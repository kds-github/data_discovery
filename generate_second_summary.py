from importlib.resources import read_text
import os
import openai
import json
import psycopg2
from dotenv import load_dotenv
from datetime import datetime
import re
import time
import uuid
from tenacity import retry, stop_after_attempt, wait_exponential

# Load environment variables from .env file
load_dotenv()
openai.api_key = os.getenv('OPENAPIKEY')

# Database connection details from environment variables
db_params = {
    "dbname": os.getenv("DBSURVEY"),
    "user": os.getenv("DBUSER"),
    "password": os.getenv("DBPASSWORD"),
    "host": os.getenv("DBHOST"),
    "port": os.getenv("DBPORT")
}

@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=10))
def make_openai_call(model="gpt-4-turbo", prompt="", temperature=0.7, max_tokens=2000):
    try:
        response = openai.ChatCompletion.create(
            model=model,
            messages=[{"role": "user", "content": prompt}],
            temperature=temperature,
            max_tokens=max_tokens
        )
        response_content = response['choices'][0]['message']['content'].strip()
        response_content = re.sub(r"```json\n|```", "", response_content).strip()
        try:
            return json.loads(response_content)
        except json.JSONDecodeError:
            return {"executive_summary": {"summary": response_content}}
    except Exception as e:
        print(f"Error calling OpenAI: {e}")
        raise

def connect_to_db():
    try:
        return psycopg2.connect(**db_params)
    except Exception as e:
        print(f"Database connection error: {e}")
        return None

def execute_query(connection, query, params=None, fetch=True):
    try:
        cursor = connection.cursor()
        cursor.execute(query, params)
        if fetch:
            return cursor.fetchall()
        connection.commit()
    except Exception as e:
        print(f"SQL Execution Error: {e}")
        connection.rollback()
    finally:
        cursor.close()

def get_distinct_control_ids(connection):
    """Get all distinct control_ids from stage.summary_by_topic"""
    result = execute_query(connection, """
        SELECT DISTINCT control_id FROM stage.summary_by_topic ORDER BY control_id;
    """)
    return [row[0] for row in result] if result else []

def get_topic_summaries_by_control_id(connection, control_id):
    """Get all topic summaries for a specific control_id"""
    result = execute_query(connection, """
        SELECT topic_, summary_ FROM stage.summary_by_topic
        WHERE control_id = %s ORDER BY topic_;
    """, (control_id,))
    return result if result else []

def get_business_info_by_control_id(connection, control_id):
    """Get business information (industry, function, role) for this control_id"""
    result = execute_query(connection, """
        SELECT DISTINCT a.industry_description, a.function_name, a.role_name 
        FROM interview.vw_answer_lookup a
        JOIN temp.summary_control sc ON a.interview_id = sc.interview_id
        WHERE sc.control_id = %s
        LIMIT 1;
    """, (control_id,))
    if result:
        return {
            "industry_description": result[0][0],
            "function_name": result[0][1],
            "role_name": result[0][2]
        }
    return None

def create_executive_summary_prompt(control_id, business_info, summaries):
    """Create prompt for generating an executive summary"""
    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    # Format each topic summary for the prompt
    summary_texts = []
    for topic, summary_json in summaries:
        try:
            summary_data = json.loads(summary_json) if isinstance(summary_json, str) else summary_json
            if "analysis" in summary_data and len(summary_data["analysis"]) > 0:
                analysis = summary_data["analysis"][0]
                summary_text = analysis.get("summary", "No summary available")
                summary_texts.append(f"Topic: {topic}\nSummary: {summary_text}")
        except (json.JSONDecodeError, KeyError) as e:
            print(f"Error parsing summary for topic '{topic}': {e}")
            summary_texts.append(f"Topic: {topic}\nSummary: Unable to parse summary data")
    
    all_summaries_text = "\n\n".join(summary_texts)
    
    # Create the prompt
    role_info = ""
    if business_info:
        role_info = f"from a {business_info['role_name']} in the {business_info['function_name']} of a {business_info['industry_description']} organization"
    
    return f"""
    Create an executive summary of the following interview topic summaries {role_info}. 
    Synthesize the key findings, identify common themes, important data flows, and notable solutions in use across all topics.
    Include the control_id {control_id} in the output. Respond in the following JSON format:

    {{
      "executive_summary": {{
        "control_id": "{control_id}",
        "summary": "<comprehensive_executive_summary>",
        "summary_date": "{current_time}",
        "key_themes": [
          "<theme_1>",
          "<theme_2>"
        ],
        "major_data_flows": [
          {{
            "source": "<major_flow_source_1>",
            "destination": "<major_flow_destination_1>"
          }},
          {{
            "source": "<major_flow_source_2>",
            "destination": "<major_flow_destination_2>"
          }}
        ],
        "key_solutions": [
          "<key_solution_1>",
          "<key_solution_2>"
        ],
        "strategic_recommendations": [
          "<recommendation_1>",
          "<recommendation_2>"
        ]
      }}
    }}

    Here are the topic summaries:
    {all_summaries_text}
    """

def insert_executive_summary(connection, control_id, summary_json):
    """Insert executive summary into stage.summary_by_interview table"""
    execute_query(connection, """
        INSERT INTO stage.summary_by_interivew (control_id, summary_, summary_date, create_date, source_)
        VALUES (%s, %s, NOW(), CURRENT_DATE, 'executive summary script');
    """, (control_id, json.dumps(summary_json)), fetch=False)

def main():
    connection = connect_to_db()
    if not connection:
        print("Database connection failed. Exiting.")
        return
    
    try:
        # Get all distinct control_ids
        control_ids = get_distinct_control_ids(connection)
        if not control_ids:
            print("No control_ids found in stage.summary_by_topic. Exiting.")
            return
        
        print(f"Found {len(control_ids)} control_ids to process.")
        
        for control_id in control_ids:
            print(f"\nProcessing control_id: {control_id}")
            
            # Check if this control_id already has an executive summary
            existing = execute_query(connection, """
                SELECT 1 FROM stage.summary_by_interivew WHERE control_id = %s LIMIT 1;
            """, (control_id,))
            
            if existing:
                print(f"Executive summary already exists for control_id {control_id}. Skipping.")
                continue
            
            # Get all topic summaries for this control_id
            summaries = get_topic_summaries_by_control_id(connection, control_id)
            if not summaries:
                print(f"No topic summaries found for control_id {control_id}. Skipping.")
                continue
            
            print(f"Found {len(summaries)} topic summaries for control_id {control_id}")
            
            # Get business information
            business_info = get_business_info_by_control_id(connection, control_id)
            
            # Create prompt for OpenAI
            prompt_text = create_executive_summary_prompt(control_id, business_info, summaries)
            
            # Call OpenAI
            print(f"Sending prompt to OpenAI for control_id {control_id}...")
            api_response = make_openai_call(prompt=prompt_text)
            
            if not api_response:
                print(f"OpenAI failed for control_id {control_id}. Skipping.")
                continue
            
            # Insert executive summary
            insert_executive_summary(connection, control_id, api_response)
            print(f"Stored executive summary for control_id {control_id}")
            
            # Add a delay to avoid rate limiting
            time.sleep(2)
            
    finally:
        connection.close()

if __name__ == "__main__":
    main()

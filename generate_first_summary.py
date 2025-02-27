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
            return {"analysis": [{"summary": response_content}]}
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

def generate_summary_control(connection):
    execute_query(connection, """
        INSERT INTO temp.summary_control (
        interview_id, respondent_id, start_date, character_count, answer_count, create_date, source_)
        SELECT interview_id, respondent_id, CURRENT_DATE, SUM(LENGTH(answer_::TEXT)),
        COUNT(answer_id), CURRENT_DATE, 'kds admin' FROM interview.vw_answer_lookup
        GROUP BY interview_id, respondent_id;
    """, fetch=False)
    result = execute_query(connection, "SELECT control_id FROM temp.summary_control ORDER BY create_date DESC LIMIT 1;")
    return result[0][0] if result else None

def get_interview_batches(connection):
    return execute_query(connection, """
        SELECT row_number() OVER (ORDER BY interview_id, topic_) AS batch_number,
        interview_id, topic_, respondent_id FROM interview.vw_answer_lookup 
        GROUP BY topic_, interview_id, respondent_id ORDER BY 3;
    """)

def get_business_key(connection, topic, interview_id, respondent_id):
    result = execute_query(connection, """
        SELECT industry_description, function_name, role_name FROM interview.vw_answer_lookup
        WHERE topic_ = %s AND interview_id = %s AND respondent_id = %s 
        GROUP BY industry_description, function_name, role_name;
    """, (topic, interview_id, respondent_id))
    return {"industry_description": result[0][0], "function_name": result[0][1], "role_name": result[0][2]} if result else None

def get_interview_responses(connection, topic, interview_id, respondent_id):
    result = execute_query(connection, """
        SELECT sort_order, topic_, subtopic_, syntax_ AS question_, answer_ FROM interview.vw_answer_lookup
        WHERE topic_ = %s AND interview_id = %s AND respondent_id = %s ORDER BY 1;
    """, (topic, interview_id, respondent_id))
    return [{"sort_order": row[0], "topic": row[1], "subtopic": row[2], "question": row[3], "answer": row[4]} for row in result] if result else None

def create_prompt(business_key, responses, control_id):
    # Current timestamp
    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    qa_text = "\n".join([f"Question (Subtopic: {resp['subtopic']}): {resp['question']}\nAnswer: {resp['answer']}\n" for resp in responses])
    return f"""
    Summarize the following interview answers from a {business_key['role_name']} in the {business_key['function_name']} of a {business_key['industry_description']} organization by topic and subtopic. Identify any data flows between source and destinations. Note any system or product names in use. Suggest a relevant follow-up question to gain deeper insights. Include the control_id {control_id} in the output. Respond in the following JSON format:
{{
  "analysis": [
    {{
      "control_id": "{control_id}",
      "summary": "<summary_explanation>",
      "summary_date": "{current_time}",
      "noted_data_flow_source": "<flow_source>",
      "noted_data_flow_destination": "<flow_target>",
      "solution_in_use": "<solution_in_use_name>",
      "follow_up_question": "<follow_up>"
    }}
  ]
}}
Here are the interview responses:
{qa_text}  
"""

def insert_summary_by_topic(connection, control_id, topic, summary_json):
    execute_query(connection, """
        INSERT INTO stage.summary_by_topic (control_id, topic_, summary_, summary_date, create_date, source_)
        VALUES (%s, %s, %s, NOW(), CURRENT_DATE, 'interview summary script');
    """, (control_id, topic, json.dumps(summary_json)), fetch=False)

def main():
    connection = connect_to_db()
    if not connection:
        print("Database connection failed. Exiting.")
        return
    try:
        control_id = generate_summary_control(connection)
        if not control_id:
            print("Failed to generate summary control. Exiting.")
            return
        print(f"Generated control_id: {control_id}")
        batches = get_interview_batches(connection)
        if not batches:
            print("No interview batches found. Exiting.")
            return
        for batch in batches:
            batch_number, interview_id, topic, respondent_id = batch
            print(f"Processing batch {batch_number}: Topic '{topic}' for Interview {interview_id}")
            business_key = get_business_key(connection, topic, interview_id, respondent_id)
            if not business_key:
                print(f"Missing business key for Topic '{topic}'. Skipping.")
                continue
            responses = get_interview_responses(connection, topic, interview_id, respondent_id)
            if not responses:
                print(f"No responses for Topic '{topic}'. Skipping.")
                continue
            prompt_text = create_prompt(business_key, responses, control_id)
            print(f"Sending prompt to OpenAI for Topic '{topic}'...")
            api_response = make_openai_call(prompt=prompt_text)
            if not api_response:
                print(f"OpenAI failed for Topic '{topic}'. Skipping.")
                continue
            insert_summary_by_topic(connection, control_id, topic, api_response)
            print(f"Stored summary for Topic '{topic}'")
            time.sleep(2)
    finally:
        connection.close()

if __name__ == "__main__":
    main()


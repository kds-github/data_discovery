import os
import psycopg2
import openai
import json
import re
import argparse
from dotenv import load_dotenv
from datetime import datetime
from jinja2 import Template

# Load environment variables from .env file
load_dotenv()
openai.api_key = os.environ.get('OPENAPIKEY')

# Function to validate UUID format
def is_valid_uuid(uuid_string):
    """Validate if the given string is a valid UUID format."""
    uuid_pattern = re.compile(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', re.IGNORECASE)
    return bool(uuid_pattern.match(uuid_string))

# Establishing database connection
def connect_to_db():
    conn = psycopg2.connect(
        dbname=os.getenv("DBSURVEY"),
        user=os.getenv("DBUSER"),
        password=os.getenv("DBPASSWORD"),
        host=os.getenv("DBHOST"),
        port=os.getenv("DBPORT")
    )
    return conn

# Fetch prompt template from the database
def fetch_prompt_template():
    conn = connect_to_db()
    cur = conn.cursor()
    query = """
    SELECT prompt_text 
    FROM admin.prompt_setting 
    WHERE name_ = 'generate_sample_answer' 
    ORDER BY create_date DESC 
    LIMIT 1;
    """
    
    cur.execute(query)
    result = cur.fetchone()
    cur.close()
    conn.close()
    
    if not result:
        raise ValueError("Prompt template 'generate_sample_answer' not found in the database.")
    
    return result[0]

# Fetch data from the database
def fetch_questions(email):
    conn = connect_to_db()
    cur = conn.cursor()
    query = """
     SELECT email_, 
               role_, 
               respondent_id, 
               industry_description, 
               subsidiary_, 
               business_unit, 
               question_text,
               question_id 
        FROM temp.vw_lookup_for_answer_test 
        WHERE email_ = %s
        ORDER BY sort_order LIMIT 20;
    """
    
    cur.execute(query, (email,))
    questions = cur.fetchall()
    cur.close()
    conn.close()
    return questions

# Generate a prompt for GPT-4 using Jinja2 template
def generate_sample_answer_prompt(template_text, industry_description, role_, question_text, question_id):
    template = Template(template_text)
    rendered_prompt = template.render(
        role_=role_,
        industry_description=industry_description,
        question_text=question_text,
        question_id=question_id
    )
    return rendered_prompt

# Interact with GPT-4 and get a sample answer
def get_gpt4_response(prompt):
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[{"role": "system", "content": "You are an assistant that formats JSON responses."},
                  {"role": "user", "content": prompt}]
    )
    return response.choices[0].message['content']

# Parse and clean the JSON response with UUID validation
def parse_gpt_response(response_text):
    try:
        response_json = json.loads(response_text)
        question_id = response_json.get("question_id")
        
        # Validate UUID format
        if not question_id or not is_valid_uuid(question_id):
            print(f"Invalid or missing UUID format received: {question_id}")
            return None, None
            
        return question_id, response_json.get("sample_answer")
    except json.JSONDecodeError:
        print("Failed to parse GPT response.")
        return None, None

# Insert answer into the database using a stored procedure
def insert_answer(cur, question_id, respondent_id, answer, answer_date, source):
    """Call the stored procedure to insert answer with an open cursor."""
    cur.execute("""
        CALL interview.up_insert_answer(
            %s, %s, %s, %s, %s
        );
    """, (question_id, respondent_id, answer, answer_date, source))

def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description='Generate test answers for survey questions.')
    parser.add_argument('--email', '-e', required=True, help='Email address to filter questions')
    args = parser.parse_args()
    
    email = args.email
    
    # Start timing
    start_time = datetime.now()
    print(f"Process started at: {start_time}")
    print(f"Generating answers for email: {email}")
    
    # Fetch the prompt template from the database
    prompt_template = fetch_prompt_template()
    print("Prompt template fetched from database.")
    
    questions = fetch_questions(email)
    if not questions:
        print(f"No questions found for email: {email}")
        return
        
    print(f"Found {len(questions)} questions to process.")
    
    conn = connect_to_db()
    cur = conn.cursor()

    # Counter for the number of processed rows
    row_count = 0
    
    for question in questions:
        # Unpack question details, now including question_id
        email_, role_, respondent_id, industry_description, subsidiary_, business_unit, question_text, original_question_id = question

        # Use the original question_id from database for safer operation
        prompt = generate_sample_answer_prompt(
            prompt_template,
            industry_description, 
            role_, 
            question_text, 
            original_question_id
        )
        print(f"Processing question_id {original_question_id}...")

        response_text = get_gpt4_response(prompt)
        gpt_question_id, sample_answer = parse_gpt_response(response_text)
        
        # Best practice: Compare the returned question_id with original
        if gpt_question_id and gpt_question_id != original_question_id:
            print(f"Warning: GPT returned different question_id: {gpt_question_id} vs original: {original_question_id}")
            
        # Always use the original question_id from the database, not the one returned by GPT
        if sample_answer:
            answer_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            source = "GPT-4"  # or any other source identifier
            try:
                insert_answer(cur, original_question_id, respondent_id, json.dumps(sample_answer), answer_date, source)
                print(f"Inserted answer for question_id {original_question_id}")
                row_count += 1  # Increment row counter
            except psycopg2.Error as e:
                print(f"Database error when inserting answer: {e}")
                conn.rollback()  # Rollback on error to continue with other questions

    conn.commit()
    cur.close()
    conn.close()

    # End timing
    end_time = datetime.now()
    print(f"Process ended at: {end_time}")
    print(f"Total execution time: {end_time - start_time}")
    print(f"Total rows processed: {row_count}")

if __name__ == "__main__":
    main()

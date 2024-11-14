import os
import openai
import json
import psycopg2
from dotenv import load_dotenv
from datetime import date
import re

# Load environment variables from .env file
load_dotenv()
openai.api_key = os.environ.get('OPENAPIKEY')

# Database connection details from environment variables
db_params = {
    "dbname": os.getenv("DBSURVEY"),
    "user": os.getenv("DBUSER"),
    "password": os.getenv("DBPASSWORD"),
    "host": os.getenv("DBHOST"),
    "port": os.getenv("DBPORT")
}

##sample data
job_title ="Senior Vice President, Platform Product Management and Developer Relations"
job_description ="Leads the strategy for their company's software platform/tools while simultaneously overseeing how external developers interact with and build on those tools. They essentially bridge the gap between building their company's developer products and ensuring the developer community successfully adopts and uses them."
email = "email@email.com"

# Function to generate prompt for job role
def generate_role_prompt(job_title, job_description):
    prompt = (
        f"Based on the following job title and description, please assign a more concise job title and provide a two-sentence role description.\n\n"
        f"Job Title: {job_title}\n"
        f"Description: {job_description}\n\n"
        f"Respond in JSON format as follows:\n"
        f"{{\n"
        f"  \"role\": \"<concise_job_title>\",\n"
        f"  \"description\": \"<role_description>\",\n"
        f"  \"rationale\": \"<one_line_explanation>\"\n"
        f"}}"
    )
    return prompt

# Function to interact with GPT-4 and parse the JSON response
def get_role_code_from_gpt(job_title, job_description):
    prompt = generate_role_prompt(job_title, job_description)
    
    response = openai.ChatCompletion.create(
        model="gpt-4-turbo",
        messages=[{"role": "user", "content": prompt}]
    )
    
    # Clean up and parse JSON response
    role_response = response['choices'][0]['message']['content'].strip()
    role_response = re.sub(r"```json\n|```", "", role_response).strip()
    
    try:
        role_data = json.loads(role_response)
    except json.JSONDecodeError as e:
        print("Error parsing JSON:", e)
        print("Response content was:", role_response)  # Debugging line
        raise ValueError("Failed to decode JSON from response.")
    
    return role_data

# Connect to PostgreSQL database
conn = psycopg2.connect(**db_params)
cur = conn.cursor()

# Generate role data from GPT-4
try:
    role_data = get_role_code_from_gpt(job_title, job_description)
except ValueError as e:
    print("Error generating role data:", e)
    conn.close()
    exit()

# Define metadata for insertion

source_ = "ChatGPT"
job_role_detail = json.dumps(role_data)  # Convert role_data to JSON for JSONB column

# Insert into PostgreSQL table using a stored procedure
try:
    cur.execute(
        """
        CALL stage.up_insert_role(%s, %s, %s, %s, %s, %s, %s);
        """,
        (
            email,
            job_title,
            role_data.get("role"),
            job_role_detail,  # JSONB job role detail
            date.today(),
            email,  # created_by
            source_
        )
    )
    
    # Commit changes
    conn.commit()
    print("Database populated with new concise job role and rationale.")
    
except Exception as e:
    print("Error inserting data:", e)
    conn.rollback()
finally:
    cur.close()
    conn.close()

import os
import json
import psycopg2
from dotenv import load_dotenv
from datetime import datetime
import uuid

# Load environment variables from .env file
load_dotenv()

# Database connection details from environment variables
db_params = {
    "dbname": os.getenv("DBSURVEY"),
    "user": os.getenv("DBUSER"),
    "password": os.getenv("DBPASSWORD"),
    "host": os.getenv("DBHOST"),
    "port": os.getenv("DBPORT")
}

def connect_to_db():
    """Connect to the PostgreSQL database"""
    try:
        return psycopg2.connect(**db_params)
    except Exception as e:
        print(f"Database connection error: {e}")
        return None

def execute_query(connection, query, params=None, fetch=True):
    """Execute a SQL query with optional parameters"""
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

def get_summaries(connection):
    """Fetch all rows from stage.summary_by_topic"""
    return execute_query(connection, """
        SELECT by_topic_id, control_id, topic_, summary_, summary_date, create_date
        FROM stage.summary_by_topic
        ORDER BY create_date;
    """)

def insert_followup_question(connection, by_topic_id, question, summary_date, create_date):
    """Insert a follow-up question into stage.followup_question_by_topic"""
    if not question:
        return
    
    # Convert the question to JSON format
    question_json = json.dumps({"follow_up_question": question})
    
    execute_query(connection, """
        INSERT INTO stage.followup_question_by_topic 
        (by_topic_id, syntax_, start_date, create_date, source_)
        VALUES (%s, %s, %s, %s, 'data parser script');
    """, (by_topic_id, question_json, summary_date, create_date), fetch=False)
    
    print(f"Inserted follow-up question for by_topic_id: {by_topic_id}")

def insert_data_flow(connection, by_topic_id, data_flow, create_date):
    """Insert a single data flow record into stage.data_flow_by_topic"""
    source = data_flow.get("source")
    destination = data_flow.get("destination")
    
    if not (source or destination):
        return
    
    # Convert source and destination to JSON
    source_json = json.dumps({"source": source}) if source else None
    destination_json = json.dumps({"destination": destination}) if destination else None
    
    execute_query(connection, """
        INSERT INTO stage.data_flow_by_topic 
        (by_topic_id, noted_data_flow_source, noted_data_flow_destination, create_date, source_)
        VALUES (%s, %s, %s, %s, 'data parser script');
    """, (by_topic_id, source_json, destination_json, create_date), fetch=False)
    
    print(f"Inserted data flow (source: {source}, destination: {destination}) for by_topic_id: {by_topic_id}")

def insert_solution_in_use(connection, by_topic_id, solution, create_date):
    """Insert a single solution in use record into stage.solution_in_use_by_topic"""
    if not solution:
        return
    
    # Convert solution to JSON
    solution_json = json.dumps({"solution": solution})
    
    execute_query(connection, """
        INSERT INTO stage.solution_in_use_by_topic 
        (by_topic_id, description_, create_date, source_)
        VALUES (%s, %s, %s, 'data parser script');
    """, (by_topic_id, solution_json, create_date), fetch=False)
    
    print(f"Inserted solution in use '{solution}' for by_topic_id: {by_topic_id}")

def process_data_flows(connection, by_topic_id, analysis, create_date):
    """Process and insert data flows, handling both the new array format and legacy single fields"""
    
    # Check if we have the new data_flows array format
    if "data_flows" in analysis and isinstance(analysis["data_flows"], list):
        # Process multiple data flows
        for data_flow in analysis["data_flows"]:
            insert_data_flow(connection, by_topic_id, data_flow, create_date)
    else:
        # Handle legacy format with single source/destination fields
        source = analysis.get("noted_data_flow_source")
        destination = analysis.get("noted_data_flow_destination")
        
        if source or destination:
            legacy_data_flow = {
                "source": source,
                "destination": destination
            }
            insert_data_flow(connection, by_topic_id, legacy_data_flow, create_date)

def process_solutions(connection, by_topic_id, analysis, create_date):
    """Process and insert solutions in use, handling both the new array format and legacy single field"""
    
    # Check if we have the new solutions_in_use array format
    if "solutions_in_use" in analysis and isinstance(analysis["solutions_in_use"], list):
        # Process multiple solutions
        for solution in analysis["solutions_in_use"]:
            insert_solution_in_use(connection, by_topic_id, solution, create_date)
    else:
        # Handle legacy format with single solution field
        solution = analysis.get("solution_in_use")
        if solution:
            insert_solution_in_use(connection, by_topic_id, solution, create_date)

def main():
    connection = connect_to_db()
    if not connection:
        print("Database connection failed. Exiting.")
        return
    
    try:
        summaries = get_summaries(connection)
        if not summaries:
            print("No summaries found in stage.summary_by_topic. Exiting.")
            return
        
        print(f"Found {len(summaries)} summaries to process.")
        
        for summary_row in summaries:
            by_topic_id, control_id, topic, summary_json, summary_date, create_date = summary_row
            
            print(f"\nProcessing summary for topic '{topic}' (by_topic_id: {by_topic_id})")
            
            try:
                # Parse the JSON data
                summary_data = json.loads(summary_json) if isinstance(summary_json, str) else summary_json
                
                # Extract data from the first analysis item (if it exists)
                if "analysis" in summary_data and len(summary_data["analysis"]) > 0:
                    analysis = summary_data["analysis"][0]
                    
                    # Extract and insert follow-up question
                    follow_up_question = analysis.get("follow_up_question")
                    insert_followup_question(connection, by_topic_id, follow_up_question, summary_date, create_date)
                    
                    # Process data flows (handles both one-to-many and legacy formats)
                    process_data_flows(connection, by_topic_id, analysis, create_date)
                    
                    # Process solutions in use (handles both one-to-many and legacy formats)
                    process_solutions(connection, by_topic_id, analysis, create_date)
                    
                else:
                    print(f"No analysis data found in summary for topic '{topic}'")
            
            except json.JSONDecodeError as e:
                print(f"Error parsing JSON for topic '{topic}': {e}")
            except Exception as e:
                print(f"Error processing summary for topic '{topic}': {e}")
    
    finally:
        connection.close()

if __name__ == "__main__":
    main()

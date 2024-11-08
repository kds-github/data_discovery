from datetime import date
import json
import os
import psycopg2
from flask import Flask, render_template, request
from dotenv import load_dotenv

load_dotenv()  # Load environment variables from .env file

app = Flask(__name__)

# Function to fetch questions from the database using a view and email parameter
def fetch_questions(cur, email):
    # Execute query to fetch questions using the provided cursor
    cur.execute("""
        SELECT
            email_,
            respondent_id,
            description_,
            question_id,
            question_text,
            gui_type,
            help_text,
            help_list
        FROM
            interview.vw_question_lookup
        WHERE
            email_ = %s ORDER BY sort_order;
    """, (email,))
    
    questions = cur.fetchall()

    # Format questions for rendering in the template
    formatted_questions = []
    for row in questions:
        email_, respondent_id, description_, question_id,  question_text, gui_type, help_text, help_list = row
        formatted_questions.append((question_text, gui_type, help_text, help_list, question_id, respondent_id))
    
    return formatted_questions


def insert_answer(cur, question_id, respondent_id, answer, answer_date, source):
    """Call the stored procedure to insert answer with an open cursor."""
    cur.execute("""
        CALL interview.insert_answer(
            %s, %s, %s, %s, %s
        );
    """, (question_id, respondent_id, answer, answer_date, source))

# Route for displaying the form
@app.route('/', methods=['GET', 'POST'])
def index():
    email = request.args.get('email', 'danielle.lee@globallogistics.com')  # Retrieve or default email
    conn = psycopg2.connect(
        dbname=os.getenv("DBSURVEY"),
        user=os.getenv("DBUSER"),
        password=os.getenv("DBPASSWORD"),
        host=os.getenv("DBHOST"),
        port=os.getenv("DBPORT")
    )
    cur = conn.cursor()

    if request.method == 'POST':
        submitted_by = email
        answer_date = date.today()
        source = "form submission"
        
    # Loop through form items to process answers
        for key, value in request.form.items():
            # Process only keys that start with 'question_id_'
            if key.startswith("question_id_"):
                # Extract the question number suffix
                question_id_n = key.split("question_id_")[1]
                
                # Retrieve question ID, respondent ID, and answer in a single block
                question_id = value
                respondent_id = request.form.get(f"respondent_id_{question_id_n}")
                answer = request.form.get(f"response_{question_id_n}")
                
                # Convert answer to JSON only if it is non-empty
                answer_jsonb = json.dumps(answer) if answer else None

                # Insert answer using the stored procedure
                insert_answer(cur, question_id, respondent_id, answer_jsonb, answer_date, source)

        # Finalize the database transaction
        conn.commit()
        cur.close()
        conn.close()

        # Return a success message
        return "Responses submitted successfully!"

    else:
        # Fetch questions with the cursor and pass to form
        questions = fetch_questions(cur, email)  # Passing cur and email to the function
        cur.close()
        conn.close()
        return render_template('form.html', questions=questions, email=email)


if __name__ == '__main__':
    app.run(debug=True)

import os
import psycopg2
from flask import Flask, render_template, request
from dotenv import load_dotenv

load_dotenv()  # Load environment variables from .env file

app = Flask(__name__)

# Function to fetch questions from the database including help_ column
def fetch_questions():
    conn = psycopg2.connect(
        dbname=os.environ.get("DBSURVEY"),
        user=os.environ.get("DBUSER"),
        password=os.environ.get("DBPASSWORD"),
        host=os.environ.get("DBHOST"),
        port=os.environ.get("DBPORT")
    )
    cur = conn.cursor()
    
    # Adjust SQL to select from the stage.question schema
    cur.execute("""
   SELECT
    syntax_ AS question_text,
    gui_type,
    help_->>'help_text' AS help_text,
    help_->'help_list' AS help_list
    FROM
    interview.question
    ORDER BY
    sort_order;
    """)
    
    questions = cur.fetchall()
    conn.close()

    # Here we're unpacking four values per question row
    formatted_questions = []
    for row in questions:
        question_text, type_, help_text, help_list = row  # Ensure all four values are unpacked
        formatted_questions.append((question_text, type_, help_text, help_list))
    
    return formatted_questions

# Route for displaying the form
@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        # Process form submission
        responses = request.form.getlist('response')
        # Code to handle saving responses to the database goes here
        return "Responses submitted successfully!"
    else:
        # Fetch questions from the database
        questions = fetch_questions()
        return render_template('form.html', questions=questions)

if __name__ == '__main__':
    app.run(debug=True)

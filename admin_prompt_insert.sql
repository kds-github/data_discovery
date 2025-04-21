WITH check_existing AS (
    SELECT 1 
    FROM admin.prompt_setting 
    WHERE name_ = 'generate_sample_answer'
)
INSERT INTO admin.prompt_setting (name_, prompt_text, response_count, create_date, created_by, source_, modified_by, modified_date)
SELECT 'generate_sample_answer',
       'Based on the following industry_description and role, please generate a sample answer to the question. Reference what tool is in use when known.

role_: {{ role_ }}
industry_description: {{ industry_description }}
question_text: {{ question_text }}

Respond in JSON format as follows:
{
  "question_id": "{{ question_id }}",
  "sample_answer": "<generated_answer>"
}',
       '20',
       '2025-04-14 00:00:00-05',
       'automated script',
       'generate_test_answer.py conversion',
       NULL,
       NULL
WHERE NOT EXISTS (SELECT 1 FROM check_existing);


WITH check_existing AS (
    SELECT 1 
    FROM admin.prompt_setting 
    WHERE name_ = 'primary interview question'
)
INSERT INTO admin.prompt_setting (name_, prompt_text, response_count, create_date, created_by, source_, modified_by, modified_date)
SELECT 'primary interview question',
       'Generate {{ response_count }} interview questions to ask a {{ role_ }} in the {{ business_function }} of a {{ industry_code_description }} organization. The questions should cover the following aspects: primary sources of data, tools for data acquisition, data usage, frequency, data volume, integration with other sources, and strengths or weaknesses of the data. For each question generate a gui_type of either checkbox - all that apply, dropdown - single select, textarea for open ended responses. Also generate help_text to give some added instructions like, select all that apply and include a help_list of possible items to display as checkbox items.
Generate each question in the following JSON format:

{
  "questions": [
    {
      "question": "<question_text>",
      "topic": "<optional_topic>",
      "subtopic": "<optional_subtopic>",
      "help_text": "<optional_explanation>",
      "help_list": "<optional_explanation>",
      "gui_type": "<optional_gui_type>",
      "type": "<question_type>",
      "sort_order": "<question_sort_order>"
    },
    ...
  ]
}',
       12,
       '2025-04-15 00:00:00-05',
       'automated script',
       'generate_question.py conversion',
       NULL,
       NULL
WHERE NOT EXISTS (SELECT 1 FROM check_existing);

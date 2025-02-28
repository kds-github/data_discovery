CREATE VIEW interview.vw_answer_lookup AS
SELECT
    q.question_id,
    q.syntax_,
    q.topic_,
    q.subtopic_,
    q.weight_,
	  q.sort_order,
	  a.answer_id,
    a.answer_,
	  a.answer_date,
    a.respondent_id,
    i.interview_id,
    d.model_id,
    r.role_id,
    r.name_ AS role_name,
    bf.function_id,
    bf.name_ AS function_name,
    ind.industry_hash_id,
    ind.description_ AS industry_description
FROM
    interview.question q
INNER JOIN
    interview.answer a ON q.question_id = a.question_id
INNER JOIN
    client.interview i ON q.interview_id = i.interview_id
INNER JOIN
    model.discovery d ON i.model_id = d.model_id
INNER JOIN
    model.role r ON d.role_id = r.role_id
INNER JOIN
    model.business_function bf ON d.function_id = bf.function_id
INNER JOIN
    reference.industry ind ON d.industry_hash_id = ind.industry_hash_id;

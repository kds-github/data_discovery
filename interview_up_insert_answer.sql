CREATE OR REPLACE PROCEDURE interview.up_insert_answer(
	IN in_question_id uuid,
	IN in_respondent_id uuid,
	IN in_answer jsonb,
	IN in_answer_date date,
	IN in_source character varying)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    INSERT INTO interview.answer_in_progress (
        question_id, 
        respondent_id, 
        answer_, 
        answer_date, 
        source_
    ) VALUES (
        in_question_id, 
        in_respondent_id, 
        in_answer, 
        in_answer_date, 
        in_source
    );
END;
$BODY$;
ALTER PROCEDURE interview.insert_answer(uuid, uuid, jsonb, date, character varying)
    OWNER TO postgres;

ALTER TABLE interview.question
ADD COLUMN interview_id UUID NULL;

UPDATE interview.question set interview_id = (SELECT interview_id from client.interview  limit 1);  --lookup for sample interview

ALTER TABLE interview.question
ADD CONSTRAINT fk_interview_id FOREIGN KEY (interview_id)
REFERENCES client.interview (interview_id)
ON UPDATE NO ACTION
ON DELETE NO ACTION;

CREATE view interview.vw_question_lookup AS
SELECT ir.email_ email_, 
	ir.role_id role_id, 
	cr.description_ description_, 
	iq.question_id question_id,
	ir.respondent_id respondent_id,
 	iq.syntax_ question_text,
    iq.gui_type gui_type,
    iq.help_->>'help_text' help_text,
    iq.help_->'help_list' help_list,
	iq.sort_order sort_order
from interview.respondent ir
INNER JOIN client.role cr ON
ir.role_id = cr.role_id
INNER JOIN client.interview ci ON
cr.role_id = ci.role_id
INNER JOIN interview.question iq ON
iq.interview_id = ci.interview_id;

DROP TABLE interview.answer_in_progress;

CREATE TABLE  interview.answer_in_progress
(
 progress_id        uuid NOT NULL DEFAULT gen_random_uuid(),
 question_id        uuid NOT NULL,
 respondent_id 		uuid NOT NULL,
 answer_            jsonb NULL,
 answer_date        date NOT NULL,
 score_             smallint NULL,
 location_reference varchar(48) NULL,
 source_            varchar(96) NOT NULL,
 hash_value         bytea NULL,
 CONSTRAINT PK_answer_in_progress PRIMARY KEY ( progress_id ),
 CONSTRAINT FK_progress_question FOREIGN KEY ( question_id ) REFERENCES interview.question ( question_id )
);

CREATE OR REPLACE PROCEDURE interview.insert_answer(
    in_question_id uuid,
    in_respondent_id uuid,
    in_answer jsonb,
    in_answer_date date,
    in_source varchar
) 
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

SELECT 'interview.answer updates dones..' AS status_;

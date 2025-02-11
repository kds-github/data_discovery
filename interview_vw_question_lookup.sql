
CREATE OR REPLACE VIEW interview.vw_question_lookup
 AS
 SELECT ir.email_,
    ir.role_id,
    cr.description_,
    iq.question_id,
    ir.respondent_id,
    iq.syntax_ AS question_text,
    iq.gui_type,
    iq.help_text,
    iq.help_list,
    iq.sort_order
   FROM interview.respondent ir
     JOIN client.role cr ON ir.role_id = cr.role_id
     JOIN client.interview ci ON cr.role_id = ci.role_id
     JOIN interview.question iq ON iq.interview_id = ci.interview_id;

ALTER TABLE interview.vw_question_lookup
    OWNER TO postgres;


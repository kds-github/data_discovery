CREATE VIEW temp.vw_lookup_for_answer_test AS
 SELECT ir.email_,
    ci.title_ AS interview_title,
    ir.role_id,
    sy.name_ AS subsidiary_,
    sy.industry_hash_id,
    ri.description_ AS industry_description,
    bu.name_ AS business_unit,
    cr.description_ AS role_,
    iq.question_id,
    ir.respondent_id,
    iq.syntax_ AS question_text,
    iq.gui_type,
    iq.sort_order
   FROM ((((((interview.respondent ir
     JOIN client.role cr ON ((ir.role_id = cr.role_id)))
     JOIN client.interview ci ON ((cr.role_id = ci.role_id)))
     JOIN interview.question iq ON ((iq.interview_id = ci.interview_id)))
     JOIN client.business_unit bu ON ((cr.unit_id = bu.unit_id)))
     JOIN client.subsidiary sy ON ((bu.subsidiary_id = sy.subsidiary_id)))
     JOIN reference.industry ri ON (((sy.industry_hash_id)::text = (ri.industry_hash_id)::text)));

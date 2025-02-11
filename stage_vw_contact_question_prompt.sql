
CREATE OR REPLACE VIEW stage.vw_contact_question_prompt
 AS
 SELECT row_number() OVER (ORDER BY contact.rag_role, contact.business_unit) AS row_number,
    contact.rag_role,
    bu.rag_business_function,
    subsidiary.rag_industry_code,
    subsidiary.rag_industry_description,
    subsidiary.industry_hash_id,
    aps.response_count
   FROM stage.contact
     JOIN stage.subsidiary ON contact.subsidiary_::text = subsidiary.name_::text
     JOIN admin.prompt_setting aps ON aps.name_::text = 'primary interview question'::text
     JOIN stage.business_unit bu ON bu.name_::text = contact.business_unit::text;

ALTER TABLE stage.vw_contact_question_prompt
    OWNER TO postgres;


CREATE OR REPLACE PROCEDURE stage.up_insert_model(
	IN p_industry_code_source character varying,
	IN p_model_name character varying,
	IN p_project_reference character varying)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    -- Update parent industry hash ID
    UPDATE stage.parent p
    SET industry_hash_id = i.industry_hash_id
    FROM reference.industry i
    WHERE i.code_ = p.rag_industry_code
    AND i.code_source = p_industry_code_source;  

    -- Update subsidiary industry hash ID
    UPDATE stage.subsidiary s
    SET industry_hash_id = i.industry_hash_id
    FROM reference.industry i
    WHERE i.code_ = s.rag_industry_code
    AND i.code_source = p_industry_code_source;

    -- Truncate model and model_question tables
    TRUNCATE TABLE stage.model;
    TRUNCATE TABLE stage.model_question;

    -- Insert into model table
    INSERT INTO stage.model (
        industry_hash_id,
        business_function,
        role_,
        name_,
        create_date,
        created_by,
        source_,
        project_reference,
        response_count
    )
    SELECT 
        industry_hash_id,
        rag_business_function,
        rag_role,
        p_model_name AS model_name,
        CURRENT_DATE AS create_date,
        USER AS created_by,
        'vw_contact_question_prompt' AS source_,
        p_project_reference AS project_reference,
        response_count
    FROM stage.vw_contact_question_prompt
    GROUP BY 
        industry_hash_id,
        rag_business_function,
        rag_role,
        response_count;
END;
$BODY$;
ALTER PROCEDURE stage.up_insert_model(character varying, character varying, character varying)
    OWNER TO postgres;
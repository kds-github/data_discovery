CREATE OR REPLACE PROCEDURE stage.up_insert_question(
	IN p_industry_hash_id character varying,
	IN p_business_function character varying,
	IN p_role_ character varying,
	IN p_model_topic character varying,
	IN p_topic_ character varying,
	IN p_subtopic_ character varying,
	IN p_syntax_ jsonb,
	IN p_help_text jsonb,
	IN p_help_list jsonb,
	IN p_response_type character varying,
	IN p_sort_order smallint,
	IN p_create_date date,
	IN p_source_ character varying,
	IN p_gui_type character varying)
LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    INSERT INTO stage.model_question (
        industry_hash_id,
        business_function,
        role_,
        model_topic,
        topic_,
        subtopic_,
        syntax_,
        help_text,
        help_list,
        response_type,
        sort_order,
        create_date,
        modified_date,
        source_,
        gui_type
    )
    VALUES (
        p_industry_hash_id,
        p_business_function,
        p_role_,
        p_model_topic,
        p_topic_,
        p_subtopic_,
        p_syntax_,
        p_help_text,
        p_help_list,
        p_response_type,
        p_sort_order,
        p_create_date,
        CURRENT_DATE,
        p_source_,
        p_gui_type  -- Use the parameter instead of extracting from syntax_
    )
    ON CONFLICT (industry_hash_id, business_function, role_, sort_order)
    DO UPDATE SET
        syntax_ = EXCLUDED.syntax_,
        help_text = EXCLUDED.help_text,
        help_list = EXCLUDED.help_list,
        modified_date = CURRENT_DATE,
        response_type = EXCLUDED.response_type,  -- Fixed column name
        topic_ = EXCLUDED.topic_,
        subtopic_ = EXCLUDED.subtopic_,
        source_ = EXCLUDED.source_,
        gui_type = EXCLUDED.gui_type;
END;
$BODY$;
ALTER PROCEDURE stage.up_insert_question(character varying, character varying, character varying, character varying, character varying, character varying, jsonb, jsonb, jsonb, character varying, smallint, date, character varying, character varying)
    OWNER TO postgres;
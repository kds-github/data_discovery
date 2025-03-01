CREATE view stage.vw_contact_question_prompt AS
SELECT row_number() OVER (ORDER BY contact.rag_role, contact.business_unit) AS row_number,
    subsidiary.industry_hash_id,
    bu.name_ AS business_function,
    contact.rag_role,
    aps.response_count,
    subsidiary.rag_industry_code,
    subsidiary.rag_industry_description
   FROM (((stage.contact
     JOIN stage.subsidiary ON (((contact.subsidiary_)::text = (subsidiary.name_)::text)))
     JOIN admin.prompt_setting aps ON (((aps.name_)::text = 'primary interview question'::text)))
     JOIN stage.business_unit bu ON (((bu.name_)::text = (contact.business_unit)::text)));

CREATE VIEW  interview.vw_question_lookup AS
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
   FROM (((interview.respondent ir
     JOIN client.role cr ON ((ir.role_id = cr.role_id)))
     JOIN client.interview ci ON ((cr.role_id = ci.role_id)))
     JOIN interview.question iq ON ((iq.interview_id = ci.interview_id)));
	 

CREATE OR REPLACE PROCEDURE stage.up_insert_model(IN p_industry_code_source character varying, IN p_model_name character varying, IN p_project_reference character varying)
 LANGUAGE plpgsql
AS $procedure$
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
       business_function, -- using business_unit instead of 
        rag_role,
     	p_model_name,
        CURRENT_DATE AS create_date,
        USER AS created_by,
        'vw_contact_question_prompt' AS source_,
        p_project_reference AS project_reference,
        response_count
    FROM stage.vw_contact_question_prompt
    GROUP BY 
        industry_hash_id,
        business_function,
        rag_role,
        response_count;
END;
$procedure$;

CREATE OR REPLACE PROCEDURE stage.up_insert_question(IN p_industry_hash_id character varying, IN p_business_function character varying, IN p_role_ character varying, IN p_model_topic character varying, IN p_topic_ character varying, IN p_subtopic_ character varying, IN p_syntax_ jsonb, IN p_help_text jsonb, IN p_help_list jsonb, IN p_response_type character varying, IN p_sort_order smallint, IN p_create_date date, IN p_source_ character varying, IN p_gui_type character varying)
 LANGUAGE plpgsql
AS $procedure$
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
$procedure$;

CREATE OR REPLACE PROCEDURE model.up_insert_model()
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    -- Insert roles
    INSERT INTO model.role(name_, description_, source_, created_by)	
    SELECT rag_role, rag_role_rationale, rag_role_source, rag_role_created_by 
    FROM stage.contact c
    INNER JOIN stage.business_unit bu on bu.name_ = c.business_unit 
    INNER JOIN stage.subsidiary s on s.name_ = c.subsidiary_;

    -- Insert business functions
    INSERT INTO model.business_function(name_, description_, source_, created_by)	
    SELECT bu.name_, rag_business_function, rag_function_source, rag_function_created_by 
    FROM stage.business_unit bu
    INNER JOIN stage.model m on m.business_function = bu.name_
    INNER JOIN stage.subsidiary s on m.industry_hash_id = s.industry_hash_id;

    -- Insert author
    INSERT INTO model.author (
        author_id, name_, email_, start_date, end_date, 
        create_date, modified_date, hash_value, source_
    )
    VALUES (
        gen_random_uuid(),
        'kds discovery author',
        'kds@kds_discovery.com',
        CURRENT_DATE,
        NULL,
        CURRENT_DATE,
        NULL,
        NULL,
        'kds_discovery'
    );

    -- Insert discovery records
    INSERT INTO model.discovery (
        industry_hash_id, function_id, role_id, author_id, 
        title_, model_topic, start_date, project_id, source_
    )
    SELECT
        s.industry_hash_id,
        bf.function_id,
        r.role_id,
        (SELECT author_id FROM model.author WHERE name_ = 'kds discovery author'),
        'Model Test',
        'Model Topic Test',
        CURRENT_DATE,
        (SELECT project_id FROM admin.project LIMIT 1),
        'kds_discovery hybrid LLM'
    FROM stage.model s
    INNER JOIN model.business_function bf ON s.business_function = bf.name_
    INNER JOIN model.role r ON s.role_ = r.name_;

    -- Insert questions
    INSERT INTO model.question (
        question_id, model_id, author_id, syntax_, help_text, 
        help_list, gui_type, sort_order, location_reference, 
        topic_, subtopic_, create_date, source_
    )
    SELECT
        s.question_id,
        d.model_id,
        (SELECT author_id FROM model.author WHERE name_ = 'kds discovery author'),
        syntax_,
        help_text,
        help_list,
        gui_type,
        sort_order,
        location_reference,
        s.topic_,
        s.subtopic_,
        CURRENT_DATE,
        'kds_discovery hybrid LLM'
    FROM stage.model_question s
    INNER JOIN model.business_function bf ON s.business_function = bf.name_
    INNER JOIN model.role r ON s.role_ = r.name_
    INNER JOIN model.discovery d ON bf.function_id = d.function_id 
        AND r.role_id = d.role_id 
        AND d.industry_hash_id = s.industry_hash_id;

    -- Insert parent organizations
    INSERT INTO client.parent (
        name_, organization_type, stock_symbol, industry_hash_id, 
        product_service, annual_revenue, employee_total, website_, 
        location_, source_, created_by, modified_date, modified_by, 
        create_date
    )
    SELECT 
        name_, organization_type, stock_symbol, industry_hash_id, 
        product_service, annual_revenue, employee_total, website_, 
        location_, source_, created_by, modified_date, modified_by, 
        CURRENT_DATE
    FROM stage.parent;

    -- Insert subsidiaries
    INSERT INTO client.subsidiary (
        organization_type, parent_id, name_, stock_symbol, 
        industry_hash_id, product_service, annual_revenue, 
        employee_total, website_, location_reference, source_, 
        create_date, created_by, modified_date, modified_by
    )
    SELECT  
        s.organization_type, p.parent_id, s.name_, s.stock_symbol, 
        s.industry_hash_id, s.product_service, s.annual_revenue, 
        s.employee_total, s.website_, s.location_, s.source_, 
        CURRENT_DATE, s.created_by, s.modified_date, s.modified_by
    FROM stage.subsidiary s 
    INNER JOIN client.parent p ON s.parent_name = p.name_;

    -- Insert business units
    INSERT INTO client.business_unit (
        parent_id, subsidiary_id, name_, create_date, created_by, 
        modified_date, modified_by, source_
    )
    SELECT 
        p.parent_id, sd.subsidiary_id, s.name_, CURRENT_DATE, 
        s.created_by, s.modified_date, s.modified_by, s.source_
    FROM stage.business_unit s 
    INNER JOIN client.parent p ON s.parent_ = p.name_ 
    INNER JOIN client.subsidiary sd ON s.subsidiary_ = sd.name_;

    -- Insert roles
    INSERT INTO client.role (
        description_, respondent_, location_reference, unit_id, 
        create_date, source_
    )
    SELECT 
        c.rag_role, c.respondent_, c.location_reference, 
        c.unit_id, current_date, 'kds_discovery_user'
    FROM (
        SELECT DISTINCT ON (
            rag_role, business_unit, subsidiary_, parent_
        )
        c.rag_role,
        c.respondent_,
        c.location_reference,
        bu.unit_id
        FROM stage.contact c
        LEFT JOIN client.business_unit bu ON bu.name_ = c.business_unit
        LEFT JOIN client.subsidiary sub ON sub.name_ = c.subsidiary_
        LEFT JOIN client.parent p ON p.name_ = c.parent_
        WHERE bu.unit_id IS NOT NULL
        AND sub.subsidiary_id IS NOT NULL
        AND p.parent_id IS NOT NULL
    ) AS c;

    -- Insert respondents
    INSERT INTO interview.respondent (
        email_, role_id, description_, respondent_, 
        location_reference, first_name, last_name, title_, 
        phone_, create_date, source_
    )
    SELECT 
        c.email_, c.role_id, c.rag_role, c.respondent_, 
        c.location_reference, c.first_name, c.last_name, 
        c.title_, c.phone_, CURRENT_DATE, 'kds_discovery_user'
    FROM (
        SELECT DISTINCT ON (
            email_, rag_role, business_unit, subsidiary_, parent_
        )
        c.email_,     
        cr.role_id, 
        c.rag_role,
        c.respondent_,
        c.location_reference,
        c.first_name, 
        c.last_name, 
        c.title_, 
        c.phone_
        FROM stage.contact c
        LEFT JOIN client.role cr ON cr.description_ = c.rag_role		
        LEFT JOIN client.business_unit bu ON bu.name_ = c.business_unit
        LEFT JOIN client.subsidiary sub ON sub.name_ = COALESCE(c.subsidiary_, '')
        LEFT JOIN client.parent p ON p.name_ = c.parent_
        WHERE bu.unit_id IS NOT NULL
        AND p.parent_id IS NOT NULL
    ) AS c;

		INSERT INTO interview.author (name_, email_, start_date, create_date, source_) 
		SELECT name_, email_, CURRENT_DATE, CURRENT_DATE, 'kds_discovery_admin'
		FROM model.author;


	INSERT INTO client.interview (
	    role_id,
	    model_id,
	    frequency_,
	    source_,
	    create_date,
		project_id
	)
	SELECT DISTINCT
	    cr.role_id,
	    d.model_id,
	    'one-time' AS frequency_,
	    'system' AS source_,
	    CURRENT_DATE AS create_date,
		(SELECT project_id FROM admin.project  LIMIT 1)
	FROM stage.model m
	INNER JOIN stage.contact c ON c.rag_role = m.role_
	INNER JOIN model.role r ON r.name_ = m.role_
	INNER JOIN model.business_function bf ON bf.name_ = m.business_function
	INNER JOIN model.discovery d ON 
	    bf.function_id = d.function_id 
	    AND r.role_id = d.role_id 
	    AND m.industry_hash_id = d.industry_hash_id
	INNER JOIN client.role cr ON cr.description_ = m.role_;

    -- Insert interview questions
    INSERT INTO interview.question (
        model_question_id, syntax_, help_text, help_list, 
        gui_type, sort_order, create_date, modified_date, 
        disable_, topic_, subtopic_, weight_, interview_id, 
        author_id, source_
    )
    SELECT 
        mq.question_id, mq.syntax_, mq.help_text, help_list, 
        mq.gui_type, mq.sort_order, mq.create_date, 
        mq.modified_date, mq.disable_, mq.topic_, mq.subtopic_, 
        mq.weight_, ci.interview_id, ia.author_id, 
        'kds_discovery_admin'
    FROM model.question as mq
    LEFT JOIN interview.author ia on ia.name_ = 'kds discovery author'
    INNER JOIN model.discovery d ON d.model_id = mq.model_id
    INNER JOIN client.interview ci ON ci.model_id = d.model_id;
END;
$procedure$;

CREATE OR REPLACE PROCEDURE interview.up_insert_answer(IN in_question_id uuid, IN in_respondent_id uuid, IN in_answer jsonb, IN in_answer_date timestamp with time zone, IN in_source character varying)
 LANGUAGE plpgsql
AS $procedure$
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
$procedure$;

CREATE OR REPLACE PROCEDURE temp.up_insert_question(IN p_nasic_code character varying, IN p_business_unit character varying, IN p_role_ character varying, IN p_model_topic character varying, IN p_topic_ character varying, IN p_subtopic_ character varying, IN p_syntax_ jsonb, IN p_help_ jsonb, IN p_type_ character varying, IN p_sort_order smallint, IN p_create_date date, IN p_source_ character varying)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    -- Insert or Update logic
    INSERT INTO temp.model_question (
        nasic_code,
        business_unit,
        role_,
        model_topic,
        topic_,
        subtopic_,
        syntax_,
        help_,
        type_,
        sort_order,
        create_date,
        modified_date,
        source_,
        gui_type
    )
    VALUES (
        p_nasic_code,
        p_business_unit,
        p_role_,
        p_model_topic,
        p_topic_,
        p_subtopic_,
        p_syntax_,
        p_help_,
        p_type_,
        p_sort_order,
        p_create_date,
        CURRENT_DATE,  -- Set modified_date to today on insert
        p_source_,
        p_syntax_ ->> 'gui_type'  -- Extract GUI type from JSONB syntax_
    )
    ON CONFLICT (nasic_code, business_unit, role_, sort_order) -- Add unique constraint columns as needed
    DO UPDATE SET
        syntax_ = EXCLUDED.syntax_,
        help_ = EXCLUDED.help_,
        modified_date = CURRENT_DATE,
        type_ = EXCLUDED.type_,
        topic_ = EXCLUDED.topic_,
        subtopic_ = EXCLUDED.subtopic_,
        source_ = EXCLUDED.source_,
        gui_type = EXCLUDED.gui_type;

END;
$procedure$;

CREATE OR REPLACE PROCEDURE model.up_delete_model()
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    DELETE FROM interview.question_response_score CASCADE;
    DELETE FROM interview.answer_in_progress CASCADE;
    DELETE FROM interview.answer CASCADE;
    DELETE FROM interview.schedule CASCADE;
    DELETE FROM interview.rating CASCADE;
    DELETE FROM interview.question CASCADE;
    DELETE FROM interview.respondent CASCADE;

    DELETE FROM client.interview CASCADE;
    DELETE FROM client.role CASCADE;
    DELETE FROM client.business_unit CASCADE;
    DELETE FROM client.subsidiary CASCADE;
    DELETE FROM client.parent CASCADE;

    DELETE FROM model.question CASCADE;
    DELETE FROM model.discovery CASCADE;
    DELETE FROM model.author CASCADE;
    DELETE FROM model.role CASCADE;
    DELETE FROM model.business_function CASCADE;

    DELETE FROM interview.author CASCADE;
    DELETE FROM analysis.report CASCADE;
END;
$procedure$;


CREATE OR REPLACE PROCEDURE model.up_insert_model(
	)
LANGUAGE 'plpgsql'
AS $BODY$
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
$BODY$;
ALTER PROCEDURE model.up_insert_model()
    OWNER TO postgres;
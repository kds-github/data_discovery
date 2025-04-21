--
-- Drop foreign key
--
ALTER TABLE client.interview_history 
   DROP CONSTRAINT interview_history_interview_id_fkey;

--
-- Create function "client"."fn_log_interview_change"
--
CREATE FUNCTION client.fn_log_interview_change ()
RETURNS trigger
LANGUAGE plpgsql
VOLATILE
AS $plpgsql$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    INSERT INTO client.interview_history (
      interview_id, role_id, request_date, model_id, cost, frequency_,
      interview_admin, approval_date, start_date, end_date, create_date,
      modified_date, created_by, modified_by, author_id, source_,
      title_, project_id, change_type, change_reason
    ) VALUES (
      OLD.interview_id, OLD.role_id, OLD.request_date, OLD.model_id, OLD.cost, OLD.frequency_,
      OLD.interview_admin, OLD.approval_date, OLD.start_date, OLD.end_date, OLD.create_date,
      CURRENT_TIMESTAMP, OLD.created_by, NEW.modified_by, OLD.author_id, OLD.source_,
      OLD.title_, OLD.project_id, 'UPDATE', TG_ARGV[0]
    );
  ELSIF TG_OP = 'INSERT' THEN
    INSERT INTO client.interview_history (
      interview_id, role_id, request_date, model_id, cost, frequency_,
      interview_admin, approval_date, start_date, end_date, create_date,
      modified_date, created_by, modified_by, author_id, source_,
      title_, project_id, change_type, change_reason
    ) VALUES (
      NEW.interview_id, NEW.role_id, NEW.request_date, NEW.model_id, NEW.cost, NEW.frequency_,
      NEW.interview_admin, NEW.approval_date, NEW.start_date, NEW.end_date, NEW.create_date,
      CURRENT_TIMESTAMP, NEW.created_by, NEW.created_by, NEW.author_id, NEW.source_,
      NEW.title_, NEW.project_id, 'CREATE', TG_ARGV[0]
    );
  END IF;
  RETURN NULL;
END;
$plpgsql$;

--
-- Drop foreign key
--
ALTER TABLE interview.question_redirect 
   DROP CONSTRAINT fk_referral_01;

--
-- Alter column "email_" on table "interview"."author"
--
ALTER TABLE interview.author 
  ALTER COLUMN email_ TYPE character varying(48);

--
-- Create trigger "client"."tr_interview_history"
--
CREATE TRIGGER tr_interview_history
after INSERT OR UPDATE
ON client.interview
FOR EACH ROW
EXECUTE FUNCTION client.fn_log_interview_change('');

--
-- Change firing mode for trigger tr_interview_history
--
ALTER TABLE client.interview ENABLE TRIGGER tr_interview_history;

--
-- Create function "client"."fn_update_interview"
--
CREATE FUNCTION client.fn_update_interview (IN interview_id_param uuid, IN updated_values jsonb, IN modified_by_param character varying, IN change_reason_param text DEFAULT NULL::text)
RETURNS boolean
LANGUAGE plpgsql
VOLATILE
AS $plpgsql$
BEGIN
  -- Perform update using the jsonb input
  UPDATE client.interview
  SET 
    role_id = COALESCE((updated_values->>'role_id')::uuid, role_id),
	frequency_ = COALESCE(updated_values->>'frequency_', frequency_),
	request_date = COALESCE((updated_values->>'request_date')::date, request_date),
	 approval_date = COALESCE((updated_values->>'approval_date')::date, approval_date),
	 start_date = COALESCE((updated_values->>'start_date')::date, start_date),
    end_date = COALESCE((updated_values->>'end_date')::date, end_date),  
	modified_date = CURRENT_TIMESTAMP
  WHERE interview_id = interview_id_param;
  
  RETURN FOUND;
END;
$plpgsql$;

--
-- Create view "client"."vw_model_client_lookup"
--
CREATE VIEW client.vw_model_client_lookup
AS
	SELECT p.name_ AS project_name,
    d.title_ AS model_title,
    mr.name_ AS model_role,
    bf.name_ AS model_business_function,
    mi.description_ AS model_industry,
    cr.description_ AS client_role_description,
    bu.name_ AS client_business_unit,
    s.name_ AS client_subsidiary,
    pa.name_ AS client_parent,
    ci.description_ AS client_subsidiary_industry,
    cip.description_ AS client_parent_industry,
    i.interview_id,
    i.project_id,
    i.model_id,
    cr.role_id AS client_role_id,
    bu.unit_id AS business_unit_id,
    s.subsidiary_id,
    pa.parent_id
   FROM client.interview i
     LEFT JOIN admin.project p ON i.project_id = p.project_id
     LEFT JOIN model.discovery d ON i.model_id = d.model_id
     LEFT JOIN model.role mr ON d.role_id = mr.role_id
     LEFT JOIN model.business_function bf ON d.function_id = bf.function_id
     LEFT JOIN reference.industry mi ON d.industry_hash_id::text = mi.industry_hash_id::text
     LEFT JOIN client.role cr ON i.role_id = cr.role_id
     LEFT JOIN client.business_unit bu ON cr.unit_id = bu.unit_id
     LEFT JOIN client.subsidiary s ON bu.subsidiary_id = s.subsidiary_id
     LEFT JOIN client.parent pa ON s.parent_id = pa.parent_id
     LEFT JOIN reference.industry ci ON s.industry_hash_id::text = ci.industry_hash_id::text
     LEFT JOIN reference.industry cip ON pa.industry_hash_id::text = cip.industry_hash_id::text;

--
-- Create view "client"."vw_contact_interview_lookup"
--
CREATE VIEW client.vw_contact_interview_lookup
AS
	SELECT r.respondent_id,
    r.email_,
    r.first_name,
    r.last_name,
    r.title_,
    r.phone_,
    r.location_reference,
    ro.description_ AS role_description,
    p.name_ AS project_name,
    i.project_id,
    i.interview_id,
    i.title_ AS interview_title,
    i.request_date,
    i.approval_date,
    i.start_date,
    i.end_date,
    i.source_ AS interview_source,
    i.frequency_ AS interview_frequency
   FROM interview.respondent r
     LEFT JOIN client.role ro ON r.role_id = ro.role_id
     LEFT JOIN client.interview i ON ro.role_id = i.role_id
     LEFT JOIN admin.project p ON i.project_id = p.project_id
  ORDER BY r.email_, i.start_date DESC;

--
-- Create view "interview"."vw_question_lookup"
--
CREATE VIEW interview.vw_question_lookup
AS
	SELECT ir.email_,
    ci.interview_id,
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

--
-- Create procedure "interview"."up_insert_answer"
--
CREATE PROCEDURE interview.up_insert_answer (IN in_question_id uuid, IN in_respondent_id uuid, IN in_answer jsonb, IN in_answer_date timestamp with time zone, IN in_source character varying)
LANGUAGE plpgsql
SECURITY INVOKER
AS $plpgsql$
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
$plpgsql$;

--
-- Create view "interview"."vw_answer_in_progress_lookup"
--
CREATE VIEW interview.vw_answer_in_progress_lookup
AS
	SELECT q.question_id,
    q.syntax_,
    q.topic_,
    q.subtopic_,
    q.weight_,
    q.sort_order,
    a.progress_id,
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
   FROM interview.question q
     JOIN interview.answer_in_progress a ON q.question_id = a.question_id
     JOIN client.interview i ON q.interview_id = i.interview_id
     JOIN model.discovery d ON i.model_id = d.model_id
     JOIN model.role r ON d.role_id = r.role_id
     JOIN model.business_function bf ON d.function_id = bf.function_id
     JOIN reference.industry ind ON d.industry_hash_id::text = ind.industry_hash_id::text;

--
-- Create procedure "model"."up_delete_model"
--
CREATE PROCEDURE model.up_delete_model ()
LANGUAGE plpgsql
SECURITY INVOKER
AS $plpgsql$

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
    
END;
$plpgsql$;

--
-- Create procedure "interview"."up_insert_answer_from_progress"
--
CREATE PROCEDURE interview.up_insert_answer_from_progress ()
LANGUAGE plpgsql
SECURITY INVOKER
AS $plpgsql$
DECLARE
    inserted_count INTEGER;
    updated_count INTEGER;
BEGIN
    -- Use Common Table Expressions (CTEs) to handle the entire operation
    WITH latest_answers AS (
        -- Get the most recent answer for each question_id
        SELECT DISTINCT ON (question_id)
            question_id,
            respondent_id,
            answer_,
            answer_date,
            note_,
            score_,
            location_reference
        FROM
            interview.answer_in_progress
        ORDER BY
            question_id,
            answer_date DESC
    ),
    -- Identify records that need updating (question exists but has an older date)
    updates AS (
        UPDATE interview.answer a
        SET
            respondent_id = la.respondent_id,
            answer_ = la.answer_,
            answer_date = la.answer_date,
            note_ = la.note_,
            score_ = la.score_,
            location_reference = la.location_reference
        FROM
            latest_answers la
        WHERE
            a.question_id = la.question_id
            AND a.answer_date < la.answer_date
        RETURNING a.question_id
    ),
    -- Insert new answers (question_id doesn't exist in answer table)
    inserts AS (
        INSERT INTO interview.answer (
            question_id,
            respondent_id,
            answer_,
            answer_date,
            note_,
            score_,
            location_reference
        )
        SELECT
            la.question_id,
            la.respondent_id,
            la.answer_,
            la.answer_date,
            la.note_,
            la.score_,
            la.location_reference
        FROM
            latest_answers la
        LEFT JOIN
            interview.answer a ON la.question_id = a.question_id
        WHERE
            a.question_id IS NULL
        RETURNING question_id
    )
    -- Get counts for reporting
    SELECT 
        (SELECT COUNT(*) FROM updates),
        (SELECT COUNT(*) FROM inserts)
    INTO 
        updated_count, inserted_count;

    RAISE NOTICE 'Updated % existing answers and inserted % new answers', 
        updated_count, inserted_count;
    
    COMMIT;
END;
$plpgsql$;

--
-- Create view "interview"."vw_interview_status"
--
CREATE VIEW interview.vw_interview_status
AS
	SELECT i.interview_id,
        CASE
            WHEN (EXISTS ( SELECT 1
               FROM interview.answer a
                 JOIN interview.question q ON a.question_id = q.question_id
              WHERE q.interview_id = i.interview_id)) THEN 'Completed'::text
            WHEN (EXISTS ( SELECT 1
               FROM interview.answer_in_progress aip
                 JOIN interview.question q ON aip.question_id = q.question_id
              WHERE q.interview_id = i.interview_id)) THEN 'In Progress'::text
            ELSE 'New'::text
        END AS status
   FROM client.interview i;

--
-- Create view "interview"."vw_answer_lookup"
--
CREATE VIEW interview.vw_answer_lookup
AS
	SELECT q.question_id,
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
   FROM interview.question q
     JOIN interview.answer a ON q.question_id = a.question_id
     JOIN client.interview i ON q.interview_id = i.interview_id
     JOIN model.discovery d ON i.model_id = d.model_id
     JOIN model.role r ON d.role_id = r.role_id
     JOIN model.business_function bf ON d.function_id = bf.function_id
     JOIN reference.industry ind ON d.industry_hash_id::text = ind.industry_hash_id::text;

--
-- Create foreign key
--
ALTER TABLE interview.followup_answer 
  ADD FOREIGN KEY (question_id)
    REFERENCES interview.followup_question_by_topic(question_id) ON DELETE NO ACTION ON UPDATE NO ACTION INITIALLY IMMEDIATE;

--
-- Create procedure "stage"."up_insert_question"
--
CREATE PROCEDURE stage.up_insert_question (IN p_industry_hash_id character varying, IN p_business_function character varying, IN p_role character varying, IN p_model_topic character varying, IN p_topic character varying, IN p_subtopic character varying, IN p_syntax jsonb, IN p_help_text jsonb, IN p_help_list jsonb, IN p_response_type character varying, IN p_sort_order smallint, IN p_create_date date, IN p_source character varying, IN p_gui_type character varying)
LANGUAGE plpgsql
SECURITY INVOKER
AS $plpgsql$
BEGIN
    -- Insert logic for the question
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
        source_,
        gui_type
    ) VALUES (
        p_industry_hash_id,
        p_business_function,
        p_role,
        p_model_topic,
        p_topic,
        p_subtopic,
        p_syntax,
        p_help_text,
        p_help_list,
        p_response_type,
        p_sort_order,
        p_create_date,
        p_source,
        p_gui_type
    );
END;
$plpgsql$;

--
-- Drop foreign key
--
ALTER TABLE stage.model 
   DROP CONSTRAINT fk_32_4;

--
-- Create procedure "model"."up_insert_model"
--
CREATE PROCEDURE model.up_insert_model (IN p_industry_hash_id character varying, IN p_business_function character varying, IN p_role character varying)
LANGUAGE plpgsql
SECURITY INVOKER
AS $plpgsql$
BEGIN
	--add author to model.author if not exists
    INSERT INTO model.author (
        author_id, name_, email_, start_date, end_date, 
        create_date, modified_date, source_
    )
	SELECT aa.author_id, aa.name_, aa.email_, aa.start_date, aa.end_date, aa.create_date, aa.modified_date, aa.source_
	FROM admin.author aa LEFT OUTER JOIN model.author ma on
	aa.author_id = ma.author_id WHERE ma.author_id is NULL;

    -- Insert roles
	INSERT INTO model.role(name_, description_, source_, created_by)    
	SELECT DISTINCT ON (c.rag_role) c.rag_role, c.rag_role_rationale, c.rag_role_source, c.rag_role_created_by 
	FROM stage.contact c
	INNER JOIN stage.business_unit bu ON bu.name_ = c.business_unit 
	INNER JOIN stage.subsidiary s ON s.name_ = c.subsidiary_
	LEFT OUTER JOIN model.role r ON r.name_ = c.rag_role
	WHERE r.name_ IS NULL;
	
	-- Modified INSERT for model.business_function using LEFT OUTER JOIN approach
	INSERT INTO model.business_function(name_, description_, source_, created_by)    
	SELECT DISTINCT ON (bu.name_) bu.name_, rag_business_function, rag_function_source, rag_function_created_by 
	FROM stage.business_unit bu
	INNER JOIN stage.model m ON m.business_function = bu.name_
	INNER JOIN stage.subsidiary s ON m.industry_hash_id = s.industry_hash_id
	LEFT OUTER JOIN model.business_function bf ON bf.name_ = bu.name_
	WHERE bf.name_ IS NULL;

    -- Insert discovery records
    INSERT INTO model.discovery (
        industry_hash_id, function_id, role_id, author_id, 
        title_, model_topic, start_date, project_id, source_
    )
    SELECT
        s.industry_hash_id,
        bf.function_id,
        r.role_id,
        s.author_id,
        'Model Test',
        'Model Topic Test',
        CURRENT_DATE,
        s.project_id,
        'kds_discovery hybrid LLM'
    FROM stage.model s
    INNER JOIN model.business_function bf ON s.business_function = bf.name_
    INNER JOIN model.role r ON s.role_ = r.name_;

	 INSERT INTO model.question (
        question_id, model_id, author_id, syntax_, help_text, 
        help_list, gui_type, sort_order, location_reference, 
        topic_, subtopic_, create_date, source_
    )
    SELECT
        s.question_id,
        d.model_id,
        sm.author_id, -- Using author_id from stage.model instead of hardcoded value
        s.syntax_,
        s.help_text,
        s.help_list,
        s.gui_type,
        s.sort_order,
        s.location_reference,
        s.topic_,
        s.subtopic_,
        CURRENT_DATE,
        'kds_discovery hybrid LLM'
    FROM stage.model_question s
    INNER JOIN stage.model sm ON sm.industry_hash_id = s.industry_hash_id
                              AND sm.business_function = s.business_function
                              AND sm.role_ = s.role_
    INNER JOIN model.business_function bf ON bf.name_ = p_business_function
    INNER JOIN model.role r ON r.name_ = p_role
    INNER JOIN model.discovery d ON bf.function_id = d.function_id 
                                AND r.role_id = d.role_id 
                                AND d.industry_hash_id = p_industry_hash_id
    WHERE s.industry_hash_id = p_industry_hash_id;
     
 	-- Insert parent organization -- only one per database please 20250402
	INSERT INTO client.parent (
	    name_, organization_type, stock_symbol, industry_hash_id, 
	    product_service, annual_revenue, employee_total, website_, 
	    location_, source_, created_by, modified_date, modified_by, 
	    create_date
	)
	SELECT 
	    sp.name_, sp.organization_type, sp.stock_symbol, sp.industry_hash_id, 
	    sp.product_service, sp.annual_revenue, sp.employee_total, sp.website_, 
	    sp.location_, sp.source_, sp.created_by, sp.modified_date, sp.modified_by, 
	    CURRENT_DATE
	FROM stage.parent sp
	LEFT OUTER JOIN client.parent cp ON 1=1  -- Join condition that always evaluates to true
	WHERE cp.name_ IS NULL  -- Only insert if no records exist in client.parent
	LIMIT 1;  -- Still maintain the limit of 1 record

	-- INSERT for client.subsidiary with uniqueness check using LEFT OUTER JOIN
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
	INNER JOIN client.parent p ON s.parent_name = p.name_
	LEFT OUTER JOIN client.subsidiary cs ON cs.name_ = s.name_
	WHERE cs.name_ IS NULL;
	
	-- INSERT for client.business_unit with uniqueness check using LEFT OUTER JOIN
	INSERT INTO client.business_unit (
	    parent_id, subsidiary_id, name_, create_date, created_by, 
	    modified_date, modified_by, source_
	)
	SELECT 
	    p.parent_id, sd.subsidiary_id, s.name_, CURRENT_DATE, 
	    s.created_by, s.modified_date, s.modified_by, s.source_
	FROM stage.business_unit s 
	INNER JOIN client.parent p ON s.parent_ = p.name_ 
	INNER JOIN client.subsidiary sd ON s.subsidiary_ = sd.name_
	LEFT OUTER JOIN client.business_unit cbu ON cbu.name_ = s.name_
	WHERE cbu.name_ IS NULL;
		
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


		INSERT INTO interview.author (author_id, name_, email_, start_date, end_date, 
        create_date, modified_date, source_ )
		SELECT aa.author_id, aa.name_, aa.email_, aa.start_date, aa.end_date, aa.create_date, aa.modified_date, aa.source_
		FROM admin.author aa LEFT OUTER JOIN interview.author ma on
		aa.author_id = ma.author_id WHERE ma.author_id is NULL;


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
		m.project_id
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
$plpgsql$;

--
-- Create view "stage"."vw_contact_question_prompt"
--
CREATE VIEW stage.vw_contact_question_prompt
AS
	WITH subsidiary_lookup AS (
         SELECT stage.name_ AS stage_name,
            client.subsidiary_id AS client_subsidiary_id,
            client.name_ AS client_name,
            stage.industry_hash_id,
            stage.rag_industry_code,
            stage.rag_industry_description
           FROM stage.subsidiary stage
             LEFT JOIN client.subsidiary client ON stage.name_::text = client.name_::text
        ), business_unit_lookup AS (
         SELECT stage.name_ AS stage_name,
            stage.parent_ AS stage_parent,
            stage.subsidiary_ AS stage_subsidiary,
            client.unit_id AS client_unit_id,
            client.name_ AS client_name,
            client.parent_id AS client_parent_id
           FROM stage.business_unit stage
             LEFT JOIN client.business_unit client ON stage.name_::text = client.name_::text
        )
 SELECT row_number() OVER (ORDER BY contact.rag_role, contact.business_unit) AS row_number,
    sul.industry_hash_id,
    bul.client_unit_id,
    contact.business_unit AS business_function,
    contact.rag_role,
    aps.response_count,
    sul.rag_industry_code,
    sul.rag_industry_description
   FROM stage.contact contact
     LEFT JOIN subsidiary_lookup sul ON contact.subsidiary_::text = sul.stage_name::text
     LEFT JOIN business_unit_lookup bul ON contact.business_unit::text = bul.stage_name::text
     CROSS JOIN admin.prompt_setting aps
  WHERE aps.name_::text = 'primary interview question'::text;

--
-- Create procedure "stage"."up_insert_model"
--
CREATE PROCEDURE stage.up_insert_model (IN p_industry_code_source character varying, IN p_model_name character varying, IN p_project_id uuid, IN p_frequency character varying, IN p_response_count integer, IN p_author_id uuid)
LANGUAGE plpgsql
SECURITY INVOKER
AS $plpgsql$

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
        project_id,
        response_count,
		frequency_,
		author_id
    )
    SELECT 
        industry_hash_id,
       business_function, -- using business_unit instead of 
        rag_role,
     	p_model_name,
        CURRENT_DATE AS create_date,
        USER AS created_by,
        'vw_contact_question_prompt' AS source_,
        p_project_id,
        p_response_count,
		p_frequency,
		p_author_id
    FROM stage.vw_contact_question_prompt
    GROUP BY 
        industry_hash_id,
        business_function,
        rag_role;
END;
$plpgsql$;

--
-- Create table "public"."v_author_id"
--
CREATE TABLE public.v_author_id(
  author_id uuid
);

--
-- Alter column "modified_date" on table "load"."model_question"
--
ALTER TABLE load.model_question 
  ALTER COLUMN modified_date TYPE timestamp with time zone;

--
-- Create procedure "temp"."up_insert_question"
--
CREATE PROCEDURE temp.up_insert_question (IN p_nasic_code character varying, IN p_business_unit character varying, IN p_role_ character varying, IN p_model_topic character varying, IN p_topic_ character varying, IN p_subtopic_ character varying, IN p_syntax_ jsonb, IN p_help_ jsonb, IN p_type_ character varying, IN p_sort_order smallint, IN p_create_date date, IN p_source_ character varying)
LANGUAGE plpgsql
SECURITY INVOKER
AS $plpgsql$
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
$plpgsql$;

--
-- Create view "temp"."vw_lookup_for_answer_test"
--
CREATE VIEW temp.vw_lookup_for_answer_test
AS
	SELECT ir.email_,
    ci.interview_id,
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
   FROM interview.respondent ir
     JOIN client.role cr ON ir.role_id = cr.role_id
     JOIN client.interview ci ON cr.role_id = ci.role_id
     JOIN interview.question iq ON iq.interview_id = ci.interview_id
     JOIN client.business_unit bu ON cr.unit_id = bu.unit_id
     JOIN client.subsidiary sy ON bu.subsidiary_id = sy.subsidiary_id
     JOIN reference.industry ri ON sy.industry_hash_id::text = ri.industry_hash_id::text
     LEFT JOIN interview.answer a ON iq.question_id = a.question_id AND ir.respondent_id = a.respondent_id
     LEFT JOIN interview.answer_in_progress aip ON iq.question_id = aip.question_id AND ir.respondent_id = aip.respondent_id
  WHERE a.answer_id IS NULL AND aip.progress_id IS NULL;

--
-- Create table "temp"."will_this_work"
--
CREATE TABLE temp.will_this_work(
  template_ text
);

--
-- Create table "temp"."project"
--
CREATE TABLE temp.project(
  project_id uuid
);

--
-- Create table "temp"."contact"
--
CREATE TABLE temp.contact(
  email_ character varying(128),
  parent_ character varying(96),
  subsidiary_ character varying(96),
  business_unit character varying(96),
  title_ character varying(128),
  respondent_ character varying(12),
  first_name character varying(48),
  last_name character varying(32),
  location_reference character varying(96),
  phone_ character varying(16),
  create_date timestamp with time zone,
  created_by character varying(92),
  job_description text,
  modified_date timestamp with time zone,
  modified_by character varying(92),
  source_ character varying(92),
  rag_role character varying(64),
  rag_role_rationale character varying(512),
  rag_role_source character varying(96),
  rag_role_create_date date,
  rag_role_created_by character varying(96),
  system_admin character varying(12)
);

--
-- Create table "temp"."author"
--
CREATE TABLE temp.author(
  author_id uuid
);

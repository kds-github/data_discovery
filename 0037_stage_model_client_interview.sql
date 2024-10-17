--stage model has been deleted so

INSERT INTO stage.model (nasic_code, biz_unit, role_, create_date, created_by, modified_date, modified_by, source_, name_)
SELECT nasic_code, biz_unit, role_, create_date, created_by, modified_date, modified_by,  'kds_discovery LLM hybrid', 'model_name goes here'
FROM load.model;

--assign seprate model source_ for each model for each nasic_code, role_, biz_unit
UPDATE stage.model SET source_ = 'kds_discovery hybrid LLM',name_ = 'model_01' WHERE biz_unit = 'Sales and Marketing Unit';
UPDATE stage.model SET source_ = 'kds_discovery hybrid LLM',name_ = 'model_02' WHERE biz_unit = 'Customer Support and Service Unit';
UPDATE stage.model SET source_ = 'kds_discovery hybrid LLM',name_ = 'model_03' WHERE biz_unit = 'Finance and Accounting Unit';
UPDATE stage.model SET source_ = 'kds_discovery hybrid LLM',name_ = 'model_04' WHERE biz_unit = 'Supply Chain Management Unit';
UPDATE stage.model SET source_ = 'kds_discovery hybrid LLM',name_ = 'model_05' WHERE biz_unit = 'Packaging and Labeling Unit';
UPDATE stage.model SET source_ = 'kds_discovery hybrid LLM',name_ = 'model_06' WHERE biz_unit = 'Operations Unit';
UPDATE stage.model SET source_ = 'kds_discovery hybrid LLM',name_ = 'model_07' WHERE biz_unit = 'IT and Systems Unit';
UPDATE stage.model SET source_ = 'kds_discovery hybrid LLM',name_ = 'model_08' WHERE biz_unit = 'Human Resources Unit';
UPDATE stage.model SET source_ = 'kds_discovery hybrid LLM',name_ = 'model_09' WHERE biz_unit = 'Research and Development Unit';

--note will cast question syntax as JSON
INSERT INTO stage.model_question (  nasic_code, business_unit, role_, model_topic, topic_, subtopic_, syntax_, help_, type_, 
								  sort_order, location_reference, create_date, modified_date, source_)
SELECT
  nasic_code, business_unit, role_, model_topic, topic_, subtopic_,
  ('"' || syntax_ || '"')::jsonb, ('"' || help_ || '"')::jsonb, type_, sort_order, location_reference, create_date, modified_date, 'kds_discovery Hybrid LLM'
FROM load.model_question;

SELECT 'stage.model and stage.model_question inserted...' as 'status_';

ALTER TABLE stage.business_unit
ALTER COLUMN model_reference TYPE UUID
USING model_reference::UUID;

UPDATE stage.business_unit AS s
SET model_reference = m.unit_id
FROM model.business_unit AS m
WHERE s.name_ = m.name_;

-- Vary the name of "IT and Systems Unit"
UPDATE model.business_unit
SET name_ = 'IT & Systems Unit'
WHERE name_ = 'IT and Systems Unit';

-- Vary the name of "Operations Unit"
UPDATE model.business_unit
SET name_ = 'Operations and Logistics Unit'
WHERE name_ = 'Operations Unit';

-- Vary the name of "Customer Support and Service Unit"
UPDATE model.business_unit
SET name_ = 'Customer Service & Support Unit'
WHERE name_ = 'Customer Support and Service Unit';

-- Vary the name of "Research and Development Unit"
UPDATE model.business_unit
SET name_ = 'R&D Unit'
WHERE name_ = 'Research and Development Unit';

-- Vary the name of "Sales and Marketing Unit"
UPDATE model.business_unit
SET name_ = 'Sales & Marketing Unit'
WHERE name_ = 'Sales and Marketing Unit';

-- Vary the name of "Packaging and Labeling Unit"
UPDATE model.business_unit
SET name_ = 'Packaging & Labeling Unit'
WHERE name_ = 'Packaging and Labeling Unit';

-- Vary the name of "Supply Chain Management Unit"
UPDATE model.business_unit
SET name_ = 'Supply Chain Unit'
WHERE name_ = 'Supply Chain Management Unit';

-- Vary the name of "Finance and Accounting Unit"
UPDATE model.business_unit
SET name_ = 'Finance & Accounting Unit'
WHERE name_ = 'Finance and Accounting Unit';

-- Vary the name of "Human Resources Unit"
UPDATE model.business_unit
SET name_ = 'HR Unit'
WHERE name_ = 'Human Resources Unit';

UPDATE stage.model
SET biz_unit = 'IT & Systems Unit', role_ = 'IT Lead'
WHERE biz_unit = 'IT and Systems Unit';

UPDATE stage.model
SET biz_unit = 'Operations and Logistics Unit', role_ = 'Operations Lead'
WHERE biz_unit = 'Operations Unit';

UPDATE stage.model
SET biz_unit = 'Customer Service & Support Unit', role_ = 'Support Lead'
WHERE biz_unit = 'Customer Support and Service Unit';


UPDATE stage.model
SET biz_unit = 'R&D Unit', role_ = 'R&D Lead'
WHERE biz_unit = 'Research and Development Unit';


UPDATE stage.model
SET biz_unit = 'Sales & Marketing Unit', role_ = 'Sales Lead'
WHERE biz_unit = 'Sales and Marketing Unit';

UPDATE stage.model
SET biz_unit = 'Packaging & Labeling Unit', role_ = 'Packaging Lead'
WHERE biz_unit = 'Packaging and Labeling Unit';


UPDATE stage.model
SET biz_unit = 'Supply Chain Unit', role_ = 'Supply Chain Lead'
WHERE biz_unit = 'Supply Chain Management Unit';


UPDATE stage.model
SET biz_unit = 'Finance & Accounting Unit', role_ = 'Finance Lead'
WHERE biz_unit = 'Finance and Accounting Unit';


UPDATE stage.model
SET biz_unit = 'HR Unit', role_ = 'HR Lead'
WHERE biz_unit = 'Human Resources Unit';

UPDATE stage.model
SET biz_unit = 'Operations Unit', role_ = 'Operations Lead'
WHERE biz_unit = 'Operations and Logistics Unit';


UPDATE stage.model_question SET business_unit = 'Sales & Marketing Unit', role_ = 'Sales Lead'
WHERE business_unit = 'Sales and Marketing Unit';


--client and interview re-do
DELETE FROM interview.question;
DELETE FROM interview.respondent;
DELETE FROM interview.author;
DELETE FROM client.interview;
DELETE FROM client.role;
DELETE FROM client.business_unit;
DELETE FROM client.subsidiary;
DELETE FROM client.parent;

--model schema redo
DELETE FROM model.question; 
DELETE FROM model.discovery;
DELETE FROM model.industry;
DELETE FROM model.author;
DELETE FROM model.business_unit;
DELETE FROM model.role;

--will insert role for Sales Marketing Unit
INSERT INTO model.role (name_, created_by, source_)	
SELECT role_, 'sys admin','kds_discovery LLM hybrid' 
	FROM stage.model WHERE biz_unit = 'Sales & Marketing Unit' GROUP BY role_;
	

INSERT INTO model.business_unit (name_, created_by, source_)	
SELECT biz_unit, 'sys admin', 'kds_discovery hybrid LLM' FROM stage.model
GROUP BY biz_unit;

INSERT INTO model.author (
  author_id,
  author_name,
  email_,
  start_date,
  end_date,
  create_date,
  modified_date,
  hash_value,
  source_
)
VALUES (
  -- Replace with actual data values here
  gen_random_uuid(), -- Generate a random UUID
  'kds discovery author',
  'kds@kds_discovery.com',
  CURRENT_DATE, -- Replace with a valid date
  NULL, 
  CURRENT_DATE, -- Insert current date
  NULL, 
  NULL,
  'kds_discovery'
);

INSERT into model.industry
SELECT * FROM stage.industry;

INSERT INTO model.discovery (nasic_code, unit_id, role_id, author_id, title_, model_topic, start_date, source_ )
SELECT
  s.nasic_code,
  bu.unit_id,
  r.role_id,
  (SELECT author_id FROM model.author WHERE author_name = 'kds discovery author') AS author_id, -- Subquery
  'Model Test',
  'Model Topic Test',
  CURRENT_DATE,
  'kds_discovery hybrid LLM'
FROM
  stage.model s
INNER JOIN model.business_unit bu ON s.biz_unit = bu.name_
INNER JOIN model.role r ON s.role_ = r.name_ ;

INSERT INTO model.question (question_id, model_id, author_id, syntax_, help_, sort_order, location_reference, topic_, subtopic_, create_date, source_)
SELECT
  s.question_id,
  d.model_id,
   (SELECT author_id FROM model.author WHERE author_name = 'kds discovery author') AS author_id, -- Subquery
  syntax_,
  help_,
  sort_order,
  location_reference,
  s.topic_,
  s.subtopic_,
  CURRENT_DATE,
  'kds_discovery hybrid LLM'
FROM
  stage.model_question s
INNER JOIN model.industry mi ON s.nasic_code = mi.nasic_code
INNER JOIN model.business_unit bu ON s.business_unit = bu.name_
INNER JOIN model.role r ON s.role_ = r.name_
INNER JOIN model.discovery d ON mi.nasic_code = d.nasic_code AND bu.unit_id = d.unit_id AND
r.role_id = d.role_id;





--client. load
INSERT INTO client.parent (name_, organization_type, ticker_, nasic_code, product_service, annual_revenue, employee_total, website_, location_, source_, 
						   created_by, modified_date, modified_by,create_date )
SELECT name_, organization_type, ticker_, nasic_code, product_service, annual_revenue, employee_total, website_, location_, source_, 
created_by, modified_date, modified_by, CURRENT_DATE
	FROM stage.parent;


INSERT INTO client.subsidiary (organization_type, parent_id, name_, ticker_, nasic_code, product_service, 
annual_revenue, employee_total, website_, location_reference, source_, create_date, created_by, modified_date, modified_by	)
SELECT  s.organization_type, p.parent_id, s.name_, s.ticker_, s.nasic_code, s.product_service, s.annual_revenue, s.employee_total, 
s.website_, s.location_, s.source_, CURRENT_DATE, s.created_by, s.modified_date, 
s.modified_by
	FROM stage.subsidiary s INNER JOIN client.parent p ON
	s.parent_name = p.name_;

INSERT INTO client.business_unit (parent_id, subsidiary_id, name_, create_date, created_by, modified_date, modified_by, source_)
SELECT p.parent_id, sd.subsidiary_id, s.name_, CURRENT_DATE, s.created_by, s.modified_date, s.modified_by, s.source_
	FROM stage.business_unit s INNER JOIN client.parent p ON
	s.parent_ = p.name_ INNER JOIN client.subsidiary sd ON
	s.subsidiary_ = sd.name_;

INSERT INTO client.role (description_, respondent_, project_sponsor, location_reference, unit_id, create_date, source_)
SELECT c.role_,  c.respondent_, c.project_sponsor, c.location_reference, c.unit_id, current_date, 'kds_discovery_user'
FROM (
  SELECT DISTINCT ON (role_, business_unit, subsidiary_, parent_)
         c.role_,
         c.respondent_,
         c.project_sponsor,
         c.location_reference,
		 bu.unit_id
  FROM stage.contact c
  LEFT JOIN client.business_unit bu ON bu.name_ = c.business_unit
  --LEFT JOIN client.subsidiary sub ON sub.name_ = COALESCE(c.subsidiary_, '')  -- Handle empty subsidiary_
  LEFT JOIN client.subsidiary sub ON sub.name_ = c.subsidiary_  
  LEFT JOIN client.parent p ON p.name_ = c.parent_
  WHERE bu.unit_id IS NOT NULL
  AND sub.subsidiary_id IS NOT NULL  -- Assuming subsidiary id check is still needed
  AND p.parent_id IS NOT NULL
) AS c;

SELECT 'schema client loaded...' as status_;

INSERT INTO interview.author (author_name, email_, start_date, create_date, source_) 
SELECT author_name, email_, CURRENT_DATE, CURRENT_DATE, 'kds_discovery_admin'
FROM model.author;

INSERT INTO interview.respondent (email_, role_id, description_, respondent_, project_sponsor, location_reference, first_name, last_name, title_, 
phone_, create_date, source_)
SELECT c.email_, c.role_id, c.role_,  c.respondent_, c.project_sponsor, c.location_reference, c.first_name, c.last_name, c.title_, c.phone_,  CURRENT_DATE, 'kds_discovery_user'
FROM (
  SELECT DISTINCT ON (email_, role_, business_unit, subsidiary_, parent_)
	c.email_,     
    cr.role_id, 
	c.role_,
    c.respondent_,
    c.project_sponsor,
    c.location_reference,
	c.first_name, 
	c.last_name, 
	c.title_, 
	c.phone_
  FROM stage.contact c
  LEFT JOIN client.role cr ON cr.description_ = c.role_		
  LEFT JOIN client.business_unit bu ON bu.name_ = c.business_unit
  LEFT JOIN client.subsidiary sub ON sub.name_ = COALESCE(c.subsidiary_, '')  -- Handle empty subsidiary_
  LEFT JOIN client.parent p ON p.name_ = c.parent_

  WHERE bu.unit_id IS NOT NULL
  --AND sub.subsidiary_id IS NOT NULL  -- Assuming subsidiary id check is still needed
  AND p.parent_id IS NOT NULL
) AS c;


INSERT INTO interview.question (
  model_question_id, syntax_, help_, sort_order, create_date, modified_date, disable_, topic_, subtopic_, weight_, author_id, source_
)
SELECT mq.question_id, mq.syntax_, mq.help_, mq.sort_order, mq.create_date, mq.modified_date, mq.disable_, mq.topic_, mq.subtopic_, 
mq.weight_, ia.author_id, 'kds_discovery_admin' --interview author ID
FROM model.question as mq
LEFT JOIN interview.author ia on ia.author_name = 'kds discovery author';

--get client roles

ALTER TABLE stage.contact ADD COLUMN model_reference UUID NULL;

--update to emulate mapping of client - business unit for matching to model data
UPDATE stage.contact sc
SET model_reference = (
    SELECT md.role_id
    FROM model.discovery md
    LIMIT 1
)
WHERE sc.email_ = 'danielle.lee@globallogistics.com';

UPDATE stage.business_unit bu
SET model_reference = (
    SELECT md.unit_id
    FROM model.discovery md
    LIMIT 1
)
WHERE bu.name_ = 'Sales and Marketing Unit';

--finally
INSERT INTO client.interview (
    role_id,
    model_id,
    frequency_,
    source_,
    create_date
)
SELECT 
    cr.role_id,
    md.model_id,
    'one-time' AS frequency_,
    'system' AS source_,
    CURRENT_DATE AS create_date
FROM interview.respondent ir
JOIN client.role cr ON cr.role_id = ir.role_id
JOIN stage.contact sc ON ir.email_ = sc.email_
JOIN model.discovery md ON sc.model_reference = md.role_id
JOIN stage.business_unit sbu ON sbu.model_reference = md.unit_id;
--adding source_ column
ALTER TABLE load.industry ADD COLUMN source_  varchar(96) NULL;
ALTER TABLE stage.industry ADD COLUMN source_  varchar(96) NOT NULL;
ALTER TABLE stage.contact ADD COLUMN source_ VARCHAR(96) NOT NULL ;  --fixes not null on initial load 20240923
ALTER TABLE stage.model ADD COLUMN name_ VARCHAR(64) NOT NULL;  
ALTER TABLE model.role ADD COLUMN source_ VARCHAR(96) NOT NULL;  
ALTER TABLE model.discovery ADD COLUMN source_ VARCHAR(96) NOT NULL;  
ALTER TABLE model.question ADD COLUMN source_ VARCHAR(96) NOT NULL;  
ALTER TABLE model.author ADD COLUMN source_ VARCHAR(96) NOT NULL;  
ALTER TABLE model.industry ADD COLUMN source_ VARCHAR(96) NOT NULL;
ALTER TABLE stage.business_unit ALTER COLUMN hash_key DROP NOT NULL;  --fixes not null on initial load 20240923


INSERT INTO stage.industry (nasic_code, description_, source_)
SELECT nasic_code, description_, 'kds_discovery NASIC six-digit'
FROM load.industry;

INSERT INTO stage.parent 
SELECT name_, organization_type, ticker_, nasic_code, product_service, annual_revenue, 
employee_total, website_, location_, source_, create_date, created_by, modified_date, modified_by
	FROM load.parent;
	
INSERT INTO stage.subsidiary (parent_name, name_, organization_type, ticker_, nasic_code, product_service, 
							  annual_revenue, employee_total, website_, location_, source_, create_date, 
							  created_by, modified_date, modified_by
) SELECT parent_, name_, organization_type, ticker_, nasic_code, product_service, annual_revenue, employee_total, 
website_, location_, source_, create_date, created_by, modified_date, modified_by
	FROM load.subsidiary;


INSERT INTO stage.business_unit
SELECT name_, parent_, subsidiary_, create_date, created_by, modified_date, modified_by, source_
	FROM load.business_unit;

INSERT INTO stage.contact (email_, parent_, business_unit, subsidiary_, title_, role_, respondent_, project_sponsor, first_name, last_name, 
location_reference, phone_, create_date, created_by, modified_date, modified_by, source_)
SELECT email_, parent_, business_unit, subsidiary_, title_, role_, respondent_, project_sponsor, first_name, last_name, 
location_, phone_, create_date, created_by, modified_date, modified_by, 'kds_discovery LLM hybrid'
	FROM load.contact;

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

SELECT 'schema stage loaded...' as status_ ;

--will insert role for Sales Marketing Unit
INSERT INTO model.role (name_, created_by, source_)	
SELECT role_, 'sys admin','kds_discovery LLM hybrid' 
	FROM stage.model WHERE biz_unit = 'Sales and Marketing Unit' GROUP BY role_;

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

SELECT  'schema model loaded...'  as status_;

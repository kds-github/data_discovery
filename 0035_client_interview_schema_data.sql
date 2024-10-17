ALTER TABLE client.role ADD COLUMN source_ VARCHAR(96) NOT NULL;  
ALTER TABLE client.interview ADD COLUMN source_ VARCHAR(96) NOT NULL;  
ALTER TABLE interview.question ADD COLUMN source_ VARCHAR(96) NOT NULL;  
ALTER TABLE interview.author ADD COLUMN source_ VARCHAR(96) NOT NULL;  
ALTER TABLE interview.respondent ADD COLUMN source_ VARCHAR(96) NOT NULL;

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

INSERT INTO client.role (description_, respondent_, project_sponsor, location_reference, unit_id, create_date)
SELECT c.role_,  c.respondent_, c.project_sponsor, c.location_reference, c.unit_id, current_date
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

SELECT 'schema interview loaded...done' as status_;


CREATE TABLE admin.prompt_type
(
 prompt_ varchar(48) NOT NULL,
 CONSTRAINT PK_39 PRIMARY KEY ( prompt_ )
);


CREATE TABLE admin.gui_type
(
 gui_ varchar(48) NOT NULL,
 CONSTRAINT PK_39_1 PRIMARY KEY ( gui_ )
);


ALTER TABLE stage.model_question ADD COLUMN gui_type VARCHAR(48) NULL;
ALTER TABLE model.question ADD COLUMN gui_type VARCHAR(48) NULL;
ALTER TABLE interview.question ADD COLUMN gui_type VARCHAR(48) NULL;
ALTER TABLE model.question ADD COLUMN type_ VARCHAR(48) NULL;
ALTER TABLE interview.question ADD COLUMN type_ VARCHAR(48) NULL;

-- 1. Dropdown with multiple select
UPDATE interview.question
SET type_ = 'dropdown with multiple select'
WHERE syntax_ =  '"What are the primary data sources you rely on to perform your job in the Sales and Marketing Unit?"';

-- 2. Dropdown with multiple select
UPDATE interview.question
SET type_ = 'dropdown with multiple select'
WHERE syntax_ =  '"Where does the majority of your sales and marketing data originate from (e.g., CRM systems, third-party data, market reports)?"';

-- 3. Textarea
UPDATE interview.question
SET type_ = 'textarea'
WHERE syntax_ =  '"How do you verify the quality and accuracy of the data you work with?"';

-- 4. Dropdown with multiple select
UPDATE interview.question
SET type_ = 'dropdown with multiple select'
WHERE syntax_ =  '"What tools or platforms do you use to acquire or access your sales and marketing data (e.g., CRM, ERP, data lakes)?"';

-- 5. Textarea
UPDATE interview.question
SET type_ = 'textarea'
WHERE syntax_ =  '"How user-friendly are the tools you use to collect and manage your data? Are there any limitations?"';

-- 6. Textarea
UPDATE interview.question
SET type_ = 'textarea'
WHERE syntax_ = '"How is the sales and marketing data you gather used in decision-making within your unit?"';

-- 7. Textarea
UPDATE interview.question
SET type_ = 'textarea'
WHERE syntax_ = '"Can you describe a recent example where the data played a crucial role in shaping a sales or marketing strategy?"';

-- 8. Checkboxes
UPDATE interview.question
SET type_ = 'checkboxes'
WHERE syntax_ = '"Are there specific KPIs or metrics that are essential to track from your data sources?"';

-- 9. Radio buttons with textarea
UPDATE interview.question
SET type_ = 'radio buttons with textarea'
WHERE syntax_ = '"How frequently do you receive new data or update your existing datasets (e.g., daily, weekly, real-time)?"';

-- 10. Number with textarea
UPDATE interview.question
SET type_ = 'number with textarea'
WHERE syntax_ = '"On average, how much data do you work with daily or weekly? Is it growing, and if so, by how much?"';

-- 11. Textarea
UPDATE interview.question
SET type_ = 'textarea'
WHERE syntax_ = '"Does your team integrate sales and marketing data with data from other departments like operations, finance, or supply chain? If yes, how?"';


UPDATE interview.question
SET type_ = 'textarea'
WHERE type_ = '1';

--3
UPDATE interview.question
SET help_ = '{"help_list": ["Foo", "Foo", "SAP", "Oracle", "Other"], "help_text": "Please select all applicable software solutions."}'
WHERE syntax_ =  '"How do you verify the quality and accuracy of the data you work with?"';

UPDATE interview.question
SET help_ = '{"help_list": ["Salesforce", "Excel", "SAP", "Oracle", "Other"], "help_text": "Please select all applicable software solutions."}'
WHERE syntax_ = '"What are the primary data sources you rely on to perform your job in the Sales and Marketing Unit?"';

UPDATE interview.question
SET help_ = '{"help_list": ["CRM Systems", "Third-party Data", "Market Reports", "Internal Databases", "Other"], "help_text": "Please select the main source of your sales and marketing data."}'
WHERE syntax_ = '"Where does the majority of your sales and marketing data originate from (e.g., CRM systems, third-party data, market reports)?"';

UPDATE interview.question
SET help_ = '{"help_list": ["Revenue", "Conversion Rate", "Customer Acquisition Cost", "Lead Volume", "Other"], "help_text": "Select the key KPIs you track from your data sources."}'
WHERE syntax_ = '"Are there specific KPIs or metrics that are essential to track from your data sources?"';

UPDATE interview.question
SET help_ = '{"help_list": ["Daily", "Weekly", "Monthly", "Real-time", "Other"], "help_text": "Please select the frequency of your data updates."}'
WHERE syntax_ = '"How frequently do you receive new data or update your existing datasets (e.g., daily, weekly, real-time)?"';

UPDATE interview.question
SET help_ = '{"help_list": null, "help_text": "Provide an estimate of the data volume you handle regularly and its growth."}'
WHERE syntax_ = '"On average, how much data do you work with daily or weekly? Is it growing, and if so, by how much?"';

UPDATE interview.question SET gui_type = type_;

SELECT 'interview.question updates done...' AS status_;

--run from psql command line on linux
--\copy admin.gui_type FROM '/home/kds/data_discovery/gui_type.txt' CSV HEADER;
--\copy admin.prompt_type FROM '/home/kds/data_discovery/question_type.txt' CSV HEADER;

UPDATE interview.question set gui_type = 'dropdown custom' 
WHERE gui_type = 'dropdown with multiple select' and sort_order < 3;

UPDATE interview.question set gui_type = 'textarea' 
WHERE sort_order = 4;

UPDATE interview.question set gui_type = 'textarea' 
WHERE gui_type is NULL;

UPDATE interview.question set gui_type = 'checkbox' 
WHERE gui_type ='checkboxes';

UPDATE interview.question set gui_type = 'radio textarea' 
WHERE gui_type = 'radio buttons with textarea';

UPDATE interview.question set type_ = gui_type;

SELECT 'interview gui types updated' AS status_;

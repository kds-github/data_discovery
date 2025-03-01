CREATE SCHEMA admin;

CREATE SCHEMA analysis;

CREATE SCHEMA client;

CREATE SCHEMA interview;

CREATE SCHEMA load;

CREATE SCHEMA model;

CREATE SCHEMA reference;

CREATE SCHEMA stage;

CREATE SCHEMA temp;

CREATE TABLE admin.account (
  name_ character varying(72) PRIMARY KEY NOT NULL,
  email_ character varying(72) NOT NULL,
  air_ character varying(32) NOT NULL,
  login_id character varying(72) NOT NULL,
  enable_ bit(1) NOT NULL,
  organization_ character varying(72),
  create_date date NOT NULL,
  created_by character varying(92) NOT NULL,
  modified_date date,
  modified_by character varying(72),
  source_ character varying(72) NOT NULL
);

CREATE TABLE admin.bill_to (
  account_ character varying(48) PRIMARY KEY NOT NULL,
  organization_ character varying(72) NOT NULL,
  subsidiary_ character varying(72) NOT NULL,
  business_unit character varying(72) NOT NULL,
  plan_ character varying(7) NOT NULL,
  email_ character varying(72) NOT NULL,
  location_ character varying(72) NOT NULL,
  name_ character varying(72) NOT NULL,
  card_ character varying(72),
  card_expiration character varying(72),
  card_csv character varying(7),
  purchase_order character varying(72),
  client_reference character varying(72) NOT NULL
);

CREATE TABLE admin.discovery_plan (
  plan_id uuid NOT NULL,
  name_ character varying(72) NOT NULL,
  cost_ money NOT NULL,
  PRIMARY KEY (plan_id, name_)
);

CREATE TABLE admin.gui_type (
  gui_ character varying(48) PRIMARY KEY NOT NULL
);

CREATE TABLE admin.project (
  project_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  name_ character varying(64) NOT NULL,
  sponsor_ character varying(48),
  manager_ character varying(48),
  approval_date date,
  start_date date,
  end_date date,
  create_date date NOT NULL,
  created_by character varying(96) NOT NULL,
  modified_date date,
  modified_by character varying(96),
  source_ character varying(96) NOT NULL
);

CREATE TABLE admin.prompt_setting (
  name_ character varying(48) PRIMARY KEY NOT NULL,
  prompt_text text NOT NULL,
  response_count integer NOT NULL,
  create_date date NOT NULL,
  created_by character varying(96) NOT NULL,
  source_ character varying(96) NOT NULL,
  modified_by character varying(96),
  modified_date date
);

CREATE TABLE admin.prompt_type (
  prompt_ character varying(48) PRIMARY KEY NOT NULL
);

CREATE TABLE analysis.report (
  report_id uuid PRIMARY KEY NOT NULL,
  role_id uuid NOT NULL
);

CREATE TABLE client.business_unit (
  unit_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  parent_id uuid NOT NULL,
  subsidiary_id uuid,
  name_ character varying(96) NOT NULL,
  create_date date NOT NULL,
  created_by character varying(92) NOT NULL,
  modified_date date,
  modified_by character varying(72),
  source_ character varying(72) NOT NULL
);

CREATE TABLE client.interview (
  interview_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  role_id uuid NOT NULL,
  request_date date,
  model_id uuid NOT NULL,
  cost numeric(6,2),
  frequency_ character varying(32) NOT NULL,
  interview_admin character varying(96),
  approval_date date,
  start_date date,
  end_date date,
  create_date date NOT NULL DEFAULT (CURRENT_DATE),
  modified_date date,
  created_by character varying(96),
  modified_by character varying(96),
  author_id uuid,
  source_ character varying(96) NOT NULL,
  title_ character varying(64),
  project_id uuid
);

CREATE TABLE client.parent (
  parent_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  name_ character varying(96) NOT NULL,
  organization_type character varying(32),
  product_service character varying(128),
  annual_revenue character varying(48),
  employee_total character varying(48),
  website_ character varying(128) NOT NULL,
  location_ character varying(96),
  source_ character varying(48) NOT NULL,
  create_date date NOT NULL,
  created_by character varying(92) NOT NULL,
  modified_date date,
  modified_by character varying(92),
  stock_symbol character varying(8),
  industry_hash_id character varying(32)
);

CREATE TABLE client.role (
  role_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  description_ character varying(92) NOT NULL,
  respondent_ character varying(12),
  project_sponsor character varying(12),
  location_reference character varying(96),
  create_date date NOT NULL,
  created_by character varying(92),
  modified_date date,
  modified_by character varying(92),
  hash_value bytea,
  unit_id uuid,
  source_ character varying(96) NOT NULL
);

CREATE TABLE client.subsidiary (
  subsidiary_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  organization_type character varying(32) NOT NULL,
  parent_id uuid NOT NULL,
  name_ character varying(96) NOT NULL,
  nasic_code character varying(8),
  product_service character varying(128),
  annual_revenue character varying(48),
  employee_total character varying(48),
  website_ character varying(96),
  location_reference character varying(96),
  source_ character varying(48) NOT NULL,
  create_date date NOT NULL DEFAULT (CURRENT_DATE),
  created_by character varying(92) NOT NULL,
  modified_date date,
  modified_by character varying(92),
  stock_symbol character varying(8),
  industry_hash_id character varying(32)
);

CREATE TABLE interview.answer (
  answer_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  question_id uuid,
  respondent_id uuid NOT NULL,
  answer_ jsonb,
  answer_date timestamptz NOT NULL,
  score_ smallint,
  location_reference character varying(48),
  hash_value bytea
);

CREATE TABLE interview.answer_in_progress (
  progress_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  question_id uuid NOT NULL,
  respondent_id uuid NOT NULL,
  answer_ jsonb,
  answer_date timestamptz NOT NULL,
  score_ smallint,
  location_reference character varying(48),
  source_ character varying(96) NOT NULL,
  hash_value bytea
);

CREATE TABLE interview.author (
  author_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  name_ character varying(96) NOT NULL,
  email_ character varying(48) NOT NULL,
  start_date date NOT NULL,
  end_date date,
  create_date date NOT NULL,
  modified_date date,
  source_ character varying(96) NOT NULL
);

CREATE TABLE interview.question (
  question_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  model_question_id uuid NOT NULL,
  author_id uuid,
  syntax_ jsonb NOT NULL,
  help_ jsonb,
  sort_order smallint NOT NULL,
  create_date date NOT NULL,
  modified_date date,
  disable_ bit(1),
  topic_ character varying(96) NOT NULL,
  subtopic_ character varying(96),
  weight_ numeric(10,2),
  source_ character varying(96) NOT NULL,
  gui_type character varying(48),
  type_ character varying(48),
  interview_id uuid,
  help_text jsonb,
  help_list jsonb
);

CREATE TABLE interview.question_response_score (
  response_score_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  question_id uuid NOT NULL,
  response_ character varying NOT NULL,
  score_ smallint NOT NULL
);

CREATE TABLE interview.rating (
  rating_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  rating_value numeric(3,2) NOT NULL,
  description_ character varying(48) NOT NULL,
  condition_ character varying(48) NOT NULL,
  condition_value numeric(6,2) NOT NULL,
  color_ character varying(32),
  source_ character varying(48),
  create_date date NOT NULL,
  modified_date date,
  hash_value bytea,
  interview_id uuid NOT NULL
);

CREATE TABLE interview.respondent (
  respondent_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  email_ character varying(96) NOT NULL,
  role_id uuid NOT NULL,
  description_ character varying(92),
  respondent_ character varying(12),
  project_sponsor character varying(12),
  location_reference character varying(48),
  first_name character varying(48),
  last_name character varying(32),
  title_ character varying(64),
  phone_ character varying(16),
  create_date date NOT NULL,
  created_by character varying(92),
  modified_date date,
  modified_by character varying(92),
  hash_value bytea,
  source_ character varying(96) NOT NULL
);

CREATE TABLE interview.schedule (
  schedule_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  date_value character varying NOT NULL,
  interview_id uuid NOT NULL
);

CREATE TABLE load.business_unit (
  name_ character varying(96) NOT NULL,
  parent_ character varying(96) NOT NULL,
  subsidiary_ character varying(96),
  nasic_code character varying(8) NOT NULL,
  model_reference character varying(255) NOT NULL,
  create_date date NOT NULL,
  created_by character varying(92) NOT NULL,
  modified_date date,
  modified_by character varying(72),
  source_ character varying(72) NOT NULL
);

CREATE TABLE load.contact (
  email_ character varying(128) NOT NULL,
  parent_ character varying(96) NOT NULL,
  subsidiary_ character varying(96),
  business_unit character varying(96) NOT NULL,
  nasic_code character varying(8) NOT NULL,
  title_ character varying(64),
  role_ character varying(50) NOT NULL,
  respondent_ character varying(12) NOT NULL,
  project_sponsor character varying(12) NOT NULL,
  first_name character varying(32),
  last_name character varying(92) NOT NULL,
  location_ character varying(48),
  phone_ character varying(16),
  create_date date NOT NULL,
  created_by character varying(92) NOT NULL,
  modified_date date,
  modified_by character varying(92)
);

CREATE TABLE load.industry (
  nasic_code character varying(8) NOT NULL,
  description_ character varying(128) NOT NULL,
  source_ character varying(96)
);

CREATE TABLE load.model (
  nasic_code character varying(8) NOT NULL,
  biz_unit character varying(96) NOT NULL,
  role_ character varying(96) NOT NULL,
  create_date date,
  created_by character varying(92) NOT NULL,
  modified_date date,
  modified_by character varying(72),
  source_ character varying(72) NOT NULL
);

CREATE TABLE load.model_question (
  nasic_code character varying(8) NOT NULL,
  business_unit character varying(96) NOT NULL,
  role_ character varying(96) NOT NULL,
  model_topic character varying(96) NOT NULL,
  topic_ character varying(96) NOT NULL,
  subtopic_ character varying(96),
  syntax_ character varying(1024) NOT NULL,
  help_ character varying(1024),
  type_ character varying(32) NOT NULL,
  sort_order smallint NOT NULL,
  location_reference character varying(96),
  create_date date NOT NULL,
  modified_date date,
  source_ character varying(96)
);

CREATE TABLE load.parent (
  name_ character varying(96) NOT NULL,
  organization_type character varying(32),
  ticker_ character varying(8),
  nasic_code character varying(8),
  product_service character varying(128),
  annual_revenue numeric(15,2),
  employee_total integer,
  website_ character varying(92),
  location_ character varying(48),
  source_ character varying(48) NOT NULL,
  create_date date NOT NULL,
  created_by character varying(92) NOT NULL,
  modified_date date,
  modified_by character varying(92)
);

CREATE TABLE load.subsidiary (
  parent_ character varying(96) NOT NULL,
  name_ character varying(96) NOT NULL,
  organization_type character varying(32),
  ticker_ character varying(8),
  nasic_code character varying(8),
  product_service character varying(72),
  annual_revenue numeric(15,2),
  employee_total integer,
  website_ character varying(92),
  location_ character varying(48),
  source_ character varying(48) NOT NULL,
  create_date date NOT NULL,
  created_by character varying(92) NOT NULL,
  modified_date date,
  modified_by character varying(92)
);

CREATE TABLE model.author (
  author_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  name_ character varying(96) NOT NULL,
  email_ character varying(96) NOT NULL,
  start_date date NOT NULL,
  end_date date,
  create_date date NOT NULL,
  modified_date date,
  hash_value bytea,
  source_ character varying(96) NOT NULL
);

CREATE TABLE model.business_function (
  function_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  name_ character varying(96) NOT NULL,
  create_date date NOT NULL DEFAULT (CURRENT_DATE),
  created_by character varying(96),
  modified_date date,
  modified_by character varying(96),
  source_ character varying(96) NOT NULL,
  description_ character varying(128)
);

CREATE TABLE model.discovery (
  model_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  role_id uuid NOT NULL,
  author_id uuid NOT NULL,
  title_ character varying(64),
  model_topic character varying(64),
  start_date date NOT NULL,
  end_date date,
  submission_approved_by character varying(48),
  survey_adminstrator character varying(48),
  approval_date date,
  create_date date NOT NULL DEFAULT (CURRENT_DATE),
  modified_date date,
  submit_date date,
  source_ character varying(96) NOT NULL,
  industry_hash_id character varying(32),
  function_id uuid,
  project_id uuid
);

CREATE TABLE model.question (
  question_id uuid PRIMARY KEY NOT NULL,
  model_id uuid NOT NULL,
  author_id uuid NOT NULL,
  syntax_ jsonb NOT NULL,
  sort_order smallint NOT NULL,
  location_reference character varying(96),
  create_date date NOT NULL,
  modified_date date,
  disable_ bit(1),
  topic_ character varying(96),
  subtopic_ character varying(96),
  weight_ numeric(10,2),
  source_ character varying(96) NOT NULL,
  gui_type character varying(48),
  type_ character varying(48),
  help_text jsonb,
  help_list jsonb
);

CREATE TABLE model.role (
  role_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  name_ character varying(96) NOT NULL,
  create_date date NOT NULL DEFAULT (CURRENT_DATE),
  created_by character varying(92),
  modified_by character varying(92),
  modified_date date,
  source_ character varying(96) NOT NULL,
  description_ character varying(512)
);

CREATE TABLE reference.industry (
  industry_hash_id character varying(32) PRIMARY KEY NOT NULL,
  code_source character varying(32) NOT NULL,
  code_ character varying(32) NOT NULL,
  description_ character varying(255) NOT NULL,
  version_ character varying(32) NOT NULL,
  start_date date NOT NULL,
  end_date date,
  created_by character varying(96) NOT NULL,
  create_date date NOT NULL,
  modified_by character varying(96),
  modified_date date
);

CREATE TABLE reference.location (
  location_hash_id character varying(32) UNIQUE PRIMARY KEY NOT NULL,
  latitude_longitude point NOT NULL,
  description_ character varying(64) NOT NULL,
  address_1 character varying(72),
  address_2 character varying(72),
  city_ character varying(72),
  province_state character varying(32),
  postal_code character varying(10) NOT NULL,
  country_code character varying(4) NOT NULL,
  source_ character varying(72) NOT NULL,
  effective_start_date date NOT NULL,
  effective_end_date date
);

CREATE TABLE stage.business_unit (
  name_ character varying(96) NOT NULL,
  parent_ character varying(96) NOT NULL,
  subsidiary_ character varying(96) NOT NULL,
  create_date date NOT NULL,
  created_by character varying(92) NOT NULL,
  modified_date date,
  modified_by character varying(72),
  source_ character varying(72) NOT NULL,
  rag_business_function character varying(96),
  rag_function_source character varying(96),
  rag_function_create_date date,
  rag_function_created_by character varying(96),
  PRIMARY KEY (name_, parent_, subsidiary_)
);

CREATE TABLE stage.contact (
  email_ character varying(128) NOT NULL,
  parent_ character varying(96) NOT NULL,
  subsidiary_ character varying(96) NOT NULL,
  business_unit character varying(96) NOT NULL,
  title_ character varying(128),
  respondent_ character varying(12),
  first_name character varying(48),
  last_name character varying(32),
  location_reference character varying(96),
  phone_ character varying(16),
  create_date date NOT NULL,
  created_by character varying(92) NOT NULL,
  job_description character varying(255),
  modified_date date,
  modified_by character varying(92),
  source_ character varying(92),
  rag_role character varying(64),
  rag_role_rationale character varying(512),
  rag_role_source character varying(96),
  rag_role_create_date date,
  rag_role_created_by character varying(96),
  system_admin character varying(12),
  PRIMARY KEY (email_, parent_, subsidiary_, business_unit)
);

CREATE TABLE stage.model (
  industry_hash_id character varying(32) NOT NULL,
  business_function character varying(96) NOT NULL,
  role_ character varying(96) NOT NULL,
  create_date date NOT NULL,
  created_by character varying(96) NOT NULL,
  modified_date date,
  modified_by character varying(96),
  source_ character varying(96) NOT NULL,
  name_ character varying(64),
  project_reference character varying(64),
  response_count smallint NOT NULL,
  PRIMARY KEY (industry_hash_id, business_function, role_)
);

CREATE TABLE stage.model_question (
  question_id uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  industry_hash_id character varying(32) NOT NULL,
  business_function character varying(96) NOT NULL,
  role_ character varying(96) NOT NULL,
  model_topic character varying(96),
  topic_ character varying(96),
  subtopic_ character varying(96),
  syntax_ jsonb NOT NULL,
  help_text jsonb,
  help_list jsonb,
  response_type character varying(32),
  sort_order smallint NOT NULL,
  location_reference character varying(96),
  create_date date NOT NULL,
  modified_date date,
  source_ character varying(92),
  gui_type character varying(48) NOT NULL
);

CREATE TABLE stage.parent (
  name_ character varying(96) PRIMARY KEY NOT NULL,
  organization_type character varying(32),
  stock_symbol character varying(8),
  product_service character varying(128),
  annual_revenue character varying(48),
  employee_total character varying(48),
  website_ character varying(92),
  location_ character varying(48),
  source_ character varying(96) NOT NULL,
  create_date date NOT NULL,
  created_by character varying(92) NOT NULL,
  modified_date date,
  modified_by character varying(92),
  parent_id uuid,
  rag_industry_code character varying(24) NOT NULL,
  rag_industry_description character varying(512),
  rag_description_rationale character varying(512),
  rag_industry_source character varying(96),
  rag_industry_create_date date,
  rag_industry_created_by character varying(96),
  industry_hash_id character varying(32)
);

CREATE TABLE stage.subsidiary (
  name_ character varying(96) NOT NULL,
  parent_name character varying(96) NOT NULL,
  organization_type character varying(32),
  stock_symbol character varying(8),
  product_service character varying(32),
  annual_revenue character varying(48),
  employee_total character varying(48),
  website_ character varying(92),
  location_ character varying(48),
  source_ character varying(48) NOT NULL,
  create_date date NOT NULL,
  created_by character varying(92) NOT NULL,
  modified_date date,
  modified_by character varying(92),
  rag_industry_code character varying(24) NOT NULL,
  rag_industry_description character varying(512),
  rag_description_rationale character varying(512),
  rag_industry_source character varying(96),
  rag_industry_create_date date,
  rag_industry_created_by character varying(96),
  industry_hash_id character varying(32),
  PRIMARY KEY (name_, parent_name)
);

CREATE TABLE temp.admin_account (
  name_ character varying(72) NOT NULL,
  email_ character varying(72) NOT NULL,
  air_ character varying(32) NOT NULL,
  login_id character varying(72) NOT NULL,
  enable_ bit(1) NOT NULL,
  organization_ character varying(72),
  create_date date NOT NULL,
  created_by character varying(92) NOT NULL,
  modified_date date,
  modified_by character varying(72),
  source_ character varying(72) NOT NULL
);

CREATE TABLE temp.bill_to (
  account_ character varying(48) NOT NULL,
  organization_ character varying(72) NOT NULL,
  subsidiary_ character varying(72),
  business_unit character varying(72) NOT NULL,
  plan_ character varying(7) NOT NULL,
  email_ character varying(72) NOT NULL,
  location_ character varying(72) NOT NULL,
  name_ character varying(72) NOT NULL,
  card_ character varying(72),
  card_expiration character varying(72),
  card_csv character varying(7),
  purchase_order character varying(72),
  client_reference character varying(72) NOT NULL
);

CREATE TABLE temp.discovery_plan (
  name_ character varying(72) NOT NULL,
  cost_ money NOT NULL,
  created_date date NOT NULL
);

CREATE INDEX fk_analysisrep ON analysis.report USING BTREE (role_id);

CREATE INDEX fk_clientbizunit ON client.business_unit USING BTREE (parent_id);

CREATE INDEX fk_1_clientinterview ON client.interview USING BTREE (role_id);

CREATE INDEX fk_2_clientint ON client.interview USING BTREE (model_id);

CREATE INDEX fk_2 ON interview.question USING BTREE (author_id);

CREATE INDEX fk_intques ON interview.question USING BTREE (model_question_id);

CREATE INDEX fk_1_rating ON interview.rating USING BTREE (interview_id);

CREATE INDEX fk_interviewres ON interview.respondent USING BTREE (role_id);

CREATE INDEX fk_1_schedule ON interview.schedule USING BTREE (interview_id);

CREATE INDEX fk_1 ON stage.model USING BTREE (industry_hash_id);

CREATE UNIQUE INDEX unique_question ON stage.model_question (industry_hash_id, business_function, role_, sort_order);

CREATE INDEX fk_model_question ON stage.model_question USING BTREE (industry_hash_id);

ALTER TABLE client.interview ADD CONSTRAINT fk_23 FOREIGN KEY (model_id) REFERENCES model.discovery (model_id);

ALTER TABLE client.interview ADD CONSTRAINT fk_26_1 FOREIGN KEY (role_id) REFERENCES client.role (role_id);

ALTER TABLE client.business_unit ADD CONSTRAINT fk_client_unit_subsidiary FOREIGN KEY (subsidiary_id) REFERENCES client.subsidiary (subsidiary_id);

ALTER TABLE client.role ADD CONSTRAINT fk_role_unit FOREIGN KEY (unit_id) REFERENCES client.business_unit (unit_id);

ALTER TABLE client.subsidiary ADD CONSTRAINT fk_subsidiary_parent FOREIGN KEY (parent_id) REFERENCES client.parent (parent_id);

ALTER TABLE interview.schedule ADD CONSTRAINT fk_21 FOREIGN KEY (interview_id) REFERENCES client.interview (interview_id);

ALTER TABLE interview.rating ADD CONSTRAINT fk_22 FOREIGN KEY (interview_id) REFERENCES client.interview (interview_id);

ALTER TABLE interview.respondent ADD CONSTRAINT fk_23_1 FOREIGN KEY (role_id) REFERENCES client.role (role_id);

ALTER TABLE interview.question ADD CONSTRAINT fk_25 FOREIGN KEY (model_question_id) REFERENCES model.question (question_id);

ALTER TABLE interview.question ADD CONSTRAINT fk_25_1 FOREIGN KEY (author_id) REFERENCES interview.author (author_id);

ALTER TABLE interview.answer ADD CONSTRAINT fk_answer_question FOREIGN KEY (question_id) REFERENCES interview.question (question_id);

ALTER TABLE interview.answer ADD CONSTRAINT fk_answer_respondent FOREIGN KEY (respondent_id) REFERENCES interview.respondent (respondent_id);

ALTER TABLE interview.question ADD CONSTRAINT fk_interview_id FOREIGN KEY (interview_id) REFERENCES client.interview (interview_id);

ALTER TABLE interview.answer_in_progress ADD CONSTRAINT fk_progress_question FOREIGN KEY (question_id) REFERENCES interview.question (question_id);

ALTER TABLE interview.question_response_score ADD CONSTRAINT fk_response_score_question FOREIGN KEY (question_id) REFERENCES interview.question (question_id);

ALTER TABLE model.discovery ADD CONSTRAINT fk_25_2 FOREIGN KEY (industry_hash_id) REFERENCES reference.industry (industry_hash_id);

ALTER TABLE model.discovery ADD CONSTRAINT fk_discovery_author FOREIGN KEY (author_id) REFERENCES model.author (author_id);

ALTER TABLE model.discovery ADD CONSTRAINT fk_discovery_function FOREIGN KEY (function_id) REFERENCES model.business_function (function_id);

ALTER TABLE model.discovery ADD CONSTRAINT fk_discovery_role FOREIGN KEY (role_id) REFERENCES model.role (role_id);

ALTER TABLE model.question ADD CONSTRAINT fk_question_author FOREIGN KEY (author_id) REFERENCES model.author (author_id);

ALTER TABLE model.question ADD CONSTRAINT fk_question_model FOREIGN KEY (model_id) REFERENCES model.discovery (model_id);

ALTER TABLE stage.model ADD CONSTRAINT fk_31_2 FOREIGN KEY (industry_hash_id) REFERENCES reference.industry (industry_hash_id);

ALTER TABLE stage.model_question ADD CONSTRAINT fk_31_3 FOREIGN KEY (industry_hash_id) REFERENCES reference.industry (industry_hash_id);

ALTER TABLE analysis.report ADD CONSTRAINT fk_report_id_01 FOREIGN KEY (role_id) REFERENCES client.role (role_id);

ALTER TABLE model.discovery ADD CONSTRAINT fk_discovery_project FOREIGN KEY (project_id) REFERENCES admin.project (project_id);

ALTER TABLE client.interview ADD CONSTRAINT fk_client_project FOREIGN KEY (project_id) REFERENCES admin.project (project_id);


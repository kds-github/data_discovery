CREATE SCHEMA "admin";

CREATE SCHEMA "analysis";

CREATE SCHEMA "client";

CREATE SCHEMA "interview";

CREATE SCHEMA "load";

CREATE SCHEMA "model";

CREATE SCHEMA "reference";

CREATE SCHEMA "stage";

CREATE SCHEMA "temp";

CREATE TABLE "admin"."account" (
  "name_" varchar(72) PRIMARY KEY NOT NULL,
  "email_" varchar(72) NOT NULL,
  "air_" varchar(32) NOT NULL,
  "login_id" varchar(72) NOT NULL,
  "enable_" bit(1) NOT NULL,
  "organization_" varchar(72),
  "create_date" timestamptz NOT NULL,
  "created_by" varchar(92) NOT NULL,
  "modified_date" timestamptz,
  "modified_by" varchar(72),
  "source_" varchar(72) NOT NULL
);

CREATE TABLE "admin"."bill_to" (
  "account_" varchar(48) PRIMARY KEY NOT NULL,
  "organization_" varchar(72) NOT NULL,
  "subsidiary_" varchar(72) NOT NULL,
  "business_unit" varchar(72) NOT NULL,
  "plan_" varchar(7) NOT NULL,
  "email_" text NOT NULL,
  "location_" varchar(72) NOT NULL,
  "name_" varchar(72) NOT NULL,
  "card_" varchar(72),
  "card_expiration" varchar(72),
  "card_csv" varchar(7),
  "purchase_order" varchar(72),
  "client_reference" varchar(72) NOT NULL
);

CREATE TABLE "admin"."discovery_plan" (
  "plan_id" uuid NOT NULL,
  "name_" varchar(72) NOT NULL,
  "cost_" money NOT NULL,
  PRIMARY KEY ("plan_id", "name_")
);

CREATE TABLE "admin"."gui_type" (
  "gui_" varchar(48) PRIMARY KEY NOT NULL
);

CREATE TABLE "admin"."project" (
  "project_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "name_" varchar(64) NOT NULL,
  "sponsor_" varchar(48),
  "manager_" varchar(48),
  "approval_date" date,
  "start_date" date,
  "end_date" date,
  "create_date" timestamptz NOT NULL,
  "created_by" varchar(96) NOT NULL,
  "modified_date" timestamptz,
  "modified_by" varchar(96),
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "admin"."prompt_setting" (
  "prompt_id" uuid NOT NULL DEFAULT (gen_random_uuid()),
  "name_" varchar(48) NOT NULL,
  "prompt_text" text NOT NULL,
  "response_count" integer NOT NULL,
  "create_date" timestamptz NOT NULL,
  "created_by" varchar(96) NOT NULL,
  "source_" varchar(96) NOT NULL,
  "modified_by" varchar(96),
  "modified_date" timestamptz,
  PRIMARY KEY ("prompt_id", "name_")
);

CREATE TABLE "admin"."prompt_type" (
  "prompt_" varchar(48) PRIMARY KEY NOT NULL
);

CREATE TABLE "admin"."author" (
  "author_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "name_" varchar(96) NOT NULL,
  "email_" varchar(96) NOT NULL,
  "access_" varchar(48) NOT NULL,
  "start_date" date NOT NULL,
  "end_date" date,
  "create_date" timestamptz NOT NULL,
  "modified_date" timestamptz,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "analysis"."summary_by_topic" (
  "by_topic_id" uuid PRIMARY KEY NOT NULL,
  "control_id" UUID NOT NULL,
  "topic_" varchar(96) NOT NULL,
  "summary_" jsonb NOT NULL,
  "summary_date" timestamptz,
  "create_date" timestamptz NOT NULL,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "analysis"."by_topic_review" (
  "review_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "by_topic_id" uuid,
  "status_" varchar(32),
  "reviewed_by" varchar(96),
  "reviewed_date" varchar(96),
  "review_comment" jsonb
);

CREATE TABLE "analysis"."summary_by_interivew" (
  "by_interview_id" uuid PRIMARY KEY NOT NULL,
  "control_id" uuid NOT NULL,
  "summary_" jsonb NOT NULL,
  "summary_date" timestamptz NOT NULL,
  "create_date" timestamptz NOT NULL,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "analysis"."data_flow_by_topic" (
  "data_flow_id" uuid PRIMARY KEY NOT NULL,
  "by_topic_id" uuid,
  "noted_data_flow_source" jsonb,
  "noted_data_flow_destination" jsonb,
  "create_date" timestamptz NOT NULL,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "analysis"."solution_in_use_by_topic" (
  "in_use_id" uuid PRIMARY KEY NOT NULL,
  "by_topic_id" uuid,
  "description_" jsonb,
  "create_date" timestamptz NOT NULL,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "client"."business_unit" (
  "unit_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "parent_id" uuid NOT NULL,
  "subsidiary_id" uuid,
  "name_" varchar(96) NOT NULL,
  "create_date" timestamptz NOT NULL,
  "created_by" varchar(92) NOT NULL,
  "modified_date" timestamptz,
  "modified_by" varchar(72),
  "source_" varchar(72) NOT NULL
);

CREATE TABLE "client"."interview" (
  "interview_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "role_id" uuid NOT NULL,
  "request_date" date,
  "model_id" uuid NOT NULL,
  "cost" numeric(6,2),
  "frequency_" varchar(32) NOT NULL,
  "interview_admin" varchar(96),
  "approval_date" date,
  "start_date" date,
  "end_date" date,
  "create_date" timestamptz NOT NULL DEFAULT (CURRENT_DATE),
  "modified_date" timestamptz,
  "created_by" varchar(96),
  "modified_by" varchar(96),
  "author_id" uuid,
  "source_" varchar(96) NOT NULL,
  "title_" varchar(64),
  "project_id" uuid
);

CREATE TABLE "client"."interview_history" (
  "history_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "interview_id" uuid NOT NULL,
  "role_id" uuid NOT NULL,
  "request_date" date,
  "model_id" uuid NOT NULL,
  "cost" numeric(6,2),
  "frequency_" varchar(32) NOT NULL,
  "interview_admin" varchar(96),
  "approval_date" date,
  "start_date" date,
  "end_date" date,
  "create_date" timestamptz NOT NULL,
  "modified_date" timestamptz NOT NULL DEFAULT (CURRENT_DATE),
  "created_by" varchar(96),
  "modified_by" varchar(96),
  "author_id" uuid,
  "source_" varchar(96) NOT NULL,
  "title_" varchar(64),
  "project_id" uuid,
  "change_type" varchar(20),
  "change_reason" text
);

CREATE TABLE "client"."parent" (
  "parent_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "name_" varchar(96) NOT NULL,
  "organization_type" varchar(32),
  "product_service" varchar(128),
  "annual_revenue" varchar(48),
  "employee_total" varchar(48),
  "website_" varchar(128) NOT NULL,
  "location_" varchar(96),
  "source_" varchar(48) NOT NULL,
  "create_date" timestamptz NOT NULL,
  "created_by" varchar(92) NOT NULL,
  "modified_date" timestamptz,
  "modified_by" varchar(92),
  "stock_symbol" varchar(8),
  "industry_hash_id" varchar(32)
);

CREATE TABLE "client"."role" (
  "role_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "description_" text NOT NULL,
  "respondent_" varchar(12),
  "project_sponsor" varchar(12),
  "location_reference" varchar(96),
  "create_date" timestamptz NOT NULL,
  "created_by" varchar(92),
  "modified_date" timestamptz,
  "modified_by" varchar(92),
  "hash_value" bytea,
  "unit_id" uuid,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "client"."subsidiary" (
  "subsidiary_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "organization_type" varchar(32) NOT NULL,
  "parent_id" uuid NOT NULL,
  "name_" varchar(96) NOT NULL,
  "nasic_code" varchar(8),
  "product_service" varchar(128),
  "annual_revenue" varchar(48),
  "employee_total" varchar(48),
  "website_" varchar(96),
  "location_reference" varchar(96),
  "source_" varchar(48) NOT NULL,
  "create_date" timestamptz NOT NULL DEFAULT (CURRENT_DATE),
  "created_by" varchar(92) NOT NULL,
  "modified_date" timestamptz,
  "modified_by" varchar(92),
  "stock_symbol" varchar(8),
  "industry_hash_id" varchar(32)
);

CREATE TABLE "interview"."answer" (
  "answer_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "question_id" uuid,
  "respondent_id" uuid NOT NULL,
  "answer_" jsonb,
  "answer_date" timestamptz NOT NULL,
  "note_" jsonb,
  "score_" smallint,
  "location_reference" varchar(48)
);

CREATE TABLE "interview"."answer_in_progress" (
  "progress_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "question_id" uuid NOT NULL,
  "respondent_id" uuid NOT NULL,
  "answer_" jsonb,
  "answer_date" timestamptz NOT NULL,
  "note_" jsonb,
  "score_" smallint,
  "location_reference" varchar(48),
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "interview"."author" (
  "author_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "name_" varchar(96) NOT NULL,
  "email_" text NOT NULL,
  "start_date" date NOT NULL,
  "end_date" date,
  "create_date" timestamptz NOT NULL,
  "modified_date" timestamptz,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "interview"."conversation" (
  "converstion_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "conversation_type" varchar(32) NOT NULL,
  "start_date" timestamptz NOT NULL,
  "interview_id" uuid NOT NULL,
  "topic_" varchar(96) NOT NULL,
  "respondent_id" uuid,
  "character_count" bigint,
  "answer_count" smallint,
  "create_date" timestamptz NOT NULL,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "interview"."question" (
  "question_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "model_question_id" uuid NOT NULL,
  "author_id" uuid,
  "syntax_" jsonb NOT NULL,
  "help_" jsonb,
  "sort_order" smallint NOT NULL,
  "create_date" timestamptz NOT NULL,
  "modified_date" timestamptz,
  "disable_" bit(1),
  "topic_" varchar(96) NOT NULL,
  "subtopic_" varchar(96),
  "weight_" numeric(10,2),
  "source_" varchar(96) NOT NULL,
  "gui_type" varchar(48),
  "type_" varchar(48),
  "interview_id" uuid,
  "help_text" jsonb,
  "help_list" jsonb
);

CREATE TABLE "interview"."question_response_score" (
  "response_score_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "question_id" uuid NOT NULL,
  "response_" varchar NOT NULL,
  "score_" smallint NOT NULL
);

CREATE TABLE "interview"."rating" (
  "rating_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "rating_value" numeric(3,2) NOT NULL,
  "description_" varchar(48) NOT NULL,
  "condition_" varchar(48) NOT NULL,
  "condition_value" numeric(6,2) NOT NULL,
  "color_" varchar(32),
  "source_" varchar(48),
  "create_date" timestamptz NOT NULL,
  "modified_date" timestamptz,
  "hash_value" bytea,
  "interview_id" uuid NOT NULL
);

CREATE TABLE "interview"."question_redirect" (
  "redirect_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "question_id" uuid,
  "redirect_date" timestamptz,
  "email_to_contact" text,
  "name_to_contact" text,
  "contact_role" text,
  "document_to_review" text,
  "document_location" text,
  "note" text
);

CREATE TABLE "interview"."respondent" (
  "respondent_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "email_" varchar(96) NOT NULL,
  "role_id" uuid NOT NULL,
  "description_" text,
  "respondent_" varchar(12),
  "project_sponsor" varchar(12),
  "location_reference" varchar(48),
  "first_name" varchar(48),
  "last_name" varchar(32),
  "title_" varchar(64),
  "phone_" varchar(16),
  "create_date" timestamptz NOT NULL,
  "created_by" varchar(92),
  "modified_date" timestamptz,
  "modified_by" varchar(92),
  "hash_value" bytea,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "interview"."schedule" (
  "schedule_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "date_value" varchar NOT NULL,
  "interview_id" uuid NOT NULL
);

CREATE TABLE "interview"."summary_control" (
  "control_id" uuid PRIMARY KEY NOT NULL,
  "interview_id" uuid NOT NULL,
  "respondent_id" uuid NOT NULL,
  "start_date" timestamptz NOT NULL,
  "prompt_id" UUID,
  "character_count" bigint,
  "answer_count" smallint,
  "create_date" timestamptz NOT NULL,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "interview"."followup_question_by_topic" (
  "question_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "by_topic_id" uuid NOT NULL,
  "syntax_" jsonb NOT NULL,
  "followup_date" timestamptz NOT NULL,
  "create_date" timestamptz NOT NULL,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "interview"."followup_answer" (
  "answer_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "question_id" uuid NOT NULL,
  "comment_" jsonb,
  "contact_email" jsonb,
  "followup_date" timestamptz NOT NULL,
  "create_date" timestamptz NOT NULL,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "load"."business_unit" (
  "name_" varchar(96) NOT NULL,
  "parent_" varchar(96) NOT NULL,
  "subsidiary_" varchar(96),
  "nasic_code" varchar(8) NOT NULL,
  "model_reference" varchar(255) NOT NULL,
  "create_date" timestamptz NOT NULL,
  "created_by" varchar(92) NOT NULL,
  "modified_date" timestamptz,
  "modified_by" varchar(72),
  "source_" varchar(72) NOT NULL
);

CREATE TABLE "load"."contact" (
  "email_" varchar(128) NOT NULL,
  "parent_" varchar(96) NOT NULL,
  "subsidiary_" varchar(96),
  "business_unit" varchar(96) NOT NULL,
  "nasic_code" varchar(8) NOT NULL,
  "title_" varchar(64),
  "role_" varchar(50) NOT NULL,
  "respondent_" varchar(12) NOT NULL,
  "project_sponsor" varchar(12) NOT NULL,
  "first_name" varchar(32),
  "last_name" varchar(92) NOT NULL,
  "location_" varchar(48),
  "phone_" varchar(16),
  "create_date" timestamptz NOT NULL,
  "created_by" varchar(92) NOT NULL,
  "modified_date" timestamptz,
  "modified_by" varchar(92)
);

CREATE TABLE "load"."industry" (
  "nasic_code" varchar(8) NOT NULL,
  "description_" varchar(128) NOT NULL,
  "source_" varchar(96)
);

CREATE TABLE "load"."model" (
  "nasic_code" varchar(8) NOT NULL,
  "biz_unit" varchar(96) NOT NULL,
  "role_" varchar(96) NOT NULL,
  "create_date" timestamptz,
  "created_by" varchar(92) NOT NULL,
  "modified_date" timestamptz,
  "modified_by" varchar(72),
  "source_" varchar(72) NOT NULL
);

CREATE TABLE "load"."model_question" (
  "nasic_code" varchar(8) NOT NULL,
  "business_unit" varchar(96) NOT NULL,
  "role_" varchar(96) NOT NULL,
  "model_topic" varchar(96) NOT NULL,
  "topic_" varchar(96) NOT NULL,
  "subtopic_" varchar(96),
  "syntax_" varchar(1024) NOT NULL,
  "help_" varchar(1024),
  "type_" varchar(32) NOT NULL,
  "sort_order" smallint NOT NULL,
  "location_reference" varchar(96),
  "create_date" timestamptz NOT NULL,
  "modified_date" date,
  "source_" varchar(96)
);

CREATE TABLE "load"."parent" (
  "name_" varchar(96) NOT NULL,
  "organization_type" varchar(32),
  "ticker_" varchar(8),
  "nasic_code" varchar(8),
  "product_service" varchar(128),
  "annual_revenue" numeric(15,2),
  "employee_total" integer,
  "website_" varchar(92),
  "location_" varchar(48),
  "source_" varchar(48) NOT NULL,
  "create_date" timestamptz NOT NULL,
  "created_by" varchar(92) NOT NULL,
  "modified_date" timestamptz,
  "modified_by" varchar(92)
);

CREATE TABLE "load"."subsidiary" (
  "parent_" varchar(96) NOT NULL,
  "name_" varchar(96) NOT NULL,
  "organization_type" varchar(32),
  "ticker_" varchar(8),
  "nasic_code" varchar(8),
  "product_service" varchar(72),
  "annual_revenue" numeric(15,2),
  "employee_total" integer,
  "website_" varchar(92),
  "location_" varchar(48),
  "source_" varchar(48) NOT NULL,
  "create_date" timestamptz NOT NULL,
  "created_by" varchar(92) NOT NULL,
  "modified_date" timestamptz,
  "modified_by" varchar(92)
);

CREATE TABLE "load"."prompt_setting" (
  "name_" varchar(48) PRIMARY KEY NOT NULL,
  "prompt_text" text NOT NULL,
  "response_count" integer NOT NULL,
  "create_date" timestamptz NOT NULL,
  "created_by" varchar(96) NOT NULL,
  "source_" varchar(96) NOT NULL,
  "modified_by" varchar(96),
  "modified_date" timestamptz
);

CREATE TABLE "load"."helpdesk_subject" (
  "helpdesk_source" TEXT NOT NULL,
  "subject_" TEXT,
  "subject_date" TEXT,
  "created_date" date NOT NULL,
  "created_by" TEXT NOT NULL,
  "source_" TEXT NOT NULL
);

CREATE TABLE "model"."author" (
  "author_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "name_" varchar(96) NOT NULL,
  "email_" varchar(96) NOT NULL,
  "start_date" date NOT NULL,
  "end_date" date,
  "create_date" timestamptz NOT NULL,
  "modified_date" timestamptz,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "model"."business_function" (
  "function_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "name_" varchar(96) NOT NULL,
  "create_date" timestamptz NOT NULL DEFAULT (CURRENT_DATE),
  "created_by" varchar(96),
  "modified_date" timestamptz,
  "modified_by" varchar(96),
  "source_" varchar(96) NOT NULL,
  "description_" varchar(128)
);

CREATE TABLE "model"."discovery" (
  "model_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "role_id" uuid NOT NULL,
  "author_id" uuid NOT NULL,
  "title_" varchar(64),
  "model_topic" varchar(64),
  "start_date" date NOT NULL,
  "end_date" date,
  "submission_approved_by" varchar(48),
  "survey_adminstrator" varchar(48),
  "approval_date" date,
  "create_date" timestamptz NOT NULL DEFAULT (CURRENT_DATE),
  "modified_date" timestamptz,
  "submit_date" date,
  "source_" varchar(96) NOT NULL,
  "industry_hash_id" varchar(32),
  "function_id" uuid,
  "project_id" uuid
);

CREATE TABLE "model"."question" (
  "question_id" uuid PRIMARY KEY NOT NULL,
  "model_id" uuid NOT NULL,
  "author_id" uuid NOT NULL,
  "syntax_" jsonb NOT NULL,
  "sort_order" smallint NOT NULL,
  "location_reference" varchar(96),
  "create_date" timestamptz NOT NULL,
  "modified_date" timestamptz,
  "disable_" bit(1),
  "topic_" varchar(96),
  "subtopic_" varchar(96),
  "weight_" numeric(10,2),
  "source_" varchar(96) NOT NULL,
  "gui_type" varchar(48),
  "type_" varchar(48),
  "help_text" jsonb,
  "help_list" jsonb
);

CREATE TABLE "model"."role" (
  "role_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "name_" varchar(96) NOT NULL,
  "create_date" timestamptz NOT NULL DEFAULT (CURRENT_DATE),
  "created_by" varchar(92),
  "modified_by" varchar(92),
  "modified_date" timestamptz,
  "source_" varchar(96) NOT NULL,
  "description_" varchar(512)
);

CREATE TABLE "reference"."industry" (
  "industry_hash_id" varchar(32) PRIMARY KEY NOT NULL,
  "code_source" varchar(32) NOT NULL,
  "code_" varchar(32) NOT NULL,
  "description_" varchar(255) NOT NULL,
  "version_" varchar(32) NOT NULL,
  "start_date" date NOT NULL,
  "end_date" date,
  "created_by" varchar(96) NOT NULL,
  "create_date" timestamptz NOT NULL,
  "modified_by" varchar(96),
  "modified_date" timestamptz
);

CREATE TABLE "reference"."location" (
  "location_hash_id" varchar(32) UNIQUE PRIMARY KEY NOT NULL,
  "latitude_longitude" point NOT NULL,
  "description_" varchar(64) NOT NULL,
  "address_1" varchar(72),
  "address_2" varchar(72),
  "city_" varchar(72),
  "province_state" varchar(32),
  "postal_code" varchar(10) NOT NULL,
  "country_code" varchar(4) NOT NULL,
  "source_" varchar(72) NOT NULL,
  "effective_start_date" date NOT NULL,
  "effective_end_date" date
);

CREATE TABLE "stage"."business_unit" (
  "name_" varchar(96) NOT NULL,
  "parent_" varchar(96) NOT NULL,
  "subsidiary_" varchar(96) NOT NULL,
  "create_date" timestamptz NOT NULL,
  "created_by" varchar(92) NOT NULL,
  "modified_date" timestamptz,
  "modified_by" varchar(72),
  "source_" varchar(72) NOT NULL,
  "rag_business_function" varchar(96),
  "rag_function_source" varchar(96),
  "rag_function_create_date" timestamptz,
  "rag_function_created_by" varchar(96),
  PRIMARY KEY ("name_", "parent_", "subsidiary_")
);

CREATE TABLE "stage"."contact" (
  "email_" varchar(128) NOT NULL,
  "parent_" varchar(96) NOT NULL,
  "subsidiary_" varchar(96) NOT NULL,
  "business_unit" varchar(96) NOT NULL,
  "title_" varchar(128),
  "respondent_" varchar(12),
  "first_name" varchar(48),
  "last_name" varchar(32),
  "location_reference" varchar(96),
  "phone_" varchar(16),
  "create_date" timestamptz NOT NULL,
  "created_by" varchar(92) NOT NULL,
  "job_description" text,
  "modified_date" timestamptz,
  "modified_by" varchar(92),
  "source_" varchar(92),
  "rag_role" varchar(64),
  "rag_role_rationale" text,
  "rag_role_source" text,
  "rag_role_create_date" timestamptz,
  "rag_role_created_by" varchar(96),
  "system_admin" varchar(12),
  PRIMARY KEY ("email_", "parent_", "subsidiary_", "business_unit")
);

CREATE TABLE "stage"."followup_question_by_topic" (
  "question_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "by_topic_id" uuid NOT NULL,
  "syntax_" jsonb NOT NULL,
  "start_date" timestamptz NOT NULL,
  "create_date" timestamptz NOT NULL,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "stage"."model" (
  "industry_hash_id" varchar(32) NOT NULL,
  "business_function" varchar(96) NOT NULL,
  "role_" varchar(96) NOT NULL,
  "create_date" timestamptz NOT NULL,
  "created_by" varchar(96) NOT NULL,
  "modified_date" timestamptz,
  "modified_by" varchar(96),
  "source_" varchar(96) NOT NULL,
  "name_" varchar(64),
  "project_reference" varchar(64),
  "response_count" smallint NOT NULL,
  "author_id" UUID,
  "project_id" UUID,
  "model_title" varchar(64),
  "model_topic" varchar(64),
  "frequency_" varchar(32),
  PRIMARY KEY ("industry_hash_id", "business_function", "role_")
);

CREATE TABLE "stage"."model_question" (
  "question_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "industry_hash_id" varchar(32) NOT NULL,
  "business_function" varchar(96) NOT NULL,
  "role_" varchar(96) NOT NULL,
  "model_topic" varchar(96),
  "topic_" varchar(96),
  "subtopic_" varchar(96),
  "syntax_" jsonb NOT NULL,
  "help_text" jsonb,
  "help_list" jsonb,
  "response_type" varchar(32),
  "sort_order" smallint NOT NULL,
  "location_reference" varchar(96),
  "create_date" timestamptz NOT NULL,
  "modified_date" timestamptz,
  "source_" varchar(92),
  "gui_type" varchar(48) NOT NULL
);

CREATE TABLE "stage"."parent" (
  "name_" varchar(96) PRIMARY KEY NOT NULL,
  "organization_type" varchar(32),
  "stock_symbol" varchar(8),
  "product_service" varchar(128),
  "annual_revenue" varchar(48),
  "employee_total" varchar(48),
  "website_" varchar(92),
  "location_" varchar(48),
  "source_" varchar(96) NOT NULL,
  "create_date" timestamptz NOT NULL,
  "created_by" varchar(92) NOT NULL,
  "modified_date" timestamptz,
  "modified_by" varchar(92),
  "parent_id" uuid,
  "rag_industry_code" varchar(24) NOT NULL,
  "rag_industry_description" varchar(512),
  "rag_description_rationale" varchar(512),
  "rag_industry_source" varchar(96),
  "rag_industry_create_date" timestamptz,
  "rag_industry_created_by" varchar(96),
  "industry_hash_id" varchar(32)
);

CREATE TABLE "stage"."subsidiary" (
  "name_" varchar(96) NOT NULL,
  "parent_name" varchar(96) NOT NULL,
  "organization_type" varchar(32),
  "stock_symbol" varchar(8),
  "product_service" varchar(32),
  "annual_revenue" varchar(48),
  "employee_total" varchar(48),
  "website_" varchar(92),
  "location_" varchar(48),
  "source_" varchar(48) NOT NULL,
  "create_date" timestamptz NOT NULL,
  "created_by" varchar(92) NOT NULL,
  "modified_date" timestamptz,
  "modified_by" varchar(92),
  "rag_industry_code" varchar(24) NOT NULL,
  "rag_industry_description" varchar(512),
  "rag_description_rationale" varchar(512),
  "rag_industry_source" varchar(96),
  "rag_industry_create_date" timestamptz,
  "rag_industry_created_by" varchar(96),
  "industry_hash_id" varchar(32),
  PRIMARY KEY ("name_", "parent_name")
);

CREATE TABLE "stage"."summary_by_topic" (
  "by_topic_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "control_id" UUID NOT NULL,
  "topic_" varchar(96) NOT NULL,
  "summary_" jsonb NOT NULL,
  "summary_date" timestamptz,
  "create_date" timestamptz NOT NULL,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "stage"."summary_by_interivew" (
  "by_interview_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "control_id" uuid NOT NULL,
  "summary_" jsonb NOT NULL,
  "summary_date" timestamptz,
  "create_date" timestamptz NOT NULL,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "stage"."data_flow_by_topic" (
  "data_flow_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "by_topic_id" uuid,
  "noted_data_flow_source" jsonb,
  "noted_data_flow_destination" jsonb,
  "create_date" timestamptz NOT NULL,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "stage"."solution_in_use_by_topic" (
  "in_use_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "by_topic_id" uuid,
  "description_" jsonb,
  "create_date" timestamptz NOT NULL,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "temp"."summary_control" (
  "control_id" uuid PRIMARY KEY NOT NULL DEFAULT (gen_random_uuid()),
  "interview_id" uuid NOT NULL,
  "respondent_id" uuid NOT NULL,
  "start_date" timestamptz NOT NULL,
  "prompt_id" UUID,
  "character_count" bigint,
  "answer_count" smallint,
  "create_date" timestamptz NOT NULL,
  "source_" varchar(96) NOT NULL
);

CREATE TABLE "temp"."admin_account" (
  "name_" varchar(72) NOT NULL,
  "email_" varchar(72) NOT NULL,
  "air_" varchar(32) NOT NULL,
  "login_id" varchar(72) NOT NULL,
  "enable_" bit(1) NOT NULL,
  "organization_" varchar(72),
  "create_date" timestamptz NOT NULL,
  "created_by" varchar(92) NOT NULL,
  "modified_date" timestamptz,
  "modified_by" varchar(72),
  "source_" varchar(72) NOT NULL
);

CREATE TABLE "temp"."bill_to" (
  "account_" varchar(48) NOT NULL,
  "organization_" varchar(72) NOT NULL,
  "subsidiary_" varchar(72),
  "business_unit" varchar(72) NOT NULL,
  "plan_" varchar(7) NOT NULL,
  "email_" varchar(72) NOT NULL,
  "location_" varchar(72) NOT NULL,
  "name_" varchar(72) NOT NULL,
  "card_" varchar(72),
  "card_expiration" varchar(72),
  "card_csv" varchar(7),
  "purchase_order" varchar(72),
  "client_reference" varchar(72) NOT NULL
);

CREATE TABLE "temp"."discovery_plan" (
  "name_" varchar(72) NOT NULL,
  "cost_" money NOT NULL,
  "created_date" date NOT NULL
);

CREATE INDEX "fk_clientbizunit" ON "client"."business_unit" USING BTREE ("parent_id");

CREATE INDEX "fk_1_clientinterview" ON "client"."interview" USING BTREE ("role_id");

CREATE INDEX "fk_2_clientint" ON "client"."interview" USING BTREE ("model_id");

CREATE INDEX "fk_interview_history" ON "client"."interview_history" USING BTREE ("interview_id");

CREATE INDEX "fk_2" ON "interview"."question" USING BTREE ("author_id");

CREATE INDEX "fk_intques" ON "interview"."question" USING BTREE ("model_question_id");

CREATE INDEX "fk_1_rating" ON "interview"."rating" USING BTREE ("interview_id");

CREATE INDEX "fk_interviewres" ON "interview"."respondent" USING BTREE ("role_id");

CREATE INDEX "fk_1_schedule" ON "interview"."schedule" USING BTREE ("interview_id");

CREATE INDEX "fk_1" ON "stage"."model" USING BTREE ("industry_hash_id");

CREATE UNIQUE INDEX "unique_question" ON "stage"."model_question" ("industry_hash_id", "business_function", "role_", "sort_order");

CREATE INDEX "fk_model_question" ON "stage"."model_question" USING BTREE ("industry_hash_id");

ALTER TABLE "client"."interview_history" ADD FOREIGN KEY ("interview_id") REFERENCES "client"."interview" ("interview_id");

ALTER TABLE "client"."interview" ADD CONSTRAINT "fk_23" FOREIGN KEY ("model_id") REFERENCES "model"."discovery" ("model_id");

ALTER TABLE "client"."interview" ADD CONSTRAINT "fk_26_1" FOREIGN KEY ("role_id") REFERENCES "client"."role" ("role_id");

ALTER TABLE "client"."business_unit" ADD CONSTRAINT "fk_client_unit_subsidiary" FOREIGN KEY ("subsidiary_id") REFERENCES "client"."subsidiary" ("subsidiary_id");

ALTER TABLE "client"."role" ADD CONSTRAINT "fk_role_unit" FOREIGN KEY ("unit_id") REFERENCES "client"."business_unit" ("unit_id");

ALTER TABLE "client"."subsidiary" ADD CONSTRAINT "fk_subsidiary_parent" FOREIGN KEY ("parent_id") REFERENCES "client"."parent" ("parent_id");

ALTER TABLE "interview"."schedule" ADD CONSTRAINT "fk_21" FOREIGN KEY ("interview_id") REFERENCES "client"."interview" ("interview_id");

ALTER TABLE "interview"."rating" ADD CONSTRAINT "fk_22" FOREIGN KEY ("interview_id") REFERENCES "client"."interview" ("interview_id");

ALTER TABLE "interview"."respondent" ADD CONSTRAINT "fk_23_1" FOREIGN KEY ("role_id") REFERENCES "client"."role" ("role_id");

ALTER TABLE "interview"."question" ADD CONSTRAINT "fk_25" FOREIGN KEY ("model_question_id") REFERENCES "model"."question" ("question_id");

ALTER TABLE "interview"."question" ADD CONSTRAINT "fk_25_1" FOREIGN KEY ("author_id") REFERENCES "interview"."author" ("author_id");

ALTER TABLE "interview"."answer" ADD CONSTRAINT "fk_answer_question" FOREIGN KEY ("question_id") REFERENCES "interview"."question" ("question_id");

ALTER TABLE "interview"."answer" ADD CONSTRAINT "fk_answer_respondent" FOREIGN KEY ("respondent_id") REFERENCES "interview"."respondent" ("respondent_id");

ALTER TABLE "interview"."question" ADD CONSTRAINT "fk_interview_id" FOREIGN KEY ("interview_id") REFERENCES "client"."interview" ("interview_id");

ALTER TABLE "interview"."answer_in_progress" ADD CONSTRAINT "fk_progress_question" FOREIGN KEY ("question_id") REFERENCES "interview"."question" ("question_id");

ALTER TABLE "interview"."question_response_score" ADD CONSTRAINT "fk_response_score_question" FOREIGN KEY ("question_id") REFERENCES "interview"."question" ("question_id");

ALTER TABLE "model"."discovery" ADD CONSTRAINT "fk_25_2" FOREIGN KEY ("industry_hash_id") REFERENCES "reference"."industry" ("industry_hash_id");

ALTER TABLE "model"."discovery" ADD CONSTRAINT "fk_discovery_author" FOREIGN KEY ("author_id") REFERENCES "model"."author" ("author_id");

ALTER TABLE "model"."discovery" ADD CONSTRAINT "fk_discovery_function" FOREIGN KEY ("function_id") REFERENCES "model"."business_function" ("function_id");

ALTER TABLE "model"."discovery" ADD CONSTRAINT "fk_discovery_role" FOREIGN KEY ("role_id") REFERENCES "model"."role" ("role_id");

ALTER TABLE "model"."question" ADD CONSTRAINT "fk_question_author" FOREIGN KEY ("author_id") REFERENCES "model"."author" ("author_id");

ALTER TABLE "model"."question" ADD CONSTRAINT "fk_question_model" FOREIGN KEY ("model_id") REFERENCES "model"."discovery" ("model_id");

ALTER TABLE "stage"."model" ADD CONSTRAINT "fk_31_2" FOREIGN KEY ("industry_hash_id") REFERENCES "reference"."industry" ("industry_hash_id");

ALTER TABLE "stage"."model_question" ADD CONSTRAINT "fk_31_3" FOREIGN KEY ("industry_hash_id") REFERENCES "reference"."industry" ("industry_hash_id");

ALTER TABLE "interview"."question_redirect" ADD CONSTRAINT "fk_referral_01" FOREIGN KEY ("question_id") REFERENCES "interview"."question" ("question_id");

ALTER TABLE "interview"."summary_control" ADD CONSTRAINT "fk_respondent_01" FOREIGN KEY ("respondent_id") REFERENCES "interview"."respondent" ("respondent_id");

ALTER TABLE "stage"."model" ADD CONSTRAINT "fk_32_4" FOREIGN KEY ("author_id") REFERENCES "admin"."author" ("author_id");

ALTER TABLE "model"."discovery" ADD CONSTRAINT "fk_discovery_project" FOREIGN KEY ("project_id") REFERENCES "admin"."project" ("project_id");

ALTER TABLE "client"."interview" ADD CONSTRAINT "fk_client_project" FOREIGN KEY ("project_id") REFERENCES "admin"."project" ("project_id");

ALTER TABLE "analysis"."solution_in_use_by_topic" ADD FOREIGN KEY ("by_topic_id") REFERENCES "analysis"."summary_by_topic" ("by_topic_id");

ALTER TABLE "analysis"."data_flow_by_topic" ADD FOREIGN KEY ("by_topic_id") REFERENCES "analysis"."summary_by_topic" ("by_topic_id");

ALTER TABLE "interview"."followup_question_by_topic" ADD FOREIGN KEY ("by_topic_id") REFERENCES "analysis"."summary_by_topic" ("by_topic_id");

ALTER TABLE "analysis"."summary_by_topic" ADD FOREIGN KEY ("control_id") REFERENCES "interview"."summary_control" ("control_id");

ALTER TABLE "analysis"."summary_by_interivew" ADD FOREIGN KEY ("control_id") REFERENCES "interview"."summary_control" ("control_id");

ALTER TABLE "interview"."followup_answer" ADD FOREIGN KEY ("question_id") REFERENCES "interview"."followup_question_by_topic" ("question_id");

ALTER TABLE "analysis"."by_topic_review" ADD FOREIGN KEY ("by_topic_id") REFERENCES "analysis"."summary_by_topic" ("by_topic_id");

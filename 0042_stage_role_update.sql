ALTER TABLE stage.contact ALTER COLUMN title_ TYPE VARCHAR(128);
ALTER TABLE stage.contact ALTER COLUMN role_ TYPE VARCHAR(64);

ALTER TABLE reference.location
ADD CONSTRAINT location_hash_id_unique UNIQUE (location_hash_id);

ALTER TABLE reference.location
ADD PRIMARY KEY (location_hash_id);


CREATE TABLE IF NOT EXISTS stage.role
(
    email_ character varying(96) COLLATE pg_catalog."default" NOT NULL,
    job_title character varying(255) COLLATE pg_catalog."default" NOT NULL,
    job_role character varying(128) COLLATE pg_catalog."default",
    job_role_detail jsonb NOT NULL,
    create_date date NOT NULL,
    created_by character varying(96) COLLATE pg_catalog."default" NOT NULL,
    source_ character varying(96) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT pk_role_email PRIMARY KEY (email_)
)

TABLESPACE pg_default;


CREATE OR REPLACE PROCEDURE stage.up_insert_role(
    p_email VARCHAR(96),
    p_job_title VARCHAR(255),
    p_job_role VARCHAR(128),
    p_job_role_detail JSONB,
    p_create_date DATE,
    p_created_by VARCHAR(96),
    p_source VARCHAR(96)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Insert the new record into stage.role
    INSERT INTO stage.role (
        email_, job_title, job_role, job_role_detail, 
        create_date, created_by, source_
    ) VALUES (
        p_email, p_job_title, p_job_role, p_job_role_detail,
        p_create_date, p_created_by, p_source
    )
    ON CONFLICT (email_) DO UPDATE
    SET
        job_title = EXCLUDED.job_title,
        job_role = EXCLUDED.job_role,
        job_role_detail = EXCLUDED.job_role_detail,
        create_date = EXCLUDED.create_date,
        created_by = EXCLUDED.created_by,
        source_ = EXCLUDED.source_;
END;
$$;

SELECT 'stage_role table and procedure created' as status_;

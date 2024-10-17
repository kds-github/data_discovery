
--clean up model data staging 
DELETE FROM stage.model;
DELETE FROM stage.model_question;
DELETE FROM stage.contact;
DELETE FROM stage.business_unit;
DELETE FROM stage.subsidiary;
DELETE FROM stage.parent;
DELETE FROM stage.industry;

INSERT into stage.industry (nasic_code, description_, source_)
SELECT nasic_code, description_, 'kds_discovery_admin' FROM load.industry;

--load client "real-like" data
INSERT INTO stage.parent
(
    name_, 
    organization_type, 
    ticker_, 
    nasic_code, 
    product_service, 
    annual_revenue, 
    employee_total, 
    website_, 
    location_, 
    source_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by
)
VALUES 
(
    'Global Logistics Solutions LLC',  -- New name
    'For Profit',                      -- Updated organization type
    'GLS',                             -- New ticker
    '561910',                          -- NASIC code unchanged
    'Packaging and Shipping Services', -- Updated product/service
    24500000.75,                       -- New annual revenue
    250,                               -- New employee total
    'www.globallogistics.com',         -- New website
    'Chicago, IL',                     -- New location
    'kds_discovery_user',              -- Updated source
    CURRENT_DATE,                      -- Current date for create_date
    'system_admin',                    -- Created by system admin
    NULL,                              -- No modification date yet
    NULL                               -- No modified by yet
);

INSERT INTO stage.subsidiary
(
    name_, 
    parent_name, 
    organization_type, 
    ticker_, 
    nasic_code, 
    product_service, 
    annual_revenue, 
    employee_total, 
    website_, 
    location_, 
    source_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by
)
VALUES 
(
    'Midwest Logistics Services Inc.', -- New subsidiary name
 'Global Logistics Solutions LLC',  -- Updated parent to match new parent data
 
    'For Profit',                      -- Updated organization type
    'MLS',                             -- New ticker
    '561910',                          -- NASIC code unchanged
    'Regional Packaging and Shipping', -- Updated product/service
    8500000.00,                        -- Updated annual revenue
    60,                                -- Updated employee total
    'www.midwestlogistics.com',        -- New website
    'Indianapolis, IN',                -- New location
    'kds_discovery_user',              -- Updated source
    CURRENT_DATE,                      -- Current date for create_date
    'system_admin',                    -- Created by system admin
    NULL,                              -- No modification date yet
    NULL                               -- No modified by yet
);

INSERT INTO stage.subsidiary
(
    name_ ,
    parent_name, 
    organization_type, 
    ticker_, 
    nasic_code, 
    product_service, 
    annual_revenue, 
    employee_total, 
    website_, 
    location_, 
    source_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by
)
VALUES 
(
     'West Coast Shipping Co.',         -- New subsidiary name
 'Global Logistics Solutions LLC',  -- Parent company

    'For Profit',                      -- Organization type
    'WCS',                             -- Ticker
    '561910',                          -- NASIC code unchanged
    'Packaging and Distribution', -- Product/service
    12000000.00,                       -- Annual revenue
    90,                                -- Employee total
    'www.westcoastshipping.com',       -- Website
    'Los Angeles, CA',                 -- Location
    'kds_discovery_user',              -- Updated source
    CURRENT_DATE,                      -- Current date for create_date
    'system_admin',                    -- Created by system admin
    NULL,                              -- No modification date yet
    NULL                               -- No modified by yet
);

INSERT INTO stage.subsidiary
(
    name_ ,
    parent_name, 
    organization_type, 
    ticker_, 
    nasic_code, 
    product_service, 
    annual_revenue, 
    employee_total, 
    website_, 
    location_, 
    source_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by
)
VALUES 
(
    'Southern Logistics Group',        -- New subsidiary name
	'Global Logistics Solutions LLC',  -- Parent company
    'For Profit',                      -- Organization type
    'SLG',                             -- Ticker
    '561910',                          -- NASIC code unchanged
    'Logistics and Packaging', -- Product/service
    10000000.00,                       -- Annual revenue
    75,                                -- Employee total
    'www.southernlogistics.com',       -- Website
    'Atlanta, GA',                     -- Location
    'kds_discovery_user',              -- Updated source
    CURRENT_DATE,                      -- Current date for create_date
    'system_admin',                    -- Created by system admin
    NULL,                              -- No modification date yet
    NULL                               -- No modified by yet
);


ALTER TABLE stage.business_unit ADD COLUMN model_reference  varchar(38) NULL;

-- IT and Systems Unit
INSERT INTO stage.business_unit
(
    subsidiary_, 
    name_, 
	parent_,
    model_reference, 
    create_date, 
    created_by,
	source_
   
)
VALUES 
(
    'Midwest Logistics Services Inc.',  -- Subsidiary
    'IT and Systems Unit',              -- Business unit name
	'Global Logistics Solutions LLC',  --parent
    'fab98eb8-7d02-42de-9405-a08cc1d9171c',  -- Model reference
    CURRENT_DATE,                      -- Current date
    'system_admin',                    -- Created by
    'kds_discovery_user'
);

-- Operations Unit
INSERT INTO stage.business_unit
(
    subsidiary_, 
    name_, 
	parent_,
    model_reference, 
    create_date, 
    created_by, 
    source_
)
VALUES 
(
    'Midwest Logistics Services Inc.',  -- Subsidiary
    'Operations Unit',                  -- Business unit name
	'Global Logistics Solutions LLC',  --parent
    'a3a14b6c-b1de-4730-b64c-5cb4ce68b150',  -- Model reference
    CURRENT_DATE,                      -- Current date
    'system_admin',                    -- Created by
    'kds_discovery_user'
);

-- Customer Support and Service Unit
INSERT INTO stage.business_unit
(
    subsidiary_, 
    name_, 
	parent_,
    model_reference, 
    create_date, 
    created_by, 
	source_
)
VALUES 
(
    'Midwest Logistics Services Inc.',  -- Subsidiary
    'Customer Support and Service Unit', -- Business unit name
	'Global Logistics Solutions LLC',  --parent
    '88c31f8c-97ae-4129-9d8d-96cd4de9f4aa',  -- Model reference
    CURRENT_DATE,                      -- Current date
    'system_admin',                    -- Created by
    'kds_discovery_user'
);

-- Research and Development Unit
INSERT INTO stage.business_unit
(
    subsidiary_, 
    name_, 
	parent_,
    model_reference, 
    create_date, 
    created_by,
	source_
)
VALUES 
(
    'Midwest Logistics Services Inc.',  -- Subsidiary
    'Research and Development Unit',    -- Business unit name
	'Global Logistics Solutions LLC',  --parent
    '192aa97a-2570-4de2-a4a9-6966c5f318da',  -- Model reference
    CURRENT_DATE,                      -- Current date
    'system_admin',                    -- Created by
    'kds_discovery_user'
);

-- Sales and Marketing Unit
INSERT INTO stage.business_unit
(
    subsidiary_, 
    name_, 
	parent_,
    model_reference, 
    create_date, 
    created_by, 
    source_
)
VALUES 
(
    'Midwest Logistics Services Inc.',  -- Subsidiary
    'Sales and Marketing Unit',         -- Business unit name
	'Global Logistics Solutions LLC',  --parent
    '52544d1f-40c8-44c8-9ead-c74edad952c1',  -- Model reference
    CURRENT_DATE,                      -- Current date
    'system_admin',                    -- Created by
	'kds_discovery_user'
    
);

-- Packaging and Labeling Unit
INSERT INTO stage.business_unit
(
    subsidiary_, 
    name_, 
	parent_,
    model_reference, 
    create_date, 
    created_by,
	source_
)
VALUES 
(
    'Midwest Logistics Services Inc.',  -- Subsidiary
    'Packaging and Labeling Unit',      -- Business unit name
	'Global Logistics Solutions LLC',  --parent
    '33962cb3-5710-4e64-b214-ab81acd9bfa8',  -- Model reference
    CURRENT_DATE,                      -- Current date
    'system_admin',                    -- Created by
    'kds_discovery_user'
);

-- Supply Chain Management Unit
INSERT INTO stage.business_unit
(
    subsidiary_, 
    name_, 
	parent_,
    model_reference, 
    create_date, 
    created_by,
	source_
)
VALUES 
(
    'Midwest Logistics Services Inc.',  -- Subsidiary
    'Supply Chain Management Unit',     -- Business unit name
	'Global Logistics Solutions LLC',  --parent
    '9caea67e-a2aa-4109-a2c5-863fe5a8b17b',  -- Model reference
    CURRENT_DATE,                      -- Current date
    'system_admin',                    -- Created by
    'kds_discovery_user'
);

-- Finance and Accounting Unit
INSERT INTO stage.business_unit
(
    subsidiary_, 
    name_, 
	parent_,
    model_reference, 
    create_date, 
    created_by, 
    source_
)
VALUES 
(
    'Midwest Logistics Services Inc.',  -- Subsidiary
    'Finance and Accounting Unit',      -- Business unit name
	'Global Logistics Solutions LLC',  --parent
    '2c86132b-d7cf-4c35-accf-9b8883df913c',  -- Model reference
    CURRENT_DATE,                      -- Current date
    'system_admin',                    -- Created by
    'kds_discovery_user'
);

-- Human Resources Unit
INSERT INTO stage.business_unit
(
    subsidiary_, 
    name_, 
	parent_,
    model_reference, 
    create_date, 
    created_by,
	source_
)
VALUES 
(
    'Midwest Logistics Services Inc.',  -- Subsidiary
    'Human Resources Unit',             -- Business unit name
	'Global Logistics Solutions LLC',  --parent
    '2e626790-5ff1-4485-8495-2bb0374ada93',  -- Model reference
    CURRENT_DATE,                      -- Current date
    'system_admin',                    -- Created by
    'kds_discovery_user'
);


-- IT and Systems Unit
INSERT INTO stage.contact
(
    email_, 
    parent_, 
    business_unit, 
    subsidiary_, 
    title_, 
    role_, 
    respondent_, 
    project_sponsor, 
    first_name, 
    last_name, 
    location_reference, 
    phone_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by, 
    source_
)
VALUES 
(
    'john.doe@globallogistics.com',        -- Email
    'Global Logistics Solutions LLC',       -- Parent company
    'IT and Systems Unit',                  -- Business unit
    'Midwest Logistics Services Inc.',      -- Subsidiary
    'Chief Information Officer',            -- Title
    'IT Lead',                              -- Role
    TRUE,                                   -- Respondent
    TRUE,                                   -- Project sponsor
    'John',                                 -- First name
    'Doe',                                  -- Last name
    'Chicago, IL',                          -- Location reference
    '555-123-4561',                         -- Phone
    CURRENT_DATE,                           -- Create date
    'system_admin',                         -- Created by
    NULL,                                   -- Modified date
    NULL,                                   -- Modified by
    'kds_discovery_user'                    -- Source
);

-- Operations Unit
INSERT INTO stage.contact
(
    email_, 
    parent_, 
    business_unit, 
    subsidiary_, 
    title_, 
    role_, 
    respondent_, 
    project_sponsor, 
    first_name, 
    last_name, 
    location_reference, 
    phone_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by, 
    source_
)
VALUES 
(
    'jane.smith@globallogistics.com',       -- Email
    'Global Logistics Solutions LLC',       -- Parent company
    'Operations Unit',                      -- Business unit
    'Midwest Logistics Services Inc.',      -- Subsidiary
    'Operations Manager',                   -- Title
    'Operations Lead',                      -- Role
    TRUE,                                   -- Respondent
    FALSE,                                  -- Project sponsor
    'Jane',                                 -- First name
    'Smith',                                -- Last name
    'Indianapolis, IN',                     -- Location reference
    '555-123-4562',                         -- Phone
    CURRENT_DATE,                           -- Create date
    'system_admin',                         -- Created by
    NULL,                                   -- Modified date
    NULL,                                   -- Modified by
    'kds_discovery_user'                    -- Source
);

-- Customer Support and Service Unit
INSERT INTO stage.contact
(
    email_, 
    parent_, 
    business_unit, 
    subsidiary_, 
    title_, 
    role_, 
    respondent_, 
    project_sponsor, 
    first_name, 
    last_name, 
    location_reference, 
    phone_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by, 
    source_
)
VALUES 
(
    'michael.brown@globallogistics.com',    -- Email
    'Global Logistics Solutions LLC',       -- Parent company
    'Customer Support and Service Unit',    -- Business unit
    'Midwest Logistics Services Inc.',      -- Subsidiary
    'Customer Service Manager',             -- Title
    'Support Lead',                         -- Role
    TRUE,                                   -- Respondent
    FALSE,                                  -- Project sponsor
    'Michael',                              -- First name
    'Brown',                                -- Last name
    'Chicago, IL',                          -- Location reference
    '555-123-4563',                         -- Phone
    CURRENT_DATE,                           -- Create date
    'system_admin',                         -- Created by
    NULL,                                   -- Modified date
    NULL,                                   -- Modified by
    'kds_discovery_user'                    -- Source
);

-- Research and Development Unit
INSERT INTO stage.contact
(
    email_, 
    parent_, 
    business_unit, 
    subsidiary_, 
    title_, 
    role_, 
    respondent_, 
    project_sponsor, 
    first_name, 
    last_name, 
    location_reference, 
    phone_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by, 
    source_
)
VALUES 
(
    'emily.johnson@globallogistics.com',    -- Email
    'Global Logistics Solutions LLC',       -- Parent company
    'Research and Development Unit',        -- Business unit
    'Midwest Logistics Services Inc.',      -- Subsidiary
    'R&D Manager',                          -- Title
    'R&D Lead',                             -- Role
    TRUE,                                   -- Respondent
    TRUE,                                   -- Project sponsor
    'Emily',                                -- First name
    'Johnson',                              -- Last name
    'Indianapolis, IN',                     -- Location reference
    '555-123-4564',                         -- Phone
    CURRENT_DATE,                           -- Create date
    'system_admin',                         -- Created by
    NULL,                                   -- Modified date
    NULL,                                   -- Modified by
    'kds_discovery_user'                    -- Source
);

-- Sales and Marketing Unit
INSERT INTO stage.contact
(
    email_, 
    parent_, 
    business_unit, 
    subsidiary_, 
    title_, 
    role_, 
    respondent_, 
    project_sponsor, 
    first_name, 
    last_name, 
    location_reference, 
    phone_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by, 
    source_
)
VALUES 
(
    'danielle.lee@globallogistics.com',     -- Email
    'Global Logistics Solutions LLC',       -- Parent company
    'Sales and Marketing Unit',             -- Business unit
    'Midwest Logistics Services Inc.',      -- Subsidiary
    'Sales Director',                       -- Title
    'Sales Lead',                           -- Role
    TRUE,                                   -- Respondent
    FALSE,                                  -- Project sponsor
    'Danielle',                             -- First name
    'Lee',                                  -- Last name
    'Chicago, IL',                          -- Location reference
    '555-123-4565',                         -- Phone
    CURRENT_DATE,                           -- Create date
    'system_admin',                         -- Created by
    NULL,                                   -- Modified date
    NULL,                                   -- Modified by
    'kds_discovery_user'                    -- Source
);

-- Packaging and Labeling Unit
INSERT INTO stage.contact
(
    email_, 
    parent_, 
    business_unit, 
    subsidiary_, 
    title_, 
    role_, 
    respondent_, 
    project_sponsor, 
    first_name, 
    last_name, 
    location_reference, 
    phone_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by, 
    source_
)
VALUES 
(
    'kevin.wilson@globallogistics.com',     -- Email
    'Global Logistics Solutions LLC',       -- Parent company
    'Packaging and Labeling Unit',          -- Business unit
    'Midwest Logistics Services Inc.',      -- Subsidiary
    'Packaging Manager',                    -- Title
    'Packaging Lead',                       -- Role
    TRUE,                                   -- Respondent
    FALSE,                                  -- Project sponsor
    'Kevin',                                -- First name
    'Wilson',                               -- Last name
    'Indianapolis, IN',                     -- Location reference
    '555-123-4566',                         -- Phone
    CURRENT_DATE,                           -- Create date
    'system_admin',                         -- Created by
    NULL,                                   -- Modified date
    NULL,                                   -- Modified by
    'kds_discovery_user'                    -- Source
);

-- Supply Chain Management Unit
INSERT INTO stage.contact
(
    email_, 
    parent_, 
    business_unit, 
    subsidiary_, 
    title_, 
    role_, 
    respondent_, 
    project_sponsor, 
    first_name, 
    last_name, 
    location_reference, 
    phone_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by, 
    source_
)
VALUES 
(
    'sarah.martin@globallogistics.com',     -- Email
    'Global Logistics Solutions LLC',       -- Parent company
    'Supply Chain Management Unit',         -- Business unit
    'Midwest Logistics Services Inc.',      -- Subsidiary
    'Supply Chain Manager',                 -- Title
    'Supply Chain Lead',                    -- Role
    TRUE,                                   -- Respondent
    TRUE,                                   -- Project sponsor
    'Sarah',                                -- First name
    'Martin',                               -- Last name
    'Chicago, IL',                          -- Location reference
    '555-123-4567',                         -- Phone
    CURRENT_DATE,                           -- Create date
    'system_admin',                         -- Created by
    NULL,                                   -- Modified date
    NULL,                                   -- Modified by
    'kds_discovery_user'                    -- Source
);

-- Finance and Accounting Unit
INSERT INTO stage.contact
(
    email_, 
    parent_, 
    business_unit, 
    subsidiary_, 
    title_, 
    role_, 
    respondent_, 
    project_sponsor, 
    first_name, 
    last_name, 
    location_reference, 
    phone_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by, 
    source_
)
VALUES 
(
    'linda.white@globallogistics.com',      -- Email
    'Global Logistics Solutions LLC',       -- Parent company
    'Finance and Accounting Unit',          -- Business unit
    'Midwest Logistics Services Inc.',      -- Subsidiary
    'Finance Director',                     -- Title
    'Finance Lead',                         -- Role
    TRUE,                                   -- Respondent
    FALSE,                                  -- Project sponsor
    'Linda',                                -- First name
    'White',                                -- Last name
    'Indianapolis, IN',                     -- Location reference
    '555-123-4568',                         -- Phone
    CURRENT_DATE,                           -- Create date
    'system_admin',                         -- Created by
    NULL,                                   -- Modified date
    NULL,                                   -- Modified by
    'kds_discovery_user'                    -- Source
);

-- Human Resources Unit
INSERT INTO stage.contact
(
    email_, 
    parent_, 
    business_unit, 
    subsidiary_, 
    title_, 
    role_, 
    respondent_, 
    project_sponsor, 
    first_name, 
    last_name, 
    location_reference, 
    phone_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by, 
    source_
)
VALUES 
(
    'nancy.green@globallogistics.com',      -- Email
    'Global Logistics Solutions LLC',       -- Parent company
    'Human Resources Unit',                 -- Business unit
    'Midwest Logistics Services Inc.',      -- Subsidiary
    'HR Director',                          -- Title
    'HR Lead',                              -- Role
    TRUE,                                   -- Respondent
    FALSE,                                  -- Project sponsor
    'Nancy',                                -- First name
    'Green',                                -- Last name
    'Chicago, IL',                          -- Location reference
    '555-123-4569',                         -- Phone
    CURRENT_DATE,                           -- Create date
    'system_admin',                         -- Created by
    NULL,                                   -- Modified date
    NULL,                                   -- Modified by
    'kds_discovery_user'                    -- Source
);

SELECT  'stage schema REAL-WORLD like data loaded...'  as status_;











/*SELECT * FROM load.parent;
SELECT * FROM load.subsidiary;
SELECT * FROM load.business_unit;
SELECT * FROM load.contact;

SELECT * FROM load.industry ORDER by 2;
SELECT * FROM load.model;
SELECT * FROM load.model_question;
*/

INSERT INTO load.parent
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
    'Global Distributors Inc.', 
    'Model', 
    'GDI', 
    '561910', 
    'Packaging and Labeling Services', 
    15000000.50, 
    120, 
    'www.globaldistributors.com', 
    'New York, NY', 
    'Data Source 1', 
    CURRENT_DATE, 
    'system_admin', 
    NULL, 
    NULL
);

--SELECT * from load.parent;


INSERT INTO load.subsidiary
(
    parent_, 
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
    'Global Distributors Inc.', 
    'East Coast Distributors LLC', 
    'Model', 
    NULL, 
    '561910', 
    'Regional Packaging and Labeling', 
    5000000.00, 
    45, 
    'www.eastcoastdistributors.com', 
    'Boston, MA', 
    'Data Source 1', 
    CURRENT_DATE, 
    'system_admin', 
    NULL, 
    NULL
);


--SELECT * FROM load.subsidiary;

-- Insert statement for the Operations Unit
INSERT INTO load.business_unit
(
    name_, 
    parent_, 
    subsidiary_, 
    nasic_code, 
    model_reference, 
    create_date, 
    created_by, 
    source_
)
VALUES 
(
    'Operations Unit', 
    'Global Distributors Inc.', 
    NULL, 
    '561910', 
    '', 
    CURRENT_DATE, 
    'system_admin', 
    'Data Source 1'
);

-- Insert statement for the Packaging and Labeling Unit
INSERT INTO load.business_unit
(
    name_, 
    parent_, 
    subsidiary_, 
    nasic_code, 
    model_reference, 
    create_date, 
    created_by, 
    source_
)
VALUES 
(
    'Packaging and Labeling Unit', 
    'Global Distributors Inc.', 
    NULL, 
    '561910', 
    '', 
    CURRENT_DATE, 
    'system_admin', 
    'Data Source 1'
);

-- Insert statement for the Sales and Marketing Unit
INSERT INTO load.business_unit
(
    name_, 
    parent_, 
    subsidiary_, 
    nasic_code, 
    model_reference, 
    create_date, 
    created_by, 
    source_
)
VALUES 
(
    'Sales and Marketing Unit', 
    'Global Distributors Inc.', 
    NULL, 
    '561910', 
    '', 
    CURRENT_DATE, 
    'system_admin', 
    'Data Source 1'
);

-- Insert statement for the Supply Chain Management Unit
INSERT INTO load.business_unit
(
    name_, 
    parent_, 
    subsidiary_, 
    nasic_code, 
    model_reference, 
    create_date, 
    created_by, 
    source_
)
VALUES 
(
    'Supply Chain Management Unit', 
    'Global Distributors Inc.', 
    NULL, 
    '561910', 
    '', 
    CURRENT_DATE, 
    'system_admin', 
    'Data Source 1'
);

-- Insert statement for the Finance and Accounting Unit
INSERT INTO load.business_unit
(
    name_, 
    parent_, 
    subsidiary_, 
    nasic_code, 
    model_reference, 
    create_date, 
    created_by, 
    source_
)
VALUES 
(
    'Finance and Accounting Unit', 
    'Global Distributors Inc.', 
    NULL, 
    '561910', 
    '', 
    CURRENT_DATE, 
    'system_admin', 
    'Data Source 1'
);

-- Insert statement for the IT and Systems Unit
INSERT INTO load.business_unit
(
    name_, 
    parent_, 
    subsidiary_, 
    nasic_code, 
    model_reference, 
    create_date, 
    created_by, 
    source_
)
VALUES 
(
    'IT and Systems Unit', 
    'Global Distributors Inc.', 
    NULL, 
    '561910', 
    '', 
    CURRENT_DATE, 
    'system_admin', 
    'Data Source 1'
);

-- Insert statement for the Human Resources (HR) Unit
INSERT INTO load.business_unit
(
    name_, 
    parent_, 
    subsidiary_, 
    nasic_code, 
    model_reference, 
    create_date, 
    created_by, 
    source_
)
VALUES 
(
    'Human Resources Unit', 
    'Global Distributors Inc.', 
    NULL, 
    '561910', 
    '', 
    CURRENT_DATE, 
    'system_admin', 
    'Data Source 1'
);

-- Insert statement for the Customer Support and Service Unit
INSERT INTO load.business_unit
(
    name_, 
    parent_, 
    subsidiary_, 
    nasic_code, 
    model_reference, 
    create_date, 
    created_by, 
    source_
)
VALUES 
(
    'Customer Support and Service Unit', 
    'Global Distributors Inc.', 
    NULL, 
    '561910', 
    '', 
    CURRENT_DATE, 
    'system_admin', 
    'Data Source 1'
);

-- Insert statement for the Research and Development (R&D) Unit
INSERT INTO load.business_unit
(
    name_, 
    parent_, 
    subsidiary_, 
    nasic_code, 
    model_reference, 
    create_date, 
    created_by, 
    source_
)
VALUES 
(
    'Research and Development Unit', 
    'Global Distributors Inc.', 
    NULL, 
    '561910', 
    '', 
    CURRENT_DATE, 
    'system_admin', 
    'Data Source 1'
);

--SELECT * FROM load.business_unit;

-- Insert statement for an Operations Manager in the Operations Unit
INSERT INTO load.contact
(
    email_, 
    parent_, 
    subsidiary_, 
    business_unit, 
    nasic_code, 
    title_, 
    role_, 
    respondent_, 
    project_sponsor, 
    first_name, 
    last_name, 
    location_, 
    phone_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by
)
VALUES 
(
    'operations.manager@globaldistributors.com', 
    'Global Distributors Inc.', 
    NULL, 
    'Operations Unit', 
    '561910', 
    'Operations Manager', 
    'Manager', 
    'Yes', 
    'No', 
    'John', 
    'Doe', 
    'New York, NY', 
    '555-123-4567', 
    CURRENT_DATE, 
    'system_admin', 
    NULL, 
    NULL
);

-- Insert statement for a Packaging Manager in the Packaging and Labeling Unit
INSERT INTO load.contact
(
    email_, 
    parent_, 
    subsidiary_, 
    business_unit, 
    nasic_code, 
    title_, 
    role_, 
    respondent_, 
    project_sponsor, 
    first_name, 
    last_name, 
    location_, 
    phone_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by
)
VALUES 
(
    'packaging.manager@globaldistributors.com', 
    'Global Distributors Inc.', 
    NULL, 
    'Packaging and Labeling Unit', 
    '561910', 
    'Packaging Manager', 
    'Manager', 
    'Yes', 
    'No', 
    'Jane', 
    'Smith', 
    'Boston, MA', 
    '555-987-6543', 
    CURRENT_DATE, 
    'system_admin', 
    NULL, 
    NULL
);

-- Insert statement for a Sales Manager in the Sales and Marketing Unit
INSERT INTO load.contact
(
    email_, 
    parent_, 
    subsidiary_, 
    business_unit, 
    nasic_code, 
    title_, 
    role_, 
    respondent_, 
    project_sponsor, 
    first_name, 
    last_name, 
    location_, 
    phone_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by
)
VALUES 
(
    'sales.manager@globaldistributors.com', 
    'Global Distributors Inc.', 
    NULL, 
    'Sales and Marketing Unit', 
    '561910', 
    'Sales Manager', 
    'Manager', 
    'Yes', 
    'No', 
    'Michael', 
    'Johnson', 
    'Los Angeles, CA', 
    '555-456-7890', 
    CURRENT_DATE, 
    'system_admin', 
    NULL, 
    NULL
);

-- Insert statement for a Supply Chain Manager in the Supply Chain Management Unit
INSERT INTO load.contact
(
    email_, 
    parent_, 
    subsidiary_, 
    business_unit, 
    nasic_code, 
    title_, 
    role_, 
    respondent_, 
    project_sponsor, 
    first_name, 
    last_name, 
    location_, 
    phone_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by
)
VALUES 
(
    'supplychain.manager@globaldistributors.com', 
    'Global Distributors Inc.', 
    NULL, 
    'Supply Chain Management Unit', 
    '561910', 
    'Supply Chain Manager', 
    'Manager', 
    'Yes', 
    'No', 
    'Emily', 
    'Davis', 
    'Chicago, IL', 
    '555-321-6548',   
	CURRENT_DATE, 
    'system_admin', 
    NULL, 
    NULL
);

-- Insert statement for a Financial Analyst in the Finance and Accounting Unit
INSERT INTO load.contact
(
    email_, 
    parent_, 
    subsidiary_, 
    business_unit, 
    nasic_code, 
    title_, 
    role_, 
    respondent_, 
    project_sponsor, 
    first_name, 
    last_name, 
    location_, 
    phone_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by
)
VALUES 
(
    'financial.analyst@globaldistributors.com', 
    'Global Distributors Inc.', 
    NULL, 
    'Finance and Accounting Unit', 
    '561910', 
    'Financial Analyst', 
    'Analyst', 
    'Yes', 
    'No', 
    'Sarah', 
    'Brown', 
    'Houston, TX', 
    '555-654-9870', 
    CURRENT_DATE, 
    'system_admin', 
    NULL, 
    NULL
);

-- Insert statement for an IT Manager in the IT and Systems Unit
INSERT INTO load.contact
(
    email_, 
    parent_, 
    subsidiary_, 
    business_unit, 
    nasic_code, 
    title_, 
    role_, 
    respondent_, 
    project_sponsor, 
    first_name, 
    last_name, 
    location_, 
    phone_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by
)
VALUES 
(
    'it.manager@globaldistributors.com', 
    'Global Distributors Inc.', 
    NULL, 
    'IT and Systems Unit', 
    '561910', 
    'IT Manager', 
    'Manager', 
    'Yes', 
    'No', 
    'David', 
    'White', 
    'Seattle, WA', 
    '555-789-0123', 
    CURRENT_DATE, 
    'system_admin', 
    NULL, 
    NULL
);

-- Insert statement for an HR Manager in the Human Resources (HR) Unit
INSERT INTO load.contact
(
    email_, 
    parent_, 
    subsidiary_, 
    business_unit, 
    nasic_code, 
    title_, 
    role_, 
    respondent_, 
    project_sponsor, 
    first_name, 
    last_name, 
    location_, 
    phone_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by
)
VALUES 
(
    'hr.manager@globaldistributors.com', 
    'Global Distributors Inc.', 
    NULL, 
    'Human Resources Unit', 
    '561910', 
    'HR Manager', 
    'Manager', 
    'Yes', 
    'No', 
    'Lisa', 
    'Martinez', 
    'Miami, FL', 
    '555-012-3456', 
    CURRENT_DATE, 
    'system_admin', 
    NULL, 
    NULL
);

-- Insert statement for a Customer Support Manager in the Customer Support and Service Unit
INSERT INTO load.contact
(
    email_, 
    parent_, 
    subsidiary_, 
    business_unit, 
    nasic_code, 
    title_, 
    role_, 
    respondent_, 
    project_sponsor, 
    first_name, 
    last_name, 
    location_, 
    phone_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by
)
VALUES 
(
    'support.manager@globaldistributors.com', 
    'Global Distributors Inc.', 
    NULL, 
    'Customer Support and Service Unit', 
    '561910', 
    'Customer Support Manager', 
    'Manager', 
    'Yes', 
    'No', 
    'Mark', 
    'Garcia', 
    'San Francisco, CA', 
    '555-987-1234', 
    CURRENT_DATE, 
    'system_admin', 
    NULL, 
    NULL
);

-- Insert statement for an R&D Manager in the Research and Development (R&D) Unit
INSERT INTO load.contact
(
    email_, 
    parent_, 
    subsidiary_, 
    business_unit, 
    nasic_code, 
    title_, 
    role_, 
    respondent_, 
    project_sponsor, 
    first_name, 
    last_name, 
    location_, 
    phone_, 
    create_date, 
    created_by, 
    modified_date, 
    modified_by
)
VALUES 
(
    'rd.manager@globaldistributors.com', 
    'Global Distributors Inc.', 
    NULL, 
    'Research and Development Unit', 
    '561910', 
    'R&D Manager', 
    'Manager', 
    'Yes', 
    'No', 
    'Nancy', 
    'Hernandez', 
    'Phoenix, AZ', 
    '555-654-3210', 
    CURRENT_DATE, 
    'system_admin', 
    NULL, 
    NULL
);

--SELECT * FROM load.contact;

-- Insert statement for Operations Unit, Manager role

INSERT INTO load.model (nasic_code, biz_unit, role_, create_date, created_by, source_)
SELECT DISTINCT nasic_code, business_unit, role_, CURRENT_DATE, 'system_admin', 'model_01'
FROM load.contact;

--SELECT * FROM load.model;

-- Insert statement for Question 1: Primary data sources
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Primary Data Sources', 
    'Data Sources', 
    NULL, 
    'What are the primary data sources you rely on to perform your job in the Sales and Marketing Unit?', 
    'Ask the manager to identify key data sources.', 
    'Open-ended', 
    1, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 2: Data origins
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Primary Data Sources', 
    'Data Origins', 
    NULL, 
    'Where does the majority of your sales and marketing data originate from (e.g., CRM systems, third-party data, market reports)?', 
    'Explore the data origins in their current role.', 
    'Open-ended', 
    2, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 3: Data accuracy
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Primary Data Sources', 
    'Data Quality', 
    NULL, 
    'How do you verify the quality and accuracy of the data you work with?', 
    'Ask the manager how they ensure data accuracy.', 
    'Open-ended', 
    3, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 4: Tools for data acquisition
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Data Acquisition Tools', 
    'Tools', 
    NULL, 
    'What tools or platforms do you use to acquire or access your sales and marketing data (e.g., CRM, ERP, data lakes)?', 
    'Identify the tools used for data acquisition.', 
    'Open-ended', 
    4, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 5: Tools usability
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Data Acquisition Tools', 
    'Usability', 
    NULL, 
    'How user-friendly are the tools you use to collect and manage your data? Are there any limitations?', 
    'Understand tool usability and limitations.', 
    'Open-ended', 
    5, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 6: Data usage in decision-making
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Data Usage', 
    'Decision Making', 
    NULL, 
    'How is the sales and marketing data you gather used in decision-making within your unit?', 
    'Investigate the role of data in decision-making.', 
    'Open-ended', 
    6, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 7: Example of data-driven strategy
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Data Usage', 
    'Strategy', 
    NULL, 
    'Can you describe a recent example where the data played a crucial role in shaping a sales or marketing strategy?', 
    'Explore data’s impact on strategy.', 
    'Open-ended', 
    7, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 8: Key KPIs and metrics
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Data Usage', 
    'Metrics', 
    NULL, 
    'Are there specific KPIs or metrics that are essential to track from your data sources?', 
    'Discover important KPIs and metrics.', 
    'Open-ended', 
    8, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 9: Data frequency
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Data Frequency and Volume', 
    'Frequency', 
    NULL, 
    'How frequently do you receive new data or update your existing datasets (e.g., daily, weekly, real-time)?', 
    'Identify data frequency and update patterns.', 
    'Open-ended', 
    9, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 10: Data volume
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Data Frequency and Volume', 
    'Volume', 
    NULL, 
    'On average, how much data do you work with daily or weekly? Is it growing, and if so, by how much?', 
    'Determine the volume of data handled regularly.', 
    'Open-ended', 
    10, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 11: Data Integration with other departments
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Data Integration', 
    'Cross-Department', 
    NULL, 
    'Does your team integrate sales and marketing data with data from other departments like operations, finance, or supply chain? If yes, how?', 
    'Investigate how cross-departmental data integration occurs.', 
    'Open-ended', 
    11, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 12: Impact of integration on work
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Data Integration', 
    'Impact', 
    NULL, 
    'How do these integrations enhance or complicate your work in sales and marketing?', 
    'Explore the effects of data integration on workflow.', 
    'Open-ended', 
    12, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 13: Challenges with external data integration
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Data Integration', 
    'External Data', 
    NULL, 
    'Are there any challenges you face when integrating external or third-party data sources into your systems?', 
    'Identify obstacles in integrating third-party data.', 
    'Open-ended', 
    13, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 14: Strengths of current data sources
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Data Strengths and Weaknesses', 
    'Strengths', 
    NULL, 
    'What do you consider to be the greatest strength of the current data sources and tools you use?', 
    'Ask the manager to identify the strengths of their data tools.', 
    'Open-ended', 
    14, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 15: Weaknesses of current data sources
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Data Strengths and Weaknesses', 
    'Weaknesses', 
    NULL, 
    'Are there any weaknesses or gaps in the data that you feel need to be addressed to improve performance?', 
    'Explore the limitations or shortcomings in current data sources.', 
    'Open-ended', 
    15, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 16: Data completeness and accuracy issues
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Data Strengths and Weaknesses', 
    'Data Accuracy', 
    NULL, 
    'How often do you encounter incomplete or inaccurate data? What impact does it have on your operations?', 
    'Understand how data quality issues affect operations.', 
    'Open-ended', 
    16, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 17: Common issues with data
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Data Issues and Improvements', 
    'Common Issues', 
    NULL, 
    'What are the most common issues or obstacles you face when accessing or analyzing data?', 
    'Investigate recurring problems with data access or analysis.', 
    'Open-ended', 
    17, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 18: Data-related problem resolution
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Data Issues and Improvements', 
    'Resolution', 
    NULL, 
    'How do you currently resolve any data-related problems, and do you think there’s room for improvement?', 
    'Explore how data issues are resolved and potential improvements.', 
    'Open-ended', 
    18, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 19: Data security and privacy concerns
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Data Issues and Improvements', 
    'Security', 
    NULL, 
    'Have you experienced any data security or privacy concerns related to the sales and marketing data?', 
    'Understand security and privacy concerns.', 
    'Open-ended', 
    19, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);

-- Insert statement for Question 20: One desired change in data tools
INSERT INTO load.model_question
(
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
    location_reference, 
    create_date, 
    modified_date, 
    source_
)
VALUES 
(
    '561910', 
    'Sales and Marketing Unit', 
    'Manager', 
    'Data Issues and Improvements', 
    'Tool Improvement', 
    NULL, 
    'If you could change one thing about the data or tools you work with, what would it be and why?', 
    'Ask for suggestions to improve data tools.', 
    'Open-ended', 
    20, 
    NULL, 
    CURRENT_DATE, 
    NULL, 
    'InterviewScript'
);


--SELECT * FROM load.model_question;






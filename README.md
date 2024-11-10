# Chatbot Data Discovery Interview App

## Introduction

In today's data-centric world, organizations are searching for ways to unlock the full potential of their data. Data discovery, which involves finding, collecting, and analyzing data from various sources to uncover valuable insights, is crucial for this purpose.

However, traditional methods are often cumbersome and inefficient, relying on manual surveys, disparate data collection, and time-consuming interviews. Many organizations still depend on spreadsheets for data discovery, leading to fragmented and error-prone management.

To address these challenges, this project introduces a **Chatbot Data Discovery Interview App**, leveraging conversational AI to automate interviews, gather structured data, and reduce the time needed for data collection. The following sections will explore the workflow, database design, and key components of the application, using a wholesale distribution business as an example to illustrate the workflow and database schema.

## Workflow Description

### 1. Generating Model Interview Questions
The first step is generating model interview questions tailored to specific roles in various industries and business units. For example, a sales manager in a wholesale distribution business might be asked questions such as:

- What are the primary sources of data you use for your daily tasks (e.g., CRM systems, sales reports, customer feedback)?
- What specific tools or software do you use to acquire sales data (e.g., Salesforce, Excel, Power BI)?
- How do you collect customer interaction and sales performance data?
- Do you use any third-party data sources? If so, which ones?
- Are there any internal systems you rely on for data collection and analysis?
- How frequently do you access sales data (e.g., daily, weekly, monthly)?

### 2. Gathering Client Data
Once model questions are generated, the next step is to gather client data based on industry, business unit, and role. This allows the app to match client data with model data for accurate analysis results.

### 3. Conducting the Interview
The chatbot conducts interviews with client contacts, asking the generated data discovery questions. The responses are stored in a PostgreSQL database.

### 4. Data Analysis and Follow-Up
After data collection, the gathered information is analyzed for insights. Follow-up interviews may be scheduled based on the analysis to gather more detailed information or clarify responses.

## Database Design
![data discovery](kds_discovery-2024-09-03.png)

The database design supports the chatbot-based application with various schemas and tables to store and manage data effectively. Below is an overview of the key schemas and tables.

### Schemas
- **admin**: Stores administrative data.
- **analysis**: Stores analysis results.
- **client**: Manages client-related data.
- **interview**: Handles the interview process data.
- **model**: Stores model questions and related metadata.
- **reference**: Manages reference data.
- **load**: Stores data related to subsidiaries, parent organizations, industry, contacts, and business units.
- **stage**: Stores staging data before loading into the main schema, including data about subsidiaries, parent organizations, industries, contacts, and business units.

### Tables and Their Purposes

#### Model Tables
- **model.role**: Stores roles within the model (e.g., "Sales Manager").
- **model.business_unit**: Stores information about different business units.
- **model.industry**: Stores industry information using NASIC codes.
- **model.author**: Contains data about authors who create the interview questions.
- **model.interview**: Links roles, business units, industries, and authors to specific interview models.
- **model.question**: Stores interview questions and their metadata.

#### Client Tables
- **client.role**: Stores client-specific roles and associated data.
- **client.interview**: Contains client responses and links to model interview questions.

#### interview Tables
- **interview.schedule**: Tracks interview schedules.
- **interview.rating**: Stores ratings and conditions related to responses.
- **interview.question**: Contains detailed information about each question, including type, tags, and metadata.
- **interview.question_response_score**: Links questions to possible response scores.
- **interview.answer**: Stores the actual answers provided by respondents.
- **interview.answer_in_progress**: Tracks partial responses and answers in progress.

#### Load Tables
- **load.subsidiary**: Stores information about subsidiaries.
- **load.parent**: Stores information about parent organizations.
- **load.model_question**: Stores model questions.
- **load.model**: Stores model data related to business units, NASIC codes, and roles.
- **load.industry**: Stores industry descriptions.
- **load.contact**: Stores contact information related to organizations.
- **load.business_unit**: Stores information about business units.

#### Stage Tables
- **stage.subsidiary**: Stores subsidiary information.
- **stage.parent**: Stores parent organization data.
- **stage.model_question**: Stores model questions in JSONB format.
- **stage.model**: Stores model data including NASIC codes and business units.
- **stage.industry**: Stores industry information and NASIC codes.
- **stage.contact**: Stores contact details related to organizations.
- **stage.business_unit**: Stores business unit information and relationships to parent and subsidiary data.

## Database & APP Installation Notes 

To date ALL database development work has been done on PostgreSQL 14.13 on Linux Mint 21.3 Cinnamon. For help with installing PostgreSQL, [see](https://postgresql.org). Once installed,run "bash 0030_install_database.sh" from the command line in a local github cloned directory.

### Update 2024-10-02
 "bash 0030_install_database.sh" creates the "kds_discovery" database and loads the "load" schema with test model data. Follow that script with "bash 0034_stage_model_data.sh". It loads the "stage" and "model" schemas with data.
 ### Update 2024-10-17
 Follow "bash 0034_stage_model_data.sh"  with "bash 0038_client_interview_data.sh", this bash file runs three sql scripts for refreshing the model schema  and loading the client and interview schemas with "REAL-WORLD" like data. 
 ### Update 2024-11-07
 Next, run  "bash 0041_interview_answer_data.sh", this bash file runs two sql scripts that updates the interview and answer tables. It also creates a view and stored procedure.
  
### Installation Notes for Running `interview_form.py`
To date, APP development has been done with Python 3.10.12, ,[see](https://python.org).

Here are a few additional steps to take to make sure the python script `interview_form.py` will run:

#### In Windows
From the command line,
1. Create a Python Virtual Environment, from the command line,

    `python -m venv interview_env`

2. Activate the Virtual Environment

    `interview_env\Scripts\activate`

3. Install Required Modules

	`pip install Flask psycopg2-binary python-dotenv`

4. Create the .env File

	In the same directory as interview_form.py, create a .env file and add the necessary environment variables.

	Use the following format:

	`DBPASSWORD="password_goes_here"`  
	`DBDATADIR="/home/data_discovery/data/"`  
    	`DBSURVEY="kds_discovery"`  
    	`DBPORT="5432"`    
    	`DBUSER="postgres"`  
    	`DBHOST="NNN.NNN.N.NNN"`  
    	`OPENAPIKEY="openAPI_key_goes_here"`

6. Run the Application

	`python interview_form.py`

#### Linux Installation
From the command line,
1. Create a Python Virtual Environment

    `python3 -m venv interview_env`

2. Activate the Virtual Environment

    `source interview_env/bin/activate`

3. Install Required Modules

    `pip install Flask psycopg2-binary python-dotenv`

4. Create the .env File

    In the same directory as interview_form.py, create a .env file by running:

    `nano .env`

    Use this format:

    `DBPASSWORD="password_goes_here"`  
    `DBDATADIR="/home/data_discovery/data/"`  
    `DBSURVEY="kds_discovery"`  
    `DBPORT="5432"`    
    `DBUSER="postgres"`  
    `DBHOST="NNN.NNN.N.NNN"`  
    `OPENAPIKEY="openAPI_key_goes_here"`  

    Add the environment variables in the file, then save and exit (Ctrl + X, Y, Enter).

    Note: The .env file stores sensitive information like database credentials and API keys securely, accessed through python-dotenv.
    Ensure interview_form.py can access .env to read environment variables.

5. Run the Application

    `python3 interview_form.py`



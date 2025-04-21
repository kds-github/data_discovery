#!/bin/bash

# Main script
dbname="kds_discovery_2025"
ddl_script_dbdiagram="kds_discovery_2025_template.sql"
ddl_script_kds="template_synch.sql"
author_insert="admin_author_insert.sql"
prompt_insert="admin_prompt_insert.sql"


# Connect to PostgreSQL using hostname, username, password
psql -h $(hostname) -U postgres <<EOF
CREATE DATABASE $dbname;
\c $dbname;
$(cat "$ddl_script_dbdiagram")\g
$(cat "$ddl_script_kds")\g
$(cat "$author_insert")\g
$(cat "$prompt_insert")\g
\copy admin.project FROM 'admin_project.txt' DELIMITER E'\t' CSV HEADER;
\copy admin.gui_type FROM 'admin_gui_type.txt' DELIMITER E'\t' CSV HEADER;
\copy admin.prompt_type FROM 'admin_prompt_type.txt' DELIMITER E'\t' CSV HEADER;
\copy reference.industry FROM 'reference_industry.txt' DELIMITER E'\t' CSV HEADER;
EOF

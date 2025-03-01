#!/bin/bash

# Main script
dbname="kds_discovery_2025"
ddl_script_dbdiagram="kds_discovery_20250220.sql"
ddl_script_kds="kds_discovery_view_procedure_20250219.sql"

# Connect to PostgreSQL using hostname, username, password
psql -h $(hostname) -U postgres <<EOF
CREATE DATABASE $dbname;
\c $dbname;
$(cat "$ddl_script_dbdiagram")\g
$(cat "$ddl_script_kds")\g
\copy admin.project FROM 'admin_project.txt' DELIMITER E'\t' CSV HEADER;
\copy admin.gui_type FROM 'admin_gui_type.txt' DELIMITER E'\t' CSV HEADER;
\copy admin.prompt_setting FROM 'admin_prompt_setting.txt' DELIMITER E'\t' CSV HEADER;
\copy admin.prompt_type FROM 'admin_prompt_type.txt' DELIMITER E'\t' CSV HEADER;
\copy reference.industry FROM 'reference_industry.txt' DELIMITER E'\t' CSV HEADER;
EOF


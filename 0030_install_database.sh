#!/bin/bash

# Main script
dbname="kds_discovery"
ddl_script="kds_discovery_20240903.sql"
csv_file="industry_for_SQL.txt"
data_script="0032_load_schema_data.sql"

# Connect to PostgreSQL using hostname, username, password
psql -h $(hostname) -U postgres <<EOF
CREATE DATABASE $dbname;
\c $dbname;
$(cat "$ddl_script")\g
\copy load.industry FROM '$csv_file' WITH DELIMITER E'\\t' NULL AS '' CSV HEADER;
$(cat "$data_script")\g
EOF


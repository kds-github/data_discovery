#!/bin/bash

# Main script
dbname="kds_discovery"
data_stage_model="0033_stage_model_schema_data.sql"

# Connect to PostgreSQL using hostname, username, password
psql -h $(hostname) -U postgres <<EOF
\c $dbname;
$(cat "$data_stage_model")\g
EOF


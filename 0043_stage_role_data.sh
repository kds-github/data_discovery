#!/bin/bash

# Main script
dbname="kds_discovery"
sql_files=("0042_stage_role_update.sql")

# Connect to PostgreSQL and run all SQL files in a single session
psql -h $(hostname) -U postgres <<EOF
\c $dbname;

-- Loop over the SQL files and execute each one
$(for sql_file in "${sql_files[@]}"; do
    cat "$sql_file"
done)

EOF

echo "All SQL files have been executed in a single session."


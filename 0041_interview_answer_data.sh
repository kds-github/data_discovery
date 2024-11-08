#!/bin/bash

# Main script
dbname="kds_discovery"
sql_files=("0039_interview_question_update.sql" "0040_answer_update.sql")

# Connect to PostgreSQL and run all SQL files in a single session
psql -h $(hostname) -U postgres <<EOF
\c $dbname;

-- Loop over the SQL files and execute each one
$(for sql_file in "${sql_files[@]}"; do
    cat "$sql_file"
done)

\copy admin.gui_type FROM '/home/kds/data_discovery/gui_type.txt' CSV HEADER;
\copy admin.prompt_type FROM '/home/kds/data_discovery/question_type.txt' CSV HEADER;
EOF

echo "All SQL files have been executed in a single session."


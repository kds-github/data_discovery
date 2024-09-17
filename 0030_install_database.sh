#!/bin/bash

# Function to check if a database exists
function database_exists() {
    psql -t -c "SELECT 1 FROM pg_database WHERE datname = '$1'" > /dev/null 2>&1
}

# Function to create a new database
function create_database() {
    if ! database_exists "$1"; then
        psql -U postgres -c "CREATE DATABASE $1"
    fi
}

# Function to run a DDL script
function run_ddl_script() {
    psql -U postgres -c "$1"
}

# Function to copy a CSV file to a table
function copy_csv_to_table() {
    psql -c "\\copy load.industry(nasic_code, description_) FROM '$3' WITH DELIMITER E'\\t' NULL AS '' CSV HEADER;"
}

# Main script
dbname="kds_discovery"
ddl_script="kds_discovery_20240903.sql"
csv_file="nasic_six_digit_2022.csv"

# Prompt for admin password
read -s -p "Enter admin password: " admin_password

# Open psql command line with admin password
psql -U postgres -d "$dbname" -c "$admin_password"

# Create the new database
create_database "$dbname"

# Change to the new database
\c "$dbname"

# Run the DDL script
run_ddl_script "$(cat "$ddl_script")\g"

# Copy the CSV file to the table
copy_csv_to_table "$csv_file"


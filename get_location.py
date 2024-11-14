import os
import json
import requests
import hashlib
import psycopg2
from datetime import date
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Database connection variables

api_key = os.environ.get('GEOCODEAPIKEY')

# Connect to PostgreSQL database
def connect_db():
    return psycopg2.connect(
        dbname=os.getenv("DBSURVEY"),
        user=os.getenv("DBUSER"),
        password=os.getenv("DBPASSWORD"),
        host=os.getenv("DBHOST"),
        port=os.getenv("DBPORT")
    )

# Function to get coordinates from the Google Maps API
def get_coordinates(address, api_key):
    base_url = "https://maps.googleapis.com/maps/api/geocode/json"
    params = {"address": address, "key": api_key}
    response = requests.get(base_url, params=params)
    data = response.json()

    if data["status"] == "OK":
        location = data["results"][0]["geometry"]["location"]
        latitude = location["lat"]
        longitude = location["lng"]
        return latitude, longitude
    else:
        print("Error:", data["status"])
        return None

# Function to hash latitude and longitude into a unique ID
def generate_location_hash(latitude, longitude):
    location_string = f"{latitude:.5f},{longitude:.5f}"
    return hashlib.md5(location_string.encode()).hexdigest()

# Function to insert location into the PostgreSQL table
def insert_location(db_conn, latitude, longitude, address, description, postal_code, country_code, source):
    # Generate location hash and formatted data
    location_hash_id = generate_location_hash(latitude, longitude)
    point_value = f"({longitude}, {latitude})"  # PostgreSQL expects (x, y) format for point type
    effective_start_date = date.today()

    # SQL Insert statement
    query = """
    INSERT INTO reference.location (
        location_hash_id, latitude_longitude, description_, address_1, city_, province_state, postal_code, 
        country_code, source_, effective_start_date
    )
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    ON CONFLICT (location_hash_id) DO NOTHING;
    """
    data = (
        location_hash_id, point_value, description, address, city, province_state, postal_code,
        country_code, source, effective_start_date
    )

    # Insert into the table
    with db_conn.cursor() as cursor:
        cursor.execute(query, data)
        db_conn.commit()
    print(f"Inserted location: {description} at {latitude}, {longitude}")

# Main function to obtain coordinates and store them
def store_address_location(address, description, postal_code, country_code, source):
    # Step 1: Retrieve coordinates
    coordinates = get_coordinates(address, api_key)
    if coordinates:
        latitude, longitude = coordinates

        # Step 2: Insert data into the database
        db_conn = connect_db()
        insert_location(db_conn, latitude, longitude, address, description, postal_code, country_code, source)
        db_conn.close()

# Example usage
address = "5700 S Dusable Lk Shr Drive" #Museum of Science and Industry - Chicago"
description = "Museum of Science and Industry - Chicago"
postal_code = "60637"
country_code = "USA"
city = "Chicago"
province_state = "Illinois"
source = "Google Maps API"

store_address_location(address, description, postal_code, country_code, source)

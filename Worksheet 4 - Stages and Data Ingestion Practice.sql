-- Step 1: Select the warehouse to use for computation
USE WAREHOUSE compute_wh;

-- Step 2: Create a new database for the ingestion test
CREATE DATABASE IF NOT EXISTS test_ingestion;

-- Step 3: Create a reusable CSV file format object in the 'public' schema
CREATE OR REPLACE FILE FORMAT test_ingestion.public.csv_ff
  TYPE = 'CSV'
  SKIP_HEADER = 1                 -- Optional: skip header row
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'  -- Optional: handle quoted fields
;

-- Step 4: Create an external stage pointing to an S3 bucket
-- Use the previously defined file format by referencing it with FILE_FORMAT
CREATE OR REPLACE STAGE test_ingestion.public.test_stage
  URL = 's3://sfquickstarts/tasty-bytes-builder-education/raw_pos/truck'
  FILE_FORMAT = test_ingestion.public.csv_ff
;

LIST @test_ingestion.public.test_stage;



-- Step 3: Create or replace the 'truck' table with the expected structure
CREATE OR REPLACE TABLE truck (
    truck_id NUMBER(38,0),
    menu_type_id NUMBER(38,0),
    primary_city VARCHAR(16777216),
    region VARCHAR(16777216),
    iso_region VARCHAR(16777216),
    country VARCHAR(16777216),
    iso_country_code VARCHAR(16777216),
    franchise_flag NUMBER(38,0),
    year NUMBER(38,0),
    make VARCHAR(16777216),
    model VARCHAR(16777216),
    ev_flag NUMBER(38,0),
    franchise_id NUMBER(38,0),
    truck_opening_date DATE
);

-- Step 4: Copy data from the external stage into the truck table
COPY INTO truck
FROM @test_stage/truck.csv.gz
FILE_FORMAT = test_ingestion.public.csv_ff;
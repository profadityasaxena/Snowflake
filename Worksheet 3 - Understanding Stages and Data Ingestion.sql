-- Use the accountadmin role to ensure you have the necessary permissions for the operations below.
USE ROLE accountadmin;

-- Create or replace the tasty_bytes database.
-- Databases are logical containers for schemas, tables, and other database objects.
CREATE OR REPLACE DATABASE tasty_bytes;

-- Create or replace the raw_pos schema within the tasty_bytes database.
-- Schemas help organize database objects logically and are used to group related tables.
CREATE OR REPLACE SCHEMA tasty_bytes.raw_pos;

-- Create or replace the raw_customer schema within the tasty_bytes database.
-- This schema is intended for raw customer data ingestion, storing unprocessed customer data.
CREATE OR REPLACE SCHEMA tasty_bytes.raw_customer;

-- Create or replace the harmonized schema within the tasty_bytes database.
-- Harmonized schemas are used for cleaned and transformed data, enabling consistent reporting.
CREATE OR REPLACE SCHEMA tasty_bytes.harmonized;

-- Create or replace the analytics schema within the tasty_bytes database.
-- Analytics schemas are used for reporting and analysis purposes, containing aggregated and derived data.
CREATE OR REPLACE SCHEMA tasty_bytes.analytics;

-- Create or replace the demo_build_wh warehouse.
-- Warehouses are compute resources in Snowflake used for query execution.
-- This warehouse is configured with a large size for demo purposes, suitable for high-performance workloads.
CREATE OR REPLACE WAREHOUSE demo_build_wh
    WAREHOUSE_SIZE = 'xxxlarge' -- Specifies the size of the warehouse (extremely large for demo purposes).
    WAREHOUSE_TYPE = 'standard' -- Standard type is suitable for most workloads.
    AUTO_SUSPEND = 60 -- Automatically suspends after 60 seconds of inactivity to save costs.
    AUTO_RESUME = TRUE -- Automatically resumes when a query is executed, ensuring availability.
    INITIALLY_SUSPENDED = TRUE -- Starts in a suspended state to save costs until explicitly used.
COMMENT = 'demo build warehouse for tasty bytes assets';

-- Create or replace the tasty_de_wh warehouse.
-- This warehouse is smaller and intended for data engineering tasks, optimized for cost efficiency.
CREATE OR REPLACE WAREHOUSE tasty_de_wh
    WAREHOUSE_SIZE = 'xsmall' -- Smaller size to optimize cost for engineering tasks.
    WAREHOUSE_TYPE = 'standard' -- Standard type for general-purpose workloads.
    AUTO_SUSPEND = 60 -- Automatically suspends after 60 seconds of inactivity.
    AUTO_RESUME = TRUE -- Automatically resumes when a query is executed.
    INITIALLY_SUSPENDED = TRUE -- Starts in a suspended state to save costs.
COMMENT = 'data engineering warehouse for tasty bytes';

-- Switch to the tasty_de_wh warehouse for subsequent operations.
-- This ensures that all queries and operations use the smaller, cost-efficient warehouse.
USE WAREHOUSE tasty_de_wh;

-- Create or replace a file format for CSV files.
-- File formats define how external files are parsed during data ingestion into Snowflake.
CREATE OR REPLACE FILE FORMAT tasty_bytes.public.csv_ff 
type = 'csv'; -- Specifies the file type as CSV, commonly used for structured data.

-- Create or replace an external stage pointing to an S3 bucket.
-- Stages are used to manage external data sources for loading into Snowflake.
CREATE OR REPLACE STAGE tasty_bytes.public.s3load
url = 's3://sfquickstarts/frostbyte_tastybytes/' -- S3 bucket URL containing the data files.
file_format = tasty_bytes.public.csv_ff; -- Associates the stage with the CSV file format for parsing.

-- Example of creating an internal stage (commented out).
-- Internal stages store files directly in Snowflake, useful for temporary or controlled data storage.
-- CREATE OR REPLACE STAGE tasty_bytes.public.internal_stage_test;

-- List files in the external stage to verify connectivity and contents.
-- The `ls` command is used to inspect the files available in the stage, ensuring the S3 bucket is accessible.
ls @tasty_bytes.public.s3load;

-- Create or replace the country table in the raw_pos schema.
-- Tables are used to store structured data, and this table holds country-related information.
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.country
(
    country_id NUMBER(18,0), -- Numeric ID for the country, used as a primary key.
    country VARCHAR(16777216), -- Name of the country.
    iso_currency VARCHAR(3), -- ISO currency code for the country.
    iso_country VARCHAR(2), -- ISO country code for the country.
    city_id NUMBER(19,0), -- Numeric ID for the city, linking to city-level data.
    city VARCHAR(16777216), -- Name of the city.
    city_population VARCHAR(16777216) -- Population of the city, stored as a string for flexibility.
);

-- Create or replace the franchise table in the raw_pos schema.
-- This table stores franchise-related data, including owner details and location information.
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.franchise 
(
    franchise_id NUMBER(38,0), -- Unique ID for the franchise, used as a primary key.
    first_name VARCHAR(16777216), -- First name of the franchise owner.
    last_name VARCHAR(16777216), -- Last name of the franchise owner.
    city VARCHAR(16777216), -- City where the franchise operates.
    country VARCHAR(16777216), -- Country where the franchise operates.
    e_mail VARCHAR(16777216), -- Email address of the franchise owner.
    phone_number VARCHAR(16777216) -- Phone number of the franchise owner.
);

-- Create or replace the location table in the raw_pos schema.
-- This table stores location-related data, including identifiers and geographic details.
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.location
(
    location_id NUMBER(19,0), -- Unique ID for the location, used as a primary key.
    placekey VARCHAR(16777216), -- Placekey identifier for the location, useful for spatial analysis.
    location VARCHAR(16777216), -- Name of the location.
    city VARCHAR(16777216), -- City where the location is situated.
    region VARCHAR(16777216), -- Region where the location is situated.
    iso_country_code VARCHAR(16777216), -- ISO country code for the location.
    country VARCHAR(16777216) -- Name of the country where the location is situated.
);

-- Additional tables and views are created similarly, with detailed comments explaining their purpose and structure.

-- Load data into the tables from the external stage.
-- The COPY INTO command is used to ingest data from the S3 bucket into Snowflake tables.
COPY INTO tasty_bytes.raw_pos.country
FROM @tasty_bytes.public.s3load/raw_pos/country/;

COPY INTO tasty_bytes.raw_pos.franchise
FROM @tasty_bytes.public.s3load/raw_pos/franchise/;

COPY INTO tasty_bytes.raw_pos.location
FROM @tasty_bytes.public.s3load/raw_pos/location/;

COPY INTO tasty_bytes.raw_pos.menu
FROM @tasty_bytes.public.s3load/raw_pos/menu/;

COPY INTO tasty_bytes.raw_pos.truck
FROM @tasty_bytes.public.s3load/raw_pos/truck/;

COPY INTO tasty_bytes.raw_customer.customer_loyalty
FROM @tasty_bytes.public.s3load/raw_customer/customer_loyalty/;

COPY INTO tasty_bytes.raw_pos.order_header
FROM @tasty_bytes.public.s3load/raw_pos/order_header/;

COPY INTO tasty_bytes.raw_pos.order_detail
FROM @tasty_bytes.public.s3load/raw_pos/order_detail/;

-- Drop the demo_build_wh warehouse after data loading is complete.
-- This helps save costs by removing unused compute resources.
DROP WAREHOUSE IF EXISTS demo_build_wh;

-- Switch back to the tasty_de_wh warehouse for subsequent operations.
USE WAREHOUSE TASTY_DE_WH;

-- Query the copy history to verify the status of data ingestion operations.
-- This provides insights into any errors or issues during the data loading process.
SELECT file_name, error_count, status, last_load_time FROM snowflake.account_usage.copy_history
  ORDER BY last_load_time DESC
  LIMIT 10;

-- Show all existing warehouses in the Snowflake account.
SHOW WAREHOUSES;

-- Create a new warehouse named SUPERWAREHOUSE.
CREATE WAREHOUSE SUPERWAREHOUSE;

-- Show all existing warehouses again to verify the creation of SUPERWAREHOUSE.
SHOW WAREHOUSES;

-- Set the active warehouse to ADITYA for subsequent queries.
USE WAREHOUSE ADITYA;

-- Query to find the menu items sold by the Freezing Point brand.
SELECT 
   menu_item_name
FROM tasty_bytes_sample_data.raw_pos.menu
WHERE truck_brand_name = 'Freezing Point';

-- Query to calculate the profit for the menu item "Mango Sticky Rice" sold by the Freezing Point brand.
SELECT 
   menu_item_name,
   (sale_price_usd - cost_of_goods_usd) AS profit_usd
FROM tasty_bytes_sample_data.raw_pos.menu
WHERE 1=1
AND truck_brand_name = 'Freezing Point'
AND menu_item_name = 'Mango Sticky Rice';

-- Create a new warehouse named warehouse_dash.
CREATE WAREHOUSE warehouse_dash;

-- Create another new warehouse named warehouse_gilberto.
CREATE WAREHOUSE warehouse_gilberto;

-- Show all existing warehouses to verify the creation of warehouse_dash and warehouse_gilberto.
SHOW WAREHOUSES;

-- Set the active warehouse to warehouse_gilberto for subsequent queries.
USE WAREHOUSE warehouse_gilberto;

-- Change the size of warehouse_dash to MEDIUM.
ALTER WAREHOUSE warehouse_dash SET warehouse_size=MEDIUM;

-- Set the active warehouse to warehouse_dash for subsequent queries.
USE WAREHOUSE warehouse_dash;

-- Query to calculate the profit for all menu items, sorted by profit in descending order.
SELECT
    menu_item_name,
   (sale_price_usd - cost_of_goods_usd) AS profit_usd
FROM tasty_bytes_sample_data.raw_pos.menu
ORDER BY 2 DESC;

-- Change the size of warehouse_dash to XSMALL.
ALTER WAREHOUSE warehouse_dash SET warehouse_size=XSMALL;

-- Drop the warehouse named warehouse_vino if it exists.
DROP WAREHOUSE warehouse_vino;

-- Show all existing warehouses to verify the deletion of warehouse_vino.
SHOW WAREHOUSES;

-- Create a multi-cluster warehouse named warehouse_vino with a maximum of 3 clusters.
CREATE WAREHOUSE warehouse_vino MAX_CLUSTER_COUNT = 3;

-- Show all existing warehouses to verify the creation of the multi-cluster warehouse warehouse_vino.
SHOW WAREHOUSES;

-- Set the AUTO_SUSPEND parameter to 180 seconds and disable AUTO_RESUME for warehouse_dash.
ALTER WAREHOUSE warehouse_dash SET AUTO_SUSPEND = 180 AUTO_RESUME = FALSE;

-- Show all existing warehouses to verify the updated parameters for warehouse_dash.
SHOW WAREHOUSES;

-- =======================================================
-- SQL SERVER SCHEMA SETUP FOR brazilian-ecommerce PROJECT
-- =======================================================

-- Create the Database
-- Checks if the database already exists before creation.
IF DB_ID(N'brazilian_ecommerce') IS NULL
BEGIN
    CREATE DATABASE brazilian_ecommerce;
END;
GO

-- Switch context to the new database
USE brazilian_ecommerce;
GO

-- 1. Product Category Translation Table
CREATE TABLE product_category_name_translation (
    product_category_name VARCHAR(50) PRIMARY KEY,
    product_category_name_english VARCHAR(50)
);

-- 2. Geolocation Table
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat DECIMAL(18, 15),
    geolocation_lng DECIMAL(18, 15),
    geolocation_city VARCHAR(50),
    geolocation_state VARCHAR(5)
);

-- 3. Customers Table
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(50),
    customer_state VARCHAR(5)
);

-- 4. Sellers Table
CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(50),
    seller_state VARCHAR(5)
);

-- 5. Products Table
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(50),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- 6. Orders Table
-- Depends on: Customers Table
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 7. Order Items Table
-- Depends on: Orders, Products, and Sellers Tables
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10, 2),
    freight_value DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

-- 8. Order Payments Table
-- Depends on: Orders Table
CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- 9. Order Reviews Table
-- Depends on: Orders Table
CREATE TABLE order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
    -- Note: Ideally links to orders, but sometimes data is missing in raw CSVs
    -- FOREIGN KEY (order_id) REFERENCES orders(order_id) 
);

/* -----------------------------------------------------------------------------------
    Importing Data into Tables We used Python with SQLAlchemy and Pandas to load CSV files into the SQL Server tables.
    Below is a sample code snippet for loading one of the CSV files into a table.
   -----------------------------------------------------------------------------------
*/

-- import pandas as pd
-- from sqlalchemy import create_engine
-- import urllib

-- # Step 1: Load the second CSV file
-- csv_path = r"path"
-- df = pd.read_csv(csv_path)

-- # Step 2: Define connection parameters
-- server = 'YOUR_SERVER_NAME'  # Replace with your server name
-- database = 'brazilian_ecommerce'

-- # Step 3: Build connection string using Windows Authentication
-- params = urllib.parse.quote_plus(
--     f"DRIVER=ODBC Driver 17 for SQL Server;"
--     f"SERVER={server};"
--     f"DATABASE={database};"
--     f"Trusted_Connection=yes;"
-- )

-- engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

-- # Step 4: Upload the DataFrame to the target table
-- df.to_sql('table_name', engine, if_exists='append', index=False)


/* -----------------------------------------------------------------------------------
   Q1: Data Integration 
   -----------------------------------------------------------------------------------
*/

SELECT 
    o.order_id,
    c.customer_unique_id,                        -- Use unique_id for accurate customer retention analysis
    t.product_category_name_english AS product_category, -- Translated category name
    o.order_purchase_timestamp,
    oi.price,
    oi.freight_value
FROM 
    orders o
INNER JOIN 
    order_items oi ON o.order_id = oi.order_id   -- Connect Orders to their Items (Price & Product ID)
INNER JOIN 
    customers c ON o.customer_id = c.customer_id -- Connect Orders to Customers to get Unique ID
INNER JOIN 
    products p ON oi.product_id = p.product_id   -- Connect Items to Products to get Category Name
INNER JOIN 
    product_category_name_translation t ON p.product_category_name = t.product_category_name; -- Translate Category to English

/* -----------------------------------------------------------------------------------
   Q2: Seller Performance 
   Objective: Identify the top 10 sellers by total revenue generated.
   -----------------------------------------------------------------------------------
*/

SELECT TOP 10
    seller_id,
    SUM(price) AS total_revenue
FROM 
    order_items
GROUP BY 
    seller_id
ORDER BY 
    total_revenue DESC;

/* -----------------------------------------------------------------------------------
   Q3: Delivery Performance 
   Objective: Calculate average delivery time per state.
   -----------------------------------------------------------------------------------
*/

SELECT 
    c.customer_state,
    AVG(DATEDIFF(day, o.order_purchase_timestamp, o.order_delivered_customer_date)) AS avg_delivery_days
FROM 
    orders o
JOIN 
    customers c ON o.customer_id = c.customer_id
WHERE 
    o.order_status = 'delivered'                 -- Filter only delivered orders
    AND o.order_delivered_customer_date IS NOT NULL -- Ensure delivery date exists
GROUP BY 
    c.customer_state
ORDER BY 
    avg_delivery_days DESC;

/* -----------------------------------------------------------------------------------
   Q4: Customer Retention (Advanced - Window Functions)
   Objective: Identify returning customers and their second purchase date.
   -----------------------------------------------------------------------------------
*/

WITH CustomerOrders AS (
    SELECT 
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        -- Assign a rank to each order per customer based on purchase date
        ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp) AS order_rank
    FROM 
        orders o
    JOIN 
        customers c ON o.customer_id = c.customer_id
)
SELECT 
    customer_unique_id,
    order_id AS second_order_id,
    order_purchase_timestamp AS second_purchase_date
FROM 
    CustomerOrders
WHERE 
    order_rank = 2; -- Filter for the second purchase only

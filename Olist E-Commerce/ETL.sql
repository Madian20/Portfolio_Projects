USE master;
GO

-- ============================================================
-- Create the Olist_DB database 
-- ============================================================

-- Drop and recreate the database to ensure a clean slate
IF DB_ID('Olist_DB') IS NOT NULL
BEGIN
    ALTER DATABASE Olist_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Olist_DB;
END
GO

CREATE DATABASE Olist_DB;
GO

USE Olist_DB;
GO

-- ==========================================================================
-- Create tables with initial NVARCHAR(MAX) data types for all columns
-- ==========================================================================

-- TABLE 1: orders

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'orders')
    DROP TABLE orders;

CREATE TABLE orders (
    [order_id]                          NVARCHAR(MAX),
    [customer_id]                       NVARCHAR(MAX),
    [order_status]                      NVARCHAR(MAX),
    [order_purchase_timestamp]          NVARCHAR(MAX),
    [order_approved_at]                 NVARCHAR(MAX),
    [order_delivered_carrier_date]      NVARCHAR(MAX),
    [order_delivered_customer_date]     NVARCHAR(MAX),
    [order_estimated_delivery_date]     NVARCHAR(MAX)
);
GO


-- TABLE 2: order_items

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'order_items')
    DROP TABLE order_items;

CREATE TABLE order_items (
    [order_id]              NVARCHAR(MAX),
    [order_item_id]         NVARCHAR(MAX),    
    [product_id]            NVARCHAR(MAX),
    [seller_id]             NVARCHAR(MAX),
    [shipping_limit_date]   NVARCHAR(MAX),
    [price]                 NVARCHAR(MAX),
    [freight_value]         NVARCHAR(MAX)
);
GO


-- TABLE 3: order_payments

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'order_payments')
    DROP TABLE order_payments;

CREATE TABLE order_payments (
    [order_id]             NVARCHAR(MAX),
    [payment_sequential]   NVARCHAR(MAX),    
    [payment_type]         NVARCHAR(MAX),   
    [payment_installments] NVARCHAR(MAX),
    [payment_value]        NVARCHAR(MAX)
);
GO


-- TABLE 4: order_reviews

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'order_reviews')
    DROP TABLE order_reviews;

CREATE TABLE order_reviews (
    [review_id]                 NVARCHAR(MAX),
    [order_id]                  NVARCHAR(MAX),
    [review_score]              NVARCHAR(MAX),    
    [review_comment_title]      NVARCHAR(MAX),
    [review_comment_message]    NVARCHAR(MAX),
    [review_creation_date]      NVARCHAR(MAX),
    [review_answer_timestamp]   NVARCHAR(MAX)
);
GO


-- TABLE 5: customers

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'customers')
    DROP TABLE customers;

CREATE TABLE customers (
    [customer_id]              NVARCHAR(MAX),    
    [customer_unique_id]       NVARCHAR(MAX),    
    [customer_zip_code_prefix] NVARCHAR(MAX),
    [customer_city]            NVARCHAR(MAX),
    [customer_state]           NVARCHAR(MAX)
);
GO


-- TABLE 6: sellers

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'sellers')
    DROP TABLE sellers;

CREATE TABLE sellers (
    [seller_id]              NVARCHAR(MAX),
    [seller_zip_code_prefix] NVARCHAR(MAX),
    [seller_city]            NVARCHAR(MAX),
    [seller_state]           NVARCHAR(MAX)
);
GO


-- TABLE 7: products

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'products')
    DROP TABLE products;

CREATE TABLE products (
    [product_id]                   NVARCHAR(MAX),
    [product_category]        NVARCHAR(MAX),   
    [product_name_lenght]          NVARCHAR(MAX),
    [product_description_lenght]   NVARCHAR(MAX),
    [product_photos_qty]           NVARCHAR(MAX),
    [product_length_cm]             NVARCHAR(MAX),
    [product_height_cm]            NVARCHAR(MAX),
    [product_width_cm]            NVARCHAR(MAX)
);
GO


-- TABLE 8: category_translation

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'category_translation')
    DROP TABLE category_translation;

CREATE TABLE category_translation (
    [product_category_name]         NVARCHAR(MAX),    
    [product_category_name_english] NVARCHAR(MAX)     
);
GO


-- TABLE 9: geolocation

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'geolocation')
    DROP TABLE geolocation;

CREATE TABLE geolocation (
    [geolocation_zip_code_prefix] NVARCHAR(MAX),
    [geolocation_lat]             NVARCHAR(MAX),
    [geolocation_lng]             NVARCHAR(MAX),
    [geolocation_city]            NVARCHAR(MAX),
    [geolocation_state]           NVARCHAR(MAX)
);
GO

-- =============================================================
-- Type Alteration: Set appropriate data types for each column
-- =============================================================

-- Alter the orders table to set appropriate data types for each column
ALTER TABLE orders
    ALTER COLUMN [order_id]                      NVARCHAR(50) NOT NULL;
 
ALTER TABLE orders
    ALTER COLUMN [customer_id]                   NVARCHAR(50) NOT NULL;
 
ALTER TABLE orders
    ALTER COLUMN [order_status]                  NVARCHAR(50) NOT NULL;

ALTER TABLE orders
    ALTER COLUMN [order_purchase_timestamp]      DATETIME NOT NULL;

ALTER TABLE orders
    ALTER COLUMN [order_approved_at]             DATETIME NULL;
 
ALTER TABLE orders
    ALTER COLUMN [order_delivered_carrier_date]  DATETIME NULL;
 
ALTER TABLE orders
    ALTER COLUMN [order_delivered_customer_date] DATETIME NULL;
 
ALTER TABLE orders
    ALTER COLUMN [order_estimated_delivery_date] DATETIME NULL;

GO


-- Alter the order_items table to set appropriate data types for each column
ALTER TABLE order_items
    ALTER COLUMN [order_id]            NVARCHAR(50) NOT NULL;
 
ALTER TABLE order_items
    ALTER COLUMN [product_id]          NVARCHAR(50) NOT NULL;
 
ALTER TABLE order_items
    ALTER COLUMN [seller_id]           NVARCHAR(50) NOT NULL;
 
ALTER TABLE order_items
    ALTER COLUMN [order_item_id]       SMALLINT NOT NULL;
 
ALTER TABLE order_items
    ALTER COLUMN [price]               DECIMAL(10,2) NOT NULL;
 
ALTER TABLE order_items
    ALTER COLUMN [freight_value]       DECIMAL(10,2) NOT NULL;
 
ALTER TABLE order_items
    ALTER COLUMN [shipping_limit_date] DATETIME NULL;

GO


-- Alter the order_payments table to set appropriate data types for each column
ALTER TABLE order_payments
    ALTER COLUMN [order_id]             NVARCHAR(50) NOT NULL;
 
ALTER TABLE order_payments
    ALTER COLUMN [payment_type]         NVARCHAR(MAX) NOT NULL;

ALTER TABLE order_payments
    ALTER COLUMN [payment_sequential]   SMALLINT NOT NULL;
 
ALTER TABLE order_payments
    ALTER COLUMN [payment_installments] SMALLINT NOT NULL;

ALTER TABLE order_payments
    ALTER COLUMN [payment_value]        DECIMAL(10,2) NOT NULL;

GO


-- Alter the order_reviews table to set appropriate data types for each column
ALTER TABLE order_reviews
    ALTER COLUMN [review_id]                NVARCHAR(50) NOT NULL;
 
ALTER TABLE order_reviews
    ALTER COLUMN [order_id]                 NVARCHAR(50) NOT NULL;

ALTER TABLE order_reviews
    ALTER COLUMN [review_score]             TINYINT NOT NULL;
 
ALTER TABLE order_reviews
    ALTER COLUMN [review_creation_date]     DATETIME NULL;
 
ALTER TABLE order_reviews
    ALTER COLUMN [review_answer_timestamp]  DATETIME NULL;

GO


-- Alter the customers table to set appropriate data types for each column
ALTER TABLE customers
    ALTER COLUMN [customer_id]              NVARCHAR(50) NOT NULL;
 
ALTER TABLE customers
    ALTER COLUMN [customer_unique_id]       NVARCHAR(50) NOT NULL;
 
ALTER TABLE customers
    ALTER COLUMN [customer_state]           NVARCHAR(50) NOT NULL;

GO


-- alter the sellers table to set appropriate data types for each column
ALTER TABLE sellers
    ALTER COLUMN [seller_id]    NVARCHAR(50) NOT NULL;
 
ALTER TABLE sellers
    ALTER COLUMN [seller_state] NVARCHAR(50) NOT NULL;

GO


-- Alter the products table to set appropriate data types for each column
ALTER TABLE products
    ALTER COLUMN [product_id]                  NVARCHAR(50) NOT NULL;

ALTER TABLE products
    ALTER COLUMN [product_category]                  NVARCHAR(50) NULL;

ALTER TABLE products
    ALTER COLUMN [product_photos_qty]          SMALLINT NULL;
 
ALTER TABLE products
    ALTER COLUMN [product_length_cm]           DECIMAL(8,2) NULL;
 
ALTER TABLE products
    ALTER COLUMN [product_height_cm]           DECIMAL(8,2) NULL;
 
ALTER TABLE products
    ALTER COLUMN [product_width_cm]            DECIMAL(8,2) NULL;
 
ALTER TABLE products
    ALTER COLUMN [product_name_lenght]         SMALLINT NULL;
 
ALTER TABLE products
    ALTER COLUMN [product_description_lenght]  SMALLINT NULL;

GO


-- Alter the category_translation table to set appropriate data types for each column
ALTER TABLE category_translation
    ALTER COLUMN [product_category_name]              NVARCHAR(50) NOT NULL;
 
ALTER TABLE category_translation
    ALTER COLUMN [product_category_name_english] NVARCHAR(50) NOT NULL;

GO


-- Alter the geolocation table to set appropriate data types for each column
ALTER TABLE geolocation
    ALTER COLUMN [geolocation_zip_code_prefix] NVARCHAR(50) NOT NULL;
 
ALTER TABLE geolocation
    ALTER COLUMN [geolocation_state]           NVARCHAR(MAX) NOT NULL;

ALTER TABLE geolocation
    ALTER COLUMN [geolocation_lat]             DECIMAL(9,6) NOT NULL;
 
ALTER TABLE geolocation
    ALTER COLUMN [geolocation_lng]             DECIMAL(9,6) NOT NULL;
 
GO

-- ================================
-- Data Cleaning
-- ================================

-- Set order_delivered_carrier_date to NULL if it is earlier than order_purchase_timestamp
UPDATE orders
SET order_delivered_carrier_date = NULL
WHERE order_delivered_carrier_date < order_purchase_timestamp;
GO


-- Update product categories to use English names
UPDATE p
SET p.product_category = ct.product_category_name_english
FROM products p
JOIN category_translation ct ON p.product_category = ct.product_category_name
WHERE p.product_category IS NOT NULL; 
GO

-- Remove duplicate reviews, keeping only the most recent review for each order
WITH cte AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY review_id
            ORDER BY review_creation_date DESC
        ) AS rn
    FROM order_reviews
)
DELETE FROM cte WHERE rn > 1;
GO

-- Remove order items that reference products not present in the products table
DELETE FROM order_items
WHERE product_id NOT IN (
    SELECT product_id FROM products
);

-- =======================================
-- Add Calculated Columns
-- =======================================

-- Add RFM columns to the customers table
ALTER TABLE customers
ADD 
    recency_days INT,
    monetary DECIMAL(10,2),
    r_score INT,
    m_score INT,
    rfm_segment VARCHAR(20);
GO

-- Calculate RFM values for each customer based on their order history
UPDATE c
SET 
    c.recency_days = DATEDIFF(DAY, last_order, '2018-10-17'),
    c.monetary = total_spend
FROM customers c
INNER JOIN (
    SELECT 
        o.customer_id,
        MAX(o.order_purchase_timestamp) AS last_order,
        SUM(oi.price + oi.freight_value) AS total_spend
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.customer_id
) rfm ON c.customer_id = rfm.customer_id;
GO 

-- Assign R, F, M scores based on quintiles
UPDATE c
SET 
    c.r_score = scores.r_score,
    c.m_score = scores.m_score
FROM customers c
INNER JOIN (
    SELECT 
        customer_id,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY monetary ASC)      AS m_score
    FROM customers
    WHERE recency_days IS NOT NULL
) scores ON c.customer_id = scores.customer_id;
GO

-- Create RFM segments based on R and F scores
UPDATE customers
SET rfm_segment = 
    CASE 
        WHEN r_score = 5 AND m_score >= 4 THEN 'Champion'
        WHEN r_score = 5 AND m_score <= 3 THEN 'New Customer'
        WHEN r_score = 4 AND m_score >= 4 THEN 'Loyal'
        WHEN r_score = 4 AND m_score <= 3 THEN 'Potential'
        WHEN r_score = 3 AND m_score >= 3 THEN 'Potential'
        WHEN r_score <= 2 AND m_score >= 4 THEN 'At Risk'
        WHEN r_score <= 2 AND m_score = 3 THEN 'Hibernating'
        ELSE 'Lost'
    END
WHERE r_score IS NOT NULL;
GO


-- ============================================================ 
-- Add primary keys to each table 
-- ============================================================

-- orders: order_id
ALTER TABLE orders
    ADD CONSTRAINT PK_orders
    PRIMARY KEY (order_id);
 
-- order_items: composite PK — one order can have multiple items
ALTER TABLE order_items
    ADD CONSTRAINT PK_order_items
    PRIMARY KEY (order_id, order_item_id);

-- order_payments: composite PK — one order can have multiple payment installments
ALTER TABLE order_payments
    ADD CONSTRAINT PK_order_payments
    PRIMARY KEY (order_id, payment_sequential);
 
-- order_reviews: review_id 
ALTER TABLE order_reviews
    ADD CONSTRAINT PK_order_reviews
    PRIMARY KEY (review_id);
 
-- customers: customer_id
ALTER TABLE customers
    ADD CONSTRAINT PK_customers
    PRIMARY KEY (customer_id);
 
-- sellers: seller_id 
ALTER TABLE sellers
    ADD CONSTRAINT PK_sellers
    PRIMARY KEY (seller_id);
 
-- products: product_id
ALTER TABLE products
    ADD CONSTRAINT PK_products
    PRIMARY KEY (product_id);

GO

-- ============================================================
-- Add FOREIGN KEYS
-- ============================================================
 
-- order_items.order_id → orders.order_id
ALTER TABLE order_items
    ADD CONSTRAINT FK_order_items_orders
    FOREIGN KEY (order_id) REFERENCES orders (order_id);
 
-- order_items.product_id → products.product_id
ALTER TABLE order_items
    ADD CONSTRAINT FK_order_items_products
    FOREIGN KEY (product_id) REFERENCES products (product_id);

-- order_items.seller_id → sellers.seller_id
ALTER TABLE order_items
    ADD CONSTRAINT FK_order_items_sellers
    FOREIGN KEY (seller_id) REFERENCES sellers (seller_id);
 
-- order_payments.order_id → orders.order_id
ALTER TABLE order_payments
    ADD CONSTRAINT FK_order_payments_orders
    FOREIGN KEY (order_id) REFERENCES orders (order_id);
 
-- order_reviews.order_id → orders.order_id
ALTER TABLE order_reviews
    ADD CONSTRAINT FK_order_reviews_orders
    FOREIGN KEY (order_id) REFERENCES orders (order_id);
 
-- orders.customer_id → customers.customer_id
ALTER TABLE orders
    ADD CONSTRAINT FK_orders_customers
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id);

GO

-- ============================================================
-- Add INDEXES
-- ============================================================
 
-- orders: 
CREATE NONCLUSTERED INDEX IX_orders_status
    ON orders (order_status);
 
CREATE NONCLUSTERED INDEX IX_orders_purchase_date
    ON orders (order_purchase_timestamp);
 
CREATE NONCLUSTERED INDEX IX_orders_customer_id
    ON orders (customer_id);
 
-- order_items: 
CREATE NONCLUSTERED INDEX IX_order_items_product_id
    ON order_items (product_id);
 
CREATE NONCLUSTERED INDEX IX_order_items_seller_id
    ON order_items (seller_id);
 
-- order_reviews:
CREATE NONCLUSTERED INDEX IX_order_reviews_score
    ON order_reviews (review_score);
 
-- customers: 
CREATE NONCLUSTERED INDEX IX_customers_state
    ON customers (customer_state);
 
-- sellers:
CREATE NONCLUSTERED INDEX IX_sellers_state
    ON sellers (seller_state);
 
-- products:
CREATE NONCLUSTERED INDEX IX_products_category
    ON products (product_category);
 
-- geolocation: 
CREATE NONCLUSTERED INDEX IX_geolocation_zip
    ON geolocation (geolocation_zip_code_prefix);
 
GO
 


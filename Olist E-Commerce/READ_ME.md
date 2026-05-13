# Olist E-Commerce

## Project Overview

**Olist E-Commerce** is a data analytics project that examines how a Brazilian e-commerce marketplace operates across orders, sellers, customers, and product categories. The project covers **approximately 100K orders · 3,000+ sellers · 73 product categories**, sourced from the Olist public dataset on Kaggle spanning 2016–2018, with a focus on identifying delivery performance gaps and their direct impact on customer satisfaction across Brazil's 27 states.

---

## Motivation & Goal

**Motivation:** Brazil's e-commerce landscape is growing fast, but geography works against it. With customers spread across 27 states and thousands of independent sellers fulfilling orders daily, delivery reliability becomes the single biggest lever on customer trust. When a package arrives late, the review score drops and that pattern, repeated at scale, quietly erodes a marketplace's reputation from the inside.

**Goal:** Develop a 4-page Power BI report that gives business stakeholders a structured, evidence-based view of order flow, delivery performance, and customer sentiment. The aim is to move decision-making around seller quality, logistics bottlenecks, and category prioritization away from assumption and toward what the data actually shows.

---

## Project Phases

**1. ETL:** The pipeline began by creating the database in SQL Server, followed by designing and creating the tables from scratch. Raw data was then loaded into the tables using Python, after which a cleaning process was applied. Calculated columns were then added directly in SQL, and the schema was finalized by enforcing primary keys, foreign keys, and indexing for query performance.

**2. EDA:** Exploratory analysis was conducted in Jupyter Notebook to understand the data before building any visuals.

**3. Power BI:** The final phase involved building the 4-page dashboard in Power BI Desktop, connecting directly to SQL Server and delivering the final interactive visuals .

---

## Data Model & Relationships
<img width="1567" height="1040" alt="image" src="https://github.com/user-attachments/assets/9bcc7fc2-b2e4-4cd3-a397-3a9736bfc137" />

---

## Final Dashboard

### Overview
<img width="1304" height="784" alt="image" src="https://github.com/user-attachments/assets/ed2b39b4-9bb4-406e-9617-e7d9b5003474" />

<img width="1302" height="779" alt="image" src="https://github.com/user-attachments/assets/a5f2bedc-1251-4aaa-9e71-5ff456453d5f" />


### Delivery Performance
<img width="1301" height="778" alt="image" src="https://github.com/user-attachments/assets/6740f9c7-c23c-46ef-b262-dece20bc5b09" />

### Customer Satisfaction
<img width="1304" height="792" alt="image" src="https://github.com/user-attachments/assets/bed06e2c-a144-4fc0-9e3e-6b4d697ad369" />

### Customer Intelligence
<img width="1307" height="785" alt="image" src="https://github.com/user-attachments/assets/dd8e71ee-cc6e-4192-9a3e-e5eb15c05870" />


---

## Insights 

**Product Performance:** Health & Beauty and Watches & Gifts are the top revenue-generating categories, contributing approximately 20% of total revenue combined. Customer satisfaction in both categories is notably high, with 80% of Health & Beauty reviewers leaving a positive rating and approximately 76% for Watches & Gifts.

**Geographic Concentration:** São Paulo and Rio de Janeiro together account for nearly half of total revenue, making them the two most critical markets in the dataset.

**Seasonality:** November is the highest revenue month across the entire period, driven by Black Friday demand.

**Delivery Performance:** Approximately 93% of delivered orders arrived on time or ahead of schedule. However, a clear inverse relationship exists between delivery delays and review scores. Orders delivered on time or early averaged a score of 4.29, while orders delayed by more than a week dropped to an average of 1.69.

**Customer Loyalty:** Only 3.12% of customers made a repeat purchase, indicating that the vast majority of Olist's customer base is one-time buyers.

**At-Risk Segment:** At-risk customers represent 15% of the customer base yet contribute approximately 20% of total revenue, making their retention a high-priority business concern.

---

## Code Highlights

### Cleaning

```{sql}
-- Update product categories to use English names
UPDATE p
SET p.product_category = ct.product_category_name_english
FROM products p
INNER JOIN category_translation ct ON p.product_category = ct.product_category_name
WHERE p.product_category IS NOT NULL;
```

```{sql}
-- Set order_delivered_carrier_date to NULL if it is earlier than order_purchase_timestamp
UPDATE orders
SET order_delivered_carrier_date = NULL
WHERE order_delivered_carrier_date < order_purchase_timestamp;
```
### Create high_value_low_rating Table
```{sql}
WITH customer_spending AS (
    SELECT 
        c.customer_id,
        c.customer_city,
        c.customer_state,
        COUNT(DISTINCT o.order_id)                 AS total_orders,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS total_spent,
        ROUND(AVG(r.review_score), 2)              AS review_score,
        MAX(o.order_purchase_timestamp)            AS last_order_date
    FROM customers c
    INNER JOIN orders o  
        ON c.customer_id = o.customer_id
    INNER JOIN order_items oi 
        ON o.order_id = oi.order_id
    INNER JOIN order_reviews r  
        ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_id, c.customer_city, c.customer_state
),
ranked AS (
    SELECT 
        *,
        NTILE(100) OVER (ORDER BY total_spent DESC) AS spending_percentile
    FROM customer_spending
)
```
### Create PKs & FKs

#### order_id PK
```{sql}
-- orders: order_id
ALTER TABLE orders
    ADD CONSTRAINT PK_orders
    PRIMARY KEY (order_id);
```
#### order_id FK
```{sql}
-- order_items.order_id → orders.order_id
ALTER TABLE order_items
    ADD CONSTRAINT FK_order_items_orders
    FOREIGN KEY (order_id) REFERENCES orders (order_id);
```
#### Add INDEXES
```{sql}
-- orders: 
CREATE NONCLUSTERED INDEX IX_orders_status
    ON orders (order_status);
 
CREATE NONCLUSTERED INDEX IX_orders_purchase_date
    ON orders (order_purchase_timestamp);
 
CREATE NONCLUSTERED INDEX IX_orders_customer_id
    ON orders (customer_id);
```

### DAX Calculeted Columns 

#### Delivery Delay Days
```{DAX}
Delivery Delay Days = 
DATEDIFF(
    orders[order_estimated_delivery_date],
    orders[order_delivered_customer_date],
    DAY
)
```
#### Delivery Status
```{DAX}
Delivery Status = 
IF(
    ISBLANK(orders[order_delivered_customer_date]),
    "Not Delivered",
    IF(
        orders[Delivery Delay Days] <= 0,
        "On Time",
        IF(
            orders[Delivery Delay Days] <= 7,
            "Late",
            "Very Late"
        )
    )
)
```









# IFood Customer Behavaior Analysis

---

## Project Overview

**IFood Customer Behavaior Analysis** is an end-to-end data analytics project built on a real-world marketing dataset from Maven Analytics, covering **2,240 customers** across **25 fields** — including customer profiles, product spending, purchase channels, and responses to 6 marketing campaigns.

The goal is to understand what drives customer engagement, identify the most effective campaigns and channels, and profile the typical Maven Marketing customer.

---

## Project Phases

**1. Database & Table Creation — SQL Server**
Built the database structure and created the core table to host the raw data.

**2. Data Cleaning — SQL Server**
Cleaned the data to ensure reliability and consistency before any analysis.

**3. Calculated Columns — SQL Server**
Added derived columns to enrich the dataset with meaningful metrics extracted from existing fields.

**4. Views — SQL Server**
Created five dedicated views to make the data easier to query and explore across different analytical angles.

**5. Exploratory Data Analysis — Python**
This phase aimed to uncover the structure and behavior of the dataset before moving into reporting

**6. Dashboard — Power BI**
Built an interactive dashboard that brings core findings in a clear, decision-ready format.


<img width="1069" height="731" alt="image" src="https://github.com/user-attachments/assets/80a91a73-3874-4ed8-9be1-d82b3a494e6f" />

---

## Key Performance Indicators

| KPI | Value |
|-----|-------|
| Total Revenue | $1.233M |
| ARPC | $606 |
| AVG Campaign Acceptance | 0.45 |
| Total Customers | 2,037 |
| % Active Customers | 32.20% |
| % Inactive Customers | 8.69% |
| AVG Customer Age | 45.16 |
| % Customers With Children | 71.87% |

---
## Cleaning Deep Dive

* **Removing incomplete rows** — deleted any record missing critical fields such as ID, Year_Birth, or Dt_Customer

```sql
DELETE FROM MarketingCampaign
WHERE
    ID            IS NULL OR LTRIM(RTRIM(ID))            = ''
    OR Year_Birth IS NULL OR LTRIM(RTRIM(Year_Birth))    = ''
    OR Dt_Customer IS NULL OR TRY_CAST(Dt_Customer AS DATE) IS NULL;
GO
```

* **Removing outliers** — dropped rows where Year_Birth was below 1900

```sql
DELETE FROM MarketingCampaign
WHERE TRY_CAST(Year_Birth AS SMALLINT) < 1900
   OR TRY_CAST(Year_Birth AS SMALLINT) IS NULL;
GO
```

* **Handling missing income** — replaced NULL or empty Income values with the median of the existing values

```sql
WITH Ordered AS (
    SELECT
        TRY_CAST(Income AS DECIMAL(10,2)) AS Income_Val,
        ROW_NUMBER() OVER (ORDER BY TRY_CAST(Income AS DECIMAL(10,2))) AS rn,
        COUNT(*)     OVER ()                                            AS cnt
    FROM MarketingCampaign
    WHERE TRY_CAST(Income AS DECIMAL(10,2)) IS NOT NULL
      AND LTRIM(RTRIM(Income)) != ''
)
UPDATE MarketingCampaign
SET Income = CAST(
    (
        SELECT AVG(Income_Val)
        FROM Ordered
        WHERE rn IN ( (cnt + 1) / 2, (cnt + 2) / 2 )
    ) AS NVARCHAR(MAX)
)
WHERE Income IS NULL
   OR LTRIM(RTRIM(Income)) = ''
   OR TRY_CAST(Income AS DECIMAL(10,2)) IS NULL;
GO
```

* **Trimming text columns** — removed leading and trailing whitespace from Education, Marital_Status, and Country

```sql
UPDATE MarketingCampaign
SET Education      = LTRIM(RTRIM(Education)),
    Marital_Status = LTRIM(RTRIM(Marital_Status)),
    Country        = LTRIM(RTRIM(Country));
GO
```

* **Removing duplicates** — kept only the first occurrence of duplicate rows based on key demographic fields

```sql
WITH CTE_Duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY Year_Birth, Education, Marital_Status, Income,
                            Kidhome, Teenhome, Dt_Customer
               ORDER BY ID
           ) AS rn
    FROM MarketingCampaign
)
DELETE FROM CTE_Duplicates WHERE rn > 1;
GO
```

---
## Insights Deep Dive

1. **Income is the strongest driver of spending, but it's not the whole story** — Premium customers spend up to $2,500 while Low-income customers rarely exceed $500. However, even within the same income segment, spend varies drastically, meaning lifestyle and personal preferences also play a significant role. Notably, income correlates with spend at 0.65 — meaningful, but far from deterministic.

2. **Wines and Meat are the business — everything else is secondary** — Wines alone account for 50% of total revenue ($617,731), and together with Meat they drive nearly 78% of all spend. However, wine is an aspirational category heavily tied to income and education: low-income customers with primary-level education spend only $3.11 on wines on average (4.52% of their total spend), compared to far higher shares among Premium and highly educated segments.

3. **Having children is both a spending suppressor and an income signal** — Customers with children spend 2.7x less ($405 vs. $1,116). But more importantly, having children is overwhelmingly a low and mid-income trait — 90.43% of Mid-income and 79.64% of Low-income customers have children, compared to only 13.73% of Premium customers. The two effects are deeply intertwined.

4. **The customer base is healthy, but VIPs and At-Risk segments need urgent attention** — Loyal and Regular customers make up 77.72% of the base, which is a strong foundation. VIPs (8.64%) generate the highest spend at $1,447 average but are a fragile group. At-Risk customers, on the other hand, have the longest tenure (12.62 months) yet are disengaging — meaning the business is at risk of losing its most experienced customers.

5. **Campaign performance is highly uneven — one stands out, one is failing** — The Response campaign achieves a 14.97% acceptance rate, nearly double the next best (Cmp4 at 7.61%). Campaign 2, however, sits at just 1.28% — dramatically below all others — signaling a fundamental mismatch with its target audience.

---

## Recommendations

1. **Prioritize wine and premium category marketing toward high-income, high-education segments only** — given that wine spend drops to as low as $3.11 among low-income/low-education customers, running wine campaigns broadly wastes budget. Concentrate wine and premium product spend on Premium and highly educated segments 

2. **Build separate playbooks for low-income customers and parents** — since 80–90% of low and mid-income customers have children, these two segments are nearly identical. They need value-driven, practical messaging — not premium positioning. Promotions, bundles, and affordability should be the core levers for this group.

3. **Launch a VIP retention program and an At-Risk win-back campaign ** — VIPs drive the highest spend but are a small and vulnerable group. At-Risk customers have the longest history with the business and represent recoverable value. Both segments require personalized, high-touch interventions before they churn.

4. **Investigate and scale the Response campaign; kill or rebuild Campaign 2** — the Response campaign's 14.97% rate is the clearest signal of what works. Its audience targeting and messaging should be studied and replicated. Campaign 2's 1.28% rate means it is actively wasting resources and should be discontinued or fundamentally redesigned.

5. **Invest in onboarding new customers in their first 90 days** — new customers average only $33.58 in spend and 8.62 months tenure, indicating they haven't formed strong habits yet.


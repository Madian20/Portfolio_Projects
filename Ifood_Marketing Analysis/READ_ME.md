## Project Overview

IFood Customer Behavaior Analysis is an end-to-end data analytics project built on a real-world marketing dataset from Maven Analytics, covering **2,240 customers** across **25 fields** — including customer profiles, product spending, purchase channels, and responses to 6 marketing campaigns.

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

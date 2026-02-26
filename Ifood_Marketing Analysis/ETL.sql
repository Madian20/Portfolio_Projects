-- use master database to create the new database
USE master;
GO

-- drop database if exists
IF DB_ID('MarketingCampaign_DB') IS NOT NULL
BEGIN
    ALTER DATABASE MarketingCampaign_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE MarketingCampaign_DB;
END
GO

-- create new database
CREATE DATABASE MarketingCampaign_DB;
GO

-- use the newly created database
USE MarketingCampaign_DB;
GO

-- create table with all columns as NVARCHAR(MAX) to avoid data type issues during bulk insert
CREATE TABLE MarketingCampaign (
    ID                   NVARCHAR(MAX),
    Year_Birth           NVARCHAR(MAX),
    Education            NVARCHAR(MAX),
    Marital_Status       NVARCHAR(MAX),
    Income               NVARCHAR(MAX),
    Kidhome              NVARCHAR(MAX),
    Teenhome             NVARCHAR(MAX),
    Dt_Customer          NVARCHAR(MAX),
    Recency              NVARCHAR(MAX),
    MntWines             NVARCHAR(MAX),
    MntFruits            NVARCHAR(MAX),
    MntMeatProducts      NVARCHAR(MAX),
    MntFishProducts      NVARCHAR(MAX),
    MntSweetProducts     NVARCHAR(MAX),
    MntGoldProds         NVARCHAR(MAX),
    NumDealsPurchases    NVARCHAR(MAX),
    NumWebPurchases      NVARCHAR(MAX),
    NumCatalogPurchases  NVARCHAR(MAX),
    NumStorePurchases    NVARCHAR(MAX),
    NumWebVisitsMonth    NVARCHAR(MAX),
    AcceptedCmp3         NVARCHAR(MAX),
    AcceptedCmp4         NVARCHAR(MAX),
    AcceptedCmp5         NVARCHAR(MAX),
    AcceptedCmp1         NVARCHAR(MAX),
    AcceptedCmp2         NVARCHAR(MAX),
    Response             NVARCHAR(MAX),
    Complain             NVARCHAR(MAX),
    Country              NVARCHAR(MAX)
);
GO

-- Bulk insert data from CSV file
BULK INSERT MarketingCampaign
FROM "D:\Marketing+Data\marketing_data.csv"
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    CODEPAGE        = '65001',
    TABLOCK
);
GO

-- ============================================================
-- Delete rows missing critical fields
-- ============================================================
DELETE FROM MarketingCampaign
WHERE
    ID               IS NULL OR LTRIM(RTRIM(ID))            = ''
    OR Year_Birth    IS NULL OR LTRIM(RTRIM(Year_Birth))    = ''
    OR Dt_Customer   IS NULL OR TRY_CAST(Dt_Customer AS DATE) IS NULL;
GO

-- ============================================================
--  Delete rows with outlier Year_Birth (< 1900)
-- ============================================================
DELETE FROM MarketingCampaign
WHERE TRY_CAST(Year_Birth AS SMALLINT) < 1900
   OR TRY_CAST(Year_Birth AS SMALLINT) IS NULL;
GO

-- ============================================================
-- Replace NULL or empty Income with MEDIAN
-- ============================================================
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

-- ============================================================
-- Trim text columns
-- ============================================================
UPDATE MarketingCampaign
SET Education      = LTRIM(RTRIM(Education)),
    Marital_Status = LTRIM(RTRIM(Marital_Status)),
    Country        = LTRIM(RTRIM(Country));
GO

-- ============================================================
-- Remove duplicate rows (keep lowest ID duplicate)
-- ============================================================
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

-- ============================================================
--  ALTER TABLE — change columns to correct data types
-- ============================================================

-- INT
ALTER TABLE MarketingCampaign ALTER COLUMN ID                   INT            NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN Kidhome              TINYINT        NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN Teenhome             TINYINT        NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN Recency              SMALLINT       NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN NumDealsPurchases    TINYINT        NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN NumWebPurchases      TINYINT        NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN NumCatalogPurchases  TINYINT        NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN NumStorePurchases    TINYINT        NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN NumWebVisitsMonth    TINYINT        NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN Year_Birth           SMALLINT       NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN AcceptedCmp1         TINYINT        NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN AcceptedCmp2         TINYINT        NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN AcceptedCmp3         TINYINT        NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN AcceptedCmp4         TINYINT        NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN AcceptedCmp5         TINYINT        NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN Response             TINYINT        NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN Complain             TINYINT        NOT NULL;

-- DECIMAL
ALTER TABLE MarketingCampaign ALTER COLUMN Income               DECIMAL(10,2)  NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN MntWines             DECIMAL(10,2)  NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN MntFruits            DECIMAL(10,2)  NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN MntMeatProducts      DECIMAL(10,2)  NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN MntFishProducts      DECIMAL(10,2)  NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN MntSweetProducts     DECIMAL(10,2)  NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN MntGoldProds         DECIMAL(10,2)  NOT NULL;

-- DATE
ALTER TABLE MarketingCampaign ALTER COLUMN Dt_Customer          DATE           NOT NULL;

-- NVARCHAR
ALTER TABLE MarketingCampaign ALTER COLUMN Education            NVARCHAR(50)   NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN Marital_Status       NVARCHAR(50)   NOT NULL;
ALTER TABLE MarketingCampaign ALTER COLUMN Country              NVARCHAR(50)   NOT NULL;
GO

USE MarketingCampaign_DB;
GO

-- ============================================================
--  Add new columns to the table
-- ============================================================
ALTER TABLE MarketingCampaign
    ADD Age                    TINYINT,
        AgeGroup               NVARCHAR(10),
        TotalSpend             DECIMAL(10,2),
        TotalPurchases         TINYINT,
        TotalCampaignsAccepted TINYINT,
        IncomeSegment          NVARCHAR(10),
        HasChildren            NVARCHAR(15),
        RecencySegment         NVARCHAR(10),
        CustomerTenure         SMALLINT,
        RFM_Segment            NVARCHAR(20);
GO

-- ============================================================
--  Age 
-- ============================================================
UPDATE MarketingCampaign
SET Age = YEAR('2014-06-01') - Year_Birth;
GO

-- ============================================================
-- AgeGroup 
-- ============================================================
UPDATE MarketingCampaign
SET AgeGroup = CASE
    WHEN Age < 30 THEN '18-29'
    WHEN Age < 40 THEN '30-39'
    WHEN Age < 50 THEN '40-49'
    WHEN Age < 60 THEN '50-59'
    ELSE '60+'
END;
GO

-- ============================================================
--  TotalSpend
-- ============================================================
UPDATE MarketingCampaign
SET TotalSpend = MntWines
               + MntFruits
               + MntMeatProducts
               + MntFishProducts
               + MntSweetProducts
               + MntGoldProds;
GO

-- ============================================================
--  TotalPurchases 
-- ============================================================
UPDATE MarketingCampaign
SET TotalPurchases = NumWebPurchases
                   + NumCatalogPurchases
                   + NumStorePurchases;
GO

-- ============================================================
--  TotalCampaignsAccepted 
-- ============================================================
UPDATE MarketingCampaign
SET TotalCampaignsAccepted = AcceptedCmp1
                            + AcceptedCmp2
                            + AcceptedCmp3
                            + AcceptedCmp4
                            + AcceptedCmp5
                            + Response;
GO

-- ============================================================
--  IncomeSegment
-- ============================================================
UPDATE MarketingCampaign
SET IncomeSegment = CASE
    WHEN Income < 30000 THEN 'Low'
    WHEN Income < 60000 THEN 'Mid'
    WHEN Income < 90000 THEN 'High'
    ELSE 'Premium'
END;
GO

-- ============================================================
-- HasChildren 
-- ============================================================
UPDATE MarketingCampaign
SET HasChildren = CASE
    WHEN Kidhome + Teenhome > 0 THEN 'Has Children'
    ELSE 'No Children'
END;
GO

-- ============================================================
--  RecencySegment 
-- ============================================================
UPDATE MarketingCampaign
SET RecencySegment = CASE
    WHEN Recency <= 30 THEN 'Active'
    WHEN Recency <= 60 THEN 'Recent'
    WHEN Recency <= 90 THEN 'Fading'
    ELSE 'Inactive'
END;
GO

-- ============================================================
-- CustomerTenure 
-- ============================================================
UPDATE MarketingCampaign
SET CustomerTenure = DATEDIFF(MONTH, Dt_Customer, '2014-06-01');
GO

-- ============================================================
--  RFM_Segment 
-- ============================================================
UPDATE MarketingCampaign
SET RFM_Segment = CASE
    WHEN Recency <= 30  AND TotalPurchases >= 10 AND TotalSpend >= 1000 THEN 'VIP'
    WHEN Recency <= 30  AND TotalSpend >= 1000                          THEN 'High Value New'
    WHEN Recency <= 60  AND TotalPurchases >= 5                         THEN 'Loyal'
    WHEN Recency <= 30  AND TotalPurchases < 5                          THEN 'New Customer'
    WHEN Recency > 90   AND TotalSpend >= 500                           THEN 'At Risk'
    WHEN Recency > 90                                                   THEN 'Inactive'
    ELSE 'Regular'
END;
GO





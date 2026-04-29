USE master;
GO

-- Drop and recreate the database if it already exists to ensure a clean slate for the ETL process

IF DB_ID('Healthcare_Cost_DB') IS NOT NULL
BEGIN
    ALTER DATABASE Healthcare_Cost_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Healthcare_Cost_DB;
END
GO

CREATE DATABASE Healthcare_Cost_DB;
GO

USE Healthcare_Cost_DB;
GO


-- TABLE: hospital_charges

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'hospital_charges')
    DROP TABLE hospital_charges;

CREATE TABLE hospital_charges (
    [Rndrng_Prvdr_CCN]          NVARCHAR(MAX),
    [Rndrng_Prvdr_Org_Name]     NVARCHAR(MAX),
    [Rndrng_Prvdr_City]         NVARCHAR(MAX),
    [Rndrng_Prvdr_St]           NVARCHAR(MAX),
    [Rndrng_Prvdr_State_FIPS]   NVARCHAR(MAX),
    [Rndrng_Prvdr_Zip5]         NVARCHAR(MAX),
    [Rndrng_Prvdr_State_Abrvtn] NVARCHAR(MAX),
    [Rndrng_Prvdr_RUCA]         NVARCHAR(MAX),
    [Rndrng_Prvdr_RUCA_Desc]    NVARCHAR(MAX),
    [DRG_Cd]                    NVARCHAR(MAX),
    [DRG_Desc]                  NVARCHAR(MAX),
    [Tot_Dschrgs]               NVARCHAR(MAX),
    [Avg_Submtd_Cvrd_Chrg]      NVARCHAR(MAX),
    [Avg_Tot_Pymt_Amt]          NVARCHAR(MAX),
    [Avg_Mdcr_Pymt_Amt]         NVARCHAR(MAX)
);
GO

-- TABLE: household_income

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'household_income')
    DROP TABLE household_income;

CREATE TABLE household_income (
    [State]                     NVARCHAR(MAX),
    [State_Abbreviation]        NVARCHAR(MAX),
    [Official_Median_Income_2024] NVARCHAR(MAX)
);
GO



-- =============================================================================================================
--  I used python to load the data into the hospital_charges table AND household_income table                  
-- there was a problem when i used the bulk insert statement in sql, so i used python to load the data instead 
-- =============================================================================================================


-- Now we will alter the data types of the columns in both tables to their appropriate types

-- hospital_charges
ALTER TABLE hospital_charges
    ALTER COLUMN [Tot_Dschrgs]            INT;

ALTER TABLE hospital_charges
    ALTER COLUMN [Avg_Submtd_Cvrd_Chrg]   DECIMAL(18,2);

ALTER TABLE hospital_charges
    ALTER COLUMN [Avg_Tot_Pymt_Amt]        DECIMAL(18,2);

ALTER TABLE hospital_charges
    ALTER COLUMN [Avg_Mdcr_Pymt_Amt]      DECIMAL(18,2);

ALTER TABLE hospital_charges
    ALTER COLUMN [Rndrng_Prvdr_RUCA]       DECIMAL(5,2);

ALTER TABLE hospital_charges
    ALTER COLUMN [Rndrng_Prvdr_State_FIPS] INT;

-- household_income
ALTER TABLE household_income
    ALTER COLUMN [Official_Median_Income_2024] DECIMAL(18,2);
GO

-- Now we will create a view that combines the data from both tables
CREATE VIEW vw_healthcare_analysis AS
SELECT
    h.[Rndrng_Prvdr_CCN],
    h.[Rndrng_Prvdr_Org_Name],
    h.[Rndrng_Prvdr_City],
    h.[Rndrng_Prvdr_St],
    h.[Rndrng_Prvdr_State_FIPS],
    h.[Rndrng_Prvdr_Zip5],
    h.[Rndrng_Prvdr_State_Abrvtn],
    h.[Rndrng_Prvdr_RUCA],
    h.[Rndrng_Prvdr_RUCA_Desc],
    h.[DRG_Cd],
    h.[DRG_Desc],
    h.[Tot_Dschrgs],
    h.[Avg_Submtd_Cvrd_Chrg],
    h.[Avg_Tot_Pymt_Amt],
    h.[Avg_Mdcr_Pymt_Amt],
    i.[State],
    i.[Official_Median_Income_2024]
FROM hospital_charges h
INNER JOIN household_income i
    ON h.Rndrng_Prvdr_State_Abrvtn = i.State_Abbreviation
WHERE
    h.Rndrng_Prvdr_Org_Name      IS NOT NULL
    AND h.Rndrng_Prvdr_State_Abrvtn IS NOT NULL
    AND h.DRG_Desc                IS NOT NULL
    AND h.Tot_Dschrgs             IS NOT NULL
    AND h.Avg_Mdcr_Pymt_Amt       IS NOT NULL
    AND i.Official_Median_Income_2024 IS NOT NULL;
GO

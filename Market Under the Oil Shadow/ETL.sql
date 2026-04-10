USE master;
GO

IF DB_ID('StockMarket_DB') IS NOT NULL
BEGIN
    ALTER DATABASE StockMarket_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE StockMarket_DB;
END
GO

CREATE DATABASE StockMarket_DB;
GO

USE StockMarket_DB;
GO

-- ============================================================
-- TABLE 1: stock_prices 
-- ============================================================
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'stock_prices')
    DROP TABLE stock_prices;

CREATE TABLE stock_prices (
    [Date]                  NVARCHAR(MAX),
    [Close]                 NVARCHAR(MAX),
    [High]                  NVARCHAR(MAX),
    [Low]                   NVARCHAR(MAX),
    [Open]                  NVARCHAR(MAX),
    [Volume]                NVARCHAR(MAX),
    [Ticker]                NVARCHAR(MAX),
    [Name]                  NVARCHAR(MAX),
    [Sector]                NVARCHAR(MAX),
    [Daily_Return_PCT]      NVARCHAR(MAX),
    [Intraday_Range]        NVARCHAR(MAX),
    [Intraday_Range_PCT]    NVARCHAR(MAX),
    [Volatility_30D]        NVARCHAR(MAX),
    [Avg_Volume_30D]        NVARCHAR(MAX),
    [MA_30D]                NVARCHAR(MAX),
    [MA_90D]                NVARCHAR(MAX),
    [Cumulative_Return_PCT] NVARCHAR(MAX),
    [Pct_Above_MA30]        NVARCHAR(MAX),
    [Prev_Close]            NVARCHAR(MAX),
    [Price_Change]          NVARCHAR(MAX),
    [Volume_Spike]          NVARCHAR(MAX)
);
GO

BULK INSERT stock_prices
FROM 'D:\Full Projects\project 11\data\stock_prices.csv'
WITH (
    FORMAT          = 'CSV',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    FIELDQUOTE      = '"',
    CODEPAGE        = '65001',
    TABLOCK
);
GO

-- ============================================================
-- TABLE 2: company_info 
-- ============================================================
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'company_info')
    DROP TABLE company_info;

CREATE TABLE company_info (
    [Ticker]                       NVARCHAR(MAX),
    [Name]                         NVARCHAR(MAX),
    [Sector]                       NVARCHAR(MAX),
    [shortName]                    NVARCHAR(MAX),
    [longName]                     NVARCHAR(MAX),
    [sector_yf]                    NVARCHAR(MAX),
    [industry]                     NVARCHAR(MAX),
    [country]                      NVARCHAR(MAX),
    [currency]                     NVARCHAR(MAX),
    [exchange]                     NVARCHAR(MAX),
    [marketCap]                    NVARCHAR(MAX),
    [enterpriseValue]              NVARCHAR(MAX),
    [trailingPE]                   NVARCHAR(MAX),
    [forwardPE]                    NVARCHAR(MAX),
    [priceToBook]                  NVARCHAR(MAX),
    [priceToSalesTrailing12Months] NVARCHAR(MAX),
    [dividendYield]                NVARCHAR(MAX),
    [dividendRate]                 NVARCHAR(MAX),
    [payoutRatio]                  NVARCHAR(MAX),
    [beta]                         NVARCHAR(MAX),
    [fiftyTwoWeekHigh]             NVARCHAR(MAX),
    [fiftyTwoWeekLow]              NVARCHAR(MAX),
    [fiftyDayAverage]              NVARCHAR(MAX),
    [twoHundredDayAverage]         NVARCHAR(MAX),
    [averageVolume]                NVARCHAR(MAX),
    [averageVolume10days]          NVARCHAR(MAX),
    [returnOnEquity]               NVARCHAR(MAX),
    [returnOnAssets]               NVARCHAR(MAX),
    [debtToEquity]                 NVARCHAR(MAX),
    [currentRatio]                 NVARCHAR(MAX),
    [revenueGrowth]                NVARCHAR(MAX),
    [earningsGrowth]               NVARCHAR(MAX),
    [totalRevenue]                 NVARCHAR(MAX),
    [grossMargins]                 NVARCHAR(MAX),
    [operatingMargins]             NVARCHAR(MAX),
    [profitMargins]                NVARCHAR(MAX),
    [recommendationMean]           NVARCHAR(MAX),
    [numberOfAnalystOpinions]      NVARCHAR(MAX),
    [targetMeanPrice]              NVARCHAR(MAX),
    [currentPrice]                 NVARCHAR(MAX),
    [Analyst_Upside_PCT]           NVARCHAR(MAX)
);
GO

BULK INSERT company_info
FROM 'D:\Full Projects\project 11\data\company_info.csv'
WITH (
    FORMAT          = 'CSV',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    FIELDQUOTE      = '"',
    CODEPAGE        = '65001',
    TABLOCK
);
GO

-- ============================================================
-- TABLE 3: oil_correlations 
-- ============================================================
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'oil_correlations')
    DROP TABLE oil_correlations;

CREATE TABLE oil_correlations (
    [Ticker]                NVARCHAR(MAX),
    [Name]                  NVARCHAR(MAX),
    [Sector]                NVARCHAR(MAX),
    [Oil_Correlation_Full]  NVARCHAR(MAX),
    [Oil_Correlation_30D]   NVARCHAR(MAX),
    [Correlation_Shift]     NVARCHAR(MAX),
    [Data_Days]             NVARCHAR(MAX),
    [Corr_Strength]         NVARCHAR(MAX),
    [Corr_Strength_30D]     NVARCHAR(MAX)
);
GO

BULK INSERT oil_correlations
FROM 'D:\Full Projects\project 11\data\oil_correlations.csv'
WITH (
    FORMAT          = 'CSV',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    FIELDQUOTE      = '"',
    CODEPAGE        = '65001',
    TABLOCK
);
GO

-- ============================================================
-- TABLE 4: sector_summary  
-- ============================================================
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'sector_summary')
    DROP TABLE sector_summary;

CREATE TABLE sector_summary (
    [Date]                  NVARCHAR(MAX),
    [Sector]                NVARCHAR(MAX),
    [Avg_Daily_Return]      NVARCHAR(MAX),
    [Avg_Volatility_30D]    NVARCHAR(MAX),
    [Avg_Cumulative_Return] NVARCHAR(MAX),
    [Avg_Volume_Spike]      NVARCHAR(MAX)
);
GO

BULK INSERT sector_summary
FROM 'D:\Full Projects\project 11\data\sector_summary.csv'
WITH (
    FORMAT          = 'CSV',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    FIELDQUOTE      = '"',
    CODEPAGE        = '65001',
    TABLOCK
);
GO

-- Alter data types to more appropriate ones for analysis 

-- ============================================================
-- TABLE 1: stock_prices
-- ============================================================
ALTER TABLE stock_prices ALTER COLUMN Date DATE NOT NULL;
ALTER TABLE stock_prices ALTER COLUMN [Close]                 DECIMAL(18,4);
ALTER TABLE stock_prices ALTER COLUMN [High]                  DECIMAL(18,4);
ALTER TABLE stock_prices ALTER COLUMN [Low]                   DECIMAL(18,4);
ALTER TABLE stock_prices ALTER COLUMN [Open]                  DECIMAL(18,4);
ALTER TABLE stock_prices ALTER COLUMN [Prev_Close]            DECIMAL(18,4);
ALTER TABLE stock_prices ALTER COLUMN [Price_Change]          DECIMAL(18,4);
ALTER TABLE stock_prices ALTER COLUMN [MA_30D]                DECIMAL(18,4);
ALTER TABLE stock_prices ALTER COLUMN [MA_90D]                DECIMAL(18,4);
ALTER TABLE stock_prices ALTER COLUMN [Volume]                BIGINT;
ALTER TABLE stock_prices ALTER COLUMN [Avg_Volume_30D]        DECIMAL(18,2);
ALTER TABLE stock_prices ALTER COLUMN [Daily_Return_PCT]      DECIMAL(10,4);
ALTER TABLE stock_prices ALTER COLUMN [Intraday_Range]        DECIMAL(18,4);
ALTER TABLE stock_prices ALTER COLUMN [Intraday_Range_PCT]    DECIMAL(10,4);
ALTER TABLE stock_prices ALTER COLUMN [Volatility_30D]        DECIMAL(10,4);
ALTER TABLE stock_prices ALTER COLUMN [Cumulative_Return_PCT] DECIMAL(10,4);
ALTER TABLE stock_prices ALTER COLUMN [Pct_Above_MA30]        DECIMAL(10,4);
ALTER TABLE stock_prices ALTER COLUMN [Volume_Spike]          TINYINT;
ALTER TABLE stock_prices ALTER COLUMN [Ticker]                NVARCHAR(20)    NOT NULL;
GO

-- ============================================================
-- TABLE 2: company_info
-- ============================================================
ALTER TABLE company_info ALTER COLUMN [Ticker]                NVARCHAR(20)    NOT NULL;
ALTER TABLE company_info ALTER COLUMN [marketCap]             DECIMAL(20,2);
ALTER TABLE company_info ALTER COLUMN [enterpriseValue]       DECIMAL(20,2);
ALTER TABLE company_info ALTER COLUMN [totalRevenue]          DECIMAL(20,2);
ALTER TABLE company_info ALTER COLUMN [marketCap]             BIGINT;
ALTER TABLE company_info ALTER COLUMN [enterpriseValue]       BIGINT;
ALTER TABLE company_info ALTER COLUMN [totalRevenue]          BIGINT;
ALTER TABLE company_info ALTER COLUMN [trailingPE]                   DECIMAL(10,4);
ALTER TABLE company_info ALTER COLUMN [forwardPE]                    DECIMAL(10,4);
ALTER TABLE company_info ALTER COLUMN [priceToBook]                  DECIMAL(10,4);
ALTER TABLE company_info ALTER COLUMN [priceToSalesTrailing12Months] DECIMAL(10,4);
ALTER TABLE company_info ALTER COLUMN [dividendYield]         DECIMAL(10,6);
ALTER TABLE company_info ALTER COLUMN [dividendRate]          DECIMAL(10,4);
ALTER TABLE company_info ALTER COLUMN [payoutRatio]           DECIMAL(10,4);
ALTER TABLE company_info ALTER COLUMN [beta]                  DECIMAL(10,4);
ALTER TABLE company_info ALTER COLUMN [fiftyTwoWeekHigh]      DECIMAL(18,4);
ALTER TABLE company_info ALTER COLUMN [fiftyTwoWeekLow]       DECIMAL(18,4);
ALTER TABLE company_info ALTER COLUMN [fiftyDayAverage]       DECIMAL(18,4);
ALTER TABLE company_info ALTER COLUMN [twoHundredDayAverage]  DECIMAL(18,4);
ALTER TABLE company_info ALTER COLUMN [currentPrice]          DECIMAL(18,4);
ALTER TABLE company_info ALTER COLUMN [targetMeanPrice]       DECIMAL(18,4);
ALTER TABLE company_info ALTER COLUMN [Analyst_Upside_PCT]    DECIMAL(10,2);
ALTER TABLE company_info ALTER COLUMN [averageVolume]         BIGINT;
ALTER TABLE company_info ALTER COLUMN [averageVolume10days]   BIGINT;
ALTER TABLE company_info ALTER COLUMN [returnOnEquity]        DECIMAL(10,4);
ALTER TABLE company_info ALTER COLUMN [returnOnAssets]        DECIMAL(10,4);
ALTER TABLE company_info ALTER COLUMN [debtToEquity]          DECIMAL(10,4);
ALTER TABLE company_info ALTER COLUMN [currentRatio]          DECIMAL(10,4);
ALTER TABLE company_info ALTER COLUMN [revenueGrowth]         DECIMAL(10,4);
ALTER TABLE company_info ALTER COLUMN [earningsGrowth]        DECIMAL(10,4);
ALTER TABLE company_info ALTER COLUMN [grossMargins]          DECIMAL(10,4);
ALTER TABLE company_info ALTER COLUMN [operatingMargins]      DECIMAL(10,4);
ALTER TABLE company_info ALTER COLUMN [profitMargins]         DECIMAL(10,4);
ALTER TABLE company_info ALTER COLUMN [recommendationMean]         DECIMAL(4,2);
ALTER TABLE company_info ALTER COLUMN [numberOfAnalystOpinions]    DECIMAL(6,2);
ALTER TABLE company_info ALTER COLUMN [numberOfAnalystOpinions]    SMALLINT;
GO

-- ============================================================
-- TABLE 3: oil_correlations
-- ============================================================
ALTER TABLE oil_correlations ALTER COLUMN [Ticker]            NVARCHAR(20)    NOT NULL;
ALTER TABLE oil_correlations ALTER COLUMN [Name]              NVARCHAR(100);
ALTER TABLE oil_correlations ALTER COLUMN [Sector]            NVARCHAR(50);
ALTER TABLE oil_correlations ALTER COLUMN [Oil_Correlation_Full]  DECIMAL(8,4);
ALTER TABLE oil_correlations ALTER COLUMN [Oil_Correlation_30D]   DECIMAL(8,4);
ALTER TABLE oil_correlations ALTER COLUMN [Correlation_Shift]     DECIMAL(8,4);
ALTER TABLE oil_correlations ALTER COLUMN [Data_Days]         SMALLINT;
GO

-- ============================================================
-- TABLE 4: sector_summary
-- ============================================================
ALTER TABLE sector_summary ALTER COLUMN [Date] DATE NOT NULL;
ALTER TABLE sector_summary ALTER COLUMN [Sector]                NVARCHAR(50) NOT NULL;
ALTER TABLE sector_summary ALTER COLUMN [Avg_Daily_Return]      DECIMAL(10,4);
ALTER TABLE sector_summary ALTER COLUMN [Avg_Volatility_30D]    DECIMAL(10,4);
ALTER TABLE sector_summary ALTER COLUMN [Avg_Cumulative_Return] DECIMAL(10,4);
ALTER TABLE sector_summary ALTER COLUMN [Avg_Volume_Spike]      DECIMAL(6,4);
GO

-- ============================================================
-- Create sectors lookup table
-- ============================================================
DROP TABLE IF EXISTS sectors;
GO

CREATE TABLE sectors (
    Sector NVARCHAR(50) PRIMARY KEY
);
GO

INSERT INTO sectors (Sector)
SELECT DISTINCT Sector FROM company_info
WHERE Sector IS NOT NULL;
GO

-- ============================================================
-- PRIMARY KEYS
-- ============================================================
ALTER TABLE company_info
    ADD CONSTRAINT PK_company_info PRIMARY KEY (Ticker);
GO

ALTER TABLE stock_prices
    ADD CONSTRAINT PK_stock_prices PRIMARY KEY (Ticker, Date);
GO

ALTER TABLE oil_correlations
    ADD CONSTRAINT PK_oil_correlations PRIMARY KEY (Ticker);
GO

ALTER TABLE sector_summary
    ADD CONSTRAINT PK_sector_summary PRIMARY KEY (Sector, Date);
GO

-- ============================================================
-- FOREIGN KEYS
-- ============================================================
ALTER TABLE stock_prices
    ADD CONSTRAINT FK_stock_prices_company
    FOREIGN KEY (Ticker) REFERENCES company_info (Ticker);
GO

ALTER TABLE oil_correlations
    ADD CONSTRAINT FK_oil_correlations_company
    FOREIGN KEY (Ticker) REFERENCES company_info (Ticker);
GO

ALTER TABLE sector_summary
    ADD CONSTRAINT FK_sector_summary_sectors
    FOREIGN KEY (Sector) REFERENCES sectors (Sector);
GO

-- Create the database only if it doesn't already exist
IF NOT EXISTS (
    SELECT 1 FROM sys.databases WHERE name = 'CryptoDB'
)

BEGIN
    CREATE DATABASE CryptoDB;
    PRINT '✅ Database "CryptoDB" has been created.';
END

ELSE
BEGIN
    PRINT 'ℹ️ Database "CryptoDB" already exists.';
END
GO

-- Use the CryptoDB database
USE CryptoDB;
GO

-- Create the crypto_ohlcv table

IF OBJECT_ID('crypto_ohlcv', 'U') IS NOT NULL
    DROP TABLE crypto_ohlcv;
BEGIN
    CREATE TABLE crypto_ohlcv (
        symbol        VARCHAR(20)  NOT NULL,
        [date]          DATE         NOT NULL,
        [open]          FLOAT        NOT NULL,
        [high]          FLOAT        NOT NULL,
        [low]           FLOAT        NOT NULL,
        [close]         FLOAT        NOT NULL,
        [volume]  DECIMAL(38,16)         NULL,
        [ret]           FLOAT        NULL,
        [volatility_30] FLOAT        NULL,
        [volume_avg30]  FLOAT        NULL,
        [vol_spike]     FLOAT        NULL,
        [running_max]   FLOAT        NULL,
        [drawdown]      FLOAT        NULL,
        [52w_low]       FLOAT          NULL,
        [post_low]      FLOAT        NULL,
        [gap]           BIT          NULL,
        CONSTRAINT pk_crypto PRIMARY KEY (symbol, [date])
    );
    END
PRINT '✅ Table "crypto_ohlcv" is ready.';
GO


IF NOT EXISTS (
    SELECT * FROM sys.objects 
    WHERE object_id = OBJECT_ID(N'crypto_market_cap') AND type = 'U'
)
BEGIN
    CREATE TABLE crypto_market_cap (
        coin_id     VARCHAR(50)  NOT NULL,
        [date]      DATE         NOT NULL,
        price       FLOAT        NOT NULL,
        volume      FLOAT        NOT NULL,
        market_cap  FLOAT        NOT NULL,
        CONSTRAINT pk_mc PRIMARY KEY (coin_id, [date])
    );
END
PRINT '✅ Table "crypto_market_cap" is ready.';
GO

-- Sample query to verify table creation
SELECT top 10 * from crypto_ohlcv;
SELECT top 10 * from crypto_market_cap;

-- Create a new table by joining crypto_ohlcv and crypto_market_cap
DROP TABLE IF EXISTS crypto_ohlcv_with_cap
GO

SELECT 
    o.*,
    m.market_cap
INTO crypto_ohlcv_with_cap
FROM crypto_ohlcv o
INNER JOIN crypto_market_cap m
    ON o.volume = m.volume
   AND o.[date] = m.[date];
-- SELECT
--     o.*,
--     m.market_cap
-- INTO crypto_ohlcv_with_cap
-- FROM crypto_ohlcv o
-- RIGHT JOIN crypto_market_cap m
--     ON LOWER(LTRIM(RTRIM(o.symbol))) = LOWER(LTRIM(RTRIM(m.coin_id)))
--    AND o.[date] = m.[date]
-- WHERE o.[date] IS NOT NULL;


-- Sample query to verify the new table creation
select * from crypto_ohlcv_with_cap
where market_cap IS NULL

USE CryptoDB;
GO

-- 1) Null counts per symbol
SELECT [symbol],
       COUNT(*) - COUNT([open])  AS null_open,
       COUNT(*) - COUNT([high])  AS null_high,
       COUNT(*) - COUNT([low])   AS null_low,
       COUNT(*) - COUNT([close]) AS null_close,
       COUNT(*) - COUNT([volume]) AS null_vol,
       COUNT(*) - COUNT([market_cap]) AS null_mc
FROM crypto_ohlcv_with_cap
GROUP BY [symbol]
HAVING (COUNT(*) - COUNT([open])) +
       (COUNT(*) - COUNT([high])) +
       (COUNT(*) - COUNT([low])) +
       (COUNT(*) - COUNT([close])) +
       (COUNT(*) - COUNT([volume])) +
       (COUNT(*) - COUNT([market_cap])) > 0;

-- 2) Duplicate rows
SELECT [symbol], [date], COUNT(*) AS dupes
FROM crypto_ohlcv_with_cap
GROUP BY [symbol], [date]
HAVING COUNT(*) > 1;

-- 3) Close outside High-Low
SELECT [symbol], [date], [close], [high], [low]
FROM crypto_ohlcv_with_cap
WHERE [close] < [low] OR [close] > [high];

-- 4) Negative volume or market-cap
SELECT [symbol], [date], [volume], [market_cap]
FROM crypto_ohlcv_with_cap
WHERE [volume] < 0 OR [market_cap] < 0;

-- 5) High < Low
SELECT [symbol], [date], [high], [low]
FROM crypto_ohlcv_with_cap
WHERE [high] < [low];

-- 6) Daily return outliers (|ret| > 50 %)
SELECT [symbol], [date], [ret]
FROM crypto_ohlcv_with_cap
WHERE ABS([ret]) > 0.50;

-- 7) Gaps greater than 90%
WITH gaps AS (
    SELECT 
        symbol,
        [date],
        [close],
        LAG([close]) OVER (PARTITION BY symbol ORDER BY [date]) AS prev_close,
        LAG([date])  OVER (PARTITION BY symbol ORDER BY [date]) AS prev_date,
        DATEDIFF(DAY, LAG([date]) OVER (PARTITION BY symbol ORDER BY [date]), [date]) AS day_diff,
        ([close] / LAG([close]) OVER (PARTITION BY symbol ORDER BY [date]) - 1) AS gap_pct
    FROM crypto_ohlcv_with_cap
)
SELECT 
    symbol,
    [date],
    prev_date,
    day_diff,
    [close],
    prev_close,
    gap_pct
FROM gaps
WHERE ABS(gap_pct) > 0.90
ORDER BY ABS(gap_pct) DESC;

-- 8) Volume spike vs 30-day average (> 5×)
WITH monthly AS (
    SELECT 
        symbol,
        YEAR([date]) AS yr,
        MONTH([date]) AS mn,
        AVG([volume]) AS avg_monthly_volume
    FROM crypto_ohlcv_with_cap
    GROUP BY symbol, YEAR([date]), MONTH([date])
)
SELECT 
    o.symbol,
    o.[date],
    o.[volume],
    m.avg_monthly_volume,
    o.[volume] / NULLIF(m.avg_monthly_volume, 0) AS spike_ratio
FROM crypto_ohlcv_with_cap o
JOIN monthly m
    ON o.symbol = m.symbol
   AND YEAR(o.[date]) = m.yr
   AND MONTH(o.[date]) = m.mn
WHERE o.[volume] / NULLIF(m.avg_monthly_volume, 0) > 5.0
ORDER BY spike_ratio DESC;

-- 9) Overall summary view
CREATE OR ALTER VIEW vw_crypto_summary AS
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT symbol) AS symbols,
    MIN([date]) AS start_date,
    MAX([date]) AS end_date,
    SUM(CASE WHEN ABS([ret]) > 0.50 THEN 1 ELSE 0 END) AS outlier_50pct,
    SUM(CASE WHEN [close] < [low] OR [close] > [high] THEN 1 ELSE 0 END) AS gap_errors,
    SUM(CASE WHEN [ret] IS NULL THEN 1 ELSE 0 END) AS null_ret
FROM crypto_ohlcv_with_cap;

-- Query the summary view
select * from vw_crypto_summary;
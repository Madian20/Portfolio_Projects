-- =============================================================
-- EDA for stock_prices dataset
-- =============================================================

-- 1. Price range per ticker over the full 3-year period
SELECT
    [Ticker],
    [Name],
    [Sector],
    MIN([Close])                          AS Min_Close,
    MAX([Close])                          AS Max_Close,
    MAX([Close]) - MIN([Close])             AS Price_Range,
    ROUND(
        (MAX([Close]) - MIN([Close]))
        / NULLIF(MIN([Close]), 0) * 100
    , 2)                                AS Range_PCT
FROM stock_prices
GROUP BY [Ticker], [Name], [Sector]
ORDER BY Range_PCT DESC;

-- 2. Total return: compare first close vs last close per ticker
WITH first_day AS (
    SELECT
        [Ticker],
        [Close] AS First_Close,
        ROW_NUMBER() OVER (PARTITION BY [Ticker] ORDER BY [Date] ASC) AS rn
    FROM stock_prices
),
last_day AS (
    SELECT
        [Ticker],
        [Close] AS Last_Close,
        ROW_NUMBER() OVER (PARTITION BY [Ticker] ORDER BY [Date] DESC) AS rn
    FROM stock_prices
)
SELECT
    sp.[Ticker],
    sp.[Name],
    sp.[Sector],
    f.First_Close,
    l.Last_Close,
    ROUND(
        (l.Last_Close - f.First_Close)
        / NULLIF(f.First_Close, 0) * 100
    , 2)                                AS Total_Return_PCT
FROM stock_prices sp
JOIN first_day f ON sp.[Ticker] = f.[Ticker] AND f.rn = 1
JOIN last_day  l ON sp.[Ticker] = l.[Ticker] AND l.rn = 1
GROUP BY sp.[Ticker], sp.[Name], sp.[Sector], f.First_Close, l.Last_Close
ORDER BY Total_Return_PCT DESC;

-- 3. Average daily volatility per sector
SELECT
    [Sector],
    ROUND(AVG([Volatility_30D]), 4)       AS Avg_Volatility,
    ROUND(MAX([Volatility_30D]), 4)       AS Max_Volatility,
    ROUND(MIN([Volatility_30D]), 4)       AS Min_Volatility
FROM stock_prices
WHERE [Volatility_30D] IS NOT NULL
GROUP BY [Sector]
ORDER BY [Avg_Volatility] DESC;

-- 4. Count and percentage of volume spike days per ticker
SELECT
    [Ticker],
    [Name],
    [Sector],
    COUNT(*)                                        AS Total_Days,
    SUM([Volume_Spike])                               AS Spike_Days,
    ROUND(
        SUM([Volume_Spike]) * 100.0
        / NULLIF(COUNT(*), 0)
    , 2)                                            AS Spike_PCT
FROM stock_prices
GROUP BY [Ticker], [Name], [Sector]
ORDER BY [Spike_PCT] DESC;

-- 5. Top 10 single-day returns across all tickers
SELECT TOP 10
    [Date],
    [Ticker],
    [Name],
    [Sector],
    [Close],
    [Daily_Return_PCT]
FROM stock_prices
WHERE [Daily_Return_PCT] IS NOT NULL
ORDER BY [Daily_Return_PCT] DESC;

-- 6. Bottom 10 single-day returns across all tickers
SELECT TOP 10
    [Date],
    [Ticker],
    [Name],
    [Sector],
    [Close],
    [Daily_Return_PCT]
FROM stock_prices
WHERE [Daily_Return_PCT] IS NOT NULL
ORDER BY [Daily_Return_PCT] ASC;

-- 7. Monthly average return per sector
SELECT
    YEAR([Date])                          AS Year,
    MONTH([Date])                         AS Month,
    [Sector],
    ROUND(AVG([Daily_Return_PCT]), 4)     AS Avg_Monthly_Return_PCT
FROM stock_prices
WHERE [Daily_Return_PCT] IS NOT NULL
  AND [Sector] NOT IN ('Benchmarks', 'Oil & Energy')
GROUP BY YEAR([Date]), MONTH([Date]), [Sector]
ORDER BY Year, Month, Sector;

-- 8. Full correlation ranking vs oil price
SELECT
    [Ticker],
    [Name],
    [Sector],
    [Oil_Correlation_Full],
    [Oil_Correlation_30D],
    [Correlation_Shift],
    [Corr_Strength],
    [Corr_Strength_30D]
FROM oil_correlations
ORDER BY [Oil_Correlation_Full] DESC;

-- 9. Sectors with biggest recent correlation shift vs oil
SELECT
    oc.[Sector],
    ROUND(AVG(oc.[Oil_Correlation_Full]), 4)  AS Avg_Corr_Full,
    ROUND(AVG(oc.[Oil_Correlation_30D]), 4)   AS Avg_Corr_30D,
    ROUND(AVG(oc.[Correlation_Shift]), 4)     AS Avg_Shift
FROM oil_correlations oc
GROUP BY oc.[Sector]
ORDER BY ABS(AVG(oc.[Correlation_Shift])) DESC;

-- 10. Average cumulative return per sector over time
-- Using the last available date per sector as final value
WITH last_date AS (
    SELECT
        [Sector],
        MAX([Date]) AS Last_Date
    FROM sector_summary
    GROUP BY [Sector]
)
SELECT
    ss.[Sector],
    ROUND(ss.[Avg_Cumulative_Return], 2)  AS Final_Cumulative_Return
FROM sector_summary ss
JOIN last_date ld
    ON ss.[Sector] = ld.[Sector]
    AND ss.[Date]  = ld.[Last_Date]
ORDER BY Final_Cumulative_Return DESC;

-- 11. Large cap stocks with high beta (high risk)
SELECT TOP 10
    [Ticker],
    [Name],
    [Sector],
    ROUND([marketCap] / 1000000000.0, 2)  AS [MarketCap(B)],
    [beta],
    [trailingPE],
    [Analyst_Upside_PCT]
FROM company_info
WHERE [beta] IS NOT NULL
  AND [marketCap] IS NOT NULL
ORDER BY [beta] DESC;

-- 12. Days where ALL sectors had negative average return simultaneously
WITH sector_daily AS (
    SELECT
        [Date],
        -- Count sectors with negative return that day
        SUM(CASE WHEN [Avg_Daily_Return] < 0 THEN 1 ELSE 0 END) AS Negative_Sectors,
        COUNT(*)                                                AS Total_Sectors,
        ROUND(AVG([Avg_Daily_Return]), 4)                        AS Market_Avg_Return
    FROM sector_summary
    GROUP BY [Date]
)
SELECT TOP 20
    [Date],
    [Negative_Sectors],
    [Total_Sectors],
    [Market_Avg_Return]
FROM sector_daily
WHERE [Negative_Sectors] = [Total_Sectors]   -- all sectors negative
ORDER BY [Market_Avg_Return] ASC;

-- 13. Stocks currently below MA90 but with positive analyst upside
WITH latest_price AS (
    SELECT
        [Ticker],
        [Close],
        [MA_90D],
        [Pct_Above_MA30],
        ROW_NUMBER() OVER (PARTITION BY [Ticker] ORDER BY [Date] DESC) AS rn
    FROM [stock_prices]
)
SELECT
    lp.[Ticker],
    ci.[Name],
    ci.[Sector],
    lp.[Close],
    lp.[MA_90D],
    ROUND(
        (lp.[Close] - lp.[MA_90D])
        / NULLIF(lp.[MA_90D], 0) * 100
    , 2)                                AS PCT_Below_MA90,
    ci.[Analyst_Upside_PCT]
FROM latest_price lp
JOIN company_info ci ON lp.[Ticker] = ci.[Ticker]
WHERE lp.[rn] = 1
  AND lp.[Close] < lp.[MA_90D]               -- below MA90 technically
  AND ci.[Analyst_Upside_PCT] > 10         -- analysts expect 10%+ upside
ORDER BY ci.[Analyst_Upside_PCT] DESC;
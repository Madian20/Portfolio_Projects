USE Healthcare_Cost_DB;
GO

-- ============================================================
-- Q1: How many records, hospitals, states, and DRG codes?
-- ============================================================
SELECT
    COUNT(*)                                    AS total_records,
    COUNT(DISTINCT Rndrng_Prvdr_CCN)            AS total_hospitals,
    COUNT(DISTINCT Rndrng_Prvdr_State_Abrvtn)   AS total_states,
    COUNT(DISTINCT DRG_Cd)                      AS total_drg_codes
FROM vw_healthcare_analysis;
GO

-- ============================================================
-- Q2: What is the overall cost distribution?
-- ============================================================
SELECT
    MIN(Avg_Tot_Pymt_Amt)                                        AS min_payment,
    MAX(Avg_Tot_Pymt_Amt)                                        AS max_payment,
    ROUND(AVG(Avg_Tot_Pymt_Amt), 2)                              AS avg_payment,
    ROUND(STDEV(Avg_Tot_Pymt_Amt), 2)                            AS std_dev_payment
FROM vw_healthcare_analysis;
GO

-- ============================================================
-- Q3: Which states are the most and least expensive?
-- ============================================================
SELECT TOP 5
    [State],
    ROUND(AVG(Avg_Tot_Pymt_Amt), 2)         AS avg_total_payment
FROM vw_healthcare_analysis
GROUP BY [State]
ORDER BY avg_total_payment DESC;
GO

SELECT TOP 5
    [State],
    ROUND(AVG(Avg_Tot_Pymt_Amt), 2)         AS avg_total_payment
FROM vw_healthcare_analysis
GROUP BY [State]
ORDER BY avg_total_payment ASC;
GO

-- ============================================================
-- Q4: Most common vs most expensive conditions
-- ============================================================
-- Most common conditions
SELECT TOP 10
    DRG_Cd,
    DRG_Desc,
    SUM(Tot_Dschrgs)                        AS total_discharges,
    ROUND(AVG(Avg_Tot_Pymt_Amt), 2)         AS avg_total_payment
FROM vw_healthcare_analysis
GROUP BY DRG_Cd, DRG_Desc
ORDER BY total_discharges DESC;
GO

-- Most expensive conditions
SELECT TOP 10
    DRG_Cd,
    DRG_Desc,
    SUM(Tot_Dschrgs)                        AS total_discharges,
    ROUND(AVG(Avg_Tot_Pymt_Amt), 2)         AS avg_total_payment
FROM vw_healthcare_analysis
GROUP BY DRG_Cd, DRG_Desc
ORDER BY avg_total_payment DESC;
GO

-- ============================================================
-- Q5: Most and least expensive hospitals
-- ============================================================
SELECT TOP 5
    Rndrng_Prvdr_Org_Name                   AS hospital,
    [State],
    ROUND(AVG(Avg_Tot_Pymt_Amt), 2)         AS avg_total_payment,
    SUM(Tot_Dschrgs)                        AS total_discharges
FROM vw_healthcare_analysis
GROUP BY Rndrng_Prvdr_Org_Name, [State]
ORDER BY avg_total_payment DESC;
GO

SELECT TOP 5
    Rndrng_Prvdr_Org_Name                   AS hospital,
    [State],
    ROUND(AVG(Avg_Tot_Pymt_Amt), 2)         AS avg_total_payment,
    SUM(Tot_Dschrgs)                        AS total_discharges
FROM vw_healthcare_analysis
GROUP BY Rndrng_Prvdr_Org_Name, [State]
ORDER BY avg_total_payment ASC;
GO

-- ============================================================
-- Q6: Affordability — cost as % of household income by state
-- ============================================================
SELECT
    [State],
    ROUND(AVG(Avg_Tot_Pymt_Amt), 2)                         AS avg_total_payment,
    MAX(Official_Median_Income_2024)                        AS median_household_income,
    ROUND(AVG(Avg_Tot_Pymt_Amt) /
          NULLIF(MAX(Official_Median_Income_2024), 0) * 100, 2) AS affordability_ratio_pct
FROM vw_healthcare_analysis
GROUP BY [State]
ORDER BY affordability_ratio_pct DESC;
GO

-- ============================================================
-- Q7: Urban vs Rural cost difference
-- ============================================================
SELECT
    CASE
        WHEN FLOOR(Rndrng_Prvdr_RUCA) IN (1, 2, 3) THEN 'Metropolitan'
        WHEN FLOOR(Rndrng_Prvdr_RUCA) IN (4, 5, 6) THEN 'Micropolitan'
        WHEN FLOOR(Rndrng_Prvdr_RUCA) IN (7, 8, 9) THEN 'Small Town'
        WHEN FLOOR(Rndrng_Prvdr_RUCA) = 10         THEN 'Rural'
        ELSE 'Unknown'
    END                                                     AS area_type,
    COUNT(DISTINCT Rndrng_Prvdr_CCN)                        AS total_hospitals,
    SUM(Tot_Dschrgs)                                        AS total_discharges,
    ROUND(AVG(Avg_Tot_Pymt_Amt), 2)                         AS avg_total_payment
FROM vw_healthcare_analysis
WHERE Rndrng_Prvdr_RUCA != 99
GROUP BY
    CASE
        WHEN FLOOR(Rndrng_Prvdr_RUCA) IN (1, 2, 3) THEN 'Metropolitan'
        WHEN FLOOR(Rndrng_Prvdr_RUCA) IN (4, 5, 6) THEN 'Micropolitan'
        WHEN FLOOR(Rndrng_Prvdr_RUCA) IN (7, 8, 9) THEN 'Small Town'
        WHEN FLOOR(Rndrng_Prvdr_RUCA) = 10         THEN 'Rural'
        ELSE 'Unknown'
    END
ORDER BY avg_total_payment DESC;
GO

-- ============================================================
-- Q8: High cost + Low income states — most financially stressed
-- ============================================================
WITH state_stats AS (
    SELECT
        [State],
        ROUND(AVG(Avg_Tot_Pymt_Amt), 2) AS avg_payment,
        MAX(Official_Median_Income_2024) AS median_income,
        ROUND(
            AVG(Avg_Tot_Pymt_Amt) /
            NULLIF(MAX(Official_Median_Income_2024), 0) * 100, 
        2) AS affordability_ratio_pct
    FROM vw_healthcare_analysis
    GROUP BY [State]
),
[national] AS (
    SELECT
        AVG(Avg_Tot_Pymt_Amt) AS national_avg_payment,
        AVG(Official_Median_Income_2024) AS national_avg_income
    FROM vw_healthcare_analysis
)

SELECT
    s.state,
    s.avg_payment,
    s.median_income,
    s.affordability_ratio_pct
FROM state_stats s
CROSS JOIN [national] n
WHERE s.avg_payment > n.national_avg_payment
  AND s.median_income < n.national_avg_income
ORDER BY s.affordability_ratio_pct DESC;

GO


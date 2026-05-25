USE master;
GO

USE Healthcare_DB;
GO

-- =========================================================
--   How many records exist in each table?
-- =========================================================
SELECT 'encounters' AS TableName, COUNT(*) AS TotalRows FROM encounters
UNION ALL
SELECT 'organizations', COUNT(*) FROM organizations
UNION ALL
SELECT 'patients', COUNT(*) FROM patients
UNION ALL
SELECT 'payers', COUNT(*) FROM payers
UNION ALL
SELECT 'procedures', COUNT(*) FROM procedures;
GO

-- ==================================================================================
--  What are the distinct encounter classes and their counts and average claim cost?
-- ================================================================================== 
SELECT 
    EncounterClass,
    COUNT(*) AS TotalEncounters,
    ROUND(AVG(Total_Claim_Cost), 2) AS AvgClaimCost
FROM encounters
GROUP BY EncounterClass
ORDER BY TotalEncounters DESC;
GO

-- =========================================================
-- What are the most common & expensive medical procedures?
-- =========================================================
SELECT DISTINCT TOP 10
    Description,
    COUNT(*) AS ProcedureCount
FROM procedures
GROUP BY Description
ORDER BY ProcedureCount DESC;
GO

SELECT DISTINCT TOP 10
    Description,
    base_cost AS ProcedureCost,
    COUNT(*) AS ProcedureCount
FROM procedures
GROUP BY Description, base_cost
ORDER BY ProcedureCost DESC;
GO

-- =========================================================
--  Which encounters had the highest total claim cost?
--  ========================================================= 
SELECT TOP 10
    Id,
    EncounterClass,
    Description,
    Total_Claim_Cost
FROM encounters
ORDER BY Total_Claim_Cost DESC;
GO

-- =========================================================
--  What are the most common encounter reasons?
-- ========================================================= 
SELECT TOP 10
    ReasonDescription,
    COUNT(*) AS TotalCases
FROM encounters
WHERE ReasonDescription IS NOT NULL
GROUP BY ReasonDescription
ORDER BY TotalCases DESC;
GO

-- =========================================================
--   What is the yearly trend of encounters?
-- ========================================================= 
SELECT
    YEAR([Start]) AS EncounterYear,
    COUNT(*) AS TotalEncounters
FROM encounters
GROUP BY YEAR([Start])
ORDER BY EncounterYear;
GO

-- =========================================================
--   What is the gender distribution of patients?
-- ========================================================= 
SELECT
    Gender,
    COUNT(*) AS TotalPatients
FROM patients
GROUP BY Gender
ORDER BY TotalPatients DESC;
GO

-- =========================================================
-- What is the racial distribution of patients and their average insurance coverage percentage?
-- =========================================================
SELECT
    p.Race,
    ROUND(AVG(
        CASE
            WHEN e.Total_Claim_Cost = 0 THEN 0
            ELSE e.Payer_Coverage * 1.0 / e.Total_Claim_Cost * 100
        END
    ), 2) AS AvgInsuranceCoverage_Pct,
    COUNT(DISTINCT p.Id) AS TotalPatients
FROM patients p
INNER JOIN encounters e ON p.Id = e.Patient
GROUP BY p.Race
ORDER BY TotalPatients DESC;
GO

-- =================================================================
--   Which insurance companies provide the highest average coverage
-- =================================================================

SELECT TOP 10
    p.Name AS [Insurance Company],
        ROUND(AVG(
        CASE
            WHEN e.Total_Claim_Cost = 0 THEN 0
            ELSE e.Payer_Coverage * 1.0 / e.Total_Claim_Cost * 100
        END
    ), 2) AS AvgInsuranceCoverage_Pct
FROM encounters e
INNER JOIN payers p
    ON e.Payer = p.Id
GROUP BY p.Name
ORDER BY AvgInsuranceCoverage_Pct DESC;
GO

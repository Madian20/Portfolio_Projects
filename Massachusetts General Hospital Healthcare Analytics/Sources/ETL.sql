USE master;
GO

IF DB_ID('Healthcare_DB') IS NOT NULL
BEGIN
    ALTER DATABASE Healthcare_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Healthcare_DB;
END
GO

CREATE DATABASE Healthcare_DB;
GO

USE Healthcare_DB;
GO

-- ==========================================================================
-- Create tables with initial NVARCHAR(MAX) data types for all columns
-- ==========================================================================

-- TABLE 1: encounters

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'encounters')
    DROP TABLE encounters;

CREATE TABLE encounters (
    [Id]                    NVARCHAR(MAX),
    [Start]                 NVARCHAR(MAX),
    [Stop]                  NVARCHAR(MAX),
    [Patient]               NVARCHAR(MAX),
    [Organization]          NVARCHAR(MAX),
    [Payer]                 NVARCHAR(MAX),
    [EncounterClass]        NVARCHAR(MAX),
    [Code]                  NVARCHAR(MAX),
    [Description]           NVARCHAR(MAX),
    [Base_Encounter_Cost]   NVARCHAR(MAX),
    [Total_Claim_Cost]      NVARCHAR(MAX),
    [Payer_Coverage]        NVARCHAR(MAX),
    [ReasonCode]            NVARCHAR(MAX),
    [ReasonDescription]     NVARCHAR(MAX)
);
GO

-- TABLE 2: organizations

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'organizations')
    DROP TABLE organizations;

CREATE TABLE organizations (
    [Id]        NVARCHAR(MAX),
    [Name]      NVARCHAR(MAX),
    [Address]   NVARCHAR(MAX),
    [City]      NVARCHAR(MAX),
    [State]     NVARCHAR(MAX),
    [Zip]       NVARCHAR(MAX),
    [Lat]       NVARCHAR(MAX),
    [Lon]       NVARCHAR(MAX)
);
GO

-- TABLE 3: patients

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'patients')
    DROP TABLE patients;

CREATE TABLE patients (
    [Id]                NVARCHAR(MAX),
    [BirthDate]         NVARCHAR(MAX),
    [DeathDate]         NVARCHAR(MAX),
    [Prefix]            NVARCHAR(MAX),
    [First]             NVARCHAR(MAX),
    [Middle]            NVARCHAR(MAX),
    [Last]              NVARCHAR(MAX),
    [Suffix]            NVARCHAR(MAX),
    [Maiden]            NVARCHAR(MAX),
    [Marital]           NVARCHAR(MAX),
    [Race]              NVARCHAR(MAX),
    [Ethnicity]         NVARCHAR(MAX),
    [Gender]            NVARCHAR(MAX),
    [BirthPlace]        NVARCHAR(MAX),
    [Address]           NVARCHAR(MAX),
    [City]              NVARCHAR(MAX),
    [State]             NVARCHAR(MAX),
    [County]            NVARCHAR(MAX),
    [FIPS County Code]  NVARCHAR(MAX),
    [Zip]               NVARCHAR(MAX),
    [Lat]               NVARCHAR(MAX),
    [Lon]               NVARCHAR(MAX)
);
GO

-- TABLE 4: payers

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'payers')
    DROP TABLE payers;

CREATE TABLE payers (
    [Id]                    NVARCHAR(MAX),
    [Name]                  NVARCHAR(MAX),
    [Address]               NVARCHAR(MAX),
    [City]                  NVARCHAR(MAX),
    [State_Headquartered]   NVARCHAR(MAX),
    [Zip]                   NVARCHAR(MAX),
    [Phone]                 NVARCHAR(MAX)
);
GO

-- TABLE 5: procedures

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'procedures')
    DROP TABLE procedures;

CREATE TABLE procedures (
    [Start]             NVARCHAR(MAX),
    [Stop]              NVARCHAR(MAX),
    [Patient]           NVARCHAR(MAX),
    [Encounter]         NVARCHAR(MAX),
    [Code]              NVARCHAR(MAX),
    [Description]       NVARCHAR(MAX),
    [Base_Cost]         NVARCHAR(MAX),
    [ReasonCode]        NVARCHAR(MAX),
    [ReasonDescription] NVARCHAR(MAX)
);
GO

-- ==========================================================================
-- ALTER column data types to appropriate types after initial load
-- ==========================================================================
 

-- TABLE 1: encounters
ALTER TABLE encounters ALTER COLUMN [Id]                  NVARCHAR(50)        NOT NULL;
ALTER TABLE encounters ALTER COLUMN [Start]               DATETIME2           NULL;
ALTER TABLE encounters ALTER COLUMN [Stop]                DATETIME2           NULL;
ALTER TABLE encounters ALTER COLUMN [Patient]             NVARCHAR(50)        NOT NULL;
ALTER TABLE encounters ALTER COLUMN [Organization]        NVARCHAR(50)        NOT NULL;
ALTER TABLE encounters ALTER COLUMN [Payer]               NVARCHAR(50)        NOT NULL;
ALTER TABLE encounters ALTER COLUMN [EncounterClass]      NVARCHAR(50)        NOT NULL;
ALTER TABLE encounters ALTER COLUMN [Code]                NVARCHAR(50)        NOT NULL;
ALTER TABLE encounters ALTER COLUMN [Base_Encounter_Cost] DECIMAL(18, 2)      NOT NULL;
ALTER TABLE encounters ALTER COLUMN [Total_Claim_Cost]    DECIMAL(18, 2)      NOT NULL;
ALTER TABLE encounters ALTER COLUMN [Payer_Coverage]      DECIMAL(18, 2)      NOT NULL;
ALTER TABLE encounters ALTER COLUMN [ReasonCode]          NVARCHAR(50)        NULL;
GO
 
-- TABLE 2: organizations
ALTER TABLE organizations ALTER COLUMN [Id]       NVARCHAR(50)    NOT NULL;
ALTER TABLE organizations ALTER COLUMN [City]     NVARCHAR(100)   NULL;
ALTER TABLE organizations ALTER COLUMN [State]    NVARCHAR(100)   NULL;
ALTER TABLE organizations ALTER COLUMN [Zip]      NVARCHAR(20)    NULL;
ALTER TABLE organizations ALTER COLUMN [Lat]      DECIMAL(9, 6)   NULL;
ALTER TABLE organizations ALTER COLUMN [Lon]      DECIMAL(9, 6)   NULL;
GO
 
-- TABLE 3: patients
ALTER TABLE patients ALTER COLUMN [Id]                NVARCHAR(50)    NOT NULL;
ALTER TABLE patients ALTER COLUMN [BirthDate]         DATE            NOT NULL;
ALTER TABLE patients ALTER COLUMN [DeathDate]         DATE            NULL;
ALTER TABLE patients ALTER COLUMN [Prefix]            NVARCHAR(20)    NULL;
ALTER TABLE patients ALTER COLUMN [First]             NVARCHAR(100)   NOT NULL;
ALTER TABLE patients ALTER COLUMN [Middle]            NVARCHAR(100)   NULL;
ALTER TABLE patients ALTER COLUMN [Last]              NVARCHAR(100)   NOT NULL;
ALTER TABLE patients ALTER COLUMN [Suffix]            NVARCHAR(20)    NULL;
ALTER TABLE patients ALTER COLUMN [Maiden]            NVARCHAR(100)   NULL;
ALTER TABLE patients ALTER COLUMN [Marital]           NVARCHAR(1)     NULL;
ALTER TABLE patients ALTER COLUMN [Race]              NVARCHAR(100)   NULL;
ALTER TABLE patients ALTER COLUMN [Ethnicity]         NVARCHAR(100)   NULL;
ALTER TABLE patients ALTER COLUMN [Gender]            NVARCHAR(1)     NOT NULL;
ALTER TABLE patients ALTER COLUMN [City]              NVARCHAR(100)   NULL;
ALTER TABLE patients ALTER COLUMN [State]             NVARCHAR(100)   NULL;
ALTER TABLE patients ALTER COLUMN [County]            NVARCHAR(100)   NULL;
ALTER TABLE patients ALTER COLUMN [FIPS County Code]  NVARCHAR(20)    NULL;
ALTER TABLE patients ALTER COLUMN [Zip]               NVARCHAR(20)    NULL;
ALTER TABLE patients ALTER COLUMN [Lat]               DECIMAL(9, 6)   NULL;
ALTER TABLE patients ALTER COLUMN [Lon]               DECIMAL(9, 6)   NULL;
GO

-- TABLE 4: payers
ALTER TABLE payers ALTER COLUMN [Id]                   NVARCHAR(50)    NOT NULL;
ALTER TABLE payers ALTER COLUMN [City]                 NVARCHAR(100)   NULL;
ALTER TABLE payers ALTER COLUMN [State_Headquartered]  NVARCHAR(100)   NULL;
ALTER TABLE payers ALTER COLUMN [Zip]                  NVARCHAR(20)    NULL;
ALTER TABLE payers ALTER COLUMN [Phone]                NVARCHAR(20)    NULL;
GO
 
-- TABLE 5: procedures
ALTER TABLE procedures ALTER COLUMN [Start]             DATETIME2       NOT NULL;
ALTER TABLE procedures ALTER COLUMN [Stop]              DATETIME2       NULL;
ALTER TABLE procedures ALTER COLUMN [Patient]           NVARCHAR(50)    NOT NULL;
ALTER TABLE procedures ALTER COLUMN [Encounter]         NVARCHAR(50)    NOT NULL;
ALTER TABLE procedures ALTER COLUMN [Code]              NVARCHAR(50)    NOT NULL;
ALTER TABLE procedures ALTER COLUMN [Base_Cost]         DECIMAL(18, 2)  NOT NULL;
ALTER TABLE procedures ALTER COLUMN [ReasonCode]        NVARCHAR(50)    NULL;
GO

-- ================================
-- Data Cleaning
-- ================================

-- 1. Delete encounters that started after the patient's death
DELETE e
FROM encounters e
INNER JOIN patients p ON p.Id = e.Patient
WHERE p.DeathDate IS NOT NULL AND e.Start > p.DeathDate;
GO

-- 2. Delete procedures that started before their encounter
DELETE FROM procedures
WHERE Encounter IN (
    SELECT pr.Encounter
    FROM procedures pr
    JOIN encounters e ON e.Id = pr.Encounter
    WHERE pr.Start < e.Start
);
GO

-- 3. Delete orphan procedures that have no matching encounter
DELETE FROM procedures
WHERE NOT EXISTS (SELECT 1 FROM encounters e WHERE e.Id = procedures.Encounter);
GO

-- ==========================================================================
-- Add Primary Keys
-- ==========================================================================
 
ALTER TABLE patients      ADD CONSTRAINT PK_patients      PRIMARY KEY (Id);
ALTER TABLE organizations ADD CONSTRAINT PK_organizations PRIMARY KEY (Id);
ALTER TABLE payers        ADD CONSTRAINT PK_payers        PRIMARY KEY (Id);
ALTER TABLE encounters    ADD CONSTRAINT PK_encounters     PRIMARY KEY (Id);
GO

-- ==========================================================================
-- Foreign Keys
-- ==========================================================================
 
-- encounters → patients
ALTER TABLE encounters
    ADD CONSTRAINT FK_encounters_patients
    FOREIGN KEY (Patient) REFERENCES patients(Id);
 
-- encounters → organizations
ALTER TABLE encounters
    ADD CONSTRAINT FK_encounters_organizations
    FOREIGN KEY (Organization) REFERENCES organizations(Id);
 
-- encounters → payers
ALTER TABLE encounters
    ADD CONSTRAINT FK_encounters_payers
    FOREIGN KEY (Payer) REFERENCES payers(Id);
 
-- procedures → patients
ALTER TABLE procedures
    ADD CONSTRAINT FK_procedures_patients
    FOREIGN KEY (Patient) REFERENCES patients(Id);
 
-- procedures → encounters
ALTER TABLE procedures
    ADD CONSTRAINT FK_procedures_encounters
    FOREIGN KEY (Encounter) REFERENCES encounters(Id);
GO

-- =================================
-- Create Views for Analysis
-- =================================

-- View 1: vw_patient_base
CREATE VIEW vw_patient_base AS
SELECT
    Id,
    Gender,
    Race,
    Marital,
    City,
    BirthDate,
    DeathDate,
    DATEDIFF(YEAR, BirthDate, (SELECT MAX(Stop) FROM encounters)) AS Age,
    CASE
        WHEN DATEDIFF(YEAR, BirthDate, (SELECT MAX(Stop) FROM encounters)) < 18 THEN 'Under 18'
        WHEN DATEDIFF(YEAR, BirthDate, (SELECT MAX(Stop) FROM encounters)) < 35 THEN '18-34'
        WHEN DATEDIFF(YEAR, BirthDate, (SELECT MAX(Stop) FROM encounters)) < 50 THEN '35-49'
        WHEN DATEDIFF(YEAR, BirthDate, (SELECT MAX(Stop) FROM encounters)) < 65 THEN '50-64'
        ELSE '65+'
    END AS AgeGroup,
    CASE WHEN DeathDate IS NOT NULL THEN 1 ELSE 0 END AS IsDead
FROM patients;
GO

-- View 2: vw_encounter_enriched
CREATE VIEW vw_encounter_enriched AS
SELECT
    e.Id                                            AS EncounterId,
    e.Patient,
    e.Payer,
    py.Name                                         AS PayerName,
    e.EncounterClass,
    e.ReasonDescription                             AS Diagnosis,
    e.Start                                         AS EncounterStart,
    e.Stop                                          AS EncounterStop,
    DATEDIFF(HOUR, e.Start, e.Stop)                 AS LengthOfStay_Hours,
    DATEDIFF(DAY,  e.Start, e.Stop)                 AS LengthOfStay_Days,
    e.Base_Encounter_Cost,
    e.Total_Claim_Cost,
    e.Payer_Coverage,
    (e.Total_Claim_Cost - e.Payer_Coverage)         AS OutOfPocket_Cost,
    CASE
        WHEN e.Total_Claim_Cost = 0 THEN 0
        ELSE ROUND(e.Payer_Coverage / e.Total_Claim_Cost * 100, 2)
    END                                             AS InsuranceCoverage_Pct,
    YEAR(e.Start)                                   AS EncounterYear,
    MONTH(e.Start)                                  AS EncounterMonth,
    DATENAME(WEEKDAY, e.Start)                      AS DayOfWeek
FROM encounters e
LEFT JOIN payers py ON e.Payer = py.Id;
GO

-- View 3: vw_readmission
CREATE VIEW vw_readmission AS
SELECT
    Patient,
    EncounterId,
    EncounterStart,
    NextEncounterStart,
    DATEDIFF(DAY, EncounterStart, NextEncounterStart) AS DaysToNext,
    CASE
        WHEN DATEDIFF(DAY, EncounterStart, NextEncounterStart) <= 30
        THEN 1 ELSE 0
    END AS IsReadmitted
FROM (
    SELECT
        e.Patient,
        e.Id    AS EncounterId,
        e.Start AS EncounterStart,
        LEAD(e.Start) OVER (
            PARTITION BY e.Patient
            ORDER BY e.Start
        )       AS NextEncounterStart
    FROM encounters e
) t;
GO

-- View 4: vw_procedure_cost 
CREATE VIEW vw_procedure_cost AS
SELECT
    pr.Patient,
    pr.Encounter,
    pr.Description          AS ProcedureName,
    pr.Base_Cost            AS ProcedureCost,
    pr.ReasonDescription    AS ProcedureReason,
    e.PayerName,
    e.EncounterClass,
    e.InsuranceCoverage_Pct,
    p.AgeGroup,
    p.Gender,
    p.Race
FROM procedures pr
LEFT JOIN vw_encounter_enriched e ON pr.Encounter = e.EncounterId
LEFT JOIN vw_patient_base       p ON pr.Patient   = p.Id;
GO

 
 


 

 



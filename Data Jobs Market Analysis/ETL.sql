USE master;
GO

-- Drop database if exists
IF DB_ID('DataJobs_DB') IS NOT NULL
BEGIN
    ALTER DATABASE DataJobs_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataJobs_DB;
END
GO

-- Create new database
CREATE DATABASE DataJobs_DB;
GO

USE DataJobs_DB;
GO

-- Create table
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'DataJobs')
BEGIN
    DROP TABLE DataJobs;
END

CREATE TABLE DataJobs (
    job_title_short       NVARCHAR(MAX),
    job_title             NVARCHAR(MAX),
    job_location          NVARCHAR(MAX),
    job_via               NVARCHAR(MAX),
    job_schedule_type     NVARCHAR(MAX),
    job_work_from_home    NVARCHAR(MAX),
    search_location       NVARCHAR(MAX),
    job_posted_date       NVARCHAR(MAX),
    job_no_degree_mention NVARCHAR(MAX),
    job_health_insurance  NVARCHAR(MAX),
    job_country           NVARCHAR(MAX),
    salary_rate           NVARCHAR(MAX),
    salary_year_avg       NVARCHAR(MAX),
    salary_hour_avg       NVARCHAR(MAX),
    company_name          NVARCHAR(MAX),
    job_skills            NVARCHAR(MAX),
    job_type_skills       NVARCHAR(MAX)
);
GO

-- BULK INSERT
BULK INSERT DataJobs
FROM 'D:\data_jobs.csv'
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

-- Add PK
ALTER TABLE DataJobs ADD job_id INT IDENTITY(1,1) PRIMARY KEY;

-- Convert data types
ALTER TABLE DataJobs ALTER COLUMN job_title_short       NVARCHAR(MAX)    NOT NULL;
ALTER TABLE DataJobs ALTER COLUMN job_posted_date       DATE             NOT NULL;
ALTER TABLE DataJobs ALTER COLUMN job_work_from_home    BIT NOT NULL;
ALTER TABLE DataJobs ALTER COLUMN job_no_degree_mention BIT NOT NULL;
ALTER TABLE DataJobs ALTER COLUMN job_health_insurance  BIT NOT NULL;
ALTER TABLE DataJobs ALTER COLUMN salary_year_avg       DECIMAL(10, 2);
ALTER TABLE DataJobs ALTER COLUMN salary_hour_avg       DECIMAL(10, 2);

-- Clean job_via
UPDATE DataJobs
SET job_via = TRIM(REPLACE(job_via, 'via ', ''));

--------------------------------------------------
--  REMOVE DUPLICATES FROM DataJobs
--------------------------------------------------
WITH CTE_Duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY 
                   job_title,
                   company_name,
                   job_location,
                   job_posted_date
               ORDER BY job_id
           ) AS rn
    FROM DataJobs
)
DELETE FROM CTE_Duplicates
WHERE rn > 1;

--------------------------------------------------
-- Create JobSkills table
--------------------------------------------------
CREATE TABLE JobSkills (
    job_id          INT,
    skill           NVARCHAR(255),
    job_posted_date DATE,
    FOREIGN KEY (job_id) REFERENCES DataJobs(job_id)
);

--------------------------------------------------
-- Insert skills (DISTINCT to reduce duplicates)
--------------------------------------------------
INSERT INTO JobSkills (job_id, skill, job_posted_date)
SELECT DISTINCT
    job_id,
    TRIM(s.value) AS skill,
    job_posted_date
FROM DataJobs
CROSS APPLY OPENJSON(
    REPLACE(REPLACE(job_skills, '''', '"'), 'None', 'null')
) AS s
WHERE job_skills IS NOT NULL;

--------------------------------------------------
--  REMOVE DUPLICATES FROM JobSkills
--------------------------------------------------
WITH CTE_Skills AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY job_id, skill
               ORDER BY job_id
           ) AS rn
    FROM JobSkills
)
DELETE FROM CTE_Skills
WHERE rn > 1;

--------------------------------------------------
-- Prevent future duplicates
--------------------------------------------------
ALTER TABLE JobSkills
ADD CONSTRAINT UQ_JobSkill UNIQUE (job_id, skill);

--------------------------------------------------
-- Salary calculations
--------------------------------------------------
UPDATE DataJobs
SET salary_hour_avg = ROUND(salary_year_avg / (40 * 52), 2)
WHERE salary_year_avg IS NOT NULL 
  AND salary_hour_avg IS NULL;

UPDATE DataJobs
SET salary_year_avg = ROUND(salary_hour_avg * (40 * 52), 2)
WHERE salary_hour_avg IS NOT NULL 
  AND salary_year_avg IS NULL;
GO

--------------------------------------------------
-- Create View
--------------------------------------------------
IF EXISTS (SELECT * FROM sys.views WHERE name = 'V_DataJobs')   
BEGIN
    DROP VIEW V_DataJobs;
END
GO

CREATE VIEW V_DataJobs AS
SELECT 
    d.job_id,
    d.job_title_short,
    d.job_title,
    d.job_location,
    d.job_via,
    d.job_schedule_type,
    d.job_work_from_home,
    d.search_location,
    d.job_posted_date,
    d.job_no_degree_mention,
    d.job_health_insurance,
    d.job_country,
    d.salary_rate,
    d.salary_year_avg,
    d.salary_hour_avg,
    d.company_name,
    s.skill,
    d.job_type_skills
FROM DataJobs d
LEFT JOIN JobSkills s ON d.job_id = s.job_id
WHERE d.job_title_short IN (
        'Data Analyst', 
        'Data Scientist', 
        'Data Engineer', 
        'Machine Learning Engineer', 
        'Business Analyst', 
        'Senior Data Analyst', 
        'Senior Data Scientist', 
        'Senior Data Engineer'
)
AND d.salary_year_avg IS NOT NULL
AND d.salary_year_avg > 0
AND d.salary_hour_avg > 0
AND s.skill IS NOT NULL;
GO

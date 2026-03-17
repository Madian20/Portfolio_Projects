# Data Jobs Market Analysis
## Project Overview

**Data Jobs Market Analysis** is a data analytics project based on a dataset published by [Luke Barousse](https://huggingface.co/datasets/lukebarousse/data_jobs) — scraped from real job postings across multiple hiring platforms. Only **data-related roles** were selected from the dataset for this analysis.

---

## Motivation

After discovering Luke's dataset, the idea was simple: turn it into something useful for anyone trying to break into the data field — not just analysis for the sake of it, but a **practical guide for real people making real career decisions**.

---

## Goal

> Help aspiring data professionals understand the job market — what roles exist, what skills are in demand, and what to expect — all from real job postings.

---

## Project Phases
 
**1. Database & Table Creation — SQL Server**
Built the database and created the core `DataJobs` table to host the raw CSV data.
 
**2. Data Ingestion & Cleaning — SQL Server**
Loaded the raw data via `BULK INSERT`, removed duplicates, standardized the `job_via` field, and enforced correct data types.
 
**3. Skill Extraction — SQL Server**
Parsed the JSON-formatted `job_skills` column to create a dedicated `JobSkills` table, linking each job posting to its required skills.
 
**4. Calculated Columns — SQL Server**
Derived missing salary values — estimating annual salary from hourly rates and vice versa — to maximize usable salary data.
 
**5. View Creation — SQL Server**
Built a unified `V_DataJobs` view joining jobs with skills, filtered to the 8 core data roles with valid salary records, serving as the single source for all analysis.

**6. Exploratory Data Analysis — SQL Server**
Explored the dataset structure and behavior through data profiling, quality checks, salary distributions, outlier detection, and a skill demand vs. pay quadrant analysis.

**7. Dashboard — Power BI**
Built an interactive dashboard to visualize key findings across job roles, salaries, skills, and hiring trends — making the insights accessible and easy to explore.

---

## Cleaning Deep Dive
 
* **Removing duplicates** — kept only the first occurrence of duplicate job postings based on title, company, location, and date
```sql
WITH CTE_Duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY job_title, company_name, job_location, job_posted_date
               ORDER BY job_id
           ) AS rn
    FROM DataJobs
)
DELETE FROM CTE_Duplicates
WHERE rn > 1;
```
 
* **Cleaning job source** — stripped the redundant `via` prefix from the `job_via` column
```sql
UPDATE DataJobs
SET job_via = TRIM(REPLACE(job_via, 'via ', ''));
```
 
* **Extracting skills** — parsed the JSON-formatted `job_skills` column and loaded each skill into a dedicated `JobSkills` table
```sql
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
```
 
* **Deriving missing salaries** — estimated annual salary from hourly rate and vice versa to maximize usable salary data
```sql
UPDATE DataJobs
SET salary_hour_avg = ROUND(salary_year_avg / (40 * 52), 2)
WHERE salary_year_avg IS NOT NULL AND salary_hour_avg IS NULL;
 
UPDATE DataJobs
SET salary_year_avg = ROUND(salary_hour_avg * (40 * 52), 2)
WHERE salary_hour_avg IS NOT NULL AND salary_year_avg IS NULL;
```

---


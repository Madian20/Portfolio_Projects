# Data Jobs Market Analysis
## Project Overview

**Data Jobs Market Analysis** is a data analytics project based on a dataset published by [Luke Barousse](https://huggingface.co/datasets/lukebarousse/data_jobs) — scraped from real job postings across multiple hiring platforms in 2023. Only **data-related roles** were selected from the dataset for this analysis.

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
Loaded the raw data via `BULK INSERT`, removed duplicates, standardized text fields, extracted skills from JSON into a dedicated `JobSkills` table, and derived missing salary values from hourly rates and vice versa.

**3. View Creation — SQL Server**
Built a unified `V_DataJobs` view joining jobs with skills, filtered to the 8 core data roles with valid salary records, serving as the single source for all analysis.

**4. Exploratory Data Analysis — SQL Server**
Explored the dataset structure and behavior through data profiling, quality checks, salary distributions, outlier detection, and a skill demand vs. pay quadrant analysis.

**5. Dashboard — Power BI**
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

* **Creating the analytical view** — joined `DataJobs` with `JobSkills`, filtered to 8 core data roles, and excluded any row with missing salaries or null skills
```sql
CREATE VIEW V_DataJobs AS
SELECT 
    d.job_id, d.job_title_short, d.job_title,
    d.job_location, d.job_country, d.company_name,
    d.job_work_from_home, d.job_schedule_type,
    d.job_posted_date, d.salary_year_avg, d.salary_hour_avg,
    s.skill
FROM DataJobs d
LEFT JOIN JobSkills s ON d.job_id = s.job_id
WHERE d.job_title_short IN (
    'Data Analyst', 'Data Scientist', 'Data Engineer',
    'Machine Learning Engineer', 'Business Analyst',
    'Senior Data Analyst', 'Senior Data Scientist', 'Senior Data Engineer'
)
AND d.salary_year_avg > 0
AND d.salary_hour_avg > 0
AND s.skill IS NOT NULL;
```

---

## Key Insights
 
> All insights below are based on **Data Analyst** job postings unless otherwise noted.
 
- **August** recorded the highest number of job postings, while **November** saw the lowest — suggesting a seasonal hiring pattern worth tracking.
- **Full-time roles dominate** at **72.81%** of all postings, reflecting the structured nature of Data Analyst positions.
- Only **12.75%** of postings offer **remote work**, indicating that most Data Analyst roles still require on-site presence.
- **38.8%** of postings include **health insurance**, and **26.56%** make no degree mention — suggesting a growing openness to non-traditional candidates.
- The average compensation stands at **$90,600/year** and **$43.58/hour**.
- **SQL** leads as the most in-demand technical skill, appearing in **60%** of postings, followed by **Excel** at **46%** and **Python** at **33%**.
- Salary distribution is **right-skewed** — over half of postings fall below **$80K**, around 40% land in the **$80K–$120K** range, and only **6.5%** reach **$160K+**, meaning high salaries exist but are far from the norm.
- A clear pattern emerges across all data roles: **the least-hired roles tend to command the highest salaries** — pointing to a supply-demand gap where specialized talent remains scarce and highly valued.
 


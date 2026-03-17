-- ================================================================
--   EDA — Data Jobs Market Analysis
--   Purpose: Understand the data deeply before advanced analysis
--   SQL Server
-- ================================================================


-- 1:  Data protofile
SELECT
    COUNT(*)                                    AS total_rows,
    COUNT(DISTINCT job_id)                      AS unique_jobs,
    COUNT(DISTINCT company_name)                AS unique_companies,
    COUNT(DISTINCT job_country)                 AS unique_countries,
    COUNT(DISTINCT skill)                       AS unique_skills,
    COUNT(DISTINCT job_title_short)             AS unique_job_titles,
    MIN(CAST(job_posted_date AS DATE))          AS earliest_post,
    MAX(CAST(job_posted_date AS DATE))          AS latest_post,
    DATEDIFF(DAY,
        MIN(job_posted_date),
        MAX(job_posted_date))                   AS date_range_days
FROM V_DataJobs;
GO


-- 2:  Data quality checks
SELECT 'job_id'                 AS col, COUNT(DISTINCT job_id)               AS unique_vals, SUM(CASE WHEN job_id IS NULL THEN 1 ELSE 0 END)               AS nulls FROM V_DataJobs UNION ALL
SELECT 'job_title_short',             COUNT(DISTINCT job_title_short),           SUM(CASE WHEN job_title_short IS NULL THEN 1 ELSE 0 END)           FROM V_DataJobs UNION ALL
SELECT 'job_title',                   COUNT(DISTINCT job_title),                 SUM(CASE WHEN job_title IS NULL THEN 1 ELSE 0 END)                 FROM V_DataJobs UNION ALL
SELECT 'job_location',                COUNT(DISTINCT job_location),              SUM(CASE WHEN job_location IS NULL THEN 1 ELSE 0 END)              FROM V_DataJobs UNION ALL
SELECT 'job_via',                     COUNT(DISTINCT job_via),                   SUM(CASE WHEN job_via IS NULL THEN 1 ELSE 0 END)                   FROM V_DataJobs UNION ALL
SELECT 'job_schedule_type',           COUNT(DISTINCT job_schedule_type),         SUM(CASE WHEN job_schedule_type IS NULL THEN 1 ELSE 0 END)         FROM V_DataJobs UNION ALL
SELECT 'job_work_from_home',          COUNT(DISTINCT job_work_from_home),        SUM(CASE WHEN job_work_from_home IS NULL THEN 1 ELSE 0 END)        FROM V_DataJobs UNION ALL
SELECT 'job_country',                 COUNT(DISTINCT job_country),               SUM(CASE WHEN job_country IS NULL THEN 1 ELSE 0 END)               FROM V_DataJobs UNION ALL
SELECT 'salary_rate',                 COUNT(DISTINCT salary_rate),               SUM(CASE WHEN salary_rate IS NULL THEN 1 ELSE 0 END)               FROM V_DataJobs UNION ALL
SELECT 'salary_year_avg',             COUNT(DISTINCT salary_year_avg),           SUM(CASE WHEN salary_year_avg IS NULL THEN 1 ELSE 0 END)           FROM V_DataJobs UNION ALL
SELECT 'salary_hour_avg',             COUNT(DISTINCT salary_hour_avg),           SUM(CASE WHEN salary_hour_avg IS NULL THEN 1 ELSE 0 END)           FROM V_DataJobs UNION ALL
SELECT 'company_name',                COUNT(DISTINCT company_name),              SUM(CASE WHEN company_name IS NULL THEN 1 ELSE 0 END)              FROM V_DataJobs UNION ALL
SELECT 'skill',                       COUNT(DISTINCT skill),                     SUM(CASE WHEN skill IS NULL THEN 1 ELSE 0 END)                     FROM V_DataJobs UNION ALL
SELECT 'job_no_degree_mention',       COUNT(DISTINCT job_no_degree_mention),     SUM(CASE WHEN job_no_degree_mention IS NULL THEN 1 ELSE 0 END)     FROM V_DataJobs UNION ALL
SELECT 'job_health_insurance',        COUNT(DISTINCT job_health_insurance),      SUM(CASE WHEN job_health_insurance IS NULL THEN 1 ELSE 0 END)      FROM V_DataJobs;
GO


-- 3: distributions of jobs
SELECT
    job_title_short,
    COUNT(DISTINCT job_id)                                          AS job_count,
    ROUND(100.0 * COUNT(DISTINCT job_id)
          / SUM(COUNT(DISTINCT job_id)) OVER (), 1)                AS pct_of_total,
    ROUND(AVG(salary_year_avg), 0)                                  AS avg_salary,
    ROUND(MIN(salary_year_avg), 0)                                  AS min_salary,
    ROUND(MAX(salary_year_avg), 0)                                  AS max_salary,
    ROUND(100.0 * SUM(CASE WHEN job_work_from_home = 1 THEN 1 ELSE 0 END)
          / COUNT(DISTINCT job_id), 1)                             AS pct_remote
FROM V_DataJobs
GROUP BY job_title_short
ORDER BY job_count DESC;
GO

-- 4: Check for salary discrepancies between annual and hourly rates
SELECT TOP 10
    job_id,
    job_title_short,
    salary_year_avg,
    salary_hour_avg,
    ROUND(salary_hour_avg * 2080, 0)                AS implied_annual,
    ABS(salary_year_avg - salary_hour_avg * 2080)   AS discrepancy
FROM (SELECT DISTINCT job_id, job_title_short,
             salary_year_avg, salary_hour_avg FROM V_DataJobs) t
WHERE salary_year_avg IS NOT NULL
  AND salary_hour_avg IS NOT NULL
ORDER BY discrepancy DESC;
GO


-- 5: Jobs with no skills recorded
SELECT
    COUNT(DISTINCT job_id)                                          AS total_jobs,
    COUNT(DISTINCT CASE WHEN skill IS NULL THEN job_id END)        AS jobs_with_no_skill,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN skill IS NULL THEN job_id END)
          / COUNT(DISTINCT job_id), 1)                             AS pct_no_skill
FROM V_DataJobs;
GO


-- 6: salary distribution stats
SELECT DISTINCT  
    ROUND(MIN(salary_year_avg)   OVER (), 0)                       AS min_sal,
    ROUND(PERCENTILE_CONT(0.10)  WITHIN GROUP (ORDER BY salary_year_avg) OVER (), 0) AS p10,
    ROUND(PERCENTILE_CONT(0.25)  WITHIN GROUP (ORDER BY salary_year_avg) OVER (), 0) AS q1,
    ROUND(PERCENTILE_CONT(0.50)  WITHIN GROUP (ORDER BY salary_year_avg) OVER (), 0) AS median,
    ROUND(AVG(salary_year_avg)   OVER (), 0)                       AS mean,
    ROUND(PERCENTILE_CONT(0.75)  WITHIN GROUP (ORDER BY salary_year_avg) OVER (), 0) AS q3,
    ROUND(PERCENTILE_CONT(0.90)  WITHIN GROUP (ORDER BY salary_year_avg) OVER (), 0) AS p90,
    ROUND(MAX(salary_year_avg)   OVER (), 0)                       AS max_sal,
    ROUND(STDEV(salary_year_avg) OVER (), 0)                       AS std_sal
FROM V_DataJobs
GO


-- 7: Are there salary outliers?
WITH stats AS (
    SELECT AVG(salary_year_avg) AS mu, STDEV(salary_year_avg) AS sigma
    FROM V_DataJobs
    WHERE salary_year_avg IS NOT NULL
)
SELECT top 1000
    job_id,
    job_title_short,
    company_name,
    salary_year_avg,
    ROUND((salary_year_avg - mu) / NULLIF(sigma, 0), 2)    AS z_score,
    CASE
        WHEN ABS((salary_year_avg - mu) / NULLIF(sigma, 0)) > 3 THEN 'Extreme'
        WHEN ABS((salary_year_avg - mu) / NULLIF(sigma, 0)) > 2 THEN 'Outlier'
        ELSE 'Normal'
    END AS outlier_flag
FROM (SELECT DISTINCT job_id, job_title_short, company_name, salary_year_avg FROM V_DataJobs) j
CROSS JOIN stats
ORDER BY ABS((salary_year_avg - mu) / NULLIF(sigma, 0)) DESC;
Go


-- 8: Skill demand vs. pay quadrant analysis
WITH skill_stats AS (
    SELECT
        skill,
        COUNT(DISTINCT job_id)          AS demand,
        ROUND(AVG(salary_year_avg), 0)  AS avg_salary
    FROM V_DataJobs
    WHERE skill IS NOT NULL
    GROUP BY skill
),
thresholds AS (
    SELECT AVG(demand * 1.0) AS avg_d, AVG(avg_salary * 1.0) AS avg_s
    FROM skill_stats
    WHERE avg_salary IS NOT NULL
)
SELECT
    s.skill,
    s.demand,
    s.avg_salary,
    CASE
        WHEN s.demand > t.avg_d AND s.avg_salary > t.avg_s THEN 'Q1: High Demand + High Pay'
        WHEN s.demand > t.avg_d AND s.avg_salary <= t.avg_s THEN 'Q2: High Demand + Low Pay'
        WHEN s.demand <= t.avg_d AND s.avg_salary > t.avg_s THEN 'Q3: Low Demand + High Pay'
        ELSE                                                      'Q4: Low Demand + Low Pay'
    END AS quadrant
FROM skill_stats s
CROSS JOIN thresholds t
ORDER BY s.demand DESC, s.avg_salary DESC;
GO


-- 9: Salary differences by work type, schedule, degree requirement, and health insurance
SELECT
    segment,
    group_value,
    COUNT(DISTINCT job_id)          AS job_count,
    ROUND(AVG(salary_year_avg), 0)  AS avg_salary
FROM (
    SELECT 
           job_id,
           salary_year_avg,
           'Work Type'      AS segment,
           CASE WHEN job_work_from_home = 1 THEN 'Remote' ELSE 'On-site' END AS group_value
    FROM V_DataJobs
    UNION ALL
    SELECT 
           job_id, 
           salary_year_avg,
           'Schedule',
           ISNULL(job_schedule_type, 'Unknown')
    FROM V_DataJobs
    UNION ALL
    SELECT 
           job_id, 
           salary_year_avg,
           'Degree Required',
           CASE WHEN job_no_degree_mention = 1 THEN 'No Degree' ELSE 'Degree Mentioned' END
    FROM V_DataJobs
    UNION ALL
    SELECT 
           job_id, 
           salary_year_avg,
           'Health Insurance',
           CASE WHEN job_health_insurance = 1 THEN 'Has Insurance' ELSE 'No Insurance' END
    FROM V_DataJobs
) t
GROUP BY segment, group_value
ORDER BY segment, avg_salary DESC;
GO

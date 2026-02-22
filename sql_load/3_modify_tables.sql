/* ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
Database Load Issues (follow if receiving permission denied when running SQL code below)

NOTE: If you are having issues with permissions. And you get error: 

'could not open file "[your file path]\job_postings_fact.csv" for reading: Permission denied.'

1. Open pgAdmin
2. In Object Explorer (left-hand pane), navigate to `sql_course` database
3. Right-click `sql_course` and select `PSQL Tool`
    - This opens a terminal window to write the following code
4. Get the absolute file path of your csv files
    1. Find path by right-clicking a CSV file in VS Code and selecting “Copy Path”
5. Paste the following into `PSQL Tool`, (with the CORRECT file path)

\copy company_dim FROM '[Insert File Path]/company_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_dim FROM '[Insert File Path]/skills_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy job_postings_fact FROM '[Insert File Path]/job_postings_fact.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_job_dim FROM '[Insert File Path]/skills_job_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

*/

-- NOTE: This has been updated from the video to fix issues with encoding

-- Source - https://stackoverflow.com/a/57410949
-- Posted by ZUIBAFI, modified by community. See post 'Timeline' for change history
-- Retrieved 2026-02-11, License - CC BY-SA 4.0




COPY company_dim
FROM 'C:\Users\Public\Documents\Developer\Data_Analysis\csv_files\company_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_dim
FROM 'C:\Users\Public\Documents\Developer\Data_Analysis\csv_files\skills_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY job_postings_fact
FROM 'C:\Users\Public\Documents\Developer\Data_Analysis\csv_files\job_postings_fact.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_job_dim
FROM 'C:\Users\Public\Documents\Developer\Data_Analysis\csv_files\skills_job_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

SELECT *
FROM job_postings_fact
LIMIT 100;

SELECT 
    job_posted_date
FROM
    job_postings_fact
LIMIT 10;

SELECT '2023-02-19'::DATE;

SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date 
FROM
    job_postings_fact
LIMIT 5;

SELECT
    COUNT(job_id) AS job_postings,
    EXTRACT(MONTH FROM job_posted_date) AS month
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    month
ORDER BY 
    job_postings DESC;

SELECT
    job_schedule_type,
    AVG(salary_year_avg) AS avg_salary_yearly,
    AVG(salary_hour_avg) AS avg_salary_hourly
FROM
    job_postings_fact
WHERE
    job_posted_date >= '2023-06-01 00:00:00'
GROUP BY
    job_schedule_type
ORDER BY
    avg_salary_yearly DESC;

SELECT
    COUNT(job_id),
    EXTRACT (MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') AS mo 
FROM
    job_postings_fact
GROUP BY
    mo

SELECT
    job_postings_fact.job_id,
    company_dim.name,
    job_postings_fact.job_health_insurance,
    EXTRACT (QUARTER FROM job_postings_fact.job_posted_date) as quarter 
FROM
    job_postings_fact
LEFT JOIN
    company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE 
    EXTRACT (QUARTER FROM job_posted_date) = 2 and
    (job_health_insurance = TRUE) 
    --AND (job_postings_fact.mo = 2);

CREATE TABLE january_jobs AS
    SELECT *
    FROM 
        job_postings_fact
    WHERE 
        EXTRACT (MONTH FROM job_posted_date) = 1;

CREATE TABLE february_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

SELECT job_posted_date
FROM march_jobs;

SELECT 
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM
     job_postings_fact
WHERE 
    job_title_short = 'Data Analyst'
GROUP BY
    location_category;

SELECT *
FROM (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 4
) AS april_jobs;

WITH may_jobs AS (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 5
) 

SELECT *
FROM may_jobs;

SELECT 
    company_id,
    name
FROM 
    company_dim
WHERE 
    company_id IN (
    SELECT 
        company_id
    FROM
        job_postings_fact
    WHERE
        job_no_degree_mention = true
    ORDER BY
        company_id
)

WITH company_job_count AS(
SELECT
    job_postings_fact.company_id,
    COUNT(*) AS total_jobs    
FROM
    job_postings_fact
GROUP BY
    job_postings_fact.company_id

)
SELECT 
    company_dim.name,
    company_job_count.total_jobs
FROM company_dim
LEFT JOIN company_job_count ON company_dim.company_id = company_job_count.company_id
ORDER BY
    total_jobs DESC

WITH skill_count AS (
    SELECT 
        skill_id,
        COUNT(*) AS skills_mention
    FROM skills_job_dim
    GROUP BY
        skill_id
)
SELECT
    skills_dim.skills,
    skill_count.skills_mention
FROM skills_dim
LEFT JOIN skill_count ON skills_dim.skill_id = skill_count.skill_id
--GROUP BY
  --      skills_dim.skills
ORDER BY
    skills_mention DESC
LIMIT 5;

WITH postings_count AS (
    SELECT
        company_id,
        COUNT(job_id) AS number_of_postings
    FROM
        job_postings_fact
    GROUP BY
        company_id
)
SELECT
    company_dim.name,
    postings_count.number_of_postings,
    CASE
        WHEN number_of_postings < 10 THEN 'Small'
        WHEN number_of_postings <50 THEN 'Medium'
        ELSE 'Large'
    END AS company_size
FROM
    company_dim
LEFT JOIN 
    postings_count ON company_dim.company_id = postings_count.company_id
ORDER BY
    number_of_postings DESC

SELECT COUNT(*)
FROM skills_job_dim

WITH remote_jobs_per_skill AS(
SELECT
    skills_job_dim.skill_id,
    COUNT(skills_job_dim.job_id) AS no_of_remote_jobs
FROM skills_job_dim
INNER JOIN job_postings_fact ON skills_job_dim.job_id = job_postings_fact.job_id
WHERE 
    job_postings_fact.job_work_from_home = TRUE AND job_title_short = 'Data Analyst'
GROUP BY 
    skills_job_dim.skill_id
)

SELECT 
    no_of_remote_jobs,
    skills
FROM skills_dim
INNER JOIN
    remote_jobs_per_skill ON skills_dim.skill_id = remote_jobs_per_skill.skill_id
ORDER BY 
    no_of_remote_jobs DESC

SELECT COUNT(*)
FROM job_postings_fact
RIGHT JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id

SELECT COUNT(*)
FROM skills_job_dim

SELECT 
    job_title_short,
    company_id,
    job_location
FROM 
    january_jobs

UNION all

SELECT 
    job_title_short,
    company_id,
    job_location
FROM 
    february_jobs

SELECT 
    job_id,
    job_title_short,
    job_location,
    salary_year_avg,
    job_posted_date::DATE
FROM
(
SELECT *
FROM january_jobs
UNION ALL
SELECT *
FROM february_jobs
UNION ALL
SELECT *
FROM march_jobs
) AS Q1_jobs
WHERE
    salary_year_avg > 70000


/*
Question: What skills are required for the top-paying data analyst jobs?
- Use the top 10 high paying remote Data Analyst jobs from the 1st query
- Add the specific skills required for these roles
- Why? It provides a detailed look at which skills are demanded by high-paying jobs, 
  helping job seekers understand which skills to develop that align with top salaries
*/
SELECT
    skills_dim.skills AS skill_name,
    top_paying_jobs.job_title,
    salary_year_avg
FROM (
    SELECT
        job_id,
        job_title,
        name AS company_name,
        salary_year_avg   
    FROM
        job_postings_fact
    LEFT JOIN
        company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE
        job_location = 'Anywhere' AND 
        job_title_short = 'Data Analyst' AND 
        salary_year_avg IS NOT NULL
    ORDER BY
        salary_year_avg DESC
    LIMIT 10
) AS top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id   
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE skills IS NOT NULL
ORDER BY
    salary_year_avg DESC
--SELECT birthdate, hire_date FROM data WHERE birthdate>=NOW() OR hire_date>=NOW();
--ALTER TABLE data ADD COLUMN age INT;
--UPDATE data SET age = EXTRACT (YEAR FROM age(birthdate));
--SELECT first_name FROM data LIMIT 5;
--SELECT birthdate, age FROM data;
--Q1, gender breakdown of employees in the company?
SELECT gender,
    count(*)
FROM data
WHERE termdate IS NULL
GROUP BY gender;
--Q2, race breakdown of employees in the company?
SELECT race,
    count(*)
FROM data
WHERE termdate IS NULL
GROUP BY race
ORDER BY count(*) DESC;
--Q3, age distirbution of employees in the company?
SELECT MIN(age) AS youngest,
    MAX(age) AS oldest
FROM data
WHERE termdate IS NULL;
SELECT CASE
        WHEN age >= 21
        AND age <= 35 THEN '21-35'
        WHEN age >= 36
        AND age <= 50 THEN '36-50'
        ELSE '51+'
    END AS agegroup,
    count(*)
FROM data
WHERE termdate IS NULL
GROUP BY agegroup
ORDER BY agegroup;
--Q4, how many employees work at headquarters vs remote work?
SELECT location,
    count(*)
FROM data
WHERE termdate IS NULL
GROUP BY location;
--Q5, average length of employment for employees who termininated?
SELECT ROUND(
        AVG(
            EXTRACT(
                YEAR
                FROM AGE(termdate, hire_date)
            )
        )
    ) AS avg_length_emp
FROM data
WHERE termdate IS NOT NULL;
--Q6, gender distribution of department across the company?
SELECT department,
    gender,
    count(*)
FROM data
GROUP BY department,
    gender
ORDER BY department;
--Q7, distribution of job titles across the company?
SELECT jobtitle,
    count(*)
FROM data
WHERE termdate IS NULL
GROUP BY jobtitle
ORDER BY jobtitle;
--Q8, department with the highest turnover rate?
SELECT department,
    totalcount,
    terminated_count,
    ROUND(
        CAST(terminated_count AS numeric) / CAST(totalcount AS numeric),
        2
    ) AS termination_rate
FROM (
        SELECT department,
            count(*) AS totalcount,
            SUM(
                CASE
                    WHEN termdate IS NOT NULL
                    AND termdate <= NOW() THEN 1
                    ELSE 0
                END
            ) AS terminated_count
        FROM data
        GROUP BY department
    ) AS subquery
ORDER BY termination_rate DESC;
--Q9, distribution of employees across the location by state?
SELECT location_state,
    count(*)
FROM data
WHERE termdate IS NULL
GROUP BY location_state
ORDER BY count(*) DESC;
--Q10, how has company's employee count changed over time based on hire and term dates?
SELECT year,
    hires,
    terminations,
    hires - terminations AS net_change,
    ROUND(
        (
            CAST(hires AS numeric) - CAST(terminations AS numeric)
        ) / CAST(hires AS numeric) * 100,
        2
    ) AS net_change_percent
FROM(
        SELECT EXTRACT(
                YEAR
                FROM hire_date
            ) AS year,
            count(*) AS hires,
            SUM(
                CASE
                    WHEN termdate IS NOT NULL
                    AND termdate <= NOW() THEN 1
                    ELSE 0
                END
            ) AS terminations
        FROM data
        GROUP BY year
    ) AS subquery
ORDER BY year ASC;
--Q11, tenure distribution for each department?
SELECT department,
    ROUND(
        AVG(
            EXTRACT(
                YEAR
                FROM AGE(termdate, hire_date)
            )::numeric
        ),
        0
    ) AS avg_tenure
FROM data
WHERE termdate IS NOT NULL
    AND termdate <= NOW()
GROUP BY department;
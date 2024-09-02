-------------------------------data cleaning----------------------------------
SELECT * FROM data;

SELECT id, birthdate FROM data
WHERE  birthdate >= NOW();

--update records with birthdate that is in the future
UPDATE data 
SET birthdate = CASE WHEN EXTRACT(YEAR FROM birthdate) >= EXTRACT(YEAR FROM NOW()) THEN birthdate - INTERVAL '100 years'
ELSE birthdate
END;

--check duplicates
SELECT COUNT(DISTINCT id) FROM data;

--create column of age
ALTER TABLE data ADD COLUMN age INT;
UPDATE data SET age = EXTRACT(YEAR FROM age(birthdate));

--check that no minors are included
SELECT * FROM data
WHERE age <= 18;

-------------------------------questions----------------------------------
--Q1, gender breakdown of employees in the company?
SELECT gender,COUNT(*) FROM data 
WHERE termdate IS NULL
GROUP BY gender;

--Q2, race breakdown of employees in the company?
SELECT race, COUNT(race) FROM data 
WHERE termdate IS NULL
GROUP BY race;

--Q3, age distirbution of employees in the company using subquery?
SELECT MIN(age), MAX(age) FROM data WHERE termdate IS NULL;

SELECT age_group, COUNT(*)
FROM (
	SELECT
	CASE 
		WHEN age <= 30 THEN '21-30'
		WHEN age <= 40 THEN '31-40'
		WHEN age <= 50 THEN '41-50'
		ELSE '51+'
		END AS age_group
		FROM data
		WHERE termdate IS NULL
	)
GROUP BY age_group
ORDER BY age_group;

----Q4, how many employees work at headquarters vs remote work?
SELECT location, COUNT(*) FROM data
WHERE termdate IS NULL
GROUP BY location;

--Q5, average length of employment for employees who termininated?
SELECT ROUND(AVG(EXTRACT(YEAR FROM AGE(termdate, hire_date))), 2)
FROM data
WHERE termdate IS NOT NULL;

--Q6, gender distribution of department across the company?
SELECT department,gender,COUNT(*) FROM data 
WHERE termdate IS NULL
GROUP BY department,gender
ORDER BY department, gender;

--Q7, distribution of job titles across the company?
SELECT jobtitle,COUNT(*)
FROM data
WHERE termdate IS NULL
GROUP BY jobtitle
ORDER BY COUNT(*) DESC;

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
SELECT location_state, COUNT(*)
FROM data
WHERE termdate IS NULL
GROUP BY location_state
ORDER BY COUNT(*) DESC;

--Q10, how has company's employee count changed over time based on hire and term dates?
SELECT year,
    hires,
    terminations,
    hires - terminations AS net_change,
    ROUND(
        (CAST(hires AS numeric) - CAST(terminations AS numeric)
        ) / CAST(hires AS numeric) * 100
		,2
    ) AS net_change_percent
FROM( SELECT EXTRACT(
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

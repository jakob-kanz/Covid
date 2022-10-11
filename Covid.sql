-- Skill used --
-- Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Casting Data Types


-- SECTION 1 --

--What percentage of people who tested positive for COVID died with it in Austria?
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_pct
FROM Covid..Covid
WHERE location = 'Austria'
ORDER BY 1,2

--Which countries had the highest per capita infection rate?
SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population)*100) AS highest_pct_pop_infected
FROM Covid..Covid
GROUP BY location, population
ORDER BY 4 DESC

--Which countries had the highest daily test rate (per capita)?
SELECT location, population, MAX(total_tests) as highest_test_count, MAX((total_tests/population)*100) AS highest_test_rate
FROM Covid..Covid
GROUP BY location, population
ORDER BY 4 DESC


-- SECTION 2 --

-- Calculating the cumulative number of vaccinations for Austria over time.
SELECT cov.location, cov.date, cov.population, vax.new_vaccinations, 
    SUM(CAST(vax.new_vaccinations AS FLOAT)) OVER (PARTITION BY vax.location ORDER BY cov.location, cov.date) AS rolling_total_vaccinations
FROM Covid..Covid AS cov
JOIN Covid..Vaccinations AS vax
    ON cov.location = vax.location
    AND cov.date = vax.date
WHERE cov.location = 'Austria'
ORDER BY 1, 2


-- Using CTE.
-- How many doses (per capita) of the COVID-19 vaccinations have been administered in Austria?
WITH pop_vs_vax (location, date, population, new_vaccinations, rolling_total_vaccinations)
AS
(
SELECT cov.location, cov.date, cov.population, vax.new_vaccinations, 
    SUM(CAST(vax.new_vaccinations AS FLOAT)) OVER (PARTITION BY vax.location ORDER BY cov.location, cov.date) AS rolling_total_vaccinations
FROM Covid..Covid AS cov
JOIN Covid..Vaccinations AS vax
    ON cov.location = vax.location
    AND cov.date = vax.date
WHERE cov.continent IS NOT NULL
    AND cov.location = 'Austria'
)
SELECT *, (rolling_total_vaccinations/population) AS per_capita_vaccinations
FROM pop_vs_vax

-- Using a temp table.
-- How many doses (per capita) of the COVID-19 vaccinations have been administered in Austria?

CREATE TABLE #pop_vs_vax
(
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_total_vaccinations numeric
)
INSERT INTO #pop_vs_vax
SELECT cov.location, cov.date, cov.population, vax.new_vaccinations, 
    SUM(CAST(vax.new_vaccinations AS FLOAT)) OVER (PARTITION BY vax.location ORDER BY cov.location, cov.date) AS rolling_total_vaccinations
FROM Covid..Covid AS cov
JOIN Covid..Vaccinations AS vax
    ON cov.location = vax.location
    AND cov.date = vax.date
WHERE cov.location = 'Austria'

SELECT *, (rolling_total_vaccinations/population) AS per_capita_vaccinations
FROM #pop_vs_vax
ORDER BY 2
USE project; 

-- -------------------------------------------------------------------------------------------

-- SELECTING THE DATA THAT IS GOING TO BE USED IN THIS PROJECT
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- -------------------------------------------------------------------------------------------

-- THE QUERY ILLUSTRATES THE LIKELIHOOD OF FATALITY WHEN CONTRACTED WITH COVID-19 wrt LOCATION 
SELECT location, date, total_cases, total_deaths, population, 
((total_deaths/total_cases) * 100) AS "Percent_death %"
FROM covid_deaths
WHERE (continent IS NOT NULL) AND (location LIKE "India")
-- WHERE continent IS NOT NULL
ORDER BY location, date;

-- -------------------------------------------------------------------------------------------

-- THE QUERY ILLUSTRATES THE LIKELIHOOD OF GETTING INFECTED TO COVID-19 wrt LOCATION 
SELECT location, date, total_cases, population, 
((total_cases/population) * 100) AS "Percent_infected %"
FROM covid_deaths
WHERE (continent IS NOT NULL) AND (location LIKE "India")
-- WHERE continent IS NOT NULL
ORDER BY location, date;


-- -------------------------------------------------------------------------------------------

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location, continent, date, MAX(total_cases) AS Maximum_cases , population, 
(MAX((total_cases/population)) * 100) AS Percent_infected
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Percent_infected DESC;

-- -------------------------------------------------------------------------------------------

-- LOOKING AT COUNTRIES WITH HIGHEST DEATH RATE PER POPULATION
SELECT 
location, continent, population, MAX(total_deaths) AS Highest_Deaths_Count,
(MAX(total_deaths/population) * 100) AS Percent_Population_died
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Percent_Population_died DESC
;

-- ------------------------------------------------------------------------------

-- BREAKING THINGS DOWN BY CONTINENT
SELECT location, MAX(total_cases) AS MAX_total_cases
FROM covid_deaths 
WHERE continent IS NULL AND 
(location NOT LIKE "International" AND location NOT LIKE "World" AND location NOT LIKE "European Union")
GROUP BY location
ORDER BY MAX_total_cases DESC;

-- ------------------------------------------------------------------------------

-- SHOWING CONTINENTS WITH HIGHEST DEATH COUNTS
SELECT location, MAX(total_deaths) AS MAX_deaths
FROM covid_deaths 
WHERE (continent IS NULL) AND 
(location NOT LIKE "International" AND location NOT LIKE "World" AND location NOT LIKE "European Union")
GROUP BY location
ORDER BY MAX_deaths DESC;

-- ------------------------------------------------------------------------------

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS Cases, SUM(new_deaths) AS Deaths, 
(SUM(new_deaths)/SUM(new_cases) * 100) AS "Percent_death %"
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date  -- Try commenting this statement
ORDER BY 1, 2;

-- ------------------------------------------------------------------------------

-- Joining two tables
SELECT 
*FROM covid_deaths AS dea 
JOIN covid_vaccination AS vac 
ON (dea.location = vac.location) AND (dea.date = vac.date)
WHERE dea.continent IS NOT NULL;

-- ------------------------------------------------------------------------------
  
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS "Cumulative_vac_number",
-- This above line indicates that whenever the location is changed, summing starts from 0
(SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)/population) * 100 AS percent_vaccinated
FROM covid_deaths AS dea 
JOIN covid_vaccination AS vac 
ON (dea.location = vac.location) AND (dea.date = vac.date)
WHERE dea.continent IS NOT NULL AND dea.location LIKE "India"
ORDER BY location, date;

-- This is a simpler version of the above code (NOT USING CUMULATION)
SELECT dea.location, dea.continent, dea.population, 
SUM(new_vaccinations) AS Total_Vaccinations,
((SUM(new_vaccinations)/dea.population) * 100) AS percent_vaccinated
FROM covid_deaths AS dea 
JOIN covid_vaccination AS vac 
ON (dea.location = vac.location) AND (dea.date = vac.date)
WHERE dea.continent IS NOT NULL AND dea.location LIKE "Albania"
GROUP BY location
ORDER BY location, continent;

-- ----------------------------------------------------------------------------------------------------

-- CREATING A VIEW FOR VISUALIZATIONS (For Tableau Project)
CREATE VIEW percent_pop_vac AS
SELECT dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS "Cumulative_vac_number",
-- This above line indicates that whenever the location is changed, summing starts from 0
(SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)/population) * 100 AS percent_vaccinated
FROM covid_deaths AS dea 
JOIN covid_vaccination AS vac 
ON (dea.location = vac.location) AND (dea.date = vac.date)
WHERE dea.continent IS NOT NULL;
-- ORDER BY location, date;
  
-- ----------------------------------------------------------------------------------------------------
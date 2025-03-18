select *
from pp.coviddeaths
where continent is not null
order by 3,4

select *
from pp.covidvac
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population 
from pp.coviddeaths
order by 1,2

--total cases vs total deaths 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percent pop
from pp.coviddeaths
where location like' %Africa%'
order by 1,2

-- total cases vs population (Africa)
-- shows the percentage of people with covid
select location, date, total_cases,population ,(total_cases /population)*100 as percentagepopinfected
from pp.coviddeaths
where location like '%Africa%'

-- countries with highest infection rate compared to population
select population,location, MAX(total_cases) as HighestInfectionCount, Max((total_cases /population))*100 as Deathpercentage
from pp.coviddeaths
where continent is not null
group by population,location
order by Deathpercentage desc

SET SQL_SAFE_UPDATES = 0;


-- checkinh null values 
UPDATE pp.coviddeaths 
SET total_deaths = NULL 
WHERE total_deaths = '';

-- alter total deaths column
ALTER TABLE pp.coviddeaths 
MODIFY COLUMN total_deaths INT

SET SQL_SAFE_UPDATES = 1;

-- showing countries with highest deaths per count
select location, max(total_deaths) as totaldeathcount
from pp.coviddeaths
where continent is not null
group by location
order by  totaldeathCount desc


-- breaking down by continent
select continent, max(total_deaths) as totaldeathcount
from pp.coviddeaths
where continent is not null
group by continent
order by  totaldeathCount desc


-- continents with the highest death rates 
select continent , max(total_deaths) as deathrates
from pp.coviddeaths
where continent is not null
group by continent
order by deathrates

-- changing the float column to an integer
SET SQL_SAFE_UPDATES = 0

UPDATE pp.coviddeaths 
SET new_deaths = NULL 
WHERE new_deaths = ''

ALTER TABLE pp.coviddeaths 
MODIFY COLUMN new_deaths INT

SET SQL_SAFE_UPDATES = 1


-- global numbers across dates
SELECT date,SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths) / SUM(new_cases)) * 100 AS death_rate
FROM pp.coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, total_cases

-- total global numbers 
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths) / SUM(new_cases)) * 100 AS death_rate
FROM pp.coviddeaths
WHERE continent IS NOT NULL
ORDER BY total_cases

-- joining both tables on dats and location 
select *
from pp.coviddeaths as dea
join pp.covidvac as vac 
 on dea.location = vac.location
 and dea.date = vac.date
 
 
--  total number of world population vaccinated 
 select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
from pp.coviddeaths as dea
join pp.covidvac as vac 
 on dea.location = vac.location
 and dea.date = vac.date 

SET SQL_SAFE_UPDATES = 0

UPDATE pp.covidvac
SET new_vaccinations = NULL 
WHERE new_vaccinations = 
MODIFY COLUMN new_vaccinations INT 
USING new_vaccinations + 0;

-- SET SQL_SAFE_UPDATES = 1



-- rolling average on vaccination totals 
SELECT 
    dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
	OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingpeoplevaccinated 
FROM pp.coviddeaths AS dea
JOIN pp.covidvac AS vac 
    ON dea.location = vac.location
    AND dea.date = vac.date;

 
-- USING CTE
WITH popvsvac AS (
    SELECT 
        dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
            OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingpeoplevaccinated
    FROM pp.coviddeaths AS dea
    JOIN pp.covidvac AS vac 
        ON dea.location = vac.location
        AND dea.date = vac.date
)
SELECT * , (rollingpeoplevaccinated/population)*100
FROM popvsvac 
ORDER BY location, date;

-- TOTAL PERCENTAGAE OF PEOPLE FULLY VACCINATED 
select dea.continent, dea.location, dea.population, vac.new_vaccinations, SUM(CAST(people_fully_vaccinated_per_hundred AS UNSIGNED))
OVER (PARTITION BY dea.location ORDER BY dea.date) AS FULLVACPER100
    FROM pp.coviddeaths AS dea
    JOIN pp.covidvac AS vac 
        ON dea.location = vac.location
        AND dea.date = vac.date
        
        
UPDATE pp.covidvac 
SET new_vaccinations = NULL 
WHERE new_vaccinations = ' '

-- TEMP TABLE

DROP TEMPORARY TABLE IF EXISTS percentpopulationvaccinated;



CREATE TEMPORARY TABLE percentpopulationvaccinated (
    continent VARCHAR(225),
    location VARCHAR(225),
    date DATETIME,
    population DECIMAL(20,2),
    new_vaccination DECIMAL(20,2),
    rollingpeoplevaccinated DECIMAL(20,2)
);

INSERT INTO percentpopulationvaccinated
SELECT 
    dea.continent, 
    dea.location, 
    STR_TO_DATE(dea.date, '%d/%m/%Y') AS date, 
    dea.population, 
    CAST(NULLIF(vac.new_vaccinations, '') AS DECIMAL(20,2)) AS new_vaccination, 
    SUM(CAST(NULLIF(vac.new_vaccinations, '') AS UNSIGNED)) 
        OVER (PARTITION BY dea.location ORDER BY STR_TO_DATE(dea.date, '%d/%m/%Y')) 
        AS rollingpeoplevaccinated
FROM pp.coviddeaths AS dea
JOIN pp.covidvac AS vac 
    ON dea.location = vac.location
    AND dea.date = vac.date;


-- Retrieve results with the percentage of the population vaccinated
SELECT *, (rollingpeoplevaccinated / population) * 100 AS percent_vaccinated
FROM percentpopulationvaccinated


-- CREATING A VIEW FOR VISIALISATION
CREATE VIEW percentpopulationvaccinated AS 
SELECT 
    dea.continent, 
    dea.location, 
    STR_TO_DATE(dea.date, '%d/%m/%Y') AS date, 
    dea.population, 
    CAST(NULLIF(vac.new_vaccinations, '') AS UNSIGNED) AS new_vaccinations, 
    SUM(CAST(NULLIF(vac.new_vaccinations, '') AS UNSIGNED)) 
        OVER (PARTITION BY dea.location ORDER BY STR_TO_DATE(dea.date, '%d/%m/%Y')) 
        AS rollingpeoplevaccinated
FROM pp.coviddeaths AS dea
JOIN pp.covidvac AS vac 
    ON dea.location = vac.location
    AND dea.date = vac.date;


create view rollingpeoplevaccinated as
SELECT 
        dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
            OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingpeoplevaccinated
    FROM pp.coviddeaths AS dea
    JOIN pp.covidvac AS vac 
        ON dea.location = vac.location
        AND dea.date = vac.date


# SQL-PROJECT
## Project Title: COVID-19 Data Analysis Using SQL
## Description:
This SQL project analyses COVID-19 data using MySQL to extract meaningful insights on infection rates, death rates, and vaccination trends. It involves cleaning data, handling null values, performing aggregate calculations, and creating views for visualization.

## Dataset Overview
The project uses two datasets stored in a database schema called pp:
1.	pp.coviddeaths – Contains COVID-19 cases, deaths, and population data for various countries and continents.
2.	pp.covidvac – Stores vaccination records, including new vaccinations and fully vaccinated statistics.

 #Key SQL Techniques Used
 ## Data Cleaning & Transformation
•	Handling NULL values: Replacing empty strings with NULL in total_deaths, new_deaths, and new_vaccinations.
•	Changing Data Types: Ensuring numerical columns are correctly formatted as INT or DECIMAL.
•	Fixing Date Formats: Converting date from VARCHAR to proper DATETIME using STR_TO_DATE().
 ## Exploratory Data Analysis (EDA)
•	Checking total cases, deaths, and infections by location and date.
•	Finding the highest infection rates relative to the population.
•	Identifying continents with the most COVID-related deaths.
 ## Aggregations & Insights
•	Global COVID Trends: Summarizing total cases, deaths, and death rates worldwide.
•	Percentage of Population Infected: Calculating (total_cases / population) * 100.
•	Death Rate Analysis: Comparing deaths to total cases in Africa.
•	Highest Death Counts by Country & Continent: Using GROUP BY and MAX() functions.
 ## Vaccination Analysis
•	Rolling Sum of Vaccinations: Using a window function (SUM() OVER()) to track cumulative vaccinations over time.
•	Total Population Vaccinated: Calculating (rollingpeoplevaccinated / population) * 100 to determine vaccination rates.
•	Comparing Vaccinations by Country & Continent.
 ## SQL Optimization
•	Using CTEs (WITH statement) for better readability and reusability.
•	Creating Views for Visualization: percentpopulationvaccinated, rollingpeoplevaccinated.
•	Temporary Tables for efficient data processing.

## Key SQL Queries
## 1.	Infection & Death Rate Analysis 
sql
SELECT location, date, total_cases, total_deaths, 
       (total_deaths / total_cases) * 100 AS death_rate
FROM pp.coviddeaths
WHERE location LIKE '%Africa%'
ORDER BY location, date;
## 2.	Highest Infection Rate by Country 
sql
SELECT location, MAX(total_cases) AS highest_cases, 
       MAX((total_cases / population) * 100) AS infection_rate
FROM pp.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY infection_rate DESC;
## 3.	Total Global Cases & Deaths 
sql
SELECT SUM(new_cases) AS total_cases, 
       SUM(new_deaths) AS total_deaths, 
       (SUM(new_deaths) / SUM(new_cases)) * 100 AS global_death_rate
FROM pp.coviddeaths
WHERE continent IS NOT NULL;
## 4.	Rolling Vaccination Count by Country 
sql
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(CAST(vac.new_vaccinations AS UNSIGNED)) 
       OVER (PARTITION BY dea.location ORDER BY dea.date) AS rollingpeoplevaccinated
FROM pp.coviddeaths AS dea
JOIN pp.covidvac AS vac 
    ON dea.location = vac.location AND dea.date = vac.date;

 ## Insights & Findings
1.	Infection Trends
	Some countries had infection rates exceeding 50% of the population.
	Africa had lower cases relative to its population compared to Europe and the Americas.
2.	Death Rate Patterns
	Countries with older populations showed higher death rates.
	The global COVID death rate fluctuated but stayed below 5% on average.
3.	Vaccination Progress
	Some countries reached over 80% full vaccination.
	The rate of vaccinations slowed down in certain regions after an initial surge.

 ## How to Use This Project
•	Run SQL Queries in MySQL Workbench to extract insights.
•	Use Views (percentpopulationvaccinated) for visualization in tools like Power BI or Tableau.
•	Modify Filters (WHERE location = 'ABC') to focus on specific countries or continents.

 
 ## Conclusion
This project provides a comprehensive SQL-based analysis of COVID-19 trends, including infections, deaths, and vaccinations. It uses real-world data and advanced SQL techniques to generate meaningful insights that can aid decision-making and policy evaluations.

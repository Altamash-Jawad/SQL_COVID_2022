-- COVID DEATHS TABLE QUERIES --

--SELECT * FROM
--SQLDataExplorationPrjct..Covid_Vaccinations
--WHERE location LIKE '%income%'
--ORDER BY 1, 2;

-- This Select Data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM SQLDataExplorationPrjct..Covid_Deaths
ORDER BY 1, 2;

-- This shows number of death by cases (Percentage) in your country. Replace location with your country. 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentageOfDeath
FROM SQLDataExplorationPrjct..Covid_Deaths
WHERE location = 'Estonia'
ORDER BY 1, 2;

-- This shows what percentage of people contracted the COVID.

SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasesInPopulation
FROM SQLDataExplorationPrjct..Covid_Deaths
WHERE location = 'Estonia'
ORDER BY 1, 2;

-- This shows which country has the highest infection rate 

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectionRate 
FROM SQLDataExplorationPrjct..Covid_Deaths
--WHERE location = 'Estonia'
GROUP BY location, population
ORDER BY InfectionRate DESC;

-- This shows the number of highest death count by location

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeaths
FROM
SQLDataExplorationPrjct..Covid_Deaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeaths DESC;

-- Death Count by Continent

SELECT continent, MAX(CAST(total_deaths AS int)) AS DeathCount
FROM SQLDataExplorationPrjct..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathCount;

-- Showing the continent with the highest death count

SELECT continent, MAX(CAST(total_deaths AS int)) AS DeathCount
FROM SQLDataExplorationPrjct..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathCount DESC;

-- Global stats

SELECT date, SUM(new_cases) AS CasesBYDate, SUM(CAST(new_deaths AS int)) AS DeathsBYDate,
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS PercentageOfDeath
FROM SQLDataExplorationPrjct..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date DESC;


SELECT SUM(total_cases) AS TotalCases, SUM(CAST(total_deaths AS bigint)) AS TotalDeaths, SUM((total_deaths/total_cases) * 100) AS DeathPercentile  
FROM SQLDataExplorationPrjct..Covid_Deaths
WHERE continent IS NOT NULL;

-- COVID VACCINES TABLE QUREIES --


-- This shows total people who have been vaccinated

SELECT death.continent, death.location,
death.date, death.population, vacc.new_vaccinations, SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY death.location ORDER BY death.date)  Vaccinated
FROM 
SQLDataExplorationPrjct..Covid_Vaccinations AS vacc
JOIN SQLDataExplorationPrjct..Covid_Deaths AS death
ON vacc.location = death.location
AND vacc.date = death.date
WHERE death.continent IS NOT NULL AND death.location = 'Estonia'
ORDER BY 2,3;

-- USE CTE - Because we want to use a column that we just created "Vaccinated"

WITH PopvsVac (Continent, Location, Date, Population, NewVacc, Vaccinated)

AS
(
	SELECT death.continent, death.location,
death.date, death.population, vacc.new_vaccinations, SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY death.location ORDER BY death.date)  Vaccinated
FROM 
SQLDataExplorationPrjct..Covid_Vaccinations AS vacc
JOIN SQLDataExplorationPrjct..Covid_Deaths AS death
ON vacc.location = death.location
AND vacc.date = death.date
WHERE death.continent IS NOT NULL AND death.location = 'Estonia'

)

SELECT *, Vaccinated/Population PercentageOfVacc
FROM 
PopvsVac;


-- TEMP Table JUST FOR PRACTICE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date  datetime,
	Population numeric,
	New_Vaccinations numeric,
	Vaccinated numeric

)

INSERT INTO #PercentPopulationVaccinated 
SELECT death.continent, death.location,
death.date, death.population, vacc.new_vaccinations, SUM(CAST(vacc.new_vaccinations AS bigint)) OVER (PARTITION BY death.location ORDER BY death.date)  Vaccinated
FROM 
SQLDataExplorationPrjct..Covid_Vaccinations AS vacc
JOIN SQLDataExplorationPrjct..Covid_Deaths AS death
ON vacc.location = death.location
AND vacc.date = death.date
--WHERE death.continent IS NOT NULL 

SELECT *, Vaccinated/Population PercentageOfVacc
FROM 
#PercentPopulationVaccinated;

-- CREATING VIEW TO STORE DATA FOR VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS

SELECT death.continent, death.location,
death.date, death.population, vacc.new_vaccinations, SUM(CAST(vacc.new_vaccinations AS bigint)) OVER (PARTITION BY death.location ORDER BY death.date)  Vaccinated
FROM 
SQLDataExplorationPrjct..Covid_Vaccinations AS vacc
JOIN SQLDataExplorationPrjct..Covid_Deaths AS death
ON vacc.location = death.location
AND vacc.date = death.date
WHERE death.continent IS NOT NULL 
--ORDER BY 2, 3

SELECT * 
FROM 
PercentPopulationVaccinated;
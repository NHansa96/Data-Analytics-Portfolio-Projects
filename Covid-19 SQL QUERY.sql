SELECT * FROM CovidDeaths$
WHERE location is NOT NULL
ORDER BY location, date

SELECT * FROM CovidVaccinations
ORDER BY location, date

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY location, date

-- LOOKING AT TOTAL CASES VS TOTAL DEATHS:
-- Displays the likelihood of dying if you contract Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM CovidDeaths$
WHERE location LIKE '%south africa%'
ORDER BY location, date

--Shows percentage of population whom got Covid
SELECT location, date, population, total_cases, (total_cases/population) * 100 AS PopulationInfectionPercent
FROM CovidDeaths$
WHERE location LIKE '%south africa%'
ORDER BY location, date

--Which country has the highest infection rate compared to population:
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PopulationInfectionPercent
FROM CovidDeaths$
GROUP  BY location, population
ORDER BY PopulationInfectionPercent DESC

--This shows the countries with the highest death count per population:
SELECT continent, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Total death count by continent:
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Figures:

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE continent is NOT NULL 
--GROUP BY date
ORDER BY 1,2

--Global Figures by date:
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE continent is NOT NULL 
GROUP BY date
ORDER BY 1,2


--Joining both tables:
SELECT * FROM CovidDeaths$ dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 


--Looking at total population vs vaccinations:
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_Vaccinations as int)) OVER (Partition BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL 
ORDER BY 2,3

--USING A CTE:
--To view Percentage of population vaccinated

WITH PopvsVac (Continent, Location, Date, Population,New_Vacinnations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_Vaccinations as int)) OVER (Partition BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL 
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageOfPopulationVaccinated
FROM PopvsVac


--TEMP TABLE:
--PercentPopulationVaccinated:

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_Vaccinations as int)) OVER (Partition BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL 

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentageOfPopulationVaccinated
FROM #PercentPopulationVaccinated

--CREATE VIEW TO STORE DATA FOR LATER VISUAIZATIONS:

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_Vaccinations as int)) OVER (Partition BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT NULL 

SELECT * FROM PercentPopulationVaccinated



/*

Queries used for Tableau Project

*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc









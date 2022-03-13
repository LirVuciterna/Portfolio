
SELECT * 
FROM PortfolioProjecct..CovidVaccinations
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProjecct..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjecct..CovidDeaths
WHERE continent is not null
Order by 1,2

--Total cases vs Total deaths
--Likelihood of dying if you contract covid in your country

SELECT  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjecct..CovidDeaths
WHERE location LIKE '%states%'
and continent is not null
ORDER BY 1,2

-- Total cases vs Population
-- Shows what percentage of population got Covid

SELECT  location, date, population, total_cases,  (total_cases/population)*100 as Infected_Pop
FROM PortfolioProjecct..CovidDeaths
WHERE location LIKE '%states%'
and continent is not null
ORDER BY 1,2

--Showing countries with Highest Infection Rate compared to Population 

SELECT  location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as Infected_Pop
FROM PortfolioProjecct..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
Group By location, population
ORDER BY Infected_Pop desc

--Showing countries with Highest Death Count per Population

SELECT  location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjecct..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
Group By location 
ORDER BY TotalDeathCount desc

--BREAKING THINGS DOWN BY CONTINENT

--Showing continents with highest death count per population

SELECT  continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjecct..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
Group By continent 
ORDER BY TotalDeathCount desc


--GLOBAL NUMBERS

SELECT date,SUM(new_cases) as Total_Covid_Cases, SUM(cast(new_deaths as int)) as Total_Covid_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProjecct..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProjecct..CovidDeaths as dea
JOIN PortfolioProjecct..CovidVaccinations as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE

WITH PopvsVAC (Continent, Location, Date, Population,New_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProjecct..CovidDeaths as dea
JOIN PortfolioProjecct..CovidVaccinations as vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVAC

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVAccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProjecct..CovidDeaths as dea
JOIN PortfolioProjecct..CovidVaccinations as vac
ON dea.location = vac.location 
AND dea.date = vac.date


SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later vizualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProjecct..CovidDeaths as dea
JOIN PortfolioProjecct..CovidVaccinations as vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
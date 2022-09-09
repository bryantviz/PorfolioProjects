SELECT * 
FROM PorfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PorfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PorfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PorfolioProject..CovidDeaths$
WHERE location like '%kong%'
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Population
-- Shows what percentage of population got infected

SELECT location, date, total_cases, population, (total_cases/population)*100 AS Infected_Population_Percentage
FROM PorfolioProject..CovidDeaths$
WHERE location like '%kong%'
WHERE continent is not null
ORDER BY 1,2

-- Looking at Countries with the Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS Infected_Population_Percentage
FROM PorfolioProject..CovidDeaths$
--WHERE location like '%kong%'
WHERE continent is not null
GROUP BY location, population
ORDER BY Infected_Population_Percentage DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, population, MAX(CAST(total_deaths AS int)) AS Total_Death_Count, MAX((CAST(total_deaths AS int)/population))*100 AS Death_Population_Percentage, MAX((total_cases/population))*100 AS Infected_Population_Percentage
FROM PorfolioProject..CovidDeaths$
--WHERE location like '%kong%'
WHERE continent is not null
GROUP BY location, population
ORDER BY Total_Death_Count DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per populaion

SELECT continent, MAX(CAST(total_deaths AS int)) AS Total_Death_Count, MAX((CAST(total_deaths AS int)/population))*100 AS Death_Population_Percentage, MAX((total_cases/population))*100 AS Infected_Population_Percentage
FROM PorfolioProject..CovidDeaths$
--WHERE location like '%kong%'
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM PorfolioProject..CovidDeaths$
--WHERE location like '%kong%'
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated / population) * 100
FROM PorfolioProject..CovidDeaths$ dea
Join PorfolioProject..CovidVaccinations$ vac
	On	dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;


-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated / population) * 100
FROM PorfolioProject..CovidDeaths$ dea
Join PorfolioProject..CovidVaccinations$ vac
	On	dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (rolling_people_vaccinated / population) * 100 AS vaccinated_population
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated

(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated / population) * 100
FROM PorfolioProject..CovidDeaths$ dea
Join PorfolioProject..CovidVaccinations$ vac
	On	dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (rolling_people_vaccinated / population) * 100 AS vaccinated_population
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated / population) * 100
FROM PorfolioProject..CovidDeaths$ dea
Join PorfolioProject..CovidVaccinations$ vac
	On	dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated
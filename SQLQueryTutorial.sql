SELECT *
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- SELECT THE DATA THAT WE ARE GOING TO BE USING


SELECT location, date, total_cases, new_cases, total_deaths, population_density
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2


-- LOOKING AT TOTAL CASES VERSUS TOTAL DEATHS
-- SHOWS THE LIKELIHOOD OF DEATH IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT location, date, total_cases, new_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%state%'
ORDER BY 1,2


-- LOOKING AT THE TOTAL CASES VERSUS THE POPULATION DENSITY
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID-19


SELECT location, date, total_cases, population_density, (cast(total_cases as float)/cast(population_density as float))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United Kingdom'
ORDER BY 1,2


-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION DENSITY

SELECT location, population_density, MAX(total_cases) AS HighestInfectionCount, (cast(MAX(total_cases) as float)/cast(population_density as float))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United Kingdom'
GROUP BY location, population_density
ORDER BY DeathPercentage DESC



-- LOOKING AT COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION DENSITY

SELECT location, MAX(cast(total_deaths as float)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United Kingdom'
WHERE Continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- TOTALDEATHCOUNT BY CONTINENT


SELECT continent, MAX(cast(total_deaths as float)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United Kingdom'
WHERE Continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- SHOWING THE CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION DENSITY


SELECT continent, MAX(cast(total_deaths as float)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United Kingdom'
WHERE Continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS


SELECT SUM(new_cases), SUM(cast(new_deaths AS float)), (SUM(cast(new_deaths AS float))/SUM(new_cases))*100 AS DeathPercentage -- total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'United Kingdom'
WHERE Continent IS NOT NULL AND new_deaths <> 0 AND new_cases <> 0
--GROUP BY date
ORDER BY 1,2



-- LOOKING AT TOTAL POPULATION DENSITY VERSUS VACCINATION

SELECT dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated, (RollingpeopleVaccinated/population_density)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3 

-- USING CTE

WITH PopvsVac (continent, location, date, population_density, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 
)
SELECT *, (RollingPeopleVaccinated/population_density)*100
FROM PopvsVac

-- USING TEMP TABLES

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population_density numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 
SELECT *, (RollingPeopleVaccinated/population_density)*100
FROM #PercentPopulationVaccinated




-- CREATING VIEW TO STORE DATA FOR LATER VISUALISATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3 

SELECT *
FROM PercentPopulationVaccinated


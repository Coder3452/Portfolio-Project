
--Select all data from the CovidDeath table within the Portfolio Project database.
--Select all rows where the continent column is not null.
--Organize in ascending order via iso_code.


SELECT *
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
ORDER BY iso_code

------------------------------------------------------------------------------------

--Select the all from the location, date, total_cases, new_cases, total_cases, and population,
--within the CovidDeaths table.
--Organize in ascending order via both the location column (1) and the date column (2).


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths$
ORDER BY 1,2

------------------------------------------------------------------------------------

--Looking at Total Cases vs Total Deaths from the CovidDeaths table.
--Show likelihood of dying if you contract COVID in your country.
--Sort where the location has the word 'states' in its input.
--Organize by both the location (1) and date (2) in ascending order.


SELECT location, date, total_cases,total_deaths,(CAST(total_deaths as float)) /(CAST(total_cases as float))* 100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2

------------------------------------------------------------------------------------

--Looking at Total Cases vs Popluation.
--Shows what percentage of population got COVID.
--Organized via InfectionPercentage in ascending order.


SELECT location, date, total_cases,population,(CAST(total_cases as float)) /(CAST(population as float))* 100 as InfectionPercentage
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%states%'
ORDER BY 5

------------------------------------------------------------------------------------

--Which countrys have highest infection rate compared to population. 


SELECT location,MAX(total_cases) as HighestInfectionCount,population,MAX((total_cases/population))* 100 as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths$
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

------------------------------------------------------------------------------------

--Organize TotalDeathCount via continent.
--Organized in ascending order by TotalDeathCount.


SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths$
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

------------------------------------------------------------------------------------

--Show global numbers of total cases, tota deaths and their respective death percentage.
--Organized via ascending date.
--Data only collected where row in the continent column is not null.
--Organize via date in ascending order.
--ANSI_WARNIGNS TURNED OFF, so errors from dividing by zero and null are not raised.
--ARITHABORT TURNED OFF, so errors from dividig by zero are not raised.


SET ANSI_WARNINGS OFF
SET ARITHABORT OFF

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as float)) as total_deaths, SUM(CAST(new_deaths as float))/SUM(New_Cases)* 100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY date

------------------------------------------------------------------------------------

--Looking at Total Population vs Vaccination.
--Creating a Common Table Expression (CTE) to show a country's total population,
--increase in vaccinations, overall people vaccinated, and the sequential percentage increase
--of a country's population vaccinated.
--This is to make information easier to access.


WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
 ON dea.location = vac.location
 and dea.date = vac.date
 WHERE dea.continent is not null
-- ORDER BY 2,3
 )
 SELECT * , (RollingPeopleVaccinated/Population)*100 as PopVaxedPercentage
 FROM PopvsVac

 ----------------------------------------------------------------------------------

 --TEMP TABLE


 DROP TABLE IF exists #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
 ON dea.location = vac.location
 and dea.date = vac.date
 WHERE dea.continent is not null
-- ORDER BY 2,3
 
 SELECT * , (RollingPeopleVaccinated/Population)*100
 FROM #PercentPopulationVaccinated

 --------------------------------------------------------------------------------

 -- Creating View to store data for later visualizations.


 DROP VIEW IF EXISTS PercentPopulationVaccinated
 CREATE VIEW PercentPopulationVaccinated as
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
 ON dea.location = vac.location
 and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated

--------------------------------------------------------------------------------

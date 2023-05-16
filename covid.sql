-- First data exploration
SELECT *
FROM covid.coviddeaths
WHERE continent is not null
order by 3;

-- Total cases vs total deaths (death percentage if you contract covid)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM covid.deaths
WHERE location in ("%states%","canada", "india", "germany", "france","%kingdome%")
order by 1,2;

-- Total cases vs population
SELECT location, date, total_cases, population, (total_cases/population)*100 as Population_Infected
FROM covid.deaths
order by 1,2;

-- Countries with highest infection rate compared to population
SELECT location, MAX(total_cases) AS Highest_Infection, population, MAX((total_cases/population))*100 as Population_Infected
FROM covid.deaths
GROUP BY location, population	
order by Population_Infected DESC;

-- Countries with highest death count per population
SELECT location, MAX(cast(total_deaths as real)) AS Total_Deaths
FROM covid.deaths
WHERE continent is not null
GROUP BY location	
order by Total_Deaths DESC;

-- Continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as real)) AS Total_Deaths
FROM covid.deaths
WHERE continent is not null
GROUP BY continent	
order by Total_Deaths DESC;

-- Global cases
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as real)) as total_deaths, SUM(cast(new_deaths as real))/SUM(new_cases)* 100 as Death_Percentage
FROM covid.deaths
WHERE continent is not null
order by 1,2;

-- Data exploration of joining tables
SELECT *
FROM covid.deaths d
JOIN covid.vaccinations v
	ON d.location = v.location
    and d.date = v.date;

-- Total vaccinations vs population
SELECT d.continent, d.location, d.population, d.date, v.new_vaccinations, SUM(cast(v.new_vaccinations as REAL)) OVER (PARTITION by d.location ORDER by d.location, d.date)
as People_Vaccinated, (People_Vaccinated/population)*100 as Vaccination_Percentage
FROM covid.deaths d
JOIN covid.vaccinations v
	ON d.location = v.location
    and d.date = v.date
WHERE d.continent is not null
order by 1,2,3;

-- Table to export to Tableau (1)
Select location, SUM(cast(new_deaths as real)) as TotalDeathCount
From covid.deaths
Where continent is not null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;

-- 2 PercentPopulationInfected
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid.deaths
Group by Location, Population
order by PercentPopulationInfected desc;

-- 3 PercentPopulationInfected with date
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid.deaths
Group by Location, Population, date
order by PercentPopulationInfected desc;

-- 4 RollingPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
From Covid.Deaths dea
Join covid.vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3;

-- 5 total_deaths with date
Select Location, date, population, total_cases, total_deaths
From Covid.Deaths
where continent is not null 
order by 1,2;

-- 6 Join table
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as real)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Covid.Deaths dea
Join Covid.Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)

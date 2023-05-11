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

-- Temporal Table
create table TempTable
(
Continent varchat(225),
Location varchat(255),
Date datetime,
Population numeric,
New_Vaccionations numeric,
Vaccination_Percentage numeric
)
insert into #TempTable
SELECT d.continent, d.location, d.population, d.date, v.new_vaccinations, SUM(cast(v.new_vaccinations as REAL)) OVER (PARTITION by d.location ORDER by d.location, d.date)
as People_Vaccinated, (People_Vaccinated/population)*100 as Vaccination_Percentage
FROM covid.deaths d
JOIN covid.vaccinations v
	ON d.location = v.location
    and d.date = v.date
WHERE d.continent is not null
order by 1,2,3;

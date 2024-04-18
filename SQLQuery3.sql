SELECT *
FROM covid..covid_death
WHERE continent is not null
order by 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid..covid_death
WHERE continent is not null
order by 1,2 

--Looking at Toatl cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
FROM covid..covid_death
WHERE location like '%India%'
and continent is not null
order by 1,2 

-- looking at Total Cases vs Population
--Shows what percentage of population got covid

Select location, date, population, total_cases, (cast(total_deaths as float)/cast(population as float))*100 as DeathPercentage
FROM covid..covid_death
WHERE location like '%India%'
and continent is not null
order by 1,2 

--looking at Countries with highest Infection rate compared to population 

Select location,population, MAX(total_cases) as HighestInfectionCount, MAX((cast(total_cases as float)/cast(population as float)))*100 as PercentPopulationInfected
FROM covid..covid_death
WHERE continent is not null
--WHERE location like '%India%'
GROUP BY location, population
order by PercentPopulationInfected desc

--Showing countries with highest Death count per poulation

Select location, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM covid..covid_death
WHERE continent is not null
--WHERE location like '%India%'
GROUP BY location
order by TotalDeathsCount desc

--Breaking things down based on continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM covid..covid_death
WHERE continent is null
--WHERE location like '%India%'
GROUP BY Location
order by TotalDeathsCount desc

--Showing continent with highest death counts

SELECT Continent,MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM covid..covid_death
WHERE continent is not null
GROUP BY continent
order by TotalDeathsCount desc

--Global Numbers

Select date, SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths
--SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)) * 100 as DeathPercentage
FROM covid..covid_death                                     
--WHERE location like '%India%'
WHERE continent is not null
GROUP BY date
order by 1,2 

SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM covid..covid_death dea
JOIN covid..covid_vacc vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
order by 2,3

--Looking at Total Population vs Total vaccination 

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date)
as RollingPeopleVaccinated
FROM covid..covid_death dea
JOIN covid..covid_vacc vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3


SELECT * 
FROM PercentPopulationVaccinated
Select *
From [Portfolio Project]..CovidDeaths
Order By 3,4

Select *
From [Portfolio Project]..CovidVaccinations
Order By 3,4
--select data to be used
Select Location, date, total_cases, new_cases,total_deaths, population
From [Portfolio Project]..CovidDeaths
Order By 1,2

--Comparing Total Cases vs Total deaths
--Shows the likelihood of dying if you contracted COVID in your the USA
Select Location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where Location Like '%states%'
Order By 1,2

Select Location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where Location Like '%Africa%'
Order By 1,2



--Comparing Total Cases vs Population
--Shows the percentage of populaton infected with COVID
Select Location, date, total_cases, population, (Total_cases/Population)*100 as Infection_rate
From [Portfolio Project]..CovidDeaths
WHERE Location like '%states%'
Order By 1,2

--Looking at countries with Highest infection rates

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/Population))*100 as Infection_rate
From [Portfolio Project]..CovidDeaths
--WHERE Location like '%states%'
GROUP BY Location, Population
Order By Infection_rate DESC

--showing coutries with highest Deaths per Population
Select Location, MAX(CAST(Total_Deaths as INT)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not NULL
GROUP BY Location
Order By TotalDeathCount DESC

--BREAKDOWN BY CONTINENT--
Select Location, MAX(CAST(Total_Deaths as INT)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
WHERE continent is NULL
GROUP BY Location
Order By TotalDeathCount DESC

--Continents with the highest deathcount per Population
Select continent, MAX(CAST(Total_Deaths as INT)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
Order By TotalDeathCount DESC

--GLOBAL NUMBERS
Select Location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
WHERE continent is not null
Order By 1,2

--new cases
Select date, SUM(new_cases)
From [Portfolio Project]..CovidDeaths
Where continent is not null
GROUP BY date
ORDER BY 1,2


Select date, SUM(new_cases), SUM(CAST(new_deaths as INT))
From [Portfolio Project]..CovidDeaths
Where continent is not null
GROUP BY date
ORDER BY 1,2


Select date, SUM(new_cases) total_cases, SUM(CAST(new_deaths as INT))as total_deaths, (SUM(CAST(new_deaths as INT))/SUM(new_cases))*100 as DailyDeathRate
From [Portfolio Project]..CovidDeaths
Where continent is not null
GROUP BY date
ORDER BY 1,2
--Global deathrate
Select SUM(new_cases) total_cases, SUM(CAST(new_deaths as INT))as total_deaths, (SUM(CAST(new_deaths as INT))/SUM(new_cases))*100 as DailyDeathRate
From [Portfolio Project]..CovidDeaths
Where continent is not null
--GROUP BY date
ORDER BY 1,2

--Total Vaccinations vs population
Select * 
FROM  [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
      On dea.location =vac.location
      and dea.date =vac.date

 Select  dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations 
FROM  [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
      On dea.location =vac.location
      and dea.date =vac.date
Where dea.continent is not null
Order by 1,2,3

Select  dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM  [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
      On dea.location =vac.location
      and dea.date =vac.date
Where dea.continent is not null
Order by 2,3

Select  dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM  [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
      On dea.location =vac.location
      and dea.date =vac.date
Where dea.continent is not null
Order by 2,3

--USE CTE
With popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(Select  dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM  [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
      On dea.location =vac.location
      and dea.date =vac.date
Where dea.continent is not null
)
Select * ,(RollingPeopleVaccinated/population)*100
From popvsvac

--TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select  dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM  [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
      On dea.location =vac.location
      and dea.date =vac.date
Where dea.continent is not null

Select * ,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating views for storing data for later visualization

DROP VIEW if EXISTS DeathrateinUSA
GO
CREATE VIEW DeathrateintheUSA as

Select Location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where Location Like '%states%'
--Order By 1,2

GO
CREATE VIEW Deathratebycountry as

Select Location, MAX(CAST(Total_Deaths as INT)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not NULL
GROUP BY Location


GO
CREATE VIEW Highestinfectionratebycountry as
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/Population))*100 as Infection_rate
From [Portfolio Project]..CovidDeaths
--WHERE Location like '%states%'
GROUP BY Location, Population

GO
CREATE VIEW GlobalDeathrate as
Select SUM(new_cases) total_cases, SUM(CAST(new_deaths as INT))as total_deaths, (SUM(CAST(new_deaths as INT))/SUM(new_cases))*100 as DailyDeathRate
From [Portfolio Project]..CovidDeaths
Where continent is not null


GO
CREATE VIEW Rollingnumbervaccinated as
Select  dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM  [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
      On dea.location =vac.location
      and dea.date =vac.date
Where dea.continent is not null
--Order by 2,3


--Covid 10 Data Exploration

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


select *
from PortfolioProject..CovidDeaths
where continent is not null 
order by 3,4

--select data that we are going to be starting with 

select location,date,total_cases, new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where Continent is not null
order by 1,2

--Total Cases Vs Total Deaths
 --Shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%kingdom%'
and continent is not null
order by 1,2

--Total Cases Vs Population 
 --Shows what percentage of population infected with Covid

select location,date,total_cases, population, (total_deaths/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%kingdom%'
order by 1,2


--Countries with highest Infection rate compared to Population

select location, population, Max (total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PerecentPopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%kingdom%'
Group by Location, population
order by PerecentPopulationInfected desc

--Highest Death Count Per Population

select location, Max(cast(total_deaths as INT)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%kingdom%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--BREAKING THINGS DOWN BY CONTINENT

--Continents with highest death count per population

select continent, Max(cast(total_deaths as INT)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%kingdom%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

select date,sum (new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int )) / Sum(new_cases)* 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--Where location like '%kingdom%'
where continent is not null
Group by date
order by 1,2

--Total Population Vs Vaccinations
--Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as INT)) over (partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
order by 2,3

--Using CTE to perform calculation on Partition by previous query

with PopvsVac ( continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as INT)) over (partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population*100)
From PopvsVac

--Using Temp Table to perform calculation on Partition by in previous query

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as INT)) over (partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population*100)
From #PercentPopulationVaccinated

--Creating View to Store data for Visualisation
Use PortfolioProject
GO
Create View PerecentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as INT)) over (partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date= vac.date
where dea.continent is not null

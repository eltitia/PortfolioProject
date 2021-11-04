--make sure i have the right files

Select *
From PortfolioProject..CovidDeaths
order by 3,4


Select *
From PortfolioProject..CovidVaccinations
order by 3,4

--Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
order by 1,2


-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Showing contintents with the highest death count per population

Select continent, MAX(Convert(int,Total_deaths)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


---join two tables covidvacinations and coviddeaths
---we named the project dea because i don't want to retype all name

Select *
From PortfolioProject..CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
    on dea.location= vac.location
	and dea.date = vac.date


--Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopVac)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopVac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (PeopVac/Population)*100
From PopvsVac

--create temp table

DROP Table if exists #covidforage
Create Table #covidforage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population_density numeric,
aged_65_older numeric,
peopvac numeric
)

--insert into table covid for people vaccined age over 65

Insert into #covidforage
Select dea.continent, dea.location, dea.date, vac.Population_density,vac.aged_65_older 
, SUM(CONVERT(int,vac.aged_65_older)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as peopvac
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	
Select *, (peopvac/Population_density)*100
From #covidforage





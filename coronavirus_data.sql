SELECT*
From CovidProject..coviddeaths
where continent is null
order by 3,4

-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..coviddeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if effected by covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..coviddeaths
Where location like '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population contracted Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentofInfectedPop
From CovidProject..coviddeaths
Where location like '%states%'
order by 1,2

-- Looking at countrys with hightest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentofInfectedPop
From CovidProject..coviddeaths
--Where location like '%China%'
Group by Location, population
order by PercentofInfectedPop desc

-- Showing countries with Highest Death Count per population

Select Location, population, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX(total_deaths/population)*100 as DeathRate
From CovidProject..coviddeaths
Where continent is not null
Group by Location, population
order by TotalDeathCount desc

-- Break down by continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..coviddeaths
Where continent is null
Group by location
order by TotalDeathCount desc

-- Displaying continents with highest death count by population

Select continent, SUM(CAST(total_deaths as int)) as TotalDeathCount
From CovidProject.. coviddeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Number totals for global 

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage 
From CovidProject..coviddeaths
Where continent is not null
order by 1,2

-- Examining vaccinated population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingVaccinated
From CovidProject..coviddeaths dea
Join CovidProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Examining vaccinated population using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingVaccinated
From CovidProject..coviddeaths dea
Join CovidProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select*, (RollingVaccinated/Population)*100 as PercentVaccinated
From PopvsVac

-- Temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_vacinnations numeric, 
RollingVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingVaccinated
From CovidProject..coviddeaths dea
Join CovidProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select*, (RollingVaccinated/Population)*100 as PercentVaccinated
From #PercentPopulationVaccinated

-- Create view to store data for visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingVaccinated
From CovidProject..coviddeaths dea
Join CovidProject..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select*
From PercentPopulationVaccinated
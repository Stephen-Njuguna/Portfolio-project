-- Previewing the Covid-19 Deaths datasets
select * from 
PortfolioProject..CovidDeaths
order by 3,4;

-- Selecting data that we are going to use
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2 ;

-- Looking at Total cases vs Total deaths
-- This shows the likelihood of one dying if the contract covid-19 in kenya 

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where Location like '%kenya%'
order by 1,2 ;

-- Previwing Total cases vs Population 
-- This shows the percentage of the population that contracted covid-19

select Location, date, total_cases, population, (total_cases/population)*100 as CovidPositive
from PortfolioProject..CovidDeaths
--where Location like '%kenya%'
order by 1,2 desc;

-- Previewing country with highest infection rate 
-- Showing country with the highest infection count

select Location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationCovidPositive
from PortfolioProject..CovidDeaths
group by Location,  population
order by PercentagePopulationCovidPositive desc;

-- showing countries with highest death count per population 

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;

-- Showing continent with highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

-- Global Numbers

-- Look at Percentage of deaths grobally

select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 ;

-- Previewing the Covid-19 Vaccination dataset
select * from PortfolioProject..CovidVaccinations
order by 3,4;

-- Joining The two tables
select * from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
On dea.location =vac.location
and dea.date = vac.date

-- Looking at Total population vs Vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint))OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
On dea.location =vac.location
and dea.date = vac.date
where (dea.continent is not null and vac.new_vaccinations is not null);

-- Creating a temportary table 

Drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint))OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
On dea.location =vac.location
and dea.date = vac.date
where (dea.continent is not null and vac.new_vaccinations is not null);

select *, (RollingPeopleVaccinated/Population)*100 as PercentagePopulationVaccinated
from #PercentagePopulationVaccinated ;

-- creating view to store data for visualization later

create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint))OVER (Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
On dea.location =vac.location
and dea.date = vac.date
where (dea.continent is not null and vac.new_vaccinations is not null);
 

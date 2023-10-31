

select *
from [Portfolio Project].dbo.coviddeaths
order by 3,4

-- Select Data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project].dbo.coviddeaths
order by 1,2

-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract covid in the United States
select location, date, total_cases, total_deaths, convert(float,total_deaths)/convert(float,total_cases)*100 as DeathPercentage
from [Portfolio Project].dbo.coviddeaths
where location = 'United States'
order by 1,2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got covid
select location, date, total_cases, population, convert(float,total_cases)/convert(float,population)*100 as InfectedPercentage
from [Portfolio Project].dbo.coviddeaths
where location = 'United States'
order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population
select location, max(total_cases)as HighestInfectionCount, population, Max(convert(float,total_cases)/convert(float,population))*100 as InfectedPercentage
from [Portfolio Project].dbo.coviddeaths
group by Location, Population
order by InfectedPercentage desc

-- Showing countries with Highest Death Count per Population
select location, max(convert(int,total_deaths)) as TotalDeathCount
from [Portfolio Project].dbo.coviddeaths
where continent is not null
group by Location
order by TotalDeathCount desc

-- Showing continents with Highest Death Count per Population
select continent, max(convert(int,total_deaths)) as TotalDeathCount
from [Portfolio Project].dbo.coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathPercentage
from [Portfolio Project].dbo.coviddeaths
where continent is not null
group by date
order by 1,2

-- Looking at Total Population vs Vaccination
-- Use CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.coviddeaths dea
join [Portfolio Project].dbo.covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100
from popvsvac

-- Temp Table
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated bigint
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.coviddeaths dea
join [Portfolio Project].dbo.covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating view to store data.

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project].dbo.coviddeaths dea
join [Portfolio Project].dbo.covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated

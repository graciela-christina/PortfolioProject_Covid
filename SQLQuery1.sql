select * from PortfolioProject.. CovidDeaths
order by 3,4

select * from PortfolioProject.. CovidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%states%'
and continent is not null
Order By 1,2



-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where Location like '%states%'
and continent is not null
Order By 1,2



--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS 
	PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
where continent is not null
Group By Location, Population
Order By PercentPopulationInfected DESC


--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as INT)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
Group By Location
Order By TotalDeathCount DESC



-- Break things down by Continents

--Showing continents with the highest death count per population
Select continent, MAX(cast(total_deaths as INT)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent IS NOT NULL
Group by continent
order by TotalDeathCount DESC



--Global Numbers
--Total Cases, Total Deaths, and Deaths Percentage Per Day
Select date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/
	SUM(new_cases) *100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
Order By 1,2


--Total Cases, Total Deaths, and Deaths Percentage In Summary
Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/
	SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Order By 1,2





--JOINING TWO TABLES: COVID VACCINATIONS DATA & COVID DEATHS DATA

select *
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
	


--Total Poluation vs Vaccinations Part 1
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Total Poluation vs Vaccinations Part 2
--Parition By Function
--Convert to BIGIINT not INT
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date)
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Total Poluation vs Vaccinations Part 3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVacciinated)
AS
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date)
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVacciinated/Population)*100
From PopvsVac






--Temp Table


Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date)
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated






--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject.. CovidDeaths dea
join PortfolioProject.. CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



--SEE THE DATA IN THE VIEW CREATED
Select *
From PercentPopulationVaccinated


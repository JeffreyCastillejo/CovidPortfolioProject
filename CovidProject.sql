Select * 
From [Portfolio Project]..CovidDeaths$
where continent is not null 
order by 3, 4

Select * 
From [Portfolio Project]..CovidVaccinations$
where continent is not null 
order by 3, 4

-- Select the Data that we are going to be using 
Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths$
where continent is not null 
order by 1,2

--Looking at the Total cases vs Total Deaths 
--shows likelihood of dying is you contract covid in your country 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From [Portfolio Project]..CovidDeaths$
where continent is not null 
Where location like '%states%'
order by 1,2

--looking at total cases vs. population 
--shows what percentage of the population has gotten covid
Select Location, date, population, total_cases, (total_cases/population)*100 as CovidPositivePercentage
From [Portfolio Project]..CovidDeaths$
where continent is not null 
--Where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS InfectedPopulationPercentage
From [Portfolio Project]..CovidDeaths$
--Where location like '%states%'
where continent is not null 
Group By population,location
order by InfectedPopulationPercentage desc


--Showing countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
where continent is not null 
--Where location like '%states%'
Group By location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT 
--Showing the continents with the highest death count per population 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths$
where continent is not null 
--Where location like '%states%'
Group By continent
order by TotalDeathCount desc

--GLOBAL NUMBERS 
Select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths$
where continent is not null 
--Group by date
order by 1,2


--Looking at Total Population vs Vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location, dea.Date)
as RollingPeopleVaccianted
From [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--use CTE
WITH PopulationvsVacciantion (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location
, dea.Date) as RollingPeopleVaccianted
From [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopulationvsVacciantion

--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated --If you want to run the query again with changes
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location
, dea.Date) as RollingPeopleVaccianted
From [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated 

--creating view to store data later for later visualizations 

Create View PercentPopulationVaccincated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location
, dea.Date) as RollingPeopleVaccianted
From [Portfolio Project]..CovidDeaths$ dea
JOIN [Portfolio Project]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

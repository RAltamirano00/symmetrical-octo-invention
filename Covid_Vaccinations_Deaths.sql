Select *
From RAPP..CovidDeaths
Where continent is not null 
Order by 3,4


--Select *
--From RAPP..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From RAPP..CovidDeaths
Where continent is not null 
Order by 1,2

--Looking at total cases versus total deaths
-- Shows likelyhood of dying if you contract Covid in the United States

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From RAPP..CovidDeaths
Where continent is not null 
Where location like '%states%'
Order by 1,2

--Looking at total cases versus population
--Shows what percentage of the population got COVID

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From RAPP..CovidDeaths
Where continent is not null 
--Where location like '%states%'
Order by 1,2

--Looking at countries with highest infection rate compared to population

Select Location, population, max(total_cases) as HighestInfectionCount, Max((total_cases)/population)*100 as PercentPopulationInfected
From RAPP..CovidDeaths
Where continent is not null 
--Where location like '%states%'
Group by Location, population
Order by PercentPopulationInfected desc

--Showing countries with the highest death count per population

Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From RAPP..CovidDeaths
Where continent is not null 
--Where location like '%states%'
Group by Location
Order by TotalDeathCount desc

--Showing Continents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From RAPP..CovidDeaths
Where continent is not null 
--Where location like '%states%'
Group by continent
Order by TotalDeathCount desc


-- Global numbers

Select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From RAPP..CovidDeaths
Where continent is not null 
Group by date 
Order by 1,2

Select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From RAPP..CovidDeaths
Where continent is not null 
--Group by date 
Order by 1,2


-- Total population versus vaccination 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From rapp..CovidVaccinations vac
join rapp..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--Use CTE 

With PopvsVac (Continent, Location, Data, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From rapp..CovidVaccinations vac
join rapp..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)


--Creating view to store data for later visualization

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From rapp..CovidVaccinations vac
join rapp..CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
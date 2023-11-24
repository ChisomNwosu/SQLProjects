Select *
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4


-- Select data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2


--Looking at the Total Cases vs Total Death
--Shows likelihood of dying if you contact covid in your country


Select Location, date, Population,  total_cases, (total_cases/Population)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths$
Where location like '%Nigeria%'
and continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to the population

Select Location, Population, MAX (total_cases) as HighestInfetionCount,  MAX(total_cases/Population)*100 as PercentagePopulationInfected 
From PortfolioProject..CovidDeaths$
Group by location, population
order by PercentagePopulationInfected desc


--Showing Countries With The Highest Death Count Per Population

Select location, MAX (cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount desc

--Lets break things by continent

Select location, MAX (cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths$
where continent is null
Group by location
order by TotalDeathCount desc


--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage  
From PortfolioProject..CovidDeaths$
--Where location like '%Nigeria%'
where continent is not null
--Group by date
order by 1,2


--Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
    dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (continent, location, date, population, vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
    dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp table
DROP Table if exists #percentPopulationVaccinated
Create table #percentpopulationVaccinated
(
continent nvarchar(255),
location nvarchar(225),
Date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)


Insert into #percentpopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
    dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
  On dea.location = vac.location
  and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #percentpopulationVaccinated


--Creating View to store data for later visualization

Create View percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
    dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3


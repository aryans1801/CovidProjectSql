Select *
From PortfolioProject..CovidDeaths
Where continent is not NULL
Order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Selecting Data that we are going to use 

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Order by 1,2

--Total Cases vs Total Deaths and dying if u get covid in india :(
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'India'
Order by 1,2

--Total Cases vs Percentage 
Select location,date,population,total_cases,(total_cases/population)*100 as PercentofPopulationInfection
From PortfolioProject..CovidDeaths
Where location like 'India'
Order by 1,2

--Countries with highest infection rate compared to population
Select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100) as PercentofPopulationInfection
From PortfolioProject..CovidDeaths
Group By location,population
Order by PercentofPopulationInfection DESC

--Countries with highest daeth count per population
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group By location
Order by TotalDeathCount DESC

-- By continent
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group By continent
Order by TotalDeathCount DESC


--// Important

--By country correct data
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is  NULL
Group By location
Order by TotalDeathCount DESC


--By continent correct data
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not  NULL
Group By continent
Order by TotalDeathCount DESC


--Showing continents with highest death count
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group By continent
Order by TotalDeathCount DESC


--Global numbers
Select date,SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2


--total cases and deaths in world
Select SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


-- Total Population vs Vaccinations
Select d.continent,d.location, d.date,d.population,v.new_vaccinations
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v 
ON d.location=v.location and d.date=v.date
Where d.continent is not null
Order by 1,2,3


-- Rolling Count of vaccination
Select d.continent,d.location, d.date,d.population,v.new_vaccinations,
SUM(Convert(bigint,v.new_vaccinations)) Over (Partition by d.location order by d.location,d.date) as RolllingVaccinatedCount
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v 
ON d.location=v.location and d.date=v.date
Where d.continent is not null
Order by 1,2,3



--CTE 
With CTE_Vaccination (Continent,Location,Date,Population,New_Vaccinations,RollingVaccinatedCount) as (
Select d.continent,d.location, d.date,d.population,v.new_vaccinations,
SUM(Convert(bigint,v.new_vaccinations)) Over (Partition by d.location order by d.location,d.date) as RolllingVaccinatedCount
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v 
ON d.location=v.location and d.date=v.date
Where d.continent is not null
--Order by 1,2,3
)
Select * ,(RollingVaccinatedCount/Population)*100 as RollingPercent
From CTE_Vaccination




--temp-table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select d.continent,d.location, d.date,d.population,v.new_vaccinations,
SUM(Convert(bigint,v.new_vaccinations)) Over (Partition by d.location order by d.location,d.date) as RolllingVaccinatedCount
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v 
ON d.location=v.location and d.date=v.date
Where d.continent is not null
--Order by 1,2,3

Select * ,(RollingVaccinated/Population)*100 as RollingPercent
From #PercentPopulationVaccinated



--View

Create View PercentPopulationVaccinated as 
Select d.continent,d.location, d.date,d.population,v.new_vaccinations,
SUM(Convert(bigint,v.new_vaccinations)) Over (Partition by d.location order by d.location,d.date) as RolllingVaccinatedCount
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v 
ON d.location=v.location and d.date=v.date
Where d.continent is not null
--Order by 2,3

Drop View PercentPopulationVaccinated

Select *
FROM PercentPopulationVaccinated
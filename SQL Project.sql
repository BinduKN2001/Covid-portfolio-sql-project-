Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
order by 1,2

--total cases vs Total Deaths
Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
where location like 'ind%'
order by 1,2

-- looking at total cases vs population
--what percentage of population got covid
Select Location,date, total_cases,population,(total_cases/population)*100 as Populationaffected
From PortfolioProject..CovidDeaths
where location like 'ind%'
order by 1,2

--country with highest infection rate compared to population
Select Location,population, Max(total_cases) as highest_infection_count,Max(total_cases/population)*100 as Populationaffected
From PortfolioProject..CovidDeaths
Group by Location,population
order by Populationaffected desc

--Coutries with highest death count per population
Select Location,Max(total_deaths) as Total_death_count
From PortfolioProject..CovidDeaths
Group by Location
order by Total_death_count desc

--Continent deathrate
Select continent,Max(cast(total_deaths as int)) as Total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by Total_death_count desc

--continent with highest death count per population
select continent,population,Max(cast(total_deaths as int)) as Total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent,population
order by Total_death_count desc

--Global numbers filtering just by date not location
Select date, total_cases,(total_deaths/total_cases)*100 as affected
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--overall percentage of total deaths around the world
Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,Sum(cast(new_deaths as int))/ Sum(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Combining both Death table and vaccination table
Select *
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date

-- Total population vs vaccination
Select death.continent, death.location, death.date,death.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date
where vac.new_vaccinations is not null
order by 1,2,3

-- Total population vs vaccination by location
Select death.continent, death.location, death.date,death.population, vac.new_vaccinations, Sum(Convert(int,vac.new_vaccinations)) over (partition by death.Location)
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date
where vac.new_vaccinations is not null
order by 2,3

--Using CTE
With PopvsVac (Continent,Location, Dae,Population, New_Vaccination,RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date,death.population, vac.new_vaccinations, Sum(Convert(int,vac.new_vaccinations)) over (partition by death.Location order by death.Location,
death.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date
where vac.new_vaccinations is not null
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

-- using TEMP Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date,death.population, vac.new_vaccinations, Sum(Convert(int,vac.new_vaccinations)) over (partition by death.Location order by death.Location,
death.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	on death.location = vac.location
	and death.date = vac.date

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
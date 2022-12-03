

Select *
From [Covid Project] ..CovidDeaths
Where continent is not Null
order by 3,4


--Select *
--From [Covid Project] ..CovidVaccinations
order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
From [Covid Project] ..CovidDeaths
Where continent is not Null
order by 1,2

-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Covid Project] ..CovidDeaths
Where continent is not Null
and location like '%states%'
order by 1,2



-- Looking at Total Cases vs Population

Select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
From [Covid Project] ..CovidDeaths
Where continent is not Null
--where location like '%australia%'
order by 1,2



--Looking at countries with highest infection rate compared to population


Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From [Covid Project] ..CovidDeaths
Where continent is not Null
--where location like '%australia%'
group by location, population
order by PercentPopulationInfected desc


--Looking at countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid Project] ..CovidDeaths
Where continent is not Null
--where location like '%australia%'
group by location
order by TotalDeathCount desc



--Break things down by Continent

--Showing the continents with the highest death count


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid Project] ..CovidDeaths
Where continent is not Null
--where location like '%australia%'
group by continent
order by TotalDeathCount desc


-- Global Numbers Breakdown


Select SUM(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Covid Project] ..CovidDeaths
Where continent is not Null
--Group by date
order by 1,2





--Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)
From [Covid Project]..CovidDeaths dea
Join [Covid Project]..CovidVaccinations vacc
   On dea.location = vacc.location
   and dea.date = vacc.date
Where dea.continent is not Null
order by 2,3



--Use CTE

With PopvsVacc (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)
From [Covid Project]..CovidDeaths dea
Join [Covid Project]..CovidVaccinations vacc
   On dea.location = vacc.location
   and dea.date = vacc.date
Where dea.continent is not Null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccPercentage
From PopvsVacc



-- Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)
From [Covid Project]..CovidDeaths dea
Join [Covid Project]..CovidVaccinations vacc
   On dea.location = vacc.location
   and dea.date = vacc.date
Where dea.continent is not Null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as VaccPercentage
From #PercentPopulationVaccinated




--Creating view to store data


Use [Covid Project]
Go
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)
From [Covid Project]..CovidDeaths dea
Join [Covid Project]..CovidVaccinations vacc
   On dea.location = vacc.location
   and dea.date = vacc.date
Where dea.continent is not Null
--order by 2,3



Select *
From PercentPopulationVaccinated



Use [Covid Project]
Go
Create View TotalDeathCount as
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid Project] ..CovidDeaths
Where continent is not Null
--where location like '%australia%'
group by continent
--order by TotalDeathCount desc


Select *
From TotalDeathCount
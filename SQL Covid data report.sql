create database covid19

use covid19

select * from [dbo].['CovidDeaths Data$'] order by 3,4

--select * from [dbo].[CovidVaccinations$] order by 3,4

---Select data that we are going to be using---

select location, date, total_cases, total_deaths, new_cases, population from [dbo].['CovidDeaths Data$'] order by 1,2

----Looking at total cases vs total deaths-------------\

select location, date, total_cases, total_deaths, new_cases, (total_deaths/total_cases) as Death_Percenatge from [dbo].['CovidDeaths Data$'] where location like '%bangla%' order by 1,2

---Looking at total cases vs population

--- shows what percenatge of population got covid

select location, date, total_cases, total_deaths, new_cases, (total_cases/population) as Death_Percenatge from [dbo].['CovidDeaths Data$'] where location like '%bangla%' order by 1,2

------Looking at countries with highest inferction rate compared to population

select location, population, max(total_cases) as Highestinfectioncount,  max((total_cases/population))*100 as Percentpopulationinfected from [dbo].['CovidDeaths Data$'] group by location,population order by Percentpopulationinfected desc;

----Showing countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount from [dbo].['CovidDeaths Data$'] where continent is  null group by location order by TotalDeathCount desc;

--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [dbo].['CovidDeaths Data$']
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


------------------Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].['CovidDeaths Data$']dea   
Join [dbo].[CovidVaccinations$]vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].['CovidDeaths Data$']dea
Join [dbo].[CovidVaccinations$]vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query


DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].['CovidDeaths Data$']dea
Join [dbo].[CovidVaccinations$]vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [dbo].['CovidDeaths Data$']dea
Join [dbo].[CovidVaccinations$]vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

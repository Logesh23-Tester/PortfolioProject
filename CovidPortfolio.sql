select * from ..CovidDeaths
order by 3,4
--select * from ..CovidVaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population 
from
PortfolioProject..CovidDeaths
order by 1,2

---Looking total cases vs Total Deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage 
from
PortfolioProject..CovidDeaths
where  continent is not null --location like '%India%' and continent is not null
order by 1,2

---Looking total cases vs population
select location,date,total_cases,population,(total_cases/population) * 100 as PopulationPercentage 
from
PortfolioProject..CovidDeaths
where  continent is not null
order by 1,2


---Looking Countries with high infection rate compared to population
select location,population,MAX(total_cases) as HighestInfectionCount
,MAX(total_cases/population) * 100 as PopulationPercentage 
from
PortfolioProject..CovidDeaths where  continent is not null
Group by location,population
order by PopulationPercentage desc

---- Showing Countries Death count compared to population
select location,MAX(cast (total_deaths as int) )as HighestDeathCount
from
PortfolioProject..CovidDeaths where  continent is not null 
Group by location
order by HighestDeathCount desc


-------- LETS break things down by continent


-------- Showing Continent with the highest death count per population

select continent,MAX(cast (total_deaths as int) )as TotalDeathCount
from PortfolioProject..CovidDeaths 
where  continent is not null 
Group by continent
order by TotalDeathCount desc


-----Global numbers ---- 

select 
SUM (new_cases) as Total_Cases,
SUM(cast(new_deaths as int )) as Total_Deaths,
SUM(cast(new_deaths as int )) / SUM(New_Cases)*100 as DeathPercentage
from
PortfolioProject..CovidDeaths
where  continent is not null 
order by 1,2

---- Looking at Total population vs Vaccinations

select de.continent,de.location,de.date,de.population,vac.new_vaccinations
,SUM(Cast (vac.new_vaccinations as int)) Over ( Partition by de.location order by de.location ,
de.date) as RollingPeopleVaccinated
from 
PortfolioProject..CovidDeaths as de
join PortfolioProject..CovidVaccinations as vac on 
de.location = vac.location
and de.date = vac.date
where de.continent is not null
order by 2,3


---USE CTE 



With PopVsVac ( Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as(

select de.continent,de.location,de.date,de.population,vac.new_vaccinations
,SUM(Cast (vac.new_vaccinations as int)) Over ( Partition by de.location order by de.location ,
de.date) as RollingPeopleVaccinated
from 
PortfolioProject..CovidDeaths as de
join PortfolioProject..CovidVaccinations as vac on 
de.location = vac.location
and de.date = vac.date
where de.continent is not null
--order by 2,3 
)
select *,(RollingPeopleVaccinated/Population)*100 
From PopVsVac


---TEMP TABLE ---
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated

select de.continent,de.location,de.date,de.population,vac.new_vaccinations
,SUM(Cast (vac.new_vaccinations as int)) Over ( Partition by de.location order by de.location ,
de.date) as RollingPeopleVaccinated
from 
PortfolioProject..CovidDeaths as de
join PortfolioProject..CovidVaccinations as vac on 
de.location = vac.location
and de.date = vac.date
where de.continent is not null
--order by 2,3 
select *,(RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated

--- Creating view to store data for later Visualizations 

CREATE View PercentPopulationVaccinated as 
select de.continent,de.location,de.date,de.population,vac.new_vaccinations
,SUM(Cast (vac.new_vaccinations as int)) Over ( Partition by de.location order by de.location ,
de.date) as RollingPeopleVaccinated
from 
PortfolioProject..CovidDeaths as de
join PortfolioProject..CovidVaccinations as vac on 
de.location = vac.location
and de.date = vac.date
where de.continent is not null
--order by 2,3 
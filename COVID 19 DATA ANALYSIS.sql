select * from sys.databases

select * from sys.tables

-- SHOWING DETAILS OF THE COVID_DEATHS TABLE

select * from CovidDeaths
where continent is not null
order by 3,4


-- SHOWING DETAILS OF THE COVID_VACCINATIONS TABLE

select * from CovidVaccinations
where continent is not null
order by 3,4


-- SELECT THE DATA TAHT WE ARE GOING TO USE 


select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2


-- LOOKING AT TOTAL CASES VS POPULATION FOR INDIA
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID CASES IN INDIA


select location, date, population,total_cases, 
round((total_cases/population)*100, 3) as Covid_Percentage
from CovidDeaths
where location = 'India'
order by 1,2


-- LOOKING AT TOTAL DEATHS vs TOTAL CASES FOR INDIA
-- SHOWS WHAT PERCENTAGE OF TOTAL DEATH AS COMPARED TO TOTAL COVID CASES IN INDIA


select location, date, total_cases, total_deaths, 
round((total_deaths / total_cases)*100, 3)  as Death_Percentage
from CovidDeaths
where location = 'India'
order by 1,2


-- LOOKING AT COUNTRIES WITH HIGHEST COVID CASES AS COMPARED TO POPULATION


select location, population, Max(total_cases) as Highest_Covid_Cases, 
round(max((total_cases/population))*100, 3) as Covid_Percentage
from CovidDeaths
group by location, population
order by  Covid_Percentage desc



-- LOOKING AT COUNTRIES WITH HIGHEST DEATH COUNT 


select location , max(cast (total_deaths as int)) as Highest_Death_Count
from CovidDeaths
where continent is not null
group by location
order by Highest_Death_Count desc


-- LOOKING AT CONTINENT WITH HIGHEST COVID CASES 


select continent , max(total_cases) as Highest_Covid_Cases
from CovidDeaths
where continent is not null
group by continent
order by Highest_Covid_Cases desc



-- LOOKING AT CONTINENT WITH HIGHEST DEATH COUNT 


select continent , max(cast (total_deaths as int)) as Highest_Death_Count
from CovidDeaths
where continent is not null
group by continent
order by Highest_Death_Count desc



-- LOOKING FOR NEW CASES AND NEW DEATHS BY DATE


select date , sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, round(sum(cast(new_deaths as int)) / sum(new_cases)*100,3) as Death_Percentage
from CovidDeaths
where continent is not null
group by date
order by 1


---JUST VIEw DETAILS OUR VACCINATION TABLE


select * from CovidVaccinations
where continent is not null
order by 3,4


--LOOKING AT  TOTAL POPULATION AND NEW VACCINATION BY DATE FOR INDIA , WE HAVE TO JOIN THE TWO TABLES 


select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations
from CovidDeaths dea 
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and dea.location = 'India'
order by 3,1


-- USING WINDOW FUNCTION FOR ROLLING COUNT FOR NEW VACCINATION BY LOCATION

select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from CovidDeaths dea 
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 3,1


--USING CTE FINDING PERCENTAGE OF PEOPLE VACCINATED AS COMPARED TO POPULATION for INDIA

with pop_vs_vac (date, continent, location, population, new_vaccinations, Rolling_People_Vaccinated)

as
(
select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from CovidDeaths dea 
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 3,1
)

select * , round((Rolling_People_Vaccinated/population)*100,3) as People_Vaccinated_vs_Population
from pop_vs_vac
where location = 'India'
order by 3,1


--USING TEMP TABLE FINDING PERCENTAGE OF PEOPLE VACCINATED AS COMPARED TO POPULATION for INDIA

drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
date datetime,
continent nvarchar(255),
location nvarchar(255),
population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)


select * from PercentPopulationVaccinated


insert into PercentPopulationVaccinated
select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from CovidDeaths dea 
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * ,round((Rolling_People_Vaccinated/population)*100,3) as People_Vaccinated_vs_Population
from PercentPopulationVaccinated
where location = 'India'
order by 3,1


-- CREATING VIEW TO STORE DATA FOR LATER VISUALISATION

create view RollingPopulationVaccinated 
as
select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from CovidDeaths dea 
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select * from RollingPopulationVaccinated 
order by 3,1
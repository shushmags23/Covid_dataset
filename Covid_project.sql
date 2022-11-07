create database covid;

use covid;	

select location,date,total_cases,new_cases,total_deaths,population
from coviddeaths
order by 1,total_deaths;

-- checking what percentage of population died due to covid in India
select location,date,total_cases,new_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from coviddeaths
where location='India'
order by 1,total_deaths;

-- -------------------------------------------------------------------

select location, population, max(total_cases) as Highestinfectioncount, 
		max((total_cases/population))*100 as percentpopulationinfected
from coviddeaths
group by 1,2
order by 4 desc;

-- ------
--  Total deathcounts by continent

select continent, max(total_deaths)
from coviddeaths
group by 1;

select sum(new_cases), sum(new_deaths), round(((sum(new_deaths)/sum(new_cases))*100),2) as Death_Percentage
from coviddeaths;

-- -----------------------
-- Joins

select * 
from coviddeaths d
join covidvaccinations v
on d.location = v.location;

-- Total population vs. Vaccinations

select d.continent, d.location, d.date, d.population, v.total_vaccinations
from coviddeaths d
join covidvaccinations v
on d.location = v.location
and d.date = v.date
order by 5 desc;


-- using window fucntions
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as running_total_of_vacc
from coviddeaths d
join covidvaccinations v
on d.location = v.location
and d.date = v.date
order by 2,3;

-- -------------------------------------------- 

-- getting the count of people that are vaccinated in a particular country

with popvac(continent, location, date, population, new_vaccinations, running_total_of_vacc)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as running_total_of_vacc
from coviddeaths d
join covidvaccinations v
on d.location = v.location
and d.date = v.date
-- order by 2,3; 
)
select *, (running_total_of_vacc/population)*100 as percent_vacctd
from popvac
where location ='India';

-- Observations made from above query is that, 
-- a. 12% of population in Albania is vaccinated.
-- b. 10.33% of population in India is vaccinated.

-- Creating VIEW for the above query;

create view PercentPopulationVaccinated as
with popvac(continent, location, date, population, new_vaccinations, running_total_of_vacc)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date) as running_total_of_vacc
from coviddeaths d
join covidvaccinations v
on d.location = v.location
and d.date = v.date
-- order by 2,3; 
)
select *, (running_total_of_vacc/population)*100 as percent_vacctd
from popvac
where location ='India';

select * from PercentPopulationVaccinated;





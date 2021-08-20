SELECT * FROM CovidDeaths 
where continent is not null
ORDER BY 3,4

SELECT * 
FROM CovidVaccinations 
ORDER BY 3,4

--Select DAta we are going to be using
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths 
order by 1,2

--Total Cases Versus Total Deaths
-- Chances you'll die if you contract the Virus
SELECT  location,date,total_cases,total_deaths,(total_deaths/total_cases)*100  as DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1,2

-- Total Cases Versus Total Population
--Shows What % of Population got Covid
SELECT  location,date,total_cases,population,(total_cases/population)*100  as PopulationPercentageInfected
from CovidDeaths
where location like '%India%'
order by 1,2

--LOoking at countries with Highest Infection Rate with population
SELECT  location,population,max(total_cases),max((total_cases/population))*100  as PopulationPercentageInfected
from CovidDeaths
--where location like '%India%'
group by location,population
order by PopulationPercentageInfected desc

-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT
--Casting nvarchar as Integer
SELECT  location, max( cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT
SELECT  continent, max( cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is  not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS
SELECT  date,sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths, (sum(cast(new_deaths as int))/sum(new_cases)) *100  as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by date desc


--Looking at total population Versus Vaccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM (cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date ) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND  dea.date=vac.date
where dea.continent is not null
order by 2,3


--Using CTE 
With PopulationVsVaccinations (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM (cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date ) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND  dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100
from PopulationVsVaccinations


-- Using Temporary table 

DROP table if exists #VaccinatedPopulationPercentage
create TABLE #VaccinatedPopulationPercentage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #VaccinatedPopulationPercentage
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM (cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date ) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND  dea.date=vac.date
where dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 FROM #VaccinatedPopulationPercentage


---CREATING VIEWS I WANT TO VISUALIZE IN TABLEAU 
Create View VaccinatedPopulationPercentage AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM (cast (vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date ) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND  dea.date=vac.date
where dea.continent is not null
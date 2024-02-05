SELECT *
FROM PortfolioProject..CovidDeath
ORDER BY 1,2


--SELECT *
--FROM PortfolioProject..CovidVaccine4

--Select the data that we are going to use

SELECT location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProject..CovidDeath
order by 1,2

--looking at total cases vs total death

SELECT location, total_cases,total_deaths, (total_deaths/total_cases)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeath
WHERE location like '%state%'
order by 1,2

--Looking at countries with highest infection rate compared population rate

SELECT location, MAX(total_cases) AS HighestInfectionRate, population, MAX((total_deaths/total_cases))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeath
GROUP BY location, population
order by PercentagePopulationInfected desc

--showing country with highest death count per population

SELECT location, MAX(total_cases) AS TotalDeathCount
FROM PortfolioProject..CovidDeath
where continent is not null
GROUP BY location
order by TotalDeathCount desc


--breaking it down by continent

SELECT continent, MAX(total_cases) AS TotalDeathCount
FROM PortfolioProject..CovidDeath
where continent is not null
GROUP BY continent
order by TotalDeathCount desc


--Global Numbers

SELECT SUM(new_cases) as total_cases,  SUM(new_deaths) as total_deaths, SUM(new_deaths) / SUM(new_cases) * 100 DeathPercentage
FROM PortfolioProject..CovidDeath
where continent is not null
order by 1,2

--Looking at Total population vs Vaccine by Joining table CovidDeath and CovidVaccine

with PopvsVac (continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeath dea
	JOIN PortfolioProject..CovidVaccine vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--Temp Table



CREATE TABLE #PercentagePopulation
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulation
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeath dea
	JOIN PortfolioProject..CovidVaccine vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null


select *, (RollingPeopleVaccinated/population)*100
from #PercentagePopulation

--Create View

create view PercentagePopulationTotal as
SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeath dea
	JOIN PortfolioProject..CovidVaccine vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where dea.continent is not null
-- Total Cases vs Total Deaths
-- Deaths % Infected by Covid
SELECT
    location
    , date
    , total_cases
    , total_deaths
    , total_deaths / CAST(total_cases as FLOAT) * 100 AS deaths_percentage
FROM PorfolioProject.dbo.CovidDeaths
-- WHERE location like '%states%'
ORDER BY 1,2

-- Creating view to store data for visualisation later
CREATE VIEW total_cases_vs_total_deaths AS
SELECT
    location
    , date
    , total_cases
    , total_deaths
    , total_deaths / CAST(total_cases as FLOAT) * 100 AS deaths_percentage
FROM PorfolioProject.dbo.CovidDeaths
-- WHERE location like '%states%'
-- ORDER BY 1,2

-- Total Cases vs Population
-- Infected Population % Infected by Covid 
SELECT
    location
    , date
    , population
    , total_cases
    , total_cases / CAST(population as FLOAT) * 100 AS infected_population
FROM PorfolioProject.dbo.CovidDeaths
-- WHERE location like '%states%'
ORDER BY 1,2

-- Creating view to store data for visualisation later
CREATE VIEW total_cases_vs_population AS
SELECT
    location
    , date
    , population
    , total_cases
    , total_cases / CAST(population as FLOAT) * 100 AS infected_population
FROM PorfolioProject.dbo.CovidDeaths
-- WHERE location like '%states%'
-- ORDER BY 1,2

-- Countries with highest infestion rate (per Population)
SELECT
    location
    , population
    , MAX(total_cases) AS highest_infection_count
    , MAX(total_cases / CAST(population as FLOAT)) * 100 AS infected_population
FROM PorfolioProject.dbo.CovidDeaths
-- WHERE location like '%states%'
GROUP BY location, population
ORDER BY infected_population DESC

-- Creating view to store data for visualisation later
CREATE VIEW countries_with_highest_infection_rate AS
SELECT
    location
    , population
    , MAX(total_cases) AS highest_infection_count
    , MAX(total_cases / CAST(population as FLOAT)) * 100 AS infected_population
FROM PorfolioProject.dbo.CovidDeaths
-- WHERE location like '%states%'
GROUP BY location, population
-- ORDER BY infected_population DESC

-- Countries with Highest Death Count (per Population)
-- Mortality Rate (aka. Total number of deaths in a population, divided by the total number of this population)
SELECT
    location
    , population
    , MAX(total_deaths) AS highest_death_count
    , MAX(total_deaths / CAST(population as FLOAT)) * 100 AS mortality_rate 
FROM PorfolioProject.dbo.CovidDeaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY highest_death_count DESC

-- Creating view to store data for visualisation later
CREATE VIEW countries_with_highest_death_count_per_population AS
SELECT
    location
    , population
    , MAX(total_deaths) AS highest_death_count
    , MAX(total_deaths / CAST(population as FLOAT)) * 100 AS mortality_rate 
FROM PorfolioProject.dbo.CovidDeaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
-- ORDER BY highest_death_count DESC

-- Countinents with Highest Death Count 
-- Mortality Rate (aka. The estimated total number of deaths in a population, divided by the total number of this population)
SELECT
    continent
    , MAX(total_deaths) AS highest_death_count
FROM PorfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
-- WHERE location like '%states%'
GROUP BY continent
ORDER BY highest_death_count DESC

-- Creating view to store data for visualisation later
CREATE VIEW continents_with_highest_death_count AS
SELECT
    continent
    , MAX(total_deaths) AS highest_death_count
FROM PorfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
-- WHERE location like '%states%'
GROUP BY continent
-- ORDER BY highest_death_count DESC

-- Global Numbers (total)
SELECT
    SUM(new_cases) AS total_cases
    , SUM(new_deaths) AS total_deaths
    , SUM(new_deaths) / SUM(CAST(new_cases as FLOAT)) * 100 AS death_percentage
FROM PorfolioProject.dbo.CovidDeaths
-- WHERE location like '%states%' 
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Creating view to store data for visualisation later
CREATE VIEW global_numbers_total AS
SELECT
    SUM(new_cases) AS total_cases
    , SUM(new_deaths) AS total_deaths
    , SUM(new_deaths) / SUM(CAST(new_cases as FLOAT)) * 100 AS death_percentage
FROM PorfolioProject.dbo.CovidDeaths
-- WHERE location like '%states%' 
WHERE continent IS NOT NULL
-- ORDER BY 1,2

-- Global Numbers (divided by date)
SELECT
    date
    , SUM(new_cases) AS total_cases
    , SUM(new_deaths) AS total_deaths
    , SUM(new_deaths) / SUM(CAST(new_cases as FLOAT)) * 100 AS death_percentage
FROM PorfolioProject.dbo.CovidDeaths
-- WHERE location like '%states%' 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Creating view to store data for visualisation later
CREATE VIEW global_numbers_divided_by_date AS
SELECT
    date
    , SUM(new_cases) AS total_cases
    , SUM(new_deaths) AS total_deaths
    , SUM(new_deaths) / SUM(CAST(new_cases as FLOAT)) * 100 AS death_percentage
FROM PorfolioProject.dbo.CovidDeaths
-- WHERE location like '%states%' 
WHERE continent IS NOT NULL
GROUP BY date
-- ORDER BY 1,2

-- Total Population vs Vaccination
-- Joining 'CovidVaccinations' to 'CovidDeaths'
-- Using CTE
WITH populationVSvaccination (continent, location, date, population, new_vaccinations, cumulated_vaccinations) AS
    (
    SELECT
        cd.continent
        ,cd.location
        ,cd.date
        ,cd.population
        ,cv.new_vaccinations
        ,SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS cumulated_vaccinations
    FROM PorfolioProject.dbo.CovidDeaths AS cd
    JOIN PorfolioProject.dbo.CovidVaccinations AS cv ON cv.location = cd.location AND cv.date = cd.date
    WHERE cd.continent IS NOT NULL
    -- ORDER BY 2,3
    )

SELECT
    *
    ,cumulated_vaccinations / CAST (population as FLOAT) * 100 AS percentage_of_population_vaccinated
FROM populationVSvaccination

-- Creating view to store data for visualisation later
CREATE VIEW population_vs_vaccination AS
    SELECT
        cd.continent
        ,cd.location
        ,cd.date
        ,cd.population
        ,cv.new_vaccinations
        ,SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS cumulated_vaccinations
    FROM PorfolioProject.dbo.CovidDeaths AS cd
    JOIN PorfolioProject.dbo.CovidVaccinations AS cv ON cv.location = cd.location AND cv.date = cd.date
    WHERE cd.continent IS NOT NULL

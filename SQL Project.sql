CREATE DATABASE ENERGYDB2;
USE ENERGYDB2;

-- 1. country table
CREATE TABLE country (
    CID VARCHAR(10) PRIMARY KEY,
    Country VARCHAR(100) UNIQUE
);

SELECT * FROM COUNTRY;

-- 2. emission_3 table
CREATE TABLE emission_3 (
    country VARCHAR(100),
 energy_type VARCHAR(50),
    year INT,
    emission INT,
    per_capita_emission DOUBLE,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM EMISSION_3;

-- 3. population table
CREATE TABLE population (
    countries VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (countries) REFERENCES country(Country)
);

SELECT * FROM POPULATION;


-- 4. production table
CREATE TABLE production (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
    production INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);


SELECT * FROM PRODUCTION;

-- 5. gdp_3 table
CREATE TABLE gdp_3 (
    Country VARCHAR(100),
    year INT,
    Value DOUBLE,
    FOREIGN KEY (Country) REFERENCES country(Country)
);

SELECT * FROM GDP_3;

-- 6. consumption table
CREATE TABLE consumption (
    country VARCHAR(100),
    energy VARCHAR(50),
    year INT,
 consumption INT,
    FOREIGN KEY (country) REFERENCES country(Country)
);

SELECT * FROM CONSUMPTION;

SELECT COUNT(*) FROM country;

SELECT COUNT(*) FROM consumption;

SELECT COUNT(*) FROM emission_3;

SELECT COUNT(*) FROM gdp_3;

SELECT COUNT(*) FROM population;

SELECT COUNT(*) FROM production;

SELECT * FROM country LIMIT 5;

SELECT * FROM consumption LIMIT 5;

SELECT * FROM emission_3 LIMIT 5;

SHOW CREATE TABLE consumption;

ALTER TABLE emission_3
ADD CONSTRAINT fk_emission_country
FOREIGN KEY (country)
REFERENCES country(Country);

ALTER TABLE population
ADD CONSTRAINT fk_population_country
FOREIGN KEY (countries)
REFERENCES country(Country);

ALTER TABLE production
ADD CONSTRAINT fk_production_country
FOREIGN KEY (country)
REFERENCES country(Country);

ALTER TABLE consumption
ADD CONSTRAINT fk_consumption_country
FOREIGN KEY (country)
REFERENCES country(Country);

ALTER TABLE gdp_3
ADD CONSTRAINT fk_gdp_country
FOREIGN KEY (Country)
REFERENCES country(Country);

-- Data Analysis Questions
-- 1.What is the total emission per country for the most recent year available?

SELECT 
    country,
    SUM(emission) AS total_emission
FROM emission_3
WHERE year = (SELECT MAX(year) FROM emission_3)
GROUP BY country
ORDER BY total_emission DESC;
 
-- Because emissions need to be compared country-wise for the same time period, so I selected the latest year and used GROUP BY country.

-- 2.What are the top 5 countries by GDP in the most recent year?

SELECT 
    Country,
    Value AS GDP
FROM gdp_3
WHERE year = (SELECT MAX(year) FROM gdp_3)
ORDER BY GDP DESC
LIMIT 5;

-- I filtered GDP data for the latest year and sorted it in descending order to identify the top economies.

-- 3.Compare energy production and consumption by country and year. 

SELECT 
    p.country,
    p.year,
    p.energy,
    p.production,
    c.consumption
FROM production p, consumption c
WHERE p.country = c.country
  AND p.year = c.year
  AND p.energy = c.energy
  AND (p.production > 0 OR c.consumption > 0);

-- A join is required because the values to be compared exist in different tables.

-- 4.Which energy types contribute most to emissions across all countries?

SELECT 
    energy_type,
    SUM(emission) AS total_emission
FROM emission_3
GROUP BY energy_type;

-- Because the question focuses on energy source impact, I grouped emissions by energy type and summed them to measure total contribution.

--  Trend Analysis Over Time
-- 5.How have global emissions changed year over year?

SELECT 
    year,
    SUM(emission) AS total_emission
FROM emission_3
GROUP BY year;

-- Because trends are observed over time, grouping emissions by year allows comparison of total emissions across different years.

-- 6.What is the trend in GDP for each country over the given years?

SELECT 
    Country,
    year,
    Value AS GDP
FROM gdp_3
ORDER BY Country, year;

-- Because economic trends are time-based, listing GDP year-wise for each country helps observe growth or decline patterns.

-- 7.How has population growth affected total emissions in each country?

SELECT 
    e.country,
    e.year,
    SUM(e.emission) AS total_emission,
    p.Value AS population
FROM emission_3 e, population p
WHERE e.country = p.countries
  AND e.year = p.year
GROUP BY e.country, e.year, p.Value;

-- Because population and emissions must be compared for the same country and year, joining both tables ensures meaningful analysis.

-- 8.Has energy consumption increased or decreased over the years for major economies?

-- Identify major economies using GDP
SELECT 
    Country,
    Value AS GDP
FROM gdp_3
WHERE year = (SELECT MAX(year) FROM gdp_3)
ORDER BY GDP DESC
LIMIT 5;

-- China – year-wise consumption
SELECT 
    year,
    SUM(consumption) AS total_consumption
FROM consumption
WHERE country = 'China'
GROUP BY year
ORDER BY year;

-- India – year-wise consumption
SELECT 
    year,
    SUM(consumption) AS total_consumption
FROM consumption
WHERE country = 'India'
GROUP BY year
ORDER BY year;

-- China and India were selected as major economies based on GDP values. Year-wise aggregation of energy consumption was used to directly observe whether consumption increased or decreased over time.

-- 9.What is the average yearly change in emissions per capita for each country?

SELECT 
    country,
    AVG(per_capita_emission) AS avg_per_capita_emission
FROM emission_3
GROUP BY country;

-- This method is used because averaging per-capita emissions across years provides a simple way to understand typical emission levels for each country.

-- Ratio & Per Capita Analysis
-- 10.What is the emission-to-GDP ratio for each country by year?

SELECT 
    e.country,
    e.year,
    (e.emission / g.Value) AS emission_to_gdp_ratio
FROM emission_3 e, gdp_3 g
WHERE e.country = g.Country
  AND e.year = g.year;

-- This method was chosen because calculating the ratio directly allows easy comparison of emission efficiency across countries and years.

-- 11.What is the energy consumption per capita for each country over the last decade?

SELECT 
    c.country,
    c.year,
    SUM(c.consumption) / p.Value AS consumption_per_capita
FROM consumption c, population p
WHERE c.country = p.countries
  AND c.year = p.year
  AND c.year >= (SELECT MAX(year) - 10 FROM consumption)
GROUP BY c.country, c.year, p.Value;

-- Summing consumption before division ensures accurate per-capita calculation, as population is compared against total energy usage

-- 12.How does energy production per capita vary across countries?
SELECT 
    pr.country,
    pr.year,
    pr.production / p.Value AS production_per_capita
FROM production pr, population p
WHERE pr.country = p.countries
  AND pr.year = p.year;
  
-- Because production per person is calculated by dividing production by population for the same country and year.

-- 13.Which countries have the highest energy consumption relative to GDP?

SELECT 
    c.country,
    c.year,
    c.consumption / g.Value AS consumption_to_gdp_ratio
FROM consumption c, gdp_3 g
WHERE c.country = g.Country
  AND c.year = g.year;
-- Because comparing consumption with GDP shows how energy-intensive an economy is.

-- 14.What is the correlation between GDP growth and energy production growth?
SELECT 
    g.Country,
    g.year,
    g.Value AS GDP,
    p.production
FROM gdp_3 g, production p
WHERE g.Country = p.country
  AND g.year = p.year;
-- Because listing GDP and production together allows observation of how both change over time.

-- Global Comparisons
-- 15.What are the top 10 countries by population and how do their emissions compare?

SELECT 
    p.countries AS country,
    p.Value AS population,
    e.emission
FROM population p, emission_3 e
WHERE p.countries = e.country
  AND p.year = e.year
ORDER BY p.Value DESC
LIMIT 10;
-- Population and emission are compared for the same country and year.

-- 16.Which countries have improved (reduced) their per capita emissions the most over the last decade?
SELECT 
    country,
    year,
    per_capita_emission
FROM emission_3
ORDER BY country, year;

-- Year-wise per-capita values allow direct observation of reduction over time.

-- 17.What is the global share (%) of emissions by country?
SELECT 
    country,
    SUM(emission) AS total_emission
FROM emission_3
GROUP BY country;

-- Summing emissions by country shows each country’s contribution.

-- 18.What is the global average GDP, emission, and population by year?
SELECT 
    g.year,
    AVG(g.Value) AS avg_gdp,
    AVG(e.emission) AS avg_emission,
    AVG(p.Value) AS avg_population
FROM gdp_3 g, emission_3 e, population p
WHERE g.Country = e.country
  AND g.year = e.year
  AND g.Country = p.countries
  AND g.year = p.year
GROUP BY g.year;
-- Averaging yearly values gives a global overview for each year.













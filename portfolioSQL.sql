-- url data: --https://covid19.who.int/data

USE COVID_19;
GO
-- SHOW DATA TABLE & ORDER BY COUNTRY
SELECT * FROM who_covid19_global_data
ORDER by 3
GO
-- CREATE VIEW AND CALCULATE NUMBER OF CURED CASE EACH YEAR
CREATE VIEW number_of_infected_case_2020 as
WITH number_of_infected_case_2020 ( Country, Total_newcases , Total_newdeaths )
as
(
	SELECT Country, sum(New_Cases) as Total_newcases , sum(New_Deaths) as Total_newdeaths
	FROM 
	(
		SELECT * FROM who_covid19_global_data
		WHERE YEAR(date_reported) = 2020
	) as wcgd
	GROUP BY Country
)
SELECT Country, Total_newcases, Total_newdeaths, 
(Total_newcases - Total_newdeaths) as number_of_cured_case
FROM number_of_infected_case_2020 

GO

-- DROP VIEW 
DROP VIEW number_of_infected_case_2020
GO

-- CREATE TABLE 
DECLARE @year int
SET @year = 2023 -- Can change year 2021, 2022,2023 
CREATE TABLE number_of_infected_case_2023
(
	Country nvarchar(100),
	Year_column int,
	Total_newcase int,
	Total_newdeaths int,
	number_of_cured_cases int
)
INSERT INTO number_of_infected_case_2023
SELECT Country, @year as Year_column, sum(New_Cases) as Total_newcases , sum(New_Deaths) as Total_newdeaths ,
	sum(New_cases) - sum(New_deaths) as number_of_cured_cases
FROM 
(
	SELECT * FROM who_covid19_global_data
	WHERE YEAR(date_reported) = @year
) as wcgd
GROUP BY Country
GO

-- CREATE NEW TABLE FOR VISUALIZATION
CREATE TABLE infected_case
(
	Country nvarchar(100),
	YEAR_COLUMN int,
	TOTAL_NEWCASES int,
	TOTAL_NEWDEATHS int,
	NUMBER_OF_CURED_CASE int
)
INSERT INTO infected_case
SELECT * from
(
	SELECT * from number_of_infected_case_2020
	UNION
	SELECT * from number_of_infected_case_2021
	UNION
	SELECT * from number_of_infected_case_2022
	UNION
	SELECT * from number_of_infected_case_2023
) as vac

-- SHOW TABLE INFECTED CASE BY MONTH
SELECT Country,Year(Date_reported) as YEAR_COLUMN , Month(Date_reported) as MONTH_COLUMN , 
	sum(New_cases) as total_cases, sum(New_deaths) as total_death
FROM who_covid19_global_data 
GROUP BY Country,Year(Date_reported) , Month(Date_reported)
ORDER BY 1

-- CREATE TABLE WITH ( JOIN TABLES INFECTED CASE BY YEAR AND QUERY TO FIND INFECTED CASE BY MONTH )
SELECT IC.Country, IC.YEAR_COLUMN, ICBM.MONTH_COLUMN, ICBM.total_cases as TOTAL_NEWCASES, ICBM.total_death as TOTAL_NEWDEATHS
INTO number_of_infected_case_by_month
FROM infected_case as IC
RIGHT JOIN
(
	SELECT Country,Year(Date_reported) as YEAR_COLUMN , Month(Date_reported) as MONTH_COLUMN , 
		sum(New_cases) as total_cases, sum(New_deaths) as total_death
	FROM who_covid19_global_data 
	GROUP BY Country,Year(Date_reported) , Month(Date_reported)
) AS ICBM
ON IC.Country = ICBM.Country AND IC.YEAR_COLUMN = ICBM.YEAR_COLUMN

SELECT * FROM infected_case
SELECT * FROM number_of_infected_case_by_month


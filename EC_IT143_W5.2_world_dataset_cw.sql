/*
***********************************************************************************
******************************
NAME: EC_IT143_W5.2_world_dataset_cw
PURPOSE: To answer mine and other's questions from the world dataset.
MODIFICATION LOG:
Ver Date Author Description
1.0 03/26/2024 CWeiss 1. Built this script for EC IT143

RUNTIME:
Xm Xs
NOTES:
This is where I talk about what this script is, why I built it, and other stuff...
This script contains all of the questions and queries needed to answer those questions
for the 5.2 assignment on creating answers.
*/
SELECT GETDATE() AS my_date;

/* Q1: JeAnna Kremer -Can you list the top ten countries 
that have the highest population? 
Can you list the lowest ten countries in terms of population? 
What three countries have the highest life expectancy? The three that have the lowest?*
cty.name, cty.population AS LocalCityPopulation, 
-- A1: This is pulled from the world dataset. No joins were required to answer the other 
student's question. */

USE WORLD;
GO

SELECT TOP 10 c.name AS Country, FORMAT(c.Population,'N','en-us') AS LargestPopulation --, COUNT(c.code)
FROM dbo.country AS c
	GROUP BY c.name, c.Population
	ORDER BY c.Population DESC
	;
	GO
SELECT TOP 10 c.name AS Country, FORMAT(c.Population,'N','en-us') AS SmallestPopulation --, COUNT(c.code)
FROM dbo.country AS c
	GROUP BY c.name, c.Population
	HAVING c.population > 0
	ORDER BY c.Population ASC
	;
	GO

/* Q2: Issac Mcintire - Name the 2 heads of states that have the highest population? I want it to show the name
of whomever is the head of state and the population.
-- A2: This is pulled from the world dataset. No joins were required to answer the other 
student's question. */

SELECT TOP 2 c.Name, c.HeadOfState, FORMAT(c.population,'N','en-us') AS Population
FROM dbo.country AS c
	GROUP BY c.Name, c.HeadOfState, c.Population
	ORDER BY c.Population DESC
	;


/* Q3: Chris Weiss (me) - What cities have a population over 5 million whose english 
speaking rate is below 30 percent? This is as if we were looking to open ESL schools and
wanted to know our demographics. 
-- A3: This is pulled from the world dataset. The country, city, and country language tables
are inner joined to pull all of the data. */


SELECT cty.Name, c.Name AS 'Country', FORMAT(cty.Population,'N','en-us') AS 'CityPopulation', cl.Language, 
cl.Percentage
FROM dbo.country AS c
	JOIN dbo.city AS cty ON cty.CountryCode=c.code
	JOIN dbo.countrylanguage AS cl ON cl.CountryCode=c.code
	WHERE cl.Language = 'English' 
	GROUP BY cty.name, c.name, cty.Population, cl.Language, cl.Percentage 
	HAVING cl.Percentage <= 30 
	ORDER BY cl.Percentage DESC, cty.Population DESC
	;
	GO


/* Q4: Chris Weiss (me) - From the previous group of cities, what are the other languages spoken in the country 
so we can understand what languages we might be teaching in? - 
-- A4: This is pulled from the world dataset. The country, city, and country language tables
are inner joined to pull all of the data. I also used a Self Join to pull the language of the
country and the percentage for the country not just assigned to the city. This was a new type
of join for me.*/




SELECT cty.Name, c.Name AS 'Country', FORMAT(cty.Population,'N','en-us') AS 'CityPopulation',
cl.Language, 
cl.Percentage, pl.Language AS 'OtherLangInCtry', pl.Percentage AS '%_Spoken'
FROM dbo.country AS c
	JOIN dbo.city AS cty ON cty.CountryCode=c.code
	JOIN dbo.countrylanguage AS cl ON cl.CountryCode=c.code
	JOIN dbo.countrylanguage AS pl ON pl.CountryCode=c.Code
	WHERE cl.Language = 'English' 
	GROUP BY cty.name, c.name, cty.Population, cl.Language, cl.Percentage, pl.Language,
	pl.Percentage
	HAVING cl.Percentage <= 30 AND pl.Language <> 'English'
	ORDER BY cl.Percentage DESC, pl.Percentage DESC, cty.population DESC, cty.name
	;
	GO
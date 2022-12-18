/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [ID]
      ,[Name]
      ,[Sex]
      ,[Age]
      ,[Height]
      ,[Weight]
      ,[Team]
      ,[NOC]
      ,[Games]
      ,[Year]
      ,[Season]
      ,[City]
      ,[Sport]
      ,[Event]
      ,[Medal]
  FROM [Olympics].[dbo].[athlete_events$]

/*** How many olympic games have been held ****/
WITH UGO AS(SELECT *, DENSE_RANK() OVER(ORDER BY count_games) AS rnk
FROM(SELECT COUNT(DISTINCT(games)) AS count_games
FROM [Olympics].[dbo].[athlete_events$])e)
SELECT count_games
FROM UGO

SELECT *, DENSE_RANK() OVER(ORDER BY count_games) AS rnk
FROM(SELECT COUNT(DISTINCT(games)) AS count_games
FROM [Olympics].[dbo].[athlete_events$])e

SELECT COUNT(DISTINCT(games)) AS count_games
FROM [Olympics].[dbo].[athlete_events$]

SELECT COUNT(games) AS count_games
FROM(SELECT DISTINCT Games
FROM [Olympics].[dbo].[athlete_events$])e

/*** List all olympic games held so far ***/
SELECT Distinct [Games]
FROM [Olympics].[dbo].[athlete_events$]
ORDER BY [Games] ASC

SELECT Games
FROM(SELECT DISTINCT games
FROM [Olympics].[dbo].[athlete_events$])e
ORDER BY Games

/*** Mention the total no of nations who participated in each olympic game **/
SELECT COUNT(DISTINCT(NOC)) AS count_nations, Games
FROM [Olympics].[dbo].[athlete_events$]
GROUP BY Games
ORDER BY Games ASC

SELECT Games, COUNT(NOC) AS count_nations
FROM(SELECT DISTINCT NOC, Games
FROM [Olympics].[dbo].[athlete_events$]) e
GROUP BY Games
ORDER BY Games

WITH UGO AS (SELECT *, DENSE_RANK() OVER(ORDER BY games) AS rnk
FROM(SELECT games, COUNT(DISTINCT(e.NOC)) AS count_countries
FROM [Olympics].[dbo].[athlete_events$] AS e
JOIN [Olympics].[dbo].[noc_regions$] AS a
ON e.NOC = a.NOC
GROUP BY Games)e)
SELECT *
FROM UGO

SELECT COUNT(DISTINCT(region)) AS Counts, Games
FROM [Olympics].[dbo].[noc_regions$] as e
JOIN [Olympics].[dbo].[athlete_events$] as a
ON e.noc = a.noc
GROUP BY Games
ORDER BY Games

SELECT Games, COUNT(NOC) AS count_nations
FROM(SELECT DISTINCT a.NOC, Games
FROM [Olympics].[dbo].[athlete_events$] AS e
JOIN [Olympics].[dbo].[noc_regions$] AS a
ON e.NOC = a.NOC)s
GROUP BY Games
ORDER BY Games



/** Which years saw the highest and lowest number of countries participating in olympics? **/
WITH UGO AS(SELECT COUNT(DISTINCT(a.NOC)) AS count_countries,games,Year
FROM [Olympics].[dbo].[athlete_events$] as a
JOIN [Olympics].[dbo].[noc_regions$] as e
ON a.NOC = e.NOC
GROUP BY Games,Year)
SELECT DISTINCT CONCAT(first_value(games) OVER(ORDER BY count_countries DESC), ' = ', first_value(count_countries) OVER(ORDER BY count_countries DESC)) AS highest_country,
CONCAT(first_value(games) OVER(ORDER BY count_countries ASC), ' = ', first_value(count_countries) OVER(ORDER BY count_countries ASC)) AS least_country
FROM UGO


/** Which nation has participated in all of the olympic games? **/
WITH UGO AS(SELECT *, DENSE_RANK() OVER(ORDER BY count_games DESC) AS rnk
FROM(SELECT COUNT(DISTINCT(games)) AS count_games,a.NOC,region
FROM [Olympics].[dbo].[athlete_events$] as a
JOIN [Olympics].[dbo].[noc_regions$] as e
ON a.NOC = e.NOC
GROUP BY a.NOC,region)e)
SELECT count_games, NOC,region
FROM UGO
WHERE rnk = 1

WITH UGO AS (SELECT COUNT(DISTINCT(games)) AS count_games,a.NOC,region
FROM [Olympics].[dbo].[athlete_events$] as a
JOIN [Olympics].[dbo].[noc_regions$] as e
ON a.NOC = e.NOC
GROUP BY a.NOC,region),
BASE AS (SELECT *, DENSE_RANK() OVER(ORDER BY count_games DESC) AS rnk
FROM UGO)
SELECT *
FROM BASE
WHERE rnk = 1


WITH UGO AS (SELECT COUNT(DISTINCT(Games)) AS count_games
FROM [Olympics].[dbo].[athlete_events$] as a
JOIN [Olympics].[dbo].[noc_regions$] as e
ON a.NOC = e.NOC),
BASE AS (SELECT DISTINCT Games, a.NOC,region
FROM [Olympics].[dbo].[athlete_events$] as a
JOIN [Olympics].[dbo].[noc_regions$] as e
ON a.NOC = e.NOC),
BASE1 AS (SELECT NOC,region, COUNT(games) AS count_games
FROM BASE
GROUP BY NOC,region)
SELECT *
FROM BASE1
JOIN UGO 
ON UGO.count_games = BASE1.count_games


/** Identify the sport which was played in all summer olympics**/
WITH UGO AS(SELECT *, DENSE_RANK() OVER(ORDER BY count_games DESC) AS rnk
FROM(SELECT COUNT(DISTINCT(Games)) AS count_games, Sport,Season
FROM [Olympics].[dbo].[athlete_events$]
WHERE Season = 'Summer'
GROUP BY Sport, Season)e)
SELECT count_games, Sport, Season
FROM UGO
WHERE rnk = 1

WITH UGO AS (SELECT COUNT(DISTINCT(games)) AS count_games,Sport, Season
FROM [Olympics].[dbo].[athlete_events$]
GROUP BY a.NOC,region),
BASE AS (SELECT *, DENSE_RANK() OVER(ORDER BY count_games DESC) AS rnk
FROM UGO)
SELECT *
FROM BASE
WHERE rnk = 1

WITH UGO AS (SELECT COUNT(DISTINCT(Games)) AS count_games
FROM [Olympics].[dbo].[athlete_events$]
WHERE Season = 'Summer'),
BASE AS (SELECT DISTINCT Games, Sport
FROM [Olympics].[dbo].[athlete_events$]
WHERE Season = 'Summer'),
BASE1 AS (SELECT Sport, COUNT(games) AS count_games
FROM BASE
GROUP BY Sport)
SELECT *
FROM BASE1
JOIN UGO 
ON UGO.count_games = BASE1.count_games

/** Which Sport were just played only once in the olympics? **/
WITH UGO AS(SELECT *, DENSE_RANK() OVER(ORDER BY count_games ASC) AS rnk
FROM(SELECT COUNT(DISTINCT(Games)) AS count_games,Sport
FROM [Olympics].[dbo].[athlete_events$]
GROUP BY Sport)e)
SELECT Sport, count_games
FROM UGO
WHERE rnk = 1

WITH UGO AS (SELECT  COUNT(DISTINCT(Games)) AS count_games,Sport
FROM [Olympics].[dbo].[athlete_events$]
GROUP BY Sport),
BASE AS (SELECT *, DENSE_RANK() OVER(ORDER BY count_games ASC) AS rnk
FROM UGO)
SELECT Sport, count_games
FROM BASE
WHERE rnk = 1


WITH BASE AS (SELECT DISTINCT games, sport
FROM [Olympics].[dbo].[athlete_events$]),
BASE1 AS (SELECT Sport, COUNT(games) AS count_games
FROM BASE
GROUP BY Sport)
SELECT *
FROM BASE1
JOIN BASE
ON BASE.Sport = BASE1.Sport
WHERE count_games = 1


/** Fetch the total no of sports played in each olympic games**/
SELECT COUNT(DISTINCT(Sport)) Sport, Games
FROM [Olympics].[dbo].[athlete_events$]
GROUP BY Games
ORDER BY Games

SELECT Games, COUNT(Sport) AS Sport
FROM (SELECT DISTINCT Sport, Games
FROM [Olympics].[dbo].[athlete_events$]) e
GROUP BY Games
ORDER BY Games

WITH UGO AS (SELECT *, DENSE_RANK() OVER(ORDER BY games) AS rnk
FROM(SELECT games, COUNT(DISTINCT(sport)) AS count_sport
FROM [Olympics].[dbo].[athlete_events$]
GROUP BY Games)e)
SELECT *
FROM UGO

WITH UGO AS (SELECT games, COUNT(DISTINCT(sport)) AS count_sport
FROM [Olympics].[dbo].[athlete_events$]
GROUP BY Games),
BASE AS (SELECT *, DENSE_RANK() OVER(ORDER BY games) AS rnk
FROM UGO)
SELECT *
FROM BASE

WITH BASE AS (SELECT DISTINCT games, sport
FROM [Olympics].[dbo].[athlete_events$]),
BASE1 AS (SELECT games, COUNT(sport) AS count_sport
FROM BASE
GROUP BY games)
SELECT *
FROM BASE1
ORDER BY games


/** Fetch details of the oldest athletes to win a gold medal. **/
SELECT Name, age, Medal
FROM(SELECT *, dense_rank() over(ORDER BY Age DESC)as rnk
FROM [Olympics].[dbo].[athlete_events$]
WHERE Medal = 'Gold') e
WHERE rnk = 1


WITH ugo AS(SELECT *, DENSE_RANK() OVER(ORDER BY age DESC) AS medal_rank
FROM(SELECT Name, age, COUNT(Medal) AS medal_count,Medal
FROM [Olympics].[dbo].[athlete_events$]
WHERE medal = 'Gold'
GROUP BY Name, Age,Medal)e)
SELECT Name, age,Medal
FROM ugo
WHERE medal_rank = 1

WITH UGO AS (SELECT name,age, COUNT(Medal) AS count_medal,Medal
FROM [Olympics].[dbo].[athlete_events$]
WHERE Medal = 'Gold'
GROUP BY Name,Age,Medal),
BASE AS (SELECT *, DENSE_RANK() OVER(ORDER BY age DESC) AS rnk
FROM UGO)
SELECT *
FROM BASE
WHERE rnk = 1


/** Fetch details of the oldest athletes to win a medal. **/
SELECT *
FROM(SELECT *, dense_rank() over(ORDER BY Age DESC)as rnk
FROM [Olympics].[dbo].[athlete_events$]
WHERE Medal IN ('Gold', 'Silver', 'Bronze')) e
WHERE rnk = 1

WITH ugo AS(SELECT *, DENSE_RANK() OVER( ORDER BY age DESC) AS medal_rank
FROM(SELECT Name, age,medal, COUNT(Medal) AS medal_count
FROM [Olympics].[dbo].[athlete_events$]
WHERE medal IN ('Gold','Silver', 'Bronze')
GROUP BY Name,age, Medal)e)
SELECT Name, age, medal, medal_count
FROM ugo
WHERE medal_rank = 1

WITH ugo AS(SELECT Name, age,medal, COUNT(Medal) AS medal_count
FROM [Olympics].[dbo].[athlete_events$]
WHERE medal IN ('Gold','Silver', 'Bronze')
GROUP BY Name,age, Medal),
BASE AS (SELECT *, DENSE_RANK() OVER(ORDER BY age DESC) AS medal_rank
FROM ugo)
SELECT Name, age, medal, medal_count
FROM BASE
WHERE medal_rank = 1

/** Fetch details of the top two oldest athletes to win a medal. **/
SELECT *
FROM(SELECT *, dense_rank() over(ORDER BY Age DESC)as rnk
FROM [Olympics].[dbo].[athlete_events$]
WHERE Medal IN ('Gold', 'Silver', 'Bronze')) e
WHERE rnk  IN (1, 2)

SELECT *, DENSE_RANK() OVER(ORDER BY age DESC) AS rnk
FROM(SELECT Name, Team, COUNT(Medal) AS count_medals, Age, Medal
FROM [Olympics].[dbo].[athlete_events$]
WHERE medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY Name, team, Age,Medal
HAVING Age >= '72')e

WITH ugo AS(SELECT *, DENSE_RANK() OVER( ORDER BY age DESC) AS medal_rank
FROM(SELECT Name, age,medal, COUNT(Medal) AS medal_count
FROM [Olympics].[dbo].[athlete_events$]
WHERE medal IN ('Gold','Silver', 'Bronze')
GROUP BY Name,age, Medal) e )
SELECT Name, age, medal, medal_count
FROM ugo
WHERE medal_rank <=2

/** Find the Ratio of male and female athletes participated in all olympic games **/
WITH UGO AS(SELECT COUNT(sex) AS female
FROM [Olympics].[dbo].[athlete_events$]
WHERE Sex ='F'),
BASE AS (SELECT COUNT(sex) AS male
FROM [Olympics].[dbo].[athlete_events$]
WHERE Sex ='M')
SELECT DISTINCT CONCAT('1:',CAST(ROUND(MALE/CAST(FEMALE AS decimal(9,4)),1)AS float))AS Ratio
FROM UGO,BASE

/** Fetch the top 5 athletes who have won the most gold medals. **/
WITH ugo AS(SELECT *, DENSE_RANK() OVER(ORDER BY medal_count DESC) AS medal_rank
FROM(SELECT Name, team,medal, COUNT(Medal) AS medal_count
FROM [Olympics].[dbo].[athlete_events$]
WHERE medal = 'Gold'
GROUP BY Name, team, Medal)e)
SELECT Name, team,medal, medal_count
FROM ugo
WHERE medal_rank <=5
ORDER BY medal_count DESC

WITH ugo AS(SELECT Name, team,medal, COUNT(Medal) AS medal_count
FROM [Olympics].[dbo].[athlete_events$]
WHERE medal = 'Gold'
GROUP BY Name, team, Medal),
BASE AS (SELECT *, DENSE_RANK() OVER(ORDER BY medal_count DESC) AS medal_rank
FROM ugo)
SELECT Name,Team,Medal,medal_count
FROM BASE
WHERE medal_rank <=5
ORDER BY medal_count DESC

/** Fetch the top 5 athletes who have won the most medals (gold/silver/bronze). **/
WITH ugo AS(SELECT *, DENSE_RANK() OVER(ORDER BY medal_count DESC) AS medal_rank
FROM(SELECT Name,team, COUNT(Medal) AS medal_count
FROM [Olympics].[dbo].[athlete_events$]
WHERE medal IN ('Gold', 'Silver','Bronze')
GROUP BY Name ,Team)e)
SELECT *
FROM ugo
WHERE medal_rank <= 5
ORDER BY medal_rank 

WITH ugo AS(SELECT *, DENSE_RANK() OVER(ORDER BY medal_count DESC) AS medal_rank
FROM(SELECT Name,team, COUNT(Medal) AS medal_count
FROM [Olympics].[dbo].[athlete_events$]
WHERE medal != 'NA'
GROUP BY Name ,Team)e)
SELECT *
FROM ugo
WHERE medal_rank <= 5
ORDER BY medal_rank 


/** Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won. **/
WITH ugo AS(SELECT *, DENSE_RANK() OVER(ORDER BY medal_count DESC) AS medal_rank
FROM(SELECT DISTINCT e.NOC, COUNT(Medal) AS medal_count
FROM [Olympics].[dbo].[athlete_events$] AS a
JOIN [Olympics].[dbo].[noc_regions$] AS e
ON a.NOC = e.NOC
WHERE medal != 'NA'
GROUP BY e.NOC)e)
SELECT *
FROM ugo
WHERE medal_rank <= 5

WITH ugo AS(SELECT *, DENSE_RANK() OVER(ORDER BY medal_count DESC) AS medal_rank
FROM(SELECT DISTINCT NOC, COUNT(Medal) AS medal_count
FROM [Olympics].[dbo].[athlete_events$]
WHERE medal IN ('Gold','Silver', 'Bronze')
GROUP BY NOC)e)
SELECT *
FROM ugo
WHERE medal_rank <= 5

/** List down total gold, silver and bronze medals won by each country. **/
WITH UGO AS(SELECT *, DENSE_RANK() OVER(ORDER BY medal_count DESC) AS medal_rank
FROM(SELECT DISTINCT NOC,medal, COUNT(Medal) AS medal_count
FROM [Olympics].[dbo].[athlete_events$]
WHERE Medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY NOC,Medal)e)
SELECT NOC,medal, medal_count
FROM UGO
ORDER BY medal_count DESC


/** List down total medals won by each country. **/
SELECT *, DENSE_RANK() OVER(ORDER BY medal_count DESC) AS medal_rank
FROM(SELECT DISTINCT NOC, COUNT(Medal) AS medal_count
FROM [Olympics].[dbo].[athlete_events$]
WHERE medal IN ('Gold', 'Silver','Bronze')
GROUP BY NOC) e 

WITH UGO AS(SELECT *, DENSE_RANK() OVER(ORDER BY medal_count DESC) AS medal_rank
FROM(SELECT DISTINCT NOC, COUNT(Medal) AS medal_count
FROM [Olympics].[dbo].[athlete_events$]
WHERE Medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY NOC)e)
SELECT *
FROM UGO


/** List down total gold, silver and bronze medals won by each country corresponding to each olympic games. **/
SELECT *, DENSE_RANK() OVER(ORDER BY games, NOC, medal_count) AS medal_rank
FROM(SELECT DISTINCT e.NOC,  games,medal, COUNT(Medal) AS medal_count
FROM [Olympics].[dbo].[athlete_events$] AS a
JOIN [Olympics].[dbo].[noc_regions$] AS e
ON a.NOC = e.NOC
WHERE medal IN ('Gold', 'Silver','Bronze')
GROUP BY e.NOC,medal,games)e 
ORDER BY NOC DESC, Games DESC

WITH UGO AS(SELECT *, DENSE_RANK() OVER(ORDER BY medal_count DESC) AS medal_rank
FROM(SELECT DISTINCT e.NOC,region,medal,games,COUNT(Medal) AS medal_count
FROM [Olympics].[dbo].[athlete_events$] AS a
JOIN [Olympics].[dbo].[noc_regions$] AS e
ON a.NOC = e.NOC
WHERE Medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY e.NOC,region,Medal,Games)e)
SELECT NOC,region,medal,Games, medal_count
FROM UGO
ORDER BY NOC DESC, region DESC, Games DESC

/** In which Sport/event, India has won highest medals.**/
WITH UGO AS(SELECT *, DENSE_RANK() OVER(ORDER BY medal_count DESC) AS medal_rank
FROM(SELECT DISTINCT Sport,Event, COUNT(Medal) AS medal_count,Team
FROM [Olympics].[dbo].[athlete_events$]
WHERE Medal IN ('Gold', 'Silver', 'Bronze')
GROUP BY Sport, Event,Team
HAVING Team = 'India')e)
SELECT *
FROM UGO
WHERE medal_rank = 1

WITH UGO AS(SELECT *, DENSE_RANK() OVER(PARTITION BY medal_count ORDER BY medal_count DESC) AS medal_rank
FROM(SELECT DISTINCT Team, Sport,Event, COUNT(Medal) AS medal_count
FROM [Olympics].[dbo].[athlete_events$]
WHERE Medal IN ('Gold', 'Silver', 'Bronze') AND Team = 'India'
GROUP BY Team, Sport,Event)r)
SELECT *
FROM UGO
ORDER BY medal_count DESC

/** Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.**/
WITH UGO AS(SELECT *, DENSE_RANK() OVER(ORDER BY medal_count DESC) AS medal_rank
FROM(SELECT DISTINCT Sport,Event,Games ,COUNT(Medal) AS medal_count,Team
FROM [Olympics].[dbo].[athlete_events$]
WHERE Medal IN ('Gold', 'Silver', 'Bronze') AND Sport = 'Hockey' AND Team = 'India'
GROUP BY Sport, Event,Team,Games)e)
SELECT *
FROM UGO
ORDER BY Games

WITH UGO AS (SELECT DISTINCT Sport,Event,Games ,COUNT(Medal) AS medal_count,Team
FROM [Olympics].[dbo].[athlete_events$]
WHERE Medal IN ('Gold', 'Silver', 'Bronze') AND Sport = 'Hockey' AND Team = 'India'
GROUP BY Sport, Event,Team,Games),
BASE AS (SELECT *, DENSE_RANK() OVER(ORDER BY medal_count DESC) AS medal_rank
FROM UGO)
SELECT *
FROM BASE
ORDER BY Games

SELECT Sport,Event,Games,Team,COUNT(Medal) AS medal_count
FROM (SELECT Medal,Sport,Event,Games,Team
FROM [Olympics].[dbo].[athlete_events$]
WHERE Medal IN ('Gold', 'Silver', 'Bronze') AND Sport = 'Hockey' AND Team = 'India')e
GROUP BY Sport, Event,Team,Games
ORDER BY Games

SELECT Sport,Event,Games ,COUNT(Medal) AS medal_count,Team
FROM [Olympics].[dbo].[athlete_events$]
WHERE Medal IN ('Gold', 'Silver', 'Bronze') AND Sport = 'Hockey' AND Team = 'India'
GROUP BY Sport, Event,Team,Games
ORDER BY Games


















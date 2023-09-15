CREATE DATABASE imdb;

USE imdb;

## (Segment-1)
## Q-1: -	Find the total number of rows in each table of the schema?

SELECT table_name,
       table_rows
FROM   INFORMATION_SCHEMA.TABLES
WHERE  TABLE_SCHEMA = 'imdb';

## Q-2: -  Identify which columns in the movie table have null values?
describe movies;
describe genre;
SELECT 'ID',
       COUNT(*) AS Null_Count
FROM   movies
WHERE  ID IS NULL
UNION
SELECT 'Title',
       COUNT(*) AS Null_Count
FROM   movies
WHERE  TITLE IS NULL
UNION
SELECT 'Year',
       COUNT(*) AS Null_Count
FROM   movies
WHERE  YEAR IS NULL
UNION
SELECT 'Date Published',
       COUNT(*) AS Null_Count
FROM   movies
WHERE  DATE_PUBLISHED IS NULL
UNION
SELECT 'movies',
       COUNT(*) AS Null_Count
FROM   movies
WHERE  DURATION IS NULL
UNION
SELECT 'Country',
       COUNT(*) AS Null_Count
FROM   movies
WHERE  COUNTRY IS NULL
UNION
SELECT 'WorldWide_Gross',
       COUNT(*) AS Null_Count
FROM   movies
WHERE  WORLWIDE_GROSS_INCOME IS NULL
UNION
SELECT 'Languages',
       COUNT(*) AS Null_Count
FROM   movies
WHERE  LANGUAGES IS NULL
UNION
SELECT 'Prod Company',
       COUNT(*) AS Null_Count
FROM   movies
WHERE  PRODUCTION_COMPANY IS NULL; 

## (Segment-2)
## Q-1:-	Determine the total number of movies released each year and analyse the month-wise trend?

SELECT Year,
       COUNT(TITLE) AS 'number_of_movies'
FROM   movies
GROUP  BY YEAR;
SELECT MONTH(DATE_PUBLISHED) AS'month_num',
       COUNT(TITLE) AS 'number_of_movies'
FROM   movies
GROUP  BY MONTH(DATE_PUBLISHED)
ORDER  BY COUNT(TITLE) DESC; 

## Q-2:-	Calculate the number of movies produced in the USA or India in the year 2019?

SELECT year,
       COUNT(TITLE) AS number_of_movies
FROM   movies
WHERE  YEAR = 2019
       AND ( COUNTRY LIKE '%USA%'
              OR COUNTRY LIKE '%India%' )
GROUP  BY YEAR;

##(Segment-3)
## Q-1:-	Retrieve the unique list of genres present in the dataset?

SELECT DISTINCT genre
FROM   genre;

## Q-2:	Identify the genre with the highest number of movies produced overall?
SELECT g.genre,
       COUNT(m.TITLE) AS no_of_movies
FROM   movies m
       INNER JOIN genre g
               ON g.MOVIE_ID = m.ID
GROUP  BY g.genre
ORDER  BY COUNT(m.TITLE) DESC
LIMIT  1; 

## Q-3:-	Determine the count of movies that belong to only one genre?
WITH AGG
     AS (SELECT m.ID,
                Count(g.genre) AS genre
         FROM   movies m
                INNER JOIN genre g
                        ON g.MOVIE_ID = m.ID
         GROUP  BY ID
         HAVING Count(g.genre) = 1)
SELECT Count(ID) AS movie_count
FROM   AGG; 

## Q-4:-	Calculate the average duration of movies in each genre?

SELECT g.genre,
       ROUND(AVG(m.DURATION), 2) AS avg_duration
FROM   movies m
       INNER JOIN genre g
               ON g.MOVIE_ID = m.ID
GROUP  BY g.genre
ORDER  BY ROUND(AVG(m.DURATION), 2) DESC; 

## Q-5:-	Find the rank of the 'thriller' genre among all genres in terms of the number of movies produced?

WITH GENRE_RANKS
     AS (SELECT genre,
                Count(MOVIE_ID) AS 'movie_count',
                RANK()
				OVER(
				ORDER BY Count(MOVIE_ID) DESC) AS genre_rank
         FROM   genre
         GROUP  BY genre)
SELECT *
FROM   GENRE_RANKS
WHERE  GENRE = 'thriller'; 

##(Segment-4)

## Q-1:-	Retrieve the minimum and maximum values in each column of the ratings table (except movie_id)?

SELECT ROUND(MIN(AVG_RATING), 1) AS min_avg_rating,
       ROUND(MAX(AVG_RATING), 1) AS max_avg_rating,
       MIN(TOTAL_VOTES) AS min_total_votes,
       MAX(TOTAL_VOTES)AS max_total_votes,
       MIN(MEDIAN_RATING)AS min_median_rating,
       MAX(MEDIAN_RATING)AS max_median_rating
FROM   ratings; 

## Q-2:-	Identify the top 10 movies based on average rating?

SELECT     M.title,
           R.avg_rating,
           RANK() OVER(ORDER BY R.AVG_RATING DESC) AS movie_rank
FROM       ratings R
INNER JOIN movies M
ON         R.MOVIE_ID=M.ID
ORDER BY   R.AVG_RATING DESC
LIMIT      10;

## Q-3:-	Summarise the ratings table based on movie counts by median ratings?

SELECT median_rating,
       COUNT(MOVIE_ID) AS movie_count
FROM   ratings
GROUP  BY MEDIAN_RATING
ORDER  BY COUNT(MOVIE_ID) DESC; 

## Q-4:-	Identify the production house that has produced the most number of hit movies (average rating > 8)?

WITH AGG
AS
  (
             SELECT     M.production_company,
                        M.ID,
                        R.AVG_RATING
             FROM       movies M
             INNER JOIN ratings R
             ON         M.ID=R.MOVIE_ID
             WHERE      AVG_RATING>8
             ORDER BY   R.AVG_RATING DESC )
  SELECT   production_company,
           COUNT(ID) AS movie_count,
           RANK() OVER (ORDER BY COUNT(ID) DESC) AS prod_company_rank
  FROM     AGG
  WHERE    PRODUCTION_COMPANY IS NOT NULL
  GROUP BY PRODUCTION_COMPANY
  ORDER BY MOVIE_COUNT DESC
  LIMIT    2;
  
  ## Q-5:-	Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes?
  
  WITH AGG
     AS (SELECT g.genre,
                r.MOVIE_ID,
                m.DATE_PUBLISHED,
                m.COUNTRY
         FROM   ratings r
                INNER JOIN genre g
                        ON r.MOVIE_ID = g.MOVIE_ID
                INNER JOIN movies m
                        ON g.MOVIE_ID = m.ID
         WHERE  r.TOTAL_VOTES > 1000
                AND Month(DATE_PUBLISHED) = 3
                AND Year(DATE_PUBLISHED) = 2017
                AND m.COUNTRY IN ( 'USA' ))
SELECT genre,
       Count(MOVIE_ID) AS movie_count
FROM   AGG
GROUP  BY genre
ORDER  BY Count(MOVIE_ID) DESC; 

## Q-6:-	Retrieve movies of each genre starting with the word 'The' and having an average rating > 8?

SELECT m.title,
       r.avg_rating,
       g.genre
FROM   genre g
       INNER JOIN ratings r
               ON g.MOVIE_ID = r.MOVIE_ID
       INNER JOIN movies m
               ON g.MOVIE_ID = m.ID
WHERE  r.AVG_RATING > 8
       AND LOWER(m.TITLE) LIKE 'the%'
ORDER  BY r.AVG_RATING DESC; 

##(Segment-5)

## Q-1:-	Identify the columns in the names table that have null values?

SELECT COUNT(*) - COUNT(ID) AS id_nulls,
       COUNT(*) - COUNT(NAME)AS name_nulls,
       COUNT(*) - COUNT(HEIGHT) AS height_nulls,
       COUNT(*) - COUNT(DATE_OF_BIRTH)AS date_of_birth_nulls,
       COUNT(*) - COUNT(KNOWN_FOR_MOVIES)AS known_for_movies_nulls
FROM   names; 

## Q-2:-	Determine the top three directors in the top three genres with movies having an average rating > 8?

WITH TOP_3_GENRE
AS
  (
             SELECT     genre
             FROM       ratings R
             INNER JOIN movies M
             ON         R.MOVIE_ID=M.ID
             INNER JOIN genre
             USING      (MOVIE_ID)
             WHERE      AVG_RATING > 8
             GROUP BY   genre
             ORDER BY   COUNT(genre) DESC
             LIMIT      3 )
  SELECT     NAME        AS director_name,
             COUNT(NAME) AS movie_count
  FROM       ratings R
  INNER JOIN movies M
  ON         R.MOVIE_ID=M.ID
  INNER JOIN genre
  USING      (MOVIE_ID)
  INNER JOIN director_mapping D
  USING      (MOVIE_ID)
  INNER JOIN NAMES N
  ON         D.NAME_ID=N.ID
  WHERE      genre IN
             (
                    SELECT *
                    FROM   TOP_3_GENRE)
  AND        AVG_RATING>8
  GROUP BY   NAME
  ORDER BY   COUNT(NAME) DESC
  LIMIT      3 ;
  
  ## Q-3:-	Find the top two actors whose movies have a median rating >= 8?
  
  SELECT NAME        AS actor_name,
       COUNT(NAME) AS movie_count
FROM   NAME N
       INNER JOIN ROLE_MAPPING RO
               ON N.ID = RO.NAME_ID
       INNER JOIN RATINGS RA
               ON RO.MOVIE_ID = RA.MOVIE_ID
WHERE  MEDIAN_RATING >= 8
       AND CATEGORY = 'actor'
GROUP  BY names
ORDER  BY COUNT(NAME) DESC
LIMIT  2; 

  ## Q-4:-	Identify the top three production houses based on the number of votes received by their movies?
  
  SELECT     production_company,
           SUM(TOTAL_VOTES) AS vote_count,
           DENSE_RANK() OVER(ORDER BY SUM(TOTAL_VOTES) DESC) AS prod_comp_rank
FROM       movies M
INNER JOIN ratings RA
ON         M.ID=RA.MOVIE_ID
GROUP BY   PRODUCTION_COMPANY
LIMIT      3;

  ## Q-5:-	Rank actors based on their average ratings in Indian movies released in India?
  
  WITH ACTORS
AS
  (
             SELECT     NAME AS actor_name ,
                        SUM(TOTAL_VOTES)   AS total_votes,
                        COUNT(NAME)  AS movie_count,
                        ROUND(SUM(AVG_RATING * TOTAL_VOTES) / SUM(TOTAL_VOTES), 2) AS actor_avg_rating
             FROM       names N
             INNER JOIN role_mapping RO
             ON         N.ID = RO.NAME_ID
             INNER JOIN movies M
             ON         RO.MOVIE_ID = M.ID
             INNER JOIN ratings RA
             ON         M.ID = RA.MOVIE_ID
             WHERE      COUNTRY REGEXP 'india'
             AND        CATEGORY = 'actor'
             GROUP BY   NAME
             HAVING     MOVIE_COUNT >= 5)
  SELECT   *,
           DENSE_RANK() OVER ( ORDER BY ACTOR_AVG_RATING DESC, TOTAL_VOTES DESC) AS actor_rank
  FROM     ACTORS;
  
    ## Q-6:-	Identify the top five actresses in Hindi movies released in India based on their average ratings?
    
    ##(Segment-6)
    
	## Q-1:-	Classify thriller movies based on average ratings into different categories?

SELECT TITLE AS movie,
       AVG_RATING,
       CASE
         WHEN AVG_RATING > 8 THEN 'Superhit movies'
         WHEN AVG_RATING BETWEEN 7 AND 8 THEN 'Hit movies'
         WHEN AVG_RATING BETWEEN 5 AND 7 THEN 'One-time-watch movies'
         WHEN AVG_RATING < 5 THEN 'Flop movies'
       END   AS 'avg_rating_category'
FROM   GENRE g
       INNER JOIN ratings ra USING(MOVIE_ID)
       INNER JOIN movies m
               ON ra.MOVIE_ID = m.ID
WHERE  genre = 'thriller'; 

## Q-2:-	Analyse the genre-wise running total and moving average of the average movie duration?

WITH genre
     AS (SELECT genre,
                ROUND(AVG(DURATION), 2) AS avg_duration,
                SUM(AVG(DURATION))
                  OVER (
                    ORDER BY genre ROWS UNBOUNDED PRECEDING) AS
                running_total_duration,
                AVG(AVG(DURATION))
                  OVER (
                    ORDER BY GENRE ROWS UNBOUNDED PRECEDING) AS
                moving_avg_duration
         FROM   movies m
                INNER JOIN genre g
                        ON m.ID = g.MOVIE_ID
         GROUP  BY genre)
SELECT genre,
       avg_duration,
       ROUND(RUNNING_TOTAL_DURATION, 2) AS running_total_duration,
       ROUND(MOVING_AVG_DURATION, 2)  AS moving_avg_duration
FROM   genre;

## Q-3:-	Identify the five highest-grossing movies of each year that belong to the top three genres?

WITH TOP_3_GENRE
AS
  (
           SELECT   genre
           FROM     genre
           GROUP BY genre
           ORDER BY COUNT(genre) DESC
           LIMIT    3 ),
  TOP_MOVIES
AS
  (
             SELECT     genre,
                        year,
                        TITLE AS movie_name,
                        CAST(REPLACE(IFNULL(WORLWIDE_GROSS_INCOME,0),'$ ','') AS DECIMAL(10)) AS worldwide_gross_income_$,
                        ROW_NUMBER() OVER (PARTITION BY YEAR ORDER BY CAST(REPLACE(IFNULL(WORLWIDE_GROSS_INCOME,0),'$ ','') AS DECIMAL(10)) DESC) AS movie_rank
             FROM       movies M
             INNER JOIN genre G
             ON         M.ID = G.MOVIE_ID
             WHERE      genre IN
                        (
							SELECT *
						FROM   TOP_3_GENRE) )
  SELECT *
  FROM   TOP_MOVIES
  WHERE  MOVIE_RANK<=5;
  
  ## Q-4:-	Determine the top two production houses that have produced the highest number of hits among multilingual movies?
  
  SELECT     production_company,
           COUNT(PRODUCTION_COMPANY)AS movie_count ,
           DENSE_RANK() OVER(ORDER BY COUNT(PRODUCTION_COMPANY) DESC) AS prod_comp_rank
FROM       movies M
INNER JOIN ratings RA
ON         M.ID=RA.MOVIE_ID
WHERE      MEDIAN_RATING>=8
AND        LANGUAGES REGEXP ','
GROUP BY   PRODUCTION_COMPANY
LIMIT      2;
## Q-5:-	Identify the top three actresses based on the number of Super Hit movies (average rating > 8) in the drama genre?

SELECT     NAME AS actress_name,
           SUM(TOTAL_VOTES) AS total_votes,
           COUNT(NAME)   AS movie_count,
           ROUND(SUM(AVG_RATING*TOTAL_VOTES)/SUM(TOTAL_VOTES),2) AS actress_avg_rating,
           ROW_NUMBER() OVER (ORDER BY COUNT(NAME) DESC)         AS actress_rank
FROM       genre G
INNER JOIN movies M
ON         G.MOVIE_ID=M.ID
INNER JOIN ratings RA
USING     (MOVIE_ID)
INNER JOIN role_mapping RO
USING      (MOVIE_ID)
INNER JOIN NAMES N
ON         RO.NAME_ID=N.ID
WHERE      AVG_RATING >8
AND        genre = 'drama'
AND        CATEGORY = 'actress'
GROUP BY   NAME
LIMIT      3;



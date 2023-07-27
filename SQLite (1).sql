CREATE TABLE applestore_description_combined AS

SELECT * FROM appleStore_description1

UNION ALL

SELECT * FROM appleStore_description2

UNION ALL

SELECT * FROM appleStore_description3

UNION ALL

SELECT * FROM appleStore_description4


**EXPLORATION DATA ANALYSIS**

--check the number of unique apps in both tablesAppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM applestore_description_combined

--check for any missing values in key fields

SELECT COUNT(*) AS MissingValues
FROM AppleStore
WHERE track_name IS null OR user_rating IS null OR prime_genre IS NULL

SELECT COUNT(*) AS MissingValues
FROM applestore_description_combined
WHERE app_desc IS null 

--Find out the number of apps per genre

SELECT prime_genre, COUNT(*) as NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC

--Get an overview of the apps' ratings 

SELECT min(user_rating) AS MinRating,
       max(user_rating) as MaxRating,
       avg(user_rating) as AvgRating
FROM AppleStore

**Data Analysis**

--Determine whether paid apps have higher rating than free apps
SELECT CASE
           WHEN price > 0 Then 'Paid'
           else 'FREE'
       END AS App_Type,
       avg(user_rating) AS Avg_Rating
FROM AppleStore 
GROUP BY App_Type

--Check if apps with more supported languages have higher ratings

SELECT CASE
            WHEN lang_num < 10 Then '<10 languages'
            When lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
            ELSE '>30 languages'
       END AS language_bucket,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY language_bucket
ORDER BY Avg_Rating DESC

--Check gneres with low ratings 

SELECT prime_genre,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
Group BY prime_genre
order by Avg_Rating ASC
LIMIT 10

--Check if there is correlation between the length of the app description and the user rating 

SELECT CASE 
           WHEN length(b.app_desc) <500 then 'Short'
           when length(b.app_desc) BETWEEN 500 and 1000 then 'Medium'
           else 'long'
        end as description_length_bucket,
        avg(a.user_rating) AS average_rating

FROM
    AppleStore as A
JOIN 
    applestore_description_combined AS b
on 
     a.id = b.id
     
GROUP BY description_length_bucket
order by average_rating DESC

--Check the top rated apps for each genreAppleStore

SELECT 
   prime_genre,
   track_name,
   user_rating
 from(
     SELECT 
   prime_genre,
   track_name,
   user_rating,
  RANK() OVER(PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
   FROM
   appleStore
   ) AS a 
where 
a.rank = 1

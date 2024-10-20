SELECT * 
FROM WHOAIRQUALITY..concentration_mean

SELECT TOP 20 * 
FROM WHOAIRQUALITY..temporal_coverage
WHERE year is not null
ORDER BY Population




--Total WHO member and non-member state
SELECT 
  SUM(CASE WHEN who_ms = 1 THEN 1 ELSE 0 END) AS Total_MemberState,
  SUM(CASE WHEN who_ms = 0 THEN 1 ELSE 0 END) AS Total_NonMemberState
FROM WHOAIRQUALITY..concentration_mean;




----Display WHO Region
--SELECT who_region, 
--	AVG(pm10_concentration) as avg_pm10_Con, 
--	AVG(pm25_concentration) as avg_pm25_Con, 
--	AVG(no2_concentration) as avg_no2_Con
--FROM WHOAIRQUALITY..concentration_mean
--WHERE who_region is not NULL
--GROUP BY who_region
--ORDER BY who_region





--Display max value three column(pm10, pm25, no2) of concentration
--By Region and year
SELECT who_region, 
	year,
	avg(pm10_concentration)as pm10Con_avg, 
	avg(pm25_concentration)as pm25Con_avg, 
	avg(no2_concentration)as no2_avg, 
	GREATEST(avg(pm10_concentration), avg(pm25_concentration), avg(no2_concentration)) as MaxValue_concentration
FROM WHOAIRQUALITY..concentration_mean
WHERE who_region is not NULL
	AND year is not NULL
GROUP BY who_region, year
ORDER BY who_region, year


--Display max value three column(pm10, pm25, no2) of temporal coverage
-- By Region and year
SELECT who_region, 
	year,
	avg(pm10_tempcov)as pm10temp_avg, 
	avg(pm25_tempcov)as pm25temp_avg, 
	avg(no2_tempcov)as no2temp_avg, 
	GREATEST(avg(pm10_tempcov), avg(pm25_tempcov), avg(no2_tempcov)) 
	as MaxValue_tempcov
FROM WHOAIRQUALITY..temporal_coverage
WHERE who_region is not NULL
	AND year is not NULL
GROUP BY who_region, year
ORDER BY who_region, year


--Display which of three column as max value mean concentration
SELECT who_region, country_name, city, year, pm10_concentration, pm25_concentration, 
	no2_concentration, 
	GREATEST(pm10_concentration, pm25_concentration, no2_concentration) as Max_tempCov,
	CASE
		WHEN pm10_concentration = GREATEST(pm10_concentration, pm25_concentration, no2_concentration) THEN 'pm10'
		WHEN pm25_concentration = GREATEST(pm10_concentration, pm25_concentration, no2_concentration) THEN 'pm25'
		WHEN no2_concentration = GREATEST(pm10_concentration, pm25_concentration, no2_concentration) THEN 'no2'
	END AS Max_AirQuality
FROM WHOAIRQUALITY..concentration_mean



-- Concentration mean vs temporal coverage
-- By WHO Region and by year
SELECT 
    con.who_region,
    con.year,
    
    -- Average concentration values
    AVG(con.pm10_concentration) AS avg_pm10_concentration,
    AVG(con.pm25_concentration) AS avg_pm25_concentration,
    AVG(con.no2_concentration) AS avg_no2_concentration,
    
    -- Max concentration
    GREATEST(
        AVG(con.pm10_concentration), 
        AVG(con.pm25_concentration), 
        AVG(con.no2_concentration)
    ) AS MaxValue_concentration,
    
    -- Identify the air quality component with the max concentration
    CASE
        WHEN AVG(con.pm10_concentration) = GREATEST(
            AVG(con.pm10_concentration), 
            AVG(con.pm25_concentration), 
            AVG(con.no2_concentration)
        ) THEN 'pm10'
        WHEN AVG(con.pm25_concentration) = GREATEST(
            AVG(con.pm10_concentration), 
            AVG(con.pm25_concentration), 
            AVG(con.no2_concentration)
        ) THEN 'pm25'
        WHEN AVG(con.no2_concentration) = GREATEST(
            AVG(con.pm10_concentration), 
            AVG(con.pm25_concentration), 
            AVG(con.no2_concentration)
        ) THEN 'no2'
    END AS AirQuality_con,

    -- Max temporal coverage
    GREATEST(
        AVG(temp.pm10_tempcov), 
        AVG(temp.pm25_tempcov), 
        AVG(temp.no2_tempcov)
    ) AS MaxValue_tempcov,

    -- Identify the air quality component with the max temporal coverage
    CASE
        WHEN AVG(temp.pm10_tempcov) = GREATEST(
            AVG(temp.pm10_tempcov), 
            AVG(temp.pm25_tempcov), 
            AVG(temp.no2_tempcov)
        ) THEN 'pm10'
        WHEN AVG(temp.pm25_tempcov) = GREATEST(
            AVG(temp.pm10_tempcov), 
            AVG(temp.pm25_tempcov), 
            AVG(temp.no2_tempcov)
        ) THEN 'pm25'
        WHEN AVG(temp.no2_tempcov) = GREATEST(
            AVG(temp.pm10_tempcov), 
            AVG(temp.pm25_tempcov), 
            AVG(temp.no2_tempcov)
        ) THEN 'no2'
    END AS AirQuality_temporalCov
FROM WHOAIRQUALITY..concentration_mean con
JOIN WHOAIRQUALITY..temporal_coverage temp
    ON con.city = temp.city
    AND con.year = temp.year
WHERE con.who_region IS NOT NULL
    AND con.year IS NOT NULL
GROUP BY con.who_region, con.year
ORDER BY con.who_region, con.year






--Display Air Quality Concentration Category 
SELECT 
  who_region, 
  country_name, 
  city,
  year,
  pm10_concentration, 
  pm25_concentration, 
  no2_concentration, 
  Max_tempCov,
  Max_AirQuality,
  
  CASE 
    -- pm10 conditions
    WHEN Max_AirQuality = 'pm10' AND Max_tempCov >= 0 AND Max_tempCov < 20.1 THEN 'Good'
    WHEN Max_AirQuality = 'pm10' AND Max_tempCov >= 20.1 AND Max_tempCov < 40.1 THEN 'Moderate'
    WHEN Max_AirQuality = 'pm10' AND Max_tempCov >= 40.1 AND Max_tempCov < 90.1 THEN 'Unhealthy'
    WHEN Max_AirQuality = 'pm10' AND Max_tempCov >= 90.1 AND Max_tempCov <= 120 THEN 'Very Unhealthy'
    WHEN Max_AirQuality = 'pm10' AND Max_tempCov > 120 THEN 'Hazardous'

    -- pm25 conditions
    WHEN Max_AirQuality = 'pm25' AND Max_tempCov >= 0 AND Max_tempCov < 5.1 THEN 'Good'
    WHEN Max_AirQuality = 'pm25' AND Max_tempCov >= 5.1 AND Max_tempCov < 10.1 THEN 'Moderate'
    WHEN Max_AirQuality = 'pm25' AND Max_tempCov >= 10.1 AND Max_tempCov < 25.1 THEN 'Unhealthy'
    WHEN Max_AirQuality = 'pm25' AND Max_tempCov >= 25.1 AND Max_tempCov <= 35 THEN 'Very Unhealthy'
    WHEN Max_AirQuality = 'pm25' AND Max_tempCov > 35 THEN 'Hazardous'

    -- no2 conditions
    WHEN Max_AirQuality = 'no2' AND Max_tempCov >= 0 AND Max_tempCov < 40.1 THEN 'Good'
    WHEN Max_AirQuality = 'no2' AND Max_tempCov >= 40.1 AND Max_tempCov < 100.1 THEN 'Moderate'
    WHEN Max_AirQuality = 'no2' AND Max_tempCov >= 100.1 AND Max_tempCov <= 300 THEN 'Unhealthy'
    WHEN Max_AirQuality = 'no2' AND Max_tempCov > 300 THEN 'Hazardous'
  END AS AirQualityCon_Category

FROM (
  SELECT 
    who_region, 
    country_name, 
    city,
	year,
    pm10_concentration, 
    pm25_concentration, 
    no2_concentration, 
    GREATEST(pm10_concentration, pm25_concentration, no2_concentration) AS Max_tempCov,
    
    CASE
      WHEN pm10_concentration = GREATEST(pm10_concentration, pm25_concentration, no2_concentration) THEN 'pm10'
      WHEN pm25_concentration = GREATEST(pm10_concentration, pm25_concentration, no2_concentration) THEN 'pm25'
      WHEN no2_concentration = GREATEST(pm10_concentration, pm25_concentration, no2_concentration) THEN 'no2'
    END AS Max_AirQuality
  FROM WHOAIRQUALITY..concentration_mean
) AS Subquery


-- Displaying temporal coverage by year with average values
SELECT 
  year, 
  AVG(pm10_tempcov) AS pm10_tempcov, 
  AVG(pm25_tempcov) AS pm25_tempcov, 
  AVG(no2_tempcov) AS no2_tempcov,
  -- Get the maximum temporal coverage among the three pollutants
  GREATEST(AVG(pm10_tempcov), AVG(pm25_tempcov), AVG(no2_tempcov)) AS Max_tempcov,
  -- Display the pollutant with the maximum temporal coverage
  CASE
    WHEN AVG(pm10_tempcov) = GREATEST(AVG(pm10_tempcov), AVG(pm25_tempcov), AVG(no2_tempcov)) THEN 'pm10_tempcov'
    WHEN AVG(pm25_tempcov) = GREATEST(AVG(pm10_tempcov), AVG(pm25_tempcov), AVG(no2_tempcov)) THEN 'pm25_tempcov'
    WHEN AVG(no2_tempcov) = GREATEST(AVG(pm10_tempcov), AVG(pm25_tempcov), AVG(no2_tempcov)) THEN 'no2_tempcov'
  END AS Max_AirQuality

FROM WHOAIRQUALITY..temporal_coverage
WHERE year IS NOT NULL
GROUP BY year
ORDER BY year;


--TOP Cities Hazard AIR QUALITY since 2010 base on Concentrated






SELECT city,
	 GREATEST(AVG(pm10_tempcov), AVG(pm25_tempcov), AVG(no2_tempcov)) AS Max_tempcov,
	 -- Display the pollutant with the maximum temporal coverage
	CASE
		WHEN AVG(pm10_tempcov) = GREATEST(AVG(pm10_tempcov), AVG(pm25_tempcov), AVG(no2_tempcov)) THEN 'pm10_tempcov'
		WHEN AVG(pm25_tempcov) = GREATEST(AVG(pm10_tempcov), AVG(pm25_tempcov), AVG(no2_tempcov)) THEN 'pm25_tempcov'
		WHEN AVG(no2_tempcov) = GREATEST(AVG(pm10_tempcov), AVG(pm25_tempcov), AVG(no2_tempcov)) THEN 'no2_tempcov'
	END AS Max_AirQuality

FROM WHOAIRQUALITY..temporal_coverage
WHERE city IS NOT NULL
GROUP BY city




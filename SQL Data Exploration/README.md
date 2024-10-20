## SQL Queries

### 1. Select All Data from Mean Concentrations
```sql
SELECT * 
FROM WHOAIRQUALITY..concentration_mean;
```
### 2. Select Top 20 Temporal Coverage Data
```
SELECT TOP 20 * 
FROM WHOAIRQUALITY..temporal_coverage 
WHERE year IS NOT NULL 
ORDER BY Population;
```
### 3. Total WHO Member and Non-Member States
```
SELECT 
    SUM(CASE WHEN who_ms = 1 THEN 1 ELSE 0 END) AS Total_MemberState,
    SUM(CASE WHEN who_ms = 0 THEN 1 ELSE 0 END) AS Total_NonMemberState
FROM WHOAIRQUALITY..concentration_mean;
```
### 4. Average Concentration by WHO Region
```
-- Uncomment the following to display average concentrations by WHO region
-- SELECT who_region, 
--        AVG(pm10_concentration) AS avg_pm10_Con, 
--        AVG(pm25_concentration) AS avg_pm25_Con, 
--        AVG(no2_concentration) AS avg_no2_Con
-- FROM WHOAIRQUALITY..concentration_mean
-- WHERE who_region IS NOT NULL
-- GROUP BY who_region
-- ORDER BY who_region;
```
### 5. Maximum Concentration Values by Region and Year
```
SELECT who_region, 
       year,
       AVG(pm10_concentration) AS pm10Con_avg, 
       AVG(pm25_concentration) AS pm25Con_avg, 
       AVG(no2_concentration) AS no2_avg, 
       GREATEST(AVG(pm10_concentration), AVG(pm25_concentration), AVG(no2_concentration)) AS MaxValue_concentration
FROM WHOAIRQUALITY..concentration_mean
WHERE who_region IS NOT NULL AND year IS NOT NULL
GROUP BY who_region, year
ORDER BY who_region, year;
```
### 6. Maximum Temporal Coverage by Region and Year
```
SELECT who_region, 
       year,
       AVG(pm10_tempcov) AS pm10temp_avg, 
       AVG(pm25_tempcov) AS pm25temp_avg, 
       AVG(no2_tempcov) AS no2temp_avg, 
       GREATEST(AVG(pm10_tempcov), AVG(pm25_tempcov), AVG(no2_tempcov)) AS MaxValue_tempcov
FROM WHOAIRQUALITY..temporal_coverage
WHERE who_region IS NOT NULL AND year IS NOT NULL
GROUP BY who_region, year
ORDER BY who_region, year;
```
### 7. Determine Maximum Air Quality Component
```
SELECT who_region, country_name, city, year, 
       pm10_concentration, pm25_concentration, no2_concentration, 
       GREATEST(pm10_concentration, pm25_concentration, no2_concentration) AS Max_tempCov,
       CASE
           WHEN pm10_concentration = GREATEST(pm10_concentration, pm25_concentration, no2_concentration) THEN 'pm10'
           WHEN pm25_concentration = GREATEST(pm10_concentration, pm25_concentration, no2_concentration) THEN 'pm25'
           WHEN no2_concentration = GREATEST(pm10_concentration, pm25_concentration, no2_concentration) THEN 'no2'
       END AS Max_AirQuality
FROM WHOAIRQUALITY..concentration_mean;
```
### 8. Air Quality Concentration vs Temporal Coverage
```
SELECT 
    con.who_region,
    con.year,
    AVG(con.pm10_concentration) AS avg_pm10_concentration,
    AVG(con.pm25_concentration) AS avg_pm25_concentration,
    AVG(con.no2_concentration) AS avg_no2_concentration,
    GREATEST(AVG(con.pm10_concentration), AVG(con.pm25_concentration), AVG(con.no2_concentration)) AS MaxValue_concentration,
    CASE
        WHEN AVG(con.pm10_concentration) = GREATEST(AVG(con.pm10_concentration), AVG(con.pm25_concentration), AVG(con.no2_concentration)) THEN 'pm10'
        WHEN AVG(con.pm25_concentration) = GREATEST(AVG(con.pm10_concentration), AVG(con.pm25_concentration), AVG(con.no2_concentration)) THEN 'pm25'
        WHEN AVG(con.no2_concentration) = GREATEST(AVG(con.pm10_concentration), AVG(con.pm25_concentration), AVG(con.no2_concentration)) THEN 'no2'
    END AS AirQuality_con,
    GREATEST(AVG(temp.pm10_tempcov), AVG(temp.pm25_tempcov), AVG(temp.no2_tempcov)) AS MaxValue_tempcov,
    CASE
        WHEN AVG(temp.pm10_tempcov) = GREATEST(AVG(temp.pm10_tempcov), AVG(temp.pm25_tempcov), AVG(temp.no2_tempcov)) THEN 'pm10'
        WHEN AVG(temp.pm25_tempcov) = GREATEST(AVG(temp.pm10_tempcov), AVG(temp.pm25_tempcov), AVG(temp.no2_tempcov)) THEN 'pm25'
        WHEN AVG(temp.no2_tempcov) = GREATEST(AVG(temp.pm10_tempcov), AVG(temp.pm25_tempcov), AVG(temp.no2_tempcov)) THEN 'no2'
    END AS AirQuality_temporalCov
FROM WHOAIRQUALITY..concentration_mean con
JOIN WHOAIRQUALITY..temporal_coverage temp
    ON con.city = temp.city AND con.year = temp.year
WHERE con.who_region IS NOT NULL AND con.year IS NOT NULL
GROUP BY con.who_region, con.year
ORDER BY con.who_region, con.year;
```
### 9. Air Quality Concentration Category
```
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
) AS Subquery;
```

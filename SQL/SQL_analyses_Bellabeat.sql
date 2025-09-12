-- SUMMARY: 11 Datasets capturing different wellness measurements by the Fitbit.
-- For easier analyses, I want one combined set.
-- To fit these datasets together, we'll need to check for matching columns and datatypes.
-- We'll then accumulate the sets one by one for a final merger before analyses

-- STEP 1: TESTING THE WATERS
-- Check to see which column names are shared across tables 
SELECT column_name, COUNT(DISTINCT table_name) AS table_count
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_schema = 'dbo'
GROUP BY column_name
ORDER BY table_count DESC;
--[Result:The Id column was listed to appear 11 times which can be a good JOIN between sets

-- let's double check the id column is indeed in every dataset we'll be working with for this query
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME = 'Id'
AND TABLE_SCHEMA = 'dbo'
--[Result affirmative.

-- Check for columns with date-related keywords, and the datatype for these columns
SELECT 
 TABLE_NAME,
 COLUMN_NAME,
 DATA_TYPE,
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND (LOWER(COLUMN_NAME) LIKE '%date%'
   OR LOWER(COLUMN_NAME) LIKE '%minute%'
   OR LOWER(COLUMN_NAME) LIKE '%daily%'
   OR LOWER(COLUMN_NAME) LIKE '%hourly%'
   OR LOWER(COLUMN_NAME) LIKE '%day%'
   OR LOWER(COLUMN_NAME) LIKE '%second%'
  )
ORDER BY TABLE_NAME, COLUMN_NAME;
-- [Result datatype: All date-related columns are in VARCHAR. 
-- [Result date-related Columns: The DailyActivity dataset contain most time-related columns, mostly minute and day related. 
-- With this information, I've decided to convert all sets to daily values before merging all relatable data with the DailyActivity data set.

 -- In the dailyActivity_merged table we saw that there is a column called ActivityDate, let's check this column is a valid timestamp column 
SELECT TOP 5
 ActivityDate,
 CASE 
  WHEN ISDATE(ActivityDate) = 1 THEN 'Valid'
  ELSE 'Not Valid'
 END AS is_timestamp
FROM dbo.dailyActivity_merged;
-- [Result: Valid

-- Check if all columns follow the timestamp pattern
SELECT 
 CASE 
  WHEN MIN(CASE WHEN ISDATE(ActivityDate) = 1 THEN 1 ELSE 0 END) = 1 
  THEN 'Valid'
  ELSE 'Not Valid'
 END AS valid_test
FROM dbo.dailyActivity_merged;
-- [Result: Valid


-- STEP 2: MERGE HOURLY AND MINUTE CALORIES DATASETS 
-- Compare HourlyCalories_merged dataset's columns and datatypes to MinuteCaloriesNarrow_merged dataset.
SELECT 
 c1.COLUMN_NAME AS hourlyCalories_merged_Column,
 c1.DATA_TYPE AS hourlyCalories_merged_DataType,
 c2.COLUMN_NAME AS minuteCaloriesNarrow_merged_Column,
 c2.DATA_TYPE AS minuteCaloriesNarrow_merged_DataType
FROM INFORMATION_SCHEMA.COLUMNS c1
FULL OUTER JOIN INFORMATION_SCHEMA.COLUMNS c2
 ON c1.COLUMN_NAME = c2.COLUMN_NAME
  AND c1.TABLE_NAME = 'hourlyCalories_merged'
  AND c2.TABLE_NAME = 'minuteCaloriesNarrow_merged'
WHERE c1.TABLE_NAME = 'hourlyCalories_merged'
 OR c2.TABLE_NAME = 'minuteCaloriesNarrow_merged'
ORDER BY COALESCE(c1.COLUMN_NAME, c2.COLUMN_NAME);
-- [Result: All data types: VARCHAR, and both datasets have the Id + Calories column(although calories are calculated differently in minute and hourly). 
-- ActivityMinute and ActivityHour column differ, so I will recalculate and rename these to match the DailyAcitivity Data set which results will be merged into in the end.

-- Create a new temporary table with daily calories aggregated from hourly, and change ActivityHour column data type from string to datetime.
SELECT 
 Id,
 CAST(ActivityHour AS datetime) AS ActivityDate,
 SUM(CAST(Calories AS FLOAT)) AS Calories
INTO dbo.HourlyCalories_day
FROM dbo.hourlyCalories_merged
GROUP BY Id, CAST(ActivityHour AS datetime);

-- Create a new temporary table with daily calories aggregated from minute, and change data Activityminute column type from string to datetime.
SELECT 
 Id,
 CAST(ActivityMinute AS datetime) AS ActivityDate,
 SUM(CAST(Calories AS FLOAT)) AS Calories
INTO dbo.MinuteCalories_day
FROM dbo.minuteCaloriesNarrow_merged
GROUP BY Id, CAST(ActivityMinute AS datetime);

-- Create a new table with all calories merged
SELECT
 COALESCE(h.Id, m.Id) AS Id,
 COALESCE(h.ActivityDate, m.ActivityDate) AS ActivityDate,
 COALESCE(m.Calories, h.Calories) AS Calories
INTO dbo.Daily_Calories_merged
FROM dbo.HourlyCalories_day h
FULL OUTER JOIN dbo.MinuteCalories_day m
 ON h.Id = m.Id
  AND h.ActivityDate = m.ActivityDate;

-- Delete potential duplicates
WITH Duplicates AS (
SELECT *,
 ROW_NUMBER() 
 OVER (PARTITION BY Id, ActivityDate
  ORDER BY Id  
 ) AS RowNum
FROM dbo.Daily_Calories_merged
)
DELETE FROM Duplicates
WHERE RowNum > 1;
-- Result: No rows affected/no duplicates

-- Check Calories datasets was successfull
SELECT TOP 10 *
FROM dbo.Daily_Calories_merged
ORDER BY ActivityDate;


-- STEP 3: MERGE HOURLY AND MINUTE INTENSITIES DATASETS
-- Compare HourlyIntensities_merged dataset's columns and datatypes to MinuteIntensitiessNarrow_merged dataset.
SELECT 
 c1.COLUMN_NAME AS hourlyIntensities_merged_Column,
 c1.DATA_TYPE AS hourlyIntensities_merged_DataType,
 c2.COLUMN_NAME AS minuteIntensitiesNarrow_merged_Column,
 c2.DATA_TYPE AS minuteIntensitiesNarrow_merged_DataType
FROM INFORMATION_SCHEMA.COLUMNS c1
FULL OUTER JOIN INFORMATION_SCHEMA.COLUMNS c2
 ON c1.COLUMN_NAME = c2.COLUMN_NAME
  AND c1.TABLE_NAME = 'hourlyIntensities_merged'
  AND c2.TABLE_NAME = 'minuteIntensitiesNarrow_merged'
WHERE c1.TABLE_NAME = 'hourlyIntensities_merged'
 OR c2.TABLE_NAME = 'minuteIntensitiesNarrow_merged'
ORDER BY COALESCE(c1.COLUMN_NAME, c2.COLUMN_NAME);
-- [Result: All data types: VARCHAR, and both datasets have the Id column but all other column names differ slightly and are calculated differently (minute vs hourly).

-- Create a new temporary table with daily Intensities aggregated from hourly, and change ActivityHour column data type from string to datetime.
SELECT 
 Id,
 CAST(ActivityHour AS datetime) AS ActivityDate,
 SUM(CAST(TotalIntensity AS FLOAT)) AS TotalIntensity
INTO dbo.HourlyIntensities_day
FROM dbo.hourlyIntensities_merged
GROUP BY Id, CAST(ActivityHour AS datetime);

-- Create a new temporary table with daily Intensities aggregated from minute, and change ActivityMinute column data type from string to datetime.
SELECT 
 Id,
 CAST(ActivityMinute AS datetime) AS ActivityDate,
 SUM(CAST(Intensity AS FLOAT)) AS TotalIntensity
INTO dbo.MinuteIntensities_day
FROM dbo.minuteIntensitiesNarrow_merged
GROUP BY Id, CAST(ActivityMinute AS datetime);

-- Create a new table merging daily Intensities dataset.
SELECT
 COALESCE(h.Id, m.Id) AS Id,
 COALESCE(h.ActivityDate, m.ActivityDate) AS ActivityDate,
 COALESCE(m.TotalIntensity, h.TotalIntensity) AS TotalIntensity
INTO dbo.Daily_Intensities_merged
FROM dbo.HourlyIntensities_day h
FULL OUTER JOIN dbo.MinuteIntensities_day m
 ON h.Id = m.Id
  AND h.ActivityDate = m.ActivityDate;

-- Delete potential duplicates
WITH Duplicates AS (
SELECT *,
 ROW_NUMBER() 
 OVER (PARTITION BY Id, ActivityDate
  ORDER BY Id  
 ) AS RowNum
FROM dbo.Daily_Intensities_merged
)
DELETE FROM Duplicates
WHERE RowNum > 1;
-- Result: No rows affected/no duplicates

-- Check merge of Intensities datasets was successfull
SELECT TOP 10 *
FROM dbo.Daily_Intensities_merged
ORDER BY ActivityDate;


-- STEP 4: MERGE STEPS DATASETS
-- Compare HourlySteps_merged dataset's columns and datatypes to MinuteStepssNarrow_merged dataset.
SELECT 
 c1.COLUMN_NAME AS hourlySteps_merged_Column,
 c1.DATA_TYPE AS hourlysteps_merged_DataType,
 c2.COLUMN_NAME AS minuteStepsNarrow_merged_Column,
 c2.DATA_TYPE AS minuteStepsNarrow_merged_DataType
FROM INFORMATION_SCHEMA.COLUMNS c1
FULL OUTER JOIN INFORMATION_SCHEMA.COLUMNS c2
 ON c1.COLUMN_NAME = c2.COLUMN_NAME
  AND c1.TABLE_NAME = 'hourlySteps_merged'
  AND c2.TABLE_NAME = 'minuteStepsNarrow_merged'
WHERE c1.TABLE_NAME = 'hourlySteps_merged'
 OR c2.TABLE_NAME = 'minuteStepsNarrow_merged'
ORDER BY COALESCE(c1.COLUMN_NAME, c2.COLUMN_NAME);
-- [Result: All data types: VARCHAR, and both datasets have the Id column but all other column names differ slightly and are calculated differently (minute vs hourly). 

-- Create a new temporary table with daily Steps aggregated from hourly, and change ActivityHour column data type from string to datetime.
SELECT 
 Id,
 CAST(ActivityHour AS datetime) AS ActivityDate,
 SUM(CAST(StepTotal AS FLOAT)) AS TotalSteps
INTO dbo.HourlySteps_day
FROM dbo.hourlySteps_merged
GROUP BY Id, CAST(ActivityHour AS datetime);

-- Create a new temporary table with daily Steps aggregated from minute, and change ActivityMinute column data type from string to datetime.
SELECT 
 Id,
 CAST(ActivityMinute AS datetime) AS ActivityDate,
 SUM(CAST(Steps AS FLOAT)) AS TotalSteps
INTO dbo.MinuteSteps_day
FROM dbo.minuteStepsNarrow_merged
GROUP BY Id, CAST(ActivityMinute AS datetime);

-- Create a new table merging daily Steps dataset.
SELECT
 COALESCE(h.Id, m.Id) AS Id,
 COALESCE(h.ActivityDate, m.ActivityDate) AS ActivityDate,
 COALESCE(m.TotalSteps, h.TotalSteps) AS TotalSteps
INTO dbo.Daily_Steps_merged
FROM dbo.HourlySteps_day h
FULL OUTER JOIN dbo.MinuteSteps_day m
 ON h.Id = m.Id
  AND h.ActivityDate = m.ActivityDate;

-- Delete potential duplicates
WITH Duplicates AS (
SELECT *,
 ROW_NUMBER() 
 OVER (PARTITION BY Id, ActivityDate
  ORDER BY Id  
 ) AS RowNum
FROM dbo.Daily_Steps_merged
)
DELETE FROM Duplicates
WHERE RowNum > 1;
-- Result: No rows affected/no duplicates

-- Check merger of Steps was datasets was successfull
SELECT TOP 10 *
FROM dbo.Daily_Steps_merged
ORDER BY ActivityDate;


-- 5. CONVERT HEARTRATE TO DAILY
-- Check columns and datatype in heartrate_seconds_merged dataset
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'heartrate_seconds_merged'
  AND TABLE_SCHEMA = 'dbo';
-- [Result: All data types: VARCHAR. Column names are Id, Time and Values. I'm unsure if Time indicates date as well.

-- Display a quickview of the content of dataset
Select Top 10 *
FROM dbo.Minute_heartrate
-- [Result: Time column contains time and date values. Since these are in VARCHAR, I will need to rename column to match DailyAcitivities
-- Instead of converting Heartrate to daily data, I will convert it into minutes to catch more exact results for analyses.

--TBC...
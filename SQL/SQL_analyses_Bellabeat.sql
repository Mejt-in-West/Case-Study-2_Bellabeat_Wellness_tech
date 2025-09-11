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
  AND (
        LOWER(COLUMN_NAME) LIKE '%date%'
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

 -- check if all columns follow the timestamp pattern
SELECT 
    CASE 
        WHEN MIN(CASE WHEN ISDATE(ActivityDate) = 1 THEN 1 ELSE 0 END) = 1 
            THEN 'Valid'
        ELSE 'Not Valid'
    END AS valid_test
FROM dbo.dailyActivity_merged;
-- [Result: Valid


-- STEP 2: MERGE CALORIES DATASETS 
-- compare the two calorie-data sets columns and datatypes
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
-- ActivityMinute and ActivityHour differ, so I will rename these to match the DailyAcitivity Data set which results will be merged into in the end.

-- Create a new temporary table with daily calories aggregated from hourly, and change data type from string to datetime.
SELECT 
    Id,
    CAST(ActivityHour AS datetime) AS ActivityDate,
    SUM(CAST(Calories AS FLOAT)) AS Calories      -- cast varchar to float before summing
INTO dbo.HourlyCalories_day2
FROM dbo.hourlyCalories_merged
GROUP BY Id, CAST(ActivityHour AS datetime);

-- Create a new temporary table with daily calories aggregated from minute, and change data type from string to datetime.
SELECT 
    Id,
    CAST(ActivityMinute AS datetime) AS ActivityDate,   -- strip time down to just date
    SUM(CAST(Calories AS FLOAT)) AS Calories      -- cast varchar to float before summing
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

-- Check merge into Daily_Calories_merged was successfull
SELECT TOP 10 *
FROM dbo.Daily_Calories_merged
ORDER BY ActivityDate;


-- STEP 3: MERGE INTENSITIES DATASETS
--TBC..
/*
	**** CLENAING DATA ****
*/

SELECT *
FROM mobile_data;

-- Creating new table for editing with columns I need, and slightly modifying some of them
DROP TABLE IF EXISTS mobile_data_editing;
CREATE TABLE mobile_data_editing AS
SELECT 
	Brand, Name, RAM, Processor, Battery, `Rear Camera` AS Rear_Camera, 
	`Front Camera` AS Front_Camera, Display, `Launch Date` AS Launch_Date,
    `Operating System` as OP_System, `Display Type` as Display_type, 
    CASE
		WHEN `USB Type-C` = 'yes' THEN TRUE
        WHEN `USB Type-C` = 'no' THEN FALSE
        ELSE NULL 
	END AS USB_C, 
	`Internal Memory` as Internal_Memory, `Expandable Memory` as Expandable_Memory, 
    CASE
		WHEN `SIM Slot(s)` LIKE 'Dual%' THEN 2
        WHEN `SIM Slot(s)` LIKE 'Single%' THEN 1
        ELSE NULL
	END AS SIM,
    CASE 
		WHEN `Fingerprint Sensor` = 'yes' THEN TRUE
        WHEN `Fingerprint Sensor` = 'no' THEN FALSE
        ELSE NULL
	END AS Fingerprint,
    Price
FROM mobile_data;

SELECT *
FROM mobile_data_editing;

-- changing all blank values to NULLs
UPDATE mobile_data_editing
SET 
	Brand = NULLIF(Brand, ""),
    Name = NULLIF(Name, ""),
    RAM = NULLIF(RAM, ""),
    Processor = NULLIF(Processor, ""),
    Battery = NULLIF(Battery, ""),
    Rear_Camera = NULLIF(Rear_Camera, ""),
    Front_Camera = NULLIF(Front_Camera, ""),
    Display = NULLIF(Display, ""),
    Launch_Date = NULLIF(Launch_Date, ""),
    OP_System = NULLIF(OP_System, ""),
    Display_type = NULLIF(Display_type, ""),
    Internal_Memory = NULLIF(Internal_Memory, ""),
    Expandable_Memory = NULLIF(Expandable_Memory, ""),
    Price = NULLIF(Price, "");

-- checking for duplicates and deleting them

WITH is_duplicate AS
(
SELECT 
	*, ROW_NUMBER() OVER(PARTITION BY Brand, Name, RAM, Processor, Battery, Rear_Camera, Front_Camera, Display, 
    Launch_Date, OP_System, Display_type, USB_C, Internal_Memory, Expandable_Memory, SIM, Fingerprint, Price ) AS duplicates
FROM mobile_data_editing
)
SELECT *
FROM is_duplicate
WHERE duplicates != 1;

DROP TABLE IF EXISTS mobile_data_editing2;
CREATE TABLE mobile_data_editing2 AS
SELECT 
	*, ROW_NUMBER() OVER(PARTITION BY Brand, Name, RAM, Processor, Battery, Rear_Camera, Front_Camera, Display, 
    Launch_Date, OP_System, Display_type, USB_C, Internal_Memory, Expandable_Memory, SIM, Fingerprint, Price ) AS duplicates
FROM mobile_data_editing;

DELETE 
FROM mobile_data_editing2
WHERE duplicates != 1;

ALTER TABLE mobile_data_editing2
DROP COLUMN duplicates;

SELECT *
FROM mobile_data_editing2;

-- Changing RAM COLUMN so that it only contains the number
-- "8 GB" -> "8"

SELECT 
	Name, RAM,
    CASE
		WHEN RAM LIKE "%GB" THEN CAST(SUBSTRING_INDEX(RAM, ' ', 1) AS SIGNED)
        WHEN RAM LIKE "%MB" THEN ROUND(CAST(SUBSTRING_INDEX(RAM, ' ', 1) AS SIGNED)/1024, 2)
        ELSE NULL
	END AS RAM_GB
FROM mobile_data_editing2;

UPDATE mobile_data_editing2
SET RAM = CASE
	WHEN RAM LIKE "%GB" THEN CAST(SUBSTRING_INDEX(RAM, ' ', 1) AS SIGNED)
	WHEN RAM LIKE "%MB" THEN ROUND(CAST(SUBSTRING_INDEX(RAM, ' ', 1) AS SIGNED)/1024, 2)
	ELSE NULL
END;

ALTER TABLE mobile_data_editing2
CHANGE COLUMN RAM RAM_GB INT;

SELECT *
FROM mobile_data_editing2;

-- Changing the Battery column to contain just the number
-- "7000 mAh" -> "7000"

SELECT 
	Name, Battery,
	SUBSTRING_INDEX(Battery, " ", 1) as Battery_mAh
FROM mobile_data_editing2;

UPDATE mobile_data_editing2
SET Battery = SUBSTRING_INDEX(Battery, " ", 1);

ALTER TABLE mobile_data_editing2
CHANGE COLUMN Battery Battery_mAh INT;

SELECT * 
FROM mobile_data_editing2;

-- Modifying Rear_Camera column "48 MP + 2 MP + 20 MP"
-- Creating a new table for camera data that will contain new 5 columns to replace this one:
	-- rear_camera_count that will contain the number of camera that model has
	-- cam1_mp, cam2_mp, cam3_mp and cam4_mp which will say how many pixels each camera has
    -- and a column for front data information
    
-- First fixing some misspelled data 
SELECT *
FROM mobile_data_editing2
WHERE Name = 'vivo Y30' or Name = 'vivo Y30 6GB RAM';

UPDATE mobile_data_editing2
SET Rear_Camera = '13 MP + 8 MP + 2 MP + 2 MP'
WHERE Name = 'vivo Y30' or Name = 'vivo Y30 6GB RAM';

-- creating the new table with new columns

DROP TABLE IF EXISTS mobile_camera_data;
CREATE TABLE mobile_camera_data AS
SELECT 
	Name, 
    LENGTH(Rear_Camera) - LENGTH(REPLACE(Rear_Camera, '+', '')) +1 AS Rear_Camera_Count,
    TRIM(SUBSTRING_INDEX(Rear_Camera, ' MP', 1)) AS Cam1_MP,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Rear_Camera, ' MP', 2), ' ', -1)) AS Cam2_MP,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Rear_Camera, ' MP', 3), ' ', -1)) AS Cam3_MP,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Rear_Camera, ' MP', 4), ' ', -1)) AS Cam4_MP,
    Front_Camera
FROM mobile_data_editing2;

UPDATE mobile_camera_data
SET 
	Cam1_MP = NULLIF(Cam1_MP, "MP"),
    Cam2_MP = NULLIF(Cam2_MP, "MP"),
    Cam3_MP = NULLIF(Cam3_MP, "MP"),
    Cam4_MP = NULLIF(Cam4_MP, "MP");
    
ALTER TABLE mobile_camera_data
MODIFY COLUMN Rear_Camera_Count INT,
MODIFY COLUMN Cam1_MP INT,
MODIFY COLUMN Cam2_MP INT,
MODIFY COLUMN Cam3_MP INT,
MODIFY COLUMN Cam4_MP INT;

-- Changing Front_Camera column so that it contains only the value
-- "20 MP" -> "20"

SELECT 
	Name, Front_Camera,
	SUBSTRING_INDEX(Front_Camera, ' ', 1) as Front_Camera_MP
FROM mobile_camera_data;

UPDATE mobile_camera_data
SET 
	Front_Camera = SUBSTRING_INDEX(Front_Camera, ' ', 1);

ALTER TABLE mobile_camera_data
CHANGE COLUMN Front_Camera Front_Camera_MP INT;

SELECT *
FROM mobile_camera_data;

-- Deleting camera columns from mobile_data_editing2 table

ALTER TABLE mobile_data_editing2
DROP COLUMN Rear_Camera,
DROP COLUMN Front_Camera;

-- Modifying Display column so that it contains only the value in inches
-- "6.52 inches (16.56 cm)" -> "6.25"

SELECT 
	Name, Display,
	SUBSTRING_INDEX(Display, " ", 1) as Display_inches
FROM mobile_data_editing2;

UPDATE mobile_data_editing2
SET Display = SUBSTRING_INDEX(Display, " ", 1);

ALTER TABLE mobile_data_editing2
CHANGE COLUMN Display Display_inches INT;

SELECT * 
FROM mobile_data_editing2;

-- Modifying the date column
	-- Deleting data I dont need
	-- Changing the type of column to date
   
SELECT 
	name, launch_date,
	substring_index(launch_date, " (", 1) as date
from mobile_data_editing2;

UPDATE mobile_data_editing2
SET launch_date = STR_TO_DATE(SUBSTRING_INDEX(launch_date, " (", 1),  '%M %d, %Y');

ALTER TABLE mobile_data_editing2
MODIFY COLUMN launch_date DATE;

-- Modifying Display_Type coulmn
-- Simplefying it so it only has LCD, OLED and AMOLED types

UPDATE mobile_data_editing2
SET Display_type = CASE
	WHEN Display_Type LIKE "%AMOLED%" THEN "AMOLED"
	WHEN Display_Type LIKE "%LCD%" OR Display_Type = "TFT" THEN "LCD"
	WHEN Display_Type LIKE "%OLED%" THEN "OLED"
	ELSE NULL
END;

-- Modifying Internal_Memory column 
-- Cleaning out of not needed data and leaving only the value 
-- "128 GB        Best in Class  â–¾" -> "128"

UPDATE mobile_data_editing2
SET Internal_Memory = CASE
	WHEN Internal_Memory LIKE "% MB%" THEN ROUND(CAST(SUBSTRING_INDEX(Internal_Memory, " ", 1) AS SIGNED)/1024, 2)
	WHEN Internal_Memory LIKE "% GB%" THEN SUBSTRING_INDEX(Internal_Memory, " ", 1)
	WHEN Internal_Memory LIKE "% TB%" THEN CAST(SUBSTRING_INDEX(Internal_Memory, " ", 1) AS SIGNED)*1024
	ELSE NULL
END;

ALTER TABLE mobile_data_editing2
CHANGE COLUMN Internal_Memory Internal_Memory_GB INT;

SELECT * 
FROM mobile_data_editing2;

-- Creating a new table that will contain all memory information 
-- Modifying the column expendable memory
-- "Yes, up to 128 GB" -> 128

DROP TABLE IF EXISTS mobile_memory_data;
CREATE TABLE mobile_memory_data AS
SELECT 
	Name, RAM_GB, Internal_Memory_GB,
    CASE
		WHEN Expandable_Memory = "No" THEN 0
        WHEN Expandable_Memory LIKE "Yes%" AND Expandable_Memory LIKE "%GB" 
			THEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(Expandable_Memory, " ", 4), " ", -1) AS SIGNED)
		WHEN Expandable_Memory LIKE "Yes%" AND Expandable_Memory LIKE "%TB" 
			THEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(Expandable_Memory, " ", 4), " ", -1) AS SIGNED) * 1024
        ELSE NULL
	END AS Expandable_Memory_up_to_GB
FROM mobile_data_editing2;

SELECT *
FROM mobile_memory_data;

ALTER TABLE mobile_data_editing2
DROP COLUMN RAM_GB,
DROP COLUMN Internal_Memory_GB,
DROP COLUMN Expandable_Memory;
    
-- Changing the price column so it contains only the number, and changing it to from rs to  American dollars
-- "RS. 43,500.00" -> 524

UPDATE mobile_data_editing2
SET Price = REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(Price, " ", -1), ".", 1), ",", "");

ALTER TABLE mobile_data_editing2
CHANGE COLUMN Price Price_Dollars INT;

UPDATE mobile_data_editing2
SET Price_Dollars = Price_Dollars / 83;

SELECT *
FROM mobile_data_editing2;


/* 
	****  PREPARING DATA FOR VIZUALIZATIONS ****
    
    1. Taking out all data gathered together
    2. Looking at how the price varies with different cameras
		> average price with the amount of rear cameras
        > average price with different resolutions of phones with one rear camera
        > average price with different resolutions of phones with all 4 rear cameras
        > average price with different resoultions of front cameras
    3. Battery life and price through time + ability to filter by brand
    4. Looking at how display types affected the mobile phone industry
		> each type over the years
    5. 
*/

-- 1. getting all data together
SELECT *
FROM mobile_data_editing2 ed
JOIN mobile_camera_data ca
	ON ed.name = ca.name
JOIN mobile_memory_data me
	ON ed.name = me.name;

-- 2. looking at how the price varies with different cameras

-- for amount of cameras
WITH camera_price as
(
SELECT 
	ed.name, ed.price_dollars as price, ca.Rear_Camera_Count AS cam_count
FROM mobile_data_editing2 ed
JOIN mobile_camera_data ca
	ON ed.name = ca.name
)
SELECT cam_count, AVG(price) as avg_price
FROM camera_price
GROUP BY cam_count
ORDER BY cam_count;

-- for phones with only 1 rear camera
WITH camera_price1 as
(
SELECT 
	ed.name, ed.price_dollars as price, ca.Rear_Camera_Count AS cam_count,
    ca.Cam1_MP as cam1, ca.Cam2_MP as cam2, ca.Cam3_MP as cam3, ca.Cam4_MP as cam4
FROM mobile_data_editing2 ed
JOIN mobile_camera_data ca
	ON ed.name = ca.name
)
SELECT cam1, AVG(price) as avg_price
FROM camera_price1
WHERE cam_count = 1
GROUP BY cam1
ORDER BY cam1;

-- for phones with all 4 rear cameras
WITH camera_price4 as
(
SELECT 
	ed.name, ed.price_dollars as price, ca.Rear_Camera_Count AS cam_count,
    ca.Cam1_MP as cam1, ca.Cam2_MP as cam2, ca.Cam3_MP as cam3, ca.Cam4_MP as cam4
FROM mobile_data_editing2 ed
JOIN mobile_camera_data ca
	ON ed.name = ca.name
)
SELECT cam1, cam2, cam3, cam4, AVG(price) as avg_price
FROM camera_price4
WHERE cam_count = 4
GROUP BY cam1, cam2, cam3, cam4
ORDER BY cam1, cam2, cam3, cam4;

-- for front camera resolutions
WITH front_camera_price as
(
SELECT 
	ed.name, ed.price_dollars as price, ca.Front_Camera_MP as front_cam
FROM mobile_data_editing2 ed
JOIN mobile_camera_data ca
	ON ed.name = ca.name
)
SELECT front_cam, AVG(price) as avg_price
FROM front_camera_price
GROUP BY front_cam
ORDER BY front_cam;

-- 3. Battery life, display size and price through time + ability to filter by brand
SELECT launch_date, brand, battery_mAh, Display_inches, Price_Dollars
FROM mobile_data_editing2
ORDER BY launch_date;

-- 4. Looking at how display types affected the mobile phone industry

SELECT name, brand, Display_type, Display_inches, launch_date, price_dollars
FROM mobile_data_editing2;

-- How much was each type created thorugh years
WITH amount_display_type AS
(
SELECT name, brand, Display_type, launch_date, ROW_NUMBER() OVER(PARTITION BY name) as num
FROM mobile_data_editing2
WHERE Display_type IS NOT NULL
)
SELECT Display_type, YEAR(launch_date), SUM(NUM)
FROM amount_display_type
GROUP BY Display_type, YEAR(launch_date)
ORDER BY Display_type, YEAR(launch_date);

--

SELECT name, brand, Display_type, launch_date, ROW_NUMBER() OVER(PARTITION BY name) as num
FROM mobile_data_editing2
WHERE Display_type IS NOT NULL;


SELECT 
	ed.name, ed.brand, ed.launch_date, ca.rear_camera_count, ca.cam1_mp, ca.cam2_mp, 
	ca.cam3_mp, ca.cam4_mp, ca.Front_Camera_MP, ed.Price_Dollars
FROM mobile_data_editing2 ed
JOIN mobile_camera_data ca
	ON ed.name = ca.name;
    
SELECT *
FROM mobile_memory_data;




    
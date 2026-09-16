-- Data Cleaning

SELECT *
FROM  layoffs
LIMIT 10;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. NULL Values or blank values
-- 4. Remove Any Columns

-- Creating a copy of raw data. Creating a blank table with same columns
CREATE TABLE layoffs_staging
LIKE layoffs;

-- Inserting the data from raw data
INSERT layoffs_staging
SELECT * 
FROM layoffs;

-- Step 1. Remove Duplicates
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Using the table from previous result to check for duplicates
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging
WHERE company = 'Casper';

-- CANNOT delete columns with CTE
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num> 1;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


-- Step 2. Standarizing data
-- For Column_COUNTRY
SELECT company, TRIM(company)
FROM layoffs_staging2;  

UPDATE layoffs_staging2
SET company = TRIM(company);

-- For Column_industry
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE '%Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE '%Crypto%';

-- For Column_location
SELECT DISTINCT location
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE location LIKE 'Malm%' OR 
	location LIKE 'D%dorf' OR 
    location LIKE'Florian%';
    
UPDATE layoffs_staging3
SET location = 'Malmö'
WHERE location LIKE 'Malm%';

UPDATE layoffs_staging3
SET location = 'Düsseldorf'
WHERE location LIKE 'D%dorf';

UPDATE layoffs_staging3
SET location = 'Florainópolis' 
WHERE location LIKE 'Florian%polis';

-- For Column_country
SELECT DISTINCT country
FROM layoffs_staging2;

-- Check for which is the proper one to be recorded
SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%'; 

-- Codify the format of DATE text
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Change the data type of a certain column
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- Step 3. NULL values or blank values 
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT *
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
WHERE company LIKE '%Bally%';


-- Step 4. Remove Columns or Rows
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Removing Column no longer needed
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

CREATE TABLE `layoffs_staging3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` date DEFAULT NULL,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging3
SELECT *
FROM layoffs_staging2;

DELETE 
FROM layoffs_staging3
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

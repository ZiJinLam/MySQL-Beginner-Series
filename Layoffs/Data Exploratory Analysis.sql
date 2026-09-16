-- Exploratory Data Anmalysis
SELECT *
FROM layoffs_staging3;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging3;

SELECT *
FROM layoffs_staging3
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Total laid off in each company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company
ORDER BY 2 DESC;

-- Range of date of this Dataset
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging3;

-- Total laid off in each industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY industry
ORDER BY 2 DESC;

-- Total laid off in each country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY country
ORDER BY 2 DESC;

-- Total laid off in each year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Total laid off in each stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY stage
ORDER BY 2 DESC;

-- Average of percentage laid off in each company
SELECT company, AVG(percentage_laid_off)
FROM layoffs_staging3
GROUP BY company
ORDER BY 2 DESC;

-- Sum of total laid off in each month
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging3
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY `MONTH` ASC;

-- Create a monthly rolling total
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging3
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY `MONTH` ASC
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company
ORDER BY 2 DESC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Rank the Top 5 campanies of having largest total laid off in each year
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging3
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;

--------------------------------------------- 
-- The top company having the most laid off in each country
WITH RankedData AS
(
	SELECT *, 
        RANK() OVER (PARTITION BY country ORDER BY total_laid_off DESC) as Ranking
	FROM layoffs_staging3
    WHERE total_laid_off IS NOT NULL
)
SELECT *
FROM RankedData
WHERE Ranking = 1
ORDER BY total_laid_off DESC;

-- The top company having the most laid off in each industry
WITH RankedData AS
(
	SELECT *, 
        RANK() OVER (PARTITION BY industry ORDER BY total_laid_off DESC) as Ranking
	FROM layoffs_staging3
    WHERE total_laid_off IS NOT NULL
)
SELECT *
FROM RankedData
WHERE Ranking = 1
ORDER BY total_laid_off DESC;

-- As most of them located in United States, set condition to dive deeper
WITH RankedData AS
(
	SELECT *, 
        RANK() OVER (PARTITION BY industry ORDER BY total_laid_off DESC) as Ranking
	FROM layoffs_staging3
    WHERE total_laid_off IS NOT NULL
)
SELECT *
FROM RankedData
WHERE Ranking = 1
	AND country = 'United States'
ORDER BY total_laid_off DESC;


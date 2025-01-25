CREATE DATABASE DATA_CLEANING;

USE DATA_CLEANING;

SELECT * FROM learn_clean;

-- CREATE TABLE SIMILAR TO THE RAW TABLE 

CREATE TABLE layoff
LIKE learn_clean;  -- this copies the columns 

SELECT * FROM layoff;

INSERT layoff 
SELECT *
FROM learn_clean; -- this copies the entire data 

-- 1. remove duplicates 

WITH REM_DUP AS(
SELECT *, ROW_NUMBER() 
OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS rw_num 
FROM layoff)
SELECT *
FROM REM_DUP
where rw_num =1;

-- Right click on table > COPY TO CLIPBOARD > ccreate statement> EDITOR PAGE AND CTRL+V 

CREATE TABLE `layoff2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `rw_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- THE ABOVE STMT WILL CREATE A EMPTY TABLE 

SELECT * FROM layoff2;

INSERT INTO layoff2 
SELECT *, ROW_NUMBER() 
OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions) AS rw_num 
FROM layoff;

SELECT * FROM layoff2;

SELECT * 
FROM layoff2
where rw_num >1;


SET SQL_SAFE_UPDATES =0;  -- OR GO TO EDIT > SQL EDITOR > UNCHECK THE SAFE MODE - AFTER DOING this refresh mysql 

DELETE 
FROM layoff2
where rw_num >1;

-- 2. standarizing the data (finding issues and fixing it 

SELECT Company, TRIM(COMPANY)
FROM layoff2;

UPDATE layoff2
SET company = TRIM(Company);

SELECT * FROM LAYOFF2;

SELECT DISTINCT industry
FROM layoff2
order by 1;  -- We have have rows like crypto, cryptocurrency, crypto currency and we to make them one 

SELECT *
FROM layoff2
WHERE industry LIKE 'crypto%';

UPDATE layoff2 
SET industry = 'crypto'
WHERE industry LIKE 'crypto%';

SELECT DISTINCT location 
FROM layoff2
order by 1;    -- after scrolling over the column everything looks good in this 

SELECT DISTINCT country
FROM layoff2
order by 1; 

UPDATE layoff2 
SET country = 'United States'
WHERE country LIKE 'United States%';

-- (or)

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoff2 
ORDER BY 1;

UPDATE layoff2 
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'united states%';

-- the date field in table is in text format we need to change it to date we can use STR_TO_DATE() THIS function helps us to change the date datatype 

SELECT date, 
STR_TO_DATE(date, '%m/%d/%Y') 
FROM layoff2;

UPDATE layoff2 
SET date = STR_TO_DATE(date, '%m/%d/%Y') ;

SELECT * FROM LAYOFF2;

-- DATE DATA TYPE IS STILL TEXT 

ALTER TABLE layoff2 
MODIFY COLUMN date DATE;

-- 3. NULL AND BLANK VALUES 
SELECT *
FROM layoff2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

DELETE 
FROM layoff2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

SELECT *
FROM layoff2;

-- deleting the column 
ALTER TABLE layoff2 
DROP COLUMN rw_num;

SELECT * 
FROM layoff2 
WHERE company = 'airbnb';

SELECT * 
FROM layoff2
WHERE company = 'Carvana';

select l1. industry, l2.industry
FROM layoff2 l1 
join layoff2 l2 
ON l1.company = l2.company 
WHERE  l1.industry IS NULL 
or l1.industry = '';

UPDATE layoff2
SET industry = NULL
WHERE industry = '';

UPDATE  layoff2 l1 
join layoff2 l2 
ON l1.company = l2.company 
SET l1.industry = l2.industry
WHERE  l1.industry IS NULL 
AND  l2.industry IS NOT NULL;

SELECT *
FROM layoff2 
WHERE industry IS NULL 
or industry = '';

SELECT * 
FROM layoff2 
WHERE company LIKE 'Bally%';

































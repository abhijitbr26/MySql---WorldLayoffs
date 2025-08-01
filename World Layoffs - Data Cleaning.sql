-- Data Cleaning

-- Step 1: Create a new database/schema - world_layoffs
-- Step 2: create tables by importing the data from a file
-- Step 3: Data Cleaning

select *
from world_layoffs.layoffs
;

-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Null values or Blank values
-- 4. Remove columns or rows

-- Creating a staging table and do all the cleaning activities
create table world_layoffs.layoffs_staging
like world_layoffs.layoffs;

insert world_layoffs.layoffs_staging
select *
from world_layoffs.layoffs
;

select *
from world_layoffs.layoffs_staging
;

-- 1. Remove Duplicates
with duplicate_cte as
(
	select 
		*
		,row_number() over(partition by company, location, industry, total_laid_off, 
        percentage_laid_off,`date`, stage, country, funds_raised_millions) as row_num
	from world_layoffs.layoffs_staging
)
select * from duplicate_cte where row_num > 1
;

select * from layoffs_staging where company = 'Casper';

-- Create another stageing table and delete the duplicate row
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
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoffs_staging2
	select 
		*
		,row_number() over(partition by company, location, industry, total_laid_off, 
        percentage_laid_off,`date`, stage, country, funds_raised_millions) as row_num
	from world_layoffs.layoffs_staging
;

select * from layoffs_staging2 where row_num > 1;

delete from layoffs_staging2 where row_num > 1;

-- 2. Standardize the data
select company, trim(company) from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select distinct industry, trim(industry) 
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where industry like ('Crypto%');

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%'
;

select distinct location, trim(location) 
from layoffs_staging2
order by 1;

select distinct country, trim(country) 
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where country like ('United States%');

select distinct country, trim(trailing '.' from country) 
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country) 
where country like 'United States%'
;

-- Change the data type of date column from text to date data type
select `date`
from layoffs_staging2;

select `date`, str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y')
;

alter table layoffs_staging2
modify column `date` date;

-- 3. Null values or Blank values
select *
from layoffs_staging2
where industry is null or industry = '';

select *
from layoffs_staging2
where company = 'Airbnb';

select *
from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
and t1.location = t2.location
where (t1.industry is null or t1.industry = '') and t2.industry is not null
;

update layoffs_staging2
set industry = null
where industry = ''
;

update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null and t2.industry is not null
;

-- 4. Remove columns or rows
-- Delete rows where total_laid_off and percentage_laid_off both are null
select *
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

delete
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

-- Removing columns
alter table layoffs_staging2
drop column row_num;

select * from layoffs_staging2;
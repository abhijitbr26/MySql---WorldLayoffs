-- Exploratory Data Analysis

select *
from layoffs_staging2
;

select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2
;

select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc
;

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc
;

select min(`date`), max(`date`)
from layoffs_staging2
;

select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc
;

select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc
;

select `date`, sum(total_laid_off)
from layoffs_staging2
group by `date`
order by 2 desc
;

select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 2 desc
;

select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc
;

-- Rolling total layoffs
select substring(`date`,6,2) as `month`, sum(total_laid_off)
from layoffs_staging2
group by `month`
order by `month`
;

select substring(`date`,1,7) as `month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by `month`
;

with rolling_total_cte as
(
	select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
	from layoffs_staging2
	where substring(`date`,1,7) is not null
	group by `month`
	order by `month`
)
select `month`, total_off, sum(total_off) over(order by `month`) as rolling_total
from rolling_total_cte
;

-- Company layoffs per year
select company, year(`date`) as `year`, sum(total_laid_off)
from layoffs_staging2
group by company, `year`
order by company, `year`
;

with company_year_cte(company, years, total_laid_off) as
(
	select company, year(`date`) as years, sum(total_laid_off)
	from layoffs_staging2
	group by company, years
),

company_year_rank_cte as
(
	select *, dense_rank() over(partition by years order by total_laid_off desc) as ranking
	from company_year_cte
	where years is not null
)
select * 
from company_year_rank_cte
where ranking <= 5
;
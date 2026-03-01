-- =====================================================
-- GLOBAL LAYOFFS ANALYSIS (SQL + Excel Project)
-- Dataset: layoffs_cleaned
-- =====================================================



-- =====================================================
-- SECTION 1: OVERALL LAYOFF IMPACT
-- =====================================================

-- Total Layoffs by Company
SELECT company, SUM(total_laid_off) AS total_layoffs
FROM layoffs_cleaned
GROUP BY company
ORDER BY total_layoffs DESC;


-- Total Layoffs by Industry
SELECT industry, SUM(total_laid_off) AS total_layoffs
FROM layoffs_cleaned
GROUP BY industry
ORDER BY total_layoffs DESC;


-- Total Layoffs by Funding Stage
SELECT stage, SUM(total_laid_off) AS total_layoffs
FROM layoffs_cleaned
GROUP BY stage
ORDER BY total_layoffs DESC;


-- Companies with 100% Workforce Layoffs
SELECT *
FROM layoffs_cleaned
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;



-- =====================================================
-- SECTION 2: TIME-BASED ANALYSIS
-- =====================================================

-- Yearly Layoff Trends
SELECT YEAR(`date`) AS year,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_cleaned
GROUP BY YEAR(`date`)
ORDER BY year;


-- Monthly Layoff Trends
SELECT substr(`date`,1,7) AS month,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_cleaned
WHERE substr(`date`,1,7) IS NOT NULL
GROUP BY month
ORDER BY month;


-- Rolling Cumulative Layoffs
WITH rolling_total AS 
(
SELECT substr(`date`,1,7) AS month,
       SUM(total_laid_off) AS total_off
FROM layoffs_cleaned
WHERE substr(`date`,1,7) IS NOT NULL
GROUP BY month
ORDER BY month
)
SELECT month,
       total_off,
       SUM(total_off) OVER(ORDER BY month) AS rolling_total
FROM rolling_total;



-- =====================================================
-- SECTION 3: RANKING & SEGMENTED ANALYSIS
-- =====================================================

-- Total Layoffs by Company Per Year
SELECT company,
       YEAR(`date`) AS year,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_cleaned
GROUP BY company, YEAR(`date`)
ORDER BY total_layoffs DESC;


-- Top 5 Companies by Layoffs Per Year
WITH company_year (company, years, total_laid_off) AS
(
SELECT company,
       YEAR(`date`) AS years,
       SUM(total_laid_off) AS total_laid_off
FROM layoffs_cleaned
GROUP BY company, YEAR(`date`)
),
company_year_rank AS 
(
SELECT *,
       DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <=5;


-- Average Layoff Percentage by Stage
SELECT stage,
       ROUND(AVG(percentage_laid_off),2) AS avg_layoff_percentage
FROM layoffs_cleaned
WHERE stage IS NOT NULL
GROUP BY stage
ORDER BY avg_layoff_percentage DESC;
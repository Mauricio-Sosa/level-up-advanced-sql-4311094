SELECT firstName, lastName, title
FROM employee 
LIMIT 5 
;

SELECT model, EngineType
FROM model
LIMIT 5
;

SELECT sql 
FROM sqlite_schema 
WHERE name = 'employee'
;

-- Challenge 1.1 Employees and Their Managers
SELECT * FROM employee;

SELECT e.firstName, e.lastName, em.firstName as mgr_firstName, em.lastName as mgr_lastName 
from employee e 
JOIN employee em on e.managerId = em.employeeId
;

-- Challenge 1.2 Salespeople with no Sales
SELECT * 
FROM employee e
LEFT OUTER JOIN sales s on e.employeeId = s.employeeId 
WHERE e.title = 'Sales Person' 
AND s.salesId is NULL 
-- notes from solution - best to not use select star, instead select specific columns
;

-- 1.3 All sales data and all customer data
SELECT c.customerId, c.firstName, c.lastName, s.soldDate, s.salesAmount 
FROM sales s 
FULL OUTER JOIN customer c on c.customerId = s.customerId
ORDER by c.firstName
-- notes from solutuion; they use unions due to sqlite not having full outer join (?),
-- also, they have fewer results because they didn't include union all and some customerids have the same names

;

-- 2.1 Number of cars sold by each employee

SELECT e.employeeId, e.firstName, e.lastName, count(s.salesId) as carsSold
FROM employee e 
LEFT OUTER JOIN sales s 
  ON e.employeeId = s.employeeId 
WHERE title = 'Sales Person'
GROUP BY e.employeeId, e.firstName, e.lastName
ORDER BY carsSold DESC
-- solution only wanted based on cars sold, not based on employee (inner join from sales)
;

-- 2.2 Cars sold with least and most expensive car sold by each employee this year
SELECT s.employeeId, e.firstName, e.lastName, min(s.salesAmount) as lowestPrice, max(s.salesAmount) highestPrice
FROM sales s
JOIN employee e ON e.employeeId = s.employeeId
WHERE soldDate >= date('now', '-999 day')
GROUP BY s.employeeId, e.firstName, e.lastName
-- solution seems to be tied to sqlite-specific date() function
;

-- 2.3 Same as above (2.2) but only employees with 5 or more sales
SELECT s.employeeId, e.firstName, e.lastName, min(s.salesAmount) as lowestPrice, max(s.salesAmount) highestPrice, count(*) as Sales
FROM sales s
JOIN employee e ON e.employeeId = s.employeeId
WHERE soldDate >= date('now', '-999 day')
GROUP BY s.employeeId, e.firstName, e.lastName
HAVING sales >= 5
-- solution seems to be tied to sqlite-specific date() function
;

-- 3.1 CTE for sales by year

with annualSales as (
SELECT strftime('%Y', soldDate) as year, count(*) as salesCount, sum(salesAmount) salesAmtSum
from sales
GROUP BY year
)
SELECT * 
FROM annualSales;

-- 3.2 Sales for each employee by month for 2021
--SELECT strftime('%m', soldDate) FROM sales;

SELECT 
  e.firstName,
  e.lastName,
  CASE WHEN strftime('%m', soldDate) = '01' THEN sum(s.salesAmount) Else 0 END as January,
  CASE WHEN strftime('%m', soldDate) = '02' THEN sum(s.salesAmount) Else 0 END as February,
  CASE WHEN strftime('%m', soldDate) = '03' THEN sum(s.salesAmount) Else 0 END as March,
  CASE WHEN strftime('%m', soldDate) = '04' THEN sum(s.salesAmount) Else 0 END as April,
  CASE WHEN strftime('%m', soldDate) = '05' THEN sum(s.salesAmount) Else 0 END as May,
  CASE WHEN strftime('%m', soldDate) = '06' THEN sum(s.salesAmount) Else 0 END as June,
  CASE WHEN strftime('%m', soldDate) = '07' THEN sum(s.salesAmount) Else 0 END as July,
  CASE WHEN strftime('%m', soldDate) = '08' THEN sum(s.salesAmount) Else 0 END as August,
  CASE WHEN strftime('%m', soldDate) = '09' THEN sum(s.salesAmount) Else 0 END as September,
  CASE WHEN strftime('%m', soldDate) = '10' THEN sum(s.salesAmount) Else 0 END as October,
  CASE WHEN strftime('%m', soldDate) = '11' THEN sum(s.salesAmount) Else 0 END as November,
  CASE WHEN strftime('%m', soldDate) = '12' THEN sum(s.salesAmount) Else 0 END as December
FROM sales s 
JOIN employee e on e.employeeId = s.employeeId 
WHERE strftime('%Y', soldDate) = '2021'
GROUP BY e.firstName, e.lastName
;

-- 3.3 Sales of electric cars, using a subquery
SELECT * 
FROM sales s 
WHERE 
  EXISTS (SELECT * 
            FROM inventory i 
            JOIN model m 
              ON m.modelId = i.modelId
              AND m.EngineType = 'Electric'
            WHERE i.inventoryId = s.inventoryId
          )
;

/* 4.1 Salespeople and cars they've sold the most */
SELECT e.firstName, e.lastName, m.model, count(m.model) as nbrSold, 
rank() OVER (PARTITION BY s.employeeId ORDER BY count(m.model) DESC) as Rank
FROM sales s 
JOIN employee e ON s.employeeId = e.employeeId
JOIN inventory i on s.inventoryId = i.inventoryId
JOIN model m ON i.modelId = m.modelId
GROUP BY e.firstName, e.lastName, m.model
;

-- 4.2 Sales per month and annual running total
WITH mSales AS (
SELECT 
strftime('%Y', soldDate) as Year, 
strftime('%m', soldDate) as Month,
sum(salesAmount) as monthlySales
FROM sales
GROUP BY Year, Month
ORDER BY Year, Month
) 
SELECT Year, Month, monthlySales,
sum(monthlySales) OVER (PARTITION BY Year ORDER By Year, Month) as annualRunningTotal 
FROM mSales
;

-- 4.3 Current and prior month cars sold

SELECT strftime('%Y-%m', soldDate) as month,
count(*) as monthlyCnt,
lag(count(*)) OVER (ORDER BY strftime('%Y-%m', soldDate)) as priorMonth
FROM sales 
GROUP BY month
ORDER BY month
;
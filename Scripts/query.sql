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
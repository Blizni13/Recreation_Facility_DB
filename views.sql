USE Projekt;

-- Sum of equipment prices from each room

IF OBJECT_ID('Sum of equipment prices') IS NOT NULL
	DROP VIEW [Sum of equipment prices];

GO

CREATE VIEW [Sum of equipment prices]
AS
SELECT F.Name, SUM(E.Price) AS [Sum] -- select the name and total amount
FROM 
Equipment AS E
INNER JOIN 
Facilities AS F
ON E.FacilityID = F.FacilityID -- join based on the facility where the equipment is located
GROUP BY F.Name -- group by facility name

GO

-- Number of leaves for each employee

IF OBJECT_ID('Number of employee leaves') IS NOT NULL
	DROP VIEW [Number of employee leaves]

GO

CREATE VIEW [Number of employee leaves]
AS
SELECT P.EmployeeID, P.Name, P.Surname, COUNT(EL.EmployeeID) AS [Number of leaves] -- selects employee ID, first name, last name, and number of leaves
FROM
Personel AS P
LEFT JOIN -- left join to match leaves to every employee, regardless of whether they have any or not
EmployeeLeaves AS EL
ON P.EmployeeID = EL.EmployeeID -- join tables based on employee ID
GROUP BY P.EmployeeID, P.Name, P.Surname

GO

-- Duration of cooperation with each company

IF OBJECT_ID('Duration of cooperation') IS NOT NULL
	DROP VIEW [Duration of cooperation];

GO

CREATE VIEW [Duration of cooperation]
AS 
SELECT CC.[Company Name], DATEDIFF(year, CC.[Beginning of Cooperation], GETDATE()) AS [Years of cooperation],
	   DATEDIFF(month, CC.[Beginning of Cooperation], GETDATE()) AS [Months of cooperation], 
	   DATEDIFF(day, CC.[Beginning of Cooperation], GETDATE() + 1) AS [Days of cooperation] -- add one to count days from the first day of cooperation
FROM CooperatingCompanies AS CC

GO

-- How many days paid vacations that started this year lasted and how much employees earned during them
-- employees on vacation earn 70% of their total salary (basic rate + bonus)

IF OBJECT_ID('Paid Vacations', 'V') IS NOT NULL
	DROP VIEW [Paid Vacations];
	
GO

CREATE VIEW [Paid Vacations]
AS
SELECT EmployeeID, 
	   SUM(DATEDIFF(day, EV.[Beginning Date], EV.[Ending Date]) + 1) AS [Days Amount], -- calculate the number of days
	   SUM(ROUND(dbo.DailySalary(EmployeeID) * 0.7 * (DATEDIFF(day, EV.[Beginning Date], EV.[Ending Date]) + 1), 2)) AS [Earned Money] -- calculate daily salary for each of the counted vacation days
FROM EmployeeVacations AS EV
WHERE YEAR(EV.[Beginning Date]) = YEAR(GETDATE()) AND EV.Paid = 'T' -- check if the vacation started this year and if it was paid
GROUP BY EmployeeID

GO

-- Calculate how much someone has worked and how much they earn (including bonuses)

IF OBJECT_ID('Current salary') IS NOT NULL
	DROP VIEW [Current salary];

GO

CREATE VIEW [Current salary]
AS -- selects employee ID, first name, last name, and basic rate + bonus found using the function
SELECT P.EmployeeID, P.Name, P.Surname, S.[Basic Salary] + dbo.FindBonus(P.EmployeeID) AS [Month salary]
FROM
Personel AS P
INNER JOIN
Salary AS S ON P.DepartmentID = S.DepartmentID -- join with salaries for individual departments to find the basic rate

GO

-- Number of dishes prepared by each chef during the current month

IF OBJECT_ID('Chefs Dishes', 'V') IS NOT NULL
	DROP VIEW [Chefs Dishes];

GO

CREATE VIEW [Chefs Dishes] AS
SELECT CookID, COUNT(*) AS [Dishes Amount] FROM Cafeteria -- selects chef ID and counts the number of prepared dishes
WHERE MONTH([Preparation Date]) = MONTH(GETDATE()) AND YEAR([Preparation Date]) = YEAR(GETDATE()) -- check if the preparation date matches the current month
GROUP BY CookID

GO

-- Summary of ticket prices purchased

IF OBJECT_ID('Tickets Summary', 'V') IS NOT NULL
	DROP VIEW [Tickets Summary];

GO

CREATE VIEW [Tickets Summary] AS
SELECT (CASE C.Sex WHEN 'F' THEN 'Female' ELSE 'Male' END) AS 'Sex', P.[Type of Pass], SUM(Price) AS [Summary Price] FROM -- CASE outputs the gender of the person
Customers AS C
INNER JOIN 
Passes AS P
ON C.PassID = P.PassID -- join customers with tickets based on purchased ticket ID
GROUP BY C.Sex, P.[Type of Pass]; -- group by gender and type of ticket

GO

-- List the 3 people who earned the most money in the last month (repetitions allowed)
-- we will use the previously created view that lists monthly revenue including bonuses for each employee

IF OBJECT_ID('Highest Revenue', 'V') IS NOT NULL 
	DROP VIEW [Highest Revenue];

GO

CREATE VIEW [Highest Revenue] AS
SELECT TOP 3 WITH TIES Name, Surname, [Month salary] FROM [Current salary] -- consider the situation where individuals earn the same amount of money
ORDER BY [Month salary] DESC

GO

-- How much one would have to pay to replace lost keys 
-- assuming the cost of making a key is 20 PLN, and the basic number of keys for each locker is 3

IF OBJECT_ID('Lost Keys Compensation', 'V') IS NOT NULL
	DROP VIEW [Lost Keys Compensation];

GO

CREATE VIEW [Lost Keys Compensation] AS
SELECT SUM(3 - Amount) * 20 AS [Summary price] FROM LockerKeys -- subtract the number of keys from 3 to obtain the number of lost keys, then multiply by 20 considering the price of each key
WHERE Amount < 3; -- only consider those with less than 3 keys

GO
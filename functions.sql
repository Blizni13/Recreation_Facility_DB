USE Projekt;

IF OBJECT_ID('CompanyStartingDate', 'FN') IS NOT NULL
	DROP FUNCTION CompanyStartingDate;
	
GO

-- Returns the date of employment of the first employee - we assume this is the date from which our company started to exist.

CREATE FUNCTION CompanyStartingDate()
RETURNS DATE
AS
BEGIN
RETURN (SELECT TOP 1 [Date Of Employment] FROM Personel ORDER BY [Date of Employment] ASC)
END

GO

IF OBJECT_ID('YearsOfExperience', 'FN') IS NOT NULL
	DROP FUNCTION YearsOfExperience;

GO

-- Calculates the number of years worked by an employee.

CREATE FUNCTION YearsOfExperience(@EmployeeID INT)
RETURNS INT
AS
BEGIN

-- Adds one to GETDATE() to count the number of days of experience including the first day of work
RETURN (SELECT (DATEDIFF(day, P.[Date of Employment], GETDATE()) + 1) / 365 FROM Personel AS P WHERE EmployeeID = @EmployeeID); 
END

GO

IF OBJECT_ID('FindBonus', 'FN') IS NOT NULL
	DROP FUNCTION FindBonus;
	
GO

-- Finds the bonus entitled to an employee for years of experience.

CREATE FUNCTION FindBonus(@EmployeeID INT)
RETURNS FLOAT
AS
BEGIN

DECLARE @yearsOfExperience INT = dbo.YearsOfExperience(@EmployeeID);
DECLARE @departmentID INT = (SELECT DepartmentID FROM Personel WHERE EmployeeID = @EmployeeID); -- Find the department to know which bonuses to consider
-- Find the bonus by sorting years from highest to lowest starting from the first bonus less than the employee's years of experience
-- Then select the first record that informs about the bonus entitled to the employee
DECLARE @bonus FLOAT = ISNULL((SELECT TOP 1 Bonus FROM Bonuses WHERE (DepartmentID = @departmentID) AND (Years <= @yearsOfExperience) ORDER BY Years DESC), 0); -- Check if it's NULL, because the person may not have enough years of experience to receive any bonus

RETURN @bonus
END

GO

IF OBJECT_ID('DailySalary', 'FN') IS NOT NULL
	DROP FUNCTION DailySalary;

GO

-- Calculates the daily rate entitled to an employee.

CREATE FUNCTION DailySalary (@EmployeeID INT)
RETURNS FLOAT
AS
BEGIN

DECLARE @basicSalary FLOAT; -- Basic rate
DECLARE @bonus FLOAT; -- Bonus entitled to the employee

-- Calculate the basic rate for this employee
SET @basicSalary = (SELECT S.[Basic Salary] FROM Personel AS P INNER JOIN Salary AS S ON P.DepartmentID = S.DepartmentID WHERE EmployeeID = @EmployeeID);
-- Calculate the bonus for this employee
SET @bonus = dbo.FindBonus(@EmployeeID);

RETURN ROUND((@basicSalary + @bonus) / 30, 2); -- Simplify the daily rate by dividing the total by 30, to avoid averaging all month's days
END

GO

-- Function to check the existence of a budget for the current year and month, returns 1 if the budget exists, and 0 otherwise.

IF OBJECT_ID('CheckBudgetExistence', 'FN') IS NOT NULL
	DROP FUNCTION CheckBudgetExistence;

GO

CREATE FUNCTION CheckBudgetExistence()
RETURNS TINYINT
AS
BEGIN
-- Counts the number of rows in the budget, if there is a budget for this year and month, it will obviously return a row count of 1, if not, it will return a value of 0
RETURN (SELECT COUNT(*) FROM Budget AS B WHERE B.Year = YEAR(GETDATE()) AND B.Month = MONTH(GETDATE()))
END

GO

IF OBJECT_ID('CalculateReservationPrice', 'FN') IS NOT NULL
	DROP FUNCTION CalculateReservationPrice;

GO

-- This function is used to calculate the reservation price for a given object for a given number of hours.

CREATE FUNCTION CalculateReservationPrice(@facilityID INT, @hours INT)
RETURNS FLOAT
AS
BEGIN
RETURN ((SELECT [Price per hour] FROM ReservationsPrice AS RP WHERE RP.FacilityID = @facilityID) * @hours) -- Select the reservation price and multiply by the number of hours
END

GO
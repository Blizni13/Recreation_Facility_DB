USE Projekt;

-- Procedures

-- Procedure that counts the company's expenses and revenues from the date provided as an argument

IF OBJECT_ID('Calculate Budget', 'P') IS NOT NULL
	DROP PROCEDURE [Calculate Budget];
	
GO

CREATE PROCEDURE [Calculate Budget](@startingDate DATE = '1753-01-01', @endingDate DATE = '9999-12-31') -- '1753-01-01' is the earliest starting date in SQL
AS
BEGIN

IF @endingDate = '9999-12-31' -- let's check if the value is equal to the default argument value
	SET @endingDate = GETDATE(); -- set the value to today's date

DECLARE @startingYear INT = YEAR(@startingDate);
DECLARE @startingMonth INT = MONTH(@startingDate);
DECLARE @endingYear INT = YEAR(@endingDate);
DECLARE @endingMonth INT = MONTH(@endingDate);

-- when we provide dates that are in the middle of the months for budget data,
-- it counts the budget from the beginning of the given month in the starting date to the end of the given month in the ending date

DECLARE @summaryProfit FLOAT = (

SELECT SUM(Profit) FROM Budget AS B
WHERE
( -- case 1 - the given years are the same, so we start from the month of the starting date and end at the month of the ending date
	(@startingYear = @endingYear) 
	AND 
	(B.Year = @startingYear) AND (B.Month >= @startingMonth) AND (B.Month <= @endingMonth)
)
OR
( -- case 2 - the given years are different, so we need to break it into 3 parts: 1) starting year from the starting month, 2) all months in between the years, 3) ending year to the ending month
		(@startingYear <> @endingYear) 
		AND 
		(
			(B.Year = @startingYear AND B.Month >= @startingMonth) -- case 1)
			OR
			(B.Year > @startingYear AND B.Year < @endingYear) -- case 2)
			OR
			(B.Year = @endingYear AND B.Month <= @endingMonth) -- case 3)
		)
)	

)

DECLARE @summaryExpenses FLOAT = ( -- we calculate similarly to the above budget

SELECT SUM(Expenses) FROM Budget AS B
WHERE
(
	(@startingYear = @endingYear) 
	AND 
	(B.Year = @startingYear) AND (B.Month >= @startingMonth) AND (B.Month <= @endingMonth)
)
OR
(
		(@startingYear <> @endingYear) 
		AND 
		(
			(B.Year = @startingYear AND B.Month >= @startingMonth)
			OR
			(B.Year > @startingYear AND B.Year < @endingYear)
			OR
			(B.Year = @endingYear AND B.Month <= @endingMonth)
		)
)	

)
								 
-- when we do not receive any input arguments, we calculate values from the moment the company was founded
-- we use the CompanyStartingDate() function, which returns the date of the company's start
SELECT (CASE @startingDate WHEN '1753-01-01' THEN dbo.CompanyStartingDate() ELSE @startingDate END) AS [Starting Date], @endingDate AS [Ending Date], @summaryProfit AS [Summary Profit], @summaryExpenses AS [Summary Expenses] 

END

GO

-- Procedure that fills the number of all keys to their initial values

IF OBJECT_ID('Completing Lost Keys', 'P') IS NOT NULL
	DROP PROCEDURE [Completing Lost Keys];

GO

CREATE PROCEDURE [Completing Lost Keys]
AS
BEGIN

DECLARE @cost FLOAT = (SELECT [Summary price] FROM [Lost Keys Compensation]); -- we calculate the cost using a previously prepared view

-- we add costs to the budget

UPDATE Budget
SET Expenses += @cost;

-- we complete all keys to 3

UPDATE LockerKeys
SET Amount = 3
WHERE Amount < 3;

END

GO

IF OBJECT_ID('Real Incomes', 'P') IS NOT NULL
	DROP PROCEDURE [Real Incomes];

GO

-- procedure that calculates "real" incomes for a given month and year, i.e., subtracts total expenses from total revenues

CREATE PROCEDURE [Real Incomes](@year INT, @month INT)
AS 
BEGIN

DECLARE @wholeProfit FLOAT = (SELECT Profit FROM Budget AS B WHERE B.Year = @year AND B.Month = @month);
DECLARE @wholeExpenses FLOAT = (SELECT Expenses FROM Budget AS B WHERE B.Year = @year AND B.Month = @month);

SELECT (@wholeProfit - @wholeExpenses) AS [Real income];

END

GO

IF OBJECT_ID('Change Tickets Cost', 'P') IS NOT NULL
	DROP PROCEDURE [Change Tickets Cost];

GO

-- Changes the ticket prices by a percentage given in the first argument. The first argument is provided as 0.xy.
-- The second argument can take two possible values: 'O' or 'P', where O - decrease, P - increase. We use it to determine whether we want to lower or raise ticket prices.
-- The third argument indicates the type of ticket whose price we want to change.

CREATE PROCEDURE [Change Tickets Cost](@percentageValue FLOAT, @changeType CHAR(1), @passType NVARCHAR(32) = NULL)
AS
BEGIN

IF @changeType NOT IN ('O', 'P') -- we provided an invalid way to change the ticket price
	RAISERROR('Invalid way to change the ticket price', 16, 1);

IF (@passType IS NOT NULL) AND (@passType NOT IN (SELECT P.[Type of Pass] FROM Passes AS P)) -- we provided an invalid ticket type
	RAISERROR('Invalid ticket type', 16, 1);

IF @passType IS NULL -- if the ticket type is not provided, we change the price of every type of ticket by the percentage given in the first argument.
	BEGIN
		IF @changeType = 'O' -- we decrease the price
			UPDATE Passes
			SET Price -= (Price * @percentageValue)
		ELSE -- we increase the price
			UPDATE Passes
			SET Price += (Price * @percentageValue)
	END
ELSE -- we change the ticket price of the type specified by the argument
	BEGIN
		IF @changeType = 'O' -- we decrease the price
			UPDATE Passes
			SET Price -= (Price * @percentageValue)
			WHERE [Type of Pass] = @passType;
		ELSE -- we increase the price
			UPDATE Passes
			SET Price += (Price * @percentageValue)
			WHERE [Type of Pass] = @passType;
	END
END

GO

IF OBJECT_ID('Equipment Overview', 'P') IS NOT NULL
	DROP PROCEDURE [Equipment Overview];
	
-- Procedure responsible for the equipment overview, adds inspection costs to the budget
-- the cost of inspecting individual equipment items is 1% of the price of that equipment item
-- inspection can take place for a specific facility, or if the argument is not provided, it takes place for each facility

GO

CREATE PROCEDURE [Equipment Overview](@FacilityID INT = NULL)
AS
BEGIN

-- if the argument is not provided, the result of the WHERE clause for each record will be TRUE (FacilityID = FacilityID),
-- otherwise, we look for those facilityID that are equal to the provided argument (FacilityID = @FacilityID)
DECLARE @costs FLOAT = (SELECT SUM(0.01 * Price) FROM Equipment WHERE FacilityID = ISNULL(@FacilityID, FacilityID)) 

IF (dbo.CheckBudgetExistence() = 0) -- if the budget for the current date does not exist
	INSERT INTO Budget VALUES
	(YEAR(GETDATE()), MONTH(GETDATE()), 0, 0);

UPDATE Budget
SET Expenses = Expenses + @costs
WHERE Year = YEAR(GETDATE()) AND Month = MONTH(GETDATE())

END

GO
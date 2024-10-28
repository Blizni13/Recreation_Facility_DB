USE Projekt;

-- Triggers

IF OBJECT_ID('tr_instead_of_insert_Budget', 'TR') IS NOT NULL
    DROP TRIGGER tr_instead_of_insert_Budget;

GO

-- Trigger that performs operations instead of the insert operation. When adding new budget data for the current month,
-- we should automatically account for taxes that need to be paid and payouts due to employees.

CREATE TRIGGER tr_instead_of_insert_Budget
ON Budget
INSTEAD OF INSERT
AS
BEGIN

DECLARE @payouts FLOAT = (SELECT SUM([Month salary]) FROM [Current salary]); -- calculate payouts for all employees using the view calculating the base rate and bonus for a given employee
DECLARE @fees FLOAT = (SELECT SUM(Price) FROM Fees); -- calculate all taxes the company pays monthly

-- when adding a row to the budget for a new year and month, we need to include employee payouts and taxes
-- we only add one row for a given year and month, so we check if it already exists

IF (dbo.CheckBudgetExistence() = 0)
    INSERT INTO Budget
    SELECT I.Year, I.Month, I.Profit, (@payouts + @fees) FROM inserted AS I 
END

GO

IF OBJECT_ID('tr_after_update_Fees', 'TR') IS NOT NULL
    DROP TRIGGER tr_after_update_Fees;

GO

CREATE TRIGGER tr_after_update_Fees
ON Fees
AFTER UPDATE 
AS
BEGIN

-- calculate the previous total of all taxes
DECLARE @previousSum FLOAT;
SET @previousSum = (SELECT SUM(Price) FROM deleted) + (SELECT SUM(Price) FROM Fees AS F WHERE F.Type NOT IN (SELECT D.Type FROM deleted AS D)); -- sum those that were changed (old versions) and those that remain unchanged (from the Fees table)

DECLARE @newSum FLOAT = (SELECT SUM(Price) FROM Fees); -- calculate the new price after changes

IF (dbo.CheckBudgetExistence() = 1) -- check if we already have such a record in our budget
    UPDATE Budget
    SET Expenses = Expenses - @previousSum + @newSum -- subtract the previous taxes and add the new ones
    WHERE Year = YEAR(GETDATE()) AND Month = MONTH(GETDATE());
ELSE -- if such a record does not exist in our budget, we insert it
    INSERT INTO Budget VALUES
    (YEAR(GETDATE()), MONTH(GETDATE()), 0, 0)
END

GO

IF OBJECT_ID('tr_after_insert_Cafeteria', 'TR') IS NOT NULL
    DROP TRIGGER tr_after_insert_Cafeteria;

GO

-- when adding an order to the cafeteria, we should account for additional income in the budget

CREATE TRIGGER tr_after_insert_Cafeteria
ON Cafeteria
AFTER INSERT
AS
BEGIN

DECLARE @sum FLOAT = (SELECT SUM(Price) FROM inserted);

IF (dbo.CheckBudgetExistence() = 1) -- check if we already have such a record in our budget
    UPDATE Budget
    SET Profit += @sum
    WHERE Year = YEAR(GETDATE()) AND Month = MONTH(GETDATE());
ELSE -- if such a record does not exist in our budget, we insert it
    INSERT INTO Budget VALUES
    (YEAR(GETDATE()), MONTH(GETDATE()), @sum, 0)    

END

GO

IF OBJECT_ID('tr_after_delete_Cafeteria', 'TR') IS NOT NULL
    DROP TRIGGER tr_after_delete_Cafeteria;

GO

-- When an order for a given product is canceled, we should be able to reverse the budget changes made by the order

CREATE TRIGGER tr_after_delete_Cafeteria
ON Cafeteria
AFTER DELETE
AS
BEGIN

DECLARE @sum FLOAT = (SELECT SUM(Price) FROM deleted); -- find the price of the orders that were canceled

-- since orders on a given day have been deleted, it means the budget must already exist

UPDATE Budget
SET Profit -= @sum
WHERE YEAR = YEAR(GETDATE()) AND MONTH = MONTH(GETDATE()) -- it makes sense to cancel only those dishes that were ordered today

END

GO

IF OBJECT_ID('tr_budget_after_insert_Customers', 'TR') IS NOT NULL
    DROP TRIGGER tr_budget_after_insert_Customers;

GO

-- this trigger is used when adding a new customer. We must then ensure the correctness of data in the budget, so we include new income.

CREATE TRIGGER tr_budget_after_insert_Customers
ON Customers
AFTER INSERT
AS
BEGIN

DECLARE @sum FLOAT = (SELECT SUM(Price) FROM inserted AS I INNER JOIN Passes AS P ON I.PassID = P.PassID); -- find the prices of tickets purchased by customers

IF (dbo.CheckBudgetExistence() = 1) -- check if we already have such a record in our budget
    UPDATE Budget
    SET Profit += @sum
    WHERE YEAR = YEAR(GETDATE()) AND MONTH = MONTH(GETDATE())
ELSE
    INSERT INTO Budget VALUES
    (YEAR(GETDATE()), MONTH(GETDATE()), @sum, 0)
END

GO

IF OBJECT_ID('tr_facilities_after_insert_Customers', 'TR') IS NOT NULL
    DROP TRIGGER tr_facilities_after_insert_Customers;

GO

-- After adding a new customer, we should update the number of all customers currently using our services

CREATE TRIGGER tr_facilities_after_insert_Customers
ON Customers
AFTER INSERT
AS
BEGIN

DECLARE @newCustomersAmount INT = (SELECT COUNT(*) FROM inserted); -- count the number of new customers

-- update the total number of customers in the Facilities table

UPDATE Facilities
SET [Number of Customers] += @newCustomersAmount; 

END

GO

IF OBJECT_ID('tr_facilities_after_delete_Customers', 'TR') IS NOT NULL
    DROP TRIGGER tr_facilities_after_delete_Customers;

GO

-- After deleting a customer, we should update the number of all customers currently using our services

CREATE TRIGGER tr_facilities_after_delete_Customers
ON Customers
AFTER DELETE
AS
BEGIN

DECLARE @deletedCustomersAmount INT = (SELECT COUNT(*) FROM deleted); -- count the number of deleted customers

-- update the total number of customers in the Facilities table

UPDATE Facilities
SET [Number of Customers] -= @deletedCustomersAmount; 

END

GO

IF OBJECT_ID('tr_facilities_after_insert_Personel', 'TR') IS NOT NULL
    DROP TRIGGER tr_facilities_after_insert_Personel;

GO

-- After adding new employee(s), we should update their count in the Facilities table

CREATE TRIGGER tr_facilities_after_insert_Personel
ON Personel
AFTER INSERT
AS
BEGIN

-- count how many employees have been added to work at a given facility and increase their number

UPDATE Facilities 
SET [Number of Employees] += (SELECT COUNT(*) FROM inserted AS I WHERE I.FacilityID = Facilities.FacilityID)

END

GO

IF OBJECT_ID('tr_facilities_after_delete_Personel', 'TR') IS NOT NULL
    DROP TRIGGER tr_facilities_after_delete_Personel;

GO

-- After deleting employee(s), we should update their count in the Facilities table

CREATE TRIGGER tr_facilities_after_delete_Personel
ON Personel
AFTER DELETE
AS
BEGIN

-- subtract the number of employees from the respective facilities

UPDATE Facilities
SET [Number of Employees] -= (SELECT COUNT(*) FROM deleted AS D WHERE D.FacilityID = Facilities.FacilityID);

END

GO

IF OBJECT_ID('tr_facilities_after_insert_Equipment', 'TR') IS NOT NULL
    DROP TRIGGER tr_facilities_after_insert_Equipment;

GO

-- After adding new equipment, we should update the quantity in the Facilities table

CREATE TRIGGER tr_facilities_after_insert_Equipment
ON Equipment
AFTER INSERT
AS
BEGIN

-- count how much equipment has been added to the respective facilities and update the data

UPDATE Facilities 
SET [Number of Equipment] += (SELECT COUNT(*) FROM inserted AS I WHERE I.FacilityID = Facilities.FacilityID)

END

GO

IF OBJECT_ID('tr_facilities_after_delete_Equipment', 'TR') IS NOT NULL
    DROP TRIGGER tr_facilities_after_delete_Equipment;

GO

-- After deleting equipment, we should update the quantity in the Facilities table

CREATE TRIGGER tr_facilities_after_delete_Equipment
ON Equipment
AFTER DELETE
AS
BEGIN

-- subtract the quantity of equipment from the respective facilities

UPDATE Facilities
SET [Number of Equipment] -= (SELECT COUNT(*) FROM deleted AS D WHERE D.FacilityID = Facilities.FacilityID);

END

GO

IF OBJECT_ID('tr_instead_of_insert_Reservations', 'TR') IS NOT NULL
    DROP TRIGGER tr_instead_of_insert_Reservations;

GO

-- trigger to insert the added reservation
-- internal assumption - the reservation cannot be shorter than one hour

CREATE TRIGGER tr_instead_of_insert_Reservations
ON Reservations
INSTEAD OF INSERT
AS
BEGIN

-- check if the reservation is shorter than one hour

IF EXISTS (SELECT * FROM inserted AS I WHERE DATEDIFF(HOUR, I.StartingTime, I.EndingTime) = 0)
    RAISERROR('Reservation for an insufficient number of hours.', 16, 1)

-- check if the provided reservation times make sense

IF EXISTS (SELECT StartingTime, EndingTime FROM inserted WHERE StartingTime > EndingTime) -- in the case of equality, the sense of such a reservation would also be highly limited
    RAISERROR('Reservation times are invalid.', 16, 1)
ELSE 

-- check if the date of the given reservation is already booked
-- check if the starting/ending time of the reservation overlaps with invalid hours of existing reservations

IF EXISTS ( SELECT * FROM Reservations AS R INNER JOIN inserted AS I ON R.FacilityID = I.FacilityID WHERE (R.Date = I.Date) AND ((I.StartingTime >= R.StartingTime AND I.StartingTime <= R.EndingTime) OR (I.EndingTime >= R.StartingTime)))
	RAISERROR('The reservation for the given date conflicts with an existing reservation.', 16, 1);
ELSE
	BEGIN

		-- calculate the price of the reservation and add it to the budget
		-- the CalculateReservationPrice function calculates the reservation price based on the pricing list and number of hours

		DECLARE @summaryProfit FLOAT = (SELECT SUM(dbo.CalculateReservationPrice(I.FacilityID, DATEDIFF(HOUR, I.StartingTime, I.EndingTime))) FROM inserted AS I)
		
		IF (dbo.CheckBudgetExistence() = 0) -- if the budget does not exist, we add the appropriate row
			INSERT INTO Budget VALUES
			(YEAR(GETDATE()), MONTH(GETDATE()), @summaryProfit, 0) -- revenue from reservations is recorded in the current budget, regardless of the reservation date
		ELSE
			UPDATE Budget 
			SET Profit += @summaryProfit
			WHERE Year = YEAR(GETDATE()) AND Month = MONTH(GETDATE())

		-- save the reservation

		INSERT INTO Reservations
		SELECT * FROM inserted;

	END

END

GO
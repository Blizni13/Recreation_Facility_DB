USE Projekt;

IF OBJECT_ID('Equipment', 'U') IS NOT NULL 
	DROP TABLE Equipment;
	
IF OBJECT_ID('CooperatingCompanies', 'U') IS NOT NULL
	DROP TABLE CooperatingCompanies;
	
IF OBJECT_ID('Bonuses', 'U') IS NOT NULL
	DROP TABLE Bonuses;

IF OBJECT_ID('EmployeeLeaves', 'U') IS NOT NULL
	DROP TABLE EmployeeLeaves;
	
IF OBJECT_ID('EmployeeVacations', 'U') IS NOT NULL
	DROP TABLE EmployeeVacations;
	
IF OBJECT_ID('Cafeteria', 'U') IS NOT NULL
	DROP TABLE Cafeteria;

IF OBJECT_ID('CafeteriaProducts', 'U') IS NOT NULL
	DROP TABLE CafeteriaProducts;

IF OBJECT_ID('Personel', 'U') IS NOT NULL
	DROP TABLE Personel;

IF OBJECT_ID('Salary', 'U') IS NOT NULL
	DROP TABLE Salary;

IF OBJECT_ID('Departments', 'U') IS NOT NULL
	DROP TABLE Departments;

IF OBJECT_ID('Lockers', 'U') IS NOT NULL
	DROP TABLE Lockers;

IF OBJECT_ID('LockerKeys', 'U') IS NOT NULL
	DROP TABLE LockerKeys;

IF OBJECT_ID('LockerRooms', 'U') IS NOT NULL
	DROP TABLE LockerRooms;

IF OBJECT_ID('Customers', 'U') IS NOT NULL
	DROP TABLE Customers;

IF OBJECT_ID('Passes', 'U') IS NOT NULL
	DROP TABLE Passes;
	
IF OBJECT_ID('Facilities', 'U') IS NOT NULL
	DROP TABLE Facilities;

IF OBJECT_ID('Reservations', 'U') IS NOT NULL
	DROP TABLE Reservations;

IF OBJECT_ID('ReservationsPrice', 'U') IS NOT NULL
	DROP TABLE ReservationsPrice;

GO

CREATE TABLE Facilities 
(
FacilityID INT PRIMARY KEY,
Name VARCHAR(30),
[Number of Customers] SMALLINT,
[Number of Employees] SMALLINT,
[Number of Equipment] SMALLINT
)

INSERT INTO Facilities VALUES
(1, 'Aquapark', 0, 0, 0),
(2, 'SPA', 0, 0, 0),
(3, 'Fitness Club', 0, 0, 0)

CREATE TABLE Equipment
(
FacilityID INT CONSTRAINT [Equipment Foreign Key] REFERENCES Facilities(FacilityID),
[Element of Equipment] VARCHAR(50),
Price MONEY,
PRIMARY KEY (FacilityID, [Element of Equipment])
)

INSERT INTO Equipment VALUES
(3, '£aweczka pozioma', 1000),
(3, 'Maszyna wyci¹gu górnego', 2000),
(3, 'Stanowisko do przysiadów/martwego ci¹gu', 10000),
(3, 'Hantle (przedzia³ ciê¿aru 2-50)', 10000),
(3, 'Suwnica do czworog³owych uda', 12000),
(3, 'Maszyna do dwug³owych uda', 6000),
(3, 'Atlas do æwiczeñ ogólnych', 3000),
(3, 'Dr¹¿ek (chwyt neutralny, nachwyt, podchwyt)', 500),
(3, 'Bie¿nia', 3000),
(3, 'Rowerek stacjonarny', 1000),
(1, 'Zje¿d¿alnia', 10000),
(1, 'Basen z falami', 15000),
(1, 'Basen dla dzieci', 5000),
(1, 'Jacuzzi', 8000),
(1, 'Sauna sucha', 6000),
(1, 'Sauna parowa', 7000),
(2, 'Strefa relaksu', 5000),
(2, 'Pokoje VIP', 20000),
(2, 'Produkty do masa¿u relaksacyjnego', 3000),
(2, 'Produkty do masa¿u leczniczego', 3500),
(2, 'Produkty do zabiegów na twarz', 2500),
(2, 'Produkty do zabiegów na cia³o', 3000),
(2, 'Produkty do manicure', 1500),
(2, 'Produkty do pedicure', 2000),
(2, 'Sprzêt do hydromasa¿u', 3500);

CREATE TABLE CooperatingCompanies 
(
CompanyID INT,
[Company Name] NVARCHAR(100),
FacilityID INT CONSTRAINT [Cooperating Companies Foreign Key] REFERENCES Facilities(FacilityID),
[Beginning of Cooperation] DATE,
PRIMARY KEY (CompanyID, FacilityID)
)

INSERT INTO CooperatingCompanies VALUES 
(1, 'Aquaventure', 1, '2010-02-01'),
(2, 'Water World', 1, '2013-05-01'),
(3, 'Power House', 3, '2020-11-01'),
(4, 'Body Works', 3, '2015-06-01'),
(5, 'Autokomis Radzionków', 1, '2008-04-01'),
(6, 'Relaxia', 2, '2018-12-31')
	
CREATE TABLE Passes
(
PassID INT PRIMARY KEY,
[Type of Pass] VARCHAR(50),
Price MONEY,
[PassDuration (Days)] TINYINT
)

INSERT INTO Passes VALUES
(1, 'jednorazowy', 50, 1),
(2, 'zwyk³y', 269, 28),
(3, 'ulgowy', 239, 28),
(4, 'miesiêczny poranny', 200, 28),
(5, 'grupowy', 150, 28)

CREATE TABLE Customers 
(
CustomerID INT PRIMARY KEY IDENTITY(1,1),
[First Name] NVARCHAR(100),
Surname NVARCHAR(100),
Sex CHAR(1),
PassID INT CONSTRAINT [Customers-PassID_Passes-PassID] REFERENCES Passes(PassID)
)

INSERT INTO Customers VALUES
('Andrzej', 'Dziwisz', 'M', 1),
('Karolina', 'dŸb³o', 'F', 1),
('Marcin', 'Domañski', 'M', 2),
('Kacper', 'B¹kiewicz', 'M', 2),
('Andrzej', 'Grabowski', 'M', 2),
('Józef', 'Piotrkiewicz', 'M', 2),
('Anna', '¯urkowska', 'F', 3),
('Grzegorz', 'Brzêczyszczykiewicz', 'M', 2),
('Patryk', 'Cpa³ka', 'M', 3),
('Karolina', 'JóŸwiak', 'F', 2),
('Patrycja', 'Jurkiewicz', 'F', 3),
('Marian', 'Poznañski', 'M', 2),
('Piotr', 'Pyrka', 'M', 2),
('Sylvester', 'Stalone', 'M', 3),
('Harrison', 'Ford', 'M', 2),
('Leonhard', 'Euler', 'M', 2),
('Miroslaw', 'S³owiñski', 'M', 2),
('Hanna', 'Markiewicz', 'F', 2),
('Paulina', 'Sopoæko', 'F', 2),
('Andrzej', 'Dziwisz', 'M', 1),
('Karolina', 'dŸb³o', 'F', 1),
('Marcin', 'Domañski', 'M', 2),
('Kacper', 'B¹kiewicz', 'M', 2),
('Andrzej', 'Grabowski', 'M', 2),
('Józef', 'Piotrkiewicz', 'M', 2),
('Anna', '¯urkowska', 'F', 3),
('Grzegorz', 'Brzêczyszczykiewicz', 'M', 2),
('Patryk', 'Cpa³ka', 'M', 3),
('Karolina', 'JóŸwiak', 'F', 2),
('Patrycja', 'Jurkiewicz', 'F', 3),
('Marian', 'Poznañski', 'M', 2),
('Piotr', 'Pyrka', 'M', 2),
('Sylvester', 'Stalone', 'M', 3),
('Harrison', 'Ford', 'M', 2),
('Leonhard', 'Euler', 'M', 2),
('Miroslaw', 'S³owiñski', 'M', 2),
('Hanna', 'Markiewicz', 'F', 2),
('Paulina', 'Sopoæko', 'F', 2),
('Andrzej', 'Dziwisz', 'M', 1),
('Karolina', 'dŸb³o', 'F', 1),
('Marcin', 'Domañski', 'M', 2),
('Kacper', 'B¹kiewicz', 'M', 2),
('Andrzej', 'Grabowski', 'M', 2),
('Józef', 'Piotrkiewicz', 'M', 2),
('Anna', '¯urkowska', 'F', 3),
('Grzegorz', 'Brzêczyszczykiewicz', 'M', 2),
('Patryk', 'Cpa³ka', 'M', 3),
('Karolina', 'JóŸwiak', 'F', 2),
('Patrycja', 'Jurkiewicz', 'F', 3),
('Marian', 'Poznañski', 'M', 2),
('Piotr', 'Pyrka', 'M', 2),
('Sylvester', 'Stalone', 'M', 3),
('Harrison', 'Ford', 'M', 2),
('Leonhard', 'Euler', 'M', 2),
('Miroslaw', 'S³owiñski', 'M', 2),
('Hanna', 'Markiewicz', 'F', 2),
('Paulina', 'Sopoæko', 'F', 2),
('Andrzej', 'Dziwisz', 'M', 1),
('Karolina', 'dŸb³o', 'F', 1),
('Marcin', 'Domañski', 'M', 2),
('Kacper', 'B¹kiewicz', 'M', 2),
('Andrzej', 'Grabowski', 'M', 2),
('Józef', 'Piotrkiewicz', 'M', 2),
('Anna', '¯urkowska', 'F', 3),
('Marian', 'Poznañski', 'M', 2),
('Piotr', 'Pyrka', 'M', 2),
('Sylvester', 'Stalone', 'M', 3),
('Harrison', 'Ford', 'M', 2),
('Leonhard', 'Euler', 'M', 2),
('Miroslaw', 'S³owiñski', 'M', 2),
('Hanna', 'Markiewicz', 'F', 2),
('Paulina', 'Sopoæko', 'F', 2),
('Andrzej', 'Dziwisz', 'M', 1),
('Karolina', 'dŸb³o', 'F', 1),
('Marcin', 'Domañski', 'M', 2),
('Kacper', 'B¹kiewicz', 'M', 2),
('Andrzej', 'Grabowski', 'M', 2),
('Józef', 'Piotrkiewicz', 'M', 2),
('Anna', '¯urkowska', 'F', 3),
('Grzegorz', 'Brzêczyszczykiewicz', 'M', 2),
('Patryk', 'Cpa³ka', 'M', 3),
('Karolina', 'JóŸwiak', 'F', 2),
('Patrycja', 'Jurkiewicz', 'F', 3),
('Marian', 'Poznañski', 'M', 2),
('Piotr', 'Pyrka', 'M', 2),
('Sylvester', 'Stalone', 'M', 3),
('Harrison', 'Ford', 'M', 2),
('Leonhard', 'Euler', 'M', 2),
('Miroslaw', 'S³owiñski', 'M', 2),
('Hanna', 'Markiewicz', 'F', 2),
('Paulina', 'Sopoæko', 'F', 2),
('Andrzej', 'Dziwisz', 'M', 1),
('Karolina', 'dŸb³o', 'F', 1),
('Marcin', 'Domañski', 'M', 2),
('Kacper', 'B¹kiewicz', 'M', 2),
('Andrzej', 'Grabowski', 'M', 2),
('Józef', 'Piotrkiewicz', 'M', 2),
('Anna', '¯urkowska', 'F', 3)

CREATE TABLE LockerRooms
(
RoomID INT,
Sex CHAR(1),
FacilityID INT CONSTRAINT [LockerRooms-FacilityID_Facilities-FacilityID] REFERENCES Facilities(FacilityID)
PRIMARY KEY(RoomID, Sex, FacilityID)
)

INSERT INTO LockerRooms VALUES
(1, 'M', 1),
(2, 'M', 1),
(1, 'F', 1),
(2, 'F', 1),
(1, 'M', 2),
(2, 'M', 2),
(3, 'M', 2),
(4, 'M', 2),
(1, 'F', 2),
(2, 'F', 2),
(3, 'F', 2),
(4, 'F', 2),
(1, 'M', 3),
(2, 'M', 3),
(3, 'M', 3),
(1, 'F', 3),
(2, 'F', 3),
(3, 'F', 3)

CREATE TABLE LockerKeys
(
KeyID INT PRIMARY KEY,
Occupied CHAR(1),
Amount TINYINT,
CONSTRAINT [Amount of Keys] CHECK (Amount >= 0 AND Amount <= 3)
)

INSERT INTO LockerKeys VALUES -- max amount of keys: 3
(1, 'T', 2),
(2, 'F', 1),
(3, 'F', 1),
(4, 'T', 1),
(5, 'F', 3),
(6, 'T', 0),
(7, 'F', 3),
(8, 'T', 2),
(9, 'T', 1),
(10, 'T', 2),
(11, 'T', 1),
(12, 'T', 2),
(13, 'T', 2),
(14, 'T', 1),
(15, 'F', 1),
(16, 'F', 3),
(17, 'F', 3),
(18, 'T', 2),
(19, 'F', 3),
(20, 'F', 1),
(21, 'F', 3)

CREATE TABLE Lockers
(
LockerID INT PRIMARY KEY IDENTITY(1,1),
LockerRoomID INT,
Sex CHAR(1),
FacilityID INT,
Size VARCHAR(20),
KeyID INT CONSTRAINT [Lockers-KeyID_LockerKeys-KeyID] REFERENCES LockerKeys(KeyID),
FOREIGN KEY(LockerRoomID, Sex, FacilityID) REFERENCES LockerRooms(RoomID, Sex, FacilityID)
)

INSERT INTO Lockers VALUES
(1, 'M', 1, '100x100', 1),
(2, 'M', 1, '100x100', 2),
(1, 'F', 1, '100x50', 3),
(2, 'F', 1, '100x100', 4),
(1, 'M', 2, '120x100', 5),
(2, 'M', 2, '100x100', 6),
(3, 'M', 2, '150x100', 7),
(4, 'M', 2, '100x100', 8),
(1, 'F', 2, '200x100', 9),
(2, 'F', 2, '100x100', 10),
(3, 'F', 2, '100x100', 11),
(4, 'F', 2, '150x200', 12),
(1, 'M', 3, '100x100', 13),
(2, 'M', 3, '50x50', 14),
(3, 'F', 3, '100x100', 15),
(1, 'F', 3, '100x100', 16),
(2, 'F', 3, '100x100', 17),
(3, 'F', 3, '50x50', 18)

GO

CREATE TABLE Departments
(
DepartmentID INT PRIMARY KEY IDENTITY(1,1),
Name VARCHAR(50),
City VARCHAR(50),
[Telephone Number] VARCHAR(30)
)

INSERT INTO Departments VALUES
('Kuchnia', 'Pilzno', NULL),
('Konserwacja powierzchni p³askich', 'Kraków', NULL),
('Recepcja', 'Kraków', NULL),
('Sportu', 'Czêstochowa', NULL),
('SPA', 'Kraków', NULL),
('Ratownictwa wodnego', 'Radzionków', NULL),
('Zarz¹d', 'Warszawa', NULL),
('Marketing', 'Warszawa', NULL),
('IT', 'Kraków', NULL)

CREATE TABLE Salary
(
DepartmentID INT PRIMARY KEY CONSTRAINT [Salary-DepartmentID_Departments-DepartmentID] REFERENCES Departments(DepartmentID),
[Basic Salary] MONEY
)

INSERT INTO Salary VALUES
(1, 4467),
(2, 3289),
(3, 3300),
(4, 4280 ),
(5, 3490),
(6, 3620),
(7, 9780),
(8, 5000),
(9, 5330)
	
CREATE TABLE Personel
(
EmployeeID INT PRIMARY KEY,
Name NVARCHAR(100),
Surname NVARCHAR(100),
FacilityID INT CONSTRAINT [Personel-Facilities_FK] REFERENCES Facilities(FacilityID),
SuperiorID INT CONSTRAINT [Employee-Superior_FK] REFERENCES Personel(EmployeeID),
DepartmentID INT CONSTRAINT [Personel_DepartmentID-Departments_DepartmentID] REFERENCES Departments(DepartmentID),
[Date of Employment] DATE
)

INSERT INTO Personel VALUES
(1, 'Kamil', 'Mazurek', 1, NULL, 7, '1990-01-01'),
(2, 'Jan', 'Kowalski', 1, 1, 1, '2001-01-15'),
(3, 'Maria', 'Zieliñska', 1, 2, 1, '2000-02-01'),
(4, 'Adam', 'Wiœniewski', 1, 3, 6, '2023-02-15'),
(5, 'Ewa', 'Wójcik', 1, 4, 5, '2000-03-01'),
(6, 'Tomasz', 'Lewandowski', 1, 5, 5, '2003-03-15'),
(7, 'Agnieszka', 'D¹browska', 1, 6, 1, '2023-04-01'),
(8, 'Pawe³', 'Zakrzewski', 3, 7, 1, '2001-04-15'),
(9, 'Katarzyna', 'Kowalczyk', 1, 8, 7, '1995-05-01'),
(10, 'Micha³', 'Mazur', 3, 9, 3, '2000-01-01'),
(11, 'Magdalena', 'Kubiak', 2, 10, 5, '2023-06-01'),
(12, 'Marcin', 'Wróbel', 3, 11, 3, '2000-06-15'),
(13, 'Joanna', 'Jankowska', 2, 12, 4, '2003-07-01'),
(14, '£ukasz', 'Nowicki', 3, 13, 1, '2015-07-15'),
(15, 'Ma³gorzata', 'Sikora', 2, 14, 3, '2005-08-01'),
(16, 'Jakub', 'Ostrowski', 1, 15, 2, '2020-08-15'),
(17, 'Barbara', 'Malinowska', 2, 16, 3, '2023-09-01'),
(18, 'Grzegorz', 'Pawlak', 1, 17, 2, '2023-09-15'),
(19, 'Aleksandra', 'Witkowska', 1, 18, 2, '2013-10-01'),
(20, 'Krzysztof', 'Krawczyk', 1, 19, 5, '2010-10-15');

CREATE TABLE Bonuses
(
DepartmentID INT CONSTRAINT [Bonuses-DepartmentID_Departments-DepartmentID] REFERENCES Departments(DepartmentID),
Years INT,
Bonus MONEY,
PRIMARY KEY(DepartmentID, Years)
)

INSERT INTO Bonuses VALUES
(1, 1, 0),
(1, 2, 0),
(1, 5, 200),
(1, 10, 300),
(1, 15, 400),
(1, 20, 500),
(2, 1, 0),
(2, 2, 0),
(2, 5, 50),
(2, 10, 100),
(2, 15, 150),
(2, 20, 200),
(3, 1, 0),
(3, 2, 50),
(3, 5, 100),
(3, 10, 200),
(3, 15, 300),
(3, 20, 350),
(4, 1, 0),
(4, 2, 100),
(4, 5, 300),
(4, 10, 400),
(4, 15, 400),
(4, 20, 400),
(5, 1, 0),
(5, 2, 0),
(5, 5, 100),
(5, 10, 200),
(5, 15, 250),
(5, 20, 250),
(6, 1, 0),
(6, 2, 0),
(6, 5, 200),
(6, 10, 400),
(6, 15, 600),
(6, 20, 800),
(7, 1, 125),
(7, 2, 250),
(7, 5, 500),
(7, 10, 1000),
(7, 15, 1100),
(7, 20, 1200),
(8, 1, 200),
(8, 2, 400),
(8, 5, 600),
(8, 10, 800),
(8, 15, 1000),
(8, 20, 1300)
	
CREATE TABLE EmployeeLeaves
(
EmployeeID INT CONSTRAINT [EmployeeLeaves-EmployeeID_Personel-EmployeeID] REFERENCES Personel(EmployeeID),
[Beginning Date] DATE,
[Ending Date] DATE,
LeaveType VARCHAR(50),
PRIMARY KEY(EmployeeID, [Beginning Date]),
CHECK ([Beginning Date] <= [Ending Date])
)

INSERT INTO EmployeeLeaves VALUES
(1, '2020-01-01', '2020-01-07', 'Parental'),
(4, '2020-02-01', '2020-02-28', 'Sick'),
(2, '2020-03-20', '2020-03-30', 'Rescue activities'),
(5, '2020-04-01', '2020-05-01', 'Parental'),
(3, '2020-05-15', '2020-06-15', 'Parental'),
(7, '2020-07-01', '2020-07-05', 'Sick'),
(8, '2020-06-01', '2020-08-01', 'Parental'),
(1, '2020-07-01', '2020-07-01', 'Sick'),
(2, '2020-10-01', '2020-11-01', 'Parental'),
(3, '2024-10-01', '2024-11-01', 'Parental'),
(4, '2024-10-01', '2024-11-01', 'Parental'),
(1, '2024-10-01', '2024-11-01', 'Parental'),
(5, '2024-10-01', '2024-11-01', 'Parental')

CREATE TABLE EmployeeVacations
(
EmployeeID INT CONSTRAINT [EmployeeVacations-EmployeeID_Personel-EmployeeID] REFERENCES Personel(EmployeeID),
[Beginning Date] DATE,
[Ending Date] DATE,
Paid CHAR(1),
PRIMARY KEY (EmployeeID, [Beginning Date])
)

INSERT INTO EmployeeVacations VALUES
(1, '2020-01-01', '2020-01-07', 'T'),
(4, '2020-02-01', '2020-02-28', 'F'),
(2, '2020-03-20', '2020-03-30', 'T'),
(5, '2020-04-01', '2020-05-01', 'F'),
(3, '2020-05-15', '2020-06-15', 'T'),
(7, '2020-07-01', '2020-07-05', 'F'),
(8, '2020-06-01', '2020-08-01', 'T'),
(1, '2020-07-01', '2020-07-01', 'T'),
(2, '2020-10-01', '2020-11-01', 'F'),
(1, '2024-10-01', '2024-11-01', 'T'),
(4, '2024-10-01', '2024-10-15', 'F'),
(1, '2024-10-20', '2024-10-02', 'T'),
(5, '2024-10-01', '2024-11-01', 'F')

CREATE TABLE CafeteriaProducts
(
ID INT PRIMARY KEY IDENTITY(1, 1),
Name NVARCHAR(100),
Price FLOAT
)

INSERT INTO CafeteriaProducts VALUES
('Lasagne al forno con besciamella e carne macinata', 20),
('Tiramisu al caffe con savoiardi e mascarpone', 30),
('Cannelloni ripieni di ricotta e spinaci al sugo di pomodoro', 15),
('Spaghetti alla carbonara con guanciale croccante', 28),
('Gnocchi di patate al ragu di salsiccia e funghi', 11)

CREATE TABLE Cafeteria
(
CookID INT CONSTRAINT [Cafeteria-CookID_Personel-EmployeeID] REFERENCES Personel(EmployeeID),
DishID INT REFERENCES CafeteriaProducts(ID),
[Preparation Date] DATE,
Price MONEY,
PRIMARY KEY (CookID, DishID, [Preparation Date])
)

INSERT INTO Cafeteria VALUES
(3, 1, '2023-01-01', 20),
(8, 1, '2023-01-01', 20),
(3, 1, '2023-01-03', 20),
(3, 2, '2023-01-03', 30),
(7, 1, '2023-01-04', 20),
(3, 3, '2023-01-04', 15),
(7, 4, '2023-01-05', 28),
(8, 2, '2023-01-05', 30),
(3, 4, '2023-01-06', 28),
(7, 5, '2023-01-06', 11),
(8, 4, '2023-01-06', 28),
(8, 5, '2023-01-06', 11),
(8, 1, '2023-01-06', 11)

GO

IF OBJECT_ID('Fees', 'U') IS NOT NULL
	DROP TABLE Fees;

CREATE TABLE Fees
(
Type VARCHAR(50) PRIMARY KEY,
Price MONEY,
)

INSERT INTO Fees VALUES
('Media', 2000),
('Ogrzewanie', 1000),
('Ubezpieczenia spoleczne i zdrowotne', 10700),
('Ksiêgowoœæ', 400),
('Marketing', 5000)

IF OBJECT_ID('Budget', 'U') IS NOT NULL
	DROP TABLE Budget;
	
CREATE TABLE Budget
(
Year INT,
Month INT,
Profit MONEY,
Expenses MONEY,
PRIMARY KEY (Year, Month)
)

INSERT INTO Budget VALUES
(2000, 1, 4000, 4500),
(2000, 2, 2500, 1110),
(2000, 3, 2000, 1500),
(2000, 4, 3000, 1900),
(2000, 5, 3100, 3200),
(2000, 6, 1500, 0),
(2003, 1, 10000, 5000),
(2004, 1, 10500, 12000),
(2005, 1, 13000, 20000),
(YEAR(GETDATE()), MONTH(GETDATE()), 0, 0);

CREATE TABLE Reservations
(
FacilityID INT,
Date DATE CHECK (Date >= GETDATE()),
StartingTime TIME,
EndingTime TIME,
PRIMARY KEY (FacilityID, Date, StartingTime)
)

INSERT INTO Reservations VALUES
(1, '2025-01-01', '15:00', '17:00');

CREATE TABLE ReservationsPrice
(
FacilityID INT PRIMARY KEY,
[Price per hour] MONEY
)

INSERT INTO ReservationsPrice VALUES
(1, 80),
(2, 100),
(3, 300);
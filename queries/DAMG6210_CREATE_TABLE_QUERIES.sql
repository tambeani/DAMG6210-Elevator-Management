USE Team_Project10;

------------ SCHEMA: Territory ------------

GO
CREATE SCHEMA Territory
GO

-------------------------------------------

-------------------------------- TABLE: Country ------------------------------------

CREATE TABLE Territory.Country (
    CountryCode INT IDENTITY(1,1) PRIMARY KEY,
    CountryName VARCHAR(255)
);

-------------------------------------------------------------------------------------


-------------------------------- TABLE: Region --------------------------------------

CREATE TABLE Territory.Region (
    RegionID INT IDENTITY(1,1) PRIMARY KEY,
    RegionName VARCHAR(10),
    CountryCode INT FOREIGN KEY(CountryCode) REFERENCES Territory.Country(CountryCode)
);

ALTER TABLE Territory.Region ALTER COLUMN RegionName VARCHAR(30)

-------------------------------------------------------------------------------------


-------------------------------- TABLE: Territory -----------------------------------

CREATE TABLE Territory.Territory (
    TerritoryID INT IDENTITY(1,1) PRIMARY KEY,
    TerritoryName VARCHAR(10),
    RegionID INT FOREIGN KEY(RegionID) REFERENCES Territory.Region(RegionID)
);

ALTER TABLE Territory.Territory ALTER COLUMN TerritoryName VARCHAR(30)

-------------------------------------------------------------------------------------

-------------------------------- TABLE: Route -----------------------------------

CREATE TABLE Territory.Route (
    RouteID INT IDENTITY(1,1) PRIMARY KEY,
    RouteName VARCHAR(100),
    TerritoryID INT FOREIGN KEY(TerritoryID) REFERENCES Territory.Territory(TerritoryID)
);

-------------------------------------------------------------------------------------

-------------------------------- TABLE: Building ------------------------------------

CREATE TABLE Territory.Building (
    BuildingID INT IDENTITY(1,1) PRIMARY KEY,
    StreetNumber INT,
    [Address 1] VARCHAR(50),
    [Address 2] VARCHAR(50),
    RouteID INT FOREIGN KEY(RouteID) REFERENCES Territory.Route(RouteID)
);

-------------------------------------------------------------------------------------

------------- Schema: Product -------------

GO 
CREATE SCHEMA Product
GO

-------------------------------------------


-------------------------------- TABLE: ProductType ------------------------------------

CREATE TABLE Product.ProductType(
    ProductTypeID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(20)
)

-------------------------------------------------------------------------------------


-------------------------------- TABLE: Product ------------------------------------

CREATE TABLE Product.Product (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(20),
    FixedPrice NUMERIC,
    ProductTypeID INT FOREIGN KEY(ProductTypeID) REFERENCES Product.ProductType(ProductTypeID),
    ManufacturingDate DATE,
    IsCommercial BIT
);

-------------------------------------------------------------------------------------

------------- Schema: Contract -------------

Go
CREATE SCHEMA Contract
Go

-------------------------------------------

-------------------------------- TABLE: Unit ------------------------------------

CREATE TABLE Contract.Unit(
  SerialNo int IDENTITY(1,1) PRIMARY KEY,
  ProductID int FOREIGN KEY REFERENCES Product.Product(ProductID),
  IsActive bit,
  BuildingID int FOREIGN KEY REFERENCES Territory.Building(BuildingID)
);

-------------------------------------------------------------------------------------

-------------------------------- TABLE: Sale ------------------------------------

CREATE TABLE Contract.Sale(
	SaleID int IDENTITY(1,1) PRIMARY KEY,
    SerialNo int FOREIGN KEY REFERENCES Contract.Unit(SerialNo),
	SalesRepID int FOREIGN KEY REFERENCES Person.Employee(EmployeeId),
	BillingCycle varchar(255),
	Price money,
	ContractDate date,
	CustomerID int FOREIGN KEY REFERENCES Person.Customer(CustomerId),
	Tenure numeric,
	BillingMode varchar(255),
	CompanyID int FOREIGN KEY REFERENCES Client.Company(CompanyID)
);

-------------------------------------------------------------------------------------

------------- Schema: Contract -------------

Go
CREATE SCHEMA Callback
Go

-------------------------------------------


-------------------------------- TABLE: Status ------------------------------------

CREATE TABLE Callback.Status
(
    StatusID INT IDENTITY(1,1) PRIMARY KEY,
    StatusType VARCHAR(10)
)

-------------------------------------------------------------------------------------


-------------------------------- TABLE: Callback ------------------------------------

CREATE TABLE Callback.Callback
(CallbackID INT,
 RouteID INT,
 MechanicID INT,
 StatusID INT FOREIGN KEY REFERENCES Contract.Unit(SerialNo),
 CallbackDate DATE,
 SerialNumber INT
 PRIMARY KEY (CallbackID),
 FOREIGN KEY (RouteID) REFERENCES Territory.Route(RouteID) ,
 FOREIGN KEY (MechanicID) REFERENCES Person.Employee(EmployeeId),
 FOREIGN KEY (SerialNumber) REFERENCES Contract.Unit(SerialNo)
);

-------------------------------------------------------------------------------------

-------------------------------- TABLE: MaintenanceJobs ------------------------------

CREATE TABLE Callback.MaintenanceJobs
(JobID INT,
 EmployeeID INT,
 RouteID INT,
 VisitDate DATE,
 JobStatus BIT,
 SerialNumber INT
 PRIMARY KEY (JobID),
 FOREIGN KEY (RouteID) REFERENCES Territory.Route(RouteID) ,
 FOREIGN KEY (EmployeeID) REFERENCES Person.Employee(EmployeeId),
 FOREIGN KEY (SerialNumber) REFERENCES Contract.Unit(SerialNo)
);

-------------------------------------------------------------------------------------

------------- Schema: Person -------------

GO
CREATE SCHEMA Person
GO

-------------------------------------------


-------------------------------- TABLE: Gender ------------------------------

CREATE TABLE Person.Gender(
    GenderID INT IDENTITY(1,1) PRIMARY KEY,
    Gender VARCHAR(10)
)

-------------------------------------------------------------------------------------

-------------------------------- TABLE: Person ---------------------------------

CREATE TABLE Person.Person (
    PersonId INT IDENTITY(1,1) PRIMARY KEY,
    FirstName VARCHAR(200) NOT NULL,
    LastName VARCHAR(200) NOT NULL,
    PhoneNumber CHAR(12), -- you might not want to have such a precise length
    CONSTRAINT chk_phone CHECK (PhoneNumber NOT LIKE '%[^0-9+-.]%'),
    DateofBirth Date,
    AGE AS DATEDIFF(hour,DateOfBirth,GETDATE())/8766,
    EmailAddress VARCHAR(200),
    GenderID INT FOREIGN KEY REFERENCES Person.Gender(GenderID)
);

-------------------------------------------------------------------------------------

-------------------------------- TABLE: Employee ---------------------------------

CREATE TABLE Person.Employee (
    EmployeeId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT FOREIGN KEY REFERENCES Client.Company(CompanyID),
    RoleId INT FOREIGN KEY REFERENCES Person.Role(RoleId),
    JoiningDate DATE,
    LastDate DATE
);

-------------------------------------------------------------------------------------

-------------------------------- TABLE: Role ---------------------------------

CREATE TABLE Person.Role (
    RoleId INT IDENTITY(1,1) PRIMARY KEY,
    Position VARCHAR(200)
);

-------------------------------------------------------------------------------------


-------------------------------- TABLE: Customer ---------------------------------

CREATE TABLE Person.Customer(
    CustomerId INT IDENTITY(1,1) PRIMARY KEY,
    CompanyId INT FOREIGN KEY REFERENCES Client.Company(CompanyID)
);

-------------------------------------------------------------------------------------

-------------------------------- TABLE: UserDetails ---------------------------------

CREATE TABLE Person.UserDetails (
    LoginId VARCHAR(200) PRIMARY KEY,
    EncryptedPassword VARBINARY(250)
);
-------------------------------------------------------------------------------------


------------- Schema: Client -------------

Go
CREATE SCHEMA Client
GO

-------------------------------------------


-------------------------------- TABLE: Organization ---------------------------------

CREATE TABLE Client.Organization (
    OrganizationID INT IDENTITY(1,1) PRIMARY KEY,
    OrganizationName VARCHAR(200) NOT NULL,
    OrganizationCountryCode INT FOREIGN KEY REFERENCES territory.country(CountryCode),
    OrganizationSSN VARCHAR(12) NOT NULL
);

-------------------------------------------------------------------------------------


-------------------------------- TABLE: China ---------------------------------

CREATE TABLE Client.Company (
    CompanyID INT IDENTITY(1,1) PRIMARY KEY,
    OrganizationID INT FOREIGN KEY REFERENCES Client.Organization(OrganizationID),
    RegionID INT FOREIGN KEY REFERENCES Territory.Region(RegionID) ,
    CompanyName VARCHAR(200)
);

-------------------------------------------------------------------------------------
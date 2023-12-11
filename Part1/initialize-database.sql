USE master;

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Stores')
	CREATE DATABASE Stores;
GO

USE STORES;

IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Clients' AND xtype='U')
CREATE TABLE Clients (
	Client_ID INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(512) NOT NULL,
	Surname NVARCHAR(512) NOT NULL,
	Sex SMALLINT CONSTRAINT User_sex_ISO_IEC_5218 CHECK (Sex IN (0, 1, 2, 9)),
	Join_date DATETIME DEFAULT GETDATE() NOT NULL,
	Phone_number NVARCHAR(24) NOT NULL,
	Email NVARCHAR(512) NOT NULL,
	Points_collected INT DEFAULT 0 CONSTRAINT User_points_not_negative CHECK (Points_collected >= 0) NOT NULL
);



IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Shops' AND xtype='U')
CREATE TABLE Shops (
	Shop_ID INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(512) NOT NULL,
	Country NVARCHAR(512) NOT NULL,
	City NVARCHAR(512) NOT NULL,
	Address NVARCHAR(512) NOT NULL,
	Post_code NVARCHAR(512) NOT NULL,
	Open_date DATETIME DEFAULT GETDATE() NOT NULL,
	Close_date DATETIME DEFAULT NULL,
);



IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Employees' AND xtype='U')
CREATE TABLE Employees(
	Employee_ID INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(512) NOT NULL,
	Surname NVARCHAR(512) NOT NULL,
	Sex SMALLINT CONSTRAINT Employee_sex_ISO_IEC_5218 CHECK (Sex IN (0, 1, 2, 9)),
	Employment_date DATETIME DEFAULT GETDATE() NOT NULL,
	Leave_date DATETIME DEFAULT NULL,
	Phone_number NVARCHAR(24) NOT NULL,
	Email NVARCHAR(512) NOT NULL,
	Role NVARCHAR(512) NOT NULL,
	Shop_ID INT FOREIGN KEY (Shop_ID) REFERENCES Shops(Shop_ID) ON UPDATE CASCADE NOT NULL
);



IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Sales' AND xtype='U')
CREATE TABLE Sales (
	Sale_ID INT PRIMARY KEY IDENTITY,
	Sale_date DATETIME DEFAULT GETDATE() NOT NULL,
	Total_cost DECIMAL(8, 2) CONSTRAINT Cost_not_negative CHECK (Total_cost >= 0) NOT NULL,
	Points_collected INT DEFAULT 0 CONSTRAINT Sale_points_not_negative CHECK (Points_collected >= 0) NOT NULL,
	Client_ID INT FOREIGN KEY (Client_ID) REFERENCES Clients(Client_ID) ON DELETE SET NULL ON UPDATE CASCADE,
	Employee_ID INT FOREIGN KEY (Employee_ID) REFERENCES Employees(Employee_ID) ON UPDATE CASCADE NOT NULL
);



IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Brands' AND xtype='U')
CREATE TABLE Brands (
	Brand_ID INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(512) NOT NULL,
	Country NVARCHAR(512) NOT NULL
);



IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Manufacturers' AND xtype='U')
CREATE TABLE Manufacturers (
	Manufacturer_ID INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(512) NOT NULL,
	Country NVARCHAR(512) NOT NULL,
	Speciality NVARCHAR(512) NOT NULL
);



IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Categories' AND xtype='U')
CREATE TABLE Categories (
	Category_ID INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(512) NOT NULL,
	Parent_ID INT FOREIGN KEY (Parent_ID) REFERENCES Categories(Category_ID)
);



IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Products' AND xtype='U')
CREATE TABLE Products (
	Product_ID INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(512) NOT NULL,
	Category_ID INT FOREIGN KEY (Category_ID) REFERENCES Categories(Category_ID) ON DELETE SET NULL ON UPDATE CASCADE,
	Brand_ID INT FOREIGN KEY (Category_ID) REFERENCES Brands(Brand_ID) ON DELETE SET NULL ON UPDATE CASCADE
);



IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Price_histories' AND xtype='U')
CREATE TABLE Price_histories(
	Price_history_ID INT PRIMARY KEY IDENTITY,
	Price DECIMAL(8, 2) CONSTRAINT Price_not_negative CHECK (Price >= 0) NOT NULL,
	Start_date DATETIME DEFAULT GETDATE() NOT NULL,
	Product_ID INT FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);




IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Storages' AND xtype='U')
CREATE TABLE Storages (
	Shop_ID INT FOREIGN KEY (Shop_ID) REFERENCES Shops(Shop_ID) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
	Product_ID INT FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
	Amount REAL CONSTRAINT Storage_amount_not_negative CHECK (Amount >= 0) NOT NULL
);



IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Sales_details' AND xtype='U')
CREATE TABLE Sales_details (
	Sale_ID INT FOREIGN KEY (Sale_ID) REFERENCES Sales(Sale_ID) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
	Product_ID INT FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
	Amount REAL CONSTRAINT Sale_amount_not_negative CHECK (Amount >= 0) NOT NULL
);



IF NOT EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Product_manufacturers' AND xtype='U')
CREATE TABLE Product_manufacturers (
	Product_ID INT FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
	Manufacturer_ID INT FOREIGN KEY (Manufacturer_ID) REFERENCES Manufacturers(Manufacturer_ID) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);
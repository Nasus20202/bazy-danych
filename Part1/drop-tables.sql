Use Stores;

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Sales_details' AND xtype='U')
	DROP TABLE Sales_details;

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Sales' AND xtype='U')
	DROP TABLE Sales;

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Storages' AND xtype='U')
	DROP TABLE Storages;

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Product_manufacturers' AND xtype='U')
	DROP TABLE Product_manufacturers;

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Price_histories' AND xtype='U')
	DROP TABLE Price_histories;

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Products' AND xtype='U')
	DROP TABLE Products;

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Categories' AND xtype='U')
	DROP TABLE Categories;

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Manufacturers' AND xtype='U')
	DROP TABLE Manufacturers;

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Brands' AND xtype='U')
	DROP TABLE Brands;

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Employees' AND xtype='U')
	DROP TABLE Employees;

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Shops' AND xtype='U')
	DROP TABLE Shops;

IF EXISTS (SELECT * FROM SYSOBJECTS WHERE name='Clients' AND xtype='U')
	DROP TABLE Clients;
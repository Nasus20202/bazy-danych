USE master;

-- Make sure that the database is not in use before droping it.
IF  EXISTS (SELECT * FROM sys.databases WHERE name = 'Stores')
BEGIN
	ALTER DATABASE Stores  SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Stores;
END;
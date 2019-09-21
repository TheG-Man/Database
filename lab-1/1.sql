CREATE DATABASE [Vadim_Seledets_DB];
GO

CREATE SCHEMA [sales];
GO

CREATE SCHEMA [persons];
GO

CREATE TABLE [sales].[Orders] (OrderNum INT NULL);

BACKUP DATABASE [Vadim_Seledets_DB] TO DISK = 'C:\Users\nikol\Desktop\Databases\Vadim_Seledets_DB.bak';
GO

DROP DATABASE [Vadim_Seledets_DB];
GO

RESTORE DATABASE [Vadim_Seledets_DB] FROM DISK = 'C:\Users\nikol\Documents\SQL Server Management Studio\Vadim_Seledets_DB.bak';
GO


/*
Добавьте в таблицу dbo.Address поле AddressType типа nvarchar размерностью 50 символов
*/

ALTER TABLE [dbo].[Address]
ADD [AddressType] NVARCHAR(50);
GO

/*
Объявите табличную переменную с такой же структурой как dbo.Address и заполните ее данными
из dbo.Address. Заполните поле AddressType значениями из Person.AddressType поля Name
*/

DECLARE @Var TABLE(
    [AddressID] INT NOT NULL,
    [AddressLine1] NVARCHAR(60) NOT NULL,
    [AddressLine2] NVARCHAR(60) NULL,
    [City] NVARCHAR(30) NOT NULL,
    [StateProvinceID] INT NOT NULL,
    [PostalCode] NVARCHAR(15) NOT NULL,
    [ModifiedDate] DATETIME NOT NULL,
    [AddressType] NVARCHAR(50) NOT NULL
);

INSERT INTO @Var (
    [AddressID],
    [AddressLine1],
    [AddressLine2],
    [City],
    [StateProvinceID],
    [PostalCode],
    [ModifiedDate],
    [AddressType]
) SELECT 
    [AddressID],
    [AddressLine1],
    [AddressLine2],
    [City],
    [StateProvinceID],
    [PostalCode],
    [ModifiedDate],
    (SELECT [Name] FROM [Person].[AddressType]
     JOIN [Person].[BusinessEntityAddress]
        ON [AddressType].[AddressTypeID] = [BusinessEntityAddress].[AddressTypeID]
     WHERE [BusinessEntityAddress].[AddressID] = [dbo].[Address].[AddressID]
     )
FROM [dbo].[Address];

SELECT * FROM @Var;

/*
Обновите поле AddressType в dbo.Address данными из табличной переменной. Также обновите AddressLine2,
если значение в поле NULL — обновите поле данными из AddressLine1
*/

UPDATE [dbo].[Address]
SET [dbo].[Address].[AddressType] = [Var].[AddressType]
FROM @Var AS [Var];

UPDATE [dbo].[Address]
SET [dbo].[Address].[AddressLine2] = [Var].[AddressLine1]
FROM @Var AS [Var]
WHERE [dbo].[Address].[AddressLine2] IS NULL;
GO

/*
Удалите данные из dbo.Address, оставив только по одной строке для каждого AddressType с максимальным AddressID
*/

DELETE [temp]
FROM (
    SELECT
        ROW_NUMBER() OVER (PARTITION BY [AddressType] ORDER BY [AddressID] DESC) AS [RowNum],
        *
    FROM [dbo].[Address]) AS [temp]
WHERE [temp].[RowNum] > 1;
GO

/*
Удалите поле AddressType из таблицы, удалите все созданные ограничения и значения по умолчанию
*/

ALTER TABLE [dbo].[Address] DROP COLUMN [AddressType];
ALTER TABLE [dbo].[Address] DROP CONSTRAINT [CH_Address_PostalCode];
ALTER TABLE [dbo].[Address] DROP CONSTRAINT [DF_Address_ModifiedDate];
GO

/*
Удалите таблицу dbo.Address
*/

DROP TABLE [dbo].[Address];
GO

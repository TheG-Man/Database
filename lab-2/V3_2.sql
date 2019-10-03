
/*    
Создайте таблицу dbo.Address с такой же структурой как Person.Address,
кроме полей geography, uniqueidentifier, не включая индексы, ограничения и триггеры
*/

CREATE TABLE [dbo].[Address] (
  [AddressID] INT NOT NULL,
  [AddressLine1] NVARCHAR(60) NOT NULL,
  [AddressLine2] NVARCHAR(60) NULL,
  [City] NVARCHAR(30) NOT NULL,
  [StateProvinceID] INT NOT NULL,
  [PostalCode] NVARCHAR(15) NOT NULL,
  [ModifiedDate] DATETIME NOT NULL
);
GO

/*
Используя инструкцию ALTER TABLE, создайте для таблицы dbo.Address составной первичный
ключ из полей StateProvinceID и PostalCode
*/

ALTER TABLE [dbo].[Address]
ADD CONSTRAINT [PK_Address_StateProvinceID_PostalCode] PRIMARY KEY ([StateProvinceID], [PostalCode]);
GO

/*
Используя инструкцию ALTER TABLE, создайте для таблицы dbo.Address ограничение для поля
PostalCode, запрещающее заполнение этого поля буквами
*/

ALTER TABLE [dbo].[Address]
ADD CONSTRAINT [CH_Address_PostalCode] CHECK ([PostalCode] NOT LIKE '%[a-zA-Z]%');
GO

/*
Используя инструкцию ALTER TABLE, создайте для таблицы dbo.Address ограничение DEFAULT
для поля ModifiedDate, задайте значение по умолчанию текущую дату и время
*/

ALTER TABLE [dbo].[Address]
ADD CONSTRAINT [DF_Address_ModifiedDate] DEFAULT GETDATE() FOR [ModifiedDate];
GO

/*
Заполните новую таблицу данными из Person.Address. Выберите для вставки только те адреса,
где значение поля CountryRegionCode = ‘US’ из таблицы StateProvince. Также исключите данные,
где PostalCode содержит буквы. Для группы данных из полей StateProvinceID и PostalCode
выберите только строки с максимальным AddressID
*/

INSERT INTO [dbo].[Address] (
    [AddressID],
    [AddressLine1],
    [AddressLine2],
    [City],
    [StateProvinceID],
    [PostalCode],
    [ModifiedDate]
) SELECT
    MAX([AddressID]) OVER (PARTITION BY [temp].[StateProvinceID], [PostalCode]) AS [AddressID],
    [AddressLine1],
    [AddressLine2],
    [City],
    [temp].[StateProvinceID],
    [PostalCode],
    [temp].[ModifiedDate]
FROM (
   SELECT 
      ROW_NUMBER() OVER (PARTITION BY [Address].[StateProvinceID], [PostalCode] ORDER BY [PostalCode] ASC) RowNum,
      *
   FROM [Person].[Address]
   ) [temp]
JOIN [Person].[StateProvince]
    ON [temp].[StateProvinceID] = [StateProvince].[StateProvinceID]
WHERE [CountryRegionCode] = 'US' AND [PostalCode] NOT LIKE '%[a-z]%' AND [RowNum] = 1;
GO

/*
Уменьшите размер поля City на NVARCHAR(20)
*/

ALTER TABLE [dbo].[Address]
ALTER COLUMN [City] NVARCHAR(20);
GO

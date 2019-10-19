
/*
Выполните код, созданный во втором задании второй лабораторной работы. Добавьте в таблицу dbo.Address поля
CountryRegionCode NVARCHAR(3) и TaxRate SMALLMONEY. Также создайте в таблице вычисляемое поле DiffMin,
считающее разницу между значением в поле TaxRate и минимальной налоговой ставкой 5.00
*/

ALTER TABLE [dbo].[Address]
ADD [CountryRegionCode] NVARCHAR(3), [TaxRate] SMALLMONEY, [DiffMin] AS ([TaxRate] - 5.00);
GO

/*
Создайте временную таблицу #Address, с первичным ключом по полю AddressID. Временная таблица должна включать
все поля таблицы dbo.Address за исключением поля DiffMin
*/

CREATE TABLE [dbo].[#Address] (
	[AddressID] INT NOT NULL,
    [AddressLine1] NVARCHAR(60) NOT NULL,
    [AddressLine2] NVARCHAR(60) NULL,
    [City] NVARCHAR(30) NOT NULL,
    [StateProvinceID] INT NOT NULL,
    [PostalCode] NVARCHAR(15) NOT NULL,
    [ModifiedDate] DATETIME NOT NULL,
	[CountryRegionCode] NVARCHAR(3),
	[TaxRate] SMALLMONEY,
	PRIMARY KEY CLUSTERED ([AddressID])
);

/*
Заполните временную таблицу данными из dbo.Address. Поле CountryRegionCode заполните значениями из таблицы
Person.StateProvince. Поле TaxRate заполните значениями из таблицы Sales.SalesTaxRate. Выберите только те записи,
где TaxRate > 5. Выборку данных для вставки в табличную переменную осуществите в Common Table Expression (CTE)
*/

WITH [EMP] AS (
SELECT 
    [AddressID],
    [AddressLine1],
    [AddressLine2],
    [City],
    [Address].[StateProvinceID],
    [PostalCode],
    [Address].[ModifiedDate],
	[StateProvince].[CountryRegionCode],
	[SalesTaxRate].[TaxRate]
FROM [dbo].[Address]
JOIN [Person].[StateProvince] 
	ON [dbo].[Address].[StateProvinceID] = [StateProvince].[StateProvinceID]
JOIN [Sales].[SalesTaxRate]
	ON [dbo].[Address].[StateProvinceID] = [SalesTaxRate].[StateProvinceID]
GROUP BY 
	[AddressID],
    [AddressLine1],
    [AddressLine2],
    [City],
    [Address].[StateProvinceID],
    [PostalCode],
    [Address].[ModifiedDate],
	[StateProvince].[CountryRegionCode],
	[SalesTaxRate].[TaxRate]
HAVING [SalesTaxRate].[TaxRate] > 5)

INSERT INTO [dbo].[#Address] (
	[AddressID],
    [AddressLine1],
    [AddressLine2],
    [City],
    [StateProvinceID],
    [PostalCode],
    [ModifiedDate],
	[CountryRegionCode],
	[TaxRate]
) SELECT
	[AddressID],
    [AddressLine1],
    [AddressLine2],
    [City],
    [StateProvinceID],
    [PostalCode],
    [ModifiedDate],
	[CountryRegionCode],
	[TaxRate]
FROM [EMP];

SELECT * FROM [dbo].[#Address] ORDER BY [StateProvinceID];

/*
Удалите из таблицы dbo.Address строки (где StateProvinceID = 36)
*/

DELETE FROM [dbo].[Address] WHERE [StateProvinceID] = '36';

/*
Напишите Merge выражение, использующее dbo.Address как target, а временную таблицу как source. Для связи target
и source используйте AddressID. Обновите поля CountryRegionCode и TaxRate, если запись присутствует в source и
target. Если строка присутствует во временной таблице, но не существует в target, добавьте строку в dbo.Address.
Если в dbo.Address присутствует такая строка, которой не существует во временной таблице, удалите строку из dbo.Address
*/

MERGE INTO [dbo].[Address] AS [target]
USING [dbo].[#Address] AS [source]
ON [target].[AddressID] = [source].[AddressID]
WHEN MATCHED THEN UPDATE SET 
	[CountryRegionCode] = [source].[CountryRegionCode],
	[TaxRate] = [source].[TaxRate]
WHEN NOT MATCHED BY TARGET THEN	INSERT (
	[AddressID],
    [AddressLine1],
    [AddressLine2],
    [City],
    [StateProvinceID],
    [PostalCode],
    [ModifiedDate],
	[CountryRegionCode],
	[TaxRate])
VALUES(
	[source].[AddressID],
	[source].[AddressLine1],
	[source].[AddressLine2],
	[source].[City],
	[source].[StateProvinceID],
	[source].[PostalCode],
	[source].[ModifiedDate],
	[source].[CountryRegionCode],
	[source].[TaxRate])
WHEN NOT MATCHED BY SOURCE THEN DELETE;
GO

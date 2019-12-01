
/*
Создайте хранимую процедуру, которая будет возвращать сводную таблицу (оператор PIVOT),
отображающую данные о средней цене (Production.Product.ListPrice) продукта в каждой
подкатегории (Production.ProductSubcategory) по определенному классу (Production.Product.Class).
Список классов передайте в процедуру через входной параметр.

Пример вызова: EXECUTE dbo.SubCategoriesByClass ‘[H],[L],[M]’
*/

CREATE PROCEDURE [dbo].[SubCategoriesByClass](@Classes NVARCHAR(300)) AS
    DECLARE @SQLQuery AS NVARCHAR(900);
    SET @SQLQuery = '
SELECT [Name], ' + @Classes + '
FROM (
    SELECT
        [P].[Class],
        [P].[ListPrice],
        [PSC].[Name]
    FROM [Production].[Product] AS [P] 
    JOIN [Production].[ProductSubcategory] AS [PSC] 
        ON [P].[ProductSubcategoryID] = [PSC].[ProductSubcategoryID]
) AS [pol]
PIVOT (AVG([ListPrice]) FOR [pol].[Class] IN(' + @Classes + ')) AS [pvt]'
    EXECUTE sp_executesql @SQLQuery

EXECUTE [dbo].[SubCategoriesByClass] '[H],[L],[M]';

/*
Создайте scalar-valued функцию, которая будет принимать в качестве входного параметра id заказа
(Purchasing.PurchaseOrderHeader.PurchaseOrderID) и возвращать сумму по заказу из детализированного
списка заказов (Purchasing.PurchaseOrderDetail.LineTotal).
*/

CREATE FUNCTION [Purchasing].[GetOrderSum](@PurchaseOrderID INT)
RETURNS MONEY
AS
BEGIN
    DECLARE @result MONEY
    SELECT @result = [PurchaseOrderDetail].[LineTotal]
    FROM [Purchasing].[PurchaseOrderDetail]
    WHERE [Purchasing].[PurchaseOrderDetail].[PurchaseOrderID] = @PurchaseOrderID
    RETURN @result
END;
GO

/*
Создайте inline table-valued функцию, которая будет принимать в качестве входных параметров id заказчика
(Sales.Customer.CustomerID) и количество строк, которые необходимо вывести. Функция должна возвращать
определенное количество самых прибыльных заказов (по TotalDue) из Sales.SalesOrderHeader для каждого заказчика.
*/

CREATE FUNCTION [Sales].GetNMostProfitableOrders(@CustomerID INT, @NumberOfRows INT)
RETURNS TABLE AS RETURN (
    SELECT
        [SalesOrderID],
        [RevisionNumber],
        [OrderDate],
        [DueDate],
        [ShipDate],
        [Status],
        [OnlineOrderFlag],
        [SalesOrderNumber],
        [PurchaseOrderNumber],
        [AccountNumber],
        [CustomerID],
        [SalesPersonID],
        [TerritoryID],
        [BillToAddressID],
        [ShipToAddressID],
        [ShipMethodID],
        [CreditCardID],
        [CreditCardApprovalCode],
        [CurrencyRateID],
        [SubTotal],
        [TaxAmt],
        [Freight],
        [TotalDue],
        [Comment],
        [rowguid],
        [ModifiedDate]
    FROM [Sales].[SalesOrderHeader]
    WHERE [CustomerID] = @CustomerID
    ORDER BY [TotalDue] DESC
        OFFSET 0 ROWS
        FETCH NEXT @NumberOfRows ROWS ONLY
);
GO

/*
Вызовите функцию для каждого заказчика, применив оператор CROSS APPLY. Вызовите функцию для каждого заказчика,
применив оператор OUTER APPLY.
*/

SELECT * FROM [Sales].[Customer] CROSS APPLY [Sales].[GetNMostProfitableOrders]([CustomerID], 2);
SELECT * FROM [Sales].[Customer] OUTER APPLY [Sales].[GetNMostProfitableOrders]([CustomerID], 2);
GO

/*
Измените созданную inline table-valued функцию, сделав ее multistatement table-valued (предварительно сохранив
для проверки код создания inline table-valued функции).
*/

CREATE FUNCTION [Sales].[ChangedGetNMostProfitableOrders](@CustomerID INT, @NumberOfRows INT)
RETURNS @result TABLE(
    [SalesOrderID] INT NOT NULL,
    [RevisionNumber] TINYINT NOT NULL,
    [OrderDate] DATETIME NOT NULL,
    [DueDate] DATETIME NOT NULL,
    [ShipDate] DATETIME NULL,
    [Status] TINYINT NOT NULL,
    [OnlineOrderFlag] dbo.Flag NOT NULL,
    [SalesOrderNumber] NVARCHAR(23),
    [PurchaseOrderNumber] dbo.OrderNumber NULL,
    [AccountNumber] dbo.AccountNumber NULL,
    [CustomerID] INT NOT NULL,
    [SalesPersonID] INT NULL,
    [TerritoryID] INT NULL,
    [BillToAddressID] INT NOT NULL,
    [ShipToAddressID] INT NOT NULL,
    [ShipMethodID] INT NOT NULL,
    [CreditCardID] INT NULL,
    [CreditCardApprovalCode] VARCHAR(15) NULL,
    [CurrencyRateID] INT NULL,
    [SubTotal] MONEY NOT NULL ,
    [TaxAmt] MONEY NOT NULL,
    [Freight] MONEY NOT NULL,
    [TotalDue] INT NOT NULL,
    [Comment] NVARCHAR(128) NULL,
    [rowguid] UNIQUEIDENTIFIER ROWGUIDCOL  NOT NULL,
    [ModifiedDate] DATETIME NOT NULL
) AS BEGIN
    INSERT INTO @result
    SELECT
        [SalesOrderID],
        [RevisionNumber],
        [OrderDate],
        [DueDate],
        [ShipDate],
        [Status],
        [OnlineOrderFlag],
        [SalesOrderNumber],
        [PurchaseOrderNumber],
        [AccountNumber],
        [CustomerID],
        [SalesPersonID],
        [TerritoryID],
        [BillToAddressID],
        [ShipToAddressID],
        [ShipMethodID],
        [CreditCardID],
        [CreditCardApprovalCode],
        [CurrencyRateID],
        [SubTotal],
        [TaxAmt],
        [Freight],
        [TotalDue],
        [Comment],
        [rowguid],
        [ModifiedDate]
    FROM [Sales].[SalesOrderHeader]
    WHERE [CustomerID] = @CustomerID
    ORDER BY [TotalDue] DESC
        OFFSET 0 ROWS
        FETCH NEXT @NumberOfRows ROWS ONLY;
    RETURN
END;
GO

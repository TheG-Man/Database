/*
Создайте представление VIEW, отображающее данные из таблиц Production.WorkOrder и Production.ScrapReason,
а также Name из таблицы Production.Product. Сделайте невозможным просмотр исходного кода представления.
Создайте уникальный кластерный индекс в представлении по полю WorkOrderID
*/

CREATE VIEW [Production].[WorkOrderWithScrapReasonView] (
    [WorkOrderID],
    [ProductID],
    [OrderQty],
    [StockedQty],
    [ScrappedQty],
    [StartDate],
    [EndDate],
    [DueDate],
    [ScrapReasonID],
    [ModifiedDate],
    [ScrapReasonName],
    [ScrapReasonModifiedDate],
    [ProductName]
) WITH ENCRYPTION, SCHEMABINDING AS SELECT
    [WO].[WorkOrderID],
    [WO].[ProductID],
    [WO].[OrderQty],
    [WO].[StockedQty],
    [WO].[ScrappedQty],
    [WO].[StartDate],
    [WO].[EndDate],
    [WO].[DueDate],
    [WO].[ScrapReasonID],
    [WO].[ModifiedDate],
    [SR].[Name],
    [SR].[ModifiedDate],
    [PR].[Name]
FROM [Production].[WorkOrder] AS [WO]
JOIN [Production].[ScrapReason] AS [SR]
    ON [WO].[ScrapReasonID] = [SR].[ScrapReasonID]
JOIN [Production].[Product] AS [PR]
    ON [WO].[ProductID] = [PR].[ProductID];
GO

CREATE UNIQUE CLUSTERED INDEX [AK_WorkOrderWithScrapReasonView_WorkOrderID] ON [Production].[WorkOrderWithScrapReasonView] ([WorkOrderID]);
GO

/*
Создайте три INSTEAD OF триггера для представления на операции INSERT, UPDATE, DELETE. Каждый триггер должен
выполнять соответствующие операции в таблицах Production.WorkOrder и Production.ScrapReason для указанного
Product Name. Обновление и удаление строк производите только в таблицах Production.WorkOrder и Production.ScrapReason,
но не в Production.Product. В UPDATE триггере не указывайте обновление поля OrderQty для таблицы Production.WorkOrder
*/

CREATE TRIGGER [Production].[TriggerWorkOrderWithScrapReasonViewInsteadInsert] ON [Production].[WorkOrderWithScrapReasonView]
INSTEAD OF INSERT AS
BEGIN
    INSERT INTO [Production].[ScrapReason] (
        [Name],
        [ModifiedDate])
    SELECT 
        [ScrapReasonName],
        [ScrapReasonModifiedDate]
    FROM [inserted]

    INSERT INTO [Production].[WorkOrder] (
        [ProductID],
        [OrderQty],
        [ScrappedQty],
        [StartDate],
        [EndDate],
        [DueDate],
        [ScrapReasonID],
        [ModifiedDate])
    SELECT 
        [PR].[ProductID],
        [inserted].[OrderQty],
        [inserted].[ScrappedQty],
        [inserted].[StartDate],
        [inserted].[EndDate],
        [inserted].[DueDate],
        [SR].[ScrapReasonID],
        [inserted].[ModifiedDate]
    FROM [inserted]
    JOIN [Production].[Product] AS [PR]
        ON [inserted].[ProductName] = [PR].[Name]
    JOIN [Production].[ScrapReason] AS [SR]
        ON [inserted].[ScrapReasonName] = [SR].[Name]
END;
GO

CREATE TRIGGER [Production].[TriggerWorkOrderWithScrapReasonViewInsteadUpdate] ON [Production].[WorkOrderWithScrapReasonView]
INSTEAD OF UPDATE AS
BEGIN
    UPDATE [Production].[ScrapReason] SET
        [Name] = [inserted].[ScrapReasonName],
        [ModifiedDate] = [inserted].[ScrapReasonModifiedDate]
    FROM [inserted]
    WHERE [Production].[ScrapReason].[ScrapReasonID] = [inserted].[ScrapReasonID]

    UPDATE [Production].[WorkOrder] SET
        [ScrappedQty] = [inserted].[ScrappedQty],
        [StartDate] = [inserted].[StartDate],
        [EndDate] = [inserted].[EndDate],
        [DueDate] = [inserted].[DueDate],
        [ScrapReasonID] = [inserted].[ScrapReasonID],
        [ModifiedDate] = [inserted].[ModifiedDate]
    FROM [inserted]
    WHERE [Production].[WorkOrder].[WorkOrderID] = [inserted].[WorkOrderID]
END;
GO

CREATE TRIGGER [Production].[TriggerWorkOrderWithScrapReasonViewInsteadDelete] ON [Production].[WorkOrderWithScrapReasonView]
INSTEAD OF DELETE AS
BEGIN
    DELETE FROM [Production].[WorkOrder]
    WHERE [Production].[WorkOrder].[WorkOrderID] IN (
        SELECT [deleted].[WorkOrderID] FROM [deleted]
    )

    DELETE FROM [Production].[ScrapReason]
    WHERE [Production].[ScrapReason].[ScrapReasonID] IN (
        SELECT [deleted].[ScrapReasonID] FROM [deleted]
    )
END;
GO

/*
Вставьте новую строку в представление, указав новые данные для WorkOrder и ScrapReason, но для существующего Product
(например для ‘Adjustable Race’). Триггер должен добавить новые строки в таблицы Production.WorkOrder и
Production.ScrapReason для указанного Product Name. Обновите вставленные строки через представление. Удалите строки.
*/

INSERT INTO [Production].[WorkOrderWithScrapReasonView] (
    [OrderQty],
    [ScrappedQty],
    [StartDate],
    [EndDate],
    [DueDate],
    [ModifiedDate],
	[ScrapReasonName],
    [ScrapReasonModifiedDate],
	[ProductName])
VALUES (
    13,
    11,
    '2030-07-04 00:00:00.000',
    '2030-07-04 00:00:00.000',
    '2030-07-04 00:00:00.000',
    GetDate(),
	'Scrap reason name',
	GetDate(),
	'Adjustable Race'
    );

UPDATE [Production].[WorkOrderWithScrapReasonView] SET
    [StartDate] = '2031-07-04 00:00:00.000',
    [EndDate] = '2031-07-04 00:00:00.000',
    [DueDate] = '2031-07-04 00:00:00.000',
	[ModifiedDate] = GetDate(),
	[ScrapReasonName] = 'New scrap reason name',
    [ScrapReasonModifiedDate] = GetDate()
WHERE [ScrapReasonName] = 'Scrap reason name';

DELETE FROM [Production].[WorkOrderWithScrapReasonView]
WHERE [ScrapReasonName] = 'New scrap reason name';
GO

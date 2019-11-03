/*
Создайте таблицу Production.WorkOrderHst, которая будет хранить информацию об изменениях в таблице Production.WorkOrder

Обязательные поля, которые должны присутствовать в таблице: ID — первичный ключ IDENTITY(1,1); Action — совершенное
действие (insert, update или delete); ModifiedDate — дата и время, когда была совершена операция; SourceID — первичный
ключ исходной таблицы; UserName — имя пользователя, совершившего операцию. Создайте другие поля, если считаете их нужными
*/

CREATE TABLE [Production].[WorkOrderHst] (
    [ID] INT IDENTITY(1, 1) PRIMARY KEY,
    [Action] CHAR(6) NOT NULL CHECK ([Action] IN('INSERT', 'UPDATE', 'DELETE')),
    [ModifiedDate] DATETIME NOT NULL,
    [SourceID] INT NOT NULL,
    [UserName] VARCHAR(50) NOT NULL
);
GO

/*
Создайте один AFTER триггер для трех операций INSERT, UPDATE, DELETE для таблицы Production.WorkOrder. Триггер должен
заполнять таблицу Production.WorkOrderHst с указанием типа операции в поле Action в зависимости от оператора, вызвавшего триггер
*/

CREATE TRIGGER [Production].[WorkOrderAfterTrigger]
ON [Production].[WorkOrder]
AFTER INSERT, UPDATE, DELETE AS
    INSERT INTO [Production].[WorkOrderHst] ([Action], [ModifiedDate], [SourceID], [UserName])
    SELECT
        CASE WHEN [inserted].[WorkOrderID] IS NULL THEN 'DELETE'
             WHEN [deleted].[WorkOrderID] IS NULL  THEN 'INSERT'
                                                    ELSE 'UPDATE'
        END,
    GetDate(),
    COALESCE([inserted].[WorkOrderID], [deleted].[WorkOrderID]),
    User_Name()
    FROM [inserted] FULL OUTER JOIN [deleted]
    ON [inserted].[WorkOrderID] = [deleted].[WorkOrderID];
GO

/*
Создайте представление VIEW, отображающее все поля таблицы Production.WorkOrder
*/

CREATE VIEW [Production].[ViewWorkOrder] AS SELECT * FROM [Production].[WorkOrder];
GO

/*
Вставьте новую строку в Production.WorkOrder через представление. Обновите вставленную строку. Удалите вставленную
строку. Убедитесь, что все три операции отображены в Production.WorkOrderHst
*/

INSERT INTO [Production].[ViewWorkOrder] (
    [ProductID],
    [OrderQty],
    [ScrappedQty],
    [StartDate],
    [EndDate],
    [DueDate],
    [ScrapReasonID],
    [ModifiedDate])
VALUES (
    726,
    10,
    0,
    '2020-07-04 00:00:00.000',
    '2020-07-04 00:00:00.000',
    '2020-07-04 00:00:00.000',
    NULL,
    GetDate()
    );

UPDATE [Production].[WorkOrder] SET [ScrappedQty] = 13 WHERE [StartDate] = '2020-07-04 00:00:00.000';

DELETE [Production].[WorkOrder] WHERE [ScrappedQty] = 13 AND [StartDate] = '2020-07-04 00:00:00.000';
GO

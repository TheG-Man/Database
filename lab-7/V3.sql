/*
Вывести значения полей [BusinessEntityID], [FirstName] и [LastName] из таблицы [Person].[Person]
в виде xml, сохраненного в переменную.
*/

DECLARE @xml XML;

SET @xml =
(
    SELECT
        [BusinessEntityID] AS 'ID',
        [FirstName] AS 'FirstName',
        [LastName] AS 'LastName'
    FROM [Person].[Person]

    FOR XML
        PATH ('Person'),
        ROOT ('Persons')
);

SELECT
    @xml;

CREATE TABLE #Person
(
    [BusinessEntityID] INT,
    [FirstName] NVARCHAR(50),
    [LastName] NVARCHAR(50)
);

INSERT INTO
    #Person
    (
        [BusinessEntityID],
        [FirstName],
        [LastName]
    )
SELECT
    [BusinessEntityID] = node.value('ID[1]', 'INT'),
    [FirstName] = node.value('FirstName[1]', 'NVARCHAR(50)'),
    [LastName] = node.value('LastName[1]', 'NVARCHAR(50)')
FROM
    @xml.nodes('/Persons/Person') AS xml(node);
GO


-- Вывести на экран название отдела, где работает каждый сотрудник в настоящий момент

SELECT
    [EmployeeDepartmentHistory].[BusinessEntityID],
    [JobTitle],
    [Department].[DepartmentID],
    [Name]
FROM [HumanResources].[EmployeeDepartmentHistory]
JOIN [HumanResources].[Employee]
    ON [EmployeeDepartmentHistory].[BusinessEntityID] = [Employee].[BusinessEntityID]
JOIN [HumanResources].[Department]
    ON [EmployeeDepartmentHistory].[DepartmentID] = [Department].[DepartmentID];
GO

-- Вывести на экран количество сотрудников в каждом отделе

SELECT
    [Department].[DepartmentID],
    [Name],
    COUNT(*) AS [EmpCount]
FROM [HumanResources].[Department]
JOIN [HumanResources].[EmployeeDepartmentHistory]
    ON [Department].[DepartmentID] = [EmployeeDepartmentHistory].[DepartmentID]
JOIN [HumanResources].[Employee]
    ON [EmployeeDepartmentHistory].[BusinessEntityID] = [HumanResources].[Employee].[BusinessEntityID]
GROUP BY [Department].[DepartmentID], [Name];
GO

-- Вывести на экран отчет истории изменения почасовых ставок в следующем формате:
-- The rate for [JobTitle] was set to [Rate] on [RateChangeDate]

SELECT
    [JobTitle],
    [Rate],
    [RateChangeDate],
    CONCAT('The rate for ', [JobTitle], ' was set to ', [Rate], ' on ', Convert(date, [RateChangeDate])) AS 'Report'
FROM [HumanResources].[Employee]
JOIN [HumanResources].[EmployeePayHistory]
    ON [Employee].[BusinessEntityID] = [EmployeePayHistory].[BusinessEntityID]
GO

-- Task 1

SELECT [DepartmentID], [Name] FROM [AdventureWorks2012].[HumanResources].[Department]
WHERE Name LIKE 'P%'

-- Task 2

SELECT 
	[BusinessEntityID],
	[JobTitle],
	[Gender],
	[VacationHours],
	[SickLeaveHours]
FROM [AdventureWorks2012].[HumanResources].[Employee]
WHERE VacationHours BETWEEN 10 AND 13

-- Task 3

SELECT 
	[BusinessEntityID],
	[JobTitle],
	[Gender],
	[BirthDate],
	[HireDate]
FROM [AdventureWorks2012].[HumanResources].[Employee]
WHERE MONTH(HireDate) = 7 AND DAY(HireDate) = 1
ORDER BY [BusinessEntityID] ASC
	OFFSET 3 ROWS
	FETCH NEXT 5 ROWS ONLY

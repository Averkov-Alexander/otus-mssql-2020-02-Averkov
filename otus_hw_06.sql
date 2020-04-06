USE WideWorldImporters;
--1. Посчитать среднюю цену товара, общую сумму продажи по месяцам
SELECT 
	FORMAT(EOMONTH(i.InvoiceDate),'MM.yyyy') AS MonthOfSale,
	AVG(il.UnitPrice) AS AvgPrice, 
	SUM(il.Quantity*il.UnitPrice) AS TotalAmount
FROM Sales.InvoiceLines AS il
INNER JOIN Sales.Invoices AS i
ON i.InvoiceID = il.InvoiceID
GROUP BY EOMONTH(i.InvoiceDate)
ORDER BY EOMONTH(i.InvoiceDate)
--2. Отобразить все месяцы, где общая сумма продаж превысила 10 000
SELECT
	FORMAT(EOMONTH(i.InvoiceDate),'MM.yyyy') AS MonthOfSale,
	SUM(il.Quantity * il.UnitPrice) AS TotalAmount
FROM Sales.Invoices AS i
INNER JOIN Sales.InvoiceLines AS il 
	ON i.InvoiceID = il.InvoiceID
GROUP BY EOMONTH(i.InvoiceDate)
HAVING SUM(il.Quantity * il.UnitPrice) > 10000
ORDER BY EOMONTH(i.InvoiceDate) 
--3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц.
SELECT
	YEAR(i.InvoiceDate) AS YearOfSale,
	EOMONTH(i.InvoiceDate) AS MonthOfSale,
	il.StockItemID,
	si.StockItemName,
	MIN(i.InvoiceDate) AS FirstSaleDate,
	SUM(il.Quantity*il.UnitPrice) AS TotalAmount,
	SUM(il.Quantity) AS TotalQuantity
FROM Sales.Invoices AS i
INNER JOIN Sales.InvoiceLines AS il
	ON i.InvoiceID = il.InvoiceID
INNER JOIN Warehouse.StockItems AS si
	ON il.StockItemID = si.StockItemID
GROUP BY il.StockItemID,si.StockItemName,YEAR(i.InvoiceDate),EOMONTH(i.InvoiceDate)
HAVING SUM(il.Quantity) < 50
ORDER BY YearOfSale, MonthOfSale

--4. Написать рекурсивный CTE sql запрос и заполнить им временную таблицу и табличную переменную
DROP TABLE IF EXISTS dbo.MyEmployees;
CREATE TABLE dbo.MyEmployees
(
EmployeeID smallint NOT NULL,
FirstName nvarchar(30) NOT NULL,
LastName nvarchar(40) NOT NULL,
Title nvarchar(50) NOT NULL,
DeptID smallint NOT NULL,
ManagerID int NULL,
CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC)
);
INSERT INTO dbo.MyEmployees VALUES
(1, N'Ken', N'Sánchez', N'Chief Executive Officer',16,NULL)
,(273, N'Brian', N'Welcker', N'Vice President of Sales',3,1)
,(274, N'Stephen', N'Jiang', N'North American Sales Manager',3,273)
,(275, N'Michael', N'Blythe', N'Sales Representative',3,274)
,(276, N'Linda', N'Mitchell', N'Sales Representative',3,274)
,(285, N'Syed', N'Abbas', N'Pacific Sales Manager',3,273)
,(286, N'Lynn', N'Tsoflias', N'Sales Representative',3,285)
,(16, N'David',N'Bradley', N'Marketing Manager', 4, 273)
,(23, N'Mary', N'Gibson', N'Marketing Specialist', 4, 16);

--SELECT * FROM dbo.MyEmployees;

WITH cteReports (EmpID, FirstName, LastName, Title, SupervisorID, EmpLevel, Path, Separator) AS
(
    SELECT EmployeeID, FirstName, LastName, Title, ManagerID, 1, CAST(EmployeeID AS varchar(MAX)) AS SortPath, CAST('' AS VARCHAR(MAX))
    FROM dbo.MyEmployees
    WHERE ManagerID IS NULL

    UNION ALL

    SELECT e.EmployeeID, e.FirstName, e.LastName, e.Title, e.ManagerID, r.EmpLevel + 1, r.Path + '\' + CAST(e.EmployeeID as varchar(MAX)) AS SortPath, r.Separator + CAST('|' AS VARCHAR(MAX))
    FROM dbo.MyEmployees AS e
    INNER JOIN cteReports AS r ON e.ManagerID = r.EmpID
)
SELECT
	EmpID,
	Separator + FirstName + ' ' + LastName AS Name,
	Title,
	Path
	--space(EmpLevel) + FirstName + ' ' + LastName AS Name,
    --EmpLevel,
    --(SELECT FirstName + ' ' + LastName FROM dbo.MyEmployees WHERE EmployeeID = cteReports.SupervisorID) AS ManagerName,	
FROM cteReports
ORDER BY Path

DROP TABLE dbo.MyEmployees;

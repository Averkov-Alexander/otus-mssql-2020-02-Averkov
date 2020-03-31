/****** Script for SelectTopNRows command from SSMS  ******/
USE WideWorldImporters;
--1. Выберите сотрудников, которые являются продажниками, и еще не сделали ни одной продажи.
SELECT PersonID,
	   FullName,
	   IsSalesperson
FROM WideWorldImporters.Application.People AS p
WHERE IsSalesperson = 1 AND p.PersonID NOT IN (SELECT DISTINCT s.LastEditedBy FROM WideWorldImporters.Sales.CustomerTransactions AS s WHERE s.TransactionTypeID = 3);
-- с использованием CTE
WITH Peoples_CTE (PersonID, FullName)
AS
(
SELECT PersonID, FullName
FROM WideWorldImporters.Application.People
WHERE IsSalesperson = 1
),
Sales_CTE (PersonID)
AS
(
SELECT DISTINCT s.LastEditedBy AS PersonID FROM WideWorldImporters.Sales.CustomerTransactions AS s WHERE s.TransactionTypeID = 3
)
SELECT PersonID,FullName FROM Peoples_CTE WHERE PersonID NOT IN (SELECT PersonID FROM Sales_CTE)

--2. Выберите товары с минимальной ценой (подзапросом), 2 варианта подзапроса.
--1-й вариант подзапроса
SELECT si.StockItemID, 
	   si.StockItemID, 
	   si.UnitPrice 
FROM Warehouse.StockItems AS si 
WHERE si.UnitPrice = (SELECT MIN(st.UnitPrice) FROM Warehouse.StockItems AS st)
--2-й вариант подзапроса
SELECT si.StockItemID, 
	   si.StockItemID, 
	   si.UnitPrice 
FROM Warehouse.StockItems AS si
	JOIN
	(SELECT MIN(UnitPrice) AS MaxPrice FROM Warehouse.StockItems) AS p
	ON si.UnitPrice = p.MaxPrice
--3. Выберите информацию по клиентам, которые перевели компании 5 максимальных платежей из [Sales].[CustomerTransactions] представьте 3 способа (в том числе с CTE)
-- вариант 1
SELECT CustomerID, CustomerName FROM Sales.Customers AS c
WHERE c.CustomerID IN 
	(SELECT TOP 5 ct.CustomerID
	 FROM Sales.CustomerTransactions AS ct
	 WHERE ct.TransactionTypeID = 3
	 ORDER BY ct.TransactionAmount DESC)
-- вариант 2
SELECT c.CustomerID, CustomerName FROM Sales.Customers AS c
JOIN
	(SELECT TOP 5 ct.CustomerID
	 FROM Sales.CustomerTransactions AS ct
	 WHERE ct.TransactionTypeID = 3
	 ORDER BY ct.TransactionAmount DESC) AS s
ON c.CustomerID = s.CustomerID
-- вариант 3 - с использованием CTE
WITH Customers_CTE (CustomerID, CustomerName)
AS
(
SELECT c.CustomerID, CustomerName FROM Sales.Customers AS c
),
SalesTop5 (CustomerID)
AS
(
SELECT TOP 5 ct.CustomerID
FROM Sales.CustomerTransactions AS ct
WHERE ct.TransactionTypeID = 3
ORDER BY ct.TransactionAmount DESC
)
SELECT CustomerID,CustomerName FROM Customers_CTE WHERE CustomerID IN (SELECT CustomerID FROM SalesTop5)
----4. Выберите города (ид и название), в которые были доставлены товары, входящие в тройку самых дорогих товаров, а также Имя сотрудника, который осуществлял упаковку заказов
--3 самых дорогих товара
WITH CTE_Top3MostExpensiveSI (StockItemID, UnitPrice)
AS
(
SELECT DISTINCT TOP 3 
	 il.StockItemID
	,il.UnitPrice
FROM Sales.InvoiceLines AS il
ORDER BY UnitPrice DESC
)
SELECT DISTINCT inv.CustomerID, cst.DeliveryCityID, cst.CityName, inv.PackedByPersonID, p.PersonID, p.FullName FROM CTE_Top3MostExpensiveSI
INNER JOIN
	(SELECT DISTINCT InvoiceID,StockItemID FROM Sales.InvoiceLines) AS i on i.StockItemID = CTE_Top3MostExpensiveSI.StockItemID
INNER JOIN
	(SELECT InvoiceID,PackedByPersonID,CustomerID FROM Sales.Invoices) AS inv on inv.InvoiceID = i.InvoiceID
INNER JOIN
	(
	SELECT
		cs.CustomerID,
		cs.DeliveryCityID,
		st.CityName
	FROM Sales.Customers AS cs
	INNER JOIN
		(SELECT CityID, CityName FROM Application.Cities) AS st ON cs.DeliveryCityID = st.CityID
	) AS cst ON cst.CustomerID = inv.CustomerID 
INNER JOIN
	(
	SELECT
		PersonID,
		FullName
	FROM Application.People) AS p on inv.PackedByPersonID = p.PersonID
--5. Объясните, что делает и оптимизируйте запрос:
--Запрос выбирает данные по накладным (инвойсам), общая сумма которых превышает 27 тыс. и присоединяет к ним данные о соответствующих заказах - выводит сумму полученных товаров и менеджера, который оформил заказх
SELECT Invoices.InvoiceID, 
	   Invoices.InvoiceDate,
       (SELECT People.FullName
			FROM Application.People
            WHERE (People.PersonID = Invoices.SalespersonPersonID)) AS SalesPersonName, SalesTotals.TotalSumm AS TotalSummByInvoice,
       (SELECT SUM(OrderLines.PickedQuantity * OrderLines.UnitPrice) AS Expr1
			FROM Sales.OrderLines
            WHERE (OrderLines.OrderId =
            (SELECT Orders.OrderId
				FROM Sales.Orders
				WHERE (Orders.PickingCompletedWhen IS NOT NULL) AND (Orders.OrderId = Invoices.OrderId)))) AS TotalSummForPickedItems
FROM Sales.Invoices INNER JOIN
 (SELECT InvoiceId, SUM(Quantity * UnitPrice) AS TotalSumm
   FROM Sales.InvoiceLines
   GROUP BY InvoiceId
   HAVING (SUM(Quantity * UnitPrice) > 27000)) AS SalesTotals ON Invoices.InvoiceID = SalesTotals.InvoiceId
ORDER BY TotalSummByInvoice DESC
--оптимизация
SELECT Invoices.InvoiceID, 
	   Invoices.InvoiceDate,
	   SalesTotals.TotalSumm AS TotalSummByInvoice,
	   P.FullName,
	   ISNULL(Ord.TotalSummForPickedItems,0) AS TotalSummForPickedItems
FROM Sales.Invoices 
INNER JOIN
 (SELECT InvoiceId, SUM(Quantity * UnitPrice) AS TotalSumm
   FROM Sales.InvoiceLines
   GROUP BY InvoiceId
   HAVING (SUM(Quantity * UnitPrice) > 27000)) AS SalesTotals ON Invoices.InvoiceID = SalesTotals.InvoiceId
INNER JOIN
(SELECT People.PersonId, People.FullName FROM Application.People) AS P ON P.PersonId = Invoices.SalespersonPersonID
LEFT JOIN
(SELECT OrderID, 
       (SELECT SUM(OrderLines.PickedQuantity * OrderLines.UnitPrice)
			FROM Sales.OrderLines
            WHERE (OrderLines.OrderId = Orders.OrderID)
			) AS TotalSummForPickedItems
FROM Sales.Orders 
WHERE Orders.PickingCompletedWhen IS NOT NULL) AS Ord ON Ord.OrderID = Invoices.OrderID
ORDER BY TotalSummByInvoice DESC

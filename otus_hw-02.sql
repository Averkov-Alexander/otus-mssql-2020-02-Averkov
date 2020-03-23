/****** ДЗ 02
1. Все товары, в которых в название есть пометка urgent или название начинается с Animal
******/

USE WideWorldImporters;

SELECT StockItemID
      ,StockItemName
FROM Warehouse.StockItems
WHERE StockItemName LIKE '%urgent%' OR StockItemName LIKE 'Animal%'

/******
2. Поставщиков, у которых не было сделано ни одного заказа (потом покажем как это делать через подзапрос, сейчас сделайте через JOIN)
******/
/* С использованием JOIN */
USE WideWorldImporters;
SELECT	s.SupplierID, 
		s.SupplierName, 
		p.PurchaseOrderID
FROM Purchasing.Suppliers AS s 
LEFT JOIN Purchasing.PurchaseOrders as p ON s.SupplierID = p.SupplierID
WHERE (p.PurchaseOrderID IS NULL)

/* без использования JOIN */
SELECT s.SupplierID,
	   s.SupplierName
FROM Purchasing.Suppliers AS s
WHERE s.SupplierID NOT IN (SELECT DISTINCT SupplierID FROM Purchasing.PurchaseOrders)

/****** 
3. Продажи с названием месяца, в котором была продажа, номером квартала, к которому относится продажа, 
включите также к какой трети года относится дата - каждая треть по 4 месяца, дата забора заказа должна быть задана, 
с ценой товара более 100$ либо количество единиц товара более 20. Добавьте вариант этого запроса с постраничной выборкой 
пропустив первую 1000 и отобразив следующие 100 записей. Соритровка должна быть по номеру квартала, трети года, дате продажи.
******/
USE [WideWorldImporters];

SELECT o.CustomerPurchaseOrderNumber AS 'Order number', 
	   DATENAME(mm, o.OrderDate) AS 'Mounth', 
	   DATENAME(Quarter, o.OrderDate) AS 'Quarter', 
	   CAST((DATEPART(mm, o.OrderDate) - 1) / 4 AS int) + 1 AS 'Third', 
	   i.UnitPrice AS 'Price', 
	   ol.Quantity
FROM Sales.Orders AS o INNER JOIN
	 Sales.OrderLines AS ol ON ol.OrderID = o.OrderID INNER JOIN
     Warehouse.StockItems AS i ON i.StockItemID = ol.StockItemID
WHERE (i.UnitPrice > 100) OR (ol.Quantity > 20);

WITH s AS
(
SELECT o.CustomerPurchaseOrderNumber AS 'Order number', 
	   DATENAME(mm, o.OrderDate) AS 'Mounth', 
	   DATENAME(Quarter, o.OrderDate) AS 'Quarter', 
	   CAST((DATEPART(mm, o.OrderDate) - 1) / 4 AS int) + 1 AS 'Third', 
	   i.UnitPrice AS 'Price', 
	   ol.Quantity,
	   ROW_NUMBER() OVER (ORDER BY CAST((DATEPART(mm, o.OrderDate) - 1) / 4 AS int) + 1) AS RowNumber
FROM Sales.Orders AS o INNER JOIN
	 Sales.OrderLines AS ol ON ol.OrderID = o.OrderID INNER JOIN
     Warehouse.StockItems AS i ON i.StockItemID = ol.StockItemID
WHERE (i.UnitPrice > 100) OR (ol.Quantity > 20)
)

SELECT * 
FROM s
WHERE RowNumber BETWEEN 1001 AND 1100

/******
4. Заказы поставщикам, которые были исполнены за 2014й год с доставкой Road Freight или Post, добавьте название поставщика, имя контактного лица принимавшего заказ
******/
-- -- запрос по видам доставки Road Freight или Post.
--SELECT * FROM Application.DeliveryMethods WHERE DeliveryMethodID IN (7,1);
USE WideWorldImporters;

SELECT o.PurchaseOrderID as 'Заказ',
	   --t.PurchaseOrderID as 'Заказ (из транзакции)',
	   o.LastEditedBy as 'Кто принял (ИД)',
	   p.FullName 'Кто принял (имя)', 
	   o.DeliveryMethodID as 'Способ доставки',
	   --t.SupplierTransactionID, 
	   t.SupplierID as 'Поставщик (ИД)',
	   s.SupplierName as 'Поставщик (имя)', 
	   t.FinalizationDate as 'Дата исполнения'
FROM Purchasing.PurchaseOrders AS o 
INNER JOIN Purchasing.SupplierTransactions AS t ON t.PurchaseOrderID = o.PurchaseOrderID AND o.DeliveryMethodID IN
			(SELECT DeliveryMethodID FROM Application.DeliveryMethods WHERE (DeliveryMethodName IN ('Post', 'Road Freight'))) AND t.FinalizationDate BETWEEN CONVERT(DATETIME, '2014-01-01 00:00:00', 102) AND CONVERT(DATETIME, '2014-12-31 23:59:59', 102)
INNER JOIN
Application.People AS p ON o.LastEditedBy = p.PersonID 
INNER JOIN Purchasing.Suppliers AS s ON o.SupplierID = s.SupplierID

/******
5. 10 последних по дате продаж с именем клиента и именем сотрудника, который оформил заказ.
*/

SELECT TOP(10)
	ct.CustomerTransactionID, 
	ct.CustomerID, 
	ct.TransactionDate, 
	ct.InvoiceID,
	c.CustomerName,
	p.FullName
FROM Sales.CustomerTransactions AS ct 
INNER JOIN
	Sales.Invoices  AS i ON ct.InvoiceID = i.InvoiceID 
INNER JOIN
	Sales.Customers AS c ON ct.CustomerID = c.CustomerID
INNER JOIN
	Application.People AS p ON i.SalespersonPersonID = p.PersonID 
ORDER BY ct.TransactionDate DESC

--6. Все ид и имена клиентов и их контактные телефоны, которые покупали товар Chocolate frogs 250g

SELECT DISTINCT c.CustomerID, c.CustomerName, c.PhoneNumber FROM sales.Customers AS c
INNER JOIN Sales.Orders AS o ON c.CustomerID = o.CustomerID
INNER JOIN sales.OrderLines AS ol ON o.OrderID = ol.OrderID
INNER JOIN Warehouse.StockItems AS si ON (si.StockItemID = ol.StockItemID) AND (si.StockItemName = 'Chocolate frogs 250g')
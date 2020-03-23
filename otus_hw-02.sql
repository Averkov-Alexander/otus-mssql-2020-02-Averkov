/****** �� 02
1. ��� ������, � ������� � �������� ���� ������� urgent ��� �������� ���������� � Animal
******/

USE WideWorldImporters;

SELECT StockItemID
      ,StockItemName
FROM Warehouse.StockItems
WHERE StockItemName LIKE '%urgent%' OR StockItemName LIKE 'Animal%'

/******
2. �����������, � ������� �� ���� ������� �� ������ ������ (����� ������� ��� ��� ������ ����� ���������, ������ �������� ����� JOIN)
******/
/* � �������������� JOIN */
USE WideWorldImporters;
SELECT	s.SupplierID, 
		s.SupplierName, 
		p.PurchaseOrderID
FROM Purchasing.Suppliers AS s 
LEFT JOIN Purchasing.PurchaseOrders as p ON s.SupplierID = p.SupplierID
WHERE (p.PurchaseOrderID IS NULL)

/* ��� ������������� JOIN */
SELECT s.SupplierID,
	   s.SupplierName
FROM Purchasing.Suppliers AS s
WHERE s.SupplierID NOT IN (SELECT DISTINCT SupplierID FROM Purchasing.PurchaseOrders)

/****** 
3. ������� � ��������� ������, � ������� ���� �������, ������� ��������, � �������� ��������� �������, 
�������� ����� � ����� ����� ���� ��������� ���� - ������ ����� �� 4 ������, ���� ������ ������ ������ ���� ������, 
� ����� ������ ����� 100$ ���� ���������� ������ ������ ����� 20. �������� ������� ����� ������� � ������������ �������� 
��������� ������ 1000 � ��������� ��������� 100 �������. ���������� ������ ���� �� ������ ��������, ����� ����, ���� �������.
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
4. ������ �����������, ������� ���� ��������� �� 2014� ��� � ��������� Road Freight ��� Post, �������� �������� ����������, ��� ����������� ���� ������������ �����
******/
-- -- ������ �� ����� �������� Road Freight ��� Post.
--SELECT * FROM Application.DeliveryMethods WHERE DeliveryMethodID IN (7,1);
USE WideWorldImporters;

SELECT o.PurchaseOrderID as '�����',
	   --t.PurchaseOrderID as '����� (�� ����������)',
	   o.LastEditedBy as '��� ������ (��)',
	   p.FullName '��� ������ (���)', 
	   o.DeliveryMethodID as '������ ��������',
	   --t.SupplierTransactionID, 
	   t.SupplierID as '��������� (��)',
	   s.SupplierName as '��������� (���)', 
	   t.FinalizationDate as '���� ����������'
FROM Purchasing.PurchaseOrders AS o 
INNER JOIN Purchasing.SupplierTransactions AS t ON t.PurchaseOrderID = o.PurchaseOrderID AND o.DeliveryMethodID IN
			(SELECT DeliveryMethodID FROM Application.DeliveryMethods WHERE (DeliveryMethodName IN ('Post', 'Road Freight'))) AND t.FinalizationDate BETWEEN CONVERT(DATETIME, '2014-01-01 00:00:00', 102) AND CONVERT(DATETIME, '2014-12-31 23:59:59', 102)
INNER JOIN
Application.People AS p ON o.LastEditedBy = p.PersonID 
INNER JOIN Purchasing.Suppliers AS s ON o.SupplierID = s.SupplierID

/******
5. 10 ��������� �� ���� ������ � ������ ������� � ������ ����������, ������� ������� �����.
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

--6. ��� �� � ����� �������� � �� ���������� ��������, ������� �������� ����� Chocolate frogs 250g

SELECT DISTINCT c.CustomerID, c.CustomerName, c.PhoneNumber FROM sales.Customers AS c
INNER JOIN Sales.Orders AS o ON c.CustomerID = o.CustomerID
INNER JOIN sales.OrderLines AS ol ON o.OrderID = ol.OrderID
INNER JOIN Warehouse.StockItems AS si ON (si.StockItemID = ol.StockItemID) AND (si.StockItemName = 'Chocolate frogs 250g')
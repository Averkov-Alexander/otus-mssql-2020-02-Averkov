-- 13. Хранимые процедуры и функции 
USE [WideWorldImporters]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
CREATE FUNCTION [Sales].[MaxSaleCustomer]
()
RETURNS int
WITH EXECUTE AS OWNER
AS
BEGIN
    DECLARE @CustomerID int;

	DECLARE Cur CURSOR FOR
	SELECT TOP(1)
		i.CustomerID
	FROM Sales.Invoices AS i
	INNER JOIN Sales.InvoiceLines AS il
		ON i.InvoiceID = il.InvoiceID
	GROUP BY i.CustomerID, i.OrderID
	ORDER BY SUM(il.Quantity*il.UnitPrice) DESC

	OPEN Cur
	FETCH NEXT FROM Cur INTO @CustomerID
	CLOSE Cur
	DEALLOCATE Cur

    RETURN @CustomerID;
END;
GO

--2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
CREATE FUNCTION [Sales].[CustomerTotalSaleAmount]
(
	@CustomerID int
)
RETURNS decimal(18,2)
WITH EXECUTE AS OWNER
AS
BEGIN
	DECLARE @CustomerTotalSaleAmount decimal(18,2)
	SELECT 
		@CustomerTotalSaleAmount = SUM(il.Quantity*il.UnitPrice)
	FROM Sales.Invoices AS i
	INNER JOIN Sales.InvoiceLines AS il
		ON i.InvoiceID = il.InvoiceID
	WHERE i.CustomerID = @CustomerID

    RETURN @CustomerTotalSaleAmount
END;
GO

--3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
-- данная хранимая процедура аналогична функции CustomerTotalSaleAmount
CREATE PROCEDURE [Sales].[Proc_CustomerTotalSaleAmount]
(
	@CustomerID int,
	@CustomerTotalSaleAmount decimal(18,2) OUTPUT
)
WITH EXECUTE AS OWNER
AS
BEGIN
	-- установим уровень изолированности READ UNCOMMITED для того чтобы избавиться от феномена "грязного чтения"
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	BEGIN TRANSACTION
		SELECT 
			@CustomerTotalSaleAmount = SUM(il.Quantity*il.UnitPrice)
		FROM Sales.Invoices AS i
		INNER JOIN Sales.InvoiceLines AS il
			ON i.InvoiceID = il.InvoiceID
		WHERE i.CustomerID = @CustomerID
	COMMIT
	RETURN
END;
GO

--4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла.
CREATE FUNCTION [Sales].[TopCustomerOrders]  
(    
   --входящие параметры и их тип
   @CustomerID INT,
   @TopNOrders INT
 )
 --возвращающее значение, т.е. таблица
 RETURNS TABLE
 AS
 --сразу возвращаем результат
RETURN 
(
    --сам запрос
    SELECT TOP(@TopNOrders) * FROM Sales.Orders WHERE CustomerID = @CustomerID ORDER BY OrderDate DESC
)
GO

-- пример использования функции с помощью CROSS APPLY
SELECT c.CustomerID, c.CustomerName, TopOrders.OrderID, TopOrders.OrderDate  
FROM 
Sales.Customers AS c
CROSS APPLY
(SELECT o.OrderID, o.OrderDate FROM Sales.TopCustomerOrders(c.CustomerID,5) as o) AS TopOrders;


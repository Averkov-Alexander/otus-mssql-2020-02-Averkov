--Тема #9. Операторы CROSS APPLY, PIVOT, CUBE 

USE WideWorldImporters;

DECLARE @DynamicPivotQuery AS NVARCHAR(MAX)
DECLARE @ColumnName AS NVARCHAR(MAX)

--SELECT @ColumnName= ISNULL(@ColumnName + ',','') + REPLACE(REPLACE(REPLACE(QUOTENAME(c.CustomerName),',',''),'(',''),')','')
SELECT @ColumnName = ISNULL(@ColumnName + ',','') + QUOTENAME(c.CustomerName)
FROM (SELECT CustomerName FROM Sales.Customers WHERE CustomerID IN (2,3,4,5,6)) AS c

SELECT @ColumnName;

SET @DynamicPivotQuery =
N'SELECT
	InvoiceMonth, ' + @ColumnName + '

FROM
(SELECT 
	FORMAT(EOMONTH(InvoiceDate),''dd.MM.yyyy'') AS InvoiceMonth, 
	c.CustomerName, 
	COUNT(InvoiceID) AS InvoiceCount 
	FROM Sales.Invoices AS i
	INNER JOIN Sales.Customers c
		ON i.CustomerID = c.CustomerID
	WHERE i.CustomerID IN (2,3,4,5,6)
	GROUP BY FORMAT(EOMONTH(InvoiceDate),''dd.MM.yyyy''), c.CustomerName
) AS src
PIVOT 
(
	SUM(InvoiceCount)
	FOR src.CustomerName IN (' + @ColumnName + ')
) AS SalesPivot';

--SELECT @DynamicPivotQuery 

--Execute the Dynamic Pivot Query
EXEC sp_executesql @DynamicPivotQuery

--2. Для всех клиентов с именем, в котором есть Tailspin Toys
-- вывести все адреса, которые есть в таблице, в одной колонке
SELECT
	CustomerName
	,AddressLine
	--,AddressColumn
FROM 
(
	SELECT
		CustomerName,
		DeliveryAddressLine1,
		DeliveryAddressLine2,
		PostalAddressLine1,
		PostalAddressLine2
	FROM Sales.Customers AS c
	WHERE c.CustomerName LIKE '%Tailspin Toys%'
) AS src
UNPIVOT
(
	AddressLine FOR AddressColumn IN ([DeliveryAddressLine1],[DeliveryAddressLine2],[PostalAddressLine1],[PostalAddressLine2])
) AS Address_Unpivot

--3. В таблице стран есть поля с кодом страны цифровым и буквенным
--сделайте выборку ИД страны, название, код - чтобы в поле был либо цифровой либо буквенный код
SELECT
	CountryID
	,CountryName
	,Code
FROM
(
	SELECT
		CountryID
		,CountryName
		,CAST(IsoAlpha3Code AS nvarchar(3)) AS IsoAlpha3Code
		,CAST(IsoNumericCode AS nvarchar(3)) AS IsoNumericCode
	FROM Application.Countries
) AS src
UNPIVOT
(
	Code FOR CodeColumn IN ([IsoAlpha3Code],[IsoNumericCode])
) AS Countries_Uvpivot

--4. Перепишите ДЗ из оконных функций через CROSS APPLY
--Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
--В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки

SELECT 
	c.CustomerID AS [ИД клиента], 
	c.CustomerName AS [Наименование],
	s.StockItemID AS [ИД Товара],
	s.UnitPrice AS [Цена],
	s.InvoiceDate AS [Дата покупки]
FROM Sales.Customers AS c
CROSS APPLY 
(
	SELECT DISTINCT TOP 2
			il.InvoiceID,
			i.InvoiceDate,
			il.UnitPrice,
			il.StockItemID	
		FROM Sales.Invoices AS i
		INNER JOIN Sales.InvoiceLines AS il
			ON i.InvoiceID = il.InvoiceID
		WHERE i.CustomerID = c.CustomerID
		--GROUP BY il.InvoiceID,il.UnitPrice,il.StockItemID
		ORDER BY il.UnitPrice DESC
 ) AS s;

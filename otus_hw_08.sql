USE WideWorldImporters;
set statistics time on;
-- 1. Напишите запрос с временной таблицей и перепишите его с табличной переменной. Сравните план
-- А) с временной таблицей:
SELECT 
	EOMONTH(i.InvoiceDate) As SaleMonth, 
	SUM(il.Quantity*il.UnitPrice) AS TotalAmount 
INTO #Sales
FROM
	Sales.Invoices AS i
INNER JOIN
	Sales.InvoiceLines AS il
ON i.InvoiceID = il.InvoiceID
WHERE i.InvoiceDate >= '2015-01-01'
GROUP BY EOMONTH(i.InvoiceDate);

SELECT * FROM #Sales AS S order by S.SaleMonth;

SELECT 
	t1.SaleMonth, 
	t1.TotalAmount,
	coalesce(sum(t2.TotalAmount), 0) as total
INTO #SalesByMonth
FROM #Sales t1
inner join #Sales t2
	 on t2.SaleMonth <= t1.SaleMonth
group by t1.SaleMonth, t1.TotalAmount
order by t1.SaleMonth

SELECT
	i.InvoiceID AS 'Id продажи', 
	i.InvoiceDate AS 'Дата продажи', 
	SUM(il.Quantity*il.UnitPrice) AS 'Сумма продажи', 
	sm.Total AS 'Итого за месяц'
FROM Sales.Invoices AS i
INNER JOIN #SalesByMonth As sm
	ON EOMONTH(i.InvoiceDate) = sm.SaleMonth
INNER JOIN Sales.InvoiceLines AS il
	ON i.InvoiceID = il.InvoiceID
WHERE i.InvoiceDate >= '2015-01-01'
GROUP BY i.InvoiceID, i.InvoiceDate, i.InvoiceDate, sm.total
ORDER BY i.InvoiceDate

DROP TABLE #SalesByMonth;

-- Б) с табличной переменной
DECLARE @SalesTab AS Table(  
    SaleMonth date,  
    TotalAmount int);

DECLARE @SalesByMonthTab AS Table(  
    SaleMonth date,  
    TotalAmount int,
	total int);
	
--SELECT * FROM @SalesTab

INSERT INTO @SalesTab
SELECT EOMONTH(i.InvoiceDate) As SaleMonth, SUM(il.Quantity*il.UnitPrice) AS TotalAmount
FROM
	Sales.Invoices AS i
INNER JOIN
	Sales.InvoiceLines AS il
ON i.InvoiceID = il.InvoiceID
WHERE i.InvoiceDate >= '2015-01-01'
GROUP BY EOMONTH(i.InvoiceDate);

SELECT * FROM @SalesTab AS S order by S.SaleMonth;

INSERT INTO @SalesByMonthTab
SELECT t1.SaleMonth, t1.TotalAmount,
       coalesce(sum(t2.TotalAmount), 0) as total
FROM @SalesTab t1
inner join @SalesTab t2
	 on t2.SaleMonth <= t1.SaleMonth
group by t1.SaleMonth, t1.TotalAmount
order by t1.SaleMonth

SELECT i.InvoiceID AS 'Id продажи', i.InvoiceDate AS 'Дата продажи', SUM(il.Quantity*il.UnitPrice) AS 'Сумма продажи', sm.Total AS 'Итого за месяц'
FROM Sales.Invoices AS i
INNER JOIN @SalesByMonthTab As sm
	ON EOMONTH(i.InvoiceDate) = sm.SaleMonth
INNER JOIN Sales.InvoiceLines AS il
	ON i.InvoiceID = il.InvoiceID
WHERE i.InvoiceDate >= '2015-01-01'
GROUP BY i.InvoiceID, i.InvoiceDate, i.InvoiceDate, sm.total
ORDER BY i.InvoiceDate

-- В) Нарастающий итог с помощью оконных функций
SELECT 
	s.SaleMonth, 
	s.TotalAmount,
	sum(s.TotalAmount) OVER (ORDER BY s.SaleMonth 
                rows between UNBOUNDED PRECEDING and CURRENT ROW) as Total
--INTO #SalesByMonth
FROM #Sales AS s
order by s.SaleMonth

DROP TABLE #Sales;
--2. Вывести список 2х самых популярных продуктов (по кол-ву проданных) в каждом месяце за 2016й год (по 2 самых популярных продукта в каждом месяце)
WITH CTE_Sales AS
(
	SELECT 
		EOMONTH(i.InvoiceDate) As SaleMonth,
		il.StockItemId,
		SUM(il.Quantity) AS TotalQuantity,
		ROW_NUMBER() OVER (PARTITION BY EOMONTH(i.InvoiceDate) ORDER BY SUM(il.Quantity) DESC) AS RowNum
	--INTO #Sales
	FROM
		Sales.Invoices AS i
	INNER JOIN
		Sales.InvoiceLines AS il
	ON i.InvoiceID = il.InvoiceID
	WHERE 
		i.InvoiceDate >= '2016-01-01' AND i.InvoiceDate < '2017-01-01'
	GROUP BY EOMONTH(i.InvoiceDate), il.StockItemId
)
SELECT *
FROM CTE_Sales
WHERE CTE_Sales.RowNum < 3

--3. Функции одним запросом
SELECT
	s.StockItemID AS 'ID',
	s.StockItemName AS 'Наименование',
	s.Brand AS 'Брэнд',
	s.UnitPrice AS 'Цена',
	ROW_NUMBER() OVER (PARTITION BY LEFT(s.StockItemName,1) ORDER BY s.StockItemName) AS 'Порядковый номер по 1-му символу',
	COUNT(*) OVER (PARTITION BY 0) AS 'Общее количество',
	COUNT(*) OVER (PARTITION BY LEFT(s.StockItemName,1)) AS 'Количество по 1-му символу',
	LEAD(s.StockItemID) OVER(ORDER BY s.StockItemName) AS 'Следующий ID',
	LAG(s.StockItemID) OVER(ORDER BY s.StockItemName) AS 'Предыдущий ID',
	ISNULL(LAG(s.StockItemName,2) OVER(ORDER BY s.StockItemName),'No Items') AS 'Название товара 2 строки назад'
FROM Warehouse.StockItems AS s

--сформируйте 30 групп товаров по полю вес товара на 1 шт
SELECT
	*,
	NTILE(30) OVER(ORDER BY TypicalWeightPerUnit) GroupNumber
FROM Warehouse.StockItems AS si;

--4. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал
--В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки
WITH CTE_LastInvoicesByPersons AS
(
	SELECT DISTINCT
		p.PersonID,
		p.FullName,
		MAX(i.InvoiceID) OVER (PARTITION BY p.PersonID) AS LastInvoiceID
	FROM Application.People AS p
	LEFT JOIN Sales.Invoices AS i
		ON p.PersonID = i.SalespersonPersonID
	WHERE p.IsSalesperson = 1
)
SELECT 
	sp.PersonID,
	sp.FullName,
	c.CustomerID,
	c.CustomerName
FROM CTE_LastInvoicesByPersons AS sp
INNER JOIN Sales.Invoices AS i 
	ON sp.LastInvoiceID = i.InvoiceID
INNER JOIN Sales.Customers AS c
	ON i.CustomerID = c.CustomerID;

--5. Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
--В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки

WITH CTE_Sales AS
(
	SELECT 
		i.CustomerID AS [ИД клиента],
		c.CustomerName AS [Наименование клиента],
		i.InvoiceDate AS [Дата покупки],
		il.StockItemId [ИД товара],
		MAX(il.UnitPrice) AS [Цена товара],
		ROW_NUMBER() OVER (PARTITION BY i.CustomerID ORDER BY MAX(il.UnitPrice) DESC) AS [Номер в группе]
	--INTO #Sales
	FROM
		Sales.Invoices AS i
	INNER JOIN Sales.InvoiceLines AS il
		ON i.InvoiceID = il.InvoiceID
	INNER JOIN Sales.Customers AS c
		ON i.CustomerID = c.CustomerID
	GROUP BY i.CustomerID, c.CustomerName, i.InvoiceDate, il.StockItemId
)
SELECT *
FROM CTE_Sales
WHERE CTE_Sales.[Номер в группе] < 3
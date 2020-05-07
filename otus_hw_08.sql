USE WideWorldImporters;
set statistics time on;
-- 1. Íàïèøèòå çàïðîñ ñ âðåìåííîé òàáëèöåé è ïåðåïèøèòå åãî ñ òàáëè÷íîé ïåðåìåííîé. Ñðàâíèòå ïëàí
-- À) ñ âðåìåííîé òàáëèöåé:
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
	i.InvoiceID AS 'Id ïðîäàæè', 
	i.InvoiceDate AS 'Äàòà ïðîäàæè', 
	SUM(il.Quantity*il.UnitPrice) AS 'Ñóììà ïðîäàæè', 
	sm.Total AS 'Èòîãî çà ìåñÿö'
FROM Sales.Invoices AS i
INNER JOIN #SalesByMonth As sm
	ON EOMONTH(i.InvoiceDate) = sm.SaleMonth
INNER JOIN Sales.InvoiceLines AS il
	ON i.InvoiceID = il.InvoiceID
WHERE i.InvoiceDate >= '2015-01-01'
GROUP BY i.InvoiceID, i.InvoiceDate, i.InvoiceDate, sm.total
ORDER BY i.InvoiceDate

DROP TABLE #SalesByMonth;

-- Á) ñ òàáëè÷íîé ïåðåìåííîé
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

SELECT i.InvoiceID AS 'Id ïðîäàæè', i.InvoiceDate AS 'Äàòà ïðîäàæè', SUM(il.Quantity*il.UnitPrice) AS 'Ñóììà ïðîäàæè', sm.Total AS 'Èòîãî çà ìåñÿö'
FROM Sales.Invoices AS i
INNER JOIN @SalesByMonthTab As sm
	ON EOMONTH(i.InvoiceDate) = sm.SaleMonth
INNER JOIN Sales.InvoiceLines AS il
	ON i.InvoiceID = il.InvoiceID
WHERE i.InvoiceDate >= '2015-01-01'
GROUP BY i.InvoiceID, i.InvoiceDate, i.InvoiceDate, sm.total
ORDER BY i.InvoiceDate

-- Â) Íàðàñòàþùèé èòîã ñ ïîìîùüþ îêîííûõ ôóíêöèé
SELECT 
	s.SaleMonth, 
	s.TotalAmount,
	sum(s.TotalAmount) OVER (ORDER BY s.SaleMonth 
                rows between UNBOUNDED PRECEDING and CURRENT ROW) as Total
--INTO #SalesByMonth
FROM #Sales AS s
order by s.SaleMonth

DROP TABLE #Sales;
--2. Âûâåñòè ñïèñîê 2õ ñàìûõ ïîïóëÿðíûõ ïðîäóêòîâ (ïî êîë-âó ïðîäàííûõ) â êàæäîì ìåñÿöå çà 2016é ãîä (ïî 2 ñàìûõ ïîïóëÿðíûõ ïðîäóêòà â êàæäîì ìåñÿöå)
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

--3. Ôóíêöèè îäíèì çàïðîñîì
SELECT
	s.StockItemID AS 'ID',
	s.StockItemName AS 'Íàèìåíîâàíèå',
	s.Brand AS 'Áðýíä',
	s.UnitPrice AS 'Öåíà',
	ROW_NUMBER() OVER (PARTITION BY LEFT(s.StockItemName,1) ORDER BY s.StockItemName) AS 'Ïîðÿäêîâûé íîìåð ïî 1-ìó ñèìâîëó',
	COUNT(*) OVER (PARTITION BY 0) AS 'Îáùåå êîëè÷åñòâî',
	COUNT(*) OVER (PARTITION BY LEFT(s.StockItemName,1)) AS 'Êîëè÷åñòâî ïî 1-ìó ñèìâîëó',
	LEAD(s.StockItemID) OVER(ORDER BY s.StockItemName) AS 'Ñëåäóþùèé ID',
	LAG(s.StockItemID) OVER(ORDER BY s.StockItemName) AS 'Ïðåäûäóùèé ID',
	ISNULL(LAG(s.StockItemName,2) OVER(ORDER BY s.StockItemName),'No Items') AS 'Íàçâàíèå òîâàðà 2 ñòðîêè íàçàä'
FROM Warehouse.StockItems AS s

--ñôîðìèðóéòå 30 ãðóïï òîâàðîâ ïî ïîëþ âåñ òîâàðà íà 1 øò
SELECT
	*,
	NTILE(30) OVER(ORDER BY TypicalWeightPerUnit) GroupNumber
FROM Warehouse.StockItems AS si;

--4. Ïî êàæäîìó ñîòðóäíèêó âûâåäèòå ïîñëåäíåãî êëèåíòà, êîòîðîìó ñîòðóäíèê ÷òî-òî ïðîäàë
--Â ðåçóëüòàòàõ äîëæíû áûòü èä è ôàìèëèÿ ñîòðóäíèêà, èä è íàçâàíèå êëèåíòà, äàòà ïðîäàæè, ñóììó ñäåëêè
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

--5. Âûáåðèòå ïî êàæäîìó êëèåíòó 2 ñàìûõ äîðîãèõ òîâàðà, êîòîðûå îí ïîêóïàë
--Â ðåçóëüòàòàõ äîëæíî áûòü èä êëèåòà, åãî íàçâàíèå, èä òîâàðà, öåíà, äàòà ïîêóïêè 

WITH CTE_Sales AS
(
	SELECT 
		i.CustomerID AS [ÈÄ êëèåíòà],
		c.CustomerName AS [Íàèìåíîâàíèå êëèåíòà],
		i.InvoiceDate AS [Äàòà ïîêóïêè],
		il.StockItemId [ÈÄ òîâàðà],
		MAX(il.UnitPrice) AS [Öåíà òîâàðà],
		ROW_NUMBER() OVER (PARTITION BY i.CustomerID ORDER BY MAX(il.UnitPrice) DESC) AS [Íîìåð â ãðóïïå]
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
WHERE CTE_Sales.[Íîìåð â ãðóïïå] < 3

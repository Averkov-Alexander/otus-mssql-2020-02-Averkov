USE WideWorldImporters;
set statistics time on;
-- 1. �������� ������ � ��������� �������� � ���������� ��� � ��������� ����������. �������� ����
-- �) � ��������� ��������:
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
	i.InvoiceID AS 'Id �������', 
	i.InvoiceDate AS '���� �������', 
	SUM(il.Quantity*il.UnitPrice) AS '����� �������', 
	sm.Total AS '����� �� �����'
FROM Sales.Invoices AS i
INNER JOIN #SalesByMonth As sm
	ON EOMONTH(i.InvoiceDate) = sm.SaleMonth
INNER JOIN Sales.InvoiceLines AS il
	ON i.InvoiceID = il.InvoiceID
WHERE i.InvoiceDate >= '2015-01-01'
GROUP BY i.InvoiceID, i.InvoiceDate, i.InvoiceDate, sm.total
ORDER BY i.InvoiceDate

DROP TABLE #SalesByMonth;

-- �) � ��������� ����������
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

SELECT i.InvoiceID AS 'Id �������', i.InvoiceDate AS '���� �������', SUM(il.Quantity*il.UnitPrice) AS '����� �������', sm.Total AS '����� �� �����'
FROM Sales.Invoices AS i
INNER JOIN @SalesByMonthTab As sm
	ON EOMONTH(i.InvoiceDate) = sm.SaleMonth
INNER JOIN Sales.InvoiceLines AS il
	ON i.InvoiceID = il.InvoiceID
WHERE i.InvoiceDate >= '2015-01-01'
GROUP BY i.InvoiceID, i.InvoiceDate, i.InvoiceDate, sm.total
ORDER BY i.InvoiceDate

-- �) ����������� ���� � ������� ������� �������
SELECT 
	s.SaleMonth, 
	s.TotalAmount,
	sum(s.TotalAmount) OVER (ORDER BY s.SaleMonth 
                rows between UNBOUNDED PRECEDING and CURRENT ROW) as Total
--INTO #SalesByMonth
FROM #Sales AS s
order by s.SaleMonth

DROP TABLE #Sales;
--2. ������� ������ 2� ����� ���������� ��������� (�� ���-�� ���������) � ������ ������ �� 2016� ��� (�� 2 ����� ���������� �������� � ������ ������)
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

--3. ������� ����� ��������
SELECT
	s.StockItemID AS 'ID',
	s.StockItemName AS '������������',
	s.Brand AS '�����',
	s.UnitPrice AS '����',
	ROW_NUMBER() OVER (PARTITION BY LEFT(s.StockItemName,1) ORDER BY s.StockItemName) AS '���������� ����� �� 1-�� �������',
	COUNT(*) OVER (PARTITION BY 0) AS '����� ����������',
	COUNT(*) OVER (PARTITION BY LEFT(s.StockItemName,1)) AS '���������� �� 1-�� �������',
	LEAD(s.StockItemID) OVER(ORDER BY s.StockItemName) AS '��������� ID',
	LAG(s.StockItemID) OVER(ORDER BY s.StockItemName) AS '���������� ID',
	ISNULL(LAG(s.StockItemName,2) OVER(ORDER BY s.StockItemName),'No Items') AS '�������� ������ 2 ������ �����'
FROM Warehouse.StockItems AS s

--����������� 30 ����� ������� �� ���� ��� ������ �� 1 ��
SELECT
	*,
	NTILE(30) OVER(ORDER BY TypicalWeightPerUnit) GroupNumber
FROM Warehouse.StockItems AS si;

--4. �� ������� ���������� �������� ���������� �������, �������� ��������� ���-�� ������
--� ����������� ������ ���� �� � ������� ����������, �� � �������� �������, ���� �������, ����� ������
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

--5. �������� �� ������� ������� 2 ����� ������� ������, ������� �� �������
--� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������

WITH CTE_Sales AS
(
	SELECT 
		i.CustomerID AS [�� �������],
		c.CustomerName AS [������������ �������],
		i.InvoiceDate AS [���� �������],
		il.StockItemId [�� ������],
		MAX(il.UnitPrice) AS [���� ������],
		ROW_NUMBER() OVER (PARTITION BY i.CustomerID ORDER BY MAX(il.UnitPrice) DESC) AS [����� � ������]
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
WHERE CTE_Sales.[����� � ������] < 3
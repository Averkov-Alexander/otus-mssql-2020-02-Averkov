/****** �� 02 
3. ������� � ��������� ������, � ������� ���� �������, ������� ��������, � �������� ��������� �������, 
�������� ����� � ����� ����� ���� ��������� ���� - ������ ����� �� 4 ������, ���� ������ ������ ������ ���� ������, 
� ����� ������ ����� 100$ ���� ���������� ������ ������ ����� 20. �������� ������� ����� ������� � ������������ �������� 
��������� ������ 1000 � ��������� ��������� 100 �������. ���������� ������ ���� �� ������ ��������, ����� ����, ���� �������.
******/
USE [WideWorldImporters];

-- ��� ������������� �������������
SELECT
	Sales.CustomerTransactions.CustomerTransactionID, Sales.CustomerTransactions.InvoiceID, 
	DATENAME(MONTH, Sales.CustomerTransactions.TransactionDate) AS Month_Name, 
	DATENAME(QUARTER, Sales.CustomerTransactions.TransactionDate) AS QuarterNumber, 
	CASE 
		WHEN MONTH(TransactionDate) <= 4 THEN 1 
		WHEN MONTH(TransactionDate) <= 8 THEN 2 
		ELSE 3 
	END AS ThirdOfYear, 
	Sales.CustomerTransactions.TaxAmount, 
	Sales.CustomerTransactions.TransactionAmount, 
	Sales.CustomerTransactions.FinalizationDate, 
	Invoices.MaxPrice, 
	Invoices.Quantity
FROM            Sales.CustomerTransactions INNER JOIN
                             (SELECT DISTINCT InvoiceID, MAX(UnitPrice) AS MaxPrice, SUM(Quantity) AS Quantity
                               FROM            Sales.InvoiceLines AS InvoiceLines_1
                               GROUP BY InvoiceID
                               HAVING         (MAX(UnitPrice) > 100) OR
                                                         (SUM(Quantity) > 20)) AS Invoices ON Sales.CustomerTransactions.InvoiceID = Invoices.InvoiceID
WHERE        (Sales.CustomerTransactions.FinalizationDate IS NOT NULL)
ORDER BY QuarterNumber, ThirdOfYear,TransactionDate;

SELECT
	Sales.CustomerTransactions.CustomerTransactionID, Sales.CustomerTransactions.InvoiceID, 
	DATENAME(MONTH, Sales.CustomerTransactions.TransactionDate) AS Month_Name, 
	DATENAME(QUARTER, Sales.CustomerTransactions.TransactionDate) AS QuarterNumber, 
	CASE 
		WHEN MONTH(TransactionDate) <= 4 THEN 1 
		WHEN MONTH(TransactionDate) <= 8 THEN 2 
		ELSE 3 
	END AS ThirdOfYear, 
	Sales.CustomerTransactions.TaxAmount, 
	Sales.CustomerTransactions.TransactionAmount, 
	Sales.CustomerTransactions.FinalizationDate, 
	Invoices.MaxPrice, 
	Invoices.Quantity
FROM            Sales.CustomerTransactions INNER JOIN
                             (SELECT DISTINCT InvoiceID, MAX(UnitPrice) AS MaxPrice, SUM(Quantity) AS Quantity
                               FROM            Sales.InvoiceLines AS InvoiceLines_1
                               GROUP BY InvoiceID
                               HAVING         (MAX(UnitPrice) > 100) OR
                                                         (SUM(Quantity) > 20)) AS Invoices ON Sales.CustomerTransactions.InvoiceID = Invoices.InvoiceID
WHERE        (Sales.CustomerTransactions.FinalizationDate IS NOT NULL)
ORDER BY QuarterNumber, ThirdOfYear,TransactionDate;

-- � �������������� �������������

WITH Sales AS
(
SELECT
	Sales.CustomerTransactions.CustomerTransactionID, Sales.CustomerTransactions.InvoiceID, 
	DATENAME(MONTH, Sales.CustomerTransactions.TransactionDate) AS Month_Name, 
	DATENAME(QUARTER, Sales.CustomerTransactions.TransactionDate) AS QuarterNumber, 
	CASE 
		WHEN MONTH(TransactionDate) <= 4 THEN 1 
		WHEN MONTH(TransactionDate) <= 8 THEN 2 
		ELSE 3 
	END AS ThirdOfYear, 
	Sales.CustomerTransactions.TaxAmount, 
	Sales.CustomerTransactions.TransactionAmount, 
	Sales.CustomerTransactions.FinalizationDate, 
	Invoices.MaxPrice, 
	Invoices.Quantity,
	ROW_NUMBER() OVER (ORDER BY DATENAME(QUARTER, Sales.CustomerTransactions.TransactionDate),
					   DATENAME(QUARTER, Sales.CustomerTransactions.TransactionDate), 
						CASE 
							WHEN MONTH(TransactionDate) <= 4 THEN 1 
							WHEN MONTH(TransactionDate) <= 8 THEN 2 
							ELSE 3 
						END) AS RowNumber
FROM            Sales.CustomerTransactions INNER JOIN
                             (SELECT DISTINCT InvoiceID, MAX(UnitPrice) AS MaxPrice, SUM(Quantity) AS Quantity
                               FROM            Sales.InvoiceLines AS InvoiceLines_1
                               GROUP BY InvoiceID
                               HAVING         (MAX(UnitPrice) > 100) OR
                                                         (SUM(Quantity) > 20)) AS Invoices ON Sales.CustomerTransactions.InvoiceID = Invoices.InvoiceID
WHERE        (Sales.CustomerTransactions.FinalizationDate IS NOT NULL)
)

SELECT * 
FROM Sales
WHERE RowNumber BETWEEN 1001 AND 1100
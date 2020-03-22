/****** ДЗ 02 
3. Продажи с названием месяца, в котором была продажа, номером квартала, к которому относится продажа, 
включите также к какой трети года относится дата - каждая треть по 4 месяца, дата забора заказа должна быть задана, 
с ценой товара более 100$ либо количество единиц товара более 20. Добавьте вариант этого запроса с постраничной выборкой 
пропустив первую 1000 и отобразив следующие 100 записей. Соритровка должна быть по номеру квартала, трети года, дате продажи.
******/
USE [WideWorldImporters];

-- без использования представлений
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

-- с использованием представлений

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
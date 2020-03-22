/****** ДЗ 02
5. 10 последних по дате продаж с именем клиента и именем сотрудника, который оформил заказ.
*/
USE WideWorldImporters;
SELECT TOP(10)
	CustomerTransactions.CustomerTransactionID, 
	CustomerTransactions.CustomerID, 
	CustomerTransactions.TransactionDate, 
	CustomerTransactions.InvoiceID,
	Customers.CustomerName,
	People.FullName
FROM Sales.CustomerTransactions AS CustomerTransactions 
INNER JOIN
	Sales.Invoices  AS Invoices ON CustomerTransactions.InvoiceID = Invoices.InvoiceID 
INNER JOIN
	Sales.Customers AS Customers ON CustomerTransactions.CustomerID = Customers.CustomerID
INNER JOIN
	Application.People AS People ON Invoices.SalespersonPersonID = People.PersonID 
ORDER BY CustomerTransactions.TransactionDate DESC
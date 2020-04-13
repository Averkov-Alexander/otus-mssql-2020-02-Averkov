USE WideWorldImporters;
--1. Äîâñòàâëÿòü â áàçó 5 çàïèñåé èñïîëüçóÿ insert â òàáëèöó Customers èëè Suppliers
IF NOT EXISTS(SELECT TOP 1 1 FROM Sales.Customers WHERE CustomerName LIKE '%W07')
BEGIN
INSERT INTO Sales.Customers
	(CustomerName,
	BillToCustomerID,
	CustomerCategoryID,
	PrimaryContactPersonID,
	DeliveryMethodID,
	DeliveryCityID,
	PostalCityID,
	CreditLimit,
	AccountOpenedDate,
	StandardDiscountPercentage,
	IsStatementSent,IsOnCreditHold,
	PaymentDays,
	PhoneNumber,
	FaxNumber,
	WebsiteURL,
	DeliveryAddressLine1,
	DeliveryAddressLine2,
	DeliveryPostalCode,
	PostalAddressLine1,
	PostalAddressLine2,
	PostalPostalCode,
	LastEditedBy)
VALUES
	('BMW #HW07', 1, 3,3134,3,24805,24805,2100.00,'2013-01-01',0.000,0,0,7,'(218) 555-0100','(218) 555-0100','www.website.com','Shop 7','548 Bures Crescent','90647','Shop 7','548 Bures Crescent','90647',1),
	('Nissan #HW07', 1, 3,3134,3,24805,24805,2100.00,'2013-01-01',0.000,0,0,7,'(218) 555-0100','(218) 555-0100','www.website.com','Shop 7','548 Bures Crescent','90647','Shop 7','548 Bures Crescent','90647',1),
	('Audi #HW07', 1, 3,3134,3,24805,24805,2100.00,'2013-01-01',0.000,0,0,7,'(218) 555-0100','(218) 555-0100','www.website.com','Shop 7','548 Bures Crescent','90647','Shop 7','548 Bures Crescent','90647',1),
	('Toyota #HW07', 1, 3,3134,3,24805,24805,2100.00,'2013-01-01',0.000,0,0,7,'(218) 555-0100','(218) 555-0100','www.website.com','Shop 7','548 Bures Crescent','90647','Shop 7','548 Bures Crescent','90647',1),
	('Volkswagen #HW07', 1, 3,3134,3,24805,24805,2100.00,'2013-01-01',0.000,0,0,7,'(218) 555-0100','(218) 555-0100','www.website.com','Shop 7','548 Bures Crescent','90647','Shop 7','548 Bures Crescent','90647',1);
END;
--ïðîâåðèì, ÷òî çàïèñè äîáàâèëèñü
SELECT * FROM Sales.Customers WHERE CustomerName Like '%HW07%';
--2. óäàëèòå 1 çàïèñü èç Customers, êîòîðàÿ áûëà âàìè äîáàâëåíà
DELETE FROM Sales.Customers
WHERE CustomerName = 'Volkswagen #HW07'; 
--3. èçìåíèòü îäíó çàïèñü, èç äîáàâëåííûõ ÷åðåç UPDATE
UPDATE Sales.Customers
Set CustomerName = CustomerName + ' #UPD'
FROM Sales.Customers
WHERE CustomerName = 'Toyota #HW07'
--4. Íàïèñàòü MERGE, êîòîðûé âñòàâèò çàïèñü â êëèåíòû, åñëè åå òàì íåò, è èçìåíèò åñëè îíà óæå åñòü
MERGE Sales.Customers AS Target
USING (
SELECT
	CustomerID,
	CASE WHEN CustomerName = 'BMW #HW07' THEN 
		'BMW #HW07 Modifed' 
	ELSE 
		CustomerName 
	END AS CustomerName,
	BillToCustomerID,
	CustomerCategoryID,
	PrimaryContactPersonID,
	DeliveryMethodID,
	DeliveryCityID,
	PostalCityID,
	CreditLimit,
	AccountOpenedDate,
	StandardDiscountPercentage,
	IsStatementSent,IsOnCreditHold,
	PaymentDays,
	PhoneNumber,
	FaxNumber,
	WebsiteURL,
	DeliveryAddressLine1,
	DeliveryAddressLine2,
	DeliveryPostalCode,
	PostalAddressLine1,
	PostalAddressLine2,
	PostalPostalCode,
	LastEditedBy
FROM Sales.Customers WHERE CustomerName Like '%HW07%'
UNION
SELECT
	9999,'Mitsubishi #HW07',1, 3,3134,3,24805,24805,2100.00,'2013-01-01',0.000,0,0,7,'(218) 555-0100','(218) 555-0100','www.website.com','Shop 7','548 Bures Crescent','90647','Shop 7','548 Bures Crescent','90647',1 
)
AS source (CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, PrimaryContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy)
ON (target.CustomerID = Source.CustomerID)
WHEN MATCHED 
	THEN UPDATE SET CustomerName = source.CustomerName
WHEN NOT MATCHED
	THEN INSERT (CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, PrimaryContactPersonID, DeliveryMethodID, DeliveryCityID, PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent, IsOnCreditHold, PaymentDays, PhoneNumber, FaxNumber, WebsiteURL, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy)
		VALUES (source.CustomerID, source.CustomerName, source.BillToCustomerID, source.CustomerCategoryID, source.PrimaryContactPersonID, source.DeliveryMethodID, source.DeliveryCityID, source.PostalCityID, source.CreditLimit, source.AccountOpenedDate, source.StandardDiscountPercentage, source.IsStatementSent, source.IsOnCreditHold, source.PaymentDays, source.PhoneNumber, source.FaxNumber, source.WebsiteURL, source.DeliveryAddressLine1, source.DeliveryAddressLine2, source.DeliveryPostalCode, source.PostalAddressLine1, source.PostalAddressLine2, source.PostalPostalCode, source.LastEditedBy)
OUTPUT $action, deleted.*, inserted.*;
--5. Íàïèøèòå çàïðîñ, êîòîðûé âûãðóçèò äàííûå ÷åðåç bcp out è çàãðóçèòü ÷åðåç bulk insert
-- äëÿ êîððåêòíîé ðàáîòû ïðèìåðà íåîáõîäèìî íèæå ïî òåêñòó çàìåíèòü:
--à) èìÿ ôàéëà â êîòîðûé áóäóò âûãðóæåíû äàííûå íà ñâî¸:
--C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\Backup\Customers.txt
--á) èìÿ ñåðâåðà íà ñâî¸
--HP-17AK014UR\SQLEXPRESS

EXEC sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE;  
GO  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
RECONFIGURE;
GO
exec master..xp_cmdshell 'BCP "SELECT TOP 10 * FROM WideWorldImporters.Sales.Customers" queryout "C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\Backup\Customers.txt" -T -c -S HP-17AK014UR\SQLEXPRESS';

SELECT * INTO Customers_Copy FROM Sales.Customers WHERE 0=1; --ñîçäà¸ì êîïèþ òàáëèöû
--SELECT * FROM Customers_Copy;
BULK INSERT Customers_Copy
   FROM "C:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\Backup\Customers.txt"
   WITH 
	 (
		BATCHSIZE = 1000,
		ROWTERMINATOR ='\n',
		KEEPNULLS,
		TABLOCK        
	  );
--ïðîâåðèì, ÷òî äàííûå â òàáëèöó çàãðóçèëèñü 
SELECT * FROM Customers_Copy;
--óäàëèì òàáëèöó
DROP TABLE Customers_Copy;

/****** ДЗ 02 
4. Заказы поставщикам, которые были исполнены за 2014й год с доставкой Road Freight или Post, добавьте название поставщика, имя контактного лица принимавшего заказ
******/
-- -- запрос по видам доставки Road Freight или Post.
--SELECT * FROM Application.DeliveryMethods WHERE DeliveryMethodID IN (7,1);
USE WideWorldImporters;

SELECT        Purchasing.SupplierTransactions.SupplierTransactionID, Purchasing.SupplierTransactions.SupplierID, Purchasing.SupplierTransactions.PurchaseOrderID, 
                        Purchasing.SupplierTransactions.FinalizationDate, Application.People.FullName, Purchasing.Suppliers.SupplierName, Purchasing.PurchaseOrders.LastEditedBy, Purchasing.PurchaseOrders.DeliveryMethodID
FROM            Purchasing.SupplierTransactions INNER JOIN
                         Purchasing.PurchaseOrders ON Purchasing.SupplierTransactions.PurchaseOrderID = Purchasing.PurchaseOrders.PurchaseOrderID AND Purchasing.PurchaseOrders.DeliveryMethodID IN (SELECT DeliveryMethodID FROM Application.DeliveryMethods WHERE DeliveryMethodName IN('Post','Road Freight')) AND 
                         Purchasing.SupplierTransactions.FinalizationDate BETWEEN CONVERT(DATETIME, '2014-01-01 00:00:00', 102) AND CONVERT(DATETIME, '2014-12-31 23:59:59', 102) INNER JOIN
                         Application.People ON Purchasing.PurchaseOrders.LastEditedBy = Application.People.PersonID INNER JOIN
                         Purchasing.Suppliers ON Purchasing.PurchaseOrders.SupplierID = Purchasing.Suppliers.SupplierID
--WHERE        (Purchasing.SupplierTransactions.FinalizationDate BETWEEN CONVERT(DATETIME, '2014-01-01 00:00:00', 102) AND CONVERT(DATETIME, '2014-12-31 23:59:59', 102))
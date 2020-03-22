/****** �� 02 
2. �����������, � ������� �� ���� ������� �� ������ ������ (����� ������� ��� ��� ������ ����� ���������, ������ �������� ����� JOIN)
******/
/* � �������������� JOIN */
USE WideWorldImporters;
SELECT        Suppliers.SupplierID, Suppliers.SupplierName, Purchasing.PurchaseOrders.PurchaseOrderID
FROM            Purchasing.Suppliers AS Suppliers LEFT OUTER JOIN
                         Purchasing.PurchaseOrders ON Suppliers.SupplierID = Purchasing.PurchaseOrders.SupplierID
WHERE PurchaseOrders.PurchaseOrderID IS NULL

/* ��� ������������� JOIN */
SELECT        Suppliers.SupplierID, Suppliers.SupplierName
FROM            Purchasing.Suppliers AS Suppliers
WHERE Suppliers.SupplierID NOT IN (SELECT DISTINCT SupplierID FROM Purchasing.PurchaseOrders)
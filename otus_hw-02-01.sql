/****** �� 02
1. ��� ������, � ������� � �������� ���� ������� urgent ��� �������� ���������� � Animal
******/

USE WideWorldImporters;

SELECT StockItemID
      ,StockItemName
FROM Warehouse.StockItems
WHERE StockItemName LIKE '%urgent%' OR StockItemName LIKE 'Animal%'
/****** ДЗ 02
1. Все товары, в которых в название есть пометка urgent или название начинается с Animal
******/

USE WideWorldImporters;

SELECT StockItemID
      ,StockItemName
FROM Warehouse.StockItems
WHERE StockItemName LIKE '%urgent%' OR StockItemName LIKE 'Animal%'
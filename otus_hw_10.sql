-- 12. Выборки из xml и json полей 
/* XML, JSON и динамический SQL
1. Загрузить данные из файла StockItems.xml в таблицу Warehouse.StockItems.
Существующие записи в таблице обновить, отсутствующие добавить сопоставлять записи по полю StockItemName).
Файл StockItems.xml в личном кабинете.*/

USE WideWorldImporters;

DECLARE @xml_doc XML;
DECLARE @docHandle int

SET @xml_doc = 
(SELECT *      
    FROM OPENROWSET (BULK 'C:\Users\averk.LAPTOP-V3KG4095\OneDrive\Документы\SQL Server Management Studio\OTUS ДЗ\10 XML, JSON и динамический SQL\StockItems.XML', SINGLE_CLOB)   
 AS xCol)

EXEC sp_xml_preparedocument @docHandle OUTPUT, @xml_doc

DROP TABLE IF EXISTS #StockItems;

SELECT *
INTO #StockItems
FROM OPENXML(@docHandle, N'/StockItems/Item', 3)
WITH
( 
	[StockItemName] nvarchar(50) '@Name',
	[SupplierID] int 'SupplierID',
	[LeadTimeDays] int 'LeadTimeDays',
	[IsChillerStock] int 'IsChillerStock',
	[TaxRate] decimal(18,3) 'TaxRate',
	[UnitPrice] decimal(18,2) 'UnitPrice',
	[UnitPackageID] int 'Package/UnitPackageID',
	[OuterPackageID] int 'Package/OuterPackageID',
	[QuantityPerOuter] int 'Package/QuantityPerOuter',
	[TypicalWeightPerUnit] decimal(18,3) 'Package/TypicalWeightPerUnit'
)

EXEC sp_xml_removedocument @docHandle

SELECT * FROM #StockItems

MERGE Warehouse.StockItems AS target 
USING (SELECT StockItemName, SupplierID, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit FROM #StockItems)
AS source (StockItemName, SupplierID, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit) 
ON
(target.StockItemName = source.StockItemName) 
WHEN MATCHED 
	THEN UPDATE SET SupplierID			 = source.SupplierID,
					LeadTimeDays		 = source.LeadTimeDays,
					IsChillerStock		 = source.IsChillerStock,
					TaxRate				 = source.TaxRate,
					UnitPrice			 = source.UnitPrice,
					UnitPackageID		 = source.UnitPackageID,
					OuterPackageID		 = source.UnitPackageID,
					QuantityPerOuter	 = source.QuantityPerOuter,
					TypicalWeightPerUnit = source.TypicalWeightPerUnit
WHEN NOT MATCHED 
	THEN INSERT (LastEditedBy, StockItemName, SupplierID, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit) 
		VALUES (1, source.StockItemName, source.SupplierID, source.LeadTimeDays, source.IsChillerStock, source.TaxRate, source.UnitPrice, source.UnitPackageID, source.OuterPackageID, source.QuantityPerOuter, source.TypicalWeightPerUnit) 
OUTPUT $action, deleted.*, inserted.*;

DROP TABLE IF EXISTS #StockItems;

/*2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml

--Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML.
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы. */

 -- FOR XML PATH
SELECT
    StockItemName AS [@Name],
    SupplierID AS [SupplierID],
	LeadTimeDays AS [LeadTimeDays],
	IsChillerStock AS [IsChillerStock],
	TaxRate AS [TaxRate],
	UnitPrice AS [UnitPrice],
	UnitPackageID AS [Package/UnitPackageID],
	OuterPackageID AS [Package/OuterPackageID],
	QuantityPerOuter AS [Package/QuantityPerOuter],
	TypicalWeightPerUnit AS [Package/TypicalWeightPerUnit]
FROM Warehouse.StockItems
FOR XML PATH('Item'), ROOT('StockItems')

--3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
--Написать SELECT для вывода:
--- StockItemID
--- StockItemName
--- CountryOfManufacture (из CustomFields)
--- FirstTag (из поля CustomFields, первое значение из массива Tags)

--1-ый вариант (без CROSS APPLY)
SELECT
	StockItemID,
	StockItemName,
	JSON_VALUE(CustomFields, '$.CountryOfManufacture') as CountryOfManufacture,
	JSON_VALUE(CustomFields, '$.Tags[0]') as FirstTag,
	CustomFields
FROM Warehouse.StockItems

--2-й вариант (с CROSS APPLY)
SELECT
	StockItemID,
	StockItemName,
	CustomFieldsArray.CountryOfManufacture,
	CustomFieldsArray.FirstTag
FROM Warehouse.StockItems
    CROSS APPLY 
		OPENJSON (CustomFields)
        WITH (
				CountryOfManufacture varchar(200) '$.CountryOfManufacture',
				FirstTag varchar(200) '$.Tags[0]'
             ) AS CustomFieldsArray

/* 4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести:
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле

Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено. */

SELECT
	StockItemID,
	StockItemName,
	[key],
	[value]
FROM Warehouse.StockItems
    CROSS APPLY 
		OPENJSON (CustomFields,'$.Tags')
WHERE [value] = 'Vintage'

--5. Пишем динамический PIVOT.
--По заданию из занятия “Операторы CROSS APPLY, PIVOT, CUBE”.
--Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
--Название клиента
--МесяцГод Количество покупок

DECLARE @DynamicPivotQuery AS NVARCHAR(MAX)
DECLARE @ColumnName AS NVARCHAR(MAX)

SELECT TOP 600 @ColumnName = ISNULL(@ColumnName + ',','') + QUOTENAME(c.CustomerName)
FROM (SELECT CustomerName FROM Sales.Customers) AS c

SELECT @ColumnName;

SET @DynamicPivotQuery =
N'SELECT
	InvoiceMonth, ' + @ColumnName + '

FROM
(SELECT 
	FORMAT(EOMONTH(InvoiceDate),''dd.MM.yyyy'') AS InvoiceMonth, 
	c.CustomerName, 
	COUNT(InvoiceID) AS InvoiceCount 
	FROM Sales.Invoices AS i
	INNER JOIN Sales.Customers c
		ON i.CustomerID = c.CustomerID
	GROUP BY FORMAT(EOMONTH(InvoiceDate),''dd.MM.yyyy''), c.CustomerName
) AS src
PIVOT 
(
	SUM(InvoiceCount)
	FOR src.CustomerName IN (' + @ColumnName + ')
) AS SalesPivot';

SELECT @DynamicPivotQuery 

--Execute the Dynamic Pivot Query
EXEC sp_executesql @DynamicPivotQuery

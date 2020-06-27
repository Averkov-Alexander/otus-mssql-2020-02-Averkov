sp_configure 'clr enabled', 1
go
reconfigure
go

CREATE ASSEMBLY CLRFunctions FROM 'C:\Users\averk.LAPTOP-V3KG4095\source\repos\SplitStrings_DLL\SplitStrings\bin\Debug\SplitStrings.dll'
go

CREATE FUNCTION [dbo].SplitStringCLR(@text [nvarchar](max), @delimiter [nchar](1))
RETURNS TABLE (
part nvarchar(max),
ID_ODER int
) WITH EXECUTE AS CALLER
AS
EXTERNAL NAME CLRFunctions.UserDefinedFunctions.SplitString

USE [WideWorldImporters]
GO  

select part from dbo.SplitStringCLR('11,22,33,44', ',')
/*
***********************************************************************************
******************************
NAME: EC_IT143_ec_it143_da_dataset
PURPOSE: To answer the business related question created by myself and other students using
this data set.
MODIFICATION LOG:
Ver Date Author Description
1.0 03/26/2024 CWeiss 1. Built this script for EC IT143

RUNTIME:
Xm Xs
NOTES:
This script was created to answer the business related quetions one could pose on this dataset.
I like it because there are 8 tables that can be joined in various ways to create interesting
questions.*/


SELECT GETDATE() AS my_date;

/*
Q1: Blade Hulse - I want to give a raise but I need to give to someone who deserves it. 
I want someone who made the most sales and profit to the company. 
Can you find the name of this person with their most used product and how much they sold?
A1: This was a challenging question to answer. This required that I use 4 tables inner joined,
create a view, and pull the remaining question from the view using a temporary table or CTE 
using the WITH clause and ROW_NUMBER for selecting the right rows. 
*/

USE EC_IT143_DA;
GO

SELECT e.EmployeeID, e.FirstName, e.LastName, FORMAT(sum(od.Quantity * p.price),'C','en-us') AS TotalSales
FROM dbo.employees AS e
	INNER JOIN dbo.orders AS o ON e.employeeid=o.EmployeeID
	INNER JOIN dbo.order_details AS od ON od.OrderID=o.OrderID
	INNER JOIN dbo.products AS p ON od.ProductID=p.ProductID
	GROUP BY e.EmployeeID,e.FirstName,e.LastName 
	ORDER BY 'totalsales' DESC;
	GO

DROP VIEW IF EXISTS dbo.v_TotalSalesPerProduct
GO

CREATE VIEW dbo.v_TotalSalesPerProduct
AS
SELECT e.EmployeeID, e.FirstName, e.LastName, p.ProductName, 
sum(od.Quantity * p.price) AS TotalSalesPerProduct

FROM dbo.employees AS e
	INNER JOIN dbo.orders AS o ON e.employeeid=o.EmployeeID
	INNER JOIN dbo.order_details AS od ON od.OrderID=o.OrderID
	INNER JOIN dbo.products AS p ON od.ProductID=p.ProductID
	GROUP BY e.EmployeeID,e.FirstName,e.LastName, p.ProductName
	;
GO

WITH added_row_number AS(
SELECT 
*,
ROW_NUMBER() OVER (PARTITION BY employeeid ORDER BY TotalSalesPerProduct DESC) AS row_number
FROM dbo.v_TotalSalesPerProduct
)
SELECT
*
FROM added_row_number
WHERE row_number = 1
ORDER BY TotalSalesPerProduct DESC
;
GO

/*
Q2: Chris Weiss (Me) - What are the average units per order and who do we ship those by?
A2: While a simple question this required two separate queries for me to figure it out.  
I joined 4 tables and grouped the quantity of units and showed them by shipper name. 
I also showed how many units were made by orderid and who we shiped those by.
*/

SELECT  sum(od.quantity) AS TotalUnitsShipped, s.ShipperName
FROM dbo.orders AS o
	JOIN dbo.order_details AS od ON o.OrderID=od.OrderID
	JOIN dbo.products AS p ON od.ProductID=p.ProductID
	JOIN dbo.shippers AS s ON s.ShipperID=o.ShipperID
	GROUP BY s.ShipperName
	ORDER BY TotalUnitsShipped DESC;
GO

SELECT  o.orderid, sum(od.quantity) AS TotalUnitsPerOrder, s.ShipperName
FROM dbo.orders AS o
	JOIN dbo.order_details AS od ON o.OrderID=od.OrderID
	JOIN dbo.products AS p ON od.ProductID=p.ProductID
	JOIN dbo.shippers AS s ON s.ShipperID=o.ShipperID
	GROUP BY o.OrderID, s.ShipperName
	ORDER BY TotalUnitsPerOrder DESC;

/*
Q3: Chris Weiss (Me) - What is our total sales by product in quantity, 
and how much was our total sales revenue based on price?
A3: 3 joined tables and figuring out how to group and order these to make the data
make sense.  Studying SQL order of opertions helped with these.
*/


SELECT p.ProductID, p.productname, SUM(od.quantity) AS UnitsSold, FORMAT(SUM(od.quantity*p.price),'C','en-us') AS TotalRevPerProduct
FROM dbo.orders AS o
	JOIN dbo.order_details AS od ON od.OrderID=o.OrderID
	JOIN dbo.products AS p ON p.ProductID=od.ProductID
	GROUP BY p.ProductID, p.ProductName
	ORDER BY UnitsSold DESC
	;

/*
Q4: Chris Weiss (Me) - Can you give a list by category of the number of units sold? 
This will help us determine our over or under performing categories.
A4: 4 joined tables and figuring out how to group and order these to make the data
make sense.  Studying SQL order of opertions helped with these.
*/


SELECT c.CategoryName, SUM(od.quantity) AS UnitsSold
FROM dbo.orders AS o
	JOIN dbo.order_details AS od ON od.OrderID=o.OrderID
	JOIN dbo.products AS p ON p.ProductID=od.ProductID
	JOIN dbo.categories AS c ON c.CategoryID=p.CategoryID
	GROUP BY c.CategoryName
	ORDER BY UnitsSold DESC
	;
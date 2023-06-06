/* 
Target market analysis of sales data to inform marketing answer management's questions. 
Skills showed: Date Functions, Time functions, Data Type Change, String Aggregation
*/
SELECT 
	TOP 10 * 
FROM PortfolioProjects..SalesData

--Total Revenue per Month
SELECT 
	DATENAME(MONTH, [Order Date]) AS Order_Month, 
	DATENAME(QUARTER, [Order Date]) AS Order_Quarter, 
	SUM(Revenue) AS Total_Revenue
FROM   PortfolioProjects..SalesData
WHERE [Order Date] < '2020-01-01' --excluding the year 2020 as data is incomplete
GROUP BY 
	DATENAME(MONTH, [Order Date]),
	DATENAME(QUARTER, [Order Date]),
	MONTH([Order Date])
ORDER BY MONTH([Order Date])

--Total Revenue per Location
SELECT 
	State, 
	City, 
	SUM(revenue) as Total_Revenue
FROM PortfolioProjects..SalesData
GROUP BY
	state, 
	City
ORDER BY
	State, 
	Total_Revenue DESC

--Total Revenue per Product
SELECT 
	Product, 
	SUM(revenue) as Total_Revenue
FROM PortfolioProjects..SalesData
GROUP BY Product
ORDER BY Total_Revenue DESC

--Total quantity ordered per Product
SELECT 
	Product, 
	SUM([Quantity Ordered]) as Total_Quantity
FROM PortfolioProjects..SalesData
GROUP BY Product
ORDER BY Total_Quantity DESC

--Total quantity ordered by the time of day with '1 PM' Format
WITH Quantity_by_Unformatted_Times AS 	
	(SELECT
		CAST(DATEPART(hour, [Order Time]) as INT) as unformated_time,
		SUM([Quantity Ordered]) as Total_Quantity
	FROM PortfolioProjects..SalesData
	GROUP BY DATEPART(hour, [Order Time]))
SELECT
	CASE	
		WHEN unformated_time = 0 THEN '12 AM'
		WHEN unformated_time < 12 THEN concat(unformated_time,' AM')
		WHEN unformated_time = 12 THEN '12 PM'
		ELSE concat(unformated_time-12, ' PM')
	END AS Time_of_Day, 
	Total_Quantity
FROM Quantity_by_Unformatted_Times
ORDER BY unformated_time


--Top 10 Products most often sold together
WITH Multiple_Product_Orders AS	
	(SELECT 
		[Order ID],
		STRING_AGG(Product, ', ') as Products --combining same-order products, seperated by a comma
	FROM PortfolioProjects..SalesData
	GROUP BY [Order ID]
	HAVING COUNT([Order ID])>1)
SELECT TOP 10
	Products,
	COUNT(*) as Number_of_Orders
FROM Multiple_Product_Orders
GROUP BY Products
ORDER BY Number_of_Orders DESC

--Probability that an order will be USB-C Charging Cable, iPhone, Google Phone or Wired Headphone
SELECT 
	Product, 
	ROUND(CAST(COUNT(DISTINCT [Order ID]) AS decimal)*100
	/ (SELECT COUNT(DISTINCT [Order ID]) FROM  PortfolioProjects..SalesData),2) as Probability
FROM PortfolioProjects..SalesData
WHERE Product IN ('USB-C Charging Cable', 'iPhone', 'Google Phone', 'Wired Headphones')
GROUP BY Product
ORDER BY Probability DESC
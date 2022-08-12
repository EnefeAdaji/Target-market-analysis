/* 
Sales data exploration for target market analysis. 
Skills showed: Date Functions, Time functions, Temporary tables, Joins, Window functions, Problem-solving
*/
Select * 
From PortfolioProjects..SalesData

--Revenue by Month
SELECT DATENAME(MONTH, [Order Date]) AS Month, DATENAME(QUARTER, [Order Date]) AS Quarter, SUM(Revenue) AS Total_Revenue_per_month
FROM   PortfolioProjects.dbo.SalesData
WHERE ([Order Date] <> '2020-01-01')
GROUP BY DATENAME(MONTH, [Order Date]), DATENAME(QUARTER, [Order Date]), MONTH([Order Date])
ORDER BY Quarter, MONTH([Order Date])

--Revenue by Location
Select State, City, SUM(revenue) as Total_Revenue
From PortfolioProjects..SalesData
Group by state, City
order by State, Total_Revenue DESC

--Revenue by Product
Select Product, SUM(revenue) as Total_Revenue
From PortfolioProjects..SalesData
Group by Product
order by Total_Revenue DESC

--Q ordered by Product
Select Product, SUM([Quantity Ordered]) as Total_Quantity_Ordered
From PortfolioProjects..SalesData
Group by Product
order by Total_Quantity_Ordered DESC

--Q ordered by time of day
Select Product, DATEPART(hour,[Order Time]) as Time,SUM([Quantity Ordered]) as Total_Quantity_Ordered
From PortfolioProjects..SalesData
Group by Product, DATEPART(hour,[Order Time])
order by DATEPART(hour,[Order Time]), Total_Quantity_Ordered desc

--Products most sold together
Drop Table if exists #NewTable
CREATE TABLE #NewTable
(
OrderID float
)
INSERT INTO #NewTable
SELECT [Order ID]
FROM PortfolioProjects..SalesData
Group by [Order ID]
Having count([Order ID])>1
Order by [Order ID]

select #NewTable.OrderID, Product, sum([Quantity Ordered]) as Quantity_ordered
FROM PortfolioProjects..SalesData as s1
Right JOIN
#NewTable
on s1.[Order ID]=#NewTable.OrderID
Group by  #NewTable.OrderID, Product
Order by #NewTable.OrderID

--Probability of ordering USB-C Charging Cable, Iphone, Google phone, wired headphone
Select c.Product, c.order_count, c.total_count, cast(c.order_count as decimal)/cast(c.total_count as decimal) as percent_order
from 
	(Select distinct(Product) as Product, count([Order ID]) over(partition by product) as order_count, 
	count([Order ID]) over() as total_count
	from PortfolioProjects..SalesData group by Product, [Order ID]) as c
JOIN PortfolioProjects..SalesData as s
On c.Product = s.Product
where c.Product IN ('USB-C Charging Cable', 'iphone', 'Google phone', 'Wired Headphones')
Group by c.Product, c.order_count, c.total_count
order by percent_order desc 
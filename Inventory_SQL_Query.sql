create database projectstore;
use  projectstore;


select * from sales;
select * from stores;
select * from inventory;
select * from products;
select * from calendar;


--Q1 Top Performing Products

create view Top_Products as
select distinct(A.Product_ID) ,  B.Product_Name , sum(A.Units) as 'Total Units Sold' , sum(Units*Product_Price) as 'Total Sales' ,sum(A.Units*(B.Product_Price - B.Product_Cost))  as 'Total Profit' 
from sales A
LEFT JOIN products B
ON A.Product_ID = B.Product_ID
group by A.product_ID , B.Product_Name  --For View
ORDER BY A.PRODUCT_ID; 


SELECT TOP 3 * FROM Top_Products
ORDER BY [Total Sales] DESC;


SELECT TOP 3 * FROM Top_Products
ORDER BY [Total Profit] DESC;


--Q2 Profit Margin  of TOP Stores

create view StorewiseProducts as
select A.Store_ID , A.Product_ID  , SUM(Units) as 'Total_Units' , Product_Cost , Product_Price  ,  SUM(Units)*Product_Cost  as 'UnitsXCost' ,
SUM(Units)*Product_Price  as 'UnitsXPrice'  
FROM SALES A
left join products B
ON A.Product_ID = B.Product_ID
GROUP BY A.Store_ID , A.Product_ID , Product_Cost , Product_Price
ORDER BY A.Store_ID , A.Product_ID

create view Top_Stores as
select Store_ID , sum(Total_Units) as 'Total_Units' , sum(UnitsXCost) as 'COGS', sum(UnitsXPrice)as 'Total_Sales' , 
sum(UnitsXPrice) - sum(UnitsXCost) as 'Total_Profit'   , ((sum(UnitsXPrice) - sum(UnitsXCost))/(sum(UnitsXPrice)))*100 as 'Profit_Margin'
from StorewiseProducts
group BY  Store_ID
order by Store_ID ;


SELECT TOP 10 * FROM Top_Stores
ORDER BY Profit_Margin DESC;

 
----Q3 3 Months Rolling Average

SELECT YEAR(Date)  , MONTH(DATE) , sum(Units) AS 'Total_Units', sum(Units*Product_Price) as 'Total_Sales' ,
AVG(sum(Units*Product_Price)) OVER (ORDER BY year(date) , month(date) ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS '3_Months_Rolling_Avg'
FROM SALES A
LEFT JOIN products B
ON A.PRODUCT_ID  = B.PRODUCT_ID
group by year(date) , month(date) 
ORDER BY year(date) , month(date)


-- Q4 Cumulative Profit Margin for Product Category


SELECT Product_Category,
	sum(Product_Cost) as 'Category_Cost' , 
	sum(Product_Price) as 'Category_Price',
    SUM(Product_Price - Product_Cost) AS 'Profit',
	(SUM(Product_Price - Product_Cost)/sum(Product_Price))*100 as 'Profit_Margin',
    SUM((SUM(Product_Price - Product_Cost)/sum(Product_Price))*100) OVER (ORDER BY product_category) AS 'Cumulative_Profit_Margin'
FROM
    PRODUCTS
GROUP BY
    Product_Category
ORDER BY
    Product_Category;



---Q5 Turnover Ratio


--Handling Null values of  Stock_On_Hand

create view StoreWiseInventory AS
SELECT A.Store_ID , A.Product_ID  , B.Stock_On_Hand as 'End_Inv' , A.Total_Units , 
(CASE WHEN B.Stock_On_Hand IS NULL THEN (A.Total_Units/2) ELSE (A.Total_Units+B.Stock_On_Hand) END ) as 'Start_Inv' ,  UnitsXCost,
(CASE WHEN B.Stock_On_Hand IS NULL THEN (A.Total_Units+B.Stock_On_Hand/2) ELSE (((A.Total_Units+B.Stock_On_Hand))+B.Stock_On_Hand)/2 END ) as 'Avg' ,
(CASE WHEN B.Stock_On_Hand IS NULL THEN (A.Total_Units+B.Stock_On_Hand/2)*Product_Cost ELSE ((((A.Total_Units+B.Stock_On_Hand))+B.Stock_On_Hand)/2)*Product_Cost END ) as 'Avg_Inv'
FROM StorewiseProducts A
LEFT JOIN inventory B
ON (A.Store_ID = B.Store_ID  and A.Product_ID = B.Product_ID)
ORDER BY A.Store_ID ,  A.Product_ID
;

SELECT * FROM StoreWiseInventory;


select Store_ID , sum(UnitsXCost) as 'COGS' , sum(Avg_Inv) as 'Total_Avg_Inv' , sum(UnitsXCost)/sum(Avg_Inv) as 'Turnover_Ratio'
from StoreWiseInventory
group by Store_ID
order by Store_ID;





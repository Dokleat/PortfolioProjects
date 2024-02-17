-- Effect of Car Color on Selling Price

SELECT Color, AVG(Price) AS Average_Sale_Price
FROM table1
GROUP BY Color
ORDER BY Average_Sale_Price DESC;

-- Analysis of Sales by Revenue Interval and Car Model

SELECT Model, 
       CASE
           WHEN Annual_Income < 50000 THEN 'Below 50k'
           WHEN Annual_Income BETWEEN 50000 AND 100000 THEN '50k-100k'
           WHEN Annual_Income BETWEEN 100001 AND 150000 THEN '100k-150k'
           ELSE 'Above 150k'
       END AS Income_Range,
       COUNT(*) AS Total_Sales
FROM table1
GROUP BY Model, 
         CASE
             WHEN Annual_Income < 50000 THEN 'Below 50k'
             WHEN Annual_Income BETWEEN 50000 AND 100000 THEN '50k-100k'
             WHEN Annual_Income BETWEEN 100001 AND 150000 THEN '100k-150k'
             ELSE 'Above 150k'
         END
ORDER BY Model, Income_Range;

-- Car Sales by Body Style and Region

SELECT Dealer_Region, Body_Style, COUNT(*) AS Total_Sales
FROM table1
GROUP BY Dealer_Region, Body_Style
ORDER BY Dealer_Region, Total_Sales DESC;

-- Dealer Performance Based on Pricing and Car Types

SELECT Dealer_Name, AVG(Price) AS Average_Price, COUNT(DISTINCT Model) AS Models_Offered
FROM table1
GROUP BY Dealer_Name
ORDER BY Average_Price DESC, Models_Offered DESC;

--Sales Trends Over Time and Seasonal Influence

SELECT YEAR(TRY_CONVERT(DATE, [Date], 103)) AS Year, MONTH(TRY_CONVERT(DATE, [Date], 103)) AS Month, COUNT(*) AS Total_Sales
FROM table1
GROUP BY YEAR(TRY_CONVERT(DATE, [Date], 103)), MONTH(TRY_CONVERT(DATE, [Date], 103))
ORDER BY Year, Month;

--Ranking of Car Models by Total Sales in Each Region

SELECT Dealer_Region, Model, COUNT(*) AS Total_Sales,
       RANK() OVER (PARTITION BY Dealer_Region ORDER BY COUNT(*) DESC) AS Rank_In_Region
FROM table1
GROUP BY Dealer_Region, Model
ORDER BY Dealer_Region, Rank_In_Region;

--The Price Difference Between Each Car and the Average Price of Its Model

SELECT Model, Price,
       Price - AVG(Price) OVER (PARTITION BY Model) AS Difference_From_Model_Avg
FROM table1;

-- Creating View  to store data for later visualization

CREATE VIEW SalesOverview AS
SELECT 
    Dealer_Region,
    Model,
    Gender,
    AVG(Annual_Income) AS Avg_Annual_Income,
    AVG(Price) AS Avg_Sale_Price,
    COUNT(*) AS Total_Sales
FROM 
    table1
GROUP BY 
    Dealer_Region,
    Model,
    Gender;

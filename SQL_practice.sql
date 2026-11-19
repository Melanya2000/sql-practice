-- Challenge 1: Customer Tier Classification 
--Create a report showing each customer's name, total number of orders, total amount spent 
--(sum of UnitPrice * Quantity from Order Details), and a tier classification based on spending: 'VIP' (>$15,000), 'Gold' ($5,000-$15,000), 
--'Silver' ($1,000-$5,000), 'Bronze' (<$1,000). Sort by total spent descending. Handle customers with NULL values using COALESCE.
USE Northwind;

SELECT 
	c.CompanyName, c.CustomerID,
	COUNT(DISTINCT o.OrderID) AS OrderCount,
	CAST(COALESCE(SUM(od.UnitPrice * od.Quantity),0) AS DECIMAL(10,2)) AS Spent,
	 CASE 
        WHEN SUM(od.UnitPrice * od.Quantity) > 15000 THEN 'VIP'
        WHEN SUM(od.UnitPrice * od.Quantity) >= 5000 THEN 'Gold'
        WHEN SUM(od.UnitPrice * od.Quantity) >= 1000 THEN 'Silver'
        ELSE 'Bronze'
	END AS TierSpent
FROM Customers c 
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY c.CompanyName, c.CustomerID    
ORDER BY Spent DESC, c.CompanyName;

-- Challenge 2: Monthly Sales Performance with Status 
--Show monthly sales totals for 1997 (year from OrderDate). Display: Month (as 'January', 'February', etc. using CASE), 
--Total Orders, Total Revenue, and a Performance Status: 'Excellent' if revenue > $50,000, 'Good' if $30,000-$50,000, 
--'Average' if $15,000-$30,000, 'Needs Improvement' if < $15,000. Sort chronologically. Use CAST/CONVERT for date handling.
USE Northwind;

SELECT   MONTH(o.OrderDate) AS MonthNo,
         CASE MONTH(o.OrderDate)
             WHEN 1 THEN 'January'
             WHEN 2 THEN 'February' 
             WHEN 3 THEN 'March'
             WHEN 4 THEN 'April'
             WHEN 5 THEN 'May' 
             WHEN 6 THEN 'June'
             WHEN 7 THEN 'July' 
             WHEN 8 THEN 'August' 
             WHEN 9 THEN 'September'
             WHEN 10 THEN 'October'
             WHEN 11 THEN 'November'
             ELSE 'December'
    END AS MonthName,
    COUNT(DISTINCT o.OrderID) AS OrderCount,
    CAST(SUM(od.UnitPrice * od.Quantity * (1- od.Discount)) AS DECIMAL(10,2)) AS TotalRevenue,
    CASE
             WHEN SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) > 50000  THEN 'Excellent'
             WHEN SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) >= 30000 THEN 'Good'
             WHEN SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) >= 15000 THEN 'Average'
             ELSE 'Needs Improvement'
         END AS PerformanceStatus
FROM Orders o 
JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE YEAR(OrderDate) = 1997
GROUP BY MONTH(o.OrderDate)   
ORDER BY MONTH(o.OrderDate) 

    -- Challenge 3: Category Performance Dashboard 
    --Create a category analysis showing: Category Name, Number of Products, Average Product Price, 
    --Total Units in Stock, Stock Status ('Overstocked' if avg units > 50, 'Well Stocked' if 20-50, 
    --'Low Stock' if 10-20, 'Critical' if < 10), and Revenue Potential (avg price * total units). 
    --Only show categories with more than 5 products. Sort by revenue potential descending.

USE Northwind;

SELECT ca.CategoryName, ca.CategoryID, COUNT(p.ProductID) AS ProductCount, 
       CAST(AVG(p.UnitPrice) AS DECIMAL(10,2)) AS AvgPrice,
       SUM(p.UnitsInStock) AS TotalInStock,
       CASE
        WHEN AVG(p.UnitsInStock) < 10 THEN 'Critical'
        WHEN AVG(p.UnitsInStock) < 20 THEN 'Low Stock'
        WHEN AVG(p.UnitsInStock) <= 50 THEN 'Well Stocked'
        Else 'Overstocked'
       END AS StockStatus,
       CAST(AVG(p.UnitPrice) AS DECIMAL(10,2)) * SUM(p.UnitsInStock) AS RevenuePotential
FROM Categories ca 
LEFT JOIN Products p ON ca.CategoryID = p.CategoryID
GROUP BY ca.CategoryName, ca.CategoryID
HAVING COUNT(p.ProductID) > 5
ORDER BY RevenuePotential DESC


-- Challenge 4: Employee Sales Leaderboard with Regions 
--Show employee sales performance: Full Name (FirstName + LastName), Title, Region (use COALESCE to show 'Unassigned' if NULL), 
--Total Orders Processed, Total Revenue Generated, Average Order Value, and Performance Rating: 'Top Performer' (revenue > $100k), 
--'High Performer' ($50k-$100k), 'Good Performer' ($25k-$50k), 'Developing' (< $25k). 
--Only include employees who processed at least 10 orders. Sort by total revenue descending.

USE Northwind;

SELECT e.FirstName +' ' + e.LastName AS FullName, e.EmployeeID,
       e.Title, COALESCE(e.Region,'Unassigned') AS Region,
       COUNT(DISTINCT o.OrderID) AS OrdersCount, 
       CAST(SUM(od.UnitPrice * od.Quantity * (1- od.Discount)) AS DECIMAL(10,2)) AS TotalRevenue,
       CAST(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))
              / COUNT(DISTINCT o.OrderID) AS DECIMAL(10,2)) AS AvgOrderValue,
       CASE
        WHEN CAST(SUM(od.UnitPrice * od.Quantity * (1- od.Discount)) AS DECIMAL(10,2))< 25000 THEN 'Developing'
        WHEN CAST(SUM(od.UnitPrice * od.Quantity * (1- od.Discount)) AS DECIMAL(10,2))< 50000 THEN 'Good Performer'
        WHEN CAST(SUM(od.UnitPrice * od.Quantity * (1- od.Discount)) AS DECIMAL(10,2))< 100000 THEN 'High Performer'
        ELSE 'Top Performer'
        END AS PerformanceRating
FROM Employees e 
LEFT JOIN Orders o ON e.EmployeeID = o.EmployeeID
LEFT JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY e.EmployeeID, e.FirstName +' ' + e.LastName, e.Title,  COALESCE(e.Region,'Unassigned')
HAVING   COUNT(DISTINCT o.OrderID) >= 10
ORDER BY TotalRevenue DESC;

-- Challenge 5: Discount Analysis by Product Type 
--Analyze discounts for products whose names contain specific patterns. Show: 
--Product Name, Category Name, Average Discount Given (as percentage, e.g., '15.5%'), 
--Total Quantity Sold, Discount Impact ('High Impact' if avg discount > 15%, 'Medium' 5-15%, 'Low' < 5%). 
--Filter for products where ProductName LIKE '%Chocolate%' OR LIKE '%Cheese%' OR LIKE '%Coffee%'.
--Only show products with at least 5 orders. Sort by average discount descending.
USE Northwind;

SELECT p.ProductName, ca.CategoryName, CAST(AVG(od.Discount) AS DECIMAL(10,2))*100AS AvgDis,
   SUM(od.Quantity) AS TotalSold, 
   CASE
        WHEN AVG(od.Discount) > 0.15 THEN 'High'
        WHEN AVG(od.Discount) >= 0.05 THEN 'Medium'
        ELSE 'Low'
    END AS DiscountImpact
FROM Products p
JOIN Categories ca on p.CategoryID = ca.CategoryID
JOIN [Order Details] od ON od.ProductID = p.ProductID
WHERE p.ProductName LIKE '%Chocolate%' OR p.ProductName LIKE '%Coffee%'  OR p.ProductName LIKE '%Cheese%'
GROUP BY p.ProductName, ca.CategoryName
HAVING   COUNT(DISTINCT od.OrderID) >= 5
ORDER BY AvgDis DESC

-- Challenge 6: Shipping Analysis by Country Group 
--Group countries into regions and analyze shipping: Show Region ('Europe' for countries IN ('Germany', 'France', 'UK', 'Spain', 'Italy'), 
--'Americas' for countries IN ('USA', 'Canada', 'Brazil', 'Argentina'), 'Other' for rest using CASE), 
--Total Orders, Average Freight Cost, Total Freight, Freight Category ('Premium' if avg > $50, 
--'Standard' $20-$50, 'Economy' < $20). Group by region, sort by total freight descending.
USE Northwind;

 SELECT 
    CASE
        WHEN o.ShipCountry IN ('Germany', 'France', 'UK', 'Spain', 'Italy') THEN 'Europe'
        WHEN o.ShipCountry IN ('USA', 'Canada', 'Brazil', 'Argentina') THEN 'Americas'
        ELSE 'Other'
    END AS Region,
    COUNT(o.OrderID) AS TotalOrder, 
    CAST(AVG(o.Freight) AS DECIMAL(10,2)) AvgFreight,
     CAST(SUM(o.Freight) AS DECIMAL(12,2))  AS TotalFreight,
    CASE
        WHEN AVG(o.Freight) > 50  THEN 'Premium'
        WHEN AVG(o.Freight) >= 20 THEN 'Standard'
        ELSE 'Economy'
    END AS FreightCategory
FROM Orders o
GROUP BY CASE
        WHEN o.ShipCountry IN ('Germany', 'France', 'UK', 'Spain', 'Italy') THEN 'Europe'
        WHEN o.ShipCountry IN ('USA', 'Canada', 'Brazil', 'Argentina') THEN 'Americas'
        ELSE 'Other'
    END
ORDER BY TotalFreight DESC

-- Challenge 7: Author Productivity Report 
--Show: Author Full Name (last, first format using concatenation), State (use COALESCE to show 'Unknown' if NULL),
--Number of Books Written, Total Sales Quantity, Average Price of Their Books (handle NULLs), 
--Author Category based on books: 'Prolific' (3+ books), 'Established' (2 books), 'Emerging' (1 book).
--Filter for authors whose last name starts with letters A-M (use LIKE). Sort by total sales quantity descending.
USE pubs;

WITH TitleSales AS (                  
    SELECT   title_id, SUM(qty) AS qty
    FROM     pubs.dbo.sales
    GROUP BY title_id
)
SELECT   a.au_id,
         a.au_lname + ', ' + a.au_fname        AS FullName,
         COALESCE(a.state, 'Unknown')    AS State,
         COUNT(ta.title_id)   AS BooksWritten,
         COALESCE(SUM(ts.qty), 0)  AS TotalSalesQty,
         CAST(AVG(t.price) AS DECIMAL(10,2))   AS AvgBookPrice,   
         CASE
             WHEN COUNT(ta.title_id) >= 3 THEN 'Prolific'
             WHEN COUNT(ta.title_id) = 2  THEN 'Established'
             WHEN COUNT(ta.title_id) = 1  THEN 'Emerging'
             ELSE 'No books yet'
         END  AS AuthorCategory
FROM     pubs.dbo.authors     AS a
LEFT JOIN pubs.dbo.titleauthor   AS ta ON ta.au_id    = a.au_id
LEFT JOIN pubs.dbo.titles  AS t  ON t.title_id  = ta.title_id
LEFT JOIN TitleSales    AS ts ON ts.title_id = t.title_id
WHERE    a.au_lname LIKE '[A-M]%'
GROUP BY a.au_id, a.au_lname, a.au_fname, a.state
ORDER BY TotalSalesQty DESC, FullName;


----Challenge 8: Book Price Range Analysis by Type 
--Analyze books by type: Show Type (display as 'Business Books' for 'business', 'Psychology Books' for 'psychology', etc. using CASE), 
--Number of Titles, Average Price, Price Range ('Premium' > $20, 'Mid-Range' $10-$20, 'Budget' < $10, 'Free/Promo' for NULL prices),
--Total Potential Revenue (sum of prices). Only include types with at least 3 titles. Convert prices to VARCHAR with 2 decimal places for display. Sort by average price descending.
USE pubs;

SELECT  CASE t.type
             WHEN 'business'     THEN 'Business Books'
             WHEN 'mod_cook'     THEN 'Modern Cooking Books'
             WHEN 'trad_cook'    THEN 'Traditional Cooking Books'
             WHEN 'popular_comp' THEN 'Popular Computing Books'
             WHEN 'psychology'   THEN 'Psychology Books'
             ELSE 'Undecided'
         END    AS BookType,
         COUNT(t.title_id) AS BookCount, 
         COALESCE(CAST (AVG(t.price) AS VARCHAR(10)), 'Free/Promo') AS AvgPrice,
         SUM(t.price) AS TotalPotencial,
         CASE 
            WHEN AVG(t.price) > 20 THEN 'Premium'
            WHEN AVG(t.price) >= 10 THEN 'Mid-Range'
            WHEN AVG(t.price) IS NULL THEN 'Free/Promo'
            ELSE 'Budget' 
        END AS PriceRange
 FROM pubs.dbo.titles t
 GROUP BY  t.type
  HAVING COUNT(t.title_id) >= 3
  ORDER BY AVG(t.price) DESC;

            
-- Challenge 9: Publisher Performance Matrix 
--Show publisher analytics: Publisher Name, City, State, Number of Titles Published, Total Sales Quantity, 
--Average Book Price, Market Position ('Market Leader' if total sales > 40, 'Strong Player' 20-40, 'Growing' 10-20, 'New Player' < 10). 
--Calculate Market Share Category: 'High Value' if avg price > $15, 'Mid Value' $10-$15, 'Value' < $10. Only publishers with at least 2 titles. Sort by total sales descending.
USE pubs;

    WITH BookSales AS (
    SELECT title_id, SUM(qty) AS TotalSales
    FROM pubs.dbo.sales
    GROUP BY title_id)
    SELECT p.pub_name, p.city,
           p.state, 
           COUNT(t.title_id) AS BookCount, 
           AVG(t.price) AS AvgPrice,
           SUM(bs.TotalSales) AS TotalSales,
           CASE 
                WHEN SUM(bs.TotalSales) > 40 THEN 'Market Leader'
                WHEN SUM(bs.TotalSales) >= 20 THEN 'Strong Player'
                WHEN SUM(bs.TotalSales) >= 10 THEN 'Growing'
                ELSE 'New Player'
            END AS MarketPosition,
            CASE 
                WHEN AVG(t.price) > 15 THEN 'High Value'
                WHEN AVG(t.price) >= 10 THEN 'Mid Value'
                ELSE 'Value'
            END AS MarketShare
    FROM publishers p 
        LEFT JOIN titles t ON p.pub_id = t.pub_id
        LEFT JOIN BookSales bs ON t.title_id = bs.title_id
    GROUP BY p.pub_name, p.city,  p.state
    HAVING COUNT(t.title_id)>= 2
    ORDER BY SUM(bs.TotalSales) DESC;

    -- Challenge 10: Store Sales Ranking with Geography 
    --Create store performance report: Store Name, City, State (COALESCE to 'N/A' if NULL), 
    --Number of Different Titles Sold, Total Units Sold, Geographic Region (CASE: states IN ('CA', 'OR', 'WA') = 'West Coast',
    --IN ('MA', 'NY') = 'East Coast', else 'Other'), Performance Level based on total units: 'Excellent' (> 30), 'Good' (15-30), 'Fair' (< 15). 
    --Sort by geographic region, then by total units descending within each region.
USE pubs;

 SELECT   st.stor_id,
         st.stor_name,
         st.city,
         COALESCE(st.state, 'N/A')   AS State,
         COUNT(DISTINCT s.title_id) AS DifferentTitlesSold,
         COALESCE(SUM(s.qty), 0)  AS TotalUnitsSold,
         CASE
             WHEN st.state IN ('CA', 'OR', 'WA') THEN 'West Coast'
             WHEN st.state IN ('MA', 'NY') THEN 'East Coast'
             ELSE 'Other'
         END   AS Region,
         CASE
             WHEN SUM(s.qty) > 30  THEN 'Excellent'
             WHEN SUM(s.qty) >= 15 THEN 'Good'
             ELSE 'Fair'
         END   AS PerformanceLevel
FROM     pubs.dbo.stores AS st
LEFT JOIN pubs.dbo.sales AS s ON s.stor_id = st.stor_id
GROUP BY st.stor_id, st.stor_name, st.city, st.state
ORDER BY Region, TotalUnitsSold DESC;


--Challenge 11: Product-Category-Supplier Intelligence 
--Create comprehensive product report: Product Name, Category Name, Supplier Company Name, Supplier Country,
--Units In Stock, Units On Order, Stock Health ('Healthy' if UnitsInStock > UnitsOnOrder * 2, 'Adequate' if UnitsInStock > UnitsOnOrder, 
--'Needs Reorder' if UnitsInStock <= UnitsOnOrder), Supplier Reliability (CASE: Country IN ('USA', 'UK', 'Germany') = 'Tier 1', 
--IN ('France', 'Italy', 'Spain') = 'Tier 2', else 'Tier 3'). Filter discontinued = 0. Sort by stock health, then category name.
USE Northwind;

SELECT p.ProductName,c.CategoryName,
       s.CompanyName, s.Country,
       p.UnitsInStock, p.UnitsOnOrder ,
       CASE
            WHEN p.UnitsInStock > UnitsOnOrder * 2 THEN 'Healthy'
            WHEN p.UnitsInStock > UnitsOnOrder THEN 'Adequate'
            ELSE 'Needs Reorder'
        END AS StockHealth,
        CASE
            WHEN Country IN ('USA', 'UK', 'Germany') THEN 'Tier 1'
            WHEN Country IN ('France', 'Italy', 'Spain') THEN 'Tier 2'
            ELSE 'Tier 3'
        END AS SupplierReliability
FROM Northwind.dbo.Products p 
LEFT JOIN Northwind.dbo.Categories c ON p.CategoryID = c.CategoryID
LEFT JOIN Northwind.dbo.Suppliers s ON p.SupplierID = s.SupplierID
WHERE p.Discontinued = 0
ORDER BY StockHealth, c.CategoryName;

-- Challenge 12: Customer Order Pattern Analysis 
--Analyze customer ordering patterns: Customer Company Name, Contact Name, Country, Order Count, 
--Average Days Between Orders (use DATEDIFF), Order Frequency Category ('Very Active' < 30 days avg, 
--'Active' 30-60 days, 'Moderate' 60-90 days, 'Inactive' > 90 days), Total Spent, Customer Value 
--('High Value' if spent > $10k AND very active/active, 'Medium Value' if spent > $5k, 'Standard' otherwise).
--Minimum 5 orders. Sort by customer value (High, Medium, Standard order), then total spent.
USE Northwind;

SELECT   c.CompanyName, c.ContactName, c.Country,
         COUNT(DISTINCT o.OrderID) AS OrderCount,
         CAST(DATEDIFF(day, MIN(o.OrderDate), MAX(o.OrderDate)) * 1.0
              / (COUNT(DISTINCT o.OrderID) - 1) AS DECIMAL(6,1)) AS AvgDaysBetween,
         CASE
             WHEN DATEDIFF(day, MIN(o.OrderDate), MAX(o.OrderDate)) * 1.0
                  / (COUNT(DISTINCT o.OrderID) - 1) < 30  THEN 'Very Active'
             WHEN DATEDIFF(day, MIN(o.OrderDate), MAX(o.OrderDate)) * 1.0
                  / (COUNT(DISTINCT o.OrderID) - 1) <= 60 THEN 'Active'
             WHEN DATEDIFF(day, MIN(o.OrderDate), MAX(o.OrderDate)) * 1.0
                  / (COUNT(DISTINCT o.OrderID) - 1) <= 90 THEN 'Moderate'
             ELSE 'Inactive'
         END AS OrderFrequency,
         CAST(SUM(od.UnitPrice * od.Quantity) AS DECIMAL(12,2)) AS TotalSpent,
         CASE
             WHEN SUM(od.UnitPrice * od.Quantity) > 10000
              AND DATEDIFF(day, MIN(o.OrderDate), MAX(o.OrderDate)) * 1.0
                  / (COUNT(DISTINCT o.OrderID) - 1) <= 60 THEN 'High Value'
             WHEN SUM(od.UnitPrice * od.Quantity) > 5000  THEN 'Medium Value'
             ELSE 'Standard'
         END AS CustomerValue
FROM     dbo.Customers   AS c
JOIN     dbo.Orders AS o  ON o.CustomerID = c.CustomerID
JOIN     dbo.[Order Details] AS od ON od.OrderID   = o.OrderID
GROUP BY c.CustomerID, c.CompanyName, c.ContactName, c.Country
HAVING   COUNT(DISTINCT o.OrderID) >= 5
ORDER BY CASE
             WHEN SUM(od.UnitPrice * od.Quantity) > 10000
              AND DATEDIFF(day, MIN(o.OrderDate), MAX(o.OrderDate)) * 1.0
                  / (COUNT(DISTINCT o.OrderID) - 1) <= 60 THEN 1
             WHEN SUM(od.UnitPrice * od.Quantity) > 5000  THEN 2
             ELSE 3
         END,
         SUM(od.UnitPrice * od.Quantity) DESC;



-- Challenge 13: Title Success Metrics with Multi-Author Analysis 
--Create title performance dashboard: Title, Type (formatted nicely using CASE), Number of Authors (count from titleauthor), 
--Publisher Name, Publication Year (YEAR from pubdate), Average Royalty %, Total Sales Quantity, Price (COALESCE 'Not Priced' if NULL, 
--else convert to currency string), Collaboration Type ('Solo' if 1 author, 'Duo' if 2, 'Team' if 3+), 
--Success Rating ('Bestseller' sales > 40, 'Popular' 20-40, 'Moderate' < 20, 'New Release' if sales NULL). 
--Filter for titles published after 1990. Sort by success rating, then sales descending.

USE pubs;

WITH AuthorCounts AS (              
    SELECT   title_id, COUNT(*) AS num_authors
    FROM     pubs.dbo.titleauthor
    GROUP BY title_id
),
TitleSales AS (                     
    SELECT   title_id, SUM(qty) AS total_qty
    FROM     pubs.dbo.sales
    GROUP BY title_id
)
SELECT   t.title,
         CASE t.type
             WHEN 'business'     THEN 'Business'
             WHEN 'mod_cook'     THEN 'Modern Cooking'
             WHEN 'trad_cook'    THEN 'Traditional Cooking'
             WHEN 'popular_comp' THEN 'Popular Computing'
             WHEN 'psychology'   THEN 'Psychology'
             ELSE 'Undecided'
         END    AS BookType,
         COALESCE(ac.num_authors, 0)    AS NumAuthors,
         p.pub_name    AS Publisher,
         YEAR(t.pubdate)    AS PubYear,
         COALESCE(CAST(t.royalty AS VARCHAR(5)) + '%', 'Not set') AS RoyaltyPct,
         ts.total_qty       AS TotalSalesQty,
         COALESCE('$' + CONVERT(VARCHAR(20), t.price, 1), 'Not Priced') AS Price,
         CASE
             WHEN ac.num_authors >= 3 THEN 'Team'
             WHEN ac.num_authors = 2  THEN 'Duo'
             WHEN ac.num_authors = 1  THEN 'Solo'
             ELSE 'No author'
         END      AS CollaborationType,
         CASE
             WHEN ts.total_qty IS NULL THEN 'New Release'
             WHEN ts.total_qty > 40    THEN 'Bestseller'
             WHEN ts.total_qty >= 20   THEN 'Popular'
             ELSE 'Moderate'
         END            AS SuccessRating
FROM     pubs.dbo.titles  AS t
LEFT JOIN pubs.dbo.publishers      AS p  ON p.pub_id    = t.pub_id
LEFT JOIN AuthorCounts        AS ac ON ac.title_id = t.title_id
LEFT JOIN TitleSales          AS ts ON ts.title_id = t.title_id
WHERE    t.pubdate >= '19910101'
ORDER BY  ts.total_qty DESC;
        
    
--Challenge 14: Store-Publisher Relationship Matrix
--Analyze store-publisher relationships: Store Name, Store State, Number of Different Publishers Sold,
--Number of Titles Sold, Total Quantity Sold, Top Publisher (the publisher whose books they sold most - use CASE/complex logic), 
--Store Type based on diversity ('Multi-Publisher' if > 3 publishers, 'Focused' if 1-3), Sales Volume ('High Volume' > 40 units, 'Medium' 20-40, 'Low' < 20).
--Show only stores that sold books from at least 2 different publishers. Sort by sales volume category, then total quantity.

USE pubs;

WITH StorePub AS (                     
    SELECT   s.stor_id, t.pub_id, SUM(s.qty) AS qty
    FROM     pubs.dbo.sales  AS s
    JOIN     pubs.dbo.titles AS t ON t.title_id = s.title_id
    GROUP BY s.stor_id, t.pub_id
)
SELECT   st.stor_name,
         COALESCE(st.state, 'N/A')       AS State,
         COUNT(DISTINCT t.pub_id)        AS PublisherCount,
         COUNT(DISTINCT s.title_id)      AS TitlesSold,
         SUM(s.qty)                      AS TotalQty,
         (SELECT TOP 1 p.pub_name
          FROM   StorePub            AS sp
          JOIN   pubs.dbo.publishers AS p ON p.pub_id = sp.pub_id
          WHERE  sp.stor_id = st.stor_id
          ORDER BY sp.qty DESC, p.pub_name) AS TopPublisher,
         CASE
             WHEN COUNT(DISTINCT t.pub_id) > 3 THEN 'Multi-Publisher'
             ELSE 'Focused'
         END                             AS StoreType,
         CASE
             WHEN SUM(s.qty) > 40  THEN 'High Volume'
             WHEN SUM(s.qty) >= 20 THEN 'Medium'
             ELSE 'Low'
         END                             AS SalesVolume
FROM     pubs.dbo.stores AS st
JOIN     pubs.dbo.sales  AS s ON s.stor_id  = st.stor_id
JOIN     pubs.dbo.titles AS t ON t.title_id = s.title_id
GROUP BY st.stor_id, st.stor_name, st.state
HAVING   COUNT(DISTINCT t.pub_id) >= 2
ORDER BY CASE
             WHEN SUM(s.qty) > 40  THEN 1
             WHEN SUM(s.qty) >= 20 THEN 2
             ELSE 3
         END,
         TotalQty DESC;



--CHALLENGE 15 Customers with Above-Average Orders 
-- Find customers who have placed more orders than the average number of orders per customer. Show CustomerID and CompanyName. 
--Solve this problem TWICE: once using a subquery, and once using a JOIN with a derived table. Compare the readability and performance of both approaches.
USE Northwind;

SELECT c.CustomerID, c.CompanyName, co.OrdersCount
FROM Customers c
INNER JOIN (
    SELECT CustomerID, COUNT(*) AS OrdersCount 
    FROM Orders
    GROUP BY CustomerID
) AS co ON co.CustomerID = c.CustomerID
WHERE co.OrdersCount > (
    SELECT AVG(CAST(OrdersCount AS FLOAT))
    FROM (
        SELECT COUNT(*) AS OrdersCount 
        FROM Orders 
        GROUP BY CustomerID
    ) AS AvgCalc
);

SELECT c.CustomerID, c.CompanyName, 
        (SELECT COUNT(*) FROM Orders o WHERE o.CustomerID = c.CustomerID) AS OrdersCount 
FROM Customers c
WHERE (SELECT COUNT(*) FROM Orders o WHERE c.CustomerID = o.CustomerID) > ( 
                    SELECT AVG(OrdCount) 
                    FROM (
                        SELECT COUNT(*) AS OrdCount 
                        FROM Orders o 
                        GROUP BY o.CustomerID) AS avg2);

----- CHALLENGE 16  Products Never Ordered 
-- Find all products that have never appeared in any order. Show ProductID, ProductName, and CategoryID. Solve THREE ways:
--(1) Using LEFT JOIN with IS NULL, (2) Using NOT IN subquery (remember NULL handling!), (3) Using NOT EXISTS. Which approach is most readable? Which is fastest?
USE Northwind;

SELECT ProductID, ProductName, CategoryID
FROM Products
WHERE ProductID NOT IN (
    SELECT ProductID 
    FROM [Order Details]
    WHERE ProductID IS NOT NULL
);


SELECT p.ProductID, p.ProductName, p.CategoryID
FROM Products p
LEFT JOIN [dbo].[Order Details] od ON od.ProductID = p.ProductID
WHERE od.OrderID IS NULL

SELECT p.ProductID, p.ProductName, p.CategoryID
FROM Products p
WHERE  NOT EXISTS(
    SELECT 1
    FROM [Order Details] od
    WHERE od.ProductID = p.ProductID)


-- CHALLENGE 17 High-Value Customers vs Average 
--Find customers whose average order value (total from Order Details) exceeds the overall average order value across all customers. 
--Show CustomerID, CompanyName, and their average order value. Try solving with: (1) Correlated subquery in WHERE,
--(2) JOIN with two derived tables (one for customer averages, one for overall average). Which performs better?
USE Northwind;

SELECT c.CustomerID, c.CompanyName, (SELECT AVG(TotalValue) AS AvgTotalValue FROM (
                                                            SELECT SUM(od.UnitPrice * od.Quantity) AS TotalValue  
                                                            FROM [Order Details] od 
                                                            INNER JOIN Orders o ON od.OrderID = o.OrderID
                                                            WHERE o.CustomerID = c.CustomerID 
                                                            GROUP BY o.OrderID) AS t
                                                            
                                                           ) AS AvgSpent
                                                       
FROM Customers c
WHERE (SELECT AVG(TotalValue) AS AvgTotalValue FROM (
                                                            SELECT SUM(od.UnitPrice * od.Quantity) AS TotalValue  
                                                            FROM [Order Details] od 
                                                            INNER JOIN Orders o ON od.OrderID = o.OrderID
                                                            WHERE o.CustomerID = c.CustomerID
                                                            GROUP BY o.OrderID) AS t
                                                            ) > (SELECT AVG(t2.PerValue) FROM (SELECT  SUM(od.UnitPrice * od.Quantity) AS PerValue
                                                                FROM [Order Details] od
                                                                JOIN Orders o  ON o.OrderID = od.OrderID
                                                                GROUP BY o.OrderID) t2)
ORDER BY AvgSpent;

                                                            
SELECT c.CustomerID, c.CompanyName, AVG(ts.TotalValue) AS AvgSpent
FROM Customers c
JOIN ( SELECT o.OrderID, o.CustomerID, SUM(od.UnitPrice * od.Quantity) AS TotalValue  
      FROM [Order Details] od 
      INNER JOIN Orders o ON od.OrderID = o.OrderID
      GROUP BY o.OrderID, o.CustomerID) AS  ts ON ts.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.CompanyName
HAVING AVG(ts.TotalValue) > (SELECT AVG(t2.PerValue) FROM (SELECT  SUM(od.UnitPrice * od.Quantity) AS PerValue
                                                                FROM [Order Details] od
                                                                JOIN Orders o  ON o.OrderID = od.OrderID
                                                                GROUP BY o.OrderID) t2)
ORDER BY AvgSpent;


-- CHALLENGE 18 Employee Order Coverage 
--Find employees who have processed orders for customers in at least 3 different countries. 
--Show EmployeeID, full name (FirstName + LastName), and the count of distinct countries. 
--Compare: (1) Pure JOIN approach with GROUP BY and HAVING, (2) Subquery in WHERE that counts distinct countries. Which is more readable?

USE Northwind;
SELECT e.EmployeeID, e.FirstName + ' ' + e.LastName AS FullName, COUNT(DISTINCT o.ShipCountry) AS CountCountry
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, e.FirstName + ' ' + e.LastName
HAVING COUNT(DISTINCT o.ShipCountry) >= 3


SELECT e.EmployeeID, e.FirstName + ' ' + e.LastName AS FullName, (
    SELECT COUNT(DISTINCT ShipCountry) 
    FROM Orders o 
    WHERE o.EmployeeID = e.EmployeeID ) AS CountCountry
FROM Employees e
WHERE (
    SELECT COUNT(DISTINCT ShipCountry) 
    FROM Orders o 
    WHERE o.EmployeeID = e.EmployeeID ) >=3


-- CHALLENGE 19 Bestselling Authors 
-- Find authors whose total sales quantity (from the sales table) exceeds the average total sales per author. 
--Show author name and total sales. Solve with: (1) Subquery in HAVING clause, (2) JOIN with a derived table containing the average. 
--Note: You'll need to join authors → titleauthor → titles → sales, then group and filter.
USE pubs;

SELECT a.au_id, a.au_fname, SUM(s.qty) AS TotalSold
FROM pubs.dbo.authors a 
JOIN pubs.dbo.titleauthor ta on a.au_id = ta.au_id
JOIN pubs.dbo.sales s on ta.title_id = s.title_id
GROUP BY a.au_id, a.au_fname
HAVING SUM(s.qty) > (SELECT AVG(t.TotalSold) FROM (SELECT ta.au_id, SUM(s.qty) AS TotalSold
                                                    FROM pubs.dbo.titleauthor ta 
                                                    JOIN pubs.dbo.sales s on ta.title_id = s.title_id
                                                    GROUP BY ta.au_id) AS t );



SELECT a.au_id, a.au_fname, t.TotalSold AS Total
FROM pubs.dbo.authors a
JOIN (SELECT ta.au_id, SUM(s.qty) AS TotalSold
      FROM pubs.dbo.titleauthor ta
      JOIN pubs.dbo.sales s on ta.title_id = s.title_id
      GROUP BY ta.au_id)  AS t ON t.au_id = a.au_id
WHERE t.totalSold > (SELECT AVG(t2.TotalSold) FROM ( SELECT ta.au_id, SUM(s.qty) AS TotalSold
                                                    FROM pubs.dbo.titleauthor ta
                                                    JOIN pubs.dbo.sales s on ta.title_id = s.title_id
                                                    GROUP BY ta.au_id) AS t2) ;



-- CHALLENGE 20 Publishers Without Recent Sales 
-- Find publishers who have NO sales records in the sales table (their books exist but haven't sold). Show pub_name and pub_id. 
--Try all three approaches: (1) LEFT JOIN with IS NULL, (2) NOT IN subquery, (3) NOT EXISTS.
--Pay special attention to NULL handling! Which approach feels most natural for this problem?
USE pubs;

SELECT p.pub_id, p.pub_name
FROM pubs.dbo.publishers AS p
LEFT JOIN pubs.dbo.titles AS t ON t.pub_id   = p.pub_id
LEFT JOIN pubs.dbo.sales  AS s ON s.title_id = t.title_id
GROUP BY p.pub_id, p.pub_name
HAVING COUNT(s.stor_id) = 0;    


SELECT p.pub_id, p.pub_name
FROM pubs.dbo.publishers p
WHERE p.pub_id NOT IN (
    SELECT t.pub_id
    FROM pubs.dbo.titles t
    JOIN pubs.dbo.sales s ON t.title_id = s.title_id
    WHERE t.pub_id IS NOT NULL);


SELECT p.pub_id, p.pub_name
FROM pubs.dbo.publishers p
WHERE NOT EXISTS (
    SELECT 1
    FROM pubs.dbo.titles t
    JOIN pubs.dbo.sales s ON t.title_id = s.title_id
    WHERE t.pub_id = p.pub_id
);

--CHALLENGE 21 Customer Segmentation 
--Create a CTE that classifies customers into segments (Bronze/Silver/Gold) based on their total order value. Bronze:
--< $5000, Silver: $5000-$15000, Gold: > $15000. Show customer name, total order value, and segment. Use ORDER BY to show Gold customers first.
USE Northwind;

WITH CustomerTier AS (
SELECT o.CustomerID, SUM(od.UnitPrice * od.Quantity) AS OrderValue, 
		CASE
			WHEN SUM(od.UnitPrice * od.Quantity) > 15000 THEN 'Gold'
			WHEN SUM(od.UnitPrice * od.Quantity) >= 5000 THEN 'Silver'
			ELSE 'Bronze'
		END AS Tier
FROM Northwind.dbo.Orders o
JOIN Northwind.dbo.[Order Details] od ON o.OrderID = od.OrderID
GROUP BY o.CustomerID
)
SELECT c.CompanyName, ct.OrderValue, ct.Tier
FROM Northwind.dbo.Customers c
JOIN CustomerTier ct ON ct.CustomerID = c.CustomerID
ORDER BY ct.OrderValue DESC;

-- CHALLENGE 22 Product Performance Analysis 
-- Using multiple CTEs: (1) Calculate total revenue per product, (2) Find average revenue across all products, 
--(3) Show products performing above average with their revenue and percentage above average. Include product name, category name, revenue, and percentage difference.
USE Northwind;

WITH ProductRevenue AS (
	SELECT od.ProductID, SUM(od.UnitPrice * od.Quantity) AS Revenue
	FROM Northwind.dbo.[Order Details] od
	GROUP BY od.ProductID
),
 AvgRevenue AS (
	SELECT AVG(Revenue) AS AvgRev
	FROM ProductRevenue
),
Precentdif AS (
	SELECT pr.ProductID, pr.Revenue,
        ((pr.Revenue - ar.AvgRev) / ar.AvgRev) * 100 AS DifferencePer
	FROM ProductRevenue pr, AvgRevenue ar
	WHERE pr.Revenue > ar.AvgRev
	)
SELECT p.ProductName, c.CategoryName, pd.Revenue, ROUND(pd.DifferencePer,2) AS Dif
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
JOIN Precentdif pd ON  p.ProductID = pd.ProductID
ORDER BY pd.Revenue DESC;


--CHALLENGE 23 : Month-over-Month Growth
-- Create a query showing monthly order totals with month-over-month growth percentage. Use CTEs to:
--(1) Group orders by month, (2) Use LAG() or self-join to get previous month's value, (3) Calculate percentage change. 
--Show month, current total, previous total, and growth percentage. Bonus: Handle first month gracefully!
USE Northwind;

WITH MonthlyOrders AS (
		SELECT MONTH(o.OrderDate) OrderMonth,YEAR(o.OrderDate) OrderYear, COUNT(*) CurrentTotal
		FROM Orders o
		GROUP BY MONTH(o.OrderDate), YEAR(o.OrderDate)
		),
	LaggedOrders AS (
		SELECT OrderYear, OrderMonth,CurrentTotal,
        LAG(CurrentTotal, 1) OVER (ORDER BY OrderYear, OrderMonth) AS PreviousTotal
		FROM MonthlyOrders
)
SELECT OrderYear, OrderMonth,  CurrentTotal,
    PreviousTotal,
    CASE 
        WHEN PreviousTotal IS NULL THEN NULL 
        ELSE CAST(((CurrentTotal - PreviousTotal) * 100.0) / PreviousTotal AS DECIMAL(5,2))
    END AS GrowthPercentage
FROM LaggedOrders
ORDER BY OrderYear, OrderMonth;


--CHALLENGE 24 Author Collaboration Network 
--Find pairs of authors who have co-authored books together. Show both author names and the count of books they've written together.
--Use a self-join on titleauthor. Bonus: Avoid duplicate pairs (e.g., show 'Author A & Author B' only once, not also 'Author B & Author A').
USE pubs;

SELECT a.au_fname + ' ' + a.au_lname AS Author1,
	  a2.au_fname + ' ' + a2.au_lname AS Author2,
	  COUNT(*) AS NumTitles
FROM pubs.dbo.authors a
JOIN pubs.dbo.titleauthor ta ON a.au_id = ta.au_id
JOIN pubs.dbo.titleauthor ta2 ON ta.title_id = ta2.title_id AND ta.au_id < ta2.au_id
JOIN pubs.dbo.authors a2 ON ta2.au_id = a2.au_id
GROUP BY a.au_fname + ' ' + a.au_lname, a2.au_fname + ' ' + a2.au_lname;

-- Challenge 25: Customer Freight Running Total 
---For each customer, calculate a running total of freight costs across all their orders. 
--Show CustomerID, OrderID, OrderDate, Freight, and cumulative freight. Order by customer and date. 
--Hint: PARTITION BY CustomerID, use ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW.
USE Northwind;

SELECT CustomerID, OrderID, OrderDate, Freight, 
		SUM(Freight) OVER (PARTITION BY CustomerID
						ORDER BY OrderDate, OrderID
						ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SumFr
FROM Orders;


-- Challenge 26: 7-Day Moving Average Sales 
--Calculate a 7-day moving average of order totals (use Order Details to get total). For each order date, show the date, daily total,
-- and the 7-day moving average. This requires aggregating by date first, then applying the window function. 
--Hint: Use a CTE to get daily totals, then ROWS BETWEEN 6 PRECEDING AND CURRENT ROW.
USE Northwind;

WITH DailySales AS (
SELECT o.OrderDate, SUM(od.UnitPrice * od.Quantity) AS total
FROM Orders o
JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY o.OrderDate
)
SELECT OrderDate, total, 
		AVG(total) OVER (ORDER BY OrderDate
						ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS Avg
FROM DailySales;

--Challenge 27: Month-over-Month Order Comparison 🔄
--Show monthly order counts and compare to the previous month using LAG(). Display year-month, order count, previous month count, 
--and the change. Use YEAR() and MONTH() to group by month. Hint: First aggregate by month in a CTE, then use LAG() OVER (ORDER BY year, month).
USE Northwind;

WITH MonthlySales AS(
SELECT YEAR(OrderDate) Year, MONTH(OrderDate) Month, COUNT(*) OrderCount
FROM Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)
SELECT Year, Month, OrderCount,
		LAG(OrderCount, 1) OVER(ORDER BY Year, Month) AS PreviousCount,
        OrderCount - LAG(OrderCount, 1) OVER(ORDER BY Year, Month) AS Change
FROM MonthlySales;

-- Challenge 28: Product Performance Percentiles 
--For each product, calculate: total units sold, revenue, percentile rank within category (PERCENT_RANK), 
--and whether it's in the top 25% of its category. Show ProductName, CategoryID, TotalUnits, TotalRevenue, PercentileRank. 
--Hint: Join Products with Order Details, aggregate, then use PERCENT_RANK() OVER (PARTITION BY CategoryID ORDER BY revenue).

USE Northwind;

WITH ProdSales AS (
		SELECT p.ProductName, p.CategoryID, SUM(od.Quantity) AS TotalUnits,
		SUM(od.UnitPrice * od.Quantity) AS Revenue
		FROM Products p
		JOIN [dbo].[Order Details] od ON p.ProductID = od.ProductID
		GROUP BY p.ProductName, p.CategoryID
		)
SELECT ProductName, CategoryID, TotalUnits, Revenue,
		PERCENT_RANK() OVER (PARTITION BY CategoryID
								ORDER BY Revenue ) AS PercentProd,
		CASE WHEN PERCENT_RANK() OVER (PARTITION BY CategoryID
								ORDER BY Revenue ) >= 0.75 THEN 'TOP 25'
				ELSE 'BELOW 75'
				END AS Tops
FROM ProdSales;

--Challenge 29: Customer Cohort Analysis by First Purchase 
--Group customers by their first purchase month (cohort). For each cohort, track how many customers were still ordering 30, 60, 90 days after first purchase.
--Calculate retention percentages. Hint: Use MIN(OrderDate) to identify first purchase, then DATEDIFF to measure time since cohort start. 
--Compare against subsequent order dates using LAG or self-join.

USE Northwind;

WITH CustOrders AS (  SELECT CustomerID,OrderDate,
							MIN(OrderDate) OVER (PARTITION BY CustomerID) AS FirstOrder
						FROM   dbo.Orders
				),
CustActivity AS (                     
    SELECT   CustomerID,
             DATEFROMPARTS(YEAR(FirstOrder), MONTH(FirstOrder), 1) AS Cohort,
             CASE WHEN MAX(DATEDIFF(day, FirstOrder, OrderDate)) >= 30 THEN 1 ELSE 0 END AS Active30,
             CASE WHEN MAX(DATEDIFF(day, FirstOrder, OrderDate)) >= 60 THEN 1 ELSE 0 END AS Active60,
             CASE WHEN MAX(DATEDIFF(day, FirstOrder, OrderDate)) >= 90 THEN 1 ELSE 0 END AS Active90
    FROM     CustOrders
    GROUP BY CustomerID, FirstOrder
)
SELECT   Cohort,                    
	     COUNT(*)    AS Customers,
         SUM(Active30)    AS Active30,
         SUM(Active60) AS Active60,
         SUM(Active90)  AS Active90,
         CAST(AVG(Active30 * 1.0) * 100 AS DECIMAL(5,1)) AS Retention30Pct,
         CAST(AVG(Active60 * 1.0) * 100 AS DECIMAL(5,1)) AS Retention60Pct,
         CAST(AVG(Active90 * 1.0) * 100 AS DECIMAL(5,1)) AS Retention90Pct
FROM     CustActivity
GROUP BY Cohort
ORDER BY Cohort;


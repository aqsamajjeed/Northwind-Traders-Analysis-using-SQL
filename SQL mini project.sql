                          --Working With Northwind Traders Dataset--
-- Categories Table
CREATE TABLE categories (
    categoryID SERIAL PRIMARY KEY,
    categoryName VARCHAR(100) NOT NULL,
    description TEXT
);

-- Customers Table
CREATE TABLE customers (
    customerID VARCHAR(10) PRIMARY KEY,
    companyName VARCHAR(100) NOT NULL,
    contactName VARCHAR(100),
    contactTitle VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50)
);

-- Employees Table
CREATE TABLE employees (
    employeeID SERIAL PRIMARY KEY,
    employeeName VARCHAR(100) NOT NULL,
    title VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50),
    reportsTo INT REFERENCES employees(employeeID)
);

-- Shippers Table
CREATE TABLE shippers (
    shipperID SERIAL PRIMARY KEY,
    companyName VARCHAR(100) NOT NULL
);

-- Products Table
CREATE TABLE products (
    productID SERIAL PRIMARY KEY,
    productName VARCHAR(100) NOT NULL,
    quantityPerUnit VARCHAR(50),
    unitPrice DECIMAL(10,2),
    discontinued BOOLEAN,
    categoryID INT REFERENCES categories(categoryID)
);

-- Orders Table
CREATE TABLE orders (
    orderID SERIAL PRIMARY KEY,
    customerID VARCHAR(10) REFERENCES customers(customerID),
    employeeID INT REFERENCES employees(employeeID),
    orderDate DATE,
    requiredDate DATE,
    shippedDate DATE,
    shipperID INT REFERENCES shippers(shipperID),
    freight DECIMAL(10,2)
);

-- Order Details Table
CREATE TABLE order_details (
    orderID INT REFERENCES orders(orderID),
    productID INT REFERENCES products(productID),
    unitPrice DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(4,2),
    PRIMARY KEY (orderID, productID)
);
 
-- Query 1: Retrieve all customers
-- Purpose: Get a complete view of all customers
-- Concepts Used: SELECT *
SELECT * FROM Customers;
-- Expected Output: Every customer record with all details
-- Business Insight:Provides a complete view of all customers,
--   including contact and location details. Useful for analyzing customer distribution,
--   planning regional strategies, and supporting sales and marketing decisions.

--------------------------------------------------------------------------------!

-- Query 2: Select specific customer details
-- Purpose: Extract names, contact persons, and cities
-- Concepts Used: SELECT specific columns
SELECT customerID, contactName, City 
FROM Customers;
-- Expected Output: Simplified list of customer contact details
-- Business Insight: This query provides essential customer contact and
--   location details, helping teams quickly identify who to contact and
--   where they are located. Ideal for customer outreach, regional marketing,
--   or support planning.

--------------------------------------------------------------------------------!

-- Query 3: Customers located in London
-- Purpose: Identify customers from a specific city
-- Concepts Used: WHERE
SELECT *
FROM Customers 
WHERE City = 'London';
-- Expected Output: List of London-based customers
-- Business Insight: Identifies all customers located in London, allowing for targeted
--   local marketing, personalized outreach, or efficient coordination of services in that area.

------------------------------------------------------------------------------------!

-- Query 4: High-value customers in London or Paris
-- Purpose: Find premium customers in select cities
-- Concepts Used: JOIN, WHERE, AND, OR
SELECT c.customerID, o.OrderID, o.OrderDate
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE c.City IN ('London','Paris') AND o.OrderDate > '1997-01-01' OR (o.Freight > 500 AND c.Country = 'UK');
-- Expected Output: Customers + orders from London/Paris with after 1997 
-- OR customers from UK with very high freight costs
-- Business Insight: Identifies high-value customers in London or Paris
--   and UK customers with costly shipments—useful for targeted sales, 
--   logistics planning, and customer prioritization.

-------------------------------------------------------------------------------------------------------------!

-- Query 5: Sort customers by first order date (newest first)
-- Purpose: Identify customers who joined recently
-- Concepts Used: JOIN, GROUP BY, ORDER BY DESC, MIN()
SELECT c.CustomerID, MIN(o.OrderDate) AS FirstOrderDate
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID
ORDER BY FirstOrderDate DESC;
-- Expected Output: Customers listed from latest first-time order to oldest
-- Business Insight: Shows when each customer placed their first order,
--   helping track how recently customers have joined and identify new vs. long-term clients.

---------------------------------------------------------------------------------------!

-- Query 6: Count total customers
-- Purpose: Get the total number of customers in the database
-- Concepts Used: COUNT
SELECT COUNT(*) AS TotalCustomers FROM Customers;
-- Expected Output: A single number (total customers)
-- Business Insight: Shows the current size of the customer base—useful 
--   for tracking growth and overall business reach.

----------------------------------------------------------------------------------------------------------!

-- Query 7: Total spending by each customer
-- Purpose: Identify high-value customers
-- Concepts Used: JOIN, SUM, GROUP BY, ORDER BY
SELECT c.CustomerID, 
       ROUND(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 2) AS TotalSpent
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN Order_Details od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID
ORDER BY TotalSpent DESC;
-- Expected Output: Customers ranked by total money spent
-- Business Insight: Ranks customers by total spending to identify top revenue 
--   contributors—crucial for focusing retention, rewards, and upselling strategies.

------------------------------------------------------------------------------------------!

-- Query 8: Top 5 most expensive orders
-- Purpose: Spot the largest transactions
-- Concepts Used: JOIN, SUM, GROUP BY, ORDER BY, LIMIT
SELECT o.OrderID, 
       o.CustomerID, 
       ROUND(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 2) AS OrderTotal
FROM Orders o
JOIN Order_Details od ON o.OrderID = od.OrderID
GROUP BY o.OrderID, o.CustomerID
ORDER BY OrderTotal DESC
LIMIT 5;
-- Expected Output: The five biggest orders with their total value
-- Business Insight: Highlights the top 5 highest-value orders, useful for identifying 
--   major transactions and understanding high-impact customer activity.

------------------------------------------------------------------------------------------------!

-- Query 9: Customers with no orders
-- Purpose: Identify inactive customers
-- Concepts Used: LEFT JOIN, IS NULL
SELECT c.CustomerID
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;
-- Expected Output: List of customers without any orders
-- Business Insight:Identifies customers with no orders, ideal for targeting re-engagement 
--   campaigns or special offers to activate dormant accounts.

--------------------------------------------------------------------------------------------!

-- Query 10: Monthly sales totals
-- Purpose: Track revenue over months
-- Concepts Used: GROUP BY, SUM, DATE functions
SELECT 
    EXTRACT(YEAR FROM OrderDate) AS Year,
    EXTRACT(MONTH FROM OrderDate) AS Month,
    SUM(UnitPrice * Quantity) AS MonthlySales
FROM Orders
JOIN Order_Details USING (OrderID)
GROUP BY EXTRACT(YEAR FROM OrderDate), EXTRACT(MONTH FROM OrderDate)
ORDER BY Year, Month;
-- Expected Output: Monthly sales totals over time
-- Business Insight: Tracks monthly sales to identify seasonal trends and monitor 
--   revenue growth over time, helping optimize inventory and marketing strategies.

----------------------------------------------------------------------------------------------!

-- Query 11: Average order size per customer
-- Purpose: Understand how much customers typically order
-- Concepts Used: JOIN, AVG, GROUP BY
SELECT c.CustomerID, 
       ROUND(AVG(od.Quantity), 2) AS AvgOrderQuantity
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN Order_Details od ON o.OrderID = od.OrderID
GROUP BY c.CustomerID
ORDER BY AvgOrderQuantity DESC;
-- Expected Output: Customers with their average order size
-- Business Insight: Shows average order size per customer, helping to differentiate
--  bulk buyers from smaller purchasers and tailor sales strategies accordingly.

---------------------------------------------------------------------------------------------!

-- Query 12: Employee sales performance
-- Purpose: See which employees generate the most sales
-- Concepts Used: JOIN, SUM, GROUP BY
SELECT e.EmployeeID, 
       e.EmployeeName, 
       ROUND(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 2) AS TotalSales
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN Order_Details od ON o.OrderID = od.OrderID
GROUP BY e.EmployeeID, e.EmployeeName
ORDER BY TotalSales DESC;
-- Expected Output: Employees ranked by sales they handled
-- Business Insight: Ranks employees by total sales handled, enabling performance 
--   evaluation and recognition of top sales contributors.

-----------------------------------------------------------------------------------------------------!

-- Query 13: Most shipped-to countries
-- Purpose: Find top destinations for orders
-- Concepts Used: JOIN, COUNT, GROUP BY
SELECT c.Country, COUNT(o.OrderID) AS TotalOrders
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.Country
ORDER BY TotalOrders DESC;
-- Expected Output: Countries ranked by number of orders
-- Business Insight: Reveals top shipping destinations, helping identify key markets
--   (e.g., Germany and USA) for focused marketing, logistics planning, or expansion.

---------------------------------------------------------------------------------------------!

-- Query 14: Top shippers by order volume
-- Purpose: Measure shipping company usage
-- Concepts Used: JOIN, COUNT, GROUP BY
SELECT s.ShipperID, s.CompanyName, COUNT(o.OrderID) AS OrdersShipped
FROM Shippers s
JOIN Orders o ON s.ShipperID = o.ShipperID
GROUP BY s.ShipperID, s.CompanyName
ORDER BY OrdersShipped DESC;
-- Expected Output: Shippers sorted by number of orders delivered
-- Business Insight: Highlights the most-used shipping partners, allowing for assessment 
--   of logistics performance and negotiation opportunities—United Package leads in order volume.

---------------------------------------------------------------------------------------------!

-- Query 15: Categories driving the most revenue
-- Purpose: Identify product categories with highest earnings
-- Concepts Used: JOIN, SUM, GROUP BY
SELECT c.CategoryName, 
       ROUND(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 2) AS CategoryRevenue
FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
JOIN Order_Details od ON p.ProductID = od.ProductID
GROUP BY c.CategoryName
ORDER BY CategoryRevenue DESC;
-- Expected Output: Categories ranked by revenue contribution
-- Business Insight:Beverages and Dairy Products are the top revenue-generating categories,
--   helping prioritize inventory, marketing, and supplier relationships around high-performing product lines.

---------------------------------------------------------------------------------------------------------!
---------------------------------------------------------------------------------------------------------!


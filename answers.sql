-- Step 1: Create the ProductDetail table with sample data
-- This table has multiple products in the Products column, which violates 1NF.
CREATE TABLE IF NOT EXISTS ProductDetail (
    OrderID INT, 
    CustomerName VARCHAR(255),
    Products VARCHAR(255)
);

-- Insert sample data into the ProductDetail table
INSERT INTO ProductDetail (OrderID, CustomerName, Products)
VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');

-- Step 2: Normalize ProductDetail table to 1NF
-- Create a new table ProductDetail_1NF to store the normalized data, where each row represents a single product.
CREATE TABLE IF NOT EXISTS ProductDetail_1NF (
    OrderID INT,
    CustomerName VARCHAR(255),
    Product VARCHAR(255)
);

-- Insert normalized data into ProductDetail_1NF
-- This query splits the comma-separated Products column into individual products, achieving 1NF.
INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product)
SELECT OrderID, CustomerName, 
       TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', n.n), ',', -1)) AS Product
FROM ProductDetail
JOIN (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) n
  ON CHAR_LENGTH(Products) - CHAR_LENGTH(REPLACE(Products, ',', '')) >= n.n - 1;

-- Step 3: Normalize OrderDetails table to 2NF
-- Check if the OrderDetails table exists and has the correct structure.
-- If necessary, drop and recreate the table with the correct schema.
DROP TABLE IF EXISTS OrderDetails;

-- Create the OrderDetails table, with the OrderID, CustomerName, Product, and Quantity columns.
CREATE TABLE OrderDetails (
    OrderID INT,
    CustomerName VARCHAR(255),
    Product VARCHAR(255),
    Quantity INT,
    PRIMARY KEY (OrderID, Product)
);

-- Insert sample data into OrderDetails table
INSERT INTO OrderDetails (OrderID, CustomerName, Product, Quantity)
VALUES
(101, 'John Doe', 'Laptop', 2),
(101, 'John Doe', 'Mouse', 1),
(102, 'Jane Smith', 'Tablet', 3),
(102, 'Jane Smith', 'Keyboard', 1),
(102, 'Jane Smith', 'Mouse', 2),
(103, 'Emily Clark', 'Phone', 1);

-- Step 4: Separate partial dependencies to achieve 2NF.
-- Create a Customer table to store unique customer data.
CREATE TABLE IF NOT EXISTS Customer (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(255)
);

-- Insert distinct customer data into the Customer table.
INSERT INTO Customer (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- Create a new OrderDetails_2NF table to remove the partial dependency.
-- Only store OrderID, Product, and Quantity.
CREATE TABLE IF NOT EXISTS OrderDetails_2NF (
    OrderID INT,
    Product VARCHAR(255),
    Quantity INT,
    PRIMARY KEY (OrderID, Product)
);

-- Insert the remaining data into the new OrderDetails_2NF table
INSERT INTO OrderDetails_2NF (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;


--*************************************************************************--
-- Title: Assignment06
-- Author: Sheyna Watkins
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2024-11-19,SheynaWatkins,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_SheynaWatkins')
	 Begin 
	  Alter Database [Assignment06DB_SheynaWatkins] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_SheynaWatkins;
	 End
	Create Database Assignment06DB_SheynaWatkins;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_SheynaWatkins;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

Go
Create View dbo.vCategories
  with SCHEMABINDING
  as
  Select CategoryID, CategoryName
    from dbo.Categories;
Go

Go
Create View dbo.vProducts
  with SCHEMABINDING
  as
  Select ProductID, ProductName, CategoryID, UnitPrice
    from dbo.Products;
Go

Go
Create View dbo.vEmployees
  with SCHEMABINDING
  as
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
    from dbo.Employees;
Go

Go
Create View dbo.vInventories
  with SCHEMABINDING
  as
  Select InventoryID, InventoryDate, EmployeeID, ProductID, Count
    from dbo.Inventories;
Go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select on dbo.Categories to Public;
Deny Select on dbo.Products to Public;
Deny Select on dbo.Employees to Public;
Deny Select on dbo.Inventories to Public;

Grant Select on dbo.vCategories to Public;
Grant Select on dbo.vProducts to Public;
Grant Select on dbo.vEmployees to Public;
Grant Select on dbo.vInventories to Public;

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
Go
Create View vProductsByCategories
  as
  Select c.CategoryName, p.ProductName, p.UnitPrice 
	from dbo.Products as p
	join dbo.Categories as c
	  on p.CategoryID = c.CategoryID;
Go

-- Order the result by the Category and Product!
Select * from vProductsByCategories
  order by CategoryName, ProductName;
Go 

-- alternate version of Question 3 view using order by inside the view
-- this is the only question I provided this alternative view for:
Go
Create View vProductsByCategoriesWithOrderBy
  as
  Select Top 100000 c.CategoryName, p.ProductName, p.UnitPrice 
	from dbo.Products as p
	join dbo.Categories as c
	  on p.CategoryID = c.CategoryID
	order by c.CategoryName, p.ProductName;
Go

Select * from vProductsByCategoriesWithOrderBy;
Go 

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
Go 
Create View vInventoriesByProductsByDates
  as
  Select p.ProductName, i.InventoryDate, i.Count
    from dbo.Products as p
	join dbo.Inventories as i
	  on p.ProductID = i.ProductID;
Go 

-- Order the results by the Product, Date, and Count!
Select * from vInventoriesByProductsByDates
  order by ProductName, InventoryDate, Count;
Go 

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
Go
Create View vInventoriesByEmployeesByDates
  as 
  Select DISTINCT i.InventoryDate, EmployeeName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
	from dbo.Inventories as i
	join dbo.Employees as e 
	  on i.EmployeeID = e.EmployeeID
Go 

-- Order the results by the Date and return only one row per date!
Select * from vInventoriesByEmployeesByDates
  order by InventoryDate asc;
Go

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Go
Create View vInventoriesByProductsByCategories
as
  Select c.CategoryName, p.ProductName, p.UnitPrice, i.InventoryDate, i.Count
	from dbo.Products as p
	join dbo.Categories as c
	  on p.CategoryID = c.CategoryID
	join dbo.Inventories as i
	  on p.ProductID = i.ProductID;
Go 

Select * from vInventoriesByProductsByCategories
	order by CategoryName asc, ProductName asc, InventoryDate asc, Count asc;
Go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
Go 
Create View vInventoriesByProductsByEmployees
  as 
  Select c.CategoryName, p.ProductName, i.InventoryDate, i.Count,  EmployeeName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
    from dbo.Products as p
	join dbo.Categories as c
	  on p.CategoryID = c.CategoryID
	join dbo.Inventories as i
	  on p.ProductID = i.ProductID
	join dbo.Employees as e 
	  on i.EmployeeID = e.EmployeeID;
Go

-- Order the results by the Inventory Date, Category, Product and Employee!
Select * from vInventoriesByProductsByEmployees
  order by InventoryDate asc, CategoryName asc, ProductName asc, EmployeeName asc;
Go 

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
Go 
Create View vInventoriesForChaiAndChangByEmployees
  as
  Select c.CategoryName, p.ProductName, i.InventoryDate, i.Count,  EmployeeName = e.EmployeeFirstName + ' ' + e.EmployeeLastName
    from dbo.Categories as c 
	join dbo.Products as p
	  on c.CategoryID = p.CategoryID
	join dbo.Inventories as i
	  on p.ProductID = i.ProductID
	join dbo.Employees as e 
	  on i.EmployeeID = e.EmployeeID
	where p.ProductName = 'Chai' or p.ProductName = 'Chang';
Go 

Select * from vInventoriesForChaiAndChangByEmployees;
Go 

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
Go
Create View vEmployeesByManager
 as
  Select Manager = man.EmployeeFirstName + ' ' + man.EmployeeLastName, Employee = emp.EmployeeFirstName + ' ' + emp.EmployeeLastName
    from dbo.Employees as man 
	join dbo.Employees as emp
	  on man.EmployeeID = emp.ManagerID;
Go

-- Order the results by the Manager's name!
Select * from vEmployeesByManager
  order by Manager, Employee; -- need to order by employee too to match the image
Go 

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
Go 
Create View vInventoriesByProductsByCategoriesByEmployees
  as 
  Select c.CategoryID, c.CategoryName, p.ProductID, p.ProductName, p.UnitPrice, 
      i.InventoryID, i.InventoryDate, i.Count, emp.EmployeeID, 
	  Employee = emp.EmployeeFirstName + ' ' + emp.EmployeeLastName,
	  Manager = man.EmployeeFirstName + ' ' + man.EmployeeLastName
    from dbo.Categories as c 
	join dbo.Products as p
	  on c.CategoryID = p.CategoryID
	join dbo.Inventories as i
	  on p.ProductID = i.ProductID
	join dbo.Employees as emp 
	  on i.EmployeeID = emp.EmployeeID
	join dbo.Employees as man 
	  on emp.ManagerID = man.EmployeeID;
Go 

--  order the data by Category, Product, InventoryID, and Employee.
Select * from vInventoriesByProductsByCategoriesByEmployees
  order by CategoryName asc, ProductName asc, InventoryID asc, Employee asc;
Go 

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/

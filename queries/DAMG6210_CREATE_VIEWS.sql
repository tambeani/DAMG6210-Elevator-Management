-- SELECT * FROM Territory.Country
-- SELECT * FROM Territory.Region

---------------------------------- VIEW: Top3ProductsperYear --------------------------------------

GO
CREATE VIEW Top3ProductsperYear as
With SumProductsperyear as(SELECT Year(sale.ContractDate) as YearSold,SUM(Quantity) as TotalQuantitySoldperyear
From Contract.Sale sale
INNER JOIN Contract.Unit unit ON unit.SerialNo=sale.SerialNo
INNER JOIN Product.Product product ON product.ProductID=unit.ProductID
INNER JOIN Person.Person person ON person.PersonId=sale.SalesRepID
INNER JOIN Product.ProductType producttype ON producttype.ProductTypeID=product.ProductTypeID
GROUP BY Year(sale.ContractDate)
),
ProductTypeSales as(SELECT Year(sale.ContractDate) as YearSold,product.ProductTypeID,producttype.Name,SUM(Quantity) as TotalQuantitySoldperyear
From Contract.Sale sale
INNER JOIN Contract.Unit unit ON unit.SerialNo=sale.SerialNo
INNER JOIN Product.Product product ON product.ProductID=unit.ProductID
INNER JOIN Person.Person person ON person.PersonId=sale.SalesRepID
INNER JOIN Product.ProductType producttype ON producttype.ProductTypeID=product.ProductTypeID
GROUP BY Year(sale.ContractDate),product.ProductTypeID,producttype.Name)


SELECT temp.YearSold,STRING_AGG(temp.Name,', ') as Top3ProductsSold,sumperyear.TotalQuantitySoldperyear as SumofTotalQuantityperYear
FROM(
SELECT YearSold,Name,TotalQuantitySoldperyear,RANK() OVER (Partition By YearSold Order By TotalQuantitySoldperyear DESC) AS Top3ProductsperYear
FROM ProductTypeSales)  as temp
INNER JOIN SumProductsperyear as sumperyear ON sumperyear.YearSold = temp.YearSold
WHERE Top3ProductsperYear<= 3
GROUP BY temp.YearSold,sumperyear.TotalQuantitySoldperyear
GO


---------------------------------- VIEW: YearlycompanysalesperRep --------------------------------------

GO
CREATE VIEW YearlycompanysalesperRep as
WITH temp as (SELECT sale.SalesRepID,person.FirstName+ ' '+person.LastName as SalesRepresentative,sale.CompanyID,company.CompanyName,product.ProductName,Year(sale.ContractDate) as YearSold,SUM((100-sale.Discount)*sale.Quantity*product.FixedPrice)/100 as SalesPerProduct
From Contract.Sale sale
INNER JOIN Contract.Unit unit ON unit.SerialNo=sale.SerialNo
INNER JOIN Product.Product product ON product.ProductID=unit.ProductID
INNER JOIN Person.Person person ON person.PersonId=sale.SalesRepID
INNER JOIN Client.Company company on company.CompanyID=sale.CompanyID
GROUP BY sale.SalesRepID,Year(sale.ContractDate),product.ProductName,sale.CompanyID,person.FirstName,person.LastName,company.CompanyName)



SELECT t1.SalesRepID,SalesRepresentative,STRING_AGG(ProductName,',') as ProductsSold,YearSold,CompanyID,CompanyName,CAST(SUM(SalesPerProduct)as int)  as TotalSalesPerCustomerPerYear
FROM temp t1
GROUP BY SalesRepID,YearSold,CompanyID,SalesRepresentative,CompanyName
GO

---------------------------------- VIEW: MaintenanceVisitsperYear --------------------------------------

CREATE VIEW MaintenanceVisitsperYear as
SELECT maintenance.EmployeeID,person.FirstName+' ' + person.LastName AS 'PersonName',YEAR(maintenance.VisitDate) VisitYear,callstatus.StatusType,Count(JobID) Visits
FROM Callback.MaintenanceJobs maintenance
INNER JOIN Callback.Status callstatus ON callstatus.StatusID=maintenance.JobStatus
INNER JOIN Person.Employee emp ON emp.EmployeeId=maintenance.EmployeeID
INNER JOIN Person.Person person ON person.PersonId=emp.EmployeeId
GROUP BY maintenance.EmployeeID,callstatus.StatusType,YEAR(maintenance.VisitDate),person.FirstName,person.LastName


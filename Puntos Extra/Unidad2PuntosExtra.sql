--consulta con el nombre del cliente, el importe total de ventas,
--importe de 1996, importe 1997 e importe 1998
SELECT
    C.CompanyName,importeTotal=ISNULL(SUM(D.QUANTITY*D.OrderDetailsUnitPrice),0),
    SUM(CASE WHEN YEAR(OrderDate) = 1996 THEN Quantity * OrderDetailsUnitPrice ELSE 0 END) AS Total96,
    SUM(CASE WHEN YEAR(OrderDate) = 1997 THEN Quantity * OrderDetailsUnitPrice ELSE 0 END) AS Total97,
    SUM(CASE WHEN YEAR(OrderDate) = 1998 THEN Quantity * OrderDetailsUnitPrice ELSE 0 END) AS Total98
FROM VW_ORDER_DETAILS D
RIGHT OUTER JOIN CUSTOMERS C ON C.CUSTOMERID = D.CUSTOMERID
GROUP BY C.CompanyName

--sin case when
SELECT 
    C.CompanyName,
    ImporteTotal=ISNULL(SUM(D.Quantity * D.OrderDetailsUnitPrice), 0),
    (SELECT ISNULL(SUM(D2.Quantity * D2.OrderDetailsUnitPrice), 0) 
     FROM VW_ORDER_DETAILS D2 
     WHERE D2.CustomerID = C.CustomerID AND YEAR(D2.OrderDate) = 1996) AS Total96,
    (SELECT ISNULL(SUM(D3.Quantity * D3.OrderDetailsUnitPrice), 0) 
     FROM VW_ORDER_DETAILS D3 
     WHERE D3.CustomerID = C.CustomerID AND YEAR(D3.OrderDate) = 1997) AS Total97,
    (SELECT ISNULL(SUM(D4.Quantity * D4.OrderDetailsUnitPrice), 0) 
     FROM VW_ORDER_DETAILS D4 
     WHERE D4.CustomerID = C.CustomerID AND YEAR(D4.OrderDate) = 1998) AS Total98
FROM VW_ORDER_DETAILS D
RIGHT OUTER JOIN CUSTOMERS C ON C.CustomerID = D.CustomerID
GROUP BY C.CompanyName, C.CustomerID



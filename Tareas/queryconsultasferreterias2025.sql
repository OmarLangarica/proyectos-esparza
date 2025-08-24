--1.- Consulta con el folio, fecha de la venta, nombre de la ferretería, mostrar los registros cuyo año
--sea multiplo de 3 y el mes contenga la letra r.
SELECT V.FOLIO,V.FECHA,F.FERRNOMBRE
FROM VENTAS V
INNER JOIN FERRETERIAS F ON F.FERRID = V.FERRID
WHERE (YEAR(V.FECHA)%3=0) AND (DATENAME(MONTH,V.FECHA) LIKE '%r%')

--2.- Consulta con el folio de la venta, fecha de la venta, meses que han pasado desde que se hizo la venta,
--nombre del cliente y nombre de la ferretería. Mostrar solo las ventas de los clientes y ferreterías que sus 
--teléfonos empiece con 667.
SELECT V.FOLIO, V.FECHA,Meses = DATEDIFF(MONTH,V.FECHA,GETDATE()),C.CTENOMBRE,C.CTETELEFONO,F.FERRNOMBRE, F.FERRTELEFONO
FROM VENTAS V 
INNER JOIN CLIENTES C ON C.CTEID = V.CTEID
INNER JOIN FERRETERIAS F ON F.FERRID = V.FERRID
WHERE F.FERRTELEFONO LIKE '667%' AND C.CTETELEFONO LIKE '667%'

--3.- Consulta con el folio de la venta, nombre del artículo, cantidad de piezas vendidas, 
--precio e importe total. Mostrar solo los artículos de las familias que su nombre empieza 
--con las letras Q, R, T, G.
SELECT D.FOLIO, A.ARTNOMBRE, D.CANTIDAD, D.PRECIO, Total = (D.CANTIDAD*D.PRECIO)
FROM DETALLES D
INNER JOIN ARTICULOS A ON A.ARTID = D.ARTID
INNER JOIN FAMILIAS F ON F.FAMID = A.FAMID
WHERE F.FAMNOMBRE LIKE 'Q%' AND F.FAMNOMBRE LIKE 'R%' AND F.FAMNOMBRE LIKE 'T%' AND F.FAMNOMBRE LIKE 'G%'

--4.- Consulta con el nombre completo del cliente, nombre de la colonia y nombre del municipio.
--Mostrar solo los clientes que el nombre del municipio y nombre la colonia contenga la cadena ‘ASA’.
SELECT NOMBRE = (CTE.CTENOMBRE+' '+CTE.CTEAPEPAT+' '+CTE.CTEAPEMAT), C.COLNOMBRE,M.MUNNOMBRE
FROM CLIENTES CTE
INNER JOIN COLONIAS C ON C.COLID = CTE.COLID
INNER JOIN MUNICIPIOS M ON M.MUNID = C.MUNID
WHERE M.MUNID LIKE '%ASA%' AND C.COLNOMBRE LIKE '%ASA%'

--5.- Consulta con el folio de la venta, fecha, nombre del empleado y cliente. 
--Mostrar solo los empleados que no tengan RFC y los clientes que no tengan CURP.
SELECT V.FOLIO, V.FECHA, E.EMPNOMBRE, C.CTENOMBRE
FROM VENTAS V
INNER JOIN EMPLEADOS E ON E.EMPID = V.EMPID
INNER JOIN CLIENTES C ON C.CTEID = V.CTEID
WHERE E.EMPRFC IS NULL AND C.CTECURP IS NULL

--6.- Consulta con el nombre del articulo y nombre de la familia. 
--Mostrar solo las familias que su tercera letra sea T, S, B, M.
SELECT A.ARTNOMBRE, F.FAMNOMBRE
FROM ARTICULOS A
INNER JOIN FAMILIAS F ON F.FAMID = A.FAMID
WHERE SUBSTRING(F.FAMNOMBRE,3,1) in ('T','S','B','M')

--7.- Consulta con el folio de la venta, fecha, nombre del empleado, cliente y ferretería.
--Mostrar solo las ventas del segundo semestre de 2020.
SELECT V.FOLIO, V.FECHA, E.EMPNOMBRE, C.CTENOMBRE, F.FERRNOMBRE
FROM VENTAS V
INNER JOIN EMPLEADOS E ON E.EMPID = V.EMPID
INNER JOIN CLIENTES C ON C.CTEID = V.CTEID
INNER JOIN FERRETERIAS F ON F.FERRID = V.FERRID
WHERE (YEAR(V.FECHA) = 2020) AND (MONTH(V.FECHA) BETWEEN 7 AND 12)

--8.- Consulta con el nombre del empleado, nombre de su jefe.
--Mostrar solo los empleados y jefes que vivan en la misma zona.
SELECT E.EMPNOMBRE, J.EMPNOMBRE
FROM EMPLEADOS E 
INNER JOIN EMPLEADOS J ON E.JEFEID = J.EMPID
WHERE E.ZONAID = J.ZONAID

--9.- Consulta con el nombre del empleado, nombre de la zona que atiende.
--Mostrar solo los empleados que la zona en su segunda letra sea la letra o.
SELECT E.EMPNOMBRE, Z.ZONANOMBRE
FROM EMPLEADOS E
INNER JOIN ZONAS Z ON Z.ZONAID = E.ZONAID
WHERE SUBSTRING(Z.ZONANOMBRE,2,1) = 'o'

--10.- Consulta con el folio de la venta, fecha de la venta, nombre del empleado, 
--edad que tenía el empleado cuando hizo la venta.
SELECT V.FOLIO, V.FECHA, E.EMPNOMBRE, Edad = DATEDIFF(YEAR,E.EMFECHANACIMIENTO,E.EMPFECHAINGRESO)
FROM VENTAS V
INNER JOIN EMPLEADOS E ON E.EMPID = V.EMPID

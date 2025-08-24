/*1.- Consulta con el nombre del empleado, zona del empleado, nombre del jefe y zona del jefe.
En el resultado deben aparecer todos los jefes.*/
SELECT EMPLEADO = E.EMPNOMBRE + ' '+E.EMPAPEMAT+ ' '+E.EMPAPEPAT,EMPLEADOZONA = Z.ZONANOMBRE,
JEFE = J.EMPNOMBRE+ ' ' + J.EMPAPEMAT+ ' '+ J.EMPAPEPAT, JEFEZONA = JZ.ZONANOMBRE
FROM EMPLEADOS E
LEFT OUTER JOIN ZONAS Z ON Z.ZONAID = E.ZONAID
LEFT OUTER JOIN EMPLEADOS J ON E.JEFEID = J.EMPID
LEFT OUTER JOIN ZONAS JZ ON JZ.ZONAID = J.ZONAID

/*2.- Consulta con el nombre del articulo y nombre de la familia.
Mostrar solo los artículos de las familias que su nombre contenga solo dos palabras.*/
SELECT A.ARTNOMBRE, F.FAMNOMBRE
FROM ARTICULOS A
INNER JOIN FAMILIAS F ON F.FAMID = A.FAMID
WHERE F.FAMNOMBRE LIKE '% %' AND F.FAMNOMBRE NOT LIKE '% % %'

/*3.- Consulta con el folio de la venta, fecha de la venta, meses que han pasado desde que se hizo la venta,
nombre del cliente y nombre de la ferretería. Mostrar solo las ventas donde el nombre del cliente y
la ferretería empiecen con la misma letra.*/
SELECT V.FOLIO, V.FECHA, MESES = DATEDIFF(MONTH,V.FECHA, GETDATE()), NOMBRECLIENTE = C.CTENOMBRE+' '+C.CTEAPEMAT+' '+C.CTEAPEPAT,
F.FERRNOMBRE
FROM VENTAS V
INNER JOIN CLIENTES C ON C.CTEID = V.CTEID
INNER JOIN FERRETERIAS F ON F.FERRID = V.FERRID
WHERE SUBSTRING(C.CTENOMBRE,1,1) = SUBSTRING(F.FERRNOMBRE,1,1)

/*4.- Consulta con el folio de la venta, nombre del artículo, cantidad de piezas vendidas,
precio e importe total. Mostrar solo los artículos de las familias que su nombre termine con N, M, S. */
SELECT D.FOLIO, A.ARTNOMBRE, D.CANTIDAD, D.PRECIO, IMPORTETOTAL = (D.CANTIDAD*D.PRECIO), F.FAMNOMBRE
FROM DETALLE D
INNER JOIN ARTICULOS A ON A.ARTID = D.ARTID 
INNER JOIN FAMILIAS F ON F.FAMID = A.FAMID
WHERE F.FAMNOMBRE LIKE '%[NMS]'

/*5.- Consulta con el nombre completo del cliente, nombre de la colonia y nombre del municipio.
Mostrar solo los clientes que el nombre del municipio y nombre la colonia contenga la cadena ‘ASA’. */
SELECT NOMBRECLIENTE = C.CTENOMBRE+' '+C.CTEAPEMAT+' '+C.CTEAPEPAT, COL.COLNOMBRE, M.MUNNOMBRE
FROM CLIENTES C
INNER JOIN COLONIAS COL ON COL.COLID = C.COLID
INNER JOIN MUNICIPIOS M ON M.MUNID = COL.MUNID
WHERE M.MUNNOMBRE LIKE '%ASA%' AND COL.COLNOMBRE LIKE '%ASA%'

/*6.- Consulta con el folio de la venta, fecha, nombre del empleado, nombre del jefe y nombre del cliente.
Mostrar solo los empleados que si tengan RFC y los clientes que si tengan CURP. */
SELECT V.FOLIO, V.FECHA,E.EMPNOMBRE+' '+E.EMPAPEMAT+' '+E.EMPAPEPAT,J.EMPNOMBRE+' '+J.EMPAPEMAT+' '+J.EMPAPEPAT,
C.CTENOMBRE+' '+C.CTEAPEMAT+' '+C.CTEAPEPAT
FROM VENTAS V
INNER JOIN EMPLEADOS E ON E.EMPID = V.EMPID
LEFT OUTER JOIN EMPLEADOS J ON E.JEFEID = J.JEFEID
INNER JOIN CLIENTES C ON C.CTEID = V.CTEID
WHERE (E.EMPRFC IS NOT NULL) AND (C.CTECURP IS NOT NULL)

/*7.- Consulta con el folio de la venta, fecha, nombre del empleado, cliente y ferretería.
Mostrar solo las ventas del segundo semestre de 2020 que se realizaron los días lunes, miércoles y viernes. */
SELECT V.FOLIO, V.FECHA, E.EMPNOMBRE+' '+E.EMPAPEMAT+' '+E.EMPAPEPAT,
C.CTENOMBRE+' '+C.CTEAPEMAT+' '+C.CTEAPEPAT,F.FERRNOMBRE
FROM VENTAS V
INNER JOIN EMPLEADOS E ON E.EMPID = V.EMPID
INNER JOIN CLIENTES C ON C.CTEID = V.CTEID
INNER JOIN FERRETERIAS F ON F.FERRID = V.FERRID
WHERE (DATEPART(MONTH,V.FECHA) BETWEEN 7 AND 12) AND YEAR(V.FECHA) = 2020 AND DATEPART(DW,V.FECHA) IN (2,4,6)

/*8.- Consulta con el nombre del empleado, nombre de su jefe.
Mostrar solo los empleados y jefes que vivan en la misma zona. */
SELECT EMPLEADOS = E.EMPNOMBRE+' '+E.EMPAPEMAT+' '+E.EMPAPEPAT,JEFES = J.EMPNOMBRE+' '+J.EMPAPEMAT+' '+J.EMPAPEPAT
FROM EMPLEADOS E 
LEFT OUTER JOIN EMPLEADOS J ON E.JEFEID = J.EMPID 
WHERE E.ZONAID = J.ZONAID

/*9.- Consulta con el folio de la venta, nombre del artículo, nombre de la familia,
cantidad de piezas vendidas, precio e importe total de venta.
Mostrar solo las ventas que en el importe incluya los números 12, 31 o 54. */
SELECT D.FOLIO, A.ARTNOMBRE, F.FAMNOMBRE, D.CANTIDAD, D.PRECIO, (D.CANTIDAD*D.PRECIO) AS IMPORTE
FROM DETALLE D
INNER JOIN ARTICULOS A ON A.ARTID = D.ARTID
INNER JOIN FAMILIAS F ON F.FAMID = A.FAMID
WHERE CAST((D.CANTIDAD*D.PRECIO) AS VARCHAR) LIKE '%12%' 
OR CAST((D.CANTIDAD*D.PRECIO) AS VARCHAR) LIKE '%54%'
OR CAST((D.CANTIDAD*D.PRECIO) AS VARCHAR) LIKE '%31%'

/*10.- En la misma consulta se debe tener el siguiente resultado donde se incluye la clave,
nombre y tipo de las tablas empleados y clientes: */

--1.-  En la tabla categories se agregó el campo TotalPiezasVendidas, 
--realizar un trigger que actualice automáticamente dicho campo.
ALTER TABLE CATEGORIES ADD TotalPiezasVendidas INT
ALTER TRIGGER TR_1 ON [Order Details]
FOR INSERT AS
BEGIN
    DECLARE @VentasPorCategoria TABLE (CategoryID INT,TotalVendidas INT)

    INSERT INTO @VentasPorCategoria (CategoryID, TotalVendidas)
    SELECT P.CategoryID, SUM(I.Quantity)
    FROM INSERTED I
    INNER JOIN Products P ON I.ProductID = P.ProductID
    GROUP BY P.CategoryID

    UPDATE C
    SET C.TotalPiezasVendidas = ISNULL(C.TotalPiezasVendidas, 0) + V.TotalVendidas
    FROM Categories C
    INNER JOIN @VentasPorCategoria V ON C.CategoryID = V.CategoryID
END
GO

--2.- Realizar un procedimiento almacenado que genere el código para que no se puedan
--realizar actualizaciones masivas en todas las tablas de cualquier BD, por ejemplo, 
--si se ejecuta en la BD northwind debe generar el código siguiente para todas las tablas siguientes:
ALTER PROC SP_CREA_TRIGGER AS
DECLARE @MIN INT, @NOM VARCHAR(50), @T VARCHAR(4000)

SELECT @MIN = MIN(ID) FROM SYSOBJECTS
WHERE XTYPE ='U' AND NAME NOT LIKE 'SYS%'

WHILE @MIN IS NOT NULL
BEGIN
	SELECT @NOM = NAME FROM SYSOBJECTS WHERE ID = @MIN 

	SELECT @T = 'CREATE TRIGGER TR_'+REPLACE(@NOM,' ','')+ '_UPD'+CHAR(13)
	SELECT @T = @T+'ON ['+@NOM+'] FOR UPDATE AS' + CHAR(13)
	SELECT @T = @T+ '	DECLARE @CONTA INT'+ CHAR(13)
	SELECT @T = @T + '	SELECT @CONTA = COUNT(*) FROM INSERTED'+ CHAR(13)
	SELECT @T = @T + CHAR(13)
	SELECT @T = @T + '	IF @CONTA > 1 '+CHAR(13)
	SELECT @T = @T +'	BEGIN'+CHAR(13)
	SELECT @T = @T +'		ROLLBACK TRAN'+CHAR(13)
	SELECT @T = @T + '		RAISERROR('+CHAR(39)+' NO SE PERMITEN ACTUALIZACIOENS MASIVAS'+CHAR(39)+',16,1)'+CHAR(13)
	SELECT @T = @T+ '	END'+CHAR(13)
	SELECT @T = @T + 'GO'

	PRINT @T

	SELECT @MIN = MIN(ID) FROM SYSOBJECTS
	WHERE XTYPE ='U' AND NAME NOT LIKE 'SYS%' AND ID > @MIN
END

EXEC SP_CREA_TRIGGER

--3.- Es necesario llevar el registro Histórico de los precios de los productos, 
--es necesario conocer la fecha y hora cuando se realiza la actualización, el nuevo valor del precio,
--el inicio de sesión que está realizando el cambio.
CREATE TABLE HISTORICO (
PRODUCTID INT, HISFECHA DATETIME,HISPRECIO NUMERIC(12,2),HISUSUARIO VARCHAR(MAX))
GO
ALTER TRIGGER TR_3 ON PRODUCTS
FOR UPDATE AS
INSERT INTO HISTORICO (PRODUCTID,HISFECHA, HISPRECIO, HISUSUARIO)
SELECT i.ProductID, GETDATE(), i.UnitPrice, CURRENT_USER
FROM inserted i
INNER JOIN deleted d ON i.ProductID = d.ProductID
WHERE i.UnitPrice <> d.UnitPrice
GO

--4.- Utilizando trigger, validar que solo se vendan ordenes de lunes a viernes.
ALTER TRIGGER TR_4 ON ORDERS 
FOR INSERT AS
DECLARE @DIA INT

SELECT @DIA = DATEPART(DW,ORDERDATE) FROM INSERTED 

IF @DIA IN (7,1)
BEGIN
	ROLLBACK TRAN
	RAISERROR('Solo se puede vender de lunes a viernes',16,1)
END
GO

--5.- Validar que un cliente no realice más de 200 ordenes por mes.
ALTER TRIGGER TR_5 ON ORDERS
FOR INSERT AS
	DECLARE @CTE INT, @CONTA INT, @MES INT

	SELECT @CTE = CUSTOMERID FROM INSERTED
	SELECT @MES = MONTH(OrderDate) FROM INSERTED

	SELECT @CONTA = COUNT(*) FROM ORDERS 
	WHERE CUSTOMERID = @CTE
	AND MONTH(ORDERDATE) = @MES
	AND YEAR(ORDERDATE) = YEAR(GETDATE())

	IF @CONTA > 200
	BEGIN
		ROLLBACK TRAN
		RAISERROR('No puede realizar mas de 200 ordenes por mes',16,1)
	END
GO

--6.- Validar que el campo firstname en la tabla employees solamente tenga un solo nombre, 
--no se permiten nombres compuestos. Además el campo lastname solo debe permitir dos apellidos.
ALTER TRIGGER TR_6 ON Employees
FOR INSERT, UPDATE AS
DECLARE @FirstName VARCHAR(50), @LastName VARCHAR(50)
SELECT @FirstName = FirstName, @LastName = LastName FROM inserted

IF LEN(@FirstName) - LEN(REPLACE(@FirstName, ' ', '')) > 0
BEGIN
	RAISERROR('el campo firstname solo puede tener un solo nombre', 16, 1)
    ROLLBACK TRAN
END

IF LEN(@LastName) - LEN(REPLACE(@LastName, ' ', '')) <> 1
BEGIN
	RAISERROR('el campo lastname solo puede contener dos apellidos', 16, 1)
    ROLLBACK TRAN
END
GO

--7.- validar que el importe total de venta de cada orden no sea mayor a $10,000.
ALTER TRIGGER TR_9 ON [Order Details] 
FOR INSERT AS  
DECLARE @ImporteTotal NUMERIC(12,2), @orderid INT 
SELECT @orderid = orderid FROM inserted 
  
SELECT @ImporteTotal = SUM(Quantity*UnitPrice) 
FROM [Order Details] 
WHERE OrderID = @orderid 
 
IF @ImporteTotal > 10000 
BEGIN 
	RAISERROR('NO SE ADMITEN VENTAS MAYORES A $10,000', 16, 1) 
	ROLLBACK TRAN 
END  
GO
--8.- Validar que solo se pueda actualizar tres veces el campo companyname de la tabla Customers
ALTER TABLE CUSTOMERS ADD CONTADOR INT
UPDATE Customers SET CONTADOR = 0
GO 
CREATE TRIGGER TR_9 ON CUSTOMERS
FOR UPDATE AS 
    DECLARE @CustomerID NCHAR(5), @CONTA INT
    SELECT @CustomerID = CustomerID, @CONTA = ISNULL(CONTADOR, 0) FROM inserted

    IF UPDATE(COMPANYNAME)
    BEGIN
        IF @CONTA >= 3
        BEGIN
            RAISERROR('EL NOMBRE DEL CLIENTE SOLO PUEDE ACTUALIZARSE TRES VECES.', 16, 1)
            ROLLBACK TRANSACTION
        END
        ELSE
        BEGIN
            UPDATE Customers 
            SET CONTADOR = @CONTA + 1 
            WHERE CustomerID = @CustomerID
        END
    END
GO

--9.- Crear un trigger en el cual descuente de la tabla products las unidades en stock (campo unitsinstock) 
--después de realzar una orden. También debe validar que si se venden más productos que hay en stock no permita
--realizar la venta.
ALTER TRIGGER TR_9 ON [Order Details]
FOR INSERT AS  
DECLARE @ProductID INT, @Quantity INT, @UnitsInStock INT 
SELECT @ProductID = ProductID, @Quantity = Quantity FROM INSERTED 
 
SELECT @UnitsInStock = UnitsInStock 
FROM Products 
WHERE ProductID = @ProductID 
 
IF @Quantity > @UnitsInStock 
BEGIN 
	ROLLBACK TRAN 
    RAISERROR('No hay suficiente stock para este producto.', 16, 1) 
END 
ELSE 
BEGIN 
	UPDATE Products 
    SET UnitsInStock = UnitsInStock - @Quantity 
    WHERE ProductID = @ProductID 
END 
GO 

--10.- La tabla customers se le agrego el campo CreditoDisponible, el cual representa el crédito 
--con el que cuenta el cliente. Inicialmente todos los clientes tienen un crédito de $20,000.
--Realizar un trigger que, al momento de comprar, se descuente el importe en el campo CreditoDisponible,
--si llega a cero, ya no debe permitir seguir comprando.
ALTER TABLE CUSTOMERS ADD CreditoDisponible NUMERIC(12,2) 
UPDATE Customers SET CreditoDisponible = 20000 
GO
CREATE TRIGGER TR_10 ON Orders
FOR INSERT AS
DECLARE @CustomerID NCHAR(5), @OrderID INT, @TotalCompra NUMERIC(12,2), @CreditoDisponible NUMERIC(12,2)
SELECT @OrderID = OrderID,@CustomerID = CustomerID FROM inserted

SELECT @TotalCompra = SUM(UnitPrice * Quantity)
FROM [Order Details]
WHERE OrderID = @OrderID

SELECT @CreditoDisponible = CreditoDisponible
FROM Customers
WHERE CustomerID = @CustomerID

IF @CreditoDisponible < @TotalCompra
BEGIN
	RAISERROR ('el cliente no tiene credito suficiente', 16, 1)
    ROLLBACK TRAN
END
ELSE
BEGIN
	UPDATE Customers
    SET CreditoDisponible = CreditoDisponible - @TotalCompra
    WHERE CustomerID = @CustomerID
END
GO



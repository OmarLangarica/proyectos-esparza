--Creacion de Base de datos 1 
create database BD1 
go
use BD1
go
create table clientes (
cte int not null,
nombre nvarchar(20) not null,
domicilio nvarchar(50) not null
)
go
create table empleados(
emp int not null,
nombre nvarchar(20) not null,
domicilio nvarchar(50) not null,
telefono nvarchar(10) not null
)
go
create table ventas(
folio int not null,
fecha datetime not null,
cte int not null,
emp int not null
)
go
alter table clientes add constraint pk_clientes primary key (cte)
go
alter table empleados add constraint pk_empleados primary key(emp)
go
alter table ventas add constraint pk_ventas primary key(folio)
go
alter table ventas add constraint fk_clientes foreign key (cte) references clientes (cte),
constraint fk_empleados foreign key (emp) references empleados (emp)
go
--Creacion de Base de Datos 2
create database BD2
go
use BD2
go
create table productos(
prod int not null,
nombre nvarchar(20) not null,
cat int not null,
precio numeric(10,2)
)
go
create table categorias(
cat int not null,
nombre nvarchar(20) not null
)
go
create table ventas(
folio int not null,
fecha datetime not null,
prod int not null,
cantidad int not null,
precio numeric(10,2)
)
go
alter table productos add constraint pk_productos primary key (prod)
go
alter table categorias add constraint pk_categorias primary key (cat)
go
alter table ventas add constraint pk_ventas primary key (folio)
go
alter table productos add constraint fk_categorias foreign key (cat) references categorias(cat)
go
alter table ventas add constraint fk_productos foreign key (prod) references productos(prod)

--1.- Dar de alta al IS ALMA pueda apagar el servidor con el comando SHUTDOWN.
create login ALMA with password = '123' 
must_change, check_expiration = on
go
sp_addsrvrolemember ALMA, ServerAdmin

--2.- Dar de alta al IS JUAN para que pueda auxiliar en la administración de inicios de sesión,
--que pueda dar de alta inicios de sesión y cambiar password.
create login JUAN with password = '123'
must_change, check_expiration = on
go
sp_addsrvrolemember JUAN, SecurityAdmin
--3.- Dar de alta al IS JOSE y configurarlo para que tenga las mismas características que el inicio de sesión SA.
create login JOSE with password = '123'
must_change, check_expiration = on
go
sp_addsrvrolemember JOSE, SysAdmin
--4.- Dar de alta al IS PEDRO para que pueda seleccionar y modificar (I/U/D) todas las tablas de las bases de datos BD1 y BD2.
create login PEDRO with password = '123'
must_change, check_expiration = on
go
--BD1
use BD1
create user PEDRO for login PEDRO
go
sp_addrolemember db_datareader,pedro
go
sp_addrolemember db_datawriter, pedro
go
--BD2
use BD2
create user PEDRO for login PEDRO
go
sp_addrolemember db_datareader,pedro
go
sp_addrolemember db_datawriter, pedro
go
--5.- Dar de alta al IS NORA Y PERLA para que puedan crear todos los objetos en BD1.
create login NORA with password = '123'
must_change, check_expiration = on
go
create login PERLA with password = '123'
must_change, check_expiration = on
go
use BD1
create user NORA for login NORA
go
sp_addrolemember db_ddladmin, NORA
go
use BD1
create user PERLA for login PERLA
go
sp_addrolemember db_ddladmin, PERLA
--6.- En la base de datos BD1 crear la función CONSULTA y darle permiso para que pueda seleccionar
--solo las 2 primeras columnas de cada tabla. A los IS NORA Y PERLA creados en el punto 6, agregarlos
--en la función CONSULTA de la base de datos BD1.
use BD1
go
sp_addrole CONSULTA
go
grant select on clientes(cte,nombre) to consulta
grant select on empleados(emp,nombre) to consulta
grant select on ventas(folio, fecha) to consulta
go
sp_addrolemember consulta, NORA
go
sp_addrolemember consulta, PERLA
--7.- Dar de alta al IS CARLOS y que pueda insertar y eliminar datos en la BD2, 
--además pueda crear vistas y tablas en la misma base de datos.
create login CARLOS with password = '123'
must_change, check_expiration = on
go
use BD2
go
create user carlos for login carlos 
go
grant insert, delete to carlos
go
grant create view, create table to carlos
--8.- Es necesario crear los IS siguientes: asesor01, asesor02,… asesor80.
--Crear un procedimiento almacenado que los genere automáticamente con la característica que 
--le cambien el password la primera vez que se conecten.
create procedure sp_crea_asesores as
declare @asesor int,@nombre nvarchar(50),@codigo nvarchar(max)
select @asesor = 1
while @asesor <= 80
begin
	select @nombre = 'asesor' + right('00' + cast(@asesor as varchar), 2)
    select @codigo = '
        create login ' + @nombre + '
        with password = ''123''
        must_change
        , check_expiration = on'

     exec sp_executesql @codigo

     select @asesor = @asesor + 1
    end
go
exec sp_crea_asesores
select * from syslogins 

--9.- De los IS creados en el punto 8, crear un procedimiento almacenado que los de alta como usuario
--en la base de datos BD1.
use BD1
go
create procedure sp_crear_usuarios as
declare @asesor int,@nombre nvarchar(50), @codigo nvarchar(max)
select @asesor = 1
    while @asesor <= 80
    begin
        select @nombre = 'asesor' + right('00' + cast(@asesor as varchar), 2)
        select @codigo = 'create user ' + @nombre + ' for login ' + @nombre
        exec sp_executesql @codigo
        select @asesor = @asesor + 1
    end
go
exec sp_crear_usuarios

--10.- En la base de datos northwind cambiar el esquema DBO de todas tablas por 
--el esquema RECURSOS utilizando un procedimiento almacenado
use northwind
go
create schema RECURSOS
go
alter procedure sp_cambiaresquema as
declare @contador int, @max int, @tabla nvarchar(255), @codigo nvarchar(max)
select @contador = 1
create table #tablas (id int identity(1,1) primary key,nombre nvarchar(255))
insert into #tablas (nombre)
select name 
from sys.objects 
where type = 'u' and schema_id = schema_id('dbo')

select @max = count(*) from #tablas

while @contador <= @max
begin
	select @tabla = nombre from #tablas where id = @contador

    select @codigo = 'alter schema recursos transfer dbo.[' + @tabla + ']'

     exec sp_executesql @codigo

     select @contador = @contador + 1
    end
go
exec sp_cambiaresquema


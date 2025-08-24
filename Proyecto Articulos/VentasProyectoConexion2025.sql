create database ventas
go
use ventas
go
create table familias(
famid int not null,
famnombre varchar( 20) not null )
go
alter table familias add constraint pk_familias primary key ( famid)
go
create table articulos(
artid int not null,
artnombre varchar( 50 ) not null, 
artdescripcion varchar( 500) not null,
artprecio numeric( 12,2) not null,
artTamaño char(1) not null,
famid int not null
)
go
alter table articulos add 
constraint pk_articulos primary key ( artid),
constraint fk_articulos_familias foreign key ( famid ) references familias(famid) ,
constraint cc_articulos_artTipo check( artTamaño in( 'C','M','G'  ) ) 
go
insert familias values( 1, 'Abarrotes' ) 
insert familias values( 2, 'Verduras' ) 
insert familias values( 3, 'Lacteos' ) 
insert familias values( 4, 'Limpieza' ) 
go
insert articulos values( 1, 'Sal la fina', 'Sal de mar',12.34  , 'C', 1) 
insert articulos values( 2, 'Cajeta Coronado', 'Cajeta de cabra', 34.34 , 'C' , 1 ) 
insert articulos values( 3, 'Limón', 'Limón colima',3.45 ,'M', 2 ) 
insert articulos values( 4, 'Tomate', 'Tomate bola',21.12 , 'M', 2 ) 
insert articulos values( 5, 'Queso crema', 'Queso de vaca ligth', 43.45 , 'G', 3 ) 
insert articulos values( 6, 'Salchicha', 'Salchicha alemana',56.34  , 'G',  3) 
insert articulos values( 7, 'Trapeador', 'Trapeador rojo de madera',78.54 ,'G',4 ) 
insert articulos values( 8, 'Cloro', 'Cloro con aroma floral', 89.87, 'M', 4) 
go

--Procedimiento almacenado
create proc sp_grabar
@artid int output, @artnombre varchar(50), @artDescripcion varchar(500), @artPrecio numeric(12,2), @artTamaño char(1), @famid int   as
begin
	if exists(select * from articulos where artid = @artid)
	begin
		update articulos set artnombre = @artnombre, artdescripcion = @artdescripcion, artprecio = @artPrecio, artTamaño = @artTamaño, famid = @famid
		where artid = @artid

		if @@ERROR <> 0
		begin
			raiserror('Error al actualizar la tabla articulos', 16, 1)
		end
	end
	else
	begin
		--Si la llave primaria no es identity, se busca la ultima clave mas 1
		select @artid = coalesce(max(artid), 0)+1 from articulos
		insert articulos(artid,artnombre,artdescripcion,artprecio,artTamaño,famid) values (@artid, @artnombre, @artDescripcion, @artPrecio, @artTamaño, @famid)
		if @@ERROR <> 0
		begin
			raiserror('Error al actualizar en la tabla articulos', 16, 1)
		end
		
	end
end
go

--Revisión prueba usuarios
create login omar with password = '123'
use ventas
create user omar
sp_addrolemember db_datareader, omar
grant execute to omar
grant delete to omar


select * from articulos

--Trigger que impida insertar
create trigger tr_insert
ON articulos for insert as
begin 
	rollback TRAN
	raiserror('No se permite ingresar', 16, 1)
end
go
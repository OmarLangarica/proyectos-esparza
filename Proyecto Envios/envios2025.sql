create database EnviosNet
go
use EnviosNet
go
create table Tipos(
tipid int not null primary key,
tipNombre varchar(50)
)
go
create table clientes(
cliid int not null primary key,
cliNombre varchar(50) not null,
cliApellidos varchar(50) not null,
cliSexo char(1) not null,
cliLimiteCredito numeric(12,2) not null,
tipid int not null
)
go
alter table clientes add constraint fk_clientes_tipos foreign key (tipid) references Tipos(tipid),
constraint fk_clientes_check check(cliSexo in ('f','m'))
go
insert Tipos values(1,'Chico')
insert Tipos values(2,'Mediano')
insert Tipos values(3,'Grande')
insert Tipos values(4,'Extra Grande')

insert clientes values(1,'Carlos','Perez','M',12000,1)
insert clientes values(2,'Ana','Castro','F',10000,2)
insert clientes values(3,'Pedro','Castro','M',5000,3)
insert clientes values(4,'Luis','Lugo','M',12000,2)
insert clientes values(5,'Carlos','Lara','F',5000,1)

go

--Procedimiento almacenado
create proc sp_grabar
@cliid int output, @clinombre nvarchar(50), @cliApellidos nvarchar(100), @cliSexo char(1), @cliLimiteCredito numeric(12,2), @tipid int   as
begin
	if exists(select * from clientes where cliid = @cliid)
	begin
		update clientes set cliNombre = @clinombre, cliApellidos = @cliApellidos, @cliSexo = @cliSexo, cliLimiteCredito = @cliLimiteCredito
		where cliid = @cliid

		if @@ERROR <> 0
		begin
			raiserror('Error al actualizar la tabla articulos', 16, 1)
		end
	end
	else
	begin
		--Si la llave primaria no es identity, se busca la ultima clave mas 1
		select @cliid = coalesce(max(cliid), 0)+1 from clientes
		insert clientes(cliid,clinombre,cliApellidos,cliSexo,cliLimiteCredito,tipid) values (@cliid, @clinombre, @cliApellidos, @cliSexo, @cliLimiteCredito, @tipid)
		if @@ERROR <> 0
		begin
			raiserror('Error al actualizar en la tabla articulos', 16, 1)
		end
		
	end
end
go

--Creación del trigger
--drop trigger tr_insert
create trigger tr_insert
ON clientes for insert as
begin 
	rollback TRAN
	raiserror('No se permite ingresar', 16, 1)
end

--pruebas usuarios
create login pruebaclientes with password = '123'
use EnviosNet
create user pruebaclientes
sp_addrolemember db_datareader, pruebaclientes

grant execute to pruebaclientes
grant delete to pruebaclientes
grant create proc to pruebaclientes
grant alter on schema::dbo to pruebaclientes

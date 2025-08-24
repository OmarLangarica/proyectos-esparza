alter proc sp_generar_relacion @tabla1 nvarchar(100), @tabla2 nvarchar(100) as

declare @texto nvarchar(2000), @alias1 varchar(2), @alias2 varchar(2),@min int, @columna nvarchar(100),
	    @llaveexterna nvarchar(100), @llaveprimaria nvarchar(100),@combinacion nvarchar(500)

select @texto = 'select '
select @alias1 = substring(@tabla1,1, 1)
select @alias2 = substring(@tabla2,1, 1)
            
select @min = min(colid) from syscolumns where id = object_id(@tabla1)
while @min is not null
begin
	select @columna = name from syscolumns where id = object_id(@tabla1) and colid = @min 
    select @texto = @texto + @alias1 + '.' + @columna + ', '
        
    select @min = min(colid) from syscolumns where id = object_id(@tabla1) and colid > @min 
end
    
select @min = min(colid) from syscolumns where id = object_id(@tabla2)
while @min is not null
begin
    select @columna = name from syscolumns where id = object_id(@tabla2) and colid = @min 
    select @texto = @texto + @alias2 + '.' + @columna + ', '
        
    select @min = min(colid) from syscolumns where id = object_id(@tabla2) and colid > @min 
end
    
select @texto = substring(@texto,1, len(@texto) - 1) 
select @texto = @texto + ' from ' + @tabla2 + ' ' + @alias2
    
select @llaveexterna = fk.name, @llaveprimaria = pk.name
from sysforeignkeys sfk
inner join syscolumns fk on fk.id = sfk.fkeyid and fk.colid = sfk.fkey
inner join syscolumns pk on pk.id = sfk.rkeyid and pk.colid = sfk.rkey
where object_name(sfk.rkeyid) = @tabla1 and object_name(sfk.fkeyid) = @tabla2
    
if @llaveexterna is not null and @llaveprimaria is not null
begin
    select @combinacion = ' inner join ' + @tabla1 + ' ' + @alias1 + ' on ' + @alias1 + '.' + @llaveprimaria + ' = ' + @alias2 + '.' + @llaveexterna
    select @texto = @texto + @combinacion
end
select @texto
go
exec sp_generar_relacion 'Suppliers', 'Products'


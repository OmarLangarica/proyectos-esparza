alter proc sp_productoordenes as
begin
    declare @productid int, @productname nvarchar(50), @ordenes nvarchar(max)
    create table #tabla (productname nvarchar(50), ordenes nvarchar(max))
    select @productid = min(productid) from products
    while @productid is not null
    begin
        select @productname = productname from products where productid = @productid
        
        select @ordenes = string_agg(cast(orderid as nvarchar), ', ')
        from [order details]
        where productid = @productid
        
        insert into #tabla values (@productname, @ordenes)
        select @productid = min(productid) from products where productid > @productid
    end

    select productname, ordenes from #tabla
end
go
exec sp_productoordenes

alter proc sp_productoordenes2 as
begin
    declare @productname nvarchar(255), @ordenes nvarchar(max)
    create table #tabla (productname nvarchar(255), ordenes nvarchar(max))
    declare @productid int = (select min(productid) from products)
    
    while @productid is not null
    begin
        select @productname = productname from products where productid = @productid
        
        select @ordenes = string_agg(cast(orderid as nvarchar), ', ')
        from [order details]
        where productid = @productid
        
        insert into #tabla values (@productname, @ordenes)
        select @productid = min(productid) from products where productid > @productid
    end

    select productname, ordenes from #tabla 
end
go
exec sp_productoordenes2


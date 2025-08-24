alter table employees add cambionombre int;
update employees set cambionombre = 0

create trigger tr_nombre on employees
for update
as
    declare @nombrecambiado int, @empid int

    select @nombrecambiado = cambionombre from deleted
    select @empid = employeeid from inserted

    if (update(firstname))
    begin
        if (@nombrecambiado = 0)
        begin
            update employees set cambionombre = 1
            where employeeid = @empid
        end
        else
        begin
            rollback tran
            raiserror('el nombre del empleado no puede ser cambiado más de una vez', 16, 1)
        end
    end
go

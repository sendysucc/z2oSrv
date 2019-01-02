use z2osrv;

drop procedure if exists proc_login;

delimiter ;;

create procedure proc_login(IN cellphone varchar(11), IN passwd varchar(40))
label_login:begin
    declare errcode int;
    declare o_paswd varchar(11);

    declare o_userid int;
    declare o_username varchar(12);
    declare o_nickname varchar(30);
    declare o_gender int;
    declare o_agentname int;
    declare o_promoteid int;

    set errcode = 0;
    set o_paswd = '';

    select password into o_paswd from User where User.cellphone = cellphone;
    if o_paswd == '' then
        set errcode = 1;    #cellphone not exists
        select errcode as 'errcode';
        leave label_login;
    end if;

    if o_paswd <=> passwd then


    end if;

end
;;
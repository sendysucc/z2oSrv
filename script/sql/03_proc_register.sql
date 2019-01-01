use z2osrv;

drop procedure if exists proc_register;

delimiter ;;

create procedure proc_register (IN cellphone varchar(11), IN passwd varchar(40), IN agentcode varchar(6),IN promotecode varchar(50))
label_reg:begin
    declare errcode int;
    declare o_agentid int;
    declare o_promoteid int;
    declare o_userid int;

    set o_agentid = 0;
    set o_promoteid = 0;
    set o_userid = 0;

    select agentid into o_agentid from Agent where Agent.agentid = agentcode;
    if o_agentid <=> 0 then
        select agentid into o_agentid from Agent where Agent.aigentid = 1;
    end if;

    select promoteid into o_promoteid from Promote where Promote.code = promotecode;
    if o_promoteid <=> 0 then
        select promoteid into o_promoteid from Promote where Promote.promoteid = 1;
    end if;


    if length(passwd) != 40 then
        return 2;   --password error.
    end if;

    select userid into o_userid from User where User.cellphone = cellphone;


end
;;
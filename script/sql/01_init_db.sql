drop database if exists z2osrv;

create database if not exists z2osrv default charset utf8 collate utf8_general_ci;

use z2osrv;

drop user 'sendy'@'%';

create user 'sendy'@'%' identified by 'sendy';

grant all on z2osrv.* to 'sendy'@'%';
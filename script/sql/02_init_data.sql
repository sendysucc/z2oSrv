use z2osrv;

insert into Agent(agentid,name,cellphone,createtime) value (1,'系统默认','09566014786',now());

insert into Game(gameid,name,minplayers,maxplayers,enable) value (20001,'抢庄牛牛',2,6,true);

insert into Promote(promoteid,code,name,detail,createtime) value(1,'sjda1001','系统默认','自身推广',now());

insert into GameRoom(roomid,name,minentry,maxentry,gameid,enable) value (1,'体验房',10,100,20001,true);
insert into GameRoom(roomid,name,minentry,maxentry,gameid,enable) value (2,'中级房',200,900,20001,true);
insert into GameRoom(roomid,name,minentry,maxentry,gameid,enable) value (3,'高级房',1000,10000,20001,true);
insert into GameRoom(roomid,name,minentry,maxentry,gameid,enable) value (4,'VIP房',20000,900000,20001,true);


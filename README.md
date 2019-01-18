# z2oSrv

                                
client----->gate----> agent-----> login
                                          succ
                                      -------------> hall
                                      -------------> game


        gate    agent   login   hall    game1,game2,game3,....


    agent 只做消息转发, 不做任何逻辑.




像加入游戏，退出游戏，游戏断线，断线重连，这些消息需要经过PlayerManager ，再由PlayerManager 交给对应的服务处理.

而游戏中的消息，则直接由Agent转交给对应的游戏服务处理.



new design :
    
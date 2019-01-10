local skynet = require "skynet"
local snax = require "skynet.snax"
local errcode = require "errorcode"

local GAMES
local GSERVICES = {}
local alloc_co          --创建 game service 的协程
local queue = {}
local userid_co = {}


--从数据库更新游戏列表
local function updategame()
    local tmpGAMES = {}
    local tempGSERVICES = {}
    local dbobj = snax.queryservice('dbmanager')
    local games = dbobj.req.gamelist()
    for k,v in pairs(games) do
        tmpGAMES[v.gameid] = v
        tmpGAMES[v.gameid].rooms = tmpGAMES[v.gameid].rooms or {}
        tempGSERVICES[v.gameid] = {}
    end
    local rooms = dbobj.req.roomlist()
    for k,v in pairs(rooms) do
        table.insert(tmpGAMES[v.gameid].rooms, v)
        tempGSERVICES[v.gameid][v.roomid] =  {}
    end
    GAMES = tmpGAMES

    for gid, rooms in pairs(GSERVICES) do
        for rid, srv in pairs(rooms) do
            tempGSERVICES[gid][rid] = GSERVICES[gid][rid] or {}
        end
    end
    GSERVICES = tempGSERVICES

    for gid,rooms in pairs(GSERVICES) do
        for rid, servs in pairs(rooms) do
            for k,v in pairs(servs) do
                print('---->gservices: ',gid,rid,k,v)
            end
        end
    end
end

local function allocgameservice()
    for gid, gqueue in pairs(queue) do
        for rid, rqueue in pairs(gqueue) do
            if #rqueue > 0 then
                for k, inst in pairs(GSERVICES[gid][rid] or {}) do
                    local canjoin, needstart, leftcount = inst.req.canjoin()
                    if canjoin == true then
                        for i = 1, needstart do
                            local userid = table.remove(rqueue,1)
                            if not userid then
                                break
                            end
                            inst.userjoin(userid)
                        end
                        for i = 1, leftcount - needstart do
                            local userid = table.remove(rqueue,1)
                            if not userid then
                                break
                            end
                            inst.userjoin(userid)
                        end
                        local bstart, needs = inst.req.gamestart()
                        if not bstart then  --增加机器人
                            for i = 1, needs do

                            end
                        end
                    end
                end

                -- 如果还有玩家没有分配,则需要创建新的游戏服务来分配玩家
                if #rqueue > 0 then

                end

            
            end
        end
    end

    skynet.sleep(100 * 3)

    ------------------------------------------------
    for i = 0 , 20 do
        skynet.error('------>[gamemanager] sleep :' .. i )
        skynet.sleep(100)
    end
    snax.queryservice('hall').post.matched(10001,{ msg = 'game matched' })
    return errcode.code.SUCCESS
end

function init(...)
    updategame()
    --game service 创建协程
    skynet.fork(function() 
        alloc_co = coroutine.running()
        while true do
            if allocgameservice() == errcode.code.SUCCESS then
                break
            end
        end
    end)
end

function accept.updategame()
    updategame()
end

function response.gamelist()
    return GAMES
end

function accept.match(userid,gameid,roomid)
    queue[gameid] = queue[gameid] or {}
    queue[gameid][roomid] = queue[gameid][roomid] or {}
    table.insert(queue[gameid][roomid],userid)
end
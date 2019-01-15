local skynet = require "skynet"
local snax = require "skynet.snax"
local errcode = require "errorcode"
local gamedata = require "gamedata"

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
end

local function matchingplayer(rqueue,gameid,roomid)
    for k, inst in pairs(GSERVICES[gameid][roomid] or {}) do
        local canjoin, needstart ,leftcount = inst.req.canjoin()
        if canjoin == errcode.code.SUCCESS then
            --先分配游戏开始最少需要的人数
            for i = 1, needstart do
                local userid = table.remove(rqueue,1)
                if not userid then
                    break
                end
                local succ = inst.req.userjoin(userid)
            end
            --游戏还剩余的座位人数
            for i = 1, leftcount - needstart do
                local userid = table.remove(rqueue,1)
                if not userid then
                    break
                end
                inst.req.userjoin(userid)
            end
            -- 开始游戏, 如果游戏人数不足, 则分配机器人加入
            local bstart, needs = inst.req.gamestart()
            if bstart ~= errcode.code.SUCCESS then
                local robot = snax.queryservice('robotmanager').req.getrobot()
                local ret = inst.req.userjoin(robot.userid)
            end
            inst.req.gamestart()
        end
    end
end

local function allocgameservice()
    --alloc queue players to exists availible game service
    for gid, gqueue in pairs(queue) do
        for rid, rqueue in pairs(gqueue) do
            while #rqueue > 0 do
                --匹配玩家
                matchingplayer(rqueue,gid,rid)
                -- 如果还有玩家没有分配,则需要创建新的游戏服务来分配玩家
                while #rqueue > 0 do
                    local game = GAMES[gid]
                    local room = GAMES[gid].rooms[rid]
                    local minplayers = game.minplayers
                    local maxplayers = game.maxplayers
                    local gametype = game.gametype
                    local minentry = room.minentry
                    local maxentry = room.maxentry
                    assert(gamedata[gid])
                    local gobj = snax.newservice(gamedata[gid].service,minplayers,maxplayers,gametype,minentry,maxentry)
                    table.insert(GSERVICES[gid][rid],gobj)
                    --匹配玩家
                    matchingplayer(rqueue,gid,rid)
                end
            end
        end
    end
    skynet.sleep(100 * 3)
end

function init(...)
    updategame()
    --game service 创建协程
    skynet.fork(function() 
        alloc_co = coroutine.running()
        while true do
            allocgameservice()
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
    -- condition check: 1. game enable ?  2.minentry ? ...
    -- game enable ?
    if not GAMES[gameid] or GAMES[gameid].enable ~= 1 then
        snax.queryservice('hall').post.matched(userid,{ errcode = errcode.code.GAMEDISABLED })
        return 
    end

    --room enable ?
    if GAMES[gameid].rooms[roomid].enable ~= 1 then
        snax.queryservice('hall').post.matched(userid,{ errcode = errcode.code.GAMEDISABLED })
        return 
    end

    -- minentry ?
    local retcode,usergold = snax.queryservice('playermanager').req.getgoldbyId(userid)
    usergold = usergold or 0
    if GAMES[gameid].rooms[roomid].minentry > usergold then
        snax.queryservice('hall').post.matched(userid, { errcode = errcode.code.LESSMINENTRY })
        return 
    end
    queue[gameid] = queue[gameid] or {}
    queue[gameid][roomid] = queue[gameid][roomid] or {}
    table.insert(queue[gameid][roomid],userid)
end
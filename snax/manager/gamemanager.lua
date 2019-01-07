local skynet = require "skynet"
local snax = require "skynet.snax"

local GAMES
local GSERVICES = {}
local alloc_co          --创建 game service 的协程
local queue = {}
local userid_co = {}


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
    if #queue <= 0 then
        print('----------allocgameservice sleeping')
        skynet.wait()
    end
    
    print('allocgameservice : ------alloc gameservice' )

end

function init(...)
    skynet.error('---------> start gamemanager service')
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

function response.joingame(userid,gameid,roomid)
    -- local obj = snax.newservice('qznn')
    -- table.insert(GSERVICES[gameid][roomid], obj)
    local running_co = coroutine.running()
    userid_co[userid] = running_co
    
    if running_co ~= alloc_co then
        skynet.wakeup(alloc_co)
    end
end



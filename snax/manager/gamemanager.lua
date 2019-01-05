local skynet = require "skynet"
local snax = require "skynet.snax"

local GAMES
local GSERVICES = {}

local function update()
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

function init(...)
    skynet.error('---------> start gamemanager service')
    update()
end

function accept.updategame()
    update()
end

function response.gamelist()
    return GAMES
end

function response.joingame(gameid,roomid)
    local gobj = snax.newservice('20001')
    
end



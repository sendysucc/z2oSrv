local skynet = require "skynet"
local snax = require "skynet.snax"

local GAMES

local function update()
    local tmpGAMES = {}

    local dbobj = snax.queryservice('dbmanager')
    local games = dbobj.req.gamelist()
    for k,v in pairs(games) do
        tmpGAMES[v.gameid] = v
        tmpGAMES[v.gameid].rooms = tmpGAMES[v.gameid].rooms or {}
    end
    local rooms = dbobj.req.roomlist()
    for k,v in pairs(rooms) do
        table.insert(tmpGAMES[v.gameid].rooms, v)
    end
    GAMES = tmpGAMES
end

function init(...)
    skynet.error('---------> start gamemanager service')
    update()
end

function response.gamelist()
    return GAMES
end

function accept.updategame()
    update()
end
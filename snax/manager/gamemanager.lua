local skynet = require "skynet"
local snax = require "skynet.snax"

local GAMES = {}

local function update()
    GAMES = {}
    local dbobj = snax.queryservice('dbmanager')
    local games = dbobj.req.gamelist()
    for k,v in pairs(games) do
        GAMES[v.gameid] = v
        GAMES[v.gameid].rooms = GAMES[v.gameid].rooms or {}
    end
    local rooms = dbobj.req.roomlist()
    for k,v in pairs(rooms) do
        table.insert(GAMES[v.gameid].rooms, v)
    end
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
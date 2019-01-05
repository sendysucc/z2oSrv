local skynet = require "skynet"
local snax = require "skynet.snax"


function init(...)
    
end

function response.gamelist()
    local gmobj = snax.queryservice('gamemanager')
    if gmobj then
        local ret = gmobj.req.gamelist()

        local resp = {}
        for k,v in pairs(ret) do
            table.insert(resp,v)
        end
        return {games = resp}
    end
end
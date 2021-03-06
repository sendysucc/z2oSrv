local skynet = require "skynet"
local snax = require "skynet.snax"

skynet.start(function()
    -- start debug console
    skynet.newservice("debug_console",30001)
    skynet.uniqueservice("protoloader")

    --start database manager
    snax.uniqueservice("dbmanager")
    --start gamemanager 
    snax.uniqueservice("gamemanager")
    --start player manager
    snax.uniqueservice("playermanager")
    --start filter 
    snax.uniqueservice("filter")
    --start hall
    snax.uniqueservice("hall")
    --start login
    snax.uniqueservice("login")
    
    -- start gate
    local gate = skynet.uniqueservice("gated")
    skynet.send(gate,'lua','open', {
        port = 12288,   -- (1024*12)
        maxclient = 10240, --(1024*10)
        nodelay = true,
    })

    skynet.exit()
end)
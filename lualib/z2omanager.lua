local skynet = require "skynet"
local snax = require "skynet.snax"

local mgr = {}

function mgr.getmanager(name)
    return snax.queryservice(name)
end


return mgr
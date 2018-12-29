local skynet = require "skynet"
local snax = require "skynet.snax"

function init(...)

end

function response.register(cellphone, password, agentcode,promotecode)
    local obj = snax.queryservice("dbmanager")
    if obj then
        return obj.req.register(cellphone,password,agentcode,promotecode)
    else
        return 1    -- obj not exists
    end
end

function response.login()

end


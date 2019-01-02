local skynet = require "skynet"
local snax = require "skynet.snax"
local crypt = require "skynet.crypt"


local function sha1(text)
    local c = crypt.sha1(text)
    return crypt.hexencode(c)
end

function init(...)

end

function response.register(cellphone, password, agentcode,promotecode)
    local obj = snax.queryservice("dbmanager")
    if obj then
        password = sha1(password)
        print('-------->login :', tostring(promotecode))
        return obj.req.register(cellphone,password,agentcode,promotecode)
    else
        return 1    -- obj not exists
    end
end

function response.login(cellphone, password)
    local obj = snax.queryservice("dbmanager")
    if obj then
        return obj.req.login(cellphone,password)
    else
        return 1
    end

end


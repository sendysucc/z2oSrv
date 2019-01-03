local skynet = require "skynet"
local snax = require "skynet.snax"
local crypt = require "skynet.crypt"
local errcode = require "errorcode"


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
        return obj.req.register(cellphone,password,agentcode,promotecode)
    else
        return errcode.code.DBSYNTAXERROR    -- obj not exists
    end
end

function response.login(cellphone, password)
    local obj = snax.queryservice("dbmanager")
    if obj then
        password = sha1(password)
        local userinfo = obj.req.login(cellphone,password)
        if userinfo.errcode == errcode.code.SUCCESS then
            local pmobj = snax.queryservice("playermanager")
            if pmobj then
                pmobj.post.adduser(userinfo)
            end
        end
        return userinfo
    else
        return errcode.code.DBSYNTAXERROR
    end
end


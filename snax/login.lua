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
    password = sha1(password)
    return snax.queryservice("dbmanager").req.register(cellphone,password,agentcode,promotecode)
end

function response.login(cellphone, password,agenthandle)
    password = sha1(password)
    local userinfo = snax.queryservice("dbmanager").req.login(cellphone,password)
    if userinfo.errcode == errcode.code.SUCCESS then
        local ecode, breakuserinfo = snax.queryservice("playermanager").req.adduser(userinfo, agenthandle)
        if ecode == errcode.code.ALREADLOGINED then --已登录
            return { errcode = errcode.code.ALREADLOGINED }
        elseif ecode == errcode.code.RECONNECT then --断线重连
            userinfo = breakuserinfo
            userinfo.errcode = errcode.code.RECONNECT
        end
    end
    return userinfo
end

function response.logout(userid)
    local ret = snax.queryservice("playermanager").logout(userid)
end
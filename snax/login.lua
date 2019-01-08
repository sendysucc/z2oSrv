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
    print('------------->register: ', response)
    local obj = snax.queryservice("dbmanager")
    if obj then
        password = sha1(password)
        return obj.req.register(cellphone,password,agentcode,promotecode)
    else
        return errcode.code.OBJNOTEXISTS    -- obj not exists
    end
end

function response.login(cellphone, password,agenthandle)
    local obj = snax.queryservice("dbmanager")
    if obj then
        password = sha1(password)
        local userinfo = obj.req.login(cellphone,password)
        if userinfo.errcode == errcode.code.SUCCESS then
            local pmobj = snax.queryservice("playermanager")
            if pmobj then
                local ecode, breakuserinfo = pmobj.req.adduser(userinfo, agenthandle)
                if ecode == errcode.code.ALREADLOGINED then --已登录
                    return { errcode = errcode.code.ALREADLOGINED }
                elseif ecode == errcode.code.RECONNECT then --断线重连
                    userinfo = breakuserinfo
                    userinfo.errcode = errcode.code.RECONNECT
                end
            end
        end
        return userinfo
    else
        return errcode.code.OBJNOTEXISTS
    end
end

function response.logout(userid)
    local pmobj = snax.queryservice("playermanager")
    if pmobj then
        local ret = pmobj.logout(userid)
    end
end
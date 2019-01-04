local skynet = require "skynet"
local snax = require "skynet.snax"
local errcode = require "errorcode"

local ONLINES = {}
local BREAKLINES = {}
--[[
    userid
    username
    nickname
    gold
    diamond
    avatoridx
    cellphone
    password
    gender
    promoteid
    agentid
    disable
    createtime
]]

function init(...)
    skynet.error('------> start playermanager service')
end

function response.adduser(userinfo,agenthandle)
    local userid = userinfo.userid
    if ONLINES[userid] then
        skynet.error('user :' .. userinfo.userid .. ' already logined ')
        return errcode.code.ALREADLOGINED
    end
    if BREAKLINES[userid] then
        skynet.error('user : ' .. userinfo.userid ..  ' has breakline ')
        return errcode.code.RECONNECT, BREAKLINES[userid]
    end
    ONLINES[userid] = userinfo
    ONLINES[userid].agenthandle = agenthandle
    return errcode.code.SUCCESS
end

function accept.breakline(agenthandle)
    for k,v in pairs(ONLINES) do
        if v.agenthandle == agenthandle then
            if v.gaming then
                v.agenthandle = nil
                BREAKLINES[v.userid] = v
            end
            ONLINES[v.userid] = nil
            print('----------->clear user :' .. v.userid)
            break
        end
    end
end

function accept.clearuser(userid)
    if ONLINES[userid] then
        ONLINES[userid] = nil
    end
    if BREAKLINES[userid] then
        BREAKLINES[userid] = nil
    end
end

function response.logou(userid)

end
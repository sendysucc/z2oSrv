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

local userid_co = {}

function init(...)
    skynet.error('------> start playermanager service')
end

local function isrobot(userid)
    if userid >= 900000 then
        return true
    end
    return false
end

--[[
    为啥 PlayerManager 中需要在用户信息中保存 agent handle?

    由于socket断开等消息是由agent来处理的 , 所以当用户断线时 , 需要通知PlayerManager
    让PlayerManager知道用户已经断线了.
]]
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

function response.logout(userid)

end

function response.getagent(userid)
    if not ONLINES[userid] then
        return errcode.code.PLAYERNOTFOUND
    end
    return errcode.code.SUCCESS,ONLINES[userid].agenthandle
end

function response.getgoldbyId(userid)
    if isrobot(userid) then
        local gold = snax.queryservice('robotmanager').req.getgoldbyId(userid)
        return errcode.code.SUCCESS, gold
    end

    if not ONLINES[userid] then
        return errcode.code.PLAYERNOTFOUND
    else
        return errcode.code.SUCCESS, ONLINES[userid].gold
    end
end

function response.getuserbyId(userid)
    if isrobot(userid) then
        local ret = snax.queryservice('robotmanager').req.findrobotbyId(userid)
        return ret
    else
        return ONLINES[userid] or BREAKLINES[userid]
    end
end
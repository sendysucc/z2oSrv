local skynet = require "skynet"
local snax = require "skynet.snax"
local errcode = require "errorcode"

local loadcounts = 100  --默认每次加载机器人数量
local alreadyload = 0   --已经加载机器人数量
local ONLINES = {}
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

local function isrobot(userid)
    if userid >= 900000 then
        return true
    end
    return false
end

local function createrobots()
    local ret = snax.queryservice('dbmanager').post.createrobots()
end

local function loadrobots()
    skynet.error('loadrobots...')
    while true do
        local rets = snax.queryservice('dbmanager').req.loadrobots(alreadyload, needtoload or loadcounts) or {}
        alreadyload = alreadyload + #rets
        for k,v in pairs(rets) do
            ONLINES[v.userid] = v
        end
        if #rets < loadcounts then
            createrobots()
            needtoload = (needtoload or loadcounts) - #rets
        else
            needtoload = 0    
            break
        end
    end
end

local function clearuser(userid)
    if ONLINES[userid] then
        skynet.error('----->user cleared '.. userid)
        ONLINES[userid] = nil
    end
end

function init(...)
    skynet.error('------> start playermanager service')
    loadrobots()
end

--[[
    为啥 PlayerManager 中需要在用户信息中保存 agent handle?

    由于socket断开等消息是由agent来处理的 , 所以当用户断线时 , 需要通知PlayerManager
    让PlayerManager知道用户已经断线了.
]]
function response.adduser(userinfo,agenthandle)
    local userid = userinfo.userid
    if ONLINES[userid] and not ONLINES[userid].breakline then
        skynet.error('user :' .. userinfo.userid .. ' already logined ')
        return errcode.code.ALREADLOGINED
    end
    if ONLINES[userid] and ONLINES[userid].breakline then
        skynet.error('user : ' .. userinfo.userid ..  ' has breakline ')
        ONLINES[userid].breakline = false
        return errcode.code.RECONNECT, ONLINES[userid]
    end
    ONLINES[userid] = userinfo
    ONLINES[userid].agenthandle = agenthandle
    return errcode.code.SUCCESS
end

function accept.breakline(agenthandle)
    for k,v in pairs(ONLINES) do
        if v.agenthandle == agenthandle then
            if v.gobj then
                v.breakline = true
            else
                clearuser(v.userid)
            end
            break
        end
    end
end

function accept.clearuser(userid)
    clearuser()
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
    if not ONLINES[userid] then
        return errcode.code.PLAYERNOTFOUND
    else
        return errcode.code.SUCCESS, ONLINES[userid].gold
    end
end

function response.getuserbyId(userid)
    return ONLINES[userid] or {}
end

function response.getrobot(gameinst,minmoney)
    while true do
        for k,v in pairs(ONLINES) do
            if v.isrobot == 1 and not v.gobj and v.gold >= minmoney then
                return v
            end
        end
        loadrobots()
    end
end

function accept.joingamesucc(userid,gameinst)
    if ONLINES[userid] then
        ONLINES[userid].gobj = gameinst
    end
end
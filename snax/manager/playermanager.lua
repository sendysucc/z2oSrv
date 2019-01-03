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

function accept.adduser(userinfo)
    local userid = userinfo.userid
    if ONLINES[userid] then
        skynet.error('user :' .. userinfo.userid .. ' already logined ')
        return
    end
    if BREAKLINES[userid] then
        skynet.error('user : ' .. userinfo.userid ..  ' has breakline ')
        return
    end
    ONLINES[userid] = userinfo
end

function response.logincheck(cellphone)

end

function accept.breakline()
    
end
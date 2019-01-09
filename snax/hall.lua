local skynet = require "skynet"
local snax = require "skynet.snax"
local errcode = require "errorcode"

local userid_co = {}
local userid_matchinfo = {}

function init(...)
    
end

function response.gamelist()
    local ret = snax.queryservice('gamemanager').req.gamelist()
    local resp = {}
    for k,v in pairs(ret) do
        table.insert(resp,v)
    end
    return {games = resp}
end

function response.match(userid,gameid,roomid)
    if userid_co[userid] then
        return 
    end
    
    userid_co[userid] = coroutine.running()
    snax.queryservice('gamemanager').post.match(userid,gameid,roomid)
    skynet.wait()

    userid_co[userid] = nil
    local resp = userid_matchinfo[userid]
    print('-----> resp',resp)
    for k,v in pairs(resp) do
        print(k,v)
    end
    return resp
end

function accept.matched(userid,matchinfo)
    userid_matchinfo[userid] = matchinfo
    if userid_co[userid] then
        skynet.wakeup(userid_co[userid])
    end
end
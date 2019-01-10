local skynet = require "skynet"
local snax = require "skynet.snax"
local logic = require "qznnlogic"

local playing = false   --游戏是否开始
local players = {}      --游戏中的玩家
local minplayer = 0     --游戏最小人数
local maxplayer = 0     --游戏最大人数
local gametype          --百人类, 对战类...
local bets = {}         --下注记录

function init(...)
    playing = false
    
end

--游戏开始
function response.gamestart()
    if #players < minplayer then
        return false, minplayer - #players
    end

    --start game


    return true, 0
end

--用户加入
function response.userjoin(userid)
    if #players >= maxplayer then
        return false
    else
        local count = #players
        players[count + 1] = userid
        return true
    end
end

function response.isplaying()
    return playing
end

--[[
    返回两个值, 
    1：bool ,是否可以加入游戏
    2: integer , 游戏还可允许多少人加入
]]
function response.canjoin()
    if playing == false and #players < maxplayer then
        local need = minplayer - #players
        if need < 0 then
            need = 0
        end
        return true , need , (maxplayer - #players)
    else
        return false , 0
    end
end

--退出游戏
function response.quit(userid)

end

--抢庄
function response.grab(userid,times)

end

--下注
function response.bet(userid,times)

end

--拼牌
function response.compose(userid, cardtype)

end
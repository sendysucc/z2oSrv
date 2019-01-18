local skynet = require "skynet"
local snax = require "skynet.snax"
local logic = require "qznnlogic"
local errcode = require "errorcode"
local card = require "card"

local playing = false   --游戏是否开始
local players = {}      --游戏中的玩家
local minplayer = 0     --游戏最小人数
local maxplayer = 0     --游戏最大人数
local minentry = 0      --最小准入
local maxentry = 0      --最大准入
local gametype          --百人类, 对战类...
local bets = {}         --下注记录
local status = nil      --游戏状态
local turnexpired = 0   --每轮计时器
local callbacks = nil   --回调

local grab = {}         --抢庄
local bets = {}         --下注


local function setstatus(statu)
    status = statu
    turnexpired = logic.exptime[status]
end

local function setgameplaying(isplay)
    playing = isplay
end

local function onstart()
    print('---------> on start , status:' ,status, ' turnexpired:',turnexpired)
end

local function ongrab()
    print('---------> on ongrab , status:' ,status, ' turnexpired:',turnexpired)
end

local function onbetting()
    print('---------> on onbetting , status:' ,status, ' turnexpired:',turnexpired)
end

local function onsendcard()
    print('---------> on onsendcard , status:' ,status, ' turnexpired:',turnexpired)
end

local function oncalcard()
    print('---------> on oncalcard , status:' ,status, ' turnexpired:',turnexpired)
end

local function onpkcard()
    print('---------> on onpkcard , status:' ,status, ' turnexpired:',turnexpired)
end

local function onsettle()
    print('---------> on onsettle , status:' ,status, ' turnexpired:',turnexpired)
end

local function cleardata()
    setgameplaying(false)
    players = {}
end

function init(...)
    callbacks = {
        [logic.gamestatu.START] = onstart,
        [logic.gamestatu.GRAB] = ongrab,
        [logic.gamestatu.BETTING] = onbetting,
        [logic.gamestatu.SENDCARD] = onsendcard,
        [logic.gamestatu.CALCARD] = oncalcard,
        [logic.gamestatu.PKCARD] = onpkcard,
        [logic.gamestatu.SETTLE] = onsettle,
    }
    setgameplaying(false)
    setstatus(logic.gamestatu.START)
    minplayer,maxplayer,gametype, minentry,maxentry = ...
end

local function loop()
    print('------>loop',status,turnexpired)
    if logic.exptime[status] == turnexpired then
        callbacks[status]()
    end
end

local function nextStatus()
    turnexpired = turnexpired - 1
    if turnexpired == 0 then
        if status + 1 > logic.gamestatu.SETTLE then
            setgameplaying(false)
        else
            setstatus(status + 1)
        end
    end
end

--游戏开始
function response.gamestart()
    if #players < minplayer then
        return errcode.code.LESSTOSTART, (minplayer - #players)
    end
    --start game
    local userinfos = {}
    for k,uid in pairs(players) do
        local uinfo = snax.queryservice('playermanager').req.getuserbyId(uid)
        table.insert(userinfos,{ seatno = k, nickname = uinfo.nickname, cellphone = uinfo.cellphone, 
                    gold =  uinfo.gold, avatoridx = uinfo.avatoridx , gender = uinfo.gender})
    end

    for k,uid in pairs(players) do
        snax.queryservice('hall').post.matched(uid, { errcode = errcode.code.SUCCESS, gameid = gameid, roomid = roomid , gsrvobj = snax.self(), players = userinfos})
    end
    setgameplaying(true)

    skynet.fork(function()
        skynet.sleep(200)
        while playing do
            loop()
            skynet.sleep(100)
            
            nextStatus()
        end
    end)

    return errcode.code.SUCCESS , 0
end

--用户加入
function response.userjoin(userid)
    if #players >= maxplayer then
        return error.code.PLAYERFULL
    end

    local succ,gold = snax.queryservice('playermanager').req.getgoldbyId(userid)
    if succ ~= errcode.code.SUCCESS then
        return succ
    end

    if (gold or 0) < minentry then
        return errcode.code.LESSMINENTRY
    end

    local count = #players
    players[count + 1] = userid
    return errcode.code.SUCCESS
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
        return errcode.code.SUCCESS , need , (maxplayer - #players)
    else
        return errcode.code.CANTJOINGAME , 0
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
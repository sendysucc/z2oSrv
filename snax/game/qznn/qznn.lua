local skynet = require "skynet"
local snax = require "skynet.snax"
local logic = require "qznnlogic"

local playing = false
local players = {}

function init(...)
    playing = false
    
end

--游戏开始
function accept.gamestart()

end

--用户加入
function response.userjoin(userid)

end

function response.isplaying()
    return playing
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
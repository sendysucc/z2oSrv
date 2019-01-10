local skynet = require "skynet"
local snax = require "skynet.snax"
local errcode = require "errorcode"

local idlerobots = {}   --空闲机器人
local busyrobots = {}   --正在游戏中的机器人
local loadcounts = 100  --默认每次加载机器人数量
local alreadyload = 0   --已经加载机器人数量

local function loadrobots()
    local rets = snax.queryservice('dbmanager').req.loadrobots(alreadyload,loadcounts)
    idlerobots = rets
end

function init(...)
    loadrobots()
end

function response.newrobot()

end
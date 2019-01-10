local skynet = require "skynet"
local snax = require "skynet.snax"
local errcode = require "errorcode"

local idlerobots = {}   --空闲机器人
local busyrobots = {}   --正在游戏中的机器人
local loadcounts = 100  --默认每次加载机器人数量
local alreadyload = 0   --已经加载机器人数量

local function loadrobots()
    local rets = snax.queryservice('dbmanager').req.loadrobots(alreadyload,loadcounts)
    for k,v in pairs(rets) do
        table.insert(idlerobots,v)
    end
end

function init(...)
    loadrobots()
end

function response.getarobot()
    if #idlerobots <= 0 then
        loadrobots()
    end

    local robot = table.remove(idlerobots, math.random(1,#idlerobots))
    table.insert(busyrobots,robot)
    return robot
end
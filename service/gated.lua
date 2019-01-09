local skynet = require "skynet"
local snax = require "skynet.snax"
local gateserver = require "snax.gateserver"
local manager = require "z2omanager"
local code = require "retcodes"

local connection = {}
local handler = {}
local CMD = {}

skynet.register_protocol({
    name = "client",
    id = skynet.PTYPE_CLIENT,
})

local function close_fd(fd)
    local c = connection[fd]
    if c then
        connection[fd] = nil
    end
end

local function close_client(fd)
    gateserver.closeclient(fd)
end

--listen socket open success
function handler.open(source,conf)

end

--client message
function handler.message(fd,msg,sz)
    local c = connection[fd]
    local agent = c.agent
    if agent then
        agent.post.rawmessage(fd,msg,sz)
    else
        skynet.error('client no agent ! drop message')

        close_client(fd)
    end
end

--client connected 
function handler.connect(fd,addr)
    local obj = manager.getmanager('filter')
    if obj then
        local result,msg = obj.req.filter(addr)
        if result == code.codes.SUCC then
            local c = {
                fd = fd,
                ip = addr,
            }
            c.agent = snax.newservice("agent",fd)
            connection[fd] = c
            gateserver.openclient(fd)
        else
            gateserver.closeclient(fd)
            skynet.error('---->invalid ip: ', code.msg[result])
        end
    end
end

--client disconnet
function handler.disconnect(fd)
    local c = assert(connection[fd])
    local agent = c.agent
    if agent then
        agent.post.disconnect()
    end
    close_fd(fd)
end

--client socket error
function handler.error(fd,msg)
    skynet.error('[gated] socket error ' .. fd .. ' :' .. tostring(msg))
    close_client(fd)
end

--client send message too large
function handler.warning(fd,size)

    skynet.error('[gated] too large message ' .. fd .. size)
    close_client(fd)
end

function handler.command(cmd,source,...)
    local f = assert(CMD[cmd])
    return f(source,fd,...)
end

function CMD.forward(source,fd,address,snaxname)
    local c = assert(connection[fd])
    local handle = address or source
    local obj = snax.bind(handle,snaxname)
    c.agent = obj
end

function CMD.kick(source,fd)
    close_client(fd)
end

function CMD.updategame(source,fd)
    local gmobj = snax.queryservice('gamemanager')
    if gmobj then
        gmobj.post.updategame()
    end
end

function CMD.loadfile(source,fd,filename)
    loadfile(filename)
end

gateserver.start(handler)
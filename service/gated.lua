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

--listen socket open success
function handler.open(source,conf)

end

--client message
function handler.message(fd,msg,sz)
    local c = connection[fd]
    local agent = c.agent
    if agent then
        agent.req.rawmessage(fd,msg,sz)
    else
        local obj = snax.queryservice("login")
        if obj then
            obj.req.rawmessage(fd,msg,sz)
        end
    end
end

--client connected 
function handler.connect(fd,addr)
    local obj = manager.getmanager('filter')
    if obj then
        local result,msg = obj.req.filter(addr)
        if result == code.codes.SUCC then
            skynet.error('----> success')
            local c = {
                fd = fd,
                ip = addr,
            }
            c.agent = snax.queryservice("hall")
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

end

--client socket error
function handler.error(fd,msg)

end

--client send message too large
function handler.warning(fd,size)

end

function handler.command(cmd,source,...)
    local f = assert(CMD[cmd])
    return f(source,...)
end

function CMD.forward(source,fd,address,snaxname)
    local c = assert(connection[fd])
    local handle = address or source
    local obj = snax.bind(handle,snaxname)
    c.agent = obj
end

function CMD.kick(source,fd)
    gateserver.closeclient(fd)
end

gateserver.start(handler)


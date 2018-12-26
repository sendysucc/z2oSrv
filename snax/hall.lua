local skynet = require "skynet"
local sproto = require "sproto"
local helper = require "helper"
local snax = require "skynet.snax"

local sp_host
local sp_request

function init(...)
    sp_host = sproto.new(helper.getprotobin("./proto/c2s.spt")):host("package")
    sp_request = sp_host:attach(sproto.new(helper.getprotobin("./proto/s2c.spt")))
end

function response.rawmessage(fd,msg,sz)
    local type,name,args, response = sp_host:dispatch(msg,sz)
    print('------------message-------------')
    print(type,name,args,response)
end

function response.message(type,name,msg,response)

end


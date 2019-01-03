local skynet = require("skynet")
local errcode = require("errorcode")

function init(...)
    skynet.error('------> start filter service')
end

function response.filter(addr)
    assert(addr)
    local ipaddr,port = string.match(addr,"(%d+%.%d+%.%d%.%d+):(%d+)")
    if ipaddr and port then
        skynet.error('----->client ip:',ipaddr , ' , port:',port)
        return errcode.code.SUCCESS
    else
        return errcode.code.ACCOUNTDISABLE
    end
end
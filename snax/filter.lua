local skynet = require("skynet")
local code = require("retcodes")

function init(...)
    skynet.error('------> start filter service')
end

function response.filter(addr)
    assert(addr)
    local ipaddr,port = string.match(addr,"(%d+%.%d+%.%d%.%d+):(%d+)")
    if ipaddr and port then
        skynet.error('----->client ip:',ipaddr , ' , port:',port)
        return code.codes.SUCC
    else
        return code.codes.FAILED
    end
end
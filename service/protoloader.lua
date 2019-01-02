local skynet = require "skynet"
local sprotoloader = require "sprotoloader"
local helper = require "helper"

skynet.start(function()
    sprotoloader.save( helper.getprotobin("./proto/c2s.spt") , 1)
    sprotoloader.save( helper.getprotobin("./proto/s2c.spt"), 2 )
end)
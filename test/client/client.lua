package.cpath = "./skynet/luaclib/?.so"
package.path = "./skynet/lualib/?.lua;" .. "./lualib/?.lua;"

if _VERSION ~= "Lua 5.3" then
    error "use Lua 5.3"
end

local socket = require "client.socket"
local sproto = require "sproto"
local helper = require "helper"
local session = 0

local host = sproto.new( helper.getprotobin("./proto/s2c.spt") ):host "package"
local request = host:attach(sproto.new( helper.getprotobin("./proto/c2s.spt")) )

local fd = assert(socket.connect("127.0.0.1",12288))

local function send_package(fd,pack)
    local package = string.pack(">s2",pack)
    socket.send(fd,package)
end

local function send_request(name,args)
    session = session + 1
    local str = request(name,args, session)
    send_package(fd,str)
end

send_request("helo",{msg="hello world"})
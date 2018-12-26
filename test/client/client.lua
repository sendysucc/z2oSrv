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

local last = ""

local function print_request(name, args)
	print("REQUEST", name)
	if args then
		for k,v in pairs(args) do
			print(k,v)
		end
	end
end

local function print_response(session, args)
	print("RESPONSE", session)
	if args then
		for k,v in pairs(args) do
			print(k,v)
		end
	end
end

local function print_package(t, ...)
	if t == "REQUEST" then
		print_request(...)
	else
		assert(t == "RESPONSE")
		print_response(...)
    end
end

local function unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

local function recv_package(last)
	local result
	result, last = unpack_package(last)
	if result then
		return result, last
	end
	local r = socket.recv(fd)
	if not r then
		return nil, last
	end
	if r == "" then
		error "Server closed"
	end
	return unpack_package(last .. r)
end

local function dispatch_package()
	while true do
		local v
		v, last = recv_package(last)
		if not v then
			break
		end

		print_package(host:dispatch(v))
	end
end

send_request("handshake")

while true do
    dispatch_package()
end
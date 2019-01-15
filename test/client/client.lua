package.cpath = "./skynet/luaclib/?.so"
package.path = "./skynet/lualib/?.lua;" .. "./lualib/?.lua;"

if _VERSION ~= "Lua 5.3" then
    error "use Lua 5.3"
end

local socket = require "client.socket"
local sproto = require "sproto"
local helper = require "helper"
local crypt = require "client.crypt"

local session = 0
local secret 

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
	
	if secret then
		str = crypt.base64encode( crypt.desencode(secret,str) )
	end

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
		if secret then
			v = crypt.desdecode(secret ,crypt.base64decode(v) )
		end
		local resType , name , args = host:dispatch(v)
		return args
	end
end

local function receive_data()
	local rets = nil
	while true do
		rets = dispatch_package()
		if rets then
			break
		end
	end
	return rets
end

send_request("handshake")

local rets = receive_data()
local challenge = crypt.base64decode(rets.challenge)


local clientkey = crypt.randomkey()

send_request("exeys",{ cye= crypt.base64encode( crypt.dhexchange(clientkey)) })

local rets = receive_data()
local serverkey = crypt.base64decode(rets.sye)
print('------->serverkey:', serverkey)

local tempsecret = crypt.dhsecret( serverkey, clientkey )

local hmac = crypt.hmac64(challenge,tempsecret)

send_request("exse", {cse = crypt.base64encode(hmac) })

local rets = receive_data()

if rets.ret == 0 then
	secret = tempsecret
end
print('-------->return : ', rets.ret)


send_request("verifycode",{agentcode = 10001})

local rets = receive_data()
print('---------verifycode -----------')
print(rets.ret)
print(rets.verifycode)

-- send_request("register",{ cellphone = "09566014786" , password="sendysucc", agentcode=10001 , verifycode = rets.verifycode ,agentcode = 1,promotecode = 1})
-- local rets = receive_data()
-- print('---------register -----------')
-- print(rets.ret)

send_request("register",{ cellphone = "09566014768" , password="sendysucc", agentcode=10001 , verifycode = rets.verifycode ,agentcode = 1,promotecode = 1})
local rets = receive_data()
print('---------register -----------')
print(rets.ret)

send_request("login", {cellphone="09566014768", password="sendysucc"})
local rets = receive_data()
print('--------- login -------------')
for k,v in pairs(rets) do
	print(k,v)
end

if rets.ret ~= 0 then
	print('------> login failed')
	os.exit()
end

send_request("gamelist")
local res = receive_data()
print('------------gamelist--------------')
for k,v in pairs(res.games) do
	print('----->',v.gameid, v.name)
	for _k,_v in pairs(v.rooms) do
		for p,q in pairs(_v) do
			print(p,q)
		end
	end
end

local _gameid = res.games[1].gameid
local _roomid = res.games[1].rooms[1].roomid

print('------>gameid:',_gameid, '--roomid:',_roomid)
send_request("match",{gameid = _gameid, roomid = _roomid })
local res = receive_data()

print('-=-->errcode:', res.errcode)
for k,v in pairs(res.players) do
	print('-----------------------')
	for _k,_v in pairs(v) do
		print(_k,_v)
	end
end




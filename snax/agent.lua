local skynet = require "skynet"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local sproto = require "sproto"
local helper = require "helper"
local snax = require "skynet.snax"

local fd = -1
local sp_host
local sp_request
local clientkey
local serverkey
local challenge
local secret 

local REQUEST = {}

local function send_package(pack)
	local package = string.pack(">s2", pack)
	socket.write(fd, package)
end

function REQUEST.handshake(type,args, response)
    challenge = crypt.randomkey()
    if response then
        send_package( response( {challenge = crypt.base64encode(challenge) }) )
    end
end

function REQUEST.exeys(type,args,response)
    clientkey = crypt.base64decode(args.cye)
    print('---------->clientkey:',clientkey)
    
    serverkey = crypt.randomkey()
    
    if response then
        send_package(response( {sye = crypt.base64encode( crypt.dhexchange( serverkey) )} ))
    end
end

function REQUEST.exse(type,args,response)
    local chmac = crypt.base64decode( args.cse )
    secret = crypt.dhsecret(clientkey, serverkey)

    local shmac = crypt.hmac64(challenge,secret)

    if chmac == shmac then
        if response then
            send_package( response({ret = 0}) )
        end
    else
        if response then
            send_package( response({ret = 1}) )
        end
    end
end

function init(...)
    fd = ...

    sp_host = sproto.new(helper.getprotobin("./proto/c2s.spt")):host("package")
    sp_request = sp_host:attach(sproto.new(helper.getprotobin("./proto/s2c.spt")))
end

function accept.rawmessage(fd,msg,sz)
    local type,name,args, response = sp_host:dispatch(msg,sz)
    local f = assert(REQUEST[name])
    f(type,args,response)
end

function accept.disconnect()
    snax.exit()
end
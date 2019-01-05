local skynet = require "skynet"
local socket = require "skynet.socket"
local crypt = require "skynet.crypt"
local sproto = require "sproto"
local helper = require "helper"
local snax = require "skynet.snax"
local sprotoloader = require "sprotoloader"
local errcode = require "errorcode"

local fd = -1
local sp_host
local sp_request
local clientkey
local serverkey
local challenge
local secret 

local req_verify_time = 0   --请求验证码的时间
local _vcode                --验证码
local REQUEST = {}

local function send_package(response,data)
    if not response then
        return 
    end
    local pack = response(data)
    if secret then
        pack =  crypt.base64encode(crypt.desencode(secret,pack))
    end
	local package = string.pack(">s2", pack)
	socket.write(fd, package)
end

local function genverifycode()
    return math.random(0,9) .. math.random(0,9) .. math.random(0,9) .. math.random(0,9)
end

function REQUEST.handshake(args, response)
    challenge = crypt.randomkey()
    send_package(response,{challenge = crypt.base64encode(challenge)})
end

function REQUEST.exeys(args,response)
    clientkey = crypt.base64decode(args.cye)
    serverkey = crypt.randomkey()
    send_package(response,{sye = crypt.base64encode( crypt.dhexchange( serverkey) )})
end

function REQUEST.exse(args,response)
    local chmac = crypt.base64decode( args.cse )
    local tempsecret = crypt.dhsecret(clientkey, serverkey)
    local shmac = crypt.hmac64(challenge,tempsecret)
    if chmac == shmac then
        send_package(response, { ret = errcode.code.SUCCESS } )
        secret = tempsecret
    else
        send_package(response, {ret = errcode.code.HANDSHAKEFAIL } )
    end
end

function REQUEST.verifycode(args,response)
    if req_verify_time > 0 and (skynet.now() - req_verify_time ) < 100 * 120 then
        send_package(response, { ret = errcode.code.TOOOFTEN })   --间隔时间太短,请120秒后在获取验证码
    else
        req_verify_time = skynet.now()
        _vcode = genverifycode()
        send_package(response, { ret = errcode.code.SUCCESS , verifycode = _vcode })
    end
end

function REQUEST.register(args,response)
    if args.verifycode ~= _vcode then
        send_package(response, { ret = errcode.code.VERIFYMISS })   --verifycode error
    else
        local obj = snax.queryservice("login")
        local retcode = errcode.code.OBJNOTEXISTS
        if obj then
            local ret = obj.req.register(args.cellphone, args.password, args.agentcode,args.promotecode)
            retcode = ret
        end
        send_package(response,{ret = retcode})
    end
end

function REQUEST.login(args,response)
    local obj = snax.queryservice("login")
    if obj then
        local ret = obj.req.login(args.cellphone, args.password, snax.self().handle)
        send_package(response,{ret = ret.errcode , cellphone = ret.cellphone, password = ret.password , userid = ret.userid, 
                                                    username = ret.username , nickname = ret.nickname, gold = ret.gold, diamond = ret.diamond, avatorid = ret.avatorid , gender = ret.gender })
    else
        send_package(response,{ret = errcode.code.OBJNOTEXISTS})
    end
end

function REQUEST.logout(userid)
    local obj = snax.queryservice("login")
    if obj then
        local ret = obj.req.logout(userid)
        
    end
end

function REQUEST.gamelist(args,response)
    local hobj = snax.queryservice("hall")
    if hobj then
        local gamelist = hobj.req.gamelist()
        send_package(response, gamelist)
    end
end

function REQUEST.joingame(args,response)
    local gmobj = snax.queryservice("gamemanager")
    if gmobj then
        local ret = gmobj.req.joingame(args.gameid, args.roomid)
    end
end

function init(...)
    fd = ...
    -- sp_host = sproto.new(helper.getprotobin("./proto/c2s.spt")):host("package")
    -- sp_request = sp_host:attach(sproto.new(helper.getprotobin("./proto/s2c.spt")))
    sp_host = sprotoloader.load(1):host "package"
    sp_request = sp_host:attach(sprotoloader.load(2))
end

function accept.rawmessage(fd,msg,sz)
    if secret then
        msg = crypt.desdecode(secret, crypt.base64decode(skynet.tostring(msg,sz)) )
    end

    local type,name,args, response = sp_host:dispatch(msg,sz)
    if type == 'REQUEST' then
        print('------>name: ' .. name)
        if name ~= 'handshake' and name ~= 'exeys' and name ~= 'exse' then
            if not secret then
                local handle = skynet.queryservice('gated')
                skynet.send(handle,'lua','kick',fd)
                snax.exit()
            end
        end

        local f = assert(REQUEST[name])
        f(args,response)
    else

    end
end

function accept.disconnect()
    local obj = snax.queryservice("playermanager")
    if obj then
        obj.post.breakline(snax.self().handle)
    end
    snax.exit()
end
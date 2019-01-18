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
local userid

local req_verify_time = 0   --请求验证码的时间
local _vcode                --验证码
local REQUEST = {}
local current_co 
local game_matched
local gaming_service        --正在玩的游戏服务对象

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
        send_package(response, { errcode = errcode.code.SUCCESS } )
        secret = tempsecret
    else
        send_package(response, {errcode = errcode.code.HANDSHAKEFAIL } )
    end
end

function REQUEST.verifycode(args,response)
    if req_verify_time > 0 and (skynet.now() - req_verify_time ) < 100 * 120 then
        send_package(response, { errcode = errcode.code.TOOOFTEN })   --间隔时间太短,请120秒后在获取验证码
    else
        req_verify_time = skynet.now()
        _vcode = genverifycode()
        send_package(response, { errcode = errcode.code.SUCCESS , verifycode = _vcode })
    end
end

function REQUEST.register(args,response)
    if args.verifycode ~= _vcode then
        send_package(response, { errcode = errcode.code.VERIFYMISS })   --verifycode error
    else
        local retcode = errcode.code.OBJNOTEXISTS
        local ret = snax.queryservice("login").req.register(args.cellphone, args.password, args.agentcode,args.promotecode)
        retcode = ret
        send_package(response,{errcode = retcode})
    end
end

function REQUEST.login(args,response)
    local ret = snax.queryservice("login").req.login(args.cellphone, args.password, snax.self().handle)
    send_package(response,{errcode = ret.errcode , cellphone = ret.cellphone, password = ret.password , userid = ret.userid, 
                                                    username = ret.username , nickname = ret.nickname, gold = ret.gold, diamond = ret.diamond, avatorid = ret.avatorid , gender = ret.gender })
    if ret.errcode == errcode.code.SUCCESS or ret.errcode == errcode.code.RECONNECT then
        userid = ret.userid
    end
end

function REQUEST.logout(userid,response)
    local ret = snax.queryservice("login").req.logout(userid)
    send_package(response,ret)
end

function REQUEST.gamelist(args,response)
    local gamelist = snax.queryservice("hall").req.gamelist()
    send_package(response, gamelist)
end

function REQUEST.match(args,response)
    -- 将加入游戏请求抛给 playermanager ,然后挂起当前协成, 等待收到匹配结果后,唤醒当前协成,并响应客户端的请求
    local matchedinfo = snax.queryservice('hall').req.match(userid,args.gameid,args.roomid)
    gaming_service = matchedinfo.gsrvobj
    matchedinfo.gsrvobj = nil
    --todo: response to client
    send_package(response, matchedinfo )    
end

function init(...)
    fd = ...
    sp_host = sprotoloader.load(1):host "package"
    sp_request = sp_host:attach(sprotoloader.load(2))
end

function accept.rawmessage(fd,msg,sz)
    if secret then
        msg = crypt.desdecode(secret, crypt.base64decode(skynet.tostring(msg,sz)) )
    end

    local type,name,args, response = sp_host:dispatch(msg,sz)
    print('---->protocol :' ,name)
    if type == 'REQUEST' then
        if name ~= 'handshake' and name ~= 'exeys' and name ~= 'exse' then
            if not secret then
                local handle = skynet.queryservice('gated')
                skynet.send(handle,'lua','kick',fd)
                snax.exit()
            end
        end
        local f = assert(REQUEST[name])
        if not f and gaming_service then
            
        else
            f(args,response)
        end
    else

    end
end

function accept.disconnect()
    snax.queryservice("playermanager").post.breakline(snax.self().handle)
    snax.exit()
end
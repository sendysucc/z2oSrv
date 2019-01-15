local skynet = require "skynet"
local snax = require "skynet.snax"
local mysql = require "skynet.db.mysql"
local errcode = require "errorcode"

local db

local function dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

local function escape(param)
    return mysql.quote_sql_str(param)
end

function init(...)
    local function on_connect(db) 
        db:query("set charset utf8")
        skynet.error('connect to database success !')
    end

    db = mysql.connect({
        host = "127.0.0.1",
        port = 3306,
        database = "z2osrv",
        user = "sendy",
        password = "sendy",
        max_packet_size = 1024*1024,
        on_connect = on_connect
    })

    if not db then
        snax.exit()
    end
end

function response.register(cellphone,password,agentcode,promotecode)
    local sql_str = string.format("call proc_register(%s,%s,%d,%s);", escape(cellphone), escape(password), agentcode , escape(promotecode) )
    local ret = db:query(sql_str)
    if ret.badresult then
        skynet.error('[db] register procedure errorno :' .. ret.errno .. ", code:" .. ret.sqlstate)
        return errcode.code.DBSYNTAXERROR
    else
        return (ret[1][1].errcode)
    end
end

function response.login(cellphone,password)
    local sql_str = string.format("call proc_login(%s,%s)", escape(cellphone), escape(password))
    local ret = db:query(sql_str)
    if ret.badresult then
        skynet.error('[db] login procedure errorno: ' .. ret.errno .. ', code:' .. ret.sqlstate)
        return { errcode = errcode.code.DBSYNTAXERROR }
    else
        local resp = ret[1][1]
        return resp
    end
end

function response.gamelist()
    local sql_str = 'select * from Game where enable = 1;'
    local ret = db:query(sql_str)

    if ret.badresult then
        skynet.error('[db] login procedure errorno: ' .. ret.errno .. ', code:' .. ret.sqlstate)
        return {errcode = errcode.code.DBSYNTAXERROR }
    else
        return ret
    end
end

function response.roomlist()
    local sql_str = 'select * from GameRoom;'
    local ret = db:query(sql_str)

    if ret.badresult then
        skynet.error('[db] login procedure errorno: ' .. ret.errno .. ', code:' .. ret.sqlstate)
        return {errcode = errcode.code.DBSYNTAXERROR }
    else
        return ret
    end
end

function response.loadrobots(startidx, count)
    local sql_str = string.format('call proc_loadrobots(%d,%d);',startidx,count)
    local ret = db:query(sql_str)
    if ret.badresult then
        skynet.error('[db] loadrobots errorno: ' .. ret.errno .. ', code:' .. ret.sqlstate)
        return {errcode = errcode.code.DBSYNTAXERROR}
    else
        return ret[1]
    end
end
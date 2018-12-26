local parser = require "sprotoparser"
local core = require "sproto.core"
local helper = {}

function helper.getprotobin(filename)
    local f = assert(io.open(filename), "can't open sproto file")
    local data = f:read "a"
    f:close()

    return parser.parse(data)
end

return helper
local skynet = require("skynet")

function init(...)
    print('-------->snax testservice init ')
end

function response.hello(msg)
    return 'service says : ' .. msg
end


local code = {
    SUCC = 0,
    FAILED = 1,
}

local reason = {
    [0] = "success",
    [1] = "failed",
    [2] = "forbidden ip address",
}

local codes = {

}

codes.codes = code
codes.msg = reason

return codes
local gameType = {
    GT_BR = 1,
    GT_BAT = 2,
}

local GameData = {
    [20001] = { gameid = 20001 , service = 'qznn' , gamename = '抢庄牛牛' , gameType = gameType.GT_BAT },
    [30001] = { gameid = 30001 , service = 'bjl' , gamename = '百家乐' , gameType = gameType.GT_BR },
}

return GameData
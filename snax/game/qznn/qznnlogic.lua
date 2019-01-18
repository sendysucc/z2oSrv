local logic = {}

logic.cardType = {
    N_NONE = 1,             --无牛
    N_ONE = 2,              --牛一
    N_TWO = 3,
    N_THREE = 4,
    N_FOUR = 5,
    N_FIVE = 6,
    N_SIX = 7,
    N_SEVEN = 8,
    N_EIGHT = 9,
    N_NINE = 10,
    N_TEN = 11,             --牛牛
    N_FOUR_FLOWER = 12,     --四花牛
    N_FIVE_FLOWER = 13,     --五花牛
    N_BOOM = 14,            --炸弹
    N_FIVE_SMALL = 15,      --五小牛
}

logic.odds = {
    [logic.cardType.N_NONE] = 1,
    [logic.cardType.N_ONE] = 1,
    [logic.cardType.N_TWO] = 1,
    [logic.cardType.N_THREE] = 1,
    [logic.cardType.N_FOUR] = 1,
    [logic.cardType.N_FIVE] = 1,
    [logic.cardType.N_SIX] = 1,
    [logic.cardType.N_SEVEN] = 2,
    [logic.cardType.N_EIGHT] = 2,
    [logic.cardType.N_NINE] = 2,
    [logic.cardType.N_TEN] = 3,
    [logic.cardType.N_FOUR_FLOWER] = 4,
    [logic.cardType.N_FIVE_FLOWER] = 4,
    [logic.cardType.N_BOOM] = 4,
    [logic.cardType.N_FIVE_SMALL] = 4,
}

logic.gamestatu = {
    START = 1,      --游戏开始
    GRAB = 2,       --抢庄
    BETTING = 3,    --下注
    SENDCARD = 4,   --发牌
    CALCARD = 5,    --拼牌
    PKCARD = 6,     --比牌
    SETTLE = 7,     --结算
}

logic.exptime = {
    [logic.gamestatu.START] = 1,
    [logic.gamestatu.GRAB] = 5,
    [logic.gamestatu.BETTING] = 5,
    [logic.gamestatu.SENDCARD] = 3,
    [logic.gamestatu.CALCARD] = 10,
    [logic.gamestatu.PKCARD] = 5,
    [logic.gamestatu.SETTLE] = 3,
}
print('----------> slkdjflajdlajk')
return logic
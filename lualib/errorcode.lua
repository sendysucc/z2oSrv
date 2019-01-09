local errors = {}

errors.code = {
    SUCCESS = 0,
    HANDSHAKEFAIL = 1,
    VERIFYMISS = 2,
    OBJNOTEXISTS = 3,
    DBSYNTAXERROR = 4,
    INVALIDPWD = 5,
    CELLPHONEREGISTED = 6,
    PASSWDERROR = 7,
    ACCOUNTNOTEXISTS = 8,
    ACCOUNTDISABLE = 9,
    TOOOFTEN = 10,
    ALREADLOGINED = 11,
    RECONNECT = 12,
    FAILED = 13,
    CANTQUITINNGAME = 14,
    ILLEGALREQUEST = 15,
    PLAYERNOTFOUND = 16,
}

errors.msg = {
    [errors.code.SUCCESS] = '操作成功',
    [errors.code.HANDSHAKEFAIL] = '握手失败',
    [errors.code.VERIFYMISS] = '验证码错误',
    [errors.code.OBJNOTEXISTS] = '对象不存在',
    [errors.code.DBSYNTAXERROR] = '数据库错误',
    [errors.code.INVALIDPWD] = '无效密码',
    [errors.code.CELLPHONEREGISTED] = '手机已被注册',
    [errors.code.PASSWDERROR] =  '密码不正确',
    [errors.code.ACCOUNTNOTEXISTS] = '账号不存在',
    [errors.code.ACCOUNTDISABLE] = '账户被禁用',
    [errors.code.TOOOFTEN] = '操作太频繁',
    [errors.code.ALREADLOGINED] = '已登录',
    [errors.code.RECONNECT] = '断线重连',
    [errors.code.FAILED] = '操作失败',
    [errors.code.CANTQUITINNGAME] = '正在游戏中无法退出',
    [errors.code.ILLEGALREQUEST] = '非法请求',
    [errors.code.PLAYERNOTFOUND] = '玩家不存在,或者不在线',
}

return errors
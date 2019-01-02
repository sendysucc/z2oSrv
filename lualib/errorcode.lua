local errors = {}

errors.errcode = {
    SUCCESS = 0,
    HANDSHAKEFAIL = 1,
    VERIFYMISS = 2,
    OBJNOTEXISTS = 3,
    DBSYNTAXERROR = 4,
    INVALIDPWD = 5,
    CELLPHONEREGISTED = 6,
    PASSWDERROR = 7,

}

errors.errmsg = {
    [errors.errcode.SUCCESS] = '成功',
    [errors.errcode.HANDSHAKEFAIL] = '握手失败',
    [errors.errcode.VERIFYMISS] = '验证码错误',
    [errors.errcode.OBJNOTEXISTS] = '对象不存在',
    [errors.errcode.DBSYNTAXERROR] = '数据库错误',
    [errors.errcode.INVALIDPWD] = '无效密码',
    [errors.errcode.CELLPHONEREGISTED] = '手机已被注册',
    [errors.errcode.PASSWDERROR] =  '密码不正确',
}


return errors
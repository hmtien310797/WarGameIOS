module("PPGameLogin", package.seeall)
local GUIMgr = Global.GGUIMgr
local ResourceLibrary = Global.GResourceLibrary
local TextMgr = Global.GTextMgr
local TableMgr = Global.GTableMgr
local GameObject = UnityEngine.GameObject
local GPlayerPrefs = UnityEngine.PlayerPrefs
local SetClickCallback = UIUtil.SetClickCallback
local WWW = UnityEngine.WWW

local _ui, wwwRequest

function Awake()
    _ui = {}
    _ui.header = PPGameLoginTool.GetFormHeaders()

    _ui.go = ResourceLibrary.GetUIInstance("Login/PPGameLogin")
    _ui.go.transform:SetParent(GUIMgr.UITopRoot, false)

    _ui.main = {}
    _ui.main.body = _ui.go.transform:Find("main").gameObject
    _ui.main.btn_account = _ui.go.transform:Find("main/btn_account").gameObject
    _ui.main.btn_tourists = _ui.go.transform:Find("main/btn_tourists").gameObject

    _ui.tourists = {}
    _ui.tourists.body = _ui.go.transform:Find("tourists").gameObject
    _ui.tourists.btn_cancel = _ui.go.transform:Find("tourists/btn_cancel").gameObject

    _ui.auto_login = {}
    _ui.auto_login.body = _ui.go.transform:Find("auto_login").gameObject
    _ui.auto_login.btn_cancel = _ui.go.transform:Find("auto_login/btn_cancel").gameObject

    _ui.account_login = {}
    _ui.account_login.body = _ui.go.transform:Find("account_login").gameObject
    _ui.account_login.btn_login = _ui.go.transform:Find("account_login/btn_login").gameObject
    _ui.account_login.label_account = _ui.go.transform:Find("account_login/account/Label_account"):GetComponent("UIInput")
    _ui.account_login.label_password = _ui.go.transform:Find("account_login/password/Label_password"):GetComponent("UIInput")
    _ui.account_login.btn_signin = _ui.go.transform:Find("account_login/signin").gameObject
    _ui.account_login.btn_forget = _ui.go.transform:Find("account_login/forget").gameObject
    _ui.account_login.btn_cancel = _ui.go.transform:Find("account_login/btn_cancel").gameObject

    _ui.signin_email = {}
    _ui.signin_email.body = _ui.go.transform:Find("signin_email").gameObject
    _ui.signin_email.btn_submit = _ui.go.transform:Find("signin_email/btn_submit").gameObject
    _ui.signin_email.label_account = _ui.go.transform:Find("signin_email/account/Label_email"):GetComponent("UIInput")
    _ui.signin_email.label_password = _ui.go.transform:Find("signin_email/password/Label_password"):GetComponent("UIInput")
    _ui.signin_email.btn_cancel = _ui.go.transform:Find("signin_email/btn_cancel").gameObject

    _ui.forget_email = {}
    _ui.forget_email.body = _ui.go.transform:Find("forget_email").gameObject
    _ui.forget_email.btn_submit = _ui.go.transform:Find("forget_email/btn_submit").gameObject
    _ui.forget_email.label_account = _ui.go.transform:Find("forget_email/account/Label_email"):GetComponent("UIInput")
    _ui.forget_email.label_password = _ui.go.transform:Find("forget_email/password/Label_password"):GetComponent("UIInput")
    _ui.forget_email.btn_cancel = _ui.go.transform:Find("forget_email/btn_cancel").gameObject

    if GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_tw_digiSky then
        _ui.app_id = "0002000300031004"--"0001000301031004"--
    elseif GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_kr_digiSky or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_kr_onestore then
        _ui.app_id = "0002000300051004"--"0001000301031004"--
    elseif GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_tw_digiSky then
        _ui.app_id = "0001000300031004"--"0001000301031004"--
    elseif GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_kr_digiSky then
        _ui.app_id = "0001000300051004"--"0001000301031004"--
    end
    _ui.url = "https://plat-all-oversea-all-login-0001.ppgame.com/"
    _ui.SendMessageToWSDK = function(func, param)
        GUIMgr.Instance.gameObject:SendMessage(func, param)
    end

    _ui.ShowError = function(code)
        MessageBox.Show(TextMgr:GetText("PPERROR_" .. code))
    end

    _ui.initReqData = function()
        local body = {}
        local extra = {}
        extra["app_id"] = ""
        extra["version"] = "1"
        body["openid"] = ""
        body["devid"] = ""
        body["app_id"] = ""
        body["network"] = ""
        body["idfa"] = ""
        body["currency_symbol"] = ""
        body["app_bundle_id"] = ""
        body["system_name"] = ""
        body["currency_code"] = ""
        body["resolution"] = ""
        body["app_build"] = ""
        body["wifi_bssid"] = ""
        body["wifi_ssid"] = ""
        body["idfv"] = ""
        body["ip"] = ""
        body["model"] = ""
        body["system_version"] = ""
        body["app_version"] = ""
        body["country"] = ""
        body["lanuage"] = ""
        body["device_name"] = ""
        return extra, body
    end

    _ui.makePostData = function(extra, body)
        return PPGameLoginTool.GetPostDatas(cjson.encode(extra), cjson.encode(body))
    end

    _ui.showTab = function(tab)
        _ui.curtab = tab
        _ui.main.body:SetActive(tab == 1)
        _ui.tourists.body:SetActive(tab == 2)
        _ui.account_login.body:SetActive(tab == 3)
        _ui.signin_email.body:SetActive(tab == 4)
        _ui.forget_email.body:SetActive(tab == 5)
        _ui.auto_login.body:SetActive(tab == 6)
        coroutine.stop(_ui.wwwCoroutine)
        _ui.wwwCoroutine = nil
    end

    _ui.getdevid = function()
        if _ui.devid == nil then
            _ui.devid = GPlayerPrefs.GetString("devid")
        end
        if _ui.devid == "" then
            local req = {}
            req.url = "gen_devid"
            local extra, body = _ui.initReqData()
            extra["app_id"] = _ui.app_id
            body["app_id"] = _ui.app_id
            req.data = _ui.makePostData(extra, body)
            req.callback = function(jtext)
                if _ui.curtab == 2 then
                    local jdata = cjsonSafe.decode(jtext) or nil
                    if jdata ~= nil then
                        if jdata["result"] == 0 then
                            _ui.devid = jdata["devid"]
                            GPlayerPrefs.SetString("devid", _ui.devid)
                            GPlayerPrefs.Save()
                            _ui.devid_login()
                        else
                            _ui.ShowError("wkywl")
                        end
                    else
                        _ui.ShowError("wkywl")
                    end
                end
            end
            wwwRequest(req)
        else
            _ui.devid_login()
        end
    end

    _ui.devid_login = function()
        local req = {}
        req.url = "devid_login"
        local extra, body = _ui.initReqData()
        extra["app_id"] = _ui.app_id
        body["app_id"] = _ui.app_id
        body["devid"] = _ui.devid
        body["openid"] = GPlayerPrefs.GetString("openid")
        req.data = _ui.makePostData(extra, body)
        req.callback = function(jtext)
            if _ui.curtab == 2 then
                local jdata = cjsonSafe.decode(jtext) or nil
                if jdata ~= nil then
                    if jdata["result"] == 0 then
                        print(jdata["openid"], jdata["access_token"])
                        GPlayerPrefs.SetString("openid", jdata["openid"])
                        GPlayerPrefs.Save()
                        local sdata = {}
                        sdata["code"] = "1"
                        sdata["uid"] = GPlayerPrefs.GetString("openid")
                        sdata["uname"] = GPlayerPrefs.GetString("openid")
                        sdata["session"] = jdata["access_token"]
                        sdata["logintype"] = "7"
                        _ui.SendMessageToWSDK("loginCallback", cjson.encode(sdata))
                        Close()
                    else
                        GPlayerPrefs.SetString("openid", "")
                        GPlayerPrefs.Save()
                        _ui.ShowError("wkywl")
                        _ui.showTab(1)
                    end
                else
                    _ui.ShowError("wkywl")
                end
            end
        end
        wwwRequest(req)
    end
    
    _ui.tourists_login = function()
        _ui.showTab(2)
        _ui.getdevid()
    end

    _ui.autoLogin = function()
        local access_token = GPlayerPrefs.GetString("access_token")
        if access_token ~= "" then
            _ui.showTab(6)
            local req = {}
            req.url = "auth"
            local extra, body = _ui.initReqData()
            extra["app_id"] = _ui.app_id
            body["app_id"] = _ui.app_id
            body["openid"] = GPlayerPrefs.GetString("openid")
            body["access_token"] = access_token
            req.data = _ui.makePostData(extra, body)
            req.callback = function(jtext)
                if _ui.curtab == 6 then
                    print(jtext)
                    local jdata = cjsonSafe.decode(jtext) or nil
                    if jdata ~= nil then
                        if jdata["result"] == 0 then
                            local sdata = {}
                            sdata["code"] = "1"
                            sdata["uid"] = GPlayerPrefs.GetString("openid")
                            sdata["uname"] = GPlayerPrefs.GetString("openid")
                            sdata["session"] = access_token
                            sdata["logintype"] = "7"
                            _ui.SendMessageToWSDK("loginCallback", cjson.encode(sdata))
                            Close()
                        else
                            GPlayerPrefs.SetString("access_token", "")
                            GPlayerPrefs.Save()
                            _ui.ShowError("sqgq")
                            _ui.showTab(3)
                        end
                    else
                        _ui.ShowError("wkywl")
                        _ui.showTab(3)
                    end
                end
            end
            wwwRequest(req)
        else
            _ui.showTab(3)
        end
    end

    _ui.normalLogin = function()
        local accountlength = #_ui.account_login.label_account.value
        local passwordlength = #_ui.account_login.label_password.value
        if accountlength == 0 or passwordlength == 0 then
            _ui.ShowError("zhmmbnwk")
            return
        elseif passwordlength < 6 or passwordlength > 18 then
            _ui.ShowError("yxdlmmcdbx")
            return
        end
        local req = {}
        req.url = "normal_login"
        local extra, body = _ui.initReqData()
        extra["app_id"] = _ui.app_id
        body["app_id"] = _ui.app_id
        body["openid"] = GPlayerPrefs.GetString("openid")
        body["login_identify"] = _ui.account_login.label_account.value
        body["login_pwd"] = GUIMgr:MD5_Encrypt(_ui.account_login.label_password.value)
        req.data = _ui.makePostData(extra, body)
        req.callback = function(jtext)
            if _ui.curtab == 6 then
                print(jtext)
                local jdata = cjsonSafe.decode(jtext) or nil
                if jdata ~= nil then
                    if jdata["result"] == 0 then
                        GPlayerPrefs.SetString("openid", jdata["openid"])
                        GPlayerPrefs.SetString("access_token", jdata["access_token"])
                        GPlayerPrefs.Save()
                        local sdata = {}
                        sdata["code"] = "1"
                        sdata["uid"] = jdata["openid"]
                        sdata["uname"] = jdata["openid"]
                        sdata["session"] = jdata["access_token"]
                        sdata["logintype"] = "7"
                        _ui.SendMessageToWSDK("loginCallback", cjson.encode(sdata))
                        Close()
                    else
                        if jdata["result"] == 60104 then
                            GPlayerPrefs.SetString("openid", "")
                            GPlayerPrefs.Save()
                            _ui.ShowError("wkywl")
                        end
                        if jdata["result"] == 60102 or jdata["result"] == 60108 then
                            _ui.ShowError("yxdzgscw")
                        end
                        if jdata["result"] == 60109 or jdata["result"] == 60113 then
                            _ui.ShowError("mmbd")
                        end
                        if jdata["result"] == 60114 then
                            _ui.ShowError("qjkdndyxwcjhbc")
                        end
                        _ui.showTab(3)
                    end
                else
                    _ui.ShowError("wkywl")
                end
            end
        end
        wwwRequest(req)
        _ui.showTab(6)
    end

    _ui.submitEmail = function()
        local accountlength = #_ui.signin_email.label_account.value
        local passwordlength = #_ui.signin_email.label_password.value
        if accountlength == 0 or passwordlength == 0 then
            _ui.ShowError("zhmmbnwk")
            return
        elseif passwordlength < 6 or passwordlength > 18 then
            _ui.ShowError("passwordlength")
            return
        end
        local req = {}
        req.url = "email_register"
        local extra, body = _ui.initReqData()
        extra["app_id"] = _ui.app_id
        body["app_id"] = _ui.app_id
        body["email"] = _ui.signin_email.label_account.value
        body["pwd"] = GUIMgr:MD5_Encrypt(_ui.signin_email.label_password.value)
        req.data = _ui.makePostData(extra, body)
        req.callback = function(jtext)
            GUIMgr:UnlockScreen()
            if _ui.curtab == 4 then
                local jdata = cjsonSafe.decode(jtext) or nil
                if jdata ~= nil then
                    if jdata["result"] == 0 then
                        _ui.showTab(3)
                        _ui.ShowError("qjkdndyxwcjhbc")
                        GPlayerPrefs.SetString("email", _ui.signin_email.label_account.value)
                        GPlayerPrefs.SetString("pwd", _ui.signin_email.label_password.value)
                        GPlayerPrefs.Save()
                        _ui.account_login.label_account.value = _ui.signin_email.label_account.value
                        _ui.account_login.label_password.value = _ui.signin_email.label_password.value
                    else
                        if jdata["result"] == 60402 then
                            _ui.ShowError("yxdzgscw")
                        end
                        if jdata["result"] == 60403 then
                            _ui.ShowError("emybsy")
                        end
                    end
                else
                    _ui.ShowError("wkywl")
                end
            end
        end
        wwwRequest(req)
        GUIMgr:LockScreen()
    end

    _ui.resetPassword = function()
        local accountlength = #_ui.forget_email.label_account.value
        local passwordlength = #_ui.forget_email.label_password.value
        if accountlength == 0 or passwordlength == 0 then
            _ui.ShowError("zhmmbnwk")
            return
        elseif passwordlength < 6 or passwordlength > 18 then
            _ui.ShowError("passwordlength")
            return
        end
        local req = {}
        req.url = "req_send_pwd_reset_email"
        local extra, body = _ui.initReqData()
        extra["app_id"] = _ui.app_id
        body["app_id"] = _ui.app_id
        body["email"] = _ui.forget_email.label_account.value
        body["pwd"] = GUIMgr:MD5_Encrypt(_ui.forget_email.label_password.value)
        req.data = _ui.makePostData(extra, body)
        req.callback = function(jtext)
            GUIMgr:UnlockScreen()
            if _ui.curtab == 5 then
                local jdata = cjsonSafe.decode(jtext) or nil
                if jdata ~= nil then
                    if jdata["result"] == 0 then
                        _ui.showTab(3)
                        _ui.ShowError("wmyxndzcyxzfslczyj")
                        GPlayerPrefs.SetString("email", _ui.forget_email.label_account.value)
                        GPlayerPrefs.SetString("pwd", _ui.forget_email.label_password.value)
                        GPlayerPrefs.Save()
                        _ui.account_login.label_account.value = _ui.forget_email.label_account.value
                        _ui.account_login.label_password.value = _ui.forget_email.label_password.value
                    end
                else
                    _ui.ShowError("wkywl")
                end
            end
        end
        wwwRequest(req)
        GUIMgr:LockScreen()
    end

    Start()
end

function Start()
    SetClickCallback(_ui.main.body, function() Close() login.ShowPPGame() end)
    SetClickCallback(_ui.tourists.btn_cancel, function() _ui.showTab(1) end)
    SetClickCallback(_ui.account_login.btn_cancel, function() _ui.showTab(1) end)
    SetClickCallback(_ui.account_login.btn_signin, function() _ui.showTab(4) end)
    SetClickCallback(_ui.account_login.btn_forget, function() _ui.showTab(5) end)
    SetClickCallback(_ui.signin_email.btn_cancel, function() _ui.showTab(3) end)
    SetClickCallback(_ui.forget_email.btn_cancel, function() _ui.showTab(3) end)
    SetClickCallback(_ui.auto_login.btn_cancel, function() _ui.showTab(3) end)

    SetClickCallback(_ui.main.btn_tourists, _ui.tourists_login)
    SetClickCallback(_ui.main.btn_account, _ui.autoLogin)
    SetClickCallback(_ui.account_login.btn_login, _ui.normalLogin)
    SetClickCallback(_ui.signin_email.btn_submit, _ui.submitEmail)
    SetClickCallback(_ui.forget_email.btn_submit, _ui.resetPassword)
    _ui.showTab(1)

    _ui.account_login.label_account.value = _ui.forget_email.label_account.value
    _ui.account_login.label_password.value = _ui.forget_email.label_password.value
end

function Show()
    if _ui == nil then
        Awake()
    end
end

function Close()
    coroutine.stop(_ui.wwwCoroutine)
    GameObject.Destroy(_ui.go)
    _ui = nil
end

wwwRequest = function(req)
    if _ui.wwwCoroutine ~= nil then
        return
    end
    _ui.wwwCoroutine = coroutine.start(function()
        wwwr = WWW(_ui.url .. req.url, req.data, _ui.header)
        Yield(wwwr)
        if wwwr.isDone then
            _ui.wwwCoroutine = nil
            req.callback(wwwr.text)
        end
    end)
end
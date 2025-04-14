module("login", package.seeall)
local GUIMgr = Global.GGUIMgr
local ResourceLibrary = Global.GResourceLibrary
local TextMgr = Global.GTextMgr
local TableMgr = Global.GTableMgr
local GameObject = UnityEngine.GameObject
local GPlayerPrefs = UnityEngine.PlayerPrefs

local _ui, ShowAccountList

local _notice
local _version

local _notShowAccount
local _accKey

function GetUID()
	return _accKey
end

function GetStatusTextColor(status)
    if status == LoginMsg_pb.ZONE_STATUS_FREE then
        return TextMgr:GetText(Text.ui_zone9), NGUIMath.HexToColor(0x08FF00FF)
    elseif status == LoginMsg_pb.ZONE_STATUS_FULL then
        return TextMgr:GetText(Text.ui_zone8), NGUIMath.HexToColor(0xFF0000FF)
    elseif status == LoginMsg_pb.ZONE_STATUS_MAINTAIN then
        return TextMgr:GetText(Text.ui_zone10), NGUIMath.HexToColor(0x707070FF)
    end
end
function StartNotice(notice, version)
	_notice = notice
	_version = version
	if _notice == "" then
		_ui.btnNotice:SetActive(false)
		return
	end
	local isfirst = false
	if tonumber(os.date("%d")) ~= GPlayerPrefs.GetInt("noticeday") then
		isfirst = true
		GPlayerPrefs.SetInt("noticeday",tonumber(os.date("%d")))
	    GPlayerPrefs.Save()
	end
	if GPlayerPrefs.GetInt("firstlogin") ~= -1 then
		isfirst = false
	end
	Notice.Show(notice, version, isfirst)
end

function ShowTip(_content)
	if _ui.loadingText == nil then
		Awake()
	end
    _ui.loadingText.text = _content
end

function SetProgress(_value)
	if _ui.sliderLoading == nil then
		Awake()
	end
	_ui.sliderLoading.gameObject:SetActive(true)
	_ui.sliderLoading.value = _value
	transform:Find("Container/bg_loading"):GetComponent("UISprite").enabled = true
end

local function RandomTips()
    local rtime = math.random(1,_ui.listLength)
    _ui.hintText.text = _ui.tipsTextList[rtime]
end

function SelectCountry(names)
	_ui.btn_service:SetActive(false)
	_ui.btnLogin:SetActive(false)
	_ui.bgTmgp.gameObject:SetActive(false)
	_ui.loginBg.gameObject:SetActive(false)
	_ui.root_right:SetActive(false)
	_ui.zoneBgObject:SetActive(false)
	_ui.areaRoot:SetActive(true)
	ShowTip("")
	transform:Find("Container/bg_loading"):GetComponent("UISprite").enabled = false
	_ui.sliderLoading.gameObject:SetActive(false)
	names = string.split(names, ";")
	_ui.areaLeftText.text = names[1]
	_ui.areaRightText.text = names[3]
	
	UIUtil.SetClickCallback(_ui.areaLeft, function()
		_ui.areaRoot:SetActive(false)
		_ui.backToArea:SetActive(true)
		Global.GGameStateLogin:SelectCounty(tonumber(names[2]))
	end)
	UIUtil.SetClickCallback(_ui.areaRight, function()
		_ui.areaRoot:SetActive(false)
		_ui.backToArea:SetActive(true)
		Global.GGameStateLogin:SelectCounty(tonumber(names[4]))
	end)
end

function ShowTmgp()
	 print("==================  ShowTmgp  ",GUIMgr:GetPlatformType())
	if GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_india then 
		ShowTip("")
		transform:Find("Container/bg_loading"):GetComponent("UISprite").enabled = false
		_ui.sliderLoading.gameObject:SetActive(false)
		if GPlayerPrefs.HasKey("logintype") then
			_ui.bgEfungp.gameObject:SetActive(false)
			_ui.btnLogin:SetActive(false)
			_notShowAccount = true
			coroutine.start(function()
				coroutine.step()
				Global.GGameStateLogin:SDKLogin(GPlayerPrefs.GetInt("logintype"))
			end)
			return
		end
		_ui.bgEfungp.gameObject:SetActive(true)
		_ui.btnLogin:SetActive(false)
		_notShowAccount = true
		_ui.efun_grid:Reposition()
	elseif GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_efun then 
		_ui.btn_efunlogin_efun.gameObject:SetActive(false)
		_ui.btn_efunlogin_gc.gameObject:SetActive(true)
		
		ShowTip("")
		transform:Find("Container/bg_loading"):GetComponent("UISprite").enabled = false
		_ui.sliderLoading.gameObject:SetActive(false)
		if GPlayerPrefs.HasKey("logintype") then
			_ui.bgEfungp.gameObject:SetActive(false)
			_ui.btnLogin:SetActive(false)
			_notShowAccount = true
			coroutine.start(function()
				coroutine.step()
				Global.GGameStateLogin:SDKLogin(GPlayerPrefs.GetInt("logintype"))
			end)
			return
		end
		_ui.bgEfungp.gameObject:SetActive(true)
		_ui.btnLogin:SetActive(false)
		_notShowAccount = true
		_ui.efun_grid:Reposition()
	else 
		ShowTip("")
		transform:Find("Container/bg_loading"):GetComponent("UISprite").enabled = false
		_ui.sliderLoading.gameObject:SetActive(false)
		if GPlayerPrefs.HasKey("logintype") then
			_ui.bgTmgp.gameObject:SetActive(false)
			_ui.btnLogin:SetActive(false)
			_notShowAccount = true
			coroutine.start(function()
				coroutine.step()
				Global.GGameStateLogin:SDKLogin(GPlayerPrefs.GetInt("logintype"))
			end)
			return
		end
		_ui.bgTmgp.gameObject:SetActive(true)
		_ui.btnLogin:SetActive(false)
		_notShowAccount = true
	end 
end

function NotShowAccount()
	ShowTip("")
	_notShowAccount = true
end

function ShowPPGame()
	ShowTip("")
	_notShowAccount = true
	ShowAccountList(nil, true)
end

function ShowGWX()--G平台微信
	ShowTip("")
	_notShowAccount = true
	_ui.gwx = ResourceLibrary.GetUIInstance("Login/GWXLogin")
	_ui.gwx.transform:SetParent(GUIMgr.UITopRoot, false)
	UIUtil.SetClickCallback(_ui.gwx.transform:Find("main/btn_login").gameObject, function()
		Global.GGameStateLogin:SDKLogin(2)
		GameObject.Destroy(_ui.gwx)
	end)
end

function ResetToStart()
	_ui.loadingText.gameObject:SetActive(true)
	_ui.sdkicon.gameObject:SetActive(false)
    _ui.sdktext.gameObject:SetActive(false)
    _ui.sdkbg:SetActive(false)
    _ui.bgsdk.gameObject:SetActive(false)
    _ui.btnLogin:SetActive(false)
    _ui.btnAccount:SetActive(false)
	_ui.bgTmgp.gameObject:SetActive(false)
	_ui.sliderLoading.gameObject:SetActive(false)
	transform:Find("Container/bg_loading"):GetComponent("UISprite").enabled = false
end

ShowAccountList = function(callback, issdk)
	if _ui.sa == nil or _ui.sa:Equals(nil) then
		_ui.sa = ResourceLibrary.GetUIInstance("setting/SelectAccount")
		NGUITools.SetLayer(_ui.sa.gameObject, gameObject.layer)
		_ui.sa.transform:SetParent(transform, false)
	end
	local close_sa = function(needshow)
		_ui.loginBg.gameObject:SetActive(false)
		if callback ~= nil then
			callback(needshow)
		end
	end
	if not issdk then
		UIUtil.SetClickCallback(_ui.sa.transform:Find("Container").gameObject, function() close_sa(true) GameObject.Destroy(_ui.sa) end)
		UIUtil.SetClickCallback(_ui.sa.transform:Find("Container/bg_frane/bg_top/btn_close").gameObject, function() close_sa(true) end)
	end
	local grid = _ui.sa.transform:Find("Container/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
	local btnitem = _ui.sa.transform:Find("btn_sdk")
	local createBtnItem = function(_texture, _bg, _name)
		local _item = GameObject.Instantiate(btnitem)
		_item.transform:SetParent(grid.transform, false)
		_item.transform:Find("Texture"):GetComponent("UITexture").mainTexture = _texture
		_item.transform:Find("text_sdk"):GetComponent("UILabel").text = _name
		if _bg ~= nil then
			_item:GetComponent("UITexture").mainTexture = _bg
		end
		return _item
	end
	
	for i, v in pairs(_ui.loginList) do
		print(i,ResourceLibrary.PATH_ICON .. "sdk/", v.bg,ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "sdk/", v.bg))
		UIUtil.SetClickCallback(createBtnItem(ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "sdk/", v.icon), ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "sdk/", v.bg), TextMgr:GetText(v.text)).gameObject, function()
			GameObject.Destroy(_ui.sa)
			v.callback(close_sa)
		end)
	end
	grid:Reposition()
end

local function ShowAccount(callback)
	if _notShowAccount == false then
		ShowAccountList(callback)
	else
		if callback then
			callback(true)
		end
		GPlayerPrefs.DeleteKey("logintype")
		GPlayerPrefs.Save()
		--GameStateLogin.Instance:StateChange2AccountLogin()
		Awake()
		GameStateLogin.Instance:SDKLogin(-1)
	end
end

local function InitLoginList()
	_ui.loginList = {}
	local logindata = TableMgr:GetLoginData(GUIMgr:GetPlatformType())
	local length = #logindata
	for i = 1, length do
		_ui.loginList[logindata[i].loginType] = {}
		_ui.loginList[logindata[i].loginType].platform = logindata[i].platformId
		_ui.loginList[logindata[i].loginType].logintype = logindata[i].loginType
		_ui.loginList[logindata[i].loginType].text = logindata[i].text
		_ui.loginList[logindata[i].loginType].icon = logindata[i].icon
		_ui.loginList[logindata[i].loginType].bg = logindata[i].bg
		if (UnityEngine.Application.isEditor and loginType == 0) or 
		((GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_self_adr or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_self_ios) and 
		(GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eDebug or GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eRelease)) then
			_ui.loginList[logindata[i].loginType].callback = function(cb)
				_ui.loginBg.gameObject:SetActive(true)
				UIUtil.SetClickCallback(_ui.loginButton.gameObject, function(go)
					_ui.sdktext.text = _ui.accKeyInput.value;
					cb();
					Global.GGameStateLogin:EditorLogin(0, _ui.zoneId, _ui.accKeyInput.value)
				end)
			end
		else
			_ui.loginList[logindata[i].loginType].callback = function() Global.GGameStateLogin:SDKLogin(logindata[i].loginType) end
		end
	end
end

function Awake()
	if _ui == nil then
		_ui = {}
	end
	InitLoginList()
	_ui.root_right = transform:Find("Container/root_right").gameObject
	if _ui.loginScene == nil then
		_ui.loginScene = ResourceLibrary:GetLoginInstance("LoginScene_01")
	end
	_ui.bgLoading = gameObject.Find("bg_loading")
	_ui.btnLogin = gameObject.Find("btn_login")
	_ui.btnAccount = transform:Find("Container/root_right/btn_account").gameObject
	_ui.bgTmgp = transform:Find("Container/bg_sdk_yyb")
	_ui.bgEfungp = transform:Find("Container/bg_sdk_efun/Grid")
	_ui.efun_grid = _ui.bgEfungp:GetComponent("UIGrid")
	_ui.efun_grid:Reposition()
	_ui.btn_login_qq = _ui.bgTmgp:Find("btn_login_qq")
	_ui.btn_login_wx = _ui.bgTmgp:Find("btn_login_wechat")
	_ui.btn_login_guest = _ui.bgTmgp:Find("btn_login_guest")
	
	_ui.btn_efunlogin_efun = _ui.bgEfungp:Find("btn_login_efun")
	_ui.btn_efunlogin_gc = _ui.bgEfungp:Find("btn_login_gc")
	_ui.btn_efunlogin_guest = _ui.bgEfungp:Find("btn_login_guest")
	_ui.btn_efunlogin_fb = _ui.bgEfungp:Find("btn_login_fb")
	
    _ui.sliderLoading = transform:Find("Container/bg_loading/loading"):GetComponent("UISlider")
    _ui.sliderLoading.value = 0
	_ui.loadingText = transform:Find("Container/bg_loading/Text"):GetComponent("UILabel")
    _ui.hintText = transform:Find("Container/text_hint"):GetComponent("UILabel")
    _ui.versionText = transform:Find("Container/version"):GetComponent("UILabel")
	_ui.bgsdk = transform:Find("Container/root_right/bg_sdk")
	_ui.sdkicon = _ui.bgsdk:Find("icon"):GetComponent("UITexture")
	_ui.sdktext = _ui.bgsdk:Find("text"):GetComponent("UILabel")
	_ui.sdkbg = _ui.bgsdk:Find("bg").gameObject
	_ui.btnlogout = _ui.bgsdk:Find("btn_logout").gameObject
	_ui.btn_service = transform:Find("Container/root_right/btn_service").gameObject
	_ui.btn_service:SetActive(false)
    _ui.tipsTextList = {}
    _ui.listLength = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.TipsTotalNum).value)
    for i = 1 , _ui.listLength do
        local text = TextMgr:GetText(string.format("tips_%d", i))
        _ui.tipsTextList[i] = text
	end
    RandomTips()
    _ui.timer = 0
	--_ui.bgLoading:SetActive(false)
	transform:Find("Container/bg_loading"):GetComponent("UISprite").enabled = false
	_ui.btnLogin:SetActive(false)
	_ui.bgTmgp.gameObject:SetActive(false)
    _ui.loginBg = transform:Find("Container/bg_account")
    _ui.accKeyInput = transform:Find("Container/bg_account/account_input"):GetComponent("UIInput")
    _ui.loginButton = transform:Find("Container/bg_account/btn_login")
    _ui.btnNotice = transform:Find("Container/root_right/btn_notice").gameObject
    _ui.btnRepair = transform:Find("Container/root_right/btn_repair").gameObject
	_ui.btnfacebook = transform:Find("Container/root_right/btn_fb").gameObject
	_ui.btnqq = transform:Find("Container/root_right/btn_qq").gameObject
    _ui.loginBg.gameObject:SetActive(false)
	_ui.root_right:SetActive(false)
	_ui.zoneBgObject = transform:Find("Container/bg_zone").gameObject
	_ui.zoneBgObject:SetActive(false)
	_ui.recommendObject = transform:Find("Container/bg_zone/icon_recommend").gameObject
	_ui.statusLabel = transform:Find("Container/bg_zone/text_state"):GetComponent("UILabel")
	_ui.countryLabel = transform:Find("Container/bg_zone/text_region"):GetComponent("UILabel")
	_ui.zoneLabel = transform:Find("Container/bg_zone/text_zone"):GetComponent("UILabel")
	_ui.chooseButton = transform:Find("Container/bg_zone/btn_choose"):GetComponent("UIButton")
	_ui.backToArea = transform:Find("Container/btn_close").gameObject
	_ui.areaRoot = transform:Find("Container/bg_area").gameObject
	_ui.areaLeft = transform:Find("Container/bg_area/btn_login_left").gameObject
	_ui.areaLeftText = transform:Find("Container/bg_area/btn_login_left/text_login"):GetComponent("UILabel")
	_ui.areaRight = transform:Find("Container/bg_area/btn_login_right").gameObject
	_ui.areaRightText = transform:Find("Container/bg_area/btn_login_right/text_login"):GetComponent("UILabel")
	
	_ui.backToArea:SetActive(false)
	_ui.areaRoot:SetActive(false)

	UIUtil.SetClickCallback(_ui.backToArea, function()
		_ui.backToArea:SetActive(false)
		Global.GGameStateLogin:ResetCountry()
	end)

	UIUtil.SetClickCallback(_ui.chooseButton.gameObject, function()
	    gameObject:SetActive(false)
	    ChooseZone.Show()
    end)
	
	_notShowAccount = false
	
	_ui.bgEfungp.gameObject:SetActive(false)
	
	UIUtil.SetClickCallback(_ui.btn_efunlogin_efun.gameObject, function(go)
        Global.GGameStateLogin:SDKLogin(2)	--eLogin_Wx
        _ui.btnLogin:SetActive(false)
		_ui.root_right:SetActive(false)
		_ui.bgTmgp.gameObject:SetActive(false)
		_ui.bgEfungp.gameObject:SetActive(false)
		_ui.loadingText.gameObject:SetActive(true)
    end)
	
	UIUtil.SetClickCallback(_ui.btn_efunlogin_gc.gameObject, function(go)
        Global.GGameStateLogin:SDKLogin(3)	--eLogin_gc
        _ui.btnLogin:SetActive(false)
		_ui.root_right:SetActive(false)
		_ui.bgTmgp.gameObject:SetActive(false)
		_ui.bgEfungp.gameObject:SetActive(false)
		_ui.loadingText.gameObject:SetActive(true)
    end)
	
	UIUtil.SetClickCallback(_ui.btn_efunlogin_fb.gameObject, function(go)
        Global.GGameStateLogin:SDKLogin(5)	--eLogin_fb
        _ui.btnLogin:SetActive(false)
		_ui.root_right:SetActive(false)
		_ui.bgTmgp.gameObject:SetActive(false)
		_ui.bgEfungp.gameObject:SetActive(false)
		_ui.loadingText.gameObject:SetActive(true)
    end)
	
	UIUtil.SetClickCallback(_ui.btn_efunlogin_guest.gameObject, function(go)
        Global.GGameStateLogin:SDKLogin(0)	--guest
		GPlayerPrefs.SetInt("logintype", 0)
		GPlayerPrefs.Save()
        _ui.btnLogin:SetActive(false)
		_ui.root_right:SetActive(false)
		_ui.bgTmgp.gameObject:SetActive(false)
		_ui.bgEfungp.gameObject:SetActive(false)
		_ui.loadingText.gameObject:SetActive(true)
    end)
	
    
	UIUtil.SetClickCallback(_ui.btn_login_qq.gameObject, function(go)
        Global.GGameStateLogin:SDKLogin(1)	--eLogin_QQ
        _ui.btnLogin:SetActive(false)
		_ui.root_right:SetActive(false)
		_ui.bgTmgp.gameObject:SetActive(false)
		_ui.loadingText.gameObject:SetActive(true)
    end)
	
	UIUtil.SetClickCallback(_ui.btn_login_wx.gameObject, function(go)
		Global.GGameStateLogin:SDKLogin((GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_official or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official_branch) and 11 or 2)	--eLogin_WX
		GPlayerPrefs.SetInt("logintype", (GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_official or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official_branch) and 11 or 2)
		GPlayerPrefs.Save()
        _ui.btnLogin:SetActive(false)
		_ui.root_right:SetActive(false)
		_ui.bgTmgp.gameObject:SetActive(false)
		_ui.loadingText.gameObject:SetActive(true)
	end)
	
	if GPlayerPrefs.GetInt("no_wexin",0) == 1 then 
		_ui.btn_login_wx.gameObject:SetActive(false)
	end 
	
	
	UIUtil.SetClickCallback(_ui.btn_login_guest.gameObject, function(go)
		Global.GGameStateLogin:SDKLogin(0)	--guest
		GPlayerPrefs.SetInt("logintype", 0)
		GPlayerPrefs.Save()
        _ui.btnLogin:SetActive(false)
		_ui.root_right:SetActive(false)
		_ui.bgTmgp.gameObject:SetActive(false)
		_ui.loadingText.gameObject:SetActive(true)
    end)
	
    UIUtil.SetClickCallback(_ui.btnLogin, function(go)
		local areaMsg = ServerListData.GetAreaData(_ui.zoneId)
		Global.SetLoginAreaMsg(areaMsg)
        Global.GGameStateLogin:Login(_ui.zoneId, _ui.charId, areaMsg:SerializeToString())
        _ui.zoneBgObject:SetActive(false)
        _ui.btnLogin:SetActive(false)
		_ui.root_right:SetActive(false)
		_ui.loadingText.gameObject:SetActive(true)
		_ui.backToArea:SetActive(false)
    end)
	
    UIUtil.SetClickCallback(_ui.btnAccount, function(go)
    	_ui.btnLogin:SetActive(false)
    	_ui.root_right:SetActive(false)
		ShowAccount(function(needshow)
			_ui.btnLogin:SetActive(true)
    		_ui.root_right:SetActive(needshow ~= nil and needshow)
    		_ui.bgsdk.gameObject:SetActive(false)
    		_ui.btnAccount:SetActive(true)
    	end)
    end)
    UIUtil.SetClickCallback(_ui.btnlogout, function(go)
    	_ui.btnLogin:SetActive(false)
    	_ui.root_right:SetActive(false)
		ShowAccount(function(needshow)
			_ui.btnLogin:SetActive(true)
    		_ui.root_right:SetActive(needshow ~= nil and needshow)
    		_ui.btnAccount:SetActive(false)
    		_ui.bgsdk.gameObject:SetActive(true)
    	end)
    end)
    Global.GAudioMgr:PlayMusic("MUSIC_login_background", 0.2, true, 1)
    
    UIUtil.SetClickCallback(_ui.btnNotice, function()
    	Notice.Show(_notice, _version)
    end)
    UIUtil.SetClickCallback(_ui.btnRepair, function()
    	Update_Repair.Show()
    end)
    UIUtil.SetClickCallback(_ui.btn_service, function()
    	UnityEngine.Application.OpenURL("http://www.baidu.com")
    end)
	UIUtil.SetClickCallback(_ui.btnfacebook, function()
		UnityEngine.Application.OpenURL("https://www.facebook.com/337868993310806/")
	end)
	UIUtil.SetClickCallback(_ui.btnqq, function()
		Global.GGUIMgr:SendDataReport("officialqq","EG6_gRglvG1W_87x8zy9CkJ16uJmAsqL")
		--MessageBox.Show("亲爱的指挥官，欢迎来到口袋战争！\n您是个军事迷？您喜欢战争和热血？亦或是您想当一个统帅三军的主将？\n即刻起您便可以在游戏中体验到运筹帷幄，攻城掠地的刺激和爽快！赶快加入吧！\n\n口袋战争国际版官方Q群:  280267168")
	end)
	local ischina = Global.IsIosMuzhi() or 
	GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_self_adr or
	GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_muzhi or 
	GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_opgame or
	GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official or
	GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_official or
	GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official_branch or
	GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_quick or
	GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_qihu
	_ui.btnfacebook:SetActive(not ischina)
	_ui.btnqq:SetActive(ischina and GUIMgr:GetPlatformType() ~= LoginMsg_pb.AccType_adr_quick and GUIMgr:GetPlatformType() ~= LoginMsg_pb.AccType_adr_qihu)
	if GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_mango then
		_ui.btnfacebook:SetActive(false)
	end
	EquipData.MakeBaseTable()
	HeroEquipData.MakeBaseTable()
	
	_ui.logo1 = transform:Find("Container/logo_efun").gameObject
	_ui.logo2 = transform:Find("Container/logo_tw").gameObject
	_ui.logo3 = transform:Find("Container/logo_kr").gameObject
	_ui.logo4 = transform:Find("Container/logo_mz").gameObject
	_ui.logo5 = transform:Find("Container/logo_mz_ios").gameObject
	local platformtype = 1
	if GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_muzhi or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_opgame or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_mango or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_official or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official_branch or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_quick or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_qihu then
		platformtype = 4
	elseif GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_efun or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_india or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_efun then
		platformtype = 1
	elseif GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_tw_digiSky or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_tw_digiSky then
		platformtype = 2
	elseif GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_kr_digiSky or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_kr_digiSky or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_kr_onestore then
		platformtype = 3
	elseif Global.IsIosMuzhi() then
		if GUIMgr:GetPlatformType() == 109 then 
			_ui.logo5:GetComponent("UISprite").spriteName = "logo_mz3"
		elseif GUIMgr:GetPlatformType() == 108 then
			_ui.logo5:GetComponent("UISprite").spriteName = "logo_mz2"
		end 
		platformtype = 5
	end
	_ui.logo1:SetActive(platformtype == 1)
	_ui.logo2:SetActive(platformtype == 2)
	_ui.logo3:SetActive(platformtype == 3)
	_ui.logo4:SetActive(platformtype == 4)
	_ui.logo5:SetActive(platformtype == 5)
end

function ShowVersion(version)
	_ui.versionText.text = version
end

function RequestServerList()
    ServerListData.RequestData(function()
        GameStateLogin.Instance:OnRequestServerList()
    end)
end

function SetZoneInfo(countryName, isNew, zoneStatus, zoneId, zoneName)
    _ui.countryLabel.text = TextMgr:GetText(countryName)
	_ui.recommendObject:SetActive(isNew)
	local text, color = GetStatusTextColor(zoneStatus)
	_ui.statusLabel.text = text
	_ui.statusLabel.color = color
	_ui.zoneLabel.text = zoneName
	_ui.countryName = countryName
	_ui.zoneName = zoneName
    _ui.zoneId = zoneId
    _ui.charId = 0
    local myZoneMsg = ServerListData.GetMyZoneData(zoneId)
    if myZoneMsg ~= nil then
        _ui.charId = myZoneMsg.charinfo.charid
    end
end

function ShowLogin(zoneId, accKey, loginType, accountName)
	_accKey = accKey
    local countryMsg, _, zoneGameMsg = ServerListData.GetCountryZoneData(zoneId)
    local zoneMsg = ServerListData.GetAllZoneData(zoneId)
	SetZoneInfo(countryMsg.name, zoneMsg.isNew, zoneMsg.status, zoneMsg.zoneId, zoneMsg.zoneName)
    if not ServerListData.IsAppleReviewing() then
        _ui.zoneBgObject:SetActive(true)
	end
	if GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official or
		GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official_branch or
		GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_official then
		_ui.backToArea:SetActive(true)
	end
	_ui.loadingText.gameObject:SetActive(false)
	_ui.root_right:SetActive(true)
	if (UnityEngine.Application.isEditor and loginType == 0) or 
	((GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_self_adr or GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_self_ios) and 
	(GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eDebug or GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eRelease)) then
    	if System.String.IsNullOrEmpty(_ui.accKeyInput.value) then
    		_ui.accKeyInput.value = accKey
    	end
    else
	    _ui.accKeyInput.value = accKey
	end
	if _ui.loginList[loginType] ~= nil and _ui.loginList[loginType].icon ~= nil then
		_ui.sdkicon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "sdk/", _ui.loginList[loginType].icon)
	end
    if _ui.accKeyInput.value ~= "" then
    	if loginType == 0 or loginType == 10 then
    		_ui.sdktext.text = ""
    		_ui.sdkicon.gameObject:SetActive(false)
    		_ui.sdktext.gameObject:SetActive(false)
    		_ui.sdkbg:SetActive(false)
    	else
    		_ui.sdkicon.gameObject:SetActive(true)
    		_ui.sdktext.gameObject:SetActive(true)
    		_ui.sdkbg:SetActive(true)
    		_ui.sdktext.text = accountName
    	end
    	_ui.bgsdk.gameObject:SetActive(true)
    	if GameObject.Find("Notice") == nil then
    		_ui.btnLogin:SetActive(true)
    	end
    else
    	_ui.btnAccount:SetActive(true)
    end
    if _ui.sa ~= nil then
    	GameObject.Destroy(_ui.sa)
	end
	
	if GPlayerPrefs.GetInt("firstlogin") ~= -1 and GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eDist then
		_ui.zoneBgObject:SetActive(false)
		_ui.root_right:SetActive(false)
		coroutine.start(function()
			coroutine.step()
			_ui.btnLogin:SendMessage("OnClick")
		end)
	end
end

function Update()
    _ui.timer = _ui.timer + Time.deltaTime
    if _ui.timer>3 then
        _ui.timer = _ui.timer - 3
        RandomTips()
    end
end

function RequestData()
	SendLanguage()
	MainData.RequestData()    
	BuffData.RequestData()
	Laboratory.ReqTechInfo()
	Barrack.RequestBarrackInfo()
	MainData.RequestLoginCount()
	CountListData.RequestData()
	TeamData.RequestData()
	TeamData.RequestDefentArmyData()
	TeamData.RequestArmyInjuredData()
	ItemListData.RequestData()
	UnlockArmyData.RequestData()	
	MailListData.RequestAllData()
	ChestListData.RequestData()
	MissionListData.RequestData()
	ConfigData.Initialize()
	WelfareData.RequestGrowGoldData()
	MapInfoData.RequestData()
	ActionListData.RequestData()
	BuildingData.RequestData()
	RadarData.RequestData()
	FunctionListData.RequestListData()
	UnionInfoData.RequestData()
	UnionInfoData.RequestOccupyFieldInfo(1,true)
	UnionHelpData.RequestData()
	SelfApplyData.RequestData()
	UnionApplyData.RequestData()
	UnionBuildingData.RequestData()
	RebelData.RequestActivityInfo()
	TalentInfoData.RequestData()
	UnionTechData.RequestData()
	UnionDonateData.RequestData()
	PveMonsterData.RequestData()
	VipData.Initialize()
	MilitaryActionData.RequestData()
	ActiveStaticsData.RequestActiveStaticsInfo()
    RebelWantedData.RequestData()
	NotifyInfoData.RequestNotifyTypeInfo()
	RaceData.RequestData(true)
	ActivityTreasureData.RequestData(true)
	ExchangeTableData.RequestData()
	ActivityExchangeData.RequestData()
	NotifySettingData.RequestData()
	NotifySettingData.RequestNoticeLanguage(tonumber(Global.GTextMgr:GetCurrentLanguageID()))
	GovernmentData.ReqGoveInfoData()
	StrongholdData.ReqAllStrongholdInfoData()
	FortressData.ReqAllFortressInfoData()
	UnionCityData.Initialize()
	JailInfoData.RequestData()
	GiftPackData.Initialize()
	GameFunctionSwitchData.RequestData()
    UnionResourceRequestData.RequestData()
    WarLossData.RequestData()
    DefenseData.RequestData()
    ArenaInfoData.RequestData()
	Barrack_SoldierEquipData.RequestArmyEnhanceInfo()
	ActiveSlaughterData.ReqMsgSlaughterGetInfo()
	MobaData.RequestMobaMatchInfo()
	ActivityLevelRaceData.RequestData()
    RuneData.RequestRuneChestPanel()
    MilitaryRankData.RequestData()
	WorldCityData.RequestData()
	FaceDrawData.RequestData()
	
	for i=1,4 do
		GovernmentData.ReqTurretInfoData(i)
	end
	
	
	if SevenDayData.GetData() == nil then
		SevenDayData.RequestData()
	end
	if ThirtyDayData.GetData() == nil then
		ThirtyDayData.RequestData()
	end
	-- if MonthCardData.GetData() == nil then
	-- 	MonthCardData.RequestData()
	-- end
	if Welfare_Template1Data.GetData() == nil then
		Welfare_Template1Data.RequestData()
	end

	WelfareData.RequestTriggerBagList()

	FunctionListData.IsFunctionUnlocked(130, function(isactive)
		if isactive then
			--RebelSurroundData.RequestData()
			RebelSurroundNewData.RequestNemesisInfo()
		end
	end)
	TragetViewData.RequestListTraget(function()
	    print("TragetViewData !!!!!!!!!!!!!!!!!")
	end)
	if not UnionInfoData.HasUnion() then
	    local mt = MassTroops()
	    mt:RequsetMassTotalNum(function(count1,count2) 
	    MainCityUI.MassTotlaNum[1] = count1
        MainCityUI.MassTotlaNum[2] = count2
		MainCityUI.PreMassTotalNum[1] = count1
		MainCityUI.PreMassTotalNum[2] = count2
		
	    print("12122222222222222222222222MassTotlaNum ",MainCityUI.MassTotlaNum[1],MainCityUI.MassTotlaNum[2])
	    end)
	end
end

function HasFinishedTeachBattle()
    if ServerListData.IsAppleReviewing() then
        return true
    end

	if ConfigData.GetGameStateTutorial() == true then
		return true
	else
		return false
	end
end

function PreloadGameResource()
	GPlayerPrefs.SetInt("firstlogin", -1)
	GPlayerPrefs.Save()
	SetProgress(1)
	GUIMgr:SubmitRoleInfo(MainData.GetCharName(), MainData.GetLevel(), true)
	GUIMgr:SendDataReport("muzhi","0")
	Tutorial.Init()
	SceneStory.Init()
	if HasFinishedTeachBattle() then
		print(MoneyListData.GetDiamond())
		GUIMgr:SendDataReport("mango", "1")
		Global.OpenUI(MainCityUI)
	end
end

function StartTeachBattle()
	GPlayerPrefs.SetInt("firstlogin", -1)
	GPlayerPrefs.Save()
	GUIMgr:SendDataReport("mango", "0")
	Main.Instance:ChangeGameState(GameStateTutorial.Instance, "",nil)
	-- SetProgress(1)
    -- local teamType = Common_pb.BattleTeamType_Main
    -- TeamData.UnselectAllHero(teamType)
    -- TeamData.UnselectAllArmy(teamType)
    -- TeamData.SelectMaxLevelArmyByType(teamType, 1)
    -- SelectArmy.StartPVEBattle(90001, Common_pb.BattleTeamType_Main)
end

function Close()	
	UnityEngine.GameObject.Destroy(_ui.loginScene)
    _ui = nil
	_notice = nil
	_version = nil
end

function ShowLoginBtn()
	_ui.btnLogin.gameObject:SetActive(true)
end

function HideLoginBtn()
	_ui.btnLogin.gameObject:SetActive(false)
end

function SendLanguage()
	local req = ClientMsg_pb.MsgSetUserLangRequest()
	req.lang = TextMgr:GetCurrentLanguageID()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgSetUserLangRequest, req, ClientMsg_pb.MsgSetUserLangResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then

        end
    end, true)
end

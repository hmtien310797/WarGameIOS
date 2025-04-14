module("account", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local _grid
local _scroll
local loginList
local exceptList
local sa

local function CloseClickCallback(go)
    Hide()
end

function logout()
    GameStateLogin.Instance:SettingAccountLogout(tostring(TextMgr.currentLanguage))
	UICamera.onClick = nil;

	UICamera.onDoubleClick = nil;
	UICamera.onHover = nil;
	UICamera.onPress = nil;
	UICamera.onSelect = nil;
	UICamera.onScroll = nil;
	UICamera.onDrag = nil;
	UICamera.onDragStart = nil;
	UICamera.onDragOver = nil;
	UICamera.onDragOut = nil;
	UICamera.onDragEnd = nil;
	UICamera.onDrop = nil;
	UICamera.onKey = nil;
	UICamera.onNavigate = nil;
	UICamera.onPan = nil;
	UICamera.onTooltip = nil;
	UICamera.onMouseMove = nil;

	UICamera.onClick = nil;

	
	--[[
        local req = ClientMsg_pb.MsgGMCommandRequest()
        req.command = "KickUser id="..MainData.GetCharId()
        print(req.command)
        Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGMCommandRequest, req, ClientMsg_pb.MsgGMCommandResponse, function(msg)
            if msg.code ~= ReturnCode_pb.Code_OK then
                MessageBox.Show(msg.result)
            else
            	Global.ShowError(msg.code)
            end
        end, true)   
        ]]--
end

function GetAccountBindListRequest(callback)
	local req = ClientMsg_pb.MsgGetAccountBindListRequest()
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetAccountBindListRequest, req, ClientMsg_pb.MsgGetAccountBindListResponse, function(msg)
        if msg.code == 0 then
            callback(msg.bindkey)
        else
        	Global.ShowError(msg.code)
        end
    end, false)   
end

local function CreateItem()
	local item = {}
	item.go = GameObject.Instantiate(transform:Find("item"))
	item.go.transform:SetParent(_grid.transform, false)
	item.acctypeName = item.go.transform:Find("name"):GetComponent("UILabel")
	item.accIdName = item.go.transform:Find("name_text"):GetComponent("UILabel")
	item.icon = item.go.transform:Find("Texture"):GetComponent("UITexture")
	return item
end

local function RefreshAccountList()
	GetAccountBindListRequest(function(bindkey)
		bindedList = bindkey
		local count = _grid.transform.childCount
		for n = 0, count - 1 do
			GameObject.Destroy(_grid.transform:GetChild(n).gameObject)
		end
		exceptList = {}
		for i, v in pairs(loginList) do
			local temp
			for j, k in ipairs(bindkey) do
				print("binding", k.acctype, i)
				if k.acctype == i then
					temp = k
				end
			end
			local item = CreateItem()
			item.acctypeName.text = TextMgr:GetText(v.text)
			item.icon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "sdk/", v.icon)
			if temp ~= nil then
				item.accIdName.text = temp.accname
				exceptList[#exceptList + 1] = temp
			else
				item.accIdName.text = TextMgr:GetText("setting_ui20")
			end
		end
		_grid:Reposition()
	end)
end

local function CallBind(logintype)

	local accounttext = TextMgr:GetText(loginList[logintype].text)
	MessageBox.Show(System.String.Format(TextMgr:GetText("login_ui11"), accounttext), 
		function()
			Global.GGameStateLogin:SDKBind(logintype, function(code, acctype, acckey, acctoken, accname, packageName, deviceid, publickeyurl, salt, signature, timestamp)
				if code == 1 then
					local req = ClientMsg_pb.MsgLogin3PartyAccountRequest()
					req.bindAccType = acctype
					req.bindAccKey = acckey
					req.bindAccToken = acctoken
					req.accUserName = accname
					req.package = packageName
					req.deviceid = deviceid
					req.publicKeyUrl = publickeyurl
					req.salt = salt
					req.signature = signature
					req.timestamp = timestamp
					Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgLogin3PartyAccountRequest, req, ClientMsg_pb.MsgLogin3PartyAccountResponse, function(msg)
			            if msg.code == 0 then
			                if msg.needBind then
			                	local req2 = ClientMsg_pb.MsgLoginBindAccountRequest()
			                	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgLoginBindAccountRequest, req2, ClientMsg_pb.MsgLoginBindAccountResponse, function(msg)
			                		if msg.code == 0 then
			                			MessageBox.Show(System.String.Format(TextMgr:GetText("setting_ui19"), accounttext))
										RefreshAccountList()
			                		else
			                			Global.ShowError(msg.code)
			                		end
			                	end, false)
			                else
			                	MessageBox.Show(System.String.Format(TextMgr:GetText("setting_ui18"), accounttext))
			                end
			            else
			            	Global.ShowError(msg.code)
			            end
			        end, false)  
			    else
			    	MessageBox.Show(System.String.Format(TextMgr:GetText("setting_ui17"), accounttext)) 
			    end
			end)
		end, function() end, TextMgr:GetText("common_hint1"), TextMgr:GetText("common_hint2"))
end

local function InitLoginList()
	loginList = {}
	local logindata = TableMgr:GetLoginData(GUIMgr:GetPlatformType())
	for i , v in pairs(logindata) do
		if logindata[i].loginType ~= 0 then
			loginList[logindata[i].loginType] = {}
			loginList[logindata[i].loginType].platform = logindata[i].platformId
			loginList[logindata[i].loginType].logintype = logindata[i].loginType
			loginList[logindata[i].loginType].text = logindata[i].text
			loginList[logindata[i].loginType].icon = logindata[i].icon
			loginList[logindata[i].loginType].callback = function() CallBind(logindata[i].loginType) end
		end
	end
	--[[local length = logindata.Length
	for i = 0, length - 1 do
		if logindata[i].loginType ~= 0 then
			loginList[logindata[i].loginType] = {}
			loginList[logindata[i].loginType].platform = logindata[i].platformId
			loginList[logindata[i].loginType].logintype = logindata[i].loginType
			loginList[logindata[i].loginType].text = logindata[i].text
			loginList[logindata[i].loginType].icon = logindata[i].icon
			loginList[logindata[i].loginType].callback = function() CallBind(logindata[i].loginType) end
		end
	end]]
end

local function ShowAccount(callback)
	if sa == nil or sa:Equals(nil) then
		sa = ResourceLibrary.GetUIInstance("setting/relateaccount")
		NGUITools.SetLayer(sa.gameObject, gameObject.layer)
		sa.transform:SetParent(transform, false)
	end
	local close_sa = function()
		if callback ~= nil then
			callback()
		end
	end
	UIUtil.SetClickCallback(sa.transform:Find("account").gameObject, function() close_sa() GameObject.Destroy(sa) end)
	UIUtil.SetClickCallback(sa.transform:Find("account/bg_frane/bg_top/btn_close").gameObject, function() close_sa() GameObject.Destroy(sa) end)
	local grid = sa.transform:Find("account/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
	local btnitem = sa.transform:Find("btn_bangding")
	local createBtnItem = function(_texture, _name, logintype)
		local _item = GameObject.Instantiate(btnitem)
		_item.transform:SetParent(grid.transform, false)
		_item.transform:Find("Texture"):GetComponent("UITexture").mainTexture = _texture
		_item.transform:Find("text"):GetComponent("UILabel").text = _name
		_item.name = logintype
		return _item
	end
	
	for i, v in pairs(loginList) do
		if i > 0 then
			local canshow = true
			for j, k in pairs(exceptList) do
				if k.logintype == i then
					canshow = false
				end
			end
			if canshow then
				UIUtil.SetClickCallback(createBtnItem(ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "sdk/", v.icon), TextMgr:GetText(v.text), v.logintype).gameObject, function()
					GameObject.Destroy(sa)
					v.callback(close_sa)
				end)
			end
		end
	end
	coroutine.start(function()
        coroutine.step()
		grid:Reposition()
	end)
	NGUITools.AdjustDepth(sa, 1000)
end

local function LoadUI()
    local btn = transform:Find("account/bg_frane/bg_top/btn_close")
    SetClickCallback(btn.gameObject,CloseClickCallback)
    SetClickCallback(transform:Find("account").gameObject, CloseClickCallback)
    local name = transform:Find("account/bg_frane/bg_msg/bg_name/name_text"):GetComponent("UILabel")
    name.text = MainData.GetCharName()
    local id = transform:Find("account/bg_frane/bg_msg/bg_ID/name_text"):GetComponent("UILabel")
    id.text = MainData.GetCharId()
    local fright = transform:Find("account/bg_frane/bg_msg/bg_power/num"):GetComponent("UILabel")
    fright.text = MainData.GetFight()
    local icon = transform:Find("account/bg_frane/bg_msg/bg_touxiang/icon_touxiang"):GetComponent("UITexture")
    icon.mainTexture = ResourceLibrary:GetIcon("Icon/head/",MainData.GetFace())
    local lv = transform:Find("account/bg_frane/bg_msg/bg_touxiang/level"):GetComponent("UILabel")
    lv.text = "LV. "..MainData.GetLevel()
    local logout_btn  = transform:Find("account/bg_frane/btn")
    local relate_btn = transform:Find("account/bg_frane/btn_relate")
    _scroll = transform:Find("account/bg_frane/bg_msg/Scroll View"):GetComponent("UIScrollView")
    _grid = _scroll.transform:Find("Grid"):GetComponent("UIGrid")
    SetClickCallback(logout_btn.gameObject,logout) 
    SetClickCallback(relate_btn.gameObject, function()
    	ShowAccount()
    end)
	local platformType = GUIMgr:GetPlatformType()
	if UnityEngine.Application.isEditor then
		platformType = LoginMsg_pb.AccType_adr_tmgp
	end
	if platformType == LoginMsg_pb.AccType_adr_tmgp then
		relate_btn.gameObject:SetActive(false)
	end
	if platformType == LoginMsg_pb.AccType_adr_official or 
		platformType == LoginMsg_pb.AccType_ios_official or 
		platformType == LoginMsg_pb.AccType_ios_efun or 
		platformType == LoginMsg_pb.AccType_ios_india or 
		platformType == LoginMsg_pb.AccType_adr_official_branch or 
		platformType == LoginMsg_pb.AccType_adr_efun then
		relate_btn.gameObject:SetActive(true)
		logout_btn.localPosition = Vector3(110, -120, 0)
	end
end

function Hide()
     _grid = nil
    _scroll = nil 
    loginList = nil 
    exceptList = nil 
    sa = nil    
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end


function Awake()

end


function Show()
    heroUid = uid
    Global.OpenUI(_M)
    LoadUI()
    InitLoginList()
    RefreshAccountList()
end

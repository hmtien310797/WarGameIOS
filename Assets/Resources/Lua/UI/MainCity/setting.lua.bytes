module("setting", package.seeall)

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
local serverTimeMsg
local serverTimeSec

local SettingData

local SettingDataMap

local SettingUI

local CurID

local secInput
local secInputKey = "#999#"

EnableIndex = nil
local isLogin = nil

local function CheckSwitch(setting)
	if setting.id == 10 and not GameFunctionSwitchData.Switch(GameFunctionSwitchData.GFSwitch.GFSwitch_CDKey) then
		return false
	end 
	
	return true
end

local function LoadData()
    if SettingData ~= nil then
        return 
    end
    SettingData = {}
    SettingDataMap = {}
	local setting_table = TableMgr:GetSettingTable()
	for _ , v in pairs(setting_table) do
		local data = v
	    SettingDataMap[data.id] = data
        if SettingData[data.ParentID] == nil then
            SettingData[data.ParentID] = {}
        end
		if CheckSwitch(data) then
			table.insert(SettingData[data.ParentID],data)
		end
		
	end
	
	--[[local iter = setting_table:GetEnumerator()
	while iter:MoveNext() do
	    local data = iter.Current.Value
	    SettingDataMap[data.id] = data
        if SettingData[data.ParentID] == nil then
            SettingData[data.ParentID] = {}
        end
        table.insert(SettingData[data.ParentID],data)
    end]]
end

local function ClearInfoList()
    for i = 1,#(SettingUI.InfoList) do
        SettingUI.InfoList[i]:SetActive(false)
        SettingUI.InfoList[i].transform.parent = nil
        GameObject.Destroy(SettingUI.InfoList[i])
    end
    SettingUI.InfoList = {}
end

local function ShowSetting(id)
    SettingArr = nil
    local settings = SettingData[id]
    if settings == nil then
        local data =  SettingDataMap[id]
        if data ~= nil then
            print("Exe :", data.CMD)
			--GUIMgr:CreateMenu("feedback" , false)
			
            local f =  Global.GetTableFunction("GMCommand."..data.CMD)
            if f ~= nil then
                f()
            end
        end
        return 
    end
    local data =  SettingDataMap[id]
    if data ~= nil then
        print("Exe :", data.CMD)
        local f =  Global.GetTableFunction("GMCommand."..data.CMD)
        if f ~= nil then
            f()
        end
    end    
    ClearInfoList()
    CurID = id
    local data =  SettingDataMap[CurID]
    if data ~= nil then
        SettingUI.Title.text = TextMgr:GetText(data.Des)
    else
        SettingUI.Title.text = TextMgr:GetText("setting_ui1") --设置"
    end

    table.foreach(settings,function(i,v)
		local add = true
        if Global.GetMobaMode() == 2 and v.id==12 then 
			add = false
		end 
		if add then
			local obj = NGUITools.AddChild(SettingUI.Grid.gameObject, SettingUI.SettingInfo)
			obj.name = v.id
			obj:SetActive(true)
			local childLabel = obj.transform:Find("name"):GetComponent("UILabel")
			local childIcon = obj.transform:Find("Texture"):GetComponent("UITexture")
			local childIcon_Enable = obj.transform:Find("Texture/select")
			local childbg =  obj.transform:Find("bg"):GetComponent("UISprite")
			childLabel.text = TextMgr:GetText(v.Des)
			childIcon.mainTexture =  ResourceLibrary:GetIcon ("Icon/setting/", v.Icon)--v.Icon--ResourceLibrary:GetIcon ("Icon/setting/", v.Icon)
			childIcon:MakePixelPerfect()
			if childIcon.width ~= childIcon.height then
				childbg.width =childIcon.width
				childbg.height = childIcon.height  
				childbg.gameObject:SetActive(false)
			end
			if v.id >= 200 and v.id < 300 then
				childIcon.width = 126
				childIcon.height = 94
				childbg.gameObject:SetActive(false)
			end
			if EnableIndex ~= nil then
				if v.id == EnableIndex then
					childIcon_Enable.gameObject:SetActive(true)
				end
			end
			SetClickCallback(obj, function(obj)
				ShowSetting(tonumber( obj.name))
			end)
			table.insert(SettingUI.InfoList,obj)
		end 
    end)
    SettingUI.Grid:Reposition()
    SettingUI.ScrollView:SetDragAmount(0, 0, false)    
end

local function ShowSettingData(data)
    local settings = SettingData[data.id]
    if settings == nil then
        print("Exe :", data.CMD)
        Global.GetTableFunction("GMCommand."..data.CMD)()
        return 
    end

end

local function CloseClickCallback(go)
    if CurID ~= 0 and not isLogin then
        local data =  SettingDataMap[CurID]
        if data ~= nil then
            ShowSetting(data.ParentID)
        end
    else
        Hide()
    end
end

function Hide()
    Global.CloseUI(_M)
    isLogin = nil
end

local function LoadUI()
    LoadData()
    SettingUI = {}
    SetClickCallback(transform:Find("menu").gameObject, CloseClickCallback)
    SetClickCallback(transform:Find("menu/bg_frane/bg_top/btn_close").gameObject, CloseClickCallback)
    SettingUI.Title = transform:Find("menu/bg_frane/bg_top/bg_title_left/title"):GetComponent("UILabel")
    SettingUI.ScrollView = transform:Find("menu/bg_frane/Scroll View"):GetComponent("UIScrollView")
    SettingUI.Grid = transform:Find("menu/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
    SettingUI.Version = transform:Find("menu/bg_frane/version"):GetComponent("UILabel")
    SettingUI.Version.text = GameStateMain:GetVersion()
	SettingUI.TimeLabel = transform:Find("menu/bg_frane/bg_time/name"):GetComponent("UILabel")
    SettingUI.SettingInfo = transform:Find("setinginfo").gameObject
    SettingUI.SettingInfo.gameObject:SetActive(false)

    SettingUI.InfoList = {}
end

function LateUpdate()
	if serverTimeMsg ~= nil and serverTimeSec > 0 then
		local passSec = Serclimax.GameTime.GetSecTime() - serverTimeSec
		SettingUI.TimeLabel.text = 	System.String.Format(TextMgr:GetText("WorldTime_title") , 
									Global.SecondToStringFormat(serverTimeSec + passSec , "yyyy-MM-dd HH:mm:ss"))
	end

	--if UnityEngine.Input.
	--inputString
	if (not System.String.IsNullOrEmpty(UnityEngine.Input.inputString)) then
		secInput = secInput .. UnityEngine.Input.inputString
		if string.find(secInput , secInputKey) then
			MessageBox.Show("[ff0000]FBI WARNNING![-]\n The pocket of war . 口袋战争" , function () secInput = "" end)
		end
	end
end

function CloseAll()
    Hide()
end


function Awake()
	serverTimeMsg = nil
	serverTimeSec = 0
end
	
function Close()
    SettingUI = nil
	serverTimeMsg = nil
	serverTimeSec = 0
end


function Show(_isLogin)
	secInput = ""
    heroUid = uid
    isLogin = _isLogin
    if isLogin then
        Global.OpenTopUI(_M)
        LoadUI()
        ShowSetting(2)
    else
        Global.OpenUI(_M)
        LoadUI()
        local req = LoginMsg_pb.MsgServerGameTimeRequest()
        Global.Request(Category_pb.Login, LoginMsg_pb.LoginTypeId.MsgServerGameTimeRequest, req, LoginMsg_pb.MsgServerGameTimeResponse, function(msg)
            serverTimeMsg = msg
            if serverTimeMsg ~= nil then
                serverTimeSec = serverTimeMsg.serverTime/1000
            end
            ShowSetting(0)
        end)
    end
end

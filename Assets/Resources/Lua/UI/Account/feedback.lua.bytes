module("feedback", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
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
local feedbackContent = {}

local function CloseClickCallback(go)
    Hide()
end

local function SendFeedback(go)
--optional uint32 type = 1;			// 类型 建议 bug 求助
	--optional string phone = 2;			// 机型
	--optional string phoneSystem = 3;	// 手机系统版本
	--optional string gameVersion = 4;	// 游戏版本号
	--optional bytes  info = 5;			
	if feedbackContent.input.value == "" then
		AudioMgr:PlayUISfx("SFX_ui02", 1, false)
		FloatText.Show(TextMgr:GetText("setting_help_8") , Color.white)
		return 
	end
	
	if Global.utfstrlen(feedbackContent.input.value) <= 10 then
		--print("len : " .. Global.utfstrlen(feedbackContent.input.value))
		AudioMgr:PlayUISfx("SFX_ui02", 1, false)
		FloatText.Show(TextMgr:GetText("setting_help_8") , Color.white)
		return 
	end
	
	
	
	local req = ClientMsg_pb.MsgUserReportRequest()
	req.type = 1
	print("deveice:" .. GUIMgr:GetDeviceName() .. "system: " .. GUIMgr:GetSystemInfo())
	req.phone = GUIMgr:GetDeviceName()
	req.phoneSystem = GUIMgr:GetSystemInfo()
	req.gameVersion = GameStateMain:GetVersion()
	req.info = feedbackContent.input.value
	--print("deveice:" .. PlatformUtils.GetDeviceNameByDeviceType(PlatformUtils.GetPlatformType()) .. " operation :" .. UnityEngine.SystemInfo.operatingSystem)
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserReportRequest, req, ClientMsg_pb.MsgUserReportResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		else
			AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
			FloatText.Show(TextMgr:GetText("setting_help_9") , Color.green)
			Hide()
		end
	end)
end

local function LoadUI()
	feedbackContent = {}
	feedbackContent.input = transform:Find("Container/bg_frane/frame_input"):GetComponent("UIInput")
	
	

    SetClickCallback(transform:Find("Container/bg_frane/bg_top/btn_close").gameObject,CloseClickCallback)
    SetClickCallback(transform:Find("Container/bg_frane/btn").gameObject , SendFeedback)
    SetClickCallback(transform:Find("Container").gameObject , CloseClickCallback)
end

function Hide()
    feedbackContent = nil
    --GUIMgr:CloseMenu("feedback" , false)
	Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end


function Awake()

end


function Show()
    Global.OpenUI(_M)
    LoadUI()
end

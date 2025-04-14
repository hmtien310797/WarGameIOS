module("Starwars", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local SetClickCallback = UIUtil.SetClickCallback

local _ui
local finishCallback
local guideStatus


function Hide()
	-- if finishCallback ~= nil then 
	-- 	finishCallback()
	-- end
	MapMask.LoadPrefab()
	Global.CloseUI(_M)
	
end

function Close()
	EventDelegate.Remove(_ui.guide1.onFinished, _ui.guide1CallBack)
	EventDelegate.Remove(_ui.guide2.onFinished, _ui.guide2CallBack)
	EventDelegate.Remove(_ui.guide3.onFinished, _ui.guide3CallBack)
	-- Global.GAudioMgr:StopMusic()	
	_ui = nil
	
end

function Show()		
	finishCallback = nil
	Global.OpenTopUI(_M)
end

function Awake()
	guideStatus = 1;	
	Global.GAudioMgr:PlayMusic("MUSIC_maincity_background", 0.2, true, 1)
	_ui = {}
	_ui.guide1 = transform:Find("Container/text_guide1"):GetComponent("TweenAlpha")	
	_ui.guide2 = transform:Find("Container/text_guide2"):GetComponent("TweenAlpha")	
	_ui.guide3 = transform:Find("Container/text_guide3"):GetComponent("TweenAlpha")	
	_ui.Container = transform:Find("Container"):GetComponent("TweenAlpha")	
	_ui.skip = transform:Find("skip btn"):GetComponent("UIButton")
	_ui.Mask = transform:Find("mask")
	_ui.Container1 = transform:Find("Container (1)"):GetComponent("BoxCollider")
	if _ui.Container1 ~= nil then
		UnityEngine.GameObject.Destroy(_ui.Container1)
	end
	MainCityUI.ShowWorldMapPreView(255, 255, 1, finishCallback)
	SetClickCallback(_ui.Mask.gameObject, function()
		MessageBox.Show(TextMgr:GetText("story_skip"), function() Hide() end, function() end, TextMgr:GetText(Text.common_hint1), nil, "btn_3", "btn_1")
	end)
	SetClickCallback(_ui.skip.gameObject, function()
		-- MainCityUI.ShowWorldMapPreView(255, 255, 1, finishCallback)
		Hide()
	end)
	_ui.guide1CallBack = EventDelegate.Callback(function()
        guideStatus = 2
	end)
	_ui.guide2CallBack = EventDelegate.Callback(function()
		guideStatus = 3
		-- MainCityUI.ShowWorldMapPreView(255, 255, 1, finishCallback)
	end)
	_ui.guide3CallBack = EventDelegate.Callback(function()
		guideStatus = 4
		MessageBox.Clear()
		Hide()
	end)
	-- _ui.ContainerCallBack = EventDelegate.Callback(function()
	-- 	if finishCallback ~= nil then 		
	-- 		finishCallback()
	-- 	end
	-- end)
	EventDelegate.Add(_ui.guide1.onFinished, _ui.guide1CallBack)
	EventDelegate.Add(_ui.guide2.onFinished, _ui.guide2CallBack)
	EventDelegate.Add(_ui.guide3.onFinished, _ui.guide3CallBack)
	-- EventDelegate.Add(_ui.Container.onFinished, _ui.ContainerCallBack)
	RequestGameLog(1,1)
end

function Update()
	if guideStatus < 4 then
		if guideStatus == 1 then
			_ui.guide1.gameObject:SetActive(true)
			guideStatus = 0
		elseif guideStatus == 2 then
			_ui.guide1.gameObject:SetActive(false)
			_ui.guide2.gameObject:SetActive(true)
			guideStatus = 0
		elseif guideStatus == 3 then
			_ui.guide1.gameObject:SetActive(false)
			_ui.guide2.gameObject:SetActive(false)
			_ui.guide3.gameObject:SetActive(true)
			guideStatus = 0
		end
	end
end

function RequestGameLog(type ,param)
    local req = ClientMsg_pb.MsgEnterGameLogRequest()
	req.param = param
	req.type = type
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgEnterGameLogRequest, req, ClientMsg_pb.MsgEnterGameLogResponse, function(msg) 
		GUIMgr:SendDataReport("efun", "register")
	end, true)    
end

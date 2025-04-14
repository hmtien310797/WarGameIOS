module("Levelup", package.seeall)

local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr.Instance
local TextMgr = Global.GTextMgr
local SetClickCallback = UIUtil.SetClickCallback
local GuideMgr = Global.GGuideManager
local ResourceLibrary = Global.GResourceLibrary

local btnQuit


--退出战斗按钮
local function ClosePressCallback(go, isPressed)
	if not isPressed then
		GUIMgr:CloseMenu("Levelup")
	end
end



function Start()
	
	
end

function Awake()
	
	
end

function Close()
end
module("Item_11101", package.seeall)
local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr.Instance
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local SetClickCallback = UIUtil.SetClickCallback

--local useCallBack 

--function SetCallBack(callback) 
--    useCallBack = callback 
--end 

function UseCallBack(msg)
	MainData.SetCharName(msg.charname)
	MainCityUI.UpdateRewardData(msg.fresh)
	SlgBag.UpdateBagItem(msg.fresh.item.items)
	CountListData.SetCount(msg.count)
end

function Use()
	ChangeName.SetCallBack(UseCallBack)
	GUIMgr:CreateMenu("ChangeName" , false)
end 

function Awake()
end 

function Start()
end 

function Close()
    --useCallBack = nil 
end 
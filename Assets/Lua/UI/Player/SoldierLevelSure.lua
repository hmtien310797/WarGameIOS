module("SoldierLevelSure", package.seeall)

local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr.Instance
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local SetClickCallback = UIUtil.SetClickCallback
local GuideMgr = Global.GGuideManager
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local GameTime = Serclimax.GameTime


local _ui
local callBackFunc
local costGold = false
local processing = false
local text1 , text2
local nextProcessTime
local autoCostGold
local costItemId
local costItemCount
--local _commandTableData

function Hide()
	--if not processing then
	Process(false)
	SoldierLevel.SetAutoCount(0)
	Global.CloseUI(_M)
	--end
end

local function OnLevelUpRequestCallBack()
	if callBackFunc ~= nil then
		callBackFunc()
	end
end

function ProcessFunc(_type , cb)
	--nextProcessTime = Serclimax.GameTime.GetSecTime()
	local req = ClientMsg_pb.MsgCommanderLeadLevelUpRequest()
    req.usegold = _type
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCommanderLeadLevelUpRequest, req, ClientMsg_pb.MsgCommanderLeadLevelUpResponse, function(msg)
		Global.DumpMessage(msg , "d:/MsgCommanderLeadLevelUpRequest.lua")
		if msg.code == ReturnCode_pb.Code_OK then
			MainData.SetCommanderLevel(msg.newlevel)
			MainCityUI.UpdateRewardData(msg.fresh)
			OnLevelUpRequestCallBack()
			if msg.result == 1 then
				FloatText.Show(TextMgr:GetText("command_ui_command_txt12") ,Color.green)
				Process(false)
			else
				FloatText.Show(TextMgr:GetText("command_ui_command_txt13") ,Color.red)
				Process(true)
			end
		else
			OnLevelUpRequestCallBack()
			Global.ShowError(msg.code)
			Process(false)
        end
		
	end , true)
end
--GetMilSecTime
function Process(proc)
	processing = proc
	LoadUI(processing)
	if processing then
		if Serclimax.GameTime.GetMilSecTime() < nextProcessTime then
			return
		end
--[[
	// 指挥官统帅升级
	message MsgCommanderLeadLevelUpRequest
	{
		optional uint32 usegold     = 1;    // 1:使用黄金 2:使用统帅书
	};
]]
		local _type = 2
		if autoCostGold then
			local have = ItemListData.GetItemCountByBaseId(tonumber(costItem))
			_type = have < costItemCount and 1 or 2
		else
			_type = 2
		end
		
		ProcessFunc(_type , Process)
		nextProcessTime = Serclimax.GameTime.GetMilSecTime() + 200
	else
		
	end
end


function LoadUI(proc)
	if _ui == nil then
		return
	end
	_ui.Label1.text = text1
	--_ui.Label2.text = text2
	
	_ui.button2.gameObject:SetActive(proc)
	_ui.button1.gameObject:SetActive(not proc)
	_ui.Label2.gameObject:SetActive(proc)
	_ui.Label3.gameObject:SetActive(not proc)
	_ui.costGoldObj.gameObject:SetActive(not proc)
end


function Start()
	local curLv = MainData.GetData().commanderLeadLevel
	local nextLv = curLv >= TableMgr:GetCommandDataCount() and curLv or curLv + 1
	nextLv = nextLv >= tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.MaxLevel).value) and tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.MaxLevel).value) or nextLv
	
	--local data = TableMgr:GetCommandData(curLv)
	local nextdata = TableMgr:GetCommandData(nextLv)
	local items = nextdata.ItemConsume:split(":")
	costItem = tonumber(items[1])
	costItemCount = tonumber(items[2])
	LoadUI(processing)
end

function Awake()
	_ui = {}
	_ui.mask = transform:Find("mask")
	_ui.btn_close = transform:Find("Container/back/close").gameObject
	
	_ui.Label1 = transform:Find("Container/back/Label1"):GetComponent("UILabel")
	_ui.Label2 = transform:Find("Container/back/Label2"):GetComponent("UILabel")
	_ui.Label3 = transform:Find("Container/back/Label3"):GetComponent("UILabel")
	
	_ui.button1 = transform:Find("Container/back/button1")
	_ui.button2 = transform:Find("Container/back/button2")
	_ui.costGoldObj = transform:Find("Container/back/gouxuan")
	_ui.costGoldSpr = transform:Find("Container/back/gouxuan/Sprite")
	
	SetClickCallback(_ui.mask.gameObject , Hide)
	SetClickCallback(_ui.btn_close.gameObject , Hide)
	
	SetClickCallback(_ui.button1.gameObject , function()	
		if not processing then
			Process(true)
		end
	end)
	
	SetClickCallback(_ui.button2.gameObject , function()	
		Process(false)
	end)
	
	SetClickCallback(_ui.costGoldObj.gameObject , function()
		autoCostGold = not autoCostGold
		_ui.costGoldSpr.gameObject:SetActive(autoCostGold)
	end)
	
	processing = false
	costGold = false
	nextProcessTime = 0
	autoCostGold = _ui.costGoldSpr.gameObject.activeSelf

end

function Update()
   if processing and Serclimax.GameTime.GetMilSecTime() >= nextProcessTime then
		Process(processing)
	end
end

function Close()
	_ui = nil
	callBackFunc = nil
	nextProcessTime = 0
end

function Show(label1 , label2 , func)
	text1 = label1
	text2 = label2
	callBackFunc = func
	
    Global.OpenUI(_M)
end

function Test()
	--Global.Request
end
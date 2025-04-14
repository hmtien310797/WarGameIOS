module("QueueLease", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String

local _ui
local itemid = 8601
local function CloseSelf()
	Global.CloseUI(_M)
end

function Close()
	_ui = nil
end

function Show()
	Global.OpenUI(_M)
end

function Awake()
	_ui = {}
	_ui.container = transform:Find("Container").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	_ui.vip_btn = transform:Find("Container/bg_frane/bg_left/btn_get").gameObject
	_ui.rent_btn = transform:Find("Container/bg_frane/bg_right/btn_get").gameObject
	_ui.rent_text = transform:Find("Container/bg_frane/bg_right/btn_get/text"):GetComponent("UILabel")
	_ui.rent_num = transform:Find("Container/bg_frane/bg_right/btn_get/num"):GetComponent("UILabel")
	_ui.icon_gold = transform:Find("Container/bg_frane/bg_right/btn_get/icon_gold"):GetComponent("UITexture")
end

local function LoadCostUI(id,num)
	if num > MoneyListData.GetMoneyByType(Common_pb.MoneyType_Diamond) then
		_ui.rent_num.text ="[ff0000]" ..num.. "[-]"
	else
		_ui.rent_num.text =num
	end
    local itemData = TableMgr:GetItemData(id)
    _ui.icon_gold.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
end

function Start()
	local item = ItemListData.GetItemDataByBaseId(itemid)
	_ui.item_count = 0
	if item ~= nil then
		_ui.item_count = item.number
	end
	local ql_str  = TableMgr:GetGlobalData(100233).value
	_ui.data ={}
	for v in string.gsplit(ql_str, ",") do
		table.insert(_ui.data,tonumber(v))
	end

	if _ui.item_count == 0 then
		LoadCostUI("2",_ui.data[2])
		_ui.rent_text.text =TextMgr:GetText("speedup_ui3")		
	else
		LoadCostUI("8601",1)--_ui.item_count)
		_ui.rent_text.text =TextMgr:GetText("speedup_ui2")
	end


	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)	
	SetClickCallback(_ui.vip_btn, function()
		print("_ui.vip_btn")
		local iapGoodInfo = GiftPackData.GetAvailableGoodsByID(801)
		if iapGoodInfo ~= nil then
			Goldstore.ShowGiftPack(iapGoodInfo)
			CloseSelf()
		end
	end)
	SetClickCallback(_ui.rent_btn, function()
		print("_ui.rent_btn")
		if _ui.item_count == 0 then
			if _ui.data[2] > MoneyListData.GetMoneyByType(Common_pb.MoneyType_Diamond) then
				Global.ShowNoEnoughMoney()
				return
			end
			if tonumber(os.date("%d")) == UnityEngine.PlayerPrefs.GetInt("t_today") then
				MessageBox.SetOkNow()
			else
				MessageBox.SetRemberFunction(function(ishide)
					if ishide then
						UnityEngine.PlayerPrefs.SetInt("t_today",tonumber(os.date("%d")))
						UnityEngine.PlayerPrefs.Save()
					end
				end)
			end
			MessageBox.Show(System.String.Format(TextMgr:GetText("ui_QueueLease1"), _ui.data[2],_ui.data[1]/3600),
			function()
				local req = BuildMsg_pb.MsgRentBuildQueueRequest()
				--LuaNetwork.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgBuildListRequest, req:SerializeToString(), function(typeId, data)
				Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgRentBuildQueueRequest, req, BuildMsg_pb.MsgRentBuildQueueResponse, function(msg)

					MainData.UpdateRentBuildQueueExpire(msg.fresh.maindata)
					MainCityUI.UpdateRewardData(msg.fresh)
					MainCityQueue.UpdateQueue()
					CloseSelf()
				end, true)
				
			end,
			function()
			
			end)
		else
			local item = ItemListData.GetItemDataByBaseId(itemid)
			SlgBag.ItemUseCount(item.uniqueid , 1)
			CloseSelf()
		end

	end)	
	UpdateUI()
end

UpdateUI = function()

end

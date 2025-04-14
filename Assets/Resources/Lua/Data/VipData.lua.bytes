module("VipData", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary

local VipPrivilegeTable
local VipInfo

local giftData
local isDailyGiftCollected

local levelupmsg = nil

local eventListener = EventListener()

local isRequesting = {}

local function NotifyListener()
	--AttributeBonus.CollectBonusInfo()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function GetLoginInfo()
	return VipInfo
end

function GetVipList()
	return VipPrivilegeTable
end

function GetVipGiftData()
	return giftData
end

function CollectDailyVipExp(callback)
	local request = VipMsg_pb.MsgObtainVipExpRequest()
	Global.Request(Category_pb.Vip, VipMsg_pb.VipTypeId.MsgObtainVipExpRequest, request, VipMsg_pb.MsgObtainVipExpResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			local itemData = TableMgr:GetItemData(15)
			local itemIcon = ResourceLibrary:GetIcon("Item/", itemData.icon)
			FloatText.Show(TextUtil.GetItemName(itemData) .. "x" .. VipInfo.todayObtain, Color.green, itemIcon)
			
			MainData.UpdateVip(msg.vipInfo)

			if VipInfo then
				VipInfo.pop = false
			end

			NotifyListener()

			if callback ~= nil then
				callback()
			end
		else
			Global.ShowError(msg.code)
		end
	end)
end

function CollectGift(level, msg, logString)
	GUIMgr:SendDataReport("reward", logString, "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))

	MainCityUI.UpdateRewardData(msg.fresh)
	if logString == "TakeVipGift" then
		giftData[level + 1].giftInfo.status = 3
		ItemListShowNew.SetTittle(TextMgr:GetText("login_ui_pay1"))
	elseif logString == "TakeVipDailyGift" then
		giftData[level + 1].dailyGiftInfo.status = 3
		isDailyGiftCollected = true
		ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
		MainCityUI.UpdateVipNotice()
	end

	ItemListShowNew.SetItemShow(msg)
	GUIMgr:CreateMenu("ItemListShowNew", false)
end

function PurchaseOneTimeGift(level, msg, callback)
	if not isRequesting.oneTimeGift then
		isRequesting.oneTimeGift = true

		local request = VipMsg_pb.MsgTakeVipGiftRequest()
		request.level = level
		Global.Request(Category_pb.Vip, VipMsg_pb.VipTypeId.MsgTakeVipGiftRequest, request, VipMsg_pb.MsgTakeVipGiftResponse, function(msg)
			isRequesting.oneTimeGift = false

			if msg.code == ReturnCode_pb.Code_OK then
				GUIMgr:SendDataReport("reward", "TakeVipGift", "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))

				MainCityUI.UpdateRewardData(msg.fresh)

				giftData[level + 1].giftInfo.status = 3

				ItemListShowNew.SetTittle(TextMgr:GetText("login_ui_pay1"))
				ItemListShowNew.SetItemShow(msg)
				GUIMgr:CreateMenu("ItemListShowNew", false)

				if callback ~= nil then
					callback()
				end
				MainCityUI.UpdateVipNotice()
			else
				Global.ShowError(msg.code)
			end
		end, true)
	end
end

function CollectDailyGift(level, msg, callback)
	if not isRequesting.dailyGift then
		isRequesting.dailyGift = true

		local request = VipMsg_pb.MsgTakeVipDailyGiftRequest()
		Global.Request(Category_pb.Vip, VipMsg_pb.VipTypeId.MsgTakeVipDailyGiftRequest, request, VipMsg_pb.MsgTakeVipDailyGiftResponse, function(msg)
			isRequesting.dailyGift = false

			if msg.code == ReturnCode_pb.Code_OK then
				GUIMgr:SendDataReport("reward", "TakeVipDailyGift", "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))

				MainCityUI.UpdateRewardData(msg.fresh)

				giftData[level + 1].dailyGiftInfo.status = 3
				isDailyGiftCollected = true
				
				ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
				ItemListShowNew.SetItemShow(msg)
				GUIMgr:CreateMenu("ItemListShowNew", false)

				MainCityUI.UpdateVipNotice()

				if callback ~= nil then
					callback()
				end
			else
				Global.ShowError(msg.code)
			end
		end, true)
	end
end

function HasUncollectedRewards()
	local canbuy = false
	for i, v in ipairs(giftData) do
		if v.giftInfo.status == 2 then
			canbuy = true
		end
	end
	return giftData[MainData.GetVipLevel() + 1].dailyGiftInfo.status ~= 3 or canbuy
end

function SetLevelUpMsg(msg)
	levelupmsg = msg
	if UnityEngine.GameObject.Find("login") == nil then
		CheckLevelUp()
	end
end

function CheckLevelUp(callback)
	if levelupmsg == nil then
		if callback ~= nil then
	        callback()
	    end
		return
	end
	VIPLevelup.SetCloseCallback(callback)
	--vip体验开启时不显示升级
	if MainData.GetVipValue().viplevelTaste < levelupmsg.newLevel then
		VIPLevelup.Show(levelupmsg.oldLevel, levelupmsg.newLevel)
	else
		if callback ~= nil then
	        callback()
	    end
	end
    CountListData.RequestData()
	ActionListData.RequestData()
	MobaActionListData.RequestData()
    VipData.RequestVipPanel()
	AttributeBonus.CollectBonusInfo()
    levelupmsg = nil
end

function GetValue(param1, param2)
	if VipPrivilegeTable == nil then 
    	return 0
    end
    if VipPrivilegeTable[MainData.GetVipLevel()] == nil then
    	return 0
    end
    for i, v in ipairs(VipPrivilegeTable[MainData.GetVipLevel()]) do
    	if v.type == 3 and tonumber(v.param1) == param1 and v.param2 == param2 then
	    	return v.value
		end
    end
    return 0
end

function CheckValue(param1, param2)
	if VipPrivilegeTable == nil then 
    	return false
    end
    if VipPrivilegeTable[MainData.GetVipLevel()] == nil then
    	return false
    end
    for i, v in ipairs(VipPrivilegeTable[MainData.GetVipLevel()]) do
    	if v.type == 3 and tonumber(v.param1) == param1 and v.param2 == param2 then
	    	return true
		end
    end
    return false
end

function IsNew(_level, data)
	local isnew = true
	if _level > 0 then
		for i, v in ipairs(VipPrivilegeTable[_level]) do
			if v.type == data.type and v.param1 == data.param1 and v.param2 == data.param2 then
				isnew = false
				--print(_level ,v.type , data.type , v.param1 , data.param1 , v.param2 , data.param2)
				break
			end
		end
	end
	return isnew
end

function MakeBaseTable()
	if VipPrivilegeTable ~= nil then
		return
	end
	VipPrivilegeTable = {}
	local data = TableMgr:GetVipPrivilegeDataList()
	for i , v in kpairs(data) do
		if VipPrivilegeTable[data[i].level] == nil then
			VipPrivilegeTable[data[i].level] = {}
		end
		table.insert(VipPrivilegeTable[data[i].level], data[i])
	end
	
	for _ ,v in pairs(VipPrivilegeTable) do
		table.sort(v , function(v1,v2)
			if v1.isnew ~= v2.isnew then
				return v1.isnew > v2.isnew
			else
				return v1.id < v2.id
			end
		end)
	end
	--[[for i = 1, tableData_tVipPrivilege.Count do
		if VipPrivilegeTable[data[i].level] == nil then
			VipPrivilegeTable[data[i].level] = {}
		end
		table.insert(VipPrivilegeTable[data[i].level], data[i])
	end]]
	
	AttributeBonus.RegisterAttBonusModule(_M)
	--AttributeBonus.CollectBonusInfo()
end

function CalAttributeBonus()
	local bonus = {}
    if VipPrivilegeTable == nil then 
    	return bonus
    end
    if VipPrivilegeTable[MainData.GetVipLevel()] == nil then
    	return bonus
    end
    for i, v in ipairs(VipPrivilegeTable[MainData.GetVipLevel()]) do
    	if v.type == 2 then
	    	local b = {}
			local t = string.split(v.param1,';')  
			for j=1,#(t) do
			    if t[j] ~= nil then 
			        local b = {}
			        b.BonusType =tonumber(t[j])
			        b.Attype =  v.param2
			        b.Value =  v.value
			        b.Global = 1
			        table.insert(bonus,b)
			    end
			end
		end
    end
    return bonus
end

function SetGiftData(data, currentVipLevel)
	if data then
		giftData = data
		isDailyGiftCollected = data[(currentVipLevel or MainData.GetVipLevel()) + 1].dailyGiftInfo.status == 3
	end
end

function RequestVipPanel(callback)
	local req = VipMsg_pb.MsgVipPanelRequest()
    Global.Request(Category_pb.Vip, VipMsg_pb.VipTypeId.MsgVipPanelRequest, req, VipMsg_pb.MsgVipPanelResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
        	VipInfo = msg.obtainInfo
        	MakeBaseTable()
        	MainData.UpdateVip(msg.vipInfo)
        	SetGiftData(msg.pkgInfos)

			maincity.CaculateBuildQueue()
        	if callback ~= nil then
        		callback()
			end
			NotifyListener()
			
			MainCityUI.UpdateVipNotice()
        end
    end, true)
end

function UpdateGiftData(currentLevel)
	for _, data in ipairs(giftData) do
		data.giftInfo.status = data.level <= currentLevel and math.max(data.giftInfo.status, 2) or 1
		data.dailyGiftInfo.status = data.level == currentLevel and (isDailyGiftCollected and 3 or 2) or 1
	end

	return giftData
end

function Initialize()
	RequestVipPanel()
end


function VipExperience(data)
	if data.item ~= nil then 
		for i,v in ipairs(data.item.items) do
			if v.data ~= nil then 
				local ItemData = TableMgr:GetItemData(v.data.baseid)
				if ItemData ~= nil then
					if ItemData.type == 9 and ItemData.subtype == 1 then
						if MainData.GetVipLevel() < ItemData.param1 then
							local req = ItemMsg_pb.MsgUseItemRequest()
							req.uid = v.data.uniqueid
							req.num = 1
							Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemRequest, req, ItemMsg_pb.MsgUseItemResponse, function(msg)	
								if MainData.GetVipValue().viplevel < tonumber(ItemData.param1) then							
									VIPLevelup.Show(MainData.GetVipValue().viplevel, ItemData.param1, 1, ItemData.param2)								
									MainData.UpdateVip(msg.fresh.maindata.vip)
									ConfigData.SetVipExperienceCard(false)
									MainCityUI.RefreshVipExperienceCard()
									MainCityUI.RefreshVipEffect()
									RequestVipPanel()
								end
							end)		
						end
					end
				end
			end
		end
	end
end

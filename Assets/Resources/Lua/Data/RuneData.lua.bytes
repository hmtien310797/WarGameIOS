module("RuneData", package.seeall)
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr

local runeListData , runeSortedListData, runeEquipedListData , runeUnlockData , runeCountTable , runeUnwearedListData,runeTableData,runTable
local eventListener = EventListener()
local nextFreeTime = {}

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

function RegistAttributeModel()
    AttributeBonus.RegisterAttBonusModule(_M)
end

local function InitTableData()
--print("InitTableData" , runeTableData)
	if runeTableData == nil then
		runeTableData = {}
		for i, v in kpairs(TableMgr:GetRuneData()) do
			local tempdata = {}
			tempdata.id = v.id
			tempdata.RuneType = v.RuneType
			tempdata.Level = v.Level
			tempdata.NeedMaterial = {}
			local str = string.split(v.NeedMaterial, ":")
			tempdata.NeedMaterial.id = tonumber(str[1])
			tempdata.NeedMaterial.num = tonumber(str[2])
			tempdata.Recycling = {}
			str = string.split(v.Recycling, ":")
			tempdata.Recycling.id = tonumber(str[1])
			tempdata.Recycling.num = tonumber(str[2])
			tempdata.RuneAttribute = {}
			str = string.msplit(v.RuneAttribute, ";", ",")
			for ii, vv in ipairs(str) do
				local b = {}
				b.BonusType = vv[1]
				b.Attype =  tonumber(vv[2])
				b.Value = tonumber(vv[3])
				b.sign = tonumber(vv[4]) == 0
				table.insert(tempdata.RuneAttribute, b)
			end
			tempdata.RunePkvalue = v.RunePkvalue
			runeTableData[v.id] = tempdata
		end
	end
end

function SetContentItemData(item, data)
	if item.childCount > 0 then
		item:GetComponent("UILabel").text = TextMgr:GetText(TableMgr:GetEquipTextDataByAddition(data.BonusType, data.Attype))
		item:GetChild(0):GetComponent("UILabel").text = (data.sign and "+" or "-") .. System.String.Format("{0:F}" , data.Value) .. (Global.IsHeroPercentAttrAddition(data.Attype) and "%" or "")
	else
		item:GetComponent("UILabel").text = TextMgr:GetText(TableMgr:GetEquipTextDataByAddition(data.BonusType, data.Attype)) .. (data.sign and "+" or "-") .. System.String.Format("{0:F}" , data.Value) .. (Global.IsHeroPercentAttrAddition(data.Attype) and "%" or "")
	end
end


function SetAttributeList(runeIds , detailGrid , contentItem)
	--print("SetAttributeList" , runeTableData)
	InitTableData()
	
	tdata = {}
	if type(runeIds) == "number" or type(runeIds) == "string" then
		for i, v in ipairs(runeTableData[tonumber(runeIds)].RuneAttribute) do
			table.insert(tdata, v)
		end
	elseif type(runeIds) == "table" then
		for i, v in ipairs(runeIds) do
			
	--print("SetAttributeList=========" , v , runeTableData[tonumber(v)] )
			for ii, vv in ipairs(runeTableData[tonumber(v)].RuneAttribute)do
				local isnew = true
				for iii, vvv in ipairs(tdata) do
					if vvv.BonusType == vv.BonusType and vvv.Attype == vv.Attype then
						vvv.Value = vvv.Value + vv.Value
						isnew = false
					end
				end
				if isnew then
					local b = {}
					b.BonusType = vv.BonusType
					b.Attype =  vv.Attype
					b.Value = vv.Value
					b.AttName = vv.AttName
					b.sign = vv.sign
					table.insert(tdata, b)
				end
			end
		end
	else
		return
	end
	
	if detailGrid ~= nil and contentItem ~= nil then
		local childCount = detailGrid.transform.childCount
		for i, v in ipairs(tdata) do
			local itemTransform 
			if i - 1 < childCount then  --池中存放item的数据
				itemTransform = detailGrid.transform:GetChild(i - 1)
			else
				itemTransform = NGUITools.AddChild(detailGrid.gameObject, contentItem.gameObject).transform
			end
			itemTransform.gameObject:SetActive(true)
			SetContentItemData(itemTransform, v)
		end
		for i = #tdata, childCount - 1 do
			detailGrid.transform:GetChild(i).gameObject:SetActive(false)
		end
		detailGrid:Reposition()
	end
end

function GetRunePkValue()
	local value = 0
	for i, v in ipairs(runeEquipedListData) do
		value = value + GetRuneDataByUid(v).RuneData.Level
	end
	return value
end

function CalAttributeBonus()
    local equipList = GetRuneEquipedListData()
	local ids = {}
	if equipList ~= nil then
		for _ , v in ipairs(equipList) do
			local data = RuneData.GetRuneDataByUid(v)
			if data then
				table.insert(ids , data.data.baseid)
			end
		end
	end
	SetAttributeList(ids)
	return tdata
end

function GetRuneEquipedListData()
	return runeEquipedListData
end

function GetRuneListData()
	return runeListData
end

local function SetRuneUnlockData (rpInfo)
	runeUnlockData = rpInfo
end

function GetRuneUnlockData()
	return runeUnlockData
end

function GetUnwearedRuneCount(baseid)
	return runeCountTable[baseid] and runeCountTable[baseid] or 0
end

function GetUnwearedRunes(rtype)
	--RefreshList()
	local list = nil
	local uidlist = {}
	runeCountTable = {}
	for _ , v in pairs(runeUnwearedListData) do
		if runTable[v] and (rtype == 0 or runTable[v].RuneData.RuneType == rtype) then
			local item = runTable[v]
			--table.insert(list , item)
			if list == nil then
				list = {}
			end
			
			if not list[item.data.baseid] then
				list[item.data.baseid] = item
			end
			if not uidlist[item.data.baseid] then
				uidlist[item.data.baseid] = {}
			end
			table.insert(uidlist[item.data.baseid], v)
			
			if runeCountTable[item.data.baseid] then
				runeCountTable[item.data.baseid] = runeCountTable[item.data.baseid] + 1
			else
				runeCountTable[item.data.baseid] = 1
			end
			
		end
	end
	
	local sortList = nil
	if list then
		if sortList  == nil then sortList = {} end
		
		for _ , v in pairs(list) do
			table.insert(sortList , v)
		end
		
		table.sort(sortList , function(v1,v2)
			return v1.RuneData.Level > v2.RuneData.Level
		end)
	end
	
	return sortList, runeCountTable, uidlist
end

function GetRuneTableData(id)
	InitTableData()
	if id == nil then
		return runeTableData
	end
	return runeTableData[id]
end

function GetRuneDataByUid(uniqueid)
	return runTable[uniqueid]
end

function GetEquipRuneByPos(pos)
	for _ , v in ipairs(runeEquipedListData) do
		if runTable[v] and runTable[v].data.parent.pos == pos then
			return runTable[v]
		end
	end
	return nil
end

RefreshList = function()
	runeListData = {}
	runeEquipedListData = {}
	runeUnwearedListData = {}
	runTable = {}
	InitTableData()
	local data = ItemListData.GetData()
	for i, v in ipairs(data) do
		local itemdata = TableMgr:GetItemData(v.baseid)
		if itemdata ~= nil then
			if itemdata.type == Common_pb.ItemType_Rune then
				local item = {}
				item.data = v
				item.BaseData = itemdata
				--item.BaseBonus = equipTable[v.baseid].BaseBonus
				item.RuneData = TableMgr:GetRuneDataById(v.baseid)	
				table.insert(runeListData, item)
				if v.parent.pos > 0 then
					table.insert(runeEquipedListData, v.uniqueid)
				elseif v.parent.pos == 0 then
					table.insert(runeUnwearedListData, v.uniqueid)
				end
				runTable[v.uniqueid] = item
			end
		end
	end
	
	--sort
	--[[for _ , v in pairs(runTable) do
		table.insert(runeListData , v)
		if v.data.parent.pos > 0 then
			table.insert(runeEquipedListData, v.data.baseid)
		end
	end
	table.sort(runeListData, function(a,b) return a.data.baseid < b.data.baseid end)
	table.sort(runeEquipedListData, function(a,b) return a.data.baseid < b.data.baseid end)]]
	NotifyListener()
end

function RequestRuneInfoData(callback)
	local req = ItemMsg_pb.MsgRuneInfoRequest()
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgRuneInfoRequest, req, ItemMsg_pb.MsgRuneInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
			Global.DumpMessage(msg , "d:/rune.lua")
			SetRuneUnlockData(msg.runeInfo.gridInfo)
			RefreshList()
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function UpdateRunePos(rtype , id)
	if rtype == 1 then
		runeUnlockData.unlockBlue.ids:append(id)
	elseif rtype == 2 then
		runeUnlockData.unlockGreen.ids:append(id)
	elseif rtype == 3 then
		runeUnlockData.unlockRed.ids:append(id)
	end
	--NotifyListener()
end

function RequestComposeRune(baseId, num, callback)
	local req = ItemMsg_pb.MsgComposeRuneRequest()
	req.baseId = baseId
	req.num = num
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgComposeRuneRequest, req, ItemMsg_pb.MsgComposeRuneResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			MainCityUI.UpdateRewardData(msg.fresh)
            Global.ShowReward(msg.reward)
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function RequestDecomposeRune(uids, callback)
	local req = ItemMsg_pb.MsgDecomposeRuneRequest()
	if type(uids) == "table" then
		for i, v in ipairs(uids) do
			req.uids:append(v)
		end
	else
		req.uids:append(uids)
	end
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgDecomposeRuneRequest, req, ItemMsg_pb.MsgDecomposeRuneResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			MainCityUI.UpdateRewardData(msg.fresh)
            Global.ShowReward(msg.reward)
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

local runeChestPanel
function GetRuneChestPanel()
	return runeChestPanel
end

function IsFreeDraw()
	local freetype = 0 -- 0没有，1普通，2高级，3都有
	local curTime = Serclimax.GameTime.GetSecTime()
    for i, v in ipairs(nextFreeTime) do
		local isfree = curTime >= v
		if isfree and i == 1 then
			freetype = freetype + i
		end
	end
	return freetype
end

local function UpdateNextFreeTime(panels)
	local nexttime = 0
	if #panels == 0 then
		nextFreeTime[panels.type] = panels.nextFreeTime
	end
	for i, v in ipairs(panels) do
		nextFreeTime[v.type] = v.nextFreeTime
	end
	for i, v in pairs(nextFreeTime) do
		if nexttime == 0 then
			nexttime = v
		elseif nexttime > v then
			nexttime = v
		end
	end
	CountDown.Instance:Add("RunedrawData", nexttime, function(t)
		if nexttime <= Serclimax.GameTime.GetSecTime() then
			CountDown.Instance:Remove("RunedrawData")
			NotifyListener()
		end
	end)
	NotifyListener()
end

function RequestRuneChestPanel(callback)
	local req = ItemMsg_pb.MsgRuneChestPanelRequest()
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgRuneChestPanelRequest, req, ItemMsg_pb.MsgRuneChestPanelResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			runeChestPanel = msg
			UpdateNextFreeTime(msg.panels)
            if callback ~= nil then
            	callback(msg)
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function RequestRuneEnterChest(type, mod, free, buy, callback)
	local req = ItemMsg_pb.MsgRuneEnterChestRequest()
	req.type = type
	req.mod = mod
	req.free = free
	req.buy = buy
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgRuneEnterChestRequest, req, ItemMsg_pb.MsgRuneEnterChestResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			UpdateNextFreeTime(msg.panel)
			MainCityUI.UpdateRewardData(msg.fresh)
            if callback ~= nil then
            	callback(msg)
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function HasRedPoint()
	local emptyPos , emptyType = 0 , 0
	local hasEmpty = false
	if runeUnlockData and runeUnlockData.unlockBlue then
		for i=1 , #runeUnlockData.unlockBlue.ids do
			if GetEquipRuneByPos(runeUnlockData.unlockBlue.ids[i]) == nil then
				emptyPos = runeUnlockData.unlockBlue.ids[i]
				emptyType = 1
				hasEmpty = true
			end
		end
	end
	
	if not hasEmpty and runeUnlockData and runeUnlockData.unlockGreen then
		for i=1 , #runeUnlockData.unlockGreen.ids do
			if GetEquipRuneByPos(runeUnlockData.unlockGreen.ids[i]) == nil then
				emptyPos = runeUnlockData.unlockGreen.ids[i]
				emptyType = 2
				hasEmpty = true
			end
		end
	end
	
	if not hasEmpty and runeUnlockData and runeUnlockData.unlockRed then
		for i=1 , #runeUnlockData.unlockRed.ids do
			if GetEquipRuneByPos(runeUnlockData.unlockRed.ids[i]) == nil then
				emptyPos = runeUnlockData.unlockRed.ids[i]
				emptyType = 3
				hasEmpty = true
			end
		end
	end
	
	if hasEmpty and emptyPos > 0 and emptyType > 0 then
		if GetUnwearedRunes(emptyType) ~= nil then
			return true
		end
	end
	
	return false
end
module("EquipData", package.seeall)
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr

local equipTable, equipAddTable, equipPosTable, equipQualityTable, materialTable, armouryTable
local equiplist, materiallist, RefreshList, equipedlist

local eventListener = EventListener()

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

function SetLevelColor(target, level)
	local c
	if MainData.GetLevel() >= level then
		c = Color.white
	else
		c = Color.red
	end
	local l = target.transform:GetComponent("UILabel")
	l.gradientTop = c
	l.gradientBottom = c
	l = target.transform.parent:GetComponent("UILabel")
	l.gradientTop = c
	l.gradientBottom = c
end

local function GetCurArmoury()
	local building = maincity.GetBuildingByID(44)
	return (building ~= nil and armouryTable[building.data.level] ~= nil) and armouryTable[building.data.level].data or nil
end

function IsUnlock(pos)
	local data = GetCurArmoury()
	if data == nil then
		return false
	end
	if string.find(data.JewelryPos, ';') ~= nil then
		local p = string.split(data.JewelryPos,';')
		for i, v in ipairs(p) do
			if tonumber(v) == tonumber(pos) then
				return true
			end
		end
	else
		if tonumber(data.JewelryPos) == tonumber(pos) then
			return true
		end
	end
	return false
end

function GetSpeedUp()
	local data = GetCurArmoury()
	if data == nil then
		return 1
	end
	return 1 + data.SpeedUp * 0.01
end

function GetEquipedPkValue()
	local value = 0
	for i, v in ipairs(equipedlist) do
		value = value + equipTable[v].EquipData.Fight
	end
	return value
end

function CalAttributeBonus()
    if MainData.IsCommanderCaptured() then
        return {}
    end

    local bonus = {}
    if equipedlist == nil then 
       return bonus
    end
    for i, v in ipairs(equipedlist) do
    	for ii, vv in ipairs(equipTable[v].Bonus) do
    		table.insert(bonus, vv)
    	end
    end
    return bonus
end

local function GetMaterialBeginer(id)
	--[[if materialTable[id] ~= nil and tonumber(materialTable[id].data.Item) > 0 then
		return GetMaterialBeginer(tonumber(materialTable[id].data.Item))
	else
		return id
	end]]
	return id
end

local function SetMaterialNext(list)
	if materialTable[list[#list]].Next ~= nil then
		table.insert(list, materialTable[list[#list]].Next)
		SetMaterialNext(list)
	end
end

function GetMaterialSeries(id)
	local list = {}
	list[1] = GetMaterialBeginer(id, list)
	SetMaterialNext(list)
	local index
	for i, v in ipairs(list) do
		if v == id then
			index = i
		end
	end
	return list, index
end

local function GetEquipEnd(id)
	if equipTable[id] ~= nil and equipTable[id].Next ~= nil then
		return GetEquipEnd(equipTable[id].Next)
	else
		return id
	end
end

local function GetEquipBeginer(id)
	if equipTable[id] ~= nil and tonumber(equipTable[id].EquipData.NeedEquip) > 0 then
		return GetEquipBeginer(tonumber(equipTable[id].EquipData.NeedEquip))
	else
		return id
	end
end

local function SetEquipNext(list)
	if equipTable[list[#list]].Next ~= nil then
		table.insert(list, equipTable[list[#list]].Next)
		SetEquipNext(list)
	end
end

function GetEquipSeries(id)
	local list = {}
	list[1] = GetEquipBeginer(id, list)
	SetEquipNext(list)
	local index
	for i, v in ipairs(list) do
		if v == id then
			index = i
		end
	end
	return list, index
end

function GetDeffent(curId, tarId)
	if curId == tarId then
		return equipTable[curId].BaseBonus
	else
		local curdata = equipTable[curId].BaseBonus
		local tardata = equipTable[tarId].BaseBonus
		local list = {}
		for i, v in ipairs(curdata) do
			local issame = false
			for ii, vv in ipairs(tardata) do
				if v.BonusType == vv.BonusType and v.Attype == vv.Attype then
					issame = true
					local b = {}
					b.BonusType = v.BonusType
					b.Attype = v.Attype
					b.Value = vv.Value - v.Value
					if tonumber(b.BonusType) == nil or tonumber(b.BonusType) > 0 or b.Attype > 0 then
						table.insert(list, b)
					end
				end
			end
			if not issame then
				local b = {}
				b.BonusType = v.BonusType
				b.Attype = v.Attype
				b.Value = - v.Value
				if tonumber(b.BonusType) == nil or tonumber(b.BonusType) > 0 or b.Attype > 0 then
					table.insert(list, b)
				end
			end
		end
		for i, v in ipairs(tardata) do
			local issame = false
			for ii, vv in ipairs(list) do
				if v.BonusType == vv.BonusType and v.Attype == vv.Attype then
					issame = true
				end
			end
			if not issame then
				if tonumber(v.BonusType) == nil or tonumber(v.BonusType) > 0 or v.Attype > 0 then
					table.insert(list, v)
				end
			end
		end
		return list
	end
end

local function CaculateMaterial(beginid, targetid, num)
	local mat = GetMaterialServerDataByID(beginid)
	if beginid < targetid then
		local nextmat = materialTable[materialTable[beginid].Next]
		local _num = (mat ~= nil and mat.data.number or 0) + (num ~= nil and num or 0)
		return CaculateMaterial(materialTable[beginid].Next, targetid, math.floor(_num / nextmat.data.Num))
	elseif beginid > targetid then
		local nextmat = materialTable[materialTable[beginid].Next]
		local _num = (mat ~= nil and mat.data.number or 0) * materialTable[beginid].data.Num + (num ~= nil and num or 0)
		if nextmat ~= nil then
			return CaculateMaterial(materialTable[beginid].Next, targetid, _num)
		else
			return _num
		end
	else
		local nextmat = materialTable[materialTable[beginid].Next]
		local _num = (mat ~= nil and mat.data.number or 0) + (num ~= nil and num or 0)
		if nextmat ~= nil then
			return CaculateMaterial(materialTable[beginid].Next, targetid, _num)
		else
			return _num
		end
	end
end

local function CheckMaterialNum(id)
	local beginer = GetMaterialBeginer(id)
	return CaculateMaterial(beginer, id, 0)
end

function CheckMaterials(id, neednext)
	local equip = equipTable[id]
	local isMax = nil
	if neednext then
		if equip.Next ~= nil then
			equip = equipTable[equip.Next]
		else
			isMax = true
		end
	end
	local hasequip = GetEquipByID(equip.Previous)
	local materialenough = true
	local materials = {}
	for i, v in ipairs(equip.Materials) do
		materials[i] = {}
		materials[i].id = v.id
		materials[i].need = v.num
		local mat = GetMaterialServerDataByID(v.id)
		materials[i].has = mat ~= nil and mat.data.number or 0--CheckMaterialNum(v.id)
		if materials[i].has < materials[i].need then
			materialenough = false
		end
	end
	return hasequip, materials, isMax, materialenough, equip.Previous > 0
end

function GetEquipMap(pos, qua, bonus, att)
	local list = {}
	for i, v in ipairs(equipPosTable[pos]) do
		if equipTable[v].Materials ~= nil and #equipTable[v].Materials > 0 then
			for ii, vv in ipairs(equipQualityTable[qua]) do
				if v == vv then
					if type(bonus) == "number" then
						table.insert(list, v)
					else
						for iii, vvv in pairs(equipAddTable[bonus][att]) do
							if v == vvv then
								table.insert(list, v)
							end
						end
					end
				end
			end
		end
	end
	local curlevel = MainData.GetLevel()
	table.sort(list, function(a, b)
		local adata = GetEquipDataByID(a)
		local bdata = GetEquipDataByID(b)
		if adata.BaseData.charLevel <= curlevel and bdata.BaseData.charLevel <= curlevel then
			return adata.BaseData.charLevel > bdata.BaseData.charLevel
		else
			return adata.BaseData.charLevel < bdata.BaseData.charLevel
		end
	end)
	return list
end

function GetEquipAddTable()
	return equipAddTable
end

function GetMaterialByID(id)
	return materialTable[id]
end

function GetEquipDataByID(id)
	return equipTable[id]
end

function GetEquipList()
	return equiplist
end

function GetMaxEquipDataByID(id)
	return equipTable[GetEquipEnd(id)]
end

function GetEquipStatusById(id) --0:未获得,1:已获得,2:已装备
	for i, v in ipairs(equiplist) do
		if v.data.baseid == id then
			if v.data.parent.pos == 0 then
				return 1
			else
				return 2
			end
		end
	end
	return 0
end

function GetEquipListByPos(pos)
	if pos > 7 then
		pos = 7
	end
	local list = {}
	for i, v in ipairs(equiplist) do
		if v.BaseData.subtype == pos then
			table.insert(list, v)
		end
	end
	table.sort(list, function(a,b)
		return a.EquipData.Fight > b.EquipData.Fight
	end)
	return list
end

function GetNonEquipListByPos(pos)
	if pos > 7 then
		pos = 7
	end
	local list = {}
	for i, v in ipairs(equipPosTable[pos]) do
		local has = false
		local first = GetEquipBeginer(v)
		for k, l in ipairs(equiplist) do
			if GetEquipBeginer(l.BaseData.id) == first then
				has = true
			end
		end
		if not has then
			for k, l in ipairs(list) do
				if l.BaseData.id == first then
					has = true
				end
			end
			if not has then
				table.insert(list, equipTable[first])
			end
		end
	end
	table.sort(list, function(a,b)
		local ahasequip, amaterials, aismax, amaterialenough, ahasPrevious = CheckMaterials(a.BaseData.id)
		local bhasequip, bmaterials, bismax, bmaterialenough, bhasPrevious = CheckMaterials(b.BaseData.id)
		if amaterialenough == bmaterialenough then
			return a.EquipData.Fight > b.EquipData.Fight
		else
			return amaterialenough
		end
	end)
	return list
end

function GetCurEquipByPos(pos)
	for i, v in ipairs(equiplist) do
		if v.data.parent.pos == pos then
			return v
		end
	end
	return nil
end

function GetEquipByUID(uid)
	for i, v in ipairs(equiplist) do
		if v.data.uniqueid == uid then
			return v
		end
	end
	return nil
end

function GetEquipByID(id)
	local equip = nil
	for i, v in ipairs(equiplist) do
		if v.data.baseid == id then
			--[[if equip == nil then
				equip = v
			elseif v.data.parent.pos == 0 then
				equip = v
			end]]
			equip = v
		end
	end
	return equip
end

function GetEquipInGroupByID(id) --在某个装备系列中查找是否已存在
	local equip = nil
	local list = {}
	list[1] = GetEquipBeginer(id, list)
	SetEquipNext(list)
	for i, v in ipairs(equiplist) do
		for k, l in ipairs(list) do
			if v.data.baseid == l then
				equip = v
			end
		end
	end
	return equip
end

function IsCanUpgradeByPos(pos)
	if pos >= 7 and not IsUnlock(pos) or false then
		return false
	end
	local equiped = GetCurEquipByPos(pos)
	if pos > 7 then
		pos = 7
	end
	for i, v in ipairs(equipPosTable[pos]) do
		local hasequip, materials, ismax, materialenough, hasPrevious = CheckMaterials(v)
		if hasPrevious then
			if hasequip and materialenough and hasequip.data.status == 0 then
				if equiped == nil then
					return true
				elseif equiped == hasequip then
					return true					
				end
			end
		else
			if materialenough and GetEquipInGroupByID(v) == nil then
				if equiped == nil then
					return true
				end
			end
		end
	end
	return false
end

function IsCanUpgrade()
	local canupgrade = false
	for i = 1, 9 do
		if IsCanUpgradeByPos(i) and IsUnlock(pos) then
			canupgrade = true
		end
	end
	return canupgrade
end

function GetUpgradingEquip()
	for i, v in ipairs(equiplist) do
		if v.data.status >= 1 then
			return v
		end
	end
	return nil
end

function GetUpgradeNeedTime()
	local upgrading = GetUpgradingEquip()
	if upgrading == nil then
		return 0
	end
	AttributeBonus.CollectBonusInfo(nil, 1)
	local bonus = AttributeBonus.GetBonusInfos()
	return GetEquipDataByID(upgrading.data.status == 1 and upgrading.BaseData.id or GetEquipDataByID(upgrading.BaseData.id).Next).EquipData.Time / GetSpeedUp() / (1 + 0.01 * (bonus[1096] ~= nil and bonus[1096] or 0))
end

function GetMaterialServerDataByID(id)
	for i, v in ipairs(materiallist) do
		if v.data.baseid == id then
			return v
		end
	end
	return nil
end

function GetMaterialList()
	return materiallist
end

local function MakeBaseBonus(_data, ArmyType, AttrType, Value)
	if _data.BaseBonus == nil then
		_data.BaseBonus = {}
	end
	local b = {}
	b.BonusType = ArmyType
	b.Attype =  AttrType
	b.Value = Value
	table.insert(_data.BaseBonus, b)
end

local function MakeBonus(_data, ArmyType, AttrType, Value, Global)
	if _data.Bonus == nil then
		_data.Bonus = {}
	end
	MakeBaseBonus(_data, ArmyType, AttrType, Value)
	local t = string.split(ArmyType,';')  
	for j=1,#(t) do
	    if t[j] ~= nil then
	    	if tonumber(t[j]) ~= 0 or AttrType ~= 0 then
		        local b = {}
		        b.BonusType =tonumber(t[j])
		        b.Attype =  AttrType
		        b.Value =  Value
		        b.Global = Global
		        table.insert(_data.Bonus, b)
		    end
	    end
	end
end

local function MakeNeedMaterial(_data, materials)
	if _data.Materials == nil then
		_data.Materials = {}
	end
	if materials ~= "NA" then
		local t = string.split(materials,';') 
		for i = 1, #(t) do
			if t[i] ~= nil then
				m = string.split(t[i], ':')
				local mat = {}
				mat.id = tonumber(m[1])
				mat.num = tonumber(m[2])
				table.insert(_data.Materials, mat)
			end
		end
	end
end

function MakeBaseTable()
	if equipTable ~= nil then
		return
	end
	ItemListData.AddListener(RefreshList)
	equipTable = {}
	equipAddTable = {}
	equipPosTable = {}
	equipQualityTable = {}
	local data = TableMgr:GetEquipTable()
	for _ , ev in pairs(data) do
		local _data = ev
		local id = _data.id
		local item_data = TableMgr:GetItemData(id)
		if item_data.type ~= 202 then
			equipTable[id] = {}
			equipTable[id].EquipData = _data
			equipTable[id].BaseData = item_data
			MakeBonus(equipTable[id], _data.AdditionArmy1, _data.AdditionAttr1, _data.Value1, _data.Global1)
			MakeBonus(equipTable[id], _data.AdditionArmy2, _data.AdditionAttr2, _data.Value2, _data.Global2)
			MakeBonus(equipTable[id], _data.AdditionArmy3, _data.AdditionAttr3, _data.Value3, _data.Global3)
			MakeBonus(equipTable[id], _data.AdditionArmy4, _data.AdditionAttr4, _data.Value4, _data.Global4)
			MakeBonus(equipTable[id], _data.AdditionArmy5, _data.AdditionAttr5, _data.Value5, _data.Global5)
			MakeBonus(equipTable[id], _data.AdditionArmy6, _data.AdditionAttr6, _data.Value6, _data.Global6)
			MakeNeedMaterial(equipTable[id], _data.NeedMaterial)
			for i, v in ipairs(equipTable[id].BaseBonus) do
				if equipAddTable[v.BonusType] == nil then
					equipAddTable[v.BonusType] = {}
				end
				if equipAddTable[v.BonusType][v.Attype] == nil then
					equipAddTable[v.BonusType][v.Attype] = {}
				end
				table.insert(equipAddTable[v.BonusType][v.Attype], id)
			end
			equipTable[id].Previous = tonumber(_data.NeedEquip)
			if equipPosTable[equipTable[id].BaseData.subtype] == nil then
				equipPosTable[equipTable[id].BaseData.subtype] = {}
			end
			table.insert(equipPosTable[equipTable[id].BaseData.subtype], id)
			if equipQualityTable[equipTable[id].BaseData.quality] == nil then
				equipQualityTable[equipTable[id].BaseData.quality] = {}
			end
			table.insert(equipQualityTable[equipTable[id].BaseData.quality], id)	
		end
	end
	for i, v in pairs(equipTable) do
		if tonumber(v.EquipData.NeedEquip) > 0 then
			equipTable[tonumber(v.EquipData.NeedEquip)].Next = i
		end
	end

	materialTable = {}
	data = TableMgr:GetItemDataByType(Common_pb.ItemType_NewMaterial,1)--TableMgr:GetMaterialTable()
	for _, mv in pairs(data) do
		local _data = mv
		local id = _data.id
		materialTable[id] = {}
		--materialTable[id].data = _data
		materialTable[id].BaseData = TableMgr:GetItemData(id)
	end
	--[[for i, v in pairs(materialTable) do
		if tonumber(v.data.Item) > 0 then
			materialTable[tonumber(v.data.Item)].Next = i
		end
	end]]

	armouryTable = {}
	data = TableMgr:GetArmouryData()
	for _ , av in pairs(data) do
		local _data = av
		local id = _data.BuildLevel
		armouryTable[id] = {}
		armouryTable[id].data = _data
	end

	AttributeBonus.RegisterAttBonusModule(_M)
end

RefreshList = function()
	equiplist = {}
	materiallist = {}
	equipedlist = {}
	local data = ItemListData.GetData()
	for i, v in ipairs(data) do
		local itemdata = TableMgr:GetItemData(v.baseid)
		if itemdata ~= nil then
			if itemdata.type == Common_pb.ItemType_NewEquip then
				local item = {}
				item.data = v
				item.BaseData = itemdata
				item.BaseBonus = equipTable[v.baseid].BaseBonus
				item.EquipData = equipTable[v.baseid].EquipData
				table.insert(equiplist, item)
				if v.parent.pos > 0 then
					table.insert(equipedlist, v.baseid)
				end
			elseif itemdata.type == Common_pb.ItemType_NewMaterial then
				local item = {}
				item.data = v
				item.BaseData = itemdata
				table.insert(materiallist, item)
			end
		end
	end
	table.sort(equiplist, function(a,b) return a.data.baseid < b.data.baseid end)
	table.sort(materiallist, function(a,b) return a.data.baseid < b.data.baseid end)
	NotifyListener()
end



function RequestWearEquip(uid, pos, callback)
	local req = ItemMsg_pb.MsgWearEquipRequest()
	req.uid = uid
	req.pos = pos
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgWearEquipRequest, req, ItemMsg_pb.MsgWearEquipResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            MainCityUI.UpdateRewardData(msg.fresh)
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function RequestTakeoffEquip(uid, callback)
	local req = ItemMsg_pb.MsgTakeoffEquipRequest()
	req.uid = uid
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgTakeoffEquipRequest, req, ItemMsg_pb.MsgTakeoffEquipResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            MainCityUI.UpdateRewardData(msg.fresh)
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function RequestForgeEquip(uid, targetBaseId, buy, callback)
	local req = ItemMsg_pb.MsgForgeEquipRequest()
	req.uid = uid
	req.targetBaseId = targetBaseId
	req.buy = buy
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgForgeEquipRequest, req, ItemMsg_pb.MsgForgeEquipResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
        	FloatText.Show(TextMgr:GetText("equip_forge_start") , Color.white)
            MainCityUI.UpdateRewardData(msg.fresh)
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

local function ShowReward(reward)
	Global.ShowReward(reward)
end

function RequestDecomposeEquip(uid, callback)
	local req = ItemMsg_pb.MsgDecomposeEquipRequest()
	req.uid = uid
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgDecomposeEquipRequest, req, ItemMsg_pb.MsgDecomposeEquipResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            MainCityUI.UpdateRewardData(msg.fresh)
            ShowReward(msg.reward)
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function RequestComposeMaterial(targetBaseId, count, callback)
	local req = ItemMsg_pb.MsgComposeMaterialRequest()
	req.targetBaseId = targetBaseId
	req.count = count
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgComposeMaterialRequest, req, ItemMsg_pb.MsgComposeMaterialResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            MainCityUI.UpdateRewardData(msg.fresh)
            ShowReward(msg.reward)
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function RequestDecomposeMaterial(uid, callback)
	local req = ItemMsg_pb.MsgDecomposeMaterialRequest()
	req.uid = uid
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgDecomposeMaterialRequest, req, ItemMsg_pb.MsgDecomposeMaterialResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            MainCityUI.UpdateRewardData(msg.fresh)
            ShowReward(msg.reward)
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function RequestAccelForgeEquip()
	local req = ItemMsg_pb.MsgAccelForgeEquipRequest()
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgAccelForgeEquipRequest, req, ItemMsg_pb.MsgAccelForgeEquipResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            MainCityUI.UpdateRewardData(msg.fresh)
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function RequestCancelForgeEquip()
	local req = ItemMsg_pb.MsgCancelForgeEquipRequest()
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgCancelForgeEquipRequest, req, ItemMsg_pb.MsgCancelForgeEquipResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
        	FloatText.Show(TextMgr:GetText("equip_forge_cancel") , Color.white)
            MainCityUI.UpdateRewardData(msg.fresh)
            if callback ~= nil then
            	callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function SetBtnEnable(btn, enabled, spriteName)
	if enabled then
		btn:GetComponent("UISprite").spriteName = spriteName
		btn:GetComponent("UIButton").normalSprite = spriteName
	else
		btn:GetComponent("UISprite").spriteName = "btn_4"
		btn:GetComponent("UIButton").normalSprite = "btn_4"
	end
	--btn:GetComponent("BoxCollider").enabled = enabled
end

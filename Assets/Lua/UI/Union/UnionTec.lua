module("UnionTec", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String

local _ui
local timer = 0
local currentId
local endlesslist

local baseTable
local baseIdTable
local coordinateTable
local timeList
local recommendedTechData
local recommendedRow

local function CloseSelf()
	Global.CloseUI(_M)
end

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	for i, v in ipairs(itemlist) do
		if go == v then
			local itemdata = TableMgr:GetItemData(tonumber(go.name))
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
		    else
		        if itemTipTarget == go then
		            Tooltip.HideItemTip()
		        else
		            itemTipTarget = go
		            Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
		        end
		    end
		    return
		end
	end
	Tooltip.HideItemTip()
end

local sname = {"wenhao01", "icon_gold", "icon_resource1", "icon_resource2", "icon_resource3", "icon_resource4"}

local LinkTag = {
	{1,1},
	{2,3},
	{4,5},
	{6,6},
	{1,2},
	{3,4},
	{5,6},
}

local function MakeTags(source, target, tags)
	if source == nil or target == nil then
		return false
	end
	local sx = source.Coord.x
	local tx = target.Coord.x
	local st = LinkTag[sx]
	local tt = LinkTag[tx]
	local needpoint = false
	if st[1] == st[2] and tt[1] == tt[2] and st[1] == tt[2] then
		
	elseif st[1] >= tt[2] then
		for i = tt[2], st[1] do
			tags[i] = true
		end
		needpoint = true
	elseif tt[1] >= st[2] then
		for i = st[2], tt[1] do
			tags[i] = true
		end
		needpoint = true
	end
	return needpoint
end

local function MakeConnect()
	for i, v in pairs(coordinateTable) do
		for ii, vv in pairs(v.datas) do
			local needpoint = false
			for iii, vvv in pairs(vv.BaseData.Condition) do
				local n = MakeTags(baseTable[vvv.id], vv, coordinateTable[i - 1].tags)
				needpoint = needpoint or n
			end
			vv.needpointup = needpoint
			if coordinateTable[i - 1] ~= nil then
				for iii, vvv in pairs(coordinateTable[i - 1].datas) do
					vvv.needpointdown = needpoint
				end
			end
		end
	end
end

function MakeBaseTable()
	if baseTable ~= nil then
		return
	end
	baseTable = {}
	baseIdTable = {}
	coordinateTable = {}
	local data = TableMgr:GetUnionTechDetailTable()
	for _ ,v in pairs(data) do
		local _data = v
		if baseTable[_data.TechId] == nil then
			baseTable[_data.TechId] = {}
			baseIdTable[_data.TechId] = baseTable[_data.TechId]
		end
		baseTable[_data.TechId][_data.Level] = _data
		baseTable[_data.TechId][_data.Level].Condition = {}
		if _data.UnlockCondition ~= "NA" then
			local t = string.split(_data.UnlockCondition,';')
			for i = 1, #(t) do
				local cond = string.split(t[i],':')
				local cc = {}
				cc.id = tonumber(cond[1])
				cc.value = tonumber(cond[2])
				table.insert(baseTable[_data.TechId][_data.Level].Condition, cc)
			end
		end
		if _data.Level == 1 then
			baseTable[_data.TechId].BaseData = baseTable[_data.TechId][_data.Level]
			
			local cot = string.split(_data.Coordinate,';')
			local x,y = tonumber(cot[2]), tonumber(cot[1])
			baseTable[_data.TechId].Coord = {}
			baseTable[_data.TechId].Coord.x = x
			baseTable[_data.TechId].Coord.y = y
			if cot[3] == nil then
				baseTable[_data.TechId].Coord.e = false
			else
				if tonumber(cot[3]) == 1 then
					baseTable[_data.TechId].Coord.e = true
				else
					baseTable[_data.TechId].Coord.e = false
				end
			end
			if coordinateTable[y] == nil then
				coordinateTable[y] = {}
				coordinateTable[y].tags = {false, false, false, false, false, false}
				coordinateTable[y].datas = {}
			end
			coordinateTable[y].datas[x] = baseTable[_data.TechId]
		end
	end
	
	--[[local iter = data:GetEnumerator()
	while iter:MoveNext() do
		local _data = iter.Current.Value
		if baseTable[_data.TechId] == nil then
			baseTable[_data.TechId] = {}
			baseIdTable[_data.TechId] = baseTable[_data.TechId]
		end
		baseTable[_data.TechId][_data.Level] = _data
		baseTable[_data.TechId][_data.Level].Condition = {}
		if _data.UnlockCondition ~= "NA" then
			local t = string.split(_data.UnlockCondition,';')
			for i = 1, #(t) do
				local cond = string.split(t[i],':')
				local cc = {}
				cc.id = tonumber(cond[1])
				cc.value = tonumber(cond[2])
				table.insert(baseTable[_data.TechId][_data.Level].Condition, cc)
			end
		end
		if _data.Level == 1 then
			baseTable[_data.TechId].BaseData = baseTable[_data.TechId][_data.Level]
			local cot = string.split(_data.Coordinate,';')
			local x,y = tonumber(cot[2]), tonumber(cot[1])
			baseTable[_data.TechId].Coord = {}
			baseTable[_data.TechId].Coord.x = x
			baseTable[_data.TechId].Coord.y = y
			if cot[3] == nil then
				baseTable[_data.TechId].Coord.e = false
			else
				if tonumber(cot[3]) == 1 then
					baseTable[_data.TechId].Coord.e = true
				else
					baseTable[_data.TechId].Coord.e = false
				end
			end
			if coordinateTable[y] == nil then
				coordinateTable[y] = {}
				coordinateTable[y].tags = {false, false, false, false, false, false}
				coordinateTable[y].datas = {}
			end
			coordinateTable[y].datas[x] = baseTable[_data.TechId]
		end
	end]]
	for i, vi in pairs(baseIdTable) do
		if vi.BaseData ~= nil then
			for ii, vv in ipairs(vi.BaseData.Condition) do
				baseIdTable[vv.id].unlocknext = vv.value
			end
		end
	end
	MakeConnect()
	AttributeBonus.RegisterAttBonusModule(_M)
end

function CalAttributeBonus()
    if baseIdTable == nil then 
       return
    end
    local bonus = {}
    table.foreach(baseIdTable ,function(i,v)
    	if v.BaseData ~= nil then
	    	local level = UnionTechData.GetUnionTechById(v.BaseData.TechId).level
	        if level ~= 0 then
		        local b = {}
		        local t = string.split(v[level].ArmyType,';')  
		        for j=1,#(t) do
			        if t[j] ~= nil then 
			            local b = {}
			            b.BonusType =tonumber(t[j])
			            b.Attype =  v[level].AttrType
			            b.Value =  v[level].Value
			            b.Global = 1
			            table.insert(bonus,b)
		            end
		        end
	        end
	    end
    end)
    return bonus
end

function GetHasedTech()
	if baseIdTable == nil then 
		return
	end
	local _list = {}
	table.foreach(baseIdTable ,function(i,v)
    	if v.BaseData ~= nil then
	    	local level = UnionTechData.GetUnionTechById(v.BaseData.TechId).level
	        if level ~= 0 then
		        local _data = baseIdTable[v.BaseData.TechId][level]
				if _data == nil then
					_data = baseIdTable[v.BaseData.TechId].BaseData
				end
				table.insert(_list, _data)
	        end
	    end
	end)
	return _list
end

function GetUnionTechByID(id)
	return baseIdTable[id]
end

local function CheckState(itemdata)
	local level = UnionTechData.GetUnionTechById(itemdata.BaseData.TechId).level
	local _data = baseIdTable[itemdata.BaseData.TechId][level]
	if _data == nil then
		_data = itemdata.BaseData
	end
	local conditions = true
	for i, v in ipairs(_data.Condition) do
		if UnionTechData.GetUnionTechById(v.id).level < v.value then
			conditions = false
		end
	end
	if conditions then
		return 1
	elseif level > 0 then
		return 2
	else
		return 3
	end
end

local function SetLineByY(y, bool)
	local root = _ui.tech.grid.transform:Find(tostring(y))
	if root ~= nil then
		for i = 1, 6 do
			root:Find(String.Format("bg_line_horizonal_{0}/line_horizonal", i)).gameObject:SetActive(bool)
		end
	end
end

local function SetUpLine(itemtrans, bool)
	local root = itemtrans.parent
	root:Find("bg_point/bg_point_top/icon_point_top").gameObject:SetActive(bool)
	root:Find("bg_line/bg_line_top/line_vertical_top").gameObject:SetActive(bool)
end

local function SetDownLine(itemtrans, bool)
	local root = itemtrans.parent
	root:Find("bg_point/bg_point_bottom/icon_point_bottom").gameObject:SetActive(bool)
	root:Find("bg_line/bg_line_bottom/line_vertical_bottom").gameObject:SetActive(bool)
end

local function ShowItemNotEnough(id)
    if id == 2 then
        Global.ShowNoEnoughMoney()
    else
        local itemdata = TableMgr:GetItemData(id)
        MessageBox.Show(String.Format(TextMgr:GetText("union_tec36"),TextUtil.GetItemName(itemdata)), function()
            MainCityUI.UseResItem(id)
        end, function() end)
    end
end

local function ShowUpgrade(_id)
	currentId = _id
	local techdata = UnionTechData.GetUnionTechById(currentId)
	local level = techdata.level
	local _data = baseIdTable[currentId][level]
	local _nextdata = baseIdTable[currentId][level + 1]
	local needenergy = _nextdata ~= nil and _nextdata.Energy or 0
	if _data == nil then
		_data = baseIdTable[currentId].BaseData
	end
	local state = CheckState(baseIdTable[currentId])
	_ui.tech.upgrade_infotext.text = TextMgr:GetText(_data.Dese)
	_ui.tech.upgrade.gameObject:SetActive(true)
	_ui.tech.upgrade_tecture.mainTexture = ResourceLibrary:GetIcon("Icon/UnionTec/", _data.Icon)
	_ui.tech.upgrade_name.text = TextMgr:GetText(_data.Name)
	_ui.tech.upgrade_bg_level_slider.value = level / _data.MaxLevel
	_ui.tech.upgrade_bg_level_text.text = level .. "/" .. _data.MaxLevel
	if level < _data.MaxLevel then
		_ui.tech.upgrade_bg_level_slider.transform:GetComponent("UISprite").spriteName = "proceed_array"
	else
		_ui.tech.upgrade_bg_level_slider.transform:GetComponent("UISprite").spriteName = "bar_array3"
	end
	if techdata.status == 1 then
		_ui.tech.upgrade_upgrading:SetActive(true)
		_ui.tech.upgrade_shengjijindu:SetActive(true)
		_ui.tech.upgrade_nextlevel:SetActive(true)
		_ui.tech.upgrade_maxlevel:SetActive(false)
		_ui.tech.upgrade_nextlevel1.text = level > 0 and _data.NumberShow or 0
		_ui.tech.upgrade_nextlevel2.text = baseIdTable[currentId][level + 1].NumberShow
		local leftTime = techdata.completeTime - Serclimax.GameTime.GetSecTime()
		_ui.tech.upgrade_shengjislider.value = 1 - (leftTime / baseIdTable[currentId][level + 1].CostTime)
		_ui.tech.upgrade_shengjilabel.text = Serclimax.GameTime.SecondToString3(leftTime)
		CountDown.Instance:Add("UnionTec",techdata.completeTime,CountDown.CountDownCallBack(function(t)
			if _ui == nil then
				CountDown.Instance:Remove("UnionTec")
				return
			end
			local leftTime = techdata.completeTime - Serclimax.GameTime.GetSecTime()
			_ui.tech.upgrade_shengjislider.value = 1 - (leftTime / baseIdTable[currentId][level + 1].CostTime)
			_ui.tech.upgrade_shengjilabel.text = t
		end))
		_ui.tech.upgrade_manji:SetActive(false)
	else
		if level < _data.MaxLevel then
			_ui.tech.upgrade_nextlevel:SetActive(true)
			_ui.tech.upgrade_maxlevel:SetActive(false)
			_ui.tech.upgrade_upgrading:SetActive(false)
			_ui.tech.upgrade_nextlevel1.text = level > 0 and _data.NumberShow or 0
			_ui.tech.upgrade_nextlevel2.text = baseIdTable[currentId][level + 1].NumberShow
			_ui.tech.upgrade_shengjijindu:SetActive(false)
			_ui.tech.upgrade_manji:SetActive(false)
		else
			_ui.tech.upgrade_nextlevel:SetActive(false)
			_ui.tech.upgrade_maxlevel:SetActive(true)
			_ui.tech.upgrade_maxlevel1.text = baseIdTable[currentId][level].NumberShow
			_ui.tech.upgrade_upgrading:SetActive(false)
			_ui.tech.upgrade_shengjijindu:SetActive(false)
			_ui.tech.upgrade_manji:SetActive(true)
		end
	end
	_ui.tech.upgrade_costtext.gameObject:SetActive(techdata.status ~= 1 and level < _data.MaxLevel)
	_ui.tech.upgrade_timetext.gameObject:SetActive(techdata.status ~= 1 and level < _data.MaxLevel)
	local currentenergy = UnionInfoData.GetCoin()
	_ui.tech.upgrade_costtext.text = String.Format(TextMgr:GetText("Union_tec_capital"), currentenergy >= needenergy and (currentenergy .. "/" .. (needenergy > 0 and needenergy or "--")) or ("[ff0000]" .. currentenergy .. "[-]/" .. (needenergy > 0 and needenergy or "--")))
    if level < _data.MaxLevel then
        _ui.tech.upgrade_timetext.text = String.Format(TextMgr:GetText("Union_tec_time"), Serclimax.GameTime.SecondToString3(baseIdTable[currentId][level + 1].CostTime))
    else
        _ui.tech.upgrade_timetext.text = String.Format(TextMgr:GetText("Union_tec_time"), Serclimax.GameTime.SecondToString3(_data.CostTime))
    end

	if state == 1 then
		_ui.tech.upgrade_bg_list.gameObject:SetActive(true)
		_ui.tech.upgrade_bg_list_hui.gameObject:SetActive(false)
		_ui.tech.upgrade_name.gradientTop = Color.white
		_ui.tech.upgrade_name.gradientBottom = Color.white
		_ui.tech.upgrade_tecture.color = Color.white
		_ui.tech.upgrade_bg_level_text.gradientTop = Color.white
		_ui.tech.upgrade_bg_level_text.gradientBottom = Color.white
		_ui.tech.upgrade_bg_level.gameObject:SetActive(true)
		_ui.tech.upgrade_icon_suo.gameObject:SetActive(false)
		_ui.tech.upgrade_icon_cha.gameObject:SetActive(false)
	elseif state == 2 then
		_ui.tech.upgrade_bg_list.gameObject:SetActive(true)
		_ui.tech.upgrade_bg_list_hui.gameObject:SetActive(false)
		_ui.tech.upgrade_name.gradientTop = Color.white
		_ui.tech.upgrade_name.gradientBottom = Color.white
		_ui.tech.upgrade_tecture.color = Color.white
		_ui.tech.upgrade_bg_level_text.gradientTop = Color.white
		_ui.tech.upgrade_bg_level_text.gradientBottom = Color.white
		_ui.tech.upgrade_bg_level.gameObject:SetActive(true)
		_ui.tech.upgrade_icon_suo.gameObject:SetActive(false)
		_ui.tech.upgrade_icon_cha.gameObject:SetActive(true)
	elseif state == 3 then
		_ui.tech.upgrade_bg_list.gameObject:SetActive(false)
		_ui.tech.upgrade_bg_list_hui.gameObject:SetActive(true)
		_ui.tech.upgrade_name.gradientTop = Color.gray
		_ui.tech.upgrade_name.gradientBottom = Color.gray
		_ui.tech.upgrade_tecture.color = Color.black
		_ui.tech.upgrade_bg_level_text.gradientTop = Color.gray
		_ui.tech.upgrade_bg_level_text.gradientBottom = Color.gray
		_ui.tech.upgrade_bg_level.gameObject:SetActive(false)
		_ui.tech.upgrade_icon_suo.gameObject:SetActive(true)
		_ui.tech.upgrade_icon_cha.gameObject:SetActive(false)
	end
	local hasPrivilege = UnionInfoData.HasPrivilege(GuildMsg_pb.PrivilegeType_UpgradeTech)
	print(state, techdata.status, hasPrivilege)
	if state == 3 then
		_ui.tech.upgrade_locked:SetActive(true)
		_ui.tech.upgrade_button:SetActive(false)
		_ui.tech.upgrade_no_permission:SetActive(false)
		_ui.tech.upgrade_other_in_development:SetActive(false)
		_ui.tech.upgrade_button_cancel:SetActive(false)
		_ui.tech.upgrade_in_development:SetActive(false)
	else
		_ui.tech.upgrade_locked:SetActive(false)
		if UnionTechData.IsUpgrading() then
			_ui.tech.upgrade_button:SetActive(false)
			_ui.tech.upgrade_no_permission:SetActive(false)
			_ui.tech.upgrade_other_in_development:SetActive(techdata.status ~= 1)
			_ui.tech.upgrade_button_cancel:SetActive(techdata.status == 1 and hasPrivilege)
			_ui.tech.upgrade_in_development:SetActive(techdata.status == 1 and not hasPrivilege)
		else
			_ui.tech.upgrade_button:SetActive(hasPrivilege)
			_ui.tech.upgrade_no_permission:SetActive(not hasPrivilege)
			_ui.tech.upgrade_other_in_development:SetActive(false)
			_ui.tech.upgrade_button_cancel:SetActive(false)
			_ui.tech.upgrade_in_development:SetActive(false)
		end
	end
	if level == _data.MaxLevel then
		_ui.tech.upgrade_locked:SetActive(false)
		_ui.tech.upgrade_button:SetActive(false)
		_ui.tech.upgrade_no_permission:SetActive(false)
		_ui.tech.upgrade_other_in_development:SetActive(false)
		_ui.tech.upgrade_button_cancel:SetActive(false)
		_ui.tech.upgrade_in_development:SetActive(false)
	end
end

local function CloseUpgrade()
	_ui.tech.upgrade.gameObject:SetActive(false)
	CountDown.Instance:Remove("UnionTec")
	CountDown.Instance:Remove("UnionTecCD")
end

local function MakeItemData(itemtrans, itemdata, y)
	local bg_list = itemtrans:Find("bg_list")
	local bg_list_hui = itemtrans:Find("bg_list_hui")
	local bg_name = itemtrans:Find("bg_title/text"):GetComponent("UILabel")
	local bg_texture = itemtrans:Find("Texture"):GetComponent("UITexture")
	local bg_level = itemtrans:Find("bg_level")
	local bg_level_slider = bg_level:Find("array"):GetComponent("UISlider")
	local bg_percent_text = bg_level:Find("array/percentage"):GetComponent("UILabel")
	bg_percent_text.gameObject:SetActive(false)
	local bg_level_text = itemtrans:Find("text"):GetComponent("UILabel")
	local icon_suo = itemtrans:Find("icon_suo")
	local icon_cha = itemtrans:Find("icon_cha")
	local upgrading = itemtrans:Find("Label").gameObject
	local recommendObject = itemtrans:Find("Reco").gameObject
	local techdata = UnionTechData.GetUnionTechById(itemdata.BaseData.TechId)
	recommendObject:SetActive(recommendedTechData == techdata)
	if recommendedTechData == techdata then
	    recommendedRow = y
    end
	if itemdata.unlocknext ~= nil then
		itemtrans:Find("Level"):GetComponent("UILabel").text = "Lv" .. itemdata.unlocknext
	else
		itemtrans:Find("Level"):GetComponent("UILabel").text = ""
	end
	if techdata.status == 1 then
		upgrading:SetActive(true)
	else
		upgrading:SetActive(false)
	end
	local level = techdata.level
	local _data = baseIdTable[itemdata.BaseData.TechId][level]
	if _data == nil then
		_data = itemdata.BaseData
	end
	bg_name.text = TextMgr:GetText(_data.Name)
	bg_texture.mainTexture = ResourceLibrary:GetIcon("Icon/UnionTec/", _data.Icon)
	bg_texture.shader = UnityEngine.Shader.Find("Unlit/Transparent Colored Gray")
	bg_level_slider.value = level / _data.MaxLevel
	bg_level_text.text = "Lv."..level .. "/" .. _data.MaxLevel
	if level < _data.MaxLevel then
        --[[if techdata.status == GuildMsg_pb.GuildTechStaus_Donate then
	        bg_level_slider.transform:GetComponent("UISprite").spriteName = "bar_array_blue"
	        local percentage = techdata.energy / baseIdTable[itemdata.BaseData.TechId][level + 1].Energy
            bg_level_slider.value = percentage
            bg_percent_text.text = string.format("%d%%", percentage * 100)
            bg_percent_text.gameObject:SetActive(percentage > 0)
        else]]
			bg_level_slider.transform:GetComponent("UISprite").spriteName = "proceed_array"
            --bg_percent_text.gameObject:SetActive(false)
            --table.insert(timeList, {slider = bg_level_slider, label = bg_percent_text, completeTime = techdata.completeTime, costTime = baseIdTable[itemdata.BaseData.TechId][level + 1].CostTime})
        --end
	else
	    --bg_percent_text.gameObject:SetActive(true)
		bg_level_slider.transform:GetComponent("UISprite").spriteName = "bar_array3"
        bg_level_slider.value = 1
        --bg_percent_text.text = TextMgr:GetText(Text.ui_maximize)
	end
	local state = CheckState(itemdata)
	if state == 1 then
		bg_list.gameObject:SetActive(true)
		bg_list_hui.gameObject:SetActive(false)
		bg_name.gradientTop = Color.white
		bg_name.gradientBottom = Color.white
		bg_texture.color = Color.white
		bg_level_text.gradientTop = Color.white
		bg_level_text.gradientBottom = Color.white
		bg_level.gameObject:SetActive(true)
		icon_suo.gameObject:SetActive(false)
		icon_cha.gameObject:SetActive(false)
	elseif state == 2 then
		bg_list.gameObject:SetActive(true)
		bg_list_hui.gameObject:SetActive(false)
		bg_name.gradientTop = Color.white
		bg_name.gradientBottom = Color.white
		bg_texture.color = Color.white
		bg_level_text.gradientTop = Color.white
		bg_level_text.gradientBottom = Color.white
		bg_level.gameObject:SetActive(true)
		icon_suo.gameObject:SetActive(false)
		icon_cha.gameObject:SetActive(true)
	elseif state == 3 then
		bg_list.gameObject:SetActive(false)
		bg_list_hui.gameObject:SetActive(true)
		bg_name.gradientTop = Color.gray
		bg_name.gradientBottom = Color.gray
		bg_texture.color = Color.black
		bg_level_text.gradientTop = Color.gray
		bg_level_text.gradientBottom = Color.gray
		bg_level.gameObject:SetActive(false)
		icon_suo.gameObject:SetActive(true)
		icon_cha.gameObject:SetActive(false)
	end
	if state == 3 then
		SetLineByY(y - 1, false)
		SetUpLine(itemtrans, false)
		SetDownLine(itemtrans, false)
	else
		SetLineByY(y - 1, true)
		SetUpLine(itemtrans, true)
		if itemdata.unlocknext ~= nil then
			SetDownLine(itemtrans, level >= itemdata.unlocknext)
		end
	end
	SetClickCallback(itemtrans.gameObject, function()
		ShowUpgrade(itemdata.BaseData.TechId)
	end)
end

local function UpdateTime()
    local serverTime = Serclimax.GameTime.GetSecTime()
    for _, v in ipairs(timeList) do
        local leftTime = v.completeTime - serverTime
        local percentage = 1 - leftTime / v.costTime 
        v.slider.value = percentage
        v.label.text = Global.GetLeftCooldownTextLong(v.completeTime)
    end
end

local function UpdateUI(needreposition)
    recommendedTechData = UnionTechData.GetRecommendedTechData()
    recommendedRow = 1
    timeList = {}
	local _coordinate = coordinateTable
	local finishindex
	for i, v in pairs(_coordinate) do
		local item = _ui.tech.grid.transform:Find(tostring(i))
		if item == nil then
			item = NGUITools.AddChild(_ui.tech.grid.gameObject, _ui.tech.item.gameObject).transform
			item.name = i
		end
		item.gameObject:SetActive(true)
		for ii, vv in pairs(v.tags) do
			item:Find("bg_line_horizonal_" .. ii).gameObject:SetActive(vv)
		end
		for ii = 1, 7 do
			local _item = item:Find(tostring(ii))
			if v.datas[ii] == nil then
				_item.gameObject:SetActive(false)
			else
				_item.gameObject:SetActive(true)
				_item:Find("bg_point/bg_point_top").gameObject:SetActive(v.datas[ii].needpointup)
				_item:Find("bg_point/bg_point_bottom").gameObject:SetActive(v.datas[ii].needpointdown)
				if i == 1 then
					_item:Find("bg_line/bg_line_top").gameObject:SetActive(false)
					_item:Find("bg_point/bg_point_top").gameObject:SetActive(false)
				end
				if v.datas[ii].Coord.e then
					_item:Find("bg_line/bg_line_bottom").gameObject:SetActive(false)
					_item:Find("bg_point/bg_point_bottom").gameObject:SetActive(false)
				end
				local item_info = _item:Find("Laboratoryitem")
				MakeItemData(item_info, v.datas[ii], i)
			end
		end
		finishindex = i
	end
	local childCount = _ui.tech.grid.transform.childCount
	for i = finishindex, childCount - 1 do
		_ui.tech.grid.transform:GetChild(i).gameObject:SetActive(false)
	end
	coroutine.start(function()
		coroutine.step()
		if _ui == nil then
		    return
        end
		_ui.tech.grid:Reposition()
		if needreposition then
            if recommendedRow > 1 then
                _ui.tech.scroll:MoveRelative(Vector3(0, 236 * (recommendedRow - 1), 0))
            else
                _ui.tech.scroll:ResetPosition()
            end
		end
	end)
	if _ui.tech.upgrade.gameObject.activeInHierarchy and currentId ~= nil then
		ShowUpgrade(currentId)
	end

	UpdateTime()
end

local function MakeRewardItem(_item, _data)
	_item.name = _data.id
	local itemdata = TableMgr:GetItemData(_data.id)
	_item:Find("icon_item"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", itemdata.icon)
	if _data.num ~= nil and _data.num > 1 then
		local num_item = _item:Find("num_item")
		num_item.gameObject:SetActive(true)
		num_item:GetComponent("UILabel").text = _data.num
		num_item = nil
	else
		local num_item = _item:Find("num_item")
		num_item.gameObject:SetActive(false)
	end
	_item:GetComponent("UISprite").spriteName = "bg_item" .. itemdata.quality
	local itemlvTrf = _item.transform:Find("bg_num")
	local itemlv = itemlvTrf:Find("txt_num"):GetComponent("UILabel")
	itemlvTrf.gameObject:SetActive(true)
	if itemdata.showType == 1 then
		itemlv.text = Global.ExchangeValue2(itemdata.itemlevel)
	elseif itemdata.showType == 2 then
		itemlv.text = Global.ExchangeValue1(itemdata.itemlevel)
	elseif itemdata.showType == 3 then
		itemlv.text = Global.ExchangeValue3(itemdata.itemlevel)
	else 
		itemlvTrf.gameObject:SetActive(false)
	end
	table.insert(itemlist, _item.gameObject)
	itemlvTrf = nil
	itemlv = nil
	itemdata = nil
end

local function UpdateReward(msg)
	if _ui == nil then
		return
	end
	local daily = msg.dailyPrize
	local weekly = msg.weeklyPrize
	_ui.reward.daily_tip.text = String.Format(TextMgr:GetText("union_tec15"), daily.leastEnergy)
	for i, v in ipairs(daily.rewards) do
		local grid = transform:Find(String.Format("background widget/bg2/content 2/left/mid/term ({0})/Grid", i)):GetComponent("UIGrid")
		for ii, vv in ipairs(v.rewardInfo.items) do
			local item = NGUITools.AddChild(grid.gameObject, _ui.reward.item.gameObject).transform
			item.localScale = _ui.reward.item.transform.localScale
			item.gameObject:SetActive(true)
			MakeRewardItem(item, vv)
		end
		grid:Reposition()
	end
	local leftTime = daily.endTime - Serclimax.GameTime.GetSecTime()
	_ui.reward.daily_time.text = Serclimax.GameTime.SecondToString3(leftTime)
	CountDown.Instance:Add("UnionTecDaily",daily.endTime,CountDown.CountDownCallBack(function(t)
		local leftTime = daily.endTime - Serclimax.GameTime.GetSecTime()
		_ui.reward.daily_time.text = t
	end))
	_ui.reward.Weekly_tip.text = String.Format(TextMgr:GetText("union_tec15"), weekly.leastEnergy)
	for i, v in ipairs(weekly.rewards) do
		local grid = transform:Find(String.Format("background widget/bg2/content 2/right/mid/term ({0})/Grid", i)):GetComponent("UIGrid")
		for ii, vv in ipairs(v.rewardInfo.items) do
			local item = NGUITools.AddChild(grid.gameObject, _ui.reward.item.gameObject).transform
			item.localScale = _ui.reward.item.transform.localScale
			item.gameObject:SetActive(true)
			MakeRewardItem(item, vv)
		end
		grid:Reposition()
	end
	local leftTime = weekly.endTime - Serclimax.GameTime.GetSecTime()
	_ui.reward.Weekly_time.text = Serclimax.GameTime.SecondToString3(leftTime)
	CountDown.Instance:Add("UnionTecWeekly",weekly.endTime,CountDown.CountDownCallBack(function(t)
		local leftTime = weekly.endTime - Serclimax.GameTime.GetSecTime()
		_ui.reward.Weekly_time.text = t
	end))
end

local function MakeScoreString(value)
	local s = tostring(value)
	local n = math.floor((#s - 1) / 3)
	for i = n, 1, -1 do
		s = string.sub(s, 0, -3 * i - 1) .. "," .. string.sub(s, -3 * i)
	end
	return s
end

local function UpdateRank(data)
	if _ui == nil then
		return
	end
	local myindex = 0
	local mycharid = MainData.GetCharId()
	for i, v in ipairs(data.rankList) do
		if v.charId == mycharid then
			myindex = v.rank
		end
	end
	if endlesslist == nil then
		endlesslist = EndlessList(_ui.rank.scroll)
	end
	endlesslist:SetItem(_ui.rank.item, #data.rankList, function(prefab, index)
		local rankdata = data.rankList[index]
		prefab.transform:Find("no.1").gameObject:SetActive(index == 1)
		prefab.transform:Find("no.2").gameObject:SetActive(index == 2)
		prefab.transform:Find("no.3").gameObject:SetActive(index == 3)
		prefab.transform:Find("no.4").gameObject:SetActive(index >= 4)
		prefab.transform:Find("no.4"):GetComponent("UILabel").text = index
		prefab.transform:Find("name"):GetComponent("UILabel").text = rankdata.name
		prefab.transform:Find("number"):GetComponent("UILabel").text = MakeScoreString(rankdata.energy)
		local back = prefab.transform:Find("Sprite")
		back:GetComponent("UISprite").spriteName = "bg_list"
		if rankdata.charId == mycharid then
			back.gameObject:SetActive(true)
			back:GetComponent("UISprite").spriteName = "bg_list_select"
		elseif index % 2 == 0 then
			back.gameObject:SetActive(true)
		else
			back.gameObject:SetActive(false)
		end
	end)
	coroutine.start(function()
		coroutine.step()
		endlesslist:MoveTo(myindex)
	end)
end

function Awake()
	_ui = {}
	_ui.maxGold = 0
	_ui.container = transform:Find("mask").gameObject
	_ui.btn_close = transform:Find("background widget/close btn").gameObject
	_ui.page1 = transform:Find("background widget/bg2/page1"):GetComponent("UIToggle")
	_ui.page2 = transform:Find("background widget/bg2/page2"):GetComponent("UIToggle")
	_ui.page3 = transform:Find("background widget/bg2/page3"):GetComponent("UIToggle")
	
	_ui.tech = {}
	_ui.tech.scroll = transform:Find("background widget/bg2/content 1/TechTree"):GetComponent("UIScrollView")
	_ui.tech.grid = transform:Find("background widget/bg2/content 1/TechTree/Grid"):GetComponent("UIGrid")
	_ui.tech.item = transform:Find("background widget/bg2/content 1/TechTree/Tech_item")
	_ui.tech.upgrade = transform:Find("Panel (1)")
	_ui.tech.info = transform:Find("background widget/bg2/content 1/info") 
	
	_ui.tech.upgrade_tecture = transform:Find("Panel (1)/bg/Laboratoryitem/Texture"):GetComponent("UITexture")
	_ui.tech.upgrade_tecture.shader = UnityEngine.Shader.Find("Unlit/Transparent Colored Gray")
	_ui.tech.upgrade_bg_list = transform:Find("Panel (1)/bg/Laboratoryitem/bg_list").gameObject
	_ui.tech.upgrade_bg_list_hui = transform:Find("Panel (1)/bg/Laboratoryitem/bg_list_hui").gameObject
	_ui.tech.upgrade_name = transform:Find("Panel (1)/bg/Laboratoryitem/bg_title/text"):GetComponent("UILabel")
	_ui.tech.upgrade_bg_level = transform:Find("Panel (1)/bg/Laboratoryitem/bg_level")
	_ui.tech.upgrade_bg_level_slider = transform:Find("Panel (1)/bg/Laboratoryitem/bg_level/array"):GetComponent("UISlider")
	_ui.tech.upgrade_bg_level_text = transform:Find("Panel (1)/bg/Laboratoryitem/text"):GetComponent("UILabel")
	_ui.tech.upgrade_icon_suo = transform:Find("Panel (1)/bg/Laboratoryitem/icon_suo")
	_ui.tech.upgrade_icon_cha = transform:Find("Panel (1)/bg/Laboratoryitem/icon_cha")
	_ui.tech.upgrade_infotext = transform:Find("Panel (1)/bg/mid/text"):GetComponent("UILabel")
	_ui.tech.upgrade_nextlevel = transform:Find("Panel (1)/bg/mid/text01").gameObject
	_ui.tech.upgrade_nextlevel1 = transform:Find("Panel (1)/bg/mid/text01/1"):GetComponent("UILabel")
	_ui.tech.upgrade_nextlevel2 = transform:Find("Panel (1)/bg/mid/text01/2"):GetComponent("UILabel")
	_ui.tech.upgrade_maxlevel = transform:Find("Panel (1)/bg/mid/text02").gameObject
	_ui.tech.upgrade_maxlevel1 = transform:Find("Panel (1)/bg/mid/text02/1"):GetComponent("UILabel")
	_ui.tech.upgrade_upgrading = transform:Find("Panel (1)/bg/mid/jindu01/text02").gameObject
	_ui.tech.upgrade_shengjijindu = transform:Find("Panel (1)/bg/mid/jindu01").gameObject
	_ui.tech.upgrade_shengjislider = transform:Find("Panel (1)/bg/mid/jindu01/blue"):GetComponent("UISlider")
	_ui.tech.upgrade_shengjilabel = transform:Find("Panel (1)/bg/mid/jindu01/Label"):GetComponent("UILabel")
	_ui.tech.upgrade_manji = transform:Find("Panel (1)/bg/mid/manji").gameObject
	_ui.tech.upgrade_costtext = transform:Find("Panel (1)/bg/mid/money text"):GetComponent("UILabel")
	_ui.tech.upgrade_timetext = transform:Find("Panel (1)/bg/mid/time text"):GetComponent("UILabel")
	_ui.tech.upgrade_button = transform:Find("Panel (1)/bg/mid/button").gameObject
	_ui.tech.upgrade_button_cancel = transform:Find("Panel (1)/bg/mid/button cancel").gameObject
	_ui.tech.upgrade_no_permission = transform:Find("Panel (1)/bg/mid/no permission").gameObject
	_ui.tech.upgrade_other_in_development = transform:Find("Panel (1)/bg/mid/other in development").gameObject
	_ui.tech.upgrade_in_development = transform:Find("Panel (1)/bg/mid/in development").gameObject
	_ui.tech.upgrade_locked = transform:Find("Panel (1)/bg/mid/unlocked").gameObject
	
	_ui.reward = {}
	_ui.reward.daily_tip = transform:Find("background widget/bg2/content 2/left/top/text"):GetComponent("UILabel")
	_ui.reward.daily_time = transform:Find("background widget/bg2/content 2/left/bottom/time/time (1)"):GetComponent("UILabel")
	_ui.reward.daily_btn = transform:Find("background widget/bg2/content 2/left/bottom/button").gameObject
	_ui.reward.Weekly_tip = transform:Find("background widget/bg2/content 2/right/top/text"):GetComponent("UILabel")
	_ui.reward.Weekly_time = transform:Find("background widget/bg2/content 2/right/bottom/time/time (1)"):GetComponent("UILabel")
	_ui.reward.Weekly_btn = transform:Find("background widget/bg2/content 2/right/bottom/button").gameObject
	_ui.reward.item = transform:Find("background widget/bg2/content 2/listinfo_item0.6")
	
	_ui.rank = {}
	_ui.rank.btn = transform:Find("background widget/bg2/page3").gameObject
	_ui.rank.scroll = transform:Find("background widget/bg2/content 3/Scroll View"):GetComponent("UIScrollView")
	_ui.rank.grid = transform:Find("background widget/bg2/content 3/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.rank.item = transform:Find("background widget/bg2/content 3/Container")
	
	_ui.tech.item.gameObject:SetActive(false)
end

function Start()
	itemlist = {}
	UpdateUI(true)
	_ui.page1:Set(true)
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	SetClickCallback(_ui.tech.upgrade.gameObject, CloseUpgrade)
	UnionTechData.RequestData()
	UnionTechData.RequestDonatePrizeInfo(UpdateReward)
	UnionTechData.AddListener(UpdateUI)
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	SetClickCallback(_ui.reward.daily_btn, function()
		UnionTechData.RequestDonateRankList(1, UnionRank.Show)	
	end)
	SetClickCallback(_ui.reward.Weekly_btn, function()
		UnionTechData.RequestDonateRankList(2, UnionRank.Show)	
	end)
	SetClickCallback(_ui.rank.btn, function()
		UnionTechData.RequestDonateRankList(3, UpdateRank)
	end)
	SetClickCallback(_ui.tech.info.gameObject, function()
        MapHelp.Open(2100, false, nil, nil, true)
	end)
	SetClickCallback(_ui.tech.upgrade_button, function()
		UnionTechData.RequestUpgradeGuildTech(currentId)
        UnionInfoData.RequestData()
	end)
	SetClickCallback(_ui.tech.upgrade_button_cancel, function()
		MessageBox.Show(TextMgr:GetText("Union_Tech_cancel"), function()
			UnionTechData.RequestCancelUpgradeGuildTech(currentId)
            UnionInfoData.RequestData()
		end, function() end)
	end)
end

function LateUpdate()
    if timer >= 0 then
        timer = timer - Serclimax.GameTime.deltaTime
        if timer < 0 then
            timer = 1
            UpdateTime()
        end
    end
end

function Close()
	_ui = nil
	endlesslist = nil
	UnionTechData.RemoveListener(UpdateUI)
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	CountDown.Instance:Remove("UnionTecDaily")
	CountDown.Instance:Remove("UnionTecWeekly")
	if not GUIMgr.Instance:IsMenuOpen("UnionInfo") then
	end
end

function Show()
	Global.OpenUI(_M)
end

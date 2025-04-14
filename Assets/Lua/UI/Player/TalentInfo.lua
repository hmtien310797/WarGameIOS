module("TalentInfo", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String

local _ui

local currentPage = 2
local currentIndex = 1

local baseTable
local baseIdTable
local coordinateTable

local function CloseSelf()
	Global.CloseUI(_M)
end

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	local param = GetParameter(go)
	if param ~= nil then
		local itemdata = baseIdTable[tonumber(param)]
		if not Tooltip.IsItemTipActive() then
		    itemTipTarget = go
			Tooltip.ShowItemTip({name = TextMgr:GetText(itemdata.BaseData.Name), text = TextMgr:GetText(itemdata.BaseData.info)})
	    else
	        if itemTipTarget == go then
	            Tooltip.HideItemTip()
	        else
	            itemTipTarget = go
	            Tooltip.ShowItemTip({name = TextMgr:GetText(itemdata.BaseData.Name), text = TextMgr:GetText(itemdata.BaseData.info)})
	        end
	    end
	else
		Tooltip.HideItemTip()
	end
end

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

local function MakeConnect(CategoryId)
	for i, v in pairs(coordinateTable[CategoryId]) do
		for ii, vv in pairs(v.datas) do
			local needpoint = false
			for iii, vvv in pairs(vv.BaseData.Condition) do
				local n = MakeTags(baseTable[CategoryId][vvv.id], vv, coordinateTable[CategoryId][i - 1].tags)
				needpoint = needpoint or n
			end
			vv.needpointup = needpoint
			if coordinateTable[CategoryId][i - 1] ~= nil then
				for iii, vvv in pairs(coordinateTable[CategoryId][i - 1].datas) do
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
	local data = TableMgr:GetTalentTable()
	for _ , v in pairs(data) do
		local _data = v
		if baseTable[_data.CategoryId] == nil then
			baseTable[_data.CategoryId] = {}
		end
		if coordinateTable[_data.CategoryId] == nil then
			coordinateTable[_data.CategoryId] = {}
		end
		if baseTable[_data.CategoryId][_data.TechId] == nil then
			baseTable[_data.CategoryId][_data.TechId] = {}
			baseIdTable[_data.TechId] = baseTable[_data.CategoryId][_data.TechId]
		end
		baseTable[_data.CategoryId][_data.TechId][_data.Level] = _data
		baseTable[_data.CategoryId][_data.TechId][_data.Level].Condition = {}
		if _data.UnlockCondition ~= "" and _data.UnlockCondition ~= "NA"  then
			local t = string.split(_data.UnlockCondition,';')
			for i = 1, #(t) do
				local cond = string.split(t[i],':')
				local cc = {}
				cc.id = tonumber(cond[1])
				cc.value = tonumber(cond[2])
				table.insert(baseTable[_data.CategoryId][_data.TechId][_data.Level].Condition, cc)
			end
		end
		if _data.Level == 1 then
			baseTable[_data.CategoryId][_data.TechId].BaseData = baseTable[_data.CategoryId][_data.TechId][_data.Level]
			local cot = string.split(_data.Coordinate,';')
			local x,y = tonumber(cot[2]), tonumber(cot[1])
			baseTable[_data.CategoryId][_data.TechId].Coord = {}
			baseTable[_data.CategoryId][_data.TechId].Coord.x = x
			baseTable[_data.CategoryId][_data.TechId].Coord.y = y
			if cot[3] == nil then
				baseTable[_data.CategoryId][_data.TechId].Coord.e = false
			else
				if tonumber(cot[3]) == 1 then
					baseTable[_data.CategoryId][_data.TechId].Coord.e = true
				else
					baseTable[_data.CategoryId][_data.TechId].Coord.e = false
				end
			end
			if coordinateTable[_data.CategoryId][y] == nil then
				coordinateTable[_data.CategoryId][y] = {}
				coordinateTable[_data.CategoryId][y].tags = {false, false, false, false, false, false}
				coordinateTable[_data.CategoryId][y].datas = {}
			end
			coordinateTable[_data.CategoryId][y].datas[x] = baseTable[_data.CategoryId][_data.TechId]
		end
	end
	
	--[[local iter = data:GetEnumerator()
	while iter:MoveNext() do
		local _data = iter.Current.Value
		if baseTable[_data.CategoryId] == nil then
			baseTable[_data.CategoryId] = {}
		end
		if coordinateTable[_data.CategoryId] == nil then
			coordinateTable[_data.CategoryId] = {}
		end
		if baseTable[_data.CategoryId][_data.TechId] == nil then
			baseTable[_data.CategoryId][_data.TechId] = {}
			baseIdTable[_data.TechId] = baseTable[_data.CategoryId][_data.TechId]
		end
		baseTable[_data.CategoryId][_data.TechId][_data.Level] = _data
		baseTable[_data.CategoryId][_data.TechId][_data.Level].Condition = {}
		if _data.UnlockCondition ~= "NA" then
			local t = string.split(_data.UnlockCondition,';')
			for i = 1, #(t) do
				local cond = string.split(t[i],':')
				local cc = {}
				cc.id = tonumber(cond[1])
				cc.value = tonumber(cond[2])
				table.insert(baseTable[_data.CategoryId][_data.TechId][_data.Level].Condition, cc)
			end
		end
		if _data.Level == 1 then
			baseTable[_data.CategoryId][_data.TechId].BaseData = baseTable[_data.CategoryId][_data.TechId][_data.Level]
			local cot = string.split(_data.Coordinate,';')
			local x,y = tonumber(cot[2]), tonumber(cot[1])
			baseTable[_data.CategoryId][_data.TechId].Coord = {}
			baseTable[_data.CategoryId][_data.TechId].Coord.x = x
			baseTable[_data.CategoryId][_data.TechId].Coord.y = y
			if cot[3] == nil then
				baseTable[_data.CategoryId][_data.TechId].Coord.e = false
			else
				if tonumber(cot[3]) == 1 then
					baseTable[_data.CategoryId][_data.TechId].Coord.e = true
				else
					baseTable[_data.CategoryId][_data.TechId].Coord.e = false
				end
			end
			if coordinateTable[_data.CategoryId][y] == nil then
				coordinateTable[_data.CategoryId][y] = {}
				coordinateTable[_data.CategoryId][y].tags = {false, false, false, false, false, false}
				coordinateTable[_data.CategoryId][y].datas = {}
			end
			coordinateTable[_data.CategoryId][y].datas[x] = baseTable[_data.CategoryId][_data.TechId]
		end
	end]]
	for i, v in pairs(baseIdTable) do
		if v.BaseData ~= nil then
			for ii, vv in ipairs(v.BaseData.Condition) do
				baseIdTable[vv.id].unlocknext = vv.value
			end
		end
	end
	MakeConnect(1)
	MakeConnect(2)
	AttributeBonus.RegisterAttBonusModule(_M)
	--AttributeBonus.CollectBonusInfo()
end

function CalAttributeBonus()
    if MainData.IsCommanderCaptured() then
        return {}
    end

    if baseIdTable == nil then 
       return
    end
    local bonus = {}
    table.foreach(baseIdTable ,function(i,v)
    	if v.BaseData ~= nil then
	    	local level = TalentInfoData.GetTalentLevelById(v.BaseData.TechId)
	        if level ~= 0 then
		        local b = {}
		        local t = string.split(v[level].ArmyType,';')  
		        for j=1,#(t) do
			        if t[j] ~= nil then 
			            local b = {}
			            b.BonusType =tonumber(t[j])
			            b.Attype =  v[level].AttrType
			            b.Value =  v[level].Value
			            b.Global = v[level].Global
			            table.insert(bonus,b)
		            end
		        end
	        end
	    end
    end)
    return bonus
end

function GetTalentByID(id)
	return baseIdTable[id]
end

function GetCurrentIndex()
	return currentIndex
end

local function CheckState(itemdata)
	local level = TalentInfoData.GetTalentLevelByIndexId(currentIndex,itemdata.BaseData.TechId)
	local _data = baseIdTable[itemdata.BaseData.TechId][level]
	if _data == nil then
		_data = itemdata.BaseData
	end
	local conditions = true
	for i, v in ipairs(_data.Condition) do
		if TalentInfoData.GetTalentLevelByIndexId(currentIndex,v.id) < v.value then
			conditions = false
		end
	end
	if currentIndex == TalentInfoData.GetData().useIndex then
		if conditions then
			return 1
		elseif level > 0 then
			return 2
		else
			return 3
		end
	else
		if conditions or level > 0 then
			return 4
		else
			return 3
		end
	end
end

local function SetLineByY(y, bool)
	local root = _ui.grid.transform:Find(tostring(y))
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

local function MakeItemData(itemtrans, itemdata, y)
	local bg_list = itemtrans:Find("bg_list")
	local bg_list_hui = itemtrans:Find("bg_list_hui")
	local bg_name = itemtrans:Find("bg_title/text"):GetComponent("UILabel")
	local bg_texture = itemtrans:Find("Texture"):GetComponent("UITexture")
	local bg_level = itemtrans:Find("bg_level")
	local bg_level_slider = bg_level:Find("array"):GetComponent("UISlider")
	local bg_level_text = itemtrans:Find("text"):GetComponent("UILabel")
	local icon_suo = itemtrans:Find("icon_suo")
	local icon_cha = itemtrans:Find("icon_cha")
	local info = itemtrans:Find("info"):GetComponent("UISprite")
	local infolabel = itemtrans:Find("info/Label"):GetComponent("UILabel")
	info.transform:GetComponent("UIButton").enabled = false
	SetParameter(info.gameObject, itemdata.BaseData.TechId)
	if itemdata.unlocknext ~= nil then
		itemtrans:Find("Level"):GetComponent("UILabel").text = "Lv" .. itemdata.unlocknext
	else
		itemtrans:Find("Level"):GetComponent("UILabel").text = ""
	end
	local level = TalentInfoData.GetTalentLevelByIndexId(currentIndex,itemdata.BaseData.TechId)
	local _data = baseIdTable[itemdata.BaseData.TechId][level]
	if _data == nil then
		_data = itemdata.BaseData
	end
	bg_name.text = TextMgr:GetText(_data.Name)
	bg_texture.mainTexture = ResourceLibrary:GetIcon("Icon/Talent/", _data.Icon)
	bg_texture.shader = UnityEngine.Shader.Find("Unlit/Transparent Colored Gray")
	bg_level_slider.value = level / _data.MaxLevel
	bg_level_text.text = level .. "/" .. _data.MaxLevel
	if level < _data.MaxLevel then
		bg_level_slider.transform:GetComponent("UISprite").spriteName = "proceed_array"
	else
		bg_level_slider.transform:GetComponent("UISprite").spriteName = "proceed_array"
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
		info.spriteName = "icon_wenhao"
		infolabel.gradientTop = Color.New(89/255, 122/255, 151/255, 1)
		infolabel.gradientBottom = Color.New(89/255, 122/255, 151/255, 1)
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
		info.spriteName = "icon_wenhao"
		infolabel.gradientTop = Color.New(89/255, 122/255, 151/255, 1)
		infolabel.gradientBottom = Color.New(89/255, 122/255, 151/255, 1)
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
		info.spriteName = "icon_wenhao_g"
		infolabel.gradientTop = Color.New(234/255, 232/255, 232/255, 1)
		infolabel.gradientBottom = Color.New(234/255, 232/255, 232/255, 1)
	else
		bg_list.gameObject:SetActive(false)
		bg_list_hui.gameObject:SetActive(true)
		bg_name.gradientTop = Color.gray
		bg_name.gradientBottom = Color.gray
		bg_texture.color = Color.black
		bg_level_text.gradientTop = Color.gray
		bg_level_text.gradientBottom = Color.gray
		bg_level.gameObject:SetActive(false)
		icon_suo.gameObject:SetActive(false)
		icon_cha.gameObject:SetActive(false)
		info.spriteName = "icon_wenhao_g"
		infolabel.gradientTop = Color.New(234/255, 232/255, 232/255, 1)
		infolabel.gradientBottom = Color.New(234/255, 232/255, 232/255, 1)
	end
	if state == 3 or state == 4 then
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
	if currentIndex == TalentInfoData.GetData().useIndex then
		itemtrans:GetComponent("BoxCollider").enabled = true
		SetClickCallback(itemtrans.gameObject, function()
			TalentUpgrade.Show(itemdata)
		end)
	else
		itemtrans:GetComponent("BoxCollider").enabled = false
	end
end

local function UpdateUI(needreposition)
	local _coordinate = coordinateTable[currentPage]
	local finishindex
	for i, v in pairs(_coordinate) do
		local item = _ui.grid.transform:Find(tostring(i))
		if item == nil then
			item = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject).transform
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
				local item_info = _item:Find("Talentitem")
				MakeItemData(item_info, v.datas[ii], i)
			end
		end
		finishindex = i
	end
	local childCount = _ui.grid.transform.childCount
	for i = finishindex, childCount - 1 do
		_ui.grid.transform:GetChild(i).gameObject:SetActive(false)
	end
	_ui.grid:Reposition()
	if needreposition then
		_ui.scroll:ResetPosition()
	end
	_ui.item.gameObject:SetActive(false)
	if currentIndex == TalentInfoData.GetData().useIndex then
		_ui.btn_reset:SetActive(true)
		SetClickCallback(_ui.btn_reset, function()
			QuickUseItem.Show(11201, function(buy)
	            TalentInfoData.RequestOperate(1, currentIndex)
	        end)
		end)
		_ui.btn_use:SetActive(false)
	else
		_ui.btn_reset:SetActive(false)
		_ui.btn_use:SetActive(true)
		SetClickCallback(_ui.btn_use, function()
			if MainData.GetVipLevel() < 8 then
				QuickUseItem.Show(11201, function(buy)
					TalentInfoData.RequestOperate(2, currentIndex)
				end)
			else
				TalentInfoData.RequestOperate(2, currentIndex)
			end
		end)
	end
	_ui.leftpoint.text = TalentInfoData.GetRemainderPoint(currentIndex)
end

function Awake()
	_ui = {}
	_ui.container = transform:Find("Container").gameObject
	_ui.btn_close = transform:Find("Container/background widget/close btn").gameObject
	_ui.btn_reset = transform:Find("Container/background widget/ResetBottom").gameObject
	_ui.btn_use = transform:Find("Container/background widget/UseBottom").gameObject
	_ui.btn_talent1 = transform:Find("Container/bg2/Talent1").gameObject
	_ui.btn_talent2 = transform:Find("Container/bg2/Talent2").gameObject
	_ui.btn_talent3 = transform:Find("Container/bg2/Talent3").gameObject
	_ui.btn_page1 = transform:Find("Container/bg2/TalentContent/bg2/page1").gameObject
	_ui.btn_page2 = transform:Find("Container/bg2/TalentContent/bg2/page2").gameObject
	_ui.leftpoint = transform:Find("Container/bg2/TalentContent/bg2/TalentIcon/point"):GetComponent("UILabel")
	_ui.scroll = transform:Find("Container/bg2/TalentContent/bg2/TalentTree"):GetComponent("UIScrollView")
	_ui.grid = transform:Find("Container/bg2/TalentContent/bg2/TalentTree/Grid"):GetComponent("UIGrid")
	_ui.item = transform:Find("Container/bg2/TalentContent/bg2/TalentTree/Tech_item")
	AddDelegate(UICamera, "onPress", OnUICameraPress)
end

function Start()
	currentIndex = TalentInfoData.GetData().useIndex
	currentPage = 2
	UpdateUI(true)
	local pages = 1
	local tiaojian = 0
	if MainData.GetLevel() >= tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.TalentPageOpenLevel).value) then
		pages = pages + 1
		tiaojian = 1
	end
	if VipData.CheckValue(7, 0) then
		pages = pages + 1
		tiaojian = 2
	end
	_ui.btn_talent2:SetActive(true)
	_ui.btn_talent3:SetActive(true)
	if pages == 1 then
		_ui.btn_talent2:GetComponent("UIToggle").enabled = false
		_ui.btn_talent2.transform:Find("unlock").gameObject:SetActive(true)
		_ui.btn_talent2.transform:Find("Sprite").gameObject:SetActive(false)
		_ui.btn_talent3:GetComponent("UIToggle").enabled = false
		_ui.btn_talent3.transform:Find("unlock").gameObject:SetActive(true)
		_ui.btn_talent3.transform:Find("Sprite").gameObject:SetActive(false)
	elseif pages == 2 then
		_ui.btn_talent2:GetComponent("UIToggle").enabled = true
		_ui.btn_talent2.transform:Find("unlock").gameObject:SetActive(false)
		_ui.btn_talent2.transform:Find("Sprite").gameObject:SetActive(true)
		_ui.btn_talent3:GetComponent("UIToggle").enabled = false
		_ui.btn_talent3.transform:Find("unlock").gameObject:SetActive(true)
		_ui.btn_talent3.transform:Find("Sprite").gameObject:SetActive(false)
	else
		_ui.btn_talent2:GetComponent("UIToggle").enabled = true
		_ui.btn_talent2.transform:Find("unlock").gameObject:SetActive(false)
		_ui.btn_talent2.transform:Find("Sprite").gameObject:SetActive(true)
		_ui.btn_talent3:GetComponent("UIToggle").enabled = true
		_ui.btn_talent3.transform:Find("unlock").gameObject:SetActive(false)
		_ui.btn_talent3.transform:Find("Sprite").gameObject:SetActive(true)
	end
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	
	SetClickCallback(_ui.btn_page1, function()
		currentPage = 2
		UpdateUI(true)
	end)
	SetClickCallback(_ui.btn_page2, function()
		currentPage = 1
		UpdateUI(true)
	end)
	_ui.btn_page1:GetComponent("UIToggle"):Set(true)
	
	SetClickCallback(_ui.btn_talent1, function()
		currentIndex = 1
		UpdateUI(true)
	end)
	SetClickCallback(_ui.btn_talent2, function()
		if pages > 1 then
			currentIndex = 2
			UpdateUI(true)
		else
			FloatText.Show(TextMgr:GetText("talenthint3"), Color.white)
		end
	end)
	SetClickCallback(_ui.btn_talent3, function()
		if pages > 2 then
			currentIndex = 3
			UpdateUI(true)
		else
			if tiaojian == 1 then
				FloatText.Show(TextMgr:GetText("talenthint2"), Color.white)
			elseif tiaojian == 2 then
				FloatText.Show(TextMgr:GetText("talenthint1"), Color.white)
			end
		end
	end)
	if currentIndex == 1 then
		_ui.btn_talent1:GetComponent("UIToggle"):Set(true)
	elseif currentIndex == 2 then
		_ui.btn_talent2:GetComponent("UIToggle"):Set(true)
	else
		_ui.btn_talent3:GetComponent("UIToggle"):Set(true)
	end
	
	TalentInfoData.AddListener(UpdateUI)
end

function Close()
	_ui = nil
	TalentInfoData.RemoveListener(UpdateUI)
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
end

function Show()
	Global.OpenUI(_M)
end

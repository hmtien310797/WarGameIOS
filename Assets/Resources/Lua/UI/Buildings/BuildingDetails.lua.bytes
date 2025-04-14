module("BuildingDetails",package.seeall)

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

local btnQuit
local bgMid
local bgScrollView
local bgScrollViewGrid
local detailItem
local detailTitle
local uiInfoGrid

OnCloseCB = nil

local function Hide()
    Global.CloseUI(_M)
end
local _current = 0
--关闭按钮
local function QuitPressCallback(go, isPressed)
	if not isPressed then
	    Hide()
	end
end



local function DelPressCallback(buildingdata)
	
	--print("del res construction")
	local msg = System.String.Format(TextMgr:GetText("ui_DisBuilding") , buildingdata.DemolishGold)
	local okCallback = function()
		print("del building")
		MainCityUI.CleanBuild()
		Hide()
	end
	local cancelCallback = function()
		MessageBox.Clear()
	end
		
	MessageBox.Show(msg, okCallback, cancelCallback)
end

function Awake()
end

local BarrackInfos

local function CreateBarrackInfo()
    if BarrackInfos ~= nil then
        return BarrackInfos
    end
	BarrackInfos = {}
	local barrack_table = TableMgr:GetBarrackBuildDataTable()
	for _ , v in pairs(barrack_table) do
		local data = v
		if BarrackInfos[data.BuildID] == nil then
			BarrackInfos[data.BuildID] = {}
		end
		BarrackInfos[data.BuildID][data.BuildLevel] = data
	
	end
	
	--[[local iter = barrack_table:GetEnumerator()
	while iter:MoveNext() do
		local data = iter.Current.Value
		if BarrackInfos[data.BuildID] == nil then
			BarrackInfos[data.BuildID] = {}
		end
		BarrackInfos[data.BuildID][data.BuildLevel] = data
	end]]
	return BarrackInfos
end

local LabInfos

local function CreateLabInfo()
    if LabInfos ~= nil then
        return LabInfos
    end
    LabInfos = {}
	local lab_table = TableMgr:GetBuildLaboratoryTable()
	for _ , v in pairs(lab_table) do
		local data = v
		if LabInfos[data.BuildLevel] == nil then
			LabInfos[data.BuildLevel] = {}
        end
		LabInfos[data.BuildLevel] = data
	end
	
	--[[local iter = lab_table:GetEnumerator()
	while iter:MoveNext() do
		local data = iter.Current.Value
		if LabInfos[data.BuildLevel] == nil then
			LabInfos[data.BuildLevel] = {}
        end
		LabInfos[data.BuildLevel] = data
	end    ]]
    return LabInfos
end

local EmbassyInfos

local function CreateEmbassyInfo()
    if EmbassyInfos ~= nil then
        return EmbassyInfos
    end
	EmbassyInfos = {}
	local embassy_table = TableMgr:GetEmbassyTable()
	for _ , v in pairs(embassy_table) do
		local data = v
		EmbassyInfos[data.buildlevel] = data
	end
	
	--[[local iter = embassy_table:GetEnumerator()
	while iter:MoveNext() do
		local data = iter.Current.Value
		EmbassyInfos[data.buildlevel] = data
	end]]
	return EmbassyInfos
end

local function ShowEmbassyInfo(build)
	local type_id = build.data.type
	local infolist = CreateEmbassyInfo()
	local bg_title = transform:Find("Container/bg_frane/bg_mid/bg_title_embassy")
	bg_title.gameObject:SetActive(true)
	detailItem = transform:Find("FortificationDetailsinfo")
    local index = 0
	for i = 1, #(infolist) do
		local item = NGUITools.AddChild(bgScrollViewGrid.gameObject, detailItem.gameObject)
		if index%2 == 0 then
			item.transform:Find("bg_list").gameObject:SetActive(false)
        end		
		if (build.data.level) == (infolist[i].buildlevel) then
			_current = i - 1
			item.transform:Find("bg_select").gameObject:SetActive(true)
			SelItem(item)
		else
			item.transform:Find("bg_select").gameObject:SetActive(false)
		end			
		item.transform:SetParent(bgScrollViewGrid, false)
		item.transform:Find("text (1)"):GetComponent("UILabel").text = infolist[i].buildlevel
		item.transform:Find("text (2)"):GetComponent("UILabel").text = infolist[i].addpower
		item.transform:Find("text (3)"):GetComponent("UILabel").text = infolist[i].armynum
		index =index + 1 
	end
end

local AssembledInfos

local function CreateAssembledInfo()
    if AssembledInfos ~= nil then
        return AssembledInfos
    end
	AssembledInfos = {}
	local assembled_table = TableMgr:GetAssembledTable()
	for _ , v in pairs(assembled_table) do
		local data = v
		AssembledInfos[data.buildlevel] = data
	end
	
	--[[local iter = assembled_table:GetEnumerator()
	while iter:MoveNext() do
		local data = iter.Current.Value
		AssembledInfos[data.buildlevel] = data
	end]]
	return AssembledInfos
end

local function calAssembled(base_weight)
    local params = {}
    params.base = base_weight
    return AttributeBonus.CallBonusFunc(51,params)
end

local function ShowAssembledInfo(build)
	local type_id = build.data.type
	local infolist = CreateAssembledInfo()
	local bg_title = transform:Find("Container/bg_frane/bg_mid/bg_title_warhall")
	bg_title.gameObject:SetActive(true)
	detailItem = transform:Find("Resinfo")
    local index = 0
	for i = 1, #(infolist) do
		local item = NGUITools.AddChild(bgScrollViewGrid.gameObject, detailItem.gameObject)
		if index%2 == 0 then
			item.transform:Find("bg_list").gameObject:SetActive(false)
        end		
		if (build.data.level) == (infolist[i].buildlevel) then
			_current = i - 1
			item.transform:Find("bg_select").gameObject:SetActive(true)
			SelItem(item)
		else
			item.transform:Find("bg_select").gameObject:SetActive(false)
		end			
		item.transform:SetParent(bgScrollViewGrid, false)
		item.transform:Find("Level"):GetComponent("UILabel").text = infolist[i].buildlevel
		item.transform:Find("text (1)"):GetComponent("UILabel").text = infolist[i].addpower
		item.transform:Find("text (2)"):GetComponent("UILabel").text = Global.ExchangeValue(infolist[i].armynum)
		item.transform:Find("text (3)"):GetComponent("UILabel").text = Global.ExchangeValue(infolist[i].ResourceMax)
		index =index + 1 
	end
end
    
local function ShowBarrackDefenseInfo(build)
	local type_id = build.data.type
	local infolist = CreateBarrackInfo()
	local bg_title = transform:Find("Container/bg_frane/bg_mid/bg_title_Fortification")
	bg_title.gameObject:SetActive(true)
	
	detailItem = transform:Find("FortificationDetailsinfo")
    local index = 0
	for i = 1, #(infolist[type_id]) do
	
		local item = NGUITools.AddChild(bgScrollViewGrid.gameObject, detailItem.gameObject)
		if index%2 == 0 then
			item.transform:Find("bg_list").gameObject:SetActive(false)
        end		
		if (build.data.level) == (infolist[type_id][i].BuildLevel) then
			_current = i - 1
			item.transform:Find("bg_select").gameObject:SetActive(true)
			SelItem(item)
		else
			item.transform:Find("bg_select").gameObject:SetActive(false)
		end			
		item.transform:SetParent(bgScrollViewGrid, false)
		item.transform:Find("text (1)"):GetComponent("UILabel").text = infolist[type_id][i].BuildLevel
		item.transform:Find("text (2)"):GetComponent("UILabel").text = infolist[type_id][i].BattlePoint
		item.transform:Find("text (3)"):GetComponent("UILabel").text = infolist[type_id][i].MaxNum
		index =index + 1 
	end
end

local function ShowBarrackInfo(build)
	local type_id = build.data.type
	local infolist = CreateBarrackInfo()
	local bg_title = transform:Find("Container/bg_frane/bg_mid/bg_title_Barrack")
	local titleAdd = bg_title:Find("text (4)"):GetComponent("UILabel")
	bg_title.gameObject:SetActive(true)
	if type_id == 21 then
		titleAdd.text = TextMgr:GetText("InfantryBarrack_effect")
	elseif type_id == 22 then
		titleAdd.text = TextMgr:GetText("SpecialBarrack_effect")
		
	elseif type_id == 23 then
		titleAdd.text = TextMgr:GetText("HeavyBarrack_effect")
		
	elseif type_id == 24 then
		titleAdd.text = TextMgr:GetText("HeavyFactory_effect")		
	end
	
	
	detailItem = transform:Find("BarrackDetailsinfo")
    local index = 0
	for i = 1, #(infolist[type_id]) do
	
		local item = NGUITools.AddChild(bgScrollViewGrid.gameObject, detailItem.gameObject)
		if index%2 == 0 then
			item.transform:Find("bg_list").gameObject:SetActive(false)
        end		
		if (build.data.level) == (infolist[type_id][i].BuildLevel) then
			_current = i - 1
			item.transform:Find("bg_select").gameObject:SetActive(true)
			SelItem(item)
		else
			item.transform:Find("bg_select").gameObject:SetActive(false)
		end			
		item.transform:SetParent(bgScrollViewGrid, false)
		item.transform:Find("text (1)"):GetComponent("UILabel").text = infolist[type_id][i].BuildLevel
		item.transform:Find("text (2)"):GetComponent("UILabel").text = infolist[type_id][i].BattlePoint
		item.transform:Find("text (3)"):GetComponent("UILabel").text = infolist[type_id][i].MaxNum
		item.transform:Find("text (4)"):GetComponent("UILabel").text = "+" .. infolist[type_id][i].IncreaseValue
		index =index + 1 
	end
end

local function ShowLabInfo(build)
	local infolist = CreateLabInfo()
	local bg_title = transform:Find("Container/bg_frane/bg_mid/bg_title_Laboratory")
	bg_title.gameObject:SetActive(true)
	detailItem = transform:Find("FortificationDetailsinfo")
    local index = 0
	for i = 1, #(infolist) do
		local item = NGUITools.AddChild(bgScrollViewGrid.gameObject, detailItem.gameObject)
		if index%2 == 0 then
			item.transform:Find("bg_list").gameObject:SetActive(false)
        end		
		if (build.data.level) == (infolist[i].BuildLevel) then
			_current = i - 1
			item.transform:Find("bg_select").gameObject:SetActive(true)
			SelItem(item)
		else
			item.transform:Find("bg_select").gameObject:SetActive(false)
		end			
		item.transform:SetParent(bgScrollViewGrid, false)
		item.transform:Find("text (1)"):GetComponent("UILabel").text = infolist[i].BuildLevel
		item.transform:Find("text (2)"):GetComponent("UILabel").text = infolist[i].AddPower
		item.transform:Find("text (3)"):GetComponent("UILabel").text = infolist[i].TechAccl.."%"
		index = index + 1
    end
end

local WareInfos

local function CreateWareInfo()
    if WareInfos ~= nil then
        return WareInfos
    end
    WareInfos = {}
	local ware_table = TableMgr:GetWareDataTable()
	for _ , v in pairs(ware_table) do
		local data = v
		if WareInfos[data.buildLevel] == nil then
			WareInfos[data.buildLevel] = {}
        end
		WareInfos[data.buildLevel] = data
	end
	--[[local iter = ware_table:GetEnumerator()
	while iter:MoveNext() do
		local data = iter.Current.Value
		if WareInfos[data.buildLevel] == nil then
			WareInfos[data.buildLevel] = {}
        end
		WareInfos[data.buildLevel] = data
	end]]
    return WareInfos
end

local function ShowWareInfo(build)
	local infolist = CreateWareInfo()
	local bg_title = transform:Find("Container/bg_frane/bg_mid/bg_title_4")
	bg_title.gameObject:SetActive(true)
	detailItem = transform:Find("4info")
    local index = 0
	for i = 1, #(infolist) do
		local item = NGUITools.AddChild(bgScrollViewGrid.gameObject, detailItem.gameObject)
		if index%2 == 0 then
			item.transform:Find("bg_list").gameObject:SetActive(false)
        end		
		if (build.data.level) == (infolist[i].buildLevel) then
			_current = i - 1
			item.transform:Find("bg_select").gameObject:SetActive(true)
			SelItem(item)
		else
			item.transform:Find("bg_select").gameObject:SetActive(false)
		end			
		item.transform:SetParent(bgScrollViewGrid, false)
		item.transform:Find("Level"):GetComponent("UILabel").text = infolist[i].buildLevel
		item.transform:Find("text (1)"):GetComponent("UILabel").text = infolist[i].addPower
		item.transform:Find("text (2)"):GetComponent("UILabel").text = Global.ExchangeValue(infolist[i].pvFood)
		item.transform:Find("text (3)"):GetComponent("UILabel").text = Global.ExchangeValue(infolist[i].pvIron)
		item.transform:Find("text (4)"):GetComponent("UILabel").text = Global.ExchangeValue(infolist[i].pvOil)
		item.transform:Find("text (5)"):GetComponent("UILabel").text = Global.ExchangeValue(infolist[i].pvElectric)
		index = index + 1
    end
end

local ClinicInfos
local function CreateClinicInfo()
	if ClinicInfos ~= nil then
        return ClinicInfos
    end
    ClinicInfos = {}
	local clinic_table = TableMgr:GetClinicTable()
	for _ , v in pairs(clinic_table) do
		local data = v
		if ClinicInfos[data.buildLevel] == nil then
			ClinicInfos[data.buildLevel] = {}
        end
		ClinicInfos[data.buildLevel] = data
	end
	
	--[[local iter = clinic_table:GetEnumerator()
	while iter:MoveNext() do
		local data = iter.Current.Value
		if ClinicInfos[data.buildLevel] == nil then
			ClinicInfos[data.buildLevel] = {}
        end
		ClinicInfos[data.buildLevel] = data
	end    ]]
    return ClinicInfos
end

local function ShowClinicInfo(build)
	local infolist = CreateClinicInfo()
	local bg_title = transform:Find("Container/bg_frane/bg_mid/bg_title_hospital")
	bg_title.gameObject:SetActive(true)
	detailItem = transform:Find("Resinfo")
    local index = 0
	for i = 1, #(infolist) do
		local item = NGUITools.AddChild(bgScrollViewGrid.gameObject, detailItem.gameObject)
		if index%2 == 0 then
			item.transform:Find("bg_list").gameObject:SetActive(false)
        end		
		if (build.data.level) == (infolist[i].buildLevel) then
			_current = i - 1
			item.transform:Find("bg_select").gameObject:SetActive(true)
			SelItem(item)
		else
			item.transform:Find("bg_select").gameObject:SetActive(false)
		end			
		item.transform:SetParent(bgScrollViewGrid, false)
		item.transform:Find("Level"):GetComponent("UILabel").text = infolist[i].buildLevel
		item.transform:Find("text (1)"):GetComponent("UILabel").text = infolist[i].addPower
		item.transform:Find("text (2)"):GetComponent("UILabel").text = infolist[i].hurt
		item.transform:Find("text (3)"):GetComponent("UILabel").text = string.format("%+.1f%%", infolist[i].speed/100)
		index = index + 1
    end
	
	uiInfoGrid = bgScrollViewGrid:GetComponent("UIGrid")
	uiInfoGrid:Reposition()
	bgScrollView:MoveRelative(Vector3.New(0, uiInfoGrid.cellHeight * _current, 0))
	bgScrollView:RestrictWithinBounds(true)
end

local WallInfos
local function CreateWallInfo()
	if WallInfos ~= nil then
        return WallInfos
    end
    WallInfos = {}
	local wall_table = TableMgr:GetWallDataTable()
	for _ , v in pairs(wall_table) do
		local data = v
		if WallInfos[data.buildLevel] == nil then
			WallInfos[data.buildLevel] = {}
        end
		WallInfos[data.buildLevel] = data
	end
	
	--[[local iter = wall_table:GetEnumerator()
	while iter:MoveNext() do
		local data = iter.Current.Value
		if WallInfos[data.buildLevel] == nil then
			WallInfos[data.buildLevel] = {}
        end
		WallInfos[data.buildLevel] = data
	end    ]]
    return WallInfos
end

local function ShowWallInfo(build)
	local infolist = CreateWallInfo()
	local bg_title = transform:Find("Container/bg_frane/bg_mid/bg_title_wall")
	bg_title.gameObject:SetActive(true)
	detailItem = transform:Find("BarrackWallinfo")
    local index = 0
	for i = 1, #(infolist) do
		local item = NGUITools.AddChild(bgScrollViewGrid.gameObject, detailItem.gameObject)
		if index%2 == 0 then
			item.transform:Find("bg_list").gameObject:SetActive(false)
        end		
		if (build.data.level) == (infolist[i].buildLevel) then
			_current = i - 1
			item.transform:Find("bg_select").gameObject:SetActive(true)
			SelItem(item)
		else
			item.transform:Find("bg_select").gameObject:SetActive(false)
		end			
		item.transform:SetParent(bgScrollViewGrid, false)
		item.transform:Find("text (1)"):GetComponent("UILabel").text = infolist[i].buildLevel
		item.transform:Find("text (2)"):GetComponent("UILabel").text = infolist[i].addPower
		item.transform:Find("text (3)"):GetComponent("UILabel").text = infolist[i].maxDefNumber
		item.transform:Find("text (4)"):GetComponent("UILabel").text = infolist[i].WallDefence
		index = index + 1
    end
	
	uiInfoGrid = bgScrollViewGrid:GetComponent("UIGrid")
	uiInfoGrid:Reposition()
	bgScrollView:MoveRelative(Vector3.New(0, uiInfoGrid.cellHeight * _current, 0))
	bgScrollView:RestrictWithinBounds(true)
end

local CallUpInfos
local function CreateCallUpInfo()
	if CallUpInfos ~= nil then
        return CallUpInfos
    end
    CallUpInfos = {}
	local callup_table = TableMgr:GetCallUpTable()
	for _ , v in pairs(callup_table) do
		local data = v
		if CallUpInfos[data.buildLevel] == nil then
			CallUpInfos[data.buildLevel] = {}
        end
		CallUpInfos[data.buildLevel] = data
	end
	
	--[[local iter = callup_table:GetEnumerator()
	while iter:MoveNext() do
		local data = iter.Current.Value
		if CallUpInfos[data.buildLevel] == nil then
			CallUpInfos[data.buildLevel] = {}
        end
		CallUpInfos[data.buildLevel] = data
	end]]    
    return CallUpInfos
end

local function ShowCallUpInfo(build)
	local infolist = CreateCallUpInfo()
	local bg_title = transform:Find("Container/bg_frane/bg_mid/bg_title_zhengzhaosuo")
	
	bg_title.gameObject:SetActive(true)
	detailItem = transform:Find("BuildingDetailsinfo")
    local index = 0
	for i = 1, #(infolist) do
		local item = NGUITools.AddChild(bgScrollViewGrid.gameObject, detailItem.gameObject)
		if index%2 == 0 then
			item.transform:Find("bg_list").gameObject:SetActive(false)
        end		
		if (build.data.level) == (infolist[i].buildLevel) then
			_current = i - 1
			item.transform:Find("bg_select").gameObject:SetActive(true)
			SelItem(item)
		else
			item.transform:Find("bg_select").gameObject:SetActive(false)
		end			
		item.transform:SetParent(bgScrollViewGrid, false)
		item.transform:Find("text (1)"):GetComponent("UILabel").text = infolist[i].buildLevel
		item.transform:Find("text (2)"):GetComponent("UILabel").text = infolist[i].addPower
		item.transform:Find("text (3)"):GetComponent("UILabel").text = infolist[i].number
		item.transform:Find("text (4)"):GetComponent("UILabel").text = math.ceil(infolist[i].speed) .. "%"
		index = index + 1
    end
	
	uiInfoGrid = bgScrollViewGrid:GetComponent("UIGrid")
	uiInfoGrid:Reposition()
	bgScrollView:MoveRelative(Vector3.New(0, uiInfoGrid.cellHeight * _current, 0))
	bgScrollView:RestrictWithinBounds(true)
end

local ParadeGroundInfos

local function CreateParadeGroundInfo()
    if ParadeGroundInfos ~= nil then
        return ParadeGroundInfos
    end
    ParadeGroundInfos = {}
	local ware_table = TableMgr:GetParadeGroundTable()
	for _ , v in pairs(ware_table) do
		local data = v
		if ParadeGroundInfos[data.buildLevel] == nil then
			ParadeGroundInfos[data.buildLevel] = {}
        end
		ParadeGroundInfos[data.buildLevel] = data
	end 
	
	--[[local iter = ware_table:GetEnumerator()
	while iter:MoveNext() do
		local data = iter.Current.Value
		if ParadeGroundInfos[data.buildLevel] == nil then
			ParadeGroundInfos[data.buildLevel] = {}
        end
		ParadeGroundInfos[data.buildLevel] = data
	end  ]]  
    return ParadeGroundInfos
end

local function ShowParadeGroundInfo(build)
	local infolist = CreateParadeGroundInfo()
	local bg_title = transform:Find("Container/bg_frane/bg_mid/bg_title_paradeground")
	bg_title.gameObject:SetActive(true)
	detailItem = transform:Find("Resinfo")
    local index = 0
	for i = 1, #(infolist) do
		local item = NGUITools.AddChild(bgScrollViewGrid.gameObject, detailItem.gameObject)
		if index%2 == 0 then
			item.transform:Find("bg_list").gameObject:SetActive(false)
        end		
		if (build.data.level) == (infolist[i].buildLevel) then
			_current = i - 1
			item.transform:Find("bg_select").gameObject:SetActive(true)
			SelItem(item)
		else
			item.transform:Find("bg_select").gameObject:SetActive(false)
		end			
		item.transform:SetParent(bgScrollViewGrid, false)
		item.transform:Find("Level"):GetComponent("UILabel").text = infolist[i].buildLevel
		item.transform:Find("text (1)"):GetComponent("UILabel").text = infolist[i].addPower
		item.transform:Find("text (2)"):GetComponent("UILabel").text = infolist[i].addlimitall
		item.transform:Find("text (3)"):GetComponent("UILabel").text = infolist[i].addlimit
		
		index = index + 1
    end
end

local RadarInfos
local function CreateRadarInfo()
    if RadarInfos ~= nil then
        return RadarInfos
    end
    RadarInfos = {}
	local ware_table = TableMgr:GetRadarTable()
	for _ , v in pairs(ware_table) do
		local data = v
		if RadarInfos[data.buildLevel] == nil then
			RadarInfos[data.buildLevel] = {}
        end
		RadarInfos[data.buildLevel] = data
	end 
	
	--[[while iter:MoveNext() do
		local data = iter.Current.Value
		if RadarInfos[data.buildLevel] == nil then
			RadarInfos[data.buildLevel] = {}
        end
		RadarInfos[data.buildLevel] = data
	end ]]   
    return RadarInfos
end

local function ShowRadarInfo(build)
	local infolist = CreateRadarInfo()
	local bg_title = transform:Find("Container/bg_frane/bg_mid/bg_title_radar")
	bg_title.gameObject:SetActive(true)
	detailItem = transform:Find("Details_radar")
    local index = 0
	for i = 1, #(infolist) do
		local item = NGUITools.AddChild(bgScrollViewGrid.gameObject, detailItem.gameObject)
		if index%2 == 0 then
			item.transform:Find("bg_list").gameObject:SetActive(false)
        end		
		if (build.data.level) == (infolist[i].buildLevel) then
			_current = i - 1
			item.transform:Find("bg_select").gameObject:SetActive(true)
			SelItem(item)
		else
			item.transform:Find("bg_select").gameObject:SetActive(false)
		end			
		item.transform:SetParent(bgScrollViewGrid, false)
		item.transform:Find("text (1)"):GetComponent("UILabel").text = infolist[i].buildLevel
		item.transform:Find("text (2)"):GetComponent("UILabel").text = infolist[i].addPower
		item.transform:Find("text (3)"):GetComponent("UILabel").text = TextMgr:GetText(infolist[i].effect)
		index = index + 1
    end
end

local TradeInfos
local function CreateTradeInfo()
    if TradeInfos ~= nil then
        return TradeInfos
    end
    TradeInfos = {}
	local ware_table = TableMgr:GetTradingPostTable()
	for _ , v in pairs(ware_table) do
		local data = v
		if TradeInfos[data.buildLevel] == nil then
			TradeInfos[data.buildLevel] = {}
        end
		TradeInfos[data.buildLevel] = data
	end 
	--[[local iter = ware_table:GetEnumerator()
	while iter:MoveNext() do
		local data = iter.Current.Value
		if TradeInfos[data.buildLevel] == nil then
			TradeInfos[data.buildLevel] = {}
        end
		TradeInfos[data.buildLevel] = data
	end ]] 
    return TradeInfos
end

local function ShowTradeInfo(build)
	local infolist = CreateTradeInfo()
	local bg_title = transform:Find("Container/bg_frane/bg_mid/bg_title_trade")
	
	bg_title.gameObject:SetActive(true)
	detailItem = transform:Find("TradeDetailsinfo")
    local index = 0
	for i = 1, #(infolist) do
		local item = NGUITools.AddChild(bgScrollViewGrid.gameObject, detailItem.gameObject)
		if index%2 == 0 then
			item.transform:Find("bg_list").gameObject:SetActive(false)
        end		
		if (build.data.level) == (infolist[i].buildLevel) then
			_current = i - 1
			item.transform:Find("bg_select").gameObject:SetActive(true)
			SelItem(item)
		else
			item.transform:Find("bg_select").gameObject:SetActive(false)
		end			
		item.transform:SetParent(bgScrollViewGrid, false)
		item.transform:Find("text (1)"):GetComponent("UILabel").text = infolist[i].buildLevel
		item.transform:Find("text (2)"):GetComponent("UILabel").text = infolist[i].addPower
		item.transform:Find("text (3)"):GetComponent("UILabel").text = infolist[i].resNum
		item.transform:Find("text (4)"):GetComponent("UILabel").text = "" .. infolist[i].rate .. "%"
		local showSpeed = ""
		if infolist[i].speedUp ~= 0 then
			showSpeed = showSpeed .. infolist[i].speedUp .. "%"
		else
			showSpeed = "--"
		end
		item.transform:Find("text (5)"):GetComponent("UILabel").text = showSpeed
		index = index + 1
    end
	
	uiInfoGrid = bgScrollViewGrid:GetComponent("UIGrid")
	uiInfoGrid:Reposition()
	bgScrollView:MoveRelative(Vector3.New(0, uiInfoGrid.cellHeight * _current, 0))
	bgScrollView:RestrictWithinBounds(true)
end

local EquipInfos
local function CreateEquipInfo()
    if EquipInfos ~= nil then
        return EquipInfos
    end
    EquipInfos = {}
	local ware_table = TableMgr:GetArmouryData()
	for _ , v in pairs(ware_table) do
		local data = v
		if EquipInfos[data.BuildLevel] == nil then
			EquipInfos[data.BuildLevel] = {}
        end
		EquipInfos[data.BuildLevel] = data
	end 
	
	--[[local iter = ware_table:GetEnumerator()
	while iter:MoveNext() do
		local data = iter.Current.Value
		if EquipInfos[data.BuildLevel] == nil then
			EquipInfos[data.BuildLevel] = {}
        end
		EquipInfos[data.BuildLevel] = data
	end  ]]
    return EquipInfos
end

local function ShowEquipInfo(build)
	local infolist = CreateEquipInfo()
	local bg_title = transform:Find("Container/bg_frane/bg_mid/bg_title_equip")
	
	bg_title.gameObject:SetActive(true)
	detailItem = transform:Find("BuildingDetailsinfo")
    local index = 0
	for i = 1, #(infolist) do
		local item = NGUITools.AddChild(bgScrollViewGrid.gameObject, detailItem.gameObject)
		if index%2 == 0 then
			item.transform:Find("bg_list").gameObject:SetActive(false)
        end		
		if (build.data.level) == (infolist[i].BuildLevel) then
			_current = i - 1
			item.transform:Find("bg_select").gameObject:SetActive(true)
			SelItem(item)
		else
			item.transform:Find("bg_select").gameObject:SetActive(false)
		end			
		item.transform:SetParent(bgScrollViewGrid, false)
		item.transform:Find("text (1)"):GetComponent("UILabel").text = infolist[i].BuildLevel
		item.transform:Find("text (2)"):GetComponent("UILabel").text = infolist[i].AddPower
		item.transform:Find("text (3)"):GetComponent("UILabel").text = infolist[i].SpeedUp .. "%"
		item.transform:Find("text (4)"):GetComponent("UILabel").text = TextMgr:GetText(infolist[i].Text)
		index = index + 1
    end
	
	uiInfoGrid = bgScrollViewGrid:GetComponent("UIGrid")
	uiInfoGrid:Reposition()
	bgScrollView:MoveRelative(Vector3.New(0, uiInfoGrid.cellHeight * _current, 0))
	bgScrollView:RestrictWithinBounds(true)
end

local Jailinfos
local function CreateJailInfo()
	if Jailinfos ~= nil then
        return Jailinfos
    end
    Jailinfos = {}
	local callup_table = TableMgr:GetJailTable()
	for _ , v in ipairs(callup_table) do
		local data = v
		if Jailinfos[data.buildlevel] == nil then
			Jailinfos[data.buildlevel] = {}
        end
		Jailinfos[data.buildlevel] = data
	end
	
    return Jailinfos
end

local function ShowJailInfo(build)
	local infolist = CreateJailInfo()
	local bg_title = transform:Find("Container/bg_frane/bg_mid/bg_title_Jail")
	
	bg_title.gameObject:SetActive(true)
	detailItem = transform:Find("BuildingDetailsinfo")
    local index = 0
	for i = 1, #(infolist) do
		local item = NGUITools.AddChild(bgScrollViewGrid.gameObject, detailItem.gameObject)
		if index%2 == 0 then
			item.transform:Find("bg_list").gameObject:SetActive(false)
        end		
		if (build.data.level) == (infolist[i].buildlevel) then
			_current = i - 1
			item.transform:Find("bg_select").gameObject:SetActive(true)
			SelItem(item)
		else
			item.transform:Find("bg_select").gameObject:SetActive(false)
		end			
		item.transform:SetParent(bgScrollViewGrid, false)
		item.transform:Find("text (1)"):GetComponent("UILabel").text = infolist[i].buildlevel
		item.transform:Find("text (2)"):GetComponent("UILabel").text = infolist[i].addpower
		item.transform:Find("text (3)"):GetComponent("UILabel").text = infolist[i].Prisoner
		item.transform:Find("text (4)"):GetComponent("UILabel").text = Global.SecondToTimeLong(infolist[i].Prisontime)
		index = index + 1
    end
	
	uiInfoGrid = bgScrollViewGrid:GetComponent("UIGrid")
	uiInfoGrid:Reposition()
	bgScrollView:MoveRelative(Vector3.New(0, uiInfoGrid.cellHeight * _current, 0))
	bgScrollView:RestrictWithinBounds(true)
end

function Start()
	bgMid = transform:Find("Container/bg_frane/bg_mid")
	local bgTittle = transform:Find("Container/bg_frane/bg_top/bg_title_left/title")
	local bgDescription = transform:Find("Container/bg_frane/text_miaosu")
	
	local build = maincity.GetCurrentBuildingData()
	local buildingData = build.buildingData
	bgScrollView = transform:Find("Container/bg_frane/bg_mid/Scroll View"):GetComponent("UIScrollView")
	bgScrollViewGrid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid")
	local tittleLabal = bgTittle.gameObject:GetComponent("UILabel")
	tittleLabal.text = TextMgr:GetText(buildingData.name)
	
	local desLabel = bgDescription:GetComponent("UILabel")
	desLabel.text = TextMgr:GetText(buildingData.description)
	
	btnQuit = transform:Find("Container/bg_frane/bg_top/btn_close")
	SetPressCallback(btnQuit.gameObject, Hide)
	SetPressCallback(transform:Find("Container").gameObject, Hide)
	
	local delBtn = transform:Find("Container/bg_frane/btn_del")
	SetClickCallback(delBtn.gameObject, function()
		DelPressCallback(buildingData)
	end)
	delBtn.gameObject:SetActive(false)
	
	if buildingData.demolish then
		FunctionListData.IsFunctionUnlocked(104, function(isactive)
	    	delBtn.gameObject:SetActive(isactive)
	    end)
	end
	
	if(buildingData.logicType == 10) then
		if buildingData.showType == 3 then-- 医疗所
			ShowClinicInfo(build)
			return
		end
		
		if buildingData.showType == 7 then --征召所
			ShowCallUpInfo(build)
			return
		end 
		
		local detailInfo = {}
		local detailInfo_1 = {}
		detailInfo_1 = TableMgr:GetBuildingResourceInfo(buildingData.id)
		detailTitle = bgMid.transform:Find("bg_title_Res")
		detailTitle.gameObject:SetActive(true)
		
		detailItem = transform:Find("Resinfo")
		
		local index = 0
		for _, v in pairs(detailInfo_1) do
			--print(v.resource_BAInfo)
			local item = NGUITools.AddChild(bgScrollViewGrid.gameObject , detailItem.gameObject)
			item.gameObject:SetActive(true)
			item.transform:SetParent(bgScrollViewGrid , false)
			--print(index)
			if index%2 == 0 then
				item.transform:Find("bg_list").gameObject:SetActive(false)
			end
			if build.data.level == (index + 1) then
				_current = index
				item.transform:Find("bg_select").gameObject:SetActive(true)
				SelItem(item)
			else
				item.transform:Find("bg_select").gameObject:SetActive(false)
			end
			local infolist = {}
			infolist = v.resource_BAInfo:split("|")
			local resInfoLevel = item.transform:Find("Level"):GetComponent("UILabel")
			resInfoLevel.text = v.resource_BLevel
			
			for i, v in ipairs(infolist) do
				local resInfo = item.transform:Find(string.format("text (%s)" , i)):GetComponent("UILabel")
				resInfo.text = i == 3 and Global.ExchangeValue(tonumber(infolist[i])) or infolist[i]
				--resInfo.text =infolist[i]
			end
			
			index = index + 1
		end
	end

    if buildingData.logicType == 1 then
        local infolist = TableMgr:GetAllBuildCoreData()
        local bg_title = transform:Find("Container/bg_frane/bg_mid/bg_title")
        bg_title.gameObject:SetActive(true)
        detailItem = transform:Find("CenterDetailsinfo")
		
		for i , v in ipairs(infolist) do
			local item = NGUITools.AddChild(bgScrollViewGrid.gameObject, detailItem.gameObject)
            item.transform:SetParent(bgScrollViewGrid, false)
            local str = infolist[i].unlockInfo
            local unlock = ""
            if str ~= "NA" then
                str = str:split(";")
                for i=1, #str do
					if i<#str then
						unlock = unlock .. TextMgr:GetText(str[i]) .. ","
					else
						unlock = unlock .. TextMgr:GetText(str[i])
					end
                end
            end
            if i % 2 == 0 then
                item.transform:Find("bg_list").gameObject:SetActive(false)
            end
            if build.data.level == i then
            	_current = i
				item.transform:Find("bg_select").gameObject:SetActive(true)
				SelItem(item)
			else
				item.transform:Find("bg_select").gameObject:SetActive(false)
			end
            item.transform:Find("text (1)"):GetComponent("UILabel").text = infolist[i].buildLevel
            item.transform:Find("text (2)"):GetComponent("UILabel").text = infolist[i].addPower
            --item.transform:Find("text (3)"):GetComponent("UILabel").text = infolist[i].accelerateMarch .. "%"
            item.transform:Find("text (3)"):GetComponent("UILabel").text = unlock
		end
        --[[for i = 0, infolist.Length - 1 do
            local item = NGUITools.AddChild(bgScrollViewGrid.gameObject, detailItem.gameObject)
            item.transform:SetParent(bgScrollViewGrid, false)
            local str = infolist[i].unlockInfo
            local unlock = ""
            if str ~= "NA" then
                str = str:split(";")
                for i=1, #str do
					if i<#str then
						unlock = unlock .. TextMgr:GetText(str[i]) .. ","
					else
						unlock = unlock .. TextMgr:GetText(str[i])
					end
                end
            end
            if i % 2 == 0 then
                item.transform:Find("bg_list").gameObject:SetActive(false)
            end
            if build.data.level == (i + 1) then
            	_current = i
				item.transform:Find("bg_select").gameObject:SetActive(true)
			else
				item.transform:Find("bg_select").gameObject:SetActive(false)
			end
            item.transform:Find("text (1)"):GetComponent("UILabel").text = infolist[i].buildLevel
            item.transform:Find("text (2)"):GetComponent("UILabel").text = infolist[i].addPower
            --item.transform:Find("text (3)"):GetComponent("UILabel").text = infolist[i].accelerateMarch .. "%"
            item.transform:Find("text (3)"):GetComponent("UILabel").text = unlock
        end]]
    end

	if buildingData.logicType == 11 then
		if build.data.type ~= 27 then
			ShowBarrackInfo(build)		  --兵营
		else
			ShowBarrackDefenseInfo(build) -- 战争堡垒
		end
	end

	if buildingData.logicType == 4 then
		ShowLabInfo(build)
    end
	
	if buildingData.logicType == 2 then
		ShowWareInfo(build)
    end
	
	if buildingData.logicType == 12 then
		ShowWallInfo(build)
	end
	
	if buildingData.logicType == 3 then
		ShowParadeGroundInfo(build)
	end
	
	if buildingData.logicType == 13 then
		ShowRadarInfo(build)
    end
	
	if buildingData.logicType == 14 then
		ShowTradeInfo(build)
	end

	if buildingData.logicType == 15 then
		ShowEmbassyInfo(build)
    end

	if buildingData.logicType == 16 then
		ShowAssembledInfo(build)
    end  
    
    if buildingData.logicType == 17 then
    	ShowEquipInfo(build)
	end
	
	if buildingData.logicType == 20 then
		ShowJailInfo(build)
	end
	
    uiInfoGrid = bgScrollViewGrid:GetComponent("UIGrid")
	uiInfoGrid:Reposition()
	bgScrollView:ResetPosition()
	bgScrollView:MoveRelative(Vector3.New(0, uiInfoGrid.cellHeight * _current, 0))
	bgScrollView:RestrictWithinBounds(true)
end

function SelItem(item)
	item.transform:Find("bg_list"):GetComponent("UISprite").spriteName = "ranking_my"
	item.transform:Find("text (1)"):GetComponent("UILabel").color = Color.white
	item.transform:Find("text (2)"):GetComponent("UILabel").color = Color.white
	item.transform:Find("text (3)"):GetComponent("UILabel").color = Color.white
	if item.transform:Find("text (4)") ~= nil then
		item.transform:Find("text (4)"):GetComponent("UILabel").color = Color.white
	end 
	if item.transform:Find("text (5)") ~= nil then
		item.transform:Find("text (5)"):GetComponent("UILabel").color = Color.white
	end 
	if item.transform:Find("Level") ~= nil then
		item.transform:Find("Level"):GetComponent("UILabel").color = Color.white
	end 
	item.transform:Find("bg_list").gameObject:SetActive(true)
end 

function Close()
	if OnCloseCB ~= nil then
    	OnCloseCB()
    	OnCloseCB = nil
    end
    btnQuit = nil
	bgMid = nil
	bgScrollView = nil
	bgScrollViewGrid = nil
	detailItem = nil
	detailTitle = nil
	uiInfoGrid = nil
end

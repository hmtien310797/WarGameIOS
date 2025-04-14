module("BuildingUpgrade",package.seeall)
local Category_pb = require("Category_pb")
local BuildMsg_pb = require("BuildMsg_pb")

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
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

local bg_title
local btn_close
local upgrade_condition_grid
local bg_right_texture
local bg_right_3DShow
local bg_right_3DShow_obj
local bg_right_grid
local btn_upgrade
local btn_upgrade_time
local btn_upgrade_gold
local btn_upgrade_gold_num
local upgrade_left_info
local upgrade_right_info

local list_upgrade_left_info
local list_upgrade_right_info

local list_left_path
local list_right_path

local targetBuilding
local building

local canClick = false
local canClick_gold = false

local isOpen
local needRefreshMaincity

OnCloseCB = nil

function Hide()
    Global.CloseUI(_M)
end

function IsOpen()
    return isOpen
end

--设置需要显示的建筑物（maincity的buildingList里面的子集）
function SetTargetBuilding(build)
    targetBuilding = build
end

function GetTargetBuilding()
	return targetBuilding
end

local function MakeList(list, i, stype, arg1, arg2, arg3)
    list[i] = {}
    list[i].type = stype
    list[i].title = arg1
    list[i].text1 = arg2
    list[i].text2 = arg3
    return i + 1
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
	end  ]]  
    return LabInfos
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
	end    ]]
    return WareInfos
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
	end ]]   
    return ClinicInfos
end

local EquipBuildInfos
local function CreateEquipBuildInfos()
	if EquipBuildInfos ~= nil then
        return EquipBuildInfos
    end
    EquipBuildInfos = {}
	local clinic_table = TableMgr:GetArmouryData()
	for _ , v in pairs(clinic_table) do
		local data = v
		if EquipBuildInfos[data.BuildLevel] == nil then
			EquipBuildInfos[data.BuildLevel] = {}
        end
		EquipBuildInfos[data.BuildLevel] = data
	end
	
	--[[local iter = clinic_table:GetEnumerator()
	while iter:MoveNext() do
		local data = iter.Current.Value
		if EquipBuildInfos[data.BuildLevel] == nil then
			EquipBuildInfos[data.BuildLevel] = {}
        end
		EquipBuildInfos[data.BuildLevel] = data
	end ]]   
    return EquipBuildInfos
end


--获取当前建筑升级后解锁数据
local function GetCurrentBuildingNextUnlock(_build)
    local sType
    if _build ~= nil then
        sType = _build.buildingData.showType
    else
        sType = maincity.GetCurrentBuildingShowType()
    end
    local unlocklist = {}
    if sType == 1 then
        local building
        if _build ~= nil then
            building = _build
        else
            building = maincity.GetCurrentBuildingData()
        end
        local coreCurrent = TableMgr:GetBuildCoreData(building.data.level)
        local coreNext = TableMgr:GetBuildCoreData(building.data.level + 1)
        if coreNext ~= nil then
	        local index = 1
	        index = MakeList(unlocklist, index, 2, TextMgr:GetText("build_ui5"), building.data.level, "Lv."..building.data.level + 1)
	        --index = MakeList(unlocklist, index, 1, TextMgr:GetText("common_ui6"), coreCurrent.accelerateMarch .. "%", coreNext.accelerateMarch .. "%")
	        local str = coreNext.unlockInfo
	        if str ~= "NA" then
	            str = str:split(";")
	            local st = ""
	            local length = #str
	            for i, v in pairs(str) do
	                st = st .. TextMgr:GetText(v)
	                if i < length then
	                    st = st .. ", "
	                end
	            end
	            index = MakeList(unlocklist, index, 2, TextMgr:GetText("common_ui7"), nil, st)
	        end
	    end
    end
    if sType == 8 then
        local building
        if _build ~= nil then
            building = _build
        else
            building = maincity.GetCurrentBuildingData()
        end
        local resCurrent = TableMgr:GetBuildingResourceData(building.data.type, building.data.level)
        local resNext = TableMgr:GetBuildingResourceData(building.data.type, building.data.level + 1)
        if resNext ~= nil then
	        local index = 1
	        index = MakeList(unlocklist, index, 2, TextMgr:GetText("build_ui5"), building.data.level, "Lv."..building.data.level + 1)
	        index = MakeList(unlocklist, index, 1, TextMgr:GetText("build_ui10"), resCurrent.resource_BYield, resNext.resource_BYield)
	        index = MakeList(unlocklist, index, 1, TextMgr:GetText("build_ui11"), resCurrent.resource_BCapacity, resNext.resource_BCapacity)
	    end
    end
	if sType == 9 then
        local building
        if _build ~= nil then
            building = _build
        else
            building = maincity.GetCurrentBuildingData()
        end
		local infolist = CreateBarrackInfo()
        local resCurrent = infolist[building.data.type][building.data.level]
        local resNext = infolist[building.data.type][building.data.level + 1]
		
		local curUpdateData = TableMgr:GetBuildUpdateData(building.data.type, building.data.level)
		local nextUpdateData = TableMgr:GetBuildUpdateData(building.data.type, building.data.level + 1)
		if nextUpdateData ~= nil then
	        local index = 1
	        index = MakeList(unlocklist, index, 2, TextMgr:GetText("build_ui5"), building.data.level, "Lv."..building.data.level + 1)
	        index = MakeList(unlocklist, index, 1, TextMgr:GetText("build_ui30"), resCurrent.MaxNum, resNext.MaxNum)
	        index = MakeList(unlocklist, index, 1, TextMgr:GetText(nextUpdateData.updateDetailDesc), "+" .. curUpdateData.updateDetailValue, "+" .. nextUpdateData.updateDetailValue)	
	    end
	end
	
	if sType == 18 then
        local building
        if _build ~= nil then
            building = _build
        else
            building = maincity.GetCurrentBuildingData()
        end
		local infolist = CreateBarrackInfo()
        local resCurrent = infolist[building.data.type][building.data.level]
        local resNext = infolist[building.data.type][building.data.level + 1]
		
		local curUpdateData = TableMgr:GetBuildUpdateData(building.data.type, building.data.level)
		local nextUpdateData = TableMgr:GetBuildUpdateData(building.data.type, building.data.level + 1)
		if nextUpdateData ~= nil then
	        local index = 1
	        index = MakeList(unlocklist, index, 2, TextMgr:GetText("build_ui5"), building.data.level, "Lv."..building.data.level + 1)
	        index = MakeList(unlocklist, index, 1, TextMgr:GetText("build_ui30"), resCurrent.MaxNum, resNext.MaxNum)
	    end
	end
	
    if sType == 4 then 
        local building
        if _build ~= nil then
            building = _build
        else
            building = maincity.GetCurrentBuildingData()
        end
		local infolist = CreateLabInfo()
        local resCurrent = infolist[building.data.level]
        local resNext = infolist[building.data.level + 1]
        if resNext ~= nil then
	        local index = 1
	        index = MakeList(unlocklist, index, 2, TextMgr:GetText("build_ui5"),building.data.level, "Lv."..building.data.level + 1)
	        index = MakeList(unlocklist, index, 1, TextMgr:GetText("build_ui34"), resCurrent.TechAccl.."%", resNext.TechAccl.."%")	    
	    end    
    end
	if sType == 2 then 
        local building
        if _build ~= nil then
            building = _build
        else
            building = maincity.GetCurrentBuildingData()
        end
		
		local curWareData = TableMgr:GetWareData(building.data.level)
		local nextWareData = TableMgr:GetWareData(building.data.level + 1)
		if nextWareData ~= nil then
	        local index = 1
	        index = MakeList(unlocklist, index, 2, TextMgr:GetText("build_ui5"),building.data.level, "Lv."..building.data.level + 1)
	        index = MakeList(unlocklist, index, 1, TextMgr:GetText("warehouse_ui5"),Global.ExchangeValue(curWareData.pvFood), Global.ExchangeValue(nextWareData.pvFood))
	        index = MakeList(unlocklist, index, 1, TextMgr:GetText("warehouse_ui6"),Global.ExchangeValue(curWareData.pvIron), Global.ExchangeValue(nextWareData.pvIron))
	        index = MakeList(unlocklist, index, 1, TextMgr:GetText("warehouse_ui7"),Global.ExchangeValue(curWareData.pvOil), Global.ExchangeValue(nextWareData.pvOil))
	        index = MakeList(unlocklist, index, 1, TextMgr:GetText("warehouse_ui8"),Global.ExchangeValue(curWareData.pvElectric), Global.ExchangeValue(nextWareData.pvElectric))          
	    end
    end

	if sType == 3 then
		local building
        if _build ~= nil then
            building = _build
        else
            building = maincity.GetCurrentBuildingData()
        end
		
		local curClinicData = TableMgr:GetClinicData(building.data.level)
		local nextClinicData = TableMgr:GetClinicData(building.data.level + 1)
		if nextClinicData ~= nil then
	        local index = 1
	        index = MakeList(unlocklist, index, 2, TextMgr:GetText("build_ui5"),building.data.level, "Lv."..building.data.level + 1)
	        index = MakeList(unlocklist, index, 1,TextMgr:GetText("hospital_ui6"),curClinicData.hurt,nextClinicData.hurt)     
		end
	end
	
	if sType == 12 then
		local building
        if _build ~= nil then
            building = _build
        else
            building = maincity.GetCurrentBuildingData()
        end
		
		local curWallData = TableMgr:GetWallData(building.data.level)
		local nextWallData = TableMgr:GetWallData(building.data.level + 1)
		if nextWallData ~= nil then
	        local index = 1
	        index = MakeList(unlocklist, index, 2, TextMgr:GetText("build_ui5"),building.data.level, "Lv."..building.data.level + 1)
	        index = MakeList(unlocklist, index, 1,TextMgr:GetText("setting_ui35"),curWallData.maxDefNumber,nextWallData.maxDefNumber)  
	        index = MakeList(unlocklist, index, 1,TextMgr:GetText("DefenceNumber_8"),curWallData.WallDefence,nextWallData.WallDefence)  
	    end   
	end
	
	if sType == 7 then
		local building
        if _build ~= nil then
            building = _build
        else
            building = maincity.GetCurrentBuildingData()
        end
		
		local curCallUpData = TableMgr:GetCallUpData(building.data.level)
		local nextCallUpData = TableMgr:GetCallUpData(building.data.level + 1)
		if nextCallUpData ~= nil then
	        local index = 1
	        index = MakeList(unlocklist, index, 2, TextMgr:GetText("build_ui5"),building.data.level, "Lv."..building.data.level + 1)
	        index = MakeList(unlocklist, index, 1,TextMgr:GetText("setting_ui36"),curCallUpData.number,nextCallUpData.number)     
	        index = MakeList(unlocklist, index, 1,TextMgr:GetText("setting_ui37"),curCallUpData.speed .. "%" , nextCallUpData.speed .. "%")
	    end
	end
	
	if sType == 6 then
		local building
        if _build ~= nil then
            building = _build
        else
            building = maincity.GetCurrentBuildingData()
        end
		
		local curParadeData = TableMgr:GetParadeGroundData(building.data.level)
		local nextParadeData = TableMgr:GetParadeGroundData(building.data.level + 1)
		if nextParadeData ~= nil then
	        local index = 1
	        index = MakeList(unlocklist, index, 2, TextMgr:GetText("build_ui5"),building.data.level, "Lv."..building.data.level + 1)
			index = MakeList(unlocklist, index, 1,TextMgr:GetText("setting_ui22"),curParadeData.addlimit,nextParadeData.addlimit)
			index = MakeList(unlocklist, index, 1,TextMgr:GetText("army_max_ui3"),curParadeData.addlimitall,nextParadeData.addlimitall)
	    end
	end
	
	if sType == 13 then
		local building
        if _build ~= nil then
            building = _build
        else
            building = maincity.GetCurrentBuildingData()
        end
		
		local curRadarData = TableMgr:GetRadarData(building.data.level)
		local nextRadarData = TableMgr:GetRadarData(building.data.level + 1)
		if nextRadarData ~= nil then
	        local index = 1
			index = MakeList(unlocklist, index, 2, TextMgr:GetText("build_ui5"),building.data.level, "Lv."..building.data.level + 1)
			local text = System.String.IsNullOrEmpty(curRadarData.effect) and nextRadarData.effect or curRadarData.effect
	        index = MakeList(unlocklist, index, 2, TextMgr:GetText("build_ui_47"),TextMgr:GetText(text), TextMgr:GetText(text))
	    end
	end
	
	if sType == 14 then
		local building
        if _build ~= nil then
            building = _build
        else
            building = maincity.GetCurrentBuildingData()
        end
		
		local curTradeData = TableMgr:GetTradingPostData(building.data.level)
		local nextTradeData = TableMgr:GetTradingPostData(building.data.level + 1)
		if nextTradeData ~= nil then
	        local index = 1
			index = MakeList(unlocklist, index, 2, TextMgr:GetText("build_ui5"),building.data.level, "Lv."..building.data.level + 1)
	        index = MakeList(unlocklist, index, 1, TextMgr:GetText("TradeHall_ui7"),curTradeData.resNum, nextTradeData.resNum)
	        index = MakeList(unlocklist, index, 1, TextMgr:GetText("TradeHall_ui8"),"" .. curTradeData.rate .. "%", "" .. nextTradeData.rate .. "%")
	        if curTradeData.speedUp ~= nextTradeData.speedUp then
	        	index = MakeList(unlocklist, index, 1, TextMgr:GetText("TradeHall_ui9"),"" .. curTradeData.speedUp .. "%", "" .. nextTradeData.speedUp .. "%")
	        end
	    end
    end

	if sType == 15 then
		local building
        if _build ~= nil then
            building = _build
        else
            building = maincity.GetCurrentBuildingData()
        end
		
		local curEmbassyData = TableMgr:GetEmbassyData(building.data.level)
		local nextEmbassyData = TableMgr:GetEmbassyData(building.data.level + 1)
		if nextEmbassyData ~= nil then
	        local index = 1
			index = MakeList(unlocklist, index, 2, TextMgr:GetText("build_ui5"),building.data.level, "Lv."..building.data.level + 1)
	        index = MakeList(unlocklist, index, 1, TextMgr:GetText("Embassy_ui1"),curEmbassyData.armynum, nextEmbassyData.armynum)
	    end
	end    

	if sType == 16 then
		local building
        if _build ~= nil then
            building = _build
        else
            building = maincity.GetCurrentBuildingData()
        end
		
		local curAssembledData = TableMgr:GetAssembledData(building.data.level)
		local nextAssembledData = TableMgr:GetAssembledData(building.data.level + 1)
		if nextAssembledData ~= nil then
	        local index = 1
			index = MakeList(unlocklist, index, 2, TextMgr:GetText("build_ui5"),building.data.level, "Lv."..building.data.level + 1)
	        index = MakeList(unlocklist, index, 1, TextMgr:GetText("union_assembled_18"),curAssembledData.armynum, nextAssembledData.armynum)
	        index = MakeList(unlocklist, index, 1, TextMgr:GetText("Review_60008"),Global.ExchangeValue(curAssembledData.ResourceMax), Global.ExchangeValue(nextAssembledData.ResourceMax))
	    end
	end
	
	if sType == 17 then
		local building
        if _build ~= nil then
            building = _build
        else
            building = maincity.GetCurrentBuildingData()
        end
		local infolist = CreateEquipBuildInfos()
		local curAssembledData = infolist[building.data.level]
		local nextAssembledData = infolist[building.data.level + 1]
		if nextAssembledData ~= nil then
	        local index = 1
			index = MakeList(unlocklist, index, 2, TextMgr:GetText("build_ui5"),building.data.level, "Lv."..building.data.level + 1)
	        index = MakeList(unlocklist, index, 1, TextMgr:GetText("equip_ui48"),curAssembledData.SpeedUp .. "%", nextAssembledData.SpeedUp .. "%")
	        if nextAssembledData.Text ~= "union_nounion" then
	        	index = MakeList(unlocklist, index, 2, TextMgr:GetText("equip_ui49"),nil, TextMgr:GetText(nextAssembledData.Text))
	        end
	    end
	end

	if sType == 20 then
		local building
		if _build ~= nil then
			building = _build
		else
			building = maincity.GetCurrentBuildingData()
		end

		local curAssembledData = TableMgr:GetJailDataByLevel(building.data.level)
		local nextAssembledData = TableMgr:GetJailDataByLevel(building.data.level + 1)
		if nextAssembledData ~= nil then
	        local index = 1
			index = MakeList(unlocklist, index, 2, TextMgr:GetText("build_ui5"),building.data.level, "Lv."..building.data.level + 1)
			index = MakeList(unlocklist, index, 1, TextMgr:GetText("jail_7"),curAssembledData.Prisoner, nextAssembledData.Prisoner)
			index = MakeList(unlocklist, index, 1, TextMgr:GetText("jail_6"),Global.SecondToTimeLong(curAssembledData.Prisontime), Global.SecondToTimeLong(nextAssembledData.Prisontime))
	    end
	end

    return unlocklist
end

local function CreatLeftInfo(i)
	local childCount = upgrade_condition_grid.transform.childCount
    local info = {}
    if i - 1 < childCount then
    	info.go = upgrade_condition_grid.transform:GetChild(i - 1).gameObject
    else
    	info.go = GameObject.Instantiate(list_left_path.go)
	end
	info.go.name = "BuildingUpgradeLeftinfo"
    info.go.transform:SetParent(upgrade_condition_grid.transform, false)
    info.texture = info.go.transform:Find(list_left_path.texture):GetComponent("UITexture")
    info.text = info.go.transform:Find(list_left_path.text):GetComponent("UILabel")
    info.num = info.go.transform:Find(list_left_path.num):GetComponent("UILabel")
    info.icon_gou = info.go.transform:Find(list_left_path.icon_gou).gameObject
    info.icon_cha = info.go.transform:Find(list_left_path.icon_cha).gameObject
    info.btn_jiasu = info.go.transform:Find(list_left_path.btn_jiasu):GetComponent("UIButton")
    info.btn_go = info.go.transform:Find(list_left_path.btn_go):GetComponent("UIButton")
    info.btn_free = info.go.transform:Find(list_left_path.btn_free):GetComponent("UIButton")
    info.btn_free.gameObject:SetActive(false)
    info.btn_help = info.go.transform:Find(list_left_path.btn_help):GetComponent("UIButton")
    info.btn_help.gameObject:SetActive(false)
    info.btn_get = info.go.transform:Find(list_left_path.btn_get):GetComponent("UIButton")
    info.icon_building = info.go.transform:Find(list_left_path.icon_building).gameObject
    info.icon_laboratory = info.go.transform:Find(list_left_path.icon_laboratory).gameObject
    info.icon_barrack = info.go.transform:Find(list_left_path.icon_barrack).gameObject
    return info
end

local function CreatRightInfo(i)
	local childCount = bg_right_grid.transform.childCount
    local info = {}
    if i - 1 < childCount then
    	info.go = bg_right_grid.transform:GetChild(i - 1).gameObject
    else
    	info.go = GameObject.Instantiate(list_right_path.go)
    end
    info.go.transform:SetParent(bg_right_grid.transform, false)
    info.title_text = info.go.transform:Find(list_right_path.title_text):GetComponent("UILabel")
    info.bg_daijiantou = info.go.transform:Find(list_right_path.bg_daijiangou).gameObject
    info.bg_meijiantou = info.go.transform:Find(list_right_path.bg_meijiantou).gameObject
    info.num_left = info.go.transform:Find(list_right_path.num_left):GetComponent("UILabel")
    info.num_right = info.go.transform:Find(list_right_path.num_right):GetComponent("UILabel")
    info.text = info.go.transform:Find(list_right_path.text):GetComponent("UILabel")
    return info
end

local function RemoveLeftAt(index)
	local childCount = upgrade_condition_grid.transform.childCount
	for i = index, childCount - 1 do
        GameObject.Destroy(upgrade_condition_grid.transform:GetChild(i).gameObject)
    end
end

local function RemoveRightAt(index)
	local childCount = bg_right_grid.transform.childCount
	for i = index, childCount - 1 do
        GameObject.Destroy(bg_right_grid.transform:GetChild(i).gameObject)
    end
end

function Awake()
    bg_title = transform:Find("Container/bg_frane/bg_top/bg_title_left/title"):GetComponent("UILabel")

    btn_close = transform:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
    upgrade_condition_grid = transform:Find("Container/bg_frane/bg_left/Scroll View/Grid"):GetComponent("UIGrid")
    bg_right_texture = transform:Find("Container/bg_frane/bg_right/Texture"):GetComponent("UITexture")
    bg_right_3DShow = transform:Find("Container/bg_frane/bg_right/3DShow")
    bg_right_grid = transform:Find("Container/bg_frane/bg_right/Scroll View/Grid"):GetComponent("UIGrid")
    btn_upgrade = transform:Find("Container/bg_frane/btn_upgrade"):GetComponent("UIButton")
    btn_upgrade_time0 = transform:Find("Container/bg_frane/time0/num"):GetComponent("UILabel")
    btn_upgrade_time = transform:Find("Container/bg_frane/time/num"):GetComponent("UILabel")
    btn_upgrade_gold = transform:Find("Container/bg_frane/btn_upgrade_gold"):GetComponent("UIButton")
    btn_upgrade_gold_num = transform:Find("Container/bg_frane/btn_upgrade_gold/num"):GetComponent("UILabel")
    upgrade_left_info = transform:Find("BuildingUpgradeLeftinfo")
    upgrade_right_info = transform:Find("BuildingUpgradeRightinfo")

    list_left_path = {}
    list_left_path.go = transform:Find("BuildingUpgradeLeftinfo").gameObject
    list_left_path.texture = "bg/Texture"
    list_left_path.icon_building = "bg/icon/icon_building"
    list_left_path.icon_laboratory = "bg/icon/icon_laboratory"
    list_left_path.icon_barrack = "bg/icon/icon_barrack"
    list_left_path.text = "bg/text"
    list_left_path.num = "bg/num"
    list_left_path.icon_gou = "bg/icon_gou"
    list_left_path.icon_cha = "bg/icon_cha"
    list_left_path.btn_jiasu = "bg/btn_jiasu"
    list_left_path.btn_go = "bg/btn_go"
    list_left_path.btn_free = "bg/btn_free"
    list_left_path.btn_get = "bg/btn_get"
    list_left_path.btn_help = "bg/btn_help"

    list_right_path = {}
    list_right_path.go = transform:Find("BuildingUpgradeRightinfo").gameObject
    list_right_path.title_text = "bg_title/text"
    list_right_path.bg_daijiangou = "bg_daijiantou"
    list_right_path.num_left = "bg_daijiantou/num_left"
    list_right_path.num_right = "bg_daijiantou/num_right"
    list_right_path.bg_meijiantou = "bg_meijiantou"
    list_right_path.text = "bg_meijiantou/text"

    list_upgrade_left_info = {}
    list_upgrade_right_info = {}
	
end

local function GetWorkCD(cd)
    local params = {}
    params.base = cd
    return AttributeBonus.CallBonusFunc(3,params)
end

function SetBtnEnable(_btn, _isEnable, enable, disable)
	local _color
	if _isEnable then
		_color = Color.white * 1
	else
		_color = Color.white * 0.7
	end
	_btn:GetComponent("UISprite").spriteName = _isEnable and enable or disable
	_btn.normalSprite = _isEnable and enable or disable
	local _text = _btn.transform:Find("text")
	if _text ~= nil then
		_text:GetComponent("UILabel").gradientTop = _color
		_text:GetComponent("UILabel").gradientBottom = _color
	end
	local _num = _btn.transform:Find("num")
	if _num ~= nil then
		_num:GetComponent("UILabel").gradientTop = _color
		_num:GetComponent("UILabel").gradientBottom = _color
	end
	local _gold = _btn.transform:Find("icon_gold")
	if _gold ~= nil then
		_gold:GetComponent("UISprite").color = _color
	end
end

local function ShopBuyRequest(useItemId , exItemid , count)
	local req = ShopMsg_pb.MsgCommonShopBuyRequest()
	req.exchangeId = exItemid
	req.num = count
	Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgCommonShopBuyRequest, req, ShopMsg_pb.MsgCommonShopBuyResponse, function(msg)
        if msg.code == 0 then
			local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
			if price == 0 then
				GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
			else
				GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
			end
			AudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
			for i=1 , #msg.reward.item.item , 1 do
				local item_data = TableMgr:GetItemData(msg.reward.item.item[i].baseid)
				FloatText.Show(TextUtil.GetItemName(item_data).."x"..msg.reward.item.item[i].num , Color.green,ResourceLibrary:GetIcon("Item/", item_data.icon))
			end
			MainCityUI.UpdateRewardData(msg.fresh)
		else
			Global.FloatError(msg.code, Color.white)
		end
    end, true)
end

local function Init()
	if transform == nil or transform:Equals(nil) then
		return
	end
	AttributeBonus.CollectBonusInfo()
	local intStart = Serclimax.GameTime.GetMilSecTime()
	canClick = true
    canClick_gold = true
	
    if targetBuilding ~= nil then
        building = targetBuilding
    else
        building = maincity.GetCurrentBuildingData()
	end
	targetBuilding = building
    if building == nil or building.buildingData == nil or building.upgradeData == nil or building.data == nil then
        return
    end
	if building.data.level == building.buildingData.levelMax then
		GUIMgr:CloseMenu("BuildingUpgrade")
		return
	end
	--print(building.data.uid)
	if bg_title == nil then
		return
	end
    bg_title.text = TextMgr:GetText(building.buildingData.name).."Lv."..building.data.level
    
    local enable_upgrade = true
    local enable_gold_upgrade = true

    btn_upgrade_time0.text = System.String.Format(TextMgr:GetText("time_old"), Serclimax.GameTime.SecondToString3(building.upgradeData.workerCD)) -- 原始升级时间
    if building.data.donetime <= Serclimax.GameTime.GetSecTime() then
        btn_upgrade_time.text = System.String.Format(TextMgr:GetText("time_now"), Serclimax.GameTime.SecondToString3(GetWorkCD(building.upgradeData.workerCD)))
        CountDown.Instance:Remove("Upgrade")
    else
        CountDown.Instance:Add("Upgrade",building.data.donetime,CountDown.CountDownCallBack(function(t)
        	if btn_upgrade_time ~= nil and not btn_upgrade_time:Equals(nil) then
            	btn_upgrade_time.text = System.String.Format(TextMgr:GetText("time_now"), t)
            end
        end))
    end
    local nextList = GetCurrentBuildingNextUnlock(building)
    local rightcount = 0
    for i, v in ipairs(nextList) do
        local r = CreatRightInfo(i)
        rightcount = i
        r.title_text.text = v.title
        if v.type == 1 then
            r.bg_meijiantou:SetActive(false)
            r.bg_daijiantou:SetActive(true)
            r.num_left.text = v.text1
            r.num_right.text = v.text2
        else
            r.bg_daijiantou:SetActive(false)
            r.bg_meijiantou:SetActive(true)
            r.text.text = v.text2
        end
    end
    RemoveRightAt(rightcount)
    local upgrading = maincity.GetUpgradingBuildList()
    local leftcount = 0
	
    local selfupgrade = false
	--local haveGradeQueue = #upgrading >= 0 and #upgrading < 2--双队列临时，该值应读表
    if #upgrading > 0 then
		for i=1 , #upgrading , 1 do
			if selfupgrade == false then
				selfupgrade = building == upgrading[i]
			end
			leftcount = leftcount + 1
			local l = CreatLeftInfo(leftcount)
			l.text.text = String.Format(TextMgr:GetText("build_ui31"), TextMgr:GetText(upgrading[i].buildingData.name))
			l.texture.gameObject:SetActive(true)
			l.texture.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "building/", upgrading[i].buildingData.icon)
			l.icon_building:SetActive(true)
			l.icon_building.transform.parent.gameObject:SetActive(false)
			local _build = upgrading[i]
			local finish = function(go)
				local req = BuildMsg_pb.MsgAccelBuildUpdateRequest()
				req.uid = _build.data.uid
				Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgAccelBuildUpdateRequest, req, BuildMsg_pb.MsgAccelBuildUpdateResponse, function(msg)
					if msg.code == 0 then
						AudioMgr:PlayUISfx("SFX_UI_building_speed", 1, false)
						maincity.UpdateBuildInMsg(msg.build, msg.build.donetime)
						MainCityUI.UpdateRewardData(msg.fresh)
						CommonItemBag.SetInitFunc(nil)
						GUIMgr:CloseMenu("CommonItemBag")
						MainCityQueue.UpdateQueue()
						needRefreshMaincity = true
					else
						Global.FloatError(msg.code, Color.white)
					end
				end, true)
			end
			local cancelreq = function()
				local req = BuildMsg_pb.MsgCancelBuildUpdateRequest()
				req.uid = _build.data.uid
				Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgCancelBuildUpdateRequest, req, BuildMsg_pb.MsgCancelBuildUpdateResponse, function(msg)
					if msg.code == 0 then
						AudioMgr:PlayUISfx("SFX_UI_building_levelupcancel", 1, false)
						maincity.UpdateBuildInMsg(msg.build, msg.build.donetime)
						MainCityUI.UpdateRewardData(msg.fresh)
						CommonItemBag.SetInitFunc(nil)
						GUIMgr:CloseMenu("CommonItemBag")
						MainCityQueue.UpdateQueue()
						MainCityUI.NotifyCancelUpgradeListener()
					else
						Global.FloatError(msg.code, Color.white)
					end
				end)
			end
			local cancel = function(go)
				MessageBox.Show(TextMgr:GetText("speedup_ui10"), cancelreq, function() end)
			end
			local opencommonitembag = function()
				AudioMgr:PlayUISfx("SFX_ui01", 1, false)
				local noitem = Global.BagIsNoItem(maincity.GetItemExchangeList(1))
				if noitem then
					AudioMgr:PlayUISfx("SFX_ui02", 1, false)
					FloatText.Show(TextMgr:GetText("speedup_ui13"), Color.white)
					return
				end
				CommonItemBag.SetTittle(TextMgr:GetText("build_ui21"))
				CommonItemBag.NotUseAutoClose()
				CommonItemBag.NeedItemMaxValue()
				CommonItemBag.SetItemList(maincity.GetItemExchangeList(1), 1)
				CommonItemBag.SetMsgText("purchase_confirmation2", "b_today")
				CommonItemBag.SetInitFunc(function()
					local _text = String.Format("{0}  LV. {1}", TextMgr:GetText(_build.buildingData.name), _build.data.level + 1)
					local _time = _build.data.donetime
					local _totalTime = _build.data.originaltime
					return _text, _time, _totalTime, finish, cancel, finish, 1, function() UnionHelpData.RequestBuildHelp(_build.data.uid) end, _build.data.createtime, _build.data.uid
				end)
				CommonItemBag.SetUseFunc(function(useItemId , exItemid , count)
					MainCityUI.UseExItemFuncEx(_build, useItemId, exItemid, count)
				end)
				GUIMgr:CreateMenu("CommonItemBag" , false)
				CommonItemBag.OnOpenCB = function()
				end
			end
			
			local setBtnStatus = function(t)
				if l.num ~= nil and not l.num:Equals(nil) then
					l.num.text = t
					l.num.gameObject:SetActive(true)
					if upgrading[i].data.donetime > Serclimax.GameTime.GetSecTime() then
						if upgrading[i].data.donetime - Serclimax.GameTime.GetSecTime() <= maincity.freetime() then
							l.btn_free.gameObject:SetActive(true)
							l.btn_jiasu.gameObject:SetActive(false)
							l.btn_help.gameObject:SetActive(false)
						elseif UnionInfoData.HasUnion(upgrading[i].data.uid) and upgrading[i].data.createtime >= UnionInfoData.GetJoinTime() then
							if UnionHelpData.HasBuildHelp(upgrading[i].data.uid) then
								l.btn_free.gameObject:SetActive(false)
								l.btn_jiasu.gameObject:SetActive(false)
								l.btn_help.gameObject:SetActive(true)
							else
								l.btn_free.gameObject:SetActive(false)
								l.btn_jiasu.gameObject:SetActive(true)
								l.btn_help.gameObject:SetActive(false)
							end
						else
							l.btn_free.gameObject:SetActive(false)
							l.btn_jiasu.gameObject:SetActive(true)
							l.btn_help.gameObject:SetActive(false)
						end
						
						if building == upgrading[i] then
							btn_upgrade_gold_num.text = Mathf.Ceil(maincity.CaculateGoldForTime(1, math.max(0, upgrading[i].data.donetime - Serclimax.GameTime.GetSecTime() - maincity.freetime())))
							btn_upgrade_gold.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("build_ui36")
							if upgrading[i].data.donetime - Serclimax.GameTime.GetSecTime() <= maincity.freetime() then
								btn_upgrade.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("speedup_ui7")
								SetClickCallback(btn_upgrade.gameObject, function() maincity.FinishBuild(upgrading[i]) end)
								SetBtnEnable(btn_upgrade, true, "btn_free", "btn_free")
							elseif UnionInfoData.HasUnion() and upgrading[1].data.createtime >= UnionInfoData.GetJoinTime() then
								if UnionHelpData.HasBuildHelp(upgrading[i].data.uid) then
									btn_upgrade.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("union_help")
									SetClickCallback(btn_upgrade.gameObject, function() UnionHelpData.RequestBuildHelp(upgrading[i].data.uid , setBtnStatus) end)
									SetBtnEnable(btn_upgrade, true, "btn_2", "btn_2")
								else
									btn_upgrade.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("build_ui21")
									SetClickCallback(btn_upgrade.gameObject, opencommonitembag)
									SetBtnEnable(btn_upgrade, true, "btn_7", "btn_4")
								end
							else
								btn_upgrade.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("build_ui21")
								SetClickCallback(btn_upgrade.gameObject, opencommonitembag)
								SetBtnEnable(btn_upgrade, true, "btn_7", "btn_4")
							end
							SetClickCallback(btn_upgrade_gold.gameObject, finish)
						end
					end
				end
			end
			--setBtnStatus()
			CountDown.Instance:Add(building.data.uid .. "Upgrading",upgrading[i].data.donetime + 2, function(t)
				setBtnStatus(t)
				if t == "00:00:00" then
					CountDown.Instance:Remove(building.data.uid .. "Upgrading")
					needRefreshMaincity = true
					Init()
				end
			end)
			l.btn_get.gameObject:SetActive(false)
			l.icon_gou:SetActive(false)
			l.icon_cha:SetActive(false)
			if upgrading[i].data.donetime - Serclimax.GameTime.GetSecTime() <= maincity.freetime() then
				l.btn_free.gameObject:SetActive(true)
				l.btn_jiasu.gameObject:SetActive(false)
				l.btn_help.gameObject:SetActive(false)
			elseif UnionInfoData.HasUnion() and upgrading[i].data.createtime >= UnionInfoData.GetJoinTime() then
				if UnionHelpData.HasBuildHelp(upgrading[i].data.uid) then
					l.btn_free.gameObject:SetActive(false)
					l.btn_jiasu.gameObject:SetActive(false)
					l.btn_help.gameObject:SetActive(true)
				else
					l.btn_free.gameObject:SetActive(false)
					l.btn_jiasu.gameObject:SetActive(true)
					l.btn_help.gameObject:SetActive(false)
				end
			else
				l.btn_free.gameObject:SetActive(false)
				l.btn_jiasu.gameObject:SetActive(true)
				l.btn_help.gameObject:SetActive(false)
			end
			SetClickCallback(l.btn_free.gameObject, function(go)
				l.btn_free.gameObject:SetActive(false)
				maincity.FinishBuild(upgrading[i])
			end)
			l.btn_go.gameObject:SetActive(false)
			enable_upgrade = enable_upgrade and false
			--enable_gold_upgrade = enable_gold_upgrade and false
			SetClickCallback(l.btn_jiasu.gameObject, opencommonitembag)
			SetClickCallback(l.btn_help.gameObject, function() UnionHelpData.RequestBuildHelp(upgrading[i].data.uid) end)
		end
		if (#upgrading < 2 and maincity.GetBuildQueueNum() < 2) and Serclimax.GameTime.GetSecTime() >= MainData.GetRentBuildQueueExpire() then
			leftcount = leftcount + 1
			local l = CreatLeftInfo(leftcount)
			l.text.text = TextMgr:GetText("maincity_ui17")
			l.num.text = ""
			l.texture.gameObject:SetActive(false)
			l.icon_building:SetActive(true)
			l.icon_building.transform.parent.gameObject:SetActive(true)
			l.btn_get.gameObject:SetActive(false)
			l.icon_gou:SetActive(false)
			l.icon_cha:SetActive(false)
			l.btn_free.gameObject:SetActive(false)
			l.btn_jiasu.gameObject:SetActive(false)
			l.btn_help.gameObject:SetActive(false)
			l.btn_go.gameObject:SetActive(true)
			SetClickCallback(l.btn_go.gameObject, function()
				if Event.HasEvent(33) then
					if ItemListData.GetItemCountByBaseId(9101) > 0 then
						Event.Check(33)
					end
				else
					QueueLease.Show()
					--VIP.Show(Global.CheckBuildQueue(2))
				end
			end)
		end
    else
    	CountDown.Instance:Remove(building.data.uid .. "Upgrading")
    end
	local precondition = maincity.GetCurrentUpgradePrecondition(building)
	local function isUpgrading(id)
		for i, v in ipairs(upgrading) do
			if tonumber(v.data.type) == tonumber(id) then
				return true
			end
		end
		return false
	end
	local preconditionenough = true
    if precondition ~= nil then
        for i, v in ipairs(precondition) do
        	local _d = TableMgr:GetBuildingData(v.id)
        	local str
        	leftcount = leftcount + 1
			local l = CreatLeftInfo(leftcount)
			l.go.name = "BuildingUpgradeLeftinfo" .. v.id
			l.icon_building:SetActive(false)
			l.icon_building.transform.parent.gameObject:SetActive(false)
        	if tonumber(v.type) == 1 then
        		local isenough, lv = maincity.CheckLevelByID(v.id, v.value)
        		if not isenough then
        			str = "[ff0000]" .. TextMgr:GetText(_d.name) .. " : LV" .. v.value
        			l.icon_gou:SetActive(false)
					l.icon_cha:SetActive(true)
					preconditionenough = false
		    		l.btn_go.gameObject:SetActive(not isUpgrading(v.id))
		    		enable_upgrade = enable_upgrade and false
		        	enable_gold_upgrade = enable_gold_upgrade and false
		    		SetClickCallback(l.btn_go.gameObject, function(go)
						AudioMgr:PlayUISfx("SFX_ui01", 1, false)
						local bigcollider = NGUITools.AddChild(GUIMgr.UITopRoot.gameObject, ResourceLibrary.GetUIPrefab("MainCity/BigCollider"))
						maincity.SetTargetBuild(v.id, false, nil, false, false, true, function(_b)
							GameObject.DestroyImmediate(bigcollider)
							if _b == nil then
								return
							end
							if lv > 0 then
								SetTargetBuilding(_b)
								GUIMgr:CreateMenu("BuildingUpgrade", false)
								MainCityUI.HideCityMenu()
								BuildingUpgrade.OnCloseCB = function()
									MainCityUI.RemoveMenuTarget()
									BuildingShowInfoUI.Refresh()
								end
							end
						end)
		    			OnCloseCB = nil
		    			if ResView.gameObject ~= nil and not ResView.gameObject:Equals(nil) then
		    				GUIMgr:CloseMenu("ResView")
		    			end
		    			if ResViewDetails.gameObject ~= nil and not ResViewDetails.gameObject:Equals(nil) then
		    				GUIMgr:CloseMenu("ResViewDetails")
		    			end
		    			GUIMgr:CloseMenu("BuildingUpgrade")
		    		end)
        		else
        			str = TextMgr:GetText(_d.name) .. " : LV" .. v.value
        			l.icon_gou:SetActive(true)
		    		l.icon_cha:SetActive(false)
		    		l.btn_go.gameObject:SetActive(false)
        		end
        	elseif tonumber(v.type) == 2 then
        		local count = maincity.GetBuildingCount(v.id)
        		if count >= tonumber(v.value) then
        			str = TextMgr:GetText(_d.name) .. "X" .. v.value
        		else
        			str = TextMgr:GetText(_d.name) .. "X" .. count
        		end
        	end
        	l.text.gameObject:SetActive(true)
        	l.text.text = str
        	l.texture.gameObject:SetActive(true)
	        l.texture.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "building/", _d.icon)
	        l.num.text = ""
	        l.num.gameObject:SetActive(false)
	        l.btn_jiasu.gameObject:SetActive(false)
	        l.btn_get.gameObject:SetActive(false)
        end
    end
    local res = maincity.GetCurrentUpgradeResource(building)
    local needgold = false
    if res ~= nil then
        for i, v in ipairs(res) do
        	leftcount = leftcount + 1
            local l = CreatLeftInfo(leftcount)
			l.icon_building:SetActive(false)
			l.icon_building.transform.parent.gameObject:SetActive(false)
            l.text.text = ""
            l.text.gameObject:SetActive(true)
			l.num.gameObject:SetActive(false)
			local needid = tonumber(v.id)
			local r
			if needid >= 15001 and needid <= 15004 then
				local itembagdata = ItemListData.GetItemDataByBaseId(needid)
				if itembagdata ~= nil then
					r = itembagdata.number
				end
			else
				r = MoneyListData.GetMoneyByType(needid)
			end
            if r == nil then
                r = 0
            end
            l.texture.gameObject:SetActive(true)
            l.texture.mainTexture = ResourceLibrary:GetIcon("Item/", TableMgr:GetItemData(v.id).icon)
            if tonumber(r) < tonumber(v.num) then
            	l.text.text = System.String.Format("[ff0000]{0}[ffffff]  /  {1}", Global.ExchangeValue(tonumber(r)),Global.ExchangeValue(tonumber(v.num)))
                l.icon_gou:SetActive(false)
                l.icon_cha:SetActive(true)
                l.btn_get.gameObject:SetActive(true)
                SetClickCallback(l.btn_get.gameObject, function(go)
					AudioMgr:PlayUISfx("SFX_ui01", 1, false)
					local commonbagtitle
					local reslistid = needid
					if needid >= 15001 and needid <= 15004 then
						reslistid = needid - 14975
						commonbagtitle = TextMgr:GetText("get_resource5")
						CommonItemBag.SetUseFunc(ShopBuyRequest)
					else
						commonbagtitle = TextMgr:GetText("get_resource" .. (needid - 2))
						CommonItemBag.SetUseFunc(maincity.UseResItemFunc)
					end
					local ResList = maincity.GetItemResList(reslistid)
		        	local noitem = Global.BagIsNoItem(ResList)
		        	if noitem then
		        		AudioMgr:PlayUISfx("SFX_ui02", 1, false)
		        		FloatText.Show(TextMgr:GetText("player_ui18"), Color.white)
		        		return
					end
		        	CommonItemBag.SetTittle(commonbagtitle)
			        CommonItemBag.NotUseAutoClose()
					CommonItemBag.SetResType(v.id)
					if needid >= 15001 and needid <= 15004 then
						CommonItemBag.SetItemList(ResList, 5)
					else
						CommonItemBag.SetItemList(ResList, 0)
					end
					CommonItemBag.OnCloseCB = Init
					GUIMgr:CreateMenu("CommonItemBag" , false)
		        end)
                needgold = true
                enable_upgrade = enable_upgrade and false
            else
            	l.text.text = System.String.Format("{0}  /  {1}", Global.ExchangeValue(tonumber(r)),Global.ExchangeValue(tonumber(v.num)))
                l.icon_cha:SetActive(false)
                l.icon_gou:SetActive(true)
                l.btn_get.gameObject:SetActive(false)
            end
            l.btn_jiasu.gameObject:SetActive(false)
            l.btn_go.gameObject:SetActive(false)
        end
    end
    RemoveLeftAt(leftcount)
    local gold = 0
    if needgold then
		for i, v in pairs(res) do
			local needid = tonumber(v.id)
			local resleft
			if needid >= 15001 and needid <= 15004 then
				local itembagdata = ItemListData.GetItemDataByBaseId(needid)
				if itembagdata ~= nil then
					resleft = tonumber(v.num) - itembagdata.number
				else
					resleft = tonumber(v.num)
				end
			else
				resleft = tonumber(v.num) - MoneyListData.GetMoneyByType(needid)
			end
			if resleft > 0 then
				gold = gold + maincity.CaculateGoldForRes(v.id, resleft)
			end
    	end
    	gold = Mathf.Ceil(gold - 0.5)
	end
    local params = {}
    params.base = building.upgradeData.workerCD
	gold = gold + math.max(0, maincity.CaculateGoldForTime(1, AttributeBonus.CallBonusFunc(3, params) - maincity.freetime()))
	gold = Mathf.Ceil(gold - 0.5)
    if gold <= 0 then
    	gold = 0
	end
    btn_upgrade_gold_num.text = gold
    if gold > MoneyListData.GetDiamond() then
        enable_gold_upgrade = enable_gold_upgrade and false
    end
    
    local coroutine = coroutine.start(function()
        coroutine.step()
        if bg_right_grid == nil then
            return
        end
        bg_right_grid:Reposition()
        upgrade_condition_grid:Reposition()
    end)
    bg_right_texture.gameObject:SetActive(false);
	--bg_right_texture.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "building/", building.buildingData.icon)
	--print(building.buildingData.icon)
	if bg_right_3DShow_obj == nil then
	bg_right_3DShow_obj = ResourceLibrary:GetMainCityInstance(building.buildingData.icon)
	bg_right_3DShow_obj.transform.parent = bg_right_3DShow
	bg_right_3DShow_obj.transform.localPosition = Vector3.zero
	bg_right_3DShow_obj.transform.localScale = Vector3.one;
	end
	
	if not(selfupgrade) then
		SetBtnEnable(btn_upgrade, enable_upgrade or selfupgrade or maincity.HasFreeQueue(), "btn_1", "btn_4")
		SetBtnEnable(btn_upgrade_gold, enable_gold_upgrade, "btn_2", "btn_4")

		btn_upgrade.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("build_ui8")
		btn_upgrade_gold.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("build_ui9")
	
		SetClickCallback(btn_upgrade.gameObject, function (go)
			local upStart = Serclimax.GameTime.GetMilSecTime()
			--if maincity.GetWorkerIsInCooldown() then
			--	AudioMgr:PlayUISfx("SFX_ui02", 1, false)
			--	FloatText.ShowAt(btn_upgrade.transform.position, TextMgr:GetText("build_ui7"), Color.white)
			--else
				if canClick then
					canClick = false
					if enable_upgrade then
						AudioMgr:PlayUISfx("SFX_ui01", 1, false)
					else
						AudioMgr:PlayUISfx("SFX_ui02", 1, false)
					end
					local beginrequest = function()
						local reqstart = Serclimax.GameTime.GetMilSecTime()
						
						local req = BuildMsg_pb.MsgUpgradeBuildRequest()
						req.uid = building.data.uid
						req.type = BuildMsg_pb.BuildUpgradeType_Worker
						Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgUpgradeBuildRequest, req, BuildMsg_pb.MsgUpgradeBuildResponse, function(msg)
							
							--print(Serclimax.GameTime.GetMilSecTime() -reqstart )
							local loadStart = Serclimax.GameTime.GetMilSecTime()
							
							if msg.code == 0 then
								if building.data.type == 26 and building.data.level >= 3 then
									Event.Resume(30)
								end
								if building.data.type == 26 and building.data.level >= 1 then
									Event.Resume(15)
								end
								if building.data.type == 1 and building.data.level >= 2 then
									Event.Resume(16)
								end
								if building.data.type == 1 and building.data.level >= 3 then
									Event.Resume(24)
								end
								if building.data.type == 1 and building.data.level >= 4 then
									Event.Resume(32)
								end
								if building.data.type == 1 and building.data.level >= 5 then
									Event.Resume(40)
								end
								--[[ if (building.data.type == 26 or building.data.type == 11) and building.data.level >= 3 then
									if ItemListData.GetItemCountByBaseId(9101) > 0 then
										Event.Check(33)
									end
								end ]]
								maincity.RefreshBuildingList(msg)
								MainCityUI.UpdateRewardData(msg.fresh)
								--GUIMgr:CloseMenu("BuildingUpgrade")
								MainCityUI.GetBuildResource(building.data.uid , building.land)
								needRefreshMaincity = true
								if not FunctionListData.IsUnlocked(140) then
									GUIMgr:CloseMenu("BuildingUpgrade")
								end
							else
								if btn_upgrade ~= nil or not btn_upgrade:Equals(nil) or btn_upgrade.transform ~= nil or not btn_upgrade.transform:Equals(nil) then
									Global.FloatErrorAt(btn_upgrade.transform.position, msg.code, Color.white)
									canClick = true
								end
								if msg.code == ReturnCode_pb.Code_Build_BuildLevelNotEnough then
									maincity.GetBuildingListData(building.data.uid)
								end
								if maincity.GetBuildQueueNum() == 1 and #maincity.GetUpgradingBuildList() > 0 then
									Event.Check(33)
								end
							end
							
							--print(Serclimax.GameTime.GetMilSecTime() -loadStart )
						end, false)
					end
					if building.data.type == 1 and building.data.level + 1 == tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.NewbieShieldLevel).value) and BuffData.HasNewbieShield() then
						MessageBox.Show(System.String.Format(TextMgr:GetText("newbieshield"), building.data.level + 1), beginrequest, function() canClick = true end)
					else
						beginrequest()
					end
				end
			--end
		end)

		SetClickCallback(btn_upgrade_gold.gameObject, function (go)
			if canClick_gold then
				-- local goldNeeded = tonumber(btn_upgrade_gold_num.text)
				-- MessageBox.ShowConfirmation(enable_gold_upgrade and goldNeeded ~= 0, System.String.Format(TextMgr:GetText("purchase_confirmation2"), goldNeeded, TextMgr:GetText(building.buildingData.name) .. "LV. " .. (targetBuilding.data.level + 1)), function()
					canClick_gold = false
					if enable_gold_upgrade then
						AudioMgr:PlayUISfx("SFX_ui01", 1, false)
					else
						AudioMgr:PlayUISfx("SFX_ui02", 1, false)
					end
					
					local beginrequest = function()
						local reqstart = Serclimax.GameTime.GetMilSecTime()
						local req = BuildMsg_pb.MsgUpgradeBuildRequest()
						req.uid = building.data.uid
						req.type = BuildMsg_pb.BuildUpgradeType_Gold
						--print(Serclimax.GameTime.GetMilSecTime() - reqstart)
						Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgUpgradeBuildRequest, req, BuildMsg_pb.MsgUpgradeBuildResponse, function(msg)
							
							--print(Serclimax.GameTime.GetMilSecTime() - reqstart)
							local loadStart = Serclimax.GameTime.GetMilSecTime()
							if msg.code == 0 then
								if building.data.type == 26 and building.data.level >= 3 then
									Event.Resume(30)
								end
								if building.data.type == 26 and building.data.level >= 1 then
									Event.Resume(15)
								end
								if building.data.type == 1 and building.data.level >= 2 then
									Event.Resume(16)
								end
								if building.data.type == 1 and building.data.level >= 3 then
									Event.Resume(24)
								end
								if building.data.type == 1 and building.data.level >= 4 then
									Event.Resume(32)
								end
								if building.data.type == 1 and building.data.level >= 5 then
									Event.Resume(40)
								end
								--[[ if (building.data.type == 26 or building.data.type == 11) and building.data.level >= 3 then
									if ItemListData.GetItemCountByBaseId(9101) > 0 then
										Event.Check(33)
									end
								end ]]
								--send data report-----------------------------------
								GUIMgr:SendDataReport("purchase", "costgold", "build upgrade:" ..building.buildingData.id, "1", "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))
								-----------------------------------------------------
							
								if building.state == 1 then
									MainCityUI.GetBuildResource(building.data.uid , building.land)
								end
								CountDown.Instance:Remove("Upgrade")
								maincity.RefreshBuildingList(msg)
								MainCityUI.UpdateRewardData(msg.fresh)
								needRefreshMaincity = true
								if msg.build.level == building.buildingData.levelMax then
									GUIMgr:CloseMenu("BuildingUpgrade")
								end
								AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
								FloatText.Show(TextMgr:GetText("build_ui39"), Color.green)
								MainCityQueue.UpdateQueue()
								--print(Serclimax.GameTime.GetMilSecTime() - loadStart)
							else
								if btn_upgrade_gold ~= nil and not btn_upgrade_gold:Equals(nil) then
									Global.FloatErrorAt(btn_upgrade_gold.transform.position, msg.code, Color.red)
								end
							end
						end, true)
					end
					if not preconditionenough then
						FloatText.ShowAt(btn_upgrade_gold.transform.position, TextMgr:GetText("Code_Build_BuildLevelNotEnough"), Color.red)
						return
					end
					if gold > MoneyListData.GetMoneyByType(Common_pb.MoneyType_Diamond) then
						Global.ShowNoEnoughMoney()
						canClick_gold = true
						return
					end
					if building.data.type == 1 and building.data.level + 1 == tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.NewbieShieldLevel).value) and BuffData.HasNewbieShield() then
						MessageBox.Show(System.String.Format(TextMgr:GetText("newbieshield"), building.data.level + 1), function()
							if gold > tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.GoldLimitWarning).value) then
								if tonumber(os.date("%d")) == UnityEngine.PlayerPrefs.GetInt("b_today") then
									MessageBox.SetOkNow()
								else
									MessageBox.SetRemberFunction(function(ishide)
										if ishide then
											UnityEngine.PlayerPrefs.SetInt("b_today",tonumber(os.date("%d")))
											UnityEngine.PlayerPrefs.Save()
										end
									end)
								end
								MessageBox.Show(System.String.Format(TextMgr:GetText("purchase_confirmation2"), gold, TextMgr:GetText(building.buildingData.name)), beginrequest, function() canClick_gold = true end)
							else
								beginrequest()
							end
						end, function() canClick_gold = true end)
					else
						if gold > tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.GoldLimitWarning).value) then
							print(tonumber(os.date("%d")), UnityEngine.PlayerPrefs.GetInt("b_today"))
							if tonumber(os.date("%d")) == UnityEngine.PlayerPrefs.GetInt("b_today") then
								MessageBox.SetOkNow()
							else
								MessageBox.SetRemberFunction(function(ishide)
									print(ishide)
									if ishide then
										UnityEngine.PlayerPrefs.SetInt("b_today",tonumber(os.date("%d")))
										UnityEngine.PlayerPrefs.Save()
									end
								end)
							end
							MessageBox.Show(System.String.Format(TextMgr:GetText("purchase_confirmation2"), gold, TextMgr:GetText(building.buildingData.name)), beginrequest, function() canClick_gold = true end)
						else
							beginrequest()
						end
					end
				-- end)
			end
		end)
	end
	--print(Serclimax.GameTime.GetMilSecTime() - intStart)
end

function Start()
	isOpen = true
	needRefreshMaincity = false
    SetClickCallback(btn_close.gameObject, function (go)
    	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
        GUIMgr:CloseMenu("BuildingUpgrade")
    end)
    SetClickCallback(transform:Find("Container").gameObject, function()
    	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
    	GUIMgr:CloseMenu("BuildingUpgrade") 
    end)
    maincity.SetBuildCallBack(function() Init() end)
	
	local reqStart = Serclimax.GameTime.GetMilSecTime()
    Init()
    
	UnionHelpData.AddListener(Init)
	VipData.AddListener(Init)
	--print(Serclimax.GameTime.GetMilSecTime() - reqStart)
end

function Close()
	isOpen = false
	if building.data ~= nil then
		CountDown.Instance:Remove(building.data.uid .. "Upgrading")
	end
    CountDown.Instance:Remove("Upgrade")
	UnionHelpData.RemoveListener(Init)
	VipData.RemoveListener(Init)
	maincity.ClearFinishBuildCallBack()
    if OnCloseCB ~= nil then
    	OnCloseCB()
    	OnCloseCB = nil
    end
    bg_title = nil
	btn_close = nil
	upgrade_condition_grid = nil
	bg_right_texture = nil
	bg_right_3DShow = nil
	bg_right_3DShow_obj = nil
	bg_right_grid = nil
	btn_upgrade = nil
	btn_upgrade_time = nil
	btn_upgrade_gold = nil
	btn_upgrade_gold_num = nil
	upgrade_left_info = nil
	upgrade_right_info = nil
	list_upgrade_left_info = nil
	list_upgrade_right_info = nil
	list_left_path = nil
	list_right_path = nil
	targetBuilding = nil
	if needRefreshMaincity then
		coroutine.start(function()
			coroutine.wait(0.5)
			maincity.UpdateConstruction()
		end)
	end
end

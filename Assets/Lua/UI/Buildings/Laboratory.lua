module("Laboratory",package.seeall)

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
local GameTime = Serclimax.GameTime

OnCloseCB = nil

local TechTreeData

local TechTreeDataIDMap

local TechListData

local TechTreeMap

local TechPriorityQueue

local TechList

local TechUI

local TechState

local SetupTechItem

local SetupListItem

local DisplayTechTree

local DisplayTechList

local FillTech

local ConnectTech

local ActiveConnectTech

local RefushNextGroup

local RefushTechUpgradeUnlock4Tech

local ClearUIAttribute

local recommendedTechnologies
local numRecommended

local LinkTag = {
	{1,1},
	{3,2},
	{5,4},
	{6,6},
	{2,1},
	{4,3},
	{6,5},	
}

function GetTechCostTime(basetime)
    local params = {}
    params.base = basetime
    params.labbuild = 0

    local build = maincity.GetBuildingByID(6)

	local lab_table = TableMgr:GetBuildLaboratoryTable()
	for _ ,v in pairs(lab_table) do
		local data = v
		if (build.data.level) == (data.BuildLevel) then
		    params.labbuild = data.TechAccl
		    break
		end
	end
	--[[local iter = lab_table:GetEnumerator()
	while iter:MoveNext() do
		local data = iter.Current.Value
		if (build.data.level) == (data.BuildLevel) then
		    params.labbuild = data.TechAccl
		    break
		end
	end    ]]
    return AttributeBonus.CallBonusFunc(13,params)
end

function GetCurUpgradeTech()
    if TechState ~= nil then
        return TechState.CurUpgradeTech;
    end
    return nil
end

local function ClearTechProgress()
    if TechUI == nil or TechUI.TechProgress == nil then
        return
    end
    TechUI.TechProgress.Des.text = TextMgr:GetText("build_ui38")
    TechUI.TechProgress.Slider.value = 0
    TechUI.TechProgress.Time.text = ""
    TechUI.TechProgress.Btn.gameObject:SetActive(false)
    TechUI.TechProgress.Root:SetActive(false)
    TechUI.Recommendation.gameObject:SetActive(true)
    -- TechUI.TechProgress.FreeRoot:SetActive(true)
end

function GetTech(tech_id)
    return TechTreeDataIDMap[tech_id]
end

function OpenTech(tech_id)
    LaboratoryUpgrade.SetTargetTech(GetTech(tech_id),true)
    GUIMgr:CreateMenu("LaboratoryUpgrade", false)
end

local function SortPriorityQueue()
	table.sort(TechPriorityQueue, function(technology1, technology2)
		if technology1.CostTime ~= technology2.CostTime then
			return technology1.CostTime < technology2.CostTime
		end

		return technology1.TechId < technology2.TechId
	end)
end

local function InitializePriorityQueue()
	TechPriorityQueue = {}
	for _, catagory in pairs(TechTreeData) do
		for _, technology in pairs(catagory) do
			local levelAcquired = technology.Info.level
			for level, data in ipairs(technology) do
				if level > levelAcquired then
					table.insert(TechPriorityQueue, data)
					break
				end
			end
		end
	end

	SortPriorityQueue()
end

function RemoveTechInPriorityQueue(tech)
	local techID = tech.BaseData.TechId
	local level = tech.Info.level

	local judge = function(technology)
		return technology.TechId == techID and technology.Level == level
	end

	-- TechPriorityQueue:RemoveFirst(judge)

	for i, technology in ipairs(TechPriorityQueue) do
		if judge(technology) then
			table.remove(TechPriorityQueue, i)
			break
		end
	end

	if level < tech.BaseData.MaxLevel then
		-- TechPriorityQueue:Push(TechTreeData[tech.BaseData.CategoryId][techID][level + 1])
		table.insert(TechPriorityQueue, TechTreeData[tech.BaseData.CategoryId][techID][level + 1])
		SortPriorityQueue()
	end

	if recommendedTechnologies ~= nil then
		for i, technology in pairs(recommendedTechnologies) do
			if judge(technology) then
				recommendedTechnologies = nil
				DisplayRecommendedTechnology()
				break
			end
		end
	else
		DisplayRecommendedTechnology()
	end
end

function PrintPriorityQueue() -- Laboratory.PrintPriorityQueue()
	local tbl = {}
	for i, technology in ipairs(TechPriorityQueue) do
		if i < 21 then
			tbl[i] = TechPriorityQueue[i]
		end

		print(i, TextMgr:GetText(technology.Name), technology.Level)
	end
	Global.DumpTable(tbl)
end

function UpgradeTech(tech)
	--AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
	RemoveTechInPriorityQueue(tech)
    FloatText.Show(TextMgr:GetText(tech.BaseData.Name).."  LV."..tech.Info.level.."   "..TextMgr:GetText("build_ui39"), Color.green)
    MainCityUI.FlyExp(maincity.GetBuildingByID(6))
    MainData.RequestData()
    Global.GAudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed",1,false)
    FillTech(tech)--TechTreeMap[TechState.CurUpgradeTech.Coord.Y][TechState.CurUpgradeTech.Coord.X])
    if TechState.CategoryID == tech.BaseData.CategoryId then
        ActiveConnectTech(tech)
        RefushNextGroup(tech)
        RefushTechUpgradeUnlock4Tech(tech)
    end
    UnlockArmyData.RequestData()
    AttributeBonus.CollectBonusInfo()   
    UnionHelpData.RequestData()
end

function ClearCurTechState(doRemoveTechInPriorityQueue)
	if doRemoveTechInPriorityQueue then
		RemoveTechInPriorityQueue(GetCurUpgradeTech())
	end

	if TechState.CurUpgradeTech ~= nil then
		if TechState.CurUpgradeTech.UI ~= nil and TechState.CurUpgradeTech.UI.UpgradeState ~= nil then
			TechState.CurUpgradeTech.UI.UpgradeState.gameObject:SetActive(false)
		end
		
	end
	TechState.CurUpgradeTech = nil
	
    BuildingShowInfoUI.MakeTransition(maincity.GetBuildingByID(6))
end

function CheckUpgradeProgress(fill)
    if TechState.CurUpgradeTech == nil then
        return
    end

    if TechState.CurUpgradeTech.Info.endtime <= Serclimax.GameTime.GetSecTime() then
        TechState.CurUpgradeTech.Info.level = math.min( TechState.CurUpgradeTech.Info.level+(fill == nil and 1 or 0),TechState.CurUpgradeTech.BaseData.MaxLevel)
        UpgradeTech(TechState.CurUpgradeTech)
        ClearTechProgress()
        ClearCurTechState(false)
        MainCityQueue.UpdateQueue();
    end	  
end

function SetCurUpgradeTech(tech)
	
	TechState.CurUpgradeTech = tech;
    if TechUI == nil or TechUI.TechProgress == nil then
        return 
    end
    TechUI.TechProgress.Root:SetActive(true)
    TechUI.Recommendation.gameObject:SetActive(false)
    -- TechUI.TechProgress.FreeRoot:SetActive(false)
    TechUI.TechProgress.BtnTxt.text = TextMgr:GetText("build_ui21")
    TechUI.TechProgress.Btn.gameObject:SetActive(true)
    TechUI.TechProgress.Des.text = TextMgr:GetText( tech.BaseData.Name).." LV."..math.min( TechState.CurUpgradeTech.Info.level + 1,tech.BaseData.MaxLevel)
	CountDown.Instance:Add("LaboratoryUpgrade",TechState.CurUpgradeTech.Info.endtime,function(t)
		TechUI.TechProgress.Time.text  =t
		if TechState.CurUpgradeTech == nil then
		    ClearTechProgress()
		    CountDown.Instance:Remove("LaboratoryUpgrade")
		    return 
        end
		local level =  math.min( TechState.CurUpgradeTech.Info.level+1,tech.BaseData.MaxLevel) -- math.max(1,TechState.CurUpgradeTech.Info.level+1)   --
    
		TechUI.TechProgress.Slider.value =math.min(1,1-(TechState.CurUpgradeTech.Info.endtime- GameTime.GetSecTime())/ TechState.CurUpgradeTech.Info.originaltime)--GetTechCostTime(TechState.CurUpgradeTech[level].CostTime))
		if TechState.CurUpgradeTech.Info.endtime+1 - GameTime.GetSecTime() <= 0 then
		    CheckUpgradeProgress(0)
			CountDown.Instance:Remove("LaboratoryUpgrade")
		end			
    end)
end

function GetCurTech(tech_id)
    return TechTreeData[TechState.CategoryID][tech_id]
end

function IsUnlock(tech)
    return IsUnlock4TechLevel(tech.BaseData)
end

function IsUnlock4Build(condition)
    if condition ~= nil then
    	for i =1,#(condition) do
            if condition[i].type == 1 then 
                local build = maincity.GetBuildingByID(condition[i].index)
                if build == nil then
                    return false
                else
                    if build.data.level < condition[i].value then
                        return false
                    end
                end
            end
	        	
        end
    end

	return true
end

function IsUnlock4TechLevel(tech)
	local unlock = true
 	
    if tech.Condition == nil then 
        return unlock
    end

 	if tech.Condition.Base ~= nil then
 	     table.foreach(tech.Condition.Base,function(i,v)
 	        local target = TechTreeData[tech.CategoryId][v.index]
 	        if target ~= nil and target.Info ~= nil and target.Info.Category ~= nil and target.Info.Category == tech.CategoryId then
                if target.Info.level < v.value then
                    unlock = false
                end
            else
                unlock = false
            end
        end)       
    end

    if tech.Condition.Other ~= nil and unlock then
        unlock = IsUnlock4Build(tech.Condition.Other)
    end


	return unlock    
end

-- Local Functions --

local function RequestUserTechInfo(category,callback)
    local req = BuildMsg_pb.MsgGetUserTechRequest()
	req.techCategory = category

	--lua.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgGetUserTechRequest, req,BuildMsg_pb.MsgGetUserTechResponse(),callback)
    LuaNetwork.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgGetUserTechRequest, req:SerializeToString(), function(typeId, data)

		local msg = BuildMsg_pb.MsgGetUserTechResponse()

		msg:ParseFromString(data)
		if callback ~= nil then
		    callback(msg)
		end

	end, false)
	
end

local function LoadTechListTable()
	if TechListData ~= nil then
		return
    end

    TechListData = {}
	local tech_table = TableMgr:GetTechCategoryTable()
	for _ ,v in pairs(tech_table) do
		local data = v
		TechListData[data.id] = data
        TechListData[data.id].Condition = {}
		if data.UnlockCondition ~= "NA" then
			local t = string.split(data.UnlockCondition,';')
			for i=1,#(t) do
				local cond = string.split(t[i],':')
				local cc = {}
				cc.type = tonumber(cond[1])		
				cc.index = tonumber(cond[2])
				cc.value = tonumber(cond[3])
				
			    if TechListData[data.id].Condition == nil then
					TechListData[data.id].Condition = {}
                end					
				table.insert(TechListData[data.id].Condition,cc)
			end			
		end   
	end
	
	--[[local iter = tech_table:GetEnumerator()
	while iter:MoveNext() do
	    --print(iter.Current.Key,iter.Current.Value)
        local data = iter.Current.Value
        TechListData[data.id] = data
        TechListData[data.id].Condition = {}
		if data.UnlockCondition ~= "NA" then
			local t = string.split(data.UnlockCondition,';')
			for i=1,#(t) do
				local cond = string.split(t[i],':')
				local cc = {}
				cc.type = tonumber(cond[1])		
				cc.index = tonumber(cond[2])
				cc.value = tonumber(cond[3])
				
			    if TechListData[data.id].Condition == nil then
					TechListData[data.id].Condition = {}
                end					
				table.insert(TechListData[data.id].Condition,cc)
			end			
		end        
    end]]
end

local function LoadTechDetailTable()
	if TechTreeData ~= nil then
		return
    end
	
	TechTreeData = {}
	TechTreeDataIDMap = {}


	local tech_table = TableMgr:GetTechDetailTable()
	for _ , v in pairs(tech_table) do
		local data = v

		if TechTreeData[data.CategoryId] == nil then
			TechTreeData[data.CategoryId] = {}
		end
		
		if TechTreeData[data.CategoryId][data.TechId] == nil then
			TechTreeData[data.CategoryId][data.TechId] = {}
			TechTreeDataIDMap[data.TechId] = TechTreeData[data.CategoryId][data.TechId]
		end
		
		if TechTreeData[data.CategoryId][data.TechId][data.Level] == nil then
			TechTreeData[data.CategoryId][data.TechId][data.Level] = {} 
		end
		TechTreeData[data.CategoryId][data.TechId][data.Level] = data

		TechTreeData[data.CategoryId][data.TechId][data.Level].Condition = {}

		if data.UnlockCondition ~= "NA" then
			TechTreeData[data.CategoryId][data.TechId][data.Level].Condition.Base = nil
			TechTreeData[data.CategoryId][data.TechId][data.Level].Condition.Other = nil
			local t = string.split(data.UnlockCondition,';')
			for i=1,#(t) do
				local cond = string.split(t[i],':')
				local cc = {}
				cc.type = tonumber(cond[1])		
				cc.index = tonumber(cond[2])
				cc.value = tonumber(cond[3])
				
				if cc.type == 3 then
					if TechTreeData[data.CategoryId][data.TechId][data.Level].Condition.Base == nil then
						TechTreeData[data.CategoryId][data.TechId][data.Level].Condition.Base = {}
					end
					
					table.insert(TechTreeData[data.CategoryId][data.TechId][data.Level].Condition.Base,cc)
				else
					if TechTreeData[data.CategoryId][data.TechId][data.Level].Condition.Other == nil then
						TechTreeData[data.CategoryId][data.TechId][data.Level].Condition.Other = {}
					end				
					table.insert(TechTreeData[data.CategoryId][data.TechId][data.Level].Condition.Other,cc)
				end	
			end			
		end

        TechTreeData[data.CategoryId][data.TechId][data.Level].Res = {}

        if data.NeedItems ~= nil then
            local t = string.split(data.NeedItems,';')
			for i=1,#(t) do
				local cond = string.split(t[i],':')
				local cc = {}
				cc.type = tonumber(cond[1])		
				cc.value = tonumber(cond[2])
				table.insert(TechTreeData[data.CategoryId][data.TechId][data.Level].Res,cc)
            end
        end


		if data.Level == 1 then
			TechTreeData[data.CategoryId][data.TechId].BaseData = TechTreeData[data.CategoryId][data.TechId][data.Level]
			TechTreeData[data.CategoryId][data.TechId].Info = {}
            TechTreeData[data.CategoryId][data.TechId].Info.level = 0
            TechTreeData[data.CategoryId][data.TechId].Info.endtime = 0
            TechTreeData[data.CategoryId][data.TechId].Info.Category = data.CategoryId
			TechTreeData[data.CategoryId][data.TechId].Coord = {}
			local cot = string.split(data.Coordinate,';')
			TechTreeData[data.CategoryId][data.TechId].Coord.Y = tonumber(cot[1])
			TechTreeData[data.CategoryId][data.TechId].Coord.X = tonumber(cot[2])
			if cot[3] == nil then 
			    TechTreeData[data.CategoryId][data.TechId].Coord.E = false
			else
			    if  tonumber(cot[3]) == 1 then 
			        TechTreeData[data.CategoryId][data.TechId].Coord.E = true
			    else
			        TechTreeData[data.CategoryId][data.TechId].Coord.E = false
			    end
            end
		end
	end
	
	--[[local iter = tech_table:GetEnumerator()
	while iter:MoveNext() do
		local data = iter.Current.Value
		
		if TechTreeData[data.CategoryId] == nil then
			TechTreeData[data.CategoryId] = {}
		end
		
		if TechTreeData[data.CategoryId][data.TechId] == nil then
			TechTreeData[data.CategoryId][data.TechId] = {}
			TechTreeDataIDMap[data.TechId] = TechTreeData[data.CategoryId][data.TechId]
		end
		

		
		if TechTreeData[data.CategoryId][data.TechId][data.Level] == nil then
			TechTreeData[data.CategoryId][data.TechId][data.Level] = {} 
		end
		TechTreeData[data.CategoryId][data.TechId][data.Level] = data

		TechTreeData[data.CategoryId][data.TechId][data.Level].Condition = {}

		if data.UnlockCondition ~= "NA" then
			TechTreeData[data.CategoryId][data.TechId][data.Level].Condition.Base = nil
			TechTreeData[data.CategoryId][data.TechId][data.Level].Condition.Other = nil
			local t = string.split(data.UnlockCondition,';')
			for i=1,#(t) do
				local cond = string.split(t[i],':')
				local cc = {}
				cc.type = tonumber(cond[1])		
				cc.index = tonumber(cond[2])
				cc.value = tonumber(cond[3])
				
				if cc.type == 3 then
					if TechTreeData[data.CategoryId][data.TechId][data.Level].Condition.Base == nil then
						TechTreeData[data.CategoryId][data.TechId][data.Level].Condition.Base = {}
					end
					
					table.insert(TechTreeData[data.CategoryId][data.TechId][data.Level].Condition.Base,cc)
				else
					if TechTreeData[data.CategoryId][data.TechId][data.Level].Condition.Other == nil then
						TechTreeData[data.CategoryId][data.TechId][data.Level].Condition.Other = {}
					end				
					table.insert(TechTreeData[data.CategoryId][data.TechId][data.Level].Condition.Other,cc)
				end	
			end			
		end

        TechTreeData[data.CategoryId][data.TechId][data.Level].Res = {}

        if data.NeedItems ~= nil then
            local t = string.split(data.NeedItems,';')
			for i=1,#(t) do
				local cond = string.split(t[i],':')
				local cc = {}
				cc.type = tonumber(cond[1])		
				cc.value = tonumber(cond[2])
				table.insert(TechTreeData[data.CategoryId][data.TechId][data.Level].Res,cc)
            end
        end


		if data.Level == 1 then
			TechTreeData[data.CategoryId][data.TechId].BaseData = TechTreeData[data.CategoryId][data.TechId][data.Level]
			TechTreeData[data.CategoryId][data.TechId].Info = {}
            TechTreeData[data.CategoryId][data.TechId].Info.level = 0
            TechTreeData[data.CategoryId][data.TechId].Info.endtime = 0
            TechTreeData[data.CategoryId][data.TechId].Info.Category = data.CategoryId
			TechTreeData[data.CategoryId][data.TechId].Coord = {}
			local cot = string.split(data.Coordinate,';')
			TechTreeData[data.CategoryId][data.TechId].Coord.Y = tonumber(cot[1])
			TechTreeData[data.CategoryId][data.TechId].Coord.X = tonumber(cot[2])
			if cot[3] == nil then 
			    TechTreeData[data.CategoryId][data.TechId].Coord.E = false
			else
			    if  tonumber(cot[3]) == 1 then 
			        TechTreeData[data.CategoryId][data.TechId].Coord.E = true
			    else
			        TechTreeData[data.CategoryId][data.TechId].Coord.E = false
			    end
            end
		end
	end]]
end

local function IsUnlock4Tech(tech,self)
    
	local unlock = true
 	
    if tech.Condition == nil then 
        return unlock
    end
 	if tech.Condition.Base ~= nil then
 	    for i =1,#(tech.Condition.Base) do
 	        local target = TechTreeData[TechState.CategoryID][tech.Condition.Base[i].index]
 	        if target ~= nil and self.BaseData.TechId == target.BaseData.TechId then
 	           
 	            if target.Info ~= nil and target.Info.Category ~= nil and target.Info.Category == TechState.CategoryID then
                    if target.Info.level < tech.Condition.Base[i].value then
                        unlock = false
                    end
                end
            end
        end
    end
	return unlock
end

local function IsUnlock4List(tech)
    return IsUnlock4Build(tech.Condition)
end	

local function SetupTechTreeMap()
	category_id = TechState.CategoryID
	TechTreeMap = {}
	TechTreeMap.MaxY = 0
	local category = TechTreeData[category_id]
	if category == nil then
		return
    end
	--for k,v in ipairs(category) do
	table.foreach(category,function(i,v)
		local tech = v
		if TechTreeMap[v.Coord.Y] == nil then
			TechTreeMap[v.Coord.Y] = {}
			TechTreeMap[v.Coord.Y].UI = nil
			if TechTreeMap.MaxY < v.Coord.Y then 
				TechTreeMap.MaxY = v.Coord.Y
			end
		end
		TechTreeMap[v.Coord.Y][v.Coord.X] = v
		TechTreeMap[v.Coord.Y][v.Coord.X].UI = nil
    end)
end

local function InitTechState()
	TechState = {}
	TechState.CategoryID = 0
	TechState.CurUpgradeTech = nil
end

local function ClearChildNode(trf)
    local childCount = trf.childCount
    for i = 0, childCount - 1 do
        trf:GetChild(i).gameObject:SetActive(false)
        GameObject.Destroy(trf:GetChild(i).gameObject)
    end
end

local function GetConnectTechTag(tech,tag,source,reslut)
	--local tag = {false,false,false,false,false,false}
	if tech.BaseData.Condition == nil or  tech.BaseData.Condition.Base == nil  then 
		return tag
	end
	
	local coordX = tech.Coord.X
	local ttag = LinkTag [coordX]
	
	for i =1,#(tech.BaseData.Condition.Base) do
		--table.foreach(tech.BaseData.Condition.Base[i],function(w,v) print(w,v) end)
		local target = TechTreeData[TechState.CategoryID][tech.BaseData.Condition.Base[i].index]
		if (source == nil ) or (source ~= nil and source == target) then
			if target ~= nil then
				if reslut ~= nil then
					table.insert(reslut,tech)
                end
				if coordX ~= target.Coord.X then
					local is_border = false
					local ttag1 = LinkTag[ target.Coord.X]
					for k =1 ,#(ttag) do
						for j =1,#(ttag1) do
							if ttag[k] == ttag1[j] then
								tag[ttag[k]] = true
								is_border = true
							end
						end
					end
					if is_border ~= true then
						if ttag[1] > ttag1[1] then
							for l = ttag1[1],ttag[2],1 do
								tag[l] = true
							end
						else
							for l = ttag[1],ttag1[2],1 do
								tag[l] = true
                            end
						end
					end
				end			
			end
		end
	end
	
	return tag
end

RefushNextGroup = function(tech)
    if tech.UI == nil or TechUI == nil or TechList == nil or TechTreeMap == nil then 
        return
    end    
	local coordY = tech.Coord.Y
	if coordY == TechTreeMap.MaxY then
		return
	end
	local nextGroup = TechTreeMap[coordY + 1]
	table.foreach(nextGroup,function(i,v)	
		if type(i) == "number" then
			RefushTechUpgradeUnlock4Tech(v)
        end
	end)
end

RefushTechUpgradeUnlock4Tech = function(tech)
    if  tech.UI == nil or TechUI == nil or TechList == nil or TechTreeMap == nil then 
        return
    end
    local level = tech.Info.level + 1
    if level > tech.BaseData.MaxLevel then
        tech.UI.UpgradeUnlock:SetActive(false)
        return 
    end
    if IsUnlock4TechLevel(tech[level]) then
        tech.UI.UpgradeUnlock:SetActive(false)
    else       
        if tech.UI.Unlock.activeSelf then 
            tech.UI.UpgradeUnlock:SetActive(false)
        else
            tech.UI.UpgradeUnlock:SetActive(true)
        end
    end
end

local function RefushTechUpgradeUnlock()
	table.foreach(TechTreeMap,function(i,v)
	    ---[[
	    if type(i) == "number" then
            table.foreach(v,function(j,tech)
                if type(j) == "number" then
                    RefushTechUpgradeUnlock4Tech(tech)
                end
            end)
        end
        --]]
    end)
end

local function TechUIUnlock(techui,unlock)
    if techui == nil then 
        return
    end
	techui.Unlock:SetActive(not unlock)
    techui.TitleGray.IsGray = not unlock
    techui.IconGray.IsGray = not unlock
    techui.UnlockDesGray.IsGray = not unlock
    techui.BGNormal:SetActive(unlock)
    techui.BGGray:SetActive(not unlock)
    techui.LevelBGNormal:SetActive(unlock)
    techui.LevelBGGary:SetActive(not unlock)	     
end

ActiveConnectTech =  function(tech)
    if  tech.UI == nil or TechUI == nil or TechList == nil or TechTreeMap == nil then 
        return
    end
    print("ActiveConnectTech",tech.Coord.X,tech.Coord.Y)
	local coordY = tech.Coord.Y
	if coordY == TechTreeMap.MaxY then
		return
	end
	local nextGroup = TechTreeMap[coordY + 1]
	local pre_group = TechTreeMap[coordY]
	
	local result = {}
	local tag = {false,false,false,false,false,false}
	table.foreach(nextGroup,function(i,v)	
		if type(i) == "number" then
			tag = GetConnectTechTag(v,tag,tech,result)
        end
	end)
	
	if IsUnlock(tech) then
	    TechUIUnlock(tech.UI,true)
	    --tech.UI.Unlock:SetActive(false)    
    end

	local unlock = true
	table.foreach(result,function(i,v)	
		if not IsUnlock(v) then
		    if unlock then 
		        unlock = false
            end
        end
	end)

	if not unlock then 
	    if #(result) == 1 and #(result[1].BaseData.Condition.Base) ~= 1 and IsUnlock4Tech(result[1].BaseData,tech) then
	        local ttag = LinkTag [tech.Coord.X]
	        --if tag[ttag[1]] or tag[ttag[2]] then
		        tech.UI.Point.Bottom.Normal:SetActive(true)
		        tech.UI.Point.Bottom.Disable:SetActive(false)		
            --end	        
	        tech.UI.Line.Bottom.Normal:SetActive(true)
    	    tech.UI.Line.Bottom.Disable:SetActive(false)	    	    
	    end
	    return 
	end


	local ttag = LinkTag [tech.Coord.X]
	--if #(result) ~= 1 or #(result[1].BaseData.Condition.Base) ~= 1 then
	--if tag[ttag[1]] or tag[ttag[2]] then
		tech.UI.Point.Bottom.Normal:SetActive(true)
		tech.UI.Point.Bottom.Disable:SetActive(false)		
    --end
	tech.UI.Line.Bottom.Normal:SetActive(true)
	tech.UI.Line.Bottom.Disable:SetActive(false)
	tech.UI.UpgradeState.gameObject:SetActive(false)

	
---[[
	table.foreach(result,function(i,v)	
		if IsUnlock(v)and (v.Coord.Y ~= 1) then
			local ttag = LinkTag [v.Coord.X]
			--if #(result) ~= 1 or  #(v.BaseData.Condition.Base) ~= 1 then
			--if (tag[ttag[1] ] or tag[ttag[2] ]) then
				v.UI.Point.Top.Normal:SetActive(true)
				v.UI.Point.Top.Disable:SetActive(false)					
			--end
			v.UI.Line.Top.Normal:SetActive(true)
			v.UI.Line.Top.Disable:SetActive(false)	
			TechUIUnlock(v.UI,true)
			--v.UI.Unlock:SetActive(false)			
        end
	end)
--]]
    tag = {false,false,false,false,false,false}
	table.foreach(pre_group,function(i,k)	
		if type(i) == "number" and IsUnlock(k) then
	        table.foreach(nextGroup,function(j,v)	
		        if type(j) == "number"  and IsUnlock(v) then
			        tag = GetConnectTechTag(v,tag,k,result)
                end
	        end)
        end
	end)

	for i = 1,#(pre_group.UI.Line) do
	    --if pre_group.UI.Line[i].Root.activeSelf then
	    --    pre_group.UI.Line[i].Normal:SetActive(true)
		--    pre_group.UI.Line[i].Disable:SetActive(false)
        --end
        if pre_group.UI.Line[i].Root.activeSelf then
            if tag[i] then
		        pre_group.UI.Line[i].Normal:SetActive(tag[i])
		        --pre_group.UI.Line[i].Disable:SetActive(not tag[i])
		    end
        end
	end	
end

ConnectTech  = function (pre_group,cur_group)
	if pre_group == nil or cur_group == nil then
		return
	end
	
	local tag = {false,false,false,false,false,false}
	table.foreach(cur_group,function(i,v)	
		if type(i) == "number" then
			tag = GetConnectTechTag(v,tag)
			TechUIUnlock(v.UI,false)
		end
	end)	
	
	--table.foreach(tag,function(i,v) print(i,v) end)
	local endline = false
	
	table.foreach(pre_group,function(i,v)
		if type(i) == "number" then
			local ttag = LinkTag [v.Coord.X]
			if tag[ttag[1]] or tag[ttag[2]] then
				v.UI.Point.Bottom.Normal:SetActive(false)
				v.UI.Point.Bottom.Disable:SetActive(true)
				
				--v.UI.Point.Top.Normal:SetActive(false)
				--v.UI.Point.Top.Disable:SetActive(true)				
			else
				v.UI.Point.Bottom.Normal:SetActive(false)
				v.UI.Point.Bottom.Disable:SetActive(false)	
                v.UI.Point.Bottom.Root:SetActive(false)
				--v.UI.Point.Top.Normal:SetActive(false)
				--v.UI.Point.Top.Disable:SetActive(false)			
			end
			
            if v.Coord.Y >= TechTreeMap.MaxY then
				v.UI.Line.Bottom.Root:SetActive(false)
                v.UI.Point.Bottom.Root:SetActive(false)                
                endline = true;
            end

			if v.Coord.Y >= TechTreeMap.MaxY  or v.Coord.E then
				v.UI.Line.Bottom.Normal:SetActive(false)
				v.UI.Line.Bottom.Disable:SetActive(false)
				v.UI.Point.Bottom.Normal:SetActive(false)
				v.UI.Point.Bottom.Disable:SetActive(false)	
				v.UI.Line.Bottom.Root:SetActive(false)
                v.UI.Point.Bottom.Root:SetActive(false)
                --endline = true;
			else
				v.UI.Line.Bottom.Normal:SetActive(false)
				v.UI.Line.Bottom.Disable:SetActive(true)			
			end

			if v.Coord.Y == 1 then
				v.UI.Point.Top.Normal:SetActive(false)
				v.UI.Point.Top.Disable:SetActive(false)					
				v.UI.Line.Top.Normal:SetActive(false)
				v.UI.Line.Top.Disable:SetActive(false)	
			else
				v.UI.Line.Top.Normal:SetActive(false)
				v.UI.Line.Top.Disable:SetActive(true)	
			end
	
		end	
	end)

	table.foreach(cur_group,function(i,v)	
		if type(i) == "number" then
			local ttag = LinkTag [v.Coord.X]
			if tag[ttag[1]] or tag[ttag[2]] then
				--v.UI.Point.Bottom.Normal:SetActive(false)
				--v.UI.Point.Bottom.Disable:SetActive(true)
				
				v.UI.Point.Top.Normal:SetActive(false)
				v.UI.Point.Top.Disable:SetActive(true)				
			else
				--v.UI.Point.Bottom.Normal:SetActive(false)
				--v.UI.Point.Bottom.Disable:SetActive(false)	

				v.UI.Point.Top.Normal:SetActive(false)
				v.UI.Point.Top.Disable:SetActive(false)	
				v.UI.Point.Top.Root:SetActive(false)
			end
		end
	end)	
	for i = 1,#(pre_group.UI.Line) do
	    if endline then
            pre_group.UI.Line[i].Root:SetActive(false)
	    else
		    pre_group.UI.Line[i].Root:SetActive(tag[i])
        end
	end	
end

FillTech = function(tech)
    if  tech.UI == nil or TechUI == nil or TechList == nil or TechTreeMap == nil then 
        return
	end
	if TechState.CurUpgradeTech ~= nil then
		if TechState.CurUpgradeTech.BaseData.TechId == tech.BaseData.TechId  then
			tech.UI.UpgradeState.gameObject:SetActive(true)
		end
	end	
	--print(TextMgr:GetText(tech.BaseData.Name),tech.BaseData.Dese)
	tech.UI.Title.text = TextMgr:GetText(tech.BaseData.Name)
	tech.UI.Icon.mainTexture = ResourceLibrary:GetIcon ("Icon/Laboratory/", tech.BaseData.Icon)
	tech.UI.UnlockDes.text =  tech.Info.level.."/"..tech.BaseData.MaxLevel -- TextMgr:GetText(tech.BaseData.Dese)
	if tech.Info.level ~= tech.BaseData.MaxLevel then
        tech.UI.LevelSprite.spriteName = "proceed_array"	    
	else
        tech.UI.LevelSprite.spriteName = "proceed_array"	
	end
	if tech.BaseData.Effect == "1" then
		tech.UI.Effect = NGUITools.AddChild(tech.UI.Root, ResourceLibrary.GetUIPrefab("BuildingCommon/ui_bingzhong"))
	end
	tech.UI.Level.value = tech.Info.level/tech.BaseData.MaxLevel
end

local function OnClickTechTreeItem(obj)
    local c = string.split(obj.name,"_")
    print(c[1],c[2],TechTreeMap[tonumber(c[1])][tonumber(c[2])].BaseData.TechId.."  sdada")
    LaboratoryUpgrade.SetTargetTech(TechTreeMap[tonumber(c[1])][tonumber(c[2])],false)
    GUIMgr:CreateMenu("LaboratoryUpgrade", false)
end

function ShowResBar()
end

local function GenerateTechTree()
	SetupTechTreeMap()
	local pre_group = nil
	for i=1,TechTreeMap.MaxY,1 do
		local item = NGUITools.AddChild(TechUI.TechTreeUI.Grid.gameObject,TechUI.TechTreeUI.TechItemPrefab)
		TechTreeMap[i].UI = SetupTechItem(item)
		TechTreeMap[i].UI.Root:SetActive(false)
		for j =1,7,1 do
			if TechTreeMap[i][j] ~= nil then
				TechTreeMap[i][j].UI = TechTreeMap[i].UI.Node[j];
				TechTreeMap[i][j].UI.Root:SetActive(true)
                TechTreeMap[i][j].UI.Btn.gameObject.name = i.."_"..j
				SetClickCallback(TechTreeMap[i][j].UI.Btn.gameObject,OnClickTechTreeItem)
				FillTech(TechTreeMap[i][j])
			end
        end
		ConnectTech(pre_group,TechTreeMap[i])
		pre_group = TechTreeMap[i]
	end
	ConnectTech(pre_group,pre_group)

	for i=1,TechTreeMap.MaxY,1 do
	    TechTreeMap[i].UI.Root:SetActive(true)
    end	
    
    TechUI.TechTreeUI.Grid:Reposition()
    TechUI.TechTreeUI.ScrollView:ResetPosition()
end

local function RefushTechInfo(msg)
    --if TechTreeData[msg.techCategory] == nil then
    --    return
    --end
    for i = 1,#(msg.tech) do
        local tech = TechTreeDataIDMap[msg.tech[i].techid]
        if tech ~= nil then
            tech.Info.level = msg.tech[i].level
            tech.Info.endtime = msg.tech[i].endtime
            tech.Info.beginTime = msg.tech[i].beginTime
            tech.Info.originaltime = msg.tech[i].originaltime
            if tech.Info.endtime > Serclimax.GameTime.GetSecTime() then
                SetCurUpgradeTech(tech)
            end
        end
    end
end

local function RefushTechInfo4Single(msg)
    for i = 1,#(msg.tech) do
        local tech = TechTreeDataIDMap[msg.tech[i].techid]
        if tech ~= nil then
            tech.Info.level = msg.tech[i].level
            tech.Info.endtime = msg.tech[i].endtime
            tech.Info.beginTime = msg.tech[i].beginTime
            tech.Info.originaltime = msg.tech[i].originaltime
            if tech.Info.endtime > Serclimax.GameTime.GetSecTime() then
                TechState.CurUpgradeTech = tech
            end
        end
    end
end

local function RefushActive()
    --if TechTreeData[msg.techCategory] == nil then
    --    return
    --end
	table.foreach(TechTreeMap,function(i,v)
	    if type(i) == "number" then
            table.foreach(v,function(j,tech)
                if type(j) == "number" then
                    if i == 1 then 
                        ActiveConnectTech(tech)
                    else
                        if  tech.Info.level ~= 0 then
                            ActiveConnectTech(tech)
                        end
                    end 
                end                    
            end)
        end
    end)   
end

DisplayTechTree = function(category_id)
   	ClearUIAttribute()
    TechUI.TechListUI.RootObj:SetActive(false)
    TechUI.BottomUI:SetActive(false)
    TechState.CategoryID = category_id
    TechUI.Tilte.text = TextMgr:GetText( TechListData[TechState.CategoryID].Name)
    TechUI.TechTreeUI.RootObj:SetActive(true)
	TechUI.TechTreeUI.RootObjBg:SetActive(true)
	ClearChildNode(	TechUI.TechTreeUI.Grid.transform )
    GenerateTechTree()
	RefushActive()
	RefushTechUpgradeUnlock()
	--ActiveConnectTech(TechTreeMap[1][6])
	--ActiveConnectTech(TechTreeMap[2][5])
	--ActiveConnectTech(TechTreeMap[3][5]) 
end

local function OnClickTechListItem(obj)
    --print(obj.name)
	if TechList ~= nil then
		if not TechList[tonumber(obj.name)].Unlock.activeSelf then
			DisplayTechTree(tonumber(obj.name))
		else
			FloatText.ShowOn(obj,TechList[tonumber(obj.name)].BottomText.text,Color.white)
		end
	end
end

local function GetRecommendedTechnology(n)
	if recommendedTechnologies == nil then
		recommendedTechnologies = {}

		for i, technology in ipairs(TechPriorityQueue) do
			if IsUnlock4List(TechListData[technology.CategoryId]) and IsUnlock4TechLevel(technology) then
				local isRecommended = false
				if #recommendedTechnologies ~= 0 then
					for i, recommendedTechnology in ipairs(recommendedTechnologies) do
						if recommendedTechnology.TechId == technology.TechId then
							isRecommended = true
							break
						end
					end
				end

				if not isRecommended then
					recommendedTechnologies[#recommendedTechnologies + 1] = technology
				
					if #recommendedTechnologies == n then
						break
					end
				end
			end
		end
	end
end

function DisplayRecommendedTechnology()
	-- if recommendedTechnologies == nil then
	-- 	recommendedTechnologies = TechPriorityQueue:FindFirstN(2, IsUnlock4TechLevel)
	-- end
	if TechUI ~= nil then
		GetRecommendedTechnology(2)
	    
	    local numRecommended = #recommendedTechnologies
	    for i = 1, 2 do
	    	TechUI.Recommendation.technology[i].gameObject:SetActive(i <= numRecommended)
	    	TechUI.Recommendation.tip_noRecommandation[i]:SetActive(i == numRecommended + 1)
	    end

	    for i, technology in ipairs(recommendedTechnologies) do
	    	local categoryID = technology.CategoryId
	    	local techData = GetTech(technology.TechId)

			local uiRecommendedTechnology = TechUI.Recommendation.technology[i]

			uiRecommendedTechnology.name.text = TextMgr:GetText(technology.Name)
			uiRecommendedTechnology.type.text = TextMgr:GetText(TechListData[categoryID].Name)
			uiRecommendedTechnology.icon.mainTexture = ResourceLibrary:GetIcon ("Icon/Laboratory/", technology.Icon)
			uiRecommendedTechnology.level.label.text = string.format("%d / %d", techData.Info.level, technology.MaxLevel)
			uiRecommendedTechnology.level.progressBar.value = techData.Info.level / technology.MaxLevel
			uiRecommendedTechnology.description.text = TextMgr:GetText(technology.Dese)

			SetClickCallback(uiRecommendedTechnology.btn_research, function()
				LaboratoryUpgrade.SetTargetTech(techData, false)
	    		GUIMgr:CreateMenu("LaboratoryUpgrade", false)
			end)
		end

		TechUI.Recommendation.gameObject:SetActive(true)
	end
end

function CheckAdvice()
	if GetCurUpgradeTech() == nil or GetCurUpgradeTech().Info.endtime < Serclimax.GameTime.GetSecTime() then
		GetRecommendedTechnology(2)
		return #recommendedTechnologies > 0
	end
	return false
end

DisplayTechList = function()
    ClearUIAttribute()
    TechUI.Tilte.text = TextMgr:GetText("Building_6_name")
    TechUI.TechTreeUI.RootObj:SetActive(false)
	TechUI.TechTreeUI.RootObjBg:SetActive(false)
	
    TechUI.TechListUI.RootObj:SetActive(true)
    TechUI.BottomUI:SetActive(true)
    TechList = {}
    ClearChildNode(	TechUI.TechListUI.Grid.transform )
    for i,v in pairs(TechListData) do
        local item = NGUITools.AddChild(TechUI.TechListUI.Grid.gameObject,TechUI.TechListUI.ListItemPrefab)
        TechList[i] = SetupListItem(item)
        TechList[i].Root.name = i
        TechList[i].Root:SetActive(true)
        TechList[i].BottomText.text =  TextMgr:GetText(v.UnlockDes)
        if TechList[i].IconGray == nil then
            TechList[i].IconGray = TechList[i].Icon.gameObject:GetComponent("UITexture2GrayController")
            if TechList[i].IconGray == nil then
                TechList[i].IconGray = TechList[i].Icon.gameObject:AddComponent(typeof(UITexture2GrayController))
            end
        end
        if TechList[i].TopTextGray == nil then
            TechList[i].TopTextGray = TechList[i].TopText.gameObject:GetComponent("UILabel2GrayController")
            if TechList[i].TopTextGray == nil then
                TechList[i].TopTextGray = TechList[i].TopText.gameObject:AddComponent(typeof(UILabel2GrayController))
            end
        end

        if IsUnlock4List(v) then
            TechList[i].Unlock:SetActive(false)
            TechList[i].BottomText.gameObject:SetActive(false)
            TechList[i].IconGray.IsGray = false
            TechList[i].TopTextGray.IsGray = false
            TechList[i].BGNormal:SetActive(true)
            TechList[i].BGGray:SetActive(false)
            TechList[i].RootBtn_Sound.State = 0
        else
            TechList[i].Unlock:SetActive(true)
            TechList[i].BottomText.gameObject:SetActive(true)
            TechList[i].IconGray.IsGray = true
            TechList[i].TopTextGray.IsGray = true
            TechList[i].BGNormal:SetActive(false)
            TechList[i].BGGray:SetActive(true)  
            TechList[i].RootBtn_Sound.State = 1
        end
         TechList[i].TopText.text = TextMgr:GetText(v.Name)
         TechList[i].Icon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "Laboratory/", v.Icon)
         SetClickCallback(TechList[i].RootBtn.gameObject,OnClickTechListItem)
    end
    TechUI.TechListUI.Grid:Reposition()
    TechUI.TechListUI.ScrollView:ResetPosition()

    TechUI.TechProgress.FreeRoot:SetActive(false)

    DisplayRecommendedTechnology()
    TechUI.Recommendation.gameObject:SetActive(GetCurUpgradeTech() == nil or GetCurUpgradeTech().Info.endtime < Serclimax.GameTime.GetSecTime())
end

local function SetupTechTreeUI()
	TechUI.TechTreeUI = {}
	TechUI.TechTreeUI.RootObj = transform:Find("Container/bg_frane/TechTree").gameObject
	TechUI.TechTreeUI.RootObjBg = transform:Find("Container/bg_frane/TechTree_bg").gameObject
	TechUI.TechTreeUI.ScrollView = transform:Find("Container/bg_frane/TechTree"):GetComponent("UIScrollView")
	TechUI.TechTreeUI.TechItemPrefab = transform:Find("Container/bg_frane/TechTree/Tech_item").gameObject
	TechUI.TechTreeUI.Grid = transform:Find("Container/bg_frane/TechTree/Grid"):GetComponent("UIGrid")
end

local function SetupTechListUI()
    TechUI.TechListUI = {}
    TechUI.TechListUI.RootObj = transform:Find("Container/bg_frane/LaboratoryList").gameObject
    TechUI.TechListUI.ScrollView =  transform:Find("Container/bg_frane/LaboratoryList"):GetComponent("UIScrollView")
    TechUI.TechListUI.ListItemPrefab = transform:Find("Container/bg_frane/LaboratoryList/Laboratoryinfo").gameObject
    TechUI.TechListUI.Grid = transform:Find("Container/bg_frane/LaboratoryList/Grid"):GetComponent("UIGrid")
end

SetupListItem = function(item)
    local ListUI = {}
    ListUI.Root = item
    ListUI.RootBtn = item:GetComponent("UIButton")
    ListUI.RootBtn_Sound = item:GetComponent("UISound")
    ListUI.TopText = item.transform:Find("bg_title/text"):GetComponent("UILabel")
    ListUI.BGNormal = item.transform:Find("bg_list").gameObject
    ListUI.BGGray = item.transform:Find("bg_list_hui").gameObject
    ListUI.Icon = item.transform:Find("Texture"):GetComponent("UITexture")
    ListUI.BottomText = item.transform:Find("text"):GetComponent("UILabel")
    ListUI.Unlock = item.transform:Find("icon_suo").gameObject
    return ListUI 
end


SetupTechItem = function(item)
	local itemUI = {}
	itemUI.Root = item
	itemUI.Node = {}
	for i = 1,7,1 do
		itemUI.Node[i] = {}
		itemUI.Node[i].Root = item.transform:Find(i).gameObject
		itemUI.Node[i].Btn =  itemUI.Node[i].Root.transform:Find("Laboratoryitem"):GetComponent("UIButton")
		itemUI.Node[i].Title = itemUI.Node[i].Root.transform:Find("Laboratoryitem/bg_title/text"):GetComponent("UILabel")
        itemUI.Node[i].TitleGray = itemUI.Node[i].Title.gameObject:AddComponent(typeof(UILabel2GrayController))

		itemUI.Node[i].Icon = itemUI.Node[i].Root.transform:Find("Laboratoryitem/Texture"):GetComponent("UITexture")
        itemUI.Node[i].IconGray = itemUI.Node[i].Icon.gameObject:AddComponent(typeof(UITexture2GrayController))

		itemUI.Node[i].UnlockDes = itemUI.Node[i].Root.transform:Find("Laboratoryitem/text"):GetComponent("UILabel")
        itemUI.Node[i].UnlockDesGray = itemUI.Node[i].UnlockDes.gameObject:AddComponent(typeof(UILabel2GrayController))

		itemUI.Node[i].Unlock = itemUI.Node[i].Root.transform:Find("Laboratoryitem/icon_suo").gameObject
		itemUI.Node[i].UpgradeUnlock = itemUI.Node[i].Root.transform:Find("Laboratoryitem/icon_cha").gameObject 
		itemUI.Node[i].UpgradeState =  itemUI.Node[i].Root.transform:Find("ui_yanjiuzhong")
        
        itemUI.Node[i].BGNormal = itemUI.Node[i].Root.transform:Find("Laboratoryitem/bg_list").gameObject
        itemUI.Node[i].BGGray = itemUI.Node[i].Root.transform:Find("Laboratoryitem/bg_list_hui").gameObject

        itemUI.Node[i].LevelBGNormal = itemUI.Node[i].Root.transform:Find("Laboratoryitem/bg_level").gameObject 
        itemUI.Node[i].LevelBGGary = itemUI.Node[i].Root.transform:Find("Laboratoryitem/bg_level_hui").gameObject 

        itemUI.Node[i].Level = itemUI.Node[i].Root.transform:Find("Laboratoryitem/bg_level/array"):GetComponent("UISlider")
        itemUI.Node[i].LevelSprite = itemUI.Node[i].Root.transform:Find("Laboratoryitem/bg_level/array"):GetComponent("UISprite")
		
		itemUI.Node[i].Line = {}
		itemUI.Node[i].Line.Top = {}
        itemUI.Node[i].Line.Top.Root = itemUI.Node[i].Root.transform:Find("bg_line/bg_line_top").gameObject
		itemUI.Node[i].Line.Top.Normal = itemUI.Node[i].Root.transform:Find("bg_line/bg_line_top/line_vertical_top").gameObject
		itemUI.Node[i].Line.Top.Disable = itemUI.Node[i].Root.transform:Find("bg_line/bg_line_top/line_vertical_top_hui").gameObject
		itemUI.Node[i].Line.Bottom = {}
		itemUI.Node[i].Line.Bottom.Root =  itemUI.Node[i].Root.transform:Find("bg_line/bg_line_bottom").gameObject
		itemUI.Node[i].Line.Bottom.Normal = itemUI.Node[i].Root.transform:Find("bg_line/bg_line_bottom/line_vertical_bottom").gameObject
		itemUI.Node[i].Line.Bottom.Disable = itemUI.Node[i].Root.transform:Find("bg_line/bg_line_bottom/line_vertical_bottom_hui").gameObject
		
		itemUI.Node[i].Point = {}
		itemUI.Node[i].Point.Top = {}
		itemUI.Node[i].Point.Top.Root = itemUI.Node[i].Root.transform:Find("bg_point/bg_point_top").gameObject
		itemUI.Node[i].Point.Top.Normal = itemUI.Node[i].Root.transform:Find("bg_point/bg_point_top/icon_point_top").gameObject
		itemUI.Node[i].Point.Top.Disable = itemUI.Node[i].Root.transform:Find("bg_point/bg_point_top/icon_point_top_hui").gameObject
		itemUI.Node[i].Point.Bottom = {}
		itemUI.Node[i].Point.Bottom.Root = itemUI.Node[i].Root.transform:Find("bg_point/bg_point_bottom").gameObject
		itemUI.Node[i].Point.Bottom.Normal = itemUI.Node[i].Root.transform:Find("bg_point/bg_point_bottom/icon_point_bottom").gameObject
		itemUI.Node[i].Point.Bottom.Disable = itemUI.Node[i].Root.transform:Find("bg_point/bg_point_bottom/icon_point_bottom_hui").gameObject
		itemUI.Node[i].Line.Top.Normal:SetActive(false)
		itemUI.Node[i].Line.Top.Disable:SetActive(false)
		itemUI.Node[i].Line.Bottom.Normal:SetActive(false)
		itemUI.Node[i].Line.Bottom.Disable:SetActive(false)
		itemUI.Node[i].Point.Top.Normal:SetActive(false)
		itemUI.Node[i].Point.Top.Disable:SetActive(false)
		itemUI.Node[i].Point.Bottom.Normal:SetActive(false)
		itemUI.Node[i].Point.Bottom.Disable:SetActive(false)		
		itemUI.Node[i].Root:SetActive(false)
        itemUI.Node[i].UpgradeUnlock:SetActive(false)
	end
	
	itemUI.Line = {}
	for i = 1,6,1 do
		itemUI.Line[i] = {}
		itemUI.Line[i].Root = item.transform:Find("bg_line_horizonal_"..i).gameObject
		itemUI.Line[i].Normal = itemUI.Line[i].Root.transform:Find("line_horizonal").gameObject
		itemUI.Line[i].Disable = itemUI.Line[i].Root.transform:Find("line_horizonal_hui").gameObject
		itemUI.Line[i].Normal:SetActive(false)
		itemUI.Line[i].Disable:SetActive(true)
		itemUI.Line[i].Root:SetActive(false)
    end
	return itemUI
end 

local function OnClickCloseBtn()
    if  TechUI.TechListUI.RootObj.activeSelf then
	    GUIMgr:CloseMenu("Laboratory")
	else
	    DisplayTechList()
	end
end

local function SetupUICallBack()
    SetClickCallback(TechUI.CloseBtn.gameObject,OnClickCloseBtn)
    SetClickCallback(transform:Find("Container").gameObject, OnClickCloseBtn)
end

function RequestTechUpAccl(callback)
    local req = BuildMsg_pb.MsgUserTechUpAcclRequest()
    Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgUserTechUpAcclRequest, req, BuildMsg_pb.MsgUserTechUpAcclResponse, function(msg)
        print("msg.code:" .. msg.code)
        if msg.code == 0 then
            local tech = TechTreeDataIDMap[msg.tech.techid]
            if tech ~= nil then
                tech.Info.level = msg.tech.level
                tech.Info.endtime = msg.tech.endtime
                tech.Info.beginTime = msg.tech.beginTime
                tech.Info.originaltime = msg.tech.originaltime
                if tech.Info.endtime > Serclimax.GameTime.GetSecTime() then
                    TechState.CurUpgradeTech = tech
                end            
            end
            if callback ~= nil then
                callback(msg)
            end
        else
            Global.FloatError(msg.code, Color.white)
        end
    end, true)
end

function RequestTechUpCancel(callback)
    local req = BuildMsg_pb.MsgUserTechUpCancelRequest()
    Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgUserTechUpCancelRequest, req, BuildMsg_pb.MsgUserTechUpCancelResponse, function(msg)
    print("msg.code:" .. msg.code)
    if msg.code == 0 then
        local tech = TechTreeDataIDMap[msg.tech.techid]
        if tech ~= nil then
            tech.Info.level = msg.tech.level
            tech.Info.endtime = msg.tech.endtime
            tech.Info.beginTime = msg.tech.beginTime
            tech.Info.originaltime = msg.tech.originaltime
            if tech.Info.endtime > Serclimax.GameTime.GetSecTime() then
                TechState.CurUpgradeTech = tech
            end
        end
        if callback ~= nil then
            callback(msg)
        end

    else
        Global.FloatError(msg.code, Color.white)
    end
    end)
end

function RequestItemSubTime(tech,useItemId,exItemid,count,callback)
	local itemTBData = TableMgr:GetItemData(useItemId)
	local itemdata = ItemListData.GetItemDataByBaseId(useItemId)
	local req = ItemMsg_pb.MsgUseItemSubTimeRequest()
	if itemdata ~= nil then
		req.uid = itemdata.uniqueid
	else
		req.exchangeId = exItemid
    end
	req.num = count
	req.buildId = maincity.GetBuildingByID(6).data.uid
	req.subTimeType = 2
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemSubTimeRequest, req, ItemMsg_pb.MsgUseItemSubTimeResponse, function(msg)
		print("use item code:" .. msg.code)
		if msg.code == 0 then
            local tech = TechTreeDataIDMap[msg.tech.techid]
            if tech ~= nil then
                tech.Info.level = msg.tech.level
                tech.Info.endtime = msg.tech.endtime
                tech.Info.beginTime = msg.tech.beginTim
                tech.Info.originaltime = msg.tech.originaltime
                if tech.Info.endtime > Serclimax.GameTime.GetSecTime() then
                    TechState.CurUpgradeTech = tech
                end            
            end
            if callback ~= nil then
                callback(msg)
            end  
        else
            Global.FloatError(msg.code, Color.white)
        end
    end, true)
end

function SetupAccBtnCallBack(obj,refrush)
    SetClickCallback(obj, function() 
        	CommonItemBag.SetTittle(TextMgr:GetText("build_ui21"))
        	CommonItemBag.NotUseAutoClose()
        	CommonItemBag.NeedItemMaxValue()
            CommonItemBag.SetItemList(maincity.GetItemExchangeList(2), 1)
            local tech = GetCurUpgradeTech()
			local finish = function(go)
				local req = BuildMsg_pb.MsgUserTechUpAcclRequest()
				Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgUserTechUpAcclRequest, req, BuildMsg_pb.MsgUserTechUpAcclResponse, function(msg)
					print("msg.code:" .. msg.code)
					if msg.code == 0 then
						--加速完成
					local tech = TechTreeDataIDMap[msg.tech.techid]
						if tech ~= nil then
							tech.Info.level = msg.tech.level
							tech.Info.endtime = msg.tech.endtime
							tech.Info.beginTime = msg.tech.beginTime
							tech.Info.originaltime = msg.tech.originaltime
							if tech.Info.endtime > Serclimax.GameTime.GetSecTime() then
								TechState.CurUpgradeTech = tech
							end            
						end
						CheckUpgradeProgress(0)
						if LaboratoryUpgrade.IsOpen() then
							LaboratoryUpgrade.Init()
						end
						--MoneyListData.UpdateData(msg.fresh.money.money)
						MainCityUI.UpdateRewardData(msg.fresh)
						CommonItemBag.SetInitFunc(nil)
						GUIMgr:CloseMenu("CommonItemBag")
						if refrush ~= nil then
							refrush()
						end
						MainCityQueue.UpdateQueue();
					else
						Global.FloatError(msg.code, Color.white)
					end
				end, true)
            end
            local cancel = function(go)
		        MessageBox.Show(TextMgr:GetText("speedup_ui10")
		        ,function()
            	    local req = BuildMsg_pb.MsgUserTechUpCancelRequest()
                	Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgUserTechUpCancelRequest, req, BuildMsg_pb.MsgUserTechUpCancelResponse, function(msg)
            		print("msg.code:" .. msg.code)
            		if msg.code == 0 then
                        local tech = TechTreeDataIDMap[msg.tech.techid]
                        if tech ~= nil then
            
                            tech.Info.level = msg.tech.level
                            tech.Info.endtime = msg.tech.endtime
                            tech.Info.beginTime = msg.tech.beginTime
                            tech.Info.originaltime = msg.tech.originaltime
                            if tech.Info.endtime > Serclimax.GameTime.GetSecTime() then
                                TechState.CurUpgradeTech = tech
                            end            
                        end

                        if TechState.CurUpgradeTech ~= nil then
                            if TechState.CurUpgradeTech.Info.endtime <= Serclimax.GameTime.GetSecTime() then
                                print(TextMgr:GetText("common_ui14"))
                                AudioMgr:PlayUISfx("SFX_ui02", 1, false)
                                FloatText.Show(TextMgr:GetText(TechState.CurUpgradeTech.BaseData.Name).."  LV."..TechState.CurUpgradeTech.Info.level.."   "..TextMgr:GetText("common_ui14"), Color.white)
                                Global.GAudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_cancel",1,false)
                                FillTech(TechState.CurUpgradeTech)--TechTreeMap[TechState.CurUpgradeTech.Coord.Y][TechState.CurUpgradeTech.Coord.X])
                                if TechState.CategoryID == TechState.CurUpgradeTech.BaseData.CategoryId then
                                    ActiveConnectTech(TechState.CurUpgradeTech)
                                    RefushNextGroup(TechState.CurUpgradeTech)
                                    RefushTechUpgradeUnlock4Tech(TechState.CurUpgradeTech)
                                end
        
                                ClearTechProgress()
                                TechState.CurUpgradeTech = nil
                                MainCityQueue.UpdateQueue();
                            end	  
                        end
                        
						--MoneyListData.UpdateData(msg.fresh.money.money)
						MainCityUI.UpdateRewardData(msg.fresh)
						CommonItemBag.SetInitFunc(nil)
						GUIMgr:CloseMenu("CommonItemBag")
						if refrush ~= nil then
						    refrush()
						end						
                    end
            	end)
		        end,
		        function()
		
		        end,
		        TextMgr:GetText("common_hint1"),
		        TextMgr:GetText("common_hint2"))
            end
            CommonItemBag.SetInitFunc(function()
                local tech = GetCurUpgradeTech()
                if tech == nil then 
			        return
			    end
                local level = tech.Info.level == 0 and 1 or (tech.Info.level + 1)
            	local _text = TextMgr:GetText(tech.BaseData.Name).."  LV. "..level
            	local _time = tech.Info.endtime
            	local _level =  math.min( TechState.CurUpgradeTech.Info.level+1,TechState.CurUpgradeTech.BaseData.MaxLevel)
            	local _totalTime = tech.Info.originaltime --GetTechCostTime(tech[_level].CostTime)
            	return _text, _time, _totalTime, finish, cancel, finish, 3, UnionHelpData.RequestTechHelp, tech.Info.beginTime
            end)
			--使用加速道具 減時間
			CommonItemBag.SetUseFunc(function(useItemId , exItemid , count) 
			    local tech = GetCurUpgradeTech()
			    if tech == nil then 
			        return
			    end
	            print("Useid : " .. useItemId .. "exid : " .. exItemid .. "count :" .. count)
	            local itemTBData = TableMgr:GetItemData(useItemId)
	            local itemdata = ItemListData.GetItemDataByBaseId(useItemId)

	            local req = ItemMsg_pb.MsgUseItemSubTimeRequest()
	            if itemdata ~= nil then
		            req.uid = itemdata.uniqueid
	            else
		            req.exchangeId = exItemid
	            end
	            req.num = count
	            req.buildId = maincity.GetBuildingByID(6).data.uid
	            req.subTimeType = 2
	            Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemSubTimeRequest, req, ItemMsg_pb.MsgUseItemSubTimeResponse, function(msg)
		            print("use item code:" .. msg.code)
		            if msg.code == 0 then
						local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
						if price == 0 then
							GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
						else
							GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
						end
			            useItemReward = msg.reward
			            AudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
						
						local nameColor = Global.GetLabelColorNew(itemTBData.quality)
						local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1] )
						FloatText.Show(showText , Color.white, ResourceLibrary:GetIcon("Item/", itemTBData.icon))
						AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
						
			            --執行減時間
                        local tech = TechTreeDataIDMap[msg.tech.techid]
                        if tech ~= nil and msg.tech.techid ~= 0 then
            
                            tech.Info.level = msg.tech.level
                            tech.Info.endtime = msg.tech.endtime
                            tech.Info.beginTime = msg.tech.beginTime
                            tech.Info.originaltime = msg.tech.originaltime
                            if tech.Info.endtime > Serclimax.GameTime.GetSecTime() then
                                TechState.CurUpgradeTech = tech
                            end 
                            if TechUI ~= nil then
  	                        CountDown.Instance:Add("LaboratoryUpgrade",TechState.CurUpgradeTech.Info.endtime,function(t)
		                        TechUI.TechProgress.Time.text  = t
		                        if TechState.CurUpgradeTech == nil then
		                            ClearTechProgress()
		                            CountDown.Instance:Remove("LaboratoryUpgrade")
		                            return 
                                end
		                        local level = math.min( TechState.CurUpgradeTech.Info.level+1,tech.BaseData.MaxLevel)
		                        TechUI.TechProgress.Slider.value =math.min(1,1-(TechState.CurUpgradeTech.Info.endtime- GameTime.GetSecTime())/GetTechCostTime(TechState.CurUpgradeTech[level].CostTime))
		                        if TechState.CurUpgradeTech.Info.endtime+1 - GameTime.GetSecTime() <= 0 then
		                            CheckUpgradeProgress()
			                        CountDown.Instance:Remove("LaboratoryUpgrade")			
		                        end			
                            end)
                            end
                        else
                            if TechState.CurUpgradeTech ~= nil then
                                TechState.CurUpgradeTech.Info.endtime = 0
                                TechState.CurUpgradeTech.Info.level = math.min( TechState.CurUpgradeTech.Info.level+1,TechState.CurUpgradeTech.BaseData.MaxLevel)
                            end
                            if LaboratoryUpgrade.IsOpen() then
                                LaboratoryUpgrade.Init()
                            end                 
		  			        CommonItemBag.SetInitFunc(nil)
		                	GUIMgr:CloseMenu("CommonItemBag") 
                        end
                        CheckUpgradeProgress()
                        MainCityQueue.UpdateQueue();
						if refrush ~= nil then
						    refrush()
						end                        
			            --MoneyListData.UpdateData(msg.fresh.money.money)
			            --MainData.UpdateData(msg.fresh.maindata)
			            --ItemListData.UpdateData(msg.fresh.item)
						MainCityUI.UpdateRewardData(msg.fresh)
			            CommonItemBag.UpdateTopProgress()
                    else
                        Global.FloatError(msg.code, Color.white)
                    end
                end, true)
			end)
			CommonItemBag.SetMsgText("purchase_confirmation2", "t_today")
			GUIMgr:CreateMenu("CommonItemBag" , false)
    end)
end

local function SetupUI()
	TechUI = {}
	TechUI.Tilte = transform:Find("Container/bg_frane/bg_top/bg_title_left/title"):GetComponent("UILabel")
	TechUI.CloseBtn =  transform:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")

	TechUI.TechProgress = {}
	TechUI.TechProgress.Root = transform:Find("Container/bg_frane/bg_bottom/bg_loading").gameObject
	TechUI.TechProgress.FreeRoot =  transform:Find("Container/bg_frane/bg_bottom/bg_noskill").gameObject
    TechUI.TechProgress.Des =transform:Find("Container/bg_frane/bg_bottom/bg_loading/Text"):GetComponent("UILabel")
    TechUI.TechProgress.Slider = transform:Find("Container/bg_frane/bg_bottom/bg_loading/loading"):GetComponent("UISlider")
    TechUI.TechProgress.Time = transform:Find("Container/bg_frane/bg_bottom/bg_loading/time"):GetComponent("UILabel")
    TechUI.TechProgress.Btn = transform:Find("Container/bg_frane/bg_bottom/bg_loading/btn_finish"):GetComponent("UIButton")
    TechUI.TechProgress.BtnTxt = transform:Find("Container/bg_frane/bg_bottom/bg_loading/btn_finish/text"):GetComponent("UILabel")

    TechUI.BottomUI = transform:Find("Container/bg_frane/bg_bottom").gameObject

    TechUI.Recommendation = {}
    TechUI.Recommendation.transform = transform:Find("Container/bg_frane/bg_bottom/RecoTech")
    TechUI.Recommendation.gameObject = TechUI.Recommendation.transform.gameObject

    TechUI.Recommendation.technology = {}
    for i = 1, 2 do
    	local recommendedTechnology = {}
    	recommendedTechnology.transform = TechUI.Recommendation.transform:Find(string.format("Reco%d", i))
    	recommendedTechnology.gameObject = recommendedTechnology.transform.gameObject

    	recommendedTechnology.name = recommendedTechnology.transform:Find("bg_title/text"):GetComponent("UILabel")
    	recommendedTechnology.type = recommendedTechnology.transform:Find("Laboratoryitem/title1/type"):GetComponent("UILabel")
    	recommendedTechnology.icon = recommendedTechnology.transform:Find("Laboratoryitem/Texture"):GetComponent("UITexture")
    	recommendedTechnology.description = recommendedTechnology.transform:Find("des"):GetComponent("UILabel")

    	recommendedTechnology.level = {}
    	recommendedTechnology.level.label = recommendedTechnology.transform:Find("bg_level/text"):GetComponent("UILabel")
    	recommendedTechnology.level.progressBar = recommendedTechnology.transform:Find("bg_level/array"):GetComponent("UISlider")

    	recommendedTechnology.btn_research = recommendedTechnology.transform:Find("Research").gameObject

    	TechUI.Recommendation.technology[i] = recommendedTechnology
    end

    TechUI.Recommendation.tip_noRecommandation = {}
    TechUI.Recommendation.tip_noRecommandation[1] = transform:Find("Container/bg_frane/bg_bottom/bg_noskill").gameObject
    TechUI.Recommendation.tip_noRecommandation[2] = TechUI.Recommendation.transform:Find("notech").gameObject
    
    SetupAccBtnCallBack(TechUI.TechProgress.Btn.gameObject)

	SetupTechListUI()
	SetupTechTreeUI()
	SetupUICallBack()
end


local function InitTech()
    if TechState == nil then
	    InitTechState()
	    LoadTechDetailTable()
	    LoadTechListTable()
        AttributeBonus.RegisterAttBonusModule(_M)
    end
end

ClearUIAttribute = function()
    if TechTreeDataIDMap == nil then 
       return
   end
    table.foreach(TechTreeDataIDMap ,function(i,v) 
        v.UI = nil
    end)
end

function CalAttributeBonus()
    if TechTreeDataIDMap == nil then 
       return
    end
    local bonus = {}
    table.foreach(TechTreeDataIDMap ,function(i,v)
        if v.Info.level ~= 0 then
           local b = {}
           local t = string.split(v[v.Info.level].ArmyType,';')  
           for j=1,#(t) do
            if t[j] ~= nil then 
             local b = {}
             b.BonusType =tonumber(t[j])
             b.Attype =  v[v.Info.level].AttrType
             b.Value =  v[v.Info.level].Value
             table.insert(bonus,b)
            end
           end

       end
    end)

    return bonus
end

function ReqTechInfo()
    InitTech()
	RequestUserTechInfo(0,function(msg)
	   	if msg.code == 0 then
            RefushTechInfo4Single(msg)
            AttributeBonus.CollectBonusInfo()
            InitializePriorityQueue()
	   	end	    
	end)
end

function Awake()
    ShowResBar()
    InitTech()
	SetupUI()
	ClearTechProgress()
	DisplayTechList()
end

function Start()
	recommendedTechnologies = nil
	RequestUserTechInfo(0,function(msg)
	   	if msg.code == 0 then
            RefushTechInfo(msg)
            --DisplayTechList()
	    else
            Global.ShowError(msg.code)
	   	end	    
	end)
end

function Close()
	if TechUI ~= nil then
		TechUI.TechProgress = nil
	end
    ClearUIAttribute()
    TechUI = nil
    TechList = nil
    TechTreeMap = nil    
    CountDown.Instance:Remove("LaboratoryUpgrade")
    maincity.HideTransitionName()

    recommendedTechnologies = nil
    numRecommended = 0

    --if GetCurUpgradeTech() ~= nil then
        --maincity.UpdateConstruction()
        maincity.RefreshBuildingTransition(maincity.GetBuildingByID(6))
    --end
    if OnCloseCB ~= nil then
    	OnCloseCB()
    	OnCloseCB = nil
    end
end

function Show()
    Global.OpenUI(_M)
end

function Hide()
    TechUI = nil
    TechList = nil
    TechTreeMap = nil
    Global.CloseUI(_M)
end

function RefreshTech(msg)
	local tech = GetCurUpgradeTech()
    if tech ~= nil and msg ~= nil then
		if tech.Info.level > msg.level or (tech.Info.level == msg.level and tech.Info.endtime < msg.endtime) then
		else
	        tech.Info.endtime = msg.endtime
	        if tech.Info.endtime > Serclimax.GameTime.GetSecTime() then
	            TechState.CurUpgradeTech = tech
	        else
	        	CheckUpgradeProgress()
	        	MainCityQueue.UpdateQueue()
	        end    
	        BuildingShowInfoUI.MakeTransition(maincity.GetBuildingByID(6))        
	    end
    end
end

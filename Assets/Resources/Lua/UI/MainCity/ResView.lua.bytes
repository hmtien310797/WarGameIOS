module("ResView",package.seeall)

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

local buildingList
local resBuildingList
local btnQuit
local bgScrollViewGrid
local resBuildItem
local resBuildItemCont
local resBuildId

local resBuildShow

OnCloseCB = nil

local function QuitPressCallback(go, isPressed)
	if not isPressed then
		GUIMgr:CloseMenu("ResView")
		if OnCloseCB ~= nil then
	    	OnCloseCB()
	    	OnCloseCB = nil
	    end
	end
end

--建筑查看
local function ViewResBuildingCallback(go, isPressed)
	if not isPressed then
		local str = go.name:split("|")
		local buildid = str[2]
		local totalY = str[3]
		local resInfo = {buildId = buildid, totalYield = totalY}
		ResViewDetails.SetResBuildInfo(resInfo)
		GUIMgr:CreateMenu("ResViewDetails", false)
	end
end

function GetExAddYield(buildid , params , buildUID)
	local curYield = 0
	
	local effect = 0
	local effectValue = 0
	
	local buff = BuffData.GetBuildingBuff(buildUID)
	if buff ~= nil then
		local buffTBData = TableMgr:GetSlgBuffData(buff.buffId)
		effect = tonumber(buffTBData.Effect:split(",")[3])
		effectValue = tonumber(buffTBData.Effect:split(",")[4])
	end
	
	if buildid == 11 then--农田
		curYield = AttributeBonus.CallBonusFunc(4 , params)
		if effect == 1030 then
			curYield = curYield * (1 + effectValue/100)
		end
	elseif buildid == 12 then-- 冶炼
		curYield = AttributeBonus.CallBonusFunc(5 , params)
		if effect == 1032 then
			curYield = curYield * (1 + effectValue/100)
		end
	elseif buildid == 13 then--炼油
		curYield = AttributeBonus.CallBonusFunc(6 , params)
		if effect == 1034 then
			curYield = curYield * (1 + effectValue/100)
		end
	elseif buildid == 14 then--发电
		curYield = AttributeBonus.CallBonusFunc(7 , params)
		if effect == 1036 then
			curYield = curYield * (1 + effectValue/100)
		end
	end

	return curYield
end

function GetAddGeneratSpeedByType(restype, global)
	local params = {}
	params.base = 1
	local functionid = 0
	if restype == 3 then--粮食
		functionid = 9
	elseif restype == 4 then-- 钢铁
		functionid = 10
	elseif restype == 5 then--石油
		functionid = 11
	elseif restype == 6 then--电力
		functionid = 12
	end
	local result = AttributeBonus.CallBonusFunc(functionid , params, global) - 1
	return result
end

function GetSpeedByType(restype,level, global)
	local params = {}

	if level == nil then
		local tileData = TableMgr:GetUnionMineByResourceType(restype)
		if tileData == nil then
			error(string.format("找不到类型为:%d 等级为的资源数据", restype))
		end			
		params.base = tileData.speed
	else
		local tileData = TableMgr:GetResourceRuleDataByTypeLevel(restype, level)
		if tileData == nil then
			error(string.format("找不到类型为:%d 等级为%d的资源数据", restype, level))
		end		
		params.base = tileData.speedIncrease
	end

	
	local functionid = 0
	if restype == 3 then--粮食
		functionid = 9
	elseif restype == 4 then-- 钢铁
		functionid = 10
	elseif restype == 5 then--石油
		functionid = 11
	elseif restype == 6 then--电力
		functionid = 12
	end
	local result = AttributeBonus.CallBonusFunc(functionid , params, global)
	return result
end

function GetAddGeneratSpeed(buildid, global)
	local params = {}
	params.base = 1
	local functionid = 0
	if buildid == 11 then--粮食
		functionid = 9
	elseif buildid == 12 then-- 钢铁
		functionid = 10
	elseif buildid == 13 then--石油
		functionid = 11
	elseif buildid == 14 then--电力
		functionid = 12
	end
	local result = AttributeBonus.CallBonusFunc(functionid , params, global) - 1
	return result
end

function GetTotalSpeed(buildid)
	local count = maincity.GetBuildingCount(buildid)
	local list = {}
	list = maincity.GetSpecialBuildList()
	
	local speed = 0
	if buildid == 5 then
		for _, v in pairs(list) do
			if v.buildingData ~= nil and v.data ~= nil then
				local callupdata = TableMgr:GetCallUpData(v.data.level)
				speed = speed + callupdata.speed
			end
		end
	end
	return speed
end
	
function GetTotalYield(buildid)
	local count = maincity.GetBuildingCount(buildid)
	local list = {}
	list = maincity.GetSpecialBuildList()
	
	local yield = 0
	if buildid == 11 or buildid == 12 or buildid == 13 or buildid == 14 then
		for _, v in pairs(list) do
			if v.buildingData ~= nil and v.data ~= nil then
				local params = {}
				local curYield = TableMgr:GetBuildingResourceYield(v.buildingData.id , v.data.level)
				params.base = curYield
				yield = yield + GetExAddYield(buildid , params , v.data.uid)
			end
		end
	elseif buildid == 3 then
		for _, v in pairs(list) do
			if v.buildingData ~= nil and v.data ~= nil then
				local clinicdata = TableMgr:GetClinicData(v.data.level)
				yield = yield + clinicdata.hurt
			end
		end
	elseif buildid == 5 then
		for _, v in pairs(list) do
			if v.buildingData ~= nil and v.data ~= nil then
				local callupdata = TableMgr:GetCallUpData(v.data.level)
				yield = yield + callupdata.number
			end
		end
	end

	return math.ceil(yield)
end

function GetInjuredArmyMax()
	local baseNum = GetTotalYield(3)
	local params = {}
    params.base = baseNum
    return math.floor(AttributeBonus.CallBonusFunc(46,params))
end

function GetTotalSoldierCost()
	local totalcost = 0
	for iType = 1001 , 1004 do
		for iLevel = 1 , 4 do
			--兵营中的数量
			local soldier = Barrack.GetAramInfo(iType , iLevel)
			if soldier ~= nil and soldier.Num > 0 then
				local soldierFood = Barrack.GetFoodCost(soldier.Food , soldier.id)
				totalcost = totalcost + (soldier.Num * soldier.TeamCount * soldierFood)
			end
			
			--派出的数量
			local setoutSoldier = SetoutData.GetSetoutArmy(iType , iLevel)
			--local setoutSoldier = Barrack.GetSetoutArmInfo(iType , iLevel)
			if setoutSoldier > 0 then
				local outSoldierData = TableMgr:GetBarrackData(iType , iLevel)
				local soldierFood = Barrack.GetFoodCost(outSoldierData.Food , outSoldierData.id)
				totalcost = totalcost + (setoutSoldier * outSoldierData.TeamCount * soldierFood)
			end
		end
	end
	return totalcost
end

function Awake()
    buildingList = {}
	resBuildingList = {}
	
	resBuildShow = {}
	--农田
	
	
	
end

function Start()
	AttributeBonus.CollectBonusInfo()
	btnQuit = transform:Find("Container/bg_frane/bg_top/btn_close")
	SetPressCallback(btnQuit.gameObject, QuitPressCallback)
	SetPressCallback(transform:Find("Container").gameObject, QuitPressCallback)
	SetPressCallback(transform:Find("mask").gameObject, QuitPressCallback)
	
    buildingList = maincity.GetBuildingList()
	--local resIndex = 0
	
	resBuildingList[11] = 11 -- 强行要有农田怕不怕 -董翔
	for _, v in pairs(buildingList) do
		if v.buildingData ~= nil and v.data ~= nil then
			local bData = v.buildingData
			if bData.logicType == 10 then
				resBuildingList[bData.id] = bData.id
				--resIndex = resIndex + 1
			end
		end
	end
	
	bgScrollViewGrid = transform:Find("Container/bg_frane/Grid")
	resBuildItem = transform:Find("ResViewinfo")
	resBuildItemCont = transform:Find("ResNuminfo")
	
	for i, v in pairs(resBuildingList) do
		--print(resBuildingList[i])
	end
	
	local commandBuild = maincity.GetBuildingByID(1)
	local lvnum = commandBuild.data.level
	--print(lvnum)
	for _, v in pairs(resBuildingList) do
		local item = NGUITools.AddChild(bgScrollViewGrid.gameObject , resBuildItem.gameObject)
		item.gameObject:SetActive(true)
		item.gameObject.name = item.gameObject.name .. "|" .. v
		item.transform:SetParent(bgScrollViewGrid , false)
		
		local buildData = TableMgr:GetBuildingData(v)
		--icon
		local resIcon = item.transform:Find("bg_icon/Texture"):GetComponent("UITexture")
		resIcon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "building/", buildData.icon)
		
		--name
		local name = item.transform:Find("bg_title/text"):GetComponent("UILabel")
		name.text = TextMgr:GetText(buildData.name)
		
		--number
		local curNum = maincity.GetBuildingCount(buildData.id)
		local maxNum = 0
		local str = buildData.buildAmount:split(";")
        for i, w in ipairs(str) do
            local s = w:split(":")
            if #s > 1 then
                if tonumber(s[1]) <= lvnum and tonumber(s[2]) >= lvnum then
                    maxNum = tonumber(s[3])
                end
            end
        end

		local num = item.transform:Find("bg_title/num"):GetComponent("UILabel")
        --print(maxNum)
		num.text = string.format("[49be3c]%d[-]/%d" , curNum , maxNum)
		
		if buildData.id >= BuildMsg_pb.BuildType_Farmland and buildData.id <= BuildMsg_pb.BuildType_IronOre then
            local contentGrid = item.transform:Find("Grid")
            local content = NGUITools.AddChild(contentGrid.gameObject , resBuildItemCont.gameObject)
            content.gameObject:SetActive(true)
            content.transform:SetParent(contentGrid , false)

            local totalYield = GetTotalYield(buildData.id)
            content.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("res_ui1")
            content.transform:Find("Sprite/num"):GetComponent("UILabel").text = Global.ExchangeValue(maincity.GetResourceTotalCapacity(buildData.id))
        end

		--content 9.5 只有产量，没有消耗
		local contentGrid = item.transform:Find("Grid")
		local content = NGUITools.AddChild(contentGrid.gameObject , resBuildItemCont.gameObject)
		content.gameObject:SetActive(true)
		content.transform:SetParent(contentGrid , false)
		
		local totalYield = GetTotalYield(buildData.id)
		content.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("build_ui16")
		content.transform:Find("Sprite/num"):GetComponent("UILabel").text = Global.ExchangeValue(totalYield) .. TextMgr:GetText("build_ui15")
		
		--士兵总消耗
		if buildData.id == 11 then
			local contentCost = NGUITools.AddChild(contentGrid.gameObject , resBuildItemCont.gameObject)
			contentCost.gameObject:SetActive(true)
			contentCost.transform:SetParent(contentGrid , false)
		
			--local totalCost = tonumber(string.format("%.2f", GetTotalSoldierCost()))保留一位小数，马博士
			local totalCost = math.ceil(GetTotalSoldierCost())--取整，董翔
			
			contentCost.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("build_ui43")--"总消耗"
			if totalCost > 1 then
				contentCost.transform:Find("Sprite/num"):GetComponent("UILabel").text = "[ff0000]-" .. Global.ExchangeValue(totalCost)--[[math.ceil(totalCost)]] .. TextMgr:GetText("build_ui15") .. "[-]"
			else	
				contentCost.transform:Find("Sprite/num"):GetComponent("UILabel").text = "[ff0000]" .. Global.ExchangeValue(totalCost) .. "[-]"
			end
		end
		
		if buildData.id == 3 then
			content.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("hospital_ui6")
			content.transform:Find("Sprite/num"):GetComponent("UILabel").text = GetInjuredArmyMax()

			local contentCost = NGUITools.AddChild(contentGrid.gameObject , resBuildItemCont.gameObject)
			contentCost.gameObject:SetActive(true)
			contentCost.transform:SetParent(contentGrid , false)
			
			contentCost.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("setting_ui26")--"伤兵总数"
			local totalhurt = math.ceil(ArmyListData.GetInjuredNum())
			contentCost.transform:Find("Sprite/num"):GetComponent("UILabel").text = totalhurt
		end

		if buildData.id == 5 then
			content.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("setting_ui36")
			content.transform:Find("Sprite/num"):GetComponent("UILabel").text = totalYield

			local contentCost = NGUITools.AddChild(contentGrid.gameObject , resBuildItemCont.gameObject)
			contentCost.gameObject:SetActive(true)
			contentCost.transform:SetParent(contentGrid , false)
			
			contentCost.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("setting_ui37")
			contentCost.transform:Find("Sprite/num"):GetComponent("UILabel").text = GetTotalSpeed(5) .. "%"
		end

		contentGrid:GetComponent("UIGrid"):Reposition()
		item.gameObject.name = item.gameObject.name .. "|" .. totalYield
		--view button
		SetPressCallback(item.gameObject, ViewResBuildingCallback)
		
	end
	
	local uiInfoGrid = bgScrollViewGrid:GetComponent("UIGrid")
	uiInfoGrid:Reposition()
    transform:Find("ResNuminfo/soldierproduction"):GetComponent("UISprite").spriteName = "icon_soldiernow" .. Barrack.GetArmyStatus()
end


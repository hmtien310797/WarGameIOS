module("MobaTileInfo", package.seeall)

local BG_BOTTOM_PADDING = 20
local BG_CORNER_BOTTOM_PADDING = BG_BOTTOM_PADDING - 6
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameObject = UnityEngine.GameObject

local playerButtonCountList = {1, 2, 3, 4, 5}
local monsterButtonCountList = {2, 4}
local resourceButtonCountList = {1, 2, 3}
local unionBuildingButtonCountList = {1, 2, 3}
local unionMonsterButtonCountList = {2,4} -- 联盟叛军RebelBase
local mobaButtonCountList = {4, 5}

local _ui

local isSelfLand = false

local tileMsg
local zoneData
local tileData
local tileGid
local mapX
local mapY
local updateTimer = 0
local tileInfoMore 
local WorldMapMonsterOnceEnergy
local LoadUI
local annouceContent = {}

local BeginSpyGuildWar
local BeginSpy
local TeleportClickCallback
local GuildTeleportClickCallback

local interface={
    ["BeginSpy"] = function(target , name) BeginSpy(target , name) end,
    ["MapHelpCallback"] = function() TeleportClickCallback() end,
    ["TeamTitle"] = "ui_moba_77",
    ["TeamValue"] = function(teamid , teamBanner , teamName) return TextMgr:GetText("moba_mapzone"..teamid) end , 
    ["ShowRankTexture"] = true,
	["ShowBtnInfo"] = true,
}

local interface_guildmoba={
    ["BeginSpy"] = function(target , name) BeginSpyGuildWar(target , name) end,
    ["MapHelpCallback"] = function() GuildTeleportClickCallback() end,
    ["TeamTitle"] = "ui_worldmap_1",
	["TeamValue"] = function(teamid ,teamBanner , teamName) return string.format("【%s】%s" , teamBanner , teamName) end,
    ["ShowRankTexture"] = false,
	["ShowBtnInfo"] = false,
}

local GetInterface=function(interface_name)
    if Global.GetMobaMode() == 2 then
        return interface_guildmoba[interface_name]
    else
        return interface[interface_name]
    end
end

local moneyTypeList =
{
    food = Common_pb.MoneyType_Food,
    iron = Common_pb.MoneyType_Iron,
    oil = Common_pb.MoneyType_Oil,
    elec= Common_pb.MoneyType_Elec,
}

local moneyNameList = {}
for k, v in pairs(moneyTypeList) do
    moneyNameList[v] = k
end

function GetTileMsg()
    return tileMsg
end

function SetTileMsg(msg)
    tileMsg = msg
end

function GetPos()
    return mapX, mapY
end

local function WorldMapJump(jumpFunc)
    if Global.GetMobaMode() == 2 then
        if GUIMgr:IsMenuOpen("GuildWarMain") then
            MainCityUI.HideWorldMap(true, function()
                jumpFunc()
            end, true)
        else
            jumpFunc()
        end
    else
        if GUIMgr:IsMenuOpen("WorldMap") then
            MainCityUI.HideWorldMap(true, function()
                jumpFunc()
            end, true)
        else
            jumpFunc()
        end 
    end
end

function GetHpPercentage(sEntryData)
    sEntryData = sEntryData or tileMsg
    local monsterMsg = sEntryData.monster

    return (monsterMsg.numMax - monsterMsg.numDead) / monsterMsg.numMax
end

function GetSuggestedPower(sEntryData)
    sEntryData = sEntryData or tileMsg
    if sEntryData then
        if sEntryData.data.entryType == Common_pb.SceneEntryType_Monster then
            return tableData_tMonsterRule.data[sEntryData.monster.level].referenceFight
        elseif sEntryData.data.entryType == Common_pb.SceneEntryType_ActMonster then
            return tableData_tActMonsterRule.data[sEntryData.monster.level].Fight
        end
    end
end

function Hide()
    Global.CloseUI(_M)
end

local function DisposeGovRulingPush()
    FloatText.Show(TextMgr:GetText("GOV_ui70")  , Color.red)
    Hide()
end

local function DisposeStrongholdPush() 
    FloatText.Show(TextMgr:GetText("GOV_ui70")  , Color.red)
    Hide()
end

local function DisposeFotressPush()
	FloatText.Show("DisposeFotressPush" , Color.red)
    Hide()
end

local function DisposeTurretRulingPush()
    if tileMsg ~= nil and tileMsg.centerBuild.turret ~= nil and tileMsg.centerBuild.turret.subType ~= nil then
        if GovernmentData.CheckTurretInRuling(tileMsg.centerBuild.turret.subType) then  
            FloatText.Show(TextMgr:GetText("GOV_ui70")  , Color.red)
            Hide()
        end
    end
end

local function RefrushTurretTitle()
    if tileMsg ~= nil and tileMsg.centerBuild.turret ~= nil and tileMsg.centerBuild.turret.subType ~= nil then
        local turret_msg = GovernmentData.GetTurretData(tileMsg.centerBuild.turret.subType)
        _ui.turretInfo.title.text = TextMgr:GetText(TableMgr:GetTurretDataByid(tileMsg.centerBuild.turret.subType).name).."("..
        TextMgr:GetText(BatteryTarget.TurretStrategyState[turret_msg.strategy])..")"
    end
end

function GetSpyString(_target, _param)
    local price = TableMgr:GetSpyPrice(_target, _param)
    price = price:split(":")
    return String.Format(TextMgr:GetText("ui_worldmap_49"), TextMgr:GetText(TableMgr:GetItemData(tonumber(price[1])).name), price[2])
end

BeginSpyGuildWar = function(_target , param)	
	if not maincity.HasBuildingByID(6) then
		FloatText.Show(TextMgr:GetText("Function_hint10") , Color.red)
		return
	end
	
	if Laboratory.GetTech(1100).Info.level == 0 then
		MessageBox.Show(TextMgr:GetText("worldmap_spyunlock") , 
			function() 
				WorldMapJump(function()
					Laboratory.OpenTech(1100)
				end)
			end , 
			function() 
				
			end
		)
		return
	end
	
	if _target == 1 then
		local req = GuildMobaMsg_pb.GuildMobaArmySetoutStarRequest()
		req.seUid = tileMsg ~= nil and tileMsg.data.uid or 0
		req.pos.x = mapX
		req.pos.y = mapY
		req.pathType = Common_pb.TeamMoveType_ReconPlayer
		--Global.DumpMessage(req , "d:/guildwarSpy.lua")
		LuaNetwork.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaArmySetoutStarRequest, req:SerializeToString(), function(typeId, data)
			local msg = GuildMobaMsg_pb.GuildMobaArmySetoutStarResponse()
			msg:ParseFromString(data)
			--Global.DumpMessage(msg , "d:/guildwarSpy.lua")
			if msg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(msg.code)
				Hide()
			else
				Hide()
			end
		end, false)
    else
		local req = GuildMobaMsg_pb.GuildMobaArmySetoutStarRequest()
		req.seUid = tileMsg ~= nil and tileMsg.data.uid or 0
		req.pos.x = mapX
		req.pos.y = mapY
		req.pathType = Common_pb.TeamMoveType_ReconMonster
		
			--Global.DumpMessage(req , "d:/guildwarSpy.lua")
		LuaNetwork.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaArmySetoutStarRequest, req:SerializeToString(), function(typeId, data)
			local msg = GuildMobaMsg_pb.GuildMobaArmySetoutStarResponse()
			msg:ParseFromString(data)
			--Global.DumpMessage(msg , "d:/guildwarSpy.lua")
			if msg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(msg.code)
				Hide()
			else
				Hide()
			end
		end, false)
    end
end

BeginSpy = function(_target, _param)
    if not MobaBattleMove.CheckActionList() then
        return
    end  

	--[[if not maincity.HasBuildingByID(6) then
		FloatText.Show(TextMgr:GetText("Function_hint10") , Color.red)
		return
	end]]
	
	--[[if Laboratory.GetTech(1100).Info.level == 0 then
		MessageBox.Show(TextMgr:GetText("worldmap_spyunlock") , 
			function() 
				WorldMapJump(function()
					Laboratory.OpenTech(1100)
				end)
			end , 
			function() 
				
			end
		)
		return
	end]]
	if MobaTechData.GetTechLevelById(9) == 0 then
		MessageBox.Show(TextMgr:GetText("ui_moba_102"), 
			function() 
				MobaStore.Show()
                MobaStore.SelectPage(2)
                MobaTechData.SetTarget(6.7)
			end , 
			function() 
				
			end
		)
		return
	end
	
    print(_target)
    if _target == 1 then
        --MainCityUI.CheckShield(Common_pb.TeamMoveType_ReconPlayer, function()
           -- MessageBox.Show(GetSpyString(_target, _param), function()
                local req = MobaMsg_pb.MsgMobaArmySetoutStarRequest()
                req.seUid = tileMsg ~= nil and tileMsg.data.uid or 0
                req.pos.x = mapX
                req.pos.y = mapY
                req.pathType = Common_pb.TeamMoveType_ReconPlayer
                LuaNetwork.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaArmySetoutStarRequest, req:SerializeToString(), function(typeId, data)
                    local msg = MobaMsg_pb.MsgMobaArmySetoutStarResponse()
                    msg:ParseFromString(data)
                    if msg.code ~= ReturnCode_pb.Code_OK then
                        Global.ShowError(msg.code)
                        Hide()
                    else
                        --MainCityUI.UpdateRewardData(msg.fresh)
                        Hide()
                    end
                end, false)
            --end, function() end)
        --end)
    else
        --MessageBox.Show(GetSpyString(_target, _param), function()
            local req = MobaMsg_pb.MsgMobaArmySetoutStarRequest()
            req.seUid = tileMsg ~= nil and tileMsg.data.uid or 0
            req.pos.x = mapX
            req.pos.y = mapY
            req.pathType = Common_pb.TeamMoveType_ReconMonster
            LuaNetwork.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaArmySetoutStarRequest, req:SerializeToString(), function(typeId, data)
                local msg = MobaMsg_pb.MsgMobaArmySetoutStarResponse()
                msg:ParseFromString(data)
                if msg.code ~= ReturnCode_pb.Code_OK then
                    Global.ShowError(msg.code)
                    Hide()
                else
                    --MainCityUI.UpdateRewardData(msg.fresh)
                    Hide()
                end
            end, false)
        --end, function() end)
    end
end

function BeginSpyEx(mapX , mapY ,_target ,_param, tileMsg , callback)

    if not MobaBattleMove.CheckActionList() then
        return
    end

	if _target == 1 then
        --MainCityUI.CheckShield(Common_pb.TeamMoveType_ReconPlayer, function()
            --MessageBox.Show(GetSpyString(_target, _param), function()
                local req = MobaMsg_pb.MsgMobaArmySetoutStarRequest()
                req.seUid = tileMsg ~= nil and tileMsg.data.uid or 0
                req.pos.x = mapX
                req.pos.y = mapY
                req.pathType = Common_pb.TeamMoveType_ReconPlayer

                LuaNetwork.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaArmySetoutStarRequest, req:SerializeToString(), function(typeId, data)
                    local msg = MobaMsg_pb.MsgMobaArmySetoutStarResponse()
                    msg:ParseFromString(data)
                    if msg.code ~= ReturnCode_pb.Code_OK then
                        Global.ShowError(msg.code)
                        Hide()
                    else
                       -- MainCityUI.UpdateRewardData(msg.fresh)
                        Hide()
                    end
                end, false)
            --end, function() end)
        --end)
    else
        --MessageBox.Show(GetSpyString(_target, _param), function()
            local req = MobaMsg_pb.MsgMobaArmySetoutStarRequest()
            req.seUid = tileMsg ~= nil and tileMsg.data.uid or 0
            req.pos.x = mapX
            req.pos.y = mapY
            req.pathType = Common_pb.TeamMoveType_ReconMonster

            LuaNetwork.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaArmySetoutStarRequest, req:SerializeToString(), function(typeId, data)
                local msg = MobaMsg_pb.MsgMobaArmySetoutStarResponse()
                msg:ParseFromString(data)
                if msg.code ~= ReturnCode_pb.Code_OK then
                    Global.ShowError(msg.code)
                    Hide()
                else
                    --MainCityUI.UpdateRewardData(msg.fresh)
                    Hide()
                end
				if callback ~= nil then
					callback(true)
				end
            end, false)
        --end, function() 
		--	if callback ~= nil then
		--		callback(false)
		--	end
		--end)
    end
end

function Update()
    if _ui == nil then
        return
    end
    local serverTime = GameTime.GetSecTime()
    updateTimer = updateTimer - GameTime.realDeltaTime
    if updateTimer > 0 then
        return
    else
        updateTimer = 1
    end
    local entryType = Common_pb.SceneEntryType_None
    if tileMsg ~= nil then
        entryType = tileMsg.data.entryType
    end
	if _ui == nil then 
		return
	end
    local tileInfo = _ui.blockInfo
    if entryType == Common_pb.SceneEntryType_None then
    elseif entryType == Common_pb.SceneEntryType_Home then
    elseif entryType == Common_pb.SceneEntryType_Occupy then
        tileInfo = _ui.playerInfo
        local occupyMsg = tileMsg.occupy
        local infoList = _ui.playerInfo.infoList
        local leftSecond = Global.GetLeftCooldownSecond(occupyMsg.starttime + occupyMsg.totaltime)
        if leftSecond > 0 then
            infoList[1].nameLabel.gameObject:SetActive(true)
            infoList[1].valueLabel.gameObject:SetActive(true)
            infoList[1].valueLabel.text = Global.SecondToTimeLong(leftSecond)
            infoList[1].finishLabel.gameObject:SetActive(false)
        else
            infoList[1].nameLabel.gameObject:SetActive(false)
            infoList[1].valueLabel.gameObject:SetActive(false)
            infoList[1].finishLabel.gameObject:SetActive(true)
        end
    elseif entryType == Common_pb.SceneEntryType_Monster then
        tileInfo = _ui.monsterInfo

        local intervalTimeId = (serverTime - MainData.GetServerStartTime()) < tonumber(tableData_tGlobal.data[100157].value) and 100158 or 100024
        
        local timeText = Global.GetLeftCooldownTextLong(tileMsg.monster.time + tonumber(tableData_tGlobal.data[intervalTimeId].value))
        tileInfo.fleeLabel.text = timeText

        local sceneEnergy = MainData.GetSceneEnergy()
        local maxSceneEnergy = MainData.GetMaxSceneEnergy()
        tileInfo.energyLabel.text = string.format("%d/%d", sceneEnergy, maxSceneEnergy)
        tileInfo.energySlider.value = sceneEnergy / maxSceneEnergy
        tileInfo.energyLabel1.text, tileInfo.energyLabel2.text = MainData.GetSceneEnergyCooldownText()
    elseif entryType == Common_pb.SceneEntryType_ActMonster then
		local sceneEnergy = MainData.GetSceneEnergy()
        local maxSceneEnergy = MainData.GetMaxSceneEnergy()
	
		if tileMsg.monster ~= nil and tileMsg.monster.digMon ~= nil and tileMsg.monster.digMon.monsterBaseId > 0 then
            tileInfo = _ui.pveMonster
			local timeText = Global.GetLeftCooldownTextLong(tileMsg.monster.actMonster.escapeTime)
			tileInfo.fleeLabel.text = timeText
			tileInfo.monsterLife.value = sceneEnergy / maxSceneEnergy
			tileInfo.monsterLifeLab.text = sceneEnergy .. "/" .. maxSceneEnergy
			return
		end
		
		if tileMsg.monster ~= nil and tileMsg.monster.guildMon.guildMonster ~= nil and tileMsg.monster.guildMon.guildMonster then
			tileInfo = _ui.guildMonster
			local timeText = Global.GetLeftCooldownTextLong(tileMsg.monster.actMonster.escapeTime)
			tileInfo.fleeLabel.text = timeText
			return
		end 
		
        tileInfo = _ui.rebelInfo

        local timeText = Global.GetLeftCooldownTextLong(tileMsg.monster.actMonster.escapeTime)
        tileInfo.fleeLabel.text = timeText

        tileInfo.energyLabel.text = string.format("%d/%d", sceneEnergy, maxSceneEnergy)
        tileInfo.energySlider.value = sceneEnergy / maxSceneEnergy
        tileInfo.energySlider.value = sceneEnergy / maxSceneEnergy
        tileInfo.energyLabel1.text, tileInfo.energyLabel2.text = MainData.GetSceneEnergyCooldownText()
    elseif entryType >= Common_pb.SceneEntryType_ResFood and entryType <= Common_pb.SceneEntryType_ResElec then
        local resMsg = tileMsg.res
        local owner = resMsg.owner
        local charId = MobaMainData.GetCharId()  
        if owner ~= 0 then
            local infoList = _ui.resourceInfo.infoList

            local takeStartTime = resMsg.takestarttime
            local takeSpeed = resMsg.takespeed
            local capacity = tileData.capacity
            local takeElapsedTime = math.min(serverTime - takeStartTime, resMsg.taketime)
            local myTakeCount = math.min(takeSpeed * takeElapsedTime, capacity)
            local resourceLeftCount = capacity - resMsg.num - myTakeCount
            infoList[1].valueLabel.text = resourceLeftCount
            if owner == charId then
                infoList[2].valueLabel.text = myTakeCount

                infoList[3].nameLabel.text = TextMgr:GetText(Text.ui_worldmap_42)

                local endTime = resMsg.takestarttime + resMsg.taketime
                local leftTime = Global.GetLeftCooldownSecond(endTime)
                local timeText = Global.GetLeftCooldownTextLong(endTime)

                infoList[3].valueLabel.text = timeText
                infoList[3].progressBar.value = 1 - leftTime / resMsg.taketime
            end
        end
    elseif entryType == Common_pb.SceneEntryType_GuildBuild then
        local infoList = _ui.unionBuildingInfo.infoList
        local buildingMsg = tileMsg.guildbuild
        local buildingData = TableMgr:GetUnionBuildingData(buildingMsg.baseid)
        local guildMsg = tileMsg.ownerguild
        local selfGuildId = MobaMainData.GetTeamID()
        local buildingType = buildingData.type

        --己方联盟建筑
        if selfGuildId == guildMsg.guildid then
            --联盟超级矿
            if buildingType == MapMsg_pb.GuildBuildTypeGuildMine then
                --联盟矿采集阶段
                if buildingMsg.isCompleted then
                    infoList[1].valueLabel.text = math.max(buildingMsg.totalRemaining - buildingMsg.totalSpeed * (serverTime - buildingMsg.nowTime), 0)
                    --自己参与的
                    if buildingMsg.hasSelfArmy and buildingMsg.selfSpeed > 0 then
                        infoList[2].valueLabel.text = buildingMsg.selfGather + buildingMsg.selfSpeed * (serverTime - buildingMsg.nowTime)
                        infoList[3].valueLabel.text = Global.GetLeftCooldownTextLong(buildingMsg.lifeTime) 
                        --自己未参与的
                    else
                    end
                    --联盟矿建造阶段
                else
                    if buildingMsg.countdown then
                        local timeText = Global.GetLeftCooldownTextLong(buildingMsg.completetime)
                        infoList[1].valueLabel.text = timeText
                    end
                end
            end
            --敌方联盟建筑
        else
            if buildingType == MapMsg_pb.GuildBuildTypeGuildMine then
                if buildingMsg.isCompleted then
                    infoList[1].valueLabel.text = math.max(buildingMsg.totalRemaining - buildingMsg.totalSpeed * (serverTime - buildingMsg.nowTime), 0)
                    infoList[2].valueLabel.text = Global.GetLeftCooldownTextLong(buildingMsg.lifeTime) 
                end
            end
        end
    end
end

local function InMapGrade(x, y, gradeData)
    return x >= gradeData.minX and x <= gradeData.maxX and y >= gradeData.minY and y <= gradeData.maxY
end

local function GetMapGradeData(x, y)
    local gradeTable = tableData_tMobaMapGrade.data
    for i = 1, 2 do
        local gradeData = gradeTable[i]
        if x >= gradeData.PositionX and x <= gradeData.PositionX + gradeData.WidthX and y >= gradeData.PositionY and y <= gradeData.PositionY + gradeData.WidthY then
            return gradeData
        end
    end

    return gradeTable[3]
end

local function SetLandInfo(tileInfo, artSettingData)
    local minX, minY = MobaMain.MobaMinPos()
    local gradeData = GetMapGradeData(mapX - minX, mapY - minY)
    tileInfo.levelBg.gameObject:SetActive(false)
    --tileInfo.help.gameObject:SetActive(MapHelp.CheckHelp(tileGid))
    SetClickCallback(tileInfo.help.gameObject, function() 
        MapHelp.OpenMulti(410)
    end)
    tileInfo.nameLabel.text = TextMgr:GetText(gradeData.tileName)
    tileInfo.nameBgSprite2.spriteName = gradeData.blockTitlebg
    tileInfo.icon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", gradeData.blockIcon)
    --[[
    local borderMsg = WorldBorderData.GetBorderDataByXY(mapX, mapY)
    if borderMsg ~= nil then
        tileInfo.unionLabel.text = string.format("[%s]%s", borderMsg.guildbanner, borderMsg.guildname)
    else
        tileInfo.unionLabel.text = TextMgr:GetText(Text.union_nounion)
    end
    --]]
	print("isSelfLand d ",gradeData.id , MobaMainData.GetTeamID())

    local teamId = MobaMainData.GetTeamID() 
		
	isSelfLand = gradeData.id == teamId
    tileInfo.teleportButton.gameObject:SetActive(gradeData.id == 3 or gradeData.id == teamId)
end

local function SetHomeInfo(tileInfo)
    local buttonGroupList = tileInfo.buttonGroupList
    local buttonCount = 0
    local homeMsg = tileMsg.home
    local guildMsg = tileMsg.ownerguild
    local charId = MobaMainData.GetCharId()  
    local selfGuildId = MobaMainData.GetTeamID() 

    local infoList = tileInfo.infoList
    local teamId = tileMsg.ownerguild.guildid
	--Global.DumpMessage(tileMsg , "d:/tileMsg.lua")
	--print(TextMgr:GetText(GetInterface("TeamTitle")) , GetInterface("TeamValue")(teamId , guildMsg.guildbanner , guildMsg.guildname) ,guildMsg.guildname , guildMsg.guildbanner)
    infoList[1].valueLabel.text = GetInterface("TeamValue")(teamId , guildMsg.guildbanner , guildMsg.guildname)--TextMgr:GetText("moba_mapzone" .. teamId)
	infoList[1].nameLabel.text = TextMgr:GetText(GetInterface("TeamTitle"))
    infoList[2].valueLabel.text = homeMsg.pkvalue
	tileInfo.rankTexture.gameObject:SetActive(GetInterface("ShowRankTexture"))
    
	tileInfo.btnInfo.gameObject:SetActive(homeMsg.charid ~= charId and GetInterface("ShowBtnInfo"))
	
	SetClickCallback(tileInfo.btnInfo.gameObject, function(go)
        MobaPersonalInfo.Show(homeMsg.charid)
    end)
	
	
	SetClickCallback(tileInfo.skinButton.gameObject, function(go)
        if homeMsg.charid == charId then
            Skin.Show()
        else
            Skin_other.Show(homeMsg.skin)
        end
    end)
    if homeMsg.charid == charId then
        tileInfo.bg.spriteName = "common_bg"
        buttonCount = 3

		
        --进入自己主基地
		SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
            --Hide()
            --MainCityUI.HideWorldMap(true, nil, true)
            print("afasfasfasf")
			
			MobaBattleMoveData.GetOrReqUserAttackFormaion(function(form)
				local selfFormation = {}
				MobaBattleMoveData.CloneFormation(selfFormation,form)
				MobaEmbattle.Show(1,selfFormation,nil,function(new_form)
					--selfFormation = new_form
					--formationSmall:SetLeftFormation(selfFormation)
					--formationSmall:Awake(false)
				end , "ParadeGround")
			end)
			
        end)
		
        --buttonGroupList[buttonCount][2].label.text = TextMgr:GetText(Text.ui_worldmap_47)
        SetClickCallback(buttonGroupList[buttonCount][2].button.gameObject, function()
            --Hide()
            --MainCityUI.HideWorldMap(true, nil, true)
            MobaWallHero.Show(Common_pb.BattleTeamType_CityDefence)
        end)
        --自己基地更多
        buttonGroupList[buttonCount][3].label.text = TextMgr:GetText(Text.ui_worldmap_30)
        SetClickCallback(buttonGroupList[buttonCount][3].button.gameObject, function()
            --MessageBox.Show(TextMgr:GetText(Text.common_ui1))
            local name = homeMsg.name
            if guildMsg.guildid ~= 0 then 
				local teamdata = TableMgr:GetMobaTeamData(guildMsg.guildid)
                name = string.format("【%s】%s", TextMgr:GetText(teamdata.Name), homeMsg.name)
            end
            --tileInfoMore:Open(buttonGroupList[buttonCount][3].button.gameObject,name,mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
			tileInfoMore:Open(buttonGroupList[buttonCount][3].button.gameObject,name,mapX,mapY,Skin.GetSkinTextureNamePath(homeMsg.skin))
            --Traget_Set.Show(homeMsg.name,mapX,mapY)

        end)
        --print("EEEEEEEEEEEEEEEEEE",TextMgr:GetText(Text.ui_worldmap_30),buttonGroupList[buttonCount][4].label.text)
        --buttonGroupList[buttonCount][4].label.text = TextMgr:GetText(Text.ui_worldmap_30)
        SetClickCallback(buttonGroupList[buttonCount][4].button.gameObject, function()
            --MobaEmbassy.ShowGOVMode(uid,mapX,mapY,nil) 
            Global.OpenUI(MobaEmbassy)
        end)        
    elseif selfGuildId ~= 0 and selfGuildId == guildMsg.guildid then
        tileInfo.bg.spriteName = "common_bg"
        buttonCount = 2

        --[[
        --盟友基地运输
        buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.ui_worldmap_63)
        SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
            if not MobaBattleMove.CheckActionList() then
                return
            end            
            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            local selflocal = MapInfoData.GetMyBasePos()
            local req = ClientMsg_pb.MsgCheckPlayerSomeRequest()
            req.charid = homeMsg.charid
            req.checktype = 1
            Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCheckPlayerSomeRequest, req, ClientMsg_pb.MsgCheckPlayerSomeResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    if msg.value > 0 then
                        Trade.Show(uid, mapX, mapY, selflocal.x, selflocal.y)
                    else
                        MessageBox.Show(TextMgr:GetText("TradeHall_ui12"))
                    end
                else
                    Global.ShowError(msg.code)
                end
            end, false)
            --MobaBattleMove.Show(Common_pb.TeamMoveType_ResTransport, uid, mapX, mapY, Hide)
        end)
        --]]
        --盟友基地驻防
        buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.ui_moba_165)
        SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            MobaEmbassy.CanEmbassy(uid,tileMsg ~= nil and (tileMsg.data.pos.x) or mapX,tileMsg ~= nil and (tileMsg.data.pos.y) or mapY,homeMsg.charid)      
            --MobaBattleMove.Show(Common_pb.TeamMoveType_Garrison, uid, mapX, mapY, Hide)
        end)
        --盟友基地更多
        buttonGroupList[buttonCount][2].label.text = TextMgr:GetText(Text.ui_worldmap_29)
        SetClickCallback(buttonGroupList[buttonCount][2].button.gameObject, function()
            --MessageBox.Show(TextMgr:GetText(Text.common_ui1))
            --Traget_Set.Show(homeMsg.name,mapX,mapY)
            local name = homeMsg.name
            if guildMsg.guildid ~= 0 then 
                --name = string.format("[%s]%s", guildMsg.guildbanner, homeMsg.name)
				local teamdata = TableMgr:GetMobaTeamData(guildMsg.guildid)
                name = string.format("【%s】%s", TextMgr:GetText(teamdata.Name), homeMsg.name)
            end
           -- tileInfoMore:Open(buttonGroupList[buttonCount][2].button.gameObject,name,mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
			
			print(homeMsg.skin)
			print(Skin.GetSkinTextureNamePath(homeMsg.skin))
			tileInfoMore:Open(buttonGroupList[buttonCount][2].button.gameObject,name,mapX,mapY,Skin.GetSkinTextureNamePath(homeMsg.skin))
        end)
        --[[
        --盟友基地查看
        buttonGroupList[buttonCount][4].label.text = TextMgr:GetText(Text.Union_Radar_ui9)
        SetClickCallback(buttonGroupList[buttonCount][4].button.gameObject, function()
            OtherInfo.RequestShow(homeMsg.charid)
        end)
        --]]
    else
        tileInfo.bg.spriteName = "common_bg"

        --tileInfo.help.gameObject:SetActive(MapHelp.CheckHelp(tileGid))
        SetClickCallback(tileInfo.help.gameObject, function() 
            MapHelp.OpenMulti(500)
        end)
        MapHelp.Open(500, false, nil, true)
        buttonCount = 4
        --侦查敌人基地
        buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.ui_worldmap_29)
        SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
            if Global.IsInSafeAreaOfGuildMoba(tileMsg ~= nil and tileMsg.data.pos.x or mapX,tileMsg ~= nil and tileMsg.data.pos.y or mapY) then
                FloatText.Show(TextMgr:GetText("ui_unionwar_25")  , Color.red)
                return
            end
			GetInterface("BeginSpy")(1, tonumber(tileMsg.home.homelvl))
        end)
        --攻击敌人基地
        buttonGroupList[buttonCount][4].label.text = TextMgr:GetText(Text.ui_worldmap_30)
        SetClickCallback(buttonGroupList[buttonCount][4].button.gameObject, function()
            if Global.IsInSafeAreaOfGuildMoba(tileMsg ~= nil and tileMsg.data.pos.x or mapX,tileMsg ~= nil and tileMsg.data.pos.y or mapY) then
                FloatText.Show(TextMgr:GetText("ui_unionwar_25")  , Color.red)
                return
            end 
            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            MobaBattleMove.Show(Common_pb.TeamMoveType_AttackPlayer, uid, 0, tileMsg ~= nil and tileMsg.data.pos.x or mapX,tileMsg ~= nil and tileMsg.data.pos.y or mapY, Hide)
        end)
        --集结敌人基地
        buttonGroupList[buttonCount][2].label.text = TextMgr:GetText(Text.ui_worldmap_28)
        SetClickCallback(buttonGroupList[buttonCount][2].button.gameObject, function()
            if Global.IsInSafeAreaOfGuildMoba(tileMsg ~= nil and tileMsg.data.pos.x or mapX,tileMsg ~= nil and tileMsg.data.pos.y or mapY) then
                FloatText.Show(TextMgr:GetText("ui_unionwar_25")  , Color.red)
                return
            end 
            -- MessageBox.Show(TextMgr:GetText(Text.common_ui1))
            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            local mtc = MassTroopsCondition()
            --集结需要的条件参数输入
            --集结需要的条件判定
            local x = mapX
            local y = mapY
            mtc.target_enable_mass =  true
            mtc:MobaCreateMass4BattleCondition(nil,function(success)
                if success then
                    assembled_time.Show(function(time)
                        if time ~= 0 then
                            --[[
                            AttributeBonus.CollectBonusInfo(nil,false,"MobaTechData")
                            local bonus = AttributeBonus.GetBonusInfos()  
                            local base = TableMgr:GetMobaUnitInfoByID(8)
                            local army_num = tonumber( base.Value) +(bonus[1109] ~= nil and bonus[1109] or 0)
                            --]]
                            local army_num = Global.MobaArmyNum4MassPlayer()
                            mtc:MobaShowCreateMassBattleMove(uid,tileMsg.home.name, x, y,army_num,time)                                                       
                        end
                    end , true)
                end
            end)   
            --MobaBattleMove.Show(Common_pb.TeamMoveType_Garrison, , Hide)
        end)
        --敌人基地更多
        buttonGroupList[buttonCount][3].label.text = TextMgr:GetText(Text.ui_worldmap_6)
        SetClickCallback(buttonGroupList[buttonCount][3].button.gameObject, function()
            --MessageBox.Show(TextMgr:GetText(Text.common_ui1))
            --Traget_Set.Show(homeMsg.name,mapX,mapY)
            local name = homeMsg.name
            if guildMsg.guildid ~= 0 then 
                --name = string.format("[%s]%s", guildMsg.guildbanner, homeMsg.name)
				local teamdata = TableMgr:GetMobaTeamData(guildMsg.guildid)
                name = string.format("【%s】%s", TextMgr:GetText(teamdata.Name), homeMsg.name)
            end            
           -- tileInfoMore:Open(buttonGroupList[buttonCount][3].button.gameObject,name,mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
			tileInfoMore:Open(buttonGroupList[buttonCount][3].button.gameObject,name,mapX,mapY,Skin.GetSkinTextureNamePath(homeMsg.skin))
        end)
        --[[
        --敌人基地查看
        buttonGroupList[buttonCount][5].label.text = TextMgr:GetText(Text.Union_Radar_ui9)
        SetClickCallback(buttonGroupList[buttonCount][5].button.gameObject, function()
            OtherInfo.RequestShow(homeMsg.charid)
        end)
        --]]
    end

    tileInfo.levelBg.gameObject:SetActive(true)
    tileInfo.levelLabel.text = homeMsg.homelvl
    tileInfo.nameLabel.text = homeMsg.name
    
    --[[
    if guildMsg.guildid == 0 then
        tileInfo.unionLabel.text = TextMgr:GetText(Text.union_nounion)
    else
        tileInfo.unionLabel.text = string.format("[%s]%s", guildMsg.guildbanner, guildMsg.guildname)
    end
    --]]
    --tileInfo.powerLabel.text = homeMsg.pkvalue

    for _, v in ipairs(playerButtonCountList) do
        buttonGroupList[v].transform.gameObject:SetActive(buttonCount == v)
        if buttonCount == v then
            local buttonGroupTransform = buttonGroupList[v].transform
            local halfHeight = buttonGroupTransform:GetComponent("UIWidget").height * 0.5
            local positionY = tileInfo.bg.transform:InverseTransformPoint(buttonGroupTransform.position).y
            tileInfo.bg.height = -positionY + halfHeight + BG_BOTTOM_PADDING 
        end
    end
    local hasWanted = #homeMsg.prisoner.info > 0
    if hasWanted then
        table.sort(homeMsg.prisoner.info, function(v1, v2)
            local totalMoney1 = 0
            for _, v in ipairs(v1.offerReward) do
                totalMoney1 = totalMoney1 + v.value
            end

            local totalMoney2 = 0
            for _, v in ipairs(v2.offerReward) do
                totalMoney2 = totalMoney2 + v.value
            end

            return totalMoney1 > totalMoney2
        end)

        local totalMoneyList = {food = 0, iron = 0, oil = 0, elec = 0}
        for i, v in ipairs(homeMsg.prisoner.info) do
            local rewardTransform
            if i > tileInfo.prisoner.grid.transform.childCount then
                rewardTransform = NGUITools.AddChild(tileInfo.prisoner.grid.gameObject, tileInfo.prisoner.prefab).transform
            else
                rewardTransform = tileInfo.prisoner.grid.transform:GetChild(i - 1)
            end
            local guildBanner = v.guildBanner
            if guildBanner == "" then
                guildBanner = "---"
            end
            local nameLabel = rewardTransform:Find("bg/name"):GetComponent("UILabel")
            SetClickCallback(nameLabel.gameObject, function()
                OtherInfo.RequestShow(v.id)
            end)
            nameLabel.text = string.format("[F1CF63][%s][-]%s", guildBanner, v.name)
            local moneyList = {food = 0, iron = 0, oil = 0, elec = 0}
            for ii, vv in ipairs(v.offerReward) do
                local moneyName = moneyNameList[vv.id]
                local money = totalMoneyList[moneyName]
                totalMoneyList[moneyName] = money + vv.value
                moneyList[moneyName] = vv.value
            end

            for kk, vv in pairs(moneyList) do
                rewardTransform:Find(string.format("bg/%s/text_num", kk)):GetComponent("UILabel").text = Global.ExchangeValue(vv)
            end

            rewardTransform.gameObject:SetActive(true)
        end
        for i = #homeMsg.prisoner.info + 1, tileInfo.prisoner.grid.transform.childCount do
            tileInfo.prisoner.grid.transform:GetChild(i - 1).gameObject:SetActive(false)
        end

        tileInfo.prisoner.grid.repositionNow = true
        for k, v in pairs(tileInfo.wanted.moneyLabelList) do
            v.text = Global.ExchangeValue(totalMoneyList[k])
        end
        SetClickCallback(tileInfo.wanted.infoButton.gameObject, function(go)
            tileInfo.transform.gameObject:SetActive(false)
            tileInfo.prisoner.gameObject:SetActive(true)
        end)
        SetClickCallback(tileInfo.prisoner.gameObject, function(go)
            tileInfo.transform.gameObject:SetActive(true)
            tileInfo.prisoner.gameObject:SetActive(false)
        end)
    end
    tileInfo.wanted.gameObject:SetActive(hasWanted)
end

local function LoadRewardList(ui, gridTransform, dropShow, itemScale)
    NGUITools.DestroyChildren(gridTransform)
	local itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    local heroPrefab = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")

    for v in string.gsplit(dropShow, ";") do
        local dropList = string.split(v, ":")
        local contentType = tonumber(dropList[1])
        local contentId = tonumber(dropList[2])
        if contentType == 1 then
            local item = {}
            local itemTransform = NGUITools.AddChild(gridTransform.gameObject, itemPrefab).transform
            if itemScale ~= nil then
                itemTransform.localScale = itemScale
            end
            UIUtil.LoadItemObject(item, itemTransform)
            local itemData = TableMgr:GetItemData(contentId)
            local itemCount = 0
            UIUtil.LoadItem(item, itemData, itemCount)
            UIUtil.SetClickCallback(item.transform.gameObject, function(go)
                if go == ui.tipObject then
                    ui.tipObject = nil
                else
                    ui.tipObject = go
                    Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
                end
            end)
        elseif contentType == 3 then
            local heroTransform = NGUITools.AddChild(gridTransform.gameObject, heroPrefab).transform
            heroTransform.localScale = Vector3(0.6,0.6,1)
            local hero = {}

            HeroList.LoadHeroObject(hero, heroTransform)
            local heroData = TableMgr:GetHeroData(contentId)
            local heroMsg = Common_pb.HeroInfo() 
            heroMsg.star = v.star
            heroMsg.level = v.level
            heroMsg.num = 1
            HeroList.LoadHero(hero, heroMsg, heroData)
            hero.nameLabel.gameObject:SetActive(false)

            SetClickCallback(hero.btn.gameObject, function(go)
                if go == ui.tipObject then
                    ui.tipObject = nil
                else
                    ui.tipObject = go
                    Tooltip.ShowItemTip({name = TextMgr:GetText(heroData.nameLabel), text = TextMgr:GetText(heroData.description)})
                end
            end)
        end
    end
end

local function SetMonsterInfo(tileInfo)
    local monsterMsg = tileMsg.monster
    local monsterLevel = monsterMsg.level
    tileInfo.levelBg.gameObject:SetActive(true)
    tileInfo.levelLabel.text = monsterLevel
    tileInfo.nameLabel.text = TextMgr:GetText(tileData.name)
    local rebelMsg = RebelWantedData.GetRebelData(monsterLevel)
    local monsterData = tableData_tMobaMonster.data[monsterLevel]
    local dropShow = monsterData.DropShow
    print("HHHHHHHHHHHHHHHHHHHHHHHHHHHMonster ",tileMsg.data.uid,tileMsg.data.pos.x,tileMsg.data.pos.y)


    local hpPercentage = GetHpPercentage()
    tileInfo.hpBar.value = hpPercentage
    tileInfo.hpPercentage.text = string.format("%d%%", math.floor(hpPercentage * 100))

    tileInfo.suggestPower.text = GetSuggestedPower()

    LoadRewardList(_ui, tileInfo.rewardGrid.transform, dropShow)

	--tileInfo.help.gameObject:SetActive(MapHelp.CheckHelp(tileGid))
    SetClickCallback(tileInfo.help.gameObject, function()
        --MapHelp.OpenMulti(200)
        MapHelp.Open(2506, false, nil, false, true)
    end)

    SetClickCallback(tileInfo.btn_add, Global.ShowNoEnoughSceneEnergy)
	
	
	--坐标
	SetClickCallback(tileInfo.btn_coord.gameObject, function() 
	 
        tileInfoMore:Open(tileInfo.btn_coord.gameObject,TextMgr:GetText(tileData.name),mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)

	end)
	
    local buttonGroupList = tileInfo.buttonGroupList
	local unLockLevel = RebelWantedData.GetMaxLevel()
    --local buttonCount = monsterLevel <= unLockLevel and 4 or 2--RebelWantedData.IsLevelUnlocked(monsterLevel) and 4 or 2
    local buttonCount = 2--RebelWantedData.IsLevelUnlocked(monsterLevel) and 4 or 2
	--print(unLockLevel , RebelWantedData.GetUnlockedLevel() , monsterLevel , RebelWantedData.GetMaxLevel())
	buttonGroupList[2].transform.gameObject:SetActive(buttonCount == 2)
	buttonGroupList[4].transform.gameObject:SetActive(buttonCount == 4)

	--info
    local sweepData = CountListData.GetWorldMapMonsterSweepCount()
    local refrushData = CountListData.GetRefreshSweepMonsterCount();
	local energyCount = math.floor( MainData.GetSceneEnergy() / WorldMapMonsterOnceEnergy )
	local vipCount = sweepData and sweepData.count or 0
    local sweepCount = math.min(energyCount , vipCount)
    local totalSweepCount = sweepData.countmax
	
	buttonGroupList[buttonCount].info:Find("bg_combat/txt_num"):GetComponent("UILabel").text = GetSuggestedPower()
	local sweepTimeLabel = buttonGroupList[buttonCount].info:Find("bg/number")
	if sweepTimeLabel then
		sweepTimeLabel:GetComponent("UILabel").text = sweepCount.."/"..totalSweepCount
	end
	
	local sweepDes = buttonGroupList[buttonCount].info:Find("vip")
	if sweepDes then
		sweepDes:GetComponent("UILabel").text = System.String.Format(TextMgr:GetText("sweep_ui_5") , MainData.GetVipLevel() ,refrushData.count , refrushData.countmax )
	end 
    
    

	print(energyCount , vipCount , sweepCount)
	
    --侦察野怪
    buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.ui_worldmap_29)
    SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
        GetInterface("BeginSpy")(2,1)
    end)
    --攻击野怪
    buttonGroupList[buttonCount][2].label.text = TextMgr:GetText(Text.ui_worldmap_30)
    buttonGroupList[buttonCount][2].stamina.text = WorldMapMonsterOnceEnergy
    SetClickCallback(buttonGroupList[buttonCount][2].button.gameObject, function()
        local uid = tileMsg ~= nil and tileMsg.data.uid or 0

        -- if MainData.GetSceneEnergy() < WorldMapMonsterOnceEnergy then
        --     MessageBox.Show(TextMgr:GetText("ui_rebelenergy_1"),function()
        --         MainCityUI.ShowUseOrBuySceneEnergy()
        --     end, function() end, TextMgr:GetText("speedup_ui3"))
        --     return
        -- end

        local unlockedLevel = RebelWantedData.GetUnlockedLevel()
--[[
        if MainData.GetSceneEnergy() < WorldMapMonsterOnceEnergy then
            Global.ShowNoEnoughSceneEnergy(WorldMapMonsterOnceEnergy-MainData.GetSceneEnergy()+1);
        elseif not RebelWantedData.IsLevelUnlocked(monsterLevel) then
            MessageBox.Show(String.Format(TextMgr:GetText("RebelArmyWanted_ui2"), RebelWantedData.GetUnlockConditionForLevel(monsterLevel), unlockedLevel), function()
                RebelArmyWanted.Search(unlockedLevel)
                Hide()
            end, function() end, TextMgr:GetText("rebel_20"))
        else
--]]
            MobaBattleMove.Show(Common_pb.TeamMoveType_AttackMonster, uid, "", tileMsg ~= nil and tileMsg.data.pos.x or mapX,tileMsg ~= nil and tileMsg.data.pos.y or mapY, Hide)
--       end
    end)
    --野怪更多
   --[[ buttonGroupList[buttonCount][3].label.text = TextMgr:GetText(Text.ui_worldmap_6)
    SetClickCallback(buttonGroupList[buttonCount][3].button.gameObject, function()
        --MessageBox.Show(TextMgr:GetText(Text.common_ui1))
        --Traget_Set.Show(TextMgr:GetText(tileData.name),mapX,mapY)
        tileInfoMore:Open(buttonGroupList[buttonCount][3].button.gameObject,TextMgr:GetText(tileData.name),mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
    end)]]

	--扫荡野怪
	
    if buttonGroupList[buttonCount][3] and buttonGroupList[buttonCount][4] then
        if (sweepData and sweepData.count or 0) == 0 then
            buttonGroupList[buttonCount][4].button.gameObject:SetActive(false)
            buttonGroupList[buttonCount].info:Find("vip").gameObject:SetActive(true)
        else
            buttonGroupList[buttonCount][4].button.gameObject:SetActive(true)
            buttonGroupList[buttonCount].info:Find("vip").gameObject:SetActive(false)
        end
		buttonGroupList[buttonCount][3].label.text = System.String.Format(TextMgr:GetText("sweep_ui_4") , sweepCount)
		buttonGroupList[buttonCount][3].stamina.text = string.format("%s" , sweepCount * WorldMapMonsterOnceEnergy)
        
        SetClickCallback(buttonGroupList[buttonCount].info:Find("vip"):Find("btn_4").gameObject,function()
            local gold_list_str = TableMgr:GetGlobalData(100195).value
            local gold_list_str_array = string.split(gold_list_str,',')
            local gold_list = {}
			for i = 1,#(gold_list_str_array) do
                gold_list[i] =tonumber( gold_list_str_array[i])
            end

            local time = (refrushData.countmax - refrushData.count)+1
            local gold = time > #gold_list and gold_list[#gold_list] or gold_list[time]

            MessageBox.Show(TextMgr:GetText("sweep_ui_6"), function()
                local req = MapMsg_pb.MsgRefreshSweepMonsterRequest()
				Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgRefreshSweepMonsterRequest, req, MapMsg_pb.MsgRefreshSweepMonsterResponse, function(reqStartMsg)
					if reqStartMsg.code ~= ReturnCode_pb.Code_OK then
						Global.ShowError(reqStartMsg.code)
                    else
                        CountListData.SetCount(reqStartMsg.sweepCount)
                        CountListData.SetCount(reqStartMsg.refreshCount)
                        MainCityUI.UpdateRewardData(reqStartMsg.fresh)

                        sweepData = CountListData.GetWorldMapMonsterSweepCount()
                        refrushData = CountListData.GetRefreshSweepMonsterCount();
                        energyCount = math.floor( MainData.GetSceneEnergy() / WorldMapMonsterOnceEnergy )
                        vipCount = sweepData and sweepData.count or 0
                        sweepCount = math.min(energyCount , vipCount)
                        totalSweepCount = sweepData.countmax
                        
                        buttonGroupList[buttonCount].info:Find("bg_combat/txt_num"):GetComponent("UILabel").text = GetSuggestedPower()
                        local sweepTimeLabel = buttonGroupList[buttonCount].info:Find("bg/number")
                        if sweepTimeLabel then
                            sweepTimeLabel:GetComponent("UILabel").text = sweepCount.."/"..totalSweepCount
                        end
                        
                        local sweepDes = buttonGroupList[buttonCount].info:Find("vip")
                        if sweepDes then
                            sweepDes:GetComponent("UILabel").text = System.String.Format(TextMgr:GetText("sweep_ui_5") , MainData.GetVipLevel() ,refrushData.count , refrushData.countmax )
                        end 

                        if (sweepData and sweepData.count or 0) == 0 then
                            buttonGroupList[buttonCount][4].button.gameObject:SetActive(false)
                            buttonGroupList[buttonCount].info:Find("vip").gameObject:SetActive(true)
                        else
                            buttonGroupList[buttonCount][4].button.gameObject:SetActive(true)
                            buttonGroupList[buttonCount].info:Find("vip").gameObject:SetActive(false)
                        end
                        buttonGroupList[buttonCount][3].label.text = System.String.Format(TextMgr:GetText("sweep_ui_4") , sweepCount)
                        buttonGroupList[buttonCount][3].stamina.text = string.format("%s" , sweepCount * WorldMapMonsterOnceEnergy)
					end
				end)

                
            end, function() end, nil,nil,nil,nil,nil,System.String.Format(TextMgr:GetText("tili_ui4"),refrushData.count),gold)
        end)

		SetClickCallback(buttonGroupList[buttonCount][3].button.gameObject, function()
			local uid = tileMsg ~= nil and tileMsg.data.uid or 0
			local unlockedLevel = RebelWantedData.GetUnlockedLevel()

			print(MainData.GetSceneEnergy() ,vipCount, sweepCount * WorldMapMonsterOnceEnergy)
			if vipCount == 0 then
				FloatText.Show(TextMgr:GetText("Code_SceneMap_SweepMonsterLimit") , Color.red)
				return
			elseif MainData.GetSceneEnergy() < WorldMapMonsterOnceEnergy then
			
				Global.ShowNoEnoughSceneEnergy(WorldMapMonsterOnceEnergy-MainData.GetSceneEnergy()+1,function() Hide() end)
				return
			end
			
			
			if MainData.GetSceneEnergy() < sweepCount * WorldMapMonsterOnceEnergy then
				Global.ShowNoEnoughSceneEnergy(sweepCount * WorldMapMonsterOnceEnergy-MainData.GetSceneEnergy()+1)
			elseif not RebelWantedData.IsLevelUnlocked(monsterLevel) then
				MessageBox.Show(String.Format(TextMgr:GetText("RebelArmyWanted_ui2"), RebelWantedData.GetUnlockConditionForLevel(monsterLevel), unlockedLevel), function()
					RebelArmyWanted.Search(unlockedLevel)
					Hide()
				end, function() end, TextMgr:GetText("rebel_20"))
			else
				MobaBattleMove.Show(Common_pb.TeamMoveType_AttackMonster, uid, "", tileMsg ~= nil and tileMsg.data.pos.x or mapX,tileMsg ~= nil and tileMsg.data.pos.y or mapY, Hide ,nil, nil , nil , nil , sweepCount)
			end
		end)
		
		SetClickCallback(buttonGroupList[buttonCount][4].button.gameObject , function()
			energyCount = math.floor( MainData.GetSceneEnergy() / WorldMapMonsterOnceEnergy )
			local count = math.min(energyCount , vipCount)
			NumberInput.Show(count, 0,count, function(number)
				buttonGroupList[buttonCount].info:Find("bg/number"):GetComponent("UILabel").text = number.."/"..totalSweepCount
				sweepCount = number
				buttonGroupList[buttonCount][3].label.text = System.String.Format(TextMgr:GetText("sweep_ui_4") , sweepCount)
				buttonGroupList[buttonCount][3].stamina.text = string.format("%s" , sweepCount * WorldMapMonsterOnceEnergy)
			end , 
			function(num) 
				energyCount = math.floor( MainData.GetSceneEnergy() / WorldMapMonsterOnceEnergy )
				count = math.min(energyCount , vipCount)
				
				if num > count then
					if count == energyCount then
						FloatText.Show(TextMgr:GetText("ui_rebelenergy_1"), Color.red) 
					elseif count == vipCount then
						FloatText.Show(TextMgr:GetText("Code_SceneMap_SweepMonsterLimit"), Color.red) 
					end
				end
				
			end)
		end)
	end
	
	
    for _, v in ipairs(monsterButtonCountList) do
        buttonGroupList[v].transform.gameObject:SetActive(buttonCount == v)
        if buttonCount == v then
            local buttonGroupTransform = buttonGroupList[v].transform
            local halfHeight = buttonGroupTransform:GetComponent("UIWidget").height * 0.5
            local positionY = tileInfo.bg.transform:InverseTransformPoint(buttonGroupTransform.position).y
            tileInfo.bg.height = -positionY + halfHeight + BG_BOTTOM_PADDING 
			
			
			tileInfo.cornerLB.localPosition = Vector3(tileInfo.cornerLB.localPosition.x,positionY - halfHeight+ BG_CORNER_BOTTOM_PADDING,tileInfo.cornerLB.localPosition.z)
			tileInfo.cornerRB.localPosition = Vector3(tileInfo.cornerRB.localPosition.x,positionY - halfHeight+ BG_CORNER_BOTTOM_PADDING,tileInfo.cornerRB.localPosition.z)
        end
    end

    SetClickCallback(tileInfo.energySprite.gameObject, function(go)
        if go == _ui.tipObject then
            _ui.tipObject = nil
			tileInfo.energyTipObject:SetActive(false)
        else
            _ui.tipObject = go
            tileInfo.energyTipObject:SetActive(true)
        end
    end)
end

local function LoadRewardHero(grid ,heroPrefab, dropdata)
	local info = NGUITools.AddChild(grid.gameObject ,heroPrefab.gameObject)
	info.transform:SetParent(grid.transform , false)
	info.gameObject:SetActive(true)
	
	local heroData = TableMgr:GetHeroData(dropdata.contentId)
	local heroicon = info.transform:Find("head icon"):GetComponent("UITexture")
	heroicon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
	
	local herolv = info.transform:Find("level text"):GetComponent("UILabel")
	herolv.text = dropdata.level
	
	local herostar = info.transform:Find(System.String.Format("star/star{0}" , dropdata.star))
	herostar.gameObject:SetActive(true)
	
	local heroQuality = info.transform:Find(System.String.Format("head icon/outline{0}" , heroData.quality))
	heroQuality.gameObject:SetActive(true)
	UIUtil.SetClickCallback(info.gameObject, function(go)
        if go == _ui.tipObject then
            _ui.tipObject = nil
        else
            _ui.tipObject = go
            local heroData = TableMgr:GetHeroData(dropdata.contentId)
            Tooltip.ShowItemTip({name = TextMgr:GetText(heroData.nameLabel), text = TextMgr:GetText(heroData.description)})
        end
    end)
end

local function LoadRewardItem(grid , itemPrefab , dropdata)
	local info = NGUITools.AddChild(grid.gameObject , itemPrefab.gameObject)
	info.transform:SetParent(grid.transform , false)
	info.gameObject:SetActive(true)
	
	local itemTBData = TableMgr:GetItemData(dropdata.contentId)
	local rewardicon = info.transform:Find("item"):GetComponent("UITexture")
	rewardicon.mainTexture = ResourceLibrary:GetIcon("Item/", itemTBData.icon)
	
	local rewardnum = info.transform:Find("num"):GetComponent("UILabel")
	rewardnum.text = dropdata.contentNumber
	rewardnum.gameObject:SetActive(dropdata.contentNumber > 1)
	
	local rewardbox = info.transform:Find("btn_item"):GetComponent("UISprite")
	rewardbox.spriteName = "bg_item" .. itemTBData.quality
	
	
	local itemlvTrf = info.transform:Find("bg_num")
	local itemlv = itemlvTrf:Find("txt_num"):GetComponent("UILabel")
	itemlvTrf.gameObject:SetActive(true)
	if itemTBData.showType == 1 then
		itemlv.text = Global.ExchangeValue2(itemTBData.itemlevel)
	elseif itemTBData.showType == 2 then
		itemlv.text = Global.ExchangeValue1(itemTBData.itemlevel)
	elseif itemTBData.showType == 3 then
		itemlv.text = Global.ExchangeValue3(itemTBData.itemlevel)
	else 
		itemlvTrf.gameObject:SetActive(false)
	end
	UIUtil.SetClickCallback(info.gameObject, function(go)
        if go == _ui.tipObject then
            _ui.tipObject = nil
        else
            _ui.tipObject = go
            local itemData = TableMgr:GetItemData(dropdata.contentId)
            Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
        end
    end)
end

local function LoadSlgBuffItem(grid , itemPrefab , dropdata)
	local info = NGUITools.AddChild(grid.gameObject , itemPrefab.gameObject)
	info.transform:SetParent(grid.transform , false)
	info.gameObject:SetActive(true)
	
	local itemTBData = TableMgr:GetSlgBuffData(dropdata.contentId)
	local rewardicon = info.transform:Find("item"):GetComponent("UITexture")
	rewardicon.mainTexture = ResourceLibrary:GetIcon("Item/", itemTBData.icon)
	
	local rewardnum = info.transform:Find("num"):GetComponent("UILabel")
	rewardnum.gameObject:SetActive(false)
	
    local rewardbox = info.transform:Find("btn_item"):GetComponent("UISprite")
    rewardbox.spriteName = "bg_item1" 
	
	
    local itemlvTrf = info.transform:Find("bg_num")
    itemlvTrf.gameObject:SetActive(false)
	UIUtil.SetClickCallback(info.gameObject, function(go)
        if go == _ui.tipObject then
            _ui.tipObject = nil
        else
            _ui.tipObject = go
            local itemData = TableMgr:GetSlgBuffData(dropdata.contentId)
            Tooltip.ShowItemTip({name = TextMgr:GetText(itemData.title), text = TextMgr:GetText(itemData.description)})
        end
    end)
end

local function ShowPveFightModifyResult(myTopPower)

	local levelBaseFight = tileData.fight
	local levelFight = myTopPower > levelBaseFight * 1.5 and  (myTopPower * 0.75) or levelBaseFight
	local levelFightModify = (levelFight / levelBaseFight)
	print("topPower:"..myTopPower , "baseLevelPower:" .. levelBaseFight , "levelFightModify:" ..levelFight , "levelfightResult:" .. levelFightModify)
	
	
	local hpcoef = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PveMonsterHpCoef).value)
	local attackcoef = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PveMonsterAttackCoef).value)
	
	print("attackCoef:" .. ((levelFightModify-1)*attackcoef + 1) , "hpCoef:" .. ((levelFightModify-1)*hpcoef + 1))
end

local function SetPveMonsterInfo(tileInfo)
	tileInfo.nameLabel.text = TextMgr:GetText(tileData.name)
	--drop show
	--local dropShowList = TableMgr:GetDropShowData(tileData.dropShow)
	local listitem = ResourceLibrary.GetUIPrefab("CommonItem/list_item")
	local listhero = ResourceLibrary.GetUIPrefab("CommonItem/list_hero_small")
	
	while _ui.pveMonster.rewardGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(_ui.pveMonster.rewardGrid.transform:GetChild(0).gameObject)
	end
	
	--for i, v in pairs(dropShowList) do
	--	local dropdata = dropShowList[i]
	--	if dropdata.contentType == 1 then
	--		LoadRewardItem(_ui.pveMonster.rewardGrid , listitem , dropShowList[i])
	--	elseif dropdata.contentType == 3 then
	--		LoadRewardHero(_ui.pveMonster.rewardGrid , listhero , dropShowList[i])
	--	end
	--end
	--[[for i = 0, dropShowList.Length - 1 do
		local dropdata = dropShowList[i]
		if dropdata.contentType == 1 then
			LoadRewardItem(_ui.pveMonster.rewardGrid , listitem , dropShowList[i])
		elseif dropdata.contentType == 3 then
			LoadRewardHero(_ui.pveMonster.rewardGrid , listhero , dropShowList[i])
		end
    end]]
    
    for i=1,#tileMsg.monster.digMon.dropInfo do
        local dropdata = {}
        dropdata.contentId = tileMsg.monster.digMon.dropInfo[i].itemid
        dropdata.contentNumber = tileMsg.monster.digMon.dropInfo[i].num
        LoadRewardItem(_ui.pveMonster.rewardGrid , listitem , dropdata)
    end

	_ui.pveMonster.rewardGrid:Reposition()
	
	--btn energy add
	SetClickCallback(tileInfo.monsterChallenCount, Global.ShowNoEnoughSceneEnergy)
	local hasAttack = PveMonsterData.HasAttackPveMonster(tileMsg.data.uid)
	UIUtil.SetBtnEnable(tileInfo.btnAttack ,"btn_1", "btn_4", not hasAttack)
	_ui.pveMonster.btnAttackLab.text = hasAttack and TextMgr:GetText("PVE_Monster_ui6") or TextMgr:GetText("PVE_Monster_ui5") 
	
	local battleData = TableMgr:GetBattleData(tileData.battleId)
	local eneryCost = battleData == nil and 0 or battleData.energyCost
	local levelBaseFight = battleData.actFight
	--btnAttack
	tileInfo.stamina.text = battleData.energyCost
	SetClickCallback(tileInfo.btnAttack , function()
		if hasAttack then
			FloatText.Show(TextMgr:GetText("PVE_Monster_ui1") , Color.white)
			return
		end
		
		--先检查行动力是否足够
		print(MainData.GetSceneEnergy() , battleData.energyCost)
		if MainData.GetSceneEnergy() < battleData.energyCost then
            Global.ShowNoEnoughSceneEnergy(battleData.energyCost-MainData.GetSceneEnergy()+1)
            return
        end
		
	
		
		SelectArmy.SetAttackCallback(function(battleId, _teamType , levelFight)
			MessageBox.Show(System.String.Format(TextMgr:GetText("PVE_Monster_ui2"), eneryCost), function()
				if TeamData.GetSelectedArmyCount(_teamType) == 0 then
					local noSelectText = TextMgr:GetText(Text.selectunit_hint112)
					FloatText.Show(noSelectText, Color.red)
					return
				end
				
				--local levelBaseFight = tileData.fight
				local levelFinalFight = (levelFight / levelBaseFight)
				print(levelFight , levelFinalFight)
				
				--进入关卡时请求战斗
				local req = BattleMsg_pb.MsgBattleMapDigTreasureStartRequest()
				req.monsterSeUid = tileMsg.data.uid
				req.monsterBaseId = tileMsg.monster.digMon.monsterBaseId
				Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgBattleMapDigTreasureStartRequest, req, BattleMsg_pb.MsgBattleMapDigTreasureStartResponse, function(reqStartMsg)
					if reqStartMsg.code ~= ReturnCode_pb.Code_OK then
						Global.ShowError(reqStartMsg.code)
					else
						Global.SetMenuBackState("WorldMap" , nil ,tileMsg.data.pos.x , tileMsg.data.pos.y )
						RebelArmy.PveMonsterStartBattle(reqStartMsg , levelFinalFight , tileMsg.data.uid)
					end
				end)
			end, function() end)
		end)
			
		--进入选将军界面时请求关卡战力调整系数
		local req = BattleMsg_pb.MsgBattleMapDigTreasureBattleCoefRequest()
		req.seuid = tileMsg.data.uid
		Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgBattleMapDigTreasureBattleCoefRequest, req, BattleMsg_pb.MsgBattleMapDigTreasureBattleCoefResponse, function(reqStartMsg)
			if reqStartMsg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(reqStartMsg.code)
			else
				print("请求到的战力关卡调整系数X为：" .. reqStartMsg.coef .. " 关卡战力为： " .. math.floor(reqStartMsg.coef * levelBaseFight))
				SelectHero.Show(Common_pb.BattleTeamType_Main,false ,{isPveMonsterBattle = true , pveMonsterLevelBaseFight = math.floor(reqStartMsg.coef * levelBaseFight)})
			end
		end)
	end)
	--btnMore
	SetClickCallback(tileInfo.btnMore, function()
        tileInfoMore:Open(tileInfo.btnMore,TextMgr:GetText(tileData.name),mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
    end)
end


local function SetRebelInfo(tileInfo)
    local monsterMsg = tileMsg.monster
    tileInfo.nameLabel.text = TextMgr:GetText(tileData.name)
    tileInfo.help.gameObject:SetActive(MapHelp.CheckHelp(tileGid))
    local dropId = tileData.killAwardShow
    RebelArmyWanted.LoadRewardList(_ui, tileInfo.rewardGrid.transform, dropId)
    SetClickCallback(tileInfo.help.gameObject, function()
        MapHelp.OpenMulti(300)
    end)
    tileInfo.finderLabel.text = (System.String.IsNullOrEmpty(monsterMsg.actMonster.finderGuildBanner) and "" or "[" .. monsterMsg.actMonster.finderGuildBanner .. "]") .. monsterMsg.actMonster.finderName
    SetClickCallback(tileInfo.energyAddBtn, Global.ShowNoEnoughSceneEnergy)

    local hpPercentage = GetHpPercentage()
    tileInfo.hpBar.value = hpPercentage
    tileInfo.hpPercentage.text = string.format("%d%%", math.floor(hpPercentage * 100))

    tileInfo.suggestPower.text = GetSuggestedPower()

    --侦察活动野怪
    SetClickCallback(tileInfo.reconBtn, function()
        GetInterface("BeginSpy")(2,1)
    end)
    --攻击活动野怪
    local stamina
    if monsterMsg.actMonster.finder == MobaMainData.GetCharId()   then
        stamina = RebelData.GetActivityInfo().actSta
    elseif monsterMsg.actMonster.finderGuildId == MobaMainData.GetTeamID() then
        stamina = RebelData.GetActivityInfo().unionSta
    else
        stamina = RebelData.GetActivityInfo().actSta
    end
    tileInfo.actStamina.text = stamina
    SetClickCallback(tileInfo.actBtn, function()
        local sta
        if monsterMsg.actMonster.finder == MobaMainData.GetCharId()   then
            sta = RebelData.GetActivityInfo().actSta
        elseif monsterMsg.actMonster.finderGuildId == MobaMainData.GetTeamID() then
            sta = RebelData.GetActivityInfo().unionSta
        else
            sta = RebelData.GetActivityInfo().actSta
        end
        local uid = tileMsg ~= nil and tileMsg.data.uid or 0
        if MainData.GetSceneEnergy() < sta then
            Global.ShowNoEnoughSceneEnergy(sta -MainData.GetSceneEnergy() +1 )
            return
        end
        MobaBattleMove.Show(Common_pb.TeamMoveType_AttackMonster, uid, "", tileMsg ~= nil and tileMsg.data.pos.x or mapX,tileMsg ~= nil and tileMsg.data.pos.y or mapY, Hide)
    end)
    --集结活动野怪
    tileInfo.massStamina.text = RebelData.GetActivityInfo().massSta
    SetClickCallback(tileInfo.massBtn, function()
        if MainData.GetSceneEnergy() < RebelData.GetActivityInfo().massSta then
            Global.ShowNoEnoughSceneEnergy(RebelData.GetActivityInfo().massSta-MainData.GetSceneEnergy()+1)
            return
        end
        local uid = tileMsg ~= nil and tileMsg.data.uid or 0
        local mtc = MassTroopsCondition()
        local x = mapX
        local y = mapY
        mtc.target_enable_mass =  true
        mtc.isActMonster = true
        mtc:MobaCreateMass4BattleCondition(function(success)
            if success then
                assembled_time.Show(function(time)
                    if time ~= 0 then
                        local building = maincity.GetBuildingByID(43)  
                        if building ~= nil then
                            local curAssembledData = TableMgr:GetAssembledData(building.data.level)
                            mtc:MobaShowCreateMassBattleMove(uid, TextMgr:GetText(tileData.name), x, y,curAssembledData.armynum,time)
                        end                           
                    end
                end, true)
            end
        end)   
    end)
    --活动野怪更多
    SetClickCallback(tileInfo.moreBtn, function()
        --MessageBox.Show(TextMgr:GetText(Text.common_ui1))
        --Traget_Set.Show(TextMgr:GetText(tileData.name),mapX,mapY)
        tileInfoMore:Open(tileInfo.moreBtn,TextMgr:GetText(tileData.name),mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
    end)
    SetClickCallback(tileInfo.energySprite.gameObject, function(go)
        if go == _ui.tipObject then
            _ui.tipObject = nil
        else
            _ui.tipObject = go
            tileInfo.energyTipObject:SetActive(true)
        end
    end)
end

local function SetGuildMonsterInfo(tileInfo , showGate , showMonster)
    local monsterMsg = tileMsg.monster
	local radarMonsterState1 = UnionRadarData.GetGuildMonsterGateHp()
	local radarMonsterState2 = UnionRadarData.GetGuildMonsterGateDestroy()
	local radarMsg = UnionRadarData.GetData()
	local buttonCount = 2
	
	local unionMonsterData = TableMgr:GetUnionMonsterData(monsterMsg.level)
	transform:Find("RebelBase/bg_info/bg_2btn").gameObject:SetActive(true)
	_ui.guildMonster.nameLabel.text = TextMgr:GetText(tileData.name)
	

	if showGate then
		_ui.guildMonster.infobgTitle1.text = TextMgr:GetText("Union_Radar_ui14")
		_ui.guildMonster.infobgTitle2.text = TextMgr:GetText("Union_Radar_ui21")
		_ui.guildMonster.infobg1.text = radarMonsterState1 == nil and "--/--" or radarMonsterState1.hp .. "/" .. unionMonsterData.hp
		_ui.guildMonster.infobg2.text = radarMsg == nil and "--/--" or radarMsg.battleCount.countmax - radarMsg.battleCount.count .. "/" .. radarMsg.battleCount.countmax
	elseif showMonster then
		_ui.guildMonster.infobgTitle1.text = TextMgr:GetText("Union_Radar_ui15")
		_ui.guildMonster.infobgTitle2.text = TextMgr:GetText("Union_Radar_ui22")
		_ui.guildMonster.infobg1.text = unionMonsterData.fight
		_ui.guildMonster.infobg2.text = radarMsg == nil and "--/--" or (radarMsg.pvpCount.countmax - radarMsg.pvpCount.count) .. "/" .. radarMsg.pvpCount.countmax
		buttonCount = 4
	end
	_ui.guildMonster.coordLabel.text = radarMonsterState1 == nil and "--,--" or radarMonsterState1.pos.x .. " , " .. radarMonsterState1.pos.y
	--print("guildbanner:" .. monsterMsg.actMonster.finderGuildBanner .. " finder:" .. monsterMsg.actMonster.finderName)
	_ui.guildMonster.guildname.text = (System.String.IsNullOrEmpty(tileMsg.ownerguild.guildbanner) and "" or "[" .. tileMsg.ownerguild.guildbanner .. "]") .. tileMsg.ownerguild.guildname

    -- _ui.guildMonster.icon = transform:Find("RebelBase/bg_info/bg_build/icon_castle"):GetComponent("UITexture")
    _ui.guildMonster.level.text = monsterMsg.level

    _ui.guildMonster.bg2Btn:SetActive(showGate)
    _ui.guildMonster.bg4Btn:SetActive(showMonster)

    --城门阶段
    SetClickCallback(tileInfo.level1_attack , function()

        print("attack:" .. tileMsg.monster.level)
        if radarMsg.battleCount.count >= radarMsg.battleCount.countmax then
            FloatText.Show(TextMgr:GetText("Union_Radar_ui42") , Color.white)
            return
        end

        local req = BattleMsg_pb.MsgBattleGuildMonsterStartRequest()
		--req.id = tileMsg.monster.level
		req.id = tileMsg.ownerguild.guildid
		Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgBattleGuildMonsterStartRequest, req, BattleMsg_pb.MsgBattleGuildMonsterStartResponse, function(reqStartMsg)
			if reqStartMsg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(reqStartMsg.code)
			else
				Hide()
				local params = {backPosx = radarMonsterState1.pos.x ; backPosy = radarMonsterState1.pos.y}
				RebelArmy.Show(reqStartMsg , params)
			end
		end)
	end)
	
	SetClickCallback(tileInfo.level1_more , function()
		print("more")
		tileInfoMore:Open(tileInfo.level1_more,TextMgr:GetText(tileData.name),mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
	end)
	
	
	--活动野怪阶段
	 SetClickCallback(tileInfo.reconBtn, function()
        GetInterface("BeginSpy")(2,1)
    end)
    --攻击活动野怪
    SetClickCallback(tileInfo.actBtn, function()
		--攻打时间限制
		if radarMonsterState2 ~= nil then
			local leftStarTimeSec = radarMonsterState2.pvpStartTime - Serclimax.GameTime.GetSecTime()
			if leftStarTimeSec > 0 then
				FloatText.Show(TextMgr:GetText("Union_Radar_ui47"), Color.white)
				return
			end
		end
	
		--攻打次数限制
		if radarMsg.pvpCount.count >= radarMsg.pvpCount.countmax then
			FloatText.Show(TextMgr:GetText("Union_Radar_ui42") , Color.white)
			return
		end
	
    	local sta
    	if monsterMsg.actMonster.finder == MobaMainData.GetCharId()   then
    		sta = RebelData.GetActivityInfo().actSta
    	elseif monsterMsg.actMonster.finderGuildId == MobaMainData.GetTeamID() then
    		sta = RebelData.GetActivityInfo().unionSta
    	else
    		sta = RebelData.GetActivityInfo().actSta
    	end
        local uid = tileMsg ~= nil and tileMsg.data.uid or 0
        if MainData.GetSceneEnergy() < sta then
            Global.ShowNoEnoughSceneEnergy(sta-MainData.GetSceneEnergy()+1)
            return
        end
        MobaBattleMove.Show(Common_pb.TeamMoveType_AttackMonster, uid, "", tileMsg ~= nil and tileMsg.data.pos.x or mapX,tileMsg ~= nil and tileMsg.data.pos.y or mapY, Hide)
    end)
    --集结活动野怪
    SetClickCallback(tileInfo.massBtn, function()
		if radarMonsterState2 ~= nil then
			local leftStarTimeSec = radarMonsterState2.pvpStartTime - Serclimax.GameTime.GetSecTime()
			if leftStarTimeSec > 0 then
				FloatText.Show(TextMgr:GetText("Union_Radar_ui47")  , Color.white)
				return
			end
		end
		if radarMsg.pvpCount.count >= radarMsg.pvpCount.countmax then
			FloatText.Show(TextMgr:GetText("Union_Radar_ui42") , Color.white)
			return
		end
		
    	if MainData.GetSceneEnergy() < RebelData.GetActivityInfo().massSta then
        	Global.ShowNoEnoughSceneEnergy(RebelData.GetActivityInfo().massSta-MainData.GetSceneEnergy())
        	return
        end
        local uid = tileMsg ~= nil and tileMsg.data.uid or 0
        local mtc = MassTroopsCondition()
        local x = mapX
        local y = mapY
        mtc.target_enable_mass =  true
        mtc.isActMonster = true
        mtc:MobaCreateMass4BattleCondition(function(success)
            if success then
                assembled_time.Show(function(time)
                    if time ~= 0 then
                        local building = maincity.GetBuildingByID(43)  
                        if building ~= nil then
                            local curAssembledData = TableMgr:GetAssembledData(building.data.level)
                            mtc:MobaShowCreateMassBattleMove(uid, TextMgr:GetText(tileData.name), x, y,curAssembledData.armynum,time)
                        end                           
                    end
                end, true)
            end
        end)   
    end)
    --活动野怪更多
    SetClickCallback(tileInfo.moreBtn, function()
        --MessageBox.Show(TextMgr:GetText(Text.common_ui1))
        --Traget_Set.Show(TextMgr:GetText(tileData.name),mapX,mapY)
        tileInfoMore:Open(tileInfo.moreBtn,TextMgr:GetText(tileData.name),mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
    end)

	
	local buttonGroupList = _ui.guildMonster.buttonGroupList
	for _, v in ipairs(unionMonsterButtonCountList) do
        --buttonGroupList[v].transform.gameObject:SetActive(buttonCount == v)
        if buttonCount == v then
		print("-----")
            local buttonGroupTransform = buttonGroupList[v].transform
            local halfHeight = buttonGroupTransform:GetComponent("UIWidget").height * 0.5
            local positionY = tileInfo.bg.transform:InverseTransformPoint(buttonGroupTransform.position).y
			print(halfHeight , tileInfo.bg.height)
            tileInfo.bg.height = -positionY + halfHeight + BG_BOTTOM_PADDING 
        end
    end
end

local function SetResourceInfo(tileInfo)
    tileInfo.levelBg.gameObject:SetActive(true)
    tileInfo.help.gameObject:SetActive(MapHelp.CheckHelp(tileGid))
    SetClickCallback(tileInfo.help.gameObject, function() 
        MapHelp.OpenMulti(MapHelp.ResGid(tileGid))
    end)
    tileInfo.nameLabel.text = TextMgr:GetText(tileData.name)
    local resMsg = tileMsg.res
    local guildMsg = tileMsg.ownerguild
    local charId = MobaMainData.GetCharId()  
    local selfGuildId = MobaMainData.GetTeamID()

    tileInfo.levelLabel.text = resMsg.level
    local owner = resMsg.owner
    local infoList = tileInfo.infoList
    local buttonGroupList = tileInfo.buttonGroupList
    local buttonCount = 0
    if owner == 0 then
        tileInfo.bg.spriteName = "common_bg"
        buttonCount = 2
        infoList[1].nameLabel.text = TextMgr:GetText(Text.ui_worldmap_40)
        local capacity = tileData.capacity
        local resourceLeftCount = capacity - resMsg.num
        infoList[1].valueLabel.text = resourceLeftCount

        infoList[2].nameLabel.text = TextMgr:GetText(Text.ui_worldmap_41)
        if resMsg.lastowner == 0 then
            infoList[2].valueLabel.text = TextMgr:GetText(Text.ui_worldmap_45)
        else
            if guildMsg.guildid == 0 then
                infoList[2].valueLabel.text = resMsg.lastownername
            else
                infoList[2].valueLabel.text = string.format("[%s]%s", guildMsg.guildbanner, resMsg.lastownername)
            end
        end

        infoList[3].transform.gameObject:SetActive(false)

        --采集无人资源
        buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.ui_worldmap_46)
        SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
            local baseLevel = BuildingData.GetCommandCenterData().level
            if baseLevel < tileData.baseLevel then
                local text = TextMgr:GetText(Text.chat_hint2)
                MessageBox.Show(String.Format(text, tileData.baseLevel))
            else
                local uid = tileMsg ~= nil and tileMsg.data.uid or 0
                MobaBattleMove.Show(Common_pb.TeamMoveType_ResTake, uid, "", tileMsg ~= nil and tileMsg.data.pos.x or mapX,tileMsg ~= nil and tileMsg.data.pos.y or mapY, Hide)
            end
        end)
        --无人资源更多
        buttonGroupList[buttonCount][2].label.text = TextMgr:GetText(Text.ui_worldmap_29)
        SetClickCallback(buttonGroupList[buttonCount][2].button.gameObject, function()
            --MessageBox.Show(TextMgr:GetText(Text.common_ui1))
            --Traget_Set.Show(TextMgr:GetText(tileData.name),mapX,mapY)
            tileInfoMore:Open(buttonGroupList[buttonCount][2].button.gameObject,TextMgr:GetText(tileData.name),mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
        end)

    elseif owner == charId then
        tileInfo.bg.spriteName = "common_bg"
        buttonCount = 2
        infoList[1].nameLabel.text = TextMgr:GetText(Text.ui_worldmap_40)

        infoList[2].nameLabel.text = TextMgr:GetText(Text.ui_worldmap_44)

        infoList[3].transform.gameObject:SetActive(true)

        --自己采集的资源撤军
        buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.ui_worldmap_38)
        SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
            local req = MapMsg_pb.CancelPathRequest()
            req.taruid = tileMsg.data.uid
            Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.CancelPathRequest, req, MapMsg_pb.CancelPathResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    Hide()
                else
                    Global.ShowError(msg.code)
                end
            end, true)
        end)
        --自己采集的资源更多
        buttonGroupList[buttonCount][2].label.text = TextMgr:GetText(Text.ui_worldmap_29)
        SetClickCallback(buttonGroupList[buttonCount][2].button.gameObject, function()
            tileInfoMore:Open(buttonGroupList[buttonCount][2].button.gameObject,TextMgr:GetText(tileData.name),mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
        end)
    elseif selfGuildId ~= 0 and selfGuildId == guildMsg.guildid then
        tileInfo.bg.spriteName = "common_bg"
        buttonCount = 1

        infoList[1].nameLabel.text = TextMgr:GetText(Text.ui_worldmap_40)

        infoList[2].nameLabel.text = TextMgr:GetText(Text.ui_worldmap_62)
        if guildMsg.guildid == 0 then
            infoList[2].valueLabel.text = resMsg.ownername
        else
            infoList[2].valueLabel.text = string.format("[%s]%s", guildMsg.guildbanner, resMsg.ownername)
        end

        infoList[3].transform.gameObject:SetActive(false)

        --盟友采集的资源更多
        buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.ui_worldmap_29)
        SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
            --MessageBox.Show(TextMgr:GetText(Text.common_ui1))
            --Traget_Set.Show(TextMgr:GetText(tileData.name),mapX,mapY)
            tileInfoMore:Open(buttonGroupList[buttonCount][1].button.gameObject,TextMgr:GetText(tileData.name),mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
        end)
    else
        tileInfo.bg.spriteName = "common_bg"
        buttonCount = 3

        infoList[1].nameLabel.text = TextMgr:GetText(Text.ui_worldmap_40)

        infoList[2].nameLabel.text = TextMgr:GetText(Text.ui_worldmap_62)
        if guildMsg.guildid == 0 then
            infoList[2].valueLabel.text = resMsg.ownername
        else
            infoList[2].valueLabel.text = string.format("[%s]%s", guildMsg.guildbanner, resMsg.ownername)
        end

        infoList[3].transform.gameObject:SetActive(false)

        --侦查敌人采集的资源
        buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.ui_worldmap_29)
        SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
            GetInterface("BeginSpy")(1, tonumber(tileMsg.res.ownerhomelvl))
        end)
        --攻击敌人采集的资源
        buttonGroupList[buttonCount][2].label.text = TextMgr:GetText(Text.ui_worldmap_30)
        SetClickCallback(buttonGroupList[buttonCount][2].button.gameObject, function()
            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            MobaBattleMove.Show(Common_pb.TeamMoveType_ResTake, uid, "", tileMsg ~= nil and tileMsg.data.pos.x or mapX,tileMsg ~= nil and tileMsg.data.pos.y or mapY, Hide)
        end)
        --敌人采集的资源更多
        buttonGroupList[buttonCount][3].label.text = TextMgr:GetText(Text.ui_worldmap_29)
        SetClickCallback(buttonGroupList[buttonCount][3].button.gameObject, function()
            -- MessageBox.Show(TextMgr:GetText(Text.common_ui1))
            --Traget_Set.Show(TextMgr:GetText(tileData.name),mapX,mapY) 
            tileInfoMore:Open(buttonGroupList[buttonCount][3].button.gameObject,TextMgr:GetText(tileData.name),mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
        end)
    end

    if owner == 0 or guildMsg.guildid == 0 then
        tileInfo.unionLabel.text = TextMgr:GetText(Text.union_nounion)
    else
        tileInfo.unionLabel.text = string.format("[%s]%s", guildMsg.guildbanner, guildMsg.guildname)
    end

    for _, v in ipairs(resourceButtonCountList) do
        buttonGroupList[v].transform.gameObject:SetActive(buttonCount == v)
        if buttonCount == v then
            local buttonGroupTransform = buttonGroupList[v].transform
            local halfHeight = buttonGroupTransform:GetComponent("UIWidget").height * 0.5
            local positionY = tileInfo.bg.transform:InverseTransformPoint(buttonGroupTransform.position).y
            tileInfo.bg.height = -positionY + halfHeight + BG_BOTTOM_PADDING 
        end
    end
end

local function SetBarrackInfo(tileInfo)
    tileInfo.wanted.gameObject:SetActive(false)
    local buttonGroupList = tileInfo.buttonGroupList
    local buttonCount = 0
    local entryType = tileMsg.data.entryType
    local barrackMsg = entryType == Common_pb.SceneEntryType_Barrack and tileMsg.barrack or tileMsg.occupy
    local barrackName = entryType == Common_pb.SceneEntryType_Barrack and barrackMsg.name or barrackMsg.ownername
    local guildMsg = tileMsg.ownerguild
    local charId = MobaMainData.GetCharId()  
    local selfGuildId = MobaMainData.GetTeamID()
    local owner = barrackMsg.owner
    local infoList = tileInfo.infoList

    infoList[1].transform.gameObject:SetActive(entryType == Common_pb.SceneEntryType_Occupy)

    if owner == charId then
        tileInfo.bg.spriteName = "common_bg"
        buttonCount = 2

        --自己兵营撤军
        buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.ui_worldmap_38)
        SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
            local req = MapMsg_pb.CancelPathRequest()
            req.taruid = tileMsg.data.uid
            Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.CancelPathRequest, req, MapMsg_pb.CancelPathResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    Hide()
                else
                    Global.ShowError(msg.code)
                end
            end, true)
        end)
        --自己兵营更多
        buttonGroupList[buttonCount][2].label.text = TextMgr:GetText(Text.ui_worldmap_29)
        SetClickCallback(buttonGroupList[buttonCount][2].button.gameObject, function()
            --MessageBox.Show(TextMgr:GetText(Text.common_ui1))
            --Traget_Set.Show(barrackMsg.name,mapX,mapY)
            tileInfoMore:Open(buttonGroupList[buttonCount][2].button.gameObject,barrackName,mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
        end)
    elseif selfGuildId ~= 0 and selfGuildId == guildMsg.guildid then
        tileInfo.bg.spriteName = "common_bg"
        buttonCount = 1
        --盟友兵营更多
        buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.ui_worldmap_30)
        SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
            --MessageBox.Show(TextMgr:GetText(Text.common_ui1))
            --Traget_Set.Show(barrackMsg.name,mapX,mapY)
            tileInfoMore:Open(buttonGroupList[buttonCount][1].button.gameObject,barrackName,mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
        end)
    else
        tileInfo.bg.spriteName = "common_bg"
        tileInfo.help.gameObject:SetActive(MapHelp.CheckHelp(tileGid))
        SetClickCallback(tileInfo.help.gameObject, function() 
            MapHelp.OpenMulti(600)
        end)
        MapHelp.Open(600, false, nil, true)
        buttonCount = 3
        --侦查敌人兵营
        buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.ui_worldmap_29)
        SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
            GetInterface("BeginSpy")(1, tonumber(barrackMsg.homelvl))
        end)
        --攻击敌人兵营
        buttonGroupList[buttonCount][2].label.text = TextMgr:GetText(Text.ui_worldmap_30)
        SetClickCallback(buttonGroupList[buttonCount][2].button.gameObject, function()
            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            local moveType = entryType ==  Common_pb.SceneEntryType_Barrack and Common_pb.TeamMoveType_Camp or Common_pb.TeamMoveType_Occupy
            MobaBattleMove.Show(moveType, uid, "", tileMsg ~= nil and tileMsg.data.pos.x or mapX,tileMsg ~= nil and tileMsg.data.pos.y or mapY, Hide)
        end)
        --敌人兵营更多
        buttonGroupList[buttonCount][3].label.text = TextMgr:GetText(Text.ui_worldmap_30)
        SetClickCallback(buttonGroupList[buttonCount][3].button.gameObject, function()
            --MessageBox.Show(TextMgr:GetText(Text.common_ui1))

            --Traget_Set.Show(barrackMsg.name,mapX,mapY)
            tileInfoMore:Open(buttonGroupList[buttonCount][3].button.gameObject,barrackName,mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
        end)
    end

    tileInfo.levelBg.gameObject:SetActive(true)
    tileInfo.levelLabel.text = barrackMsg.homelvl
    tileInfo.nameLabel.text = barrackName 
    tileInfo.powerLabel.text = barrackMsg.pkvalue

    if owner == 0 or guildMsg.guildid == 0 then
        tileInfo.unionLabel.text = TextMgr:GetText(Text.union_nounion)
    else
        tileInfo.unionLabel.text = string.format("[%s]%s", guildMsg.guildbanner, guildMsg.guildname)
    end

    for _, v in ipairs(playerButtonCountList) do
        buttonGroupList[v].transform.gameObject:SetActive(buttonCount == v)
        if buttonCount == v then
            local buttonGroupTransform = buttonGroupList[v].transform
            local halfHeight = buttonGroupTransform:GetComponent("UIWidget").height * 0.5
            local positionY = tileInfo.bg.transform:InverseTransformPoint(buttonGroupTransform.position).y
            tileInfo.bg.height = -positionY + halfHeight + BG_BOTTOM_PADDING 
        end
    end
end

local function SetUnionBuildingInfo(tileInfo)
    local infoList = tileInfo.infoList
    local infoCount = 0
    local buttonGroupList = tileInfo.buttonGroupList
    local buttonCount = 0
    local buildingMsg = tileMsg.guildbuild
    local buildingData = TableMgr:GetUnionBuildingData(buildingMsg.baseid)
    local guildMsg = tileMsg.ownerguild
    local selfGuildId = MobaMainData.GetTeamID()
    local charId = MobaMainData.GetCharId()  
    local buildingType = buildingData.type

    --同联盟联盟矿
    if selfGuildId == guildMsg.guildid then
        tileInfo.bg.spriteName = "common_bg"
        --联盟仓库
        if buildingType == MapMsg_pb.GuildBuildTypeWareHouse then
            --联盟科研中心
        elseif buildingType == MapMsg_pb.GuildBuildTypeTechHouse then
            buttonCount = 2
            --己方联盟科技心捐献
            buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.union_tec4)
            SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
                UnionTec.Show()
            end)
            --己方联盟科技中心更多
            buttonGroupList[buttonCount][2].label.text = TextMgr:GetText(Text.ui_worldmap_29)
            SetClickCallback(buttonGroupList[buttonCount][2].button.gameObject, function()
                local name = string.format("[%s]%s", guildMsg.guildbanner, TextMgr:GetText(buildingData.name))
                tileInfoMore:Open(buttonGroupList[buttonCount][2].button.gameObject,name,mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
            end)
            --联盟超级矿
        elseif buildingType == MapMsg_pb.GuildBuildTypeGuildMine then
            --自己参与的
            if buildingMsg.hasSelfArmy and buildingMsg.selfSpeed > 0 then
                buttonCount = 3
                --联盟矿采集阶段
                if buildingMsg.isCompleted then
                    infoList[1].nameLabel.text = TextMgr:GetText(Text.ui_worldmap_40)
                    infoList[2].nameLabel.text = TextMgr:GetText(Text.ui_worldmap_44)
                    infoList[3].nameLabel.text = TextMgr:GetText(Text.collectnew_time)
                    infoCount = 3
                    --联盟矿建造阶段
                else
                    infoList[1].nameLabel.text = TextMgr:GetText(Text.union_ore4)
                    if not buildingMsg.countdown then
                        local timeText = Global.GetLeftCooldownTextLong(buildingMsg.completetime)
                        if buildingData.enableEnergyPerSec > 0 then
                            infoList[1].valueLabel.text = Global.SecondToTimeLong(math.ceil((buildingData.progressBar - buildingMsg.curCreatePro) / buildingData.enableEnergyPerSec))
                        else
                            infoList[1].valueLabel.text = 0
                        end
                    end
                    infoCount = 1
                end
                --己方联盟超级矿进入
                buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.union_ore13)
                SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
                    UnionBuildingData.RequestData(function()
                        local unionBuildingMsg = UnionBuildingData.GetDataByUid(tileMsg.data.uid)
                        Hide()
                        if unionBuildingMsg ~= nil then
                            UnionSuperOre.Show(buildingData.id)
                        end
                    end)
                end)
                --己方联盟超级矿矿撤军
                buttonGroupList[buttonCount][2].label.text = TextMgr:GetText(Text.ui_worldmap_38)
                SetClickCallback(buttonGroupList[buttonCount][2].button.gameObject, function()
                    local req = MapMsg_pb.CancelPathRequest()
                    req.taruid = tileMsg.data.uid
                    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.CancelPathRequest, req, MapMsg_pb.CancelPathResponse, function(msg)
                        if msg.code == ReturnCode_pb.Code_OK then
                            Hide()
                        else
                            Global.ShowError(msg.code)
                        end
                    end, true)
                end)
                --己方联盟超级矿更多
                buttonGroupList[buttonCount][3].label.text = TextMgr:GetText(Text.ui_worldmap_29)
                SetClickCallback(buttonGroupList[buttonCount][3].button.gameObject, function()
                    local name = string.format("[%s]%s", guildMsg.guildbanner, TextMgr:GetText(buildingData.name))
                    tileInfoMore:Open(buttonGroupList[buttonCount][3].button.gameObject,name,mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
                end)
                --自己未参与的
            else
                --联盟矿采集阶段
                if buildingMsg.isCompleted then
                    infoList[1].nameLabel.text = TextMgr:GetText(Text.ui_worldmap_40)
                    infoList[3].nameLabel.text = TextMgr:GetText(Text.collectnew_time)
                    --联盟矿建造阶段
                else
                    infoList[1].nameLabel.text = TextMgr:GetText(Text.union_ore4)
                    if not buildingMsg.countdown then
                        local timeText = Global.GetLeftCooldownTextLong(buildingMsg.completetime)
                        if buildingData.enableEnergyPerSec > 0 then
                            infoList[1].valueLabel.text = Global.SecondToTimeLong(math.ceil((buildingData.progressBar - buildingMsg.curCreatePro) / buildingData.enableEnergyPerSec))
                        else
                            infoList[1].valueLabel.text = 0
                        end
                    end
                end
                infoCount = 1
                buttonCount = 2
                --己方联盟超级矿进入
                buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.union_ore13)
                SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
                    local tileMsg = tileMsg
                    UnionBuildingData.RequestData(function()
                        local unionBuildingMsg = UnionBuildingData.GetDataByUid(tileMsg.data.uid)
                        Hide()
                        if unionBuildingMsg ~= nil then
                            UnionSuperOre.Show(buildingData.id)
                        end
                    end)
                end)
                --己方联盟超级矿更多
                buttonGroupList[buttonCount][2].label.text = TextMgr:GetText(Text.ui_worldmap_29)
                SetClickCallback(buttonGroupList[buttonCount][2].button.gameObject, function()
                    local name = string.format("[%s]%s", guildMsg.guildbanner, TextMgr:GetText(buildingData.name))
                    tileInfoMore:Open(buttonGroupList[buttonCount][2].button.gameObject,name,mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
                end)
            end
            --己方联盟训练场
        elseif buildingType == MapMsg_pb.GuildBuildTypeTrainHouse then
            tileInfo.bg.spriteName = "common_bg"
            infoCount = 0
            buttonCount = 2
            --自己参与的
            if buildingMsg.hasSelfArmy then
                --己方联盟训练场查看
                buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.rebel_16)
                SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
                    Hide()
                    UnionTrain.Show(buildingData.id)
                end)
                --自己未参与的
            else
                --己方联盟训练场演习
                buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.union_train3)
                SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
                    MobaBattleMove.Show(Common_pb.TeamMoveType_TrainField, tileMsg.data.uid, "", tileMsg ~= nil and tileMsg.data.pos.x or mapX,tileMsg ~= nil and tileMsg.data.pos.y or mapY, Hide)
                end)
            end
            --己方联盟训练场更多
            buttonGroupList[buttonCount][2].label.text = TextMgr:GetText(Text.ui_worldmap_29)
            SetClickCallback(buttonGroupList[buttonCount][2].button.gameObject, function()
                local name = string.format("[%s]%s", guildMsg.guildbanner, TextMgr:GetText(buildingData.name))
                tileInfoMore:Open(buttonGroupList[buttonCount][2].button.gameObject,name,mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
            end)
            --联盟雷达
        elseif buildingType == MapMsg_pb.GuildBuildTypeRadar then
            buttonCount = 2
            buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.union_ore13)
            SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
				Hide()
                UnionRadar.Show()
            end)
            buttonGroupList[buttonCount][2].label.text = TextMgr:GetText(Text.ui_worldmap_29)
            SetClickCallback(buttonGroupList[buttonCount][2].button.gameObject, function()
                local name = string.format("[%s]%s", guildMsg.guildbanner, TextMgr:GetText(buildingData.name))
                tileInfoMore:Open(buttonGroupList[buttonCount][2].button.gameObject,name,mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
            end)
        end
    else
        tileInfo.bg.spriteName = "common_bg"
        --联盟仓库
        if buildingType == MapMsg_pb.GuildBuildTypeWareHouse then
            --联盟科研中心
        elseif buildingType == MapMsg_pb.GuildBuildTypeTechHouse then
            buttonCount = 1
            --敌方联盟科技中心更多
            buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.ui_worldmap_29)
            SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
                local name = string.format("[%s]%s", guildMsg.guildbanner, TextMgr:GetText(buildingData.name))
                tileInfoMore:Open(buttonGroupList[buttonCount][1].button.gameObject,name,mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
            end)
            --联盟超级矿
        elseif buildingType == MapMsg_pb.GuildBuildTypeGuildMine then
            buttonCount = 1
            --敌方超级矿中心更多
            buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.ui_worldmap_29)
            SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
                local name = string.format("[%s]%s", guildMsg.guildbanner, TextMgr:GetText(buildingData.name))
                tileInfoMore:Open(buttonGroupList[buttonCount][1].button.gameObject,name,mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
            end)
            --联盟矿采集阶段
            if buildingMsg.isCompleted then
                infoList[1].nameLabel.text = TextMgr:GetText(Text.ui_worldmap_40)
                infoList[2].nameLabel.text = TextMgr:GetText(Text.ui_worldmap_42)
                infoCount = 2
                --联盟矿建造阶段
            else
                infoList[1].nameLabel.gameObject:SetActive(false)
                infoList[1].valueLabel.gameObject:SetActive(false)
                infoList[1].stateLabel.text = TextMgr:GetText(Text.union_ore8)
                infoList[1].stateLabel.gameObject:SetActive(true)
                infoCount = 1
            end
            --敌方联盟训练场
        elseif buildingType == MapMsg_pb.GuildBuildTypeTrainHouse then
            infoCount = 0
            buttonCount = 1
            --敌方联盟训练场更多
            buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.ui_worldmap_29)
            SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
                local name = string.format("[%s]%s", guildMsg.guildbanner, TextMgr:GetText(buildingData.name))
                tileInfoMore:Open(buttonGroupList[buttonCount][1].button.gameObject,name,mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
            end)
		elseif buildingType == MapMsg_pb.GuildBuildTypeRadar then
			buttonCount = 1
            buttonGroupList[buttonCount][1].label.text = TextMgr:GetText(Text.ui_worldmap_29)
            SetClickCallback(buttonGroupList[buttonCount][1].button.gameObject, function()
                local name = string.format("[%s]%s", guildMsg.guildbanner, TextMgr:GetText(buildingData.name))
                tileInfoMore:Open(buttonGroupList[buttonCount][1].button.gameObject,name,mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
            end)
        end
    end
    tileInfo.nameLabel.text = TextMgr:GetText(buildingData.name)
    tileInfo.unionLabel.text = string.format("[%s]%s", guildMsg.guildbanner, guildMsg.guildname)

    for _, v in ipairs(unionBuildingButtonCountList) do
        buttonGroupList[v].transform.gameObject:SetActive(buttonCount == v)
    end

    for i = infoCount + 1, 3 do
        infoList[i].transform.gameObject:SetActive(false)
    end

    tileInfo.infoGrid:Reposition()
    tileInfo.infoBg.height = tileInfo.infoHeight * infoCount
end

local function SetRebelMonsterAttackInfo(tileInfo)
	local targettime
    RebelArmyAttackData.RequestSiegeMonsterInfo(function(msg)
        if _ui == nil then
            return
        end
		if msg.lastStartTime == 0 then
			MessageBox.Show("获取的时间为0，请找程序查BUG")
			return
		end
		local moreBtn
		local timeLabel
		if msg.isOpen then
			_ui.rebelArmyAttack.opened.go:SetActive(true)
			_ui.rebelArmyAttack.notopen.go:SetActive(false)
			if UnionInfoData.HasUnion() and msg.isAttack then
				if msg.lastWave >= RebelArmyAttackData.GetMaxWave(msg.siegeNumber) then
					targettime = msg.lastStartTime + tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.RebelArmyAttackDuration).value)
					_ui.rebelArmyAttack.opened.title_time.text = TextMgr:GetText("RebelArmyAttack_ui3")
				else
					targettime = msg.lastStartTime + tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.RebelArmyAttackCD).value)
					_ui.rebelArmyAttack.opened.title_time.text = TextMgr:GetText("RebelArmyAttack_ui52")
				end
				timeLabel = _ui.rebelArmyAttack.opened.text_time
				_ui.rebelArmyAttack.opened.text_title.text = TextMgr:GetText("SiegeMonster_" .. msg.lastWave) .. TextMgr:GetText("RebelArmyAttack_ui8")
				_ui.rebelArmyAttack.opened.text_power.text = String.Format(TextMgr:GetText("RebelArmyAttack_ui4"), TableMgr:GetSiegeMonsterFightByWave(msg.lastWave))
				_ui.rebelArmyAttack.btn_group[2][1].parent.gameObject:SetActive(true)
				_ui.rebelArmyAttack.btn_group[3][1].parent.gameObject:SetActive(false)
				moreBtn = _ui.rebelArmyAttack.btn_group[2][2]
				SetClickCallback(_ui.rebelArmyAttack.btn_group[2][1].gameObject, function()
					ActivityAll.Show("RebelArmyAttack")
				end)
			else
				if msg.lastWave >= RebelArmyAttackData.GetMaxWave(msg.siegeNumber) then
					_ui.rebelArmyAttack.opened.go:SetActive(false)
					_ui.rebelArmyAttack.notopen.go:SetActive(true)
					timeLabel = _ui.rebelArmyAttack.notopen.text_time
					targettime = msg.lastStartTime + tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.RebelArmyAttackDuration).value)
					_ui.rebelArmyAttack.notopen.title_time.text = TextMgr:GetText("RebelArmyAttack_ui3")
					_ui.rebelArmyAttack.btn_group[3][1].parent.gameObject:SetActive(false)
					_ui.rebelArmyAttack.btn_group[2][1].parent.gameObject:SetActive(true)
					moreBtn = _ui.rebelArmyAttack.btn_group[2][2]
					SetClickCallback(_ui.rebelArmyAttack.btn_group[2][1].gameObject, function()
						ActivityAll.Show("RebelArmyAttack")
					end)
				else
					_ui.rebelArmyAttack.opened.text_title.text = TextMgr:GetText("SiegeMonster_" .. (msg.lastWave + 1))
					_ui.rebelArmyAttack.opened.text_power.text = String.Format(TextMgr:GetText("RebelArmyAttack_ui4"), TableMgr:GetSiegeMonsterFightByWave(msg.lastWave + 1))
					timeLabel = _ui.rebelArmyAttack.opened.text_time
					targettime = msg.lastStartTime + tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.RebelArmyAttackDuration).value)
					_ui.rebelArmyAttack.opened.title_time.text = TextMgr:GetText("RebelArmyAttack_ui3")
					_ui.rebelArmyAttack.btn_group[2][1].parent.gameObject:SetActive(false)
					_ui.rebelArmyAttack.btn_group[3][1].parent.gameObject:SetActive(true)
					moreBtn = _ui.rebelArmyAttack.btn_group[3][3]
					SetClickCallback(_ui.rebelArmyAttack.btn_group[3][1].gameObject, function()
						ActivityAll.Show("RebelArmyAttack")
					end)
					SetClickCallback(_ui.rebelArmyAttack.btn_group[3][2].gameObject, function()
						RebelArmyAttackData.RequestSiegeMonsterStart(tileMsg.data.uid, function(msg)
							if msg.code ~= ReturnCode_pb.Code_OK then
								Global.ShowError(msg.code)
							end
							Hide()
						end)
					end)
				end
			end
		else
			_ui.rebelArmyAttack.opened.go:SetActive(false)
			_ui.rebelArmyAttack.notopen.go:SetActive(true)
			timeLabel = _ui.rebelArmyAttack.notopen.text_time
			targettime = msg.lastStartTime
			_ui.rebelArmyAttack.notopen.title_time.text = TextMgr:GetText("RebelArmyAttack_ui2")
			_ui.rebelArmyAttack.btn_group[3][1].parent.gameObject:SetActive(false)
			_ui.rebelArmyAttack.btn_group[2][1].parent.gameObject:SetActive(true)
			moreBtn = _ui.rebelArmyAttack.btn_group[2][2]
			SetClickCallback(_ui.rebelArmyAttack.btn_group[2][1].gameObject, function()
				ActivityAll.Show("RebelArmyAttack")
			end)
		end
		CountDown.Instance:Add("TileRebelArmyAttack",targettime,CountDown.CountDownCallBack(function(t)
	        --if t:find("d") ~= nil then
	        --	timeLabel.text = String.Format(TextMgr:GetText("RebelArmyAttack_ui18"),t:split("d")[1])
	        --else
	        	timeLabel.text = t
	        --end
	        if targettime <= Serclimax.GameTime.GetSecTime() then
	        	Hide()
	        end
	    end))
	    SetClickCallback(moreBtn.gameObject, function()
            tileInfoMore:Open(moreBtn.gameObject,TextMgr:GetText("RebelArmyAttack_ui27"),mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
        end)
	end)
end

local gov_flag_icon_path = ResourceLibrary.PATH_ICON .. "Union/"

local function UpdateGoveInputLimit()
    if _ui == nil then
        return
    end
    local infoPage = _ui.governmentInfo
    local characterCount = utf8.len(infoPage.editInput.value)
    infoPage.numLabel.text = string.format("%d/%d", characterCount, infoPage.characterLimit)
    infoPage.numLabel.color = characterCount >= infoPage.characterLimit and NGUIMath.HexToColor(0xFF0002FF) or Color.white 
end

function ShowEditGoveNotice()
    if _ui == nil then
        return
    end    
    local infoPage = _ui.governmentInfo
    local infoMsg = GovernmentData.GetGovernmentData()
    infoPage.editTransform.gameObject:SetActive(true)
    infoPage.editInput.value = infoMsg.notice
    infoPage.editInput.isSelected = true
    UpdateGoveInputLimit()
end

function CheckCenterBuild()
    local govState =  GovernmentData.GetGOVState()
    if govState == 1 then
        FloatText.Show(TextMgr:GetText("GOV_ui70")  , Color.red)
        return false
    end   
    local selfGuildId = MobaMainData.GetTeamID()
    if selfGuildId == 0 then
        FloatText.Show(TextMgr:GetText("GOV_ui76")  , Color.red)
        return false
    end
    return true
end

local function ShowGTSF_MonsterArmy(monsterArmy_msg,root_trf)
    if monsterArmy_msg == nil then
        root_trf.gameObject:SetActive(false)
        return false
    end
    root_trf.gameObject:SetActive(true)
    local hero_trf = root_trf:Find("listitem_hero")
    local solider_trf = root_trf:Find("troops")
    local hero = {}
    local heroMsg = monsterArmy_msg.hero.heros[1]
    if heroMsg ~= nil then
        HeroList.LoadHeroObject(hero, hero_trf)
        UIUtil.LoadHeroInfo(hero , heroMsg , false)
        local heroData = TableMgr:GetHeroData(heroMsg.baseid) 
        SetClickCallback(hero.btn.gameObject, function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                Tooltip.ShowItemTip({name = TextMgr:GetText(heroData.nameLabel), text = TextMgr:GetText(heroData.description)})
            end
        end)


        hero_trf.gameObject:SetActive(true)
    else
        hero_trf.gameObject:SetActive(false)
    end

    local soldierList= {}
    for i=1,5 do
        soldierList[i] = {}
        soldierList[i].gameObject = solider_trf:Find("btn_enemy ("..i..")").gameObject
        soldierList[i].iconTexture = solider_trf:Find("btn_enemy ("..i..")/enemy"):GetComponent("UITexture")
        soldierList[i].numberLabel = solider_trf:Find("btn_enemy ("..i..")/Label"):GetComponent("UILabel")
    end

    local soldierIndex = 1
    local total_count = 0
    for i=1,#monsterArmy_msg.army.army do
        if i>5 then
            break
        end
        local soldierId = monsterArmy_msg.army.army[i].armyId
        local soldierLevel =monsterArmy_msg.army.army[i].armyLevel
        local soldierCount = monsterArmy_msg.army.army[i].num
        total_count = total_count + soldierCount
        local soldierData = TableMgr:GetBarrackData(soldierId, soldierLevel)
        local soldier = soldierList[soldierIndex]
        soldier.iconTexture.mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", soldierData.SoldierIcon)
        soldier.numberLabel.text = soldierCount
        soldier.gameObject:SetActive(true)
        SetClickCallback(soldier.gameObject, function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                Tooltip.ShowItemTip({name = TextMgr:GetText(soldierData.SoldierName), text = TextMgr:GetText(soldierData.SoldierDes)})
            end
        end)

        soldierIndex = soldierIndex + 1
    end

    for i = soldierIndex, 5 do
        soldierList[i].gameObject:SetActive(false)
    end
    if total_count == 0 then
        root_trf.gameObject:SetActive(false)
        return false
    end
    return true
end


local Government_Reward = {
    [1] = {click_func = function(buff_id)
        local tip_data =
        {
            buffTitle = TextMgr:GetText("ui_rewardtittle1") , 
            buffDes = TextMgr:GetText("ui_fortressdes1") , 
            actList =buff_id, 
            actListCount = nil,
            buffTip = true
        }        
        Tooltip.ShowStrongHoldBufftip(tip_data)
    end},
    [2] = {click_func = function()
        local tip_data =
        {
            buffTitle = TextMgr:GetText("ui_rewardtittle5") , 
            buffDes = TextMgr:GetText("ui_govdes5") , 
            actList = nil, 
            actListCount = nil,
            buffTip = false
        }        
        Tooltip.ShowStrongHoldBufftip(tip_data)
    end},
    [3] = {click_func = function(item)
        local tip_data =
        {
            buffTitle = TextMgr:GetText("ui_rewardtittle3") , 
            buffDes = TextMgr:GetText("ui_strongholddes3") , 
            actList = item.actList, 
            actListCount = item.actListCount,
            buffTip = false
        }        
        Tooltip.ShowStrongHoldBufftip(tip_data)
    end},
    [4] = {click_func = function(item)
        local tip_data =
        {
            buffTitle = TextMgr:GetText("ui_rewardtittle2") , 
            buffDes = TextMgr:GetText("ui_fortressdes2") , 
            actList = item.actList, 
            actListCount = item.actListCount,
            buffTip = false
        }        
        Tooltip.ShowStrongHoldBufftip(tip_data)
    end},
}   

local function UpdateGovernmentInfo(tileInfo)
    local gov_msg = GovernmentData.GetGovernmentData()
    if gov_msg == nil then
        return
    end
    if _ui == nil then
        return
    end

    local guildid = gov_msg.archonInfo.guildId
    local selfGuildId = MobaMainData.GetTeamID()
    local charId = MobaMainData.GetCharId()  
    local govState = GovernmentData.GetGOVState()
    local govActInfo = GovernmentData.GetGOVActInfo()
    local endTime = 0

    local reward_click_param = {}



    --------------------------------------------------------------------------
    local buff_array = string.split(gov_msg.rulingBuff,';')
    reward_click_param[1] ={}
    for i=1,#buff_array do
        table.insert(reward_click_param[1],tonumber( buff_array[i])) 
    end

    reward_click_param[3] = {}  
    reward_click_param[3].actList = {}
    reward_click_param[3].actListCount={}
    
    for i=1,#gov_msg.killMonsterReward.items do
        table.insert(reward_click_param[3].actList,gov_msg.killMonsterReward.items[i].id)
        reward_click_param[3].actListCount[gov_msg.killMonsterReward.items[i].id] = gov_msg.killMonsterReward.items[i].num
    end

    reward_click_param[4] = {}  
    reward_click_param[4].actList = {}
    reward_click_param[4].actListCount={}
    
    for i=1,#gov_msg.rulingReward.items do
        table.insert(reward_click_param[4].actList,gov_msg.rulingReward.items[i].id)
        reward_click_param[4].actListCount[gov_msg.rulingReward.items[i].id] = gov_msg.rulingReward.items[i].num
    end        

    for i=1,4 do
        if i ==3 then
            tileInfo.rewards_items[i].root.gameObject:SetActive(#gov_msg.killMonsterReward.items ~= 0)
        end  

        SetClickCallback(tileInfo.rewards_items[i].root.gameObject,
        function()
            Government_Reward[i].click_func(reward_click_param[i])
        end)
    end    
    tileInfo.rewards_items_grid:Reposition()
    
    if gov_msg.archonInfo == nil or gov_msg.archonInfo.guildId == 0 then
        tileInfo.info1.gameObject:SetActive(false)
        tileInfo.info2.gameObject:SetActive(false)
        tileInfo.info3.gameObject:SetActive(false)
        if not ShowGTSF_MonsterArmy(gov_msg.monsterArmy,tileInfo.enemy_root) then
            tileInfo.info1.gameObject:SetActive(true)
            tileInfo.info2.gameObject:SetActive(true)
            tileInfo.info3.gameObject:SetActive(true)
        end
    else
        ShowGTSF_MonsterArmy(nil,tileInfo.enemy_root)
        tileInfo.info1.gameObject:SetActive(true)
        tileInfo.info2.gameObject:SetActive(true)
        tileInfo.info3.gameObject:SetActive(true)
    end   
    
    --------------------------------------------------------------------------

    if govState == 1 then
        tileInfo.stateLabel.text = TextMgr:GetText("GOV_ui5")
        endTime = govActInfo.contendStartTime
        tileInfo.stateTimeLabel.color = Color.white
    elseif govState == 2 then
        tileInfo.stateLabel.text = TextMgr:GetText("GOV_ui6")
        endTime = govActInfo.contendEndTime
        tileInfo.stateTimeLabel.color = Color.red
    end
    if GameTime.GetSecTime() > endTime then
        endTime = GameTime.GetSecTime() + 7200
        print("Error：Server active time error！！！！！！！！！！！！！！！！"..govActInfo.contendStartTime..","..govActInfo.contendEndTime..
        endTime..","..GameTime.GetSecTime())
    end
    local display_time = tonumber(TableMgr:GetGlobalData(100180).value)
    tileInfo.stateTimeLabel.gameObject:SetActive(true)
    if govActInfo.contendStartTime == govActInfo.firstStartTime then
        if govActInfo.contendStartTime - GameTime.GetSecTime() > display_time then
            tileInfo.stateTimeLabel.gameObject:SetActive(false)
        end
    end
    CountDown.Instance:Add("Gov_State",endTime,CountDown.CountDownCallBack(function(t)
        if _ui == nil then
            CountDown.Instance:Remove("Gov_State")
            return
        end
        tileInfo.stateTimeLabel.text  = t

        if endTime+1 - GameTime.GetSecTime() <= 0 then
            CountDown.Instance:Remove("Gov_State")    
            GovernmentData.ReqGoveInfoData(function()
                UpdateGovernmentInfo(tileInfo)
            end)                    
        end			
    end))

    if gov_msg.archonInfo ~= nil and gov_msg.archonInfo.guildId ~= 0 then
        tileInfo.flag.gameObject:SetActive(true)
        tileInfo.flag.mainTexture = ResourceLibrary:GetIcon(gov_flag_icon_path, gov_msg.archonInfo.guildLang)
        tileInfo.unionNameLabel.text = "["..gov_msg.archonInfo.guildBanner.."]"..gov_msg.archonInfo.guildName
        tileInfo.officialNameLabel.text = "["..gov_msg.archonInfo.guildBanner.."]"..gov_msg.archonInfo.charName
    else
        tileInfo.flag.gameObject:SetActive(false)
        tileInfo.unionNameLabel.text = TextMgr:GetText("union_nounion")
        tileInfo.officialNameLabel.text = TextMgr:GetText("union_nounion")       
    end

    if gov_msg.garrisonCapacity == 0 then
        tileInfo.powerLabel.text = TextMgr:GetText("union_nounion")
    else
        tileInfo.powerLabel.text =gov_msg.garrisonNum .." / "..gov_msg.garrisonCapacity
    end

    if (gov_msg.notice ~= nil and gov_msg.notice ~= "" ) or (not GovernmentData.
    IsPrivilegeValid(MapData_pb.GovernmentPrivilege_EditNotice,MainData.GetGOVPrivilege()))then
        tileInfo.noticeLabel.text = gov_msg.notice
    end
    
	tileInfo.transBg.gameObject:SetActive(gov_msg.notice ~= nil and gov_msg.notice ~= "")
	annouceContent = {}
	annouceContent.transBtn = tileInfo.transBtn
	annouceContent.origeBtn = tileInfo.origeBtn
	annouceContent.content = tileInfo.noticeLabel:GetComponent("UILabel")--msg.content
	annouceContent.srcContent = gov_msg.notice
	annouceContent.transing = tileInfo.transing
	
    if selfGuildId == guildid and selfGuildId ~= 0 then
        tileInfo.power.gameObject:SetActive(true)
        tileInfo.friendly.gameObject:SetActive(true)
        tileInfo.hostile.gameObject:SetActive(false)
        tileInfo.bg.spriteName = "common_bg"
        tileInfo.titleBg.spriteName = "title_bg4"
        SetClickCallback(tileInfo.friendly_share.gameObject, function()
            tileInfoMore:Open(tileInfo.friendly_share.gameObject,TextMgr:GetText("GOV_ui7"),mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
        end)   
        SetClickCallback(tileInfo.friendly_garrison.gameObject, function()
            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            MobaEmbassy.CanGOVEmbassy(uid,mapX,mapY) 
        end)    
        
        SetClickCallback(tileInfo.friendly_check_garrison.gameObject, function()
            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            MobaEmbassy.ShowGOVMode(uid,mapX,mapY,nil) 
        end)           
        
        SetClickCallback(tileInfo.friendly_manage.gameObject, function()
            GOV_Main.Show(true,-1)
        end)           
    else
        tileInfo.power.gameObject:SetActive(false)
        tileInfo.friendly.gameObject:SetActive(false)
        tileInfo.hostile.gameObject:SetActive(true)
        tileInfo.bg.spriteName = "common_bg"
        tileInfo.titleBg.spriteName = "title_bg4_red"
        SetClickCallback(tileInfo.hostile_scout.gameObject, function()
            if not CheckCenterBuild() then
                return
            end
            GetInterface("BeginSpy")(2,1)
        end)
        SetClickCallback(tileInfo.hostile_attack.gameObject, function()
            if not CheckCenterBuild() then
                return
            end        
            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            MobaBattleMove.Show(Common_pb.TeamMoveType_AttackCenterBuild, uid, "", tileMsg ~= nil and tileMsg.data.pos.x or mapX,tileMsg ~= nil and tileMsg.data.pos.y or mapY, Hide)
        end)
        SetClickCallback(tileInfo.hostile_mass.gameObject, function()
            if not CheckCenterBuild() then
                return
            end         
            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            local mtc = MassTroopsCondition()
            local x = mapX
            local y = mapY
            mtc.target_enable_mass =  true
            mtc.isActMonster = true
            mtc:MobaCreateMass4BattleCondition(function(success)
                if success then
                    assembled_time.Show(function(time)
                        if time ~= 0 then
                            local building = maincity.GetBuildingByID(43)  
                            if building ~= nil then
                                local curAssembledData = TableMgr:GetAssembledData(building.data.level)
                                mtc:MobaShowCreateMassBattleMove(uid, TextMgr:GetText("GOV_ui7"), x, y,curAssembledData.armynum,time)
                            end                           
                        end
                    end, true)
                end
            end)   
        end)
        SetClickCallback(tileInfo.hostile_share.gameObject, function()
            tileInfoMore:Open(tileInfo.hostile_share.gameObject,TextMgr:GetText("GOV_ui7"),mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
        end)
        
        SetClickCallback(tileInfo.hostile_check.gameObject, function()
            GOV_Main.Show(true,-1)
        end)        
    end
end

local function SetGovernmentInfo(tileInfo)
    GovernmentData.AddGovRulingListener(DisposeGovRulingPush)    
    GovernmentData.ReqGoveInfoData(function()
        UpdateGovernmentInfo(tileInfo)
        tileInfo.transform.gameObject:SetActive(true);
    end)
end

local function UpdateTurretInfo(subType,tileInfo)
    local turret_msg = GovernmentData.GetTurretData(subType)
    if turret_msg == nil then
        return
    end
    if _ui == nil then
        return
    end

    local guildid = turret_msg.rulingInfo~= nil and turret_msg.rulingInfo.guildId or 0

    local selfGuildId = MobaMainData.GetTeamID()
    local charId = MobaMainData.GetCharId()  
    local govState = GovernmentData.GetGOVState()
    local govActInfo = GovernmentData.GetGOVActInfo()
    local endTime = 0


-----------------------------------------------------------------------------
    if turret_msg.rulingInfo ~= nil and turret_msg.rulingInfo.guildId ~= nil and turret_msg.rulingInfo.guildId ~= 0 then
        ShowGTSF_MonsterArmy(nil,tileInfo.enemy_root)
        tileInfo.info2.gameObject:SetActive(true)
    else
        tileInfo.info2.gameObject:SetActive(false)
        if not ShowGTSF_MonsterArmy(turret_msg.monsterArmy,tileInfo.enemy_root) then
            tileInfo.info2.gameObject:SetActive(true)
        end
    end          
-----------------------------------------------------------------------------


    if govState == 1 then
        tileInfo.stateLabel.text = TextMgr:GetText("GOV_ui5")
        endTime = govActInfo.contendStartTime
        tileInfo.stateTimeLabel.color = Color.white
    elseif govState == 2 then
        tileInfo.stateLabel.text = TextMgr:GetText("GOV_ui6")
        endTime = govActInfo.contendEndTime
        tileInfo.stateTimeLabel.color = Color.red
    end
    print("RRRRRRRRRRRRRRRRRRRRRR",govState,govActInfo.contendStartTime,govActInfo.contendEndTime,GameTime.GetSecTime(),GameTime.GetSecTime(),endTime)
    if GameTime.GetSecTime() > endTime then
        endTime = GameTime.GetSecTime() + 7200
        print("Error：Server active time error！！！！！！！！！！！！！！！！")
    end    

    local display_time = tonumber(TableMgr:GetGlobalData(100180).value)
    tileInfo.stateTimeLabel.gameObject:SetActive(true)
    if govActInfo.contendStartTime == govActInfo.firstStartTime then
        if govActInfo.contendStartTime - GameTime.GetSecTime() > display_time then
            tileInfo.stateTimeLabel.gameObject:SetActive(false)
        end
    end

    CountDown.Instance:Add("Turret_State",endTime,CountDown.CountDownCallBack(function(t)
        if _ui == nil then
            CountDown.Instance:Remove("Turret_State")
            return
        end
        tileInfo.stateTimeLabel.text  = t

        if endTime+1 - GameTime.GetSecTime() <= 0 then
            CountDown.Instance:Remove("Turret_State")    
            GovernmentData.ReqTurretInfoData(subType,function()
                UpdateTurretInfo(subType,tileInfo)
            end)                  
        end			
    end))

    if turret_msg.rulingInfo ~= nil and turret_msg.rulingInfo.guildId ~= nil and turret_msg.rulingInfo.guildId ~= 0 then
        tileInfo.flag.gameObject:SetActive(true)
        tileInfo.flag.mainTexture = ResourceLibrary:GetIcon(gov_flag_icon_path, turret_msg.rulingInfo.guildLang)
        tileInfo.unionNameLabel.text = "["..turret_msg.rulingInfo.guildBanner.."]"..turret_msg.rulingInfo.guildName
        tileInfo.officialNameLabel.text = ""--turret_msg.rulingInfo.charName
    else
        tileInfo.flag.gameObject:SetActive(false)
        tileInfo.unionNameLabel.text = TextMgr:GetText("union_nounion")
        tileInfo.officialNameLabel.text = TextMgr:GetText("union_nounion")       
    end

    if turret_msg.garrisonCapacity == 0 then
        tileInfo.powerLabel.text = TextMgr:GetText("union_nounion")
    else
        tileInfo.powerLabel.text =turret_msg.garrisonNum .." / "..turret_msg.garrisonCapacity
    end

    
    tileInfo.title.text = TextMgr:GetText(TableMgr:GetTurretDataByid(subType).name).."("..TextMgr:GetText(BatteryTarget.TurretStrategyState[turret_msg.strategy])..")"

    if selfGuildId == guildid and selfGuildId ~= 0 then
        tileInfo.power.gameObject:SetActive(true)
        tileInfo.friendly.gameObject:SetActive(true)
        tileInfo.hostile.gameObject:SetActive(false)
        tileInfo.bg.spriteName = "common_bg"
        tileInfo.titleBg.spriteName = "title_bg4"
	    SetClickCallback(tileInfo.friendly_share.gameObject, function()
            tileInfoMore:Open(tileInfo.friendly_share.gameObject,TextMgr:GetText(TableMgr:GetTurretDataByid(subType).name),mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
        end)  
        
        SetClickCallback(tileInfo.friendly_garrison.gameObject, function()
            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            if tileMsg ~= nil and tileMsg.centerBuild.turret ~= nil and tileMsg.centerBuild.turret.subType ~= nil then
                MobaEmbassy.CanTurretEmbassy(uid,mapX,mapY,tileMsg.centerBuild.turret.subType)  
            end
        end)    
                    
        SetClickCallback(tileInfo.friendly_check_garrison.gameObject, function()
            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            if tileMsg ~= nil and tileMsg.centerBuild.turret ~= nil and tileMsg.centerBuild.turret.subType ~= nil then
                MobaEmbassy.ShowGOVMode(uid,mapX,mapY,tileMsg.centerBuild.turret.subType) 
            end           
            
        end)        
        
        SetClickCallback(tileInfo.friendly_manage.gameObject, function()
            if tileMsg ~= nil and tileMsg.centerBuild.turret ~= nil and tileMsg.centerBuild.turret.subType ~= nil then
                BatteryTarget.Show(tileMsg.centerBuild.turret.subType)
            end          
        end) 
    else
        tileInfo.power.gameObject:SetActive(false)
        tileInfo.friendly.gameObject:SetActive(false)
        tileInfo.hostile.gameObject:SetActive(true)
        tileInfo.bg.spriteName = "common_bg"
        tileInfo.titleBg.spriteName = "title_bg4_red"
        SetClickCallback(tileInfo.hostile_scout.gameObject, function()
            if not CheckCenterBuild() then
                return
            end
            GetInterface("BeginSpy")(2,1)
        end)
        SetClickCallback(tileInfo.hostile_attack.gameObject, function()
            if not CheckCenterBuild() then
                return
            end          
            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            MobaBattleMove.Show(Common_pb.TeamMoveType_AttackCenterBuild, uid, "", tileMsg ~= nil and tileMsg.data.pos.x or mapX,tileMsg ~= nil and tileMsg.data.pos.y or mapY, Hide)
        end)
        SetClickCallback(tileInfo.hostile_mass.gameObject, function()
            if not CheckCenterBuild() then
                return
            end

            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            local mtc = MassTroopsCondition()
            local x = mapX
            local y = mapY
            mtc.target_enable_mass =  true
            mtc.isActMonster = true
            mtc:MobaCreateMass4BattleCondition(function(success)
                if success then
                    assembled_time.Show(function(time)
                        if time ~= 0 then
                            local building = maincity.GetBuildingByID(43)  
                            if building ~= nil then
                                local curAssembledData = TableMgr:GetAssembledData(building.data.level)
                                mtc:MobaShowCreateMassBattleMove(uid, TextMgr:GetText(TableMgr:GetTurretDataByid(tileMsg.centerBuild.turret.subType).name), x, y,curAssembledData.armynum,time)
                            end                           
                        end
                    end, true)
                end
            end)   
        end)

        SetClickCallback(tileInfo.hostile_check.gameObject, function()
            if tileMsg ~= nil and tileMsg.centerBuild.turret ~= nil and tileMsg.centerBuild.turret.subType ~= nil then
                BatteryTarget.Show(tileMsg.centerBuild.turret.subType)
            end          
        end) 

	    SetClickCallback(tileInfo.hostile_share.gameObject, function()
            tileInfoMore:Open(tileInfo.hostile_share.gameObject,TextMgr:GetText(TableMgr:GetTurretDataByid(subType).name),mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
        end)
    end
end

local function SetTurretInfo(subType,tileInfo)
    GovernmentData.AddTurretRulingListener(DisposeTurretRulingPush)
    GovernmentData.AddEditStrategyListener(RefrushTurretTitle)
    GovernmentData.ReqTurretInfoData(subType,function()
        UpdateTurretInfo(subType,tileInfo)
        tileInfo.transform.gameObject:SetActive(true);
    end)
end

local function CheckStronghold(entryType,subtype)
	local state = 1 
	if entryType == Common_pb.SceneEntryType_Stronghold then
		state = StrongholdData.GetStrongholdState(subtype)
	elseif entryType == Common_pb.SceneEntryType_Fortress then
		state = FortressData.GetFortressState(subtype)
	end
	--local state =  GovernmentData.GetGOVState()
    if state == 1 then
        FloatText.Show(TextMgr:GetText("GOV_ui70")  , Color.red)
        return false
    end   
    local selfGuildId = MobaMainData.GetTeamID()
    if selfGuildId == 0 then
        FloatText.Show(TextMgr:GetText("GOV_ui76")  , Color.red)
        return false
    end
	
    return true
end
		
local SetStrongholdInfo
local StrongholdFuncs = {
        friendly_share = function(tileInfo,title_name) 
            tileInfoMore:Open(tileInfo.friendly_share.gameObject,title_name,mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)
        end,
        friendly_garrison = function(entryType,subtype)
            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            MobaEmbassy.CanStrongholdEmbassy(entryType,subtype,uid,mapX,mapY)         
        end,
        friendly_check_garrison = function(entryType,subtype)
            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            MobaEmbassy.ShowStrongholdMode(uid,mapX,mapY,subtype,entryType)         
        end,
        friendly_manage = function(entryType)
			City_lord.Show(entryType)
            --GOV_Main.Show(true,-1)        
        end,
        hostile_scout = function(entryType,subtype)
			print(entryType,subtype)
			if not CheckStronghold(entryType,subtype) then
				return
			end
            GetInterface("BeginSpy")(2,1)        
        end,
        hostile_attack = function(entryType,subtype)  
			if not CheckStronghold(entryType , subtype) then
				return
			end
			
            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            MobaBattleMove.Show(Common_pb.TeamMoveType_AttackCenterBuild, uid, "", tileMsg ~= nil and tileMsg.data.pos.x or mapX,tileMsg ~= nil and tileMsg.data.pos.y or mapY, Hide, nil, nil, nil, tileMsg.data.entryType)         
        end,
        hostile_check = function(entryType)
			City_lord.Show(entryType)
            --GOV_Main.Show(true,-1)
        end,
        hostile_share = function(tileInfo,title_name)
            tileInfoMore:Open(tileInfo.hostile_share.gameObject,title_name,mapX,mapY,TableMgr:GetArtSettingData(tileGid).icon)        
        end,
        hostile_mass = function(title_name , entryType , subtype)
			if not CheckStronghold(entryType , subtype) then
				return
			end
			
            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            local mtc = MassTroopsCondition()
            local x = mapX
            local y = mapY
            mtc.target_enable_mass =  true
            mtc.isActMonster = true
            mtc:MobaCreateMass4BattleCondition(function(success)
                if success then
                    assembled_time.Show(function(time)
                        if time ~= 0 then
                            local building = maincity.GetBuildingByID(43)  
                            if building ~= nil then
                                local curAssembledData = TableMgr:GetAssembledData(building.data.level)
                                mtc:MobaShowCreateMassBattleMove(uid, title_name, x, y,curAssembledData.armynum,time)
                            end                           
                        end
                    end, true)
                end
            end)            
        end,    
        strongholdrewards = function()
            StrongholdRule.Show(Common_pb.SceneEntryType_Stronghold)
        end,  
        fortressrewards = function()
            StrongholdRule.Show(Common_pb.SceneEntryType_Fortress)
        end,      
    }

local Stronghold_Reward = {
    [1] = {click_func = function(buff_ids)
        local tip_data =
        {
            buffTitle = TextMgr:GetText("ui_rewardtittle1") , 
            buffDes = TextMgr:GetText("ui_strongholddes1") , 
            actList = buff_ids, 
            actListCount = nil,
            buffTip = true
        }        
        Tooltip.ShowStrongHoldBufftip(tip_data)
    end},
    [2] = {click_func = function()
        local tip_data =
        {
            buffTitle = TextMgr:GetText("ui_rewardtittle5") , 
            buffDes = TextMgr:GetText("ui_strongholddes5") , 
            actList = nil, 
            actListCount = nil,
            buffTip = false
        }        
        Tooltip.ShowStrongHoldBufftip(tip_data)
    end},
    [3] = {click_func = function(item)
        local tip_data =
        {
            buffTitle = TextMgr:GetText("ui_rewardtittle3") , 
            buffDes = TextMgr:GetText("ui_strongholddes3") , 
            actList = item.actList, 
            actListCount = item.actListCount,
            buffTip = false
        }        
        Tooltip.ShowStrongHoldBufftip(tip_data)
    end},
    [4] = {click_func = function(buff_id)
        local tip_data =
        {
            buffTitle = TextMgr:GetText("ui_rewardtittle4") , 
            buffDes = TextMgr:GetText("ui_fortressdes4") , 
            actList = {1603}, 
            actListCount = nil,
            buffTip = true
        }        
        Tooltip.ShowStrongHoldBufftip(tip_data)
    end},
}    

local Fortress_Reward = {
    [1] = {click_func = function(buff_id)
        local tip_data =
        {
            buffTitle = TextMgr:GetText("ui_rewardtittle1") , 
            buffDes = TextMgr:GetText("ui_fortressdes1") , 
            actList = buff_id, 
            actListCount = nil,
            buffTip = true
        }        
        Tooltip.ShowStrongHoldBufftip(tip_data)
    end},
    [2] = {click_func = function()
        local tip_data =
        {
            buffTitle = TextMgr:GetText("ui_rewardtittle5") , 
            buffDes = TextMgr:GetText("ui_fortressdes5") , 
            actList = nil, 
            actListCount = nil,
            buffTip = false
        }        
        Tooltip.ShowStrongHoldBufftip(tip_data)
    end},
    [3] = {click_func = function(item)
        local tip_data =
        {
            buffTitle = TextMgr:GetText("ui_rewardtittle3") , 
            buffDes = TextMgr:GetText("ui_strongholddes3") , 
            actList = item.actList, 
            actListCount = item.actListCount,
            buffTip = false
        }        
        Tooltip.ShowStrongHoldBufftip(tip_data)
    end},
    [4] = {click_func = function(item)
        local tip_data =
        {
            buffTitle = TextMgr:GetText("ui_rewardtittle2") , 
            buffDes = TextMgr:GetText("ui_fortressdes2") , 
            actList = item.actList, 
            actListCount = item.actListCount,
            buffTip = false
        }        
        Tooltip.ShowStrongHoldBufftip(tip_data)
    end},
}    

local function UpdateStrongholdInfo(tileInfo,subtype,entryType)
    if _ui == nil then
        return
    end    
    local guildid
    local selfGuildId 
    local charId 
    
    local holdActInfo
    local endTime = 0

    local holdState
    local contendStartTime 
    local contendEndTime
    local archonInfo 
    local archonInfo_guildId
    local archonInfo_guildBanner
    local archonInfo_guildLang
    local archonInfo_guildName
    local archonInfo_charName 
    local garrisonNum 
    local garrisonCapacity 
    local title_name 


    local info
    local reward_click_param = {}

    if entryType == Common_pb.SceneEntryType_Stronghold then
        local stronghold_msg = StrongholdData.GetStrongholdData(subtype)
        if stronghold_msg == nil then
            return
        end
        guildid = stronghold_msg.rulingInfo.guildId
        selfGuildId = MobaMainData.GetTeamID()
        charId = MobaMainData.GetCharId()          
        strongholdActInfo = StrongholdData.GetStrongholdActInfo(subtype)
        strongholdState = StrongholdData.GetStrongholdState(subtype)
        contendStartTime = strongholdActInfo.contendStartTime
        contendEndTime = strongholdActInfo.contendEndTime
        archonInfo = stronghold_msg.rulingInfo
        archonInfo_guildId = stronghold_msg.rulingInfo == nil and 0 or stronghold_msg.rulingInfo.guildId
        archonInfo_guildBanner = stronghold_msg.rulingInfo == nil and "" or stronghold_msg.rulingInfo.guildBanner
        archonInfo_guildLang = stronghold_msg.rulingInfo == nil and "" or stronghold_msg.rulingInfo.guildLang
        archonInfo_guildName = stronghold_msg.rulingInfo == nil and "" or stronghold_msg.rulingInfo.guildName
        archonInfo_charName = stronghold_msg.rulingInfo == nil and nil or stronghold_msg.rulingInfo.charName
        garrisonNum = stronghold_msg.garrisonNum
        garrisonCapacity = stronghold_msg.garrisonCapacity  
        title_name = TextMgr:GetText(TableMgr:GetStrongholdRuleByID(subtype).name)      
        
        tileInfo.rewards_stronghold.gameObject:SetActive(true)
        tileInfo.rewards_fortress.gameObject:SetActive(false)  

        tileInfo.info_stornghold.root.gameObject:SetActive(true)
        tileInfo.info_fortress.root.gameObject:SetActive(false)
        info = tileInfo.info_stornghold

        SetClickCallback(tileInfo.rewards.gameObject,StrongholdFuncs.strongholdrewards)   
        SetClickCallback(tileInfo.help.gameObject, function()
            GOV_Help.Show(GOV_Help.HelpModeType.STRONGHOLDMODE)
        end)         
        tileInfo.stateTimeLabel.gameObject:SetActive(true)  
        
        local buff_array = string.split(stronghold_msg.rulingBuff,';')
        reward_click_param[1] ={}
        for i=1,#buff_array do
            table.insert(reward_click_param[1],tonumber( buff_array[i])) 
        end

        local listitem = ResourceLibrary.GetUIPrefab("CommonItem/list_item")
        for i=1,#stronghold_msg.rulingReward.items do
 
            local dropdata = {}
            dropdata.contentId = stronghold_msg.rulingReward.items[i].id
            dropdata.contentNumber = stronghold_msg.rulingReward.items[i].num         

            LoadRewardItem(tileInfo.dailyrewards_stronghold_grid , listitem , dropdata)
        end
        tileInfo.dailyrewards_stronghold_grid:Reposition()

        reward_click_param[3] = {}  
        reward_click_param[3].actList = {}
        reward_click_param[3].actListCount={}
        
        for i=1,#stronghold_msg.killMonsterReward.items do
            table.insert(reward_click_param[3].actList,stronghold_msg.killMonsterReward.items[i].id)
            reward_click_param[3].actListCount[stronghold_msg.killMonsterReward.items[i].id] = stronghold_msg.killMonsterReward.items[i].num
        end

        for i=1,4 do
            if i ==3 then
                tileInfo.rewards_stronghold_items[i].root.gameObject:SetActive(#stronghold_msg.killMonsterReward.items ~= 0)
            end
            SetClickCallback(tileInfo.rewards_stronghold_items[i].root.gameObject,
            function()
                Stronghold_Reward[i].click_func(reward_click_param[i])
            end)
        end
        tileInfo.rewards_stronghold_grid:Reposition();
        if stronghold_msg.rulingInfo == nil or stronghold_msg.rulingInfo.guildId == 0 then
            tileInfo.info_stornghold.info.gameObject:SetActive(false)
            if not ShowGTSF_MonsterArmy(stronghold_msg.monsterArmy,tileInfo.info_stornghold.enemy_root) then
                tileInfo.info_stornghold.info.gameObject:SetActive(true)
            end
        else
            ShowGTSF_MonsterArmy(nil,tileInfo.info_stornghold.enemy_root)
            tileInfo.info_stornghold.info.gameObject:SetActive(true)
        end
    elseif entryType == Common_pb.SceneEntryType_Fortress then
		local fortress_msg = FortressData.GetFortressData(subtype)
        if fortress_msg == nil then
            return
        end
		guildid = fortress_msg.rulingInfo.guildId
        selfGuildId = MobaMainData.GetTeamID()
        charId = MobaMainData.GetCharId()   

        strongholdActInfo = FortressData.GetFortressActInfo(subtype)
        strongholdState = FortressData.GetFortressState(subtype)
        contendStartTime = strongholdActInfo.contendStartTime
        contendEndTime = strongholdActInfo.contendEndTime
        archonInfo = fortress_msg.rulingInfo
        archonInfo_guildId = fortress_msg.rulingInfo == nil and 0 or fortress_msg.rulingInfo.guildId
        archonInfo_guildBanner = fortress_msg.rulingInfo == nil and "" or fortress_msg.rulingInfo.guildBanner
        archonInfo_guildLang = fortress_msg.rulingInfo == nil and "" or fortress_msg.rulingInfo.guildLang
        archonInfo_guildName = fortress_msg.rulingInfo == nil and "" or fortress_msg.rulingInfo.guildName
        archonInfo_charName = fortress_msg.rulingInfo == nil and nil or fortress_msg.rulingInfo.charName
		
        garrisonNum = fortress_msg.garrisonNum
        garrisonCapacity = fortress_msg.garrisonCapacity  
        title_name = TextMgr:GetText(TableMgr:GetFortressRuleByID(subtype).name)      
        
        local display_time = tonumber(TableMgr:GetGlobalData(100180).value)
        tileInfo.stateTimeLabel.gameObject:SetActive(true)


        if fortress_msg.contendStartTime == fortress_msg.firstStartTime then
            if fortress_msg.contendStartTime - GameTime.GetSecTime() > display_time then
                tileInfo.stateTimeLabel.gameObject:SetActive(false)
            end
        end    

        tileInfo.rewards_stronghold.gameObject:SetActive(false)
        tileInfo.rewards_fortress.gameObject:SetActive(true)  

        tileInfo.info_stornghold.root.gameObject:SetActive(false)
        tileInfo.info_fortress.root.gameObject:SetActive(true)
        info = tileInfo.info_fortress

        SetClickCallback(tileInfo.rewards.gameObject,StrongholdFuncs.fortressrewards) 
        SetClickCallback(tileInfo.help.gameObject, function()
            GOV_Help.Show(GOV_Help.HelpModeType.FORTRESS)
        end)      
        
        --------------------------------------------------------------
        local buff_array = string.split(fortress_msg.rulingBuff,';')
        reward_click_param[1] ={}
        for i=1,#buff_array do
            table.insert(reward_click_param[1],tonumber( buff_array[i]))
        end

        reward_click_param[3] = {}  
        reward_click_param[3].actList = {}
        reward_click_param[3].actListCount={}
        
        for i=1,#fortress_msg.killMonsterReward.items do
            table.insert(reward_click_param[3].actList,fortress_msg.killMonsterReward.items[i].id)
            reward_click_param[3].actListCount[fortress_msg.killMonsterReward.items[i].id] = fortress_msg.killMonsterReward.items[i].num
        end

        reward_click_param[4] = {}  
        reward_click_param[4].actList = {}
        reward_click_param[4].actListCount={}
        
        for i=1,#fortress_msg.rulingReward.items do
            table.insert(reward_click_param[4].actList,fortress_msg.rulingReward.items[i].id)
            reward_click_param[4].actListCount[fortress_msg.rulingReward.items[i].id] = fortress_msg.rulingReward.items[i].num
        end        

        for i=1,4 do
            if i ==3 then
                tileInfo.rewards_fortress_items[i].root.gameObject:SetActive(#fortress_msg.killMonsterReward.items ~= 0)
            end

            SetClickCallback(tileInfo.rewards_fortress_items[i].root.gameObject,
            function()
                Fortress_Reward[i].click_func(reward_click_param[i])
            end)
        end    
        tileInfo.rewards_fortress_grid:Reposition();
        
        if fortress_msg.rulingInfo == nil or fortress_msg.rulingInfo.guildId == 0 then
            tileInfo.info_fortress.info.gameObject:SetActive(false)
            if not ShowGTSF_MonsterArmy(fortress_msg.monsterArmy,tileInfo.info_fortress.enemy_root) then
                tileInfo.info_fortress.info.gameObject:SetActive(true)
            end
        else
            ShowGTSF_MonsterArmy(nil,tileInfo.info_fortress.enemy_root)
            tileInfo.info_fortress.info.gameObject:SetActive(true)
        end        
    else
        return
    end
	
	if entryType == Common_pb.SceneEntryType_Stronghold then
		StrongholdData.OpenStrongholdUI(subtype)
	elseif entryType == Common_pb.SceneEntryType_Fortress then
		FortressData.OpenFortressUI(subtype)
	end

    if strongholdState == 1 then
        tileInfo.stateLabel.text = TextMgr:GetText("GOV_ui5")
        endTime = contendStartTime
        tileInfo.stateTimeLabel.color = Color.white
    elseif strongholdState == 2 then
        tileInfo.stateLabel.text = TextMgr:GetText("GOV_ui6")
        endTime = contendEndTime
        tileInfo.stateTimeLabel.color = Color.red
    elseif strongholdState == 3 then
        tileInfo.stateLabel.text = TextMgr:GetText("war_over")
        endTime = -1
        tileInfo.stateLabel.color = Color.red
        tileInfo.stateTimeLabel.color = Color.red
    end

    if endTime < 0 then
        tileInfo.stateTimeLabel.text = "--:--:--" --gameObject:SetActive(false)
    else
        CountDown.Instance:Add("Hold_State",endTime,CountDown.CountDownCallBack(function(t)
            if _ui == nil then
                CountDown.Instance:Remove("Hold_State")
                return
            end
            tileInfo.stateTimeLabel.text  = t
    
            if endTime+1 - GameTime.GetSecTime() <= 0 then
                CountDown.Instance:Remove("Hold_State")  
                SetStrongholdInfo(tileInfo,subtype,entryType,false)               
            end			
        end))

    end


    if strongholdActInfo ~= nil and archonInfo_guildId ~= 0 then
        tileInfo.flag.gameObject:SetActive(true)
        tileInfo.flag.mainTexture = ResourceLibrary:GetIcon(gov_flag_icon_path, archonInfo_guildLang)
        info.unionNameLabel.text = "["..archonInfo_guildBanner.."]"..archonInfo_guildName
        info.officialNameLabel.text = (archonInfo_charName == nil or archonInfo_charName == "") and TextMgr:GetText("union_nounion") or "["..archonInfo_guildBanner.."]"..archonInfo_charName

    else
        tileInfo.flag.gameObject:SetActive(false)
        info.unionNameLabel.text = TextMgr:GetText("union_nounion")
        info.officialNameLabel.text = TextMgr:GetText("union_nounion")       
    end

    if garrisonCapacity == 0 then
        info.powerLabel.text = TextMgr:GetText("union_nounion")
    else
        info.powerLabel.text =garrisonNum .." / "..garrisonCapacity
    end    
    
    tileInfo.title.text = title_name
    
    if selfGuildId == guildid and selfGuildId ~= 0 then
        tileInfo.power.gameObject:SetActive(true)
        tileInfo.friendly.gameObject:SetActive(true)
        tileInfo.hostile.gameObject:SetActive(false)
        tileInfo.bg.spriteName = "common_bg"
        tileInfo.titleBg.spriteName = "title_bg4"
        SetClickCallback(tileInfo.friendly_share.gameObject,function() StrongholdFuncs.friendly_share(tileInfo,title_name) end)   
        SetClickCallback(tileInfo.friendly_garrison.gameObject,function() StrongholdFuncs.friendly_garrison(entryType,subtype) end)    
        SetClickCallback(tileInfo.friendly_check_garrison.gameObject,function() StrongholdFuncs.friendly_check_garrison(entryType,subtype) end )          
        SetClickCallback(tileInfo.friendly_manage.gameObject,function() StrongholdFuncs.friendly_manage(entryType) end)           
    else
        tileInfo.power.gameObject:SetActive(false)
        tileInfo.friendly.gameObject:SetActive(false)
        tileInfo.hostile.gameObject:SetActive(true)
        tileInfo.bg.spriteName = "common_bg"
        tileInfo.titleBg.spriteName = "title_bg4_red"
        SetClickCallback(tileInfo.hostile_scout.gameObject,function() StrongholdFuncs.hostile_scout(entryType , subtype) end)
        SetClickCallback(tileInfo.hostile_attack.gameObject,function() StrongholdFuncs.hostile_attack(entryType , subtype) end)
        SetClickCallback(tileInfo.hostile_mass.gameObject,function() StrongholdFuncs.hostile_mass(title_name , entryType , subtype) end)
        SetClickCallback(tileInfo.hostile_share.gameObject,function() StrongholdFuncs.hostile_share(tileInfo,title_name) end)
        SetClickCallback(tileInfo.hostile_check.gameObject,function() StrongholdFuncs.hostile_check(entryType) end)        
    end
end

SetStrongholdInfo = function(tileInfo,subtype,entryType,addlister)
    if entryType == Common_pb.SceneEntryType_Stronghold then
        if addlister then
            StrongholdData.AddHoldRulingListener(DisposeStrongholdPush) 
        end   
        StrongholdData.ReqStrongholdInfoData(subtype,function()
            UpdateStrongholdInfo(tileInfo,subtype,entryType)
            tileInfo.transform.gameObject:SetActive(true);
        end)        
    elseif entryType == Common_pb.SceneEntryType_Fortress then
		if addlister then
            FortressData.AddFortressRulingListener(DisposeFotressPush) 
        end   
		
        FortressData.ReqFortressData(subtype,function()
            UpdateStrongholdInfo(tileInfo,subtype,entryType)
            tileInfo.transform.gameObject:SetActive(true);
        end)    
    end
end
local moba_center_build_ids ={[1] = true,[4] = true}
local moba_main_build_ids={[1] = true,[2] = true,[3] = true,[4]= true,[5]=true,[6]=true}
local moba_ruling_strs =  { "moba_mapzone0", "moba_mapzone1", "moba_mapzone2" };

local MobaBaseFuncs = {
    friendly_share = function(tileInfo,title_name , buildid) 
        tileInfoMore:Open(tileInfo.friendly_share.gameObject,title_name,mapX,mapY,TableMgr:GetMobaMapBuildingDataByID(buildid).Icon) 
    end,
    friendly_garrison = function(entryType,build_id)
        local uid = tileMsg ~= nil and tileMsg.data.uid or 0
        MobaEmbassy.CanMobaBaseEmbassy(build_id,uid,mapX,mapY)         
    end,
    friendly_check_garrison = function(entryType,build_id)
        local uid = tileMsg ~= nil and tileMsg.data.uid or 0
        MobaEmbassy.ShowMobaBaseMode(uid,mapX,mapY,build_id)         
    end,
    friendly_formation = function()
		local uid = tileMsg ~= nil and tileMsg.data.uid or 0
		MobaBattleMoveData.RequestBuildingFormation(uid ,Common_pb.BattleFormation_Def, function(success , form)
			if form.armyForm.form == nil or #form.armyForm.form == 0 then
				FloatText.Show(TextMgr:GetText("ui_moba_101"))
				return
			end
			local selfFormation = {}
			local selfPreFormation = {}
			MobaBattleMoveData.CloneFormation(selfFormation,form.armyForm.form)
			MobaBattleMoveData.CloneFormation(selfPreFormation,form.armyForm.form)
			MobaEmbattle.ShowForMobaBuilding(2,Common_pb.BattleFormation_Def , selfFormation,selfPreFormation, uid , function(new_form)
				--selfFormation = new_form
				--formationSmall:SetLeftFormation(selfFormation)
				--formationSmall:Awake(false)
			end , "MobaBuilding")
		end)
    end,
    hostile_scout = function(entryType,build_id)
        GetInterface("BeginSpy")(2,1)        
    end,
    hostile_attack = function(entryType,build_id)  
        local uid = tileMsg ~= nil and tileMsg.data.uid or 0
        MobaBattleMove.Show(Common_pb.TeamMoveType_MobaAtkBuild, uid, "", tileMsg ~= nil and tileMsg.data.pos.x or mapX,tileMsg ~= nil and tileMsg.data.pos.y or mapY, Hide, nil, nil, nil, tileMsg.data.entryType)         
    end,
    hostile_share = function(tileInfo,title_name , buildid)
        tileInfoMore:Open(tileInfo.hostile_share.gameObject,title_name,mapX,mapY,TableMgr:GetMobaMapBuildingDataByID(buildid).Icon)        
    end,
    hostile_mass = function(title_name , entryType , build_id)        
        local uid = tileMsg ~= nil and tileMsg.data.uid or 0
        local mtc = MassTroopsCondition()
        local x = mapX
        local y = mapY
        mtc.target_enable_mass =  true
        mtc.isActMonster = true
        mtc:MobaCreateMass4BattleCondition(build_id,function(success)
            if success then
                assembled_time.Show(function(time)
                    if time ~= 0 then
                        --[[
                        AttributeBonus.CollectBonusInfo(nil,false,"MobaTechData")
                        local bonus = AttributeBonus.GetBonusInfos()  
                        local base = TableMgr:GetMobaUnitInfoByID(8)
                        local army_num = tonumber( base.Value) +(bonus[1109] ~= nil and bonus[1109] or 0)
                        ]]
                        local army_num = Global.MobaArmyNum4MassBuild()
                        mtc:MobaShowCreateMassBattleMove(uid, title_name, x, y,army_num,time)                       
                    end
                end, true)
            end
        end)            
    end,     
}

function DisposeMobaBuildStatusPush(msg)
    if _ui == nil then
        return
    end   
    if tileMsg == nil then
        return
    end
    if tileMsg.mobaBuild == nil then
        return
    end
    if _ui.mobaInfo == nil then
        return
    end
    local entryType = tileMsg.data.entryType
    if entryType == Common_pb.SceneEntryType_MobaGate or
       entryType == Common_pb.SceneEntryType_MobaCenter or 
       entryType == Common_pb.SceneEntryType_MobaArsenal or
       entryType == Common_pb.SceneEntryType_MobaFort or
       entryType == Common_pb.SceneEntryType_MobaInstitute or
       entryType == Common_pb.SceneEntryType_MobaTransPlat
    then
        if tileMsg.mobaBuild.buidingid ~= msg.buildingid then
            return
        end
        if msg.broken then
            Hide()
            return
        end
        MobaZoneBuildingData.GetDataWithCallBack(msg.buildingid,function()
            if _ui == nil then
                return
            end
            SetMobaBaseInfo(_ui.mobaInfo,tileMsg.mobaBuild.buidingid)
        end,true)
    end
end


SetMobaBaseInfo = function(tileInfo,build_id)
    if _ui == nil then
        return
    end   
    local entryType = tileMsg.data.entryType
    local build_msg = MobaZoneBuildingData.GetData(build_id)
    local myTeamID = MobaMainData.GetTeamID()
    if build_msg == nil then
        return
    end
    local now = GameTime.GetSecTime()
    local build_state = build_msg.hasShield and build_msg.shieldEndTime > now 
    local endTime = -1 
    local build_data = TableMgr:GetMobaMapBuildingDataByID(build_id)
    title_name = TextMgr:GetText(build_data.Name) 
	
    if moba_main_build_ids[build_id] then
        tileInfo.main_stateLabel.gameObject:SetActive(true)
        tileInfo.main_stateTimeLabel.gameObject:SetActive(true)
        tileInfo.stateLabel.gameObject:SetActive(false)
        if build_state then
            tileInfo.main_stateLabel.text = TextMgr:GetText("ui_moba_117")
            endTime = build_msg.shieldEndTime
            tileInfo.main_stateTimeLabel.color = Color.white
        else
            if build_msg.rulingTeam == 0 then
                tileInfo.main_stateLabel.text = TextMgr:GetText("ui_moba_118")

            elseif build_data.Camp == myTeamID then
                if  build_msg.rulingTeam == myTeamID then
                    if build_msg.garrisonNum ~= 0 then
                        tileInfo.main_stateLabel.text = System.String.Format(TextMgr:GetText("ui_moba_133"), TextMgr:GetText(moba_ruling_strs[build_msg.rulingTeam+1]))
                    else
                        tileInfo.main_stateLabel.text = TextMgr:GetText("ui_moba_118")
                    end
                else
                    if build_msg.garrisonNum ~= 0 then
                        tileInfo.main_stateLabel.text = System.String.Format(TextMgr:GetText("ui_moba_132"), TextMgr:GetText(moba_ruling_strs[build_msg.rulingTeam+1]))
                    else
                        tileInfo.main_stateLabel.text = TextMgr:GetText("ui_moba_118")
                    end 
                    tileInfo.main_stateLabel.color = Color.red
                    tileInfo.main_stateTimeLabel.color = Color.red                   
                end
            else
                if  build_msg.rulingTeam == myTeamID then
                    if build_msg.garrisonNum ~= 0 then
                        tileInfo.main_stateLabel.text = System.String.Format(TextMgr:GetText("ui_moba_132"), TextMgr:GetText(moba_ruling_strs[build_msg.rulingTeam+1]))
                    else
                        tileInfo.main_stateLabel.text = TextMgr:GetText("ui_moba_118")
                    end
                else
                    if build_msg.garrisonNum ~= 0 then
                        tileInfo.main_stateLabel.text = System.String.Format(TextMgr:GetText("ui_moba_133"), TextMgr:GetText(moba_ruling_strs[build_msg.rulingTeam+1]))
                    else
                        tileInfo.main_stateLabel.text = TextMgr:GetText("ui_moba_118")
                    end   
                    tileInfo.main_stateLabel.color = Color.red
                    tileInfo.main_stateTimeLabel.color = Color.red                 
                end
            end
            endTime = -1
        end       
    else
        tileInfo.main_stateLabel.gameObject:SetActive(false)
        tileInfo.main_stateTimeLabel.gameObject:SetActive(false)
        tileInfo.stateLabel.gameObject:SetActive(true)
        if build_msg.rulingTeam == myTeamID then
			tileInfo.stateLabel.color = NGUIMath.HexToColor(0x56C0FFFF)
		else
			tileInfo.stateLabel.color = Color.red
		end 
		tileInfo.stateLabel.text = System.String.Format(TextMgr:GetText("moba_mapzone4"), TextMgr:GetText(moba_ruling_strs[build_msg.rulingTeam+1]))
    end 

    if moba_center_build_ids[build_id] then
        tileInfo.main_stateTimeLabel.gameObject:SetActive(false)
    end    
    
    if endTime < 0 then
        tileInfo.main_stateTimeLabel.text = "" --gameObject:SetActive(false)
    else
        CountDown.Instance:Add("Moba_State",endTime,CountDown.CountDownCallBack(function(t)
            if _ui == nil then
                CountDown.Instance:Remove("Moba_State")
                return
            end
            tileInfo.main_stateTimeLabel.text  = t
    
            if endTime+1 - GameTime.GetSecTime() <= 0 then
                CountDown.Instance:Remove("Moba_State")  
                SetMobaBaseInfo(tileInfo,build_id)               
            end			
        end))
    end    

    tileInfo.icon.gameObject:SetActive(true)
    tileInfo.icon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", build_data.Icon)

    local listitem = ResourceLibrary.GetUIPrefab("CommonItem/list_item")


    NGUITools.DestroyChildren(tileInfo.rewards_grid.transform)

    if build_msg.rulingReward ~= nil then
        for i=1,#build_msg.rulingReward.items do
            local dropdata = {}
            dropdata.contentId = build_msg.rulingReward.items[i].id
            dropdata.contentNumber = build_msg.rulingReward.items[i].num         
            if build_msg.rulingReward.items[i].num > 0 then
                LoadRewardItem(tileInfo.rewards_grid , listitem , dropdata)
            end
        end
    end

    if build_msg.rulingBuff ~= nil and build_msg.rulingBuff ~= "" then
        for v in string.gsplit(build_msg.rulingBuff, ";") do
            local dropdata = {}
            dropdata.contentId = tonumber(v)
            dropdata.contentNumber = 0        
            LoadSlgBuffItem(tileInfo.rewards_grid , listitem , dropdata)
        end
    end

    tileInfo.rewards_grid:Reposition()
    if moba_main_build_ids[build_id] then
        tileInfo.defence.gameObject:SetActive(true)
        local end_value = build_msg.cityguardspeed > 0 and build_msg.maxcityguard or 0
        local pass_value = (now - build_msg.refreshTime)*build_msg.cityguardspeed
        local end_defence_time = math.abs(build_msg.cityguardspeed) > 0 and math.abs((end_value - math.min(build_msg.maxcityguard,build_msg.cityguard+pass_value))/build_msg.cityguardspeed) or 0
        local cv = math.floor(math.min(build_msg.maxcityguard,build_msg.cityguard+pass_value))
        tileInfo.defence_progress.text  = cv .." / ".. build_msg.maxcityguard
        tileInfo.defence_progress_sprite.width = math.floor(302*(math.floor(math.min(build_msg.maxcityguard,build_msg.cityguard+pass_value))/build_msg.maxcityguard)) 
        if cv <= 0 then
            CountDown.Instance:Remove("Moba_Defence_State") 
            Hide()
            return
        end    

        if end_defence_time == 0 then
            tileInfo.defence_state_Label.gameObject:SetActive(false)
        else
            tileInfo.defence_state_Label.gameObject:SetActive(true)
            local state_str  = build_msg.cityguardspeed > 0 and "ui_moba_78" or "ui_moba_79"
            tileInfo.defence_state_Label.text = string.format(TextMgr:GetText(state_str), Global.SecondToTimeLong( end_defence_time))

            CountDown.Instance:Add("Moba_Defence_State",now + end_defence_time,CountDown.CountDownCallBack(function(t)
                if _ui == nil then
                    CountDown.Instance:Remove("Moba_Defence_State")
                    return
                end

                local pass_value = (GameTime.GetSecTime() - build_msg.refreshTime)*build_msg.cityguardspeed
                local cv = math.floor(math.min(build_msg.maxcityguard,build_msg.cityguard+pass_value))
                tileInfo.defence_progress.text  = cv .." / ".. build_msg.maxcityguard
                tileInfo.defence_progress_sprite.width = math.floor(302*(math.floor(math.min(build_msg.maxcityguard,build_msg.cityguard+pass_value))/build_msg.maxcityguard))
                local new_end_defence_time = math.abs((end_value - math.min(build_msg.maxcityguard,build_msg.cityguard+pass_value))/build_msg.cityguardspeed)
                tileInfo.defence_state_Label.text = TextMgr:GetText(state_str)..Global.SecondToTimeLong( new_end_defence_time)
                if cv <= 0 then
                    CountDown.Instance:Remove("Moba_Defence_State") 
                    Hide()
                    return
                end

                if new_end_defence_time == 0 then
                    CountDown.Instance:Remove("Moba_Defence_State")  
                    SetMobaBaseInfo(tileInfo,build_id)               
                end			
            end))
        end 
        tileInfo.mid.root.gameObject:SetActive(true)
        tileInfo.mid1.root.gameObject:SetActive(false)
        tileInfo.mid2.root.gameObject:SetActive(false)
        if build_msg.rulingTeam == myTeamID then
            tileInfo.mid.player_name.text = build_msg.chiefid > 0 and build_msg.chiefname or "--"
            tileInfo.mid.nums.text =  build_msg.chiefid > 0 and (build_msg.garrisonNum.." / "..build_msg.garrisonCapacity) or "--"
        else
            tileInfo.mid.player_name.text = build_msg.chiefid > 0 and build_msg.chiefname or "--"
            tileInfo.mid.nums.text =  build_msg.chiefid > 0 and "?????" or "--"
        end
    else
        tileInfo.defence.gameObject:SetActive(false)
        tileInfo.mid.root.gameObject:SetActive(false)
        tileInfo.mid1.root.gameObject:SetActive(false)
        tileInfo.mid2.root.gameObject:SetActive(false)   
        
        if not ShowGTSF_MonsterArmy(build_msg.monsterArmy,tileInfo.mid2.enemy_root) then
            tileInfo.mid1.root.gameObject:SetActive(true)
            if build_msg.rulingTeam == myTeamID then
                tileInfo.mid1.player_name.text = build_msg.chiefid > 0 and build_msg.chiefname or "--"
                tileInfo.mid1.nums.text =  build_msg.chiefid > 0 and (build_msg.garrisonNum.." / "..build_msg.garrisonCapacity) or "--"
            else
                tileInfo.mid1.player_name.text = build_msg.chiefid > 0 and build_msg.chiefname or "--"
                tileInfo.mid1.nums.text =  build_msg.chiefid > 0 and "?????" or "--"
            end   
        else
            tileInfo.mid2.root.gameObject:SetActive(true)   
        end
    end
    if myTeamID == build_msg.rulingTeam then
        tileInfo.friendly.gameObject:SetActive(true)
        tileInfo.hostile.gameObject:SetActive(false)
        tileInfo.bg.spriteName = "common_bg"
        tileInfo.titleBg.spriteName = "title_bg4"
        SetClickCallback(tileInfo.friendly_share.gameObject,function() MobaBaseFuncs.friendly_share(tileInfo,title_name , build_id) end)   
        SetClickCallback(tileInfo.friendly_garrison.gameObject,function() MobaBaseFuncs.friendly_garrison(entryType,build_id) end)    
        SetClickCallback(tileInfo.friendly_check_garrison.gameObject,function() MobaBaseFuncs.friendly_check_garrison(entryType,build_id) end )          
        SetClickCallback(tileInfo.friendly_formation.gameObject,function() MobaBaseFuncs.friendly_formation() end)           
    else
        tileInfo.friendly.gameObject:SetActive(false)
        tileInfo.hostile.gameObject:SetActive(true)
        tileInfo.bg.spriteName = "common_bg"
        tileInfo.titleBg.spriteName = "title_bg4_red"
        SetClickCallback(tileInfo.hostile_scout.gameObject,function() MobaBaseFuncs.hostile_scout(entryType , build_id) end)
        SetClickCallback(tileInfo.hostile_attack.gameObject,function() MobaBaseFuncs.hostile_attack(entryType , build_id) end)
        SetClickCallback(tileInfo.hostile_mass.gameObject,function() MobaBaseFuncs.hostile_mass(title_name , entryType , build_id) end)
        SetClickCallback(tileInfo.hostile_share.gameObject,function() MobaBaseFuncs.hostile_share(tileInfo,title_name , build_id) end)      
    end    

    tileInfo.title.text = TextMgr:GetText(build_data.Name)
    SetClickCallback(tileInfo.help.gameObject,function() 
        if entryType == Common_pb.SceneEntryType_MobaGate then
            MapHelp.Open(2501, false, nil, false, true)
        elseif entryType == Common_pb.SceneEntryType_MobaCenter then
            MapHelp.Open(2500, false, nil, false, true)
        elseif entryType == Common_pb.SceneEntryType_MobaArsenal then
            MapHelp.Open(2503, false, nil, false, true)
        elseif entryType == Common_pb.SceneEntryType_MobaFort then
            MapHelp.Open(2505, false, nil, false, true)
        elseif entryType == Common_pb.SceneEntryType_MobaInstitute then
            MapHelp.Open(2504, false, nil, false, true)
        elseif entryType == Common_pb.SceneEntryType_MobaTransPlat then
            MapHelp.Open(2502, false, nil, false, true)
        elseif entryType == Common_pb.SceneEntryType_MobaSmallBuild then
            MapHelp.Open(2709, false, nil, false, true)    
        end
    end)   
end

LoadUI = function()
    local entryType = Common_pb.SceneEntryType_None
	local guildMonster = false
	local monsterState = 1
	local pveMonter = false
    if tileMsg ~= nil then
        if WorldMapMgr.Instance:ShowTileInfo(tileMsg.data.pos.x % 512, tileMsg.data.pos.y % 512) == nil then
            Hide()
            return
        end
        entryType = tileMsg.data.entryType
        if tileMsg.monster ~= nil and tileMsg.monster.guildMon.guildMonster ~= nil then
            guildMonster = tileMsg.monster.guildMon.guildMonster
			monsterState = tileMsg.monster.guildMon.guildMonsterState
		end
		
		if tileMsg.monster ~= nil and tileMsg.monster.digMon ~= nil and tileMsg.monster.digMon.monsterBaseId > 0 then
            pveMonter = true
		end
    end

    local tileInfo = _ui.blockInfo
	local showGate = (entryType == Common_pb.SceneEntryType_ActMonster and guildMonster and monsterState == 1)
	local showMonster = (entryType == Common_pb.SceneEntryType_ActMonster and guildMonster and monsterState == 2)
	local showRebel = (entryType == Common_pb.SceneEntryType_ActMonster and not guildMonster and not pveMonter)
	local showPveMonster = (entryType == Common_pb.SceneEntryType_ActMonster and not guildMonster and pveMonter)

    local artSettingData = TableMgr:GetArtSettingData(tileGid)
    if entryType == Common_pb.SceneEntryType_None then
        SetLandInfo(tileInfo, artSettingData)
    elseif entryType == Common_pb.SceneEntryType_Home then
        tileInfo = _ui.playerInfo
        SetHomeInfo(tileInfo)
    elseif entryType == Common_pb.SceneEntryType_Monster then
        tileInfo = _ui.monsterInfo
        SetMonsterInfo(tileInfo)
    elseif entryType == Common_pb.SceneEntryType_ActMonster then
        if showRebel then
            tileInfo = _ui.rebelInfo
            SetRebelInfo(tileInfo)
        elseif showGate or showMonster then
            tileInfo = _ui.guildMonster
            SetGuildMonsterInfo(tileInfo , showGate , showMonster)
		elseif showPveMonster then
			tileInfo = _ui.pveMonster
			SetPveMonsterInfo(tileInfo)
        end
    elseif entryType >= Common_pb.SceneEntryType_ResFood and entryType <= Common_pb.SceneEntryType_ResElec then
        tileInfo = _ui.resourceInfo
        SetResourceInfo(tileInfo)
    elseif entryType == Common_pb.SceneEntryType_Barrack or entryType == Common_pb.SceneEntryType_Occupy then
        tileInfo = _ui.playerInfo
        SetBarrackInfo(tileInfo)
    elseif entryType == Common_pb.SceneEntryType_GuildBuild then
        tileInfo = _ui.unionBuildingInfo
        SetUnionBuildingInfo(tileInfo)
    elseif entryType == Common_pb.SceneEntryType_SiegeMonster then
    	tileInfo = _ui.rebelArmyAttack
        SetRebelMonsterAttackInfo(tileInfo)
    elseif entryType == Common_pb.SceneEntryType_Govt then
        tileInfo = _ui.governmentInfo
        SetGovernmentInfo(tileInfo)
    elseif entryType == Common_pb.SceneEntryType_Turret then
        if tileMsg ~= nil and tileMsg.centerBuild.turret ~= nil and tileMsg.centerBuild.turret.subType ~= nil then
            tileInfo = _ui.turretInfo
            SetTurretInfo(tileMsg.centerBuild.turret.subType,tileInfo)
        end
    elseif entryType == Common_pb.SceneEntryType_Stronghold then
        if tileMsg ~= nil and tileMsg.centerBuild.stronghold ~= nil and tileMsg.centerBuild.stronghold.subtype ~= nil then
            tileInfo = _ui.stronghold
            SetStrongholdInfo(tileInfo,tileMsg.centerBuild.stronghold.subtype,entryType,true)
        end        
    elseif entryType == Common_pb.SceneEntryType_Fortress then
        if tileMsg ~= nil and tileMsg.centerBuild.fortress ~= nil and tileMsg.centerBuild.fortress.subtype ~= nil then
            tileInfo = _ui.stronghold
            SetStrongholdInfo(tileInfo,tileMsg.centerBuild.fortress.subtype,entryType,true)
        end    
    elseif entryType == Common_pb.SceneEntryType_MobaGate then
        if tileMsg ~= nil and tileMsg.mobaBuild ~= nil then
            tileInfo = _ui.mobaInfo
            SetMobaBaseInfo(tileInfo,tileMsg.mobaBuild.buidingid)
        end             
	elseif entryType == Common_pb.SceneEntryType_MobaCenter then
        if tileMsg ~= nil and tileMsg.mobaBuild ~= nil then
            tileInfo = _ui.mobaInfo
            SetMobaBaseInfo(tileInfo,tileMsg.mobaBuild.buidingid)
        end    
	elseif entryType == Common_pb.SceneEntryType_MobaArsenal then
        if tileMsg ~= nil and tileMsg.mobaBuild ~= nil then
            tileInfo = _ui.mobaInfo
            SetMobaBaseInfo(tileInfo,tileMsg.mobaBuild.buidingid)
        end  
	elseif entryType == Common_pb.SceneEntryType_MobaFort then
        if tileMsg ~= nil and tileMsg.mobaBuild ~= nil then
            tileInfo = _ui.mobaInfo
            SetMobaBaseInfo(tileInfo,tileMsg.mobaBuild.buidingid)
        end  
	elseif entryType == Common_pb.SceneEntryType_MobaInstitute then
        if tileMsg ~= nil and tileMsg.mobaBuild ~= nil then
            tileInfo = _ui.mobaInfo
            SetMobaBaseInfo(tileInfo,tileMsg.mobaBuild.buidingid)
        end  
	elseif entryType == Common_pb.SceneEntryType_MobaTransPlat then
        if tileMsg ~= nil and tileMsg.mobaBuild ~= nil then
            tileInfo = _ui.mobaInfo
            SetMobaBaseInfo(tileInfo,tileMsg.mobaBuild.buidingid)
        end    
	elseif entryType == Common_pb.SceneEntryType_MobaSmallBuild then
        if tileMsg ~= nil and tileMsg.mobaBuild ~= nil then
            tileInfo = _ui.mobaInfo
            SetMobaBaseInfo(tileInfo,tileMsg.mobaBuild.buidingid)
        end          
    end
    
	
	local btn_close = tileInfo.transform:Find("bg_info/close btn")
	if btn_close ~= nil then
		SetClickCallback(btn_close.gameObject, Hide)
	end
    if entryType ~= Common_pb.SceneEntryType_None and
        entryType ~= Common_pb.SceneEntryType_MobaGate and
        entryType ~= Common_pb.SceneEntryType_MobaCenter and
        entryType ~= Common_pb.SceneEntryType_MobaArsenal and
        entryType ~= Common_pb.SceneEntryType_MobaFort and
        entryType ~= Common_pb.SceneEntryType_MobaInstitute and
        entryType ~= Common_pb.SceneEntryType_MobaTransPlat and
        entryType ~= Common_pb.SceneEntryType_MobaSmallBuild
        then
        if entryType ~= Common_pb.SceneEntryType_Home or Skin.IsDefaultSkin(tileMsg.home.skin) then
            tileInfo.icon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", artSettingData.icon)
        else
            local itemData = Skin.GetItemDataList(tileMsg.home.skin)[1]
            if itemData ~= nil then
                tileInfo.icon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", itemData.icon)
            end
        end
    end
    local offset_x,offset_y = MobaMain.MobaMinPos()    
    tileInfo.coordLabel.text = string.format("X:%d Y:%d", mapX-offset_x, mapY-offset_y)
    if entryType == Common_pb.SceneEntryType_Govt  then
        tileInfo.coordLabel.text = string.format("X:%d Y:%d", 176, 176)
    elseif entryType == Common_pb.SceneEntryType_Stronghold  then
        tileInfo.coordLabel.text = string.format("X:%d Y:%d", 
        tableData_tStrongholdRule.data[tileMsg.centerBuild.stronghold.subtype].Xcoord,
         tableData_tStrongholdRule.data[tileMsg.centerBuild.stronghold.subtype].Ycoord)
    elseif entryType == Common_pb.SceneEntryType_Fortress  then
        tileInfo.coordLabel.text = string.format("X:%d Y:%d", 
        tableData_tFortressRule.data[tileMsg.centerBuild.fortress.subtype].Xcoord,
        tableData_tFortressRule.data[tileMsg.centerBuild.fortress.subtype].Ycoord)
    end
    Update()
end

local function MapHelpCallback()
	MapHelp.Open(401,false , GetInterface("MapHelpCallback")() , false)
end

GuildTeleportClickCallback = function()
    local item = 0
    local transType = 0
    local buy = false
    local center = maincity.GetBuildingByID(1)
	
	local levelCon = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.NewbieShieldLevel).value)
	if WorldBorderData.IsSelfBorder(mapX, mapY) then
		print("WorldBorderData.IsSelfBorder ",mapX, mapY)
		if ItemListData.GetItemDataByBaseId(4101) and center.data.level < levelCon then--新手
            transType = MapMsg_pb.TranslateType_NewBie
            item = 4101
        elseif ItemListData.GetItemDataByBaseId(4401) then--领地
            transType = MapMsg_pb.TranslateType_Field
            item = 4401
        elseif ItemListData.GetItemDataByBaseId(4301) then--定点
            transType = MapMsg_pb.TranslateType_Fixed
            item = 4301
        else 									 --首先默认购买领地传送券
            transType = MapMsg_pb.TranslateType_Field 
            item = 4401
        end
    else--空地
        if ItemListData.GetItemDataByBaseId(4101) and center.data.level < levelCon then--新手
            transType = MapMsg_pb.TranslateType_NewBie
            item = 4101
        else											--默认定点传送券
            transType = MapMsg_pb.TranslateType_Fixed
            item = 4301
        end
    end
	transType = MapMsg_pb.TranslateType_Fixed
    item = 4303

    local dotransfer = function()
		print("isSelfLand",isSelfLand)
		if isSelfLand or GuildWarMain.IsInActiveTransPlat(mapX,mapY)== true then 
			local req = GuildMobaMsg_pb.GuildMobaHomeTranslateRequest()
			  --  req.type = transType
				req.tarpos.x = mapX
				req.tarpos.y = mapY
				local offsetx,offsety = GuildWarMain.MobaMinPos()
				req.tarpos.x = req.tarpos.x - offsetx
				req.tarpos.y = req.tarpos.y - offsety
				
			--	req.buy = false
				req.useGold = true
				local itemdata = MobaItemData.GetItemDataByBaseId(4303)
				if itemdata ~= nil then 
					if MobaMainData.GetData().data.mobaScore < itemdata.needScore  then 
						--req.useGold = true
					end 
				end 

				Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaHomeTranslateRequest, req, GuildMobaMsg_pb.GuildMobaHomeTranslateResponse, function(msg)
					if msg.code == ReturnCode_pb.Code_OK then
						 WorldMapData.SetMyBaseTileData(msg.homeinfo)
						 MobaMainData.GetData().pos.x = req.tarpos.x
						  MobaMainData.GetData().pos.y = req.tarpos.y
						local myBasePos = MapInfoData.GetMyBasePos()
						GuildWarMain.LookAt(myBasePos.x, myBasePos.y,true)
						if buy then
							GUIMgr:SendDataReport("purchase", "costgold", "item:"..item, "1", "" ..MoneyListData.ComputeDiamond(msg.fresh.money.money))
						else
							GUIMgr:SendDataReport("purchase", "useitem", tostring(item), "1")
						end
						local itData = TableMgr:GetItemData(item)
						local nameColor = Global.GetLabelColorNew(itData.quality)
						local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itData)..nameColor[1])
						--FloatText.Show(showText , Color.white , ResourceLibrary:GetIcon("Item/", itData.icon))
						Global.GAudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
						MainCityUI.UpdateRewardData(msg.fresh)
						Hide()
						WorldMapMgr.Instance:PlayEffect(mapX, mapY, 2, 5)
					else
						print("dddd",msg.code)
						Global.ShowError(msg.code)
					end
				end, true)
		else
			print("QuickUseItem 4303 1 ")
			QuickUseItem.Show(item, function(buy)
				print("QuickUseItem 4303")
				local req = GuildMobaMsg_pb.GuildMobaHomeTranslateRequest()
			  --  req.type = transType
				req.tarpos.x = mapX
				req.tarpos.y = mapY
				local offsetx,offsety = GuildWarMain.MobaMinPos()
				req.tarpos.x = req.tarpos.x - offsetx
				req.tarpos.y = req.tarpos.y - offsety
				
				req.useGold = true
				local itemdata = MobaItemData.GetItemDataByBaseId(4303)
				if itemdata ~= nil then 
					if MobaMainData.GetData().data.mobaScore < itemdata.needScore  then 
					--	req.useGold = true
					end 
				end 

				Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaHomeTranslateRequest, req, GuildMobaMsg_pb.GuildMobaHomeTranslateResponse, function(msg)
					if msg.code == ReturnCode_pb.Code_OK then
						 WorldMapData.SetMyBaseTileData(msg.homeinfo)
						 MobaMainData.GetData().pos.x = req.tarpos.x
						  MobaMainData.GetData().pos.y = req.tarpos.y
						local myBasePos = MapInfoData.GetMyBasePos()
						GuildWarMain.LookAt(myBasePos.x, myBasePos.y,true)
						if buy then
							GUIMgr:SendDataReport("purchase", "costgold", "item:"..item, "1", "" ..MoneyListData.ComputeDiamond(msg.fresh.money.money))
						else
							GUIMgr:SendDataReport("purchase", "useitem", tostring(item), "1")
						end
						local itData = TableMgr:GetItemData(item)
						local nameColor = Global.GetLabelColorNew(itData.quality)
						local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itData)..nameColor[1])
						FloatText.Show(showText , Color.white , ResourceLibrary:GetIcon("Item/", itData.icon))
						Global.GAudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
						MainCityUI.UpdateRewardData(msg.fresh)
						Hide()
						WorldMapMgr.Instance:PlayEffect(mapX, mapY, 2, 5)
					else
						Global.ShowError(msg.code)
					end
				end, true)
			end)
		end 
    end
    MessageBox.ShowConfirmation(GuildWarMain.IsInRestrictArea(mapX,mapY) and BuffData.HasShield(), TextMgr:GetText("ControlZone_ui2"), function() -- 管制区取消护盾提醒
        MessageBox.ShowConfirmation(#(MobaActionListData.GetData()) > 0, TextMgr:GetText("ui_maphint_1"), function() -- 行军队列不为空提醒
            if MobaRadarData.IsPathToMe() then
                MessageBox.Show(TextMgr:GetText(Text.transfer_ui1), dotransfer, MessageBox.DoNothing)
            else
                dotransfer()
            end
        end)
    end)
end

--空地传送
TeleportClickCallback = function()
    local item = 0
    local transType = 0
    local buy = false
    local center = maincity.GetBuildingByID(1)
	
	local levelCon = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.NewbieShieldLevel).value)
	if WorldBorderData.IsSelfBorder(mapX, mapY) then
		print("WorldBorderData.IsSelfBorder ",mapX, mapY)
		if ItemListData.GetItemDataByBaseId(4101) and center.data.level < levelCon then--新手
            transType = MapMsg_pb.TranslateType_NewBie
            item = 4101
        elseif ItemListData.GetItemDataByBaseId(4401) then--领地
            transType = MapMsg_pb.TranslateType_Field
            item = 4401
        elseif ItemListData.GetItemDataByBaseId(4301) then--定点
            transType = MapMsg_pb.TranslateType_Fixed
            item = 4301
        else 									 --首先默认购买领地传送券
            transType = MapMsg_pb.TranslateType_Field 
            item = 4401
        end
    else--空地
        if ItemListData.GetItemDataByBaseId(4101) and center.data.level < levelCon then--新手
            transType = MapMsg_pb.TranslateType_NewBie
            item = 4101
        else											--默认定点传送券
            transType = MapMsg_pb.TranslateType_Fixed
            item = 4301
        end
    end
	transType = MapMsg_pb.TranslateType_Fixed
    item = 4302
    --管制区不可以传输
    -- if WorldMap.IsInRestrictArea(mapX,mapY) and BuffData.HasShield() then
    --     MessageBox.Show(TextMgr:GetText("ControlZone_ui2"), function()
    --         MessageBox.Show(TextMgr:GetText(Text.transfer_ui1), function()
    --             QuickUseItem.Show(item, function(buy)
    --                 local req = MapMsg_pb.HomeTranslateRequest()
    --                 req.type = transType
    --                 req.tarpos.x = mapX
    --                 req.tarpos.y = mapY
    --                 req.buy = buy

    --                 Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.HomeTranslateRequest, req, MapMsg_pb.HomeTranslateResponse, function(msg)
    --                     if msg.code == ReturnCode_pb.Code_OK then
    --                          WorldMapData.SetMyBaseTileData(msg.homeinfo)
    --                         local myBasePos = MapInfoData.GetMyBasePos()
    --                         WorldMap.LookAt(myBasePos.x, myBasePos.y)
    --                         if buy then
    --                             GUIMgr:SendDataReport("purchase", "costgold", "item:"..item, "1", "" ..MoneyListData.ComputeDiamond(msg.fresh.money.money))
    --                         else
    --                             GUIMgr:SendDataReport("purchase", "useitem", tostring(item), "1")
    --                         end
    --                         local itData = TableMgr:GetItemData(item)
    --                         local nameColor = Global.GetLabelColorNew(itData.quality)
    --                         local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itData)..nameColor[1])
    --                         FloatText.Show(showText , Color.white , ResourceLibrary:GetIcon("Item/", itData.icon))
    --                         Global.GAudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
    --                         MainCityUI.UpdateRewardData(msg.fresh)
    --                         Hide()
    --                         WorldMapMgr.Instance:PlayEffect(mapX, mapY, 2, 5)
    --                     else
    --                         Global.ShowError(msg.code)
    --                     end
    --                 end, true)
    --             end)
    --         end, MessageBox.DoNothing)
    --     end, MessageBox.DoNothing)
    -- else
    --     MessageBox.Show(TextMgr:GetText(Text.transfer_ui1), function()
    --         QuickUseItem.Show(item, function(buy)
    --             local req = MapMsg_pb.HomeTranslateRequest()
    --             req.type = transType
    --             req.tarpos.x = mapX
    --             req.tarpos.y = mapY
    --             req.buy = buy

    --             Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.HomeTranslateRequest, req, MapMsg_pb.HomeTranslateResponse, function(msg)
    --                 if msg.code == ReturnCode_pb.Code_OK then
    --                     WorldMapData.SetMyBaseTileData(msg.homeinfo)
    --                     local myBasePos = MapInfoData.GetMyBasePos()
    --                     WorldMap.LookAt(myBasePos.x, myBasePos.y)
    --                     if buy then
    --                         GUIMgr:SendDataReport("purchase", "costgold", "item:"..item, "1", "" ..MoneyListData.ComputeDiamond(msg.fresh.money.money))
    --                     else
    --                         GUIMgr:SendDataReport("purchase", "useitem", tostring(item), "1")
    --                     end

    --                     local itData = TableMgr:GetItemData(item)
    --                     local nameColor = Global.GetLabelColorNew(itData.quality)
    --                     local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itData)..nameColor[1])
    --                     FloatText.Show(showText , Color.white , ResourceLibrary:GetIcon("Item/", itData.icon))
    --                     Global.GAudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
    --                     MainCityUI.UpdateRewardData(msg.fresh)
    --                     Hide()
    --                     WorldMapMgr.Instance:PlayEffect(mapX, mapY, 2, 5)
    --                 else
    --                     Global.ShowError(msg.code)
    --                 end
    --             end, true)
    --         end)
    --     end, MessageBox.DoNothing)
    -- end

    --[[
    local gradeData = GetMapGradeData(mapX, mapY)
    if gradeData.id ~= 3 then
        MessageBox.Show(String.Format(TextMgr:GetText(Text.MapGrade_hint1), gradeData.baseLevel, TextMgr:GetText(gradeData.tileName)))
        return
    end
    --]]
    local dotransfer = function()
		print("isSelfLand",isSelfLand)
		if isSelfLand or MobaMain.IsInActiveTransPlat(mapX,mapY)== true then 
			local req = MobaMsg_pb.MsgMobaHomeTranslateRequest()
			  --  req.type = transType
				req.tarpos.x = mapX
				req.tarpos.y = mapY
				local offsetx,offsety = MobaMain.MobaMinPos()
				req.tarpos.x = req.tarpos.x - offsetx
				req.tarpos.y = req.tarpos.y - offsety
				
				req.buy = false
				req.useGold = false
				local itemdata = MobaItemData.GetItemDataByBaseId(4302)
				if itemdata ~= nil then 
					if MobaMainData.GetData().data.mobaScore < itemdata.needScore  then 
						req.useGold = true
					end 
				end 

				Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaHomeTranslateRequest, req, MobaMsg_pb.MsgMobaHomeTranslateResponse, function(msg)
					if msg.code == ReturnCode_pb.Code_OK then
						 WorldMapData.SetMyBaseTileData(msg.homeinfo)
						 MobaMainData.GetData().pos.x = req.tarpos.x
						  MobaMainData.GetData().pos.y = req.tarpos.y
						local myBasePos = MapInfoData.GetMyBasePos()
						MobaMain.LookAt(myBasePos.x, myBasePos.y,true)
						if buy then
							GUIMgr:SendDataReport("purchase", "costgold", "item:"..item, "1", "" ..MoneyListData.ComputeDiamond(msg.fresh.money.money))
						else
							GUIMgr:SendDataReport("purchase", "useitem", tostring(item), "1")
						end
						local itData = TableMgr:GetItemData(item)
						local nameColor = Global.GetLabelColorNew(itData.quality)
						local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itData)..nameColor[1])
						--FloatText.Show(showText , Color.white , ResourceLibrary:GetIcon("Item/", itData.icon))
						Global.GAudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
						MainCityUI.UpdateRewardData(msg.fresh)
						Hide()
						WorldMapMgr.Instance:PlayEffect(mapX, mapY, 2, 5)
					else
						print("dddd",msg.code)
						Global.ShowError(msg.code)
					end
				end, true)
		else
			QuickUseItem.Show(item, function(buy)
				local req = MobaMsg_pb.MsgMobaHomeTranslateRequest()
			  --  req.type = transType
				req.tarpos.x = mapX
				req.tarpos.y = mapY
				local offsetx,offsety = MobaMain.MobaMinPos()
				req.tarpos.x = req.tarpos.x - offsetx
				req.tarpos.y = req.tarpos.y - offsety
				
				req.buy = buy
				req.useGold = false
				local itemdata = MobaItemData.GetItemDataByBaseId(4302)
				if itemdata ~= nil then 
					if MobaMainData.GetData().data.mobaScore < itemdata.needScore  then 
						req.useGold = true
					end 
				end 

				Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaHomeTranslateRequest, req, MobaMsg_pb.MsgMobaHomeTranslateResponse, function(msg)
					if msg.code == ReturnCode_pb.Code_OK then
						 WorldMapData.SetMyBaseTileData(msg.homeinfo)
						 MobaMainData.GetData().pos.x = req.tarpos.x
						  MobaMainData.GetData().pos.y = req.tarpos.y
						local myBasePos = MapInfoData.GetMyBasePos()
						MobaMain.LookAt(myBasePos.x, myBasePos.y,true)
						if buy then
							GUIMgr:SendDataReport("purchase", "costgold", "item:"..item, "1", "" ..MoneyListData.ComputeDiamond(msg.fresh.money.money))
						else
							GUIMgr:SendDataReport("purchase", "useitem", tostring(item), "1")
						end
						local itData = TableMgr:GetItemData(item)
						local nameColor = Global.GetLabelColorNew(itData.quality)
						local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itData)..nameColor[1])
						FloatText.Show(showText , Color.white , ResourceLibrary:GetIcon("Item/", itData.icon))
						Global.GAudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
						MainCityUI.UpdateRewardData(msg.fresh)
						Hide()
						WorldMapMgr.Instance:PlayEffect(mapX, mapY, 2, 5)
					else
						Global.ShowError(msg.code)
					end
				end, true)
			end)
		end 
    end
    MessageBox.ShowConfirmation(MobaMain.IsInRestrictArea(mapX,mapY) and BuffData.HasShield(), TextMgr:GetText("ControlZone_ui2"), function() -- 管制区取消护盾提醒
        MessageBox.ShowConfirmation(#(MobaActionListData.GetData()) > 0, TextMgr:GetText("ui_maphint_1"), function() -- 行军队列不为空提醒
            if MobaRadarData.IsPathToMe() then
                MessageBox.Show(TextMgr:GetText(Text.transfer_ui1), dotransfer, MessageBox.DoNothing)
            else
                dotransfer()
            end
        end)
    end)
end

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    Tooltip.HideStrongHoldBufftip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
    Tooltip.HideStrongHoldBufftip()
end

function Awake()
    _ui = {}
    _ui.bgPanel = transform:GetComponent("UIPanel")

    if WorldMapMonsterOnceEnergy == nil then
        WorldMapMonsterOnceEnergy = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.WorldMapMonsterOnceEnergy).value)
    end

    updateTimer = 0

    tileInfoMore = TileInfoMore(transform:Find("bg_more") , true)
    _ui.landMore = TileInfoMore(transform:Find("bg_more01") , true)

    WorldMapData.AddListener(LoadUI)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

local function LoadPlayerInfo()
	local prefab = ResourceLibrary.GetUIPrefab("Moba/MobaPlayerInfo")
	NGUITools.AddChild(gameObject, prefab).name = "PlayerInfo"
	local transform = transform

    local playerInfo = {}
    playerInfo.transform = transform:Find("PlayerInfo")
    playerInfo.bg = transform:Find("PlayerInfo/bg_info"):GetComponent("UISprite")
    playerInfo.icon = transform:Find("PlayerInfo/bg_info/bg_build/icon_castle"):GetComponent("UITexture")
    playerInfo.rankTexture = transform:Find("PlayerInfo/bg_info/bg_build/Texture"):GetComponent("UITexture")
	
    playerInfo.levelBg = transform:Find("PlayerInfo/bg_info/bg_level")
    playerInfo.levelLabel = transform:Find("PlayerInfo/bg_info/bg_level/name"):GetComponent("UILabel")
    playerInfo.nameLabel = transform:Find("PlayerInfo/bg_info/bg_date/txt_name"):GetComponent("UILabel")
    playerInfo.coordLabel = transform:Find("PlayerInfo/bg_info/bg_date/txt_num"):GetComponent("UILabel")
    playerInfo.help = transform:Find("PlayerInfo/bg_info/btn_help")
	transform:Find("PlayerInfo/bg_info/bg").gameObject:SetActive(false)
	playerInfo.btnInfo = transform:Find("PlayerInfo/bg_info/info")
    local wanted = {}
    local wantedTransform = transform:Find("PlayerInfo/wanted")
    wanted.transform = wantedTransform
    wanted.gameObject = wantedTransform.gameObject
    local moneyLabelList = {}
    for k, v in pairs(moneyTypeList) do
        moneyLabelList[k] = wantedTransform:Find(string.format("resource/%s/text_num", k)):GetComponent("UILabel")
    end
    wanted.moneyLabelList = moneyLabelList
    wanted.infoButton = wantedTransform:Find("button_info"):GetComponent("UIButton")
    playerInfo.wanted = wanted

	local prisonersPrefab = ResourceLibrary.GetUIPrefab("TileInfo/Prisoners")
	NGUITools.AddChild(gameObject, prisonersPrefab).name = "Prisoners"

    local prisoner = {}
    local prisonerTransform = transform:Find("Prisoners")
    prisoner.gameObject = prisonerTransform.gameObject
    prisoner.grid = prisonerTransform:Find("info/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
    prisoner.prefab = prisonerTransform:Find("info/bg_frane/bg_mid/Scroll View/Grid/list_prisoner").gameObject
    prisoner.helpObject = prisonerTransform:Find("info/bg_frane/bg_top/help").gameObject
    playerInfo.prisoner = prisoner
    prisoner.gameObject:SetActive(false)
    prisonerTransform:Find("info/bg_frane/bg_mid/Scroll View"):GetComponent("UIPanel").depth = _ui.bgPanel.depth + 1

	playerInfo.btnInfo.gameObject:SetActive(true)
	
    SetClickCallback(prisoner.helpObject, function(go)
        if go == _ui.tipObject then
            _ui.tipObject = nil
        else
            _ui.tipObject = go
            Tooltip.ShowItemTip({name = TextMgr:GetText(Text.help_ransom_tittle), text = TextMgr:GetText(Text.help_ransom)})
        end
    end)
    do
        local infoList = {}
        for i = 1, 2 do
            local info = {}
            info.transform = transform:Find(string.format("PlayerInfo/bg_info/bg_infomation/bg_%d", i))
            info.nameLabel = info.transform:Find("txt_title"):GetComponent("UILabel")
            info.valueLabel = info.transform:Find("txt_num"):GetComponent("UILabel")
            info.finishLabel = info.transform:Find("txt_finish"):GetComponent("UILabel")
            infoList[i] = info
        end
        playerInfo.infoList = infoList

        local buttonGroupList = {}
        for _, v in ipairs(playerButtonCountList) do
            local buttonGroup = {}
            buttonGroup.transform = transform:Find(string.format("PlayerInfo/bg_info/btn_%d", v))
            for j = 1, v do
                local group = {}
                group.button = buttonGroup.transform:Find("btn_"..j):GetComponent("UIButton")
                group.label = group.button.transform:Find("txt_3"):GetComponent("UILabel")
                buttonGroup[j] = group
            end
            if v == 3 then
                local group = {}
                local temp = buttonGroup.transform:Find("btn_"..4)
                if temp ~= nil then
                    group.button = temp:GetComponent("UIButton")
                    group.label = group.button.transform:Find("txt_3"):GetComponent("UILabel")
                    buttonGroup[4] = group 
                end
            end
            buttonGroupList[v] = buttonGroup
        end
        playerInfo.buttonGroupList = buttonGroupList
    end

    playerInfo.skinButton = transform:Find("PlayerInfo/bg_info/skin"):GetComponent("UIButton")

    SetClickCallback(playerInfo.bg.gameObject, Hide)
    _ui.playerInfo = playerInfo
end

local function LoadBlockInfo()
	local prefab = ResourceLibrary.GetUIPrefab("Moba/MobaBlockInfo")
	NGUITools.AddChild(gameObject, prefab).name = "BlockInfo"
	local transform = transform

    local blockInfo = {}
    blockInfo.transform = transform:Find("BlockInfo")
    blockInfo.bg = transform:Find("BlockInfo/bg_info"):GetComponent("UISprite")
    blockInfo.icon = transform:Find("BlockInfo/bg_info/bg_build/icon_castle"):GetComponent("UITexture")
    blockInfo.levelBg = transform:Find("BlockInfo/bg_info/bg_level")
    blockInfo.levelLabel = transform:Find("BlockInfo/bg_info/bg_level/name"):GetComponent("UILabel")
    blockInfo.nameLabel = transform:Find("BlockInfo/bg_info/bg_date/txt_name"):GetComponent("UILabel")
    blockInfo.nameBgSprite1 = transform:Find("BlockInfo/bg_info/title/Sprite"):GetComponent("UISprite")
    blockInfo.nameBgSprite2 = transform:Find("BlockInfo/bg_info/title/Sprite/Sprite (1)"):GetComponent("UISprite")
    blockInfo.unionLabel = transform:Find("BlockInfo/bg_info/bg_date/bg_union/txt_num"):GetComponent("UILabel")
    blockInfo.coordLabel = transform:Find("BlockInfo/bg_info/bg_date/txt_num"):GetComponent("UILabel")
    blockInfo.teleportButton = transform:Find("BlockInfo/bg_info/btn_2"):GetComponent("UIButton")
	blockInfo.teleportButtonLabel = transform:Find("BlockInfo/bg_info/btn_2/txt_2"):GetComponent("UILabel")
	blockInfo.baseButton = transform:Find("BlockInfo/bg_info/btn_1"):GetComponent("UIButton")
    blockInfo.occupyButton = transform:Find("BlockInfo/bg_info/btn_3"):GetComponent("UIButton")
    blockInfo.moreButton = transform:Find("BlockInfo/bg_info/btn_4"):GetComponent("UIButton")
    blockInfo.help = transform:Find("BlockInfo/bg_info/btn_help")

    SetClickCallback(blockInfo.bg.gameObject, Hide)
    SetClickCallback(blockInfo.teleportButton.gameObject, MapHelpCallback)
	transform:Find("BlockInfo/bg_info/btn_2/txt_2"):GetComponent("LocalizeEx").enabled = false
	blockInfo.teleportButtonLabel.text =  TextMgr:GetText("ui_worldmap_3")
	blockInfo.baseButton.gameObject:SetActive(false)
	blockInfo.occupyButton.gameObject:SetActive(false)
    --驻扎空地
 --[[   SetClickCallback(blockInfo.baseButton.gameObject, function()
        MapHelp.Open(402, false, function()  
            local uid = tileMsg ~= nil and tileMsg.data.uid or 0
            MobaBattleMove.Show(Common_pb.TeamMoveType_Camp, uid, "", tileMsg ~= nil and tileMsg.data.pos.x or mapX,tileMsg ~= nil and tileMsg.data.pos.y or mapY, Hide)
        end, false)        
    end)
    --占领空地
    SetClickCallback(blockInfo.occupyButton.gameObject,
        function() 
            MapHelp.Open(403, false,
            function()
                if not UnionInfoData.HasUnion() then
                    MessageBox.Show(TextMgr:GetText(Text.occupy_ui4))        
                elseif WorldBorderData.IsSelfBorder(mapX, mapY) then
                    MessageBox.Show(TextMgr:GetText(Text.occupy_ui3))        
                elseif MobaMain.IsInRestrictArea(mapX, mapY) then
                    MessageBox.Show(TextMgr:GetText("ControlZone_ui3"))
                elseif not WorldBorderData.IsSelfNeighboringBorder(mapX, mapY) then
                    MessageBox.Show(TextMgr:GetText(Text.occupy_ui1))
                else
                    local uid = tileMsg ~= nil and tileMsg.data.uid or 0
                    MobaBattleMove.Show(Common_pb.TeamMoveType_Occupy, uid, "", tileMsg ~= nil and tileMsg.data.pos.x or mapX,tileMsg ~= nil and tileMsg.data.pos.y or mapY, Hide)
                end
            end, false)
        end)]]--
    --空地更多
    SetClickCallback(blockInfo.moreButton.gameObject, function()
        --MessageBox.Show(TextMgr:GetText(Text.common_ui1))

        local artSettingData = TableMgr:GetArtSettingData(tileGid)
        --_ui.landMore:Open(blockInfo.moreButton.gameObject,TextMgr:GetText(artSettingData.name),mapX,mapY,artSettingData.icon)
		_ui.landMore:Open(blockInfo.moreButton.gameObject,TextMgr:GetText(artSettingData.name),mapX,mapY,TableMgr:GetMobaMapBuildingDataByID(999).Icon)
    end)

    _ui.blockInfo = blockInfo
end

local function LoadMonsterInfo()
	local prefab = ResourceLibrary.GetUIPrefab("Moba/MObaMonsterInfo")
	NGUITools.AddChild(gameObject, prefab).name = "MonsterInfo"
	local transform = transform

    local monsterInfo = {}
    monsterInfo.transform = transform:Find("MonsterInfo")
    monsterInfo.bg = transform:Find("MonsterInfo/bg_info"):GetComponent("UISprite")
    monsterInfo.icon = transform:Find("MonsterInfo/bg_info/bg_build/icon_castle"):GetComponent("UITexture")
    monsterInfo.levelBg = transform:Find("MonsterInfo/bg_info/bg_level")
    monsterInfo.levelLabel = transform:Find("MonsterInfo/bg_info/bg_level/name"):GetComponent("UILabel")
    monsterInfo.nameLabel = transform:Find("MonsterInfo/bg_info/bg_date/txt_name"):GetComponent("UILabel")
    monsterInfo.fleeLabel = transform:Find("MonsterInfo/bg_info/bg_date/bg_union/txt_num"):GetComponent("UILabel")
    monsterInfo.coordLabel = transform:Find("MonsterInfo/bg_info/bg_date/txt_num"):GetComponent("UILabel")
    monsterInfo.energyLabel = transform:Find("MonsterInfo/bg_info/bg_jindu/bg_progress/Label"):GetComponent("UILabel")
    monsterInfo.energySlider = transform:Find("MonsterInfo/bg_info/bg_jindu/bg_progress/icon_progress"):GetComponent("UISlider")
    monsterInfo.btn_add = transform:Find("MonsterInfo/bg_info/btn_add").gameObject
    monsterInfo.help = transform:Find("MonsterInfo/bg_info/btn_help")
	monsterInfo.btn_coord = transform:Find("MonsterInfo/bg_info/btn_coord")
    monsterInfo.rewardLabel = transform:Find("MonsterInfo/bg_info/bg_rewards/bg_title/text"):GetComponent("UILabel")
    monsterInfo.rewardGrid = transform:Find("MonsterInfo/bg_info/bg_rewards/Scroll View/Grid"):GetComponent("UIGrid")
    monsterInfo.suggestPower = transform:Find("MonsterInfo/bg_info/bg_date/bg_combat/txt_num"):GetComponent("UILabel")
    monsterInfo.hpBar = transform:Find("MonsterInfo/bg_info/bg_build/blood/red"):GetComponent("UISlider")
    monsterInfo.hpPercentage = transform:Find("MonsterInfo/bg_info/bg_build/blood/Label"):GetComponent("UILabel")
    monsterInfo.energySprite = transform:Find("MonsterInfo/bg_info/bg_jindu/Sprite"):GetComponent("UISprite")
    monsterInfo.energyTipObject = transform:Find("MonsterInfo/bg_info/bg_jindu/bg").gameObject
    monsterInfo.energyLabel1 = transform:Find("MonsterInfo/bg_info/bg_jindu/bg/Label (1)"):GetComponent("UILabel")
    monsterInfo.energyLabel2 = transform:Find("MonsterInfo/bg_info/bg_jindu/bg/Label"):GetComponent("UILabel")
	monsterInfo.cornerLB = transform:Find("MonsterInfo/bg_info/corner/corner (3)")
	monsterInfo.cornerRB = transform:Find("MonsterInfo/bg_info/corner/corner (2)")
	--monsterInfo.sweepDes = transform:Find("MonsterInfo/bg_info/info/vip"):GetComponent("UILabel")
	--monsterInfo.sweepTimeLabel = transform:Find("MonsterInfo/bg_info/info/bg/number"):GetComponent("UILabel")
	--monsterInfo.sweepTimeBg = transform:Find("MonsterInfo/bg_info/info/bg")
	--monsterInfo.sweepInfo = transform:Find("MonsterInfo/bg_info/info")
	
    transform:Find("MonsterInfo/bg_info/bg_rewards/Scroll View"):GetComponent("UIPanel").depth = _ui.bgPanel.depth + 1
	
    do
        local buttonGroupList = {}
        for _, v in ipairs(monsterButtonCountList) do
            local buttonGroup = {}
            buttonGroup.transform = transform:Find(string.format("MonsterInfo/bg_info/btn_%d", v))
			buttonGroup.info = buttonGroup.transform:Find("info")
            for j = 1, v do
                local group = {}
                group.button = buttonGroup.transform:Find("btn_"..j):GetComponent("UIButton")
                group.label = group.button.transform:Find("txt_3"):GetComponent("UILabel")

                local staminaTransform = group.button.transform:Find("Label")
                if staminaTransform then
                	group.stamina = group.button.transform:Find("Label"):GetComponent("UILabel")
                end

                buttonGroup[j] = group
            end
            buttonGroupList[v] = buttonGroup
        end

        monsterInfo.buttonGroupList = buttonGroupList
    end
    _ui.monsterInfo = monsterInfo
    SetClickCallback(_ui.monsterInfo.bg.gameObject, Hide)
end


local function LoadMobaBuildingInfo()

	local prefab = ResourceLibrary.GetUIPrefab("Moba/MobaBuilding")
	NGUITools.AddChild(gameObject, prefab).name = "MobaBuilding"
	local transform = transform

    local mobaInfo = {}
    mobaInfo.transform = transform:Find("MobaBuilding")
    mobaInfo.bg = transform:Find("MobaBuilding/bg_info"):GetComponent("UISprite")
    mobaInfo.bg_collider = transform:Find("MobaBuilding/bg_info/bg")
    mobaInfo.titleBg = transform:Find("MobaBuilding/bg_info/bg_title"):GetComponent("UISprite")
    mobaInfo.title = transform:Find("MobaBuilding/bg_info/bg_title/txt_name"):GetComponent("UILabel")


    mobaInfo.icon = transform:Find("MobaBuilding/bg_info/bg_build/icon_castle"):GetComponent("UITexture")

    mobaInfo.stateLabel = transform:Find("MobaBuilding/bg_info/bg_date/rebel"):GetComponent("UILabel")
    mobaInfo.coordLabel = transform:Find("MobaBuilding/bg_info/bg_date/txt_num"):GetComponent("UILabel")
	mobaInfo.main_stateLabel = transform:Find("MobaBuilding/bg_info/bg_date/Label"):GetComponent("UILabel")
    mobaInfo.main_stateTimeLabel = transform:Find("MobaBuilding/bg_info/bg_date/time"):GetComponent("UILabel")

    mobaInfo.help = transform:Find("MobaBuilding/bg_info/btn_help")

    mobaInfo.defence = transform:Find("MobaBuilding/bg_info/defence")
    mobaInfo.defence_progress_sprite = transform:Find("MobaBuilding/bg_info/defence/jindu/Sprite"):GetComponent("UISprite")
    mobaInfo.defence_progress = transform:Find("MobaBuilding/bg_info/defence/jindu/Label"):GetComponent("UILabel")
    mobaInfo.defence_state_Label = transform:Find("MobaBuilding/bg_info/defence/time"):GetComponent("UILabel")
	
	
	
    mobaInfo.rewards = transform:Find("MobaBuilding/bg_info/bg_rewards")
    mobaInfo.rewards_grid = transform:Find("MobaBuilding/bg_info/bg_rewards/Stronghold/dailyrewards/Scroll View/Grid"):GetComponent("UIGrid")

    mobaInfo.mid = {}
    mobaInfo.mid.root =  transform:Find("MobaBuilding/bg_info/mid")
    mobaInfo.mid.player_name = transform:Find("MobaBuilding/bg_info/mid/number1"):GetComponent("UILabel")
    mobaInfo.mid.nums = transform:Find("MobaBuilding/bg_info/mid/number2"):GetComponent("UILabel")

    mobaInfo.mid1 = {}
    mobaInfo.mid1.root =  transform:Find("MobaBuilding/bg_info/mid_1")
    mobaInfo.mid1.player_name = transform:Find("MobaBuilding/bg_info/mid_1/number1"):GetComponent("UILabel")
    mobaInfo.mid1.nums = transform:Find("MobaBuilding/bg_info/mid_1/number2"):GetComponent("UILabel")   
    
    mobaInfo.mid2 = {}
    mobaInfo.mid2.root =  transform:Find("MobaBuilding/bg_info/mid_2")
    mobaInfo.mid2.enemy_root = transform:Find("MobaBuilding/bg_info/mid_2/Stronghold/enemy")

    transform:Find("MobaBuilding/bg_info/bg_rewards/title").gameObject:SetActive(false)
    
    mobaInfo.friendly = transform:Find("MobaBuilding/bg_info/btn_4")
    mobaInfo.friendly_garrison = transform:Find("MobaBuilding/bg_info/btn_4/btn_4")
    mobaInfo.friendly_check_garrison = transform:Find("MobaBuilding/bg_info/btn_4/btn_2")
    mobaInfo.friendly_formation = transform:Find("MobaBuilding/bg_info/btn_4/btn_1")
    mobaInfo.friendly_share = transform:Find("MobaBuilding/bg_info/btn_4/btn_3")
    mobaInfo.hostile = transform:Find("MobaBuilding/bg_info/btn_5")
    mobaInfo.hostile_scout = transform:Find("MobaBuilding/bg_info/btn_5/btn_2")
    mobaInfo.hostile_attack = transform:Find("MobaBuilding/bg_info/btn_5/btn_1")
    mobaInfo.hostile_mass = transform:Find("MobaBuilding/bg_info/btn_5/btn_4")
    mobaInfo.hostile_share = transform:Find("MobaBuilding/bg_info/btn_5/btn_3")

    _ui.mobaInfo = mobaInfo 
    SetClickCallback(_ui.mobaInfo.bg.gameObject, Hide)
       
end

local function LoadResourceInfo()
	local prefab = ResourceLibrary.GetUIPrefab("TileInfo/Resinfo")
	NGUITools.AddChild(gameObject, prefab).name = "Resinfo"
	local transform = transform

    local resourceInfo = {}
    resourceInfo.transform = transform:Find("Resinfo")
    resourceInfo.bg = transform:Find("Resinfo/bg_info"):GetComponent("UISprite")
    resourceInfo.icon = transform:Find("Resinfo/bg_info/bg_build/icon_castle"):GetComponent("UITexture")
    resourceInfo.levelBg = transform:Find("Resinfo/bg_info/bg_level")
    resourceInfo.levelLabel = transform:Find("Resinfo/bg_info/bg_level/name"):GetComponent("UILabel")
    resourceInfo.nameLabel = transform:Find("Resinfo/bg_info/bg_date/txt_name"):GetComponent("UILabel")
    resourceInfo.unionLabel = transform:Find("Resinfo/bg_info/bg_date/bg_union/txt_num"):GetComponent("UILabel")
    resourceInfo.coordLabel = transform:Find("Resinfo/bg_info/bg_date/txt_num"):GetComponent("UILabel")
    resourceInfo.help = transform:Find("Resinfo/bg_info/btn_help")

    do
        local infoList = {}
        for i = 1, 3 do
            local info = {}
            info.transform = transform:Find(string.format("Resinfo/bg_info/bg_infomation/bg_%d", i))
            info.nameLabel = info.transform:Find("txt_title"):GetComponent("UILabel")
            info.valueLabel = info.transform:Find("txt_num"):GetComponent("UILabel")
            if i == 3 then
            	info.progressBar = info.transform:Find("bg_exp/bg/bar"):GetComponent("UISlider")
            end
            infoList[i] = info
        end
        resourceInfo.infoList = infoList

        local buttonGroupList = {}
        for _, v in ipairs(resourceButtonCountList) do
            local buttonGroup = {}
            buttonGroup.transform = transform:Find(string.format("Resinfo/bg_info/bg_%dbtn", v))
            for j = 1, v do
                local group = {}
                group.button = buttonGroup.transform:Find("btn_"..j):GetComponent("UIButton")
                group.label = group.button.transform:Find("txt_3"):GetComponent("UILabel")
                buttonGroup[j] = group
            end
            buttonGroupList[v] = buttonGroup
        end

        resourceInfo.buttonGroupList = buttonGroupList
    end

    _ui.resourceInfo = resourceInfo
    SetClickCallback(_ui.resourceInfo.bg.gameObject, Hide)
end

local function LoadRebelInfo()
	local prefab = ResourceLibrary.GetUIPrefab("TileInfo/rebel")
	NGUITools.AddChild(gameObject, prefab).name = "rebel"
	local transform = transform

    local rebelInfo = {}
    rebelInfo.transform = transform:Find("rebel")
    rebelInfo.bg = transform:Find("rebel/bg_info")
    rebelInfo.icon = transform:Find("rebel/bg_info/bg_build/icon_castle"):GetComponent("UITexture")
    rebelInfo.nameLabel = transform:Find("rebel/bg_info/bg_date/txt_name"):GetComponent("UILabel")
    rebelInfo.coordLabel = transform:Find("rebel/bg_info/bg_date/txt_num"):GetComponent("UILabel")
    rebelInfo.fleeLabel = transform:Find("rebel/bg_info/bg_date/bg_union/txt_num"):GetComponent("UILabel")
    rebelInfo.finderLabel = transform:Find("rebel/bg_info/bg_date/finder/txt_num"):GetComponent("UILabel")
    rebelInfo.energyLabel = transform:Find("rebel/bg_info/bg_jindu/bg_progress/Label"):GetComponent("UILabel")
    rebelInfo.energySlider = transform:Find("rebel/bg_info/bg_jindu/bg_progress/icon_progress"):GetComponent("UISlider")
    rebelInfo.energyAddBtn = transform:Find("rebel/bg_info/bg_jindu/btn_add").gameObject
    rebelInfo.reconBtn = transform:Find("rebel/bg_info/btn_1").gameObject
    rebelInfo.actBtn = transform:Find("rebel/bg_info/btn_2").gameObject
    rebelInfo.actStamina = transform:Find("rebel/bg_info/btn_2/Label"):GetComponent("UILabel")
    rebelInfo.massBtn = transform:Find("rebel/bg_info/btn_3").gameObject
    rebelInfo.massStamina = transform:Find("rebel/bg_info/btn_3/Label"):GetComponent("UILabel")
    rebelInfo.moreBtn = transform:Find("rebel/bg_info/btn_4").gameObject
    rebelInfo.help = transform:Find("rebel/bg_info/btn_help")
    rebelInfo.rewardGrid = transform:Find("rebel/bg_info/bg_rewards/Scroll View/Grid"):GetComponent("UIGrid")
    rebelInfo.suggestPower = transform:Find("rebel/bg_info/bg_date/bg_combat/txt_num"):GetComponent("UILabel")
    rebelInfo.hpBar = transform:Find("rebel/bg_info/bg_build/blood/red"):GetComponent("UISlider")
    rebelInfo.hpPercentage = transform:Find("rebel/bg_info/bg_build/blood/Label"):GetComponent("UILabel")
    rebelInfo.energySprite = transform:Find("rebel/bg_info/bg_jindu/bg_progress/Sprite"):GetComponent("UISprite")
    rebelInfo.energyTipObject = transform:Find("rebel/bg_info/bg_jindu/bg").gameObject
    rebelInfo.energyLabel1 = transform:Find("rebel/bg_info/bg_jindu/bg/Label (1)"):GetComponent("UILabel")
    rebelInfo.energyLabel2 = transform:Find("rebel/bg_info/bg_jindu/bg/Label"):GetComponent("UILabel")
    transform:Find("rebel/bg_info/bg_rewards/Scroll View"):GetComponent("UIPanel").depth = _ui.bgPanel.depth + 1
    _ui.rebelInfo = rebelInfo
    SetClickCallback(_ui.rebelInfo.bg.gameObject, Hide)
end

local function LoadUnionBuildingInfo()
	local prefab = ResourceLibrary.GetUIPrefab("TileInfo/UnionbuildingInfo")
	NGUITools.AddChild(gameObject, prefab).name = "UnionbuildingInfo"
	local transform = transform

    local unionBuildingInfo = {}
    unionBuildingInfo.transform = transform:Find("UnionbuildingInfo")
    unionBuildingInfo.bg = transform:Find("UnionbuildingInfo/bg_info"):GetComponent("UISprite")
    unionBuildingInfo.icon = transform:Find("UnionbuildingInfo/bg_info/bg_build/icon_castle"):GetComponent("UITexture")
    unionBuildingInfo.nameLabel = transform:Find("UnionbuildingInfo/bg_info/bg_date/txt_name"):GetComponent("UILabel")
    unionBuildingInfo.unionLabel = transform:Find("UnionbuildingInfo/bg_info/bg_date/bg_union/txt_num"):GetComponent("UILabel")
    unionBuildingInfo.coordLabel = transform:Find("UnionbuildingInfo/bg_info/bg_date/txt_num"):GetComponent("UILabel")

    do
        local infoList = {}
        for i = 1, 3 do
            local info = {}
            info.transform = transform:Find(string.format("UnionbuildingInfo/bg_info/bg_infomation/Grid/bg_%d", i))
            if i == 1 then
                info.stateLabel = info.transform:Find("text"):GetComponent("UILabel")
            end
            info.nameLabel = info.transform:Find("txt_title"):GetComponent("UILabel")
            info.valueLabel = info.transform:Find("txt_num"):GetComponent("UILabel")
            infoList[i] = info
        end
        unionBuildingInfo.infoList = infoList
        unionBuildingInfo.infoBg = transform:Find("UnionbuildingInfo/bg_info/bg_infomation"):GetComponent("UIWidget")
        unionBuildingInfo.infoGrid = transform:Find("UnionbuildingInfo/bg_info/bg_infomation/Grid"):GetComponent("UIGrid")
        unionBuildingInfo.infoHeight = unionBuildingInfo.infoGrid.cellHeight

        local buttonGroupList = {}
        for _, v in ipairs(unionBuildingButtonCountList) do
            local buttonGroup = {}
            buttonGroup.transform = transform:Find(string.format("UnionbuildingInfo/bg_info/btn_%d", v))
            for j = 1, v do
                local group = {}
                group.button = buttonGroup.transform:Find("btn_"..j):GetComponent("UIButton")
                group.label = group.button.transform:Find("txt_3"):GetComponent("UILabel")
                buttonGroup[j] = group
            end
            buttonGroupList[v] = buttonGroup
        end
        unionBuildingInfo.buttonGroupList = buttonGroupList
    end

    _ui.unionBuildingInfo = unionBuildingInfo
    SetClickCallback(_ui.unionBuildingInfo.bg.gameObject, Hide)

end

local function LoadGuildMonster()
	local prefab = ResourceLibrary.GetUIPrefab("TileInfo/RebelBase")
	NGUITools.AddChild(gameObject, prefab).name = "RebelBase"
	local transform = transform

    local guildMonster = {}
    guildMonster.transform = transform:Find("RebelBase")
    guildMonster.bg = transform:Find("RebelBase/bg_info"):GetComponent("UISprite")
    guildMonster.icon = transform:Find("RebelBase/bg_info/bg_build/icon_castle"):GetComponent("UITexture")
    guildMonster.level = transform:Find("RebelBase/bg_info/bg_level/name"):GetComponent("UILabel")
    guildMonster.nameLabel = transform:Find("RebelBase/bg_info/bg_date/txt_name"):GetComponent("UILabel")
    guildMonster.coordLabel = transform:Find("RebelBase/bg_info/bg_date/txt_num"):GetComponent("UILabel")
    guildMonster.guildname = transform:Find("RebelBase/bg_info/bg_date/bg_union/txt_num"):GetComponent("UILabel")
    guildMonster.infobg1 = transform:Find("RebelBase/bg_info/bg_infomation/bg_1/txt_num"):GetComponent("UILabel")
    guildMonster.infobg2 = transform:Find("RebelBase/bg_info/bg_infomation/bg_2/txt_num"):GetComponent("UILabel")
    guildMonster.infobgTitle1 = transform:Find("RebelBase/bg_info/bg_infomation/bg_1/txt_title"):GetComponent("UILabel")
    guildMonster.infobgTitle2 = transform:Find("RebelBase/bg_info/bg_infomation/bg_2/txt_title"):GetComponent("UILabel")
    guildMonster.bg2Btn = transform:Find("RebelBase/bg_info/bg_2btn").gameObject
    guildMonster.level1_attack = transform:Find("RebelBase/bg_info/bg_2btn/btn_1").gameObject
    guildMonster.level1_more = transform:Find("RebelBase/bg_info/bg_2btn/btn_2").gameObject
    guildMonster.bg4Btn = transform:Find("RebelBase/bg_info/bg_4btn").gameObject
    guildMonster.reconBtn = transform:Find("RebelBase/bg_info/bg_4btn/btn_1").gameObject
    guildMonster.actBtn = transform:Find("RebelBase/bg_info/bg_4btn/btn_2").gameObject
    guildMonster.massBtn = transform:Find("RebelBase/bg_info/bg_4btn/btn_3").gameObject
    guildMonster.moreBtn = transform:Find("RebelBase/bg_info/bg_4btn/btn_4").gameObject
    guildMonster.fleeLabel = transform:Find("RebelBase/bg_info/bg_infomation/bg_3/txt_num"):GetComponent("UILabel")
	do
	
		local buttonGroupList = {}
        for _, v in ipairs(unionMonsterButtonCountList) do
            local buttonGroup = {}
            buttonGroup.transform = transform:Find(string.format("RebelBase/bg_info/bg_%dbtn", v))
            for j = 1, v do
                local group = {}
                group.button = buttonGroup.transform:Find("btn_"..j):GetComponent("UIButton")
                group.label = group.button.transform:Find("txt_3"):GetComponent("UILabel")
                buttonGroup[j] = group
            end
            buttonGroupList[v] = buttonGroup
        end
        guildMonster.buttonGroupList = buttonGroupList
	end
		
    SetClickCallback(guildMonster.bg.gameObject, Hide)

    _ui.guildMonster = guildMonster
end

local function LoadPveMonster()
	local prefab = ResourceLibrary.GetUIPrefab("TileInfo/PveMonsterInfo")
	NGUITools.AddChild(gameObject, prefab).name = "PveMonsterInfo"
	local transform = transform

	local pveMonster = {}
	pveMonster.transform = transform:Find("PveMonsterInfo")
    pveMonster.bg = transform:Find("PveMonsterInfo/bg_info")
    pveMonster.icon = transform:Find("PveMonsterInfo/bg_info/bg_build/icon_castle"):GetComponent("UITexture")
    pveMonster.level = transform:Find("PveMonsterInfo/bg_info/bg_level/name"):GetComponent("UILabel")
    pveMonster.nameLabel = transform:Find("PveMonsterInfo/bg_info/bg_date/txt_name"):GetComponent("UILabel")
    pveMonster.coordLabel = transform:Find("PveMonsterInfo/bg_info/bg_date/txt_num"):GetComponent("UILabel")
    pveMonster.fleeLabel = transform:Find("PveMonsterInfo/bg_info/bg_date/bg_union/txt_num"):GetComponent("UILabel")
	pveMonster.monsterLife = transform:Find("PveMonsterInfo/bg_info/bg_jindu/bg_progress/icon_progress"):GetComponent("UISlider")
	pveMonster.monsterLifeLab = transform:Find("PveMonsterInfo/bg_info/bg_jindu/bg_progress/Label"):GetComponent("UILabel")
    pveMonster.monsterChallenCount = transform:Find("PveMonsterInfo/bg_info/btn_add").gameObject
    pveMonster.rewardGrid = transform:Find("PveMonsterInfo/bg_info/bg_rewards/Scroll View/Grid"):GetComponent("UIGrid")
    pveMonster.btnAttack = transform:Find("PveMonsterInfo/bg_info/btn_2/btn_1").gameObject
    pveMonster.btnAttackLab = transform:Find("PveMonsterInfo/bg_info/btn_2/btn_1/txt_3"):GetComponent("UILabel")
    pveMonster.btnMore = transform:Find("PveMonsterInfo/bg_info/btn_2/btn_2").gameObject
    pveMonster.stamina = transform:Find("PveMonsterInfo/bg_info/btn_2/btn_1/Label"):GetComponent("UILabel")
    transform:Find("PveMonsterInfo/bg_info/bg_rewards/Scroll View"):GetComponent("UIPanel").depth = _ui.bgPanel.depth + 1
	
    SetClickCallback(pveMonster.bg.gameObject, Hide)

    _ui.pveMonster = pveMonster
end

local function LoadRebelArmyAttack()
	local prefab = ResourceLibrary.GetUIPrefab("TileInfo/RebelArmyAttack")
	NGUITools.AddChild(gameObject, prefab).name = "RebelArmyAttack"
	local transform = transform

	local rebelArmyAttack = {}
	rebelArmyAttack.transform = transform:Find("RebelArmyAttack")
	rebelArmyAttack.bg = transform:Find("RebelArmyAttack/bg_info")
	rebelArmyAttack.icon = transform:Find("RebelArmyAttack/bg_info/bg_build/icon_castle"):GetComponent("UITexture")
	rebelArmyAttack.coordLabel = transform:Find("RebelArmyAttack/bg_info/txt_num"):GetComponent("UILabel")
	rebelArmyAttack.opened = {}
	rebelArmyAttack.opened.go = transform:Find("RebelArmyAttack/bg_info/bg_date").gameObject
	rebelArmyAttack.opened.text_title = transform:Find("RebelArmyAttack/bg_info/bg_date/text_title"):GetComponent("UILabel")
	rebelArmyAttack.opened.text_power = transform:Find("RebelArmyAttack/bg_info/bg_date/text_power"):GetComponent("UILabel")
	rebelArmyAttack.opened.title_time = transform:Find("RebelArmyAttack/bg_info/bg_date/title_time"):GetComponent("UILabel")
	rebelArmyAttack.opened.text_time = transform:Find("RebelArmyAttack/bg_info/bg_date/text_time"):GetComponent("UILabel")
	rebelArmyAttack.notopen = {}
	rebelArmyAttack.notopen.go = transform:Find("RebelArmyAttack/bg_info/bg_date (1)").gameObject
	rebelArmyAttack.notopen.title_time = transform:Find("RebelArmyAttack/bg_info/bg_date (1)/title_time"):GetComponent("UILabel")
	rebelArmyAttack.notopen.text_time = transform:Find("RebelArmyAttack/bg_info/bg_date (1)/text_time"):GetComponent("UILabel")
	rebelArmyAttack.btn_group = {}
	for i = 2, 3 do
		local group = {}
		for ii = 1, i do
			group[ii] = transform:Find(string.format("RebelArmyAttack/bg_info/btn_%d/btn_%d", i, ii))
		end
		rebelArmyAttack.btn_group[i] = group
	end
	SetClickCallback(rebelArmyAttack.bg.gameObject, Hide)
    
    _ui.rebelArmyAttack = rebelArmyAttack
end

local function LoadGovernmentInfo()
	local prefab = ResourceLibrary.GetUIPrefab("TileInfo/Government")
	NGUITools.AddChild(gameObject, prefab).name = "Government"
	local transform = transform

    local governmentInfo = {}
    governmentInfo.transform = transform:Find("Government")
    governmentInfo.help = transform:Find("Government/bg_info/btn_help")
    governmentInfo.titleBg = transform:Find("Government/bg_info/bg_title"):GetComponent("UISprite")
    governmentInfo.title = transform:Find("Government/bg_info/bg_date/txt_name"):GetComponent("UILabel")
	governmentInfo.bg = transform:Find("Government/bg_info"):GetComponent("UISprite")
    governmentInfo.icon = transform:Find("Government/bg_info/bg_build/icon_castle"):GetComponent("UITexture")
    governmentInfo.flag = transform:Find("Government/bg_info/bg_build/icon_flag"):GetComponent("UITexture")
    governmentInfo.coordLabel = transform:Find("Government/bg_info/bg_date/txt_num"):GetComponent("UILabel")
    governmentInfo.stateLabel = transform:Find("Government/bg_info/bg_condition/txt"):GetComponent("UILabel")
    governmentInfo.stateTimeLabel = transform:Find("Government/bg_info/bg_condition/bg_time/time"):GetComponent("UILabel")
    governmentInfo.unionNameLabel = transform:Find("Government/bg_info/bg_date/bg_union/txt_num"):GetComponent("UILabel")
    governmentInfo.officialNameLabel = transform:Find("Government/bg_info/bg_date/bg_power/txt_num"):GetComponent("UILabel")
    governmentInfo.power= transform:Find("Government/bg_info/bg_date/bg_soldier")
    governmentInfo.powerLabel = transform:Find("Government/bg_info/bg_date/bg_soldier/txt_num"):GetComponent("UILabel")

    governmentInfo.noticeLabel = transform:Find("Government/bg_info/announcement/Scroll View/Label"):GetComponent("UILabel")
    transform:Find("Government/bg_info/announcement/Scroll View"):GetComponent("UIPanel").depth = _ui.bgPanel.depth + 1
    governmentInfo.noticeButton = transform:Find("Government/bg_info/announcement/editor btn"):GetComponent("UIButton")
    governmentInfo.editTransform = transform:Find("Government/bg_info/announcement/editor mask")
    governmentInfo.editInput = transform:Find("Government/bg_info/announcement/editor mask/input"):GetComponent("UIInput")
    governmentInfo.numLabel = transform:Find("Government/bg_info/announcement/editor mask/num"):GetComponent("UILabel")
    governmentInfo.cancelButton = transform:Find("Government/bg_info/announcement/editor mask/cancel btn"):GetComponent("UIButton")
    governmentInfo.confirmButton = transform:Find("Government/bg_info/announcement/editor mask/ok btn"):GetComponent("UIButton")

    governmentInfo.friendly = transform:Find("Government/bg_info/btn_4")
    governmentInfo.friendly_garrison = transform:Find("Government/bg_info/btn_4/btn_1")
    governmentInfo.friendly_check_garrison = transform:Find("Government/bg_info/btn_4/btn_2")
    governmentInfo.friendly_manage = transform:Find("Government/bg_info/btn_4/btn_4")
    governmentInfo.friendly_share = transform:Find("Government/bg_info/btn_4/btn_3")
    governmentInfo.hostile = transform:Find("Government/bg_info/btn_5")
    governmentInfo.hostile_scout = transform:Find("Government/bg_info/btn_5/btn_1")
    governmentInfo.hostile_attack = transform:Find("Government/bg_info/btn_5/btn_2")
    governmentInfo.hostile_check = transform:Find("Government/bg_info/btn_5/btn_3")
    governmentInfo.hostile_share = transform:Find("Government/bg_info/btn_5/btn_4")
    governmentInfo.hostile_mass = transform:Find("Government/bg_info/btn_5/btn_5")
	
	governmentInfo.transBg = transform:Find("Government/bg_info/announcement/bg_translate")
	governmentInfo.transBtn = transform:Find("Government/bg_info/announcement/bg_translate/btn_translate"):GetComponent("UIButton")
	governmentInfo.origeBtn = transform:Find("Government/bg_info/announcement/bg_translate/btn_orige"):GetComponent("UIButton")
    governmentInfo.transing = transform:Find("Government/bg_info/announcement/bg_translate/bg_traning")
    

    governmentInfo.rewards_items_grid = transform:Find("Government/bg_info/bg_rewards/Scroll View/Grid"):GetComponent("UIGrid")
    governmentInfo.rewards_items ={}
    local icon_paths ={"icon","icon (1)","icon (2)","icon (3)"}
    for i=1,4 do
        governmentInfo.rewards_items[i] = {}        
        governmentInfo.rewards_items[i].root = transform:Find("Government/bg_info/bg_rewards/Scroll View/Grid/"..icon_paths[i])
    end

    governmentInfo.info1 = transform:Find("Government/bg_info/bg_date/bg_power")
    governmentInfo.info2 = transform:Find("Government/bg_info/bg_date/bg_union")
    governmentInfo.info3 = transform:Find("Government/bg_info/bg_date/bg_soldier")
    governmentInfo.enemy_root = transform:Find("Government/bg_info/bg_enemy/bg/enemy")


    transform:Find("Government/bg_info/bg_rewards/Scroll View"):GetComponent("UIPanel").depth = _ui.bgPanel.depth + 1

	SetClickCallback(governmentInfo.transBtn.gameObject , function()
		governmentInfo.transBtn.gameObject:SetActive(false)
		governmentInfo.origeBtn.gameObject:SetActive(false)
		governmentInfo.transing.gameObject:SetActive(true)
		
		UnionInfo.Translate(annouceContent , 1)
	end)
	SetClickCallback(governmentInfo.origeBtn.gameObject , function()
		governmentInfo.transBtn.gameObject:SetActive(true)
		governmentInfo.origeBtn.gameObject:SetActive(false)
		governmentInfo.transing.gameObject:SetActive(false)
		
		UnionInfo.CheckSourceText(annouceContent)
	end)

    SetClickCallback(governmentInfo.bg.gameObject, Hide)
    governmentInfo.editInput.defaultText = TextMgr:GetText(Text.click_input)
    governmentInfo.characterLimit = governmentInfo.editInput.characterLimit
    EventDelegate.Add(governmentInfo.editInput.onChange, EventDelegate.Callback(function()
        UpdateGoveInputLimit()
    end))
    governmentInfo.noticeButton.gameObject:SetActive( GovernmentData.
    IsPrivilegeValid(MapData_pb.GovernmentPrivilege_EditNotice,MainData.GetGOVPrivilege()))

    --打开政府公告编辑
    SetClickCallback(governmentInfo.noticeButton.gameObject, function()
        ShowEditGoveNotice()
    end)

    --取消政府公告编辑
    SetClickCallback(governmentInfo.cancelButton.gameObject, function()
        governmentInfo.editTransform.gameObject:SetActive(false)
    end)

    --确认政府公告编辑
    SetClickCallback(governmentInfo.confirmButton.gameObject, function()
        local req = MapMsg_pb.MsgGovernmentEditNoticeRequest()
        req.notice = governmentInfo.editInput.value
		annouceContent.srcContent = governmentInfo.editInput.value
		governmentInfo.transBg.gameObject:SetActive(annouceContent.srcContent ~= nil and annouceContent.srcContent ~= "")
		
        Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgGovernmentEditNoticeRequest, req, MapMsg_pb.MsgGovernmentEditNoticeResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                GovernmentData.SetGoveNotice(governmentInfo.editInput.value)
                if _ui == nil then
                    return
                end
                governmentInfo.editTransform.gameObject:SetActive(false)
                
            else
                Global.ShowError(msg.code)
                if _ui == nil then
                    return
                end                
                local InfoMsg = GovernmentData.GetGovernmentData()
                governmentInfo.editInput.value = InfoMsg.notice
                
            end
        end, false)
    end)

    governmentInfo.help.gameObject:SetActive(true)
    SetClickCallback(governmentInfo.help.gameObject, function()
        GOV_Help.Show(GOV_Help.HelpModeType.GOVMODE)
    end)    

    _ui.governmentInfo = governmentInfo
end

local function LoadTurretInfo()
	local prefab = ResourceLibrary.GetUIPrefab("TileInfo/Battery")
	NGUITools.AddChild(gameObject, prefab).name = "Battery"
	local transform = transform

    local turretInfo = {}
    turretInfo.transform = transform:Find("Battery")
    turretInfo.bg = transform:Find("Battery/bg_info"):GetComponent("UISprite")
    turretInfo.help = transform:Find("Battery/bg_info/btn_help")
    turretInfo.titleBg = transform:Find("Battery/bg_info/bg_title"):GetComponent("UISprite")
    turretInfo.title = transform:Find("Battery/bg_info/bg_date/txt_name"):GetComponent("UILabel")
    turretInfo.icon = transform:Find("Battery/bg_info/bg_build/icon_castle"):GetComponent("UITexture")
    turretInfo.flag = transform:Find("Battery/bg_info/bg_build/icon_flag"):GetComponent("UITexture")
    turretInfo.coordLabel = transform:Find("Battery/bg_info/bg_date/txt_num"):GetComponent("UILabel")
    turretInfo.stateLabel = transform:Find("Battery/bg_info/bg_condition/txt"):GetComponent("UILabel")
    turretInfo.stateTimeLabel = transform:Find("Battery/bg_info/bg_condition/bg_time/time"):GetComponent("UILabel")
    turretInfo.unionNameLabel = transform:Find("Battery/bg_info/bg_date/bg_union/txt_num"):GetComponent("UILabel")
    turretInfo.officialNameLabel = transform:Find("Battery/bg_info/bg_date/bg_power/txt_num"):GetComponent("UILabel")
    turretInfo.power= transform:Find("Battery/bg_info/bg_date/bg_soldier")
    turretInfo.powerLabel = transform:Find("Battery/bg_info/bg_date/bg_soldier/txt_num"):GetComponent("UILabel")
    turretInfo.friendly = transform:Find("Battery/bg_info/btn_4")
    turretInfo.friendly_garrison = transform:Find("Battery/bg_info/btn_4/btn_1")
    turretInfo.friendly_check_garrison = transform:Find("Battery/bg_info/btn_4/btn_2")
    turretInfo.friendly_manage = transform:Find("Battery/bg_info/btn_4/btn_4")
    turretInfo.friendly_share = transform:Find("Battery/bg_info/btn_4/btn_3")
    turretInfo.hostile = transform:Find("Battery/bg_info/btn_5")
    turretInfo.hostile_scout = transform:Find("Battery/bg_info/btn_5/btn_1")
    turretInfo.hostile_attack = transform:Find("Battery/bg_info/btn_5/btn_2")
    turretInfo.hostile_check = transform:Find("Battery/bg_info/btn_5/btn_3")
    turretInfo.hostile_share = transform:Find("Battery/bg_info/btn_5/btn_4")
    turretInfo.hostile_mass = transform:Find("Battery/bg_info/btn_5/btn_5")


    turretInfo.info1 = transform:Find("Battery/bg_info/bg_date/bg_power")
    turretInfo.info2 = transform:Find("Battery/bg_info/bg_date/bg_union")
    turretInfo.enemy_root = transform:Find("Battery/bg_info/bg_enemy/bg/enemy")  
    transform:Find("Battery/bg_info/bg_enemy").gameObject:SetActive(true)  

    SetClickCallback(turretInfo.bg.gameObject, Hide)

    turretInfo.help.gameObject:SetActive(true)
    SetClickCallback(turretInfo.help.gameObject, function()
        GOV_Help.Show(GOV_Help.HelpModeType.TURRETMODE)
    end)        

    _ui.turretInfo = turretInfo
end

function LoadStronghold()
	local prefab = ResourceLibrary.GetUIPrefab("TileInfo/Stronghold")
	NGUITools.AddChild(gameObject, prefab).name = "Stronghold"
	local transform = transform

    local stronghold = {}
    stronghold.transform = transform:Find("Stronghold")
    stronghold.help = transform:Find("Stronghold/bg_info/btn_help")
    stronghold.titleBg = transform:Find("Stronghold/bg_info/bg_title"):GetComponent("UISprite")
    stronghold.title = transform:Find("Stronghold/bg_info/bg_date/txt_name"):GetComponent("UILabel")
	stronghold.bg = transform:Find("Stronghold/bg_info"):GetComponent("UISprite")
    stronghold.icon = transform:Find("Stronghold/bg_info/bg_build/icon_castle"):GetComponent("UITexture")
    stronghold.flag = transform:Find("Stronghold/bg_info/bg_build/icon_flag"):GetComponent("UITexture")
    stronghold.coordLabel = transform:Find("Stronghold/bg_info/bg_date/txt_num"):GetComponent("UILabel")
    stronghold.stateLabel = transform:Find("Stronghold/bg_info/bg_condition/txt"):GetComponent("UILabel")
    stronghold.stateTimeLabel = transform:Find("Stronghold/bg_info/bg_condition/bg_time/time"):GetComponent("UILabel")
    stronghold.unionNameLabel = transform:Find("Stronghold/bg_info/bg_date/bg_union/txt_num"):GetComponent("UILabel")
    stronghold.officialNameLabel = transform:Find("Stronghold/bg_info/bg_date/bg_power/txt_num"):GetComponent("UILabel")
    stronghold.power= transform:Find("Stronghold/bg_info/bg_date/bg_soldier")
    stronghold.powerLabel = transform:Find("Stronghold/bg_info/bg_date/bg_soldier/txt_num"):GetComponent("UILabel")
    if stronghold.unionNameLabel ~= nil then
        stronghold.unionNameLabel.gameObject:SetActive(false)
    end
    if stronghold.officialNameLabel ~= nil then
        stronghold.officialNameLabel.gameObject:SetActive(false)
    end
    if stronghold.powerLabel ~= nil then
        stronghold.powerLabel.gameObject:SetActive(false)
    end        


    stronghold.friendly = transform:Find("Stronghold/bg_info/btn_4")
    stronghold.friendly_garrison = transform:Find("Stronghold/bg_info/btn_4/btn_1")
    stronghold.friendly_check_garrison = transform:Find("Stronghold/bg_info/btn_4/btn_2")
    stronghold.friendly_manage = transform:Find("Stronghold/bg_info/btn_4/btn_4")
    stronghold.friendly_share = transform:Find("Stronghold/bg_info/btn_4/btn_3")
    stronghold.hostile = transform:Find("Stronghold/bg_info/btn_5")
    stronghold.hostile_scout = transform:Find("Stronghold/bg_info/btn_5/btn_1")
    stronghold.hostile_attack = transform:Find("Stronghold/bg_info/btn_5/btn_2")
    stronghold.hostile_mass = transform:Find("Stronghold/bg_info/btn_5/btn_3")
    stronghold.hostile_share = transform:Find("Stronghold/bg_info/btn_5/btn_4")
    stronghold.hostile_check = transform:Find("Stronghold/bg_info/btn_5/btn_5")

    stronghold.rewards = transform:Find("Stronghold/bg_info/bg_rewards")
    stronghold.dailyrewards_stronghold_grid = transform:Find("Stronghold/bg_info/bg_rewards/Stronghold/dailyrewards/Scroll View/Grid"):GetComponent("UIGrid")
    stronghold.rewards_stronghold = transform:Find("Stronghold/bg_info/bg_rewards/Stronghold")
    stronghold.rewards_stronghold_grid = transform:Find("Stronghold/bg_info/bg_rewards/Stronghold/Stronghold Scroll View/Grid"):GetComponent("UIGrid")
    stronghold.rewards_stronghold_items ={}
    local icon_paths ={"icon","icon (1)","icon (2)","icon (4)"}
    for i=1,4 do
        stronghold.rewards_stronghold_items[i] = {}
        stronghold.rewards_stronghold_items[i].root = transform:Find("Stronghold/bg_info/bg_rewards/Stronghold/Stronghold Scroll View/Grid/"..icon_paths[i])
        stronghold.rewards_stronghold_items[i].icon = transform:Find("Stronghold/bg_info/bg_rewards/Stronghold/Stronghold Scroll View/Grid/"..icon_paths[i].."/Texture"):GetComponent("UITexture")
    end

    transform:Find("Stronghold/bg_info/bg_rewards/Stronghold/Stronghold Scroll View").gameObject:SetActive(true)

    stronghold.rewards_fortress = transform:Find("Stronghold/bg_info/bg_rewards/fortress")
    stronghold.rewards_fortress_grid = transform:Find("Stronghold/bg_info/bg_rewards/fortress/fortress Scroll View/Grid"):GetComponent("UIGrid")
    stronghold.rewards_fortress_items ={}
    local icon_paths ={"icon","icon (1)","icon (2)","icon (3)"}
    for i=1,4 do
        stronghold.rewards_fortress_items[i] = {}        
        stronghold.rewards_fortress_items[i].root = transform:Find("Stronghold/bg_info/bg_rewards/fortress/fortress Scroll View/Grid/"..icon_paths[i])
        stronghold.rewards_fortress_items[i].icon = transform:Find("Stronghold/bg_info/bg_rewards/fortress/fortress Scroll View/Grid/"..icon_paths[i].."/Texture"):GetComponent("UITexture")
    end

    transform:Find("Stronghold/bg_info/bg_rewards/fortress/fortress Scroll View").gameObject:SetActive(true)

    stronghold.info_stornghold = {}
    stronghold.info_stornghold.root = transform:Find("Stronghold/bg_info/bg_enemy/Stronghold")
    stronghold.info_stornghold.officialNameLabel = transform:Find("Stronghold/bg_info/bg_enemy/Stronghold/info/bg_power/txt_num"):GetComponent("UILabel")
    stronghold.info_stornghold.unionNameLabel = transform:Find("Stronghold/bg_info/bg_enemy/Stronghold/info/bg_union/txt_num"):GetComponent("UILabel")
    stronghold.info_stornghold.power= transform:Find("Stronghold/bg_info/bg_enemy/Stronghold/info/bg_soldier")
    stronghold.info_stornghold.powerLabel = transform:Find("Stronghold/bg_info/bg_enemy/Stronghold/info/bg_soldier/txt_num"):GetComponent("UILabel")  
    stronghold.info_stornghold.enemy_root = transform:Find("Stronghold/bg_info/bg_enemy/Stronghold/enemy")
    stronghold.info_stornghold.info = transform:Find("Stronghold/bg_info/bg_enemy/Stronghold/info")

    stronghold.info_fortress = {}
    stronghold.info_fortress.root = transform:Find("Stronghold/bg_info/bg_enemy/fortress")
    stronghold.info_fortress.officialNameLabel = transform:Find("Stronghold/bg_info/bg_enemy/fortress/info/bg_power/txt_num"):GetComponent("UILabel")
    stronghold.info_fortress.unionNameLabel = transform:Find("Stronghold/bg_info/bg_enemy/fortress/info/bg_union/txt_num"):GetComponent("UILabel")
    stronghold.info_fortress.power= transform:Find("Stronghold/bg_info/bg_enemy/fortress/info/bg_soldier")
    stronghold.info_fortress.powerLabel = transform:Find("Stronghold/bg_info/bg_enemy/fortress/info/bg_soldier/txt_num"):GetComponent("UILabel")  
    stronghold.info_fortress.enemy_root = transform:Find("Stronghold/bg_info/bg_enemy/fortress/enemy")
    stronghold.info_fortress.info = transform:Find("Stronghold/bg_info/bg_enemy/fortress/info")

    

    transform:Find("Stronghold/bg_info/bg_rewards/Stronghold/Stronghold Scroll View"):GetComponent("UIPanel").depth = _ui.bgPanel.depth + 1
    transform:Find("Stronghold/bg_info/bg_rewards/fortress/fortress Scroll View"):GetComponent("UIPanel").depth = _ui.bgPanel.depth + 1
    transform:Find("Stronghold/bg_info/bg_rewards/Stronghold/dailyrewards/Scroll View"):GetComponent("UIPanel").depth = _ui.bgPanel.depth + 1
	
    SetClickCallback(stronghold.bg.gameObject, Hide)
    stronghold.help.gameObject:SetActive(true)
     
    _ui.stronghold = stronghold
end

function Start()
    if tileMsg == nil then
        LoadBlockInfo()
    else
		
        local entryType = tileMsg.data.entryType
        if entryType == Common_pb.SceneEntryType_Home or entryType == Common_pb.SceneEntryType_Barrack or entryType == Common_pb.SceneEntryType_Occupy then
            LoadPlayerInfo()
        elseif entryType == Common_pb.SceneEntryType_Monster then
            LoadMonsterInfo()
        elseif entryType >= Common_pb.SceneEntryType_ResFood and entryType <= Common_pb.SceneEntryType_ResElec then
            LoadResourceInfo()
        elseif entryType == Common_pb.SceneEntryType_ActMonster then
            if tileMsg.monster.guildMon.guildMonster then
                LoadGuildMonster()
            elseif tileMsg.monster.digMon.monsterBaseId > 0 then
                LoadPveMonster()
            else
                LoadRebelInfo()
            end
        elseif entryType == Common_pb.SceneEntryType_GuildBuild then
            LoadUnionBuildingInfo()
        elseif entryType == Common_pb.SceneEntryType_SiegeMonster then
            LoadRebelArmyAttack()
        elseif entryType == Common_pb.SceneEntryType_Govt then
            LoadGovernmentInfo()
        elseif entryType == Common_pb.SceneEntryType_Turret then
            LoadTurretInfo()
        elseif entryType == Common_pb.SceneEntryType_Stronghold or entryType == Common_pb.SceneEntryType_Fortress then
            LoadStronghold()
		elseif entryType == Common_pb.SceneEntryType_MobaGate  then
            LoadMobaBuildingInfo()
		elseif entryType == Common_pb.SceneEntryType_MobaCenter  then
            LoadMobaBuildingInfo()
		elseif entryType == Common_pb.SceneEntryType_MobaArsenal  then
            LoadMobaBuildingInfo()
        elseif entryType == Common_pb.SceneEntryType_MobaFort  then
            LoadMobaBuildingInfo()
		elseif entryType == Common_pb.SceneEntryType_MobaInstitute  then
            LoadMobaBuildingInfo()
		elseif entryType == Common_pb.SceneEntryType_MobaTransPlat  then
            LoadMobaBuildingInfo()        
		elseif entryType == Common_pb.SceneEntryType_MobaSmallBuild  then
            LoadMobaBuildingInfo()            			
        end
    end

    LoadUI()
end

function Show(msg, data, gid, x, y,zone)
    if MobaMain.TESTGOV then
        if msg ~= nil and msg.data.entryType == Common_pb.SceneEntryType_Turret then
            return
        end
    end
    print(string.format("tile uid:%d data id: %d, gid:%d", msg and msg.data.uid or 0, data and data.id or 0, gid))
    tileMsg = msg
    tileData = data
    tileGid = gid
	zoneData = zone
	mapX = x
    mapY = y
    Global.OpenUI(_M)
end

function Close()
    CountDown.Instance:Remove("Turret_State")
    CountDown.Instance:Remove("TileRebelArmyAttack")
    CountDown.Instance:Remove("Gov_State")
    CountDown.Instance:Remove("Hold_State")  

    CountDown.Instance:Remove("Moba_State")
    CountDown.Instance:Remove("Moba_Defence_State")  

    StrongholdData.CloseStrongholdUI()
    GovernmentData.RemoveEditStrategyListener(RefrushTurretTitle)
    GovernmentData.RemoveTurretRulingListener(DisposeTurretRulingPush)
    GovernmentData.RemoveGovRulingListener(DisposeGovRulingPush)  
    StrongholdData.RemoveHoldRulingListener(DisposeStrongholdPush) 
	FortressData.RemoveFortressRulingListener(DisposeFotressPush)
    WorldMapData.RemoveListener(LoadUI)
    if tileInfoMore ~= nil then
        tileInfoMore:Close()
        tileInfoMore = nil
    end
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
    _ui = nil
	annouceContent = nil
end

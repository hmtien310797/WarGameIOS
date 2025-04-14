module("MobaSelectHero_PVP", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local SetTooltipCallback = UIUtil.SetTooltipCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime
local AudioMgr = Global.GAudioMgr

local selectHeroData
local _ui
local timer = 0

local AUTO_SELECT_UNLOCK_MISSION_ID = 1804

local EXPEDIATION_SPEED_ID =
{
    [Common_pb.TeamMoveType_None] = 1004,
    [Common_pb.TeamMoveType_ResTake] = 1005,            --资源采集
    [Common_pb.TeamMoveType_MineTake] = 1005,           --超级矿采集
    [Common_pb.TeamMoveType_TrainField] = 1007,     --训练场
    [Common_pb.TeamMoveType_Garrison] = 1007,           --驻防
    [Common_pb.TeamMoveType_GatherCall] = 1007,     --发起集结
    [Common_pb.TeamMoveType_GatherRespond] = 1007,      --响应集结
    [Common_pb.TeamMoveType_AttackMonster] = 1006,      --攻击怪
    [Common_pb.TeamMoveType_AttackPlayer] = 1007,       --攻击玩家
    --[Common_pb.TeamMoveType_ReconPlayer] = 9,     --侦查玩家
    --[Common_pb.TeamMoveType_ReconMonster] = 10,       --侦查怪
    [Common_pb.TeamMoveType_Camp] = 1007,               --扎营
    [Common_pb.TeamMoveType_Occupy] = 1007,         --占领
    --[Common_pb.TeamMoveType_ResTransport] = 13,       --资源运输
    [Common_pb.TeamMoveType_GuildBuildCreate] = 1007,   --联盟建筑
    --[Common_pb.TeamMoveType_MonsterSiege] = 15,   --怪物攻城
    [Common_pb.TeamMoveType_AttackFort] = 1007,     --攻击要塞
    [Common_pb.TeamMoveType_AttackCenterBuild] = 1007,      --攻击政府
    [Common_pb.TeamMoveType_GarrisonCenterBuild] = 1007,    --驻防政府
}

local DefaultHeroAtts_moba = {1004,100000021,1008,1063}
local DefaultHeroAttsOutSea_Moba = {1004,100000021,1008,1063}
local DefaultHeroAtts_Normal = {1004,100000021,1008}
local DefaultHeroAttsOutSea_Normal = {1102 ,1004,100000021,1008}

local DefaultHeroAtts = {1004,100000021,1008,1063}
local DefaultHeroAttsOutSea = {1004,100000021,1008,1063}
local MobaHeroAtts = {10000,1001,1002,1003,1004,0,1063}

function GetSelectHeroData(ingoreHeroState)
    if selectHeroData == nil then
        selectHeroData = BMLocalHeroData()
        selectHeroData:NormalizeData()
    end
    
    if (_ui == nil or _ui.ignoreHeroAtts == nil) and (ingoreHeroState == nil or not ingoreHeroState) then
    local heros = MobaBattleMoveData.GetPreHeroList()
    if heros ~= nil then
        for _, v in ipairs(heros) do
            -- if HeroListData.IsHeroSetout(v) then
            if MobaHeroListData.IsOutForExpediation(v) then
                selectHeroData:UnselectHero(v)
            end
        end
    end
    end 
    return selectHeroData
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    if _ui.closeCallback ~= nil then
        _ui.closeCallback() 
    end
    Hide()
end

function CancelClose()
    if _ui ~= nil then
        selectHeroData.memHero = _ui.oldSelectHeroData
        CloseAll()
    end    
end

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

LoadUI = nil

local function GetVaildHeroUid(uid)
    local baseHerodata = MobaHeroListData.GetGeneralByUID(uid) -- HeroListData.GetHeroDataByUid(uid)
    if baseHerodata == nil then
        return nil
    end

    local baseid = baseHerodata.baseid

    local heroListData = MobaHeroListData.GetGenerals() -- HeroListData.GetData()
    for _, v in ipairs(heroListData) do
        if v.baseid == baseid and uid == v.uid then
            return v.uid
        end
    end
    
    return nil
end

function AutoSelect(moveType, tileMsg, maxNumHeroSelected, ingoreHeroState)
    
    local selectHeroData = GetSelectHeroData(true)

    local suggestionRule = TableMgr:GetHeroSuggestionRule(9999)
    --local suggestionRule = _ui and _ui.suggestionRule or TableMgr:GetMobaExpediationSuggestionRule(moveType, tileMsg) -- TableMgr:GetExpediationSuggestionRule(HeroListData.GetHeroSuggestionRule(moveType, tileMsg))
--[[
    if suggestionRule == nil then -- 不需要推荐出征将军时先选取上次出征的将军后填充空位
        selectHeroData:UnselectAllHero()

        local lastExpediationHeroes = MobaBattleMoveData.GetPreHeroList()

        for i = 1, #(lastExpediationHeroes) do
            local uid = GetVaildHeroUid(lastExpediationHeroes[i])
            if (_ui == nil or _ui.ignoreHeroAtts == nil) and (ingoreHeroState == nil or not ingoreHeroState) then
                if uid ~= nil and MobaHeroListData.IsAvailableForExpediation(uid) then -- HeroListData.IsHeroAvailableForExpediation(uid) then
                    selectHeroData:SelectHero(uid)
                end
            else
                if uid ~= nil then
                    selectHeroData:SelectHero(uid)
                end
            end
        end
    else
        --]]
        local numSelected = 0
        local numDiffered = 0

        local generalsToSelect = {}
        for _, hero in ipairs(_ui and _ui.heroListData or MobaHeroListData.GetSortedGenerals(suggestionRule and suggestionRule.sortingConfig)) do  -- HeroListData.GetSortedHeroes(suggestionRule and suggestionRule.sortingConfig)
            if numSelected < (maxNumHeroSelected or 5) then
                local uid = hero.uid
                if (_ui == nil or _ui.ignoreHeroAtts == nil) and (ingoreHeroState == nil or not ingoreHeroState) then
                    if uid ~= nil and MobaHeroListData.IsAvailableForExpediation(uid) then -- HeroListData.IsHeroAvailableForExpediation(uid) then
                        if not selectHeroData:IsHeroSelectedByUid(uid) then
                            numDiffered = numDiffered + 1 -- selectHeroData:SelectHero(uid)
                        end

                        table.insert(generalsToSelect, uid)
                        numSelected = numSelected + 1
                    end
                else
                    if uid ~= nil then
                        if not selectHeroData:IsHeroSelectedByUid(uid) then
                            numDiffered = numDiffered + 1 -- selectHeroData:SelectHero(uid)
                        end

                        table.insert(generalsToSelect, uid) -- selectHeroData:SelectHero(uid)
                        numSelected = numSelected + 1
                    end
                end

            else
                break
            end
        end

        selectHeroData:UnselectAllHero()

        if numDiffered > 0 then
            for _, uid in ipairs(generalsToSelect) do
                selectHeroData:SelectHero(uid)
            end
        end
--    end
end

function ClearSelectedGenerals()
    selectHeroData:UnselectAllHero()
end

function SetIgnoreHero(_ignoreHeros)
    ignoreHeros = _ignoreHeros
end

function IsOutForExpediation(uid)
    if ignoreHeros == nil or ignoreHeros[uid] == nil then
        return MobaHeroListData.IsOutForExpediation(uid)
    else
        return ignoreHeros[uid]~= nil or MobaHeroListData.IsOutForExpediation(uid)
    end
end

function LoadArchive(archive)
    if archive then
        for i, uid in ipairs(archive.generals or {}) do
            if _ui == nil or _ui.ignoreHeroAtts == nil then
            if uid and not IsOutForExpediation(uid) then -- HeroListData.IsHeroSetout(uid) then
                selectHeroData:SelectHero(uid)
            end
            else
                if uid then -- HeroListData.IsHeroSetout(uid) then
                    selectHeroData:SelectHero(uid)
                end               
            end
		end
	end
end

local function IngoreAtts(att_id)
    if Global.GetMobaMode() == 2 then
        if _ui.ignoreHeroAtts == nil then
            return true
        end
        for i = 1,#_ui.ignoreHeroAtts do
            if _ui.ignoreHeroAtts[i] == att_id then
                return false
            end
        end
        return true
    else
        if MobaHeroAtts == nil then
            return false
        end
        for i = 1,#MobaHeroAtts do
            if MobaHeroAtts[i] == att_id then
                return true
            end
        end
        return false 
    end
end

local function LoadSelectList()
    local moveType = _ui.moveType
    local tileMsg = _ui.tileMsg
    local totalPower = 0
    local totalTroops = 0
    local selectIndex = 1
    -- local allAttrList = {}
    local totalAttributes = {}
    local setoutAttrList = {--[[{Text.Hero_soldier, 0},]] {Text.ui_worldmap_85, 0}, {Text.ui_worldmap_87, 0}, {Text.ui_worldmap_86, 0}}
	if Global.IsOutSea() then
		setoutAttrList = {{Text.Hero_soldier, 0}, {Text.ui_worldmap_85, 0}, {Text.ui_worldmap_87, 0}, {Text.ui_worldmap_86, 0}}
	end
	
	--Global.DumpMessage(_ui.heroListMsg , "d:/heroListMsg.lua")
    for i, v in ipairs(_ui.heroListMsg) do
        if selectHeroData:IsHeroSelectedByUid(v.uid) then
            local heroMsg = v
            local selectHero = _ui.selectList[selectIndex]
            local heroData = TableMgr:GetHeroData(heroMsg.baseid) 
            HeroList.LoadHero(selectHero.hero, heroMsg, heroData)
            selectHero.hero.gameObject:SetActive(true)
            selectIndex = selectIndex + 1
            SetClickCallback(selectHero.bgObject, function(go)
                selectHeroData:UnselectHero(heroMsg.uid)
                LoadUI()
            end)

            -- local attrList = HeroListData.GetAttrList(heroMsg, heroData)
            -- for k, v in pairs(attrList) do
            --     if allAttrList[k] == nil then
            --         allAttrList[k] = v
            --     else
            --         allAttrList[k].value = allAttrList[k].value + v.value
            --     end
            -- end

            local attributes = nil 
            if Global.GetMobaMode() == 1 then
                attributes = MobaHeroListData.GetAttributes(heroMsg)
            else
                attributes = MobaHeroListData.GetAttributes(heroMsg)[2]
            end

            for attributeID, value in pairs(attributes) do
				if Global.IsOutSea() then
					if not totalAttributes[attributeID] then
						totalAttributes[attributeID] = value
					else
						totalAttributes[attributeID] = totalAttributes[attributeID] + value
					end
				else
					if attributeID ~= 1102 then
						if not totalAttributes[attributeID] then
							totalAttributes[attributeID] = value
                        else
                            
							totalAttributes[attributeID] = totalAttributes[attributeID] + value
						end
					end
				end
            end

            local sceneEntryType = tileMsg.data.entryType

            totalPower = totalPower + MobaHeroListData.GetPower(heroMsg) -- HeroListData.GetPowerByAttrList(attrList)

            local troopsValue = 0--attributes[DefaultHeroAtts[1]] -- HeroListData.GetTroops(heroMsg, heroData)
            setoutAttrList[1][2] = setoutAttrList[1][2] + troopsValue
            
            if not Global.IsOutSea() then
                local moveValue = (attributes[DefaultHeroAtts[1]] or 0) + (attributes[EXPEDIATION_SPEED_ID[moveType]] or 0) -- HeroListData.GetMoveAttrValueByHeroMsgData(moveType, heroMsg, heroData)
                setoutAttrList[1][2] = setoutAttrList[1][2] + moveValue
            
                local weightValue = attributes[DefaultHeroAtts[2]] or 0 -- HeroListData.GetWeightByHeroMsgData(heroMsg, heroData)
                setoutAttrList[2][2] = setoutAttrList[2][2] + weightValue
            
                local gatherValue = (attributes[DefaultHeroAtts[3]] or 0) + (attributes[1006 + (sceneEntryType == Common_pb.SceneEntryType_GuildBuild and tileMsg.guildbuild.baseid or sceneEntryType)] or 0) -- HeroListData.GetGatherAttrValueByHeroMsgData(tileMsg, heroMsg, heroData)
                setoutAttrList[3][2] = setoutAttrList[3][2] + gatherValue
            
            else
                troopsValue = (attributes[DefaultHeroAttsOutSea[1]] or 0)
				setoutAttrList[1][2] = setoutAttrList[1][2] + troopsValue
				
				local moveValue = (attributes[DefaultHeroAttsOutSea[2]] or 0) + (attributes[EXPEDIATION_SPEED_ID[moveType]] or 0)
				setoutAttrList[2][2] = setoutAttrList[2][2] + moveValue
				
				local weightValue = attributes[DefaultHeroAttsOutSea[3]] or 0
				setoutAttrList[3][2] = setoutAttrList[3][2] + weightValue
				
				local gatherValue = (attributes[DefaultHeroAttsOutSea[4]] or 0) + (attributes[1006 + (sceneEntryType == Common_pb.SceneEntryType_GuildBuild and tileMsg.guildbuild.baseid or sceneEntryType)] or 0) 
				setoutAttrList[4][2] = setoutAttrList[4][2] + gatherValue
			end
			
			
            totalTroops = totalTroops + troopsValue
        end
    end

    _ui.powerLabel.text = math.floor(totalPower)
    _ui.troopsLabel.text = "+" .. totalTroops

    for i = selectIndex, 5 do
        local selectHero = _ui.selectList[i]
        selectHero.hero.gameObject:SetActive(false)
        SetClickCallback(selectHero.bgObject, nil)
    end

    local attrIndex = 1
    for attributeID, value in pairs(--[[allAttrList]]totalAttributes) do
        
        if IngoreAtts(attributeID) then

        local attributeData = TableMgr:GetNeedTextData(attributeID)
        if attributeData then
            if attributeData.additionArmy ~= 0 or attributeData.additionAttr ~= 1102 then
                local attrTransform
                if attrIndex > _ui.attrListGrid.transform.childCount then
                    
                    attrTransform = NGUITools.AddChild(_ui.attrListGrid.gameObject, _ui.attrPrefab).transform
                else
                    attrTransform = _ui.attrListGrid.transform:GetChild(attrIndex - 1)
                end
                local nameLabel = attrTransform:Find("name"):GetComponent("UILabel")
                local valueLabel = attrTransform:Find("num"):GetComponent("UILabel")
                nameLabel.text = TextMgr:GetText(attributeData.unlockedText)
                valueLabel.text = Global.GetHeroAttrValueString(attributeData.additionAttr, value)
                valueLabel.color = value > 0 and Color.green or Color.white
                if attributeData == 1063 and value <= 0 then
                    attrTransform.gameObject:SetActive(false)
                else
                    attrTransform.gameObject:SetActive(true)
                end
                
                attrIndex = attrIndex + 1
            end
        end
        end
    end

    if Global.GetMobaMode() == 2 then
	local defultAttrs = Global.IsOutSea() and DefaultHeroAttsOutSea_Normal or DefaultHeroAtts_Normal
    for i = 1, (Global.IsOutSea() and 4 or 3) do
        if IngoreAtts(defultAttrs[i]) then
		
		
        local attrTransform
        if attrIndex > _ui.attrListGrid.transform.childCount then
            attrTransform = NGUITools.AddChild(_ui.attrListGrid.gameObject, _ui.attrPrefab).transform
        else
            attrTransform = _ui.attrListGrid.transform:GetChild(attrIndex - 1)
        end
        local nameLabel = attrTransform:Find("name"):GetComponent("UILabel")
        local valueLabel = attrTransform:Find("num"):GetComponent("UILabel")
        nameLabel.text = TextMgr:GetText(setoutAttrList[i][1])
        local attrValue = setoutAttrList[i][2]
        if i == 1 then
            valueLabel.text = "+" .. attrValue
        else
            valueLabel.text = "+" .. attrValue .. "%"
        end
        valueLabel.color = attrValue > 0 and Color.green or Color.white
        if attributeData == 1063 and value <= 0 then
            attrTransform.gameObject:SetActive(false)
        else
            attrTransform.gameObject:SetActive(true)
        end
        attrIndex = attrIndex + 1
        end
    end
    end
    

    for i = attrIndex, _ui.attrListGrid.transform.childCount do
        _ui.attrListGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end

    _ui.attrListGrid.repositionNow = true
end

local function LoadHeroList()
    local moveType = _ui.moveType
    local tileMsg = _ui.tileMsg
    for i, v in ipairs(_ui.heroListMsg) do
        local listHeroTransform
        if i > _ui.heroListGrid.transform.childCount then
            listHeroTransform = NGUITools.AddChild(_ui.heroListGrid.gameObject, _ui.heroPrefab).transform
            listHeroTransform.name = "listitem_hero_PVP".. i
            if i > 1 and (i - 1) % 6 == 0 then
                _ui.heroListGrid.repositionNow = true
                coroutine.step()
            end
        else
            listHeroTransform = _ui.heroListGrid.transform:GetChild(i - 1)
        end
        local heroMsg = v
        local heroData = TableMgr:GetHeroData(heroMsg.baseid) 
        local listHero = {}
        local selected = selectHeroData:IsHeroSelectedByUid(heroMsg.uid)
        listHero.selectObject = listHeroTransform:Find("select").gameObject
        local hero = {}
        local heroTransform = listHeroTransform:Find("Container")
        HeroList.LoadHeroObject(hero, heroTransform)
        HeroList.LoadHero(hero, heroMsg, heroData)

        local sceneEntryType = tileMsg.data.entryType

        local attributes = MobaHeroListData.GetAttributes(heroMsg)
        if Global.GetMobaMode() == 2 then
            attributes = MobaHeroListData.GetAttributes(heroMsg)[2]
        end

        local troopsLabel = heroTransform:Find("quality1/num"):GetComponent("UILabel")
        local troopsValue = attributes[1063] or 0 -- HeroListData.GetTroops(heroMsg, heroData)
        if Global.GetMobaMode() == 2 then
            troopsValue = attributes[1102] or 0
        end 
        troopsLabel.text = "+" .. troopsValue
        troopsLabel.color = troopsValue > 0 and Color.green or Color.white
        heroTransform:Find("quality1").gameObject:SetActive(troopsValue > 0)


        local moveLabel = heroTransform:Find("quality2/num"):GetComponent("UILabel")
        local moveValue = (attributes[1004] or 0) + (attributes[EXPEDIATION_SPEED_ID[moveType]] or 0) -- HeroListData.GetMoveAttrValueByHeroMsgData(moveType, heroMsg, heroData)

        moveLabel.text = "+" .. moveValue .. "%"
        moveLabel.color = moveValue > 0 and Color.green or Color.white

        local weightLabel = heroTransform:Find("quality3/num"):GetComponent("UILabel")
        local weightValue = attributes[100000021] or 0 -- HeroListData.GetWeightByHeroMsgData(heroMsg, heroData)
        weightLabel.text = "+" .. weightValue .. "%"
        weightLabel.color = weightValue > 0 and Color.green or Color.white
        --if Global.GetMobaMode() == 1 then
            heroTransform:Find("quality3").gameObject:SetActive(false)
        --end

        local gatherLabel = heroTransform:Find("quality4/num"):GetComponent("UILabel")
        local gatherValue = (attributes[1008] or 0) + (attributes[1006 + (sceneEntryType == Common_pb.SceneEntryType_GuildBuild and tileMsg.guildbuild.baseid or sceneEntryType)] or 0) -- HeroListData.GetGatherAttrValueByHeroMsgData(tileMsg, heroMsg, heroData)
        gatherLabel.text = "+" .. gatherValue .. "%"
        gatherLabel.color = gatherValue > 0 and Color.green or Color.white
        --if Global.GetMobaMode() == 1 then
            heroTransform:Find("quality4").gameObject:SetActive(false)
        --end

        -- local heroState = HeroListData.GetHeroState(heroMsg.uid)
        hero.stateBg.gameObject:SetActive(false)
        for _, v in pairs(hero.stateList) do
            v.gameObject:SetActive(false)
        end
        if _ui.ignoreHeroAtts == nil then
        -- if HeroListData.IsHeroDefenseByState(heroState) then
        if MobaHeroListData.IsDefending(heroMsg.uid) then
            hero.stateBg.gameObject:SetActive(true)
            hero.stateList.defense.gameObject:SetActive(true)
        end

        -- if HeroListData.IsHeroSetoutByState(heroState) then
        if IsOutForExpediation(heroMsg.uid) then
            hero.stateBg.gameObject:SetActive(true)
            hero.stateList.setout.gameObject:SetActive(true)
        end
        end

        listHero.selectObject:SetActive(selected)
        listHero.hero = hero
        SetClickCallback(listHeroTransform.gameObject, function(go)
            local heroUid = heroMsg.uid
            if selectHeroData:IsHeroSelectedByUid(heroUid) then
                selectHeroData:UnselectHero(heroUid)
                LoadUI()
            else
                -- if HeroListData.IsHeroSetoutByState(heroState) then
                if _ui.ignoreHeroAtts == nil then    
                if IsOutForExpediation(heroMsg.uid) then
                    FloatText.Show(TextMgr:GetText(Text.BattleMove_atk))
                else
                    local full = selectHeroData:GetSelectedHeroCount() >= 5
                    if full then
                        local text = TextMgr:GetText(Text.selectunit_hint114)
                        AudioMgr:PlayUISfx("SFX_ui02", 1, false)
                        FloatText.Show(text, Color.white)
                    else
                        -- if HeroListData.IsHeroDefenseByState(heroState) then
                        if IsOutForExpediation(heroMsg.uid) then
                            MessageBox.Show(TextMgr:GetText(Text.BattleMove_wall), function()
                                selectHeroData:SelectHero(heroUid)
                                LoadUI()
                            end,
                            function()
                            end)
                        else
                            print("选择将军: baseid:", heroData.id, "uid:", heroUid)
                            selectHeroData:SelectHero(heroUid)
                            LoadUI()
                        end
                    end
                end
                else
                    local full = selectHeroData:GetSelectedHeroCount() >= 5
                    if full then
                        local text = TextMgr:GetText(Text.selectunit_hint114)
                        AudioMgr:PlayUISfx("SFX_ui02", 1, false)
                        FloatText.Show(text, Color.white)
                    else
                            print("选择将军: baseid:", heroData.id, "uid:", heroUid)
                            selectHeroData:SelectHero(heroUid)
                            LoadUI()
                    end
                end
            end
        end)
    end

    for i = #_ui.heroListMsg + 1, _ui.heroListGrid.transform.childCount do
        _ui.heroListGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end

    _ui.heroListGrid.repositionNow = true
end

function LoadUI()
    _ui.suggestionRule = TableMgr:GetMobaExpediationSuggestionRule(_ui.moveType, _ui.tileMsg)-- HeroListData.GetHeroSuggestionRule(_ui.moveType, _ui.tileMsg))
    _ui.heroListMsg = MobaHeroListData.GetSortedGenerals(_ui.suggestionRule and _ui.suggestionRule.sortingConfig) -- HeroListData.GetSortedHeroes(_ui.suggestionRule and _ui.suggestionRule.sortingConfig)
    Global.DumpMessage(_ui.heroListMsg, "d:/wgame/dump/messages/SelectHero_PVP._ui.heroListMsg.lua")
    coroutine.stop(_ui.loadHeroListCoroutine)
    _ui.loadHeroListCoroutine = coroutine.start(LoadHeroList)
    LoadSelectList()
end

local function LoadHeroObject(hero, heroTransform)
    hero.icon = heroTransform:Find("head icon"):GetComponent("UITexture")
    hero.qualityList = {}
    for i = 1, 5 do
        hero.qualityList[i] = heroTransform:Find("head icon/outline"..i)
    end
    hero.levelLabel = heroTransform:Find("head icon/level text"):GetComponent("UILabel")
end

function Awake()
    local closeButton = transform:Find("Container/btn_back")
    closeButton.gameObject:SetActive(true)
    local mask = transform:Find("Container/mask")
    SetClickCallback(closeButton.gameObject, CancelClose)
    SetClickCallback(mask.gameObject, CancelClose)
    _ui = {}
    _ui.powerLabel = transform:Find("Container/bg_skills/bg_skills/title_bg/combat num"):GetComponent("UILabel")
    local selectList = {}
    for i = 1, 5 do
        local selectTransform = transform:Find("Container/bg_battle skills/bg_selected/hero" .. i)
        local selectHero = {}
        selectHero.transform = selectTransform
        selectHero.bgObject = selectTransform:Find("bg").gameObject
        local hero = {}
        local heroTransform = selectTransform:Find("Container")
        HeroList.LoadHeroObject(hero, heroTransform)
        selectHero.hero = hero
        selectList[i] = selectHero
    end
    _ui.selectList = selectList
    _ui.heroListScrollView = transform:Find("Container/bg_skills/bg_skills/bg2/Scroll View"):GetComponent("UIScrollView")
    _ui.heroListGrid = transform:Find("Container/bg_skills/bg_skills/bg2/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.heroPrefab = ResourceLibrary.GetUIPrefab("WorldMap/listitem_hero_PVP")

    _ui.troopsLabel = transform:Find("Container/bg_right/bg/soldier num"):GetComponent("UILabel")

    _ui.attrListGrid = transform:Find("Container/bg_right/bg/bg_addition/Scroll View/Grid"):GetComponent("UIGrid") 
    _ui.attrPrefab = _ui.attrListGrid.transform:GetChild(0).gameObject
    _ui.autoSelectButton = transform:Find("Container/btn_auto"):GetComponent("UIButton")
    _ui.confirmButton = transform:Find("Container/btn_attack"):GetComponent("UIButton")
    SetClickCallback(_ui.autoSelectButton.gameObject, function()
        AutoSelect(_ui.moveType, _ui.tileMsg)
        LoadUI()
    end)
    SetClickCallback(_ui.confirmButton.gameObject, CloseAll)

    RaceData.AddListener(LoadUI)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Close()
    print("EEEEEWWWWWWWWWWWWWW MobaSelectHero_PVPMobaSelectHero_PVPMobaSelectHero_PVP")
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    RaceData.RemoveListener(LoadUI)
    Tooltip.HideItemTip()
    coroutine.stop(_ui.loadHeroListCoroutine)
    _ui = nil
    ignoreHeros = nil
end

function Show(moveType, tileMsg,ignoreHeroAtts, closeCallback)
    Global.OpenUI(_M)
    _ui.ignoreHeroAtts = ignoreHeroAtts
    _ui.oldSelectHeroData = {}
    for i, v in ipairs(GetSelectHeroData().memHero) do
        _ui.oldSelectHeroData[i] = v
    end
    _ui.moveType = moveType
    _ui.tileMsg = tileMsg
    _ui.closeCallback = closeCallback
    if Global.GetMobaMode() == 2 then
        DefaultHeroAtts = DefaultHeroAtts_Normal
        DefaultHeroAttsOutSea = DefaultHeroAttsOutSea_Normal
    else
        DefaultHeroAtts = DefaultHeroAtts_moba
        DefaultHeroAttsOutSea = DefaultHeroAttsOutSea_Moba
    end

    LoadUI()
end

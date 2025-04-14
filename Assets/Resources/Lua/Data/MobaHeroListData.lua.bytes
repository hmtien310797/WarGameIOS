module("MobaHeroListData", package.seeall)

local TableMgr = Global.GTableMgr

local NUM_BASIC_ATTRIBUTES = TableMgr:GetNumGeneralBasicAttributes()

MAX_LEVEL = tableData_tHeroExp.Count
MAX_STAR = 6
MAX_GRADE = 10

----- Events ---------------------------------------------------------
local eventOnDataChange = EventDispatcher.CreateEvent()
local eventOnGeneralLevelChange = EventDispatcher.CreateEvent()
local eventOnGeneralStarChange = EventDispatcher.CreateEvent()
local eventOnGeneralExpChange = EventDispatcher.CreateEvent()
local eventOnGeneralGradeChange = EventDispatcher.CreateEvent()
local eventOnGeneralAppointmentChange = EventDispatcher.CreateEvent()
local eventOnNoticeStatusChange = EventDispatcher.CreateEvent()

function OnDataChange()
    return eventOnDataChange
end

function OnGeneralLevelChange()
    return eventOnGeneralLevelChange
end

function OnGeneralStarChange()
    return eventOnGeneralStarChange
end

function OnGeneralExpChange()
    return eventOnGeneralExpChange
end

function OnGeneralGradeChange()
    return eventOnGeneralGradeChange
end

function OnGeneralAppointmentChange()
    return eventOnGeneralAppointmentChange
end

function OnNoticeStatusChange()
    return eventOnNoticeStatusChange
end

local function BroadcastEventOnDataChange(...)
    EventDispatcher.Broadcast(eventOnDataChange, ...)
end

local function BroadcastEventOnGeneralLevelChange(...)
    EventDispatcher.Broadcast(eventOnGeneralLevelChange, ...)
end

local function BroadcastEventOnGeneralStarChange(...)
    EventDispatcher.Broadcast(eventOnGeneralStarChange, ...)
end

local function BroadcastEventOnGeneralExpChange(...)
    EventDispatcher.Broadcast(eventOnGeneralExpChange, ...)
end

local function BroadcastEventOnGeneralGradeChange(...)
    EventDispatcher.Broadcast(eventOnGeneralGradeChange, ...)
end

local function BroadcastEventOnGeneralAppointmentChange(...)
    EventDispatcher.Broadcast(eventOnGeneralAppointmentChange, ...)
end

local function BroadcastEventOnNoticeStatusChange(...)
    EventDispatcher.Broadcast(eventOnNoticeStatusChange, ...)
end
----------------------------------------------------------------------

----- Data -----
local generals = {}
local generalsByUID = {}
local generalsByBaseID = {}

local availableExpFromItems = 0
local noticeStatus = {}
local noticeStatus4LevelUp = {}
local SeenHeroIDs = {}
local GetNewHeroIDs = {}

local function ClearData()
    generals = {}
    generalsByUID = {}
    generalsByBaseID = {}

    availableExpFromItems = 0
    noticeStatus = {}
    noticeStatus4LevelUp = {}
    SeenHeroIDs = {}
    GetNewHeroIDs = {}
end

function GetGenerals()
    return generals
end

function GetSortedGenerals(sortingConfig)
    SortGenerals(sortingConfig)
    return generals
end

function GetGeneralByUID(uid)
    if uid then
        return generalsByUID[uid]
    end

    return generalsByUID
end

function GetGeneralByBaseID(baseID)
    if baseID then
        return generalsByBaseID[baseID]
    end

    return generalsByBaseID
end

function HasGeneralByBaseID(baseID)
    return generalsByBaseID[baseID] ~= nil
end

function HasBattleHero()
    for _, heroInfo in ipairs(generals) do
        local heroData = TableMgr:GetHeroData(heroInfo.baseid)
        if not heroData.expCard then
            return true
        end
    end
    return false
end

function HasNonAppointedGeneral()
    for _, heroInfo in ipairs(generals) do
        if heroInfo.appointInfo.buildType == 0 then
            if not TableMgr:GetHeroData(heroInfo.baseid).expCard then
                return true
            end
        end
    end

    return false
end


function CanLevelUpQuick(heroInfo, heroRule)
    if not heroRule then
        heroRule = TableMgr:GetRulesDataByStarGrade(heroInfo.star, heroInfo.grade)
    end

    if heroInfo.level < heroRule.maxlevel then
        for i = 1, 5 do
            if ItemListData.GetItemCountByBaseId(TableMgr:GetItemData(550000 + i).id) > 0 then
                return true
            end
        end

        return false
    end

    return false
end

function CanLevelUp(heroMsg, heroRule)
    local rulesData = heroRule
    if not heroRule then
        rulesData = TableMgr:GetRulesDataByStarGrade(heroMsg.star, heroMsg.grade)
    end

    local maxLevel = rulesData.maxlevel
    
    -------------------------------
    --n级 以上才开启等级显示红点
    local unlock_level_data = TableMgr:GetGlobalData(100222)
    local unlock_level = 0
    if  unlock_level_data ~= nil then
        unlock_level = tonumber(unlock_level_data.value)
    end

    --print("WWWWWWWWWWWWWWWWWWWWWWWWW1",heroMsg.level)
    if heroMsg.level < 10 then --unlock_level
        return false
    end
    --------------------------------


    if heroMsg.level < maxLevel then
        local exp = 0
 
        ---可升满一级
        ---------------------------------
        local preExp = 0
        if heroMsg.level > 1 then
            preExp = TableMgr:GetHeroExpData(heroMsg.level - 1).exp
        end
        local currentExp = heroMsg.exp - preExp

        local expData = TableMgr:GetHeroExpData(heroMsg.level)
        local levelexp = expData.levelExp
        local leftExp = levelexp - currentExp
        if leftExp < 0 then
            if heroMsg.level ~= rulesData.maxlevel then
                local next_exp = TableMgr:GetHeroExpData(heroMsg.level + 1)
                if next_exp ~= nil then
                    levelexp = next_exp.levelExp
                    leftExp = levelexp - currentExp
                end
            end
        end
        ---------------------------------
        --print("WWWWWWWWWWWWWWWWWWWWWWWWW1",leftExp)
        for i = 1, 5 do
            local expDataList = TableMgr:GetItemDataListByTypeQuality(55, i)

            ------------------------------------
            for j, v in ipairs(expDataList) do
                if v ~= nil then
                    if leftExp <= 0 then
                        return true
                    end
                    local item_msg = ItemListData.GetItemDataByBaseId(v.id)
                    if item_msg ~= nil then
                        local cardCount = item_msg.number
                        leftExp = leftExp - v.param1 * math.floor(cardCount)  
                        --print("WWWWWWWWWWWWWWWWWWWWWWWWW1",leftExp,v.param1 * math.floor(cardCount)  ,item_msg.number)                      
                    end
                end
            end
            -------------------------------------

            --local expMsg = ItemListData.GetItemDataByBaseId(expDataList[1].id)
            --if expMsg ~= nil then
            --    return true
            --end
        end
       -- print("WWWWWWWWWWWWWWWWWWWWWWWWW",leftExp)
        if leftExp <= 0 then
            return true
        end        
    end
end

function CanStarUp(heroInfo, heroData, heroRule)
    if not heroData then
        heroData = TableMgr:GetHeroData(heroInfo.baseid)
    end

    if not heroRule then
        heroRule = TableMgr:GetRulesDataByStarGrade(heroInfo.star, heroInfo.grade)
    end

    return heroInfo.star < 6 and ItemListData.GetItemCountByBaseId(heroData.chipID) >= heroRule.num
end

function CanGradeUp(heroInfo, heroGradeUpData)
    if not heroGradeUpData then
        heroGradeUpData = TableMgr:GetHeroGradeUpDataByHeroIdGrade(heroInfo.baseid, heroInfo.heroGrade)
    end
    
    if heroGradeUpData.badgeGrade ~= 0 then
        if heroInfo.level >= heroGradeUpData.unlockLevel then
            for s in string.gsplit(heroGradeUpData.needItem, ";") do
                local badgeMaterial = {}

                local itemData
                local neededNum
                for intString in string.gsplit(s, ":") do
                    if not itemData then
                        itemData = TableMgr:GetItemData(tonumber(intString))
                    elseif not neededNum then
                        neededNum = tonumber(intString)
                    end
                end

                if ItemListData.GetItemCountByBaseId(itemData.id) < neededNum then
                    return false
                end
            end

            return true
        end
    end

    return false
end

function CanPassiveSkillUpgrade(heroMsg, skillIndex)
    if skillIndex > heroMsg.star then
        return false
    end
    local heroData = TableMgr:GetHeroData(heroMsg.baseid)
    local skillId = tonumber(string.split(TableMgr:GetHeroData(heroMsg.baseid).showpassiveskill, ";")[skillIndex])
    if skillId == 0 then
        return false
    end

    local skillData = TableMgr:GetPassiveSkillData(skillId)
    local skillMsg
    for i, v in ipairs(heroMsg.skill.passiveSkill) do
        if v.id == skillData.id then
            skillMsg = v
            break
        end
    end
    if skillMsg == nil then
        return false
    end
    
    local skillLevel = skillMsg.level
    local maxLevel = skillData.SkillLevelMax
    if skillLevel >= maxLevel then
        return false
    end

    local nextLevelUpId = skillData.SkillLvlupType * 1000 + skillLevel + 1
    local nextLevelUpData = tableData_tPassiveskillLevelUp.data[nextLevelUpId]
    if heroMsg.level < nextLevelUpData.NeedHeroLevel then
        return false
    end

    local itemList = string.split(nextLevelUpData.SkillLevelConsume, ";")
    for i, v in ipairs(itemList) do
        local itemIdList = string.split(v, ":")
        local itemId = tonumber(itemIdList[1])
        local itemCount = tonumber(itemIdList[2])
        local itemData = TableMgr:GetItemData(itemId)
        local hasCount = 0
        if itemData == nil then
            return false
        end
        if itemData.type == 1 then
            hasCount = MoneyListData.GetMoneyByType(itemData.id)
        else
            hasCount = ItemListData.GetItemCountByBaseId(itemId)
        end
        if hasCount < itemCount then
            return false
        end
    end

    return true
end

function CanAnyPassiveSkillUpgrade(heroMsg)
    for i = 1, 6 do
        if CanPassiveSkillUpgrade(heroMsg, i) then
            return true
        end
    end

    return false
end

function HasGeneralCanLevelUp(quality)
    if not quality then
        quality = 0
    end

    for _, heroInfo in ipairs(generals) do
        local heroData = TableMgr:GetHeroData(heroInfo.baseid)
        if heroData.quality >= quality and CanLevelUp(heroInfo) then
            return true
        end
    end

    return false
end

function HasGeneralCanStarUp(quality)
    if not quality then
        quality = 0
    end

    for _, heroInfo in ipairs(generals) do
        local heroData = TableMgr:GetHeroData(heroInfo.baseid)
        if heroData.quality >= quality and CanStarUp(heroInfo, heroData) then
            return true
        end
    end

    return false
end

function HasGeneralCanGradeUp(quality)
    if not quality then
        quality = 0
    end
    
    for _, heroInfo in ipairs(generals) do
        local heroData = TableMgr:GetHeroData(heroInfo.baseid)
        if heroData.quality >= quality and CanGradeUp(heroInfo) then
            return true
        end
    end

    return false
end

function HasGeneralCanPassiveSkillUpgrade()
    for _, heroInfo in ipairs(generals) do
        if CanAnyPassiveSkillUpgrade(heroInfo) then
            return true
        end
    end

    return false
end

function HasNotice(baseID)
    if not baseID then
        for _, hasNotice in pairs(noticeStatus) do
            if hasNotice then
                return true
            end
        end

        return false
    else
        return noticeStatus[baseID] or false
    end
end

local function SetNoticeStatus(heroInfo, hasNotice)
    if noticeStatus[heroInfo.baseid] ~= hasNotice then
        noticeStatus[heroInfo.baseid] = hasNotice

        local bMemorized = noticeStatus[heroInfo.baseid] or false
        local bUpdated = hasNotice or false

        if bMemorized ~= bUpdated then
            BroadcastEventOnNoticeStatusChange(heroInfo, bUpdated)
        end
    end
end

function HasNotice4LevelUp(baseID)
    if not baseID then
        for i, hasNotice in pairs(noticeStatus4LevelUp) do
            if SeenHeroIDs[i] == nil then
                if hasNotice then
                    return true
                end                
            end
        end
        return false
    else
        if SeenHeroIDs[baseID] == nil then
            return noticeStatus4LevelUp[baseID] or false
        else
            return false
        end
    end
end

function SetSeenHero(heroInfo)
    SeenHeroIDs[heroInfo.baseid] = true
    UpdateNoticeStatus(heroInfo);
end

function ClearSeenHero(baseID)
    SeenHeroIDs[baseID] = nil
end

local function SetNoticeStatus4LevelUp(heroInfo, hasNotice)
    if noticeStatus4LevelUp[heroInfo.baseid] ~= hasNotice then
        noticeStatus4LevelUp[heroInfo.baseid] = hasNotice
    end
end

function GetHeroNewState(baseid)
    if GetNewHeroIDs[baseid] ~= nil then
        return true;
    end
    return false;
end

function UpdateNoticeStatus(heroInfo)
    if not heroInfo then
        for _, general in ipairs(generals) do
            UpdateNoticeStatus(general)
        end
    else
        
        local heroData = TableMgr:GetHeroData(heroInfo.baseid)
        local heroRule = TableMgr:GetRulesDataByStarGrade(heroInfo.star, heroInfo.grade)
        local levelup = (SeenHeroIDs[heroInfo.baseid] == nil) and CanLevelUp(heroInfo, heroRule)

        SetNoticeStatus4LevelUp(heroInfo,heroData.quality > 3 and levelup)
        SetNoticeStatus(heroInfo, CanStarUp(heroInfo, heroData, heroRule)
        or (heroData.quality > 3 and (levelup or CanGradeUp(heroInfo)))
        or GetHeroNewState(heroInfo.baseid))
        --or CanAnyPassiveSkillUpgrade(heroInfo))  
--[[
        levelup = levelup ~= nil and true or false
        print("[RED_POINT] QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA HEROOOOOOO:"..heroInfo.baseid.."Star="..heroInfo.star.."grade="..heroInfo.grade,
        "SeenHero:",SeenHeroIDs[heroInfo.baseid] == nil,
        "List levelup:",((heroData.quality > 3) and levelup),
        "maincity red Levelup:",(heroData.quality > 3 and (levelup or CanGradeUp(heroInfo))),
        "StarUp:",CanStarUp(heroInfo, heroData, heroRule),
        "NewState",GetHeroNewState(heroInfo.baseid)
        )      
]]
    end
end



function ClearHeroNewState()
    GetNewHeroIDs = {}
    UpdateNoticeStatus()
end

local function AddGeneral(heroInfo,record_new)
    table.insert(generals, heroInfo)
    generalsByUID[heroInfo.uid] = heroInfo
    generalsByBaseID[heroInfo.baseid] = heroInfo
    if record_new then
        GetNewHeroIDs[heroInfo.baseid] = true;
        Welfare_HerogetData.RequestData(ActivityData.GetActivityIdByTemplete(313))
    end
    UpdateNoticeStatus(heroInfo)

    BroadcastEventOnDataChange(heroInfo, 1)
end

local function UpdateGeneral(heroInfo)
    local hasLevelChanged = false
    local hasStarChanged = false
    local hasExpChanged = false
    local hasGradeChanged = false
    local hasAppointmentChanged = false
    local hasDataChanged = false

    local memorizedData = generalsByUID[heroInfo.uid]

    if memorizedData.level ~= heroInfo.level then
        memorizedData.level = heroInfo.level
        hasLevelChanged = true
        hasDataChanged = true
    end
    
    if memorizedData.star ~= heroInfo.star then
        memorizedData.star = heroInfo.star
        hasStarChanged = true
        hasDataChanged = true
    end

    if memorizedData.grade ~= heroInfo.grade then
        memorizedData.grade = heroInfo.grade
        hasStarChanged = true
        hasDataChanged = true
    end

    if memorizedData.exp ~= heroInfo.exp then
        memorizedData.exp = heroInfo.exp
        hasExpChanged = true
        hasDataChanged = true
    end

    if memorizedData.heroGrade ~= heroInfo.heroGrade then
        memorizedData.heroGrade = heroInfo.heroGrade
        hasGradeChanged = true
        hasDataChanged = true
    end

    if memorizedData.appointInfo.index ~= heroInfo.appointInfo.index then
        memorizedData.appointInfo.index = heroInfo.appointInfo.index
        hasAppointmentChanged = true
        hasDataChanged = true
    end

    if memorizedData.appointInfo.buildType ~= heroInfo.appointInfo.buildType then
        memorizedData.appointInfo.buildType = heroInfo.appointInfo.buildType
        hasAppointmentChanged = true
        hasDataChanged = true
    end

    memorizedData.skill.godSkill.level = heroInfo.skill.godSkill.level
    memorizedData.skill.pvpSkill.level = heroInfo.skill.pvpSkill.level

    while #memorizedData.skill.passiveSkill > 0 do
        memorizedData.skill.passiveSkill:remove(1)
    end
    for _, v in ipairs(heroInfo.skill.passiveSkill) do
        local passiveSkill = memorizedData.skill.passiveSkill:add()
        passiveSkill.id = v.id
        passiveSkill.level = v.level
    end
    hasDataChanged = true

    UpdateNoticeStatus(heroInfo)

    if hasLevelChanged then
        BroadcastEventOnGeneralLevelChange(heroInfo)
    end

    if hasStarChanged then
        BroadcastEventOnGeneralStarChange(heroInfo)
    end

    if hasExpChanged then
        BroadcastEventOnGeneralExpChange(heroInfo)
    end

    if hasGradeChanged then
        BroadcastEventOnGeneralGradeChange(heroInfo)
    end

    if hasAppointmentChanged then
        BroadcastEventOnGeneralAppointmentChange(heroInfo)
    end

    if hasDataChanged then
        BroadcastEventOnDataChange(heroInfo, 0)
    end
end

local function RemoveGeneral(heroInfo)
    for i = 1, #generals do
        if generals[i].uid == heroInfo.uid then
            table.remove(generals, i)
            break
        end
    end

    generalsByUID[heroInfo.uid] = nil
    generalsByBaseID[heroInfo.baseid] = nil

    
    SetNoticeStatus(heroInfo, nil)
    SetNoticeStatus4LevelUp(heroInfo, nil)

    BroadcastEventOnDataChange(heroInfo, -1)
end

function UpdateData(heroFreshInfo)
    for _, freshInfo in ipairs(heroFreshInfo.data) do
        if freshInfo.optype == Common_pb.FreshDataType_Add then
            AddGeneral(freshInfo.data,true)
        elseif freshInfo.optype == Common_pb.FreshDataType_Fresh then
            UpdateGeneral(freshInfo.data)
        elseif freshInfo.optype == Common_pb.FreshDataType_Delete then
            RemoveGeneral(freshInfo.data)
        -- elseif freshInfo.optype == Common_pb.FreshDataType_FlagAdd then
        end
    end
end

function OnPushSetData(response)
    for _, heroInfo in ipairs(response.heros) do
        if not generalsByUID[heroInfo.uid] then
            AddGeneral(heroInfo)
        else
            UpdateGeneral(heroInfo)
        end
    end
end

function SetData(response)
    ClearData()
    for _, heroInfo in ipairs(response.heros) do
        AddGeneral(heroInfo)
    end
end
----------------

function IsPVE(uid)
    return TeamData.IsHeroSelectedByUid(Common_pb.BattleTeamType_Main, uid)
end

function IsDefending(uid)
    return TeamData.IsHeroSelectedByUid(Common_pb.BattleTeamType_CityDefence, uid)
end

function IsOutForExpediation(uid)
    return MobaArmySetoutData.HasHeroSetout(uid)
end

function IsAppointed(uid)
    return generalsByUID[uid].appointInfo.buildType ~= 0
end

function IsPVEOrAppointed(uid)
    return IsPVE(uid) or IsAppointed(uid)
end

function IsAvailableForExpediation(uid)
    return not IsOutForExpediation(uid)
end

function RegistAttributeModel()
    AttributeBonus.RegisterAttBonusModule(_M)
end

function GetPowerMoba(heroInfo)
    return TableMgr:GetMobaHeroData(heroInfo.baseid).HeroPower
end

function GetPowerNormal(heroInfo)
    local power = 0
    for i, v in ipairs(heroInfo.skill.passiveSkill) do
        local skillData = tableData_tPassiveSkill.data[v.id]
        local levelUpId = skillData.SkillLvlupType * 1000 + v.level
        local levelUpData = tableData_tPassiveskillLevelUp.data[levelUpId]
        power = power + levelUpData.SkillPkvalue
    end
    return GetAttributes(heroInfo, 100)[0] + power
end

function GetPower(heroInfo)
    if Global.GetMobaMode() == 1 then
        return GetPowerMoba(heroInfo)
    else
        return GetPowerNormal(heroInfo)
    end
end

function GetPowerRankingList()
    local list = {}

    for _, heroInfo in ipairs(generals) do
        table.insert(list, GetPower(heroInfo))
    end

    table.sort(list, function(power1, power2)
        return power1 > power2
    end)

    return list
end

attributesCache = { fromStarAndLevel = {},
                    fromStarAndGrade = {}, 
                    fromPassiveSkills = {},
                    onAppointment = {},
                    all = {},               }
function GetAttributesFromStarAndLevel(heroInfo)
    local baseID = heroInfo.baseid
    local level = heroInfo.level
    local star = heroInfo.star
    local smallStar = heroInfo.grade

    local cacheKey = baseID * 1000000 + level * 10000 + star * 1000 + smallStar * 100

    if not attributesCache.fromStarAndLevel[cacheKey] then
        local heroData = TableMgr:GetHeroData(baseID)
        local starUpData = TableMgr:GetHeroStarUpDataByHeroIdStarGrade(baseID, star, smallStar)
        
        local attributes = { [0] = {}, [1] = {}, [2] = {}, [3] = {} }

        local power = 0

        for attributeIndex = 1, NUM_BASIC_ATTRIBUTES do
            local value = starUpData["defaultValue" .. attributeIndex] + (level - 1) * starUpData["growValue" .. attributeIndex]
            if value then
                local attributeID = Global.GetAttributeLongID(heroData["additionArmy" .. attributeIndex], heroData["additionAttr" .. attributeIndex])

                local powerData = TableMgr:GetFightData(attributeID)
                if powerData then
                    power = power + value * powerData.coef
                end

                for activeCondition = 0, 3 do
                    attributes[activeCondition][attributeID] = value
                end
            end
        end

        for activeCondition = 0, 3 do
            attributes[activeCondition][100] = power
        end

        attributesCache.fromStarAndLevel[cacheKey] = attributes

        return attributes
    end

    return attributesCache.fromStarAndLevel[cacheKey]
end

function GetAttributesFromStarAndGrade(heroInfo)
    local baseID = heroInfo.baseid
    local level = heroInfo.level
    local star = heroInfo.star
    local grade = heroInfo.heroGrade

    local cacheKey = baseID * 1000000 + level * 10000 + star * 1000 + grade

    if not attributesCache.fromStarAndGrade[cacheKey] then
        local heroData = TableMgr:GetHeroData(baseID)
        local gradeUpData = TableMgr:GetHeroGradeUpDataByHeroIdGrade(baseID, grade)
        
        local attributes = { [0] = {}, [1] = {}, [2] = {}, [3] = {} }

        local power = 0

        for attributeIndex = 1, NUM_BASIC_ATTRIBUTES do
            local value = gradeUpData["value" .. attributeIndex]
            if value then
                local attributeID = Global.GetAttributeLongID(heroData["additionArmy" .. attributeIndex], heroData["additionAttr" .. attributeIndex])
                
                local powerData = TableMgr:GetFightData(attributeID)
                if powerData then
                    power = power + value * powerData.coef
                end

                for activeCondition = 0, 3 do
                    attributes[activeCondition][attributeID] = value
                end
            end
        end

        for activeCondition = 0, 3 do
            attributes[activeCondition][100] = power
        end

        attributesCache.fromStarAndGrade[cacheKey] = attributes

        return attributes
    end

    return attributesCache.fromStarAndGrade[cacheKey]
end

local function GetPassiveSkillCacheKey(skillMsg)
    local keyTable = {}
    for _, v in ipairs(skillMsg) do
        table.insert(keyTable, v.level)
    end
    return table.concat(keyTable, ":")
end

function GetAttributeFromPassiveSkills(heroInfo, heroData)
    local baseID = heroInfo.baseid
    local star = heroInfo.star
    local cacheKey = string.format("%d;%d;%s", baseID, star, GetPassiveSkillCacheKey(heroInfo.skill.passiveSkill))
    
    if not attributesCache.fromPassiveSkills[cacheKey] then
        if not heroData then
            heroData = TableMgr:GetHeroData(baseID)
        end

        local attributes = { [1] = {}, [2] = {}, [3] = {} }
        for i, stringIDs in ipairs(string.split(heroData.passiveskill, ";")) do
            if i <= star then
                local skillLevel = 1
                local skillId = tonumber(string.split(heroData.showpassiveskill, ";")[i])
                local getLevel = false
                for __, vv in ipairs(heroInfo.skill.passiveSkill) do
                    if vv.id == skillId then
                        skillLevel = vv.level
                        break
                    end
                end

                for stringID in string.gsplit(stringIDs, ",") do
                    if tonumber(stringID) ~= 0 then
                        local skillData = TableMgr:GetPassiveSkillData(tonumber(stringID))

                        for attributeIndex = 1, 10 do
                            local attributeID = Global.GetAttributeLongID(skillData["ArmyType" .. attributeIndex], skillData["AttrType" .. attributeIndex])
                            if attributeID ~= 0 then
                                local value = skillData["DefaultValue" .. attributeIndex] + (skillLevel - 1) * skillData["GrowValue" .. attributeIndex] * (1 + math.floor(skillLevel * 0.1) * tonumber(tableData_tGlobal.data[100227].value))

                                local activeCondition = skillData.ActiveCondition

                                if not attributes[activeCondition][attributeID] then
                                    attributes[activeCondition][attributeID] = value
                                else
                                    attributes[activeCondition][attributeID] = attributes[activeCondition][attributeID] + value
                                end
                            end
                        end
                    end
                end
            end
        end

        attributesCache.fromPassiveSkills[cacheKey] = attributes

        return attributes
    end

    return attributesCache.fromPassiveSkills[cacheKey]
end

local attributesCacheMoba = {}
function GetAttributesMoba(heroInfo, v1, v2)
    local cacheKey = heroInfo.baseid
    if attributesCacheMoba[cacheKey] == nil then
        local attributes = {}
        local heroData = nil             
        heroData = TableMgr:GetMobaHeroData(cacheKey)
        if heroData ~= nil then
            for v in string.gsplit(heroData.HeroAttribute, ";") do
                local attrList = string.split(v, ",")
                local armyType = tonumber(attrList[1])
                local attrType = tonumber(attrList[2])
                local attrValue = tonumber(attrList[3])
                attributes[Global.GetAttributeLongID(armyType, attrType)] = attrValue
            end
            attributesCacheMoba[cacheKey] = attributes
        else
            print("herodata is nil ",cacheKey)
        end

    end
    return attributesCacheMoba[cacheKey]
end

function GetAttributesNormal(heroInfo, v1, v2)
    local cacheKey = string.format("%d;%d;%d;%d;%d;%s", heroInfo.baseid, heroInfo.level, heroInfo.star, heroInfo.grade, heroInfo.heroGrade, GetPassiveSkillCacheKey(heroInfo.skill.passiveSkill))

    if not attributesCache.all[cacheKey] then
        local attributes_fromStarAndLevel = GetAttributesFromStarAndLevel(heroInfo)
        local attributes_fromStarAndGrade = GetAttributesFromStarAndGrade(heroInfo)
        local attributes_fromPassiveSkills = GetAttributeFromPassiveSkills(heroInfo)

        local attributes = {}
        for activeCondition = 0, 3 do
            attributes[activeCondition] = {}

            for attributeID, value in pairs(attributes_fromStarAndLevel[activeCondition] or {}) do
                if attributes[activeCondition][attributeID] then
                    attributes[activeCondition][attributeID] = attributes[activeCondition][attributeID] + value
                else
                    attributes[activeCondition][attributeID] = value
                end
            end

            for attributeID, value in pairs(attributes_fromStarAndGrade[activeCondition] or {}) do
                if attributes[activeCondition][attributeID] then
                    attributes[activeCondition][attributeID] = attributes[activeCondition][attributeID] + value
                else
                    attributes[activeCondition][attributeID] = value
                end
            end

            for attributeID, value in pairs(attributes_fromPassiveSkills[activeCondition] or {}) do
                if attributes[activeCondition][attributeID] then
                    attributes[activeCondition][attributeID] = attributes[activeCondition][attributeID] + value
                else
                    attributes[activeCondition][attributeID] = value
                end
            end
        end

        attributesCache.all[cacheKey] = attributes
    end

    if v2 then
        local result = {}

        for activeCondition = 0, 3 do
            result[activeCondition] = attributesCache.all[cacheKey][activeCondition][Global.GetAttributeLongID(v1, v2)] or 0
        end

        return result
    elseif v1 then
        local result = {}

        for activeCondition = 0, 3 do
            result[activeCondition] = attributesCache.all[cacheKey][activeCondition][v1] or 0
        end
        
        return result
    end

    return attributesCache.all[cacheKey]
end

function GetAttributes(heroInfo, v1, v2)
    if Global.GetMobaMode() == 1 then
        return GetAttributesMoba(heroInfo, v1, v2)
    else
        return GetAttributesNormal(heroInfo, v1, v2)
    end
end

function CalAttributeBonus()
    local bonuses = {}

    for _, heroInfo in ipairs(generals) do
        if Global.GetMobaMode() == 1 then
        local heroData = TableMgr:GetMobaHeroData(heroInfo.baseid)
        for v in string.gsplit(heroData.HeroAttribute, ";") do
            local attrList = string.split(v, ",")
            local armyType = tonumber(attrList[1])
            local attrType = tonumber(attrList[2])
            local attrValue = tonumber(attrList[3])

            local bonus = {}
            bonus.BonusType = armyType
            bonus.Attype = attrType
            bonus.Value = attrValue

            table.insert(bonuses, bonus)
        end
        else
        local buildingType = heroInfo.appointInfo.buildType
        if buildingType ~= 0 then
            local buildingData = TableMgr:GetBuildingData(buildingType)
            local attributes = GetAttributes(heroInfo)
            for i = 1, 3 do
                local bonusAttributeType = buildingData["attrType" .. i]
                if bonusAttributeType ~= 0 then
                    local value = attributes[Global.GetAttributeLongID(10000, buildingData.appointattr)] * buildingData["value" .. i]
                    local bonusArmyType = buildingData["armyType" .. i]

                    local bonus = {}
                    bonus.BonusType = bonusArmyType
                    bonus.Attype = bonusAttributeType
                    bonus.Value = value
                    
                    table.insert(bonuses, bonus)
                end
            end

            for skillIndex, stringIDs in ipairs(string.split(TableMgr:GetHeroData(heroInfo.baseid).passiveskill, ";")) do
                if skillIndex <= heroInfo.star then
                    for stringID in string.gsplit(stringIDs, ",") do
                        if tonumber(stringID) ~= 0 then
                            local skillData = TableMgr:GetPassiveSkillData(tonumber(stringID))
                            if skillData.ActiveCondition == 1 and skillData.Coef == buildingType then
                                for i = 1, 10 do
                                    local bonusAttributeType = skillData["AttrType" .. i]
                                    if bonusAttributeType ~= 0 then
                                        local bonusArmyType = skillData["ArmyType" .. i]

                                        local bonus = {}
                                        bonus.BonusType = bonusArmyType
                                        bonus.Attype = bonusAttributeType
                                        bonus.Value = attributes[Global.GetAttributeLongID(bonusArmyType, bonusAttributeType)]

                                        table.insert(bonuses, bonus)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        end
    end

    return bonuses
end

local isRequesting = false
function UseExpItems(heroUID,baseID, items, callback)
    if not isRequesting then
        local request = HeroMsg_pb.MsgHeroAddExpRequest()
        request.heroUid = heroUID

        for itemUID, num in pairs(items) do
            card = request.card:add()
            card.uid = itemUID
            card.num = num
        end

        isRequesting = true
        Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgHeroAddExpRequest, request, HeroMsg_pb.MsgHeroAddExpResponse, function(msg)
            isRequesting = false

            if msg.code == ReturnCode_pb.Code_OK then
                SeenHeroIDs[baseID] = nil
                MainCityUI.UpdateRewardData(msg.fresh)
            else
                Global.ShowError(msg.code)
            end

            if callback then
                callback()
            end
        end, true)
    end
end

function GetAppointmentSkillForBuilding(heroInfo, heroData, buildingID)
    local effectiveSkills = {}

    for skillIndex, stringID in ipairs(string.split(heroData.showpassiveskill, ";")) do
        if tonumber(stringID) ~= 0 then
            if skillIndex <= heroInfo.star then
                local skillData = TableMgr:GetPassiveSkillData(tonumber(stringID))
                if skillData.ActiveCondition == 1 and skillData.Coef == buildingID then
                    table.insert(effectiveSkills, skillData)
                end
            else
                break
            end
        end
    end

    for skillIndex, stringIDs in ipairs(string.split(TableMgr:GetHeroData(heroInfo.baseid).passiveskill, ";")) do
        if skillIndex <= heroInfo.star then
            for stringID in string.gsplit(stringIDs, ",") do
                if tonumber(stringID) ~= 0 then
                    local skillData = TableMgr:GetPassiveSkillData(tonumber(stringID))
                    if skillData.ActiveCondition == 1 and skillData.Coef == buildingID then
                        table.insert(effectiveSkills, skillData)
                    end
                end
            end
        else
            break
        end
    end

    return effectiveSkills
end

function HasAppointmentSkillForBuilding(heroInfo, heroData, buildingID)
    for skillIndex, stringID in ipairs(string.split(heroData.showpassiveskill, ";")) do
        if tonumber(stringID) ~= 0 then
            if skillIndex <= heroInfo.star then
                local skillData = TableMgr:GetPassiveSkillData(tonumber(stringID))
                if skillData.ActiveCondition == 1 and skillData.Coef == buildingID then
                    return true
                end
            else
                break
            end
        end
    end

    for skillIndex, stringIDs in ipairs(string.split(TableMgr:GetHeroData(heroInfo.baseid).passiveskill, ";")) do
        if skillIndex <= heroInfo.star then
            for stringID in string.gsplit(stringIDs, ",") do
                if tonumber(stringID) ~= 0 then
                    local skillData = TableMgr:GetPassiveSkillData(tonumber(stringID))
                    if skillData.ActiveCondition == 1 and skillData.Coef == buildingID then
                        return true
                    end
                end
            end
        else
            break
        end
    end

    return false
end

local compareFunctions = { ["0"] = function(heroInfo1, heroInfo2)
                                        local new_state1 = GetHeroNewState(heroInfo1.baseid)
                                        local new_state2 = GetHeroNewState(heroInfo2.baseid)

                                        if(new_state1 ~= new_state2) then
                                            return new_state1;
                                        end

                                        local heroData1 = TableMgr:GetHeroData(heroInfo1.baseid)
                                        local heroData2 = TableMgr:GetHeroData(heroInfo2.baseid)

                                        if heroData1.expCard ~= heroData2.expCard then
                                            return not heroData1.expCard
                                        elseif heroData1.quality ~= heroData2.quality then
                                            return heroData1.quality > heroData2.quality     
                                        elseif heroInfo1.level ~= heroInfo2.level then
                                            return heroInfo1.level > heroInfo2.level
                                        elseif heroInfo1.star ~= heroInfo2.star then
                                            return heroInfo1.star > heroInfo2.star
                                        elseif heroInfo1.grade ~= heroInfo2.grade then
                                            return heroInfo1.grade < heroInfo2.grade
                                        else
                                            return heroInfo1.baseid < heroInfo2.baseid
                                        end
                                   end,                                                          }

function GetCompareFunction(sortingConfig)
    if sortingConfig then
        if not compareFunctions[sortingConfig] then
            compareFunctions[sortingConfig] = function(heroInfo1, heroInfo2)

                local new_state1 = GetHeroNewState(heroInfo1.baseid)
                local new_state2 = GetHeroNewState(heroInfo2.baseid)

                if(new_state1 ~= new_state2) then
                    return new_state1;
                end

                local sortingRuleInfo = string.split(sortingConfig, ":")
                local activeCondition = tonumber(sortingRuleInfo[1])

                local attributes1 = GetAttributes(heroInfo1)
                local attributes2 = GetAttributes(heroInfo2)

                for stringIDs in string.gsplit(sortingRuleInfo[2], ";") do
                    local bonus1 = 0
                    local bonus2 = 0
                    for stringID in string.gsplit(stringIDs, "+") do
                        local attributeID = tonumber(stringID)
                        if attributeID then
                            bonus1 = bonus1 + (attributes1[attributeID] or 0)
                            bonus2 = bonus2 + (attributes2[attributeID] or 0)
                        end
                    end

                    if bonus1 ~= bonus2 then
                        return bonus1 > bonus2
                    end
                end

                return compareFunctions["0"](heroInfo1, heroInfo2)
            end
        end

        return compareFunctions[sortingConfig]
    else
        return compareFunctions["0"]
    end
end

function CompareGenerals(heroInfo1, heroInfo2, sortingConfig)
    return GetCompareFunction(sortingConfig)(heroInfo1, heroInfo2)
end

function SortGenerals(sortingConfig)
    table.sort(generals, GetCompareFunction(sortingConfig))
end

function GetDefaultHeroData(heroData, level, star, smallStar, grade)
    if not level then
        level = 1
    end

    if not star then
        star = 1
    end

    if not smallStar then
        smallStar = 1
    end

    if not grade then
        grade = 1
    end

    local heroInfo = Common_pb.HeroInfo()

    heroInfo.uid = 0
    heroInfo.baseid = heroData.id

    heroInfo.level = level
    heroInfo.exp = 0

    heroInfo.star = star
    heroInfo.grade = smallStar

    heroInfo.heroGrade = grade

    heroInfo.skill.godSkill.id = tonumber(heroData.skillId)
    heroInfo.skill.godSkill.level = star

    heroInfo.skill.pvpSkill.id = heroData.slgskillId
    heroInfo.skill.pvpSkill.level = star

    return heroInfo
end

function Duplicate(heroInfo)
    local heroInfo_duplicated = Common_pb.HeroInfo()

    heroInfo_duplicated.uid = heroInfo.uid
    heroInfo_duplicated.baseid = heroInfo.baseid
    heroInfo_duplicated.star = heroInfo.star
    heroInfo_duplicated.exp = heroInfo.exp
    heroInfo_duplicated.level = heroInfo.level
    heroInfo_duplicated.grade = heroInfo.grade
    heroInfo_duplicated.heroGrade = heroInfo.heroGrade

    heroInfo_duplicated.skill.godSkill.id = heroInfo.skill.godSkill.id
    heroInfo_duplicated.skill.godSkill.level = heroInfo.skill.godSkill.level

    heroInfo_duplicated.skill.pvpSkill.id = heroInfo.skill.pvpSkill.id
    heroInfo_duplicated.skill.pvpSkill.level = heroInfo.skill.pvpSkill.level

    return heroInfo_duplicated
end

--[[
function Initialize(msg)
    SetData(msg)

    EventDispatcher.Bind(ItemListData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.DELAYED, function(params)
        UpdateNoticeStatus()
    end)
end
--]]

function DumpGeneralAttributes() -- GeneralData.DumpGeneralAttributes()
    local file = io.open("d:/[DEBUG]GeneralAttributes.lua", "w")

    SortGenerals()

    for _, heroInfo in ipairs(generals) do
        local heroData = TableMgr:GetHeroData(heroInfo.baseid)
        
        file:write(string.format("[%d]\t%s\t\tLv: %d\t\tstar: %d-%d\tbadge: %d\n", heroInfo.baseid, Global.GTextMgr:GetText(heroData.nameLabel), heroInfo.level, heroInfo.star, heroInfo.grade, heroInfo.heroGrade))
        
        for activeCondition, attributes in pairs(GetAttributes(heroInfo)) do
            file:write(string.format("\tactiveCondition = %d\n", activeCondition))

            for attributeID, value in pairs(attributes) do
                file:write(string.format("\t\t\t\t\t\t[%9d]\t%.2f\n", attributeID, value))
            end    
        end

        file:write("\n")
        file:write("\n")
    end

    file:close()
end

function DumpAppointmentAttributeBonus() -- GeneralData.DumpAppointmentAttributeBonus()
    local file = io.open("d:/[DEBUG]GeneralAppointment.lua", "w")
    
    local attributes = {}
    for _, bonus in ipairs(CalAttributeBonus()) do
        local attributeID = Global.GetAttributeLongID(bonus.BonusType, bonus.Attype)

        if not attributes[attributeID] then
            attributes[attributeID] = bonus.Value
        else
            attributes[attributeID] = attributes[attributeID] + bonus.Value
        end
    end

    for attributeID, value in pairs(attributes) do
        file:write(string.format("[%9d]\t%.2f\n", attributeID, value))
    end

    file:close()
end


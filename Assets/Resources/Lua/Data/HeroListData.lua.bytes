module("HeroListData", package.seeall)

local GatherAttrList =
{
   	[Common_pb.SceneEntryType_None] = 1008,
	[Common_pb.SceneEntryType_ResFood] = 1009,				--资源-粮食
	[Common_pb.SceneEntryType_ResIron] = 1010,				--资源-铁矿
	[Common_pb.SceneEntryType_ResOil] = 1011,				--资源-石油矿
	[Common_pb.SceneEntryType_ResElec] = 1012,				--资源-电能矿

}

local UnionGatherAttrList =
{
    [GuildMsg_pb.GuildResType_Food] = 1009,				--资源-粮食
    [GuildMsg_pb.GuildResType_Iron] = 1010,				--资源-铁矿
    [GuildMsg_pb.GuildResType_Oil] = 1011,				--资源-石油矿
    [GuildMsg_pb.GuildResType_Elec] = 1012,				--资源-电能矿
}

local MoveAttrList =
{
    [Common_pb.TeamMoveType_None] = 1004,
	[Common_pb.TeamMoveType_ResTake] = 1005,			--资源采集
	[Common_pb.TeamMoveType_MineTake] = 1005,			--超级矿采集
	[Common_pb.TeamMoveType_TrainField] = 1007,		--训练场
	[Common_pb.TeamMoveType_Garrison] = 1007,			--驻防
	[Common_pb.TeamMoveType_GatherCall] = 1007,		--发起集结
	[Common_pb.TeamMoveType_GatherRespond] = 1007,		--响应集结
	[Common_pb.TeamMoveType_AttackMonster] = 1006,		--攻击怪
	[Common_pb.TeamMoveType_AttackPlayer] = 1007,		--攻击玩家
	--[Common_pb.TeamMoveType_ReconPlayer] = 9,		--侦查玩家
	--[Common_pb.TeamMoveType_ReconMonster] = 10,		--侦查怪
	[Common_pb.TeamMoveType_Camp] = 1007,				--扎营
	[Common_pb.TeamMoveType_Occupy] = 1007,			--占领
	--[Common_pb.TeamMoveType_ResTransport] = 13,		--资源运输
	[Common_pb.TeamMoveType_GuildBuildCreate] = 1007,	--联盟建筑
	--[Common_pb.TeamMoveType_MonsterSiege] = 15,	--怪物攻城
	[Common_pb.TeamMoveType_AttackFort] = 1007,		--攻击要塞
	[Common_pb.TeamMoveType_AttackCenterBuild] = 1007,		--攻击政府
	[Common_pb.TeamMoveType_GarrisonCenterBuild] = 1007,  	--驻防政府
}

MaxAttrCount = 7
HeroStatePVE = 1
HeroStateDefense = 2
HeroStateSetout = 4
HeroStateAppoint = 8

local heroListData = {}
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

local coefRuleList

local badgeIdListCache1 = {}
function GetBadgeIdList(badge)
    local badgeIdList = badgeIdListCache1[badge]
    if badgeIdList == nil then
        badgeIdList = {}
        for v in string.gsplit(badge, ";") do
            table.insert(badgeIdList, tonumber(v))
        end
        badgeIdListCache1[badge] = badgeIdList
    end

    return badgeIdList
end

function GetPowerCoef(heroPower)
    if coefRuleList == nil then
        coefRuleList = {}
        for k, v in pairs(tableData_tCoefRule.data) do
            table.insert(coefRuleList, {k, v})
        end
        table.sort(coefRuleList, function(v1, v2)
            return v1[1] < v2[1]
        end)
    end

    if heroPower <= 0 then
        return 0
    end

    for i ,v in ipairs(coefRuleList) do
        if v[1] > heroPower then
            return coefRuleList[i - 1][2].coefficient
        end
    end

    return coefRuleList[#coefRuleList][2].coefficient
end

function Sort1Function(v1, v2)
    local heroData1 = TableMgr:GetHeroData(v1.baseid)
    local heroData2 = TableMgr:GetHeroData(v2.baseid)
    if heroData1.expCard and not heroData2.expCard or not heroData1.expCard and heroData2.expCard then
        return not heroData1.expCard and heroData2.expCard
    else
        if v1.level == v2.level then
            if heroData1.quality == heroData2.quality then
                if v1.star == v2.star then
                    if v1.grade == v2.grade then
                        return v1.baseid < v2.baseid
                    end
                    return v1.grade < v2.grade
                end
                return v1.star > v2.star
            end
            return heroData1.quality > heroData2.quality
        end
        return v1.level > v2.level
    end
end

function Sort1()
    table.sort(heroListData, Sort1Function)
end

function GetData()
    return heroListData
end

function SetData(data)
    heroListData = data
    Sort1()
end

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function GetHeroDataByBaseId(baseId)
    for _, v in ipairs(heroListData) do
        if v.baseid == baseId then
            return v
        end
    end
    return nil
end

function HasHeroByBaseId(baseId)
    return GetHeroDataByBaseId(baseId) ~= nil
end

function GetHeroDataByUid(uid)
    for _, v in ipairs(heroListData) do
        if v.uid == uid then
            return v
        end
    end
    return nil
end

function HasHeroByUid(uid)
    return GetHeroDataByUid(uid) ~= nil
end

local function FreshHero(heroData)
    for i, v in ipairs(heroListData) do
        if v.uid == heroData.uid then
            heroListData[i] = heroData
            return
        end
    end
    error("fresh hero error uid:", heroData.uid)
end

local function DeleteHero(heroData)
    for i, v in ipairs(heroListData) do
        if v.uid == heroData.uid then
            heroListData:remove(i)
            return
        end
    end
    error("fresh hero error uid:", heroData.uid)
end

function UpdateData(data)
    local deleteHero = false
    for _, v in ipairs(data.data) do
        if v.optype == Common_pb.FreshDataType_Add then
            local heroData = TableMgr:GetHeroData(v.data.baseid) 
            if not heroData.expCard then
                heroListData:add()
                heroListData[#heroListData] = v.data
                ActiveHeroData.AddNewHero(v.data.baseid)
            else
                local _hero = GetHeroDataByBaseId(v.data.baseid)
                if _hero == nil then
                    heroListData:add()
                    heroListData[#heroListData] = v.data
                    ActiveHeroData.AddNewHero(v.data.baseid)
                else
                    _hero.num = v.data.num
                end
            end
        elseif v.optype == Common_pb.FreshDataType_Fresh then
            FreshHero(v.data)
        elseif v.optype == Common_pb.FreshDataType_Delete then
            DeleteHero(v.data)
            deleteHero = true
        elseif v.optype == Common_pb.FreshDataType_FlagAdd then
        end
    end

    if deleteHero then
        TeamData.NormalizeData()
    end
    if #data.data > 0 then
        Sort1()
        NotifyListener()
    end
end

function IsHeroPVE(heroUid)
    return TeamData.IsHeroSelectedByUid(Common_pb.BattleTeamType_Main, heroUid)
end

function IsHeroDefense(heroUid)
    return TeamData.IsHeroSelectedByUid(Common_pb.BattleTeamType_CityDefence, heroUid)
end

function IsHeroSetout(heroUid)
    return ArmySetoutData.HasHeroSetout(heroUid)
end

function IsHeroAppoint(heroUid)
    local heroMsg = GetHeroDataByUid(heroUid)
    return heroMsg.appointInfo.buildType ~= 0
end

function IsHeroPVEOrAppoint(heroUid)
    return IsHeroPVE(heroUid) or IsHeroAppoint(heroUid)
end

function IsHeroAvailableForExpediation(uid)
    return not IsHeroDefense(uid) and not IsHeroSetout(uid)
end

function GetPreviousHeroData(uid)
    for i, v in ipairs(heroListData) do
        if v.uid == uid then
            return heroListData[i - 1]
        end
    end
end

function GetNextHeroData(uid)
    for i, v in ipairs(heroListData) do
        if v.uid == uid then
            return heroListData[i + 1]
        end
    end
end

function GetBadgeData(heroMsg, badgeId)
    for _, v in ipairs(heroMsg.badge) do
        if v.baseid == badgeId then
            return v
        end
    end
end

local badgeAttrCache = {}
function GetBadgeAttr(badgeId, badgeQuality)
    local cacheId = badgeId * 100 + badgeQuality
    local badgeAttr = badgeAttrCache[cacheId]
    if badgeAttr == nil then
        local badgeData = TableMgr:GetBadgeDataByIdQuality(badgeId, badgeQuality)
        local needTextData = TableMgr:GetNeedTextDataByAddition(badgeData.armyType, badgeData.attrType)
        badgeAttr = {id = needTextData.id, data = needTextData, value = badgeData.value}
        badgeAttrCache[cacheId] = badgeAttr
    end

    return badgeAttr
end

local starAttrListCache = {}
function GetStarAttrList(heroMsg, heroData)
    local cacheId = heroMsg.baseid * 1000000 + heroMsg.level * 10000 + heroMsg.star * 100 + heroMsg.grade

    local starAttrList = starAttrListCache[cacheId]
    if starAttrList == nil then
        starAttrList = {}
        local heroStarUpData = TableMgr:GetHeroStarUpDataByHeroIdStarGrade(heroMsg.baseid, heroMsg.star, heroMsg.grade)
        for i = 1, MaxAttrCount do
            local additionArmy = heroData["additionArmy" .. i]
            local additionAttr = heroData["additionAttr" .. i]
            local needTextData = TableMgr:GetNeedTextDataByAddition(additionArmy, additionAttr)
            local attrId = needTextData.id
            if heroStarUpData ~= nil then
                if starAttrList[attrId] == nil then
                    starAttrList[attrId] = {}
                    starAttrList[attrId].data = needTextData
                    starAttrList[attrId].value = 0
                end
                local defaultValue = heroStarUpData["defaultValue" .. i]
                local growValue = heroStarUpData["growValue" .. i]
                starAttrList[attrId].value = starAttrList[attrId].value + defaultValue + (heroMsg.level - 1) * growValue
            end
        end

        starAttrListCache[cacheId] = starAttrList
    end

    return starAttrList
end

local gradeAttrListCache = {}
function GetGradeAttrList(heroMsg, heroData)
    local cacheId = heroMsg.baseid * 100 + heroMsg.heroGrade

    local gradeAttrList = gradeAttrListCache[cacheId]
    if gradeAttrList == nil then
        gradeAttrList = {}
        local heroGradeUpData = TableMgr:GetHeroGradeUpDataByHeroIdGrade(heroMsg.baseid, heroMsg.heroGrade)
        for i = 1, MaxAttrCount do
            local additionArmy = heroData["additionArmy" .. i]
            local additionAttr = heroData["additionAttr" .. i]
            local needTextData = TableMgr:GetNeedTextDataByAddition(additionArmy, additionAttr)
            local attrId = needTextData.id
            if heroGradeUpData ~= nil then
                if gradeAttrList[attrId] == nil then
                    gradeAttrList[attrId] = {}
                    gradeAttrList[attrId].data = needTextData
                    gradeAttrList[attrId].value = 0
                end
                local defaultValue = heroGradeUpData["value".. i]
                gradeAttrList[attrId].value = gradeAttrList[attrId].value + defaultValue
            end
        end

        gradeAttrListCache[cacheId] = gradeAttrList
    end

    return gradeAttrList
end

function GetAttrList(heroMsg, heroData)
    local attrList = {}
    local badgeIdList = GetBadgeIdList(heroData.badge)
    for _, v in ipairs(badgeIdList) do
        local badgeMsg = GetBadgeData(heroMsg, v)
        if badgeMsg ~= nil then
            local badgeAttr = GetBadgeAttr(v, badgeMsg.quality)
            local attrId = badgeAttr.id
            if attrList[attrId] == nil then
                attrList[attrId] = {}
                attrList[attrId].data = badgeAttr.data
                attrList[attrId].value = 0
            end
            attrList[attrId].value = attrList[attrId].value + badgeAttr.value
        end
    end

    local starAttrList = GetStarAttrList(heroMsg, heroData)
    for kk, vv in pairs(starAttrList) do
        if attrList[kk] == nil then
            attrList[kk] = {}
            attrList[kk].data = vv.data
            attrList[kk].value = 0
        end
        attrList[kk].value = attrList[kk].value + vv.value
    end

    local gradeAttrList = GetGradeAttrList(heroMsg, heroData)
    for kk, vv in pairs(gradeAttrList) do
        if attrList[kk] == nil then
            attrList[kk] = {}
            attrList[kk].data = vv.data
            attrList[kk].value = 0
        end
        attrList[kk].value = attrList[kk].value + vv.value
    end

    return attrList
end

function GetBadgeList(heroMsg, heroData)
    local badgeList = {}
    local badgeIndex = 1
    local badgeIdList = GetBadgeIdList(heroData.badge)
    for _, v in ipairs(badgeIdList) do
        local badge = {}
        local badgeMsg = GetBadgeData(heroMsg, v)
        local badgeQuality = 1
        if badgeMsg ~= nil then
            badge.msg = badgeMsg
            badgeQuality = badgeMsg.quality
        end
        local badgeData = TableMgr:GetBadgeDataByIdQuality(v, badgeQuality)
        badge.data = badgeData
        local targetBadgeData = nil
        targetBadgeData = TableMgr:GetBadgeDataByIdQuality(v, badgeQuality + 1)
        badge.targetData = targetBadgeData
        badge.maxQuality = targetBadgeData == nil
        local targetLevel = targetBadgeData ~= nil and targetBadgeData.unlockLevel or badgeData.unlockLevel
        badge.targetLevel = targetLevel
        badge.levelEnough = false
        badge.itemEnough = false
        badge.gradeEnough = false

        if heroMsg.level >= targetLevel then
            badge.levelEnough = true
        end

        if targetBadgeData ~= nil and ItemListData.HaveEnoughBadgeItem(targetBadgeData) then
            badge.itemEnough = true
        end

        if targetBadgeData ~= nil and heroMsg.heroGrade >= targetBadgeData.heroGrade then
            badge.gradeEnough = true
        end

        badgeList[badgeIndex] = badge
        badgeIndex = badgeIndex  + 1
    end

    return badgeList
end

function GetAttrBadgeList(heroMsg, heroData)
    return GetAttrList(heroMsg, heroData), GetBadgeList(heroMsg, heroData)
end

function GetPowerByAttrList(attrList)
    local power = 0
    for _, v in pairs(attrList) do
        local data = v.data
        local fightId = data.additionArmy * 10000 + data.additionAttr
        local fightData = TableMgr:GetFightData(fightId)
        if fightData == nil then
            power = power + v.value * TableMgr:GetFightData(0).coef
        else
            power = power + v.value * fightData.coef
        end
    end
    return math.floor(power)
end

function GetPower(heroMsg, heroData)
    local attrList = GetAttrList(heroMsg, heroData)
    return GetPowerByAttrList(attrList)
end

function GetTroopsByAttrList(attrList)
    local troops = 0
    for _, v in pairs(attrList) do
        local data = v.data
        if data.additionArmy == 0 and data.additionAttr == 1102 then
            troops = troops + v.value
        end
    end

    return troops
end

function GetTroops(heroMsg, heroData)
    local attrList = GetAttrList(heroMsg, heroData)
    return GetTroopsByAttrList(attrList)
end

function GetPassiveSkillValue(passiveSkillData, heroLevel)
    return passiveSkillData.DefaultValue1 + (heroLevel - 1) * passiveSkillData.GrowValue1
end

function GetPassiveSkillShowValue(passiveSkillData, heroLevel)
    local value = GetPassiveSkillValue(passiveSkillData, heroLevel)
    return passiveSkillData.sign == 0 and value or -value
end

function GetAppointSkillDataByBuildingId(heroData, buildingId)
    for v in string.gsplit(heroData.passiveskill, ";") do
        local passiveSkillId = tonumber(v)
        if passiveSkillId ~= nil then
            local skillData = TableMgr:GetPassiveSkillData(passiveSkillId)
            if skillData.ActiveCondition == 1 and skillData.Coef == buildingId then
                return skillData
            end
        end
    end

    return nil
end

function HasAppointSkillDataByBuildingId(heroData, buildingId)
    return GetAppointSkillDataByBuildingId(heroData, buildingId) ~= nil
end

function GetAppointSkillDataByHeroMsgData(heroMsg, heroData)
    if heroMsg.appointInfo.buildType ~= 0 then
        local buildType = heroMsg.appointInfo.buildType
        return GetAppointSkillDataByBuildingId(heroData, buildType)
    end

    return nil
end

function GetAppointSkillDataByHeroUid(heroUid)
    local heroMsg = GetHeroDataByUid(heroUid)
    if heroMsg.appointInfo.buildType ~= 0 then
        local heroData = TableMgr:GetHeroData(heroMsg.baseid)
        return GetAppointSkillDataByHeroMsgData(heroMsg, heroData)
    end

    return nil
end

function GetAppointSkillDataValueByHeroMsgData(heroMsg, heroData)
    if heroMsg.appointInfo.buildType ~= 0 then
        local passiveSkillData = GetAppointSkillDataByHeroMsgData(heroMsg, heroData)
        if passiveSkillData ~= nil then
            return passiveSkillData, GetPassiveSkillValue(passiveSkillData, heroMsg.level)
        end
    end

    return nil
end

function GetAppointSkillDataValueByHeroUid(heroUid)
    local heroMsg = GetHeroDataByUid(heroUid)
    local heroData = TableMgr:GetHeroData(heroMsg.baseid)

    return GetAppointSkillDataValueByHeroMsgData(heroMsg, heroData)
end

function ForeachSetoutSkillData(heroData, func)
    for v in string.gsplit(heroData.passiveskill, ";") do
        local passiveSkillId = tonumber(v)
        if passiveSkillId ~= nil then
            local skillData = TableMgr:GetPassiveSkillData(passiveSkillId)
            if skillData.ActiveCondition == 2 then
                func(skillData)
            end
        end
    end
end

function GetGatherAttrValue(tileMsg, passiveSkillData, heroLevel)
    if tileMsg == nil then
        return 0
    end

    local attrValue = 0
    local entryType = tileMsg.data.entryType
    for i = 1, 3 do
        local armyType = passiveSkillData["ArmyType" .. i]
        if armyType == 0 then
            local attrType = passiveSkillData["AttrType" .. i]
            local hasValue = false
            if attrType == GatherAttrList[Common_pb.SceneEntryType_None] then
                hasValue = true
            else
                if entryType >= Common_pb.SceneEntryType_ResFood and entryType <= Common_pb.SceneEntryType_ResElec then
                    if attrType == GatherAttrList[entryType]then
                        hasValue = true
                    end
                elseif entryType == entryType == Common_pb.SceneEntryType_GuildBuild then
                    if attrType == UnionGatherAttrList[tileMsg.guildbuild.baseid] then
                        hasValue = true
                    end
                end
            end
            if hasValue then
                attrValue = attrValue + GetPassiveSkillValue(passiveSkillData, heroLevel)
            end
        end
    end

    return attrValue
end

function GetGatherAttrValueByHeroMsgData(tileMsg, heroMsg, heroData)
    local attrValue = 0
    ForeachSetoutSkillData(heroData, function(skillData)
        attrValue = attrValue + GetGatherAttrValue(tileMsg, skillData, heroMsg.level)
    end)

    return attrValue
end

function GetGatherAttrValueByHeroUid(tileMsg, heroUid)
    local heroMsg = GetHeroDataByUid(heroUid)
    local heroData = TableMgr:GetHeroData(heroMsg.baseid)

    return GetGatherAttrValueByHeroMsgData(tileMsg, heroMsg, heroData)
end

function GetMoveAttrValue(moveType, passiveSkillData, heroLevel)
    local attrValue = 0
    for i = 1, 3 do
        local armyType = passiveSkillData["ArmyType" .. i]
        if armyType == 0 then
            local attrType = passiveSkillData["AttrType" .. i]
            local hasValue = false
            if attrType == MoveAttrList[Common_pb.TeamMoveType_None] then
                hasValue = true
            else
                if attrType == MoveAttrList[moveType] then
                    hasValue = true
                end
            end
            if hasValue then
                attrValue = attrValue + GetPassiveSkillValue(passiveSkillData, heroLevel)
            end
        end
    end

    return attrValue
end

function GetMoveAttrValueByHeroMsgData(moveType, heroMsg, heroData)
    local attrValue = 0
    ForeachSetoutSkillData(heroData, function(skillData)
        attrValue = attrValue + GetMoveAttrValue(moveType, skillData, heroMsg.level)
    end)

    return attrValue
end

function GetMoveAttrValueByHeroUid(moveType, heroUid)
    local heroMsg = GetHeroDataByUid(heroUid)
    local heroData = TableMgr:GetHeroData(heroMsg.baseid)

    return GetMoveAttrValueByHeroMsgData(moveType, heroMsg, heroData)
end

function GetWeight(passiveSkillData, heroLevel)
    local weight = 0
    for i = 1, 3 do
        local armyType = passiveSkillData["ArmyType" .. i]
        if armyType == 10000 then
            local attrType = passiveSkillData["AttrType" .. i]
            if attrType == 21 then
                weight = weight + GetPassiveSkillValue(passiveSkillData, heroLevel)
            end
        end
    end

    return weight
end

function GetWeightByHeroMsgData(heroMsg, heroData)
    local weight = 0
    ForeachSetoutSkillData(heroData, function(skillData)
        weight = weight + GetWeight(skillData, heroMsg.level)
    end)

    return weight
end

function GetWeightByHeroUid(heroUid)
    local heroMsg = GetHeroDataByUid(heroUid)
    local heroData = TableMgr:GetHeroData(heroMsg.baseid)

    return GetWeightByHeroMsgData(heroMsg, heroData)
end

function HasNotAppointedHero()
    for _, v in ipairs(heroListData) do
        if v.appointInfo.buildType == 0 then
            local heroData = TableMgr:GetHeroData(v.baseid)
            if not heroData.expCard then
                return true
            end
        end
    end

    return false
end

function HasBradgeCanUpgrade(badgeList)
    for _, v in pairs(badgeList) do
        if not v.maxQuality and v.levelEnough and v.itemEnough and v.gradeEnough then
            return true
        end
    end
    return false
end

function HasMoreThanQualityBradgeCanUpgrade(quality)
    for _, v in ipairs(heroListData) do
        if IsHeroPVEOrAppoint(v.uid) then
            local heroData = TableMgr:GetHeroData(v.baseid)
            if heroData.quality >= quality then
                local badgeList = GetBadgeList(v, heroData)
                if HasBradgeCanUpgrade(badgeList) then
                    return true
                end
            end
        end
    end

    return false
end

function CanStarUpgrade(heroMsg, heroData)
    local star = heroMsg.star
    if star == 6 then
        return false
    end

    local rulesData = TableMgr:GetRulesDataByStarGrade(heroMsg.star, heroMsg.grade)
    local itemMsg = ItemListData.GetItemDataByBaseId(heroData.chipID)
    return itemMsg ~= nil and itemMsg.number >= rulesData.num
end

function HasMoreThanQualityCanStarUpgrade(quality)
    for _, v in ipairs(heroListData) do
        local heroData = TableMgr:GetHeroData(v.baseid)
        if heroData.quality >= quality and CanStarUpgrade(v, heroData) then
            return true
        end
    end

    return false
end

function GetMaxStarHeroData(baseId)
    local maxStar = -1
    local heroMsg
    for _, v in ipairs(heroListData) do
        if v.baseid == baseId and v.star > maxStar then
            maxStar = v.star
            heroMsg = v
        end
    end

    return heroMsg
end

function IsRecommendStarUp(heroMsg, heroData)
    return CanStarUpgrade(heroMsg, heroData)
end

function CanLevelUp(heroMsg, heroData)
    local rulesData = TableMgr:GetRulesDataByStarGrade(heroMsg.star, heroMsg.grade)
    local maxLevel = rulesData.maxlevel
    
    -------------------------------
    --n级 以上才开启等级显示红点
    local unlock_level_data = TableMgr:GetGlobalData(100222)
    local unlock_level = 0
    if  unlock_level_data ~= nil then
        unlock_level = tonumber(unlock_level_data.value)
    end

    if heroMsg.level < unlock_level then
        return false
    end
    --------------------------------


    if heroMsg.level < maxLevel then
        local exp = 0
 
        ---可升满一级
        ---------------------------------
        local expData = TableMgr:GetHeroExpData(heroMsg.level)
        local levelexp = expData.levelExp
        local leftExp = levelexp - heroMsg.exp
        ---------------------------------

        
        for i = 1, 5 do
            local expDataList = TableMgr:GetItemDataListByTypeQuality(55, i)

            ------------------------------------
            for j, v in ipairs(expDataList) do
                if v ~= nil then
                    if leftExp <= 0 then
                        return true
                    end
                    local itemData = ItemListData.GetItemDataByBaseId(v.id)  
                    local cardCount = leftExp / itemData.param1
                    cardCount = math.min(cardCount, v.number) 
                    leftExp = leftExp - itemData.param1 * math.floor(cardCount)
                end
            end
            -------------------------------------

            --local expMsg = ItemListData.GetItemDataByBaseId(expDataList[1].id)
            --if expMsg ~= nil then
            --    return true
            --end
        end
    end
end

function IsRecommendLevelUp(heroMsg, heroData)
    return heroData.quality > 3 and IsHeroPVEOrAppoint(heroMsg.uid) and CanLevelUp(heroMsg, heroData)
end

function HasMoreThanQualityCanLevelUp(quality)
    for _, v in ipairs(heroListData) do
        if IsHeroPVEOrAppoint(v.uid) then
            local heroData = TableMgr:GetHeroData(v.baseid)
            if heroData.quality >= quality and CanLevelUp(v, heroData) then
                return true
            end
        end
    end

    return false
end

function CanGradeUpgrade(heroMsg, badgeList)
    local heroGradeUpData = TableMgr:GetHeroGradeUpDataByHeroIdGrade(heroMsg.baseid, heroMsg.heroGrade)
    local requiredBadgeGrade = 0
    if heroGradeUpData ~= nil then
        requiredBadgeGrade = heroGradeUpData.badgeGrade 
    end
    for i, v in ipairs(badgeList) do
        if v.msg == nil or v.msg.quality < requiredBadgeGrade then
            return false
        end
    end

    return true
end

function HeroHasNotice(heroMsg, heroData, badgeList)
    if heroMsg.uid == 0 then
        local shardCount = ItemListData.GetItemCountByBaseId(heroData.chipID)
        local requiredShardCount = heroData.chipnum
        return shardCount >= requiredShardCount
    end

    return IsRecommendLevelUp(heroMsg, heroData) or IsRecommendStarUp(heroMsg, heroData) or CanGradeUpgrade(heroMsg, badgeList) or (IsHeroPVEOrAppoint(heroMsg.uid) and HasBradgeCanUpgrade(badgeList))
end

function HasNotice()
    for _, v in ipairs(heroListData) do
        local heroData = TableMgr:GetHeroData(v.baseid)
        local badgeList = GetBadgeList(v, heroData)
        if HeroHasNotice(v, heroData, badgeList) then
            return true
        end
    end

    return false
end

function HasNoticeByUid(heroUid)
    local heroMsg = GetHeroDataByUid(heroUid)
    local heroData = TableMgr:GetHeroData(heroMsg.baseid)
    local badgeList = GetBadgeList(heroMsg, heroData)

    return HeroHasNotice(heroMsg, heroData, badgeList)
end

function HasBattleHero()
    for _, v in ipairs(heroListData) do
        local heroData = TableMgr:GetHeroData(v.baseid) 
        if not heroData.expCard then
            return true
        end
    end
    return false
end

function GetDefaultHeroData(heroData)
    local heroMsg = Common_pb.HeroInfo()
    heroMsg.uid = 0
    heroMsg.baseid = heroData.id
    heroMsg.star = 1
    heroMsg.exp = 0
    heroMsg.level = 1
    heroMsg.grade = 1
    heroMsg.skill.godSkill.id = tonumber(heroData.skillId)
    heroMsg.skill.godSkill.level = 1
    heroMsg.heroGrade = 1
    return heroMsg
end

function GetHeroTopPower()
    local heroTable = {}
    for _, v in ipairs(heroListData) do
        local hero = {}
        hero.data = TableMgr:GetHeroData(v.baseid)
        hero.power = GetPower(v, hero.data)
        hero.heroMsg = v
        table.insert(heroTable ,hero)
    end

    table.sort(heroTable , function(v1,v2)
        return v1.power > v2.power
    end)
    return heroTable
end

function GetHeroState(heroUid)
    local heroState = 0
    if IsHeroPVE(heroUid) then
        heroState = bit.bor(heroState, HeroStatePVE)
    end

    if IsHeroDefense(heroUid) then
        heroState = bit.bor(heroState, HeroStateDefense)
    end

    if IsHeroSetout(heroUid) then
        heroState = bit.bor(heroState, HeroStateSetout)
    end

    if IsHeroAppoint(heroUid) then
        heroState = bit.bor(heroState, HeroStateAppoint)
    end

    return heroState
end

function IsHeroPVEByState(heroState)
    return bit.band(heroState, HeroStatePVE) ~= 0
end

function IsHeroDefenseByState(heroState)
    return bit.band(heroState, HeroStateDefense) ~= 0
end

function IsHeroSetoutByState(heroState)
    return bit.band(heroState, HeroStateSetout) ~= 0
end

function IsHeroAppointByState(heroState)
    return bit.band(heroState, HeroStateAppoint) ~= 0
end

function IsHeroAvailableForExpediationByState(heroState)
    return not IsHeroDefenseByState(heroState) and not IsHeroSetoutByState(heroState)
end

function RegistAttributeModel()
    AttributeBonus.RegisterAttBonusModule(_M)
end

local GameTime = Serclimax.GameTime
function CalAttributeBonus()
    local bonusList = {}
    local buildingListData = BuildingData.GetData()
    for _, v in ipairs(buildingListData.buildList) do
        if v.type ~= 0 then
            local t = GameTime.GetMilSecTime()
            local data,attrValue , attrValue2 , attrValue3 = BuildingData.GetBuildingHeroAttrById(v.type)
            if data ~= nil then
                local bonus = {}
                bonus.BonusType = data.armyType1
                bonus.Attype = data.attrType1
                bonus.Value = attrValue
                table.insert(bonusList, bonus)

                if data.armyType2 ~= 0 and data.attrType2 ~= nil then
                    local bonus2 = {}
                    bonus2.BonusType = data.armyType2
                    bonus2.Attype = data.attrType2
                    bonus2.Value = attrValue2
                    table.insert(bonusList, bonus2)
                end

                if data.armyType3 ~= 0 and data.attrType3 ~= nil then
                    local bonus3 = {}
                    bonus3.BonusType = data.armyType3
                    bonus3.Attype = data.attrType3
                    bonus3.Value = attrValue3
                    table.insert(bonusList, bonus3)
                end

            end
        end
    end

    local heroListData = HeroListData.GetData()
    for _, v in ipairs(heroListData) do
        local herodata = TableMgr:GetHeroData(v.baseid)
        local pdata,attrValue = GetAppointSkillDataValueByHeroMsgData(v,herodata)
        if pdata ~= nil then
            local bonus = {}
            bonus.BonusType = pdata.ArmyType1
            bonus.Attype = pdata.AttrType1
            bonus.Value = attrValue
            table.insert(bonusList, bonus)
            if pdata.AttrType2 ~= 0 and pdata.AttrType2 ~= nil then
                local bonus2 = {}
                bonus2.BonusType = pdata.ArmyType2
                bonus2.Attype = pdata.AttrType2
                bonus2.Value = pdata.DefaultValue2 + (v.level - 1) * pdata.GrowValue2
                table.insert(bonusList, bonus2)                        
            end
            if pdata.AttrType3 ~= 0 and pdata.AttrType3 ~= nil then
                local bonus3 = {}
                bonus3.BonusType = pdata.ArmyType3
                bonus3.Attype = pdata.AttrType3
                bonus3.Value = pdata.DefaultValue3 + (v.level - 1) * pdata.GrowValue3
                table.insert(bonusList, bonus3)                        
            end 			
        end
    end    
    return bonusList
end

function GetHeroBattleMoveBuffs(heroMsg)
    local heroData = TableMgr:GetHeroData(heroMsg.baseid)
    local buffs = {}
    buffs[0] = GetPower(heroMsg, heroData)
    buffs[1] = GetTroops(heroMsg, heroData)
    
    for s in string.gsplit(heroData.passiveskill, ";") do
        local passiveSkillId = tonumber(s)
        if passiveSkillId ~= nil then
            local skillData = TableMgr:GetPassiveSkillData(passiveSkillId)
            if skillData.ActiveCondition == 2 then
                local skillValue = GetPassiveSkillValue(skillData, heroMsg.level)
                
                for ss in string.gsplit(skillData.BattleMoveBuff, ";") do
                    local buffId = tonumber(ss)
                    buffs[buffId] = (buffs[buffId] == nil and 0 or buffs[buffId]) + skillValue
                end
            end
        end
    end

    return buffs
end

function GetHeroSuggestionRule(teamMoveType, sEntryData)
    if sEntryData == nil or sEntryData.data.entryType == 0 then
        return 0
    elseif teamMoveType == Common_pb.TeamMoveType_ResTake and sEntryData.res.owner ~= 0 and sEntryData.res.owner ~= MainData.GetCharId() and (UnionInfoData.GetGuildId() == 0 or sEntryData.ownerguild.guildid ~= UnionInfoData.GetGuildId()) then -- 攻击别人正在采集的资源田
        return teamMoveType * 100 + 10 + sEntryData.data.entryType
    elseif teamMoveType == Common_pb.TeamMoveType_MineTake then -- 采集联盟矿
        return teamMoveType * 100 + TableMgr:GetUnionBuildingData(sEntryData.guildbuild.baseid).resourceType
    end

    return teamMoveType * 100 + sEntryData.data.entryType
end

function GetSortedHeroes(sortingConfig, heroList)
    if heroList == nil then heroList = heroListData end
    if sortingConfig ~= nil then
        local heroBuffs = {}
        for _, hero in ipairs(heroList) do
            local heroMsg = tonumber(hero) == nil and hero or GetHeroDataByUid(hero)
            heroBuffs[heroMsg.uid] = GetHeroBattleMoveBuffs(heroMsg)
        end

        table.sort(heroList, function(hero1, hero2)
            local heroMsg1 = tonumber(hero1) == nil and hero1 or GetHeroDataByUid(hero1)
            local heroMsg2 = tonumber(hero2) == nil and hero2 or GetHeroDataByUid(hero2)

            for s in string.gsplit(sortingConfig, ";") do
                local buffId = tonumber(s)
                if buffId ~= nil then
                    buff1 = heroBuffs[heroMsg1.uid][buffId] or 0
                    buff2 = heroBuffs[heroMsg2.uid][buffId] or 0
                    
                    if buff1 ~= buff2 then
                        return buff1 > buff2
                    end
                end
            end

            return heroMsg1.baseid > heroMsg2.baseid
        end)
    else
        table.sort(heroList, Sort1Function)
    end

    return heroList
end

function GetSuggestedHeroesForBattleMove(maxNumber, teamMoveType, sEntryData, heroList)
    local rule = TableMgr:GetHeroSuggestionRule(GetHeroSuggestionRule(teamMoveType, sEntryData))
    if rule == nil then
        if heroList == nil then
            return BattleMoveData.GetPreHeroList()
        else
            return heroList()
        end
    end

    local heroes = GetSortedHeroes(rule.sortingConfig, heroList)

    local suggestedHeroes = {}
    local selectedHeroes = {}
    for _, hero in pairs(heroes) do
        if selectedHeroes[hero.baseid] == nil then
            suggestedHeroes[#suggestedHeroes + 1] = hero.uid
            selectedHeroes[hero.baseid] = hero.uid

            if #suggestedHeroes == maxNumber then break end
        end
    end
    
    return suggestedHeroes
end

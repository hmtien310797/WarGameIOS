local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local Format = System.String.Format
local LogError = UnityEngine.Debug.LogError 
local LogWarning = UnityEngine.Debug.LogWarning 

module("TextUtil", package.seeall)

function GetMissionTitle(missionData)
    local Impl = function(missionData)
        local showType = missionData.showtype
        local paramList = string.split(missionData.param, ":")
        local number = missionData.number
        local p0
        local p1
        if showType == 1 then
            p0 = TextMgr:GetText(tableData_tBuilding.data[tonumber(paramList[1])].name)
            p1 = paramList[2]
        elseif showType == 2 then
            p0 = number
        elseif showType == 3 then
            p0 = paramList[1]
        elseif showType == 4 then
            p0 = TextMgr:GetText(tableData_tBattles.data[tonumber(paramList[2])].nameLabel)
        elseif showType == 5 then
            p0 = number
            p1 = paramList[1]
        elseif showType == 6 then
            p0 = number
            local soldierData = TableMgr:GetBarrackData(tonumber(paramList[1]), 1)
            p1 = TextMgr:GetText(soldierData.TabName) 
        elseif showType == 7 then
            p0 = number
            local itemData = tableData_tItem.data[tonumber(paramList[1])]
            p1 = TextMgr:GetText(itemData.name)
        elseif showType == 8 then
            local techData = TableMgr:GetTechDetailDataByIdLevel(tonumber(paramList[1]), 1)
            p0 = TextMgr:GetText(techData.Name)
            p1 = number
        elseif showType == 9 then
            p0 = Global.ExchangeValue2(number)
        elseif showType == 10 then
            p0 = number
            local buildingData = tableData_tBuilding.data[tonumber(paramList[1])]
            p1 = TextMgr:GetText(buildingData.name) 
        end

        return p0, p1
    end

    local titleText = TextMgr:GetText(missionData.title)

    if missionData.showtype == 0 then
        return titleText 
    end

    local s, p0, p1 = pcall(Impl, missionData)
    if s then
        return Format(titleText, p0, p1)
    else
        LogError(string.format("GetMissionTitle error id:%d, showType:%d, %s", missionData.id, missionData.showtype, p0))
        return titleText
    end
end

local ItemImpl = function(itemData, showType)
    local p0
    local p1
    if showType == 1 then
        p0 = itemData.itemlevel 
    elseif showType == 2 then
        p0 = itemData.itemlevel 
    elseif showType == 3 then
        p0 = Global.ExchangeValue2(itemData.itemlevel)
    elseif showType == 4 then
        p0 = itemData.itemlevel .. "%"
    elseif showType == 5 then
        p0 = itemData.itemlevel / 60
    elseif showType == 6 then
        p0 = itemData.itemlevel / 3600
    elseif showType == 7 then
        p0 = itemData.itemlevel / 86400
    elseif showType == 8 then
        local heroData = tableData_tHero.data[itemData.param1]
        p0 = TextMgr:GetText(heroData.nameLabel)
    elseif showType == 9 then
        p0 = itemData.param1
    end

    return p0, p1
end

function GetItemName(itemData)
    local nameText = TextMgr:GetText(itemData.name)
    if itemData.showtypename == 0 then
        return nameText 
    end

    local s, p0, p1 = pcall(ItemImpl, itemData, itemData.showtypename)
    if s then
        return Format(nameText, p0, p1)
    else
        LogError(string.format("GetItemName error id:%d, showType:%d, %s", itemData.id, itemData.showtypename, p0))
        return nameText
    end
end

function GetItemDescription(itemData)
    local descriptionText = TextMgr:GetText(itemData.description)
    if itemData.showtypedes == 0 then
        return descriptionText 
    end

    local s, p0, p1 = pcall(ItemImpl, itemData, itemData.showtypedes)
    if s then
        return Format(descriptionText, p0, p1)
    else
        LogError(string.format("GetItemDescription error id:%d, showType:%d, %s", itemData.id, itemData.showtypedes, p0))
        return descriptionText
    end
end

local function SlgBuffImpl(buffData)
    local paramList = {}
    for v in string.gsplit(buffData.Effect, ";") do
        if v ~= "" then
            table.insert(paramList, string.split(v, ",")[4] .. "%")
        end
    end

    return paramList
end

function GetSlgBuffTitle(buffData)
    local titleText = TextMgr:GetText(buffData.title)
    if buffData.Effect == "" then
        return titleText 
    end

    local s, paramList = pcall(SlgBuffImpl, buffData)
    if s then
        return Format(titleText, unpack(paramList))
    else
        LogError(string.format("GetSlgBuffTitle error id:%d %s", buffData.id, paramList))
        return titleText
    end
end

function GetSlgBuffDescription(buffData)
    local descriptionText = TextMgr:GetText(buffData.description)
    if buffData.Effect == "" then
        return descriptionText 
    end

    local s, paramList = pcall(SlgBuffImpl, buffData)
    if s then
        return Format(descriptionText, unpack(paramList))
    else
        LogError(string.format("GetSlgBuffTitle error id:%d %s", buffData.id, paramList))
        return descriptionText
    end
end

function GetSkillLevelDescription(skillData)
    local levelDescription = skillData.levelDescription
    if levelDescription == "" then
        return levelDescription
    end

    local descriptionText = TextMgr:GetText(skillData.levelDescription)
    local Impl = function(skillData)
        local showType = skillData.showtype
        local p0
        local p1
        if showType == 1 then
            p0 = skillData.level
            p1 = skillData.cooldown
        elseif showType == 2 then
            p0 = skillData.level
            p1 = skillData.radius
        elseif showType == 3 then
            p0 = skillData.level
            p1 = skillData.duration
        end
        return p0, p1
    end

    local s, p0, p1 = pcall(Impl, skillData)
    if s then
        return Format(descriptionText, p0, p1)
    else
        LogError(string.format("GetSkillLevelDescription error id:%d showtype:%d %s", skillData.id, skillData.showtype, p0))
        return descriptionText
    end
end

local RomanNumerals = {}
for i = 1, 10 do
    RomanNumerals[i] = "\226\133" .. string.char(159 + i)
end

local function UnitImpl(unitData)
    local showType = unitData.Showtype
    local p0
    if showType == 1 then
        p0= unitData.ShowNumber
    elseif showType == 2 then
        local groupData = tableData_tGroupInfo.data[unitData._unitArmyType]
        p0 = TextMgr:GetText(groupData._UnitGroupName) 
    elseif showType == 3 then
        p0 = RomanNumerals[unitData.ShowNumber]
    elseif showType == 4 then
        p0 = RomanNumerals[unitData._unitArmyLevel]
    end

    return p0
end

function GetUnitName(unitData)
    local nameText = TextMgr:GetText(unitData._unitNameLabel)
    if unitData.Showtype == 0 then
        return nameText 
    end

    local s, p0 = pcall(UnitImpl, unitData)
    if s then
        return Format(nameText, p0)
    else
        LogError(string.format("GetUnitName error id:%d showtype:%d %s", unitData.id, unitData.Showtype, p0))
        return nameText
    end
end

function GetUnitDescription(unitData)
    local descriptionText = TextMgr:GetText(unitData._unitDesLabel)
    if unitData.Showtype == 0 then
        return descriptionText 
    end

    local s, p0 = pcall(UnitImpl, unitData)
    if s then
        return Format(descriptionText, p0)
    else
        LogError(string.format("GetUnitDescription error id:%d showtype:%d %s", unitData.id, unitData.Showtype, p0))
        return descriptionText
    end
end

function Test()
    ---[[
    local file = io.open("d:/mission.csv", "w")
    for k, v in pairs(tableData_tMission.data) do
        local title = GetMissionTitle(v)
        file:write(v.id, ",", '"', title, '"', "\n")
        if title:find("步枪兵") or title:find("{0}") or title:find("{1}") then
            LogWarning("mission may error id:" .. v.id)
        end
    end
    file:close()
    --]]

    ---[[
    local file = io.open("d:/Item.csv", "w")
    for k, v in pairs(tableData_tItem.data) do
        local name = GetItemName(v)
        local description = GetItemDescription(v)
        file:write(v.id, ",", '"', name, '"', ",", '"', description, '"', "\n")
        if name:find("步枪兵") or name:find("{0}") or name:find("{1}")
            or description:find("步枪兵") or description:find("{0}") or description:find("{1}") then
            LogWarning("item may error id:" .. v.id)
        end
    end
    file:close()
    --]]

    ---[[
    local file = io.open("d:/SlgBuff.csv", "w")
    for k, v in pairs(tableData_tSlgBuff.data) do
        local title = GetSlgBuffTitle(v)
        local description = GetSlgBuffDescription(v)
        file:write(v.id, ",", '"', title, '"', ",", '"', description, '"', "\n")
        if title:find("步枪兵") or title:find("{0}") or title:find("{1}")
            or description:find("步枪兵") or description:find("{0}") or description:find("{1}") then
            LogWarning("SlgBuff may error id:" .. v.id)
        end
    end
    file:close()
    --]]

    ---[[
    local file = io.open("d:/Skill.csv", "w")
    for k, v in pairs(tableData_tGodSkill.data) do
        local description = GetSkillLevelDescription(v)
        file:write(v.id, ",", '"', description, '"', "\n")
        if description:find("步枪兵") or description:find("{0}") or description:find("{1}") then
            LogWarning("Skill may error id:" .. v.id)
        end
    end
    file:close()
    --]]
    --
    ---[[
    local file = io.open("d:/unit.csv", "w")
    for k, v in pairs(tableData_tUnitInfo.data) do
        local name = GetUnitName(v)
        local description = GetUnitDescription(v)
        file:write(v.id, ",", '"', name, '"', ",", '"', description, '"', "\n")
        if name:find("步枪兵") or name:find("{0}") or name:find("{1}")
            or description:find("步枪兵") or description:find("{0}") or description:find("{1}") then
            LogWarning("unit may error id:" .. v.id)
        end
    end
    file:close()
    --]]

end

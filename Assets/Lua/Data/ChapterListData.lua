module("ChapterListData", package.seeall)
local chapterListData
local eventListener = EventListener()
local teamSlotList
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local String = System.String

function GetData()
    return chapterListData
end

function SetData(data)
    chapterListData = data
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

function GetLevelData(levelId)
	if chapterListData ~= nil then
		for _, v in ipairs(chapterListData) do
			for _, vv in ipairs(v.level) do
				if vv.chapterlevel == levelId then
					return vv
				end
			end
		end
	end
	return nil 
end

function GetLevelDataInChapter(chapterMsg, levelId)
    for _, v in ipairs(chapterMsg.level) do
        if v.chapterlevel == levelId then
            return v
        end
    end
end

function GetChapterData(chapter)
    for _, v in ipairs(chapterListData) do
        if v.chapter == chapter then
            return v
        end
    end
    return nil
end

function ForceUpdateChapterData(data)
	for i, v in ipairs(chapterListData) do
        if v.chapter == data.chapter then
            chapterListData[i] = data
            break
        end
    end
end

function UpdateChapterData(data)
    local chapterData
    for _, v in ipairs(chapterListData) do
        if v.chapter == data.chapter then
            chapterData = v
            break
        end
    end

    if chapterData ~= nil then
        for _, v in ipairs(data.level) do
            local newLevel = true
            for i, vv in ipairs(chapterData.level) do
                if v.chapterlevel == vv.chapterlevel then
                    newLevel = false
                    chapterData.level[i] = v
                    break
                end
            end
            if newLevel then
                chapterData.level:add()
                chapterData.level[#chapterData.level] = v
            end
        end
    else
        chapterListData:add()
        chapterListData[#chapterListData] = data
    end
end

function HasLevelExplored(levelId)
	for k in string.gsplit(tostring(levelId), ",") do
		local levelData = GetLevelData(tonumber(k))
		if levelData then
            local isLevelUnlocked = false
			for _, v in ipairs(levelData.star) do
				if v then
                    isLevelUnlocked = true
					break
				end
			end

            if not isLevelUnlocked then
                return false
            end
        else
            return false
		end
	end

    return true
end

function HasAllFrontLevelExplored(frontId)
    if frontId == "NA" then
        return true
    end
    for v in string.gsplit(frontId, ",") do
        if not HasLevelExplored(tonumber(v)) then
            return false
        end
    end
    return true
end

function GetFrontUnexploredLevelList(frontId)
    if frontId == "NA" then
        return nil
    end
    local list = {}
    for v in string.gsplit(frontId, ",") do
        local levelId = tonumber(v)
        if not HasLevelExplored(levelId) then
            table.insert(list, levelId)
        end
    end
    return #list > 0 and list or nil
end

function HasAllLevelExplored(chapterData)
    for v in string.gsplit(chapterData.content, ";") do
        if not HasLevelExplored(tonumber(v)) then
            return false
        end
    end
    return true
end

function HasChapterCompleted(chapterData)
    local backwardChapterId = chapterData.backwardChapterId
    if backwardChapterId == 0 then
        return HasAllLevelExplored(chapterData)
    else
        local backwardChapterData = TableMgr:GetChapterData(backwardChapterId)
        if HasLevelExplored(backwardChapterData.openLevelId) then
            return true
        else
            return false
        end
    end
end

function HasChapterCompletedById(chapterId)
    return HasChapterCompleted(tableData_tChapters.data[chapterId])
end

local function LoadTeamSlotList()
    if teamSlotList == nil then
        teamSlotList = {}
        teamSlotList.hero = {}
        teamSlotList.army = {}
        local teamSlotTable = TableMgr:GetTeamSlotTable()
		for _ , v in pairs(teamSlotTable) do
			local value = v
            if value.slotType == 1 then
                table.insert(teamSlotList.hero, {slot = value.slot, battleId = value.unlockBattle})
            elseif value.slotType == 2 then
                table.insert(teamSlotList.army, {slot = value.slot, battleId = value.unlockBattle})
            end
		end
		
        --[[local iter = teamSlotTable:GetEnumerator()
        while iter:MoveNext() do
            local value = iter.Current.Value
            if value.slotType == 1 then
                table.insert(teamSlotList.hero, {slot = value.slot, battleId = value.unlockBattle})
            elseif value.slotType == 2 then
                table.insert(teamSlotList.army, {slot = value.slot, battleId = value.unlockBattle})
            end
        end]]
    end
end

function GetUnlockHeroSlotBattleId(slot)
    LoadTeamSlotList()
    for i, v in ipairs(teamSlotList.hero) do
        if v.slot == slot then
            return v.battleId
        end
    end
end

function GetHeroSlot()
    LoadTeamSlotList()
    for i = #teamSlotList.hero, 1, -1 do
        if teamSlotList.hero[i].battleId == 0 or HasLevelExplored(teamSlotList.hero[i].battleId) then
            return teamSlotList.hero[i].slot
        end
    end
    return 1
end

function GetArmySlot()
    LoadTeamSlotList()
    for i = #teamSlotList.army, 1, -1 do
        if teamSlotList.hero[i].battleId == 0 or HasLevelExplored(teamSlotList.army[i].battleId) then
            return teamSlotList.army[i].slot
        end
    end
    return 1
end

function GetUnlockArmySlotBattleId(slot)
    LoadTeamSlotList()
    for i, v in ipairs(teamSlotList.army) do
        if v.slot == slot then
            return v.battleId
        end
    end
end

function GetExploringChapterId(chapterType)
    local chapterMsg
    local chapterData
    local chapter = 0
    for _, v in ipairs(chapterListData) do
        if v.chapter > 0 then
            local data = TableMgr:GetChapterData(v.chapter)
            local find = false
            if chapterType ~= nil then
                if data.type == chapterType and v.chapter > chapter then
                    find = true
                end
            else
                if data.type == 1 or data.type == 5 then
                    if (chapterData == nil or data.type >= chapterData.type) and v.chapter > chapter then
                        find = true
                    end
                end
            end
            if find then
                chapter = v.chapter
                chapterMsg = v
                chapterData = data
            end
        end
    end

    if chapterData == nil then
        for _, v in pairs(tableData_tChapters.data) do
            if v.type == chapterType and v.number == 1 then
                return v.id
            end
        end
    end

    local backwardChapterId = chapterData.backwardChapterId
    if backwardChapterId == 0 then
        return chapterMsg.chapter
    else
        local backwardChapterData = TableMgr:GetChapterData(backwardChapterId)
        if HasLevelExplored(backwardChapterData.openLevelId) then
            return backwardChapterId
        else
            return chapterMsg.chapter
        end
    end
end

function GetChapterStarCount(chapterData)
    local chapterMsg = GetChapterData(chapterData.id)

    local count = 0
    local totalCount = 0
    for v in string.gsplit(chapterData.content, ";") do
        local battleData = TableMgr:GetBattleData(tonumber(v))
        if battleData.Type == 1 then
            if chapterMsg ~= nil then
                local levelMsg = GetLevelDataInChapter(chapterMsg, tonumber(v))
                if levelMsg ~= nil then
                    for _, v in ipairs(levelMsg.star) do
                        if v then
                            count = count + 1
                        end
                    end
                end
            end
            totalCount = totalCount + 3
        end
    end
    return count, totalCount
end

function CheckExplore(levelId)
    local battleData = TableMgr:GetBattleData(levelId)
    local unexploredList = GetFrontUnexploredLevelList(battleData.frontId)
    if unexploredList ~= nil then
        local nameList = {}
        for _, v in ipairs(unexploredList) do
            local data = TableMgr:GetBattleData(v)
            table.insert(nameList, TextMgr:GetText(data.nameLabel))
        end
        
        local unlockText = TextMgr:GetText(Text.chapter_ui6)
        return false, String.Format(unlockText, table.concat(nameList, " "))
    end
    local playerLevel = MainData.GetLevel()
    local requiredLevel = battleData.requiredLevel
    if playerLevel < requiredLevel then
        local unlockText = TextMgr:GetText(Text.chapter_ui7)
        return false, String.Format(unlockText, requiredLevel)
    end
    return true
end

function CanExplore(levelId)
    return (CheckExplore(levelId))
end

function IsLevelExploring(levelId)
    return not HasLevelExplored(levelId) and CanExplore(levelId)
end

function IsChapterUnlocked(id)
    local unmetPrerequisites = {}
    for _, battleID in ipairs(table.map(string.split(TableMgr:GetChapterData(id).openLevelId, ","), tonumber)) do
        if not HasLevelExplored(battleID) then
            table.insert(unmetPrerequisites, TextMgr:GetText(TableMgr:GetBattleData(battleID).nameLabel))
        end
    end

    return #unmetPrerequisites == 0, System.String.Format(TextMgr:GetText(Text.chapter_ui6), table.concat(unmetPrerequisites, " "))
end

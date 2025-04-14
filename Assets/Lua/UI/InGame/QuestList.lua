module("QuestList", package.seeall)
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr

local conditionList = {}
local questList = {}

class "Quest"
{
    result = 0,
}

function Quest:__init__(id, updateCallback)
    local data = TableMgr:GetStarConditionData(id)
    self.data = data
    self.updateCallback = updateCallback
    self.trace = TextMgr:GetText(data.trace)
end

local function SecondToTime(second)
    return string.format("%d:%02d", math.floor(second / 60), second % 60)
end

local function CheckQuest()
    for _, v in ipairs(questList) do
        local trace = v.trace
        local arg1 = tonumber(v.data.arg1 or 0)
        local arg2 = tonumber(v.data.arg2 or 0)
        --在{参数1}内摧毁敌方基地
        if v.data.type == 1 then
            if v.result == 0 then
                if conditionList.gameTime >= arg1 then
                    v.result = -1
                elseif conditionList.gameWin == 1 then
                    v.result = 1
                end
            end
            local color = v.result == -1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, color .. SecondToTime(conditionList.gameTime), SecondToTime(arg1) .. "[-]")
            --在{参数1}内护送目标经过{参数2}个点
        elseif v.data.type == 2 then
            if v.result == 0 then
                if conditionList.gameTime >= arg1 then
                    v.result = -1
                elseif conditionList.targetArrived >= arg2 then
                    v.result = 1
                end
            end
            local color = v.result == -1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, color .. SecondToTime(conditionList.gameTime), SecondToTime(arg1) .. "[-]")
            --在{参数1}内保护主基地
        elseif v.data.type == 3 then
            if v.result == 0 then
                if conditionList.gameTime >= arg1 then
                    v.result = 1
                elseif conditionList.ourBaseDestroyed > 0 then
                    v.result = -1
                end
            end
            local color = v.result == -1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, color .. SecondToTime(conditionList.gameTime), SecondToTime(arg1) .. "[-]")
            --不使用{参数1}和{参数2}过关
        elseif v.data.type == 4 then
            local count1 = conditionList.countList.useArmy[arg1]
            local count2 = conditionList.countList.useArmy[arg2]
            if v.result == 0 then
                if count1 or count2 then
                    v.result = -1
                elseif conditionList.gameWin == 1 then
                    v.result = 1
                end
            end
            local groupData1 = TableMgr:GetGroupData(arg1)
            local groupName1 = TextMgr:GetText(groupData1._UnitGroupName)
            local color1 = count1 and "[ff0000]" or "[-]"

            local groupData2 = TableMgr:GetGroupData(arg2)
            local groupName2 = TextMgr:GetText(groupData2._UnitGroupName)
            local color2 = count2 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, color1..groupName1.."[-]", color2..groupName2.."[-]")
            --不使用{参数1}过关
        elseif v.data.type == 5 then
            local count1 = conditionList.countList.useArmy[arg1]
            if v.result == 0 then
                if count1 then
                    v.result = -1
                elseif conditionList.gameWin == 1 then
                    v.result = 1
                end
            end
            local groupData1 = TableMgr:GetGroupData(arg1)
            local groupName1 = TextMgr:GetText(groupData1._UnitGroupName)
            local color1 = count1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, color1..groupName1.."[-]")
            --通关时阵亡人数不超过{参数1}
        elseif v.data.type == 6 then
            local totalCount = conditionList.conditionList.selfDead.totalCount
            if v.result == 0 then
                if totalCount > arg1 then
                    v.result = -1
                end
                if conditionList.gameWin == 1 then
                    v.result = 1
                end
            end
            local color = totalCount > arg1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, color .. totalCount, arg1 .. "[-]")
            --过关时剩余能量超过{参数1}
        elseif v.data.type == 7 then
            if v.result == 0 then
                if conditionList.gameWin ~= -1 then
                    if conditionList.gameWin == 1 and conditionList.currentEnergy >= arg1 then
                        v.result = 1
                    else
                        v.result = -1
                    end
                end
            end
            local color = conditionList.currentEnergy < arg1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, color .. conditionList.currentEnergy, arg1 .. "[-]")
            --过关时剩余子弹超过{参数1}
        elseif v.data.type == 8 then
            if v.result == 0 then
                if conditionList.gameWin ~= -1 then
                    if conditionList.gameWin == 1 and conditionList.currentBullet >= arg1 then
                        v.result = 1
                    else
                        v.result = -1
                    end
                end
            end
            local color = conditionList.currentBullet < arg1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, color .. conditionList.currentBullet, arg1 .. "[-]")
            --共计使用能量少于{参数1}
        elseif v.data.type == 9 then
            if v.result == 0 then
                if conditionList.usedEnergy > arg1 then
                    v.result = -1
                elseif conditionList.gameWin == 1 then
                    v.result = 1
                end
            end
            local color = conditionList.usedEnergy > arg1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, color .. conditionList.usedEnergy, arg1 .. "[-]")
            --共计使用弹药少于{参数1}
        elseif v.data.type == 10 then
            if v.result == 0 then
                if conditionList.usedBullet > arg1 then
                    v.result = -1
                elseif conditionList.gameWin == 1 then
                    v.result = 1
                end
            end
            local color = conditionList.usedBullet > arg1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, color .. conditionList.usedBullet, arg1 .. "[-]")
            --召唤{参数2}超过{参数1}个
        elseif v.data.type == 11 then
            local count1 = conditionList.countList.useArmy[arg2] or 0
            local groupData1 = TableMgr:GetGroupData(arg2)
            count1 = count1 * groupData1._UnitGroupNum
            if v.result == 0 then
                if count1 >= arg1 then 
                    v.result = 1
                elseif conditionList.gameWin == 1 then
                    v.result = -1
                end
            end
            local groupName1 = TextMgr:GetText(groupData1._UnitGroupName)
            local color1 = count1 < arg1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, groupName1, color1..count1.."[-]", arg1)
            --召唤{参数2}不超过{参数1}个
        elseif v.data.type == 12 then
            local count1 = conditionList.countList.useArmy[arg2] or 0
            local groupData1 = TableMgr:GetGroupData(arg2)
            count1 = count1 * groupData1._UnitGroupNum
            if v.result == 0 then
                if count1 > arg1 then 
                    v.result = -1
                elseif conditionList.gameWin == 1 then
                    v.result = 1
                end
            end
            local groupName1 = TextMgr:GetText(groupData1._UnitGroupName)
            local color1 = count1 > arg1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, groupName1, color1..count1.."[-]", arg1)
            --人口数始终不超过{参数1}
        elseif v.data.type == 13 then
            if v.result == 0 then
                if conditionList.currentPopulation > arg1 then
                    v.result = -1
                elseif conditionList.gameWin == 1 then
                    v.result = 1
                end
            end
            local color = conditionList.currentPopulation > arg1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, color .. conditionList.currentPopulation.."[-]", arg1 .. "[-]")
            --{参数2}的血量超过{参数1}
        elseif v.data.type == 14 then
            if v.result == 0 then
                if conditionList.npcHPPercentage < arg1 then
                    v.result = -1
                elseif conditionList.gameWin == 1 then
                    v.result = 1
                end
            end
            local color = conditionList.npcHPPercentage < arg1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, color..conditionList.npcHPPercentage.."[-]", arg1 .. "[-]")
            --保护{参数1}不被摧毁
        elseif v.data.type == 15 then
            if v.result == 0 then
                local count1 = conditionList.countList.friendDead[arg1] or 0
                if count1 > 0 then
                    v.result = -1
                elseif conditionList.gameWin == 1 then
                    v.result = 1
                end
            end
            --不释放{参数1}和{参数2}过关
        elseif v.data.type == 16 then
            if v.result == 0 then
                local count1 = conditionList.countList.useSkill[arg1] or 0
                local count2 = conditionList.countList.useSkill[arg2] or 0
                if count1 > 0 or count2 > 0 then
                    v.result = -1
                elseif conditionList.gameWin == 1 then
                    v.result = 1
                end
            end
            --释放{参数2}超过{参数1}次
        elseif v.data.type == 17 then
            local count2 = conditionList.countList.useSkill[arg2] or 0
            if v.result == 0 then
                if count2 >= arg1 then
                    v.result = 1
                end
            end
            local color = count2 < arg1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, color..count2.."[-]", arg1 .. "[-]")
            --{参数2}的血量超过{参数1}
        elseif v.data.type == 18 then
            if v.result == 0 then
                if conditionList.baseUsHPPercentage < arg1 then
                    v.result = -1
                elseif conditionList.gameWin == 1 then
                    v.result = 1
                end
            end
            local color = conditionList.baseUsHPPercentage < arg1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, color..conditionList.baseUsHPPercentage.."[-]", arg1 .. "[-]")
            --在{参数1}秒内消灭{参数2}个敌军
        elseif v.data.type == 19 then
            local totalCount = conditionList.countList.killEnemy.totalCount
            if v.result == 0 then
                if conditionList.gameTime > arg1 then
                    v.result = -1
                elseif totalCount >= arg2 then
                    v.result = 1
                elseif conditionList.gameWin ~= -1 then
                    v.result = -1
                end
            end
            local color = conditionList.gameTime > arg1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, color..SecondToTime(conditionList.gameTime).."[-]", SecondToTime(arg1) .. "[-]", totalCount, arg2)
            --在{参数1}秒内消灭ID为{参数2}
        elseif v.data.type == 20 then
            if v.result == 0 then
                local count1 = conditionList.countList.killEnemy[arg2]
                if conditionList.gameTime > arg1 then
                    v.result = -1
                elseif count1 then
                    v.result = 1
                elseif conditionList.gameWin ~= -1 then
                    v.result = -1
                end
            end
            local color = conditionList.gameTime > arg1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, color..SecondToTime(conditionList.gameTime).."[-]", SecondToTime(arg1) .. "[-]")
            --释放任意技能大于等于{参数1}次
        elseif v.data.type == 21 then
            local totalCount = conditionList.countList.useSkill.totalCount
            if v.result == 0 then
                if totalCount >= arg1 then
                    v.result = 1
                end
            end
            local color = totalCount < arg1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, color..totalCount.."[-]", arg1 .. "[-]")
            --释放任意技能小于等于{参数1}次
        elseif v.data.type == 22 then
            local totalCount = conditionList.countList.useSkill.totalCount
            if v.result == 0 then
                if totalCount > arg1 then
                    v.result = -1
                elseif conditionList.gameWin == 1 then
                    v.result = 1
                end
            end
            local color = totalCount > arg1 and "[ff0000]" or "[-]"
            trace = System.String.Format(trace, color..totalCount.."[-]", arg1 .. "[-]")
        end
        v.updateCallback(v.index, v.result, trace)
    end
end

function Clear()
    conditionList.enemyBaseDestroyed = 0
    conditionList.ourBaseDestroyed = 0
    conditionList.targetArrived = 0
    conditionList.gameTime = 0
    conditionList.gameWin = -1
    conditionList.currentEnergy = 0
    conditionList.currentBullet = 0
    conditionList.currentPopulation = 0
    local countList = {}
    countList.selfDead = {totalCount = 0}
    countList.friendDead = {totalCount = 0}
    countList.killEnemy = {totalCount = 0}
    countList.useSkill = {totalCount = 0}
    countList.useArmy = {totalCount = 0}
    conditionList.countList = countList
    conditionList.usedEnergy = 0
    conditionList.usedBullet = 0
    conditionList.npcHPPercentage = 100
    conditionList.baseUsHPPercentage = 100
    questList = {}
end

function AddQuest(index, id, updateCallback)
    if id == 0 then 
        return
    end
    local quest = Quest(id, updateCallback)
    quest.index = index
    table.insert(questList, quest)
end

local function SetCondition(key, value)
    conditionList[key] = value
    CheckQuest()
end

local function IncreaseCondition(key)
    conditionList[key] = conditionList[key] + 1
    CheckQuest()
end

local function AddCondition(key, value)
    conditionList[key] = conditionList[key] + value
    CheckQuest()
end

local function IncreaseCount(key, id)
    local count = conditionList.countList[key][id] or 0
    conditionList.countList[key][id] = count + 1
    conditionList.countList[key].totalCount = conditionList.countList[key].totalCount + 1
    CheckQuest()
end

function SetEnemyBaseDestroyed()
    SetCondition("enemyBaseDestroyed", 1)
end

function SetOurBaseDestroyed()
    SetCondition("ourBaseDestroyed", 1)
end

function SetGameTime(gameTime)
    SetCondition("gameTime", gameTime)
end

function IncreaseTargetArrived()
    IncreaseCondition("targetArrived")
end

function SetGameWin(gameWin)
    SetCondition("gameWin", gameWin and 1 or 0)
end

function SetCurrentEnergy(currentEnergy)
    SetCondition("currentEnergy", currentEnergy)
end

function SetCurrentBullet(currentBullet)
    SetCondition("currentBullet", currentBullet)
end

function SetCurrentPopulation(currentPopulation)
    SetCondition("currentPopulation", currentPopulation)
end

function AddUsedEnergy(value)
    AddCondition("usedEnergy", value)
end

function AddUsedBullet(value)
    AddCondition("usedBullet", value)
end

function IncreaseSelfDeadCount(id)
    IncreaseCount("selfDead", id)
end

function IncreaseFriendDeadCount(id)
    IncreaseCount("friendDead", id)
end

function IncreaseKillEnemyCount(id)
    IncreaseCount("killEnemy", id)
end

function IncreaseUseSkillCount(id)
    IncreaseCount("useSkill", id)
end

function IncreaseUsedArmyCount(id)
    IncreaseCount("useArmy", id)
end

function SetNPCHpPercentage(hpPercentage)
    SetCondition("npcHPPercentage", math.floor(hpPercentage))
end

function SetBaseUsHpPercentage(hpPercentage)
    SetCondition("baseUsHPPercentage", math.floor(hpPercentage))
end


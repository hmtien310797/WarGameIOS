module("MobaArmySetoutData", package.seeall)
local armySetoutData
local eventListener = EventListener()
local TableMgr = Global.GTableMgr

function GetData()
    return armySetoutData
end

function SetData(data)
    armySetoutData = data
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

function UpdateData(data)
    armySetoutData = data
    NotifyListener()
end

function HasHeroSetout(heroUid)
    for _, v in ipairs(armySetoutData.hero) do
        if v == heroUid then
            return true
        end
    end

    return false
end

function HasArmySetout(baseId)
    for _, v in ipairs(armySetoutData.army) do
        if v.baseid == baseId then
            return true
        end
    end

    return false
end

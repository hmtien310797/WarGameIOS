module("ActiveHeroData", package.seeall)
local activeHeroData
local eventListener = EventListener()

local oldActiveHeroData

local TableMgr = Global.GTableMgr

function GetData()
    return activeHeroData
end

function SetData(data)
    activeHeroData = data
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

function HasHero(heroId)
    for _, v in ipairs(activeHeroData) do
        if v == heroId then
            return true
        end
    end
    return false
end

function AddNewHero(heroId)
    if not HasHero(heroId) then
        activeHeroData:append(heroId)
    end
end

function SetOldData()
	oldActiveHeroData = {}
	for i, v in ipairs(activeHeroData) do
		table.insert(oldActiveHeroData, v)
	end
end

function HasHeroOld(heroId)
	for _, v in ipairs(oldActiveHeroData) do
        if v == heroId then
            return true
        end
    end
    return false
end

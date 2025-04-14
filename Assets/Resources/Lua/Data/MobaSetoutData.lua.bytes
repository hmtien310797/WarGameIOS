module("MobaSetoutData", package.seeall)
local setoutMsg
local setoutHero = {}
local setoutArmy = {}
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function GetData()
    return setoutData
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

function GetSetoutHero()
	return setoutHero
end

function GetSetoutArmy(itype , ilevel)
	if setoutArmy[itype] ~= nil and setoutArmy[itype][ilevel] ~= nil then
		return setoutArmy[itype][ilevel]
	end
	return 0
end



function SetData(msg)
    setoutMsg = msg
	
	--hero
	setoutHero = {}
	for i=1 , #(setoutMsg.hero) do
		if setoutHero[setoutMsg.hero[i]] == nil then
			setoutHero[setoutMsg.hero[i]] = {}
		end
		setoutHero[setoutMsg.hero[i]] = setoutMsg.hero[i]
		--print(setoutHero[setoutMsg.hero[i]] , setoutMsg.hero[i])
	end
	
	--army
	setoutArmy = {}
	for i=1 , #(setoutMsg.army) do
		if setoutArmy[setoutMsg.army[i].baseid] == nil then
			setoutArmy[setoutMsg.army[i].baseid] = {}
		end
		
		setoutArmy[setoutMsg.army[i].baseid][setoutMsg.army[i].level] = setoutMsg.army[i].num
		--print(setoutMsg.army[i].baseid , setoutMsg.army[i].level , setoutMsg.army[i].num)
		--
		--if setoutArmy[setoutMsg.army[i]] == nil then
		--	setoutArmy[setoutMsg.army[i]] = {}
		--end
		--setoutArmy[setoutMsg.army[i]] = setoutMsg.army[i]
		--print(setoutArmy[setoutMsg.army[i]] , setoutMsg.army[i])
	end
	
	NotifyListener()
end

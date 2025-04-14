module("Npcinfo", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local Format = System.String.Format
local SetClickCallback = UIUtil.SetClickCallback

local _ui

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function LoadUI()
    local robotData = tableData_tPvpRobot.data[_ui.robotRank]
    local heroIndex = 1
    for v in string.gsplit(robotData.HeroID, ";") do
        local args = string.split(v, ":")
        if #args[1] > 0 then
            local heroData = tableData_tHero.data[tonumber(args[1])]
            local heroMsg = GeneralData.GetDefaultHeroData(heroData, tonumber(args[2]), tonumber(args[3]))
            HeroList.LoadHero(_ui.heroList[heroIndex], heroMsg, heroData)
            heroIndex = heroIndex + 1
        end
    end
    for i = heroIndex, 5 do
        _ui.heroList[i].gameObject:SetActive(false)
    end

    local soldierIndex = 1
    for v in string.gsplit(robotData.Soilder, ";") do
        local args = string.split(v, ":")
        if #args[1] > 0 then
            local soldierData = TableMgr:GetBarrackData(tonumber(args[1]), tonumber(args[2]))
            local soldier = _ui.soldierList[soldierIndex]
            soldier.iconTexture.mainTexture = ResourceLibrary:GetIcon ("Icon/Unit/", soldierData.SoldierIcon)
            soldier.countLabel.text = args[3]
            soldierIndex = soldierIndex + 1
        end
    end
    for i = soldierIndex, 4 do
        _ui.soldierList[i].gameObject:SetActive(false)
    end
end

function Awake()
    _ui = {}
    _ui.prisonerPrefab = ResourceLibrary.GetUIPrefab("Jail/list_prisoner")
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)
    _ui.heroGrid = transform:Find("Container/bg_frane/bg_hero/Grid"):GetComponent("UIGrid")
    local heroList = {}
    for i = 1, 5 do
        local heroTransform = _ui.heroGrid.transform:GetChild(i - 1)
        local hero = {}
        HeroList.LoadHeroObject(hero, heroTransform)
        heroList[i] = hero
    end
    _ui.heroList = heroList
    local soldierList = {}
    for i = 1, 4 do
        local soldier = {}
        soldierTransform = transform:Find(string.format("Container/bg_frane/bg_solider/troops/btn_enemy (%d)", i))
        soldier.gameObject = soldierTransform.gameObject
        soldier.iconTexture = soldierTransform:Find("enemy"):GetComponent("UITexture")
        soldier.countLabel = soldierTransform:Find("Label"):GetComponent("UILabel")
        soldierList[i] = soldier
    end
    _ui.soldierList = soldierList
end

function Start()
    LoadUI()
end

function Close()
    _ui = nil
end

function Show(robotRank)
    Global.OpenUI(_M)
    _ui.robotRank = robotRank
end

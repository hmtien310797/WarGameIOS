module("CityMap", package.seeall)
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

function OnUICameraClick(go)
    if go == _ui.tip.goButton.gameObject then
        return
    end
    _ui.tip.gameObject:SetActive(false)
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    if go == _ui.tip.goButton.gameObject then
        return
    end
    _ui.tip.gameObject:SetActive(false)
end

function LoadUI()
    for i, v in ipairs(_ui.cityList) do
        local cityData = v.data
        local cityMsg = WorldCityData.GetCityInfo(cityData.id)
        v.msg = cityMsg
        local battling = not cityMsg.occupied and (i == 1 or _ui.cityList[i - 1].msg.occupied)
        if i > 1 then
            v.pointObject:SetActive(battling)
        end
        v.battleObject:SetActive(battling)
        local occupied = v.msg.occupied
        if occupied then
            v.nameLabel.gameObject:SetActive(true)
            v.nameLabel.color = NGUIMath.HexToColor(0XF5BC32FF)
            v.iconTexture.color = Color(1, 1, 1, 0.01)
            v.boxCollider.enabled = true
        elseif battling then
            v.nameLabel.gameObject:SetActive(true)
            v.nameLabel.color = Color.white
            v.iconTexture.color = NGUIMath.HexToColor(0xF11515FF)
            v.boxCollider.enabled = true
        else
            v.nameLabel.gameObject:SetActive(false)
            v.iconTexture.color = NGUIMath.HexToColor(0x6E2400FF)
            v.boxCollider.enabled = false
        end
        v.rewardObject:SetActive(cityMsg.reputationNum > 0)
        v.nameLabel.text = TextMgr:GetText(cityData.Name)
        SetClickCallback(v.iconTexture.gameObject, function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                local tip = _ui.tip
                tip.gameObject:SetActive(true)
                UIUtil.RepositionTooltip(tip.widget)
                tip.iconTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", cityData.Icon)
                tip.nameLabel.text = TextMgr:GetText(cityData.Name)
                tip.popularityLabel.text = Format(TextMgr:GetText(Text.ui_citybattle_9), cityData.HonorYield)
                if cityData.SeizeBuff == "" then
                    tip.attrLabel.text = TextMgr:GetText(Text.ui_citybattle_19)
                else
                    local buffData = tableData_tSlgBuff.data[tonumber(cityData.SeizeBuff)]
                    local effectList = string.split(buffData.Effect, ",")
                    local buffName = TextMgr:GetText(TableMgr:GetEquipTextDataByAddition(effectList[2], tonumber(effectList[3])))
                    local buffValue = tonumber(effectList[4])
                    tip.attrLabel.text = string.format("%s%s%s%%", TextMgr:GetText(buffData.title), buffName, buffValue)
                end
                tip.attrLabel.gameObject:SetActive(cityMsg.occupied)
                tip.goButton.gameObject:SetActive(not cityMsg.occupied)
                tip.occupyLabel.text = Format(TextMgr:GetText(Text.ui_citybattle_17), cityMsg.occupyUserNum)
                if not cityMsg.occupied then
                    SetClickCallback(tip.goButton.gameObject, function(go)
                        CloseAll()
                        local cityPos = cityMsg.pos
                        MainCityUI.ShowWorldMap(cityPos.x, cityPos.y, true)
                    end)
                end
            end
        end)
    end
end

function Awake()
    _ui = {}
    _ui.prisonerPrefab = ResourceLibrary.GetUIPrefab("Jail/list_prisoner")
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/background/close btn")
    SetClickCallback(mask.gameObject, Hide)
    SetClickCallback(closeButton.gameObject, Hide)
    _ui.helpButton = transform:Find("Container/background/mid/btn_help"):GetComponent("UIButton")
    SetClickCallback(_ui.helpButton.gameObject, function()
        MapHelp.Open(2600, false, nil, nil, true)
    end)

    local cityBgTransform = transform:Find("Container/background/mid/level_list")
    local cityList = {}
    local cityId = 1
    local cityIndex = 1
    repeat
        local cityData = tableData_tWorldCity.data[cityId]
        local city = {}
        local cityTransform = cityBgTransform:Find(string.format("city (%d)", cityIndex))
        city.transform = cityTransform
        city.gameObject = cityTransform.gameObject
        city.iconTexture = cityTransform:Find("icon"):GetComponent("UITexture")
        city.boxCollider = cityTransform:Find("icon"):GetComponent("BoxCollider")
        city.battleObject = cityTransform:Find("icon_battle").gameObject
        city.nameLabel = cityTransform:Find("city_name"):GetComponent("UILabel")
        city.rewardObject = cityTransform:Find("tips_icon").gameObject
        if cityIndex > 1 then
            city.pointObject = cityBgTransform:Find(string.format("point (%d)", cityIndex - 1)).gameObject
        end
        city.data = cityData
        cityList[cityIndex] = city
        SetClickCallback(city.rewardObject, function(go)
            CityList.Show()
        end)
        cityId = cityData.BackCity
        cityIndex = cityIndex + 1
    until cityId == 0

    _ui.cityList = cityList

    local tip = {}
    local tipTransform = transform:Find("Container/CityTips")
    tip.gameObject = tipTransform.gameObject
    tip.widget = tipTransform:GetComponent("UIWidget")
    tip.iconTexture = tipTransform:Find("bg/city_icon"):GetComponent("UITexture")
    tip.nameLabel = tipTransform:Find("bg/bg_name/Name"):GetComponent("UILabel")
    tip.popularityLabel = tipTransform:Find("bg/text"):GetComponent("UILabel")
    tip.attrLabel = tipTransform:Find("bg/bg_Description/text"):GetComponent("UILabel")
    tip.occupyLabel = tipTransform:Find("bg/other_text"):GetComponent("UILabel")
    tip.goButton = tipTransform:Find("bg/btn_battle"):GetComponent("UIButton")

    tip.gameObject:SetActive(false)

    _ui.tip = tip

    local listButton = transform:Find("Container/background/bottom/button")
    SetClickCallback(listButton.gameObject, function()
        CityList.Show()
    end)

    WorldCityData.AddListener(LoadUI)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Close()
    WorldCityData.RemoveListener(LoadUI)
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    _ui.tip.gameObject:SetActive(false)
    _ui = nil
end

function Show()
    WorldCityData.RequestData()
    Global.OpenUI(_M)
    LoadUI()
end

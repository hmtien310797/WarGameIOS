module("JailInfo", package.seeall)
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
local timer = 0

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    JailTreat.Hide()
    Hide()
end

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

local function UpdateTime()
    for _, v in ipairs(_ui.prisonerList) do
        v.timeLabel.text = Global.GetLeftCooldownTextLong(v.msg.freeTime)
    end
end

function LoadPrisonerObject(prisoner, prisonerTransform)
    prisoner.transform = prisonerTransform
    prisoner.headObject = prisonerTransform:Find("head").gameObject
    prisoner.faceTexture = prisonerTransform:Find("head/Texture"):GetComponent("UITexture")
    prisoner.nameLabel = prisonerTransform:Find("name"):GetComponent("UILabel")
    prisoner.levelLabel = prisonerTransform:Find("name/level"):GetComponent("UILabel")
    prisoner.timeObject = prisonerTransform:Find("time").gameObject
    prisoner.timeLabel = prisonerTransform:Find("time/load/time"):GetComponent("UILabel")
    prisoner.treatButton = prisonerTransform:Find("treat")
end

function LoadPrisoner(prisoner, prisonerMsg, prisonerData)
    prisoner.msg = prisonerMsg
    prisoner.data = prisonerData
    local infoMsg = prisonerMsg.info
    SetClickCallback(prisoner.headObject, function(go)
        OtherInfo.RequestShow(infoMsg.id)
    end)
    prisoner.faceTexture.mainTexture = ResourceLibrary:GetIcon("Icon/head/", infoMsg.face)
    prisoner.levelLabel.text = "Lv." .. infoMsg.level
    local guildBanner = infoMsg.guildBanner
    if guildBanner == "" then
        guildBanner = "---"
    end
    prisoner.nameLabel.text = string.format("[F1CF63][%s][-]%s", guildBanner, infoMsg.name)
    if prisoner.treatButton ~= nil then
        SetClickCallback(prisoner.treatButton.gameObject, function(go)
            JailTreat.Show(prisonerMsg, prisonerData)
        end)
    end
end

function LoadUI()
    local prisonLevel = maincity.GetBuildingLevelByID(10)
    _ui.prisonerList = {}
    local jailInfoMsg = JailInfoData.GetData()
    for i, v in ipairs(jailInfoMsg.prisoner) do
        local prisonerTransform
        if i > _ui.prisonerGridTransform.childCount then
            prisonerTransform = NGUITools.AddChild(_ui.prisonerGridTransform.gameObject, _ui.prisonerPrefab).transform
        else
            prisonerTransform = _ui.prisonerGridTransform:GetChild(i - 1)
        end
        local prisoner = {}
        LoadPrisonerObject(prisoner, prisonerTransform)
        local prisonerData = TableMgr:GetJailDataByLevel(prisonLevel)
        LoadPrisoner(prisoner, v, prisonerData)
        prisonerTransform.gameObject:SetActive(true)
        _ui.prisonerList[i] = prisoner
    end

    for i = #jailInfoMsg.prisoner + 1, _ui.prisonerGridTransform.childCount do
        _ui.prisonerGridTransform:GetChild(i - 1).gameObject:SetActive(false)
    end
    local hasPrionser = #jailInfoMsg.prisoner > 0
    _ui.noneObject:SetActive(not hasPrionser)
    local _, valueText = JailInfoData.GetBuffNameValueText()
    _ui.buffLabel.text = Format(TextMgr:GetText(Text.jail_1), valueText)
    _ui.countLabel.text = Format(TextMgr:GetText(Text.jail_2), #jailInfoMsg.prisoner, TableMgr:GetJailDataByLevel(prisonLevel).Prisoner)
    UpdateTime()
    
    if hasPrionser then
        if UnityEngine.PlayerPrefs.GetInt("JailInfoHelp") == 0 then
            MapHelp.Open(2200, false, nil, nil, true)
            UnityEngine.PlayerPrefs.SetInt("JailInfoHelp", 1)
        end
    end
    SetClickCallback(_ui.helpObject, function(go)
        MapHelp.Open(2200, false, nil, nil, true)
    end)
end

function Awake()
    _ui = {}
    _ui.prisonerPrefab = ResourceLibrary.GetUIPrefab("Jail/list_prisoner")
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)

    _ui.prisonerGridTransform = transform:Find("Container/bg_frane/Container/Scroll View/Grid")
    _ui.prisonerGrid = _ui.prisonerGridTransform:GetComponent("UIGrid")
    _ui.buffLabel = transform:Find("Container/bg_frane/bg_mid/buff"):GetComponent("UILabel")
    _ui.noneObject = transform:Find("Container/bg_frane/bg_mid/none").gameObject
    _ui.countLabel = transform:Find("Container/bg_frane/bg_mid/prisoner"):GetComponent("UILabel")
    _ui.infoObject = transform:Find("Container/bg_frane/bg_mid/buff/info").gameObject
    _ui.helpObject = transform:Find("Container/bg_frane/bg_mid/prisoner/help").gameObject
    SetClickCallback(_ui.infoObject, function(go)
        Prisonerhelp.Show()
    end)
    JailInfoData.AddListener(LoadUI)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function LateUpdate()
    if timer >= 0 then
        timer = timer - GameTime.deltaTime
        if timer < 0 then
            timer = 1
            UpdateTime()
        end
    end
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
    JailInfoData.RemoveListener(LoadUI)
    _ui = nil
end

function Show()
    Global.OpenUI(_M)
    LoadUI()
end

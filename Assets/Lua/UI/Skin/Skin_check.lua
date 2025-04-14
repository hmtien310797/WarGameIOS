module("Skin_check", package.seeall)
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

local function SecondUpdate()
    for _, v in ipairs(_ui.skinList) do
        if v.expird ~= 0 then
            v.timeLabel1.text = Format(TextMgr:GetText(Text.DailyMission_CountDown), Global.GetLeftCooldownTextLong(v.msg.expird)) 
        end
    end
end

local function LoadUI()
    local skinInfoMsg = MainData.GetData().skin
    local skinList = {}
    local skinsMsg = skinInfoMsg.skins
    for _, v in ipairs(skinsMsg) do
        if not Skin.IsDefaultSkin(v.id) then
            table.insert(skinList, {data = tableData_tSkin.data[v.id], msg = v, itemDataList = Skin.GetItemDataList(v.id)})
        end
    end

    local attrCount = 0
    for i, v in ipairs(skinList) do
        local skinTransform
        if i > _ui.skinGrid.transform.childCount then
            skinTransform = NGUITools.AddChild(_ui.skinGrid.gameObject, _ui.skinPrefab).transform
        else
            skinTransform = _ui.skinGrid.transform:GetChild(i - 1)
        end
        local skin = v
        local itemData = skin.itemDataList[1]
        print("skin id:", skin.data.id)
        local nameLabel = skinTransform:Find("name"):GetComponent("UILabel")
        local iconTexture = skinTransform:Find("icon"):GetComponent("UITexture")
        local attrGrid = skinTransform:Find("base_mid/Grid"):GetComponent("UIGrid")
        local attrPrefab = attrGrid.transform:GetChild(0).gameObject
        local timeLabel1 = skinTransform:Find("time_1"):GetComponent("UILabel")
        local timeLabel2 = skinTransform:Find("time_2"):GetComponent("UILabel")
        nameLabel.text = TextMgr:GetText(itemData.name)
        iconTexture.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", itemData.icon)
        skinTransform.gameObject:SetActive(true)

        local attrIndex = 1
        if skin.data.SkinAttribute ~= "" then
            for vv in string.gsplit(skin.data.SkinAttribute, ";") do
                attrCount = attrCount + 1
                local attrTransform
                if attrIndex > attrGrid.transform.childCount then
                    attrTransform = NGUITools.AddChild(attrGrid.gameObject, attrPrefab).transform
                else
                    attrTransform = attrGrid.transform:GetChild(attrIndex - 1)
                end
                local attrList = string.split(vv, ",")
                local needData = TableMgr:GetNeedTextDataByAddition(tonumber(attrList[1]), tonumber(attrList[2]))
                attrTransform:GetComponent("UILabel").text = TextMgr:GetText(needData.unlockedText) .. Global.GetHeroAttrValueString(needData.additionAttr, tonumber(attrList[3]))

                attrTransform.gameObject:SetActive(true)
                attrIndex = attrIndex + 1
            end
        end
        for j = attrIndex, attrGrid.transform.childCount do
            attrGrid.transform:GetChild(j - 1).gameObject:SetActive(false)
        end
        attrGrid.repositionNow = true
        timeLabel1.gameObject:SetActive(skin.msg.expird ~= 0)
        timeLabel2.gameObject:SetActive(skin.msg.expird == 0)
        v.timeLabel1 = timeLabel1
    end
    for i = #skinList + 1, _ui.skinGrid.transform.childCount do
        _ui.skinGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end
    _ui.skinGrid.repositionNow = true
    _ui.skinList = skinList
    _ui.noneAttrObject:SetActive(attrCount == 0)

    SecondUpdate()
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)

    _ui.skinGrid = transform:Find("Container/bg_frane/mid/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.skinPrefab = transform:Find("Container/bg_frane/mid/list_buff").gameObject
    _ui.noneAttrObject = transform:Find("Container/bg_frane/mid/none").gameObject
    _ui.timer = Timer.New(SecondUpdate, 1, -1)
    _ui.timer:Start()
end

function Start()
    LoadUI()
end

function Close()
    _ui.timer:Stop()
    _ui = nil
end

function Show()
    Global.OpenUI(_M)
end

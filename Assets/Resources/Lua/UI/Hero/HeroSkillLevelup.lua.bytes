module("HeroSkillLevelup", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local UICamera = UICamera
local Tooltip = Tooltip

local _ui = nil

function Hide()
    if GUIMgr:IsMenuOpen("HeroInfoNew") then
        HeroInfoNew.UnselectPassiveSkill()
    end
    UITweener.PlayAllTweener(_ui.bgObject, false, false, false)
    if _ui ~= nil then
        _ui.bgObject:GetComponent("UITweener"):SetOnFinished(EventDelegate.Callback(function()
            Global.CloseUI(_M)
        end))
    end
end

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
    if go.transform.parent ~= nil and go.transform.parent.name == "Equip_tips(Clone)" then
        return
    end
    if go.layer == LayerMask.NameToLayer("ui top layer") then
        return
    end
    if NGUITools.IsChild(transform, go.transform) then
        return
    end
    Hide()
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

local function LoadAttrList(attrGrid, skillMsg, skillData, skillLevel)
    local attrPrefab = attrGrid.transform:GetChild(0).gameObject
    local attrIndex = 1
    for i = 1, 10 do
        local armyType = skillData["ArmyType" .. i]
        local attrType = skillData["AttrType" .. i]
        local needData = TableMgr:GetNeedTextDataByAddition(armyType, attrType)
        --print("armyType:", armyType, "attrType", attrType)
        if needData ~= nil then
            local attrValue = skillData["DefaultValue" .. i] + (skillLevel - 1) * skillData["GrowValue" .. i] * (1 + math.floor(skillLevel * 0.1) * tonumber(tableData_tGlobal.data[100227].value))
            local attrTransform
            if attrIndex > attrGrid.transform.childCount then
                attrTransform = NGUITools.AddChild(attrGrid.gameObject, attrPrefab).transform
            else
                attrTransform = attrGrid.transform:GetChild(attrIndex - 1)
            end
            local attrLabel = attrTransform:GetComponent("UILabel")
            local nameText = TextMgr:GetText(needData.unlockedText)
            local valueText = Global.GetHeroAttrValueString(needData.additionAttr, (skillData.sign == 0 and 1 or -1 ) * attrValue)
            if needData.id == 1102 then
                attrLabel.text = System.String.Format(string.gsub(TextMgr:GetText(Text.Hero_skill_ui1), "[:：]", ""), nameText, valueText) 
            else
                attrLabel.text = System.String.Format(TextMgr:GetText(Text.Hero_skill_ui1), nameText, valueText) 
            end
            attrTransform.gameObject:SetActive(true)
            attrIndex = attrIndex + 1
        end
    end
    for i = attrIndex, attrGrid.transform.childCount do
        attrGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end
end

local function LoadUI()
    local heroMsg = GeneralData.GetGeneralByUID(_ui.heroUid)
    local heroData = TableMgr:GetHeroData(heroMsg.baseid)
    local skillData = TableMgr:GetPassiveSkillData(tonumber(string.split(TableMgr:GetHeroData(heroMsg.baseid).showpassiveskill, ";")[_ui.skillIndex]))
    local skillMsg
    for i, v in ipairs(heroMsg.skill.passiveSkill) do
        if v.id == skillData.id then
            skillMsg = v
            print("skill id:", v.id)
            break
        end
    end
    local skillLevel = skillMsg.level
    local levelUpId = skillData.SkillLvlupType * 1000 + skillLevel
    local levelUpData = tableData_tPassiveskillLevelUp.data[levelUpId]

    _ui.nameLabel.text = TextMgr:GetText(skillData.SkillName)
    _ui.bgSprite.spriteName = "bg_skill_" .. levelUpData.SkillQuality
    _ui.iconTexture.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", skillData.SkillIcon)
    local maxLevel = skillData.SkillLevelMax
    _ui.levelLabel.text = System.String.Format(TextMgr:GetText(Text.Hero_skill_ui8), skillLevel .. "/" .. maxLevel)

    _ui.descriptionLabel.text = TextMgr:GetText(skillData.SkillDes)

    LoadAttrList(_ui.currentGrid, skillMsg, skillData, skillLevel)
    local itemGrid = _ui.itemGrid
    local hasEnoughItem = false
    local upgradeQuality = false
    local nextLevelUpData
    if skillLevel < maxLevel then
        hasEnoughItem = true
        _ui.nextGrid.gameObject:SetActive(true)
        LoadAttrList(_ui.nextGrid, skillMsg, skillData, skillLevel + 1)
        itemGrid.gameObject:SetActive(true)
        local nextLevelUpId = skillData.SkillLvlupType * 1000 + skillLevel + 1
        nextLevelUpData = tableData_tPassiveskillLevelUp.data[nextLevelUpId]
        print("level up data id:", nextLevelUpData.id)
        local itemList = string.split(nextLevelUpData.SkillLevelConsume, ";")
        for i, v in ipairs(itemList) do
            local itemIdList = string.split(v, ":")
            local itemId = tonumber(itemIdList[1])
            local itemCount = tonumber(itemIdList[2])
            local itemData = TableMgr:GetItemData(itemId)
            local item = {}
            local itemTransform
            if i > itemGrid.transform.childCount then
                itemTransform = NGUITools.AddChild(itemGrid.gameObject, _ui.itemPrefab).transform
            else
                itemTransform = itemGrid.transform:GetChild(i - 1)
            end
            UIUtil.LoadItemObject(item, itemTransform)
            item.countLabel.pivot = UIWidget.Pivot.Center 
            item.countLabel.transform.localPosition = Vector3(5, -27, 0)
            item.countLabel.fontSize = 22
            item.transform.localScale = Vector3(0.9, 0.9, 0.9)
            UIUtil.LoadItem(item, itemData, itemCount)
            local hasCount = 0
            if itemData.type == 1 then
                hasCount = MoneyListData.GetMoneyByType(itemData.id)
            else
                hasCount = ItemListData.GetItemCountByBaseId(itemId)
            end
            local hasCountText
            if hasCount >= itemCount then
                hasCountText = string.format("%d/%d", hasCount, itemCount)
            else
                hasCountText = string.format("[ff0000]%d[-]/%d", hasCount, itemCount)
                hasEnoughItem = false
            end
            item.transform:Find("have"):GetComponent("UILabel").text = hasCountText
            UIUtil.SetClickCallback(item.transform.gameObject, function(go)
                print("item id:", itemData.id)
                if go == _ui.tipObject then
                    _ui.tipObject = nil
                else
                    _ui.tipObject = go
                    Tooltip.ShowItemTip({BaseData = itemData}, "equipTips")
                end
            end)
            itemTransform.gameObject:SetActive(true)
        end
        for i = #itemList + 1, itemGrid.transform.childCount do
            local itemTransform = itemGrid.transform:GetChild(i - 1)
            itemTransform.gameObject:SetActive(false)
        end
        itemGrid.repositionNow = true

        _ui.upgradeLabel.text = TextMgr:GetText(nextLevelUpData.SkillQuality == levelUpData.SkillQuality and Text.build_ui8 or Text.equip_ui13)
        upgradeQuality = nextLevelUpData.SkillQuality ~= levelUpData.SkillQuality
        _ui.requireLevelLabel.text = System.String.Format(TextMgr:GetText(Text.hero_ui1), nextLevelUpData.NeedHeroLevel)
    else
        _ui.nextGrid.gameObject:SetActive(false)
        itemGrid.gameObject:SetActive(false)
        _ui.upgradeLabel.text = TextMgr:GetText(Text.build_ui8)
        _ui.requireLevelLabel.text = TextMgr:GetText(Text.ui_maximize)
    end
    coroutine.start(function()
        coroutine.step()
        if _ui == nil then
            return _ui
        end
        _ui.currentGrid.repositionNow = true
        _ui.nextGrid.repositionNow = true
        _ui.attrTable.repositionNow = true
    end)
    local canUpgrade = hasEnoughItem and skillLevel < maxLevel and heroMsg.level >= nextLevelUpData.NeedHeroLevel
    UIUtil.SetBtnEnable(_ui.upgradeButton, "btn_1", "btn_4", canUpgrade)
    _ui.noticeObject:SetActive(canUpgrade)
    SetClickCallback(_ui.upgradeButton.gameObject, function(go)
        if skillLevel >= maxLevel then
            FloatText.Show(TextMgr:GetText(Text.ui_maximize))
            return
        end

        if heroMsg.level < nextLevelUpData.NeedHeroLevel then
            FloatText.Show(TextMgr:GetText(Text.Hero_skill_ui3))
            return
        end

        if not hasEnoughItem then
            FloatText.Show(TextMgr:GetText(Text.Hero_skill_ui2))
            return
        end

        local req = HeroMsg_pb.MsgHeroUpgradePassiveSkillRequest()
        req.heroUid = heroMsg.uid
        req.skillId = skillMsg.id
        print("Request id ", req.skillId)
        Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgHeroUpgradePassiveSkillRequest, req, HeroMsg_pb.MsgHeroUpgradePassiveSkillResponse, function(msg)
            if msg.code ~= ReturnCode_pb.Code_OK then
                Global.FloatError(msg.code)
            else
                FloatText.Show(TextMgr:GetText(upgradeQuality and Text.Hero_skill_ui7 or Text.Hero_skill_ui6), Color.green)
                MainCityUI.UpdateRewardData(msg.fresh)
                HeroInfoNew.OnPassiveSkillUpgrade(_ui.skillIndex)
            end
        end, false)
    end)
end

function Awake()
    _ui = {}
    _ui.containerObject = transform:Find("Container").gameObject
    _ui.bgObject = transform:Find("Container/bg").gameObject

    _ui.nameLabel = transform:Find("Container/bg/Title"):GetComponent("UILabel")
    _ui.bgSprite = transform:Find("Container/bg/bg_top/Scroll View/Table/top/Frame"):GetComponent("UISprite")
    _ui.iconTexture = transform:Find("Container/bg/bg_top/Scroll View/Table/top/Frame/Icon"):GetComponent("UITexture")
    _ui.levelLabel = transform:Find("Container/bg/bg_top/Scroll View/Table/top/Name"):GetComponent("UILabel")
    _ui.descriptionLabel = transform:Find("Container/bg/bg_top/Scroll View/Table/top/msg"):GetComponent("UILabel")

    _ui.attrTable = transform:Find("Container/bg/bg_top/Scroll View/Table"):GetComponent("UITable")
    _ui.currentGrid = transform:Find("Container/bg/bg_top/Scroll View/Table/now/Grid"):GetComponent("UIGrid")
    _ui.nextGrid = transform:Find("Container/bg/bg_top/Scroll View/Table/next/Grid"):GetComponent("UIGrid")

    _ui.itemGrid = transform:Find("Container/bg/bg_mid/Grid"):GetComponent("UIGrid")
    _ui.itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    _ui.requireLevelLabel = transform:Find("Container/bg/bg_mid/herolv"):GetComponent("UILabel")
    _ui.upgradeButton = transform:Find("Container/bg/btn_levelup"):GetComponent("UIButton")
    _ui.upgradeLabel = transform:Find("Container/bg/btn_levelup/Label"):GetComponent("UILabel")
    _ui.noticeObject = transform:Find("Container/bg/btn_levelup/Notice").gameObject

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    EventDispatcher.Bind(GeneralData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.DELAYED, function(params)
        LoadUI()
    end)
end

function Show(heroUid, skillIndex)
    Global.OpenUI(_M)
    _ui.heroUid = heroUid
    _ui.skillIndex = skillIndex
    UITweener.PlayAllTweener(_ui.bgObject, true, true, false)
    _ui.bgObject:GetComponent("UITweener"):ClearOnFinished()
    LoadUI()
end

function Close()
    EventDispatcher.UnbindAll(_M)
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
    _ui = nil
end

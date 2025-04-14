module("BadgeInfo", package.seeall)

local EFFECT_DELAY = 1.4

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local selectedBadgeId
local heroUid
local heroMsg
local heroData

local _ui

local currentLevelEnough
local currentItemEnough

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local function CloseClickCallback(go)
    Hide()
    HeroInfo.Show(heroUid, heroMsg.baseid, true)
end

local function SetBadgeAttr(badge, badgeData)
    local needData = TableMgr:GetNeedTextDataByAddition(badgeData.armyType, badgeData.attrType)
    badge.icon.mainTexture = ResourceLibrary:GetIcon("Item/", badgeData.icon)
    badge.quality.spriteName = "medal_level_"..badgeData.quality
    badge.name.text = TextMgr:GetText(badgeData.name)
    badge.attr1Name.text = TextMgr:GetText(needData.unlockedText)
    badge.attr1Value.text = Global.GetHeroAttrValueString(needData.additionAttr, badgeData.value)
    badge.attr2Name.text = TextMgr:GetText(Text.army_limit)
    badge.attr2Value.text = "+"..badgeData.armyMax
end


local function LoadGatherItem()
    if _ui.gatherItemId ~= nil then
        _ui.gatherItem:LoadUI(_ui.gatherItemId, _ui.gatherItemCount)
    end
end

function LoadUI()
    if _ui.waitingCoroutine then
        return
    end
    heroMsg = HeroListData.GetHeroDataByUid(heroUid)
    heroData = TableMgr:GetHeroData(heroMsg.baseid)
    local badgeList = HeroListData.GetBadgeList(heroMsg, heroData)

    for i, v in ipairs(badgeList) do
        if i == selectedBadgeIndex then
            local badgeData = v.data
            local targetLevel = v.targetLevel
            local haveBadge = v.msg ~= nil
            selectedBadgeId = v.data.badgeId
            _ui.arrowIcon.gameObject:SetActive(haveBadge and not v.maxQuality)
            _ui.maxIcon.gameObject:SetActive(v.maxQuality)
            _ui.lockIcon.gameObject:SetActive(not haveBadge)
            if v.msg == nil then
                _ui.lockLabel.text = String.Format(TextMgr:GetText(Text.hero_ui2), targetLevel)
            end

            local targetBadgeData = v.targetData
            -- set attr
            if v.maxQuality or v.msg == nil then
                _ui.currentBadge.bg.gameObject:SetActive(false)
                _ui.itemList.bg.gameObject:SetActive(false)
                SetBadgeAttr(_ui.targetBadge, badgeData)
                _ui.btnOk.gameObject:SetActive(true)
                _ui.targetBadge.bg.localPosition = Vector3(0, 105, 0)
                _ui.targetBadge.lock.gameObject:SetActive(v.msg == nil)
            else
                _ui.currentBadge.bg.gameObject:SetActive(true)
                _ui.itemList.bg.gameObject:SetActive(true)
                SetBadgeAttr(_ui.currentBadge, badgeData)
                SetBadgeAttr(_ui.targetBadge, targetBadgeData)
                _ui.btnOk.gameObject:SetActive(false)
                _ui.targetBadge.lock.gameObject:SetActive(false)
                _ui.targetBadge.bg.localPosition = _ui.targetBadge.defaultPos

                -- set item
                for j = 1, 5 do
                    local item = _ui.itemList[j]
                    local itemId = targetBadgeData["itemId"..j]
                    if itemId ~= 0 then
                        local itemData = TableMgr:GetItemData(itemId)
                        local itemMsg = ItemListData.GetItemDataByBaseId(itemId)
                        local itemCount = targetBadgeData["itemCount"..j]
                        local haveCount = itemMsg ~= nil and itemMsg.number or 0
                        UIUtil.LoadHeroItem(item, itemData, string.format("%d/%d", haveCount, itemCount))
                        item.countLabel.color = haveCount >= itemCount and Color.white or Color.red
                        SetClickCallback(item.iconObject, function(go)
                            _ui.gatherItemId = itemId
                            _ui.gatherItemCount = itemCount
                            print("物品表格Id:", itemId)
                            LoadGatherItem()
                            if not _ui.gatherItem.gameObject.activeSelf then
                                _ui.gatherItem.gameObject:SetActive(true)
                                UITweener.PlayAllTweener(_ui.container.gameObject, true, true, false)
                                UITweener.PlayAllTweener(_ui.gatherItem.gameObject, true, true, false)
                            end
                        end)
                    else
                        item.gameObject:SetActive(false)
                    end
                end
            end

            _ui.labelNeedLevel.color = v.levelEnough and Color.white or Color.red
            _ui.labelNeedLevel.text = String.Format(TextMgr:GetText(Text.hero_ui1), targetLevel)

            currentLevelEnough = v.levelEnough
            currentItemEnough = v.itemEnough
        end
    end
end

local function UpgradeClickCallback(go)
    if not currentLevelEnough then
    	AudioMgr:PlayUISfx("SFX_ui02", 1, false)
        FloatText.Show(TextMgr:GetText(Text.common_ui11), Color.white)
    elseif not currentItemEnough then
    	AudioMgr:PlayUISfx("SFX_ui02", 1, false)
        FloatText.Show(TextMgr:GetText(Text.common_ui12), Color.white)
    else
        local req = HeroMsg_pb.MsgHeroBadgeUpRequest()
        req.heroUid = heroMsg.uid
        req.badgeid = selectedBadgeId
        Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgHeroBadgeUpRequest, req, HeroMsg_pb.MsgHeroBadgeUpResponse, function(msg)
            if msg.code ~= ReturnCode_pb.Code_OK then
                Global.ShowError(msg.code)
                if _ui ~= nil then
                    _ui.btnUpgrade.isEnabled = true
                end
            else
                if _ui ~= nil then
                    _ui.btnUpgrade.isEnabled = false
                    _ui.waitingCoroutine = true
                end
                MainCityUI.UpdateRewardData(msg.fresh)
                CloseClickCallback()
                HeroInfo.PlayBadgeEffect(selectedBadgeId)
            end
        end)
    end
end

function Awake()
    _ui = {}
    local closeButton = transform:Find("Container/outline/close btn"):GetComponent("UIButton")
    SetClickCallback(closeButton.gameObject, CloseClickCallback)
	
	local maskbg = transform:Find("mask")
    SetClickCallback(maskbg.gameObject, CloseClickCallback)
	
    _ui.container = transform:Find("Container")
    _ui.currentBadge = {}
    _ui.currentBadge.bg = transform:Find("Container/current medal widget")
    _ui.currentBadge.quality = transform:Find("Container/current medal widget/medal icon/outline1"):GetComponent("UISprite")
    _ui.currentBadge.icon = transform:Find("Container/current medal widget/medal icon"):GetComponent("UITexture")
    _ui.currentBadge.name = transform:Find("Container/current medal widget/medal name"):GetComponent("UILabel")

    _ui.currentBadge.attr1Name = transform:Find("Container/current medal widget/quality1"):GetComponent("UILabel")
    _ui.currentBadge.attr1Value = transform:Find("Container/current medal widget/quality1/quality num"):GetComponent("UILabel")

    _ui.currentBadge.attr2Name = transform:Find("Container/current medal widget/quality2"):GetComponent("UILabel")
    _ui.currentBadge.attr2Value = transform:Find("Container/current medal widget/quality2/quality num"):GetComponent("UILabel")

    _ui.targetBadge = {}
    _ui.targetBadge.bg = transform:Find("Container/target medal widget")
    _ui.targetBadge.icon = transform:Find("Container/target medal widget/medal icon"):GetComponent("UITexture")
    _ui.targetBadge.quality = transform:Find("Container/target medal widget/medal icon/outline1"):GetComponent("UISprite")
    _ui.targetBadge.name = transform:Find("Container/target medal widget/medal name"):GetComponent("UILabel")

    _ui.targetBadge.attr1Name = transform:Find("Container/target medal widget/quality1"):GetComponent("UILabel")
    _ui.targetBadge.attr1Value = transform:Find("Container/target medal widget/quality1/quality num"):GetComponent("UILabel")

    _ui.targetBadge.attr2Name = transform:Find("Container/target medal widget/quality2"):GetComponent("UILabel")
    _ui.targetBadge.attr2Value = transform:Find("Container/target medal widget/quality2/quality num"):GetComponent("UILabel")
    _ui.targetBadge.lock = transform:Find("Container/target medal widget/lock")
    _ui.targetBadge.defaultPos = _ui.targetBadge.bg.localPosition

    _ui.arrowIcon = transform:Find("Container/arrow") 
    _ui.maxIcon = transform:Find("Container/max")
    _ui.lockIcon = transform:Find("Container/lv lock")
    _ui.lockLabel = transform:Find("Container/lv lock/lv text"):GetComponent("UILabel")

    _ui.itemList = {}
    _ui.itemList.bg = transform:Find("Container/compose widget")
    for i = 1, 5 do
        local item = {}
        local itemTransform = transform:Find("Container/compose widget/listitem_hero_item" .. i)
        UIUtil.LoadHeroItemObject(item, itemTransform)

        _ui.itemList[i] = item
    end

    _ui.gatherItemTransform = transform:Find("GatherItem")
    _ui.gatherItem = GatherItem()

    _ui.gatherItem:LoadObject(_ui.gatherItemTransform)
    SetClickCallback(_ui.gatherItem.closeButton.gameObject, function(go)
        _ui.gatherItem.gameObject:SetActive(false)
        UITweener.PlayAllTweener(_ui.container.gameObject, false, true, false)
        UITweener.PlayAllTweener(_ui.gatherItem.gameObject, false, true, false)
    end)

    _ui.btnUpgrade = transform:Find("Container/compose widget/compose btn"):GetComponent("UIButton")
    _ui.btnOk = transform:Find("Container/OK btn"):GetComponent("UIButton")
    SetClickCallback(_ui.btnUpgrade.gameObject, UpgradeClickCallback)
    SetClickCallback(_ui.btnOk.gameObject, UpgradeClickCallback)

    _ui.labelNeedLevel = transform:Find("Container/compose widget/Label"):GetComponent("UILabel")
    HeroListData.AddListener(LoadUI)
    ItemListData.AddListener(LoadUI)
    ItemListData.AddListener(LoadGatherItem)
    _ui.waitingCoroutine = false
    LoadUI()
end

function Close()
    _ui.gatherItem:Close()
    HeroListData.RemoveListener(LoadUI)
    ItemListData.RemoveListener(LoadUI)
    ItemListData.RemoveListener(LoadGatherItem)
    _ui = nil
end

function Show(uid, index)
    heroUid = uid
    selectedBadgeIndex = index
    Global.OpenUI(_M)
end

module("HeroLevelUp", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
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
local LoadHero = HeroList.LoadHero

local oldHeroMsg
local oldHeroData
local newHeroMsg
local newHeroData

local _ui

function LoadUI()
    oldHeroData = TableMgr:GetHeroData(oldHeroMsg.baseid)
    newHeroData = TableMgr:GetHeroData(newHeroMsg.baseid)
    HeroInfo.LoadHeadPage(_ui.headPage, newHeroMsg, newHeroData)

    _ui.oldLevelLabel.text = oldHeroMsg.level
    _ui.newLevelLabel.text = newHeroMsg.level
    local alist = {}
    alist[1] = HeroListData.GetAttrList(oldHeroMsg, oldHeroData)
    alist[2] = HeroListData.GetAttrList(newHeroMsg, newHeroData)

    local attrIndex = 1
    for k, v in kpairs(alist[2]) do
        local attr = _ui.attrList[attrIndex]
        attr.nameLabel.gameObject:SetActive(true)
        attr.nameLabel.text = TextMgr:GetText(v.data.unlockedText)
        attr.valueLabel[2].text = Global.GetHeroAttrValueString(v.data.additionAttr, v.value)
        attr.valueLabel[2].gameObject:SetActive(true)
        local v1 = alist[1][k]
        attr.valueLabel[1].text = Global.GetHeroAttrValueString(v1.data.additionAttr, v1.value)
        attr.valueLabel[1].gameObject:SetActive(true)

        attrIndex = attrIndex + 1
    end

    for i = attrIndex, HeroListData.MaxAttrCount do
        local attr = _ui.attrList[i]
        attr.nameLabel.gameObject:SetActive(false)
        attr.valueLabel[1].gameObject:SetActive(false)
        attr.valueLabel[2].gameObject:SetActive(false)
    end
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local function CloseClickCallback()
    HeroUpgrade.CloseAll()
end

function Awake()
    _ui = {}
    local closeBtn = transform:Find("Container/close btn"):GetComponent("UIButton")
    local okBtn = transform:Find("ok btn"):GetComponent("UIButton")
    SetClickCallback(closeBtn.gameObject, Hide)
    SetClickCallback(okBtn.gameObject, Hide)

    _ui.headPage = {}
    local headTransform = transform:Find("head widget")
    HeroInfo.LoadHeadPageObject(_ui.headPage, headTransform)

    _ui.oldLevelLabel = transform:Find("Container/info bg/lv text/lv num1"):GetComponent("UILabel")
    _ui.newLevelLabel = transform:Find("Container/info bg/lv text/lv num2"):GetComponent("UILabel")
    local levelEffect = transform:Find("Container/info bg/lv text/HeroAUp")
    local levelTweener = transform:Find("Container/info bg/lv text"):GetComponent("UITweener")
    _ui.levelUpCoroutine = coroutine.start(function()
        coroutine.wait(levelTweener.delay)
        levelEffect.gameObject:SetActive(true)
    end)

    _ui.attrList = {}
    for i = 1, HeroListData.MaxAttrCount do
        _ui.attrList[i] = {}
        _ui.attrList[i].nameLabel = transform:Find(string.format("Container/info bg/quality%d", i)):GetComponent("UILabel")
        _ui.attrList[i].valueLabel = {}
        for j = 1, 2 do
            _ui.attrList[i].valueLabel[j] = transform:Find(string.format("Container/info bg/quality%d/lv num%d", i, j)):GetComponent("UILabel")
        end
        local attrEffect = transform:Find(string.format("Container/info bg/quality%d/HeroAUp", i))
        attrEffect.gameObject:SetActive(false)
        local attrTweener = transform:Find(string.format("Container/info bg/quality%d", i)):GetComponent("UITweener")
        attrTweener:SetOnFinished(EventDelegate.Callback(function()
            attrEffect.gameObject:SetActive(true)
        end))
    end
    LoadUI()
end

function Close()
    coroutine.stop(_ui.levelUpCoroutine)
    _ui = nil
end

function Show(oldMsg, newMsg)
    oldHeroMsg = oldMsg
    newHeroMsg = newMsg
    Global.OpenUI(_M)
end


module("LuckyRotaryReward", package.seeall)

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
local Format = System.String.Format

local _ui = nil

function Hide()
    Global.CloseUI(_M)
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

local function LoadUI()
    for i, v in ipairs(_ui.rewards) do
        local itemdata = TableMgr:GetItemData(v.id)
		local item = NGUITools.AddChild(_ui.gridTransform.gameObject, _ui.itemPrefab).transform
		local reward = {}
		UIUtil.LoadItemObject(reward, item)
        UIUtil.LoadItem(reward, itemdata, v.num)
        UIUtil.SetClickCallback(reward.transform.gameObject, function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
            end
        end)
    end
    _ui.grid.repositionNow = true
    _ui.hintATKRoot.gameObject:SetActive(true)
    _ui.hintATKLabel.text = Format(TextMgr:GetText("LuckyRotary_10"), _ui.count)
    _ui.title.text = TextMgr:GetText("Union_Radar_ui2")
    UIUtil.SetBtnEnable(_ui.rewardButton ,"btn_2", "btn_4", _ui.status == 2)
    if _ui.status == 1 then
        _ui.rewardLabel.text = TextMgr:GetText("mission_reward")
        SetClickCallback(_ui.rewardButton.gameObject, function(go)
            FloatText.ShowOn(_ui.rewardButton.gameObject, TextMgr:GetText("SectionRewards_ui4"), Color.white)
        end)
    elseif _ui.status == 2 then
        _ui.rewardLabel.text = TextMgr:GetText("mission_reward")
        SetClickCallback(_ui.rewardButton.gameObject, function(go)
            if _ui.callback then
                _ui.callback()
            end
            Hide()
        end)
    elseif _ui.status == 3 then
        _ui.rewardLabel.text = TextMgr:GetText("SectionRewards_ui5")
        SetClickCallback(_ui.rewardButton.gameObject, function(go)
            
        end)
    end
end

function Awake()
    _ui = {}
    _ui.containerObject = transform:Find("Container").gameObject
    _ui.hintRoot = transform:Find("Container/bg_frane/bg_hint")
    _ui.hintLabel = transform:Find("Container/bg_frane/bg_hint/text"):GetComponent("UILabel")
    _ui.hintATKRoot = transform:Find("Container/bg_frane/bg_hint_PVPATK")
    _ui.hintATKLabel = transform:Find("Container/bg_frane/bg_hint_PVPATK/text"):GetComponent("UILabel")
    _ui.hintClimbRoot = transform:Find("Container/bg_frane/bg_hint_climb")
    _ui.hintClimbLabel = transform:Find("Container/bg_frane/bg_hint_climb/text"):GetComponent("UILabel")    
    
    _ui.rewardButton = transform:Find("Container/bg_frane/button"):GetComponent("UIButton")
    _ui.rewardLabel = transform:Find("Container/bg_frane/button/Label"):GetComponent("UILabel")
    _ui.title = transform:Find("Container/bg_frane/bg_top/title"):GetComponent("UILabel")
    _ui.gridTransform = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid")
    _ui.grid = _ui.gridTransform:GetComponent("UIGrid")
    _ui.itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    _ui.heroPrefab = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")

    _ui.hintRoot.gameObject:SetActive(false)
    _ui.hintClimbRoot.gameObject:SetActive(false)
    _ui.hintATKRoot.gameObject:SetActive(false)
    SetClickCallback(_ui.containerObject, Hide)

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()
    LoadUI()
end

function Show(rewards, callback, status, count)
    Global.OpenUI(_M)
    _ui.rewards = rewards
    _ui.callback = callback
    _ui.status = status
    _ui.count = count
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
    _ui = nil
end

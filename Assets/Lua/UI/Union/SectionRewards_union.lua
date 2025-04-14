module("SectionRewards_union", package.seeall)

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
    ShareCommon.LoadRewardList(_ui, _ui.gridTransform, _ui.dropId)
    _ui.grid.repositionNow = true
    _ui.title.text = TextMgr:GetText("union_donatereward1")
    _ui.hintLabel.text = System.String.Format(TextMgr:GetText("union_donatereward2"), _ui.requiredCount)
    UIUtil.SetBtnEnable(_ui.rewardButton ,"union_button1", "union_button1_un", _ui.status == 2)
    _ui.rewardLabel.text = TextMgr:GetText(_ui.status == 3 and Text.SectionRewards_ui5 or Text.mail_ui12)
    SetClickCallback(_ui.rewardButton.gameObject, function(go)
        if _ui.status == 1 then
            FloatText.Show(TextMgr:GetText("SectionRewards_ui4") , Color.red)
        elseif _ui.status == 2 then
            local req = GuildMsg_pb.MsgTakeContributeStepRewardRequest()
            req.step = _ui.step
            Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgTakeContributeStepRewardRequest, req, GuildMsg_pb.MsgTakeContributeStepRewardResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    UnionDonateData.UpdateStepRewardData(msg.step)
                    Global.ShowReward(msg.reward)
                    MainCityUI.UpdateRewardData(msg.fresh)
                    Hide()
                else
                    Global.ShowError(msg.code)
                end
            end)
        end
    end)
end

function Awake()
    _ui = {}
    _ui.containerObject = transform:Find("Container").gameObject
    _ui.hintRoot = transform:Find("Container/bg_frane/bg_hint")
    _ui.hintLabel = transform:Find("Container/bg_frane/bg_hint/text"):GetComponent("UILabel")
    _ui.hintATKRoot = transform:Find("Container/bg_frane/bg_hint_PVPATK")
    _ui.hintATKLabel = transform:Find("Container/bg_frane/bg_hint_PVPATK/text")
    _ui.rewardButton = transform:Find("Container/bg_frane/button"):GetComponent("UIButton")
    _ui.rewardLabel = transform:Find("Container/bg_frane/button/Label"):GetComponent("UILabel")
    _ui.title = transform:Find("Container/bg_frane/bg_top/title"):GetComponent("UILabel")
    _ui.gridTransform = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid")
    _ui.grid = _ui.gridTransform:GetComponent("UIGrid")
    _ui.itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    _ui.heroPrefab = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")

    _ui.hintRoot.gameObject:SetActive(true)
    _ui.hintATKRoot.gameObject:SetActive(false)
    SetClickCallback(_ui.containerObject, Hide)

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()
    LoadUI()
end

function Show(requiredCount, dropId, status, step)
    Global.OpenUI(_M)
    _ui.dropId = dropId
    _ui.requiredCount = requiredCount
    _ui.status = status
    _ui.step = step
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
    _ui = nil
end

module("SectionRewards", package.seeall)

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
    if _ui.custom_callback ~= nil then
        _ui.custom_callback(_ui)
        return 
    end
    _ui.title.text = TextMgr:GetText("SectionRewards_ui1")
    _ui.hintLabel.text = System.String.Format(TextMgr:GetText("SectionRewards_ui2"), _ui.starCount)
    UIUtil.SetBtnEnable(_ui.rewardButton ,"btn_2", "btn_4", _ui.status == "_done")
    _ui.rewardLabel.text = TextMgr:GetText(_ui.status == "open" and Text.SectionRewards_ui5 or Text.mail_ui12)
    SetClickCallback(_ui.rewardButton.gameObject, function(go)
        if _ui.status == "_null" then
            FloatText.Show(TextMgr:GetText("SectionRewards_ui4") , Color.red)
        elseif _ui.status == "_done" then
            local req = BattleMsg_pb.MsgGetChapterStarRewardRequest();
            req.id = _ui.sandId
            req.index = _ui.rewardIndex
            Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgGetChapterStarRewardRequest, req, BattleMsg_pb.MsgGetChapterStarRewardResponse, function(msg)
                if msg.code ~= ReturnCode_pb.Code_OK then
                    Global.ShowError(msg.code)
                else
                    ChapterListData.ForceUpdateChapterData(msg.chapter)
                    MainCityUI.UpdateRewardData(msg.fresh)
                    MainCityUI.UpdateBattleReward()
                    MainData.SetStarReward(msg.starReward)
                    if _ui ~= nil then
                        Hide()
                    end
                    if GUIMgr:IsMenuOpen("SandSelect") then
                        SandSelect.LoadUI()
                    end

                    ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
                    ItemListShowNew.SetItemShow(msg)
                    GUIMgr:CreateMenu("ItemListShowNew" , false)

                    TalentInfoData.RequestData()
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

    _ui.hintRoot.gameObject:SetActive(true)
    _ui.hintClimbRoot.gameObject:SetActive(false)
    _ui.hintATKRoot.gameObject:SetActive(false)
    SetClickCallback(_ui.containerObject, Hide)

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()
    LoadUI()
end

function ShowCustom(dropId,custom_callback)
    Global.OpenUI(_M)
    _ui.dropId = dropId
    _ui.custom_callback = custom_callback
end

function Show(sandId, rewardIndex, dropId, starCount, status)
    Global.OpenUI(_M)
    _ui.sandId = sandId
    _ui.rewardIndex = rewardIndex
    _ui.dropId = dropId
    _ui.starCount = starCount
    _ui.status = status
    
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
    _ui = nil
end

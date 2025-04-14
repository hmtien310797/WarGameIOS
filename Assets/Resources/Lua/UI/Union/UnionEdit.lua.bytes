module("UnionEdit", package.seeall)
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
    Hide()
end

local function UpdateInnerLimit()
    local innerCount = utf8.len(_ui.innerInput.value)
    _ui.innerNumberLabel.text = Format(TextMgr:GetText(Text.union_edit1), _ui.innerLimit - innerCount)
end

local function UpdateOuterLimit()
    local outerCount = utf8.len(_ui.outerInput.value)
    _ui.outerNumberLabel.text = Format(TextMgr:GetText(Text.union_edit1), _ui.outerLimit - outerCount)
end

local recruitTextList =
{
    [GuildMsg_pb.RecruitType_apply] = Text.union_needaprove,
    [GuildMsg_pb.RecruitType_public] = Text.union_publicrecruit,
    [GuildMsg_pb.RecruitType_reject] = Text.union_canotapply,
}

local function UpdateRecruitType()
    _ui.recruitLabel.text = TextMgr:GetText(recruitTextList[_ui.recruitType])
    _ui.leftButton.isEnabled = _ui.recruitType > GuildMsg_pb.RecruitType_apply
    _ui.rightButton.isEnabled = _ui.recruitType < GuildMsg_pb.RecruitType_reject
end

function LoadUI()
    local unionInfoMsg = UnionInfoData.GetData()
    local unionMsg = unionInfoMsg.guildInfo
    _ui.innerInput.value = unionMsg.innerNotice
    _ui.outerInput.value = unionMsg.outerNotice
    UpdateInnerLimit()
    UpdateOuterLimit()
    _ui.recruitType = unionMsg.recruitType
    UpdateRecruitType()
    _ui.powerInput.value = unionMsg.pkValueLimit

    local isLeader = UnionInfoData.IsUnionLeader()
    _ui.powerObject:SetActive(isLeader)
    _ui.recruitTypeObject:SetActive(isLeader)
end

function Start()
    _ui.innerInput = transform:Find("background widget/content/inside/frame_input"):GetComponent("UIInput")
    _ui.innerInput.defaultText = TextMgr:GetText(Text.click_input)
    _ui.innerLimit = _ui.innerInput.characterLimit
    _ui.innerNumberLabel = transform:Find("background widget/content/inside/des"):GetComponent("UILabel")
    EventDelegate.Add(_ui.innerInput.onChange, EventDelegate.Callback(function()
        UpdateInnerLimit()
    end))

    _ui.outerInput = transform:Find("background widget/content/outside/frame_input"):GetComponent("UIInput")
    _ui.outerInput.defaultText = TextMgr:GetText(Text.click_input)
    _ui.outerLimit = _ui.outerInput.characterLimit
    _ui.outerNumberLabel = transform:Find("background widget/content/outside/des"):GetComponent("UILabel")
    EventDelegate.Add(_ui.outerInput.onChange, EventDelegate.Callback(function()
        UpdateOuterLimit()
    end))

    _ui.powerObject = transform:Find("background widget/content/apply_combat_edit").gameObject
    _ui.powerInput = transform:Find("background widget/content/apply_combat_edit/frame_input"):GetComponent("UIInput")
    SetClickCallback(_ui.powerInput.gameObject, function()
        NumberInput.Show(_ui.powerInput.value, 0, 9999999999, function(number)
            _ui.powerInput.value = number
        end)
    end)

    _ui.recruitTypeObject = transform:Find("background widget/content/apply_type_edit").gameObject
    _ui.recruitLabel = transform:Find("background widget/content/apply_type_edit/frame_input (1)/title"):GetComponent("UILabel")
    _ui.leftButton = transform:Find("background widget/content/apply_type_edit/btn_left"):GetComponent("UIButton")
    _ui.rightButton = transform:Find("background widget/content/apply_type_edit/btn_right"):GetComponent("UIButton")

    SetClickCallback(_ui.leftButton.gameObject, function(go)
        _ui.recruitType = _ui.recruitType - 1
        UpdateRecruitType()
    end)

    SetClickCallback(_ui.rightButton.gameObject, function(go)
        _ui.recruitType = _ui.recruitType + 1
        UpdateRecruitType()
    end)
    
    _ui.saveButton = transform:Find("background widget/content/btn ok"):GetComponent("UIButton")
    
    SetClickCallback(_ui.saveButton.gameObject, function()
        local request = GuildMsg_pb.MsgEditGuildBasicInfoRequest()
        request.innerNotice = _ui.innerInput.value
        request.outerNotice = _ui.outerInput.value
        request.recruitType = _ui.recruitType
        request.pkValueLimit = tonumber(_ui.powerInput.value)
        Global.LogDebug(_M, "REQUEST SAVE", request.innerNotice, request.outerNotice, request.recruitType, request.pkValueLimit)
        Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgEditGuildBasicInfoRequest, request, GuildMsg_pb.MsgEditGuildBasicInfoResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                _ui.innerInput.value = msg.innerNotice
                UnionInfoData.SetInnerNotice(msg.innerNotice)
                UpdateInnerLimit()

                _ui.outerInput.value = msg.outerNotice
                UnionInfoData.SetOuterNotice(msg.outerNotice)
                UpdateOuterLimit()

                _ui.recruitType = msg.recruitType
                UnionInfoData.SetRecruitType(msg.recruitType)
                UpdateRecruitType()

                _ui.powerInput.value = msg.pkValueLimit
                UnionInfoData.SetPKValueLimit(msg.pkValueLimit)

                CloseAll()
            else
                Global.ShowError(msg.code)
            end
        end, false)
    end)

    LoadUI()
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("background widget/close btn")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)

    UnionDonateData.AddListener(LoadUI)
end

function Close()
    UnionDonateData.RemoveListener(LoadUI)
    _ui = nil
end

function Show()
    Global.OpenUI(_M)
end

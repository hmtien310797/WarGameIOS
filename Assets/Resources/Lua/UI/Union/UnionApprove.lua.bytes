module("UnionApprove", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback

local _ui

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function LoadUI()
    local function LoadApplicantObject(applicant, applicantTransform)
        applicant.faceTexture = applicantTransform:Find("head_bg/icon"):GetComponent("UITexture")
        applicant.faceBg = applicantTransform:Find("head_bg").gameObject
        applicant.nameLabel = applicantTransform:Find("bg/name text"):GetComponent("UILabel")
        applicant.powerLabel = applicantTransform:Find("bg/combat num"):GetComponent("UILabel")
        applicant.killLabel = applicantTransform:Find("bg/annihilate num"):GetComponent("UILabel")
        applicant.refuseButton = applicantTransform:Find("cancel btn"):GetComponent("UIButton")
        applicant.acceptButton = applicantTransform:Find("ok btn"):GetComponent("UIButton")
        applicant.killLabel = applicantTransform:Find("bg/annihilate num"):GetComponent("UILabel")
        applicant.officialLabel = applicantTransform:Find("bg/official text"):GetComponent("UILabel")
        applicant.joinLabel = applicantTransform:Find("bg/join text"):GetComponent("UILabel")
    end

    local function LoadApplicant(applicant, applicantMsg, toggleIndex)
        SetClickCallback(applicant.faceBg, function()
            OtherInfo.RequestShow(applicantMsg.charId)
        end)

        local function RequestDealApplicant(charId, charName, accept)
            local req = GuildMsg_pb.MsgDealApplicationRequest()
            req.charId = charId
            req.type = accept and GuildMsg_pb.DealApplicationType_Pass or GuildMsg_pb.DealApplicationType_Reject

            Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgDealApplicationRequest, req, GuildMsg_pb.MsgDealApplicationResponse, function(msg)
                UnionApplyData.RequestData()
                if msg.code == ReturnCode_pb.Code_OK then
                    if accept then
                        UnionInfoData.RequestData()

                        local send = {}
                        send.curChanel = ChatMsg_pb.chanel_guild
                        send.spectext = ""
                        send.content = "TipsNotice_Union_Desc6"..","..charName--System.String.Format(TextMgr:GetText("TipsNotice_Union_Desc6"), charName)
                        send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
                        send.chatType = 4
                        send.senderguildname = UnionInfoData.GetData().guildInfo.banner
                        Chat.SendContent(send)
                    end
                else
                    Global.ShowError(msg.code)
                end
            end, false)
        end

        local function RequestPositionApplicant(charId, charName, accept)
            local req = GuildMsg_pb.MsgDealPositionApplicationRequest()
            req.charId = charId
            req.type = accept and GuildMsg_pb.DealApplicationType_Pass or GuildMsg_pb.DealApplicationType_Reject

            Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgDealPositionApplicationRequest, req, GuildMsg_pb.MsgDealPositionApplicationResponse, function(msg)
                UnionApplyData.RequestData()
                if msg.code == ReturnCode_pb.Code_OK then
                else
                    Global.ShowError(msg.code)
                end
            end, false)
        end

        SetClickCallback(applicant.refuseButton.gameObject, function()
            if toggleIndex == 1 then
                RequestDealApplicant(applicantMsg.charId, applicantMsg.name, false)
            else
                RequestPositionApplicant(applicantMsg.charId, applicantMsg.name, false)
            end
        end)
        SetClickCallback(applicant.acceptButton.gameObject, function()
            if toggleIndex == 1 then
                RequestDealApplicant(applicantMsg.charId, applicantMsg.name, true)
            else
                RequestPositionApplicant(applicantMsg.charId, applicantMsg.name, true)
            end
        end)

        applicant.faceTexture.mainTexture = ResourceLibrary:GetIcon("Icon/head/", applicantMsg.face)
        applicant.nameLabel.text = applicantMsg.name
        applicant.powerLabel.text = Global.FormatNumber(applicantMsg.pkValue)
        applicant.killLabel.text = applicantMsg.killArmyNum
        applicant.joinLabel.gameObject:SetActive(toggleIndex == 1)
        applicant.officialLabel.gameObject:SetActive(toggleIndex == 2)
        if toggleIndex == 2 then
            applicant.officialLabel.text = TextMgr:GetText("union_member_level" .. applicantMsg.applyPosition)
        end
    end

    local applyMsg = UnionApplyData.GetData()
    for i, v in ipairs(_ui.applyList) do
        local applicantListMsg = i == 1 and applyMsg.applicants or applyMsg.positionApplicants
        for ii, vv in ipairs(applicantListMsg) do
            local applicantTransform
            if ii > v.grid.transform.childCount then
                applicantTransform = NGUITools.AddChild(v.grid.gameObject, _ui.applicantPrefab).transform
            else
                applicantTransform = v.grid:GetChild(ii - 1)
            end

            applicantTransform.gameObject:SetActive(true)
            local applicant = {}
            LoadApplicantObject(applicant, applicantTransform)
            LoadApplicant(applicant, vv, i)
        end
        for ii = #applicantListMsg + 1, v.grid.transform.childCount do
            v.grid:GetChild(ii - 1).gameObject:SetActive(false)
        end
        v.grid.repositionNow = true
        v.emptyObject:SetActive(#applicantListMsg == 0)
        v.noticeObject:SetActive(#applicantListMsg ~= 0)
    end
    _ui.toggleList[2].gameObject:SetActive(UnionInfoData.IsLeader())
end

function Awake()
    _ui = {}
    if _ui.applicantPrefab == nil then
        _ui.applicantPrefab = ResourceLibrary.GetUIPrefab("Union/listitem_ applicant")
    end
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/close btn")

    SetClickCallback(mask.gameObject, Hide)
    SetClickCallback(closeButton.gameObject, Hide)

    UnionApplyData.AddListener(LoadUI)
end

function Start()
    _ui.applyList = {}
    _ui.toggleList = {}
    for i = 1, 2 do
        local uiToggle = transform:Find("Container/Sprite/page" .. i):GetComponent("UIToggle")
        _ui.toggleList[i] = uiToggle
        local apply = {}
        apply.scrollView = transform:Find("Container/Sprite/Scroll View" .. i):GetComponent("UIScrollView")
        apply.grid = apply.scrollView.transform:Find("Grid"):GetComponent("UIGrid")
        apply.emptyObject = apply.scrollView.transform:Find("no one").gameObject
        apply.noticeObject = transform:Find(string.format("Container/Sprite/page%d/red", i)).gameObject
        _ui.applyList[i] = apply
    end
    for i, v in ipairs(_ui.toggleList) do
        v.value = i == _ui.toggleIndex
    end
    LoadUI()
end

function Close()
    UnionApplyData.RemoveListener(LoadUI)
    _ui = nil
end

function Show(toggleIndex)
    UnionApplyData.RequestData(function()
        Global.OpenUI(_M)
        _ui.toggleIndex = toggleIndex or 1
    end, true)
end

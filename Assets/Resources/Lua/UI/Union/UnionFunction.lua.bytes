module("UnionFunction", package.seeall)

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

local function UpdateApplyNotice()
    _ui.applyNotice:SetActive(UnionApplyData.HasNotice())
end

function LoadUI()
    if not UnionInfoData.HasUnion() then
        CloseAll()
        return
    end
    local unionInfoMsg = UnionInfoData.GetData()
    local unionMsg = unionInfoMsg.guildInfo
    local memberMsg = unionInfoMsg.memberInfo

    local leaderCharId = unionMsg.leaderCharId
    local charId = MainData.GetCharId()
    local isLeader = leaderCharId == charId

    _ui.editButton.gameObject:SetActive(UnionInfoData.HasPrivilege(GuildMsg_pb.PrivilegeType_EditInnerNotice))
    _ui.applyButton.gameObject:SetActive(UnionInfoData.HasPrivilege(GuildMsg_pb.PrivilegeType_ManageApplicant))
    _ui.leaveButton.gameObject:SetActive(not isLeader)

    _ui.nameButton.gameObject:SetActive(isLeader)
    _ui.codeButton.gameObject:SetActive(isLeader)
    _ui.badgeButton.gameObject:SetActive(isLeader)
    _ui.languageButton.gameObject:SetActive(isLeader)
    _ui.abdicationButton.gameObject:SetActive(isLeader)
    _ui.dissolutionButton.gameObject:SetActive(isLeader)

    _ui.grid.repositionNow = true

    UpdateApplyNotice()
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("manage widget/close btn")

    SetClickCallback(mask.gameObject, Hide)
    SetClickCallback(closeButton.gameObject, Hide)
end

function Start()
    _ui.gridTransform = transform:Find("manage widget/bg/Scroll View/Grid")
    _ui.grid = _ui.gridTransform:GetComponent("UIGrid")

    _ui.editButton = _ui.gridTransform:Find("edit"):GetComponent("UIButton")
    _ui.authorityButton = _ui.gridTransform:Find("authority"):GetComponent("UIButton")
    _ui.buffButton = _ui.gridTransform:Find("buff"):GetComponent("UIButton")
    _ui.rankButton = _ui.gridTransform:Find("rank"):GetComponent("UIButton")
    _ui.otherButton = _ui.gridTransform:Find("other"):GetComponent("UIButton")
    _ui.inviteButton = _ui.gridTransform:Find("invite"):GetComponent("UIButton")
    _ui.inviteLabel = transform:Find("manage widget/bg/Scroll View/Grid/invite/Label (1)"):GetComponent("UILabel")
    _ui.applyButton = _ui.gridTransform:Find("apply"):GetComponent("UIButton")
    _ui.applyNotice = _ui.gridTransform:Find("apply/red").gameObject
    _ui.leaveButton = _ui.gridTransform:Find("leave"):GetComponent("UIButton")
    _ui.nameButton = _ui.gridTransform:Find("name"):GetComponent("UIButton")
    _ui.codeButton = _ui.gridTransform:Find("code"):GetComponent("UIButton")
    _ui.badgeButton = _ui.gridTransform:Find("badge"):GetComponent("UIButton")
    _ui.languageButton = _ui.gridTransform:Find("language"):GetComponent("UIButton")
    _ui.abdicationButton = _ui.gridTransform:Find("abdication"):GetComponent("UIButton")
    _ui.dissolutionButton = _ui.gridTransform:Find("dissolution"):GetComponent("UIButton")

    SetClickCallback(_ui.editButton.gameObject, function(go)
        UnionEdit.Show()
    end)

    SetClickCallback(_ui.authorityButton.gameObject, function(go)
        UnionAuthority.Show()
    end)

    SetClickCallback(_ui.buffButton.gameObject, function(go)
        UnionBuff.Show()
    end)

    SetClickCallback(_ui.rankButton.gameObject, function(go)
        UnionMemberRank.Show()
    end)

    SetClickCallback(_ui.otherButton.gameObject, function(go)
		rank.Show(2, 1)
    end)

    SetClickCallback(_ui.inviteButton.gameObject, function(go)
		UnionPubinfo.CheckAndSendUnionInvitation()
    end)

	local cost = tonumber(TableMgr:GetGlobalData(100077).value)
    _ui.inviteLabel.text = cost

    SetClickCallback(_ui.applyButton.gameObject, function(go)
        UnionApprove.Show()
    end)

    SetClickCallback(_ui.leaveButton.gameObject, function(go)
        MessageBox.Show(TextMgr:GetText(Text.union_leave), function()
			--1.先对联盟频道发送离开联盟的信息
			local send = {}
			send.curChanel = ChatMsg_pb.chanel_guild
			send.spectext = ""
			send.content = "TipsNotice_Union_Desc5"..","..MainData.GetCharName()--System.String.Format(TextMgr:GetText("TipsNotice_Union_Desc5") ,MainData.GetCharName() ) 
			send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
			send.chatType = 4
			--send.senderguildname = UnionInfoData.GetData().guildInfo.name
			Chat.SendContent(send) 
            
            
			 
			--2.信息发送完成后，发送离开联盟的请求信息
			local req = GuildMsg_pb.MsgExitGuildRequest()
			Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgExitGuildRequest, req, GuildMsg_pb.MsgExitGuildResponse, function(msg)
				if msg.code == ReturnCode_pb.Code_OK then
					UnionInfo.CloseAll()
					UnionInfoData.UpdateData(GuildMsg_pb.MsgSeeMyGuildResponse())
					UnionHelpData.SetMemberHelpData(GuildMsg_pb.MsgCompensateListResponse())
					ChatData.ClearChatData(ChatMsg_pb.chanel_guild)
					--SelfApplyData.RequestData()
					SelfApplyData.ClearApply()
					--清除联盟留言
                    ChatData.ResetunionMessageChatListSelf()
					--更新联盟月卡的状态
                    UnionCardData.RequestData(0)
					
					MainCityUI.MassTotlaNum[1] = 0
					MainCityUI.MassTotlaNum[2] = 0
					MainCityUI.UpdateMassBtn()
					
					--3. 请求清除与联盟相关的Notify记录：ClientNotifyType_GuildLog , ClientNotifyType_OccupyContest
					local reqNotify = 
					{
						ClientMsg_pb.ClientNotifyType_GuildLog,
						ClientMsg_pb.ClientNotifyType_OccupyContest,
					}
					NotifyInfoData.RequestMutiNotifyInfo(reqNotify)
				else
					Global.ShowError(msg.code)
				end
			end, false) 
        end,
        function()
        end)
    end)

    SetClickCallback(_ui.nameButton.gameObject, function(go)
        UnionName.Show()
    end)

    SetClickCallback(_ui.codeButton.gameObject, function(go)
        UnionCode.Show()
    end)

    SetClickCallback(_ui.badgeButton.gameObject, function(go)
        local unionInfoMsg = UnionInfoData.GetData()
        local unionMsg = unionInfoMsg.guildInfo
        UnionBadge.Show(unionMsg.badge, true, function(badgeInfo)
            local badgeId = UnionBadge.BadgeInfoToId(badgeInfo)
            local req = GuildMsg_pb.MsgChangeGuildBadgeRequest()
            req.badge = badgeId
            Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgChangeGuildBadgeRequest, req, GuildMsg_pb.MsgChangeGuildBadgeResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    UnionInfoData.SetBadge(msg.badge)
                    MainCityUI.UpdateRewardData(msg.fresh)
                    FloatText.Show(TextMgr:GetText(Text.union_badge_success))
                else
                    Global.ShowError(msg.code)
                end
            end, false) 
        end)
    end)

    SetClickCallback(_ui.languageButton.gameObject, function(go)
        local unionInfoMsg = UnionInfoData.GetData()
        local unionMsg = unionInfoMsg.guildInfo
        UnionLanguage.Show(unionMsg.lang, false, function(languageId)
            local req = GuildMsg_pb.MsgChooseGuildLangRequest()
            req.lang = languageId
            Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgChooseGuildLangRequest, req, GuildMsg_pb.MsgChooseGuildLangResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    unionMsg.lang = languageId
                    FloatText.Show(TextMgr:GetText(Text.union_language_success))
                else
                    Global.ShowError(msg.code)
                end
            end, false) 
        end)
    end)

    SetClickCallback(_ui.abdicationButton.gameObject, function(go)
        Hide()
        local unionInfoMsg = UnionInfoData.GetData()
        local unionMsg = unionInfoMsg.guildInfo
        UnionMemberLevel.Show(unionMsg.guildId, true)
    end)

    SetClickCallback(_ui.dissolutionButton.gameObject, function(go)
        if UnionInfoData.IsNormal() then
            MessageBox.Show(TextMgr:GetText(Text.union_dissolve_popup), function()
                local req = GuildMsg_pb.MsgDissolveGuildRequest()
                Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgDissolveGuildRequest, req, GuildMsg_pb.MsgDissolveGuildResponse, function(msg)
                    if msg.code == ReturnCode_pb.Code_OK then
                        UnionInfoData.RequestData()
                    else
                        Global.ShowError(msg.code)
                    end
                end, false) 
            end,
            function()
            end)
        else
            local req = GuildMsg_pb.MsgCancelDissolveRequest()
            Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgCancelDissolveRequest, req, GuildMsg_pb.MsgCancelDissolveResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    UnionInfoData.RequestData()
                else
                    Global.ShowError(msg.code)
                end
            end, false) 
        end
    end)

    LoadUI()

    UnionInfoData.AddListener(LoadUI)
    UnionApplyData.AddListener(UpdateApplyNotice)
end

function Close()
    UnionInfoData.RemoveListener(LoadUI)
    UnionApplyData.RemoveListener(UpdateApplyNotice)
    _ui = nil
end

function Show()
    Global.OpenUI(_M)
end

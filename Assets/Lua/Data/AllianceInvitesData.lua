module("AllianceInvitesData", package.seeall)

local GUIMgr = Global.GGUIMgr
local TextMgr = Global.GTextMgr

local pendingInvites = {}
local recommendedAlliance

----- Events -----------------------------------------------------
local eventOnDataChange = EventDispatcher.CreateEvent()

function OnDataChange()
    return eventOnDataChange
end

local function BroadcastEventOnDataChange()
    EventDispatcher.Broadcast(eventOnDataChange, #pendingInvites)
end
------------------------------------------------------------------

----- Data ------------------------------------------------
local function AddPendingInvite(invite)
    table.insert(pendingInvites, invite)

    BroadcastEventOnDataChange()
end

local function SetRecommendedAlliance(message)
    recommendedAlliance = {}
    recommendedAlliance.guildId = message.guildId
    recommendedAlliance.guildName = message.name
    recommendedAlliance.guildBanner = message.banner
    recommendedAlliance.guildBadge = message.badge
    recommendedAlliance.guildLanguage = message.lang
    recommendedAlliance.guildSlogan = message.outerNotice
end

local function RemovePendingInvite(index)
    table.remove(pendingInvites, index)

    BroadcastEventOnDataChange()
end

local function ClearPendingInvite()
    pendingInvites = {}

    BroadcastEventOnDataChange()
end

function ClearRecommendedAlliance() 
    recommendedAlliance = nil
end

function GetPendingInvite(index)
    return pendingInvites[index]
end

function GetPendingInvites()
    return pendingInvites
end

function GetNumPendingInvites()
    return #pendingInvites
end

function GetRecommendedAlliance()   
    return recommendedAlliance
end
-----------------------------------------------------------

function RequestInvites(callback)
    local request = GuildMsg_pb.MsgGuildGetInviteInfoRequest()
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildGetInviteInfoRequest, request, GuildMsg_pb.MsgGuildGetInviteInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            for i = #pendingInvites + 1, #msg.infos do
                local invite = msg.infos[i]

                local pendingInvite = {}
                pendingInvite.inviterCharId = invite.inviterCharId
                pendingInvite.inviterName = invite.inviterName
                pendingInvite.guildId = invite.guildId
                pendingInvite.guildName = invite.name
                pendingInvite.guildBanner = invite.banner
                pendingInvite.guildBadge = invite.badge
                pendingInvite.guildLanguage = invite.lang
                pendingInvite.guildSlogan = invite.outerNotice

                AddPendingInvite(pendingInvite)
            end

            if callback then
                callback(msg)
            end
        end
    end, true)
end

local function RequestHandleInvite(index, handlerType, callback)
    local pendingInvite = pendingInvites[index]

    local request = GuildMsg_pb.MsgGuildInviteHandleRequest()
    request.guildId = pendingInvite.guildId
    request.inviterCharId = pendingInvite.inviterCharId
    request.handlerType = handlerType

    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildInviteHandleRequest, request, GuildMsg_pb.MsgGuildInviteHandleResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            if callback then
                callback(msg)
            end
        else
            Global.ShowError(msg.code)
        end
    end)
end

function RequestRecommendedAlliance(callback)
    local request = GuildMsg_pb.MsgGuildRecommendRequest()

    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildRecommendRequest, request, GuildMsg_pb.MsgGuildRecommendResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetRecommendedAlliance(msg)

            if callback then
                callback(msg)
            end
        else
            print("[DEBUG][RequestRecommendedAlliance] Desired alliance not found")
            callback()
        end
    end, true)
end

function SendInvite(inviteeCharId)
    local request = GuildMsg_pb.MsgGuildInviteMemberRequest()
    request.inviteeCharId = inviteeCharId
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildInviteMemberRequest, request, GuildMsg_pb.MsgGuildInviteMemberResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            MessageBox.Show(TextMgr:GetText("ui_inviteunion_code3"))
        else
            Global.ShowError(msg.code)
        end
    end)
end

function AcceptInvite(index)
    RequestHandleInvite(index, 1, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            ClearPendingInvite()

            UnionInfoData.RequestData()
            UnionBuildingData.SetCheckNotice()
            UnionBuildingData.RequestData()
            SelfApplyData.ClearApply()
            JoinUnion.CloseAll()
            
            local send = {}
            send.curChanel = ChatMsg_pb.chanel_guild
            send.spectext = ""
            send.content = "TipsNotice_Union_Desc6" .. "," .. MainData.GetCharName()
            send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
            send.chatType = 4
            send.senderguildname = UnionInfoData.GetData().guildInfo.name
            Chat.SendContent(send)
        else
            RemovePendingInvite(index)
            Global.ShowError(msg.code)
        end
    end)
end

function RefuseInvite(index)
    RequestHandleInvite(index, 2)
    RemovePendingInvite(index)
end

function JoinRecommendedAlliance()
    local request = GuildMsg_pb.MsgJoinGuildRequest()
    request.guildId = recommendedAlliance.guildId

    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgJoinGuildRequest, request, GuildMsg_pb.MsgJoinGuildResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            UnionBuildingData.RequestData()
            SelfApplyData.ClearApply()
            
            UnionInfoData.UpdateData(msg)
            UnionBuildingData.CheckNotice()
			UnionCardData.RequestData(0)
            JoinUnion.CloseAll()
            
            local send = {}
            send.curChanel = ChatMsg_pb.chanel_guild
            send.spectext = ""
            send.content = "TipsNotice_Union_Desc6" .. "," .. MainData.GetCharName()
            send.languageCode = TextMgr:GetCurrentLanguageID()
            send.chatType = 4
            send.senderguildname = UnionInfoData.GetData().guildInfo.name
            Chat.SendContent(send)
        else
            Global.ShowError(msg.code)
        end

        ClearRecommendedAlliance()
        MainCityUI.HideAllianceInvites()
    end, false)
end

function Test_AddingPlayerInvites(n) -- AllianceInvitesData.Test_AddingPlayerInvites()
    for i = 1, (n or 1) do
        local invite = {}

        invite.inviterCharId = 999
        invite.inviterName = string.format("TestInviter_%d", i)
        invite.guildId = 0
        invite.guildName = string.format("TestGuild_%d", i)
        invite.guildBanner = string.format("TG%d", i)
        invite.guildBadge = UnionBadge.CreateRandomBadgeId()
        invite.guildLanguage = 1
        invite.guildSlogan = string.format("This is test data %d.", i)

        AddPendingInvite(invite)
    end
end

function Test_SettingRecommendedAlliance() -- AllianceInvitesData.Test_SettingRecommendedAlliance()
    local msg = {}

    msg.code = ReturnCode_pb.Code_OK
    msg.guildId = math.random(1, 100)
    msg.name = "TestRecommendedAlliance"
    msg.banner = "TRA"
    msg.badge = UnionBadge.CreateRandomBadgeId()
    msg.lang = 1
    msg.outerNotice = string.format("This is test data (id = %d).", msg.guildId)

    SetRecommendedAlliance(msg)
end

module("UnionManagement", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback

local targetMemberMsg

local _ui

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    UnionSetLevel.CloseAll()
    Hide()
end

function LoadUI()
    if _ui == nil then
        return
    end
    local unionInfoMsg = UnionInfoData.GetData()
    local unionMsg = unionInfoMsg.guildInfo
    local selfMemberMsg = unionInfoMsg.memberInfo
    local charId = MainData.GetCharId()
    local targetIsLeader = targetMemberMsg.charId == unionMsg.leaderCharId
    local selfIsLeader = charId == unionMsg.leaderCharId

    _ui.nameLabel.text = targetMemberMsg.name
    _ui.iconSprite.spriteName = "level_" .. targetMemberMsg.position
    local canDepose = targetIsLeader and not selfIsLeader
    _ui.deposeButton.parent.localScale = Vector3(1, canDepose and 1 or 0, 1)

    local privilege = selfMemberMsg.privilege 
    local canChangeLevel = bit.band(privilege, GuildMsg_pb.PrivilegeType_ChangeMemberPostion) ~= 0
    local canKick = bit.band(privilege,  GuildMsg_pb.PrivilegeType_FireMember) ~= 0
    _ui.levelButton.parent.localScale = Vector3(1,  canChangeLevel and 1 or 0, 1)
    _ui.kickButton.parent.localScale = Vector3(1, canKick and 1 or 0, 1)
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("container/close btn")

    SetClickCallback(mask.gameObject, Hide)
    SetClickCallback(closeButton.gameObject, Hide)

    _ui.nameLabel = transform:Find("container/MemberName"):GetComponent("UILabel")
    _ui.iconSprite = transform:Find("container/MemberName/Icon"):GetComponent("UISprite")
    _ui.deposeButton = transform:Find("container/DeposeLeader/DeposeLeader")
    _ui.infoButton = transform:Find("container/Persinfobottum/PersonalInfo")
    _ui.letterButton = transform:Find("container/SendLetbuttom/SendLetter")
    _ui.trafficButton = transform:Find("container/TransResbuttom/TransRes")
    _ui.stationButton = transform:Find("container/Garsbuttom/Garrison")
    _ui.levelButton = transform:Find("container/Levelbuttom/SetLevel")
    _ui.kickButton = transform:Find("container/Expelbuttom/Evict")

    SetClickCallback(_ui.deposeButton.gameObject, function()
        MessageBox.Show(TextMgr:GetText(Text.common_ui1))
    end)
    SetClickCallback(_ui.infoButton.gameObject, function()
        OtherInfo.RequestShow(targetMemberMsg.charId)
    end)
    SetClickCallback(_ui.letterButton.gameObject, function()
        Mail.SimpleWriteTo(targetMemberMsg.name)
    end)
    SetClickCallback(_ui.trafficButton.gameObject, function()
        MessageBox.Show(TextMgr:GetText(Text.common_ui1))
    end)
    SetClickCallback(_ui.stationButton.gameObject, function()
        MessageBox.Show(TextMgr:GetText(Text.common_ui1))
    end)
    SetClickCallback(_ui.levelButton.gameObject, function()
        UnionSetLevel.Show(targetMemberMsg)
    end)
    SetClickCallback(_ui.deposeButton.gameObject, function()
        local deposeText = TextMgr:GetText(Text.union_recall)
        MessageBox.Show(System.String.Format(deposeText, UnionInfo.GetDeposeLeaderPrice()), function()
            local req = GuildMsg_pb.MsgDismissLeaderRequest()
            Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgDismissLeaderRequest, req, GuildMsg_pb.MsgDismissLeaderResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    UnionInfo.CloseAll()
                    MainCityUI.UpdateRewardData(msg.fresh)
                else
                    Global.ShowError(msg.code)
                end
            end, false)

        end,
        function()
        end)
    end)
    SetClickCallback(_ui.kickButton.gameObject, function()
        MessageBox.Show(String.Format(TextMgr:GetText(Text.Mail_expel_Desc1), targetMemberMsg.name), function()
            local req = GuildMsg_pb.MsgFireMemberRequest()
            req.charId = targetMemberMsg.charId
            Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgFireMemberRequest, req, GuildMsg_pb.MsgFireMemberResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    UnionInfoData.RequestData()
                    Hide()
                    UnionMemberLevel.KickMember(msg.charId)

                    --
                    local send = {}
                    send.curChanel = ChatMsg_pb.chanel_guild
                    send.spectext = ""
                    send.content = "union_playerout"..","..targetMemberMsg.name--System.String.Format(TextMgr:GetText("union_playerout") , targetMemberMsg.name)
                    send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
                    send.chatType = 4
                    send.senderguildname = UnionInfoData.GetData().guildInfo.banner
                    Chat.SendContent(send)
                else
                    Global.ShowError(msg.code)
                end
            end, false)
        end,
        function()
        end)
    end)
end

function Close()
    _ui = nil
end

function Show(memberMsg)
    targetMemberMsg = memberMsg
    Global.OpenUI(_M)
    LoadUI()
end

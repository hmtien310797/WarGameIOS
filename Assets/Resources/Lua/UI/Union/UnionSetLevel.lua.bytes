module("UnionSetLevel", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback

local _ui

local memberMsg
local currentRank

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function LoadUI()
    _ui.currentRankLabel.text = String.Format(TextMgr:GetText(Text.union_currentlevel), memberMsg.name, TextMgr:GetText(Text["union_member_level" .. memberMsg.position]))
    for k, v in pairs(_ui.rankList) do
        v.checkTransform.gameObject:SetActive(currentRank == k)
    end
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("SetLevel/close btn"):GetComponent("UIButton")

    SetClickCallback(mask.gameObject, Hide)
    SetClickCallback(closeButton.gameObject, Hide)
    _ui.currentRankLabel = transform:Find("SetLevel/container/BGup/CurrentLevel"):GetComponent("UILabel")

    _ui.rankList = {}
    for i = 1, 14 do
        local rank = {}
        local rankTransform = transform:Find(string.format("SetLevel/container/BGbottom/Rank%d", i))
        if rankTransform ~= nil then
            rank.transform = rankTransform
            SetClickCallback(rankTransform:Find("Sprite").gameObject, function()
                currentRank = i
                LoadUI()
            end)
            rank.checkTransform = rankTransform:Find("Sprite/Sprite")
            _ui.rankList[i] = rank
        end
    end

    local changeButton = transform:Find("SetLevel/container/BGbottom/Changelevelbottom")
    SetClickCallback(changeButton.gameObject, function()
        local req = GuildMsg_pb.MsgChangeMemberPositionRequest()
        req.charId = memberMsg.charId
        req.position = currentRank

        Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgChangeMemberPositionRequest, req, GuildMsg_pb.MsgChangeMemberPositionResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                Hide()
                UnionMemberLevel.SetMemberPosition(msg.charId, msg.position)
                UnionMemberLevel.SetMemberPrivilege(msg.charId, msg.privilege)
                UnionManagement.LoadUI()
            else
                Global.ShowError(msg.code)
            end
        end, false)
    end)
end

function Close()
    _ui = nil
end

function Show(msg)
    memberMsg = msg
    currentRank = msg.position
    Global.OpenUI(_M)
    LoadUI()
end

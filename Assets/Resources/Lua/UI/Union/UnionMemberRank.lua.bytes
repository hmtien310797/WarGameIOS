module("UnionMemberRank", package.seeall)

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
    UnionManagement.CloseAll()
    Hide()
end

local sortKeyList =
{
    {"pkValue", ">"},
    {"contributePoint", ">"},
    {"currentFieldNum", ">"},
    {"killArmyNum", ">"},
}

function LoadUI()
    local selfUnionInfoMsg = UnionInfoData.GetData()
    local selfMemberMsg = selfUnionInfoMsg.memberInfo
    local charId = MainData.GetCharId()

    for i, v in ipairs(_ui.rankList) do
        local sortKey = sortKeyList[i][1]
        local compare = sortKeyList[i][2]
        table.sort(_ui.memberMsg, function(v1, v2)
            if compare == ">" then
                return v1[sortKey] > v2[sortKey]
            else
                return v1[sortKey] < v2[sortKey]
            end
        end)
        for ii, vv in ipairs(_ui.memberMsg) do
            local memberTransform
            if ii > v.memberGrid.transform.childCount then
                memberTransform = NGUITools.AddChild(v.memberGrid.gameObject, _ui.memberPrefab).transform
            else
                memberTransform = v.memberGrid:GetChild(ii - 1)
            end
            memberTransform.gameObject:SetActive(true)
            memberTransform:Find("image").gameObject:SetActive(ii % 2 ~= 0)
            memberTransform:Find("info/rank"):GetComponent("UILabel").text = ii
            memberTransform:Find("info/membername"):GetComponent("UILabel").text = vv.name
            local rankValue = Global.FormatNumber(vv[sortKey])
            memberTransform:Find("info/Memberpower/powerinfo"):GetComponent("UILabel").text = rankValue
            local rankSprite = memberTransform:Find("info/rank123"):GetComponent("UISprite")
            rankSprite.gameObject:SetActive(ii <= 3)
            if ii <= 3 then
                rankSprite.spriteName = "rank_" .. ii
            end

            local viewTransform = memberTransform:Find("btn")
            viewTransform.gameObject:SetActive(vv.charId ~= charId)
            SetClickCallback(viewTransform.gameObject, function()
                OtherInfo.RequestShow(vv.charId)
            end)
            if vv.charId == charId then
                v.rankLabel.text = ii
                v.nameLabel.text = vv.name
                v.valueLabel.text = rankValue
                v.rankSprite.gameObject:SetActive(ii <= 3)
                if ii <= 3 then
                    v.rankSprite.spriteName = "rank_" .. ii
                end
            end
        end
        for ii = #_ui.memberMsg + 1, v.memberGrid.transform.childCount do
            v.memberGrid:GetChild(ii - 1).gameObject:SetActive(false)
        end
        v.memberGrid.repositionNow = true
    end
end

function Awake()
    _ui = {}
    _ui.memberPrefab = ResourceLibrary.GetUIPrefab("Union/listiem_unionMemberRank")
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/close btn")
    SetClickCallback(mask.gameObject, Hide)
    SetClickCallback(closeButton.gameObject, Hide)
    _ui.toggleList = {}
    local rankList = {}
    for i = 1, 4 do
        local uiToggle = transform:Find("Container/page" .. i):GetComponent("UIToggle")
        _ui.toggleList[i] = uiToggle
        local rank = {}
        local rankTransform = transform:Find("Container/content " .. i)
        rank.transform = rankTransform
        rank.rankLabel = rankTransform:Find("my/listiem_unionMemberRank/info/rank"):GetComponent("UILabel")
        rank.nameLabel = rankTransform:Find("my/listiem_unionMemberRank/info/membername"):GetComponent("UILabel")
        rank.valueLabel = rankTransform:Find("my/listiem_unionMemberRank/info/Memberpower/powerinfo"):GetComponent("UILabel")
        rank.memberGrid = rankTransform:Find("Scroll View/Grid"):GetComponent("UIGrid")
        rank.rankSprite = rankTransform:Find("my/listiem_unionMemberRank/info/rank123"):GetComponent("UISprite")
        rankList[i] = rank
    end

    _ui.rankList = rankList
end

function Close()
    _ui = nil
end

function Show(toggleIndex)
    toggleIndex = toggleIndex or 1
    local req = GuildMsg_pb.MsgGuildMemberPKValueRankRequest()
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildMemberPKValueRankRequest, req, GuildMsg_pb.MsgGuildMemberPKValueRankResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            Global.OpenUI(_M)
            for i, v in ipairs(_ui.toggleList) do
                v.value = i == toggleIndex
            end
            _ui.memberMsg = msg.members
            LoadUI()
        else
            Global.ShowError(msg.code)
        end
    end, false)
end


module("UnionMemberLevel", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback

local _ui

local memberListMsg
local selfUnionInfoMsg
local isSelfUnion
local showAbdicate
local showAppoint
local appointOfficialId
local showGuildId

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    UnionManagement.CloseAll()
    Hide()
end

function LoadUI()
    local charId = MainData.GetCharId()
    local selfPrivilege = 0
    local selfPosition
    if selfUnionInfoMsg ~= nil then
        local selfMemberMsg = selfUnionInfoMsg.memberInfo
        selfPrivilege = selfMemberMsg.privilege 
        selfPosition = selfMemberMsg.position
    end

    local function GetMemberMsgByPosition(position)
        for _, v in ipairs(memberListMsg) do
            if v.position == position then
                return v
            end
        end

        local memberMsg = GuildMsg_pb.GuildMember() 
        memberMsg.position = position

        return memberMsg
    end

    local function LoadMemberObject(member, memberTransform)
        member.transform = memberTransform
        member.faceTexture = memberTransform:Find("image/membeimage"):GetComponent("UITexture")
        member.faceMilitaryRankRoot =  memberTransform:Find("image/MilitaryRank")
        member.faceBg = memberTransform:Find("image/bg").gameObject
        member.powerObject = memberTransform:Find("info/Memberpower").gameObject
        member.nameLabel = memberTransform:Find("info/membername"):GetComponent("UILabel")
        member.powerLabel = memberTransform:Find("info/Memberpower/powerinfo"):GetComponent("UILabel")
        member.lastLabel = memberTransform:Find("Lastlogin unit"):GetComponent("UILabel")
        member.letterButton = memberTransform:Find("Letterbuttom"):GetComponent("UIButton")
        member.managerButton = memberTransform:Find("Managebuttom"):GetComponent("UIButton")
        member.abdicateButton = memberTransform:Find("Giveawaybuttom"):GetComponent("UIButton")
        member.appointButton = memberTransform:Find("Appointbuttom"):GetComponent("UIButton")
        member.killObject = memberTransform:Find("info/Container").gameObject
        member.killLabel = memberTransform:Find("info/Container/powerinfo"):GetComponent("UILabel")
        member.leader = memberTransform:Find("leader"):GetComponent("UISprite")
        member.applyButton = memberTransform:Find("ApplyOfficial"):GetComponent("UIButton")
        member.vacancyObject = memberTransform:Find("info/vacancy").gameObject
    end

    local function LoadMember(member, memberMsg)
        for i = 1, 14 do
            local rankTransform = member.transform:Find(string.format("info/membername/rank%d", i))
            if rankTransform ~= nil then
                rankTransform.gameObject:SetActive(i == memberMsg.position)
            end
        end
        local validMember = memberMsg.charId ~= 0
        member.faceBg:SetActive(validMember)
        member.letterButton.gameObject:SetActive(validMember and not isSelfUnion)
        member.managerButton.gameObject:SetActive(validMember and isSelfUnion and not showAbdicate and not showAppoint and memberMsg.charId ~= charId)
        member.abdicateButton.gameObject:SetActive(validMember and showAbdicate and not showAppoint and memberMsg.charId ~= charId)
        member.appointButton.gameObject:SetActive(not showAbdicate and showAppoint and not UnionOfficialData.HasAppointed(memberMsg.charId))
        member.faceTexture.mainTexture = ResourceLibrary:GetIcon("Icon/head/", memberMsg.face)
        GOV_Util.SetFaceUI(member.faceMilitaryRankRoot,validMember and memberMsg.militaryRankId or 0)	
        member.nameLabel.text = memberMsg.name
        member.powerObject:SetActive(validMember)
        member.powerLabel.text = Global.FormatNumber(memberMsg.pkValue)
        member.lastLabel.gameObject:SetActive(validMember and isSelfUnion and bit.band(selfPrivilege,  GuildMsg_pb.PrivilegeType_SeeMemberOfflineTime) ~= 0)
        member.lastLabel.text = Global.GetLastOnlineText(memberMsg.lastOnlineTime)
        member.killObject:SetActive(validMember)
        member.killLabel.text = memberMsg.killArmyNum
        member.leader.gameObject:SetActive(memberMsg.position == 5)
        member.vacancyObject:SetActive(not validMember)

        SetClickCallback(member.faceBg, function()
            OtherInfo.RequestShow(memberMsg.charId)
        end)
        SetClickCallback(member.letterButton.gameObject, function()
            Mail.SimpleWriteTo(memberMsg.name)
        end)
        SetClickCallback(member.managerButton.gameObject, function()
            UnionManagement.Show(memberMsg)
        end)
        SetClickCallback(member.abdicateButton.gameObject, function()
            local abdicateText = TextMgr:GetText(Text.union_giveaway_confirm)
            MessageBox.Show(System.String.Format(abdicateText, memberMsg.name), function()
                local req = GuildMsg_pb.MsgTransferLeaderRequest()
                req.charId = memberMsg.charId
                Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgTransferLeaderRequest, req, GuildMsg_pb.MsgTransferLeaderResponse, function(msg)
                    if msg.code == ReturnCode_pb.Code_OK then
                        Hide()
                        UnionInfoData.RequestData(function()
                            FloatText.Show(TextMgr:GetText(Text.union_giveaway_success))
                        end)
                    else
                        Global.ShowError(msg.code)
                    end
                end, false) 
            end,
            function()
            end)
        end)

        SetClickCallback(member.appointButton.gameObject, function()
            local req = GuildMsg_pb.MsgGuildAppointOfficialRequest()
            req.charId = memberMsg.charId
            req.officialId = appointOfficialId
            Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildAppointOfficialRequest, req, GuildMsg_pb.MsgGuildAppointOfficialResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    Hide()
                    UnionOfficialData.UpdateData(msg.officialList)
                    TileInfo.Hide()
                else
                    Global.ShowError(msg.code)
                end
            end, false) 
        end)

        member.applyButton.gameObject:SetActive(memberMsg.charId == 0 and selfPosition ~= 0 and selfPosition ~= 5 and selfPosition < 11 and UnionInfoData.GetGuildId() == showGuildId)
        SetClickCallback(member.applyButton.gameObject, function()
            local req = GuildMsg_pb.MsgApplyGuildPositionRequest()
            req.position = memberMsg.position
            Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgApplyGuildPositionRequest, req, GuildMsg_pb.MsgApplyGuildPositionResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                else
                    Global.ShowError(msg.code)
                end
            end, false) 
        end)

    end

    local memberIndex = 1
    do
        if memberIndex > _ui.rankGrid.transform.childCount then
            memberTransform = NGUITools.AddChild(_ui.rankGrid.gameObject, _ui.memberPrefab).transform
        else
            memberTransform = _ui.rankGrid.transform:GetChild(memberIndex - 1)
        end
        local member = {}
        LoadMemberObject(member, memberTransform)
        local memberMsg = GetMemberMsgByPosition(5)
        LoadMember(member, memberMsg)
        memberIndex = memberIndex + 1
    end

    do
        for i = 14, 11, -1 do
            if memberIndex > _ui.rankGrid.transform.childCount then
                memberTransform = NGUITools.AddChild(_ui.rankGrid.gameObject, _ui.memberPrefab).transform
            else
                memberTransform = _ui.rankGrid.transform:GetChild(memberIndex - 1)
            end
            local member = {}
            LoadMemberObject(member, memberTransform)
            local memberMsg = GetMemberMsgByPosition(i)
            LoadMember(member, memberMsg)
            memberIndex = memberIndex + 1
        end
    end

    local civilianList = {}
    for _, v in ipairs(memberListMsg) do
        if v.position ~= 5 and v.position < 11 then
            table.insert(civilianList, v)
        end
    end

    table.sort(civilianList, function(v1, v2)
        return v1.position > v2.position
    end)

    for i, v in ipairs(civilianList) do
        local memberTransform
        if memberIndex > _ui.rankGrid.transform.childCount then
            memberTransform = NGUITools.AddChild(_ui.rankGrid.gameObject, _ui.memberPrefab).transform
        else
            memberTransform = _ui.rankGrid.transform:GetChild(memberIndex - 1)
        end
        memberTransform.gameObject:SetActive(true)
        local member = {}
        LoadMemberObject(member, memberTransform)
        LoadMember(member, v)
        memberIndex = memberIndex + 1
    end

    for i = memberIndex, _ui.rankGrid.transform.childCount do
        _ui.rankGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end
    _ui.rankGrid.repositionNow = true
    _ui.charId = nil
end

function Awake()
    _ui = {}
    if _ui.memberPrefab == nil then
        _ui.memberPrefab = ResourceLibrary.GetUIPrefab("Union/UnionMemberinfo")
    end
    _ui.halfMemberHeight = _ui.memberPrefab:GetComponent("UIWidget").height * 0.5
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/close btn")
    SetClickCallback(mask.gameObject, Hide)
    SetClickCallback(closeButton.gameObject, Hide)

    _ui.authorityButton = transform:Find("Container/authority btn"):GetComponent("UIButton")
    SetClickCallback(_ui.authorityButton.gameObject, function()
        UnionAuthority.Show()
    end)
    _ui.rankPanel = transform:Find("Scroll View"):GetComponent("UIPanel")
    _ui.rankScrollView = transform:Find("Scroll View"):GetComponent("UIScrollView")
    _ui.rankGrid = transform:Find("Scroll View/Grid"):GetComponent("UIGrid")
end

function Start()
    LoadUI()
end

function Close()
    _ui = nil
end

function SetMemberPrivilege(charId, privilege)
    for _, v in ipairs(memberListMsg) do
        if v.charId == charId then
            v.privilege = privilege
            LoadUI()
            break
        end
    end
end

function SetMemberPosition(charId, position)
    for _, v in ipairs(memberListMsg) do
        if v.charId == charId then
            v.position = position
            LoadUI()
            break
        end
    end
end

function KickMember(charId)
    for i, v in ipairs(memberListMsg) do
        if v.charId == charId then
            memberListMsg:remove(i)
            LoadUI()
            break
        end
    end
end

function Show(guildId, abdicate, appoint, officialId, charId)
    selfUnionInfoMsg = UnionInfoData.GetData()
    isSelfUnion = selfUnionInfoMsg ~= nil and selfUnionInfoMsg.guildInfo.guildId == guildId
    showAbdicate = abdicate
    showAppoint = appoint
	showGuildId = guildId
    appointOfficialId = officialId
    local req = GuildMsg_pb.MsgGuildMemberListRequest()
    req.guildId = guildId
	--print(guildId , charId , MainData.GetCharId() , UnionInfoData.GetGuildId())
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildMemberListRequest, req, GuildMsg_pb.MsgGuildMemberListResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            memberListMsg = msg.members
            Global.OpenUI(_M)
            _ui.charId = charId
        else
            Global.ShowError(msg.code)
        end
    end, false)
end

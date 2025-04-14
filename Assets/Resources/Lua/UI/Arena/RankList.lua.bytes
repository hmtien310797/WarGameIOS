module("RankList", package.seeall)
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

function LoadRankObject(rank, rankTransform)
    rank.transform = rankTransform
    rank.gameObject = rankTransform.gameObject
    rank.rankLabel = rankTransform:Find("rank_info"):GetComponent("UILabel")
    rank.nationTexture = rankTransform:Find("rank_info/flag"):GetComponent("UITexture")
    rank.levelLabel = rankTransform:Find("rank_info/level"):GetComponent("UILabel")
    rank.nameLabel = rankTransform:Find("rank_info/level/name"):GetComponent("UILabel")
    rank.powerLabel = rankTransform:Find("rank_info/combat/number"):GetComponent("UILabel")
    rank.faceObject = rankTransform:Find("head").gameObject
    rank.vipSprite = rankTransform:Find("head"):GetComponent("UISprite")
    local vipTransform = rankTransform:Find("head/vipicon/num")
    if vipTransform ~= nil then
        rank.vipLabel = vipTransform:GetComponent("UILabel")
    end
    rank.faceTexture = rankTransform:Find("head/avatar"):GetComponent("UITexture")
    rank.rankTexture = rankTransform:Find("head/Military"):GetComponent("UITexture")
end

function LoadRank(rank, rankMsg, myRank)
    if rank.rankLabel ~= nil then
        if rankMsg.rank == 0 then
            rank.rankLabel.text = TextMgr:GetText(Text.ui_Arena_11)
        else
            rank.rankLabel.text = rankMsg.rank
        end
    end
    rank.nationTexture.mainTexture = UIUtil.GetNationalFlagTexture(rankMsg.nation)
    rank.levelLabel.text = "Lv." .. rankMsg.level
    if rankMsg.charid == 0 then
        rank.nameLabel.text = TextMgr:GetText(rankMsg.charname)
        rank.faceTexture.mainTexture = ResourceLibrary:GetIcon("Icon/head/", "666")
    else
        rank.nameLabel.text = rankMsg.charname
        rank.faceTexture.mainTexture = ResourceLibrary:GetIcon("Icon/head/", rankMsg.face)
    end
    if rank.vipSprite ~= nil then
        rank.vipSprite.spriteName = tableData_tVip.data[rankMsg.viplevel].headBox
    end
    if rank.vipLabel ~= nil then
        rank.vipLabel.text = rankMsg.viplevel
    end
    rank.powerLabel.text = rankMsg.pkval
    local militaryRankData = tableData_tMilitaryRank.data[rankMsg.militaryrankid] 
    rank.rankTexture.mainTexture = ResourceLibrary:GetIcon("Icon/MilitaryRank/", militaryRankData.Icon)

    SetClickCallback(rank.faceObject, function(go)
        if myRank ~= rankMsg.rank then
            if rankMsg.charid == 0 then
                Npcinfo.Show(rankMsg.rank)
            else
                OtherInfo.RequestShow(rankMsg.charid)
            end
        end
    end)
end

function LoadUI()
    local myRank = _ui.rankListMsg.myrank
    for i = 1, 3 do
        LoadRank(_ui.topRankList[i], _ui.rankListMsg.rankuser[i], myRank)
    end

    local myRank = _ui.rankListMsg.myrank
    local in100 = myRank > 0 and myRank <= 100
    _ui.selfRank.gameObject:SetActive(not in100)

    if not in100 then
        local arenaInfoMsg = ArenaInfoData.GetData().arenaInfo
        local rankMsg = BattleMsg_pb.ArenaEnemyInfo()
        rankMsg.rank = myRank
        rankMsg.viplevel = MainData.GetVipLevel()
        rankMsg.nation = MainData.GetNationality()
        rankMsg.level = MainData.GetLevel()
        rankMsg.charid = MainData.GetCharId()
        rankMsg.charname = MainData.GetCharName()
        rankMsg.pkval = arenaInfoMsg.pkval
        rankMsg.face = MainData.GetFace()
        rankMsg.militaryrankid = MainData.GetMilitaryRankID()
        LoadRank(_ui.selfRank, rankMsg, myRank)
    end
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/bg_frane/bg_title/btn_close")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)

    local topRankList = {}
    for i = 1, 3 do
        local rank = {}
        local rankTransform = transform:Find("Container/bg_frane/bg_top/bg_top" .. i)
        LoadRankObject(rank, rankTransform)
        topRankList[i] = rank
    end
    _ui.topRankList = topRankList

    _ui.rankScrollView = transform:Find("Container/bg_frane/bg_mid/Container/Scroll View"):GetComponent("UIScrollView")
    _ui.rankWrapContent = transform:Find("Container/bg_frane/bg_mid/Container/Scroll View/Grid"):GetComponent("UIWrapContent")
    _ui.itemSize = _ui.rankWrapContent.itemSize

    local selfRankTransform = transform:Find("Container/bg_frane/bg_bottom")
    _ui.selfRank = {}
    LoadRankObject(_ui.selfRank, selfRankTransform)

    _ui.rankPrefab = transform:Find("Container/bg_frane/list_playerinfo").gameObject
end

local function UpdateRankList(go, wrapIndex, realIndex)
    local myRank = _ui.rankListMsg.myrank
    local rankIndex = -realIndex
    local rank = {}
    LoadRankObject(rank, go.transform)
    rank.selfObject = go.transform:Find("bg_self").gameObject
    local rankMsg = _ui.rankListMsg.rankuser[rankIndex + 4]
    LoadRank(rank, rankMsg, myRank)
    local myRank = _ui.rankListMsg.myrank
    rank.selfObject:SetActive(rankIndex + 4 == myRank)
end

function Start()
    local rankPanel = RankList.transform:Find("Container/bg_frane/bg_mid/Container/Scroll View"):GetComponent("UIPanel")
    local defaultClip = rankPanel.baseClipRegion
    local myRank = _ui.rankListMsg.myrank
    local in100 = myRank > 0 and myRank <= 100
    if in100 then
        rankPanel.baseClipRegion = Vector4(defaultClip.x, defaultClip.y - _ui.itemSize * 0.5, defaultClip.z, defaultClip.w + _ui.itemSize)
    end
    local pageSize = in100 and 6 or 5
    _ui.pageSize = pageSize

    _ui.rankWrapContent.onInitializeItem = UpdateRankList
    local rankList = {}
    for i = 1, pageSize do
        local rankTransform = NGUITools.AddChild(_ui.rankWrapContent.gameObject, _ui.rankPrefab).transform
        local rank = {}
        LoadRankObject(rank, rankTransform)
        rank.selfObject = rankTransform:Find("bg_self").gameObject
        rankList[i] = rank
    end
    _ui.rankList = rankList
    _ui.rankWrapContent.minIndex = -96
    _ui.rankScrollView:ResetPosition()
    _ui.rankWrapContent:ResetToStart()
    LoadUI()
    if myRank > 3 and in100 then
        coroutine.start(function()
            coroutine.wait(0.1)
            if _ui == nil then
                return
            end
            _ui.rankScrollView:Scroll(math.max(0, -1.3264236486599 * (myRank - 6)))
        end)
    end
end

function Close()
    _ui = nil
end

function Show()
    local req = BattleMsg_pb.MsgArenaRankListRequest()
    req.srank = 1
    req.count = 100
    Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgArenaRankListRequest, req, BattleMsg_pb.MsgArenaRankListResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            Global.OpenUI(_M)
            _ui.rankListMsg = msg
            print("my rank:", msg.myrank)
        else
            Global.ShowError(msg.code)
        end
    end, false)
end

module("AllianceUnionSelect", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameObject = UnityEngine.GameObject

local _ui, ShowMissionReward

local memberListMsg
local selfUnionInfoMsg
local onlyShow, ShareReward, closeCallback

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
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

function LoadUI()
    local charId = MainData.GetCharId()
    local selfPrivilege = 0
    local selfPosition
    if selfUnionInfoMsg ~= nil then
        local selfMemberMsg = selfUnionInfoMsg.memberInfo
        selfPrivilege = selfMemberMsg.privilege 
        selfPosition = selfMemberMsg.position
    end

    local function CheckMax()
        local total = 0
        for i, v in pairs(_ui.checklist) do
            if v then
                total = total + 1
            end
        end
        if ShareReward == nil then
            return total < tonumber(_ui.maxMember)
        end
        if ShareReward ~= nil then
            return total < tonumber(tableData_tGuildMobaGlobal.data[113].Value)
        end
    end

    local function UpdateMemberText()
        _ui.idlist = {}
        local total = 0
        for i, v in pairs(_ui.checklist) do
            if v then
                table.insert(_ui.idlist, i)
                total = total + 1
            end
        end
        if ShareReward == nil then
            _ui.membertext.text = String.Format(TextMgr:GetText("ui_unionwar_16"), total, _ui.maxMember)
        end
        if ShareReward ~= nil then
            _ui.membertext.text = String.Format(TextMgr:GetText("ui_unionwar_17"), total, tableData_tGuildMobaGlobal.data[113].Value)
        end
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
        member.killObject = memberTransform:Find("info/Container").gameObject
        member.killLabel = memberTransform:Find("info/Container/powerinfo"):GetComponent("UILabel")
        member.leader = memberTransform:Find("leader"):GetComponent("UISprite")
        member.vacancyObject = memberTransform:Find("info/vacancy").gameObject
        member.iconreward = memberTransform:Find("icon_reward").gameObject
        member.select = memberTransform:Find("select").gameObject
        member.confirm = memberTransform:Find("select/confirm").gameObject
        member.reward_done = memberTransform:Find("reward_done"):GetComponent("UILabel")
    end

    local function LoadMember(member, memberMsg)
        for i = 1, 14 do
            local rankTransform = member.transform:Find(string.format("info/membername/rank%d", i))
            if rankTransform ~= nil then
                rankTransform.gameObject:SetActive(i == memberMsg.position)
            end
        end
        local validMember = memberMsg.charId ~= 0
        member.faceTexture.mainTexture = ResourceLibrary:GetIcon("Icon/head/", memberMsg.face)
        GOV_Util.SetFaceUI(member.faceMilitaryRankRoot,validMember and memberMsg.militaryRankId or 0)	
        member.nameLabel.text = memberMsg.name
        member.powerLabel.text = Global.FormatNumber(memberMsg.pkValue)
        member.lastLabel.text = Global.GetLastOnlineText(memberMsg.lastOnlineTime)
        member.killLabel.text = memberMsg.killArmyNum
        member.iconreward:SetActive(ShareReward ~= nil and _ui.checklist[memberMsg.charId] == true)
        member.confirm:SetActive(_ui.checklist[memberMsg.charId] == true)
        SetClickCallback(member.iconreward, function()
            ShowMissionReward(ShareReward)
        end)
        if ShareReward ~= nil then
            member.select:SetActive(not UnionMobaActivityData.CheckRewarded(memberMsg.charId))
            member.reward_done.gameObject:SetActive(UnionMobaActivityData.CheckRewarded(memberMsg.charId))
            member.reward_done.text = TextMgr:GetText("ui_unionwar_40")
            _ui.checklist[memberMsg.charId] = UnionMobaActivityData.CheckRewarded(memberMsg.charId)
        else
            if memberMsg.joinTime > _ui.baomingshijian then
                member.select:SetActive(false)
                member.reward_done.gameObject:SetActive(true)
                member.reward_done.text = TextMgr:GetText("ui_unionwar_45")
            else
                member.select:SetActive(true)
                member.reward_done.gameObject:SetActive(false)
            end
        end
        if not onlyShow and _ui.hasorder and (memberMsg.position ~= 5 or ShareReward ~= nil) then
            SetClickCallback(member.select, function()
                if not CheckMax() and not _ui.checklist[memberMsg.charId] then
                    return
                end
                _ui.checklist[memberMsg.charId] = not _ui.checklist[memberMsg.charId]
                member.iconreward:SetActive(ShareReward ~= nil and _ui.checklist[memberMsg.charId] == true)
                member.confirm:SetActive(_ui.checklist[memberMsg.charId] == true)
                UpdateMemberText()
            end)
        end
        SetClickCallback(member.faceBg, function()
            OtherInfo.RequestShow(memberMsg.charId)
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
        _ui.hasorder = charId == memberMsg.charId
        if ShareReward == nil then
            _ui.checklist[memberMsg.charId] = true
        end
        LoadMember(member, memberMsg)
        memberIndex = memberIndex + 1
    end

    local civilianList = {}
    for _, v in ipairs(memberListMsg) do
        if v.position ~= 5 then
            table.insert(civilianList, v)
        end
    end
    _ui.maxMember = math.min(#memberListMsg, 20)

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
        if ShareReward == nil then
            _ui.checklist[v.charId] = UnionMobaActivityData.CheckSelect(v.charId)
        end
        LoadMember(member, v)
        memberIndex = memberIndex + 1
    end

    for i = memberIndex, _ui.rankGrid.transform.childCount do
        _ui.rankGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end
    _ui.rankGrid.repositionNow = true
    UpdateMemberText()
    _ui.rankScrollView:MoveRelative(Vector3(0,-5,0))
end

function Awake()
    _ui = {}
    _ui.baomingshijian = UnionMobaActivityData.GetData().matchtime
    _ui.checklist = {}
    if _ui.memberPrefab == nil then
        _ui.memberPrefab = transform:Find("PlayInfo").gameObject
    end
    _ui.halfMemberHeight = _ui.memberPrefab:GetComponent("UIWidget").height * 0.5
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/close btn")
    SetClickCallback(mask.gameObject, Hide)
    SetClickCallback(closeButton.gameObject, Hide)

    _ui.authorityButton = transform:Find("Container/authority btn"):GetComponent("UIButton")
    SetClickCallback(_ui.authorityButton.gameObject, function()
        if ShareReward ~= nil then
            local rewardednum = 0
            for i, v in ipairs(_ui.idlist) do
                if UnionMobaActivityData.CheckRewarded(v) then
                    rewardednum = rewardednum + 1
                end
            end
            print(rewardednum == tonumber(tableData_tGuildMobaGlobal.data[113].Value), rewardednum, #memberListMsg, rewardednum == 0)
            if rewardednum == tonumber(tableData_tGuildMobaGlobal.data[113].Value) or rewardednum == #memberListMsg or #_ui.idlist == 0 then
                Hide()
                return
            end
        end
        if closeCallback ~= nil then
            closeCallback(_ui.idlist)
        end
        Hide()
    end)
    _ui.rankPanel = transform:Find("Scroll View"):GetComponent("UIPanel")
    _ui.rankScrollView = transform:Find("Scroll View"):GetComponent("UIScrollView")
    _ui.rankGrid = transform:Find("Scroll View/Grid"):GetComponent("UIGrid")

    _ui.membertext = transform:Find("Container/text"):GetComponent("UILabel")
    --_ui.membertext.gameObject:SetActive(not onlyShow and ShareReward == nil)
    _ui.icon_reward = transform:Find("Container/icon_reward").gameObject
    _ui.icon_reward:SetActive(ShareReward ~= nil)

    SetClickCallback(_ui.icon_reward, function()
        ShowMissionReward(ShareReward)
    end)
    _ui.authorityButton.gameObject:SetActive(not onlyShow)

    _ui.rewardshow = ResourceLibrary.GetUIPrefab("ActivityStage/GrowRewards")

    _ui.itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    _ui.heroPrefab = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()
    LoadUI()
end

function Close()
    _ui = nil
    ShareReward = nil
    closeCallback = nil
    onlyShow = nil
    
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Show(_onlyShow, _ShareReward, _callback)
    onlyShow = _onlyShow
    ShareReward = _ShareReward
    closeCallback = _callback
    local req = GuildMsg_pb.MsgGuildMemberListRequest()
    req.guildId = UnionInfoData.GetData().guildInfo.guildId

    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildMemberListRequest, req, GuildMsg_pb.MsgGuildMemberListResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            memberListMsg = msg.members
            Global.OpenUI(_M)
        else
            Global.ShowError(msg.code)
        end
    end, false)
end


ShowMissionReward = function(showReward)
	local showgo = NGUITools.AddChild(GUIMgr.UIRoot.gameObject, _ui.rewardshow)
	local showtrans = showgo.transform
	local _show = {}
	_show.bg = showtrans:Find("Container")
	_show.listGrid = showtrans:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	_show.getButton = showtrans:Find("Container/bg_frane/button"):GetComponent("UIButton")
	_show.getLabel = showtrans:Find("Container/bg_frane/button/Label"):GetComponent("UILabel")
	_show.growHint = showtrans:Find("Container/bg_frane/bg_hint").gameObject
	_show.dailyHint = showtrans:Find("Container/bg_frane/bg_dailymission").gameObject
	_show.dailyHintLabel = showtrans:Find("Container/bg_frane/bg_dailymission/text"):GetComponent("UILabel")
    _show.dailyHintLabel.text = ""
    _show.getLabel.text = TextMgr:GetText("common_hint1")
    _show.getButton.gameObject:SetActive(true)
	for i, v in ipairs(showReward.heros) do
        local heroData = TableMgr:GetHeroData(v.id)
        local hero = NGUITools.AddChild(_show.listGrid.gameObject, _ui.heroPrefab).transform
        hero.localScale = Vector3(0.6, 0.6, 1) * 0.9
        hero:Find("level text").gameObject:SetActive(false)
        hero:Find("name text").gameObject:SetActive(false)
        hero:Find("bg_skill").gameObject:SetActive(false)
        hero:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
        hero:Find("head icon/outline"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
        local star = hero:Find("star"):GetComponent("UISprite")
        if star ~= nil then
            star.width = v.star * star.height
        end
        UIUtil.SetClickCallback(reward.transform.gameObject, function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                Tooltip.ShowItemTip({name = TextMgr:GetText(heroData.nameLabel), text = TextMgr:GetText(heroData.description)})
            end
        end)
    end
    for i, v in ipairs(showReward.items) do
        local itemdata = TableMgr:GetItemData(v.id)
        local item = NGUITools.AddChild(_show.listGrid.gameObject, _ui.itemPrefab).transform
        local reward = {}
        UIUtil.LoadItemObject(reward, item)
        UIUtil.LoadItem(reward, itemdata, v.num)
        UIUtil.SetClickCallback(reward.transform.gameObject, function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
            end
        end)
    end
    for i, v in ipairs(showReward.armys) do
        local reward = v
        local soldierData = TableMgr:GetBarrackData(reward.id, reward.level)
        local itemprefab = NGUITools.AddChild(_show.listGrid.gameObject, _ui.itemPrefab).transform
        itemprefab.gameObject:SetActive(true)
        itemprefab:GetComponent("UISprite").spriteName = "bg_item" .. (1 + reward.level)
        itemprefab:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", soldierData.SoldierIcon)
        itemprefab:Find("have"):GetComponent("UILabel").text = reward.num
        itemprefab:Find("num").gameObject:SetActive(false)
        UIUtil.SetClickCallback(itemprefab.gameObject, function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                Tooltip.ShowItemTip({name = TextMgr:GetText(soldierData.SoldierName), text = TextMgr:GetText(soldierData.SoldierDes)})
            end
        end)
    end
	_show.listGrid:Reposition()
	SetClickCallback(_show.bg.gameObject, function()
		GameObject.Destroy(showgo)
		_show = nil
	end)
	SetClickCallback(_show.getButton.gameObject, function()
		GameObject.Destroy(showgo)
		_show = nil
	end)
	showgo:SetActive(true)
	GUIMgr:BringForward(showgo)
end
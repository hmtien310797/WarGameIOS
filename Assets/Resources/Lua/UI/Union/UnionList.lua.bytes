module("UnionList", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback

local badgeId
local searchLanguageId
local createLanguageId

local _ui

local searchListMsg

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    UnionPubinfo.CloseAll()
    UnionBadge.CloseAll()
    UnionLanguage.CloseAll()
    Hide()
end

function SetSearchLanguage(id)
    searchLanguageId = id
    if _ui ~= nil and _ui.searchPage ~= nil and _ui.searchPage.languageLabel ~= nil then
        _ui.searchPage.languageLabel.text = UnionLanguage.GetLanguageText(searchLanguageId)
    end
end

local function SetCreateLanguage(id)
    createLanguageId = id
    _ui.createPage.languageLabel.text = UnionLanguage.GetLanguageText(createLanguageId)
end

function LoadUnionObject(union, unionTransform)
    local badge = {}
    union.transform = unionTransform
    union.gameObject = unionTransform.gameObject
    union.viewButton = unionTransform:Find("check btn")
    local badgeTransform = unionTransform:Find("badge bg")
    UnionBadge.LoadBadgeObject(badge, badgeTransform)
    union.badge = badge
    union.nameLabel = unionTransform:Find("info widget/union name"):GetComponent("UILabel")
    union.powerLabel = unionTransform:Find("info widget/combat/num"):GetComponent("UILabel")
    union.levelLabel = unionTransform:Find("info widget/chest lv/num"):GetComponent("UILabel")
    union.memberLabel = unionTransform:Find("info widget/people/num"):GetComponent("UILabel")
    union.languageLabel = unionTransform:Find("info widget/language/num"):GetComponent("UILabel")
    union.joinButton = unionTransform:Find("btn wtdget/join btn"):GetComponent("UIButton")
    union.applyButton = unionTransform:Find("btn wtdget/apply btn"):GetComponent("UIButton")
    union.cancelButton = unionTransform:Find("btn wtdget/cancel btn"):GetComponent("UIButton")
    local power = unionTransform:Find("btn wtdget/need_combat")
    if power ~= nil then
        union.requiredPowerLabel = power:GetComponent("UILabel")
    end

    local unionCard = unionTransform:Find("info widget/unioncard/num")
    local unionCardRoot = unionTransform:Find("info widget/unioncard")
    if unionCardRoot ~= nil then
        unionCardRoot.gameObject:SetActive(UnionCardData.IsAvailable())
    end
    if unionCard ~= nil then
        union.unionCardLabel = unionCard:GetComponent("UILabel")
    end
    -- 注意
    -- 这个函数也在炮塔 里面使用 所以在find的时候请先判空
    -- 参考如上方式
end

UpdateSearchUnion = nil
local function RequestUnionInfo(guildId)
    local req = GuildMsg_pb.MsgGuildInfoRequest()
    req.guildId = guildId

    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildInfoRequest, req, GuildMsg_pb.MsgGuildInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            UnionList.UpdateSearchUnion(msg.guildInfo)
        end
    end, false)
end

function LoadUnion(union, unionMsg, hasApplied)
    UnionBadge.LoadBadgeById(union.badge, unionMsg.badge)

    union.nameLabel.text = string.format("[%s]%s", unionMsg.banner, unionMsg.name)
    union.powerLabel.text = Global.FormatNumber(unionMsg.power)
    union.levelLabel.text = unionMsg.giftLevel
    union.memberLabel.text = string.format("%d/%d", unionMsg.memberCount, unionMsg.memberMax)
    union.languageLabel.text = UnionLanguage.GetLanguageText(unionMsg.lang)

    union.joinButton.gameObject:SetActive(unionMsg.recruitType == GuildMsg_pb.RecruitType_public)
    union.applyButton.gameObject:SetActive(unionMsg.recruitType == GuildMsg_pb.RecruitType_apply and not hasApplied)
    union.cancelButton.gameObject:SetActive(unionMsg.recruitType == GuildMsg_pb.RecruitType_apply and hasApplied)
    if union.requiredPowerLabel ~= nil then
        union.requiredPowerLabel.text = System.String.Format(TextMgr:GetText(Text.need_combat), unionMsg.pkValueLimit)
    end

    if union.unionCardLabel ~= nil then
        union.unionCardLabel.text = unionMsg.guildMonthBuyed and string.format("%s/%s" , unionMsg.guildMonthDayMax - unionMsg.guildMonthDay , unionMsg.guildMonthDayMax) or TextMgr:GetText("ui_worldmap_45")
    end

    SetClickCallback(union.viewButton.gameObject, function()
        UnionPubinfo.Show(unionMsg)
    end)

    SetClickCallback(union.applyButton.gameObject, function()
        local req = GuildMsg_pb.MsgApplyGuildRequest()
        req.guildId = unionMsg.guildId

        Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgApplyGuildRequest, req, GuildMsg_pb.MsgApplyGuildResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                SelfApplyData.RequestData()
                FloatText.Show(TextMgr:GetText(Text.Mail_join_request_Title))
            else
                Global.ShowError(msg.code)
                RequestUnionInfo(unionMsg.guildId)
            end
        end, false)
    end)
    SetClickCallback(union.cancelButton.gameObject, function()
        local req = GuildMsg_pb.MsgCancelApplyGuildRequest()
        req.guildId = unionMsg.guildId

        Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgCancelApplyGuildRequest, req, GuildMsg_pb.MsgCancelApplyGuildResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                SelfApplyData.RequestData()
                if _ui.applyPage.pageToggle.value then
                    SelfApplyData.RemoveApply(msg.guildId)
                end
            else
                Global.ShowError(msg.code)
                RequestUnionInfo(unionMsg.guildId)
            end
        end, false)
    end)
    SetClickCallback(union.joinButton.gameObject, function()
        local req = GuildMsg_pb.MsgJoinGuildRequest()
        req.guildId = unionMsg.guildId
        Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgJoinGuildRequest, req, GuildMsg_pb.MsgJoinGuildResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                FloatText.Show(TextMgr:GetText(Text.Mail_join_Title))
                --SelfApplyData.RequestData()
                UnionBuildingData.RequestData()
				SelfApplyData.ClearApply()--自身已有联盟
				
                UnionInfoData.UpdateData(msg)
                UnionBuildingData.CheckNotice()
				UnionCardData.RequestData(0)
                JoinUnion.CloseAll()
				if not msg.isExile then
					--UnionGuide.Show(msg.leaderInfo , UnionGuide.ShowPage.UnionPage)
				end
				
                --UnionInfo.Show()
				GUIMgr:SendDataReport("efun", "join_unions")
				local send = {}
				send.curChanel = ChatMsg_pb.chanel_guild
				send.spectext = ""
				send.content = "TipsNotice_Union_Desc6"..","..MainData.GetCharName()--System.String.Format(TextMgr:GetText("TipsNotice_Union_Desc6") ,MainData.GetCharName() ) 
				send.languageCode = TextMgr:GetCurrentLanguageID()
				send.chatType = 4
				send.senderguildname = UnionInfoData.GetData().guildInfo.banner
				Chat.SendContent(send)

                --拉取联盟留言
                UnionMessageData.RequestUnionMessageChatInfo(unionMsg.guildId, function() 
                    UnityEngine.PlayerPrefs.SetInt("UnionMessage", ChatData.GetChatDataLength(ChatMsg_pb.chanel_guild_mboard))
                end)

                MainCityUI.HideAllianceInvites()
            else
                Global.ShowError(msg.code)
                RequestUnionInfo(unionMsg.guildId)
            end
        end, false)
    end)
end

function LoadSearchPage(reset,customCallBack)
    local unionList = _ui.searchPage.unionList
    _ui.searchPage.languageLabel.text = UnionLanguage.GetLanguageText(searchLanguageId)
    if searchListMsg ~= nil then
        for i, v in ipairs(searchListMsg.guildInfos) do
            local unionMsg = v
            local union = unionList[i]
            union.gameObject:SetActive(true)
            local hasApplied = SelfApplyData.HasApplied(v.guildId)
            LoadUnion(union, unionMsg, hasApplied)
            if customCallBack ~= nil then
                customCallBack(union, unionMsg)
            end
        end
    end
    local index = searchListMsg ~= nil and #searchListMsg.guildInfos + 1 or 1
    for i = index, _ui.searchPage.pageSize do
        unionList[i].gameObject:SetActive(false)
    end
    _ui.searchPage.listGrid:Reposition()
    if reset then
        _ui.searchPage.scrollView:ResetPosition()
    end
end

UpdateSearchUnion = function(unionMsg)
    if searchListMsg ~= nil then
        for i, v in ipairs(searchListMsg.guildInfos) do
            if v.guildId == unionMsg.guildId then
                searchListMsg.guildInfos[i] = unionMsg
                LoadSearchPage(false)
                break
            end
        end
    end
end

local function LoadCreatePage()
    if createLanguageId == nil then
        createLanguageId = TextMgr:GetCurrentLanguageID()
    end
    _ui.createPage.languageLabel.text = UnionLanguage.GetLanguageText(createLanguageId)
    UnionBadge.LoadBadgeById(_ui.createPage.badge, badgeId)
end

local function LoadApplyPage()
    local applyListMsg = SelfApplyData.GetData().guildInfos
    for i, v in ipairs(applyListMsg) do
        local unionMsg = v
        local unionTransform = _ui.applyPage.listGrid:GetChild(i - 1)
        if unionTransform == nil then
            unionTransform = NGUITools.AddChild(_ui.applyPage.listGrid.gameObject, _ui.unionPrefab).transform
        end
        unionTransform.gameObject:SetActive(true)
        local union = {}
        LoadUnionObject(union, unionTransform)
        LoadUnion(union, unionMsg, true)
    end
    local index = applyListMsg ~= nil and #applyListMsg + 1 or 1
    for i = index, _ui.applyPage.listGrid.transform.childCount do
        _ui.applyPage.listGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end
    _ui.applyPage.emptyTransform.gameObject:SetActive(#applyListMsg == 0)
    _ui.applyPage.listGrid:Reposition()
    _ui.applyPage.scrollView:ResetPosition()
end

function LoadUI()
    LoadSearchPage(true)
    LoadCreatePage()
    LoadApplyPage()
end

function RequestSearch(pageIndex,customCallBack)
    local req = GuildMsg_pb.MsgGuildListRequest()
    req.nameOrBanner = _ui.searchPage.nameInput.value
    req.lang = searchLanguageId
    req.pageIndex = pageIndex
    req.pageSize = _ui.searchPage.pageSize

    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildListRequest, req, GuildMsg_pb.MsgGuildListResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
			Global.DumpMessage(msg , "d:/unionlist.lua")
            if customCallBack ~= nil then
                customCallBack(msg)
            else
                searchListMsg = msg
                LoadSearchPage(true)
            end
        else
            Global.ShowError(msg.code)
        end
    end, false)
end

function SearchDragFinished()
    local y = _ui.searchPage.scrollView.transform.localPosition.y
    if y < -30 then
        if searchListMsg ~= nil and searchListMsg.pageIndex > 1 then
            RequestSearch(searchListMsg.pageIndex - 1)
        end
    elseif y + _ui.searchPage.clipHeight >  _ui.searchPage.pageSize * _ui.searchPage.listGrid.cellHeight + 30 then
        if searchListMsg ~= nil and searchListMsg.more then
            RequestSearch(searchListMsg.pageIndex + 1)
        end
    end
end

function Awake()
    _ui = {}
    if _ui.unionPrefab == nil then
        _ui.unionPrefab = ResourceLibrary.GetUIPrefab("Union/lisitem_union1")
    end
    local closeButton = transform:Find("background widget/close btn"):GetComponent("UIButton")
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, Hide)
    SetClickCallback(mask.gameObject, Hide)

    _ui.searchPage = {}
    _ui.searchPage.pageToggle = transform:Find("background widget/bg2/page1"):GetComponent("UIToggle")
    _ui.searchPage.nameInput = transform:Find("background widget/bg2/content 1/search widget/frame_input"):GetComponent("UIInput")
    _ui.searchPage.languageButton = transform:Find("background widget/bg2/content 1/search widget/frame_input (1)"):GetComponent("UIButton")
    _ui.searchPage.languageLabel = transform:Find("background widget/bg2/content 1/search widget/frame_input (1)/title"):GetComponent("UILabel")
    _ui.searchPage.searchButton = transform:Find("background widget/bg2/content 1/search widget/search btn"):GetComponent("UIButton")
    _ui.searchPage.scrollView = transform:Find("background widget/bg2/content 1/Scroll View"):GetComponent("UIScrollView")
    _ui.searchPage.scrollView.onDragFinished = SearchDragFinished
    local listGridTransform = transform:Find("background widget/bg2/content 1/Scroll View/Grid")
    _ui.searchPage.listGrid = listGridTransform:GetComponent("UIGrid")
    _ui.searchPage.nameInput.defaultText = TextMgr:GetText(Text.click_input)
    _ui.searchPage.unionList = {}
    _ui.searchPage.pageSize = listGridTransform.childCount
    _ui.searchPage.clipHeight = transform:Find("background widget/bg2/content 1/Scroll View"):GetComponent("UIPanel").baseClipRegion.w
    for i = 1, _ui.searchPage.pageSize do
        local union = {}
        local unionTransform = listGridTransform:GetChild(i - 1)
        LoadUnionObject(union, unionTransform)
        _ui.searchPage.unionList[i] = union
    end

    SetClickCallback(_ui.searchPage.languageButton.gameObject, function()
        UnionLanguage.Show(searchLanguageId, true, function(languageId)
            SetSearchLanguage(languageId)
        end)
    end)
    SetClickCallback(_ui.searchPage.searchButton.gameObject, function()
        RequestSearch(1)
    end)

    _ui.createPage = {}
    _ui.createPage.pageToggle = transform:Find("background widget/bg2/page2"):GetComponent("UIToggle")
    _ui.createPage.nameInput = transform:Find("background widget/bg2/content 2/name widget/frame_input"):GetComponent("UIInput")
    _ui.createPage.codeInput = transform:Find("background widget/bg2/content 2/name widget/frame_input (1)"):GetComponent("UIInput")
    _ui.createPage.badgeButton = transform:Find("background widget/bg2/content 2/badge widget/change btn"):GetComponent("UIButton")
    _ui.createPage.languageButton = transform:Find("background widget/bg2/content 2/language widget/change btn"):GetComponent("UIButton")
    _ui.createPage.createButton = transform:Find("background widget/bg2/content 2/btn ok"):GetComponent("UIButton")
    _ui.createPage.createLabel = transform:Find("background widget/bg2/content 2/btn ok/number"):GetComponent("UILabel")
    _ui.createPage.createLabel.text = JoinUnion.GetCreateCost()
    _ui.createPage.nameInput.defaultText = TextMgr:GetText(Text.click_input)
    _ui.createPage.codeInput.defaultText = TextMgr:GetText(Text.click_input)
    local badge = {}
    badge.borderTexture = transform:Find("background widget/bg2/content 2/badge widget/badge bg/outline icon"):GetComponent("UITexture")
    badge.colorTexture = transform:Find("background widget/bg2/content 2/badge widget/badge bg/outline icon/color"):GetComponent("UITexture")
    badge.totemTexture = transform:Find("background widget/bg2/content 2/badge widget/badge bg/totem icon"):GetComponent("UITexture")
    _ui.createPage.badge = badge
    _ui.createPage.languageLabel = transform:Find("background widget/bg2/content 2/language widget/frame_input/title"):GetComponent("UILabel")
    SetClickCallback(_ui.createPage.badgeButton.gameObject, function()
        UnionBadge.Show(badgeId, false, function(badgeInfo)
            badgeId = UnionBadge.BadgeInfoToId(badgeInfo)
            UnionBadge.LoadBadgeByInfo(_ui.createPage.badge, badgeInfo)
        end)
    end)
    SetClickCallback(_ui.createPage.languageButton.gameObject, function()
        UnionLanguage.Show(createLanguageId, false, function(languageId)
            SetCreateLanguage(languageId)
        end)
    end)

    SetClickCallback(_ui.createPage.createButton.gameObject, function()
        local req = GuildMsg_pb.MsgCreateGuildRequest()
        req.name = _ui.createPage.nameInput.value
        req.banner = _ui.createPage.codeInput.value
        req.badge = badgeId
        req.lang = createLanguageId

        Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgCreateGuildRequest, req, GuildMsg_pb.MsgCreateGuildResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                SelfApplyData.RequestData()
                JoinUnion.CloseAll()
                UnionInfoData.UpdateData(msg)
                UnionInfo.Show()
                GUIMgr:SendDataReport("efun", "create_unions")
                MainCityUI.UpdateRewardData(msg.fresh)
                --拉取联盟留言
                UnionMessageData.RequestUnionMessageChatInfo(UnionInfoData.GetGuildId())
            else
                Global.ShowError(msg.code)
            end
        end, false)
    end)

    _ui.applyPage = {}
    _ui.applyPage.pageToggle = transform:Find("background widget/bg2/page3"):GetComponent("UIToggle") 
    _ui.applyPage.scrollView = transform:Find("background widget/bg2/content 3/Scroll View"):GetComponent("UIScrollView")
    _ui.applyPage.listGrid = transform:Find("background widget/bg2/content 3/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.applyPage.emptyTransform = transform:Find("background widget/bg2/content 3/no one")

    SelfApplyData.AddListener(LoadSearchPage)
    SelfApplyData.AddListener(LoadApplyPage)
end

function Close()
    SelfApplyData.RemoveListener(LoadSearchPage)
    SelfApplyData.RemoveListener(LoadApplyPage)
    _ui = nil
end

function Show(search)
    if searchLanguageId == nil then
        searchLanguageId = -1
    end
    badgeId = UnionBadge.CreateRandomBadgeId()
    Global.OpenUI(_M)
    LoadUI()
    if search then
        _ui.searchPage.pageToggle.value = true
    else
        _ui.createPage.pageToggle.value = true
    end
    RequestSearch(1)
end

function SetExtraUI(ui)
    _ui= ui
    if searchLanguageId == nil then
        searchLanguageId = -1
    end    
end

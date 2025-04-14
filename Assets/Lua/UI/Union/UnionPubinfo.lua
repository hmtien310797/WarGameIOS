module("UnionPubinfo", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback

local _ui
local annouceContent = {}

local unionMsg

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local RequestUnionInfo
local function UpdateInputLimit()
    local characterCount = utf8.len(_ui.editInput.value)
    _ui.numLabel.text = string.format("%d/%d", characterCount, _ui.characterLimit)
    _ui.numLabel.color = characterCount >= _ui.characterLimit and NGUIMath.HexToColor(0xFF0002FF) or Color.white 
end

local function LoadUI()
    local hasApplied = SelfApplyData.HasApplied(unionMsg.guildId)
    UnionBadge.LoadBadgeById(_ui.badgeWidget, unionMsg.badge)
    _ui.nameLabel.text = string.format("[%s]%s", unionMsg.banner, unionMsg.name)
    _ui.powerLabel.text = Global.FormatNumber(unionMsg.power)
    _ui.levelLabel.text = unionMsg.giftLevel
    _ui.leaderLabel.text = unionMsg.leaderName
    _ui.memberLabel.text = string.format("%d/%d", unionMsg.memberCount, unionMsg.memberMax)
    _ui.languageLabel.text = UnionLanguage.GetLanguageText(unionMsg.lang)
    _ui.borderLabel.text = unionMsg.fieldNum
    _ui.rankLabel.text = unionMsg.pkValueRank
	
	_ui.unionCardLabel.text = unionMsg.guildMonthBuyed and string.format("%s/%s" , unionMsg.guildMonthDayMax - unionMsg.guildMonthDay , unionMsg.guildMonthDayMax) or TextMgr:GetText("ui_worldmap_45")

    local selfUnionInfoMsg = UnionInfoData.GetData()
    local isSelfUnion = selfUnionInfoMsg.guildInfo.guildId == unionMsg.guildId
    _ui.noticeLabel.text = unionMsg.outerNotice
    local privilege = selfUnionInfoMsg.memberInfo.privilege
    local noticePrivilege = bit.band(privilege,  GuildMsg_pb.PrivilegeType_EditOuterNotice) ~= 0
    _ui.noticeButton.gameObject:SetActive(isSelfUnion and noticePrivilege)
    
    if not noticePrivilege then
        _ui.editTransform.gameObject:SetActive(false)
    end

    _ui.joinTransform.gameObject:SetActive(not UnionInfoData.HasUnion() and not isSelfUnion and unionMsg.recruitType == GuildMsg_pb.RecruitType_public)
    _ui.applyButton.gameObject:SetActive(not UnionInfoData.HasUnion() and not isSelfUnion and unionMsg.recruitType == GuildMsg_pb.RecruitType_apply)
    _ui.applyLabel.text = TextMgr:GetText(hasApplied and Text.union_cancel or Text.union_apply)
    _ui.applyButton.normalSprite = hasApplied and "btn_3" or "btn_2"
	_ui.leaderPos.gameObject:SetActive(isSelfUnion)
	SetClickCallback(_ui.leaderPos.gameObject , function()
		local req = GuildMsg_pb.MsgGuildLeaderInfoRequest()
		Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildLeaderInfoRequest, req, GuildMsg_pb.MsgGuildLeaderInfoResponse, function(msg)
			if msg.code == ReturnCode_pb.Code_OK then
				if not msg.isExile then
					GUIMgr:ActiveMainCityUI()
					
					MainCityUI.ShowWorldMap(msg.leaderInfo.entryBaseData.pos.x , msg.leaderInfo.entryBaseData.pos.y , true)
                else
                    FloatText.Show(TextMgr:GetText(Text.union_searchleader))
				end
            else
                Global.ShowError(msg.code)
			end
		end, false)
	end)
    SetClickCallback(_ui.applyButton.gameObject, function()
        if hasApplied then
            local req = GuildMsg_pb.MsgCancelApplyGuildRequest()
            req.guildId = unionMsg.guildId

            Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgCancelApplyGuildRequest, req, GuildMsg_pb.MsgCancelApplyGuildResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    SelfApplyData.RequestData()
                else
                    Global.ShowError(msg.code)
                    RequestUnionInfo()
                end
            end, false)
        else
            local req = GuildMsg_pb.MsgApplyGuildRequest()
            req.guildId = unionMsg.guildId

            Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgApplyGuildRequest, req, GuildMsg_pb.MsgApplyGuildResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    SelfApplyData.RequestData()
                else
                    Global.ShowError(msg.code)
                    RequestUnionInfo()
                end
            end, false)
        end
    end)

	_ui.transBg.gameObject:SetActive(unionMsg.outerNotice ~= nil and unionMsg.outerNotice ~= "")
	annouceContent = {}
	annouceContent.transBtn = _ui.transBtn
	annouceContent.origeBtn = _ui.origeBtn
	annouceContent.content = _ui.noticeLabel:GetComponent("UILabel")--msg.content
	annouceContent.srcContent = unionMsg.outerNotice
	annouceContent.transing = _ui.transing
end

function RequestUnionInfo()
    local req = GuildMsg_pb.MsgGuildInfoRequest()
    req.guildId = unionMsg.guildId

    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildInfoRequest, req, GuildMsg_pb.MsgGuildInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            unionMsg = msg.guildInfo
            if GUIMgr:IsMenuOpen(UnionList._NAME) then
                UnionList.UpdateSearchUnion(unionMsg)
            end
            LoadUI()
        else
            Global.ShowError(msg.code)
        end
    end, false)
end

function CheckAndSendUnionInvitation()
	if not UnionInfoData.HasPrivilege(GuildMsg_pb.PrivilegeType_ChatGuildInvite) then	
		FloatText.Show(TextMgr:GetText("union_invite_text6") , Color.red)
		return
	end

	
	local unioninfo = UnionInfoData.GetData()
	local maxMemCount = UnionInfo.GetMaxMemberCount()
	if unioninfo.guildInfo.memberCount >= maxMemCount then
		FloatText.Show(TextMgr:GetText("union_invite_text8") , Color.red)
		return
	end
	
	--为热更新，临时写死数值
	local cost = tonumber(TableMgr:GetGlobalData(100077).value)
	if MoneyListData.GetDiamond() < cost then
		Global.ShowNoEnoughMoney()
		return
	end
	
    local send = {}
    send.type = ChatMsg_pb.ChatInfoConditionType_GuildInvite
	send.curChanel = ChatMsg_pb.chanel_world
	send.spectext = unioninfo.guildInfo.banner..","..
					unioninfo.guildInfo.name..","..
					unioninfo.guildInfo.power..","..
					unioninfo.guildInfo.memberCount.."/"..maxMemCount .. ","..
					unioninfo.guildInfo.badge..","..
					math.random(1,3)..","..
					unioninfo.guildInfo.guildId..","..
					unioninfo.guildInfo.lang
					
					
	send.content = "union_invite_text4"
	send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
	send.chatType = 5
	send.senderguildname = unioninfo.guildInfo.banner
	--send.senderguildname = UnionInfoData.GetData().guildInfo.name
	--Chat.SendContent(send)
	Chat.SendConditionContent(send , function()
		FloatText.Show(System.String.Format(TextMgr:GetText(Text.union_invite_tips), cost), Color.white)
	end)
end

function ShowEditNotice()
    _ui.editTransform.gameObject:SetActive(true)
    _ui.editInput.value = _ui.noticeLabel.text
    _ui.editInput.isSelected = true
    UpdateInputLimit()
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/BG up/close")
    SetClickCallback(mask.gameObject, Hide)
    SetClickCallback(closeButton.gameObject, Hide)

    _ui.badgeWidget = {}
    _ui.badgeWidget.borderTexture = transform:Find("Container/BG middle/BadgeBG/outline icon"):GetComponent("UITexture")
    _ui.badgeWidget.colorTexture = transform:Find("Container/BG middle/BadgeBG/outline icon/color"):GetComponent("UITexture")
    _ui.badgeWidget.totemTexture = transform:Find("Container/BG middle/BadgeBG/totem icon"):GetComponent("UITexture")

    _ui.nameLabel = transform:Find("Container/BG middle/union name"):GetComponent("UILabel")
    _ui.levelLabel = transform:Find("Container/BG middle/giftlevel/giftlevel text"):GetComponent("UILabel")
    _ui.leaderLabel = transform:Find("Container/BG middle/leader/leader text"):GetComponent("UILabel")
    _ui.leaderPos = transform:Find("Container/BG middle/leader/research")
    _ui.powerLabel = transform:Find("Container/BG middle/combat/combat text"):GetComponent("UILabel")
    _ui.memberLabel = transform:Find("Container/BG middle/people/people text"):GetComponent("UILabel")
    _ui.languageLabel = transform:Find("Container/BG middle/Language/Language"):GetComponent("UILabel")
    _ui.borderLabel = transform:Find("Container/BG middle/Territory/giftlevel text"):GetComponent("UILabel")
    _ui.rankLabel = transform:Find("Container/BG middle/Unionrank/giftlevel text"):GetComponent("UILabel")
    _ui.unionCardLabel = transform:Find("Container/BG middle/unioncard/people text"):GetComponent("UILabel")
    _ui.unionCardRoot = transform:Find("Container/BG middle/unioncard").gameObject
    _ui.unionCardRoot:SetActive(UnionCardData.IsAvailable())

    _ui.memberButton = transform:Find("Container/BG middle/Unionmember"):GetComponent("UIButton")
    _ui.letterButton = transform:Find("Container/BG middle/letter"):GetComponent("UIButton")
    _ui.messageButton = transform:Find("Container/BG middle/message"):GetComponent("UIButton")
    SetClickCallback(_ui.messageButton.gameObject, function()
        UnionMessage.Show(unionMsg.guildId)
    end)
    SetClickCallback(_ui.memberButton.gameObject, function()
        UnionMemberLevel.Show(unionMsg.guildId, false)
    end)
    SetClickCallback(_ui.letterButton.gameObject, function()
        Mail.SimpleWriteTo(unionMsg.leaderName)
    end)

    _ui.noticeLabel = transform:Find("Container/BG bottom/Scroll View/Label"):GetComponent("UILabel")
    _ui.noticeButton = transform:Find("Container/BG bottom/editor btn"):GetComponent("UIButton")
    SetClickCallback(_ui.noticeButton.gameObject, function()
        ShowEditNotice()
    end)

    _ui.editTransform = transform:Find("Container/BG bottom/editor mask")
    _ui.editInput = transform:Find("Container/BG bottom/editor mask/input"):GetComponent("UIInput")
    _ui.numLabel = transform:Find("Container/BG bottom/editor mask/num"):GetComponent("UILabel")
    _ui.cancelEditButton = transform:Find("Container/BG bottom/editor mask/cancel btn"):GetComponent("UIButton")
    _ui.confirmEditButton = transform:Find("Container/BG bottom/editor mask/ok btn"):GetComponent("UIButton")

    _ui.editInput.defaultText = TextMgr:GetText(Text.click_input)
    SetClickCallback(_ui.cancelEditButton.gameObject, function()
        _ui.editTransform.gameObject:SetActive(false)
    end)
    _ui.characterLimit = _ui.editInput.characterLimit
    EventDelegate.Add(_ui.editInput.onChange, EventDelegate.Callback(function()
        UpdateInputLimit()
    end))
    SetClickCallback(_ui.confirmEditButton.gameObject, function()
        local req = GuildMsg_pb.MsgEditOuterNoticeRequest()
        req.notice = _ui.editInput.value

        Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgEditOuterNoticeRequest, req, GuildMsg_pb.MsgEditOuterNoticeResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                _ui.noticeLabel.text = msg.notice
                _ui.editTransform.gameObject:SetActive(false)
                UnionInfoData.SetOuterNotice(msg.notice)
            else
                Global.ShowError(msg.code)
            end
        end, false)
    end)

    _ui.joinTransform = transform:Find("Container/JoinUnion")
    _ui.applyButton = transform:Find("Container/ApplyUnion"):GetComponent("UIButton")
    _ui.applyLabel = transform:Find("Container/ApplyUnion/applytext"):GetComponent("UILabel")
    SetClickCallback(_ui.joinTransform.gameObject, function()
        local req = GuildMsg_pb.MsgJoinGuildRequest()
        req.guildId = unionMsg.guildId

        Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgJoinGuildRequest, req, GuildMsg_pb.MsgJoinGuildResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                --SelfApplyData.RequestData()
                UnionInfoData.UpdateData(msg)

                UnionBuildingData.SetCheckNotice()
                UnionBuildingData.RequestData()
				SelfApplyData.ClearApply()--自身已有联盟
				UnionCardData.RequestData(0)
                JoinUnion.CloseAll()
                UnionInfo.Show()
				
				local send = {}
				send.curChanel = ChatMsg_pb.chanel_guild
				send.spectext = ""
				send.content = "TipsNotice_Union_Desc6" .. "," .. MainData.GetCharName()--System.String.Format(TextMgr:GetText("TipsNotice_Union_Desc6") ,MainData.GetCharName()) 
				send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
				send.chatType = 4
				send.senderguildname = UnionInfoData.GetData().guildInfo.name
				Chat.SendContent(send)
				
				if GUIMgr:FindMenu("Chat") ~= nil then
					GUIMgr:CloseMenu("Chat")	
				end

                MainCityUI.HideAllianceInvites()
            else
                RequestUnionInfo()
                Global.ShowError(msg.code)
            end
        end, false)
    end)
	
	_ui.transBg = transform:Find("Container/BG bottom/bg_translate")
	_ui.transBtn = transform:Find("Container/BG bottom/bg_translate/btn_translate"):GetComponent("UIButton")
	_ui.origeBtn = transform:Find("Container/BG bottom/bg_translate/btn_orige"):GetComponent("UIButton")
	_ui.transing = transform:Find("Container/BG bottom/bg_translate/bg_traning")
	SetClickCallback(_ui.transBtn.gameObject , function()
		_ui.transBtn.gameObject:SetActive(false)
		_ui.origeBtn.gameObject:SetActive(false)
		_ui.transing.gameObject:SetActive(true)
		
		UnionInfo.Translate(annouceContent , 1)
	end)
	
	SetClickCallback(_ui.origeBtn.gameObject , function()
		_ui.transBtn.gameObject:SetActive(true)
		_ui.origeBtn.gameObject:SetActive(false)
		_ui.transing.gameObject:SetActive(false)
	
		UnionInfo.CheckSourceText(annouceContent)
	end)
	
	
    UnionInfoData.AddListener(LoadUI)
    SelfApplyData.AddListener(LoadUI)
end

function Close()
    UnionInfoData.RemoveListener(LoadUI)
    SelfApplyData.RemoveListener(LoadUI)
    _ui = nil
	annouceContent = nil
end

function Show(msg, applied)
    unionMsg = msg
    Global.OpenUI(_M)
    LoadUI()
end

function RequestShow(guildId)
    local req = GuildMsg_pb.MsgGuildInfoRequest()
    req.guildId = guildId

    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildInfoRequest, req, GuildMsg_pb.MsgGuildInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            Show(msg.guildInfo)
        else
            Global.ShowError(msg.code)
        end
    end, false)
end

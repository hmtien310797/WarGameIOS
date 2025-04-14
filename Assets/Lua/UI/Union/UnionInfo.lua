module("UnionInfo", package.seeall)
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

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    UnionMemberLevel.CloseAll()
    UnionApprove.CloseAll()
    UnionHelp.CloseAll()
    UnionGift.CloseAll()
    UnionFunction.CloseAll()
    UnionShop.CloseAll()
    UnionBuilding.CloseAll()
    UnionSuperOre.CloseAll()
    UnionCity.CloseAll()
    UnionWar.CloseAll()
    Hide()
end

local annouceContent = {}
local annouceContentOuter = {}

local maxMemberCount

OnCloseCB = nil

function CheckSourceText(trinfo)
    trinfo.content.text = trinfo.srcContent
end

function Translate(trinfo , reqCount)
    print("Translate count:" , reqCount)
    if reqCount >= 10 then
        if trinfo ~= nil then
            trinfo.transBtn.gameObject:SetActive(true)
            trinfo.origeBtn.gameObject:SetActive(false)
            if trinfo.transing ~= nil then
                trinfo.transing.gameObject:SetActive(false)
            end
        end
        return
    end
    reqCount = reqCount + 1
    
    local req = ChatMsg_pb.MsgUserTranslateTextRequest()
    req.clientLang = GUIMgr:GetSystemLanguage()
    req.text:append(trinfo.srcContent)

    Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgUserTranslateTextRequest, req, ChatMsg_pb.MsgUserTranslateTextResponse, function(msg)
        local transData = msg.data[1]
		if trinfo ~= nil and transData ~= nil and transData.text ~= nil and transData.text ~= "" and not transData.waitTranslate then
			trinfo.content.text = transData.text
				trinfo.origeBtn.gameObject:SetActive(true)
				trinfo.transBtn.gameObject:SetActive(false)
				if trinfo.transing ~= nil then
					trinfo.transing.gameObject:SetActive(false)
				end
		else
			Translate(trinfo , reqCount)
		end
    end,true)       
end

function GetMaxMemberCount()
    if maxMemberCount == nil then
        maxMemberCount = TableMgr:GetUnionNumByType("upperLimit")
    end
    return maxMemberCount + (AttributeBonus.CollectBonusInfo(nil, 1)[1100] ~= nil and AttributeBonus.CollectBonusInfo(nil, 1)[1100] or 0)
end

local renamePrice
function GetRenamePrice()
    if renamePrice == nil then
        renamePrice = TableMgr:GetUnionNumByType("name")
    end
    return renamePrice
end

local changeBannerPrice
function GetChangeBannerPrice()
    if changeBannerPrice == nil then
        changeBannerPrice = TableMgr:GetUnionNumByType("code")
    end
    return changeBannerPrice
end

local changeBadgePrice
function GetChangeBadgePrice()
    if changeBadgePrice == nil then
        changeBadgePrice = TableMgr:GetUnionNumByType("badge")
    end
    return changeBadgePrice
end

local deposeLeaderPrice
function GetDeposeLeaderPrice()
    if deposeLeaderPrice == nil then
        deposeLeaderPrice = TableMgr:GetUnionNumByType("recallPrice")
    end
    return deposeLeaderPrice
end

local deposeLeaderTime
function GetDeposeLeaderTime(rank)
    return TableMgr:GetUnionNumByType("recallTimeR"..rank) * 24 * 3600
end

function RequestLog(logtype , index , callback)
	--print("req:" .. logtype , index)
	local req = GuildMsg_pb.MsgGuildOperLogInfoRequest()
	req.operType = logtype
	req.index = index
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildOperLogInfoRequest, req, GuildMsg_pb.MsgGuildOperLogInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
			--Global.DumpMessage(msg , "d:/unionLog.lua")
            if callback ~= nil then
                callback(msg)
            end
        end
    end, false)
end


function UpdateGiftCount(giftCount)
	print("-------" , giftCount)
	if _ui and _ui.infoPage then
		_ui.infoPage.giftNoticeTransform.gameObject:SetActive(giftCount > 0)
		_ui.infoPage.giftCountLabel.text = giftCount
	end
end

function UpdateUnionCardInfo(giftCount)
	local unionCard =  UnionCardData.GetAvailableCard(0)
	 --print(unionCard)
    if unionCard ~= nil  then
		--print(unionCard.buyed)
        if unionCard.buyed then
            transform:Find("Container/bg2/content 1/info widget/unioncard/btn_go").gameObject:SetActive(false)
            local num = transform:Find("Container/bg2/content 1/info widget/unioncard/num"):GetComponent("UILabel")
            num.text = Format(TextMgr:GetText("Union_Mcard_ui6"), unionCard.goodInfo.day - unionCard.day)
            num.gameObject:SetActive(true)
        else
            local go =  transform:Find("Container/bg2/content 1/info widget/unioncard/btn_go").gameObject
            go:SetActive(true)
            transform:Find("Container/bg2/content 1/info widget/unioncard/num").gameObject:SetActive(false)
        end
    end
	
	--UpdateGiftCount(giftCount)
end


local function LoadLogItem(item)
	local itemUI = {}
	local noticeItem_label = item:Find("Label")
	if noticeItem_label then
		itemUI.noticeItem_label = noticeItem_label:GetComponent("UILabel")
	end
	
	local warItem_desLabel = item:Find("text_desc")
	if warItem_desLabel then
		itemUI.warItem_desLabel = warItem_desLabel:GetComponent("UILabel")
	end
	
	local warItem_timeLabel = item:Find("text_time")
	if warItem_timeLabel then
		itemUI.warItem_timeLabel = warItem_timeLabel:GetComponent("UILabel")
	end
	return itemUI
end

local function LoadNotice(logType , logmsg , uigrid , uiitem)
	while uigrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(uigrid.transform:GetChild(0).gameObject)
	end

	for i=1 , #logmsg.logInfo , 1 do
		local info = logmsg.logInfo[i]
		local logBaseData = TableMgr:GetUnionLogData(info.operLogId)
		
		local infoItem = NGUITools.AddChild(uigrid.gameObject, uiitem.gameObject).transform
		infoItem.name = info.operLogId
		
		local itemUI = LoadLogItem(infoItem)
		infoItem:Find("background").gameObject:SetActive(i%2 == 0)
		--local desLabel = nil
		if itemUI.noticeItem_label then
			itemUI.noticeItem_label.text = UnionLog.GetContentText(info , TextMgr:GetText(logBaseData.logContent))
			--desLabel = itemUI.noticeItem_label
		end
		
		if itemUI.warItem_desLabel then
			itemUI.warItem_desLabel.text = UnionLog.GetContentText(info , TextMgr:GetText(logBaseData.logContent))
			--desLabel = itemUI.warItem_desLabel
		end
		
		if itemUI.warItem_timeLabel then
			local pass1 = Global.Datediff(Serclimax.GameTime.GetSecTime() , info.operTime)
			if pass1 > 0 then
				if pass1 >= 7 then
					itemUI.warItem_timeLabel.text = System.String.Format(TextMgr:GetText("chat_hint9") , pass1)
				else
					itemUI.warItem_timeLabel.text = System.String.Format(TextMgr:GetText("chat_hint8") , pass1)
				end
			else
				itemUI.warItem_timeLabel.text = Serclimax.GameTime.SecondToStringHHMM(info.operTime)
			end
		end
		
		--[[SetClickCallback(infoItem.gameObject , function()
			local posUrl = desLabel
			if posUrl == nil then
				return
			end
			
			local url = posUrl:GetUrlAtPosition(UICamera.lastWorldPosition)
			if url == nil then
				return
			end
			--url = "jumppos,3"
			--[93CCE6FF]6qayuyang006[-]占领了空地([url=jumppos,1][u]x:61 y:110[/u][/url])
			--领地[93CCE6FF]空地([url=jumppos,1][u]x:60 y:92[/u][/url])[-]被[FF0000FF][001]5qayuyang005[-]占领
			print(url)
			local str = string.split(url , ",")
			if str[1] == "jumppos" then
				local param = info.paras[tonumber(str[2]) + 1].value
				local posstr = string.split(param , " ")
				local posstrx = tonumber(string.split(posstr[1] , ":")[2])
				local posstry = tonumber(string.split(posstr[2] , ":")[2])
				print(posstrx , posstry)
				Hide()
				if GUIMgr:FindMenu("UnionInfo") ~= nil then
					UnionInfo.Hide()
				end
				MainCityUI.ShowWorldMap(posstrx, posstry, true)
			end
		end)]]
		
		--[[local bgSpr = infoItem:Find("bg_list/background"):GetComponent("UISprite")
		bgSpr.spriteName = logBaseData.logBg
		
		local contentText = infoItem:Find("bg_list/text_desc"):GetComponent("UILabel")
		
		
		local timeText = infoItem:Find("bg_list/text_time"):GetComponent("UILabel")
		local pass1 = Global.Datediff(Serclimax.GameTime.GetSecTime() , info.operTime)
		if pass1 > 0 then
			if pass1 >= 7 then
				timeText.text = System.String.Format(TextMgr:GetText("chat_hint9") , pass1)
			else
				timeText.text = System.String.Format(TextMgr:GetText("chat_hint8") , pass1)
			end
		else
			timeText.text = Serclimax.GameTime.SecondToStringHHMM(info.operTime)
		end
		
		
		SetClickCallback(infoItem.gameObject , function()
			local posUrl = infoItem:Find("bg_list/text_desc"):GetComponent("UILabel")
			local url = posUrl:GetUrlAtPosition(UICamera.lastWorldPosition)
			if url == nil then
				return
			end
			--url = "jumppos,3"
			--[93CCE6FF]6qayuyang006[-]占领了空地([url=jumppos,1][u]x:61 y:110[/u][/url])
			--领地[93CCE6FF]空地([url=jumppos,1][u]x:60 y:92[/u][/url])[-]被[FF0000FF][001]5qayuyang005[-]占领
			print(url)
			local str = string.split(url , ",")
			if str[1] == "jumppos" then
				local param = info.paras[tonumber(str[2]) + 1].value
				local posstr = string.split(param , " ")
				local posstrx = tonumber(string.split(posstr[1] , ":")[2])
				local posstry = tonumber(string.split(posstr[2] , ":")[2])
				print(posstrx , posstry)
				Hide()
				if GUIMgr:FindMenu("UnionInfo") ~= nil then
					UnionInfo.Hide()
				end
				MainCityUI.ShowWorldMap(posstrx, posstry, true)
			end
		end)
		]]
	end
	uigrid:Reposition()
end

local function UpdateUnionInternalNotice()
	RequestLog(GuildMsg_pb.GuildOperLogTypeInterior , 1 , function(msg)
		LoadNotice(GuildMsg_pb.GuildOperLogTypeInterior , msg , _ui.infoPage.logGrid , _ui.infoPage.logPrefab)
	end)
end

local function UpdateUnionWarNotice()
	RequestLog(GuildMsg_pb.GuildOperLogTypeFight , 1 , function(msg)
		LoadNotice(GuildMsg_pb.GuildOperLogTypeFight , msg , _ui.infoPage.logWarGrid , _ui.infoPage.logWarPrefab)
	end)
end

local function UpdateUnionTecNotice()
    local infoPage = _ui.infoPage
    local had_privilege = UnionInfoData.HasPrivilege(GuildMsg_pb.PrivilegeType_UpgradeTech)
    infoPage.techNoticeObject:SetActive(had_privilege and UnionTechData.GetNormalDonateNotice())
end

local function UpdateUnionHelp()
    local unionHelpCount = UnionHelpData.GetHelpCount()
    --_ui.infoPage.helpNotice:SetActive(unionHelpCount > 0)
    --_ui.infoPage.helpCount.text = unionHelpCount
end

local function UpdateCityNotice()
	if _ui then
		_ui.infoPage.cityNoticeObject:SetActive(UnionCityData.HasUnclaimedRewards())
	end
end

local function UpdateFunctionNotice()
	if _ui then
		_ui.infoPage.functionNotice:SetActive(UnionApplyData.HasNotice())
	end
end

local function SecondUpdate()
	if _ui then
		_ui.infoPage.donateNotice.gameObject:SetActive(UnionDonateData.HasNotice())
	end
end

function LoadUI()
    if not UnionInfoData.HasUnion() then
        CloseAll()
        return
    end

    local infoPage = _ui.infoPage
    local unionInfoMsg = UnionInfoData.GetData()
    local unionMsg = unionInfoMsg.guildInfo
    local memberMsg = unionInfoMsg.memberInfo
    UnionBadge.LoadBadgeById(infoPage.badge, unionMsg.badge)
    infoPage.nameLabel.text = string.format("[%s]%s", unionMsg.banner, unionMsg.name)
    infoPage.leaderLabel.text = unionMsg.leaderName
    infoPage.powerLabel.text = Global.FormatNumber(unionMsg.power)
    infoPage.memberLabel.text = string.format("%d/%d", unionMsg.memberCount, GetMaxMemberCount())
    infoPage.coinLabel.text = Global.FormatNumber(UnionInfoData.GetCoin())
    SetClickCallback(infoPage.leaderPosObject, function()
        local req = GuildMsg_pb.MsgGuildFixPositionRequest()
        Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildFixPositionRequest, req, GuildMsg_pb.MsgGuildFixPositionResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                GUIMgr:ActiveMainCityUI()
                MainCityUI.ShowWorldMap(msg.pos.x , msg.pos.y , true)
            else
                Global.ShowError(msg.code)
            end
        end, false)
    end)

    infoPage.innerNotice.noticeLabel.text = #unionMsg.innerNotice > 0 and unionMsg.innerNotice or TextMgr:GetText(Text.union_notice_tips1)
    infoPage.outerNotice.noticeLabel.text = #unionMsg.outerNotice > 0 and unionMsg.outerNotice or TextMgr:GetText(Text.union_notice_tips2)

    infoPage.giftButton.transform:Find("Label"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText("union_giftinfo") , UnionInfoData.GetData().guildInfo.giftLevel)
    
    --union card
    infoPage.unionCardRoot:SetActive(UnionCardData.IsAvailable())
    
    local unionCard =  UnionCardData.GetAvailableCard(0)
    if unionCard ~= nil  then
        if unionCard.buyed then
            infoPage.unionCardGo:SetActive(false)
            infoPage.unionCardNum.text = Format(TextMgr:GetText("Union_Mcard_ui6"), unionCard.goodInfo.day - unionCard.day)
            infoPage.unionCardNum.gameObject:SetActive(true)
        else
            
            SetClickCallback(infoPage.unionCardGo, function()
				Goldstore.ShowUnionCardInfo()
            end)
            infoPage.unionCardGo:SetActive(true)
            infoPage.unionCardNum.gameObject:SetActive(false)
        end
    end
	
    --gift count
    local activeGiftCount = UnionInfoData.GetActiveGiftCount()
    infoPage.giftNoticeTransform.gameObject:SetActive(activeGiftCount > 0)
    infoPage.giftCountLabel.text = activeGiftCount

    infoPage.innerNotice.transBg.gameObject:SetActive(UnionInfoData.GetData().guildInfo.innerNotice ~= nil and UnionInfoData.GetData().guildInfo.innerNotice ~= "")
    annouceContent = {}
    annouceContent.transBtn = infoPage.innerNotice.transBtn
    annouceContent.origeBtn = infoPage.innerNotice.origeBtn
    annouceContent.content = infoPage.innerNotice.noticeLabel:GetComponent("UILabel")--msg.content
    annouceContent.srcContent = UnionInfoData.GetData().guildInfo.innerNotice
    annouceContent.transing = infoPage.innerNotice.transing
    
    infoPage.outerNotice.transBg.gameObject:SetActive(UnionInfoData.GetData().guildInfo.outerNotice ~= nil and UnionInfoData.GetData().guildInfo.outerNotice ~= "")
    annouceContentOuter = {}
    annouceContentOuter.transBtn = infoPage.outerNotice.transBtn
    annouceContentOuter.origeBtn = infoPage.outerNotice.origeBtn
    annouceContentOuter.content = infoPage.outerNotice.noticeLabel:GetComponent("UILabel")--msg.content
    annouceContentOuter.srcContent = UnionInfoData.GetData().guildInfo.outerNotice
    annouceContentOuter.transing = infoPage.outerNotice.transing

    UpdateUnionTecNotice()
    
    UpdateUnionHelp()
	
	UpdateUnionInternalNotice()
	UpdateUnionWarNotice()
	
    infoPage.warNoticeObject:SetActive(MainCityUI.MassHasNotice())
    UpdateCityNotice()
    infoPage.buildingNoticeObject:SetActive(UnionBuildingData.HasNotice() or UnityEngine.PlayerPrefs.GetInt("UnionBuildingNotice") == 0 or UnionResourceRequestData.HasNotice())
    infoPage.messageNoticeObject:SetActive(UnionMessage.HasRedPoint())
    UpdateFunctionNotice()

    SecondUpdate()
end

function Start()
    local infoPage = {}
    local badge = {}
    local badgeTransform = transform:Find("Container/bg2/content 1/union_icon/icon bg")
    UnionBadge.LoadBadgeObject(badge, badgeTransform)
    infoPage.badge = badge
    infoPage.nameLabel = transform:Find("Container/bg2/content 1/info widget/union name"):GetComponent("UILabel")
    infoPage.leaderLabel = transform:Find("Container/bg2/content 1/info widget/leader/leader text"):GetComponent("UILabel")
    infoPage.leaderPosObject = transform:Find("Container/bg2/content 1/info widget/leader/research").gameObject
    infoPage.powerLabel = transform:Find("Container/bg2/content 1/union_icon/combat/combat text"):GetComponent("UILabel")
    infoPage.memberLabel = transform:Find("Container/bg2/content 1/info widget/people/people text"):GetComponent("UILabel")
    infoPage.coinLabel = transform:Find("Container/bg2/content 1/info widget/capital/num"):GetComponent("UILabel")

    infoPage.letterButton = transform:Find("Container/bg2/content 1/info widget/mail"):GetComponent("UIButton")
    infoPage.memberButton = transform:Find("Container/bg2/content 1/function_secondary/member_btn"):GetComponent("UIButton")
    infoPage.memberNoticeObject = transform:Find("Container/bg2/content 1/function_secondary/member_btn/red dot").gameObject
    infoPage.helpButton = transform:Find("Container/bg2/content 1/function widget/help_btn"):GetComponent("UIButton")
    infoPage.helpNotice = transform:Find("Container/bg2/content 1/function widget/help_btn/red dot").gameObject
    --infoPage.helpCount = transform:Find("Container/bg2/content 1/function widget/btn3/red dot/num"):GetComponent("UILabel")
    infoPage.giftButton = transform:Find("Container/bg2/content 1/function_secondary/gift_btn"):GetComponent("UIButton")
    infoPage.giftNoticeTransform = transform:Find("Container/bg2/content 1/function_secondary/gift_btn/red dot")
    infoPage.giftCountLabel = transform:Find("Container/bg2/content 1/function_secondary/gift_btn/red dot/num"):GetComponent("UILabel")

    infoPage.logGrid = transform:Find("Container/bg2/content 1/notice_widget/notice/Scroll View/Grid"):GetComponent("UIGrid")
    infoPage.logPrefab = transform:Find("Container/bg2/content 1/notice_widget/notice/log")--ResourceLibrary.GetUIPrefab("Union/UnionLog_descinfo")
	infoPage.logAllBtn = transform:Find("Container/bg2/content 1/notice_widget/notice/allbtn")
    infoPage.logWarGrid = transform:Find("Container/bg2/content 1/trends/Scroll View/Grid"):GetComponent("UIGrid")
    infoPage.logWarPrefab = transform:Find("Container/bg2/content 1/trends/UnionLog_descinfo")
	infoPage.logWarAllBtn = transform:Find("Container/bg2/content 1/trends/Panel/allbtn")

    infoPage.donateButton = transform:Find("Container/bg2/content 1/function widget/donate_btn"):GetComponent("UIButton")
    infoPage.donateNotice = transform:Find("Container/bg2/content 1/function widget/donate_btn/red dot").gameObject

    infoPage.shopButton = transform:Find("Container/bg2/content 1/function widget/shop_btn"):GetComponent("UIButton")
    infoPage.functionButton = transform:Find("Container/bg2/content 1/function_secondary/manage_btn"):GetComponent("UIButton")
    infoPage.functionNotice = transform:Find("Container/bg2/content 1/function_secondary/manage_btn/red").gameObject

    infoPage.warButton = transform:Find("Container/bg2/content 1/function widget/war_btn"):GetComponent("UIButton")
    infoPage.warNoticeObject = transform:Find("Container/bg2/content 1/function widget/war_btn/red dot").gameObject

    infoPage.buildingButton = transform:Find("Container/bg2/content 1/function widget/building_btn"):GetComponent("UIButton")
    infoPage.buildingNoticeObject = transform:Find("Container/bg2/content 1/function widget/building_btn/red dot").gameObject

    infoPage.cityButton = transform:Find("Container/bg2/content 1/function widget/city_btn"):GetComponent("UIButton")
    infoPage.cityNoticeObject = transform:Find("Container/bg2/content 1/function widget/city_btn/red dot").gameObject

    local innerNotice = {}
    innerNotice.transBg = transform:Find("Container/bg2/content 1/notice_widget/announcement/bg_translate")
    innerNotice.transBtn = transform:Find("Container/bg2/content 1/notice_widget/announcement/bg_translate/btn_translate"):GetComponent("UIButton")
    innerNotice.origeBtn = transform:Find("Container/bg2/content 1/notice_widget/announcement/bg_translate/btn_orige"):GetComponent("UIButton")
    innerNotice.transing = transform:Find("Container/bg2/content 1/notice_widget/announcement/bg_translate/bg_traning")
    innerNotice.noticeLabel = transform:Find("Container/bg2/content 1/notice_widget/announcement/Scroll View/Label"):GetComponent("UILabel")

    infoPage.innerNotice = innerNotice
    
    local outerNotice = {}
    outerNotice.transBg = transform:Find("Container/bg2/content 1/notice_widget/announcement_out/bg_translate")
    outerNotice.transBtn = transform:Find("Container/bg2/content 1/notice_widget/announcement_out/bg_translate/btn_translate"):GetComponent("UIButton")
    outerNotice.origeBtn = transform:Find("Container/bg2/content 1/notice_widget/announcement_out/bg_translate/btn_orige"):GetComponent("UIButton")
    outerNotice.transing = transform:Find("Container/bg2/content 1/notice_widget/announcement_out/bg_translate/bg_traning")
    outerNotice.noticeLabel = transform:Find("Container/bg2/content 1/notice_widget/announcement_out/Scroll View/Label"):GetComponent("UILabel")

    infoPage.outerNotice = outerNotice
    
    infoPage.messageButton = transform:Find("Container/bg2/content 1/function_secondary/message_btn").gameObject
    infoPage.messageNoticeObject = transform:Find("Container/bg2/content 1/function_secondary/message_btn/red dot").gameObject

    infoPage.techButton = transform:Find("Container/bg2/content 1/function widget/tech_btn").gameObject
    infoPage.techNoticeObject = transform:Find("Container/bg2/content 1/function widget/tech_btn/red dot").gameObject

    infoPage.unionCardRoot = transform:Find("Container/bg2/content 1/info widget/unioncard").gameObject
	infoPage.unionCardGo =  transform:Find("Container/bg2/content 1/info widget/unioncard/btn_go").gameObject
	infoPage.unionCardNum =  transform:Find("Container/bg2/content 1/info widget/unioncard/num"):GetComponent("UILabel")
	
    SetClickCallback(infoPage.messageButton, function()
        UnionMessage.Show(UnionInfoData.GetGuildId())
    end)

    SetClickCallback(infoPage.techButton, function()
        UnionTec.Show()
        UnionTechData.NormalDonateNoticeReset()
    end)
    
    infoPage.memberNoticeObject:SetActive(UnityEngine.PlayerPrefs.GetInt("UnionMemberNotice") == 0)

    SetClickCallback(infoPage.innerNotice.transBtn.gameObject , function()
        infoPage.innerNotice.transBtn.gameObject:SetActive(false)
        infoPage.innerNotice.origeBtn.gameObject:SetActive(false)
        infoPage.innerNotice.transing.gameObject:SetActive(true)
        
        Translate(annouceContent , 1)
    end)
    
    SetClickCallback(infoPage.innerNotice.origeBtn.gameObject , function()
        infoPage.innerNotice.transBtn.gameObject:SetActive(true)
        infoPage.innerNotice.origeBtn.gameObject:SetActive(false)
        infoPage.innerNotice.transing.gameObject:SetActive(false)
    
        CheckSourceText(annouceContent)
    end)
    
    SetClickCallback(infoPage.outerNotice.transBtn.gameObject , function()
        infoPage.outerNotice.transBtn.gameObject:SetActive(false)
        infoPage.outerNotice.origeBtn.gameObject:SetActive(false)
        infoPage.outerNotice.transing.gameObject:SetActive(true)
        
        Translate(annouceContentOuter , 1)
    end)
    
    SetClickCallback(infoPage.outerNotice.origeBtn.gameObject , function()
        infoPage.outerNotice.transBtn.gameObject:SetActive(true)
        infoPage.outerNotice.origeBtn.gameObject:SetActive(false)
        infoPage.outerNotice.transing.gameObject:SetActive(false)
    
        CheckSourceText(annouceContentOuter)
    end)
    
	SetClickCallback(infoPage.logWarAllBtn.gameObject , function()
        UnionLog.Show(GuildMsg_pb.GuildOperLogTypeFight )
    end)
	
	SetClickCallback(infoPage.logAllBtn.gameObject , function()
        UnionLog.Show(GuildMsg_pb.GuildOperLogTypeInterior )
    end)

    EventDispatcher.Bind(UnionCityData.OnRewardStatusChange(), _M, EventDispatcher.HANDLER_TYPE.DELAYED, UpdateCityNotice)

     --群体邮件
    SetClickCallback(infoPage.letterButton.gameObject, function()
		local pos = UnionInfoData.GetData().memberInfo.position
		if pos >= 5 or UnionInfoData.IsLeader() then
			--Mail.SetJumMenu("MailNew")
			local sendMailData = {}
			sendMailData.fromname = TextMgr:GetText("mail_all_union")
			sendMailData.unionMember = true
			--MailNew.SetMailData(sendMailData)
			MailNew.SetCloseCallBack(function()
				Mail.Hide()
			end)
			MailNew.Show(sendMailData)
		else
			FloatText.Show(TextMgr:GetText("guild_mail_msg") , Color.red)
			return
		end
        
    end)

    --联盟成员
    SetClickCallback(infoPage.memberButton.gameObject, function()
        local unionInfoMsg = UnionInfoData.GetData()
        UnionMemberLevel.Show(unionInfoMsg.guildInfo.guildId, false)
        if UnityEngine.PlayerPrefs.GetInt("UnionMemberNotice") == 0 then
            infoPage.memberNoticeObject:SetActive(false)
            UnityEngine.PlayerPrefs.SetInt("UnionMemberNotice", 1)
        end
    end)


    --加速援助
    SetClickCallback(infoPage.helpButton.gameObject, function()
        UnionHelp.Show(function()
        end)
    end)

    --礼物等级
    SetClickCallback(infoPage.giftButton.gameObject, function()
        UnionGift.Show()
    end)

    --联盟捐献
    SetClickCallback(infoPage.donateButton.gameObject, function()
        Union_donate.Show()
    end)

    --联盟商店
    SetClickCallback(infoPage.shopButton.gameObject, function()
        SlgBag.Show(3)
    end)

    --集结
    SetClickCallback(infoPage.warButton.gameObject, function()
        UnionWar.Show()
    end)

    --联盟建筑
    SetClickCallback(infoPage.buildingButton.gameObject, function()
        if UnityEngine.PlayerPrefs.GetInt("UnionBuildingNotice") == 0 then
            UnityEngine.PlayerPrefs.SetInt("UnionBuildingNotice", 1)
            LoadUI()
            UnionBuildingData.CancelNotice()
        end
        UnionBuilding.Show()
    end)

    --联盟城市
    SetClickCallback(infoPage.cityButton.gameObject, function()
        UnionCity.Show()
    end)

    --联盟功能
    SetClickCallback(infoPage.functionButton.gameObject, function()
        UnionFunction.Show()
    end)

    _ui.infoPage = infoPage
    --LoadUI()

    _ui.timer = Timer.New(SecondUpdate, 1, -1)
    _ui.timer:Start()

    UnionInfoData.AddListener(LoadUI)
    UnionResourceRequestData.AddListener(LoadUI)
    UnionHelpData.AddListener(UpdateUnionHelp)
    UnionApplyData.AddListener(UpdateFunctionNotice)
    UnionTechData.AddNormalDonateListener(UpdateUnionTecNotice)
end

function UpdateUnionMessageRed()
    if _ui ~= nil and _ui.infoPage ~= nil then
        _ui.infoPage.messageNoticeObject:SetActive(UnionMessage.HasRedPoint())
    end
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/background widget/close btn")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)
end

function Close()
    UnionInfoData.RemoveListener(LoadUI)
    UnionResourceRequestData.RemoveListener(LoadUI)
    UnionHelpData.RemoveListener(UpdateUnionHelp)
    UnionApplyData.RemoveListener(UpdateFunctionNotice)
    UnionTechData.RemoveNormalDonateListener(UpdateUnionTecNotice)
    _ui.timer:Stop()
    _ui = nil
    annouceContent = nil
    annouceContentOuter = nil
    if OnCloseCB ~= nil then
        OnCloseCB()
        OnCloseCB = nil
    end
end

function Show()
    UnionInfoData.RequestData()
    UnionDonateData.RequestData()
    UnionApplyData.RequestData(nil, false)
    Global.OpenUI(_M)

    if Event.HasEvent(46) then
        if ItemListData.GetItemCountByBaseId(4101) >= 5 then
            local req = GuildMsg_pb.MsgGuildFixPositionRequest()
            Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildFixPositionRequest, req, GuildMsg_pb.MsgGuildFixPositionResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    Event.Check(46, true)
                end
            end, false)
        end
    end
end

module("UnionMessage", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
-- local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
-- local GameStateMain = Global.GGameStateMain
-- local GameTime = Serclimax.GameTime
local String = System.String
local GameObject = UnityEngine.GameObject

-- local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
-- local AddDelegate = UIUtil.AddDelegate
-- local RemoveDelegate = UIUtil.RemoveDelegate

local addNewChatItemPos = 0
local addOldChatItemPos = 0
local ReqChatRecord = false
local GuildId = 0
local _ui 

local translateCoroutine = nil
local translateMap = {}
local translateMapCount = 0
local translateTryCount = 3
local translateTryWait = 2
local translateWaiting = false

function GetGuildId()
	return GuildId
end

function Show(guidid)
	GuildId = guidid
	Global.OpenUI(_M)
end

function Hide()
	Global.CloseUI(_M)
end

function Close()	
	GuildId = 0
	ChatData.RemoveListener(NotifyChanelChat)
	coroutine.stop(translateCoroutine)
	coroutine.stop(_ui.setUpdateCorount)
	coroutine.stop(_ui.setCorount)
	if UnionInfoData.GetGuildId() ~= GuildId then
		ChatData.ResetUnionMessageChatListOther()
	end
	_ui = nil
end

function ManagementItem(item, data)
	-- local item = NGUITools.AddChild(_ui.Management_Grid.gameObject , _ui.Management_Item)	
	_ui.ManagementItem_Cancel = item.transform:Find("btn_cancel")
	_ui.ManagementItem_CancelText = item.transform:Find("btn_cancel/Label")
	_ui.ManagementItem_Name = item.transform:Find("name"):GetComponent("UILabel")
	local guildLabel = ""
	if data.user.guildBanner ~= nil and data.user.guildBanner ~= "" then
		guildLabel = "[f1cf63]【".. data.user.guildBanner .. "】[-]"
	end
	_ui.ManagementItem_Name.text = guildLabel ..  "[ffffff]" ..  data.user.name .. "[-]"
	--变灰
	local isPrivilege
	if UnionInfoData.HasPrivilege(GuildMsg_pb.PrivilegeType_MessageBoard) == false then
		_ui.ManagementItem_Cancel:GetComponent("UISprite").spriteName = "btn_4"
		_ui.ManagementItem_Cancel:GetComponent("UIButton").normalSprite = "btn_4"
		_ui.ManagementItem_CancelText:GetComponent("UILabel").color = Color(0.5,0.5,0.5,1)
		isPrivilege = false
	else
		_ui.ManagementItem_Cancel:GetComponent("UISprite").spriteName = "btn_1"
		_ui.ManagementItem_Cancel:GetComponent("UIButton").normalSprite = "btn_1"
		_ui.ManagementItem_CancelText:GetComponent("UILabel").color = Color(1, 1, 1, 1)
		isPrivilege = true
	end
	SetClickCallback(_ui.ManagementItem_Cancel.gameObject, function()
		if isPrivilege == false then 
			Global.FloatError(5513)
			return
		end
		UnionMessageData.RequestGuildSetMessageBoardBacklist(2, data.user.charid, function()
			if _ui == nil then 
				return
			end
			ManagementUpdate()
		end)
	end)	
	item.gameObject:SetActive(true)
end

function ManagementUpdate()
	UnionMessageData.RequestGuildMessageBoardBacklist(function() 
		if _ui == nil then 
			return
		end
		local GuildMessageBoardBackData = UnionMessageData.GetData().user
		if #GuildMessageBoardBackData > 0 then			
			local childcount = _ui.Management_Grid.transform.childCount
			local index = 0			
			for _, v in ipairs(GuildMessageBoardBackData) do 				
				if v.user ~= nil then
					index = index + 1
					local item
					if index <= childcount then
						item = _ui.Management_Grid.transform:GetChild(index - 1)
					else
						item = NGUITools.AddChild(_ui.Management_Grid.gameObject , _ui.Management_Item)
					end
					ManagementItem(item, v)
				end
			end
			_ui.Management_Grid:Reposition()
			for i = index + 1, childcount do
				GameObject.Destroy(_ui.Management_Grid.transform:GetChild(index).gameObject)
			end
			_ui.Management_None = transform:Find("Management/Container/mid/none").gameObject
			_ui.Management_None:SetActive(false)
		else
			if _ui.Management_Grid.transform.childCount > 0 then
				GameObject.Destroy(_ui.Management_Grid.transform:GetChild(0).gameObject)
			end
			_ui.Management_None = transform:Find("Management/Container/mid/none").gameObject
			_ui.Management_None:SetActive(true)
		end
	end)
end

function Management()
	_ui.Management:SetActive(true)
	local unlock = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.UnionMessageUnLock).value)
	_ui.Management_Mask = transform:Find("Management/mask").gameObject
	_ui.Management_Close = transform:Find("Management/Container/bg/top/close").gameObject
	_ui.Management_Title = transform:Find("Management/Container/mid/line/Label"):GetComponent("UILabel")
	_ui.Management_Title.text = String.Format(TextMgr:GetText("UnionMessage_2"), unlock)
	_ui.Management_ScrollView = transform:Find("Management/Container/mid/Scroll View"):GetComponent("UIScrollView")
	_ui.Management_Grid = transform:Find("Management/Container/mid/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.Management_Item = transform:Find("Management/Container/mid/list").gameObject
	SetClickCallback(_ui.Management_Mask, function()
		_ui.Management:SetActive(false)
	end)	
	SetClickCallback(_ui.Management_Close, function()
		_ui.Management:SetActive(false)
	end)	
	ManagementUpdate()
end

function SendContent()
	local unioninfo = UnionInfoData.GetData()
	local send = {}
    send.type = ChatMsg_pb.ChatInfoConditionType_GuildMessageBoard
	send.curChanel = ChatMsg_pb.chanel_guild_mboard
	send.spectext = ""
	send.content = _ui.ChatContent.value
	send.languageCode = TextMgr:GetCurrentLanguageID()
	send.chatType = 7
	send.senderguildname = unioninfo.guildInfo.banner
	send.param = GuildId
	Chat.SendConditionContent(send , function()
		if _ui.ChatContent ~= nil then
			_ui.ChatContent.value = ""
		end
	end)
end

function NotifyChanelChat()	
	local chanelNewChat = nil
	-- if GuildId == UnionInfoData.GetGuildId() then
	-- 	chanelNewChat = ChatData.GetChanelNewChat(ChatMsg_pb.chanel_guild_mboard, 10 , recvList)
	-- else
	chanelNewChat = ChatData.GetChanelNewChat(ChatMsg_pb.chanel_guild_mboard, 10 , recvList)
	-- end

	if GuildId == UnionInfoData.GetGuildId() then
		UnityEngine.PlayerPrefs.SetInt("UnionMessage", ChatData.GetChatDataLength(ChatMsg_pb.chanel_guild_mboard))
		MainCityUI.UpdateNotice()
		UnionInfo.UpdateUnionMessageRed()
	end
	local moveUp = addNewChatItemPos
	local additem = {}
	if chanelNewChat ~= nil and #chanelNewChat > 0 then		
		local setCorount = coroutine.start(function()
			for _, v in pairs(chanelNewChat) do 
				local chatitem = SetChatContent(v)
				table.insert(additem , chatitem.transform)
			end
			
			coroutine.step()
			for _,v in pairs(additem) do
				if v ~= nil then
					Chat.CalculateChatWidth(v)
					v.transform.localPosition = Vector3(0,addNewChatItemPos,0)
					addNewChatItemPos = addNewChatItemPos - Chat.CalculateChatHeight(v)
				end
			end
			
			if _ui.noitem.gameObject.activeSelf then
				_ui.noitem.gameObject:SetActive(false)
			end
			
			local chatcount = _ui.Grid.transform.childCount
			local updatePosPercent = 1 - 4/chatcount
			if _ui.ScrollView.verticalScrollBar.value > updatePosPercent then
				_ui.ScrollView:ResetPosition()
				_ui.ScrollView:RestrictWithinBoundsBottom(true)
			end
		end)
	end
end

function ItemDetail(chatinfo)
	_ui.Detail = transform:Find("Panel_box").gameObject
	_ui.DetailWidget = transform:Find("Panel_box/bg_box"):GetComponent("UIWidget")
	_ui.DetailInfo = transform:Find("Panel_box/bg_box/btn_information").gameObject
	_ui.DetailMail = transform:Find("Panel_box/bg_box/btn_mail").gameObject
	_ui.DetailDisabled = transform:Find("Panel_box/bg_box/btn_ban").gameObject
	_ui.DetailChat = transform:Find("Panel_box/bg_box/btn_chat").gameObject
	_ui.DetailMask = transform:Find("Panel_box/mask").gameObject
	_ui.DetailProhibitText = transform:Find("Panel_box/bg_box/btn_ban/text"):GetComponent("UILabel")
	_ui.DetailReport = transform:Find("Panel_box/bg_box/btn_report").gameObject
	
	
	-- local touchPos = UICamera.currentTouch.pos
	-- local touchUIPos = NGUIMath.ScreenToParentPixels(touchPos, _ui.Detail.transform.parent)
	--_ui.Detail.transform.localPosition = Vector3(touchUIPos.x, touchUIPos.y, 0)
	local isProhibit = false
	_ui.DetailProhibitText.text = TextMgr:GetText("UnionMessage_6")
	local data = UnionMessageData.GetData().user
	for i, v in ipairs(data) do
		if v.user ~= nil then
			if v.user.charid == chatinfo.sender.charid then
				isProhibit = true
				_ui.DetailProhibitText.text = TextMgr:GetText("UnionMessage_5")
			end
		end
	end	

	UIUtil.RepositionTooltip(_ui.DetailWidget)
	_ui.Detail:SetActive(true)
	SetClickCallback(_ui.DetailMask, function()
		_ui.Detail:SetActive(false)
	end)
	SetClickCallback(_ui.DetailInfo, function()
		OtherInfo.RequestShow(chatinfo.sender.charid)
	end)
	SetClickCallback(_ui.DetailMail, function()
		Mail.SimpleWriteTo(chatinfo.sender.name)
	end)
	
	SetClickCallback(_ui.DetailReport, function()
		PanelBox.RequestChatReport(chatinfo.sender.charid,ChatMsg_pb.MsgChatTipOffWay_Guild,chatinfo.infotext);
	end)
	
	--_ui.DetailDisabled:SetActive(UnionInfoData.GetGuildId() == GuildId)
	SetClickCallback(_ui.DetailDisabled , function()
		if UnionInfoData.GetGuildId() ~= GuildId then
			FloatText.Show(TextMgr:GetText("GOV_ui63") , Color.red)
			return 
		end
		
		if isProhibit == false then
			UnionMessageData.RequestGuildSetMessageBoardBacklist(1, chatinfo.sender.charid, function()
				isProhibit = true
				_ui.DetailProhibitText.text = TextMgr:GetText("UnionMessage_5")
			end)
		else
			UnionMessageData.RequestGuildSetMessageBoardBacklist(2, chatinfo.sender.charid, function()
				isProhibit = false
				_ui.DetailProhibitText.text = TextMgr:GetText("UnionMessage_6")
			end)
		end
	end)
	SetClickCallback(_ui.DetailChat, function()
		if Global.GGUIMgr:FindMenu("Chat") == nil then
			Chat.SetPrivateChat(chatinfo.sender.name , chatinfo.sender.charid , chatinfo.sender.guildBanner , chatinfo.sender.officialId, chatinfo.sender.guildOfficialId)
			GUIMgr:CreateMenu("Chat", false)
		else
			Chat.PrivateChat(chatinfo.sender.name , chatinfo.sender.charid , chatinfo.sender.guildBanner , chatinfo.sender.officialId, chatinfo.sender.guildOfficialId)
		end
	end)
end

function SetChatContent(chatinfo)
	local item = NGUITools.AddChild(_ui.Grid.gameObject , _ui.ChatInfo)	
	item.gameObject:SetActive(true)
	item.gameObject.name = chatinfo.time
	item.transform:SetParent(_ui.Grid.transform , false)
	local chatContent = "left"
	if MainData.GetCharId() == chatinfo.sender.charid then
		chatContent = "right"
	else
		if chatinfo.sender.guildid == GuildId then
			local bubble = item.transform:Find(System.String.Format("{0}/bg_msg", chatContent)):GetComponent("UISprite")
			bubble.color = NGUIMath.HexToColor(0xFBCD6BFF)
			local arrow = item.transform:Find(System.String.Format("{0}/bg_msg/arrow", chatContent)):GetComponent("UISprite")
			arrow.color = NGUIMath.HexToColor(0xFBCD6BFF)
		end
	end
	local leftRight = item.transform:Find(System.String.Format("{0}", chatContent))
	leftRight.gameObject:SetActive(true)
	Global.DumpMessage(chatinfo , "d:/chatinfo.lua")
	local touxiangBtn = item.transform:Find(System.String.Format("{0}/bg_touxiang", chatContent)):GetComponent("UIButton")
	
	local itemIcon = item.transform:Find(System.String.Format("{0}/bg_touxiang/icon_touxiang", chatContent)):GetComponent("UITexture")
	itemIcon.mainTexture = ResourceLibrary:GetIcon("Icon/head/", chatinfo.sender.face)
	GOV_Util.SetFaceUI(item.transform:Find(System.String.Format("{0}/bg_touxiang/MilitaryRank", chatContent)), chatinfo.sender.militaryRankId)
	local bg_vip = item.transform:Find(System.String.Format("{0}/bg_touxiang/bg_vip", chatContent))
	bg_vip.gameObject:SetActive(chatinfo.sender.viplevel > 0)
	local vipSpr = bg_vip:Find("icon"):GetComponent("UISprite")
	vipSpr.spriteName = "bg_avatar_num_vip"..math.ceil(chatinfo.sender.viplevel/5)
	local vipLabel = bg_vip:Find("num"):GetComponent("UILabel")
	vipLabel.text = chatinfo.sender.viplevel

	local content = item.transform:Find(System.String.Format("{0}/text" , chatContent)):GetComponent("UILabel")
	local translatebg = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate" , chatContent))
	local translateText = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/text" , chatContent)):GetComponent("UILabel")
	translateText.text = TextMgr:GetText("chat_hint11")--"翻译"
	translatebg.gameObject:SetActive(true)
	local transBtn = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/btn_translate" , chatContent)):GetComponent("UIButton")
	local srcBtn = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/btn_src" , chatContent))
	local traning = item.transform:Find(System.String.Format("{0}/bg_msg/bg_traning" , chatContent))

	local chatName = item.transform:Find(System.String.Format("{0}/bg_title/name" , chatContent)):GetComponent("UILabel")
	local guildLabel = ""
	if chatinfo.senderguildname ~= nil and chatinfo.senderguildname ~= "" then
		guildLabel = "[f1cf63]【".. chatinfo.senderguildname .. "】[-]"
	end
	chatName.text = guildLabel ..  "[ffffff]" ..  chatinfo.sender.name .. "[-]"

	local gov =item.transform:Find(System.String.Format("{0}/bg_title/bg_gov" , chatContent))
	if gov ~= nil then
		GOV_Util.SetGovNameUI(gov,chatinfo.sender.officialId,chatinfo.sender.guildOfficialId,true)
	end

	local chatTime = item.transform:Find(System.String.Format("{0}/bg_title/time" , chatContent)):GetComponent("UILabel")
	chatTime.text = Chat.GetChatTime(chatinfo.time)

	local chatGuildPos = item.transform:Find(System.String.Format("{0}/union_level" , chatContent)):GetComponent("UILabel")
	if tonumber(chatinfo.sender.guildMemPosition) == 0 then
		chatGuildPos.gameObject:SetActive(false)
	else
		local levelText = TableMgr:GetUnionPrivilege(tonumber(chatinfo.sender.guildMemPosition)).name
		--chatGuildPos.text = System.String.Format(TextMgr:GetText("UnionMessage_7"), chatinfo.sender.guildMemPosition)
		chatGuildPos.text = TextMgr:GetText(TableMgr:GetUnionPrivilege(tonumber(chatinfo.sender.guildMemPosition)).name)
	end	

	-- if chatinfo.transtext == nil or chatinfo.transtext == "" then -- 未获得翻译结果
	-- 	content.text = chatinfo.infotext
	-- 	return
	-- end

	SetClickCallback(touxiangBtn.gameObject , function()
		if MainData.GetCharId() == chatinfo.sender.charid then
			OtherInfo.RequestShow(chatinfo.sender.charid)
		else
			UnionMessageData.RequestGuildMessageBoardBacklist(function() 
				ItemDetail(chatinfo)
			end)			
		end 
	end)
	
	SetClickCallback(transBtn.gameObject , function()
		translatebg.gameObject:SetActive(false)
		traning.gameObject:SetActive(true)
		UnionMessageData.Translate(chatinfo.infotext, 1, function(text)
			if _ui == nil then 
				return
			end
			
			content.text = text			
			transBtn.gameObject:SetActive(false)
			srcBtn.gameObject:SetActive(true)
			traning.gameObject:SetActive(false)
			translatebg.gameObject:SetActive(true)
			translateText.text = TextMgr:GetText("chat_hint11")
			Chat.CalculateChatWidth(item.transform)			
		end)
	end)
	
	SetClickCallback(srcBtn.gameObject , function()
		srcBtn.gameObject:SetActive(false)
		transBtn.gameObject:SetActive(true)
		content.text = chatinfo.infotext
		translateText.text = TextMgr:GetText("chat_hint10")
		Chat.CalculateChatWidth(item.transform)
	end)
	

	translatebg.gameObject:SetActive(true)
	transBtn.gameObject:SetActive(true)
	srcBtn.gameObject:SetActive(false)
	translateText.text = TextMgr:GetText("chat_hint10")
	content.text = chatinfo.infotext
	
	return item.transform
end

function UpdateChatContent()
	addOldChatItemPos = 0
	addNewChatItemPos = 0	
	if _ui == nil then
		return
	end
	
	local chanelChat = nil
	if GuildId == UnionInfoData.GetGuildId() then
		ChatData.InitRecordIndex(ChatMsg_pb.chanel_guild_mboard)
		chanelChat = ChatData.GetChanelRecordChat(ChatMsg_pb.chanel_guild_mboard , 10)
		UnityEngine.PlayerPrefs.SetInt("UnionMessage", ChatData.GetChatDataLength(ChatMsg_pb.chanel_guild_mboard))
		MainCityUI.UpdateNotice()
		UnionInfo.UpdateUnionMessageRed()
	else
		ChatData.InitRecordIndex(400)
		chanelChat = ChatData.GetChanelRecordChat(400 , 10)
	end	
	
	if chanelChat == nil or #chanelChat <= 0 then
		_ui.Noitem:SetActive(true)
	else	
		local moveUp = 0		
		_ui.Noitem:SetActive(false)
		_ui.setCorount = coroutine.start(function()
			--addchild
			for _, v in pairs(chanelChat) do
				local chatitem = SetChatContent(v)
			end
			coroutine.step()
			--cal height 
			--等待一帧获取widget尺寸
			if _ui.Grid ~= nil then
				for i=0, _ui.Grid.transform.childCount-1 do
					local chatitem = _ui.Grid.transform:GetChild(i)
					Chat.CalculateChatWidth(chatitem)
					chatitem.transform.localPosition = Vector3(0,moveUp,0)
					moveUp = moveUp - Chat.CalculateChatHeight(chatitem)
				end
			end
			
			addNewChatItemPos = moveUp

			coroutine.step()
			if _ui.ScrollView ~= nil then
				_ui.ScrollView:UpdatePosition()
				_ui.ScrollView.verticalScrollBar.value = 1
			end
		end)
	end	
end



function HasRedPoint()
	local count = UnityEngine.PlayerPrefs.GetInt("UnionMessage")
	if count < ChatData.GetChatDataLength(ChatMsg_pb.chanel_guild_mboard) then
		return true
	else
		return false
	end
end

function UpdateRecordChatInfo()
	local chatcount = _ui.Grid .transform.childCount
	local chanelChat = nil
	if GuildId == UnionInfoData.GetGuildId() then
		chanelChat = ChatData.GetChanelRecordChat(ChatMsg_pb.chanel_guild_mboard , 10)	
	else
		chanelChat = ChatData.GetChanelRecordChat(400 , 10)	
	end
	local additem = {}
	local addoldchat = addOldChatItemPos
	_ui.setUpdateCorount = coroutine.start(function()
		for _, v in pairs(chanelChat) do
			local chatitem = SetChatContent(v)	
			table.insert(additem , chatitem.transform)
		end
		
		coroutine.step()
		for i=0 , #additem-1 do --从后往前添加
			local v = additem[#additem - i]
			Chat.CalculateChatWidth(v)
			addoldchat = addoldchat + Chat.CalculateChatHeight(v)
			addOldChatItemPos = addoldchat
			v.localPosition = Vector3(0,addoldchat,0)
		end
		coroutine.step()
		--chatContentList.scrollView:UpdatePosition()
	end)
end

function OnDrag()
	if _ui.ScrollView.transform.localPosition.y < -50 - addOldChatItemPos then
		_ui.ScrollViewOnDrag.gameObject:SetActive(true)
		local offsety = addOldChatItemPos + 200
		_ui.ScrollViewOnDrag.localPosition = Vector3(0, offsety , 0 )
		ReqChatRecord = true
	end
end

function OnDragFinish()
	if ReqChatRecord then
		ReqChatRecord = false
		_ui.ScrollViewOnDrag.gameObject:SetActive(false)
		UpdateRecordChatInfo()
	end
end

function Awake()
	_ui = {}
	_ui.Management = transform:Find("Management").gameObject
	_ui.Close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	_ui.Manage = transform:Find("Container/bg_frane/bg_top/btn_manage").gameObject
	_ui.ChatContent = transform:Find("Container/bg_frane/bg_bottom/frame_input"):GetComponent("UIInput")	
	_ui.ScrollViewOnDrag = transform:Find("Container/bg_frane/Scroll View/bg_juhua")
	_ui.ScrollView = transform:Find("Container/bg_frane/Scroll View"):GetComponent("UIScrollView")
	_ui.Grid = transform:Find("Container/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.Noitem = transform:Find("Container/bg_frane/bg_mid/bg_noitem").gameObject
	_ui.Send = transform:Find("Container/bg_frane/bg_bottom/btn_send").gameObject
	_ui.ChatInfo = transform:Find("ChatInfo").gameObject
	_ui.noitem = transform:Find("Container/bg_frane/bg_mid/bg_noitem")
	_ui.Mask = transform:Find("Container").gameObject
	SetClickCallback(_ui.Mask, function()
		Hide()
	end)
	SetClickCallback(_ui.Close, function()
		Hide()
	end)
	SetClickCallback(_ui.Manage, function()		
		Management()
	end)
	SetClickCallback(_ui.Send, function()		
		if _ui.ChatContent.value == "" then
			FloatText.Show(TextMgr:GetText("chat_hint5") , Color.white)
			return
		end
		SendContent()
	end)		
	
	if GuildId == UnionInfoData.GetGuildId() then
		UpdateChatContent()
		_ui.ScrollView.onDragMove =  OnDrag
		_ui.ScrollView.onDragFinished = OnDragFinish
		ChatData.AddListener(NotifyChanelChat)
	else
		_ui.Manage:SetActive(false)
		UnionMessageData.RequestUnionMessageChatInfo(GuildId, function()
			UpdateChatContent()
			_ui.ScrollView.onDragMove =  OnDrag
			_ui.ScrollView.onDragFinished = OnDragFinish
			ChatData.AddListener(NotifyChanelChat)
		end)
	end
	
	
end

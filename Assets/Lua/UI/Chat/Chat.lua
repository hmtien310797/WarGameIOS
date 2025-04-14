module("Chat", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String
local GameObject = UnityEngine.GameObject
local Common_pb = require("Common_pb")


local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local fileRecorder = Global.GFileRecorder 

local curChanel
local bg_tab
local bg_bottom
local bg_mid
local bg_top
local chatContentList
local chatLock
local chatInfoBox
local privateShare
local privateChat

local translateCoroutine = nil
local translateMap = nil
local translateMapCount = 0
local translateTryCount = 3
local translateTryWait = 2
local translateWaiting = false

local addNewChatItemPos = 0
local addOldChatItemPos = 0

local panel_box

local translateContent
local ReqChatRecord = false
local UpdatePrivatePlaterContent
local UpdatePrivateContent

local UpdateDiscGroupContent
local RallyCount
local MaxRallyCount
local recvList
local _ui

local groupDataMap
CloseCallBack = nil


local isNewPrivateMessageViewed = false

function HasNewPrivateMessageViewed()
	return isNewPrivateMessageViewed
end

function NotifyNewPrivateMessage()
	isNewPrivateMessageViewed = false
end

function CloseMail()
	--GUIMgr:CloseMenu("Mail")
	Mail.CloseUI()
end

function SetPrivateChat(name , charid , banner , offid, guildOfficialId)
	if privateChat == nil then
		privateChat = {}
	end
	privateChat.name = name
	privateChat.charid = charid
	privateChat.banner = banner
	privateChat.offid = offid
	privateChat.guildOfficialId = guildOfficialId
end

function SetPrivateShare(shareContent)
	
	privateShare = shareContent

end

local function UpdateTabRedPoint()
	local new = ChatData.GetUnreadPrivateCount()
	local groupnew = GroupChatData.GetUnReadGroupCount(MainData.GetCharId())
	
	bg_tab.privateRed.gameObject:SetActive(new + groupnew > 0)
	bg_tab.privateRed:Find("num"):GetComponent("UILabel").text = new + groupnew
	
	local guildNew = ChatData.GetUnreadGuildCount(0)
	bg_tab.guildRed.gameObject:SetActive(guildNew > 0 and curChanel ~= ChatMsg_pb.chanel_guild )
	bg_tab.guildRed:Find("num"):GetComponent("UILabel").text = guildNew
	if curChanel == ChatMsg_pb.chanel_guild then
		ChatData.SetUnreadGuildCount(0)
	end
end

function GoMap(posx , posy)
	if GUIMgr:IsMainCityUIOpen() then
		GUIMgr:ActiveMainCityUI()
	end
	
	MainCityUI.ShowWorldMap(posx, posy, true)
end

function GetChatTime(chatTime) 
	local cTime = ""
	
	-- local passSec = Serclimax.GameTime.GetSecTime() - serverTimeSec
	cTime = Global.SecondToStringFormat(chatTime , "yyyy-MM-dd HH:mm:ss")
	
	--[[
	local pass = math.floor((Serclimax.GameTime.GetSecTime() - chatTime) / (60*60*24))
	--自然天
	local pass1 = Global.Datediff(Serclimax.GameTime.GetSecTime() , chatTime)
	if pass1 > 0 then
		if pass1 >= 7 then
			cTime = System.String.Format(TextMgr:GetText("chat_hint9") , pass1)
		else
			cTime = System.String.Format(TextMgr:GetText("chat_hint8") , pass1)
		end
	else
		cTime = Serclimax.GameTime.SecondToStringHHMM(chatTime)
	end]]--
	return cTime
end

function TranslateContentOld(trinfo)
	translateContent.btnTween.enabled = true;
	translateContent.btnTween:Play(true, true)

	--请求翻译文本
	local req = ClientMsg_pb.MsgTranslateTextRequest()
	req.id = trinfo.id
	req.text = trinfo.content
	req.languageCode = Global.GTextMgr:GetCurrentLanguageID()
    LuaNetwork.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgTranslateTextRequest, req:SerializeToString(), function(typeId, data)
		local msg = ClientMsg_pb.MsgTranslateTextResponse()
		msg:ParseFromString(data)
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		else
			--防止在翻译结果回来之前关掉聊天界面
			if trinfo.go.gameObject ~= nil and not trinfo.go:Equals(nil) then
				translateContent.btnTween.enabled = false;
				
				local transCoroutin = coroutine.start(function()
					local content = trinfo.go.transform:Find(System.String.Format("{0}/text" , trinfo.box)):GetComponent("UILabel")
					content.text = msg.text
					
					local translateText = trinfo.go.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/text"  , trinfo.box)):GetComponent("UILabel")
					translateText.text = TextMgr:GetText("chat_hint11")
					coroutine.step()
					CalculateChatWidth(trinfo.go.transform)
					SetClickCallback(trinfo.btn.gameObject , function()
						CheckSourceText(trinfo)
					end)
				end)
			end
		end 
    end , false)
end


--手动请求翻译
---[[
function ReqTranslateGetUserContent(reqContent , reqLang, reqCount , resultcallback)
	
	if reqCount > 3 then
		resultcallback(reqCount  , nil)
		return
	else
		coroutine.start(function()
			coroutine.wait(2)
			
			reqCount = reqCount + 1
			local req = ChatMsg_pb.MsgUserTranslateTextRequest()
			req.clientLang = reqLang
			req.text:append(reqContent)
			Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgUserTranslateTextRequest, req, ChatMsg_pb.MsgUserTranslateTextResponse, function(msg)
				local transData = msg.data[1]
				if transData ~= nil and transData.text ~= nil and transData.text ~= "" and not transData.waitTranslate then
					resultcallback(reqCount , transData.text)
				else
					ReqTranslateGetUserContent(reqContent , reqLang, reqCount , resultcallback)
				end
			end , true)
		end)
	end
	
	
end
--]]

--[[function ReqTranslateGetUserContent(reqContent , reqLang , resultcallback)
	local transCoroutin = coroutine.start(function()
		local req = ChatMsg_pb.MsgUserTranslateTextRequest()
		req.clientLang = reqLang
		req.text:append(reqContent)
		for i=1 , 3 , 1 do
			Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgUserTranslateTextRequest, req, ChatMsg_pb.MsgUserTranslateTextResponse, function(msg)
				local transData = msg.data[1]
				if transData ~= nil and transData.text ~= nil and transData.text ~= "" and not transData.waitTranslate then
					resultcallback(reqCount , transData.text)
					coroutine.stop(transCoroutin)
					
				else
					coroutine.resume(transCoroutin)
				end
			end)
			coroutine.yield()
			coroutine.wait(1)
		end
	end)	
end]]

--[[
local requestFunc = function()
	for i = 1, 3 do
		local req = ChatMsg_pb.MsgUserTranslateTextRequest()
		req.clientLang = reqLang
		req.text:append(reqContent)
		Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgUserTranslateTextRequest, req, ChatMsg_pb.MsgUserTranslateTextResponse, function(msg)
			local transData = msg.data[1]
			if transData ~= nil and transData.text ~= nil and transData.text ~= "" and not transData.waitTranslate then
				resultcallback(reqCount , transData.text)
			else
				--ReqTranslateGetUserContent(reqContent , reqLang, reqCount , resultcallback)
				coroutine.resume(requestCoroutine)
				
			end
		end)
		coroutine.yield()
		coroutine.wait(2)
	end

coroutine.resume(requestCoroutine)]]
function TranslateContent(trinfo)
	local transCoroutin = coroutine.start(function()
		local content = trinfo.go.transform:Find(System.String.Format("{0}/text" , trinfo.box)):GetComponent("UILabel")
		content.text = trinfo.content
		
		local translateText = trinfo.go.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/text"  , trinfo.box)):GetComponent("UILabel")
		translateText.text = TextMgr:GetText("chat_hint10")
		coroutine.step()
		CalculateChatWidth(trinfo.go.transform)
		SetClickCallback(trinfo.btn.gameObject , function()
			CheckSourceText(trinfo)
		end)
	end)
end

function CheckSourceText(trinfo)
	local transCoroutin = coroutine.start(function()
		local content = trinfo.go.transform:Find(System.String.Format("{0}/text" , trinfo.box)):GetComponent("UILabel")
		content.text = trinfo.content
		
		local translateText = trinfo.go.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/text"  , trinfo.box)):GetComponent("UILabel")
		translateText.text = TextMgr:GetText("chat_hint10")
		coroutine.step()
		CalculateChatWidth(trinfo.go.transform)
		SetClickCallback(trinfo.btn.gameObject , function()
			TranslateContent(trinfo)
		end)
	end)
end

function CheckPlayerInfo()
	--print(panel_box.name)
	--[[local nameLegalReq = ClientMsg_pb.MsgCheckNameExitRequest()
	nameLegalReq.name = panel_box.name
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCheckNameExitRequest, nameLegalReq, ClientMsg_pb.MsgCheckNameExitResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
			return
		else
			Mail.SetJumMenu("MailNew")
			local sendMailData = {}
			sendMailData.fromname = panel_box.name--chatinfo.sender.name
			MailNew.SetMailData(sendMailData)
			MailNew.SetCloseCallBack(CloseMail)
			GUIMgr:CreateMenu("Mail" , false)
			
			if panel_box.go.gameObject.activeSelf then
				panel_box.go.gameObject:SetActive(false)
			end
		end
	end)]]
	--Mail.SetJumMenu("MailNew")
	--local sendMailData = {}
	--sendMailData.fromname = panel_box.name--chatinfo.sender.name
	--MailNew.SetMailData(sendMailData)
	--MailNew.SetCloseCallBack(CloseMail)
	--GUIMgr:CreateMenu("Mail" , false)
	--Mail.Show()
	Mail.SimpleWriteTo(panel_box.name)
	
	if panel_box.go.gameObject.activeSelf then
		panel_box.go.gameObject:SetActive(false)
	end
end

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	
	--[[local str = go.gameObject.name:split("_")
	if #str == 3 and str[1] == "playerBtn" then
		if str[2] == "left" then
			OtherInfo.RequestShow(tonumber(str[3]))
		end
	end
	]]
	--[[if #str > 2 and str[1] == "playerBtn" then
		local offset = 100
		if str[2] == "left" then
			if not panel_box.go.gameObject.activeSelf then
				panel_box.go.gameObject:SetActive(true)
			end
			panel_box.go.transform.position = Vector3(go.transform.position.x  + 0.6, go.transform.position.y ,go.transform.position.z)
			panel_box.name = str[3]
			for i=4 , #str do
				panel_box.name = panel_box.name .."_".. str[i]
			end
			print(panel_box.name)
		end
	elseif go.gameObject.name == "btn_information" then
		CheckPlayerInfo()
	elseif go.gameObject.name == "btn_copy" then
		AudioMgr:PlayUISfx("SFX_ui01", 1, false)
		FloatText.Show("复制成功" , Color.white)
		panel_box.go.gameObject:SetActive(false)
		
		print(panel_box.name)
		NGUITools.clipboard = panel_box.name
		print(NGUITools.clipboard)
	else
		if panel_box.go.gameObject.activeSelf then
			panel_box.go.gameObject:SetActive(false)
			panel_box.name = ""
		end
	end]]
	
end


function CalculateChatWidth(chatItem)
	if chatItem.gameObject == nil or chatItem.gameObject:Equals(nil) then
		return
	end

	local item = chatItem
	local chattype = item.gameObject.name:split("_")[2]
	
	local bgName = "left"
	if not item:Find(bgName).gameObject.activeSelf then
		bgName = "right"
	end
	
	if tonumber(chattype) ~= 1 then
		return
		
	end
	--计算气泡宽度
	local name = item:Find(System.String.Format("{0}/bg_title/name" , bgName)):GetComponent("UILabel")
	local chatTime = item:Find(System.String.Format("{0}/bg_title/time" , bgName)):GetComponent("UILabel")
	-- local msgCollider = item:Find(System.String.Format("{0}/bg_msg" , bgName)):GetComponent("BoxCollider")
	-- local titleVip = item:Find(System.String.Format("{0}/bg_touxiang/bg_vip" , bgName)):GetComponent("UIWidget")
	local gov = item:Find(System.String.Format("{0}/bg_title/bg_gov", bgName)):GetComponent("UIWidget")
	local govIcon = item:Find(System.String.Format("{0}/bg_title/bg_gov/gov_icon" , bgName)):GetComponent("UITexture")
	local govText = item:Find(System.String.Format("{0}/bg_title/bg_gov/text" , bgName)):GetComponent("UILabel")
	local titleLength = --[[titleVip.width +]] name:textWidth() + chatTime.width --[[+ gov.width]] + govText:textWidth() + govIcon.width

	local content = item:Find(System.String.Format("{0}/text" , bgName)):GetComponent("UILabel")
	local translate = item:Find(System.String.Format("{0}/bg_msg/bg_translate/btn_translate" , bgName)):GetComponent("UISprite")
	local translateText = item:Find(System.String.Format("{0}/bg_msg/bg_translate/text" , bgName)):GetComponent("UILabel")
	
	local translateLength = translateText:textWidth() + translate.width
	local contentLength = math.min(530, math.max(content:textWidth(), translateLength))

	item:Find(System.String.Format("{0}/bg_msg" , bgName)):GetComponent("UISprite").width = math.max(titleLength , contentLength) + 30
	
	-- print("------------------------------------------------------------------")
	-- print("content :" .. content.text)
	-- print("conlen :" .. Global.GetTextWidth(content.text ,content.fontSize ))
	-- print("conlen1 :" .. content:textWidth())
	-- print(titleLength, contentLength, math.max(titleLength , contentLength))
	-- print("------------------------------------------------------------------")
end

function CalculateChatHeight(chatItem)
	local item = chatItem
	local bgName = "left"
	if not item:Find(bgName).gameObject.activeSelf then
		bgName = "right"
	end
	
	
	local msgBox = item:Find(System.String.Format("{0}/bg_msg" , bgName)):GetComponent("UISprite")
	return msgBox.height + 20
end

function GetSystemChatInfoContent(infotext)
	local contentText = ""
	local contentStr = string.split(infotext , ",")
	--配置的参数个数
	if #contentStr > 1 then
		local text = TextMgr:GetText(contentStr[1])
		local params = {}
		for w in string.gmatch(text , "{%d}") do
			params[#params + 1] = w
		end
		
		local contentParam = {}
		--实际的参数个数
		for i=2 , #contentStr , 1 do
			local paramStr = string.split(contentStr[i] , ":")
			local str = ""
			if #paramStr == 2 then
				str = paramStr[1]
				if str == "text" then
					str = TextMgr:GetText(paramStr[2])
				else
					str = paramStr[2]
				end
			else
				str = paramStr[1]
			end
			table.insert(contentParam , str)
		end
		
		--补足缺少的参数
		for i=#contentParam , #params , 1 do
			table.insert(contentParam , "xxx")
		end
		
		contentText = GUIMgr:StringFomat(text, contentParam)
	else
		contentText = TextMgr:GetText(contentStr[1])
	end
	return contentText
end

local function SetChatInfoSystem(chatinfo, chatContent , item)
	
	item.gameObject:SetActive(true)
	item.gameObject.name = chatinfo.time .. "_" .. chatinfo.type 
	item.transform:SetParent(chatContentList.grid.transform , false)
	
	local content = item.transform:Find("left/bg_msg/text"):GetComponent("UILabel")
	content.text = GetSystemChatInfoContent(chatinfo.infotext) .. "  " .. GetChatTime(chatinfo.time)
	
	SetClickCallback(item.gameObject , function()
		local url = content:GetUrlAtPosition(UICamera.lastWorldPosition)
		local paramStr = string.split(chatinfo.spectext , ",")
		--url = "jumppos,3"
		--print(content.text  , url)
		if url == nil then
			return
		end
		
		local param = {}
		for i=1 , #(paramStr) ,1 do
			local sv = string.split(paramStr[i] ,":")
			if sv[1] == "d" then
				table.insert(param , tonumber(sv[2]))
			else
				table.insert(param , sv[2])
			end
		end
		
		
		local str = string.split(url , ",") 
		if str[1] == "jump" then
			--print("jump" , str[2])
			if tonumber(str[2]) == 0 then
				assert(Global.GetTableFunction(str[3]))()
			elseif tonumber(str[2]) == 1 then
				assert(Global.GetTableFunction(string.format(str[3],param[1])))()
			elseif tonumber(str[2]) == 2 then
				assert(Global.GetTableFunction(string.format(str[3],param[1],param[2])))()
			elseif tonumber(str[2]) == 3 then
				assert(Global.GetTableFunction(string.format(str[3],param[1],param[2],param[3])))()
			end
			
			GUIMgr:CloseMenu("Chat")
		end

	end)
end

local function SetChatInfoUnionInvitation(chatinfo, chatContent , item)
	local str = chatinfo.spectext:split(",")
	local guildLabel = item.transform:Find(System.String.Format("{0}/bg_msg/mid/union_name" , chatContent)):GetComponent("UILabel")
	guildLabel.text = "【" .. str[1] .. "】" .. str[2]
	
	local fightLabel = item.transform:Find(System.String.Format("{0}/bg_msg/mid/icon_power/num" , chatContent)):GetComponent("UILabel")
	fightLabel.text = str[3]

	local memberLabel = item.transform:Find(System.String.Format("{0}/bg_msg/mid/icon_num/num" , chatContent)):GetComponent("UILabel")
	memberLabel.text = str[4]
	
	if #str >= 5 then
		local badgeWidget = {}
		badgeWidget.borderTexture = item.transform:Find(System.String.Format("{0}/bg_msg/mid/icon bg/outline icon" , chatContent)):GetComponent("UITexture")
		badgeWidget.colorTexture = item.transform:Find(System.String.Format("{0}/bg_msg/mid/icon bg/outline icon/color" , chatContent)):GetComponent("UITexture")
		badgeWidget.totemTexture = item.transform:Find(System.String.Format("{0}/bg_msg/mid/icon bg/totem icon" , chatContent)):GetComponent("UITexture")
		UnionBadge.LoadBadgeById(badgeWidget, tonumber(str[5]))
	end
	
	if #str >= 6 then
		local invitationLabel = item.transform:Find(System.String.Format("{0}/bg_msg/text" , chatContent)):GetComponent("UILabel")
		invitationLabel.text = TextMgr:GetText("union_invite_text" .. str[6])
	end
	
	if #str >= 7 then
		local msgCB = item.transform:Find(System.String.Format("{0}/bg_msg" , chatContent))
		SetClickCallback(msgCB.gameObject , function()
			UnionPubinfo.RequestShow(tonumber(str[7]))
		end)
	end
	
	if #str >= 8 then
		local lanicon = item.transform:Find(System.String.Format("{0}/bg_msg/mid/union_name/Texture" , chatContent)):GetComponent("UITexture")
		lanicon.mainTexture = ResourceLibrary:GetIcon("Icon/Union/" ,str[8] ) 
	end
end

local function SetChatInfoRallyInvitation(chatinfo, chatContent , item)	
	local gov =item.transform:Find(chatContent.."/bg_title (1)/bg_gov")	
	gov.gameObject:SetActive(true)
	if gov ~= nil then
		GOV_Util.SetGovNameUI(gov,chatinfo.sender.officialId,chatinfo.sender.guildOfficialId,true)	
	end
	local str = chatinfo.spectext:split(",")
	local rally = {}
	rally.touxiang = item.transform:Find(chatContent.."/bg_msg/mid/head_bg02/icon"):GetComponent("UITexture")
	rally.unionname = item.transform:Find(chatContent.."/bg_msg/mid/head_bg02/union_name"):GetComponent("UILabel")
	rally.name = item.transform:Find(chatContent.."/bg_msg/mid/head_bg02/name_02"):GetComponent("UILabel")
	rally.playericon = item.transform:Find(chatContent.."/bg_msg/mid/bg_name/head_bg01/icon"):GetComponent("UITexture")
	rally.playerunionname = item.transform:Find(chatContent.."/bg_msg/mid/bg_name/union_name"):GetComponent("UILabel")
	rally.playername = item.transform:Find(chatContent.."/bg_msg/mid/bg_name/name_02"):GetComponent("UILabel")
	rally.player = item.transform:Find(chatContent.."/bg_title (1)/name"):GetComponent("UILabel")
	rally.time = item.transform:Find(chatContent.."/bg_msg/mid/bg_exp/bg/text"):GetComponent("UILabel")
	rally.timeslider = item.transform:Find(chatContent.."/bg_msg/mid/bg_exp/bg/bar"):GetComponent("UISlider")
	rally.msg = item.transform:Find(chatContent.."/bg_msg")
	-- rally.number = item.transform:Find(chatContent.."/bg_msg/mid/Troops/num"):GetComponent("UILabel")
	rally.exp = item.transform:Find(chatContent.."/bg_msg/mid/bg_exp")
	rally.timeend = item.transform:Find(chatContent.."/bg_msg/mid/txt"):GetComponent("UILabel")
	rally.touxiang.mainTexture =  ResourceLibrary:GetIcon("Icon/head/", str[1]) --ResourceLibrary:GetIcon("Icon/head/", chatinfo.sender.face)
	if chatinfo.gm then
		rally.playericon.mainTexture = ResourceLibrary:GetIcon("Icon/head/", "GM")
		GOV_Util.SetFaceUI(item.transform:Find(chatContent.."/bg_msg/mid/head_bg02/MilitaryRank"),nil)
	else
		rally.playericon.mainTexture = ResourceLibrary:GetIcon("Icon/head/", chatinfo.sender.face)
		GOV_Util.SetFaceUI(item.transform:Find(chatContent.."/bg_msg/mid/head_bg02/MilitaryRank"),chatinfo.sender.militaryRankId)
	end
	rally.unionname.text = str[2]
	rally.name.text = str[3]
	rally.Totalltime = str[4] - str[5]
	rally.playerunionname.text = "["..str[9].."]"
	rally.playername.text = str[10]
	rally.player.text = "["..str[9].."]"..str[10]
	-- rally.number.text = str[6].."/"..str[7]
	if tonumber(str[5]) < Serclimax.GameTime.GetSecTime() then
		if tonumber(str[4]) < Serclimax.GameTime.GetSecTime() then
			rally.exp.gameObject:SetActive(false)
			rally.timeend.gameObject:SetActive(true)
			rally.timeend = TextMgr:GetText("ui_rally_departed")
		else
			RallyCount = RallyCount + 1
			if RallyCount > MaxRallyCount then
				MaxRallyCount = RallyCount
			end

			CountDown.Instance:Add("Rally"..RallyCount, str[4], CountDown.CountDownCallBack(function(t)
				if rally ~= {} then
					if rally.exp ~= nil and rally.timeend ~= nil and rally.time ~= nil and rally.timeslider ~= nil then
						if t == "00:00:00" then
							rally.exp.gameObject:SetActive(false)
							rally.timeend.gameObject:SetActive(true)
							rally.timeend.text = TextMgr:GetText("ui_rally_departed")
						else
							rally.time.text = t
							rally.timeslider.value = (Serclimax.GameTime.GetSecTime() - str[5]) / rally.Totalltime
						end
					end
				end
			end))
		end
	end

	SetClickCallback(rally.msg.gameObject,function(go) 
		if tonumber(str[4]) < Serclimax.GameTime.GetSecTime() then
			FloatText.Show(TextMgr:GetText("ui_rally_departed"))
			return
		end
		local join = {}
		join.charid = tonumber(str[8])
		MassTroops.join = join
		UnionWar.Show()
		GUIMgr:CloseMenu("Chat")
	end)
end

local function SetChatInfoBattleReport(chatinfo, chatContent , item)
	local transBtn = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/btn_translate" , chatContent)):GetComponent("UIButton")
	local translateText = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/text" , chatContent)):GetComponent("UILabel")
	local srcBtn = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/btn_src" , chatContent))
	local traningBg = item.transform:Find(System.String.Format("{0}/bg_msg/bg_traning" , chatContent))
	local transBg = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate" , chatContent))
	translateText.text = TextMgr:GetText("chat_hint10")
	
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
	
	--chatName.text = chatinfo.sender.name
	
	local reportTile = item.transform:Find(System.String.Format("{0}/text" , chatContent)):GetComponent("UILabel")
	local reportContent = item.transform:Find(System.String.Format("{0}/content" , chatContent)):GetComponent("UILabel")
	local str = chatinfo.spectext:split(",")
	local reportId = str[1]
	reportContent.text = str[4]
	
	local pGuildName = ""
	if str[6] ~= nil then
		pGuildName = "[f1cf63]" .. str[6] .. "[-]"
	end
	local tGuildName = ""
	if str[7] ~= nil then
		tGuildName = "[f1cf63]" .. str[7] .. "[-]"
	end
	
	local playerName = ""
	if str[2] ~= nil then
		playerName = str[2]
	end
	
	local targetName = ""
	if str[3] ~= nil then
		targetName = str[3]
	end

	local fort = 0
	if str[8] ~= nil and tonumber(str[8]) ~= 0 then
		fort = tonumber(str[8]) 
		if fort == nil then
			fort = 0
		end
		targetName = TextMgr:GetText("FortArmyName_"..fort)
    end
	
	local mailSubType = Mail.MailReportType.MailReport_player
	if str[9] ~= nil then
		mailSubType = tonumber(str[9])
	end

	local gov = 5
	if str[10] ~= nil then
		gov = tonumber(str[10])
		if gov == 0 then
			targetName = targetName--TextMgr:GetText("GOV_ui7")
		elseif gov >=1 and gov <= 4 then
			targetName = TextMgr:GetText(TableMgr:GetTurretDataByid(gov).name)
		end                 
	end
	
	local strVs = " [ff0000]vs[-] "

	--print(str[6] , str[7] ,tGuildName , targetName , fort)

	reportTile.text =  playerName .. strVs ..  targetName

	--set chat widget height
	local bg_msg = item.transform:Find(System.String.Format("{0}/bg_msg" , chatContent)):GetComponent("UIWidget")
	if str[4] == nil or str[4] == "" then
		bg_msg.height = 65
	else
		bg_msg.height = 90
    end
	
	transBg.gameObject:SetActive(str[4] ~= "")
	SetClickCallback(item.transform:Find(System.String.Format("{0}/btn_replay" , chatContent)).gameObject ,function(go)
		print("view repot:" .. reportId)
		if mailSubType == Mail.MailReportType.MailReort_atkWorldCity then
			if Global.ForceUpdateVersion("ui_update_hint1") then
                return
            end
		end
		
		
		local reportData = {}
		reportData.reportId = tonumber(reportId)
		reportData.createtime = tonumber(str[5])
		reportData.subtype = mailSubType
		if fort > 0 then
		    reportData.subtype = Mail.MailReportType.MailReport_fort
		end
		Mail_share.Show(reportData)
	end)
	
	SetClickCallback(transBtn.gameObject , function()
		traningBg.gameObject:SetActive(true)
		transBg.gameObject:SetActive(false)

		--print("=============Req:" , str[4])
		ReqTranslateGetUserContent(str[4] , GUIMgr:GetSystemLanguage() , 0 , function(reqCount , transResult)
			--print("+++++++++++++++++++++++" , reqCount , transResult)
			if item.gameObject ~= nil and not item.gameObject:Equals(nil) then
				traningBg.gameObject:SetActive(false)
				transBg.gameObject:SetActive(true)
				transBtn.gameObject:SetActive(transResult == nil)
				srcBtn.gameObject:SetActive(transResult ~= nil)
				translateText.text = transResult == nil and TextMgr:GetText("chat_hint10") or TextMgr:GetText("chat_hint11")
				reportContent.text = transResult == nil and str[4] or transResult
			end
		end)
	end)
	
	SetClickCallback(srcBtn.gameObject , function()
		translateText.text = TextMgr:GetText("chat_hint10")
		transBtn.gameObject:SetActive(true)
		srcBtn.gameObject:SetActive(false)
		reportContent.text = str[4]
	end)
end

--[[local function FormatCoodinateContent(str)
	local content {}
	local str = chatinfo.spectext:split(",")
	for i , k in pairs(str) do
		content[i] = str[i]
	end
	
end]]

local function SetChatInfoCoordinateContent(chatinfo , chatContent , item)
	local content = item.transform:Find(System.String.Format("{0}/text" , chatContent)):GetComponent("UILabel")
	local coordinate = item.transform:Find(System.String.Format("{0}/coordinate" , chatContent)):GetComponent("UILabel")
	local content1 = item.transform:Find(System.String.Format("{0}/text (1)" , chatContent)):GetComponent("UILabel")

	local transBtn = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/btn_translate" , chatContent)):GetComponent("UIButton")
	local translateText = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/text" , chatContent)):GetComponent("UILabel")
	local srcBtn = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/btn_src" , chatContent))
	local traningBg = item.transform:Find(System.String.Format("{0}/bg_msg/bg_traning" , chatContent))
	local transBg = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate" , chatContent))
	local str = chatinfo.spectext:split(",")
	
	translateText.text = TextMgr:GetText("chat_hint10")--"翻译"
	content.text = str[5]
	local strFormat = coordinate.text
	coordinate.text = System.String.Format(strFormat , "1" , str[1] , str[2])
	content1.text = str[4]

	if str[4] == nil or str[4] == "" then
		item.transform:Find(System.String.Format("{0}/bg_msg/" , chatContent)):GetComponent("UISprite").height = 105
	else
		item.transform:Find(System.String.Format("{0}/bg_msg/" , chatContent)):GetComponent("UISprite").height = 145
    end
	
	local coordIcon = item.transform:Find(System.String.Format("{0}/bg_msg/bg_icon/Texture" , chatContent)):GetComponent("UITexture")
	coordIcon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", str[3])
	
	SetClickCallback(coordinate.gameObject , function(go)
		print("click pos coordinate")
		--jump to worldmap
			FunctionListData.IsFunctionUnlocked(101, function(isactive)
				if not isactive then
					FloatText.Show(TextMgr:GetText(TableMgr:GetFunctionUnlockText(101)), Color.white)
				else
					GoMap(tonumber(str[1]), tonumber(str[2]))
					--MainCityUI.ShowWorldMap(tonumber(str[1]), tonumber(str[2]), true)
					GUIMgr:CloseMenu("Chat")
				end
			end)
		
	end)
	
	transBg.gameObject:SetActive(str[4] ~= "")
	SetClickCallback(transBtn.gameObject , function()
		traningBg.gameObject:SetActive(true)
		transBg.gameObject:SetActive(false)

		--print("=============Req:" , str[4])
		ReqTranslateGetUserContent(str[4] , GUIMgr:GetSystemLanguage() , 0 , function(reqCount , transResult)
			--print("+++++++++++++++++++++++" , reqCount , transResult)
			if item.gameObject ~= nil and not item.gameObject:Equals(nil) then
				traningBg.gameObject:SetActive(false)
				transBg.gameObject:SetActive(true)
				transBtn.gameObject:SetActive(transResult == nil)
				srcBtn.gameObject:SetActive(transResult ~= nil)
				translateText.text = transResult == nil and TextMgr:GetText("chat_hint10") or TextMgr:GetText("chat_hint11")
				content1.text = transResult == nil and str[4] or transResult
			end
		end)
	end)
	
	SetClickCallback(srcBtn.gameObject , function()
		translateText.text = TextMgr:GetText("chat_hint10")
		transBtn.gameObject:SetActive(true)
		srcBtn.gameObject:SetActive(false)
		content1.text = str[4]
	end)
	
end

local function SetChatInfoExistTest(chatinfo, chatContent, item)
	local rootTransform = item.transform:Find(chatContent)

	local str = chatinfo.spectext:split(",")

	rootTransform:Find("bg_msg/mid/txt"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText("ExistTest_7"), str[1])

	SetClickCallback(rootTransform:Find("bg_msg/mid/button").gameObject , function()
		ExistTest.SetSearchCharId(tonumber(str[2]))
		ExistTest.Show()
	end)
end

local function SetContentManualTranslate(chatinfo,chatContent, item)
	local content = item.transform:Find(System.String.Format("{0}/text" , chatContent)):GetComponent("UILabel")
	local transBtn = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/btn_translate" , chatContent)):GetComponent("UIButton")
	local translateText = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/text" , chatContent)):GetComponent("UILabel")
	local srcBtn = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/btn_src" , chatContent))
	local traningBg = item.transform:Find(System.String.Format("{0}/bg_msg/bg_traning" , chatContent))
	local transBg = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate" , chatContent))
	
	transBg.gameObject:SetActive(true)
	srcBtn.gameObject:SetActive(false)
	content.text = chatinfo.infotext
	translateText.text = TextMgr:GetText("chat_hint10")
	
	SetClickCallback(transBtn.gameObject , function()
		traningBg.gameObject:SetActive(true)
		transBg.gameObject:SetActive(false)

		if chatinfo.transtext ~= nil and chatinfo.transtext ~= "" then
			traningBg.gameObject:SetActive(false)
			transBg.gameObject:SetActive(true)
			transBtn.gameObject:SetActive(false)
			srcBtn.gameObject:SetActive(true)
			translateText.text = TextMgr:GetText("chat_hint11")
			content.text = chatinfo.transtext
			return
		end
		--print("=============Req:" , str[4])
		ReqTranslateGetUserContent(chatinfo.infotext , GUIMgr:GetSystemLanguage() , 0 , function(reqCount , transResult)
			print("+++++++++++++++++++++++" , reqCount , transResult)
			if item.gameObject ~= nil and not item.gameObject:Equals(nil) then
				traningBg.gameObject:SetActive(false)
				transBg.gameObject:SetActive(true)
				transBtn.gameObject:SetActive(transResult == nil)
				srcBtn.gameObject:SetActive(transResult ~= nil)
				translateText.text = transResult == nil and TextMgr:GetText("chat_hint10") or TextMgr:GetText("chat_hint11")
				content.text = transResult == nil and chatinfo.infotext or transResult
			end
		end)
	end)
	
	SetClickCallback(srcBtn.gameObject , function()
		translateText.text = TextMgr:GetText("chat_hint10")
		transBtn.gameObject:SetActive(true)
		srcBtn.gameObject:SetActive(false)
		content.text = chatinfo.infotext
	end)
end

local function SetContentAutoTranslate(chatinfo,chatContent, item)
	local content = item.transform:Find(System.String.Format("{0}/text" , chatContent)):GetComponent("UILabel")
	local translatebg = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate" , chatContent))
	local translateText = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/text" , chatContent)):GetComponent("UILabel")

	local transBtn = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/btn_translate" , chatContent)):GetComponent("UIButton")
	local srcBtn = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/btn_src" , chatContent))

	--print(chatinfo.infotext , chatinfo.transtext)
	if chatinfo.transtext == nil or chatinfo.transtext == "" then -- 未获得翻译结果
		content.text = chatinfo.infotext
		return
	end
	
	SetClickCallback(transBtn.gameObject , function()
		transBtn.gameObject:SetActive(false)
		srcBtn.gameObject:SetActive(true)
		content.text = chatinfo.transtext
		translateText.text = TextMgr:GetText("chat_hint11")
		CalculateChatWidth(item.transform)
	end)
	
	SetClickCallback(srcBtn.gameObject , function()
		srcBtn.gameObject:SetActive(false)
		transBtn.gameObject:SetActive(true)
		content.text = chatinfo.infotext
		translateText.text = TextMgr:GetText("chat_hint10")
		CalculateChatWidth(item.transform)
	end)
	
	
	if chatinfo.infotext ~= chatinfo.transtext and ChatData.GetTranslateEnable() then
		if chatinfo.languagecode == GUIMgr:GetSystemLanguage() then
			--print("显示原文，有翻译按钮")
			translatebg.gameObject:SetActive(true)
			transBtn.gameObject:SetActive(true)
			srcBtn.gameObject:SetActive(false)
			translateText.text = TextMgr:GetText("chat_hint10")
			content.text = chatinfo.infotext
		else						
			--print("显示翻译后的文本，有显示原文按钮")
			translatebg.gameObject:SetActive(true)
			transBtn.gameObject:SetActive(false)
			srcBtn.gameObject:SetActive(true)
			translateText.text = TextMgr:GetText("chat_hint11")
			content.text = chatinfo.transtext
		end
	else
		--print("显示原文，没有按钮")
		content.text = chatinfo.infotext
	end
end

local function SetChatInfoNormalContentOld(chatinfo,chatContent, item)
	local content = item.transform:Find(System.String.Format("{0}/text" , chatContent)):GetComponent("UILabel")
	--文本客户端语言与自身客户端语言一致显示原文，否则显示翻译后的文本
	if chatinfo.clientlangcode == Global.GTextMgr:GetCurrentLanguageID() then
		content.text = chatinfo.infotext
	else
		content.text = chatinfo.transtext
	end
	
	--目前没有翻译功能，所以都显示内容原文2017/8/18
	content.text = chatinfo.infotext
	--
	
	--[[文本客户端语言与自身客户端语言一致
		并且文本自身语言(api)与自身客户端语言不一致。则显示翻译按钮
		
		否则显示查看原文
	
	local translate = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/btn_translate" , chatContent)):GetComponent("UISprite")
	local translateText = item.transform:Find(System.String.Format("{0}/bg_msg/bg_translate/text" , chatContent)):GetComponent("UILabel")
	
	if MainData.GetCharId() == chatinfo.sender.charid then
		translate.transform.parent.gameObject:SetActive(false)--不显示
	else
		local transBtn = translate.transform:GetComponent("UIButton")
		if Global.GTextMgr:GetCurrentLanguageID() == chatinfo.clientlangcode then
			translateText.text = TextMgr:GetText("chat_hint10")
			if Global.GTextMgr:GetCurrentLanguageID() ~= chatinfo.languagecode then -- 翻译
				translate.transform.parent.gameObject:SetActive(true)
				SetClickCallback(transBtn.gameObject , function()
					translateContent = {}
					translateContent.id = 1
					translateContent.content = chatinfo.infotext--原文本
					translateContent.go = item
					translateContent.box = chatContent
					translateContent.btn = transBtn
					translateContent.btnTween = transBtn.transform:GetComponent("TweenRotation")
					TranslateContent(translateContent)
					CalculateChatWidth(item.transform)
				end)
				
			else
				translate.transform.parent.gameObject:SetActive(false)--不显示
			end
		else
			if Global.GTextMgr:GetCurrentLanguageID() ~= chatinfo.languagecode then
				translateText.text = TextMgr:GetText("chat_hint11")
				translate.transform.parent.gameObject:SetActive(true)
				SetClickCallback(transBtn.gameObject , function()
					translateContent = {}
					translateContent.id = 1
					translateContent.content = chatinfo.infotext--原文本
					translateContent.go = item
					translateContent.box = chatContent
					translateContent.btn = transBtn
					translateContent.btnTween = transBtn.transform:GetComponent("TweenRotation")
					CheckSourceText(translateContent)
					CalculateChatWidth(item.transform)
				end)
			end
		end
	end
	]]
end

--------------------------------------------------


local function SetChatInfoNormalContent(chatinfo, chatContent , item)
	if ChatData.AutoTranslate() and ChatData.GetTranslateEnable() then
		SetContentAutoTranslate(chatinfo, chatContent , item)
		CheckTranslateInfo(item)
	else
		SetContentManualTranslate(chatinfo,chatContent, item)
	end
end


function TranslateChatContent()
	if translateMap == nil then
		translateMap = {}
	end
	
	if translateCoroutine ~= nil then
		coroutine.stop(translateCoroutine)
		translateCoroutine = nil
	end
	translateMapCount = 0
	
	if translateCoroutine == nil then
		translateCoroutine = coroutine.start(function()
			while true do
				local waitStep = 1
				if translateMapCount > 0 and not translateWaiting then
					coroutine.wait(1)
					translateWaiting = true
					local req = ChatMsg_pb.MsgGetTranslateTextInfoRequest()
					--print("-----------request translate.----------")
					for _ , v in pairs(translateMap) do
						if v ~= nil and v.md5 ~= nil then
							req.textVerify:append(v.md5)
							--print(string.format("============Request Translate Content MD5:%s , SRC_TEXT:%s , REQ_COUNT:%d , Language:%d" ,v.md5 , v.srcText, v.reqCount , GUIMgr:GetSystemLanguage()))
							
						end
					end
					
					req.clientLang = GUIMgr:GetSystemLanguage()
					
					Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgGetTranslateTextInfoRequest, req, ChatMsg_pb.MsgGetTranslateTextInfoResponse, function(msg)
						if translateMap ~= nil then
							for _ , k in ipairs(msg.data) do
								if translateMap[k.textVerify] ~= nil then
									local transCount = #translateMap[k.textVerify].tab or 0
									if k.text ~= nil and k.text ~= "" then
										for _ ,  vv in pairs(translateMap[k.textVerify].tab) do
											vv.data.transtext = k.text
											SetChatInfoNormalContent(vv.data , vv.chatContent , vv)
										end
										
										translateMap[k.textVerify].tab = nil
										translateMap[k.textVerify] = nil
										translateMapCount = translateMapCount - transCount
										--print(string.format("++++++++++++++Response MD5:%s , TRANSLATE_TEXT:%s " ,k.textVerify , k.text))
									else
										translateMap[k.textVerify].reqCount = translateMap[k.textVerify].reqCount + 1
										if translateMap[k.textVerify].reqCount > 3 then --同一内容请求了三次都没有翻译成功的话，就不在翻译了
											translateMap[k.textVerify].tab = nil
											translateMap[k.textVerify] = nil
											translateMapCount = translateMapCount - transCount
										end
									end
								end
							end
						end
						translateWaiting = false
					end , true)
				else
					coroutine.step()
				end
			end
		end)
	end
end

function CheckTranslateInfo(chatitem)
	local chatInfo = chatitem.data
	if chatInfo.transtext == nil or chatInfo.transtext == "" then --没有自动翻译，需要额外请求翻译
		local md5 = "trans_" .. GUIMgr:MD5_Encrypt(chatInfo.infotext) .. "_" ..GUIMgr:GetSystemLanguage()
		--local md5 = chatInfo.infotext
		if translateMap[md5] == nil then
			translateMap[md5] = {}
			translateMap[md5].md5 = md5
			translateMap[md5].tab = {}
			translateMap[md5].reqCount = 0
			translateMap[md5].srcText = chatInfo.infotext
			--print(translateMap[md5].md5 , chatInfo.infotext)
		end
		table.insert(translateMap[md5].tab , chatitem)
		translateMapCount = translateMapCount + 1
	end
end
-------------------
function SetChatInfo(chatinfo , grid)
	local item
	local contentGrid = grid == nil and chatContentList.grid or grid
	if chatinfo.type == 2 then -- 分享到聊天的大地图地块信息
		item = NGUITools.AddChild(contentGrid.gameObject , chatContentList.coordinateItem.gameObject)
	elseif chatinfo.type == 3 then -- 分享到聊天的大地图PVP信息
		item = NGUITools.AddChild(contentGrid.gameObject , chatContentList.pvpItem.gameObject)
	elseif chatinfo.type == 4 then -- 分享到聊天的系统自动信息
		item = NGUITools.AddChild(contentGrid.gameObject , chatContentList.autoSystem.gameObject)
		SetChatInfoSystem(chatinfo, chatContent , item)
		return item
	elseif chatinfo.type == 5 then
		item = NGUITools.AddChild(contentGrid.gameObject , chatContentList.unionInvitation.gameObject)
		--SetChatInfoUnionInvitation(chatinfo, chatContent , item)
		--return item
	elseif chatinfo.type == 6 then
		item = NGUITools.AddChild(contentGrid.gameObject, chatContentList.rallyinvitation.gameObject)
	elseif chatinfo.type == 7 then
		item = NGUITools.AddChild(contentGrid.gameObject, chatContentList.existtest.gameObject)
	else
		item = NGUITools.AddChild(contentGrid.gameObject, chatContentList.item.gameObject)
	end
	item.gameObject:SetActive(true)
	item.gameObject.name = chatinfo.time .. "_" .. chatinfo.type 
	item.transform:SetParent(contentGrid.transform , false)
	
	--print("-------" , chatinfo.sender.charid , MainData.GetCharId())
	local chatContent = "left"
	if MainData.GetCharId() == chatinfo.sender.charid then
		chatContent = "right"
	end
	
	--私聊开发时协议数据填充不全的临时保护
	if chatinfo.sender.viplevel == nil then
		chatinfo.sender.viplevel = 0 
		chatinfo.sender.officialId = 0
		chatinfo.sender.guildOfficialId = 0
		chatinfo.sender.face = 103
		print("私聊开发时协议数据填充不全的临时保护")
	end
	
	--
	
	local itembg = item.transform:Find(chatContent)
	itembg.gameObject:SetActive(true)
	local vipData = TableMgr:GetVipData(chatinfo.sender.viplevel)
	local bg_vip = item.transform:Find(System.String.Format("{0}/bg_touxiang/bg_vip", chatContent))
	bg_vip.gameObject:SetActive(chatinfo.sender.viplevel > 0)
	local vipSpr = bg_vip:Find("icon"):GetComponent("UISprite")
	--local offset = chatinfo.sender.viplevel%5 > 0 and 1 or 0
	vipSpr.spriteName = vipData.headBoxVip--"bg_avatar_num_vip"..math.ceil(chatinfo.sender.viplevel/5)
	local vipLabel = bg_vip:Find("num"):GetComponent("UILabel")
	vipLabel.text = chatinfo.sender.viplevel
	
	local touxiangVip = item.transform:Find(System.String.Format("{0}/bg_touxiang" , chatContent)):GetComponent("UISprite")
	touxiangVip.spriteName = vipData.headBox--"bg_avatar_vip"..math.ceil(chatinfo.sender.viplevel/5)

	
	
	local name = item.transform:Find(System.String.Format("{0}/bg_title/name" , chatContent)):GetComponent("UILabel")
	--print(chatinfo.sender.name .. "     "  .. tostring(chatinfo.gm))
	if chatinfo.gm then
		name.text = "[ff0000][" .. TextMgr:GetText("GM_Name") .. "][-]" .. chatinfo.sender.name
	else
		local guildLabel = ""
		--if UnionInfoData.HasUnion() then
			--guildLabel = "[f1cf63]【"..UnionInfoData.GetData().guildInfo.name .. "】[-]"
		--end
		if chatinfo.senderguildname ~= nil and chatinfo.senderguildname ~= "" then
			guildLabel = "[f1cf63]【".. chatinfo.senderguildname .. "】[-]"
		end
		name.text = guildLabel ..  "[ffffff]" ..  chatinfo.sender.name .. "[-]"
	end

	local gov =item.transform:Find(System.String.Format("{0}/bg_title/bg_gov" , chatContent))
	if gov ~= nil then
		GOV_Util.SetGovNameUI(gov,chatinfo.sender.officialId,chatinfo.sender.guildOfficialId,true)
	end	
	
	local chatTime = item.transform:Find(System.String.Format("{0}/bg_title/time" , chatContent)):GetComponent("UILabel")
	chatTime.text = GetChatTime(chatinfo.time)

	local touxiang = item.transform:Find(System.String.Format("{0}/bg_touxiang/icon_touxiang" , chatContent)):GetComponent("UITexture")
	if chatinfo.gm then
		touxiang.mainTexture = ResourceLibrary:GetIcon("Icon/head/", "GM")
		GOV_Util.SetFaceUI(item.transform:Find(System.String.Format("{0}/bg_touxiang/MilitaryRank" , chatContent)),nil)
	else
		touxiang.mainTexture = ResourceLibrary:GetIcon("Icon/head/", chatinfo.sender.face)
		GOV_Util.SetFaceUI(item.transform:Find(System.String.Format("{0}/bg_touxiang/MilitaryRank" , chatContent)),chatinfo.sender.militaryRankId)
	end

	item.transform:Find(System.String.Format("{0}/bg_touxiang/Inprison" , chatContent)).gameObject:SetActive(chatinfo.sender.isPrison)
	
	item.chatContent = chatContent
	item.data = chatinfo
	
	if chatinfo.type == 2 then
		SetChatInfoCoordinateContent(chatinfo, chatContent , item)
	elseif chatinfo.type == 3 then
		SetChatInfoBattleReport(chatinfo, chatContent , item)
	elseif chatinfo.type == 5 then
		SetChatInfoUnionInvitation(chatinfo, chatContent , item)
	elseif chatinfo.type == 6 then		
		SetChatInfoRallyInvitation(chatinfo, chatContent , item)
	elseif chatinfo.type == 7 then
		SetChatInfoExistTest(chatinfo, chatContent, item)
	else
		SetChatInfoNormalContent(chatinfo, chatContent , item)
	end
	
	
	--
	
	--[[local chatbtn = item.transform:Find(System.String.Format("{0}/bg_msg" , chatContent))
	SetClickCallback(chatbtn.gameObject , function(go)
		print("click chat Btn")
	end)]]
	
	local touxiangBtn = item.transform:Find(System.String.Format("{0}/bg_touxiang" , chatContent)):GetComponent("UIButton")
	SetClickCallback(touxiangBtn.gameObject , function()
		if chatContent == "left" then
			-- GUIMgr:CreateMenu("PanelBox",false)
			local data = {}
			data.name = chatinfo.sender.name;
			data.text = chatinfo.infotext;
			data.id = chatinfo.sender.charid;
			data.kind = ChatMsg_pb.MsgChatTipOffWay_Chat;
			PanelBox.Show(data);
			--[[ OtherInfo.RequestShow(chatinfo.sender.charid , function(msg)
				if msg.userInfo.charid == chatinfo.sender.charid and msg.userInfo.name ~= chatinfo.sender.name then
					MessageBox.Show(TextMgr:GetText("changename_error") , function() return false end)
				else
					return true
				end	 
			end)]]--
		end
	end)
	--touxiangBtn.gameObject.name = "playerBtn" .. "_" .. chatContent .. "_" .. chatinfo.sender.name
	--touxiangBtn.gameObject.name = "playerBtn_" .. chatContent .. "_" .. chatinfo.sender.charid
	
	return item
end


function SendConditionContent(content , callback)
	local req = ChatMsg_pb.MsgChatInfoConditionSendRequest()
	req.type = content.type
	if req.type == ChatMsg_pb.ChatInfoConditionType_GuildGather then
		req.tarUid = content.tarUid
	end
	req.info.chanel = tonumber(content.curChanel)
	req.info.infotext = content.content
	req.info.clientlangcode = content.languageCode or GUIMgr:GetSystemLanguage()--Global.GTextMgr:GetCurrentLanguageID()
	req.info.type = content.chatType
	req.info.senderguildname = content.senderguildname or ""
	req.info.spectext = content.spectext or ""
	req.info.param = content.param or 0
	Global.DumpMessage(req , "d:/MsgChatInfoConditionSendRequest.lua")
	Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatInfoConditionSendRequest, req, ChatMsg_pb.MsgChatInfoConditionSendResponse, function(msg)
		Global.DumpMessage(msg , "d:/MsgChatInfoConditionSendResponse.lua")
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.FloatError(msg.code)
		else
			if bg_bottom ~= nil then
				bg_bottom.input.value = ""
			end
			--MainCityUI.RequestChat(false)
			print("shend Chat sucess")
			
			if callback ~= nil then
				callback()
			end
		end 
	end , false)
	
end

function SendContent(content , callback)
	local req = ChatMsg_pb.MsgChatInfoSendRequest()
	req.info.chanel = tonumber(content.curChanel)
	req.info.infotext = content.content
	req.info.clientlangcode = content.languageCode or GUIMgr:GetSystemLanguage()--Global.GTextMgr:GetCurrentLanguageID()
	req.info.type = content.chatType
	req.info.senderguildname = content.senderguildname or ""
	req.info.spectext = content.spectext or ""
	if curChanel == ChatMsg_pb.chanel_private then
		req.info.recvlist:add()
		req.info.recvlist[#(req.info.recvlist)].charid = recvList.charid
		req.info.recvlist[#(req.info.recvlist)].name = recvList.name
		print(req.info.recvlist[#(req.info.recvlist)].charid , req.info.recvlist[#(req.info.recvlist)].name)
		--[[for i=1 , #recvList , 1 do
			req.info.recvlist:add()
			req.info.recvlist[#(req.info.recvlist)].charid = recvList[i].charid
			req.info.recvlist[#(req.info.recvlist)].name = recvList[i].name
			
			print(req.info.recvlist[#(req.info.recvlist)].charid , req.info.recvlist[#(req.info.recvlist)].name)
		end]]
	elseif curChanel == ChatMsg_pb.chanel_discussiongroup then
		req.info.param = content.groupid and content.groupid or recvList.groupid
	end
	
	if content.curChanel == ChatMsg_pb.chanel_world then
		local cd  = Global.GetChatIntvContinuesCD(GameTime.GetSecTime() , ChatMsg_pb.chanel_world)
		if cd > 0 then
			FloatText.Show(System.String.Format(TextMgr:GetText("Forbidden_1") , cd) , Color.red)
			return
		end
	end
	
	Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatInfoSendRequest, req, ChatMsg_pb.MsgChatInfoSendResponse, function(msg)
	
		if msg.code ~= ReturnCode_pb.Code_OK then
			if msg.code == 5541 then--禁言
				FloatText.Show(System.String.Format(TextMgr:GetText("Forbidden_3") , msg.forbidtime - GameTime.GetSecTime()) , Color.red)
			else
				Global.ShowError(msg.code)
			end
		else
			if bg_bottom ~= nil then
				bg_bottom.input.value = ""
			end
			--MainCityUI.RequestChat(false)
			print("shend Chat sucess")
			if content.curChanel == ChatMsg_pb.chanel_world then
				Global.SetChatIntvContinuesTime(GameTime.GetSecTime() , ChatMsg_pb.chanel_world)
			end
			
			if callback ~= nil then
				callback()
			end
		end 
	end , true)
	
end

function SendGroupContent(content , callback)
	local req = ChatMsg_pb.MsgChatInfoSendRequest()
	req.info.chanel = tonumber(content.curChanel)
	req.info.infotext = content.content
	req.info.clientlangcode = content.languageCode or GUIMgr:GetSystemLanguage()--Global.GTextMgr:GetCurrentLanguageID()
	req.info.type = content.chatType
	req.info.senderguildname = content.senderguildname or ""
	req.info.spectext = content.spectext or ""
	req.info.param = content.groupid and content.groupid or recvList.groupid
	print(content.curChanel ,content.groupid )
	Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatInfoSendRequest, req, ChatMsg_pb.MsgChatInfoSendResponse, function(msg)
	
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		else
			if bg_bottom ~= nil then
				bg_bottom.input.value = ""
			end
			if callback ~= nil then
				callback()
			end
		end 
	end , true)
	
end

function SendClickCallBack(go)
	local content = bg_bottom.input.value
	if curChanel == ChatMsg_pb.chanel_private then
		if recvList and recvList.charid and ChatData.IsInBlackList(recvList.charid) then
			FloatText.Show(TextMgr:GetText("setting_blacklist_ui15") , Color.red)
			return
		end
	end
	
	if chatLock then
		FloatText.ShowAt(go.transform.position , TextMgr:GetText("chat_hint4") , Color.white)
		return
	end
	
	if content == nil or  content == "" then
		AudioMgr:PlayUISfx("SFX_ui02", 1, false)
		FloatText.Show(TextMgr:GetText("chat_hint5") , Color.white)
		return
	end
	local send = {}
	
	send.curChanel = curChanel
	send.content = content
	send.languageCode = GUIMgr:GetSystemLanguage()--Global.GTextMgr:GetCurrentLanguageID()
	send.chatType = 1
	send.senderguildname = ""
	send.spectext = ""
	if UnionInfoData.HasUnion() then
		send.senderguildname = UnionInfoData.GetData().guildInfo.banner
	end
	
	SendContent(send)
end

local function SendPrivateShare()
	if privateShare ~= nil then
		SendContent(privateShare , function()
			FloatText.Show(TextMgr:GetText("ui_worldmap_83"))
		end)
		privateShare = nil
	end
end

local function SendGroupShare(callback)
	if privateShare ~= nil then
		SendGroupContent(privateShare , function()
			FloatText.Show(TextMgr:GetText("ui_worldmap_83"))
			if callback ~= nil then
				callback()
			end
		end)
		privateShare = nil
	end
end

function NotifyChanelChat()
	if GUIMgr:FindMenu("Chat") == nil then
		return
	end
	
	local chanelNewChat = ChatData.GetChanelNewChat(curChanel , 10 , recvList)
	local moveUp = addNewChatItemPos
	local additem = {}
	if chanelNewChat ~= nil and #chanelNewChat > 0 then

		print("==============================================="  , curChanel , #chanelNewChat)
		local setCorount = coroutine.start(function()
			for _, v in pairs(chanelNewChat) do 
				if ChatData.IsInBlackList(v.sender.charid) == false then
					local chatitem = SetChatInfo(v)
					table.insert(additem , chatitem.transform)
				end
			end
			
			coroutine.step()
			if _ui ~= nil then
				for _,v in pairs(additem) do
					if v ~= nil then
						CalculateChatWidth(v)
						v.transform.localPosition = Vector3(0,addNewChatItemPos,0)
						addNewChatItemPos = addNewChatItemPos - CalculateChatHeight(v)
					end
				end
				
				if bg_mid.noitem.gameObject.activeSelf then
					bg_mid.noitem.gameObject:SetActive(false)
				end
				
				local chatcount = chatContentList.grid.transform.childCount
				local updatePosPercent = 1 - 4/chatcount
				if chatContentList.scrollView.verticalScrollBar.value > updatePosPercent then
					chatContentList.scrollView:ResetPosition()
					chatContentList.scrollView:RestrictWithinBoundsBottom(true)
				end
			end
		end)
	end

	UpdateTabRedPoint()
end


local function GetPreviewContent(chatmsg)
	local name = ""
	if chatmsg.type == 4 then
	
	elseif chatmsg.gm then
		name = "[ff0000][" .. TextMgr:GetText("GM_Name") .."][-]:"
	else
		name = "[" .. chatmsg.sender.name .."]:"
	end
	
	local content = ""
	local contentOffset = ""
	if chatmsg.type == 3 then
		contentOffset = "          "
	end
	
	if chatmsg.type == 4 or chatmsg.type == 5 or chatmsg.type == 2 then
		content = contentOffset .. GetSystemChatInfoContent(chatmsg.infotext)
	else
		content = contentOffset .. chatmsg.infotext
	end
	
	return content
end

function PrivateChat(name , charid , guildBanner , officialId, guildOfficialId)
	--print(name , charid)
	UpdatePrivatePlaterContent(name , charid , guildBanner , officialId, guildOfficialId)
end

local function DeleteRecord(priName , priCharId)
	MessageBox.Show(TextMgr:GetText("Chat_priui1") , 
		function() 
			ChatData.DeleteChatData(priName , priCharId)
			UpdatePrivateContent()
			FloatText.Show(TextMgr:GetText("Chat_priui2"))
		end ,
		
		function()
			return
		end)
end

local function CreateGroupMember(initlist , defaultMem)
	GroupSelectList.Show(initlist , function(addlist)
		if addlist == nil or #addlist == 0 then
			FloatText.Show(TextMgr:GetText("chat_group_ui14") , Color.red)
			return false
		end
	
		local req = ChatMsg_pb.MsgChatDiscGroupCreateRequest()
		local name = string.format("%s ， %s" , MainData.GetCharName() , defaultMem)
		req.mem:append(initlist[2])
		if addlist ~= nil then
			for i=1 , #addlist , 1 do
				req.mem:append(addlist[i].charId)
				name = string.format("%s ， %s" , name , addlist[i].name)
			end
		end
		req.name = name
	
		--Global.DumpMessage(req , "d:/chatgroup.lua")
		Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatDiscGroupCreateRequest, req, ChatMsg_pb.MsgChatDiscGroupCreateResponse, function(msg)
			--Global.DumpMessage(msg , "d:/chatgroup.lua")
			if msg.code == ReturnCode_pb.Code_OK then
				GroupChatData.UpdateData(msg.data)
				UpdateDiscGroupContent(msg.data)
				
				local send = {}
				send.curChanel = ChatMsg_pb.chanel_discussiongroup
				send.spectext = ""
				--send.content = MainData.GetCharName() .. "创建了讨论组"
				send.content = "chat_group_ui12"..",".. name
				send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
				send.chatType = 4
				send.groupid = recvList.groupid
				print("CreateGroupMember :" , recvList.groupid , MainData.GetCharName())
				--send.senderguildname = UnionInfoData.GetData().guildInfo.name
				SendGroupContent(send)
			else
				Global.ShowError(msg.code)
			end
		end, false)
		
		return true
	end)
end

function DiscGroupContent()
	local gd = GroupChatData.GetGroupData(recvList.groupid)
	print("000000000000 : " ,gd, recvList.groupid)
	local memTitle = ""
	for i=1 , #gd.mem , 1 do
		if not gd.mem[i].removed then
			local uInfo = gd.mem[i].user
			local exStr = ""
			if uInfo.guildBanner ~= nil and uInfo.guildBanner ~= "" then
				exStr = "[f1cf63]【".. uInfo.guildBanner .. "】[-]"
			end
			memTitle = memTitle == "" and exStr .. uInfo.name or string.format("%s,%s" , memTitle , exStr .. uInfo.name)
		end
	end
	
	chatContentList.privateTitle.text = gd.name--memTitle
end

function ChatUpdateDiscGroupContent(disMsg , addlist)
	UpdateDiscGroupContent(disMsg)
	--[[for i=1 , #addlist , 1 do
		local memmsg = nil
		for k=1 , #disMsg.mem , 1 do
			print()
			if disMsg.mem[k].user.charid == addlist[i].charId then
				memmsg = disMsg.mem[k]
			end
		end
		
		if memmsg ~= nil then
			local send = {}
			send.curChanel = ChatMsg_pb.chanel_discussiongroup
			send.spectext = ""
			--send.content = memmsg.user.name .. "创建了讨论组"
			send.content = "TipsNotice_Union_Desc5"..","..memmsg.user.name
			send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
			send.chatType = 4
			send.groupid = recvList.groupid
			print("ChatUpdateDiscGroupContent :" , recvList.groupid , memmsg.user.name)
			--send.senderguildname = UnionInfoData.GetData().guildInfo.name
			SendGroupContent(send)
		end
	end]]
	
end




UpdateDiscGroupContent = function(disMsg)
	chatContentList.privatePanel.gameObject:SetActive(true)
	bg_privateList.trf.gameObject:SetActive(false)
	chatContentList.scrollView.gameObject:SetActive(true)
	bg_bottom.bg.gameObject:SetActive(true)
	
	recvList = {}
	recvList.groupid = disMsg.id
	--group title
	DiscGroupContent()
	
	SetClickCallback(chatContentList.privateBackBtn.gameObject , function()
		chatContentList.privatePanel.gameObject:SetActive(false)
		UpdatePrivateContent()
	end)
	
	chatContentList.privateDisSettingBtn.gameObject:SetActive(true)
	chatContentList.privateDisBtn.gameObject:SetActive(false)
	SetClickCallback(chatContentList.privateDisSettingBtn.gameObject , function()
		GroupSetting.Show(disMsg.id , UpdatePrivateContent , DiscGroupContent , UpdatePrivateContent)
	end)
	
	GroupChatData.RequestGroupChat(disMsg.id ,true, function()
		UpdateChatContent(ChatMsg_pb.chanel_discussiongroup)
	end)
end

UpdatePrivatePlaterContent = function (recName , recCharId , guildBanner , officialId, guildOfficialId)
	chatContentList.privatePanel.gameObject:SetActive(true)
	bg_privateList.trf.gameObject:SetActive(false)
	chatContentList.scrollView.gameObject:SetActive(true)
	bg_bottom.bg.gameObject:SetActive(true)
	
	recvList = {}
	recvList.charid = recCharId
	recvList.name = recName
	
	local exStr = ""
	if guildBanner ~= nil and guildBanner ~= "" then
		exStr = "[f1cf63]【".. guildBanner .. "】[-]"
	end
	chatContentList.privateTitle.text = exStr .. recName
	GOV_Util.SetGovNameUI(chatContentList.privateGov,officialId,guildOfficialId,true)

	
	SetClickCallback(chatContentList.privateBackBtn.gameObject , function()
		chatContentList.privatePanel.gameObject:SetActive(false)
		UpdatePrivateContent()
	end)
	
	chatContentList.privateDisSettingBtn.gameObject:SetActive(false)
	chatContentList.privateDisBtn.gameObject:SetActive(true)
	SetClickCallback(chatContentList.privateDisBtn.gameObject , function()
		local initlist = {}
		initlist[1] = MainData.GetCharId()
		initlist[2] = recCharId
		CreateGroupMember(initlist , recvList.name)
	end)
	
	UpdateChatContent(ChatMsg_pb.chanel_private)
end

function UpdateGroupPreview(chatInfo , new)
	if groupDataMap ~= nil and groupDataMap[chatInfo.param] ~= nil then
		local gd = GroupChatData.GetGroupData(chatInfo.param)
		groupDataMap[chatInfo.param]:Find("bg/redpiont").gameObject:SetActive(new>0)
		groupDataMap[chatInfo.param]:Find("bg/redpiont/num"):GetComponent("UILabel").text = new
		
		groupDataMap[chatInfo.param]:Find("bg/text"):GetComponent("UILabel").text = GetPreviewContent(chatInfo)
	end
	
end

function CheckGroupChatData()
	if curChanel == ChatMsg_pb.chanel_discussiongroup and recvList and recvList.groupid then
		GroupChatData.RequestGroupChat(recvList.groupid ,false, function()
			UpdateChatContent(ChatMsg_pb.chanel_discussiongroup)
			GroupChatData.RequestChatGroupList({recvList.groupid} , true , nil)
		end)
	else
		GroupChatData.RequestChatGroupList(nil , nil , function()
			local groups = GroupChatData.GetData()
			local totalnew = 0
			for i=1 , #groups do
				if not GroupChatData.IsDismissed(groups[i].id) and not GroupChatData.IsRemoved(groups[i].id , MainData.GetCharId()) then
					local new = GroupChatData.GetGroupCurrentChatCount(groups[i].id)
					UpdateGroupPreview(groups[i].currentChat , new )
					totalnew = totalnew + new
				end
			end
			GroupChatData.UpdateCheckCount(totalnew)
		end)
	end
end


local function UpdatePrivateNGroupListData()
	if _ui == nil or bg_privateList == nil then
		return
	end
	
	bg_privateList.trf.gameObject:SetActive(true)
	chatContentList.scrollView.gameObject:SetActive(false)
	chatContentList.privatePanel.gameObject:SetActive(false)
	bg_bottom.bg.gameObject:SetActive(false)
	curChanel = ChatMsg_pb.chanel_None
	bg_privateList.scrollView:ClearScrollItemList()
	Global.SetChatEnterChanel(ChatMsg_pb.chanel_private)
	GroupChatData.UpdateCheckCount(0)
	UpdateTabRedPoint()
	

	groupDataMap = {}
	local noitem = true
	while bg_privateList.grid.transform.childCount > 0 do
		GameObject.DestroyImmediate(bg_privateList.grid.transform:GetChild(0).gameObject)
	end
	local contentItems = {}
	local sortTable = ChatData.GetPrivateNew()
	for i=1 , #(sortTable) , 1 do
		local k = sortTable[i].name
		local v = ChatData.GetPrivateChat(k)
		noitem = false
		--print("msg:" , k ,#(v))
		local strPri = string.split(k , ",")
		local priName = strPri[1]
		local priCharId = tonumber(strPri[2])
		local lastchat = v[#(v)]
		local priPlayer = nil
		if lastchat.sender.charid ~= priCharId then
			priPlayer = {}
			priPlayer.sender = v[#(v)].recvlist[1]
		else
			priPlayer = v[#(v)]
		end
	
		---私聊开发时协议数据填充不全的临时保护----
		if priPlayer.sender.viplevel == nil then
			priPlayer.sender.viplevel = 0 
			priPlayer.sender.officialId = 0
			priPlayer.sender.guildOfficialId = 0
			priPlayer.sender.face = 103
			priPlayer.sender.guildBanner = ""
			print("私聊开发时协议数据填充不全的临时保护")
		end
		-----------------------------------------------
		
		
		local listitem = NGUITools.AddChild(bg_privateList.grid.gameObject , chatContentList.privateListInfo.gameObject).transform
		listitem.gameObject:SetActive(true)
		local itemIcon = listitem:Find("bg/bg_touxiang/icon_touxiang"):GetComponent("UITexture")
		itemIcon.mainTexture = ResourceLibrary:GetIcon("Icon/head/", priPlayer.sender.face)
		GOV_Util.SetFaceUI(listitem:Find("bg/bg_touxiang/MilitaryRank"),priPlayer.sender.militaryRankId)		
		listitem:Find("bg/bg_touxiang/Inprison").gameObject:SetActive(priPlayer.sender.isPrison)
		local itemName = listitem:Find("bg/bg_title/name"):GetComponent("UILabel")
		local exStr = ""
		if priPlayer.sender.guildBanner ~= nil and priPlayer.sender.guildBanner ~= "" then
			exStr = "[f1cf63]【".. priPlayer.sender.guildBanner .. "】[-]"
		end
		itemName.text = exStr.. priName
		local itemTime = listitem:Find("bg/bg_title/time"):GetComponent("UILabel")
		
		listitem.name = lastchat.time
		itemTime.text = GetChatTime(lastchat.time)
		local itemMsg = listitem:Find("bg/text"):GetComponent("UILabel")
		itemMsg.text = GetPreviewContent(lastchat)--"fuck u"
		local reportIcon = listitem:Find("bg/text/Sprite")
		reportIcon.gameObject:SetActive(lastchat.type == 3)
		--vip
		local vipData = TableMgr:GetVipData(priPlayer.sender.viplevel)
		local bg_vip = listitem.transform:Find("bg/bg_touxiang/bg_vip")
		bg_vip.gameObject:SetActive(priPlayer.sender.viplevel > 0)
		local vipSpr = bg_vip:Find("icon"):GetComponent("UISprite")
		vipSpr.spriteName = vipData.headBoxVip--"bg_avatar_num_vip"..math.ceil(priPlayer.sender.viplevel/5)
		local vipLabel = bg_vip:Find("num"):GetComponent("UILabel")
		vipLabel.text = priPlayer.sender.viplevel
		
		local touxiangVip = listitem.transform:Find("bg/bg_touxiang"):GetComponent("UISprite")
		touxiangVip.spriteName = vipData.headBox--"bg_avatar_vip"..math.ceil(priPlayer.sender.viplevel/5)
		
		local gov =listitem.transform:Find("bg/bg_title/bg_gov")
		if gov ~= nil then
			GOV_Util.SetGovNameUI(gov,priPlayer.sender.officialId,priPlayer.sender.guildOfficialId,true)
		end
		
		local new = ChatData.GetPlayerUnreadPrivateContent(priName , priCharId)
		local red = listitem:Find("bg/redpiont")
		red.gameObject:SetActive(new > 0)
		red:Find("num"):GetComponent("UILabel").text = new
		
		contentItems[priName] = listitem
		SetClickCallback(listitem:Find("bg").gameObject , function()
			print("player rec:" , k , lastchat.sender.charid ,priCharId ,MainData.GetCharId() , privateShare)
			--MessageBox.Show(GTextMgr:GetText(Text.common_ui8), function() store.Show() end, function() end, GTextMgr:GetText(Text.common_ui10))
			if privateShare ~= nil then
				
				if ChatData.IsInBlackList(priCharId) then
					FloatText.Show(TextMgr:GetText("setting_blacklist_ui15") , Color.red)
					return
				end
	
				MessageBox.Show(System.String.Format(TextMgr:GetText("Chat_share_ui2") , k), 
				function()  
					bg_privateList.trf.gameObject:SetActive(false)
					UpdatePrivatePlaterContent(priName , priCharId , priPlayer.sender.guildBanner , priPlayer.sender.officialId, priPlayer.sender.guildOfficialId)
					SendPrivateShare()
				end, 
				function() 
					FloatText.Show(TextMgr:GetText("Chat_share_ui1")) 
				end)
			else
				bg_privateList.trf.gameObject:SetActive(false)
				UpdatePrivatePlaterContent(priName , priCharId , priPlayer.sender.guildBanner , priPlayer.sender.officialId, priPlayer.sender.guildOfficialId)
			end
		end)
		
		SetClickCallback(touxiangVip.gameObject , function()
			OtherInfo.RequestShow(priCharId , function(msg)
				if msg.userInfo.charid == priCharId and msg.userInfo.name ~= priName then
					MessageBox.Show(TextMgr:GetText("changename_error") , function() return false end)
				else
					return true
				end	
			end)
			
			--OtherInfo.RequestShow(priCharId)
		end)
		
		local del = listitem:Find("bg/btn_del")
		SetClickCallback(del.gameObject , function()
			DeleteRecord(priName , priCharId)
		end)
	end
	
	local sortedCfg = Global.GFileRecorder:GetSortedConfigData()
	for i=1 , #sortedCfg , 1 do
		local v = sortedCfg[i]
		if contentItems[v.name] == nil then
			local k = v.name
			noitem = false
			
			---私聊开发时协议数据填充不全的临时保护----
			if v.viplevel == nil then
				v.viplevel = 0 
				v.officialId = 0
				v.guildOfficialId = 0
				v.face = 103
				v.guildBanner = ""
				v.militaryRankId = 1
				print("私聊开发时协议数据填充不全的临时保护")
			end
			-----------------------------------------------
			
			local previewContent = Global.GFileRecorder.charRecordsBuff[k].data[1]
			local listitem = NGUITools.AddChild(bg_privateList.grid.gameObject , chatContentList.privateListInfo.gameObject).transform
			listitem.gameObject:SetActive(true)
			local itemIcon = listitem:Find("bg/bg_touxiang/icon_touxiang"):GetComponent("UITexture")
			itemIcon.mainTexture = ResourceLibrary:GetIcon("Icon/head/", v.face)
			GOV_Util.SetFaceUI(listitem:Find("bg/bg_touxiang/MilitaryRank"),v.militaryRankId)	
			local itemName = listitem:Find("bg/bg_title/name"):GetComponent("UILabel")
			local exStr = ""
			if v.guildBanner ~= nil and v.guildBanner ~= "" then
				exStr = "[f1cf63]【".. v.guildBanner .. "】[-]"
			end
			itemName.text = exStr.. v.name
			local itemTime = listitem:Find("bg/bg_title/time"):GetComponent("UILabel")
			
			listitem.name = previewContent.time
			itemTime.text = GetChatTime(previewContent.time)
			local itemMsg = listitem:Find("bg/text"):GetComponent("UILabel")
			itemMsg.text = GetPreviewContent(previewContent)--"fuck u"
			local reportIcon = listitem:Find("bg/text/Sprite")
			reportIcon.gameObject:SetActive(previewContent.type == 3)
			--vip
			local bg_vip = listitem.transform:Find("bg/bg_touxiang/bg_vip")
			bg_vip.gameObject:SetActive(v.viplevel > 0)
			local vipSpr = bg_vip:Find("icon"):GetComponent("UISprite")
			vipSpr.spriteName = "bg_avatar_num_vip"..math.ceil(v.viplevel/5)
			local vipLabel = bg_vip:Find("num"):GetComponent("UILabel")
			vipLabel.text = v.viplevel
			local touxiangVip = listitem.transform:Find("bg/bg_touxiang"):GetComponent("UISprite")
			touxiangVip.spriteName = "bg_avatar_vip"..math.ceil(v.viplevel/5)
			local gov =listitem.transform:Find("bg/bg_title/bg_gov")
			if gov ~= nil then
				GOV_Util.SetGovNameUI(gov,v.officialId,v.guildOfficialId,true)
			end
			
			local new = ChatData.GetPlayerUnreadPrivateContent(k , v.charid)
			
			local red = listitem:Find("bg/redpiont")
			red.gameObject:SetActive(new > 0)
			red:Find("num"):GetComponent("UILabel").text = new
		
			SetClickCallback(listitem:Find("bg").gameObject , function()
				--print("player rec:" , k , v.charid , MainData.GetCharId())
				if privateShare ~= nil then
					if ChatData.IsInBlackList(v.charid) then
						FloatText.Show(TextMgr:GetText("setting_blacklist_ui15") , Color.red)
						return
					end
				
					MessageBox.Show(System.String.Format(TextMgr:GetText("Chat_share_ui2") , k), 
					function()  
						bg_privateList.trf.gameObject:SetActive(false)
						UpdatePrivatePlaterContent(k , v.charid , v.guildBanner , v.officialId, v.guildOfficialId)
						SendPrivateShare()
					end, 
					function() 
						FloatText.Show(TextMgr:GetText("Chat_share_ui1")) 
					end)
				else
					bg_privateList.trf.gameObject:SetActive(false)
					UpdatePrivatePlaterContent(k , v.charid , v.guildBanner , v.officialId, v.guildOfficialId)
				end
			end)
			
			SetClickCallback(touxiangVip.gameObject , function()
				OtherInfo.RequestShow(v.charid , function(msg)
					if msg.userInfo.charid == v.charid and msg.userInfo.name ~= v.name then
						MessageBox.Show(TextMgr:GetText("changename_error") , function() return false end)
					else
						return true
					end	
				end)
			
				--OtherInfo.RequestShow(v.charid)
			end)
			
			local del = listitem:Find("bg/btn_del")
			SetClickCallback(del.gameObject , function()
				DeleteRecord(k , v.charid)
			end)
		end
	end
	
	local groupdata  = GroupChatData.GetSortedData()
	if groupdata then
		for i=1 , #groupdata , 1 do
			local group = groupdata[i]
			if (not GroupChatData.IsDismissed(group.id)) and (not GroupChatData.IsRemoved(group.id , MainData.GetCharId())) then
				noitem = false
				local listitem = NGUITools.AddChild(bg_privateList.grid.gameObject , chatContentList.privateListInfo.gameObject).transform
				listitem.gameObject:SetActive(true)
				listitem:Find("bg/bg_touxiang_group").gameObject:SetActive(true)
				listitem:Find("bg/bg_touxiang").gameObject:SetActive(false)
				
				local itemName = listitem:Find("bg/bg_title/name"):GetComponent("UILabel")
				--[[local groupMemText = ""
				for k=1 , #group.mem , 1 do
					if not group.mem[k].removed then
						groupMemText = string.format("%s , %s" , groupMemText , group.mem[k].user.name)
					end
				end
				itemName.text = groupMemText]]
				itemName.text = group.name--groupMemText
				
				local itemTime = listitem:Find("bg/bg_title/time"):GetComponent("UILabel")
				itemTime.text = ""
				listitem.name = 0--group.currentChat.time
				if group.currentChat and group.currentChat.time then
					itemTime.text = GetChatTime(group.currentChat.time)
					listitem.name = group.currentChat.time
				end
				
				local itemMsg = listitem:Find("bg/text"):GetComponent("UILabel")
				if group.currentChat then
					itemMsg.text = GetPreviewContent(group.currentChat)--"fuck u"
				end
				
				local new = GroupChatData.GetGroupCurrentChatCount(group.id)
				local newIcon = listitem:Find("bg/redpiont")
				newIcon.gameObject:SetActive(new > 0)
				newIcon:Find("num"):GetComponent("UILabel").text = new
				
				groupDataMap[group.id] = listitem
				
				SetClickCallback(listitem:Find("bg").gameObject , function()
					--[[if GroupChatData.IsRemoved(group.id , MainData.GetCharId()) then
						FloatText.Show(TextMgr:GetText("chat_group_ui9") , Color.red) -- "你已经被移出该讨论组"
						return 
					end]]
					if privateShare ~= nil then
						MessageBox.Show(TextMgr:GetText("chat_group_ui18") , --"是否确定要分享到该讨论组？", 
						function()  
							bg_privateList.trf.gameObject:SetActive(false)
							
							privateShare.curChanel = ChatMsg_pb.chanel_discussiongroup
							privateShare.groupid = group.id
							SendGroupShare(UpdateDiscGroupContent(group))
							
						end, 
						function() 
							FloatText.Show(TextMgr:GetText("Chat_share_ui1")) 
						end)
					else
						bg_privateList.trf.gameObject:SetActive(false)
						UpdateDiscGroupContent(group)
					end
					
				end)
				
				local del = listitem:Find("bg/btn_del")
				SetClickCallback(del.gameObject , function()
					FloatText.Show(TextMgr:GetText("chat_group_ui20"))
				end)

			end
			
		end
	end
	
	
	bg_privateList.grid:Reposition()
	bg_mid.noitem.gameObject:SetActive(noitem)
end


UpdatePrivateContent = function()
	print("uuuuuuuuuuuuuuu")
	if _ui.time ~= nil then 
		_ui.time.gameObject:SetActive(false)
	end
	GroupChatData.RequestChatGroupList(nil, nil , UpdatePrivateNGroupListData)
end

function OnChatGroupPush()
	GroupChatData.RequestChatGroupList(nil, nil , function()
		--检查是当前讨论组是否已变化
		if curChanel  == ChatMsg_pb.chanel_discussiongroup then
			local needBack = false
			local backText = ""
			if GroupChatData.IsDismissed(recvList.groupid) then
				needBack = true
				backText = TextMgr:GetText("chat_group_ui11")--"改讨论组已经被解散"
				print(backText)
			end
			
			if GroupChatData.IsRemoved(recvList.groupid , MainData.GetCharId()) then
				needBack = true
				backText = TextMgr:GetText("chat_group_ui9")--"你已经被移出该讨论组"
				print(backText)
			end
			
			if needBack then
				MessageBox.Show(backText , 
					function()
						chatContentList.privatePanel.gameObject:SetActive(false)
						UpdatePrivateNGroupListData()
					end)
			end
			
		end
	end)
end 


function UpdateChatContent(updateChanel , forceUpdate)
--	print(curChanel , updateChanel)
	if _ui.time ~= nil then 
		_ui.time.gameObject:SetActive(true)
	end
	if updateChanel ~= ChatMsg_pb.chanel_world and updateChanel ~= ChatMsg_pb.chanel_guild and 
		updateChanel ~= ChatMsg_pb.chanel_private and updateChanel ~= ChatMsg_pb.chanel_discussiongroup then
		
		AudioMgr:PlayUISfx("SFX_ui02", 1, false)
		FloatText.Show(TextMgr:GetText("common_ui1") , Color.white)
		return
	end
	
	if curChanel == updateChanel and (not forceUpdate) then
		return 
	end
	
	if _ui == nil then
		return 
	
	end
	--ChatData.SaveChatList()
	chatContentList.privatePanel.gameObject:SetActive(false)
	bg_privateList.trf.gameObject:SetActive(false)
	chatContentList.scrollView.gameObject:SetActive(true)
	bg_bottom.bg.gameObject:SetActive(true)
	
	--if curChanel == updateChanel then
	--	return
	--end

	if updateChanel ~= ChatMsg_pb.chanel_private and updateChanel ~= ChatMsg_pb.chanel_discussiongroup then
		privateShare = nil
	end

	local optChanel = updateChanel
	if updateChanel == ChatMsg_pb.chanel_discussiongroup then
		optChanel = ChatMsg_pb.chanel_private
	end
	Global.SetChatEnterChanel(optChanel)--记录聊天的页签
	
	bg_tab[optChanel].transform:GetComponent("UIToggle"):Set(true)
	curChanel = updateChanel
	--print(curChanel, recvList.name , recvList.charid)
	ChatData.InitRecordIndex(curChanel, recvList.name , recvList.charid , recvList.groupid)

	panel_box.name = ""
	addOldChatItemPos = 0
	addNewChatItemPos = 0
	
	translateMap = nil
	TranslateChatContent()
	
	--chatContentList.scrollView.verticalScrollBar.value = 0
				
	-- 集结分享倒计时
	if RallyCount > 0 then 
		for i = 1, RallyCount do
			CountDown.Instance:Remove("Rally"..i)
		end
	end
	RallyCount = 0
	
	
	local chanelChat = nil
	if updateChanel == ChatMsg_pb.chanel_private then
		--print("privateName:" , recvList.name , recvList.charid)
		chanelChat = ChatData.GetPrivateRecordData(recvList.name , recvList.charid, 10 , false)
		chatContentList.privatePanel.gameObject:SetActive(true)
		ChatData.SavePlayerChat(recvList.name , recvList.charid , true)
		
		if _ui.time ~= nil then 
			_ui.time.gameObject:SetActive(false)
		end
		
	elseif updateChanel == ChatMsg_pb.chanel_discussiongroup then
		chatContentList.privatePanel.gameObject:SetActive(true)
		chanelChat = ChatData.GetChanelRecordChat(curChanel , 10 , nil , nil , recvList.groupid)
		local gd = GroupChatData.GetGroupData(recvList.groupid)
		local curChatid = (#chanelChat > 0) and chanelChat[#chanelChat].id or 0
		GroupChatData.SetGroupCurrentChatId(gd.id , curChatid)
	else
		chanelChat = ChatData.GetChanelRecordChat(curChanel , 10 )
	end
	
	UpdateTabRedPoint()
	
	if updateChanel == ChatMsg_pb.chanel_guild then
		ChatData.SetUnreadGuildCount(0)
	end
	
	local moveUp = 0
	while chatContentList.grid.transform.childCount > 0 do
		GameObject.DestroyImmediate(chatContentList.grid.transform:GetChild(0).gameObject)
	end
	
	if chanelChat == nil or #chanelChat <= 0 then
		bg_mid.noitem.gameObject:SetActive(true)
	else	
		bg_mid.noitem.gameObject:SetActive(false)
		local setCorount = coroutine.start(function()
			--addchild
			for _, v in pairs(chanelChat) do
				--print(v.infotext , v.sender.name , v.sender.charid , v.type , ChatData.IsInBlackList(v.sender.charid))
				local chatitem = SetChatInfo(v)
			end
			coroutine.step()
			--cal height 
			--等待一帧获取widget尺寸
			if chatContentList ~= nil then
				for i=0, chatContentList.grid.transform.childCount-1 do
					local chatitem = chatContentList.grid.transform:GetChild(i)
					CalculateChatWidth(chatitem)
					chatitem.transform.localPosition = Vector3(0,moveUp,0)
					moveUp = moveUp - CalculateChatHeight(chatitem)
				end
			end
			
			addNewChatItemPos = moveUp
			--chatContentList.scrollView:RestrictWithinBoundsBottom(true)
			coroutine.step()
			if chatContentList ~= nil then
				chatContentList.scrollView:UpdatePosition()
				chatContentList.scrollView.verticalScrollBar.value = 1
			end
		end)
	end
end 


function UpdateChatContentList()
	if GUIMgr:FindMenu("Chat") ~= nil then
		if curChanel == ChatMsg_pb.chanel_world or curChanel == ChatMsg_pb.chanel_guild then
			UpdateChatContent(curChanel , true)
		end
	end
end

function UpdateRecordChatInfo()
	local chatcount = chatContentList.grid.transform.childCount
	local chanelChat = nil
	if curChanel == ChatMsg_pb.chanel_private then
		chanelChat = ChatData.GetPrivateRecordData(recvList.name , recvList.charid, 10 , true)
	elseif curChanel == ChatMsg_pb.chanel_discussiongroup then
		chanelChat = ChatData.GetChanelRecordChat(curChanel , 10 , nil , nil , recvList.groupid)
	else
		chanelChat = ChatData.GetChanelRecordChat(curChanel , 10)
	end
	
	local additem = {}
	local addoldchat = addOldChatItemPos
	--print("len:" .. #chanelChat)
	local setCorount = coroutine.start(function()
		for _, v in pairs(chanelChat) do
			local chatitem = SetChatInfo(v)	
			table.insert(additem , chatitem.transform)
		end
		
		coroutine.step()
		for i=0 , #additem-1 do --从后往前添加
			local v = additem[#additem - i]
			CalculateChatWidth(v)
			addoldchat = addoldchat + CalculateChatHeight(v)
			addOldChatItemPos = addoldchat
			v.localPosition = Vector3(0,addoldchat,0)
		end
		coroutine.step()
		--chatContentList.scrollView:UpdatePosition()
	end)
end


local function OnCloseCallback(go)
	GUIMgr:CloseMenu("Chat")	
end

function JumpNewTab(sel)
end

function GetTabSelect()
end

function OnDrag()
	--print("drag")
	if chatContentList ~= nil and (chatContentList.scrollView.transform.localPosition.y < -50 - addOldChatItemPos) then
		--print("sv pos:" .. chatContentList.scrollView.transform.localPosition.y)
		bg_mid.svjuhua.gameObject:SetActive(true)
		local offsety = addOldChatItemPos + 200
		bg_mid.svjuhua.localPosition = Vector3(0, offsety , 0 )
		ReqChatRecord = true
	end
end

function Update()
	--[[
	local sp = chatContentList.scrollView.transform:GetComponent("SpringPanel")
	if sp ~= nil and sp.enabled then
		if chatContentList.scrollView.transform.localPosition.y < -40 - addOldChatItemPos then
			chatContentList.scrollView:DisableSpring()
		end
	end
	]]
end

function OnDragStart()
	
	--print("start")
end

function OnDragFinish()
	--print("finish:" .. chatContentList.scrollView.transform.localPosition.y .. "fref:" .. -100 - addOldChatItemPos)
	--if chatContentList.scrollView.transform.localPosition.y < -100 - addOldChatItemPos then
	if ReqChatRecord then
		print("get record")
		ReqChatRecord = false
		bg_mid.svjuhua.gameObject:SetActive(false)
		UpdateRecordChatInfo()
	end
end


local function CheckLeaveUnion()
    if not UnionInfoData.HasUnion() then
        if not bg_tab[ChatMsg_pb.chanel_world].transform:GetComponent("UIToggle").value then
            UpdateChatContent(ChatMsg_pb.chanel_world)
            bg_tab[ChatMsg_pb.chanel_guild].transform:GetComponent("UIToggle").value = false
        end
    end
end

function Awake()
	local container = transform:Find("Container")
	SetClickCallback(container.gameObject, function(go)
		GUIMgr:CloseMenu("Chat")
	end)
	_ui = {}
	bg_tab = {}
	bg_tab[ChatMsg_pb.chanel_world] = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_5"):GetComponent("UIButton")
	transform:Find("Container/bg_frane/bg_tab/btn_tabtype_5/text1"):GetComponent("UILabel").text = TextMgr:GetText("chat_tab1")
	transform:Find("Container/bg_frane/bg_tab/btn_tabtype_5/Animation/btn_lv1_down/tab_title_down1"):GetComponent("UILabel").text = TextMgr:GetText("chat_tab1")
	SetClickCallback(bg_tab[ChatMsg_pb.chanel_world].gameObject, function(go)
		--curChanel = ChatMsg_pb.chanel_world
		--UpdateChatContent()
		UpdateChatContent(ChatMsg_pb.chanel_world)
	end)
	
	bg_tab[ChatMsg_pb.chanel_guild] = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_4"):GetComponent("UIButton")
	transform:Find("Container/bg_frane/bg_tab/btn_tabtype_4/text2"):GetComponent("UILabel").text = TextMgr:GetText("maincity_ui6")
	transform:Find("Container/bg_frane/bg_tab/btn_tabtype_4/Animation/btn_lv2_down/tab_title_down2"):GetComponent("UILabel").text = TextMgr:GetText("maincity_ui6")
	SetClickCallback(bg_tab[ChatMsg_pb.chanel_guild].gameObject, function(go)
		--curChanel = ChatMsg_pb.chanel_guild				
		if not UnionInfoData.HasUnion() then
			FunctionListData.IsFunctionUnlocked(106, function(isactive)
	        	if isactive then
					JoinUnion.Show(function()
						if bg_tab ~= nil then
							bg_tab[ChatMsg_pb.chanel_guild].transform:GetComponent("UIToggle").value = false
							UpdateChatContent(ChatMsg_pb.chanel_world)
						end
		            end)
		        else
		        	FloatText.Show(TextMgr:GetText(TableMgr:GetFunctionUnlockText(106)), Color.white)
		        end
		    end)
            return
		end
		UpdateChatContent(ChatMsg_pb.chanel_guild)
	end)
	bg_tab[ChatMsg_pb.chanel_system] = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_6"):GetComponent("UIButton")
	SetClickCallback(bg_tab[ChatMsg_pb.chanel_system].gameObject, function(go)
		--curChanel = ChatMsg_pb.chanel_system
		UpdateChatContent(ChatMsg_pb.chanel_system)
	end)
	bg_tab[ChatMsg_pb.chanel_private] = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_7"):GetComponent("UIButton")
	bg_tab[ChatMsg_pb.chanel_private].gameObject:SetActive(true)
	transform:Find("Container/bg_frane/bg_tab/btn_tabtype_7/text2"):GetComponent("UILabel").text = TextMgr:GetText("chat_tab3")
	SetClickCallback(bg_tab[ChatMsg_pb.chanel_private].gameObject, function(go)
		--curChanel = ChatMsg_pb.chanel_private
		--UpdateChatContent(ChatMsg_pb.chanel_private)
		UpdatePrivateContent()
	end)
	
	bg_tab.privateRed = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_7/Animation/bg_num")
	bg_tab.guildRed = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_4/Animation/bg_num")
	table.insert(_ui , bg_tab)
	
	chatContentList = {}
	chatContentList.scrollView = transform:Find("Container/bg_frane/Scroll View"):GetComponent("UIScrollView")
	chatContentList.grid = transform:Find("Container/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
	chatContentList.item = transform:Find("ChatInfo")
	chatContentList.itemSizeY = transform:Find("ChatInfo/left"):GetComponent("UIWidget").height
	chatContentList.privatePanel = transform:Find("Container/bg_frane/Panel")
	chatContentList.privateBackBtn = transform:Find("Container/bg_frane/Panel/bg_top/btn_back")
	chatContentList.privateDisBtn = transform:Find("Container/bg_frane/Panel/bg_top/btn_group")
	chatContentList.privateDisSettingBtn = transform:Find("Container/bg_frane/Panel/bg_top/btn_setting")
	chatContentList.privateTitle = transform:Find("Container/bg_frane/Panel/bg_top/bg_title/name"):GetComponent("UILabel")
	chatContentList.privateGov = transform:Find("Container/bg_frane/Panel/bg_top/bg_title/bg_gov")

	chatContentList.rallyinvitation = transform:Find("rallyinvitation")	
	chatContentList.coordinateItem = transform:Find("coordinateInfo")
	chatContentList.pvpItem = transform:Find("PVPInfo")
	chatContentList.autoSystem = transform:Find("systemInfo")
	chatContentList.unionInvitation = transform:Find("unionInvitation")
	chatContentList.privateListInfo = transform:Find("Prichatlistinfo")
	chatContentList.existtest = transform:Find("existtest")
	
	bg_bottom = {}
	bg_bottom.bg = transform:Find("Container/bg_frane/bg_bottom")
	bg_bottom.input = transform:Find("Container/bg_frane/bg_bottom/frame_input"):GetComponent("UIInput")
	bg_bottom.inputLock = transform:Find("Container/bg_frane/bg_bottom/frame_input/title"):GetComponent("UILabel")
	bg_bottom.inputunLock = transform:Find("Container/bg_frane/bg_bottom/unlock"):GetComponent("UILabel")
	bg_bottom.sendbtn = transform:Find("Container/bg_frane/bg_bottom/btn_send"):GetComponent("UIButton")
	bg_bottom.inputCollider = transform:Find("Container/bg_frane/bg_bottom/frame_input"):GetComponent("BoxCollider")
	SetClickCallback(bg_bottom.sendbtn.gameObject, SendClickCallBack)
	table.insert(_ui , bg_bottom)
	
	bg_mid = {}
	bg_mid.noitem = transform:Find("Container/bg_frane/bg_mid/bg_noitem")
	bg_mid.svjuhua = transform:Find("Container/bg_frane/Scroll View/bg_juhua")
	table.insert(_ui , bg_mid)
	
	bg_top = {}
	bg_top.tittle = transform:Find("Container/bg_frane/bg_top/bg_title_left/title"):GetComponent("UILabel")
	bg_top.closeBtn = transform:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(bg_top.closeBtn.gameObject, function(go)
		GUIMgr:CloseMenu("Chat")
	end)
	table.insert(_ui , bg_top)
	
	bg_privateList = {}
	bg_privateList.trf = transform:Find("Container/bg_frane/bg_prichatlist")
	bg_privateList.scrollView = transform:Find("Container/bg_frane/bg_prichatlist/Scroll View"):GetComponent("UIScrollView")
	bg_privateList.grid = transform:Find("Container/bg_frane/bg_prichatlist/Scroll View/Grid"):GetComponent("UIGrid")
	table.insert(_ui , bg_privateList)
	
	bg_privatePlayer = {}
	bg_privatePlayer.trf = transform:Find("Container/bg_frane/bg_prichat")
	bg_privatePlayer.scrollView = transform:Find("Container/bg_frane/bg_prichat/Scroll View")
	bg_privatePlayer.grid = transform:Find("Container/bg_frane/bg_prichat/Scroll View/Grid"):GetComponent("UIGrid")
	table.insert(_ui , bg_privatePlayer)
	
	panel_box = {}
	panel_box.go = transform:Find("Panel_box")
	panel_box.btnInfo = transform:Find("Panel_box/bg_box/btn_information"):GetComponent("UIButton")
	panel_box.btnCopy = transform:Find("Panel_box/bg_box/btn_copy"):GetComponent("UIButton")
	panel_box.name = ""
	table.insert(_ui , panel_box)
	
	chatContentList.scrollView.onDragMove =  OnDrag
	chatContentList.scrollView.onDragStarted = OnDragStart
	chatContentList.scrollView.onDragFinished = OnDragFinish
	table.insert(_ui , chatContentList)
	
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	
	translateCoroutine = nil
	translateMap = nil
	recvList = {}

	ChatData.AddListener(NotifyChanelChat)
	--ChatData.AddListener(UpdateTabInfo)
	UnionInfoData.AddListener(CheckLeaveUnion)
	
	_ui.time = transform:Find("Container/bg_frane/time"):GetComponent("UILabel")
	_ui.time.gameObject:SetActive(true)
	
	_ui.timecoroutine = coroutine.start(function()

		local serverTimeSec = 0
		while true do
			if _ui == nil then 
				break
			end 
			local passSec = Serclimax.GameTime.GetSecTime() - serverTimeSec
			_ui.time.text = Global.SecondToStringFormat(serverTimeSec + passSec , "yyyy-MM-dd HH:mm:ss")--Serclimax.GameTime.MilSecToString(0)
			coroutine.wait(1)
		end
	end)
	
end

function Start()
print("chat start")
	isNewPrivateMessageViewed = true
	RallyCount = 0
	MaxRallyCount = 0
	curChanel = -1
	local lockBuild = maincity.GetBuildingByID(1)
	local lockLevel = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ChatUnlock).value)
	if Global.DistributeInHome() then
		lockLevel = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ChatUnlockInHome).value)
	end
	if lockBuild == nil or lockBuild.data.level < lockLevel then
		chatLock = true
		bg_bottom.inputLock.gameObject:SetActive(false)
		bg_bottom.inputunLock.gameObject:SetActive(true)
		local locktext = bg_bottom.inputunLock.text
		bg_bottom.inputunLock.text = System.String.Format(TextMgr:GetText("chat_hint2") ,lockLevel )
		bg_bottom.input.label = bg_bottom.inputunLock
		bg_bottom.input.enabled = false
		bg_bottom.inputCollider.enabled = false
	else
		chatLock = false
		bg_bottom.inputLock.gameObject:SetActive(true)
		bg_bottom.inputunLock.gameObject:SetActive(false)
		bg_bottom.input.label = bg_bottom.inputLock
	end
	
	if UnionInfoData.HasUnion() then
		bg_tab[ChatMsg_pb.chanel_guild].transform:GetComponent("UIToggle").enabled = true
	else
		bg_tab[ChatMsg_pb.chanel_guild].transform:GetComponent("UIToggle").enabled = false
	end
	
	UpdateTabRedPoint()
	MainCityUI.SetChatPreviewRedPoint(false)
	TranslateChatContent()
	
	local chatTab = Global.GetChatEnterChanel()
	if privateChat ~= nil then
		PrivateChat(privateChat.name , privateChat.charid , privateChat.banner , privateChat.offid, privateChat.guildOfficialId)
		bg_tab[ChatMsg_pb.chanel_private].transform:GetComponent("UIToggle"):Set(true)
		
	elseif privateShare ~= nil or chatTab == ChatMsg_pb.chanel_private or chatTab == ChatMsg_pb.chanel_discussiongroup then
		UpdatePrivateContent()
		bg_tab[ChatMsg_pb.chanel_private].transform:GetComponent("UIToggle"):Set(true)
	else
		UpdateChatContent(chatTab)
	end
	
	
	
end

function Close()
	ChatData.SaveChatList()
	MainCityUI.PreviewChanelChange()
	MainCityUI.SetChatPreviewRedPoint(false)
	bg_tab = nil
	bg_bottom = nil 
	bg_mid = nil
	bg_top = nil
	chatContentList = nil
	translateMap = nil
	privateShare = nil
	privateChat = nil
	groupDataMap = nil
	curChanel = -1
	bg_privateList = nil
	_ui = nil

	--集结分享倒计时
	if MaxRallyCount > 0 then 
		for i = 1, MaxRallyCount do
			CountDown.Instance:Remove("Rally"..i)
		end
	end
	
	ChatData.RemoveListener(NotifyChanelChat)
    UnionInfoData.RemoveListener(CheckLeaveUnion)
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	
	if translateCoroutine ~= nil then
		coroutine.stop(translateCoroutine)
		translateCoroutine = nil
	end
	if CloseCallBack ~= nil then
		CloseCallBack()
		CloseCallBack = nil
	end
end


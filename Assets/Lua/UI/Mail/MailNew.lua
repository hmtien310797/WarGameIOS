module("MailNew", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback

local mailInfoItem
local mailListGrid
local mailContent

local curTabSelect = -1
local mailNew = {}

local maildata
local defultTarget
local defaultContent
local mainMailNewUI
local unionMemberMail

local closeCallback = nil

local customCallBack = nil

function SetCustomCallBack(callback)
	customCallBack = callback
end

function SetCloseCallBack(callback)
	closeCallback = callback
end

function NotifyMail()
	print("MailNotify")
end

function SetMailData(mdata)
	maildata = mdata
end

function SendGovMail()
	local mailNewInputName = mainMailNewUI:Find("bg_frane/bg_msg/frame_input"):GetComponent("UIInput")
	local mailNewInputContent = mainMailNewUI:Find("bg_frane/frame_input/Scroll View/text"):GetComponent("UILabel")
	
	local sendReq = MapMsg_pb.MsgGovernmentSendZoneMailRequest()
	sendReq.title = "tittle?"--mailNew.titile.text
	sendReq.content = mailNewInputContent.text
	sendReq.clientlangcode = Global.GTextMgr:GetCurrentLanguageID()
	
	local sendFunc = function()
		Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgGovernmentSendZoneMailRequest, sendReq, MapMsg_pb.MsgGovernmentSendZoneMailResponse, function(msg)
			--MailListData.SetData(msg.maillist)
			if msg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(msg.code)
				return
			else
				AudioMgr:PlayUISfx("SFX_ui02", 1, false)
				FloatText.Show(TextMgr:GetText("mail_ui36") , Color.white)
				
				if closeCallback ~= nil then
					closeCallback()
				end
				Hide()
				
			end
		end)
	end
	
	Global.RequestChatInvalidCSharp("mail" , mailNewInputContent.text , function(success , ad , sns)
		if (success == 0) then
			if ad == nil and sns == nil then
				print("聊天信息采集阶段")
				sendFunc()
				return
			end
			
			local adjust = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ChatFilterADJust).value)
			local snsjust = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ChatFilterSNSJust).value)
			if ad < adjust and sns < snsjust then
				sendFunc()
			elseif ad >= adjust then
				MessageBox.Show(TextMgr:GetText("Code_Chat_AD"))
			elseif sns >= snsjust then
				MessageBox.Show(TextMgr:GetText("Code_Chat_ExternalSns"))
			else
				--MessageBox.Show("请勿发送垃圾信息！")
			end
		else
			--MessageBox.Show("发送失败")
		end
		
	end)
end

local function SendUnionMail()
	local mailNewInputName = mainMailNewUI:Find("bg_frane/bg_msg/frame_input"):GetComponent("UIInput")
	local mailNewInputContent = mainMailNewUI:Find("bg_frane/frame_input/Scroll View/text"):GetComponent("UILabel")
	
	local sendReq = GuildMsg_pb.MsgSendGuildMailRequest()
	sendReq.title = "tittle?"--mailNew.titile.text
	sendReq.content = mailNewInputContent.text
	sendReq.clientLangCode = Global.GTextMgr:GetCurrentLanguageID()
	
	local sendFunc = function()
		Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgSendGuildMailRequest, sendReq, GuildMsg_pb.MsgSendGuildMailResponse, function(msg)
			--MailListData.SetData(msg.maillist)
			if msg.code ~= ReturnCode_pb.Code_OK then
				if msg.code == 504 then --禁言
					MessageBox.ShowCountDownMsg(TextMgr:GetText("Forbidden_4"), msg.forbidtime)--ShowCountDownMsg
				else
					Global.ShowError(msg.code)
				end
			else
				AudioMgr:PlayUISfx("SFX_ui02", 1, false)
				FloatText.Show(TextMgr:GetText("mail_ui36") , Color.white)
				Global.SetMailIntvContinuesTime(GameTime.GetSecTime() , MailMsg_pb.MailType_User)
				
				if closeCallback ~= nil then
					closeCallback()
				end
				Hide()
			end
		end)
	end
	
	Global.RequestChatInvalidCSharp("mail" , mailNewInputContent.text , function(success , ad , sns)
		if (success == 0) then
			if ad == nil and sns == nil then
				print("聊天信息采集阶段")
				sendFunc()
				return
			end
			
			local adjust = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ChatFilterADJust).value)
			local snsjust = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ChatFilterSNSJust).value)
			if ad < adjust and sns < snsjust then
				sendFunc()
			elseif ad >= adjust then
				MessageBox.Show(TextMgr:GetText("Code_Chat_AD"))
			elseif sns >= snsjust then
				MessageBox.Show(TextMgr:GetText("Code_Chat_ExternalSns"))
			else
				--MessageBox.Show("请勿发送垃圾信息！")
			end
		else
			--MessageBox.Show("发送失败")
		end
		
	end)
	
end

local function SendNormailMail()
	local mailNewInputName = mainMailNewUI:Find("bg_frane/bg_msg/frame_input"):GetComponent("UIInput")
	local mailNewInputContent = mainMailNewUI:Find("bg_frane/frame_input/Scroll View/text"):GetComponent("UILabel")

	
	local sendReq = MailMsg_pb.MsgUserMailSendRequest()
	sendReq.title = "tittle?"--mailNew.titile.text
	sendReq.content = mailNewInputContent.text
	sendReq.clientlangcode = Global.GTextMgr:GetCurrentLanguageID()
	local targets = mailNewInputName.value:split(";")
	
	for _ , v in ipairs(targets) do
		sendReq.targetname:append(v)
	end
	
	local sendFunc = function()
		Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailSendRequest, sendReq, MailMsg_pb.MsgUserMailSendResponse, function(msg)
			--MailListData.SetData(msg.maillist)
			if msg.code ~= ReturnCode_pb.Code_OK then
				if msg.code == 504 then --禁言
					--FloatText.Show(System.String.Format(TextMgr:GetText("Forbidden_4") , msg.forbidtime - GameTime.GetSecTime()) , Color.red)
					MessageBox.ShowCountDownMsg(TextMgr:GetText("Forbidden_4"), msg.forbidtime)--ShowCountDownMsg
				else
					Global.ShowError(msg.code)
				end
			else
				AudioMgr:PlayUISfx("SFX_ui02", 1, false)
				FloatText.Show(TextMgr:GetText("mail_ui36") , Color.white)
				
				if closeCallback ~= nil then
					closeCallback()
				end
				Hide()
				--mailNew.inputName.go.gameObject:SetActive(true)
				
				Global.SetMailIntvContinuesTime(GameTime.GetSecTime() , MailMsg_pb.MailType_User)
			end
		end)
	end
	
	Global.RequestChatInvalidCSharp("mail" , mailNewInputContent.text , function(success , ad , sns)
		if (success == 0) then
			if ad == nil and sns == nil then
				print("聊天信息采集阶段")
				sendFunc()
				return
			end
			
			local adjust = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ChatFilterADJust).value)
			local snsjust = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ChatFilterSNSJust).value)
			if ad < adjust and sns < snsjust then
				sendFunc()
			elseif ad >= adjust then
				MessageBox.Show(TextMgr:GetText("Code_Chat_AD"))
			elseif sns >= snsjust then
				MessageBox.Show(TextMgr:GetText("Code_Chat_ExternalSns"))
			else
				--MessageBox.Show("请勿发送垃圾信息！")
			end
		else
			--MessageBox.Show("发送失败")
		end
		
	end)
end

local function SendMail()
	local cd  = Global.GetMailIntvContinuesCD(GameTime.GetSecTime() , MailMsg_pb.MailType_User)
	print(cd)
	if cd > 0 then
		FloatText.Show(System.String.Format(TextMgr:GetText("Forbidden_3") , cd) , Color.red)
		return
	end
		
	if maildata ~= nil and maildata.unionMember ~= nil then
		SendUnionMail()
	else
		local lockBuild = maincity.GetBuildingByID(1)
		local lockLevel = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.SendMailUnlock).value)
		if Global.DistributeInHome() then
			lockLevel = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.SendMailUnlockInHome).value)
		end
		
		if lockBuild == nil or lockBuild.data.level < lockLevel then
			FloatText.Show(System.String.Format(TextMgr:GetText("send_mail_msg") , lockLevel) , Color.red)
			return
		end
		SendNormailMail()
	end
end

function CheckMailVaild()
	local mailNewInputName = mainMailNewUI:Find("bg_frane/bg_msg/frame_input"):GetComponent("UIInput")
	if mailNewInputName.value == "" then
		AudioMgr:PlayUISfx("SFX_ui02", 1, false)
		FloatText.Show(TextMgr:GetText("mail_ui38"))
		return false
	end
	
	local contentInput = mainMailNewUI:Find("bg_frane/frame_input"):GetComponent("UIInput")
	if contentInput.value == "" then
		AudioMgr:PlayUISfx("SFX_ui02", 1, false)
		FloatText.Show(TextMgr:GetText("mail_ui39"))
		return false
	end

	return true
end

function OpenUI()
	--relay
	print("openNew")
	
	--[[
	local openCorountin = coroutine.start(function()
		coroutine.step()
		local mailNewInputName = mainMailNewUI:Find("bg_frane/bg_msg/frame_input"):GetComponent("UIInput")
		if maildata ~= nil then
			mailNewInputName.value = maildata.fromname
		else
			mailNewInputName.value = defultTarget
		end
	end)]]
	
	
	local mailNewInputName = mainMailNewUI:Find("bg_frane/bg_msg/frame_input"):GetComponent("UIInput")
	local mailNewInputContent = mainMailNewUI:Find("bg_frane/frame_input"):GetComponent("UIInput")
	
	if maildata ~= nil then
		mailNewInputName.value = maildata.fromname
		if maildata.unionMember ~= nil then
			mailNewInputName.enabled = false
		else
			mailNewInputName.enabled = true
		end
		mailNewInputContent.value = ""
	else
		mailNewInputName.enabled = true
		mailNewInputName.value = ""
		mailNewInputContent.value = ""
	end	

	if customCallBack ~= nil then
		customCallBack("SetGovInputName",mailNewInputName)
		customCallBack("SetSendBtn",mainMailNewUI:Find("bg_frane/bg_bottom/btn_send"))
	end
end

function Init()
end


function Hide()
	Global.CloseUI(_M)
end

function CloseUI()
	Hide()
end

function Close()
	mailNew = nil
	mainMailNewUI = nil
	customCallBack = nil
	maildata = nil
	closeCallback = nil
end


function Awake()
	mainMailNewUI = transform:Find("MailNew")
	local mailTransform = transform:Find("InputName")
	mailNew = {}
	mailNew.content = mainMailNewUI:Find("bg_frane/frame_input/Scroll View/text"):GetComponent("UILabel")
	mailNew.target = mainMailNewUI:Find("bg_frane/bg_msg/bg_name/text_name"):GetComponent("UILabel")
	mailNew.title = "titile?"
	
	mailNew.inputName = {}
	mailNew.inputName.go = transform:Find("InputName")
	mailNew.inputName.nameText = mailTransform:Find("frame_input/title"):GetComponent("UILabel")
	mailNew.inputName.okBtn = mailTransform:Find("btn_confirm"):GetComponent("UIButton")
	mailNew.inputName.closeBtn = mailTransform:Find("btn_close"):GetComponent("UIButton")
	
	defultTarget = mailNew.inputName.nameText.text
	defaultContent = mailNew.content.text
	
	SetClickCallback(mailNew.inputName.closeBtn.gameObject , function(go)
		mailNew.inputName.go.gameObject:SetActive(false)
	end)
	SetClickCallback(mailNew.inputName.okBtn.gameObject , function(go)
		local nameLegalReq = ClientMsg_pb.MsgCheckPlayerExitRequest()
		local name = mailNew.inputName.nameText.text
		nameLegalReq.names:append(name)
		Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCheckPlayerExitRequest, nameLegalReq, ClientMsg_pb.MsgCheckPlayerExitResponse, function(msg)
			if msg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(msg.code)
				return
			else
				local canUse = true
				for _ ,v in ipairs(msg.names) do
					if name == v then
						canUse = false
					end
				end
				if canUse then
					mailNew.target.text = name
					mailNew.inputName.go.gameObject:SetActive(false)
				else
					AudioMgr:PlayUISfx("SFX_ui02", 1, false)
					FloatText.Show(TextMgr:GetText("player_ui26"))
				end
			end
		end)
	end)
	
	local closeBtn = mainMailNewUI:Find("bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(closeBtn.gameObject , function(go)
		if closeCallback ~= nil then
			closeCallback()
		end
		
		Hide()
	end)
	
	SetClickCallback(mainMailNewUI.gameObject , function(go)
		if closeCallback ~= nil then
			closeCallback()
		end
		Hide()
	end)
	
	local clearBtn = mainMailNewUI:Find("bg_frane/bg_bottom/btn_del"):GetComponent("UIButton")
	SetClickCallback(clearBtn.gameObject , function(go)
		print("clear content")
		local contentInput = mainMailNewUI:Find("bg_frane/frame_input"):GetComponent("UIInput")
		contentInput.value = ""
	end)
	local sendBtn = mainMailNewUI:Find("bg_frane/bg_bottom/btn_send"):GetComponent("UIButton")
	SetClickCallback(sendBtn.gameObject , function(go)
		--print("send content")
		local mailNewInputName = mainMailNewUI:Find("bg_frane/bg_msg/frame_input"):GetComponent("UIInput")
		if not CheckMailVaild() then
			return
		end
		
		local nameLegalReq = ClientMsg_pb.MsgCheckPlayerExitRequest()
		local strName = mailNewInputName.value:split(";")
		for _,v in ipairs(strName) do
			nameLegalReq.names:append(v)
		end
		
		SendMail()
	end)
	
	local selectPlayerBtn = mainMailNewUI:Find("bg_frane/bg_msg/btn_select"):GetComponent("UIButton")
	SetClickCallback(selectPlayerBtn.gameObject , function(go)
		print("selectPlayerBtn")
	end)
	local groupSendBtn = mainMailNewUI:Find("bg_frane/bg_msg/btn_groupsend"):GetComponent("UIButton")
	SetClickCallback(groupSendBtn.gameObject , function(go)
		print("groupSendBtn")
	end)
	
end

function Start()
	
end

function Show(maildata)
	Global.OpenUI(_M)
	
	SetMailData(maildata)
	OpenUI()
end
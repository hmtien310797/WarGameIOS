module("GroupSetting", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback
local GameObject = UnityEngine.GameObject

local _container

local data
local groupId
local deleteCallback
local removeCallback
local quitCallback

local OnGroupMemMgr
local confirmList

local function CloseSelf()
	Global.CloseUI(_M)
	_container = nil
end

local function QuitGroup()
	MessageBox.Show(TextMgr:GetText("chat_group_ui13") , 
	function() 
		local send = {}
		send.curChanel = ChatMsg_pb.chanel_discussiongroup
		send.spectext = ""
		send.content = "chat_group_ui7"..","..MainData.GetCharName()
		send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
		send.chatType = 4
		send.groupid = groupId
		print("Groupsetting QuitGroup :" , groupId , MainData.GetCharName())
		--send.senderguildname = UnionInfoData.GetData().guildInfo.name
		Chat.SendGroupContent(send)
		
		local oplist = {}
		table.insert(oplist , MainData.GetCharId())
		GroupChatData.RequestGroupMemMgr(groupId , ChatMsg_pb.ChatDiscGroupMemOpt_Delete , oplist , 
		function()
			FloatText.Show(TextMgr:GetText("chat_group_ui19")   , Color.green) --"已退出该讨论组"

			if quitCallback ~= nil then
				quitCallback()
			end
			
			CloseSelf()
		end) 
	end , 
	function() end)
	
end

local function RemoveGroupMem()
	local optlist = {}
	local gd = GroupChatData.GetGroupData(groupId)
	
	local contentName = ""
	local addlist = {}
	for _ , v in pairs(confirmList) do
		if v ~= nil then
			table.insert(optlist, v.user.charid)
			contentName = contentName == "" and v.user.name or contentName .. " ，" .. v.user.name
		end
	end
	
	--[[for i=1 , _container.Grid.transform.childCount , 1 do
		local item = _container.Grid.transform:GetChild(i-1)
		if item.name ~= "setting_add" then
			local checkBox = item:Find("bg/checkbox"):GetComponent("UIToggle")
			if checkBox.value and gd.mem[i].user.charid ~= MainData.GetCharId() then
				table.insert(optlist, gd.mem[i].user.charid)
				contentName = contentName == "" and gd.mem[i].user.name or contentName .. " ，" .. gd.mem[i].user.name
			end
		end
	end]]
	
	if #optlist == 0 then
		FloatText.Show(TextMgr:GetText("chat_group_ui16") , Color.red)
		return
	end
	
	MessageBox.Show(TextMgr:GetText("chat_group_ui8"),--"是否确认移除一下成员" , 
	function() 
		GroupChatData.RequestGroupMemMgr(groupId , ChatMsg_pb.ChatDiscGroupMemOpt_Remove , optlist , 
		function()
			FloatText.Show(System.String.Format(TextMgr:GetText("chat_group_ui15"),contentName)   , Color.green)
			local send = {}
			send.curChanel = ChatMsg_pb.chanel_discussiongroup
			send.spectext = ""
			send.content = "chat_group_ui15"..","..contentName
			send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
			send.chatType = 4
			send.groupid = groupId
			print("Groupsetting RemoveGroupMem :" , groupId , contentName)
			--send.senderguildname = UnionInfoData.GetData().guildInfo.name
			Chat.SendGroupContent(send)
			
			if removeCallback ~= nil then
				removeCallback()
			end
			
			CloseSelf()
		end) 
	end , 
	function() end)
	
	
end

local function DeleteGroup()
	MessageBox.Show(TextMgr:GetText("chat_group_ui10") , 
	function() 
		GroupChatData.RequestGroupMemMgr(groupId , ChatMsg_pb.ChatDiscGroupMemOpt_RemoveAll , nil , 
			function()
				FloatText.Show(TextMgr:GetText("chat_group_ui11")   , Color.green)
				--print("uuuuuuuuuuuuu" , deleteCallback)

				if deleteCallback ~= nil then
					deleteCallback()
				end
				
				CloseSelf()
			end) 
	end , 
	function() end)
	
end


local function LoadUI()
	transform:Find("Container/bg_frane/bg_bottom/btn2").gameObject:SetActive(false)
	local gd = GroupChatData.GetGroupData(groupId)
	local isCreater = GroupChatData.GetGroupCreate(gd) and GroupChatData.GetGroupCreate(gd).user.charid == MainData.GetCharId() or false
	
	if gd ~= nil then
		_container.title.text = gd.name
		local childcount = _container.Grid.transform.childCount
		if childcount > 0 then
			_container.ItemAdd.transform:SetParent(_container.container.transform , false)
			while _container.Grid.transform.childCount > 0 do
				GameObject.DestroyImmediate(_container.Grid.transform:GetChild(0).gameObject)
			end
		end
		
		
		for i=1 , #gd.mem , 1 do
			if not gd.mem[i].removed then
				local v = gd.mem[i]
				local listitem = NGUITools.AddChild(_container.Grid.gameObject , _container.item).transform
				listitem.name = v.user.charid
				local itemIcon = listitem:Find("bg/bg_touxiang/icon_touxiang"):GetComponent("UITexture")
				itemIcon.mainTexture = ResourceLibrary:GetIcon("Icon/head/", v.user.face)
				
				local bgIcon = listitem:Find("bg/bg_touxiang"):GetComponent("UISprite")
				bgIcon.spriteName = string.format("bg_avatar_vip%s" , math.ceil(v.user.viplevel/5))
				
				local itemVip = listitem:Find("bg/bg_touxiang/bg_vip")
				itemVip.gameObject:SetActive(v.user.viplevel > 0)
				itemVip:Find("icon"):GetComponent("UISprite").spriteName = string.format("bg_avatar_num_vip%s" , math.ceil(v.user.viplevel/5))
				itemVip:Find("num"):GetComponent("UILabel").text = string.format("VIP%s" , v.user.viplevel)
				
				local itemName = listitem:Find("bg/name"):GetComponent("UILabel")
				local exStr = ""
				if v.user.guildBanner ~= nil and v.user.guildBanner ~= "" then
					exStr = "[f1cf63]【".. v.user.guildBanner .. "】[-]"
				end
				itemName.text = exStr.. v.user.name
				
				local tog = listitem:Find("bg/checkbox"):GetComponent("UIToggle")
				tog.gameObject:SetActive(isCreater)
				if v.user.charid == MainData.GetCharId() then
					tog.gameObject:SetActive(false)
				end
				
				local touxiang = listitem:Find("bg/bg_touxiang")
				SetClickCallback(touxiang.gameObject , function()
					OtherInfo.RequestShow(v.user.charid)
				end)
				
				EventDelegate.Set(tog.onChange,EventDelegate.Callback(function(obj,delta)
					if tog.value then
						confirmList[v.user.charid] = v
					else
						confirmList[v.user.charid] = nil
					end
				end))
		
			end
		end
		
		_container.ItemAdd.transform:SetParent(_container.Grid.transform , false)
		local additemBg = _container.ItemAdd.transform:Find("bg/bg_touxiang").gameObject
		SetClickCallback(additemBg , function()
			local initlist = {}
			for i=1 , #gd.mem , 1 do
				if not gd.mem[i].removed then
					table.insert(initlist , gd.mem[i].user.charid)
				end
			end
			GroupSelectList.Show(initlist , OnGroupMemMgr)
		end)
		_container.Grid:Reposition()
		
	end
	
	SetClickCallback(_container.btn_bottom2.gameObject , function()
		RemoveGroupMem()
	end)
	
	SetClickCallback(_container.btn_bottom1.gameObject , function()
		DeleteGroup()
	end)
	
	SetClickCallback(_container.btn_bottom3.gameObject , function()
		QuitGroup()
	end)
	
	_container.btn_bottom1.gameObject:SetActive(isCreater)
	_container.btn_bottom2.gameObject:SetActive(isCreater)
	_container.btn_bottom3.gameObject:SetActive(not isCreater)
	
end

OnGroupMemMgr = function (addlist)
	if addlist == nil or #addlist == 0 then
		FloatText.Show(TextMgr:GetText("chat_group_ui14") , Color.red)
		return false
	end
		
	local gd = GroupChatData.GetGroupData(groupId)
	local req = ChatMsg_pb.MsgChatDiscGroupMemberMgrRequest()
	req.data.id = groupId
	req.data.name = gd.name
	req.data.opt = ChatMsg_pb.ChatDiscGroupMemOpt_Add
	
	local contentName = ""
	for i=1 , #addlist , 1 do
		--print("==============" , addlist[i].charId)
		local c = req.data.mem:append(addlist[i].charId)
		contentName = contentName == "" and addlist[i].name or contentName .. "，" .. addlist[i].name
	end
	
	--Global.DumpMessage(req , "d:/chatgroup.lua")
	Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatDiscGroupMemberMgrRequest, req, ChatMsg_pb.MsgChatDiscGroupMemberMgrResponse, function(msg)		
		--Global.DumpMessage(msg , "d:/chatgroup.lua")
        if msg.code ~= ReturnCode_pb.Code_OK then
		    Global.ShowError(msg.code)
		else
			GroupChatData.UpdateData(msg.data)
			Chat.ChatUpdateDiscGroupContent(msg.data , addlist)
			LoadUI()
			
			local send = {}
			send.curChanel = ChatMsg_pb.chanel_discussiongroup
			send.spectext = ""
			send.content = "chat_group_ui12"..","..contentName
			send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
			send.chatType = 4
			send.groupid = groupId
			--print("Groupsetting OnGroupMemMgr :" , groupId , contentName)
			--send.senderguildname = UnionInfoData.GetData().guildInfo.name
			Chat.SendGroupContent(send)
			--CloseSelf()
		end
	end, true)
	
	return true
end


function Awake()
	_container = {}
	_container.container = transform:Find("Container").gameObject
	_container.btn_close = transform:Find("Container/bg_frane/btn_close").gameObject
	_container.title = transform:Find("Container/bg_frane/bg_top/name"):GetComponent("UILabel")
	_container.titleBtn = transform:Find("Container/bg_frane/bg_top/btn").gameObject
	
	--_container.ScrollView = transform:Find("Container/bg_frane/bg_mid/Scroll View"):GetComponent("UIScrollView")
	_container.Grid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	_container.btn_bottom1 = transform:Find("Container/bg_frane/bg_bottom/btn1").gameObject
	_container.btn_bottom2 = transform:Find("Container/bg_frane/bg_bottom/btn2").gameObject
	_container.btn_bottom3 = transform:Find("Container/bg_frane/bg_bottom/btn3").gameObject
	
	_container.item = transform:Find("Container/setting_info").gameObject
	_container.ItemAdd = transform:Find("Container/setting_add").gameObject
	
	_container.ItemAddBg = transform:Find("Container/setting_add/bg/bg_touxiang").gameObject
end

local function ChangeNameInitFunc(trf)
	local gd = GroupChatData.GetGroupData(groupId)
	trf:Find("Container/bg_frane/random btn").gameObject:SetActive(false)
	trf:Find("Container/bg_frane/hint").gameObject:SetActive(false)
	trf:Find("Container/bg_frane/hint1").gameObject:SetActive(false)
	
	trf:Find("Container/bg_frane/frame_input"):GetComponent("UIInput").value = gd.name
end

local function ChangeNameSureFunc(changeTxt)

	MessageBox.Show(TextMgr:GetText("chat_group_ui17") ,--"是否确认修改为该名字" , 
	function() 
		GroupChatData.RequestGroupMemMgr(groupId , ChatMsg_pb.ChatDiscGroupMemOpt_Rename , nil , 
		function()
			FloatText.Show(TextMgr:GetText("player_ui11")   , Color.green) -- "讨论组改名已成功"

			if quitCallback ~= nil then
				quitCallback()
			end
			
			GUIMgr:CloseMenu("ChangeName")
			CloseSelf()
		end ,changeTxt ) 
	end , 
	function() end)
	
end

function Start()
	SetClickCallback(_container.container, CloseSelf)
	SetClickCallback(_container.btn_close, CloseSelf)
	
	confirmList = {}
	local gd = GroupChatData.GetGroupData(groupId)
	_container.titleBtn.gameObject:SetActive(MainData.GetCharId() == GroupChatData.GetGroupCreate(gd).user.charid)

	SetClickCallback(_container.titleBtn, function()
		ChangeName.SetFunc(ChangeNameInitFunc , nil , ChangeNameSureFunc)
		GUIMgr:CreateMenu("ChangeName" , false)
	end)
	
end

function Show(groupid , del_cb , rm_cb , qt_cb)
	--data = _data
	groupId = groupid
	deleteCallback = del_cb
	removeCallback = rm_cb
	quitCallback = qt_cb
	
	Global.OpenUI(_M)
	
	LoadUI()
end

function Close()
	deleteCallback = nil
	removeCallback = nil
	quitCallback = nil
	_container = nil
	confirmList = nil
end

module("GuildMobaChatData", package.seeall)
local TableMgr = Global.GTableMgr
local GameTime = Serclimax.GameTime
local TextMgr = Global.GTextMgr

local eventListener = EventListener()
local chatInfoList
local chatNextTime = 0

local totalChat = nil
local nationChatList = {}
local unionChatList = {}
local groupChatData = {}
local unionMessageChatListSelf = {}
local unionMessageChatListOther = {}
local privateChatList = {}
local showChatList = {}

local BlackList = {}

local translateEnable = false
local autoTranslate = false
local newGuildChat = 0 

local recordChatIndex = 0

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function GetUnreadGuildCount()
	return newGuildChat
end

function SetUnreadGuildCount(count)
	newGuildChat = count
end

function GetPrivateNew()
	local sort_table = {}
	for k, v in pairs(privateChatList) do
		if v ~= nil then
			local data = {name=k , lastTime=v[#(v)].time}
			print(k , v)
			table.insert(sort_table , data)
		end
	end
	
	table.sort(sort_table , function(v1, v2)
		return v1.lastTime > v2.lastTime
	end)
	
	print(#sort_table)
	return sort_table--totalChat[ChatMsg_pb.chanel_private]
end

function GetPrivateChat(sKey)
	return privateChatList[sKey]
end



function GetUnreadPrivateCount()
	local new = 0
	for _ , v in pairs(privateChatList) do
		if v ~= nil then
			for i=1 , #v , 1 do
				if v[i].sender.charid ~= MainData.GetCharId() then
					new = new + 1
				end
			end
		end
	end
	new = new + Global.GFileRecorder:HaveUnSavedRecord()

	return new
end

function GetPlayerUnreadPrivateContent(pName , pId)
	local new = 0
	local pKey = string.format("%s,%s" , pName , pId)
	if privateChatList[pKey] ~= nil then
		for i=1 , #(privateChatList[pKey]) , 1 do
			local chatData = privateChatList[pKey][i]
			if chatData.sender.charid ~= MainData.GetCharId() then
				new = new + 1
			end
		end
		--new = #privateChatList[pKey]
	end
	
	new = new + Global.GFileRecorder:HaveUnSavedPlayerRecord(pName)
	return new
end

function ClearChatData(chatChanel)
	if totalChat ~= nil and totalChat[100] ~= nil then
		totalChat[chatChanel] = nil
		unionChatList = {}
		
		for i = table.getn(totalChat[100]) , 1 , -1 do
			if totalChat[100][i] ~= nil and totalChat[100][i].chanel == chatChanel then
				table.remove(totalChat[100],i)
			end
		end
		NotifyListener()
	end
end

function SetNextTime(nextTime)
	if nextTime == 0 then
		chatNextTime = Serclimax.GameTime.GetSecTime() + 1
	else
		chatNextTime = Serclimax.GameTime.GetSecTime() + nextTime
	end
end

function GetNextTime()
	return chatNextTime
end

function SetTranslateEnable(auto , enable)
	----print("----------SetTranslateEnable" , enable)
	autoTranslate = auto
	translateEnable = enable
end

function GetTranslateEnable()
	return translateEnable
end

function AutoTranslate()
	return autoTranslate
end

local tRecord = {}
function GetChatRecordTable()
	return tRecord
end

function SavePlayerChat(pName , pId , forceSaveConfig)
	print("======ChatData.SavePlayerChat()====")
	if Global.GFileRecorder ~= nil then
		local pKey = string.format("%s,%s" , pName , pId)
		if Global.GFileRecorder.charRecordsCfg[pName] ~= nil then
			Global.GFileRecorder.charRecordsCfg[pName].saveTime = Serclimax.GameTime.GetSecTime()
		end
		
		local saveData = {}
		saveData[pKey] = privateChatList[pKey]
		Global.GFileRecorder:SaveRecordData(saveData , forceSaveConfig)
		privateChatList[pKey] = nil
	end
end

function SaveChatList(callback)
	print("======ChatData.SaveChatList()====")
	if Global.GFileRecorder ~= nil then
		Global.GFileRecorder:SaveRecordData(privateChatList)
		privateChatList = {}
		if totalChat ~= nil then
			totalChat[200] = {}
		end
	end
end

function DeleteChatData(charname ,  charid)
	if Global.GFileRecorder ~= nil then
		local sKey = string.format("%s,%d" , charname , charid)
		if privateChatList[sKey] ~= nil then
			privateChatList[sKey] = nil
		end
		Global.GFileRecorder:DeleteRecord(charname ,  charid)
	end
end



function UpdateNewData(charInfo , auto , transEnable , chatReqInit , flag)
	SetTranslateEnable(auto , transEnable)
	chatInfoList = charInfo
	local guildunread = GetUnreadGuildCount()
	local guildnew = 0
	for _ , v in ipairs(charInfo) do
		if v.chanel == ChatMsg_pb.chanel_GuildMobaWorld then --moba战场
			table.insert(nationChatList , v)
		elseif v.chanel == ChatMsg_pb.chanel_MobaPrivate then   --moba私聊
			if v.sender.charid == MainData.GetCharId() then
				if v.recvlist ~= nil then
					for i=1 , #v.recvlist , 1 do
						local chat = v.recvlist[i]
						local sKey = chat.name..","..chat.charid
						if privateChatList[sKey] == nil then
							privateChatList[sKey] = {}
						end
						table.insert(privateChatList[sKey] , v)
						--print("chatdata UpdateNewData:" .. sKey  , v)
					end
				end
			else
				local sKey = v.sender.name..","..v.sender.charid
				if privateChatList[sKey] == nil then
					privateChatList[sKey] = {}
				end
				table.insert(privateChatList[sKey] , v)
			end
		elseif v.chanel == ChatMsg_pb.chanel_GuildMobaTeam then -- moba阵营
			table.insert(unionChatList , v)
			guildnew = guildnew + 1
		end
	end
	
	if chatReqInit then
		SetUnreadGuildCount(guildunread + guildnew)
	else
		SetUnreadGuildCount(0)
	end
	
	if totalChat == nil then
		totalChat = {}
	end
	
	if totalChat[tonumber(ChatMsg_pb.chanel_GuildMobaWorld)] == nil then
		totalChat[tonumber(ChatMsg_pb.chanel_GuildMobaWorld)] = nationChatList
	end
	
	if totalChat[tonumber(ChatMsg_pb.chanel_MobaPrivate)] == nil then
		totalChat[tonumber(ChatMsg_pb.chanel_MobaPrivate)] = privateChatList
	end

	if totalChat[tonumber(ChatMsg_pb.chanel_GuildMobaTeam)] == nil then
		totalChat[tonumber(ChatMsg_pb.chanel_GuildMobaTeam)] = unionChatList
	end	

	if totalChat[100] == nil then
		totalChat[100] = {}
	end
	
	if totalChat[200] == nil then
		totalChat[200] = {}
	end
	
	if totalChat[300] == nil then
		totalChat[300] = {}
	end

	for _, v in ipairs(charInfo) do
		if v.chanel == ChatMsg_pb.chanel_MobaPrivate then
			table.insert(totalChat[200] , v)
			if #totalChat[200] > 2 then
				table.remove(totalChat[200],1)
			end
		elseif v.chanel == ChatMsg_pb.chanel_GuildMobaTeam then
			table.insert(totalChat[300] , v)
			if #totalChat[300] > 2 then
				table.remove(totalChat[300],1)
			end
		elseif v.chanel == ChatMsg_pb.chanel_GuildMobaWorld then
			table.insert(totalChat[100] , v)
			if #totalChat[100] > 2 then
				table.remove(totalChat[100],1)
			end
		else
			print("---------------undeal chat channel in moba =================:" , v.chanel)
		end
	end

	if guildnew > 0 then
		NotifyListener()
		return
	end
	
	if not flag then
		NotifyListener()
	end
	
end


function UpdateGroupNewData(groupid , charInfo , auto , transEnable , chatReqInit ,flag )
	if flag then
		groupChatData[groupid] = nil
	end
	UpdateNewData(charInfo , auto , transEnable , chatReqInit,flag)
end


function ResetData()
	chatNextTime = 0
	totalChat = nil
	nationChatList = {}
	unionChatList = {}
	privateChatList = {}
	showChatList = {}
end

function GetRecentNewChat(chanel , n)
	local recentNew = {}
	local getNewIndex = 0
	local newIndex = 100
	if chanel == ChatMsg_pb.chanel_MobaPrivate then
		newIndex = 200
	elseif chanel == ChatMsg_pb.chanel_GuildMobaTeam then
		newIndex = 300
	end
	if totalChat ~= nil then
		for i=1 , #totalChat[newIndex] , 1 do
			local idx = #totalChat[newIndex] - getNewIndex
			if totalChat[newIndex][idx] ~= nil then
				
				if getNewIndex < n then
					table.insert(recentNew , totalChat[newIndex][idx])
				else
					return recentNew
				end
			end
			getNewIndex = getNewIndex + 1
		end
	end

	return recentNew
end

function GetLatestChat(n)
	
end

--当前频道新聊天刷新
function GetChanelNewChat(chanel , num , recvList)
	local lastChat = {}
	for _ , v in ipairs(chatInfoList) do
		if v.chanel == chanel then
			----print("insert")
			table.insert(lastChat , v)
		end
	end
	
	local result = {}
	local chanelLength = #lastChat
	local startIndex = math.max(0 , chanelLength - num) + 1
	for i=startIndex , chanelLength do
		table.insert(result , lastChat[i])
	end
	
	return result
end

function GetChatDataLength(chanel , recName,recCharId , recGroupId)
	--print("===GetChatDataLength===" , totalChat)
	local leng = 0
	if totalChat ~= nil then
		local chanelChat = nil 
		chanelChat = totalChat[tonumber(chanel)]
		leng = chanelChat and #chanelChat or 0
	end
	return leng
end


function GetRecordIndex()
	return recordChatIndex
end


function SetRecordIndex(index)
	recordChatIndex = index
	--print("========ChatData SetRecordIndex()===" , recordChatIndex)
end


function InitRecordIndex(chanel , recName,recCharId , groupId)
	local chanelChat =  GetChatDataLength(chanel,recName,recCharId , groupId)
	recordChatIndex = chanelChat
	--print("===ChatData InitRecordIndex()===" , recordChatIndex)
end

function GetGroupRecordChat(groupid)
	local lastChat = {}
	if groupChatData == nil or groupChatData[groupid] == nil then
		return lastChat
	end
	
	
end

--[[
recordChatIndex :已取数量
num：获取数量
chanel:频道
]]
function GetChanelRecordChat(chanel , num , recName , recCharId , recGroupId)
	--print("========GetChanelRecordChat=======")
	local lastChat = {}
	if totalChat == nil then
		return lastChat
	end
	
	
	local chanelChat = {}
	if chanel == ChatMsg_pb.chanel_MobaPrivate then
		local skey = recName.. ",".. recCharId
		chanelChat = privateChatList[skey]
	else
		chanelChat = totalChat[tonumber(chanel)]
	end
	local chanelLength = chanelChat and #chanelChat or 0

	local endIndex = math.max(1 , recordChatIndex)
	endIndex = math.min(chanelLength , recordChatIndex)
	
	local startIndex = math.max( 1 , endIndex - num + 1)
	if recordChatIndex > 0 then 
		for i=startIndex , endIndex do
			table.insert(lastChat , chanelChat[i])
		end
	end
	recordChatIndex = math.max(0 , endIndex - num)
	
	--print("chatData()" ,"start :" .. startIndex .. "end:" .. endIndex , recordChatIndex ,chanelChat)
	return lastChat
end

function GetPrivateRecordData(recName, recCharId, num , update)
	local lastChat = GetChanelRecordChat(ChatMsg_pb.chanel_MobaPrivate , num , recName , recCharId)
	if #lastChat < num then
		local buffchat = {}
		Global.GFileRecorder:GetRecordFromBuff(buffchat , recName , num , update)

		for _ , v in pairs(lastChat) do
			if v~=nil then
				table.insert(buffchat ,  v)
			end
		end
		return buffchat
	end
	return lastChat
end

function RequestPrivateChat()
	local req = GuildMobaMsg_pb.GuildMobaChatInfoListRequest()
	req.languagecode = Global.GGUIMgr:GetSystemLanguage()--Global.GTextMgr:GetCurrentLanguageID()
	req.chanel = ChatMsg_pb.chanel_MobaPrivate
	Global.DumpMessage(req , "d:/privateChat.lua")
	Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaChatInfoListRequest, req, GuildMobaMsg_pb.GuildMobaChatInfoListResponse, function(msg)
	
		Global.DumpMessage(msg , "d:/privateChat.lua")
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		else
			UpdateNewData(msg.infos , msg.autoTrans , msg.transEnable)
			--ChatData.SetNextTime(msg.reqPeriod)
			--ChatData.SetTranslateEnable(msg.transEnable)
			if callback ~= nil then
				callback()
			end	
		end
	end, true)
end

function RequestChatInfo()
	requestChat = true
	--ChatData.ResetData()
	local req = GuildMobaMsg_pb.GuildMobaChatInfoListRequest()
	req.init = true
	req.languagecode = Global.GGUIMgr:GetSystemLanguage() --Global.GTextMgr:GetCurrentLanguageID()
	req.chanel = ChatMsg_pb.chanel_GuildMoba
	Global.DumpMessage(req , "d:/ChatResponseMAIN111.lua")
	Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaChatInfoListRequest, req, GuildMobaMsg_pb.GuildMobaChatInfoListResponse, function(msg)
		Global.DumpMessage(msg , "d:/ChatResponseMAIN111.lua")
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		else
			UpdateNewData(msg.infos, msg.autoTrans , msg.transEnable)
			SetNextTime(msg.reqPeriod)
			requestChat = false
		end
	end, true)
	
	--RequestPrivateChat()
end

function IsInBlackList()
	return false
end

function RequestChat(chanel , callback)
	local req = GuildMobaMsg_pb.GuildMobaChatInfoListRequest()
	req.init = false
	req.languagecode = Global.GGUIMgr:GetSystemLanguage()--Global.GTextMgr:GetCurrentLanguageID()
	req.chanel = chanel == nil and ChatMsg_pb.chanel_GuildMoba or chanel

	Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaChatInfoListRequest, req, GuildMobaMsg_pb.GuildMobaChatInfoListResponse, function(msg)
		--Global.DumpMessage(msg , "d:/ChatResponseMAIN.lua")
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		else
			UpdateNewData(msg.infos, msg.autoTrans , msg.transEnable , true)		
			SetNextTime(msg.reqPeriod)
			if callback ~= nil then
				callback()
			end	
		end
	end, true)
	
	--RequestPrivateChat()
end



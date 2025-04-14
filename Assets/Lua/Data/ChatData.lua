module("ChatData", package.seeall)
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
			table.insert(sort_table , data)
		end
	end
	
	table.sort(sort_table , function(v1, v2)
		return v1.lastTime > v2.lastTime
	end)
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

function UpdatePrivateNewData(charInfo , auto , transEnable , chatReqInit , flag)
	SetTranslateEnable(auto , transEnable)
	chatInfoList = charInfo
	for _ , v in ipairs(charInfo) do
		--if IsInBlackList(v.sender.charid) == false then 
			if v.chanel == ChatMsg_pb.chanel_private then
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
					--print("chatdata UpdateNewData:" .. sKey  , v)
				end
			end
		--end
	end
	
	if totalChat == nil then
		totalChat = {}
	end

	if totalChat[tonumber(ChatMsg_pb.chanel_private)] == nil then
		totalChat[tonumber(ChatMsg_pb.chanel_private)] = privateChatList
	end
	
	for _, v in ipairs(charInfo) do
		--if IsInBlackList(v.sender.charid) == false then
			if v.chanel == ChatMsg_pb.chanel_private then
				Chat.NotifyNewPrivateMessage()
				table.insert(totalChat[200] , v)
				if #totalChat[200] > 2 then
					table.remove(totalChat[200],1)
				end
			end
		--end
	end
	
	if not flag then
		--print("+++++++++++++" , flag , chatReqInit , GetUnreadGuildCount() , guildunread , guildnew)
		NotifyListener()
	end
end


function UpdateNewData(charInfo , auto , transEnable , chatReqInit , flag)
	SetTranslateEnable(auto , transEnable)
	chatInfoList = charInfo
	local guildunread = GetUnreadGuildCount()
	local guildnew = 0
	for _ , v in ipairs(charInfo) do
		--if IsInBlackList(v.sender.charid) == false then 
			if v.chanel == ChatMsg_pb.chanel_world then
				table.insert(nationChatList , v)
			elseif v.chanel == ChatMsg_pb.chanel_private then
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
					--print("chatdata UpdateNewData:" .. sKey  , v)
				end
			elseif v.chanel == ChatMsg_pb.chanel_system then
				table.insert(showChatList , v)
			elseif v.chanel == ChatMsg_pb.chanel_guild then
				table.insert(unionChatList , v)
				guildnew = guildnew + 1
			elseif v.chanel == ChatMsg_pb.chanel_guild_mboard then			
				if v.param == UnionInfoData.GetGuildId() then
					table.insert(unionMessageChatListSelf , v)
				else
					table.insert(unionMessageChatListOther , v)
				end
			elseif v.chanel == ChatMsg_pb.chanel_discussiongroup then
				if groupChatData == nil then
					groupChatData = {}
				end
				if groupChatData[v.param] == nil then
					groupChatData[v.param] = {}
				end
				table.insert(groupChatData[v.param] , v)
				
			end
			
		--end
		
	end
	
	if chatReqInit then
		SetUnreadGuildCount(guildunread + guildnew)
	else
		SetUnreadGuildCount(0)
	end
	
	if totalChat == nil then
		totalChat = {}
	end
	
	if totalChat[tonumber(ChatMsg_pb.chanel_world)] == nil then
		totalChat[tonumber(ChatMsg_pb.chanel_world)] = nationChatList
	end
	
	if totalChat[tonumber(ChatMsg_pb.chanel_private)] == nil then
		totalChat[tonumber(ChatMsg_pb.chanel_private)] = privateChatList
	end

	if totalChat[tonumber(ChatMsg_pb.chanel_system)] == nil then
		totalChat[tonumber(ChatMsg_pb.chanel_system)] = showChatList
	end

	if totalChat[tonumber(ChatMsg_pb.chanel_guild)] == nil then
		totalChat[tonumber(ChatMsg_pb.chanel_guild)] = unionChatList
	end	
	-- if totalChat[tonumber(ChatMsg_pb.chanel_guild_mboard)] == nil then
		totalChat[tonumber(ChatMsg_pb.chanel_guild_mboard)] = unionMessageChatListSelf
	-- end	
	-- if totalChat[400] == nil then
		totalChat[400] = unionMessageChatListOther
	-- end
	
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
		--if IsInBlackList(v.sender.charid) == false then
			if v.chanel == ChatMsg_pb.chanel_private or v.chanel == ChatMsg_pb.chanel_discussiongroup then
				Chat.NotifyNewPrivateMessage()
				table.insert(totalChat[200] , v)
				if #totalChat[200] > 2 then
					table.remove(totalChat[200],1)
				end
			elseif v.chanel == ChatMsg_pb.chanel_guild then
				table.insert(totalChat[300] , v)
				if #totalChat[300] > 2 then
					table.remove(totalChat[300],1)
				end
			elseif v.chanel == ChatMsg_pb.chanel_guild_mboard then
			else
				table.insert(totalChat[100] , v)
				if #totalChat[100] > 2 then
					table.remove(totalChat[100],1)
				end
			end
		--end
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

function ResetUnionMessageChatListOther()
	unionMessageChatListOther = {}
	if totalChat == nil then
		return
	end
	totalChat[400] = nil
end

function ResetunionMessageChatListSelf()
	unionMessageChatListSelf = {}
	if totalChat == nil then
		return
	end
	totalChat[tonumber(ChatMsg_pb.chanel_guild_mboard)] = nil
end

--[[
		totalChat[tonumber(ChatMsg_pb.chanel_world)] = nationChatList
		totalChat[tonumber(ChatMsg_pb.chanel_private)] = privateChatList
		totalChat[tonumber(ChatMsg_pb.chanel_system)] = showChatList
		totalChat[tonumber(ChatMsg_pb.chanel_guild)] = unionChatList
]]

function GetRecentNewChat(chanel , n)
	local recentNew = {}
	if totalChat ~= nil then
		
		local chanelChat = totalChat[tonumber(ChatMsg_pb.chanel_world)]
		if chanel == ChatMsg_pb.chanel_private then
			chanelChat = totalChat[ChatMsg_pb.chanel_private]
		elseif chanel == ChatMsg_pb.chanel_guild then
			chanelChat = totalChat[ChatMsg_pb.chanel_guild]
		end
		if chanelChat ~= nil then
			local getNewIndex = 0
			local infoLength = #chanelChat
			local num = math.min(infoLength , n)
			for i=infoLength , 1 , -1 do
				local info = chanelChat[i]
				
				if IsInBlackList(info.sender.charid) == false then
					table.insert(recentNew , info)
					getNewIndex = getNewIndex + 1
				end
				
				if getNewIndex > n then
					break
				end
			end
		end
	end
	--[[
		local recentNew = {}
		local getNewIndex = 0
		local newIndex = 100
		if chanel == ChatMsg_pb.chanel_private then
			newIndex = 200
		elseif chanel == ChatMsg_pb.chanel_guild then
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
		end]]
	
	
	if chanel == ChatMsg_pb.chanel_private and #recentNew < n then
		Global.GFileRecorder:GetNewestRecords(recentNew , n-#recentNew)
	end
	
	--聊天预览框中，私聊和讨论组属于同一频道，所以要比较私聊和讨论组的时间先后
	if chanel == ChatMsg_pb.chanel_private or chanel == ChatMsg_pb.chanel_discussiongroup then
		GroupChatData.GetGroupNewestChat(recentNew , n)
	end
	
	return recentNew
end

function GetLatestChat(n)
	
end

--进入界面或切换tab时
--[[function GetChanelChat(chanel , num)
	if totalChat == nil then
		return nil
	end
	
	local chanelChat = totalChat[tonumber(chanel)]
	local chanelLength = #chanelChat
	local startIndex = math.max(0 , chanelLength - num) + 1
	local lastChat = {}
	for i=startIndex , chanelLength do
		table.insert(lastChat , chanelChat[i])
	end
	return lastChat
end
]]
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
	
	if chanel == ChatMsg_pb.chanel_private then
		for _ , v in pairs(lastChat) do
		
			--if IsInBlackList(v.sender.charid) == false then 
		
				if v.sender.charid == recvList.charid then
					table.insert(result , v)
				end
				
				if v.recvlist ~= nil then
					local get = false
					for i=1 , #(v.recvlist) , 1 do
						if v.recvlist[i].charid == recvList.charid then
							get = true
							break;
						end
					end
					
					if get then
						table.insert(result , v)
					end
				end
			--end
		end
	else
		local chanelLength = #lastChat
		local startIndex = math.max(0 , chanelLength - num) + 1
		for i=startIndex , chanelLength do
			--if IsInBlackList(lastChat[i].sender.charid) == false then 
				table.insert(result , lastChat[i])
			--end
			
		end
	end
	
	if chanel == ChatMsg_pb.chanel_discussiongroup then 
		if #lastChat > 0 then 
			GroupChatData.SetGroupCurrentChatId(recvList.groupid ,lastChat[#lastChat].id )
		end
	end
	
	return result
end

function GetChatDataLength(chanel , recName,recCharId , recGroupId)
	--print("===GetChatDataLength===" , totalChat)
	local leng = 0
	if totalChat ~= nil then
		local chanelChat = nil 
		if chanel == ChatMsg_pb.chanel_private then
			chanelChat = privateChatList
			local sKey = recName..","..recCharId
			leng = (chanelChat and chanelChat[sKey]) and #chanelChat[sKey] or 0
			print("GetChatDataLength():length:" ,leng)
		elseif chanel == ChatMsg_pb.chanel_discussiongroup then
			leng = 0
			if groupChatData and groupChatData[recGroupId] then
				leng = #groupChatData[recGroupId]
			end
			print("GetGroupChatDataLength():length:" ,leng , "  groupid : " ,recGroupId )
		else
			chanelChat = totalChat[tonumber(chanel)]
			leng = chanelChat and #chanelChat or 0
		end
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
	if chanel == ChatMsg_pb.chanel_private then
		local skey = recName.. ",".. recCharId
		chanelChat = privateChatList[skey]
		--print("GetChanelRecordChat:" , skey , chanelChat)
		if chanelChat ~= nil then
			--print("GetChanelRecordChat msgrecord length:"  , #chanelChat)
		else
			--print("GetChanelRecordChat msgrecord is nil")
		end
	elseif chanel == ChatMsg_pb.chanel_discussiongroup then
		if groupChatData and groupChatData[recGroupId] then
			chanelChat = groupChatData[recGroupId]
		end
	else
		chanelChat = totalChat[tonumber(chanel)]
	end
	
	local chanelLength = chanelChat and #chanelChat or 0

	local endIndex = math.max(1 , recordChatIndex)
	endIndex = math.min(chanelLength , recordChatIndex)
	--[[local startIndex = math.max( 1 , endIndex - num + 1)
	if recordChatIndex > 0 then 
		for i=startIndex , endIndex do
			table.insert(lastChat , chanelChat[i])
		end
	end
	recordChatIndex = math.max(0 , endIndex - num)]]
	--print("chatData()" ,"start :" .. startIndex .. "end:" .. endIndex , recordChatIndex ,chanelChat)
	
	
	local checkNum = 0
	if recordChatIndex > 0 then
		local tmp = {}
		while num > 0 do
			if endIndex - checkNum <= 0 then
				break
			end
			local info = chanelChat[endIndex - checkNum]
			if IsInBlackList(info.sender.charid) == false then 
				table.insert(tmp ,info)
				num = num - 1
			end
			checkNum = checkNum + 1
		end
		
		for i=1 , #tmp do
			lastChat[i] = table.remove(tmp)
		end
	end
	recordChatIndex = math.max(0 , endIndex - checkNum)
	--print("chatData()" ,"start :" .. endIndex - checkNum .. "end:" .. endIndex , recordChatIndex ,checkNum)
	
	return lastChat
end

function GetPrivateRecordData(recName, recCharId, num , update)
	local lastChat = GetChanelRecordChat(ChatMsg_pb.chanel_private , num , recName , recCharId)
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


function IsInBlackList(charid)
	for i=1 , #BlackList do
		if charid == BlackList[i].charid then 
			return true;
		end
	end
	
	return false
end


function GetBlackList()

	return BlackList
end

function RequestBlackList(callback)
    
	local req = ChatMsg_pb.MsgChatListBlackRequest()

	Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatListBlackRequest, req, ChatMsg_pb.MsgChatListBlackResponse, function(msg)		

		print("RequestBlackList———— "..msg.code) 
		if msg.code ~= ReturnCode_pb.Code_OK then
		    Global.ShowError(msg.code)
		else
			
			BlackList = msg.blackuserinfo	
			if BlackList ==nil then 
				BlackList = {}
			end 
			if callback ~= nil then
				callback()
			end	
		end
	end, true)
	
end

function RequestOpBlackList(charid,add,callback,tip)
	print("RequestOpBlackList "..charid)
	local call_add = function() 
		local req = ChatMsg_pb.MsgChatAddBlackRequest()
		req.charid = charid
		Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatAddBlackRequest, req, ChatMsg_pb.MsgChatAddBlackResponse, function(msg)		
			print("RequestOpBlackList code = "..msg.code) 
			-- Global.DumpMessage(msg , "d:/chatreport.lua")
			if tonumber(msg.code) == ReturnCode_pb.Code_BlackListMax then
				-- 黑名单已满
				FloatText.Show(TextMgr:GetText("setting_blacklist_ui8") , Color.red)
			elseif tonumber(msg.code) == ReturnCode_pb.Code_UserInBlack then 
				FloatText.Show(TextMgr:GetText("setting_blacklist_ui9") , Color.red)
			else 
				FloatText.Show(TextMgr:GetText("setting_blacklist_ui13") , Color.green)
				ChatData.RequestBlackList(function()
					if callback ~= nil then 
						callback()
					end 
				end)
			end
		end, true)
		
	end
	
	local call_del = function() 
		local req = ChatMsg_pb.MsgChatDelBlackRequest()
		req.charid = charid
		Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatDelBlackRequest, req, ChatMsg_pb.MsgChatDelBlackResponse, function(msg)		

			-- Global.DumpMessage(msg , "d:/chatreport.lua")
			if tonumber(msg.code) == ReturnCode_pb.Code_UserNotBlack then
				-- 玩家不在黑名单中
				FloatText.Show(TextMgr:GetText("setting_blacklist_ui10") , Color.red)
			else
				FloatText.Show(TextMgr:GetText("setting_blacklist_ui14") , Color.green)
				ChatData.RequestBlackList(function()
					if callback ~= nil then 
						callback()
					end 
				end)
			end
		end, true)
		
	end
	
	if add then
		MessageBox.Show(TextMgr:GetText("setting_blacklist_ui2"), 
			function() 
				call_add()
			end, 
			function() 
			
			end)
	else
		if tip then
			MessageBox.Show(TextMgr:GetText("setting_blacklist_ui4"), 
				function() 
					call_del()
				end, 
				function() 
				
				end)
		else
			call_del()
		end 
	end 
end



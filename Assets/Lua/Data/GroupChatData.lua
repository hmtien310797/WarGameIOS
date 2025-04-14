module("GroupChatData", package.seeall)
local GUIMgr = Global.GGUIMgr
local GPlayerPrefs = UnityEngine.PlayerPrefs

local groupChatData = {}
local chatNextTime = 0
local groupLastChat = {}
local eventListener = EventListener()

--[[
	checkCount:
	-1 为上线时的初始状态，语义此时作为是否有未读讨论组信息
	0 / ( >0 )  为更新后的状态，语义为是否有新讨论组信息。> 0 为有新讨论组消息 ， 0 为已查看过频道（是否查看频道和是否有未读信息语义不同）
]]
local checkCount = -1

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function GetData()
    return groupChatData
end


function GetData()
	return groupChatData
end

function SetData(data)
    groupChatData = data
end


function GetSortedData()
	local sort = {}
	for i=1 , #groupChatData , 1 do
		table.insert(sort , groupChatData[i])
	end
	
	table.sort(sort , function(v1 , v2)
		if v1.currentChat.time ~= nil and v2.currentChat.time ~= nil then 
			return v1.currentChat.time > v2.currentChat.time
		else
			return false
		end
	end)
	
	return sort
end

function GetCheckCount()
	if checkCount < 0 then
		local groups = GroupChatData.GetData()
		local iniCount = 0
		for i=1 , #groups do
			if not IsDismissed(groups[i].id) and not IsRemoved(groups[i].id , MainData.GetCharId()) then
				local new = GroupChatData.GetGroupCurrentChatCount(groups[i].id)
				iniCount = iniCount + new
			end
		end
		return iniCount
	end
	
	return checkCount
end

function UpdateCheckCount(cCount)
	checkCount = cCount
end

function UpdateData(data)
	local update = false
	for i=1 , #groupChatData , 1 do
		if groupChatData[i].id == data.id then
			groupChatData[i] = data
			update = true
		end
	end
	
	if not update then
		groupChatData:add()
		groupChatData[#groupChatData] = data
	end
	
	NotifyListener()
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

function GetGroupData(groupId)
	for i=1 , #groupChatData , 1 do
		if groupChatData[i].id == groupId then
			return groupChatData[i]
		end	
	end
end

function IsDismissed(groupId)
	
	local gd = GetGroupData(groupId)
	local dismiss = true
	if gd ~= nil then
		for i=1 , #gd.mem , 1 do
			if not gd.mem[i].removed then
				dismiss = false
				break
			end
		end
	end
	return dismiss
end

function IsRemoved(groupId , charid)
	local gd = GetGroupData(groupId)
	if gd ~= nil then
		for i=1 , #gd.mem , 1 do
			if gd.mem[i].user.charid == charid then
				return gd.mem[i].removed
			end
		end
	end
	return false
end

function GetGroupCreateById(groupId)
	local gd = GetGroupData(groupId)
	if gd ~= nil then
		for i=1 , #gd.mem , 1 do
			if gd.mem[i].creator then
				return gd.mem[i]
			end
		end
	end
	
	return nil
end

function GetGroupCreate(group)
	if group ~= nil then
		for i=1 , #group.mem , 1 do
			if group.mem[i].creator then
				return group.mem[i]
			end
		end
	end
	
	return nil
end

function CheckNew()
	

end

function GetGroupLastChat()
	local save_key = string.format("groupChat_%s_%s_%s" , MainData.GetCharId() ,ServerListData.GetCurrentAreaId(), ServerListData.GetCurrentZoneId())
	local jStr = GPlayerPrefs.GetString(save_key)--cjson.decode()
	print("=============GetGroupLastChat=========" , save_key ,jsStr)
	
	if jStr and jStr ~= "" then
		local data = cjson.decode(jStr)
		for k , v in pairs(data) do
			
			SetGroupCurrentChatId(tonumber(k) , tonumber(v))
		end
	end
end

function SaveGroupLastChat()
	local jsStr = cjson.encode(groupLastChat)
	if ServerListData.GetAllAreaData() and ServerListData.GetCurrentZoneId() then
	local save_key = string.format("groupChat_%s_%s_%s" , MainData.GetCharId() ,ServerListData.GetCurrentAreaId(), ServerListData.GetCurrentZoneId())
	print("============SaveGroupLastChat ============ " , save_key ,jsStr )
	GPlayerPrefs.SetString(save_key, jsStr)
	end
end

function GetGroupCurrentChatCount(groupid)
	local gd = GetGroupData(groupid)
	local current = gd.currentChat and gd.currentChat.id or 0
	local last = groupLastChat[groupid] and groupLastChat[groupid] or 0
	
	return current - last
end

function SetGroupCurrentChatId(groupid , curChatid)
	groupLastChat[groupid] = curChatid
	SaveGroupLastChat()
end


function GetUnReadGroupCount(charid)
	local count = 0
	for i=1 , #groupChatData do
		local gd = groupChatData[i]
		if not IsRemoved(gd.id , charid) and not IsDismissed(gd.id) then
			local curCid = gd.currentChat and gd.currentChat.id or 0
			if groupLastChat[gd.id] ~= nil then
				count = count + curCid - groupLastChat[gd.id]
			else
				count = count + curCid
			end
		end
	end
	return count
end

function GetGroupNewestChat(recentNew , count)
	--先排序获取最新的count条数据
	local newc = GetSortedData()
	--对比私聊记录，如果记录时间更新，则替换记录
	local grpCount = 0
	for i=1 , #newc do
		local group = newc[i]
		if not IsDismissed(group.id) and not IsRemoved(group.id , MainData.GetCharId()) then
			if newc[i].currentChat then
				table.insert(recentNew ,  newc[i].currentChat)
				grpCount = grpCount + 1
			end
			
			if grpCount >= count then
				break
			end
		end
	end
	
	table.sort(recentNew , function(v1, v2)
		return v1.time > v2.time
	end)

	return recentNew
end

function RequestChatGroupList(reqGroups , update , callback)
   
	local req = ChatMsg_pb.MsgChatDiscGroupListRequest()
	if reqGroups then
		for i=1 , #reqGroups , 1 do
			req.id:append(reqGroups[i])
		end
	end
	
	
	Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatDiscGroupListRequest, req, ChatMsg_pb.MsgChatDiscGroupListResponse, function(msg)		
		Global.DumpMessage(msg , "d:/chatgroup.lua")
        if msg.code ~= ReturnCode_pb.Code_OK then
		    Global.ShowError(msg.code)
		else
			if update then
				UpdateData(msg.data[1])
			else
				SetData(msg.data)
			end
			
			if callback ~= nil then
				callback()
			end
		end
	end, true)
end

function RequestGroupChat(groupid ,flag, callback)
	
	local req = ChatMsg_pb.MsgChatInfoListRequest()
	req.init = flag
	req.languagecode = GUIMgr:GetSystemLanguage()--Global.GTextMgr:GetCurrentLanguageID()
	req.chanel = ChatMsg_pb.chanel_discussiongroup
	req.param = groupid
	--Global.DumpMessage(req , "d:/RequestGroupChat.lua")
	Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatInfoListRequest, req, ChatMsg_pb.MsgChatInfoListResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		else
			--Global.DumpMessage(msg , "d:/RequestGroupChat.lua")
			ChatData.UpdateGroupNewData(groupid , msg.infos , msg.autoTrans , msg.transEnable , nil , flag)
			--ChatData.UpdateNewData(msg.infos , msg.autoTrans , msg.transEnable)
			
			if callback ~= nil then
				callback()
			end	
		end
	end, true)
end


function RequestGroupMemMgr(groupid , opt , oplist , callback , name)
	--print(groupid , opt , oplist , callback , name)
	
	local req = ChatMsg_pb.MsgChatDiscGroupMemberMgrRequest()
	req.data.id = groupid
	req.data.opt = opt
	local _log = ""
	if oplist ~= nil then
		for i=1 , #oplist , 1 do
			req.data.mem:append(oplist[i])
			_log = _log .. oplist[i] .. ","
		end
	end
	
	if name ~= nil then
		req.data.name = name
	end
	--print(groupid , opt , _log , oplist)
	--Global.DumpMessage(req , "d:/chatgroup.lua")
	Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatDiscGroupMemberMgrRequest, req, ChatMsg_pb.MsgChatDiscGroupMemberMgrResponse, function(msg)		
	--	Global.DumpMessage(msg , "d:/chatgroup.lua")
        if msg.code ~= ReturnCode_pb.Code_OK then
		    Global.ShowError(msg.code)
		else
			UpdateData(msg.data)
			
			if callback ~= nil then
				callback()
			end
		end
	end, true)
end

function Translate(text, reqCount, callback)
    if reqCount >= 10 then
        if callback ~= nil then
            callback(text)    
        end
        return
    end
    reqCount = reqCount + 1
	local req = ChatMsg_pb.MsgUserTranslateTextRequest()
	req.clientLang = Global.GGUIMgr:GetSystemLanguage()
    req.text:append(text)
    Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgUserTranslateTextRequest, req, ChatMsg_pb.MsgUserTranslateTextResponse, function(msg)
        local transData = msg.data[1]
        if transData ~= nil and transData.text ~= nil and transData.text ~= "" then
            if callback ~= nil then
                callback(transData.text)    
            end
        else
            Translate(text, reqCount, callback)
        end
    end,true)	
    
end
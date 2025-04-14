module("UnionMessageData", package.seeall)
local GUIMgr = Global.GGUIMgr
local unionMessageData = {}
local chatNextTime = 0

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
    return unionMessageData
end

function SetData(data)
    unionMessageData = data
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

function RequestGuildMessageBoardBacklist(callback)
    local req = ChatMsg_pb.MsgGuildMessageBoardBacklistRequest()
    Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgGuildMessageBoardBacklistRequest, req, ChatMsg_pb.MsgGuildMessageBoardBacklistResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetData(msg.backlist)
            if callback ~= nil then
                callback()
            end
        else
            Global.FloatError(msg.code)
        end
    end, true)
end

function RequestGuildSetMessageBoardBacklist(type, charid, callback)
    local req = ChatMsg_pb.MsgGuildSetMessageBoardBacklistRequest()
    req.type = type
    req.charid = charid
    Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgGuildSetMessageBoardBacklistRequest, req, ChatMsg_pb.MsgGuildSetMessageBoardBacklistResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetData(msg.backlist)
            if callback ~= nil then
                callback()
            end
        else
            Global.FloatError(msg.code)
        end
    end, true)
end

function RequestUnionMessageChatInfo(guildId, callback)
    if guildId == UnionInfoData.GetGuildId() then   
        ChatData.ResetunionMessageChatListSelf()
    else
        ChatData.ResetUnionMessageChatListOther()
    end
	local req = ChatMsg_pb.MsgChatInfoListRequest()
	req.init = true
	req.languagecode = GUIMgr:GetSystemLanguage() --Global.GTextMgr:GetCurrentLanguageID()
    -- requestUnionMessageChat = true
    req.chanel = ChatMsg_pb.chanel_guild_mboard
	req.param = guildId				
    -- Global.DumpMessage(req , "d:/ChatAllRequest.lua")

	Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatInfoListRequest, req, ChatMsg_pb.MsgChatInfoListResponse, function(msg)		
		-- Global.DumpMessage(msg , "d:/ChatAllRequest.lua")
        if msg.code ~= ReturnCode_pb.Code_OK then
		    Global.ShowError(msg.code)
		else
			ChatData.UpdateNewData(msg.infos)
			UnionMessageData.SetNextTime(msg.reqPeriod)			
			if callback ~= nil then
				callback()
			end	
		end
	end, true)
end

function RequestUnionMessageChat(callback)
	local req = ChatMsg_pb.MsgChatInfoListRequest()
	req.init = false
	req.languagecode = GUIMgr:GetSystemLanguage()--Global.GTextMgr:GetCurrentLanguageID()
	req.chanel = ChatMsg_pb.chanel_guild_mboard
    if GUIMgr:IsMenuOpen("UnionMessage") then
        req.param = UnionMessage.GetGuildId()
    else
        if UnionInfoData.GetGuildId() ~= 0 then
            req.param = UnionInfoData.GetGuildId()
        else
            return
        end
    end
    -- Global.DumpMessage(req , "d:/Chatrequest.lua")

	Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatInfoListRequest, req, ChatMsg_pb.MsgChatInfoListResponse, function(msg)
		-- Global.DumpMessage(msg , "d:/Chatrequest.lua")
        if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		else
			ChatData.UpdateNewData(msg.infos, msg.autoTrans , msg.transEnable , true)		
            UnionMessageData.SetNextTime(msg.reqPeriod)
            MainCityUI.UpdateNotice()
            UnionInfo.UpdateUnionMessageRed()

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
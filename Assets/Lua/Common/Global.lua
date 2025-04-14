module("Global", package.seeall)
local dumpCount = 3
local string = string
local math = math
local abs = math.abs
local modf = math.modf
local isEditor = UnityEngine.Application.isEditor
local Format = System.String.Format
messageList = {}
local dumpList = {}
local ReturnCode_pb = require("ReturnCode_pb")

GGameStateLogin = GameStateLogin.Instance
GGameStateBattle = GameStateBattle.Instance
GResourceLibrary = ResourceLibrary.instance
GGameStateMain = GameStateMain.Instance
GGuideManager = GuideManager.instance
GMain = Main.Instance
GGUIMgr = GUIMgr.Instance
GController = Controller.instance
--GTableMgr = GMain:GetTableMgr()
GTextMgr = TextManager.Instance
GGameSetting = GameSetting.instance
GAudioMgr = AudioManager.Instance
GUIAnimMgr = UIAnimManager.instance
GTableMgr = LuaTableMgr()
GFileRecorder = nil

local MINUTE_SECOND = 60
local HOUR_SECOND = MINUTE_SECOND * 60
local DAY_SECOND = HOUR_SECOND * 24
local MONTH_SECOND = DAY_SECOND * 30
local YEAR_SECOND = DAY_SECOND * 365

local GameObject = UnityEngine.GameObject
local GameTime = Serclimax.GameTime
local uiTopRoot = GGUIMgr.UITopRoot

local BattleReportBack = {}
local MenuBackState = {}
local ChatEnterChanel = 0
local MobaChatEnterChanel = 0
local GuildMobaChatEnterChanel = 0

local MailIntvColdDown = {}
local MailIntvDownLevel = 0

local ChatIntvColdDown = {}
local ChatIntvColdDownLevel = 0

ACTIVE_GUILD_MOBA = true
enablePowerRank = true

function SetChatIntvContinuesTime(_time , _channel)
	if _channel ~= ChatMsg_pb.chanel_world then
		return
	end
	--初始状态
	if ChatIntvColdDown == nil then
		ChatIntvColdDown = {}
	end
	
	if ChatIntvColdDown[_channel] == nil then
		ChatIntvColdDown[_channel] = {}
	end
	ChatIntvColdDown[_channel][#(ChatIntvColdDown[_channel]) + 1] =  _time
end

function SetMailIntvContinuesTime(_time , _channel)
	if _channel ~= MailMsg_pb.MailType_User then
		return
	end
	--初始状态
	if MailIntvColdDown == nil then
		MailIntvColdDown = {}
	end
	
	if MailIntvColdDown[_channel] == nil then
		MailIntvColdDown[_channel] = {}
	end
	MailIntvColdDown[_channel][#(MailIntvColdDown[_channel]) + 1] =  _time
end

function GetMailIntvContinuesCD(_time , _channel)
	if MailIntvColdDown == nil or MailIntvColdDown[_channel] == nil then
		return 0 
	end
	
	local cfgIntvTimeLow = tonumber(GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.MailIntvContinusTime).value)
	local cfgIntvTimeHigh = tonumber(GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.MailIntvContinusTimeHigh).value)
	local cfgIntvCount = tonumber(GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.MailIntvContinusCount).value)
	local cfgIntvCD = string.split(GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.MailIntvContinusCD).value , ",")

	local cfgTime = cfgIntvTimeLow
	if MailIntvDownLevel > 1 then
		cfgTime = cfgIntvTimeHigh
	end
	
	local lastTime = #(MailIntvColdDown[_channel]) > 0 and MailIntvColdDown[_channel][#(MailIntvColdDown[_channel])] or 0
	if _time < lastTime then
		return lastTime - _time
	elseif MailIntvDownLevel > 0 then
		MailIntvColdDown[_channel] = {}
		MailIntvDownLevel = 0
	end
	
	local count = 1
	local update = {}
	for i=1 , #(MailIntvColdDown[_channel]) do
		if _time - MailIntvColdDown[_channel][i] < cfgTime then
			count = count + 1
			update[#update + 1] = MailIntvColdDown[_channel][i]
		end
	end
	MailIntvColdDown[_channel] = update
	
	if count > cfgIntvCount then 
		MailIntvDownLevel = math.min(#cfgIntvCD , MailIntvDownLevel + 1)
		local cd = tonumber(cfgIntvCD[MailIntvDownLevel])
		MailIntvColdDown[_channel][#(MailIntvColdDown[_channel])] = _time + cd
		return cd
	end
	return 0
end

function GetChatIntvContinuesCD(_time , _channel)
	if ChatIntvColdDown == nil or ChatIntvColdDown[_channel] == nil then
		return 0 
	end
	
	local cfgIntvTimeLow = tonumber(GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ChatIntvContinusTime).value)
	local cfgIntvTimeHigh = tonumber(GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ChatIntvContinusTimeHigh).value)
	local cfgIntvCount = tonumber(GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ChatIntvContinusCount).value)
	local cfgIntvCD = string.split(GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ChatIntvContinusCD).value , ",")

	local cfgTime = cfgIntvTimeLow
	if ChatIntvColdDownLevel > 1 then
		cfgTime = cfgIntvTimeHigh
	end
	
	local lastTime = #(ChatIntvColdDown[_channel]) > 0 and ChatIntvColdDown[_channel][#(ChatIntvColdDown[_channel])] or 0
	--lastTime = lastTime or 0
	if _time < lastTime then
		return lastTime - _time
	elseif ChatIntvColdDownLevel > 0 then
		ChatIntvColdDown[_channel] = {}
		ChatIntvColdDownLevel = 0
	end
	
	local count = 1
	local update = {}
	for i=1 , #(ChatIntvColdDown[_channel]) do
		if _time - ChatIntvColdDown[_channel][i] < cfgTime then
			count = count + 1
			update[#update + 1] = ChatIntvColdDown[_channel][i]
		end
	end
	ChatIntvColdDown[_channel] = update
	
	if count > cfgIntvCount then 
		ChatIntvColdDownLevel = math.min(#cfgIntvCD , ChatIntvColdDownLevel + 1)
		local cd = tonumber(cfgIntvCD[ChatIntvColdDownLevel])
		ChatIntvColdDown[_channel][#(ChatIntvColdDown[_channel])] = _time + cd
		return cd
	end
	
	
	
	--[[local index = (#(ChatIntvColdDown[_channel]) - cfgIntvCount) > 0 and (#(ChatIntvColdDown[_channel]) - cfgIntvCount) or 1
	local startTime = ChatIntvColdDown[_channel][index]
	
	if _time < startTime then
		return (startTime - _time)
	end
	
	local checkCount = #(ChatIntvColdDown[_channel]) + 1
	if #(ChatIntvColdDown[_channel]) > cfgIntvCount  then
		if _time - startTime < cfgTime then
			ChatIntvColdDown = nil
			ChatIntvColdDownLevel = math.min(#cfgIntvCD , ChatIntvColdDownLevel + 1)
			local cd = tonumber(cfgIntvCD[ChatIntvColdDownLevel])
			SetChatCDTime(_time + cd , _channel , 1)
			
			
			print("============enter cd :" , _time + cd , ChatIntvColdDownLevel , cd )
			return cd		
		end
		
		local _colddown = {}
		for i=1 , #(ChatIntvColdDown[_channel]) do
			local t = ChatIntvColdDown[_channel][i]
			if _time - t < cfgTime then
				_colddown[#(_colddown) + 1] = t
			end
		end
		ChatIntvColdDownLevel = 0
		ChatIntvColdDown[_channel] = _colddown
	end
	]]
	return 0
end


function TestCD()
	--SetChatContinuesTime(GameTime.GetSecTime())
	print(GTextMgr:GetText("Forbidden_4") , GameTime.GetSecTime() + 60)
	MessageBox.ShowCountDownMsg(GTextMgr:GetText("Forbidden_4"), GameTime.GetSecTime() + 60)--ShowCountDownMsg
end

function TestChatCD()
	if GetMailIntvContinuesCD(GameTime.GetSecTime() , MailMsg_pb.MailType_User) == 0 then
		print("send success")
		SetMailIntvContinuesTime(GameTime.GetSecTime() , MailMsg_pb.MailType_User)
	else
		print("send in cd ")
	end
end

----- Events ---------------------------
local eventOnTick = EventDispatcher.CreateEvent({ EventDispatcher.HANDLER_TYPE.INSTANT, EventDispatcher.HANDLER_TYPE.STATIC_INSTANT })

function OnTick()
    return eventOnTick
end
----------------------------------------

function IsDebugVersion()
    return GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eDebug
end

function IsReleaseVersion()
    return GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eRelease
end

function IsDistVersion()
    return GameEnviroment.NETWORK_ENV == GameEnviroment.EEnviroment.eDist
end

function SetDumpCount(messageCount)
    dumpCount = messageCount
end

function GetDumpCount()
    return dumpCount
end

function ReleaseResource()
    ResourceUnload.instance:ReleaseUnusedResource()
end

function DebugPrint(...)
    if IsDebugVersion() then
       -- print(...)
    end
end

local heroAdditionBaseList

local function WriteMessage(file, msg, indent)
    local fields = msg._fields
    if fields ~= nil then
        if indent == 0 then
            local mt = getmetatable(msg)
            file:write("--", mt._descriptor.full_name, "\n")
            file:write(mt._descriptor.name, " =\n{\n")
        end
        for k, v in pairs(fields) do
            local indentStr = string.rep(" ", indent + 4)
            if type(v) ~= "table" then
                if type(v) == "string" then
                    file:write(indentStr, k.name, " = ", string.format("%q", v), ",\n")
                else
                    file:write(indentStr, k.name, " = ", tostring(v), ",\n")
                end
            else
                file:write(indentStr, k.name, " =\n", indentStr, "{\n")
                WriteMessage(file, v, indent + 4, k.name)
                file:write(indentStr, "},\n")
            end
        end
        if indent == 0 then
            file:write("}")
        end
    else
        local indentStr = string.rep(" ", indent + 4)
        if indent == 0 then
            if msg._message_descriptor ~= nil then
                file:write("--", msg._message_descriptor.full_name, "\n")
                file:write(msg._message_descriptor.name, " =\n{\n")
            else
                file:write("{\n")
            end
        end
        for i, v in ipairs(msg) do
            if type(v) ~= "table" then
                file:write(indentStr, "[", i, "] = ")
                if type(v) == "string" then
                    file:write(string.format("%q", v), ",\n")
                else
                    file:write(tostring(v), ",\n")
                end
            else
                file:write(indentStr, "[", i, "] = \n")
                file:write(indentStr, "{\n")
                WriteMessage(file, v, indent + 4)
                file:write(indentStr, "},\n")
            end
        end
        if indent == 0 then
            file:write("}")
        end
    end
end

function DumpMessage(msg, fileName)
    if not isEditor then
        return 
    end
    local dumpFile = nil
    if fileName ~= nil then
        dumpFile = io.open(fileName, "a")
    else
        dumpFile = io.open("d:/dump.lua", "a")
    end
    if dumpFile ~= nil then
        WriteMessage(dumpFile, msg, 0)
        dumpFile:write("\n\n\n")
        dumpFile:write("-- Server Time: " .. Serclimax.GameTime.SecondToStringYMDLocal(Serclimax.GameTime.GetSecTime()))
        dumpFile:write("\n")
        dumpFile:write("-- Local Time: " .. os.date("%Y-%m-%d %H:%M:%S", os.time()))
        dumpFile:write("\n")
        dumpFile:close()
    end
end

function DumpAllMessage()
    if not isEditor then
        return 
    end
    local dumpFile = io.open("d:/message.lua", "w")
    if dumpFile ~= nil then
        for _, v in ipairs(messageList) do
            if v.repMsg ~= nil then
                dumpFile:write("--seqId:", v.seqId, "\n")
                dumpFile:write("--request:\n")
                WriteMessage(dumpFile, v.reqMsg, 0)
                dumpFile:write("\n")
                dumpFile:write("--response:\n")
                WriteMessage(dumpFile, v.repMsg, 0)
                dumpFile:write("\n")
                dumpFile:write(string.rep("-", 80), "\n")
            end
        end
        dumpFile:close()
    end
end

local isTableVisited = {}
function DumpTable(table, filePath, indentLevel, dumpFile)
    if dumpFile == nil then
        dumpFile = io.open(filePath or "d:/table.lua", "w")
        if dumpFile == nil then
            dumpFile = io.open("d:/table.lua", "w")
        end
    end

    if not isTableVisited[table] then
        isTableVisited[table] = true

        indentLevel = indentLevel or 0

        local indent = string.rep("\t", indentLevel)

        if indentLevel == 0 then
            dumpFile:write(tostring(table) .. "\n")
        end

        dumpFile:write(indent .. "{" .. "\n")
        
        for k, v in pairs(table) do
            dumpFile:write(string.format("%s\t%s = %s\n", indent, tostring(k), tostring(v)))
            
            if type(v) == "table" then
                DumpTable(v, nil, indentLevel + 1, dumpFile)
            end
        end

        dumpFile:write(indent .. "}" .. "\n")

        if indentLevel == 0 then
            dumpFile:write("\n\n\n")
            dumpFile:write("-- " .. Serclimax.GameTime.SecondToStringYMDLocal(Serclimax.GameTime.GetSecTime()))
            dumpFile:write("\n")
            dumpFile:close()

            isTableVisited = {}
        end
    end
end

function LogDebug(moduleTable, functionName, ...)
    if isEditor then
        print(System.String.Format("[Debug][{0}.{1}]", moduleTable._NAME, functionName), ...)
    end
end

function LogError(moduleTable, functionName, errorMessage)
    if isEditor then
        error(System.String.Format("[Error][{0}.{1}] {2}", moduleTable._NAME, functionName, errorMessage))
    end
end

function EnableFakeData()
    return Serclimax.Constants.ENABLE_FAKE_DATA
end

errorCodeTextIdList = {}
for k, v in pairs(ReturnCode_pb) do
    if type(v) == "number" then
        errorCodeTextIdList[v] = Text[k]
    end
end

function GetAttributeLongID(armyType, attributeType)
    return armyType * 10000 + attributeType
end

function DecodeAttributeLongID(attributeLongID)
    return math.floor(attributeLongID / 10000), attributeLongID % 10000
end

function GetErrorText(errorCode)
    if errorCode >= 100000 then
        if IsDebugVersion() then
            local errorCodeTextId = errorCodeTextIdList[errorCode]
            if errorCodeTextId == nil then
                return "unknown system error: code="..errorCode
            else
                return string.format("%s(%s%d)", GTextMgr:GetText(errorCodeTextId), "system error: code=", errorCode)
            end
        else
            return "system error: code="..errorCode
        end
    else
        local errorCodeTextId = errorCodeTextIdList[errorCode]
        if errorCodeTextId == nil then
            return "unknown error: code="..errorCode
        else
            return GTextMgr:GetText(errorCodeTextId)
        end
    end
end

function ShowNoEnoughMoney()
    MessageBox.Show(GTextMgr:GetText(Text.common_ui8), function() Goldstore.ShowRechargeTab() end, function() end, GTextMgr:GetText(Text.common_ui10))
end

function ShowNoEnoughSceneEnergy(buyCount,okCall)
	MainCityUI.CheckAndBuySceneEnergy() --ShowUseOrBuySceneEnergy()
end

function ShowError(errorCode, callback)
    if not IsDistVersion() then
        print("errorCode:", errorCode)
    end
	
	--客户端存档数据过大，不弹框提示 2p,yansiying,yuyang - 2018/11/26
	if errorCode == ReturnCode_pb.Code_ClientSaveStr_TooLong then
		return
	end
	
    if errorCode == ReturnCode_pb.Code_DiamondNotEnough then
        ShowNoEnoughMoney()
	elseif errorCode == ReturnCode_pb.Code_SceneEnergyNotEnough then
		ShowNoEnoughSceneEnergy()
	elseif errorCode == ReturnCode_pb.Code_Moba_SceneMapNotExist then
		MessageBox.Show(GTextMgr:GetText("ui_moba_164"), function()
			if GGUIMgr:IsMenuOpen("MobaMain") then
			MainCityUI.HideWorldMap(true , MainCityUI.WorldMapCloseCallback, true)
			end
		end)
    else
        MessageBox.Show(GetErrorText(errorCode), callback)
    end
end

function FloatError(errorCode, color)
    if not IsDistVersion() then  
        print("errorCode:", errorCode)
    end
    if errorCode == ReturnCode_pb.Code_DiamondNotEnough then
        ShowNoEnoughMoney()
    else
        FloatText.Show(GetErrorText(errorCode), color)
    end
end

function FloatErrorOn(gameObject, errorCode, color)
    if not IsDistVersion() then
        print("errorCode:", errorCode)
    end
    if errorCode == ReturnCode_pb.Code_DiamondNotEnough then
        ShowNoEnoughMoney()
    else
        FloatText.ShowOn(gameObject, GetErrorText(errorCode), color)
    end
end

function FloatErrorAt(position, errorCode, color)
    if not IsDistVersion() then
        print("errorCode:", errorCode)
    end
    if errorCode == ReturnCode_pb.Code_DiamondNotEnough then
        ShowNoEnoughMoney()
    else
        FloatText.ShowAt(position, GetErrorText(errorCode), color)
    end
end

function FormatNumber(num)
	local s = num
	if num >= 1000 then
		s = Format("{0:0,0}",num)
	end
	return s
end

function FormatPercentageNumber(number, hundredPercent, decimals)
    if decimals == nil or decimals < 0 then decimals = 1 end
    if hundredPercent == nil or hundredPercent < 0 then hundredPercent = 100 end

    local percentage = number * 100 / hundredPercent

    local minPercentage = math.pow(10, -decimals)
    if percentage ~= 0 and percentage < minPercentage then return "<" .. minPercentage .. "%" end

    return string.format("%." .. decimals .. "f%%", percentage)
end

function ExchangeValue(num)
    local s = num
    if num >= 1000000000 then
        s = Mathf.Floor(num / 1000000000) .. "." .. Mathf.Floor((num % 1000000000) / 100000000) .. "B"
    elseif num >= 1000000 then
        s = Mathf.Floor(num / 1000000) .. "." .. Mathf.Floor((num % 1000000) / 100000) .. "M"
    elseif num >= 1000 then
        s = Mathf.Floor(num / 1000) .. "." .. Mathf.Floor((num % 1000) / 100) .. "K"
	else
		s = math.ceil(num)
    end

    return s
end

function ExchangeValue2(num)
	local s = num
	if num >= 1000000000 then
        s = Mathf.Floor(num / 1000000000) .. (Mathf.Floor((num % 1000000000) / 100000000) > 0 and "." .. Mathf.Floor((num % 1000000000) / 100000000) or "") .. "B"
    elseif num >= 1000000 then
        s = Mathf.Floor(num / 1000000) .. (Mathf.Floor((num % 1000000) / 100000) > 0 and "." .. Mathf.Floor((num % 1000000) / 100000) or "") .. "M"
    elseif num >= 10000 then
        s = Mathf.Floor(num / 1000) .. (Mathf.Floor((num % 1000) / 100) > 0 and "." .. Mathf.Floor((num % 1000) / 100) or "") .. "K"
	elseif num >= 1000 then
		s = FormatNumber(num)
    end

    return s
	
	--[[
	local s1 , s2
	if num >= 1000000000 then
		s1 = Mathf.Floor(num / 1000000000)
		s2 = Mathf.Floor((num % 1000000000) / 100000000)
		local formats1 = FormatNumber(s1)
        --s = Mathf.Floor(num / 1000000000) .. "." .. Mathf.Floor((num % 1000000000) / 100000000) .. "B"
		s = formats1 .."." .. s2 .. "B"
    elseif num >= 1000000 then
		s1 = Mathf.Floor(num / 1000000)
		s2 = Mathf.Floor((num % 1000000) / 100000)
		local formats1 = FormatNumber(s1)
        --s = Mathf.Floor(num / 1000000) .. "." .. Mathf.Floor((num % 1000000) / 100000) .. "M"
		s = formats1 .."." .. s2 .. "M"
	elseif num >= 10000 then
		s1 = Mathf.Floor(num / 1000)
		s2 = Mathf.Floor((num % 1000) / 100)
		local formats1 = FormatNumber(s1)
        --s = Mathf.Floor(num / 1000) .. "." .. Mathf.Floor((num % 1000) / 100) .. "K"
		s = formats1 .."." .. s2 .. "K"
	else
		s = FormatNumber(num)
	end
	
	return s
	]]
end

function ExchangeValue1(num)
	local s = num
	if num >= 86400 then
		s = Mathf.Floor(num / 86400) .. "d"
	elseif num > 3600 then
		s = Mathf.Floor(num / 3600) .. "h"
	elseif num > 0 then
		s = Mathf.Floor(num / 60) .. "m"
	end
	
	return s
end

function ExchangeValue3(num)
	return num .. "%"
end

function ExchangeValue4(num)
	local s = num
	if num >= 1000000000 then
        s = Mathf.Floor(num / 1000000000) .. (Mathf.Floor((num % 1000000000) / 100000000) > 0 and "." .. Mathf.Floor((num % 1000000000) / 100000000) or "") .. "B"
    elseif num >= 1000000 then
        s = Mathf.Floor(num / 1000000) .. (Mathf.Floor((num % 1000000) / 100000) > 0 and "." .. Mathf.Floor((num % 1000000) / 100000) or "") .. "M"
    end

    return s
end

function SecToDataFormat(sec)
	local h , m , s
	h = Mathf.Floor(sec/3600)
	if h < 10 then
		h = "0" .. h
	end
	m = Mathf.Floor((sec%3600) / 60)
	if m < 10 then
		m = "0" .. m
	end
	s = Mathf.Floor((sec%3600)%60)
	if s < 10 then
		s = "0" .. s
	end
	local reslult = h .. ":" .. m .. ":" .. s
	return reslult
end

function IsHeroPercentAttrAddition(attrAddition)
    if heroAdditionBaseList == nil then
        local additionBaseList = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.HeroAdditionBaseList).value
        heroAdditionBaseList = string.split(additionBaseList, ";")
    end
    for _, v in ipairs(heroAdditionBaseList) do
        if tostring(attrAddition) == v then
            return false
        end
    end
    return true
end

function GetHeroAttrValueString(attrAddition, attrValue)
    if attrValue ~= 0 and abs(attrValue) < 0.1 then
        if attrValue < 0 then
            attrValue = -0.1
        else
            attrValue = 0.1
        end
    end

    local _, f = modf(attrValue)
    if abs(f) < 0.1 then
        if IsHeroPercentAttrAddition(attrAddition) then
            return string.format("%+d%%", attrValue)
        else
            return string.format("%+d", attrValue)
        end
    else
        if IsHeroPercentAttrAddition(attrAddition) then
            return string.format("%+.1f%%", attrValue)
        else
            return string.format("%+.1f", attrValue)
        end
    end
end

local tableFunctionList = {}
function GetTableFunction(funcStr)
    local tableFunction = tableFunctionList[funcStr]
    if tableFunction == nil then
        tableFunction = loadstring(funcStr)
        tableFunctionList[funcStr] = tableFunction
    end
    return tableFunction
end

function Log2File(file , str)
	local dumpFile = io.open(file, "a")
	if dumpFile ~= nil then
		dumpFile:write(str)
		dumpFile:write("\n")
		dumpFile:close()
	end
end

function Log2FileContent(file , str)
	if file ~= nil then
		file:write(str)
		file:write("\n")
	end
end

local reqSeqTrace = nil
function Request(categoryId, typeId, reqMsg, repMsgPb, callback, unlockScreen)
	local t = os.clock()

    local seqId = LuaNetwork.Request(categoryId, typeId, reqMsg:SerializeToString(), function(seqId, data)
        local repMsg = repMsgPb()
        repMsg:ParseFromString(data)
        if isEditor and dumpCount ~= 0 then
            for _, v in ipairs(messageList) do
                if v.seqId == seqId then
                    v.repMsg = repMsg
                    break
                end
            end
            DumpAllMessage()
        end
		
		local mt = getmetatable(repMsg)
		if LuaNetwork.EnableLog() then
			Log2File("d:/dumpCS.lua" , string.format("%s , %s" , "++++++++++++++response msg call start:" , mt._descriptor.full_name) )
			--print("send msg:" , mt._descriptor.full_name)
		end
        callback(repMsg)
		
		if LuaNetwork.EnableLog() then
			Log2File("d:/dumpCS.lua" , string.format("%s , %s , repTimeMs: %d" , "===============response msg call end:" , mt._descriptor.full_name , math.floor((os.clock() - t)*1000)))
		end
		
    end, not unlockScreen)
    
	if LuaNetwork.EnableLog() then
		if reqSeqTrace == nil then
			reqSeqTrace = {}
			
			local dumpFile = io.open("d:/RequestSeqTrace.lua", "w")
			if dumpFile ~= nil then
				dumpFile:close()
			end
		end
		
		if reqSeqTrace[seqId] ~= nil then
			UnityEngine.Debug.LogError ("Network Request Seqid Dunplicate :" , seqId)	
		end
		Log2File("d:/RequestSeqTrace.lua" , string.format("%s , %s , %s" , "traceSeqId:" , seqId , " cateid:"..categoryId .. " typeid:" .. typeId))
	end
	
    if isEditor and dumpCount ~= 0 then
        local request = {seqId = seqId, reqMsg = reqMsg}
        table.insert(messageList, request)
        if #messageList > dumpCount then
            table.remove(messageList, 1)
            for i = dumpCount, #messageList do
                messageList[i] = nil
            end
        end
    end
end

function OpenUI(moduleTable)
    GGUIMgr:CreateMenu(moduleTable._NAME, false)
end

function OpenTopUI(moduleTable, topUI)
    GGUIMgr:CreateMenu(moduleTable._NAME, true)
end

function CloseUI(moduleTable)
    return GGUIMgr:CloseMenu(moduleTable._NAME)
end

function GetSelectedCount(list)
    local count = 0
    for _, v in ipairs(list) do
        if v.selected then
            count = count + 1
        end
        if v.selectednum ~= nil then
        	count = count + v.selectednum
        end
    end
    return count
end

function SetNumber(list, number)
    for i, v in ipairs(list) do
        v.gameObject:SetActive(i == number)
    end
end

function ClearAllSelected(list)
    for _, v in ipairs(list) do
        v.selected = false
        v.selectednum = 0
    end
end

function GetLabelColorNew(itemquality)
	local lbcolor = {}
	if	itemquality == 6 then
		lbcolor[0] = "[FF3F4B]"
	elseif itemquality == 5 then
		lbcolor[0] = "[FFC712]"
	elseif itemquality == 4 then
		lbcolor[0] = "[BD3FFF]"
	elseif itemquality == 3 then
		lbcolor[0] = "[00F4FF]"
	elseif itemquality == 2 then
		lbcolor[0] = "[2AFF00]"
	else 
		lbcolor[0] = "[FFFFFF]"
	end
	lbcolor[1] = "[-]"
	return lbcolor
end

function BagIsNoItem(items)
	for _ , v in pairs(items) do
		local itemid  = v.itemid
		local exid  = v.exid
		
		local itemExData = GTableMgr:GetItemExchangeData(exid)
		local itemTBData = ItemListData.GetItemDataByBaseId(itemid)

		if itemTBData ~= nil or itemExData ~= nil then
			return false
		end
	end
	return true
end

function SecondToTimeLong(second)
    return GameTime.SecondToString3(second)
end

function GetLeftCooldownMillisecond(cooldownTime)
    local leftMillisecond = cooldownTime * 1000 - GameTime.GetMilSecTime()
    return leftMillisecond > 0 and leftMillisecond or 0
end

function GetLeftCooldownSecond(cooldownTime)
    local leftSecond = cooldownTime - GameTime.GetSecTime()
    return leftSecond > 0 and leftSecond or 0
end

function GetLeftCooldownTextLong(cooldownTime)
    local leftSecond = GetLeftCooldownSecond(cooldownTime)
    return SecondToTimeLong(leftSecond), leftSecond
end

function utfstrlen(str)
	local len = #str;
	local left = len;
	local cnt = 0;
	local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc};
	while left ~= 0 do
		local tmp=string.byte(str,-left);
		local i=#arr;
		while arr[i] do
			if tmp>=arr[i] then left=left-i;break;end
				i=i-1;
		end
		cnt=cnt+1;
	end
	return cnt;
end

function GetSubString(inputstr , startIndex , charlen)
	local lenInByte = #inputstr
	local lenStr = utfstrlen(inputstr)
	local indexInChar = 0
	local i = 1
	
	while (i<=lenInByte) do
        local curByte = string.byte(inputstr, i)
        local byteCount = 1;
        if curByte>0 and curByte<=127 then
            byteCount = 1   --1字节字符
        elseif curByte>=192 and curByte<223 then
            byteCount = 2   --双字节字符
        elseif curByte>=224 and curByte<239 then
            byteCount = 3   --汉字
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4   --4字节字符
        end
		
		local curchar = string.sub(inputstr, i, i+byteCount-1)
		--print(curchar)--当前字
		i = i + byteCount --重置下一字节的索引
		indexInChar = indexInChar + 1
		--print(curchar , indexInChar)--当前字
		if indexInChar >= charlen then
			return string.sub(inputstr, 1, i-1)
		end
	end
end

function GetTextWidth(inputstr , fontsize)
	local lenInByte = #inputstr
	local width = 0
	local i = 1
	while (i<=lenInByte) do
        local curByte = string.byte(inputstr, i)
        local byteCount = 1;
        if curByte>0 and curByte<=127 then
            byteCount = 1   --1字节字符
        elseif curByte>=192 and curByte<223 then
            byteCount = 2   --双字节字符
        elseif curByte>=224 and curByte<239 then
            byteCount = 3   --汉字
        elseif curByte>=240 and curByte<=247 then
            byteCount = 4   --4字节字符
        end
		
		local curchar = string.sub(inputstr, i, i+byteCount-1)
		--print(curchar)--当前字
		i = i + byteCount --重置下一字节的索引
		
		if byteCount == 1 then
			width = width + fontsize * 0.3
		else
			width = width + fontsize -- 字符的个数（长度）
		end 
	end
	return width
end

function StringToSecondTime(stringTime, spliter1, spliter2, spliter3)
    if spliter1 == nil then
        spliter1 = " "
    end

    if spliter2 == nil then
        spliter2 = "-"
    end

    if spliter3 == nil then
        spliter3 = ":"
    end

    local ymd, hms
    for v in string.gsplit(stringTime, spliter1) do
        if ymd == nil then
            ymd = v
        else
            hms = v
        end
    end

    local time = {}

    if ymd ~= nil then
        for v in string.gsplit(ymd, spliter2) do
            if time.year == nil then
                time.year = tonumber(v)
            elseif time.month == nil then
                time.month = tonumber(v)
            else
                time.day = tonumber(v)
            end
        end
    end

    if hmd ~= nil then
        for v in string.gsplit(hms, spliter3) do
            if time.hour == nil then
                time.hour = tonumber(v)
            elseif time.min == nil then
                time.min = tonumber(v)
            else
                time.sec = tonumber(v)
            end
        end
    end

    return os.time(time)
end

function isTimeAvailable(beginTime, endTime, availableDays)
    local now = Serclimax.GameTime.GetSecTime()
    local weekDay = os.date("*t").wday

    if now >= beginTime and now < endTime then
        for _weekDay in string.gsplit(availableDays, ",") do
            return _weekDay ~= nil and weekDay == tonumber(_weekDay)
        end
    end

    return false
end

function isActivityAvailable(activity) -- tActivityCondition.data
    return isTimeAvailable(Global.StringToSecondTime(activity.sBegin), Global.StringToSecondTime(activity.sEnd), activity.week)
end

function Datediff(time1,time2)
	local dataTab1 = os.date("*t" , time1)
	local dataTab2 = os.date("*t" , time2)
	
	local day1 = {};
	local day2 = {};
	local numDay1;
	local numDay2;
	

	day1.year = dataTab1.year
	day1.month = dataTab1.month
	day1.day = dataTab1.day
	
	day2.year = dataTab2.year
	day2.month = dataTab2.month
	day2.day = dataTab2.day
	
	numDay1 = os.time(day1);
	numDay2 = os.time(day2);
	
	return (numDay1-numDay2)/(3600*24);
end

function GetItemLevelText(itemData) 
    if itemData.showType == 1 then
        return ExchangeValue2(itemData.itemlevel)
    elseif itemData.showType == 2 then
        return ExchangeValue1(itemData.itemlevel)
    elseif itemData.showType == 3 then
        return ExchangeValue3(itemData.itemlevel)
    else 
        return nil
    end
end



function ShowReward(rewardMsg, targetGameObject)
    local targetPosition
    if targetGameObject ~= nil then
        targetPosition = targetGameObject.transform.position
    end
    coroutine.start(function()
        for _, v in ipairs(rewardMsg.item.item) do
            local itemData = GTableMgr:GetItemData(v.baseid)
            local itemIcon = GResourceLibrary:GetIcon("Item/", itemData.icon)
            if targetPosition ~= nil then
                FloatText.ShowAt(targetPosition, TextUtil.GetItemName(itemData) .. "x" .. v.num, Color.green, itemIcon)
            else
                FloatText.Show(TextUtil.GetItemName(itemData) .. "x" .. v.num, Color.green, itemIcon)
            end
            GAudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
            coroutine.wait(0.3)
        end
        if rewardMsg.army ~= nil and rewardMsg.army.army ~= nil then
            for _, v in ipairs(rewardMsg.army.army) do
                local soldierData = GTableMgr:GetBarrackData(v.baseid, v.level)
                local itemIcon = GResourceLibrary:GetIcon("Icon/Unit/", soldierData.SoldierIcon)
                if targetPosition ~= nil then
                    FloatText.ShowAt(targetPosition, GTextMgr:GetText(soldierData.SoldierName) .. "x" .. v.num, Color.green, itemIcon)
                else
                    FloatText.Show(GTextMgr:GetText(soldierData.SoldierName) .. "x" .. v.num, Color.green, itemIcon)
                end
                GAudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
                coroutine.wait(0.3)
            end
        end
        local heroList = {}
        for _, v in ipairs(rewardMsg.hero.hero) do
            local key = v.baseid..v.level..v.star
            if heroList[key] == nil then
                heroList[key] = {}
                heroList[key].hero = v
                heroList[key].count = 1
            else
                heroList[key].count = heroList[key].count + 1
            end
        end

        for _, v in pairs(heroList) do
            local heroData = GTableMgr:GetHeroData(v.hero.baseid)
            local heroIcon = GResourceLibrary:GetIcon("Icon/herohead/", heroData.icon)
            local heroName = GTextMgr:GetText(heroData.nameLabel)
            local countText = v.count > 1 and "x"..v.count or ""
            if targetPosition ~= nil then
                FloatText.ShowAt(targetPosition, heroName..countText, Color.white, heroIcon)
            else
                FloatText.Show(heroName..countText, Color.white, heroIcon)
            end
            GAudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
            coroutine.wait(0.3)
        end
    end)
end

function ShowReward4DropId(drop_id, targetGameObject,specify_id)
    local dropShowList = GTableMgr:GetDropShowData(drop_id)
    local length = #dropShowList
    local rewardMsg = {}
    rewardMsg.item = {}
    rewardMsg.item.item = {}
    rewardMsg.hero = {}
    rewardMsg.hero.hero = {}    
    for i, v in ipairs(dropShowList) do
        local dropShowData = v
        local contentType = dropShowData.contentType        
        local contentId = dropShowData.contentId
        if contentType == 1 then
            local itemData = GTableMgr:GetItemData(contentId)
            local item = {}
            item.baseid = itemData.id
            item.num = dropShowData.contentNumber  
            if specify_id ~= nil then
                if specify_id[contentId] ~= nil then
                    table.insert(rewardMsg.item.item,item) 
                end
            else  
                table.insert(rewardMsg.item.item,item) 
            end
        elseif contentType == 3 then
            local heroData = GTableMgr:GetHeroData(contentId)
            local hero = {}
            hero.baseid = heroData.id
            hero.level = dropShowData.level
            hero.star = dropShowData.star
            if specify_id ~= nil  then
                if specify_id[contentId] ~= nil then
                    table.insert(rewardMsg.hero.hero,hero)  
                end
            else
                table.insert(rewardMsg.hero.hero,hero)  
            end
            
        end
    end
    ShowReward(rewardMsg,targetGameObject)
end

function ShowTopMask(closeDelay)
    local topMask = ResourceLibrary.GetUIInstance("Login/TopMask")
    local transform = topMask.transform
    transform:SetParent(uiTopRoot, false)
    GameObject.Destroy(topMask, closeDelay)
    topMask = nil
end

local topMask
function DisableUI()
    topMask = ResourceLibrary.GetUIInstance("Login/TopMask")
    local transform = topMask.transform
    transform:SetParent(uiTopRoot, false)
end


function EnableUI()
    GameObject.Destroy(topMask)
    topMask = nil
end


----SLG PVP
--
-- IsSponsor是不是发起者 1是 SupportRevert 支不支持恢复 1支持 是不是防守方 1 是
function LuaToSLGPlayer(formation,armylist,herolist,IsSponsor,SupportRevert,hadCommander,IsDefend,injuredNum)
    local player = Serclimax.SLGPVP.ScSLGPlayer()
    player.IsSponsor = IsSponsor
    player.SupportRevert = SupportRevert
    player.IsDefend = IsDefend
    player.Formation = formation
    player.InjuredNum = injuredNum
    player.HadCommander = hadCommander
    local armys = {}
    table.foreach(armylist,function(_,v)
        if v.Count > 0 then
            local army = Serclimax.SLGPVP.ScArmy()
            local data = Barrack.GetAramInfo(v.ArmyType,v.Level)
            army.ID = v.ID
            army.Count = v.Count
            army.Level = v.Level
            army.Exp = v.Exp == nil and 0 or v.Exp
            army.ArmyType = v.ArmyType
            if v.ArmyType == 101 or v.ArmyType == 102 then
                army.PhalanxType = BattleMove.Army2PhalanxType(v.ArmyType == 101 and 27 or 28)
            else
                army.PhalanxType = BattleMove.Army2PhalanxType(data.BarrackId)
            end
            army.HP = v.HP
            army.Attack = v.Attack
            army.Armor = v.Armor
            army.Penetrate = v.Penetrate
            table.insert(armys,army)
        end
    end)
    player.Armys = armys

    local heros = {}
    if herolist ~= nil then
        table.foreach(herolist,function(_,v)
            local hero = Serclimax.SLGPVP.ScSLGPVPHero()
            hero.uid = v.uid
            hero.baseid= v.baseid
            hero.level= v.level
            hero.star= v.star
            hero.grade= v.grade
            hero.skill_id = v.skill_id
            --10010105 -- 轰炸
            --10040105 --初级榴弹 no
            --10000202

            --
            --10030105 --初级扫射 no
            
            --10070106 -- 初级救援 no
            --10100204 --中级鼓舞
            --10090105 --初级包扎
            --10080105 --初级急救
            --
            --10060106 --初级治疗
            --10050105 --初级毒雾
            --10040105 --初级榴弹 no
            --10030105 --初级扫射 no
            --10010105 -- 轰炸
            --v.skill_id
            print("SSSSSSSSSSSSSSSSSS",v.skill_id)
            table.insert(heros,hero)
        end)        
    end
    print("UUUUUUUUUUUUUUUUUUUUUU",#heros)
    player.Heros = heros
    return player
end

local HeroAttr = {
    {3},--攻
    {9},--防
    {6},--血
}

local function AddHeroBuff(herobuffs,heroindex,addarmy,addattr,camp)
    --print("IIIIIIIIIIIII1",heroindex,addarmy,addattr)
    local index = (heroindex-1) * 12 
    for i =1,12 do
        if herobuffs[index + i -1] == -100 then
            herobuffs[index + i -1] = 0
        end        
    end 
    local att = {0,0,0}
    for i =1,3 do
        for j=1, #HeroAttr[i] do
            if addattr == HeroAttr[i][j] then
                att[i] = (camp == 1 and 1 or -1)
                break
            end
        end
    end

    local had = att[1] +att[2] + att[3]
    --print("IIIIIIIIIIIII2",att[1],att[2],att[3])
    if had == 0 then
        return 
    end
    --print("IIIIIIIIIIIII2",att[1],att[2],att[3])
    local s = ""
    local p = addarmy % 10000
    if p == 0 then
        for i =1,12 do
            if herobuffs[index + i -1] == 0 then
                herobuffs[index + i -1] = att[((i-1)%3)+1]
            end            
        end 
    else
        for i =1,3 do
            if herobuffs[index + (p-1)*3 + i -1] == 0 then
                herobuffs[index + (p-1)*3 + i -1] = att[i]
            end
        end
    end
    for i =1,12 do
        s = s .. herobuffs[index + i -1]..","
    end     
    --print("IIIIIIIIIIII3",s)
end

function IsPlayer(pType)
	if pType == Common_pb.SceneEntryType_Home or 
		pType == Common_pb.SceneEntryType_ResElec or 
		pType == Common_pb.SceneEntryType_ResFood or 
		pType == Common_pb.SceneEntryType_ResIron or 
		pType == Common_pb.SceneEntryType_ResOil or 
		pType == Common_pb.SceneEntryType_Barrack or 
		pType == Common_pb.SceneEntryType_Govt or 
		pType == Common_pb.SceneEntryType_Turret or 
		pType == Common_pb.SceneEntryType_Occupy or
		pType == Common_pb.SceneEntryType_Fortress or 
		pType == Common_pb.SceneEntryType_Stronghold then
		
		return true
	elseif pType == Common_pb.SceneEntryType_Fortress or 
			pType == Common_pb.SceneEntryType_Stronghold then
		
	else
		return false
	end
end

function GetResaultConfigPer(sbinput , campIndex)
	if campIndex < 0 or campIndex > 1 then
		return ""
	end
	
	local team1IsPlayer = false;
	for i=1 , #(sbinput.user.team1) , 1 do
		if sbinput.user.team1[i].seType == 0 then
			team1IsPlayer = true;
			break;
		end
	end

	local team2IsPlayer = false;
	for i=1, #(sbinput.user.team2), 1 do
		if IsPlayer(sbinput.user.team2[i].seType) then
			team2IsPlayer = true;
			break;
		end
	end
	
	local isPvpBattle = team1IsPlayer and team1IsPlayer == team2IsPlayer
	local strDRConfig = ""
	local team1SeType = sbinput.user.team1[1].seType
	local team2SeType = sbinput.user.team2[1].seType
	local team1PathType = sbinput.user.pathType
	local battleType = sbinput.battleType
	
	if not isPvpBattle then
		if team2SeType == Common_pb.SceneEntryType_Monster	then 								--打野怪额外恢复比例和伤兵比例
			if campIndex == 0 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pveMonsterDR).value  
			elseif campIndex == 1 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pveDMonsterDefaultDR).value  
			end 
		elseif (team2SeType == Common_pb.SceneEntryType_ActMonster) then 						
			local team2SeSubType = sbinput.user.team2[1].seSubtype
			if team2SeSubType == Common_pb.SeSubTypeActMonster_GuildMonster then				--打联盟怪额外恢复比例和伤兵比例
				if campIndex == 0 then
					strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pveLansquenetDR).value  
				elseif campIndex == 1 then
					strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pveDMonsterDefaultDR).value  
				end 
			elseif team2SeSubType == Common_pb.SeSubTypeActMonster_DigMonster then				--打金矿额外恢复比例和伤兵比例
				if campIndex == 0 then
					strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvePanzerDR).value  
				elseif campIndex == 1 then
					strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pveDMonsterDefaultDR).value  
				end 
			elseif team2SeSubType == Common_pb.SeSubTypeActMonster_Guncarriage then				--打炮车额外恢复比例和伤兵比例
				if campIndex == 0 then
					strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvePanzerDR).value  
				elseif campIndex == 1 then
					strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pveDMonsterDefaultDR).value  
				end
			end
		elseif (team2SeType == Common_pb.SceneEntryType_EliteMonster) then							--打精英叛军额外恢复比例和伤兵比例
			if campIndex == 0 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pveEliteDR).value  
			elseif campIndex == 1 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pveDMonsterDefaultDR).value  
			end
		else                                                        								
			if battleType == Common_pb.SceneBattleType_Siege then									--叛军攻城
				if campIndex == 0 then
					strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pveDMonsterDefaultDR).value  
				elseif campIndex == 1 then
					strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pveSiegeDR).value  
				end
			else																							--其他大地图pve行为额外恢复比例和伤兵比例
				if campIndex == 0 then
					strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pveNormalDR).value  
				elseif campIndex == 1 then
					strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pveDMonsterDefaultDR).value  
				end
			end
			
		end
	else
		if team2SeType == Common_pb.SceneEntryType_Barrack then -- 攻击驻扎
			if campIndex == 0 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvpAQuarterDR).value  
			elseif campIndex == 1 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvpDQuarterDR).value  
			end
		end
		
		if team2SeType == Common_pb.SceneEntryType_Occupy then -- 攻击占领
			if campIndex == 0 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvpAOccupyDR).value  
			elseif campIndex == 1 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvpDOccupyDR).value  
			end
		end
		
		if team2SeType == Common_pb.SceneEntryType_ResFood or 
			team2SeType == Common_pb.SceneEntryType_ResIron or
			team2SeType == Common_pb.SceneEntryType_ResOil or
			team2SeType == Common_pb.SceneEntryType_ResElec then -- 攻击资源
			if campIndex == 0 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvpAResourceDR).value  
			elseif campIndex == 1 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvpDResourceDR).value  
			end
		end
		
		if team2SeType == Common_pb.SceneEntryType_Govt or 
			team2SeType == Common_pb.SceneEntryType_Turret then -- 攻击政府/炮台
			if campIndex == 0 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvpAGovDR).value  
			elseif campIndex == 1 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvpDGovDR).value  
			end
		end
		
		if team2SeType == Common_pb.SceneEntryType_Fort then -- 攻击要塞
			if campIndex == 0 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvpAFortDR).value  
			elseif campIndex == 1 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvpDFortDR).value  
			end
		end
		
		if team2SeType == Common_pb.SceneEntryType_Fortress then -- 攻击新要塞
			if campIndex == 0 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvpAFortDR).value  
			elseif campIndex == 1 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvpDFortDR).value  
			end
		end
		
		if team2SeType == Common_pb.SceneEntryType_Stronghold then -- 攻击據點
			if campIndex == 0 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvpAPointDR).value  
			elseif campIndex == 1 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvpDPointDR).value  
			end
		end
		
		if team2SeType == Common_pb.SceneEntryType_Home then -- 攻击 玩家
			if campIndex == 0 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvpAPlayerDR).value
			elseif campIndex == 1 then
				strDRConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvpDPlayerDR).value  
			end
		end
		
		
	end
	
	print("------", isPvpBattle ,team1SeType, team2SeType , strDRConfig)
    return strDRConfig
	
end

function LuaToHeroBuffs(result)
    local hero = HeroBuffShowInfo()
    for i =1,120 do
        hero.HeroBuffIds[i-1] = -100
    end     
    if result ~= nil then
        local heroindex =1
        for i=1, 5 do          
            if i> #result.input.user.team1[1].hero.heros then

            else
                local heroMsg = result.input.user.team1[1].hero.heros[i]
                local heroData = GTableMgr:GetHeroData(heroMsg.baseid) 
                AddHeroBuff(hero.HeroBuffIds,heroindex,heroData.additionArmy1,heroData.additionAttr1,1)
                AddHeroBuff(hero.HeroBuffIds,heroindex,heroData.additionArmy2,heroData.additionAttr2,1)
                AddHeroBuff(hero.HeroBuffIds,heroindex,heroData.additionArmy3,heroData.additionAttr3,1)
                AddHeroBuff(hero.HeroBuffIds,heroindex,heroData.additionArmy4,heroData.additionAttr4,1)
                AddHeroBuff(hero.HeroBuffIds,heroindex,heroData.additionArmy5,heroData.additionAttr5,1)
                AddHeroBuff(hero.HeroBuffIds,heroindex,heroData.additionArmy6,heroData.additionAttr6,1)
            end
            heroindex = heroindex +1       
        end
        for i=1, 5 do          
            if i> #result.input.user.team2[1].hero.heros then

            else
                local heroMsg = result.input.user.team2[1].hero.heros[i]
                local heroData = GTableMgr:GetHeroData(heroMsg.baseid) 
                AddHeroBuff(hero.HeroBuffIds,heroindex,heroData.additionArmy1,heroData.additionAttr1,2)
                AddHeroBuff(hero.HeroBuffIds,heroindex,heroData.additionArmy2,heroData.additionAttr2,2)
                AddHeroBuff(hero.HeroBuffIds,heroindex,heroData.additionArmy3,heroData.additionAttr3,2)
                AddHeroBuff(hero.HeroBuffIds,heroindex,heroData.additionArmy4,heroData.additionAttr4,2)
                AddHeroBuff(hero.HeroBuffIds,heroindex,heroData.additionArmy5,heroData.additionAttr5,2)
                AddHeroBuff(hero.HeroBuffIds,heroindex,heroData.additionArmy6,heroData.additionAttr6,2)
            end
            heroindex = heroindex +1       
        end 
        return hero     
    end
end

function SimulateSLGPVP(players,random_seed)
    GameStateSLGBattle.InitSimulateSLGPVPCfg()
    local slg_pvp = Serclimax.SLGPVP.ScSLGPvP()
    slg_pvp.StartBattle(players,nil,random_seed);
end
--[[
function GetSimulateSLGPlayers()
local player1 = {
	 Formation = {0,4,1,3,0,2,},
	 Armys = 
	{
		{
			ID =2030001,
			Count =78,
			Level =1,
			ArmyType =4,
			PhalanxType =3,
			HP =600,
			Attack =100,
			Armor =0,
			Penetrate =0,
		},
		{
			ID =2020001,
			Count =80,
			Level =1,
			ArmyType =3,
			PhalanxType =2,
			HP =800,
			Attack =160,
			Armor =0,
			Penetrate =0,
		},
		{
			ID =3020001,
			Count =100,
			Level =1,
			ArmyType =8,
			PhalanxType =4,
			HP =2000,
			Attack =280,
			Armor =0,
			Penetrate =0,
		},
		{
			ID =2010001,
			Count =60,
			Level =1,
			ArmyType =2,
			PhalanxType =1,
			HP =600,
			Attack =60,
			Armor =0,
			Penetrate =0,
		},
		{
			ID =2000001,
			Count =80,
			Level =1,
			ArmyType =1,
			PhalanxType =1,
			HP =400,
			Attack =40,
			Armor =0,
			Penetrate =0,
		},
		{
			ID =2050001,
			Count =80,
			Level =1,
			ArmyType =6,
			PhalanxType =2,
			HP =1000,
			Attack =60,
			Armor =0,
			Penetrate =0,
		},
		{
			ID =2040001,
			Count =100,
			Level =1,
			ArmyType =5,
			PhalanxType =3,
			HP =1000,
			Attack =60,
			Armor =0,
			Penetrate =0,
		},
		{
			ID =3010001,
			Count =100,
			Level =1,
			ArmyType =7,
			PhalanxType =4,
			HP =1400,
			Attack =100,
			Armor =0,
			Penetrate =0,
		},
	}
}

local player2 = {
	 Formation = {0,3,4,0,1,2,7,8},
	 Armys = 
	{
		{
			ID =2030001,
			Count =78,
			Level =1,
			ArmyType =4,
			PhalanxType =3,
			HP =600,
			Attack =100,
			Armor =0,
			Penetrate =0,
		},
		{
			ID =2020001,
			Count =80,
			Level =1,
			ArmyType =3,
			PhalanxType =2,
			HP =800,
			Attack =160,
			Armor =0,
			Penetrate =0,
		},
		{
			ID =3020001,
			Count =100,
			Level =1,
			ArmyType =8,
			PhalanxType =4,
			HP =2000,
			Attack =280,
			Armor =0,
			Penetrate =0,
		},
		{
			ID =2010001,
			Count =60,
			Level =1,
			ArmyType =2,
			PhalanxType =1,
			HP =600,
			Attack =60,
			Armor =0,
			Penetrate =0,
		},
		{
			ID =2000001,
			Count =80,
			Level =1,
			ArmyType =1,
			PhalanxType =1,
			HP =400,
			Attack =40,
			Armor =0,
			Penetrate =0,
		},
		{
			ID =2050001,
			Count =80,
			Level =1,
			ArmyType =6,
			PhalanxType =2,
			HP =1000,
			Attack =60,
			Armor =0,
			Penetrate =0,
		},
		{
			ID =2040001,
			Count =100,
			Level =1,
			ArmyType =5,
			PhalanxType =3,
			HP =1000,
			Attack =60,
			Armor =0,
			Penetrate =0,
		},
		{
			ID =3010001,
			Count =100,
			Level =1,
			ArmyType =7,
			PhalanxType =4,
			HP =1400,
			Attack =100,
			Armor =0,
			Penetrate =0,
		},
		{
			ID =1010001,
			Count =100,
			Level =1,
			ArmyType =101,
			PhalanxType =27,
			HP =1400,
			Attack =100,
			Armor =0,
			Penetrate =0,
		},		
		{
			ID =1020001,
			Count =100,
			Level =1,
			ArmyType =102,
			PhalanxType = 28,
			HP =1400,
			Attack =100,
			Armor =0,
			Penetrate =0,
		},		
	}
}

    local players = {}
    players[1] = LuaToSLGPlayer(player1.Formation,player1.Armys,1,1,1,0,0) 
    players[2] = LuaToSLGPlayer(player2.Formation,player2.Armys,1,1,1,1,0)   
    return players
end
--]]
function CreateSLGPVPPlayerInfo(msg_team)
    local players = {}
    for i = 1,#(msg_team),1 do
        local player = {}
	    player.Formation = {}
        player.Armys = {}
        player.Heros = {}
        
	    local lf = BMFormation(nil)
        local myFormation = {}
        if #msg_team[i].formation.form == 0 then
            myFormation = lf:PvPData2Formation(msg_team[i])
        else
            for fi =1,#msg_team[i].formation.form do
                myFormation[fi] = msg_team[i].formation.form[fi]
            end        
        end

        --print("EEEEEEEEEEEEEEEEEE",i,log,flog)
	    for j =1,8,1 do 
		    --print(myFormation[i])
		    if myFormation[j] ~= nil then
			    player.Formation[j] = BattleMove.Army2PhalanxType(myFormation[j])
	    	else
			    player.Formation[j] = 0
		    end
        end
        if msg_team[i].army ~= nil then
	    for j=1 , #msg_team[i].army do
		    local army = msg_team[i].army[j].army
		    local attr = msg_team[i].army[j].attr
		    local solider = Barrack.GetAramInfo(army.baseid , army.level)
	
		    player.Armys[j] = {}
		    player.Armys[j].ID = solider.UnitID
		    player.Armys[j].Count = army.num
		    player.Armys[j].Level = army.level
		    player.Armys[j].ArmyType = army.baseid
		    player.Armys[j].PhalanxType = BattleMove.Army2PhalanxType(solider.BarrackId)
		    player.Armys[j].HP = attr.hp
            player.Armys[j].Exp = attr.exp
		    player.Armys[j].Attack = attr.atk
		    player.Armys[j].Armor = attr.def
		    player.Armys[j].Penetrate =0
        end
        end
        if msg_team[i].hero ~= nil and msg_team[i].hero.heros ~= nil then
        for j=1 , #msg_team[i].hero.heros do
            local hero = msg_team[i].hero.heros[j]           
            player.Heros[j] = {}
            player.Heros[j].uid = hero.uid
            player.Heros[j].baseid = hero.baseid
            player.Heros[j].level = hero.level
            player.Heros[j].star = hero.star
            player.Heros[j].grade = hero.grade
            if hero.pvpSkill ~= nil then
                player.Heros[j].skill_id = hero.pvpSkill.id*100+hero.pvpSkill.level
            else
                player.Heros[j].skill_id = 0
            end
        end      
        end   
        table.insert(players,player)
    end   
    return players
end

function CreateSLGPVPPlayers(msg_team,playerinfos,isdefend)
    local players = {}
    for i = 1,#(msg_team),1 do
        print(isdefend,i,#(msg_team))
        local player = Global.LuaToSLGPlayer(playerinfos[i].Formation,playerinfos[i].Armys,playerinfos[i].Heros,
	    (msg_team[i].main and 1 or 0),
	    (msg_team[i].recover ~= nil and 1 or 0),
	    (msg_team[i].userwar and 1 or 0),
	    isdefend and 1 or 0,msg_team[i].injureLeftMax) 
	    table.insert(players,player)
    end
    return players
end

function BattleReportDebugEx(msg,s)
    isBattleWave = false
    
    if false then
        for i =1,2 do
            local input = msg.mail.misc.result.waveInput:add()
            local PlayerInfo = input.playerInfos:add()
            PlayerInfo.joinBattle = 1
            PlayerInfo.armyDeadNum:append((i-1)*20)
        end
        local player = msg.mail.misc.result.input.user.team2:add()
        player.recover = true
        player.userwar = true
        player.main = true
        player.user.name = "哈哈将军看看嗯嗯任天堂啊"
        player.user.level = 30
        player.user.exp = 98559
        player.user.pkvalue = 875311
        player.user.face = 101
        player.user.charid = 32506
        local armyinfo = player.army:add()
        armyinfo.formation = 21
        armyinfo.pos = 1   
        armyinfo.army.baseid = 1001
        armyinfo.army.level = 4
        armyinfo.army.num = 41632
        armyinfo.attr.atk = 64.200996398926
        armyinfo.attr.def = 7.4035000801086
        armyinfo.attr.hp = 691.05438232422
        armyinfo.attr.pkvalue = 4.1999998092651
        armyinfo.attr.exp = 4
        armyinfo = player.army:add()
        armyinfo.formation = 27
        armyinfo.pos = 7   
        armyinfo.army.baseid = 101
        armyinfo.army.level = 1
        armyinfo.army.num = 100
        armyinfo.attr.atk = 21.199998855591
        armyinfo.attr.def = 6
        armyinfo.attr.hp = 211.99998474121
        armyinfo.attr.pkvalue =  0.89999997615814
        armyinfo.attr.exp = 1        
        player.heroAddPkValue = 7309
        
    end
    local maildata = MailListData.GetMailDataById(msg.mail.id)
    local msubtype = 0
    if maildata ~= nil then
        msubtype = maildata.subtype
    end
    if msg.mail.misc.result.waveInput ~= nil and #msg.mail.misc.result.waveInput > 0 then
        CheckBattleReportWaveEx(msg.mail,msubtype,battleFinishCallback, s == nil and 1 or 2)
        return
    end


    local team1PlayerInfos = CreateSLGPVPPlayerInfo(msg.mail.misc.result.input.user.team1)
    local team2PlayerInfos = CreateSLGPVPPlayerInfo(msg.mail.misc.result.input.user.team2)
    local team1players =  CreateSLGPVPPlayers(msg.mail.misc.result.input.user.team1,team1PlayerInfos,false)
    local team2players =  CreateSLGPVPPlayers(msg.mail.misc.result.input.user.team2,team2PlayerInfos,true)
    local players = {}
    for i = 1,#(team1players),1 do
        table.insert(players,team1players[i])
    end
    for i = 1,#(team2players),1 do
        table.insert(players,team2players[i])
    end

    local pinfo = {}
    pinfo[1] = {}
    pinfo[1].name = msg.mail.misc.result.input.user.team1[1].user.name
    pinfo[1].face = msg.mail.misc.result.input.user.team1[1].user.face
    pinfo[2] = {}
    pinfo[2].name = msg.mail.misc.result.input.user.team2[1].user.name
    pinfo[2].face = msg.mail.misc.result.input.user.team2[1].user.face 
    pinfo.arr = {}
    pinfo.arr[1] = msg.mail.misc.result.input.user.attrAddMax1
    pinfo.arr[2] = msg.mail.misc.result.input.user.attrAddMax2

    local hero = LuaToHeroBuffs(msg.mail.misc.result)

	local strAConfig = GetResaultConfigPer(msg.mail.misc.result.input , 0)
	local strDConfig = GetResaultConfigPer(msg.mail.misc.result.input , 1) 
	local strPhalanxConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvePhalanxConfig).value  
    if s == nil then
	    Global.StartSLGPVP_Debug(players,pinfo,hero,msg.mail.misc.result.input.user.seed , msg.mail.misc.result ,nil , strAConfig , strDConfig , strPhalanxConfig)    
	else
	    Global.StartSLGPVPSimple_Debug(players,pinfo,msg.mail.misc.result.input.user.seed , msg.mail.misc.result.input) 
    end    
end

function SyncPlayerFromWaveInput(sourceplayerInfos, targetplayerinfos,curwaveInput)
    local new_player_infos = {}
    for i=1 , #sourceplayerInfos do
        local player = targetplayerinfos[i]
        local splayer = sourceplayerInfos[i]
        local count = 0
        for j=1 , #player.Armys do
		    player.Armys[j].Count = splayer.Armys[j].Count - curwaveInput.playerInfos[i].armyDeadNum[j]
		    count = count + player.Armys[j].Count
        end
        if count > 0 then
            table.insert(new_player_infos,player)
        end
    end
    return new_player_infos
end

local isBattleWave
local curWaveIndex
local MaxWave
function IsSLGPVPBattleWaveState()
    return isBattleWave;
end

function SkillAllWave()
    curWaveIndex = MaxWave
end

function CheckBattleReportWaveEx(msg,readMailData_subtype, battleFinishCallback,support_debug)
    isBattleWave = true;
    local pinfo = {}
	local p1 , vs , p2 = MailReportDocNew.GetReportShareTitle(msg,readMailData_subtype)
    pinfo[1] = {}
    pinfo[1].name = p1--msg.misc.result.input.user.team1[1].user.name
    pinfo[1].face = MailReportDocNew.GetArmyFace(msg.misc.result.input.user.team1 , 1 )
    --msg.misc.result.input.user.team1[1].user.face
    pinfo[2] = {}
    pinfo[2].name = p2--msg.misc.result.input.user.team2[1].user.name
    pinfo[2].face = MailReportDocNew.GetArmyFace(msg.misc.result.input.user.team2 , 1 )
    --msg.misc.result.input.user.team2[1].user.face 
    msg.misc.result.ACampPlayers[1].name = p1
    msg.misc.result.DCampPlayers[1].name = p2
    if msg.misc.result.input.user.team2[1].monster ~= nil and msg.misc.result.input.user.team2[1].monster.monsterType == Common_pb.SceneEntryType_ActMonster then
    	--local monster = GTableMgr:GetActMonsterRuleData(msg.misc.result.input.user.team2[1].actMonster)
		local monsterName = msg.misc.target.name
    	pinfo[2].face = msg.misc.target.face--RebelData.GetActivityInfo().headIcon
	    pinfo[2].name = Global.GTextMgr:GetText(monsterName--[[monster.name]])
	    msg.misc.result.DCampPlayers[1].icon = pinfo[2].face
	    msg.misc.result.DCampPlayers[1].name = pinfo[2].name
	end
	curWaveIndex = 1
	if msg.misc.result.input.user.team1[1].monster ~= nil and msg.misc.result.input.user.team1[1].monster.monsterType == Common_pb.SceneEntryType_SiegeMonster then
		pinfo[1].face = 201
		pinfo[1].name = GTextMgr:GetText("SiegeMonster_" .. msg.misc.siegeShow.wave)
		msg.misc.result.ACampPlayers[1].icon = pinfo[1].face
	    msg.misc.result.ACampPlayers[1].name = pinfo[1].name
    end
    if msg.misc.result.input.battleType == Common_pb.SceneBattleType_Fort and msg.misc.result.input.user.team2[1].fort ~= nil and msg.misc.result.input.user.team2[1].fort.subType >0 then
        pinfo[2].name =System.String.Format(Global.GTextMgr:GetText("FortArmyNameWave_"..msg.misc.result.input.user.team2[1].fort.subType),curWaveIndex)
        for i=1,#msg.misc.result.DCampPlayers do
            msg.misc.result.DCampPlayers[i].icon = pinfo[2].face
            msg.misc.result.DCampPlayers[i].name = System.String.Format(Global.GTextMgr:GetText("FortArmyNameWave_"..msg.misc.result.input.user.team2[1].fort.subType),i)
        end
    end    
    pinfo.arr = {}
    pinfo.arr[1] = msg.misc.result.input.user.attrAddMax1
    pinfo.arr[2] = msg.misc.result.input.user.attrAddMax2

    local sourcePlayerInfos = CreateSLGPVPPlayerInfo(msg.misc.result.input.user.team1)
    local targetPlayerInfos = CreateSLGPVPPlayerInfo(msg.misc.result.input.user.team1)
    local team2PlayerInfos = CreateSLGPVPPlayerInfo(msg.misc.result.input.user.team2)

    
    MaxWave = #msg.misc.result.waveInput
    local team1PlayerInfos = SyncPlayerFromWaveInput(sourcePlayerInfos,targetPlayerInfos,msg.misc.result.waveInput[curWaveIndex])
    local team1players =  CreateSLGPVPPlayers(msg.misc.result.input.user.team1,team1PlayerInfos,false)
    local team2players =  CreateSLGPVPPlayers(msg.misc.result.input.user.team2,team2PlayerInfos,true)
    local players = {}
    for i = 1,#(team1players),1 do
        table.insert(players,team1players[i])
    end
    table.insert(players,team2players[curWaveIndex])

    local hero = LuaToHeroBuffs(msg.misc.result)
    battleEndFunction = function()
        curWaveIndex = curWaveIndex +1
        print(curWaveIndex,#msg.misc.result.waveInput)
        if curWaveIndex > #msg.misc.result.waveInput then
            isBattleWave = false
            BattlefieldReport.SetBattleResult(msg.misc.result,battleFinishCallback)
            if not BattlefieldReport.Show() then
                Global.QuitSLGPVP(function()
                    BattlefieldReport.ExeExitCallBack()
                end)
                BattlefieldReport.SetBattleResult(nil,nil)
            end
        else
            if msg.misc.result.input.battleType == Common_pb.SceneBattleType_Fort and msg.misc.result.input.user.team2[1].fort ~= nil and msg.misc.result.input.user.team2[1].fort.subType >0 then
                pinfo[2].name = System.String.Format(Global.GTextMgr:GetText("FortArmyNameWave_"..msg.misc.result.input.user.team2[1].fort.subType),curWaveIndex)
            end            
            team1PlayerInfos = SyncPlayerFromWaveInput(sourcePlayerInfos,targetPlayerInfos,msg.misc.result.waveInput[curWaveIndex])
            team1players =  CreateSLGPVPPlayers(msg.misc.result.input.user.team1,team1PlayerInfos,false)
            players = {}
            for i = 1,#(team1players),1 do
                table.insert(players,team1players[i])
            end
            table.insert(players,team2players[curWaveIndex])
			
			local strAConfig = GetResaultConfigPer(msg.misc.result.input , 0)
			local strDConfig = GetResaultConfigPer(msg.misc.result.input , 1)
			local strPhalanxConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvePhalanxConfig).value  
            if support_debug ~= nil and support_debug == 1 then
                --print("battleEndFunction    ",battleEndFunction)
                Global.StartSLGPVP_Debug(players,pinfo,nil,msg.misc.result.input.user.seed,msg.misc.result,battleEndFunction , strAConfig , strDConfig , strPhalanxConfig)
            elseif support_debug ~= nil and support_debug == 2 then
                Global.StartSLGPVPSimple_Debug(players,pinfo,msg.misc.result.input.user.seed,nil,battleEndFunction)
            else
                StartSLGPVP(players,pinfo,nil,msg.misc.result.input.user.seed , msg.misc.result , battleEndFunction , strAConfig , strDConfig , strPhalanxConfig)
            end
        end
    end
	
	local strAConfig = GetResaultConfigPer(msg.misc.result.input , 0)
	local strDConfig = GetResaultConfigPer(msg.misc.result.input , 1)
	local strPhalanxConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvePhalanxConfig).value  
    if support_debug ~= nil and support_debug == 1 then
        Global.StartSLGPVP_Debug(players,pinfo,hero,msg.misc.result.input.user.seed,msg.misc.result,battleEndFunction , strAConfig , strDConfig , strPhalanxConfig)
    elseif support_debug ~= nil and support_debug == 2 then
        Global.StartSLGPVPSimple_Debug(players,pinfo,msg.misc.result.input.user.seed,nil,battleEndFunction)
    else
        StartSLGPVP(players,pinfo,hero,msg.misc.result.input.user.seed , msg.misc.result , battleEndFunction , strAConfig , strDConfig , strPhalanxConfig)
    end
end

function CheckMobaBattleReportEx(msg)
	local pinfo = {}
	local p1 , vs , p2 = MailReportDoc.GetReportShareTitle(msg)
    pinfo[1] = {}
    pinfo[1].name = customCallback == nil and p1 or customCallback("player1")--msg.misc.result.input.user.team1[1].user.name
    pinfo[1].face = customCallback == nil and  MailReportDocNew.GetArmyFace(msg.misc.result.input.user.team1,1)  or customCallback("player1face") --msg.misc.result.input.user.team1[1].user.face
    pinfo[2] = {}
    pinfo[2].name = customCallback == nil and p2 or customCallback("player2")--msg.misc.result.input.user.team2[1].user.name
    pinfo[2].face = customCallback == nil and MailReportDocNew.GetArmyFace(msg.misc.result.input.user.team2,1)  or customCallback("player2face") --msg.misc.result.input.user.team2[1].user.face
    msg.misc.result.ACampPlayers[1].name = p1
    msg.misc.result.DCampPlayers[1].name = p2
    msg.misc.result.ACampPlayers[1].icon = pinfo[1].face     
    msg.misc.result.DCampPlayers[1].icon = pinfo[2].face 
	
	if msg.misc.result.input.user.team2[1].monster ~= nil and msg.misc.result.input.user.team2[1].monster.monsterType == Common_pb.SceneEntryType_ActMonster then
		
    	--local monster = GTableMgr:GetActMonsterRuleData(msg.misc.result.input.user.team2[1].actMonster)
		local monsterName = msg.misc.target.name
    	pinfo[2].face = msg.misc.target.face--RebelData.GetActivityInfo().headIcon
	    pinfo[2].name = Global.GTextMgr:GetText(monsterName--[[monster.name]])
	    msg.misc.result.DCampPlayers[1].icon = pinfo[2].face
	    msg.misc.result.DCampPlayers[1].name = pinfo[2].name
	end
	
	if msg.misc.result.input.user.team1[1].monster ~= nil and msg.misc.result.input.user.team1[1].monster.monsterType == Common_pb.SceneEntryType_SiegeMonster then
		pinfo[1].face = 201
		pinfo[1].name = GTextMgr:GetText("SiegeMonster_" .. msg.misc.siegeShow.wave)
		msg.misc.result.ACampPlayers[1].icon = pinfo[1].face
	    msg.misc.result.ACampPlayers[1].name = pinfo[1].name
	end
	
	if msg.misc.result.input.user.team2[1].seType == Common_pb.SceneEntryType_EliteMonster then
		if msg.misc.result.input.user.team2[1].elite ~= nil then
			local eliteMsg = msg.misc.result.input.user.team2[1].elite
			local elitedata = GTableMgr:GetEliteRebelDataById(eliteMsg.eliteId)
			if elitedata ~= nil then
				pinfo[2].face = elitedata.icon
				pinfo[2].name = Global.GTextMgr:GetText(elitedata.name)
				msg.misc.result.DCampPlayers[1].icon = pinfo[2].face
				msg.misc.result.DCampPlayers[1].name = pinfo[2].name
			end
		end
	end
	
	if msg.misc.result.input.user.team2[1].monster ~= nil and (msg.misc.result.input.user.team2[1].monster.monsterType == Common_pb.SceneEntryType_Monster or 
		reportMsg.misc.result.input.user.team2[1].monster.monsterType == Common_pb.SceneEntryType_WorldMonster) then
		local monBaseId = msg.misc.result.input.user.team2[1].monster.monsterLevel
		local monsterData = GTableMgr:GetMonsterRuleData(monBaseId)
    	pinfo[2].face = 888
	    pinfo[2].name = ""
		if monsterData ~= nil then
			pinfo[2].name = Global.GTextMgr:GetText(monsterData.name)
		end
	    msg.misc.result.DCampPlayers[1].icon = pinfo[2].face
	    msg.misc.result.DCampPlayers[1].name = pinfo[2].name
	end
	
	if msg.misc.result.input.user.team2[1].mobabuild.buildingid > 0 then
		local buildid = msg.misc.result.input.user.team2[1].mobabuild.buildingid
		local buildData = GTableMgr:GetMobaMapBuildingDataByID(buildid)
		pinfo[2].face = 888
	    pinfo[2].name = Global.GTextMgr:GetText(buildData.Name)
	end
	
	pinfo.arr = {}
    pinfo.arr[1] = msg.misc.result.input.user.attrAddMax1
    pinfo.arr[2] = msg.misc.result.input.user.attrAddMax2
	
	PVP_SLG.FillPlayerInfo(pinfo,msg.misc.result)
end

function CheckBattleReportEx(msg,readMailData_subtype, battleFinishCallback,customCallback)
    isBattleWave = false
    if msg.misc.result.waveInput ~= nil and #msg.misc.result.waveInput > 0 then
        CheckBattleReportWaveEx(msg,readMailData_subtype,battleFinishCallback)
        return
    end
    local team1PlayerInfos = CreateSLGPVPPlayerInfo(msg.misc.result.input.user.team1)
    local team2PlayerInfos = CreateSLGPVPPlayerInfo(msg.misc.result.input.user.team2)
    local team1players =  CreateSLGPVPPlayers(msg.misc.result.input.user.team1,team1PlayerInfos,false)
    local team2players =  CreateSLGPVPPlayers(msg.misc.result.input.user.team2,team2PlayerInfos,true)
    local players = {}
    for i = 1,#(team1players),1 do
        table.insert(players,team1players[i])
    end
    for i = 1,#(team2players),1 do
        table.insert(players,team2players[i])
    end
	
    local pinfo = {}
	local p1 , vs , p2 = MailReportDoc.GetReportShareTitle(msg)
    pinfo[1] = {}
    pinfo[1].name = customCallback == nil and p1 or customCallback("player1")--msg.misc.result.input.user.team1[1].user.name
    pinfo[1].face = customCallback == nil and  MailReportDocNew.GetArmyFace(msg.misc.result.input.user.team1,1)  or customCallback("player1face") --msg.misc.result.input.user.team1[1].user.face
    pinfo[2] = {}
    pinfo[2].name = customCallback == nil and p2 or customCallback("player2")--msg.misc.result.input.user.team2[1].user.name
    pinfo[2].face = customCallback == nil and MailReportDocNew.GetArmyFace(msg.misc.result.input.user.team2,1)  or customCallback("player2face") --msg.misc.result.input.user.team2[1].user.face
    msg.misc.result.ACampPlayers[1].name = p1
    msg.misc.result.DCampPlayers[1].name = p2
    msg.misc.result.ACampPlayers[1].icon = pinfo[1].face     
    msg.misc.result.DCampPlayers[1].icon = pinfo[2].face 
    if msg.misc.result.input.user.team2[1].monster ~= nil and msg.misc.result.input.user.team2[1].monster.monsterType == Common_pb.SceneEntryType_ActMonster then
		
    	--local monster = GTableMgr:GetActMonsterRuleData(msg.misc.result.input.user.team2[1].actMonster)
		local monsterName = msg.misc.target.name
    	pinfo[2].face = msg.misc.target.face--RebelData.GetActivityInfo().headIcon
	    pinfo[2].name = Global.GTextMgr:GetText(monsterName--[[monster.name]])
	    msg.misc.result.DCampPlayers[1].icon = pinfo[2].face
	    msg.misc.result.DCampPlayers[1].name = pinfo[2].name
	end
	
	if msg.misc.result.input.user.team1[1].monster ~= nil and msg.misc.result.input.user.team1[1].monster.monsterType == Common_pb.SceneEntryType_SiegeMonster then
		pinfo[1].face = 201
		pinfo[1].name = GTextMgr:GetText("SiegeMonster_" .. msg.misc.siegeShow.wave)
		msg.misc.result.ACampPlayers[1].icon = pinfo[1].face
	    msg.misc.result.ACampPlayers[1].name = pinfo[1].name
	end
	
	if msg.misc.result.input.user.team2[1].seType == Common_pb.SceneEntryType_EliteMonster then
		if msg.misc.result.input.user.team2[1].elite ~= nil then
			local eliteMsg = msg.misc.result.input.user.team2[1].elite
			local elitedata = GTableMgr:GetEliteRebelDataById(eliteMsg.eliteId)
			if elitedata ~= nil then
				pinfo[2].face = elitedata.icon
				pinfo[2].name = Global.GTextMgr:GetText(elitedata.name)
				msg.misc.result.DCampPlayers[1].icon = pinfo[2].face
				msg.misc.result.DCampPlayers[1].name = pinfo[2].name
			end
		end
	end
	
	if msg.misc.result.input.user.team2[1].monster ~= nil and (msg.misc.result.input.user.team2[1].monster.monsterType == Common_pb.SceneEntryType_Monster or 
		msg.misc.result.input.user.team2[1].monster.monsterType == Common_pb.SceneEntryType_WorldMonster) then
		local monBaseId = msg.misc.result.input.user.team2[1].monster.monsterLevel
		local monsterData = GTableMgr:GetMonsterRuleData(monBaseId)
    	pinfo[2].face = 888
	    pinfo[2].name = ""
		if monsterData ~= nil then
			pinfo[2].name = Global.GTextMgr:GetText(monsterData.name)
		end
	    msg.misc.result.DCampPlayers[1].icon = pinfo[2].face
	    msg.misc.result.DCampPlayers[1].name = pinfo[2].name
	end
	
	if msg.misc.result.input.user.team2[1].worldCity ~= nil and msg.misc.result.input.user.team2[1].worldCity.cityId > 0 then
		local cityName = Global.GTextMgr:GetText(GTableMgr:GetWorldCityDataByID(msg.misc.result.input.user.team2[1].worldCity.cityId).Name)
		--player2 = System.String.Format(TextMgr:GetText("ui_citybattle_20") , cityName)
		pinfo[2].name = System.String.Format(Global.GTextMgr:GetText("ui_citybattle_20") , cityName)
		msg.misc.result.DCampPlayers[1].name = pinfo[2].name
	end
	
    pinfo.arr = {}
    pinfo.arr[1] = msg.misc.result.input.user.attrAddMax1
    pinfo.arr[2] = msg.misc.result.input.user.attrAddMax2

	local strAConfig = GetResaultConfigPer(msg.misc.result.input , 0)
	local strDConfig = GetResaultConfigPer(msg.misc.result.input , 1)
	local strPhalanxConfig = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.pvePhalanxConfig).value  
    local hero = LuaToHeroBuffs(msg.misc.result)
    StartSLGPVP(players,pinfo,hero,msg.misc.result.input.user.seed , msg.misc.result , battleFinishCallback,customCallback,strAConfig,strDConfig , strPhalanxConfig)  
end



--[[
function CheckBattleReportNew(reportMsg , formationParam , battleFinishCallback)
    
    isBattleWave = false
	local team1Players = {}
	local team2Players = {}
	
	for i=1 , #reportMsg.misc.result.input.user.team1 do
		local sfd = reportMsg.misc.result.input.user.team1[i]
		local player1 = {}
		player1.Formation = {}
        player1.Armys = {}
        player1.Heros = {}
		
		local myFormation = formationParam.formationSmall:PvPData2Formation(sfd)
		for f =1,8,1 do 
		--print(myFormation[i])
			if myFormation[f] ~= nil then
				player1.Formation[f] = BattleMove.Army2PhalanxType(myFormation[f])
			else
				player1.Formation[f] = 0
			end
		end
		for k=1 , #sfd.army do
			local army = sfd.army[k].army
			local attr = sfd.army[k].attr
			print(army.baseid , army.level)
			local solider = Barrack.GetAramInfo(army.baseid , army.level)
			print(solider.BarrackId)
		
			player1.Armys[k] = {}
			player1.Armys[k].ID = solider.UnitID
			player1.Armys[k].Count = army.num
			player1.Armys[k].Level = army.level
			player1.Armys[k].ArmyType = army.baseid
			player1.Armys[k].PhalanxType = BattleMove.Army2PhalanxType(solider.BarrackId)
			player1.Armys[k].Exp = attr.exp
			player1.Armys[k].HP = attr.hp
			player1.Armys[k].Attack = attr.atk
			player1.Armys[k].Armor = attr.def
			player1.Armys[k].Penetrate =0
		end
        
        for k=1 , #sfd.hero.heros do
            local hero = sfd.hero.heros[k]           
            player1.Heros[k] = {}
            player1.Heros[k].uid = hero.uid
            player1.Heros[k].baseid = hero.baseid
            player1.Heros[k].level = hero.level
            player1.Heros[k].star = hero.star
            player1.Heros[k].grade = hero.grade
            player1.Heros[k].skill_id = hero.uid
		end 

		table.insert(team1Players , player1)
    end
		
		
	for i=1 , #reportMsg.misc.result.input.user.team2 do
		local tfd = reportMsg.misc.result.input.user.team2[i]
		local player2 = {}
		player2.Formation = {}
        player2.Armys = {}
        player1.Heros = {}
		
		local myFormation = formationParam.formationSmall:PvPData2Formation(tfd)
		for f =1,8,1 do 
		--print(myFormation[i])
			if myFormation[f] ~= nil then
				player2.Formation[f] = BattleMove.Army2PhalanxType(myFormation[f])
			else
				player2.Formation[f] = 0
			end
		end
		for k=1 , #tfd.army do
			local army = tfd.army[k].army
			local attr = tfd.army[k].attr
			print(army.baseid , army.level)
			local solider = Barrack.GetAramInfo(army.baseid , army.level)
			print(solider.BarrackId)
		
			player2.Armys[k] = {}
			player2.Armys[k].ID = solider.UnitID
			player2.Armys[k].Count = army.num
			player2.Armys[k].Level = army.level
			player2.Armys[k].ArmyType = army.baseid
			player2.Armys[k].PhalanxType = BattleMove.Army2PhalanxType(solider.BarrackId)
			player2.Armys[k].Exp = attr.exp
			player2.Armys[k].HP = attr.hp
			player2.Armys[k].Attack = attr.atk
			player2.Armys[k].Armor = attr.def
			player2.Armys[k].Penetrate =0
        end
        
        for k=1 , #sfd.hero.heros do
            local hero = sfd.hero.heros[k]           
            player1.Heros[k] = {}
            player1.Heros[k].uid = hero.uid
            player1.Heros[k].baseid = hero.baseid
            player1.Heros[k].level = hero.level
            player1.Heros[k].star = hero.star
            player1.Heros[k].grade = hero.grade
            player1.Heros[k].skill_id = hero.uid
		end         
		
		table.insert(team2Players , player2)
    end
	
	--lua player to c# player
	local players = {}
	for i=1 , #reportMsg.misc.result.input.user.team2 do
		if reportMsg.misc.result.input.user.team2[i].recover == nil then
			reportMsg.misc.result.input.user.team2[i].recover = false
		end
	end
	for i=1 , #reportMsg.misc.result.input.user.team1 do
		if reportMsg.misc.result.input.user.team1[i].recover == nil then
			reportMsg.misc.result.input.user.team1[i].recover = false
		end
	end
		
	for _ , v in pairs(team1Players) do
		local player = Global.LuaToSLGPlayer(v.Formation,v.Armys,
						(reportMsg.misc.result.input.user.team1[1].main and 1 or 0),
						(reportMsg.misc.result.input.user.team1[1].recover and 1 or 0),
						(reportMsg.misc.result.input.user.team1[1].userwar and 1 or 0),
						0,reportMsg.misc.result.input.user.team1[1].injureLeftMax) 
	end

	players[1] = Global.LuaToSLGPlayer(player1.Formation,player1.Armys,
	(reportMsg.misc.result.input.user.team1[1].main and 1 or 0),
	(reportMsg.misc.result.input.user.team1[1].recover and 1 or 0),
	(reportMsg.misc.result.input.user.team1[1].userwar and 1 or 0),
	0,reportMsg.misc.result.input.user.team1[1].injureLeftMax) 
	players[2] = Global.LuaToSLGPlayer(player2.Formation,player2.Armys,
	(reportMsg.misc.result.input.user.team2[1].main and 1 or 0),
	(reportMsg.misc.result.input.user.team2[1].recover and 1 or 0),
	(reportMsg.misc.result.input.user.team2[1].userwar and 1 or 0),
	1,reportMsg.misc.result.input.user.team2[1].injureLeftMax) 


    local pinfo = {}
    pinfo[1] = {}
    pinfo[1].name = reportMsg.misc.result.input.user.team1[1].user.name
    pinfo[1].face = reportMsg.misc.result.input.user.team1[1].user.face
    pinfo[2] = {}
    pinfo[2].name = reportMsg.misc.result.input.user.team2[1].user.name
    pinfo[2].face = reportMsg.misc.result.input.user.team2[1].user.face
    pinfo.arr = {}
    pinfo.arr[1] = reportMsg.misc.result.input.user.attrAddMax1
    pinfo.arr[2] = reportMsg.misc.result.input.user.attrAddMax2 
	
	local hero = LuaToHeroBuffs(reportMsg.misc.result)
	StartSLGPVP(players,pinfo,hero,reportMsg.misc.result.input.user.seed , reportMsg.misc.result , battleFinishCallback)
end

function CheckBattleReport(reportMsg , formationParam , battleFinishCallback)
    isBattleWave = false
	--local formationSmall = formationParam.formationSmall
	local sfd = reportMsg.misc.result.input.user.team1[1]
	local tfd = reportMsg.misc.result.input.user.team2[1]
	--进攻方
	
	local player1 = {}
	player1.Formation = {}
	player1.Armys = {}
	
	local myFormation = formationParam.formationSmall:PvPData2Formation(sfd)
	
	for i =1,8,1 do 
		--print(myFormation[i])
		if myFormation[i] ~= nil then
			player1.Formation[i] = BattleMove.Army2PhalanxType(myFormation[i])
		else
			player1.Formation[i] = 0
		end
    end
	
	for i=1 , #reportMsg.misc.result.input.user.team1[1].army do
		local army = reportMsg.misc.result.input.user.team1[1].army[i].army
		local attr = reportMsg.misc.result.input.user.team1[1].army[i].attr
		print(army.baseid , army.level)
		local solider = Barrack.GetAramInfo(army.baseid , army.level)
		print(solider.BarrackId)
	
		player1.Armys[i] = {}
		player1.Armys[i].ID = solider.UnitID
		player1.Armys[i].Count = army.num
		player1.Armys[i].Level = army.level
		player1.Armys[i].ArmyType = army.baseid
		player1.Armys[i].PhalanxType = BattleMove.Army2PhalanxType(solider.BarrackId)
		player1.Armys[i].Exp = attr.exp
		player1.Armys[i].HP = attr.hp
		player1.Armys[i].Attack = attr.atk
		player1.Armys[i].Armor = attr.def
		player1.Armys[i].Penetrate =0
	end


	local player2 = {}
	player2.Formation = {}
	player2.Armys = {}
	
	local defFormation = formationParam.formationSmall:PvPData2Formation(tfd)
	for i =1,8,1 do 
		if defFormation[i] ~= nil then
			player2.Formation[i] = BattleMove.Army2PhalanxType(defFormation[i])
		else
			player2.Formation[i] = 0
		end
    end
	
	for i=1 , #reportMsg.misc.result.input.user.team2[1].army do
		local army = reportMsg.misc.result.input.user.team2[1].army[i].army
		local attr = reportMsg.misc.result.input.user.team2[1].army[i].attr
		local solider = Barrack.GetAramInfo(army.baseid , army.level)
		
		player2.Armys[i] = {}
		player2.Armys[i].ID = solider.UnitID
		player2.Armys[i].Count = army.num
		player2.Armys[i].Level = army.level
		player2.Armys[i].ArmyType = army.baseid
		player2.Armys[i].PhalanxType = BattleMove.Army2PhalanxType(solider.BarrackId)
		player2.Armys[i].Exp = attr.exp
		player2.Armys[i].HP = attr.hp
		player2.Armys[i].Attack = attr.atk
		player2.Armys[i].Armor = attr.def
		player2.Armys[i].Penetrate =0
	end

	
	for _,v in pairs(player1.Armys) do
		print(v.ID , v.Count)
	
	end
	
	local players = {}
	--players[1] = Global.LuaToSLGPlayer(player1.Formation,player1.Armys,1,1,0,reportMsg.misc.result.input.user.team1[1].injureLeftMax) 
	--players[2] = Global.LuaToSLGPlayer(player2.Formation,player2.Armys,1,1,1,reportMsg.misc.result.input.user.team2[1].injureLeftMax)
    if reportMsg.misc.result.input.user.team2[1].recover == nil then
        reportMsg.misc.result.input.user.team2[1].recover = false
    end
    if reportMsg.misc.result.input.user.team1[1].recover == nil then
        reportMsg.misc.result.input.user.team1[1].recover = false
    end


	players[1] = Global.LuaToSLGPlayer(player1.Formation,player1.Armys,
	(reportMsg.misc.result.input.user.team1[1].main and 1 or 0),
	(reportMsg.misc.result.input.user.team1[1].recover and 1 or 0),
	(reportMsg.misc.result.input.user.team1[1].userwar and 1 or 0),
	0,reportMsg.misc.result.input.user.team1[1].injureLeftMax) 
	players[2] = Global.LuaToSLGPlayer(player2.Formation,player2.Armys,
	(reportMsg.misc.result.input.user.team2[1].main and 1 or 0),
	(reportMsg.misc.result.input.user.team2[1].recover and 1 or 0),
	(reportMsg.misc.result.input.user.team2[1].userwar and 1 or 0),
	1,reportMsg.misc.result.input.user.team2[1].injureLeftMax) 
    

    local pinfo = {}
    pinfo[1] = {}
    pinfo[1].name = reportMsg.misc.result.input.user.team1[1].user.name
    pinfo[1].face = reportMsg.misc.result.input.user.team1[1].user.face
    pinfo[2] = {}
    pinfo[2].name = reportMsg.misc.result.input.user.team2[1].user.name
    pinfo[2].face = reportMsg.misc.result.input.user.team2[1].user.face
    pinfo.arr = {}
    pinfo.arr[1] = reportMsg.misc.result.input.user.attrAddMax1
    pinfo.arr[2] = reportMsg.misc.result.input.user.attrAddMax2 

	local hero = LuaToHeroBuffs(reportMsg.misc.result)
	StartSLGPVP(players,pinfo,hero,reportMsg.misc.result.input.user.seed , reportMsg.misc.result , battleFinishCallback)
end
--]]
local BattleScene_city = 20003
local BattleScene_wilderness = 20002

function GetBattleId(result)

    local pathType = result.input.user.pathType
    local seType = result.input.user.team2[1].seType
    if pathType == Common_pb.TeamMoveType_AttackPlayer or 
       pathType == Common_pb.TeamMoveType_AttackFort or 
       pathType == Common_pb.TeamMoveType_AttackCenterBuild or 
       pathType == Common_pb.TeamMoveType_GatherCall
    then
        if pathType == Common_pb.TeamMoveType_GatherCall then
            if seType == Common_pb.SceneEntryType_Home then
                return BattleScene_city
            else
                return BattleScene_wilderness
            end
        else
            return BattleScene_city
        end
    end
    return BattleScene_wilderness
end

function StartSLGPVP(players,playerInfos,heroBuffs,random_seed,result,exit_call_back,customCallback , strAConfig , strDConfig , strPhalanxConfig)
    DumpMessage(result)
    Global.GGUIMgr:CloseAllMenu()
    PVP_SLG.CalculateK(players)
    PVP_SLG.FillPlayerInfo(playerInfos,result)
    BattlefieldReport.SetBattleResult(result,exit_call_back,customCallback)
    local battleState = GameStateSLGBattle.Instance
    local bid = GetBattleId(result)
    local battleArgs = 
    {
        battleId = bid
    }
    battleState.SlgPlayers = players
    battleState.Slg_Random_Seed = random_seed
    battleState.heroBuffs = heroBuffs
	battleState.strAConfig = strAConfig
    battleState.strDConfig = strDConfig
	battleState.strPhalanxConfig = strPhalanxConfig
    print("strAConfig",strAConfig,"strDConfig",strDConfig , "strPhalanxConfig" , strPhalanxConfig)
    battleState.InitSimulateSLGPVPCfg()
    Main.Instance:ChangeGameState(battleState, cjson.encode(battleArgs),nil)
end

function StartSLGPVP_Debug(players,playerInfos,heroBuffs,random_seed,result,exit_call_back , strAConfig , strDConfig , strPhalanxConfig)
    Global.GGUIMgr:CloseAllMenu()
    PVP_SLG.CalculateK(players)
    PVP_SLG.FillPlayerInfo(playerInfos,result)
    BattlefieldReport.SetBattleResult(result,exit_call_back)
    local battleState = GameStateSLGBattle.Instance
    local bid = GetBattleId(result)
    local battleArgs = 
    {
        battleId = bid,
        enbaleLog = true
    }
    battleState.SlgPlayers = players
    battleState.Slg_Random_Seed = random_seed
    battleState.heroBuffs = heroBuffs
    battleState.InitSimulateSLGPVPCfg()
	battleState.strAConfig = strAConfig
	battleState.strDConfig = strDConfig
	battleState.strPhalanxConfig = strPhalanxConfig
    for i =1,#(players),1 do
        print(players[i]:ToLuaString())
    end
	
	print("strAConfig",strAConfig,"strDConfig",strDConfig , "strPhalanxConfig" , strPhalanxConfig)
    Main.Instance:ChangeGameState(battleState, cjson.encode(battleArgs),nil)
end

function StartSLGPVPSimple_Debug(players,playerInfos,random_seed,input,exit_call_back)
    PVP_SLG.CalculateK(players)
    PVP_SLG.FillPlayerInfo(playerInfos,input)
    GameStateSLGBattle.InitSimulateSLGPVPCfg()
    local slg_pvp = Serclimax.SLGPVP.ScSLGPvP()
    local camps = slg_pvp:StartBattle(players,random_seed,true);
    local pvp_result = Serclimax.SLGPVP.ScSLGPVPResult()
    pvp_result:FillResult(camps)
    print(slg_pvp.Log)
    if exit_call_back ~= nil then
        exit_call_back()
    end
    --slg_pvp:PrintLog()
    --[[
    local sbr = Common_pb.SceneBattleResult()
    --sbr.input = input
    sbr.winteam = pvp_result.WinCamp[1] == 1 and 1 or 2
    for i =1,2,1 do
        sbr.ArmyTotalNum[i] = pvp_result.ArmyTotalNum[i]
    end

    for i =1,2,1 do
        sbr.ArmyDeadNum[i] = pvp_result.ArmyDeadNum[i]
    end

    for i =1,2,1 do
        sbr.ArmyLivedNum[i] = pvp_result.ArmyLivedNum[i]
    end

    for i =1,2,1 do
        sbr.ArmyLossFighting[i] = pvp_result.ArmyLossFighting[i]
    end

    for i =1,2,1 do
        sbr.ArmyInjuredNum[i] = pvp_result.ArmyInjuredNum[i]
    end    
    
    for i =1,2,1 do
        sbr.Exp[i] = pvp_result.Exp[i]
    end  

    for i =1,#(pvp_result.ACampPlayers),1 do
        local player =  sbr.ACampPlayers:add()
        player.uid = pvp_result.ACampPlayers[i].uid;
        player.name = pvp_result.ACampPlayers[i].name;
        player.icon = pvp_result.ACampPlayers[i].icon;
        player.level = pvp_result.ACampPlayers[i].level;
        player.BattleForce = pvp_result.ACampPlayers[i].BattleForce;
        player.Destroy = pvp_result.ACampPlayers[i].Destroy;
        player.Exp = pvp_result.ACampPlayers[i].Exp;

        for j =1,#(presult.ACampPlayers[i].ArmyResults),1 do
            local ars = player.ArmyResults:add()
            ars.Army = {}
            ars.Army.baseid = pvp_result.ACampPlayers[i].ArmyResults[j].Army.ArmyType;
            ars.Army.level = pvp_result.ACampPlayers[i].ArmyResults[j].Army.Level;
            ars.DeadNum = pvp_result.ACampPlayers[i].ArmyResults[j].DeadNum;
            ars.TotalNum = pvp_result.ACampPlayers[i].ArmyResults[j].TotalNum;
            ars.InjuredNum = pvp_result.ACampPlayers[i].ArmyResults[j].InjuredNum;
        end
    end

    for i =1,#(pvp_result.DCampPlayers),1 do
        local player =  sbr.DCampPlayers:add()
        player.uid = pvp_result.DCampPlayers[i].uid;
        player.name = pvp_result.DCampPlayers[i].name;
        player.icon = pvp_result.DCampPlayers[i].icon;
        player.level = pvp_result.DCampPlayers[i].level;
        player.BattleForce = pvp_result.DCampPlayers[i].BattleForce;
        player.Destroy = pvp_result.DCampPlayers[i].Destroy;
        player.Exp = pvp_result.DCampPlayers[i].Exp;

        for j =1,#(presult.DCampPlayers[i].ArmyResults),1 do
            local ars = player.ArmyResults:add()
            ars.Army = {}
            ars.Army.baseid = pvp_result.DCampPlayers[i].ArmyResults[j].Army.ArmyType;
            ars.Army.level = pvp_result.DCampPlayers[i].ArmyResults[j].Army.Level;
            ars.DeadNum = pvp_result.DCampPlayers[i].ArmyResults[j].DeadNum;
            ars.TotalNum = pvp_result.DCampPlayers[i].ArmyResults[j].TotalNum;
            ars.InjuredNum = pvp_result.DCampPlayers[i].ArmyResults[j].InjuredNum;
        end
    end    
    BattlefieldReport.SetBattleResult(sbr,nil)
    --]]
end

function SaveMailBattleReport(index, path)
    local lds = MailListData.GetMailDataByType(3)
    if index >=1 and index <= #(lds) then
        local req = MailMsg_pb.MsgUserMailReadRequest()
        req.mailid = lds[index].id
        req.isRead = true
        Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailReadRequest, req, MailMsg_pb.MsgUserMailReadResponse, function(msg)
            if msg.code == 0 then
                local file = io.open(path, "wb")
                file:write(msg:SerializeToString())
                file:close()
                print("save report sucess!")
            else
                print(msg.code)
            end
        end, true)
    end
end

function PlayBattleReport(path)
    local file = io.open(path, "rb")
    if file ~= nil then
        local msg = MailMsg_pb.MsgUserMailReadResponse() 
        msg:ParseFromString(file:read("*all"))
        BattleReportDebugEx(msg)
        file:close()
    else
        print("open report failed!")
    end
end

function PlaySLGPVPReport(reportName)
    local msg = MailMsg_pb.MsgUserMailReadResponse() 
    msg:ParseFromString(GResourceLibrary:GetSLGPVPReportBytes(reportName))
    local sourceName = GTextMgr:GetText(Text.Evil_rebels)
    local targetName = GTextMgr:GetText(Text.Our_defenders)
    local sourceFace = 101
    local targetFace = 110
    local misc = msg.mail.misc
    local result = misc.result
    msg.mail.contentparams[1].value = sourceName

    misc.source.name = sourceName
    misc.source.face = sourceFace
    misc.target.name = targetName
    misc.target.face = targetFace

    local ACampPlayers = result.ACampPlayers
    local DCampPlayers = result.DCampPlayers
    if #ACampPlayers > 0 then
        ACampPlayers[1].name = sourceName
        ACampPlayers[1].icon = sourceFace
    end
    if #DCampPlayers > 0 then
        DCampPlayers[1].name = targetName
        DCampPlayers[1].icon = targetFace
    end

    local user = result.input.user
    local team1 = user.team1
    local team2 = user.team2
    if #team1 > 0 then
        team1[1].user.name = sourceName
        team1[1].user.face = sourceFace
    end
    if #team2 > 0 then
        team2[1].user.name = targetName
        team2[1].user.face = targetFace
    end
    BattlefieldReport.SetEventData(sourceName, sourceFace, targetName, targetFace)
    BattleReportDebugEx(msg)
end

function SLGPVP4Mail(index)
        local lds = MailListData.GetMailDataByType(3)
        if index >=1 and index <= #(lds) then
	        local req = MailMsg_pb.MsgUserMailReadRequest()
            req.mailid = lds[index].id
            req.isRead = true
	        Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailReadRequest, req, MailMsg_pb.MsgUserMailReadResponse, function(msg)
		        if msg.code == 0 then
                    BattleReportDebugEx(msg)
                    --MailReportDoc.BattleReportDebug(msg)
		        else
			        print(msg.code)
		        end
            end, true)
        end
    end

function SLGPVP4MailEx(index)
        local lds = MailListData.GetMailDataByType(3)
        if index >=1 and index <= #(lds) then
	        local req = MailMsg_pb.MsgUserMailReadRequest()
            req.mailid = lds[index].id
            req.isRead = true
	        Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailReadRequest, req, MailMsg_pb.MsgUserMailReadResponse, function(msg)
		        if msg.code == 0 then
		            BattleReportDebugEx(msg,1)
                    --MailReportDoc.BattleReportDebug(msg,1)
		        else
			        print(msg.code)
		        end
            end, true)
        end
    end

function StartSimulateSLGPVP()
    StartSLGPVP_Debug(GetSimulateSLGPlayers(),nil,nil,12345678 , "" , "")    
end

function QuitSLGPVP(done_cb)
    local mainState = GameStateMain.Instance
	Global.GGUIMgr:CloseAllMenu()
	Main.Instance:ChangeGameState(mainState, "",done_cb)
end

function SetBattleReportBack(mainui , menu , x , y)
	BattleReportBack = {}
	BattleReportBack.MainUI = mainui
	BattleReportBack.Menu = menu
	BattleReportBack.PosX = x
	BattleReportBack.PosY = y
end

function GetBattleReportBack()
	return BattleReportBack
end

function SetMenuBackState(mainui , menu , x , y)
	MenuBackState = {}
	MenuBackState.MainUI = mainui
	MenuBackState.Menu = menu
	MenuBackState.PosX = x
	MenuBackState.PosY = y
end

function GetMenuBackState()
	return MenuBackState
end

function ClearMenuBackState()
	MenuBackState = nil
end

function SetChatEnterChanel(chatChanel)
	ChatEnterChanel = chatChanel
end

function GetChatEnterChanel()
	if ChatEnterChanel == 0 then
		ChatEnterChanel = ChatMsg_pb.chanel_world
	end
	return ChatEnterChanel
end

function SetMobaChatEnterChanel(chatChanel)
	MobaChatEnterChanel = chatChanel
end

function MobaGetChatEnterChanel()
	if MobaChatEnterChanel == 0 then
		MobaChatEnterChanel = ChatMsg_pb.chanel_MobaWorld
	end
	return MobaChatEnterChanel
end

function SetGuildMobaChatEnterChanel(chatChanel)
	GuildMobaChatEnterChanel = chatChanel
end

function GuildMobaGetChatEnterChanel()
	if GuildMobaChatEnterChanel == 0 then
		GuildMobaChatEnterChanel = ChatMsg_pb.chanel_GuildMobaWorld
	end
	return GuildMobaChatEnterChanel
end

local languageDataList
local function LoadLanguageData()
    local settingTable = GTableMgr:GetSettingTable()
	for _ , v in pairs(settingTable) do
		local settingData = v
        if settingData.ParentID == 2 then
            languageDataList[settingData.LanguageCode] = settingData
        end
	end
	
    --[[local iter = settingTable:GetEnumerator()
    while iter:MoveNext() do
        local settingData = iter.Current.Value
        if settingData.ParentID == 2 then
            languageDataList[settingData.LanguageCode] = settingData
        end
    end]]
end


function GetLanguageDataById(id)
    if languageDataList == nil then
        languageDataList = {}
        LoadLanguageData()
    end
    return languageDataList[id]
end

function GetLanguageTextById(id)
    if id == -1 then
        return GTextMgr:GetText(Text.all_language)
    end
    local languageData = GetLanguageDataById(id)
    return GTextMgr:GetText(languageData.Des)
end

function GetLastOnlineText(onlineTime)
    if onlineTime == 0 then
        return GTextMgr:GetText(Text.union_online)
    end

    local elapsedSecond = GameTime.GetSecTime() - onlineTime
    if elapsedSecond > MONTH_SECOND then
        return Format(GTextMgr:GetText(Text.union_moon), math.floor(elapsedSecond / MONTH_SECOND))
    elseif elapsedSecond > DAY_SECOND then
        return Format(GTextMgr:GetText(Text.union_day), math.floor(elapsedSecond / DAY_SECOND))
    elseif elapsedSecond > HOUR_SECOND then
        return Format(GTextMgr:GetText(Text.union_hour), math.floor(elapsedSecond / HOUR_SECOND))
    elseif elapsedSecond > MINUTE_SECOND then
        return Format(GTextMgr:GetText(Text.union_minute), math.floor(elapsedSecond / MINUTE_SECOND))
    else
        return Format(GTextMgr:GetText(Text.union_minute), 1)
    end
end

function IsNeighboringCoord(x1, y1, x2, y2)
    return x1 == x2 and abs(y1 - y2) == 1 or y1 == y2 and abs(x1 - x2) == 1
end


function DisposeRestrictAreaNotify()
	local req = ClientMsg_pb.MsgClientNotifyInfoRequest()
    req.notify:append(ClientMsg_pb.ClientNotifyType_ThrowoutCtrZone)
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgClientNotifyInfoRequest, req, ClientMsg_pb.MsgClientNotifyInfoResponse, function(msg)
		if msg.code == 0 then
		    if msg.data ~= nil and (#msg.data) > 0 and msg.data[1].notify == ClientMsg_pb.ClientNotifyType_ThrowoutCtrZone then
                MessageBox.Show(GTextMgr:GetText("ControlZone_ui4"))
            end
		else
            Global.ShowError(msg.code)
        end
    end, true)
end

function GetGoalTimeSec(mins)
	return math.floor(Serclimax.GameTime.GetSecTime() / 86400) * 86400 + mins * 60
end

function CreatEnumTable(tbl, index) 
    --assert(IsTable(tbl)) 
    local enumtbl = {} 
    local enumindex = index or 0 
    for i, v in ipairs(tbl) do 
		local strs = string.split(v , "=")
		if #strs == 1 then
			enumtbl[v] = enumindex + i
		elseif #strs > 1 then
			local sV = string.gsub(strs[2] , " " , "")
			local index = tonumber(sV)
			enumtbl[string.gsub(strs[1] , " " , "")] = index
			enumindex = index
		end
    end 
    return enumtbl 
end 

function Reconnect()
	login.RequestData()
	-- if GUIMgr:IsMenuOpen("WorldMap") then
	-- 	WorldMap.RequestMapData(false)
	-- end
end

function TestChat(groupid , text)
	--[[local send = {}
	send.curChanel = ChatMsg_pb.chanel_guild
	send.spectext = ""
	--send.content = memmsg.user.name .. "创建了讨论组"
	send.content = text and text or "global test"
	send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
	send.chatType = 1
	send.groupid = groupid
	--send.senderguildname = UnionInfoData.GetData().guildInfo.name
	Chat.SendGroupContent(send)]]
	local send = {}
	send.curChanel = ChatMsg_pb.chanel_GuildMobaTeam
	send.spectext = "ysyyyyyy"
	send.content = "Chat_TestSystemJump_Moba01"..",".."pipijki" .."," .."ggggg"
	send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
	send.chatType = 4
	GuildMobaChat.SendContent(send)  

	
end


function testJson()
	local test = 
	{
		ad = 1.7,
		external_sns = 0.6,
	}
	
	local str = cjson.encode(test)
	
	local resp = cjson.decode(str)
	print(resp.ad , resp.external_sns)
end
--{"ad": 0.0, "external_sns": 1.6288684889786964e-07}

function ToDouble(num)
	if(num == "" or num == nil) then
		return "-1"
	end
	
	if string.match(num , "e") == nil and string.match(num , "E") == nil then
		return  string.format("%.2f" , tonumber(num))
	end
	
	local str = nil
	if string.match(num , "e") ~= nil then
		str = string.split(num , "e")
	else
		str = string.split(num , "E")
	end
	
	local cinum = 0
	local op = nil
	local ci = 1
	
	local sCi = nil
	if string.match(str[2] , "-") ~=  nil then
		sCi = string.split(str[2] , "-")
		op = "-"
	elseif string.match(str[2] , "+") ~= nil then
		sCi = string.split(str[2] , "+")
		op = "+"
	end
	
	if sCi ~= nil and #sCi == 2 then
		cim = tonumber(sCi[2])
		
		for i=1 , cim do
			ci = ci * 10
		end
		
		if op == "-" then
			return string.format("%.2f" , tonumber(str[1]) / ci)
		end
		if op == "+" then
			return string.format("%.2f" , tonumber(str[1]) * ci)
		end
	end
	
	return "-1"
end

function RequestChatInvalidCSharp(msgType , content , callback)
	local url = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ChatFilterUrl).value
	local chatMsg = 
	{
		product = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ChatFilterProduct).value , 
		user_id = tostring(MainData.GetCharId()) , 
		message_type = msgType or "mail" , 
		text = content or ""
	}
	
	local strBody = cjson.encode(chatMsg)
	local header = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ChatFilterHeader).value or ""
	
	local strHeaders = string.msplit(header , ";" , ":")
	local reqHeader = System.Collections.Generic.Dictionary_string_string()
	for i, v in ipairs(strHeaders) do
		if #v == 2 then
			reqHeader:Add(v[1], v[2])
		end
	end
	
	GGUIMgr:HttpRequest(url ,reqHeader , strBody, function(success , res)
		if(callback ~= nil) then
			if(success == 0) then
				local response = {}
				if res ~= "" then
					response = cjson.decode(res)
				end
				local v_ad = ToDouble(response.ad)
				local v_sns = ToDouble(response.external_sns)
				print(string.format("发送内容评分 = ad:%s , sns:%s ; tonumber = %d , %d" ,response.ad , response.external_sns  ,v_ad , v_ad ))
				callback(success , tonumber(v_ad) , tonumber(v_sns))
			else
				callback(success , -1 ,-1)
			end
		end
	end)
end

function RequestChatInvalidLua(msgType , content , callback)
	local url = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ChatFilterUrl).value
	local chatMsg = 
	{
		product = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ChatFilterProduct).value , 
		user_id = tostring(MainData.GetCharId()) , 
		message_type = msgType or "mail" , 
		text = content or ""
	}
	
	local header = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ChatFilterHeader).value or ""
	local strHeaders = string.msplit(header , ";" , ":")
	local reqHeader = System.Collections.Generic.Dictionary_string_string()
	
	for i, v in ipairs(strHeaders) do
		if #v == 2 then
			reqHeader:Add(v[1], v[2])
		end
	end
	
	local strBody =	cjson.encode(chatMsg)
	coroutine.start(function()
		local www = UnityEngine.WWW( url,System.Text.Encoding.UTF8:GetBytes(strBody), reqHeader)
        coroutine.www(www)
		
		if(www.isDone) then
			if www.error ~= nil then
				if callback ~= nil then
					callback(1 , -1 , -1)
				end
			else
				if callback ~= nil then
					local response = cjson.decode(www.text)
					callback(0 , response.ad , response.external_sns) 
				end
			end
			
			coroutine.stop(www)
		end
	end)
end

function TestChat1(groupid , text)
	--[[local send = {}
	send.curChanel = ChatMsg_pb.chanel_guild
	send.spectext = ""
	--send.content = memmsg.user.name .. "创建了讨论组"
	send.content = text and text or "global test"
	send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
	send.chatType = 1
	send.groupid = groupid
	--send.senderguildname = UnionInfoData.GetData().guildInfo.name
	Chat.SendGroupContent(send)]]
	local send = {}
	send.curChanel = ChatMsg_pb.chanel_world
	send.spectext = "d:100"..",".. "d:001" .. "," .. "d:1yyy"
	send.content = "Chat_TestSystemJump_Moba01"..",".."pipijki" .."," .."ggggg"
	send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
	send.chatType = 10
	Chat.SendContent(send)         
end

function AutoChat(name , repeatTime)
	coroutine.start(function()
		for i=1 , math.huge , 1 do
			TestChat(name)
			coroutine.wait(1.5)
			
			if repeatTime ~= nil and i >= repeatTime then
				break
			end
		end
	end)
	
end

function TestUpgradeBuilding(buildid)
	local reqstart = Serclimax.GameTime.GetMilSecTime()
	print(buildid)
	local req = BuildMsg_pb.MsgUpgradeBuildRequest()
	req.uid = buildid
	req.type = BuildMsg_pb.BuildUpgradeType_Worker
	
	LuaNetwork.testCallback = function(typeId)
		print(Serclimax.GameTime.GetMilSecTime() -reqstart )
	end
	LuaNetwork.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgUpgradeBuildRequest, req:SerializeToString(), function(typeId, data)	
		print(Serclimax.GameTime.GetMilSecTime() -reqstart )
		--local loadStart = Serclimax.GameTime.GetMilSecTime()
		--print(Serclimax.GameTime.GetMilSecTime() -loadStart )
	end, true)
end

function JSTest()
	local filePath =  cc.FileUtils:getInstance():fullPathForFilename( FILE_NAME )
end

function GetFiveOclockCooldown(onlyCooldownSecond)
    local utcOffset = 0
    local platformType = GGUIMgr:GetPlatformType()
    if Global.IsIosMuzhi() or
        platformType == LoginMsg_pb.AccType_adr_muzhi or
        platformType == LoginMsg_pb.AccType_adr_opgame or
        platformType == LoginMsg_pb.AccType_self_adr or
        platformType == LoginMsg_pb.AccType_adr_mango or 
        platformType == LoginMsg_pb.AccType_adr_official or
        platformType == LoginMsg_pb.AccType_ios_official or
        platformType == LoginMsg_pb.AccType_adr_official_branch or
        platformType == LoginMsg_pb.AccType_adr_quick then
        utcOffset = 3600 * 8
    end

    local serverTime = GameTime.GetSecTime()
    local todaySecond = (serverTime % (3600 * 24))
    local cooldownSecond = (3600 * 5 - utcOffset) % (3600 * 24)
    if platformType == LoginMsg_pb.AccType_adr_qihu then
        cooldownSecond = (utcOffset) % (3600 * 24)
    end
    if onlyCooldownSecond then
        return cooldownSecond
    end
    if todaySecond < cooldownSecond then
        return serverTime - todaySecond + cooldownSecond
    else
        return serverTime - todaySecond + cooldownSecond + 3600 * 24
    end
end

function GetWeekFiveOclockCooldown(onlyCooldownSecond)
    local utcOffset = 0
    local platformType = GGUIMgr:GetPlatformType()
    if Global.IsIosMuzhi() or
        platformType == LoginMsg_pb.AccType_adr_muzhi or
        platformType == LoginMsg_pb.AccType_adr_opgame or
        platformType == LoginMsg_pb.AccType_self_adr or
        platformType == LoginMsg_pb.AccType_adr_mango or
        platformType == LoginMsg_pb.AccType_adr_official or
        platformType == LoginMsg_pb.AccType_ios_official or
        platformType == LoginMsg_pb.AccType_adr_official_branch or
        platformType == LoginMsg_pb.AccType_adr_quick then
        utcOffset = 3600 * 8
    end
    local serverTime = GameTime.GetSecTime()
    local todaySecond = (serverTime % (3600 * 24))
    local cooldownSecond = (3600 * 5 - utcOffset) % (3600 * 24)
    if platformType == LoginMsg_pb.AccType_adr_qihu then
        cooldownSecond = (utcOffset) % (3600 * 24)
    end
    
    local ttab = os.date("*t",serverTime)
    local one_day = false
    local n = 0
    if ttab.wday < 2 then
        if todaySecond < cooldownSecond then
            n = 1
        else
            n = 0
            one_day = true
        end        
    elseif ttab.wday > 2 then
        n = 7 - ttab.wday + 2
    elseif ttab.wday == 2 then
        if todaySecond < cooldownSecond then
            n = 0
        else
            n = 7 - ttab.wday + 2
        end
    end
    if onlyCooldownSecond then
        return cooldownSecond+(3600 * 24)*n
    end
    if todaySecond < cooldownSecond then
        return serverTime - todaySecond + cooldownSecond+(3600 * 24)*n
    else
        return serverTime - todaySecond + cooldownSecond +(3600 * 24)*n + (one_day and 3600 * 24 or 0)
    end
end

function IsTimeInToday(calculateTime)
    return calculateTime > GetFiveOclockCooldown() - 3600 * 24
end

function IsTodayFirstLogin()
    if UnityEngine.PlayerPrefs.GetInt("lastsecond") == 0 then
        UnityEngine.PlayerPrefs.SetInt("lastsecond", GetFiveOclockCooldown())
        UnityEngine.PlayerPrefs.Save()
        return true
    elseif UnityEngine.PlayerPrefs.GetInt("lastsecond") < GetFiveOclockCooldown() then
        UnityEngine.PlayerPrefs.SetInt("lastsecond", GetFiveOclockCooldown())
        UnityEngine.PlayerPrefs.Save()
        return true
    else
        return false
    end
end

function Check(check_result,print_str)
    if not isEditor then
        return check_result
    end    
    if check_result then
        print(print_str)
    end    
    return check_result;
end

--BuildQueueUnlock
local UpdateBuildQueueLimit = nil
function CheckBuildQueue(queueIndex)
	if UpdateBuildQueueLimit == nil then
		UpdateBuildQueueLimit = {}
		local unlockStr = GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.BuildQueueUnlock).value
		local str = unlockStr:split(";")
		for i=1 , #str do
			local buildQueueStr = str[i]:split(":")
			UpdateBuildQueueLimit[tonumber(buildQueueStr[1])] = tonumber(buildQueueStr[2])
		end
	end
	
	local unlockVip = UpdateBuildQueueLimit[queueIndex] ~= nil and UpdateBuildQueueLimit[queueIndex] or 0
	return unlockVip
end

function GetServerTime()
	local req = ClientMsg_pb.MsgGetServerTimeRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetServerTimeRequest, req, ClientMsg_pb.MsgGetServerTimeResponse, function(msg)
		print("------------get server time")
		local fields = msg._fields
		for k, v in pairs(fields) do
			print(k.name , " = " , v)
		end
		
	end , true)
	
end

--[[local cjson = require "cjson"
function jsonTest()
	print("===================jsonTest============================================")
	local testDataTable = {}
	testDataTable[1] = {}
	testDataTable[1]["age"] = 23
	testDataTable[1]["testArray"] = {}
	testDataTable[1]["testArray"]["array"] = {8,9,11,14,25}
	testDataTable[1]["Himi"] = "himigame.com"
	
	local enStr = cjson.encode(testDataTable)
	print("encode result str:" .. enStr)
	
	local data = cjson.decode(enStr)
	print(data[1]["testArray"]["array"][1])
	
	print("===================jsonTest============================================")
end]]


function makeMsgTable(msg)
	local result_table = {}
	msg2Table(msg , result_table)
	return reslult_table
end

function msg2Table(msg , restable)
	local fields = msg._fields
	if fields ~= nil then
		for k, v in pairs(fields) do
			if type(v) ~= "table" then
				if type(v) == "string" then
					restable[k.name] = tostring(v)
				else
					restable[k.name] = v
					--print(restable[k.name])
				end
			else
				restable[k.name] = {}
				msg2Table(v , restable[k.name])
			end
		end
	end
end

function InitFileRecorder()
	if GFileRecorder == nil then
		print("===========init fileRecorder==============")
		GFileRecorder = FileRecorder(MainData.GetCharId(), ServerListData.GetCurrentAreaId(), ServerListData.GetCurrentZoneId())
		GFileRecorder:GetConfigData()
	end
	GFileRecorder:GetRecordToBuff()
end

function CreateDirectory(path , file)
	Global.GGUIMgr:CreateDirectory(path , file)
end

function Base2String(baseStr)
	return Global.GGUIMgr:Base2String(baseStr)
end

function String2Base(str)
	return Global.GGUIMgr:String2Base(str)
end

function copy_table(ori_tab)  
    if type(ori_tab) ~= "table" then  
        return  
    end  
    local new_tab = {}  
    for k, v in pairs(ori_tab) do  
        new_tab[k] = v  
    end  
    return new_tab  
end 

--pvp4pve缓存数据
local currentP4PVE = nil
function ResetCurrentP4PVE()
	currentP4PVE = nil
end

function ResetCurrentP4PVEMsg()
	if currentP4PVE ~= nil then
		currentP4PVE.result = nil
		currentP4PVE.battleFail = true
	end
end

function ResetCurrentP4PVEBattleState()
	if currentP4PVE ~= nil and currentP4PVE.battleFail ~= nil then
		currentP4PVE.battleFail = false
	end
	
end

function GetCurrentP4PVEMsg()
	return currentP4PVE
end

function SetCurrentP4PVEMsg(battleid , msg)
	if currentP4PVE == nil then
		currentP4PVE = {id = battleid , result = msg}
	else
		if currentP4PVE.id ~= nil and currentP4PVE.id == battleid then
			currentP4PVE.result = msg
		else
			currentP4PVE = {id = battleid , result = msg}
		end
	end
end
local SupportPlayBack= false

function GetSupportPlayBack()
    return SupportPlayBack
end

function ClearSupportPlayBack()
    SupportPlayBack= false
end

function CheckSupportPlayBack(callback)
    FunctionListData.IsFunctionUnlocked(308, function(isactive)
        if not isactive then
            if callback ~= nil then
                SupportPlayBack = isactive;
                callback()
            end
        else
            if tonumber(os.date("%d")) == UnityEngine.PlayerPrefs.GetInt("b_today") then
                MessageBox.SetOkNow()
            else
                MessageBox.SetRemberFunction(function(ishide)
                    if ishide then
                        UnityEngine.PlayerPrefs.SetInt("b_today",tonumber(os.date("%d")))
                        UnityEngine.PlayerPrefs.Save()
                    end
                end)
            end
            MessageBox.Show(Global.GTextMgr:GetText("ui_battleskip_text"), function()
                if callback ~= nil then
                    SupportPlayBack = true;
                    callback()
                end
            end, 
            function()
                if callback ~= nil then
                    SupportPlayBack = false;
                    callback()
                end 
            end)
        end
    end)

end

function SendNormailMail(index , tarName)
	local sendReq = MailMsg_pb.MsgUserMailSendRequest()
	sendReq.title = "tittle?"--mailNew.titile.text
	sendReq.content = "content" .. index
	sendReq.clientlangcode = Global.GTextMgr:GetCurrentLanguageID()

	sendReq.targetname:append(tarName)
	Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailSendRequest, sendReq, MailMsg_pb.MsgUserMailSendResponse, function(msg)
		--MailListData.SetData(msg.maillist)
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
			return
		else
			
		end
	end)

end

function SecondToStringFormat(second, format)
    local isChina = Global.IsIosMuzhi()  or
     GGUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_muzhi or
     GGUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_opgame or 
     GGUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_mango or
     GGUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_qihu--[[or
     GGUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official or
     GGUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_official or
     GGUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_official_branch]]
    local utcOffset = 0
    if isChina then
        utcOffset = 3600 * 8
    end
    return GameTime.SecondToStringFormat(second + utcOffset, format, false)
end

function IsOutSea()


    local platformType = GGUIMgr:GetPlatformType()
    if platformType == LoginMsg_pb.AccType_self_ios or
    platformType == LoginMsg_pb.AccType_self_adr or
    platformType == LoginMsg_pb.AccType_adr_tmgp or
    Global.IsIosMuzhi() or
    platformType == LoginMsg_pb.AccType_adr_muzhi or
    --platformType == LoginMsg_pb.AccType_adr_opgame or
    platformType == LoginMsg_pb.AccType_adr_mango --[[or
    platformType == LoginMsg_pb.AccType_adr_official]] then
        return false
    else
        return true
    end
end

function DistributeInHome()
	local platformType = GGUIMgr:GetPlatformType()
    return (platformType == LoginMsg_pb.AccType_adr_official) or
    (platformType == LoginMsg_pb.AccType_ios_official) or
    (platformType == LoginMsg_pb.AccType_adr_official_branch) or
    (platformType == LoginMsg_pb.AccType_adr_opgame) or
    platformType == LoginMsg_pb.AccType_adr_quick or
    platformType == LoginMsg_pb.AccType_adr_qihu
end


function LoadMainCity()
    local apple_review = ServerListData.IsAppleReviewing()
    if apple_review then
        Global.GGameStateMain:LoadMainCity("maincity_B")
    else
        Global.GGameStateMain:LoadMainCity("maincity")
    end
end


function Load3DTerrain()
    local apple_review = ServerListData.IsAppleReviewing()
    if apple_review then
        return Global.GResourceLibrary:GetWorldTerrainPrefab("3DTerrain_B")
    else
        return Global.GResourceLibrary:GetWorldTerrainPrefab("3DTerrain")
    end    
end

function Load3DTerrain4Moba()
    local apple_review = ServerListData.IsAppleReviewing()
    if apple_review then
        return Global.GResourceLibrary:GetWorldTerrainPrefab("3DTerrain_moba")
    else
        return Global.GResourceLibrary:GetWorldTerrainPrefab("3DTerrain_moba")
    end    
end

function Load3DTerrain4GuildMoba()
    return Global.GResourceLibrary:GetWorldTerrainPrefab("3DTerrain_guild_moba")
end


function IsIosMuzhi()
	local platformType = GGUIMgr:GetPlatformType()
    if platformType == LoginMsg_pb.AccType_ios_muzhi or
		platformType == LoginMsg_pb.AccType_ios_muzhi2 or
        platformType == 108 or
        platformType == 109  then
        return true
    end
	
	return false
end 

local mobaMode = 0

function GetMobaMode()
    --mobaMode = 2;
    if not ACTIVE_GUILD_MOBA then
        if mobaMode >= 2 then
            return 0;
        end
    end
    return mobaMode
end

function IsSlgMobaMode()
    return GetMobaMode() ~= 0
end


--public enum WorldMode
--{
--    Normal = 0,
--    Moba = 1,
--    GuildMoba = 2,
--}
function SetSlgMobaMode(int_moba_mode)
    mobaMode = int_moba_mode
    if not ACTIVE_GUILD_MOBA then
        if mobaMode >= 2 then
            mobaMode = 0
        end
    end
end

function RequestMobaData(finish_call_back)
    if GetMobaMode() == 1 then
        MobaHeroListData.RegistAttributeModel()
        MobaMainData.RequestData()  
	    MobaTechData.RequestMobaTechList()
        MobaBuffData.RequestData()
        MobaZoneBuildingData.RequestData()
	    MobaRadarData.RequestData()
	    MailListData.RequestData(MailMsg_pb.MailType_Moba)
        MobaChatData.RequestChatInfo()
        local mt = MobaMassTroops()
        mt:RequsetMassTotalNum(function(count1,count2) 
            MobaMain.MassTotlaNum[1] = count1
            MobaMain.MassTotlaNum[2] = count2
            MobaMain.PreMassTotalNum[1] = count1
            MobaMain.PreMassTotalNum[2] = count2
    
            print("12122222222222222222222222MassTotlaNum ",MobaMain.MassTotlaNum[1],MobaMain.MassTotlaNum[2])
        end)
        MobaTeamData.RequestData(function()
                if finish_call_back then
                finish_call_back()
            end
        end)  
    elseif GetMobaMode() == 2 then
        MobaHeroListData.RegistAttributeModel()
        MobaMainData.RequestData()
		MobaBuffData.RequestData()
		MailListData.RequestGuildMobaData()
		GuildMobaChatData.RequestChatInfo()
        MobaTeamData.RequestData(function()
            if finish_call_back then
            finish_call_back()
        end
    end)   
	   --MailListData.RequestData(MailMsg_pb.MailType_GuildMoba)
	   --MobaBuffData.RequestData()
    end    
end

local need_wait_init_map = nil

function ExeInitMap()
    if need_wait_init_map ~= nil then
        need_wait_init_map(true)
    end
    need_wait_init_map = nil
end

function RequestEnterMap(callback)
    need_wait_init_map = nil
    if GetMobaMode() == 1 then
        if callback ~= null then
            callback(true)
        end
    else
        print("Start GuildMobaEnterMapRequest")
        local req = GuildMobaMsg_pb.GuildMobaEnterMapRequest()
        Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaEnterMapRequest, req, GuildMobaMsg_pb.GuildMobaEnterMapResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                print("GuildMobaEnterMapRequest",msg.init)
                if callback ~= nil then
                    if not msg.init then
                        need_wait_init_map = callback
                    else
                        callback(msg.init)
                    end
                end
            elseif msg.code == ReturnCode_pb.Code_GuildMoba_ShieldNotice then
                MessageBox.Show(Global.GTextMgr:GetText("Code_GuildMoba_ShieldNotice"), function()
                    UnionMobaActivityData.RequestEnterMap(function()
                        callback(msg.init)
                    end, unlockScreen, true)
                end,function() end)    
            else
                print("GuildMobaEnterMapRequest failed",msg.code)
                if callback ~= null then
                    callback(false)
                end
            end
        end, true)
    end
end



function MakeAward(award)   --解析奖励 类型：ID：数量：参数1：参数2
                            --类型1表示道具，后续为道具ID
                            --类型3表示将军，后续为将军ID，参数1表示将军星级，参数2表示将军等级，默认都为1
                            --类型4表示士兵，后续为士兵ID，参数1位0，参数2表示士兵等级，默认为1
    local reward = {}
    reward.items = {}
    reward.heros = {}
    reward.armys = {}
    if award == "" then
        return reward
    end
    local str = string.msplit(award, ";", ":")
    for i, v in ipairs(str) do
        if v[1] == "1" then
            local item = {}
            item.id = tonumber(v[2])
            item.baseid = item.id
            item.num = tonumber(v[3])
            table.insert(reward.items, item)
        elseif v[1] == "3" then
            local hero = {}
            hero.id = tonumber(v[2])
            hero.baseid = hero.id
            hero.num = tonumber(v[3])
            hero.star = v[4] ~= nil and tonumber(v[4]) or 1
            hero.level = v[5] ~= nil and tonumber(v[5]) or 1
            table.insert(reward.heros, hero)
        elseif v[1] == "4" then
            local army = {}
            army.id = tonumber(v[2])
            army.baseid = army.id
            army.num = tonumber(v[3])
            army.level = v[5] ~= nil and tonumber(v[5]) or 1
            table.insert(reward.armys, army)
        end
    end
    return reward
end

function PrintAll(t)
    table.foreach(t, function(i, v)
        print(i, v)
        if type(v) == "table" then
            PrintAll(v)
        end
    end)
end

function MobaArmyNum4EmbassyPlayer()
    --科技 ，角色
    AttributeBonus.CollectBonusInfo(nil,false,{"MobaBuffData","MobaTechData", "MobaBattleMove"})
    local bonus = AttributeBonus.GetBonusInfos()  
    local base = GTableMgr:GetMobaUnitInfoByID(8)
    local army_num = tonumber( base.Value) +(bonus[1093] ~= nil and bonus[1093] or 0)
    return army_num
end

--[[
function MobaArmyNum4EmbassyBuild()
    AttributeBonus.CollectBonusInfo(nil,false,"MobaTechData")
    local bonus = AttributeBonus.GetBonusInfos()  
    local base = TableMgr:GetMobaUnitInfoByID(8)
    local army_num = tonumber( base.Value) +(bonus[1109] ~= nil and bonus[1109] or 0)
    return army_num
end
]]

function MobaArmyNumUpLimit()

    AttributeBonus.CollectBonusInfo(nil,false,{"MobaBuffData","MobaTechData", "MobaBattleMove"})
    local bonus = AttributeBonus.GetBonusInfos()  
    local base = GTableMgr:GetMobaUnitInfoByID(11)
    local army_num = tonumber( base.Value) +(bonus[1112] ~= nil and bonus[1112] or 0)
    return army_num
end

function MobaArmyNum4MassPlayer()
    --科技 ，角色
    AttributeBonus.CollectBonusInfo(nil,false,{"MobaBuffData","MobaTechData", "MobaBattleMove"})
    local bonus = AttributeBonus.GetBonusInfos()  
    local base = GTableMgr:GetMobaUnitInfoByID(8)
    local army_num = tonumber( base.Value) +(bonus[1109] ~= nil and bonus[1109] or 0)
    return army_num
end

function MobaArmyNum4MassBuild()
    --科技 ，角色
    AttributeBonus.CollectBonusInfo(nil,false,{"MobaBuffData","MobaTechData", "MobaBattleMove"})
    local bonus = AttributeBonus.GetBonusInfos()  
    local base = GTableMgr:GetMobaUnitInfoByID(8)
    local army_num = tonumber( base.Value) +(bonus[1109] ~= nil and bonus[1109] or 0)
    return army_num
end

function MobaArmyMovePlayer()
    --科技 ，角色
    AttributeBonus.CollectBonusInfo(nil,false,{"MobaBuffData","MobaTechData", "MobaBattleMove"})
    local bonus = AttributeBonus.GetBonusInfos()  
    local base = GTableMgr:GetMobaUnitInfoByID(7)
    local army_num = tonumber( base.Value) +(bonus[1063] ~= nil and bonus[1063] or 0)
    return army_num
end

function GetResWeight(resType)
	for v in string.gsplit(GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ResWeightCfg).value, ";") do
		local args = string.split(v, ":")
		if tonumber(args[1]) == resType then 
			return tonumber(args[2])
		end 
	end
	return 1
end

local LoginAreaMsg
local TargetVersion ={1.05,11.05}

function SetLoginAreaMsg(area_msg)
    LoginAreaMsg = area_msg
end

function ForceUpdateVersion(main_text)
    if LoginAreaMsg == nil then
        return false
    end
    local target_version = 0
    
    local platformType = GGUIMgr:GetPlatformType()
    if platformType == LoginMsg_pb.AccType_adr_efun or platformType == LoginMsg_pb.AccType_ios_efun then
        target_version = TargetVersion[1]
    else
        target_version = TargetVersion[2]
    end
    print(target_version,GameVersion.EXE)
    if target_version ~=  tonumber(GameVersion.EXE) then
        return false
    end
    MessageBox.Show(GTextMgr:GetText(main_text),function()
        UpdateVersion.Show(LoginAreaMsg.updateText, LoginAreaMsg.exeUpdateUrl, LoginAreaMsg.isExeUpdate)
    end,function() end,
    GTextMgr:GetText("ui_update_hint2"),GTextMgr:GetText("ui_update_hint3"))
    return true
end

function GetMinMassSceneEnergyValue()
    local str = GTableMgr:GetGlobalData(100261).value;
    
    local str_vs =  string.split(str,";")
    local min = 0;
    for i, v in ipairs(str_vs) do
        local vs =  string.split(v,":")
        if min == 0 then
            min = tonumber(vs[2]) 
        elseif tonumber(vs[2]) < min then
            min = tonumber(vs[2]) 
        end
    end
    return min
end

local GuildMobaSafeAreaInfo = nil

function IsInSafeAreaOfGuildMoba(x,y)
    if GetMobaMode() ~= 2 then
        return false
    end
    local offset_x,offset_y = MobaMain.MobaMinPos() 
    x = x - offset_x
    y = y - offset_y
    if GuildMobaSafeAreaInfo == nil then
        if(GTableMgr:GetGuildMobaGlobal(12) == nil or GTableMgr:GetGuildMobaGlobal(13) == nil ) then
            return false
        end
        GuildMobaSafeAreaInfo = {}
        GuildMobaSafeAreaInfo.area1={}
        GuildMobaSafeAreaInfo.area1.min={}
        GuildMobaSafeAreaInfo.area1.max={}
        GuildMobaSafeAreaInfo.area2={}
        GuildMobaSafeAreaInfo.area2.min={}
        GuildMobaSafeAreaInfo.area2.max={} 
        local area1 = GTableMgr:GetGuildMobaGlobal(12).Value
        local area2 = GTableMgr:GetGuildMobaGlobal(13).Value
        local str_vs =  string.split(area1,";")
        local str_vs2 = string.split(str_vs[1],":")
        GuildMobaSafeAreaInfo.area1.min.x = tonumber(str_vs2[1])
        GuildMobaSafeAreaInfo.area1.min.y = tonumber(str_vs2[2])

        str_vs2 = string.split(str_vs[2],":")
        GuildMobaSafeAreaInfo.area1.max.x = tonumber(str_vs2[1])
        GuildMobaSafeAreaInfo.area1.max.y = tonumber(str_vs2[2]) 

        str_vs =  string.split(area2,";")
        str_vs2 = string.split(str_vs[1],":")
        GuildMobaSafeAreaInfo.area2.min.x = tonumber(str_vs2[1])
        GuildMobaSafeAreaInfo.area2.min.y = tonumber(str_vs2[2]) 

        str_vs2 = string.split(str_vs[2],":")
        GuildMobaSafeAreaInfo.area2.max.x = tonumber(str_vs2[1])
        GuildMobaSafeAreaInfo.area2.max.y = tonumber(str_vs2[2])  
    end
    if (x >= GuildMobaSafeAreaInfo.area1.min.x and x <= GuildMobaSafeAreaInfo.area1.max.x and
     y >= GuildMobaSafeAreaInfo.area1.min.y and y <= GuildMobaSafeAreaInfo.area1.max.y ) or 
     (x >= GuildMobaSafeAreaInfo.area2.min.x and x <= GuildMobaSafeAreaInfo.area2.max.x and
     y >= GuildMobaSafeAreaInfo.area2.min.y and y <= GuildMobaSafeAreaInfo.area2.max.y ) 
     then
        return true;
     end
     return false;
end

local guild_moba_cal_buff_id = {[97]=true, [96]=true, [95]=true, [94]=true, [93]=true, [92]=true,
 [91]=true, [90]=true, [89]=true, [88]=true, [87]=true, [1701]=true, [1702]=true, [1703]=true, [1704]=true, [1705]=true,[1904]=true}

function CheckBuff(buff_id)
    if GetMobaMode() == 2 then
        return guild_moba_cal_buff_id[buff_id] ~= nil
    else
        return true
    end
    
end
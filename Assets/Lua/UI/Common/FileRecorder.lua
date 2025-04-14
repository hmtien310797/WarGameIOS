class "FileRecorder"
{	
}

function FileRecorder:__init__(charid , areaid , zoneid)
	self.saveNumSingleFile = 200
	self.charRecordsCfg = {}
	self.charRecordsBuff = {}
	self.lastPage = 0
	self.recFileSuffix = 5
	self.buffsize = 100 --最少读取数量。buff大小可能超过100
	self.fChar = '/'
	
	local device = Global.GGUIMgr:GetDeviceName()
	if device == "Android" then
		self.settingPath = Global.GGUIMgr:GetFileUserPath()
		self.makeDirCommond = "mkdir -p "
	elseif device == "Iphone" then
		self.settingPath = Global.GGUIMgr:GetFileUserPath()
	elseif device == "Stand Alone OSX" then
	
	else
		self.settingPath = Global.GGUIMgr:GetResourceUserPath()
		self.makeDirCommond = "mkdir -p "
		self.fChar = "\\"
	end
	
	--print("-----file recorder:init() user path:", self.settingPath)
	
	self.charId = charid
	self.areaId =areaid
	self.zoneId = zoneid
	self.areazone = areaid * 1000 + zoneid
	
	self.zoneRecPath = self.settingPath .. self.areazone .. self.fChar
	self.charRecPath = self.zoneRecPath .. self.charId .. self.fChar
	self.configName = self.charRecPath .. "config.txt"
end

function FileRecorder:GetConfigData()
	local file = io.open(self.configName , "r")
	if file ~= nil then
		for line in file:lines() do
			local cfgTable = cjson.decode(line)
			if cfgTable.lastTime == nil then
				cfgTable.lastTime = 0
			end
			if cfgTable.saveTime == nil then
				cfgTable.saveTime = 0
			end
			self.charRecordsCfg[cfgTable.name] = cfgTable
		end
	end
	io.close()
end


function FileRecorder:HaveUnSavedPlayerRecord(pName)
	local new = 0
	if self.charRecordsCfg[pName] == nil then
		return new
	end
	
	local saveTime = self.charRecordsCfg[pName].saveTime and self.charRecordsCfg[pName].saveTime or 0
	for i=1 , #(self.charRecordsBuff[pName].data) , 1 do
		local recData = self.charRecordsBuff[pName].data[i]
		--print("====" ,Serclimax.GameTime.SecondToStringYMDLocal(recData.time) , Serclimax.GameTime.SecondToStringYMDLocal(saveTime) ,recData.sender.charid, MainData.GetCharId())
		if recData.time > saveTime and recData.sender.charid ~= MainData.GetCharId() then
			new = new + 1
		end
	end
	return new
end

function FileRecorder:HaveUnSavedRecord()
	local unsave = 0
	for _ , v in pairs(self.charRecordsCfg) do
		unsave = unsave + self:HaveUnSavedPlayerRecord(v.name)
	end
	return unsave
end

function FileRecorder:GetSortedConfigData()
	local sorted_table = {}
	for _ , v in pairs(self.charRecordsCfg) do
		if v ~= nil then
			table.insert(sorted_table , v)
		end
	end
	
	table.sort(sorted_table , function (v1,v2)
		return v1.lastTime > v2.lastTime
	end)
	
	return sorted_table
end

function FileRecorder:GetNewestRecords(recbuff , num)
	local get = 0
	if recbuff == nil then
		return get
	end
	local sortedCfg = Global.GFileRecorder:GetSortedConfigData()
	for i=1 , #sortedCfg , 1 do
		if (i+1) <= #sortedCfg then
			get = get + self:GetRecords(recbuff , sortedCfg[i].name , sortedCfg[i+1].lastTime)
		else
			get = get + self:GetRecords(recbuff , sortedCfg[i].name , 0)
		end
		if get >= num then
			break
		end
	end
	return get
end

function FileRecorder:GetRecords(recbuff ,cfgName , lastTime)
	local getNum = 0
	if recbuff == nil then
		return getNum
	end
	if self.charRecordsBuff[cfgName] ~= nil and self.charRecordsBuff[cfgName].data ~= nil then
		for i=1 , #self.charRecordsBuff[cfgName].data , 1 do
			if self.charRecordsBuff[cfgName].data[i].time >= lastTime or lastTime == 0 then
				local v = self.charRecordsBuff[cfgName].data[i]
				table.insert(recbuff , v)
				getNum = getNum + 1
			else
				break
			end
		end
	end
	return getNum
end

function FileRecorder:GetRecordFromBuff(recbuff , recName , num , update)
	print("========= GetRecordFromBuff:========" )
	local getNum = 0
	if recbuff == nil then
		return getNum
	end
	--self.charRecordsBuff[recName]
	if self.charRecordsCfg[recName] ~= nil then
		if not update then
			self.charRecordsBuff[recName].getRecord = 0
		end
		--print(recName)
		local recTotal = self.charRecordsCfg[recName].totalnum
		local buffSize = #(self.charRecordsBuff[recName].data)
		local size = buffSize
		
		if self.charRecordsBuff[recName].getRecord + num >= buffSize and buffSize < recTotal then
			local getNameTable = {}
			getNameTable[recName] = {lastPage = self.charRecordsCfg[recName].lastPage}
			self:GetRecordToBuff(getNameTable)
		end

		buffSize = #(self.charRecordsBuff[recName].data)
		if self.charRecordsBuff[recName].getRecord < buffSize then
			local recordindex = self.charRecordsBuff[recName].getRecord
			local index =  math.min(buffSize ,recordindex + num)
			local endindex = recordindex
			for i=index , endindex, -1 do
				local v = self.charRecordsBuff[recName].data[i]
				if type(v) == "table" then
					table.insert(recbuff , v)
					getNum = getNum + 1
				end
			end
			self.charRecordsBuff[recName].getRecord = index + 1
			--print("GetRecordFromBuff()" , "name:"..recName , "index:"..index , "end:"..endindex , "record:" .. self.charRecordsBuff[recName].getRecord , "buffsize:" ..buffSize , "|" .. size )
		end
	end
	return getNum
end

function FileRecorder:GetRecordToBuff(getRecList)
	--print("========= GetRecordToBuff:========" )
	local recordlist = getRecList and getRecList or self.charRecordsCfg
	for k , v in pairs(recordlist) do
		if self.charRecordsBuff[k] == nil then
			self.charRecordsBuff[k] = {}
			self.charRecordsBuff[k].data = {}
			self.charRecordsBuff[k].getRecord = 0
		end
		
		--local base64Key = Global.GGUIMgr:String2Base(k)
		local base64Key = Global.GGUIMgr:MD5_Encrypt(k)
		local start = self.charRecordsBuff[k].lastTravPage ~= nil and self.charRecordsBuff[k].lastTravPage or v.lastPage
		local travcount = self.charRecordsBuff[k].travCount ~= nil and self.charRecordsBuff[k].travCount or 0
		local index = start
		local readCount = 0
		while(index >= 0) do
			if travcount >= 5 then
				break
			end
			--print("-----file recorder:GetRecordToBuff() record file:", self.charRecPath .. string.format("%s%s_%d" , base64Key..self.fChar , base64Key , index ))
			local file = io.open(self.charRecPath .. string.format("%s%s_%d" , base64Key..self.fChar , base64Key , index ) , "r")
			if file ~= nil then
				
				--倒序读取
				local list = nil 
				for line in file:lines() do
					list = {next = list , value = line}
					readCount = readCount + 1
				end
				file:close()
				
				local l = list
				while l do
					table.insert(self.charRecordsBuff[k].data , cjson.decode(l.value))
					l = l.next
				end
				--[[正序读取
				for line in file:lines() do
					table.insert(self.charRecordsBuff[k] , cjson.decode(line))
					readCount = readCount + 1
				end
				file:close()]]
			end
			
			if index == 0 then
				index = self.recFileSuffix
			end
			
			index = index - 1
			travcount = travcount + 1
			if travcount >= self.recFileSuffix or readCount >= self.buffsize then
				self.charRecordsBuff[k].travCount = travcount
				self.charRecordsBuff[k].lastTravPage = index
				break
			end
		end
		
		--print("GetRecordToBuff()" , "name:"..k , "buffsize:"..#(self.charRecordsBuff[k].data) , "record:" .. self.charRecordsBuff[k].getRecord)
	end
end

function FileRecorder:GetContentFromMsg(msg)
	local content = {}
	content.clientlangcode = msg.clientlangcode
	content.time = msg.time
	content.senderguildname = msg.senderguildname
	content.verify = msg.verify
	content.gm = msg.gm
	content.type = msg.type
	content.spectext = msg.spectext
	content.infotext = msg.infotext
	content.chanel = msg.chanel
	return content
end

function FileRecorder:GetSenderFromMsg(msg , sender)
	sender = {}
	Global.msg2Table(msg.sender , sender)
end

function FileRecorder:MakeDir(dirName) 
	--os.execute(self.makeDirCommond .. self.charRecPath .. dirName)
	--print("-----file recorder:SaveRecordData() make dir:", self.charRecPath .. dirName , dirName)
	Global.CreateDirectory(self.charRecPath .. dirName , dirName)
end

function FileRecorder:UpdateBuff(recordDatas)
	--print("===========UpdateBuff==========")
	for k , v in pairs(recordDatas) do
		local sKey = string.split(k , ",")
		local sName = sKey[1]
		local sCharId = tonumber(sKey[2])
		
		if self.charRecordsBuff[sName] == nil then
			self.charRecordsBuff[sName] = {}
			self.charRecordsBuff[sName].data = {}
			self.charRecordsBuff[sName].getRecord = 0
		end
		
		local upbuff = {}
		for i=#(v) , 1 , -1 do
			table.insert(upbuff , v[i])
		end
		for i=1 , #(self.charRecordsBuff[sName].data) , 1 do
			table.insert(upbuff , self.charRecordsBuff[sName].data[i])
		end
		self.charRecordsBuff[sName].data = upbuff
		self.charRecordsBuff[sName].getRecord = self.charRecordsBuff[sName].getRecord + #(v)
		
		--print("UpdateBuff()" , "name:" .. sName , "msgSize:"..#(v) , "buffsize:" .. #(upbuff) , "record:" .. self.charRecordsBuff[sName].getRecord)
	end
end

function FileRecorder:SaveRecordWithTime(recordDatas)
	
end

function FileRecorder:SaveRecordData(recordDatas, saveCfgTime)
	
	local saveConfig = false--isSaveConfig and isSaveConfig or false
	self:UpdateBuff(recordDatas)
	
	for k , v in pairs(recordDatas) do
		if v ~= nil and #(v) > 0 then
			saveConfig = true
			local sKey = string.split(k , ",")
			local sName = sKey[1]
			local sCharId = tonumber(sKey[2])
			local senderConfig = nil
			if v[1].sender.charid == sCharId then
				senderConfig = v[1].sender
			else
				for i=1 , #(v[1].recvlist) , 1 do
					if v[1].recvlist[i].charid == sCharId then
						senderConfig = v[1].recvlist[i]
					end
				end
			end
			
			--update config table
			--local base64Key = Global.GGUIMgr:String2Base(sName)
			local base64Key = Global.GGUIMgr:MD5_Encrypt(sName)
			if self.charRecordsCfg[sName] == nil then
				self.charRecordsCfg[sName] = {}
				Global.msg2Table(senderConfig , self.charRecordsCfg[sName])
				self.charRecordsCfg[sName].totalnum = 0
				self:MakeDir(tostring(base64Key))
			end
			
			--update buff table
			--[[self.charRecordsBuff[sName] = {}
			self.charRecordsBuff[sName].data = {}
			self.charRecordsBuff[sName].getRecord = 0]]
		
			--save record
			local lastPage = math.floor(self.charRecordsCfg[sName].totalnum / self.saveNumSingleFile) % self.recFileSuffix
			self.charRecordsCfg[sName].totalnum = self.charRecordsCfg[sName].totalnum + #(v)
			self.charRecordsCfg[sName].lastPage = lastPage
			self.charRecordsCfg[sName].lastTime = 0
			if self.charRecordsBuff[sName].data ~= nil and #(self.charRecordsBuff[sName].data) > 0 then
				self.charRecordsCfg[sName].lastTime = self.charRecordsBuff[sName].data[1].time
			end
			
			
			local file = io.open(self.charRecPath .. string.format("%s%s_%d" , base64Key..self.fChar , base64Key , lastPage) , "a")
			--print("-----file recorder:SaveRecordData() save file:", self.charRecPath .. string.format("%s%s_%d" , base64Key..self.fChar , base64Key , lastPage))
			
			if file ~= nil then
				for k, vv in pairs(v) do
					local data = {}
					Global.msg2Table(vv , data)
					--table.insert(self.charRecordsBuff[sName].data , data)
					
					local jsStr = cjson.encode(data)
					file:write(jsStr .. "\n")
				end
				file:close()
			end
		end
	end
	
	if saveCfgTime then
		for k , v in pairs(recordDatas) do
			local sKey = string.split(k , ",")
			local sName = sKey[1]
			local sCharId = tonumber(sKey[2])
			self.charRecordsCfg[sName].saveTime = Serclimax.GameTime.GetMilSecTime()
			--print("++++++++" , Serclimax.GameTime.SecondToStringYMDLocal(self.charRecordsCfg[sName].saveTime))
		end
	end
	
	--save config file 
	--print("===========SaveRecordData==========" , saveConfig,saveCfgTime)
	if saveConfig or saveCfgTime then
		local cfgFile = io.open(self.configName , "w")
		if cfgFile ~= nil then
			for _, v in pairs(self.charRecordsCfg) do
				local cfgJsStr = cjson.encode(v)
				cfgFile:write(cfgJsStr .. "\n")
			end
			cfgFile:close()
		end
		
	end
end

function FileRecorder:DeleteRecord(charname, charid)
	--delete buff
	local saveConfig = false
	if self.charRecordsBuff[charname] ~= nil then
		self.charRecordsBuff[charname] = nil
		saveConfig = true
	end
	--delete config
	if self.charRecordsCfg[charname] ~= nil then
		self.charRecordsCfg[charname] = nil
		saveConfig = true
	end
	
	if saveConfig then
		local cfgFile = io.open(self.configName , "w")
		for _, v in pairs(self.charRecordsCfg) do
			if v == nil then
				local cfgJsStr = ""
				cfgFile:write(cfgJsStr .. "\n")
			else
				local cfgJsStr = cjson.encode(v)
				cfgFile:write(cfgJsStr .. "\n")
			end
		end
		cfgFile:close()
	end
	--delete file
	--local name64 = Global.GGUIMgr:String2Base(charname)
	local name64 = Global.GGUIMgr:MD5_Encrypt(charname)
	
	local recPath = self.charRecPath .. name64
	--print("-----file recorder:DeleteRecord() del file:", self.charRecPath .. name64)
	Global.GGUIMgr:DeleteDirectory(recPath)
end
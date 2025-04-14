module("MainData", package.seeall)
local TableMgr = Global.GTableMgr
local GameTime = Serclimax.GameTime
local Format = System.String.Format
local TextMgr = Global.GTextMgr

local eventListener = EventListener()
local WorldMapMaxSceneEnergy

local mainData
local savedMainData = {}
local energyTime
local energyInterval
local sceneEnergyTime
local sceneEnergyInterval
local charId
local characterName
local gm
local saveLevel
local saveEnergy
local loginCount
local hasRecharged
local goodInfo
local rewardInfo
local displayPrice
local hasTakeRecharged
local recommendGoodInfo
local creationTime
local serverStartTime
local lastShareTime
local commanderInfo
local starReward

local function NotifyListener()
    eventListener:NotifyListener()
end

function GetCreationTime()
	return creationTime
end

function GetServerStartTime()
	return serverStartTime
end

function GetSavedData()
	return savedMainData
end

function GetSavedExp()
	return savedMainData.exp
end

function GetSavedLevel()
    return savedMainData.level
end

function GetSavedEnergy()
	return savedMainData.energy
end


function GetSavedScenEnergy()
	return savedMainData.sceneEnergy
end

function GetLastShareTime()
    return lastShareTime
end

function HasWeeklyShare()
    local baseLevel = BuildingData.GetCommandCenterData().level
    if baseLevel < tonumber(tableData_tGlobal.data[100146].value) then
        return false
    end

    local serverTime = GameTime.GetSecTime()
    if serverTime - lastShareTime < 3600 * 24 * 7 then
        return false
    end

    return true
end

function SetNationality(nationality)
    if tableData_tNationalityDefine.data[nationality] == nil then
        nationality = 0
    end
	mainData.nationality = nationality

	NotifyListener()
end

function SetCommanderLevel(lv)
	mainData.commanderLeadLevel = lv
end

function GetNationality()
    if tableData_tNationalityDefine.data[mainData.nationality] == nil then
        return 0
    end
	return mainData.nationality
end

function SaveMainData()
	if mainData == nil then
		return 
	end
	savedMainData.level = mainData.level
	savedMainData.energy = mainData.energy
	savedMainData.exp = mainData.exp
	savedMainData.sceneEnergy = mainData.sceneEnergy
end

function HadRecharged()
	return not hasRecharged
end

function SetRecharged()
	local laststate = hasRecharged
	hasRecharged = true
	if laststate ~= hasRecharged then
		FunctionListData.IsFunctionUnlocked(108, function(isactive)
			if isactive then
				FirstPurchase.Show()
			end
		end)
	end
	NotifyListener()
end

function CanTakeRecharged()
	return not hasTakeRecharged
end

function SetTakedRecharged()
	hasTakeRecharged = true
	NotifyListener()
end

function GetGoodInfo()
	return goodInfo
end

function GetRecommendGoodInfo()
	return recommendGoodInfo
end

function GetRewardInfo()
	return rewardInfo
end

function GetDisplayPrice()
	return displayPrice
end

function GetCommanderInfo()
    return commanderInfo
end

function HasPendingRansom()
    return commanderInfo.captived == 1 and #commanderInfo.ransom > 0 and not commanderInfo.ransomRefuse
end

function SetCommanderInfo(info)
    commanderInfo = info
end

function IsCommanderCaptured()
    return commanderInfo.captived ~= 0
end

function GetStarReward()
    return starReward
end

function SetStarReward(reward)
    starReward = reward
end

function GetSandReward(sandId)
    for _, v in ipairs(starReward.data) do
        if v.id == sandId then
            return v
        end
    end
end

function GetData()
    return mainData
end

function SetData(data)
	savedMainData = {}
    mainData = data
	SaveMainData()
	--NotifyListener()
end

function RequestData()
	local req = ClientMsg_pb.MsgClientMainDataRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgClientMainDataRequest, req, ClientMsg_pb.MsgClientMainDataResponse, function(msg)
        GameTime.SetServerTime(msg.gametime)
        GameTime.SetServerDayStartTime(msg.gametime)
        charId = msg.charid
        characterName = msg.charname
        gm = msg.gm
        commanderInfo = msg.commanderInfo
        SetData(msg.data)
        ChapterListData.SetData(msg.chapter)
		MoneyListData.SetData(msg.money.money)
        goodInfo = msg.firstRechargeInfo.goodInfo
        hasRecharged = msg.firstRechargeInfo.hasRecharged
		rewardInfo = msg.firstRechargeInfo.rewardInfo
		hasTakeRecharged = msg.firstRechargeInfo.hasTake
		displayPrice = msg.firstRechargeInfo.displayPrice
		recommendGoodInfo = msg.firstRechargeInfo.recommendGoodInfo
        creationTime = msg.charCreateTime
        serverStartTime = msg.serverStartTime
        lastShareTime = msg.lastShareTime
        starReward = msg.starReward
        NotifyListener()
    end, true)
end

function RequestChangeNationality(nationality, callback)
	local req = ClientMsg_pb.MsgCharacterChangeNationalityRequest()
	req.nationality = nationality
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCharacterChangeNationalityRequest, req, ClientMsg_pb.MsgCharacterChangeNationalityResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
        	ConfigData.SetHasSetNationality(true)
        	SetNationality(msg.nationality)

        	if callback then
        		callback()
        	end
        end
    end, true)
end

function RequestCommanderInfo()
    local req = BuildMsg_pb.MsgPrisonGetCommanderRequest()
    Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgPrisonGetCommanderRequest, req, BuildMsg_pb.MsgPrisonGetCommanderResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetCommanderInfo(msg.commanderInfo)
            NotifyListener()            
        else
            Global.ShowError(msg.code)
        end
    end, true)
end


function GetCharId()
    return charId
end

function SetCharName(charname)
    characterName = charname
end

function GetCharName()
    return characterName
end

function IsGM()
    return gm
end

local function MergeData(data)
	if data.level == 0 then
		return
	end
	mainData.level = data.level
	mainData.face = data.face
	mainData.exp = data.exp
	mainData.energy = data.energy
	mainData.sceneEnergy = data.sceneEnergy
	mainData.pkvalue = data.pkvalue
	mainData.vip:MergeFrom(data.vip)
	mainData.buildpkvalue = data.buildpkvalue
	mainData.techpkvalue = data.techpkvalue
	mainData.armypkvalue = data.armypkvalue
	mainData.heropkvalue = data.heropkvalue
	mainData.lastpkvalue = data.lastpkvalue
	mainData.curpkvalue = data.curpkvalue
	mainData.commanderpkvalue = data.commanderpkvalue
	mainData.armybordpkvalue = data.armybordpkvalue
	mainData.officialId = data.officialId
	mainData.privilege = data.privilege
	mainData.nationality = data.nationality
	mainData.guildOfficialId = data.guildOfficialId
	mainData.commanderLeadLevel = data.commanderLeadLevel
	mainData.militaryRankId = data.militaryRankId
	mainData.militaryRankLevelUpFailCnt = data.militaryRankLevelUpFailCnt
	mainData.skin.select = data.skin.select
	mainData.rentBuildQueueExpire = data.rentBuildQueueExpire
	mainData.dayWorldMonster = data.dayWorldMonster
	while #mainData.skin.skins > 0 do
        mainData.skin.skins:remove()
    end
    for _, v in ipairs(data.skin.skins) do
        local skin = mainData.skin.skins:add()
        skin:MergeFrom(v)
    end

	for i, v in ipairs(data.armybordpkValuebyid) do
		local isnew = true
		for ii, vv in ipairs(mainData.armybordpkValuebyid) do
			if v.armyid == vv.armyid then
				isnew = false
				vv.pkvalue = v.pkvalue
			end
		end
		if isnew then
			local pk = mainData.armybordpkValuebyid:add()
			pk.armyid = v.armyid
			pk.pkvalue = v.pkvalue
		end
	end
end

function UpdateData(data)
	if mainData == nil then
		return
	end
	if data == nil or next(data) == nil --[[or #(data) == 0]] then
		return
	end
	SaveMainData()
	--[[if data.sceneEnergy ~= mainData.sceneEnergy then
	    RequestEnergy(2)
    end
    if data.energy ~= mainData.energy then
	   RequestEnergy(1)
	end]]
    MergeData(data)
    NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

--获取玩家当前等级
function GetLevel()
    return mainData.level
end

function GetFight()
	return mainData.pkvalue
end

--获取体力
function GetEnergy()
    return mainData.energy
end

function GetSceneEnergy()
    return mainData.sceneEnergy
end

--获取体力上限
function GetMaxEnergy()
  local expData = TableMgr:GetPlayerExpData(mainData.level)
  return expData.energyMax
end

function GetMaxSceneEnergy()
    if WorldMapMaxSceneEnergy == nil then
        WorldMapMaxSceneEnergy = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.WorldMapMaxSceneEnergy).value)
    end

    return WorldMapMaxSceneEnergy
end

--获取VIP等级
function GetVipLevel()
	if mainData.vip.viptimeTaste > Serclimax.GameTime.GetSecTime() then
		if mainData.vip.viplevel > mainData.vip.viplevelTaste then
			return mainData.vip.viplevel
		else
			return mainData.vip.viplevelTaste
		end
	else
		return mainData.vip.viplevel
	end
end

function IsInTast()
	return mainData.vip.viptimeTaste > Serclimax.GameTime.GetSecTime() 
end

--是否最大VIP等级
function IsMaxVipLevel()
    return mainData.vip.viplevel == mainData.vip.maxviplevel
end

function GetVipExp()
	return mainData.vip.vipexp
end

function GetVipNextExp()
	return mainData.vip.nextexp
end

--设置体力
function SetEnergy(energy , notify)
    mainData.energy = energy
	if notify then
		NotifyListener()
	end
end

function SetSceneEnergy(sceneEnergy , notify)
    mainData.sceneEnergy = sceneEnergy
	if notify then
		NotifyListener()
	end
end

--设置上次体力恢复时间
function SetEnergyTime(time)
    energyTime = time
end

function SetSceneEnergyTime(time)
    sceneEnergyTime = time
end

--获取上次体力恢复时间
function GetEnergyTime()
    return energyTime
end

function GetSceneEnergyTime()
    return sceneEnergyTime
end

function SetEnergyInterval(interval)
    energyInterval = interval
end

function SetSceneEnergyInterval(interval)
    sceneEnergyInterval = interval
end

function GetSceneEnergyInterval()
    return sceneEnergyInterval
end

function GetNextEnergyTime()
    return energyTime + energyInterval
end

function GetNextSceneEnergyTime()
    return sceneEnergyTime + sceneEnergyInterval
end

--获取剩余体力恢复时间
function GetLeftEnergyTime()
    return energyTime + energyInterval - GameTime.GetSecTime()
end

function GetLeftSceneEnergyTime()
    return sceneEnergyTime + sceneEnergyInterval - GameTime.GetSecTime()
end

function GetFace()
	return mainData.face
end

function SetFace(faceid)
	mainData.face = faceid
	NotifyListener()
end

function GetExp()
	return mainData.exp
end


function RequestEnergy(energyType)
    local req = ClientMsg_pb.MsgCharacterEnergyRequest()
    req.energyType = energyType
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCharacterEnergyRequest, req, ClientMsg_pb.MsgCharacterEnergyResponse, function (msg)
        if msg.energyType == 1 then
        SetEnergy(msg.energy)
        SetEnergyTime(msg.energytime)
        SetEnergyInterval(msg.interval)
        
    else
        SetSceneEnergy(msg.energy)
        SetSceneEnergyTime(msg.energytime)
        SetSceneEnergyInterval(msg.interval)
    end
    end, true)
end

function RequestLoginCount()
	local req = ClientMsg_pb.MsgUserDayLoginCountRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserDayLoginCountRequest, req, ClientMsg_pb.MsgUserDayLoginCountResponse, function(msg)
        loginCount = msg.count
    end, true)
end

function GetLoginCount()
    return loginCount
end

function IsFirstLogin()
    return loginCount == 1
end

function GetBuildPkValue()
	return mainData.buildpkvalue
end

function GetTechPkValue()
	return mainData.techpkvalue
end

function GetArmyPkValue()
	return mainData.armypkvalue + mainData.armybordpkvalue
end

function GetHeroPkValue()
	return mainData.heropkvalue
end

function GetMilitaryRankID()
	return mainData.militaryRankId
end

function GetMilitaryRankUpFail()
	return mainData.militaryRankLevelUpFailCnt
end

function SetMilitaryRankUpFail(id)
	mainData.militaryRankLevelUpFailCnt = id
end

function SetMilitaryRankID(id)
	mainData.militaryRankId = id
	NotifyListener()
end

function GetCommanderPKValue()
	return mainData.commanderpkvalue
end

function GetVipValue()
	return mainData.vip
end


function GetOfficialId()
	return mainData.officialId
end

function GetGOVPrivilege()
	return mainData.privilege
end

function GetArmybordpkvalue()
	return mainData.armybordpkvalue
end

function GetRentBuildQueueExpire()
	return mainData.rentBuildQueueExpire
end

function GetArmybordpkvalueById(soldierid)
	for i, v in ipairs(mainData.armybordpkValuebyid) do
		if v.armyid == soldierid then
			return v.pkvalue
		end
	end
end

function UpdatePkValue(data)
	mainData.buildpkvalue = data.buildpkvalue
	mainData.techpkvalue = data.techpkvalue
	mainData.armypkvalue = data.armypkvalue
	mainData.heropkvalue = data.heropkvalue
	mainData.curpkvalue = data.curpkvalue
	mainData.lastpkvalue = data.lastpkvalue
	mainData.commanderpkvalue = data.commanderpkvalue
	mainData.armybordpkvalue = data.armybordpkvalue
	for i, v in ipairs(data.armybordpkValuebyid) do
		local isnew = true
		for ii, vv in ipairs(mainData.armybordpkValuebyid) do
			if v.armyid == vv.armyid then
				isnew = false
				vv.pkvalue = v.pkvalue
			end
		end
		if isnew then
			local pk = mainData.armybordpkValuebyid:add()
			pk.armyid = v.armyid
			pk.pkvalue = v.pkvalue
		end
	end
	mainData.pkvalue = data.pkvalue
end	

local function UpdateLVEXP(data)
	if Global.GGUIMgr:FindMenu("InGameUI") ~= nil then
		return
	end
	SaveMainData()
	mainData.level = data.level
	mainData.exp = data.exp
end

function UpdateRentBuildQueueExpire(data)
	mainData.rentBuildQueueExpire = data.rentBuildQueueExpire
end

local function UpdateEnergy(data)
	SetSceneEnergy(data.sceneEnergy)
	SetEnergy(data.energy)
end

function UpdateGov(data)
	if mainData ~= nil then
		mainData.officialId = data.officialId
		mainData.privilege = data.privilege
		mainData.guildOfficialId = data.guildOfficialId
	end
end

function CheckPkValue(msg)
	if mainData == nil then
		return
	end
	-- print("cur:" .. msg.data.curpkvalue .. " last:" .. msg.data.lastpkvalue .. "  bpop:" .. tostring(msg.bpop))
	if msg.data.curpkvalue < msg.data.lastpkvalue and msg.bpop then
		PowerUp.Show(msg.data.curpkvalue , msg.data.lastpkvalue , Color.green)
	end
	UpdatePkValue(msg.data)
	UpdateLVEXP(msg.data)
	UpdateEnergy(msg.data)
	UpdateGov(msg.data)
	NotifyListener()
end

function UpdateVip(data)
	mainData.vip.viplevel = data.viplevel
	mainData.vip.vipexp = data.vipexp
	mainData.vip.nextexp = data.nextexp
	mainData.vip.maxviplevel = data.maxviplevel
	mainData.vip.viplevelTaste = data.viplevelTaste
	mainData.vip.viptimeTaste = data.viptimeTaste
	NotifyListener()
end

function UpdateDailyRob(value)
	mainData.dayRobRes = value
	NotifyListener()
end

function GetEnergyCooldownText()
	local nextTime
	local Energy = GetEnergy()
	local maxEnergy = GetMaxEnergy()
	if  Energy >= maxEnergy then
		nextTime = 0
	else
		nextTime = GetNextEnergyTime()
	end
	return Format(TextMgr:GetText(Text.ui_staminarecover), Global.GetLeftCooldownTextLong(nextTime)),
	Format(TextMgr:GetText(Text.ui_staminarecover2), Global.GetLeftCooldownTextLong(nextTime + (maxEnergy - Energy - 1) * energyInterval))
end

function GetSceneEnergyCooldownText()
        local nextTime
        local sceneEnergy = GetSceneEnergy()
        local maxSceneEnergy = GetMaxSceneEnergy()
        if  sceneEnergy >= maxSceneEnergy then
            nextTime = 0
        else
            nextTime = GetNextSceneEnergyTime()
        end
        return Format(TextMgr:GetText(Text.ui_movepoints1), Global.GetLeftCooldownTextLong(nextTime)),
        Format(TextMgr:GetText(Text.ui_movepoints2), Global.GetLeftCooldownTextLong(nextTime + (maxSceneEnergy - sceneEnergy - 1) * GetSceneEnergyInterval()))
end

function TakeFirstRechargeReward(callback)
	local req = ShopMsg_pb.MsgTakeFirstRechargeRewardRequest()
	Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgTakeFirstRechargeRewardRequest, req, ShopMsg_pb.MsgTakeFirstRechargeRewardResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			MainCityUI.UpdateRewardData(msg.fresh)
			Global.ShowReward(msg.reward)
			SetTakedRecharged()
			if callback ~= nil then
				callback()
			end
		else
			Global.FloatError(msg.code, Color.white)
		end
    end, true)
end

function RequestFirstRechargeInfo(callback)
	local req = ShopMsg_pb.MsgFirstRechargeInfoRequest()
	Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgFirstRechargeInfoRequest, req, ShopMsg_pb.MsgFirstRechargeInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			recommendGoodInfo = msg.firstRechargeInfo.recommendGoodInfo
			NotifyListener()
			if callback ~= nil then
				callback()
			end
		else
			Global.FloatError(msg.code, Color.white)
		end
    end, true)
end

function RequestIAPSingleGoodInfo(goodId ,callback)
	local req = ShopMsg_pb.MsgIAPSingleGoodInfoRequest()
	req.goodId = goodId
	Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPSingleGoodInfoRequest, req, ShopMsg_pb.MsgIAPSingleGoodInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			if callback ~= nil then
				GiftPackData.ExchangePrice(msg.goodInfo)
				callback(msg.goodInfo)
			end
		else
			Global.FloatError(msg.code, Color.white)
		end
    end, true)
end



function CalAttributeBonus()
	local bouns = {}
	local rankData = TableMgr:GetMilitaryRankTable()[mainData.militaryRankId or 0]
	if rankData ~= nil then
		local t = string.split(rankData.RankEffect,';')
		for i = 1,#(t) do
			local b = {}
			local eff = string.split(t[i] , ',')
			b.BonusType = tonumber(eff[1])
			b.Attype =  tonumber(eff[2])
			b.Value =  tonumber(eff[3])
			table.insert(bouns, b)  
		end
	end
    return bouns
end

function RegistAttributeModel()
    AttributeBonus.RegisterAttBonusModule(_M)
end

function UpdateEnergyPush(msg)
	if msg.energyType == 1 then
		SetEnergy(msg.energy)
		SetEnergyTime(msg.energytime)
		SetEnergyInterval(msg.interval)
	else
		SetSceneEnergy(msg.energy)
		SetSceneEnergyTime(msg.energytime)
		SetSceneEnergyInterval(msg.interval)
	end
end

function UpdateSelectSkin(select)
    mainData.skin.select = select
    NotifyListener()
end

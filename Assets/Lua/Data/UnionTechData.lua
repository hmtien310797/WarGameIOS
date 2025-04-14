module("UnionTechData", package.seeall)
local TextMgr = Global.GTextMgr
local unionTechData
local normalDonate
local superDonate
local eventListener = EventListener()

local KeyValueData
local normalDonateNotice

local isUpgrading = false
local function MakeKeyValueData()
	KeyValueData = {}
	isUpgrading = false
	for i, v in ipairs(unionTechData) do
		if v.techId ~= nil then
			KeyValueData[v.techId] = v
			if v.status ~= nil and v.status == 1 and v.completeTime ~= nil and v.completeTime > 0 then
				isUpgrading = true
				CountDown.Instance:Add("UnionTecCountDown" .. v.techId,v.completeTime,CountDown.CountDownCallBack(function(t)
					local leftTime = v.completeTime - Serclimax.GameTime.GetSecTime()
					if leftTime <= 0 then
						CountDown.Instance:Remove("UnionTecCountDown" .. v.techId)
						RequestData()
					end
				end))
			end
		end
	end
end

function IsUpgrading()
	return isUpgrading
end

local normalDonateEventListener = EventListener()
local function NotifyNormalDonateListener()
	normalDonateEventListener:NotifyListener()
end
function AddNormalDonateListener(listener)
    normalDonateEventListener:AddListener(listener)
end
function RemoveNormalDonateListener(listener)
    normalDonateEventListener:RemoveListener(listener)
end
local function NormalDonateCountdown()
	if normalDonate ~= nil then
		if normalDonate.cdEndTime > Serclimax.GameTime.GetSecTime() then
			CountDown.Instance:Add("NormalDonateCountdown",normalDonate.cdEndTime,CountDown.CountDownCallBack(function(t)
				local leftTime = normalDonate.cdEndTime - Serclimax.GameTime.GetSecTime()
				if leftTime <= 0 then
					CountDown.Instance:Remove("NormalDonateCountdown")
					normalDonateNotice = true
					NotifyNormalDonateListener()
				end
			end))
		else
			normalDonateNotice = true
		end
	else
		normalDonateNotice = true
	end
end

function SetNormalDonateNotice()
	normalDonateNotice = true
end

function GetNormalDonateNotice()
	return normalDonateNotice
end

function NormalDonateNoticeReset()
	normalDonateNotice = false
	NotifyNormalDonateListener()
end

function GetUnionTechById(id)
	if KeyValueData ~= nil and KeyValueData[id] ~= nil then
		return KeyValueData[id]
	end
	return {techId = id, level = 0, energy = 0, status = 0, completeTime = 0}
end

local function NotifyListener()
	MakeKeyValueData()
	UnionTec.MakeBaseTable()
	--AttributeBonus.CollectBonusInfo()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function GetData()
    return unionTechData
end

function GetRecommendedTechData()
    local techData
    local maxTime = 0
    for _, v in ipairs(unionTechData) do
        if v.donateTimeByLeader ~= 0 and v.donateTimeByLeader > maxTime then
            maxTime = v.donateTimeByLeader
            techData = v
        end
    end

    return techData
end

function GetNormalDonate()
	return normalDonate
end

function GetSuperDonate()
	return superDonate
end

function IsNormalInCD()
	if normalDonate == nil then
		return 0
	elseif normalDonate.cdEndTime - Serclimax.GameTime.GetSecTime() > normalDonate.cdLimit then
		return 1
	elseif normalDonate.cdEndTime > Serclimax.GameTime.GetSecTime() then
		return 2
	else
		return 0
	end
end

function SetData(data)
    unionTechData = data.techInfos
    normalDonate = data.normalDonate
	superDonate = data.superDonate
	if Global.IsTodayFirstLogin() and normalDonateNotice == nil then
		normalDonateNotice = IsNormalInCD() ~= 1
		NormalDonateCountdown()
	end
end

function RequestData()
    local req = GuildMsg_pb.MsgGuildTechListRequest()
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildTechListRequest, req, GuildMsg_pb.MsgGuildTechListResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetData(msg)
            NotifyListener()
        else
        	KeyValueData = {}
        end
    end, true)
end

local function UpdateData(msg)
	normalDonate = msg.normalDonate
	NormalDonateCountdown()
	superDonate = msg.superDonate
	for i, v in ipairs(unionTechData) do
		if v.techId == msg.techInfo.techId then
			v.level = msg.techInfo.level
			v.energy = msg.techInfo.energy
			v.status = msg.techInfo.status
			v.completeTime = msg.techInfo.completeTime
			v.donateTimeByLeader = msg.techInfo.donateTimeByLeader
			return
		end
	end
	table.insert(unionTechData, msg.techInfo)
end

function RequestDonateGuildTech(techId, donateType, callback) -- 1普通，2炒鸡
	local req = GuildMsg_pb.MsgDonateGuildTechRequest()
	req.techId = techId
	req.donateType = donateType
	Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgDonateGuildTechRequest, req, GuildMsg_pb.MsgDonateGuildTechResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
        	if msg.code == ReturnCode_pb.Code_Guild_Tech_DonateFail then
        		MessageBox.Show(System.String.Format(TextMgr:GetText("union_tec24"),normalDonate.resetCost), function()
	                ResetNormalDonateRequest()
	            end,
	            function()
	            end)
        	else
            	--Global.ShowError(msg.code)
            	if callback ~= nil then
	            	callback(false)
	            end
            end
        else
            UpdateData(msg)
            MainCityUI.UpdateRewardData(msg.fresh)
            if callback ~= nil then
            	callback(true)
            end
        end
        NotifyListener()
    end, true)
end

function RequestDonatePrizeInfo(callback)
	local req = GuildMsg_pb.MsgDonatePrizeInfoRequest()
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgDonatePrizeInfoRequest, req, GuildMsg_pb.MsgDonatePrizeInfoResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            if callback ~= nil then
            	callback(msg)
            end
        end
    end, true)
end

function RequestDonateRankList(rankType, callback) --1每日2每周3历史
	local req = GuildMsg_pb.MsgDonateRankListRequest()
	req.rankType = rankType
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgDonateRankListRequest, req, GuildMsg_pb.MsgDonateRankListResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            if callback ~= nil then
            	callback(msg, rankType)
            end
        end
    end, true)
end

function ResetNormalDonateRequest()
	local req = GuildMsg_pb.MsgResetNormalDonateRequest()
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgResetNormalDonateRequest, req, GuildMsg_pb.MsgResetNormalDonateResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			normalDonate = msg.normalDonate
			NormalDonateCountdown()
            MainCityUI.UpdateRewardData(msg.fresh)
            NotifyListener()
        end
    end, false)
end

local hasunion

function UpdateTech()
	if hasunion ~= UnionInfoData.HasUnion() then
		hasunion = UnionInfoData.HasUnion()
		RequestData()
	end
end

function RequestUpgradeGuildTech(techId)
	local req = GuildMsg_pb.MsgUpgradeGuildTechRequest()
	req.techId = techId
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgUpgradeGuildTechRequest, req, GuildMsg_pb.MsgUpgradeGuildTechResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			UpdateTech()
        end
    end, false)
end

function RequestCancelUpgradeGuildTech(techId)
	local req = GuildMsg_pb.MsgCancelUpgradeGuildTechRequest()
	req.techId = techId
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgCancelUpgradeGuildTechRequest, req, GuildMsg_pb.MsgCancelUpgradeGuildTechResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			UpdateTech()
        end
    end, false)
end
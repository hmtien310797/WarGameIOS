module("ActiveStaticsData", package.seeall)
local activeStaticsData
local eventListener = EventListener()
local TableMgr = Global.GTableMgr

local raceStatusPush
local curPersonalRaceState = 0
local curUnionRaceState = 0


ActiveStaticType =
{
	AST_NONE = 0 ,
	AST_PERSONAL = 1 ,
	AST_UNION = 2 , 
}
ActiveStaticState = 
{
	ASS_NONE = 0,
	ASS_PRESTART = 1 , 
	ASS_DURINGACTIVITY = 2,
}


function GetData()
    return activeStaticsData
end

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end


function SetData(data,notify)
    activeStaticsData = data
	if notify then
		NotifyListener()
	end
end

function GetRaceStatus()
	return raceStatusPush
end

function GetCurActiveActId(activeType)
	local curTime = Serclimax.GameTime.GetSecTime()
	for i=1 , #activeStaticsData.act,1 do
		local activeStaticsMsg = activeStaticsData.act[i]
		local activeData = TableMgr:GetActivityStaticsListData(activeStaticsMsg.actId)
		--print( activeStaticsMsg.startTime , activeStaticsMsg.endTime , curTime)
		if curTime < activeStaticsMsg.endTime and activeData.completeType == activeType then 
			return activeStaticsData.act[i].actId
		end
	end
	return 0
end

--个人竞赛
function GetCurActiveArmRacePartTime()
	local part = 0
	local curTime = Serclimax.GameTime.GetSecTime()
	
	for i=1 , #activeStaticsData.act,1 do
		local activeStaticsMsg = activeStaticsData.act[i]
		local activeData = TableMgr:GetActivityStaticsListData(activeStaticsMsg.actId)
		if activeData.completeType == ActiveStaticType.AST_PERSONAL then
			--print( activeStaticsMsg.startTime , activeStaticsMsg.endTime , curTime)
			if curTime < activeStaticsMsg.startTime then 
				part = activeStaticsMsg.startTime
				curPersonalRaceState = ActiveStaticState.ASS_PRESTART
			elseif curTime < activeStaticsMsg.endTime then

				if curPersonalRaceState == ActiveStaticState.ASS_PRESTART then
					part = activeStaticsMsg.endTime
					curPersonalRaceState = ActiveStaticState.ASS_DURINGACTIVITY
					--ArmRace.LoadUI()
					--ArmRaceinfo.LoadTopInfo()
					NotifyListener()
				else
					part = activeStaticsMsg.endTime
					curPersonalRaceState = ActiveStaticState.ASS_DURINGACTIVITY
				end
				
			else
				curPersonalRaceState = ActiveStaticState.ASS_NONE
			end

			if part > 0 then
				return part,curPersonalRaceState
			end
		
		end
	end
	
	return part , ActiveStaticState.ASS_NONE
end

--联盟竞赛
function GetCurActiveUnionArmRacePartTime()
	local part = 0
	local curTime = Serclimax.GameTime.GetSecTime()
	
	for i=1 , #activeStaticsData.act,1 do
		local activeStaticsMsg = activeStaticsData.act[i]
		local activeData = TableMgr:GetActivityStaticsListData(activeStaticsMsg.actId)
		if activeData ~= nil  and activeData.completeType == ActiveStaticType.AST_UNION then
			--print( activeStaticsMsg.startTime , activeStaticsMsg.endTime , curTime)
			if curTime < activeStaticsMsg.startTime then 
				part = activeStaticsMsg.startTime
				curUnionRaceState = ActiveStaticState.ASS_PRESTART
			elseif curTime < activeStaticsMsg.endTime then

				if curUnionRaceState == ActiveStaticState.ASS_PRESTART then
					part = activeStaticsMsg.endTime
					curUnionRaceState = ActiveStaticState.ASS_DURINGACTIVITY
					--ArmRace.LoadUI()
					--ArmRaceinfo.LoadTopInfo()
					NotifyListener()
				else
					part = activeStaticsMsg.endTime
					curUnionRaceState = ActiveStaticState.ASS_DURINGACTIVITY
				end
				
			else
				curUnionRaceState = ActiveStaticState.ASS_NONE
			end

			if part > 0 then
				return part,curUnionRaceState
			end
		
		end
	end
	
	return part , ActiveStaticState.ASS_NONE
end

function RequestActiveStaticsInfo(cb , notify)
	local req = ClientMsg_pb.MsgGetRaceActListRequest();
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetRaceActListRequest, req, ClientMsg_pb.MsgGetRaceActListResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
           SetData(msg , notify)
            if cb ~= nil then
                cb()
            end
        end
    end, true)
end

function RequActiveStaticsDetailInfo(id , cb)
	local req = ClientMsg_pb.MsgGetRaceInfoRequest();
	req.actId:append(id)
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetRaceInfoRequest, req, ClientMsg_pb.MsgGetRaceInfoResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            if cb ~= nil then
                cb(msg)
            end
        end
    end, true) 
end

function RequActiveStaticsRankHistory(comType , cb)
	local req = ClientMsg_pb.MsgGetRaceRankInfoRequest();
	req.racetype = comType
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetRaceRankInfoRequest, req, ClientMsg_pb.MsgGetRaceRankInfoResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            if cb ~= nil then
                cb(msg)
            end
        end
    end)
end


function SetRaceStatus(msg)
	raceStatusPush = msg
	if msg.redNoticeType == 1 then
		print("activestatics push")
		RequestActiveStaticsInfo(nil , true)
		--MainCityUI.UpdateStaticRaceRed(true)
	end
end

function UpdateArmRace(comType)
	local part = 0 
	local state = 0 
	if comType == ActiveStaticType.AST_PERSONAL then
		part , state = GetCurActiveArmRacePartTime()
	elseif comType == ActiveStaticType.AST_UNION then
		part , state = GetCurActiveUnionArmRacePartTime()
	end
	
	local curTime = Serclimax.GameTime.GetSecTime()
	local leftTimeSec = part - curTime
	local countDown = ""
	
	if leftTimeSec > 0 then
		countDown = Global.GetLeftCooldownTextLong(part)
	else
		if state == ActiveStaticState.ASS_PRESTART then
			--RequestActiveStaticsInfo(nil , true)
		end
		countDown = ""
	end
	
	return countDown
end

function RequestUnionContributeRankHistory(total , cb)
	local req = ClientMsg_pb.MsgGetRaceGuildRankInfoRequest();
	req.total = total
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetRaceGuildRankInfoRequest, req, ClientMsg_pb.MsgGetRaceGuildRankInfoResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            if cb ~= nil then
                cb(msg)
            end
        end
    end) 
end

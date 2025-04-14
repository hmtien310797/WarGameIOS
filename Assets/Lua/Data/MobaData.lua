module("MobaData", package.seeall)
local TextMgr = Global.GTextMgr
local eventListener = EventListener()

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

local mobaMatchInfo

function GetMobaMatchInfo()
    return mobaMatchInfo
end

local function UpdateMatchInfo(status)
    mobaMatchInfo.userstatus = status
end

function RequestMobaMatchInfo()
    local req = MobaMsg_pb.MsgMobaMatchInfoRequest()
    Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaMatchInfoRequest, req, MobaMsg_pb.MsgMobaMatchInfoResponse, function(msg)
        mobaMatchInfo = msg
        NotifyListener()
    end, true)
end

function RequestMobaBook()
    local req = MobaMsg_pb.MsgMobaBookRequest()
    Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaBookRequest, req, MobaMsg_pb.MsgMobaBookResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            UpdateMatchInfo(1)
            FloatText.Show(TextMgr:GetText("ui_moba_149"), Color.white)
            NotifyListener()
        else
        	Global.ShowError(msg.code)
        end
    end, true)
end

function RequestMobaApply()
    local req = MobaMsg_pb.MsgMobaApplyRequest()
    Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaApplyRequest, req, MobaMsg_pb.MsgMobaApplyResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            UpdateMatchInfo(2)
            FloatText.Show(TextMgr:GetText("ui_moba_150"), Color.white)
            NotifyListener()
        else
        	Global.ShowError(msg.code)
        end
    end, true)
end

local mobaEnterInfo

function GetMobaEnterInfo()
    return mobaEnterInfo
end

function RequestMobaEnter(callback)
    print(debug.traceback())
    local req = MobaMsg_pb.MsgMobaEnterRequest()
    Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaEnterRequest, req, MobaMsg_pb.MsgMobaEnterResponse, function(msg)
        Global.DumpMessage(msg, "d:/ddddd.lua")
        if msg.code == ReturnCode_pb.Code_OK then
            mobaEnterInfo = msg.info
            UpdateMatchInfo(3)
            if callback ~= nil then
                callback()
            end
            NotifyListener()
        else
        	Global.ShowError(msg.code)
        end
    end, true)
end

function RequestMobaGetReward(level, callback)
    local req = MobaMsg_pb.MsgMobaGetRewardRequest()
    req.level = level
    Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaGetRewardRequest, req, MobaMsg_pb.MsgMobaGetRewardResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            MainCityUI.UpdateRewardData(msg.fresh)
            Global.ShowReward(msg.reward)
            mobaMatchInfo.info.reward.rewards:append(level)
            if callback ~= nil then
                callback()
            end
        else
        	Global.ShowError(msg.code)
        end
    end, true)
end

function RequestMobaHideRecord(hide, errorcallback)
    local req = MobaMsg_pb.MsgMobaHideRecordRequest()
    req.hide = hide
    Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaHideRecordRequest, req, MobaMsg_pb.MsgMobaHideRecordResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            mobaMatchInfo.info.hiderecord = hide
        else
            if errorcallback ~= nil then
                errorcallback()
            end
        	Global.ShowError(msg.code)
        end
    end, true)
end

local RoleInfo

function GetRoleID()
    if RoleInfo == nil then
        return 0
    end
    return RoleInfo.id
end

function UpdateRole(msg)
    if msg == nil then
        return
    end
    local charid = MainData.GetCharId()
    for i, v in ipairs(msg.info.users) do
        if v.roleid ~= nil and v.roleid > 0 then
            if v.charId == charid then
                RoleInfo = tableData_tMobaRole.data[v.roleid]
            end
        end
    end   
end

function RequestMobaRoleInfo(callback)
    local req = MobaMsg_pb.MsgMobaGetRoleListRequest()
    Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaGetRoleListRequest, req, MobaMsg_pb.MsgMobaGetRoleListResponse, function(msg)
        Global.DumpMessage(msg,"d:/ddddd.lua")
        if msg.code == ReturnCode_pb.Code_OK then
            for i, v in ipairs(msg.info.users) do
                if v.charId == MainData.GetCharId() then
                    RoleInfo = tableData_tMobaRole.data[v.roleid]
                end
            end
			if callback ~= nil then
                callback(msg)
            end
        else
        	Global.ShowError(msg.code)
        end
    end, true)
end

function RequestMobaPickRole(roleid, callback)
    local req = MobaMsg_pb.MsgMobaPickRoleRequest()
    req.roleid = roleid
    Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaPickRoleRequest, req, MobaMsg_pb.MsgMobaPickRoleResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            RoleInfo = tableData_tMobaRole.data[roleid]
			if callback ~= nil then
                callback(roleid)
            end
        else
        	Global.ShowError(msg.code)
        end
    end, true)
end

local eventStateListener = EventListener()

local curState = -1

local function NotifyStateListener()
    eventStateListener:NotifyListener()
end

function AddStateListener(listener)
    eventStateListener:AddListener(listener)
end

function RemoveStateListener(listener)
    eventStateListener:RemoveListener(listener)
end

function SetMobaState(state)
   curState = state		
end

function GetCurState()
	return curState
end 

function GetMobaState(notify)
		
    local serverTime = Serclimax.GameTime.GetSecTime()
	local state =-1
	if mobaEnterInfo ~= nil then 
		if serverTime>= mobaEnterInfo.firsttime and serverTime< mobaEnterInfo.secondtime then 
			state= 1
		elseif serverTime>= mobaEnterInfo.secondtime and serverTime< mobaEnterInfo.thirdtime then 
			state= 2
		elseif serverTime>= mobaEnterInfo.thirdtime and serverTime< mobaEnterInfo.fourthtime then 
			state= 3
		elseif serverTime>= mobaEnterInfo.fourthtime and serverTime< mobaEnterInfo.overtime then 
			state= 4
	    end
	end 
	if curState ~= state and notify ==true then 
		curState = state
		NotifyStateListener()
	end 

	return state
end

function GetMobaStateStartEndTime()
    local serverTime = Serclimax.GameTime.GetSecTime()
	if mobaEnterInfo ~= nil then 
		if serverTime>= mobaEnterInfo.firsttime and serverTime< mobaEnterInfo.secondtime then 
			return mobaEnterInfo.firsttime, mobaEnterInfo.secondtime
		elseif serverTime>= mobaEnterInfo.secondtime and serverTime< mobaEnterInfo.thirdtime then 
			return mobaEnterInfo.secondtime, mobaEnterInfo.thirdtime
		elseif serverTime>= mobaEnterInfo.thirdtime and serverTime< mobaEnterInfo.fourthtime then 
			return mobaEnterInfo.thirdtime, mobaEnterInfo.fourthtime
		elseif serverTime>= mobaEnterInfo.fourthtime and serverTime< mobaEnterInfo.overtime then 
			return mobaEnterInfo.fourthtime, mobaEnterInfo.overtime
	    end
    end
    return 0, 0
end

function GetMobaLeftTime()
    local serverTime = Serclimax.GameTime.GetSecTime()
	if mobaEnterInfo ~= nil then 
		--print("GetMobaLeftTime overtime ",mobaEnterInfo.overtime,Serclimax.GameTime.SecondToStringYMDLocal(mobaEnterInfo.overtime),serverTime,Serclimax.GameTime.SecondToStringYMDLocal(serverTime))
		return mobaEnterInfo.overtime - serverTime
	end 
	return 0
end

local mobaUserResult

function GetMobaUserResult()
    return mobaUserResult
end

function SetMobaUserResult(msg)
    if Global.GetMobaMode() == 1 then
        mobaUserResult = msg
        --Moba_winlose.Show()
        MobaMain.ShowMobaBattleResult(mobaUserResult)
    end
end

function GetMobaScoreInfo(callback)
    local req = MobaMsg_pb.MsgMobaSeeTeamInfoRequest()
    Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaSeeTeamInfoRequest, req, MobaMsg_pb.MsgMobaSeeTeamInfoResponse, function(msg)
        if callback ~= nil then
            callback(msg)
        end
    end, true)
end

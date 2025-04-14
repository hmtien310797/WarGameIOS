module("MissionListData", package.seeall)
local missionListData
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

local isBlocking = false
local blockingList = {}
local dailyMissionNoticeList = {}
local growNoticeList = {}

function Sort1()
    table.sort(missionListData, function(v1, v2)
        local data1 = TableMgr:GetMissionData(v1.id)
        local data2 = TableMgr:GetMissionData(v2.id)
        local complete1 = v1.value >= data1.number
        local complete2 = v2.value >= data2.number

        if complete1 == complete2 then
            return v1.id < v2.id
        else
            return complete1 and not complete2
        end
    end)
end

function Sort2()
    table.sort(missionListData, function(v1, v2)
        return v1.id < v2.id
    end)
end

function Sort3()
    table.sort(missionListData, function(v1, v2)
        local data1 = TableMgr:GetMissionData(v1.id)
        local data2 = TableMgr:GetMissionData(v2.id)
        local complete1 = v1.value >= data1.number
        local complete2 = v2.value >= data2.number
        if complete1 == complete2 then
            return data1.ChapOrder < data2.ChapOrder
        else
            return not complete1 and complete2
        end
    end)
end

function GetData()
    return missionListData
end

function SetData(data)
    missionListData = data
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

function RequestData()
    local req = ClientMsg_pb.MsgUserMissionRequest()
    req.type = 0
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserMissionRequest, req, ClientMsg_pb.MsgUserMissionResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            SetData(msg.quest)
            for _, v in ipairs(missionListData) do
                local missionData = TableMgr:GetMissionData(v.id)
				
				if missionData ~= nil then 
					if missionData.chest and missionData.type == 2 and not v.rewarded and v.value >= missionData.number then
						dailyMissionNoticeList[missionData.id] = true
					end

					if missionData.type == 100 and missionData.tab < 100 and not v.rewarded and v.value >= missionData.number then
						growNoticeList[missionData.tab] = true
					end
				end
            end
            NotifyListener()
        end
    end, true)
end

function UpdateMission(msg, notnotify)
	if isBlocking then
		table.insert(blockingList, msg)
		return
    end
    if missionListData == nil then
        return
    end
    local newMission = true
    local missionMsg
    for _, v in ipairs(missionListData) do
        if v.id == msg.id then
            v:MergeFrom(msg)
            newMission = false
            missionMsg = v
            break
        end
    end
    if newMission then
        missionMsg = missionListData:add()
        missionMsg:MergeFrom(msg)
    end
    local missionData = TableMgr:GetMissionData(msg.id)

    if missionData.chest and missionData.type == 2 and not missionMsg.rewarded and missionMsg.value >= missionData.number then
        dailyMissionNoticeList[missionMsg.id] = true
    end

    if missionData.type == 100 and missionData.tab < 100 and not missionMsg.rewarded and missionMsg.value >= missionData.number then
        growNoticeList[missionData.tab] = true
    end
    if not notnotify then
        NotifyListener()
    end
end

function UpdatePush(msg)
    for _, v in ipairs(msg.quest) do
        UpdateMission(v, true)
    end

    NotifyListener()
end

function RemoveMission(id)
    for i, v in ipairs(missionListData) do
        if v.id == id then
            missionListData:remove(i)
            break
        end
    end
end

function UpdateList(missionList)
    for _, v in ipairs(missionList) do
        local newMission = true

        for __, vv in ipairs(missionListData) do
            if vv.id == v.id then
                vv.value = v.value
                vv.rewarded = v.rewarded
                vv.status = v.status
                newMission = false
                break
            end
        end

        if newMission then
            local missionMsg = missionListData:add()
            missionMsg.id = v.id
            missionMsg.value = v.value
            missionMsg.rewarded = v.rewarded
            missionMsg.status = v.status
        end
    end

    NotifyListener()
end

function SetRewarded(id)
    for _, v in ipairs(missionListData) do
        if v.id == id then
            v.rewarded = true
            local missionData = TableMgr:GetMissionData(id)

            if missionData.type == 2 then
                dailyMissionNoticeList[id] = nil
            end
            NotifyListener()
            break
        end
    end
end

function GetRecommendedMissionAndData()
    local mission = nil
    local data = nil
    local storytips = false
    local storyfirst = nil
    local storylist = {}
    for _, v in ipairs(missionListData) do
        local missionData = TableMgr:GetMissionData(v.id)
        if missionData == nil then
            error(string.format("找不到id为:%d的任务数据", v.id))
        end
        if missionData.type == 1 and missionData.recommend ~= 0 and v.value <= missionData.number then
            local recommend = false
            if mission == nil then
                recommend = true
            elseif missionData.recommend == data.recommend then
                if missionData.type2 == data.type2 then
                    if missionData.id > data.id then
                        recommend = true
                    end
                elseif missionData.type2 < data.type2 then
                    recommend = true
                end
            elseif missionData.recommend < data.recommend then
                recommend = true
            end

            if recommend then
                mission = v
                data = missionData
            end
        end
        if missionData.type == ClientMsg_pb.UserMissionType_Chapter then
        	if missionData.type2 % 1000 == 0 then
	        	mission = v
	        	data = missionData
                --storytips = storytips or ActivityGrow.CheckStory(missionData.type2 / 1000)
            end
	        if v.value >= missionData.number and not v.rewarded then
	        	storytips = true
            end
            local story = {}
        	story.mission = v
        	story.data = missionData
        	table.insert(storylist, story)
        end
    end
    table.sort(storylist, function(a,b)
    	if a.data.ChapOrder ~= nil and b.data.ChapOrder ~= nil then
    		return a.data.ChapOrder < b.data.ChapOrder
    	end
    	return a.mission.id < b.mission.id
    end)
    for i, v in ipairs(storylist) do
        if storyfirst == nil and v.data.type2 % 1000 ~= 0 and v.mission.value < v.data.number then
            storyfirst = v.data
        end
    end
    return mission, data, storytips, storyfirst
end

function HasCompletedChapterMission(id)
    local chapter = ConfigData.GetStoryConfig()
    local missionMsg = GetMissionData(id)
    local missionData = TableMgr:GetMissionData(id)
    if missionMsg ~= nil then
        return missionMsg.value >= missionData.number
    else
        return missionData.type2 / 1000 < chapter
    end
    return false
end

function GetMissionData(id)
    for _, v in ipairs(missionListData) do
        if v.id == id then
            return v
        end
    end
    return nil
end

function HasCompletedMission(id)
    local missionMsg = GetMissionData(id)
    if missionMsg ~= nil then
        local missionData = TableMgr:GetMissionData(missionMsg.id)
        return missionMsg.value >= missionData.number
    end
    return false
end

function HasNotice()
    for _, v in ipairs(missionListData) do
        local missionData = TableMgr:GetMissionData(v.id)
        local missionType = missionData.type
        if missionType == 1 then
            if v.value >= missionData.number then
                return true
            end
        end
    end
    return false
end

function HasDailyMissionNotice()
    return next(dailyMissionNoticeList) ~= nil
end

function CancelDailyNotice()
    dailyMissionNoticeList = {}
end

function HasFinishedAllDailyMission()
    for _, v in ipairs(missionListData) do
        local missionData = TableMgr:GetMissionData(v.id)
        local missionType = missionData.type
        if missionType == 2 and not v.rewarded then
            return false
        end
    end

    return true
end

function HasAnyGrowNotice()
    return next(growNoticeList) ~= nil
end

function HasGrowNotice(tabIndex)
    return growNoticeList[tabIndex] ~= nil
end

function CancelGrowNotice(tabIndex)
    growNoticeList[tabIndex] = nil
end

function HasFinishedAllGrow()
    for _, v in ipairs(missionListData) do
        local missionData = TableMgr:GetMissionData(v.id)
        local missionType = missionData.type
        if missionData.tab < 100 and missionType == 100 and not v.rewarded then
            return false
        end
    end

    return true
end

function BlockMsg()
	--isBlocking = true
end

function ReleaseMsg()
	isBlocking = false
	while #blockingList > 0 do
		local b = table.remove(blockingList, 1)
		UpdateMission(b, true)
    end
    NotifyListener()
end

function  RequestDataByType(type)
    local req = ClientMsg_pb.MsgUserMissionRequest()
    req.type = type
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserMissionRequest, req, ClientMsg_pb.MsgUserMissionResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            UpdateList(msg.quest)
            for _, v in ipairs(missionListData) do
                local missionData = TableMgr:GetMissionData(v.id)

                if missionData.chest and missionData.type == 2 and not v.rewarded and v.value >= missionData.number then
                    dailyMissionNoticeList[missionData.id] = true
                end

                if missionData.type == 100 and missionData.tab < 100 and not v.rewarded and v.value >= missionData.number then
                    growNoticeList[missionData.tab] = true
                end
            end
            NotifyListener()
        end
    end, true)
end

function HasDailyMissionNotice()
    for _, v in ipairs(missionListData) do
        local missionData = TableMgr:GetMissionData(v.id)
        if missionData.chest and missionData.type == 2 and not v.rewarded and v.value >= missionData.number then
            return true
        end
    end
    return false
end

function GetCompletedMainMissionCount()
    local completedCount = 0
    for _, v in ipairs(missionListData) do
        local missionData = TableMgr:GetMissionData(v.id)
        if missionData.type == 1 and not v.rewarded and v.value >= missionData.number then
            completedCount = completedCount + 1
        end
    end

    return completedCount
end

function GetCompletedChestCount()
    local completedCount = 0
    for _, v in ipairs(missionListData) do
        local missionData = TableMgr:GetMissionData(v.id)
        if missionData.chest and missionData.type == 2 and not v.rewarded and v.value >= missionData.number then
            completedCount = completedCount + 1
        end
    end

    return completedCount
end

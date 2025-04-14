module("PathInfo", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback

local pathInfoMsg

local _ui

function Hide()
    Global.CloseUI(_M)
end


local moba_ruling_strs =  { "moba_mapzone0", "moba_mapzone1", "moba_mapzone2" };
local function LoadUI()
    local status = pathInfoMsg.status
    local pathType = pathInfoMsg.pathType

    local guildMsg = pathInfoMsg.ownerguild
    if guildMsg.guildid == 0 then
        if pathType == Common_pb.TeamMoveType_Nemesis then
            _ui.playerNameLabel.text = TextMgr:GetText(pathInfoMsg.charname)
        else
            _ui.playerNameLabel.text = pathInfoMsg.charname
        end
    else
        local guildbanner = guildMsg.guildbanner
        if Global.GetMobaMode() == 1 then
            guildbanner = TextMgr:GetText(moba_ruling_strs[guildMsg.guildid+1])
        elseif Global.GetMobaMode() == 2 then
            guildbanner = TextMgr:GetText(moba_ruling_strs[guildMsg.guildid+1])
        end
        
        _ui.playerNameLabel.text = string.format("[%s]%s", guildbanner, pathInfoMsg.charname)
    end
    local targetPos = pathInfoMsg.targetPos
    if Global.GetMobaMode() ~= 0 then
        local offsetx,offsety = MobaMain.MobaMinPos()
        targetPos.x = targetPos.x -offsetx
        targetPos.y = targetPos.y -offsety
    end
    local coordText = string.format("X:%d Y:%d", targetPos.x, targetPos.y)
    if status == -1 then
        local stateText = TextMgr:GetText(Text.ui_worldmap_36)
        _ui.pathStateLabel.text = String.Format(stateText, coordText)
    else
        local stateText = TextMgr:GetText(_ui.stateTextList[pathType])
        _ui.pathStateLabel.text = String.Format(stateText, coordText)
    end

    _ui.retreatButton.gameObject:SetActive(pathInfoMsg.status == Common_pb.PathMoveStatus_Go)
    local charId = MainData.GetCharId()
    local selfPath = pathInfoMsg.charid == charId

	print("sss ",pathType , status,selfPath)
	
	if Global.GetMobaMode() == 1 then 
		MobaActionListData.RequestData()
    elseif Global.GetMobaMode() == 2 then
    end 
	
    local canAccelerate = true
    --非自己的飞机不能撤退
    if not selfPath then
        canAccelerate = false
		if Global.GetMobaMode() == 1 then
			print("dsd")
			if pathType == Common_pb.TeamMoveType_GatherCall and status == Common_pb.PathMoveStatus_Go and guildMsg.guildid == MobaMainData.GetTeamID() then 

				if MobaActionListData.GetActionData(pathInfoMsg.pathId)~=nil or MobaActionListData.GetActionDataByAttachPath(pathInfoMsg.pathId) ~= nil then
					canAccelerate = true
				end 
		   end 
        elseif Global.GetMobaMode() == 2 then
			if pathType == Common_pb.TeamMoveType_GatherCall and status == Common_pb.PathMoveStatus_Go and guildMsg.guildid == MobaMainData.GetTeamID() then 

				if MobaActionListData.GetActionData(pathInfoMsg.pathId)~=nil or MobaActionListData.GetActionDataByAttachPath(pathInfoMsg.pathId) ~= nil then
					canAccelerate = true
				end 
		   end 
        end 
    elseif status ~= Common_pb.PathMoveStatus_Go and status ~= Common_pb.PathMoveStatus_Back then
        canAccelerate = false
		
		--集结大飞机不能加速
    elseif status == Common_pb.PathMoveStatus_Go and pathType == Common_pb.TeamMoveType_GatherCall then
        canAccelerate = false

        if Global.IsSlgMobaMode() then
            if Global.GetMobaMode() == 1 then
                if guildMsg.guildid == MobaMainData.GetTeamID() then
                    if MobaActionListData.GetActionData(pathInfoMsg.pathId)~=nil or MobaActionListData.GetActionDataByAttachPath(pathInfoMsg.pathId) ~= nil then
                        canAccelerate = true
                    end                 
                end
            elseif Global.GetMobaMode() == 2 then
				 if guildMsg.guildid == MobaMainData.GetTeamID() then
                    if MobaActionListData.GetActionData(pathInfoMsg.pathId)~=nil or MobaActionListData.GetActionDataByAttachPath(pathInfoMsg.pathId) ~= nil then
                        canAccelerate = true
                    end                 
                end
			
			end
		end 
        --指挥官回城不能加速
    elseif pathType == Common_pb.TeamMoveType_Prisoner then
        canAccelerate = false
    end
    local canRetreat = true
    --非自己的飞机不能撤退
    if not selfPath then
        canRetreat = false
        --已经在撤退的不能撤退
    elseif status == Common_pb.PathMoveStatus_Back then
        canRetreat = false
        --响应集结的和大飞机不能撤退
    elseif (status == Common_pb.PathMoveStatus_Go and pathType == Common_pb.TeamMoveType_GatherRespond) or status == Common_pb.PathEntryStatus_Gather then
        canRetreat = false
		
		
    end
	
	if Global.GetMobaMode() == 2 then
		canRetreat = false
	end 


    _ui.retreatButton.gameObject:SetActive(canRetreat)
    _ui.accelerateButton.gameObject:SetActive(canAccelerate)
end

function Awake()
    _ui = {}
    if _ui.stateTextList == nil then
        _ui.stateTextList = {}
        _ui.stateTextList[Common_pb.TeamMoveType_ResTake] = Text.ui_worldmap_32
        _ui.stateTextList[Common_pb.TeamMoveType_MineTake] = Text.ui_worldmap_32
        _ui.stateTextList[Common_pb.TeamMoveType_TrainField] = Text.ui_worldmap_32
        _ui.stateTextList[Common_pb.TeamMoveType_Garrison] = Text.ui_worldmap_34
        _ui.stateTextList[Common_pb.TeamMoveType_GatherCall] = Text.ui_worldmap_35
        _ui.stateTextList[Common_pb.TeamMoveType_GatherRespond] = Text.ui_worldmap_35
        _ui.stateTextList[Common_pb.TeamMoveType_AttackMonster] = Text.ui_worldmap_32
        _ui.stateTextList[Common_pb.TeamMoveType_AttackPlayer] = Text.ui_worldmap_32
        _ui.stateTextList[Common_pb.TeamMoveType_ReconMonster] = Text.ui_worldmap_31
        _ui.stateTextList[Common_pb.TeamMoveType_ReconPlayer] = Text.ui_worldmap_31
        _ui.stateTextList[Common_pb.TeamMoveType_Camp] = Text.ui_worldmap_32
        _ui.stateTextList[Common_pb.TeamMoveType_Occupy] = Text.ui_worldmap_32
        _ui.stateTextList[Common_pb.TeamMoveType_ResTransport] = Text.ui_worldmap_33
        _ui.stateTextList[Common_pb.TeamMoveType_MonsterSiege] = Text.ui_worldmap_32
    end
    _ui.playerNameLabel = transform:Find("Container/bg_frane/bg_msg/name"):GetComponent("UILabel")
    _ui.pathStateLabel = transform:Find("Container/bg_frane/bg_msg/text"):GetComponent("UILabel")
    _ui.arriveTimeLabel = transform:Find("Container/bg_frane/bg_msg/num"):GetComponent("UILabel")

    local bg = transform:Find("Container")
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
    _ui.retreatButton = transform:Find("Container/bg_frane/btn_back"):GetComponent("UIButton")
    _ui.accelerateButton = transform:Find("Container/bg_frane/btn_speedup"):GetComponent("UIButton")
    SetClickCallback(closeButton.gameObject, Hide)
    SetClickCallback(bg.gameObject, Hide)
    SetClickCallback(_ui.retreatButton.gameObject, function()
        if Global.GetMobaMode() == 1 then
			QuickUseItem.Show(101011, function(buy)
				local garrisonUser = 0
				local pathType = pathInfoMsg.pathType
				if pathType == Common_pb.TeamMoveType_Garrison then
					garrisonUser = MainData.GetCharId()
				end
				MobaActionList.RequestRetreat(pathInfoMsg.pathId, 0, garrisonUser, buy)
				Hide()
            end)
        elseif Global.GetMobaMode() == 2 then
			QuickUseItem.Show(101012, function(buy)
				local garrisonUser = 0
				local pathType = pathInfoMsg.pathType
				if pathType == Common_pb.TeamMoveType_Garrison then
					garrisonUser = MainData.GetCharId()
				end
				MobaActionList.RequestRetreat(pathInfoMsg.pathId, 0, garrisonUser, buy)
				Hide()
            end)
		
		
		else
			QuickUseItem.Show(10101, function(buy)
				local garrisonUser = 0
				local pathType = pathInfoMsg.pathType
				if pathType == Common_pb.TeamMoveType_Garrison then
					garrisonUser = MainData.GetCharId()
				end
				ActionList.RequestRetreat(pathInfoMsg.pathId, 0, garrisonUser, buy)
				Hide()
			end)
		end 
    end)
    SetClickCallback(_ui.accelerateButton.gameObject, function()
        local targetPos = pathInfoMsg.targetPos
        if Global.GetMobaMode() == 1 then
			local _, statusText, _ = MobaActionList.GetActionTargetInfo(pathInfoMsg.status, pathInfoMsg.pathType, pathInfoMsg.targetPos, "")
			local pathid = pathInfoMsg.pathId
			print("pathInfoMsg.pathId ",pathid)
			if MobaActionListData.GetActionDataByAttachPath(pathInfoMsg.pathId) ~= nil then 
				 pathid = MobaActionListData.GetActionDataByAttachPath(pathInfoMsg.pathId).uid
			end 
			print("pathInfoMsg.pathId new  ",pathid)
			MainCityUI.ShowMarchingAcceleration(pathid, statusText)
        elseif Global.GetMobaMode() == 2 then
			local _, statusText, _ = MobaActionList.GetActionTargetInfo(pathInfoMsg.status, pathInfoMsg.pathType, pathInfoMsg.targetPos, "")
			local pathid = pathInfoMsg.pathId
			print("pathInfoMsg.pathId ",pathid)
			if MobaActionListData.GetActionDataByAttachPath(pathInfoMsg.pathId) ~= nil then 
				 pathid = MobaActionListData.GetActionDataByAttachPath(pathInfoMsg.pathId).uid
			end 
			print("pathInfoMsg.pathId new  ",pathid)
			MainCityUI.ShowMarchingAcceleration(pathid, statusText)
		
		else
			local _, statusText, _ = ActionList.GetActionTargetInfo(pathInfoMsg.status, pathInfoMsg.pathType, pathInfoMsg.targetPos, "")
			MainCityUI.ShowMarchingAcceleration(pathInfoMsg.pathId, statusText)
		end 
		
        Hide()
    end)

end

function Show(msg)
    pathInfoMsg = msg
    Global.OpenUI(_M)
    LoadUI()
end

function Update()
    local arriveText = TextMgr:GetText(Text.ui_worldmap_37)
    local timeText, lefttime = Global.GetLeftCooldownTextLong(pathInfoMsg.starttime + pathInfoMsg.time)
    _ui.arriveTimeLabel.text = String.Format(arriveText, timeText)
    if lefttime <= 0 then
        Global.CloseUI(_M)
    end
end

function Close()
    _ui = nil
end

module("ClimbData", package.seeall)
local TableMgr = Global.GTableMgr
local GameTime = Serclimax.GameTime
local TextMgr = Global.GTextMgr

local climbInfoData = nil
local climbQuestData = nil
local climbSchemeMap = nil
local climbPassMap = nil
local curServerLevel_ID = nil


local climbScoreRefrush = EventListener()

local function NotifyClimbScoreListener()
    climbScoreRefrush:NotifyListener()
end

function AddClimbScoreListener(listener)
    climbScoreRefrush:AddListener(listener)
end

function RemoveClimbScoreListener(listener)
    climbScoreRefrush:RemoveListener(listener)
end

function RefrushCurServerLevelID(id)
	curServerLevel_ID = id
	--print("iiiiiiiiiiiiiiiiiiiiiiiiiiddddddddddddddd",curServerLevel_ID)
end

function RefrushClimbScore(climbScore)
	if climbInfoData ~= nil then
		climbInfoData.climbInfo.climbScore = climbScore
		NotifyClimbScoreListener()
	end
end

function GetCurServerLevel()
	return curServerLevel_ID
end

function GetQuestData()
	return climbQuestData
end

function RefrushQuestData(questData)
	if climbQuestData == nil then
		return
	end
	if questData == nil then
		return 
	end
	local quest = {}
	quest.id = questData.id
	quest.conditions = {}
	if questData.conditions ~= nil then
		for i=1,#questData.conditions do
			quest.conditions[questData.conditions[i]] = true
		end
	end
	quest.take = questData.take
	climbQuestData[quest.id] = quest
end

function UpdateClimbInfo(msg)
	climbInfoData = {}
	climbInfoData = msg
	climbSchemeMap = {}
	climbPassMap = {} 
	for i =1,#climbInfoData.climbInfo.schemes do
		climbSchemeMap[i] = {}
		if climbInfoData.climbInfo.schemes[i].scheme ~= nil then
			for j = 1,#climbInfoData.climbInfo.schemes[i].scheme.armyScheme.army do
				local ArmySetoutNumInfo = climbInfoData.climbInfo.schemes[i].scheme.armyScheme.army[j]
				if climbSchemeMap[i][ArmySetoutNumInfo.armyId] == nil then
					climbSchemeMap[i][ArmySetoutNumInfo.armyId]= {}
				end
				climbSchemeMap[i][ArmySetoutNumInfo.armyId][ArmySetoutNumInfo.armyLevel] = ArmySetoutNumInfo
			end
		end
	end
	for i = 1,#climbInfoData.climbInfo.perfectStages do
		climbPassMap[climbInfoData.climbInfo.perfectStages[i]] = climbInfoData.climbInfo.perfectStages[i]
	end
	climbQuestData = {}
	if climbInfoData.climbInfo.questData ~= nil then
		for i=1, #climbInfoData.climbInfo.questData.quests do
			RefrushQuestData(climbInfoData.climbInfo.questData.quests[i])
		end
	end
	
	RefrushCurServerLevelID(climbInfoData.climbInfo.lastPassStage)
end



function GetClimbInfo()
	return climbInfoData
end

function GetClimbSchemeMap()
	return climbSchemeMap
end

function isPerfectLevel(level_id)
	if climbPassMap ~= nil then
		return climbPassMap[level_id] ~= nil
	end
	return false
end

function ReqMsgClimbInfo(callback)
	local req = BattleMsg_pb.MsgClimbInfoRequest()
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgClimbInfoRequest, req, BattleMsg_pb.MsgClimbInfoResponse, function(msg)
		Global.DumpMessage(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			UpdateClimbInfo(msg)
			NotifyClimbScoreListener()
			if callback ~= nil then
				callback()
			end
		else
			Global.ShowError(msg.code)		
		end
	end, false)
end


function ReqSetClimbFormation(formation,callback)
	local req = BattleMsg_pb.MsgSetClimbFormationRequest()
    for i =1,6,1 do
        req.formation.form:append(formation[i])
    end	
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgSetClimbFormationRequest, req, BattleMsg_pb.MsgSetClimbFormationResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			if climbInfoData ~= nil then
				for i =1,6,1 do
					climbInfoData.climbInfo.formation.form[i] = formation[i]
				end
			end
			if callback ~= nil then
				callback()
			end
		else
			Global.ShowError(msg.code)	
			if callback ~= nil then
				callback()
			end				
		end
	end, false)
end

function ReqSetClimbArmyScheme(index,army,hero,formation,callback)
	local req = BattleMsg_pb.MsgSetClimbArmySchemeRequest()
	req.scheme.index = index 
	
    table.foreach(army,function(_,v)
		if v.num > 0 then
		   local army = req.scheme.armyScheme.army:add()
		   army.armyId = v.type_id
		   army.armyLevel = v.level
		   army.num = v.num
		   local barrack_data = Barrack.GetAramInfo(army.armyId,army.armyLevel )
		   local barrackid = barrack_data.BarrackId;
		   for j =1,#formation do
				if barrackid == formation[j] then
					army.pos = j
					print("EEEEEEEEEEEEEEEEEEEEEE",army.pos)
					break;
				end
		   end		   
		end
	end)
	
    for i =1,#hero,1 do
        req.scheme.armyScheme.hero:append(hero[i])
    end    	
	
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgSetClimbArmySchemeRequest, req, BattleMsg_pb.MsgSetClimbArmySchemeResponse, function(msg)
		Global.DumpMessage(msg)
		if msg.code == ReturnCode_pb.Code_OK then
				
			UpdateClimbInfo(msg)
			
			if callback ~= nil then
				callback()
			end
		else
			Global.ShowError(msg.code)	
			if callback ~= nil then
				callback()
			end				
		end
	end, false)
end


function ReqRestartClimbChapter(callback)
	local req = BattleMsg_pb.MsgRestartClimbChapterRequest()
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgRestartClimbChapterRequest, req, BattleMsg_pb.MsgRestartClimbChapterResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			UpdateClimbInfo(msg)
			if callback ~= nil then
				callback(true)
			end
		else
			Global.ShowError(msg.code)	
			if callback ~= nil then
				callback(false)
			end				
		end
	end, false)
end

function ReqGoForwardClimb(callback)
	local req = BattleMsg_pb.MsgGoForwardClimbRequest()
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgGoForwardClimbRequest, req, BattleMsg_pb.MsgGoForwardClimbResponse, function(msg)
		Global.DumpMessage(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			if climbInfoData ~= nil then
				print("msg.lastPassStage",msg.lastPassStage)
				if msg.lastPassStage ~= nil then
					climbInfoData.climbInfo.lastPassStage = msg.lastPassStage
					RefrushCurServerLevelID(climbInfoData.climbInfo.lastPassStage)
				end
				if msg.nextArriveTime ~= nil then
					climbInfoData.climbInfo.nextArriveTime = msg.nextArriveTime
				end
			end
			if callback ~= nil then
				callback(true)
			end
		else
			Global.ShowError(msg.code)	
			if callback ~= nil then
				callback(false)
			end				
		end
	end, false)	
end

function ReqFightClimbBattle(index,callback)
	local req = BattleMsg_pb.MsgFightClimbBattleRequest()
	req.schemeIndex =index
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgFightClimbBattleRequest, req, BattleMsg_pb.MsgFightClimbBattleResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			if callback ~= nil then
				callback(true)
			end
		else
			Global.ShowError(msg.code)	
			if callback ~= nil then
				callback(false)
			end				
		end
	end, false)	
end


function UserRankListRequest(callback)
	local req = ClientMsg_pb.MsgUserRankListRequest()
	req.rankType = 101
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserRankListRequest, req, ClientMsg_pb.MsgUserRankListResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
            	callback(msg)
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end
function ClimbRankListRequest(day,callback)
	local req = BattleMsg_pb.MsgClimbRankListRequest()
	req.rankType = day and 1 or 2
    Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgClimbRankListRequest, req, BattleMsg_pb.MsgClimbRankListResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
            	callback(msg)
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end



function RequestClimbShopData(bagParam,callback)
	local req = BattleMsg_pb.MsgClimbShopInfoRequest()
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgClimbShopInfoRequest, req, BattleMsg_pb.MsgClimbShopInfoResponse, function(msg)
		Global.DumpMessage(msg)
        if msg.code == ReturnCode_pb.Code_OK then
			bagParam.msg = msg.shopInfo
			if callback ~= nil then
				callback(msg)
			end
			UnionShop.LoadUnionShopListBag(bagParam)
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function RefreshClimbShop(bagParam,callback)
	local req = BattleMsg_pb.MsgRefreshClimbShopRequest()
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgRefreshClimbShopRequest, req, BattleMsg_pb.MsgRefreshClimbShopResponse, function(msg)
		Global.DumpMessage(msg)
        if msg.code == ReturnCode_pb.Code_OK then
			bagParam.msg = msg.shopInfo
			MainCityUI.UpdateRewardData(msg.fresh)
			if callback ~= nil then
				callback(msg)
			end
			UnionShop.LoadUnionShopListBag(bagParam)
        else
        	Global.ShowError(msg.code)
        end
    end, false)	
end

function ReqClimbTakeQuestReward(quest_id,callback)
	local req = BattleMsg_pb.MsgClimbTakeQuestRewardRequest()
	req.id = quest_id
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgClimbTakeQuestRewardRequest, req, BattleMsg_pb.MsgClimbTakeQuestRewardResponse, function(msg)
		Global.DumpMessage(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			RefrushQuestData(msg.quest)
			MainCityUI.UpdateRewardData(msg.fresh)
			if callback ~= nil then
				callback(msg)
			end
        else
        	Global.ShowError(msg.code)
        end
    end, false)	
end

function ReqBuyClimbCount(callback)
	local req = BattleMsg_pb.MsgBuyClimbCountRequest()
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgBuyClimbCountRequest, req, BattleMsg_pb.MsgBuyClimbCountResponse, function(msg)
		Global.DumpMessage(msg)
		if msg.code == ReturnCode_pb.Code_OK then

			MainCityUI.UpdateRewardData(msg.fresh)
			if climbInfoData ~= nil then
				climbInfoData.climbInfo.count:MergeFrom(msg.climbCount)
			end
			CountListData.SetCount(msg.buyCount)
			if callback ~= nil then
				callback()
			end
		elseif msg.code == ReturnCode_pb.Code_DiamondNotEnough then
			Global.ShowNoEnoughMoney()
		else
        	Global.ShowError(msg.code)
        end
    end, false)	
end

local function GetClimbRankRewards()
	local rewards = {}
	local last_show = 0
	local last_week_show = 0
	for i=1,100 do
		rewards[i] = {}
		rewards[i].id = i
		rewards[i].rewardType = 1
		rewards[i].order = i
		local data = TableMgr:GetClimbRank(i)
		if data ~= nil then
			last_show = data.awardShow
			last_week_show = data.WeekawardShow
		end
		rewards[i].awardShow = last_show
		rewards[i].weekawardShow = last_week_show
	end

	return rewards
end

function GetPersonRankReward()
	local reward = {}
	local mr = GetClimbRankRewards()
	for i = 1, #mr do
		reward[i] = mr[i]
		reward[i].awardlist = {}
		local award = TableMgr:GetDropShowData(reward[i].awardShow)
		for ii = 1, #award do
			reward[i].awardlist[ii] = award[ii]
		end
	end
	return reward
end

function GetWeekRankReward()
	local reward = {}
	local mr = GetClimbRankRewards()
	for i = 1, #mr do
		reward[i] = mr[i]
		reward[i].awardlist = {}
		local award = TableMgr:GetDropShowData(reward[i].weekawardShow)
		for ii = 1, #award do
			reward[i].awardlist[ii] = award[ii]
		end
	end
	return reward
end
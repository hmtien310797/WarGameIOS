module("Climb", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String
local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local Common_pb = require("Common_pb")
local _ui = nil

local ScreenLevelCount = 0
local CarSpeed = 64
local CameraFollowSpeed =80
local AdSpeed = 1
local ScreenNeighborIndex = {-1,0,1}
local FollowWaitTime = 1
local OnValueChange
local ChapterID = 0
OnCloseCB = nil
HadReward = 0
local FirePointOffset = 417
local SetCarMove2Level = nil
local RewardCoroutine = nil

RefrushMap = nil
local StartLevel;
local EndLevel;
local CurLayer = 0;
local TotalLayer= 0;
local CarLayer = 0;
local PreLayerCount = 10;
local TotalLevel = 0;
local ShowUpperLayerOffset = 200;
local ShowNextLayerOffset = 1500;
local RefrushReplayBtn = nil
local LEVEL_STATE=
{
	Arrive = 1,
	NoPass = 2,
	Passed = 3,
}

local bg_texture_names = {"bg_climb1","bg_climb2","bg_climb3","bg_climb4","bg_climb5"}

local layer_names = {"climb_layer3","climb_layer4","climb_layer5","climb_layer6","climb_layer7","climb_layer8"}

function RefrushHadReward()
	HadReward = math.max(0,HadReward -1)
end

function GetClimbLevel(chapter_id,level,preLayerCount)
	
	local plc = preLayerCount
	if plc == nil then
		plc = PreLayerCount
	end
	local pl = level-plc
	return TableMgr:GetClimbLevel(chapter_id,pl)
end

function GetClimbDataOrder(chapter_id,level_id)
	local order = TableMgr:GetClimbDataOrder(chapter_id,level_id)
	if order == nil then
		local cur_id_layer = TableMgr:ClimbLayerIdToIndex(chapter_id)
		local pre_chapter_id = TableMgr:ClimbLayerIndexToId(cur_id_layer -1)
		if pre_chapter_id ~= nil then
			local pl = TableMgr:GetClimbLayerStartLevelCount(cur_id_layer -1)
			order = TableMgr:GetClimbDataOrder(pre_chapter_id,level_id)
			if order ~= nil then
				order = order+pl
			end
			return order
		end
	end
	if order ~= nil then
		order = order+PreLayerCount
	end
	return order
end

function GetPreLayerCount()
	return PreLayerCount 
end

function OnUICameraClick(go)
	Tooltip.HideItemTip()
	if _ui ~= nil then
    	if go ~= _ui.tipObject then
        	_ui.tipObject = nil
		end
	end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

function CanBattle(levelId)
	if _ui == nil then
		return false
	end
	if _ui.Map.Car.NeedMove then
		return false
	else
		local level_data = GetClimbLevel(ChapterID,_ui.Map.Car.CurLevel);--TableMgr:GetClimbLevel(ChapterID,math.max(1,_ui.Map.Car.CurLevel - PreLayerCount))
		if level_data == nil then
			return false
		end
		local level_pass = false
		local level_id,arrive,pass = GetCurLevelAndState()
		if levelId ~= level_data.id then
			return false
		end
		local order = GetClimbDataOrder(ChapterID,level_id)
		if _ui.Map.Car.CurLevel == order then
			level_pass = pass
		end
			
		if ClimbData.isPerfectLevel(level_data.id) or level_pass then
			return false
		else
			return true							
		end
	end
end


function UpdateGOAndBattleBtn()
	local go_batch = false
	local go = false
	if _ui.Map.Car.NeedMove then
		--_ui.go_batch.gameObject:SetActive(false)
		--_ui.go.gameObject:SetActive(true)
		_ui.battle.gameObject:SetActive(false)
		go_batch = false 
		go = true
	else
		local level_data = GetClimbLevel(ChapterID,_ui.Map.Car.CurLevel);--TableMgr:GetClimbLevel(ChapterID,math.max(1,_ui.Map.Car.CurLevel - PreLayerCount))
		local level_pass = false
		local level_id,arrive,pass = GetCurLevelAndState()
		local order = GetClimbDataOrder(ChapterID,level_id)
		if _ui.Map.Car.CurLevel == order then
			level_pass = pass
		end
		if level_data == nil then
			print("SSSSSSSSSSSSS",ChapterID,_ui.Map.Car.CurLevel)
		end
		if ClimbData.isPerfectLevel(level_data.id) or level_pass then
			if  not level_pass then
				--_ui.go.gameObject:SetActive(false)
				--_ui.go_batch.gameObject:SetActive(true)	
				go_batch = true 
				go = false			
			else
				local next_level = math.min( _ui.Map.Car.CurLevel+1,EndLevel)
				local next_level_data = GetClimbLevel(ChapterID,next_level); --TableMgr:GetClimbLevel(ChapterID,math.max(1,next_level - PreLayerCount))
				if ClimbData.isPerfectLevel(next_level_data.id) then
					--_ui.go.gameObject:SetActive(false)
					--_ui.go_batch.gameObject:SetActive(true)		
					go_batch = true 
					go = false								
				else
					--_ui.go.gameObject:SetActive(true)
					--_ui.go_batch.gameObject:SetActive(false)
					go_batch = false 
					go = true						
				end				
			end
			
			_ui.battle.gameObject:SetActive(false)
		else
			--_ui.go_batch.gameObject:SetActive(false)
			--_ui.go.gameObject:SetActive(false)
			_ui.battle.gameObject:SetActive(true)	
			go_batch = false 
			go = false								
		end
	end
	if 	_ui.Map.Car.CurLevel>= TotalLevel then
		go_batch = false 
		go = false		
	end	
	if not go and not go_batch and CurLayer == CarLayer then
		if not RefrushReplayBtn() then
			local level_data = GetClimbLevel(ChapterID,_ui.Map.Car.CurLevel); --TableMgr:GetClimbLevel(ChapterID,math.max(1,_ui.Map.Car.CurLevel - PreLayerCount))
			OnClickLevelInfo(level_data.id)				
		end				
	end	
	return go,go_batch
end

function GetNextNotPrefectLevel(car_level)
	local cl = car_level
	local tlc = TotalLevel
	local nl = 0
	if cl == tlc then
		nl = cl
	else
		for i = cl+1,tlc do
			nl = i;
			local level_data = TableMgr:GetClimbLevel4Id(i)--GetClimbLevel(ChapterID,i);--TableMgr:GetClimbLevel(ChapterID,i- PreLayerCount)
			if not (ClimbData.isPerfectLevel(level_data.id)) then
				return true,i
			end
		end		
	end
	if nl == tlc then
		return true,nl
	else
		return false,-1
	end	
end

RefrushReplayBtn = function ()
	local climb_info = ClimbData.GetClimbInfo()
	if climb_info ~= nil then
		
		local enabled_replay = climb_info.climbInfo.firstLoseStage > 0 
		local enabled_replay2 = false
		if climb_info.climbInfo.status == 1 then
			local server_level_index = GetClimbDataOrder(ChapterID,ClimbData.GetCurServerLevel())
			if server_level_index ~= nil then
				enabled_replay2 = server_level_index >= 10
				if server_level_index >= TableMgr:GetClimpChapterLevelTotalCount() then
					enabled_replay = true
				end			
			end
		end
		
		_ui.replay.gameObject:SetActive(enabled_replay or enabled_replay2)
		return enabled_replay
	else
		_ui.replay.gameObject:SetActive(false)
		return false
	end
end

function LevelCount2ScreenIndex(level)		
	return math.floor( level / ScreenLevelCount)
end

function Pos2ScreenIndex(pos,bg_width)
	if pos == _ui.Map_bg_Total_width then
		pos = _ui.Map_bg_Total_width -1
	end
	return math.floor( pos / bg_width)	
end

function AdjustPos4Progress(pos)
	local p = (pos - _ui.ScreenWidth/2)
	if p < 0 then
		p = 0
	elseif p > _ui.Map_bg_Total_width - _ui.ScreenWidth then
		p = 1
	else
		p = p /(_ui.Map_bg_Total_width - _ui.ScreenWidth)
	end
	return p
end

function RefrushLevelInfo(ScreenListItem,open)
	if ScreenListItem == nil then
		return 
	end
	--if _ui.climbTableData ~= nil then
		local levelData = TableMgr:GetClimbLevel4Id(ScreenListItem.level)
		if ScreenListItem.level > EndLevel then
			levelData = nil
		end
		if ScreenListItem.level < StartLevel then
			levelData = nil
		end
		local climb_quest = ClimbData.GetQuestData()
		if levelData ~= nil then

			ScreenListItem.root_trf.gameObject:SetActive(true)
			--print("QQQQQQQQQQQQQQQQ",ScreenListItem.level , _ui.Map.Car.TargetLevel)
			local level_show = not (ClimbData.isPerfectLevel(levelData.id) or ScreenListItem.level < _ui.Map.Car.TargetLevel)

			if ScreenListItem.level == _ui.Map.Car.CurLevel then
				local level_id,arrive,pass = GetCurLevelAndState()
				local order = GetClimbDataOrder(ChapterID,level_id)
				if _ui.Map.Car.CurLevel == order then
					level_show = not pass and not ClimbData.isPerfectLevel(levelData.id)
				end
			end


			ScreenListItem.levelIcon.gameObject:SetActive(level_show)
			ScreenListItem.levelIcon.mainTexture = ResourceLibrary:GetIcon("Chapter/", levelData.Icon)
			--ScreenListItem.levelIcon:MakePixelPerfect()
			local level_reward_show = true
			if _ui.Map.Car.CurLevel == ScreenListItem.level then
				local level_id,arrive,pass = GetCurLevelAndState()
				local order = GetClimbDataOrder(ChapterID,level_id)
				if order == nil then
					level_reward_show = ScreenListItem.level >= _ui.Map.Car.TargetLevel
				else
					level_reward_show = HadReward ~= 0 and  ScreenListItem.level >= _ui.Map.Car.TargetLevel or level_show
				end
			else
				level_reward_show = ScreenListItem.level >= _ui.Map.Car.TargetLevel
			end
			local reward_show = level_reward_show or open
			--print("QQQQQQQQQQ",_ui.Map.Car.CurLevel , ScreenListItem.level,_ui.Map.Car.TargetLevel,level_reward_show , open)
			ScreenListItem.levelRward.gameObject:SetActive(reward_show)

	
			if open then				
				ScreenListItem.levelRewardAnim:Play("levelItem")
			else
				ScreenListItem.levelRewardAnim:Play("item_daiji")
			end
			

			
			ScreenListItem.levelRwardIcon.mainTexture = ResourceLibrary:GetIcon("Chapter/", levelData.RewardIcon)
			ScreenListItem.levelRwardOpenIcon.mainTexture = ResourceLibrary:GetIcon("Chapter/", levelData.RewardIcon.."_open")
			--ScreenListItem.levelRwardIcon:MakePixelPerfect()
			ScreenListItem.levelLabel.text = System.String.Format(TextMgr:GetText(levelData.NameLabel), ScreenListItem.level)
			
			ScreenListItem.levelIcon.transform.localPosition = ScreenListItem.cfg.levelIconLocalPosition
			ScreenListItem.levelRward.transform.localPosition = ScreenListItem.cfg.levelRewardIconLocalPosition
			ScreenListItem.levelLabelRoot.transform.localPosition = ScreenListItem.cfg.levelNameLocalPosition

			local reward_show = false
			local show_reward = levelData.chapterID ~= 0 

			if climb_quest[levelData.chapterID] ~= nil and climb_quest[levelData.chapterID].take then
				show_reward = false
			end

			if show_reward then
				reward_show = true
				local rewardData = TableMgr:GetClimbReward(levelData.chapterID)
				if rewardData ~= nil then
					ScreenListItem.specialRewardRoot.localPosition = ScreenListItem.cfg.rewardLocalPosition
					ScreenListItem.specialRewardRoot.gameObject:SetActive(true)
					ScreenListItem.specialRewardIcon.mainTexture = ResourceLibrary:GetIcon("Chapter/", rewardData.AwardIcon)
					ScreenListItem.specialRewardAnim:Play("item_daiji")
					ScreenListItem.specialRewardApplyGetEffect.gameObject:SetActive(false)
					local state1 = false
					local state2 = false
					local state3 = false 
					local take  =false
					local climb_quset = ClimbData.GetQuestData()
					if climb_quset ~= nil then
						if climb_quset[levelData.chapterID] ~= nil then
							local conditions = {}
							if climb_quset[levelData.chapterID].conditions ~= nil then
								state1 = climb_quset[levelData.chapterID].conditions[rewardData.Condition1] ~= nil 
								state2 = climb_quset[levelData.chapterID].conditions[rewardData.Condition2] ~= nil 
								state3 = climb_quset[levelData.chapterID].conditions[rewardData.Condition3] ~= nil 
								take = climb_quset[levelData.chapterID].take
							end
						end
					end
					if take then
						ScreenListItem.specialRewardRoot.gameObject:SetActive(false)
					else
						if state1 and state2 and state3 then
							ScreenListItem.specialRewardApplyGetEffect.gameObject:SetActive(true)
						end	
					end

					--ScreenListItem.specialRewardIcon:MakePixelPerfect()	
				else
					ScreenListItem.specialRewardRoot.gameObject:SetActive(false)
				end
			else
				ScreenListItem.specialRewardRoot.gameObject:SetActive(false)
			end
			local l = level_show and 1 or 0
			l = l + (level_reward_show and 1 or 0)
			--l = l + (reward_show and 1 or 0)
			ScreenListItem.levelLabelRoot.gameObject:SetActive(l ~= 0)
			if HadReward ~= 0 and level_reward_show and _ui.Map.Car.CurLevel == ScreenListItem.level then
				ScreenListItem.levelRewardAnim:Play("levelItem")
				local level_data = GetClimbLevel(ChapterID,_ui.Map.Car.CurLevel);--TableMgr:GetClimbLevel(ChapterID,math.max(1,_ui.Map.Car.CurLevel-PreLayerCount))
				if level_data ~= nil then
					if RewardCoroutine == nil then
						RewardCoroutine = coroutine.start(function()
							coroutine.step()
							coroutine.step()
							local specify_id ={}
							specify_id[17] = 1	
							print("RefrushLevelInfo",HadReward,level_reward_show,_ui.Map.Car.CurLevel , ScreenListItem.level)
							Global.ShowReward4DropId(level_data.NormalShowDropId,_ui.ScreenMap[_ui.Map.Car.CurLevel].levelRwardIcon.gameObject,nil)
							RewardCoroutine = nil
						end)
					end
				end
			end
		else
			ScreenListItem.root_trf.gameObject:SetActive(false)
		end

	--end
	--[[
	if ScreenListItem.level >= _ui.Map.Car.TargetLevel then
		ScreenListItem.root_trf.gameObject:SetActive(true)

		ScreenListItem.root_trf.gameObject:SetActive(false)
	else
		ScreenListItem.root_trf.gameObject:SetActive(false)
	end
	]]
end

function ResetLevelPos(pos)
	pos.x = _ui.Map_bg_Total_width/2
	pos.y = -1000
	return pos
end

function RefrushScreen()
	if _ui == nil then
		return
	end
	if _ui.targetScreenIndexs == nil then
		return
	end
	if _ui.ScreenList == nil then
		return
	end
	_ui.ScreenMap = nil
	for i = 1,3 do
		if _ui.targetScreenIndexs[i] ~= _ui.ScreenList[i].screen_index then
			_ui.ScreenList[i].screen_index = _ui.targetScreenIndexs[i]
			local start_level = _ui.ScreenList[i].screen_index * ScreenLevelCount + StartLevel -1
			for j = 1,#_ui.ScreenList[i].items do
				local pos = _ui.ScreenList[i].items[j].root_trf.localPosition
				local level = start_level + j -1 
				
				if _ui.ScreenList[i].screen_index >= 0 then
					pos.x = _ui.ScreenList[i].screen_index*_ui.Map.Map_bg_width + _ui.ScreenList[i].items[j].cfg.localValue*_ui.Map.Map_bg_width
					pos.y = _ui.ScreenList[i].items[j].cfg.localPosY
					if _ui.ScreenMap == nil then
						_ui.ScreenMap = {}
					end
					_ui.ScreenMap[level] = _ui.ScreenList[i].items[j]
				else
					pos = ResetLevelPos(pos)
					--level = -1
				end
				if _ui.ScreenList[i].items[j].level ~= level then
					_ui.ScreenList[i].items[j].level = level
					RefrushLevelInfo(_ui.ScreenList[i].items[j])
				end
				_ui.ScreenList[i].items[j].root_trf.localPosition = pos
			end
		end
	end
end

function RefrushLevel(force )
	for i =1,3 do
		_ui.targetScreenIndexs[i] = _ui.ScreenIndex + ScreenNeighborIndex[i]
	end
	if force then
		for i = 1,3 do
			_ui.ScreenList[i].screen_index = -1
			for j = 1,#_ui.ScreenList[i].items do
				_ui.ScreenList[i].items[j].level = -1
			end
		end
	end
	RefrushScreen()
end

function OnClickLevelInfo(level_id)
	if ClimbData.isPerfectLevel(level_id) then
		local level_data = TableMgr:GetClimbLevel4Id(level_id)
		local level_index = GetClimbDataOrder(ChapterID,level_id)
		local server_level_index = GetClimbDataOrder(ChapterID,ClimbData.GetCurServerLevel())
		SectionRewards.ShowCustom(level_data.NormalShowDropId,function(_sr_ui)
			_sr_ui.hintRoot.gameObject:SetActive(false)
			_sr_ui.hintClimbRoot.gameObject:SetActive(true)
			_sr_ui.title.text = TextMgr:GetText("rebel_28")
			_sr_ui.hintClimbLabel.text = System.String.Format(TextMgr:GetText("Climb_ui20"), level_index)
			_sr_ui.rewardButton.gameObject:SetActive(false)
		end)
	else
		ClimbInfo.Show(level_id)
	end
end

function OnClickRewardInfo(level)
	ClimbReward.Show(level)
end

function InitMapSize( totalLevelCount)
	if _ui.Map == nil then
		return
	end
	local screen_Count = math.ceil( totalLevelCount / ScreenLevelCount) --LevelCount2ScreenIndex(totalLevelCount)
	_ui.Map_bg_Total_width = screen_Count * _ui.Map.Map_bg_width + 300
	_ui.Map.Map_bg.width = _ui.Map_bg_Total_width 
	_ui.ScreenWidth = _ui.MapPanel.finalClipRegion.z
	

	if _ui.levelCfgRoot ~= nil then
		if _ui.levelCfg == nil then
			_ui.levelCfg = {}
			local root_pos = _ui.levelRoot.localPosition
			for i = 0,_ui.levelCfgRoot.childCount-1 do
				local trf = _ui.levelCfgRoot:GetChild(i)
				local reward_trf = trf:Find("reward")
				_ui.levelCfg[i+1] = {}
				_ui.levelCfg[i+1].localPosY = trf.localPosition.y - root_pos.y 
				_ui.levelCfg[i+1].localValue = (_ui.Map.Map_bg_width/2 + trf.localPosition.x) / _ui.Map.Map_bg_width 
				_ui.levelCfg[i+1].rewardLocalPosition = reward_trf.localPosition
				local level_item_trf = trf:Find("levelItem (1)")
				local level_trf = trf:Find("levelItem (1)/Texture")
				_ui.levelCfg[i+1].levelIconLocalPosition = level_trf.localPosition + level_item_trf.localPosition
				level_trf = trf:Find("levelItem (1)/item")
				_ui.levelCfg[i+1].levelRewardIconLocalPosition = level_trf.localPosition + level_item_trf.localPosition
				level_trf = trf:Find("levelItem (1)/frame_level")
				_ui.levelCfg[i+1].levelNameLocalPosition = level_trf.localPosition + level_item_trf.localPosition
			end	
		end
		
		if _ui.ScreenList == nil then
			_ui.ScreenList ={}
			_ui.ScreenMap = nil
			for i =1,3 do
				_ui.ScreenList[i] = {}
				_ui.ScreenList[i].items = {}
				for j = 1,_ui.levelCfgRoot.childCount do
					_ui.ScreenList[i].items[j] = {}
					_ui.ScreenList[i].items[j].level = -1
					_ui.ScreenList[i].items[j].cfg = _ui.levelCfg[j]
					_ui.ScreenList[i].items[j].root_trf = NGUITools.AddChild(_ui.levelRoot.gameObject , _ui.levelItemPrefab.gameObject).transform
					_ui.ScreenList[i].items[j].root_trf.gameObject:SetActive(true)

					_ui.ScreenList[i].items[j].levelIcon = _ui.ScreenList[i].items[j].root_trf:Find("Texture"):GetComponent("UITexture")
					_ui.ScreenList[i].items[j].levelRward = _ui.ScreenList[i].items[j].root_trf:Find("item")
					_ui.ScreenList[i].items[j].levelRewardAnim = _ui.ScreenList[i].items[j].levelRward:GetComponent("Animator")
					_ui.ScreenList[i].items[j].levelRwardIcon = _ui.ScreenList[i].items[j].levelRward:Find("item"):GetComponent("UITexture")
					_ui.ScreenList[i].items[j].levelRwardOpenIcon = _ui.ScreenList[i].items[j].levelRward:Find("item/item (1)"):GetComponent("UITexture")
					_ui.ScreenList[i].items[j].levelLabelRoot = _ui.ScreenList[i].items[j].root_trf:Find("frame_level")
					_ui.ScreenList[i].items[j].levelLabel = _ui.ScreenList[i].items[j].root_trf:Find("frame_level/Label"):GetComponent("UILabel")
					_ui.ScreenList[i].items[j].specialRewardRoot = _ui.ScreenList[i].items[j].root_trf:Find("reward")
					_ui.ScreenList[i].items[j].specialRewardAnim = _ui.ScreenList[i].items[j].specialRewardRoot:Find("item"):GetComponent("Animator")
					_ui.ScreenList[i].items[j].specialRewardApplyGetEffect = _ui.ScreenList[i].items[j].specialRewardRoot:Find("kelingqu")
					_ui.ScreenList[i].items[j].specialRewardIcon = _ui.ScreenList[i].items[j].specialRewardRoot:Find("item/item"):GetComponent("UITexture")
					_ui.ScreenList[i].items[j].specialRewardOpenIcon = _ui.ScreenList[i].items[j].specialRewardRoot:Find("item/item/item (1)"):GetComponent("UITexture")
				
					local pos = _ui.ScreenList[i].items[j].root_trf.localPosition
					pos = ResetLevelPos(pos)
					_ui.ScreenList[i].items[j].root_trf.localPosition = pos

					SetClickCallback(_ui.ScreenList[i].items[j].levelIcon.gameObject,function() 
						local levelData = TableMgr:GetClimbLevel4Id(_ui.ScreenList[i].items[j].level)
						OnClickLevelInfo(levelData.id)
				 	end)
				 	SetClickCallback(_ui.ScreenList[i].items[j].levelRwardIcon.gameObject,function() 
						local levelData = TableMgr:GetClimbLevel4Id(_ui.ScreenList[i].items[j].level)
						OnClickLevelInfo(levelData.id)
				 	end)
				 	SetClickCallback(_ui.ScreenList[i].items[j].specialRewardIcon.gameObject,function() 
						local levelData = TableMgr:GetClimbLevel4Id(_ui.ScreenList[i].items[j].level)
						OnClickRewardInfo(levelData.id)
				 	end) 
				end
				_ui.ScreenList[i].screen_index = -1
			end	
		else
			for i =1,3 do
				for j = 1,_ui.levelCfgRoot.childCount do
					local pos = _ui.ScreenList[i].items[j].root_trf.localPosition
					pos = ResetLevelPos(pos)
					_ui.ScreenList[i].items[j].root_trf.localPosition = pos					
				end
				_ui.ScreenList[i].screen_index = -1
			end
		end
	end
	_ui.Map.MapScrollView:ResetPosition()
end

function Level2Pos(level)
	level = level - StartLevel +1
	local c =  LevelCount2ScreenIndex( level )
	local i = level%ScreenLevelCount+1	
	return _ui.levelCfg[i].localValue*_ui.Map.Map_bg_width + c*_ui.Map.Map_bg_width
end

function SetCarPos(pos)
	local p = ((pos % _ui.Map.Map_bg_width)/_ui.Map.Map_bg_width)
	_ui.Map.Car.AnimState.enabled = true
	_ui.Map.Car.AnimState.weight = 1;
	_ui.Map.Car.AnimState.normalizedTime = p
	_ui.Map.Car.Anim:Sample();
	_ui.Map.Car.AnimState.enabled =  false
	_ui.Map.Car.Pos = _ui.Map.Car.Root.localPosition
	_ui.Map.Car.Pos.x = pos 
	_ui.Map.Car.Root.localPosition = _ui.Map.Car.Pos
end

function SetCarLevel(level,pos)
	SetCarPos(pos)
	_ui.Map.Car.NeedMove = false
	_ui.Map.Car.CurLevel = level
	_ui.Map.Car.TargetLevel = level
	_ui.Map.Car.Root.localPosition = _ui.Map.Car.Pos
end



function SetCameraPos(pos)
	_ui.MapProgress.value = AdjustPos4Progress(pos)
	OnValueChange()	
end

function SetCurLevel(level,need_update_car)
	local total_level = EndLevel
	local l = level
	if level > total_level then
		l = total_level
	end
	local pos = Level2Pos(l)
	if need_update_car then
		--print("PPPPPPPPPPPPPPPPPPPPPPPPPP1111111111",pos,level)
		SetCarLevel(level,pos)
	end	
	SetCameraPos(pos)
	--print("TTTTTTTTTTTTTTTTTTT",_ui.Map.Car.TargetLevel)
end

function LookAtCar()
	local car_pos = _ui.Map.Car.Pos.x
	SetCameraPos(car_pos)
end

function LookAtCarSmooth()
	_ui.NeedCameraFollow = true
	_ui.NeedLookAtSmooth = true
	_ui.FollowTime = -1
end

function ForceRefrushLevel(level)
	if _ui.ScreenMap ~= nil and _ui.ScreenMap[level] ~= nil then
		RefrushLevelInfo(_ui.ScreenMap[level])
	end
	
end

function RefrushScreenPos(screenPos,use_car)
	if use_car then
		_ui.CarScreenPos = screenPos
	else
		_ui.ScreenPos = screenPos
	end
	
	if screenPos <= ShowUpperLayerOffset then
		if CurLayer > 1 and CurLayer <= TotalLayer then
			_ui.upperLayer.gameObject:SetActive(true)
			_ui.nextLayer.gameObject:SetActive(false)			
		else
			_ui.upperLayer.gameObject:SetActive(false)
			_ui.nextLayer.gameObject:SetActive(false)			
		end

	elseif screenPos >= _ui.Map_bg_Total_width - ShowNextLayerOffset then	
		if CurLayer < TotalLayer then
			_ui.upperLayer.gameObject:SetActive(false)
			_ui.nextLayer.gameObject:SetActive(true)			
		else
			_ui.upperLayer.gameObject:SetActive(false)
			_ui.nextLayer.gameObject:SetActive(false)			
		end			
	else
		_ui.upperLayer.gameObject:SetActive(false)
		_ui.nextLayer.gameObject:SetActive(false)		
	end

	local screen_index = Pos2ScreenIndex(screenPos,_ui.Map.Map_bg_width)
	if screen_index ~= _ui.ScreenIndex then
		_ui.ScreenIndex = screen_index
		local car_index = Pos2ScreenIndex(_ui.Map.Car.Pos.x,_ui.Map.Map_bg_width)
		--print("Carrrrrrrrrrr",_ui.ScreenIndex , car_index)
		local offset = _ui.ScreenIndex - car_index
		local islook = false
		if offset > 0 then
			if offset < 1 then
				islook = true
			else
				islook = false
			end
		else
			if offset > -2 then
				islook = true
			else
				islook = false
			end
		end
		if CarLayer == CurLayer then
			if islook then
				_ui.firePoint.gameObject:SetActive(false)
			else
				local p = _ui.firePoint.localPosition
				local left = false
				if _ui.ScreenIndex - car_index > 0 then
					p.x = FirePointOffset*-1
					left = true
				else
					p.x = FirePointOffset
				end
				if left then
					_ui.firePoint_left.gameObject:SetActive(true)
					_ui.firePoint_right.gameObject:SetActive(false)
				else
					_ui.firePoint_left.gameObject:SetActive(false)
					_ui.firePoint_right.gameObject:SetActive(true)		
				end
				_ui.firePoint.localPosition = p
				_ui.firePoint.gameObject:SetActive(true)
			end
		else
			local p = _ui.firePoint.localPosition
			local left = false		
			if CarLayer < CurLayer then
				p.x = FirePointOffset*-1
				left = true								
			else
				p.x = FirePointOffset
			end
			if left then
				_ui.firePoint_left.gameObject:SetActive(true)
				_ui.firePoint_right.gameObject:SetActive(false)
			else
				_ui.firePoint_left.gameObject:SetActive(false)
				_ui.firePoint_right.gameObject:SetActive(true)		
			end
			_ui.firePoint.localPosition = p			
			_ui.firePoint.gameObject:SetActive(true)
		end
		RefrushLevel()
	end
end

function GetScreenPos()
	local v = _ui.MapProgress.value
	local pos = v*(_ui.Map_bg_Total_width - _ui.ScreenWidth)
	return pos
end

OnValueChange = function()
	RefrushScreenPos(GetScreenPos() ,false)
end

function OnCarMoveStart()

	_ui.tips.gameObject:SetActive(true)
	if _ui.ScreenMap == nil or _ui.ScreenMap[_ui.Map.Car.CurLevel] == nil then
		return
	end	
	local level_data = GetClimbLevel(ChapterID,_ui.Map.Car.CurLevel); --TableMgr:GetClimbLevel(ChapterID,math.max(1,_ui.Map.Car.CurLevel-PreLayerCount))
	local open = false
	if level_data ~= nil then
		local level_id,arrive,pass = GetCurLevelAndState()
		local order = GetClimbDataOrder(ChapterID,level_id)
		
		if _ui.Map.Car.CurLevel == order then
			if HadReward ~= 0 then
				open = false
				--Global.ShowReward4DropId(level_data.NormalShowDropId,_ui.ScreenMap[_ui.Map.Car.CurLevel].levelRwardIcon.gameObject)
			end
		else
			open = true
			local specify_id ={}
			specify_id[17] = 1			
			print("OnCarMoveStart",_ui.Map.Car.CurLevel , order )
			Global.ShowReward4DropId(level_data.NormalShowDropId,_ui.ScreenMap[_ui.Map.Car.CurLevel].levelRwardIcon.gameObject,nil)
		end

	end
	RefrushLevelInfo(_ui.ScreenMap[_ui.Map.Car.CurLevel],open)
end

function AutoMoveCar(is_go)
	local cur_level  = _ui.Map.Car.CurLevel
	local total_level = EndLevel

	if cur_level <= total_level then
		local level_data = GetClimbLevel(ChapterID,cur_level); --TableMgr:GetClimbLevel(ChapterID,math.max(1,cur_level-PreLayerCount))
		local server_level_index = GetClimbDataOrder(ChapterID,ClimbData.GetCurServerLevel())
		local show_reward = level_data.chapterID ~= 0 
		local climb_quest = ClimbData.GetQuestData()
		if climb_quest[level_data.chapterID] ~= nil and climb_quest[level_data.chapterID].take then
			show_reward = false
		end		
		show_reward = false -- 遇到特殊奖励不停车	
		if is_go then
			if server_level_index == nil then
				server_level_index = 1
			end		
		else
			if _ui.Map.Car.CurLevel > 1 then
				if server_level_index == nil then
					server_level_index = 1
				end		
			else
				if server_level_index == nil then
					return
				end				
			end
		end

		if server_level_index == 0 then
			server_level_index = 1
		else
			server_level_index = server_level_index + 1
		end
		--print("AAAAAAAAAAAAAAAAAAAAAAAAA",cur_level,server_level_index,ClimbData.isPerfectLevel(level_data.id),_ui.Map.Car.NeedMove)
		if cur_level > server_level_index then
			cur_level = server_level_index
			local cur_Level = server_level_index - 1
			if cur_Level < 0 then
				cur_Level = 0
			end
			if cur_level < 0 then
				cur_level = 1
			end		
			SetCurLevel(cur_Level,true)
			SetCarMove2Level(cur_level)
		else

			local level_id,arrive,pass = GetCurLevelAndState()
			local order = GetClimbDataOrder(ChapterID,level_id)	
			local level_pass = false
			if _ui.Map.Car.CurLevel == order then
				level_pass = pass
			end
				--print("WWWWWWWWWWWWWWWWWW",level_pass,_ui.Map.Car.CurLevel,arrive,pass, order,ClimbData.isPerfectLevel(level_data.id),not show_reward)
			if (ClimbData.isPerfectLevel(level_data.id) and not show_reward) or level_pass then
				if cur_level == total_level then
					UpdateGOAndBattleBtn()
					RefrushReplayBtn()
					if cur_level < TotalLevel then
						RefrushMap()
					end						
				else
					SetCarMove2Level(cur_level+1)
				end
			else
				local go,go_batch = UpdateGOAndBattleBtn()
				--if cur_level < TotalLevel then
				--	RefrushMap()
				--end					
			end
		end
	else
		if cur_level < TotalLevel then
			RefrushMap()
		end	
	end
end

function OnCarMoveEnd()
	_ui.tips.gameObject:SetActive(false)
	SetCarLevel(_ui.Map.Car.TargetLevel,_ui.Map.Car.TargetPos)
	if _ui.ScreenMap ~= nil and _ui.ScreenMap[_ui.Map.Car.CurLevel] ~= nil then
		local open = false
		
		if _ui.Map.Car.CurLevel == EndLevel then
			local levelData = TableMgr:GetClimbLevel4Id(_ui.ScreenMap[_ui.Map.Car.CurLevel].level)
			if ClimbData.isPerfectLevel(levelData.id) then
				open = true
				print("OnCarMoveEnd",_ui.Map.Car.CurLevel ,EndLevel,ClimbData.isPerfectLevel(levelData.id) )
				local specify_id ={}
				specify_id[17] = 1
				Global.ShowReward4DropId(levelData.NormalShowDropId,_ui.ScreenMap[_ui.Map.Car.CurLevel].levelRwardIcon.gameObject,nil)
			end
		end
		

		RefrushLevelInfo(_ui.ScreenMap[_ui.Map.Car.CurLevel],open)
	end	
	AutoMoveCar()
end

SetCarMove2Level = function(level)
	if _ui.Map.Car.CurLevel == level or _ui.Map.Car.CurLevel > level then
		return
	end
	if _ui.Map.Car.NeedMove then
		return
	end
	_ui.Map.Car.TargetLevel = level
	_ui.Map.Car.TargetPos = Level2Pos(level)
	
	local dis = _ui.Map.Car.TargetPos  - _ui.Map.Car.Pos.x
	local levelData = TableMgr:GetClimbLevel4Id(level)

	if levelData ~= nil then
		_ui.Map.Car.MoveTotalTime = levelData.MoveTime +1 ;
		_ui.Map.Car.MoveTime = 0		
		CarSpeed = dis / (levelData.MoveTime +1)
		CameraFollowSpeed = CarSpeed*1.5
	end	
	_ui.Map.Car.NeedMove = true
	_ui.NeedCameraFollow = true
	_ui.NeedLookAtSmooth = false
	OnCarMoveStart()
end

local startfollow = false
function UpdateCameraFollowCar()
	if CurLayer ~= CarLayer then
		return
	end	
	if not _ui.Dragging and _ui.FollowTime > 0 then
		_ui.FollowTime = _ui.FollowTime - GameTime.deltaTime
	end
	startfollow = false	
	--_ui.Map.Car.NeedMove and
	if _ui.NeedCameraFollow and not _ui.Dragging and _ui.FollowTime <= 0 then
		if _ui.CarScreenPos == nil then
			_ui.CarScreenPos = _ui.ScreenPos
			startfollow = true
		end
		
		local targetPos = _ui.Map.Car.Pos.x

		local screenPos = _ui.CarScreenPos
		if screenPos == 0 then
			screenPos = _ui.ScreenWidth / 2
			if targetPos < screenPos then
				if not _ui.Map.Car.NeedMove then
					_ui.NeedCameraFollow = false
					_ui.NeedLookAtSmooth = false	
				end
				return
			end
		elseif screenPos > _ui.Map_bg_Total_width - _ui.ScreenWidth then
			screenPos =_ui.Map_bg_Total_width - _ui.ScreenWidth
			if targetPos > screenPos then
				if not _ui.Map.Car.NeedMove then
					_ui.NeedCameraFollow = false
					_ui.NeedLookAtSmooth = false	
				end
				return
			end
		else
			screenPos = screenPos + _ui.ScreenWidth / 2
		end		

		local car_index = Pos2ScreenIndex(targetPos,_ui.Map.Map_bg_width)
		local enable_follow = math.abs(car_index - _ui.ScreenIndex)<=2 and  math.abs(targetPos - screenPos) > 0.1 
		if _ui.NeedLookAtSmooth then
			enable_follow = math.abs(targetPos - screenPos) > 0.1 
		end
		if enable_follow then
			local offset  = (targetPos - screenPos)
			if _ui.NeedLookAtSmooth then
				_ui.FollowSpeed = math.min(_ui.FollowSpeed*5 + AdSpeed*10,CameraFollowSpeed*30)
			else
				_ui.FollowSpeed = math.min(_ui.FollowSpeed + AdSpeed*10,CameraFollowSpeed)
			end
			
			local dis = _ui.FollowSpeed * GameTime.deltaTime
			if math.abs(offset) < dis then
				dis = offset
			else
				dis = dis*(offset>=0 and 1 or -1)
			end
			local next_pos = (screenPos + dis)
			if startfollow then
			end
			
			_ui.MapProgress.value = AdjustPos4Progress(next_pos)		
			RefrushScreenPos( GetScreenPos(),true)
			return
		else
			_ui.NeedCameraFollow = false
			_ui.NeedLookAtSmooth = false
		end	
	end
	
	_ui.FollowSpeed = 0
	_ui.CarScreenPos = nil
end



function UpdateCarMoving()
	if CurLayer ~= CarLayer then
		return
	end
	if not _ui.Map.Car.NeedMove then
		return
	end
	local dt = GameTime.deltaTime
	_ui.Map.Car.MoveTime = _ui.Map.Car.MoveTime + dt
	_ui.tips_label.text = System.String.Format(TextMgr:GetText("Climb_ui9"), _ui.Map.Car.MoveTotalTime - math.floor(_ui.Map.Car.MoveTime),_ui.Map.Car.TargetLevel) 
	local dis = CarSpeed * dt
	local next_pos = _ui.Map.Car.Pos.x + dis
	--[[ 
	print("Car",_ui.Map.Car.MoveTotalTime , 
	math.floor(_ui.Map.Car.MoveTime),
	_ui.Map.Car.MoveTotalTime - math.floor(_ui.Map.Car.MoveTime),dis,next_pos,_ui.Map.Car.TargetPos,_ui.Map.Car.TargetLevel,_ui.Map.Car.CurLevel)
	]]	
	if next_pos >= _ui.Map.Car.TargetPos then

		OnCarMoveEnd()
		return
	end
	SetCarPos(next_pos)
end

function onDragStarted()
	_ui.Dragging = true
	_ui.NeedCameraFollow = false
	_ui.NeedLookAtSmooth = false
	_ui.FollowTime = FollowWaitTime;
end

function onDragFinished()
	_ui.Dragging = false
	if _ui.Map.Car.NeedMove then
		_ui.NeedCameraFollow = true
	end
end

function GetCurLevelAndState()
	local climb_info = ClimbData.GetClimbInfo()
	local level = climb_info.climbInfo.lastPassStage
	local curTime = Serclimax.GameTime.GetSecTime()
	local pass = false
	local arrive = false
	if climb_info.climbInfo.nextArriveTime == 0 then
		arrive = true
		pass = true
	else
		if climb_info.climbInfo.nextArriveTime >= curTime then
			arrive = false
			pass = true
		else
			arrive = true
			pass = false
		end
	end
	return level,arrive,pass
end


function LoadMap(layer)
	if _ui == nil then
		return 
	end
	_ui.targetScreenIndexs = {-1,-1,-1}
	_ui.Map = {}
	_ui.Map.MapScrollView = transform:Find("Container/ClimbMap/map"):GetComponent("UIScrollView")
	_ui.MapProgress = _ui.Map.MapScrollView.gameObject:GetComponent("UIProgressBar")
	_ui.MapPanel = _ui.Map.MapScrollView.gameObject:GetComponent("UIPanel")
	_ui.levelCfgRoot = transform:Find("Container/ClimbMap/map/map_root_2d/levelCfg")
	_ui.levelRoot = transform:Find("Container/ClimbMap/map/map_root_2d/level")
	_ui.levelItemPrefab = transform:Find("Container/ClimbMap/levelItem")
	ScreenLevelCount = _ui.levelCfgRoot.childCount
	EventDelegate.Add(_ui.MapProgress.onChange,EventDelegate.Callback(function(obj,delta)
		OnValueChange()
	end))	
	_ui.Map.MapScrollView.onDragStarted = onDragStarted
	_ui.Map.MapScrollView.onDragFinished = onDragFinished
	_ui.Dragging = false
	_ui.Map.MapScrollView.onDragMove =  onMomentumMove
	_ui.Map.Map_bg = transform:Find("Container/ClimbMap/map/map_root_2d"):GetComponent("UITexture")
	_ui.Map.Map_bg_width = 760 -- _ui.Map.Map_bg.mainTexture.width;
	
	_ui.Map.Car = {}
	_ui.Map.Car.CurLevel = 0
	_ui.Map.Car.TargetLevel = 0
	_ui.Map.Car.TargetPos = 0;
	_ui.Map.Car.MoveTotalTime = 0;
	_ui.Map.Car.MoveTime = 0
	_ui.Map.Car.NeedMove = false
	_ui.Map.Car.Root = transform:Find("Container/ClimbMap/map/map_root_2d/car/Sprite")
	_ui.Map.Car.Pos =_ui.Map.Car.Root.localPosition
	_ui.Map.Car.Pos.x = 0
	
	_ui.Map.Car.Anim = _ui.Map.Car.Root:GetComponent("Animation")
	_ui.Map.Car.AnimState = _ui.Map.Car.Anim:get_Item("CarMove")

	_ui.WantScreenIndex = 0;
	_ui.WantScreenPos = 0;
	_ui.ScreenIndex = -1;
	_ui.ScreenPos = 0;
	_ui.FollowTime = FollowWaitTime;
	_ui.FollowSpeed = 0
	_ui.CarScreenPos = nil;
	_ui.NeedCameraFollow = false
	_ui.NeedLookAtSmooth = false

	TotalLevel = TableMgr:GetClimpChapterLevelTotalCount()
	TotalLayer = TableMgr:GetClimbLayerTotalCount()

	local climb_info = ClimbData.GetClimbInfo()
	local level = 1
	local level_id,arrive,pass = GetCurLevelAndState()
	local level_data = TableMgr:GetClimbLevel4Id(level_id)
	local order = nil
	local prePreLayerCount = 0
	if level_data ~= nil then
		ChapterID = level_data.ClimbChapterId	
		preChapterId = ChapterID
		order = TableMgr:GetClimbDataOrder(ChapterID,level_id) 
	end
	if order == nil then
		order = 1
		ChapterID = TableMgr:ClimbLayerIndexToId(1)
		level_data = TableMgr:GetClimbLevel(ChapterID,1)
	else
		if  not pass then
			order = order + 1
			level_data = TableMgr:GetClimbLevel(ChapterID,order)
			if level_data == nil then
				local layer_index = TableMgr:ClimbLayerIdToIndex(ChapterID)
				layer_index = layer_index + 1
				if layer_index <= TotalLayer and layer_index >= 1 then
					local layer_id = TableMgr:ClimbLayerIndexToId(layer_index -1)
					local table_data = TableMgr:GetClimbChapter(layer_id)
					prePreLayerCount = #table_data
					ChapterID = TableMgr:ClimbLayerIndexToId(layer_index)
					level_data = TableMgr:GetClimbLevel(ChapterID,1)
				else
					order = order - 1
				end
			end
		end		

		if not arrive then
			local _table_data = TableMgr:GetClimbChapter(ChapterID)
			local _layer_level_count = #_table_data		
			if _layer_level_count == order then
			else
				order = math.max(1,order - 1)  
				level_data = TableMgr:GetClimbLevel(ChapterID,order)
				if level_data == nil then
					local layer_index = TableMgr:ClimbLayerIdToIndex(ChapterID)
					layer_index = layer_index - 1
					if layer_index <= TotalLayer and layer_index >= 1 then
						ChapterID = TableMgr:ClimbLayerIndexToId(layer_index)
						level_data = TableMgr:GetClimbLevel(ChapterID,#TableMgr:GetClimbChapter(ChapterID))
					end
				end					
			end	
		end 		
	end




	if layer ~= nil then
		if layer <= TotalLayer and layer >= 1 then
			ChapterID = TableMgr:ClimbLayerIndexToId(layer)
			CurLayer = layer
		else
			CurLayer =TableMgr:ClimbLayerIdToIndex(ChapterID)
			--CurLayer = math.max(1,math.ceil(order / PreLayerCount))
			CarLayer = CurLayer			
		end		
	else
		CurLayer =TableMgr:ClimbLayerIdToIndex(ChapterID)
		--CurLayer = math.max(1,math.ceil(order / PreLayerCount))
		CarLayer = CurLayer
	end

	
	
	local table_data = TableMgr:GetClimbChapter(ChapterID)
	local layer_level_count = #table_data
	local start_level_data = TableMgr:GetClimbLevel(ChapterID,1)
	local end_level_data = TableMgr:GetClimbLevel(ChapterID,layer_level_count)
	PreLayerCount = TableMgr:GetClimbLayerStartLevelCount(CurLayer)

	

	--StartLevel = ((CurLayer -1) * PreLayerCount)+1;
	--EndLevel = math.min(TotalLevel, CurLayer * PreLayerCount)
	StartLevel = TableMgr:GetClimbDataOrder(ChapterID,start_level_data.id) + PreLayerCount
	EndLevel = TableMgr:GetClimbDataOrder(ChapterID,end_level_data.id) + PreLayerCount
	print("Level ",StartLevel,EndLevel,layer_level_count,ChapterID,start_level_data.id,end_level_data.id)
	_ui.upperLayer.gameObject:SetActive(false)
	_ui.nextLayer.gameObject:SetActive(false)
	_ui.Map.Map_bg.mainTexture =  ResourceLibrary:GetIcon("Chapter/", "bg_climb"..ChapterID) --ResourceLibrary:GetBg(bg_texture_names[CurLayer])
	_ui.layerText.text = TextMgr:GetText("climb_layer"..ChapterID)
	InitMapSize(layer_level_count+1)



	if CarLayer ~= CurLayer then
		--print("wwwwwwwwwwwwwwwwwwwww",order ,TableMgr:GetClimbLayerStartLevelCount(CarLayer))
		order = order + TableMgr:GetClimbLayerStartLevelCount(CarLayer)
		_ui.Map.Car.Root.gameObject:SetActive(false)
	else
		--print("wwwwwwwwwwwwwwwwwwwww",order , PreLayerCount , prePreLayerCount)
		order = order + PreLayerCount - prePreLayerCount
		_ui.Map.Car.Root.gameObject:SetActive(true)
	end
	if order == 1 and climb_info.climbInfo.status == 0 then
		SetCurLevel(0,true)
		SetCarMove2Level(order)
	else
		SetCurLevel(order,true)
		if not arrive then
			SetCarMove2Level(order + 1)					
		end
	end
	RefrushLevel(true)
end

function Hide()
    Global.CloseUI(_M)
end

function RefrushIcon()
	local climb_info = ClimbData.GetClimbInfo()
	if climb_info ~= nil then
		--print("SSSSSSSSSSSSSSSScore    ",climb_info.climbInfo.climbScore)
		--_ui.coin_num.text = climb_info.climbInfo.climbScore
		_ui.coin_num.text = Global.ExchangeValue(MoneyListData.GetMoneyByType(Common_pb.MoneyType_ClimbCoin))
	end
	--
end

function RefrushCount()
	local climb_info = ClimbData.GetClimbInfo()
	if climb_info == nil then
		return
	end
	local buy_count = CountListData.GetBuyClimbCount()
	if buy_count == nil then
		_ui.count.text = System.String.Format(TextMgr:GetText("climb_layer6"), climb_info.climbInfo.count.count)
		return
	end
	if climb_info.climbInfo.count.count == 0 then
		_ui.count.text = System.String.Format(TextMgr:GetText("climb_layer7"), buy_count.count) 
		return
	end
	if buy_count.countmax == buy_count.count then
		_ui.count.text = System.String.Format(TextMgr:GetText("climb_layer6"), climb_info.climbInfo.count.count) 
	else
		--今日剩余演习次数：N
		_ui.count.text = System.String.Format(TextMgr:GetText("Climb_ui6"), climb_info.climbInfo.count.count) 
	end
end

function _RefrushMap(layer)
	LoadMap(layer)
	_ui.tips.gameObject:SetActive(false)
	local climb_info = ClimbData.GetClimbInfo()
	if climb_info ~= nil then
		
		if climb_info.climbInfo.status == 1 then
			if CarLayer == CurLayer then
				local p,l = GetNextNotPrefectLevel(_ui.Map.Car.CurLevel);
				if p then
					local go,go_batch = UpdateGOAndBattleBtn()
					if go or go_batch then
						ClimbData.ReqGoForwardClimb(function() 
							AutoMoveCar(true)
						end)		
					end
				end		
			end
			--_ui.go.gameObject:SetActive(true)
			--_ui.battle.gameObject:SetActive(false)
		else
			--_ui.go_batch.gameObject:SetActive(false)
			--_ui.go.gameObject:SetActive(false)
			_ui.battle.gameObject:SetActive(true)			
		end
	end
	RefrushReplayBtn()
	RefrushCount()
	--_ui.count.text = System.String.Format(TextMgr:GetText("Climb_ui6"), climb_info.climbInfo.count.count)  
end

RefrushMap = function(layer,callback)
	ClimbData.ReqMsgClimbInfo(function()
		if _ui == nil then
			return
		end
		_RefrushMap(layer)
		if callback ~= nil then
			callback()
		end
	end)
end

function Battle()
	if _ui == nil then
		return
	end
		--print("TTTTTTTTTTTTTT",_ui.Map.Car.CurLevel)
		if _ui.Map.Car.CurLevel ~= 0 and _ui.Map.Car.NeedMove then
			return
		end		

		local chapter_id = TableMgr:ClimbLayerIndexToId(CarLayer)
		local preLayerCount = TableMgr:GetClimbLayerStartLevelCount(CarLayer)
		local climb_info = ClimbData.GetClimbInfo()
		local level = math.max(1,_ui.Map.Car.CurLevel)
		local level_data = GetClimbLevel(chapter_id,level,preLayerCount); --TableMgr:GetClimbLevel(ChapterID,math.max(1,level-PreLayerCount))
		if climb_info.climbInfo.status == 1 then
			BattleMove.Show4Climb(level_data.id,function() 
				HadReward = 2 	
			end)
		else
			
			if climb_info.climbInfo.count.count <= 0 then
				local buy_count = CountListData.GetBuyClimbCount()
				if buy_count ~= nil then
					if buy_count.count > 0 then
						local pay_strs = TableMgr:GetGlobalData(100200).value
						local pays = string.split(pay_strs,',')

						MessageBox.Show(TextMgr:GetText("climb_layer8"),
						function() 
							ClimbData.ReqBuyClimbCount(function()
								if _ui == nil then
									return								
								end
								RefrushCount()
								BattleMove.Show4Climb(level_data.id,function()
									LoadUI()
									local go,go_batch = UpdateGOAndBattleBtn()
									if go or go_batch then
										ClimbData.ReqGoForwardClimb(function() 
											AutoMoveCar(true)
										end)		
									end				
								end)
							end)
						end,
						function() end,nil,nil,nil,nil,nil,System.String.Format(TextMgr:GetText("tili_ui3"),buy_count.count),pays[buy_count.countmax -buy_count.count + 1])
						return 
					end
				end
				MessageBox.Show(TextMgr:GetText("Climb_ui30"))
				return
			end			
			BattleMove.Show4Climb(level_data.id,function()
				LoadUI()
				local go,go_batch = UpdateGOAndBattleBtn()
				if go or go_batch then
					ClimbData.ReqGoForwardClimb(function() 
						AutoMoveCar(true)
					end)		
				end				
			end)			
		end
end

function LoadUI()	
    _ui.mask = transform:Find("mask")
	_ui.close = transform:Find("Container/Panel_top/bg_top/btn_close")
	_ui.coin_num = transform:Find("Container/Panel_top/bg_top/bg_coin/number"):GetComponent("UILabel")
	_ui.rank = transform:Find("Container/Panel_top/bg_b0ttom/rank")
	_ui.tips = transform:Find("Container/Panel_top/bg_b0ttom/tips")
	_ui.tips_label = transform:Find("Container/Panel_top/bg_b0ttom/tips/Label"):GetComponent("UILabel")
	_ui.shop =  transform:Find("Container/Panel_top/bg_b0ttom/button1")
	_ui.replay = transform:Find("Container/Panel_top/bg_b0ttom/button2")
	_ui.battle = transform:Find("Container/Panel_top/bg_b0ttom/button3")
	_ui.go = transform:Find("Container/Panel_top/bg_b0ttom/button4")
	_ui.go_batch = transform:Find("Container/Panel_top/bg_b0ttom/button5")
	_ui.help = transform:Find("Container/Panel_top/bg_b0ttom/wenhao")
	_ui.firePoint = transform:Find("Container/frane_FirePoint")
	_ui.firePoint_left = transform:Find("Container/frane_FirePoint/jiantou_left")
	_ui.firePoint_right = transform:Find("Container/frane_FirePoint/jiantou_right")
	_ui.count = transform:Find("Container/Panel_top/bg_b0ttom/text"):GetComponent("UILabel")
	_ui.upperLayer = transform:Find("Container/Panel_top/UpperLayer")
	_ui.nextLayer = transform:Find("Container/Panel_top/NextLayer")
	_ui.layerText = transform:Find("Container/Panel_top/text"):GetComponent("UILabel")
	_ui.firePoint.gameObject:SetActive(false)

	_ui.go.gameObject:SetActive(false)
	_ui.go_batch.gameObject:SetActive(false)

    SetClickCallback(_ui.close.gameObject,function()
        Hide()
	end)   
	 
    SetClickCallback(_ui.mask.gameObject,function()
        Hide()
	end)   
	
	SetClickCallback(_ui.firePoint.gameObject,function()
		if CarLayer == CurLayer then
			LookAtCar()
		else
			RefrushMap();
		end
	end)  

    SetClickCallback(_ui.shop.gameObject,function()
        SlgBag.ShowClimb()
	end)   

	
	SetClickCallback(_ui.help.gameObject,function()
		GOV_Help.Show(GOV_Help.HelpModeType.CLIMB)
	end) 	

	SetClickCallback(_ui.rank.gameObject,function()
		RebelArmyAttackrank.SetScoreTextID("climb_layer9")
        RebelArmyAttackrank.ShowClimb()
	end)  

	_RefrushMap()
	RefrushHadReward()
	
	

	SetClickCallback(_ui.go.gameObject,function()
		if _ui.Map.Car.NeedMove then
			return
		end
		if _ui.Map.Car.CurLevel >= EndLevel then
			MessageBox.Show(TextMgr:GetText("Climb_ui32"))
			return
		end
		local level_data = GetClimbLevel(ChapterID,_ui.Map.Car.CurLevel);--TableMgr:GetClimbLevel(ChapterID,math.max(1,_ui.Map.Car.CurLevel-PreLayerCount))
		--if ClimbData.isPerfectLevel(level_data.id) then
			ClimbData.ReqGoForwardClimb(function() 
				AutoMoveCar(true)
			end)	
		--end
	end)

	SetClickCallback(_ui.go_batch.gameObject,function()
		if _ui.Map.Car.NeedMove then
			return
		end
		if _ui.Map.Car.CurLevel >= EndLevel then
			MessageBox.Show(TextMgr:GetText("Climb_ui32"))
			return
		end

		local p,l = GetNextNotPrefectLevel(_ui.Map.Car.CurLevel);
		if p then
			MessageBox.Show( System.String.Format( TextMgr:GetText("climb_sweep_text"), l),function()
				local level_data = GetClimbLevel(ChapterID,_ui.Map.Car.CurLevel); --TableMgr:GetClimbLevel(ChapterID,math.max(1,_ui.Map.Car.CurLevel-PreLayerCount))
				ClimbData.ReqGoForwardClimb(function() 
					AutoMoveCar(true)
				end)
			end ,function()end)
		else
			local level_data = GetClimbLevel(ChapterID,_ui.Map.Car.CurLevel); --TableMgr:GetClimbLevel(ChapterID,math.max(1,_ui.Map.Car.CurLevel-PreLayerCount))
			ClimbData.ReqGoForwardClimb(function() 
				AutoMoveCar(true)
			end)
		end
	end)

	
	SetClickCallback(_ui.battle.gameObject,function()
		Battle()
	end)

	SetClickCallback(_ui.replay.gameObject,function()
		
		MessageBox.Show(TextMgr:GetText("Climb_ui29"),function()
			ClimbData.ReqRestartClimbChapter(function(is_ok)
				if is_ok then
					LoadUI()
				end
			end)
		end,
		function() end)
	end)	
	RefrushIcon()
	local  coin = transform:Find("Container/Panel_top/bg_top/bg_coin")

	local ShowTooltip = function(go)
		if go == _ui.tipObject then
			_ui.tipObject = nil
		else
			_ui.tipObject = go
			Tooltip.ShowItemTip({name = TextMgr:GetText("item_17_name"), text = TextMgr:GetText("item_17_des")})
		end
	end
	SetClickCallback(coin.gameObject, ShowTooltip)

	SetClickCallback(_ui.upperLayer.gameObject, function()
		RefrushMap(math.max(1,CurLayer - 1));
	end)
	SetClickCallback(_ui.nextLayer.gameObject, function()
		RefrushMap(math.min(TotalLayer, CurLayer + 1));
	end)

	ClimbData.AddClimbScoreListener(RefrushIcon)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
	AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)	
	
	
end

function Awake()
	LoadUI()
end

function Update()
	if _ui == nil then
		return
	end
	UpdateCarMoving()
	UpdateCameraFollowCar()
end

function Show()
	ClimbData.ReqMsgClimbInfo(function()
		_ui = {}
		Global.OpenUI(_M)	
		--[[
		ChapterID = 1001
		local climbTableData = TableMgr:GetClimbChapter(ChapterID)
		if climbTableData ~= nil then
			_ui = {}
			_ui.climbTableData = climbTableData
			Global.OpenUI(_M)
		end
		--]]
	end)
end

function Close()
	RefrushHadReward()
	ClimbData.RemoveClimbScoreListener(RefrushIcon)
	_ui = nil
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()		
	if OnCloseCB ~= nil then
		OnCloseCB()
	end
	if RewardCoroutine ~= nil then
		coroutine.stop(RewardCoroutine)
	end
	RewardCoroutine = nil
	OnCloseCB = nil
	StartLevel = 0
	EndLevel = 0
	CurLayer = 0;
	TotalLayer= 0;
	CarLayer = 0;	
end

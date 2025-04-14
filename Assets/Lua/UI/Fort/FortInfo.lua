module("FortInfo", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr

-- fort
local subType = 0
local fort
local config
local status = 0

-- map
local mapX = -1
local mapY = -1
local tileMsg

-- timer
local animationStartTime = 0

-- animation
local enableAnimation = false
local height
local damage
local damagePercentage

local ui
local isInViewPort = false

------------- Constants -------------
local FORMAT_POSITION = "X:%d Y:%d"
local FORMAT_GUILDLABEL = "[%s]%s"
-------------------------------------

local function LoadUI()
	ui = {}

	transform:Find("Container/background/title/Label"):GetComponent("UILabel").text = TextMgr:GetText(string.format("Duke_%d", 14 + fort.subType))
	
	UIUtil.SetClickCallback(transform:Find("mask").gameObject, function()
		Global.CloseUI(_M)
	end)

	UIUtil.SetClickCallback(transform:Find("Container/background/close btn").gameObject, function()
		Global.CloseUI(_M)
	end)

	UIUtil.SetClickCallback(transform:Find("Container/bg_bottom/button01").gameObject, function()
		FortOccuRule.Show()
	end)

	UIUtil.SetClickCallback(transform:Find("Container/bg_bottom/button02").gameObject, function()
		FortRule.Show()
	end)

	UIUtil.SetClickCallback(transform:Find("Container/bg_bottom/button03").gameObject, function()
		FortHistory.Show(subType)
	end)

	ui.infoBtn = transform:Find("Container/bg_bottom/button04").gameObject
	ui.moreInfo = TileInfoMore(ui.infoBtn.transform:Find("bg_moreInfo"))
	UIUtil.SetClickCallback(ui.infoBtn, function()
		ui.moreInfo:Open(ui.infoBtn, TextMgr:GetText(string.format("Duke_%d", 14 + fort.subType)), fort.pos.x, fort.pos.y, TableMgr:GetArtSettingData(500).icon)
	end)

	ui.left = {}
	ui.left.rankList = transform:Find("Container/bg_left/RankList").gameObject
	ui.left.fortShow = transform:Find("Container/bg_left/Fort3DShow").gameObject
	ui.left[1] = transform:Find("Container/bg_left/bg_1").gameObject
	ui.left[2] = transform:Find("Container/bg_left/bg_2").gameObject

	ui.right = {}
	ui.right[1] = transform:Find("Container/bg_right01").gameObject
	ui.right[2] = transform:Find("Container/bg_right02").gameObject
	ui.right[3] = transform:Find("Container/bg_right03").gameObject

	if status <= 2 or not fort.available then -- 休战中、预告中、不开放
		-- 左半栏
		ui.left.rankList:SetActive(false)
		ui.left.fortShow:SetActive(true)
		ui.left[1]:SetActive(true)
		ui.left[2]:SetActive(false)

		ui.left[1].transform:Find("time_bg").gameObject:SetActive(fort.available and status == 2)
		ui.status = ui.left[1].transform:Find("time_bg/text02"):GetComponent("UILabel")
		ui.time = ui.left[1].transform:Find("time_bg/time"):GetComponent("UILabel")

		-- 右半栏
		ui.right[1]:SetActive(true)
		ui.right[2]:SetActive(false)
		ui.right[3]:SetActive(false)

		ui.fort = {}

		-- 位置信息跳转
		ui.fort.position = ui.right[1].transform:Find("top/text_01"):GetComponent("UILabel")
		UIUtil.SetClickCallback(ui.right[1].transform:Find("top/text_01").gameObject, function()
			MainCityUI.ShowWorldMap(fort.pos.x, fort.pos.y, true, nil)
			Global.CloseUI(_M)
		end)

		ui.right[1].transform:Find("top/text_02"):GetComponent("LocalizeEx").enabled = false
		ui.fort.ownerGuild = ui.right[1].transform:Find("top/text_02"):GetComponent("UILabel")

		ui.right[1].transform:Find("top/text_03"):GetComponent("LocalizeEx").enabled = false
		ui.fort.duke = ui.right[1].transform:Find("top/text_03"):GetComponent("UILabel")
	elseif status == 3 then -- 争夺中
		-- 左半栏
		ui.left.rankList:SetActive(true)
		ui.left.fortShow:SetActive(false)
		ui.left[1]:SetActive(false)
		ui.left[2]:SetActive(true)

		ui.left.rankList.transform:Find("none").gameObject:SetActive(#fort.contendInfo.rankList == 0)
		
		ui.rankList = {}
		for rank = 1, 3 do
			ui.rankList[rank] = {}
			ui.rankList[rank].gameObject = ui.left.rankList.transform:Find(string.format("no.%d", rank)).gameObject
			ui.rankList[rank].histogram = ui.left.rankList.transform:Find(string.format("no.%d/bar", rank)):GetComponent("UITexture")
			ui.rankList[rank].fx_histogram = ui.left.rankList.transform:Find(string.format("no.%d/frame", rank)):GetComponent("UITexture")
			ui.rankList[rank].movingLabels = ui.left.rankList.transform:Find(string.format("no.%d/moving_labels", rank)).transform
			ui.rankList[rank].label = ui.left.rankList.transform:Find(string.format("no.%d/moving_labels/label", rank)):GetComponent("UILabel")
			ui.rankList[rank].damage = ui.left.rankList.transform:Find(string.format("no.%d/moving_labels/damage", rank)):GetComponent("UILabel")
			ui.rankList[rank].damagePercentage = ui.left.rankList.transform:Find(string.format("no.%d/damagePercentage", rank)):GetComponent("UILabel")
		
			ui.rankList[rank].fx_damagePercentage = {}
			ui.rankList[rank].fx_damagePercentage.gameObject = ui.left.rankList.transform:Find(string.format("no.%d/fx_damagePercentage", rank)).gameObject
			ui.rankList[rank].fx_damagePercentage.text = ui.left.rankList.transform:Find(string.format("no.%d/fx_damagePercentage", rank)):GetComponent("UILabel")
		end
		for rank = 4, 7 do
			ui.rankList[rank] = {}
			ui.rankList[rank].label = ui.left[2].transform:Find(string.format("no.%d/label", rank)):GetComponent("UILabel")
			ui.rankList[rank].damage = ui.left[2].transform:Find(string.format("no.%d/damage", rank)):GetComponent("UILabel")
			ui.rankList[rank].damagePercentage = ui.left[2].transform:Find(string.format("no.%d/damagePercentage", rank)):GetComponent("UILabel")
		end

		-- 右半栏
		ui.right[1]:SetActive(false)
		ui.right[2]:SetActive(true)
		ui.right[3]:SetActive(false)

		ui.playerGuild = {}
		ui.playerGuild.name = ui.right[2].transform:Find("top/Label"):GetComponent("UILabel")
		ui.playerGuild.attackChance = ui.right[2].transform:Find("top/text_01"):GetComponent("UILabel")
		ui.playerGuild.totalDamage = ui.right[2].transform:Find("top/text_02"):GetComponent("UILabel")
		ui.playerGuild.damagePercentage = ui.right[2].transform:Find("top/text_03"):GetComponent("UILabel")
		ui.right[2].transform:Find("top/icon_04").gameObject:SetActive(fort.contendInfo.contendGuildInfo.rankInfo.rank ~= 0)
		ui.playerGuild.currentRank = ui.right[2].transform:Find("top/text_04"):GetComponent("UILabel")
		ui.playerGuild.lastDamage = ui.right[2].transform:Find("top/text_05"):GetComponent("UILabel")
		ui.playerGuild.highestDamage = ui.right[2].transform:Find("top/text_06"):GetComponent("UILabel")
		ui.right[2].transform:Find("top/icon_06").gameObject:SetActive(fort.contendInfo.contendGuildInfo.lastHurt == fort.contendInfo.contendGuildInfo.bestHurt)

		ui.time = ui.right[2].transform:Find("time"):GetComponent("UILabel")

		ui.scoutBtn = ui.right[2].transform:Find("button_left").gameObject
		ui.rellyBtn = ui.right[2].transform:Find("button_right").gameObject
	elseif status == 4 then --占领中
		-- 左半栏
		ui.left.rankList:SetActive(table.getn(fort.occupyInfo.rankList) ~= 0)
		ui.left.fortShow:SetActive(table.getn(fort.occupyInfo.rankList) == 0)
		ui.left[1]:SetActive(true)
		ui.left[2]:SetActive(false)

		ui.rankList = {}
		for rank = 1, 3 do
			ui.rankList[rank] = {}
			ui.rankList[rank].gameObject = ui.left.rankList.transform:Find(string.format("no.%d", rank)).gameObject
			ui.rankList[rank].histogram = ui.left.rankList.transform:Find(string.format("no.%d/bar", rank)):GetComponent("UITexture")
			ui.rankList[rank].fx_histogram = ui.left.rankList.transform:Find(string.format("no.%d/frame", rank)):GetComponent("UITexture")
			ui.rankList[rank].movingLabels = ui.left.rankList.transform:Find(string.format("no.%d/moving_labels", rank)).transform
			ui.rankList[rank].label = ui.left.rankList.transform:Find(string.format("no.%d/moving_labels/label", rank)):GetComponent("UILabel")
			ui.rankList[rank].damage = ui.left.rankList.transform:Find(string.format("no.%d/moving_labels/damage", rank)):GetComponent("UILabel")
			ui.rankList[rank].damagePercentage = ui.left.rankList.transform:Find(string.format("no.%d/damagePercentage", rank)):GetComponent("UILabel")
			
			ui.rankList[rank].fx_damagePercentage = {}
			ui.rankList[rank].fx_damagePercentage.gameObject = ui.left.rankList.transform:Find(string.format("no.%d/fx_damagePercentage", rank)).gameObject
			ui.rankList[rank].fx_damagePercentage.text = ui.left.rankList.transform:Find(string.format("no.%d/fx_damagePercentage", rank)):GetComponent("UILabel")
		end
		
		ui.left[1].transform:Find("time_bg").gameObject:SetActive(true)
		ui.left[1].transform:Find("text01").gameObject:SetActive(table.getn(fort.occupyInfo.rankList) == 0)
		ui.status = ui.left[1].transform:Find("time_bg/text02"):GetComponent("UILabel")
		ui.time = ui.left[1].transform:Find("time_bg/time"):GetComponent("UILabel")

		-- 右半栏
		ui.right[1]:SetActive(false)
		ui.right[2]:SetActive(false)
		ui.right[3]:SetActive(true)

		ui.fort = {}
		
		-- 位置信息跳转
		ui.fort.position = ui.right[3].transform:Find("top/text_01"):GetComponent("UILabel")
		UIUtil.SetClickCallback(ui.fort.position.gameObject, function()
			MainCityUI.ShowWorldMap(fort.pos.x, fort.pos.y, true, nil)
			Global.CloseUI(_M)
		end)

		ui.fort.ownerGuild = ui.right[3].transform:Find("top/text_02"):GetComponent("UILabel")
		ui.fort.duke = ui.right[3].transform:Find("top/text_03"):GetComponent("UILabel")

		if #fort.occupyInfo.rankList ~= 0 then
			ui.rewardTimeDisplay = ui.right[3].transform:Find("mid").gameObject

			local now = Serclimax.GameTime.GetSecTime()
			local nextRewardTime = now + config.occupyRewardInterval - (now - config.contendEndTime) % config.occupyRewardInterval
			ui.rewardTimeDisplay.gameObject:SetActive(nextRewardTime <= config.occupyEndTime)

			ui.rewardTime = ui.right[3].transform:Find("mid/time"):GetComponent("UILabel")
		end
	end
end

----------------- Animation Parameters -----------------
local ANIMATION_TIMESPAN = 1000

local HEIGHT_MINIMUM = 50
local HEIGHT_MAXIMUM = 220
local HEIGHT_DELTA = HEIGHT_MAXIMUM - HEIGHT_MINIMUM
local HEIGHT_DELTA_THRESHOLD = 10
local FRAME_HEIGHT_INCREASE = 27
local TEXT_Y_SHIFT = 3
local TEXT_Y_MINIMUM = 75
--------------------------------------------------------
local function EnableAnimation()
	if status == 3 or status == 4 then
		local info = status == 3 and fort.contendInfo or fort.occupyInfo

		local guildNum = math.min(3, table.getn(info.rankList))
		if guildNum == 0 then return end

		local totalDamage = 0
		for rank = 1, guildNum do
			totalDamage = totalDamage + info.rankList[rank].hurt
		end

		height = {}
		for rank = 1, guildNum do
			height[rank] = HEIGHT_MINIMUM + HEIGHT_DELTA * info.rankList[rank].hurt / totalDamage
		end

		if guildNum == 3 then
			local heightDiff12 = height[1] - height[2]
			if info.rankList[1].percent == info.rankList[2].percent and ui.rankList[1].damage.text == ui.rankList[2].damage.text then
				heightDiff12 = 0
			end
			local heightDiff23 = height[2] - height[3]
			if info.rankList[2].percent == info.rankList[3].percent and ui.rankList[2].damage.text == ui.rankList[3].damage.text then
				heightDiff23 = 0
			end

			if heightDiff12 > 0 and heightDiff12 < HEIGHT_DELTA_THRESHOLD and heightDiff23 > 0 and heightDiff23 < HEIGHT_DELTA_THRESHOLD then
				local heightDiffMin = math.min(heightDiff12, heightDiff23)
				height[1] = height[2] + HEIGHT_DELTA_THRESHOLD * heightDiff12 / heightDiffMin
				height[3] = height[2] - HEIGHT_DELTA_THRESHOLD * heightDiff23 / heightDiffMin
			elseif heightDiff12 > 0 and heightDiff12 < HEIGHT_DELTA_THRESHOLD then
				height[1] = height[2] + HEIGHT_DELTA_THRESHOLD
			elseif heightDiff23 > 0 and heightDiff23 < HEIGHT_DELTA_THRESHOLD then
				height[3] = height[2] - HEIGHT_DELTA_THRESHOLD
			end
		elseif guildNum == 2 then
			if height[1] - height[2] < HEIGHT_DELTA_THRESHOLD then
				height[1] = height[2] + HEIGHT_DELTA_THRESHOLD
			end
		end
	end

	animationStartTime = Serclimax.GameTime.GetMilSecTime()
	enableAnimation = true
end

local function SetUI()
	if status <= 2 or not fort.available then -- 休战中、预告中、不开放
		ui.status.text = TextMgr:GetText("Duke_30")

		ui.fort.position.text = string.format(FORMAT_POSITION, fort.pos.x, fort.pos.y)
		ui.fort.ownerGuild.text =  TextMgr:GetText(fort.available and "Fort_ui1" or "Fort_ui6")
		ui.fort.duke.text = TextMgr:GetText(fort.available and "Fort_ui1" or "Fort_ui6")

		if fort.available and status == 2 then
			CountDown.Instance:Add("FortInfo", config.contendStartTime, CountDown.CountDownCallBack(function(t)
				local leftTime = Global.GetLeftCooldownSecond(config.contendStartTime)
				ui.time.text = Global.SecondToTimeLong(leftTime)

				if leftTime <= 0 then
					CountDown.Instance:Remove("FortInfo")
				end
			end))
		end
	elseif status == 3 then -- 争夺中
		local rankList = fort.contendInfo.rankList
		damage = {}
		damagePercentage = {}
		for rank = 1, math.min(7, table.getn(rankList)) do
			local guild = rankList[rank]

			if rank < 4 then
				ui.rankList[rank].gameObject:SetActive(true)
				damage[rank] = guild.hurt
				damagePercentage[rank] = guild.percent
			else
				ui.rankList[rank].damage.text = Global.ExchangeValue(guild.hurt)
				ui.rankList[rank].damagePercentage.text = Global.FormatPercentageNumber(guild.percent)
			end

			ui.rankList[rank].label.text = string.format(FORMAT_GUILDLABEL, guild.guildBanner, guild.guildName)
		end

		EnableAnimation()

		local playerGuild = fort.contendInfo.contendGuildInfo
		ui.playerGuild.name = string.format(FORMAT_GUILDLABEL, playerGuild.rankInfo.guildBanner, playerGuild.rankInfo.guildName)
		ui.playerGuild.attackChance.text = string.format("%d / %d", config.attackCountLimit - playerGuild.attackcount, config.attackCountLimit)
		ui.playerGuild.totalDamage.text = Global.ExchangeValue(playerGuild.rankInfo.hurt)
		ui.playerGuild.damagePercentage.text = Global.FormatPercentageNumber(playerGuild.rankInfo.percent)
		ui.playerGuild.currentRank.text = playerGuild.rankInfo.rank == 0 and "[FFED00]--" or Global.ExchangeValue(playerGuild.rankInfo.rank)
		ui.playerGuild.lastDamage.text = Global.ExchangeValue(playerGuild.lastHurt)
		ui.playerGuild.highestDamage.text = Global.ExchangeValue(playerGuild.bestHurt)

		-- 结束争夺倒计时
		CountDown.Instance:Add("FortInfo", config.contendEndTime, CountDown.CountDownCallBack(function(t)
			local leftTime = Global.GetLeftCooldownSecond(config.contendEndTime)
			ui.time.text = Global.SecondToTimeLong(leftTime)

			if leftTime <= 0 then
				CountDown.Instance:Remove("FortInfo")
			end
		end))

		-- 侦查按钮
		UIUtil.SetClickCallback(ui.scoutBtn , function()
			if not BattleMove.CheckActionList() then
				return
			end    			
			print("侦查要塞", tileMsg ~= nil and tileMsg.data.uid or 0, mapX, mapY, Common_pb.TeamMoveType_ReconFort)
            MessageBox.Show(TileInfo.GetSpyString(2, 1), function()
	            local req = HeroMsg_pb.MsgArmySetoutStarRequest()
	            req.seUid = tileMsg ~= nil and tileMsg.data.uid or 0
	            req.pos.x = mapX
	            req.pos.y = mapY
	            req.pathType = Common_pb.TeamMoveType_ReconMonster

	            LuaNetwork.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgArmySetoutStarRequest, req:SerializeToString(), function(typeId, data)
	                local msg = HeroMsg_pb.MsgArmySetoutStarResponse()
	                msg:ParseFromString(data)
	                if msg.code ~= ReturnCode_pb.Code_OK then
	                    Global.ShowError(msg.code)
	                    Global.CloseUI(_M)
	                else
	                    MainCityUI.UpdateRewardData(msg.fresh)
	                    Global.CloseUI(_M)
	                end
	            end, false)
            end, function() end)
		end)
		
		-- 集结按钮
		UIUtil.SetClickCallback(ui.rellyBtn, function()
	        if playerGuild.attackcount < 3 then
		        local uid = fort ~= nil and fort.entryUid or 0
		        local mtc = MassTroopsCondition()
		        local x = fort.pos.x
		        local y = fort.pos.y

		        mtc.target_enable_mass = true
		        mtc.isActMonster = true
		        mtc:CreateMass4BattleCondition(function(success)
		            if success then
		                assembled_time.Show(function(time)
		                    if time ~= 0 then
		                        local building = maincity.GetBuildingByID(43)  
		                        if building ~= nil then
		                            local curAssembledData = TableMgr:GetAssembledData(building.data.level)
									mtc:ShowCreateMassBattleMove(uid, TextMgr:GetText(string.format("Duke_%d", 14 + fort.subType)), x, y, curAssembledData.armynum, time)									
		                        	Global.CloseUI(_M)
		                        end
		                    end
		                end)
		            end
		        end)
		    else
		    	Global.ShowError(ReturnCode_pb.Code_SceneMap_FortAttackLimit)
	    	end
		end)
	elseif status == 4 then -- 占领中
		local rankList = fort.occupyInfo.rankList
		damage = {}
		damagePercentage = {}
		for rank = 1, math.min(3, table.getn(rankList)) do
			ui.rankList[rank].gameObject:SetActive(true)

			local guild = rankList[rank]
			ui.rankList[rank].label.text = string.format(FORMAT_GUILDLABEL, guild.guildBanner, guild.guildName)
			damage[rank] = guild.hurt
			damagePercentage[rank] = guild.percent
		end

		EnableAnimation()

		ui.status.text = TextMgr:GetText("Duke_51")
		
		-- 结束占领倒计时
		CountDown.Instance:Add("FortInfo", config.occupyEndTime, CountDown.CountDownCallBack(function(t)
			local leftTime = Global.GetLeftCooldownSecond(config.occupyEndTime)
			ui.time.text = Global.SecondToTimeLong(leftTime)

			if leftTime <= 0 then
				CountDown.Instance:Remove("FortInfo")
				CountDown.Instance:Remove("FortInfo_Reward")
			end
		end))

		EnableAnimation()

		ui.fort.position.text = string.format(FORMAT_POSITION, fort.pos.x, fort.pos.y)

		local ownerGuild = fort.occupyInfo.ownerInfo
		if ownerGuild.guildId ~= nil and ownerGuild.guildId ~= 0 then -- 联盟占领
			ui.fort.ownerGuild.text = string.format(FORMAT_GUILDLABEL, ownerGuild.guildBanner, ownerGuild.guildName)
			ui.fort.duke.text = ownerGuild.leaderName
		else -- 无城主、叛军占领
			ui.fort.ownerGuild.text = TextMgr:GetText("Duke_49")
			ui.fort.ownerGuild.color = Color.red
			ui.fort.duke.text = TextMgr:GetText("Duke_49")
			ui.fort.duke.color = Color.red
		end

		-- 下次奖励领取倒计时
		if #fort.occupyInfo.rankList ~= 0 then
			CountDown.Instance:Add("FortInfo_Reward", config.occupyEndTime, CountDown.CountDownCallBack(function(t)
				local now = Serclimax.GameTime.GetSecTime()
				local nextRewardTime = now + config.occupyRewardInterval - (now - config.contendEndTime) % config.occupyRewardInterval
				
				if nextRewardTime <= config.occupyEndTime then
					ui.rewardTime.text = Global.SecondToTimeLong(Global.GetLeftCooldownSecond(nextRewardTime))
				else
					ui.rewardTimeDisplay:SetActive(false)
					CountDown.Instance:Remove("FortInfo_Reward")
				end
			end))
		end
	end
end

local function Animate()
	if status == 3 or status == 4 then
		local animationTimespan = math.min(Serclimax.GameTime.GetMilSecTime() - animationStartTime, ANIMATION_TIMESPAN)
		if animationTimespan >= ANIMATION_TIMESPAN then enableAnimation = false end
		
		for rank = 1, math.min(3, table.getn(status == 3 and fort.contendInfo.rankList or fort.occupyInfo.rankList)) do
			local currentHeight = HEIGHT_MINIMUM + (height[rank] - HEIGHT_MINIMUM) * animationTimespan / ANIMATION_TIMESPAN
			ui.rankList[rank].histogram.height = currentHeight
			
			local textY = currentHeight + TEXT_Y_SHIFT
			if textY > TEXT_Y_MINIMUM then
				ui.rankList[rank].movingLabels.localPosition = Vector3(0, textY, 0)
			end

			ui.rankList[rank].damage.text = Global.ExchangeValue(math.floor(damage[rank] * currentHeight / height[rank]))
			ui.rankList[rank].damagePercentage.text = Global.FormatPercentageNumber(damagePercentage[rank] * currentHeight / height[rank])

			if not enableAnimation then
				ui.rankList[rank].fx_histogram.height = height[rank] + FRAME_HEIGHT_INCREASE
				ui.rankList[rank].fx_histogram.gameObject:SetActive(true)

				ui.rankList[rank].fx_damagePercentage.text.text = Global.FormatPercentageNumber(damagePercentage[rank])
				ui.rankList[rank].fx_damagePercentage.gameObject:SetActive(true)
			end
		end
	end
end

local function Draw()
	LoadUI()
	SetUI()
end

----------
-- APIs --
----------

function Refresh()
	if isInViewPort then
		FortsData.RequestFortData(subType, function(_fort, _config, _status)
			if _status >= 1 and _status <= 4 then
				fort = _fort
				config = _config
				status = _status
				
				if fort.available then Draw() end
			else
				Global.ShowError(ReturnCode_pb.Code_SceneMap_ForActStatusInvalid)
				Global.CloseUI(_M)
			end
		end)
	end
end

function Show(_subType, _mapX, _mapY, _tileMsg)
	subType = _subType
    mapX = _mapX
    mapY = _mapY
    tileMsg = _tileMsg

	FortsData.RequestFortData(subType, function(_fort, _config, _status)
		if _status >= 1 and _status <= 4 then
			fort = _fort
			config = _config
			status = _status

			Global.OpenUI(_M)
		else
			Global.ShowError(ReturnCode_pb.Code_SceneMap_ForActStatusInvalid)
		end
	end)
end

function Start()
	isInViewPort = true
	
	Draw()
end

function Close()
	isInViewPort = false

	CountDown.Instance:Remove("FortInfo")
	CountDown.Instance:Remove("FortInfo_Reward")

	subType = 0
	forts = nil
	config = nil
	status = 0

	mapX = -1
	mapY = -1
	tileMsg = nil

	animationStartTime = 0

	enableAnimation = false
	height = nil
	damage = nil
	damagePercentage = nil
	
	ui = nil
end

function Update()
	if enableAnimation then Animate() end
end

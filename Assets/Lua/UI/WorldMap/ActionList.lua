module("ActionList", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local GameTime = Serclimax.GameTime

local _ui

function Hide()
    Global.CloseUI(_M)
end

local function UpdateActionListState()
    for _, v in ipairs(_ui.actionList) do
        local actionMsg = v.msg
        local arriveTime = actionMsg.starttime + actionMsg.time
        local leftCooldownSecond = Global.GetLeftCooldownSecond(arriveTime)

		-- print("_____________",actionMsg.starttime,actionMsg.time)
        if leftCooldownSecond > 0 then
            
			if actionMsg.status == Common_pb.PathEntryStatus_camp then
				v.timeSlider.value = 1 - Global.GetLeftCooldownMillisecond(arriveTime) / (actionMsg.time * 1000)
				v.timeLabel.text = System.String.Format(Global.GTextMgr:GetText("ui_autoreturn_txt"),Global.SecondToTimeLong(leftCooldownSecond))
			else 
				v.timeSlider.value = 1 - Global.GetLeftCooldownMillisecond(arriveTime) / (actionMsg.time * 1000)
				v.timeLabel.text = Global.SecondToTimeLong(leftCooldownSecond)
			end
        else
            if actionMsg.status == Common_pb.PathEntryStatus_Occupy then
				
				local Time = TableMgr:GetGlobalData(100224).value
				arriveTime = actionMsg.starttime + actionMsg.time + Time
				leftCooldownSecond = Global.GetLeftCooldownSecond(arriveTime)
				
				if leftCooldownSecond >0 then 
					v.timeBg.gameObject:SetActive(true)
					v.timeSlider.value = 1 - Global.GetLeftCooldownMillisecond(arriveTime) / (Time * 1000)
					v.timeLabel.text = System.String.Format(Global.GTextMgr:GetText("ui_autoreturn_txt"),Global.SecondToTimeLong(leftCooldownSecond))
				else
					v.timeBg.gameObject:SetActive(false)
				end 

				v.stateLabel.text = TextMgr:GetText(Text.ui_worldmap_57)
			else
				v.timeBg.gameObject:SetActive(false)
				if actionMsg.status == Common_pb.PathEntryStatus_Occupy then
					v.stateLabel.text = TextMgr:GetText(Text.ui_worldmap_57)
				end
			end 
		   
        end
    end
end

function RequestRetreat(pathId, targetUid, garrisonUser, buy, pathtype, pathstatus)
    local req = MapMsg_pb.CancelPathRequest()
    req.tarpathid = pathId
    req.taruid = targetUid
    req.buy = buy
    
    if pathtype == Common_pb.TeamMoveType_GarrisonCenterBuild or pathstatus == Common_pb.PathEntryStatus_GarrisonCenterBuild then
        req.garrisonCenterUser = garrisonUser
    else
        req.garrisonUser = garrisonUser
    end
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.CancelPathRequest, req, MapMsg_pb.CancelPathResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            MainCityUI.UpdateRewardData(msg.fresh)
            AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
            if pathtype == Common_pb.TeamMoveType_GatherCall or pathstatus == Common_pb.PathEntryStatus_Garrison or
            pathstatus == Common_pb.PathEntryStatus_GarrisonCenterBuild or pathtype == Common_pb.TeamMoveType_GarrisonCenterBuild 
            or pathstatus == Common_pb.PathEntryStatus_camp or pathstatus == Common_pb.PathEntryStatus_Occupy then

            else
                if buy then
                    GUIMgr:SendDataReport("purchase", "costgold", "item:10101", "1", "" ..MoneyListData.ComputeDiamond(msg.fresh.money.money))
                else
                    GUIMgr:SendDataReport("purchase", "useitem", "10101", "1")
                end

                if buy then
                    local itData = TableMgr:GetItemData(10101)
                    local nameColor = Global.GetLabelColorNew(itData.quality)
                    local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itData)..nameColor[1])
                    FloatText.Show(showText , Color.white , ResourceLibrary:GetIcon("Item/", itData.icon))
                end
            end
        end
    end, true)
end

function GetActionTargetInfo(status, pathType, targetPos, tarname, tarentrytype)
    local statusIcon
    local statusText
    local targetName

    --返回中
    if status == Common_pb.PathMoveStatus_Back then
        if pathType == Common_pb.TeamMoveType_ReconMonster or pathType == Common_pb.TeamMoveType_ReconPlayer then
            statusIcon = "icon_plane_reconback"
            statusText = Text.ui_worldmap_55
        elseif pathType == Common_pb.TeamMoveType_Prisoner then
            statusIcon = "icon_plane_commander"
            statusText = Text.jail_35
		elseif pathType == 22 then
			statusIcon = "icon_plane_support"
            statusText = "Union_Support_ui9"
        else
            statusIcon = "icon_plane_back"
            statusText = Text.ui_worldmap_55
        end
        targetName = MainData.GetCharName()
        --出发前等待
    elseif status == Common_pb.PathMoveStatus_GoWait then
        statusIcon = "icon_plane_attack"
        statusText = Text.ui_worldmap_54
        if tarentrytype == Common_pb.SceneEntryType_Fort then
            targetName = TextMgr:GetText(tarname)
        elseif tarentrytype == Common_pb.SceneEntryType_Govt then
            targetName = TextMgr:GetText(tarname)
        elseif tarentrytype == Common_pb.SceneEntryType_Turret then
            targetName = TextMgr:GetText(tarname)
        elseif tarentrytype == Common_pb.SceneEntryType_EliteMonster then
            targetName = TextMgr:GetText(tarname)
        elseif tarentrytype == Common_pb.SceneEntryType_Fortress then
            targetName = TextMgr:GetText(tarname)
        elseif tarentrytype == Common_pb.SceneEntryType_Stronghold then
            targetName = TextMgr:GetText(tarname)
        elseif tarname == "" then
            targetName = WorldMap.GetTileName(targetPos.x, targetPos.y)
        else
            targetName = tarname
        end
        --行军中
    elseif status == Common_pb.PathMoveStatus_Go then
        --侦察野怪 侦察玩家
        if pathType == Common_pb.TeamMoveType_ReconMonster or pathType == Common_pb.TeamMoveType_ReconPlayer then
            statusIcon = "icon_plane_recon"
            --侦查中
            statusText = Text.ui_worldmap_50
            --资源运输
        elseif pathType == Common_pb.TeamMoveType_ResTransport then
            statusIcon = "icon_plane_trade"
            --运输中
            statusText = Text.ui_worldmap_52
            --驻防中
        elseif pathType == Common_pb.TeamMoveType_ResTake 
            or pathType == Common_pb.TeamMoveType_MineTake 
            or pathType == Common_pb.TeamMoveType_Garrison 
            or pathType == Common_pb.TeamMoveType_GatherCall 
            or pathType == Common_pb.TeamMoveType_GatherRespond
            or pathType == Common_pb.TeamMoveType_GuildBuildCreate
            or pathType == Common_pb.TeamMoveType_TrainField then
            statusIcon = "icon_plane_go"
            --行军中
            statusText = Text.ui_worldmap_51
            --进攻中
        else
            statusIcon = "icon_plane_attack"
            statusText = Text.ui_worldmap_56
        end

        if pathType == Common_pb.TeamMoveType_AttackPlayer
            or pathType == Common_pb.TeamMoveType_ReconPlayer
            or pathType == Common_pb.TeamMoveType_Camp
            or pathType == Common_pb.TeamMoveType_Garrison
            or pathType == Common_pb.TeamMoveType_Occupy
            or pathType == Common_pb.TeamMoveType_ResTransport
            or pathType == Common_pb.TeamMoveType_GatherCall
            or pathType == Common_pb.TeamMoveType_GatherRespond then
            if tarentrytype == Common_pb.SceneEntryType_Fort then
                targetName = TextMgr:GetText(tarname)
            elseif tarentrytype == Common_pb.SceneEntryType_Govt then
                targetName = TextMgr:GetText(tarname)
            elseif tarentrytype == Common_pb.SceneEntryType_Turret then
                targetName = TextMgr:GetText(tarname)
			
			elseif tarentrytype == Common_pb.SceneEntryType_Fortress then
				targetName = TextMgr:GetText(tarname)
			elseif tarentrytype == Common_pb.SceneEntryType_Stronghold then
				targetName = TextMgr:GetText(tarname)
			elseif tarentrytype == Common_pb.SceneEntryType_EliteMonster then
				targetName = TextMgr:GetText(tarname)
            elseif tarname == "" then
                targetName = WorldMap.GetTileName(targetPos.x, targetPos.y)
            else
                targetName = tarname
            end
        else
            targetName = TextMgr:GetText(tarname)
        end
        --采集中
    elseif status == Common_pb.PathEntryStatus_takeres then
        statusIcon = "icon_plane_gather"
        statusText = Text.ui_worldmap_59
        targetName = TextMgr:GetText(tarname)
        --扎营中
    elseif status == Common_pb.PathEntryStatus_camp then
        statusIcon = "icon_plane_station"
        statusText = Text.ui_worldmap_57
        if tarname == "" then
            targetName = WorldMap.GetTileName(targetPos.x, targetPos.y)
        else
            targetName = tarname
        end
		--联盟争霸
	elseif status == Common_pb.PathEntryStatus_GuildMoba then
        statusIcon = "icon_plane_attack"
        statusText = "ui_moba_166"
        -- targetName = TextMgr:GetText("mail_unionwar_over_title") -- tarname)
        --驻防中
    elseif status == Common_pb.PathEntryStatus_Garrison then
        statusIcon = "icon_plane_garrison"
        statusText = Text.ui_worldmap_53
        if tarname == "" then
            targetName = WorldMap.GetTileName(targetPos.x, targetPos.y)
        else
            targetName = tarname
        end
        -- 驻防政府
    elseif status == Common_pb.PathEntryStatus_GarrisonCenterBuild then
        statusIcon = "icon_plane_garrison"
        statusText = Text.ui_worldmap_53
        if tarname == "" then
            targetName = WorldMap.GetTileName(targetPos.x, targetPos.y)
        else
            targetName = TextMgr:GetText(tarname)
        end
        --占领中
    elseif status == Common_pb.PathEntryStatus_Occupy then
        statusIcon = "icon_plane_station"
        statusText = Text.ui_worldmap_58
        if tarname == "" then
            targetName = WorldMap.GetTileName(targetPos.x, targetPos.y)
        else
            targetName = tarname
        end
        --集结中
    elseif status == Common_pb.PathEntryStatus_Gather then
        statusIcon = "icon_plane_attack"
        statusText = Text.ui_worldmap_54
        if tarentrytype == Common_pb.SceneEntryType_Fort then
            targetName = TextMgr:GetText(tarname)
        elseif tarentrytype == Common_pb.SceneEntryType_Govt then
            targetName = TextMgr:GetText(tarname)
        elseif tarentrytype == Common_pb.SceneEntryType_Turret then
            targetName = TextMgr:GetText(tarname)
        elseif tarentrytype == Common_pb.SceneEntryType_Fortress then
            targetName = TextMgr:GetText(tarname)
        elseif tarentrytype == Common_pb.SceneEntryType_Stronghold then
            targetName = TextMgr:GetText(tarname)
        elseif tarname == "" then
            targetName = WorldMap.GetTileName(targetPos.x, targetPos.y)
        else
            targetName = tarname
        end
        --联盟矿建造
    elseif status == Common_pb.PathEntryStatus_GuileMineCreate then
        statusIcon = "icon_plane_gather"
        statusText = Text.union_ore11
        targetName = TextMgr:GetText(tarname)
        --联盟矿采集
    elseif status == Common_pb.PathEntryStatus_GuileMineTake then
        statusIcon = "icon_plane_gather"
        statusText = Text.union_ore10
        targetName = TextMgr:GetText(tarname)
        --联盟训练场
    elseif status == Common_pb.PathEntryStatus_Train then
        statusIcon = "icon_plane_gather"
        statusText = Text.union_train11
        targetName = TextMgr:GetText(tarname)
    end
    if not System.String.IsNullOrEmpty(targetName) then
        if string.find(targetName,"map_paoche_") ~= nil then
            targetName = TextMgr:GetText(targetName)
        end
    end
    return statusIcon, TextMgr:GetText(statusText), targetName
end

function GetActionTargetInfoByMsg(actionMsg)
    return GetActionTargetInfo(actionMsg.status, actionMsg.pathtype, actionMsg.tarpos, actionMsg.tarname, actionMsg.tarentrytype)
end

local function LoadUI()
    ActionListData.Sort1()
    local actionListMsg = ActionListData.GetData()
    local totalCount = #actionListMsg
    _ui.actionList = {}
    local actionIndex = 1
    for _, v in ipairs(actionListMsg) do
        local actionTransform = _ui.actionGrid:GetChild(actionIndex - 1)
        if actionTransform == nil then
            actionTransform = NGUITools.AddChild(_ui.actionGrid.gameObject, _ui.actionPrefab).transform
        end
        local action = {}
        action.msg = v
        action.transform = actionTransform
        action.stateLabel = actionTransform:Find("bg_text/text_type"):GetComponent("UILabel")
        action.targetLabel = actionTransform:Find("goal/name"):GetComponent("UILabel")
        action.coordLabel = actionTransform:Find("local/name"):GetComponent("UILabel")
        action.countLabel = actionTransform:Find("number/Label"):GetComponent("UILabel")
        action.stateIcon = actionTransform:Find("bg_icon/Sprite"):GetComponent("UITexture")
        action.locateButton = actionTransform:Find("bg_icon/btn"):GetComponent("UIButton")
        action.retreatButton = actionTransform:Find("bg_exp/cancel"):GetComponent("UIButton")
		action.retreatButtonBg = actionTransform:Find("bg_exp/cancel/bg"):GetComponent("UISprite")
        action.timeBg = actionTransform:Find("bg_exp/bg")
        action.timeSlider = actionTransform:Find("bg_exp/bg/bar"):GetComponent("UISlider")
        action.timeLabel = actionTransform:Find("bg_exp/bg/text"):GetComponent("UILabel")
        action.accelerateButton = actionTransform:Find("bg_exp/speed"):GetComponent("UIButton")
        action.heroGrid = actionTransform:Find("Grid"):GetComponent("UIGrid")
        action.heroEmptyObject = actionTransform:Find("Label").gameObject
		action.baseObject = actionTransform:Find("base").gameObject
		action.localObject = actionTransform:Find("local").gameObject

        local targetPos = v.tarpos
        action.coordLabel.text = string.format("#1.X:%d Y:%d", targetPos.x, targetPos.y)
        action.countLabel.text = v.armynum

        local statusIcon, statusText, targetName = GetActionTargetInfoByMsg(v)

        action.stateIcon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/" ,statusIcon) -- statusIcon
        action.stateLabel.text = statusText
        action.targetLabel.text = targetName

        
        local status = v.status
        local pathType = v.pathtype
        local attachPathId = v.attachPathId
        
        local showTime = false
        --路径显示时间
        if status == Common_pb.PathMoveStatus_Back or status == Common_pb.PathMoveStatus_Go then
            showTime = true
        end

        --采集显示时间
        if status == Common_pb.PathEntryStatus_takeres 
            --占领显示时间
            or status == Common_pb.PathEntryStatus_Occupy
            ---联盟矿建造显示时间
            or status == Common_pb.PathEntryStatus_GuileMineCreate
            --联盟矿采集显示时间
            or status == Common_pb.PathEntryStatus_GuileMineTake
			
			or status == Common_pb.PathEntryStatus_GuildMoba 
            --联盟训练场显示时间
            or status == Common_pb.PathEntryStatus_Train then
            showTime = true
        end

	    print("_________________________",status,v.starttime,v.time)
        --集结显示时间
        if status == Common_pb.PathEntryStatus_Gather or status == Common_pb.PathMoveStatus_GoWait then
			showTime = true
            local state,startTime,endTime = MassTroops.UpdateTimeMsg(nil, v.gather)
            startTime = math.max(startTime, 0)
            endTime = math.max(endTime, 0)
            v.starttime = startTime
            v.time = endTime - startTime 
			
		elseif status == Common_pb.PathEntryStatus_camp then
			showTime = true
			local Time = TableMgr:GetGlobalData(100224).value
            v.time = tonumber(Time)
        end
		
        action.timeBg.gameObject:SetActive(showTime)

        local canAccelerate = true
        --非路径不能加速
        if status ~= Common_pb.PathMoveStatus_Go and status ~= Common_pb.PathMoveStatus_Back then
            canAccelerate = false
            --集结大飞机不能加速
        elseif status == Common_pb.PathMoveStatus_Go and pathType == Common_pb.TeamMoveType_GatherCall then
            canAccelerate = false
            --指挥官回城不能加速
        elseif pathType == Common_pb.TeamMoveType_Prisoner then
            canAccelerate = false
			--联盟援助不能加速
		elseif pathType == 22 then
			canAccelerate = false
        end

        action.accelerateButton.gameObject:SetActive(canAccelerate)

        local canRetreat = true
        --已经在撤退的不能撤退
        if status == Common_pb.PathMoveStatus_Back then
            canRetreat = false
            --响应集结的和大飞机不能撤退
        elseif (status == Common_pb.PathMoveStatus_Go and pathType == Common_pb.TeamMoveType_GatherRespond) or status == Common_pb.PathEntryStatus_Gather then
            canRetreat = false
            --指挥官回城不能加速撤退
        elseif pathType == Common_pb.TeamMoveType_Prisoner then
            canRetreat = false
        end

        action.retreatButton.gameObject:SetActive(canRetreat)

        SetClickCallback(action.coordLabel.gameObject, function()
            if status == Common_pb.PathEntryStatus_GuildMoba then 
				local basePos = MapInfoData.GetData().mypos
				Hide()
                WorldMap.LookAt(basePos.x, basePos.y)
                WorldMap.SelectTile(basePos.x, basePos.y)
			else
				Hide()
				WorldMap.LookAt(targetPos.x, targetPos.y)
				WorldMap.SelectTile(targetPos.x, targetPos.y)
			end 
        end)

        SetClickCallback(action.locateButton.gameObject, function()
			if status == Common_pb.PathEntryStatus_takeres
                or status == Common_pb.PathEntryStatus_camp
                or status == Common_pb.PathEntryStatus_Garrison
                or status == Common_pb.PathEntryStatus_GarrisonCenterBuild
                or status == Common_pb.PathEntryStatus_Occupy
                or status == Common_pb.PathEntryStatus_Gather and attachPathId == 0
                or status == Common_pb.PathMoveStatus_GoWait
                or status == Common_pb.PathEntryStatus_GuileMineCreate
                or status == Common_pb.PathEntryStatus_GuileMineTake
                or status == Common_pb.PathEntryStatus_Train then
                Hide()
                WorldMap.LookAt(targetPos.x, targetPos.y)
                WorldMap.SelectTile(targetPos.x, targetPos.y)
			elseif status == Common_pb.PathEntryStatus_GuildMoba then 
				local basePos = MapInfoData.GetData().mypos
				Hide()
                WorldMap.LookAt(basePos.x, basePos.y)
                WorldMap.SelectTile(basePos.x, basePos.y)
            else
                local req = MapMsg_pb.SceneMapPathInfoRequest()
                req.pathid = v.uid
                if status == Common_pb.PathEntryStatus_Gather then
                    req.pathid = attachPathId
                end
                Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.SceneMapPathInfoRequest, req, MapMsg_pb.SceneMapPathInfoResponse, function(msg)
                    if msg.code == ReturnCode_pb.Code_OK then
                        if #msg.path > 0 then
                            local pathInfoMsg = msg.path[1]
                            -- PathListData.UpdatePathData(pathInfoMsg)
                            WorldMap.FollowPath(pathInfoMsg.pathId)
                            Hide()
                        end
                    end
                end, false)
            end
        end)

        SetClickCallback(action.accelerateButton.gameObject, function()
            local accelerateText = String.Format(TextMgr:GetText(Text.ui_worldmap_72), statusText, targetName, 1, targetPos.x, targetPos.y)
            MainCityUI.ShowMarchingAcceleration(v.uid, accelerateText)
        end)

        SetClickCallback(action.retreatButton.gameObject, function()
            if status == Common_pb.PathMoveStatus_Go then
                QuickUseItem.Show(10101, function(buy)
                    local garrisonUser = 0
                    if pathType == Common_pb.TeamMoveType_Garrison then
                        garrisonUser = MainData.GetCharId()
                    end
                    if pathType == Common_pb.TeamMoveType_GarrisonCenterBuild then
                        garrisonUser = MainData.GetCharId()
                        RequestRetreat(v.uid, 0, garrisonUser, false, pathType, status)
                    else
                        RequestRetreat(v.uid, 0, garrisonUser, buy, pathType)
                    end                    
                end)
            elseif status == Common_pb.PathMoveStatus_GoWait then
                local garrisonUser = 0
                local buy = false
                RequestRetreat(v.uid, 0, garrisonUser, buy, pathType)
            else
                local garrisonUser = 0
                if status == Common_pb.PathEntryStatus_Garrison  or pathType == Common_pb.TeamMoveType_Garrison then
                    garrisonUser = MainData.GetCharId()
                end
                if status == Common_pb.PathEntryStatus_GarrisonCenterBuild then
                    garrisonUser = MainData.GetCharId()
                    RequestRetreat(attachPathId, v.uid, garrisonUser, false, pathType, status)
                else
                    RequestRetreat(0, v.uid, garrisonUser, false, pathType, status)
                end
                
            end
        end)

        actionTransform.gameObject:SetActive(true)
        _ui.actionList[actionIndex] = action
        actionIndex = actionIndex + 1

        local heroMsgList = v.army.hero.heros
        action.heroGrid.gameObject:SetActive(#heroMsgList > 0)
        action.heroEmptyObject:SetActive(#heroMsgList == 0)
        if #heroMsgList > 0 then
            for ii, vv in ipairs(heroMsgList) do
                local heroTransform
                if ii > action.heroGrid.transform.childCount then
                    heroTransform = NGUITools.AddChild(action.heroGrid.gameObject, _ui.heroPrefab).transform
                else
                    heroTransform = action.heroGrid.transform:GetChild(ii - 1)
                    heroTransform.gameObject:SetActive(true)
                end
                heroTransform.localScale = Vector3(0.45,0.45,1)
                local hero = {}
                HeroList.LoadHeroObject(hero, heroTransform)
                local heroMsg = Common_pb.HeroInfo() 
                heroMsg.star = vv.star
                heroMsg.level = vv.level
                heroMsg.num = vv.num
                local heroData = TableMgr:GetHeroData(vv.baseid)
                HeroList.LoadHero(hero, heroMsg, heroData)
            end
            action.heroGrid.repositionNow = true
        end
        for ii = #heroMsgList + 1, action.heroGrid.transform.childCount do
            action.heroGrid.transform:GetChild(ii - 1).gameObject:SetActive(false)
        end
		
		if status == Common_pb.PathEntryStatus_GuildMoba then
			action.retreatButton.isEnabled = false
			action.retreatButtonBg.spriteName = "union_button1_un"
			action.heroEmptyObject:SetActive(false)
			action.baseObject:SetActive(false)
			action.locateButton.gameObject:SetActive(false)
			action.localObject:SetActive(false)
		else 
			action.retreatButton.isEnabled = true
			action.retreatButtonBg.spriteName = "union_button1"
			action.baseObject:SetActive(true)
		end 
		
    end
    for i = actionIndex, _ui.actionGrid.transform.childCount do
        _ui.actionGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end
    _ui.actionGrid:Reposition()
    UpdateActionListState() 
end

function Update()
    UpdateActionListState()
end

function Awake()
    _ui = {}
    if _ui.actionPrefab == nil then
        _ui.actionPrefab = ResourceLibrary.GetUIPrefab("WorldMap/march_item")
    end

    local bg = transform:Find("Container")
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
    SetClickCallback(bg.gameObject, Hide)
    SetClickCallback(closeButton.gameObject, Hide)
    _ui.actionGrid = transform:Find("Container/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.heroPrefab = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
    ActionListData.AddListener(LoadUI)
end

function Close()
    ActionListData.RemoveListener(LoadUI)
    _ui = nil
end

function Show()
    Global.OpenUI(_M)
    LoadUI()
end

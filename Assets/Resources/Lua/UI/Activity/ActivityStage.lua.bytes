module("ActivityStage", package.seeall)
local BattleMsg_pb = require("BattleMsg_pb")
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local SetDragCallback = UIUtil.SetDragCallback

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local ActivityID
local LeftCount
local CountMax

local MissionInfo
local PreMission
local _ui
local function CloseClickCallback(go)
    Hide()
    --ActivityEntrance.Show()
end

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end


function GetCurBattleInfo()
    if PreMission == nil then
        return nil 
    end
    return PreMission.data
end

function GetActivityID()
    return ActivityID
end

function GetPreMission()
    return PreMission
end

local function StartBattle(cl)
    --Hide()
    if LeftCount == 0 then
        MessageBox.Show(TextMgr:GetText("ui_activity_hint1"))
    else
        if ActivityID == 5 then
            SelectArmy.SetAttackCallback(function(battleId, _teamType)
				
            if TeamData.GetSelectedArmyCount(_teamType) == 0 then
                 local noSelectText = TextMgr:GetText(Text.selectunit_hint112)
                 Global.GAudioMgr:PlayUISfx("SFX_ui02", 1, false)
                FloatText.Show(noSelectText, Color.red)
                return
            end           


                    local req = BattleMsg_pb.MsgBattleRandomPVEStartRequest()
                    req.activityId = ActivityID -- ActivityID
                    req.missionId = PreMission.data.missionId 
                    Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgBattleRandomPVEStartRequest, req, BattleMsg_pb.MsgBattleRandomPVEStartResponse, function(msg)
                        if msg.code ~= ReturnCode_pb.Code_OK then
                            Global.ShowError(msg.code)
                        else
                            local battleState = GameStateBattle.Instance
                            ActivityData.UpdateListData(msg.actInfo)
                            print(battleState)
                            battleState:SetRandomBattleStartResponse(ActivityID,msg.chapterlevel,msg:SerializeToString())
                            local _battleId = msg.chapterlevel
                            local battleData = TableMgr:GetBattleData(_battleId)
                            local unlockArmyId
                            local unlockHeroId
                            if not ChapterListData.HasLevelExplored(_battleId) and battleData.unlock ~= "NA" then
                                local unlockList = string.split(battleData.unlock, ",")
                                if unlockList[1] == "1" then
                                    unlockArmyId = tonumber(unlockList[2])
                                elseif unlockList[1] == "2" then
                                    unlockHeroId = tonumber(unlockList[2])
                                end
                            end
    
                            
                            battleState.IsPvpBattle = false
                            GUIMgr:CloseAllMenu()
    
                            battleState.BattleId =  _battleId
    
                            local teamData = TeamData.GetDataByTeamType(_teamType)
                            local selectedArmyList = {}
                            for _, v in ipairs(teamData.memArmy) do
                                table.insert(selectedArmyList, v.uid)
                            end
    
                            local heroInfoDataList = battleState.heroInfoDataList
                            heroInfoDataList:Clear()
                            for _, v in ipairs(teamData.memHero) do
                                local heroMsg = GeneralData.GetGeneralByUID(v.uid) -- HeroListData.GetHeroDataByUid(v.uid)
                                heroInfoDataList:Add(heroMsg:SerializeToString())
                            end
    
                            if unlockHeroId ~= nil and heroInfoDataList.Count < 5 then
                                local heroMsg = Common_pb.HeroInfo()
                                heroMsg.uid = 0
                                heroMsg.baseid = unlockHeroId
                                heroMsg.star = 1
                                heroMsg.exp = 0
                                heroMsg.grade = 1
                                heroMsg.skill.godSkill.id = tonumber(TableMgr:GetHeroData(unlockHeroId).skillId)
                                heroMsg.skill.godSkill.level = 1
                                heroInfoDataList:Add(heroMsg:SerializeToString())
                            end
    
                            AttributeBonus.CollectBonusInfo()
                            local battleBonus = AttributeBonus.CalBattleBonus(_battleId)
                            local battleArgs = 
                            {
                                loadScreen = "1",
                                selectedArmyList = selectedArmyList,
                                battleBonus = 
                                {
                                    bulletAddition = battleBonus.SummonEnergy,
                                    energyAddition = battleBonus.SkillEnergy,
                                    bulletRecover = battleBonus.SummonEnergyRecovery
                                }
                            }
                            print("开始战斗，关卡Id:", _battleId)
                            Main.Instance:ChangeGameState(battleState, cjson.encode(battleArgs),nil)
                            ActivityEntrance.CurShowID = ActivityID
                        end
                    end)
 
            end)
            SelectHero.Show(Common_pb.BattleTeamType_Main,true)
        else
            ActivityArmy.Show(ActivityID,PreMission.data)
        end
    end
end

function GetActivityID()
    return ActivityID
end

local total_mission = 0
local missions

local function AddRandomBattle(grid,mission_prefab,reward_prefab,data,better_time)
    total_mission = total_mission + 1
    if missions == nil then 
        missions = {}
    end
    local obj = NGUITools.AddChild(grid.gameObject, mission_prefab)
    obj.name = data.missionId
    obj:SetActive(true)
    missions[data.missionId] = {}
    missions[data.missionId].obj= obj
    missions[data.missionId].data = data
    missions[data.missionId].betterTime = better_time
    local childLabel = obj.transform:Find("bg_frane/bg_name/name"):GetComponent("UILabel")
    local childIcon = obj.transform:Find("bg_frane/bg_texture/texture"):GetComponent("UITexture")
    local childDes = obj.transform:Find("bg_frane/bg_des/describe"):GetComponent("UILabel")
    local reward_sv = obj.transform:Find("bg_frane/bg_reward/Scroll View"):GetComponent("UIScrollView")
    local reward_g = obj.transform:Find("bg_frane/bg_reward/Scroll View/Grid"):GetComponent("UIGrid")
    local icon_finish =  obj.transform:Find("bg_frane/bg_texture/icon_finish").gameObject
    local better_time_root =  obj.transform:Find("bg_frane/best time bg").gameObject
    local better_time_label = obj.transform:Find("bg_frane/best time bg/Label"):GetComponent("UILabel")
    icon_finish:SetActive(data.complete)

    if ActivityID == 1 then
        better_time_root.gameObject:SetActive(false)
    else
        if better_time == nil or better_time == 0 then
            better_time_root.gameObject:SetActive(false)
        else
            better_time_root.gameObject:SetActive(true)
            better_time_label.text = Serclimax.GameTime.SecondToString(better_time)
        end
    end

    childLabel.text = TextMgr:GetText(data.name)
    childDes.text = TextMgr:GetText(data.desc)
    childIcon.mainTexture = ResourceLibrary:GetIcon ("Icon/Chapter/", data.icon)
    --childIcon:MakePixelPerfect()

    local t = string.split(data.reward,';')
    for i=1,#(t) do
        if t[i] ~= "" then
        local tt = string.split(t[i],':')
        local itemData = TableMgr:GetItemData(tonumber(tt[1]))
        local robj = NGUITools.AddChild(reward_g.gameObject, reward_prefab)
		local item = {}
		UIUtil.LoadItemObject(item, robj.transform)
		UIUtil.LoadItem(item, itemData, nil)
       
        robj:AddComponent(typeof(UIEventListener));
        SetClickCallback(robj.gameObject,function(go)
            if go == _ui.tipObject then
                _ui.tipObject = nil
            else
                _ui.tipObject = go
                Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)}) 
            end
        end)
    end
end
    reward_g:Reposition()
    reward_sv:SetDragAmount(0, 0, false) 
    local begin = obj.transform:Find("bg_frane/btn_begin")
    begin.gameObject:SetActive(false)
    local frame = obj.transform:Find("bg_frane"):GetComponent("UIWidget")
    local frameLight = obj.transform:Find("bg_frane/frame_contour").gameObject
    frameLight:SetActive(false)
    frame.gameObject:GetComponent("UIButton").tweenTarget = nil

    --frame.alpha = 0.5
    frame.transform.localScale = Vector3(0.8,0.8,0.8)
    local Center = obj:GetComponent("UICenterOnChild")


    if not data.complete then
        if PreMission == nil then
        PreMission = {}
        PreMission.frame = frame
        --PreMission.frame.alpha = 1
        PreMission.frame.transform.localScale = Vector3(1,1,1)
        PreMission.begin = begin
        PreMission.Center = Center
        PreMission.begin.gameObject:SetActive(not data.complete)
        PreMission.frameLight = frameLight
        PreMission.frameLight:SetActive(true)
        PreMission.data = data
        PreMission.betterTime = better_time
    end

    end
    if MissionInfo == nil then
        MissionInfo = {}
        MissionInfo.frame = frame
        --MissionInfo.frame.alpha = 1
        MissionInfo.frame.transform.localScale = Vector3(1,1,1)
        MissionInfo.begin = begin
        MissionInfo.Center = Center
        MissionInfo.begin.gameObject:SetActive(not data.complete)
        MissionInfo.frameLight = frameLight
        MissionInfo.frameLight:SetActive(true)
        MissionInfo.data = data
        MissionInfo.betterTime = better_time
        if data.complete then
        MissionInfo.begin.gameObject:SetActive(false)
        MissionInfo.frameLight:SetActive(false)
        MissionInfo.Center.enable = false
        --MissionInfo.frame.alpha = 0.5
        MissionInfo.frame.transform.localScale = Vector3(0.8,0.8,0.8)
        end        
    end    

    SetDragCallback(frame.gameObject,function(obj,delta)
        if math.abs( delta.x ) < 5 then
            return 
        end
            local id = tonumber( PreMission.frame.transform.parent.name)
            if delta.x < 0 then
                id = id + 1
            else
                id = id -1
            end
            
            if id < 0 or id > total_mission then
                return 
            end 
            if missions[id] == nil then
                return
            end
        if PreMission ~= nil then
            PreMission.begin.gameObject:SetActive(false)
            PreMission.frameLight:SetActive(false)
            PreMission.Center.enable = false
            --PreMission.frame.alpha = 0.5
            PreMission.frame.transform.localScale = Vector3(0.8,0.8,0.8)
            PreMission.frame = missions[id].obj.transform:Find("bg_frane"):GetComponent("UIWidget")
            --PreMission.frame.alpha = 1
            PreMission.frame.transform.localScale = Vector3(1,1,1)
            PreMission.frameLight =   missions[id].obj.transform:Find("bg_frane/frame_contour").gameObject
            PreMission.frameLight:SetActive(true)
            PreMission.begin =  missions[id].obj.transform:Find("bg_frane/btn_begin")
            PreMission.Center = missions[id].obj:GetComponent("UICenterOnChild")
            PreMission.Center:Recenter()
            PreMission.begin.gameObject:SetActive(not missions[id].data.complete)
            PreMission.data = missions[id].data
            PreMission.betterTime = missions[id].betterTime
        end
    end)

    SetClickCallback(frame.gameObject, function(obj)
        if PreMission ~= nil then
            PreMission.begin.gameObject:SetActive(false)
            PreMission.frameLight:SetActive(false)
            PreMission.Center.enable = false
            --PreMission.frame.alpha = 0.5
            PreMission.frame.transform.localScale = Vector3(0.8,0.8,0.8)

            PreMission.frame = frame
            --PreMission.frame.alpha = 1
            PreMission.frame.transform.localScale = Vector3(1,1,1)

            PreMission.frameLight = frameLight
            PreMission.frameLight:SetActive(true)
            PreMission.begin = begin
            PreMission.Center = Center
            PreMission.Center:Recenter()
            PreMission.begin.gameObject:SetActive(not data.complete)
            PreMission.data = data
            PreMission.betterTime = better_time
        end
    end)
    SetClickCallback(begin.gameObject, function(obj)
        StartBattle(tonumber( obj.name))
    end)
end

local function LoadUI()
    --[[
    ActivityID = 1
    local data = {}
    data.battle = {}
    data.battle[1]={}
    data.battle[1].name ="ui_barrack_warning2"
    data.battle[1].desc = "ui_barrack_warning8"
    data.battle[1].reward = "19101,10;19212,10;"
    data.battle[1].count = 0

    data.battle[2]={}
    data.battle[2].name ="ui_barrack_warning2"
    data.battle[2].desc = "ui_barrack_warning8"
    data.battle[2].reward = "19101,10;19212,10;"
    data.battle[2].count = 0  

    data.battle[3]={}
    data.battle[3].name ="ui_barrack_warning2"
    data.battle[3].desc = "ui_barrack_warning8"
    data.battle[3].reward = "19101,10;19212,10;"
    data.battle[3].count = 0

    ActivityData.SetActivityData(1,data)
    --]]
    local mission_prefab = transform:Find("MissionInfo").gameObject
    mission_prefab:SetActive(false)

    local reward_prefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")--transform:Find("listinfo_item").gameObject
   -- reward_prefab:SetActive(false)

    
    local scorllView = transform:Find("Container/Scroll View"):GetComponent("UIScrollView")
    local grid = transform:Find("Container/Scroll View/Grid"):GetComponent("UIGrid")

    local count_num = transform:Find("Container/bg_count/bg_num/num"):GetComponent("UILabel")


    local battle_list = ActivityData.GetActivityData(ActivityID).battle

    local better_time = ActivityData.GetActivityData(ActivityID).battleTime


    print(ActivityID,#battle_list.battle,better_time)
    for i= 1,#(battle_list.battle) do 
        AddRandomBattle(grid,mission_prefab,reward_prefab,battle_list.battle[i],better_time)
    end
    if PreMission == nil and MissionInfo ~= nil  then
        PreMission = MissionInfo
        --PreMission.frame.alpha = 1
        PreMission.frame.transform.localScale = Vector3(1,1,1)
        PreMission.frameLight:SetActive(true)
        if not PreMission.data.complete then
            PreMission.begin.gameObject:SetActive(true)
        end
    end
    MissionInfo = nil
    count_num.text =  LeftCount.."/"..CountMax

    grid:Reposition()
    --scorllView:SetDragAmount(0, 0, false) 
    if PreMission ~= nil then
        PreMission.Center:Recenter()
    end
    SetClickCallback(transform:Find("Container/btn_back").gameObject,CloseClickCallback)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Hide()
    ActivityID = nil
    LeftCount = nil 
    CountMax = nil 

    MissionInfo = nil 
    PreMission = nil
    missions = nil
    Global.CloseUI(_M)
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
    _ui = nil
end

function CloseAll()
    Hide()
end


function Awake()
    _ui = {}
end


function Show(id,leftcount,countMax)
	print(id)
    PreMission = nil
    ActivityID = id
    LeftCount = leftcount
    CountMax = countMax
    Global.OpenUI(_M)
    print(ActivityID)
    local data = ActivityData.GetActivityData(ActivityID)
    if data == nil then
        ActivityData.RequestActivityData(ActivityID,LoadUI)
    else
        LoadUI()
    end
end

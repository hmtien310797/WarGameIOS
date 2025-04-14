module("RebelSurround",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String
local AudioMgr = Global.GAudioMgr
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local SetDragCallback = UIUtil.SetDragCallback

local _ui
local BuildPosData
local MonsterIdsData
local isPlayAnimation = false
local AttackTime = 10
local CanFight = true
local isScout = false

--Fight state
--1 战斗无效 
--0 等待叛军到来
--1 兵力不足
--2 兵力满足
local FightState = {
    Invaild = -1,
    WaitEnemy = 0,
    Ready = 1,
}

local FightTagColor = {
    "[FF0000FF]",
    "[00FF1EFF]"
}

local RewardItemTrfName = {
    "Grid01/Item_CommonNew",
    "Grid01/Item_CommonNew (1)",
    "Grid01/Item_CommonNew (2)"
}

local RewardListTrfName ={
    "Container/bg/left/Grid/left_list",
    "Container/bg/left/Grid/left_list (1)",
    "Container/bg/left/Grid/left_list (2)",
}

local RewardBtnBgName = {
    "btn_4",
    "btn_2",
    "btn_4",
    "btn_4"
}

local FightBtnName = {
    "btn_1",
    "btn_3",
    "btn_4",
}

local CheckText ={
    CheckDes = "RebelSurround_23",
    CheckAddArmy = "RebelSurround_24",
    CheckFight ="ui_barrack_btn2",

}

RebelSurroundGuideId ={
    1,
    2,
    3,
    4,
}

local _FState = FightState.Invaild


local RefrushLvlInfo
local RefrushFire
local PlayerCoroutine
UpdateRewardRed = nil

function GetUI()
    return _ui
end

local function SetLookAtCoord(mapX, mapY)
    if _ui == nil then
        return
    end    
    _ui.mapMgr:GoPos(mapX, mapY)
end

function GetMonsterIdsData()
    return MonsterIdsData
end

local function LoadData()
    if BuildPosData == nil then
        BuildPosData = {}
        local pos_str = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.RebelSurroundPos).value
        local posdata = string.split(pos_str,';')
        if #posdata == 2 then
            local pos = string.split(posdata[1],',')
            BuildPosData[1] = {}
            BuildPosData[1].mapX = tonumber(pos[1])
            BuildPosData[1].mapY = tonumber(pos[2])
            pos = string.split(posdata[2],',')
            BuildPosData[2] = {}
            BuildPosData[2].mapX = tonumber(pos[1])
            BuildPosData[2].mapY = tonumber(pos[2])            
        end
    end
    if MonsterIdsData == nil then
        MonsterIdsData = {}
        local id_str = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.RebelSurroundMonster).value
        local ids = string.split(id_str,',')
        for i = 1,#ids do
            table.insert(MonsterIdsData, tonumber(ids[i]))
        end
    end    
end

function Scout()
    isScout = true
end

function CanShowEnemyFormation()
    return isScout
end

function AttackMonsterPath(level,mname,show,time,showWarning)
    if _ui == nil then
        return
    end    
    local monster_level = level
    local monster_name = mname
    _ui.mapMgr:ClearPathData()
    local sx = BuildPosData[2].mapX
    local sy = BuildPosData[2].mapY
    local tx = BuildPosData[1].mapX
    local ty = BuildPosData[1].mapY
    local entry = Common_pb.SceneEntryType_Home
    if show ~= nil and show then
        sx = BuildPosData[2].mapX - math.abs(BuildPosData[2].mapX - BuildPosData[1].mapX)
        sy = BuildPosData[2].mapY + math.abs(BuildPosData[2].mapY - BuildPosData[1].mapY)
        tx = BuildPosData[2].mapX
        ty = BuildPosData[2].mapY
        entry = Common_pb.SceneEntryType_Barrack
    end
    _ui.mapMgr:SetPathData(sx,sy,tx,ty,
    monster_name,
    entry,
    Serclimax.GameTime.GetSecTime(),
    time == nil and AttackTime or time,nil)
    _ui.mapMgr:DrawLine()
    PlayerAttackAnimation(time == nil and AttackTime or time,showWarning)
end

function AttackPlayerPath(level,mname,time)
    if _ui == nil then
        return
    end    
    local monster_level = level
    local monster_name = mname
    _ui.mapMgr:ClearPathData()
    _ui.mapMgr:SetPathData(BuildPosData[1].mapX,BuildPosData[1].mapY,BuildPosData[2].mapX,BuildPosData[2].mapY,
    MainData.GetCharName(),
    Common_pb.SceneEntryType_Monster,
    Serclimax.GameTime.GetSecTime(),
    time == nil and AttackTime or time,UnionInfoData.HasUnion() and UnionInfoData.GetData().guildInfo.banner or nil)
    _ui.mapMgr:DrawLine()
    PlayerAttackAnimation(time == nil and AttackTime or time,false)
end

function RemoveMonster()
    if _ui == nil then
        return
    end
    _ui.mapMgr:RemoveHomeData(BuildPosData[2].mapX,BuildPosData[2].mapY)
    _ui.mapMgr:UpdateSprite()
end

function AddMonster(level)
    if _ui == nil then
        return
    end    
    print("AddMonster ",level)
    local monster_level = level
    local monster_name = TextMgr:GetText("RebelSurroundname_"..level)
    _ui.mapMgr:SetHomeData(BuildPosData[2].mapX,BuildPosData[2].mapY,
    monster_name,
    monster_level,
    nil,
    MonsterIdsData[monster_level])   
    if monster_level == #MonsterIdsData and ConfigData.GetRebelSurroundConfig()==2 then
        Global.GGuideManager:StartGuide(RebelSurroundGuideId[3],nil,nil)
        ConfigData.SetRebelSurroundConfig(3);
    end          
end

function ShowHomeFire()
    _ui.mapMgr:ShowEffect(BuildPosData[1].mapX,BuildPosData[1].mapY,100)
    _ui.mapMgr:UpdateSprite()
end

function HideHomeFire()
    _ui.mapMgr:HideEffect(BuildPosData[1].mapX,BuildPosData[1].mapY)
    _ui.mapMgr:UpdateSprite()
end

function ShowPreviewMonster()
    if _ui == nil then
        return
    end    
    local sx = BuildPosData[2].mapX - math.abs(BuildPosData[2].mapX - BuildPosData[1].mapX)
    local sy = BuildPosData[2].mapY + math.abs(BuildPosData[2].mapY - BuildPosData[1].mapY)
    local tx = BuildPosData[2].mapX
    local ty = BuildPosData[2].mapY
     _ui.mapMgr:SetCustomLine("preview",sx,sy,tx,ty,Color.red,5)    
end

function HidePreviewMonster()
    if _ui == nil then
        return
    end    
     _ui.mapMgr:RemoveCustomLine("preview")
 end

function ShowMonster(level,mname,time)
    if _ui == nil then
        return
    end    
    HidePreviewMonster()
    AttackMonsterPath(level,mname,true,time,false)
    print("ShowMonster",level)
    local ll = level
    coroutine.start(function()
        coroutine.wait(time)
        local data = RebelSurroundData.GetData()
        if data.passAll then
            return
        end        
        if _ui ~= nil then
            AddMonster(ll)
            _ui.mapMgr:UpdateSprite()
        end
    end)
end

local function SetWorldMapData()
    
    _ui.mapMgr:SetHomeData(BuildPosData[1].mapX,BuildPosData[1].mapY,
    MainData.GetCharName(),
    maincity.GetBuildingByID(1).data.level,
    UnionInfoData.HasUnion() and UnionInfoData.GetData().guildInfo.banner or nil,-1)
    
    local data = RebelSurroundData.GetData()
    if data.passAll then
        return
    end
    if Serclimax.GameTime.GetSecTime() < data.levelInfo.startTime then
        local t = data.levelInfo.startTime - Serclimax.GameTime.GetSecTime()
        if t < 4 then
            AddMonster(data.curLevel)
        elseif t>=4 and t<10 then
            ShowMonster(data.curLevel,TextMgr:GetText("RebelSurroundname_"..data.curLevel),t)
        else
            ShowPreviewMonster()
        end
    else
        AddMonster(data.curLevel)
    end
end

function PlayerAttackAnimation(time,showWarning)
    if isPlayAnimation then
        return
    end
    time =time + 2.5
    isPlayAnimation = true
    if showWarning then
        RadarData.SetForceWarningType(2)
        _ui.warning.gameObject:SetActive(AudioMgr.SfxSwith)
    end
    if PlayerCoroutine ~= nil then
        coroutine.stop(PlayerCoroutine)
        PlayerCoroutine = nil
    end
    PlayerCoroutine = coroutine.start(function()
        coroutine.wait(time)
        if showWarning then
            RadarData.SetForceWarningType(nil)
            _ui.warning.gameObject:SetActive(false)        
        end
        isPlayAnimation = false
        PlayerCoroutine = nil
        ShowBattleResult()
    end)

    isPlayAnimation = true
end

function UpdateToNextWave()
    local battleResult = RebelSurroundData.GetBattleResult()
    if battleResult ~= nil then
        local reward = RebelSurroundData.GetRewardList()
        local winlose =  RebelSurroundData.GetWinLose(battleResult)
        if winlose == 1 then
            local level = battleResult.level
            local wave = battleResult.wave
            
            if reward[level].sortWave[wave].status == 1 then
                reward[level].sortWave[wave].status =2
            end  
            local data = RebelSurroundData.GetData()
            if data.levelInfo.waveInfos[wave].type == 2  then
                if battleResult.battleTime <= data.levelInfo.fastEndTime then
                    if reward[level].msg.fastReward.status == 1 then
                        reward[level].msg.fastReward.status =2
                    end  
                end
            end
        end            
    end

    MainCityUI.UpdateRebelSurroundRed()
    RebelSurroundData.ResetUpdateNextWaveDone()
    if not RebelSurroundData.UpdateToNextWave() then
        RebelSurroundData.RequestSimpleData(function() 
            if _ui == nil then
                return 
            end
            local data = RebelSurroundData.GetData()
            RemoveMonster()
            if not data.passAll then
                ShowPreviewMonster() 
            end
            if battleResult.level == #MonsterIdsData and ConfigData.GetRebelSurroundConfig()==3 then
                Global.GGuideManager:StartGuide(RebelSurroundGuideId[4],nil,nil)
                ConfigData.SetRebelSurroundConfig(4);
            end             
            if battleResult.level == 1 and ConfigData.GetRebelSurroundConfig()==1 then
                Global.GGuideManager:StartGuide(RebelSurroundGuideId[2],nil,nil)
                ConfigData.SetRebelSurroundConfig(3);
            end            
            RefrushLvlInfo()
        end)
    else
        RefrushLvlInfo()
    end
end

function ShowBattleResult()
    if _ui == nil  then
        UpdateToNextWave()
        return
    end
    if  isPlayAnimation then
        return 
    end
    if RebelSurroundData.GetBattleResult() == nil then
        return
    end
    RebelSurround_report.Show( function(success)
        if success and RebelSurroundData.GetUpdateNextWaveDone() then        
            UpdateToNextWave()
        else
            RefrushFire()
            CanFight = true
            RebelSurroundData.ClearBattleResult()
        end
        if RebelSurroundrewardList.isOpen() then
            local data = RebelSurroundData.GetData()
            RebelSurroundrewardList.SelectLevel(data.curLevel)
        end
    end)
    MainCityUI.BringForward()
end



function RefrushRewardItem(trf,level,rewardDetail,simple,fastEndTime,takeCallBack)
    --print("RefrushRewardItem   ",level)
    local reward_name = trf:Find("reward01")
    reward_name.gameObject:SetActive(false)
    local none = trf:Find("none01")
    none.gameObject:SetActive(false)
    local time = trf:Find("time"):GetComponent("UILabel")
    time.gameObject:SetActive(false)
    local btn = trf:Find("button01")
    local get_btn = trf:Find("button02")
    if get_btn ~= nil then
        get_btn.gameObject:SetActive(false)
    end
    btn.gameObject:SetActive(false)
    local grid = trf:Find("Grid01")
    grid.gameObject:SetActive(false)

    if simple then
        reward_name.gameObject:SetActive(true)
    else
        btn.gameObject:SetActive(true)
        local btn_bg = btn:GetComponent("UIButton")
        btn_bg.normalSprite = RewardBtnBgName[rewardDetail.status]   
        if  rewardDetail.status == 3 and get_btn ~= nil then
            btn.gameObject:SetActive(false)
            get_btn.gameObject:SetActive(true)
        else
            SetClickCallback(btn.gameObject,function()
                local rewards = RebelSurroundData.GetRewardList()
                if rewardDetail.wave == 0 then
                    if rewards[level].msg.fastReward.status == 2  then
                        RebelSurroundData.RequestTakeFastReward(level,takeCallBack)
                    end
                else
                    if rewards[level].sortWave[rewardDetail.wave].status == 2  then
                        RebelSurroundData.RequestTakeWaveReward(level,rewardDetail.wave,takeCallBack)
                    end
                end
            end)         
        end
  
    end
    if fastEndTime ~= nil  then
        if simple and _FState == FightState.WaitEnemy then
            time.gameObject:SetActive(false)
        else
            time.gameObject:SetActive(true)
            local countName = "fastEndTime_Simple"
            if not simple then
                countName = "fastEndTime"
            end
            CountDown.Instance:Add(countName,fastEndTime,CountDown.CountDownCallBack(function(t)
                    time.text  = String.Format(TextMgr:GetText("RebelSurround_30"), t)
                    if fastEndTime+1 - Serclimax.GameTime.GetSecTime() <= 0 then
                        rewardDetail.status = 4
                        CountDown.Instance:Remove(countName)
                        time.text = TextMgr:GetText("RebelSurround_39")
                    end			
                end)
            )            
        end

    end
    if rewardDetail.wave == 0 and rewardDetail.status == 4 then
        time.gameObject:SetActive(true)
        time.text = TextMgr:GetText("RebelSurround_39")
    end

    if _FState == FightState.WaitEnemy and simple then
        none.gameObject:SetActive(true)
    else
        grid.gameObject:SetActive(true)
        local items = {}
        for i=1,3 do
            items[i] = trf:Find(RewardItemTrfName[i])
            items[i].gameObject:SetActive(false)
        end

        for i = 1,#rewardDetail.reward.items do
            if items[i] ~= nil then
                local itemparam = {baseid = rewardDetail.reward.items[i].id,
                                   count = rewardDetail.reward.items[i].num}
                UIUtil.LoadItemInfo(items[i], itemparam,nil,function(go)
                    SetClickCallback(go.gameObject , function(go_obj)
                        if go_obj == _ui.tipObject then
                            _ui.tipObject = nil
                        else
                            
                            local itemData = TableMgr:GetItemData(itemparam.baseid)
                            if itemData ~= nil then
                                _ui.tipObject = go_obj
                                Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)}) 
                            else
                                _ui.tipObject = nil
                            end
                        end
                    end)
                end)  
                items[i].gameObject:SetActive(true)    
            end
        end    
    end
end

RefrushFire = function()
    local data = RebelSurroundData.GetData()
    if data.lastAgainstFailTime == nil then
        return 
    end
    if Serclimax.GameTime.GetSecTime() < data.lastAgainstFailTime + 300 then
        ShowHomeFire()
        CountDown.Instance:Add("FireTime",data.lastAgainstFailTime + 300,CountDown.CountDownCallBack(function(t)
            if data.lastAgainstFailTime + 300 - Serclimax.GameTime.GetSecTime() <= 0 then
                CountDown.Instance:Remove("FireTime")
                HideHomeFire()
            end			
        end)
        )  
    end
end

RefrushLvlInfo = function()
    if _ui == nil then
        return
    end
    UpdateRewardRed()
    local data = RebelSurroundData.GetData()
    local rewards = RebelSurroundData.GetRewardList()
    Global.Check(data == nil,"########### RebelSurroundData is nil")

    if data.passAll then
        _ui.TipText.gameObject:SetActive(false)
        local maxLevel = 5
        local maxWave = 4
        _ui.fightBtnSprite.normalSprite = FightBtnName[3]
        _ui.fightBackBtnSprite.normalSprite = FightBtnName[3]        
        _ui.TopText.text = ""
        _ui.enemyIcon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/","icon_lawn")
        _ui.LevelName.text = TextMgr:GetText("RebelSurround_40")
        _ui.remainCount.text = TextMgr:GetText("RebelSurround_40")    
        _ui.armyCount.text = TextMgr:GetText("RebelSurround_40")
        --迎戰獎勵
        RefrushRewardItem(_ui.rewardList[1],maxLevel,rewards[maxLevel].sortWave[maxWave],true)
        --反擊獎勵
        RefrushRewardItem(_ui.rewardList[2],maxLevel,rewards[maxLevel].sortWave[maxWave],true)
        --快速通關獎勵
        RefrushRewardItem(_ui.rewardList[3],maxLevel,rewards[maxLevel].msg.fastReward,true,nil)
        return
    end
    isScout = false
    CanFight = true
    local curArmyCount = Barrack.GetRealArmyNum()
    print(curArmyCount)
    _FState = FightState.Invaild
    _ui.TipText.gameObject:SetActive(false)
    _ui.TopText.text = TextMgr:GetText("RebelSurround_2")
    local artSettingData = TableMgr:GetArtSettingData(MonsterIdsData[data.curLevel])
    _FState = FightState.Ready
    _ui.enemyIcon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", artSettingData.icon)
    if Serclimax.GameTime.GetSecTime() < data.levelInfo.startTime then
        _ui.LevelName.text = TextMgr:GetText("Embassy_ui9")
        _ui.remainCount.text = "------"
        _FState = FightState.WaitEnemy
        _ui.TipText.gameObject:SetActive(true)
        _ui.TopText.text = String.Format(TextMgr:GetText("RebelSurround_20"),TextMgr:GetText("RebelSurroundname_"..(math.max(1, data.curLevel-1))))
		CountDown.Instance:Add("WaitEnemy",data.levelInfo.startTime,CountDown.CountDownCallBack(function(t)
            _ui.TipText.text  = String.Format(TextMgr:GetText("RebelSurround_19"), t)
            local time = data.levelInfo.startTime - Serclimax.GameTime.GetSecTime()
            if time == 10 and not isPlayAnimation then
                ShowMonster(data.curLevel,TextMgr:GetText("RebelSurroundname_"..data.curLevel),time)
            end
            if data.levelInfo.startTime+1 - Serclimax.GameTime.GetSecTime() <= 0 then
                CountDown.Instance:Remove("WaitEnemy")
                RefrushLvlInfo()
            end			
        end)
        )  
    else
        _ui.LevelName.text = TextMgr:GetText("RebelSurroundname_"..data.curLevel)
        local tw = RebelSurroundData.GetCurWaveTotalCount()
        _ui.remainCount.text =math.max(0,tw - data.curWave+1) .."/"..RebelSurroundData.GetCurWaveTotalCount()
    end
    --_FState = FightState.ArmyRed
    local fc = FightTagColor[1]
    if curArmyCount >= data.levelInfo.waveInfos[data.curWave].recommendSoldier then
        --_FState = FightState.ArmyGreen
        fc = FightTagColor[2]
    end
    if _FState == FightState.WaitEnemy or _FState == FightState.Invaild then
        _ui.fightBtnSprite.normalSprite = FightBtnName[3]
        _ui.fightBackBtnSprite.normalSprite = FightBtnName[3]
    elseif RebelSurroundData.IsCurWavePlayerFight() then
        _ui.fightBtnSprite.normalSprite = FightBtnName[3]
        _ui.fightBackBtnSprite.normalSprite = FightBtnName[2]
    else
        _ui.fightBtnSprite.normalSprite = FightBtnName[1]
        _ui.fightBackBtnSprite.normalSprite = FightBtnName[3]
    end

    _ui.armyCount.text = fc..curArmyCount.."[-]".."/"..data.levelInfo.waveInfos[data.curWave].recommendSoldier    
    --迎戰獎勵
    RefrushRewardItem(_ui.rewardList[1],data.curLevel,rewards[data.curLevel].sortWave[data.curWave],true)
    --反擊獎勵
    for i =1,#rewards[data.curLevel].sortWave do
        if data.levelInfo.waveInfos[i].type == 2 then
            RefrushRewardItem(_ui.rewardList[2],data.curLevel,rewards[data.curLevel].sortWave[i],true)
            break
        end
    end
    --快速通關獎勵
    RefrushRewardItem(_ui.rewardList[3],data.curLevel,rewards[data.curLevel].msg.fastReward,true,data.levelInfo.fastEndTime)
    RefrushFire()
end



UpdateRewardRed = function()
    if _ui == nil then
        return
    end
    if RebelSurroundData.GetCanTakeRewardCount() > 0 then
        _ui.rewardCenterRed.gameObject:SetActive(true)
    else
        _ui.rewardCenterRed.gameObject:SetActive(false)
    end
end

function JumpToBarrack()
    for i = 1,4,1 do
        local barrack =maincity.GetBuildingByID(20+i)
        if barrack ~= nil then
            if Barrack.GetTrainInfo(20+i) == nil then
                Barrack.OnCloseCB = function() 
                    RefrushLvlInfo()    
                end
                Barrack.Show(20+i)
                return
            end
        end
    end
    Barrack.OnCloseCB = function() 
        RefrushLvlInfo()    
    end    
    Barrack.Show(21)
end

function CheckArmy(fight_callBack,showBox_callBack)
    local data = RebelSurroundData.GetData()
    local totalArmyNum = Barrack.GetRealArmyNum()
    if totalArmyNum >= data.levelInfo.waveInfos[data.curWave].recommendSoldier then
        if fight_callBack ~= nil then
            fight_callBack()
        end    
        return
    end
    _ui.msgBox_Root.gameObject:SetActive(true)
    if showBox_callBack ~= nil then
        showBox_callBack()
    end
    SetClickCallback(_ui.msgBox_Cancel.gameObject,function(go)
        _ui.msgBox_Root.gameObject:SetActive(false)
        if fight_callBack ~= nil then
            fight_callBack()
        end   
    end)      
    SetClickCallback(_ui.msgBox_Ok.gameObject,function(go)
        _ui.msgBox_Root.gameObject:SetActive(false)
        JumpToBarrack()
    end)              
end

function FightBack(go,showBox_callBack)
    if isPlayAnimation or not CanFight then
        return
    end
    if _FState == FightState.WaitEnemy or _FState == FightState.Invaild then
        if go ~= nil then
            FloatText.ShowOn(go, TextMgr:GetText("RebelSurround_28"), Color.red)
        end
        
        --MessageBox.Show(TextMgr:GetText("RebelSurround_28"))
        return 
    end    
    local data = RebelSurroundData.GetData()
    if RebelSurroundData.IsCurWavePlayerFight() then
        
        CheckArmy(function() 
            CanFight = false
            BattleMove.Show4RebelSurround(function() CanFight = true end)
        end,showBox_callBack)
    else
        if go ~= nil then
            FloatText.ShowOn(go, TextMgr:GetText("RebelSurround_26"), Color.red)
        end        
        --MessageBox.Show(TextMgr:GetText("RebelSurround_26"))
    end
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

function Awake()
    _ui = {}
    _ui.mapMgr = WorldMapMgr.Instance
    _ui.mapMgr.isFirst = true
    _ui.mapMgr:SetSelfInfo(MainData.GetCharId(), UnionInfoData.GetGuildId())
    _ui.worldCamera = _ui.mapMgr.transform:Find("WorldCamera/Main Camera"):GetComponent("Camera")
    _ui.uiCamera = NGUITools.FindCameraForLayer(gameObject.layer)
     SetClickCallback(transform:Find("Container/close btn").gameObject,function()
        MainCityUI.HideRebelSurround(true, MainCityUI.WorldMapCloseCallback,true)
    end)
    _ui.msgBox_Root = transform:Find("box")
    _ui.msgBox_Root.gameObject:SetActive(false)
    _ui.msgBox_mask = transform:Find("box/mask")
    SetClickCallback(_ui.msgBox_mask.gameObject,function(go)
        _ui.msgBox_Root.gameObject:SetActive(false)
    end)    
    _ui.msgBox_Ok = transform:Find("box/bg/btn_cancel")
  
    _ui.msgBox_Cancel = transform:Find("box/bg/btn_confirm")
 

    _ui.LevelName = transform:Find("Container/bg/right/Label (1)/Label (2)"):GetComponent("UILabel")
    _ui.enemyIcon = transform:Find("Container/bg/right/Texture"):GetComponent("UITexture")
    _ui.remainCount = transform:Find("Container/bg/right/Label (2)/Label (2)"):GetComponent("UILabel")
    _ui.armyCount = transform:Find("Container/bg/right/Label (3)/Label (2)"):GetComponent("UILabel")
    _ui.TipText = transform:Find("Container/bg/top_text02"):GetComponent("UILabel")
    _ui.TopText = transform:Find("Container/bg/top_text"):GetComponent("UILabel")
    _ui.rewardCenterRed = transform:Find("Container/bg/left/rewardcenter/red")
    _ui.warning = transform:Find("Container/bg/warning")
    _ui.warning.gameObject:SetActive(false)
    _ui.rewardList={}
    for i=1,3 do
        _ui.rewardList[i] = transform:Find(RewardListTrfName[i])
    end

    --按钮
    _ui.fightBtn = transform:Find("Container/bg/right/button_start")
    _ui.fightBtnSprite = _ui.fightBtn:GetComponent("UIButton")
    SetClickCallback(_ui.fightBtn.gameObject,function(go)
        if isPlayAnimation or not CanFight then
            return
        end  

        local totalArmyNum = Barrack.GetRealArmyNum()
        if totalArmyNum == 0 then
            return FloatText.ShowOn(go, TextMgr:GetText("RebelSurround_43"), Color.red)
        end
        if _FState == FightState.WaitEnemy or _FState == FightState.Invaild then

            if go ~= nil then
                FloatText.ShowOn(go, TextMgr:GetText("RebelSurround_28"), Color.red)
            end                 
            --MessageBox.Show(TextMgr:GetText("RebelSurround_28"))
            return 
        end
        local data = RebelSurroundData.GetData()
        if RebelSurroundData.IsCurWaveMonsterFight() then
            
            CheckArmy(function() 
                CanFight = false
                local req = BattleMsg_pb.MsgMonsterSurroundStartBattleRequest()
                RebelSurroundData.RequsetSurroundStartBattle(req,function(success)
                    if success then
                        AttackMonsterPath(data.curLevel,TextMgr:GetText("RebelSurroundname_"..data.curLevel),nil,nil,true)
                    end
                end)
            end)
        else
            if go ~= nil then
                FloatText.ShowOn(go, TextMgr:GetText("RebelSurround_27"), Color.red)
            end                 
            --MessageBox.Show(TextMgr:GetText("RebelSurround_27"))
        end
        
    end)
    _ui.fightBackBtn = transform:Find("Container/bg/right/button_fightback")
    _ui.fightBackBtnSprite = _ui.fightBackBtn:GetComponent("UIButton")
    SetClickCallback(_ui.fightBackBtn.gameObject,function(go)
        FightBack(go)
    end)
    _ui.heroBtn = transform:Find("Container/bg/right/button_hero")
    SetClickCallback(_ui.heroBtn.gameObject,function()

        local _building = maincity.GetBuildingByID(26)
        if _building == nil then
            MainCityUI.HideRebelSurround(true,  function() 
                MainCityUI.WorldMapCloseCallback()
                GrowGuide.Show(maincity.SetTargetBuild(26, true, nil, false).land.transform)
            end,true)
        else
            WallHero.Show(Common_pb.BattleTeamType_CityDefence)
        end
    end)

    _ui.rewardCenter = transform:Find("Container/bg/left/rewardcenter")
    SetClickCallback(_ui.rewardCenter.gameObject,function()
        RebelSurroundrewardList.Show()
    end)
    
    _ui.strategyBtn = transform:Find("Container/bg/button_strategy")
    SetClickCallback(_ui.strategyBtn.gameObject,function()
        RebelSurround_ins.Show()
    end)


    _ui.homeBtn = transform:Find("Container/bg/home")
    SetClickCallback(_ui.homeBtn.gameObject,function()
        RebelSurrounddefenceshow.Show()
    end)    

    _ui.enemyBtn = transform:Find("Container/bg/enemy")
    SetClickCallback(_ui.enemyBtn.gameObject,function()
        local data = RebelSurroundData.GetData()
        if not data.passAll and Serclimax.GameTime.GetSecTime() >= data.levelInfo.startTime then
            RebelSurround_TileInfo.Show()
        end
    end)      
    _ui.addAmryNum = transform:Find("Container/bg/right/Sprite")
    SetClickCallback(_ui.addAmryNum.gameObject,function()
        JumpToBarrack()
    end)          
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)    
end

local needUpdateWorldMapData = false
function Start()
    isPlayAnimation = false
  
end

function Update()
    if needUpdateWorldMapData then
        RefrushLvlInfo()
        ShowBattleResult()          
        SetWorldMapData()  
        needUpdateWorldMapData = false
    end
end

function Hide()
    Global.CloseUI(_M)
end

function Close()
    if PlayerCoroutine ~= nil then
        coroutine.stop(PlayerCoroutine)
        PlayerCoroutine = nil
    end    
    RadarData.SetForceWarningType(nil)
    _ui.warning.gameObject:SetActive(false)   
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()    
    isPlayAnimation = false
    Global.GGuideManager:SaveGuideProcess()
    MainCityUI.CheckRebelSurroundBtn()
    MainCityUI.ShowMainCityUIBtn()
    RebelSurround_report.Hide()
    MainCityUI.DestroyTerrain()
    CountDown.Instance:Remove("FireTime")
    CountDown.Instance:Remove("WaitEnemy")
    CountDown.Instance:Remove("fastEndTime_Simple")
    CountDown.Instance:Remove("fastEndTime")
    Global.GGuideManager:Clear()
    _ui = nil
end

local function _Show(mapX,mapY)
    Global.OpenUI(_M)	
    SetLookAtCoord(mapX, mapY)
    LoadData()
    needUpdateWorldMapData = true
    if MainCityUI.gameObject ~= nil then
        GUIMgr:BringForward(MainCityUI.gameObject)
    end
end

function Show(mapX,mapY,enterCallBack)
    local data = RebelSurroundData.GetData()
    if data == nil then
        RebelSurroundData.RequestData(function() 
            _Show(mapX,mapY)
            if enterCallBack ~= nil then
                enterCallBack()
            end
        end)
    else
        _Show(mapX,mapY)
        if enterCallBack ~= nil then
            enterCallBack()
        end        
    end
end

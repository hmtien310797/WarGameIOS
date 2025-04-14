module("PVP_SLG", package.seeall)

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

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local panel_hud
local IsDestroy

local FullSkipBtn
local SkipBtn
local TopUI
local NextBtn
local enableCameraDrag

local SkillEffect;
local SkipCoroutine
local DelayShowTHpTime = 0.25

local playerinfos
local result

local THps0
local THps1
local K

local heroPathStr = {
    "Container/bg_frane/hero/listitem_hero/GameObject/left_0",
    "Container/bg_frane/hero/listitem_hero (1)/GameObject (1)/left_0",
    "Container/bg_frane/hero/listitem_hero (2)/GameObject (2)/left_0",
    "Container/bg_frane/hero/listitem_hero (3)/GameObject (3)/left_0",
    "Container/bg_frane/hero/listitem_hero (4)/GameObject (4)/left_0",
    "Container/bg_frane/hero/listitem_hero (5)/Game_lan/left_0",
    "Container/bg_frane/hero/listitem_hero (6)/Game_lan (1)/left_0",
    "Container/bg_frane/hero/listitem_hero (7)/Game_lan (2)/left_0",
    "Container/bg_frane/hero/listitem_hero (8)/Game_lan (3)/left_0",
    "Container/bg_frane/hero/listitem_hero (9)/Game_lan (4)/left_0",
}

local heroEffectPathStr = {
    "Container/bg_frane/hero/listitem_hero/GameObject/hong_1",
    "Container/bg_frane/hero/listitem_hero (1)/GameObject (1)/hong_1",
    "Container/bg_frane/hero/listitem_hero (2)/GameObject (2)/hong_1",
    "Container/bg_frane/hero/listitem_hero (3)/GameObject (3)/hong_1",
    "Container/bg_frane/hero/listitem_hero (4)/GameObject (4)/hong_1",
    "Container/bg_frane/hero/listitem_hero (5)/Game_lan/lan",
    "Container/bg_frane/hero/listitem_hero (6)/Game_lan (1)/lan",
    "Container/bg_frane/hero/listitem_hero (7)/Game_lan (2)/lan",
    "Container/bg_frane/hero/listitem_hero (8)/Game_lan (3)/lan",
    "Container/bg_frane/hero/listitem_hero (9)/Game_lan (4)/lan",
}

local function InitBattleCamera()
	
    local cameraTransform = TopUI.mainCamera.transform
    local cameraMove = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PvPBattleCameraMove).value
	local move = string.split(cameraMove , ",")
	if TopUI.minX == nil or TopUI.maxX == nil or TopUI.offset == nil then
		TopUI.minX =  cameraTransform.localPosition.x -6 --tonumber(move[1])
		TopUI.maxX =  cameraTransform.localPosition.x + 6--tonumber(move[2])
		TopUI.offset = 0
		TopUI.battleCamera = BattleCamera(TopUI.mainCamera, TopUI.minX, TopUI.maxX,  cameraTransform.localPosition.y, cameraTransform.localPosition.y, cameraTransform.localPosition.z, cameraTransform.localPosition.z)
	end
end


local function OnGameOver()
    --print("GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG",Global.IsSLGPVPBattleWaveState())
    if SkipCoroutine ~= nil then
        coroutine.stop(SkipCoroutine)
        SkipCoroutine = nil 
    end    
    if Global.IsSLGPVPBattleWaveState() then
        BattlefieldReport.ExeExitCallBack()
        return 
    end
    -- if ConfigData.GetGameStateTutorial() == false then
    --     MainCityUI.StartTeachBattle()
    -- else
    local curP4pve = Global.GetCurrentP4PVEMsg()
	if curP4pve ~= nil and curP4pve.id ~= nil and curP4pve.result ~= nil then
		WinLose.SetBattleId(curP4pve.id)
		WinLose.SetBattleRewards(curP4pve.result.data)	
		UnlockArmyData.RequestData(function(unlist)
			SoldierUnlock.UnlockArmy(unlist)
		end) 
		WinLose.Show()
	else
        if not BattlefieldReport.Show() then
            Global.QuitSLGPVP(function()
                BattlefieldReport.ExeExitCallBack()
            end)
        end
	end
    -- end
end

local function onGameOver_Debug(result)
    if SkipCoroutine ~= nil then
        coroutine.stop(SkipCoroutine)
        SkipCoroutine = nil 
    end    
     --print("DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD",Global.IsSLGPVPBattleWaveState())
    if Global.IsSLGPVPBattleWaveState() then
        BattlefieldReport.ExeExitCallBack()
        return 
    end    
    -- if ConfigData.GetGameStateTutorial() == false then
    --     MainCityUI.StartTeachBattle()
    -- else    
        if ConfigData.GetGameStateTutorial() == false then
            local resultMsg = Common_pb.SceneBattleResult()
            resultMsg:ParseFromString(result)       
            BattlefieldReport.SetBattleResult(resultMsg,nil)
        end
        if not BattlefieldReport.Show() then
            Global.QuitSLGPVP(function()
                BattlefieldReport.ExeExitCallBack()
            end)
        end  
    -- end
      
end

local function OnShowBeatHurt(pos,type,hurt)
    if IsDestroy then
        return
    end
    local lhurt = math.floor(K*hurt + 1)
    print(lhurt,hurt)
    if type < 0 then
        BeatText.ShowNormal(pos,lhurt,Color.New(0,192/255,1,1))
    elseif type == 0 then
        BeatText.ShowNormal(pos,lhurt,Color.yellow)
    else
        BeatText.ShowBeat(pos,lhurt,Color.red)
    end
end

local showAnim = false
local preHps = nil
local function OnShowBattleState(round,hps)
	
	enableCameraDrag = true
	InitBattleCamera()
	
    --print(hps,hps[0],hps[1])
    --
    if THps0 == nil then
        THps0 = {}
    end
    if THps1 == nil then
        THps1 = {}
    end
    
    --if #THps ~= 0 then
        local pre =preHps
        local count = 6
        local pre0 = pre == nil and 1 or pre[0]
        local pre1 = pre == nil and 1 or pre[1]
        local h0 =   (pre == nil and 1 or pre[0]) - hps[0];
        if h0 >= 0 then
        end
        local h1 =   (pre == nil and 1 or pre[1]) - hps[1];

        --print(hps[0],hps[1],h0,h1,(pre == nil and 1 or pre[0]),(pre == nil and 1 or pre[1]))
        if h0 >= 0.0001 and h0 < 1  then
            for i =1,count do
                table.insert(THps0,pre[0] - (i/count)*(h0))
            end
        else
            if  h0 >= 0 then
                table.insert(THps0,hps[0])
            end
        end

        if h1 >= 0.0001 and h1 < 1 then
            for i =1,count do
                table.insert(THps1,pre[1] - (i/count)*(h1))
            end
        else
            if h1 >= 0 then
                table.insert(THps1,hps[1])
            end
        end
        if preHps == nil then
            preHps = {}
        end
        if h0 >= 0 then
            preHps[0] = hps[0]
        end
        if h1 >= 0 then
            preHps[1] = hps[1]
        end        
    --else
    --    table.insert(THps,hps)
    --end
    if not showAnim then
        coroutine.start(function()
            local i =1
            while THps0[i] or THps1[i] do
                coroutine.wait(DelayShowTHpTime)
                if(TopUI == nil) then
                    return
                end
                if THps0[i] ~= nil then                    
                    --print(0,THps0[i],#THps0)
                    TopUI.attack.hp.value = THps0[i]
                    UIAnimManager.instance:AddUIProgressBarAnim(TopUI.attack.shp, TopUI.attack.shp.value, THps0[i], 0.5, 0.5)
                    table.remove(THps0,i)
                end
                if THps1[i] ~= nil then
                    --print(1,THps1[i],#THps1)
                    TopUI.defend.hp.value = THps1[i]
                    UIAnimManager.instance:AddUIProgressBarAnim(TopUI.defend.shp, TopUI.defend.shp.value, THps1[i], 0.5, 0.5)

                    table.remove(THps1,i)
                end    
            end
            showAnim = false
        end)
    end


    TopUI.vs.text = round.."/200"
end

local function onSkipShowHeroFinish()
    FullSkipBtn.gameObject:SetActive(false)
    local battleState = GameStateSLGBattle.Instance
    if battleState.heroBuffs ~= nil then
        --[[TopUI.heroAnim = TopUI.hero:GetComponent("Animator")
        if TopUI.heroAnim ~= nil then
            print("TopUI.heroAnim  ",TopUI.heroAnim)
            local stateInfo = TopUI.heroAnim:GetCurrentAnimatorStateInfo(0)
            print("stateInfo  ",stateInfo.length,stateInfo.normalizedTime)
            TopUI.heroAnim:Play("jinchang",-1,6.5/stateInfo.length)
            --stateInfo.normalizedTime = 
        end     
        ]]--
        for i =1,10 do
            TopUI.heros[i].gameObject:SetActive(TopUI.heros[i].valid)
            TopUI.heros[i].parent:SetActive(TopUI.heros[i].valid)
        end   
        TopUI.Vs:SetActive(true)
        for i =1,10 do
            TopUI.heros[i].pvpEffect.gameObject:SetActive(false)  
        end         
    end
end

local function onShowHeroFinish()
    FullSkipBtn.gameObject:SetActive(false)
    TopUI.Vs:SetActive(true) 
	
	
end

local function onShowHero(index)
    print("RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR",index)
    TopUI.heros[index+1].parent:SetActive(true)
    TopUI.heros[index+1].gameObject:SetActive(true)
    TopUI.heros[index+1].pvpEffect.gameObject:SetActive(true)
end

local Hero_CO = nil

local function DisposeHeroEffect(heros,time)
    local co = coroutine.start(function()
        local max = math.max(#heros[1],#heros[2])
        for i=1,max do
            if SkillEffect == nil then
                return
            end  
            if i <= #heros[1] then
                SkillEffect[1].root.gameObject:SetActive(true)
                local hd = TableMgr:GetHeroData( heros[1][i])
                print("1",heros[1][i],hd.picture)
                SkillEffect[1].hero_texture.mainTexture = ResourceLibrary:GetIcon("Icon/hero_half/", hd.picture)                
            end

            if i<=#heros[2] then
                SkillEffect[2].root.gameObject:SetActive(true)
                local hd = TableMgr:GetHeroData( heros[2][i])
                print("2",heros[2][i],hd.picture)
                SkillEffect[2].hero_texture.mainTexture = ResourceLibrary:GetIcon("Icon/hero_half/", hd.picture)                
            end

            WaitForRealSeconds(time)
            SkillEffect[1].root.gameObject:SetActive(false)
            SkillEffect[2].root.gameObject:SetActive(false)
        end
        Hero_CO = nil
    end)
    Hero_CO = co
end

local function onShowHeroSkillEffect( hero_base_ids,time)
    local heros = {}
    heros[1] = {}
    heros[2] = {}
    for i=0,hero_base_ids.Length-1 do
        if hero_base_ids[i] < 0 then
            table.insert(heros[1] ,math.abs(hero_base_ids[i]))
        else
            table.insert(heros[2] ,math.abs(hero_base_ids[i]))
        end
    end
    DisposeHeroEffect(heros,time)
end

local function OnAnimFinish()
    -- if ConfigData.GetGameStateTutorial() == true then
        SkipCoroutine = coroutine.start(function()
            coroutine.wait(7)
            coroutine.stop(SkipCoroutine)
            SkipCoroutine = nil
            SkipBtn.gameObject:SetActive(true)
        end)


        --SkipBtn.gameObject:SetActive(true)
    -- end
    FullSkipBtn.gameObject:SetActive(true)
    TopUI.root:SetActive(true)
    local battleState = GameStateSLGBattle.Instance
    if battleState.heroBuffs ~= nil then
        TopUI.hero:SetActive(true)     
    end
	
end

function CalculateK(players)
    K = 0;
    local k = 0
    for i = 1,#players,1 do
        local p = {}
        for a = 0,players[i].Armys.Length-1, 1 do
            local army = players[i].Armys[a]
            if p[army.PhalanxType] == nil then
                p[army.PhalanxType] = 0    
            end
            p[army.PhalanxType] = p[army.PhalanxType] + army.Count * army.Attack
        end
        for z =1,10,1 do
            if p[z] ~= nil then
                if p[z] > k then
                    k = p[z]
                end
            end
        end
    end
    
    K = k
    if K ~= 0 then
        K = 50/math.sqrt(K)
    end
    print("Max Attack ",k,"  K ",K)
end

function FillPlayerInfo(players,_result)
    playerinfos = players
    result = _result
end

function GetPlayerInfo()
   return playerinfos
end

local function OnUICameraDrag(go, delta)
    if go ~= TopUI.bg then
        return
    end
    if not enableCameraDrag then
        return
    end
    local deltaX = delta.x
    local deltaY = delta.y
    local dragSpeed = 0.02
	--[[TopUI.offset = TopUI.offset + deltaX * dragSpeed
	TopUI.offset = Mathf.Clamp(TopUI.offset , TopUI.minX , TopUI.maxX)
	
	
	print(TopUI.offset , TopUI.maxX , TopUI.minX)
	if TopUI.offset < TopUI.maxX and TopUI.offset > TopUI.minX then
		TopUI.mainCamera.transform:Translate(deltaX * dragSpeed, 0, 0)
	end]]
    TopUI.battleCamera:Move(deltaX * dragSpeed, deltaY * dragSpeed)
	TopUI.battleCamera:SetFollowPosition(nil)
end

local function LoadUI()
    TopUI = {}
	TopUI.mainCamera = UnityEngine.Camera.main
    TopUI.bg = transform:Find("Container").gameObject
    TopUI.Vs = transform:Find("Container/bg_frane/hero/Camera").gameObject
    TopUI.root = transform:Find("Container/bg_frane/bg_top").gameObject
    TopUI.hero = transform:Find("Container/bg_frane/hero").gameObject
    TopUI.root:SetActive(false)
    TopUI.hero:SetActive(false)
    TopUI.Vs:SetActive(false)

    TopUI.show = transform:Find("Container/bg_frane/hero/Camera")
    NGUITools.SetChildLayer(TopUI.show, 18)

    TopUI.attack = {}
    TopUI.attack.name = transform:Find("Container/bg_frane/bg_top/PVPUIanimation/bg_attack/level"):GetComponent("UILabel")
    TopUI.attack.face = transform:Find("Container/bg_frane/bg_top/PVPUIanimation/bg_attack/bg_icon/Texture"):GetComponent("UITexture")
    TopUI.attack.hp = transform:Find("Container/bg_frane/bg_top/PVPUIanimation/bg_attack/UnitHudRed/hud frame/hp slider"):GetComponent("UISlider")
    TopUI.attack.shp = transform:Find("Container/bg_frane/bg_top/PVPUIanimation/bg_attack/UnitHudRed/hud frame/hp_gray"):GetComponent("UISlider")
    TopUI.attack.hp.value = 1
    TopUI.attack.shp.value = 1


    TopUI.defend = {}
    TopUI.defend.name = transform:Find("Container/bg_frane/bg_top/PVPUIanimation/bg_defend/level"):GetComponent("UILabel")
    TopUI.defend.face = transform:Find("Container/bg_frane/bg_top/PVPUIanimation/bg_defend/bg_icon/Texture"):GetComponent("UITexture")
    TopUI.defend.hp = transform:Find("Container/bg_frane/bg_top/PVPUIanimation/bg_defend/UnitHudBlue/hud frame/hp slider"):GetComponent("UISlider")  
    TopUI.defend.shp = transform:Find("Container/bg_frane/bg_top/PVPUIanimation/bg_defend/UnitHudBlue/hud frame/hp_gray"):GetComponent("UISlider")
    TopUI.defend.hp.value = 1
    TopUI.defend.shp.value = 1

    TopUI.heros = {}
    for i =1,10 do
        TopUI.heros[i] = {}
        local trf = transform:Find(heroPathStr[i])
        HeroList.LoadHeroObject(TopUI.heros[i], trf)   
        --TopUI.heros[i].outline = trf:Find("head icon/outline")
        --TopUI.heros[i].outline.gameObject:SetActive(false)
        TopUI.heros[i].valid = false
        TopUI.heros[i].pvpEffect = transform:Find(heroEffectPathStr[i]) 
        TopUI.heros[i].pvpEffect.gameObject:SetActive(false) 
        TopUI.heros[i].gameObject:SetActive(false)
        TopUI.heros[i].parent = TopUI.heros[i].transform.parent.gameObject
        TopUI.heros[i].parent:SetActive(false)
    end
    if result ~= nil then
        local k = 1
        for i=1, #result.input.user.team1[1].hero.heros do
            if k > 5 then
                break;
            end
            local heroMsg = result.input.user.team1[1].hero.heros[i]
            local heroData = TableMgr:GetHeroData(heroMsg.baseid)  
            HeroList.LoadHero(TopUI.heros[k], heroMsg, heroData)  
            TopUI.heros[k].valid = true;
            TopUI.heros[k].starSprite.gameObject:SetActive(true)
            TopUI.heros[k].levelLabel.gameObject:SetActive(true)
            --TopUI.heros[k].pvpEffect.gameObject:SetActive(true) 
            --TopUI.heros[k].outline.gameObject:SetActive(true)
            k = k+1         
        end
        k = 6
        for i=1, #result.input.user.team2[1].hero.heros do
            if k > 10 then
                break;
            end
            local heroMsg = result.input.user.team2[1].hero.heros[i]
            local heroData = TableMgr:GetHeroData(heroMsg.baseid)   
            HeroList.LoadHero(TopUI.heros[k], heroMsg, heroData)   
            TopUI.heros[k].valid = true;
            TopUI.heros[k].starSprite.gameObject:SetActive(true)
            TopUI.heros[k].levelLabel.gameObject:SetActive(true)  
            --TopUI.heros[k].pvpEffect.gameObject:SetActive(true) 
            --TopUI.heros[k].outline.gameObject:SetActive(true)
            k = k+1      
        end        
    end




    TopUI.vs = transform:Find("Container/bg_frane/bg_top/PVPUIanimation/bg_vs/bg_round/text"):GetComponent("UILabel")
    TopUI.vs.text = "0/200"
    if playerinfos ~= nil then
        TopUI.attack.name.text = playerinfos[1].name
        TopUI.attack.face.mainTexture = ResourceLibrary:GetIcon("Icon/head/",playerinfos[1].face)
        TopUI.defend.name.text = playerinfos[2].name
        TopUI.defend.face.mainTexture = ResourceLibrary:GetIcon("Icon/head/",playerinfos[2].face)
    end

    panel_hud = transform:Find("panel_hud")
    local battleState = GameStateSLGBattle.Instance
    AddDelegate(battleState, "onGameOver", OnGameOver)
    AddDelegate(battleState, "onGameOver_Debug", onGameOver_Debug)
    AddDelegate(battleState, "onShowBeatHurt", OnShowBeatHurt)
    AddDelegate(battleState, "onAnimFinish", OnAnimFinish)
    AddDelegate(battleState, "onSkipShowHeroFinish", onSkipShowHeroFinish)
    AddDelegate(battleState, "onShowHeroFinish", onShowHeroFinish);
    AddDelegate(battleState, "onShowHero", onShowHero);
    AddDelegate(battleState, "onShowHeroSkillEffect", onShowHeroSkillEffect);
    
    
    AddDelegate(battleState, "onShowBattleState", OnShowBattleState)
	AddDelegate(UICamera, "onDrag", OnUICameraDrag)
	
    FullSkipBtn = transform:Find("Container/full skip")
    SkipBtn = transform:Find("Container/bg_frane/btn_skip")
    NextBtn = transform:Find("Container/bg_frane/btn_next")
    SkipBtn.gameObject:SetActive(false)
    NextBtn.gameObject:SetActive( Global.IsSLGPVPBattleWaveState() )
    FullSkipBtn.gameObject:SetActive(true)    
    SetClickCallback(SkipBtn.gameObject,function()
        if not Global.IsSLGPVPBattleWaveState() then
            battleState:BattleEnd()
        else
            Global.SkillAllWave()
            battleState:BattleEnd()
        end
    end)
    SetClickCallback(FullSkipBtn.gameObject,function()
        battleState:BattleSkillAnim()
    end)
    SetClickCallback(NextBtn.gameObject,function()
        if Global.IsSLGPVPBattleWaveState() then
            battleState:BattleEnd()
        end
    end)

    SkillEffect ={}
    SkillEffect[1] = {}
    SkillEffect[1].root = transform:Find("SkillEffect")
    SkillEffect[1].hero_texture = transform:Find("SkillEffect/Animations/Gerneral"):GetComponent("UITexture")
    SkillEffect[2] = {}
    SkillEffect[2].root = transform:Find("SkillEffect (1)")
    SkillEffect[2].hero_texture = transform:Find("SkillEffect (1)/Animations/Gerneral"):GetComponent("UITexture")
end

function AddHud(_hud)
    if panel_hud ~= nil then
        _hud.transform:SetParent(panel_hud, false)
        _hud.layer = gameObject.layer
    end
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end


function Awake()
    IsDestroy = false;
    LoadUI()
end

function LateUpdate()
	if TopUI.battleCamera ~= nil then 
		TopUI.battleCamera:Update()
	end
end

function Start()
    local anim_name = "SLGPVPCAM";
    local clip = Global.GResourceLibrary:GetMainCityAnimationClipInstance(anim_name)
    local mCamAnim = UnityEngine.Camera.main:GetComponent("Animation")
    mCamAnim:RemoveClip("SLGPVPCAM")
    mCamAnim:AddClip(clip, anim_name);
    mCamAnim:Play(anim_name);    
end

function Close()
    showAnim = false
	enableCameraDrag = false
    preHps = nil 
    IsDestroy = true;
    panel_hud = nil
    FullSkipBtn = nil
    SkipBtn = nil 
    if SkipCoroutine ~= nil then
        coroutine.stop(SkipCoroutine)
        SkipCoroutine = nil 
    end
    TopUI = nil   
    THps0 = nil
    THps1 = nil
    SkillEffect = nil
    if Hero_CO ~= nil then
        coroutine.stop(Hero_CO)
        Hero_CO = nil
    end 

    RemoveDelegate(GameStateSLGBattle.Instance, "onGameOver", OnGameOver)
    RemoveDelegate(GameStateSLGBattle.Instance, "onGameOver_Debug", onGameOver_Debug)
    RemoveDelegate(GameStateSLGBattle.Instance, "onShowBeatHurt", OnShowBeatHurt)
    RemoveDelegate(GameStateSLGBattle.Instance, "onAnimFinish", OnAnimFinish)
    RemoveDelegate(GameStateSLGBattle.Instance, "onShowBattleState", OnShowBattleState)
    RemoveDelegate(GameStateSLGBattle.Instance, "onSkipShowHeroFinish", onSkipShowHeroFinish)
    RemoveDelegate(GameStateSLGBattle.Instance, "onShowHeroFinish", onShowHeroFinish);
    RemoveDelegate(GameStateSLGBattle.Instance, "onShowHero", onShowHero);
    RemoveDelegate(GameStateSLGBattle.Instance, "onShowHeroSkillEffect", onShowHeroSkillEffect);
	RemoveDelegate(UICamera, "onDrag", OnUICameraDrag)
    
end

function SetQuitCallBack(callback)
    ExitCallBack = callback
end

function Show() --,dis,buf,tile
    Global.OpenUI(_M)
    
end






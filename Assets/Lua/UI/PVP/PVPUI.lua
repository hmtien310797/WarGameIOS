module("PVPUI", package.seeall)
local PvPMsg_pb = require("PvPMsg_pb")
local Category_pb = require("Category_pb")
local ClientMsg_pb = require("ClientMsg_pb")

local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr.Instance
local TextMgr = Global.GTextMgr
local SetClickCallback = UIUtil.SetClickCallback
local GuideMgr = Global.GGuideManager
local ResourceLibrary = Global.GResourceLibrary


local SetClickCallback = UIUtil.SetClickCallback

local BattleType = 1

local PSRefreshRate = 3

local PVPUI

local PVPState

local csBattle

local sceneManager

local DState =
{
	None = 0,
	Matched = 1,
	AllReady = 2,
	HeroSet = 3,
	ClientLoaded = 4,
	Battleing = 5,
	Ending = 6,
}

local UIState =
{
	WaitMatch = 0,
	Matching = 1,
	WaitReady = 2,
	Readying = 3,
}

local RefrushUI
local RefrushUIState
local UpdatePVPState
local RequestStartPVP
local RequestPVPEnd

local BattleEndCB
local CheckEndBattleCB


local BattleSuccessCB

local BattleFaildCB

local BattleCBTag

local BattleOpList

local BattleState

local DisposeMsg

local DisposeOpList

function InitPVP()
    if PVPState ~= nil then
        return
    end
    BattleState = GameStateBattle.Instance

    BattleOpList = {}
    sceneManager = SceneManager.instance
    csBattle = Clishow.CsBattle.Instance
    PVPState = {}
    PVPState.EnableRefreshState = false
    PVPState.RefreshTime = 0
    PVPState.State = nil
    PVPState.RefreshFunc = nil
    PVPState.BattleData = nil
    PVPState.CurState = nil
end

function StartPVPStateBeat()
    UpdateBeat:Add(UpdatePVPState)
end

function EndPVPStateBeat()
    BattleOpList = {}
    PVPState.RefreshTime = 0
    PVPState.CurState = nil
    UpdateBeat:Remove(UpdatePVPState)
end

function IsPVP()
     if PVPState == nil then
         return false
     end

     if PVPState.State == nil then
        return false   
     end

     return PVPState.State~= DState.None
end

local function ResetRefreshTag()
    PVPState.EnableRefreshState = false
    PVPState.RefreshTime = 0 
end

local function RefrushPVPState(state)
    InitPVP()
        PVPState.State = state         
        ResetRefreshTag()
        --print("PVPState",PVPState.State)
        if PVPState.RefreshFunc ~= nil then
            PVPState.RefreshFunc()
        end
        if PVPState.State == DState.Ending then 
            if PVPState.CurState ~= DState.Ending then
                PVPState.CurState = DState.Ending
                EndPVPStateBeat()
                local cb = CheckEndBattleCB
                CheckEndBattleCB = nil 
                if cb ~= nil then
                    cb()
                end
            end
        end
        if PVPState.State == DState.HeroSet then 
            if PVPState.CurState ~= DState.HeroSet then
                PVPState.CurState = DState.HeroSet
                RequestStartPVP()
            end  
        end
        if PVPState.State == DState.Battleing then 
            if PVPState.CurState ~= DState.Battleing then
                PVPState.CurState = DState.Battleing
                csBattle:NotifyTitleFinished()
            end  
        end    
end

local function RequestState()
    if PVPState.EnableRefreshState then 
            if PVPState.RefreshTime >= PSRefreshRate then
                ResetRefreshTag()
            end
        return
    end
    PVPState.EnableRefreshState = true;
    local req = PvPMsg_pb.MsgBattlePvPGetCurrentBattleRequest()
    LuaNetwork.Request(Category_pb.PvP, PvPMsg_pb.PvPTypeId.MsgBattlePvPGetCurrentBattleRequest, req:SerializeToString(), function(typeId, data)
		local msg = PvPMsg_pb.MsgBattlePvPGetCurrentBattleReponse()
		msg:ParseFromString(data)
        RefrushPVPState(msg.battleState)
	end, false)
end

function PvPBattleStatePush(msg)
    RefrushPVPState(msg.state)
end


function PVPBattlePVPTickPush(msg)
    if  not IsPVP() then
        return 
    end
    --print(msg.serverTimeStart,msg.serverTimeEnd)
    BattleState:SyncTime(msg.serverTimeStart,msg.serverTimeEnd)
    table.insert(BattleOpList,msg)
end

DisposeMsg = function(operation)
    if operation.type == 1 then 
        csBattle:RequestCast4RedCmd(operation.cmd)
    else
        sceneManager:CreateUnit4RedCmd(operation.cmd)
    end
    if operation.tag == BattleCBTag then
        BattleFaildCB = nil
        local cb = BattleSuccessCB
        BattleSuccessCB = nil 
        if cb ~= nil then
            cb()
        end 
        InGameUI.EnableUI()
    end
end

DisposeOpList = function(frame_time)
    for i = #(BattleOpList),1,-1 do 
        --print("DisposeMsg -------------- ",BattleOpList[i].serverTimeStart,frame_time)
        if BattleOpList[i].serverTimeStart == frame_time then
            if #(BattleOpList[i].operation) ~= 0 then
                for k = 1,#(BattleOpList[i].operation) do
                    DisposeMsg(BattleOpList[i].operation[k])
                end
            end
            table.remove(BattleOpList,i)    
        end
        
    end
end

UpdatePVPState = function()
    if not IsPVP() then 
        if PVPState.State == nil or PVPUI.UIState == UIState.WaitMatch then
            return
        end
    end
    
    PVPState.RefreshTime =PVPState.RefreshTime + Serclimax.GameTime.deltaTime
    if PVPState.RefreshTime >= PSRefreshRate then
        RequestState()
    end
end




local function SetUpUI()
    gameObject:SetActive(false)
    if PVPUI ~= nil then
        return
    end

    PVPUI = {}

    PVPUI.StateText = transform:Find("Container/State_Text"):GetComponent("UILabel")
    PVPUI.CloseBtn = transform:Find("Container/Btn_CLose"):GetComponent("UIButton")

    PVPUI.BtnMiD = transform:Find("Container/Btn_Mid"):GetComponent("UIButton")
    PVPUI.BtnMiDText = transform:Find("Container/Btn_Mid/text"):GetComponent("UILabel")

    PVPUI.BtnLeft = transform:Find("Container/Btn_Left"):GetComponent("UIButton")
    PVPUI.BtnLeftText = transform:Find("Container/Btn_Left/text"):GetComponent("UILabel")

    PVPUI.BtnRight = transform:Find("Container/Btn_Right"):GetComponent("UIButton")
    PVPUI.BtnRightText = transform:Find("Container/Btn_Right/text"):GetComponent("UILabel")

    SetClickCallback(PVPUI.CloseBtn.gameObject,function() 
        GUIMgr:CloseMenu("PVPUI")
    end)
end

local function RequestCancelPVPMatch()
    local req = PvPMsg_pb.MsgBattlePvPBattleMatchCancelRequest()
    LuaNetwork.Request(Category_pb.PvP, PvPMsg_pb.PvPTypeId.MsgBattlePvPBattleMatchCancelRequest, req:SerializeToString(), function(typeId, data)
		local msg = PvPMsg_pb.MsgBattlePvPBattleMatchCancelReponse()
		msg:ParseFromString(data)
		if msg.code == 0 then
            RefrushUI(UIState.WaitMatch)
        else
             print("Error",msg.code)            
        end
	end, true)
end

local function RequestPVPReady()
    local req = PvPMsg_pb.MsgBattlePvPBattleReadyRequest()
    LuaNetwork.Request(Category_pb.PvP, PvPMsg_pb.PvPTypeId.MsgBattlePvPBattleReadyRequest, req:SerializeToString(), function(typeId, data)
		local msg = PvPMsg_pb.MsgBattlePvPBattleReadyReponse()
		msg:ParseFromString(data)
		if msg.code == 0 then
            RefrushUI(UIState.Readying)
        else
             print("Error",msg.code)
		end
	end, true)    
end

local function RequestPVPMatch()
    local req = PvPMsg_pb.MsgBattlePvPBattleMatchRequest()
    req.battletype = BattleType
    LuaNetwork.Request(Category_pb.PvP, PvPMsg_pb.PvPTypeId.MsgBattlePvPBattleMatchRequest, req:SerializeToString(), function(typeId, data)
		local msg = PvPMsg_pb.MsgBattlePvPBattleMatchReponse()
		msg:ParseFromString(data)
		if msg.code == 0 then
		    PVPState.RefreshFunc = RefrushUIState
		    StartPVPStateBeat()
            RefrushUI(UIState.Matching)
        else
           print("Error",msg.code)
        end
    end, true)
end

function RequestSetingBattleConfirm()
    local req = PvPMsg_pb.MsgBattlePvPSetingBattleConfirmRequest()
    LuaNetwork.Request(Category_pb.PvP, PvPMsg_pb.PvPTypeId.MsgBattlePvPSetingBattleConfirmRequest, req:SerializeToString(), function(typeId, data)
		local msg = PvPMsg_pb.MsgBattlePvPSetingBattleConfirmReponse()
		msg:ParseFromString(data)
		if msg.code == 0 then
            MessageBox.Show("對付感覺到了你的霸氣，請容他擦擦褲子上的尿漬。。。")
        else
           print("Error",msg.code)
       end
    end, true)    
end

function RequestPVPClientReady()
    local req = PvPMsg_pb.MsgBattlePvPBattleClientLoadedRequest()
    LuaNetwork.Request(Category_pb.PvP, PvPMsg_pb.PvPTypeId.MsgBattlePvPBattleClientLoadedRequest, req:SerializeToString(), function(typeId, data)
		local msg = PvPMsg_pb.MsgBattlePvPBattleClientLoadedReponse()
		msg:ParseFromString(data)
		if msg.code ~= 0 then
           print("Error",msg.code)
       end
    end, true)   
end

RequestPVPEnd = function()
    PVPState.State = nil
    local req = PvPMsg_pb.MsgBattlePvPEndRequest()
    LuaNetwork.Request(Category_pb.PvP, PvPMsg_pb.PvPTypeId.MsgBattlePvPEndRequest, req:SerializeToString(), function(typeId, data)
		local msg = PvPMsg_pb.MsgBattlePvPEndReponse()
		msg:ParseFromString(data)
		if msg.code ~= 0 then
            Global.ShowError(msg.code)
        else
            local cb = BattleEndCB
            BattleEndCB = nil 
            if cb ~= nil then
                cb(msg)
            end
        end
    end, true)   
end

function ShowWinlose(EndCB)
    BattleEndCB = EndCB  
    if PVPState.State >= DState.Ending then
        RequestPVPEnd()
    else
        CheckEndBattleCB = RequestPVPEnd
    end
end

function RequestCast(index,pos,successCB,failedCB)
    BattleSuccessCB = successCB
    BattleFaildCB = failedCB
    BattleCBTag = MainData.GetCharId()..Serclimax.GameTime.GetSecTime()
    InGameUI.DisableUI()
    local cmd = csBattle:RequestCast2RedCmd(index,pos)
    print(cmd)
    
    local req = PvPMsg_pb.MsgBattlePvPUserOperationsRequest()
    req.operation.time = Serclimax.GameTime.GetSecTime()
    req.operation.cmd = cmd
    req.operation.type = 1
    req.operation.tag = BattleCBTag
    LuaNetwork.Request(Category_pb.PvP, PvPMsg_pb.PvPTypeId.MsgBattlePvPUserOperationsRequest, req:SerializeToString(), function(typeId, data)
		local msg = PvPMsg_pb.MsgBattlePvPUserOperationsReponse()
		msg:ParseFromString(data)
		if msg.code ~= 0 then
            local cb = BattleFaildCB
            BattleFaildCB = nil 
            if cb ~= nil then
                cb()
            end
            InGameUI.EnableUI()
           print("Error",msg.code)
       end
    end, false) 
end

function CreateUnit(tableId,groupDataId, touchGroundPos,bonus,successCB,failedCB)
    local cmd = sceneManager:CreateUnit2RedCmd(tableId,groupDataId, touchGroundPos,bonus)
    if cmd == nil then
        return false
    end
    BattleSuccessCB = successCB
    BattleFaildCB = failedCB
    BattleCBTag = MainData.GetCharId()..Serclimax.GameTime.GetSecTime()
    InGameUI.DisableUI()    
    print(cmd)
    
    local req = PvPMsg_pb.MsgBattlePvPUserOperationsRequest()
    req.operation.time = Serclimax.GameTime.GetSecTime()
    req.operation.cmd = cmd
    req.operation.type = 2
    req.operation.tag = BattleCBTag
    LuaNetwork.Request(Category_pb.PvP, PvPMsg_pb.PvPTypeId.MsgBattlePvPUserOperationsRequest, req:SerializeToString(), function(typeId, data)
		local msg = PvPMsg_pb.MsgBattlePvPUserOperationsReponse()
		msg:ParseFromString(data)
		if msg.code ~= 0 then
            local cb = BattleFaildCB
            BattleFaildCB = nil 
            if cb ~= nil then
                cb()
            end
            InGameUI.EnableUI()
           print("Error",msg.code)
       end
    end, false)
    return true
end

RequestStartPVP = function()
    local teamType = Common_pb.BattleTeamType_pvp_1
    local req = PvPMsg_pb.MsgBattlePvPStartRequest()
    Global.Request(Category_pb.PvP, PvPMsg_pb.PvPTypeId.MsgBattlePvPStartRequest, req, PvPMsg_pb.MsgBattlePvPStartReponse, function(msg)	
		if msg.code == 0 then
            local battleState = GameStateBattle.Instance
            battleState.IsPvpBattle = true
            battleState.CharaUid = MainData.GetCharId()
            for i=1,#(msg.battle.users.users) do
                if msg.battle.users.users[i].charid == battleState.CharaUid then
                    battleState.PvpTeam = msg.battle.users.users[i].team
                end
            end
            print("PvpTeam", battleState.PvpTeam,"battleStartTime       ",msg.battleStartTime)
            battleState:SetPVPBattleStartResponse(msg.battleStartTime,msg.battle.battle.mapid,DisposeOpList,msg.monsterDrop:SerializeToString(),msg.config:SerializeToString())
            GUIMgr:CloseAllMenu()
            local selectedArmyList = {}
            local heroInfoDataList = battleState.heroInfoDataList
            heroInfoDataList:Clear()
            print("Users Count ",#(msg.battle.users.users))
            if TeamData.GetSelectedArmyCount(teamType) == 0 then
                local self_charID = MainData.GetCharId()
                local self_index = -1
                for i,v in ipairs(msg.battle.users.users) do
                    print(i,v.charid,self_charID)
                    if v.charid == self_charID then
                        self_index = i
                        break
                    end
                end
                print("self_index",self_index,"msg.battle.mapid",msg.battle.battle.mapid)
                for _, v in ipairs(msg.battle.users.userData[self_index].arms.data) do
                    table.insert(selectedArmyList, v.uid)
                end
                for _, v in ipairs(msg.battle.users.userData[self_index].hero.data) do
                    local heroMsg = GeneralData.GetGeneralByUID(v.uid) -- HeroListData.GetHeroDataByUid(v.uid)
                    heroInfoDataList:Add(heroMsg:SerializeToString())
                end
            else
                local teamData = TeamData.GetDataByTeamType(teamType) 
                for _, v in ipairs(teamData.memArmy) do
                    table.insert(selectedArmyList, v.uid)
                end
                for _, v in ipairs(teamData.memHero) do
                    local heroMsg = GeneralData.GetGeneralByUID(v.uid) -- HeroListData.GetHeroDataByUid(v.uid)
                    heroInfoDataList:Add(heroMsg:SerializeToString())
                end
            end

            AttributeBonus.CollectBonusInfo()
            print(msg.battle.battle.mapid)
            local battleBonus = AttributeBonus.CalBattleBonus(msg.battle.battle.mapid)
            local battleArgs = 
            {
                battleId = msg.battle.battle.mapid,
                loadScreen = "1",
                selectedArmyList = selectedArmyList,
                battleBonus = 
                {
                    bulletAddition = battleBonus.SummonEnergy,
                    energyAddition = battleBonus.SkillEnergy,
                    bulletRecover = battleBonus.SummonEnergyRecovery
                }
            }
            print("start battle, battleId:", battleArgs.battleId,battleState,cjson.encode(battleArgs))
            Main.Instance:ChangeGameState(battleState, cjson.encode(battleArgs),nil)
        else
           print("Error",msg.code)
       end
   end) 
end


RefrushUI = function (uistate)
    if PVPUI == nil then
        return 
    end
    if gameObject.activeSelf == false then
        gameObject:SetActive(true)
    end
   
    PVPUI.UIState = uistate
     --print( "PVPUI.UIState",PVPUI.UIState)
    if PVPUI.UIState == UIState.WaitMatch then
        PVPUI.CloseBtn.gameObject:SetActive(true)
        PVPUI.StateText.text = "要不要去搞點事情！"
        PVPUI.BtnMiD.gameObject:SetActive(true)
        PVPUI.BtnMiDText.text = "昂忙北鼻"
        PVPUI.BtnLeft.gameObject:SetActive(false)
        PVPUI.BtnRight.gameObject:SetActive(false)
        SetClickCallback(PVPUI.BtnMiD.gameObject,function()             
            RequestPVPMatch()
        end)         
    elseif PVPUI.UIState == UIState.Matching then
         PVPUI.CloseBtn.gameObject:SetActive(true)
        PVPUI.StateText.text =  "看看會遇到哪個倒霉蛋？...."
        PVPUI.BtnMiD.gameObject:SetActive(true)
        PVPUI.BtnMiDText.text = "我後悔了"
        PVPUI.BtnLeft.gameObject:SetActive(false)
        PVPUI.BtnRight.gameObject:SetActive(false)
        SetClickCallback(PVPUI.BtnMiD.gameObject,function() 
            RequestCancelPVPMatch()
        end)          
    elseif PVPUI.UIState == UIState.WaitReady then
         PVPUI.CloseBtn.gameObject:SetActive(false)
        PVPUI.StateText.text = "害怕了？懂哇瑞 請相信你的右手可以的"
        PVPUI.BtnMiD.gameObject:SetActive(false)
		PVPUI.BtnLeft.gameObject:SetActive(true)
        PVPUI.BtnLeftText.text = "來吃夠"
        PVPUI.BtnRight.gameObject:SetActive(false)
        --PVPUI.BtnRightText.text = "我怕了" 
        SetClickCallback(PVPUI.BtnLeft.gameObject,function() 
            RequestPVPReady()
        end)  

        --SetClickCallback(PVPUI.BtnRight.gameObject,function() 
        --    RequestCancelPVPMatch()
        --end)         

    elseif PVPUI.UIState == UIState.Readying then
        PVPUI.CloseBtn.gameObject:SetActive(false)
        PVPUI.StateText.text = "HAHAHAHAHAHAHHAHAHAHAHA 顫抖吧~~~~~~~~~~~"
        PVPUI.BtnMiD.gameObject:SetActive(false)
        PVPUI.BtnLeft.gameObject:SetActive(false)
        PVPUI.BtnRight.gameObject:SetActive(false)
    end
end

function Start()
    InitPVP()
    SetUpUI()
    if PVPState.State == nil then 
        PVPState.RefreshFunc = RefrushUIState
        RequestState()
    else
        RefrushUIState()
    end    
end

function Awake()

end

--function Update()
--    UpdatePVPState()

--end

function Show()
    Global.OpenTopUI(_M)
end

function Hide()
    Global.CloseUI(_M)
end

function Close()
    PVPUI = nil
    if PVPState.State < DState.AllReady then
        RequestCancelPVPMatch()
        EndPVPStateBeat()
        PVPState.State = nil
    end
    PVPState.RefreshFunc = nil
 end

RefrushUIState = function()
    if PVPUI == nil then
        return 
    end
    if  PVPState.State == DState.None or PVPState.State > DState.Ending then
        if PVPUI.UIState ~= UIState.Matching then
            RefrushUI(UIState.WaitMatch)
        end
    elseif  PVPState.State == DState.Matched and PVPUI.UIState ~= UIState.Readying then
        RefrushUI(UIState.WaitReady)
    elseif  PVPState.State == DState.AllReady then  
        Hide()
        SelectHero.Show(Common_pb.BattleTeamType_pvp_1)
    end
end

module("Reinforcement", package.seeall)

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

local selectSoldier
local BattleUI

local BattleLeftInfos

local BattleLeftSortInfos


local ArmyNumber

local MaxSoilderNumber

local QuickTime = 0


local SuccessCallBack

local cancelCallback

local FixedMaxSoilderNumber


local SetLeftInfo

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if BattleUI == nil then
        return
    end
    if go ~= BattleUI.tipObject then
        BattleUI.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

function GetBattleLeftInfos()
    return BattleLeftInfos
end

local function MoveRequest()
        local req = GuildMobaMsg_pb.GuildMobaReinforceRequest()
        local total = 0
        table.foreach(BattleLeftInfos,function(_,v)
            if v.num > 0 then
               local army = req.army.armys:add()
               army.baseid = v.type_id
               army.level = v.level
               army.num = v.num
               total = total+ v.num
           end
        end)
        LuaNetwork.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaReinforceRequest, req:SerializeToString(), function(typeId, data)
            local msg = GuildMobaMsg_pb.GuildMobaReinforceResponse()
            msg:ParseFromString(data)
            if msg.code ~= ReturnCode_pb.Code_OK then
                Global.ShowError(msg.code)
                Hide()        
            else
			
                if total ~= 0 then
                    MessageBox.Show(TextMgr:GetText("ui_unionwar_47"))
                else
                    MessageBox.Show(TextMgr:GetText("ui_unionwar_48"))
                end
                Hide()
				MobaArmyListData.NotifyListener()

            end
        end, false)
end

local function CloseClickCallback(go)
    Hide()
end

local function roundOff(num, n)
    if n > 0 then
       local scale = math.pow(10, n-1)
        return math.floor(num / scale + 0.5) * scale
    elseif n < 0 then
        local scale = math.pow(10, n)
        return math.floor(num / scale + 0.5) * scale
     elseif n == 0 then
         return num
     end
end


function calMaxSoilderNum(base)
    local params = {}
    params.base = base
        --[[
            print("params.base:",base,
            "GV(1063):",AttributeBonus.GetValueSGL(1063),
            "GV(1024):",AttributeBonus.GetValueSGL(1024),
            "GV(1102):",AttributeBonus.GetValueSGL(1102),
            "GV(1086):",AttributeBonus.GetValueSGL(1086),
            "((params.base+GV(1063))*(1+GV(1024)*0.01)+GV(1102))*(1+GV(1086)*0.01)",
            ((params.base+AttributeBonus.GetValueSGL(1063))*(1+AttributeBonus.GetValueSGL(1024)*0.01)+AttributeBonus.GetValueSGL(1102))*(1+AttributeBonus.GetValueSGL(1086)*0.01)
            ) 
        --]] 
    return AttributeBonus.CallBonusFunc(30,params)
end


function RefrushTotalSoliderNum()
    local _num = 0
    RefrushFight()
    table.foreach(BattleLeftInfos,function(_,v) 
        if v.num ~= 0 then
            _num = _num + v.num
        end
    end) 
    if _num > MaxSoilderNumber then
        local num = 0
        local done = false
        for i=4,1,-1 do
            if done then
                break
            end
            for j = 1004,1001,-1 do
                local info = BattleLeftSortInfos[i*100+j]
                if info ~= nil then
                    num = info.num
                    SetLeftInfo(info.unitId,info.num)
                    if num ~= info.num then
                        done = true
                        break
                    end
                end
            end
            RefrushFight()
        end
    end
end


local function checkNumLimit(soldier_UnitID,num)
    if BattleLeftInfos[soldier_UnitID] == nil then
        return 0
    end
    
    local tnum = 0
    table.foreach(BattleLeftInfos,function(i,v) 
        if v.num ~= 0 and i ~= soldier_UnitID then
            tnum = tnum + v.num
        end
    end)

    if MaxSoilderNumber <= tnum then
        return 0
    end
    
    if MaxSoilderNumber - num >= tnum then
        return num
    end
    
    return MaxSoilderNumber - tnum
end    

local function AddLeftInfo(perfab,soldier_data)
    local t = 0    

    local soldier =Barrack.GetAramInfo(soldier_data.SoldierId,soldier_data.Grade)
    if soldier == nil or soldier.Num <= 0 then
        return
    end 
    t = soldier.Num

    if t <= 0 then
        return false
    end

    if BattleLeftInfos[soldier_data.UnitID] == nil then
        BattleLeftInfos[soldier_data.UnitID] = {}
    end
    local info = BattleLeftInfos[soldier_data.UnitID]
    info.autoRefrush = false
    info.obj = NGUITools.AddChild(BattleUI.bg_left.armys_grid.gameObject,BattleUI.BattleMoveLeftInfo)
    info.obj.name = (5 - soldier_data.Grade)*100 + (1005 - soldier_data.SoldierId)
    info.name_txt = info.obj.transform:Find("bg_list/bg_title/text_name"):GetComponent("UILabel")
    info.name_txt.text = TextMgr:GetText(soldier_data.SoldierName) --.."  LV."..soldier_data.Grade
    info.icon_tex = info.obj.transform:Find("bg_list/bg_icon/Texture"):GetComponent("UITexture")
    info.icon_tex.mainTexture = ResourceLibrary:GetIcon ("Icon/Unit/", soldier_data.SoldierIcon)
    info.total_num_txt = info.obj.transform:Find("bg_list/num"):GetComponent("UILabel")
    info.total_num_txt.text = t
    info.input_num_gobj = info.obj.transform:Find("bg_list/bg_food").gameObject
    info.input_num_txt = info.obj.transform:Find("bg_list/bg_food/txt_food"):GetComponent("UILabel")
    info.num = 0
    
    info.fight_point = soldier_data.fight
    info.total_num = t
    info.base_weight = soldier_data.Weight*soldier_data.TeamCount
    info.type_id = soldier_data.SoldierId
    info.bonusArmyType = soldier_data.barrackAdd
    info.unitId = soldier_data.UnitID
    info.level = soldier_data.Grade
    info.speed = soldier_data.Speed
    info.first = true
    info.bg_schedule = info.obj.transform:Find("bg_list/bg_schedule")
    info.bg_schedule_climb = info.obj.transform:Find("bg_list/bg_schedule_climb")    

        info.bg_schedule.gameObject:SetActive(true)
        info.bg_schedule_climb.gameObject:SetActive(false)
        info.slider = info.obj.transform:Find("bg_list/bg_schedule/bg_slider"):GetComponent("UISlider")
        SetClickCallback(info.input_num_gobj , function()
            NumberInput.Show(math.floor(info.num), 0, info.total_num, function(number)
                info.autoRefrush = true
                local n = checkNumLimit(soldier_data.UnitID,number)
                info.num = n
                info.slider.value = n/info.total_num
            end)
        end)        



    EventDelegate.Set(info.slider.onChange,EventDelegate.Callback(function()
        local tn = roundOff( info.total_num * info.slider.value,1)
        local n = checkNumLimit(soldier_data.UnitID,tn)
        if tn ~= n then
            info.slider.gameObject:SetActive(false)
            info.slider.value = n/info.total_num
            info.slider.gameObject:SetActive(true)
        end
        info.num = n
        info.input_num_txt.text = info.num
        if info.autoRefrush then
            if not info.first then
                RefrushTotalSoliderNum()
            end
            if info.first then
                info.first = false
            end
        else
            info.autoRefrush = true
        end
    end))
    BattleLeftSortInfos[soldier_data.Grade*100+soldier_data.SoldierId] = info
    return true
end

SetLeftInfo = function(soldier_UnitID, num)
    if BattleLeftInfos[soldier_UnitID] == nil then
        return 0
    end

    local info = BattleLeftInfos[soldier_UnitID]
    local n = checkNumLimit(soldier_UnitID, num)
    info.num = math.min(n, info.total_num)
    info.slider.value = n / info.total_num

    return info.num
end


local function RefrushLeftInfo(ArmySetoutSchemeInfo)
    BattleLeftSortInfos = nil
    if BattleLeftInfos ~= nil then
        table.foreach(BattleLeftInfos,function(_,v) 
            v.obj:SetActive(false)
            v.obj.transform.parent = nil
            GameObject.Destroy(v.obj)
        end)  
    end 
    BattleLeftInfos = {}
    BattleLeftSortInfos = {}

    local armys = Barrack.GetArmy()

    local count = 0
    table.foreach(armys,function(_,v)
        if AddLeftInfo(BattleUI.BattleMoveLeftInfo,v) then
            count = count + 1
        end
    end)
    
    if count ~= 0 then
        BattleUI.bg_left.armys_grid:Reposition()
        BattleUI.bg_left.armys_scrollview:SetDragAmount(0, 0, false) 
        BattleUI.bg_left.noitem_gobj:SetActive(false)
    else
        BattleUI.bg_left.noitem_gobj:SetActive(true)
    end
end

local function ClearLeftInfo()
    table.foreach(BattleLeftInfos, function(id, v)
        v.autoRefrush = false
        SetLeftInfo(id, 0)
    end)
end



local function ClearSelectedSoldiers()
    table.foreach(BattleLeftInfos,function(id,v)
        v.autoRefrush = false
        SetLeftInfo(id,0)
    end)
end

local function QuickSelectCallBack()
    local num = 0
    local total_num = 0;
    table.foreach(BattleLeftInfos,function(_,v) 
        if v.num ~= 0 then
            num = num + v.num
        end
        if v.total_num ~= 0 then
            total_num = total_num + v.total_num
        end
    end)   
    local res_type = pathType == Common_pb.TeamMoveType_ResTake or pathType == Common_pb.TeamMoveType_MineTake
    local clear = num >= total_num  or num >= MaxSoilderNumber
    if res_type then
        clear = QuickTime % 2 ~= 0
    end

    if clear then
        ClearSelectedSoldiers()
    else

        ClearSelectedSoldiers()

    --if QuickTime % 2 == 0 then
        if pathType == Common_pb.TeamMoveType_ResTake then
            local tile = TileInfo.GetTileMsg()

			local tileMsg = TileInfo.GetTileMsg()
			local entryType = TileInfo.GetTileMsg() and TileInfo.GetTileMsg().data.entryType or nil

			if tile ~= nil then
                CalculateSoldiersForCollectingResources(MaxSoilderNumber, (WorldMap.GetTileData(tile).capacity - tile.res.num)*Global.GetResWeight(entryType))
            end
        elseif pathType == Common_pb.TeamMoveType_MineTake then
            local tile = TileInfo.GetTileMsg()
            local tileMsg = TileInfo.GetTileMsg()
			local entryType = TileInfo.GetTileMsg() and TileInfo.GetTileMsg().data.entryType or nil
			local tileData = WorldMap.GetTileData(tile)

			if tile ~= nil then
                local mine = TileInfo.GetTileMsg().guildbuild
                CalculateSoldiersForCollectingResources(MaxSoilderNumber, (mine.totalRemaining - mine.totalSpeed * (GameTime.GetSecTime() - mine.nowTime))*Global.GetResWeight(tileData.resourceType))
            end
        else
            local availableSoldiers = PriorityQueue(4, function(soldierA, soldierB)
                if soldierA.num ~= soldierB.num then
                    return soldierA.num < soldierB.num
                end

                if soldierA.info.fight_point ~= soldierB.info.fight_point then
                    return soldierA.info.fight_point > soldierB.info.fight_point
                end

                return soldierA.uid > soldierB.uid
            end)

            local leftNum = MaxSoilderNumber
            for level = 4, 1, -1 do
                if leftNum <= 0 then
                    break
                end

                for id = 1004, 1001, -1 do
                    local uid = level * 100 + id
                    local soldierInfo = BattleLeftSortInfos[uid]
                    if soldierInfo then
                        local soldier = {}
                        soldier.uid = uid
                        soldier.info = soldierInfo
                        soldier.num = soldierInfo.total_num

                        availableSoldiers:Push(soldier)
                    end
                end

                while leftNum > 0 and not availableSoldiers:IsEmpty() do
                    local numAvailableSoldier = availableSoldiers:Count();
                    local soldier = availableSoldiers:Pop()
                    local actual = SetLeftInfo(soldier.info.unitId, math.floor(leftNum / numAvailableSoldier))
                    leftNum = leftNum - actual
                end
            end
        end
    end
    
    RefrushTotalSoliderNum()
    QuickTime = QuickTime + 1
end


CalNormalBattleMoveMaxNum = function()
    return Barrack.GetArmyNum()
end

function Hide()
    Global.CloseUI(_M)
    ResBar.OnMenuClose("BattleMove")
end

function LoadUI()
    SetClickCallback(transform:Find("Container").gameObject,Hide)
    QuickTime = 0

    MaxSoilderNumber =  math.floor(CalNormalBattleMoveMaxNum())
    if FixedMaxSoilderNumber ~= nil then
        MaxSoilderNumber = math.floor(math.min(MaxSoilderNumber, FixedMaxSoilderNumber))
    end

    BattleUI = {}
    BattleUI.bg_left = {}

    
    BattleUI.bg_left.noitem_gobj = transform:Find("Container/bg_frane/bg_left/bg_noitem").gameObject
    BattleUI.bg_left.armys_scrollview = transform:Find("Container/bg_frane/bg_left/Scroll View"):GetComponent("UIScrollView")
    BattleUI.bg_left.armys_grid = transform:Find("Container/bg_frane/bg_left/Scroll View/Grid"):GetComponent("UIGrid")
    BattleUI.BattleMoveLeftInfo = transform:Find("BattleMoveLeftinfo").gameObject

    BattleUI.bg_left.PowerNum = transform:Find("Container/bg_frane/powerPanel/power/num"):GetComponent("UILabel");

    BattleUI.bg_left.PowerNum.color = Color.white
    BattleUI.bg_left.Animator = transform:Find("Container/bg_frane/powerPanel/power"):GetComponent("Animator");

    RefrushLeftInfo()
    RefrushTotalSoliderNum()


    SetClickCallback(transform:Find("Container/bg_frane/bg_top/btn_close").gameObject,CloseClickCallback)
    local quick = transform:Find("Container/bg_frane/btn_upgrade_gold")
    SetClickCallback(quick.gameObject,QuickSelectCallBack)

    BattleUI.battle = transform:Find("Container/bg_frane/btn_upgrade")
    BattleUI.battle.gameObject:SetActive(true)
    SetClickCallback(BattleUI.battle.gameObject,function()
        MoveRequest()
    end)

    QuickSelectCallBack()
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)    
end

function CloseAll()
    Hide()
end

function Awake()
end

function Start()
    LoadUI()
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)    
    Tooltip.HideItemTip()

      
    if cancelCallback ~= nil then
        cancelCallback()
    end    
    cancelCallback = nil
    FixedMaxSoilderNumber = nil
    BattleUI = nil
    if BattleLeftInfos ~= nil then
        table.foreach(BattleLeftInfos,function(_,v) 
            v.obj:SetActive(false)
            v.obj.transform.parent = nil
            GameObject.Destroy(v.obj)
        end)  
    end
    BattleLeftInfos = nil
    SuccessCallBack = nil
end

function SetFixedMaxSoilder(num)
    FixedMaxSoilderNumber = num
end



function Show()
    Barrack.RequestArmNum(function()
        Global.OpenUI(_M)
    end)
end

RefrushFight = function()
    --print("----------------------------------------------   RefrushFight")
    BattleFight = 0
    local army = 0
    AttributeBonus.CollectBonusInfo()
    table.foreach(BattleLeftInfos,function(_,v)
        local data = Barrack.GetAramInfo(v.type_id,v.level)
        army = army + AttributeBonus.CalBattlePointNew(data)*v.num
        --print(v.type_id,v.level,AttributeBonus.CalBattlePointNew(data))
    end)

    BattleFight = army
    BattleUI.bg_left.PowerNum.text = math.ceil( BattleFight);
end

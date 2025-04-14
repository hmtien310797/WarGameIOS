module("MapMask", package.seeall)

-- local GUIMgr = Global.GGUIMgr
-- local Controller = Global.GController
-- local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
-- local AudioMgr = Global.GAudioMgr
-- local UIAnimMgr = Global.GUIAnimMgr
-- local String = System.String
-- local WorldToLocalPoint = NGUIMath.WorldToLocalPoint
-- local Screen = UnityEngine.Screen
-- local isEditor = UnityEngine.Application.isEditor

-- local ResourceLibrary = Global.GResourceLibrary
-- local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime

-- local SetPressCallback = UIUtil.SetPressCallback
-- local SetClickCallback = UIUtil.SetClickCallback
-- local AddDelegate = UIUtil.AddDelegate
-- local RemoveDelegate = UIUtil.RemoveDelegate

-- local NGUITools = NGUITools
-- local GameObject = UnityEngine.GameObject
-- local FloatText = FloatText
-- local WorldMapData = WorldMapData

-- local uiRoot

local Base = { x = 171, y= 167, wx = 2488, wy = 2424 }
local Barracks = { x = 171, y= 170, wx = 2488, wy = 2472 }
local timer = 0
local TutorialType = 0
local _ui
local PathData2 = {
    {sx = 170, sy = 175, ex = 168, ey = 180, startTime = 0, time = 10},
    {sx = 169, sy = 181, ex = 173, ey = 177, startTime = 0, time = 15}
}

local PathData2Status2 = {
    {sx = 158, sy = 158, ex = 171, ey = 167, startTime = 0, time = 5},
    {sx = 167, sy = 162, ex = 171, ey = 167, startTime = 0, time = 5},
    {sx = 171, sy = 162, ex = 171, ey = 167, startTime = 0, time = 5},
    {sx = 186, sy = 165, ex = 171, ey = 167, startTime = 0, time = 5},
    {sx = 185, sy = 163, ex = 171, ey = 167, startTime = 0, time = 5}
}

local function SetLookAtCoord(mapX, mapY)
    if _ui == nil then
        return
    end    
    _ui.mapMgr:GoPos(mapX, mapY)

end

function EffectEnd()
    _ui.mapMgr.NoUpdateWorld = false
    _ui.itween:MoveTo(_ui.worldCamera.gameObject, UnityEngine.Vector3(Base.wx+30,-40,Base.wy+30), 0, 1, function() 
        Hide()
    end)
end

function Attack()
    -- _ui.Barracks = _ui.mapMgr.transform:Find("World/Canvas/BuildTypeMap1/bingying_1_3D")
    -- _ui.Barracks.gameObject:SetActive(false)
    _ui.mapMgr:SetPathData(Barracks.x, Barracks.y, Base.x, Base.y, 
    "",
    Common_pb.SceneEntryType_Home,
    Serclimax.GameTime.GetSecTime(),
    3,
    nil)
    _ui.mapMgr:DrawLine()
    timer = 0.8
end

function Move()    
    _ui.mask = transform:Find("mask"):GetComponents(typeof(TweenAlpha))   
    
    -- _ui.maskForwardCallBack = EventDelegate.Callback(function()
    --     _ui.mask[1]:PlayForward(true)
    --     --设置2屏飞机
    --     for i,v in ipairs(PathData2) do
    --         _ui.mapMgr:SetPathData(v.sx, v.sy, v.ex, v.ey, 
    --         "",
    --         Common_pb.SceneEntryType_Home,
    --         Serclimax.GameTime.GetSecTime() + v.startTime,
    --         v.time,
    --         nil)
    --     end
    --     _ui.mapMgr:DrawLine()
    --     _ui.itween:MoveTo(_ui.worldCamera.gameObject, UnityEngine.Vector3(Barracks.wx,0,Barracks.wy), 0, 5, function() 
    --         _ui.mapMgr:SelectTile(Barracks.x, Barracks.y, 1, 1)
    --         timer = 1.5
    --     end)  
    -- end)
    -- _ui.maskBackCallBack = EventDelegate.Callback(function()
        _ui.itween:MoveTo(_ui.worldCamera.gameObject, UnityEngine.Vector3(Barracks.wx,0,Barracks.wy), 0, 3, function() 
            _ui.mapMgr:SelectTile(Barracks.x, Barracks.y, 1, 1)
            timer = 1.5
        end) 
    -- end)

    --设置2屏飞机
    for i,v in ipairs(PathData2) do
        _ui.mapMgr:SetPathData(v.sx, v.sy, v.ex, v.ey, 
        "",
        Common_pb.SceneEntryType_Home,
        Serclimax.GameTime.GetSecTime() + v.startTime,
        v.time,
        nil)
    end
    _ui.mapMgr:DrawLine()
  
    
    -- _ui.itween:MoveTo(_ui.worldCamera.gameObject, UnityEngine.Vector3(3832,0,3732), 0, 3, function() 
        -- SetLookAtCoord(Barracks.x, Barracks.y + 10)        
    -- end)
    
    -- EventDelegate.Add(_ui.mask[0].onFinished, _ui.maskForwardCallBack)
    -- EventDelegate.Add(_ui.mask[1].onFinished, _ui.maskBackCallBack)
    -- _ui.mask[1]:PlayForward(true)
    
end

function MoveTo(mapX, mapY, callback)
    local worldCamera = WorldMapMgr.Instance.transform:Find("WorldCamera")  
    PreViewAnimation.Instance:MoveTo(worldCamera.gameObject, WorldMapMgr.Instance:GetCurPosToWorldPos(mapX, mapY, 0), 0, 1, callback)
end

function MoveBase()
    _ui.itween:MoveTo(_ui.worldCamera.gameObject, UnityEngine.Vector3(Base.wx,0,Base.wy), 0, 1, function() 
        _ui.mapMgr:SelectTile(Base.x, Base.y, 1, 1)
        timer = 1.5 
    end)
end

function Tutorials()
    if _ui.status == 1 then  
        TutorialType = TutorialType + 1
        if TutorialType == 1 then 
            Move()
            Starwars.RequestGameLog(1,2)
            
            -- Tutorial.TriggerModule(10000)
        elseif TutorialType == 2 then        
            local isTutorial = Tutorial.TriggerModule(10000)
            if isTutorial == false then
                isTutorial = Tutorial.TriggerModule(10001)
                if isTutorial == false then
                    MapMask.MoveBase()
                end
            end
        elseif TutorialType == 3 then
            local isTutorial = Tutorial.TriggerModule(10002)
            if isTutorial == false then
                MapMask.Attack()
            end
        elseif TutorialType == 4 then
            EffectEnd()
            timer = 0.5
        elseif TutorialType == 5 then
            _ui.mapMgr:PlayEffect(Base.x, Base.y, 0, 5)
        end
    elseif _ui.status == 2 then 
        TutorialType = TutorialType + 1
        if TutorialType == 1 then 
            _ui.mapMgr:PlayEffect(Base.x, Base.y, 0, 5)
            timer = 2.5
        elseif TutorialType == 2 then 
            Event.Resume(9)
            if maincity.gameObject ~= nil then
                maincity.gameObject:SetActive(true)
            end
            MainCityUI.gameObject:SetActive(true)
            -- MainCityUI.HideWorldMapPreView(true, nil, nil)
            Hide()	
        end
    end
end

function Update()
    if timer >= 0 then
        timer = timer - GameTime.deltaTime
        if timer < 0 then
            Tutorials()
        end
    end
end

function LoadPrefab()
    -- _ui.itween:MoveTo(_ui.worldCamera.gameObject, UnityEngine.Vector3(3832, 0, 3832), 0, 1, function() 
    --     _ui.mapMgr:SelectTile(252, 252, 7, 7)
    -- end)
    Global.OpenTopUI(_M)
end 

function Show(mapX, mapY, status, cb)
    TutorialType = 0
    _ui = {}
    _ui.status = status
    _ui.mapX = mapX
    _ui.mapY = mapY
    _ui.callBack = cb
    _ui.mapMgr = WorldMapMgr.Instance
    _ui.mapMgr.isFirst = true
    _ui.mapMgr:SetSelfInfo(MainData.GetCharId(), UnionInfoData.GetGuildId())        
    _ui.itween = PreViewAnimation.Instance
    SetLookAtCoord(mapX, mapY)
    _ui.worldCamera = _ui.mapMgr.transform:Find("WorldCamera")  
    if status == 1 then  
        SetLookAtCoord(Barracks.x, Barracks.y + 10)
        -- _ui.worldCamera.transform.localPosition = UnityEngine.Vector3(3752, 100, 3752)
    elseif status == 2 then
        _ui.BaseText = _ui.mapMgr.transform:Find("World/Canvas/BuildTypeMap2/jidi_01_3D/HUD/BaseHUD/label/text").gameObject
        _ui.BaseText:SetActive(false)
        _ui.BaseText = _ui.mapMgr.transform:Find("World/Canvas/BuildTypeMap2/jidi_01_3D/HUD/BaseHUD/label/text1").gameObject
        _ui.BaseText:SetActive(true)
        if maincity.gameObject ~= nil then
            maincity.gameObject:SetActive(false)
        end
        
        MainCityUI.gameObject:SetActive(false)
        Global.OpenTopUI(_M)

         --设置第2次2屏飞机
         for i,v in ipairs(PathData2Status2) do
            _ui.mapMgr:SetPathData(v.sx, v.sy, v.ex, v.ey, 
            "",
            Common_pb.SceneEntryType_Home,
            Serclimax.GameTime.GetSecTime() + v.startTime,
            v.time,
            nil)
        end
        _ui.mapMgr:DrawLine()
        timer = 4
    end

    if _ui.callBack then 
        _ui.callBack()
    end   
end

function Hide()	    
    if _ui.status == 1 then
        Starwars.RequestGameLog(1,3)
        MainCityUI.StartTeachBattle()
        -- Global.PlaySLGPVPReport("Event2Demo")
    end
    MainCityUI.DestroyTerrain()
    Global.CloseUI(_M)	
    
end

function Close()
    if _ui.mask ~= nil then
        EventDelegate.Remove(_ui.mask[0].onFinished, _ui.maskForwardCallBack)
        EventDelegate.Remove(_ui.mask[1].onFinished, _ui.maskBackCallBack)     
    end
    _ui = nil
end

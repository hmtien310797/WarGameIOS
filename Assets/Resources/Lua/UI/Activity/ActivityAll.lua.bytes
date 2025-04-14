module("ActivityAll", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local SetTooltipCallback = UIUtil.SetTooltipCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local activities = {}

local currentTab = 0
local previousTab = -1
local tabID = {}

local _ui
local tabEffect = {}
local hasNotice = {}

local isRequesting = false
local isInViewport = false

----- 添加新的战场活动 -------------------------------------------------
-- 1. *在Activity表中配置相关信息（名称、图标、开启时间、特效......）
-- 2. *在ACTIVITY_ID中注册新的活动ID（和表中相同）
-- 3. 若需要在战场界面顶端显示倒计时，请在HAS_COUNTDOWN中注册活动相关ID
-- 4. *在ShowTab()中添加新活动页签UI的显示方法（xxx.Show()）
-- 5. *在CloseTab()中添加新活动页签UI的关闭方法（xxx.Hide()）
-- 6. 在UpdateNotice()中添加新活动相关的红点逻辑
-- 7. 在NotifyActivityAvailable()中添加新活动在开启瞬间的相关处理 
-- 8. 在NotifyActivityUnavailable()中添加新活动在关闭瞬间的相关处理
--
-- *必做
------------------------------------------------------------------------

------------------- CONSTANTS -------------------
local DEFAULT_TAB = 1
local ACTIVITY_ID = {["empty"] = 0,
                     ["RebelArmyWanted"] = 2001,
                     ["Panzer"] = 2002,
                     ["Panzer_predict"] = 2003,
                     ["ActivityRace"] = 103,
                     ["ActivityTreasure"] = 102,
                     ["NewRace"] = 111,
                     ["UnionMoba"] = 7,

                     ["ActivityTreasure1"] = 1021,
                     ["ActivityTreasure2"] = 1022,
                     ["ActivityTreasure3"] = 1023,
                     ["ActivityTreasure4"] = 1024,
                     ["ActivityTreasure5"] = 1025,

                     ["RebelArmyAttack"] = 107,
                     ["Fort_predict"] = 2007,
                     ["Fort"] = 108,
                     ["gov1_T"] = 2008,
                     ["gov1_F"] = 2009,
                     ["gov2_T"] = 2010,
                     ["gov2_F"] = 2011,
                     ["fortress_P"] = 2013,
                     ["fortress_E"] = 110,
                     ["stronghold_P"] = 2012,
                     ["stronghold_E"] = 109,
                     ["PVP_ATK_Activity"] = 2014,
                     ["PVP_ATK_Activity_P"] = 2015,
                     ["New_StongHold_P"] = 2016,
                     ["New_StongHold_E"] = 2017,
					 
                     ["Combine_StongHold_First_P"] = 110001,
                     ["Combine_StongHold_First_E"] = 100001,
                     ["Combine_StongHold_Normal_P"] = 110002,
                     ["Combine_StongHold_Normal_E"] = 100002,
                     ["Combine_Fortress_First_P"] = 110003,
                     ["Combine_Fortress_First_E"] = 100003,
                     ["Combine_Fortress_Normal_P"] = 110004,
                     ["Combine_Fortress_Normal_E"] = 100004,
					 
                     ["Combine_Gov_First_P"] = 110005,
                     ["Combine_Gov_First_E"] = 100005,
                     ["Combine_Gov_Normal_P"] = 110006,
                     ["Combine_Gov_Normal_E"] = 100006,
					 
                    }
local HAS_COUNTDOWN = {[2003] = true,
                       [2007] = true,
                       [2008] = true,
                       [2009] = true,
                       [2012] = true,
                       [2013] = true,
                       [109] = true,
                       [110] = true,
                       [2015] = true,
                       [2016] = true,
                       [2017] = true,
					   [100001] = true,
					   [110002] = true,
					   [100002] = true,
					   [110003] = true,
					   [100003] = true,
					   [110004] = true,
					   [100004] = true,
					   [110005] = true,
					   [100005] = true,
					   [110006] = true,
					   [100006] = true,
                      }

local SORT_BY_NOTICE = false

local TESTMODE = false
-------------------------------------------------
Redraw = nil

local Draw = nil

function IsInViewport()
    return isInViewport
end

function GetActivityIdByName(name)
    return ACTIVITY_ID[name]
end

local function SetCurrentTab(tab)
    currentTab = tab
end

local function SetPreviousTab(tab)
    previousTab = tab
end

local function SetTabActivityID(tab, id)
    tabID[tab] = id
end

function GetTabActivityID(tab)
    local id = tabID[tab or currentTab]

    return id or 0
end

function GetActivityTabByID(id)
	print(id)
    if isInViewport then
        local activity = activities[id]
        local uiTab = activity and _ui.tabList.tabs[activity.tab] or nil

        return uiTab and uiTab.transform or nil
    end

    return nil
end

local function MakeConfigs(_activities)
    if _activities == nil then
        activities = {}
        return 0
    end

    local count = 0
    local sortedList = {}

    local now = Serclimax.GameTime.GetSecTime()

    for _, activity in ipairs(_activities) do
		print(activity.activityId)
        local templete = activity.templet
        if templete >= 200 and templete < 300 or activity.activityId == 7 then
            if SORT_BY_NOTICE then
                if activities[activity.activityId] == nil then
                    activities[activity.activityId] = {isAvailable = now < activity.endTime}
                else
                    activities[activity.activityId].isAvailable = now < activity.endTime
                end
            end

            table.insert(sortedList, activity)
            count = count + 1
        end    
    end

    if SORT_BY_NOTICE then
        UpdateNotice()
    end

    table.sort(sortedList, function(activity1, activity2)
        -- if activity1.isOpen ~= activity2.isOpen then
        --     return activity1.isOpen
        -- end

        if SORT_BY_NOTICE then
            local hasNotice1 = HasNotice(activity1.activityId)
            local hasNotice2 = HasNotice(activity2.activityId)

            if hasNotice1 ~= hasNotice2 then
                return hasNotice1
            end
        end

        return activity1.order > activity2.order
    end)

    activities = {}
    tabID = {}
    for tab, activity in ipairs(sortedList) do
        local config = {}
        config.id = activity.activityId
        config.name = activity.name
        config.icon = activity.icon
        config.endTime = activity.endTime
        config.isAvailable = now < activity.endTime
        config.Templet = activity.templet
        config.effect = activity.effect
        config.tab = tab

        activities[config.id] = config
        SetTabActivityID(tab, config.id)
    end
    if not SORT_BY_NOTICE then
        UpdateNotice()
    end

    return count
end

----- 页签操作 ---------------------------------------------------------------------------
local function ShowTab(id, callback)
    if id == ACTIVITY_ID["empty"] then
        ActivityAll_empty.Show()

        if callback ~= nil then
            callback()
        end
    elseif id == ACTIVITY_ID["RebelArmyWanted"] then
        RebelArmyWanted.Show()
        
        if callback ~= nil then
            callback()
        end
    elseif id == ACTIVITY_ID["Panzer"] then
        rebel.Show()
            
        if callback ~= nil then
            callback()
        end

        MapHelp.Open(300, false, function() end, true)
    elseif id == ACTIVITY_ID["Panzer_predict"] then
        rebel_predict.Show()
        
        if callback ~= nil then
            callback()
        end
    elseif id == ACTIVITY_ID["ActivityRace"] then
        ActivityRace.Show()
            
        if callback ~= nil then
            callback()
        end

        MapHelp.Open(800, false, function() end, true)
    elseif id == ACTIVITY_ID["NewRace"] then
        local newracedata = NewRaceData.GetData()
        if newracedata.actId == 0 or newracedata.actId == 999999 then
            NewRaceRredict.Show()
        elseif newracedata.actId > 0 and newracedata.actId <= 5 then
            NewRace.Show()
        elseif newracedata.actId == 6 then
            NewRaceResult.Show()
        end
        if callback ~= nil then
            callback()
        end
    elseif id == ACTIVITY_ID["UnionMoba"] then
        AllianceLogin.Show()
        if callback ~= nil then
            callback()
        end
    elseif id == ACTIVITY_ID["ActivityTreasure"] or
           id == ACTIVITY_ID["ActivityTreasure1"] or
           id == ACTIVITY_ID["ActivityTreasure2"] or
           id == ACTIVITY_ID["ActivityTreasure3"] or
           id == ACTIVITY_ID["ActivityTreasure4"] or
           id == ACTIVITY_ID["ActivityTreasure5"]    
    then
        print("ActivityTreasure " ,id)
        ActivityTreasure.Show()
        
        if callback ~= nil then
            callback()
        end
    elseif id == ACTIVITY_ID["RebelArmyAttack"] then
        RebelArmyAttackData.RequestSiegeMonsterInfo(function(msg)
            if isInViewport and GetTabActivityID() == ACTIVITY_ID["RebelArmyAttack"] then
                if msg.code == 0 then
                    RebelArmyAttack.RequestOpenUI(msg)

                    if callback ~= nil then
                        callback()
                    end
                else
                    tab = 0
                    ActivityAll_empty.Show()
                    Global.ShowError(msg.code)
                end
            end
        end)
    elseif id == ACTIVITY_ID["Fort_predict"] then
        Fort_predict.Show()
        
        if callback ~= nil then
            callback()
        end
    elseif id == ACTIVITY_ID["Fort"] then
        FortInfoall.Show(function()
            if callback ~= nil then
                callback()
            end
        end)
    elseif id == ACTIVITY_ID["gov1_T"] then
        GOV_predict.Show()
        if callback ~= nil then
            callback()
        end
    elseif id == ACTIVITY_ID["gov2_T"] then
        GOV_predict.Show()
        if callback ~= nil then
            callback()
        end
    elseif id == ACTIVITY_ID["gov1_F"] then
        GOV_predict.Show()
        if callback ~= nil then
            callback()
        end
    elseif id == ACTIVITY_ID["gov2_F"] then
        GOV_predict.Show()
        if callback ~= nil then
            callback()
        end
	elseif id == ACTIVITY_ID["Combine_Gov_First_P"] then
        GOV_predict.Show()
        if callback ~= nil then
            callback()
        end
    elseif id == ACTIVITY_ID["Combine_Gov_Normal_P"] then
        GOV_predict.Show()
        if callback ~= nil then
            callback()
        end
    elseif id == ACTIVITY_ID["Combine_Gov_First_E"] then
        GOV_predict.Show()
        if callback ~= nil then
            callback()
        end
    elseif id == ACTIVITY_ID["Combine_Gov_Normal_E"] then
        GOV_predict.Show()
        if callback ~= nil then
            callback()
        end
    elseif id == ACTIVITY_ID["fortress_P"] then
        FortressInfoall.Show(Common_pb.SceneEntryType_Fortress, id)

        local previousTabID = GetTabActivityID(previousTab)
        if callback ~= nil then
            callback(previousTabID == ACTIVITY_ID["fortress_P"] or previousTabID == ACTIVITY_ID["fortress_E"])
        end
    elseif id == ACTIVITY_ID["fortress_E"] then
        FortressInfoall.Show(Common_pb.SceneEntryType_Fortress, id)

        local previousTabID = GetTabActivityID(previousTab)
        if callback ~= nil then
            callback(previousTabID == ACTIVITY_ID["fortress_P"] or previousTabID == ACTIVITY_ID["fortress_E"])
        end
	elseif id == ACTIVITY_ID["Combine_Fortress_First_P"] then
        FortressInfoall.Show(Common_pb.SceneEntryType_Fortress, id)

        local previousTabID = GetTabActivityID(previousTab)
        if callback ~= nil then
            callback(previousTabID == ACTIVITY_ID["Combine_Fortress_First_P"] or previousTabID == ACTIVITY_ID["Combine_Fortress_First_E"])
        end
    elseif id == ACTIVITY_ID["Combine_Fortress_First_E"] then
        FortressInfoall.Show(Common_pb.SceneEntryType_Fortress, id)

        local previousTabID = GetTabActivityID(previousTab)
        if callback ~= nil then
            callback(previousTabID == ACTIVITY_ID["Combine_Fortress_First_P"] or previousTabID == ACTIVITY_ID["Combine_Fortress_First_E"])
        end	
	elseif id == ACTIVITY_ID["Combine_Fortress_Normal_P"] then
        FortressInfoall.Show(Common_pb.SceneEntryType_Fortress, id)

        local previousTabID = GetTabActivityID(previousTab)
        if callback ~= nil then
            callback(previousTabID == ACTIVITY_ID["Combine_Fortress_Normal_P"] or previousTabID == ACTIVITY_ID["Combine_Fortress_Normal_E"])
        end
    elseif id == ACTIVITY_ID["Combine_Fortress_Normal_E"] then
        FortressInfoall.Show(Common_pb.SceneEntryType_Fortress, id)

        local previousTabID = GetTabActivityID(previousTab)
        if callback ~= nil then
            callback(previousTabID == ACTIVITY_ID["Combine_Fortress_Normal_P"] or previousTabID == ACTIVITY_ID["Combine_Fortress_Normal_E"])
        end		
    elseif id == ACTIVITY_ID["stronghold_P"] then
        StrongholdInfoall.Show(Common_pb.SceneEntryType_Stronghold, id)

        local previousTabID = GetTabActivityID(previousTab)
        if callback ~= nil then
            callback(previousTabID == ACTIVITY_ID["stronghold_P"] or previousTabID == ACTIVITY_ID["stronghold_E"])
        end
    elseif id == ACTIVITY_ID["stronghold_E"] then
        StrongholdInfoall.Show(Common_pb.SceneEntryType_Stronghold, id)

        local previousTabID = GetTabActivityID(previousTab)
        if callback ~= nil then
            callback(previousTabID == ACTIVITY_ID["stronghold_P"] or previousTabID == ACTIVITY_ID["stronghold_E"])
        end
	elseif id == ACTIVITY_ID["New_StongHold_P"] then
        StrongholdInfoall.Show(Common_pb.SceneEntryType_Stronghold, id)

        local previousTabID = GetTabActivityID(previousTab)
        if callback ~= nil then
            callback(previousTabID == ACTIVITY_ID["New_StongHold_P"] or previousTabID == ACTIVITY_ID["New_StongHold_E"])
        end
    elseif id == ACTIVITY_ID["New_StongHold_E"] then
        StrongholdInfoall.Show(Common_pb.SceneEntryType_Stronghold, id)

        local previousTabID = GetTabActivityID(previousTab)
        if callback ~= nil then
            callback(previousTabID == ACTIVITY_ID["New_StongHold_P"] or previousTabID == ACTIVITY_ID["New_StongHold_E"])
        end
	elseif id == ACTIVITY_ID["Combine_StongHold_Normal_P"] then
        StrongholdInfoall.Show(Common_pb.SceneEntryType_Stronghold, id)

        local previousTabID = GetTabActivityID(previousTab)
        if callback ~= nil then
            callback(previousTabID == ACTIVITY_ID["Combine_StongHold_Normal_P"] or previousTabID == ACTIVITY_ID["Combine_StongHold_Normal_E"])
        end
    elseif id == ACTIVITY_ID["Combine_StongHold_Normal_E"] then
        StrongholdInfoall.Show(Common_pb.SceneEntryType_Stronghold, id)

        local previousTabID = GetTabActivityID(previousTab)
        if callback ~= nil then
            callback(previousTabID == ACTIVITY_ID["Combine_StongHold_Normal_P"] or previousTabID == ACTIVITY_ID["Combine_StongHold_Normal_E"])
        end	
	elseif id == ACTIVITY_ID["Combine_StongHold_First_P"] then
        StrongholdInfoall.Show(Common_pb.SceneEntryType_Stronghold, id)
        local previousTabID = GetTabActivityID(previousTab)
        if callback ~= nil then
            callback(previousTabID == ACTIVITY_ID["Combine_StongHold_First_P"] or previousTabID == ACTIVITY_ID["Combine_StongHold_First_E"])
        end	
	elseif id == ACTIVITY_ID["Combine_StongHold_First_E"] then
        StrongholdInfoall.Show(Common_pb.SceneEntryType_Stronghold, id)

        local previousTabID = GetTabActivityID(previousTab)
          if callback ~= nil then
            callback(previousTabID == ACTIVITY_ID["Combine_StongHold_First_P"] or previousTabID == ACTIVITY_ID["Combine_StongHold_First_E"])
        end	
    elseif id == ACTIVITY_ID["PVP_ATK_Activity"] then
        ActiveSlaughterData.ReqMsgSlaughterGetInfo(nil,true)
        PVP_ATK_Activity.Show() 
        if callback ~= nil then
            callback(reviousTabID == ACTIVITY_ID["PVP_ATK_Activity"] or previousTabID == ACTIVITY_ID["PVP_ATK_Activity_P"])
        end    
    elseif  id == ACTIVITY_ID["PVP_ATK_Activity_P"] then  
        ActiveSlaughterData.ReqMsgSlaughterGetInfo(nil,true)
        PVP_ATK_Activity.Show() 
        if callback ~= nil then
            callback(reviousTabID == ACTIVITY_ID["PVP_ATK_Activity"] or previousTabID == ACTIVITY_ID["PVP_ATK_Activity_P"])
        end         
    end
end

local function CloseTab(id)
    if id == nil then
        id = GetTabActivityID()
    end

    if id == ACTIVITY_ID["empty"] then
        ActivityAll_empty.Hide()
    elseif id == ACTIVITY_ID["RebelArmyWanted"] then
        RebelArmyWanted.CloseAll()
    elseif id == ACTIVITY_ID["Panzer"] then
        rebel.CloseSelf()
    elseif id == ACTIVITY_ID["Panzer_predict"] then
        rebel_predict.Hide()
    elseif id == ACTIVITY_ID["ActivityRace"] then
        ActivityRace.CloseAll()
    elseif id == ACTIVITY_ID["NewRace"] then
        NewRace.Hide()
        NewRaceRredict.Hide()
        NewRaceResult.Hide()
    elseif id == ACTIVITY_ID["UnionMoba"] then
        AllianceLogin.Hide()
    elseif id == ACTIVITY_ID["ActivityTreasure"] or
    id == ACTIVITY_ID["ActivityTreasure1"] or
    id == ACTIVITY_ID["ActivityTreasure2"] or
    id == ACTIVITY_ID["ActivityTreasure3"] or
    id == ACTIVITY_ID["ActivityTreasure4"] or
    id == ACTIVITY_ID["ActivityTreasure5"] then
        ActivityTreasure.CloseAll()
    elseif id == ACTIVITY_ID["RebelArmyAttack"] then
        RebelArmyAttack.CloseSelf()
    elseif id == ACTIVITY_ID["Fort_predict"] then
        Fort_predict.Hide()
    elseif id == ACTIVITY_ID["Fort"] then
        FortInfoall.Hide()
    elseif id == ACTIVITY_ID["gov1_T"] then
        GOV_predict.Hide()
    elseif id == ACTIVITY_ID["gov2_T"] then
        GOV_predict.Hide()
    elseif id == ACTIVITY_ID["gov1_F"] then
        GOV_predict.Hide()
    elseif id == ACTIVITY_ID["gov2_F"] then
        GOV_predict.Hide()
    elseif id == ACTIVITY_ID["Combine_Gov_First_P"] then
        GOV_predict.Hide()
    elseif id == ACTIVITY_ID["Combine_Gov_Normal_P"] then
        GOV_predict.Hide()
    elseif id == ACTIVITY_ID["Combine_Gov_First_E"] then
        GOV_predict.Hide()
    elseif id == ACTIVITY_ID["Combine_Gov_Normal_E"] then
        GOV_predict.Hide()	
    elseif id == ACTIVITY_ID["fortress_P"] then
        FortressInfoall.Hide()
    elseif id == ACTIVITY_ID["fortress_E"] then
        FortressInfoall.Hide()
	 elseif id == ACTIVITY_ID["Combine_Fortress_First_P"] then
        FortressInfoall.Hide()
    elseif id == ACTIVITY_ID["Combine_Fortress_First_E"] then
        FortressInfoall.Hide()	
	 elseif id == ACTIVITY_ID["Combine_Fortress_Normal_P"] then
        FortressInfoall.Hide()
    elseif id == ACTIVITY_ID["Combine_Fortress_Normal_E"] then
        FortressInfoall.Hide()	
    elseif id == ACTIVITY_ID["stronghold_P"] then
        StrongholdInfoall.Hide()
    elseif id == ACTIVITY_ID["stronghold_E"] then
        StrongholdInfoall.Hide()
	elseif id == ACTIVITY_ID["New_StongHold_P"] then
        StrongholdInfoall.Hide()
    elseif id == ACTIVITY_ID["New_StongHold_E"] then
        StrongholdInfoall.Hide()
	elseif id == ACTIVITY_ID["Combine_StongHold_Normal_P"] then
        StrongholdInfoall.Hide()
    elseif id == ACTIVITY_ID["Combine_StongHold_Normal_E"] then
        StrongholdInfoall.Hide()
	elseif id == ACTIVITY_ID["Combine_StongHold_First_P"] then
        StrongholdInfoall.Hide()
	elseif id == ACTIVITY_ID["Combine_StongHold_First_E"] then
        StrongholdInfoall.Hide()
    elseif id == ACTIVITY_ID["PVP_ATK_Activity"] then
        PVP_ATK_Activity.Hide()
    elseif id == ACTIVITY_ID["PVP_ATK_Activity_P"] then
        PVP_ATK_Activity.Hide()          
    end
end

local function ClosePreviousTab()
    CloseTab(GetTabActivityID(previousTab))
end
------------------------------------------------------------------------------------------

----- 红点 ------------------------------------------------
function HasNotice(id) -- ActivityAll.HasNotice()
    if id == nil then
        for _, flag in pairs(hasNotice) do
            if flag then
                return true
            end
        end

        return false
    end

    local config = activities[id]
    if config == nil or not config.isAvailable then
        return false
    end

    return hasNotice[id] or false
end

function UpdateNotice(id) -- ActivityAll.UpdateNotice()
    if id == nil then
        for id, _ in pairs(activities) do
            UpdateNotice(id)
        end

        return hasNotice
    end

    local flag = false

    local activity = activities[id]
    if activity == nil then
        return false
    elseif activity.isAvailable then
        if id == ACTIVITY_ID["RebelArmyWanted"] then
            flag = RebelWantedData.HasNotice()
        elseif id == ACTIVITY_ID["Panzer"] then
            flag = rebel.HasNotice()
        elseif id == ACTIVITY_ID["Panzer_predict"] then
            flag = not rebel_predict.HasVisited()
        elseif id == ACTIVITY_ID["ActivityRace"] then
            flag = RaceData.HasNotice()
        elseif id == ACTIVITY_ID["NewRace"] then
            flag = NewRaceData.HasNotice()
        elseif id == ACTIVITY_ID["UnionMoba"] then
            flag = UnionMobaActivityData.HasNotice()
        elseif id == ACTIVITY_ID["ActivityTreasure"] or
        id == ACTIVITY_ID["ActivityTreasure1"] or
        id == ACTIVITY_ID["ActivityTreasure2"] or
        id == ACTIVITY_ID["ActivityTreasure3"] or
        id == ACTIVITY_ID["ActivityTreasure4"] or
        id == ACTIVITY_ID["ActivityTreasure5"]    
 then
            flag = ActivityTreasureData.HasNotice()
        elseif id == ACTIVITY_ID["RebelArmyAttack"] then
            flag = RebelArmyAttackData.HasNotice()
        elseif id == ACTIVITY_ID["Fort_predict"] then
            flag = not Fort_predict.HasVisited()
        elseif id == ACTIVITY_ID["Fort"] then
            flag = FortInfoall.HasNotice()
        elseif id == ACTIVITY_ID["gov1_T"] then
            flag =  not GOV_predict.HasVisited()
        elseif id == ACTIVITY_ID["gov2_T"] then
            flag =  not GOV_predict.HasVisited()
        elseif id == ACTIVITY_ID["gov1_F"] then
            flag =  not GOV_predict.HasVisited()
        elseif id == ACTIVITY_ID["gov2_F"] then
            flag =  not GOV_predict.HasVisited()
        elseif id == ACTIVITY_ID["Combine_Gov_First_P"] then
            flag =  not GOV_predict.HasVisited()
        elseif id == ACTIVITY_ID["Combine_Gov_Normal_P"] then
            flag =  not GOV_predict.HasVisited()
        elseif id == ACTIVITY_ID["Combine_Gov_First_E"] then
            flag =  not GOV_predict.HasVisited()
        elseif id == ACTIVITY_ID["Combine_Gov_Normal_E"] then
            flag =  not GOV_predict.HasVisited()	 
        elseif id == ACTIVITY_ID["fortress_P"] then
            flag =  not FortressInfoall.HasVisited(id)
        elseif id == ACTIVITY_ID["fortress_E"] then
            flag =  not FortressInfoall.HasVisited(id)
        elseif id == ACTIVITY_ID["Combine_Fortress_First_P"] then
            flag =  not FortressInfoall.HasVisited(id)
        elseif id == ACTIVITY_ID["Combine_Fortress_First_E"] then
            flag =  not FortressInfoall.HasVisited(id)
        elseif id == ACTIVITY_ID["Combine_Fortress_Normal_P"] then
            flag =  not FortressInfoall.HasVisited(id)
        elseif id == ACTIVITY_ID["Combine_Fortress_Normal_E"] then
            flag =  not FortressInfoall.HasVisited(id)
		elseif id == ACTIVITY_ID["stronghold_P"] then
            flag =  not StrongholdInfoall.HasVisited(id)
        elseif id == ACTIVITY_ID["stronghold_E"] then
            flag =  not StrongholdInfoall.HasVisited(id)
		 elseif id == ACTIVITY_ID["New_StongHold_P"] then
            flag =  not StrongholdInfoall.HasVisited(id)
        elseif id == ACTIVITY_ID["New_StongHold_E"] then
            flag =  not StrongholdInfoall.HasVisited(id)
		elseif id == ACTIVITY_ID["Combine_StongHold_Normal_P"] then
            flag =  not StrongholdInfoall.HasVisited(id)
        elseif id == ACTIVITY_ID["Combine_StongHold_Normal_E"] then
            flag =  not StrongholdInfoall.HasVisited(id)
		elseif id == ACTIVITY_ID["Combine_StongHold_First_P"] then
            flag =  not StrongholdInfoall.HasVisited(id)	
		elseif id == ACTIVITY_ID["Combine_StongHold_First_E"] then
            flag =  not StrongholdInfoall.HasVisited(id)
        elseif id == ACTIVITY_ID["PVP_ATK_Activity"] then   
            flag =  not PVP_ATK_Activity.HasVisited() 
        elseif id == ACTIVITY_ID["PVP_ATK_Activity_P"] then   
            flag =  not PVP_ATK_Activity.HasVisited()                      
        end
    end

    if isInViewport then
        local uiTab = _ui.tabList.tabs[activity.tab]
        if uiTab ~= nil then
            uiTab.notice:SetActive(flag)
        end
    end

    hasNotice[id] = flag
    return flag
end
-----------------------------------------------------------

----- 活动状态变更 ---------------------------------------------------------------------
function NotifyActivityAvailable(id) -- ActivityAll.NotifyActivityAvailable()
    if id == nil then
        print("[ERROR][ActivityAll.NotifyActivityAvailable] Invalid input (id = nil)")
    else
        local availableConfig = activities[id]
        if availableConfig ~= nil then
            availableConfig.isAvailable = true
        else
            activities[id] = {isAvailable = true}
        end

        if id == ACTIVITY_ID["RebelArmyWanted"] then
            RebelWantedData.NotifyAvailable()
        elseif id == ACTIVITY_ID["Panzer"] then
            rebel.NotifyAvailable()
        elseif id == ACTIVITY_ID["Panzer_predict"] then
            rebel_predict.NotifyAvailable()
        elseif id == ACTIVITY_ID["ActivityRace"] then
            RaceData.NotifyAvailable()
        elseif id == ACTIVITY_ID["NewRace"] then
            NewRaceData.NotifyAvailable()
        elseif id == ACTIVITY_ID["UnionMoba"] then
            UnionMobaActivityData.NotifyAvailable()
        elseif id == ACTIVITY_ID["ActivityTreasure"] or
        id == ACTIVITY_ID["ActivityTreasure1"] or
        id == ACTIVITY_ID["ActivityTreasure2"] or
        id == ACTIVITY_ID["ActivityTreasure3"] or
        id == ACTIVITY_ID["ActivityTreasure4"] or
        id == ACTIVITY_ID["ActivityTreasure5"] then
            ActivityTreasureData.NotifyAvailable()
        elseif id == ACTIVITY_ID["RebelArmyAttack"] then
            RebelArmyAttackData.NotifyAvailable()
        elseif id == ACTIVITY_ID["Fort_predict"] then
            Fort_predict.NotifyAvailable()
        elseif id == ACTIVITY_ID["Fort"] then
            FortInfoall.NotifyAvailable()
        elseif id == ACTIVITY_ID["gov1_T"] then
            GOV_predict.NotifyAvailable()
        elseif id == ACTIVITY_ID["gov2_T"] then
            GOV_predict.NotifyAvailable()
        elseif id == ACTIVITY_ID["gov1_F"] then
            GOV_predict.NotifyAvailable()
        elseif id == ACTIVITY_ID["gov2_F"] then
            GOV_predict.NotifyAvailable()
        elseif id == ACTIVITY_ID["Combine_Gov_First_P"] then
            GOV_predict.NotifyAvailable()
        elseif id == ACTIVITY_ID["Combine_Gov_Normal_P"] then
            GOV_predict.NotifyAvailable()
        elseif id == ACTIVITY_ID["Combine_Gov_First_E"] then
            GOV_predict.NotifyAvailable()
        elseif id == ACTIVITY_ID["Combine_Gov_Normal_E"] then
            GOV_predict.NotifyAvailable()
        elseif id == ACTIVITY_ID["fortress_P"] then
            FortressInfoall.NotifyAvailable(id)
        elseif id == ACTIVITY_ID["fortress_E"] then
            FortressInfoall.NotifyAvailable(id)
        elseif id == ACTIVITY_ID["Combine_Fortress_First_P"] then
            FortressInfoall.NotifyAvailable(id)
        elseif id == ACTIVITY_ID["Combine_Fortress_First_E"] then
            FortressInfoall.NotifyAvailable(id)		
        elseif id == ACTIVITY_ID["Combine_Fortress_Normal_P"] then
            FortressInfoall.NotifyAvailable(id)
        elseif id == ACTIVITY_ID["Combine_Fortress_Normal_E"] then
            FortressInfoall.NotifyAvailable(id)	                     
        elseif id == ACTIVITY_ID["stronghold_P"] then
            StrongholdInfoall.NotifyAvailable(id)
        elseif id == ACTIVITY_ID["stronghold_E"] then
            StrongholdInfoall.NotifyAvailable(id)
        elseif id == ACTIVITY_ID["New_StongHold_P"] then
            StrongholdInfoall.NotifyAvailable(id)
        elseif id == ACTIVITY_ID["New_StongHold_E"] then
            StrongholdInfoall.NotifyAvailable(id)
		elseif id == ACTIVITY_ID["Combine_StongHold_First_P"] then
            StrongholdInfoall.NotifyAvailable(id)
        elseif id == ACTIVITY_ID["Combine_StongHold_First_E"] then
            StrongholdInfoall.NotifyAvailable(id)
        elseif id == ACTIVITY_ID["Combine_StongHold_Normal_E"] then
            StrongholdInfoall.NotifyAvailable(id)
        elseif id == ACTIVITY_ID["Combine_StongHold_Normal_P"] then
            StrongholdInfoall.NotifyAvailable(id)
        elseif id == ACTIVITY_ID["PVP_ATK_Activity"] then
            PVP_ATK_Activity.NotifyAvailable()
        elseif id == ACTIVITY_ID["PVP_ATK_Activity_P"] then
            PVP_ATK_Activity.NotifyAvailable()                       
        end
    end
end

function NotifyActivityUnavailable(id) -- ActivityAll.NotifyActivityUnavailable()
    if id == nil then
        if not TESTMODE then
            ActivityData.RequestBattleFieldActivityConfigs(function(_activities)
                MakeConfigs(_activities)
            end)
        end
    else
        local unavailableConfig = activities[id]
        if unavailableConfig ~= nil then
            unavailableConfig.isAvailable = false
            MainCityUI.UpdateActivityAllNotice(id)

            if id == ACTIVITY_ID["Panzer_predict"] then
                ActivityData.RequestBattleFieldActivityConfigs(function(_activities)
                     for _, activity in ipairs(_activities) do
                        if activity.activityId == ACTIVITY_ID["Panzer"] then
                            local config = {}
                            config.id = activity.activityId
                            config.name = activity.name
                            config.icon = activity.icon
                            config.endTime = activity.endTime
                            config.isAvailable = true
                            config.Templet = activity.templet
                            config.tab = unavailableConfig.tab

                            activities[ACTIVITY_ID["Panzer"]] = config
                            break
                        end
                    end

                    if isInViewport then
                        SetTabActivityID(unavailableConfig.tab, ACTIVITY_ID["Panzer"])

                        if currentTab == unavailableConfig.tab then
                            ShowTab(ACTIVITY_ID["Panzer"], function()
                                CloseTab(ACTIVITY_ID["Panzer_predict"])
                                GUIMgr:BringForward(gameObject)
                            end)
                        end
                    end
                end)
            elseif id == ACTIVITY_ID["Fort_predict"] then
                ActivityData.RequestBattleFieldActivityConfigs(function(_activities)
                    for _, activity in ipairs(_activities) do
                        if activity.activityId == ACTIVITY_ID["Fort"] then
                            local config = {}
                            config.id = activity.activityId
                            config.name = activity.name
                            config.icon = activity.icon
                            config.endTime = activity.endTime
                            config.isAvailable = true
                            config.Templet = activity.templet
                            config.tab = unavailableConfig.tab

                            activities[ACTIVITY_ID["Fort"]] = config
                            break
                        end
                    end

                    if isInViewport then
                        SetTabActivityID(unavailableConfig.tab, ACTIVITY_ID["Fort"])

                        if currentTab == unavailableConfig.tab then
                            ShowTab(ACTIVITY_ID["Fort"], function()
                                CloseTab(ACTIVITY_ID["Fort_predict"])
                                GUIMgr:BringForward(gameObject)
                            end)
                        end
                    end
                end)
            elseif id == ACTIVITY_ID["gov1_T"] then
                ActivityData.RequestBattleFieldActivityConfigs(function(_activities)
                    for _, activity in ipairs(_activities) do
                        if activity.activityId == ACTIVITY_ID["gov2_T"] then
                            local config = {}
                            config.id = activity.activityId
                            config.name = activity.name
                            config.icon = activity.icon
                            config.endTime = activity.endTime
                            config.isAvailable = true
                            config.Templet = activity.templet
                            config.tab = unavailableConfig.tab

                            activities[ACTIVITY_ID["gov2_T"]] = config
                            break
                        end
                    end

                    if isInViewport then
                        SetTabActivityID(unavailableConfig.tab, ACTIVITY_ID["gov2_T"])

                        if currentTab == unavailableConfig.tab then
                            ShowTab(ACTIVITY_ID["gov2_T"], function()
                                --CloseTab(ACTIVITY_ID["gov1_T"])
                                GUIMgr:BringForward(gameObject)
                            end)
                        end
                    end
                end)
            elseif id == ACTIVITY_ID["gov1_F"] then
                ActivityData.RequestBattleFieldActivityConfigs(function(_activities)
                    for _, activity in ipairs(_activities) do
                        if activity.activityId == ACTIVITY_ID["gov2_F"] then
                            local config = {}
                            config.id = activity.activityId
                            config.name = activity.name
                            config.icon = activity.icon
                            config.endTime = activity.endTime
                            config.isAvailable = true
                            config.Templet = activity.templet
                            config.tab = unavailableConfig.tab

                            activities[ACTIVITY_ID["gov2_F"]] = config
                            break
                        end
                    end

                    if isInViewport then
                        SetTabActivityID(unavailableConfig.tab, ACTIVITY_ID["gov2_F"])

                        if currentTab == unavailableConfig.tab then
                            ShowTab(ACTIVITY_ID["gov2_F"], function()
                                --CloseTab(ACTIVITY_ID["gov1_F"])
                                GUIMgr:BringForward(gameObject)
                            end)
                        end
                    end
                end)
			elseif id == ACTIVITY_ID["Combine_Gov_First_P"] then
                ActivityData.RequestBattleFieldActivityConfigs(function(_activities)
                    for _, activity in ipairs(_activities) do
                        if activity.activityId == ACTIVITY_ID["Combine_Gov_Normal_P"] then
                            local config = {}
                            config.id = activity.activityId
                            config.name = activity.name
                            config.icon = activity.icon
                            config.endTime = activity.endTime
                            config.isAvailable = true
                            config.Templet = activity.templet
                            config.tab = unavailableConfig.tab

                            activities[ACTIVITY_ID["Combine_Gov_Normal_P"]] = config
                            break
                        end
                    end

                    if isInViewport then
                        SetTabActivityID(unavailableConfig.tab, ACTIVITY_ID["Combine_Gov_Normal_P"])

                        if currentTab == unavailableConfig.tab then
                            ShowTab(ACTIVITY_ID["Combine_Gov_Normal_P"], function()
                                --CloseTab(ACTIVITY_ID["Combine_Gov_First_P"])
                                GUIMgr:BringForward(gameObject)
                            end)
                        end
                    end
                end)
            elseif id == ACTIVITY_ID["Combine_Gov_First_E"] then
                ActivityData.RequestBattleFieldActivityConfigs(function(_activities)
                    for _, activity in ipairs(_activities) do
                        if activity.activityId == ACTIVITY_ID["Combine_Gov_Normal_E"] then
                            local config = {}
                            config.id = activity.activityId
                            config.name = activity.name
                            config.icon = activity.icon
                            config.endTime = activity.endTime
                            config.isAvailable = true
                            config.Templet = activity.templet
                            config.tab = unavailableConfig.tab

                            activities[ACTIVITY_ID["Combine_Gov_Normal_E"]] = config
                            break
                        end
                    end

                    if isInViewport then
                        SetTabActivityID(unavailableConfig.tab, ACTIVITY_ID["Combine_Gov_Normal_E"])

                        if currentTab == unavailableConfig.tab then
                            ShowTab(ACTIVITY_ID["Combine_Gov_Normal_E"], function()
                                --CloseTab(ACTIVITY_ID["Combine_Gov_First_E"])
                                GUIMgr:BringForward(gameObject)
                            end)
                        end
                    end
                end)
            elseif  id == ACTIVITY_ID["fortress_P"] then
                ActivityData.RequestBattleFieldActivityConfigs(function(_activities)
                    for _, activity in ipairs(_activities) do
                        if activity.activityId == ACTIVITY_ID["fortress_E"] then
                            local config = {}
                            config.id = activity.activityId
                            config.name = activity.name
                            config.icon = activity.icon
                            config.endTime = activity.endTime
                            config.isAvailable = true
                            config.Templet = activity.templet
                            config.tab = unavailableConfig.tab

                            activities[ACTIVITY_ID["fortress_E"]] = config
                            break
                        end
                    end
                    if isInViewport then
                        SetTabActivityID(unavailableConfig.tab, ACTIVITY_ID["fortress_P"])
                        
                        if currentTab == unavailableConfig.tab then
                            ShowTab(ACTIVITY_ID["fortress_E"], function()                        
                            end)
                        end
                    end   
                end)
            elseif  id == ACTIVITY_ID["fortress_E"] then
                if isInViewport then
                    MessageBox.Show(TextMgr:GetText("ui_zone13"), function() 
                        CloseTab(ACTIVITY_ID["fortress_E"])
                        Redraw()
                    end)
                else
                    Redraw()
                end
			elseif  id == ACTIVITY_ID["Combine_Fortress_First_P"] then
                ActivityData.RequestBattleFieldActivityConfigs(function(_activities)
                    for _, activity in ipairs(_activities) do
                        if activity.activityId == ACTIVITY_ID["Combine_Fortress_First_E"] then
                            local config = {}
                            config.id = activity.activityId
                            config.name = activity.name
                            config.icon = activity.icon
                            config.endTime = activity.endTime
                            config.isAvailable = true
                            config.Templet = activity.templet
                            config.tab = unavailableConfig.tab

                            activities[ACTIVITY_ID["Combine_Fortress_First_E"]] = config
                            break
                        end
                    end
                    if isInViewport then
                        SetTabActivityID(unavailableConfig.tab, ACTIVITY_ID["Combine_Fortress_First_P"])
                        
                        if currentTab == unavailableConfig.tab then
                            ShowTab(ACTIVITY_ID["Combine_Fortress_First_E"], function()                        
                            end)
                        end
                    end   
                end)
            elseif  id == ACTIVITY_ID["Combine_Fortress_First_E"] then
                if isInViewport then
                    MessageBox.Show(TextMgr:GetText("ui_zone13"), function() 
                        CloseTab(ACTIVITY_ID["Combine_Fortress_First_E"])
                        Redraw()
                    end)
                else
                    Redraw()
                end	
			elseif  id == ACTIVITY_ID["Combine_Fortress_Normal_P"] then
                ActivityData.RequestBattleFieldActivityConfigs(function(_activities)
                    for _, activity in ipairs(_activities) do
                        if activity.activityId == ACTIVITY_ID["Combine_Fortress_Normal_E"] then
                            local config = {}
                            config.id = activity.activityId
                            config.name = activity.name
                            config.icon = activity.icon
                            config.endTime = activity.endTime
                            config.isAvailable = true
                            config.Templet = activity.templet
                            config.tab = unavailableConfig.tab

                            activities[ACTIVITY_ID["Combine_Fortress_Normal_E"]] = config
                            break
                        end
                    end
                    if isInViewport then
                        SetTabActivityID(unavailableConfig.tab, ACTIVITY_ID["Combine_Fortress_Normal_P"])
                        
                        if currentTab == unavailableConfig.tab then
                            ShowTab(ACTIVITY_ID["Combine_Fortress_Normal_E"], function()                        
                            end)
                        end
                    end   
                end)
            elseif  id == ACTIVITY_ID["Combine_Fortress_Normal_E"] then
                if isInViewport then
                    MessageBox.Show(TextMgr:GetText("ui_zone13"), function() 
                        CloseTab(ACTIVITY_ID["Combine_Fortress_Normal_E"])
                        Redraw()
                    end)
                else
                    Redraw()
                end			 
            elseif  id == ACTIVITY_ID["stronghold_P"] then
                ActivityData.RequestBattleFieldActivityConfigs(function(_activities)
                    for _, activity in ipairs(_activities) do
                        if activity.activityId == ACTIVITY_ID["stronghold_E"] then
                            local config = {}
                            config.id = activity.activityId
                            config.name = activity.name
                            config.icon = activity.icon
                            config.endTime = activity.endTime
                            config.isAvailable = true
                            config.Templet = activity.templet
                            config.tab = unavailableConfig.tab

                            activities[ACTIVITY_ID["stronghold_E"]] = config
                            break
                        end
                    end
                    if isInViewport then
                        SetTabActivityID(unavailableConfig.tab, ACTIVITY_ID["stronghold_P"])
                        
                        if currentTab == unavailableConfig.tab then
                            ShowTab(ACTIVITY_ID["stronghold_E"], function()                        
                            end)
                        end
                    end   
                end)
            elseif  id == ACTIVITY_ID["stronghold_E"] then
                if isInViewport then
                    MessageBox.Show(TextMgr:GetText("ui_zone13"), function() 
                        CloseTab(ACTIVITY_ID["stronghold_E"])
                        Redraw()
                    end)
                else
                    Redraw()
                end
			elseif  id == ACTIVITY_ID["New_StongHold_P"] then
                ActivityData.RequestBattleFieldActivityConfigs(function(_activities)
                    for _, activity in ipairs(_activities) do
                        if activity.activityId == ACTIVITY_ID["New_StongHold_E"] then
                            local config = {}
                            config.id = activity.activityId
                            config.name = activity.name
                            config.icon = activity.icon
                            config.endTime = activity.endTime
                            config.isAvailable = true
                            config.Templet = activity.templet
                            config.tab = unavailableConfig.tab

                            activities[ACTIVITY_ID["New_StongHold_E"]] = config
                            break
                        end
                    end
                    if isInViewport then
                        SetTabActivityID(unavailableConfig.tab, ACTIVITY_ID["New_StongHold_P"])
                        
                        if currentTab == unavailableConfig.tab then
                            ShowTab(ACTIVITY_ID["New_StongHold_E"], function()                        
                            end)
                        end
                    end   
                end)
            elseif  id == ACTIVITY_ID["New_StongHold_E"] then
                if isInViewport then
                    MessageBox.Show(TextMgr:GetText("ui_zone13"), function() 
                        CloseTab(ACTIVITY_ID["New_StongHold_E"])
                        Redraw()
                    end)
                else
                    Redraw()
                end
			elseif  id == ACTIVITY_ID["Combine_StongHold_First_P"] then
                ActivityData.RequestBattleFieldActivityConfigs(function(_activities)
                    for _, activity in ipairs(_activities) do
                        if activity.activityId == ACTIVITY_ID["Combine_StongHold_First_E"] then
                            local config = {}
                            config.id = activity.activityId
                            config.name = activity.name
                            config.icon = activity.icon
                            config.endTime = activity.endTime
                            config.isAvailable = true
                            config.Templet = activity.templet
                            config.tab = unavailableConfig.tab

                            activities[ACTIVITY_ID["Combine_StongHold_First_E"]] = config
                            break
                        end
                    end
                    if isInViewport then
                        SetTabActivityID(unavailableConfig.tab, ACTIVITY_ID["Combine_StongHold_First_P"])
                        
                        if currentTab == unavailableConfig.tab then
                            ShowTab(ACTIVITY_ID["Combine_StongHold_First_E"], function()                        
                            end)
                        end
                    end   
                end)
			 elseif  id == ACTIVITY_ID["Combine_StongHold_First_E"] then
                if isInViewport then
                    MessageBox.Show(TextMgr:GetText("ui_zone13"), function() 
                        CloseTab(ACTIVITY_ID["Combine_StongHold_First_E"])
                        Redraw()
                    end)
                else
                    Redraw()
                end	
				
			elseif  id == ACTIVITY_ID["Combine_StongHold_Normal_P"] then
                ActivityData.RequestBattleFieldActivityConfigs(function(_activities)
                    for _, activity in ipairs(_activities) do
                        if activity.activityId == ACTIVITY_ID["Combine_StongHold_Normal_E"] then
                            local config = {}
                            config.id = activity.activityId
                            config.name = activity.name
                            config.icon = activity.icon
                            config.endTime = activity.endTime
                            config.isAvailable = true
                            config.Templet = activity.templet
                            config.tab = unavailableConfig.tab

                            activities[ACTIVITY_ID["Combine_StongHold_Normal_E"]] = config
                            break
                        end
                    end
                    if isInViewport then
                        SetTabActivityID(unavailableConfig.tab, ACTIVITY_ID["Combine_StongHold_Normal_P"])
                        
                        if currentTab == unavailableConfig.tab then
                            ShowTab(ACTIVITY_ID["Combine_StongHold_Normal_E"], function()                        
                            end)
                        end
                    end   
                end)
            elseif  id == ACTIVITY_ID["Combine_StongHold_Normal_E"] then
                if isInViewport then
                    MessageBox.Show(TextMgr:GetText("ui_zone13"), function() 
                        CloseTab(ACTIVITY_ID["Combine_StongHold_Normal_E"])
                        Redraw()
                    end)
                else
                    Redraw()
                end			
			elseif  id == ACTIVITY_ID["Combine_StongHold_First_E"] then
                if isInViewport then
                    MessageBox.Show(TextMgr:GetText("ui_zone13"), function() 
                        CloseTab(ACTIVITY_ID["Combine_StongHold_First_E"])
                        Redraw()
                    end)
                else
                    Redraw()
                end 
				
            elseif id == ACTIVITY_ID["PVP_ATK_Activity_P"] then
                Redraw()
            elseif id == ACTIVITY_ID["ActivityTreasure1"] or
            id == ACTIVITY_ID["ActivityTreasure2"] or
            id == ACTIVITY_ID["ActivityTreasure3"] or
            id == ACTIVITY_ID["ActivityTreasure4"]  then
                local cur_activity_id = id
                local next_activity_id = cur_activity_id + 1
                if next_activity_id > ACTIVITY_ID["ActivityTreasure5"] then
                    next_activity_id = ACTIVITY_ID["ActivityTreasure1"]
                end
                ActivityData.RequestBattleFieldActivityConfigs(function(_activities)
                    for _, activity in ipairs(_activities) do
                        if activity.activityId == next_activity_id then
                            local config = {}
                            config.id = activity.activityId
                            config.name = activity.name
                            config.icon = activity.icon
                            config.endTime = activity.endTime
                            config.isAvailable = true
                            config.Templet = activity.templet
                            config.tab = unavailableConfig.tab

                            activities[next_activity_id] = config
                            break
                        end
                    end
                    if isInViewport and unavailableConfig.tab then
                        SetTabActivityID(unavailableConfig.tab, cur_activity_id)
                
                        if currentTab == unavailableConfig.tab then
                            ShowTab(next_activity_id, function()                        
                            end)
                        end
                    end   
                end)
            elseif id == ACTIVITY_ID["ActivityTreasure5"] then
                if isInViewport then
                    MessageBox.Show(TextMgr:GetText("ui_zone13"), function() 
                        CloseTab(ACTIVITY_ID["ActivityTreasure5"])
                        Redraw()
                    end)
                else
                    Redraw()
                end 
            elseif id == ACTIVITY_ID["NewRace"] then
                if isInViewport then
                    local newracedata = NewRaceData.GetData()
                    if newracedata.actId == 0 then
                    elseif newracedata.actId > 0 and newracedata.actId <= 5 then
                        ShowTab(ACTIVITY_ID["NewRace"], function()
                            NewRaceRredict.Hide()
                            GUIMgr:BringForward(gameObject)
                            NewRaceBanner.Show()
                        end)
                    elseif newracedata.actId == 6 then
                        ShowTab(ACTIVITY_ID["NewRace"], function()
                            NewRace.Hide()
                            GUIMgr:BringForward(gameObject)
                        end)
                    else
                        CloseTab(ACTIVITY_ID["NewRace"])
                        Redraw()
                    end
                else
                    Redraw()
                end
            elseif id == ACTIVITY_ID["UnionMoba"] then
                if isInViewport then
                    ShowTab(ACTIVITY_ID["UnionMoba"], function()
                        GUIMgr:BringForward(gameObject)
                    end)
                else
                    Redraw()
                end
            elseif isInViewport and currentTab == unavailableConfig.tab then
                MessageBox.Show(TextMgr:GetText("ui_zone13"), Redraw)
            end
        end
    end
end
----------------------------------------------------------------------------------------

----- 倒计时 -------------------------------------------------------------------------
function UpdateCountdown(id)
    if isInViewport and _ui ~= nil then
        if id == nil then
            for tab, uiTab in ipairs(_ui.tabList.tabs) do
                local id = GetTabActivityID(tab)
                local config = activities[id]
                if HAS_COUNTDOWN[id] and config ~= nil and config.isAvailable then
                    local leftTime = Global.GetLeftCooldownSecond(config.endTime)
                    if leftTime > 0 then
                        uiTab.countdown.time.text = Global.SecondToTimeLong(leftTime)
                    else
                        uiTab.countdown.gameObject:SetActive(false)
                    end
                end
            end
        elseif id ~= 0 then
            local config = activities[id]
            if HAS_COUNTDOWN[id] and config ~= nil and config.isAvailable then
                uiTab = _ui.tabList.tabs[config.tab]
                if uiTab ~= nil then
                    local leftTime = Global.GetLeftCooldownSecond(config.endTime)
                    if leftTime > 0 then
                        uiTab.countdown.time.text = Global.SecondToTimeLong(leftTime)
                    else
                        uiTab.countdown.gameObject:SetActive(false)
                    end
                end
            end
        else
            print(string.format("[ActivityAll.UpdateCountdown] Invalid id (%d)", id))
        end
    end
end
--------------------------------------------------------------------------------------

----- 特效 -------------------------------------------------------------------
local function RefreshFx(id)
    if isInViewport and _ui ~= nil then
        if id == nil then
            for tab, uiTab in ipairs(_ui.tabList.tabs) do
                local effect = tabEffect[GetTabActivityID(tab)]
                uiTab.fx_notice:SetActive(effect and effect ~= 0 or false)
            end
        else
            local uiTab = GetActivityTabByID(id)
            if uiTab ~= nil then
                local effect = tabEffect[id]
                uiTab = fx_notice:SetActive(effect and effect ~= 0 or false)
            end
        end
    end
end

function EnableFx(id, effect)
    if id ~= nil then
        tabEffect[id] = effect
        RefreshFx(id)
    end
end

function DisableFx(id)
    if id ~= nil then
        tabEffect[id] = 0
        RefreshFx(id)
    end
end
------------------------------------------------------------------------------

local function SetUI()
    if isInViewport then
        for tab, uiTab in ipairs(_ui.tabList.tabs) do
            uiTab.toggle.value = tab == currentTab

            local id = GetTabActivityID(tab)
            _ui.tabList.tabs[tab].notice:SetActive(HasNotice(id))
            UpdateCountdown(id)
        end
    end
end

local function LoadUI()
    if isInViewport and _ui == nil then
        _ui = {}

        SetClickCallback(transform:Find("Container/close btn").gameObject, CloseAll)

        _ui.newTab = {}
        _ui.newTab.transform = transform:Find("Container/newActivity")
        _ui.newTab.gameObject = _ui.newTab.transform.gameObject
        _ui.newTab.gameObject:GetComponent("UIToggle").value = false

        _ui.newTab.name = _ui.newTab.transform:Find("name"):GetComponent("UILabel")
        _ui.newTab.icon = _ui.newTab.transform:Find("Sprite"):GetComponent("UITexture")

        _ui.newTab.selectedFx = {}
        _ui.newTab.selectedFx.transform = _ui.newTab.transform:Find("selected effect")
        _ui.newTab.selectedFx.gameObject = _ui.newTab.selectedFx.transform.gameObject
        _ui.newTab.selectedFx.name = _ui.newTab.selectedFx.transform:Find("name"):GetComponent("UILabel")
        _ui.newTab.selectedFx.icon = _ui.newTab.selectedFx.transform:Find("Sprite"):GetComponent("UITexture")

        _ui.tabList = {}
        _ui.tabList.transform = transform:Find("Container/top/Scroll View/Grid")
        _ui.tabList.gameObject = _ui.tabList.transform.gameObject
        _ui.tabList.grid = _ui.tabList.transform:GetComponent("UIGrid")
        
        _ui.tabList.tabs = {}
        for id, activity in pairs(activities) do
            if id ~= 0 and activity.isAvailable then
                if id == ACTIVITY_ID["NewRace"] and NewRaceData.GetData().actId > 6 then
                elseif id == ACTIVITY_ID["UnionMoba"] and (UnionMobaActivityData.GetData() ~= nil and 
                                                            (UnionMobaActivityData.GetData().noticetime > Serclimax.GameTime.GetSecTime() or
                                                             UnionMobaActivityData.GetData().status == 5 or
                                                             UnionMobaActivityData.GetData().noticetime == 0)) then
                else
                    local name =  TextMgr:GetText(activity.name)
                    _ui.newTab.name.text = name
                    _ui.newTab.selectedFx.name.text = name

                    local icon = ResourceLibrary:GetIcon("Icon/Activity/", activity.icon)
                    _ui.newTab.icon.mainTexture = icon
                    _ui.newTab.selectedFx.icon.mainTexture = icon

                    uiTab = {}
                    uiTab.gameObject = NGUITools.AddChild(_ui.tabList.gameObject, _ui.newTab.gameObject)
                    uiTab.transform = uiTab.gameObject.transform
                    uiTab.gameObject.name = tostring(200000000 + activity.id + (activity.tab == nil and 0 or activity.tab * 100000))

                    uiTab.toggle = uiTab.transform:GetComponent("UIToggle")

                    UIUtil.SetClickCallback(uiTab.gameObject, function()
                        local id = GetTabActivityID(activity.tab)
                        local config = activities[id]
                        if config ~= nil and config.isAvailable then
                            Refresh(id)
                        else
                            MessageBox.Show(TextMgr:GetText("ui_zone13"), Redraw)
                        end
                    end)

                    uiTab.countdown = {}
                    uiTab.countdown.transform = uiTab.transform:Find("Sprite_time")
                    uiTab.countdown.gameObject = uiTab.countdown.transform.gameObject
                    uiTab.countdown.gameObject:SetActive(HAS_COUNTDOWN[id] and activity.isAvailable)
                    uiTab.countdown.time = uiTab.countdown.transform:Find("Label"):GetComponent("UILabel")

                    uiTab.notice = uiTab.transform:Find("red_dian").gameObject

                    uiTab.fx_notice = uiTab.transform:Find("fx_notice").gameObject

                    if id == ACTIVITY_ID["RebelArmyAttack"] then
                        local activityInfo = RebelArmyAttackData.GetSiegeMonsterInfo()
                        tabEffect[id] = activityInfo and activityInfo.isOpen and 1 or 0
                    elseif id == ACTIVITY_ID["ActivityTreasure"]  or
                    id == ACTIVITY_ID["ActivityTreasure1"] or
                    id == ACTIVITY_ID["ActivityTreasure2"] or
                    id == ACTIVITY_ID["ActivityTreasure3"] or
                    id == ACTIVITY_ID["ActivityTreasure4"] or
                    id == ACTIVITY_ID["ActivityTreasure5"] then
                        tabEffect[id] = ActivityTreasureData.IsActive() and 1 or 0
                    else
                        tabEffect[id] = activity.effect
                    end

                    _ui.tabList.tabs[activity.tab] = uiTab
                end
            end
        end
        _ui.tabList.grid:Reposition()

        RefreshFx()

        RebelWantedData.AddListener(SetUI)
        RaceData.AddListener(SetUI)
        ActivityTreasureData.AddListener(SetUI)
    end
end

Draw = function () -- ActivityAll.Draw()
    LoadUI()
    ShowTab(GetTabActivityID(), function(doUseSamePrefab)
        SetUI()
        
        if not doUseSamePrefab then
            ClosePreviousTab()
            GUIMgr:BringForward(gameObject)
        end
    end)
end

Redraw = function()
    ActivityData.RequestBattleFieldActivityConfigs(function(activities)
        MakeConfigs(activities)

        if isInViewport then
            NGUITools.DestroyChildren(_ui.tabList.transform)
            CloseTab()

            SetPreviousTab(-1)

            _ui = nil

            SetCurrentTab(DEFAULT_TAB)
            Draw()
        else
            Show()
        end
    end)
end

function Show(param) -- param = string(key @ ACTIVITY_ID) | tableData_tActivityCondition.data.id | tab | nil
    if not isInViewport then
        CheckParamAndOpen = function(tabNum)
            if tabNum == 0 then
                print(string.format("[ERROR][ActivityAll.Show] No available activities"))
                SetCurrentTab(0)
            else
                local num = param
                if type(param) == "string" then
                    num = ACTIVITY_ID[param]
                end

                if num ~= nil then
                    if num > 0 and num <= tabNum then
                        SetCurrentTab(num)
                    else
                        if activities[num] == nil then
                            FloatText.Show(TextMgr:GetText("ActivityAll_27"), Color.white)
                            return false
                        else
                            SetCurrentTab(activities[num].tab)
                        end
                    end
                else
                    SetCurrentTab(DEFAULT_TAB)
                end
            end

            Global.OpenUI(_M)
        end

        if TESTMODE then
            local tabNum
            activities, tabNum = TableMgr:GetBattleFieldActivities()
            CheckParamAndOpen(tabNum)
        else
            ActivityData.RequestBattleFieldActivityConfigs(function(activities)
                CheckParamAndOpen(MakeConfigs(activities))
            end)
        end

        return true
    end

    print(System.String.Format("[ActivityAll.Show] The window is already in viewport", num))
    return false
end

function Refresh(id)
    if isInViewport then
        local newTab = activities[id].tab
        if newTab ~= nil and newTab ~= currentTab then
            SetPreviousTab(currentTab)
            SetCurrentTab(newTab)
        end

        Draw()
    end
end

function Hide()
    if isInViewport then
        Global.CloseUI(_M)
    end
end

function CloseAll()
    ActivityAll_empty.Hide()
    RebelArmyWanted.CloseAll()
    rebel.CloseSelf()
    rebel_predict.Hide()
    ActivityRace.CloseAll()
    ActivityTreasure.CloseAll()
    RebelArmyAttack.CloseSelf()
    Fort_predict.Hide()
    FortInfoall.Hide()
    GOV_predict.Hide()
    FortressInfoall.Hide()
    StrongholdInfoall.Hide()
    PVP_ATK_Activity.Hide()
    NewRace.Hide()
    NewRaceRredict.Hide()
    NewRaceResult.Hide()
    AllianceLogin.Hide()
    Hide()
end

function Start()
    isInViewport = true

    Draw()
end

function Close()
    isInViewport = false

    RebelWantedData.RemoveListener(SetUI)
    RaceData.RemoveListener(SetUI)
    ActivityTreasureData.RemoveListener(SetUI)

    SetCurrentTab(0)
    SetPreviousTab(-1)
    tabID = {}

    _ui = nil
end

function Initialize()
    MakeConfigs(ActivityData.GetListData())

    MainCityUI.UpdateActivityAllNotice()
end

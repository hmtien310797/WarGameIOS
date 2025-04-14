module("WelfareAll", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local igTab 

local configs

local tab = 0
local tabID = {}

local ui
local closeCallback

local isInViewport = false

-------------------------- Constants --------------------------
local DEFAULT_TAB = 1
local UI_PREFAB_NAME = { [0] = "ActivityAll_empty",
                         [301] = "GrowGold",
                         --[302] = "SevenDay",
                         --[303] = "ThirtyDay",
                         [304] = "MonthCard_reward",
                         [305] = "Welfare_Template1",
                         [306] = "Welfare_Template1",
                         [307] = "Welfare_Template1",
                         [308] = "HeroCard_reward",
                         [309] = "Welfare_Template1",
                         [399] = "DailyActivity_ContinueRecharge",
                         [501] = "Welfare_Timebag",   
                         [310] = "LuckyRotary", 
                         --[311] = "PVP_LuckyRotary", 
                         [312] = "TenHero", 
                         [313] = "Welfare_heroget",
                         [314] = "Rebate_LuckyRotary",
                         [315] = "ReturnRewards",
                     }

local TEST_MODE = false
---------------------------------------------------------------
function IsInViewport()
    return isInViewport
end

local function GetTabID(_tab)
    return tabID[_tab or tab] or 0
end

local function ShowError()
    MessageBox.Show(TextMgr:GetText("ui_zone13"), Redraw)
end

function NotifyWelfareUnavailable(id)
    if id ~= nil then
        if isInViewport then
            if configs[id] == nil then
                tab = DEFAULT_TAB
                ShowError()
                return
            end
            if tab == configs[id].tab then
                ShowError()
            end
        end
    end
end

function SetNotice(id, flag)
    if isInViewport and ui.tabList.tabs then
        if id == nil then
            for tab, uiTab in ipairs(ui.tabList.tabs) do
                local _flag = flag[GetTabID(tab)]
                if _flag ~= nil then
                    uiTab.notice:SetActive(_flag)
                end
            end
        elseif id ~= 0 then
            local config = configs[id]
            if config ~= nil then
                local tab = config.tab
                local uiTab = ui.tabList.tabs[tab]
                if uiTab ~= nil then
                    uiTab.notice:SetActive(flag)
                else
                    --Global.LogDebug(_M, "SetNotice", string.format("[DEBUG][WelfareAll.SetNotice] Cannot find UI tab (id = %d, tab = %d)", id, tab))
                end
            else
                --Global.LogDebug(_M, "SetNotice", string.format("[DEBUG][WelfareAll.SetNotice] Cannot find the welfare (id = %d)", id))
            end
        end
    end
end

function RefreshNotice(id)
    SetNotice(id, WelfareData.HasNotice(id))
end

function UpdateNotice(id)
    SetNotice(id, WelfareData.UpdateNotice(id))
end

function UpdateConfigs(callback)
    WelfareData.RequestWelfareConfigs(function(_configs, tabNum)
        if IsInViewport() then
            configs = _configs
            configs[0] = {}
            configs[0].Templet = 0
            if callback ~= nil then
                callback(tabNum)
            end
        end
    end)
end

local function LoadUI()
    if ui == nil then
        ui = {}

        UIUtil.SetClickCallback(transform:Find("Container/close btn").gameObject, function()
			Hide()
        end)

        ui.newTab = {}
        ui.newTab.gameObject = transform:Find("Container/newWelfare").gameObject
        ui.newTab.gameObject:GetComponent("UIToggle").value = false

        ui.newTab.name = ui.newTab.gameObject.transform:Find("name"):GetComponent("UILabel")
        ui.newTab.icon = ui.newTab.gameObject.transform:Find("Sprite"):GetComponent("UITexture")

        ui.newTab.selectedFx = {}
        ui.newTab.selectedFx.gameObject = ui.newTab.gameObject.transform:Find("selected effect").gameObject
        ui.newTab.selectedFx.name = ui.newTab.selectedFx.gameObject.transform:Find("name"):GetComponent("UILabel")
        ui.newTab.selectedFx.icon = ui.newTab.selectedFx.gameObject.transform:Find("Sprite"):GetComponent("UITexture")

        ui.tabList = {}
        ui.tabList.gameObject = transform:Find("Container/top/Scroll View/Grid").gameObject
        ui.tabList.grid = ui.tabList.gameObject.transform:GetComponent("UIGrid")
    end
end

local function SetUI()
    if ui ~= nil then
        if ui.tabList.tabs == nil then
            ui.tabList.tabs = {}
            for id, config in pairs(configs) do
                print(id, config.name, config.Templet)
                if id ~= 0 and config.isAvailable and config.name ~= igTab and (config.Templet ~= 315 or (config.Templet == 315 and ReturnRewards.IsInTime())) then
                    local name =  TextMgr:GetText(config.name)
                    ui.newTab.name.text = name
                    ui.newTab.selectedFx.name.text = name

                    local icon = ResourceLibrary:GetIcon("Icon/Activity/", config.icon)
                    ui.newTab.icon.mainTexture = icon
                    ui.newTab.selectedFx.icon.mainTexture = icon

                    uiTab = {}
                    uiTab.gameObject = NGUITools.AddChild(ui.tabList.gameObject, ui.newTab.gameObject)
                    uiTab.gameObject.name = tostring(200000000 + id + (config.tab == nil and 0 or config.tab * 100000))

                    uiTab.toggle = uiTab.gameObject.transform:GetComponent("UIToggle")

                    UIUtil.SetClickCallback(uiTab.gameObject, function()
                        if config ~= nil and config.isAvailable then
                            Refresh(id)
                        else
                            ShowError()
                        end
                    end)

                    uiTab.notice = uiTab.gameObject.transform:Find("red_dian").gameObject
                    if config.Templet == 501 then
                        local tabTime = {}
                        tabTime.lefttime = uiTab.gameObject.transform:Find("Sprite_time").gameObject
                        tabTime.lefttimelabel = uiTab.gameObject.transform:Find("Sprite_time/Label"):GetComponent("UILabel")
                        if not config.data.canTake then
                            tabTime.lefttime:SetActive(true)
                            CountDown.Instance:Add("WelfareAll_501", config.endTime, CountDown.CountDownCallBack(function(t)
                                if t == "00:00:00" then
                                    CountDown.Instance:Remove("WelfareAll_501")
                                    tabTime.lefttime:SetActive(false)
                                else
                                    tabTime.lefttimelabel.text = t
                                end
                            end))
                        else
                            tabTime.lefttime:SetActive(false)
                        end
                    end
                    tabID[config.tab] = id
					
                    ui.tabList.tabs[config.tab] = uiTab
                end
            end
            ui.tabList.grid:Reposition()
        end
        
        
        if tab < 1 or tab > #ui.tabList.tabs then
            Global.LogDebug(_M, "SetUI", string.format("Invalid tab (tab = %d / %d)", tab, #ui.tabList.tabs))
            ActivityAll_empty.Show()
        end

        WelfareData.NotifyUIOpened(GetTabID())

        for _tab, uiTab in ipairs(ui.tabList.tabs) do
            local id = GetTabID(_tab)
            SetNotice(id, WelfareData.HasNotice(id))
            uiTab.toggle.value = _tab == tab
        end
    end
end

local function ShowTab(tab)
    local id = GetTabID(tab)
    local templete = configs[id].Templet

    assert(Global.GetTableFunction(string.format("%s.Show(%d, %d)", UI_PREFAB_NAME[templete], id, templete)))()
end

function RefreshTab(id)
    if isInViewport then
        local config = configs[id or GetTabID()]
        if config ~= nil then
            MainCityUI.UpdateWelfareNotice(config.id)
            assert(Global.GetTableFunction(string.format("%s.Refresh()", UI_PREFAB_NAME[config.Templet])))()
        else
            Global.LogDebug(_M, "Show", System.String.Format("Invalid id ({0})", id))
        end
    end
end

local function HideTab(tab)
    if configs[GetTabID(tab)] then
        assert(Global.GetTableFunction(string.format("%s.Hide()", UI_PREFAB_NAME[configs[GetTabID(tab)].Templet])))()
    end
end

function DelTab(tabpage)
	igTab = tabpage
	Hide()
--[[	if ui~= nil and ui.tabList.grid ~= nil then 
		local childCount =ui.tabList.grid.transform.childCount
		for i = 1, childCount  do
		  UnityEngine.GameObject.Destroy(ui.tabList.grid.transform:GetChild(i-1).gameObject)
		end
		ui.tabList.tabs = nil 
	end 
	tab =1
    ui.coroutines = coroutine.start(function()
		SetUI()
		coroutine.step()
		ui.tabList.grid:Reposition()
		for _tab, uiTab in ipairs(ui.tabList.tabs) do
			local id = GetTabID(_tab)
			uiTab.toggle.value = true
			tab =id
			ShowTab(_tab)
			break
		end
		GUIMgr:BringForward(gameObject)
    end)]]--
end

local function Draw()
    SetUI()

    ShowTab()

    GUIMgr:BringForward(gameObject)
end

function Redraw()
    UpdateConfigs(function()
        NGUITools.DestroyChildren(ui.tabList.gameObject.transform)
        HideTab()

        ui = nil

        Draw()
    end)
end

function Refresh(id)
    if isInViewport then
        if id ~= nil then
            local _tab = configs[id].tab
            if _tab ~= nil and _tab ~= tab then
                if UI_PREFAB_NAME[configs[GetTabID(_tab)].Templet] ~= UI_PREFAB_NAME[configs[GetTabID()].Templet] then              
                    HideTab()
                end
                tab = _tab
            end
        end

        Draw()
    end
end

function Show(num, callback)
    
	if SevenDay.IsSevenDayOver() == true then 
		igTab = "ActivityName_2"
	end
	
	if not isInViewport then
        closeCallback = callback
        configs = {}

        Global.OpenUI(_M)

        UpdateConfigs(function(numTab)
            if num ~= nil then
                if num > 0 and num <= numTab then
                    tab = num
                else
                    if configs[num] == nil then
                        Global.LogDebug(_M, "Show", System.String.Format("Cannot find welfare / UI tab (input = {0})", num))
                        return false
                    else
                        tab = configs[num].tab
                    end
                end
            else
                tab = DEFAULT_TAB
            end
            Draw()
        end)

        return true
    end

    Global.LogDebug(_M, "Show", "The window is already in viewport")

    return false
end

function Hide()
    if isInViewport then
        Global.CloseUI(_M)
    end
end

function Start()
    isInViewport = true

    LoadUI()
end

function Close()
    isInViewport = false

    if closeCallback then
        closeCallback()
    end

    CountDown.Instance:Remove("WelfareAll_501")
    HideTab()

    configs = nil

    tab = 0
    tabID = {}

    ui = nil
    closeCallback = nil
end

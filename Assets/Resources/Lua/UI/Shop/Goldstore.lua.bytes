module("Goldstore", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local GPlayerPrefs = UnityEngine.PlayerPrefs

----- Template ------------------------------------------------------------------------------------------------------
--[[
如需添加新的模板，请在要添加的模板的.lua文件中调用 RegisterAsTemplate 方法注册该模板

    *Show(config, ...)              用于显示模板UI
                                    @params [config] tableData_tGoldStoreTabConfig中页签的配置数据
                                            [...] 不定参数，用于多页签对应同一模板（e.g. Welfare_Template1.lua）以及各模板中的功能扩展

    *Hide()                         用于隐藏模板UI

    IsAvailable(config)             用于判断该页签是否有效（e.g. 活动是否开启），若不实现则为常有效
                                    @params [config] tableData_tGoldStoreTabConfig中页签的配置数据
                                    @return [bool] 页签是否有效

    HasNotice(config)               用于判断该页签是否有红点，若不实现则为无红点
                                    @params [config] tableData_tGoldStoreTabConfig中页签的配置数据
                                    @return [bool] 页签是否有红点

    GetCountdownTime(config)        用于获取页签倒计时，若不实现则为无倒计时
                                    @params [config] tableData_tGoldStoreTabConfig中页签的配置数据，若为nil则返回所有倒计时中最短的倒计时
                                    @return [int] 倒计时时间戳
                                            [nil] 暂无倒计时

    OnAvailabilityChange(config)    是否有效变化事件（e.g. 活动结束），若实现该事件则必须实现 IsAvailable 方法
                                    @params [config] tableData_tGoldStoreTabConfig中页签的配置数据
                                    @return [int] EventDispatcher.CreateEvent()所返回的事件ID

    OnNoticeStatusChange(config)    红点信息变化事件，若实现该事件则必须实现 HasNotice 方法
                                    @params [config] tableData_tGoldStoreTabConfig中页签的配置数据
                                    @return [int] EventDispatcher.CreateEvent()所返回的事件ID

*必须实现
    
（具体实现可参考 Goldstore_template1.lua）
]]

local templates = {}
local templatesWithCountdown = {}

function RegisterAsTemplate(template, module)
    if templates[template] then
        Global.LogError(_M, "RegisterAsTemplate", string.format("%s 不能注册为已注册的模板 (%d)，请更换模板ID", module._NAME, template))
    else
        if not module.Show then
            Global.LogError(_M, "RegisterAsTemplate", string.format("%s 必须实现 Show(config, ...) 方法", module._NAME))
        end

        if not module.Hide then
            Global.LogError(_M, "RegisterAsTemplate", string.format("%s 必须实现 Hide() 方法", module._NAME))
        end

        if module.OnNoticeStatusChange and not module.HasNotice then
            Global.LogError(_M, "RegisterAsTemplate", string.format("%s 实现了 OnNoticeStatusChange(config) 事件但没有实现 HasNotice(config) 方法", module._NAME))
        end

        if module.OnAvailabilityChange and not module.IsAvailable then
            Global.LogError(_M, "RegisterAsTemplate", string.format("%s 实现了 OnAvailabilityChange(config) 事件但没有实现 IsAvailable(config) 方法", module._NAME))
        end

        if module.GetCountdownTime then
            table.insert(templatesWithCountdown, module)
        end

        templates[template] = module
    end
end
--------------------------------------------------------------------------------------------------------------------

----- Event ----------------------------------------------------
local eventOnNoticeStatusChange = EventDispatcher.CreateEvent()

function OnNoticeStatusChange(config)
    return eventOnNoticeStatusChange
end

local function BroadcastEventOnNoticeStatusChange(...)
    EventDispatcher.Broadcast(eventOnNoticeStatusChange, ...)
end
----------------------------------------------------------------

----- Data ---------------------------------------------------------------
local noticeStatus = 0
local availability = 0

local function SetNoticeStatus(tabID, hasNotice)
    noticeStatus = bit.write(noticeStatus, hasNotice and 1 or 0, tabID)
end

local function SetAvailability(tabID, isAvailable)
    availability = bit.write(availability, isAvailable and 1 or 0, tabID)
end

function HasNotice(tabID)
    if tabID then
        return bit.read(bit.band(noticeStatus, availability), tabID) == 1
    else
        --return bit.band(noticeStatus, availability) ~= 0
        local isfirst = false
        if tonumber(os.date("%d")) ~= GPlayerPrefs.GetInt("storeday") then
            isfirst = true
        end
        print(isfirst, bit.band(noticeStatus, availability) ~= 0)
        return isfirst and bit.band(noticeStatus, availability) ~= 0
    end
end

function IsAvailable(tabID)
    if tabID then
        return bit.read(availability, tabID) == 1
    else
        return availability ~= 0
    end
end

function GetCountdownTime()
    local countdownTime
    for _, module in ipairs(templatesWithCountdown) do
        local _countdownTime = module.GetCountdownTime()
        if _countdownTime and (not countdownTime or _countdownTime < countdownTime) then
            countdownTime = _countdownTime
        end
    end

    return countdownTime
end
--------------------------------------------------------------------------

----- UI -----------
local ui
local currentTab
local eventHandlers
--------------------



function IsInViewport()
    return ui ~= nil
end

local function SetCurrentTab(uiTab)
    currentTab = uiTab.config
end

local function HideTab(tab)
    templates[tab.template].Hide()
end

local function ShowTab(uiTab, ...)
    local config = uiTab.config
    local template = config.template

    if currentTab and currentTab.template ~= template then
        HideTab(currentTab)
    end

    SetCurrentTab(uiTab)

    uiTab.toggle.value = true

    templates[template].Show(config, ...)

    if ItemListShowNew.IsInViewport() then
        ItemListShowNew.BringForward()
    end
end

local function ShowTabByID(tabID, giftPackID)
    ShowTab(ui.tabList.tabs[tabID], giftPackID)
end

local function ShowTabByOrder(order, giftPackID)
    ShowTab(ui.tabList.tabsByOrder[order], giftPackID)
end

local function UpdateTabNotice(uiTab)
    local config = uiTab.config
    local templateModule = templates[config.template]

    uiTab.notice:SetActive(HasNotice(config.id))
end

local function UpdateTabCountdown(uiTab)
    local config = uiTab.config
    local timeStamp = templates[config.template].GetCountdownTime(config)

    if timeStamp then
        uiTab.countdown.label.text = Global.SecondToTimeLong(timeStamp - ui.lastUpdateTime)

        if not uiTab.countdown.gameObject.activeSelf then
            uiTab.countdown.gameObject:SetActive(true)
        end
    elseif uiTab.countdown.gameObject.activeSelf then
        uiTab.countdown.gameObject:SetActive(false)
    end
end

local function AddEventHandler(event, tabID, handlerType, handler)
    if not eventHandlers then
        Initialize()
    end
    if not eventHandlers[handlerType] then
        eventHandlers[handlerType] = {}
    end

    if not eventHandlers[handlerType][event] then
        eventHandlers[handlerType][event] = {}
        EventDispatcher.Bind(event, _M, handlerType, function()
            for tabID, handler in pairs(eventHandlers[handlerType][event]) do
                handler()
            end
        end)
    end

    eventHandlers[handlerType][event][tabID] = handler
end

local function RemoveEventHandler(event, tabID)
    for handlerType, handlers in pairs(eventHandlers) do
        if bit.band(handlerType, 2) == 0 and handlers[event] then
            handlers[event][tabID] = nil
        end
    end
end

local function RemoveTab(tabID)
    local uiTab = ui.tabList.tabs[tabID]
    local config = uiTab.config

    local templateModule = templates[config.template]

    if templateModule.GetCountdownTime then
        for i, _uiTab in ipairs(ui.tabList.tabsWithCountdown) do
            if _uiTab == uiTab then
                table.remove(ui.tabList.tabsWithCountdown, i)
                break
            end
        end
    end

    if templateModule.OnNoticeStatusChange then
        RemoveEventHandler(templateModule.OnNoticeStatusChange(config), tabID)
    end

    if templateModule.OnAvailabilityChange then
        RemoveEventHandler(templateModule.OnAvailabilityChange(config), tabID)
    end

    UnityEngine.GameObject.Destroy(uiTab.gameObject)
    ui.tabList.tabs[tabID] = nil

    for i = 1, #ui.tabList.tabsByOrder do
        if ui.tabList.tabsByOrder[i].config.id == tabID then
            table.remove(ui.tabList.tabsByOrder, i)

            if currentTab.id == tabID then
                Show(ui.tabList.tabsByOrder[math.min(#ui.tabList.tabsByOrder, i)].config.id)
            end
            
            return
        end
    end
end

local function AddTab(config)
    local tabID = config.id

    local templateModule = templates[config.template]

    local uiTab = {}

    uiTab.config = config

    uiTab.gameObject = NGUITools.AddChild(ui.tabList.gameObject, ui.tabList.newTab)
    uiTab.transform = uiTab.gameObject.transform
    uiTab.toggle = uiTab.transform:GetComponent("UIToggle")

    uiTab.name = uiTab.transform:Find("Name"):GetComponent("UILabel")
    uiTab.icon = uiTab.transform:Find("icon"):GetComponent("UISprite")
    uiTab.sprite = uiTab.transform:GetComponent("UISprite")
    uiTab.button = uiTab.transform:GetComponent("UIButton")
    uiTab.notice = uiTab.transform:Find("red").gameObject

    uiTab.gameObject.name = 10000 + config.order

    uiTab.name.text = TextMgr:GetText(config.name)
    uiTab.icon.spriteName = config.icon

    uiTab.countdown = {}
    uiTab.countdown.transform = uiTab.transform:Find("Countdown")
    uiTab.countdown.gameObject = uiTab.countdown.transform.gameObject
    uiTab.countdown.label = uiTab.countdown.transform:Find("Time"):GetComponent("UILabel")

    local sprite = config.sprite
    uiTab.sprite.spriteName = sprite
    uiTab.button.normalSprite = sprite

    UpdateTabNotice(uiTab)

    UIUtil.SetClickCallback(uiTab.gameObject, function()
        local tabID = uiTab.config.id
        if tabID ~= currentTab.id then
            Show(tabID)
        end
    end)

    ui.tabList.tabs[tabID] = uiTab
    table.insert(ui.tabList.tabsByOrder, uiTab)

    if templateModule.GetCountdownTime then
        table.insert(ui.tabList.tabsWithCountdown, uiTab)
        UpdateTabCountdown(uiTab)
    else
        uiTab.countdown.gameObject:SetActive(false)
    end

    if templateModule.OnNoticeStatusChange then
        AddEventHandler(templateModule.OnNoticeStatusChange(config), tabID, EventDispatcher.HANDLER_TYPE.DELAYED, function()
            UpdateTabNotice(ui.tabList.tabs[config.id])
        end)
    end

    if templateModule.OnAvailabilityChange then
        AddEventHandler(templateModule.OnAvailabilityChange(config), tabID, EventDispatcher.HANDLER_TYPE.INSTANT, function()
            if not templateModule.IsAvailable(config) then
                RemoveTab(config.id)
                ui.tabList.grid.repositionNow = true
            end
        end)
    end
end

local function SortTabs()
    local function compare(uiTabA, uiTabB)
        return uiTabA.config.order < uiTabB.config.order
    end

    table.sort(ui.tabList.tabsByOrder, compare)
    table.sort(ui.tabList.tabsWithCountdown, compare)

    ui.tabList.grid.repositionNow = true
end

local function UpdateExchequer()
    ui.goldNum.text = MoneyListData.GetDiamond()
end

local function ReportErrorInShowFunction(errorMessage)
    if not currentTab then
        Hide()
    end

    Global.LogError(_M, "Show", errorMessage)

    return false
end

function ShowRechargeTab()
    Show(4)
end

function ShowGiftPack(iapGoodInfo)
    local tabID = iapGoodInfo.tab
    Show(math.floor(tabID / 100), tabID)
end

function ShowUnionCardInfo()
	Show(2 , 3)
end

function Show(tabID, ...)
    GPlayerPrefs.SetInt("storeday",tonumber(os.date("%d")))
    GPlayerPrefs.Save()
    local args = { ... }

    if not IsInViewport() then
        Global.OpenUI(_M)

        for tabID, config in pairs(TableMgr:GetGoldStoreTabConfig()) do
            local templateModule = templates[config.template]
            if templateModule and (not templateModule.IsAvailable or templateModule.IsAvailable(config)) then
                AddTab(config)
            else
                -- return ReportErrorInShowFunction(string.format("Template %d has no registered module", config.template))
            end
        end

        SortTabs()

        UpdateExchequer()
    end

    local uiTabToShow
    if not currentTab and not tabID then
        for _, uiTab in ipairs(ui.tabList.tabsWithCountdown) do
            local config = uiTab.config
            if templates[config.template].GetCountdownTime(config) then
                uiTabToShow = uiTab
                break
            end
        end

        if not uiTabToShow then
            uiTabToShow = ui.tabList.tabsByOrder[1]
        end
    else
        if tabID then
            local uiTab = ui.tabList.tabs[tabID]

            if uiTab then
                local tabConfig = uiTab.config

                if tabConfig.template == 1 then
                    local giftPackTabID = args[1]
                    if giftPackTabID and not GiftPackData.HasAvailableGoods(giftPackTabID) then
                        return ReportErrorInShowFunction(string.format("Tab (%d) has no available gift packs", giftPackTabID))
                    end
                elseif tabConfig.template == 2 then
                    local index = args[1]

                    if index and (index < 1 or index > 4) then
                        return ReportErrorInShowFunction(string.format("Invalid #2 arguments: non-existed index (%d)", index))
                    end
                end
                
                uiTabToShow = uiTab
            else
                return ReportErrorInShowFunction(string.format("Tab (%d) does not exist (Did Nothing)", tabID))
            end
        else
            return true
        end
    end

    ShowTab(uiTabToShow, ...)

    return true
end

function Hide()
    if currentTab then
        HideTab(currentTab)
    end

    MainCityUI.UpdateLimitedTime()
    Global.CloseUI(_M)
end

function Awake()
    local tabList = UIUtil.LoadList(transform:Find("Container/Background/Sidebar/Container/Scroll View"))
    tabList.newTab = transform:Find("Container/Background/Sidebar/New Tab").gameObject
    tabList.tabs = {}
    tabList.tabsByOrder = {}
    tabList.tabsWithCountdown = {}

    ui = {}
    ui.goldNum = transform:Find("Container/Background/Sidebar/Gold/Num"):GetComponent("UILabel")
    ui.tabList = tabList

    ui.lastUpdateTime = Serclimax.GameTime.GetSecTime()

    UIUtil.SetClickCallback(transform:Find("Mask").gameObject, Hide)
    UIUtil.SetClickCallback(transform:Find("Container/Background/Close Button").gameObject, Hide)
    UIUtil.SetClickCallback(transform:Find("Container/Background/Sidebar/Gold/Recharge Button").gameObject, ShowRechargeTab)

    MoneyListData.AddListener(UpdateExchequer)

    GiftPackData.RequestData()
end

function Update()
    local now = Serclimax.GameTime.GetSecTime()
    if ui.lastUpdateTime ~= now then
        ui.lastUpdateTime = now
        for _, uiTab in ipairs(ui.tabList.tabsWithCountdown) do
            UpdateTabCountdown(uiTab)
        end
    end
end

function Close()
    EventDispatcher.UnbindAll(_M)
    eventHandlers[EventDispatcher.HANDLER_TYPE.INSTANT] = nil
    eventHandlers[EventDispatcher.HANDLER_TYPE.DELAYED] = nil

    MoneyListData.RemoveListener(UpdateExchequer)

    ui = nil
    currentTab = nil
    GiftPackData.Initialize()
end

function Initialize()
    eventHandlers = {}

    for tabID, config in pairs(TableMgr:GetGoldStoreTabConfig()) do
        local templateModule = templates[config.template]
        if templateModule then
            SetNoticeStatus(tabID, templateModule.HasNotice and templateModule.HasNotice(config))

            if templateModule.OnNoticeStatusChange then
                AddEventHandler(templateModule.OnNoticeStatusChange(config), tabID, EventDispatcher.HANDLER_TYPE.STATIC_INSTANT, function()
                    SetNoticeStatus(tabID, templateModule.HasNotice(config))
                    BroadcastEventOnNoticeStatusChange(tabID)
                end)
            end

            SetAvailability(tabID, not templateModule.IsAvailable or templateModule.IsAvailable(config))

            if templateModule.OnAvailabilityChange then
                AddEventHandler(templateModule.OnAvailabilityChange(config), tabID, EventDispatcher.HANDLER_TYPE.STATIC_INSTANT, function()
                    SetAvailability(tabID, templateModule.IsAvailable(config))
                    BroadcastEventOnNoticeStatusChange(tabID)
                end)
            end
        end
    end

    BroadcastEventOnNoticeStatusChange()
end

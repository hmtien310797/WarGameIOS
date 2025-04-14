module("ActivityBulletin", package.seeall)

local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary

----- Data ---------------------------
local activities
local closeCallback

local ui
local isInViewport = false

function IsInViewport()
    return isInViewport
end

local function SetIsInViewport(flag)
    isInViewport = flag
end

local function SetActivities(data)
    activities = data
end

local function SetCloseCallback(func)
    closeCallback = func
end
--------------------------------------

----- Constants --------------
local FUNCTION_ID = 141
local WIDTH_OFFSET_FACTOR = 4
------------------------------

----- Global Flags ------
local TEST_MODE = false
-------------------------

----- Test -------------------------------------------------------------------------
local function MakeTestData()
    local testData = {}

    math.randomseed(os.time())
    for i = 1, 5 do
        local r = math.floor(math.random(1, 100))
        local activity = {}
        activity.templetId = r % 2 == 0 and "banner_gov" or "banner_rebelsiege"
        activity.content1 = r % 2 == 0 and "Government Contention" or "Rebel Siege"
        activity.content2 = string.format("ORDER: %d", r)
        activity.order = r
        table.insert(testData, activity)
    end

    return testData
end
------------------------------------------------------------------------------------
local function UpdateNavigation()
    ui.navigationList.navigations[math.min(#ui.navigationList.navigations, math.floor((math.abs(ui.scrollView.localPosition.x) + ui.activityList.width / WIDTH_OFFSET_FACTOR) / ui.activityList.width) + 1)].toggle.value = true
end

local function LoadUI()
    if DEBUG_MODE then
        Global.LogDebug(_M, "LoadUI")
    end

    if isInViewport and not ui then
        UIUtil.SetClickCallback(transform:Find("container/header/btn_close").gameObject, Hide)

        ui = {}

        ui.title = transform:Find("container/header/title"):GetComponent("UILabel")

        ui.scrollView = transform:Find("container/activityList")

        ui.activityList = {}
        ui.activityList.transform = transform:Find("container/activityList/grid")
        ui.activityList.gameObject = ui.activityList.transform.gameObject
        ui.activityList.grid = ui.activityList.transform:GetComponent("UIGrid")
        ui.activityList.width = ui.activityList.grid.cellWidth
        ui.activityList.newListItem = transform:Find("container/activityList/newActivity").gameObject

        ui.navigationList = {}
        ui.navigationList.transform = transform:Find("container/navigationList")
        ui.navigationList.gameObject = ui.navigationList.transform.gameObject
        ui.navigationList.grid = ui.navigationList.transform:GetComponent("UIGrid")
        ui.navigationList.newListItem = transform:Find("container/newNavigation").gameObject

        ui.scrollView:GetComponent("UIScrollView").onMomentumMove = UpdateNavigation
    end
end

local function SetUI()
    if isInViewport and ui then
        if TEST_MODE then
            ui.title.text = "假数据调试中......"
        end

        ui.activityList.activities = {}
        ui.navigationList.navigations = {}
        for _, activity in ipairs(activities) do
            local uiNavigation = {}
            uiNavigation.gameObject = NGUITools.AddChild(ui.navigationList.gameObject, ui.navigationList.newListItem)
            uiNavigation.transform = uiNavigation.gameObject.transform
            uiNavigation.toggle = uiNavigation.transform:GetComponent("UIToggle")
            table.insert(ui.navigationList.navigations, uiNavigation)

            local uiActivity = {}
            uiActivity.gameObject = NGUITools.AddChild(ui.activityList.gameObject, ui.activityList.newListItem)
            uiActivity.transform = uiActivity.gameObject.transform
            uiActivity.image = uiActivity.transform:Find("image"):GetComponent("UITexture")
            uiActivity.title = uiActivity.transform:Find("title"):GetComponent("UILabel")
            uiActivity.description = uiActivity.transform:Find("description"):GetComponent("UILabel")
            uiActivity.btn_go = uiActivity.transform:Find("buttonGo").gameObject
            uiActivity.navigation = uiNavigation

            UIUtil.SetClickCallback(uiActivity.btn_go, function()
                Global.GetTableFunction(activity.go)()
            end)

            table.insert(ui.activityList.activities, uiActivity)

            uiActivity.image.mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", activity.templetId)
            uiActivity.title.text = TEST_MODE and activity.content1 or TextMgr:GetText(activity.content1)
            uiActivity.description.text = TEST_MODE and activity.content2 or TextMgr:GetText(activity.content2)
            uiActivity.gameObject.name = 1000 + activity.order
            uiActivity.btn_go:SetActive(not System.String.IsNullOrEmpty(activity.go))

            uiActivity.gameObject:SetActive(true)
            uiNavigation.gameObject:SetActive(true)
        end
        ui.activityList.grid:Reposition()
        ui.navigationList.grid:Reposition()
    end

    UpdateNavigation()
end

local function UpdateUI()
end

local function Draw()
    LoadUI()
    SetUI()
    UpdateUI()
end

function Hide()
    Global.CloseUI(_M)
end

function Show(closeCallback)
    if not isInViewport then
        if TEST_MODE then
            SetActivities(MakeTestData())
            SetCloseCallback(closeCallback)
            Global.OpenUI(_M)
        else
            local request = ActivityMsg_pb.MsgActBulletinGetRequest()
            Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgActBulletinGetRequest, request, ActivityMsg_pb.MsgActBulletinGetResponse, function(msg)
                FunctionListData.IsFunctionUnlocked(FUNCTION_ID, function(isUnlocked)
                    if isUnlocked then
                        if #msg.bulletinInfos ~= 0 then
                            SetActivities(msg.bulletinInfos or {})
                            SetCloseCallback(closeCallback)
                            Global.OpenUI(_M)
                        else
                            if closeCallback ~= nil then
                                closeCallback()
                            end
                            Global.LogDebug(_M, "Show", "Nothing to be shown.")
                        end
                    else
                        if closeCallback ~= nil then
                            closeCallback()
                        end

                        Global.LogDebug(_M, "Show", string.format("Function is not unlocked. (id = %d)", FUNCTION_ID))
                    end
                end)
            end, true)
        end

        return true
    end
    if closeCallback ~= nil then
        closeCallback()
    end

    Global.LogDebug(_M, "Show", "The window is already in the viewport.")
    
    return false
end

function Start()
    SetIsInViewport(true)

    Draw()
end

function Close()
    SetIsInViewport(false)

    if closeCallback then
        closeCallback()
    end

    SetActivities()
    SetCloseCallback()

    ui = nil
end

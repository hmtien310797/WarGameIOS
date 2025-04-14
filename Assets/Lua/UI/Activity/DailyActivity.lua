module("DailyActivity", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local GameObject = UnityEngine.GameObject
local SetClickCallback = UIUtil.SetClickCallback
local SetTooltipCallback = UIUtil.SetTooltipCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime

local _ui, InitActivityList
local lastSelectTemplate = 0

local TestUserActivityInfoData =
{
    activity =
    {
 
        [1] = 
        {
            endTime = 3509656400,
            activityId = 1004,
            name = "activity_content_36",
            icon = "act_icon_base",
            leftCount = 5,
            countMax = 5,
            countid = 0,
            actskip = "",
            order = 6000,
            state = 1,
            templet = 102,
        },
        [2] = 
        {
            endTime = 1512316800,
            activityId = 1005,
            name = "activity_content_39",
            icon = "act_icon_union",
            leftCount = 5,
            countMax = 5,
            countid = 0,
            actskip = "",
            order = 5000,
            state = 1,
            templet = 102,
        },
        [3] = 
        {
            endTime = 1512057600,
            activityId = 1006,
            name = "activity_content_40",
            icon = "act_icon_speedup",
            leftCount = 5,
            countMax = 5,
            countid = 0,
            actskip = "",
            order = 4000,
            state = 1,
            templet = 102,
        },
		[4] = 
        {
            endTime = 1512057600,
            activityId = 1001,
            name = "activity_content_1",
            icon = "act_icon_king",
            leftCount = 5,
            countMax = 5,
            countid = 0,
            actskip = "",
            order = 9000,
            state = 1,
            templet = 101,
        },
		[5] = 
        {
            endTime = 1512057600,
            activityId = 1003,
            name = "activity_supplycollect_title",
            icon = "act_icon_junbei",
            leftCount = 5,
            countMax = 5,
            countid = 0,
            actskip = "",
            order = 7000,
            state = 1,
            templet = 103,
        },
    },
}




local function InitTemplete()
    templet = 
    {
        [101] = KingsRoad,
        [102] = DailyActivity_Template1,
        [103] = SupplyCollect,
        [104] = DailyActivity_Share,
        [111] = DailyActivity_Worldcup,
        [112] = HolidayActivity,
        [140] = LevelRace,
        [151] = SevenDay,
        [152] = ThirtyDay,
        [153] = PVP_LuckyRotary,
		[113] = Christmas,
    }
end

local redpointList = {}
local function SetRedPoint()
	local isNew = DailyActivityData.GetIsNew()
	local red = DailyActivityData.GetRedpoints()
	for i, v in pairs(redpointList) do
		if red[i] ~= nil then
			print("SetRedPointSetRedPointSetRedPointSetRedPoint : " , i , isNew[i] , red[i])
			v:SetActive(isNew[i] or red[i])
		end
	end
end

local function CloseTabs()
	for i, v in pairs(templet) do
		v.CloseSelf()
	end
end

function CloseSelf()
	CloseTabs()
    Global.CloseUI(_M)
end

function Close()
    CloseTabs()
	_ui = nil
	redpointList = {}
	DailyActivityData.RemoveListener(SetRedPoint)
end

function SelectActivity(activity)
    if lastSelectTemplate ~= activity.templet and activity.templet ~= 104 then
        CloseTabs()
    end
    print("activity.templet : ", activity.templet , templet[activity.templet] )
    if templet[activity.templet] ~= nil then

        if activity.templet ~= 104 then
            templet[activity.templet].Show(activity , lastSelectTemplate == activity.templet)
        else
            local req = ClientMsg_pb.MsgUserRankListRequest()
            req.rankType = 1
            Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserRankListRequest, req, ClientMsg_pb.MsgUserRankListResponse, function(msg)
                if GUIMgr:IsMenuOpen("DailyActivity") then
                    if msg.code == ReturnCode_pb.Code_OK then
                        CloseTabs()
                        DailyActivity_Share.Show(msg.myRank.rank)
                        GUIMgr:BringForward(gameObject)
                    else
                        Global.ShowError(msg.code)
                    end
                end
            end, false)
        end
    end

    if lastSelectTemplate ~= activity.templet or 
        activity.templet == 112 or
        activity.templet == 151 or
        activity.templet == 152 or
        activity.templet == 153 then
        GUIMgr:BringForward(gameObject)
    end
    lastSelectTemplate = activity.templet
end

function Show(activityId)
	Global.OpenUI(_M)
	_ui.selectedActivityId = activityId
end

function RemoveWeeklyShare()
    if _ui ~= nil then
        if _ui.btnList[104] ~= nil then
            GameObject.Destroy(_ui.btnList[104].gameObject)
            DailyActivity_Share.CloseSelf()
            if _ui.grid.transform.childCount > 0 then
                UICamera.Notify(_ui.grid.transform:GetChild(0).gameObject, "OnClick", nil)
            end
        end
    end
end

function Awake()
	if _ui == nil then
        _ui = {}
        InitTemplete()
	end
	_ui.btn_close = transform:Find("Container/close btn").gameObject
	_ui.scorll = transform:Find("Container/top/Scroll View"):GetComponent("UIScrollView")
	_ui.grid = transform:Find("Container/top/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.item = transform:Find("Container/top/Scroll View/Grid/top_1")
	
	lastSelectTemplate = 0
	DailyActivityData.AddListener(SetRedPoint)
end

function Start()
	MissionListData.RequestData()
	_ui.activitys = {}
	for _, v in ipairs(DailyActivityData.GetActivitys()) do
	    table.insert(_ui.activitys, v)
    end
    if MainData.HasWeeklyShare() then
        table.insert(_ui.activitys,
        {
            endTime = 1512057600,
            activityId = 0,
            name = "Target_ui6",
            icon = "icon_share",
            leftCount = 5,
            countMax = 5,
            countid = 0,
            actskip = "",
            order = 7000,
            state = 1,
            templet = 104,
        })
    end
	SetClickCallback(_ui.btn_close, CloseSelf)
	local childcount = _ui.grid.transform.childCount
	local index = 0
	_ui.btnList = {}
	for i, v in ipairs(_ui.activitys) do
        index = index + 1
		local btn
		if index <= childcount then
			btn = _ui.grid.transform:GetChild(index - 1)
		else
			btn = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject).transform
		end
		SetClickCallback(btn.gameObject, function()
		    SelectActivity(v)
		end)

		btn:Find("name"):GetComponent("UILabel").text = TextMgr:GetText(v.name)
		btn:Find("selected effect/name01"):GetComponent("UILabel").text = TextMgr:GetText(v.name)
		btn:Find("Sprite"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon ("Icon/Activity/", v.icon)
		btn:Find("selected effect/Sprite"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon ("Icon/Activity/", v.icon)
		
		print(v.activityId)
		redpointList[v.activityId] = btn:Find("red_dian").gameObject

		if _ui.selectedActivityId == nil and index == 1 and templet[v.templet] ~= nil then
			btn:GetComponent("UIToggle"):Set(true)
			lastSelectTemplate = v.templet
			templet[v.templet].Show(v)
			GUIMgr:BringForward(gameObject)
		end
        if v.templet == 104 then
            btn:Find("red_dian").gameObject:SetActive(false)
        end
        _ui.btnList[v.templet] = btn
	end

	for i = index + 1, childcount do
		GameObject.Destroy(_ui.grid.transform:GetChild(index).gameObject)
	end
	_ui.grid:Reposition()
	SetRedPoint()
	if _ui.selectedActivityId ~= nil then
        for i, v in ipairs(_ui.activitys) do
            if v.activityId == _ui.selectedActivityId then
                UICamera.Notify(_ui.grid.transform:GetChild(i - 1).gameObject, "OnClick", nil)
                break
            end
        end
    end
end

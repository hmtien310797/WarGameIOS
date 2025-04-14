module("Rebate_LuckyRotary", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local Format = System.String.Format
local SetClickCallback = UIUtil.SetClickCallback

local minFrame = 1
local maxFrame = 10
local frameStep = 1

local _ui
local timer = 0

local data
function RequestData()
    local req = ActivityMsg_pb.MsgGoldLotteryGetInfoRequest()
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgGoldLotteryGetInfoRequest, req, ActivityMsg_pb.MsgGoldLotteryGetInfoResponse, function(msg)
        Global.DumpMessage(msg, "d:/ddddd.lua")
        if msg.code ~= ReturnCode_pb.Code_OK then
            --Global.FloatError(msg.code)
        else
            data = msg
            local activityId = ActivityData.GetActivityIdByTemplete(314)
            WelfareData.UpdateUncollectedRewards(activityId)
            MainCityUI.UpdateWelfareNotice(activityId)
            if _ui ~= nil then
                LoadUI()
            end
        end
    end)
end

function HasUnclaimedAward(activityID)
    if not activityID or not data then
        return false
    end
    return (data.count > 0) and (data.totalPayNum >= data.needPayNum)
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
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

local function SecondUpdate()
    if _ui then
        if ActivityData.GetActivityConfig(_ui.activity.activityId).endTime < Serclimax.GameTime.GetSecTime() then
            WelfareAll.Hide()
        end
        _ui.cooldownLabel.text = Format(TextMgr:GetText("activity_content_119"), Global.GetLeftCooldownTextLong(ActivityData.GetActivityConfig(_ui.activity.activityId).endTime))
    end
end

function LoadUI()
    if _ui == nil or data == nil then
        return
    end

    _ui.lock:SetActive(data.totalPayNum < data.needPayNum)
    _ui.unlock:SetActive(data.totalPayNum >= data.needPayNum and data.count > 0)
    _ui.finish:SetActive(data.totalPayNum >= data.needPayNum and data.count == 0)

    for i, v in ipairs(_ui.packageList) do
        v.num.text = data.rewards[i].items[1].num
    end

    _ui.lock_text.text = Format(TextMgr:GetText("activity_content_118"), data.totalPayNum, data.needPayNum)
    _ui.unlock_num.text = data.cost
    _ui.leftcountLabel.text = Format(TextMgr:GetText("activity_content_120"), data.count)

    SetClickCallback(_ui.rewardButton.gameObject, function(go)
        if data.totalPayNum >= data.needPayNum then
            local req = ActivityMsg_pb.MsgGoldLotteryDrawRequest()
            Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgGoldLotteryDrawRequest, req, ActivityMsg_pb.MsgGoldLotteryDrawResponse, function(msg)
                Global.DumpMessage(msg, "d:/ddddd.lua")
                if msg.code ~= ReturnCode_pb.Code_OK then
                    Global.FloatError(msg.code)
                else
                    MainCityUI.UpdateRewardData(msg.fresh)
                    if _ui ~= nil then
                        Global.DisableUI()
                        _ui.rewardCoroutine = coroutine.start(function()
                            local priceListIndex = 1
                            local frame = minFrame
                            repeat
                                local priceIndex = priceListIndex % #_ui.packageList + 1
                                for i, v in ipairs(_ui.packageList) do
                                    v.selectObject:SetActive(i == priceIndex)
                                end
                                coroutine.step(frame)
                                priceListIndex = priceListIndex + 1
                                frame = frame + frameStep
                            until frame >= maxFrame and priceIndex == msg.result + 1
                            coroutine.wait(0.5)
                            ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
                            ItemListShowNew.SetItemShow(msg)
                            ItemListShowNew.SetCloseMenuCallback(LoadUI)
                            GUIMgr:CreateMenu("ItemListShowNew" , false)
                            data = msg
                            local activityId = ActivityData.GetActivityIdByTemplete(314)
                            WelfareData.UpdateUncollectedRewards(activityId)
                            MainCityUI.UpdateWelfareNotice(activityId)
                            Global.EnableUI()
                        end)
                    end
                end
            end)
        else
            MessageBox.Show(TextMgr:GetText("activity_content_122"), function() Goldstore.ShowRechargeTab() end, function() end, TextMgr:GetText("common_ui10"))
        end
    end)
    
    SecondUpdate()
end

function Refresh()
    LoadUI()
end

function Awake()
    local mask = transform:Find("mask")
    SetClickCallback(mask.gameObject, WelfareAll.Hide)

    _ui.lock = transform:Find("Container/bg_frane/rotary/mid_button/lock").gameObject
    _ui.lock_text = transform:Find("Container/bg_frane/rotary/mid_button/lock/text"):GetComponent("UILabel")
    _ui.unlock = transform:Find("Container/bg_frane/rotary/mid_button/unlock").gameObject
    _ui.unlock_num = transform:Find("Container/bg_frane/rotary/mid_button/unlock/num"):GetComponent("UILabel")
    _ui.finish = transform:Find("Container/bg_frane/rotary/mid_button/text_complete").gameObject

    local packageList = {}
    for i = 1, 5 do
        local package = {}
        package.iconTexture = transform:Find(string.format("Container/bg_frane/rotary/Texture%d/Textureclosed", i)):GetComponent("UITexture")
        package.num = transform:Find(string.format("Container/bg_frane/rotary/Texture%d/Textureclosed/num", i)):GetComponent("UILabel")
        package.selectObject = transform:Find(string.format("Container/bg_frane/rotary/select%d", i)).gameObject
        transform:Find(string.format("Container/bg_frane/rotary/Texture%d", i)):GetComponent("Animator").enabled = false
        packageList[i] = package
    end
    _ui.packageList = packageList

    _ui.rewardButton = transform:Find("Container/bg_frane/rotary/mid_button"):GetComponent("UIButton")

    _ui.cooldownLabel = transform:Find("Container/bg_frane/right/top/Label"):GetComponent("UILabel")
    _ui.leftcountLabel = transform:Find("Container/bg_frane/right/top/text_num"):GetComponent("UILabel")
    _ui.timer = Timer.New(SecondUpdate, 1, -1)
    _ui.timer:Start()

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()
    LoadUI()
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
    _ui.timer:Stop()
    coroutine.stop(_ui.rewardCoroutine)
    Global.EnableUI()
    isInView = false
    _ui = nil
end

function Show(activityId,templet)
	if activityId == nil or templet == nil then
		print("############### Activity is null ###############")
		return
	end
	if _ui == nil then
		_ui = {}
	end
	if _ui.activity == nil then
		_ui.activity = {}
	else
		if _ui.activity.activityId == activityId and _ui.activity.templet == templet then
			return
		end
	end
	_ui.activity.activityId = activityId
	_ui.activity.templet = templet
	
    if isInView then
        LoadUI()
    else
        Global.OpenUI(_M)
        isInView = true
        RequestData()
    end
	print(_ui.activity.activityId, _ui.activity.templet)
end
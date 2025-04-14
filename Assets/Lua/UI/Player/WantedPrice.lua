module("WantedPrice", package.seeall)
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

local repeatDelay = 0.5
local repeatInterval = 0.1
local repeatTimer = 0
local _ui
local moneyTypeList =
{
    Common_pb.MoneyType_Food,
    Common_pb.MoneyType_Iron,
    Common_pb.MoneyType_Oil,
    Common_pb.MoneyType_Elec,
}

local moneyIndexList = {}
for i, v in ipairs(moneyTypeList) do
    moneyIndexList[v] = i
end

function Hide()
    Global.CloseUI(_M)
end

local function LoadMoney(moneyIndex, setSlider)
    local moneyType = moneyTypeList[moneyIndex]
    local money = _ui.moneyList[moneyIndex]
    local currentMoney = _ui.setReq.addReward[moneyIndex].value
    local totalMoney = MoneyListData.GetMoneyByType(moneyType)
    money.numberLabel.text = string.format("%s/%s", Global.ExchangeValue(currentMoney), Global.ExchangeValue(totalMoney))
    local moneyPercent = 0
    if totalMoney > 0 then
        moneyPercent = currentMoney / totalMoney
    end
    money.slider.value = moneyPercent
    local currentTotalMoney = 0
    for _, v in ipairs(_ui.setReq.addReward) do
        currentTotalMoney = currentTotalMoney + v.value
    end
    local moneyText
    if currentTotalMoney < _ui.minMoney then
        moneyText = string.format("[FF0000]%d[-]", currentTotalMoney)
    else
        moneyText = currentTotalMoney
    end
    _ui.minLabel.text = Format(TextMgr:GetText(Text.jail_39), _ui.minMoney, moneyText)
end

local function GetStep(total)
    if total <= 1000 then
        return 1
    elseif total < 1000000 then
        return 100
    elseif total < 1000000000 then
        return 100000
    else
        return 100000000
    end
end

local function ReduceMoney(moneyIndex)
    local money = _ui.setReq.addReward[moneyIndex].value
    if money > 0 then
        local moneyType = moneyTypeList[moneyIndex]
        local totalMoney = MoneyListData.GetMoneyByType(moneyType)
        local step = GetStep(totalMoney)
        _ui.setReq.addReward[moneyIndex].value = math.max(money - step, 0)
        LoadMoney(moneyIndex, true)
    end
end

local function AddMoney(moneyIndex)
    local money = _ui.setReq.addReward[moneyIndex].value
    local moneyType = moneyTypeList[moneyIndex]
    local totalMoney = MoneyListData.GetMoneyByType(moneyType)
    if money < totalMoney then
        local step = GetStep(totalMoney)
        _ui.setReq.addReward[moneyIndex].value = math.min(money + step, totalMoney)
        LoadMoney(moneyIndex, true)
    end
end

function LoadUI()
    local level = MainData.GetLevel()
    local jailInfoData = TableMgr:GetJailInfoDataByLevel(level)
    _ui.minMoney = level * jailInfoData.ransomcoef

    for i, v in ipairs(_ui.moneyList) do
        SetClickCallback(v.numberLabel.gameObject, function(go)
            local moneyType = moneyTypeList[i]
            local maxReward = MoneyListData.GetMoneyByType(moneyType)
            NumberInput.Show(_ui.setReq.addReward[i].value, 0, maxReward, function(number)
                _ui.setReq.addReward[i].value = number
                LoadMoney(i, true)
            end)
        end)
        EventDelegate.Set(v.slider.onChange, EventDelegate.Callback(function(go)
            local moneyType = moneyTypeList[i]
            local maxReward = MoneyListData.GetMoneyByType(moneyType)
            _ui.setReq.addReward[i].value = Mathf.Round(maxReward * v.slider.value)
            LoadMoney(i, false)
        end))
        UIUtil.SetClickCallback(v.minusButton.gameObject, function(go)
            ReduceMoney(i)
        end)
        UIUtil.SetClickCallback(v.addButton.gameObject, function(go)
            AddMoney(i)
        end)
        UIUtil.SetPressCallback(v.minusButton.gameObject, function(go, isPressed)
            repeatTimer = isPressed and repeatDelay or 0
        end)
        UIUtil.SetPressCallback(v.addButton.gameObject, function(go, isPressed)
            repeatTimer = isPressed and repeatDelay or 0
        end)
        LoadMoney(i, true)
    end
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("payransom/bg_frane/bg_top/btn_close")
    local cancelButton = transform:Find("payransom/bg_frane/btn_cancel")
    local confirmButton = transform:Find("payransom/bg_frane/btn_dissolution"):GetComponent("UIButton")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(cancelButton.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)
    UIUtil.SetClickCallback(confirmButton.gameObject, function()
        local totalMoney = 0
        for _, v in ipairs(_ui.setReq.addReward) do
            totalMoney = totalMoney + v.value
        end
        if totalMoney < _ui.minMoney then
            FloatText.Show(TextMgr:GetText(Text.Code_Prison_Offer_Exceed_Min))
            return
        end
        if _ui.callback ~= nil then
            _ui.callback(_ui.setReq)
        end
        Hide()
    end)

    local moneyList = {}
    for i = 1, 4 do
        local moneyTransform = transform:Find(string.format("payransom/bg_frane/bg_mid/bg_resource_time (%d)", i))
        local money = {}
        money.transform = moneyTransform
        money.gameObject = moneyTransform.gameObject
        money.slider = moneyTransform:Find("bg_schedule/bg_slider"):GetComponent("UISlider")
        money.numberLabel = moneyTransform:Find("text_num"):GetComponent("UILabel")
        money.minusButton = moneyTransform:Find("btn_minus"):GetComponent("UIButton")
        money.addButton = moneyTransform:Find("btn_add"):GetComponent("UIButton")
        moneyList[i] = money
    end
    _ui.moneyList = moneyList
    _ui.minLabel = transform:Find("payransom/bg_frane/min"):GetComponent("UILabel")
end

function Start()
    LoadUI()
end

function LateUpdate()
    local deltaTime = GameTime.deltaTime
    if repeatTimer > 0 then
        repeatTimer = repeatTimer - deltaTime
        if repeatTimer <= 0 then
            repeatTimer = repeatTimer + repeatInterval
            for i, v in ipairs(_ui.moneyList) do
                if UICamera.IsPressed(v.minusButton.gameObject) then
                    ReduceMoney(i)
                elseif UICamera.IsPressed(v.addButton.gameObject) then
                    AddMoney(i)
                end
            end
        end
    end
end

function Close()
    _ui = nil
end

function Show(setReq, callback)
    Global.OpenUI(_M)
	_ui.setReq = BuildMsg_pb.MsgPrisonSetRewardRequest()
	_ui.callback = callback
	for i = 1, 4 do
	    local reqReward = _ui.setReq.addReward:add()
	    reqReward.id = moneyTypeList[i] 
	    reqReward.value = setReq.addReward[i].value
    end
end

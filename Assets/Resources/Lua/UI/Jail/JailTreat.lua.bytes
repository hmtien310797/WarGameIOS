module("JailTreat", package.seeall)
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
local repeatStep = 10

local _ui
local timer = 0

local moneyTypeList =
{
    Common_pb.MoneyType_Food,
    Common_pb.MoneyType_Iron,
    Common_pb.MoneyType_Oil,
    Common_pb.MoneyType_Elec,
}

function Hide()
    Global.CloseUI(_M)
end

local function UpdateTime()
    _ui.prisoner.timeLabel.text = Global.GetLeftCooldownTextLong(_ui.prisoner.msg.freeTime)
end

local function LoadRansom(setSlider)
    local totalRansom = 0
    for i, v in ipairs(_ui.moneyList) do
        local ransom = _ui.setReq.ransom[i].value
        v.numberLabel.text = ransom 
        v.numberLabel2.text = ransom 
        totalRansom = totalRansom + ransom
        if setSlider then
            v.slider.value = ransom / _ui.maxRansom 
        end
    end
    --_ui.totalLabel.text = string.format("[F1CF63]%s[-]/%s", Global.FormatNumber(totalRansom), Global.FormatNumber(_ui.maxRansom))
	_ui.totalLabel.text = System.String.Format(TextMgr:GetText("jail_22") , Global.FormatNumber(totalRansom), Global.FormatNumber(_ui.maxRansom) )
end

local function ReduceMoney(ransomIndex, step)
    local ransom = _ui.setReq.ransom[ransomIndex].value
    if ransom > 0 then
        _ui.setReq.ransom[ransomIndex].value = math.max(ransom - step, 0)
        LoadRansom(true)
    end
end

local function AddMoney(ransomIndex, step)
    local ransom = _ui.setReq.ransom[ransomIndex].value
    local leftRansom = _ui.maxRansom
    for ii, vv in ipairs(_ui.setReq.ransom) do
        if ii ~= ransomIndex then
            leftRansom = leftRansom - vv.value
        end
    end
    if ransom < leftRansom then
        _ui.setReq.ransom[ransomIndex].value = math.min(ransom + step, leftRansom)
        LoadRansom(true)
    end
end

function LoadUI()
    local prisonerMsg = _ui.prisonerMsg
    _ui.setReq = BuildMsg_pb.MsgPrisonSetRansomRequest()
    _ui.setReq.ownerId = _ui.prisonerMsg.info.id

    local totalRansom = 0
    for i = 1, 4 do
        local reqRansom = _ui.setReq.ransom:add()
        local moneyType = moneyTypeList[i]
        reqRansom.id = moneyType
        local money = JailInfoData.GetMoneyByType(prisonerMsg.ransom, moneyType)
        reqRansom.value = money
        totalRansom = totalRansom + money
    end

    local canChange = prisonerMsg.ransomRefuse or totalRansom == 0
    _ui.moneyObject:SetActive(canChange)
    _ui.moneyObject2:SetActive(not canChange)
    JailInfo.LoadPrisoner(_ui.prisoner, prisonerMsg, _ui.prisonerData)
    local jailInfoData = TableMgr:GetJailInfoDataByLevel(prisonerMsg.info.level)
    _ui.maxRansom = prisonerMsg.info.level * jailInfoData.ransomcoef
    for i, v in ipairs(_ui.moneyList) do
        EventDelegate.Set(v.slider.onChange, EventDelegate.Callback(function(go)
            _ui.setReq.ransom[i].value = Mathf.Round(_ui.maxRansom * v.slider.value)
            LoadRansom(false)
        end))
        UIUtil.SetClickCallback(v.numberLabel.gameObject, function(go)
            local leftRansom = _ui.maxRansom
            for ii, vv in ipairs(_ui.setReq.ransom) do
                if ii ~= i then
                    leftRansom = leftRansom - vv.value
                end
            end
            NumberInput.Show(_ui.setReq.ransom[i].value, 0, leftRansom, function(number)
                _ui.setReq.ransom[i].value = number
                LoadRansom(true)
            end)
        end)
        UIUtil.SetDelegate(v.slider, "onDragFinished", function(go)
            local leftRansom = _ui.maxRansom
            for ii, vv in ipairs(_ui.setReq.ransom) do
                if ii ~= i then
                    leftRansom = leftRansom - vv.value
                end
            end
            _ui.setReq.ransom[i].value = math.min(_ui.setReq.ransom[i].value, leftRansom)
            LoadRansom(true)
        end)
        UIUtil.SetClickCallback(v.minusButton.gameObject, function(go)
            ReduceMoney(i, 1)
        end)
        UIUtil.SetClickCallback(v.addButton.gameObject, function(go)
            AddMoney(i, 1)
        end)
        UIUtil.SetPressCallback(v.minusButton.gameObject, function(go, isPressed)
            repeatTimer = isPressed and repeatDelay or 0
        end)
        UIUtil.SetPressCallback(v.addButton.gameObject, function(go, isPressed)
            repeatTimer = isPressed and repeatDelay or 0
        end)
    end
    local pos = prisonerMsg.pos
    _ui.prisoner.coordLabel.text = string.format("X:%dY:%d", pos.x, pos.y)
    SetClickCallback(_ui.prisoner.coordLabel.gameObject, function(go)
        JailInfo.CloseAll()
        MainCityUI.ShowWorldMap(pos.x, pos.y, true)
    end)
    _ui.refuseObject:SetActive(prisonerMsg.ransomRefuse)

    UIUtil.SetBtnEnable(_ui.setButton, "btn_1", "btn_4", canChange)
    local setText
    if totalRansom == 0 then

        setText = Text.jail_8
    elseif prisonerMsg.ransomRefuse then
        setText = Text.jail_10
    else
        setText = Text.jail_9
    end
    _ui.setLabel.text = TextMgr:GetText(setText)
    SetClickCallback(_ui.setButton.gameObject, function(go)
        local totalSetValue = 0
        for _, v in ipairs(_ui.setReq.ransom) do
            totalSetValue = totalSetValue + v.value
        end
        if totalSetValue < tonumber(tableData_tGlobal.data[153].value) then
            FloatText.Show(TextMgr:GetText(Text.jail_41))
            return
        end

        if totalRansom == 0 or prisonerMsg.ransomRefuse then
            MessageBox.Show(TextMgr:GetText(Text.jail_29), function()
                local req = _ui.setReq
                Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgPrisonSetRansomRequest, req, BuildMsg_pb.MsgPrisonSetRansomResponse, function(msg)
                    if msg.code == ReturnCode_pb.Code_OK then
                        JailInfoData.UpdatePrionserData(msg.prisoner)
                        _ui.prisonerMsg = msg.prisoner
                        LoadUI()
                    else
                        Global.ShowError(msg.code)
                    end
                end, true)
            end,
            function()
            end)
        else
            FloatText.Show(TextMgr:GetText(Text.jail_30))
        end
    end)
    LoadRansom(true)
    UpdateTime()
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)
    local prisonerTransform = transform:Find("Container/bg_frane/Container/prisoner")
    _ui.prisoner = {}
    JailInfo.LoadPrisonerObject(_ui.prisoner, prisonerTransform)
    _ui.prisoner.coordLabel = prisonerTransform:Find("coordinate"):GetComponent("UILabel")
    _ui.totalLabel = transform:Find("Container/bg_frane/Container/ransom/total/Label"):GetComponent("UILabel")
    _ui.setButton = transform:Find("Container/bg_frane/Container/ransom/set"):GetComponent("UIButton")
    _ui.setLabel = transform:Find("Container/bg_frane/Container/ransom/set/Label"):GetComponent("UILabel")
    _ui.letterButton = transform:Find("Container/bg_frane/Container/more/Letter"):GetComponent("UIButton")
    _ui.releaseButton = transform:Find("Container/bg_frane/Container/more/release"):GetComponent("UIButton")
    _ui.refuseObject = transform:Find("Container/bg_frane/Container/ransom/denied").gameObject
	SetClickCallback(_ui.letterButton.gameObject, function()
        Mail.SimpleWriteTo(_ui.prisonerMsg.info.name)
    end)
    SetClickCallback(_ui.releaseButton.gameObject, function(go)
        MessageBox.Show(Format(TextMgr:GetText(Text.ui_jail_release_1), _ui.prisonerMsg.info.name), function()
            local req = BuildMsg_pb.MsgPrisonPardonRequest()
            req.ownerId = _ui.prisonerMsg.info.id
            Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgPrisonPardonRequest, req, BuildMsg_pb.MsgPrisonPardonResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    FloatText.Show(TextMgr:GetText(Text.jail_28))
                    Hide()
                else
                    Global.ShowError(msg.code)
                end
            end, true)
        end,
        function()
        end)
    end)
    _ui.moneyObject = transform:Find("Container/bg_frane/Container/ransom/setting").gameObject
    _ui.moneyObject2 = transform:Find("Container/bg_frane/Container/ransom/setting2").gameObject
    local moneyList = {}
    for i = 1, 4 do
        local moneyTransform = transform:Find(string.format("Container/bg_frane/Container/ransom/setting/bg_resource_time (%d)", i))
        local moneyTransform2 = transform:Find(string.format("Container/bg_frane/Container/ransom/setting2/bg_resource_time (%d)", i))
        local money = {}
        money.transform = moneyTransform
        money.gameObject = moneyTransform.gameObject
        money.slider = moneyTransform:Find("bg_schedule/bg_slider"):GetComponent("UISlider")
        money.numberLabel = moneyTransform:Find("text_num"):GetComponent("UILabel")
        money.minusButton = moneyTransform:Find("btn_minus"):GetComponent("UIButton")
        money.addButton = moneyTransform:Find("btn_add"):GetComponent("UIButton")
        money.numberLabel2 = moneyTransform2:Find("text_num"):GetComponent("UILabel")
        money.type = moneyTypeList[i]
        moneyList[i] = money
    end
    _ui.moneyList = moneyList
end

function Start()
    LoadUI()
end

function LateUpdate()
    local deltaTime = GameTime.deltaTime
    if timer >= 0 then
        timer = timer - deltaTime
        if timer < 0 then
            timer = 1
            UpdateTime()
        end
    end

    if repeatTimer > 0 then
        repeatTimer = repeatTimer - deltaTime
        if repeatTimer <= 0 then
            repeatTimer = repeatTimer + repeatInterval
            for i, v in ipairs(_ui.moneyList) do
                if UICamera.IsPressed(v.minusButton.gameObject) then
                    ReduceMoney(i, repeatStep)
                elseif UICamera.IsPressed(v.addButton.gameObject) then
                    AddMoney(i, repeatStep)
                end
            end
        end
    end
end

function Close()
    _ui = nil
end

function Show(prisonerMsg, prisonerData)
    Global.OpenUI(_M)
    _ui.prisonerMsg = prisonerMsg
    _ui.prisonerData = prisonerData
end

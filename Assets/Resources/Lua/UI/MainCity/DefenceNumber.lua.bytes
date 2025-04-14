module("DefenceNumber", package.seeall)
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

local _ui

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function LoadUI()
    local buildingLevel = maincity.GetBuildingByID(26).data.level
    _ui.repairInterval = tonumber(tableData_tGlobal.data[100220].value)
    _ui.goldLabel.text = tableData_tGlobal.data[100221].value
    local wallData = tableData_tWallData.data[buildingLevel]
    _ui.maxDefense = wallData.WallDefence
    _ui.defenseMsg = DefenseData.GetData().cginfo
    _ui.defenseSlider.value = _ui.defenseMsg.culval / _ui.maxDefense
    _ui.defenseLabel.text = string.format("%d/%d", _ui.defenseMsg.culval, _ui.maxDefense)
    _ui.burningObject:SetActive(_ui.defenseMsg.fireing)
    _ui.burningEffectObject:SetActive(_ui.defenseMsg.fireing)
    SetClickCallback(_ui.extinguishButton.gameObject, function(go)
        local req = ClientMsg_pb.MsgOutFireRequest()
        Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgOutFireRequest, req, ClientMsg_pb.MsgOutFireResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                MainCityUI.UpdateRewardData(msg.refresh)
                DefenseData.UpdateDefenseData(msg.cginfo)
            else
                Global.ShowError(msg.code)
            end
        end, true)
    end)
    SetClickCallback(_ui.repairButton.gameObject, function(go)
        local serverTime = GameTime.GetSecTime()
        if serverTime < _ui.defenseMsg.lastRepairTime + _ui.repairInterval then
            FloatText.Show(TextMgr:GetText(Text.DefenceNumber_12))
        else
            local req = ClientMsg_pb.RepairCityGuardRequest()
            Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.RepairCityGuardRequest, req, ClientMsg_pb.RepairCityGuardResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    DefenseData.UpdateDefenseData(msg.cginfo)
                else
                    Global.ShowError(msg.code)
                end
            end, true)
        end
    end)
end

function LateUpdate()
    local defenseMsg = _ui.defenseMsg

    local serverTime = GameTime.GetSecTime()
    if defenseMsg.fireing and serverTime < defenseMsg.fireEndTime then
        local curDefense = math.max(1, math.floor(defenseMsg.culval - (serverTime - defenseMsg.cultime) * defenseMsg.damage))
        _ui.defenseSlider.value = curDefense / _ui.maxDefense
        _ui.defenseLabel.text = string.format("%d/%d", curDefense, _ui.maxDefense)
    end

    if _ui.timer <= 0 then
        if defenseMsg.fireing then
            _ui.burningLabel.text = Format(TextMgr:GetText(Text.DefenceNumber_4), Global.GetLeftCooldownTextLong(defenseMsg.fireEndTime))
        end

        local needRepair = not defenseMsg.fireing and defenseMsg.culval < _ui.maxDefense
        _ui.repairObject.gameObject:SetActive(needRepair)

        local text, leftSecond = Global.GetLeftCooldownTextLong(defenseMsg.lastRepairTime + _ui.repairInterval)
        _ui.repairLabel.text = Format(TextMgr:GetText(Text.DefenceNumber_11), text) 
        _ui.repairLabel.gameObject:SetActive(leftSecond > 0)
        UIUtil.SetBtnEnable(_ui.repairButton, "btn_1", "btn_4", leftSecond <= 0)
        _ui.timer = _ui.timer + 1
    end
    _ui.timer = _ui.timer - Time.deltaTime
end

function Awake()
    _ui = {}
    _ui.timer = 0
    _ui.prisonerPrefab = ResourceLibrary.GetUIPrefab("Jail/list_prisoner")
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/bg/title/close")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)

    _ui.defenseSlider = transform:Find("Container/bg/top/jindu"):GetComponent("UISlider")
    _ui.defenseLabel = transform:Find("Container/bg/top/jindu/number"):GetComponent("UILabel")

    _ui.noDamageObject = transform:Find("Container/bg/text_none").gameObject

    _ui.burningObject = transform:Find("Container/bg/button").gameObject
    _ui.goldLabel = transform:Find("Container/bg/button/gold/number"):GetComponent("UILabel")
    _ui.burningLabel = transform:Find("Container/bg/button/fire/text"):GetComponent("UILabel")
    _ui.extinguishButton = transform:Find("Container/bg/button"):GetComponent("UIButton")
    _ui.burningEffectObject = transform:Find("Container/bg/top/texiao").gameObject

    _ui.repairObject = transform:Find("Container/bg/button_repair").gameObject
    _ui.repairButton = transform:Find("Container/bg/button_repair"):GetComponent("UIButton")
    _ui.repairLabel = transform:Find("Container/bg/button_repair/time"):GetComponent("UILabel") 
    DefenseData.AddListener(LoadUI)
end

function Start()
    LoadUI()
end

function Close()
    DefenseData.RemoveListener(LoadUI)
    _ui = nil
end

function Show()
    Global.OpenUI(_M)
end

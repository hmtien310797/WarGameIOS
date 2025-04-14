module("RansomPay", package.seeall)
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
local timer = 0

function Hide()
    Global.CloseUI(_M)
    MainCityUI.LoginAwardGo()
end

function CloseAll()
    Hide()
end

local function LoadUI()
    local commanderMsg = _ui.commanderMsg
    for i = 1, 4 do
        local ransomValue = 0
        local ransom = commanderMsg.ransom[i]
        if ransom ~= nil then
            ransomValue = ransom.value
        end
        _ui.ransomLabelList[i].text = Global.ExchangeValue(ransomValue)
    end
end

local function RequestRansomOper(operType)
    local req = BuildMsg_pb.MsgPrisonRansomOperRequest()
    req.operType = operType
    Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgPrisonRansomOperRequest, req, BuildMsg_pb.MsgPrisonRansomOperResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            Hide()
			MainCityUI.UpdateRewardData(msg.fresh)
			MainData.RequestData()
        else
            Global.ShowError(msg.code)
        end
    end, true)
end

function Awake()
    _ui = {}
    _ui.prisonerPrefab = ResourceLibrary.GetUIPrefab("Jail/list_prisoner")
    local mask = transform:Find("mask")
    local closeButton = transform:Find("payransom/bg_frane/bg_top/btn_close")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)
    local ransomLabelList = {}
    for i = 1, 4 do
        ransomLabelList[i] = transform:Find(string.format("payransom/bg_frane/bg_mid/resource/%s/text_num", MainInformation.moneyNameList[i])):GetComponent("UILabel")
    end
    _ui.ransomLabelList = ransomLabelList
    _ui.payButton = transform:Find("payransom/bg_frane/btn_pay"):GetComponent("UIButton")
    _ui.refuseButton = transform:Find("payransom/bg_frane/btn_refuse"):GetComponent("UIButton")
    SetClickCallback(_ui.payButton.gameObject, function(go)
        MessageBox.Show(TextMgr:GetText(Text.jail_23), function()
            RequestRansomOper(1)
        end,
        function()
        end)
    end)
    SetClickCallback(_ui.refuseButton.gameObject, function(go)
        RequestRansomOper(2)
    end)
end

function Start()
    LoadUI()
end

function Close()
    _ui = nil
end

function Show(commanderMsg)
    Global.OpenUI(_M)
    _ui.commanderMsg = commanderMsg
end

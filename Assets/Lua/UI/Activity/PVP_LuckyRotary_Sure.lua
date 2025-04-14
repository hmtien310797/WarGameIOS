module("PVP_LuckyRotary_Sure", package.seeall)
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
    JailTreat.Hide()
    Hide()
end

function LoadUI()
    _ui.costLabel.text = Format(TextMgr:GetText(Text.PVP_LuckyRotary12), _ui.cost)
    _ui.priceTexture = ResourceLibrary:GetIcon("Item/", _ui.itemData.icon)
    _ui.priceLabel.text = _ui.itemCount
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)

    _ui.costLabel = transform:Find("Container/bg_frane/text1"):GetComponent("UILabel")
    _ui.priceTexture = transform:Find("Container/bg_frane/icongold"):GetComponent("UITexture")
    _ui.priceLabel = transform:Find("Container/bg_frane/icongold/number"):GetComponent("UILabel")
    _ui.confirmButton = transform:Find("Container/bg_frane/button"):GetComponent("UIButton")
    SetClickCallback(_ui.confirmButton.gameObject, function(go)
        local req = ActivityMsg_pb.MsgWarLossDrawRequest()
        req.drawType = _ui.priceIndex
        Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgWarLossDrawRequest, req, ActivityMsg_pb.MsgWarLossDrawResponse, function(msg)
            if msg.code ~= ReturnCode_pb.Code_OK then
                Global.FloatError(msg.code)
            else
                if _ui ~= nil then
                    _ui.requestCallback(msg)
                end
                Hide()
            end
        end)
    end)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()
    LoadUI()
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    _ui = nil
end

function Show(priceIndex, itemData, itemCount, cost, requestCallback)
    Global.OpenUI(_M)
    _ui.priceIndex = priceIndex
    _ui.itemData = itemData
    _ui.itemCount = itemCount
    _ui.cost = cost
    _ui.requestCallback = requestCallback
    LoadUI()
end

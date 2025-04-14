module("CD_Key", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr

local NUM_DIGITS = tonumber(TableMgr:GetGlobalData(100154).value)

local ui

function IsInViewport()
    return ui ~= nil
end

local function SetInputField(redeemCode)
    ui.inputField.value = redeemCode
end

function Show(redeemCode)
    if not IsInViewport() then
        Global.OpenUI(_M)
        SetInputField(redeemCode or "")
    end
end

function Hide()
    Global.CloseUI(_M)
end

function Awake()
    ui = {}

    ui.inputField = transform:Find("Container/Input"):GetComponent("UIInput")

    UIUtil.SetClickCallback(transform:Find("Container/Redeem Button").gameObject, function()
        local redeemCode = ui.inputField.value
        if NUM_DIGITS == 0 or string.len(redeemCode) == NUM_DIGITS then
            local request = ClientMsg_pb.MsgCDKeyExchangeRequest()
            request.cdkey = redeemCode

            Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCDKeyExchangeRequest, request, ClientMsg_pb.MsgCDKeyExchangeResponse, function(response)
                if response.code == ReturnCode_pb.Code_OK then
                    MainCityUI.UpdateRewardData(response.fresh)
                    
                    ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
                    ItemListShowNew.SetItemShow(response)
                    GUIMgr:CreateMenu("ItemListShowNew", false)
                else
                    Global.ShowError(response.code)
                end
            end)
        else
            MessageBox.Show(System.String.Format(TextMgr:GetText("CDKey_ui8"), NUM_DIGITS))
        end
    end)

    UIUtil.SetClickCallback(transform:Find("mask").gameObject, Hide)
end

function Start()
end

function Close()
    ui = nil
end

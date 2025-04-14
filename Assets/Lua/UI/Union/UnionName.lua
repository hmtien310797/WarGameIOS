module("UnionName", package.seeall)

local TextMgr = Global.GTextMgr
local SetClickCallback = UIUtil.SetClickCallback
local String = System.String

function Hide()
    Global.CloseUI(_M)
end

function Awake()
    local mask = transform:Find("mask")
    local closeButton = transform:Find("BGTOP/close")

    SetClickCallback(mask.gameObject, Hide)
    SetClickCallback(closeButton.gameObject, Hide)
end

function Start()
    local nameInput = transform:Find("BGMid"):GetComponent("UIInput")
    local namePriceLabel = transform:Find("BGButtom/Gold/GoldNumber"):GetComponent("UILabel")
    local nameConfirmTransform = transform:Find("BGButtom")
    local nameLeftLabel = transform:Find("BGMid/Digitleft"):GetComponent("UILabel")
    namePriceLabel.text = UnionInfo.GetRenamePrice()
    nameInput.defaultText = TextMgr:GetText(Text.click_input)

    EventDelegate.Set(nameInput.onChange, EventDelegate.Callback(function()
        local leftCount = nameInput.characterLimit - String(nameInput.value).Length
        local leftText = TextMgr:GetText(Text.union_name_string)
        nameLeftLabel.text = String.Format(leftText, leftCount)
    end))
    local leftCount = nameInput.characterLimit - String(nameInput.value).Length
    local leftText = TextMgr:GetText(Text.union_name_string)
    nameLeftLabel.text = String.Format(leftText, leftCount)

    SetClickCallback(nameConfirmTransform.gameObject, function()
        local req = GuildMsg_pb.MsgChangeGuildNameRequest()
        req.name = nameInput.value
        Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgChangeGuildNameRequest, req, GuildMsg_pb.MsgChangeGuildNameResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                Hide()
                UnionInfoData.Rename(msg.name)
                MainCityUI.UpdateRewardData(msg.fresh)
                FloatText.Show(TextMgr:GetText(Text.union_name_success))
            else
                Global.ShowError(msg.code)
            end
        end, false) 
    end)
end

function Show()
    Global.OpenUI(_M)
end

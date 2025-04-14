module("UnionCode", package.seeall)

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
    local bannerLeftLabel = transform:Find("BGMid/Digitleft"):GetComponent("UILabel")
    local bannerInput = transform:Find("BGMid"):GetComponent("UIInput")
    local bannerPriceLabel = transform:Find("BGButtom/Gold/GoldNumber"):GetComponent("UILabel")
    bannerInput.defaultText = TextMgr:GetText(Text.click_input)
    bannerPriceLabel.text = UnionInfo.GetChangeBannerPrice()
    local bannerConfirmTransform = transform:Find("BGButtom")

    EventDelegate.Set(bannerInput.onChange, EventDelegate.Callback(function()
        local leftCount = bannerInput.characterLimit - String(bannerInput.value).Length
        local leftText = TextMgr:GetText(Text.union_name_string)
        bannerLeftLabel.text = String.Format(leftText, leftCount)
    end))

    SetClickCallback(bannerConfirmTransform.gameObject, function()
        local req = GuildMsg_pb.MsgChangeGuildBannerRequest()
        req.banner = bannerInput.value
        Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgChangeGuildBannerRequest, req, GuildMsg_pb.MsgChangeGuildBannerResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                Hide()
                UnionInfoData.SetBanner(msg.banner)
                MainCityUI.UpdateRewardData(msg.fresh)
                FloatText.Show(TextMgr:GetText(Text.union_code_success))
            else
                Global.ShowError(msg.code)
            end
        end, false) 
    end)

end

function Show()
    Global.OpenUI(_M)
end

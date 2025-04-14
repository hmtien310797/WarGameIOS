class "VipWidget"
{
}

function VipWidget:__init__(rootTransform)
    self.transform = rootTransform
    self.gameObject = rootTransform.gameObject

    self.icon = rootTransform:Find("bg_vip/frame"):GetComponent("UITexture")
    self.expBar = rootTransform:Find("bg_exp/bg/bar"):GetComponent("UISlider")
    self.label = rootTransform:Find("bg_exp/bg/text"):GetComponent("UILabel")

    self.hint = rootTransform:Find("text_rechargetips"):GetComponent("UILabel")
    self.tips = rootTransform:Find("VIP/button/vipdesdes"):GetComponent("UILabel")

    self.btn_claim = rootTransform:Find("VIP/button").gameObject
    self.btn_go = rootTransform:Find("VIP/button_gou").gameObject

    UIUtil.SetClickCallback(self.btn_claim, function()
        VipData.CollectDailyVipExp(function()
            self:Update()
            MainCityUI.UpdateCashShopNotice()
        end)
    end)

    UIUtil.SetClickCallback(self.btn_go, function()
        VIP.Show()
    end)
end

function VipWidget:Update()
    local nowlevel = MainData.GetVipLevel()

    self.icon.mainTexture = Global.GResourceLibrary:GetIcon("pay/" ,"icon_vip" .. nowlevel)
    self.expBar.value = MainData.GetVipExp() / MainData.GetVipNextExp()
    self.label.text = MainData.GetVipExp() .. "/" .. MainData.GetVipNextExp()

    if nowlevel + 1 <= MainData.GetData().vip.maxviplevel then
        local curLanCode = Global.GTextMgr:GetCurrentLanguageID()
        local currency = Global.GTableMgr:GetCurrency(curLanCode) > 0 and Global.GTableMgr:GetCurrency(curLanCode) or 1
        local needRecharge = math.ceil((MainData.GetVipNextExp() - MainData.GetVipExp()) / currency)
        --self.hint.text = System.String.Format(Global.GTextMgr:GetText("vip_ui_recharge"), needRecharge, nowlevel + 1)
        self.hint.text = System.String.Format(Global.GTextMgr:GetText("vip_ui_recharge"), Global.FormatNumber(MainData.GetVipNextExp() - MainData.GetVipExp()), nowlevel + 1)
        self.hint.gameObject:SetActive(not MainData.IsInTast())
    else
        self.hint.text = ""
    end

    local vipLoginInfo = VipData.GetLoginInfo()
    local hasUnclaimedDailyVipExp = vipLoginInfo.pop
    
    self.btn_claim:SetActive(hasUnclaimedDailyVipExp)
    self.btn_go:SetActive(not hasUnclaimedDailyVipExp)

    self.tips.text = hasUnclaimedDailyVipExp and System.String.Format(Global.GTextMgr:GetText("VIP_ui108"), vipLoginInfo.todayObtain) or ""
end

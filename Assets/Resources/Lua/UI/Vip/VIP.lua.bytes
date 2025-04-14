module("VIP", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local AudioMgr = Global.GAudioMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String
local loadCoroutine
local pageWidetWidth = 0
local VipLevelList

local _ui, UpdateUI
local needjump = false
local lastlevel = 0
local selectnum = 0

local jumplevel = nil

local vipGiftData

local isInViewport = false

local function CloseSelf()
	Global.CloseUI(_M)
end

local function UpdateLootBox(item, index, nowlevel, childIndex)
	_ui.LootBoxUI[childIndex] = item

	local giftData = vipGiftData[index + 1] -- VipMsg.VipGiftPkgInfo
	item.transform:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/hero_half/", tostring(giftData.background))

	local GiftOnPurchase = {}
	
	GiftOnPurchase.gameObject = item.transform:Find("bg_libao_top").gameObject
	GiftOnPurchase.title = GiftOnPurchase.gameObject.transform:Find("bg_title/text"):GetComponent("UILabel")

	GiftOnPurchase.icon = {}
	GiftOnPurchase.icon.gameObject = GiftOnPurchase.gameObject.transform:Find("Sprite").gameObject
	SetClickCallback(GiftOnPurchase.icon.gameObject, function()
		BoxShow.Show(giftData.giftInfo.rewardInfo, TextMgr:GetText("gift_detail"))
	end)
	GiftOnPurchase.icon.sprite = GiftOnPurchase.icon.gameObject.transform:GetComponent("UISprite")

	GiftOnPurchase.price_original = GiftOnPurchase.gameObject.transform:Find("bg_yuanjia/num"):GetComponent("UILabel")
	GiftOnPurchase.price_actual = GiftOnPurchase.gameObject.transform:Find("bg_xianjia/num"):GetComponent("UILabel")

	GiftOnPurchase.title.text = String.Format(TextMgr:GetText("vip_gift_ui1"), index)
	GiftOnPurchase.price_original.text = Global.FormatNumber(giftData.giftInfo.oldPrice)
	GiftOnPurchase.price_actual.text = Global.FormatNumber(giftData.giftInfo.price)

	GiftOnPurchase.btn_collect = {}
	GiftOnPurchase.btn_collect.gameObject = GiftOnPurchase.gameObject.transform:Find("btn_get").gameObject
	GiftOnPurchase.btn_collect.gameObject:SetActive(giftData.giftInfo.status == 2)
	GiftOnPurchase.btn_collect.sprite = GiftOnPurchase.btn_collect.gameObject.transform:GetComponent("UISprite")

	GiftOnPurchase.tips_collected = GiftOnPurchase.gameObject.transform:Find("text").gameObject
	GiftOnPurchase.tips_collected:SetActive(giftData.giftInfo.status > 2)

	SetClickCallback(GiftOnPurchase.btn_collect.gameObject, function(msg)
		-- if giftData.giftInfo.status == 1 then
		-- 	FloatText.ShowOn(GiftOnPurchase.btn_collect.gameObject, TextMgr:GetText("Change_203_des"))
		-- elseif giftData.giftInfo.status == 2 then
			VipData.PurchaseOneTimeGift(index, msg, function()
				if isInViewport then
					-- GiftOnPurchase.btn_collect.sprite.spriteName = "btn_4"
					GiftOnPurchase.btn_collect.gameObject:SetActive(false)
					GiftOnPurchase.tips_collected:SetActive(true)
					GiftOnPurchase.icon.sprite.spriteName = "icon_chest1_open"

					UpdateVipGiftData()
				end
			end)
		-- elseif giftData.giftInfo.status == 3 then
		-- 	FloatText.ShowOn(GiftOnPurchase.btn_collect.gameObject, TextMgr:GetText("VIP_ui111"), Color.White)
		-- end
	end, true)
	-- GiftOnPurchase.btn_collect.sprite.spriteName = string.format("btn_%d", giftData.giftInfo.status > 2 and 4 or 2)
	GiftOnPurchase.icon.sprite.spriteName = string.format("icon_chest1_%s", giftData.giftInfo.status > 2 and "open" or "close")

	local DailyGift = {}
	DailyGift.gameObject = item.transform:Find("bg_libao_bottom").gameObject
	DailyGift.title = DailyGift.gameObject.transform:Find("bg_title/text"):GetComponent("UILabel")

	DailyGift.icon = {}
	DailyGift.icon.gameObject = DailyGift.gameObject.transform:Find("Sprite").gameObject
	SetClickCallback(DailyGift.icon.gameObject, function()
		BoxShow.Show(giftData.dailyGiftInfo.rewardInfo, TextMgr:GetText("gift_detail"))
	end)
	DailyGift.icon.sprite = DailyGift.icon.gameObject.transform:GetComponent("UISprite")

	DailyGift.price_actual = DailyGift.gameObject.transform:Find("bg_xianjia/num"):GetComponent("UILabel")

	DailyGift.title.text = String.Format(TextMgr:GetText("vip_gift_ui2"), index)
	DailyGift.price_actual.text = Global.FormatNumber(giftData.dailyGiftInfo.price)

	DailyGift.btn_collect = {}
	DailyGift.btn_collect.gameObject = DailyGift.gameObject.transform:Find("btn_get").gameObject
	DailyGift.btn_collect.gameObject:SetActive(giftData.dailyGiftInfo.status == 2)
	DailyGift.btn_collect.sprite = DailyGift.btn_collect.gameObject.transform:GetComponent("UISprite")

	DailyGift.tips_collected = DailyGift.gameObject.transform:Find("text").gameObject
	DailyGift.tips_collected:SetActive(giftData.dailyGiftInfo.status > 2)

	SetClickCallback(DailyGift.btn_collect.gameObject, function(msg)
		-- if giftData.dailyGiftInfo.status == 2 then
			VipData.CollectDailyGift(index, msg, function()
				if isInViewport then
					-- DailyGift.btn_collect.sprite.spriteName = "btn_4"
					DailyGift.btn_collect.gameObject:SetActive(false)
					DailyGift.tips_collected:SetActive(true)
					DailyGift.icon.sprite.spriteName = "icon_chest2_open"
					
					UpdateVipGiftData()
				end
			end)
		-- elseif giftData.dailyGiftInfo.status == 3 then
		-- 	FloatText.ShowOn(DailyGift.btn_collect.gameObject, TextMgr:GetText("ui_activity_des6"), Color.White)
		-- end
	end, true)
	-- DailyGift.btn_collect.sprite.spriteName = string.format("btn_%d", giftData.dailyGiftInfo.status > 2 and 4 or 2)
	DailyGift.icon.sprite.spriteName = string.format("icon_chest2_%s", giftData.dailyGiftInfo.status > 2 and "open" or "close")
end

function RefreshLootBox()
	if isInViewport then
		UpdateLootBox(_ui.LootBoxUI[selectnum % 3], selectnum, selectnum, selectnum % 3)
	end
end

function UpdateVipGiftData()
	if isInViewport then
		vipGiftData = VipData.GetVipGiftData()
	end
end

function GetVipInfo() 
	local nowlevel = MainData.GetVipLevel()
	local needRecharge = 0
	
	if nowlevel + 1 <= MainData.GetData().vip.maxviplevel then
		local curLanCode = Global.GTextMgr:GetCurrentLanguageID()
		local currency = Global.GTableMgr:GetCurrency(curLanCode) > 0 and Global.GTableMgr:GetCurrency(curLanCode) or 1
		--needRecharge = math.ceil((MainData.GetVipNextExp() - MainData.GetVipExp()) / currency)
		needRecharge = MainData.GetVipNextExp() - MainData.GetVipExp()
	else
		nowlevel = 0
		needRecharge = 0
	end
	return nowlevel , needRecharge
end

local function UpdateUIOnChanger()
	local logininfo = VipData.GetLoginInfo()
	_ui.miaoshu.text = String.Format(TextMgr:GetText("VIP_ui102"), logininfo.tomorrowObtain)
	_ui.miaoshu2.text = String.Format(TextMgr:GetText("VIP_ui103"), logininfo.continuousDays)
	local nowlevel = MainData.GetVipLevel()
	
	local levelChange = 0
	if lastlevel ~= nowlevel then
		needjump = true
		levelChange = nowlevel - selectnum
		lastlevel = nowlevel
	end
	
	local vipData = TableMgr:GetVipData(nowlevel)
	_ui.vipicon.mainTexture = ResourceLibrary:GetIcon("pay/" ,vipData.vipIcon--[["icon_vip" .. nowlevel]] )
	_ui.expslider.value = MainData.GetVipExp() / MainData.GetVipNextExp()
	_ui.exptext.text = MainData.GetVipExp() .. "/" .. MainData.GetVipNextExp()
	if nowlevel + 1 <= MainData.GetData().vip.maxviplevel then
		--_ui.vipDesc.text = System.String.Format(TextMgr:GetText("VIP_ui109") , MainData.GetVipNextExp() - MainData.GetVipExp() , nowlevel + 1 )
		local curLanCode = Global.GTextMgr:GetCurrentLanguageID()
		local currency = Global.GTableMgr:GetCurrency(curLanCode) > 0 and Global.GTableMgr:GetCurrency(curLanCode) or 1
		local needRecharge = math.ceil((MainData.GetVipNextExp() - MainData.GetVipExp()) / currency)
		--print(curLanCode , currency , needRecharge)
		_ui.needHint.text = System.String.Format(TextMgr:GetText("vip_ui_recharge") ,MainData.GetVipNextExp() - MainData.GetVipExp() ,  nowlevel + 1)
		_ui.needHint.gameObject:SetActive(not MainData.IsInTast())
	else
		--_ui.vipDesc.text = ""
		_ui.needHint.text = ""
	end
	
	if needjump then
		UpdateVipGiftData()
		-- vipGiftData = VipData.UpdateGiftData(nowlevel)

		_ui.scrollSpringPanel:SetSpringPanelMove(Vector3(-(levelChange)*_ui.pageWidetWidth , 0 , 0))
		selectnum = nowlevel
		needjump = false
		
		local datalength = #VipLevelList
		_ui.btn_left.gameObject:SetActive(selectnum > 0)
		_ui.btn_right.gameObject:SetActive(selectnum < datalength-1)
		_ui.UpdateContentItem = {}

		if math.abs(levelChange) < 2 then
			RefreshLootBox() -- UpdateLootBox(_ui.LootBoxUI[nowlevel % 3], nowlevel, nowlevel, nowlevel % 3)
		end
	end
end

function Close()
	jumplevel = nil
	isInViewport = false
	_ui.optGrid.onInitializeItem = nil 	_ui = nil
	vipGiftData = nil
	loadCoroutine = nil
	needjump = false
	lastlevel = 0
	CountDown.Instance:Remove("vip")
	MainData.RemoveListener(UpdateUIOnChanger)
end

function Show(level)
	jumplevel = level
	Global.OpenUI(_M)
end

function Awake()
	_ui = {}
	_ui.container = transform:Find("Container").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	_ui.miaoshu = transform:Find("Container/bg_frane/text_miaosu"):GetComponent("UILabel")
	_ui.miaoshu.gameObject:GetComponent("LocalizeEx").enabled = false	
	_ui.miaoshu2 = transform:Find("Container/bg_frane/text_miaosu (1)"):GetComponent("UILabel")
	_ui.miaoshu2.gameObject:GetComponent("LocalizeEx").enabled = false
	_ui.vipicon = transform:Find("Container/bg_frane/bg_vip/frame"):GetComponent("UITexture")
	_ui.expslider = transform:Find("Container/bg_frane/bg_exp/bg/bar"):GetComponent("UISlider")
	_ui.exptext = transform:Find("Container/bg_frane/bg_exp/bg/text"):GetComponent("UILabel")
	_ui.scroll = transform:Find("Container/bg_frane/bg_mid/Scroll View"):GetComponent("UIScrollView")
	--_ui.grid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.scrollSpringPanel = transform:Find("Container/bg_frane/bg_mid/Scroll View"):GetComponent("UISpringPanel")
	_ui.optGrid = transform:Find("Container/bg_frane/bg_mid/Scroll View/OptGrid"):GetComponent("UIWrapContent")
	_ui.btn_use = transform:Find("Container/bg_frane/btn_pay").gameObject
	_ui.btn_left = transform:Find("Container/bg_frane/bg_mid/arrows/bg_arrow_left").gameObject
	_ui.btn_right = transform:Find("Container/bg_frane/bg_mid/arrows/bg_arrow_right").gameObject
	_ui.vipDesc = transform:Find("Container/bg_frane/text_desc"):GetComponent("UILabel")
	_ui.pageWidetWidth = transform:Find("Container/bg_frane/bg_mid/Scroll View/OptGrid"):GetChild(0):GetComponent("UIWidget").width
	_ui.viphelp = transform:Find("Container/bg_frane/btn_help").gameObject
	_ui.needHint = transform:Find("Container/bg_frane/text_rechargetips"):GetComponent("UILabel")

	_ui.UpdateContentItem = {}
	_ui.LootBoxUI = {}
	VipLevelList = {}
	
	_ui.vipinfo = transform:Find("Container/VIPinfo")
	_ui.listinfo = transform:Find("Container/listinfo")
	MainData.AddListener(UpdateUIOnChanger)
end

function Start()
	isInViewport = true

	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	SetClickCallback(_ui.btn_use, function()
		CloseSelf()
		Goldstore.ShowRechargeTab()
	end)
	
	needjump = true
	lastlevel = 0
	selectnum = 0
	
	UpdateVipGiftData()
	-- vipGiftData = VipData.GetVipGiftData()
	UpdateUI(jumplevel)
end

local function SetLeftRight()
	if selectnum == 1 then
		_ui.btn_left:SetActive(false)
	elseif selectnum == #_ui.viplist then
		_ui.btn_right:SetActive(false)
	else
		_ui.btn_left:SetActive(true)
		_ui.btn_right:SetActive(true)
	end
end

local function UpdateVipListItem(item , childIndex , realInde)
	local index = realInde
	local v = VipData.GetVipList()[index]
	local nowlevel = MainData.GetVipLevel()
	--print("==============" , index , realInde , v , nowlevel , selectnum)
	if selectnum < realInde - 1  or selectnum >  realInde + 1 then
		return
	end
	
	if v == nil then
		return
	end
	
	--print("--------------" , index , realInde , v , nowlevel , selectnum)
	_ui.UpdateContentItem[childIndex] = realInde
	--_ui.realIndexMap[childIndex] = realInde
	--local nowlevel = MainData.GetVipLevel()
	if lastlevel ~= nowlevel then
		needjump = true
		lastlevel = nowlevel
	end
	
	SetClickCallback(item.gameObject, function()
		local centerClick = item:GetComponent("UICenterOnClick")
		item.gameObject:SendMessage("OnClick")
	end)
	print(index)
	local vipData = TableMgr:GetVipData(index)
	item.transform:Find("bg_icon/icon_vip"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("pay/" ,vipData.vipIcon--[["icon_vip" .. index]] )
	item.transform:Find("title"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText("VIP_ui112") , index)

	local scroll = item.transform:Find("Scroll View"):GetComponent("UIScrollView")
	local grid = scroll.transform:Find("Grid"):GetComponent("UIGrid")
	local cc = grid.transform.childCount
	for i=#v , cc-1 , 1 do
		grid.transform:GetChild(i).gameObject:SetActive(false)
	end
	
	for ii, vv in ipairs(v) do
		local info
		if ii <= cc then
			info = grid.transform:GetChild(ii - 1).gameObject
			info:SetActive(true)
		else
			info = NGUITools.AddChild(grid.gameObject , _ui.listinfo.gameObject)
		end
		info.transform:Find("bg_list").gameObject:SetActive(ii % 2 == 0)
		
		local st
		if string.find(vv.showvalue, ';') ~= nil then
			local p = string.split(vv.showvalue, ';')
			st = String.Format(TextMgr:GetText(p[2]), p[1])
		else
			st = vv.showvalue
		end	
		info.transform:Find("text"):GetComponent("UILabel").text = string.format("%s%s" , TextMgr:GetText(vv.text),(st == "" and index <= nowlevel) and "" or st)
		--local isnew = VipData.IsNew(index-1, vv)

		info.transform:Find("bg_select").gameObject:SetActive(vv.isnew > 0)
		info.transform:Find("icon_new").gameObject:SetActive(vv.isnew > 0)
	end
	grid.repositionNow = true
	scroll:ResetPosition()

	UpdateLootBox(item, index, nowlevel, childIndex)
end

UpdateUI = function(level)
	local logininfo = VipData.GetLoginInfo()
	if MainData.GetVipValue().viplevelTaste > MainData.GetVipValue().viplevel then
		_ui.viphelp:SetActive(true)
		SetClickCallback(_ui.viphelp, function()
			DailyActivityHelp.Show("setting_ui9", "Vip_Card_Help_Desc")
		end)
		CountDown.Instance:Add("vip", MainData.GetVipValue().viptimeTaste, CountDown.CountDownCallBack(function(t)
			if t == "00:00:00" then
				_ui.miaoshu.text = String.Format(TextMgr:GetText("VIP_ui102"), logininfo.tomorrowObtain)
				CountDown.Instance:Remove("vip")
			else
				_ui.miaoshu.text = String.Format(TextMgr:GetText("vip_ui6"), t) 
			end
		end))
	else
		_ui.miaoshu.text = String.Format(TextMgr:GetText("VIP_ui102"), logininfo.tomorrowObtain)
	end	
	
	_ui.miaoshu2.text = String.Format(TextMgr:GetText("VIP_ui103"), logininfo.continuousDays)
	local nowlevel = level ~= nil and level or MainData.GetVipLevel()
	if lastlevel ~= nowlevel then
		needjump = true
		lastlevel = nowlevel
	end
	local vipData = TableMgr:GetVipData(MainData.GetVipLevel())
	_ui.vipicon.mainTexture = ResourceLibrary:GetIcon("pay/" ,vipData.vipIcon --[["icon_vip" .. MainData.GetVipLevel() ]])
	_ui.expslider.value = MainData.GetVipExp() / MainData.GetVipNextExp()
	_ui.exptext.text = MainData.GetVipExp() .. "/" .. MainData.GetVipNextExp()
	if MainData.GetVipLevel() + 1 <= MainData.GetData().vip.maxviplevel then
		--_ui.vipDesc.text = System.String.Format(TextMgr:GetText("VIP_ui109") , MainData.GetVipNextExp() - MainData.GetVipExp() , nowlevel + 1 )
		local curLanCode = Global.GTextMgr:GetCurrentLanguageID()
		local currency = Global.GTableMgr:GetCurrency(curLanCode) > 0 and Global.GTableMgr:GetCurrency(curLanCode) or 1
		local needRecharge = math.ceil((MainData.GetVipNextExp() - MainData.GetVipExp()) / currency)
		--print(curLanCode , currency , needRecharge)
		_ui.needHint.text = System.String.Format(TextMgr:GetText("vip_ui_recharge") ,MainData.GetVipNextExp() - MainData.GetVipExp() , MainData.GetVipLevel() + 1 )
		_ui.needHint.gameObject:SetActive(not MainData.IsInTast())
	else
		--_ui.vipDesc.text = ""
		_ui.needHint.text = ""
	end

	
	for i , v in pairs(VipData.GetVipList()) do
		if v ~= nil then
			table.insert(VipLevelList , i)
		end
	end
	local datalength = #VipLevelList
	_ui.optGrid.minIndex = 0
	_ui.optGrid.maxIndex = (datalength-1)
	_ui.optGrid.onInitializeItem = UpdateVipListItem

	
	if needjump then
		selectnum = nowlevel
		_ui.scrollSpringPanel:SetSpringPanelMove(Vector3(-(nowlevel)*_ui.pageWidetWidth , 0 , 0))
		--_ui.scroll:MoveRelative(Vector3(-(nowlevel)*800 , 0 , 0))
		_ui.optGrid:UpdateSpecialItem(nowlevel%3)
		needjump = false
		
		_ui.btn_left.gameObject:SetActive(selectnum > 0)
		_ui.btn_right.gameObject:SetActive(selectnum < datalength-1)
	end
	
	SetClickCallback(_ui.btn_left, function()
		selectnum = selectnum - 1
		selectnum = math.max(0, selectnum)
		_ui.btn_left.gameObject:SetActive(selectnum > 0)
		_ui.btn_right.gameObject:SetActive(selectnum < datalength-1)
		_ui.scrollSpringPanel:SetSpringPanelMove(Vector3(_ui.pageWidetWidth , 0 , 0))
		
		for i=1 , 3 , 1 do
			if _ui.UpdateContentItem[i-1] == nil then
				_ui.optGrid:UpdateSpecialItem(i-1)
			end
		end
		
	end)
	SetClickCallback(_ui.btn_right, function()
		selectnum = selectnum + 1
		selectnum = math.min(datalength, selectnum)
		_ui.btn_right.gameObject:SetActive(selectnum < datalength-1)
		_ui.btn_left.gameObject:SetActive(selectnum > 0)
		_ui.scrollSpringPanel:SetSpringPanelMove(Vector3(-_ui.pageWidetWidth , 0 , 0))
		
		for i=1 , 3 , 1 do
			if _ui.UpdateContentItem[i-1] == nil then
				_ui.optGrid:UpdateSpecialItem(i-1)
			end
		end
	end)
	
end

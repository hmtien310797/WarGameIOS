module("MonthCard_reward", package.seeall)

local TextMgr = Global.GTextMgr
local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr

local SetClickCallback = UIUtil.SetClickCallback
local GameObject = UnityEngine.GameObject
local GameTime = Serclimax.GameTime
local Format = System.String.Format
local ResourceLibrary =	Global.GResourceLibrary

local _ui = {}
local cards = {}
local cardCount = 0
local cardNames = {}
local cardDays = {}
local timer = 0

function Hide()
    -- MainCityUI.UpdateActivityNotice()
    Global.CloseUI(_M)
end

function LateUpdate()
	if _ui.configs["refreshtime"] ~= nil then
	    if timer >= 0 then
	        timer = timer - Serclimax.GameTime.deltaTime
	        if timer < 0 then
	            timer = 1
	            _ui.time_line2.text = Format(TextMgr:GetText(_ui.configs["refreshtime"]), Global.GetLeftCooldownTextLong(Global.GetFiveOclockCooldown()))
	        end
	    end
	end
end

local GetReward = function(msg)
    if msg.code == 0 then
        MainCityUI.UpdateRewardData(msg.fresh)
        Global.ShowReward(msg.reward)
        LoadUI()
    else
        Global.ShowError(msg.code)
    end
end

function Awake()
    _ui = {}
    cards = {}
    cardCount = 0
    cardNames = {}
    cardDays = {}

	cardNames[1] = TextMgr:GetText("pay_ui6")
	cardNames[2] = TextMgr:GetText("pay_ui5")
	cardDays[1] = "7"
    cardDays[2] = "30"    
    _ui.mask = transform.transform:Find("mask") 
    _ui.btn_close = transform.transform:Find("Container/bg_frame/bg_top/btn_close")
    _ui.resettime = transform.transform:Find("Container") 
    SetClickCallback(_ui.mask.gameObject, function() 
        WelfareAll.Hide()
    end) 
    SetClickCallback(_ui.btn_close.gameObject, function() 
        WelfareAll.Hide()
    end) 
    _ui.mid = transform.transform:Find("Container/bg_frame/bg_mid").gameObject
    _ui.mid:SetActive(false)
    _ui.banner = transform.transform:Find("Container/bg_frame/banner").gameObject
    _ui.banner:SetActive(false)
    _ui.grid = transform.transform:Find("Container/bg_frame/bg_mid/Grid"):GetComponent("UIGrid")
    _ui.item = transform.transform:Find("Rewardinfo")

    _ui.configs = TableMgr:GetActivityShowCongfig(3004, 304)

    _ui.text_line1 = transform.transform:Find("Container/bg_frame/banner/Label"):GetComponent("UILabel")
	_ui.text_line2 = transform.transform:Find("Container/bg_frame/banner/tips01"):GetComponent("UILabel")
	_ui.time_line1 = transform.transform:Find("Container/bg_frame/banner/time"):GetComponent("UILabel")
	_ui.time_line2 = transform.transform:Find("Container/bg_frame/banner/time (1)"):GetComponent("UILabel")
	-- _ui.help = transform:Find("Container/content/bg_frame/banner/button_ins").gameObject
    -- LoadUI()
    MonthCardData.AddListener(LoadUI)
    MonthCardData.RequestData()
end

local function UpdateTop()
	-- if _ui.configs["HelpTitle"] == nil then
	-- 	_ui.help:SetActive(false)
	-- end
	_ui.text_line1.text = _ui.configs["title"] ~= nil and TextMgr:GetText(_ui.configs["title"]) or ""
	_ui.text_line2.text = _ui.configs["des"] ~= nil and TextMgr:GetText(_ui.configs["des"]) or ""
    if _ui.configs["lefttime"] ~= nil then
    --     if MonthCardData.GetData()[1].day ~= nil then
    --         local time = (Global.GetFiveOclockCooldown() - Serclimax.GameTime.GetSecTime()) + ((30 - MonthCardData.GetData()[1].day) * 86400 + 5)
    --         CountDown.Instance:Add("MonthCard", time, CountDown.CountDownCallBack(function(t)
    --         if t == "00:00:00" then
    --             CountDown.Instance:Remove("MonthCard")
    --             MonthCardData.RequestData()
    --         else
    --             _ui.time_line1.text = Format(TextMgr:GetText(_ui.configs["lefttime"]),t)
    --         end        
    --         end))        
    --     else
    --         _ui.time_line1.text = ""
    --     end
	else
		_ui.time_line1.text = ""
	end
	if _ui.configs["refreshtime"] == nil then
		_ui.time_line2.text = ""
	else
		_ui.time_line2.text = Format(TextMgr:GetText(_ui.configs["refreshtime"]), Global.GetLeftCooldownTextLong(Global.GetFiveOclockCooldown()))
	end
end

function LoadUI()
    UpdateTop()

    local platformType = GUIMgr:GetPlatformType()

    for i, v in ipairs(MonthCardData.GetData()) do
        if v.code == 0 then
            local _item
            if i - 1 < _ui.grid.transform.childCount then
                _item = _ui.grid.transform:GetChild(i - 1).gameObject
            else
                _item = GameObject.Instantiate(_ui.item)
            end
            _item.transform:SetParent(_ui.grid.transform, false)
            _item.transform:Find("text_name"):GetComponent("UILabel").text = cardNames[i]
            local hintinfo = _item.transform:Find("text"):GetComponent("UILabel")
            local hint = _item.transform:Find("hint"):GetComponent("UILabel")
            local btn = _item.transform:Find("btn_get"):GetComponent("UIButton")
            btn.disabledColor = Color.white
            btn.disabledSprite = "btn_4"
            local btn_text = btn.transform:Find("text"):GetComponent("UILabel")
            _item.transform:Find("bg_mid/num"):GetComponent("UILabel").text = v.item.item.item[1].num
            _item.transform:Find("bg_mid/icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Background/","icon_act_" .. (18 + i))

            if v.buyed then
                _item.transform:Find("bg_mid/Container01").gameObject:SetActive(false)
                hintinfo.gameObject:SetActive(true)
                _item.transform:Find("bg_mid/num").gameObject:SetActive(true)
                if v.cantake then
                    hintinfo.text = TextMgr:GetText("pay_ui9")
                    btn.isEnabled = true
                else
                    hintinfo.text = TextMgr:GetText("pay_ui7")
                    btn.isEnabled = false
                end
                hint.text = "" .. v.day .. "/" .. cardDays[i]
                btn_text.text = TextMgr:GetText("mail_ui12")
                if i == 1 then
                    SetClickCallback(btn.gameObject, function()
                        local req = ShopMsg_pb.MsgIAPTakeWeekCardRequest()
                        LuaNetwork.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPTakeWeekCardRequest, req:SerializeToString(), function (typeId, data)
                            local msg = ShopMsg_pb.MsgIAPTakeWeekCardResponse()
                            msg:ParseFromString(data)  
                            GetReward(msg)
                            MonthCardData.RequestCard(3, function() MainCityUI.UpdateWelfareNotice(3004) end)
                            
                            if tonumber(v.day) == tonumber(cardDays[i]) then
                                store.RequestCardInfo(1, function()
                                    local goodsinfo = store.cards[i]
                                    local priceText
                                    if platformType == LoginMsg_pb.AccType_adr_huawei then
                                        priceText = "SGD$" .. goodsinfo.price
                                    elseif platformType == LoginMsg_pb.AccType_adr_tmgp or
                                    Global.IsIosMuzhi() or
                                    platformType == LoginMsg_pb.AccType_adr_muzhi or
                                    platformType == LoginMsg_pb.AccType_adr_opgame or
                                    platformType == LoginMsg_pb.AccType_adr_mango or
                                    platformType == LoginMsg_pb.AccType_adr_official or
                                    platformType == LoginMsg_pb.AccType_ios_official or
                                    platformType == LoginMsg_pb.AccType_adr_official_branch or
                                    platformType == LoginMsg_pb.AccType_adr_quick or
                                    platformType == LoginMsg_pb.AccType_adr_qihu then
                                        priceText = "RMB￥" .. goodsinfo.price
                                    else
                                        priceText = "US$" .. goodsinfo.price
                                    end

                                    MessageBox.Show(TextMgr:GetText("pay_ui11"), function() store.BuyCard(1) end, function() end, priceText)
                                end)
                            end
                        end, false) 
                    end)
                else
                    SetClickCallback(btn.gameObject, function()
                        local req = ShopMsg_pb.MsgIAPTakeMonthCardRequest()
                        LuaNetwork.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPTakeMonthCardRequest, req:SerializeToString(), function (typeId, data)
                            local msg = ShopMsg_pb.MsgIAPTakeMonthCardResponse()
                            msg:ParseFromString(data)
                            GetReward(msg)
                            MonthCardData.RequestCard(4, function() MainCityUI.UpdateWelfareNotice(3004) end)

                            if tonumber(v.day) == tonumber(cardDays[i]) then
                                store.RequestCardInfo(2, function()
                                    local goodsinfo = store.cards[i]
                                    local priceText
                                    if platformType == LoginMsg_pb.AccType_adr_huawei then
                                        priceText = "SGD$" .. goodsinfo.price
                                    elseif platformType == LoginMsg_pb.AccType_adr_tmgp or
                                    platformType == LoginMsg_pb.AccType_ios_muzhi or
                                    platformType == LoginMsg_pb.AccType_adr_muzhi or
                                    platformType == LoginMsg_pb.AccType_adr_opgame or
                                    platformType == LoginMsg_pb.AccType_adr_mango or
                                    platformType == LoginMsg_pb.AccType_adr_official or
                                    platformType == LoginMsg_pb.AccType_ios_official or
                                    platformType == LoginMsg_pb.AccType_adr_official_branch or
                                    platformType == LoginMsg_pb.AccType_adr_quick or
                                    platformType == LoginMsg_pb.AccType_adr_qihu then
                                        priceText = "RMB￥" .. goodsinfo.price
                                    else
                                        priceText = "US$" .. goodsinfo.price
                                    end

                                    MessageBox.Show(TextMgr:GetText("pay_ui12"), function() store.BuyCard(2) end, function() end, priceText)
                                end)
                            end
                        end, true)
                    end)
                end
            else
                _item.transform:Find("bg_mid/Container01").gameObject:SetActive(true)
                _item.transform:Find("bg_mid/Container01/number1"):GetComponent("UILabel").text = v.item.item.item[1].num
                _item.transform:Find("bg_mid/Container01/number2"):GetComponent("UILabel").text = i == 1 and 6300 or 17000
                _item.transform:Find("bg_mid/Container01/text3"):GetComponent("UILabel").text = i == 1 and TextMgr:GetText("MonthCard_Desc_Week") or TextMgr:GetText("MonthCard_Desc_Month")
                hintinfo.gameObject:SetActive(false)
                _item.transform:Find("bg_mid/num").gameObject:SetActive(false)
                hintinfo.text = TextMgr:GetText("pay_ui8")
                hint.text = ""

                local goodsinfo = store.cards[i]
                local priceText
                if platformType == LoginMsg_pb.AccType_adr_huawei then
                    priceText = "SGD$" .. goodsinfo.price
                elseif platformType == LoginMsg_pb.AccType_adr_tmgp then
                    priceText = "RMB￥" .. goodsinfo.price
                else
                    priceText = "US$" .. goodsinfo.price
                end

                btn_text.text = priceText

                SetClickCallback(btn.gameObject, function()
                    -- WelfareAll.Hide()
                    store.BuyCard(i)
                end)
            end
        end
    end

    _ui.grid:Reposition()
    _ui.mid:SetActive(true)
    _ui.banner:SetActive(true)
end

function Close()
    _ui = nil
    -- CountDown.Instance:Remove("MonthCard")
    MonthCardData.RemoveListener(LoadUI)
end

function Show()
    Global.OpenUI(_M)
end

function Refresh()
    LoadUI()
end

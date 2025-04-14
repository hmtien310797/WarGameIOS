module("EquipMainNew", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String

local _ui
local UpdateUI , UpdateRightInfo
local pos
OnCloseCB = nil

local function CloseSelf()
	Global.CloseUI(_M)
end

function Close()
	_ui = nil
	CountDown.Instance:Remove("EquipMainNew")
	EquipData.RemoveListener(UpdateUI)
	if OnCloseCB ~= nil then
		OnCloseCB()
		OnCloseCB = nil
	end
end

function Show(_pos)
	pos = _pos
	Global.OpenUI(_M)
end

function Awake()
	_ui = {}
	_ui.mask = transform:Find("mask").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	
	_ui.mid = {}--transform:Find("Container/bg_frane/mid")
	for i=1 , 7 do
		_ui.mid[i] = {}
		_ui.mid[i].transform = transform:Find(string.format("Container/bg_frane/mid/item (%d)", i))
		_ui.mid[i].texture = _ui.mid[i].transform:Find("Texture"):GetComponent("UITexture")
		_ui.mid[i].red = _ui.mid[i].transform:Find("red").gameObject
		SetClickCallback(transform:Find(string.format("Container/bg_frane/mid/item (%d)" , i)).gameObject , function()
			if i < 7 then
				EquipSelectNew.Show(i)
			else
				local open = 7
				for j = 7, 9 do
					if EquipData.GetCurEquipByPos(j) == nil and EquipData.IsUnlock(j) then
						open = j
					end
				end
				print(EquipData.IsUnlock(open), open)
				if EquipData.IsUnlock(open) then
					EquipSelectNew.Show(open)
				else
					local text = TextMgr:GetText("equip_shiptishi" .. (open - 5))
					FloatText.ShowAt(_ui.mid[i].transform.position,text, Color.white)
				end
			end
		end)
	end
	
	_ui.bottom = transform:Find("Container/bg_frane/bottom")
	_ui.bottom.gameObject:SetActive(false)
	_ui.bottom_time_name = transform:Find("Container/bg_frane/bottom/time/name"):GetComponent("UILabel")
	_ui.bottom_time_slider = transform:Find("Container/bg_frane/bottom/time/Sprite"):GetComponent("UISlider")
	_ui.bottom_time_label = transform:Find("Container/bg_frane/bottom/time/Sprite/time"):GetComponent("UILabel")
	_ui.bottom_time_speed = transform:Find("Container/bg_frane/bottom/time/speed").gameObject
	_ui.bottom_time_cancel = transform:Find("Container/bg_frane/bottom/time/cancel").gameObject
end

function Start()
	SetClickCallback(_ui.mask, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	selected = 0
	UpdateUI()
	EquipData.AddListener(UpdateUI)
end

UpdateUI = function()
	for i, v in ipairs(_ui.mid) do

		_ui.mid[i].red:SetActive(EquipData.IsCanUpgradeByPos(i))
	end
	local upgradingEquip = EquipData.GetUpgradingEquip()
	_ui.bottom.gameObject:SetActive(upgradingEquip ~= nil)
	if upgradingEquip ~= nil then
		local nameColor = Global.GetLabelColorNew(upgradingEquip.BaseData.quality)
		local needtime = EquipData.GetUpgradeNeedTime()
		needtime = math.ceil(needtime)
		_ui.bottom_time_name.text = nameColor[0] .. TextMgr:GetText(upgradingEquip.BaseData.name) .. nameColor[1]
		_ui.bottom_time_slider.value = 1 - (upgradingEquip.data.completeTime - Serclimax.GameTime.GetSecTime()) / needtime
		_ui.bottom_time_label.text = Serclimax.GameTime.SecondToString3(upgradingEquip.data.completeTime)
		CountDown.Instance:Add("EquipMainNew", upgradingEquip.data.completeTime, CountDown.CountDownCallBack(function(t)
        	if _ui ~= nil and _ui.bottom ~= nil and not _ui.bottom:Equals(nil) then
            	_ui.bottom_time_slider.value = 1 - (upgradingEquip.data.completeTime - Serclimax.GameTime.GetSecTime()) / needtime
            	_ui.bottom_time_label.text = t
            end
		end))
		
		local finish = function(go)
        	local num = math.floor(maincity.CaculateGoldForTime(1, upgradingEquip.data.completeTime - Serclimax.GameTime.GetSecTime()) + 0.5)
		    EquipData.RequestAccelForgeEquip()		            
        	GUIMgr:CloseMenu("CommonItemBag")
		end
		local cancelreq = function()
        	curStatus = false
        	EquipData.RequestCancelForgeEquip()
        	GUIMgr:CloseMenu("CommonItemBag")
        end
        local cancel = function(go)
        	MessageBox.Show(TextMgr:GetText("equip_ui47"), cancelreq, function() end)
		end
		local initfunc = function()
        	local data = ItemListData.GetData()
        	local upgradingEquip
			for i, v in ipairs(data) do
				local itemdata = TableMgr:GetItemData(v.baseid)
				if itemdata.type == 200 then
					if v.status >= 1 then
						upgradingEquip = v
					end
				end
			end
			if upgradingEquip ~= nil then
				local itemdata = TableMgr:GetItemData(upgradingEquip.baseid)
	        	local _text = nameColor[0] .. TextUtil.GetItemName(itemdata) .. nameColor[1]
	        	local _time = upgradingEquip.completeTime
	        	local _totalTime = needtime
	        	return _text, _time, _totalTime, finish, cancel, finish, 1
	        else
	        	return "", 0, 0, nil, nil, nil, 1
	        end
		end
		SetClickCallback(_ui.bottom_time_speed, function()
        	CommonItemBag.SetTittle(TextMgr:GetText("build_ui21"))
	        CommonItemBag.NotUseAutoClose()
	        CommonItemBag.NeedItemMaxValue()
	        CommonItemBag.SetItemList(maincity.GetItemExchangeListNoCommon(1), 4)
			CommonItemBag.SetUseFunc(EquipBuildNew.UseExItemFunc)
			CommonItemBag.SetInitFunc(initfunc)
			CommonItemBag.SetMsgText("purchase_confirmation4", "e_today")
			GUIMgr:CreateMenu("CommonItemBag" , false)
        end)
        SetClickCallback(_ui.bottom_time_cancel, function()
        	MessageBox.Show(TextMgr:GetText("equip_ui47"), function()
        		curStatus = false
	            EquipData.RequestCancelForgeEquip()
	        end,
	        function()
	        end)
        end)
	end
end


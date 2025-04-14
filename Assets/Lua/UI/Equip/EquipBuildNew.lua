module("EquipBuildNew", package.seeall)
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

local _ui, UpdateUI
local data, currentI, targetData, curStatus

local itemtipslist , itemTipTarget

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	if itemtipslist == nil then
		return
	end
	print(go.name)
	for i, v in pairs(itemtipslist) do
		if go == v.gameObject then
			--local itemdata = TableMgr:GetItemData(tonumber(go.name))
			go:SendMessage("OnClick")
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({BaseData = v.BaseData} , "equipTips")
		    else
		        if itemTipTarget == go then
		            Tooltip.HideItemTip()
		        else
		            itemTipTarget = go
					Tooltip.ShowItemTip({BaseData = v.BaseData} , "equipTips")
		        end
		    end
		    return
		end
	end
	Tooltip.HideItemTip()
	_ui.animator:SetTrigger("idle")
	if _ui.needdelay then
		_ui.tween_timer:ClearOnFinished()
		_ui.needdelay = false
		curStatus = false
		UpdateUI()
		EquipData.AddListener(UpdateUI)
	end
end

local function CloseSelf()
	Global.CloseUI(_M)
end

function Close()
	_ui = nil
	data = nil
	currentI = nil
	targetData = nil 
	itemtipslist = nil
	CountDown.Instance:Remove("EquipBuildNew")
	EquipData.RemoveListener(UpdateUI)
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
end

function Show(_data, _targetData)
	data = _data
	targetData = _targetData
	Global.OpenUI(_M)
end

function Awake()
	_ui = {}
	itemtipslist = {}
	_ui.container = transform:Find("Container").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject

	_ui.left_materials = {}
	_ui.left_material_root = transform:Find("Container/bg_frane/bg2/Container/left/mid/material_root")
	_ui.left_material_item = transform:Find("Container/bg_frane/bg2/Container/left/mid/material")
	
	_ui.left_make = transform:Find("Container/bg_frane/bg2/Container/left/mid/bg_make").gameObject
	_ui.left_make_texture = transform:Find("Container/bg_frane/bg2/Container/left/mid/bg_make/item/Texture"):GetComponent("UITexture")
	_ui.left_make_quality = transform:Find("Container/bg_frane/bg2/Container/left/mid/bg_make/item"):GetComponent("UISprite")
	_ui.left_make_effect = transform:Find("Container/bg_frane/bg2/Container/left/mid/bg_make/item/effects").gameObject
	_ui.left_upgrade = transform:Find("Container/bg_frane/bg2/Container/left/mid/bg_levelup").gameObject
	_ui.left_upgrade_left_texture = transform:Find("Container/bg_frane/bg2/Container/left/mid/bg_levelup/item_left/Texture"):GetComponent("UITexture")
	_ui.left_upgrade_left_quality = transform:Find("Container/bg_frane/bg2/Container/left/mid/bg_levelup/item_left"):GetComponent("UISprite")
	_ui.left_upgrade_left_level = transform:Find("Container/bg_frane/bg2/Container/left/mid/bg_levelup/item_left/level/num"):GetComponent("UILabel")
	_ui.left_upgrade_right_texture = transform:Find("Container/bg_frane/bg2/Container/left/mid/bg_levelup/item_right/Texture"):GetComponent("UITexture")
	_ui.left_upgrade_right_quality = transform:Find("Container/bg_frane/bg2/Container/left/mid/bg_levelup/item_right"):GetComponent("UISprite")
	_ui.left_upgrade_right_level = transform:Find("Container/bg_frane/bg2/Container/left/mid/bg_levelup/item_right/level/num"):GetComponent("UILabel")
	_ui.left_upgrade_right_effect = transform:Find("Container/bg_frane/bg2/Container/left/mid/bg_levelup/item_right/effects").gameObject

	_ui.right_level = transform:Find("Container/bg_frane/bg2/Container/right/level/number"):GetComponent("UILabel")
	_ui.right_level2 = transform:Find("Container/bg_frane/bg2/Container/right/level (1)/number"):GetComponent("UILabel")
	_ui.right_scroll = transform:Find("Container/bg_frane/bg2/Container/right/Scroll View"):GetComponent("UIScrollView")
	_ui.right_grid = transform:Find("Container/bg_frane/bg2/Container/right/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.right_item = transform:Find("Container/bg_frane/bg2/item_attribute")

	_ui.bottom_time = transform:Find("Container/bg_frane/bg2/Container/left/time").gameObject
	_ui.bottom_time_name = transform:Find("Container/bg_frane/bg2/Container/left/time/name"):GetComponent("UILabel")
	_ui.bottom_time_slider = transform:Find("Container/bg_frane/bg2/Container/left/time/Sprite"):GetComponent("UISlider")
	_ui.bottom_time_label = transform:Find("Container/bg_frane/bg2/Container/left/time/Sprite/time"):GetComponent("UILabel")
	_ui.bottom_time_speed = transform:Find("Container/bg_frane/bg2/Container/left/time/speed").gameObject
	_ui.bottom_time_cancel = transform:Find("Container/bg_frane/bg2/Container/left/time/cancel").gameObject
	_ui.bottom_btn1 = transform:Find("Container/bg_frane/bg2/Container/left/button01").gameObject
	_ui.bottom_btn1_label = transform:Find("Container/bg_frane/bg2/Container/left/button01/Label"):GetComponent("UILabel")
	_ui.bottom_btn1_time = transform:Find("Container/bg_frane/bg2/Container/left/button01/time"):GetComponent("UILabel")
	_ui.bottom_btn2 = transform:Find("Container/bg_frane/bg2/Container/left/button02").gameObject
	_ui.bottom_btn2_label = transform:Find("Container/bg_frane/bg2/Container/left/button02/Label"):GetComponent("UILabel")
	_ui.bottom_btn2_num = transform:Find("Container/bg_frane/bg2/Container/left/button02/number"):GetComponent("UILabel")

	_ui.animator = transform:Find("Container/bg_frane/bg2/Container"):GetComponent("Animator")
	_ui.tween_timer = transform:Find("Container/bg_frane/bg2/Container"):GetComponent("TweenAlpha")

	EquipData.AddListener(UpdateUI)
	AddDelegate(UICamera, "onPress", OnUICameraPress)
end

function Start()
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	UpdateUI()
end

function UseExItemFunc(useItemId , exItemid , count)
	print("Useid : " .. useItemId .. "exid : " .. exItemid .. "count :" .. count)
	local itemTBData = TableMgr:GetItemData(useItemId)
	local itemdata = ItemListData.GetItemDataByBaseId(useItemId)

	local req = ItemMsg_pb.MsgUseItemSubTimeRequest()
	if itemdata ~= nil then
		req.uid = itemdata.uniqueid
	else
		req.exchangeId = exItemid
	end
	req.num = count
	req.subTimeType = 7
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemSubTimeRequest, req, ItemMsg_pb.MsgUseItemSubTimeResponse, function(msg)
		print("use item code:" .. msg.code)
		if msg.code == 0 then
			local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
			if price == 0 then
				GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
			else
				GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
			end
			AudioMgr:PlayUISfx("SFX_UI_building_speed", 1, false)
			useItemReward = msg.reward

			local nameColor = Global.GetLabelColorNew(itemTBData.quality)
			local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1])
			FloatText.Show(showText , Color.white ,ResourceLibrary:GetIcon("Item/", itemTBData.icon))
			
			MainCityUI.UpdateRewardData(msg.fresh)
			ItemListData.UpdateEquip(msg.equipInfo)
			CommonItemBag.UpdateTopProgress()
		else
            Global.FloatError(msg.code, Color.white)
		end
	end, true)
end

local function SetBtns(enabled)
	
end

local function ResetPos()
	if _ui == nil then
		return
	end
	for i, v in ipairs(_ui.left_materials) do
		v.texture.transform.localPosition = Vector3.zero
		v.texture.alpha = 1
	end
end

local function PlayTween()
	
end

local function PlayUpgradeSfx()
	if _ui == nil then
		return
	end
	if _ui.isupgrade then
		_ui.animator:SetTrigger("shengji")
		for i, v in ipairs(_ui.left_materials) do
			v.eta.delay = 0.033
			v.eta:PlayForward(true)
			v.tp:PlayForward(true)
			v.ta:SetOnFinished(EventDelegate.Callback(function()
				ResetPos()
			end))
			v.ta:PlayForward(true)
		end
	else
		_ui.animator:SetTrigger("duanzao")
		for i, v in ipairs(_ui.left_materials) do
			v.eta.delay = 0.16
			v.eta:PlayForward(true)
		end
	end
	if _ui.needdelay then
		_ui.tween_timer.duration = _ui.isupgrade and 4 or 2
		_ui.tween_timer:SetOnFinished(EventDelegate.Callback(function()
			_ui.needdelay = false
			curStatus = false
			UpdateUI()
			EquipData.AddListener(UpdateUI)
		end))
		_ui.tween_timer:PlayForward(true)
	end
end

local function PlayFinishSfx()
	
end

UpdateUI = function()
	if _ui == nil then
		return
	end
	local equipdata = EquipData.GetEquipByID(data.BaseData.id)
	if equipdata ~= nil and equipdata.data.status == 0 then
		local next = EquipData.GetEquipDataByID(data.BaseData.id).Next
		if next ~= nil and next > 0 then
			data = EquipData.GetEquipDataByID(next)
		end
	end
	local list, index = EquipData.GetEquipSeries(data.BaseData.id)
	local upgradingEquip = EquipData.GetUpgradingEquip()

	local mdata = EquipData.GetEquipDataByID(list[index])
	local hasequip, materials, isMax, materialenough, hasPrevious = EquipData.CheckMaterials(mdata.BaseData.id)
	local pdata = EquipData.GetEquipDataByID(mdata.Previous)
	local canUpgrade = (hasequip ~= nil or pdata == nil)
	if not canUpgrade then
		CloseSelf()
		return
	end

	_ui.left_make_effect:SetActive(materialenough)
	_ui.left_upgrade_right_effect:SetActive(materialenough)

	_ui.isupgrade = pdata ~= nil
	_ui.left_make:SetActive(pdata == nil)
	_ui.left_upgrade:SetActive(pdata ~= nil)

	_ui.bottom_btn1_label.text = pdata == nil and TextMgr:GetText("equip_ui25") or TextMgr:GetText("build_ui8")
	_ui.bottom_btn2_label.text = pdata == nil and TextMgr:GetText("equip_ui37") or TextMgr:GetText("build_ui9")
	itemtipslist = {}
	if pdata ~= nil then
		_ui.left_upgrade_left_texture.mainTexture = ResourceLibrary:GetIcon("Item/", pdata.BaseData.icon)
		_ui.left_upgrade_left_quality.spriteName = "bg_item" .. pdata.BaseData.quality
		_ui.left_upgrade_left_level.text = pdata.BaseData.itemlevel
		_ui.left_upgrade_right_texture.mainTexture = ResourceLibrary:GetIcon("Item/", mdata.BaseData.icon)
		_ui.left_upgrade_right_quality.spriteName = "bg_item" .. mdata.BaseData.quality
		_ui.left_upgrade_right_level.text = mdata.BaseData.itemlevel
	else
		_ui.left_make_texture.mainTexture = ResourceLibrary:GetIcon("Item/", mdata.BaseData.icon)
		_ui.left_make_quality.spriteName = "bg_item" .. mdata.BaseData.quality
	end
	_ui.right_level.text = mdata.BaseData.charLevel
	EquipData.SetLevelColor(_ui.right_level, mdata.BaseData.charLevel)
	_ui.right_level2.text = mdata.BaseData.charLevel
	EquipData.SetLevelColor(_ui.right_level2, mdata.BaseData.charLevel)
	_ui.right_level2.transform.parent.gameObject:SetActive(false)
	local singleRound = math.pi * 2 / #materials
	for i, v in ipairs(materials) do
		if i > #_ui.left_materials then
			_ui.left_materials[i] = {}
			_ui.left_materials[i].transform = NGUITools.AddChild(_ui.left_material_root.gameObject, _ui.left_material_item.gameObject).transform
			_ui.left_materials[i].texture = _ui.left_materials[i].transform:Find("Texture"):GetComponent("UITexture")
			_ui.left_materials[i].quality = _ui.left_materials[i].transform:GetComponent("UISprite")
			_ui.left_materials[i].label = _ui.left_materials[i].transform:Find("Label"):GetComponent("UILabel")
			_ui.left_materials[i].tp = _ui.left_materials[i].texture.transform:GetComponent("TweenPosition")
			_ui.left_materials[i].tp.from = Vector3(0,0,0)
			_ui.left_materials[i].ta = _ui.left_materials[i].texture.transform:GetComponent("TweenAlpha")
			_ui.left_materials[i].eta = _ui.left_materials[i].transform:Find("kuang1"):GetComponent("TweenAlpha")
		end
		_ui.left_materials[i].transform.localPosition = Vector3(math.sin(singleRound * (i - 1)), math.cos(singleRound * (i - 1)), 0) * 160
		_ui.left_materials[i].transform.gameObject:SetActive(true)
		local matdata = EquipData.GetMaterialByID(v.id)
		_ui.left_materials[i].quality.spriteName = "bg_item" .. matdata.BaseData.quality
		_ui.left_materials[i].texture.mainTexture = ResourceLibrary:GetIcon("Item/", matdata.BaseData.icon)
		_ui.left_materials[i].label.gameObject:SetActive(true)
		local serverdata = EquipData.GetMaterialServerDataByID(v.id)
		_ui.left_materials[i].label.text = (serverdata ~= nil and (serverdata.data.number >= v.need and serverdata.data.number or ("[ff0000]" .. serverdata.data.number .. "[-]")) or "[ff0000]0[-]") .. "/" .. v.need
		if pdata == nil then
			_ui.left_materials[i].tp.to = _ui.left_materials[i].transform:InverseTransformPoint(_ui.left_make_texture.transform.position)
		else
			_ui.left_materials[i].tp.to = _ui.left_materials[i].transform:InverseTransformPoint(_ui.left_upgrade_left_texture.transform.position)
		end
		local temp = {}
		temp.gameObject = _ui.left_materials[i].transform.gameObject
		temp.BaseData = matdata.BaseData
		table.insert(itemtipslist, temp)
	end

	for i = #materials + 1, #_ui.left_materials do
		_ui.left_materials[i].transform.gameObject:SetActive(false)
	end

	local childCount = _ui.right_grid.transform.childCount
	local index = 0
	for i, v in ipairs(mdata.BaseBonus) do
		if tonumber(v.BonusType) == nil or tonumber(v.BonusType) > 0 or v.Attype > 0 then
			local item
			if i <= childCount then
				item = _ui.right_grid.transform:GetChild(i - 1).transform
			else
				item = NGUITools.AddChild(_ui.right_grid.gameObject, _ui.right_item.gameObject).transform
			end
			item:GetComponent("UILabel").text = TextMgr:GetText(TableMgr:GetEquipTextDataByAddition(v.BonusType, v.Attype))
			item:Find("Label"):GetComponent("UILabel").text = System.String.Format("{0:F}" , v.Value) .. (Global.IsHeroPercentAttrAddition(v.Attype) and "%" or "")
			index = index + 1
		end
	end
	for i = index, childCount - 1 do
        GameObject.Destroy(_ui.right_grid.transform:GetChild(i).gameObject)
    end
	_ui.right_grid:Reposition()

	_ui.bottom_btn1:SetActive(upgradingEquip == nil)
	_ui.bottom_btn2:SetActive(upgradingEquip == nil)
	_ui.bottom_time:SetActive(upgradingEquip ~= nil)
	if upgradingEquip ~= nil then
		local nameColor = Global.GetLabelColorNew(upgradingEquip.BaseData.quality)
		local needtime = EquipData.GetUpgradeNeedTime()
		needtime = math.ceil(needtime)
		_ui.bottom_time_name.text = nameColor[0] .. TextMgr:GetText(upgradingEquip.BaseData.name) .. nameColor[1]
		_ui.bottom_time_slider.value = 1 - (upgradingEquip.data.completeTime - Serclimax.GameTime.GetSecTime()) / needtime
		_ui.bottom_time_label.text = Serclimax.GameTime.SecondToString3(upgradingEquip.data.completeTime)
		CountDown.Instance:Add("EquipBuildNew", upgradingEquip.data.completeTime, CountDown.CountDownCallBack(function(t)
        	if _ui ~= nil and _ui.bottom_time ~= nil and not _ui.bottom_time:Equals(nil) then
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
			CommonItemBag.SetUseFunc(UseExItemFunc)
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
	else
		CountDown.Instance:Remove("EquipBuildNew")
		EquipData.SetBtnEnable(_ui.bottom_btn1, canUpgrade, "btn_1")
		EquipData.SetBtnEnable(_ui.bottom_btn2, canUpgrade, "btn_2")

		local needtime = mdata.EquipData.Time / EquipData.GetSpeedUp() / (1 + 0.01 * (AttributeBonus.CollectBonusInfo()[1096] ~= nil and AttributeBonus.CollectBonusInfo()[1096] or 0))
		needtime = math.ceil(needtime)
		_ui.bottom_btn1_time.text = Serclimax.GameTime.SecondToString3(needtime)
		_ui.bottom_btn2_num.text = math.floor(maincity.CaculateGoldForTime(1, needtime) + 0.5)

		SetClickCallback(_ui.bottom_btn1, function()
			if curStatus then
				return
			end
			EquipData.RequestForgeEquip(hasequip ~= nil and hasequip.data.uniqueid or 0, mdata.BaseData.id, false, PlayUpgradeSfx)
		end)
		
		SetClickCallback(_ui.bottom_btn2, function()
			if curStatus then
				return
			end
			local beginrequest = function()
				if _ui == nil then
					return
				end
				curStatus = true
				EquipData.RemoveListener(UpdateUI)
				_ui.needdelay = true
				EquipData.RequestForgeEquip(hasequip ~= nil and hasequip.data.uniqueid or 0, mdata.BaseData.id, true, PlayUpgradeSfx)
			end
			local gold = math.floor(maincity.CaculateGoldForTime(1, needtime) + 0.5)
			if gold > tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.GoldLimitWarning).value) then
				if tonumber(os.date("%d")) == UnityEngine.PlayerPrefs.GetInt("e_today") then
					MessageBox.SetOkNow()
				else
					MessageBox.SetRemberFunction(function(ishide)
						if ishide then
							UnityEngine.PlayerPrefs.SetInt("e_today",tonumber(os.date("%d")))
							UnityEngine.PlayerPrefs.Save()
						end
					end)
				end
				MessageBox.Show(System.String.Format(TextMgr:GetText("purchase_confirmation4"), gold, TextMgr:GetText(mdata.BaseData.name)), beginrequest, function() canClick_gold = true end)
			else
				beginrequest()
			end
		end)
	end
end

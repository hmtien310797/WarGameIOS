module("EquipSelectNew", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter
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
local itemTipTarget
local backori = 230

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	local param = GetParameter(go)
	if param ~= nil then
		if not Tooltip.IsItemTipActive() then
			itemTipTarget = go
			Tooltip.ShowItemTip({BaseData = param} , "equipTips")
		else
			if itemTipTarget == go then
				Tooltip.HideItemTip()
			else
				itemTipTarget = go
				Tooltip.ShowItemTip({BaseData = param} , "equipTips")
			end
		end
		go:SendMessage("OnClick")
	else
		Tooltip.HideItemTip()
	end
end

local function CloseSelf()
	Tooltip.HideItemTip()
	Global.CloseUI(_M)
end

function Close()
	_ui = nil
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	EquipData.RemoveListener(UpdateUI)
	CountDown.Instance:Remove("EquipSelectNew")
end

function Show(_pos)
	pos = _pos
	Global.OpenUI(_M)
end

local function Func_Make(equipdata)
	local attrs = EquipData.GetEquipDataByID(equipdata.BaseData.id)
	print(equipdata.BaseData.id ,attrs, attrs.Next ,EquipData.GetEquipDataByID(attrs.Next))
	EquipBuildNew.Show(equipdata)
	--local hasequip, materials = EquipData.CheckMaterials(equipdata.BaseData.id)
	--EquipData.RequestForgeEquip(hasequip ~= nil and hasequip.data.uniqueid or 0, equipdata.BaseData.id, false, nil)
end

local function Func_Upgragde(equipdata)
	local attrs = EquipData.GetEquipDataByID(equipdata.BaseData.id)
	EquipBuildNew.Show(EquipData.GetEquipDataByID(attrs.Next), equipdata)
end

local function Func_Equip(equipdata , equipPos)
	EquipData.RequestWearEquip(equipdata.data.uniqueid, equipPos, UpdateUI)
end

local function Func_TakeOff(equipdata)
	EquipData.RequestTakeoffEquip(equipdata.data.uniqueid, UpdateUI)
end

function Awake()
	_ui = {}
	_ui.isopen = true
	_ui.mask = transform:Find("mask").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	--[[_ui.title = transform:Find("Container/title/text"):GetComponent("UILabel")
	_ui.scrollview = transform:Find("bg2/Scroll View"):GetComponent("UIScrollView")
	_ui.grid = transform:Find("bg2/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.item = transform:Find("bg2/Scroll View/Grid/listitem_authority")
	_ui.item:Find("Sprite"):GetComponent("UIToggle").group = 99
	_ui.btn_ok = transform:Find("btn ok").gameObject
	]]
	_ui.left = transform:Find("Container/bg_frane/left")
	_ui.leftScroll1 = _ui.left:Find("Scroll View1"):GetComponent("UIScrollView")
	_ui.leftGrid1 = _ui.left:Find("Scroll View1/Grid"):GetComponent("UIGrid")
	_ui.leftScroll2 = _ui.left:Find("Scroll View2"):GetComponent("UIScrollView")
	_ui.leftGrid2 = _ui.left:Find("Scroll View2/Grid"):GetComponent("UIGrid")
	_ui.leftBuildingBg = _ui.left:Find("building")
	_ui.bottom_time_name = transform:Find("Container/bg_frane/left/building/time/name"):GetComponent("UILabel")
	_ui.bottom_time_slider = transform:Find("Container/bg_frane/left/building/time/Sprite"):GetComponent("UISlider")
	_ui.bottom_time_label = transform:Find("Container/bg_frane/left/building/time/Sprite/time"):GetComponent("UILabel")
	_ui.bottom_time_speed = transform:Find("Container/bg_frane/left/building/time/speed").gameObject
	_ui.bottom_time_cancel = transform:Find("Container/bg_frane/left/building/time/cancel").gameObject
	
	_ui.right = transform:Find("Container/bg_frane/right")
	_ui.rightTitle = _ui.right:Find("title1/Label"):GetComponent("UILabel")
	_ui.rightTop = _ui.right:Find("mid/Scroll View/top")
	_ui.rightTopType = _ui.rightTop:Find("type"):GetComponent("UILabel")
	_ui.rightTopText = _ui.rightTop:Find("text"):GetComponent("UILabel")
	_ui.rightTopItem = _ui.rightTop:Find("item"):GetComponent("UISprite")
	_ui.rightTopItemTexture = _ui.rightTop:Find("item/Texture"):GetComponent("UITexture")
	_ui.rightTopItemLevel = _ui.rightTop:Find("item/level")
	_ui.rightTopItemLevelNum = _ui.rightTop:Find("item/level/num"):GetComponent("UILabel")
	
	_ui.rightMidTile1 = _ui.right:Find("mid/Scroll View/title1"):GetComponent("UILabel")
	_ui.rightMidTile2 = _ui.right:Find("mid/Scroll View/title2"):GetComponent("UILabel")
	_ui.rightMidBg1 = _ui.right:Find("mid/Scroll View/bg1")
	
	_ui.rightMidBg1Icon1 = _ui.right:Find("mid/Scroll View/icon1"):GetComponent("UISprite")
	_ui.rightMidBg1Lab1 = _ui.right:Find("mid/Scroll View/icon1/Label1"):GetComponent("UILabel")
	_ui.rightMidBg1Num1 = _ui.right:Find("mid/Scroll View/icon1/Label1/number"):GetComponent("UILabel")
	_ui.rightMidBg1Icon2 = _ui.right:Find("mid/Scroll View/icon2"):GetComponent("UISprite")
	_ui.rightMidBg1Lab2 = _ui.right:Find("mid/Scroll View/icon2/Label2"):GetComponent("UILabel")
	_ui.rightMidBg1Num2 = _ui.right:Find("mid/Scroll View/icon2/Label2/number"):GetComponent("UILabel")
	
	_ui.rightMidBg2Scroll = _ui.right:Find("mid/Scroll View/bg2/Scroll View"):GetComponent("UIScrollView")
	_ui.rightMidBg2Grid = _ui.right:Find("mid/Scroll View/bg2/Scroll View/Grid"):GetComponent("UIGrid")
	
	_ui.rightButton1 = _ui.right:Find("button1")
	_ui.rightButton1Label = _ui.right:Find("button1/Label"):GetComponent("UILabel")
	_ui.rightButton1Red = _ui.right:Find("button1/red").gameObject
	_ui.rightButton2 = _ui.right:Find("button2")
	_ui.rightButton2Red = _ui.right:Find("button2/red").gameObject
	_ui.rightButton2Label = _ui.right:Find("button2/Label"):GetComponent("UILabel")
	
	_ui.rightCombat = _ui.right:Find("combat"):GetComponent("UILabel")
	_ui.rightBack = transform:Find("Container/bg_frane/right/mid/Scroll View/back"):GetComponent("UISprite")

	_ui.rightMaterialTitle = transform:Find("Container/bg_frane/right/mid/Scroll View/title_cailiao"):GetComponent("UILabel")
	_ui.rightMaterialGrid = transform:Find("Container/bg_frane/right/mid/Scroll View/bg_cailiao/Grid"):GetComponent("UIGrid")
	_ui.rightMaterial = {}
	for i = 1, _ui.rightMaterialGrid.transform.childCount do
		_ui.rightMaterial[i] = {}
		_ui.rightMaterial[i].transform = _ui.rightMaterialGrid.transform:GetChild(i - 1)
		_ui.rightMaterial[i].quality = _ui.rightMaterial[i].transform:GetComponent("UISprite")
		_ui.rightMaterial[i].texture = _ui.rightMaterial[i].transform:Find("Texture"):GetComponent("UITexture")
		_ui.rightMaterial[i].label = _ui.rightMaterial[i].transform:Find("Label"):GetComponent("UILabel")
	end
	
	_ui.noitem = transform:Find("Container/bg_frane/left/bg_noitem")
	_ui.noitem1 = transform:Find("Container/bg_frane/left/bg_noitem (1)")
	
	_ui.itemPrefab = transform:Find("Container/item_equip")
	_ui.itemList = transform:Find("Container/list")
	_ui.title1button = transform:Find("Container/bg_frane/left/title1"):GetComponent("UIToggle")
	_ui.title2button = transform:Find("Container/bg_frane/left/title2"):GetComponent("UIToggle")
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	EquipData.AddListener(UpdateUI)
end

function Start()
	SetClickCallback(_ui.mask, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	SetClickCallback(_ui.title1button.gameObject, function()
		UpdateUI()
	end)
	SetClickCallback(_ui.title2button.gameObject, function()
		UpdateUI()
	end)
	
	selected = 0
	Tooltip.HideItemTip()
	
	_ui.title1button:Set(true)
	UpdateUI()
end



function LoadItemObject(item , itemTransform)
	item.transform = itemTransform
    item.gameObject = itemTransform.gameObject
	item.quaIcon = itemTransform:GetComponent("UISprite")
	item.icon = itemTransform:Find("Texture"):GetComponent("UITexture")
	item.spr01 = itemTransform:Find("Sprite01"):GetComponent("UISprite")
	item.spr02 = itemTransform:Find("Sprite02"):GetComponent("UISprite")
	item.spr = itemTransform:Find("Sprite"):GetComponent("UISprite")
	item.num = itemTransform:Find("num_item"):GetComponent("UILabel")
	item.select = itemTransform:GetComponent("UIToggle")
	item.level = itemTransform:Find("level")
	item.levelnum = itemTransform:Find("level/num"):GetComponent("UILabel")
	return item
end

function LoadItemInfo(item , data)
	if item.quaIcon ~= nil then
		item.quaIcon.spriteName = "bg_item" .. data.BaseData.quality
	end
	
	if item.icon ~= nil then
		item.icon.mainTexture = ResourceLibrary:GetIcon("item/" , data.BaseData.icon)
	end

	if item.num ~= nil then
		item.num.text = ""
	end
	
	if item.selected ~= nil then
		item.selected.spriteName = ""
	end

	item.level.gameObject:SetActive(data.BaseData.itemlevel > 0)
	
	if item.levelnum ~= nil then
		item.levelnum.text = data.BaseData.itemlevel
	end
	
	if item.gameObject ~= nil then
		--SetParameter(item.gameObject, data.BaseData)
		SetClickCallback(item.gameObject, function()
			if item.select ~= nil then
				item.select:Set(true)
			end
			UpdateRightInfo(data)
		end)
	end
	
	local eqstatus = EquipData.GetEquipStatusById(data.BaseData.id)
	if item.spr01 ~= nil then
		item.spr01.gameObject:SetActive(eqstatus == 2)
		if data.data ~= nil and pos == data.data.parent.pos then
			item.isEquiped = eqstatus == 2
		end
	end
	
	local upgradingEquip = EquipData.GetUpgradingEquip()
	if item.spr02 ~= nil then
		item.spr02.gameObject:SetActive(upgradingEquip ~= nil and (upgradingEquip.data.status == 1 or upgradingEquip.data.status == 2) and upgradingEquip.BaseData.id == data.BaseData.id)
	end
	
	local canUpgrade = false
	if item.spr ~= nil then
		if data.data ~= nil then
			local hasequip, materials, isMax, materialenough, hasPrevious = EquipData.CheckMaterials(data.BaseData.id, true)
			canUpgrade = isMax == nil and materialenough
			canUpgrade = canUpgrade and data.data.status == 0
		else
			local hasequip, materials, isMax, materialenough, hasPrevious = EquipData.CheckMaterials(data.BaseData.id)
			canUpgrade = isMax == nil and materialenough
		end
		item.spr.gameObject:SetActive(canUpgrade)
	end
end

UpdateRightInfo = function(curData)
	--right top
	if _ui == nil then
		return
	end
	_ui.rightTitle.text = TextMgr:GetText(curData.BaseData.name)
	_ui.rightTopText.text = System.String.Format(TextMgr:GetText(curData.BaseData.description) , curData.BaseData.itemlevel)
	local item = {}
	--LoadItemObject(item , _ui.rightTopItem)
	item.quaIcon = _ui.rightTopItem
	item.icon = _ui.rightTopItem.transform:Find("Texture"):GetComponent("UITexture")
	item.level = _ui.rightTopItem.transform:Find("level")
	item.levelnum = _ui.rightTopItem.transform:Find("level/num"):GetComponent("UILabel")
	item.spr = _ui.rightButton1Red
	LoadItemInfo(item ,curData)
	--right mid
	_ui.rightMidTile1.text = TextMgr:GetText(curData.BaseData.name)
	_ui.rightMidBg1Lab1.text = TextMgr:GetText("player_ui22")--"指挥官等级: " .. curData.BaseData.charLevel
	_ui.rightMidBg1Num1.text =  curData.BaseData.charLevel
	EquipData.SetLevelColor(_ui.rightMidBg1Num1, curData.BaseData.charLevel)
	_ui.rightMidBg1Icon1.spriteName = MainData.GetLevel() >= curData.BaseData.charLevel and "icon_gou" or "New_x"
	
	_ui.rightMidBg1Lab2.text = TextMgr:GetText("player_ui22")--"指挥官等级: " .. curData.BaseData.charLevel
	_ui.rightMidBg1Num2.text =  curData.BaseData.charLevel
	EquipData.SetLevelColor(_ui.rightMidBg1Num2, curData.BaseData.charLevel)
	_ui.rightMidBg1Icon2.spriteName = MainData.GetLevel() >= curData.BaseData.charLevel and "icon_gou" or "New_x"
	_ui.rightMidBg1Icon2.gameObject:SetActive(false)
	
	local attrs = EquipData.GetEquipDataByID(curData.BaseData.id)
	_ui.rightCombat.text = System.String.Format(TextMgr:GetText("equip_powernum") , attrs.EquipData.Fight)--"战斗力:" .. attrs.EquipData.Fight
	_ui.rightTopType.text = System.String.Format(TextMgr:GetText("equip_ui53") , TextMgr:GetText(attrs.EquipData.EquipType))
	
	local maxData = EquipData.GetMaxEquipDataByID(curData.BaseData.id)
	local index = 0
	for i, v in ipairs(curData.BaseBonus) do
		if tonumber(v.BonusType) == nil or tonumber(v.BonusType) > 0 or v.Attype > 0 then
			index = index + 1
			local item = nil 
			if i <= _ui.rightMidBg2Grid.transform.childCount then
				item = _ui.rightMidBg2Grid.transform:GetChild(i - 1).transform
			else
				item = NGUITools.AddChild(_ui.rightMidBg2Grid.gameObject, _ui.itemList.gameObject).transform
			end
			item:Find("Label1"):GetComponent("UILabel").text = TextMgr:GetText(TableMgr:GetEquipTextDataByAddition(v.BonusType, v.Attype))
			item:Find("Label2"):GetComponent("UILabel").text = System.String.Format("{0:F}" , v.Value) .. (Global.IsHeroPercentAttrAddition(v.Attype) and "%" or "")
			item:Find("Label3"):GetComponent("UILabel").text = "(" .. TextMgr:GetText("equip_max_text") .. System.String.Format("{0:F}" , maxData.BaseBonus[i].Value) .. (Global.IsHeroPercentAttrAddition(maxData.BaseBonus[i].Attype) and "%" or "") .. ")"
		end
	end
	_ui.rightBack.height = backori + 30 * index
	for i = index, _ui.rightMidBg2Grid.transform.childCount - 1 do
        GameObject.Destroy(_ui.rightMidBg2Grid.transform:GetChild(i).gameObject)
    end
	_ui.rightMidBg2Grid:Reposition()
	
	local hasequip, materials, isMax, materialenough, hasPrevious
	if curData.data ~= nil then
		hasequip, materials, isMax, materialenough, hasPrevious = EquipData.CheckMaterials(curData.BaseData.id, true)
		_ui.rightMaterialTitle.text = TextMgr:GetText("equip_ui52")
	else
		hasequip, materials, isMax, materialenough, hasPrevious = EquipData.CheckMaterials(curData.BaseData.id)
		_ui.rightMaterialTitle.text = TextMgr:GetText("equip_ui51")
	end
	for i, v in ipairs(_ui.rightMaterial) do
		if i > #materials then
			v.transform.gameObject:SetActive(false)
		else
			v.transform.gameObject:SetActive(true)
			local matdata = EquipData.GetMaterialByID(materials[i].id)
			v.quality.spriteName = "bg_item" .. matdata.BaseData.quality
			v.texture.mainTexture = ResourceLibrary:GetIcon("Item/", matdata.BaseData.icon)
			v.label.gameObject:SetActive(true)
			local serverdata = EquipData.GetMaterialServerDataByID(materials[i].id)
			v.label.text = (serverdata ~= nil and (serverdata.data.number >= materials[i].need and serverdata.data.number or ("[ff0000]" .. serverdata.data.number .. "[-]")) or "[ff0000]0[-]") .. "/" .. materials[i].need
			SetParameter(v.transform.gameObject, matdata.BaseData)
		end
	end
	_ui.rightMaterialGrid:Reposition()
	
	local upgradingEquip = EquipData.GetUpgradingEquip()
	_ui.leftBuildingBg.localScale = upgradingEquip ~= nil and Vector3(1,1,0) or Vector3(1,0,0)
	if upgradingEquip ~= nil then
		local nameColor = Global.GetLabelColorNew(upgradingEquip.BaseData.quality)
		local needtime = EquipData.GetUpgradeNeedTime()
		needtime = math.ceil(needtime)
		_ui.bottom_time_name.text = nameColor[0] .. TextMgr:GetText(upgradingEquip.BaseData.name) .. nameColor[1]
		_ui.bottom_time_slider.value = 1 - (upgradingEquip.data.completeTime - Serclimax.GameTime.GetSecTime()) / needtime
		_ui.bottom_time_label.text = Serclimax.GameTime.SecondToString3(upgradingEquip.data.completeTime)
		CountDown.Instance:Add("EquipSelectNew", upgradingEquip.data.completeTime, CountDown.CountDownCallBack(function(t)
        	if _ui ~= nil and _ui.leftBuildingBg ~= nil and not _ui.leftBuildingBg:Equals(nil) then
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

	local eqstatus = EquipData.GetEquipStatusById(curData.BaseData.id)
	print(curData.BaseData.id , eqstatus)
	EquipData.SetBtnEnable(_ui.rightButton2, true, "btn_1")

	local isCurUpgrading = upgradingEquip ~= nil and (upgradingEquip.data.status == 1 or upgradingEquip.data.status == 2) and upgradingEquip.BaseData.id == curData.BaseData.id
	
	local hasnext = EquipData.GetEquipDataByID(attrs.Next) ~= nil
	_ui.rightButton2Red:SetActive(false)
	if isCurUpgrading then
		_ui.rightButton1.gameObject:SetActive(false)
		_ui.rightButton2.gameObject:SetActive(true)
		_ui.rightButton2Label.text = TextMgr:GetText("build_ui21")--"锻造"
		SetClickCallback(_ui.rightButton2.gameObject , function() _ui.bottom_time_speed:SendMessage("OnClick") end)
	else
		if eqstatus  == 0 then
			_ui.rightButton1.gameObject:SetActive(false)
			_ui.rightButton2.gameObject:SetActive(true)
			_ui.rightButton2Label.text = TextMgr:GetText("equip_ui25")--"锻造"
			SetClickCallback(_ui.rightButton2.gameObject , function() Func_Make(curData) end)
			_ui.rightButton2Red:SetActive(materialenough)
		elseif eqstatus == 1 then
			_ui.rightButton1.gameObject:SetActive(true)
			_ui.rightButton1Label.text = TextMgr:GetText("build_ui20")--"进阶"
			SetClickCallback(_ui.rightButton1.gameObject , function() Func_Upgragde(curData) end)
			_ui.rightButton2.gameObject:SetActive(true)
			_ui.rightButton2Label.text = TextMgr:GetText("equip_ui15")--"穿上"
			SetClickCallback(_ui.rightButton2.gameObject , function() Func_Equip(curData , pos) end)
			if EquipData.GetCurEquipByPos(pos) == nil then
				_ui.rightButton2Red:SetActive(true)
			end
		elseif eqstatus == 2 then
			print(curData.data.parent.pos)
			if curData.data.parent.pos ~= pos then
				_ui.rightButton1.gameObject:SetActive(true)
				_ui.rightButton1Label.text = TextMgr:GetText("build_ui20")--"进阶"
				SetClickCallback(_ui.rightButton1.gameObject , function() Func_Upgragde(curData) end)
				_ui.rightButton2.gameObject:SetActive(true)
				_ui.rightButton2Label.text = TextMgr:GetText("equip_ui15")--"穿上"
				EquipData.SetBtnEnable(_ui.rightButton2, false, "btn_1")
				SetClickCallback(_ui.rightButton2.gameObject ,function() end)
			else
				_ui.rightButton1.gameObject:SetActive(true)
				_ui.rightButton1Label.text = TextMgr:GetText("build_ui20")--"进阶"
				SetClickCallback(_ui.rightButton1.gameObject , function() Func_Upgragde(curData) end)
				_ui.rightButton2.gameObject:SetActive(true)
				_ui.rightButton2Label.text = TextMgr:GetText("equip_ui14")--"卸下"
				SetClickCallback(_ui.rightButton2.gameObject ,function() Func_TakeOff(curData) end)
			end
		end
		if not hasnext then
			EquipData.SetBtnEnable(_ui.rightButton1, false, "btn_2")
			SetClickCallback(_ui.rightButton1.gameObject , function() FloatText.ShowAt(_ui.rightButton1.transform.position, TextMgr:GetText("equip_ui54"), Color.white) end)
		else
			EquipData.SetBtnEnable(_ui.rightButton1, true, "btn_2")
		end
	end
end

UpdateUI = function()
	local curData = EquipData.GetCurEquipByPos(pos)
	local equiplist = EquipData.GetEquipListByPos(pos)
	if _ui. isopen then
		_ui.isopen = false
		if #equiplist <= 0 then
			_ui.title2button:Set(true)
			UpdateUI()
			return
		end
	end
	_ui.noitem.gameObject:SetActive( _ui.title1button.value and #equiplist <= 0)
	
	local equiped
	local haslist = {}
	local nothaslist = {}

	local index = 0
	if #equiplist > 0 then
		if curData == nil then
			print(curData)
			curData = equiplist[1]
		end 	
		for i=1 , #equiplist do
			index = index + 1
			local itemTransform = nil
			if i <= _ui.leftGrid1.transform.childCount then
				itemTransform = _ui.leftGrid1.transform:GetChild(i - 1).transform
			else
				itemTransform = NGUITools.AddChild(_ui.leftGrid1.gameObject, _ui.itemPrefab.gameObject).transform
			end
			local epInfo = equiplist[i]
			local item = {}
			LoadItemObject(item , itemTransform)
			LoadItemInfo(item ,epInfo)
			if item.isEquiped then
				equiped = item
			end
			table.insert(haslist, item)
		end
	end
	for i = index, _ui.leftGrid1.transform.childCount - 1 do
		GameObject.Destroy(_ui.leftGrid1.transform:GetChild(i).gameObject)
	end
	_ui.leftGrid1:Reposition()
	_ui.leftScroll1:ResetPosition()
	
	--未获得
	local nonEquiplist = EquipData.GetNonEquipListByPos(pos)
	_ui.noitem1.gameObject:SetActive( _ui.title2button.value and #nonEquiplist <= 0)
	index = 0
	if #nonEquiplist > 0 then
		if curData == nil then
			curData = nonEquiplist[1]
		end
		for i=1 , #nonEquiplist do
			index = index + 1
			if i <= _ui.leftGrid2.transform.childCount then
				itemTransform = _ui.leftGrid2.transform:GetChild(i - 1).transform
			else
				itemTransform = NGUITools.AddChild(_ui.leftGrid2.gameObject, _ui.itemPrefab.gameObject).transform
			end
			local epInfo = nonEquiplist[i]
			local item = {}
			LoadItemObject(item , itemTransform)
			LoadItemInfo(item ,epInfo)
			table.insert(nothaslist, item)
		end
	end
	for i = index, _ui.leftGrid2.transform.childCount - 1 do
		GameObject.Destroy(_ui.leftGrid2.transform:GetChild(i).gameObject)
	end
	_ui.leftGrid2:Reposition()
	_ui.leftScroll2:ResetPosition()
	
	UpdateRightInfo(curData)
	
	if equiped ~= nil then
		if equiped.select ~= nil then
			equiped.select:Set(true)
		end
	elseif #haslist > 0 then
		if haslist[1].select ~= nil then
			haslist[1].select:Set(true)
		end
	else
		if nothaslist[1].select ~= nil then
			nothaslist[1].select:Set(true)
		end
	end
end

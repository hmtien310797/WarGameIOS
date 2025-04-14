module("EquipBuild", package.seeall)
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

local function CloseSelf()
	Global.CloseUI(_M)
end

function Close()
	_ui = nil
	data = nil
	currentI = nil
	targetData = nil 
	CountDown.Instance:Remove("EquipUpgrade")
	EquipData.RemoveListener(UpdateUI)
end

function Show(_data, _targetData)
	data = _data
	targetData = _targetData
	Global.OpenUI(_M)
end

function Awake()
	_ui = {}
	
	_ui.container = transform:Find("Container").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	
	_ui.left_grid = transform:Find("Container/bg_frane/bg2/Container/left/Grid"):GetComponent("UIGrid")
	_ui.left_item = ResourceLibrary.GetUIPrefab("equip/item_equipsmall")
	_ui.left_name = transform:Find("Container/bg_frane/bg2/Container/left/mid/title/Label"):GetComponent("UILabel")
	_ui.left_oriPos = {}
	_ui.left_target = transform:Find("Container/bg_frane/bg2/Container/left/mid/2")
	_ui.left_source = transform:Find("Container/bg_frane/bg2/Container/left/mid/5")
	_ui.left_oriPos[0] = _ui.left_source.position
	_ui.left_materials = {}
	_ui.left_materials[1] = transform:Find("Container/bg_frane/bg2/Container/left/mid/1")
	_ui.left_oriPos[1] = _ui.left_materials[1].position
	_ui.left_materials[2] = transform:Find("Container/bg_frane/bg2/Container/left/mid/3")
	_ui.left_oriPos[2] = _ui.left_materials[2].position
	_ui.left_materials[3] = transform:Find("Container/bg_frane/bg2/Container/left/mid/4")
	_ui.left_oriPos[3] = _ui.left_materials[3].position
	_ui.left_materials[4] = transform:Find("Container/bg_frane/bg2/Container/left/mid/6")
	_ui.left_oriPos[4] = _ui.left_materials[4].position
	_ui.left_sfx = transform:Find("Container/bg_frane/bg2/Container/left/mid/SFX").gameObject
	_ui.left_sfx:SetActive(false)
	
	_ui.btn_upgrade = transform:Find("Container/bg_frane/bg2/Container/left/button01").gameObject
	_ui.btn_upgrade:GetComponent("UIButton").enabled = false
	_ui.btn_upgrade_gold = transform:Find("Container/bg_frane/bg2/Container/left/button02").gameObject
	_ui.btn_upgrade_gold:GetComponent("UIButton").enabled = false
	_ui.upgrading = transform:Find("Container/bg_frane/bg2/Container/left/time")
	
	_ui.right_name = transform:Find("Container/bg_frane/bg2/Container/right/title1/Label"):GetComponent("UILabel")
	_ui.right_level = transform:Find("Container/bg_frane/bg2/Container/right/level/number"):GetComponent("UILabel")
	_ui.right_grid = transform:Find("Container/bg_frane/bg2/Container/right/Grid"):GetComponent("UIGrid")
	_ui.right_item = transform:Find("Container/bg_frane/bg2/item_attribute")
	EquipData.AddListener(UpdateUI)
end

function Start()
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	UpdateUI()
end

local function UseExItemFunc(useItemId , exItemid , count)
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
	for i, v in ipairs(_ui.left_equips) do
		v:GetComponent("BoxCollider").enabled = enabled
	end
	for i, v in ipairs(_ui.left_materials) do
		v:GetComponent("BoxCollider").enabled = enabled
	end
	_ui.left_source:GetComponent("BoxCollider").enabled = enabled
	_ui.btn_upgrade:GetComponent("BoxCollider").enabled = enabled
	_ui.btn_upgrade_gold:GetComponent("BoxCollider").enabled = enabled
end

local function ResetPos()
	_ui.left_source.position = _ui.left_oriPos[0]
	_ui.left_source:GetComponent("UISprite").color = Color.white
	for i, v in ipairs(_ui.left_materials) do
		v.position = _ui.left_oriPos[i]
		v:GetComponent("UISprite").color = Color.white
	end
end

local function PlayTween()
	if _ui.left_source.gameObject.activeInHierarchy then
		_ui.left_source:GetComponent("TweenPosition"):PlayForward(true)
		_ui.left_source:GetComponent("TweenAlpha"):PlayForward(true)
	end
	for i, v in ipairs(_ui.left_materials) do
		v:GetComponent("TweenPosition"):PlayForward(true)
		v:GetComponent("TweenAlpha"):PlayForward(true)
	end
end

local function PlayUpgradeSfx()
	coroutine.start(function()
		SetBtns(false)
		PlayTween()
		coroutine.wait(0.4)
        if _ui == nil then
            return
        end
		_ui.left_sfx:SetActive(true)
		coroutine.wait(1.5)
        if _ui == nil then
            return
        end
		_ui.left_sfx:SetActive(false)
		SetBtns(true)
		ResetPos()
	end)
end

local function PlayFinishSfx()
	coroutine.start(function()
		_ui.left_sfx:SetActive(true)
		coroutine.wait(1.5)
        if _ui == nil then
            return
        end
		_ui.left_sfx:SetActive(false)
	end)
end

UpdateUI = function(i)
	local list, index = EquipData.GetEquipSeries(data.BaseData.id)
	if i ~= nil then
		currentI = i
	end
	if currentI ~= nil then
		index = currentI
	end
	currentI = index
	
	local upgradingEquip = EquipData.GetUpgradingEquip()
	if upgradingEquip ~= nil then
		curStatus = true
	else
		if curStatus == true then
			PlayFinishSfx()
			index = math.min(index + 1, 5)
			currentI = index
		end
		curStatus = false
	end
	
	_ui.left_equips = {}
	local childCount = _ui.left_grid.transform.childCount
	for i, v in ipairs(list) do
		local mdata = EquipData.GetEquipDataByID(v)
		local item
		if i <= childCount then
			item = _ui.left_grid.transform:GetChild(i - 1).transform
		else
			item = NGUITools.AddChild(_ui.left_grid.gameObject, _ui.left_item.gameObject).transform
		end
		item:GetComponent("UISprite").spriteName = "bg_item" .. mdata.BaseData.quality
		item:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", mdata.BaseData.icon)
		item:Find("kuang").gameObject:SetActive(i == index)
		SetClickCallback(item.gameObject, function()
			UpdateUI(i)
		end)
		_ui.left_equips[i] = item
	end
	_ui.left_grid:Reposition()
	
	
	local mdata = EquipData.GetEquipDataByID(list[index])
	local nameColor = Global.GetLabelColorNew(mdata.BaseData.quality)
	_ui.left_name.text = nameColor[0] .. TextMgr:GetText(mdata.BaseData.name) .. nameColor[1]
	_ui.right_name.text = nameColor[0] .. TextMgr:GetText(mdata.BaseData.name) .. nameColor[1]
	_ui.left_target:GetComponent("UISprite").spriteName = "bg_item" .. mdata.BaseData.quality
	_ui.left_target:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", mdata.BaseData.icon)
	_ui.left_target:Find("effects").gameObject:SetActive(false)
	_ui.right_level.text = mdata.BaseData.charLevel
	EquipData.SetLevelColor(_ui.right_level, mdata.BaseData.charLevel)
	local hasequip, materials = EquipData.CheckMaterials(mdata.BaseData.id)
	--if targetData ~= nil then
	--	hasequip = targetData
	--end
	local pdata = EquipData.GetEquipDataByID(mdata.Previous)
	local canUpgrade = (hasequip ~= nil or pdata == nil)
	
	if pdata ~= nil then
		_ui.left_source.gameObject:SetActive(true)
		_ui.left_source:Find("effects").gameObject:SetActive(false)
		_ui.left_source:GetComponent("UISprite").spriteName = "bg_item" .. pdata.BaseData.quality
		_ui.left_source:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", pdata.BaseData.icon)
		_ui.left_source:Find("Label").gameObject:SetActive(true)
		if hasequip ~= nil then
			_ui.left_source:Find("Label"):GetComponent("UILabel").text = "1/1"
		else
			_ui.left_source:Find("Label"):GetComponent("UILabel").text = "[ff0000]0[-]/1"
		end
		SetClickCallback(_ui.left_source.gameObject, function()
			UpdateUI(currentI - 1)
		end)
	else
		_ui.left_source.gameObject:SetActive(false)
	end
	for i, v in ipairs(_ui.left_materials) do
		if materials[i] ~= nil then
			v.gameObject:SetActive(true)
			local matdata = EquipData.GetMaterialByID(materials[i].id)
			v:GetComponent("UISprite").spriteName = "bg_item" .. matdata.BaseData.quality
			v:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", matdata.BaseData.icon)
			v:Find("Label").gameObject:SetActive(true)
			local serverdata = EquipData.GetMaterialServerDataByID(materials[i].id)
			v:Find("Label"):GetComponent("UILabel").text = (serverdata ~= nil and (serverdata.data.number >= materials[i].need and serverdata.data.number or ("[ff0000]" .. serverdata.data.number .. "[-]")) or "[ff0000]0[-]") .. "/" .. materials[i].need
			local canshow = false
			if serverdata ~= nil then
				if serverdata.data.number < materials[i].need then
					canUpgrade = false
					canshow = true
				end
			else
				canUpgrade = false
				canshow = true
			end
			v:Find("effects").gameObject:SetActive(materials[i].has >= materials[i].need and canshow)
			SetClickCallback(v.gameObject, function()
				EquipCompound.Show(matdata)
			end)
		else
			v.gameObject:SetActive(false)
		end
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
			item:Find("Label"):GetComponent("UILabel").text = EquipInfo.NormalizeValue(v.Value) .. (Global.IsHeroPercentAttrAddition(v.Attype) and "%" or "")
			index = index + 1
		end
	end
	for i = index, childCount - 1 do
        GameObject.Destroy(_ui.right_grid.transform:GetChild(i).gameObject)
    end
	_ui.right_grid:Reposition()
	
	if upgradingEquip ~= nil then
		local upgradingEquipData
		if upgradingEquip.data.status == 1 then
			upgradingEquipData = EquipData.GetEquipDataByID(upgradingEquip.BaseData.id)
		else
			upgradingEquipData = EquipData.GetEquipDataByID(EquipData.GetEquipDataByID(upgradingEquip.BaseData.id).Next)
		end
		
		_ui.btn_upgrade:SetActive(false)
		_ui.btn_upgrade_gold:SetActive(false)
		_ui.upgrading.gameObject:SetActive(true)
		local nameColor = Global.GetLabelColorNew(upgradingEquipData.BaseData.quality)
		local needtime = EquipData.GetUpgradeNeedTime()
		needtime = math.ceil(needtime)
		_ui.upgrading:Find("name"):GetComponent("UILabel").text = nameColor[0] .. TextMgr:GetText(upgradingEquipData.BaseData.name) .. nameColor[1]
		_ui.upgrading:Find("Sprite"):GetComponent("UISlider").value = 1 - (upgradingEquip.data.completeTime - Serclimax.GameTime.GetSecTime()) / needtime
		_ui.upgrading:Find("Sprite/time"):GetComponent("UILabel").text = Serclimax.GameTime.SecondToString3(upgradingEquip.data.completeTime)
		CountDown.Instance:Add("EquipUpgrade", upgradingEquip.data.completeTime, CountDown.CountDownCallBack(function(t)
        	if _ui ~= nil and _ui.upgrading ~= nil and not _ui.upgrading:Equals(nil) then
            	_ui.upgrading:Find("Sprite"):GetComponent("UISlider").value = 1 - (upgradingEquip.data.completeTime - Serclimax.GameTime.GetSecTime()) / needtime
            	_ui.upgrading:Find("Sprite/time"):GetComponent("UILabel").text = t
            end
        end))
        
        local finish = function(go)
        	local num = math.floor(maincity.CaculateGoldForTime(1, upgradingEquip.data.completeTime - Serclimax.GameTime.GetSecTime()) + 0.5)
        	--MessageBox.Show(String.Format(TextMgr:GetText("equip_ui46"), num), function()
		        EquipData.RequestAccelForgeEquip()		            
        		GUIMgr:CloseMenu("CommonItemBag")
		    --end,
		    --function()
		    --end)
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
				if itemdata.type == 100 then
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
        
        SetClickCallback(_ui.upgrading:Find("speed").gameObject, function()
        	CommonItemBag.SetTittle(TextMgr:GetText("build_ui21"))
	        CommonItemBag.NotUseAutoClose()
	        CommonItemBag.NeedItemMaxValue()
	        CommonItemBag.SetItemList(maincity.GetItemExchangeListNoCommon(1), 4)
			CommonItemBag.SetUseFunc(UseExItemFunc)
			CommonItemBag.SetInitFunc(initfunc)
			CommonItemBag.SetMsgText("purchase_confirmation4", "e_today")
			GUIMgr:CreateMenu("CommonItemBag" , false)
        end)
        SetClickCallback(_ui.upgrading:Find("cancel").gameObject, function()
        	MessageBox.Show(TextMgr:GetText("equip_ui47"), function()
        		curStatus = false
	            EquipData.RequestCancelForgeEquip()
	        end,
	        function()
	        end)
        end)
	else
		CountDown.Instance:Remove("EquipUpgrade")
		_ui.btn_upgrade:SetActive(true)
		_ui.btn_upgrade_gold:SetActive(true)
		_ui.upgrading.gameObject:SetActive(false)
		EquipData.SetBtnEnable(_ui.btn_upgrade, canUpgrade, "btn_1")
		EquipData.SetBtnEnable(_ui.btn_upgrade_gold, canUpgrade, "btn_2")
		local needtime = mdata.EquipData.Time / EquipData.GetSpeedUp() / (1 + 0.01 * (AttributeBonus.CollectBonusInfo()[1096] ~= nil and AttributeBonus.CollectBonusInfo()[1096] or 0))
		needtime = math.ceil(needtime)
		_ui.btn_upgrade.transform:Find("time"):GetComponent("UILabel").text = Serclimax.GameTime.SecondToString3(needtime)
		_ui.btn_upgrade_gold.transform:Find("number"):GetComponent("UILabel").text = math.floor(maincity.CaculateGoldForTime(1, needtime) + 0.5)
		
		SetClickCallback(_ui.btn_upgrade, function()
			EquipData.RequestForgeEquip(hasequip ~= nil and hasequip.data.uniqueid or 0, mdata.BaseData.id, false, PlayUpgradeSfx)
		end)
		
		SetClickCallback(_ui.btn_upgrade_gold, function()
			local beginrequest = function()
				curStatus = true
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

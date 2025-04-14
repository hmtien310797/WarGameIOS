module("Barrack_SoldierEquip", package.seeall)
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

local _ui, _soldierId, _pos, UpdateUI, UpdateLeft, UpdateLeftDown, UpdateRightUp, UpdateRightDown

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	local param = GetParameter(go)
	if param ~= nil then
		local itemdata = TableMgr:GetItemData(tonumber(param))
		if not Tooltip.IsItemTipActive() then
			itemTipTarget = go
			Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
		else
			if itemTipTarget == go then
			    Tooltip.HideItemTip()
			else
			    itemTipTarget = go
			    Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
			end
		end
	else
		Tooltip.HideItemTip()
	end
end

local function CloseSelf()
	Tooltip.HideItemTip()
	Global.CloseUI(_M)
end

local function SetCombat()
    local combat = MainData.GetArmybordpkvalueById(_soldierId)
    _ui.combat_label.text = String.Format(TextMgr:GetText("SoldierEquip_13"), combat ~= nil and combat or 0)
end

function Close()
    _ui = nil
    soldierId = nil
    MainData.RemoveListener(SetCombat)
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
end

function Show(soldierId)
    _soldierId = soldierId
    if _soldierId == nil then
        _soldierId = 1001
    end
	Global.OpenUI(_M)
end

local function ChangeSoldier(isadd)
    if isadd then
        _soldierId = _soldierId + 1
        if _soldierId > 1004 then
            _soldierId = 1001
        end
    else
        _soldierId = _soldierId - 1
        if _soldierId < 1001 then
            _soldierId = 1004
        end
    end
    UpdateUI()
end

local function SetSelect(num)
    _pos = num
    for i, v in pairs(_ui.equip) do
        v.select:SetActive(i == num)
    end
    UpdateRightUp()
    UpdateRightDown()
end

local function SetPrice()
    local lockid = 1
    for i, v in ipairs(_ui.xilian) do
        if v.lockstatus then
            lockid = lockid + 1
        end
    end
    local pricedata = TableMgr:GetSoldierBaptizeById(lockid)
    local temp = string.split(pricedata.ItemComsume, ":")
    _ui.xilianitemid, _ui.xilianitemnum = tonumber(temp[1]), tonumber(temp[2])
    _ui.btn_xilian_label.text = _ui.xilianitemnum
    temp = string.split(pricedata.GoldConsume, ":")
    _ui.btn_xilian_gold_label.text = temp[2]
end

function Awake()
    _ui = {}
    _ui.title = transform:Find("Container/bg_frane/bg_top/bg_title_left/title"):GetComponent("UILabel")
    _ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
    _ui.btn_left = transform:Find("Container/bg_frane/button_left").gameObject
    _ui.btn_right = transform:Find("Container/bg_frane/button_right").gameObject

    _ui.xilian_icon = transform:Find("Container/bg_frane/left/xilian_icon").gameObject
    _ui.xilian_label = transform:Find("Container/bg_frane/left/xilian_icon/Label"):GetComponent("UILabel")
    _ui.soldier_name_label = transform:Find("Container/bg_frane/left/base_combat/name"):GetComponent("UILabel")
    _ui.combat_label = transform:Find("Container/bg_frane/left/base_combat/combat"):GetComponent("UILabel")

    _ui.model_root = transform:Find("Container/bg_frane/left/model")

    _ui.equip = {}
    for i = 1, 5 do
        _ui.equip[i] = {}
        _ui.equip[i].transform = transform:Find(string.format("Container/bg_frane/left/equip/%d", i))
        _ui.equip[i].texture = _ui.equip[i].transform:Find("Texture"):GetComponent("UITexture")
        _ui.equip[i].quality = _ui.equip[i].transform:GetComponent("UISprite")
        _ui.equip[i].name = _ui.equip[i].transform:Find("name"):GetComponent("UILabel")
        _ui.equip[i].lv = _ui.equip[i].transform:Find("lv/Label"):GetComponent("UILabel")
        _ui.equip[i].select = _ui.equip[i].transform:Find("select").gameObject
        SetClickCallback(_ui.equip[i].transform.gameObject, function()
            SetSelect(i)
            UpdateRightUp()
            UpdateRightDown()
        end)
    end

    _ui.right_name = transform:Find("Container/bg_frane/right/name"):GetComponent("UILabel")
    _ui.right_wenhao = transform:Find("Container/bg_frane/right/wenhao").gameObject
    _ui.right_grid = transform:Find("Container/bg_frane/right/upgrade/back/Grid"):GetComponent("UIGrid")
    _ui.right_materials = {}
    for i = 1, 4 do
        _ui.right_materials[i] = {}
        _ui.right_materials[i].transform = transform:Find(string.format("Container/bg_frane/right/upgrade/back/Grid/item%d", i))
        _ui.right_materials[i].texture = _ui.right_materials[i].transform:Find("Texture"):GetComponent("UITexture")
        _ui.right_materials[i].quality = _ui.right_materials[i].transform:GetComponent("UISprite")
        _ui.right_materials[i].num = _ui.right_materials[i].transform:Find("num_base/Label"):GetComponent("UILabel")
    end

    _ui.right_base_attr_name = transform:Find("Container/bg_frane/right/upgrade/text1/text2"):GetComponent("UILabel")
    _ui.right_base_attr_value = transform:Find("Container/bg_frane/right/upgrade/text1/text3"):GetComponent("UILabel")

    _ui.levelup_effect = transform:Find("Container/bg_frane/right/upgrade/text1/zong").gameObject
    _ui.btn_levelup = transform:Find("Container/bg_frane/right/upgrade/button").gameObject
    _ui.levelup_tishi = transform:Find("Container/bg_frane/right/upgrade/max").gameObject
    _ui.btn_xilian = transform:Find("Container/bg_frane/right/button2").gameObject
    _ui.btn_xilian_icon = transform:Find("Container/bg_frane/right/button2/gold").gameObject
    _ui.btn_xilian_label = transform:Find("Container/bg_frane/right/button2/gold/need"):GetComponent("UILabel")
    _ui.btn_xilian_gold = transform:Find("Container/bg_frane/right/button1").gameObject
    _ui.btn_xilian_gold_label = transform:Find("Container/bg_frane/right/button1/gold/need"):GetComponent("UILabel")

    _ui.xilian = {}
    for i = 1, 4 do
        _ui.xilian[i] = {}
        _ui.xilian[i].transform = transform:Find(string.format("Container/bg_frane/right/xilian/Grid/text%d", i))
        _ui.xilian[i].name_label = _ui.xilian[i].transform:GetComponent("UILabel")
        _ui.xilian[i].slider = _ui.xilian[i].transform:Find("jindu"):GetComponent("UISlider")
        _ui.xilian[i].num_label = _ui.xilian[i].transform:Find("jindu/Label"):GetComponent("UILabel")
        _ui.xilian[i].lock = _ui.xilian[i].transform:Find("lock"):GetComponent("UISprite")
        _ui.xilian[i].add = _ui.xilian[i].transform:Find("add"):GetComponent("UISprite")
        _ui.xilian[i].upeffect = _ui.xilian[i].transform:Find("jindu/green/shangshenglvse").gameObject
        _ui.xilian[i].downeffect = _ui.xilian[i].transform:Find("jindu/green/xiajianghongse").gameObject
        _ui.xilian[i].unlock = transform:Find(string.format("Container/bg_frane/right/xilian/unlock%d0", i)):GetComponent("UILabel")
        _ui.xilian[i].unlock.text = String.Format(TextMgr:GetText("SoldierEquip_20"), i * 10)
        SetClickCallback(_ui.xilian[i].transform.gameObject, function()
            _ui.xilian[i].lockstatus = not _ui.xilian[i].lockstatus
            _ui.xilian[i].lock.spriteName = "SoldierEquip_" .. (_ui.xilian[i].lockstatus and 2 or 3)
            Barrack_SoldierEquipData.GetData()[_soldierId][_pos].data.probs[i].lock = _ui.xilian[i].lockstatus and 1 or 0
            SetPrice()
        end)
    end

    AddDelegate(UICamera, "onPress", OnUICameraPress)
    MainData.AddListener(SetCombat)
end

local function ReqXilian(usemoney)
    local lockprob = {}
    local isalllock = true
    local isallmax = true
    for i, v in ipairs(_ui.xilian) do
        if v.lockstatus ~= nil then
            table.insert(lockprob, v.lockstatus and 1 or 0)
            isalllock = isalllock and v.lockstatus
            isallmax = isallmax and (v.slider.value == 1)
        end
    end
    if isalllock and isallmax then
        FloatText.Show(TextMgr:GetText("SoldierEquip_19"), Color.white)
        return
    end
    if usemoney == 0 and tonumber(_ui.xilian_label.text) < _ui.xilianitemnum then
        FloatText.Show(TextMgr:GetText("SoldierEquip_21"), Color.white)
        return
    end
    Barrack_SoldierEquipData.RequestArmyEnhanceBaptize(_soldierId, _pos, lockprob, usemoney, function()
        UpdateRightDown()
    end)
end

function Start()
    SetClickCallback(_ui.btn_close, CloseSelf)
    SetClickCallback(_ui.btn_left, function() ChangeSoldier(false) end)
    SetClickCallback(_ui.btn_right, function() ChangeSoldier(true) end)
    SetClickCallback(_ui.btn_levelup, function()
        Barrack_SoldierEquipData.RequestArmyEnhanceLevelUp(_soldierId, _pos, function()
            _ui.levelup_effect:SetActive(false)
            _ui.levelup_effect:SetActive(true)
            UpdateLeftDown()
            UpdateRightUp()
            UpdateRightDown()
        end)
    end)
    SetClickCallback(_ui.btn_xilian, function() ReqXilian(0) end)
    SetClickCallback(_ui.btn_xilian_gold, function() ReqXilian(1) end)
    SetClickCallback(_ui.right_wenhao, function()
        GOV_Help.Show(GOV_Help.HelpModeType.SoldierEquipHelp, function()
        end)
    end)
    UpdateUI()
end

UpdateUI = function()
    SetSelect(1)
    _ui.title.text = TextMgr:GetText("SoldierEquip_" .. (_soldierId - 999))
    UpdateLeft()
    UpdateLeftDown()
    UpdateRightUp()
    UpdateRightDown()
end

UpdateLeft = function()
    if _ui.model ~= nil then
        GameObject.DestroyImmediate(_ui.model)
    end
    _ui.model, _ui.soldier_name_label.text = Barrack.GetBarrackModle(_soldierId)
    _ui.model.transform:SetParent(_ui.model_root, false)
    if _soldierId == 1001 then
        _ui.model.transform.localScale = Vector3.one * 1.4
    elseif _soldierId == 1002 then
        _ui.model.transform.localScale = Vector3.one * 1.6
    elseif _soldierId == 1003 then
        _ui.model.transform.localScale = Vector3.one * 1.2
    elseif _soldierId == 1004 then
        _ui.model.transform.localScale = Vector3.one * 0.7
    end
    NGUITools.SetChildLayer(_ui.model.transform, 31)
    _ui.model:GetComponent("Animation"):Play("idle")
    local soldierMat = _ui.model:GetComponentsInChildren(typeof(UnityEngine.Renderer))
    for i = 0, soldierMat.Length - 1 do
        local v = soldierMat[i]
        v.material:SetFloat("_Brightness", 3)
        v.material:SetColor("_Color", Color.white)
    end
    Barrack_SoldierEquipData.Checked()
end

UpdateLeftDown = function()
    local data = Barrack_SoldierEquipData.GetData()[_soldierId]
    for i, v in ipairs(_ui.equip) do
        v.name.text = TextMgr:GetText(data[i].baseData.Name)
        v.quality.spriteName = "bg_item" .. (1 + tonumber(TableMgr:GetSoldierStrengthLevelById(data[i].data.level).AttributeNum))
        v.texture.mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", data[i].baseData.Icon)
        v.lv.text = "LV." .. data[i].data.level
    end
end

UpdateRightUp = function()
    local data = Barrack_SoldierEquipData.GetData()[_soldierId][_pos]
    _ui.right_name.text = TextMgr:GetText(data.baseData.Name)
    local nextconsume = TableMgr:GetSoldierStrengthLevelById(data.data.level + 1)
    if nextconsume ~= nil then
        nextconsume = nextconsume.LevelConsume
    else
        nextconsume = ""
    end
    local materials = {}
    if nextconsume ~= "" then
        if string.find(nextconsume ,";") then
            nextconsume = string.msplit(nextconsume, ";", ":")
            for i, v in ipairs(nextconsume) do
                local m = {}
                m.id = tonumber(v[1])
                m.num = tonumber(v[2])
                table.insert(materials, m)
            end
        else
            local ms = string.split(nextconsume, ":")
            local m = {}
            m.id = tonumber(ms[1])
            m.num = tonumber(ms[2])
            table.insert(materials, m)
        end
    end

    for i, v in ipairs(_ui.right_materials) do
        v.transform.gameObject:SetActive(materials[i] ~= nil)
        if materials[i] ~= nil then
            local itemData = TableMgr:GetItemData(materials[i].id)
            v.quality.spriteName = "bg_item" .. itemData.quality
            v.texture.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
            local hasnum = ItemListData.GetItemCountByBaseId(materials[i].id)
            v.num.text = (hasnum >= tonumber(materials[i].num) and ("[00ff00]" .. hasnum .. "[-]") or ("[ff0000]" .. hasnum .. "[-]")) .. "/" .. materials[i].num
            SetParameter(v.transform.gameObject, materials[i].id)
        end
    end
    _ui.right_grid:Reposition()
    _ui.btn_levelup:SetActive(#materials > 0)
    _ui.levelup_tishi:SetActive(#materials == 0)
    _ui.right_base_attr_name.text = TextMgr:GetText(data.baseData.AttributeText)
    _ui.right_base_attr_value.text = System.String.Format((data.baseData.sign == 1 and "-" or "+") .. "{0:F}" , data.baseData.BaseValue + (data.data.level - 1)* data.baseData.GrowValue * (1 + math.floor(data.data.level / 10) * tonumber(TableMgr:GetGlobalData(100228).value))) .. (Global.IsHeroPercentAttrAddition(data.baseData.AddAttr) and "%" or "")
end

local setBtnState = function(btn, type, enabled)
    local bs = btn.transform:GetComponent("UISprite")
    local bb = btn.transform:GetComponent("BoxCollider")
    bs.spriteName = enabled and ("btn_" .. type) or "btn_4"
    bb.enabled = enabled
end

UpdateRightDown = function()
    local data = Barrack_SoldierEquipData.GetData()[_soldierId][_pos]
    local maxattr = TableMgr:GetSoldierStrengthLevelById(data.data.level).AttributeMax
    local hasattr = false
    for i, v in ipairs(_ui.xilian) do
        v.transform.gameObject:SetActive(data.data.probs ~= nil and data.data.probs[i] ~= nil)
        v.unlock.gameObject:SetActive(data.data.probs == nil or data.data.probs[i] == nil)
        if data.data.probs and data.data.probs[i] then
            hasattr = true
            v.lockstatus = data.data.probs[i].lock == 1
            v.lock.spriteName = "SoldierEquip_" .. (v.lockstatus and 2 or 3)
            v.slider.value = data.data.probs[i].value / maxattr
            local singleattr = TableMgr:GetSoldierStrengthAttrById(data.data.probs[i].id)
            v.num_label.text = System.String.Format((singleattr.sign == 1 and "-" or "") .. "{0:F}" , singleattr.AttributeValue * data.data.probs[i].value) .. (Global.IsHeroPercentAttrAddition(singleattr.Attribute) and "%" or "")
            .. " / " .. System.String.Format((singleattr.sign == 1 and "-" or "") .. "{0:F}" , singleattr.AttributeValue * maxattr) .. (Global.IsHeroPercentAttrAddition(singleattr.Attribute) and "%" or "")
            local nameQuality = 1
            for ii = 1, 4 do
                if data.data.probs[i].value > TableMgr:GetSoldierStrengthLevelById(ii * 10).AttributeMax then
                    nameQuality = ii + 1
                end
            end
            local nameColor = Global.GetLabelColorNew(nameQuality)
            v.name_label.text = nameColor[0] .. TextMgr:GetText(singleattr.AttributeText) .. nameColor[1]
            v.add.gameObject:SetActive(data.updata[i] ~= 0)
            v.add.spriteName = "icon_add" .. (data.updata[i] < 0 and "un" or "")
            v.upeffect:SetActive(false)
            v.downeffect:SetActive(false)
            v.upeffect:SetActive(data.updata[i] > 0)
            v.downeffect:SetActive(data.updata[i] < 0)
            data.updata[i] = 0
        else
            v.lockstatus = nil
        end
    end
    setBtnState(_ui.btn_xilian, 1, hasattr)
    setBtnState(_ui.btn_xilian_gold, 2, hasattr)
    SetPrice()
    _ui.xilian_label.text = ItemListData.GetItemCountByBaseId(_ui.xilianitemid)
    SetParameter(_ui.xilian_icon, _ui.xilianitemid)
    SetCombat()
end

function Update()
    local topMenu = GUIMgr:GetTopMenuOnRoot()
    if topMenu.name == "Barrack_SoldierEquip" then
        if _ui.model and not _ui.model.activeInHierarchy then
            _ui.model:SetActive(true)
            _ui.model:GetComponent("Animation"):Play("idle")
        end
    else
        if _ui.model and _ui.model.activeInHierarchy then
            _ui.model:SetActive(false)
        end
    end
end
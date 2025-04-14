module("Barrack_Soldier", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local UIAnimMgr = Global.GUIAnimMgr

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local SetDragCallback = UIUtil.SetDragCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String

local _ui, UpdateUI
local SoldierTable

local function CloseSelf()
	Global.CloseUI(_M)
end

function Close()
	_ui = nil
	MainCityUI.RemoveMenuTarget()
end

function Show()
	Global.OpenUI(_M)
end

function SetUpTable(data)
	if SoldierTable == nil then
		SoldierTable = {}
	end
	if SoldierTable[data.BarrackId] == nil then
		SoldierTable[data.BarrackId] = {}
	end
	if data.SoldierTab == 2 then
		if SoldierTable[data.BarrackId][data.SoldierId] == nil then
			SoldierTable[data.BarrackId][data.SoldierId] = {}
		end
		SoldierTable[data.BarrackId][data.SoldierId][data.Grade] = data
	end
end

local function OnModelClick()
	if _ui.models == nil or _ui.models[_ui.index] == nil then
		return
	end
	if _ui.models[_ui.index].anim:get_Item("show") ~= nil then
	    if not _ui.models[_ui.index].anim:IsPlaying("show") then
	        _ui.models[_ui.index].anim:PlayQueued("show",UnityEngine.QueueMode.PlayNow)
            _ui.models[_ui.index].anim:PlayQueued("idle",UnityEngine.QueueMode.CompleteOthers)
        end
	else
	    if not _ui.models[_ui.index].anim:IsPlaying("idle") then
	        _ui.models[_ui.index].anim:Play("idle")
        end
    end
end

local function OnModelDrag(go, delta)
	if _ui.models == nil or _ui.models[_ui.index] == nil then
		return
	end
	_ui.models[_ui.index].go.transform.localEulerAngles = Vector3(0, _ui.models[_ui.index].go.transform.localEulerAngles.y - delta.x,0)
end

function Awake()
	_ui = {}
	_ui.container = transform:Find("Container").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	_ui.title = transform:Find("Container/bg_frane/bg_top/bg_title_left/title"):GetComponent("UILabel")
	_ui.soldiername = transform:Find("Container/bg_frane/name/Label01"):GetComponent("UILabel")
	_ui.soldierunlock = transform:Find("Container/bg_frane/name/Label02"):GetComponent("UILabel")
	
	_ui.cost = transform:Find("Container/bg_frane/left/1/number"):GetComponent("UILabel")
	_ui.cost.text = 0
	_ui.population = transform:Find("Container/bg_frane/left/2/number"):GetComponent("UILabel")
	_ui.population.text = 0
	_ui.att = transform:Find("Container/bg_frane/left/3/number"):GetComponent("UILabel")
	_ui.att.text = 0
	_ui.attslider = transform:Find("Container/bg_frane/left/3/red"):GetComponent("UISlider")
	_ui.def = transform:Find("Container/bg_frane/left/4/number"):GetComponent("UILabel")
	_ui.def.text = 0
	_ui.defslider = transform:Find("Container/bg_frane/left/4/red"):GetComponent("UISlider")
	_ui.hp = transform:Find("Container/bg_frane/left/5/number"):GetComponent("UILabel")
	_ui.hp.text = 0
	_ui.hpslider = transform:Find("Container/bg_frane/left/5/red"):GetComponent("UISlider")
	_ui.desc = transform:Find("Container/bg_frane/right/text"):GetComponent("UILabel")
	
	_ui.btn_left = transform:Find("Container/bg_frane/button_left").gameObject
	_ui.btn_right = transform:Find("Container/bg_frane/button_right").gameObject
	
	_ui.list3d = transform:Find("Container/bg_frane/Texture/Camera/povit/list")
	_ui.camera3d = transform:Find("Container/bg_frane/Texture/Camera"):GetComponent("Camera")
	_ui.touch3d = transform:Find("Container/bg_frane/Texture").gameObject
end

function Start()
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	SetClickCallback(_ui.touch3d, OnModelClick)
	SetDragCallback(_ui.touch3d, OnModelDrag)
	local btype = maincity.GetCurrentBuildingData().data.type
	if btype == 24 then
		_ui.scale = 0.4
		_ui.height = 0--.15
	elseif btype == 21 then
		_ui.scale = 1.15
	elseif btype == 23 then
		_ui.scale = 0.9
	else
		_ui.scale = 1
	end
	_ui.height = 0
	transform:Find("Container/bg_frane/bg_top/bg_title_left/title"):GetComponent("UILabel").text = TextMgr:GetText(maincity.GetCurrentBuildingData().buildingData.name)
	local armyList = UnlockArmyData.GetArmyList()
	local unlockedLit = {}
	for i, v in ipairs(armyList) do
    	local armyData = TableMgr:GetUnitData(v)
    	if armyData ~= nil then
    		local soldier = {}
    		soldier.id = armyData._unitArmyType
    		soldier.level = armyData._unitArmyLevel
    		table.insert(unlockedLit, soldier)
    	end
    end
    _ui.soldiers = {}
    for i, v in pairs(SoldierTable[btype]) do
    	local has = false
    	for ii, vv in ipairs(unlockedLit) do
    		if i == vv.id then
    			has = true
    			local s = {}
    			s.data = v[vv.level]
    			s.unlock = true
    			table.insert(_ui.soldiers, s)
    		end
    	end
    	if not has then
    		local s = {}
    		s.data = v[1]
    		s.unlock = false
    		table.insert(_ui.soldiers, s)
    	end
    end
    
    _ui.index = 1
    _ui.max = #_ui.soldiers
    _ui.lastindex = 1
    
    SetClickCallback(_ui.btn_left, function()
    	_ui.index = _ui.index - 1
    	_ui.index = math.max(_ui.index, 1)
    end)
    
    SetClickCallback(_ui.btn_right, function()
    	_ui.index = _ui.index + 1
    	_ui.index = math.min(_ui.index, _ui.max)
    end)
    
    UpdateUI()
    
    _ui.models = {}
    coroutine.start(function()
    	for i, v in ipairs(_ui.soldiers) do
    		local model = {}
    		model.go = ResourceLibrary:GetUnitInstance4UI(TableMgr:GetUnitData(Barrack.GetAramInfo(v.data.SoldierId, v.data.Grade).UnitID)._unitPrefab)
    		model.go.transform:SetParent(_ui.list3d, false)
    		model.go.transform.localScale = Vector3.one * _ui.scale
    		model.go.transform.localEulerAngles = Vector3(0, 135, 0)
    		model.go.transform.localPosition = Vector3(2 * (i - 1), _ui.height, 2 - math.cos(1 * (i - 1)) * 2)
    		NGUITools.SetChildLayer(model.go.transform, 29)
    		model.mat = model.go:GetComponentInChildren(typeof(UnityEngine.Renderer)).material
    		if math.abs(1 - i) < 1.5 then
	    		if v.unlock then
	    			model.mat:SetFloat("_Brightness", 0.7 + 0.9 * (1 - Mathf.Clamp(math.abs(1 - i), 0, 1)))
	    			model.mat:SetColor("_Color", Color.white)
	    		else
	    			model.mat:SetFloat("_Brightness", 1)
	    			model.mat:SetColor("_Color", Color(0.3,0.3,0.3,1))
	    		end
	    	else
	    		model.mat:SetFloat("_Brightness", 0)
	    	end
    		model.anim = model.go:GetComponent("Animation")
    		if i == 1 then
    			model.anim:PlayQueued("show",UnityEngine.QueueMode.PlayNow)
    			model.anim:PlayQueued("idle",UnityEngine.QueueMode.CompleteOthers)
    		else
    			model.anim:Play("idle")
    			coroutine.step()
    			model.anim:Stop()
    		end
    		table.insert(_ui.models, model)
    		coroutine.step()
    	end
    end)
end

function LateUpdate()
	local lastx = _ui.list3d.localPosition.x
	_ui.list3d.localPosition = Vector3(Mathf.Lerp(lastx, -2 * (_ui.index - 1), Time.deltaTime * 5), 0, 0)
	if math.abs(lastx - _ui.list3d.localPosition.x) > 0.01 then 
		local index = 1 - _ui.list3d.localPosition.x / 2
		for i, v in ipairs(_ui.soldiers) do
			if _ui.models[i] ~= nil then
				_ui.models[i].go.transform.localEulerAngles = Vector3(0, Mathf.Lerp(_ui.models[i].go.transform.localEulerAngles.y, 135, 45 * Time.deltaTime),0)
				_ui.models[i].go.transform.localPosition = Vector3(2 * (i - 1), _ui.height, 2 - math.cos(1 * (index - i)) * 2)
				if math.abs(index - i) < 1.5 then
					if v.unlock then
	    				_ui.models[i].mat:SetFloat("_Brightness", 0.7 + 0.9 * (1 - Mathf.Clamp(math.abs(index - i), 0, 1)))
	    				_ui.models[i].mat:SetColor("_Color", Color.white)
		    		else
		    			_ui.models[i].mat:SetFloat("_Brightness", 1)
		    			_ui.models[i].mat:SetColor("_Color", Color(0.3,0.3,0.3,1))
		    		end
		    	else
		    		_ui.models[i].mat:SetFloat("_Brightness", Mathf.Clamp(2 - math.abs(index - i), 0, 1))
		    	end
			end
		end
		index = math.floor(index + 0.5)
		if index ~= _ui.lastindex then
			_ui.lastindex = index
			UpdateUI()
		end
	end
	if _ui.attslider.value ~= _ui.atttarget then
		_ui.attslider.value = _ui.attslider.value + _ui.attspeed * Time.deltaTime
		if math.abs(_ui.attslider.value - _ui.atttarget) < math.abs(_ui.attspeed) * Time.deltaTime * 2 then
			_ui.attslider.value = _ui.atttarget
		end
	end
	if _ui.defslider.value ~= _ui.deftarget then
		_ui.defslider.value = _ui.defslider.value + _ui.defspeed * Time.deltaTime
		if math.abs(_ui.defslider.value - _ui.deftarget) < math.abs(_ui.defspeed) * Time.deltaTime * 2 then
			_ui.defslider.value = _ui.deftarget
		end
	end
	if _ui.hpslider.value ~= _ui.hptarget then
		_ui.hpslider.value = _ui.hpslider.value + _ui.hpspeed * Time.deltaTime
		if math.abs(_ui.hpslider.value - _ui.hptarget) < math.abs(_ui.hpspeed) * Time.deltaTime * 2 then
			_ui.hpslider.value = _ui.hptarget
		end
	end
end

UpdateUI = function()
	if _ui.index == 1 then
		_ui.btn_left:SetActive(false)
		_ui.btn_right:SetActive(true)
	elseif _ui.index == _ui.max then
		_ui.btn_right:SetActive(false)
		_ui.btn_left:SetActive(true)
	else
		_ui.btn_left:SetActive(true)
		_ui.btn_right:SetActive(true)
	end
	OnModelClick()
	
	if _ui.models ~= nil then
		for i, v in ipairs(_ui.models) do
			if i ~= _ui.index then
				_ui.models[i].anim:Stop()
			end
		end
	end
	
	local data = _ui.soldiers[_ui.index].data
	local sdata = TableMgr:GetUnitData(Barrack.GetAramInfo(_ui.soldiers[_ui.index].data.SoldierId, _ui.soldiers[_ui.index].data.Grade).UnitID)
	_ui.soldiername.text = TextUtil.GetUnitName(sdata)
	_ui.soldierunlock.text = _ui.soldiers[_ui.index].unlock and "" or String.Format(TextMgr:GetText("common_ui15"), TextMgr:GetText(TableMgr:GetBattleData(data.BattleId).nameLabel))
	
	UIAnimMgr:IncreaseUILabelTextAnim(_ui.cost , tonumber(_ui.cost.text) , sdata._unitNeedBullet)
	UIAnimMgr:IncreaseUILabelTextAnim(_ui.population , tonumber(_ui.population.text) , sdata._unitPopulation)
	
	UIAnimMgr:IncreaseUILabelTextAnim(_ui.att , tonumber(_ui.att.text) , data.Attack)
	_ui.atttarget = data.Attack / 300
	_ui.attspeed = (_ui.atttarget - _ui.attslider.value)
	UIAnimMgr:IncreaseUILabelTextAnim(_ui.def , tonumber(_ui.def.text) , data.fakeArmo)
	_ui.deftarget = data.fakeArmo / 100
	_ui.defspeed = (_ui.deftarget - _ui.defslider.value)
	UIAnimMgr:IncreaseUILabelTextAnim(_ui.hp , tonumber(_ui.hp.text) , data.Hp)
	_ui.hptarget = data.Hp / 2500
	_ui.hpspeed = (_ui.hptarget - _ui.hpslider.value)
	
	_ui.desc.text = TextMgr:GetText(data.SoldierDes)
end

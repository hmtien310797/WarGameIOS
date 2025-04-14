module("BuildingShowInfoUI", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr =	Global.GTextMgr
local ResourceLibrary =	Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetDragOverCallback =	UIUtil.SetDragOverCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate =	UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools	= NGUITools
local GameObject = UnityEngine.GameObject
local FloatText	= FloatText
local AudioMgr = Global.GAudioMgr

local canUpdate
local buildingList
local buildingshowroot
local buildinginforoot
local buildinginforootsize
local mainCamera
local ParadeGroundShowGroup
local ParadeGroundShowGroupNumRoot

local isOpened = false
local needreposition

function SetReposition()
	needreposition = true
end

function IsOpened()
	return isOpened
end

local function GetBuildingList()
	buildingList = maincity.GetBuildingList()
end

function MakeBuildTime(_building)
	if transform ==	nil	or transform:Equals(nil) then
		return
	end
	local transition = _building.transition
	local timer	= {}
	timer.beginTime	= _building.data.createtime	~= nil and _building.data.createtime or	0
	timer.time = _building.data.donetime + 2
	timer.icon = "time_icon4"
	timer.step = 0
	timer.type = 1
	transition.transitionStruct:SetTime(timer)
end

function MakeBuffTime(_building)
	if transform ==	nil	or transform:Equals(nil) then
		return
	end
	local transition = _building.transition
	local curBuf = BuffData.GetBuildingBuff(_building.data.uid)
	if curBuf ~= nil then
		local timer	= {}
		timer.time = curBuf.time
		timer.icon = curBuf.buffIcon
		timer.step = 0
		timer.type = 4
		transition.transitionStruct:SetTime(timer)
	else
		transition.transitionStruct:RemoveTime(4)
	end
end

function MakeTechTime(_building)
	if transform ==	nil	or transform:Equals(nil) then
		return
	end
	local transition = _building.transition
	local tech = Laboratory.GetCurUpgradeTech()
	if tech	~= nil then
		MainCityQueue.UpdateSimpleQueue();
		local timer	= {}
		timer.beginTime	= tech.Info.beginTime ~= nil and tech.Info.beginTime or	0
		timer.time = tech.Info.endtime
		timer.icon = "time_icon5"
		timer.step = 0
		timer.type = 2
		transition.transitionStruct:SetTime(timer)
	else
		transition.transitionStruct:RemoveTime(2)
	end
end

function MakeBarrackTime(_building)
	if transform ==	nil	or transform:Equals(nil) then
		return
	end
	upgrading =	Barrack.GetTrainInfo(_building.data.type)
	local transition = _building.transition
	transition.timerList[3]	= nil
	if upgrading ~=	nil	then 
		local timer	= {}
		timer.time = upgrading.TimeSec
		timer.icon = "time_icon9"
		timer.step = 0
		timer.type = 3
		transition.transitionStruct:SetTime(timer)
	else
		transition.transitionStruct:RemoveTime(3)
	end
end

function MakeHospitalTime(_building, _targettime, callback , icon)
	if transform ==	nil	or transform:Equals(nil) then
		return
	end
	local transition = _building.transition
	if _targettime ~= nil then
		local timer	= {}
		timer.time = _targettime
		timer.icon = icon
		timer.step = 0
		timer.type = 5
		transition.transitionStruct:SetTime(timer)
	else
		transition.transitionStruct:RemoveTime(5)
	end
end

function MakeHeroAppoint(_building)
	if transform ==	nil	or transform:Equals(nil) then
		return
	end
	if MainCityUI.CanSHowHeroPoint() then
		local transition = _building.transition
		local needshow = BuildingData.NeedAppointHero(_building.buildingData)
		if transition.hero == nil or transition.hero:Equals(nil) then
			return
		end
		if needshow then
			transition.needshowhero = true
			transition.hero:SetActive(true)
			transition.hero_collider.enabled = true
			SetClickCallback(transition.hero_collider.gameObject, function()
				HeroAppointUI.Show(_building.buildingData.type)
			end)
		else
			transition.needshowhero = nil
			transition.hero:SetActive(false)
			transition.hero_collider.enabled = false
		end
	end
end

function RemoveTranstion(_building)
	if transform ==	nil	or transform:Equals(nil) then
		return
	end
	local transition = _building.transition
	if transition ~= nil then
		if transition.colliderroottransform ~= nil then
			GameObject.Destroy(transition.colliderroottransform.gameObject)
		end
		if transition.showroottransform	~= nil then
			GameObject.Destroy(transition.showroottransform.gameObject)
		end
		_building.transition = nil
	end
end

local function UpdateTransitionPos()
	if buildinginforootsize == nil then
		return
	end
	for	i, v in	pairs(buildingList)	do
		if v.transition	~= nil then
			local transition = v.transition
			if transform ~=	nil	and	not	transform:Equals(nil) and mainCamera ~= nil and not mainCamera:Equals(nil) then
				if transition.free_icon ~= nil and not transition.free_icon:Equals(nil) then
					local position = mainCamera:WorldToViewportPoint(transition.free_icon.position) - (Vector3.one * 0.5)
					local dis =	Vector3.Distance(transition.free_icon.position, mainCamera.transform.position)
					local scale	= 105 /	dis
					transition.scale = scale
					local pos =	Vector3(position.x * buildinginforootsize.width, position.y	* buildinginforootsize.height, 0)
					transition.transitionStruct:UpdateCollider(pos, Vector3.one * scale)
				end
				if transition.buildsfx ~= nil and not transition.buildsfx:Equals(nil) then
					local position = mainCamera:WorldToViewportPoint(transition.buildsfx_icon.position) - (Vector3.one * 0.5)
					local dis =	Vector3.Distance(transition.buildsfx_icon.position, mainCamera.transform.position)
					local scale	= 105 /	dis
					local pos =	Vector3(position.x * buildinginforootsize.width, position.y	* buildinginforootsize.height, 0)
					transition.sfx_collider.transform.localPosition = pos
					transition.sfx_collider.transform.localScale = Vector3.one * scale
				end
				if transition.HasPrisoner then
					local position = mainCamera:WorldToViewportPoint(transition.jianyu_touxiang.transform.position) - (Vector3.one * 0.5)
					local dis =	Vector3.Distance(transition.jianyu_touxiang.transform.position, mainCamera.transform.position)
					local scale	= 105 /	dis
					local pos =	Vector3(position.x * buildinginforootsize.width, position.y	* buildinginforootsize.height, 0)
					transition.jianyu_collider.transform.localPosition = pos
					transition.jianyu_collider.transform.localScale = Vector3.one * scale
				end
				if transition.seNeedShow then
					local position = mainCamera:WorldToViewportPoint(transition.sequip_touxiang.transform.position) - (Vector3.one * 0.5)
					local dis =	Vector3.Distance(transition.sequip_touxiang.transform.position, mainCamera.transform.position)
					local scale	= 105 /	dis
					local pos =	Vector3(position.x * buildinginforootsize.width, position.y	* buildinginforootsize.height, 0)
					transition.sequip_collider.transform.localPosition = pos
					transition.sequip_collider.transform.localScale = Vector3.one * scale
				end
				if transition.IsNeedRepair then
					local position = mainCamera:WorldToViewportPoint(transition.jianyu_touxiang.transform.position) - (Vector3.one * 0.5)
					local dis =	Vector3.Distance(transition.jianyu_touxiang.transform.position, mainCamera.transform.position)
					local scale	= 105 /	dis
					local pos =	Vector3(position.x * buildinginforootsize.width, position.y	* buildinginforootsize.height, 0)
					transition.jianyu_collider.transform.localPosition = pos
					transition.jianyu_collider.transform.localScale = Vector3.one * scale
				end
				if transition.IsMobaShow then
					local position = mainCamera:WorldToViewportPoint(transition.moba_touxiang.transform.position) - (Vector3.one * 0.5)
					local dis =	Vector3.Distance(transition.moba_touxiang.transform.position, mainCamera.transform.position)
					local scale	= 105 /	dis
					local pos =	Vector3(position.x * buildinginforootsize.width, position.y	* buildinginforootsize.height, 0)
					transition.moba_collider.transform.localPosition = pos
					transition.moba_collider.transform.localScale = Vector3.one * scale
				end
			end
		end
		if v.unlock_collider ~= nil then
			local position = mainCamera:WorldToViewportPoint(v.unlockUI_icon.position)	- (Vector3.one * 0.5)
			local dis =	Vector3.Distance(v.unlockUI_icon.position, mainCamera.transform.position)
			local scale	= 105 /	dis
			local pos =	Vector3(position.x * buildinginforootsize.width, position.y * buildinginforootsize.height, 0)
			v.unlock_collider.transform.localPosition = pos
			v.unlock_collider.transform.localScale = Vector3.one * scale
		end
		if v.unlockLand_collider ~= nil then
			local position = mainCamera:WorldToViewportPoint(v.unlockLandUI_icon.position)	- (Vector3.one * 0.5)
			local dis =	Vector3.Distance(v.unlockLandUI_icon.position, mainCamera.transform.position)
			local scale	= 105 /	dis
			local pos =	Vector3(position.x * buildinginforootsize.width, position.y * buildinginforootsize.height, 0)
			v.unlockLand_collider.transform.localPosition = pos
			v.unlockLand_collider.transform.localScale = Vector3.one * scale
		end
		if v.hospital_collider ~= nil and not v.hospital_collider:Equals(nil) then
			local position = mainCamera:WorldToViewportPoint(v.hospitalUI_icon.transform.position) - (Vector3.one * 0.5)
			local dis =	Vector3.Distance(v.land.transform.position, mainCamera.transform.position)
			local scale	= 105 /	dis
			local pos =	Vector3(position.x * buildinginforootsize.width, position.y * buildinginforootsize.height, 0)
			v.hospital_collider.transform.localPosition = pos
			v.hospital_collider.transform.localScale = Vector3.one * scale
		end
	end
end

local function CheckHospital(_building)
	if _building.buildingData.logicType	== 10 and _building.buildingData.showType == 3 then
		local transition = _building.transition
		if ArmyListData.CanCureArmy() == 1 then
			transition.needshowhospital = true
			if _building.hospitalUI == nil or _building.hospitalUI:Equals(nil) then
				_building.hospitalUI = ResourceLibrary.GetUIInstance("BuildingCommon/yiliao")
				_building.hospitalUI_icon = _building.hospitalUI.transform:Find("yiliao/chuizi")
				_building.hospital_collider = ResourceLibrary.GetUIInstance("BuildingCommon/BuildingBubbleCollider"):GetComponent("BoxCollider")
				_building.hospitalUI.transform:SetParent(transition.showroottransform, false)
				_building.hospitalUI.transform.localEulerAngles = Vector3(45, 0, 0)
				_building.hospitalUI.transform.position = _building.land.transform.position
				_building.hospitalUI.transform.localPosition = _building.hospitalUI.transform.localPosition + Vector3(0, _building.transition.h, 0)
				_building.hospital_collider.transform:SetParent(transition.colliderroottransform, false)
				SetClickCallback(_building.hospital_collider.gameObject, function(go)
					Hospital.SetBuild(_building)
					GUIMgr:CreateMenu("Hospital", false)
				end)
			end
		else
			transition.needshowhospital = nil
			if _building.hospitalUI ~= nil and not _building.hospitalUI:Equals(nil) then
				GameObject.DestroyImmediate(_building.hospitalUI.gameObject)
				GameObject.DestroyImmediate(_building.hospital_collider.gameObject)
				_building.hospitalUI = nil
				_building.hospital_collider = nil
				_building.hospitalUI_icon = nil
			end
		end
	end
end

local function UpdateTransition()
	GetBuildingList()
	for	i, v in	pairs(buildingList)	do
		if v.transition	~= nil then
			local transition = v.transition
			transition.transitionStruct:UpdateTime()
			CheckHospital(v)
		end
	end
	if needreposition then
		UpdateTransitionPos()
		needreposition = false
	end
end

local function GetResPressCallback(go, isPressed)
	if isPressed then
		local name = go.transform.parent.parent.name
		local params = name:split("_")
		local getResId = params[2]
		--print("getResId =- " .. getResId)
		MainCityUI.GetBuildResource(tonumber(getResId) , go.gameObject.transform)
		maincity.SetisGetResBubble(true)
	end
end

local function OnDragGetRes(obj)
	if maincity.GetisGetResBubble()	then
		local name = obj.transform.parent.parent.gameObject.name
		local params = name:split("_")
		local getResId = params[2]
		--print("DraggetResId =- " .. getResId)
		MainCityUI.GetBuildResource(tonumber(getResId) , obj.transform.parent.gameObject.transform)
	end
end

local function CheckResBuild(build)
	local result = {}
	result.showIcon	= false
	--[[
	if build.buildingData.logicType	== 10 and build.buildingData.showType == 8 then
		local passtime = Serclimax.GameTime.GetSecTime() - build.data.gathertime 
		if passtime	> 60 then
			result.showIcon	= true
		end
		result.pressCallback = GetResPressCallback
		result.dragCallback	= OnDragGetRes
	else
		--]]
	if build.buildingData.logicType	== 10 and build.buildingData.showType == 3 then
		if ArmyListData.CanCureArmy() == 1 then
			result.showIcon	= true
		elseif ArmyListData.CanCureArmy() == 2 then
			
		end
		result.pressCallback = function()
			Hospital.SetBuild(build)
			GUIMgr:CreateMenu("Hospital", false)
		end
		result.dragCallback	= nil
	end
	return result
end

local function UpdateParadeGroundGroup()
	if ParadeGroundShowGroup ==	nil	then
		return
	end
	for	_, v in	pairs(ParadeGroundShowGroup) do
		if v.showui	== nil or v.showui:Equals(nil) then
			v.showui = ResourceLibrary.GetUIInstance("BuildingCommon/UnitName")
			v.showui.gameObject:SetActive(false)
			v.numui	= v.showui.transform:Find("bg_title/text"):GetComponent("UILabel")
		end
		v.numui.text = v.num
		if transform ~=	nil	and	not	transform:Equals(nil) and v.transform ~= nil and not v.transform:Equals(nil) then
			local dis =	Vector3.Distance(v.transform.position, mainCamera.transform.position)
			local scale	= 105 /	dis
			local position = mainCamera:WorldToViewportPoint(v.transform.position) - (Vector3.one *	0.5)
			local pos =	Vector3(position.x * buildinginforootsize.width, position.y * buildinginforootsize.height + 50	* scale, 0)
			v.showui.transform:SetParent(transform,	false)
			v.showui.transform.localPosition = pos
			v.showui.transform.localScale =	Vector3.one	* scale
		end
	end
end

function Awake()
	
end

function Start()
	
end

function SetUnlock(_building)
    if _building.unlockUI == nil or _building.unlockUI:Equals(nil) then
		_building.unlockUI = ResourceLibrary.GetUIInstance("BuildingCommon/dianjiquan")
		_building.unlockUI_icon = _building.unlockUI.transform:Find("dianjiquan/chuizi")
        _building.unlock_collider = ResourceLibrary.GetUIInstance("BuildingCommon/BuildingBubbleCollider"):GetComponent("BoxCollider")
		_building.unlockUI.transform:SetParent(buildingshowroot, false)
		_building.unlockUI.transform.position = _building.land.transform.position
		_building.unlockUI.transform.localScale = Vector3.one * 7.7
		--_building.unlockUI.transform.localEulerAngles = Vector3(45, 0, 0)
		_building.unlock_collider.transform:SetParent(transform, false)
        SetClickCallback(_building.unlock_collider.gameObject, function(go)
            BuildingLocked.SetData(_building)
			BuildingLocked.SetBuildCallback(function()
				GameObject.DestroyImmediate(_building.unlockUI.gameObject)
                GameObject.DestroyImmediate(_building.unlock_collider.gameObject)
				_building.unlockUI = nil
				_building.unlock_collider = nil
                maincity.BuildBuilding(_building.unlockData.id,	0, 1, function ()
                    maincity.GetBuildingListData()
                end)
            end)
            GUIMgr:CreateMenu("BuildingLocked",	false)
        end)
    end
end

function SetUnlockLand(_building)
    if _building.unlockLandUI == nil or _building.unlockLandUI:Equals(nil) then
		_building.unlockLandUI = ResourceLibrary.GetUIInstance("BuildingCommon/dianjiquan")
		_building.unlockLandUI_icon = _building.unlockLandUI.transform:Find("dianjiquan/chuizi")
        _building.unlockLand_collider = ResourceLibrary.GetUIInstance("BuildingCommon/BuildingBubbleCollider"):GetComponent("BoxCollider")
		_building.unlockLandUI.transform:SetParent(buildingshowroot, false)
		_building.unlockLandUI.transform.position = _building.land.transform.position
		_building.unlockLandUI.transform.localScale = Vector3.one * 7.7
		--_building.unlockLandUI.transform.localEulerAngles = Vector3(45, 0, 0)
		_building.unlockLand_collider.transform:SetParent(transform, false)
        SetClickCallback(_building.unlockLand_collider.gameObject, function(go)
            BuildingLocked.SetData(_building)
			BuildingLocked.SetBuildCallback(function()
				GameObject.DestroyImmediate(_building.unlockLandUI.gameObject)
                GameObject.DestroyImmediate(_building.unlockLand_collider.gameObject)
				_building.unlockLandUI = nil
				_building.unlockLand_collider = nil
                local pos =	_building.land.transform.position
                maincity.UnlockLand(_building.unlockLandid, function(msg)
                    maincity.GetBuildingListData()
                    AudioMgr:PlayUISfx("SFX_building_born",	1, false)
                    local _fx =	ResourceLibrary:GetEffectInstance("BornBuildBig")
                    _fx.transform.position = pos
                    GameObject.Destroy(_fx.gameObject,3)
                end)
            end)
            GUIMgr:CreateMenu("BuildingLocked",	false)
        end)
    end
end

function Close()
	isOpened = false
	if buildingshowroot and not buildingshowroot:Equals(nil) then
		GameObject.Destroy(buildingshowroot.gameObject)
		buildingshowroot = nil
	end
	if gameObject then
		if not gameObject:Equals(nil) then
			GameObject.Destroy(gameObject)
		end
	end
	buildinginforoot = nil
	buildinginforootsize = nil
	canUpdate =	false
	-- HeroListData.RemoveListener(RefreshHero)
	EventDispatcher.UnbindAll(_M)
	MoneyListData.RemoveListener(RefreshUpgrade)
	maincity.OnCameraMove = nil
	CountDown.Instance:Remove("buildingShowInfoUI")
end

local function MakeHospitalInfo(_building)
	if _building.buildingData.logicType	== 10 and _building.buildingData.showType == 3 then
		Hospital.CheckCureInfo(_building)
	end
end

function MakeTransition(_building)
	if transform ==	nil	or transform:Equals(nil) or _building == nil or _building.land == nil or _building.land:Equals(nil) or not GUIMgr:IsMainCityUIOpen() then
		return
	end
	local transitionStruct
	if _building.transition == nil then
		transitionStruct = BuildTransition(_building, buildingshowroot, transform, buildinginforootsize)
	else
		transitionStruct = _building.transition.transitionStruct
	end
	transitionStruct:MakeUpgradeMark()
	MakeBuildTime(_building)
	MakeBuffTime(_building)
	if _building.data.type == 6	then
		MakeTechTime(_building)
	end
	if _building.data.type == 21 or	_building.data.type	== 22 or _building.data.type ==	23 or _building.data.type == 24	 or	_building.data.type	== 27 then
		MakeBarrackTime(_building)
	end
	MakeHeroAppoint(_building)
end

local function MakeAllWidget()
	for	i, v in	pairs(buildingList)	do
		if v.data ~= nil then
			MakeTransition(v)
		else
			if v.canUnlock ~= nil and v.canUnlock then
				SetUnlock(v)
			end
			if v.unlockLand	~= nil and v.unlockLand	then
				SetUnlockLand(v)
			end
		end
	end
end

function Refresh()
	if transform ==	nil	or transform:Equals(nil) then
		Show()
		return
	end
	gameObject:SetActive(true)
	buildingshowroot.gameObject:SetActive(true)
	GetBuildingList()
	if buildingList	== nil then
		return
	end
	for	i, v in	pairs(buildingList)	do
		if v.data ~= nil then
			if v.transition == nil then
				MakeTransition(v)
			end
			v.transition.transitionStruct:MakeUpgradeMark()
			MakeHeroAppoint(v)
		else
			if v.canUnlock ~= nil and v.canUnlock then
				SetUnlock(v)
			end
			if v.unlockLand	~= nil and v.unlockLand	then
				SetUnlockLand(v)
			end
		end
	end
end

function RefreshUpgrade()
	if transform ==	nil	or transform:Equals(nil) then
		return
	end
	GetBuildingList()
	if buildingList	== nil then
		return
	end
	for	i, v in	pairs(buildingList)	do
		if v.data ~= nil and v.transition ~= nil then
			v.transition.transitionStruct:MakeUpgradeMark()
		end
	end
end

function RefreshHero()
	if transform ==	nil	or transform:Equals(nil) then
		return
	end
	GetBuildingList()
	if buildingList	== nil then
		return
	end
	for	i, v in	pairs(buildingList)	do
		if v.data ~= nil then
			MakeHeroAppoint(v)
		end
	end
end

function Show()
	print(gameObject, gameObject and not gameObject:Equals(nil))
	if gameObject ~= nil and not gameObject:Equals(nil)	then
		gameObject:SetActive(true)
	else
		go = ResourceLibrary.GetUIInstance("MainCity/BuildingShowInfoUI")
		go:AddComponent(typeof(LuaBehaviour))
	end
	mainCamera = maincity.GetMainCamera()
	canUpdate =	true
	buildinginforoot = MainCityUI.GetBuildingInfoRoot()
	transform:SetParent(buildinginforoot, false)
	buildinginforootsize = buildinginforoot:GetComponent("UIWidget")
	if buildingshowroot == nil or buildingshowroot:Equals(nil) then
		local showroot = GameObject()
		showroot.name = "Transition"
		showroot:AddComponent(typeof(UIPanel))
		NGUITools.SetLayer(showroot, 27)
		buildingshowroot = showroot.transform
		buildingshowroot.localEulerAngles = Vector3(0, 180, 0)
		buildingshowroot.localScale = Vector3(0.13, 0.13, 0.13)
	else
		buildingshowroot.gameObject:SetActive(true)
	end
	NGUITools.SetLayer(gameObject, buildinginforoot.gameObject.layer)
	GetBuildingList()
	MakeAllWidget()
	--transform:GetComponent("UIPanel").depth	= 0
	-- HeroListData.RemoveListener(RefreshHero)
	-- HeroListData.AddListener(RefreshHero)

	EventDispatcher.Bind(GeneralData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.DELAYED, RefreshHero)

	MoneyListData.RemoveListener(RefreshUpgrade)
	MoneyListData.AddListener(RefreshUpgrade)
	maincity.OnCameraMove = function()
		UpdateTransitionPos()
	end
	CountDown.Instance:Add("buildingShowInfoUI", 0, CountDown.CountDownCallBack(function(t)
		UpdateTransition()
	end))
	isOpened = true
end

function Hide()
	if gameObject ~= nil and not gameObject:Equals(nil)	then
		gameObject:SetActive(false)
	end
	if buildingshowroot ~= nil and not buildingshowroot:Equals(nil) then
		buildingshowroot.gameObject:SetActive(false)
	end
	canUpdate =	false
end

function SetParadeGroundGroup(_index, _num,	_transform)
	if ParadeGroundShowGroup ==	nil	then
		ParadeGroundShowGroup =	{}
	end
	if ParadeGroundShowGroupNumRoot == nil or ParadeGroundShowGroupNumRoot:Equals(nil) then
		ParadeGroundShowGroupNumRoot = GameObject()
		ParadeGroundShowGroupNumRoot.name = "NumRoot"
		ParadeGroundShowGroupNumRoot.transform:SetParent(_transform.parent.parent, false)
		ParadeGroundShowGroupNumRoot:AddComponent(typeof(UIPanel)).depth = 10
		NGUITools.SetLayer(ParadeGroundShowGroupNumRoot, 27)
	end
	if ParadeGroundShowGroup[_index] ==	nil	then
		ParadeGroundShowGroup[_index] =	{}
	end
	ParadeGroundShowGroup[_index].num =	_num
	ParadeGroundShowGroup[_index].transform	= _transform
	if ParadeGroundShowGroup[_index].showui	== nil or ParadeGroundShowGroup[_index].showui:Equals(nil) then
		ParadeGroundShowGroup[_index].showui = ResourceLibrary.GetUIInstance("BuildingCommon/UnitName")
		ParadeGroundShowGroup[_index].showui.gameObject:SetActive(false)
		ParadeGroundShowGroup[_index].numui	= ParadeGroundShowGroup[_index].showui.transform:Find("bg_title/text"):GetComponent("UILabel")
	end
	ParadeGroundShowGroup[_index].showui.transform:SetParent(ParadeGroundShowGroup[_index].transform.parent, false)
	ParadeGroundShowGroup[_index].showui.transform.localPosition = Vector3(5,10,-5)
	ParadeGroundShowGroup[_index].showui.transform.localEulerAngles = Vector3(45,135,0)
	ParadeGroundShowGroup[_index].showui.transform.localScale = Vector3.one*0.2
	ParadeGroundShowGroup[_index].showui.transform:SetParent(ParadeGroundShowGroupNumRoot.transform)
	ParadeGroundShowGroup[_index].numui.text = ParadeGroundShowGroup[_index].num
end

function RemoveParadeGroundGroup(_index)
	if ParadeGroundShowGroup ==	nil	then
		return
	end
	ParadeGroundShowGroup[_index] =	nil
end

function ShowParadeGroundNum()
	if not isOpened then
		return
	end
	if ParadeGroundShowGroup ==	nil	then
		ParadeGroundShowGroup =	{}
	end
	for	_, v in	pairs(ParadeGroundShowGroup) do
		if v.showui.gameObject.activeInHierarchy then
			return
		end
		v.showui.gameObject:SetActive(true)
		local talpha = v.showui.transform:Find("bg_title"):GetComponent("TweenAlpha")
		local talphadur	= talpha.duration
		local tscale = talpha.transform:GetComponent("TweenScale")
		talpha:PlayForward(false)
		tscale:PlayForward(true)
		local coroutine	= coroutine.start(function()
			coroutine.wait(5)
			if isOpened then
				talpha.duration	= 1.5
				talpha:PlayReverse(false)
				talpha:SetOnFinished(EventDelegate.Callback(function ()
					talpha.duration	= talphadur
					v.showui.gameObject:SetActive(false)
					talpha:ClearOnFinished()
				end))
			end
		end)
	end
end

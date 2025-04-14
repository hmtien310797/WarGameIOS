module("maincity", package.seeall)
local defaultCameraPosition = Vector3(55, 102, 101)

local minCameraX = -145
local maxCameraX = 5

local minCameraY = 40		
local maxCameraY = 70

local minCameraZ = 40	
local maxCameraZ = 180

local cameraDragDelta

local Controller = Global.GController
local BuildMsg_pb = require("BuildMsg_pb")
local ItemMsg_pb = require("ItemMsg_pb")

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameObject = UnityEngine.GameObject
local Screen = UnityEngine.Screen
local Physics = UnityEngine.Physics
local SetPressCallback = UIUtil.SetPressCallback
local SetDragOverCallback = UIUtil.SetDragOverCallback
local SetClickCallback = UIUtil.SetClickCallback
local FloatText = FloatText

local buildingList = {}
local landList
local resourceBaseCapacity

--local cityCamera
local mainCamera
local uiEventCamera
local uiCamera

local specialList

local currentSelectedBuilding

local buildinginforoot
local buildinginforootsize

local buildingInited

local _buildingUpMsg

local _buildSFX = {}

local locateLandListener = EventListener()

local isAllLoad = false

local canGuide = false

local isRemoveBuild = false

local isGetResBubble = false

local isAwake = false

local wasteEffect

local needrefresh = false

local isPressCameraMove

local effect_shengji_gan
local effect_shengji_gebian
local effect_BornBuild
local isWast

local catchlist

local cameraBeginPos

OnCameraMove = nil

function GetisGetResBubble()
	return isGetResBubble
end

function SetisGetResBubble(value)
	isGetResBubble = value
end

function SetWast(wast)
    isWast = wast
end

function IsWast()
    return isWast
end

local buildqueue = 1
local needRecheck = true
local hasfreequeue = false
function GetBuildQueueNum()
	return buildqueue
end

function CaculateBuildQueue()
	for i = 1 , 2 do
		local unlock = Global.CheckBuildQueue(i) <= MainData.GetVipLevel() or Serclimax.GameTime.GetSecTime() < MainData.GetRentBuildQueueExpire()
		if unlock then
			buildqueue = i
		end
	end
end

function HasFreeQueue()
	if needRecheck then
		needRecheck = false
		local workBuild = GetWorkerCdTime()
		local usedqueue = 0
		for i, v in ipairs(workBuild) do
			if v.donetime > Serclimax.GameTime.GetSecTime() then
				usedqueue = usedqueue + 1
			end
		end
		CaculateBuildQueue()
		hasfreequeue = usedqueue < buildqueue
	end
	return hasfreequeue
end

function GetWorkerCdTime()
	local workBuild = {}
	for i=1 , #BuildingData.GetData().buildList , 1 do
		if BuildingData.GetData().buildList[i].donetime ~= nil and BuildingData.GetData().buildList[i].createtime ~= nil then
			table.insert(workBuild , BuildingData.GetData().buildList[i])
		end
	end
	return workBuild--BuildingData.GetData().workercdtime
end

function AddLocateLandListener(listener)
    locateLandListener:AddListener(listener)
end

function RemoveLocateLandListener(listener)
    locateLandListener:RemoveListener(listener)
end

local function NotifyLocateLandListener(landName)
    locateLandListener:NotifyListener(landName)
end

freetime = function()
	return tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.BuildFree).value) + VipData.GetValue(1,0)
end

techFreeTime = function()
	return tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.TechFree).value) + VipData.GetValue(2,0)
end

local function SetChildrenScale(go, _scale)
	local components = go:GetComponentsInChildren(typeof(UnityEngine.Transform))
	for i = 0, components.Length - 1 do
		components[i].localScale = Vector3.one * _scale
	end
end

function ResetCamera()
	if cityCamera then
		cityCamera:Recover()
	end
end

function PlayCameraAnimation(anim)
    local animClip = ResourceLibrary:GetMainCityAnimationClipInstance(anim)
    local controller = ResourceLibrary:GetLevelAnimatorControllerInstance("TitleCamera")
    if animClip ~= nil then
        local animator = cityCamera.transform:GetComponent("Animator")
        if animmator == nil then
            animator = cityCamera.gameObject:AddComponent(typeof(UnityEngine.Animator))
        end
        local overrideController = UnityEngine.AnimatorOverrideController()
        overrideController.name = "TitleCamera"
        overrideController.runtimeAnimatorController = controller
        overrideController:set_Item(overrideController.clips[0].originalClip, animClip)
        if animator ~= nil then
            animator.runtimeAnimatorController = nil
            animator.runtimeAnimatorController = overrideController
        end
        GameObject.Destroy(animator, animClip.length)
    end
end

--获取当前选中地块含有的建筑物信息
function GetCurrentBuildingData()
    return buildingList[currentSelectedBuilding]
end

function GetCurrentLandId()
    if currentSelectedBuilding:find("_") ~= nil then
        return tonumber(currentSelectedBuilding:split("_")[2])
    end
end

--获取建筑物信息列表
function GetBuildingList()
    return buildingList
end

function GetResourceBaseCapacity()
    if resourceBaseCapacity == nil then
        resourceBaseCapacity = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ResourceBaseCapacity).value)
    end

    return resourceBaseCapacity
end

function GetResourceCapacity(resourceType)
    local capacity = 0
    for _, v in pairs(GetBuildingList()) do
        if v.buildingData ~= nil and v.data ~= nil then
            local data = v.data
            if data.type == resourceType then
                capacity = capacity + TableMgr:GetBuildingResourceData(data.type, data.level).resource_BCapacity
            end
        end
    end

    return capacity
end

function GetResourceTotalCapacity(resourceType)
    return GetResourceBaseCapacity() + GetResourceCapacity(resourceType)
end

function GetFoodTotalCapacity()
    return GetResourceTotalCapacity(BuildMsg_pb.BuildType_Farmland)
end

function GetOilTotalCapacity()
    return GetResourceTotalCapacity(BuildMsg_pb.BuildType_OilField)
end

function GetSteelTotalCapacity()
    return GetResourceTotalCapacity(BuildMsg_pb.BuildType_Logging)
end

function GetElecTotalCapacity()
    return GetResourceTotalCapacity(BuildMsg_pb.BuildType_IronOre)
end

local function GetBuildingDataByLand(land)
    local datatable = TableMgr:GetAllBuildingData()
	for i , v in pairs(datatable) do
		if datatable[i].land == land then
            return datatable[i]
        end
	end
    --[[for i = 0, datatable.Length - 1 do
        if datatable[i].land == land then
            return datatable[i]
        end
    end]]
end

function GetMainCamera()
	return mainCamera
end

function IsMovingCamera()
    return cityCamera ~= nil and cityCamera:IsMoving()
end

function GetBuildingLevelByID(id)
	local lv = 0
    for i, v in pairs(buildingList) do
        if v.data ~= nil then
            if tonumber(v.data.type) == tonumber(id) and v.data.level > lv then
                lv = v.data.level
            end
        end
    end
    return lv
end

function HasBuildingByID(id)
    return GetBuildingLevelByID(id) > 0
end

function BuildBuilding(typeid, landid, buildtype, callback)
    local req = BuildMsg_pb.MsgConstructBuildRequest()
    req.type = typeid
    req.landid = landid
    req.upgradeType = buildtype
    LuaNetwork.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgConstructBuildRequest, req:SerializeToString(), function (typeId, data)
        local msg = BuildMsg_pb.MsgConstructBuildResponse()
        msg:ParseFromString(data)
		callback(msg)
		if typeid == 8 then
			GUIMgr:SendDataReport("efun", "build_event")
        elseif typeid == 21 then
            Event.Resume(4)
		end
    end, true)
end

function UnlockLand(id, callback)
	local req = BuildMsg_pb.MsgBuildLandUnlockRequest()
	req.id = id
	LuaNetwork.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgBuildLandUnlockRequest, req:SerializeToString(), function(typeId, data)
		local msg = BuildMsg_pb.MsgBuildLandUnlockResponse()
		msg:ParseFromString(data)
		callback(msg)
	end,true)
end

function HideTransitionName()
	if BuildingShowInfoUI.IsOpened() then
		for i, v in pairs(buildingList) do
			if v.transition ~= nil then
				v.transition.head.gameObject:SetActive(false)
			end
		end
	end
end

local FinishBuildCallBack = nil

function SetBuildCallBack(callback)
	FinishBuildCallBack = callback
end

function FinishBuild(_build)
    local req = BuildMsg_pb.MsgAccelBuildUpdateRequest()
    req.uid = _build.data.uid
    Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgAccelBuildUpdateRequest, req, BuildMsg_pb.MsgAccelBuildUpdateResponse, function(msg)
    	if msg.code == 0 then
    		AudioMgr:PlayUISfx("SFX_UI_building_speed", 1, false)
			_build.buildingfree = false
			UpdateBuildInMsg(msg.build, msg.build.donetime)
			MoneyListData.UpdateData(msg.fresh.money.money)
			MainCityQueue.UpdateQueue()
		else
	     	Global.FloatError(msg.code, Color.white)
    	end
    end, true)
end

function ClearFinishBuildCallBack()
	FinishBuildCallBack = nil
end

local function BuildingClickCallback(go)
	if Global.GController:GetTouches().Count < 2 then
		local canmove = false
		MainCityUI.HideCityMenu()
		if go.transform.childCount == 0 then
			return
		end
		currentSelectedBuilding = go.name
		local apple_review = ServerListData.IsAppleReviewing()
		if apple_review and currentSelectedBuilding ==  "huodongdating_01" then
			return 
		end 
	    if buildingList[currentSelectedBuilding].data ~= nil then
	    	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
	    	local isfinish = false
	    	if buildingList[currentSelectedBuilding].buildingfree ~= nil and buildingList[currentSelectedBuilding].buildingfree then
	    		isfinish = true
	    		FinishBuild(buildingList[currentSelectedBuilding])
	    	end
	    	if buildingList[currentSelectedBuilding].techfree ~= nil and buildingList[currentSelectedBuilding].techfree then
	    		isfinish = true
	    		--科技免费加速回调
	    		local tech = Laboratory.GetCurUpgradeTech()
	    		if tech ~= nil then
	    		    LaboratoryUpgrade.RequestFree(function() 
	    		        buildingList[currentSelectedBuilding].techfree = false
	    		    end)
                end
            end
	    	if not isfinish then
	    		canmove = true
	    		print(buildingList[currentSelectedBuilding].data.type)
		        if buildingList[currentSelectedBuilding].data.type == 7 then
		        	MainCityUI.SetShowMenuCallBack(mainCamera,go,function()
		            	MilitarySchool.Show()
		            	MilitarySchool.OnCloseCB = function()
			            	MainCityUI.RemoveMenuTarget()
			            end
		            end)
		        elseif buildingList[currentSelectedBuilding].data.type == 8 then
		        	MainCityUI.SetShowMenuCallBack(mainCamera,go,function()
		            	Entrance.Show()
			            Entrance.OnCloseCB = function()
			            	MainCityUI.RemoveMenuTarget()
			            end
		            end)
		        elseif buildingList[currentSelectedBuilding].data.type == 9 then -- 排行榜
                    local baseLevel = BuildingData.GetCommandCenterData().level
                    if baseLevel < 8 then
                        FloatText.Show(TextMgr:GetText(Text.ui_Arena_16))
                        return
                    end
					BattleRank.Show(false, MainCityUI.RemoveMenuTarget)
		        else
		            MainCityUI.ShowCityMenu(mainCamera,go)
		        end
		    end
	    else
	        if buildingList[currentSelectedBuilding].unlock ~= nil and buildingList[currentSelectedBuilding].unlock then
	        	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
	            MainCityUI.ShowCityMenu(mainCamera,go)
	        	canmove = true
	        end
	        if buildingList[currentSelectedBuilding].canUnlock ~= nil then
	            BuildingLocked.SetData(buildingList[currentSelectedBuilding])
				BuildingLocked.SetBuildCallback(function()
					local _building = buildingList[currentSelectedBuilding]
	            	BuildBuilding(_building.unlockData.id, 0, 1, function ()
						if _building.unlockUI ~= nil then
							GameObject.Destroy(_building.unlockUI.gameObject)
							GameObject.Destroy(_building.unlock_collider.gameObject)
							_building.unlockUI = nil
							_building.unlock_collider = nil
						end
						GetBuildingListData()
		            end)
	            end)
	            AudioMgr:PlayUISfx("SFX_ui01", 1, false)
	            GUIMgr:CreateMenu("BuildingLocked", false)
	            canmove = false
	        end
	    end
	    HideTransitionName()
	    if buildingList[currentSelectedBuilding].transition ~= nil then
	    	buildingList[currentSelectedBuilding].transition.head.gameObject:SetActive(true)
	    	local bgs = buildingList[currentSelectedBuilding].transition.name.transform.parent:GetComponents(typeof(UITweener))
			for i = 0, bgs.Length - 1 do
				bgs[i]:Play(true, true)
			end
	    end
	    
	    if buildingList[currentSelectedBuilding].unlockLand ~= nil then
	    	BuildingLocked.SetData(buildingList[currentSelectedBuilding])
	    	BuildingLocked.SetBuildCallback(function()
				local pos = buildingList[currentSelectedBuilding].land.transform.position
				if buildingList[currentSelectedBuilding].unlockLandid ~= nil then
					UnlockLand(buildingList[currentSelectedBuilding].unlockLandid, function(msg)
						AudioMgr:PlayUISfx("SFX_building_born", 1, false)
						local _fx = ResourceLibrary:GetEffectInstance("BornBuildBig")
						_fx.transform.position = pos
						GameObject.Destroy(_fx.gameObject,3)
						GetBuildingListData()
						if buildingList[currentSelectedBuilding].unlockLandUI ~= nil then
							GameObject.Destroy(buildingList[currentSelectedBuilding].unlockLandUI.gameObject)
							GameObject.Destroy(buildingList[currentSelectedBuilding].unlockLand_collider.gameObject)
							buildingList[currentSelectedBuilding].unlockLandUI = nil
							buildingList[currentSelectedBuilding].unlockLand_collider = nil
						end
					end)
				end
	    	end)
	    	GUIMgr:CreateMenu("BuildingLocked", false)
	        canmove = false
	    end
	    
	    if canmove then
	    	cityCamera:SetTargetPosition(go.transform.position, false, false)
	    else
	    	cityCamera:Recover()
	    end
    end
end

function SetAwardStatus(_building, isActive, callback, text, spritename)
	if _building == nil or _building.transition == nil or _building.transition.free == nil or _building.transition.free:Equals(nil) then
		return
	end
	_building.transition.free.gameObject:SetActive(isActive)
	_building.transition.free.transform:Find("bg"):GetComponent("UISprite").spriteName = spritename
	if text ~= nil and not System.String.IsNullOrEmpty(text) then
		_building.transition.free.transform:Find("bg/text"):GetComponent("UILabel").text = text
		--_building.transition.free.transform:Find("bg/text").gameObject:SetActive(true)
	end
	SetClickCallback(_building.transition.free.transform:Find("bg").gameObject, function()
		AudioMgr:PlayUISfx("SFX_ui01", 1, false)
		if callback ~= nil then
			callback()
		end
	end)
end

function RefreshBuildingTransition(building)
	BuildingShowInfoUI.MakeTransition(building)
end

function RefreshCurrentTransition()
	BuildingShowInfoUI.MakeTransition(buildingList[currentSelectedBuilding])
end

function RefreshBuildingTransitionType(ltype , stype)
	for _ ,v in pairs(buildingList) do
		if v.buildingData ~= nil and v.data ~= nil then
			if v.buildingData.logicType == lType and v.buildingData.showType == sType then
				RefreshBuildingTransition(v)
			end
		end
	end
end

--这里只刷新了建筑的获取资源时间，--gathertime
function RefreshBuild(freshlist)
	for _ , v in ipairs(freshlist) do
		for _, vv in pairs(buildingList) do
			if vv.data ~= nil and vv.data.uid == v.uid then
				vv.data.gathertime = v.gathertime
			end
		end
	end
end

local function GetBDataByUID(uid)
	for i, v in pairs(BuildingData.GetData().buildList) do
		if tonumber(v.uid) == tonumber(uid) then
			return v
        end
	end
end

function CheckLevelUp()
	if transform == nil or not gameObject.activeInHierarchy then
        return
    end
	canGuide = false
    local req = BuildMsg_pb.MsgBuildUpdateCompletedRewardRequest()
    LuaNetwork.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgBuildUpdateCompletedRewardRequest, req:SerializeToString(), function(typeId, data)
		local msg = BuildMsg_pb.MsgBuildUpdateCompletedRewardResponse()
		msg:ParseFromString(data)
		if msg.info ~= nil and #msg.info > 0 then
		    for i, v in ipairs(msg.info) do
				MainCityUI.UpdateRewardData(v.reward)
		        if v.build ~= nil and v.build.type == 1 then
		        	WelfareData.UpdateWelfareProgression(3001)
		            if MainCityUI.IsLoginEnter() then
		            	MainCityUI.AddAfterLoginAward(function() BuildingLevelup.Show(v.build,MainCityUI.LoginAwardGo) end)
		            else
		            	BuildingLevelup.Show(v.build)
		            end
		        end
		    end
		end
		UnlockArmyData.RequestData()
	    MainCityQueue.UpdateQueue();	
	end, false)
end

function SetBuildCountDown(_building, _targettime, callback , icon)
	--[[
	local transition = _building.transition
	local countdown = transition.foot.transform:Find("time/num"):GetComponent("UILabel")
	transition.foot.transform:Find("time").gameObject:SetActive(true)
	local countdownIcon = transition.foot.transform:Find("time/icon"):GetComponent("UISprite")
	countdownIcon.spriteName = icon--"time_icon9"
    CountDown.Instance:Add(_building.buildingData.name .. _building.data.uid, _targettime, function(t)
    	if callback ~= nil then
    		callback(t)
    	end
    	countdown.text = t
    	if _targettime < Serclimax.GameTime.GetSecTime() then
    		transition.foot.transform:Find("time").gameObject:SetActive(false)
    		CountDown.Instance:Remove(_building.buildingData.name .. _building.data.uid)
    	end
    end)
    --]]
    BuildingShowInfoUI.MakeHospitalTime(_building, _targettime, callback, icon)
    MainCityQueue.UpdateQueue()
end

function RemoveBuildCountDown(_building)
	--[[
	local transition = _building.transition
	if transition ~= nil then
		transition.foot.transform:Find("time").gameObject:SetActive(false)
	end
	CountDown.Instance:Remove(_building.buildingData.name .. _building.data.uid)
	--]]
	BuildingShowInfoUI.MakeHospitalTime(_building)
end

function SetTypeBuildCountDown(lType , sType , _targettime, callback , icon)
	for _ ,v in pairs(buildingList) do
		if v.buildingData ~= nil and v.data ~= nil then
			if v.buildingData.logicType == lType and v.buildingData.showType == sType then
				SetBuildCountDown(v , _targettime, callback , icon)
			end
		end
	end
end

function RemoveTypeBuildCountDown(lType , sType)
	for _ ,v in pairs(buildingList) do
		if v.buildingData ~= nil and v.data ~= nil then
			if v.buildingData.logicType == lType and v.buildingData.showType == sType then
				RemoveBuildCountDown(v)
			end
		end
	end
end

local function InitBuildSFX(_building)

	local _size = _building.land:GetComponent("BoxCollider").size
	if _building._sfx ~= nil and not _building._sfx:Equals(nil) then
		GameObject.Destroy(_building._sfx.gameObject)
		_sfx = nil
	end
	_buildSFX = {}
	_sfx = GameObject.New("SFX").transform
	_sfx:SetParent(_building.land.transform.parent)
	_sfx.position = _building.land.transform.position
	_sfx.localEulerAngles = Vector3.zero
	local _fx = NGUITools.AddChild(_sfx.gameObject, effect_shengji_gan.gameObject)
	_fx.transform.localPosition = Vector3.New(_size.y * 0.5, 0, _size.x * 0.5)
	_fx.transform.localEulerAngles = Vector3.New(0, 180, 0)
	_buildSFX[1] = _fx
	_fx = NGUITools.AddChild(_sfx.gameObject, effect_shengji_gan.gameObject)
	_fx.transform.localPosition = -Vector3.New(_size.y * 0.5, 0, _size.x * 0.5)
	_fx.transform.localEulerAngles = Vector3.New(0, 0, 0)
	_buildSFX[2] = _fx
	_fx = NGUITools.AddChild(_sfx.gameObject, effect_shengji_gebian.gameObject)
	_fx.transform.localPosition = Vector3.New(-_size.y * 0.5, 0, _size.x * 0.5)
	_fx.transform.localEulerAngles = Vector3.New(0, 0, 0)
	_buildSFX[3] = _fx
	_fx = NGUITools.AddChild(_sfx.gameObject, effect_shengji_gebian.gameObject)
	_fx.transform.localPosition = -Vector3.New(-_size.y * 0.5, 0, _size.x * 0.5)
	_fx.transform.localEulerAngles = Vector3.New(0, 180, 0)
	_buildSFX[4] = _fx
	_sfx.localEulerAngles = Vector3.New(0, 45, 0)
	local scale = math.max(_size.z / 8, 0.5)
	for i, v in ipairs(_buildSFX) do
		v.transform.localScale = Vector3.one * scale
	end
	_building._sfx = _sfx
	_building._buildSFX = _buildSFX
	_building._sfxScale = scale
end

local function PlayBuildSFXIdle(_building)
	InitBuildSFX(_building)

	for i, v in ipairs(_building._buildSFX) do
		v.transform:GetChild(0):GetComponent("Animator"):SetTrigger("idle")
	end
	local _fx
	if _building._fx == nil or _building._fx:Equals(nil) then
		_fx = NGUITools.AddChild(_building.land.parent.gameObject, effect_BornBuild.gameObject)
	else
		_fx = _building._fx
	end
	_fx.transform.position = _building.land.transform.position
	SetChildrenScale(_fx, _building._sfxScale)
	_building._fx = _fx
end

function PlayBuildSFXIdleByID(id)
	local _building = GetBuildingByID(id)
	PlayBuildSFXIdle(_building)
end

function PlayBuildEffect(id, effect, duration)
	local _building = GetBuildingByID(id)
    local effectInstance = ResourceLibrary:GetEffectInstance(effect)
    effectInstance.transform:SetParent(_building.land, false)
    GameObject.Destroy(effectInstance, duration)
end

local function PlayBuildSFXBegin(_building)
	InitBuildSFX(_building)
	for i, v in ipairs(_building._buildSFX) do
		v.transform:GetChild(0):GetComponent("Animator"):SetTrigger("begin")
	end
	local _fx
	if _building._fx == nil or _building._fx:Equals(nil) then
		_fx = NGUITools.AddChild(_building.land.parent.gameObject, effect_BornBuild.gameObject)
	else
		_fx = _building._fx
	end
	_fx.transform.position = _building.land.transform.position
	SetChildrenScale(_fx, _building._sfxScale)
	_building._fx = _fx
	_building.targetstate = 1
end

function PlayBuildSFXBeginByID(id)
	local _building = GetBuildingByID(id)
	PlayBuildSFXBegin(_building)
end

local function PlayBuildSFXEnd(_building)
	_building.targetstate = nil
	InitBuildSFX(_building)

	if _building._fx ~= nil then
    	GameObject.Destroy(_building._fx)
    	_building._fx = nil
    end
	for i, v in ipairs(_building._buildSFX) do
		v.transform:GetChild(0):GetComponent("Animator"):SetTrigger("end")
	end
	GameObject.Destroy(_building._sfx.gameObject,3)
	_building._sfx = nil
	_building.buildSfxState = nil
end

function PlayBuildSFXEndByID(id)
	local _building = GetBuildingByID(id)
	PlayBuildSFXEnd(_building)
end

local function PlayBuildSFXBorn(_building)
	_building.targetstate = nil
	InitBuildSFX(_building)
	local _fx
	if _building._fx == nil or _building._fx:Equals(nil) then
		_fx = NGUITools.AddChild(_building.land.parent.gameObject, effect_BornBuild.gameObject)
	else
		_fx = _building._fx
	end
	_fx.transform.position = _building.land.transform.position
	SetChildrenScale(_fx, _building._sfxScale)
	_building._fx = _fx
	_building.hideTransition = true
	local bornfunction = function(__building)
		for i, v in ipairs(__building._buildSFX) do
			if v ~= nil and not v:Equals(nil) then
				v.transform:GetChild(0):GetComponent("Animator"):SetTrigger("begin")
			end
		end
       	coroutine.wait(3)
        if __building._fx ~= nil then
        	GameObject.Destroy(__building._fx)
        	__building._fx = nil
		end
        for i, v in ipairs(__building._buildSFX) do
        	if v == nil or v:Equals(nil) then
        		break
        	end
			v.transform:GetChild(0):GetComponent("Animator"):SetTrigger("end")
		end
		--GameObject.Destroy(__building._sfx.gameObject,3)
		--__building._sfx = nil
		MissionListData.ReleaseMsg()
		canGuide = true
		__building.hideTransition = false
		__building.buildSfxState = nil
    end
    coroutine.stop(_building.bornCoroutine)
    _building.bornCoroutine = coroutine.start(bornfunction, _building)
end

function PlayBuildSFXBornByID(id)
	local _building = GetBuildingByID(id)
	PlayBuildSFXBorn(_building)
end

function CleanBuildSFX(_building)
	if _building._fx ~= nil then
    	GameObject.Destroy(_building._fx)
    	_building._fx = nil
    end
    if _building._sfx ~= nil then
    	GameObject.Destroy(_building._sfx.gameObject)
		_building._sfx = nil
    end
end

function IsCanGuide()
	return canGuide
end

local showQueue = false
local updateConstructionCoroutine
local ShowParadeGroundArmyCoroutine
function UpdateConstruction()
	local buildList = BuildingData.GetData().buildList
	landList = BuildingData.GetData().lands
	for _, v in ipairs(buildList) do
		local building
		local buildingData = TableMgr:GetBuildingData(v.type)
		if buildingData ~= nil then
			local buildUpdateData = TableMgr:GetBuildUpdateData(v.type, v.level)
			
			if v.landid > 0 then
				building = buildingList[buildingData.land .. v.landid]
			else
				building = buildingList[buildingData.land]
			end
			if building ~= nil then
				building.data = v
				building.buildingData = buildingData
				building.upgradeData = buildUpdateData
			end
		end
	end
	local needcoroutine = false
    if transform == nil or not gameObject.activeInHierarchy then
        return
	end
	if BuildingUpgrade.gameObject ~= nil or CommonItemBag.gameObject ~= nil then
		return
	end
	--coroutine.stop(updateConstructionCoroutine)
	
	updateConstructionCoroutine = coroutine.start(function()
		local cangoon = false
		for _, v in ipairs(buildList) do
			local building
			local buildingData = TableMgr:GetBuildingData(v.type)
			if buildingData ~= nil then
				local buildUpdateData = TableMgr:GetBuildUpdateData(v.type, v.level)
				
	            if v.landid > 0 then
	                building = buildingList[buildingData.land .. v.landid]
	            else
	                building = buildingList[buildingData.land]
				end
				cangoon = building ~= nil and (building.land ~= nil and not building.land:Equals(nil))
				if building ~= nil and cangoon then
					if building.model ~= nil and building.model.name ~= buildUpdateData.prefab then
						GameObject.Destroy(building.model.gameObject)
						building.model = ResourceLibrary:GetConstructionInstance(buildUpdateData.prefab)
						building.model.name = buildUpdateData.prefab
						building.model.transform:SetParent(building.land, false)
						building.model.transform.localPosition = Vector3.zero
						building.model.transform.localEulerAngles = Vector3.zero
						building.model.transform.localScale = Vector3.one
						local box = building.model:GetComponent("BoxCollider")
						if box ~= nil then
							box.enabled = false
						end
					elseif building.model == nil or building.model:Equals(nil) then
						local childCount = building.land.childCount
						for i = 1, childCount do
							GameObject.Destroy(building.land:GetChild(i - 1).gameObject)
						end
						building.model = ResourceLibrary:GetConstructionInstance(buildUpdateData.prefab)
						building.model.name = buildUpdateData.prefab
						building.model.transform:SetParent(building.land, false)
						building.model.transform.localPosition = Vector3.zero
						building.model.transform.localEulerAngles = Vector3.zero
						building.model.transform.localScale = Vector3.one
						local box = building.model:GetComponent("BoxCollider")
						if box ~= nil then
							box.enabled = false
						end
					end
					if building.unlockUI ~= nil then
						GameObject.Destroy(building.unlockUI.gameObject)
						GameObject.Destroy(building.unlock_collider.gameObject)
						building.unlockUI = nil
						building.unlock_collider = nil
					end
	                local lvstate = 0
	                if building.data == nil then
	                	if not isAwake then
	                		lvstate = 1
	                	end
	                else
	                	if building.data.level ~= v.level then
	                		lvstate = 2
	                	end
	                end
	                building.data = v
	                building.buildingData = buildingData
	                building.upgradeData = buildUpdateData
					building.state = 0
					if building.buildSfxState == nil then
						building.buildSfxState = {}
					end
					
		            if lvstate == 1 then
		            	if v.type == 4 then
		            		ShowParadeGroundArmyCoroutine = coroutine.start(function()
				    			coroutine.wait(6)
				    			Barrack.ShowParadeGroundArmy()
				    		end)
		            	end
		            	building.model.transform.localPosition = Vector3.New(0, 0, -20)
						iTween.MoveTo(building.model, building.land.position, 3)
						AudioMgr:PlayUISfx("SFX_building_born", 1, false)
						_buildingUpMsg = nil
						building.targetstate = 3
						BuildingShowInfoUI.MakeTransition(building)
					elseif lvstate == 2 then
						AudioMgr:PlayUISfx("SFX_UI_finish_building", 1, false)
					    local _fx = ResourceLibrary:GetEffectInstance("BulidLVUP")
					    _fx.transform.position = building.land.transform.position
					    GameObject.Destroy(_fx, 3)
					    MainCityUI.FlyExp(building)
					    if v.type == 1 then -- 主城升级
					    	WelfareData.UpdateWelfareProgression(3001)
					    end
					    _buildingUpMsg = nil
					    building.targetstate = 2
		            end
	                
	                if v.landid > 0 then
	                    buildingList[buildingData.land .. v.landid] = building
	                else
	                    buildingList[buildingData.land] = building
	                end
	                if v.donetime + 10 > Serclimax.GameTime.GetSecTime() then
			        	if building.targetstate == nil then
			        		building.targetstate = 0
			        	end
						CountDown.Instance:Add("Levelup",v.donetime + 2,CountDown.CountDownCallBack(function(t)
			                if t == "00:00:00" then
			                    GetBuildingListData(v.uid)
								CountDown.Instance:Remove("Levelup")
								coroutine.start(function()
									coroutine.wait(3)
									GetBuildingListData(v.uid)
								end)
			                end
			            end))
			        else
			        	if building.targetstate == 1 then
			        		building.targetstate = 2
			        	end
			        end
				end
			end
			if building ~= nil and cangoon then
				if building.targetstate == 0 then
					building.targetstate = 1
					PlayBuildSFXBegin(building)
				elseif building.targetstate == 1 then
					PlayBuildSFXIdle(building)
				elseif building.targetstate == 2 then
					PlayBuildSFXEnd(building)
				elseif building.targetstate == 3 then
					PlayBuildSFXBorn(building)
				else
					CleanBuildSFX(building)
				end
			end
	        if isAwake or needcoroutine then
	        	coroutine.step()
	        end
		end
		local landunlock = {}
		for _, v in pairs(buildingList) do
			needcoroutine = false
			cangoon = v.land ~= nil and not v.land:Equals(nil)
			if cangoon then
				if v.land.name:find("ziyuantian_") ~= nil then
					v.unlock = false
					local t = v.land.name:split("_")
					for i, vv in pairs(landList) do
						if tonumber(vv.land) == tonumber(t[#t]) then
							landunlock[vv.land] = true
							v.unlock = true
							if vv.used == false then
								if v.model == nil or v.model:Equals(false) then
									v.model = ResourceLibrary:GetConstructionInstance("kongxianjianzhu_01")
									--v.model.name = "kongxianjianzhu_01"
									v.model.transform:SetParent(v.land, false)
									v.model.transform.localPosition = Vector3.zero
									v.model.transform.localEulerAngles = Vector3.zero
								end
							end
						end
					end
					--needcoroutine = true
				end
				if v.buildingData == nil then
					local bdata = GetBuildingDataByLand(v.land.name)
					if bdata ~= nil then
						
						v.unlockData = bdata
						if MainData.GetLevel() >= bdata.needPlayerLevel then
							v.canUnlock = true
							local str = bdata.unlockCondition
							if str == "NA" then
								v.canUnlock = v.canUnlock and true
							end
							local st = ""
							str = str:split(";")
							for i, w in ipairs(str) do
								local s = w:split(":")
								if #s > 1 then
									if tonumber(s[1]) == 1 then
										if tonumber(s[3]) <= GetBuildingLevelByID(s[2]) then
											v.canUnlock = v.canUnlock and true
										else
											v.canUnlock = v.canUnlock and false
										end
									elseif tonumber(s[1]) == 2 then
										if tonumber(s[3]) <= GetBuildingCount(s[2]) then
											v.canUnlock = v.canUnlock and true
										else
											v.canUnlock = v.canUnlock and false
										end
									--[[elseif tonumber(s[1]) == 3 then
										if tonumber(s[3]) <= GetBuildingCount(s[2]) then
											v.canUnlock = v.canUnlock and true
										else
											v.canUnlock = v.canUnlock and false
										end]]
									elseif tonumber(s[1]) == 4 then
										if ChapterListData.HasLevelExplored(tonumber(s[2])) then
											v.canUnlock = v.canUnlock and true
										else
											v.canUnlock = v.canUnlock and false
										end
									end
								end
							end
						else
							v.canUnlock = v.canUnlock and false
						end
						--needcoroutine = true
					end
				else
					if v.canUnlock ~= nil then
						v.canUnlock = nil
					end
				end
			end
			if needcoroutine then
	        	coroutine.step()
	        end
	    end
	--	if buildingInited ~= true then
	--		Barrack.RequsetBarrackTrainInfo()
	--		buildingInited = true
	--	end
		for i = 1, 7 do
			if landunlock[i * 5] == nil then
				local landdata = TableMgr:GetLandListData(i)
				if landdata ~= nil then
					if landdata.lands == nil then
						break
					end
					buildingList["ziyuan" .. i].unlockLand = false
					buildingList["ziyuan" .. i].unlockData = {}
					buildingList["ziyuan" .. i].unlockData.name = "build_ui44" --TextMgr:GetText("build_ui44")
					buildingList["ziyuan" .. i].unlockData.description = "build_ui45" --TextMgr:GetText("build_ui45")
					buildingList["ziyuan" .. i].unlockData.icon = "999"
					local str = landdata.unlockCondition
		            if str == "NA" then
		                buildingList["ziyuan" .. i].unlockLand = true
		                buildingList["ziyuan" .. i].unlockLandid = i
		            end
		            local st = ""
		            str = str:split(";")
		            for _, w in ipairs(str) do
		                local s = w:split(":")
		                if #s > 1 then
		                    if tonumber(s[1]) == 1 then
		                        if landdata.needPlayerLevel <= MainData.GetLevel() and tonumber(s[3]) <= GetBuildingLevelByID(s[2]) then
		                            buildingList["ziyuan" .. i].unlockLand = true
		                            buildingList["ziyuan" .. i].unlockLandid = i
		                        else
		                        	st = st .. System.String.Format(TextMgr:GetText("build_ui28"), TextMgr:GetText(TableMgr:GetBuildingData(s[2]).name), s[3])
		                        	buildingList["ziyuan" .. i].unlockCondition = st
		                        end
		                    else
		                        if landdata.needPlayerLevel <= MainData.GetLevel() and tonumber(s[3]) <= GetBuildingCount(s[2]) then
		                            buildingList["ziyuan" .. i].unlockLand = true
		                            buildingList["ziyuan" .. i].unlockLandid = i
		                        else
		                            st = st .. System.String.Format(TextMgr:GetText("build_ui29"), TextMgr:GetText(TableMgr:GetBuildingData(s[2]).name), s[3])
		                            buildingList["ziyuan" .. i].unlockCondition = st
		                        end
		                    end
		                end
		            end
				end
			else
				buildingList["ziyuan" .. i].land.gameObject:SetActive(false)
				buildingList["ziyuan" .. i].unlockLand = nil
				buildingList["ziyuan" .. i].unlockLandid = nil
				if buildingList["ziyuan" .. i].unlockLandUI ~= nil then
					GameObject.Destroy(buildingList["ziyuan" .. i].unlockLandUI.gameObject)
					GameObject.Destroy(buildingList["ziyuan" .. i].unlockLand_collider.gameObject)
					buildingList["ziyuan" .. i].unlockLandUI = nil
					buildingList["ziyuan" .. i].unlockLand_collider = nil
				end
			end
		end
		--[[ if CommonItemBag ~= nil then
			if CommonItemBag.transform ~= nil and not CommonItemBag.transform:Equals(nil) then
				CommonItemBag.UpdateItem()
			end
		end ]]
		if not cangoon then
			return
		end
		if not GUIMgr.Instance:IsMenuOpen("WorldMap") then
			CaculateBuildQueue()
			if isAwake then
				BuildingShowInfoUI.Show()
			else
				BuildingShowInfoUI.Refresh()
			end
		end

		if not showQueue then
	        MainCityQueue.LoadUI(MainCityUI.transform)
	        MainCityQueue.ShowQueue(true,true)
	        showQueue = true
	    end
	    
		--MainCityUI.RefreshCityMenu()
		
		if isAwake then
	    	Barrack.RequestArmNum()
			MainCityUI.CheckRecommendedMission()
			isAllLoad = true
			UnionHelpData.RequestData()
			MainCityUI.AddAfterLoginAward(function()
				MainCityUI.OpenTutorial()
				MainCityUI.LoginAwardGo()
			end)
			MainCityUI.UpdateFreeChest()
			MainCityUI.UpdateActivityNotice()
			MainCityUI.UpdateMoney()
			Laboratory.CheckUpgradeProgress()
			MainCityUI.CheckLoginAward()
			Barrack_SoldierEquipData.CaculateNeedShow()
		end
		if OnCameraMove ~= nil then
			OnCameraMove()
		end
		
		if isAwake then
			isAwake = false
			needcoroutine = false
			--[[table.insert(catchlist, ResourceLibrary.GetUIPrefab("Laboratory/Laboratory"))
			table.insert(catchlist, ResourceLibrary.GetUIPrefab("equip/EquipMap"))
			table.insert(catchlist, ResourceLibrary.GetUIPrefab("HeroAppoint/HeroAppointUI"))
			table.insert(catchlist, ResourceLibrary.GetUIPrefab("Barrack/Barrack"))
			table.insert(catchlist, ResourceLibrary.GetUIPrefab("Barrack/Barrack_soldier"))
			local BarrackInfosMap = Barrack.GetBarrackInfosMap()
			for _,soldierid in pairs(BarrackInfosMap) do
				for __,data in pairs(soldierid) do
					local unit_data = TableMgr:GetUnitData(data.UnitID)
					if unit_data ~= nil then
						table.insert(catchlist, ResourceLibrary:GetLevelUnitPrefab(unit_data._unitPrefab))
					end
				end
			end]]
		end
	end)
end

function UpdateBuildInMsg(buildmsg, workcdtime)
	if buildmsg == nil or transform == nil then
		return
	end
	local isnew = true
	for i , v in ipairs(BuildingData.GetData().buildList) do
		if v.uid == buildmsg.uid then
			if v.level > buildmsg.level then
			else
				isnew = false
				BuildingData.GetData().buildList[i] = buildmsg
				local _b = GetBuildingByUID(v.uid)
				if _b ~= nil then
					_b.data = buildmsg
					_b.upgradeData = TableMgr:GetBuildUpdateData(_b.data.type, _b.data.level)
					BuildingShowInfoUI.MakeTransition(_b)
				end
			end
		end
	end
	if isnew then
		table.insert(BuildingData.GetData().buildList, buildmsg)
	end
	if FinishBuildCallBack ~= nil then
		if BuildingUpgrade.gameObject ~= nil then
			FinishBuildCallBack()
		else
			FinishBuildCallBack = nil
		end
	end
	CheckLevelUp()
	UpdateConstruction()
	UnionHelpData.RequestData()
end

function RemoveBuild(land)
	isRemoveBuild = true
	for i, v in pairs(buildingList) do
		if v.land.name:find("ziyuantian_") ~= nil then
			local t = v.land.name:split("_")
			if tonumber(land.land) == tonumber(t[#t]) then
				local childCount = v.land.childCount
                for i = 1, childCount do
                    GameObject.Destroy(v.land:GetChild(i - 1).gameObject)
                end
				
                RemoveBuildCountDown(v)
                v.data = nil
                v.buildingData = nil
                v.upgradeData = nil
				v.model = nil
				if v.icon ~= nil then
					GameObject.Destroy(v.icon.gameObject)
					v.icon = nil
				end
				
                BuildingShowInfoUI.RemoveTranstion(v)
                
                if v.unlockui ~= nil then
					GameObject.Destroy(v.unlockui)
				end
				
				if v.unlockLandui ~= nil then
					GameObject.Destroy(v.unlockLandui)
				end
			end
		end
	end
end

function SetBuildClickEnable(isEnabled)
    uiEventCamera.enabled = isEnabled
    if isEnabled == false then
        MainCityUI.HideCityMenu()
    end
end

function GetBuildingListData(uid, callback)
    BuildingData.RequestData(function(msg)
    	if uid ~= nil then
    		for i, v in ipairs(msg.buildList) do
    			if v.uid == uid then
    				local building = GetBuildingByUID(uid)
    				building.data = v
    				BuildingShowInfoUI.MakeBuildTime(building)
    				if CommonItemBag ~= nil then
						if CommonItemBag.transform ~= nil and not CommonItemBag.transform:Equals(nil) then
							CommonItemBag.UpdateTopProgress()
						end
					end
					building.upgradeData = TableMgr:GetBuildUpdateData(v.type, v.level)
					if v.donetime ~= nil then
						if v.donetime + 10 > Serclimax.GameTime.GetSecTime() then
							CountDown.Instance:Add("Levelup",v.donetime + 2,CountDown.CountDownCallBack(function(t)
								if t == "00:00:00" then
									GetBuildingListData(v.uid)
									CountDown.Instance:Remove("Levelup")
								end
							end))
						end
					end
					if FinishBuildCallBack ~= nil then
						if BuildingUpgrade.gameObject ~= nil then
							FinishBuildCallBack()
						else
							FinishBuildCallBack = nil
						end
					end
					if callback ~= nil then
						callback()
					end
    			end
    		end
			UpdateConstruction()
			CheckLevelUp()
    	else
			if isRemoveBuild then
				isRemoveBuild = false
			else
				CheckLevelUp()
			end
			UpdateConstruction()
		end
    end)
end

local function OnUICameraPress(go, ispress)
	isPressCameraMove = ispress
end

function ResetUICameraPress()
	isPressCameraMove = false
end

local function OnUICameraDrag(go, delta)
    if UICamera.isOverUI then
        return
    end
    local topMenu = GUIMgr:GetTopMenuOnRoot()
    if topMenu ~= MainCityUI.this and topMenu ~= BuildingShowInfoUI.this then
        return
    end
    if isGetResBubble then
        return
    end
    if Global.GController:GetTouches().Count > 1 then
        return
    end
    cameraDragDelta = delta
    local deltaX = delta.x
    local deltaY = delta.y
    local dragSpeed = 0.1
    cityCamera:Move(deltaX * dragSpeed, deltaY * dragSpeed)
	MainCityUI.HideCityMenu()
	HideTransitionName()
	if math.abs(deltaX) >= 20 or math.abs(deltaY) >= 20 then
		MainCityUI.ResEffectTargetUpdate()
	end
end

local function OnUICameraDragEnd(go)
    if cameraDragDelta ~= nil then
		local deltaTime = Time.deltaTime
        local dragSpeed = 0.1
        cityCamera:DampMove(cameraDragDelta.x, cameraDragDelta.y)
        cameraDragDelta = nil
    end
end

local function OnUICameraClick(go)
    if UICamera.selectedObject == GUIMgr.UITopRoot.gameObject then
        cityCamera:Recover()
    end
	if UICamera.isOverUI then
        return
    end
	local ray = mainCamera:ScreenPointToRay(Controller:GetCurrentPosition())
	if Physics.Raycast(ray) == false then
		MainCityUI.HideCityMenu()
		HideTransitionName()
        cityCamera:Recover()
	end
	MainCityUI.Shousuo()
end

function Awake()
	isAllLoad = false
	buildingInited = false
	isAwake = true
	effect_shengji_gan = ResourceLibrary:GetEffectPrefab("shengji_gan")
	effect_shengji_gebian = ResourceLibrary:GetEffectPrefab("shengji_gebian")
	effect_BornBuild = ResourceLibrary:GetEffectPrefab("BornBuild")
	mainCamera = transform:Find("Main Camera"):GetComponent("Camera")
    uiEventCamera = mainCamera.gameObject:AddComponent(typeof(UICamera))
	--mainCamera.transform.localPosition = defaultCameraPosition
	uiCamera = GUIMgr.UIRoot.transform:Find("Camera"):GetComponent("Camera")
    isGetResBubble = false
	cityCamera = CityCamera(mainCamera, minCameraX, maxCameraX, minCameraY, maxCameraY, minCameraZ, maxCameraZ)
	cityCamera:SetArriveTargetCallback(function()
	    --local buildingData = GetCurrentBuildingData()
	    --if buildingData ~= nil then
	    if currentSelectedBuilding ~= nil then
            NotifyLocateLandListener(currentSelectedBuilding)
        end
        SceneStory.ResumeStory("WaitCamera", "")
	end)
	if cameraBeginPos == nil then
		cameraBeginPos = cityCamera.transform.position
	end
	catchlist = {}
	
	specialList = {}
	SetBuildClickEnable(true)
    local building = transform:Find("building")
	local childCount = building.childCount
	for i = 1, childCount do
		local child = building:GetChild(i - 1)
		if buildingList[child.gameObject.name] ==nil then
			buildingList[child.gameObject.name] = {}
		end
		buildingList[child.gameObject.name].land = child
		if child.gameObject:GetComponent("BoxCollider") ~= nil then
			UIUtil.SetClickCallback(child.gameObject, BuildingClickCallback)
		elseif child.childCount > 0 then
			child:GetChild(0).gameObject.name = child.gameObject.name
			UIUtil.SetClickCallback(child:GetChild(0).gameObject, BuildingClickCallback)
		end
	end
    UIUtil.AddDelegate(UICamera, "onDrag", OnUICameraDrag)
    UIUtil.AddDelegate(UICamera, "onDragEnd", OnUICameraDragEnd)
	UIUtil.AddDelegate(UICamera, "onClick", OnUICameraClick)
	UIUtil.AddDelegate(UICamera, "onPress", OnUICameraPress)
    
    if MainCityUI.IsLoginEnter() then
    	local _data = BuildingData.GetData()
    	UpdateConstruction()
    else
    	GetBuildingListData()
    end
    CheckLevelUp()
	wasteEffect = {}
	wasteEffect[1] = transform:Find("effect/wastelandbak").gameObject
	--wasteEffect[2] = mainCamera.transform:Find("RedMask").gameObject

	ArmyListData.AddListener(Barrack.RequestArmNum)
	ActionListData.AddListener(Barrack.RequestArmNum)
	Global.DisposeRestrictAreaNotify()
end

function Close()
	coroutine.stop(updateConstructionCoroutine)
	coroutine.stop(ShowParadeGroundArmyCoroutine)
	for i, v in pairs(buildingList) do
		v.land = nil
		v.model = nil
		v.transition = nil
	end
	mainCamera = nil
	uiEventCamera = nil
	catchlist = nil
	showQueue = false
	BuildingShowInfoUI.Close()
	--CountDown.Instance:RemoveAll()
	CountDown.Instance:Remove("FreeChest")
	cityCamera = nil
	buildinginforoot = nil
	buildinginforootsize = nil
	wasteEffect = nil
	effect_shengji_gan = nil
	effect_shengji_gebian = nil
	effect_BornBuild = nil
    UIUtil.RemoveDelegate(UICamera, "onDrag", OnUICameraDrag)
	UIUtil.RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    UIUtil.RemoveDelegate(UICamera, "onDragEnd", OnUICameraDragEnd)
	UIUtil.RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	uiCamera = nil
    MainCityQueue.Destroy()
    ArmyListData.RemoveListener(Barrack.RequestArmNum)
    ActionListData.RemoveListener(Barrack.RequestArmNum)
    Barrack.HideParadeGroundArmy()
end

local lastcameramove = false
local lastcamerapos = Vector3.zero
local function CheckCameraMove()
	if cityCamera ~= nil then
		if lastcamerapos ~= cityCamera.transform.position then
			lastcamerapos = cityCamera.transform.position
			return true
		end
	end
	return false
end

function LateUpdate()
    if uiEventCamera.enabled == true then
		local deltaTime = Time.deltaTime
		if cityCamera ~= nil then
			--镜头缩放速度
			local zoomSpeed = 0.1
	        if not UICamera.isOverUI then
				if Controller:IsReleased() then
					isGetResBubble = false
				end
	            if Controller:IsPinch() then
	                local pinchDelta = Controller:GetPinchDelta()
	                cityCamera:Zoom(pinchDelta * zoomSpeed)
	            end
	        end
			cityCamera:Update()
		end
	end
    MainCityUI.UpdateCityMenuPosition()
	
	if OnCameraMove ~= nil and not isPressCameraMove then
		local cameramove = CheckCameraMove()
		--if lastcameramove ~= cameramove then
			--lastcameramove = cameramove
			--if lastcameramove == false then
				if cameramove and OnCameraMove ~= nil then
					OnCameraMove()
				end
			--end
		--end
	end
	needRecheck = true
end

local function ProcessBaseIcons(iconIds, iconTypes, isUpgrading, isHightSpeed)
    if isUpgrading then
        icons = iconTypes[2]
    else
        if isHightSpeed then
            icons = iconTypes[3]
        else
            icons = iconTypes[1]
        end
    end
    for i, v in ipairs(icons) do
        iconIds[i] = {}
        iconIds[i].icon = v
        iconIds[i].enabled = true
    end
    return iconIds
end

function GetCurrentBuildingIconList()
    if buildingList[currentSelectedBuilding] == nil then
        return nil
    end
    local iconIds = {}
    if buildingList[currentSelectedBuilding].data ~= nil and buildingList[currentSelectedBuilding].buildingData.BtnIcon ~= nil then
        local str = buildingList[currentSelectedBuilding].buildingData.BtnIcon:split(";")
        local btns = {}
        local subnum = 0
        for i, v in ipairs(str) do
            btns[i] = {}
            if v:find("|") ~= nil then
                local st = v:split("|")
                btns[i].main = st[1]
                btns[i].sub = {}
                subnum = subnum + 1
                if st[2]:find(",") ~= nil then
                    st = st[2]:split(",")
                    for j, vv in ipairs(st) do
                        btns[i].sub[j] = vv
                    end
                else
                    btns[i].sub[1] = st[2]
                end
            else
                btns[i].main = v
            end
        end
        local iconTypes = {}
        local removeIcons = {}
        for i = 1, subnum + 1 do
            iconTypes[i] = {}
            removeIcons[i] = {}
            local subtime = 1
            for j, v in ipairs(btns) do
                iconTypes[i][j] = {}
                if v.sub ~= nil then
                    subtime = subtime + 1
                    if subtime == i then
                        iconTypes[i][j] = tonumber(v.sub[1])
                        removeIcons[i] = {}
                        for k = 2, #v.sub do
                            removeIcons[i][k-1] = tonumber(v.sub[k])
                        end
                    else
                        iconTypes[i][j] = tonumber(v.main)
                    end
                else
                    iconTypes[i][j] = tonumber(v.main)
                end
            end
		end
        if buildingList[currentSelectedBuilding].data.level >= buildingList[currentSelectedBuilding].buildingData.levelMax then
            for i, v in ipairs(removeIcons) do
                v[#v + 1] = -2
            end
		end
        for i, vi in ipairs(iconTypes) do
            for j = #vi, 1, -1 do
                for _, vr in ipairs(removeIcons[i]) do
                    if vi[j] == - vr then
                        table.remove(vi, j)
                    end
                end
			end
			for ii, vv in ipairs(removeIcons[i]) do
				if vv == 24 then
					table.insert(vi, 3, vv)
				end
			end
        end
        iconIds = ProcessBaseIcons(iconIds, iconTypes, IsCurrentBuildUpgrade(), false)
        if tonumber(buildingList[currentSelectedBuilding].buildingData.showType) == 8 then --资源建筑
            for i, v in ipairs(iconIds) do
                if v.icon == 4 then
                    if DisplayResourceNumber(buildingList[currentSelectedBuilding]) == 1 then
                        v.enabled = true
                    else
                        v.enabled = false
                    end
                end
            end
        end
        --模仿上面搞特殊处理
        return iconIds
    end
    if currentSelectedBuilding:find("ziyuantian_") ~= nil then
        if buildingList[currentSelectedBuilding].unlock then
        	local setIcons = function(index, id)
        		iconIds[index] = {}
                iconIds[index].icon = id
                iconIds[index].enabled = true
        	end
            setIcons(1,100)
            setIcons(2,101)
            setIcons(5,102)
            setIcons(6,103)
            setIcons(3,104)
			setIcons(4,105)
        end
        return iconIds
    end
    return nil
end

--获取正在建造中的建筑信息
function GetUpgradingBuildList()
    local upgrading = {}
    local index = 0
    local nowTime = Serclimax.GameTime.GetSecTime()
    for _, v in pairs(buildingList) do
        if v.data ~= nil then
        	if v.data.donetime > nowTime then
	            index = index + 1
	            upgrading[index] = v
	        end
        end
    end
    return upgrading
end

function IsUpgrading(id, level)
	local _building = GetBuildingByID(id)
	if _building == nil then
		return false
	end
	if _building.data.level + 1 == level and _building.data.donetime > Serclimax.GameTime.GetSecTime() then
		return true
	end
	if level == nil and _building.data.donetime > Serclimax.GameTime.GetSecTime() then
		return true
	end
	return false
end

function GetWorkerIsInCooldown()
    return #GetUpgradingBuildList() > 0
end

--当前建筑是否在升级中
function IsCurrentBuildUpgrade()
    local nowTime = Serclimax.GameTime.GetSecTime()
    return buildingList[currentSelectedBuilding].data.donetime > nowTime
end

--获取当前建筑升级前置条件
function GetCurrentUpgradePrecondition(building)
    local unlockCondition
    if building ~= nil then
        unlockCondition = building.upgradeData.unlockCondition
    else
        unlockCondition = buildingList[currentSelectedBuilding].upgradeData.unlockCondition
    end
    if unlockCondition == "NA" then
        return nil
    end
    unlockCondition = unlockCondition:split(";")
    local precondition = {}
    for i, v in ipairs(unlockCondition) do
        local temp = v:split(":")
        precondition[i] = {}
        precondition[i].type = temp[1]
        precondition[i].id = temp[2]
        precondition[i].value = temp[3]
    end
    return precondition
end

function IsBuildingUnlockByID(id)
	local _buildingData = TableMgr:GetBuildingData(id)
	local unlockCondition = _buildingData.unlockCondition
	if unlockCondition == "NA" then
        return true
    end
    unlockCondition = unlockCondition:split(";")
    local canUnlock
    local lockstr = ""
    for i, v in ipairs(unlockCondition) do
        local temp = v:split(":")
        if tonumber(temp[1]) == 1 then
        	if tonumber(temp[3]) <= GetBuildingLevelByID(temp[2]) then
                canUnlock = true
            else
                canUnlock = false
                lockstr = lockstr .. System.String.Format(TextMgr:GetText("build_ui28"), TextMgr:GetText(TableMgr:GetBuildingData(tonumber(temp[2])).name), temp[3])
				
            end
        else
            if tonumber(temp[3]) <= GetBuildingCount(temp[2]) then
            	canUnlock = true
            else
                canUnlock = false
                lockstr = lockstr .. System.String.Format(TextMgr:GetText("build_ui29"), TextMgr:GetText(TableMgr:GetBuildingData(tonumber(temp[2])).name), temp[3])
        	end
        end
    end
    return canUnlock, lockstr
end

--获取当前建筑升级需要资源
function GetCurrentUpgradeResource(building)
    local needItem
    if building ~= nil then
        needItem = building.upgradeData.needItem
    else
        needItem = buildingList[currentSelectedBuilding].upgradeData.needItem
    end
    if needItem == "NA" then
        return nil
    end
    needItem = needItem:split(";")
    local resources = {}
    for i, v in ipairs(needItem) do
        local temp = v:split(":")
        resources[i] = {}
        resources[i].id = temp[1]
        resources[i].num = temp[2]
    end
    return resources
end

--当前建筑的逻辑类型
function GetCurrentBuildingLogicType()
    return buildingList[currentSelectedBuilding].buildingData.logicType
end

--当前建筑的显示类型
function GetCurrentBuildingShowType()
    return buildingList[currentSelectedBuilding].buildingData.showType
end

--获取某ID建筑数量
function GetBuildingCount(id)
	--clear
	for i, v in pairs(specialList) do
		specialList[i] = nil
	end
	
	local index = 0
    local count = 0
	
    for i, v in pairs(buildingList) do
        if v.buildingData ~= nil then
            if tonumber(v.buildingData.id) == tonumber(id) and v.data ~= nil then
				specialList[count] = v
                count = count + 1
            end
        end
    end
    return count
end

function GetSpecialBuildList()
	return specialList
end

function GetBuildingByID(id)
	if buildingList == nil then
		return nil
	end
    for i, v in pairs(buildingList) do
        if v.buildingData ~= nil then
            if tonumber(v.buildingData.id) == tonumber(id) then
                return v
            end
        end
    end
    return nil
end

function GetBuildingByUID(uid)
    for i, v in pairs(buildingList) do
        if v.data ~= nil then
            if tonumber(v.data.uid) == tonumber(uid) then
                return v
            end
        end
    end
    return nil
end

function GetBuildingMatch(buildingName)
	for k, v in pairs(buildingList) do
	    if string.match(k, buildingName) then
	        return v
        end
    end
end

function RefreshBuildingList(msg)
	AudioMgr:PlayUISfx("SFX_UI_start_building", 1, false)
	local build = msg.build
	BuildingData.GetData().workercdtime = msg.workercdtime
	UpdateBuildInMsg(build, msg.build.donetime)
end

function RefreshResourceTime(msg)
    for _, v in pairs(buildingList) do
        if v.data ~= nil then
            if v.data.uid == msg.uid then
                v.data.gathertime = msg.gathertime
            end
        end
    end
end

function DisplayResourceNumber(build)
	local ret = 0 
	if build == nil then
		return
	end
	
	--local build = GetCurrentBuildingData()
	if build.buildingData ~= nil then
		if build.buildingData.logicType == 10 then
			local lastGetTime = build.data.gathertime
			local nowTime = Serclimax.GameTime.GetSecTime()
			local passTime = nowTime - lastGetTime
			if passTime > 60 then
				ret = 1
			end
		end
	end
	return ret
end

function GetBuildingMaxCount(id)
	local str = TableMgr:GetBuildingData(id).buildAmount:split(";")
    for i, w in ipairs(str) do
        local s = w:split(":")
        if #s > 1 then
            if tonumber(s[1]) <= GetBuildingByID(1).data.level and tonumber(s[2]) >= GetBuildingByID(1).data.level then
                return tonumber(s[3])
            end
        end
    end
end

function CheckLevelByID(id, lv)
	local templevel = 0
	for i, v in pairs(buildingList) do
		if v.data ~= nil then 
			if v.data.type == tonumber(id) then
				if v.data.level > templevel then
					templevel = v.data.level
				end
				if tonumber(v.data.level) >= tonumber(lv) then
					return true, v.data.level
				end
			end
		end
	end
	return false, templevel
end

function GetEmptyZiyuantian()
	local n = 50
	for i, v in pairs(buildingList) do
		if v.land.name:find("ziyuantian_") ~= nil and v.data == nil and v.unlock then
			local s = tonumber(v.land.name:split("_")[2])
			if s < n then
				n = s
			end
		end
	end
	return buildingList["ziyuantian_" .. n]
end

function GetEmptyLand()
	for i = 1, 7 do
		if buildingList["ziyuan" .. i].land.gameObject.activeInHierarchy then
			return buildingList["ziyuan" .. i]
		end
	end
	return nil
end

function SetEmptyZiyuantianTarget(moveTo, autoMode)
	_b = GetEmptyZiyuantian()
	if _b ~= nil then
		currentSelectedBuilding = _b.land.name
		cityCamera:SetTargetPosition(_b.land.transform.position, moveTo, autoMode)
		if moveTo then
		else
			MainCityUI.ShowCityMenu(mainCamera,_b.land.gameObject)
			MainCityUI.SetTargetFlash(_b.land)
		end
	else
		AudioMgr:PlayUISfx("SFX_ui02", 1, false)
		FloatText.Show(TextMgr:GetText("build_ui41"), Color.white)
	end
end

function SetEmptyLandTarget(moveTo, autoMode)
	_b = GetEmptyLand()
	if _b ~= nil then
		currentSelectedBuilding = _b.land.name
		cityCamera:SetTargetPosition(_b.land.transform.position, moveTo, autoMode)
		if moveTo then
		else
			MainCityUI.ShowCityMenu(mainCamera,_b.land.gameObject)
			MainCityUI.SetTargetFlash(_b.land)
		end
	else
		AudioMgr:PlayUISfx("SFX_ui02", 1, false)
		FloatText.Show(TextMgr:GetText("build_ui41"), Color.white)
	end
end

function SetTargetZiyuantian(targetLevel, showmenu, moveTo, autoMode, callback)
	local _b
	for i, v in pairs(buildingList) do
		if v.data ~= nil and v.data.type >= 11 and v.data.type <= 14 then
			if _b == nil then
				if targetLevel ~= nil then
					if v.data.level < targetLevel then
						_b = v
					end
				else
					_b = v
				end
			else
				if targetLevel ~= nil then
					if _b.data.level < v.data.level and v.data.level < targetLevel then
						_b = v
					end
				else
					if _b.data.level < v.data.level then
						_b = v
					end
				end
			end
		end
	end
	print(_b)
	if _b ~= nil then
		currentSelectedBuilding = _b.land.name
		cityCamera:SetTargetPosition(_b.land.transform.position, moveTo, autoMode)
		if showmenu == nil or showmenu == true then
			MainCityUI.ShowCityMenu(mainCamera,_b.land.gameObject)
		end
		MainCityUI.SetTargetFlash(_b.land)
	else
		local _d = TableMgr:GetBuildingData(11)
		_b = buildingList[_d.land]
		if _b == nil then
			_b = GetEmptyZiyuantian()
			if _b ~= nil then
				currentSelectedBuilding = _b.land.name
				cityCamera:SetTargetPosition(_b.land.transform.position, moveTo, autoMode)
				if showmenu == nil or showmenu == true then
					MainCityUI.ShowCityMenu(mainCamera,_b.land.gameObject)
				end
				MainCityUI.SetTargetFlash(_b.land)
			else
				AudioMgr:PlayUISfx("SFX_ui02", 1, false)
				FloatText.Show(TextMgr:GetText("build_ui41"), Color.white)
			end
		else
			currentSelectedBuilding = _b.land.name
			cityCamera:SetTargetPosition(_b.land.transform.position, moveTo, autoMode)
			MainCityUI.SetTargetFlash(_b.land)
		end
	end
	if callback ~= nil then
		MainCityUI.SetShowMenuCallBack(mainCamera, _b.land.gameObject, callback, 0.3)
	end
end

function GetMinLevelBarrack()
	local _b = nil
	local blist = {21, 22, 23, 24}
	for i, v in pairs(buildingList) do
		if v.data ~= nil and (v.data.type == 21 or v.data.type == 22 or v.data.type == 23 or v.data.type == 24) then
			for ii, vv in ipairs(blist) do
				if vv == v.data.type then
					table.remove(blist, ii)
				end
			end
			if _b == nil then
				if v.data.level < 10 then
					_b = v
				end
			else
				if _b.data.level > v.data.level then
					_b = v
				end
			end
		end
	end
	if _b == nil and #blist > 0 then
		local _d = TableMgr:GetBuildingData(blist[1])
		if _d == nil then
			print("Build表没有ID为" .. id .. "的数据")
			return
		end
		_b = buildingList[_d.land]
	end
	return _b
	--return _b ~= nil and _b.land.gameObject or nil
end

function GetHospital()
	for i, v in pairs(buildingList) do
		if v.buildingData ~= nil and v.buildingData.logicType == 10 and v.buildingData.showType == 3 then
			return v
		end
	end
end

function IsBarrackEmpty(id)
	local _b = GetBuildingByID(id)
	return _b ~= nil and Barrack.GetTrainInfo(id) == nil 
end

function GetEmptyBarrackOnly()
	for i = 21, 24 do
		local _b = GetBuildingByID(i)
		if _b ~= nil and Barrack.GetTrainInfo(i) == nil then
			--return _b.land.gameObject
			return _b
		end
	end
	return nil
end

function GetEmptyBarrack()
	local _b = GetEmptyBarrackOnly()
	if _b ~= nil then
		return _b
	end
	return GetBuildingByID(21)
	--return GetBuildingByID(21).land.gameObject
end

function SetTargetBuild(id, showarrow, targetLevel, showmenu, moveTo, autoMode, callback, findmin)
	HideTransitionName()
	local _b
	for i, v in pairs(buildingList) do
		if v.data ~= nil and (findmin == true and (v.data.type >= 11 and v.data.type <= 14) or v.data.type == tonumber(id)) then
			if _b == nil then
				if targetLevel ~= nil then
					if v.data.level < targetLevel then
						_b = v
					end
				else
					_b = v
				end
			else
				if targetLevel ~= nil then
					if _b.data.level < v.data.level and v.data.level < targetLevel then
						_b = v
					end
				else
					if not findmin then
						if _b.data.level < v.data.level then
							_b = v
						end
					else
						if _b.data.level > v.data.level then
							_b = v
						end
					end
				end
			end
		end
	end
	local targetPosition
	if _b ~= nil and _b.land ~= nil then
		currentSelectedBuilding = _b.land.name
		if _b.transition ~= nil then
			_b.transition.head.gameObject:SetActive(true)
		end
		targetPosition = _b.land.transform.position
		if showmenu == nil or showmenu == true then
			MainCityUI.ShowCityMenu(mainCamera,_b.land.gameObject)
		end
		MainCityUI.SetTargetFlash(_b.land)
		if callback ~= nil then
			MainCityUI.SetShowMenuCallBack(mainCamera, _b.land.gameObject, function() callback(_b) end, 0.3)
		end
	else
		local _d = TableMgr:GetBuildingData(id)
		if _d == nil then
			print("Build表没有ID为" .. id .. "的数据")
			return
		end
		_b = buildingList[_d.land]
		if _b == nil then
			_b = GetEmptyZiyuantian()
			if _b ~= nil then
				currentSelectedBuilding = _b.land.name
				targetPosition = _b.land.transform.position
				if showmenu == nil or showmenu == true then
					MainCityUI.ShowCityMenu(mainCamera,_b.land.gameObject)
				end
				MainCityUI.SetTargetFlash(_b.land)
			else
				AudioMgr:PlayUISfx("SFX_ui02", 1, false)
				FloatText.Show(TextMgr:GetText("build_ui41"), Color.white)
			end
		else
			if _b.land ~= nil then
				currentSelectedBuilding = _b.land.name
				targetPosition = _b.land.transform.position
				MainCityUI.SetTargetFlash(_b.land)
			end
		end
		if callback ~= nil then
			callback(_b)
		end
	end
	if targetPosition ~= nil then
		cityCamera:SetTargetPosition(targetPosition, moveTo, autoMode)
	end
	
	--[[
	if showarrow ~= nil and showarrow and _b ~= nil and _b.transition ~= nil then
		_b.transition.arrow.gameObject:SetActive(true)
		local coroutine = coroutine.start(function()
			coroutine.wait(5)
			_b.transition.arrow.gameObject:SetActive(false)
		end)
	end
	--]]
	return _b
end

function SetTargetBlock(id)
	if id ~= nil then
		currentSelectedBuilding = "ziyuan" .. id
		cityCamera:SetTargetPosition(buildingList["ziyuan" .. id].land.transform.position, false, false)
		MainCityUI.SetTargetFlash(buildingList["ziyuan" .. id].land)
	else
		for i = 1, 7 do
			if buildingList["ziyuan" .. i].unlockLand then
				currentSelectedBuilding = "ziyuan" .. id
				cityCamera:SetTargetPosition(buildingList["ziyuan" .. i].land.transform.position, false, false)
				MainCityUI.SetTargetFlash(buildingList["ziyuan" .. i].land)
				return
			end
		end
	end
end

function SetTargetBuildByUid(uid, showarrow)
	local _b
	for i, v in pairs(buildingList) do
		if v.data ~= nil and v.data.uid == tonumber(uid) then
			if _b == nil then
				_b = v
			elseif _b.data.level < v.data.level then
				_b = v
			end
		end
	end
	if _b ~= nil then
		currentSelectedBuilding = _b.land.name
		cityCamera:SetTargetPosition(_b.land.transform.position, false, false)
		MainCityUI.ShowCityMenu(mainCamera,_b.land.gameObject)
		MainCityUI.SetTargetFlash(_b.land)
	else
		--FloatText.Show(TextMgr:GetText("build_ui41"), Color.white)
		local _d = TableMgr:GetBuildingData(id)
		_b = buildingList[_d.land]
		if _b ~= nil then
			currentSelectedBuilding = _b.land.name
			cityCamera:SetTargetPosition(_b.land.transform.position, false, false)
			MainCityUI.SetTargetFlash(_b.land)
		end
	end
	if showarrow ~= nil and showarrow then
		--[[
		_b.transition.arrow.gameObject:SetActive(true)
		local coroutine = coroutine.start(function()
			coroutine.wait(5)
			_b.transition.arrow.gameObject:SetActive(false)
		end)
		]]
	end
end

function CaculateGoldForRes(_type, _value)
	local _data = TableMgr:GetResourcePriceData()
	local _v = tonumber(_value)
	local gold = 0
	local _prev = 0
	for _ , v in ipairs(_data) do
		local _iter = v
		if _iter.Type == tonumber(_type) and _iter.Min <= _v then
			if _iter.Max >= _v then
				gold = gold + (_iter.Price * (_v - _prev))
			else
				gold = gold + (_iter.Price * (_iter.Max - _prev))
				_prev = _iter.Max
			end
		end
	end
	
	--[[local _d = _data:GetEnumerator()
	while _d:MoveNext() do
		local _iter = _d.Current.Value
		if _iter.Type == tonumber(_type) and _iter.Min <= _v then
			if _iter.Max >= _v then
				gold = gold + (_iter.Price * (_v - _prev))
			else
				gold = gold + (_iter.Price * (_iter.Max - _prev))
				_prev = _iter.Max
			end
		end
	end]]
	return gold
end

function CaculateGoldForTime(_type, _value)
	return SpeedUpprice.GetPrice(_type,_value)
end

local count

function GetItemExchangeListNoCommon(_type)
	local items = {}
	count = 0
	MakeItems(items, _type)
	return items
end

function GetItemExchangeList(_type)
	local items = GetItemExchangeListNoCommon(tonumber(_type) + 1)
	MakeItems(items, 1)
	return items
end

function MakeItems(items, id)
	local _data = TableMgr:GetItemExchangeListData(id).itemID
	str = _data:split(";")
	local c = 0
	for i,v in ipairs(str) do
		items[count + i] = {}
		local itemPar = {}
		itemPar = v:split(":")
		items[count + i].itemid = tonumber(itemPar[1])
		items[count + i].exid = tonumber(itemPar[2])
		c = i
	end
	count = count + c
end

function GetItemResList(id)
	local items = {}
	count = 0
	MakeItems(items, tonumber(id) + 2)
	return items
end

function SetBuildTarget(go)
	cityCamera:SetTargetPosition(go.transform.position, false, false)
	MainCityUI.SetTargetFlash(go)
end

function SetBuildTargetByID(id, showarrow)
	local _build = GetBuildingByID(id)
	if _build ~= nil then
		SetBuildTarget(_build.land.gameObject)
	end
	if showarrow ~= nil and showarrow then
		--[[
		_build.transition.arrow.gameObject:SetActive(true)
		local coroutine = coroutine.start(function()
			coroutine.wait(5)
			_build.transition.arrow.gameObject:SetActive(false)
		end)
		]]
	end
end

function SetBuildTargetByUID(uid)
	local _build = GetBuildingByUID(uid)
	if _build ~= nil then
		SetBuildTarget(_build.land.gameObject)
	end
	if showarrow ~= nil and showarrow then
		--[[
		_build.transition.arrow.gameObject:SetActive(true)
		local coroutine = coroutine.start(function()
			coroutine.wait(5)
			_build.transition.arrow.gameObject:SetActive(false)
		end)
		]]
	end
end

function GetResBtn(name)
	if buildingList[name]~= nil and buildingList[name].icon ~= nil then
		return buildingList[name].icon.gameObject.transform:Find("Pivot/bg").gameObject
	end
	return nil
end

function GetResBtnMatch(name)
    for k, v in pairs(buildingList) do
        if string.match(k, name) then
            if v.icon ~= nil then
                return v.icon.gameObject.transform:Find("Pivot/bg").gameObject
            end
        end
    end

	return nil
end

function UseResItemFunc(useItemId , exItemid , count)
	print("Useid : " .. useItemId .. "exid : " .. exItemid .. "count :" .. count)
	local itemTBData = TableMgr:GetItemData(useItemId)
	local itemdata = ItemListData.GetItemDataByBaseId(useItemId)

	local req = ItemMsg_pb.MsgUseItemRequest()
	if itemdata ~= nil then
		req.uid = itemdata.uniqueid
	else
		req.exchangeId = exItemid
	end
	req.num = count
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemRequest, req, ItemMsg_pb.MsgUseItemResponse, function(msg)
		print("use item code:" .. msg.code)
		if msg.code == 0 then
			local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
			if price == 0 then
				GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
			else
				GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
			end
			--AudioMgr:PlayUISfx("SFX_UI_building_speed", 1, false)
			useItemReward = msg.reward
			AudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
			
			--[[local nameColor = Global.GetLabelColorNew(itemTBData.quality)
			local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1])
			FloatText.Show(showText , Color.white,ResourceLibrary:GetIcon("Item/", itemTBData.icon))]]
			for i=1 , #msg.reward.item.item , 1 do
				local item_data = TableMgr:GetItemData(msg.reward.item.item[i].baseid)
				FloatText.Show(TextUtil.GetItemName(item_data).."x"..msg.reward.item.item[i].num , Color.green,ResourceLibrary:GetIcon("Item/", item_data.icon))
			end
			
			--maincity.GetBuildingListData()
			--MoneyListData.UpdateData(msg.fresh.money.money)
			--MainData.UpdateData(msg.fresh.maindata)
			--ItemListData.UpdateData(msg.fresh.item)
			MainCityUI.UpdateRewardData(msg.fresh)
			if FinishBuildCallBack ~= nil then
				if BuildingUpgrade.gameObject ~= nil then
					FinishBuildCallBack()
				else
					FinishBuildCallBack = nil
				end
			end
			MainCityQueue.UpdateQueue()
		else
			Global.FloatError(msg.code, Color.white)
		end
	end, true)
end

function IsAllLoaded()
	return isAllLoad
end

function Hide()
	BuildingShowInfoUI.Close()
    --transform.parent.gameObject:SetActive(false)
    --[[
    local shadowMapGameObject = GameObject.Find("ShadowMap")
     print("**************************",shadowMapGameObject,transform.parent.gameObject.name)
    if shadowMapGameObject ~= nil then
        shadowMapGameObject:SetActive(false)
    end
	--]]
	MainCityUI.HideCityMenu()
	MainCityUI.HideQuickMission()
	-- MainCityUI.HideHeadBar()
	MainCityUI.HideArrayBar()
	MainCityUI.HideBattle()
	MainCityUI.HideOnlineReward()
	MainCityUI.CloseJionUnionFirst()
	if transform == nil then
		return
	end
	if cityCamera ~= nil then
		cityCamera:Recover()
		cityCamera.transform.position = cameraBeginPos
	end
	GameObject.Destroy(transform.parent.gameObject)
	Close()
end

function Show()
	if transform ~= nil and not transform:Equals(nil) then
		transform.parent.gameObject:SetActive(true)
	else
		Global.LoadMainCity();
		--GameStateMain:LoadMainCity("maincity")
	end
    --transform.parent.gameObject:SetActive(true)
	--[[
    local shadowMapGameObject = GameObject.Find("ShadowMap")
    print("**************************",shadowMapGameObject,transform.parent.gameObject.name)
    if shadowMapGameObject ~= nil then
        shadowMapGameObject:SetActive(true)
    end
    --]]
    MainCityUI.ShowQuickMission()
    MainCityUI.ShowHeadBar()
    MainCityUI.ShowArrayBar()
    MainCityUI.ShowBattle()
	MainCityUI.ShowOnlineReward()
	MainCityUI.OpenJoinUnionFirst()
end

function ShowWastEffect(flag)
	if wasteEffect == nil or wasteEffect[1] == nil or wasteEffect[1]:Equals(nil) then
		return
	end

	local curActive = wasteEffect[1].activeSelf
	if flag then
		if not curActive then
			table.foreach(wasteEffect , function(i , v)
				v:SetActive(true)
			end)
			GUIMgr:EnableDestroyEffect(true)
		end
	else
		if curActive then
			table.foreach(wasteEffect , function(i , v)
				v:SetActive(false)
			end)
			GUIMgr:EnableDestroyEffect(false)
		end
	end
	--transform:Find("effect/wastelandbak").gameObject:SetActive(flag)
	--mainCamera:Find("RedMask").gameObject:SetActive(flag)
end

function OnEnable()
	CheckLevelUp()
    local burning = DefenseData.GetData().cginfo.fireing
	ShowWastEffect(burning)
	--UpdateConstruction()
end


function isInMainCity()
    if transform == nil or not transform.gameObject.activeSelf then
        return false
    end
    return true
end

function IsAllBuildingMaxLevel()
	for i, v in pairs(buildingList) do
		if not (string.find(i, "ziyuan") or string.find(i,"chengqiang_02")) then
			if v.data == nil or v.buildingData == nil then
				return false
			else
				if v.data.level < v.buildingData.levelMax then
					return false
				end
			end
		end
	end
	return true
end

module("ResViewDetails",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
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

local specialBuilding
local resBuildInfo

local _ui

local function QuitPressCallback(go, isPressed)
	if not isPressed then
		GUIMgr:CloseMenu("ResViewDetails")
	end
end

local function UpgradePressCallBack(go , isPressed)
	if not isPressed then
		local uid = go.gameObject.name
		local build = maincity.GetBuildingByUID(uid)
		BuildingUpgrade.SetTargetBuilding(build)
		GUIMgr:CreateMenu("BuildingUpgrade" , false)
		BuildingUpgrade.OnCloseCB = function()
			LoadUI()
		end
	end
end

function SetResBuildInfo(info)
	resBuildInfo = info
	local buildingData = TableMgr:GetBuildingData(resBuildInfo.buildId)
	
	if buildingData.logicType == 10 and buildingData.showType == 7 then
		local count = maincity.GetBuildingCount(resBuildInfo.buildId)
		local list = {}
		list = maincity.GetSpecialBuildList()
		
		local yield = 0
		local speed = 0
		for _, v in pairs(list) do
			if v.buildingData ~= nil and v.data ~= nil then
				local callupdata = TableMgr:GetCallUpData(v.data.level)
				yield = yield + callupdata.number
				speed = speed + callupdata.speed
			end
		end
		resBuildInfo.totalYield = yield
		resBuildInfo.totalSpeed = speed
	end
end

local function ShowResourceBuildingDetail(item , v)
	local detailGrid = item.transform:Find("Grid")
	local detail = NGUITools.AddChild(detailGrid.gameObject , _ui.contentItemDetail.gameObject)
	detail.gameObject:SetActive(true)
	detail.transform:SetParent(detailGrid , false)
	detailGrid:GetComponent("UIGrid"):Reposition()
	
	local textLabel = detail.transform:Find("text"):GetComponent("UILabel")
	textLabel.text = TextMgr:GetText("build_ui42") .. ":"
	local numLabel = detail.transform:Find("num"):GetComponent("UILabel")
	local baseYield = TableMgr:GetBuildingResourceYield(v.buildingData.id , v.data.level)
	local params = {}
	params.base = baseYield
	local finalYield = ResView.GetExAddYield(v.buildingData.id , params , v.data.uid)
	local addYield = math.ceil(finalYield - baseYield)

	--format : xx/h (+yy/h)
	numLabel.text = baseYield .. TextMgr:GetText("build_ui15") .. "    [00ff00](+" .. addYield .. TextMgr:GetText("build_ui15").. ")[-]"
	
end

local function ShowCallUpDetail(item , v)
	local callUpData = TableMgr:GetCallUpData(v.data.level)
	local detailGrid = item.transform:Find("Grid")
	local detailnumber = NGUITools.AddChild(detailGrid.gameObject , _ui.contentItemDetail.gameObject)
	detailnumber.gameObject:SetActive(true)
	detailnumber.transform:SetParent(detailGrid , false)
	local textLabel = detailnumber.transform:Find("text"):GetComponent("UILabel")
	textLabel.text = TextMgr:GetText("setting_ui36") .. ":"
	local numLabel1 = detailnumber.transform:Find("num"):GetComponent("UILabel")
	numLabel1.text = callUpData.number
	
	detailspeed = NGUITools.AddChild(detailGrid.gameObject , _ui.contentItemDetail.gameObject)
	detailspeed.gameObject:SetActive(true)
	detailspeed.transform:SetParent(detailGrid , false)
	local textLabel = detailspeed.transform:Find("text"):GetComponent("UILabel")
	textLabel.text = TextMgr:GetText("setting_ui37") .. ":"
	local numLabel2 = detailspeed.transform:Find("num"):GetComponent("UILabel")
	numLabel2.text = callUpData.speed .. "%"
	
	detailGrid:GetComponent("UIGrid"):Reposition()
end

local function ShowClinicDetail(item , v)
	local clinicData = TableMgr:GetClinicData(v.data.level)
	local detailGrid = item.transform:Find("Grid")
	local detail = NGUITools.AddChild(detailGrid.gameObject , _ui.contentItemDetail.gameObject)
	detail.gameObject:SetActive(true)
	detail.transform:SetParent(detailGrid , false)
	detailGrid:GetComponent("UIGrid"):Reposition()
	
	local textLabel = detail.transform:Find("text"):GetComponent("UILabel")
	textLabel.text = TextMgr:GetText("hospital_ui6") .. ":"
	local numLabel = detail.transform:Find("num"):GetComponent("UILabel")
	--format : xx/h (+yy/h)
	numLabel.text = clinicData.hurt
end


local function ShowTotalCount(resBuildInfo , buildingData)
	local des = transform:Find("Container/text_miaoshu"):GetComponent("UILabel")
	local num = transform:Find("Container/text_miaoshu/num"):GetComponent("UILabel")
	local des1 = transform:Find("Container/text_miaoshu (1)"):GetComponent("UILabel")
	local num1 = transform:Find("Container/text_miaoshu (1)/num"):GetComponent("UILabel")
	
	if buildingData.showType == 7 then
		des.text = TextMgr:GetText("setting_ui38") .. ":"
		num.text = resBuildInfo.totalYield
		des1.gameObject:SetActive(true)
		des1.text = TextMgr:GetText("setting_ui39") .. ":"
		num1.text = math.ceil(resBuildInfo.totalSpeed) .. "%"
	elseif buildingData.showType == 3 then
		des.text = TextMgr:GetText("hospital_ui6") .. ":"
		num.text = resBuildInfo.totalYield
	else
		--9.5只有总产量
		des.text = TextMgr:GetText("build_ui16") .. ":"
		num.text = resBuildInfo.totalYield .. TextMgr:GetText("build_ui15")
	end
end

function Awake()
	
	_ui = {}
	_ui.contentGrid = transform:Find("Container/Scroll View/Grid")
	_ui.contentItem = transform:Find("ResViewDetailsinfo")
	_ui.contentItemDetail = transform:Find("ResViewDetailsNuminfo")
	
	
	--tittle & close & description
	_ui.btnQuit = transform:Find("Container/bg_frane/bg_top/btn_close")
	SetPressCallback(_ui.btnQuit.gameObject, QuitPressCallback)
	SetPressCallback(transform:Find("Container").gameObject, QuitPressCallback)
	SetPressCallback(transform:Find("mask").gameObject, QuitPressCallback)
	
end

function Close()
	_ui = nil
end

function LoadUI()
	local buildCount = maincity.GetBuildingCount(resBuildInfo.buildId)
	local buildList = {}
	buildList = maincity.GetSpecialBuildList()
	local buildingData = TableMgr:GetBuildingData(resBuildInfo.buildId)
	
	local tittle = transform:Find("Container/bg_frane/bg_top/title"):GetComponent("UILabel")
	tittle.text = TextMgr:GetText(buildingData.name)
	
	ShowTotalCount(resBuildInfo , buildingData)
	
	--scroll content
	
	
	while _ui.contentGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(_ui.contentGrid.transform:GetChild(0).gameObject)
	end
		
	for _, v in pairs(buildList) do
		local item = NGUITools.AddChild(_ui.contentGrid.gameObject , _ui.contentItem.gameObject)
		item.gameObject:SetActive(true)
		item.transform:SetParent(_ui.contentGrid , false)
		
		--icon
		local resIcon = item.transform:Find("bg_icon/Texture"):GetComponent("UITexture")
		resIcon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "building/", v.buildingData.icon)
		
		--level
		local level = item.transform:Find("bg_icon/text"):GetComponent("UILabel")
		level.text = "Lv.".. v.data.level
		
		--update button
		local btnGo = item.transform:Find("btn_go")
		btnGo.gameObject.name = v.data.uid
		SetPressCallback(btnGo.gameObject, UpgradePressCallBack)
		if v.data.level == v.buildingData.levelMax then
			btnGo.gameObject:SetActive(false)
		end
		
		--detail
		if v.buildingData.showType == 7 then
			ShowCallUpDetail(item , v)
		elseif v.buildingData.showType == 3 then
			ShowClinicDetail(item , v)
		else
			ShowResourceBuildingDetail(item , v)
		end
	end
	
	local gridCom = _ui.contentGrid:GetComponent("UIGrid")
	gridCom:Reposition()	

end


function Start()
	LoadUI()
end


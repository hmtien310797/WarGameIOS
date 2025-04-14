module("MobaEmbattle", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local EmbattleUI

local leftForm

local rightForm
local mobaBuildingPreForm
local mobaBuildingUID = 0

local Formation

local CloseCallBack

local ParadeGroundDisplay
local BattleMoveDisplay
local MobaBuildingDisplay
local CurDisplay = ""
local ParadeGroundTitle
local EmbattleTitle
local FormationType
local EditorState
local Tips


function Hide()
    Global.CloseUI(_M)
    EditorState = nil
end

function CloseAll()
    Hide()
	CurDisplay = ""
end

function SaveFormation()
	if Formation == nil then
		return
	end
	local form = Formation:GetSelfFormation()
	--table.foreach(form , function(_,v)
	--	print(v)
	--end)
	
	MobaBattleMoveData.SaveFormation(FormationType , form , function()
		print("formation save . ftype : " .. FormationType)
		if FormationType == 2 then
			--RadarData.SetDefendForm(form)
		end
	end)
end

function SaveBuildingFormation()
	if Formation == nil then
		return
	end
	local form = Formation:GetSelfFormation()
	--local form = Formation:GetRightFormation()
	
	--table.foreach(form , function(_,v)
	--	print(v)
	--end)
	
	if Formation:Equals(form , mobaBuildingPreForm) then
		return
	end
	
	MobaBattleMoveData.SaveBuildingFormation(FormationType , form , mobaBuildingPreForm , mobaBuildingUID , function(success)
		print("formation save . ftype : " .. FormationType)
		if not success then
			CloseAll()
		end
		
		MobaBattleMoveData.CloneFormation(mobaBuildingPreForm,form)
		if FormationType == 2 then
			--RadarData.SetDefendForm(form)
		end
	end)
end

function ShowAttackFormation()
	print("attack formation")
	MobaBattleMoveData.GetOrReqUserAttackFormaion(function(form)
		local selfFormation = {}
		MobaBattleMoveData.CloneFormation(selfFormation,form)
		if EmbattleTitle ~= nil and ParadeGroundTitle ~= nil then
			EmbattleTitle.text = "出征"
			ParadeGroundTitle.text = "出征阵容"
			Show(1,selfFormation,nil,function(new_form)
			--selfFormation = new_form
			--formationSmall:SetLeftFormation(selfFormation)
			--formationSmall:Awake(false)
			end , "ParadeGround")
		end
	end)
end

local function ShowDefenceFormation()
	print("defense formation")
	MobaBattleMoveData.GetOrReqUserDefendFormaion(function(form)
		local selfFormation = {}
		MobaBattleMoveData.CloneFormation(selfFormation,form)
		if EmbattleTitle ~= nil and ParadeGroundTitle ~= nil then
			EmbattleTitle.text = "城防"
			ParadeGroundTitle.text = "城防阵容"
			Show(2,nil,selfFormation,function(new_form)
			--selfFormation = new_form
			--formationSmall:SetLeftFormation(selfFormation)
			--formationSmall:Awake(false)
			end , "ParadeGround")
		end
	end)
	
	
end

local function ClickAttackBtnCallback(go)
	--SaveFormation(2)
	FormationType = 1
	ShowAttackFormation()
end

local function ClickDefensBtnCallback(go)
	--SaveFormation(1)
	FormationType = 2
	ShowDefenceFormation()
end

local function CloseClickCallback(go)
    Hide()

    if CloseCallBack ~= nil then
        CloseCallBack(leftForm)
    end
    CloseCallBack = nil
end

local function LoadUIForMailReport()
    Formation = BMFormation(transform:Find("Container/bg_frane/Embattle"))
    Formation:SetPVPMailLeftFormationData(leftForm)
    Formation:SetPVPMailRightFormationData(rightForm)

    Formation:Awake(EditorState)

    SetClickCallback(transform:Find("Container/bg_frane/bg_top/btn_close").gameObject,CloseClickCallback)
end

local function LoadUIForMobaBuilding()
	MobaBuildingDisplay.gameObject:SetActive(true)
		ParadeGroundDisplay.gameObject:SetActive(false)
		BattleMoveDisplay.gameObject:SetActive(false)

    Formation = BMFormation(transform:Find("Container/bg_frane/Embattle"))
    Formation:SetLeftFormation(leftForm)
    Formation:SetRightFormation(rightForm)
	Formation:SetCallBack(SaveBuildingFormation)
	
    Formation:Awake(EditorState)

    SetClickCallback(transform:Find("Container/bg_frane/bg_top/btn_close").gameObject,CloseClickCallback)
end

local function ShowTips()
	if Tips == nil then
		return
	end
	if Tips.left ~= nil then
		Tips.left.gameObject:SetActive(true)
	end
	if Tips.right ~= nil then
		Tips.right.gameObject:SetActive(true)
	end	
end

local function LoadUI()

    Formation = BMFormation(transform:Find("Container/bg_frane/Embattle"))
    Formation:SetLeftFormation(leftForm)
    Formation:SetRightFormation(rightForm)
	Formation:SetCallBack(SaveFormation)
	Formation:Awake(EditorState)
	Formation:CheckArmyRestrict()
	if SupportPVE~=nil and SupportPVE then
		
		ShowTips();
	end
    SetClickCallback(transform:Find("Container/bg_frane/bg_top/btn_close").gameObject,CloseClickCallback)

	if CurDisplay == "ParadeGround" then
		ParadeGroundDisplay.gameObject:SetActive(true)
		BattleMoveDisplay.gameObject:SetActive(false)
		MobaBuildingDisplay.gameObject:SetActive(false)
	elseif CurDisplay == "MobaBuilding" then
		MobaBuildingDisplay.gameObject:SetActive(true)
		ParadeGroundDisplay.gameObject:SetActive(false)
		BattleMoveDisplay.gameObject:SetActive(false)
		
	else
		ParadeGroundDisplay.gameObject:SetActive(false)
		BattleMoveDisplay.gameObject:SetActive(true)
		MobaBuildingDisplay.gameObject:SetActive(false)
	end
end


function Awake()
    SetClickCallback(transform:Find("Container").gameObject,Hide)
	FormationType = 1
	ParadeGroundDisplay = transform:Find("Container/bg_frane/bg_paradeground")
	local AttackBtn = ParadeGroundDisplay:Find("btn_attack"):GetComponent("UIButton")
	SetClickCallback(AttackBtn.gameObject , ClickAttackBtnCallback)
	local DefenceBtn = ParadeGroundDisplay:Find("btn_defense"):GetComponent("UIButton")
	SetClickCallback(DefenceBtn.gameObject , ClickDefensBtnCallback)
	

	ParadeGroundTitle = ParadeGroundDisplay:Find("bg_formation/frame/title"):GetComponent("UILabel")
	EmbattleTitle = transform:Find("Container/bg_frane/bg_top/bg_title_left/title"):GetComponent("UILabel")
	
	BattleMoveDisplay = transform:Find("Container/bg_frane/bg_battlemove")
	MobaBuildingDisplay = transform:Find("Container/bg_frane/bg_moba")
	if SupportPVE~=nil and SupportPVE then
		Tips={}
		Tips.left = transform:Find("Container/bg_frane/bg_top/text_left")
		Tips.right = transform:Find("Container/bg_frane/bg_top/text_right")	
	end
	local formationHelp = transform:Find("Container/bg_frane/Embattle/btn_help")
	SetClickCallback(formationHelp.gameObject, UnitCounters.Show)	
end

function Close()
    Formation = nil
    EmbattleUI = nil
    EditorState = nil
    BattleMoveDisplay = nil
	MobaBuildingDisplay = nil
    EmbattleTitle = nil
    ParadeGroundTitle = nil
	ParadeGroundDisplay = nil
	mobaBuildingPreForm = nil
	Tips = nil
	SupportPVE = nil
end

function Show(editor,leftform,rightform,closeCallBack , display,supoort_pve)
	SupportPVE = supoort_pve
    EditorState = editor
    leftForm = leftform
    rightForm = rightform
	CurDisplay = display
    CloseCallBack = closeCallBack
    Global.OpenUI(_M)
    LoadUI()    
end

function ShowForMailReport(editor , leftformdata , rightformdata , closeCallBack)
	SupportPVE = nil
	EditorState = editor
    leftForm = leftformdata
    rightForm = rightformdata
	CurDisplay = display
    CloseCallBack = closeCallBack
    Global.OpenUI(_M)
    LoadUIForMailReport()  
end

function ShowForMobaBuilding(editor , formType,  formdata , preformdata , uid, closeCallBack)
	SupportPVE = nil
	EditorState = editor
    leftForm = formdata
    leftForm = nil
    rightForm = formdata
	mobaBuildingPreForm = preformdata
	mobaBuildingUID = uid
	CurDisplay = display
    CloseCallBack = closeCallBack
    Global.OpenUI(_M)
	FormationType = formType
    LoadUIForMobaBuilding()
end

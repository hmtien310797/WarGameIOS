module("Dissolution",package.seeall)

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
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local SetPressCallback = UIUtil.SetPressCallback

local Solider_info

local DissolutionUI

local DissolutionState
local disType

function OpenDissolution(solider_info , _type)
	disType = _type
	Solider_info = solider_info
	DissolutionUI = nil
	DissolutionState = {}
	GUIMgr:CreateMenu("Dissolution",true)
end

local function UpdateDismiss(msg)
	if msg.code == 0 then
		MoneyListData.UpdateData(msg.fresh.money.money)
		--Barrack.RefreshArmNum(msg)
		Solider_info.Num = Solider_info.Num - DissolutionState.SoliderNum
		Barrack.RefrushCurAttributeUI()
		Barrack.UpdateArmyStatus()
		MainCityUI.UpdateArmyStatus()
		GUIMgr:CloseMenu("Dissolution")
		FloatText.Show(TextMgr:GetText("ui_barrack_dissolution3"), Color.white)
	else
		Global.ShowError(msg.code)
	end
end	

local function RequestDismiss(tab,grade,num)
	local req = HeroMsg_pb.MsgArmyDismissRequest()
	req.armyId = tab;
	req.level = grade;
	req.num = num;		
		
	LuaNetwork.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgArmyDismissRequest, req:SerializeToString(), function(typeId, data)
		local msg = HeroMsg_pb.MsgArmyDismissResponse()
		msg:ParseFromString(data)
		UpdateDismiss(msg)
	end, true)	
end


local function UpdateDismissInjured(msg)
	if msg.code == 0 then
		ArmyListData.UpdateInjuredData(msg)
		Solider_info.Num = Solider_info.Num - DissolutionState.SoliderNum
		--Hospital.LoadUI()
		GUIMgr:CloseMenu("Dissolution")
		FloatText.Show(TextMgr:GetText("ui_barrack_dissolution3"), Color.white)
	else
		Global.ShowError(msg.code)
	end
end	

local function RequestDismissInjuredArmy(tab,grade,num)
	local req = HeroMsg_pb.MsgInjureArmyDissolutionRequest()
	
	print("num:" .. num)
	req.info.baseid = tab;
	req.info.level = grade;
	req.info.count = num;		
			
	LuaNetwork.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgInjureArmyDissolutionRequest, req:SerializeToString(), function(typeId, data)
		local msg = HeroMsg_pb.MsgInjureArmyDissolutionResponse()
		msg:ParseFromString(data)
		UpdateDismissInjured(msg)
	end, true)	
end

local function InitDissolutionUI()

	DissolutionUI = {}
	DissolutionUI.CloseBtn = transform:Find ("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")

	DissolutionUI.TargetName = transform:Find ("Container/bg_frane/bg_mid/bg_title/txt_name"):GetComponent("UILabel")
	DissolutionUI.TargetIcon = transform:Find ("Container/bg_frane/bg_mid/icon_texture"):GetComponent("UITexture")
	DissolutionUI.TargetNum = transform:Find("Container/bg_frane/bg_mid/txt_num"):GetComponent("UILabel")

	DissolutionUI.DissolutionSlider = transform:Find ("Container/bg_frane/bg_bottom/bg_dissolution_time/bg_schedule/bg_slider"):GetComponent("UISlider")
	DissolutionUI.DissolutionTxt = transform:Find ("Container/bg_frane/bg_bottom/bg_dissolution_time/bg_schedule/text_num"):GetComponent("UILabel")

	DissolutionUI.DissolutionDelBtn = transform:Find ("Container/bg_frane/bg_bottom/bg_dissolution_time/btn_minus"):GetComponent("UIButton")
	DissolutionUI.DissolutionAddBtn = transform:Find ("Container/bg_frane/bg_bottom/bg_dissolution_time/btn_add"):GetComponent("UIButton")

	DissolutionUI.DissolutionBtn = transform:Find ("Container/bg_frane/btn_dissolution"):GetComponent("UIButton")
	DissolutionUI.DissolutionBtnTxt = transform:Find ("Container/bg_frane/btn_dissolution/text"):GetComponent("UILabel")
end

local function SetIcon (icon_name)
	DissolutionUI.TargetIcon.mainTexture = ResourceLibrary:GetIcon ("Icon/Unit/", icon_name)
end

local function SetupSlider()
	DissolutionUI.DissolutionTxt.text = DissolutionState.SoliderNum.. "/"..Solider_info.Num
end

local function roundOff(num, n)
    if n > 0 then
       local scale = math.pow(10, n-1)
        return math.floor(num / scale + 0.5) * scale
    elseif n < 0 then
        local scale = math.pow(10, n)
        return math.floor(num / scale + 0.5) * scale
     elseif n == 0 then
         return num
     end
end 


local function OnSliderChange()
	if Solider_info.Num == 0 then
		DissolutionUI.DissolutionSlider.value = 0
		return
	end	
	DissolutionState.SoliderNum = roundOff(Solider_info.Num * DissolutionUI.DissolutionSlider.value,1)
	SetupSlider()
end

local function OnClickDissolutionAddBtn()
	if Solider_info.Num == 0 then
		return
	end
	DissolutionUI.DissolutionSlider.value = math.min( DissolutionState.SoliderNum + 1,Solider_info.Num)/Solider_info.Num
end

local function OnClickDissolutionDelBtn()
	if Solider_info.Num == 0 then
		return
	end	
	DissolutionUI.DissolutionSlider.value = math.max( DissolutionState.SoliderNum - 1,0)/Solider_info.Num
end

local function OnClickCloseBtn()
	GUIMgr:CloseMenu("Dissolution")
end

local function OnClickDissolutionBtn()
	local messageText = ""
	if disType == 1 then
		messageText = TextMgr:GetText("hospital_ui11")
	else
		messageText = TextMgr:GetText("ui_barrack_warning6")
	end

	MessageBox.Show(messageText,
		function() 
			if disType == 1 then
				RequestDismissInjuredArmy(Solider_info.SoldierId,Solider_info.Grade,DissolutionState.SoliderNum)
			else
				RequestDismiss(Solider_info.SoldierId,Solider_info.Grade,DissolutionState.SoliderNum)
			end
		end,
		function()
		end,
		TextMgr:GetText("common_hint1"),
		TextMgr:GetText("common_hint2"))
end

local function SetupDissolutionUI()
	DissolutionUI.TargetName.text = TextMgr:GetText(Solider_info.SoldierName)
	SetIcon(Solider_info.SoldierIcon)
	DissolutionUI.TargetNum.text = Solider_info.Num
	DissolutionState.SoliderNum = Solider_info.Num
	EventDelegate.Set(DissolutionUI.DissolutionSlider.onChange,EventDelegate.Callback(OnSliderChange))
	--DissolutionUI.DissolutionSlider:GetComponent("UISliderOnChangeEvent").OnChange = OnSliderChange
	SetClickCallback(DissolutionUI.DissolutionAddBtn.gameObject,OnClickDissolutionAddBtn)
	SetClickCallback(DissolutionUI.DissolutionDelBtn.gameObject,OnClickDissolutionDelBtn)
	SetClickCallback(DissolutionUI.CloseBtn.gameObject,OnClickCloseBtn)
	SetClickCallback(DissolutionUI.DissolutionBtn.gameObject,OnClickDissolutionBtn)
	SetClickCallback(transform:Find ("Container").gameObject, function () GUIMgr:CloseMenu("Dissolution") end)
	SetupSlider()
end

function Awake()
	InitDissolutionUI()
end

function Start()
	SetupDissolutionUI()
end


function Close() 
    DissolutionUI = nil
	disType = nil
end

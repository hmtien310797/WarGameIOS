module("Hospital",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetDragCallback = UIUtil.SetDragCallback
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local moneyLabelList
local container
local wareInfo

local ShowContent
local GetHospitaData
local UpdateContent
local GetMoneyListData
local SelectAllWithRes
local GetAllCurNumber

local hospitalMsg
local treatMsg
local moneylist
local clinicDataMap
local clinicTotal
local clinicOneTime

local costGold
local needRes = -1
local noitem

local LoadUI
local ShowAccUI

local incuring

local CurBuild
local firstIn = true
local SelectAll

local OnValueChange

local isOpen = false

OnCloseCB = nil

function IsOpen()
	return isOpen
end

function IsFull()
	local msg = ArmyListData.GetInjuredData()
	local tCount = 0
	for _,v in ipairs(msg) do
		local clinidata = {}
		--print(v.baseid .. " " .. v.level .. " " .. v.count)
		local soldierData = Barrack.GetAramInfo(v.baseid , v.level)
		if soldierData ~= nil then
			local unitData = TableMgr:GetUnitData(soldierData.UnitID)
			if unitData ~= nil then
				tCount = tCount + v.count
			end
		end
	end
	
	
	print("total:" , tCount , " curnum:" , ResView.GetInjuredArmyMax())
	
	return tCount >= ResView.GetInjuredArmyMax()
end


LoadUI = function()
	noitem = true
	needRes = -1
	costGold = 0
	--RequestInjuredArmyInfo()
	SetMsg(nil)
	GetMoneyListData()
	UpdateContent()
	if firstIn then
		firstIn = false
		SelectAllWithRes()
	end
	--ShowContent()
	SelectAll()
end

function SetMsg()
	hospitalMsg = ArmyListData.GetInjuredData()
	GetHospitaData()
end

function SetBuild(build)
	CurBuild = build
end

local function GetAllHospitalInfo()
	local buildList = {}
	buildList = maincity.GetSpecialBuildList()
	
	local totalSpeed = 0
	local num  = 0 
	for _, v in pairs(buildList) do
		if v.buildingData.showType == 3 then
			local clinicData = TableMgr:GetClinicData(v.data.level)
			totalSpeed = totalSpeed + clinicData.speed
			num = num + 1
		end
	end 
	
	
	return totalSpeed , num
end

local function CheckResourceInfo(index)
	local resType = Common_pb.MoneyType_Food + index - 1
	local needres = tonumber(moneylist[resType].cost)
	local haveres = tonumber(MoneyListData.GetMoneyByType(resType))
	if needres < haveres then
		return
	end
	
	CommonItemBag.SetTittle(TextMgr:GetText("get_resource" .. index))
	CommonItemBag.NotUseAutoClose()
	CommonItemBag.SetResType(resType)
	CommonItemBag.SetItemList(maincity.GetItemExchangeListNoCommon(resType + 2), 0)
	CommonItemBag.SetUseFunc(maincity.UseResItemFunc)
	GUIMgr:CreateMenu("CommonItemBag" , false)
end

local function RequestInjuredArmyInfo()
	SetMsg(nil)
	UpdateContent()
	ShowContent()
	--[[local req = HeroMsg_pb.MsgInjureArmyInfoRequest()
	Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgInjureArmyInfoRequest, req, HeroMsg_pb.MsgInjureArmyInfoResponse, function(msg)
		print("msg.code:" .. msg.code)
		if msg.code == 0 then
			SetMsg(msg)
			UpdateContent()
			ShowContent()
		else
			Global.FloatError(msg.code, Color.white)
			return
		end
	end)]]
	
end

function GetInjuredArmyCost(basetime,type_id,level)
	local params = {}
    params.base = basetime
    params.barrack_bonu_id = 0
    if type_id == 1001 then 
         params.barrack_bonu_id = 1053
    elseif type_id == 1002 then
         params.barrack_bonu_id = 1054
    elseif type_id == 1003 then 
         params.barrack_bonu_id = 1055
    elseif type_id == 1004 then    
         params.barrack_bonu_id = 1056
    end
    params.soldier_att_id = type_id*10000+24
    params.all_soldier_att_id = 10000 * 10000 + 24
    return AttributeBonus.CallBonusFunc(47,params)
end

function GetResourceNeeded(resType)
	return moneylist[resType].cost
end

function NeedResMsg(resType)
	local resMsg = ""
	if resType == Common_pb.MoneyType_Food then
		resMsg = "item_3_name"
	elseif resType == Common_pb.MoneyType_Iron then
		resMsg = "item_4_name"
	elseif resType == Common_pb.MoneyType_Oil then
		resMsg = "item_5_name"
	elseif resType == Common_pb.MoneyType_Elec then
		resMsg = "item_6_name"
	end
	return System.String.Format(TextMgr:GetText("TradeHall_ui17") , TextMgr:GetText(resMsg))
end


function RequestArmyInjuredData()
	local req = HeroMsg_pb.MsgInjureArmyInfoRequest()
	Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgInjureArmyInfoRequest, req, HeroMsg_pb.MsgInjureArmyInfoResponse, function(msg)
		print("msg.code:" .. msg.code)
		if msg.code == 0 then
			ArmyListData.SetInjuredArmyData(msg)
		else
			Global.FloatError(msg.code, Color.white)
			return
		end
	end, true)
end

function RequestCancelCuring()
	if not incuring then
		FloatText.Show(TextMgr:GetText("hospital_ui17") , Color.white)
		return
	end
	
	local req = HeroMsg_pb.MsgCancelArmyTreatRequest()
	Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgCancelArmyTreatRequest, req, HeroMsg_pb.MsgCancelArmyTreatResponse, function(msg)
		print("msg.code:" .. msg.code)
		if msg.code == 0 then
			FloatText.Show(TextMgr:GetText("UnionWareHouse_ui22"),Color.green)
			CountDown.Instance:Remove("TreatmentSoldier")
			ArmyListData.UpdateInjuredArmyData(msg)
			MainCityUI.UpdateRewardData(msg.fresh)
			
			--local CurBuild = maincity.GetCurrentBuildingData()
			--maincity.RemoveBuildCountDown(CurBuild)
			maincity.RemoveTypeBuildCountDown(CurBuild.buildingData.logicType , CurBuild.buildingData.showType)
		else
			Global.FloatError(msg.code, Color.white)
			return
		end
	end)
end

function CureClick(go)
	if needRes > 0 then
		FloatText.ShowOn(go, NeedResMsg(needRes) , Color.white)
		return
	end

	if noitem and not incuring then
		--FloatText.Show("没有需要治疗的单位" , Color.white)
		FloatText.Show(TextMgr:GetText("hospital_ui15") , Color.red)
		return
	end

	if GetAllCurNumber() <= 0 then
		FloatText.Show(TextMgr:GetText("hospital_ui15") , Color.red)
		return
	end

	if GetAllCurNumber() > clinicOneTime then
		FloatText.Show(TextMgr:GetText("ui_hospital_max") , Color.red)
		return 
	end
	
	if incuring then
		local text = TextMgr:GetText("hospital_ui9")
		local okCallback = function()
			ShowAccUI()
			MessageBox.Clear()
		end
		local cancelCallback = function()
			MessageBox.Clear()
		end
		MessageBox.Show(text, okCallback, cancelCallback)

		return
	end



	local req = HeroMsg_pb.MsgInjureArmyTreatmentRequest()
	req.buygold = false
	for _ , v in pairs(clinicDataMap) do
		if v.curnum > 0 then
			req.infos:add()
			req.infos[#req.infos].baseid = v.barrackData.SoldierId
			req.infos[#req.infos].level = v.barrackData.Grade
			req.infos[#req.infos].count =v.curnum
			--print(v.barrackData.SoldierId , v.barrackData.Grade , v.curnum)
		end
	end
	
	Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgInjureArmyTreatmentRequest, req, HeroMsg_pb.MsgInjureArmyTreatmentResponse, function(msg)
		print("msg.code:" .. msg.code)
		if msg.code == 0 then
			MainCityUI.UpdateRewardData(msg.fresh)
			ArmyListData.UpdateInjuredArmyData(msg)
			--[[CountDown.Instance:Remove("TreatmentSoldier")
			CountDown.Instance:Add("TreatmentSoldier",msg.treatarmy.endtime,CountDown.CountDownCallBack(function(t)
				container.bgCureDoingTime.text = t
				if msg.treatarmy.endtime+3 - GameTime.GetSecTime() <= 0 then
					RequestArmyInjuredData()
					CountDown.Instance:Remove("TreatmentSoldier")
				end			
			end))]]
			--local CurBuild = maincity.GetCurrentBuildingData()
			local ltype = CurBuild.buildingData.logicType
			local stype = CurBuild.buildingData.showType
			maincity.SetTypeBuildCountDown(CurBuild.buildingData.logicType , CurBuild.buildingData.showType , msg.treatarmy.endtime , function(t)
				--print("SSSSSSSSSSSSSSSSSSSS",t)
				if t == "00:00:00" then
					maincity.RefreshBuildingTransitionType(ltype , stype)
				end					
			end , "time_icon10")
			MobaArmyListData.NotifyListener()
		else
			Global.FloatError(msg.code, Color.white)
			return
		end
	end)
	
end

function CureArmyWithGold()
	if costGold > MoneyListData.GetMoneyByType(Common_pb.MoneyType_Diamond) then
	    Global.ShowNoEnoughMoney()
		return
	end
	if GetAllCurNumber() <= 0 then
		FloatText.Show(TextMgr:GetText("hospital_ui15") , Color.red)
		return
	end
	
	if GetAllCurNumber() > clinicOneTime then
		FloatText.Show(TextMgr:GetText("ui_hospital_max") , Color.red)
		return 
	end
	
	local beginrequest = function()
		local req = HeroMsg_pb.MsgInjureArmyTreatmentRequest()
		req.buygold = true
		for _ , v in pairs(clinicDataMap) do
			if v.curnum > 0 then
				req.infos:add()
				req.infos[#req.infos].baseid = v.barrackData.SoldierId
				req.infos[#req.infos].level = v.barrackData.Grade
				req.infos[#req.infos].count = v.curnum
				--print(v.barrackData.SoldierId , v.barrackData.Grade , v.curnum)
			end
		end
		
		Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgInjureArmyTreatmentRequest, req, HeroMsg_pb.MsgInjureArmyTreatmentResponse, function(msg)
			print("msg.code:" .. msg.code)
			if msg.code == 0 then
				FloatText.Show(TextMgr:GetText("hospital_ui13"), Color.green)
				AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
				MainCityUI.UpdateRewardData(msg.fresh)
				ArmyListData.UpdateInjuredArmyData(msg)
			else
				Global.FloatError(msg.code, Color.white)
				return
			end
			MobaArmyListData.NotifyListener()
		end)
	end
	if costGold > tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.GoldLimitWarning).value) then
		if tonumber(os.date("%d")) == UnityEngine.PlayerPrefs.GetInt("h_today") then
			MessageBox.SetOkNow()
		else
			MessageBox.SetRemberFunction(function(ishide)
				if ishide then
					UnityEngine.PlayerPrefs.SetInt("h_today",tonumber(os.date("%d")))
					UnityEngine.PlayerPrefs.Save()
				end
			end)
		end
		MessageBox.Show(System.String.Format(TextMgr:GetText("purchase_confirmation5"), costGold), beginrequest, function() end)
	else
		beginrequest()
	end
end


function CureGoldClick(go)
	CureArmyWithGold()
end

function testShow()
	ShowAccUI()
end

ShowAccUI = function()      
    CommonItemBag.SetTittle(TextMgr:GetText("build_ui21"))
    CommonItemBag.NotUseAutoClose()
    CommonItemBag.NotUseFreeFinish()
    CommonItemBag.NeedItemMaxValue()
	CommonItemBag.SetItemList(maincity.GetItemExchangeList(48), 4)
	CommonItemBag.SetMsgText("purchase_confirmation5", "h_today")
    local finish = function()
		local req = HeroMsg_pb.MsgAccelArmyTreatRequest()
		Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgAccelArmyTreatRequest, req, HeroMsg_pb.MsgAccelArmyTreatResponse, function(msg)
			print("msg.code:" .. msg.code)
			if msg.code == 0 then
				ArmyListData.UpdateInjuredArmyData(msg)
				CountDown.Instance:Remove("TreatmentSoldier")
				MainCityUI.UpdateRewardData(msg.fresh)
				FloatText.Show(TextMgr:GetText("hospital_ui13"), Color.green)
				AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
				
				--local CurBuild = maincity.GetCurrentBuildingData()
				if CurBuild ~= nil then
					maincity.RemoveTypeBuildCountDown(CurBuild.buildingData.logicType , CurBuild.buildingData.showType)
				end
			else
				Global.FloatError(msg.code, Color.white)
				return
			end
		end, true)
		CommonItemBag.SetInitFunc(nil)
		GUIMgr:CloseMenu("CommonItemBag")                        
	end

    local cancel = function()
		MessageBox.Show(TextMgr:GetText("hospital_ui8"),
		function()
			RequestCancelCuring()
			CommonItemBag.SetInitFunc(nil)
			GUIMgr:CloseMenu("CommonItemBag")			
        end,
		function()
		end,
		TextMgr:GetText("common_hint1"),
		TextMgr:GetText("common_hint2"))        
	            	
        end

	--treatMsg = ArmyListData.GetTreatmentData()
	--local CurBuild = maincity.GetCurrentBuildingData()
	if treatMsg == nil then
		treatMsg = ArmyListData.GetTreatmentData()
	end
	
    CommonItemBag.SetInitFunc(function()
    	local _text = TextMgr:GetText("hospital_ui7") --"部队治疗中"
    	local _time = treatMsg.endtime
    	local _totalTime = math.floor(treatMsg.endtime - treatMsg.starttime)
    	--_totalTime = GetTrainTime(_totalTime,BarrackInfos[BarrackState.CurTrainingTab][BarrackState.CurTrainingGrade].SoldierId)
    	return _text, _time, treatMsg.originaltime --[[_totalTime]], finish, cancel, finish, 2
    end)

	--使用加速道具 減時間
	CommonItemBag.SetUseFunc(function(useItemId , exItemid , count)
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
        req.buildId = CurBuild.data.uid
        req.subTimeType = 4
        Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemSubTimeRequest, req, ItemMsg_pb.MsgUseItemSubTimeResponse, function(msg)
            print("use item code:" .. msg.code)
            if msg.code == 0 then
				local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
				if price == 0 then
					GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
				else
					GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
				end
	            AudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
				local nameColor = Global.GetLabelColorNew(itemTBData.quality)
				local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1])
				FloatText.Show(showText , Color.white , ResourceLibrary:GetIcon("Item/", itemTBData.icon))
				ArmyListData.UpdateInjuredArmyData(msg)
				
				if CurBuild ~= nil then
					if msg.treatarmy.endtime == 0 and msg.treatarmy.starttime == 0 then
						CountDown.Instance:Remove("TreatmentSoldier")
						--local CurBuild = maincity.GetCurrentBuildingData()
						maincity.RemoveTypeBuildCountDown(CurBuild.buildingData.logicType , CurBuild.buildingData.showType)
					elseif msg.treatarmy.endtime > GameTime.GetSecTime() then
						--update citycountdown
						maincity.SetTypeBuildCountDown(CurBuild.buildingData.logicType , CurBuild.buildingData.showType , msg.treatarmy.endtime , function(t)
							--print("SSSSSSSSSSSSSSSSSSSS",t)
							if t == "00:00:00" then
								maincity.RefreshBuildingTransitionType(ltype , stype)
							end					
						end , "time_icon10")
						
						--update ui countdown
						--CountDown.Instance:Remove("TreatmentSoldier")
						CountDown.Instance:Add("TreatmentSoldier",treatMsg.endtime,CountDown.CountDownCallBack(function(t)
							container.bgCureDoingTime.text = t
							local _totalTime = math.floor(treatMsg.endtime - treatMsg.starttime)
							local _nowTime = math.floor(treatMsg.endtime - GameTime.GetSecTime())
							container.CureDoingSlider.value = 1- (_nowTime/_totalTime)
							if treatMsg.endtime - GameTime.GetSecTime() <= 0 then
							
								FloatText.Show(TextMgr:GetText("hospital_ui13"), Color.green)
								AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
								CountDown.Instance:Remove("TreatmentSoldier")
								--local CurBuild = maincity.GetCurrentBuildingData()
								--maincity.RemoveBuildCountDown(CurBuild)
								maincity.RemoveTypeBuildCountDown(CurBuild.buildingData.logicType , CurBuild.buildingData.showType)
								RequestArmyInjuredData()
							end			
						end))
					end
				end
			
				MainCityUI.UpdateRewardData(msg.fresh)
				CommonItemBag.UpdateTopProgress()
				--GUIMgr:CloseMenu("CommonItemBag") 
            else
                Global.FloatError(msg.code, Color.red)
            end
        end, true)
	end)
    GUIMgr:CreateMenu("CommonItemBag" , false)
end



function CureSpeedUp(go)
	--if BarrackInfos[BarrackState.CurTab][BarrackState.CurGrade].Training then
	if incuring then
	    ShowAccUI()
    end
	
end



function CureCancel(go)
	MessageBox.Show(TextMgr:GetText("hospital_ui8"),
		function()
			RequestCancelCuring()
			
        end,
		function()
		end,
		TextMgr:GetText("common_hint1"),
		TextMgr:GetText("common_hint2"))	
end

GetMoneyListData = function()
	moneylist = {}
	moneylist[Common_pb.MoneyType_Food] = {}
	moneylist[Common_pb.MoneyType_Food].cur = MoneyListData.GetFood()
	moneylist[Common_pb.MoneyType_Food].cost = 0
	moneylist[Common_pb.MoneyType_Iron] = {}
	moneylist[Common_pb.MoneyType_Iron].cur = MoneyListData.GetSteel()
	moneylist[Common_pb.MoneyType_Iron].cost = 0
	moneylist[Common_pb.MoneyType_Oil] = {}
	moneylist[Common_pb.MoneyType_Oil].cur = MoneyListData.GetOil()
	moneylist[Common_pb.MoneyType_Oil].cost = 0
	moneylist[Common_pb.MoneyType_Elec] = {}
	moneylist[Common_pb.MoneyType_Elec].cur = MoneyListData.GetElec()
	moneylist[Common_pb.MoneyType_Elec].cost = 0

end

GetHospitaData = function()
	clinicTotal = 0
	clinicDataMap = {}
	for _,v in ipairs(hospitalMsg) do
		local clinidata = {}
		--print(v.baseid .. " " .. v.level .. " " .. v.count)
		local soldierData = Barrack.GetAramInfo(v.baseid , v.level)
		if soldierData ~= nil then
			local unitData = TableMgr:GetUnitData(soldierData.UnitID)
			if unitData ~= nil then
				clinidata.unitData = unitData
				clinidata.msg = v
				clinidata.curnum = 0
				clinidata.barrackData = soldierData
				clinicTotal = clinicTotal + v.count
				table.insert(clinicDataMap ,  clinidata)
				--clinicDataMap[unitData.id] = clinidata
			end
		end
	end
	
	clinicOneTime = math.min(clinicTotal , ResView.GetInjuredArmyMax())
	--end
	
	--sort
	table.sort(clinicDataMap, function(t1, t2)
		return t1.unitData._unitArmyLevel > t2.unitData._unitArmyLevel
	end)
end

local function GetData(id)
	for _ , v in pairs(clinicDataMap) do
		if v.unitData.id == id then
			return v
		end
	end
	return nil
end

---------------
local function UpdateMoneyCost()
	for i=1 , #(moneylist) do
		if moneylist[i] ~= nil then
			moneylist[i].cost = 0
			for _ , v  in pairs(clinicDataMap) do
				local str = string.split(v.barrackData.CureCost , ";")
				for _ , k in pairs(str) do
					local itemstr = string.split(k,":")
					local item = tonumber(itemstr[1])
					local num = tonumber(itemstr[2])
					if i == item then
						local baseCost = (v.curnum * v.barrackData.TeamCount * num )
						local cost = math.floor(GetInjuredArmyCost(baseCost,v.barrackData.SoldierId , v.barrackData.Grade))
						--print(cost , baseCost , v.barrackData.SoldierId , v.barrackData.Grade)
						moneylist[i].cost = moneylist[i].cost + cost
					end
				end
			end
		end
	end
end


local function UpdateSlider(unitid)
	local clidata = GetData(unitid)
	if clidata ~= nil and clidata.msg.count > 0 then
		local slider = clidata.info.transform:Find("bg_train_time/bg_schedule/bg_slider"):GetComponent("UISlider")
		slider.value = clidata.curnum/clidata.msg.count
		
		local num = clidata.info.transform:Find("text/num"):GetComponent("UILabel")
		num.text = clidata.curnum .. "/" .. clidata.msg.count
	end
end

GetAllCurNumber = function()
	local curCount = 0
	for _ , v in pairs(clinicDataMap) do
		curCount = curCount + v.curnum
	end
	return curCount
end

local function GetCost(clindata)
	local cost = {}
	local cost_time = 0
	local t = string.split(clindata.barrackData.CureCost , ";")
	
	local curFinal = -1
	for _ ,  v in pairs(t) do
		local itemstr = string.split(v , ":")
		local item = tonumber(itemstr[1])
		local num = tonumber(itemstr[2])
		local curcount = 1
		local itemcost = 0
		for i=0 , clindata.msg.count do
			curcount = i
			itemcost = i * clindata.barrackData.TeamCount * num 
			local itemcostnext = (i+1) * clindata.barrackData.TeamCount * num 
			if itemcostnext > moneylist[item].cur then
				--print("count:" .. curcount .. " cost item:" .. item .. " cost num:" .. moneylist[item].cur)
				break 
			end
		end
		
		if curFinal < 0 then
			curFinal = curcount
		else
			curFinal = math.min(curFinal , curcount)
		end
	end
	
	clindata.curnum = curFinal
	for _, v in pairs(t) do
		local itemstr = string.split(v,":")
		local item = tonumber(itemstr[1])
		local num = tonumber(itemstr[2])
		local cost = curFinal * clindata.barrackData.TeamCount * num 
		moneylist[item].cur = moneylist[item].cur - cost
		moneylist[item].cost = moneylist[item].cost + cost
		
		--print("item:" .. item .. " cost:" ..cost .. " curnum:" .. moneylist[item].cur .. " costnum:" .. moneylist[item].cost)
	end
end

SelectAllWithRes = function()
	GetMoneyListData()
	for _ , v in pairs(clinicDataMap) do
		GetCost(v)
	end
	
	for _ , v in pairs(clinicDataMap) do
		--print("soldier:" .. v.msg.armytype .. " level:" .. v.msg.level .. " count:" .. v.msg.count .. "  curnum :" .. v.curnum)
		UpdateSlider(v.unitData.id)
		
	end
	
	--ShowContent()
end

SelectAll = function()
	local total = 0
	for _ , v in pairs(clinicDataMap) do
		if v ~= nil and v.info ~= nil then
			local slider  = v.info.transform:Find("bg_train_time/bg_schedule/bg_slider"):GetComponent("UISlider")
			total = total + v.msg.count 
			if total > clinicOneTime then
				v.curnum = math.max( 0 , v.msg.count - (total - clinicOneTime))
			else
				v.curnum = v.msg.count
			end
			slider.value = v.curnum / v.msg.count
			--v.curnum = Mathf.Ceil(slider.value * v.msg.count)
			
			local num = v.info.transform:Find("text/num"):GetComponent("UILabel")
			num.text = v.curnum .. "/" .. v.msg.count
			
			UpdateMoneyCost(v.unitData.id)
		end
	end
	ShowContent()
end

local function OpClickCallback(op , unitid)
	local add = (op == "add")
	local clidata = GetData(unitid)
	if clidata ~= nil then
		if add then
			clidata.curnum = math.min(clidata.curnum + 1 ,  clidata.msg.count)
		else
			clidata.curnum = math.max(clidata.curnum - 1 , 0)
		end
		
		--print(clidata.unitData.id .. "  " .. clidata.curnum)
		UpdateSlider(unitid)
		UpdateMoneyCost(unitid)
		ShowContent()
	end
end
		
local function OnDragSlider(unitid)
	--local unitid = tonumber(go.name)
	local clidata = GetData(unitid)
	local slider = clidata.info.transform:Find("bg_train_time/bg_schedule/bg_slider"):GetComponent("UISlider")
	if clidata ~= nil then
		--numSlider.value = numSlider.value + delta.x*0.005
		local curnum = Mathf.Ceil(slider.value * clidata.msg.count)
		clidata.curnum = curnum--Mathf.Ceil(slider.value * clidata.msg.count)
		UpdateSlider(unitid)
		UpdateMoneyCost(unitid)
		ShowContent()
		
	end
end

OnValueChange =  function(unitid)
	local clidata = GetData(unitid)
	local slider = clidata.info.transform:Find("bg_train_time/bg_schedule/bg_slider"):GetComponent("UISlider")
	
	if clidata ~= nil then
		--local curnum = Mathf.Ceil(slider.value * clidata.msg.count)
		--clidata.curnum = curnum
		
		local num = clidata.info.transform:Find("text/num"):GetComponent("UILabel")
		num.text = clidata.curnum .. "/" .. clidata.msg.count
		--UpdateSlider(unitid)
		UpdateMoneyCost(unitid)
		ShowContent()
	end
end

local function OnDelItem(go)
	local unitid = tonumber(go.name)
	local clidata = GetData(unitid)

	local disParam = {}
	disParam.SoldierId = clidata.barrackData.SoldierId
	disParam.Grade = clidata.barrackData.Grade
	disParam.Num = clidata.msg.count
	disParam.SoldierIcon = clidata.barrackData.SoldierIcon
	disParam.SoldierName = clidata.barrackData.SoldierName
	--disParam.DisType = 1
	
	Dissolution.OpenDissolution(disParam , 1)
	--[[local unitid = tonumber(go.name)
	local clidata = GetData(unitid)
	MsgInjureArmyDissolutionRequest
	Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgInjureArmyTreatmentRequest, req, HeroMsg_pb.MsgInjureArmyTreatmentResponse, function(msg)
		print("msg.code:" .. msg.code)
		if msg.code == 0 then
			 ArmyListData.UpdateInjuredArmyData(msg)
			 MainCityUI.UpdateRewardData(msg.fresh)
		else
			Global.FloatError(msg.code, Color.white)
			return
		end
	end)]]
end

ShowContent = function()
	if clinicDataMap == nil then
		return
	end
	
	AttributeBonus.CollectBonusInfo()
	container.hurt.text = clinicTotal
	container.hurtLim.text = (GetAllCurNumber() > ResView.GetInjuredArmyMax() and "[ff0000]" ..GetAllCurNumber().. "[-]" or GetAllCurNumber()) .. "/" .. ResView.GetInjuredArmyMax()

	local gold = 0
	needRes = -1
	if moneylist[Common_pb.MoneyType_Food].cost > MoneyListData.GetFood() then
		container.food.text = "[ff0000]" .. moneylist[Common_pb.MoneyType_Food].cost .. "[-]"
		needRes = Common_pb.MoneyType_Food
		gold = gold + maincity.CaculateGoldForRes(3, moneylist[Common_pb.MoneyType_Food].cost - MoneyListData.GetFood())
	else
		container.food.text = moneylist[Common_pb.MoneyType_Food].cost
		gold = gold + maincity.CaculateGoldForRes(3, 0)
	end
	
	if moneylist[Common_pb.MoneyType_Iron].cost > MoneyListData.GetSteel() then
		container.iron.text = "[ff0000]" .. moneylist[Common_pb.MoneyType_Iron].cost .. "[-]"
		needRes = Common_pb.MoneyType_Iron
		gold = gold + maincity.CaculateGoldForRes(4, moneylist[Common_pb.MoneyType_Iron].cost - MoneyListData.GetSteel())
	else
		container.iron.text = moneylist[Common_pb.MoneyType_Iron].cost
		gold = gold + maincity.CaculateGoldForRes(4, 0)
	end
	
	if moneylist[Common_pb.MoneyType_Oil].cost > MoneyListData.GetOil() then
		container.oil.text = "[ff0000]" .. moneylist[Common_pb.MoneyType_Oil].cost .. "[-]"
		needRes = Common_pb.MoneyType_Oil
		gold = gold + maincity.CaculateGoldForRes(5, moneylist[Common_pb.MoneyType_Oil].cost - MoneyListData.GetOil())
	else
		container.oil.text = moneylist[Common_pb.MoneyType_Oil].cost
		gold = gold + maincity.CaculateGoldForRes(5, 0)
	end
	
	
	if moneylist[Common_pb.MoneyType_Elec].cost > MoneyListData.GetElec() then
		container.electric.text = "[ff0000]" .. moneylist[Common_pb.MoneyType_Elec].cost .. "[-]"
		needRes = Common_pb.MoneyType_Elec
		gold = gold + maincity.CaculateGoldForRes(6, moneylist[Common_pb.MoneyType_Elec].cost - MoneyListData.GetElec())
	else
		container.electric.text = moneylist[Common_pb.MoneyType_Elec].cost
		gold = gold + maincity.CaculateGoldForRes(6, 0)
	end
	
	
	--print(GetAllCurNumber())
	if GetAllCurNumber() <= 0 then
		container.btnCureGold.gameObject:SetActive(false)
	else
		container.btnCureGold.gameObject:SetActive(true)
	end
	
	--train time
	local _totalTime = 0
	for _ , v in pairs(clinicDataMap) do
		local trantime = math.floor(v.curnum * v.barrackData.TeamCount * v.barrackData.CureTime)
		_totalTime = _totalTime + GetCureTime(trantime , v.barrackData.SoldierId)
	end

	--print("原时间：" , _totalTime)
	local tSpeed , tNum = GetAllHospitalInfo()
	--print("总加速时间:" , tSpeed , " 医疗所数量:" , tNum)
	_totalTime = _totalTime / (1 + (tSpeed/10000))
	
	--print("最终时间：" , _totalTime ,  Serclimax.GameTime.SecondToString3(_totalTime))
	container.cooldown.text = Serclimax.GameTime.SecondToString3(_totalTime)

	--[[if MoneyListData.GetFood() < moneylist[Common_pb.MoneyType_Food].cost or 
		MoneyListData.GetSteel() < moneylist[Common_pb.MoneyType_Iron].cost or 
		MoneyListData.GetOil() < moneylist[Common_pb.MoneyType_Oil].cost or 
		MoneyListData.GetFood() < moneylist[Common_pb.MoneyType_Elec].cost then
		
		gold = gold + SpeedUpprice.GetPrich(2,_totalTime)
	else
		gold = SpeedUpprice.GetPrice(2,_totalTime)
	end]]
	if needRes > 0 then
		gold = Mathf.Round(gold) + Mathf.Round(SpeedUpprice.GetPrice(2,_totalTime))
	else
		gold = Mathf.Round(SpeedUpprice.GetPrice(2,_totalTime))
	end
	costGold = math.max(gold , 0)
	container.btnCureGoldLabel.text =  costGold
	
	treatMsg = ArmyListData.GetTreatmentData()
	if treatMsg ~= nil and treatMsg.armys ~= nil and (treatMsg.endtime +1) - GameTime.GetSecTime() > 0 then
		incuring = true
		container.btnCureGold.gameObject:SetActive(false)
		container.bgCureDoing.gameObject:SetActive(true)

		--CountDown.Instance:Remove("TreatmentSoldier")
		CountDown.Instance:Add("TreatmentSoldier",treatMsg.endtime,CountDown.CountDownCallBack(function(t)
			container.bgCureDoingTime.text = t
			local _totalTime = math.floor(treatMsg.endtime - treatMsg.starttime)
			local _nowTime = math.floor(treatMsg.endtime - GameTime.GetSecTime())
			container.CureDoingSlider.value = 1- (_nowTime/_totalTime)

			if treatMsg.endtime+1 - GameTime.GetSecTime() <= 0 then
				FloatText.Show(TextMgr:GetText("hospital_ui13"), Color.green)
				AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
				CountDown.Instance:Remove("TreatmentSoldier")
				--local CurBuild = maincity.GetCurrentBuildingData()
				--maincity.RemoveBuildCountDown(CurBuild)
				maincity.RemoveTypeBuildCountDown(CurBuild.buildingData.logicType , CurBuild.buildingData.showType)
				RequestArmyInjuredData()
			end			
		end))
		container.bgCureDoing.gameObject:SetActive(true)
	else
		incuring = false
		container.bgCureDoing.gameObject:SetActive(false)
	end
	
end

UpdateContent = function()
	--local build = maincity.GetCurrentBuildingData()
	local level = CurBuild.data.level
	local ClinicTableData = TableMgr:GetClinicData(level)
	
	while container.grid.transform.childCount > 0 do
		GameObject.DestroyImmediate(container.grid.transform:GetChild(0).gameObject);
	end
	
	noitem = true
	for _, v in pairs(clinicDataMap) do
		if v ~= nil and v.msg.count > 0 then
			noitem = false
			local info = NGUITools.AddChild(container.grid.gameObject , container.detailItem.go.gameObject)
			info.transform:SetParent(container.grid.transform , false)
			info.gameObject:SetActive(true)
			--info.gameObject.name = v.unitData.id
			v.info = info
			
			--local iconbox = info.transform:Find("bg_icon"):GetComponent("UISprite")
			--icon.spriteName = ResourceLibrary:GetIcon("Icon/Unit/", v.unitData._unitIcon)--v.unitData._unitIcon
			local icon = info.transform:Find("bg_icon/icon"):GetComponent("UITexture")
			icon.mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", v.unitData._unitSoldierIcon)
			
			local name = info.transform:Find("name"):GetComponent("UILabel")
			name.text = TextUtil.GetUnitName(v.unitData)
			--container.detailItem.num.text = clinicTotal .. "/" .. ClinicTableData.hurt
			local num = info.transform:Find("text/num"):GetComponent("UILabel")
			num.text = v.curnum .. "/" .. v.msg.count
			
			local slider = info.transform:Find("bg_train_time/bg_schedule/bg_slider"):GetComponent("UISlider")
			slider.value = v.curnum / v.msg.count
			slider.numberOfSteps = v.msg.count
			
			EventDelegate.Set(slider.onChange,EventDelegate.Callback(function(obj,delta)
				--OnValueChange(v.unitData.id)
			end))
			
			local timesliderMinusBtn = info.transform:Find("bg_train_time/btn_minus"):GetComponent("UIButton")
			--timesliderMinusBtn.gameObject.name = "minus:" .. v.unitData.id
			SetClickCallback(timesliderMinusBtn.gameObject , function()
				OpClickCallback("minus" , v.unitData.id)
			end)
			
			local timesliderAddBtn = info.transform:Find("bg_train_time/btn_add"):GetComponent("UIButton")
			--timesliderAddBtn.gameObject.name = "add:" .. v.unitData.id
			SetClickCallback(timesliderAddBtn.gameObject , function()
				if GetAllCurNumber() >= clinicOneTime then
					FloatText.Show(TextMgr:GetText("ui_hospital_max") , Color.red)
					return
				end
				OpClickCallback("add" ,v.unitData.id )
			end)
			
			local itemsliderBtn = info.transform:Find("bg_train_time/bg_schedule/bg_slider")
			SetDragCallback(itemsliderBtn.gameObject , function(obj , delta)
				OnDragSlider(v.unitData.id)
			end)
			SetClickCallback(itemsliderBtn.gameObject , function()
				OnDragSlider(v.unitData.id)
			end)
			
			local timesliderDelBtn = info.transform:Find("btn_del"):GetComponent("UIButton")
			timesliderDelBtn.gameObject.name = v.unitData.id
			SetClickCallback(timesliderDelBtn.gameObject , OnDelItem)
			--[[if hospitalMsg.treatarmy ~= nil and hospitalMsg.treatarmy.Length > 0 then
				timesliderMinusBtn.enabled = false
				timesliderAddBtn.enabled = false
				itemsliderBtn.enabled = false
			else
				timesliderMinusBtn.enabled = true
				timesliderAddBtn.enabled = true
				itemsliderBtn.enabled = true
			end]]
			
		end
	end
	container.grid:Reposition()

	if noitem then
		container.noitem.gameObject:SetActive(true)
		container.btnCureGold.gameObject:SetActive(false)
		container.btnAll.gameObject:SetActive(false)
		container.btnCure.gameObject:SetActive(false)
		container.cooldown.transform.parent.gameObject:SetActive(false)
	else
		container.noitem.gameObject:SetActive(false)
		container.btnCureGold.gameObject:SetActive(true)
		container.btnAll.gameObject:SetActive(true)
		container.btnCure.gameObject:SetActive(true)
		container.cooldown.transform.parent.gameObject:SetActive(true)
	end

end

function Awake()
    container = {}
    container.go = transform:Find("Container").gameObject
    container.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
    container.grid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	container.noitem = transform:Find("Container/bg_frane/bg_mid/bg_noitem")
	container.food = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_resource/bg_food/txt_food"):GetComponent("UILabel")
	container.iron = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_resource/bg_iron/txt_iron"):GetComponent("UILabel")
	container.oil = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_resource/bg_oil/txt_oil"):GetComponent("UILabel")
	container.electric = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_resource/bg_electric/txt_electric"):GetComponent("UILabel")
	container.cooldown = transform:Find("Container/bg_frane/bg_bottom/bg_train/time/num"):GetComponent("UILabel")
	container.hurt = transform:Find("Container/bg_frane/text/num"):GetComponent("UILabel")
	container.hurtLim = transform:Find("Container/bg_frane/text (1)/num"):GetComponent("UILabel")
	
	container.resBtn = {}
	container.resBtn[1] = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_resource/bg_food"):GetComponent("UIButton")
	container.resBtn[2] = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_resource/bg_iron"):GetComponent("UIButton")
	container.resBtn[3] = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_resource/bg_oil"):GetComponent("UIButton")
	container.resBtn[4] = transform:Find("Container/bg_frane/bg_bottom/bg_train/bg_resource/bg_electric"):GetComponent("UIButton")
	for i=1 , 4 , 1 do
		SetClickCallback(container.resBtn[i].gameObject , function()
			print(i)
			CheckResourceInfo(i)
		end)
	end
	
	
	container.btnAll = transform:Find("Container/bg_frane/bg_bottom/bg_train/btn_selall"):GetComponent("UIButton")
	container.btnCure = transform:Find("Container/bg_frane/bg_bottom/bg_train/btn_cure"):GetComponent("UIButton")
	SetClickCallback(container.btnCure.gameObject , CureClick)
	container.btnCureGold = transform:Find("Container/bg_frane/bg_bottom/bg_train/btn_cure_gold"):GetComponent("UIButton")
	SetClickCallback(container.btnCureGold.gameObject , CureGoldClick)
	container.btnCureGoldLabel = transform:Find("Container/bg_frane/bg_bottom/bg_train/btn_cure_gold/num"):GetComponent("UILabel")

	container.detailItem = {}
	container.detailItem.go = transform:Find("wareinfo")
	container.detailItem.icon = transform:Find("wareinfo/bg_icon"):GetComponent("UISprite")
	container.detailItem.name = transform:Find("wareinfo/name"):GetComponent("UILabel")
	container.detailItem.num = transform:Find("wareinfo/text/num"):GetComponent("UILabel")
	container.detailItem.timeslider = transform:Find("wareinfo/bg_train_time/bg_schedule/bg_slider"):GetComponent("UISlider")
	container.detailItem.timesliderbtn = transform:Find("wareinfo/bg_train_time/bg_schedule/bg_btn_slider"):GetComponent("UIButton")
	container.detailItem.timesliderAddBtn = transform:Find("wareinfo/bg_train_time/btn_add"):GetComponent("UIButton")
	container.detailItem.timesliderMinusBtn = transform:Find("wareinfo/bg_train_time/btn_minus"):GetComponent("UIButton")
	container.detailItem.timesliderDelBtn = transform:Find("wareinfo/btn_del"):GetComponent("UIButton")
	
	container.bgCureDoing = transform:Find("Container/bg_frane/bg_cure_doing")
	container.bgCureDoingTime = transform:Find("Container/bg_frane/bg_cure_doing/bg_time/txt_time"):GetComponent("UILabel")
	container.CureDoingSpeedUpBtn = transform:Find("Container/bg_frane/bg_cure_doing/btn_speedup"):GetComponent("UIButton")
	container.CureDoingDelBtn = transform:Find("Container/bg_frane/bg_cure_doing/btn_delete"):GetComponent("UIButton")
	container.CureDoingSlider = transform:Find("Container/bg_frane/bg_cure_doing/bg_time"):GetComponent("UISlider")
	
	-- container.bgCureDoing.gameObject:SetActive(false)

	SetClickCallback(container.CureDoingSpeedUpBtn.gameObject , CureSpeedUp)
	SetClickCallback(container.CureDoingDelBtn.gameObject , CureCancel)
	
	GetMoneyListData()
	ArmyListData.AddListener(LoadUI)
	MoneyListData.AddListener(ShowContent)
	
end

function Start()
	isOpen = true
	container.btnCure.gameObject:SetActive(false)

	SetClickCallback(container.go, function()
    	GUIMgr:CloseMenu("Hospital")
    end)
 
    SetClickCallback(container.btn_close.gameObject, function()
    	GUIMgr:CloseMenu("Hospital")
    end)
	
	SetClickCallback(container.btnAll.gameObject , function()
		SelectAll()
	end)
	
	TeamData.RequestArmyInjuredData()
	--LoadUI()
end

function CheckCureInfo(build)
	local treat = ArmyListData.GetTreatmentData()
	if treat ~= nil and treat.endtime >  GameTime.GetSecTime() then
		maincity.SetBuildCountDown(build , treat.endtime , function(t)
			--print("SSSSSSSSSSSSSSSSSSSS",t)
			if t == "00:00:00" then
				maincity.RefreshBuildingTransition(build)
			end					
		end , "time_icon10")
	end
end

function Close()
	isOpen = false
	
	if OnCloseCB ~= nil then
    	OnCloseCB()
    	OnCloseCB = nil
    end
	firstIn = true
	CurBuild = nil
	clinicDataMap = nil
	ArmyListData.RemoveListener(LoadUI)
	MoneyListData.RemoveListener(ShowContent)
	CountDown.Instance:Remove("TreatmentSoldier")
end

function GetCureTime(basetime,type_id)
    local params = {}
    params.base = basetime
    params.barrack_bonu_id = 0
    if type_id == 1001 then 
         params.barrack_bonu_id = 1048
    elseif type_id == 1002 then
         params.barrack_bonu_id = 1049
    elseif type_id == 1003 then 
         params.barrack_bonu_id = 1050
    elseif type_id == 1004 then    
         params.barrack_bonu_id = 1051
    end
	
    params.soldier_att_id = type_id*10000+23
    params.all_soldier_att_id = 10000*10000 + 23
    
    local builds = maincity.GetBuildingList()
    local speed = 0;
    --print(speed)
    params.TSpeed = speed
    return AttributeBonus.CallBonusFunc(15,params)
end

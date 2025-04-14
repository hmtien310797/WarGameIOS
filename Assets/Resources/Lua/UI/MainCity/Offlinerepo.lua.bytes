module("Offlinerepo",package.seeall)

local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local String = System.String
local GameObject = UnityEngine.GameObject
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback

local _ui

function Hide()
    Global.CloseUI(_M)
end

function ReportItem(item, index)
	local ResGains = item.transform:Find("collect").gameObject
	local ResLose = item.transform:Find("lost").gameObject
	local ArmyTrain = item.transform:Find("Make").gameObject
	local ArmyLose = item.transform:Find("injured").gameObject
	local BuildUpgrad = item.transform:Find("building").gameObject
	local TechUpgrad = item.transform:Find("research").gameObject
	local CheckBtn = item.transform:Find("check").gameObject
	local Time = item.transform:Find("time").gameObject

		
	if tonumber(_ui.Order[index]) == tonumber(ClientMsg_pb.OfflineReportType_ResGains) then
		local IsActive = false
		if _ui.ResGains ~= nil then
			for i, v in ipairs(_ui.ResGains) do
				if v.value > 0 then
					if v.id == 3 then --粮食
						ResGains.transform:Find("name/Grid/resource/qtty"):GetComponent("UILabel").text = Global.ExchangeValue(v.value)
						ResGains.transform:Find("name/Grid/resource").gameObject:SetActive(true)
					elseif v.id == 4 then --钢铁
						ResGains.transform:Find("name/Grid/iron/qtty"):GetComponent("UILabel").text = Global.ExchangeValue(v.value)
						ResGains.transform:Find("name/Grid/iron").gameObject:SetActive(true)
					elseif v.id == 5 then --石油
						ResGains.transform:Find("name/Grid/oil/qtty"):GetComponent("UILabel").text = Global.ExchangeValue(v.value) 
						ResGains.transform:Find("name/Grid/oil").gameObject:SetActive(true)
					elseif v.id == 6 then --电能
						ResGains.transform:Find("name/Grid/elec/qtty"):GetComponent("UILabel").text = Global.ExchangeValue(v.value)
						ResGains.transform:Find("name/Grid/elec").gameObject:SetActive(true)
					end
					IsActive = true
				end			
			end
		end
		if IsActive == true then 
			ResGains.transform:Find("name/Grid"):GetComponent("UIGrid"):Reposition()
			ResGains.gameObject:SetActive(true)
			item.gameObject:SetActive(true)	
		end
	elseif tonumber(_ui.Order[index]) == tonumber(ClientMsg_pb.OfflineReportType_ResLose) then
		local IsActive = false
		local mailId = 0
		if _ui.ResLose ~= nil then
			for i, v in ipairs(_ui.ResLose) do
				if v.value > 0 then
					if v.id == 3 then --粮食
						ResLose.transform:Find("name/Grid/resource/qtty"):GetComponent("UILabel").text = Global.ExchangeValue(v.value)
						ResLose.transform:Find("name/Grid/resource").gameObject:SetActive(true)
					elseif v.id == 4 then --钢铁
						ResLose.transform:Find("name/Grid/iron/qtty"):GetComponent("UILabel").text = Global.ExchangeValue(v.value)
						ResLose.transform:Find("name/Grid/iron").gameObject:SetActive(true)
					elseif v.id == 5 then --石油
						ResLose.transform:Find("name/Grid/oil/qtty"):GetComponent("UILabel").text = Global.ExchangeValue(v.value)
						ResLose.transform:Find("name/Grid/oil").gameObject:SetActive(true)
					elseif v.id == 6 then --电能
						ResLose.transform:Find("name/Grid/elec/qtty"):GetComponent("UILabel").text = Global.ExchangeValue(v.value)
						ResLose.transform:Find("name/Grid/elec").gameObject:SetActive(true)
					end
					mailId = v.mailId
					IsActive = true
				end			
			end
		end
		if IsActive == true then 
			if mailId > 0 then
				local check = item.transform:Find("check")
				check.gameObject:SetActive(true)
				SetClickCallback(check.gameObject, function()
					--跳转邮件
					Mail.DirectShow(mailId)
				end)
			end
			ResLose.transform:Find("name/Grid"):GetComponent("UIGrid"):Reposition()
			ResLose.gameObject:SetActive(true)
			item.gameObject:SetActive(true)	
		end
	elseif tonumber(_ui.Order[index]) == -2 then --城防
		local IsActive = false
		local grid = ArmyTrain.transform:Find("name/Grid"):GetComponent("UIGrid")
		if _ui.ArmyTrain ~= nil then
			for i, v in ipairs(_ui.ArmyTrain) do
				if v.value > 0 then			
					local Soldier = TableMgr:GetBarrackDataByUnitId(v.id)		
					if Soldier.Defence == 1 then
						index = index + 1
						local SoldierItem = NGUITools.AddChild(grid.gameObject , _ui.Defence.gameObject)
						SoldierItem.transform:GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon ("Icon/Unit/", Soldier.SoldierIcon)
						SoldierItem.transform:Find("qtty"):GetComponent("UILabel").text = v.value
						SoldierItem.gameObject:SetActive(true)
						IsActive = true
					end
				end
			end
		end
		if IsActive == true then 
			local grid = ArmyTrain.transform:Find("name/Grid"):GetComponent("UIGrid")
			grid:Reposition()
			ArmyTrain.gameObject:SetActive(true)
			item.gameObject:SetActive(true)			
		end
	elseif tonumber(_ui.Order[index]) == -1 then --训练兵
		local IsActive = false
		local grid = ArmyTrain.transform:Find("name/Grid"):GetComponent("UIGrid")
		if _ui.ArmyTrain ~= nil then
			for i, v in ipairs(_ui.ArmyTrain) do
				local Soldier = TableMgr:GetBarrackDataByUnitId(v.id)		
				if Soldier.Defence == 0 then
					local SoldierItem = NGUITools.AddChild(grid.gameObject , _ui.Soldier.gameObject)
					SoldierItem.transform:GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon ("Icon/Unit/", Soldier.SoldierIcon)
					SoldierItem.transform:Find("qtty"):GetComponent("UILabel").text = v.value
					SoldierItem.gameObject:SetActive(true)
					IsActive = true
				end
			end
		end
		if IsActive == true then 
			local grid = ArmyTrain.transform:Find("name/Grid"):GetComponent("UIGrid")
			grid:Reposition()
			ArmyTrain.gameObject:SetActive(true)	
			item.gameObject:SetActive(true)		
		end
	elseif tonumber(_ui.Order[index]) == tonumber(ClientMsg_pb.OfflineReportType_ArmyLose) then
		local IsActive = false
		if _ui.ArmyLose ~= nil then
			for i, v in ipairs(_ui.ArmyLose) do
				if v.value > 0 then
					if v.id == 1 then -- 死兵
						ArmyLose.transform:Find("name/Grid/killed/qtty"):GetComponent("UILabel").text = v.value 				
						ArmyLose.transform:Find("name/Grid/killed").gameObject:SetActive(true)
					elseif v.id == 2 then -- 伤兵
						ArmyLose.transform:Find("name/Grid/injured/qtty"):GetComponent("UILabel").text = v.value 
						ArmyLose.transform:Find("name/Grid/injured").gameObject:SetActive(true)
						
						local hospitalBuild = maincity.GetBuildingByID(3)
						if hospitalBuild ~= nil then
							CheckBtn:SetActive(true)
							SetClickCallback(CheckBtn , function()
								Hide()
								Hospital.SetBuild(hospitalBuild)
								Global.GGUIMgr:CreateMenu("Hospital", false)
								Hospital.OnCloseCB = function()
									MainCityUI.RemoveMenuTarget()
								end
							end)
						end
					end
					IsActive = true
				end
			end
		end
		if IsActive == true then 
			ArmyLose.transform:Find("name/Grid"):GetComponent("UIGrid"):Reposition()
			ArmyLose.gameObject:SetActive(true)		
			item.gameObject:SetActive(true)		
		end
	elseif tonumber(_ui.Order[index]) == -3 then --建筑1队列
		local IsActive = false
		if _ui.BuildUpgrad ~= nil then
			if _ui.BuildUpgrad[1] ~= nil then
				if _ui.BuildUpgrad[1].value > 0 then
					local building = TableMgr:GetBuildingData(_ui.BuildUpgrad[1].id)
					BuildUpgrad.transform:Find("name/buildingname"):GetComponent("UILabel").text = TextMgr:GetText(building.name)
					BuildUpgrad.transform:Find("name/lv_before"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("Level_ui"), _ui.BuildUpgrad[1].value - 1) 
					BuildUpgrad.transform:Find("name/lv_before/lv_now"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("Level_ui"), _ui.BuildUpgrad[1].value) 
					IsActive = true
				end
			end
		end
		if IsActive == true then 
			BuildUpgrad.gameObject:SetActive(true)
			item.gameObject:SetActive(true)	
		end
	elseif tonumber(_ui.Order[index]) == -4 then --建筑2队列
		local IsActive = false
		if _ui.BuildUpgrad ~= nil then
			if _ui.BuildUpgrad[2] ~= nil then
				if _ui.BuildUpgrad[2].value > 0 then
					local building = TableMgr:GetBuildingData(_ui.BuildUpgrad[2].id)
					BuildUpgrad.transform:Find("name/buildingname"):GetComponent("UILabel").text = TextMgr:GetText(building.name)
					BuildUpgrad.transform:Find("name/lv_before"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("Level_ui"), _ui.BuildUpgrad[2].value - 1) 
					BuildUpgrad.transform:Find("name/lv_before/lv_now"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("Level_ui"), _ui.BuildUpgrad[2].value) 
					IsActive = true
				end
			end
		end
		if IsActive == true then 
			BuildUpgrad.gameObject:SetActive(true)
			item.gameObject:SetActive(true)	
		end
	elseif tonumber(_ui.Order[index]) == tonumber(ClientMsg_pb.OfflineReportType_TechUpgrad) then
		local IsActive = false
		if _ui.TechUpgrad ~= nil then
			if _ui.TechUpgrad[1] ~= nil then
				if _ui.TechUpgrad[1].value > 0 then
					local TechDetail = TableMgr:GetTechDetailDataByIdLevel(_ui.TechUpgrad[1].id, _ui.TechUpgrad[1].value)
					TechUpgrad.transform:Find("name/techname"):GetComponent("UILabel").text = TextMgr:GetText(TechDetail.Name)
					TechUpgrad.transform:Find("name/lv_before"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("Level_ui"), _ui.TechUpgrad[1].value - 1)
					TechUpgrad.transform:Find("name/lv_before/lv_now"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("Level_ui"), _ui.TechUpgrad[1].value)
					IsActive = true
				end
			end
		end
		if IsActive == true then 
			TechUpgrad.gameObject:SetActive(true)
			item.gameObject:SetActive(true)	
		end
	elseif tonumber(_ui.Order[index]) == 0 then
		Time.transform:Find("name/data"):GetComponent("UILabel").text = Global.SecondToTimeLong(_ui.Data.offlineDuration)
		Time.gameObject:SetActive(false)	
		item.gameObject:SetActive(false)	
	end
end

function ReportUpdate()
	if _ui == nil then
		return
	end

	transform:Find("Container/background/time/name/data"):GetComponent("UILabel").text = Global.SecondToTimeLong(_ui.Data.offlineDuration)
	
	local count = -1
	local item = nil
	for i = 0, #_ui.Order do
		if item == nil then 
			count = count + 1
			item = NGUITools.AddChild(_ui.Grid.gameObject , _ui.ReportItem.gameObject)	
		else
			if item.activeSelf == true then
				count = count + 1
				item = NGUITools.AddChild(_ui.Grid.gameObject , _ui.ReportItem.gameObject)	
			end
		end		
		ReportItem(item, i)
	end
	if count > 4 then
		if item ~= nil and item.activeSelf == false then
			GameObject.Destroy(item.gameObject)
		end
		_ui.Arrow.gameObject:SetActive(true)
		EventDelegate.Set(_ui.ScrollBar.onChange,EventDelegate.Callback(function()
			if _ui == nil then
				return
			end
			if _ui.ScrollBar.value > 0.2 then
				_ui.Arrow.gameObject:SetActive(true)
			end
			if _ui.ScrollBar.value > 0.8 then
				_ui.Arrow.gameObject:SetActive(false)
			end
		end))
	else
		if item ~= nil and item.activeSelf == false then
			item.gameObject:SetActive(true)
		end
		
		for i=count+1, 4, 1 do
			item = NGUITools.AddChild(_ui.Grid.gameObject , _ui.ReportItem.gameObject)
			item.gameObject:SetActive(true)	
		end
	end
	_ui.Grid:Reposition()
	_ui.ScrollView:ResetPosition()
end

function Awake()
	_ui.ScrollView = transform:Find("Container/background/Scroll View"):GetComponent("UIScrollView")
	_ui.Grid = transform:Find("Container/background/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.ScrollBar = transform:Find("Container/background/Scroll Bar"):GetComponent("UIScrollBar")
	_ui.Arrow = transform:Find("Container/arrow")
	_ui.ReportItem = transform:Find("list_report")
	_ui.Close = transform:Find("Container/btn_close")
	_ui.Mask = transform:Find("mask")
	_ui.Order = string.split(tostring(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.OfflinerepoOrder).value),",")
	_ui.Soldier = transform:Find("soldier")
	_ui.Defence = transform:Find("defence")
	_ui.Res = transform:Find("res")
	_ui.Killed = transform:Find("killed")
	_ui.Injured = transform:Find("Injured")

	SetClickCallback(_ui.Mask.gameObject, function()
		Hide()
	end)
	SetClickCallback(_ui.Close.gameObject, function()
		Hide()
	end)

	ReportUpdate()
end

function CheckResGains()
	local isShow = false
	if _ui.ResGains ~= nil then
		for i, v in ipairs(_ui.ResGains) do
			print(v.value , tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.OfflinerepoResShow).value))
			if v.value > tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.OfflinerepoResShow).value) then
				isShow = true
			end
		end
	end
	return isShow
end

function Close()
	if _ui.FinishCallBrack ~= nil then
		_ui.FinishCallBrack(true)
	end
	_ui = nil
end

function Show(callbrack)
	_ui = {}
	_ui.FinishCallBrack = callbrack
	OfflinerepoData.RequestOfflineReport(function() 
		_ui.Data = OfflinerepoData.GetData()
		Global.DumpMessage(_ui.Data , "d:/offlineReport.lua")
		local reportCount = 0
		for i, v in ipairs(_ui.Data.infos) do
			if v.type == ClientMsg_pb.OfflineReportType_ResGains then
				_ui.ResGains = v.data
			elseif v.type == ClientMsg_pb.OfflineReportType_ResLose then
				_ui.ResLose = v.data
			elseif v.type == ClientMsg_pb.OfflineReportType_ArmyTrain then
				_ui.ArmyTrain = v.data
			elseif v.type == ClientMsg_pb.OfflineReportType_ArmyLose then
				_ui.ArmyLose = v.data
			elseif v.type == ClientMsg_pb.OfflineReportType_BuildUpgrad then
				_ui.BuildUpgrad = v.data
			elseif v.type == ClientMsg_pb.OfflineReportType_TechUpgrad then
				_ui.TechUpgrad = v.data
			end
			reportCount = i
		end
		-- Global.OpenUI(_M)
		
		if reportCount >= 2 then
			Global.OpenUI(_M)
		elseif CheckResGains() then
			Global.OpenUI(_M)
		else
			if CheckResGains() == false then
				if _ui.FinishCallBrack ~= nil then
					_ui.FinishCallBrack(false)
				end
				return
			end
		end
	end)	
	
end

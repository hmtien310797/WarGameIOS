module("LaboratoryDetails",package.seeall)

local Category_pb = require("Category_pb")
local BuildMsg_pb = require("BuildMsg_pb")

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


local TargetTech

function SetTargetTech(tech)
    TargetTech = tech
end


local function QuitPressCallback(go, isPressed)
	if not isPressed then
		GUIMgr:CloseMenu("LaboratoryDetails")
	end
end

function Start()
    local detailItem
    local detailTitle
    local uiInfoGrid

    local bgScrollViewGrid
	local bgMid = transform:Find("Container/bg_frane/bg_mid")
	local bgTittle = transform:Find("Container/bg_frane/bg_top/bg_title_left/title")
	local bgDescription = transform:Find("Container/bg_frane/text_miaosu")
	
	bgScrollViewGrid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid")
	if TargetTech.BaseData.TechId == 1100 then
		bgScrollViewGrid.gameObject:SetActive(false)
		bgScrollViewGrid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid (1)")
		bgScrollViewGrid.gameObject:SetActive(true)
		local bg_title = transform:Find("Container/bg_frane/bg_mid/bg_title")
		bg_title.gameObject:SetActive(false)
		bg_title = transform:Find("Container/bg_frane/bg_mid/bg_title (1)")
		bg_title.gameObject:SetActive(true)
	end
	local tittleLabal = bgTittle.gameObject:GetComponent("UILabel")
	tittleLabal.text = TextMgr:GetText(TargetTech.BaseData.Name)
	local ttt = transform:Find(string.format("Container/bg_frane/bg_mid/bg_title/text (3)")):GetComponent("UILabel")
	if TargetTech.BaseData.TechId == 1100 then
		ttt = transform:Find(string.format("Container/bg_frane/bg_mid/bg_title (1)/text (3)")):GetComponent("UILabel")
	end
	ttt.text = TextMgr:GetText(TargetTech.BaseData.Dese)

	local desLabel = bgDescription:GetComponent("UILabel")
	if TargetTech.BaseData.Value == 0 then 
		if TargetTech.BaseData.TechId == 1100 then
			desLabel.text = TextMgr:GetText(TargetTech.BaseData.Dese) 
	        ttt.text =  TextMgr:GetText("Tec_spy_des") 
		else
	        desLabel.text = TextMgr:GetText(TargetTech.BaseData.Detail) 
	        ttt.text =  TextMgr:GetText("common_ui7") 
	    end
	else
	    desLabel.text = TextMgr:GetText(TargetTech.BaseData.Detail)
	    ttt.text = TextMgr:GetText(TargetTech.BaseData.Dese)
	end
	
	
	local btnQuit = transform:Find("Container/bg_frane/bg_top/btn_close")
	SetPressCallback(btnQuit.gameObject, QuitPressCallback)
	SetPressCallback(transform:Find("Container").gameObject, function() GUIMgr:CloseMenu("BuildingDetails") end)

	detailItem = transform:Find("Detailsinfo")
	if TargetTech.BaseData.TechId == 1100 then
		detailItem = transform:Find("Detailsinfo (1)")
		detailItem.gameObject:SetActive(true)
	end
    local index = 0
	table.foreach(TargetTech,function(i,v)
	    if type(i) == "number" then	        
		    local item = NGUITools.AddChild(bgScrollViewGrid.gameObject, detailItem.gameObject)
		    if index%2 == 0 then
			    item.transform:Find("bg_list").gameObject:SetActive(false)
            end		    
	    	if (i) == (TargetTech.Info.level) then
			    item.transform:Find("bg_select").gameObject:SetActive(true)
		    else
			    item.transform:Find("bg_select").gameObject:SetActive(false)
		    end			
	    	item.transform:SetParent(bgScrollViewGrid, false)
		    item.transform:Find("text (1)"):GetComponent("UILabel").text = i
		    item.transform:Find("text (2)"):GetComponent("UILabel").text = v.AddFight
		    if TargetTech.BaseData.TechId == 1100 then
		    	item.transform:Find("text (3)"):GetComponent("UILabel").text = TextMgr:GetText(v.Detail)
		    else
		    	item.transform:Find("text (3)"):GetComponent("UILabel").text = TargetTech.BaseData.Value == 0 and TextMgr:GetText(v.Dese) or LaboratoryUpgrade.GetAttrValueString(v.AttrType,v.Value,v.Sign)
		    end
			
			if (i) == (TargetTech.Info.level) then 
				item.transform:Find("text (1)"):GetComponent("UILabel").color = Color.white
				item.transform:Find("text (2)"):GetComponent("UILabel").color = Color.white
				item.transform:Find("text (3)"):GetComponent("UILabel").color = Color.white
			end 
		    index = index + 1
        end
	end)


    uiInfoGrid = bgScrollViewGrid:GetComponent("UIGrid")
	uiInfoGrid:Reposition()
	
end

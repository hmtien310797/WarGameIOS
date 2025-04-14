module("LaboratoryUpgrade",package.seeall)

local Category_pb = require("Category_pb")
local BuildMsg_pb = require("BuildMsg_pb")

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
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
local GameTime = Serclimax.GameTime

local _ui

local TargetTech

local IsTop
local lock 
local CloseUpdate
Init = nil

local RequestTechUpAccl

local isOpen

function IsOpen()
    return isOpen
end

function SetTargetTech(tech,closeUpdate)
    TargetTech = tech
    CloseUpdate = closeUpdate
end

function GetCurrentTechData()
    return TargetTech
end

local function MakeList(list, i, stype, arg1, arg2, arg3)
    list[i] = {}
    list[i].type = stype
    list[i].title = arg1
    list[i].text1 = arg2
    list[i].text2 = arg3
    return i + 1
end

--科技升级详情：数值展示修正为填什么即显示什么  -- wuzhiyang
function GetAttrValueString(attrAddition, attrValue,effect)
    if Global.IsHeroPercentAttrAddition(attrAddition) then
        if effect == 0 then
            --return string.format("+%.1f%%", attrValue)
			return "+"..attrValue.."%"
        else
            --return string.format("-%.1f%%", attrValue)
			return "-"..attrValue.."%"
        end
    else
        if effect == 0 then
            --return string.format("+%.1f", attrValue)
			return "+"..attrValue
        else
            --return string.format("-%.1f", attrValue)
			return "-"..attrValue
        end        
        
    end
end

local function GetCurrentTechNextUnlock(tech)
    local unlocklist = {}
    local index = 1
    local isMax = tech.Info.level >= tech.BaseData.MaxLevel

    if isMax then
        index = MakeList(unlocklist, index, 2, TextMgr:GetText("build_ui40"),nil,  tech.Info.level)
        if tech.BaseData.Value == 0 then 
        	if tech.BaseData.TechId == 1100 then
        		index = MakeList(unlocklist, index, 3, TextMgr:GetText("Tec_spy_des"),nil, TextMgr:GetText(tech[tech.Info.level].Detail))
        	else
            	index = MakeList(unlocklist, index, 2, TextMgr:GetText("common_ui7"),nil, TextMgr:GetText(tech[tech.Info.level].Dese))
            end
        else
            index = MakeList(unlocklist, index, 2, TextMgr:GetText(tech.BaseData.Dese),nil,GetAttrValueString(tech[tech.Info.level].AttrType,tech[tech.Info.level].Value,tech[tech.Info.level].Sign))           
        end
    else
        index = MakeList(unlocklist, index, 1, TextMgr:GetText("build_ui5"), tech.Info.level, tech.Info.level + 1)
        if tech.BaseData.Value == 0 then 
        	if tech.BaseData.TechId == 1100 then
        		index = MakeList(unlocklist, index, 3, TextMgr:GetText("Tec_spy_des2"),nil, TextMgr:GetText(tech[tech.Info.level + 1].Detail))
        	else
            	index = MakeList(unlocklist, index, 2, TextMgr:GetText("common_ui7"),nil, TextMgr:GetText(tech[tech.Info.level + 1].Dese))
            end
        else
            index = MakeList(unlocklist, index, 1, TextMgr:GetText(tech.BaseData.Dese),tech.Info.level == 0 and "0" or 
            GetAttrValueString(tech[tech.Info.level].AttrType,tech[tech.Info.level].Value,tech[tech.Info.level].Sign), 
            GetAttrValueString(tech[tech.Info.level+1].AttrType,tech[tech.Info.level+1].Value,tech[tech.Info.level+1].Sign))
        end
    end
    return unlocklist
end

local function CreatLeftInfo(i,type)
    local childCount = _ui.upgrade_condition_grid.transform.childCount
    local info = {}
    if i - 1 < childCount then
    	info.go = _ui.upgrade_condition_grid.transform:GetChild(i - 1).gameObject
    else
    	info.go = GameObject.Instantiate(_ui.list_left_path.go)
    end
    info.go.name =  "BuildingUpgradeLeftinfo "..type..i
    info.go.transform:SetParent(_ui.upgrade_condition_grid.transform, false)
    info.texture = info.go.transform:Find(_ui.list_left_path.texture):GetComponent("UITexture")
    info.text = info.go.transform:Find(_ui.list_left_path.text):GetComponent("UILabel")
    info.num = info.go.transform:Find(_ui.list_left_path.num):GetComponent("UILabel")
    info.icon_gou = info.go.transform:Find(_ui.list_left_path.icon_gou).gameObject
    info.icon_cha = info.go.transform:Find(_ui.list_left_path.icon_cha).gameObject
    info.btn_jiasu = info.go.transform:Find(_ui.list_left_path.btn_jiasu):GetComponent("UIButton")
    Laboratory.SetupAccBtnCallBack(info.btn_jiasu.gameObject,Init)
    info.btn_go = info.go.transform:Find(_ui.list_left_path.btn_go):GetComponent("UIButton")
    info.btn_free = info.go.transform:Find(_ui.list_left_path.btn_free):GetComponent("UIButton")
    info.btn_free.gameObject:SetActive(false) 
    info.btn_help = info.go.transform:Find(_ui.list_left_path.btn_help):GetComponent("UIButton")
    info.btn_help.gameObject:SetActive(false) 
    info.btn_get = info.go.transform:Find(_ui.list_left_path.btn_get):GetComponent("UIButton")
    info.icon_update = info.go.transform:Find("bg/icon/icon_update").gameObject
    info.icon_need = info.go.transform:Find("bg/icon/icon_need").gameObject
    info.go:SetActive(false)
    return info
end

local function CreatRightInfo(i)
    local info = {}
    
    if IsTop then
    	local childCount = _ui.Top_bg_right_grid.transform.childCount
    	if i - 1 < childCount then
	    	info.go = _ui.Top_bg_right_grid.transform:GetChild(i - 1).gameObject
	    else
	    	info.go = GameObject.Instantiate(_ui.list_right_path.go)
	    end
        info.go.transform:SetParent(_ui.Top_bg_right_grid.transform, false)
    else
    	local childCount = _ui.bg_right_grid.transform.childCount
    	if i - 1 < childCount then
	    	info.go = _ui.bg_right_grid.transform:GetChild(i - 1).gameObject
	    else
	    	info.go = GameObject.Instantiate(_ui.list_right_path.go)
	    end
        info.go.transform:SetParent(_ui.bg_right_grid.transform, false)
    end
    
    info.title_text = info.go.transform:Find(_ui.list_right_path.title_text):GetComponent("UILabel")
    info.bg_daijiantou = info.go.transform:Find(_ui.list_right_path.bg_daijiangou).gameObject
    info.bg_meijiantou = info.go.transform:Find(_ui.list_right_path.bg_meijiantou).gameObject
    info.num_left = info.go.transform:Find(_ui.list_right_path.num_left):GetComponent("UILabel")
    info.num_right = info.go.transform:Find(_ui.list_right_path.num_right):GetComponent("UILabel")
    info.text = info.go.transform:Find(_ui.list_right_path.text):GetComponent("UILabel")
    return info
end

local function RemoveLeftAt(index)
	local childCount = _ui.upgrade_condition_grid.transform.childCount
	for i = childCount - 1, index,-1 do
	    local trf = _ui.upgrade_condition_grid.transform:GetChild(i)
	    trf.parent = _ui.upgrade_condition_grid.transform.parent
        GameObject.Destroy(trf.gameObject)
    end
end

local function RemoveRightAt(index)
	if IsTop then
		local childCount = _ui.Top_bg_right_grid.transform.childCount
		for i = childCount - 1, index,-1 do
		    local trf = _ui.Top_bg_right_grid.transform:GetChild(i)
		    trf.parent = _ui.Top_bg_right_grid.transform.parent
	        GameObject.Destroy(trf.gameObject)
	    end
	else
		local childCount = _ui.bg_right_grid.transform.childCount
		for i = childCount - 1, index,-1 do
		    local trf = _ui.bg_right_grid.transform:GetChild(i)
		    trf.parent = __ui.bg_right_grid.transform.parent
	        GameObject.Destroy(trf.gameObject)
	    end
	end
end

function Awake()
    _ui = {}
    _ui.RootNormal = transform:Find("LaboratoryUpgrade_normal").gameObject 
    _ui.RootTop = transform:Find("LaboratoryUpgrade_top").gameObject 
    _ui.bg_title = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/bg_top/bg_title_left/title"):GetComponent("UILabel")
    _ui.top_bg_title = transform:Find("LaboratoryUpgrade_top/Container/bg_frane/bg_top/bg_title_left/title"):GetComponent("UILabel")
    _ui.btn_close = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
    _ui.Top_btn_close = transform:Find("LaboratoryUpgrade_top/Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
    _ui.upgrade_condition_grid = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/bg_left/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.bg_right_texture = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/bg_right/Texture"):GetComponent("UITexture")
    _ui.bg_right_grid = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/bg_right/Grid"):GetComponent("UIGrid")
    _ui.Top_bg_right_texture = transform:Find("LaboratoryUpgrade_top/Container/bg_frane/bg_right/Texture"):GetComponent("UITexture")
    _ui.Top_bg_right_grid =  transform:Find("LaboratoryUpgrade_top/Container/bg_frane/bg_right/Grid"):GetComponent("UIGrid")
    _ui.btn_upgrade = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/btn_upgrade"):GetComponent("UIButton")
    _ui.btn_upgrade_sound = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/btn_upgrade"):GetComponent("UISound")
    _ui.btn_upgrade_des =  transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/btn_upgrade/text"):GetComponent("UILabel")
    _ui.btn_upgrade_timeDisplay = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/time"):GetComponent("UISprite")
    _ui.btn_upgrade_time0Display = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/time0"):GetComponent("UISprite")
    _ui.btn_upgrade_time = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/time/num"):GetComponent("UILabel")
    _ui.btn_upgrade_time0 = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/time0/num"):GetComponent("UILabel")
    _ui.btn_upgrade_gold = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/btn_upgrade_gold"):GetComponent("UIButton")
    _ui.btn_upgrade_gold_sound = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/btn_upgrade_gold"):GetComponent("UISound")
    _ui.btn_upgrade_gold_num = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/btn_upgrade_gold/num"):GetComponent("UILabel")
    _ui.btn_upgrade_gold_des = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/btn_upgrade_gold/text"):GetComponent("UILabel")
    _ui.upgrade_left_info = transform:Find("BuildingUpgradeLeftinfo")
    _ui.upgrade_right_info = transform:Find("BuildingUpgradeRightinfo")

    _ui.Info_Btn = transform:Find("LaboratoryUpgrade_normal/Container/bg_frane/bg_right/btn_info"):GetComponent("UIButton")
    _ui.Top_Info_Btn = transform:Find("LaboratoryUpgrade_top/Container/bg_frane/bg_right/btn_info"):GetComponent("UIButton")

    _ui.list_left_path = {}
    _ui.list_left_path.go = transform:Find("LaboratoryUpgrade_normal/BuildingUpgradeLeftinfo").gameObject
    _ui.list_left_path.texture = "bg/Texture"
    _ui.list_left_path.text = "bg/text"
    _ui.list_left_path.num = "bg/num"
    _ui.list_left_path.icon_gou = "bg/icon_gou"
    _ui.list_left_path.icon_cha = "bg/icon_cha"
    _ui.list_left_path.btn_jiasu = "bg/btn_jiasu"
    _ui.list_left_path.btn_go = "bg/btn_go"
    _ui.list_left_path.btn_free = "bg/btn_free"
    _ui.list_left_path.btn_get = "bg/btn_get"    
    _ui.list_left_path.btn_help = "bg/btn_help"

    _ui.list_right_path = {}
    _ui.list_right_path.go = transform:Find("LaboratoryUpgrade_normal/BuildingUpgradeRightinfo").gameObject
    _ui.list_right_path.title_text = "bg_title/text"
    _ui.list_right_path.bg_daijiangou = "bg_daijiantou"
    _ui.list_right_path.num_left = "bg_daijiantou/num_left"
    _ui.list_right_path.num_right = "bg_daijiantou/num_right"
    _ui.list_right_path.bg_meijiantou = "bg_meijiantou"
    _ui.list_right_path.text = "bg_meijiantou/text"

    _ui.list_upgrade_left_info = {}
    _ui.list_upgrade_right_info = {}
    _ui.RootNormal:SetActive(false)
    _ui.RootTop:SetActive(false)
end

Init = function()
    if _ui.RootNormal == nil then
        return
    end
	AttributeBonus.CollectBonusInfo()
    _ui.RootNormal:SetActive(false)
    _ui.RootTop:SetActive(false)
    --[[
    local childCount = _ui.bg_right_grid.transform.childCount
    for i = 0, childCount - 1 do
        GameObject.Destroy(_ui.bg_right_grid.transform:GetChild(i).gameObject)
    end
    childCount = _ui.upgrade_condition_grid.transform.childCount
    for i = 0, childCount - 1 do
        _ui.upgrade_condition_grid.transform:GetChild(i).gameObject:SetActive(false)
        GameObject.Destroy(_ui.upgrade_condition_grid.transform:GetChild(i).gameObject)
    end

    childCount = _ui.Top_bg_right_grid.transform.childCount
    for i = 0, childCount - 1 do
        GameObject.Destroy(_ui.Top_bg_right_grid.transform:GetChild(i).gameObject)
    end    
    --]]
    if TargetTech.Info.level >= TargetTech.BaseData.MaxLevel and TargetTech.Info.endtime < Serclimax.GameTime.GetSecTime() then
        IsTop = true
        SetClickCallback(_ui.Top_btn_close.gameObject, function (go)
            GUIMgr:CloseMenu("LaboratoryUpgrade")
        end)
        SetClickCallback(transform:Find("LaboratoryUpgrade_top/Container").gameObject, function() GUIMgr:CloseMenu("LaboratoryUpgrade") end)          
    else
        IsTop = false
        SetClickCallback(_ui.btn_close.gameObject, function (go)
            GUIMgr:CloseMenu("LaboratoryUpgrade")
        end)
        SetClickCallback(transform:Find("LaboratoryUpgrade_normal/Container").gameObject, function() GUIMgr:CloseMenu("LaboratoryUpgrade") end)   
    end

    _ui.RootNormal:SetActive(not IsTop)
    _ui.RootTop:SetActive(IsTop)

  

    if IsTop then
        _ui.top_bg_title.text = TextMgr:GetText(TargetTech.BaseData.Name)
    else
        _ui.bg_title.text = TextMgr:GetText(TargetTech.BaseData.Name)
    end
   

    local enable_upgrade = true
    local enable_gold_upgrade = true    
    local rightcount = 0
    if IsTop then
        local nextList = GetCurrentTechNextUnlock(TargetTech)
        for i, v in ipairs(nextList) do
            local r = CreatRightInfo(i)
            rightcount = i
            r.title_text.text = v.title
            if v.type == 1 then
                r.bg_meijiantou:SetActive(false)
                r.bg_daijiantou:SetActive(true)
                r.num_left.text = v.text1
                r.num_right.text = v.text2
            else
                r.bg_daijiantou:SetActive(false)
                r.bg_meijiantou:SetActive(true)
                r.text.text = v.text2
            end
        end
        _ui.Top_bg_right_texture.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "Laboratory/", TargetTech.BaseData.Icon)
        SetClickCallback(_ui.Top_Info_Btn.gameObject,function(go)
            LaboratoryDetails.SetTargetTech(TargetTech)
            GUIMgr:CreateMenu("LaboratoryDetails",false)
        end)        
        return 
    end

    local baseTime = TargetTech[math.min(TargetTech.BaseData.MaxLevel, TargetTech.Info.level + 1)].CostTime
    _ui.btn_upgrade_time0.text = System.String.Format(TextMgr:GetText("time_old"), Serclimax.GameTime.SecondToString3(baseTime)) --原始研发时间
    if TargetTech.Info.endtime <= Serclimax.GameTime.GetSecTime() then
        _ui.btn_upgrade_time.text = System.String.Format(TextMgr:GetText("time_now"), Serclimax.GameTime.SecondToString3(Laboratory.GetTechCostTime(baseTime)))
        CountDown.Instance:Remove("TechUpgrade")
    else
        CountDown.Instance:Add("TechUpgrade",TargetTech.Info.endtime,CountDown.CountDownCallBack(function(t)
        	if _ui.btn_upgrade_time ~= nil and not _ui.btn_upgrade_time:Equals(nil) then
            	_ui.btn_upgrade_time.text = System.String.Format(TextMgr:GetText("time_now"), t)
            end
         end))            
    end
    

    local nextList = GetCurrentTechNextUnlock(TargetTech)
    for i, v in ipairs(nextList) do
        local r = CreatRightInfo(i)
        rightcount = i
        r.title_text.text = v.title
        if v.type == 1 then
            r.bg_meijiantou:SetActive(false)
            r.bg_daijiantou:SetActive(true)
            r.go.transform:Find("bg_meijiantou (1)").gameObject:SetActive(false)
            r.num_left.text = v.text1
            r.num_right.text = v.text2
        elseif v.type == 2 then
            r.bg_daijiantou:SetActive(false)
            r.bg_meijiantou:SetActive(true)
            r.text.text = v.text2
        else
        	r.bg_meijiantou:SetActive(false)
            r.bg_daijiantou:SetActive(false)
            r.go.transform:Find("bg_meijiantou (1)").gameObject:SetActive(true)
            r.go.transform:Find("bg_meijiantou (1)/text"):GetComponent("UILabel").text = v.text2
        end
    end
    RemoveRightAt(rightcount)
	local leftcount = 0
    local upgrading = Laboratory.GetCurUpgradeTech()
    if upgrading ~= nil then
    	leftcount = leftcount + 1
    	local l = CreatLeftInfo(leftcount,"cur upgrade tech")
    	l.text.text = String.Format(TextMgr:GetText("build_ui31"), TextMgr:GetText(upgrading.BaseData.Name))
    	-- icon change
        --	l.texture.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "Laboratory/", upgrading.BaseData.Icon)
        l.texture.gameObject:SetActive(false)
        l.icon_update:SetActive(true)
    	CountDown.Instance:Add(upgrading.BaseData.TechId .. "Upgrading",upgrading.Info.endtime, function(t)
    	    if upgrading == nil then
    	        CountDown.Instance:Remove(upgrading.BaseData.TechId .. "Upgrading")
    	        Init()
    	        return 
            end
            if l.num ~= nil and not l.num:Equals(nil) then
    			l.num.text = t
    			if upgrading.Info.endtime > Serclimax.GameTime.GetSecTime() then
		    		if upgrading.Info.endtime - Serclimax.GameTime.GetSecTime() <= maincity.techFreeTime() then
						l.btn_free.gameObject:SetActive(true)
						l.btn_jiasu.gameObject:SetActive(false)
						l.btn_help.gameObject:SetActive(false)
					elseif UnionInfoData.HasUnion() and ((upgrading.Info.beginTime ~= nil and UnionInfoData.GetJoinTime() ~= nil) and upgrading.Info.beginTime >= UnionInfoData.GetJoinTime()) then
						if UnionHelpData.HasTechHelp() then
							l.btn_free.gameObject:SetActive(false)
							l.btn_jiasu.gameObject:SetActive(false)
							l.btn_help.gameObject:SetActive(true)
						else
							l.btn_free.gameObject:SetActive(false)
							l.btn_jiasu.gameObject:SetActive(true)
							l.btn_help.gameObject:SetActive(false)
						end
					else
						l.btn_free.gameObject:SetActive(false)
						l.btn_jiasu.gameObject:SetActive(true)
						l.btn_help.gameObject:SetActive(false)
					end
					if TargetTech.BaseData.TechId == upgrading.BaseData.TechId then
                        _ui.btn_upgrade_gold_num.text = Mathf.Ceil(maincity.CaculateGoldForTime(1, math.max(0, upgrading.Info.endtime - Serclimax.GameTime.GetSecTime() - maincity.techFreeTime())))
		                if upgrading.Info.endtime - Serclimax.GameTime.GetSecTime() <= maincity.techFreeTime() then
				        	_ui.btn_upgrade.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("speedup_ui7")
							SetClickCallback(_ui.btn_upgrade.gameObject, function() RequestTechUpAccl() end)
							BuildingUpgrade.SetBtnEnable(_ui.btn_upgrade, true, "btn_free", "btn_free")
				        elseif UnionInfoData.HasUnion() and ((upgrading.Info.beginTime ~= nil and UnionInfoData.GetJoinTime() ~= nil) and upgrading.Info.beginTime >= UnionInfoData.GetJoinTime()) then
							if UnionHelpData.HasTechHelp() then
								_ui.btn_upgrade.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("union_help")
								SetClickCallback(_ui.btn_upgrade.gameObject, function() UnionHelpData.RequestTechHelp(Init) end)
								BuildingUpgrade.SetBtnEnable(_ui.btn_upgrade, true, "btn_2", "btn_2")
							else
								_ui.btn_upgrade.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("build_ui21")
								Laboratory.SetupAccBtnCallBack(_ui.btn_upgrade.gameObject,Init) 
								BuildingUpgrade.SetBtnEnable(_ui.btn_upgrade, true, "btn_7", "btn_4")
							end
						else
							_ui.btn_upgrade.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("build_ui21")
							Laboratory.SetupAccBtnCallBack(_ui.btn_upgrade.gameObject,Init)
							BuildingUpgrade.SetBtnEnable(_ui.btn_upgrade, true, "btn_7", "btn_4")
						end
					end
                end
    		end
    		if t == "00:00:00" then
    			CountDown.Instance:Remove(upgrading.BaseData.TechId .. "Upgrading")
    			Laboratory.CheckUpgradeProgress(0)
    			Init()
            end
    	end)
    	l.icon_gou:SetActive(false)
    	l.icon_cha:SetActive(false)
     	if upgrading.Info.endtime - Serclimax.GameTime.GetSecTime() <= maincity.techFreeTime() then
			l.btn_free.gameObject:SetActive(true)
			l.btn_jiasu.gameObject:SetActive(false)
			l.btn_help.gameObject:SetActive(false)
		elseif UnionInfoData.HasUnion() and upgrading.Info.beginTime >= UnionInfoData.GetJoinTime() then
			if UnionHelpData.HasTechHelp() then
				l.btn_free.gameObject:SetActive(false)
				l.btn_jiasu.gameObject:SetActive(false)
				l.btn_help.gameObject:SetActive(true)
			else
				l.btn_free.gameObject:SetActive(false)
				l.btn_jiasu.gameObject:SetActive(true)
				l.btn_help.gameObject:SetActive(false)
			end
		else
			l.btn_free.gameObject:SetActive(false)
			l.btn_jiasu.gameObject:SetActive(true)
			l.btn_help.gameObject:SetActive(false)
		end
		SetClickCallback(l.btn_free.gameObject, function(go)
			l.btn_free.gameObject:SetActive(false)
			RequestTechUpAccl()
		end)
		SetClickCallback(l.btn_help.gameObject, UnionHelpData.RequestTechHelp)
        l.btn_go.gameObject:SetActive(false)
        if TargetTech.BaseData.TechId ~= upgrading.BaseData.TechId then
            enable_upgrade = enable_upgrade and false
        end
        --enable_gold_upgrade = enable_gold_upgrade and false        
    end
    lock = {}
    lock.enable = false
    local preconditionenough = true
    local condition = TargetTech[TargetTech.Info.level+1].Condition;
    if condition.Base ~= nil then
        for i = 1,#(condition.Base) do
        	leftcount = leftcount + 1
            local l = CreatLeftInfo(leftcount,"normal condition")
            local t = Laboratory.GetTech( condition.Base[i].index)
            local str = nil--= TextMgr:GetText(t.BaseData.Name) .. " : LV" .. condition.Base[i].value
            local isenough = t.Info.level >=  condition.Base[i].value 
            if not isenough then
                str = "[ff0000]" .. TextMgr:GetText(t.BaseData.Name) .. " : LV" .. condition.Base[i].value
                lock.enable = true
                if lock.condition == nil then
                    lock.condition = condition.Base[i]
                end
                preconditionenough = false
        		l.icon_gou:SetActive(false)
		    	l.icon_cha:SetActive(true)
		    	l.btn_go.gameObject:SetActive(true)
		    	SetClickCallback(l.btn_go.gameObject, function(go)		    		
		    		SetTargetTech(t)
		    		Init()
                end)

                enable_upgrade = enable_upgrade and false
                enable_gold_upgrade = enable_gold_upgrade and false
            else
                str = TextMgr:GetText(t.BaseData.Name) .. " : LV" .. condition.Base[i].value
        		l.icon_gou:SetActive(true)
		    	l.icon_cha:SetActive(false)
		    	l.btn_go.gameObject:SetActive(false)
            end
            l.text.text = str
            --icon  change
	        --l.texture.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "Laboratory/", t.BaseData.Icon)
	        l.texture.gameObject:SetActive(false)
	        l.icon_need:SetActive(true)
	        l.num.gameObject:SetActive(false)
	        l.btn_jiasu.gameObject:SetActive(false)
            l.btn_get.gameObject:SetActive(false)
        end
    end

    if condition.Other ~= nil then
        for i = 1,#(condition.Other) do
        	leftcount = leftcount + 1
        	local _d = TableMgr:GetBuildingData(condition.Other[i].index)
        	local str
        	local l = CreatLeftInfo(leftcount,"advanced condition")
        	if condition.Other[i].type == 1 then
        		local isenough, lv = maincity.CheckLevelByID(condition.Other[i].index, condition.Other[i].value)
        		if not isenough then
                    lock.enable = true
                    if lock.condition == nil then
                        lock.condition = condition.Other[i]
                    end
        			str = "[ff0000]" .. TextMgr:GetText(_d.name) .. " : LV" .. condition.Other[i].value
        			l.icon_gou:SetActive(false)
                    l.icon_cha:SetActive(true)
                    preconditionenough = false
		    		l.btn_go.gameObject:SetActive(true)
		    		SetClickCallback(l.btn_go.gameObject, function(go)
		    			Laboratory.OnCloseCB = nil
                        maincity.SetTargetBuild(condition.Other[i].index, false, nil, false, false, true, function()
                            if lv > 0 then
                                GUIMgr:CreateMenu("BuildingUpgrade", false)
                                MainCityUI.HideCityMenu()
                                BuildingUpgrade.OnCloseCB = function()
                                    MainCityUI.RemoveMenuTarget()
                                    BuildingShowInfoUI.Refresh()
                                end
                            end
						end)
		    		    GUIMgr:CloseMenu("LaboratoryUpgrade")
                        GUIMgr:CloseMenu("Laboratory")
		    		end)
                    enable_upgrade = enable_upgrade and false
                    enable_gold_upgrade = enable_gold_upgrade and false		    		
        		else
        			str = TextMgr:GetText(_d.name) .. " : LV" .. condition.Other[i].value
                    l.text.gradientTop = Color.white
                    l.text.gradientBottom = Color.white
        			l.icon_gou:SetActive(true)
		    		l.icon_cha:SetActive(false)
		    		l.btn_go.gameObject:SetActive(false)
                end
        	elseif condition.Other[i].type == 2 then
        		local count = maincity.GetBuildingCount(condition.Other[i].index)
        		if count >=  condition.Other[i].value then
        			str = TextMgr:GetText(_d.name) .. "X" .. condition.Other[i].value
        		else
        			str = TextMgr:GetText(_d.name) .. "X" .. count
                end
        	end
        	l.text.text = str
	        l.texture.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "building/", _d.icon)
	        l.num.gameObject:SetActive(false)
	        l.btn_jiasu.gameObject:SetActive(false)
            l.btn_get.gameObject:SetActive(false)
        end        
    end
	RemoveLeftAt(leftcount)
    local res = TargetTech[TargetTech.Info.level + 1].Res 
    local needgold = false
    if res ~= nil then
        for i, v in ipairs(res) do
        	leftcount = leftcount + 1
            local l = CreatLeftInfo(leftcount,"res")
            l.text.gameObject:SetActive(true)
            l.num.gameObject:SetActive(false)
            local r = MoneyListData.GetMoneyByType(v.type)
            if r == nil then
                r = 0
            end
            l.texture.mainTexture = ResourceLibrary:GetIcon("Item/", TableMgr:GetItemData(v.type).icon)
            local str = "";
            if tonumber(r) < tonumber(v.value) then
                str = System.String.Format("[ff0000]{0}[ffffff]  /  {1}",Global.ExchangeValue(r),Global.ExchangeValue(v.value))
                lock.enable = true
                if lock.res == nil then
                     lock.res = v
                 end
                l.icon_gou:SetActive(false)
                l.btn_get.gameObject:SetActive(true)
                SetClickCallback(l.btn_get.gameObject, function(go)
		        	local noitem = Global.BagIsNoItem(maincity.GetItemResList(v.type))
		        	if noitem then
		        		AudioMgr:PlayUISfx("SFX_ui02", 1, false)
		        		FloatText.Show(TextMgr:GetText("player_ui18"), Color.white)
		        		return
		        	end
		        	CommonItemBag.SetTittle(TextMgr:GetText("get_resource" .. (v.type - 2)))
			        CommonItemBag.NotUseAutoClose()
                    CommonItemBag.SetResType(v.type)
			        CommonItemBag.SetItemList(maincity.GetItemResList(v.type), 0)
					CommonItemBag.SetUseFunc(maincity.UseResItemFunc)
					GUIMgr:CreateMenu("CommonItemBag" , false)
					CommonItemBag.OnCloseCB = function()
					    Init()				    
                    end					
		        end)  
                needgold = true
                enable_upgrade = enable_upgrade and false
            else
                str = System.String.Format("{0}  /  {1}", Global.ExchangeValue(tonumber(r)), Global.ExchangeValue(v.value))
                l.icon_cha:SetActive(false)
                l.btn_get.gameObject:SetActive(false)
            end
            l.text.text = str
            l.btn_jiasu.gameObject:SetActive(false)
            l.btn_go.gameObject:SetActive(false)
        end
    end
    local gold = 0
    if needgold then
    	for i, v in pairs(res) do
    		local resleft = tonumber(v.value) - MoneyListData.GetMoneyByType(tonumber(v.type))
    		if resleft > 0 then
    			gold = gold + maincity.CaculateGoldForRes(v.type, resleft)
    		end
    	end
    	gold = Mathf.Ceil(gold - 0.5)
    end
    gold = gold + maincity.CaculateGoldForTime(1, math.max(0, Laboratory.GetTechCostTime(TargetTech[TargetTech.Info.level+1].CostTime) - maincity.techFreeTime()))
    gold = Mathf.Ceil(gold - 0.5)
    if gold <= 0 then
    	gold = 0
    end    
    _ui.btn_upgrade_gold_num.text = gold
    if gold > MoneyListData.GetDiamond() then
        enable_gold_upgrade = enable_gold_upgrade and false
    end    
    
    --coroutine.start(function()
    --    coroutine.step()
        _ui.bg_right_grid:Reposition()
        local childCount = _ui.upgrade_condition_grid.transform.childCount
        for i = 0, childCount - 1 do
            _ui.upgrade_condition_grid.transform:GetChild(i).gameObject:SetActive(true)
        end        
        _ui.upgrade_condition_grid:Reposition()
    --end)

	_ui.bg_right_texture.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "Laboratory/", TargetTech.BaseData.Icon)
	
	--是否隐藏研发时间
	_ui.btn_upgrade_timeDisplay.gameObject:SetActive(enable_upgrade or Laboratory.IsUnlock(TargetTech))
	_ui.btn_upgrade_time0Display.gameObject:SetActive(enable_upgrade or Laboratory.IsUnlock(TargetTech))

    if enable_upgrade then
        _ui.btn_upgrade_sound.State = 0
    else
        _ui.btn_upgrade_sound.State = 1
    end

    if enable_gold_upgrade then
        _ui.btn_upgrade_gold_sound.State = 0
    else
        _ui.btn_upgrade_gold_sound.State = 1
    end

	BuildingUpgrade.SetBtnEnable(_ui.btn_upgrade, enable_upgrade, "btn_1", "btn_4")
	BuildingUpgrade.SetBtnEnable(_ui.btn_upgrade_gold, enable_gold_upgrade, "btn_2", "btn_4")

	if upgrading ~= nil and TargetTech.BaseData.TechId == upgrading.BaseData.TechId then
	    _ui.btn_upgrade_gold_des.text = TextMgr:GetText("build_ui36")   
	    --_ui.btn_upgrade_gold_num.text = Mathf.Ceil(maincity.CaculateGoldForTime(1, TargetTech.Info.endtime - GameTime.GetSecTime()))
	    _ui.btn_upgrade_gold_num.text = Mathf.Ceil(maincity.CaculateGoldForTime(1, math.max(0, upgrading.Info.endtime - Serclimax.GameTime.GetSecTime() - maincity.techFreeTime())))
        SetClickCallback(_ui.btn_upgrade_gold.gameObject, function (go)
             --立刻完成
            -- local goldNeeded = tonumber(_ui.btn_upgrade_gold_num.text)
            -- MessageBox.ShowConfirmation(enable_gold_upgrade and goldNeeded ~= 0, System.String.Format(TextMgr:GetText("purchase_confirmation2"), goldNeeded, TextMgr:GetText(TargetTech.BaseData.Name) .. "LV. " .. (TargetTech.Info.level + 1)), RequestTechUpAccl)
            RequestTechUpAccl()
        end)
        if upgrading.Info.endtime - Serclimax.GameTime.GetSecTime() <= maincity.techFreeTime() then
			_ui.btn_upgrade.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("speedup_ui7")
			SetClickCallback(_ui.btn_upgrade.gameObject, function() RequestTechUpAccl() end)
			BuildingUpgrade.SetBtnEnable(_ui.btn_upgrade, true, "btn_free", "btn_free")
		elseif UnionInfoData.HasUnion() and upgrading.Info.beginTime >= UnionInfoData.GetJoinTime() then
			if UnionHelpData.HasTechHelp() then
				_ui.btn_upgrade.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("union_help")
				SetClickCallback(_ui.btn_upgrade.gameObject, function() UnionHelpData.RequestTechHelp(Init) end)
				BuildingUpgrade.SetBtnEnable(_ui.btn_upgrade, true, "btn_2", "btn_2")
			else
				_ui.btn_upgrade.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("build_ui21")
				Laboratory.SetupAccBtnCallBack(_ui.btn_upgrade.gameObject,Init) 
				BuildingUpgrade.SetBtnEnable(_ui.btn_upgrade, true, "btn_7", "btn_4")
			end
		else
			_ui.btn_upgrade.transform:Find("text"):GetComponent("UILabel").text = TextMgr:GetText("build_ui21")
			Laboratory.SetupAccBtnCallBack(_ui.btn_upgrade.gameObject,Init)
			BuildingUpgrade.SetBtnEnable(_ui.btn_upgrade, true, "btn_7", "btn_4")
		end
	else
	    _ui.btn_upgrade_des.text = TextMgr:GetText("build_ui8")
	    _ui.btn_upgrade_gold_des.text = TextMgr:GetText("build_ui9")
	    --[[
	    if lock.enable then
	        local txt =
	        if lock.condition ~= nil then
	        else if lock.res ~= nil then
	        end
	         
            SetClickCallback(_ui.btn_upgrade.gameObject,function (go)
        	    FloatText.ShowAt(_ui.btn_upgrade.transform.position, txt, Color.white)
            end)
            SetClickCallback(_ui.btn_upgrade_gold.gameObject, function (go)
                FloatText.ShowAt(_ui.btn_upgrade_gold.transform.position, txt, Color.white)
            end)                
	    else
	    --]]
	        if upgrading ~= nil then
                SetClickCallback(_ui.btn_upgrade.gameObject,function (go)
        	        FloatText.ShowAt(_ui.btn_upgrade.transform.position, TextMgr:GetText("build_ui37"), Color.white)
                end)
            else
        	    SetClickCallback(_ui.btn_upgrade.gameObject, function (go)
                    RequestUpgradeBuild(TargetTech.BaseData.TechId,false, gold, preconditionenough)
                end)
            end

            SetClickCallback(_ui.btn_upgrade_gold.gameObject, function (go)
                -- local goldNeeded = tonumber(_ui.btn_upgrade_gold_num.text)
                -- MessageBox.ShowConfirmation(enable_gold_upgrade and goldNeeded ~= 0, System.String.Format(TextMgr:GetText("purchase_confirmation2"), goldNeeded, TextMgr:GetText(TargetTech.BaseData.Name) .. "LV. " .. (TargetTech.Info.level + 1)), function()
                    RequestUpgradeBuild(TargetTech.BaseData.TechId,true, gold, preconditionenough)
                -- end)
            end)
        --end
	end

    SetClickCallback(_ui.Info_Btn.gameObject,function(go)
        LaboratoryDetails.SetTargetTech(TargetTech)
        GUIMgr:CreateMenu("LaboratoryDetails",false)
    end)	
end

RequestFree = function(succeed)
    local req = BuildMsg_pb.MsgUserTechUpAcclRequest()

    LuaNetwork.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgUserTechUpAcclRequest, req:SerializeToString(), function(typeId, data)
		local msg = BuildMsg_pb.MsgUserTechUpAcclResponse()
		msg:ParseFromString(data)	    
	    if msg.code == 0 then
	        print("MsgUserTechUpResponse",msg.tech.level,msg.tech.endtime)
	        local tech = Laboratory.GetTech(msg.tech.techid)
            if tech ~= nil then 
	            tech.Info.level = msg.tech.level
	            tech.Info.endtime = msg.tech.endtime
	            tech.Info.beginTime = msg.tech.beginTime
	            tech.Info.originaltime = msg.tech.originaltime
	            AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
	            FloatText.Show(TextMgr:GetText(tech.BaseData.Name).."  LV."..tech.Info.level.."   "..TextMgr:GetText("build_ui39"), Color.green)
                Global.GAudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed",1,false)    
	            Laboratory.ClearCurTechState(true)
            end
            MainCityQueue.UpdateQueue(); 
	        MainCityUI.UpdateRewardData(msg.fresh)
	        if succeed ~= nil then
	            succeed()
	        end
        else
            print("MsgUserTechUpResponse error ",msg.code)
            --Global.FloatErrorAt(_ui.btn_upgrade_gold.transform.position, msg.code, Color.white)
        end
	end, false)
end

local function RequestUpgradeBuildExx(techId,buy)
    local req = BuildMsg_pb.MsgUserTechUpRequest()
	req.techId = TargetTech.BaseData.TechId
	req.buy = buy
    Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgUserTechUpRequest, req, BuildMsg_pb.MsgUserTechUpResponse, function(msg)
	    if msg.code == 0 then
	        print("MsgUserTechUpResponse",msg.tech.level,msg.tech.endtime,buy)
	        TargetTech.Info.level = msg.tech.level
	        TargetTech.Info.endtime = msg.tech.endtime
	        TargetTech.Info.beginTime = msg.tech.beginTime
	        TargetTech.Info.originaltime = msg.tech.originaltime
            if TargetTech.Info.endtime > Serclimax.GameTime.GetSecTime() then
                Laboratory.SetCurUpgradeTech(TargetTech)
            end	        
            if buy then 
                local upgrade = Laboratory.GetCurUpgradeTech()
                if upgrade ~= nil and TargetTech.BaseData.TechId == upgrade.BaseData.TechId then
                    print("MsgUserTechUpResponse",TargetTech.Info.level,TargetTech.Info.endtime)
                    Laboratory.CheckUpgradeProgress(0)
                else
                    print("MsgUserTechUpResponse",TargetTech.Info.level,TargetTech.Info.endtime)
                    Laboratory.UpgradeTech(TargetTech)
                end
                -- Laboratory.SetCurUpgradeTech(TargetTech)
            else
                AudioMgr:PlayUISfx("SFX_UI_countdown_start", 1, false)
            end
            MainCityQueue.UpdateQueue();
            MainCityUI.UpdateRewardData(msg.fresh)
            if _ui ~= nil then
                Init()
            end	     
            if not buy then
                if not FunctionListData.IsUnlocked(145) then
                    GUIMgr:CloseMenu("LaboratoryUpgrade")
                    GUIMgr:CloseMenu("Laboratory")
                end   
            end
        else
            -- if _ui == nil then
            --     return
            -- end
            print("MsgUserTechUpResponse error ",msg.code)
            if buy then
            	if _ui.btn_upgrade_gold ~= nil and not _ui.btn_upgrade_gold:Equals(nil) then
                	Global.FloatErrorAt(_ui.btn_upgrade_gold.transform.position, msg.code, Color.white)
                else
                	Global.FloatError(msg.code, Color.white)
                end
            else
                if _ui.btn_upgrade ~= nil and not _ui.btn_upgrade:Equals(nil) then
                    Global.FloatErrorAt(_ui.btn_upgrade.transform.position, msg.code, Color.white)
                else
                    Global.FloatError(msg.code, Color.white)
                end
            end
	    end
	end, true)
end

RequestUpgradeBuild = function(techId,buy,gold,preconditionenough)
    if not buy then
        UnionHelpData.RequestData(function()
    --print("RequestUpgradeBuild",techId,buy)
            RequestUpgradeBuildExx(techid,buy)
	    end)
    else
        local tech = Laboratory.GetTech(techId)
        local level = tech.Info.level == 0 and 1 or (tech.Info.level + 1)
        local techname = TextMgr:GetText(tech.BaseData.Name).."  LV. "..level
        if not preconditionenough then
            FloatText.ShowAt(_ui.btn_upgrade_gold.transform.position, TextMgr:GetText("Code_Tech_LevelLess"), Color.red)
            return
        end
        if gold > MoneyListData.GetMoneyByType(Common_pb.MoneyType_Diamond) then
            Global.ShowNoEnoughMoney()
            return
        end
        if gold > tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.GoldLimitWarning).value) then
            if tonumber(os.date("%d")) == UnityEngine.PlayerPrefs.GetInt("t_today") then
                MessageBox.SetOkNow()
            else
                MessageBox.SetRemberFunction(function(ishide)
                    if ishide then
                        UnityEngine.PlayerPrefs.SetInt("t_today",tonumber(os.date("%d")))
                        UnityEngine.PlayerPrefs.Save()
                    end
                end)
            end
            MessageBox.Show(System.String.Format(TextMgr:GetText("purchase_confirmation2"), gold, techname), function()
                RequestUpgradeBuildExx(techid,buy)
            end, function() canClick_gold = true end)
        else
            RequestUpgradeBuildExx(techid,buy)
        end
    end
end

RequestTechUpAccl = function ()
    local beginrequest = function()
        local req = BuildMsg_pb.MsgUserTechUpAcclRequest()

        LuaNetwork.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgUserTechUpAcclRequest, req:SerializeToString(), function(typeId, data)
            local msg = BuildMsg_pb.MsgUserTechUpAcclResponse()
            msg:ParseFromString(data)	    
            if msg.code == 0 then
                print("MsgUserTechUpResponse",msg.tech.level,msg.tech.endtime)
                local tech = Laboratory.GetTech(msg.tech.techid)
                if tech ~= nil then 
                    tech.Info.level = msg.tech.level
                    tech.Info.endtime = msg.tech.endtime
                    tech.Info.beginTime = msg.tech.beginTime
                    tech.Info.originaltime = msg.tech.originaltime
                    Laboratory.CheckUpgradeProgress(0)
                end
                MainCityQueue.UpdateQueue();
                MainCityUI.UpdateRewardData(msg.fresh)
                Init()
            else
                print("MsgUserTechUpResponse error ",msg.code)
                Global.FloatErrorAt(_ui.btn_upgrade_gold.transform.position, msg.code, Color.white)
            end
        end, false)
    end
    local tech = Laboratory.GetTech(TargetTech.BaseData.TechId)
    local level = tech.Info.level == 0 and 1 or (tech.Info.level + 1)
    local techname = TextMgr:GetText(tech.BaseData.Name).."  LV. "..level
    local gold = Mathf.Ceil(maincity.CaculateGoldForTime(1, math.max(0, tech.Info.endtime - Serclimax.GameTime.GetSecTime() - maincity.techFreeTime())))
    if gold > MoneyListData.GetMoneyByType(Common_pb.MoneyType_Diamond) then
        Global.ShowNoEnoughMoney()
        return
    end
    if gold > tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.GoldLimitWarning).value) then
        if tonumber(os.date("%d")) == UnityEngine.PlayerPrefs.GetInt("t_today") then
            MessageBox.SetOkNow()
        else
            MessageBox.SetRemberFunction(function(ishide)
                if ishide then
                    UnityEngine.PlayerPrefs.SetInt("t_today",tonumber(os.date("%d")))
                    UnityEngine.PlayerPrefs.Save()
                end
            end)
        end
		MessageBox.Show(System.String.Format(TextMgr:GetText("purchase_confirmation2"), gold, techname), beginrequest, function() canClick_gold = true end)
	else
		beginrequest()
	end
end


function Start()
    Init()
    isOpen = true
    UnionHelpData.AddListener(Init)
end

function Close()
	UnionHelpData.RemoveListener(Init)
    _ui = {}
    isOpen = false
    --Laboratory.ShowResBar()
    CountDown.Instance:Remove(TargetTech.BaseData.TechId .. "Upgrading")
    if CloseUpdate then
    if Laboratory.GetCurUpgradeTech() ~= nil then
        --maincity.UpdateConstruction()
        maincity.RefreshBuildingTransition(maincity.GetBuildingByID(6))
    end        
    end  
end



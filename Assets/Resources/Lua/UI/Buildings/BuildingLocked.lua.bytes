module("BuildingLocked",package.seeall)

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
local building
local data
local buildcb

function SetBuildCallback(_buildcb)
	buildcb = _buildcb
end

function SetData(_data)
    building = _data
    data = building.unlockData
end

function Awake()
end

function Start()
    SetClickCallback(transform:Find("Container/bg_frane/bg_top/btn_close").gameObject, function (go)
        GUIMgr:CloseMenu("BuildingLocked")
    end)
    SetClickCallback(transform:Find("Container").gameObject,function() GUIMgr:CloseMenu("BuildingLocked") end)
    transform:Find("Container/bg_frane/bg_top/title"):GetComponent("UILabel").text = TextMgr:GetText(data.name)
    transform:Find("Container/bg_frane/bg_mid/Texture"):GetComponent("UITexture").gameObject:SetActive(false)   --.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "building/", data.icon)
    local bg_right_3DShow = transform:Find("Container/bg_frane/bg_mid/3DShow")
   	local b_obj = ResourceLibrary:GetMainCityInstance(data.icon.."_unlock")
	b_obj.transform.parent = bg_right_3DShow
	b_obj.transform.localPosition = Vector3.zero
	b_obj.transform.localScale = Vector3.one; 

    transform:Find("Container/bg_frane/txt"):GetComponent("UILabel").text = TextMgr:GetText(data.description)
    local btn_unlock = transform:Find("Container/bg_frane/btn_confirm").gameObject
    local str_unlock = transform:Find("Container/bg_frane/bg_mid/num_right").gameObject
    if building.unlockLand ~= nil then
    	if building.unlockLand == true then
    		SetClickCallback(btn_unlock, function()
	    		if buildcb ~= nil then
	    			buildcb()
	    			buildcb = nil
	    		end
	    		GUIMgr:CloseMenu("BuildingLocked")
	    	end)
	    	str_unlock:SetActive(false)
    	else
    		transform:Find("Container/bg_frane/bg_mid/num_right"):GetComponent("UILabel").text = building.unlockCondition
		    btn_unlock:SetActive(false)
    	end
    else
	    if building.canUnlock then
	    	SetClickCallback(btn_unlock, function()
	    		if buildcb ~= nil then
	    			MissionListData.BlockMsg()
	    			buildcb()
	    			buildcb = nil
	    		end
	    		GUIMgr:CloseMenu("BuildingLocked")
	    	end)
	    	str_unlock:SetActive(false)
	    else
		    local str = data.unlockCondition
		    local st = ""
		    if MainData.GetLevel() < data.needPlayerLevel then
		    	st = st .. System.String.Format(TextMgr:GetText("build_ui28"), TextMgr:GetText("common_hint4"), data.needPlayerLevel) .. " "
		    end
		    str = str:split(";")
		    for i, v in ipairs(str) do
		        local s = v:split(":")
		        if #s > 1 then
		            if tonumber(s[1]) == 1 then
		                st = st .. System.String.Format(TextMgr:GetText("build_ui28"), TextMgr:GetText(TableMgr:GetBuildingData(s[2]).name), s[3])
		            elseif tonumber(s[1]) == 2 then
		                st = st .. System.String.Format(TextMgr:GetText("build_ui29"), TextMgr:GetText(TableMgr:GetBuildingData(s[2]).name), s[3])
		            --elseif tonumber(s[1]) == 3 then
		            --    st = st .. System.String.Format(TextMgr:GetText("build_ui29"), TextMgr:GetText(TableMgr:GetBuildingData(s[2]).name), s[3])
		            elseif tonumber(s[1]) == 4 then
		                st = st .. System.String.Format(TextMgr:GetText("common_ui15"), TextMgr:GetText(TableMgr:GetBattleData(tonumber(s[2])).nameLabel))
		            end
		        end
		    end
		    transform:Find("Container/bg_frane/bg_mid/num_right"):GetComponent("UILabel").text = st
		    btn_unlock:SetActive(false)
		end
	end
end

function Close()
	maincity.ResetCamera()
end

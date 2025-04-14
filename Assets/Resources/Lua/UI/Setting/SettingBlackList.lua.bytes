module("SettingBlackList", package.seeall)

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


local _UI


local function ClearInfoList()
    for i = 1,#(_UI.InfoList) do
        _UI.InfoList[i]:SetActive(false)
        _UI.InfoList[i].transform.parent = nil
        GameObject.Destroy(_UI.InfoList[i])
    end
    _UI.InfoList = {}
end

local function ShowList()

    ClearInfoList()
	local BlackList = ChatData.GetBlackList()
    for i=1 , #BlackList do
        local v = BlackList[i]
		local obj = NGUITools.AddChild(_UI.Grid.gameObject, _UI.SettingInfo)
        obj.name = v.charid
        obj:SetActive(true)

		local nameLabel = obj.transform:Find("bg_list/bg_title/name_text"):GetComponent("UILabel")
        nameLabel.text = v.charname
	    
		local icon = obj.transform:Find("bg_list/bg_title/bg_touxiang/icon_touxiang"):GetComponent("UITexture")
	    icon.mainTexture = ResourceLibrary:GetIcon("Icon/head/",v.face)
	   
		local fightLabel = obj.transform:Find("bg_list/bg_title/name_zhanli/num_zhanli"):GetComponent("UILabel")
        fightLabel.text = v.pkval

		local checkbox = obj.transform:Find("bg_list/bg_title/checkbox"):GetComponent("UIToggle")
		checkbox.value = false
		
		SetClickCallback(checkbox.gameObject , function(go)
			
		end)
		
		EventDelegate.Set(checkbox.onChange , EventDelegate.Callback(function(go , value)
			UpdateBtnState()
		end))

        table.insert(_UI.InfoList,obj)
    end
    _UI.Grid:Reposition()
    _UI.ScrollView:SetDragAmount(0, 0, false)   

	UpdateBtnState()
end


function Hide()
    Global.CloseUI(_M)
end

function LoadUI()
   
    _UI = {}

	_UI.ScrollView = transform:Find("options/bg_frane/Scroll View"):GetComponent("UIScrollView")
    _UI.Grid = transform:Find("options/bg_frane/Scroll View/Table"):GetComponent("UITable")
    _UI.InfoList = {}
	_UI.SettingInfo = transform:Find("options/ListInfo").gameObject
    _UI.SettingInfo.gameObject:SetActive(false)
	_UI.EmptyList = transform:Find("options/bg_frane/bg_noplayer").gameObject
    _UI.EmptyList.gameObject:SetActive(false)
	
	_UI.outBlackListButton = transform:Find("options/bg_frane/btn"):GetComponent("UIButton")
	
	
	SetClickCallback(transform:Find("options/bg_frane/bg_top/btn_close").gameObject, function()
		Hide()
	end)
	
	SetClickCallback(transform:Find("options/bg_frane/btn").gameObject, BtnOutBlackList)
	
end

function BtnOutBlackList()
	
	local delList = {}
	
	local count =0;
	
	for i=1 , _UI.Grid.transform.childCount , 1 do
		local item = _UI.Grid.transform:GetChild(i-1)
		local checkBox = item:Find("bg_list/bg_title/checkbox"):GetComponent("UIToggle")
		if checkBox.value and checkBox.enabled then
			table.insert(delList, tonumber(_UI.InfoList[i].name))
			count = count +1 
		end
	end
	
	if count ==0 then 
		FloatText.Show(TextMgr:GetText("setting_blacklist_ui6") , Color.red)
		return
	end 
	
	local call_del = function()
	
		for i=1 , #delList do
			if i == count then
				local call = function()
					ChatData.RequestBlackList(function() 
						ShowList();	 
						end)
					end 
				ChatData.RequestOpBlackList(tonumber(delList[i]),false,call,false)
			else 
				ChatData.RequestOpBlackList(tonumber(delList[i]),false,nil,false)
			end 
		end
	
	end 
	
	MessageBox.Show(TextMgr:GetText("setting_blacklist_ui4"), 
				function() 
					call_del()
				end, 
				function() 
				
				end)
end 

function UpdateBtnState()
	
	local count = 0;
	local total = 0

	for i=1 , _UI.Grid.transform.childCount , 1 do
		local item = _UI.Grid.transform:GetChild(i-1)
		local checkBox = item:Find("bg_list/bg_title/checkbox"):GetComponent("UIToggle")
		if checkBox.value and checkBox.enabled then
			count= count +1;
		end
		total = total +1
	end
	if total > 0 then 
		_UI.EmptyList.gameObject:SetActive(false)
		-- _UI.outBlackListButton:GetComponent("BoxCollider").enabled = true
	else 
		_UI.EmptyList.gameObject:SetActive(true)
		-- _UI.outBlackListButton:GetComponent("BoxCollider").enabled = false
	end 
	
end 



function CloseAll()
    Hide()
end


function Awake()
	
end
	
function Close()
    _UI = nil
end


function Show()
    Global.OpenUI(_M)
    LoadUI()
	ShowList();	
	--ChatData.RequestBlackList(function() 
	--	ShowList();	
	--end)
end

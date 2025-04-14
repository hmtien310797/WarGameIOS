module("WallInfo",package.seeall)

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

local soliderItemPrefab
local constructItemPrefab

local container
OnCloseCB = nil

local HideSoldierContent
local ShowSoldierContent
local HideConstructContent
local ShowConstructContent


HideSoldierContent = function()
	container.army.gameObject:SetActive(false)
end

function ReloadSoldierContent()
	ShowSoldierContent()
end

ShowSoldierContent = function()
	HideConstructContent()
	while container.armygrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(container.armygrid.transform:GetChild(0).gameObject);
	end
	
	local allarmy = Barrack.GetArmy()
	--container.armytopinfo.text = allarmy.totalNumber
	local armynum = 0
	for _ , v in pairs(allarmy) do
		if v ~= nil then
			local info = NGUITools.AddChild(container.armygrid.gameObject , soliderItemPrefab.gameObject)
			info.transform:SetParent(container.armygrid.transform , false)
			info.gameObject:SetActive(true)

			local unitData = TableMgr:GetUnitData(v.UnitID)
			local icon = info.transform:Find("bg/icon"):GetComponent("UITexture")
			icon.mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", unitData._unitSoldierIcon)
			local num = info.transform:Find("bg/num"):GetComponent("UILabel")
			num.text = v.Num
			local name = info.transform:Find("name bg/name text"):GetComponent("UILabel")
			name.text = TextUtil.GetUnitName(unitData)
			
			armynum = armynum + v.Num
		end
	end
	container.armygrid:Reposition()
	container.armytopinfo.text = System.String.Format(TextMgr:GetText("wall_army_num") , armynum)
end

HideConstructContent = function()
	
	container.construct.gameObject:SetActive(false)
end

ShowConstructContent = function()
	HideSoldierContent()
	while container.constructgrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(container.constructgrid.transform:GetChild(0).gameObject);
	end
	
	local defendCons = Barrack.GetDefConstruct()
	local consnum = 0
	for _ , v in pairs(defendCons) do
		if v ~= nil then
			local info = NGUITools.AddChild(container.constructgrid.gameObject , soliderItemPrefab.gameObject)
			info.transform:SetParent(container.constructgrid.transform , false)
			info.gameObject:SetActive(true)

			local unitData = TableMgr:GetUnitData(v.UnitID)
			local icon = info.transform:Find("bg/icon"):GetComponent("UITexture")
			icon.mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", unitData._unitSoldierIcon)
			local num = info.transform:Find("bg/num"):GetComponent("UILabel")
			num.text = v.Num
			local name = info.transform:Find("name bg/name text"):GetComponent("UILabel")
			name.text = TextUtil.GetUnitName(unitData)
			
			consnum = consnum + v.Num
		end
	end
	container.constructgrid:Reposition()
	container.constructtopinfo.text = System.String.Format(TextMgr:GetText("wall_facilities_num") , consnum)
	
end


function Awake()
    container = {}
    container.bgmask = transform:Find("mask").gameObject
    container.btn_close = transform:Find("WallInfo widget/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	container.armypage = transform:Find("WallInfo widget/bg_frane/Container/page1"):GetComponent("UIButton")
	container.constructpage = transform:Find("WallInfo widget/bg_frane/Container/page2"):GetComponent("UIButton")
	container.army = transform:Find("WallInfo widget/bg_frane/Container/content 1")
	container.construct = transform:Find("WallInfo widget/bg_frane/Container/content 2")
	
    container.armygrid = transform:Find("WallInfo widget/bg_frane/Container/content 1/bg2/Scroll View/Grid"):GetComponent("UIGrid")
    container.constructgrid = transform:Find("WallInfo widget/bg_frane/Container/content 2/bg2/Scroll View/Grid"):GetComponent("UIGrid")
	
    container.armytopinfo = transform:Find("WallInfo widget/bg_frane/Container/content 1/bg/num"):GetComponent("UILabel")
    container.constructtopinfo = transform:Find("WallInfo widget/bg_frane/Container/content 2/bg/num"):GetComponent("UILabel")
	
	soliderItemPrefab = ResourceLibrary.GetUIPrefab("wall/listitem_soldier")
	--constructItemPrefab = ResourceLibrary.GetUIPrefab("")
	
	
	--GetWareData()
	
	--MoneyListData.AddListener(UpdateContent)
	SetoutData.AddListener(ReloadSoldierContent)
	
end

function Start()
    SetClickCallback(container.bgmask, function()
    	GUIMgr:CloseMenu("WallInfo")
    end)
 
    SetClickCallback(container.btn_close.gameObject, function()
    	GUIMgr:CloseMenu("WallInfo")
    end)
	
	SetClickCallback(container.armypage.gameObject, function()
    	ShowSoldierContent()
    end)
	
	SetClickCallback(container.constructpage.gameObject, function()
    	ShowConstructContent()
    end)
	
	ShowSoldierContent()
	--ShowContent()

end

function Show()
	Barrack.RequestArmNum(function(msg)
		if msg.code == 0 then
			Global.OpenUI(_M)			
		end
    end)    
end

function Hide()
    Global.CloseUI(_M)
end

function Close()
	--MoneyListData.RemoveListener(UpdateContent)
	
	SetoutData.RemoveListener(ReloadSoldierContent)
	if OnCloseCB ~= nil then
    	OnCloseCB()
    	OnCloseCB = nil
    end
	
end

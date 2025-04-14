module("Statistic", package.seeall)

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

function GetEffectDataToBuffValues(Effect)
	local result ={}
	local t = string.split(Effect,';')
	for i = 1,#(t) do
		local tt = string.split(t[i],',')
		result[i] ={}
		result[i].buff_str = TableMgr:GetEquipTextDataByAddition(tt[1],tonumber(tt[2]))
		
		if Global.IsHeroPercentAttrAddition(tonumber(tt[2])) then
			if tonumber(tt[3]) >= 0 then
				result[i].value = " +"..tonumber(tt[3]).."%"
			else
				result[i].value = tonumber(tt[3]).."%"
			end
		else
			if tonumber(tt[3]) >= 0 then
				result[i].value = " +"..tonumber(tt[3])
			else
				result[i].value = tonumber(tt[3])
			end     
			
		end
		
		-- result[i].value = tonumber(tt[3])
		print("GetEffectDataToBuffValues "..tt[1].." "..tt[2].." "..result[i].buff_str.."==> "..TextMgr:GetText(result[i].buff_str).." "..tt[3])
	end
	return result
end


local function ShowList(lv,grade)

    ClearInfoList()

	local count =1
	
	for _, rankData in pairs(TableMgr:GetMilitaryRankTable()) do
		if tonumber(rankData.RankLevel) == tonumber(lv) and tonumber(rankData.RankGrade) ==tonumber(grade) then

			local buff_values = GetEffectDataToBuffValues(rankData.RankEffect)

			if buff_values ~= nil then

				for i =1,#buff_values do
					local str = buff_values[i].value
					
					local item  = ResourceLibrary.GetUIPrefab("PlayerInformation/list_statistic")
					local obj = NGUITools.AddChild(_UI.Grid.gameObject,item)
		
					obj:SetActive(true)
					
					if count % 2 == 0 then 
						obj.transform:Find("bg"):GetComponent("UISprite").enabled = true
					else
						obj.transform:Find("bg"):GetComponent("UISprite").enabled = false
					end 
					
					count = count +1
					-- print("...."..str)
					obj.transform:Find("Label3"):GetComponent("UILabel").text = TextMgr:GetText(buff_values[i].buff_str) 
					obj.transform:Find("num"):GetComponent("UILabel").text = str 
					-- obj.transform:Find("num"):GetComponent("LocalizeEx").enabled = false
					table.insert(_UI.InfoList,obj)

				end
			end
			
		end 
	end 

    _UI.Grid:Reposition()
    _UI.ScrollView:SetDragAmount(0, 0, false)   

end


function Hide()
    Global.CloseUI(_M)
end

function LoadUI()
   
    _UI = {}

	_UI.ScrollView = transform:Find("Container/back/Scroll View"):GetComponent("UIScrollView")
    _UI.Grid = transform:Find("Container/back/Scroll View/Grid"):GetComponent("UIGrid")
    _UI.InfoList = {}
	
	SetClickCallback(transform:Find("mask").gameObject, function()
		Hide()
	end)
	
	SetClickCallback(transform:Find("Container/back/close").gameObject, function()
		Hide()
	end)
end


function CloseAll()
    Hide()
end


function Awake()
	
end
	
function Close()
    _UI = nil
end


function Show(lv,grade)
    Global.OpenUI(_M)
    LoadUI()
	ShowList(lv,grade);	
	--ChatData.RequestBlackList(function() 
	--	ShowList();	
	--end)
end

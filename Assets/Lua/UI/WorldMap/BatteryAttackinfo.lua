module("BatteryAttackinfo", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameObject = UnityEngine.GameObject

local _ui

function Hide()
    Global.CloseUI(_M)
end

local function GetContentText(logmsg , text)
	local text_param = {}
	local need_params = {}
	--配置的参数个数
	for w in string.gmatch(text , "{%d}") do
		need_params[#need_params + 1] = w
	end
	--实际的参数个数
	for _ , vv in ipairs(logmsg.noticeParams) do
		Notice_Tips.DecodeString(text_param , vv , function() end)
		--[[if vv.paramType ~= nil and vv.paramType == "posname" then
			local temp = tonumber(vv.id)
			local y = temp % 10000
			local x = math.floor(temp * 0.0001)
			local tileGid = WorldMap.GetTileGidByMapCoord(x, y)
			local ad = TableMgr:GetArtSettingData(tileGid)
			table.insert(text_param , TextMgr:GetText(ad.name))
		else
			table.insert(text_param , vv.value)
		end]]
		
	end
	--补足参数
	for i=#text_param , #need_params , 1 do
		table.insert(text_param , "xxx")
	end
	
	return GUIMgr:StringFomat(text, text_param)
end

local function LoadUI( logmsg)
	--Global.DumpMessage(logmsg)
	_ui.logIndex = logmsg.pageIndex + 1
	if logmsg.more ~= nil  and logmsg.more then
		_ui.logMaxIndex = _ui.logIndex + 1
	end
	
	local content = _ui.content
	local scrollView = content:GetComponent("UIScrollView")
	local grid = content:Find("Grid"):GetComponent("UIGrid")
	
	for i=1 , #logmsg.turretLog.data , 1 do
		local info = logmsg.turretLog.data[i]
		if info.logId ~= 0 then
			local logBaseData = TableMgr:GetTurretLogByid(info.logId)
		
			local infoItem = NGUITools.AddChild(grid.gameObject, _ui.contentItemPrefab.gameObject).transform
			infoItem:SetParent(grid.transform , false)
			infoItem.name = info.logId
			
			
			local contentText = infoItem:Find("bg/Label"):GetComponent("UILabel")
			contentText.text = Global.SecondToStringFormat(info.time , "HH:mm:ss")..GetContentText(info , TextMgr:GetText(logBaseData.Content))
			
			local armyData ={}
			local armyRoot = infoItem:Find("bg/soldier/Grid"):GetComponent("UIGrid")
			for i=1,#info.hurtDatas,1 do
				local aid = info.hurtDatas[i].armyId
				local alevel = info.hurtDatas[i].armyGrade
				if armyData[aid] == nil then
					armyData[aid] = {}
					armyData[aid].id = aid
				end
				if armyData[aid][alevel] == nil then
					armyData[aid][alevel] = {}
				end
				armyData[aid][alevel] = info.hurtDatas[i].deadNum + info.hurtDatas[i].injuredNum
			end
			local c = 0
			table.foreach(armyData,function(_,v)
				c = c+1
				Embassy.AddArmyItem(v,_ui.armyPrefab,armyRoot.gameObject,c == 1 or c == 5)
			end)
			armyRoot:Reposition()			
		end
	end
	grid:Reposition()
end

local function GetContentTabUI(index)
	if _ui.logMaxIndex <=  index then
		print(_ui.logMaxIndex , index)
		_ui.spController:RestrictBounds()
		return
	end
	GovernmentData.ReqTurretHurtLog(_ui.logIndex, function(msg)
		LoadUI(msg)
		_ui.spController:OnFreshContent()
	end)
end

function  Awake()
    _ui = {}
    _ui.mask = transform:Find("mask")
    _ui.close = transform:Find("Container/bg_frane/bg_top/close")
    SetClickCallback(_ui.close.gameObject,function()
        Hide()
    end)    
    SetClickCallback(_ui.mask.gameObject,function()
        Hide()
    end) 
    _ui.content =  transform:Find("Container/bg_frane/Scroll View")
    _ui.logMaxIndex = 2
    _ui.logIndex = 1
    _ui.spController  =transform:Find("Container/bg_frane/Scroll View"):GetComponent("SpringPanelController") 
    _ui.contentItemPrefab = transform:Find("Container/list_info")
    _ui.armyPrefab = transform:Find("Container/soilder_list").gameObject
    _ui.spController.OnUpdateContent = function() 
        GetContentTabUI(_ui.logIndex)
    end    
end



function Show() 
    GovernmentData.ReqTurretHurtLog(1, function(msg)
		Global.OpenUI(_M)
		
		LoadUI(msg)
		_ui.spController:OnFreshContent()
	end)     
end

function Close()   
    _ui = nil
end

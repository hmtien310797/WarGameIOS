module("UnionLog", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate


local _ui
local unionLogData
local unionIndex
local currentTab

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	--[[print(go.name)
	local posUrl = go.transform:Find("bg_list/text_desc"):GetComponent("UILabel")
    local url = posUrl:GetUrlAtPosition(UICamera.lastWorldPosition)
	print(url)]]
end

function RequestLog(logtype , index , callback)
	--print("req:" .. logtype , index)
	local req = GuildMsg_pb.MsgGuildOperLogInfoRequest()
	req.operType = logtype
	req.index = index
    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildOperLogInfoRequest, req, GuildMsg_pb.MsgGuildOperLogInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
			Global.DumpMessage(msg , "d:/unionlog.lua")
            if callback ~= nil then
                callback(msg)
            end
        end
    end, false)
end

function GetContentText(logmsg , text)
	local text_param = {}
	local need_params = {}
	--配置的参数个数
	for w in string.gmatch(text , "{%d}") do
		need_params[#need_params + 1] = w
	end
	--实际的参数个数
	for _ , vv in ipairs(logmsg.paras) do
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

local function LoadUI(logType , logmsg)
	_ui.unionIndex[logType] = logmsg.curIndex + 1
	if logmsg.maxIndex ~= nil then
		_ui.unionMaxIndex[logType] = logmsg.maxIndex
	end
	
	local content = _ui.content[logType]
	local scrollView = content:GetComponent("UIScrollView")
	local grid = content:Find("Grid"):GetComponent("UIGrid")
	
	for i=1 , #logmsg.logInfo , 1 do
		local info = logmsg.logInfo[i]
		local logBaseData = TableMgr:GetUnionLogData(info.operLogId)
		
		local infoItem = NGUITools.AddChild(grid.gameObject, _ui.contentItemPrefab.gameObject).transform
		infoItem:SetParent(grid.transform , false)
		infoItem.name = info.operLogId
		
		local bgSpr = infoItem:Find("bg_list/background"):GetComponent("UISprite")
		bgSpr.spriteName = logBaseData.logBg
		
		local contentText = infoItem:Find("bg_list/text_desc"):GetComponent("UILabel")
		contentText.text = GetContentText(info , TextMgr:GetText(logBaseData.logContent))
		
		local timeText = infoItem:Find("bg_list/text_time"):GetComponent("UILabel")
		local pass1 = Global.Datediff(Serclimax.GameTime.GetSecTime() , info.operTime)
		if pass1 > 0 then
			if pass1 >= 7 then
				timeText.text = System.String.Format(TextMgr:GetText("chat_hint9") , pass1)
			else
				timeText.text = System.String.Format(TextMgr:GetText("chat_hint8") , pass1)
			end
		else
			timeText.text = Serclimax.GameTime.SecondToStringHHMM(info.operTime)
		end
		
		
		SetClickCallback(infoItem.gameObject , function()
			local posUrl = infoItem:Find("bg_list/text_desc"):GetComponent("UILabel")
			local url = posUrl:GetUrlAtPosition(UICamera.lastWorldPosition)
			if url == nil then
				return
			end
			--url = "jumppos,3"
			--[93CCE6FF]6qayuyang006[-]占领了空地([url=jumppos,1][u]x:61 y:110[/u][/url])
			--领地[93CCE6FF]空地([url=jumppos,1][u]x:60 y:92[/u][/url])[-]被[FF0000FF][001]5qayuyang005[-]占领
			print(url)
			local str = string.split(url , ",")
			if str[1] == "jumppos" then
				local param = info.paras[tonumber(str[2]) + 1].value
				local posstr = string.split(param , " ")
				local posstrx = tonumber(string.split(posstr[1] , ":")[2])
				local posstry = tonumber(string.split(posstr[2] , ":")[2])
				print(posstrx , posstry)
				Hide()
				if GUIMgr:FindMenu("UnionInfo") ~= nil then
					UnionInfo.Hide()
				end
				MainCityUI.ShowWorldMap(posstrx, posstry, true)
			end
		end)
	end
	grid:Reposition()
end

local function ShowTabUI(logtype , index)
	if _ui.unionIndex[logtype] == 1 then
		RequestLog(logtype , 1 , function(msg)
			LoadUI(logtype , msg)
			print(_ui.spController[logtype] , logtype )
			_ui.spController[logtype]:OnFreshContent()
		end)
	end
	
end

local function EnterTabUI(logtype)
	_ui.tab[logtype]:GetComponent("UIToggle"):Set(true)
	RequestLog(logtype , 1 , function(msg)
		LoadUI(logtype , msg)
		print(_ui.spController[logtype] , logtype )
		_ui.spController[logtype]:OnFreshContent()
	end)
end

local function GetContentTabUI(logtype , index)
	if _ui.unionMaxIndex[logtype] <=  index then
		print(_ui.unionMaxIndex[logtype] , index)
		_ui.spController[logtype]:RestrictBounds()
		return
	end
	RequestLog(logtype , _ui.unionIndex[logtype], function(msg)
		LoadUI(logtype , msg)
		_ui.spController[logtype]:OnFreshContent()
	end)
end


function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function Awake()
	currentTab = nil
   _ui = {}
   _ui.content = 
   {
		[GuildMsg_pb.GuildOperLogTypeAll] = transform:Find("Container/Scroll View (1)"),
		[GuildMsg_pb.GuildOperLogTypeFight] = transform:Find("Container/Scroll View (2)"),
		[GuildMsg_pb.GuildOperLogTypeOccupy] = transform:Find("Container/Scroll View (3)"),
		[GuildMsg_pb.GuildOperLogTypeInterior] = transform:Find("Container/Scroll View (4)"),
   }
 
   _ui.tab = 
   {
		[GuildMsg_pb.GuildOperLogTypeAll] = transform:Find("Container/bg_left/btn_itemtype_5"),
		[GuildMsg_pb.GuildOperLogTypeFight] = transform:Find("Container/bg_left/btn_itemtype_4"),
		[GuildMsg_pb.GuildOperLogTypeOccupy] = transform:Find("Container/bg_left/btn_itemtype_6"),
		[GuildMsg_pb.GuildOperLogTypeInterior] = transform:Find("Container/bg_left/btn_itemtype_7"),
   }
   
   _ui.unionIndex = 
   {
		[GuildMsg_pb.GuildOperLogTypeAll] = 1 , 
		[GuildMsg_pb.GuildOperLogTypeFight] = 1 , 
		[GuildMsg_pb.GuildOperLogTypeOccupy] = 1 , 
		[GuildMsg_pb.GuildOperLogTypeInterior] = 1 , 
   }
   _ui.unionMaxIndex = 
   {
		[GuildMsg_pb.GuildOperLogTypeAll] = 1 , 
		[GuildMsg_pb.GuildOperLogTypeFight] = 1 , 
		[GuildMsg_pb.GuildOperLogTypeOccupy] = 1 , 
		[GuildMsg_pb.GuildOperLogTypeInterior] = 1 , 
   }
   
   _ui.spController  =
   {
		[GuildMsg_pb.GuildOperLogTypeAll] = transform:Find("Container/Scroll View (1)"):GetComponent("SpringPanelController") , 
		[GuildMsg_pb.GuildOperLogTypeFight] = transform:Find("Container/Scroll View (2)"):GetComponent("SpringPanelController") , 
		[GuildMsg_pb.GuildOperLogTypeOccupy] = transform:Find("Container/Scroll View (3)"):GetComponent("SpringPanelController") , 
		[GuildMsg_pb.GuildOperLogTypeInterior] = transform:Find("Container/Scroll View (4)"):GetComponent("SpringPanelController") , 
   }
  
   _ui.contentItemPrefab = ResourceLibrary.GetUIPrefab("Union/UnionLog_descinfo")
   
   for i=GuildMsg_pb.GuildOperLogTypeAll , GuildMsg_pb.GuildOperLogTypeInterior ,1 do
		--set click
		SetClickCallback(_ui.tab[i].gameObject , function()
			ShowTabUI(i , _ui.unionIndex[i])
		end)	
		
		--set spController delegate
		_ui.spController[i].OnUpdateContent = function() 
			GetContentTabUI(i , _ui.unionIndex[i])
		end
    end
	
	
	_ui.closeBtn = transform:Find("Container/close btn"):GetComponent("UIButton")
	SetClickCallback(_ui.closeBtn.gameObject , Hide)
	_ui.bg = transform:Find("mask")
	SetClickCallback(_ui.bg.gameObject , Hide)
	
	--AddDelegate(UICamera, "onPress", OnUICameraPress)
end

function Close()
    _ui = nil
	currentTab = nil
	--RemoveDelegate(UICamera, "onPress", OnUICameraPress)
end

function Show(logType)
	--[[RequestLog(GuildMsg_pb.GuildOperLogTypeAll ,1 , function(msg)
		--unionLogData = msg
		Global.OpenUI(_M)
		LoadUI(GuildMsg_pb.GuildOperLogTypeAll , msg)
	end)]]
	Global.OpenUI(_M)
	local logUIType = logType and logType or GuildMsg_pb.GuildOperLogTypeAll
	local logUnionIndex = _ui.unionIndex[logType] and _ui.unionIndex[logType] or _ui.unionIndex[GuildMsg_pb.GuildOperLogTypeAll]
	EnterTabUI(logUIType ,logUnionIndex )
	
end

module("GroupSelectList", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback
local GameObject = UnityEngine.GameObject
local AddDelegate = UIUtil.AddDelegate

local _container

local _data
local currentPage
local initList
local confirmList
local confirmCallback


local Page = 
{
	Page_Union = 1 ,
	Page_Private = 2,
}
local function CloseSelf()
	Global.CloseUI(_M)
	_container = nil
	_data = nil
end

local function MakeSelectData(guildMem)
	_data = {}
	if guildMem ~= nil and #guildMem > 0 then
		_data[Page.Page_Union] = {}
		for i=1 , #guildMem , 1 do
			local mem = {}
			mem.face = guildMem[i].face
			mem.name =	guildMem[i].name
			mem.level =	guildMem[i].level
			mem.viplevel =	guildMem[i].vipLevel
			mem.position =	guildMem[i].position
			mem.charId =	guildMem[i].charId
			table.insert(_data[Page.Page_Union] , mem)
		end
	end
	
	local sortTable = ChatData.GetPrivateNew()
	_data[Page.Page_Private] = {}
	if sortTable ~= nil and #sortTable > 0 then 
		
		for i=1 , #(sortTable) , 1 do
			local k = sortTable[i].name
			local v = ChatData.GetPrivateChat(k)
			
			local strPri = string.split(k , ",")
			local priName = strPri[1]
			local priCharId = tonumber(strPri[2])
			local lastchat = v[#(v)]
			local priPlayer = nil
			if lastchat.sender.charid ~= priCharId then
				priPlayer = {}
				priPlayer.sender = v[#(v)].recvlist[1]
			else
				priPlayer = v[#(v)]
			end
			
			local mem = {}
			mem.face = priPlayer.sender.face
			mem.name =	priPlayer.sender.name
			mem.guildBanner = priPlayer.sender.guildBanner
			mem.level =	priPlayer.sender.level
			mem.viplevel =	priPlayer.sender.viplevel
			mem.charId =	priCharId
			table.insert(_data[Page.Page_Private] , mem)
		end
	end
	
	local sortedCfg = Global.GFileRecorder:GetSortedConfigData()
	for i=1 , #sortedCfg , 1 do
		local v = sortedCfg[i]
		
		local mem = {}
		mem.face = v.face
		mem.name =	v.name
		mem.guildBanner = v.guildBanner
		mem.level =	v.level
		mem.viplevel =	v.viplevel
		mem.charId =	v.charid
		
		local exist = false
		for i=1 , #_data[Page.Page_Private] do
			if _data[Page.Page_Private][i].charId == v.charid then
				exist = true
				break
			end
		end
		
		if not exist then
			table.insert(_data[Page.Page_Private] , mem)
		end
		
	end
	
end

local function ConfirmAdd()
	local addlist = {}
	print(confirmList)
	for _ , v in pairs(confirmList) do
		if v ~= nil then
			print("select list :"  , v.charId)
			table.insert(addlist, v)
		end
	end
	
	--[[for i=1 , _container.Grid.transform.childCount , 1 do
		local item = _container.Grid.transform:GetChild(i-1)
		local checkBox = item:Find("bg/checkbox"):GetComponent("UIToggle")
		if checkBox.value and checkBox.enabled then
			table.insert(addlist, _data[currentPage][i])
		end
	end]]
	
	if confirmCallback ~= nil then
		if not confirmCallback(addlist) then
			return
		end
	end
	
	CloseSelf()
end


local function LoadUI(page)
print("loadui " , page , _data ,_data[page])
	if not _data or not _data[page] then
		return
	end

	while _container.Grid.transform.childCount > 0 do
		GameObject.DestroyImmediate(_container.Grid.transform:GetChild(0).gameObject)
	end
	for i=1 , #_data[page] , 1 do
		local v = _data[page][i]
		local listitem = NGUITools.AddChild(_container.Grid.gameObject , _container.item).transform
		local itemIcon = listitem:Find("bg/bg_touxiang/icon_touxiang"):GetComponent("UITexture")
		itemIcon.mainTexture = ResourceLibrary:GetIcon("Icon/head/", v.face)
		
		local itemName = listitem:Find("bg/bg_title/name"):GetComponent("UILabel")
		local exStr = ""
		if v.guildBanner ~= nil and v.guildBanner ~= "" then
			exStr = "[f1cf63]【".. v.guildBanner .. "】[-]"
		end
		itemName.text = exStr.. v.name
		
		if v.level ~= nil then
			--local itemName = listitem:Find("bg/bg_title/name"):GetComponent("UILabel")
			--itemName.text = v.level
		end
		
		if v.viplevel ~= nil then
			local bgIcon = listitem:Find("bg/bg_touxiang"):GetComponent("UISprite")
			bgIcon.spriteName = string.format("bg_avatar_vip%s" , math.ceil(v.viplevel/5))
				
			local itemVip = listitem:Find("bg/bg_touxiang/bg_vip")
			itemVip.gameObject:SetActive(v.viplevel > 0)
			itemVip:Find("icon"):GetComponent("UISprite").spriteName = string.format("bg_avatar_num_vip%s" , math.ceil(v.viplevel/5))
			itemVip:Find("num"):GetComponent("UILabel").text = string.format("VIP%s" , v.viplevel)
		end
		
		--itemPos.text = ""
		listitem:Find("bg/bg_title/union_level").gameObject:SetActive(v.position ~= nil)
		if v.position ~= nil then
			local itemPos = listitem:Find("bg/bg_title/union_level"):GetComponent("UILabel")
			if v.position == 5 then
				itemPos.text = TextMgr:GetText("ui_leader_icon")--"盟主"
			else
				itemPos.text = TextMgr:GetText("union_member_level"..v.position)--string.format("%s阶级" , v.position)
			end
		end
		
		local tog = listitem:Find("bg/checkbox"):GetComponent("UIToggle")
		
		EventDelegate.Set(tog.onChange,EventDelegate.Callback(function(obj,delta)
			if tog.value then
				confirmList[v.charId] = v
			else
				confirmList[v.charId] = nil
			end
		end))
		
		if initList then
			for _ , k in pairs(initList) do
				if v.charId == k then
					tog:Set(true)
					tog.enabled = false
					break
				end
			end
		end
		
		
		
	end
	_container.Grid:Reposition()
	_container.ScrollView:ResetPosition()
end


local function SelectTab(page)
	if currentPage ~= page then
		currentPage = page
		LoadUI(currentPage)
	end
end


function Awake()
	_container = {}
	_container.container = transform:Find("Container").gameObject
	_container.btn_close = transform:Find("Container/bg_frane/btn_close").gameObject
	
	_container.tabUnion = transform:Find("Container/bg_frane/bg_top/tab1").gameObject
	_container.tabPrivate = transform:Find("Container/bg_frane/bg_top/tab2").gameObject
	
	_container.ScrollView = transform:Find("Container/bg_frane/bg_mid/Scroll View"):GetComponent("UIScrollView")
	_container.Grid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")

	_container.btn = transform:Find("Container/bg_frane/bg_bottom/btn").gameObject
	_container.item = transform:Find("grouplist_info").gameObject
end


function Start()
	currentPage = Page.Page_Union
	confirmList = {}
	
	SetClickCallback(_container.container, CloseSelf)
	SetClickCallback(_container.btn_close, CloseSelf)

	SetClickCallback(_container.tabUnion, function()
		SelectTab(Page.Page_Union)
	end)
	SetClickCallback(_container.tabPrivate, function() 
		SelectTab(Page.Page_Private)
	end)
	SetClickCallback(_container.btn, function() 
		ConfirmAdd()
	end)
end

function Show(initlist , callback)
	
	--[[_data = data	
    Global.OpenUI(_M)
    LoadUI()]]
	Global.OpenUI(_M)
	
	
	local req = GuildMsg_pb.MsgGuildMemberListRequest()
    req.guildId = UnionInfoData.GetData().guildInfo.guildId

    Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildMemberListRequest, req, GuildMsg_pb.MsgGuildMemberListResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            
			MakeSelectData(msg.members)
			initList = initlist
			confirmCallback = callback
			
            LoadUI(currentPage)
        else
            Global.ShowError(msg.code)
        end
    end, false)
end

function Close()
	_data = nil
	initList = nil
	confirmList = nil
	confirmCallback = nil
	_container = nil
end
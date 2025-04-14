module("SettingNotice", package.seeall)

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
local _ui = nil

local function ClickCheckNode(node)
	--local checkBox = node.checkBox
	local childCount = node.itemOpenTable.transform.childCount
	
	for i=0 ,childCount-1, 1 do
		local child = node.itemOpenTable.transform:GetChild(i)
		child:Find("checkbox"):GetComponent("UIToggle").value = node.checkBox.value
	end
end

local function CheckNodeToggle(rootId)
	local nodeRoot = _ui.typeNodes[rootId]
	if nodeRoot ~= nil then
		local toggleValue = false
		local childcount = nodeRoot.itemOpenTable.transform.childCount
		for i=0 , childcount - 1 , 1 do
			local child = nodeRoot.itemOpenTable.transform:GetChild(i)
			if child:Find("checkbox"):GetComponent("UIToggle").value then
				toggleValue = true
			end
		end
		
		nodeRoot.checkBox.value = toggleValue
	end
end

local function LoadType()
	local node = {}
	local itemInfo = NGUITools.AddChild(_ui.table.gameObject, _ui.itemInfo.gameObject).transform
	node.title = itemInfo:Find("bg_list/bg_title/name_text"):GetComponent("UILabel")
	node.desc = itemInfo:Find("bg_list/bg_title/name_text/des"):GetComponent("UILabel")
	node.checkBox = itemInfo:Find("bg_list/bg_title/checkbox"):GetComponent("UIToggle")
	node.trf = itemInfo
	node.id = 0
	node.itemOpen = itemInfo:Find("ItemInfo_open")
	node.btnOpen = itemInfo:Find("bg_list/btn_open")
	node.itemOpenTable = itemInfo:Find("ItemInfo_open/bg_soldier/Table"):GetComponent("UITable")
	node.cotroller = itemInfo:GetComponent("ParadeTableItemController")
	node.bgHeight = itemInfo:Find("bg_list"):GetComponent("UIWidget").height
	node.bg = itemInfo:Find("bg_list"):GetComponent("UIWidget")
	return node
end

local function FillLoadType(node,typeNotice,subCount)
	node.trf.name = typeNotice.id .. "_" ..typeNotice.nType
	node.id = typeNotice.id
	node.title.text = TextMgr:GetText(typeNotice.title)
	node.desc.text = typeNotice.description == "" and typeNotice.description or TextMgr:GetText(typeNotice.description)
	node.checkBox.value = NotifySettingData.GetConfig(typeNotice.id) ~= nil and true or false 
	node.itemOpenTable.repositionNow = true
	node.btnOpen.gameObject:SetActive(subCount>1)
	SetClickCallback(node.checkBox.gameObject , function(go)
		ClickCheckNode(node)
	end)
end

local function LoadSubType(rootId)
	local nodeRoot = _ui.typeNodes[rootId]
	if nodeRoot ~= nil then
		local rootTable = nodeRoot
		local node = {}
		local checkInfo = NGUITools.AddChild(nodeRoot.itemOpenTable.gameObject, _ui.checkItem.gameObject).transform
		node.desc = checkInfo:Find("checkDes"):GetComponent("UILabel")
		node.checkBox = checkInfo:Find("checkbox"):GetComponent("UIToggle")
		node.trf = checkInfo
		node.height = checkInfo:GetComponent("UIWidget").height
		node.id = 0
		node.rootId = rootId

		SetClickCallback(node.checkBox.gameObject , function(go)
			CheckNodeToggle(rootId)
		end)
		
		return node
	end
	return nil
end

local function FillLoadSubType(node,typeNotice)
	node.trf.name = typeNotice.id .. "_" ..typeNotice.nType
	node.id = typeNotice.id
	node.desc.text = TextMgr:GetText(typeNotice.title)
	node.checkBox.value = NotifySettingData.GetConfig(typeNotice.id) ~= nil and true or false 
	local root = _ui.typeNodes[node.rootId]
	if root ~= nil and node.checkBox.value then
		root.checkBox.value = node.checkBox.value
	end
end

local function LoadUI()
	_ui.typeNodes = {}
	_ui.nodes = {}
	local notice = TableMgr:GetSettingNoticeData()
	for i , v in pairs(notice) do
		local bgHeight = 0
		for k=1 , #v , 1 do
			local typenode = nil
			if v[k].show then
				if v[k].subtype == 0 then --
					typenode = LoadType()
					FillLoadType(typenode , v[k] , #v)
					_ui.typeNodes[i] = typenode
					bgHeight = bgHeight + typenode.bgHeight
				else
					typenode = LoadSubType(i)
					if typenode ~= nil then
						FillLoadSubType(typenode , v[k])
						bgHeight = bgHeight + typenode.height
						table.insert(_ui.nodes ,typenode )
					end
					
				end
			end
		end
		
		if _ui.typeNodes[i] ~= nil then
			_ui.typeNodes[i].cotroller:SetItemOpenHeight(bgHeight)
		end
	end
	--_ui.table.repositionNow = true
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function SaveSettingAndClose()
	local saveList = {}
	for _ , v in pairs(_ui.nodes) do
		if v.checkBox.value then
			table.insert(saveList , v.id)
		end
	end
	NotifySettingData.SetConfig(saveList  , Hide)
end

function Close()
	_ui = nil
end

function Awake()
	_ui = {}
	_ui.scrollView = transform:Find("options/bg_frane/Scroll View"):GetComponent("UIScrollView")
	_ui.table = transform:Find("options/bg_frane/Scroll View/Table"):GetComponent("UITable")
	_ui.itemInfo = transform:Find("options/ItemInfo")
	_ui.checkItem = transform:Find("options/checklist")
	_ui.closeBtn = transform:Find("options/bg_frane/bg_top/btn_close")
	_ui.bg = transform:Find("options")
	SetClickCallback(_ui.closeBtn.gameObject, function()
		SaveSettingAndClose()
	end)
	SetClickCallback(_ui.bg.gameObject, function()
		SaveSettingAndClose()
	end)
end


function Show()
    --heroUid = uid
    Global.OpenUI(_M)
    LoadUI()
end

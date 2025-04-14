module("UnionRadarHis", package.seeall)
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

local _ui
local LoadUI
local unionMonsterHisMsg
local unionSortHisList

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local function SortList()
	unionSortHisList = {}
	for i=1 , #(unionMonsterHisMsg.history) , 1 do
		local his = unionMonsterHisMsg.history[i]
		table.insert(unionSortHisList , his)
	end
	
	--sort
	table.sort(unionSortHisList, function(t1, t2)
		if t1.pvpHurt == t2.pvpHurt then
			return t1.pveHurt > t2.pveHurt
		else
			return t1.pvpHurt > t2.pvpHurt
		end
	end)
	
end

function Awake()
	_ui = {}
	local closeBtn = transform:Find("Container/bg_frane/bg_title/btn_close"):GetComponent("UIButton")
	SetClickCallback(closeBtn.gameObject, Hide)
	
	SetClickCallback(transform:Find("Container").gameObject , Hide)
	
	_ui.radarHisInfo = transform:Find("listitem")
	_ui.scrollview = transform:Find("Container/bg_frane/bg_mid/Scroll View"):GetComponent("UIScrollView")
	--_ui.grid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	
end


local function LoadItem(info , msg)
	
end

function UpdateHisrotyItem(item , index , realInde)
	local dataIndex = math.abs(realInde) + 1
	
	--if dataIndex > #unionMonsterHisMsg.history then
	if dataIndex > #unionSortHisList then
		return
	end
	
	local v = unionSortHisList[dataIndex]
	item.transform:Find("bg").gameObject:SetActive(realInde % 2 == 0)
	item.transform:Find("bg_select").gameObject:SetActive(v.charname == MainData.GetCharName)
	
	local name = item.transform:Find("name"):GetComponent("UILabel")
	name.text = v.charname
	
	local num = item.transform:Find("num"):GetComponent("UILabel")
	num.text = v.pveHurt
	
	local num = item.transform:Find("time"):GetComponent("UILabel")
	num.text = v.pvpHurt
end

LoadUI = function()
	if unionMonsterHisMsg == nil then
		return
	end
	SortList()
	local datalength = #unionSortHisList--#unionMonsterHisMsg.history
	print(datalength)

	local optGridTransform = _ui.scrollview.transform:Find("OptGrid")
	if optGridTransform ~= nil then
		GameObject.DestroyImmediate(optGridTransform.gameObject)
	end
		
	local wrapParam = {}
	wrapParam.OnInitFunc = UpdateHisrotyItem
	wrapParam.itemSize = 45
	wrapParam.minIndex = -(datalength-1)
	wrapParam.maxIndex = 0
	wrapParam.itemCount = datalength < 10 and datalength or 10-- 预设项数量。 -1为实际显示项数量
	wrapParam.cellPrefab = _ui.radarHisInfo
	wrapParam.localPos = Vector3(0,45 , 0)
	wrapParam.cullContent = false
	wrapParam.moveDir = 1--horizal
	UIUtil.CreateWrapContent(_ui.scrollview , wrapParam , function(optGridTrf)
		--[[while _ui.giftGrid.transform.childCount > 0 do
			GameObject.DestroyImmediate(_ui.giftGrid.transform:GetChild(0).gameObject)
		end]]
		_ui.grid = optGridTrf
	end)
	_ui.scrollview:ResetPosition()
end

function Show()
	Global.OpenUI(_M)
	local req = BattleMsg_pb.MsgBattleGuildMonsterHistoryRequest()
    Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgBattleGuildMonsterHistoryRequest, req, BattleMsg_pb.MsgBattleGuildMonsterHistoryResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			unionMonsterHisMsg = msg
			LoadUI()
		end
	end)
end

function Close()
	_ui = nil
	unionSortHisList = nil
end

module("SupplyCollectRanking", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local Format = System.String.Format

local _ui

local UpdateUI = nil

function CloseSelf()
    _ui = nil
	Global.CloseUI(_M)
end

function Close()
	SupplyCollect.rankeventListener:RemoveListener(UpdateUI)
end

function Awake()
	_ui.container = transform:Find("Container").gameObject
	_ui.btn_close = transform:Find("Container/close btn").gameObject
	_ui.rank_scroll = transform:Find("Container/content_rank/Scroll View"):GetComponent("UIScrollView")
	_ui.rank_grid = transform:Find("Container/content_rank/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.rank_item = transform:Find("Container/content_rank/Scroll View/Grid/listitem_supplyrank")
	_ui.rank_my = transform:Find("Container/content_rank/Myrank/myranklist")	
	SupplyCollect.rankeventListener:AddListener(UpdateUI)
end

function Start()
	SetClickCallback(_ui.container, CloseSelf)
    SetClickCallback(_ui.btn_close, CloseSelf)
	SupplyCollect.RequestSupplyCollectRankList()
	UpdateUI()
end

UpdateUI = function()
	SupplyCollect.UpdateRank(_ui)
end


function Show()
	_ui = {}
	Global.OpenUI(_M)
end

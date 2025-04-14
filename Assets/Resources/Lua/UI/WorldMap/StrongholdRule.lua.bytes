module("StrongholdRule", package.seeall)

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
local mode

function Hide()
    Global.CloseUI(_M)
end

LoadUI = function()

	if mode == Common_pb.SceneEntryType_Fortress then
		_ui.fortressSC.gameObject:SetActive(true)
		_ui.strongholdSC.gameObject:SetActive(false)
		_ui.fortressSCTable.repositionNow = true
	elseif mode == Common_pb.SceneEntryType_Stronghold then
		_ui.fortressSC.gameObject:SetActive(false)
		_ui.strongholdSC.gameObject:SetActive(true)
		_ui.strongholdSCTable.repositionNow = true
	end
	
    SetClickCallback(_ui.close.gameObject,function()
        Hide()
    end)    
    SetClickCallback(_ui.mask.gameObject,function()
        Hide()
    end)

	
	coroutine.start(function()
		coroutine.step()
		if _ui ~= nil then
			_ui.strongholdSCTable:Reposition()
			_ui.fortressSCTable:Reposition()
		end
	end)
end

function  Awake()
    _ui = {}
    _ui.mask = transform:Find("mask")
    _ui.close = transform:Find("bg_frane/bg_top/btn_close")
	_ui.fortressSC = transform:Find("bg_frane/bg_mid/Fortress Scroll View"):GetComponent("UIScrollView")
	_ui.fortressSCTable = transform:Find("bg_frane/bg_mid/Fortress Scroll View/Table"):GetComponent("UITable")
	_ui.strongholdSC = transform:Find("bg_frane/bg_mid/Stronghold Scroll View"):GetComponent("UIScrollView")
	_ui.strongholdSCTable = transform:Find("bg_frane/bg_mid/Stronghold Scroll View/Table"):GetComponent("UITable")
	
	LoadUI()
end

function Show(_mode)
    mode = _mode    
    Global.OpenUI(_M)
	
end

function Close()   
    _ui = nil
end
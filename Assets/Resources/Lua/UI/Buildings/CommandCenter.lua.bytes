module("CommandCenter",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local title
local btn_close
local grid
local info_item

function Awake()
    title = transform:Find("Container/bg_frane/bg_top/bg_title_left/title"):GetComponent("UILabel")
    btn_close = transform:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
    grid = transform:Find("Container/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
    info_item = {}
    info_item.go = ResourceLibrary.GetUIPrefab("CommandCenter/CommandCenterinfo")
    info_item.title = "bg_frane/bg_title/title"
    info_item.num = "bg_frane/bg_title/num"
    for i = 1, 4 do
        info_item.bg[i] = {}
        info_item.bg[i].bg = string.format("bg_frane/bg (%d)", i)
        info_item.bg[i].icon = string.format("bg_frane/bg (%d)/icon", i)
        info_item.bg[i].text = string.format("bg_frane/bg (%d)/text", i)
        info_item.bg[i].num = string.format("bg_frane/bg (%d)/num", i)
    end
    
end

function Start()
    local infogo = NGUITools.AddChild(grid.gameObject, info_item.go)
end

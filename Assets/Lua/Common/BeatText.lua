module("BeatText", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local ClampWidgetPosition = UIUtil.ClampWidgetPosition
local GameTime = Serclimax.GameTime

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local Object = UnityEngine.Object
local uiTopRoot = GUIMgr.UITopRoot

local BeatTextPrefab
local lastShowTime = 0
local showDelay = 0


function ShowAt(position, text, color,effect)
    if BeatTextPrefab == nil then
        BeatTextPrefab = ResourceLibrary.GetUIPrefab("Login/BeatText")
    end
    local BeatTextGameObject = GameObject.Instantiate(BeatTextPrefab)
    local transform = BeatTextGameObject.transform 
    local BeatTextLabel = transform:Find("text"):GetComponent("UILabel")
    BeatTextLabel.text = text
    BeatTextLabel.gradientTop = color or Color.white
    BeatTextLabel.gradientBottom = color or Color.white

    transform:SetParent(uiTopRoot, false)
    if position ~= nil then
        transform.position = position
    end
end

function ShowNormal(pos,text, color)
    ShowAt(pos, text, color,1)
end

function ShowBeat(pos,text, color)
    ShowAt(pos, text, color,2)
end



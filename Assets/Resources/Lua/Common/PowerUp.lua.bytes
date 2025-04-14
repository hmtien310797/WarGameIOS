module("PowerUp", package.seeall)
local GUIMgr = Global.GGUIMgr
local ResourceLibrary = Global.GResourceLibrary
local UIAnimMgr = Global.GUIAnimMgr

local GameObject = UnityEngine.GameObject
local uiTopRoot = GUIMgr.UITopRoot

local floatTextPrefab
local floatTextGameObject
local sfxGameObject

local function Hide()
	Close()
end

function ShowAt(position, fromtext,totext, color)
    if floatTextPrefab == nil then
		floatTextPrefab = ResourceLibrary.GetUIPrefab("BuildingCommon/PowerUp")
    end
	
	if floatTextGameObject ~= nil then
		UITweener.ResetAllToBegining(floatTextGameObject , false)
		floatTextGameObject:SetActive(true)
	else
		floatTextGameObject = GameObject.Instantiate(floatTextPrefab)
		floatTextGameObject.transform:SetParent(uiTopRoot, false)
	end
	
    local floatTextLabel = floatTextGameObject.transform:Find("Container/text_miaosu"):GetComponent("UILabel")
	local labelAnim = floatTextGameObject.transform:Find("Container/text_miaosu"):GetComponent("UILabelAnimController")	
	
    floatTextLabel.text = fromtext
    floatTextLabel.color = color or Color.red
	UIAnimMgr:IncreaseUILabelTextAnim(floatTextLabel , fromtext , totext)

    if position ~= nil then
        floatTextGameObject.transform.position = position
    end
    
	
	local tweenPosition = floatTextGameObject.transform:Find("Container"):GetComponent("TweenPosition")
	UITweener.PlayAllTweener(tweenPosition.gameObject , true , true , false)
    tweenPosition:SetOnFinished(EventDelegate.Callback(function()
		Hide()
    end))
end

function Show(fromtext , totext, color)
    ShowAt(nil, fromtext, totext, color)
end

function ShowOn(gameObject, fromtext, totext, color)
    ShowAt(gameObject.transform.position, text, color)
end

function Close()
	floatTextPrefab = nil
	floatTextGameObject:SetActive(false)
	sfxGameObject = nil
end
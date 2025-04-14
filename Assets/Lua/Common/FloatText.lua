module("FloatText", package.seeall)
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

local floatTextPrefab
local lastShowTime = 0
local showDelay = 0

local maxSize = 10
local setSize = 0
local floatSet = {}
local floatRoot

function GetEnabledFloatText()
	--local childCount = floatRoot.childCount
	for i=1 , #floatSet ,1 do
		local obj = floatSet[i]
		local childTween = obj.transform:Find("text"):GetComponent("UITweener")
		if childTween.tweenFactor - 1 < 0.01 and not obj.gameObject.activeSelf then
			return floatSet[i]
		end
	end
	
	return nil
end

function ShowAt(position, text, color, icon)
	--[[if floatRoot == nil then
		floatRoot = uiTopRoot:Find("FloatTextRoot")
	end
	
	local floatTextGameObject
	if #floatSet < maxSize then
		if floatTextPrefab == nil then
			floatTextPrefab = ResourceLibrary.GetUIPrefab("Login/FloatText")
		end
		floatTextGameObject = GameObject.Instantiate(floatTextPrefab)
		floatTextGameObject.transform:SetParent(floatRoot , false)
		floatSet[#floatSet + 1] = floatTextGameObject
		--setSize = setSize + 1
	else
		floatTextGameObject = GetEnabledFloatText()
	end

	if floatTextGameObject ~= nil then
		floatTextGameObject.gameObject:SetActive(true)
		local transform = floatTextGameObject.transform 
		local showIcon = transform:Find("text/icon"):GetComponent("UITexture")
		local floatTextLabel = transform:Find("text"):GetComponent("UILabel")
		floatTextLabel.text = text
		floatTextLabel.color = color or Color.red
		if icon ~= nil then
			showIcon.mainTexture = icon
			showIcon.gameObject:SetActive(true)
		else
			showIcon.gameObject:SetActive(false)
		end

		if position ~= nil then
			transform.position = position
		else
			transform.localPosition = UnityEngine.Vector3.zero
		end
		
		local textObj = transform:Find("text")
		UITweener.PlayAllTweener(textObj.gameObject , true , true , false)
		
		local tween = textObj:GetComponent("UITweener")
		tween:SetOnFinished(EventDelegate.Callback(function()
			floatTextGameObject.gameObject:SetActive(false)
		end))
	end]]
	
	
    if floatTextPrefab == nil then
        floatTextPrefab = ResourceLibrary.GetUIPrefab("Login/FloatText")
    end
    local floatTextGameObject = GameObject.Instantiate(floatTextPrefab)
    local transform = floatTextGameObject.transform 
    local showIcon = transform:Find("text/icon"):GetComponent("UITexture")
    local floatTextLabel = transform:Find("text"):GetComponent("UILabel")
    floatTextLabel.text = text
    floatTextLabel.color = color or Color.red
    if icon ~= nil then
        showIcon.mainTexture = icon
        showIcon.gameObject:SetActive(true)
    else
        showIcon.gameObject:SetActive(false)
    end
    transform:SetParent(uiTopRoot, false)
    if position ~= nil then
        transform.position = position
    end
    local tweenPosition = transform:Find("text"):GetComponent("TweenPosition")
    showTime = GameTime.realTime
    if showTime - lastShowTime < 0.1 then
        showDelay = showDelay + 0.5
        floatTextGameObject:SetActive(false)
        coroutine.start(function()
            coroutine.wait(showDelay)
            floatTextGameObject:SetActive(true)
        end)
    else
        showDelay = 0
    end
    lastShowTime = showTime
    tweenPosition:SetOnFinished(EventDelegate.Callback(function()
        GameObject.Destroy(floatTextGameObject)
    end))
end

function Show(text, color, icon)
    ShowAt(nil, text, color, icon)
end

function ShowOn(gameObject, text, color, icon)
    ShowAt(gameObject.transform.position, text, color, icon)
end


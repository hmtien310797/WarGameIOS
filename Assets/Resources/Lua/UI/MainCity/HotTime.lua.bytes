module("HotTime",package.seeall)

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
local hotBuff = nil

function LoadUI()
	local buffBaseData = TableMgr:GetSlgBuffData(hotBuff.buffId)
	_ui.actIcon.spriteName = buffBaseData.icon
	_ui.actName.text = TextUtil.GetSlgBuffTitle(buffBaseData)
	_ui.durDes1.text = TextUtil.GetSlgBuffDescription(buffBaseData)
	_ui.durDes2.text = TextMgr:GetText(buffBaseData.description01)
	_ui.leftIcon.mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", buffBaseData.icon01)
	
	local curActBaseData = ActivityData.GetActivityGlobalBuff()
	if curActBaseData ~= nil then
		local nextAct = string.split(curActBaseData.nextactivity , ",")
		_ui.nextBg.gameObject:SetActive(#nextAct == 2)
		if #nextAct == 2 then
			local nextActData = TableMgr:GetActiveConditionData(tonumber(nextAct[1]))
			local nextBuffData = TableMgr:GetSlgBuffData(nextActData.buff)
			_ui.nextIcon.spriteName = nextBuffData.icon
			_ui.nextName.text = TextUtil.GetSlgBuffTitle(nextBuffData)
			_ui.nextDes1.text = TextUtil.GetSlgBuffDescription(nextBuffData)
			_ui.nextTime.text = System.String.Format(TextMgr:GetText("HotTime_11") , nextAct[2])
		end
	end
end



function LateUpdate()
	if _ui ~= nil and hotBuff ~= nil then 
		local leftTimeSec = hotBuff.time - Serclimax.GameTime.GetSecTime()
		if leftTimeSec >= 0 then
			_ui.durantTime.text = Serclimax.GameTime.SecondToString3(leftTimeSec)
		else
			_ui.durantTime.text = "00:00:00"
		end
	end
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function Awake()
	_ui = {}
	local closeBtn = transform:Find("Container/bg/title/close"):GetComponent("UIButton")
	SetClickCallback(closeBtn.gameObject, Hide)
	
	SetClickCallback(transform:Find("mask").gameObject , Hide)
	
	_ui.durantTime = transform:Find("Container/bg/left/base/time"):GetComponent("UILabel")
	_ui.leftIcon = transform:Find("Container/bg/left/Texture"):GetComponent("UITexture")
	_ui.actIcon = transform:Find("Container/bg/right/hot_icon"):GetComponent("UISprite")
	_ui.actName = transform:Find("Container/bg/right/hot_icon/name"):GetComponent("UILabel")
	_ui.durDes1 = transform:Find("Container/bg/right/Label01"):GetComponent("UILabel")
	_ui.durDes2 = transform:Find("Container/bg/right/Label02"):GetComponent("UILabel")
	_ui.nextBg =  transform:Find("Container/bg/right/title/bg")
	_ui.nextIcon = transform:Find("Container/bg/right/title/bg/hot_icon01"):GetComponent("UISprite")
	_ui.nextName = transform:Find("Container/bg/right/title/bg/hot_icon01/name"):GetComponent("UILabel")
	_ui.nextDes1 = transform:Find("Container/bg/right/title/bg/Label03"):GetComponent("UILabel")
	_ui.nextTime = transform:Find("Container/bg/right/title/bg/Label"):GetComponent("UILabel")
end


function Start()

end

function Close()
	_ui = nil
	hotBuff = nil
end

function Show(buff)
	hotBuff = buff
	if hotBuff == nil then
		return
	end
	Global.OpenUI(_M)
	LoadUI()
end

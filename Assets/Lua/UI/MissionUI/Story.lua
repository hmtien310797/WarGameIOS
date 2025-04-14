module("Story", package.seeall)
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
local String = System.String

local _ui, storyid, story, closecallback, DoSpeak, SpeakStory

function Hide()
	Global.CloseUI(_M)
end

local function CloseSelf()
	if _ui == nil then
		return
	end
	_ui.black_top:SetOnFinished(EventDelegate.Callback(function()
		if storyid ~= nil and storyid < 100 then
			ConfigData.SetStoryConfig(storyid)
			MainCityUI.HasReadStory()
		end
		Global.CloseUI(_M)
	end))
	if _ui == nil then
		return
	end
	_ui.black_top:PlayReverse(false)
	if _ui == nil then
		return
	end
	_ui.black_bottom:PlayReverse(false)
end

function Close()
	if closecallback ~= nil then
		closecallback(storyid)
		closecallback = nil
	end
	_ui = nil
	storyid = nil
	story = nil
end

function Show(id, callback)
    if ServerListData.IsAppleReviewing() then
        return
    end

	closecallback = callback
	storyid = id
	if storyid ~= nil then
		if TableMgr:GetStoryById(storyid) == nil then
			if closecallback ~= nil then
				closecallback()
				closecallback = nil
				return
			end
		end
		local textid = TableMgr:GetStoryById(storyid).TextId
		if textid == "" then
			if closecallback ~= nil then
				closecallback()
				closecallback = nil
				return
			end
		end
	end
	Global.OpenUI(_M)
end

function Awake()
	_ui = {}
	_ui.btn = gameObject
	
	_ui.bg_female = {}
	_ui.bg_female.go = transform:Find("bg_female").gameObject
	_ui.bg_female.text = transform:Find("bg_female/bg/text_guide"):GetComponent("UILabel")
	_ui.bg_female.icon = transform:Find("bg_female/bg/icon_guide"):GetComponent("UITexture")
	_ui.bg_female.btn_over = transform:Find("bg_female/bg/btn_over").gameObject
	_ui.bg_female.bg_btn = transform:Find("bg_female/bg/bg_btn").gameObject
	_ui.bg_female.bg_btn:SetActive(false)
	_ui.bg_female.btn1 = transform:Find("bg_female/bg/bg_btn/btn_1").gameObject
	_ui.bg_female.btn1text = transform:Find("bg_female/bg/bg_btn/btn_1/text"):GetComponent("UILabel")
	_ui.bg_female.btn2 = transform:Find("bg_female/bg/bg_btn/btn_2").gameObject
	_ui.bg_female.btn2text = transform:Find("bg_female/bg/bg_btn/btn_2/text"):GetComponent("UILabel")
	
	_ui.bg_male = {}
	_ui.bg_male.go = transform:Find("bg_male").gameObject
	_ui.bg_male.text = transform:Find("bg_male/bg/text_guide"):GetComponent("UILabel")
	
	_ui.bg_general = {}
	_ui.bg_general.go = transform:Find("bg_general").gameObject
	_ui.bg_general.text = transform:Find("bg_general/bg/text_guide"):GetComponent("UILabel")

	_ui.bg_baruch = {}
	_ui.bg_baruch.go = transform:Find("bg_Baruch").gameObject
	_ui.bg_baruch.text = transform:Find("bg_Baruch/bg/text_guide"):GetComponent("UILabel")

	_ui.icon_guide9 = {}
	_ui.icon_guide9.go = transform:Find("icon_guide9").gameObject
	_ui.icon_guide9.text = transform:Find("icon_guide9/bg/text_guide"):GetComponent("UILabel")

	_ui.icon_guide10 = {}
	_ui.icon_guide10.go = transform:Find("icon_guide10").gameObject
	_ui.icon_guide10.text = transform:Find("icon_guide10/bg/text_guide"):GetComponent("UILabel")

	_ui.icon_guide11 = {}
	_ui.icon_guide11.go = transform:Find("icon_guide11").gameObject
	_ui.icon_guide11.text = transform:Find("icon_guide11/bg/text_guide"):GetComponent("UILabel")

	_ui.icon_guide12 = {}
	_ui.icon_guide12.go = transform:Find("icon_guide12").gameObject
	_ui.icon_guide12.text = transform:Find("icon_guide12/bg/text_guide"):GetComponent("UILabel")

	_ui.h301 = {}
	_ui.h301.go = transform:Find("301").gameObject
	_ui.h301.text = transform:Find("301/bg/text_guide"):GetComponent("UILabel")

	_ui.h203 = {}
	_ui.h203.go = transform:Find("203").gameObject
	_ui.h203.text = transform:Find("203/bg/text_guide"):GetComponent("UILabel")

	_ui.icon_guide1 = {}
	_ui.icon_guide1.go = transform:Find("icon_guide1").gameObject
	_ui.icon_guide1.text = transform:Find("icon_guide1/bg/text_guide"):GetComponent("UILabel")
	
	_ui.typewrites = {}
	_ui.typewrites[1] = _ui.bg_female.text.transform:GetComponent("TypewriterEffect")
	_ui.typewrites[2] = _ui.bg_male.text.transform:GetComponent("TypewriterEffect")
	_ui.typewrites[3] = _ui.bg_general.text.transform:GetComponent("TypewriterEffect")
	_ui.typewrites[4] = _ui.bg_baruch.text.transform:GetComponent("TypewriterEffect")
	_ui.typewrites[5] = _ui.icon_guide9.text.transform:GetComponent("TypewriterEffect")
	_ui.typewrites[6] = _ui.icon_guide10.text.transform:GetComponent("TypewriterEffect")
	_ui.typewrites[7] = _ui.icon_guide11.text.transform:GetComponent("TypewriterEffect")
	_ui.typewrites[8] = _ui.icon_guide12.text.transform:GetComponent("TypewriterEffect")
	_ui.typewrites[9] = _ui.h301.text.transform:GetComponent("TypewriterEffect")
	_ui.typewrites[10] = _ui.h203.text.transform:GetComponent("TypewriterEffect")
	_ui.typewrites[11] = _ui.icon_guide1.text.transform:GetComponent("TypewriterEffect")
	for i, v in ipairs(_ui.typewrites) do
		v:Finish()
	end
	
	_ui.black_top = transform:Find("black_top/black"):GetComponent("TweenPosition")
	_ui.black_bottom = transform:Find("black_bottom/black"):GetComponent("TweenPosition")
end

function Start()
	_ui.bg_female.btn1text.text = TextMgr:GetText("Chapterstory_231")
	_ui.bg_female.btn2text.text = TextMgr:GetText("Chapterstory_241")
	_ui.black_top:SetOnFinished(EventDelegate.Callback(function()
		if storyid ~= nil then
			SpeakStory()
		elseif story ~= nil then
			DoSpeak()
		end
	end))
	_ui.black_top:PlayForward(false)
	_ui.black_bottom:PlayForward(false)
end

local curtypewrite = 1
DoSpeak = function()
	if _ui == nil then
		return
	end
	if _ui.typewrites[curtypewrite].isActive then
		_ui.typewrites[curtypewrite]:Finish()
		return
	end
	if story ~= nil and #story > 0 then
		local s = table.remove(story,1)
		_ui.bg_female.go:SetActive(s.person == "icon_guide")
		_ui.bg_male.go:SetActive(s.person == "icon_guide_male")
		_ui.bg_general.go:SetActive(s.person == "305")
		_ui.bg_baruch.go:SetActive(s.person == "bg_Baruch" or s.person == "icon_guide8")
		_ui.icon_guide9.go:SetActive(s.person == "icon_guide9")
		_ui.icon_guide10.go:SetActive(s.person == "icon_guide10")
		_ui.icon_guide11.go:SetActive(s.person == "icon_guide11")
		_ui.icon_guide12.go:SetActive(s.person == "icon_guide12")
		_ui.h301.go:SetActive(s.person == "301")
		_ui.h203.go:SetActive(s.person == "203")
		_ui.icon_guide1.go:SetActive(s.person == "icon_guide1")
		if s.person == "icon_guide"then
			--_ui.bg_female.icon.spriteName = s.person
			_ui.bg_female.text.text = TextMgr:GetText(s.speak)
			curtypewrite = 1
		elseif s.person == "icon_guide_male" then
			_ui.bg_male.text.text = TextMgr:GetText(s.speak)
			curtypewrite = 2
		elseif s.person == "bg_Baruch" or s.person == "icon_guide8" then
			_ui.bg_baruch.text.text = TextMgr:GetText(s.speak)
			curtypewrite = 4
		elseif s.person == "icon_guide9" then
			_ui.icon_guide9.text.text = TextMgr:GetText(s.speak)
			curtypewrite = 5
		elseif s.person == "icon_guide10" then
			_ui.icon_guide10.text.text = TextMgr:GetText(s.speak)
			curtypewrite = 6
		elseif s.person == "icon_guide11" then
			_ui.icon_guide11.text.text = TextMgr:GetText(s.speak)
			curtypewrite = 7
		elseif s.person == "icon_guide12" then
			_ui.icon_guide12.text.text = TextMgr:GetText(s.speak)
			curtypewrite = 8
		elseif s.person == "301" then
			_ui.h301.text.text = TextMgr:GetText(s.speak)
			curtypewrite = 9
		elseif s.person == "203" then
			_ui.h203.text.text = TextMgr:GetText(s.speak)
			curtypewrite = 10
		elseif s.person == "icon_guide1" then
			_ui.icon_guide1.text.text = TextMgr:GetText(s.speak)
			curtypewrite = 11
		else
			_ui.bg_general.text.text = TextMgr:GetText(s.speak)
			curtypewrite = 3
		end
		SetClickCallback(_ui.btn, function()
			AudioMgr:PlayUISfx("SFX_ui01", 1, false)
			DoSpeak()
		end)
		_ui.typewrites[curtypewrite]:ResetToBeginning()
	else
		if _ui == nil then
			return
		end
		_ui.bg_female.go:SetActive(false)
		_ui.bg_male.go:SetActive(false)
		_ui.bg_general.go:SetActive(false)
		_ui.bg_baruch.go:SetActive(false)
		_ui.icon_guide9.go:SetActive(false)
		_ui.icon_guide10.go:SetActive(false)
		_ui.icon_guide11.go:SetActive(false)
		_ui.icon_guide12.go:SetActive(false)
		_ui.h301.go:SetActive(false)
		_ui.h203.go:SetActive(false)
		_ui.icon_guide1.go:SetActive(false)
		CloseSelf()
	end
end

SpeakStory = function()
	local textid = TableMgr:GetStoryById(storyid).TextId
	local temp = textid:split(";")
	story = {}
	for i, v in ipairs(temp) do
		local t = v:split(":")
		local s = {}
		s.person = t[1]
		s.speak = t[2]
		table.insert(story, s)
	end
	DoSpeak()
end

function ShowSigle(person, speak, callback)
	story = {}
	local speaks = speak:split(";")
	for i, v in ipairs(speaks) do
		local s = {}
		s.person = person
		s.speak = v
		table.insert(story, s)
	end
	Show(nil, callback)
end

function ShowMultiple(_story, callback)
	story = _story
	Show(nil, callback)
end

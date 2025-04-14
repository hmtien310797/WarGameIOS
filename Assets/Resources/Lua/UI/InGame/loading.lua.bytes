module("loading", package.seeall)
local ResourceLibrary = Global.GResourceLibrary
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr

local bgTexture
local uiSlider
local hintText
local tipsTextList
local listLength
local timer

function Hide()
    Global.CloseUI(_M)
end

function Close()
	collectgarbage("collect")
	Global.GGUIMgr:GC()    
end

function SetProgress(_value)
	if uiSlider ~= nil then
		uiSlider.value = _value
	end
end

local function RandomTips()
    local rtime = math.random(1,listLength)
    hintText.text = tipsTextList[rtime]
end

function Awake()
	bgTexture = transform:Find("Container/bg_big"):GetComponent("UITexture")
	--bgTexture.mainTexture = ResourceLibrary:GetBg('bg_loading')
	hintText = transform:Find("Container/text_hint"):GetComponent("UILabel")

	uiSlider = transform:Find("Container/bg_loading/loading"):GetComponent("UISlider")
	uiSlider.value = 0;

    tipsTextList = {}
    listLength = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.TipsTotalNum).value)
    for i = 1 , listLength do
        local text = TextMgr:GetText(string.format("tips_%d", i))
        tipsTextList[i] = text
    end
    RandomTips()
    timer = 0

    local fx =  transform:Find("FX")
    local bg_Check = transform:Find("Container/bg_Check")
	local apple_review = ServerListData.IsAppleReviewing()
	if apple_review then
		if fx ~= nil then
			fx.gameObject:SetActive(false)
		end
		if bg_Check ~= nil then
			bg_Check.gameObject:SetActive(true)
		end			
	else
		if fx ~= nil then
			fx.gameObject:SetActive(true)
		end
		if bg_Check ~= nil then
			bg_Check.gameObject:SetActive(false)
		end
	end
end

function Update()
	timer = timer + Time.deltaTime
    if timer>3 then
        timer = timer - 3
        RandomTips()
    end
end

function Show()
    Global.OpenUI(_M)
end


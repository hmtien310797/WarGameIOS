module("LoadingMap", package.seeall)

local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr

local _ui

function ReadyHide()
	collectgarbage("collect")
	Global.GGUIMgr:GC()
end

function Hide()
	Global.CloseUI(_M)
end

function Close()	
	_ui = nil
end

function Show()
	Global.OpenTopUI(_M)
end

function Awake()
	_ui = {}
	_ui.hintText = transform:Find("Container/text_hint"):GetComponent("UILabel")	

	tipsTextList = {}
    listLength = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.TipsTotalNum).value)
    for i = 1 , listLength do
        local text = TextMgr:GetText(string.format("tips_%d", i))
        tipsTextList[i] = text
    end
    local rtime = math.random(1,listLength)
	_ui.hintText.text = tipsTextList[rtime]	

	_ui.bg_logo = transform:Find("Container/bg_logo")
	_ui.loadingdonghua02 = transform:Find("Container/loadingdonghua02")
	_ui.bg_Check = transform:Find("Container/bg_Check")

	local apple_review = ServerListData.IsAppleReviewing()
	if apple_review then
		if _ui.bg_logo ~= nil then
			_ui.bg_logo.gameObject:SetActive(false)
		end
		if _ui.loadingdonghua02 ~= nil then
			_ui.loadingdonghua02.gameObject:SetActive(false)
		end
		if _ui.bg_Check ~= nil then
			_ui.bg_Check.gameObject:SetActive(true)
		end				
	else
		if _ui.bg_logo ~= nil then
			_ui.bg_logo.gameObject:SetActive(true)
		end
		if _ui.loadingdonghua02 ~= nil then
			_ui.loadingdonghua02.gameObject:SetActive(true)
		end
		if _ui.bg_Check ~= nil then
			_ui.bg_Check.gameObject:SetActive(false)
		end	
	end
end

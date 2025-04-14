module("NumberInput", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback

local numberLabel
local maxNumber
local minNumber
local confirmCallback
local inputTipCallback

function Hide()
    Global.CloseUI(_M)
	numberLabel = nil
	inputTipCallback = nil
	confirmCallback = nil
end

function Awake()
    local bg = transform:Find("Container")
    numberLabel = transform:Find("Container/bg_frane/bg_txt/text_num"):GetComponent("UILabel")
    local btnBackspace = transform:Find("Container/bg_frane/btn_use")
    for i = 0, 9 do
        local btnNumber = transform:Find(string.format("Container/bg_frane/btn_%d", i))
        SetClickCallback(btnNumber.gameObject, function(go)
			if inputTipCallback ~= nil then
				inputTipCallback(tonumber(numberLabel.text..i))
			end
            numberLabel.text = Mathf.Clamp(tonumber(numberLabel.text..i), minNumber, maxNumber)

        end)
    end
    local btnConfirm = transform:Find("Container/bg_frane/btn_confirm")

    SetClickCallback(bg.gameObject, function(go)
        Hide()
    end)

    SetClickCallback(btnBackspace.gameObject, function(go)
        local number = tonumber(string.sub(numberLabel.text, 1, -2)) or minNumber
        numberLabel.text = Mathf.Clamp(number, minNumber, maxNumber)
    end)

    SetClickCallback(btnConfirm.gameObject, function(go)
        confirmCallback(tonumber(numberLabel.text))
        Hide()
    end)
end

function Show(defaultText, min, max, callback , tipCallback)
    Global.OpenUI(_M)
    numberLabel.text = defaultText
    minNumber = min
    maxNumber = max
    confirmCallback = callback
	inputTipCallback = tipCallback
end

function OpenNumberInput(defaultText, min, max, callback)
	numberLabel = {}
	numberLabel.text = defaultText
    minNumber = min
    maxNumber = max
    confirmCallback = callback
	GUIMgr:CreateMenu("NumberInput",true)
end
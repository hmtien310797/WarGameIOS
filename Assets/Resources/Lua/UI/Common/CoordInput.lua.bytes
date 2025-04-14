module("CoordInput", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback

local coordLabelX
local coordLabelY

local confirmCallback

function Hide()
    Global.CloseUI(_M)
end

local function ValidateCoord(coord)
    if Global.IsSlgMobaMode() then
        return Mathf.Clamp(tonumber(coord) or 0, 0, 61)
    else
        return Mathf.Clamp(tonumber(coord) or 0, 0, 511)
    end
end

local function ValidateCoordX()
    coordInputX.value = ValidateCoord(coordInputX.value)
end

local function ValidateCoordY()
    coordInputY.value = ValidateCoord(coordInputY.value)
end

function Awake()
    local bg = transform:Find("Container")
    SetClickCallback(bg.gameObject, Hide)
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
    SetClickCallback(closeButton.gameObject, Hide)
    coordLabelX = transform:Find("Container/bg_frane/bg2/bg_food/txt_food"):GetComponent("UILabel")
    coordLabelY = transform:Find("Container/bg_frane/bg3/bg_food/txt_food"):GetComponent("UILabel")

    local coordBgX = transform:Find("Container/bg_frane/bg2/bg_food")
    local coordBgY = transform:Find("Container/bg_frane/bg3/bg_food")
    SetClickCallback(coordBgX.gameObject, function()
        if Global.IsSlgMobaMode() then
			NumberInput.Show("", 0, 61, function(coord)
				coordLabelX.text = coord
			end)
		else 
			NumberInput.Show("", 0, 511, function(coord)
				coordLabelX.text = coord
			end)
		end 
    end)

    SetClickCallback(coordBgY.gameObject, function()
        if Global.IsSlgMobaMode() then
			NumberInput.Show("", 0, 61, function(coord)
				coordLabelY.text = coord
			end)
		else
			NumberInput.Show("", 0, 511, function(coord)
				coordLabelY.text = coord
			end)
		end 
    end)

    local confirmButton = transform:Find("Container/bg_frane/btn_go")
    SetClickCallback(confirmButton.gameObject, function(go)
        Hide()
        local coordX = tonumber(coordLabelX.text)
        local coordY = tonumber(coordLabelY.text)
        if coordX ~= nil and coordY ~= nil then
            confirmCallback(coordX, coordY)
        end
    end)
end

function Show(callback)
    Global.OpenUI(_M)
    confirmCallback = callback
end

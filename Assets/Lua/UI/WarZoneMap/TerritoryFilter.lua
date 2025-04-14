module("TerritoryFilter", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback

local filterIndex
local selectSelf
local callback

function Hide()
    Global.CloseUI(_M)
end

local function LoadUI()
    for i = 1, 5 do
        local checkToggole = transform:Find(string.format("Container/bg_frane/bg_mid/Grid/listitem_Filter (%d)/Sprite", i)):GetComponent("UIToggle")
        checkToggole.value = filterIndex == i
        EventDelegate.Add(checkToggole.onChange, EventDelegate.Callback(function()
            if checkToggole.value then
                filterIndex = i
            end
        end))
    end
    local checkToggole = transform:Find("Container/bg_frane/bg_mid/bg_myunion/Sprite"):GetComponent("UIToggle")
    checkToggole.value = selectSelf
    EventDelegate.Add(checkToggole.onChange, EventDelegate.Callback(function()
        selectSelf = checkToggole.value
    end))
end

function Awake()
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    SetClickCallback(closeButton.gameObject, function()
        Hide()
    end)

    local confirmButton = transform:Find("Container/bg_frane/btn_ok")
    SetClickCallback(confirmButton.gameObject, function()
        callback(filterIndex, selectSelf)
        Hide()
    end)

end

function Show(index, self, cb)
    filterIndex = index
    selectSelf = self
    callback = cb
    Global.OpenUI(_M)
    LoadUI()
end

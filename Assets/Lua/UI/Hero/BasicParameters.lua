module("BasicParameters", package.seeall)

local TextMgr = Global.GTextMgr

local ATTRIBUTE_NAMES = { [100000003] = "heronew_10",
                          [100000006] = "heronew_11",
                          [101] = "heronew_12",
                          [100000101] = "heronew_12",
                          [102] = "heronew_13",
                          [100000102] = "heronew_13", }

local heroData

local ui

function IsInViewport()
    return ui ~= nil
end

local function UpdateUI()
    if GeneralData.HasGeneralByBaseID(heroData.id) then
        local attributes = GeneralData.GetAttributes(GeneralData.GetGeneralByBaseID(heroData.id))[0]
        --local color = uiLabel.color.yellow
        for i, uiLabel in ipairs(ui.attributes) do
            local attributeID = Global.GetAttributeLongID(tonumber(heroData["additionArmy" .. i]), tonumber(heroData["additionAttr" .. i]))
            uiLabel.text = TextMgr:GetText(ATTRIBUTE_NAMES[attributeID]) .. "[FFE165FF]".. string.format("%.1f", attributes[attributeID]) .. "[-]"
        end
    else
        for i, uiLabel in ipairs(ui.attributes) do
            uiLabel.text = TextMgr:GetText(ATTRIBUTE_NAMES[Global.GetAttributeLongID(tonumber(heroData["additionArmy" .. i]), tonumber(heroData["additionAttr" .. i]))])
        end
    end
end

function Show(_heroData)
    heroData = _heroData

    if IsInViewport then
        Global.OpenUI(_M)
    else
        UpdateUI()
    end
end

function Hide()
    Global.CloseUI(_M)
end

function Awake()
    ui = {}

    ui.attributes = {}
    for i = 1, 4 do
        table.insert(ui.attributes, transform:Find(string.format("Container/Background/%d/Label", i)):GetComponent("UILabel"))
    end

    UIUtil.SetClickCallback(transform:Find("Mask").gameObject, Hide)
    UIUtil.SetClickCallback(transform:Find("Container/Close Button").gameObject, Hide)

    EventDispatcher.Bind(GeneralData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(heroInfo, change)
        if heroInfo.baseid == heroData.id then
            if change == 0 then
                UpdateUI()
            end
        end
    end)
end

function Start()
    UpdateUI()
end

function Close()
    EventDispatcher.UnbindAll(_M)

    ui = nil
    heroData = nil
end

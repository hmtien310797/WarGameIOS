module("JailInfoData", package.seeall)
local TextMgr = Global.GTextMgr
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function GetData()
    return jailInfoData
end

function SetData(data)
    jailInfoData = data
end

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function RequestData()
    local req = BuildMsg_pb.MsgPrisonInfoRequest()
    Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgPrisonInfoRequest, req, BuildMsg_pb.MsgPrisonInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetData(msg)
            NotifyListener()            
        else
            Global.ShowError(msg.code)
        end
    end, true)
end

function UpdatePrionserData(data)
    for i, v in ipairs(jailInfoData.prisoner) do
        if v.info.id == data.info.id then
            jailInfoData.prisoner[i] = data
            NotifyListener()
            break
        end
    end
end

function RemovePrionserData(data)
    for i, v in ipairs(jailInfoData.prisoner) do
        if v.info.id == data.info.id then
            jailInfoData.prisoner:remove(i)
            NotifyListener()
            break
        end
    end
end

function GetPrisonerCount()
    return #jailInfoData.prisoner
end

function HasPrisoner()
    return #jailInfoData.prisoner > 0
end

function GetBuffNameValueText()
    local nameText, attrValue = GetBuffNameValue()
    return nameText, System.String.Format("{0:N1}%",  attrValue)
end

function GetBuffNameValue()
    local nameText
    local valueText = 0
    if #jailInfoData.prisonAttr.attrs > 0 then
        local attrMsg = jailInfoData.prisonAttr.attrs[1]
        local armyType = attrMsg.armyType
        local attrId = attrMsg.attrId
        local attrValue = attrMsg.value
        nameText = TextMgr:GetText(BattlefieldReport.GetArmyTypeID(armyType)) .. TextMgr:GetText(BattlefieldReport.GetAttrTypeID(attrId))
        valueText = attrValue
    end
    return nameText, valueText
end

function GetMoneyByType(moneyList, moneyType)
    for _, v in ipairs(moneyList) do
        if v.id == moneyType then
            return v.value
        end
    end

    return 0
end

function GetJailInfoDataByCharName(charName)
    for i, v in ipairs(jailInfoData.prisoner) do
        if v.info.name == charName then
            return v
        end
    end
end

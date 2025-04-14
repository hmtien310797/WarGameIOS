module("DailyActivity_WorldcupGuss", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local SetTooltipCallback = UIUtil.SetTooltipCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime

local _ui
local match_info_id
function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function RefrushMoney()    
    _ui.number.text = Global.ExchangeValue(MoneyListData.GetMoneyByType(Common_pb.MoneyType_ChipCoin))
end

function RefrushItem(item)
    local betInfoMap = WorldCupData.GetBetInfoMap()
    if betInfoMap ~= nil and betInfoMap[match_info_id] ~= nil then
        if betInfoMap[match_info_id][item.data.id] ~= nil then
            item.had.text = betInfoMap[match_info_id][item.data.id].betValue
            item.gameObject.name = "item"..(4294967295 - betInfoMap[match_info_id][item.data.id].betValue)
            
        end 
    end
end

function AddItem(flags,rate,state)
    local item = {}
    item.gameObject = NGUITools.AddChild(_ui.grid.gameObject, _ui.item_prefab.gameObject)
    --item.gameObject.SetActive(true)
    item.country = item.gameObject.transform:Find("base/country"):GetComponent("UILabel")
    item.Texture = item.gameObject.transform:Find("base/Texture"):GetComponent("UITexture")
    item.rate = item.gameObject.transform:Find("base/rate"):GetComponent("UILabel")
    item.had = item.gameObject.transform:Find("base/text1/number"):GetComponent("UILabel")
    item.get =  item.gameObject.transform:Find("base/btn_get")
    item.input_add = item.gameObject.transform:Find("base/text2/add")
    item.input_add_label = item.gameObject.transform:Find("base/text2/add/number"):GetComponent("UILabel")
    item.data = flags
    item.country.text = TextMgr:GetText(item.data.name)
    item.Texture.mainTexture = ResourceLibrary:GetIcon("Icon/Activity/", item.data.Icon)
    item.rate.text = String.Format(TextMgr:GetText("worldcup_9"),rate)
    item.had.text = 0  
    item.input_num = 1
    item.input_add_label.text = item.input_num
    item.gameObject.name = "item"..4294967295
    SetClickCallback(item.input_add.gameObject,function()
        NumberInput.Show(item.input_num, 0,MoneyListData.GetMoneyByType(Common_pb.MoneyType_ChipCoin), function(number)
            item.input_num = number
            item.input_add_label.text = item.input_num
        end)
    end)
    SetClickCallback(item.get.gameObject,function()
        if item.input_num > MoneyListData.GetMoneyByType(Common_pb.MoneyType_ChipCoin) then
            MessageBox.Show(TextMgr:GetText("worldcup_13"), 
            function() 
                Goldstore.Show(1, 109)
            end,
            function() end, TextMgr:GetText("mission_go"),
            TextMgr:GetText("common_hint2"))
        else
            WorldCupData.ReqMsgGuessActMatchBet(match_info_id,flags.id,item.input_num,function()
                RefrushItem(item)
            end)
        end
    end)     
    item.get.gameObject:SetActive(state == 0)
    return item
end

function RefrushAllItem()
    for i =1,#_ui.items do            
        RefrushItem(_ui.items[i])
    end
end


function LoadUI()
    RefrushMoney()
    local ActivityFlags = TableMgr:GetActivityFlagTable()
    local cup_data = WorldCupData.GetData()
    if cup_data == nil then
        return
    end
    for i = 1, #cup_data.matchInfo do
        if match_info_id == cup_data.matchInfo[i].id then
            _ui.match_info = cup_data.matchInfo[i]
            break
        end
    end
    if _ui.match_info == nil then
        return
    end

    local teamId = nil
    if _ui.match_info.winTeam ~= nil and #_ui.match_info.winTeam ~= 0 then
        teamId = _ui.match_info.winTeam
    elseif _ui.match_info.teamId ~= nil and #_ui.match_info.teamId ~= 0  then
        teamId = _ui.match_info.teamId
    end

    if teamId == nil then
        return
    end
    if #teamId == 0 then
        return 
    end
    local cur_time = Serclimax.GameTime.GetSecTime()
    local state = -1
    if _ui.match_info.startBetTime > cur_time then
        state = -1
    elseif cur_time < _ui.match_info.endBetTime then
        state = 0
    else
        state = 1
    end    
    local vote_Time_table = TableMgr:GetActivityVoteTimeTable()
    local vote_Time = vote_Time_table[_ui.match_info.id]
    if vote_Time == nil then
        return
    end
    local as = string.split(vote_Time.ExchangeRate,":")
    local rate = tonumber(as[2])
    
    _ui.items = {}
    for i =1,#teamId do
        local flags = ActivityFlags[teamId[i]]
        if flags ~= nil then
            _ui.items[i] = AddItem(flags,rate,state)
            RefrushItem(_ui.items[i])
        end
    end
    _ui.grid.enabled = true
    MoneyListData.AddListener(RefrushMoney)
    WorldCupData.AddBetListener(RefrushAllItem)
end

function Awake()
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    closeButton.gameObject:SetActive(true)
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, function()
        CloseAll()
    end)
    _ui = {}
    _ui.number = transform:Find("Container/bg_frane/guesscoin/number"):GetComponent("UILabel")
    _ui.scrollView =  transform:Find("Container/bg_frane/Scroll View"):GetComponent("UIScrollView")
    _ui.grid =  transform:Find("Container/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.item_prefab = transform:Find("Container/bg_frane/list")
    _ui.title = transform:Find("Container/bg_frane/bg_top/bg_title_left/title"):GetComponent("UILabel")
    local data = TableMgr:GetActivityVoteTimeTable()
    local item_data =  data[match_info_id]
    if item_data ~= nil then
        _ui.title.text = TextMgr:GetText(item_data.Name)
    end
    LoadUI()
end

function Close()
    MoneyListData.RemoveListener(RefrushMoney)
    WorldCupData.RemoveBetListener(RefrushAllItem)
    _ui = nil
end

function Show(id)
    match_info_id = id

    Global.OpenUI(_M)
end

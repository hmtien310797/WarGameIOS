module("DailyActivity_Worldcup", package.seeall)

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

function CloseSelf()
	Global.CloseUI(_M)
end

function Hide()
    GUIMgr:FindMenu("DailyActivity_Worldcup").gameObject:SetActive(false)
    --Global.CloseUI(_M)
end

function CloseAll()
	CloseSelf()
	DailyActivity.CloseSelf()
end

hasVisited = false
ACTIVITY_ID = 300
function HasVisited() 
    return hasVisited or false
end

function NotifyAvailable()
    hasVisited = false
end

function RefrushMoney()
    _ui.money.text = Global.ExchangeValue(MoneyListData.GetMoneyByType(Common_pb.MoneyType_ChipCoin))
end
function RefrushListItem(item,matchInfo)
    if item == nil or matchInfo == nil then
        return
    end
    item.gameObject:SetActive(true)
    local cur_time = Serclimax.GameTime.GetSecTime()
    local state = -1
    if matchInfo.startBetTime > cur_time then
        state = -1
    elseif cur_time < matchInfo.endBetTime then
        state = 0
    elseif cur_time < matchInfo.awardTime then
        state = 1
    else 
        state = 2
    end

    item.bg.color = state < 0 and Color.black or Color.white
    item.title.color = state < 0 and NGUIMath.HexToColor(0xAAAAAAFF) or NGUIMath.HexToColor(0xFEDC21FF)
    item.btn.gameObject:SetActive(state >= 0)

    if state == 0 then
        item.btn_label.text = TextMgr:GetText("worldcup_6")
        item.btn_label.color = NGUIMath.HexToColor(0xFEDC21FF)
        item.btn.normalSprite = "btn_1"
    elseif state == 1 then
        item.btn_label.text = TextMgr:GetText("worldcup_7")
        item.btn_label.color = NGUIMath.HexToColor(0xAAAAAAFF)
        item.btn.normalSprite = "btn_4"
    elseif state == 2 then
        item.btn_label.text = TextMgr:GetText("worldcup_8")
        item.btn_label.color = NGUIMath.HexToColor(0xAAAAAAFF)
        item.btn.normalSprite = "btn_4"
    end
    
    item.time.gameObject:SetActive(state == 0)
    if state == 0 then
        if cur_time < matchInfo.endBetTime-1 then
            CountDown.Instance:Add("WorldCup"..item.data.id, matchInfo.endBetTime, function(t)
                if matchInfo.endBetTime <= Serclimax.GameTime.GetSecTime() then
                    RefrushListItem(item,matchInfo)
                    CountDown.Instance:Remove("WorldCup"..item.data.id)
                else
                    item.time.text = String.Format( TextMgr:GetText("ActivityAll_24"),t)
                end
            end)           
        end
    else
        CountDown.Instance:Remove("WorldCup"..item.data.id)
    end
end

function AddListItem(item_data)
    local item = {}
    item.gameObject = NGUITools.AddChild(_ui.grid.gameObject, _ui.list_prefab.gameObject)
    --item.gameObject.SetActive(true)
    item.title = item.gameObject.transform:Find("title"):GetComponent("UILabel")
    item.time = item.gameObject.transform:Find("time"):GetComponent("UILabel")
    item.bg = item.gameObject.transform:Find("base"):GetComponent("UITexture")
    item.title.text = TextMgr:GetText(item_data.Name)
    item.bg.mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", item_data.Icon)
    item.btn = item.gameObject.transform:Find("button"):GetComponent("UIButton")
    item.btn_label = item.gameObject.transform:Find("button/Label"):GetComponent("UILabel")
    item.data = item_data
    SetClickCallback(item.btn.gameObject,function()
        DailyActivity_WorldcupGuss.Show(item.data.id)
    end)
    return item
end

function LoadUI()
    table.foreach(_ui.item,function(i,v)
        v.gameObject:SetActive(false)
    end)  

    local cup_data =  WorldCupData.GetData()
    if cup_data ~= nil then
        for i =1 ,#cup_data.matchInfo do
            local item= _ui.item[cup_data.matchInfo[i].id]
            if item ~= nil then
                RefrushListItem(item,cup_data.matchInfo[i])
            end
        end
    end
    _ui.grid:Reposition()
    _ui.scrollView:ResetPosition() 
    
    RefrushMoney(); 
end

--CloseSelf

function Awake()
    local closeButton = transform:Find("Container/background/close btn")
    closeButton.gameObject:SetActive(true)
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, function()
        CloseAll()
        ActivityAll.Hide()
    end)
    _ui.list_prefab =  transform:Find("Container/content/list")
    _ui.scrollView =  transform:Find("Container/content/Scroll View"):GetComponent("UIScrollView")
    _ui.grid =  transform:Find("Container/content/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.help =  transform:Find("Container/content/button_ins")
    _ui.money = transform:Find("Container/content/top/number"):GetComponent("UILabel")
    _ui.help_ui = transform:Find("DailyActivity_WorldcupHelp")
    _ui.help_ui_close = transform:Find("DailyActivity_WorldcupHelp/Container/bg_frane/bg_top/btn_close")
    _ui.help_ui_mask = transform:Find("DailyActivity_WorldcupHelp/mask")

    _ui.item = {}
    local data = TableMgr:GetActivityVoteTimeTable()
    table.foreach(data,function(i,v)
       local item =  AddListItem(v)
       _ui.item[item.data.id] = item
    end)   
    SetClickCallback(_ui.help.gameObject, function()
        GOV_Help.Show(GOV_Help.HelpModeType.WorldCup)
    end)    
    SetClickCallback(_ui.help_ui_close.gameObject, function()
        _ui.help_ui.gameObject:SetActive(false)
    end)   
    SetClickCallback(_ui.help_ui_mask.gameObject, function()
        _ui.help_ui.gameObject:SetActive(false)
    end)         
    MoneyListData.AddListener(RefrushMoney)
    WorldCupData.ReqMsgGuessActGetInfo(nil,true)
    WorldCupData.AddListener(LoadUI)
    --LoadUI()
end

function Close()
    MoneyListData.RemoveListener(RefrushMoney)
    if _ui.item ~= nil then
        table.foreach(_ui.item,function(i,v)
            CountDown.Instance:Remove("WorldCup"..v.data.id)
        end)  
    end
    WorldCupData.RemoveListener(LoadUI)
    _ui = nil
end

function Show(activity,updateTemplet)
	if activity == nil then
		print("############### Activity is null ###############")
		return
	end
	
	if updateTemplet == nil or not updateTemplet then
		if _ui == nil then
			_ui = {}
		end
		_ui.activity = activity
        Global.OpenUI(_M)
	else
        _ui.activity = activity
        WorldCupData.ReqMsgGuessActGetInfo(nil,true)
		LoadUI()
    end 
    if not hasVisited then
		hasVisited = true
    end    
    DailyActivityData.NotifyUIOpened(ACTIVITY_ID)
    
end

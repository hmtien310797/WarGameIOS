module("PVP_ATK_DisRank", package.seeall)

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


function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end



function SetupItems(index)
    if _ui.select_index ~= nil then
        if _ui.tabs[_ui.select_index] ~= nil then
            _ui.tabs[_ui.select_index].select.gameObject:SetActive(false)
        end
        _ui.select_index = nil
    end
    _ui.select_index = index
    if _ui.tabs[_ui.select_index] == nil then
        return
    end    
    _ui.tabs[_ui.select_index].select.gameObject:SetActive(true)
    local rank_detail = _ui.disRank_data.rankDetail[_ui.select_index]
    local rank_count = rank_detail.rankInfos ~= nil and #rank_detail.rankInfos or 0
    local item_count = #_ui.items
    for i =1,item_count do
        if i>rank_count then
            _ui.items[i].root.gameObject:SetActive(false)
            SetClickCallback(_ui.items[i].root.gameObject, nil)
        else
            _ui.items[i].root.gameObject:SetActive(true)
            _ui.items[i].no1.gameObject:SetActive(false)
            _ui.items[i].no2.gameObject:SetActive(false)
            _ui.items[i].no3.gameObject:SetActive(false)
            _ui.items[i].no4.gameObject:SetActive(false)    
            local rank_info = rank_detail.rankInfos[i]

            if rank_info.rank == 1 then
                _ui.items[i].no1.gameObject:SetActive(true)
                _ui.items[i].no1.text = rank_info.rank 
            elseif rank_info.rank == 2 then
                _ui.items[i].no2.gameObject:SetActive(true)  
                _ui.items[i].no2.text = rank_info.rank 
            elseif rank_info.rank == 3 then
                _ui.items[i].no3.gameObject:SetActive(true)   
                _ui.items[i].no3.text = rank_info.rank 
            else
                _ui.items[i].no4.gameObject:SetActive(true)  
                _ui.items[i].no4.text = rank_info.rank   
            end
            _ui.items[i].name.text = rank_info.guildBanner == "" and "[---]"..rank_info.name or "["..rank_info.guildBanner.."]"..rank_info.name
            SetClickCallback(_ui.items[i].root.gameObject, function()
                OtherInfo.RequestShow(rank_info.charid)
            end)
        end
        _ui.items[i].bg:SetActive(i % 2 == 1)
    end
    _ui.item_gird:Reposition()
end

function SetupTabs()
    for i=1,#_ui.disRank_data.rankDetail do
        _ui.tabs[i] = {}
        _ui.tabs[i].root = NGUITools.AddChild(_ui.tab_grid.gameObject, _ui.tab_prefab).transform
        _ui.tabs[i].name = _ui.tabs[i].root:Find("Name"):GetComponent("UILabel")
        _ui.tabs[i].select = _ui.tabs[i].root:Find("select")
        _ui.tabs[i].index = i
        _ui.tabs[i].root.gameObject:SetActive(true)
        _ui.tabs[i].name.text = String.Format(TextMgr:GetText("PVP_ATK_Activity_ui19"), _ui.disRank_data.rankDetail[i].term)
        SetClickCallback(_ui.tabs[i].root.gameObject,function()
            SetupItems(_ui.tabs[i].index)
        end)
    end
    _ui.tab_grid:Reposition()
end

function InitItems()
    for i=1,10 do
        _ui.items[i] = {}
        _ui.items[i].root = NGUITools.AddChild(_ui.item_gird.gameObject, _ui.item_prefab).transform
        _ui.items[i].no1 = _ui.items[i].root:Find("no.1"):GetComponent("UILabel")
        _ui.items[i].no2 = _ui.items[i].root:Find("no.2"):GetComponent("UILabel")
        _ui.items[i].no3 = _ui.items[i].root:Find("no.3"):GetComponent("UILabel")
        _ui.items[i].no4 =  _ui.items[i].root:Find("no.4"):GetComponent("UILabel")
        _ui.items[i].name = _ui.items[i].root:Find("name"):GetComponent("UILabel")
        _ui.items[i].bg = _ui.items[i].root:Find("background").gameObject
    end
end

function LoadUI()
    InitItems()
    SetupTabs()
    SetupItems(1)
end

function Awake()
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, function()
        CloseAll()
    end)
    _ui.tab_prefab = transform:Find("Container/bg_frane/bg_left/Scroll View/New Tab").gameObject
    _ui.item_prefab = transform:Find("Container/bg_frane/bg_right/Scroll View/bg_list").gameObject
    _ui.tab_scroll_view = transform:Find("Container/bg_frane/bg_left/Scroll View")
    _ui.tab_grid = transform:Find("Container/bg_frane/bg_left/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.item_scroll_view = transform:Find("Container/bg_frane/bg_right/Scroll View")
    _ui.item_gird = transform:Find("Container/bg_frane/bg_right/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.tabs = {}
    _ui.items = {}

end


function Start()

end

function Close()
  
    _ui = nil
end

function reverseTable(tab)  
    local tmp = {}  
    for i = 1, #tab do  
        local key = #tab  
        tmp[i] = table.remove(tab)  
    end  
  
    return tmp  
end 

function Show()
    ActiveSlaughterData.ReqMsgSlaughterGetRankInfo(function(msg)
        _ui= {}
        _ui.disRank_data ={}
        _ui.disRank_data.rankDetail ={}
        for i=1,#msg.rankDetail do
            _ui.disRank_data.rankDetail[msg.rankDetail[i].term]=msg.rankDetail[i]
        end
        _ui.disRank_data.rankDetail = reverseTable(_ui.disRank_data.rankDetail)
        Global.OpenUI(_M)
        LoadUI()
    end)
end

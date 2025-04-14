module("RebelSurroundrewardList",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback
local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String
local MaxLevel 

local _ui

local BtnStateStr = {
    "red_left",
    "red_mid",
    "red_right",
    "red_mid_gray",
    "red_mid_gray",
    "red_right_gray",
}

function isOpen()
    return _ui ~= nil
end

function RefrushRewardList(level)
    print("RefrushRewardList",level)
    CountDown.Instance:Remove("fastEndTime")
    local data = RebelSurroundData.GetData()
    local rewards = RebelSurroundData.GetRewardList()
    if level > #rewards then
        print("！！！！！！！！level > #data.rewardList ",level, #data.rewardList)
        return
    end

    for i =1,#rewards[level].sortWave do
        --if data.levelInfo.waveInfos[i].type == 2 then
        if i == 4 then
            RebelSurround.RefrushRewardItem(_ui.rewardListFightback,level,rewards[level].sortWave[i],false,nil,function(success,msg)
                if success then
                    RefrushRewardList(level)
                    _ui.Btns[level].red.gameObject:SetActive(RebelSurroundData.GetCanTakeRewardCount4Level(level) ~= 0)
                    MainCityUI.UpdateRewardData(msg.freshInfo)
                    ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
                    ItemListShowNew.SetItemShow(msg)
                    GUIMgr:CreateMenu("ItemListShowNew" , false)        
                end        
            end)
            break
        else
            RebelSurround.RefrushRewardItem(_ui.rewardListFight[i],level,rewards[level].sortWave[i],false,nil,function(success,msg)
                if success then
                    RefrushRewardList(level)
                    _ui.Btns[level].red.gameObject:SetActive(RebelSurroundData.GetCanTakeRewardCount4Level(level) ~= 0)
                    MainCityUI.UpdateRewardData(msg.freshInfo)
                    ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
                    ItemListShowNew.SetItemShow(msg)
                    GUIMgr:CreateMenu("ItemListShowNew" , false)     
                end           
            end)
        end
    end

    local fastEndTime =  nil
    if data.curLevel == level then
        fastEndTime = data.levelInfo.fastEndTime 
    end
    RebelSurround.RefrushRewardItem(_ui.rewardListFast,level,rewards[level].msg.fastReward,false,level == data.curLevel and fastEndTime or nil,function(success,msg)
        if success then
            RefrushRewardList(level)
            _ui.Btns[level].red.gameObject:SetActive(RebelSurroundData.GetCanTakeRewardCount4Level(level) ~= 0)
            MainCityUI.UpdateRewardData(msg.freshInfo)
            ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
            ItemListShowNew.SetItemShow(msg)
            GUIMgr:CreateMenu("ItemListShowNew" , false)     
        end            
    end)
end

function AllBtnFree()
    for i = 1,5 do
        _ui.Btns[i].select.gameObject:SetActive(false)
    end
end

function SelectLevel(level,obj)
    local data = RebelSurroundData.GetData()

    if data.passAll or level <= MaxLevel then
        AllBtnFree()
        _ui.Btns[level].select.gameObject:SetActive(true)
        RefrushRewardList(level)
    else
        if obj ~= nil then
            FloatText.ShowOn(obj, TextMgr:GetText("RebelSurround_21"), Color.red)
        end
    end
end

function Awake()
    _ui = {}
    _ui.Close = transform:Find("Container/bg/top/button_close")
    SetClickCallback(_ui.Close.gameObject,function()
        Hide()
    end)    
    
    _ui.Mask = transform:Find("mask")
    if _ui.Mask ~= nil then
        SetClickCallback(_ui.Mask.gameObject,function()
            Hide()
        end)        
    end     
    _ui.rewardListFight = {}
    _ui.rewardListFight[1] = transform:Find("Container/bg/Container_1/reward_1/Grid/left_list")
    _ui.rewardListFight[2] = transform:Find("Container/bg/Container_1/reward_1/Grid/left_list (1)")
    _ui.rewardListFight[3] = transform:Find("Container/bg/Container_1/reward_1/Grid/left_list (2)")

    _ui.rewardListFightback = transform:Find("Container/bg/Container_1/reward_1 (1)/Grid/left_list")

    _ui.rewardListFast = transform:Find("Container/bg/Container_1/reward_1 (2)/Grid/left_list")

    _ui.Btns = {}

    local data = RebelSurroundData.GetData()
    if Serclimax.GameTime.GetSecTime() >= data.levelInfo.startTime then
        MaxLevel = data.passAll and 5 or data.curLevel
    else
        MaxLevel = data.curLevel - 1
    end    
    
    for i = 1,5 do
        _ui.Btns[i] = {}
        _ui.Btns[i].btn = transform:Find("Container/bg/top/"..i):GetComponent("UIButton")
        _ui.Btns[i].btnLabel = transform:Find("Container/bg/top/"..i.."/Label"):GetComponent("UILabel")
        _ui.Btns[i].select = transform:Find("Container/bg/top/"..i.."/select")
        _ui.Btns[i].red = transform:Find("Container/bg/top/"..i.."/red")
        _ui.Btns[i].btnLabel.text = TextMgr:GetText("RebelSurroundname_"..i)
        _ui.Btns[i].red.gameObject:SetActive(RebelSurroundData.GetCanTakeRewardCount4Level(i) ~= 0)
        if not data.passAll and i > MaxLevel then
            if i == 1 then
                _ui.Btns[i].btn.normalSprite = BtnStateStr[4]
            elseif i < 5 then
                _ui.Btns[i].btn.normalSprite = BtnStateStr[5]
            else
                _ui.Btns[i].btn.normalSprite = BtnStateStr[6]
            end
            _ui.Btns[i].btnLabel.color = Color(184/255,184/255,184/255,1)
        else
            if i == 1 then
                _ui.Btns[i].btn.normalSprite = BtnStateStr[1]
            elseif i < 5 then
                _ui.Btns[i].btn.normalSprite = BtnStateStr[2]
            else
                _ui.Btns[i].btn.normalSprite = BtnStateStr[3]
            end            
            
        end

        SetClickCallback(_ui.Btns[i].btn.gameObject,function()
            SelectLevel(i,_ui.Btns[i].btn.gameObject)
        end)
    end
    SelectLevel(MaxLevel)
    
end

function Start()
end

function Hide()
    CountDown.Instance:Remove("fastEndTime")
    RebelSurround.UpdateRewardRed()
    Global.CloseUI(_M)
end

function Close()
    _ui = nil
end

function Show()
	Global.OpenUI(_M)	
end

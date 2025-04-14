module("GOV_predict", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameObject = UnityEngine.GameObject

local _ui

local hasVisited = false

function HasVisited()
	return hasVisited or false
end

function NotifyAvailable()
	hasVisited = false
end


function Hide()
    Global.CloseUI(_M)
end

LoadUI = function()
   

    local govstate = GovernmentData.GetGOVState()
    local govdata = GovernmentData.GetGovernmentData()
    local govActInfo = GovernmentData.GetGOVActInfo()
    local endTime = 0

    if govstate == 1 then        
        endTime = govActInfo.contendStartTime
    elseif govstate == 2 then
        endTime = govActInfo.contendEndTime
    end
    if GameTime.GetSecTime() > endTime then
        endTime = GameTime.GetSecTime() + 7200
        print("Error：Server active time error！！！！！！！！！！！！！！！！"..endTime)
    end    

    if govstate == 1 then
        _ui.des.gameObject:SetActive(true)
        --_ui.help.gameObject:SetActive(true)
        --_ui.go.gameObject:SetActive(true)
        --_ui.war.gameObject:SetActive(false)
        _ui.war_des.gameObject:SetActive(false)
        _ui.war_sprite.spriteName = "btn_4"
        _ui.war_btn.normalSprite = "btn_4"        
        _ui.govStateTitle.text = TextMgr:GetText("GOV_ui66")
        endTime = govActInfo.contendStartTime
    else
        _ui.des.gameObject:SetActive(false)
        --_ui.help.gameObject:SetActive(false)
        --_ui.go.gameObject:SetActive(false)
        --_ui.war.gameObject:SetActive(true)
        _ui.war_des.gameObject:SetActive(true)
        _ui.war_sprite.spriteName = "btn_1"
        _ui.war_btn.normalSprite = "btn_1"        
        _ui.govStateTitle.text = TextMgr:GetText("GOV_ui67")
        if govdata.archonInfo.guildId ~= 0 then
            _ui.war_des_guild.text = "["..govdata.archonInfo.guildBanner.."]"..govdata.archonInfo.guildName --govdata.archonInfo.guildName
            _ui.badge_root1.gameObject:SetActive(true)
            _ui.badge_root2.gameObject:SetActive(true)
            UnionBadge.LoadBadgeById(_ui.badge, govdata.archonInfo.guildBadge)
        else
            _ui.badge_root1.gameObject:SetActive(false)
            _ui.badge_root2.gameObject:SetActive(false)
            _ui.war_des_guild.text = TextMgr:GetText("union_nounion")
        end
        endTime = govActInfo.contendEndTime
    end
    if GameTime.GetSecTime() > endTime then
        endTime = GameTime.GetSecTime() + 7200
        error("Error：Server active time error！！！！！！！！！！！！！！！！")
    end     
    CountDown.Instance:Add("Predict",endTime,CountDown.CountDownCallBack(function(t)
        if _ui == nil then
            CountDown.Instance:Remove("Predict")
            return
        end
        _ui.govStateTime.text  = t

        if endTime+1 - GameTime.GetSecTime() <= 0 then
            CountDown.Instance:Remove("Predict")    
            LoadUI()                
        end			
    end))       
end

function  Awake()
    _ui = {}
    _ui.mask = transform:Find("mask")
    _ui.badge_root = transform:Find("Container/bg_frane/mid/bg_waring/badge bg")
    _ui.badge_root1 = transform:Find("Container/bg_frane/mid/bg_waring/badge bg/outline icon")
    _ui.badge_root2 = transform:Find("Container/bg_frane/mid/bg_waring/badge bg/totem icon")
    _ui.badge = {}
    UnionBadge.LoadBadgeObject(_ui.badge, _ui.badge_root)    
    _ui.govStateTitle = transform:Find("Container/bg_frane/mid/Sprite_time/text"):GetComponent("UILabel")
    _ui.govStateTime = transform:Find("Container/bg_frane/mid/Sprite_time/time"):GetComponent("UILabel")
    _ui.help = transform:Find("Container/bg_frane/mid/occuRule")
    _ui.go = transform:Find("Container/bg_frane/mid/rule")
    _ui.war =  transform:Find("Container/bg_frane/mid/btn_war")
    _ui.war_sprite = _ui.war.gameObject:GetComponent("UISprite")
    _ui.war_btn = _ui.war.gameObject:GetComponent("UIButton")


    _ui.des =  transform:Find("Container/bg_frane/mid/text")
    _ui.war_des =  transform:Find("Container/bg_frane/mid/bg_waring")
    _ui.war_des_guild =  transform:Find("Container/bg_frane/mid/bg_waring/text (2)"):GetComponent("UILabel")

    if _ui.close ~= nil then
        SetClickCallback(_ui.close.gameObject,function()
            ActivityAll.Hide()
            Hide()
        end) 
    end
   
    SetClickCallback(_ui.mask.gameObject,function()
        ActivityAll.Hide()
        Hide()
        
    end)      

    SetClickCallback(_ui.help.gameObject,function()
        GOV_Help.Show(GOV_Help.HelpModeType.PREDICTMODE)
    end)   

    SetClickCallback(_ui.go.gameObject,function()
        MainCityUI.ShowWorldMap(176, 176, true)
        ActivityAll.CloseAll()
    end)   
    
    SetClickCallback(_ui.war.gameObject,function()
        local govstate = GovernmentData.GetGOVState()
        if govstate == 1 then
            FloatText.ShowOn(_ui.war.gameObject, TextMgr:GetText("activity_wait"), Color.red)
        else
            GOVWarinfo.Show()
        end
        
    end)       

    LoadUI()
end

function Start()
    if not hasVisited then
		hasVisited = true
        MainCityUI.UpdateActivityAllNotice(2008)
        MainCityUI.UpdateActivityAllNotice(2009)
        MainCityUI.UpdateActivityAllNotice(2010)
        MainCityUI.UpdateActivityAllNotice(2011)
		
		
        MainCityUI.UpdateActivityAllNotice(110005)
        MainCityUI.UpdateActivityAllNotice(100005)
        MainCityUI.UpdateActivityAllNotice(110006)
        MainCityUI.UpdateActivityAllNotice(100006)
		
	end
end

function Show()    
    Global.OpenUI(_M)
end

function Close()   
    CountDown.Instance:Remove("Predict") 
    _ui = nil
end
module("PVP_ATK_Activity", package.seeall)

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
local CloseSecondTrfStr={
    [1]= "Container/bg_frane/bg_topplayer/Grid/iteminfo",
    [2]= "Container/bg_frane/bg_topplayer/Grid/iteminfo (1)",
    [3]= "Container/bg_frane/bg_topplayer/Grid/iteminfo (2)",
}

local OpenRewardItemTrfStr={
    [1]= "Container/bg_frane/bg_rewards/bg_array/GameObject/icon_item1",
    [2]= "Container/bg_frane/bg_rewards/bg_array/GameObject/icon_item2",
    [3]= "Container/bg_frane/bg_rewards/bg_array/GameObject/icon_item3",
}

local OpenRewardReadyTrfStr ={
    [1]= "Container/bg_frane/bg_rewards/bg_array/GameObject/icon_item1/ShineItem",
    [2]= "Container/bg_frane/bg_rewards/bg_array/GameObject/icon_item2/ShineItem",
    [3]= "Container/bg_frane/bg_rewards/bg_array/GameObject/icon_item3/ShineItem",
}

local RewardBoxCloseSpriteNames ={
    [1] = "icon_starbox_s_done_dm",
    [2] = "icon_starbox_m_done_dm",
    [3] = "icon_starbox_b_done_dm",
}
local RewardBoxOpenSpriteNames ={
    [1] = "icon_starbox_s_open_dm",
    [2] = "icon_starbox_m_open_dm",
    [3] = "icon_starbox_b_open_dm",
}
local RewardBoxNullSpriteNames = {
    [1] = "icon_starbox_s_null_dm",
    [2] = "icon_starbox_m_null_dm",
    [3] = "icon_starbox_b_null_dm",
}

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local hasVisited = false

function HasVisited() 
    return hasVisited or false
end

function NotifyAvailable()
    hasVisited = false
end

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if _ui ~= nil then
        if go ~= _ui.tipObject then
        _ui.tipObject = nil
        end
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

function SetupCloseFirst()
    _ui.CloseFirstGrid = {}
    local data = TableMgr:GetPVPATK(101)
    if data == nil then
        return 
    end
    _ui.CloseFirstGrid.gridTransform = transform:Find("Container/bg_frane/bg_rewards1/Grid")
    _ui.CloseFirstGrid.grid = _ui.CloseFirstGrid.gridTransform:GetComponent("UIGrid")
    ShareCommon.LoadRewardList(_ui, _ui.CloseFirstGrid.gridTransform, data.no1)
    _ui.CloseFirstGrid.grid.repositionNow = true
end

function SetupCloseSecond()
    _ui.CloseSecondGrid = {}
    for i=1,3 do
        _ui.CloseSecondGrid[i] = {}
        _ui.CloseSecondGrid[i].root = transform:Find(CloseSecondTrfStr[i])
        _ui.CloseSecondGrid[i].name = _ui.CloseSecondGrid[i].root:Find("bg/name"):GetComponent("UILabel")
        _ui.CloseSecondGrid[i].btn = _ui.CloseSecondGrid[i].root:Find("bg/bg_touxiang"):GetComponent("UISprite")
        _ui.CloseSecondGrid[i].face = _ui.CloseSecondGrid[i].root:Find("bg/bg_touxiang/icon_touxiang"):GetComponent("UITexture")        
        _ui.CloseSecondGrid[i].bg_vip = _ui.CloseSecondGrid[i].root:Find("bg/bg_touxiang/bg_vip")		
		_ui.CloseSecondGrid[i].vipSpr = _ui.CloseSecondGrid[i].bg_vip:Find("icon"):GetComponent("UISprite")		
		_ui.CloseSecondGrid[i].vipLabel = _ui.CloseSecondGrid[i].bg_vip:Find("num"):GetComponent("UILabel")

        _ui.CloseSecondGrid[i].name.gameObject:SetActive(false)
        _ui.CloseSecondGrid[i].face.gameObject:SetActive(false)
        if _ui.slaughter_data.rankInfo ~= nil and _ui.slaughter_data.rankInfo[i] ~= nil then
            local viplevel = _ui.slaughter_data.rankInfo[i].vipLevel ~= nil and _ui.slaughter_data.rankInfo[i].vipLevel or 0
            _ui.CloseSecondGrid[i].bg_vip.gameObject:SetActive(viplevel > 0)
            _ui.CloseSecondGrid[i].vipSpr.spriteName = "bg_avatar_num_vip"..math.ceil(viplevel/5)
            _ui.CloseSecondGrid[i].btn.spriteName = "bg_avatar_vip"..math.ceil(viplevel/5)
            _ui.CloseSecondGrid[i].vipLabel.text =viplevel
            _ui.CloseSecondGrid[i].name.text = _ui.slaughter_data.rankInfo[i].guildBanner == "" and "[---]".._ui.slaughter_data.rankInfo[i].name or
             "[".._ui.slaughter_data.rankInfo[i].guildBanner.."]".._ui.slaughter_data.rankInfo[i].name
            _ui.CloseSecondGrid[i].face.mainTexture = ResourceLibrary:GetIcon("Icon/head/", _ui.slaughter_data.rankInfo[i].face)
            _ui.CloseSecondGrid[i].name.gameObject:SetActive(true)
            _ui.CloseSecondGrid[i].face.gameObject:SetActive(true) 
            SetClickCallback(_ui.CloseSecondGrid[i].btn.gameObject,function()
                OtherInfo.RequestShow(_ui.slaughter_data.rankInfo[i].charId)
            end)            
        end
    end
end

function SetupPurchase()
    if #_ui.purchase_ids == 0 then
        _ui.OpenRewardRoot.purchase.root.gameObject:SetActive(false)
        return
    end    
    _ui.OpenRewardRoot.purchase.root.gameObject:SetActive(true)
    for i =1,#_ui.purchase_ids do
        print("GiftPackData.IsGiftPackAvailable",i,_ui.purchase_ids[i],GiftPackData.IsGiftPackAvailable(_ui.purchase_ids[i]),GiftPackData.GetAvailableGoodsByID(_ui.purchase_ids[i]))
        if GiftPackData.IsGiftPackAvailable(_ui.purchase_ids[i]) then
            local gpd = GiftPackData.GetAvailableGoodsByID(_ui.purchase_ids[i])
            _ui.OpenRewardRoot.purchase.name.text = TextMgr:GetText(gpd.name)
            _ui.OpenRewardRoot.purchase.icon.mainTexture = ResourceLibrary:GetIcon("pay/", gpd.icon)
            SetClickCallback(_ui.OpenRewardRoot.purchase.root.gameObject,function()
                CloseAll()
                ActivityAll.Hide()       
                Goldstore.ShowGiftPack(gpd)
            end)
            if gpd.endTime > 0 then
                CountDown.Instance:Add("ATK_PurchaseTime", gpd.endTime, function(t)
                    _ui.OpenRewardRoot.purchase.time.text = t
                    if gpd.endTime <= Serclimax.GameTime.GetSecTime() then
                        CountDown.Instance:Remove("ATK_PurchaseTime")
                        SetupPurchase()
                    end
                end)
            else
                CountDown.Instance:Remove("ATK_PurchaseTime")
            end
            return
        end
    end
    _ui.OpenRewardRoot.purchase.root.gameObject:SetActive(false)

end

function SetupReward()
    if _ui == nil then
        return
    end
    local cur_score = _ui.slaughter_data.selfInfo.score
    local max_score = 0
    for i=1,3 do
        _ui.OpenRewardRoot.reward.item_root[i].score.text = _ui.slaughter_data.selfInfo.reward[i].needScroe
        max_score = _ui.slaughter_data.selfInfo.reward[i].needScroe;
        if _ui.slaughter_data.selfInfo.reward[i].isReward then
            _ui.OpenRewardRoot.reward.item_root[i].sprite.spriteName = RewardBoxOpenSpriteNames[i]
        else
            if cur_score >= _ui.slaughter_data.selfInfo.reward[i].needScroe then
                _ui.OpenRewardRoot.reward.item_root[i].sprite.spriteName = RewardBoxCloseSpriteNames[i]
            else
                _ui.OpenRewardRoot.reward.item_root[i].sprite.spriteName = RewardBoxNullSpriteNames[i]
            end
        end
        if cur_score >= _ui.slaughter_data.selfInfo.reward[i].needScroe and not _ui.slaughter_data.selfInfo.reward[i].isReward then
            _ui.OpenRewardRoot.reward.item_root[i].ready.gameObject:SetActive(true)
        else
            _ui.OpenRewardRoot.reward.item_root[i].ready.gameObject:SetActive(false)
        end
        SetClickCallback(_ui.OpenRewardRoot.reward.item_root[i].btn.gameObject,function()
            SectionRewards.ShowCustom(_ui.slaughter_data.selfInfo.reward[i].dropId,function(_sr_ui)
                _sr_ui.hintRoot.gameObject:SetActive(false)
                _sr_ui.hintATKRoot.gameObject:SetActive(true)
                _sr_ui.title.text = TextMgr:GetText("PVP_ATK_Activity_ui15")
                _sr_ui.hintATKLabel.text = System.String.Format(TextMgr:GetText("PVP_ATK_Activity_ui18"), _ui.slaughter_data.selfInfo.reward[i].needScroe)
                local enable_get_reward = _ui.slaughter_data.selfInfo.score >=  _ui.slaughter_data.selfInfo.reward[i].needScroe 
                and not _ui.slaughter_data.selfInfo.reward[i].isReward
                UIUtil.SetBtnEnable(_sr_ui.rewardButton ,"btn_2", "btn_4",
                enable_get_reward)
                _sr_ui.rewardLabel.text = TextMgr:GetText(_ui.slaughter_data.selfInfo.reward[i].isReward and Text.SectionRewards_ui5 or Text.mail_ui12)
                SetClickCallback(_sr_ui.rewardButton.gameObject, function(go)
                    if enable_get_reward then
                        ActiveSlaughterData.ReqMsgSlaughterGetReward(_ui.slaughter_data.selfInfo.reward[i].index,function(msg)
                            _ui.slaughter_data = ActiveSlaughterData.GetData()
							SectionRewards.Hide()
                            MainCityUI.UpdateRewardData(msg.fresh)
                            ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
                            ItemListShowNew.SetItemShow(msg)
                            GUIMgr:CreateMenu("ItemListShowNew" , false) 
                            UpdateRewardState()                     
                        end)
                    end
                end)
            end)
            
        end)
    end
    for i=1,3 do
        local pos = _ui.OpenRewardRoot.reward.item_root[i].btn.transform.localPosition
        pos.x = (_ui.slaughter_data.selfInfo.reward[i].needScroe/max_score)*455
        _ui.OpenRewardRoot.reward.item_root[i].btn.transform.localPosition = pos
    end    
    _ui.OpenRewardRoot.reward.slider.value = cur_score/max_score
    _ui.OpenRewardRoot.reward.myscore.text = TextMgr:GetText("PVP_ATK_Activity_ui17").._ui.slaughter_data.selfInfo.score
end

function SetupOpenReward()
    _ui.OpenRewardRoot = {}
    _ui.OpenRewardRoot.purchase = {}
    _ui.OpenRewardRoot.purchase.root = transform:Find("Container/bg_frane/bg_rewards/purchase")
    _ui.OpenRewardRoot.purchase.name = _ui.OpenRewardRoot.purchase.root:Find("Label"):GetComponent("UILabel")
    _ui.OpenRewardRoot.purchase.icon = _ui.OpenRewardRoot.purchase.root:Find("Texture"):GetComponent("UITexture")
    _ui.OpenRewardRoot.purchase.time = _ui.OpenRewardRoot.purchase.root:Find("time"):GetComponent("UILabel")
    _ui.OpenRewardRoot.reward = {}
    _ui.OpenRewardRoot.reward.item_root = {}
    for i=1,3 do
        _ui.OpenRewardRoot.reward.item_root[i] = {}
        _ui.OpenRewardRoot.reward.item_root[i].btn = transform:Find(OpenRewardItemTrfStr[i])
        _ui.OpenRewardRoot.reward.item_root[i].sprite = _ui.OpenRewardRoot.reward.item_root[i].btn:GetComponent("UISprite")
        _ui.OpenRewardRoot.reward.item_root[i].score = _ui.OpenRewardRoot.reward.item_root[i].btn:Find("num"):GetComponent("UILabel")
        _ui.OpenRewardRoot.reward.item_root[i].ready = _ui.OpenRewardRoot.reward.item_root[i].btn:Find("ShineItem")
    end
    _ui.OpenRewardRoot.reward.myscore = transform:Find("Container/bg_frane/bg_rewards/text"):GetComponent("UILabel")
    _ui.OpenRewardRoot.reward.slider = transform:Find("Container/bg_frane/bg_rewards/bg_array/bg_frame/bg_slider"):GetComponent("UISlider")



    local purchase_global_data = TableMgr:GetGlobalData(100167)
    _ui.purchase_ids = {}
    if purchase_global_data ~= nil then
        local id_str = string.split(purchase_global_data.value,",")
        if id_str ~= nil then
            for i =1,#id_str do
                print("purchase_ids",i,tonumber(id_str[i]))
                _ui.purchase_ids[i] = tonumber(id_str[i])
            end
        end
    end
    SetupPurchase()
    SetupReward()
end

function LoadUI()
    local mask = transform:Find("mask")
    SetClickCallback(mask.gameObject, function()
        CloseAll()
        ActivityAll.CloseAll()
    end)
    
    _ui.help_btn = transform:Find("Container/bg_frane/btn_help")
    _ui.state_title_time = transform:Find("Container/bg_frane/bg_desc/title_time"):GetComponent("UILabel")
    _ui.state_time = transform:Find("Container/bg_frane/bg_desc/text_time"):GetComponent("UILabel")
    _ui.state_Close_second_root = transform:Find("Container/bg_frane/bg_topplayer")
    _ui.state_Close_first_root = transform:Find("Container/bg_frane/bg_rewards1")
    _ui.state_Open_reward = transform:Find("Container/bg_frane/bg_rewards")
    _ui.state_Btns = {}
    _ui.state_Btns[1]= transform:Find("Container/bg_frane/button"):GetComponent("UIButton")


    UIUtil.SetBtnEnable(_ui.state_Btns[1] ,"btn_2", "btn_4", _ui.slaughter_data.term ~= 1)
    

    SetClickCallback(_ui.help_btn.gameObject, function(go)
        GOV_Help.Show(GOV_Help.HelpModeType.ATK)
    end)   

    SetClickCallback(_ui.state_Btns[1].gameObject, function(go)
        --历届
        if _ui.slaughter_data.term ~= 1 then
            PVP_ATK_DisRank.Show()
        else
            FloatText.ShowOn(_ui.state_Btns[1].gameObject,TextMgr:GetText("PVP_ATK_Activity_ui14"))
        end
    end)    
    _ui.state_Btns[2] = transform:Find("Container/bg_frane/button (1)"):GetComponent("UIButton")
    SetClickCallback(_ui.state_Btns[2].gameObject, function(go)
        RebelArmyAttackrank.ShowATK()
    end)      
    _ui.state_Btns[3] = transform:Find("Container/bg_frane/button (2)"):GetComponent("UIButton")
    UIUtil.SetBtnEnable(_ui.state_Btns[3] ,"btn_2", "btn_4", _ui.slaughter_data.term ~= 1)
    SetClickCallback(_ui.state_Btns[3].gameObject, function(go)
        --历届
        if _ui.slaughter_data.term ~= 1 then
            PVP_ATK_DisRank.Show()
        else
            FloatText.ShowOn(_ui.state_Btns[3].gameObject,TextMgr:GetText("PVP_ATK_Activity_ui14"))
        end
    end)      

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)    

	UpdateRewardState()
 
    
	if not hasVisited then
		hasVisited = true
		MainCityUI.UpdateActivityAllNotice(ACTIVITY_ID)
	end    
end

function UpdateRewardState()

    local time = 0
    if _ui.slaughter_data.isOpen then
        _ui.state_title_time.text = TextMgr:GetText("RebelArmyAttack_ui3")
        _ui.state_Btns[1].gameObject:SetActive(true)
        _ui.state_Btns[2].gameObject:SetActive(true)
        _ui.state_Btns[3].gameObject:SetActive(false)
        SetupOpenReward()
        _ui.state_Close_second_root.gameObject:SetActive(false)
        _ui.state_Close_first_root.gameObject:SetActive(false)
        _ui.state_Open_reward.gameObject:SetActive(true)
        time = _ui.slaughter_data.endTime
    else
        _ui.state_title_time.text = TextMgr:GetText("RebelArmyAttack_ui2")
        _ui.state_Btns[1].gameObject:SetActive(false)
        _ui.state_Btns[2].gameObject:SetActive(false)
        _ui.state_Btns[3].gameObject:SetActive(true)
        _ui.state_Close_second_root.gameObject:SetActive(false)
        _ui.state_Close_first_root.gameObject:SetActive(false)
        _ui.state_Open_reward.gameObject:SetActive(false)        
        if _ui.slaughter_data.term == 1 then
            SetupCloseFirst()
            _ui.state_Close_first_root.gameObject:SetActive(true)
        else
            SetupCloseSecond()
            _ui.state_Close_second_root.gameObject:SetActive(true)
        end
        time = _ui.slaughter_data.startTime
    end
    CountDown.Instance:Add("ATK_State_Time", time, function(t)
        _ui.state_time.text = t
        --[[
        if time <= Serclimax.GameTime.GetSecTime() then
            CountDown.Instance:Remove("ATK_State_Time")
            if _ui.slaughter_data.isOpen then
                CloseAll()
                ActivityAll.Hide()
            end            
            
        end
        --]]
    end)  

end

function Awake()
    ActiveSlaughterData.AddListener(LoadUI)
end


function Start()

end

function Close()
    ActiveSlaughterData.RemoveListener(LoadUI)
    CountDown.Instance:Remove("ATK_State_Time")
    CountDown.Instance:Remove("ATK_PurchaseTime")
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()    
    _ui = nil
end

function Show()
    _ui= {}
    _ui.slaughter_data = ActiveSlaughterData.GetData()
    Global.OpenUI(_M)
    LoadUI()
end

module("ClimbReward", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String
local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local Common_pb = require("Common_pb")
local _ui = nil
local levelId
function Hide()
    Global.CloseUI(_M)
end

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

function ConditionDes(id)
	local condition = TableMgr:GetClimbCondition(id)
    if condition ~= nil then
        local cstr = ""
        if condition.type == 1 or  condition.type == 6 then
            if condition.type == 1 then
                cstr = System.String.Format( TextMgr:GetText(condition.description), condition.arg1)
            else
                cstr = System.String.Format( TextMgr:GetText(condition.description),condition.arg1)
            end
            
        elseif condition.type == 2 or  condition.type == 3 or  condition.type == 4 or  condition.type == 5 or
        condition.type == 7 or  condition.type == 8 or  condition.type == 10
        then
            if condition.type == 2 then
                local build_data = TableMgr:GetBuildingData(condition.arg1)
                cstr = System.String.Format( TextMgr:GetText(condition.description),TextMgr:GetText(build_data.name),condition.arg2)
            elseif condition.type == 8 then 
                cstr = System.String.Format( TextMgr:GetText(condition.description),condition.arg1,TextMgr:GetText("TabName_"..condition.arg2))
            elseif condition.type == 10 then
                cstr = System.String.Format( TextMgr:GetText(condition.description),TextMgr:GetText("Tec_"..condition.arg1.."_name"),condition.arg2)
            else
                cstr = System.String.Format( TextMgr:GetText(condition.description),condition.arg1,condition.arg2)
            end            
            
        elseif condition.type == 9 then
            cstr = System.String.Format( TextMgr:GetText(condition.description),condition.arg1,condition.arg2,TextMgr:GetText("TabName_"..condition.arg3))
        end
        return cstr
    else
        return ""
    end
end

function FillStarDesAndState(index,des,state)
    local spriteName = "icon_star"
    if not state then
        spriteName = "icon_star_hui"
    end
    _ui.star[index].sprite.spriteName = spriteName
    _ui.star[index].des.text = des
end

function LoadUI()	
    local totalPower = 0
    local battleData = TableMgr:GetClimbLevel4Id(levelId)
    local rewardData = TableMgr:GetClimbReward(battleData.chapterID)
    local rewardList = _ui.rewardList
    local dropId = rewardData.awardShow

    local dropShowList = TableMgr:GetDropShowData(dropId)
    local length = #dropShowList
    for i, v in ipairs(rewardList) do
        if i > length then
            v.item.gameObject:SetActive(false)
            v.hero.transform.gameObject:SetActive(false)
        else
            local dropShowData = dropShowList[i]
            local contentType = dropShowData.contentType
            local contentId = dropShowData.contentId
            local item = v.item
            local hero = v.hero
            item.gameObject:SetActive(contentType == 1 or contentType == 4)
            hero.transform.gameObject:SetActive(contentType == 3)
            if contentType == 1 then
                local itemData = TableMgr:GetItemData(contentId)
                UIUtil.LoadItem(item, itemData, dropShowData.contentNumber)
                v.name = TextUtil.GetItemName(itemData)
                v.description = TextUtil.GetItemDescription(itemData)
            elseif contentType == 4 then
				local soldierData = TableMgr:GetBarrackData(contentId, dropShowData.level)
				UIUtil.LoadSoldier(item , soldierData , dropShowData.contentNumber)
				v.name = TextMgr:GetText(soldierData.SoldierName)
                v.description = TextMgr:GetText(soldierData.SoldierDes)
			else
                local heroData = TableMgr:GetHeroData(contentId)
                local heroMsg = Common_pb.HeroInfo() 
                heroMsg.star = dropShowData.star
                heroMsg.level = dropShowData.level
                heroMsg.num = dropShowData.contentNumber
                HeroList.LoadHero(hero, heroMsg, heroData)
                v.name = TextMgr:GetText(heroData.nameLabel)
                v.description = TextMgr:GetText(heroData.description)
            end
            local ShowTooltip = function(go)
                if go == _ui.tipObject then
                    _ui.tipObject = nil
                else
                    _ui.tipObject = go
                    Tooltip.ShowItemTip({name = v.name, text = v.description})
                end
            end
            SetClickCallback(item.gameObject, ShowTooltip)
            SetClickCallback(hero.btn.gameObject, ShowTooltip)
        end
    end	
    
    local order = TableMgr:GetClimbDataOrder(battleData.ClimbChapterId,battleData.id)
    
    _ui.btn_allDone = false
    local climb_info = ClimbData.GetClimbInfo()
    local state1 = false
    local state2 = false
    local state3 = false 
    local take  =false
    local climb_quset = ClimbData.GetQuestData()
    if climb_quset ~= nil then
        if climb_quset[battleData.chapterID] ~= nil then
            local conditions = {}
            if climb_quset[battleData.chapterID].conditions ~= nil then
                state1 = climb_quset[battleData.chapterID].conditions[rewardData.Condition1] ~= nil 
                state2 = climb_quset[battleData.chapterID].conditions[rewardData.Condition2] ~= nil 
                state3 = climb_quset[battleData.chapterID].conditions[rewardData.Condition3] ~= nil 
                take = climb_quset[battleData.chapterID].take
            end
        end
    end
    local des1 = ConditionDes(rewardData.Condition1)   
    FillStarDesAndState(1,des1,state1)
    local des2 = ConditionDes(rewardData.Condition2)   
    FillStarDesAndState(2,des2,state2)
    local des3 = ConditionDes(rewardData.Condition3)   
    FillStarDesAndState(3,des3,state3)    
    if state1 and state2 and state3 then
        _ui.btn_allDone = true
    end
    UIUtil.SetBtnEnable(_ui.btn ,"union_button1", "union_button1_un",not take and _ui.btn_allDone)

    SetClickCallback(_ui.btn.gameObject,function()
        if take or not _ui.btn_allDone then
            FloatText.Show(TextMgr:GetText("SectionRewards_ui4"), Color.white)
            return
        end
        ClimbData.ReqClimbTakeQuestReward(battleData.chapterID,function(msg)
            Hide()
            ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
            ItemListShowNew.SetItemShow(msg)
            GUIMgr:CreateMenu("ItemListShowNew" , false)   
            Climb.ForceRefrushLevel(levelId)          
        end)
	end)  

end



function Awake()
	_ui = {}
    _ui.mask = transform:Find("mask")
	_ui.close = transform:Find("Container/bg_frane/bg_title_left/btn_close")


    SetClickCallback(_ui.close.gameObject,function()
        Hide()
    end)    
    SetClickCallback(_ui.mask.gameObject,function()
        Hide()
	end)   
	
    local rewardList = {}
    for i = 1, 4 do
        local reward = {}
        local item = {}
        local itemTransform = transform:Find(string.format("Container/bg_frane/Grid/Item_CommonNew (%d)", i))
        UIUtil.LoadItemObject(item, itemTransform)

        local heroTransform = transform:Find(string.format("Container/bg_frane/Grid/hero (%d)", i))
        local hero = {}
        HeroList.LoadHeroObject(hero, heroTransform)

        reward.item = item
        reward.hero = hero
        rewardList[i] = reward
    end

    _ui.rewardList = rewardList
    
    _ui.star = {}
    for i=1,3 do
        local star_item = {}
        star_item.sprite = transform:Find(string.format("Container/bg_frane/bg_text/star (%d)", i)):GetComponent("UISprite")
        star_item.des =  transform:Find(string.format("Container/bg_frane/bg_text/star (%d)/title",i)):GetComponent("UILabel")
        _ui.star[i] = star_item
    end
    _ui.btn = transform:Find("Container/bg_frane/button1"):GetComponent("UIButton")
	LoadUI()
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)	
end



function Show(level_id)
	levelId = level_id
	Global.OpenUI(_M)
end

function Close()
	_ui = nil
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()	
end

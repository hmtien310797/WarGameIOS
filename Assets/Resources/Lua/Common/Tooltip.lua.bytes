module("Tooltip", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local armyTipPrefab
local armyTipTransform
function ShowArmyTip(groupId)
    if armyTipPrefab == nil then
        armyTipPrefab = ResourceLibrary.GetUIPrefab("Army/msg_weapon")
    end
    if armyTipTransform == nil then
        armyTipTransform = GameObject.Instantiate(armyTipPrefab).transform
    end
    local uiCamera = UICamera.current
    local current = uiCamera.currentTouch.current
    local root = current:GetComponent("UIRect").root
    armyTipTransform:SetParent(root.transform, false)
    armyTipTransform.gameObject:SetActive(true)
    armyTipWidget = armyTipTransform:Find("bg"):GetComponent("UISprite")
    NGUITools.BringForward(armyTipTransform.gameObject)
    UIUtil.RepositionTooltip(armyTipWidget)

    local groupData = TableMgr:GetGroupData(groupId)
    local unitData = TableMgr:GetUnitData(groupData._UnitGroupUnitId)
    local name = TextUtil.GetUnitName(unitData)
    local bulletCost = groupData._UnitGroupNum * unitData._unitNeedBullet
    local populationCost = groupData._UnitGroupNum * unitData._unitPopulation
    local armyNum = groupData._UnitGroupNum
    local cooldown = groupData._UnitGroupCD
    armyTipTransform:Find("bg/title"):GetComponent("UILabel").text = name
    armyTipTransform:Find("bg/icon_danyao/num"):GetComponent("UILabel").text = bulletCost
    armyTipTransform:Find("bg/icon_renkou/num"):GetComponent("UILabel").text = populationCost
    armyTipTransform:Find("bg/icon_toufangliang/num"):GetComponent("UILabel").text = armyNum
    armyTipTransform:Find("bg/icon_cd/num"):GetComponent("UILabel").text = cooldown
end

function HideArmyTip()
    if armyTipTransform ~= nil then
        armyTipTransform.gameObject:Destroy()
        armyTipTransform = nil
    end
end

function IsArmyTipActive()
    return armyTipTransform ~= nil and armyTipTransform.gameObject.activeSelf
end

local skillTipPrefab
local skillTipTransform
function ShowSkillTip(skillId)
    if skillTipPrefab == nil then
        skillTipPrefab = ResourceLibrary.GetUIPrefab("Hero/msg_skill")
    end
    if skillTipTransform ~= nil then
        skillTipTransform.gameObject:Destroy()
    end
    skillTipTransform = GameObject.Instantiate(skillTipPrefab).transform
    local uiCamera = UICamera.current
    local current = uiCamera.currentTouch.current
    local root = current:GetComponent("UIRect").root
    skillTipTransform:SetParent(root.transform, false)
    skillTipTransform.gameObject:SetActive(true)
    skillTipWidget = skillTipTransform:Find("bg"):GetComponent("UISprite")
    NGUITools.BringForward(skillTipTransform.gameObject)
    UIUtil.RepositionTooltip(skillTipWidget)

    local skillData = TableMgr:GetGodSkillData(skillId)
    local name = TextMgr:GetText(skillData.name)
    local energyCost = skillData.cost
    local cooldown = skillData.cooldown
    local description = TextMgr:GetText(skillData.description)

    skillTipTransform:Find("bg/title"):GetComponent("UILabel").text = name
    skillTipTransform:Find("bg/icon_nengliang/num"):GetComponent("UILabel").text = energyCost
    skillTipTransform:Find("bg/icon_cd/num"):GetComponent("UILabel").text = cooldown
    skillTipTransform:Find("bg/Label"):GetComponent("UILabel").text = description
end

function ShowPassiveSkillTip(skillData)
    if skillTipPrefab == nil then
        skillTipPrefab = ResourceLibrary.GetUIPrefab("Hero/msg_skill")
    end
    if skillTipTransform ~= nil then
        skillTipTransform.gameObject:Destroy()
    end
    skillTipTransform = GameObject.Instantiate(skillTipPrefab).transform
    local uiCamera = UICamera.current
    local current = uiCamera.currentTouch.current
    local root = current:GetComponent("UIRect").root
    skillTipTransform:SetParent(root.transform, false)
    skillTipTransform.gameObject:SetActive(true)
    skillTipWidget = skillTipTransform:Find("bg"):GetComponent("UISprite")
    NGUITools.BringForward(skillTipTransform.gameObject)
    UIUtil.RepositionTooltip(skillTipWidget)

    local name = TextMgr:GetText(skillData.SkillName)
    -- local energyCost = skillData.cost
    -- local cooldown = skillData.cooldown
    local description = TextMgr:GetText(skillData.SkillDes)

    skillTipTransform:Find("bg/title"):GetComponent("UILabel").text = name
    skillTipTransform:Find("bg/icon_nengliang/num"):GetComponent("UILabel").text = ""
    skillTipTransform:Find("bg/icon_cd/num"):GetComponent("UILabel").text = ""
    skillTipTransform:Find("bg/Label"):GetComponent("UILabel").text = description
end

function HideSkillTip()
    if skillTipTransform ~= nil then
        skillTipTransform.gameObject:Destroy()
        skillTipTransform = nil
    end
end

function IsSkillTipActive()
    return skillTipTransform ~= nil and skillTipTransform.gameObject.activeSelf
end

local itemTipPrefab
local equipTipPrefab
local itemTipTransform
function ShowItemTip(itemTip , showType)
	local uiCamera = UICamera.current
	local current = uiCamera.currentTouch.current
	local root = current:GetComponent("UIRect").root

	if showType and showType == "equipTips" then
		if equipTipPrefab == nil then
			equipTipPrefab = ResourceLibrary.GetUIPrefab("equip/Equip_tips")
		end
		if itemTipTransform ~= nil then
			itemTipTransform.gameObject:Destroy()
        end
		itemTipTransform = GameObject.Instantiate(equipTipPrefab).transform
		itemTipWidget = itemTipTransform:Find("bg"):GetComponent("UISprite")
		
		itemTipTransform:Find("bg/item_equip"):GetComponent("UISprite").spriteName = "bg_item" .. itemTip.BaseData.quality
		itemTipTransform:Find("bg/item_equip/Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("item/" , itemTip.BaseData.icon)
		itemTipTransform:Find("bg/item_equip/Sprite"):GetComponent("UISprite").gameObject:SetActive(false)
		itemTipTransform:Find("bg/item_equip/num"):GetComponent("UILabel").text = "100/100"
		itemTipTransform:Find("bg/item_equip/name"):GetComponent("UILabel").text = TextMgr:GetText(itemTip.BaseData.name)
		local tipTable = itemTipTransform:Find("bg/Scroll View/Table"):GetComponent("UITable")
        local gathers = string.split(itemTip.BaseData.gather , ":")
        if gathers[1] == "99" then
            if string.find(gathers[2], ";") ~= nil then
                gathers = string.split(gathers[2], ";")
            else
                gathers = {gathers[2]}
            end
			for i=1 , #gathers do
				if i <= tipTable.transform.childCount then
					tipTable.transform:GetChild(i - 1).gameObject:SetActive(true)
					tipTable.transform:GetChild(i - 1):GetComponent("UILabel").text = TextMgr:GetText(gathers[i])
				end
			end
		end
		
		UIUtil.SetClickCallback(itemTipTransform:Find("mask").gameObject, function()
			Tooltip.HideItemTip()
		end)
    elseif showType and showType == "otherEquipTips" then
        local item = {}
        local _ui = {}
        local index = 0 
        if equipTipPrefab == nil then
            equipTipPrefab = ResourceLibrary.GetUIPrefab("equip/Other_Equip_tips")
        end
        if itemTipTransform ~= nil then
           itemTipTransform.gameObject:Destroy()
        end 
        itemTipTransform = GameObject.Instantiate(equipTipPrefab).transform       
        itemTipTransform:Find("back/equip01 (1)"):GetComponent("UISprite").spriteName = "bg_item" .. itemTip.BaseData.quality
        itemTipTransform:Find("back/equip01 (1)/Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("item/" , itemTip.BaseData.icon)
        itemTipWidget = itemTipTransform:Find("back"):GetComponent("UISprite")
        _ui.grid = itemTipTransform:Find("back/Grid"):GetComponent("UIGrid")
        _ui.itemList = itemTipTransform:Find("back/Grid/Container")
        _ui.level = itemTipTransform:Find("back/equip01 (1)/level")
        _ui.level.gameObject:SetActive(itemTip.BaseData.itemlevel > 0)
        itemTipTransform:Find("back/desc"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText(itemTip.BaseData.description) , itemTip.BaseData.itemlevel)
        itemTipTransform:Find("back/type"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText("equip_ui53") , TextMgr:GetText(itemTip.EquipData.EquipType))
        itemTipTransform:Find("back/equip01 (1)/level/num"):GetComponent("UILabel").text = itemTip.BaseData.itemlevel
        local maxData = EquipData.GetMaxEquipDataByID(itemTip.BaseData.id)
        local index = 0
        for i, v in ipairs(itemTip.BaseBonus) do
            if tonumber(v.BonusType) == nil or tonumber(v.BonusType) > 0 or v.Attype > 0 then
                index = index + 1
                local item = nil 
                if i <= _ui.grid.transform.childCount then
                    item = _ui.grid.transform:GetChild(i - 1).transform
                else
                    item = NGUITools.AddChild(_ui.grid.gameObject, _ui.itemList.gameObject).transform
                end
                item:Find("Label1"):GetComponent("UILabel").text = TextMgr:GetText(TableMgr:GetEquipTextDataByAddition(v.BonusType, v.Attype))
                item:Find("Label2"):GetComponent("UILabel").text = System.String.Format("{0:F}" , v.Value) .. (Global.IsHeroPercentAttrAddition(v.Attype) and "%" or "")
                item:Find("Label3"):GetComponent("UILabel").text = "(" .. TextMgr:GetText("equip_max_text") .. System.String.Format("{0:F}" , maxData.BaseBonus[i].Value) .. (Global.IsHeroPercentAttrAddition(maxData.BaseBonus[i].Attype) and "%" or "") .. ")"
            end
        end
        UIUtil.SetClickCallback(itemTipTransform:Find("mask").gameObject, function()
			Tooltip.HideItemTip()
		end)
	else
		if itemTipPrefab == nil then
			itemTipPrefab = ResourceLibrary.GetUIPrefab("ChapterInfo/item_msg")
		end
		if itemTipTransform ~= nil then
			itemTipTransform.gameObject:Destroy()
		end
		itemTipTransform = GameObject.Instantiate(itemTipPrefab).transform
		itemTipWidget = itemTipTransform:Find("bg_item_msg"):GetComponent("UISprite")

		itemTipTransform:Find("bg_item_msg/name_item"):GetComponent("UILabel").text = itemTip.name
		itemTipTransform:Find("bg_item_msg/num_item"):GetComponent("UILabel").text = itemTip.number
		itemTipTransform:Find("bg_item_msg/text_item"):GetComponent("UILabel").text = itemTip.text

		UIUtil.SetClickCallback(itemTipTransform.gameObject, function()
			Tooltip.HideItemTip()
		end)
	end
	
	itemTipTransform:SetParent(root.transform, false)
	itemTipTransform.gameObject:SetActive(true)
		
    NGUITools.BringForward(itemTipTransform.gameObject)
    UIUtil.RepositionTooltip(itemTipWidget)
end

function HideItemTip()
    if itemTipTransform ~= nil then
        itemTipTransform.gameObject:Destroy()
        itemTipTransform = nil
    end
end



local uiStrongHoldBufftip

function ShowStrongHoldBufftip(testData)
	testData = testData or 
	{
		buffTitle = "阿斯顿节" , 
		buffDes = "适当放宽后阿适当放宽后阿适当放宽后阿适当放宽后阿适当放宽后阿适当放宽后阿适当放宽后" , 
		--[[actList = {31503 , 3601 , 3402}]] actList = {3431 , 15012 , 27106,27107,27108,27109}, actListCount = {[3431]=1 ,[15012] = 2 , [27106] = 3,[27107] = 4, [27108] = 5, [27109] = 6},
		buffTip = false
	}

	local uiCamera = UICamera.current
	local current = uiCamera.currentTouch.current
	local root = current:GetComponent("UIRect").root

	if not uiStrongHoldBufftip then
		uiStrongHoldBufftip = {}
		uiStrongHoldBufftip.gameObject = GameObject.Instantiate(ResourceLibrary.GetUIPrefab("TileInfo/bg_tipsdetail"))
        uiStrongHoldBufftip.transform = uiStrongHoldBufftip.gameObject.transform
		
		uiStrongHoldBufftip.name = uiStrongHoldBufftip.transform:Find("bg/title"):GetComponent("UILabel")
        uiStrongHoldBufftip.description = uiStrongHoldBufftip.transform:Find("bg/Table/des"):GetComponent("UILabel")
        uiStrongHoldBufftip.table = uiStrongHoldBufftip.transform:Find("bg/Table"):GetComponent("UITable")
        uiStrongHoldBufftip.buffshow = uiStrongHoldBufftip.transform:Find("bg/Table/buffshow")
        --uiStrongHoldBufftip.buffshow01 = uiStrongHoldBufftip.transform:Find("Table/buffshow/buff")
        --uiStrongHoldBufftip.buffshow02 = uiStrongHoldBufftip.transform:Find("Table/buffshow/buff (1)")
		
        uiStrongHoldBufftip.reward = uiStrongHoldBufftip.transform:Find("bg/Table/reward")
	end
	
	if testData.buffTitle ~= nil then
		uiStrongHoldBufftip.name.text = testData.buffTitle
	end
	if testData.buffDes ~= nil then
		uiStrongHoldBufftip.description.text = testData.buffDes
	end
	if testData.actList ~= nil then
		uiStrongHoldBufftip.buffshow.gameObject:SetActive(testData.buffTip)
		uiStrongHoldBufftip.reward.gameObject:SetActive(not testData.buffTip)
		
		if testData.buffTip then
			local listTrf = uiStrongHoldBufftip.buffshow
			local actCount = 0
			for _ , v in pairs(testData.actList) do
				local baseData = TableMgr:GetSlgBuffData(v)
				if baseData and actCount < listTrf.childCount then
					local buffItemtrf = listTrf:GetChild(actCount)
					buffItemtrf.gameObject:SetActive(true)
					--buffItemtrf:Find("icon"):GetComponent("UISprite").spriteName = baseData.icon
					buffItemtrf:Find("name"):GetComponent("UILabel").text = TextUtil.GetSlgBuffTitle(baseData)
					buffItemtrf:Find("data"):GetComponent("UILabel").text = TextUtil.GetSlgBuffDescription(baseData)
					buffItemtrf:Find("icon/Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", baseData.icon)
					actCount = actCount + 1
				end
			end
			
			for i=actCount , listTrf.childCount - 1 do
				listTrf:GetChild(i).gameObject:SetActive(false)
			end
			
		else
			local listTrf = uiStrongHoldBufftip.reward
			local actCount = 0
			for _ , v in pairs(testData.actList) do
				local baseData = TableMgr:GetItemData(v)
				if baseData and actCount < listTrf.childCount then
					local rewardItemTrf = listTrf:GetChild(actCount)
					rewardItemTrf.gameObject:SetActive(true)
					local rewardicon = rewardItemTrf:Find("item"):GetComponent("UITexture")
					rewardicon.mainTexture = ResourceLibrary:GetIcon("Item/", baseData.icon)
					
					local rewardnum = rewardItemTrf:Find("num"):GetComponent("UILabel")
					if testData.actListCount ~= nil and testData.actListCount[v] ~= nil then
						rewardnum.text = testData.actListCount[v]
					else
						rewardnum.gameObject:SetActive(false)
					end
					--rewardnum.gameObject:SetActive(false)
					
					local rewardbox = rewardItemTrf:Find("btn_item"):GetComponent("UISprite")
					rewardbox.spriteName = "bg_item" .. baseData.quality
					
					local itemlvTrf = rewardItemTrf:Find("bg_num")
					local itemlv = itemlvTrf:Find("txt_num"):GetComponent("UILabel")
					itemlvTrf.gameObject:SetActive(true)
					if baseData.showType == 1 then
						itemlv.text = Global.ExchangeValue2(baseData.itemlevel)
					elseif baseData.showType == 2 then
						itemlv.text = Global.ExchangeValue1(baseData.itemlevel)
					elseif baseData.showType == 3 then
						itemlv.text = Global.ExchangeValue3(baseData.itemlevel)
					else 
						itemlvTrf.gameObject:SetActive(false)
					end
					
					actCount = actCount + 1
				end
			end
			
			for i=actCount , listTrf.childCount - 1 do
				listTrf:GetChild(i).gameObject:SetActive(false)
			end
			
		end
	end 

	uiStrongHoldBufftip.table.repositionNow = true
	uiStrongHoldBufftip.transform:SetParent(root.transform, false)
    uiStrongHoldBufftip.gameObject:SetActive(true)
	
	NGUITools.BringForward(uiStrongHoldBufftip.gameObject)
    UIUtil.RepositionTooltip(uiStrongHoldBufftip.transform:Find("bg"):GetComponent("UISprite"))
end

function HideStrongHoldBufftip()
    if uiStrongHoldBufftip then
        uiStrongHoldBufftip.gameObject:Destroy()
        uiStrongHoldBufftip = nil
    end
end


local itemSourcePrefab
local uiItemSource
local uiItemSourceCallback

local function UpdateUIItemSource()
    local numNeeded = uiItemSource.numNeeded
    local numOwned = ItemListData.GetItemCountByBaseId(uiItemSource.itemData.id)
    uiItemSource.item.num.text = numNeeded and string.make_fraction(numOwned, numNeeded) or numOwned
end

function ShowItemSource(itemData, numNeeded, callback)
    local sourceInfos = string.msplit(itemData.gather, ",", ":", "-")
    local methodType = tonumber(sourceInfos[1][1])

    if itemSourcePrefab == nil then
        itemSourcePrefab = ResourceLibrary.GetUIPrefab("Hero/BadgeInfoNew_3")
    end

    if not uiItemSource then
        uiItemSource = {}

        uiItemSource.gameObject = GameObject.Instantiate(itemSourcePrefab)
        uiItemSource.transform = uiItemSource.gameObject.transform
        
        uiItemSource.background = uiItemSource.transform:Find("Container/Background").gameObject
        uiItemSource.label = uiItemSource.transform:Find("Container/Background/Label"):GetComponent("UILabel")
        uiItemSource.tips = uiItemSource.transform:Find("Container/Background/Tips"):GetComponent("UILabel")
        uiItemSource.btn_go = uiItemSource.transform:Find("Container/Background/Go Button").gameObject
        
        uiItemSource.item = {}
        uiItemSource.item.transform = uiItemSource.transform:Find("Container/Background/Item")
        uiItemSource.item.gameObject = uiItemSource.item.transform.gameObject
        uiItemSource.item.icon = uiItemSource.item.transform:Find("Icon"):GetComponent("UITexture")
        uiItemSource.item.frame = uiItemSource.item.transform:Find("Frame"):GetComponent("UISprite")
        uiItemSource.item.name = uiItemSource.item.transform:Find("Name"):GetComponent("UILabel")
        uiItemSource.item.num = uiItemSource.item.transform:Find("Num"):GetComponent("UILabel")

        uiItemSource.itemData = itemData
        uiItemSource.numNeeded = numNeeded
    end

    uiItemSource.transform:SetParent(UICamera.current.currentTouch.current:GetComponent("UIRect").root.transform, false)
    uiItemSource.gameObject:SetActive(true)

    uiItemSource.methodType = methodType

    uiItemSource.item.icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
    uiItemSource.item.frame.spriteName = "bg_item" .. itemData.quality
    uiItemSource.item.name.text = TextUtil.GetItemName(itemData)

    if methodType == 3 then
        local sLevels = sourceInfos[1][2]
        --local targetRebelLevel = tonumber(sourceInfos[2][2])
        local targetRebelLevel = tonumber(sLevels[2])

        uiItemSource.targetRebelLevel = targetRebelLevel
        uiItemSource.label.text = System.String.Format(TextMgr:GetText("heronew_21"), sLevels[1], sLevels[2])
        uiItemSource.tips.text = System.String.Format(TextMgr:GetText("heronew_43"), targetRebelLevel)

        uiItemSource.btn_go:SetActive(true)

        UIUtil.SetClickCallback(uiItemSource.btn_go, function()
            if uiItemSource.methodType == 3 then
                MapSearch.Show(1, math.min(RebelWantedData.GetUnlockedLevel(), uiItemSource.targetRebelLevel), function() --
                    if uiItemSourceCallback then
                        uiItemSourceCallback()
                        uiItemSourceCallback = nil
                    end

                    HideItemSource()
                end)
            end
        end)
    else
        uiItemSource.label.text = ""
        uiItemSource.tips.text = "[ff0000]" .. TextMgr:GetText("heronew_41")
        
        uiItemSource.btn_go:SetActive(false)
    end

    UpdateUIItemSource()

    uiItemSourceCallback = callback

    EventDispatcher.Bind(ItemListData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(itemInfo, change)
        if itemInfo.baseid == uiItemSource.itemData.id then
            UpdateUIItemSource()
        end
    end)

    NGUITools.BringForward(uiItemSource.gameObject)
    UIUtil.RepositionTooltip(uiItemSource.transform:Find("Container"):GetComponent("UIWidget"))
end

function HideItemSource()
    if uiItemSource ~= nil then
        EventDispatcher.Unbind(ItemListData.OnDataChange(), _M)

        uiItemSource.gameObject:Destroy()
        uiItemSource = nil
    end
end


local uiPassiveSkill
local function UpdatePassiveSkillTooltip()
    local heroInfo = uiPassiveSkill.heroInfo
    local unlockLevel = uiPassiveSkill.unlockLevel
    local skillData = uiPassiveSkill.skillData

    if unlockLevel > heroInfo.star then
        local heroInfo_skillUnlocked = GeneralData.Duplicate(heroInfo)
        heroInfo_skillUnlocked.star = unlockLevel
        heroInfo_skillUnlocked.grade = 1
        
        uiPassiveSkill.description.text = System.String.Format(TextMgr:GetText(skillData.SkillDes), GeneralData.GetAttributes(heroInfo_skillUnlocked, skillData.ArmyType1, skillData.AttrType1)[uiPassiveSkill.skillData.ActiveCondition])
        uiPassiveSkill.locked.label.text = System.String.Format(TextMgr:GetText("heronew_39"), unlockLevel)
        uiPassiveSkill.locked.transform.localScale = Vector3.one
    else
        uiPassiveSkill.description.text = System.String.Format(TextMgr:GetText(skillData.SkillDes), GeneralData.GetAttributes(heroInfo, skillData.ArmyType1, skillData.AttrType1)[uiPassiveSkill.skillData.ActiveCondition])
        uiPassiveSkill.locked.transform.localScale = Vector3.zero
    end
end

function ShowPassiveSkill(heroInfo, skillIndex)
    if not uiPassiveSkill then
        uiPassiveSkill = {}

        uiPassiveSkill.gameObject = GameObject.Instantiate(ResourceLibrary.GetUIPrefab("Hero/passiveSkillTooltip"))
        uiPassiveSkill.transform = uiPassiveSkill.gameObject.transform
        
        uiPassiveSkill.background = uiPassiveSkill.transform:Find("Container/Background").gameObject
        uiPassiveSkill.name = uiPassiveSkill.transform:Find("Container/Background/Name"):GetComponent("UILabel")
        uiPassiveSkill.description = uiPassiveSkill.transform:Find("Container/Background/Description"):GetComponent("UILabel")
        
        uiPassiveSkill.locked = {}
        uiPassiveSkill.locked.transform = uiPassiveSkill.transform:Find("Container/Background/Tips")
        uiPassiveSkill.locked.gameObject = uiPassiveSkill.locked.transform.gameObject
        uiPassiveSkill.locked.label = uiPassiveSkill.locked.transform:GetComponent("UILabel")
    end

    uiPassiveSkill.transform:SetParent(UICamera.current.currentTouch.current:GetComponent("UIRect").root.transform, false)
    uiPassiveSkill.gameObject:SetActive(true)

    local skillData = TableMgr:GetPassiveSkillData(tonumber(string.split(TableMgr:GetHeroData(heroInfo.baseid).showpassiveskill, ";")[skillIndex]))
    
    uiPassiveSkill.heroInfo = heroInfo
    uiPassiveSkill.unlockLevel = skillIndex
    uiPassiveSkill.skillData = skillData

    uiPassiveSkill.name.text = TextMgr:GetText(skillData.SkillName)

    UpdatePassiveSkillTooltip()

    EventDispatcher.Bind(GeneralData.OnGeneralStarChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(heroInfo, change)
        if heroInfo.baseid == uiPassiveSkill.heroInfo.baseid then
            UpdatePassiveSkillTooltip()
        end
    end)

    EventDispatcher.Bind(GeneralData.OnGeneralGradeChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(heroInfo, change)
        if heroInfo.baseid == uiPassiveSkill.heroInfo.baseid then
            UpdatePassiveSkillTooltip()
        end
    end)

    NGUITools.BringForward(uiPassiveSkill.gameObject)
    UIUtil.RepositionTooltip(uiPassiveSkill.transform:Find("Container"):GetComponent("UIWidget"))
end

function HidePassiveSkill()
    if uiPassiveSkill ~= nil then
        EventDispatcher.Unbind(GeneralData.OnGeneralStarChange(), _M)
        EventDispatcher.Unbind(GeneralData.OnGeneralGradeChange(), _M)

        uiPassiveSkill.gameObject:Destroy()
        uiPassiveSkill = nil
    end
end

local uiAttribute

local ATTRIBUTE_NAME = { [103] = "heronew_33",
                         [1102] = "heronew_31", }
local ATTRIBUTE_DESCRIPTION = { [103] = "heronew_34",
                                [1102] = "heronew_32", }
function ShowAttributeTooltip(attributeID)
    if not uiAttribute then
        uiAttribute = {}

        uiAttribute.gameObject = GameObject.Instantiate(ResourceLibrary.GetUIPrefab("Hero/passiveSkillTooltip"))
        uiAttribute.transform = uiAttribute.gameObject.transform
        
        uiAttribute.background = uiAttribute.transform:Find("Container/Background").gameObject
        uiAttribute.name = uiAttribute.transform:Find("Container/Background/Name"):GetComponent("UILabel")
        uiAttribute.description = uiAttribute.transform:Find("Container/Background/Description"):GetComponent("UILabel")
    
        uiAttribute.transform:Find("Container/Background/Tips").gameObject:SetActive(false)
    end

    uiAttribute.transform:SetParent(UICamera.current.currentTouch.current:GetComponent("UIRect").root.transform, false)
    uiAttribute.gameObject:SetActive(true)

    uiAttribute.name.text = TextMgr:GetText(ATTRIBUTE_NAME[attributeID])
    uiAttribute.description.text = TextMgr:GetText(ATTRIBUTE_DESCRIPTION[attributeID])

    NGUITools.BringForward(uiAttribute.gameObject)
    UIUtil.RepositionTooltip(uiAttribute.transform:Find("Container"):GetComponent("UIWidget"))
end

function HideAttributeTooltip()
    if uiAttribute ~= nil then
        uiAttribute.gameObject:Destroy()
        uiAttribute = nil
    end
end


local uiMobaBufftip
function ShowMobaBuffTips(buffid)
	local uiCamera = UICamera.current
	local current = uiCamera.currentTouch.current
	local root = current:GetComponent("UIRect").root
	
	if not uiMobaBufftip then
		uiMobaBufftip = {}
		uiMobaBufftip.gameObject = GameObject.Instantiate(ResourceLibrary.GetUIPrefab("Moba/MobaBuffTips"))
        uiMobaBufftip.transform = uiMobaBufftip.gameObject.transform
		
		uiMobaBufftip.bg = uiMobaBufftip.transform:Find("bg"):GetComponent("UIWidget")
		uiMobaBufftip.name = uiMobaBufftip.transform:Find("bg/Name"):GetComponent("UILabel")
        uiMobaBufftip.description = uiMobaBufftip.transform:Find("bg/Description"):GetComponent("UILabel")
        uiMobaBufftip.grid = uiMobaBufftip.transform:Find("bg/Grid"):GetComponent("UIGrid")
        uiMobaBufftip.textItem = uiMobaBufftip.transform:Find("bg/text")
        uiMobaBufftip.itemheight = uiMobaBufftip.textItem:GetComponent("UIWidget").height
	end
	
	local baseData = TableMgr:GetSlgBuffData(buffid)
	uiMobaBufftip.name.text = TextMgr:GetText(baseData.title)
	uiMobaBufftip.description.text = TextMgr:GetText(baseData.description)
	local seq =1
	local buff_values = nil--MilitaryRank.Moba_GetEffectDataToBuffValues(baseData.Effect)

	uiMobaBufftip.bg.height = 100
	if buff_values ~= nil then
		for i =1,#buff_values do
			local str = buff_values[i].value
			
			local obj = nil 
			local childCount = uiMobaBufftip.grid.transform.childCount
			if childCount > tonumber(seq-1)  then
				obj = uiMobaBufftip.grid.transform:GetChild(tonumber(seq-1)).gameObject
			else
				obj = NGUITools.AddChild( uiMobaBufftip.grid.gameObject, uiMobaBufftip.textItem.gameObject)
			end 
			
			seq = seq +1

			-- local obj = NGUITools.AddChild( MilitaryRankUI.effectGrid.gameObject,MilitaryRankUI.effectItem.gameObject)
			obj:SetActive(true)
			obj.transform:GetComponent("UILabel").text = TextMgr:GetText(buff_values[i].buff_str)  .. " : " .. str
			
		end
		
		uiMobaBufftip.grid:Reposition()
		uiMobaBufftip.bg.height = uiMobaBufftip.bg.height + (#buff_values) * 30
	end
	
	uiMobaBufftip.grid.repositionNow = true
	uiMobaBufftip.transform:SetParent(root.transform, false)
    uiMobaBufftip.gameObject:SetActive(true)
	
	NGUITools.BringForward(uiMobaBufftip.gameObject)
    UIUtil.RepositionTooltip(uiMobaBufftip.transform:Find("bg"):GetComponent("UISprite"))
end


function HideMobaBuffTips()
    if uiMobaBufftip then
        uiMobaBufftip.gameObject:Destroy()
        uiMobaBufftip = nil
    end
end

local uiCommonTooltip
function Show(title, description, hint)
    Global.LogDebug(_M, "Show", title, description, hint)
    if not uiCommonTooltip then
        uiCommonTooltip = {}

        uiCommonTooltip.gameObject = GameObject.Instantiate(ResourceLibrary.GetUIPrefab("Hero/passiveSkillTooltip"))
        uiCommonTooltip.transform = uiCommonTooltip.gameObject.transform
        
        uiCommonTooltip.background = uiCommonTooltip.transform:Find("Container/Background").gameObject
        uiCommonTooltip.title = uiCommonTooltip.transform:Find("Container/Background/Name"):GetComponent("UILabel")
        uiCommonTooltip.description = uiCommonTooltip.transform:Find("Container/Background/Description"):GetComponent("UILabel")
    
        uiCommonTooltip.hint = {}
        uiCommonTooltip.hint.transform = uiCommonTooltip.transform:Find("Container/Background/Tips")
        uiCommonTooltip.hint.gameObject = uiCommonTooltip.hint.transform.gameObject
        uiCommonTooltip.hint.label = uiCommonTooltip.hint.transform:GetComponent("UILabel")
    end

    uiCommonTooltip.transform:SetParent(UICamera.current.currentTouch.current:GetComponent("UIRect").root.transform, false)
    uiCommonTooltip.gameObject:SetActive(true)

    if title and title ~= "" then
        uiCommonTooltip.title.text = title
        uiCommonTooltip.title.transform.localScale = Vector3.one
    else
        uiCommonTooltip.title.transform.localScale = Vector3.zero
    end

    if description and description ~= "" then
        uiCommonTooltip.description.text = description
        uiCommonTooltip.description.transform.localScale = Vector3.one
    else
        uiCommonTooltip.description.transform.localScale = Vector3.zero
    end

    if hint and hint ~= "" then
        uiCommonTooltip.hint.text = hint
        uiCommonTooltip.hint.transform.localScale = Vector3.one
    else
        uiCommonTooltip.hint.transform.localScale = Vector3.zero
    end

    NGUITools.BringForward(uiCommonTooltip.gameObject)
    UIUtil.RepositionTooltip(uiCommonTooltip.transform:Find("Container"):GetComponent("UIWidget"))
end

function Hide()
    if uiCommonTooltip then
        uiCommonTooltip.gameObject:Destroy()
        uiCommonTooltip = nil
    end
end

function IsItemSourceClicked(go)
    return uiItemSource and (go == uiItemSource.background or go == uiItemSource.btn_go)
end

function IsPassiveSkillClicked(go)
    return uiPassiveSkill and go == uiPassiveSkill.background
end

function IsAttributeTooltipClicked(go)
    return uiAttribute and go == uiAttribute.background
end

function IsClicked(go)
    return uiCommonTooltip and go == uiCommonTooltip.background
end

function IsItemTipActive()
    return itemTipTransform ~= nil and itemTipTransform.gameObject.activeSelf
end

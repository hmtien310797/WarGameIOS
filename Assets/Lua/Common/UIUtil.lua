module("UIUtil", package.seeall)
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local Mathf = Mathf
local Screen = UnityEngine.Screen

--from NGUI UITooltip.cs
function ClampWidgetPosition(widget, position)
	local gameObject = widget.gameObject
	local transform = gameObject.transform
	local size = widget.localSize
	local uiCamera = NGUITools.FindCameraForLayer(gameObject.layer)

	if uiCamera ~= nil then
		position.x = Mathf.Clamp01(position.x / Screen.width)
		position.y = Mathf.Clamp01(position.y / Screen.height)
		
		local activeSize = uiCamera.orthographicSize / transform.parent.lossyScale.y
		local ratio = (Screen.height * 0.5) / activeSize

		local max = Vector2(ratio * size.x / Screen.width, ratio * size.y / Screen.height)

		position.x = Mathf.Min(position.x, 1 - max.x)
		position.y = Mathf.Max(position.y, max.y)

		transform.position = uiCamera:ViewportToWorldPoint(position)
		position = transform.localPosition
		position.x = Mathf.Round(position.x)
		position.y = Mathf.Round(position.y)
		transform.localPosition = position
	else
		if position.x + size.x > Screen.width then
			position.x = Screen.width - size.x
		end
		if position.y - size.y < 0 then
			position.y = size.y
		end

		position.x = position.x - Screen.width * 0.5
		position.y = position.y - Screen.height * 0.5
	end
	transform.localPosition = position
	transform.localSize = size
end

function RepositionTooltip(widget)
	NGUITools.ImmediatelyCreateDrawCalls(widget.gameObject)
	ClampWidgetPosition(widget, UICamera.lastEventPosition)
end

function SetParameter(go, parameter)
	local listener = UIEventListener.Get(go)
	listener.parameter = parameter
end

function GetParameter(go)
	local listener = go:GetComponent("UIEventListener")
	return listener ~= nil and listener.parameter or nil
end

function SetSubmit(go, callback)
	local listener = UIEventListener.Get(go)
	listener.onSubmit = callback
end

function SetClickCallback(go, callback)
	local listener = UIEventListener.Get(go)
	listener.onClick = callback
end

function SetDoubleClickCallback(go, callback)
	local listener = UIEventListener.Get(go)
	listener.onDoubleClick = callback
end

function SetHoverCallback(go, callback)
	local listener = UIEventListener.Get(go)
	listener.onHover = callback
end

function SetPressCallback(go, callback)
	local listener = UIEventListener.Get(go)
	listener.onPress = callback
end

function SetSelectCallback(go, callback)
	local listener = UIEventListener.Get(go)
	listener.onSelect = callback
end

function SetScrollCallback(go, callback)
	local listener = UIEventListener.Get(go)
	listener.onScroll = callback
end

function SetDragStartCallback(go, callback)
	local listener = UIEventListener.Get(go)
	listener.onDragStart = callback
end

function SetDragCallback(go, callback)
	local listener = UIEventListener.Get(go)
	listener.onDrag = callback
end

function SetDragOverCallback(go, callback)
	local listener = UIEventListener.Get(go)
	listener.onDragOver = callback
end

function SetDragOutCallback(go, callback)
	local listener = UIEventListener.Get(go)
	listener.onDragOut = callback
end

function SetDragEndCallback(go, callback)
	local listener = UIEventListener.Get(go)
	listener.onDragEnd = callback
end

function SetDropCallback(go, callback)
	local listener = UIEventListener.Get(go)
	listener.onDrop = callback
end

function SetKeyCallback(go, callback)
	local listener = UIEventListener.Get(go)
	listener.onKey = callback
end

function SetTooltipCallback(go, callback)
	local listener = UIEventListener.Get(go)
	listener.onTooltip = callback
end

function SetActiveCallback(go, callback)
	local listener = UIEventListener.Get(go)
	listener.onActive = callback
end

function ReloadUI(ui)
	GGUIMgr:ReloadUI(ui)
end

function ReloadTopUI(topUI)
	GGUIMgr:ReloadTopUI(topUI)
end

function SetDelegate(object, delegate, func)
    object[delegate] = func
end

function AddDelegate(object, delegate, func)
	if object[delegate] ~= nil then
		object[delegate] = object[delegate] + func
	else
		object[delegate] = func
	end
end

function RemoveDelegate(object, delegate, func)
	if object[delegate] ~= nil then
		object[delegate] = object[delegate] - func
	end
end

--local SliderCorountine = nil
function UIAnimSlider(startValue , addValue , durTime , sliderObj , callbackFunc)
	local SliderCorountine = nil
	local totalExpAdd = 0
	if addValue > 0 then
		local addStep = addValue/durTime
		--startValue = startValue - math.floor(startValue)
		--if SliderCorountine ~= nil then
		--	coroutine.stop(SliderCorountine)
		--end
		SliderCorountine = coroutine.start(function()
			while totalExpAdd < addValue do
				--return startValue
				startValue = startValue + addStep
				totalExpAdd = totalExpAdd + addStep
			
				if math.floor(startValue) > 0 then
					startValue = startValue - math.floor(startValue)
					if callbackFunc ~= nil then
						callbackFunc()
					end
				end
				
				sliderObj.value = startValue
				coroutine.wait(addStep)
			end
		end)
	--else
	--	sliderObj.value = startValue
	--	callbackFunc()
	end
	return SliderCorountine
end


local UIListItemBtnObj
local jumpToFinish = false
function UIListItemShowJumpFinish()
	jumpToFinish = true
end

local function GetRewardItem(itemlist ,itemid)
	if itemlist ~= nil then
		for _ , v in pairs(itemlist) do
			if v.data.baseid == itemid then
				return v
			end
		end
	end
	return nil
end

--适用Bag/item_CommonNew
function LoadItemInfo(item , itemparam , BoxClickCallback,CustomCallBack)
	
	local itemTBData = TableMgr:GetItemData(itemparam.baseid)
	if itemTBData ~= nil then
		if CustomCallBack ~= nil then
			CustomCallBack(item)
		end
		--icon
		local resIcon = item.transform:Find("Texture"):GetComponent("UITexture")
		resIcon.mainTexture = ResourceLibrary:GetIcon("Item/", itemTBData.icon)
	
		if itemTBData.type == 3 then 
			local box = item.transform:Find("btn_box")
			if itemTBData.subtype == 1 or  itemTBData.subtype == 2 then
				box.gameObject:SetActive(true)
				if BoxClickCallback ~= nil then
					SetClickCallback(box.gameObject , BoxClickCallback)
				end
			end
		end
		--itenlevel
		--print("baseid:" .. itemparam.baseid .. "     " .. "show:" .. itemTBData.showType)
		local itemlvTrf = item.transform:Find("num")
		itemlvTrf.gameObject:SetActive(true)
		local itemlv = itemlvTrf:GetComponent("UILabel")
		if itemTBData.showType == 1 then
			itemlv.text = Global.ExchangeValue2(itemTBData.itemlevel)
		elseif itemTBData.showType == 2 then
			itemlv.text = Global.ExchangeValue1(itemTBData.itemlevel)
		elseif itemTBData.showType == 3 then
			itemlv.text = Global.ExchangeValue3(itemTBData.itemlevel)
		else 
			itemlvTrf.gameObject:SetActive(false)
		end
		
		--quality
		local quabox = item.transform:GetComponent("UISprite")
		quabox.spriteName = "bg_item" .. itemTBData.quality
		
		local have = item.transform:Find("have")
		have.gameObject:SetActive(itemparam.count ~= nil and itemparam.count > 1)
		have:GetComponent("UILabel").text = itemparam.count
	end
end

--适用Hero/listitem_hero
function LoadHeroInfo(hero , heroShowData , isIllustrateList)
	local data = TableMgr:GetHeroData(heroShowData.baseid)

    if hero.icon ~= nil then
        hero.icon.mainTexture = ResourceLibrary:GetIcon("Icon/herohead/", data.icon)
    end
	
    --SetNumber(hero.qualityList, data.quality)
    if hero.qualitySprite ~= nil then
        hero.qualitySprite.spriteName = "head"..data.quality
    end
    if hero.nameLabel ~= nil then
        hero.nameLabel.text = TextMgr:GetText(data.nameLabel)
    end

    if hero.levelLabel ~= nil then
        hero.levelLabel.text = heroShowData.level
    end
   -- SetNumber(hero.starList, heroShowData.star)
    if hero.starSprite ~= nil then
        hero.starSprite.width = heroShowData.star * hero.starHeight
    end

	if hero.num ~= nil and not isIllustrateList then
		--if data.expCard then
			hero.num.gameObject:SetActive(heroShowData.count ~= nil and heroShowData.count > 1)
			hero.num:GetComponent("UILabel").text = heroShowData.count
		--else
		--	hero.num.gameObject:SetActive(false)
		--end
	end

	if hero.skillIcon ~= nil then
        local skillId = 0
        local skillLevel = 1
        local skillMsg
        if heroShowData.skill then
        	skillMsg = heroShowData.skill.godSkill
        end
        if skillMsg ~= nil then
            skillId = skillMsg.id
            skillLevel = skillMsg.level
        else
            skillId = tonumber(data.skillId)
        end
        local skillData = TableMgr:GetGodSkillDataByIdLevel(skillId, skillLevel)
        hero.skillIcon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", skillData.iconId)
    end
end

function LoadStarDisplay(rootTransform)
	local stars = {}

	stars.transform = rootTransform
	stars.gameObject = rootTransform.gameObject

	local largeStarsTransform = rootTransform:Find("Large")
	if largeStarsTransform then
		local large = {}

		large.transform = largeStarsTransform
		large.gameObject = largeStarsTransform.gameObject
		large.grid = largeStarsTransform:GetComponent("UIGrid")

		for i = 1, 6 do
			large[i] = largeStarsTransform:GetChild(i - 1):GetComponent("UISprite")
		end

		stars.large = large
	end

	local smallStarsTransform = rootTransform:Find("Small")
	if smallStarsTransform then
		local small = {}

		small.transform = smallStarsTransform
		small.gameObject = smallStarsTransform.gameObject
		small.grid = smallStarsTransform:GetComponent("UIGrid")

		for i = 2, 5 do
			local uiSmallStar = {}

			uiSmallStar.transform = smallStarsTransform:GetChild(i - 2)
			uiSmallStar.gameObject = uiSmallStar.transform.gameObject
			uiSmallStar.icon = uiSmallStar.transform:GetComponent("UISprite")

			small[i] = uiSmallStar
		end

		stars.small = small
	end

	return stars
end

function UpdateStarDisplay(uiStars, star, smallStar)
	for i = 1, 6 do
        uiStars.large[i].spriteName = i <= star and "hero_star" or "hero_star_none"
    end
    uiStars.large.grid:Reposition()

    if uiStars.small then
	    if star ~= 1 and star ~= 6 then
	        for i = 2, 5 do
	        	if i <= star then
	        		local uiSmallStar = uiStars.small[i]

	        		uiSmallStar.gameObject:SetActive(true)
	            	uiSmallStar.icon.spriteName = i <= smallStar and "star2" or "star2_lock"
	            else
	            	uiStars.small[i].gameObject:SetActive(false)
	            end
	        end
	        uiStars.small.grid:Reposition()
	        
	        uiStars.small.gameObject:SetActive(true)
	    else
	        uiStars.small.gameObject:SetActive(false)
	    end
	end
end

function UpdateShardDisplay(uiShard, heroInfo, heroData, heroRule)
	if not heroData then
		heroData = TableMgr:GetHeroData(heroInfo.baseid)
	end

	if not heroRule then
		heroRule = TableMgr:GetRulesDataByStarGrade(heroInfo.star, heroInfo.grade)
	end

    local requiredShardCount
    if heroInfo.uid == 0 then
        requiredShardCount = heroData.chipnum
    else
        requiredShardCount = heroRule.num
    end

    local ownedShardCount = ItemListData.GetItemCountByBaseId(heroData.chipID)

    uiShard.progressBar.value = ownedShardCount / requiredShardCount
    uiShard.num.text = string.format("%d/%d", ownedShardCount, requiredShardCount)

    return ownedShardCount, requiredShardCount
end

function LoadSkillDisplay(rootTransform)
	local uiSkill = {}
	
	uiSkill.transform = rootTransform
    uiSkill.gameObject = rootTransform.gameObject

    uiSkill.name = rootTransform:Find("Name"):GetComponent("UILabel")
    uiSkill.description = rootTransform:Find("Description"):GetComponent("UILabel")
    uiSkill.icon = rootTransform:Find("Icon"):GetComponent("UITexture")
    
    uiSkill.stars = UIUtil.LoadStarDisplay(uiSkill.icon.transform:Find("Stars"))

    uiSkill.btn_detail = rootTransform:Find("Name/Detail Button").gameObject

    uiSkill.details = {}
    uiSkill.details.transform = rootTransform:Find("Detail")
    uiSkill.details.gameObject = uiSkill.details.transform.gameObject

    for i = 1, 5 do
        uiSkill.details[i + 1] = uiSkill.details.transform:GetChild(i):GetComponent("UILabel")
    end

    uiSkill.details.label = uiSkill.details.transform:Find("Label"):GetComponent("UILabel")

    return uiSkill
end

function LoadMailHeroObj(hero, heroTransform)
	hero.transform = heroTransform
    hero.gameObject = heroTransform.gameObject
    hero.lock = heroTransform:Find("lock")
    hero.mask = heroTransform:Find("select")
    hero.icon = heroTransform:Find("head icon"):GetComponent("UITexture")
    hero.btn = heroTransform:Find("head icon"):GetComponent("UIButton")
	
	--将军技能
	hero.skill = {}
	hero.skill.bg = heroTransform:Find("bg_skill")
	if hero.skill.bg ~= nil then
		hero.skill.bgIcon = hero.skill.bg:Find("bg")
		hero.skill.sprIcon = hero.skill.bg:Find("icon_skill")
	end
	--将军数量
	local countTransform = heroTransform:Find("num")
	if countTransform ~= nil then
	    hero.countLabel = countTransform:GetComponent("UILabel")
    end
	--将军头像
	local head = heroTransform:Find("head icon")
	if head ~= nil then
		hero.head = head:GetComponent("UITexture")
		local lvUp = head:Find("txt_lvlpu")
		if lvUp ~= nil then
			hero.levelUp = lvUp
		end
		local empty = head:Find("none_hero")
		if empty ~= nil then
			hero.empty = empty
		end
		--将军品质
		local quality = head:Find("outline")
		if quality ~= nil then
			hero.qualitySprite = quality:GetComponent("UISprite")
		end
	end
	--将军名字
    local nameTransform = heroTransform:Find("name text")
    if nameTransform ~= nil then
        hero.nameLabel = nameTransform:GetComponent("UILabel")
    end
	--将军等级
    hero.levelLabel = heroTransform:Find("level text"):GetComponent("UILabel")
	--将军星级
    hero.starSprite = heroTransform:Find("star"):GetComponent("UISprite")
    if hero.starSprite ~= nil then
        hero.starHeight = hero.starSprite.height
    end
	--将军红点提示
    hero.notice = heroTransform:Find("red dot")
	local skillIconTransform = heroTransform:Find("bg_skill/icon_skill")
	if skillIconTransform ~= nil then
	    hero.skillIcon = skillIconTransform:GetComponent("UITexture")
    end

    local stateBg = heroTransform:Find("occupy")

    if stateBg ~= nil then
        hero.stateBg = stateBg
        local stateList = {}
        stateList.setout = stateBg:Find("chuzhan")
        stateList.defense = stateBg:Find("shoucheng")
        stateList.pve = stateBg:Find("changyong")
        hero.stateList = stateList
    end
    --将军进阶信息
    local badgeBg = heroTransform:Find("advanced")
    if badgeBg ~= nil then
        hero.gradeSprite = badgeBg:Find("advanced bg/icon"):GetComponent("UISprite")
        local badgeList = {}
        LoadBadgeObjectList(badgeList, badgeBg)
        hero.badgeList = badgeList
    end
	--将军经验
	local expBg = heroTransform:Find("bg_exp")
	if expBg ~= nil then
		hero.expBg = expBg
		hero.expLabel = expBg:Find("txt_exp"):GetComponent("UILabel")
		hero.expSlider = expBg:Find("exp"):GetComponent("UISlider")
	end
	
	--将军升级
	local lvUpEff = heroTransform:Find("GeneralLvUp")
	if lvUpEff ~= nil then
		hero.lvUpEff = lvUpEff
	end
end

function FormatItemList(info)
	ActiveHeroData.SetOldData()
	local itemlist = {}
	local formatList = {}
	local reward = info.msg.reward
	if reward == nil then
		reward = info.msg.rewardInfo
	end
	for _, v in ipairs(reward.item.item) do
		local rewarditem = {}
		if v.baseid ~= 12 then
			--print("item: " .. v.baseid)
			--[[local reward = GetRewardItem(itemlist , v.baseid)
			if reward ~= nil then     --合并相同baseid的道具
				reward.data.num = reward.data.num + v.num
			else
				rewarditem.data = v
				rewarditem.dtype = 0
				rewarditem.itemInfo = info.ItemInfo
				table.insert(itemlist, rewarditem)
			end]]
			if formatList[v.baseid] ~= nil then
				local num = formatList[v.baseid].data.num
				formatList[v.baseid].data.num = num + v.num
			else
				rewarditem.data = v
				rewarditem.dtype = 0
				rewarditem.itemInfo = info.ItemInfo
				formatList[v.baseid] = rewarditem
			end
		end
	end
	
	for _ , v in pairs(formatList) do
		if v ~= nil then
			table.insert(itemlist, v)
		end
	end
	
	--将军
	local heroList = {}
	for _,v in ipairs(reward.hero.hero) do
		local key = v.baseid..v.star..v.level
        if heroList[key] == nil then
			heroList[key] = {}
			heroList[key].data = v
			heroList[key].dtype = 1
			heroList[key].itemInfo = info.HeroIndo
			heroList[key].count = v.num
		else
			heroList[key].count = heroList[key].count + 1
		end
	end
	
	for _, v in pairs(heroList) do
		table.insert(itemlist, v)
	end
	
	--士兵
	local soldierList = {}
	for _ , v in ipairs(reward.army.army) do
		local rewardarmy = {}
		rewardarmy.data = v
		rewardarmy.dtype = 2
		rewardarmy.itemInfo = info.ItemInfo
		soldierList[v.baseid] = rewardarmy
	end
	for _, v in pairs(soldierList) do
		table.insert(itemlist, v)
	end
	
	return itemlist
end


function UpdateWrapContent(optgridTrf , UpdateParam , InitFinish)
	local optGrid = optgridTrf:GetComponent("UIWrapContent")
	if optGrid == nil then
		return
	end
	optGrid.minIndex = UpdateParam.minIndex
	optGrid.maxIndex = UpdateParam.maxIndex
	
	if InitFinish ~= nil then
		InitFinish(optGrid.transform)
	end
	
	optGrid:WrapContent()
	
end

function CreateWrapContent(srcollView , InitParam , InitFinish)
	if srcollView == nil then
		--UnityEngine_DebugWrap:LogError("scrollView obj is null")
		print("scrollView obj is null")
		return
	end		

	if srcollView.transform:Find("OptGrid") ~= nil then
		print("OptGrid exist")
		return
	end
	--[[local srcollViewCom = srcollView:GetComponent("UIScrollView")
	if scrollViewCom == nil then
		--UnityEngine_DebugWrap:LogError("there is no UIScrollView Component")
		print("there is no UIScrollView Component")
		return
	end]]
	
	local optGridPrefab = ResourceLibrary.GetUIPrefab("BuildingCommon/OptGrid")
	local optGridTransform = NGUITools.AddChild(srcollView.gameObject , optGridPrefab).transform
	optGridTransform.localPosition = Vector3(InitParam.localPos.x , InitParam.localPos.y , InitParam.localPos.z)
	optGridTransform.name = "OptGrid"
	local optGrid = optGridTransform:GetComponent("UIWrapContent")
	
	optGrid.onInitializeItem = InitParam.OnInitFunc
	--optGrid.OnUpdateItem = InitParam.OnUpdateFunc
	optGrid.itemSize = InitParam.itemSize
	optGrid.minIndex = InitParam.minIndex
	optGrid.maxIndex = InitParam.maxIndex
	optGrid.cullContent = InitParam.cullContent
	
	for i=0, InitParam.itemCount-1 do
		local cell = NGUITools.AddChild(optGridTransform.gameObject , InitParam.cellPrefab.gameObject).transform
		if InitParam.cellName ~= nil then
			cell.name = InitParam.cellName
		end
		--vertical
		if InitParam.moveDir == 1 then
			cell.localPosition = Vector3(cell.localPosition.x  , cell.localPosition.y - i*optGrid.itemSize , cell.localPosition.z)
		end
		--hor
		if InitParam.moveDir == 2 then
			cell.localPosition = Vector3(cell.localPosition.x + i*optGrid.itemSize , cell.localPosition.y , cell.localPosition.z)
		end
		
	end
	
	optGrid:ResetToStart()
	
	if InitFinish ~= nil then
		InitFinish(optGrid.transform)
	end
	
	
end

function SetBtnEnable(_btn, enableSpr , disableSpr , _isEnable )
	local _sprite_name
	local _color
	if _isEnable then
		_sprite_name = enableSpr
		_color = Color.white * 1
	else
		_sprite_name = disableSpr
		_color = Color.white * 0.7
	end
	_btn:GetComponent("UISprite").spriteName = _sprite_name
	_btn.normalSprite = _sprite_name
	local _text = _btn.transform:Find("text")
	if _text ~= nil then
		_text = _text:GetComponent("UILabel")
		_text.applyGradient = true
		_text.gradientTop = _color
		_text.gradientBottom = _color
	end
	local _label = _btn.transform:Find("Label")
	if _label ~= nil then
		_label = _label:GetComponent("UILabel")
		_label.applyGradient = true
		_label.gradientTop = _color
		_label.gradientBottom = _color
	end
	local _num = _btn.transform:Find("num")
	if _num ~= nil then
		_num = _num:GetComponent("UILabel")
		_num.applyGradient = true
		_num.gradientTop = _color
		_num.gradientBottom = _color
	end
	local _gold = _btn.transform:Find("icon_gold")
	if _gold ~= nil then
		_gold:GetComponent("UISprite").color = _color
	end
end

function LoadItemObject(item, itemTransform)
    item.transform = itemTransform
    item.gameObject = itemTransform.gameObject
    item.qualitySprite = itemTransform:GetComponent("UISprite")
    item.iconTexture = itemTransform:Find("Texture"):GetComponent("UITexture")
    local countTransform = itemTransform:Find("have")
    item.countObject = countTransform.gameObject
    item.countLabel = countTransform:GetComponent("UILabel")
    local numberTransform = itemTransform:Find("num")
    item.numberObject = numberTransform.gameObject
    item.numberLabel = numberTransform:GetComponent("UILabel")
    local pieceTransform = itemTransform:Find("Texture/piece")
    item.pieceObject = pieceTransform.gameObject
    item.pieceSprite = pieceTransform:GetComponent("UISprite")
    local viewTransform = itemTransform:Find("btn_box")
    item.viewObject = viewTransform.gameObject
    item.viewButton = viewTransform:GetComponent("UIButton")

    return item
end

function LoadSoldier(item, soldierData, soldierCount)
	item.data = soldierData
	item.iconTexture.mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", soldierData.SoldierIcon)
	item.countLabel.text = soldierCount
	item.qualitySprite.spriteName = "bg_item"
	item.numberObject:SetActive(false)
end

function LoadItem(item, itemData, itemCount)
    item.data = itemData
	item.qualitySprite.spriteName = "bg_item" .. itemData.quality
	if itemData.type == 61 then
		item.iconTexture.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", itemData.icon)
	else
		item.iconTexture.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
	end
	
    if itemCount ~= nil then
        item.countObject:SetActive(true)
        if type(itemCount) == "number" then
			if itemCount > 0 then
				item.countLabel.text = Global.ExchangeValue(itemCount)
			else
				item.countObject:SetActive(false)
			end
            
        else
            item.countLabel.text = itemCount
        end
    else
        item.countObject:SetActive(false)
    end
    local levelText = Global.GetItemLevelText(itemData) 
    if levelText ~= nil then
        item.numberObject:SetActive(true)
        item.numberLabel.text = levelText
    else
        item.numberObject:SetActive(false)
    end
    if itemData.type == 54 then
        item.pieceObject:SetActive(true)
        item.pieceSprite.spriteName = "piece" .. itemData.quality
    else
        item.pieceObject:SetActive(false)
    end
    if item.nameLabel ~= nil then
        item.nameLabel.text = TextUtil.GetItemName(itemData)
    end
end

function AddItemToGrid(grid, itemInfo, onClick)
	local item = LoadItemObject({}, NGUITools.AddChild(grid, ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")).transform)
	LoadItem(item, TableMgr:GetItemData(itemInfo.id or itemInfo.baseid), itemInfo.num)
	
	if onClick ~= nil then
		SetClickCallback(item.gameObject, onClick)
	end

	return item
end

function LoadList(rootTransform)
	local list = {}
    list.scrollView = rootTransform:GetComponent("UIScrollView")
    list.panel = rootTransform:GetComponent("UIPanel")
    list.transform = rootTransform:GetChild(0)
    list.gameObject = list.transform.gameObject
    list.grid = list.transform:GetComponent("UIGrid")

    return list
end

function LoadHeroItemObject(item, itemTransform)
    item.transform = itemTransform
    item.gameObject = itemTransform.gameObject
    local iconTransform = itemTransform:Find("item1")
    item.iconObject = iconTransform.gameObject
    item.iconTexture = iconTransform:GetComponent("UITexture")
    item.qualitySprite = itemTransform:Find("item1/outline1"):GetComponent("UISprite")
    local countTransform = itemTransform:Find("item1/num")
    item.countObject = countTransform.gameObject
    item.countLabel = countTransform:GetComponent("UILabel")
    local pieceTransform = itemTransform:Find("item1/piece")
    item.pieceObject = pieceTransform.gameObject
    item.pieceSprite = pieceTransform:GetComponent("UISprite")
    item.selectObject = itemTransform:Find("select").gameObject

    return item
end

function LoadHeroItem(item, itemData, itemCount)
    item.data = itemData
    item.qualitySprite.spriteName = "bg_item" .. itemData.quality
    item.iconTexture.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
    if itemCount ~= nil and (type(itemCount) == "string" or itemCount > 0) then
        item.countObject:SetActive(true)
        item.countLabel.text = itemCount
    else
        item.countObject:SetActive(false)
    end
    if itemData.type == 54 then
        item.pieceObject:SetActive(true)
        item.pieceSprite.spriteName = "piece" .. itemData.quality
    else
        item.pieceObject:SetActive(false)
    end
    if item.nameLabel ~= nil then
        item.nameLabel.text = TextUtil.GetItemName(itemData)
    end
end

function UIListItemShow(rewardListData , showlimit , finishCallBackFunc)
	UIListItemBtnObj = {}
	local listGrid = rewardListData.grid
	local listScrollView = rewardListData.scrollview
	local panel = listScrollView.transform:GetComponent("UIPanel")
	
	listScrollView.enabled = false
	local showCorout = coroutine.start(function()
		local startPos = listGrid.transform.localPosition
		local offset = listGrid.cellWidth
		
		local svWidth = panel.baseClipRegion.z
		local moveing = false
		local movedis = 0
		local movetime = 10--frame
		local index = 1
		local speed = offset/movetime
		local rewardList = rewardListData.data
		local offindex = showlimit
		local moveindex = 0
		
		jumpToFinish = false
		
		--table.foreach(rewardList , function(_,v) print(v.data.baseid) end )
		
		while listGrid.transform.childCount > 0 do
			GameObject.DestroyImmediate(listGrid.transform:GetChild(0).gameObject)
		end
		
		-- grid的初始位置
		if #rewardList < showlimit then
			local gridname = System.String.Format("Grid_{0}" , #rewardList)
			local gridPos = listScrollView.transform:Find(gridname)
			if gridPos ~= nil then
				listGrid.transform.localPosition = gridPos.localPosition
				local wid = gridPos:GetChild(0)
				if wid ~= nil then
					listGrid.cellWidth = tonumber(wid.name)
				end
			end
		end
		
		while index <= #rewardList do
			if moveing then
				if movedis < offset*moveindex then
					speed = offset*moveindex/movetime
					local movespeed = speed
					if movedis + speed > offset*moveindex then
						--movespeed = offset*moveindex - movedis
					end
					movedis = movedis + movespeed
					listGrid.transform.localPosition = listGrid.transform.localPosition - Vector3(movespeed , 0, 0)
					listScrollView:UpdatePosition()
					
				else
					moveing = false
				end
				
				if not jumpToFinish then
					coroutine.step()
				end
				
			else
				local v = rewardList[index]
				if v.dtype == 0 then
					local itemTransform = NGUITools.AddChild(listGrid.transform.gameObject , v.itemInfo).transform
					local itemData = TableMgr:GetItemData(v.data.baseid)
					local item = {}
					LoadItemObject(item, itemTransform)
					LoadItem(item, itemData, v.data.num)
					v.btnGo = itemTransform.gameObject
					v.tbData = itemData
					

				elseif v.dtype == 1 then
					local heroitem = NGUITools.AddChild(listGrid.transform.gameObject , v.itemInfo.gameObject)
					heroitem.transform:SetParent(listGrid.transform , false)
					heroitem.gameObject:SetActive(true)
					heroitem.transform.localScale = Vector3(0.6,0.6,1)
					local heroData = TableMgr:GetHeroData(v.data.baseid)
					local heroShowData = 
					{
						baseid = v.data.baseid, 
						level = v.data.level, 
						star = v.data.star,
						grade = v.data.grade,
						count = v.count
					}
					local hero = {}
					HeroList.LoadHeroObject(hero , heroitem.transform)
					LoadHeroInfo(hero , heroShowData , false)
					v.btnGo = heroitem.gameObject
					v.tbData = heroData
					local hasHero = ActiveHeroData.HasHeroOld(heroShowData.baseid)
			        if not hasHero then
			            hero.isNew = true
			        end
					if hero.isNew and heroData.quality >= 4 then
		                OneCardDisplay.Show(nil, heroShowData, nil, false)
		                while OneCardDisplay.Showing() do
		                    coroutine.step()
		                end
		            end
				elseif v.dtype == 2 then
					local soldieritem = NGUITools.AddChild(listGrid.transform.gameObject , v.itemInfo.gameObject)
					soldieritem:SetActive(true)
					print("soldier=================" , v.data.baseid, v.data.level , v.data.baseid, v.data.num)
					local soldierData = TableMgr:GetBarrackData(v.data.baseid, v.data.level)
					soldierData.name = soldierData.SoldierName
					soldierData.description = soldierData.SoldierDes 
					
					print("soldier=================" , soldierData.name,soldierData.description)
					local item = {}
					LoadItemObject(item, soldieritem.transform)
					LoadSoldier(item, soldierData, v.data.num)
					v.btnGo = soldieritem
					v.tbData = soldierData
				end
				AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
				--print("index" .. index)
				listGrid:Reposition()
				index = index + 1
				if not jumpToFinish then
					coroutine.wait(0.2)
				end
				if index > #rewardList then
					if finishCallBackFunc ~= nil then
						finishCallBackFunc()
					end
					
					listScrollView.enabled = true
				else
					if index > offindex then
						--print("move index" .. index)
						moveing = true
						movedis = 0
						moveindex = 0
						if (#rewardList - offindex)/showlimit >= 1 then
							moveindex = showlimit
						else
							moveindex = (#rewardList - offindex)%showlimit
						end
						offindex = offindex + moveindex
					end 
				end
			end
		end
	end)
	listGrid:Reposition()
	return showCorout
end

function AdjustDepth(gameObject, adjustment)
    local widgets = gameObject:GetComponentsInChildren(typeof(UIWidget))
    for i = 1, widgets.Length do
        widgets[i - 1].depth = widgets[i - 1].depth + adjustment
    end
end

function GetNationalFlagTexture(nationality)
	return ResourceLibrary:GetIcon("Icon/Union/", TableMgr:GetNationalityData(nationality).texture)
end

function ScrollTo(scrollView, index, rowCount, itemHeight)
    local scrollViewTransform = scrollView.transform
    local clipHeight = scrollViewTransform:GetComponent("UIPanel").baseClipRegion.w

    local moveY = itemHeight * (index - 1)
    moveY = math.min(moveY, itemHeight * rowCount - clipHeight) 
    if moveY > 0 then
        scrollView:MoveRelative(Vector3(0, moveY, 0))
        scrollView:Scroll(0.01)
    end
end

function LoadMOD(rootTransform, config)
    local params = string.split(config, ",")

    local widgetType = params[2]
    if widgetType == "T" then
        rootTransform:Find(params[1]):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("", params[3])
    elseif widgetType == "S" then
    	rootTransform:Find(params[1]):GetComponent("UISprite").spriteName = params[3]
    end
end

function GetCurrencySprite(itemID)
	if itemID == 2 then
		return "icon_gold"
	end
end

function GetTableLength(_table)
	local count = 0
	for i, v in pairs(_table) do
		count = count + 1
	end
	return count
end

function LoadButtonSlider(slider, minusButton, addButton, value, minValue, maxValue, changeCallback)
    local currentValue = value
    slider.numberOfSteps = maxValue - minValue + 1
    if minValue == maxValue then
        slider.value = 1
    else
        slider.value = (currentValue - minValue) / (maxValue - minValue)
    end
    slider.transform:GetComponent("BoxCollider").enabled = minValue ~= maxValue
    slider.thumb:GetComponent("BoxCollider").enabled = minValue ~= maxValue
    --slider:ForceUpdate()
    SetClickCallback(minusButton.gameObject, function(go)
        if currentValue > minValue then
            currentValue = currentValue - 1
            slider.value = (currentValue - minValue) / (maxValue - minValue)
            slider:ForceUpdate()
            changeCallback(currentValue)
        end
    end)

    SetClickCallback(addButton.gameObject, function(go)
        if currentValue < maxValue then
            currentValue = currentValue + 1
            slider.value = (currentValue - minValue) / (maxValue - minValue)
            slider:ForceUpdate()
            changeCallback(currentValue)
        end
    end)
    EventDelegate.Set(slider.onChange, EventDelegate.Callback(function(go)
        currentValue = Mathf.Round((maxValue - minValue) * slider.value) + minValue
        changeCallback(currentValue)
    end))
end

function SetStarPos(star_root, star, total, index, height, angle) --星星轴心，星星，总数，第几个，半径，间隔角度
	star.transform:SetParent(star_root.transform, false)
	local start_angle = - (angle * (total - 1)) / 2
	local current_angle = (start_angle + angle * (index - 1)) / 180 * math.pi
	local x = height * math.sin(current_angle)
	local y = height * math.cos(current_angle)
	star.transform.localPosition = Vector3(x, y, 0)
end
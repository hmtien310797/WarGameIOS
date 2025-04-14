module("MobaParadeGround",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetDragCallback = UIUtil.SetDragCallback
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

OnCloseCB = nil

local heroPrefab = ResourceLibrary.GetUIPrefab("ParadeGround/listitem_hero_small")
local soldierPrefab = ResourceLibrary.GetUIPrefab("wall/listitem_soldier")

local ShowContent
local UpdateContent
local LoadUI

local itemOpenning
local itemDefentOpen

local tipShowCoroutine

local paradeItemList
local actionUpdate
OnCloseCB = nil



local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	
	for _,v in pairs(paradeItemList) do
		if go == v.btn then

			if not Tooltip.IsItemTipActive() then
				itemTipTarget = go
				Tooltip.ShowItemTip({name = v.name, text = v.des})
			else
				 if itemTipTarget == go then
					Tooltip.HideItemTip()
				else
					itemTipTarget = go
					Tooltip.ShowItemTip({name = v.name, text = v.des})
				end
			end
			return
		end
	end
	
	Tooltip.HideItemTip()
end

function GetArmyMaxNum()
	local maxnum = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.ArmyBaseCount).value)
	local pd = maincity.GetBuildingByID(4)
    if pd ~= nil then
        local pd_data = TableMgr:GetParadeGroundData(pd.data.level)
        maxnum = maxnum + pd_data.addlimitall  
    end
	
	return	maxnum
end

function GetTotalArmyNum()
	--return --[[Barrack.GetArmyNum() +]] MobaActionListData.GetActionArmyTotalNum()
	return MobaBarrackData.GetArmyNum() + MobaActionListData.GetActionArmyTotalNum()
end

local function ShowReviewTips(go)
	local str = string.split(go.name , "_")
	local index = tonumber(str[3])
	local parTrans = container.overviewTips[index]
	--print(parTrans.localPosition.x , parTrans.localPosition.y , parTrans.localPosition.z)
	container.tips.gameObject:SetActive(true)
	container.tips.localPosition = Vector3(parTrans.localPosition.x , 200--[[parTrans.localPosition.y -100]] ,parTrans.localPosition.z )
	container.tipslabel.text = container.overviewTips[index].label
	
	
	if tipShowCoroutine ~= nil then
		coroutine.stop(tipShowCoroutine)
		tipShowCoroutine = nil
		
		tipShowCoroutine = coroutine.start(function()
			coroutine.wait(3)
			container.tips.gameObject:SetActive(false) 
		end)
	else
		tipShowCoroutine = coroutine.start(function()
			coroutine.wait(3)
			container.tips.gameObject:SetActive(false) 
		end)
	end
	
end

local function ResetDefentList()
	local des = {}
	local childCount = container.Table.table.transform.childCount
	for i=0 , childCount-1 do
		local child = container.Table.table.transform:GetChild(i)
		if child.name == "ArmyUI_Type_1" then
			--GameObject.DestroyImmediate(child.gameObject)
			des[i] = child
		end
	end
	
	for _ , v in pairs(des) do
		if v ~= nil then
			GameObject.DestroyImmediate(v.gameObject)
		end
	end
end

local function ResetActionList()
	local des = {}
	local childCount = container.Table.table.transform.childCount
	for i=0 , childCount-1 do
		local child = container.Table.table.transform:GetChild(i)
		if child.name == "ArmyUI_Type_2" then
			--GameObject.DestroyImmediate(child.gameObject)
			des[i] = child
		end
	end
	
	for _ , v in pairs(des) do
		if v ~= nil then
			GameObject.DestroyImmediate(v.gameObject)
		end
	end
end


local function UpdateActionListState()
	if actionUpdate ~= nil then
		for _ , v in pairs(actionUpdate) do
			if v.msg.status ~= 3 and v.msg.status ~= 102 and v.msg.status ~= 109 then
				local status = v.statusText
				local countDown = Global.GetLeftCooldownTextLong(v.arriveTime)
				v.item.transform:Find("bg_list/bg_text/text"):GetComponent("UILabel").text = System.String.Format("{0}({1})" , status , countDown)
			else
				v.item.transform:Find("bg_list/bg_text/text"):GetComponent("UILabel").text = v.statusText
			end
		end
	end
end

local function LoadActionList()
	--UpdateActionList()
	print("parade Ground notify")
	actionUpdate = {}
	ResetActionList()
	MobaActionListData.Sort1()
	
	AttributeBonus.CollectBonusInfo()
	local Bonus = AttributeBonus.GetBonusInfos()
	
	local actcionMsg = MobaActionListData.GetData()
	local actionCount = #actcionMsg
    local baseLevel = BuildingData.GetCommandCenterData().level
    local coreData = TableMgr:GetBuildCoreDataByLevel(baseLevel)
	local pathCount = coreData.armyNumber + (Bonus[1088] ~= nil and Bonus[1088] or 0)
	
    --container.overview.num3.text = string.format("%d/%d", actionCount, pathCount)
    container.overview.num3.text = string.format("%d/%d", actionCount, MobaActionListData.GetMaxCount())
	
	
	for _ , v in ipairs(actcionMsg) do
		local updateInfo = {}
	
		local info = NGUITools.AddChild(container.Table.table.gameObject , container.Table.iteminfo.gameObject)
		info.transform:SetParent(container.Table.table.transform , false)
		info.name = "ArmyUI_Type_" .. 2--行军队列信息
		info.gameObject:SetActive(true)
		
		--title status
		local statusIcon, statusText, targetName = MobaActionList.GetActionTargetInfoByMsg(v)
		local itemTitle = info.transform:Find("bg_list/bg_text/text"):GetComponent("UILabel")

		--icon
		local icon = info.transform:Find("bg_list/bg_text/Texture"):GetComponent("UISprite")
		icon.spriteName = "icon_attack"
		
		updateInfo.item = info
		updateInfo.arriveTime = v.starttime + v.time
		updateInfo.msg = v
		updateInfo.statusText = statusText
		actionUpdate[v.uid] = updateInfo

		--target name
		local itemTargetName = info.transform:Find("bg_list/bg_mid/target")
		itemTargetName.gameObject:SetActive(true)
		local name = info.transform:Find("bg_list/bg_mid/target/name"):GetComponent("UILabel")
		name.text = targetName

		--target pos
		local targetPos = info.transform:Find("bg_list/bg_mid/local")
		targetPos.gameObject:SetActive(true)
		local pos = info.transform:Find("bg_list/bg_mid/local/name"):GetComponent("UILabel")
		pos.text = System.String.Format("#1 X:{0} Y:{1}" , v.tarpos.x , v.tarpos.y)
		SetClickCallback(pos.gameObject, function()
			--MainCityUI.ShowWorldMap(tonumber(v.tarpos.x) , tonumber(v.tarpos.y))
			if Global.GetMobaMode() == 2 then
				GuildMobaChat.GoMap(v.tarpos.x , v.tarpos.y)
			else
				local mapX = tonumber(v.tarpos.x)
				local mapY = tonumber(v.tarpos.y)
				local minX, minY = MobaMain.MobaMinPos()
				local worldMapX = mapX + minX
				local worldMapY = mapY + minY
				MobaMain.LookAt(worldMapX, worldMapY)
				MobaMain.SelectTile(worldMapX, worldMapY)
				GUIMgr:CloseMenu("MobaParadeGround")
			end
		end)
		if v.pathtype ~= Common_pb.TeamMoveType_ResTransport then
			local itemOpen = info.transform:Find("ItemInfo_open")
			local itemOpenTweenScal = itemOpen:GetComponent("TweenScale")
			local tweenHeight = info.transform:Find("bg_list"):GetComponent("TweenHeight")
			local paraController = info.transform:GetComponent("ParadeTableItemController")
			
			local itemGenNoitem = info.transform:Find("ItemInfo_open/bg_general/frame/bg_noitem/txt_noitem"):GetComponent("UILabel")
			local itemSoldierNoitem = info.transform:Find("ItemInfo_open/bg_soldier/frame/bg_noitem/txt_noitem"):GetComponent("UILabel")

			--add hero
			local genGrid = info.transform:Find("ItemInfo_open/bg_general/frame/Scroll View/Grid"):GetComponent("UIGrid")
			local actionHeros = v.army.hero.heros
			
			if (#actionHeros) < 1 then
				itemGenNoitem.transform.parent.gameObject:SetActive(true)
				itemGenNoitem.text = TextMgr:GetText("PVP_ui14")
			else
				itemGenNoitem.transform.parent.gameObject:SetActive(false)
			end
			
			for _ , vh in ipairs(actionHeros) do
				local heroTransform = NGUITools.AddChild(genGrid.gameObject , heroPrefab).transform
				heroTransform:SetParent(genGrid.transform , false)
				heroTransform.localScale = Vector3(0.8,0.8,0.8)
				
				print("uid:" .. vh.uid)
				local heroMsg = MobaHeroListData.GetGeneralByUID(vh.uid) -- HeroListData.GetHeroDataByUid(vh.uid)
				local heroData = TableMgr:GetHeroData(heroMsg.baseid)
				
				local heroicon = heroTransform:Find("head icon"):GetComponent("UITexture")
				heroicon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
				
				local herolv = heroTransform:Find("level text"):GetComponent("UILabel")
				herolv.text = heroMsg.level
				
				local herostar = heroTransform:Find(System.String.Format("star/star{0}" , heroMsg.star))
				herostar.gameObject:SetActive(true)
				
				local heroQuality = heroTransform:Find(System.String.Format("head icon/outline{0}" , heroData.quality))
				heroQuality.gameObject:SetActive(true)
				
				local showItem = {}
				showItem.btn = heroicon.gameObject
				showItem.name = TextMgr:GetText(heroData.nameLabel)
				showItem.des = TextMgr:GetText(heroData.description)
				table.insert(paradeItemList , showItem)
			end
			
			genGrid:Reposition()
			
			local solderframe = info.transform:Find("ItemInfo_open/bg_soldier/frame"):GetComponent("UIWidget")
			local generalframe = info.transform:Find("ItemInfo_open/bg_general/frame"):GetComponent("UIWidget")
			local solderOpen = info.transform:Find("ItemInfo_open"):GetComponent("UIWidget")
			local soldierTable = info.transform:Find("ItemInfo_open/bg_soldier/Table"):GetComponent("UITable")
			local soldierGrid = info.transform:Find("ItemInfo_open/bg_soldier/Grid"):GetComponent("UIGrid")
			
			local armys = v.army.army.army
			local armyCount = #(armys)
			local soldierItemHeight = 0
			
			if armyCount == 0 then
				itemSoldierNoitem.transform.parent.gameObject:SetActive(true)
				itemSoldierNoitem.text = TextMgr:GetText("paradeground_ui2")
			else
				itemSoldierNoitem.transform.parent.gameObject:SetActive(false)
			end
			
			for _ , va in ipairs(armys) do
				local soldierTransform = NGUITools.AddChild(soldierGrid.gameObject , soldierPrefab).transform
				soldierTransform:SetParent(soldierGrid.transform , false)
				
				local soldier = TableMgr:GetBarrackData(va.armyId , va.armyLevel)
				local unitData = TableMgr:GetUnitData(soldier.UnitID)
				local icon = soldierTransform:Find("bg/icon"):GetComponent("UITexture")
				icon.mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", unitData._unitSoldierIcon)
				local num = soldierTransform:Find("bg/num"):GetComponent("UILabel")
				num.text = va.num - va.deadNum
				local name = soldierTransform:Find("name bg/name text"):GetComponent("UILabel")
				name.text = TextUtil.GetUnitName(unitData)
				
				soldierItemHeight = soldierTransform:Find("bg"):GetComponent("UIWidget").height + soldierTransform:Find("name bg"):GetComponent("UIWidget").height
				
				local showItem = {}
				showItem.btn = soldierTransform.gameObject
				showItem.name = name.text
				showItem.des = TextUtil.GetUnitDescription(unitData)
				table.insert(paradeItemList , showItem)
			end

			--armyNum
			local itemContentLeft = info.transform:Find("bg_list/bg_mid/text_left"):GetComponent("UILabel")
			itemContentLeft.text = TextMgr:GetText("setting_ui28") .. v.armynum
		
			soldierGrid:Reposition()
			--print("params:" .. soldierItemHeight, armyCount , soldierTable.columns)
			local soldierRows = math.ceil((armyCount)/soldierGrid.maxPerLine)

			local rowdis = 25
			local addbgHeight = soldierRows * soldierItemHeight + rowdis
			--print("add height:" .. addbgHeight ,soldierRows )
		
		
			if soldierRows > 0 then
				solderframe.height = addbgHeight
				solderOpen.height = addbgHeight + generalframe.height + rowdis
				
				--tweenHeight.to = solderOpen.height + container.Table.iteminfo:GetComponent("UIWidget").height - rowdis
				paraController:SetItemOpenHeight(solderOpen.height + container.Table.iteminfo:GetComponent("UIWidget").height - rowdis)
			end
		else
			local itemOpen = info.transform:Find("ItemInfo_open (1)")
			info.transform:Find("bg_list/btn_open"):GetComponent("UIPlayTween").tweenTarget = itemOpen.gameObject
			local itemOpenTweenScal = itemOpen:GetComponent("TweenScale")
			local tweenHeight = info.transform:Find("bg_list"):GetComponent("TweenHeight")
			local paraController = info.transform:GetComponent("ParadeTableItemController")
			local itemGrid = info.transform:Find("ItemInfo_open (1)/bg_res/frame/Grid"):GetComponent("UIGrid")
			
			local itemprefab = ResourceLibrary.GetUIPrefab("ParadeGround/list_item")
			local restrans = v.restrans.res
			for _ , va in ipairs(restrans) do
				if va.num > 0 then
					local itemTransform = NGUITools.AddChild(itemGrid.gameObject , itemprefab).transform
					itemTransform:SetParent(itemGrid.transform , false)
					
					local itemdata = TableMgr:GetItemData(va.id)
					local icon = itemTransform:Find("item"):GetComponent("UITexture")
					icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemdata.icon)
					local num = itemTransform:Find("num"):GetComponent("UILabel")
					num.text = Global.ExchangeValue(va.num)
					local nameroot = itemTransform:Find("bg_num").gameObject
					local name = itemTransform:Find("bg_num/txt_num"):GetComponent("UILabel")
					if itemdata.showType == 1 then
						name.text = Global.ExchangeValue2(itemdata.itemlevel)
					elseif itemdata.showType == 2 then
						name.text = Global.ExchangeValue1(itemdata.itemlevel)
					elseif itemdata.showType == 3 then
						name.text = Global.ExchangeValue3(itemdata.itemlevel)
					else 
						nameroot.gameObject:SetActive(false)
					end
					
					local showItem = {}
					showItem.btn = itemTransform.gameObject
					showItem.name = TextUtil.GetItemName(itemdata)
					showItem.des = TextUtil.GetItemDescription(itemdata)
					table.insert(paradeItemList , showItem)
				end
			end
			itemGrid:Reposition()
			local itemContentLeft = info.transform:Find("bg_list/bg_mid/text_left"):GetComponent("UILabel")
			itemContentLeft.text = TextMgr:GetText("setting_ui28") .. 0
			paraController:SetItemOpenHeight(210)
		end
	end
	
end

local function GetDefenseHero()
	local defentHero = {}
	local defentArmy = MobaTeamData.GetDataByTeamType(Common_pb.BattleTeamType_CityDefence)
	local setoutHero = MobaSetoutData.GetSetoutHero()
	

	for _ , v in ipairs(defentArmy.memHero) do
		local defent = true
		for _ , vv in pairs(setoutHero) do
			if v.uid == vv then
				defent = false
			end
		end
		
		if defent then
			table.insert(defentHero , v)
		end
	end
	return defentHero
	
end


function SetDefentArmyUI(info,_paradeItemList,_container,_real)	
	local icon = info.transform:Find("bg_list/bg_text/Texture"):GetComponent("UISprite")
	icon.spriteName = "icon_defend"
		
	local itemTitle = info.transform:Find("bg_list/bg_text/text"):GetComponent("UILabel")
	itemTitle.text = TextMgr:GetText("wall_ui2")
	local itemContentLeft = info.transform:Find("bg_list/bg_mid/text_left"):GetComponent("UILabel")
	itemContentLeft.text = TextMgr:GetText("setting_ui28") .. MobaBarrackData.GetArmyNum()
	
	
	local itemOpen = info.transform:Find("ItemInfo_open")
	local itemOpenTweenScal = itemOpen:GetComponent("TweenScale")
	local tweenHeight = info.transform:Find("bg_list"):GetComponent("TweenHeight")
	local paraController = info.transform:GetComponent("ParadeTableItemController")
	
	local itemGenNoitem = info.transform:Find("ItemInfo_open/bg_general/frame/bg_noitem/txt_noitem"):GetComponent("UILabel")
	local itemSoldierNoitem = info.transform:Find("ItemInfo_open/bg_soldier/frame/bg_noitem/txt_noitem"):GetComponent("UILabel")
	
	
	--add hero
	local genGrid = info.transform:Find("ItemInfo_open/bg_general/frame/Scroll View/Grid"):GetComponent("UIGrid")
	local defentArmy = GetDefenseHero()--TeamData.GetDataByTeamType(Common_pb.BattleTeamType_CityDefence)

	if (#defentArmy) < 1 then
		itemGenNoitem.transform.parent.gameObject:SetActive(true)
		itemGenNoitem.text = TextMgr:GetText("paradeground_ui1")
	else
		itemGenNoitem.transform.parent.gameObject:SetActive(false)
	end
	
	for _ , v in ipairs(defentArmy) do
		local heroTransform = NGUITools.AddChild(genGrid.gameObject , heroPrefab).transform
		heroTransform:SetParent(genGrid.transform , false)
		heroTransform.localScale = Vector3(0.8,0.8,0.8)
		
		print("uid:" .. v.uid)
		local heroMsg = MobaHeroListData.GetGeneralByUID(v.uid) -- HeroListData.GetHeroDataByUid(v.uid)
		local heroData = TableMgr:GetHeroData(heroMsg.baseid)
		
		local heroicon = heroTransform:Find("head icon"):GetComponent("UITexture")
		heroicon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
		
		local herolv = heroTransform:Find("level text"):GetComponent("UILabel")
		herolv.text = heroMsg.level
		
		local herostar = heroTransform:Find(System.String.Format("star/star{0}" , heroMsg.star))
		herostar.gameObject:SetActive(true)
		
		local heroQuality = heroTransform:Find(System.String.Format("head icon/outline{0}" , heroData.quality))
		heroQuality.gameObject:SetActive(true)
		
		local showItem = {}
		showItem.btn = heroicon.gameObject
		showItem.name = TextMgr:GetText(heroData.nameLabel)
		showItem.des = TextMgr:GetText(heroData.description)
		table.insert(_paradeItemList , showItem)
	end
	
	genGrid:Reposition()
	
	local solderframe = info.transform:Find("ItemInfo_open/bg_soldier/frame"):GetComponent("UIWidget")
	local generalframe = info.transform:Find("ItemInfo_open/bg_general/frame"):GetComponent("UIWidget")
	local solderOpen = info.transform:Find("ItemInfo_open"):GetComponent("UIWidget")
	local soldierTable = info.transform:Find("ItemInfo_open/bg_soldier/Table"):GetComponent("UITable")
	local soldierGrid = info.transform:Find("ItemInfo_open/bg_soldier/Grid"):GetComponent("UIGrid")
	local armys = MobaBarrackData.GetArmy()
	if _real ~= nil and _real then
		armys = MobaBarrackData.GetRealArmy()
	end
	local armyCount = #(armys)
	local soldierItemHeight = 0
	
	if armyCount == 0 then
		itemSoldierNoitem.transform.parent.gameObject:SetActive(true)
		itemSoldierNoitem.text = TextMgr:GetText("paradeground_ui2")
	else
		itemSoldierNoitem.transform.parent.gameObject:SetActive(false)
	end
	
	for _ , v in pairs(armys) do
		local soldierTransform = NGUITools.AddChild(soldierGrid.gameObject , soldierPrefab).transform
		soldierTransform:SetParent(soldierGrid.transform , false)
		
		local unitData = TableMgr:GetUnitData(v.UnitID)
		local icon = soldierTransform:Find("bg/icon"):GetComponent("UITexture")
		icon.mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", unitData._unitSoldierIcon)
		local num = soldierTransform:Find("bg/num"):GetComponent("UILabel")
		num.text = v.Num
		local name = soldierTransform:Find("name bg/name text"):GetComponent("UILabel")
		name.text = TextUtil.GetUnitName(unitData)
		
		soldierItemHeight = soldierTransform:Find("bg"):GetComponent("UIWidget").height + soldierTransform:Find("name bg"):GetComponent("UIWidget").height
		
		local showItem = {}
		showItem.btn = soldierTransform.gameObject
		showItem.name = name.text
		showItem.des = TextUtil.GetUnitDescription(unitData)
		table.insert(_paradeItemList , showItem)
	end

	soldierGrid:Reposition()
	--print("params:" .. soldierItemHeight, armyCount , soldierTable.columns)
	local soldierRows = math.ceil((armyCount)/soldierGrid.maxPerLine)

	local rowdis = 25
	local addbgHeight = soldierRows * soldierItemHeight + rowdis
	--print("add height:" .. addbgHeight ,soldierRows )
	
	
	if soldierRows > 0 then
		solderframe.height = addbgHeight
		solderOpen.height = addbgHeight + generalframe.height + rowdis
		
		--tweenHeight.to = solderOpen.height + container.Table.iteminfo:GetComponent("UIWidget").height - rowdis
		if paraController ~= nil  and _container ~= nil then
			paraController:SetItemOpenHeight(solderOpen.height + _container.Table.iteminfo:GetComponent("UIWidget").height - rowdis)
		end
	end
end


local function LoadDefentArmyUI()
	ResetDefentList()
	itemDefentOpen = false
	
	local info = NGUITools.AddChild(container.Table.table.gameObject , container.Table.iteminfo.gameObject)
	info.transform:SetParent(container.Table.table.transform , false)
	info.name = "ArmyUI_Type_" .. 1--城防部队信息
	info.gameObject:SetActive(true)
	SetDefentArmyUI(info,paradeItemList,container)
end

local function LoadTopArmyUI()

	container.overview.num1.text = Global.GetMobaMode() == 1 and GetTotalArmyNum().. "/" .. Global.MobaArmyNumUpLimit() or GetTotalArmyNum()
	container.overview.num2.text = Global.ExchangeValue2(math.ceil(ResView.GetTotalSoldierCost()))..TextMgr:GetText("build_ui15")
	container.overview.num3.text = 0--string.format("%d/%d", actionCount, coreData.armyNumber)
	container.overview.num4.text = ArmyListData.GetInjuredNum() .. "/" .. ResView.GetInjuredArmyMax()
end


function UpdateActionList()
	LoadTopArmyUI()
	LoadDefentArmyUI()
	LoadActionList()
	container.Table.table:Reposition()
end
LoadUI = function()
	--overview
	
	tipShowCoroutine = nil
	LoadTopArmyUI()
	

	local defentArmyUI = LoadDefentArmyUI()
	local ActionUI = LoadActionList()
	--local defentArmyUI1 = LoadDefentArmyUI() 
	
	
	container.Table.table:Reposition()
	
end

ShowContent = function()

end

UpdateContent = function()
	

end

function Awake()
	paradeItemList = {}
    container = {}
    container.go = transform:Find("Container").gameObject
    container.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	
	container.overviewTips = {}
	container.overview = {}
	container.overview.bg_num1 = transform:Find("Container/bg_frane/bg_overview/bg_num_1")
	container.overview.icon_num1 = transform:Find("Container/bg_frane/bg_overview/bg_num_1/icon"):GetComponent("UITexture")
	container.overview.num1 = transform:Find("Container/bg_frane/bg_overview/bg_num_1/num"):GetComponent("UILabel")
	container.overviewTips[1] = container.overview.bg_num1
	container.overviewTips[1].label = TextMgr:GetText("setting_ui24")
	
	container.overview.bg_num2 = transform:Find("Container/bg_frane/bg_overview/bg_num_2")
	container.overview.icon_num2 = transform:Find("Container/bg_frane/bg_overview/bg_num_2/icon"):GetComponent("UITexture")
	container.overview.num2 = transform:Find("Container/bg_frane/bg_overview/bg_num_2/num"):GetComponent("UILabel")
	container.overviewTips[2] = container.overview.bg_num2
	container.overviewTips[2].label = TextMgr:GetText("paradeground_ui3")
	
	container.overview.bg_num3 = transform:Find("Container/bg_frane/bg_overview/bg_num_3")
	container.overview.icon_num3 = transform:Find("Container/bg_frane/bg_overview/bg_num_3/icon"):GetComponent("UITexture")
	container.overview.num3 = transform:Find("Container/bg_frane/bg_overview/bg_num_3/num"):GetComponent("UILabel")
	container.overviewTips[3] = container.overview.bg_num3
	container.overviewTips[3].label = TextMgr:GetText("setting_ui25")
	
	container.overview.bg_num4 = transform:Find("Container/bg_frane/bg_overview/bg_num_4")
	container.overview.icon_num4 = transform:Find("Container/bg_frane/bg_overview/bg_num_4/icon"):GetComponent("UITexture")
	container.overview.num4 = transform:Find("Container/bg_frane/bg_overview/bg_num_4/num"):GetComponent("UILabel")
	container.overviewTips[4] = container.overview.bg_num4
	container.overviewTips[4].label = TextMgr:GetText("setting_ui26")
	
	container.Table = {}
	container.Table.table = transform:Find("Container/bg_frane/Scroll View/Table"):GetComponent("UITable")
	container.Table.iteminfo = transform:Find("ItemInfo")
	
	container.tips = transform:Find("tips")
	container.tipslabel = transform:Find("tips/text"):GetComponent("UILabel")
	
    SetClickCallback(container.go, function()
    	GUIMgr:CloseMenu("MobaParadeGround")
    end)
 
    SetClickCallback(container.btn_close.gameObject, function()
    	GUIMgr:CloseMenu("MobaParadeGround")
    end)
	
	SetClickCallback(container.overview.bg_num1.gameObject, ShowReviewTips)
	SetClickCallback(container.overview.bg_num2.gameObject, ShowReviewTips)
	SetClickCallback(container.overview.bg_num3.gameObject, ShowReviewTips)
	SetClickCallback(container.overview.bg_num4.gameObject, ShowReviewTips)
	
	
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	MobaActionListData.AddListener(UpdateActionList)
	MobaSetoutData.AddListener(UpdateActionList)
end





function Start()
    itemOpen = false
	
	LoadUI()
	

end

function Update()
	--[[if itemOpenning then
		container.Table.table:Reposition()
	end]]
	if container.tips.gameObject.activeSelf then
	
	end
end

function LateUpdate()
    UpdateActionListState()
end


function Show()
	MobaTeamData.RequestData(function(msg)
		if msg.code == 0 then
			Global.OpenUI(_M)			
		end
    end)    
end

function Hide()
    Global.CloseUI(_M)
end


function Close()
	if OnCloseCB ~= nil then
    	OnCloseCB()
    	OnCloseCB = nil
    end
	container = nil
	actionUpdate = nil
	
	if tipShowCoroutine ~= nil then
		coroutine.stop(tipShowCoroutine)
		tipShowCoroutine = nil
	end
	
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	
	MobaActionListData.RemoveListener(UpdateActionList)
	MobaSetoutData.RemoveListener(UpdateActionList)
end

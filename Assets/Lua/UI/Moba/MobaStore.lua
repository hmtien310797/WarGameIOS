module("MobaStore", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local Format = System.String.Format
local SetClickCallback = UIUtil.SetClickCallback
local NGUITools = NGUITools
local Screen = UnityEngine.Screen

local ATTRIBUTE_NAMES = { [100000003] = "heronew_10",
                          [100000006] = "heronew_11",
                          [101] = "heronew_12",
                          [100000101] = "heronew_12",
                          [102] = "heronew_13",
                          [100000102] = "heronew_13", }
local _ui
local timer = 0

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    if _ui ~= nil then
        Hide()
    end
end



function Awake()
    _ui = {}
    local closeButton = transform:Find("Container/close btn")
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, CloseAll)
    _ui.list_ui = {}
	_ui.cur_select_index =-1
	
	
    local RootTrf = transform:Find("Container")

    for i = 1,3,1 do
        _ui.list_ui[i] = {}
        _ui.list_ui[i].count = 0
        _ui.list_ui[i].msg = nil
        _ui.list_ui[i].list = {}
        _ui.list_ui[i].grid = RootTrf:Find("bg2/content"..i.."/Scroll View/Grid"):GetComponent("UIGrid")
        _ui.list_ui[i].scroll_view = RootTrf:Find("bg2/content"..i.."/Scroll View"):GetComponent("UIScrollView")
		if RootTrf:Find("bg2/content"..i.."/list_1") ~= nil then
			_ui.list_ui[i].item = RootTrf:Find("bg2/content"..i.."/list_1").gameObject
			_ui.list_ui[i].item:SetActive(false)
		elseif RootTrf:Find("bg2/content"..i.."/New Hero") ~= nil then
			_ui.list_ui[i].item = RootTrf:Find("bg2/content"..i.."/New Hero").gameObject
			_ui.list_ui[i].item:SetActive(false)
		end
        _ui.list_ui[i].root = RootTrf:Find("bg2/content"..i).gameObject
        _ui.list_ui[i].page = RootTrf:Find("bg2/page"..i):GetComponent("UIToggle")
        _ui.list_ui[i].root:SetActive(i==1 and true or false)
        _ui.list_ui[i].notice = RootTrf:Find("bg2/page"..i.."/red")
        _ui.list_ui[i].notice.gameObject:SetActive(false)
		 RootTrf:Find("bg2/page"..i):GetComponent("UIToggledObjects").enabled = false
		 
		_ui.list_ui[i].desc_root = RootTrf:Find("bg2/content"..i.."/desc_list")

		_ui.list_ui[i].pageLabel = RootTrf:Find("bg2/page"..i.."/selected effect/text (1)"):GetComponent("UILabel")
		
        UIUtil.SetClickCallback(_ui.list_ui[i].page.gameObject,function()
            OpenList(i,true)
        end)
    end 
	_ui.jifen = RootTrf:Find("bg2/jifen_number/Label"):GetComponent("UILabel")
	
	OpenList(1,true)
	AddDelegate(UICamera, "onClick", OnUICameraClick)
	AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
	
	MobaMainData.AddListener(UpdateData)
	MobaPackageItemData.AddListener(UpdateItemList)
	UpdateData()
	_ui.title = transform:Find("Container/background/title/Label"):GetComponent("UILabel")
	
	if Global.GetMobaMode() == 1 then
		MobaTechData.InitUI(RootTrf:Find("bg2/content2"))
		MobaTechData.RequestMobaTechList()
	else
		_ui.list_ui[2].page.gameObject:SetActive(false)
		_ui.list_ui[3].page.gameObject:SetActive(false)
		RootTrf:Find("bg2/jifen_number").gameObject:SetActive(false)
		_ui.title:GetComponent("LocalizeEx").enabled = false
		_ui.title.text = TextMgr:GetText("ui_unionwar_5")
		_ui.list_ui[1].pageLabel:GetComponent("LocalizeEx").enabled = false
		_ui.list_ui[1].pageLabel.text = TextMgr:GetText("ui_unionwar_5")
	end

	
	
end

function UpdateData()
	if Global.GetMobaMode() == 1 then
		_ui.jifen.text = MobaMainData.GetData().data.mobaScore
	else
	
	end
end 

function UpdateItemList()
	LoadItemList(_ui.list_ui[1].grid,_ui.list_ui[1].item)
end 

function CloseCurList()
    if _ui.cur_select_index >= 1  and _ui.list_ui[_ui.cur_select_index] ~= nil then
        --_ui:StopListCountDown(_ui.cur_select_index)   
        _ui.list_ui[_ui.cur_select_index].root:SetActive(false)
    end
end

function OpenList(index,reload) 
	if _ui ==nil then 
		return 
	end 
	if _ui.cur_select_index ~= index then
        CloseCurList()
        _ui.cur_select_index = index
    end

    _ui.list_ui[_ui.cur_select_index].notice.gameObject:SetActive(false)
    _ui.list_ui[_ui.cur_select_index].root:SetActive(true)
	
	if index ==1 then 
		if reload == true then 
			MobaItemData.GetDataWithCallBack(function()
				if _ui ==nil then 
					return 
				end 
				LoadItemList(_ui.list_ui[1].grid,_ui.list_ui[1].item)
				MobaPackageItemData.GetDataWithCallBack(function()
					-- OpenList(1,false)
				end)
			end)
		else
			LoadItemList(_ui.list_ui[1].grid,_ui.list_ui[1].item)
		end 
	elseif index ==2 then 
		--LoadTechList(_ui.list_ui[2].grid,_ui.list_ui[2].item,TableMgr:GetMobaShopTechTable())
	elseif index ==3 then 
		if reload == true then 
			MobaTeamData.RequestData(function()
				if _ui == nil then 
					return 
				end 
				LoadHeroList(_ui.list_ui[3].grid,_ui.list_ui[3].item,TableMgr:GetMobaShopHeroTable())
			end)
		else
			LoadHeroList(_ui.list_ui[3].grid,_ui.list_ui[3].item,TableMgr:GetMobaShopHeroTable())
		end 
	end

end

local function UseMultiPressCallback(UseItemId ,  btn)
	print("UseMultiPressCallback ",UseItemId)
	local itemdata = MobaItemData.GetItemDataByUid(UseItemId)
	local itemLocal = TableMgr:GetMobaShopItemTable()[UseItemId]
	if itemdata ~= nil then
		print("UseMultiPressCallback ",UseItemId,itemdata.exchangeId)
		if itemdata.maxBuyNum == 0 then 
			MobaStoreBuy.SetLeftTime(100)
			MobaStoreBuy.SetActualTime(itemdata.needScore)
			MobaStoreBuy.SetMaxNum(100) 
		else
			MobaStoreBuy.SetLeftTime(itemdata.maxBuyNum-itemdata.curBuyNum)
			MobaStoreBuy.SetActualTime(itemdata.needScore)
			MobaStoreBuy.SetMaxNum(itemdata.maxBuyNum-itemdata.curBuyNum) 
		end 

		local itemTable = TableMgr:GetItemData(itemLocal.ItemID)
		
		if itemLocal.PaceNeed > MobaData.GetMobaState() then 
			MessageBox.Show(TextMgr:GetText(Text.Code_NextStage))
			return 
		end 
		
		if itemdata.curBuyNum>=itemdata.maxBuyNum then
			-- FloatText.ShowOn(btn, TextMgr:GetText("CommonItemBag_ui12"), Color.white)
			--return
		end
		
		MobaStoreBuy.SetDefaultUseNum(1) 
		MobaStoreBuy.InitItem(tonumber(UseItemId),itemTable)

		local tip = ""
		MobaStoreBuy.SetUseCallBack(function(useNum)
			
			local req = MobaMsg_pb.MsgMobaBuyShopItemRequest()
			req.exchangeId = UseItemId
			req.num = useNum
			
			if MobaMainData.GetData().data.mobaScore >= itemdata.needScore*useNum then 
				req.useGold = false
				Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaBuyShopItemRequest, req, MobaMsg_pb.MsgMobaBuyShopItemResponse, function(msg)
								 Global.DumpMessage(msg , "d:/MsgMobaBuyShopItemResponse.lua")
								if msg.code ~= ReturnCode_pb.Code_OK then
									Global.ShowError(msg.code)
								else
									MobaMainData.RequestData()
									MainCityUI.UpdateRewardData(msg.fresh)
									Global.ShowReward(msg.reward)
									OpenList(1)
								end
							end, true)
				return 
			else 
				tip = System.String.Format(TextMgr:GetText(Text.ui_moba_45), itemdata.needGold *useNum)
				req.useGold = true
				MessageBox.Show(tip, function() 
					Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaBuyShopItemRequest, req, MobaMsg_pb.MsgMobaBuyShopItemResponse, function(msg)
									 Global.DumpMessage(msg , "d:/MsgMobaBuyShopItemResponse.lua")
									if msg.code ~= ReturnCode_pb.Code_OK then
										Global.ShowError(msg.code)
									else
										MobaMainData.RequestData()
										MainCityUI.UpdateRewardData(msg.fresh)
										Global.ShowReward(msg.reward)
										OpenList(1)
									end
								end, true)
				end, function() end)
			end 
		end)

		GUIMgr:CreateMenu("MobaStoreBuy" , false)
	end
end

local function GuildUseMultiPressCallback(UseItemId ,  btn)
	print("UseMultiPressCallback ",UseItemId)
	local itemdata = MobaItemData.GetItemDataByUid(UseItemId)
	local itemLocal = TableMgr:GetMobaShopItemTable()[UseItemId]
	if itemdata ~= nil then
		print("UseMultiPressCallback ",UseItemId,itemdata.exchangeId)
		local useNum = 1
		local tip = ""
		local req = GuildMobaMsg_pb.GuildMobaBuyShopItemRequest()
		req.exchangeId = UseItemId
		req.num = 1

		if MoneyListData.GetDiamond() < itemdata.needGold *useNum then
				Global.ShowNoEnoughMoney()
		else
			Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaBuyShopItemRequest, req, GuildMobaMsg_pb.GuildMobaBuyShopItemResponse, function(msg)
				 Global.DumpMessage(msg , "d:/GuildMobaBuyShopItemResponse.lua")
				if msg.code ~= ReturnCode_pb.Code_OK then
					Global.ShowError(msg.code)
				else
					MobaMainData.RequestData()
					MainCityUI.UpdateRewardData(msg.fresh)
					Global.ShowReward(msg.reward)
					OpenList(1,true)
				end
			end, true)
		end
	end
end


function ItemSortFunction(v1, v2)
    return v1.itemId > v2.itemId
end

function LoadItemList(_grid,objitem)
    
	for i=0, _grid.transform.childCount-1 do
		local chatitem = _grid.transform:GetChild(i)
		chatitem.gameObject:SetActive(false)
	end
	
	local total =0
	local tableData = MobaItemData.GetData()
	-- table.sort(tableData, ItemSortFunction)
	for i=1,#tableData do
		local item = tableData[i]
		local obj = nil 
		local childCount = _grid.transform.childCount
		if childCount > tonumber(total)  then
			obj = _grid.transform:GetChild(tonumber(total)).gameObject
		else
			obj = NGUITools.AddChild( _grid.gameObject,objitem)
		end 

		obj:SetActive(true)
		
		local itemData = TableMgr:GetItemData(item.itemId)

		local uiItem = {}
		
		uiItem.icon = obj.transform:Find("item/Texture"):GetComponent("UITexture")
		uiItem.name = obj.transform:Find("name"):GetComponent("UILabel")
		uiItem.num = obj.transform:Find("button/Label"):GetComponent("UILabel")
		uiItem.have = obj.transform:Find("have"):GetComponent("UILabel")
		uiItem.frame = obj.transform:Find("item"):GetComponent("UISprite")
		uiItem.btnBuy = obj.transform:Find("button"):GetComponent("UIButton")
		uiItem.quality = obj.transform:Find("item"):GetComponent("UISprite")
		uiItem.btnBuySp = obj.transform:Find("button"):GetComponent("UISprite")
		uiItem.btnBuyIconSp = obj.transform:Find("button/Sprite"):GetComponent("UISprite")
		local cost = item.needScore
		if Global.GetMobaMode() == 2 then
			uiItem.btnBuyIconSp.atlas = uiItem.btnBuySp.atlas
			uiItem.btnBuyIconSp.spriteName = "icon_gold"
			
			local shopItem = TableMgr:GetGuildWarShopDataByID(item.itemId)
		
			local cost = tonumber(shopItem.NeedGold)
			if cost ==0 then 
				local t = string.split(shopItem.MultipleGold,';')
				if tonumber(item.curBuyNum)>=#(t) then 
				  cost = t[#t]
				else
				  cost = t[tonumber(item.curBuyNum)+1]
				end 
			end 
			
		end

		
		

		local bagData = MobaPackageItemData.GetItemDataByUid(item.itemId)

		if itemData~= nil then 
			uiItem.icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
			uiItem.name.text = TextUtil.GetItemName(itemData)
			uiItem.num.text = cost -- item.needScore
			uiItem.have.text = ""
			if bagData ~= nil then 
				-- uiItem.have.text = System.String.Format(TextMgr:GetText(Text.ui_worldmap_70), bagData.number)
			end 
			uiItem.quality.enabled = true
			uiItem.quality.spriteName = "bg_item" .. itemData.quality
		end
		
		obj.name = item.exchangeId
		
		SetClickCallback(uiItem.btnBuy.gameObject, function(go)
			if Global.GetMobaMode() == 1 then
				UseMultiPressCallback(tonumber(go.transform.parent.gameObject.name) ,  go)
			elseif Global.GetMobaMode() == 2 then
				GuildUseMultiPressCallback(tonumber(go.transform.parent.gameObject.name) ,  go)
			end
		end)
		uiItem.itemData = itemData
		UIUtil.SetClickCallback(uiItem.frame.gameObject, function()
			if _ui.tooltip ~= uiItem then
				local itemData = uiItem.itemData
				--Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
				-- print_r(itemData)
				ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
				-- _ui.tooltip = uiItem
			else
				_ui.tooltip = nil
			end
		end)
		total = total +1
		
	end
	
	local count = _grid.transform.childCount

	while (count>total) do
		GameObject.Destroy(_grid.transform:GetChild(count-1).gameObject)
		count = count-1
	end

	_grid:Reposition()
	
end

function ShowItemTip(itemTip , showType)
	local uiCamera = UICamera.current
	local current = uiCamera.currentTouch.current
	local root = current:GetComponent("UIRect").root
		
	
	local itemTipTransform = _ui.list_ui[1].desc_root
	local itemTipWidget = itemTipTransform:Find("base"):GetComponent("UISprite")

	itemTipTransform:Find("base/name"):GetComponent("UILabel").text = itemTip.name
	itemTipTransform:Find("base/desc"):GetComponent("UILabel").text = itemTip.text


	-- itemTipTransform:SetParent(root.transform, false)
	itemTipTransform.gameObject:SetActive(true)
		
    NGUITools.BringForward(itemTipTransform.gameObject)
   -- UIUtil.RepositionTooltip(itemTipWidget)
	RePositionItem(itemTipTransform,UICamera.lastEventPosition)
end

function RePositionItem(tra, position)
	local gameObject = tra.gameObject

	local size = Vector2(256,124)
	local uiCamera = NGUITools.FindCameraForLayer(gameObject.layer)

	if uiCamera ~= nil then
		position.x = Mathf.Clamp01(position.x / Screen.width)
		position.y = Mathf.Clamp01(position.y / Screen.height)
		
		local activeSize = uiCamera.orthographicSize / tra.parent.lossyScale.y
		local ratio = (Screen.height * 0.5) / activeSize

		local max = Vector2(ratio * size.x / Screen.width, ratio * size.y / Screen.height)

		position.x = Mathf.Min(position.x, 1 - max.x)
		position.y = Mathf.Max(position.y, max.y)

		tra.position = uiCamera:ViewportToWorldPoint(position)
		position = tra.localPosition
		position.x = Mathf.Round(position.x) + 220
		position.y = Mathf.Round(position.y) - 110
		tra.localPosition = position
	else
		if position.x + size.x > Screen.width then
			position.x = Screen.width - size.x
		end
		if position.y - size.y < 0 then
			position.y = size.y
		end
		position.x = position.x - Screen.width * 0.5 + 220
		position.y = position.y - Screen.height * 0.5- 110
	end
	
	tra.localPosition = position
	tra.localSize = size
end

function ShowHeroTip(heroID,item)
	local uiCamera = UICamera.current
	local current = uiCamera.currentTouch.current
	local root = current:GetComponent("UIRect").root
		

	local itemTipTransform = _ui.list_ui[3].desc_root
	local itemTipWidget = itemTipTransform:Find("base"):GetComponent("UISprite")

	local itemData = TableMgr:GetHeroData(heroID)
	

	if itemData ~= nil then
		itemTipTransform:Find("name"):GetComponent("UILabel").text = TextMgr:GetText(itemData.nameLabel)
		itemTipTransform:Find("head/Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/herohead/", itemData.icon)
		itemTipTransform:Find("head"):GetComponent("UISprite").spriteName = "bg_item" .. itemData.quality
	end 
	
	local _grid = itemTipTransform:Find("Grid"):GetComponent("UIGrid")
	local heroInfo = MobaHeroListData.GetDefaultHeroData(itemData, item.HeroLevel, item.HeroStar)
	--local attributes = MobaHeroListData.GetAttributes(heroInfo)[2]

	local heroData = TableMgr:GetHeroData(heroID)

	local total =0
	
	for i=0, _grid.transform.childCount-1 do
		local chatitem = _grid.transform:GetChild(i)
		chatitem.gameObject:SetActive(false)
	end

	--print(heroID)
	local totalAttributes = {}

	for k, it in pairs(TableMgr:GetMobaShopHeroTable()) do
		if k ==heroID then 
			local t = string.split(it.HeroAttribute,';')
			for i = 1,#(t) do
				local b = {}
				local eff = string.split(t[i] , ',')
				b.BonusType = tonumber(eff[1])
				b.Attype =  tonumber(eff[2])
				b.Value =  tonumber(eff[3])
				table.insert(totalAttributes, b)  
				local attributeID = Global.GetAttributeLongID(b.BonusType, b.Attype)
				--print(attributeID)
				local attributeData = TableMgr:GetNeedTextData(attributeID)
				if attributeData then
					local obj = nil 
					local childCount = _grid.transform.childCount
					if childCount > tonumber(total)  then
						obj = _grid.transform:GetChild(tonumber(total)).gameObject
					else
						obj = NGUITools.AddChild( _grid.gameObject,_grid.transform:GetChild(0).gameObject)
					end 

					obj:SetActive(true)

					obj:GetComponent("UILabel").text = TextMgr:GetText(attributeData.unlockedText)
					obj.transform:Find("number1"):GetComponent("UILabel").text = Global.GetHeroAttrValueString(attributeData.additionAttr, b.Value)
					obj.transform:Find("number1"):GetComponent("UILabel").color = b.Value > 0 and Color.green or Color.white
					
					total = total +1
				end
			end
		end 
	end 
	
	--print_r(totalAttributes)


	_grid:Reposition()
	

	-- itemTipTransform:SetParent(root.transform, false)
	itemTipTransform.gameObject:SetActive(true)
		
    NGUITools.BringForward(itemTipTransform.gameObject)
   -- UIUtil.RepositionTooltip(itemTipWidget)
	RePositionHero(itemTipTransform,UICamera.lastEventPosition)
end


function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end


function RePositionHero(tra, position)
	local gameObject = tra.gameObject

	local size = Vector2(256,360)
	local uiCamera = NGUITools.FindCameraForLayer(gameObject.layer)

	if uiCamera ~= nil then
		position.x = Mathf.Clamp01(position.x / Screen.width)
		position.y = Mathf.Clamp01(position.y / Screen.height)
		
		local activeSize = uiCamera.orthographicSize / tra.parent.lossyScale.y
		local ratio = (Screen.height * 0.5) / activeSize

		local max = Vector2(ratio * size.x / Screen.width, ratio * size.y / Screen.height)

		position.x = Mathf.Min(position.x, 1 - max.x)
		position.y = Mathf.Max(position.y, max.y)

		tra.position = uiCamera:ViewportToWorldPoint(position)
		position = tra.localPosition
		position.x = Mathf.Round(position.x) + 220
		position.y = Mathf.Round(position.y) - 110
		tra.localPosition = position
	else
		if position.x + size.x > Screen.width then
			position.x = Screen.width - size.x
		end
		if position.y - size.y < 0 then
			position.y = size.y
		end
		position.x = position.x - Screen.width * 0.5 + 220
		position.y = position.y - Screen.height * 0.5- 110
	end
	
	tra.localPosition = position
	tra.localSize = size
end

function OnUICameraClick(go)
	for i = 1,3,1 do
		if _ui.list_ui[i].desc_root ~= nil then 
			_ui.list_ui[i].desc_root.gameObject:SetActive(false)
		end 
	end 
    Tooltip.HideItemTip()
    if go ~= _ui.tooltip then
        _ui.tooltip = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
	for i = 1,3,1 do
		if _ui.list_ui[i].desc_root ~= nil then 
			_ui.list_ui[i].desc_root.gameObject:SetActive(false)
		end 
	end 
end

function LoadTechList(_grid,objitem,tableData)
    local total =0
	
	for _, item in pairs(tableData) do
		local obj = nil 
		local childCount = _grid.transform.childCount
		if childCount > tonumber(total)  then
			obj = _grid.transform:GetChild(tonumber(total)).gameObject
		else
			obj = NGUITools.AddChild( _grid.gameObject,objitem)
		end 

		obj:SetActive(true)
		
		local uiItem = {}
		uiItem.btnBuy = obj.transform:Find("button"):GetComponent("UIButton")
		uiItem.num = obj.transform:Find("button/Label"):GetComponent("UILabel")
		uiItem.icon = obj.transform:Find("item/Texture"):GetComponent("UITexture")
		uiItem.icon.mainTexture = ResourceLibrary:GetIcon("Item/", item.Icon)
		if System.String.IsNullOrEmpty(item.Name) then 
			obj.transform:Find("name"):GetComponent("UILabel").text = ""
		else
			obj.transform:Find("name"):GetComponent("UILabel").text = TextMgr:GetText(item.Name)
		end
		obj.name = item.id
		
		SetClickCallback(uiItem.btnBuy.gameObject, function(go)
			local req = MobaMsg_pb.MsgMobaUpgradeTechRequest()
			req.techId = tonumber(go.transform.parent.gameObject.name)
			req.useGold = false
			Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaUpgradeTechRequest, req, MobaMsg_pb.MsgMobaUpgradeTechResponse, function(msg)
				-- Global.DumpMessage(msg , "d:/moba5.lua")
				if msg.code ~= ReturnCode_pb.Code_OK then
					Global.ShowError(msg.code)
				else
					
				end
			end, true)
		end)
		
		total = total +1
	end
	_grid:Reposition()
end

function HeroSortFunction(v1, v2)
    local heroData1 = TableMgr:GetHeroData(v1.baseid)
    local heroData2 = TableMgr:GetHeroData(v2.baseid)
    if heroData1.expCard and not heroData2.expCard or not heroData1.expCard and heroData2.expCard then
        return not heroData1.expCard and heroData2.expCard
    else
        if v1.HeroLevel == v2.HeroLevel then
            if heroData1.quality == heroData2.quality then
                if v1.HeroStar == v2.HeroStar then
                    if v1.grade == v2.grade then
                        return v1.baseid < v2.baseid
                    end
                    return v1.grade < v2.grade
                end
                return v1.HeroStar > v2.HeroStar
            end
            return heroData1.quality > heroData2.quality
        end
        return v1.HeroLevel > v2.HeroLevel
    end
end

function LoadHeroList(_grid,objitem,_tableData)
    local total =0

	local tableData ={}
	for k, item in pairs(_tableData) do
		local item ={}
		item.expCard = true
		item.grade = 1
		item.HeroStar = _tableData[k].HeroStar
		item.HeroLevel = _tableData[k].HeroLevel
		item.SlgskillId = _tableData[k].SlgskillId
		item.HeroAttribute = _tableData[k].HeroAttribute
		item.IsSold = _tableData[k].IsSold
		item.NeedScore = _tableData[k].NeedScore
		item.NeedGold = _tableData[k].NeedGold
		item.PaceNeed = _tableData[k].PaceNeed
		item.baseid = k
		table.insert(tableData,item)
	end 
	
	table.sort(tableData, HeroSortFunction)
	
	for i=0, _grid.transform.childCount-1 do
		local chatitem = _grid.transform:GetChild(i)
		chatitem.gameObject:SetActive(false)
	end
	
	for _, item in pairs(tableData) do
		local k = item.baseid
		if item.IsSold == 1 and MobaHeroListData.HasGeneralByBaseID(k) == false then 
			local obj = nil 
			local childCount = _grid.transform.childCount
			if childCount > tonumber(total)  then
				obj = _grid.transform:GetChild(tonumber(total)).gameObject
			else
				obj = NGUITools.AddChild( _grid.gameObject,objitem)
			end 
			
			local uiItem = {}
			
			uiItem.icon = obj.transform:Find("Icon"):GetComponent("UITexture")
			uiItem.name = obj.transform:Find("Name"):GetComponent("UILabel")
			uiItem.btnBuy = obj.transform:Find("button"):GetComponent("UIButton")
			uiItem.frame = obj.transform:Find("Icon")
			uiItem.num = obj.transform:Find("button/Label"):GetComponent("UILabel")
			uiItem.lv = obj.transform:Find("Level"):GetComponent("UILabel")
			uiItem.stars = obj.transform:Find("Stars"):GetComponent("UISprite")
			
			local itemData = TableMgr:GetHeroData(k)
			uiItem.stars.width = tonumber(item.HeroStar)* 30
			
			if itemData ~= nil then
				uiItem.icon.mainTexture = ResourceLibrary:GetIcon("Icon/herohead/", itemData.icon)
				uiItem.name.text = TextMgr:GetText(itemData.nameLabel)
				obj.transform:Find("Background"):GetComponent("UISprite").spriteName = "head" .. itemData.quality
			end 
			uiItem.lv.text = item.HeroLevel
			uiItem.num.text = item.NeedScore
			UIUtil.SetClickCallback(uiItem.frame.gameObject, function(go)
				if _ui.tooltip ~= uiItem then
					local itemData = uiItem.itemData
					-- Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
					ShowHeroTip(tonumber(go.transform.parent.gameObject.name),item)
					_ui.tooltip = uiItem
				else
					_ui.tooltip = nil
				end
			end)
			obj.name = k
			
				SetClickCallback(uiItem.btnBuy.gameObject, function(go)
					local req = MobaMsg_pb.MsgMobaExchangeHeroRequest()
					req.heroId = tonumber(go.transform.parent.gameObject.name)
					if item.PaceNeed > MobaData.GetMobaState() then 
						MessageBox.Show(TextMgr:GetText(Text.Code_NextStage))
						return 
					end 
					
					
					if MobaMainData.GetData().data.mobaScore >= item.NeedScore then 
						req.useGold = false
						Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaExchangeHeroRequest, req, MobaMsg_pb.MsgMobaExchangeHeroResponse, function(msg)
							Global.DumpMessage(msg , "d:/MsgMobaExchangeHeroResponse.lua")
							if msg.code ~= ReturnCode_pb.Code_OK then
								Global.ShowError(msg.code)
							else
								MobaMainData.RequestData()
								MainCityUI.UpdateRewardData(msg.fresh)
								FloatText.Show(TextMgr:GetText("login_ui_pay1"), Color.green)
								--Global.ShowReward(msg.reward)
								OpenList(3)
							end
						end, true)
						return 
					else
						tip = System.String.Format(TextMgr:GetText(Text.ui_moba_45), item.NeedGold)
						req.useGold = true
						
						MessageBox.Show(tip, function() 
							Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaExchangeHeroRequest, req, MobaMsg_pb.MsgMobaExchangeHeroResponse, function(msg)
								Global.DumpMessage(msg , "d:/MsgMobaExchangeHeroResponse.lua")
								if msg.code ~= ReturnCode_pb.Code_OK then
									Global.ShowError(msg.code)
								else
									MobaMainData.RequestData()
									MainCityUI.UpdateRewardData(msg.fresh)
									FloatText.Show(TextMgr:GetText("login_ui_pay1"), Color.green)
									--Global.ShowReward(msg.reward)
									OpenList(3)
								end
							end, true)
						end, function() end)
					end 
				end)
			
			obj:SetActive(true)
			-- obj.transform:Find("2/before"):GetComponent("UILabel").text = str 
			total = total +1
		end
	end
	_grid:Reposition()
end

function Close()
	RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
	MobaMainData.RemoveListener(UpdateData)
	MobaPackageItemData.RemoveListener(UpdateItemList)
	Tooltip.HideItemTip()
	for i = 1,3,1 do
		if _ui.list_ui[i].desc_root ~= nil then 
			_ui.list_ui[i].desc_root.gameObject:SetActive(false)
		end 
	end 
	MobaTechData.ReleaseUI()
    _ui = nil
end

function Show()
    Global.OpenUI(_M)
end

function SelectPage(id)
	
	coroutine.start(function()
		coroutine.step()
		_ui.list_ui[id].page:Set(true)
		OpenList(id,true)
	end)
end 

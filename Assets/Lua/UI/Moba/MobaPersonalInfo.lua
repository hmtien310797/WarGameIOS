module("MobaPersonalInfo", package.seeall)
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
local CharId
local CharName

local MsgInfo

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
	_ui.info = MsgInfo
    local closeButton = transform:Find("Marchlist/Container/bg_frane/bg_top/btn_close")
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, CloseAll)
    _ui.list_ui = {}
	_ui.cur_select_index =-1
	
	
    local RootTrf = transform:Find("Marchlist/Container/bg_frane")

    for i = 1,2,1 do
        _ui.list_ui[i] = {}
        _ui.list_ui[i].count = 0
        _ui.list_ui[i].msg = nil
        _ui.list_ui[i].list = {}
        _ui.list_ui[i].grid = RootTrf:Find("right/Scroll View"..i.."/Grid"):GetComponent("UIGrid")
     --   _ui.list_ui[i].scroll_view = RootTrf:Find("bg2/content"..i.."/Scroll View"):GetComponent("UIScrollView")
		if RootTrf:Find("right/Scroll View"..i.."/list_mobasoldier") ~= nil then
			_ui.list_ui[i].item = RootTrf:Find("right/Scroll View"..i.."/list_mobasoldier").gameObject
			_ui.list_ui[i].item:SetActive(false)
		elseif RootTrf:Find("right/Scroll View"..i.."/list_mobahero") ~= nil then
			_ui.list_ui[i].item = RootTrf:Find("right/Scroll View"..i.."/list_mobahero").gameObject
			_ui.list_ui[i].item:SetActive(false)
		end
        _ui.list_ui[i].root = RootTrf:Find("right/Scroll View"..i).gameObject
        _ui.list_ui[i].page = RootTrf:Find("right/page"..i):GetComponent("UIToggle")
    --    _ui.list_ui[i].root:SetActive(i==1 and true or false)
    --    _ui.list_ui[i].notice = RootTrf:Find("bg2/page"..i.."/red")
    --    _ui.list_ui[i].notice.gameObject:SetActive(false)
	--	 RootTrf:Find("bg2/page"..i):GetComponent("UIToggledObjects").enabled = false
		 
		_ui.list_ui[i].desc_root = RootTrf:Find("right/desc_list")

        
        UIUtil.SetClickCallback(_ui.list_ui[i].page.gameObject,function()
            OpenList(i,true)
        end)
    end 
	_ui.totalHero = RootTrf:Find("right/totalHero"):GetComponent("UILabel")
	_ui.totalArmy = RootTrf:Find("right/totalArmy"):GetComponent("UILabel")
	
	_ui.marchspd_lv = RootTrf:Find("left/Tech/marchno/lv"):GetComponent("UILabel")
--	_ui.marchno_lv = RootTrf:Find("left/Tech/marchno/lv"):GetComponent("UILabel")
	_ui.limit_lv = RootTrf:Find("left/Tech/limit/lv"):GetComponent("UILabel")
--	_ui.capacity_lv = RootTrf:Find("left/Tech/capacity/lv"):GetComponent("UILabel")
	_ui.rally_lv = RootTrf:Find("left/Tech/rally/lv"):GetComponent("UILabel")
	_ui.radar_lv = RootTrf:Find("left/Tech/radar/lv"):GetComponent("UILabel")
	
	_ui.marchspd_num = RootTrf:Find("left/Tech/marchno/number"):GetComponent("UILabel")
--	_ui.marchno_num = RootTrf:Find("left/Tech/marchno/number"):GetComponent("UILabel")
	_ui.limit_num = RootTrf:Find("left/Tech/limit/number"):GetComponent("UILabel")
--	_ui.capacity_num = RootTrf:Find("left/Tech/capacity/number"):GetComponent("UILabel")
	_ui.rally_num = RootTrf:Find("left/Tech/rally/number"):GetComponent("UILabel")
	_ui.radar_num = RootTrf:Find("left/Tech/radar/number"):GetComponent("UILabel")
	
	_ui.totalScore = RootTrf:Find("left/head/point"):GetComponent("UILabel")
	_ui.curScore = RootTrf:Find("left/head/recover"):GetComponent("UILabel")
	_ui.name = RootTrf:Find("left/head/name"):GetComponent("UILabel")
	_ui.head = RootTrf:Find("left/head/Texture"):GetComponent("UITexture")
	
	_ui.flag = RootTrf:Find("left/bg/flag/Label"):GetComponent("UILabel")
	
	_ui.roleName = RootTrf:Find("left/head/character"):GetComponent("UILabel")
	_ui.roleIcon = RootTrf:Find("left/head/character/Sprite"):GetComponent("UISprite")
	
	RootTrf:Find("left/Tech/capacity").gameObject:SetActive(false)
	
	OpenList(1)
	AddDelegate(UICamera, "onClick", OnUICameraClick)
	AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
	MobaMainData.AddListener(UpdateData)
	MobaPackageItemData.AddListener(UpdateItemList)
	UpdateData()
	
	_ui.btnInfo = RootTrf:Find("left/head/character/Sprite")
	SetClickCallback(_ui.btnInfo.gameObject, function(go)
		
		local role = TableMgr:GetMobaRoleTable()[_ui.info.role]
	
		if role ~=nil then 
			local descs = string.split(role.description, ";")
			local desc =""
			
			for i=1,#descs do
				desc = desc..TextMgr:GetText(descs[i])
				desc = desc.."\n"
			end
			
			Tooltip.ShowItemTip({name = TextMgr:GetText(role.Name), text = desc})
		end 
		
		
		
	end)
end

function GetTechById(id)
	for i=1,#_ui.info.techs do 
		if _ui.info.techs[i].techId == id then
			return _ui.info.techs[i]
		end 
	end 
	local info = MobaData_pb.MobaTechInfo()
	info.techId = 0
	info.level = 0
	info.param = 0
	return info
end 

function UpdateData()

	_ui.marchspd_lv.text = "Lv"..GetTechById(1).level
	_ui.limit_lv.text = "Lv"..GetTechById(6).level
	_ui.rally_lv.text = "Lv"..GetTechById(7).level
	_ui.radar_lv.text = "Lv"..GetTechById(9).level
	
	
	_ui.marchspd_num.text = GetTechById(1).param
	_ui.limit_num.text = GetTechById(6).param
	_ui.rally_num.text = GetTechById(7).param
	_ui.radar_num.text = GetTechById(9).param
	
	_ui.totalScore.text = System.String.Format(TextMgr:GetText("ui_moba_104"),_ui.info.maxScore)
	_ui.curScore.text = System.String.Format(TextMgr:GetText("ui_moba_105"),_ui.info.scoreInc,_ui.info.scoreInc-_ui.info.baseScoreInc)
	_ui.name.text = _ui.info.name
	_ui.head.mainTexture = ResourceLibrary:GetIcon("Icon/head/", _ui.info.face)
	
	if _ui.info.team ==1 then 
		_ui.flag.text = TextMgr:GetText("moba_mapzone1")
	else
		_ui.flag.text = TextMgr:GetText("moba_mapzone2")
	end 
	
	local role = TableMgr:GetMobaRoleTable()[_ui.info.role]
	
	if role ~=nil then 
		_ui.roleIcon.spriteName = role.Icon
		_ui.roleName.text = TextMgr:GetText(role.Name)
	else
		_ui.roleIcon.spriteName = ""
		_ui.roleName.text = TextMgr:GetText("")
	end 
end 

function UpdateItemList()
	--LoadArmyList(_ui.list_ui[1].grid,_ui.list_ui[1].item)
end 

function CloseCurList()
    if _ui.cur_select_index >= 1  and _ui.list_ui[_ui.cur_select_index] ~= nil then
        --_ui:StopListCountDown(_ui.cur_select_index)   
        _ui.list_ui[_ui.cur_select_index].root:SetActive(false)
    end
end

function OpenList(index,reload) 
	print("openlist ",index)
	if _ui.cur_select_index ~= index then
        CloseCurList()
        _ui.cur_select_index = index
    end
	
	if index == 1 then 
		_ui.totalHero.gameObject:SetActive(false)
		_ui.totalArmy.gameObject:SetActive(true)
	else 
		_ui.totalHero.gameObject:SetActive(true)
		_ui.totalArmy.gameObject:SetActive(false)
	end 

  --  _ui.list_ui[_ui.cur_select_index].notice.gameObject:SetActive(false)
    _ui.list_ui[_ui.cur_select_index].root:SetActive(true)
	
	if index ==1 then 
		LoadArmyList(_ui.list_ui[1].grid,_ui.list_ui[1].item)
	elseif index ==2 then 
		LoadHeroList(_ui.list_ui[2].grid,_ui.list_ui[2].item,TableMgr:GetMobaShopHeroTable())
	end

end


function LoadArmyList(_grid,objitem)
    local total =0
	
	for i=0, _grid.transform.childCount-1 do
		local chatitem = _grid.transform:GetChild(i)
		chatitem.gameObject:SetActive(false)
	end
	local totalCount =0
	local armys = _ui.info.armys --MobaBarrackData.GetArmy()
	-- table.sort(tableData, ItemSortFunction)
	local ignore = {"RuneData", "SelectArmy", "TalentInfo", "EquipData", "BattleMove","MainData","MainCityUI","Barrack_SoldierEquipData","Laboratory","GeneralData"}
	AttributeBonus.CollectBonusInfo(ignore)
	
	for i=1,#armys do
		local army = armys[i]
		local obj = nil 
		local childCount = _grid.transform.childCount
		if childCount > tonumber(total)  then
			obj = _grid.transform:GetChild(tonumber(total)).gameObject
		else
			obj = NGUITools.AddChild( _grid.gameObject,objitem)
		end 

		obj:SetActive(true)
	
		local uiItem = {}
		
		uiItem.icon = obj.transform:Find("bg/icon"):GetComponent("UITexture")
		uiItem.name = obj.transform:Find("bg/name text"):GetComponent("UILabel")
		uiItem.num = obj.transform:Find("bg/num"):GetComponent("UILabel")

		
		uiItem.BattleAttackNum= obj.transform:Find("info/ATK/num"):GetComponent("UILabel")
	    uiItem.BattleAttackExtra= obj.transform:Find("info/ATK/num"):GetComponent("UILabel")
        
	    uiItem.BattleHpNum = obj.transform:Find("info/HP/num"):GetComponent("UILabel")
	    uiItem.BattleHpExtra = obj.transform:Find("info/HP/num"):GetComponent("UILabel")

		uiItem.BattleDefendNum = obj.transform:Find("info/DEF/num"):GetComponent("UILabel")
	    uiItem.BattleDefendExtra = obj.transform:Find("info/DEF/num"):GetComponent("UILabel")
		
		
		uiItem.num.text = army.num
		totalCount =  totalCount + army.num

		local soldierData = TableMgr:GetBarrackData(army.id,army.lv)

		uiItem.name.text = TextMgr:GetText(soldierData.SoldierName) --.."  LV."..soldier_data.Grade
		uiItem.icon.mainTexture = ResourceLibrary:GetIcon ("Icon/Unit/", soldierData.SoldierIcon)
	
		uiItem.BattleAttackExtra.text = math.floor(army.atk + 0.5) .. " [00ff00](+" .. math.floor(army.atk - soldierData.Attack + 0.5) .. ")[-]"
		uiItem.BattleHpExtra.text = math.floor(army.hp + 0.5) .. " [00ff00](+" .. math.floor(army.hp - soldierData.Hp + 0.5) .. ")[-]"
		uiItem.BattleDefendExtra.text = math.floor(army.def + 0.5) .. " [00ff00](+" .. math.floor(army.def - soldierData.fakeArmo + 0.5) .. ")[-]"
	
		total = total +1
		
	end
	_ui.totalArmy.text = System.String.Format(TextMgr:GetText("wall_army_num"),totalCount)
	local count = _grid.transform.childCount

	while (count>total) do
		GameObject.Destroy(_grid.transform:GetChild(count-1).gameObject)
		count = count-1
	end

	_grid:Reposition()
	
end


function ShowHeroTip(heroID,item)
	local uiCamera = UICamera.current
	local current = uiCamera.currentTouch.current
	local root = current:GetComponent("UIRect").root
		

	local itemTipTransform = _ui.list_ui[2].desc_root
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

	_grid:Reposition()

	itemTipTransform.gameObject:SetActive(true)
		
    NGUITools.BringForward(itemTipTransform.gameObject)
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
	for i = 1,2,1 do
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
	for i = 1,2,1 do
		if _ui.list_ui[i].desc_root ~= nil then 
			_ui.list_ui[i].desc_root.gameObject:SetActive(false)
		end 
	end 
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

function HasGeneralByBaseID(id)
	for i=1,#_ui.info.heros do
		if _ui.info.heros[i].baseId ==id then 
			return true
		end
	end 
	return false
end 

function LoadHeroList(_grid,objitem,_tableData)
    local total =0
	
	local totalCount =0

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
	
	for _, item in pairs(tableData) do
		local k = item.baseid
		if HasGeneralByBaseID(k) == true then 
			local obj = nil 
			local childCount = _grid.transform.childCount
			if childCount > tonumber(total)  then
				obj = _grid.transform:GetChild(tonumber(total)).gameObject
			else
				obj = NGUITools.AddChild( _grid.gameObject,objitem)
			end 
			
			local uiItem = {}
			
			uiItem.icon = obj.transform:Find("listitem_hero/head icon"):GetComponent("UITexture")
			uiItem.name = obj.transform:Find("name text"):GetComponent("UILabel")
			uiItem.frame = obj.transform:Find("listitem_hero/head icon")
			uiItem.lv = obj.transform:Find("listitem_hero/level text"):GetComponent("UILabel")
			uiItem.stars = obj.transform:Find("listitem_hero/star"):GetComponent("UISprite")
			
			local itemData = TableMgr:GetHeroData(k)
			uiItem.stars.width = tonumber(item.HeroStar)* 30
			totalCount = totalCount +1
			if itemData ~= nil then
				uiItem.icon.mainTexture = ResourceLibrary:GetIcon("Icon/herohead/", itemData.icon)
				uiItem.name.text = TextMgr:GetText(itemData.nameLabel)
				obj.transform:Find("listitem_hero/head icon/outline"):GetComponent("UISprite").spriteName = "head" .. itemData.quality
			end 
			uiItem.lv.text = item.HeroLevel
			UIUtil.SetClickCallback(uiItem.frame.gameObject, function(go)
				if _ui.tooltip ~= uiItem then
					local itemData = uiItem.itemData
					local t = go.transform.parent
					ShowHeroTip(tonumber(t.parent.gameObject.name),item)
					_ui.tooltip = uiItem
				else
					_ui.tooltip = nil
				end
			end)
			obj.name = k

			obj:SetActive(true)
			total = total +1
		end
	end
	_ui.totalHero.text = System.String.Format(TextMgr:GetText("ui_moba_131"),totalCount)
	_grid:Reposition()
end

function Close()
	RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
	MobaMainData.RemoveListener(UpdateData)
	MobaPackageItemData.RemoveListener(UpdateItemList)
	Tooltip.HideItemTip()
	for i = 1,2,1 do
		if _ui.list_ui[i].desc_root ~= nil then 
			_ui.list_ui[i].desc_root.gameObject:SetActive(false)
		end 
	end 
	MobaTechData.ReleaseUI()
    _ui = nil
end

function Show(charId)
	if Global.GetMobaMode() == 1 then
		if charId == nil then 
			charId = MobaMainData.GetCharId()
			--charName = MainData.GetCharName()
		end 
		CharId = charId
		print("_______________charid ",charId)
		local req = MobaMsg_pb.MsgMobaUserDetailInfoRequest()
		req.charId = charId
		Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaUserDetailInfoRequest, req, MobaMsg_pb.MsgMobaUserDetailInfoResponse, function(msg)
			Global.DumpMessage(msg,"D:/MsgMobaUserDetailInfoResponse.lua")
			if msg.code == ReturnCode_pb.Code_OK then
				MsgInfo = msg.info
				Global.OpenUI(_M)
			end
		end, true)
	else
	
	end

end

function SelectPage(id)
	
	coroutine.start(function()
		coroutine.step()
		_ui.list_ui[id].page:Set(true)
		OpenList(id,true)
	end)
end 

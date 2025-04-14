module("RebelArmyAttack", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String

local _ui

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

--[[
local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	local param = GetParameter(go)
	if param ~= nil then
		local param = param:split("_")
		if param[1] == "item" then
			local itemdata = TableMgr:GetItemData(tonumber(param[2]))
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
			else
			    if itemTipTarget == go then
			        Tooltip.HideItemTip()
			    else
			        itemTipTarget = go
			        Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
			    end
			end
		else
			local itemdata = TableMgr:GetHeroData(tonumber(param[2]))
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = TextMgr:GetText(itemdata.nameLabel), text = TextMgr:GetText(itemdata.description)})
		    else
		        if itemTipTarget == go then
		            Tooltip.HideItemTip()
		        else
		            itemTipTarget = go
		            Tooltip.ShowItemTip({name = TextMgr:GetText(itemdata.nameLabel), text = TextMgr:GetText(itemdata.description)})
		        end
		    end
		end
	else
		Tooltip.HideItemTip()
	end
end
]]

function CloseSelf()
	Global.CloseUI(_M)
end

function CloseAll()
	ActivityAll.Hide()
	CloseSelf()
end

local function UpdateUI()
	if _ui.msg.lastStartTime == 0 then
		MessageBox.Show("获取的时间为0，请找程序查BUG")
		return
	end
	local targettime
	local timelabel
	local maxWave = RebelArmyAttackData.GetMaxWave(_ui.msg.siegeNumber)
	if _ui.msg.isOpen then
		_ui.opened.go:SetActive(true)
		_ui.notopened.go:SetActive(false)
		_ui.btn_left.gameObject:SetActive(true)
		_ui.btn_middle.gameObject:SetActive(false)
		_ui.btn_right.gameObject:SetActive(true)
		if UnionInfoData.HasUnion() and _ui.msg.isAttack then
			if _ui.msg.lastWave >= maxWave then
				targettime = _ui.msg.lastStartTime + tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.RebelArmyAttackDuration).value)
				_ui.opened.title_time.text = TextMgr:GetText("RebelArmyAttack_ui3")
			else
				targettime = _ui.msg.lastStartTime + tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.RebelArmyAttackCD).value)
				_ui.opened.title_time.text = TextMgr:GetText("RebelArmyAttack_ui52")
			end
			_ui.opened.text_title.text = TextMgr:GetText("SiegeMonster_" .. _ui.msg.lastWave) .. TextMgr:GetText("RebelArmyAttack_ui8")
			_ui.opened.text_power.text = String.Format(TextMgr:GetText("RebelArmyAttack_ui4"), TableMgr:GetSiegeMonsterFightByWave(_ui.msg.lastWave))
			_ui.rank_text.text = TextMgr:GetText("RebelArmyAttack_ui14")
			timelabel = _ui.opened.text_time
		else
			targettime = _ui.msg.lastStartTime + tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.RebelArmyAttackDuration).value)
			_ui.opened.text_title.text = TextMgr:GetText("SiegeMonster_" .. (_ui.msg.lastWave + 1))
			_ui.opened.text_power.text = String.Format(TextMgr:GetText("RebelArmyAttack_ui4"), TableMgr:GetSiegeMonsterFightByWave(_ui.msg.lastWave < maxWave and _ui.msg.lastWave + 1 or maxWave))
			_ui.opened.title_time.text = TextMgr:GetText("RebelArmyAttack_ui3")
			_ui.rank_text.text = TextMgr:GetText("RebelArmyAttack_ui14")
			timelabel = _ui.opened.text_time
			if _ui.msg.lastWave >= maxWave then
				_ui.opened.go:SetActive(false)
				_ui.notopened.go:SetActive(true)
				targettime = _ui.msg.lastStartTime + tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.RebelArmyAttackDuration).value)
				_ui.btn_left.gameObject:SetActive(false)
				_ui.btn_middle.gameObject:SetActive(true)
				_ui.btn_right.gameObject:SetActive(false)
				_ui.rank_text.text = TextMgr:GetText("RebelArmyAttack_ui14")
				_ui.notopened.title_time.text = TextMgr:GetText("RebelArmyAttack_ui3")
				_ui.notopened.text_desc.text = TextMgr:GetText("RebelArmyAttack_ui53")
				timelabel = _ui.notopened.text_time
				SetClickCallback(_ui.btn_middle, function()
					RebelArmyAttackRewards.Show(_ui.msg.siegeNumber)
				end)
			end
		end
		
		SetClickCallback(_ui.btn_left, function()
			RebelArmyAttackRewards.Show(_ui.msg.siegeNumber)
		end)
	else
		_ui.opened.go:SetActive(false)
		_ui.notopened.go:SetActive(true)
		targettime = _ui.msg.lastStartTime
		_ui.btn_left.gameObject:SetActive(false)
		_ui.btn_middle.gameObject:SetActive(true)
		_ui.btn_right.gameObject:SetActive(false)
		_ui.rank_text.text = TextMgr:GetText("RebelArmyAttack_ui13")
		_ui.notopened.title_time.text = TextMgr:GetText("RebelArmyAttack_ui2")
		_ui.notopened.text_desc.text = TextMgr:GetText("RebelArmyAttack_ui17")
		timelabel = _ui.notopened.text_time
		SetClickCallback(_ui.btn_middle, function()
			RebelArmyAttackRewards.Show(_ui.msg.siegeNumber)
		end)
		if _ui.msg.siegeNumber == 0 then
			_ui.btn_rank:SetActive(false)
		end
	end
	CountDown.Instance:Add("RebelArmyAttack",targettime,CountDown.CountDownCallBack(function(t)
        --if t:find("d") ~= nil then
        --	timelabel.text = String.Format(TextMgr:GetText("RebelArmyAttack_ui18"),t:split("d")[1])
        --else
        	timelabel.text = t
        --end
        if targettime <= Serclimax.GameTime.GetSecTime() then
        	RebelArmyAttackData.RequestSiegeMonsterInfo(function(msg)
				if _ui == nil then
					CountDown.Instance:Remove("RebelArmyAttack")
					return
				end
				_ui.msg = msg
				UpdateUI()
			end)
        end
    end))
    _ui.mybest_num.text = _ui.msg.bestScore
    _ui.mybest_num.transform.parent.gameObject:SetActive(_ui.msg.bestScore > 0)
    
    SetClickCallback(_ui.btn_right, function()
    	RebelArmyAttackData.RequestSiegeMonsterSearch(function(msg)
    		if msg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(msg.code)
				return
			end
			ActivityAll.CloseAll()
    		MainCityUI.ShowWorldMap(msg.entrypos.x, msg.entrypos.y, true)
    		if GUIMgr.Instance:IsMenuOpen("ActivityEntrance") then
    			GUIMgr:CloseMenu("ActivityEntrance")
    		end
    	end)
    end)
    while _ui.grid.transform.childCount > 0 do
		GameObject.DestroyImmediate(_ui.grid.transform:GetChild(0).gameObject)
	end
    local rewards = RebelArmyAttackData.GetRewardData(_ui.msg.isOpen and _ui.msg.siegeNumber or (_ui.msg.siegeNumber + 1))
    for i,v in ipairs(rewards[#rewards].awardlist) do
    	if v.contentType == 1 then
    		local itemdata = TableMgr:GetItemData(v.contentId)
			local item = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject).transform
			item.localScale = Vector3.one
			item:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", itemdata.icon)
			local num_item = item:Find("have")
			num_item.gameObject:SetActive(false)
			item:GetComponent("UISprite").spriteName = "bg_item" .. itemdata.quality
			local itemlvTrf = item.transform:Find("num")
			local itemlv = itemlvTrf:GetComponent("UILabel")
			itemlvTrf.gameObject:SetActive(true)
			if itemdata.showType == 1 then
				itemlv.text = Global.ExchangeValue2(itemdata.itemlevel)
			elseif itemdata.showType == 2 then
				itemlv.text = Global.ExchangeValue1(itemdata.itemlevel)
			elseif itemdata.showType == 3 then
				itemlv.text = Global.ExchangeValue3(itemdata.itemlevel)
			else 
				itemlvTrf.gameObject:SetActive(false)
			end
			SetParameter(item.gameObject, "item_" .. v.contentId)
			local ShowTooltip = function(go)
				if go == _ui.tipObject then
					_ui.tipObject = nil
				else
					_ui.tipObject = go
					Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
				end
			end
			SetClickCallback(item.gameObject, ShowTooltip)			
    	elseif v.contentType == 3 then
    		local heroData = TableMgr:GetHeroData(v.contentId)
			local hero = NGUITools.AddChild(_ui.grid.gameObject, _ui.hero.gameObject).transform
			hero.localScale = Vector3(0.6, 0.6, 1)
			hero:Find("level text").gameObject:SetActive(false)
			hero:Find("name text").gameObject:SetActive(false)
			hero:Find("bg_skill").gameObject:SetActive(false)
			hero:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
			hero:Find("head icon/outline"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
			local star = hero:Find("star"):GetComponent("UISprite")
			if star ~= nil then
		        star.width = v.star * star.height
		    end
			SetParameter(hero:Find("head icon").gameObject, "hero_" .. v.contentId)
			local ShowTooltip = function(go)
				if go == _ui.tipObject then
					_ui.tipObject = nil
				else
					_ui.tipObject = go
					Tooltip.ShowItemTip({name = TextMgr:GetText(heroData.nameLabel), text = TextMgr:GetText(heroData.description)})
				end
			end
			SetClickCallback(hero.gameObject, ShowTooltip)				
    	end
    end
    _ui.grid:Reposition()
end

function Awake()
	if _ui == nil then
		_ui = {}
	end
	_ui.container = transform:Find("Container").gameObject
	_ui.mask = transform:Find("mask").gameObject
	_ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	
	_ui.opened = {}
	_ui.opened.go = transform:Find("Container/bg_frane/bg_desc").gameObject
	_ui.opened.text_title = transform:Find("Container/bg_frane/bg_desc/text_title"):GetComponent("UILabel")
	_ui.opened.text_power = transform:Find("Container/bg_frane/bg_desc/text_power"):GetComponent("UILabel")
	_ui.opened.title_time = transform:Find("Container/bg_frane/bg_desc/title_time"):GetComponent("UILabel")
	_ui.opened.text_time = transform:Find("Container/bg_frane/bg_desc/text_time"):GetComponent("UILabel")
	
	_ui.notopened = {}
	_ui.notopened.go = transform:Find("Container/bg_frane/bg_desc (1)").gameObject
	_ui.notopened.text_desc = transform:Find("Container/bg_frane/bg_desc (1)/text_desc"):GetComponent("UILabel")
	_ui.notopened.title_time = transform:Find("Container/bg_frane/bg_desc (1)/title_time"):GetComponent("UILabel")
	_ui.notopened.text_time = transform:Find("Container/bg_frane/bg_desc (1)/text_time"):GetComponent("UILabel")
	
	_ui.mybest_num = transform:Find("Container/bg_frane/mybest/num"):GetComponent("UILabel")
	_ui.rank_text = transform:Find("Container/bg_frane/btn_rank/text"):GetComponent("UILabel")
	_ui.btn_rank = transform:Find("Container/bg_frane/btn_rank").gameObject
	_ui.btn_help = transform:Find("Container/bg_frane/btn_help").gameObject
	_ui.grid = transform:Find("Container/bg_frane/bg_rewards/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.btn_left = transform:Find("Container/bg_frane/button").gameObject
	_ui.btn_middle = transform:Find("Container/bg_frane/button (2)").gameObject
	_ui.btn_right = transform:Find("Container/bg_frane/button (1)").gameObject
	
	_ui.item = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	_ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
	
	--AddDelegate(UICamera, "onPress", OnUICameraPress)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)	

end

function Start()
	SetClickCallback(_ui.container, CloseAll)
	SetClickCallback(_ui.mask, CloseAll)
	SetClickCallback(_ui.btn_close, CloseSelf)
	SetClickCallback(_ui.btn_help, RebelArmyAttackHelp.Show)
	SetClickCallback(_ui.btn_rank, RebelArmyAttackrank.Show)
	UpdateUI()
	RebelArmyAttackData.NotifyUIOpened()
end

function Close()
	print(123)
	CountDown.Instance:Remove("RebelArmyAttack")
	_ui = nil
	--RemoveDelegate(UICamera, "onPress", OnUICameraPress)
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
	RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)	
	Tooltip.HideItemTip()	
end

function Show()
	RebelArmyAttackData.RequestSiegeMonsterInfo(function(msg)
		if _ui == nil then
			_ui = {}
		end
		_ui.msg = msg
		if msg.code == ReturnCode_pb.Code_OK then
			Global.OpenUI(_M)
		else
			Global.ShowError(msg.code)
		end
	end)
end

function RequestOpenUI(msg)
	if _ui == nil then
		_ui = {}
	end
	_ui.msg = msg
	if msg.code == ReturnCode_pb.Code_OK then
		Global.OpenUI(_M)
	else
		Global.ShowError(msg.code)
	end
end

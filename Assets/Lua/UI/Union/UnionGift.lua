module("UnionGift", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local GameObject = UnityEngine.GameObject
local AudioMgr = Global.GAudioMgr

local _ui
local TestGiftData
local forceUpdate



local ReloacUI

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end


local function GetExtraGift()
	local req = GuildMsg_pb.MsgOpenExtraChestRequest()
	Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgOpenExtraChestRequest, req, GuildMsg_pb.MsgOpenExtraChestResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			GUIMgr:SendDataReport("reward", "UnionGift Extra", "".. MoneyListData.ComputeDiamond(msg.fresh.money.money))
			--fresh data
			AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
			_ui.giftInfoMsg = msg
			MainCityUI.UpdateRewardData(msg.fresh)
			ReloacUI()
			
			ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
			ItemListShowNew.SetItemShow(msg)
			GUIMgr:CreateMenu("ItemListShowNew" , false)
		else
			Global.ShowError(msg.code)
		end
	end, false)
end

local function OpenUnionCardGift()
	local req = ShopMsg_pb.MsgIAPTakeGuildMonthCardRequest()
	Global.Request(Category_pb.Shop, ShopMsg_pb.ShopTypeId.MsgIAPTakeGuildMonthCardRequest, req, ShopMsg_pb.MsgIAPTakeGuildMonthCardResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
			--Global.DumpMessage(msg , "d:/IAPTakeGuildMonthCard.lua")
			MainCityUI.UpdateRewardData(msg.fresh)
			
			--UnionCardData.RequestData(0)
			--UnionInfoData.UpdateUnionGiftCountData(#msg.chestInfos)
			UnionCardData.SetUnionCardTaked(false)
			ReloacUI()
			--show 
			ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
			ItemListShowNew.SetItemShow(msg)
			GUIMgr:CreateMenu("ItemListShowNew" , false)
		else
			Global.ShowError(msg.code)
		end
	end, false)
end

local function OpenGiftCallback(giftuid , batch)
	--MsgOpenGuildChestRequest
	local req = GuildMsg_pb.MsgOpenGuildChestRequest()
	req.uid = giftuid
	req.batch = batch
	
	Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgOpenGuildChestRequest, req, GuildMsg_pb.MsgOpenGuildChestResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then
			GUIMgr:SendDataReport("reward", "UnionGift", "".. MoneyListData.ComputeDiamond(msg.fresh.money.money))
		
			if msg.guildMonthCardTaked then
				UnionCardData.SetUnionCardTaked(false)
				--UnionCardData.RequestData(0)
			end
			--fresh data
			AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
			
			_ui.giftInfoMsg = msg
			MainCityUI.UpdateRewardData(msg.fresh)
			UnionInfoData.UpdateUnionGiftCountData(#msg.chestInfos)
			ReloacUI()
			--show 
			ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
			ItemListShowNew.SetItemShow(msg)
			--ItemListShowNew.SetCloseMenuCallback(ReloacUI)
			GUIMgr:CreateMenu("ItemListShowNew" , false)
		else
			Global.ShowError(msg.code)
		end
	end, false)
end


local function UpdateGiftListItem(info , index , realInde)
	--print(info , index , realInde)
	--local v = _ui.giftInfoMsg.chestInfos[realInde+1]
	local ginfo = _ui.giftList[realInde+1]
	if ginfo ~= nil then
		local v = ginfo.data
		info.name = "gift_" .. ginfo.type .. "_" .. v.uid
		if ginfo.type == 0 then 
			--gift info
			local giftData = TableMgr:GetUnionItemData(v.itemId)
			local itemIcon = info.transform:Find("bg/Texture"):GetComponent("UITexture")
			itemIcon.mainTexture = ResourceLibrary:GetIcon("Item/", giftData.icon)
			
			--gift owner
			local ownerLabel = info.transform:Find("bg/giver text"):GetComponent("UILabel")
			ownerLabel.text = System.String.Format(TextMgr:GetText("union_gift_people") , v.charName)--v.charName .. "的礼物"
			
			--gift name
			local name = info.transform:Find("bg/name"):GetComponent("UILabel")
			name.text = TextMgr:GetText(giftData.name)
			--gift quality
			local quality  = info.transform:Find("bg/name/quality"):GetComponent("UISprite")
			quality.spriteName = "gift_" .. giftData.quality
			
			--gift end time
			local giftMsg = ginfo
			table.insert(_ui.giftUpdateList,giftMsg)
			--print(v.uid)
			
			--btn open
			
			SetClickCallback(info.transform:Find("bg/ok btn").gameObject , function(go)
				OpenGiftCallback(v.uid , false)
			end)
		elseif ginfo.type == 1 then
			local ownerLabel = info.transform:Find("bg/giver text"):GetComponent("UILabel")
			ownerLabel.text = System.String.Format(TextMgr:GetText("union_gift_people") , v.charName)--v.charName .. "的礼物"
			
			--gift name
			local name = info.transform:Find("bg/name"):GetComponent("UILabel")
			name.text = TextMgr:GetText("Union_Mcard_ui4")
			
			local giftMsg = ginfo
			table.insert(_ui.giftUpdateList,giftMsg)
			
			SetClickCallback(info.transform:Find("bg/ok btn").gameObject , function(go)
				OpenUnionCardGift()
			end)
		end
	end
end

local function WrapUpdateUIContent()
	local datalength = 0
	if _ui.giftInfoMsg.chestInfos ~= nil then
		for i=1 , #_ui.giftInfoMsg.chestInfos do
			table.insert(_ui.giftList , {type = 0 , data = _ui.giftInfoMsg.chestInfos[i]})
		end
		datalength = #_ui.giftInfoMsg.chestInfos
	end
	print(datalength)
	
	local unionCard =  UnionCardData.GetAvailableCard(0)
	--Global.DumpMessage(unionCard,"d:/cardInfo.lua")
	if unionCard ~= nil and unionCard.buyed and unionCard.cantake then
		local ucardGift = GuildMsg_pb.GuildChestInfo()
		ucardGift.charName = unionCard.buyer
		ucardGift.endTime = Global.GetFiveOclockCooldown()
		table.insert(_ui.giftList , {type = 1 , data = ucardGift})
		datalength = datalength + 1
	end
	
	print(datalength)
	UnionInfo.UpdateGiftCount(datalength)

	--print(_ui.giftInfoMsg.giftExp , TableMgr:GetUnionGiftExpData(1) , #_ui.giftInfoMsg.chestInfos , Serclimax.GameTime.GetSecTime() , _ui.giftInfoMsg.giftLevel)
	_ui.giftCount.text = System.String.Format(TextMgr:GetText("union_gift_num")  , #_ui.giftList)
	_ui.giftLevelLabel.text = System.String.Format(TextMgr:GetText("union_gift_lv")  , _ui.giftInfoMsg.giftLevel)
	_ui.giftLevelSlider.value = tonumber(_ui.giftInfoMsg.giftExp) / tonumber(TableMgr:GetUnionGiftExpData(_ui.giftInfoMsg.giftLevel).exp)
	_ui.giftLevelValue1.text = _ui.giftInfoMsg.giftExp
	_ui.giftLevelValue2.text = TableMgr:GetUnionGiftExpData(_ui.giftInfoMsg.giftLevel).exp
	--_ui.giftLevelValue2.text = "[ffffff]" .. _ui.giftInfoMsg.giftExp .. "[-]/[fff600]" .. TableMgr:GetUnionGiftExpData(_ui.giftInfoMsg.giftLevel).exp .. "[-]"
	if _ui.giftInfoMsg.canOpenExtraChest then
		_ui.giftExtraBtn.gameObject:SetActive(true)
		_ui.giftExtraBtn_effect1.gameObject:SetActive(true)
		_ui.giftExtraBtn_effect2.gameObject:SetActive(true)		
		SetClickCallback(_ui.giftExtraBtn.gameObject , GetExtraGift)
	else	
		_ui.giftExtraBtn_effect1.gameObject:SetActive(false)
		_ui.giftExtraBtn_effect2.gameObject:SetActive(false)		
		_ui.giftExtraBtn.gameObject:SetActive(false)
	end
	
	SetClickCallback(_ui.giftGetAllBtn.gameObject , function(go)
		OpenGiftCallback(0,true)
	end)

	_ui.noGift.gameObject:SetActive(#_ui.giftList <= 0)
	if #_ui.giftList > 0 then
		_ui.giftGetAllBtn.isEnabled = true
		_ui.giftGetAllBtn.transform:GetComponent("BoxCollider").enabled = true
	else
		_ui.giftGetAllBtn.isEnabled = false
		_ui.giftGetAllBtn.transform:GetComponent("BoxCollider").enabled = false
	end

	local optGridTransform = _ui.giftScrollView.transform:Find("OptGrid")
	if optGridTransform ~= nil then
		GameObject.DestroyImmediate(optGridTransform.gameObject)
	end
		
	local wrapParam = {}
	wrapParam.OnInitFunc = UpdateGiftListItem
	wrapParam.itemSize = 250
	wrapParam.minIndex = 0
	wrapParam.maxIndex = (datalength-1)
	wrapParam.itemCount = datalength < 4 and datalength or 4-- 预设项数量。 -1为实际显示项数量
	wrapParam.cellPrefab = _ui.GiftItemPrefab
	wrapParam.localPos = Vector3(-238 , 0 , 0)
	wrapParam.cullContent = false
	wrapParam.moveDir = 2--horizal
	UIUtil.CreateWrapContent(_ui.giftScrollView , wrapParam , function(optGridTrf)
		_ui.giftGrid.transform = optGridTrf
	end)

	_ui.giftScrollView:ResetPosition()
	
end 



local function UpdateUIContent()
	local datalength = 0
	if _ui.giftInfoMsg.chestInfos ~= nil then
		for i=1 , #_ui.giftInfoMsg.chestInfos do
			table.insert(_ui.giftList , {type = 0 , data = _ui.giftInfoMsg.chestInfos[i]})
		end
		datalength = #_ui.giftInfoMsg.chestInfos
	end
	print(datalength)
	
	local unionCard =  UnionCardData.GetAvailableCard(0)
	--Global.DumpMessage(unionCard,"d:/cardInfo.lua")
	if unionCard ~= nil and unionCard.buyed and unionCard.cantake then
		local ucardGift = GuildMsg_pb.GuildChestInfo()
		ucardGift.charName = unionCard.buyer
		ucardGift.endTime = Global.GetFiveOclockCooldown()
		table.insert(_ui.giftList , {type = 1 , data = ucardGift})
		datalength = datalength + 1
	end
	
	print(datalength)
	UnionInfo.UpdateGiftCount(datalength)
	--gift count
	--print(_ui.giftInfoMsg.giftExp , TableMgr:GetUnionGiftExpData(1) , #_ui.giftInfoMsg.chestInfos , Serclimax.GameTime.GetSecTime() , _ui.giftInfoMsg.giftLevel , _ui.giftGrid)
	_ui.giftCount.text = System.String.Format(TextMgr:GetText("union_gift_num")  , #_ui.giftList)
	_ui.giftLevelLabel.text = System.String.Format(TextMgr:GetText("union_gift_lv")  , _ui.giftInfoMsg.giftLevel)
	_ui.giftLevelSlider.value = tonumber(_ui.giftInfoMsg.giftExp) / tonumber(TableMgr:GetUnionGiftExpData(_ui.giftInfoMsg.giftLevel).exp)
	_ui.giftLevelValue1.text = _ui.giftInfoMsg.giftExp
	_ui.giftLevelValue2.text = TableMgr:GetUnionGiftExpData(_ui.giftInfoMsg.giftLevel).exp
	
	
	--_ui.giftLevelValue2.text = "[ffffff]" .. _ui.giftInfoMsg.giftExp .. "[-]/[fff600]" .. TableMgr:GetUnionGiftExpData(_ui.giftInfoMsg.giftLevel).exp .. "[-]"
	if _ui.giftInfoMsg.canOpenExtraChest then
		_ui.giftExtraBtn.gameObject:SetActive(true)
		_ui.giftExtraBtn_effect1.gameObject:SetActive(true)
		_ui.giftExtraBtn_effect2.gameObject:SetActive(true)
		SetClickCallback(_ui.giftExtraBtn.gameObject , GetExtraGift)
	else	
		_ui.giftExtraBtn_effect1.gameObject:SetActive(false)
		_ui.giftExtraBtn_effect2.gameObject:SetActive(false)		
		_ui.giftExtraBtn.gameObject:SetActive(false)
	end
	
	SetClickCallback(_ui.giftGetAllBtn.gameObject , function(go)
		OpenGiftCallback(0,true)
	end)
	
	while _ui.giftGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(_ui.giftGrid.transform:GetChild(0).gameObject)
	end
	
	_ui.noGift.gameObject:SetActive(#_ui.giftList <= 0)	
	if #_ui.giftList > 0 then
		_ui.giftGetAllBtn.isEnabled = true
		_ui.giftGetAllBtn.transform:GetComponent("BoxCollider").enabled = true
	else
		_ui.giftGetAllBtn.isEnabled = false
		_ui.giftGetAllBtn.transform:GetComponent("BoxCollider").enabled = false
	end

	for _ , k in ipairs (_ui.giftList) do
		if k ~= nil then
			local ginfo = k
			local v = ginfo.data
			
			local info = NGUITools.AddChild(_ui.giftGrid.gameObject , _ui.GiftItemPrefab.gameObject)
			info.transform:SetParent(_ui.giftGrid.transform , false)
			info.gameObject:SetActive(true)
			info.gameObject.name = "gift_" .. ginfo.type .. "_" .. v.uid
			
			--info.name = "gift_" .. ginfo.type .. "_" .. v.uid
			if ginfo.type == 0 then 
				--gift info
				local giftData = TableMgr:GetUnionItemData(v.itemId)
				local itemIcon = info.transform:Find("bg/Texture"):GetComponent("UITexture")
				itemIcon.mainTexture = ResourceLibrary:GetIcon("Item/", giftData.icon)
				
				--gift owner
				local ownerLabel = info.transform:Find("bg/giver text"):GetComponent("UILabel")
				ownerLabel.text = System.String.Format(TextMgr:GetText("union_gift_people") , v.charName)--v.charName .. "的礼物"
				
				--gift name
				local name = info.transform:Find("bg/name"):GetComponent("UILabel")
				name.text = TextMgr:GetText(giftData.name)
				--gift quality
				local quality  = info.transform:Find("bg/name/quality"):GetComponent("UISprite")
				quality.spriteName = "gift_" .. giftData.quality
				
				--gift end time
				local giftMsg = ginfo
				table.insert(_ui.giftUpdateList,giftMsg)
				--print(v.uid)
				
				--btn open
				
				SetClickCallback(info.transform:Find("bg/ok btn").gameObject , function(go)
					OpenGiftCallback(v.uid , false)
				end)
			elseif ginfo.type == 1 then
				local ownerLabel = info.transform:Find("bg/giver text"):GetComponent("UILabel")
				ownerLabel.text = System.String.Format(TextMgr:GetText("union_gift_people") , v.charName)--v.charName .. "的礼物"
				
				--gift name
				local name = info.transform:Find("bg/name"):GetComponent("UILabel")
				name.text = TextMgr:GetText("Union_Mcard_ui4")
				
				local giftMsg = ginfo
				table.insert(_ui.giftUpdateList,giftMsg)
				
				SetClickCallback(info.transform:Find("bg/ok btn").gameObject , function(go)
					OpenUnionCardGift()
				end)
			end
		end
	end
	_ui.giftGrid:Reposition()
end



ReloacUI = function()
	if _ui == nil then
		return
	end
	
	_ui.giftUpdateList = {}
	_ui.giftList = {}
	
	--WrapUpdateUIContent()
	UpdateUIContent()
end

local function ForceUpdateGiftList(giftData)
	local forceUpdate = false
	local updateIndex = 1
	for _ , v in pairs(_ui.giftList) do
		if v.data.uid == giftData.data.uid then
			table.remove(_ui.giftList , updateIndex)
			forceUpdate = true
		end
		updateIndex = updateIndex + 1
	end
	if forceUpdate then
		if giftData.type == 1 then
			UnionCardData.SetUnionCardTaked(false)
		else
			ReloacUI()
		end
		
		if GUIMgr:FindMenu("UnionInfo") ~= nil then
			UnionInfo.UpdateGiftCount(#_ui.giftList)
		end
	end
end

local function UpdateGiftState()
	
end

local function UpdateGiftListState()
	if _ui.giftUpdateList ~= nil then
		local upIndex = 1
		for _ , k in ipairs(_ui.giftUpdateList) do
			local v = k
			if v ~= nil then
				--print(v.uid)
				local leftTimeSec = v.data.endTime - Serclimax.GameTime.GetSecTime()
				if leftTimeSec > 0 then
					local countDown = Global.GetLeftCooldownTextLong(v.data.endTime)
					--print(countDown , v.endTime )
					local updateItem = _ui.giftGrid.transform:Find("gift_" .. v.type .. "_" .. v.data.uid)
					if updateItem ~= nil then
						updateItem:Find("bg/time"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText("union_gift_time") , countDown)
					end
				else
					ForceUpdateGiftList(v)
				end
			end
			upIndex = upIndex + 1
		end
	end
end

function LateUpdate()
    UpdateGiftListState()
end

function LoadUI()
	--[[_ui.giftInfoMsg = {}
	_ui.giftInfoMsg.giftLevel = 3
	_ui.giftInfoMsg.giftExp = 4300
	_ui.giftInfoMsg.canOpenExtraChest = true
	_ui.giftInfoMsg.chestInfos = {}
	
	local index = 1
	for i=3105 , 3109 , 1 do
		local chestInfos = {}
		chestInfos.uid = i;			
		chestInfos.charId = 2;			
		chestInfos.charName = "yyy" .. i;		
		chestInfos.itemId = i;
		chestInfos.endTime = 1491383047 + index * 60;		
		index = index + 1
		table.insert(_ui.giftInfoMsg.chestInfos , chestInfos)
	end
	
	--_ui.giftInfoMsg = TestGiftData
	ReloacUI()]]
	
end


function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local closeButton = transform:Find("bg/titleBg/close btn")

    SetClickCallback(mask.gameObject, Hide)
    SetClickCallback(closeButton.gameObject, Hide)
	
	_ui.GiftItemPrefab = ResourceLibrary.GetUIPrefab("Union/listitem_gift")
	_ui.giftScrollView = transform:Find("bg2/Scroll View"):GetComponent("UIScrollView")
	_ui.giftGrid = transform:Find("bg2/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.giftCount = transform:Find("num bg/Label"):GetComponent("UILabel")
	_ui.giftLevelLabel = transform:Find("gife level widget/text"):GetComponent("UILabel")
	_ui.giftLevelSlider = transform:Find("gife level widget/coin bar"):GetComponent("UISlider")
	_ui.giftLevelValue1 = transform:Find("gife level widget/coin bar/mynum"):GetComponent("UILabel")
	_ui.giftLevelValue2 = transform:Find("gife level widget/coin bar/num"):GetComponent("UILabel")
	_ui.giftExtraBtn = transform:Find("gife level widget/gift btn"):GetComponent("UIButton")
	_ui.giftExtraBtn_effect1 = transform:Find("gife level widget/sfx")
	_ui.giftExtraBtn_effect2 = transform:Find("gife level widget/gift btn/sfxchixu")
	_ui.giftGetAllBtn = transform:Find("gife level widget/btn root"):GetComponent("UIButton")
	_ui.noGift = transform:Find("no one"):GetComponent("UILabel")
	
	EventDispatcher.Bind(UnionCardData.OnDataChange(), _M, EventDispatcher.HANDLER_TYPE.INSTANT, function(cardInfo, change)
		print("union card data : on data change")
		ReloacUI()
		if GUIMgr:FindMenu("UnionInfo") ~= nil and _ui ~= nil then
			UnionInfo.UpdateGiftCount(#_ui.giftList)
		end
    end)
	
	LoadUI()
end

function Close()
    _ui = nil
end

function Show()
	UnionCardData.RequestData(0)
	local req = GuildMsg_pb.MsgGuildGiftInfoRequest()
	Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildGiftInfoRequest, req, GuildMsg_pb.MsgGuildGiftInfoResponse, function(msg)
		if msg.code == ReturnCode_pb.Code_OK then

			Global.OpenUI(_M)
			_ui.giftInfoMsg = nil
			_ui.giftInfoMsg = msg
			ReloacUI()
			
		else
			Global.ShowError(msg.code)
		end
	end, false)

end

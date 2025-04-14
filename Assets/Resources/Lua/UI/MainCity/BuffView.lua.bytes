module("BuffView",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local BuffListData
local myBuff
local bScrollView
local bGrid
local bScrollViewItem
local jailBuffObject
local skinBuffObject
local bActiveBuffList

local detailScrollView
local detailGrid
local detailItem
local showDetail
local ReloadUI
local LoadBuffListUI
local curBuffDetail
local coroutineSet
local skinList

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local function QuitClickCallback(go)
	if detailScrollView.gameObject.activeSelf then
		detailScrollView.gameObject:SetActive(false)
		bScrollView.gameObject:SetActive(true)

		curBuffDetail = nil
	else
		Hide()
	end
end

local function BuyPressCallback(go, isPressed)
	if not isPressed then
		print("buybuybuy")
	end
end

local function CheckSameBuff(itemParam)
	local itemData = TableMgr:GetItemData(itemParam.itemid)
	local itemBagData = ItemListData.GetItemDataByBaseId(itemParam.itemid)
	local itemExchangeData = TableMgr:GetItemExchangeData(itemParam.exid)
	
	local buffdata = BuffData.HaveSameBuff(0 , itemData.param1)
	if buffdata ~= nil then
		
	else
		
	end
end

function UseItem(itemParam , number)
	local itemData = itemParam.itemData
	local itemBagData = itemParam.itemBagData
	
	local req = ItemMsg_pb.MsgUseItemRequest()
	if itemBagData ~= nil then
		req.uid = itemBagData.uniqueid
	else
		req.exchangeId = itemParam.exid
	end
	req.num = number
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemRequest, req, ItemMsg_pb.MsgUseItemResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
			if msg.code == ReturnCode_pb.Code_SceneMap_ShieldForbidden_WaringBuff then
				MessageBox.ShowCountDownMsg(TextMgr:GetText("WarCD_ui1"), BuffData.GetBuffByType({"1801"}).time)
			else
				Global.ShowError(msg.code)
			end
		else
			--useItemReward = msg.reward
			AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
			local nameColor = Global.GetLabelColorNew(itemData.quality)
			local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemData)..nameColor[1])
			FloatText.Show(showText , Color.white , ResourceLibrary:GetIcon("Item/", itemData.icon))
			AudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
			MainCityUI.UpdateRewardData(msg.fresh)
		end
	end , true)
end

local function UseClickCallback(itemParam ,UseFunc)
	print("use")
	local itemData = TableMgr:GetItemData(itemParam.itemid)
	local itemBagData = ItemListData.GetItemDataByBaseId(itemParam.itemid)
	
	if itemData ~= nil then
		local buffdata = BuffData.HaveSameBuff(0 , itemData.param1)
		itemParam.itemData = itemData
		itemParam.itemBagData = itemBagData
		local curTime = Serclimax.GameTime.GetSecTime()
		--print(curTime)
		if buffdata ~= nil and buffdata.time > curTime then
			local buffTableData = TableMgr:GetSlgBuffData(buffdata.buffId)
			print("========== buff data :" .. buffdata.uid .. " time :".. buffdata.time .. "build :" .. buffdata.buffMasterId)
			
			local okCallback = function()
				if UseFunc ~= nil then
					UseFunc(itemParam , 1)
				end
				CountDown.Instance:Remove("BuffCountDown")
				MessageBox.Clear()
			end
			local cancelCallback = function()
				if usebtn ~= nil and not usebtn:Equals(nil) then
					usebtn.transform:GetComponent("UIButton").enabled = true
				end
				CountDown.Instance:Remove("BuffCountDown")
				MessageBox.Clear()
			end
			
			MessageBox.Show(msg, okCallback, cancelCallback)
			local mbox = MessageBox.GetMessageBox()
			if mbox ~= nil then
				CountDown.Instance:Add("BuffCountDown",buffdata.time, function(t)
					mbox.msg.text = System.String.Format(TextMgr:GetText("speedup_ui5") , TextUtil.GetSlgBuffTitle(buffTableData) , t)
					if t == "00:00:00" then
						CountDown.Instance:Remove("BuffCountDown")
					end
				end)
			end
		else
			if UseFunc ~= nil then
				UseFunc(itemParam , 1)
			end
		end		
	end
end

local function OnAccelerateBtn(bufData)
	bScrollView.gameObject:SetActive(false)
	detailScrollView.gameObject:SetActive(true)
	
	curBuffDetail = bufData
	local activeBuffData = nil
	if bufData.activeBuff ~= nil then
		activeBuffData = TableMgr:GetSlgBuffData(bufData.activeBuff.buffId)
	end
	
	local childCount = detailGrid.transform.childCount
	while detailGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(detailGrid.transform:GetChild(0).gameObject);
	end
	
	local exitems = maincity.GetItemExchangeListNoCommon(bufData.baseData.exchange)
	for _ , v in pairs(exitems) do
		local itemBagData = ItemListData.GetItemDataByBaseId(v.itemid)
		if v.exid ~= 0 or itemBagData ~= nil then
			local exitem = NGUITools.AddChild(detailGrid.gameObject, detailItem.gameObject)
			exitem.gameObject:SetActive(true)
			exitem.transform:SetParent(detailGrid.transform , false)
			
			local itemData = TableMgr:GetItemData(v.itemid)	
			local itemExchangeData = TableMgr:GetItemExchangeData(v.exid)
			
			--icon
			local icon = exitem.transform:Find("bg_list/bg_icon/Texture"):GetComponent("UITexture")
			icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
			--name
			local name = exitem.transform:Find("bg_list/bg_top/text_type"):GetComponent("UILabel")
			local textColor
			if itemBagData ~= nil then
				textColor = Global.GetLabelColorNew(itemData.quality)
			else
				local exTBdata = TableMgr:GetItemData(itemExchangeData.item)
				textColor = Global.GetLabelColorNew(exTBdata.quality)
			end
			name.text = textColor[0] .. TextUtil.GetItemName(itemData) .. "[-]"
			--des
			local des = exitem.transform:Find("bg_list/text_mid"):GetComponent("UILabel")
			des.text = TextUtil.GetItemDescription(itemData)
			--quality
			local quabox = exitem.transform:Find("bg_list/bg_icon"):GetComponent("UISprite")
			quabox.spriteName = "bg_item" .. itemData.quality
			--level
			local itemlv = exitem.transform:Find("bg_list/bg_icon/num"):GetComponent("UILabel")
			if itemData.showType == 1 then
				itemlv.text = Global.ExchangeValue2(itemData.itemlevel)
			elseif itemData.showType == 2 then
				itemlv.text = Global.ExchangeValue1(itemData.itemlevel)
			elseif itemData.showType == 3 then
				itemlv.text = Global.ExchangeValue3(itemData.itemlevel)
			else 
				itemlv.gameObject:SetActive(false)
			end
			--bar
			local bar = exitem.transform:Find("bg_list/active")
			local bufTime = exitem.transform:Find("bg_list/active/bg_exp/bg/text"):GetComponent("UILabel")
			local barSlider = exitem.transform:Find("bg_list/active/bg_exp/bg/bar"):GetComponent("UISlider")
			
			if activeBuffData ~= nil and activeBuffData.item == v.itemid then
				bar.gameObject:SetActive((bufData.leftTime > 0))
				local updateTime = coroutine.start(function()
					while(detailScrollView ~= nil and detailScrollView.gameObject ~= nil and detailScrollView.gameObject.activeSelf) do
						if bufData.leftTime > 0 then
							if bufTime~= nil and not bufTime:Equals(nil) then
								bufTime.text = Serclimax.GameTime.SecondToString3(bufData.leftTime)
							end
							if barSlider~= nil and not barSlider:Equals(nil) then
								barSlider.value = ( bufData.leftTime / (itemData.param2 ) )
							end
						else
							if bar~= nil and not bar:Equals(nil) then
								bar.gameObject:SetActive(false)
							end
							coroutine.stop(updateTime)
						end
						coroutine.wait(1)
					end
					
				end)
				table.insert(coroutineSet , updateTime)
			else
				bar.gameObject:SetActive(false)
			end
			--num
			local useBtn = exitem.transform:Find("bg_list/btn_use")
			SetClickCallback(useBtn.gameObject, function(go)
				UseClickCallback(v ,UseItem)
			end)
			--buy button
			local buyBtn  = exitem.transform:Find("bg_list/btn_use_gold")
			SetClickCallback(buyBtn.gameObject, function(go) 
				UseClickCallback(v , UseItem)
			end)
			
			local num = exitem.transform:Find("bg_list/bg_top/num"):GetComponent("UILabel")
			if itemBagData ~= nil then
				useBtn.gameObject:SetActive(true)
				buyBtn.gameObject:SetActive(false)

				num.text = itemBagData.number
			else
				useBtn.gameObject:SetActive(false)
				buyBtn.gameObject:SetActive(true)

				num.text = "0"--"[ff0000]0[-]"
				local money = exitem.transform:Find("bg_list/btn_use_gold/num"):GetComponent("UILabel")
				money.text = itemExchangeData.price
			end
		end
	end
	detailGrid:Reposition()
end

--======================== data ========================
local function LoadActiveBuffData()
	for _ , v in pairs(BuffListData) do
		if v ~= nil and v.baseData ~= nil then
			local fBuffs = string.split(v.baseData.content , ";")
			local activeBuff = BuffData.GetBuffByType(fBuffs)
			v.activeBuff = activeBuff
		end
	end
end

local function LoadBuffListData()
	--table list
	BuffListData = {}
	local BuffTable = TableMgr:GetBuffShowList()
	for _ , v in pairs(BuffTable) do
		
        local data = v
		local bufListData = {}
		bufListData.baseData = data
		bufListData.activeBuff = nil
		bufListData.leftTime = 0
		bufListData.show = 1
		
		table.insert(BuffListData ,bufListData)
	end
	
	--my buff list
	--[[myBuff = BuffData.GetData()
	
	for _ , v in pairs(BuffListData) do
		if v ~= nil then
			local fBuffs = string.split(v.baseData.content , ";")
			local activeBuff = BuffData.GetBuffByType(fBuffs)
			v.activeBuff = activeBuff
		end
	end]]
	
end

local function SortBuffListData()
	-- 排序
	table.sort(BuffListData , function(v1 , v2)
		-- if (v1.activeBuff ~= nil) ~= (v2.activeBuff ~= nil) then
		-- 	return v1.activeBuff ~= nil
		-- end

		return v1.baseData.id < v2.baseData.id
	end)
end

---------================ update =======================
local function ClearBuffItem(buff)
	local reposition = false
	local delindex = 0
	for k , v in pairs(BuffListData) do
		if v ~= nil and v.baseData.id == buff.baseData.id then
			GameObject.DestroyImmediate(BuffListData[k].bg.gameObject);
			BuffListData[k] = nil
			--delindex = k
			reposition = true
		end
	end
	
	if reposition then
		bGrid:Reposition()
	end
	
end

local function UpdateBuff(buff)
	local active = (buff.activeBuff ~= nil)
	local detail = buff.bg:Find("bg_list/active")
	local bufftitle = buff.bg:Find("bg_list/bg_top/text_type"):GetComponent("UILabel")
	local buffdes = buff.bg:Find("bg_list/text_mid"):GetComponent("UILabel")
	local buffTime = buff.bg:Find("bg_list/active/bg_exp/bg/text").gameObject
	local tip_activated = buff.bg:Find("bg_list/active/bg_exp/bg/text01").gameObject
	local bSlider = detail:Find("bg_exp/bg/bar"):GetComponent("UISlider")

	buff.bg.gameObject.name = 9000 + buff.baseData.id - (active and 1000 or 0)
	
	-- 没有倒计时
	if buff.baseData.activation == 1 then --buff.baseData.content == "99" or buff.baseData.content == "98" then
		detail.gameObject:SetActive(true)
		bSlider.value = 1
		buffTime.gameObject:SetActive(false)
		tip_activated.gameObject:SetActive(true)
		bufftitle.text = TextMgr:GetText(buff.baseData.title)
		buffdes.text = TextMgr:GetText(buff.baseData.description)
		return
	end

	buffTime.gameObject:SetActive(true)
	tip_activated.gameObject:SetActive(false)
	if not active then
		if buff.baseData.show == 0 then
			ClearBuffItem(buff)
		else
			detail = buff.bg:Find("bg_list/active")
			detail.gameObject:SetActive(false)
			
			bufftitle.text = TextMgr:GetText(buff.baseData.title)
			buffdes.text = TextMgr:GetText(buff.baseData.description)
		end
		
		return
	end
	
	
	detail.gameObject:SetActive(true)
	local activeBuffData = TableMgr:GetSlgBuffData(buff.activeBuff.buffId)
	local buffItemData = TableMgr:GetItemData(activeBuffData.item)
	
	local bTime = detail:Find("bg_exp/bg/text"):GetComponent("UILabel")
	local leftTimeSec = buff.activeBuff.time - Serclimax.GameTime.GetSecTime()
	if leftTimeSec >= 0 then
		bTime.text = Serclimax.GameTime.SecondToString3(leftTimeSec)
		if buffItemData then
			if buffItemData.param2 > 0 then
				local start = buff.activeBuff.time - buffItemData.param2*1000
				bSlider.value = ( leftTimeSec / (buffItemData.param2 ) )
				buff.leftTime = leftTimeSec
			end

			bufftitle.text = "[00FF1EFF]" .. TextUtil.GetItemName(buffItemData) .. "[-]"
			buffdes.text = TextUtil.GetItemDescription(buffItemData)
		else
			bSlider.value = leftTimeSec / tonumber(activeBuffData.duration) * 1000
			buff.leftTime = leftTimeSec
		end
	else
		buff.activeBuff = nil
		--[[if buff.baseData.show == 0 then
			ReloadBuffItem()
		end]]
	end
end

function Update()
	if BuffListData == nil then
		return
	end
	
	for _ , v in pairs(BuffListData) do
		if v ~= nil and v.show == 1 then
			UpdateBuff(v)
		end
	end
end

--=================== show ===================================

local function UpdateActiveBuff()
	LoadActiveBuffData()
	for _ , v in pairs(BuffListData) do
		if v ~= nil and v.show == 1 then
			UpdateBuff(v)
		end
		
		if curBuffDetail ~= nil and v.baseData.id == curBuffDetail.baseData.id then
			OnAccelerateBtn(v)
		end
	end

	bGrid:Reposition()
end

local function HaveActiveBuff(bufListData)
	local fBuffs = string.split(bufListData.content , ";")
	local activeBuff = BuffData.GetBuffByType(fBuffs)
	return activeBuff
end

LoadBuffListUI = function()
	local childCount = bGrid.transform.childCount
	while bGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(bGrid.transform:GetChild(0).gameObject);
	end

    do
        local buffName, buffValue = JailInfoData.GetBuffNameValueText()
        if buffName ~= nil then
            local buffTransform = NGUITools.AddChild(bGrid.gameObject , jailBuffObject).transform
            buffTransform:Find("bg_list/text_mid"):GetComponent("UILabel").text = System.String.Format(TextMgr:GetText(Text.item_jailbuff_des), buffValue)
        end
    end
    do
        local buffTransform = NGUITools.AddChild(bGrid.gameObject , skinBuffObject).transform
        SetClickCallback(buffTransform:Find("bg_list/button").gameObject, function(go)
            bScrollView.gameObject:SetActive(false)
            detailScrollView.gameObject:SetActive(true)
            local skinInfoMsg = MainData.GetData().skin
            skinList = {}
            local skinsMsg = skinInfoMsg.skins
            for _, v in ipairs(skinsMsg) do
                if not Skin.IsDefaultSkin(v.id) then
                    table.insert(skinList, {data = tableData_tSkin.data[v.id], msg = v, itemDataList = Skin.GetItemDataList(v.id)})
                end
            end

            local skinGrid = detailGrid
            local skinPrefab = detailItem.gameObject
            for i, v in ipairs(skinList) do
                local skinTransform
                if i > skinGrid.transform.childCount then
                    skinTransform = NGUITools.AddChild(skinGrid.gameObject, skinPrefab).transform
                else
                    skinTransform = skinGrid.transform:GetChild(i - 1)
                end
                local skin = v
                local itemData = skin.itemDataList[1]
                print("skin id:", skin.data.id)
                local nameLabel = skinTransform:Find("bg_list/bg_top/text_type"):GetComponent("UILabel")
                local iconTexture = skinTransform:Find("bg_list/bg_icon/Texture"):GetComponent("UITexture")
                local attrLabel = skinTransform:Find("bg_list/text_mid"):GetComponent("UILabel")
                nameLabel.text = TextMgr:GetText(itemData.name)
                iconTexture.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", itemData.icon)
                skinTransform:Find("bg_list/bg_icon/num").gameObject:SetActive(false)
                skinTransform:Find("bg_list/btn_use_gold").gameObject:SetActive(false)
                skinTransform:Find("bg_list/btn_use").gameObject:SetActive(false)
                skinTransform:Find("bg_list/bg_top/num").gameObject:SetActive(false)
                skinTransform:Find("bg_list/active").gameObject:SetActive(false)
                skinTransform.gameObject:SetActive(true)

                local attrText = ""
                if skin.data.SkinAttribute ~= "" then
                    for vv in string.gsplit(skin.data.SkinAttribute, ";") do
                        local attrList = string.split(vv, ",")
                        local needData = TableMgr:GetNeedTextDataByAddition(tonumber(attrList[1]), tonumber(attrList[2]))
                        attrText = attrText .. TextMgr:GetText(needData.unlockedText) .. Global.GetHeroAttrValueString(needData.additionAttr, tonumber(attrList[3]))
                    end
                end
                attrLabel.text = attrText
            end
            for i = #skinList + 1, skinGrid.transform.childCount do
                skinGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
            end
        end)
    end

	for _ , v in pairs(BuffListData) do
		if v ~= nil and v.baseData ~= nil then
			local haveActive = HaveActiveBuff(v.baseData)
			if v.baseData.show == 1 or haveActive ~= nil --[[and haveActive.buffMasterType ~= Common_pb.BuffMasterType_Global]] then   -- 表中show字段不为 0 或者有对应buff激活时才显示
				local item = NGUITools.AddChild(bGrid.gameObject , bScrollViewItem.gameObject)
				item.gameObject:SetActive(true)
				item.gameObject.name = 9000 + v.baseData.id - (v.activeBuff ~= nil and 1000 or 0)
				item.transform:SetParent(bGrid.transform , false)
				
				v.show = 1
				local buffIcon = item.transform:Find("bg_list/bg_icon/Sprite"):GetComponent("UITexture")
				buffIcon.mainTexture = ResourceLibrary:GetIcon("Item/", v.baseData.icon)
				
				local bufftitle = item.transform:Find("bg_list/bg_top/text_type"):GetComponent("UILabel")
				local buffdes = item.transform:Find("bg_list/text_mid"):GetComponent("UILabel")
				bufftitle.text = TextMgr:GetText(v.baseData.title)
				buffdes.text = TextMgr:GetText(v.baseData.description)
				
				local buffDetail = item.transform:Find("bg_list/active")
				buffDetail.gameObject:SetActive(false)
				
				local accelerateBtn = item.transform:Find("bg_list/button"):GetComponent("BoxCollider")
				local RebelSurroundBtn = item.transform:Find("bg_list/button_miss"):GetComponent("BoxCollider")
				RebelSurroundBtn.gameObject:SetActive(false)
				if v.baseData.content == "99" then
					RebelSurroundBtn.gameObject:SetActive(true)
					SetClickCallback(RebelSurroundBtn.gameObject , function(go)
						Hide()
						RebelSurroundNew.Show()
					end)
				end

				--print(v.baseData.exchange)
				accelerateBtn.gameObject:SetActive(v.baseData.exchange > 0)
				SetClickCallback(accelerateBtn.gameObject , function(go)
					OnAccelerateBtn(v)
				end)
				
				v.bg = item.transform
			else
				v.show = 0
			end
		end
	end
	bGrid:Reposition()
end

function LoadUI()
	LoadActiveBuffData()
	-- SortBuffListData()
	LoadBuffListUI()
end


function GetActiveBuffInBufflist()
	if BuffListData == nil or #BuffListData == 0 then
		LoadBuffListData()
	end
	
	local activeNum = 0
	for k , v in pairs(BuffListData) do
		local activilable = string.split(v.baseData.content, ";")
		activeNum = activeNum + BuffData.GetBuffCountWithSameType(activilable)
	end
	
	return activeNum
end

function Awake()
	coroutineSet = {}
	BuffListData = nil
	BuffData.AddListener(UpdateActiveBuff)
	
	local closeBtn = transform:Find("BUFF/Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(closeBtn.gameObject , QuitClickCallback)
	
	local bgmask = transform:Find("mask")
	SetClickCallback(bgmask.gameObject , QuitClickCallback)
	
	bScrollView = transform:Find("BUFF/Container/bg_frane/Scroll View"):GetComponent("UIScrollView")
	bGrid = transform:Find("BUFF/Container/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
	
	detailScrollView = transform:Find("BUFF/Container/bg_frane/Scroll View Buff"):GetComponent("UIScrollView")
	detailGrid = transform:Find("BUFF/Container/bg_frane/Scroll View Buff/Grid"):GetComponent("UIGrid")

	bScrollViewItem = transform:Find("BUFF/ItemInfo")
	detailItem = transform:Find("BUFF/ExItemInfo")
	jailBuffObject = transform:Find("BUFF/0Jailbuff").gameObject
	skinBuffObject = transform:Find("BUFF/skin").gameObject
	
	LoadBuffListData()
	LoadUI()
end

function Close()
	BuffListData = nil
	BuffData.RemoveListener(UpdateActiveBuff)
	bScrollView = nil
	bGrid = nil
	bScrollViewItem = nil
	detailScrollView = nil
	detailGrid = nil
	detailItem = nil
	table.foreach(coroutineSet , function(_ ,v)
		coroutine.stop(v)
	
	end)
	
	
	coroutineSet = nil
end

function Show()
	Global.OpenUI(_M)
end

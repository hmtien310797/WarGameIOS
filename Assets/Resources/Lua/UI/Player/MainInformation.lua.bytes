module("MainInformation", package.seeall)

local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr.Instance
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local SetClickCallback = UIUtil.SetClickCallback
local GuideMgr = Global.GGuideManager
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local GameTime = Serclimax.GameTime
local NGUITools = NGUITools


moneyTypeList =
{
    Common_pb.MoneyType_Food,
    Common_pb.MoneyType_Iron,
    Common_pb.MoneyType_Oil,
    Common_pb.MoneyType_Elec,
}

local moneyIndexList = {}
for i, v in ipairs(moneyTypeList) do
    moneyIndexList[v] = i
end

moneyNameList =
{
    "food",
    "iron",
    "oil",
    "elec",
}

local _ui
local timer = 0

local headSelect
local MilitaryRankUI = {}
	
function LoadOfficialObject(official, officialTransform)
    official.transform = officialTransform
    official.nonObject = officialTransform:Find("text").gameObject
    official.bgObject = officialTransform:Find("bg_gov").gameObject
    official.viewButton = officialTransform:Find("bg_gov/btn (1)"):GetComponent("UIButton")
    official.editButton = officialTransform:Find("bg_gov/btn"):GetComponent("UIButton")
    official.icon = officialTransform:Find("bg_gov/gov_icon"):GetComponent("UITexture")
    official.nameLabel = officialTransform:Find("bg_gov/text"):GetComponent("UILabel")
end

function LoadOfficial(official, guildOfficialId, guildId, guildBanner, charId, charName)
    local myGuildId = UnionInfoData.GetGuildId()

    local isOfficial = guildOfficialId ~= 0
    local isLeader = UnionInfoData.IsUnionLeader()
    local isSelfGuild = guildId ~= 0 and myGuildId == guildId
    local hasField = StrongholdData.HasMyStronghold() or FortressData.HasMyFortress()
    local canChange = isLeader and isSelfGuild and hasField

    local bgVisible = isOfficial or canChange
    official.bgObject:SetActive(bgVisible)
    official.nonObject:SetActive(not bgVisible)
    if bgVisible then
        official.editButton.gameObject:SetActive(canChange)
        official.viewButton.gameObject:SetActive(not canChange)
        official.icon.gameObject:SetActive(isOfficial)
        local officialData
        if isOfficial then
            officialData = tableData_tUnionOfficial.data[guildOfficialId]
            official.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Government/", officialData.icon)
            official.nameLabel.text = TextMgr:GetText(officialData.name)
        else
            official.nameLabel.text = TextMgr:GetText(Text.GOV_ui62)
        end
        SetClickCallback(official.editButton.gameObject, function(go)
            local entryType
            if officialData ~= nil then
                entryType = officialData == 1 and Common_pb.SceneEntryType_Stronghold or Common_pb.SceneEntryType_Fortress
            end
            City_lord.Show(entryType, charId)
        end)

        SetClickCallback(official.viewButton.gameObject, function(go)
            Union_Officialinfo.Show(officialData, guildBanner, charName)
        end)
    end
end

local function LoadReward()
    local commanderMsg = MainData.GetCommanderInfo()
    local captived = commanderMsg.captived
    local kidnapper = _ui.kidnapper
    local totalReward = 0
    for i = 1, 4 do
        local rewardValue = 0
        local reward = commanderMsg.offerReward[i]
        if reward ~= nil then
            rewardValue = reward.value
        end
        kidnapper.rewardLabelList[i].text = Global.ExchangeValue(rewardValue + _ui.setReq.addReward[i].value)
        totalReward = totalReward + rewardValue
    end
    kidnapper.changeLabel.text = TextMgr:GetText(totalReward > 0 and Text.jail_16 or Text.jail_14)
    local level = MainData.GetLevel()
    local jailInfoData = TableMgr:GetJailInfoDataByLevel(level)
    _ui.minMoney = level * jailInfoData.ransomcoef
    local totoalMoney = 0
    for _, v in ipairs(_ui.setReq.addReward) do
        totoalMoney = totoalMoney + v.value
    end
    UIUtil.SetBtnEnable(kidnapper.setButton, "btn_3", "btn_4", captived == 1 and totoalMoney >= _ui.minMoney)
    SetClickCallback(kidnapper.setButton.gameObject, function(go)
        if captived ~= 1 then
            Global.FloatError(ReturnCode_pb.Code_Prison_CommanderIsBackHome)
            return
        end

        if totoalMoney < _ui.minMoney then
            FloatText.Show(TextMgr:GetText(Text.Code_Prison_Offer_Exceed_Min))
            return
        end

        MessageBox.Show(TextMgr:GetText(Text.jail_20), function()
            local req = _ui.setReq
            Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgPrisonSetRewardRequest, req, BuildMsg_pb.MsgPrisonSetRewardResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    FloatText.Show(TextMgr:GetText(Text.jail_38), Color.white)
                    for i = 1, 4 do
                        _ui.setReq.addReward[i].value = 0
                    end
                    MainData.RequestData()
                else
                    Global.ShowError(msg.code)
                end
            end, true)
        end,
        function()
        end)
    end)
end

local function UpdateTime()
    local commanderMsg = MainData.GetCommanderInfo()
    _ui.timeLabel.text = Global.GetLeftCooldownTextLong(commanderMsg.freeTime)
end

function ShowWantedPrice()
    WantedPrice.Show(_ui.setReq, function(setReq)
        _ui.setReq = setReq
        LoadReward()
    end)
end

function DisplayExpEffect(show)
	if show then
		_ui.explable_effect1.enabled = true;
		_ui.explable_effect1:Play(true,true)
		_ui.explable_effect2.gameObject:SetActive(true)
		_ui.explable_effect2:Play(true,true)
		_ui.explable_effect3.gameObject:SetActive(true)
		_ui.explable_effect3:Play(true,true)				
	else
		_ui.explable_effect1:Sample(0,false)
		_ui.explable_effect1.enabled = false
		_ui.explable_effect2.gameObject:SetActive(false)
		_ui.explable_effect3.gameObject:SetActive(false)
	end
end

local function CloseOtherUI()
	SoldierLevel.Hide(false)
	MilitaryRank.Hide()
	MainCityUI.UpdateTalent()
end

function MInfoUpdate()
	_ui.name_text.text = MainData.GetCharName()
	_ui.headTexture.mainTexture = ResourceLibrary:GetIcon("Icon/head/", MainData.GetFace())
	GOV_Util.SetFaceUI(_ui.MilitaryRank,MainData.GetData().militaryRankId)
	_ui.level.text = "LV." .. MainData.GetLevel()
	local expdata = TableMgr:GetPlayerExpData(MainData.GetLevel())
	local maxLevel = tonumber( TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PlayerMaxLevel).value)
	if MainData.GetLevel() >= maxLevel then
		_ui.explable.text = TextMgr:GetText("exp_max")
		DisplayExpEffect(false)
	else
		_ui.explable.text = MainData.GetExp().."/".. expdata.playerExp
		DisplayExpEffect(MainData.GetExp() > expdata.playerExp)
	end
	
	_ui.expslider.value = MainData.GetExp()/expdata.playerExp
	_ui.combat.text = MainData.GetData().pkvalue
	_ui.SoldierLevel.text = "Lv." .. MainData.GetData().commanderLeadLevel
	_ui.SoldierRed.gameObject:SetActive(SoldierLevel.CheckLevelUpdate() and FunctionListData.IsFunctionUnlocked(303))
	_ui.capacity.text = BattleMove.CalNormalBattleMoveMaxNum()
	
	if UnionInfoData.HasUnion() then
		local unionInfoMsg = UnionInfoData.GetData()
	    local unionMsg = unionInfoMsg.guildInfo
	    _ui.union.text = string.format("[%s]%s", unionMsg.banner, unionMsg.name)
	else
		_ui.union.text = "--"
	end
    _ui.id.text = MainData.GetCharId()
	

    -- 旗子
    local nationality = MainData.GetNationality()
    _ui.nationalFlag.mainTexture = UIUtil.GetNationalFlagTexture(nationality)
    _ui.nationalityNotice:SetActive(not ConfigData.HasSetNationality())

    local guildOfficialId = MainData.GetData().guildOfficialId
    LoadOfficial(_ui.official, guildOfficialId, UnionInfoData.GetGuildId(), UnionInfoData.GetGuildBanner(), MainData.GetCharId(), MainData.GetCharName())
    local commanderMsg = MainData.GetCommanderInfo()
    local captured = commanderMsg.captived ~= 0
    local captived = commanderMsg.captived

    _ui.btn_talent:SetActive(not captured)
    _ui.headedit:SetActive(not captured)
    _ui.midObject:SetActive(not captured)
    _ui.ransomObject:SetActive(captured)
    _ui.prisonObject:SetActive(captured)
    _ui.label_check.text = TextMgr:GetText(captured and Text.maincity_ui5 or Text.review_ui01)

    if captured then
        if UnityEngine.PlayerPrefs.GetInt("MainInformationPrisonHelp") == 0 then
            MapHelp.Open(2300, false, nil, nil, true)
            UnityEngine.PlayerPrefs.SetInt("MainInformationPrisonHelp", 1)
        end
    end
	SetClickCallback(_ui.btn_check, function(go)
        if not captured then
            BuildReview.Show()
        else
            Mail.SimpleWriteTo(commanderMsg.info.name)
        end
	end)

	SetClickCallback(_ui.prisonHelpObject, function(go)
        MapHelp.Open(2300, false, nil, nil, true)
    end)
	
    local kidnapperMsg = commanderMsg.info 
    local kidnapper = _ui.kidnapper
    local pos = commanderMsg.pos
    kidnapper.faceTexture.mainTexture = ResourceLibrary:GetIcon("Icon/head/", kidnapperMsg.face)
    kidnapper.nameLabel.text = kidnapperMsg.name
    kidnapper.levelLabel.text = "Lv." .. kidnapperMsg.level
    if kidnapperMsg.guildBanner ~= "" then
        kidnapper.unionLabel.text = string.format("[%s]%s", kidnapperMsg.guildBanner, kidnapperMsg.guildName)
        kidnapper.unionLabel.gameObject:SetActive(true)
    else
        kidnapper.unionLabel.gameObject:SetActive(false)
    end
    kidnapper.coordLabel.text = string.format("X:%dY:%d", pos.x, pos.y)
    UIUtil.SetBtnEnable(kidnapper.changeButton, "btn_1", "btn_4", captived == 1)
    SetClickCallback(kidnapper.headObject, function(go)
        OtherInfo.RequestShow(kidnapperMsg.id)
    end)
    SetClickCallback(kidnapper.coordLabel.gameObject, function(go)
		GUIMgr:CloseMenu("MainInformation")
		CloseOtherUI()
        MainCityUI.ShowWorldMap(pos.x, pos.y, true)
    end)

    SetClickCallback(kidnapper.changeButton.gameObject, function(go)
        if captived ~= 1 then
            Global.FloatError(ReturnCode_pb.Code_Prison_CommanderIsBackHome)
            return
        end

        ShowWantedPrice()
    end)
    table.sort(commanderMsg.ransom, function(v1, v2)
        return moneyIndexList[v1.id] < moneyIndexList[v2.id] 
    end)
    local totalRansom = 0
    for i = 1, 4 do
        local ransomValue = 0
        local ransom = commanderMsg.ransom[i]
        if ransom ~= nil then
            ransomValue = ransom.value
        end
        totalRansom = totalRansom + ransomValue
        kidnapper.ransomLabelList[i].text = Global.ExchangeValue(ransomValue)
    end
    local ransomRefuse = commanderMsg.ransomRefuse
    local rewardText
    if totalRansom == 0 then
        rewardText = Text.jail_25
        kidnapper.noticeObject:SetActive(false)
    elseif ransomRefuse then
        rewardText = Text.jail_31
        kidnapper.noticeObject:SetActive(false)
    else
        rewardText = Text.jail_17
        kidnapper.noticeObject:SetActive(true)
    end

    kidnapper.rewardLabel.text = TextMgr:GetText(rewardText)
    UIUtil.SetBtnEnable(kidnapper.rewardButton, "btn_1", "btn_4", totalRansom > 0 and not ransomRefuse)
    SetClickCallback(kidnapper.rewardButton.gameObject, function(go)
        if captived ~= 1 then
            Global.FloatError(ReturnCode_pb.Code_Prison_CommanderIsBackHome)
        elseif totalRansom == 0 then
            FloatText.Show(TextMgr:GetText(Text.jail_33))
        elseif ransomRefuse then
            FloatText.Show(TextMgr:GetText(Text.jail_24))
        else
            RansomPay.Show(commanderMsg)
        end
    end)
    LoadReward()
end

--退出战斗按钮
local function ClosePressCallback(go, isPressed)
	if not isPressed then
		GUIMgr:CloseMenu("MainInformation")
		CloseOtherUI()
	end
end

local function UseExpFunc(useItemId , exItemid , count)
	print("Useid : " .. useItemId .. "exid : " .. exItemid .. "count :" .. count)
	local itemTBData = TableMgr:GetItemData(useItemId)
	local itemdata = ItemListData.GetItemDataByBaseId(useItemId)

	local req = ItemMsg_pb.MsgUseItemRequest()
	if itemdata ~= nil then
		req.uid = itemdata.uniqueid
	else
		req.exchangeId = exItemid
	end
	req.num = count
	
	
	local lastLevel = MainData.GetLevel()
	Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemRequest, req, ItemMsg_pb.MsgUseItemResponse, function(msg)
		--print("use item code:" .. msg.code)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
			
		else
			local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
			if price == 0 then
				GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
			else
				GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
			end		
			useItemReward = msg.reward
			AudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
			
			local nameColor = Global.GetLabelColorNew(itemTBData.quality)
			local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1])
			FloatText.Show(showText , Color.white , ResourceLibrary:GetIcon("Item/", itemTBData.icon))
				
			MainCityUI.UpdateRewardData(msg.fresh)
		end
	end, true)
end



local function AddExpCallBack(go)
	
	local items = {}
	items = maincity.GetItemExchangeListNoCommon(10)
	
	local noirtem = Global.BagIsNoItem(items)
	local noItemHint = TextMgr:GetText("player_ui18")
	if noirtem == true then
		FloatText.Show(noItemHint)
		return
	end
	
	local maxLevel = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PlayerMaxLevel).value
	local maxHint = TextMgr:GetText("build_ui33")
	local myLevel = MainData.GetLevel()
	if myLevel >= tonumber(maxLevel) then
		AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
		FloatText.Show(maxHint , Color.green)
		return
	end
	
	CommonItemBag.SetTittle(TextMgr:GetText("player_ui16"))
	CommonItemBag.SetResType(Common_pb.MoneyType_None)
	CommonItemBag.SetItemList(items, 0)
	CommonItemBag.SetUseFunc(UseExpFunc)
	CommonItemBag.OnOpenCB = function()
	end
	GUIMgr:CreateMenu("CommonItemBag" , false)
	
end

function ChangeNameCallBack(msg)
	MainData.SetCharName(msg.charname)
	MainCityUI.UpdateRewardData(msg.fresh)
	CountListData.SetCount(msg.count)
	MInfoUpdate()
end

local function SureChangeFaceCallBack(go)
	local faceid = tonumber(go.gameObject.name)
	headSelect = faceid
end

local function SureChangeFace()
	if headSelect > 0 then
		local req = ClientMsg_pb.MsgChangeFaceRequest()
		req.faceid = headSelect
		Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgChangeFaceRequest, req, ClientMsg_pb.MsgChangeFaceResponse, function(msg)
			if msg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(msg.code)
			else
				_ui.ChangeHeadUi.gameObject:SetActive(false)
				_ui.PlayerInformation.gameObject:SetActive(true)
				MainData.SetFace(msg.faceid)
				MInfoUpdate()
			end
		end)
	end
end

local function UpdateTalent()
	local point = TalentInfoData.GetCurrentIndexRemainderPoint()
	_ui.talent_number.text = point
	FunctionListData.IsFunctionUnlocked(107, function(isactive)
		if _ui == nil then
			return
		end
		if isactive then
			if point > 0 then
				_ui.talent_fx:SetActive(true)
			else
				_ui.talent_fx:SetActive(false)
			end
		else
			_ui.talent_fx:SetActive(false)
		end
	end)
end

local function UpdateEquip()
    local functionUnlocked = FunctionListData.IsFunctionUnlocked(304)
	for i, v in ipairs(_ui.equips) do
		local eq = EquipData.GetCurEquipByPos(i)
		if functionUnlocked and (i < 7 or EquipData.IsUnlock(i)) then
			if eq ~= nil then
				v.quality.spriteName = "bg_item" .. eq.data.quality
				v.Texture.mainTexture = ResourceLibrary:GetIcon("Item/", eq.BaseData.icon)
				v.lock:SetActive(false)
				v.lunkuo:SetActive(false)
				v.effect:SetActive(false)
				v.level:SetActive(eq.BaseData.itemlevel >= 1)
				v.level_label.text = eq.BaseData.itemlevel
			else
				v.quality.spriteName = "bg_item_hui"
				v.Texture.mainTexture = nil
				v.lock:SetActive(false)
				v.lunkuo:SetActive(true)
				v.level:SetActive(false)
				local equiplist = EquipData.GetEquipListByPos(i)
				if #equiplist > 0 then
					local hasequip = false
					local level = MainData.GetLevel()
					for i, v in ipairs(equiplist) do
						if v.BaseData.charLevel <= level and v.data.status == 0 and v.data.parent.pos == 0 then
							hasequip = true
						end
					end
					v.effect:SetActive(hasequip)
				else
					v.effect:SetActive(false)
				end
			end
			SetClickCallback(v.go, function()
				--EquipChange.Show(i)
				EquipSelectNew.Show(i)
			end)
			v.red:SetActive(EquipData.IsCanUpgradeByPos(i))
		else
			v.quality.spriteName = "bg_item_hui"
			v.Texture.mainTexture = nil
			v.lock:SetActive(true)
			v.lunkuo:SetActive(false)
			v.level:SetActive(false)
			local text = functionUnlocked and TextMgr:GetText("equip_shiptishi" .. (i - 5)) or TextMgr:GetText(TableMgr:GetFunctionUnlockText(304))
			SetClickCallback(v.go, function()
				FloatText.ShowAt(v.go.transform.position,text, Color.white)
			end)
		end
	end
end

function Start()
	headSelect = 0
	MInfoUpdate()
	SetClickCallback(_ui.btn_add , AddExpCallBack)
	local myface = MainData.GetFace()
	local heads = TableMgr:GetItemDataByType(60 , 1)
	for i , v in pairs(heads) do
		local item = NGUITools.AddChild(_ui.headGrid.gameObject , _ui.headIte.gameObject)
		item.gameObject:SetActive(true)
		item.gameObject.name = tostring(heads[i].param1)
		item.transform:Find("icon_touxiang"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/head/" ,tostring(heads[i].param1))		
		item.transform:SetParent(_ui.headGrid , false)
		
		SetClickCallback(item.gameObject , SureChangeFaceCallBack)
		
		if heads[i].param1 == myface then
			local headTog = item.transform:GetComponent("UIToggle")
			headTog.value = true
		end
		
	end
	
	local headGridCom = _ui.headGrid:GetComponent("UIGrid")
	headGridCom:Reposition()
	local scrollv = _ui.headScrollView:GetComponent("UIScrollView")
	scrollv:ResetPosition()
	TalentInfoData.RequestData()
	UpdateTalent()
	UpdateEquip()
    local gov = transform:Find("Container/bg_franenew/bg_gov")
    if gov ~= nil then
        GOV_Util.SetGovInfoUI4MainInfo(gov)
    end	
    if _ui.toggleIndex ~= nil then
        _ui.tabs[_ui.toggleIndex].toggle.value = true
    end
    UpdateMilitaryRankNotice()
end

function ShowFace3D()
   -- _ui.face3D:SetActive(true)
   if _ui ~= nil then 
		local playerObject = transform:Find("Container/bg_franenew/mid/Zhihuiguan/Povit").gameObject
		playerObject:SetActive(true)
   end 
end

function HideFace3D()
	if _ui ~= nil then 
		local playerObject = transform:Find("Container/bg_franenew/mid/Zhihuiguan/Povit").gameObject
		playerObject:SetActive(false)
	end 
  --  _ui.face3D:SetActive(false)
end

function UpdateMilitaryRankNotice()
	_ui.militaryRankNotice:SetActive(MilitaryRankData.HasNotice())
end

function Awake()
    MilitaryRankData.RequestData()
    MainData.RequestCommanderInfo()
	_ui = {}
	_ui.setReq = BuildMsg_pb.MsgPrisonSetRewardRequest()
	for i = 1, 4 do
	    local reqReward = _ui.setReq.addReward:add()
	    reqReward.id = moneyTypeList[i] 
	    reqReward.value = 0
    end

	MainData.AddListener(MInfoUpdate)
	MainData.AddListener(UpdateEquip)
	_ui.PlayerInformation = transform:Find("Container")
	
	_ui.btn_close = transform:Find("Container/bg_franenew/btn_close").gameObject
	_ui.head = transform:Find("Container/bg_franenew/head").gameObject
	_ui.headTexture = transform:Find("Container/bg_franenew/head/Texture"):GetComponent("UITexture")
	_ui.MilitaryRank = transform:Find("Container/bg_franenew/head/MilitaryRank")
	_ui.headedit = transform:Find("Container/bg_franenew/head/talent").gameObject

	_ui.name = transform:Find("Container/bg_franenew/name").gameObject
	_ui.name_text = transform:Find("Container/bg_franenew/name/Label"):GetComponent("UILabel")

	_ui.expslider = transform:Find("Container/bg_franenew/addexp"):GetComponent("UISlider")
	_ui.btn_add = transform:Find("Container/bg_franenew/addexp/button").gameObject
	_ui.explable = transform:Find("Container/bg_franenew/addexp/jindu/Label"):GetComponent("UILabel")

	_ui.explable_effect1 = transform:Find("Container/bg_franenew/addexp/jindu/Label"):GetComponent("TweenAlpha")
	_ui.explable_effect2 = transform:Find("Container/bg_franenew/addexp/jindu/Texture"):GetComponent("TweenAlpha")
	_ui.explable_effect3 = transform:Find("Container/bg_franenew/addexp/jindu/Label (1)"):GetComponent("TweenAlpha")

	DisplayExpEffect(false)
	_ui.level = transform:Find("Container/bg_franenew/addexp/level"):GetComponent("UILabel")
	

	_ui.equips = {}
	for i = 1, 9 do
		_ui.equips[i] = {}
		_ui.equips[i].go = transform:Find(String.Format("Container/bg_franenew/mid/equip0{0}", i)).gameObject
		_ui.equips[i].quality = _ui.equips[i].go:GetComponent("UISprite")
		_ui.equips[i].Texture = _ui.equips[i].go.transform:Find("Texture"):GetComponent("UITexture")
		_ui.equips[i].lunkuo = _ui.equips[i].go.transform:Find("lunku").gameObject
		_ui.equips[i].lock = _ui.equips[i].go.transform:Find("lock").gameObject
		_ui.equips[i].go:GetComponent("UIButton").enabled = false
		_ui.equips[i].effect = _ui.equips[i].go.transform:Find("effect").gameObject
		_ui.equips[i].level = _ui.equips[i].go.transform:Find("level").gameObject
		_ui.equips[i].level_label = _ui.equips[i].go.transform:Find("level/num"):GetComponent("UILabel")
		_ui.equips[i].red = _ui.equips[i].go.transform:Find("redpoint").gameObject
	end
	_ui.btn_check = transform:Find("Container/bg_franenew/bottom/button_left").gameObject
	_ui.label_check = transform:Find("Container/bg_franenew/bottom/button_left/Label"):GetComponent("UILabel")
	_ui.btn_talent = transform:Find("Container/bg_franenew/bottom/button_right").gameObject
	_ui.talent_number = transform:Find("Container/bg_franenew/bottom/button_right/Label02"):GetComponent("UILabel")
	_ui.talent_fx = transform:Find("Container/bg_franenew/bottom/button_right/tianfufx").gameObject
	
	_ui.btn_options = transform:Find("Container/bg_franenew/bottom/btn_setting"):GetComponent("UIButton")
	SetClickCallback(_ui.btn_options.gameObject, function(go)
	    setting.Show()
    end)  	
	
	_ui.ChangeHeadUi = transform:Find("ChangeHead")
	_ui.ChangeNameUi = transform:Find("ChangeName")
	_ui.headScrollView = _ui.ChangeHeadUi:Find("Container/bg_frane/Scroll View")
	_ui.headGrid = _ui.ChangeHeadUi:Find("Container/bg_frane/Scroll View/Grid")
	_ui.headIte = _ui.ChangeHeadUi:Find("head")
	_ui.combat = transform:Find("Container/bg_franenew/info/combat/text"):GetComponent("UILabel")
	_ui.union = transform:Find("Container/bg_franenew/info/union/text"):GetComponent("UILabel")
	_ui.id = transform:Find("Container/bg_franenew/info/id/text"):GetComponent("UILabel")
	_ui.SoldierLevel = transform:Find("Container/bg_franenew/Soldier/level"):GetComponent("UILabel")
	_ui.SoldierBtn = transform:Find("Container/bg_franenew/Soldier/back")
	_ui.SoldierRed = transform:Find("Container/page/info3/red")
	_ui.capacity = transform:Find("Container/bg_franenew/info/capacity/text"):GetComponent("UILabel")
	
	TalentInfoData.AddListener(UpdateTalent)
	EquipData.AddListener(UpdateEquip)
	
	SetClickCallback(_ui.SoldierBtn.gameObject, function(go)
		SoldierLevel.Show(function()
			MInfoUpdate()
		end)
	end)
	SetClickCallback(_ui.PlayerInformation.gameObject, function(go)
		GUIMgr:CloseMenu("MainInformation")
		CloseOtherUI()
	end)
	
	SetClickCallback(_ui.btn_close, function(go)
		GUIMgr:CloseMenu("MainInformation")
		CloseOtherUI()
	end)
	

	local chgHeadUiContainer = _ui.ChangeHeadUi:Find("Container")
	SetClickCallback(chgHeadUiContainer.gameObject, function(go)
		_ui.ChangeHeadUi.gameObject:SetActive(false)
		_ui.PlayerInformation.gameObject:SetActive(true)
	end)
	local chgNameUiContainer = _ui.ChangeNameUi:Find("Container")
	SetClickCallback(chgNameUiContainer.gameObject, function(go)
		_ui.ChangeNameUi.gameObject:SetActive(false)
		_ui.PlayerInformation.gameObject:SetActive(true)
	end)
	transform:Find("Container/bg_franenew/top/Label"):GetComponent("UILabel").text = TextMgr:GetText("player_ui1")
	SetClickCallback(_ui.head, function(go)
		_ui.ChangeHeadUi.gameObject:SetActive(true)
		_ui.PlayerInformation.gameObject:SetActive(false)
	end)
	SetClickCallback(_ui.headedit, function(go)
		_ui.ChangeHeadUi.gameObject:SetActive(true)
		_ui.PlayerInformation.gameObject:SetActive(false)
	end)
	local headClose_btn = _ui.ChangeHeadUi:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(headClose_btn.gameObject, function(go)
		_ui.ChangeHeadUi.gameObject:SetActive(false)
		_ui.PlayerInformation.gameObject:SetActive(true)
	end)
	local changeHead_btn = _ui.ChangeHeadUi:Find("Container/bg_frane/btn_change"):GetComponent("UIButton")
	SetClickCallback(changeHead_btn.gameObject, SureChangeFace)
	SetClickCallback(_ui.name, function(go)
		ChangeName.SetCallBack(ChangeNameCallBack)
		GUIMgr:CreateMenu("ChangeName" , false)
	end)
	SetClickCallback(_ui.btn_talent, function()
		FunctionListData.IsFunctionUnlocked(107, function(isactive)
    		if isactive then
    			TalentInfo.Show()
			else
				if _ui == nil then
					return
				end
    			FloatText.ShowAt(_ui.btn_talent.transform.position,TextMgr:GetText(TableMgr:GetFunctionUnlockText(107)), Color.white)
    		end
    	end)
		
	end)

	_ui.midTransform = transform:Find("Container/bg_franenew/mid")
	local playerInstance = ResourceLibrary.GetUIInstance("PlayerInformation/Zhihuiguan")
	playerInstance.transform:SetParent(_ui.midTransform, false)
	_ui.face3D = playerInstance
	local playerObject = transform:Find("Container/bg_franenew/mid/Zhihuiguan").gameObject
	local playerAnimation = transform:Find("Container/bg_franenew/mid/Zhihuiguan/Povit/Zhihuiguan_01"):GetComponent("Animation")
	local playerTransform = playerAnimation.transform
	SetClickCallback(playerObject, function()
	    playerAnimation:PlayQueued("idle0" .. math.random(3) + 1, UnityEngine.QueueMode.PlayNow)
	    playerAnimation:PlayQueued("idle01", UnityEngine.QueueMode.CompleteOthers)
    end)
	UIUtil.SetDragCallback(playerObject, function(go, delta)
	    playerTransform:Rotate(0, -delta.x, 0)
    end)

    _ui.nationalFlag = transform:Find("Container/bg_franenew/flag"):GetComponent("UITexture")
    SetClickCallback(_ui.nationalFlag.gameObject, ChooseFlag.Show)

    _ui.nationalityNotice = transform:Find("Container/bg_franenew/flag/Sprite").gameObject

    local officialTransform = transform:Find("Container/bg_franenew/info/UnionOfficial")
    _ui.official = {}
    LoadOfficialObject(_ui.official, officialTransform)

    _ui.midObject = transform:Find("Container/bg_franenew/mid").gameObject
    _ui.ransomObject = transform:Find("Container/bg_franenew/ransom").gameObject
    _ui.prisonObject = transform:Find("Container/bg_franenew/head/Inprison").gameObject
    _ui.prisonHelpObject = transform:Find("Container/bg_franenew/head/Inprison/help").gameObject
    local kidnapper = {}
    local kidnapperTransform = transform:Find("Container/bg_franenew/ransom")
    kidnapper.faceTexture = kidnapperTransform:Find("left/head/Texture"):GetComponent("UITexture")
    kidnapper.headObject = kidnapperTransform:Find("left/head").gameObject
    kidnapper.nameLabel = kidnapperTransform:Find("left/name/Label"):GetComponent("UILabel")
    kidnapper.levelLabel = kidnapperTransform:Find("level/Label"):GetComponent("UILabel")
    kidnapper.unionLabel = kidnapperTransform:Find("left/name/alliance"):GetComponent("UILabel")
    kidnapper.coordLabel = kidnapperTransform:Find("left/name/coordinate"):GetComponent("UILabel")

    local rewardLabelList = {}
    for i = 1, 4 do
        rewardLabelList[i] = kidnapperTransform:Find(string.format("left/resource/%s/text_num", moneyNameList[i])):GetComponent("UILabel")
    end
    kidnapper.rewardLabelList = rewardLabelList
    kidnapper.changeButton = kidnapperTransform:Find("left/change"):GetComponent("UIButton")
    kidnapper.setButton = kidnapperTransform:Find("left/set"):GetComponent("UIButton")
    kidnapper.changeLabel = kidnapperTransform:Find("left/change/Label"):GetComponent("UILabel")

    local ransomLabelList = {}
    for i = 1, 4 do
        ransomLabelList[i] = kidnapperTransform:Find(string.format("right/resource/%s/text_num", moneyNameList[i])):GetComponent("UILabel")
    end
    kidnapper.ransomLabelList = ransomLabelList
    kidnapper.rewardButton = kidnapperTransform:Find("right/pay"):GetComponent("UIButton")
    kidnapper.rewardLabel = kidnapperTransform:Find("right/pay/label"):GetComponent("UILabel")
    kidnapper.noticeObject = kidnapperTransform:Find("right/pay/reddot").gameObject
    _ui.timeLabel = transform:Find("Container/bg_franenew/ransom/time/load/time"):GetComponent("UILabel")

    _ui.kidnapper = kidnapper
	
	
	local InfoUI = {}

    InfoUI.transform = transform:Find("Container/bg_franenew")
    InfoUI.gameObject = InfoUI.transform.gameObject

	_ui.tabs = {}
    --_ui.tabs= { InfoUI, MilitaryRankUI,nil}
	_ui.tabs[1] = {} ;
	_ui.tabs[1].ui = InfoUI
	
	_ui.tabs[2] = {} ;
	_ui.tabs[2].ui = nil
	
	_ui.tabs[3] = {} ;
	_ui.tabs[3].ui = nil
	
	
	for i = 1, 3 do
        local toggle = transform:Find(string.format("Container/page/info%d", i)):GetComponent("UIToggle")
		_ui.tabs[i].toggle = toggle

        EventDelegate.Add(toggle.onChange, EventDelegate.Callback(function()
			if _ui then
				if _ui.tabs[i].ui ~=nil then
					_ui.tabs[i].ui.gameObject:SetActive(_ui.tabs[i].toggle.value)
				end 
				if _ui.tabs[i].toggle.value and i ==3 then 
				SoldierLevel.Show(function()
					-- MInfoUpdate()
					end)
				elseif _ui.tabs[i].toggle.value and i ==2 then
					MilitaryRank.Show(function()
						-- MInfoUpdate()
					end)
				else 
					MInfoUpdate()
					SoldierLevel.Hide(false)
					MilitaryRank.Hide(false)
				end 
			end

		end))
    end
	_ui.tabs[1].toggle.value = true;

	local unlockTab2 = transform:Find("Container/page/info2/unlock").gameObject
	FunctionListData.IsFunctionUnlocked(302, function(isactive)
	    if _ui == nil then
	        return
        end
        unlockTab2:SetActive(not isactive)
    end)
    SetClickCallback(unlockTab2, function(go)
        FloatText.Show(TextMgr:GetText(TableMgr:GetFunctionUnlockText(302)))
    end)
	local unlockTab3 = transform:Find("Container/page/info3/unlock").gameObject
	FunctionListData.IsFunctionUnlocked(303, function(isactive)
	    if _ui == nil then
	        return
        end
        unlockTab3:SetActive(not isactive)
    end)
    SetClickCallback(unlockTab3, function(go)
        FloatText.Show(TextMgr:GetText(TableMgr:GetFunctionUnlockText(303)))
	end)
	
	_ui.mobaicon = transform:Find("Container/bg_franenew/info/moba/mobaicon"):GetComponent("UITexture")
	_ui.mobanone = transform:Find("Container/bg_franenew/info/moba/text").gameObject
	_ui.mobabtn = transform:Find("Container/bg_franenew/info/moba/mobaicon/btn").gameObject
	
	MilitaryRank.UpdateCurMilitaryRankInfo()
	_ui.militaryRankNotice = transform:Find("Container/page/info2/red").gameObject

	local data = MobaData.GetMobaMatchInfo()
	if data.info.level == 0 then
		_ui.mobaicon.gameObject:SetActive(false)
		_ui.mobanone:SetActive(true)
	else
		_ui.mobaicon.gameObject:SetActive(true)
		_ui.mobanone:SetActive(false)
		local rankData = TableMgr:GetMobaRankDataByID(data.info.level)
		_ui.mobaicon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "Moba/", rankData.RankIcon)
		SetClickCallback(_ui.mobabtn, function()
			mobafile.Show(MainData.GetCharId(), data)
		end)
	end
	MilitaryRankData.AddListener(UpdateMilitaryRankNotice)
end

function LateUpdate()
    if timer >= 0 then
        timer = timer - GameTime.deltaTime
        if timer < 0 then
            timer = 1
            UpdateTime()
        end
    end
end


function Close()
	_ui = nil
    MainData.RemoveListener(MInfoUpdate)
    TalentInfoData.RemoveListener(UpdateTalent)
    EquipData.RemoveListener(UpdateEquip)
    MainData.RemoveListener(UpdateEquip)
	MilitaryRankData.RemoveListener(UpdateMilitaryRankNotice)
	MainCityUI.UpdateTalent()
end

function Show(toggleIndex)
    Global.OpenUI(_M)
    _ui.toggleIndex = toggleIndex
end

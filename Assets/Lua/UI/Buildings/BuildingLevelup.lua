module("BuildingLevelup",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local eventListener = EventListener()

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

local container
local unlock
local itemPrefab
local heroPrefab
local itemTipTarget
local itemlist
local updateMsg
local CloseCB
local builddata
local existtest
local soldierequip

local efunlevel = {2,3,4,5,6,8,10}

function SetData(msg)
	updateMsg = msg
end

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	for i, v in ipairs(itemlist) do
		if go == v.gameObject then
			local itemdata = TableMgr:GetItemData(tonumber(go.name))
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
		    return
		end
	end
	Tooltip.HideItemTip()
end

local function ProcessItem(data ,grid)
    local str = data.rewardItem
    if str ~= "NA" then
        str = str:split(";")
        itemlist = {}
        for i, v in ipairs(str) do
	        local st = v:split(":")
	        if #st > 0 and tonumber(st[1]) ~= 11 then
				if itemPrefab == nil then
					itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
				end
	
				local itemTransform = NGUITools.AddChild(grid.transform.gameObject , itemPrefab).transform
				itemTransform.localScale = Vector3(1.2,1.2,1.2)
	            table.insert(itemlist, itemTransform)
	            local itemdata = TableMgr:GetItemData(st[1])
				itemTransform.name = st[1]
				
				local item = {}
				UIUtil.LoadItemObject(item, itemTransform)
				UIUtil.LoadItem(item, itemdata, tonumber(st[2]))
				itemTransform.gameObject:SetActive(false)
				
				coroutine.start(function()
					coroutine.wait(0.3 * i)
					if itemlist == nil or itemTransform == nil or itemTransform:Equals(nil) then
						return
					end
					itemTransform.gameObject:SetActive(true)
				end)
	        end
	        grid:Reposition()
	    end
    end
end

function Awake()
    container = {}
    container.go = transform:Find("Container").gameObject
    container.title = transform:Find("Container/bg_frane/bg_top/title"):GetComponent("UILabel")
    container.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
    container.num_left = transform:Find("Container/bg_frane/bg_level/num_left"):GetComponent("UILabel")
    container.num_right = transform:Find("Container/bg_frane/bg_level/num_right"):GetComponent("UILabel")
    container.texture = transform:Find("Container/bg_frane/bg_mid/Texture"):GetComponent("UITexture")
    container.name = transform:Find("Container/bg_frane/bg_mid/name"):GetComponent("UILabel")
    container.text = transform:Find("Container/bg_frane/bg_bottom/bg_title/text"):GetComponent("UILabel")
    container.grid = transform:Find("Container/bg_frane/bg_bottom/Scroll View/Grid"):GetComponent("UIGrid")
    container.mid = transform:Find("Container/bg_frane/bg_mid").gameObject
    container.scrollview = transform:Find("Container/bg_frane/Scroll View").gameObject

    unlock = {}
    unlock.go = transform:Find("unlock").gameObject
    unlock.title = transform:Find("unlock/bg_frane/bg_top/title"):GetComponent("UILabel")
    unlock.btn_close = transform:Find("unlock/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
    unlock.num_left = transform:Find("unlock/bg_frane/bg_level/num_left"):GetComponent("UILabel")
    unlock.num_right = transform:Find("unlock/bg_frane/bg_level/num_right"):GetComponent("UILabel")
    unlock.text = transform:Find("unlock/bg_frane/bg_bottom/bg_title/text"):GetComponent("UILabel")
    unlock.grid = transform:Find("unlock/bg_frane/bg_bottom/Scroll View/Grid"):GetComponent("UIGrid")
    unlock.scrollview = transform:Find("unlock/bg_frane/bg_bottom/Scroll View"):GetComponent("UIScrollView")

    itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")

end

function Start()
    SetClickCallback(container.btn_close.gameObject, function (go)
    	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
        GUIMgr:CloseMenu("BuildingLevelup")
    end)
    SetClickCallback(unlock.btn_close.gameObject, function (go)
    	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
        GUIMgr:CloseMenu("BuildingLevelup")
    end)
    SetClickCallback(container.go, function (go)
    	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
        GUIMgr:CloseMenu("BuildingLevelup")
    end)
    SetClickCallback(unlock.go, function (go)
    	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
        GUIMgr:CloseMenu("BuildingLevelup")
    end)
    --[[SetClickCallback(transform:Find("Container").gameObject, function()
    	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
    	GUIMgr:CloseMenu("Levelup")
	end)]]
	local commandcenter = {}
	if builddata ~= nil then
		commandcenter.data = builddata
		commandcenter.upgradeData = TableMgr:GetBuildUpdateData(commandcenter.data.type, commandcenter.data.level)
	end
	for i,v in ipairs(efunlevel) do
		if commandcenter.data.level == v then
			GUIMgr:SendDataReport("efun", "mb"..v)
		end
	end
	if commandcenter.data.level >= 3 then
		Event.Resume(101)
	end
	if commandcenter.data.level >= 4 then
		Event.Resume(102)
	end
	if commandcenter.data.level >= 5 then
		Event.Resume(103)
		Event.Resume(104)
	end
	if commandcenter.data.level == 8 then
		existtest = true
	end
	if commandcenter.data.level == tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.SoldierEquipUnlockLevel).value) then
		soldierequip = true
	end
	FunctionListData.IsFunctionUnlocked(130, function(isactive)
		if isactive then
			RebelSurroundNewData.RequestNemesisInfo()
		end
	end)
	--检查hotTime全局buff是否开启
	MainCityUI.RequestNCheckHotTime()
	
    local alldata = TableMgr:GetAllBuildingData()
    local unlockdata = {}
	for i , v in pairs(alldata) do
		local unlockCondition = alldata[i].unlockCondition
		if unlockCondition ~= "NA" then
		    unlockCondition = unlockCondition:split(";")
		    for _, v in ipairs(unlockCondition) do
		        local temp = v:split(":")
		        if tonumber(temp[1]) == 1 then
		        	if tonumber(temp[2]) == 1 then
			        	if tonumber(temp[3]) == commandcenter.data.level then
			                unlockdata[#unlockdata + 1] = {}
			                unlockdata[#unlockdata].icon = alldata[i].icon
			                unlockdata[#unlockdata].name = TextMgr:GetText(alldata[i].name)
			            end
			        end
		        end
		    end
	    end
	end
    --[[for i = 0, alldata.Length - 1 do
    	local unlockCondition = alldata[i].unlockCondition
		if unlockCondition ~= "NA" then
		    unlockCondition = unlockCondition:split(";")
		    for _, v in ipairs(unlockCondition) do
		        local temp = v:split(":")
		        if tonumber(temp[1]) == 1 then
		        	if tonumber(temp[2]) == 1 then
			        	if tonumber(temp[3]) == maincity.GetBuildingLevelByID(temp[2]) then
			                unlockdata[#unlockdata + 1] = {}
			                unlockdata[#unlockdata].icon = alldata[i].icon
			                unlockdata[#unlockdata].name = TextMgr:GetText(alldata[i].name)
			            end
			        end
		        end
		    end
	    end
    end]]
	
    local coreData = TableMgr:GetBuildCoreData(commandcenter.data.level)
    local str = coreData.unlockInfo
	if string.find(str, "Building_1_special") ~= nil then
		unlockdata[#unlockdata + 1] = {}
		unlockdata[#unlockdata].icon = "998"
		unlockdata[#unlockdata].name = TextMgr:GetText("Building_1_special")
    end
    
    local level = commandcenter.data.level
	--[[if level > 5 and UnionInfoData.HasUnion() then
		local send = {}
		send.curChanel = ChatMsg_pb.chanel_guild
		send.spectext = ""
		send.content = "UnionLog_Chat_Desc1"..","..MainData.GetCharName()..","..level--System.String.Format(TextMgr:GetText("UnionLog_Chat_Desc1"), MainData.GetCharName(), level)
		send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
		send.chatType = 4
		send.senderguildname = UnionInfoData.GetData().guildInfo.banner
		Chat.SendContent(send)
	end]]
	--format rewardshow
	local rewardList = {}
	rewardList.data = {}
	
    if #unlockdata == 1 then
        --container.num_left.text = commandcenter.data.level - 1
        container.num_right.text = commandcenter.data.level
        container.name.text = unlockdata[1].name
        container.texture.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "building/", unlockdata[1].icon)
        ProcessItem(commandcenter.upgradeData, container.grid)
        unlock.go:SetActive(false)
    elseif #unlockdata > 1 then
    	container.num_right.text = commandcenter.data.level
    	container.mid:SetActive(false)
    	container.scrollview:SetActive(true)
    	for i = 1, 3 do
    		local item = container.scrollview.transform:Find(System.String.Format("Grid/bg_mid{0}", i))
    		if i > #unlockdata then
    			item.gameObject:SetActive(false)
    		else
    			item:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "building/", unlockdata[i].icon)
    			item:Find("name"):GetComponent("UILabel").text = unlockdata[i].name
    		end
    	end
    	ProcessItem(commandcenter.upgradeData, container.grid)
    	unlock.go:SetActive(false)
    else
        unlock.num_left.text = commandcenter.data.level - 1
        unlock.num_right.text = commandcenter.data.level
        ProcessItem(commandcenter.upgradeData, unlock.grid)
        container.go:SetActive(false)
    end
    MainCityUI.CheckMoneyLock()
    AudioMgr:PlayUISfx("SFX_UI_building_levelup", 1, false)
    coroutine.start(function()
    	coroutine.wait(0.3)
    	if container == nil then
    		return
    	end
	    container.title:GetComponent("Animator").enabled = true
	    unlock.title:GetComponent("Animator").enabled = true
	    transform:Find("Container/bg_frane/bg_top/SFX").gameObject:SetActive(true)
	    transform:Find("unlock/bg_frane/bg_top/SFX").gameObject:SetActive(true)
    end)
    AddDelegate(UICamera, "onPress", OnUICameraPress)
    NotifyListener()
end

function Close()
    if builddata.level >= tonumber(tableData_tGlobal.data[100147].value) then
        ShareCommon.Show(3)
    elseif builddata.level >= tonumber(tableData_tGlobal.data[100146].value) then
        MainCityUI.CheckWeelyShareNotice()
	end
	
	if builddata.level >= tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.RateGame).value) and UnityEngine.PlayerPrefs.GetInt("rategame" .. MainData.GetCharId()) < 1 then
		local platformType = GUIMgr:GetPlatformType()
		if platformType == LoginMsg_pb.AccType_adr_qihu then
			MainCityUI.UpdateRategame()
		else
			rategame.Show()
		end
	end

    if builddata.level == 0 then
        --SoldierEquipBanner.Show(TextMgr:GetText(Text.equip_ui18), "Equip_banner", TextMgr:GetText(Text.Equip_des), 9001) --指挥官装备
    elseif builddata.level == 10 then
		SoldierEquipBanner.Show(TextMgr:GetText(Text.ui_militaryrank_1), "MilitaryRank_banner", TextMgr:GetText(Text.MilitaryRank_des), 9002) --军衔
	elseif builddata.level == 8 then
		SoldierEquipBanner.Show(nil, nil, nil, 9009) --竞技场
    elseif builddata.level == 13 then
		SoldierEquipBanner.Show(TextMgr:GetText(Text.command_ui_command_txt08), "SoldierLevel_banner", TextMgr:GetText(Text.SoldierLevel_des), 9003) --统帅
	elseif builddata.level == 9 then
		SoldierEquipBanner.Show(TextMgr:GetText("ui_moba_136"), "Moba_banner", TextMgr:GetText("Moba_des"), 9005) --MOBA
	elseif builddata.level == 14 then
		SoldierEquipBanner.Show(TextMgr:GetText("ui_rune_3"), "Rune_banner", TextMgr:GetText("ui_rune_45"), 9004) --符文
	elseif builddata.level == 7 then
		if not UnionInfoData.HasUnion() then
			SoldierEquipBanner.Show(nil, nil, nil, 9010) --加入联盟
		end
    end

	updateMsg = nil
	Tooltip.HideItemTip()
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	container = nil
	unlock = nil
	itemPrefab = nil
	heroPrefab = nil
	itemTipTarget = nil
	itemlist = nil
	builddata = nil
	MainCityUI.RemoveMenuTarget()
	if existtest then
		if GUIMgr:FindMenu("BuildingUpgrade") then
			GUIMgr:CloseMenu("BuildingUpgrade")
		end
		ExistTestData.SetFirstGuide(true)
		ExistTestNotice.Show()
		existtest = nil
	end
	if soldierequip then
		Barrack_SoldierEquipData.RequestArmyEnhanceInfo()
		if GUIMgr:FindMenu("BuildingUpgrade") then
			GUIMgr:CloseMenu("BuildingUpgrade")
		end
        SoldierEquipBanner.Show(TextMgr:GetText(Text.SoldierEquip_1), "SoldierEquip_banner", TextMgr:GetText(Text.SoldierEquip_7), 9999)
		soldierequip = nil
	end
	if CloseCB ~= nil then
		CloseCB()
		CloseCB = nil
	end
end

function Show(_building,closecallback)
	builddata = _building
	CloseCB = closecallback
	Global.OpenUI(_M)
end

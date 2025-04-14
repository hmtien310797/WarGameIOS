module("MobaResBar", package.seeall)

local GUIMgr = Global.GGUIMgr.Instance
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local SetClickCallback = UIUtil.SetClickCallback
local String = System.String
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime

local moduleName
local EachBuyEnergyAmount
local resList
local energyTipCoroutine

local uiobjList = {}
local moduleList = {}

local chatPreviewOffset = 0

local ingroList

local NewResBarLableList = {"gold","energy"}
local labelMoney 

local showLabelList = 
{
    ChapterSelectUI = {"combatPoint", "energy", "gold"},
    BuildingDetails = {"gold", "food", "steel", "oil", "elec"},
    BuildingUpgrade = {"gold", "food", "steel", "oil", "elec"},
    Barrack = {"gold", "food", "steel", "oil", "elec"},
    Laboratory = {"gold", "food", "steel", "oil", "elec"},
    LaboratoryUpgrade = {"gold", "food", "steel", "oil", "elec"},
    CommonItemBag = {"gold", "food", "steel", "oil", "elec"},
    MilitarySchool = {"item530001", "item530002", "gold"},
    Shop = {"gold", "food", "steel", "oil", "elec"},
	WareHouse = {"gold", "food", "steel", "oil", "elec"},
	Hospital = {"gold", "food", "steel", "oil", "elec"},
	ParadeGround = {"gold", "food", "steel", "oil", "elec"},
	TradeHall = {"gold", "food", "steel", "oil", "elec"},
	Trade = {"gold", "food", "steel", "oil", "elec"},
	TileInfo = {"gold", "item13"},
	BuffView = {"gold", "food", "steel", "oil", "elec"},
	UnionTec = {"gold", "food"},
	GetVipCoin = {"gold"}
}

local function StartEnergyTipCoroutine()
    if energyTipCoroutine == nil then
        energyTipCoroutine = coroutine.start(function()
            while true do
                local text1 = TextMgr:GetText(Text.tili_ui1)
                local leftEnergyTime = MainData.GetLeftEnergyTime()
                if leftEnergyTime < 0 then
                    leftEnergyTime = 0
                end
                local text2 = GameTime.SecondToString2(leftEnergyTime)
				if _ui ~= nil then
					_ui.tipLabel.text = String.Format(text1, text2)
				end
                coroutine.wait(1)
            end
        end)
    end
end

local function StopEnergyTipCoroutine()
    if energyTipCoroutine ~= nil then
        coroutine.stop(energyTipCoroutine)
        energyTipCoroutine = nil
    end
end

local function EnergyTipCallback()
    if MainData.GetEnergy() >= MainData.GetMaxEnergy() then
        _ui.tipLabel.text = TextMgr:GetText(Text.tili_ui7)
        StopEnergyTipCoroutine()
    else
        StartEnergyTipCoroutine()
    end
    return false
end

local function MakeIngroList()
	ingroList = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.IngroResBar).value:split(",")
end

local function CheckNeedShow(_moduleName)
    if not Global.IsSlgMobaMode() then
        return false
    end
	if ingroList == nil then
		MakeIngroList()
	end
	for i, v in ipairs(ingroList) do
		if v == _moduleName then
			return false
		end
	end
	return true
end

local function CheckUnLock(id)
    local active = false
    if id == "food" then
        active = maincity.IsBuildingUnlockByID(11)
    elseif id == "steel" then
        active = maincity.IsBuildingUnlockByID(12)
    elseif id == "oil" then
        active = maincity.IsBuildingUnlockByID(13)
    elseif id == "elec" then
        active = maincity.IsBuildingUnlockByID(14)
    else
        active = true
    end
    return active
end

local function NewEnergyTipCallback()
  --[[  if  moduleName == "Barrack" then
        MobaMain.UseResItem(25,function() Barrack.Open3DArea() end)
        Barrack.Close3DArea()
    else
        MobaMain.UseResItem(25)
    end  
    --]]
    MobaMain.CheckAndBuyEnergy(false)
    if MainData.GetEnergy() >= MainData.GetMaxEnergy() then
        StopEnergyTipCoroutine()
    else
        StartEnergyTipCoroutine()
    end
    return false
end

local function BuyEnergyCallback(go)
    MobaMain.CheckAndBuyEnergy(false)
end

local configList = 
{
    combatPoint = {icon = "0"},
    energy = {icon = "7", addVisible = true, tipCallback = NewEnergyTipCallback, addCallback = BuyEnergyCallback},
    gold = {icon = "2", tipCallback = function() 
        if  moduleName == "Barrack" then
            Pay.CloseCallBack = function() Barrack.Open3DArea() end
            Barrack.Close3DArea()
        end    
        store.Show(7)
        return false 
    end},
    food = {icon = "3", tipCallback = function() 
        if  moduleName == "Barrack" then

            MobaMain.UseResItem(3,function() Barrack.Open3DArea() end)
            Barrack.Close3DArea()
        else
            MobaMain.UseResItem(3)
        end
        return false 
    end},
    steel = {icon = "4", tipCallback = function() 
        if  moduleName == "Barrack" then

            MobaMain.UseResItem(4,function() Barrack.Open3DArea() end)
            Barrack.Close3DArea()
        else
            MobaMain.UseResItem(4)
        end        
        return false 
    end},
    oil = {icon = "5", tipCallback = function()
        if  moduleName == "Barrack" then
            MobaMain.UseResItem(5,function() Barrack.Open3DArea() end)
            Barrack.Close3DArea()
        else
            MobaMain.UseResItem(5)
        end        
        return false 
    end},
    elec = {icon = "6", tipCallback = function() 
        if  moduleName == "Barrack" then
            MobaMain.UseResItem(6,function() Barrack.Open3DArea() end)
            Barrack.Close3DArea()
        else
            MobaMain.UseResItem(6)
        end        
        return false 
    end},
}

local function LoadRes()
    if resList == nil then
        resList = {}
        if #moduleList == 0 then
            return
        end
        local transform = uiobjList[moduleList[#moduleList]].go.transform
        moduleTable = uiobjList[moduleList[#moduleList]].moduleTable
        local grid = transform:Find("Container/Grid"):GetComponent("UIGrid")
        local resGameObject = transform:Find("ResBarinfo").gameObject
        moduleName = transform.parent.name
        for i = 1, 2 do
            local resTransform
            if i > grid.transform.childCount then
                resTransform = NGUITools.AddChild(grid.gameObject, resGameObject).transform
            else
                resTransform = grid.transform:GetChild(i - 1)
            end
            local label = resTransform:Find("bg_num/num"):GetComponent("UILabel")
            local icon = resTransform:Find("bg_num/icon"):GetComponent("UITexture")
            local btnAdd = resTransform:Find("bg_num/btn_add"):GetComponent("UIButton")
            resList[i] = {label = label}
            if i == 1 then
				labelMoney  = label
                label.text = MoneyListData.GetDiamond()
                icon.mainTexture = ResourceLibrary:GetIcon("Item/", "2")
            elseif i == 2 then
				if MobaMainData.GetData()~= nil then 
					local mainData = MobaMainData.GetData().data
					if mainData ~= nil then
						label.text = mainData.mobaScore
					end
					icon.mainTexture = ResourceLibrary:GetIcon("Item/", "Item_mobascore")
				end 
            end

            grid.transform:GetChild(i - 1).gameObject:SetActive(true)
        end
        for i = 3, grid.transform.childCount do
            grid.transform:GetChild(i - 1).gameObject:SetActive(false)
        end
        grid.repositionNow = true
    end
end

local function UpdateMoney()
    LoadRes() 
	if resList == nil or resList[1] == nil then
		return
    end
    resList[1].label.text = MoneyListData.GetDiamond()
end

local function UpdateScore()
	if resList == nil or resList[2] == nil or MobaMainData.GetData()== nil then
        return
    end
    local mainData = MobaMainData.GetData().data
    if mainData ~= nil then
        resList[2].label.text = mainData.mobaScore
    end
end

local function UpdateEnergy()
    LoadRes()
    for k, v in pairs(resList) do
        local label = v.label
        if k == "combatPoint" then
            label.text = MainData.GetFight()
        elseif k == "energy" then
            label.text = string.format("%d/%d", MainData.GetEnergy(), MainData.GetMaxEnergy())
        elseif k == "item13" then
        	label.text = string.format("%d/%d", MainData.GetSceneEnergy(), MainData.GetMaxSceneEnergy())
        end
    end
end

local function UpdateElse()
    LoadRes()
    for k, v in pairs(resList) do
        local label = v.label
        if  k == "gold" then
            label.text = MoneyListData.GetDiamond()
        elseif k == "food" then
            label.text = Global.ExchangeValue(MoneyListData.GetFood())
        elseif k == "steel" then
            label.text = Global.ExchangeValue(MoneyListData.GetSteel())
        elseif k == "oil" then
            label.text = Global.ExchangeValue(MoneyListData.GetOil())
        elseif k == "elec" then
            label.text = Global.ExchangeValue(MoneyListData.GetElec())
        elseif string.starts(k, "item") then
            local itemId = tonumber(string.sub(k, 5, -1))
            label.text = ItemListData.GetItemCountByBaseId(itemId) 
        end
    end
end

local function UpdateRes()
    --UpdateEnergy()
    --UpdateElse()
    UpdateMoney()
    UpdateScore()
end


local function RefresgBagInfo()
	UpdateEnergy()
    --UpdateElse()
end 

function SetChatPreviewRedPoint(flag)
	if ChatMenu ~= nil and ChatMenu.redPoint ~= nil and #moduleList > 0 then
		ChatMenu.redPoint.gameObject:SetActive(flag)
	end
end

local CharMenu
local InitCharMenu

local function PreviewChanelChange(dir)
	if not Global.IsSlgMobaMode() then
		return
	end
	if not InitCharMenu() then
		return
	end

	MobaMain.PreviewChanelChange(dir, ChatMenu)
end

InitCharMenu = function()
	if #moduleList == 0 then
		return false
	end
	local transform = uiobjList[moduleList[#moduleList]].go.transform
	ChatMenu = {}
	ChatMenu.bg = transform:Find("bg_liaotian")
	ChatMenu.chatBtn = transform:Find("bg_liaotian (1)")
	ChatMenu.name1 = transform:Find("bg_liaotian/name1")
	ChatMenu.name2 = transform:Find("bg_liaotian/name2")
	ChatMenu.previewTog = {}
	ChatMenu.redPoint = transform:Find("bg_liaotian/redpoint")
	
	ChatMenu.previewTog[ChatMsg_pb.chanel_MobaWorld] = transform:Find("bg_liaotian/pointbar/point2"):GetComponent("UIToggle")
	ChatMenu.previewTog[ChatMsg_pb.chanel_MobaTeam] = transform:Find("bg_liaotian/pointbar/point4"):GetComponent("UIToggle")
	ChatMenu.previewTog[ChatMsg_pb.chanel_MobaPrivate] = transform:Find("bg_liaotian/pointbar/point1"):GetComponent("UIToggle")
	ChatMenu.previewTog[ChatMsg_pb.chanel_MobaPrivate].gameObject:SetActive(false)
	--[[for i = ChatMsg_pb.chanel_private, ChatMsg_pb.chanel_guild, 1 do
		ChatMenu.previewTog[i] = transform:Find("bg_liaotian/pointbar/point" .. i):GetComponent("UIToggle")
	end]]

	SetClickCallback(ChatMenu.chatBtn.gameObject, function(go)
		if moduleName == "Barrack" then
            MobaChat.CloseCallBack = function() Barrack.Open3DArea() end
            Barrack.Close3DArea()
        end
		GUIMgr:CreateMenu("MobaChat", false)
    end)

    chatPreviewOffset = 0
	UIUtil.SetDragCallback(ChatMenu.chatBtn.gameObject , function(go, delt)
		chatPreviewOffset = chatPreviewOffset + delt.x
	end)
	UIUtil.SetDragEndCallback(ChatMenu.chatBtn.gameObject , function(go)
		--print(delt.x)
		if chatPreviewOffset < -100 then
			PreviewChanelChange(2)
		end
		
		if chatPreviewOffset > 100 then
			PreviewChanelChange(1)
		end

		chatPreviewOffset = 0
	end)

    return true
end

-- 弃用
local function UpdateChatHint(chanel, hintCount)
	if not Main.Instance:IsInBattleState() then
		if not InitCharMenu() then
			return
		end
		local recentChat = MobaChatData.GetRecentNewChat(nil, 2)
		if recentChat ~= nil and #recentChat > 0 then
			for i , v in pairs(recentChat) do
				local cmName = nil
				if i == 1 then
					cmName = ChatMenu.name2
				elseif i == 2 then
					cmName = ChatMenu.name1
				end
				
				if cmName ~= nil and cmName.gameObject ~= nil then
					cmName.gameObject:SetActive(true)
					local name = cmName:GetComponent("UILabel")
					if v.gm then
						name.text = "[ff0000][" .. TextMgr:GetText("GM_Name") .."][-]:"
					else
                        name.text = "[" .. v.sender.name .."]:"
                        print("yyyyyyyyyyyyyyyyyyyyyyy,",cmName:Find("bg_gov"),v.sender.officialId,v.sender.guildOfficialId,true,1)
                        GOV_Util.SetGovNameUI(cmName:Find("bg_gov"),v.sender.officialId,v.sender.guildOfficialId,true,v.sender.militaryRankId)
					end
					
					local content = cmName:Find("Label"):GetComponent("UILabel")
					local contentOffset = ""
					if v.type == 3 then
						cmName:Find("Label/Sprite").gameObject:SetActive(true)
						contentOffset = "          "
					else
						cmName:Find("Label/Sprite").gameObject:SetActive(false)
					end
					--[[翻译功能屏蔽，所以都显示原文
					if v.clientlangcode == Global.GTextMgr:GetCurrentLanguageID() then
						content.text = contentOffset .. v.infotext
					else
						content.text = contentOffset .. v.transtext
					end]]
					if v.type == 4 or v.type == 5 or v.type == 2 then
						content.text = contentOffset .. MobaChat.GetSystemChatInfoContent(v.infotext)
					elseif v.type == 3 then
                        local str = v.spectext:split(",")
	                    local pGuildName = ""
	                    if str[6] ~= nil then
	                    	pGuildName = "[f1cf63]" .. str[6] .. "[-]"
	                    end
	                    local tGuildName = ""
	                    if str[7] ~= nil then
		                    tGuildName = "[f1cf63]" .. str[7] .. "[-]"
	                    end
	
	                    local playerName = ""
	                    if str[2] ~= nil then
		                    playerName = str[2]
	                    end
	
	                    local targetName = ""
	                    if str[3] ~= nil then
		                    targetName = str[3]
	                    end

	                    local fort = 0
	                    if str[8] ~= nil then
		                    fort = tonumber(str[8])
		                    targetName = TextMgr:GetText("FortArmyName_"..fort)
                        end      

                        local gov = 5
                        if str[10] ~= nil then
                            gov = tonumber(str[10])
                            if gov == 0 then
                                targetName = TextMgr:GetText("GOV_ui7")
                            elseif gov >=1 and gov <= 4 then
                                targetName = TextMgr:GetText(TableMgr:GetTurretDataByid(gov).name)
                            end                 
                        end

                        local strVs = " [ff0000]vs[-] "


                            if fort > 0 or gov < 5 then
                                content.text = contentOffset ..pGuildName .. playerName .. strVs .. tGuildName .. targetName
                            else
                                content.text = contentOffset .. v.infotext
                            end
                        
  


					else
						content.text = contentOffset .. v.infotext
					end
				end
			end
        end
	end
end

local function CloseChat()
    MobaChatData.RemoveListener(PreviewChanelChange)
end

local function OnUICameraPress(go, pressed)
    if not pressed then
        return
    end
	if resList ~= nil then
	    for k, v in pairs(resList) do
	    	if v.icon ~= nil and not v.icon:Equals(nil) then
		        if go == v.icon.gameObject then
		            local config = configList[k]
		            if config ~= nil then
		                local tipCallback = config.tipCallback
		                if tipCallback ~= nil then
		                    if tipCallback() then
		                        --_ui.tipWidget.gameObject:SetActive(not _ui.tipWidget.gameObject.activeSelf)
		                        --_ui.tipWidget.transform:SetParent(v.icon.transform, false)
		                    end
		                    return
		                end
		            end
		        end
		    end
	    end
	end
    --_ui.tipWidget.gameObject:SetActive(false)
end

function OnMenuOpen(_moduleName)
	if CheckNeedShow(_moduleName) then
		local obj = {}
		obj.moduleTable = GUIMgr:FindMenu(_moduleName)
        if obj.moduleTable ~= nil then
            obj.go = obj.moduleTable.transform:Find("ResBar(Clone)")
            if obj.go ~= nil then
                obj.go = obj.go.gameObject
            else
                obj.go = NGUITools.AddChild(obj.moduleTable.gameObject, ResourceLibrary.GetUIPrefab("BuildingCommon/ResBar"))
            end
			obj.go:GetComponent("UIPanel").depth = obj.moduleTable.gameObject:GetComponent("UIPanel").depth + 1
            uiobjList[_moduleName] = obj
            for i, v in ipairs(moduleList) do
                if v == _moduleName then
                    table.remove(moduleList, i)
                end
            end
            table.insert(moduleList, _moduleName)
            resList = nil
            LoadRes()
			UpdateRes()
			PreviewChanelChange()
		end
	end
end

function OnMenuClose(_moduleName)
	for i, v in ipairs(moduleList) do
		if v == _moduleName then
			table.remove(moduleList, i)
		end
    end
    uiobjList[_moduleName] = nil
    resList = nil
	UpdateRes()
	PreviewChanelChange()
end

function Init()
    resList = nil
	moduleList = {}
	uiobjList = {}
	if EachBuyEnergyAmount == nil then
	    EachBuyEnergyAmount = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.EachBuyEnergyAmount).value)
	end
	AddDelegate(GUIMgr, "onMenuCreate", OnMenuOpen)
	AddDelegate(GUIMgr, "onMenuClose", OnMenuClose)
    AddDelegate(UICamera, "onPress", OnUICameraPress)
    --MobaMain.AddCommonItemBagListener(UpdateElse)
    --MainData.AddListener(UpdateEnergy)
	--MobaMainData.AddListener(LoadRes)
	MobaMainData.AddListener(UpdateScore)
	MoneyListData.AddListener(UpdateMoney)
	
	MobaChatData.AddListener(PreviewChanelChange)
end



function Close()
	RemoveDelegate(GUIMgr, "onMenuCreate", OnMenuOpen)
	RemoveDelegate(GUIMgr, "onMenuClose", OnMenuClose)
    RemoveDelegate(UICamera, "onPress", OnUICameraPress)
    --MobaMain.RemoveCommonItemBagListener(UpdateElse)
    --MainData.RemoveListener(UpdateEnergy)
	--MobaMainData.RemoveListener(LoadRes)
    MobaMainData.RemoveListener(UpdateScore)
	MoneyListData.RemoveListener(UpdateMoney)
    MobaChatData.RemoveListener(PreviewChanelChange)
    StopEnergyTipCoroutine()
    CloseChat()
    _ui = nil
    resList = nil
	labelMoney = nil
end

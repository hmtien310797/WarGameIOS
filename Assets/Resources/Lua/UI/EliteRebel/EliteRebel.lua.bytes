module("EliteRebel", package.seeall)

local GUIMgr = Global.GGUIMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback
local SetDragCallback = UIUtil.SetDragCallback
local TableMgr = Global.GTableMgr
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local Format = System.String.Format
local GameTime = Serclimax.GameTime

local tileMsg
local eliteData
local eliteShow = nil
local Guid

local ui = nil
local timer = 0


local function UpdateTime()
    ui.energyLabel1.text, ui.energyLabel2.text = MainData.GetSceneEnergyCooldownText()
end

function OnUICameraClick(go)
	if ui == nil then
		return
	end
	
    ui.energyTipObject:SetActive(false)
    if go ~= ui.tipObject then
        ui.tipObject = nil
	end
	
	if go ~= ui.tooltip then
		Tooltip.HideItemTip()
		ui.tooltip = nil
	end
end

function OnUICameraDragStart(go, delta)
	if ui == nil then
		return
	end
	
    ui.energyTipObject:SetActive(false)
end

local function LoadBriefRewardItem(grid , dropdata)
	local item = NGUITools.AddChild(grid.gameObject ,ui.itemPrefab.gameObject)
	item.transform:SetParent(grid.transform , false)
	item.gameObject:SetActive(true)
	--info.transform.localScale = Vector3(0.66 , 0.66 , 0.66)
	--info.gameObject.name = "1_" .. dropdata.contentId
	local itemdata = TableMgr:GetItemData(dropdata.contentId)
	local itemCount = dropdata.contentNumber
	local reward = {}
	UIUtil.LoadItemObject(reward, item.transform)
	UIUtil.LoadItem(reward, itemdata, itemCount)
	SetClickCallback(item.gameObject, function(go) 
		if go ~= ui.tooltip then
			Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
			ui.tooltip = item.gameObject
		else
			Tooltip.HideItemTip()
			ui.tooltip = nil
		end
	end)
end

local function LoadBriefRewardHero(grid , dropdata)
	local heroitem = NGUITools.AddChild(grid.gameObject ,ui.heroPrefab.gameObject)
	heroitem.transform:SetParent(grid.transform , false)
	heroitem.gameObject:SetActive(true)
	--info.transform.localScale = Vector3(0.93 , 0.93 , 1)
	
	local heroData = TableMgr:GetHeroData(dropdata.contentId) 
	local heroCount = dropdata.contentNumber
	
	local item = {}
	UIUtil.LoadHeroItemObject(item, heroitem.transform)
    UIUtil.LoadHeroItem(item, heroData, heroCount)
	
end




local function LoadUI()
	ui = {}
	ui.closeBtn = transform:Find("Container/bg_frane/bg_top/btn_close")
	ui.mask = transform:Find("mask")
	
	ui.title = transform:Find("Container/bg_frane/bg_top/title_left/Label"):GetComponent("UILabel")
	ui.rebelDes = transform:Find("Container/bg_frane/bg_mid/line2/Label"):GetComponent("UILabel")
	ui.escapeTime = transform:Find("Container/bg_frane/bg_mid/time/time"):GetComponent("UILabel")
	ui.coodinate = transform:Find("Container/bg_frane/bg_mid/text/coor"):GetComponent("UILabel")
	ui.power = transform:Find("Container/bg_frane/bg_mid/bg_jindu/bg_progress/Label"):GetComponent("UILabel")
	ui.powerSlider = transform:Find("Container/bg_frane/bg_mid/bg_jindu/bg_progress/icon_progress"):GetComponent("UISlider")
	ui.elitShow = transform:Find("Container/bg_frane/bg_mid/3DShow/3dShow")
	ui.elitShowDragBox = transform:Find("Container/bg_frane/bg_mid/3DShow/3dDrag")
	ui.share = transform:Find("Container/bg_frane/bg_mid/time/share")
	ui.more = transform:Find("Container/bg_frane/bg_mid/time/bg_more")
	ui.EliteRebelCostEnergy = transform:Find("Container/bg_frane/bg_mid/button02/icon/Label"):GetComponent("UILabel")
	
	ui.detailBtn = transform:Find("Container/bg_frane/bg_mid/btn_help")
	ui.rewardList = transform:Find("Container/bg_frane/bg_bottom/Scroll View/Grid"):GetComponent("UIGrid")
	ui.jijieBtn = transform:Find("Container/bg_frane/bg_mid/button02")
	ui.zhenchaBtn = transform:Find("Container/bg_frane/bg_mid/button01")
	ui.poweAddBtn = transform:Find("Container/bg_frane/bg_mid/btn_add")

	ui.itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	--ui.itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	--ui.heroPrefab = ResourceLibrary.GetUIPrefab("CommonItem/list_hero_common")
	ui.heroPrefab = ResourceLibrary.GetUIPrefab("Hero/listitem_hero_item")
	ui.energySprite = transform:Find("Container/bg_frane/bg_mid/bg_jindu/Sprite"):GetComponent("UISprite")
	ui.energyTipObject = transform:Find("Container/bg_frane/bg_mid/bg_jindu/bg").gameObject
	ui.energyLabel1 = transform:Find("Container/bg_frane/bg_mid/bg_jindu/bg/Label (1)"):GetComponent("UILabel")
	ui.energyLabel2 = transform:Find("Container/bg_frane/bg_mid/bg_jindu/bg/Label"):GetComponent("UILabel")
    SetClickCallback(ui.energySprite.gameObject, function(go)
        if go == ui.tipObject then
            ui.tipObject = nil
        else
            ui.tipObject = go
            ui.energyTipObject:SetActive(true)
        end
	end)

	local massSta = Global.GetMinMassSceneEnergyValue()
	if massSta == 0 then
		massSta = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.EliteRebelCostEnergy).value
	end

	ui.EliteRebelCostEnergy.text = massSta
	local tileInfoMore = TileInfoMore(ui.more)
	SetClickCallback(ui.share.gameObject, function(go) 
		local artSettingData = TableMgr:GetArtSettingData(Guid)
        tileInfoMore:Open(ui.share.gameObject,TextMgr:GetText(eliteData.name), tileMsg.data.pos.x,tileMsg.data.pos.y,artSettingData.icon)
	end)
	
	MainData.AddListener(Refresh)
	UpdateTime()
end

local function SetPowerUI()
	local sceneEnergy = MainData.GetSceneEnergy()
    local maxSceneEnergy = MainData.GetMaxSceneEnergy()
	ui.power.text = string.format("%d/%d" , sceneEnergy , maxSceneEnergy)
	ui.powerSlider.value = sceneEnergy / maxSceneEnergy
	
	SetClickCallback(ui.poweAddBtn.gameObject, Global.ShowNoEnoughSceneEnergy)
end

local function SetUI()
	UIUtil.SetClickCallback(ui.mask.gameObject, function()
		Global.CloseUI(_M)
	end)

	UIUtil.SetClickCallback(ui.closeBtn.gameObject, function()
		Global.CloseUI(_M)
	end)

	--title
	ui.title.text = TextMgr:GetText(eliteData.name)
	--desLabel and btn_des
	ui.rebelDes.text = TextMgr:GetText(eliteData.des)
	UIUtil.SetClickCallback(ui.detailBtn.gameObject, function()
		EliteRebelHelp.Show()
	end)

	SetDragCallback(ui.elitShowDragBox.gameObject , function(go ,delta)
		ui.elitShow.localEulerAngles = Vector3(0, ui.elitShow.localEulerAngles.y - delta.x,0)
	end)
	
	--coodinate
	ui.coodinate.text = string.format("#1 X:%s , Y:%s" , tileMsg.data.pos.x , tileMsg.data.pos.y)
	--power and addbtbn
	SetPowerUI()
	--btn zhengcha 
	SetClickCallback(ui.zhenchaBtn.gameObject, function()
		TileInfo.BeginSpyEx(tileMsg.data.pos.x , tileMsg.data.pos.y, 2,1 , tileMsg , function(mesBox) 
			if mesBox then
				Global.CloseUI(_M)
			end
		end)
		
	end)
	--btn jijieBtn
	SetClickCallback(ui.jijieBtn.gameObject, function()

		local massSta = Global.GetMinMassSceneEnergyValue()
		if massSta == 0 then
			massSta = RebelData.GetActivityInfo().massSta
		end
		 if MainData.GetSceneEnergy() < massSta then
            Global.ShowNoEnoughSceneEnergy(massSta - MainData.GetSceneEnergy() +1)
            return
        end
	
		--主城等级判断
		if maincity.GetBuildingByID(1).data.level < eliteData.baselevel then
			MessageBox.Show(System.String.Format(TextMgr:GetText("ui_worldmap_99") ,eliteData.baselevel ),
			function()
			end)
			return
		end
		
		--战争大厅解锁判断
		if maincity.GetBuildingByID(43) == nil or maincity.GetBuildingByID(43).data == nil then
			MessageBox.Show(TextMgr:GetText("assemble_warning_4"),
			function()
			end)
			return
		end
	

        local uid = tileMsg ~= nil and tileMsg.data.uid or 0
        local mtc = MassTroopsCondition()
        local x = tileMsg.data.pos.x
        local y = tileMsg.data.pos.y
        mtc.target_enable_mass =  true
        mtc.isActMonster = true
        mtc:CreateMass4BattleCondition(function(success)
            if success then
                assembled_time.Show(function(time)
                    if time ~= 0 then
                        local building = maincity.GetBuildingByID(43)  
                        if building ~= nil then
                            local curAssembledData = TableMgr:GetAssembledData(building.data.level)
                            mtc:ShowCreateMassBattleMove(uid, TextMgr:GetText(eliteData.name), x, y,curAssembledData.armynum,time)
							Global.CloseUI(_M)
                        end                           
                    end
                end,false,true)
            end
        end,true)   
	end)
	--reward
	local showlist = TableMgr:GetDropShowData(tonumber(eliteData.dropshow))
	if #showlist > 0 then
		for i , v in pairs(showlist) do
			local dropdata = showlist[i]
			if dropdata.contentType == 1 then
				LoadBriefRewardItem(ui.rewardList , showlist[i])
			elseif dropdata.contentType == 3 then
				LoadBriefRewardHero(ui.rewardList , showlist[i])
			end
		end
	end
	ui.rewardList:Reposition()
	
	--show model
	if eliteShow == nil then
		eliteShow = ResourceLibrary:GetConstructionShow(eliteData.prefab)
		if eliteShow ~= nil then
			NGUITools.AddChild(ui.elitShow.gameObject , eliteShow.gameObject)
		end
	end
end

local function Draw()
	LoadUI()
	SetUI()
end

function Show(tmsg, gid, tdata)
	print("show EliteRebel . type = "..tmsg.elite.type , "  level = " .. tmsg.elite.level)
	tileMsg = tmsg
	Guid = gid
	eliteData = TableMgr:GetEliteRebelData(tileMsg.elite.type , tileMsg.elite.level)
	
	if tileMsg == nil or eliteData == nil then
		print("错误：精英叛军消息为空 或者配置表错误")
		return
	end
	
	Global.OpenUI(_M)
end

function Refresh()
	SetPowerUI()
end

function Awake()
	AddDelegate(UICamera, "onPress", OnUICameraPress)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
end

function Update()
	local leftTimeSec = tileMsg.elite.escapeTime - Serclimax.GameTime.GetSecTime()
	if leftTimeSec >= 0 then
		ui.escapeTime.text = Serclimax.GameTime.SecondToString3(leftTimeSec)
	else
		ui.escapeTime.text = "00:00:00"
	end
    if timer >= 0 then
        timer = timer - GameTime.deltaTime
        if timer < 0 then
            timer = 1
            UpdateTime()
        end
    end
end

function Start()
	Draw()
end

function Close()
	MainData.RemoveListener(Refresh)
	Guid = nil
	tileMsg = nil
	eliteData = nil
	eliteShow = nil
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
	
	ui = nil
end

module("BattlefieldReport", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local BattleResult

local ExitCallBack
local isPVP4PVE = false
local isMoba = false

local CustomCallBack
local eventSourceName
local uiCoroutine

local TopUI

local ArmyTypeID = {
    [1001] = "TabName_1001",
    [1002] = "TabName_1002",
    [1003] = "TabName_1003",
    [1004] = "TabName_1004",
	
    [101] = "TabName_101",
    [102] = "TabName_102",
    [10000] = "PVPChapter_All",
    --[["unit_buff_soilder_5",
    "unit_buff_soilder_6",
    "unit_buff_soilder_7",
    "unit_buff_soilder_8",--]]
}

local ArrTypeID = {
    [2] = "unit_buff_attr_2",
    [5] = "unit_buff_attr_5",
    [9] = "unit_buff_attr_9",
}

local function exchange(table,i,j)
    local k = table[i]
    table[i] = table[j]
    table[j] = k
end

function GetArmyTypeID(armyType)
	return ArmyTypeID[armyType]
end

function GetAttrTypeID(armyType)
	return ArrTypeID[armyType]
end

function GetAttValue(armyType , attrId , tatts)
	for i=1, #tatts , 1 do
		if tatts[i].armyType == armyType and tatts[i].attrId == attrId then
			return tatts[i].value
		end
	end
	return 0
end

function GetCampArmyResult(rsCampMsg , defendBuild , mobaMode)
	local campResult = {}
	campResult[1001] = {total=0 , lost=0 , kill=0 , armyType=1001}
	campResult[1002] = {total=0 , lost=0 , kill=0 , armyType=1002}
	campResult[1003] = {total=0 , lost=0 , kill=0 , armyType=1003}
	campResult[1004] = {total=0 , lost=0 , kill=0 , armyType=1004}
	
	if defendBuild then
		campResult[101] = {total=0 , lost=0 , kill=0 , armyType=101}
		campResult[102] = {total=0 , lost=0 , kill=0 , armyType=102}
	end
	

	if rsCampMsg ~= nil and #rsCampMsg > 0 then
		for i=1 , #rsCampMsg , 1 do
			for j=1 , #rsCampMsg[i].ArmyResults , 1 do
				--local barrackData = Global.GTableMgr:GetBarrackData(rsCampMsg.ArmyResults[j].Army.baseid , rsCampMsg.ArmyResults[j].level)
				local armyType = rsCampMsg[i].ArmyResults[j].Army.baseid
				if campResult[armyType] == nil then
					campResult[armyType] = {}
					campResult[armyType].total = rsCampMsg[i].ArmyResults[j].TotalNum
					campResult[armyType].lost = rsCampMsg[i].ArmyResults[j].DeadNum + rsCampMsg[i].ArmyResults[j].InjuredNum
					campResult[armyType].kill = rsCampMsg[i].ArmyResults[j].KillNum
					--print(armyType , campResult[armyType])
				else
					campResult[armyType].total = campResult[armyType].total + rsCampMsg[i].ArmyResults[j].TotalNum
					campResult[armyType].lost = campResult[armyType].lost + rsCampMsg[i].ArmyResults[j].DeadNum + rsCampMsg[i].ArmyResults[j].InjuredNum
					campResult[armyType].kill = campResult[armyType].kill + rsCampMsg[i].ArmyResults[j].KillNum
					--print(armyType , campResult[armyType])
				end
			end
		end
	end
	
	local returnResult = {}
	table.insert(returnResult , campResult[1001])
	table.insert(returnResult , campResult[1002])
	table.insert(returnResult , campResult[1003])
	table.insert(returnResult , campResult[1004])
	if defendBuild and (not mobaMode) then
		table.insert(returnResult , campResult[101])
		table.insert(returnResult , campResult[102])
	end
	
	return returnResult
end

function QuickSort(table,s,e)
    if s < 1 or e > #table then
        return
    end
    local i = s
    local j = e    
    if i>j then 
        return;
    end    
    local b = table[s].value


    while(i<j) do
        while(i<j and table[j].value<=b) do
            j = j-1
        end

        while(i<j and table[i].value >= b )do
            i = i+1
        end
        if i<j then
            exchange(table,i,j)
        end           
    end
    exchange(table,s,i)
    QuickSort(table,s,i-1)
    QuickSort(table,j+1,e)
end

local function InitArr()
    local ArrRoot = {}
    for i =1,5,1 do
        ArrRoot[i] = {}
        ArrRoot[i].root = transform:Find("Container/bg_frane/bg_mid/frame/bg_skill ("..(i-1)..")")
        ArrRoot[i].left_text = ArrRoot[i].root:Find("bg_left/text"):GetComponent("UILabel")
        ArrRoot[i].left_num = ArrRoot[i].root:Find("bg_left/num"):GetComponent("UILabel")
        ArrRoot[i].right_text = ArrRoot[i].root:Find("bg_right/text"):GetComponent("UILabel")
        ArrRoot[i].right_num = ArrRoot[i].root:Find("bg_right/num"):GetComponent("UILabel")
    end
        
    local pinfo = PVP_SLG.GetPlayerInfo()
    if pinfo == nil or pinfo.arr == nil then
        return 
    end
    local arrs = {}
    arrs[1] = {}
    if pinfo.arr[1] ~= nil then
        for i =1,#pinfo.arr[1].attrs,1 do
            print("1",i, pinfo.arr[1].attrs[i].value,pinfo.arr[1].attrs[i].armyType,pinfo.arr[1].attrs[i].attrId)
            arrs[1][i] = {}
            arrs[1][i].armyType = pinfo.arr[1].attrs[i].armyType
            arrs[1][i].attrId = pinfo.arr[1].attrs[i].attrId
            arrs[1][i].value = pinfo.arr[1].attrs[i].value
            print("1",i, arrs[1][i].value,arrs[1][i].armyType,arrs[1][i].attrId)
        end
    end

    arrs[2] = {}
    if pinfo.arr[2] ~= nil then
        for i =1,#pinfo.arr[2].attrs,1 do
            print("2",i, pinfo.arr[2].attrs[i].value,pinfo.arr[2].attrs[i].armyType,pinfo.arr[2].attrs[i].attrId)
            arrs[2][i] = {}
            arrs[2][i].armyType = pinfo.arr[2].attrs[i].armyType
            arrs[2][i].attrId = pinfo.arr[2].attrs[i].attrId
            arrs[2][i].value = pinfo.arr[2].attrs[i].value
             print("2",i, arrs[2][i].value,arrs[2][i].armyType,arrs[2][i].attrId)
        end
    end
    for i =1,2,1 do
            for j =1,5,1 do
                if i ==1 then
                    ArrRoot[j].left_text.text = TextMgr:GetText("restrain_3")
                    ArrRoot[j].left_num.text = ""
                else
                    ArrRoot[j].right_text.text = TextMgr:GetText("restrain_3")
                    ArrRoot[j].right_num.text = ""                   
                end
            end            
    end
    for i =1,2,1 do
        if #arrs[i] ~= 0 then
            QuickSort(arrs[i],1,#arrs[i])
            for j =1,5,1 do
                if i ==1 then
                    if j <= #arrs[i] then
                        ArrRoot[j].left_text.text = TextMgr:GetText(ArmyTypeID[arrs[i][j].armyType]) .. TextMgr:GetText(ArrTypeID[arrs[i][j].attrId])
                        ArrRoot[j].left_num.text = System.String.Format("{0:N1}%",  arrs[i][j].value)                    
                    end
                else
                    if j <= #arrs[i] then
                        ArrRoot[j].right_text.text = TextMgr:GetText(ArmyTypeID[arrs[i][j].armyType]) .. TextMgr:GetText(ArrTypeID[arrs[i][j].attrId])
                        ArrRoot[j].right_num.text = System.String.Format("{0:N1}%",  arrs[i][j].value)                      
                    end
                end
            end            
        end
    end


end

local function InitPlayerHeroDetail(root_obj,player)
    local hero_ui = {}
    hero_ui.noitem = root_obj.transform:Find("bg_general/frame/bg_noitem").gameObject
    hero_ui.noitem:SetActive(false)
    hero_ui.hero = {}
    for i =1,5,1 do
        hero_ui.hero[i] =  root_obj.transform:Find("bg_general/frame/Scroll View/Grid/listitem_hero_small ("..(i-1)..")")
        hero_ui.hero[i].gameObject:SetActive(false)
    end
    if #(player.hero) == 0 then
        hero_ui.noitem:SetActive(true)
    else
        for i = 1,#(player.hero),1 do
            local hero = {}
            local heroData =  Global.GTableMgr:GetHeroData(player.hero[i].baseid)
            hero_ui.hero[i].gameObject:SetActive(true)
            HeroList.LoadHeroObject(hero, hero_ui.hero[i])
            HeroList.LoadHero(hero, player.hero[i], heroData)
        end
    end
end

local function InitPlayerSoldierDetail(root_obj,player,soldier_perfab)
    local soldier_ui = {}
    -- soldier_ui.grid = root_obj.transform:Find("bg_soldier/Scroll View/Grid"):GetComponent("UIGrid")
    -- soldier_ui.scrollView =  root_obj.transform:Find("bg_soldier/Scroll View"):GetComponent("UIScrollView")
    soldier_ui.table = root_obj.transform:Find("bg_soldier/Table"):GetComponent("UITable")
    rootWidget = root_obj:GetComponent("UIWidget")    
    for i = 1,#(player.ArmyResults),1 do
        rootWidget.height = rootWidget.height +32
        
        local soldier = {}
        soldier = NGUITools.AddChild(soldier_ui.table.gameObject, soldier_perfab)
        soldier.name = (5 - player.ArmyResults[i].Army.level)*100 + (9-player.ArmyResults[i].Army.baseid)
        soldier:SetActive(true)
        soldier.level_sprite = soldier.transform:Find("bg_1/icon"):GetComponent("UISprite")
        soldier.level_sprite.spriteName = "level_"..player.ArmyResults[i].Army.level
        soldier.name_lable = soldier.transform:Find("bg_1/name"):GetComponent("UILabel")
        local data = Barrack.GetAramInfo(player.ArmyResults[i].Army.baseid,player.ArmyResults[i].Army.level)
        soldier.name_lable.text = TextMgr:GetText(data.SoldierName)
        soldier.total_lable = soldier.transform:Find("text (1)"):GetComponent("UILabel")
        soldier.total_lable.text = player.ArmyResults[i].TotalNum
        soldier.injured_lable = soldier.transform:Find("text (2)"):GetComponent("UILabel")
        soldier.injured_lable.text = player.ArmyResults[i].InjuredNum
        soldier.dead_lable = soldier.transform:Find("text (3)"):GetComponent("UILabel")
        soldier.dead_lable.text = player.ArmyResults[i].DeadNum
    end
    soldier_ui.table:Reposition()

    -- soldier_ui.grid:Reposition()
    -- soldier_ui.scrollView:SetDragAmount(0, 0, false) 
end

local function AddPlayerInfo(player,player_perfab,soldier_perfab,parent_view,parent_table,index,CampIndex)
    local player_ui = {}
    player_ui.root_obj = NGUITools.AddChild(parent_table.gameObject, player_perfab)
    player_ui.root_obj.name = index
    player_ui.root_obj:SetActive(true)
    player_ui.trf = player_ui.root_obj.transform
    player_ui.TotolNum_label = player_ui.trf:Find("bg_list/bg_right/bg_total/num"):GetComponent("UILabel")
    player_ui.TotolNum_label.text = player.BattleForce
    player_ui.TotalKill_label =  player_ui.trf:Find("bg_list/bg_right/bg_destroy/num"):GetComponent("UILabel")
    player_ui.TotalKill_label.text = player.Destroy
    player_ui.icon_tex =  player_ui.trf:Find("bg_list/bg_touxiang/icon_touxiang"):GetComponent("UITexture")
    local face = CustomCallBack == nil and player.icon or CustomCallBack(CampIndex == 1 and "player1face" or "player2face")
    --if face == 0 then
    --    face = 101
    --end
    player_ui.icon_tex.mainTexture = ResourceLibrary:GetIcon("Icon/head/",face)
    player_ui.name_lable = player_ui.trf:Find("bg_list/bg_touxiang/text_name"):GetComponent("UILabel")
    player_ui.name_lable.text = CustomCallBack == nil and player.name or CustomCallBack(CampIndex == 1 and "player1" or "player2")
    if player_ui.name_lable.text == "" then
        player_ui.name_lable.text = "Player"
    end
    player_ui.level_lable = player_ui.trf:Find("bg_list/bg_touxiang/level text"):GetComponent("UILabel")
    player_ui.level_lable.text = player.level
    if player.level == 0 then
        player_ui.level_lable.gameObject:SetActive(false)
    end
    player_ui.open_btn =  player_ui.trf:Find("bg_list/btn_open")
    player_ui.table_item = player_ui.trf:GetComponent("ParadeTableItemController")
    player_ui.detail_root_obj =  player_ui.trf:Find("ItemInfo_open")

	local playerHead = player_ui.trf:Find("bg_list/bg_touxiang")
    SetClickCallback(playerHead.gameObject , function()
		if isMoba then
			MobaPersonalInfo.Show(player.uid)
			return
		end
		
        if CustomCallBack ~= nil then
            if CustomCallBack("ClickFace"..CampIndex) then
                if eventSourceName == nil and player.uid ~= nil then
                    OtherInfo.RequestShow(player.uid)
                end
            end
        elseif eventSourceName == nil and player.uid ~= nil then
			OtherInfo.RequestShow(player.uid)
		end
	end)
	
    InitPlayerHeroDetail(player_ui.detail_root_obj,player)
    InitPlayerSoldierDetail(player_ui.detail_root_obj,player,soldier_perfab)
    
    player_ui.table_item:CalAutoHight()
    return player_ui
end

function ExeExitCallBack()
    --print("ExitCallBack  ------------- ",ExitCallBack)
    if ExitCallBack ~= nil then
        ExitCallBack()
    end   
    ExitCallBack = nil
end


local function LoadUI()
    SetClickCallback( transform:Find("Container/bg_frane/btn_close").gameObject,function()
		if isMoba then
			CloseAll()
			return
		end
		
		if not isPVP4PVE then
            Global.QuitSLGPVP(function()
                ExeExitCallBack()
            end)
        else
            ExeExitCallBack()
        end
    end)
    SetClickCallback( transform:Find("Container").gameObject,function()
		if isMoba then
			CloseAll()
			return
		end
		
		if not isPVP4PVE then
            Global.QuitSLGPVP(function()
                ExeExitCallBack()
            end)
        else
            ExeExitCallBack()
        end
    end)    
    TopUI = {}
    TopUI.strong = transform:Find("Container/bg_frane/btn_strong").gameObject
    SetClickCallback(TopUI.strong, function()
        if not isPVP4PVE then
            Global.QuitSLGPVP(function()
                --ExeExitCallBack()
                GetStrong.Show()
            end)
        else
            ExeExitCallBack()
        end
    end)
    TopUI[1] ={}
    TopUI[1].icon_tex = transform:Find("Container/bg_frane/bg_top/bg_left/bg_name/icon")
    TopUI[1].name_lable = transform:Find("Container/bg_frane/bg_top/bg_left/bg_name/text"):GetComponent("UILabel")
    TopUI[1].name_lable.text = BattleResult.ACampPlayers[1].name

    TopUI[1].result_lable = transform:Find("Container/bg_frane/bg_top/bg_left/text"):GetComponent("UILabel")
    TopUI[1].result_lable.gameObject:SetActive(false)
    TopUI[1].result_win = transform:Find("Container/bg_frane/bg_top/bg_left/win")
    TopUI[1].result_lose = transform:Find("Container/bg_frane/bg_top/bg_left/lose")
    local isteamone = false
    for i, v in ipairs(BattleResult.ACampPlayers) do
        if v.uid == MainData.GetCharId() then
            isteamone = true
        end
    end
    if BattleResult.winteam == 1 then
        TopUI[1].result_win.gameObject:SetActive(true)
        TopUI.strong:SetActive(not isMoba and not isPVP4PVE and not isteamone)
    else
        TopUI[1].result_lose.gameObject:SetActive(true)
        TopUI.strong:SetActive(not isMoba and not isPVP4PVE and isteamone)
    end

    --TopUI[1].result_lable.text = BattleResult.winteam == 1 and TextMgr:GetText("common_ui18") or TextMgr:GetText("common_ui19")
    TopUI[1].result_lable.gradientTop =  BattleResult.winteam == 1 and NGUIMath.HexToColor(0x88F992FF) or NGUIMath.HexToColor(0xFF7676FF)
    TopUI[1].result_lable.gradientBottom = BattleResult.winteam == 1 and NGUIMath.HexToColor(0x2FB017FF) or NGUIMath.HexToColor(0xFF0000FF)

    TopUI[2] ={}
    TopUI[2].icon_tex = transform:Find("Container/bg_frane/bg_top/bg_right/bg_name/icon")
    TopUI[2].name_lable = transform:Find("Container/bg_frane/bg_top/bg_right/bg_name/text"):GetComponent("UILabel")
    TopUI[2].name_lable.text = BattleResult.DCampPlayers[1].name

    TopUI[2].result_lable = transform:Find("Container/bg_frane/bg_top/bg_right/text"):GetComponent("UILabel")
    TopUI[2].result_lable.gameObject:SetActive(false)
    TopUI[2].result_win = transform:Find("Container/bg_frane/bg_top/bg_right/win")
    TopUI[2].result_lose = transform:Find("Container/bg_frane/bg_top/bg_right/lose")

    if BattleResult.winteam == 2 then
        TopUI[2].result_win.gameObject:SetActive(true)
    else
        TopUI[2].result_lose.gameObject:SetActive(true)
    end

    --TopUI[2].result_lable.text = BattleResult.winteam == 2 and TextMgr:GetText("common_ui18") or TextMgr:GetText("common_ui19")
    TopUI[2].result_lable.gradientTop =  BattleResult.winteam == 2 and NGUIMath.HexToColor(0x88F992FF) or NGUIMath.HexToColor(0xFF7676FF)
    TopUI[2].result_lable.gradientBottom = BattleResult.winteam == 2 and NGUIMath.HexToColor(0x2FB017FF) or NGUIMath.HexToColor(0xFF0000FF)


    TopUI[1].scrollView = transform:Find("Container/bg_frane/Scroll View_left"):GetComponent("UIScrollView")
    TopUI[1].table = transform:Find("Container/bg_frane/Scroll View_left/Table"):GetComponent("UITable")
    
    TopUI[2].scrollView = transform:Find("Container/bg_frane/Scroll View_right"):GetComponent("UIScrollView")
    TopUI[2].table = transform:Find("Container/bg_frane/Scroll View_right/Table"):GetComponent("UITable")

    TopUI.player_perfab =  transform:Find("ItemInfo_left").gameObject
    TopUI.player_perfab_right = transform:Find("ItemInfo_right").gameObject
    TopUI.soldier_perfab = transform:Find("soldierinfo").gameObject

    TopUI.Aplayers = {}
    for i =1,#(BattleResult.ACampPlayers),1 do
        table.insert(TopUI.Aplayers, AddPlayerInfo(BattleResult.ACampPlayers[i],TopUI.player_perfab_right,TopUI.soldier_perfab,TopUI[1].scrollView,TopUI[1].table,i,1))
    end
    
    TopUI.Dplayers = {}
    for i =1,#(BattleResult.DCampPlayers),1 do
        table.insert(TopUI.Dplayers, AddPlayerInfo(BattleResult.DCampPlayers[i],TopUI.player_perfab,TopUI.soldier_perfab,TopUI[2].scrollView,TopUI[2].table,i,2))
    end 
    InitArr()
	
    --[[if BattleResult.input.user.team2[1].actMonster ~= nil and BattleResult.input.user.team2[1].actMonster > 0 then
    	local monster = TableMgr:GetActMonsterRuleData(BattleResult.input.user.team2[1].actMonster)
    	TopUI.Dplayers[1].icon_tex.mainTexture = ResourceLibrary:GetIcon("Icon/head/",RebelData.GetActivityInfo().headIcon)
	    TopUI.Dplayers[1].name_lable.text = Global.GTextMgr:GetText(monster.name)
	    TopUI[2].name_lable.text = Global.GTextMgr:GetText(monster.name)
	    TopUI.Dplayers[1].level_lable.gameObject:SetActive(false)
    end]]
    
    SetClickCallback( transform:Find("Container/bg_frane/bg_mid/frame/bg_title/btn_help").gameObject,function()
        GOV_Help.Show(GOV_Help.HelpModeType.BattleFieldReport)
    end)
end


function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end


function Awake()
   
end

function Start()
	if uiCoroutine ~= nil then
		coroutine.stop(uiCoroutine)
	end
	uiCoroutine = coroutine.start(function()
		coroutine.step()
    if #(BattleResult.ACampPlayers) == 1 then
        UICamera.Notify(TopUI.Aplayers[1].open_btn.gameObject, "OnClick", nil)
        TopUI.Aplayers[1].table_item:OnClickOpen()
    end

    TopUI[1].table:Reposition()
    TopUI[1].scrollView:SetDragAmount(0, 0, false)   

    if #(BattleResult.DCampPlayers) == 1 then
        UICamera.Notify(TopUI.Dplayers[1].open_btn.gameObject, "OnClick", nil)
    end    

    TopUI[2].table:Reposition()
    TopUI[2].scrollView:SetDragAmount(0, 0, false)   
    end)


end

function Close()
	if uiCoroutine ~= nil then
		coroutine.stop(uiCoroutine)
		uiCoroutine = nil
	end
	
	isPVP4PVE = false
	isMoba = false
    BattleResult = nil
    eventSourceName = nil
    eventSourceFace = nil
    eventTargetName = nil
    eventTargetFace = nil
    CustomCallBack = nil
    --ExitCallBack = nil
end

function SetEventData(sourceName, sourceFace, targetName, targetFace)
    eventSourceName = sourceName
    eventSourceFace = sourceFace
    eventTargetName = targetName
    eventTargetFace = targetFace
end

function SetBattleResult(battle_result,callback,customCallBack,is4Pve)
    print("Set Battle Result",battle_result,callback)
    CustomCallBack = customCallBack
    BattleResult = battle_result
    ExitCallBack = callback
	isPVP4PVE = is4Pve == nil and false or is4Pve
	isMoba = BattleResult.input.battleType ~= 4 and BattleResult.input.mobaSceneId > 0 
end

function SetExitCallBack(callback)
	ExitCallBack = callback
end

function Show()
    if BattleResult == nil then
        return false
    end
    if eventSourceName ~= nil then
        for i =1,#(BattleResult.ACampPlayers),1 do
            local player = BattleResult.ACampPlayers[i] 
            player.icon = eventSourceFace
            player.name = eventSourceName
            player.level = 5
        end

        for i =1,#(BattleResult.DCampPlayers),1 do
            local player = BattleResult.DCampPlayers[i]
            player.icon = eventTargetFace
            player.name = eventTargetName
            player.level = 1
        end 
    end
    PVP_SLG.Hide()
    Global.OpenUI(_M)
    LoadUI()
    return true
end






module("BattleHistory", package.seeall)
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

local battleListMsg

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
    local closeButton = transform:Find("Container/bg_frane/bg_title/btn_close")
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, CloseAll)

	AddDelegate(UICamera, "onClick", OnUICameraClick)
	AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)

	_ui.grid = transform:Find("Container/bg_frane/background/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.item = transform:Find("Container/bg_frane/background/playerlist").gameObject
	_ui.item.gameObject:SetActive(false)
	ReqBattleList(function()
		if _ui == nil then 
			return 
		end 
		LoadBattleList(_ui.grid,_ui.item)
	end,true)
end

function OnUICameraClick(go)

    Tooltip.HideItemTip()
    if go ~= _ui.tooltip then
        _ui.tooltip = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()

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


function reverseTable(tab)  
    local tmp = {}  
    for i = 1, #tab do  
        local key = #tab  
        tmp[i] = table.remove(tab)  
    end  
  
    return tmp  
end  

function LoadBattleList(_grid,objitem)
    local total =0

	for i=0, _grid.transform.childCount-1 do
		local chatitem = _grid.transform:GetChild(i)
		chatitem.gameObject:SetActive(false)
	end
	Global.DumpMessage(battleListMsg,"d:/BattleHistory.lua")
	for _, item in pairs(battleListMsg) do
		
		if item ~= nil and item.result~= nil then 
			--print_r(item)
			local obj = nil 
			local childCount = _grid.transform.childCount
			if childCount > tonumber(total)  then
				obj = _grid.transform:GetChild(tonumber(total)).gameObject
			else
				obj = NGUITools.AddChild( _grid.gameObject,objitem)
			end 
			
			local uiItem = {}
			
			uiItem.review = obj.transform:Find("btn_review"):GetComponent("UIButton")
			uiItem.lv = obj.transform:Find("playerinfo/level"):GetComponent("UILabel")
			uiItem.name = obj.transform:Find("playerinfo/level/name"):GetComponent("UILabel")
			uiItem.head = obj.transform:Find("head/avatar"):GetComponent("UITexture")
			
			
			
			uiItem.headFrame = obj.transform:Find("head")
			uiItem.militaryRank = obj.transform:Find("head/Military"):GetComponent("UITexture")
			uiItem.flag = obj.transform:Find("playerinfo/level/flag"):GetComponent("UITexture")
			
			uiItem.victory = obj.transform:Find("head/victory")
			
			uiItem.defeat = obj.transform:Find("head/defeat")
			
			uiItem.down = obj.transform:Find("down_rank"):GetComponent("UISprite")
			uiItem.text_down = obj.transform:Find("down_rank/text_downrank"):GetComponent("UILabel")
			
			uiItem.text_combate = obj.transform:Find("playerinfo/combat/number"):GetComponent("UILabel")
			uiItem.vipSprite = obj.transform:Find("head"):GetComponent("UISprite")
			uiItem.vipNum = obj.transform:Find("head/vipicon/num"):GetComponent("UILabel")
			uiItem.text_combate.text =  item.enemy.pkval
			
			uiItem.head.mainTexture = ResourceLibrary:GetIcon("Icon/head/", item.enemy.face)
			uiItem.lv.text = "Lv"..item.enemy.level
			uiItem.name.text = item.enemy.charname
			uiItem.flag.mainTexture = UIUtil.GetNationalFlagTexture(item.enemy.nation)
			--uiItem.headFrame.gameObject.name = item.enemy.charid
			
			local rankData = TableMgr:GetMilitaryRankTable()[item.enemy.militaryrankid or 0]
			uiItem.militaryRank.mainTexture = ResourceLibrary:GetIcon("Icon/MilitaryRank/", rankData.Icon)

			local player2 =  item.result.input.user.team2[1] --BattleInfo.result.DCampPlayers[1];
			local player1 =  item.result.input.user.team1[1]
			
			if uiItem.vipSprite ~= nil then
				uiItem.vipSprite.spriteName = tableData_tVip.data[item.enemy.viplevel].headBox
			end
			uiItem.vipNum.text = item.enemy.viplevel
			
			local win = false
			if player2.user.charid == MainData.GetCharId() then 
				if item.result.winteam ==1 then 
					win = false
				else
					win = true
				end 
			else
				if item.result.winteam ==1 then 
					win = true
				else
					win = false
				end 
			end 
			
			
			if win == false then
				uiItem.text_down.text = item.nrank
				uiItem.victory.gameObject:SetActive(true)
				uiItem.defeat.gameObject:SetActive(false)
				uiItem.down.gameObject:SetActive(true)
				if item.orank < item.nrank then
					uiItem.down.gameObject:SetActive(true)
				else
					uiItem.down.gameObject:SetActive(false)
				end 
			else
				uiItem.victory.gameObject:SetActive(false)
				uiItem.defeat.gameObject:SetActive(true)
				uiItem.text_down.text = ""
				uiItem.down.gameObject:SetActive(false)
			end
			
			local selectedList = {}
			for i = 1, 5 do
				selectedList[i] ={}
				local hero = {}
				hero.bg = obj.transform:Find(string.format("bg_battle skills/bg_selected/bg/hero%d", i))
				hero.btn = obj.transform:Find(string.format("bg_battle skills/bg_selected/bg/hero%d/bg", i)):GetComponent("UIButton")
				hero.icon = obj.transform:Find(string.format("bg_battle skills/bg_selected/bg/hero%d/head icon", i)):GetComponent("UITexture")
				hero.levelLabel = obj.transform:Find(string.format("bg_battle skills/bg_selected/bg/hero%d/head icon/level text", i)):GetComponent("UILabel")
				hero.qualityList = {}
				for j = 1, 5 do
					hero.qualityList[j] = obj.transform:Find(string.format("bg_battle skills/bg_selected/bg/hero%d/head icon/outline%d", i, j))
				end
				hero.starList = {}
				for j = 1, 6 do
					hero.starList[j] = obj.transform:Find(string.format("bg_battle skills/bg_selected/bg/hero%d/head icon/star/star%d", i, j))
				end
				hero.plus = obj.transform:Find(string.format("bg_battle skills/bg_selected/bg/hero%d/bg/plus", i))
				hero.lock = obj.transform:Find(string.format("bg_battle skills/bg_selected/bg/hero%d/bg/lock", i))
				selectedList[i].hero = hero

				local skill = {}
				skill.bg = obj.transform:Find(string.format("bg_battle skills/bg_selected/bg/hero%d/bg_skill", i))
				--skill.btn = obj.transform:Find(string.format("bg_battle skills/bg_selected/bg/hero%d/bg_skills (%d)", i)):GetComponent("UIButton")
				skill.icon = obj.transform:Find(string.format("bg_battle skills/bg_selected/bg/hero%d/bg_skill/icon_skill", i)):GetComponent("UITexture")
				--skill.lock = obj.transform:Find(string.format("bg_battle skills/bg_selected/bg/hero%d/bg_skills (%d)/locked", i))
				hero.bg.gameObject:SetActive(false)
				selectedList[i].skill = skill
			end    
			

			obj.name = k
			LoadBattle(item,selectedList)
			SetClickCallback(uiItem.headFrame.gameObject, function(go)
				OtherInfo.RequestShow(item.enemy.charid)
			end)
			
			SetClickCallback(uiItem.review.gameObject, function(go)
				CheckBattleReport(item)
			end)
			
			obj:SetActive(true)
			total = total +1
		end 
	end
	_grid:Reposition()
end

function CheckRedPot()
	print("BattleHistory CheckRedPot ")
	if battleListMsg == nil then 
		print("BattleHistory CheckRedPot is null ")
		return false
	end
	if #battleListMsg >0 then 
		local tag = battleListMsg[1].battleTime
		print("BattleHistory CheckRedPot ",UnityEngine.PlayerPrefs.GetInt("lastBattleHistory") ,tag)
		if UnityEngine.PlayerPrefs.GetInt("lastBattleHistory") ~= tag then
			return true
		end 
	end 
	return false
end 

function ReqBattleList(callback,open)
	local req = BattleMsg_pb.MsgArenaListBattleResultRequest()
	Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgArenaListBattleResultRequest, req, BattleMsg_pb.MsgArenaListBattleResultResponse, function(msg)
		Global.DumpMessage(msg,"d:/BattleHistory.lua")
		if msg.code == ReturnCode_pb.Code_OK then

			battleListMsg= msg.report
			battleListMsg= reverseTable(battleListMsg)

			if #battleListMsg >0 and open == true then 
				local tag = battleListMsg[1].battleTime
				UnityEngine.PlayerPrefs.SetInt("lastBattleHistory", tag)
			end 
			
			if callback ~= nil then
				callback()
			end
        else
        	Global.ShowError(msg.code)
        end
    end, false)	

end 

function CheckBattleReport(report)
	
	local msg ={
        content = "Mail_attack_actmonster_win_Desc",
        misc =
        {
            recon ={},
            robres ={},
            traderes ={},
            heros ={},
            train ={},
            attachShow ={},
            siegeShow ={},
            reportid = 8602,
            source ={},
            target ={},
            fortOccupy ={},
            result ={},
        }        
    }
	msg.misc.source.guildBanner = ""
	msg.misc.target.guildBanner = ""
	msg.misc.result = report.result
	
	
	--设置战斗返回时的界面显示：
	local mainui = "MainCityUI"
	local posx = 0
	local posy = 0
	if GUIMgr:FindMenu("WorldMap") ~= nil then
		mainui = "WorldMap"
		local curpos = WorldMap.GetCenterMapCoord()
		posx , posy = WorldMap.GetCenterMapCoord()
	end
	Global.SetBattleReportBack("BattleHistory" , "BattleHistory" , posx , posy)
	
	--启动战报播放
	Global.CheckBattleReportEx(msg ,mailSubtype , function()
		print("report end function")
		
		local battleBack = Global.GetBattleReportBack()
		if battleBack.MainUI == "BattleHistory" then
            BattleHistory.Show()
		end

	end)
end


function LoadBattle(BattleInfo,selectedList)
	if #(BattleInfo.result.DCampPlayers) == 0 then 
		return 
	end 
	
	if BattleInfo.result.input== nil or BattleInfo.result.input.user== nil or BattleInfo.result.input.user.team2== nil then 
		return 
	end 
	
	
	
	print("item ",total)
	
	local player2 =  BattleInfo.result.input.user.team2[1] --BattleInfo.result.DCampPlayers[1];
	local player1 =  BattleInfo.result.input.user.team1[1]
	
	local player = player2
	if player2.user.charid == MainData.GetCharId() then 
		player = player1 
	end 
	
	local heroMsgList =  player.hero.heros -- player.hero
	for i =1,#(heroMsgList),1 do
		
		local hero = selectedList[i].hero
		--HeroList.LoadHeroObject(hero, heroTransform)
		local heroMsg = Common_pb.HeroInfo() 
		heroMsg.star = heroMsgList[i].star
		heroMsg.level = heroMsgList[i].level
		heroMsg.num = 1 --vv.num
		local heroData = TableMgr:GetHeroData(heroMsgList[i].baseid)
		HeroList.LoadHero(hero, heroMsg, heroData)
		local pvpSkill = heroMsgList[i].pvpSkill
		local skillData = TableMgr:GetPvpSkillDataByIdLevel(pvpSkill.id, pvpSkill.level)--TableMgr:GetGodSkillDataByIdLevel(pvpSkill.id, pvpSkill.level)
		selectedList[i].skill.bg.gameObject:SetActive(true)
		hero.bg.gameObject:SetActive(true)
		selectedList[i].skill.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Skill/", skillData.iconId)
	end
end 

function Close()
	RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)

	Tooltip.HideItemTip()

    _ui = nil
end

function Show()
    Global.OpenUI(_M)
end

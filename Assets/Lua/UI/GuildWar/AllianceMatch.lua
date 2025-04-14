module("AllianceMatch", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local SetDragCallback = UIUtil.SetDragCallback

local matchInfo
local maxRound =1
local zoneid =0
local guildid =0

local _ui

local function QuitPressCallback(go, isPressed)
	if not isPressed then
		GUIMgr:CloseMenu("AllianceMatch")
	end
end

function LoadObjItem(item)
	local badgeWidget = {}
	if item ~= nil then 
		badgeWidget.borderTexture = item:Find("icon/outline icon"):GetComponent("UITexture")
		badgeWidget.icon = item:Find("icon")
		badgeWidget.colorTexture = item:Find("icon/color"):GetComponent("UITexture")
		badgeWidget.totemTexture = item:Find("icon/totem icon"):GetComponent("UITexture")
		-- UnionBadge.LoadBadgeById(badgeWidget, tonumber(str[5]))
		badgeWidget.name = item:Find("name"):GetComponent("UILabel")
		badgeWidget.server = item:Find("sever"):GetComponent("UILabel")
		badgeWidget.mask = item:Find("mask")
		badgeWidget.obj = item
		badgeWidget.sp = item:GetComponent("UISprite")
	end 
	return badgeWidget
end 

function LoadResultItem(item)
	local badgeWidget = {}
	-- badgeWidget.result = item:Find("time"):GetComponent("UILabel")
	badgeWidget.bg = item
	return badgeWidget
end 

function LoadResultLine(item,line,th1,tc1,tv1,th2,tc2,tv2,up)
	item.th1= line:Find(th1)
	item.tc1= line:Find(tc1)
	item.tv1= line:Find(tv1)
	item.th2= line:Find(th2)
	item.tc2= line:Find(tc2)
	item.tv2= line:Find(tv2)
	item.up= line:Find(up)
	return item
end

function ShowResult(msg)
	Global.CheckMobaBattleReportEx(msg)
	BattlefieldReport.SetBattleResult(msg.misc.result,nil)
	BattlefieldReport.Show()
end

function Show()
	--zoneid = zone
	--guildid = guild
	Global.OpenUI(_M)
end

function Start()
	_ui = {}
	local btnQuit = transform:Find("Container/bg_frane/bg_top/btn_close")
	SetPressCallback(btnQuit.gameObject, QuitPressCallback)
	local bg = transform:Find("Container")
	SetPressCallback(bg.gameObject, QuitPressCallback)
	
	local mid= transform:Find("Container/bg_frane/mid")
	_ui.items1 = {}
	_ui.items1[1] = LoadObjItem(mid.transform:Find("left/bg_position (1)"))
	_ui.items1[2] = LoadObjItem(mid.transform:Find("left/bg_position (2)"))
	_ui.items1[3] = LoadObjItem(mid.transform:Find("left/bg_position (3)"))
	_ui.items1[4] = LoadObjItem(mid.transform:Find("left/bg_position (4)"))
	_ui.items1[5] = LoadObjItem(mid.transform:Find("left/bg_position (8)"))
	_ui.items1[6] = LoadObjItem(mid.transform:Find("left/bg_position (7)"))
	_ui.items1[7] = LoadObjItem(mid.transform:Find("left/bg_position (6)"))
	_ui.items1[8] = LoadObjItem(mid.transform:Find("left/bg_position (5)"))
	
	_ui.items1[9] = LoadObjItem(mid.transform:Find("right/bg_position (1)"))
	_ui.items1[10] = LoadObjItem(mid.transform:Find("right/bg_position (2)"))
	_ui.items1[11] = LoadObjItem(mid.transform:Find("right/bg_position (3)"))
	_ui.items1[12] = LoadObjItem(mid.transform:Find("right/bg_position (4)"))
	_ui.items1[13] = LoadObjItem(mid.transform:Find("right/bg_position (8)"))
	_ui.items1[14] = LoadObjItem(mid.transform:Find("right/bg_position (7)"))
	_ui.items1[15] = LoadObjItem(mid.transform:Find("right/bg_position (6)"))
	_ui.items1[16] = LoadObjItem(mid.transform:Find("right/bg_position (5)"))
	
	
	_ui.items2 = {}
--[[	_ui.items2[1] = LoadObjItem(mid.transform:Find("left/bg_position (5)"))
	_ui.items2[2] = LoadObjItem(mid.transform:Find("left/bg_position (6)"))
	_ui.items2[3] = LoadObjItem(mid.transform:Find("left/bg_position (11)"))
	_ui.items2[4] = LoadObjItem(mid.transform:Find("left/bg_position (12)"))
	
	_ui.items2[5] = LoadObjItem(mid.transform:Find("right/bg_position (6)"))
	_ui.items2[6] = LoadObjItem(mid.transform:Find("right/bg_position (5)"))
	_ui.items2[7] = LoadObjItem(mid.transform:Find("right/bg_position (10)"))
	_ui.items2[8] = LoadObjItem(mid.transform:Find("right/bg_position (11)"))
	]]--
	
	_ui.items3 = {}
	
--[[	_ui.items3[1] = LoadObjItem(mid.transform:Find("left/bg_position (7)"))
	_ui.items3[2] = LoadObjItem(mid.transform:Find("left/bg_position (10)"))
	_ui.items3[3] = LoadObjItem(mid.transform:Find("right/bg_position (7)"))
	_ui.items3[4] = LoadObjItem(mid.transform:Find("right/bg_position (9)"))
	]]--
	_ui.items4 = {}
	_ui.items4[1] = LoadObjItem(mid.transform:Find("left/bg_position (9)"))
	_ui.items4[2] = LoadObjItem(mid.transform:Find("right/bg_position (9)"))
	
	local line1 = mid.transform:Find("left/line")
	local line2 = mid.transform:Find("right/line")
	_ui.results1 = {}
	_ui.results1[1] = LoadResultItem(mid.transform:Find("left/icon_result (1)"))
	_ui.results1[2] = LoadResultItem(mid.transform:Find("left/icon_result (2)"))
	_ui.results1[3] = LoadResultItem(mid.transform:Find("left/icon_result (6)"))
	_ui.results1[4] = LoadResultItem(mid.transform:Find("left/icon_result (5)"))
	_ui.results1[5] = LoadResultItem(mid.transform:Find("right/icon_result (1)"))
	_ui.results1[6] = LoadResultItem(mid.transform:Find("right/icon_result (2)"))
	_ui.results1[7] = LoadResultItem(mid.transform:Find("right/icon_result (6)"))
	_ui.results1[8] = LoadResultItem(mid.transform:Find("right/icon_result (5)"))
	LoadResultLine(_ui.results1[1],line1,"bg_line (1)","bg_corner","bg_line (3)","bg_line (2)","bg_corner (1)","bg_line (4)","bg_line (5)")
	LoadResultLine(_ui.results1[2],line1,"bg_line (11)","bg_corner (5)","bg_line (10)","bg_line (8)","bg_corner (4)","bg_line (9)","bg_line (7)")
	LoadResultLine(_ui.results1[3],line1,"bg_line (23)","bg_corner (11)","bg_line (22)","bg_line (20)","bg_corner (10)","bg_line (21)","bg_line (19)")
	LoadResultLine(_ui.results1[4],line1,"bg_line (14)","bg_corner (6)","bg_line (15)","bg_line (17)","bg_corner (7)","bg_line (16)","bg_line (18)")
	
	LoadResultLine(_ui.results1[5],line2,"bg_line (17)","bg_corner (7)","bg_line (16)","bg_line (14)","bg_corner (6)","bg_line (15)","bg_line (18)")
	LoadResultLine(_ui.results1[6],line2,"bg_line (20)","bg_corner (10)","bg_line (21)","bg_line (23)","bg_corner (11)","bg_line (22)","bg_line (19)")
	LoadResultLine(_ui.results1[7],line2,"bg_line (8)","bg_corner (4)","bg_line (9)","bg_line (11)","bg_corner (5)","bg_line (10)","bg_line (7)")
	LoadResultLine(_ui.results1[8],line2,"bg_line (2)","bg_corner (1)","bg_line (4)","bg_line (1)","bg_corner","bg_line (3)","bg_line (5)")
	
	_ui.results2 = {}
	_ui.results2[1] = LoadResultItem(mid.transform:Find("left/icon_result (3)"))
	_ui.results2[2] = LoadResultItem(mid.transform:Find("left/icon_result (4)"))
	_ui.results2[3] = LoadResultItem(mid.transform:Find("right/icon_result (3)"))
	_ui.results2[4] = LoadResultItem(mid.transform:Find("right/icon_result (4)"))
	
	LoadResultLine(_ui.results2[1],line1,"bg_line (5)","bg_corner (2)","bg_line (6)","bg_line (7)","bg_corner (3)","bg_line (12)","bg_line (25)")
	LoadResultLine(_ui.results2[2],line1,"bg_line (19)","bg_corner (9)","bg_line (24)","bg_line (18)","bg_corner (8)","bg_line (13)","bg_line (26)")
	LoadResultLine(_ui.results2[3],line2,"bg_line (18)","bg_corner (8)","bg_line (13)","bg_line (19)","bg_corner (9)","bg_line (24)","bg_line (26)")
	LoadResultLine(_ui.results2[4],line2,"bg_line (7)","bg_corner (3)","bg_line (12)","bg_line (5)","bg_corner (2)","bg_line (6)","bg_line (25)")
	
	
	_ui.results3 = {}
	_ui.results3[1] = LoadResultItem(mid.transform:Find("left/icon_result (7)"))
	_ui.results3[2] = LoadResultItem(mid.transform:Find("right/icon_result (7)"))
	LoadResultLine(_ui.results3[1],line1,"bg_line (25)","bg_corner (12)","bg_line (27)","bg_line (26)","bg_corner (13)","bg_line (28)","bg_line (29)")
	LoadResultLine(_ui.results3[2],line2,"bg_line (26)","bg_corner (13)","bg_line (28)","bg_line (25)","bg_corner (12)","bg_line (27)","bg_line (29)")
	
	
	_ui.results4 = {}
	_ui.results4[1] = LoadResultItem(mid.transform:Find("icon_result (1)"))
	LoadResultLine(_ui.results4[1],line1,"bg_line (29)","bg_line (29)","bg_line (29)","bg_line (29)","bg_line (29)","bg_line (29)","bg_line (29)")
	_ui.results4[1].tc2 = line2:Find("bg_line (29)")
	
	
	_ui.third_item1 = LoadObjItem(mid.transform:Find("third/bg_position (9)"))
	_ui.third_item2 = LoadObjItem(mid.transform:Find("third/bg_position (10)"))
	_ui.third_result = LoadResultItem(mid.transform:Find("third/icon_result (1)"))
	_ui.third = transform:Find("Container/bg_frane/mid/third")
	
	_ui.items4[3] = _ui.third_item1
	_ui.items4[4] = _ui.third_item2
	_ui.results4[2] = _ui.third_result
	
	_ui.results = {_ui.results1,_ui.results2,_ui.results3,_ui.results4}
	_ui.items = {_ui.items1,_ui.items2,_ui.items3,_ui.items4}
	
	UIUtil.SetClickCallback(mid:Find("btn_reward").gameObject, function()
		AllianceRank.Show()
	end)
	
	_ui.champion = {}
	_ui.champion.borderTexture = transform:Find("Container/bg_frane/champion_icon/outline icon"):GetComponent("UITexture")
	_ui.champion.colorTexture = transform:Find("Container/bg_frane/champion_icon/color"):GetComponent("UITexture")
	_ui.champion.totemTexture = transform:Find("Container/bg_frane/champion_icon/totem icon"):GetComponent("UITexture")
	-- UnionBadge.LoadBadgeById(badgeWidget, tonumber(str[5]))
	_ui.champion.name = transform:Find("Container/bg_frane/champion_icon/bg_name/name"):GetComponent("UILabel")
	_ui.champion.bgname = transform:Find("Container/bg_frane/champion_icon/bg_name")

	ResetUI()
	UpdateChampion(nil)

	local req = GuildMobaMsg_pb.GuildMobaRoundInfoRequest()
	--req.zoneid =zoneid
	--req.guildid =guildid
    Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaRoundInfoRequest, req, GuildMobaMsg_pb.GuildMobaRoundInfoResponse, function(msg)
        Global.DumpMessage(msg, "D:/GuildMobaRoundInfoResponse.lua")
        if msg.code == ReturnCode_pb.Code_OK then
            UpdateUI(msg)
        else
            Global.ShowError(msg.code)
        end
    end, true)
end

function ResetUI()
	maxRound = 0
	local i =1
	while i <= #_ui.items do
		for k, v in ipairs(_ui.items[i]) do
			UpdateTeamInfo(v)
		end
		i=i+1
	end 

	i =1
	while i <= #_ui.results do
		for k, v in ipairs(_ui.results[i]) do
			UpdateResultInfo(v)
		end
		i=i+1
	end 
	
	--_ui.third.gameObject:SetActive(false)
end 

function UpdateUI(msg)
	matchInfo = msg
	ResetUI()
	matchInfo.round = #matchInfo.rounds
	-- matchInfo.round =4
	
	maxRound =0
	
	
	
	local i =1
	while i <= matchInfo.round do
		local RoundInfo = nil 
		for k, v in ipairs(matchInfo.rounds) do
			if k == i then
				RoundInfo = v
				RoundInfo.round = k
			end
		end
		--print("show round"..RoundInfo.round)
		ShowRound(RoundInfo)
		
		
		for k, v in ipairs(RoundInfo.pairlist) do
		
			if tonumber(v.teamA.guildid)<= 0 and tonumber(v.teamB.guildid)<= 0 then

			else
				maxRound = maxRound+1
				break
			end
		end
		i=i+1
	end 
	
	print("show round  "..maxRound)
	
	i =1
	while i <= matchInfo.round do
		local RoundInfo = nil 
		for k, v in ipairs(matchInfo.rounds) do
			if k == i then
				RoundInfo = v
				RoundInfo.round = k
			end
		end
		--print("show round"..RoundInfo.round)
		ShowRound(RoundInfo)
		i=i+1
	end 
	
	i =1
	while i <= matchInfo.round do
		local RoundInfo = nil 
		for k, v in ipairs(matchInfo.rounds) do
			if k == i then
				RoundInfo = v
				RoundInfo.round = k
			end
		end
		--print("show round"..RoundInfo.round)
		--ShowRound(RoundInfo,true)
		i=i+1
	end 
	
end 

function ShowRound(RoundInfo,showUp)
	if RoundInfo == nil then 
		return 
	end 

	local round = RoundInfo.round
	
	local items = _ui.items[round]
	local results = _ui.results[round]
	
	if round == 4 then 
		UpdateChampion(RoundInfo.pairlist[1])
	end 
	
	if showUp == true then 
		for k, v in ipairs(RoundInfo.pairlist) do
	
			if round > maxRound then

				UpdateResultInfoUp(results[k],nil,false)
			else
				
				if v.winner == 1 then 
					
					UpdateResultInfoUp(results[k],v,false)
				elseif v.winner ==2 then 
		
					UpdateResultInfoUp(results[k],v,false)
				else

					UpdateResultInfoUp(results[k],nil,false)
				end 
			end

		end
	else
			for k, v in ipairs(RoundInfo.pairlist) do
		
				if round > maxRound then
				
					UpdateTeamInfo(items[2*k-1],nil)
					UpdateTeamInfo(items[2*k],nil) 
					UpdateResultInfo(results[k],nil,false)
				else
					UpdateTeamInfo(items[2*k-1],v.teamA)
					UpdateTeamInfo(items[2*k],v.teamB) 
					

					if v.winner == 1 then 
						if items[2*k-1]~=nil and items[2*k]~= nil and items[2*k-1].mask~=nil and items[2*k].mask~= nil then 
							items[2*k-1].mask.gameObject:SetActive(false)
							items[2*k].mask.gameObject:SetActive(true)
						end 
						UpdateResultInfo(results[k],v,false)
					elseif v.winner ==2 then 
						if items[2*k-1]~=nil and items[2*k]~= nil and items[2*k-1].mask~=nil and items[2*k].mask~= nil then 
							items[2*k-1].mask.gameObject:SetActive(true)
							items[2*k].mask.gameObject:SetActive(false)
						end 
						UpdateResultInfo(results[k],v,false)
					else
						
						if items[2*k-1]~=nil and items[2*k]~= nil and items[2*k-1].mask~=nil and items[2*k].mask~= nil then 
							items[2*k-1].mask.gameObject:SetActive(false)
							items[2*k].mask.gameObject:SetActive(false)
						end 
						UpdateResultInfo(results[k],nil,false)
					end 
				end
			end 

	end

end

function ShowLine(line,show)
	if line~=nil then 
		if show~=nil then 
			line:Find("full").gameObject:SetActive(show)
			line.gameObject:SetActive(true);
		else
			line.gameObject:SetActive(false);
		end 
	end 
end 

function UpdateResultInfo(item,PairInfo)
	if item == nil or item.bg == nil then 
		return 
	end 
	if PairInfo ~= nil then
		-- item.result.text = Global.SecondToStringFormat(PairInfo.starttime , "MM/dd") 
		SetClickCallback(item.bg.gameObject, function()
			UnionMobaActivityData.RequestBattleResult(PairInfo.sceneid, function(msg)
				if #msg.result.userlist.users > 0 then
					Mobaconclusion.Show(msg.result, PairInfo.winner)
				end
			end)
		end)
		item.bg.gameObject:SetActive(true)
		if item.th1~=nil then 
			
				if PairInfo.winner == 1 then 
					ShowLine(item.th1,true)
					ShowLine(item.tc1,true)
					ShowLine(item.tv1,true)
					ShowLine(item.th2,false)
					ShowLine(item.tc2,false)
					ShowLine(item.tv2,false)
					ShowLine(item.up,true)
				elseif PairInfo.winner ==2 then 
					ShowLine(item.th1,false)
					ShowLine(item.tc1,false)
					ShowLine(item.tv1,false)
					ShowLine(item.th2,true)
					ShowLine(item.tc2,true)
					ShowLine(item.tv2,true)
					ShowLine(item.up,true)
				else
					ShowLine(item.th1,false)
					ShowLine(item.tc1,false)
					ShowLine(item.tv1,false)
					ShowLine(item.th2,false)
					ShowLine(item.tc2,false)
					ShowLine(item.tv2,false)
					ShowLine(item.up,false)
				end 

			
		end 
		
	else
		-- item.result.text = ""
		item.bg.gameObject:SetActive(false)
		if item.th1~=nil then 
			ShowLine(item.th1,false)
					ShowLine(item.tc1,false)
					ShowLine(item.tv1,false)
					ShowLine(item.th2,false)
					ShowLine(item.tc2,false)
					ShowLine(item.tv2,false)
					ShowLine(item.up,false)
		end 
		
	end 
end 

function UpdateResultInfoUp(item,PairInfo)
	if item == nil or item.bg == nil then 
		return 
	end 
	if PairInfo ~= nil then
		item.bg.gameObject:SetActive(true)
		if item.th1~=nil then 
			if PairInfo.round == 1 then 
				if PairInfo.winner == 1 then 
					ShowLine(item.up,true)
				elseif PairInfo.winner ==2 then 
					ShowLine(item.up,true)
				else

					--ShowLine(item.up,false)
				end 
			else
				if PairInfo.winner == 1 then 
					ShowLine(item.up,true)
				elseif PairInfo.winner ==2 then 
					ShowLine(item.up,true)
				else

					--ShowLine(item.up,false)
				end 
					--ShowLine(item.up,false)
			end 
			
		end 
		
		
	else
		-- item.result.text = ""
		item.bg.gameObject:SetActive(false)
		if item.th1~=nil then 
			-- ShowLine(item.up,false)
		end 
		
	end 
end 

function UpdateTeamInfo(item,GuildInfo)
	if item == nil or item.name== nil then 
		return 
	end 
	if GuildInfo ~= nil  then 
		if GuildInfo.guildbanner == nil or GuildInfo.guildbanner=="" then 
			GuildInfo.guildbanner = "0"
		end
		local id = tonumber(GuildInfo.guildbadge)
		if id == nil then 
		 id = 0
		end 
		UnionBadge.LoadBadgeById(item, id)
		item.name.text = GuildInfo.guildname
		item.server.text = GuildInfo.zonename
		--item.mask.gameObject:SetActive(false)
		item.obj.gameObject:SetActive(true)
		item.icon.gameObject:SetActive(true)
		if GuildInfo.guildid == UnionInfoData.GetGuildId() and ServerListData.GetCurrentZoneId()==GuildInfo.zoneid then 
			item.sp.spriteName = "bg_counterwork1"
		else
			item.sp.spriteName = "bg_counterwork"
		end 
	else
		UnionBadge.LoadBadgeById(item, 0)
		item.name.text = ""
		item.server.text = ""
		item.mask.gameObject:SetActive(true)
		item.icon.gameObject:SetActive(false)
		item.sp.spriteName = "bg_counterwork"
		--item.obj.gameObject:SetActive(false)
	end 
end 


function UpdateChampion(msg)
	local GuildInfo = nil 

	if msg ~= nil then 
		if msg.winner == 1 then 
			GuildInfo = msg.teamA
		elseif msg.winner == 2 then 
			GuildInfo = msg.teamB
		end 
	end 
	
	if GuildInfo == nil then 
		_ui.champion.borderTexture.gameObject:SetActive(false)
		_ui.champion.colorTexture.gameObject:SetActive(false)
		_ui.champion.totemTexture.gameObject:SetActive(false)
		_ui.champion.bgname.gameObject:SetActive(false)
	else 

		if GuildInfo.guildbanner == nil or GuildInfo.guildbanner=="" then 
			GuildInfo.guildbanner = "0"
		end
		local id = tonumber(GuildInfo.guildbadge)
		if id == nil then 
		 id = 0
		end 
		UnionBadge.LoadBadgeById(_ui.champion, id)

		_ui.champion.borderTexture.gameObject:SetActive(true)
		_ui.champion.colorTexture.gameObject:SetActive(true)
		_ui.champion.totemTexture.gameObject:SetActive(true)
		_ui.champion.bgname.gameObject:SetActive(true)
		_ui.champion.name.text = GuildInfo.guildname
	end 
	
end 

function Close()

    _ui = nil
end

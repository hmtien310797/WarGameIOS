module("PVP_Rewards", package.seeall)
local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr.Instance
local String = System.String
local TextMgr = Global.GTextMgr
local SetClickCallback = UIUtil.SetClickCallback
local GetParameter = UIUtil.GetParameter
local SetParameter = UIUtil.SetParameter
local ResourceLibrary = Global.GResourceLibrary
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameObject = UnityEngine.GameObject

local _ui
local OldMailListData
local NewMailListData
local NewMailData
local NewMailInfoData
local showCoroutine

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

function deepcopy(t)
    OldMailListData = {}
    for i,v in ipairs(t) do
        local new = {}
        new.id = v.id
        table.insert(OldMailListData, new)
    end
end

function SaveMailListData(mailListData)
    deepcopy(mailListData)
    -- OldMailListData = MergeFrom(mailListData)
    -- print(#OldMailListData)
end

--查找最新战斗邮件
function FindNewMail()
    for i,v in ipairs(NewMailListData) do
        newMail = true
        -- if v.category == MailMsg_pb.MailType_Report then
            for io,vo in ipairs(OldMailListData) do
                -- if vo.category == MailMsg_pb.MailType_Report then
                    if tonumber(v.id) == tonumber(vo.id) then
                        newMail = false
                    end
                -- end
            end
            if newMail == true then
                NewMailData = v
            end
        -- end
    end
end


function RequestMailInfoData(data, callback)
    local req = MailMsg_pb.MsgUserMailReadRequest()
    req.mailid = data.id
    req.isRead = false
    Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailReadRequest, req, MailMsg_pb.MsgUserMailReadResponse, function(msg)
        if msg.code == 0 then
            -- Global.DumpMessage(msg,"D:/sss.lua")
			NewMailInfoData = msg
			--如果是别人打得野怪就不显示
			if NewMailData.subtype == Mail.MailReportType.MailReport_actmonsterfinder then
				-- print("邮件id"..NewMailInfoData.mail.misc.source.uid.."自己id"..MainData.GetCharId())
				if NewMailInfoData.mail.misc.source.uid == MainData.GetCharId() then
					if callback ~= nil then
						callback()
					end
				end
			else
				if callback ~= nil then
					callback()
				end
			end
        end
    end, true)    
end

function CheckPvpShow()
	NewMailListData = MailListData.GetData()
	
	if OldMailListData == nil then
		return
	end
	-- print(GUIMgr.UIRoot.transform.childCount)
    if GUIMgr.UIRoot.transform.childCount == 3 and (not Global.IsSlgMobaMode()) then        
        FindNewMail()
        -- if NewMailData.subtype == 0 then 
        -- Global.DumpMessage(NewMailData, "D:/ssss.lua")
        -- end
        if NewMailData and NewMailData.category == MailMsg_pb.MailType_Report and
        NewMailData.subtype ~= Mail.MailReportType.MailReport_takeres and
        NewMailData.subtype ~= Mail.MailReportType.MailReport_recon and
        NewMailData.subtype ~= Mail.MailReportType.MailReport_reconmonster and
        NewMailData.subtype ~= Mail.MailReportType.MailReport_recontakeres and
        NewMailData.subtype ~= Mail.MailReportType.MailReport_berecon and
        NewMailData.subtype ~= Mail.MailReportType.MailReport_shieldDefence and
        NewMailData.subtype ~= Mail.MailReportType.MailReport_shieldAttack and
        NewMailData.subtype ~= Mail.MailReportType.MailReport_shieldGatherAttack and
        NewMailData.subtype ~= Mail.MailReportType.MailReport_shieldGatherDefence and
		NewMailData.subtype ~= Mail.MailReportType.MailReport_reconElite and
		NewMailData.subtype ~= Mail.MailReportType.MailReport_reconTurret and
		NewMailData.subtype ~= Mail.MailReportType.MailReport_reconGovt and
		NewMailData.subtype ~= Mail.MailReportType.MailReport_GuildMine and
		NewMailData.subtype ~= Mail.MailReportType.MailReport_GuildTrain and
		NewMailData.subtype ~= Mail.MailReportType.MailReport_reconStronghold and
		NewMailData.subtype ~= Mail.MailReportType.MailReport_reconFortress and
		NewMailData.subtype ~= Mail.MailReportType.MailReport_prisonerRewardSet and
		NewMailData.subtype ~= Mail.MailReportType.MailReport_prisonerRewardOpt and
		NewMailData.subtype ~= Mail.MailReportType.MailReport_prisonerFlee and
		NewMailData.subtype ~= Mail.MailReportType.MailReport_traderes and
		NewMailData.subtype ~= Mail.MailReportType.MailReport_shieldRecon and
		NewMailData.subtype ~= Mail.MailReportType.MailReport_shieldBeRecon and
		NewMailData.subtype ~= 0		
		 then            
            RequestMailInfoData(NewMailData, function() Show() end)            
        end
    end
end

function GetWinLose(readMailData , reportMsg)
	local text = ""
    local winlose = 1
    
    local targetName
    if reportMsg.misc.target.nameText then
        targetName = TextMgr:GetText(reportMsg.misc.target.name)
    else
        targetName = reportMsg.misc.target.name
    end

    local targetGuildBanner
    if reportMsg.misc.target.guildBanner ~= "" then
        targetGuildBanner = "["..reportMsg.misc.target.guildBanner.."]"..targetName
    else
        targetGuildBanner = targetName
    end
    
    local targetPos = "X:"..reportMsg.misc.target.pos.x.."   Y:"..reportMsg.misc.target.pos.y

    local sourceName
    if reportMsg.misc.target.nameText then
        sourceName = TextMgr:GetText(reportMsg.misc.source.name)
    else
        sourceName = reportMsg.misc.source.name
    end
    local sourceGuildBanner
    if reportMsg.misc.source.guildBanner ~= "" then
        sourceGuildBanner = "["..reportMsg.misc.source.guildBanner.."]"..sourceName
    else
        sourceGuildBanner = sourceName
    end
    local sourcePos = "X:"..reportMsg.misc.source.pos.x.."   Y:"..reportMsg.misc.source.pos.y

	if readMailData.subtype == Mail.MailReportType.MailReport_player or readMailData.subtype == Mail.MailReportType.MailReport_robres  then
        if reportMsg.misc.result.winteam == 1 then            
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text1"), targetGuildBanner, targetPos)--"攻击胜利"
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text2"), targetGuildBanner, targetPos)--"攻击失败"
			winlose = 0 
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_defence then
		if reportMsg.misc.result.winteam == 2 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text3"), sourceGuildBanner, sourcePos)--"防守成功"
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text4"), sourceGuildBanner, sourcePos)--"防守失败"
			winlose = 0 
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_robres then
		if reportMsg.misc.result.winteam == 1 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text1"), targetGuildBanner, targetPos)--"采集抢夺成功"
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text2"), targetGuildBanner, targetPos)--"采集抢夺失败"
			winlose = 0 
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_robresdefence then --"抢夺采集防御"
		if reportMsg.misc.result.winteam == 2 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text3"), sourceGuildBanner, sourcePos)--"采集防御成功"
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text4"), sourceGuildBanner, sourcePos)--"采集防御失败"
			winlose = 0 
		end
	
	elseif readMailData.subtype == Mail.MailReportType.MailReport_robclamp then
		if reportMsg.misc.result.winteam == 1 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text1"), targetGuildBanner, targetPos)--"抢夺扎营成功"
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text2"), targetGuildBanner, targetPos)--"抢夺扎营失败"
			winlose = 0 
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_robcampdefence then 
		if reportMsg.misc.result.winteam == 2 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text3"), sourceGuildBanner, sourcePos)--"扎营防御成功"
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text4"), sourceGuildBanner, sourcePos)--"扎营防御失败"
			winlose = 0 
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_actmonster then
		if reportMsg.misc.result.winteam == 1 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text1"), targetGuildBanner, targetPos)--进攻跑车成功
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text2"), targetGuildBanner, targetPos)--进攻跑车失败
			winlose = 0
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_guildmonsterRepoty then
		if reportMsg.misc.result.winteam == 1 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text1"), targetGuildBanner, targetPos)--进攻联盟野怪成功
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text2"), targetGuildBanner, targetPos)--进攻联盟野怪失败
			winlose = 0
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_siegeAttack then
		if reportMsg.misc.result.winteam == 2 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text5"), sourceGuildBanner, sourcePos)--叛军攻城防御成功
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text6"), sourceGuildBanner, sourcePos)--叛军攻城防御失败
			winlose = 0
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_siegeHelp then
		if reportMsg.misc.result.winteam == 2 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text5"), sourceGuildBanner, sourcePos)--叛军攻城防御成功
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text6"), sourceGuildBanner, sourcePos)--叛军攻城防御失败
			winlose = 0
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_monster then
        if reportMsg.misc.result.winteam == 2 then
            text = String.Format(TextMgr:GetText("PVP_Rewards_Text2"), targetGuildBanner, targetPos)--"攻击失败"
            winlose = 0
        else
            text = String.Format(TextMgr:GetText("PVP_Rewards_Text1"), targetGuildBanner, targetPos)--"攻击胜利"
        end
	elseif readMailData.subtype == Mail.MailReportType.MailReport_fort then  --攻击要塞
		text = String.Format(TextMgr:GetText("PVP_Rewards_Text1"), targetGuildBanner, targetPos)
	elseif 	readMailData.subtype == Mail.MailReportType.MailReport_defGovt then 
		if reportMsg.misc.result.winteam == 2 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text3"), sourceGuildBanner, sourcePos)--防守政府成功
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text4"), sourceGuildBanner, sourcePos)--防守政府失败
			winlose = 0
		end
	elseif 	readMailData.subtype == Mail.MailReportType.MailReport_atkGovt then
		if reportMsg.misc.result.winteam == 1 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text1"), targetGuildBanner, targetPos)--攻击政府成功
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text2"), targetGuildBanner, targetPos)--攻击政府失败
			winlose = 0
		end
	elseif 	readMailData.subtype == Mail.MailReportType.MailReport_defTurret then 
		if reportMsg.misc.result.winteam == 2 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text3"), sourceGuildBanner, sourcePos)--防守炮台成功
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text4"), sourceGuildBanner, sourcePos)--防守炮台失败
			winlose = 0
		end
	elseif 	readMailData.subtype == Mail.MailReportType.MailReport_atkTurret then
		if reportMsg.misc.result.winteam == 1 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text1"), targetGuildBanner, targetPos)--攻击炮台成功
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text2"), targetGuildBanner, targetPos)--攻击炮台失败
			winlose = 0
		end		
	elseif 	readMailData.subtype == Mail.MailReportType.MailReport_gatherGovt then
		if reportMsg.misc.result.winteam == 1 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text1"), targetGuildBanner, targetPos)--集结政府成功
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text2"), targetGuildBanner, targetPos)--集结政府失败
			winlose = 0
		end
	elseif	readMailData.subtype == Mail.MailReportType.MailReport_gatherTurret then	
		if reportMsg.misc.result.winteam == 1 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text1"), targetGuildBanner, targetPos)--集结炮台成功
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text2"), targetGuildBanner, targetPos)--集结炮台失败
			winlose = 0
		end
	elseif	readMailData.subtype == Mail.MailReportType.MailReport_atkEliter then	
		if reportMsg.misc.result.winteam == 1 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text1"), targetGuildBanner, targetPos)--集结精英野怪成功
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text2"), targetGuildBanner, targetPos)--集结精英野怪失败
			winlose = 0
		end
	elseif	readMailData.subtype == Mail.MailReportType.MailReport_atkStronghold then --进攻据点
		if reportMsg.misc.result.winteam == 1 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text1"), targetGuildBanner, targetPos)
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text2"), targetGuildBanner, targetPos)
			winlose = 0
		end
	elseif	readMailData.subtype == Mail.MailReportType.MailReport_gathStronghold then
		if reportMsg.misc.result.winteam == 1 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text1"), targetGuildBanner, targetPos)--集结据点成功
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text2"), targetGuildBanner, targetPos)--集结据点失败
			winlose = 0
		end
	elseif	readMailData.subtype == Mail.MailReportType.MailReport_defStronghold then
		if reportMsg.misc.result.winteam == 2 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text3"), targetGuildBanner, targetPos)--防守据点成功
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text4"), targetGuildBanner, targetPos)--防守据点失败
			winlose = 0
		end
	elseif	readMailData.subtype == Mail.MailReportType.MailReport_atkFortress then
		if reportMsg.misc.result.winteam == 1 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text1"), targetGuildBanner, targetPos)--进攻要塞成功
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text2"), targetGuildBanner, targetPos)--进攻要塞失败
			winlose = 0
		end
	elseif	readMailData.subtype == Mail.MailReportType.MailReport_gathFortress then
		if reportMsg.misc.result.winteam == 1 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text1"), targetGuildBanner, targetPos)--集结要塞成功
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text2"), targetGuildBanner, targetPos)--集结要塞失败
			winlose = 0
		end
	elseif	readMailData.subtype == Mail.MailReportType.MailReport_defFortress then
		if reportMsg.misc.result.winteam == 2 then
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text3"), targetGuildBanner, targetPos)--防守要塞成功
		else
			text = String.Format(TextMgr:GetText("PVP_Rewards_Text4"), targetGuildBanner, targetPos)--防守要塞失败
			winlose = 0
		end
	elseif readMailData.subtype == Mail.MailReportType.MailReort_atkWorldCity then
		if reportMsg.misc.result.winteam == 1 then
			text = TextMgr:GetText("Mail_attack_city_win_Title")	--"城市进攻成功"
		else
			text = TextMgr:GetText("Mail_attack_city_fail_Title")--"城市进攻失败"
			winlose = 0 
		end
    end
	
	return text , winlose
end

function LoadItem(itemid, itemCount, grid, mailItem)
	local itemdata = TableMgr:GetItemData(itemid)
	local itemTransform = NGUITools.AddChild(grid.gameObject , mailItem).transform
	local item = {}
	UIUtil.LoadItemObject(item, itemTransform)
	UIUtil.LoadItem(item, itemdata, itemCount)
    SetParameter(itemTransform.gameObject, "item_" .. itemid)
end

local function NeedShow(subtype ,rewardData, rewardSrc)
	if rewardData == nil then
		return false
	end
	if rewardSrc == "attachShow" then
		if subtype == Mail.MailReportType.MailReport_atkEliter then
			if rewardData.charid ~= MainData.GetCharId() then
				return false
			end
		end
	end
	return true
end

function GetShowItemList(msgItemData , NeedShow)
	local itemList = {}
	for i=#msgItemData.attachShow.data , 1 , -1 do
		local itemListData = msgItemData.attachShow.data[i]
		if (NeedShow ~= nil and NeedShow(itemListData)) or NeedShow == nil then
			for i=1 , #itemListData.data.item.items , 1 do
				local itemData = itemListData.data.item.items[i]
				if itemList[itemData.data.baseid] ~= nil then
					itemList[itemData.data.baseid].itemCount = itemList[itemData.data.baseid].itemCount + itemData.data.number
				else
					itemList[itemData.data.baseid] = {baseid = itemData.data.baseid , itemCount = itemData.data.number}
				end
			end
			for i=1 , #itemListData.data.money.money , 1 do
				local itemData = itemListData.data.money.money[i]
				if itemList[itemData.type] ~= nil then
					itemList[itemData.type].itemCount = itemList[itemData.data.baseid].itemCount + itemData.value
				else
					itemList[itemData.type] = {baseid = itemData.type , itemCount = itemData.value , charid = itemListData.charid}
				end
			end
		end
	end
	
	if msgItemData.robres ~= nil and msgItemData.robres.res ~= nil then
		for i=#msgItemData.robres.res , 1 , -1 do
			local itemData = msgItemData.robres.res[i]
			if itemList[itemData.id] ~= nil then
				itemList[itemData.id].itemCount = itemList[itemData.data.baseid].itemCount + itemData.num
			else
				itemList[itemData.id] = {baseid = itemData.id , itemCount = itemData.num}
			end
		end
	end

    local sortList = {}
	for _, v in pairs(itemList) do
		if v then
			table.insert(sortList , v)
		end
	end
	return sortList
end 

local function CheckShowWarLossScore(CampPlayers)
    if tonumber(os.date("%j")) ~= UnityEngine.PlayerPrefs.GetInt("CheckShowWarLossScore") then
        for _, v in ipairs(CampPlayers) do
            if v.uid == MainData.GetCharId() and v.WarLossScore > 0 then
                MessageBox.Show(TextMgr:GetText(Text.PVP_LuckyRotary14))
                UnityEngine.PlayerPrefs.SetInt("CheckShowWarLossScore",tonumber(os.date("%j")))
                UnityEngine.PlayerPrefs.Save()
                return
            end
        end
    end
end

function LoadUI()
    _ui.PVP_Rewards = _ui.transform:Find("PVP_Rewards").gameObject
    _ui.PVP_Defend = _ui.transform:Find("PVP_Defend").gameObject
	local title , WinLose = GetWinLose(NewMailData , NewMailInfoData.mail)
	
    -- print("邮件类型"..NewMailData.subtype)
    --判断是否是防御
    if NewMailData.subtype == Mail.MailReportType.MailReport_defence or
    NewMailData.subtype == Mail.MailReportType.MailReport_robresdefence or
    NewMailData.subtype == Mail.MailReportType.MailReport_robcampdefence or
    NewMailData.subtype == Mail.MailReportType.MailReport_defGovt or
    NewMailData.subtype == Mail.MailReportType.MailReport_defTurret or 
    NewMailData.subtype == Mail.MailReportType.MailReport_siegeAttack or 
	NewMailData.subtype == Mail.MailReportType.MailReport_siegeHelp or
	NewMailData.subtype == Mail.MailReportType.MailReport_defStronghold or
	NewMailData.subtype == Mail.MailReportType.MailReport_defFortress or
    --上面防御的
    NewMailData.subtype == Mail.MailReportType.MailReport_atkTurret or
    NewMailData.subtype == Mail.MailReportType.MailReport_gatherTurret or
    NewMailData.subtype == Mail.MailReportType.MailReport_atkGovt or
    NewMailData.subtype == Mail.MailReportType.MailReport_gatherGovt or
    NewMailData.subtype == Mail.MailReportType.MailReport_robclamp or
    NewMailData.subtype == Mail.MailReportType.MailReport_robres or
    NewMailData.subtype == Mail.MailReportType.MailReport_fort
    then   
        _ui.PVP_Rewards:SetActive(false)
        _ui.PVP_Defend:SetActive(true)

        _ui.win = _ui.transform:Find("PVP_Defend/bg_win").gameObject
		_ui.lose = _ui.transform:Find("PVP_Defend/bg_lose").gameObject
		_ui.strong = _ui.transform:Find("PVP_Defend/bg_lose/btn_strong").gameObject
		SetClickCallback(_ui.strong, function()
			Hide()
			GetStrong.Show()
		end)
        if WinLose == 1 then 
            _ui.win:SetActive(true)
			_ui.lose:SetActive(false)
			_ui.strong:SetActive(false)
        else
            _ui.win:SetActive(false)
			_ui.lose:SetActive(true)
			_ui.strong:SetActive(true)
            CheckShowWarLossScore(NewMailInfoData.mail.misc.result.DCampPlayers)
        end
        _ui.Title = _ui.transform:Find("PVP_Defend/bg_msg/bg/text"):GetComponent("UILabel")
        _ui.Title.text = title        
    else                
        _ui.PVP_Rewards:SetActive(true)
        _ui.PVP_Defend:SetActive(false)

        _ui.win = _ui.transform:Find("PVP_Rewards/bg_win").gameObject
        _ui.lose = _ui.transform:Find("PVP_Rewards/bg_lose").gameObject
        _ui.strong = _ui.transform:Find("PVP_Rewards/bg_lose/btn_strong").gameObject
		SetClickCallback(_ui.strong, function()
			Hide()
			GetStrong.Show()
		end)
        if WinLose == 1 then 
            _ui.win:SetActive(true)
			_ui.lose:SetActive(false)
			_ui.strong:SetActive(false)
        else
            _ui.win:SetActive(false)
			_ui.lose:SetActive(true)
			_ui.strong:SetActive(true)
            CheckShowWarLossScore(NewMailInfoData.mail.misc.result.ACampPlayers)
        end
        _ui.Title = _ui.transform:Find("PVP_Rewards/bg_msg/bg/text"):GetComponent("UILabel")
        _ui.Title.text = title    
		
		--当战斗是集结pvp战斗时，判断是不是发起者，如果不是，将不显示战利品
		if NewMailInfoData.mail.category == MailMsg_pb.MailType_Report and NewMailInfoData.mail.subtype == 2 and NewMailInfoData.mail.misc.source ~= nil then
			local gatherMainPlayer = NewMailInfoData.mail.misc.source
			_ui.getRewardPre =  _ui.transform:Find("PVP_Rewards/bg_get props").gameObject:SetActive(true)
		end

        --判断是否有奖品
        if (NewMailInfoData.mail.misc.attachShow ~= nil and NewMailInfoData.mail.misc.attachShow.data ~= nil and #NewMailInfoData.mail.misc.attachShow.data > 0) or
        (NewMailInfoData.mail.misc.robres ~= nil and #NewMailInfoData.mail.misc.robres.res > 0)
         then
            local noitem = _ui.transform:Find("PVP_Rewards/bg_get props/GameObject/bg_item/text_noitem").gameObject
            noitem:SetActive(false)

            local rewardTypeGrid = _ui.transform:Find("PVP_Rewards/bg_get props/GameObject/bg_item/Scroll View/Grid"):GetComponent("UIGrid")
            local rewardTypeScrollView = transform:Find("PVP_Rewards/bg_get props/GameObject/bg_item/Scroll View"):GetComponent("UIScrollView")
			-- for i = rewardTypeGrid.transform.childCount-1, 0,-1 do
			while rewardTypeGrid.transform.childCount > 0 do
                GameObject.DestroyImmediate(rewardTypeGrid.transform:GetChild(0).gameObject)
            end
            local itemCount = 0
			local showItemList = GetShowItemList(NewMailInfoData.mail.misc , function(itemListData)
				--local itemListData = NewMailInfoData.mail.misc.attachShow.data[i]
				return NeedShow(NewMailData.subtype , itemListData , "attachShow")
			end)
			itemCount = (#showItemList) - 1
			--[[
            for i=#NewMailInfoData.mail.misc.attachShow.data , 1 , -1 do
                local itemListData = NewMailInfoData.mail.misc.attachShow.data[i]
				if NeedShow(NewMailData.subtype , itemListData , "attachShow") then
					itemCount = itemCount + (#itemListData.data.item.items + #itemListData.data.money.money)
				end
                -- rewardTypeGrid.transform.localPosition = UnityEngine.Vector3(190 - itemCount * rewardTypeGrid.cellWidth/2,61)
            end
            if NewMailInfoData.mail.misc.robres ~= nil then
                local itemData = #NewMailInfoData.mail.misc.robres.res
                itemCount = itemCount + itemData
            end
            itemCount = itemCount - 1
			
			]]
            rewardTypeGrid.transform.localPosition = UnityEngine.Vector3(190 - itemCount * rewardTypeGrid.cellWidth/2,61)
			--showCoroutine = coroutine.start(function()  
                for i=#showItemList , 1 , -1 do
                    local itemListData = showItemList[i]
					--local itemData = itemListData.data.item.items[i]
					if itemListData.baseid ~= 12 then
						LoadItem(itemListData.baseid , itemListData.itemCount , rewardTypeGrid ,ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew") )
					end
                end
			    rewardTypeGrid:Reposition()
           -- end)
			--[[
            showCoroutine = coroutine.start(function()  
                for i=#NewMailInfoData.mail.misc.attachShow.data , 1 , -1 do
                    local itemListData = NewMailInfoData.mail.misc.attachShow.data[i]
					if NeedShow(NewMailData.subtype , itemListData , "attachShow") then
						-- local bgItem = NGUITools.AddChild(rewardTypeGrid.gameObject, mailContent.rewardTypeGridItem.gameObject).transform
						-- bgItem:SetParent(rewardTypeGrid.transform , false)
						
						-- local itemTypeName = bgItem:Find("Label"):GetComponent("UILabel")
						-- itemTypeName.text = TextMgr:GetText(itemListData.infoid)
						
						-- local itemListGrid = bgItem:Find("Grid1"):GetComponent("UIGrid")

						for i=1 , #itemListData.data.item.items , 1 do
							local itemData = itemListData.data.item.items[i]
							LoadItem(itemData.data.baseid , itemData.data.number , rewardTypeGrid ,ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew") )
						end
						for i=1 , #itemListData.data.money.money , 1 do
							local itemData = itemListData.data.money.money[i]
							LoadItem(itemData.type , itemData.value , rewardTypeGrid ,ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew") )
						end                    
					end
                    -- itemListGrid:Reposition()
                end
                -- print("掠夺数量"..#NewMailInfoData.mail.misc.robres.res)
                for i=#NewMailInfoData.mail.misc.robres.res , 1 , -1 do
                    local itemData = NewMailInfoData.mail.misc.robres.res[i]  
					LoadItem(itemData.id, itemData.num, rewardTypeGrid ,ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew") )
                end
				
				
                rewardTypeGrid:Reposition()
                
            end)
			]]
            
        end
    end
end

function Awake()
    _ui.mask = transform:Find("mask").gameObject
    _ui.transform = transform
    SetClickCallback(_ui.mask, function(go) Hide() end)
    AddDelegate(UICamera, "onPress", OnUICameraPress)
    LoadUI()
end

function Show()    
    if GUIMgr:IsMenuOpen("PVP_Rewards") then
        LoadUI()
    else
        _ui = {}
        Global.OpenUI(_M)
    end
    
end

function Hide()    
    Global.CloseUI(_M)
end

function Close()
    _ui = nil
    showCoroutine = nil
    RemoveDelegate(UICamera, "onPress", OnUICameraPress)
    coroutine.stop(showCoroutine)
end

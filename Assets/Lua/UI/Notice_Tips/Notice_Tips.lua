module("Notice_Tips", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local SetClickCallback = UIUtil.SetClickCallback

local tipsList

local noticeRoot
local noticePanel
local noticeItem
local tipsTP
local tipsTA
local tipsText
local tipsWidget

local noticeBig
local tipsTPBig
local tipsTABig
local tipsWidgetBig
local tipsTextBig
local tipsTitleBig
local tipsBtnBig
	
local noticeSpeedList

local noticeLeft
local noticeRight
local noticeSpace = 300
local tipsMaxTime = 3
local tipsMinTime = 1

local noticeShowList
local noticeSpaceCounter
local tipsTimeCounter
local tipsCanCounter = false
local tipsNew = true

local tempNoticeList = {}
local tempTipsList = {}
local encoding = false

class "Notice" {}

local function HideTips()
	tipsCanCounter = false
	tipsTA:PlayForward(true)
	tipsTABig:PlayForward(true)
end

local function GetTileInfo(tileMsg,mapX, mapY)
    local tileInfo = {}
    local tileData = WorldMap.GetTileData(tileMsg)
    if tileData == nil then
        local tileGid = WorldMap.GetTileGidByMapCoord(mapX, mapY)
        local ad = TableMgr:GetArtSettingData(tileGid)
        tileInfo.name = TextMgr:GetText( ad.name)
        tileInfo.icon = ad.icon
        return tileInfo
    else
        local gid = WorldMap.GetTileGidByMsgData(mapX, mapY, tileMsg, tileData)
        local artSettingData = TableMgr:GetArtSettingData(gid) 
        tileInfo.icon = artSettingData.icon
    end
    local entryType = tileMsg.data.entryType
    
    if entryType == Common_pb.SceneEntryType_None then
        tileInfo.name = TextMgr:GetText(artSettingData.name)
    elseif entryType == Common_pb.SceneEntryType_Home then
        local homeMsg = tileMsg.home
        local guildMsg = tileMsg.ownerguild
        local name = homeMsg.name
        if guildMsg.guildid ~= 0 then                 
            name = string.format("[%s]%s", guildMsg.guildbanner, homeMsg.name)
        end        
        tileInfo.name = name
    elseif entryType == Common_pb.SceneEntryType_Monster then
        tileInfo.name = TextMgr:GetText(tileData.name)
    elseif entryType == Common_pb.SceneEntryType_ActMonster then
        tileInfo.name = TextMgr:GetText(tileData.name)
    elseif entryType >= Common_pb.SceneEntryType_ResFood and entryType <= Common_pb.SceneEntryType_ResElec then
        tileInfo.name = TextMgr:GetText(tileData.name)
    elseif entryType == Common_pb.SceneEntryType_Barrack or entryType == Common_pb.SceneEntryType_Occupy then
        local entryType = tileMsg.data.entryType
        local barrackMsg = entryType == Common_pb.SceneEntryType_Barrack and tileMsg.barrack or tileMsg.occupy
        tileInfo.name = barrackMsg.name
    end
    return tileInfo
end

function RequestTileInfo(x, y, callback)
    local req = MapMsg_pb.SceneEntryInfoFreshRequest()
    req.pos.x = x
    req.pos.y = y
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.SceneEntryInfoFreshRequest, req, MapMsg_pb.SceneEntryInfoFreshResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            local info = GetTileInfo(msg.entry,x,y)
            if info == nil then
                return
            end
            callback(info.name) 
        else
            Global.FloatError(msg.code, Color.white)
        end
    end, true) 
end

function DecodeString(strings, v, callback)
	if v.paramType == "form" then
		ReconSaveData.Save(v.value)
		--return
	end
	
	if v.paramType == "item" then
		local itemTBData = TableMgr:GetItemData(v.id)
		local nameColor = Global.GetLabelColorNew(itemTBData.quality)
		table.insert(strings, nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1])
	elseif v.paramType == "num" then
		table.insert(strings, v.value)
	elseif v.paramType == "buildname" then
		table.insert(strings, TextMgr:GetText(TableMgr:GetBuildingData(v.id).name))
	elseif v.paramType == "techname" then
		table.insert(strings, TextMgr:GetText(Laboratory.GetTech(v.id).BaseData.Name))
	elseif v.paramType == "guildgift" then
		table.insert(strings, TextMgr:GetText(TableMgr:GetUnionItemData(v.id).name))
	elseif v.paramType == "heroname" then
		table.insert(strings, TextMgr:GetText(TableMgr:GetHeroData(v.id).nameLabel))
	elseif v.paramType == "levelname" then
		table.insert(strings, TextMgr:GetText(TableMgr:GetBattleData(v.id).nameLabel))
	elseif v.paramType == "posname" then
		local temp = tonumber(v.id)
		local y = temp % 10000
		local x = math.floor(temp * 0.0001)
		local tileGid = WorldMap.GetTileGidByMapCoord(x, y)
        local ad = TableMgr:GetArtSettingData(tileGid)
		table.insert(strings, TextMgr:GetText(ad.name))
	elseif v.paramType == "resname" then
		local temp = tonumber(v.id)
		local y = temp % 10000
		local x = math.floor(temp * 0.0001)
		table.insert(strings, TextMgr:GetText(TableMgr:GetResourceRuleDataByTypeLevel(x,y).name))
	elseif v.paramType == "itemname" then
		table.insert(strings, TextUtil.GetSlgBuffTitle(TableMgr:GetSlgBuffData(v.id)))
	elseif v.paramType == "monstername" then
		local temp = tonumber(v.id)
		local y = temp % 10000
		local x = math.floor(temp * 0.0001) -- 1 ��ͨҰ�� 2 �Ұ�� 3 ����Ұ��
		if x == 1 then
			table.insert(strings, TextMgr:GetText(TableMgr:GetMonsterRuleData(y).name))
		elseif x == 2 then
			table.insert(strings, TextMgr:GetText(TableMgr:GetActMonsterRuleData(y).name))
		elseif x == 3 then
			table.insert(strings, TextMgr:GetText(TableMgr:GetUnionMonsterData(y).name))
		elseif x == 5 then
			table.insert(strings, TextMgr:GetText("SiegeMonster_" .. y))
		elseif x == 6 then
			table.insert(strings, TextMgr:GetText(TableMgr:GetMobaMonsterByID(y).name))
		end
	elseif v.paramType == "unitname" then
		local temp = tonumber(v.id)
		local y = temp % 10000
		local x = math.floor(temp * 0.0001)
		table.insert(strings, TextMgr:GetText(TableMgr:GetBarrackData(x,y).SoldierName))
	elseif v.paramType == "guildbanner" then
		table.insert(strings, v.value == "" and "" or "["  .. v.value .. "]")
	elseif v.paramType == "resnum" then
		table.insert(strings, Global.ExchangeValue(v.id))
	elseif v.paramType == "unionBuilding" then
		table.insert(strings, TextMgr:GetText(v.value))
	elseif v.paramType == "restype" then
		local item = TableMgr:GetItemData(v.id)
		table.insert(strings, item == nil and "" or TextUtil.GetItemName(item))
	elseif v.paramType == "level" then
		table.insert(strings, v.id)
	elseif v.paramType == "guildtechname" then
		table.insert(strings, TextMgr:GetText(v.value))
	elseif v.paramType == "unionMonster" then
		table.insert(strings, TextMgr:GetText(v.value))
	elseif v.paramType == "fortname" then
		table.insert(strings, TextMgr:GetText(TableMgr:GetFortRuleData(v.id).name))
	elseif v.paramType == "govname" then
		if v.id == 0 then
			table.insert(strings, TextMgr:GetText("GOV_ui7"))
		else
			table.insert(strings, TextMgr:GetText(TableMgr:GetTurretDataByid(v.id).name))
		end
	elseif v.paramType == "strongholdname" then
		table.insert(strings, TextMgr:GetText(TableMgr:GetStrongholdRuleByID(v.id).name))
	elseif v.paramType == "fortressname" then
		table.insert(strings, TextMgr:GetText(TableMgr:GetFortressRuleByID(v.id).name))
	elseif v.paramType == "guildpositionname" then
		table.insert(strings, TextMgr:GetText(TableMgr:GetUnionPrivilege(v.id).name))
	elseif  v.paramType == "officialsname" then
		table.insert(strings, TextMgr:GetText(TableMgr:GetGoveOfficialDataByid(v.id).name))
	elseif not System.String.IsNullOrEmpty(v.value) then
		table.insert(strings, v.value)
	elseif v.paramType == "mailID"  then
	
		table.insert(strings, v.value)
	elseif v.paramType == "elitename" then
		table.insert(strings , TextMgr:GetText(TableMgr:GetEliteRebelDataById(v.id).name))
	elseif v.paramType == "unionofficialname" then
		table.insert(strings, TextMgr:GetText(tableData_tUnionOfficial.data[v.id].name))
	elseif v.paramType == "mobabuildingname" then
		table.insert(strings, TextMgr:GetText(tableData_tMobaBuildingRule.data[v.id].Name))
	elseif v.paramType == "guildmobabuildingname" then
		table.insert(strings, TextMgr:GetText(tableData_tGuildMobaBuilding.data[v.id].Name))
	elseif v.paramType == "worldcityname" then
		table.insert(strings, TextMgr:GetText(tableData_tWorldCity.data[v.id].Name))
	else
		table.insert(strings, v.value)
	end
	callback()
end

local function DecodeParam(strings, msg, callback)
	if #msg.paras > 0 then
		
		local v = table.remove(msg.paras, 1)
		if msg.noticeType == 10000 then
			table.insert(strings, Mail.ParsrGMContent(v.value, TableMgr:GetLanguageSettingData(TextMgr:GetCurrentLanguageID()).Icon))
			callback()
		elseif msg.content == "TipsNotice_Union_Desc12" then
			table.insert(strings, TextMgr:GetText(Text["union_member_level" .. v.value]))
			callback()
		else
			DecodeString(strings, v, function()
				DecodeParam(strings, msg, callback)
			end)
		end
	else
		callback()
	end
end

local function MakeString(msg, callback)
	local strings = {}
	DecodeParam(strings, msg, function()
		local s = TextMgr:GetText(msg.content)
		for i, v in ipairs(strings) do
			local index = string.find(s,"{")
			if index ~= nil then
				local temps = string.sub(s, 0, index - 1)
				temps = temps .. v
				index = string.find(s,"}")
				temps = temps .. string.sub(s, index + 1)
				s = temps
				index = nil
				temps = nil
			end
		end
		strings = nil
		callback(s)
	end)
end

local function GetNoticeSpeed()
	local speed = 0
	for i, v in pairs(noticeSpeedList) do
		if #NoticeData.noticeList + 1 >= i then
			if speed < v then
				speed = v
			end
		end
	end
	return speed
end

local function MakeNotice()
	if noticeShowList == nil then
		noticeShowList = {}
	end
	if #NoticeData.noticeList > 0 then
		transform:GetComponent("UIPanel").depth = -2
		noticePanel.depth = -1
		local item = Notice()
		item.go = NGUITools.AddChild(noticePanel.gameObject, noticeItem.gameObject)
		item.pos = noticeRight
		item.canNew = true
		local t_notice = table.remove(NoticeData.noticeList, 1)
		item.go.transform:Find("Label"):GetComponent("UILabel").text = t_notice
		table.insert(noticeShowList, item)
	end
end

function Notice:Move()
	self.pos = self.pos - GetNoticeSpeed() * Time.deltaTime
	self.go.transform.localPosition = Vector3(self.pos, 0, 0)
	self.length = NGUIMath.CalculateRelativeWidgetBounds(self.go.transform, false).size.x
	if self.pos + self.length + noticeSpace <= noticeRight then
		if self.canNew then
			self.canNew = false
			MakeNotice()
		end
	end
	if self.pos + self.length <= noticeLeft then
		GameObject.Destroy(self.go)
		table.remove(noticeShowList, 1)
	end
end

function Awake()
	if noticeSpeedList == nil then
		noticeSpeedList = {}
		local speeds = TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.NoticeMoveSpeed).value:split(";")
		for _, v in pairs(speeds) do
			local temp = v:split(":")
			noticeSpeedList[tonumber(temp[1])] = tonumber(temp[2])
		end
	end
	noticeRoot = transform:Find("Container/Scroll_Notice/bg").gameObject
	noticePanel = transform:Find("Container/Scroll_Notice/bg/Panel"):GetComponent("UIPanel")
	noticeItem = transform:Find("Container/Scroll_Notice_ITem")
	tipsTP = transform:Find("Container/panel_tips/bg_tween"):GetComponent("TweenPosition")
	tipsTA = transform:Find("Container/panel_tips/bg_tween"):GetComponent("TweenAlpha")
	tipsWidget = transform:Find("Container/panel_tips/bg_tween"):GetComponent("UIWidget")
	tipsText = transform:Find("Container/panel_tips/bg_tween/text"):GetComponent("UILabel")
	
	noticeBig = transform:Find("Container/panel_tips_big")
	tipsTPBig = transform:Find("Container/panel_tips_big/bg_tween"):GetComponent("TweenPosition")
	tipsTABig = transform:Find("Container/panel_tips_big/bg_tween"):GetComponent("TweenAlpha")
	tipsWidgetBig = transform:Find("Container/panel_tips_big/bg_tween"):GetComponent("UIWidget")
	tipsTextBig = transform:Find("Container/panel_tips_big/bg_tween/text"):GetComponent("UILabel")
	tipsTitleBig = transform:Find("Container/panel_tips_big/bg_tween/title"):GetComponent("UILabel")
	tipsBtnBig = transform:Find("Container/panel_tips_big/bg_tween/btn_go")
	
	noticeRoot:SetActive(false)
	tipsTP:SetOnFinished(EventDelegate.Callback(function ()
        tipsTimeCounter = 0
        tipsCanCounter = true
    end))
    
    tipsTA:SetOnFinished(EventDelegate.Callback(function ()
        tipsTimeCounter = 0
        tipsNew = true
		if tipsTP ~= nil then
			tipsTP:ResetToBeginning()
		end
    end))
	
	tipsTPBig:SetOnFinished(EventDelegate.Callback(function ()
        tipsTimeCounter = 0
        tipsCanCounter = true
    end))
    
    tipsTABig:SetOnFinished(EventDelegate.Callback(function ()
        tipsTimeCounter = 0
        tipsNew = true
		if tipsTPBig ~= nil then
			tipsTPBig:ResetToBeginning()
		end
    end))
	
    noticeShowList = {}
end

function Start()
	local p = noticePanel:GetComponent("UIPanel")
	noticeLeft = - p.width / 2
	noticeRight = p.width / 2
	if NoticeData.noticeList == nil then
		NoticeData.noticeList = {}
	end
	if tipsList == nil then
		tipsList = {}
	end
end

local function MakeTips()
	if #tipsList > 0 then
		local tip = table.remove(tipsList, 1)
		tipsNew = false
		if tip.format == 1 then--small tip
			tipsWidget.alpha = 1
			tipsText.text = tip.str
			tipsTP:PlayForward(true)
		elseif tip.format == 2 then
			tipsWidgetBig.alpha = 1
			tipsTextBig.text = tip.str
			tipsTPBig:PlayForward(true)
			tipsTitleBig.text = TextMgr:GetText(tip.title)
			
			SetClickCallback(tipsBtnBig.gameObject, function()
				HideTips()
				Mail.DirectShow(tonumber(tip.value))
			end)
		end
		
		AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
	end
end

local function GetDataValue(tipdata , strID)
	for i=1  , #tipdata.paras , 1 do
		if tipdata.paras[i].paramType ~= nil and tipdata.paras[i].paramType == strID then
			return tipdata.paras[i].value
		end
	end
	return nil
end


function LateUpdate()
	if NoticeData.noticeList == nil then
		NoticeData.noticeList = {}
	end
	if #tempNoticeList > 0 and not encoding then
		encoding = true
		table.sort(tempNoticeList, function(a, b) return a.priority > b.priority end)
		MakeString(table.remove(tempNoticeList, 1), function(str)
			table.insert(NoticeData.noticeList, str)
			encoding = false
		end)
	end
	
	if tipsList == nil then
		tipsList = {}
	end
	if #tempTipsList > 0 and not encoding then
		encoding = true
		table.sort(tempTipsList, function(a, b) return a.priority > b.priority end)
		local tipdata =  table.remove(tempTipsList, 1)
		local value = GetDataValue(tipdata , "mailID")
		MakeString(tipdata, function(str)
			local tip = {}
			tip.str = str
			tip.format = tipdata.format
			tip.value = value
			tip.title = tipdata.title
			table.insert(tipsList, tip)
			encoding = false
		end)
	end
	
	if #noticeShowList > 0 then
		noticeRoot:SetActive(true)
	else
		noticeRoot:SetActive(false)
		MakeNotice()
	end
	for i, v in pairs(noticeShowList) do
		v:Move()
	end
	
	if tipsCanCounter then
		tipsTimeCounter = tipsTimeCounter + Time.deltaTime
		if #tipsList > 0 then
			if tipsTimeCounter >= tipsMinTime then
				HideTips()
			end
		else
			if tipsTimeCounter >= tipsMaxTime then
				HideTips()
			end
		end
	end
	if tipsNew then
		MakeTips()
	end
end

function OpenUI()
	if MainCityUI.gameObject == nil or MainCityUI.gameObject:Equals(nil) then
		return
	end
	if transform == nil or transform:Equals(nil) then
		Global.OpenTopUI(_M)
	end
end

function ShowNotice(notice)
	if notice.repeatcount ~= nil and notice.repeatcount > 1 then
		local tempstr = notice:SerializeToString()
		for i = 1, notice.repeatcount do
			local temp = ClientMsg_pb.MsgNoticeScrollPush()
			temp:ParseFromString(tempstr)
			table.insert(tempNoticeList, temp)
		end
	else
		table.insert(tempNoticeList, notice)
	end
	OpenUI()
end

function ShowTips(tips)
	--Global.DumpMessage(tips, "d:/dddd.lua")
	table.insert(tempTipsList, tips)
	OpenUI()
end

function GetConatiner()
	return transform:Find("Container")
end

function Close()
	tipsList = nil
	noticeRoot = nil
	noticePanel = nil
	noticeItem = nil
	tipsTP = nil
	tipsTA = nil
	tipsText = nil
	tipsWidget = nil
	noticeSpeedList = nil
	noticeLeft = nil
	noticeRight = nil
	noticeShowList = nil
	tipsWidgetBig = nil
	noticeBig = nil
	tipsTPBig = nil
	tipsTABig = nil
end

function Test()
	local MsgNoticeScrollPush =
	{
		content = "TipsNotice_War_Desc17",
		priority = 500,
		paras =
		{
			[1] = 
			{
				id = 10009,
				paramType = "monstername",
			},
			[2] = 
			{
				value = "x:109 y:10",
			},
			[3] = 
			{
				value = "123",
				paramType = "mailID",
			},
		},
		format = 2,
		title = "rank_ui11",
		tipId = 10700,
		tipType = 1,
	}
	
	local MsgNoticPush1 =
	{
		content = "TipsNotice_War_Desc17",
		priority = 500,
		paras =
		{
			[1] = 
			{
				id = 10009,
				paramType = "monstername",
			},
			[2] = 
			{
				value = "x:109 y:10",
			},
			[3] = 
			{
				value = "123",
				paramType = "mailID",
			},
		},
		format = 1,
		title = "rank_ui11",
		tipId = 10700,
		tipType = 1,
	}
	coroutine.start(function()
		ShowTips(MsgNoticeScrollPush)
		coroutine.wait(0.1)
		ShowTips(MsgNoticPush1)
	end)
	
end

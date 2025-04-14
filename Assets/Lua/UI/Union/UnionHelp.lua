module("UnionHelp", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local AudioMgr = Global.GAudioMgr

local _ui
local callback

function Hide()
    Global.CloseUI(_M)
    if callback ~= nil then
        callback()
        callback = nil
    end
end

function CloseAll()
    Hide()
end

--[[
optional uint32	charId	= 1;		// 盟有角色ID
	optional string	name	= 2;		// 盟有玩家名
	optional uint32 face 	= 3;		// 盟有头像
	optional uint32 position = 4;		// 盟有职级
	optional uint32	atkCharId	= 5;	// 攻击者角色ID
	optional string	atkName	= 6;		// 攻击者玩家名
	optional string atkGuildBanner = 7;	//攻击者guildBanner
	optional uint32 triggerTime	= 8;	// 触发时间
	optional uint32 endTime		= 9;	// 帮助结束时间
	repeated uint32 assistors = 10;		// 提供帮助的玩家Id
]]
function MakeMemHelpData(makeCount)
	local msg = GuildMsg_pb.MsgCompensateListResponse()
	msg.code = 0
	for i=1 , makeCount do
		local data = msg.compensateInfos:add()
		--local data = GuildMsg_pb.CompensateInfo()
		data.charId = 1000 + i
		data.face = 100
		data.name = "guildMem_rebot" .. i
		data.position = 1%15
		data.atkName = "attack_rebot"
		data.atkCharId = 30000
		data.atkGuildBanner = "auto"
		data.triggerTime = Serclimax.GameTime.GetSecTime()
		data.endTime = Serclimax.GameTime.GetSecTime() + 3600
		data.assistors:append(2000+i)
	end
	
	UnionHelpData.SetMemberHelpData(msg)
end

function MakeGiveCompensate(helpMsg)
	--产生push，重拉援助信息，然后更新ui
	local msg = GuildMsg_pb.MsgCompensateListResponse()
	msg.code = 0
	for i=1 , 1 do
		local data = msg.compensateInfos:add()
		--local data = GuildMsg_pb.CompensateInfo()
		data.charId = helpMsg.charId
		data.face = helpMsg.face
		data.name = helpMsg.name
		data.position = helpMsg.position
		data.atkName = helpMsg.atkName
		data.atkCharId = helpMsg.atkCharId
		data.atkGuildBanner = helpMsg.atkGuildBanner
		data.triggerTime = helpMsg.triggerTime
		data.endTime = helpMsg.endTime
		data.assistors:append(2000+i)
		data.assistors:append(MainData.GetCharId())
	end
	
	UnionHelpData.SetMemberHelpData(msg)
end

local function GetHelpName(helpMsg)
    local helpName
    if helpMsg.type == GuildMsg_pb.AccelAssistType_Build then
        helpName = TextMgr:GetText(TableMgr:GetBuildingData(helpMsg.desc).name)
    else
        helpName = TextMgr:GetText(TableMgr:GetTechDetailDataByIdLevel(helpMsg.desc, 1).Name)
    end
    return helpName
end

local function LoadHelp(help, helpMsg)
	if help.typeLabel ~= nil then
		local helpType = helpMsg.type
		if helpType == GuildMsg_pb.AccelAssistType_Build then
			help.typeLabel.text = TextMgr:GetText(Text.build_ui)
		else
			help.typeLabel.text = TextMgr:GetText(Text.science_ui)
		end
	end
	
    if help.faceTexture ~= nil then
        help.faceTexture.mainTexture = ResourceLibrary:GetIcon("Icon/head/", helpMsg.face)
    end
	
    if help.rankList ~= nil then
        for k, v in pairs(help.rankList) do
            v.gameObject:SetActive(k == helpMsg.position)
        end
    end
    if help.nameLabel ~= nil then
        help.nameLabel.text = helpMsg.name
    end
    local percent = 0
    if helpMsg.assistNumMax ~= nil and helpMsg.assistNumMax > 0 then
        percent = helpMsg.assistNum / helpMsg.assistNumMax
    end
	
	if help.countSlider ~= nil then
		help.countSlider.value = percent
	end
	
	if help.countLabel ~= nil then
		help.countLabel.text = string.format("%d/%d", helpMsg.assistNum, helpMsg.assistNumMax)
    end
	
	if help.checkTransform ~= nil then
        help.checkTransform.gameObject:SetActive(helpMsg.assistNumMax > 0 and helpMsg.assistNum == helpMsg.assistNumMax) 
    end
	
	if help.contentLabel ~= nil then 
		local helpName = GetHelpName(helpMsg)
		help.contentLabel.text = string.format("Lv.%d %s", helpMsg.assistLevel, helpName)
	end
	
	if help.memHelpDisc ~= nil then
		help.memHelpDisc.text = System.String.Format(TextMgr:GetText("Union_Support_ui3") , helpMsg.name --[[, helpMsg.atkGuildBanner ]], helpMsg.atkName)
	end
	
	if help.memHelpDisc1 ~= nil then
		help.memHelpDisc1.text = TextMgr:GetText("Union_Support_ui2")
	end
	
	if help.memHelpButton ~= nil then
		--help.memHelpButton = helpTransform:Find("help btn"):GetComponent("UIButton")
	end
end


function NeedShow(helpMsg)
	--援助目标是自己的话不显示
	if helpMsg.charId == MainData.GetCharId() then
		return false
	end
	
	--已经援助过的就不显示
	for i=1 , #helpMsg.assistors do
		if helpMsg.assistors[i] == MainData.GetCharId() then
			return false
		end
	end
	return true
end

function LoadUI()
    local unionHelpMsg = UnionHelpData.GetData()
    local unionInfoMsg = UnionInfoData.GetData()
	local unionMemHelpMsg = UnionHelpData.GetMemberHelpData()
	
    local unionMsg = unionInfoMsg.guildInfo
    local selfMemberMsg = unionInfoMsg.memberInfo
    local myListMsg = unionHelpMsg.myAccelAssistInfos

    _ui.faceTexture.mainTexture = ResourceLibrary:GetIcon("Icon/head/", selfMemberMsg.face)
    for k, v in pairs(_ui.rankList) do
        v.gameObject:SetActive(k == selfMemberMsg.position)
    end
    _ui.nameLabel.text = selfMemberMsg.name
    local coinData = UnionHelpData.GetDailyCoinCountData()
    _ui.coinLabel.text = string.format("%d/%d", coinData.countmax - coinData.count, coinData.countmax)
    local percent = 0
    if coinData.countmax > 0 then
        percent = (coinData.countmax - coinData.count) / coinData.countmax
    end
    _ui.coinSlider.value = percent
	
    for i, v in ipairs(myListMsg) do
        local help = _ui.helpList[i]
        help.transform.gameObject:SetActive(true)
        LoadHelp(help, v)
    end

    for i = #myListMsg + 1, 3 do
        _ui.helpList[i].transform.gameObject:SetActive(false)
    end

	while _ui.helpGrid.transform.childCount > 0 do
		 UnityEngine.GameObject.DestroyImmediate(_ui.helpGrid.transform:GetChild(0).gameObject)
	end
		
	--联盟援助
	local otherMemHelpListMsg = nil 
	if unionMemHelpMsg ~= nil then 
		otherMemHelpListMsg = unionMemHelpMsg.compensateInfos
	end 
	
	local oterMemListLength = 0
	if otherMemHelpListMsg ~= nil then
		for i, v in ipairs(otherMemHelpListMsg) do
			if NeedShow(v) then
				oterMemListLength = oterMemListLength + 1
				local helpTransform
				if _ui.helpGrid.transform.childCount < i then
					helpTransform = NGUITools.AddChild(_ui.helpGrid.gameObject, _ui.memHelpPrefab).transform
				else
					helpTransform = _ui.helpGrid:GetChild(i - 1)
				end
				
				local help = {}
				help.faceTexture = helpTransform:Find("headbg/icon"):GetComponent("UITexture")
				help.faceBg = helpTransform:Find("headbg").gameObject
				help.rankList = {}
				for ii = 1, 15 do
					help.rankList[ii] = helpTransform:Find(string.format("player name/rank%d", ii))
				end
				help.nameLabel = helpTransform:Find("player name"):GetComponent("UILabel")
				help.memHelpDisc = helpTransform:Find("text"):GetComponent("UILabel")
				help.memHelpDisc1 = helpTransform:Find("text (1)"):GetComponent("UILabel")
				help.memHelpButton = helpTransform:Find("help btn"):GetComponent("UIButton")
				LoadHelp(help, v)
				SetClickCallback(help.faceBg, function()
					OtherInfo.RequestShow(v.charId)
				end)
				
				SetClickCallback(help.memHelpButton.gameObject, function()
					--MakeGiveCompensate(v)
					local req = GuildMsg_pb.MsgGiveCompensateRequest()
					req.charId	= v.charId;
					req.triggerTime	= v.triggerTime;
					req.endTime		= v.endTime;
					
					Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGiveCompensateRequest, req, GuildMsg_pb.MsgGiveCompensateResponse, function(msg)
						if msg.code == ReturnCode_pb.Code_OK then
							--UnionHelpData.UpdateMemHelpData(msg)
							FloatText.Show(TextMgr:GetText(Text.union_help_friend), Color.green)
						else
							Global.ShowError(msg.code)
						end
					end, false)
					
				end)
				helpTransform.gameObject:SetActive(true)
			end
		end
	end

	print(oterMemListLength , _ui.helpGrid.transform.childCount)
    for i = oterMemListLength + 1, _ui.helpGrid.transform.childCount do
		print("=================")
		_ui.helpGrid:GetChild(i - 1).gameObject:SetActive(false)
    end
	
	--联盟帮助
    local otherListMsg = unionHelpMsg.accelAssistInfos
    for i, v in ipairs(otherListMsg) do
        local helpTransform
		print(_ui.helpGrid.transform.childCount , i , oterMemListLength, i + oterMemListLength)
        if _ui.helpGrid.transform.childCount < i + oterMemListLength then
            helpTransform = NGUITools.AddChild(_ui.helpGrid.gameObject, _ui.helpPrefab).transform
        else
            helpTransform = _ui.helpGrid:GetChild(i + oterMemListLength - 1)
        end
        local help = {}
        help.faceTexture = helpTransform:Find("headbg/icon"):GetComponent("UITexture")
        help.faceBg = helpTransform:Find("headbg").gameObject
        help.rankList = {}
        for ii = 1, 15 do
            help.rankList[ii] = helpTransform:Find(string.format("player name/rank%d", ii))
        end
        help.typeLabel = helpTransform:Find("coin bar/text"):GetComponent("UILabel")
        help.nameLabel = helpTransform:Find("player name"):GetComponent("UILabel")
        help.contentLabel = helpTransform:Find("text/Label"):GetComponent("UILabel")
        help.countSlider = helpTransform:Find("coin bar"):GetComponent("UISlider")
        help.countLabel = helpTransform:Find("coin bar/num"):GetComponent("UILabel")
        help.helpButton = helpTransform:Find("help btn"):GetComponent("UIButton")

        LoadHelp(help, v)

        SetClickCallback(help.faceBg, function()
            OtherInfo.RequestShow(v.charId)
        end)
        SetClickCallback(help.helpButton.gameObject, function()
            local req = GuildMsg_pb.MsgGiveAccelAssistRequest()
            req.charId = v.charId
            req.type = v.type
            req.relatedid = v.relatedId
            Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGiveAccelAssistRequest, req, GuildMsg_pb.MsgGiveAccelAssistResponse, function(msg)
                UnionHelpData.RequestData()
                if msg.code == ReturnCode_pb.Code_OK then
                    FloatText.Show(TextMgr:GetText(Text.union_help_friend), Color.green)
                else
                    Global.ShowError(msg.code)
                end
            end, false)
        end)
        helpTransform.gameObject:SetActive(true)
    end
    for i = #otherListMsg + oterMemListLength + 1, _ui.helpGrid.transform.childCount do
        _ui.helpGrid:GetChild(i - 1).gameObject:SetActive(false)
    end
    _ui.helpGrid:Reposition()
	
    if #otherListMsg + oterMemListLength == 0 then
    	_ui.emptyTransform.gameObject:SetActive(true)
    else
    	_ui.emptyTransform.gameObject:SetActive(false)
    end
	
    UIUtil.SetBtnEnable(_ui.helpButton ,"union_button1", "union_button1_un", #otherListMsg ~= 0)
end

function Awake()
    _ui = {}
    if _ui.helpPrefab == nil then
        _ui.helpPrefab = ResourceLibrary.GetUIPrefab("Union/listitem_unionHelp")
    end
	if _ui.memHelpPrefab == nil then
		_ui.memHelpPrefab = ResourceLibrary.GetUIPrefab("Union/listitem_unionSupport")
	end
	
    local mask = transform:Find("mask")
    local closeButton = transform:Find("bg/close btn")

    SetClickCallback(mask.gameObject, Hide)
    SetClickCallback(closeButton.gameObject, Hide)

    _ui.faceTexture = transform:Find("my widget/head bg/icon"):GetComponent("UITexture")
    _ui.rankList = {}
    for i = 1, 15 do
        _ui.rankList[i] = transform:Find(string.format("my widget/player name/rank%d", i))
    end
    _ui.nameLabel = transform:Find("my widget/player name"):GetComponent("UILabel")
    _ui.coinSlider = transform:Find("my widget/coin bar"):GetComponent("UISlider")
    _ui.coinLabel = transform:Find("my widget/coin bar/num"):GetComponent("UILabel")
    _ui.resetLabel = transform:Find("my widget/coin bar/time"):GetComponent("UILabel") 

    _ui.helpList = {}
    for i = 1, 3 do
        local help = {}
        help.transform = transform:Find(string.format("my widget/speed up bar%d", i))
        help.typeLabel = transform:Find(string.format("my widget/speed up bar%d/text", i)):GetComponent("UILabel")
        help.countSlider = transform:Find(string.format("my widget/speed up bar%d", i)):GetComponent("UISlider")
        help.countLabel = transform:Find(string.format("my widget/speed up bar%d/num", i)):GetComponent("UILabel")
        help.checkTransform = transform:Find(string.format("my widget/speed up bar%d/tick", i))
        help.contentLabel = transform:Find(string.format("my widget/speed up bar%d/Label", i)):GetComponent("UILabel")
        _ui.helpList[i] = help
    end

    _ui.helpScrollView = transform:Find("bg2/Scroll View"):GetComponent("UIScrollView")
    _ui.helpGrid = transform:Find("bg2/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.emptyTransform = transform:Find("bg2/no one")
    _ui.helpButton = transform:Find("ok btn"):GetComponent("UIButton")
    SetClickCallback(_ui.helpButton.gameObject, function()
		local unionHelpMsg = UnionHelpData.GetData().accelAssistInfos
    	--if _ui.emptyTransform.gameObject.activeInHierarchy or then
		if unionHelpMsg == nil or #unionHelpMsg == 0 then
    		AudioMgr:PlayUISfx("SFX_ui02", 1, false)
    		FloatText.Show(TextMgr:GetText("union_help05"), Color.white)
            if not GUIMgr:IsMenuOpen("UnionInfo") then
                Hide()
            end
    		return
    	end
        local req = GuildMsg_pb.MsgBatchGiveAccelAssistRequest()
        Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgBatchGiveAccelAssistRequest, req, GuildMsg_pb.MsgBatchGiveAccelAssistResponse, function(msg)
            UnionHelpData.RequestData()
            if msg.code == ReturnCode_pb.Code_OK then
                FloatText.Show(TextMgr:GetText(Text.union_help_friend), Color.green)
            	AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
            else
                Global.ShowError(msg.code)
            end
            if not GUIMgr:IsMenuOpen("UnionInfo") then
                Hide()
            end
        end)
    end)

    UnionHelpData.AddListener(LoadUI)
end

function Close()
    UnionHelpData.RemoveListener(LoadUI)
    _ui = nil
end

function Show(_callback)
    callback = _callback
    UnionHelpData.RequestData(function()
        Global.OpenUI(_M)
        LoadUI()
    end)
end

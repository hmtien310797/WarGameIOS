module("OtherInfo", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local SetTooltipCallback = UIUtil.SetTooltipCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime

local _ui

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end
local ChangeOfficial = nil
ChangeOfficial =function (officialId)
    _ui.infoMsg.userInfo.officialId = officialId
    GOV_Util.SetGovInfoUI4OtherInfo(_ui.gov,_ui.infoMsg.userInfo,ChangeOfficial)
end

function LoadUI()
    local infoMsg = _ui.infoMsg
    local userInfo = infoMsg.userInfo
    local statInfo = infoMsg.statInfo
    local equipInfo = infoMsg.wearEquipInfo
    SetClickCallback(_ui.copyButton.gameObject, function()
        FloatText.Show(TextMgr:GetText(Text.chat_hint12))
        NGUITools.clipboard = userInfo.name
    end)
    _ui.nameLabel.text = userInfo.name
    for i, v in ipairs(_ui.equipList) do
        local equipMsg = nil
        for __, vv in ipairs(equipInfo) do
            if vv.parent.pos == i then
                equipMsg = vv
                break
            end
        end

        v.bg:SetActive(equipMsg == nil)
        v.icon.gameObject:SetActive(equipMsg ~= nil)
        if equipMsg ~= nil then
            local itemData = TableMgr:GetItemData(equipMsg.baseid)
            local curData = EquipData.GetEquipDataByID(equipMsg.baseid)
            v.icon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
            v.qualitySprite.spriteName = "bg_item" .. itemData.quality
            v.level:SetActive(itemData.itemlevel > 0)
            v.level_label.text = itemData.itemlevel
            SetClickCallback(v.transform.gameObject,function()
                print("@@@",curData.BaseData.quality)
                Tooltip.ShowItemTip(curData , "otherEquipTips")   
            end)
        else
            v.level:SetActive(false)
            v.qualitySprite.spriteName = "bg_item_hui"
        end
    end

    _ui.faceTexture.mainTexture = ResourceLibrary:GetIcon("Icon/head/", userInfo.face)
    GOV_Util.SetFaceUI(_ui.faceMilitaryRank,userInfo.militaryRankId)
    _ui.levelLabel.text = String.Format(TextMgr:GetText(Text.Level_ui), userInfo.level)

	local expData = TableMgr:GetPlayerExpData(userInfo.level)
	_ui.expLabel.text = string.format("%d/%d", userInfo.exp, expData.playerExp)
	_ui.expSlider.value = userInfo.exp / expData.playerExp
	_ui.powerLabel.text = userInfo.pkvalue
    if userInfo.guildid ~= 0 then
        _ui.unionLabel.text = string.format("[%s]%s", userInfo.guildBanner, userInfo.guildName)
        SetClickCallback(_ui.unionButton.gameObject, function()
            UnionPubinfo.RequestShow(userInfo.guildid)
        end)
    else
        _ui.unionLabel.text = TextMgr:GetText(Text.union_nounion)
        SetClickCallback(_ui.unionButton.gameObject, function()
            FloatText.Show(TextMgr:GetText(Text.union_invite_text9))
        end)
    end
	_ui.killLabel.text = statInfo.killArmyNum

	SetClickCallback( _ui.priChatButton.gameObject , function()
		if ChatData.IsInBlackList(userInfo.charid) then
			FloatText.Show(TextMgr:GetText("setting_blacklist_ui15") , Color.red)
			return
		end
		
		if Global.GGUIMgr:FindMenu("Chat") == nil then
			Chat.SetPrivateChat(userInfo.name , userInfo.charid , userInfo.guildBanner , userInfo.officialId, userInfo.guildOfficialId)
			GUIMgr:CreateMenu("Chat", false)
		else
			Chat.PrivateChat(userInfo.name , userInfo.charid , userInfo.guildBanner , userInfo.officialId, userInfo.guildOfficialId)
		end
		CloseAll()
	end)

    _ui.inviteButton.isEnabled = UnionInfoData.GetGuildId() ~= 0
    SetClickCallback(_ui.inviteButton.gameObject, function()
        AllianceInvitesData.SendInvite(userInfo.charid)
    end)
	
	SetClickCallback(_ui.viewButtoon.gameObject, function()
	    OtherView.Show(statInfo)
    end)
	SetClickCallback(_ui.letterButton.gameObject, function()
        Mail.SimpleWriteTo(userInfo.name)
    end)
    _ui.gov = transform:Find("Container/bg_franenew/bg_gov")
    if _ui.gov ~= nil then
        GOV_Util.SetGovInfoUI4OtherInfo(_ui.gov,_ui.infoMsg.userInfo,ChangeOfficial)
    end
    
    _ui.nationalFlag.mainTexture = UIUtil.GetNationalFlagTexture(_ui.infoMsg.userInfo.nationality)

    local officialTransform = transform:Find("Container/bg_franenew/info/UnionOfficial")
    _ui.official = {}
    MainInformation.LoadOfficialObject(_ui.official, officialTransform)
    local guildOfficialId = userInfo.guildOfficialId
    MainInformation.LoadOfficial(_ui.official, guildOfficialId, userInfo.guildid, userInfo.guildBanner, userInfo.charid, userInfo.name)

    UpdateBlackListState()
    
    local data = {}
    data.info = infoMsg.mobaInfo
	if data.info.level == 0 then
		_ui.mobaicon.gameObject:SetActive(false)
		_ui.mobanone:SetActive(true)
	else
		_ui.mobaicon.gameObject:SetActive(true)
		_ui.mobanone:SetActive(false)
		local rankData = TableMgr:GetMobaRankDataByID(data.info.level)
		_ui.mobaicon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "Moba/", rankData.RankIcon)
		SetClickCallback(_ui.mobabtn, function()
			mobafile.Show(userInfo.charid, data)
		end)
	end

	for i, v in ipairs(infoMsg.arenainfo.hero) do
	    local heroData = tableData_tHero.data[v.baseid]
	    HeroList.LoadHero(_ui.heroList[i], v, heroData)
    end
    for i = #infoMsg.arenainfo.hero + 1, 5 do
        _ui.heroList[i].gameObject:SetActive(false)
    end
end

function Awake()
    local closeButton = transform:Find("Container/bg_franenew/btn_close")
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, CloseAll)
    _ui = {}
    print("awake:" , _ui)
    _ui.copyButton = transform:Find("Container/bg_franenew/mid/name"):GetComponent("UIButton")
    _ui.nameLabel = transform:Find("Container/bg_franenew/mid/name/Label"):GetComponent("UILabel")
    local equipList = {}
    for i = 1, 9 do
        local equip = {}
        local equipTransform = transform:Find(string.format("Container/bg_franenew/mid/equip0%d", i))
        equip.transform = equipTransform
        equip.qualitySprite = equipTransform:GetComponent("UISprite")
        equip.icon = equipTransform:Find("Texture"):GetComponent("UITexture")
        equip.bg = equipTransform:Find("lunku").gameObject
        equip.level = equipTransform:Find("level").gameObject
		equip.level_label = equipTransform:Find("level/num"):GetComponent("UILabel")
        equipList[i] = equip
    end
    _ui.equipList = equipList
    local i = 1,5 do 
    _ui.itemGrid =  transform:Find("Container/bg_franenew/info/bg_hero/Grid"):GetComponent("UIGrid")
    _ui.viewButtoon = transform:Find("Container/bg_franenew/bottom/button_left"):GetComponent("UIButton")
    _ui.faceTexture = transform:Find("Container/bg_franenew/mid/head/Texture"):GetComponent("UITexture")
    _ui.faceMilitaryRank = transform:Find("Container/bg_franenew/mid/head/MilitaryRank")
    _ui.expSlider = transform:Find("Container/bg_franenew/mid/addexp"):GetComponent("UISlider")
    _ui.expLabel = transform:Find("Container/bg_franenew/mid/addexp/jindu/Label"):GetComponent("UILabel")
    _ui.levelLabel = transform:Find("Container/bg_franenew/mid/addexp/level"):GetComponent("UILabel")
    _ui.powerLabel = transform:Find("Container/bg_franenew/info/combat/text"):GetComponent("UILabel")
    _ui.unionLabel = transform:Find("Container/bg_franenew/info/union/text"):GetComponent("UILabel")
    _ui.killLabel = transform:Find("Container/bg_franenew/info/damage/text"):GetComponent("UILabel")
    _ui.letterButton = transform:Find("Container/bg_franenew/bottom/button_mail"):GetComponent("UIButton")
    _ui.unionButton = transform:Find("Container/bg_franenew/bottom/button_union"):GetComponent("UIButton")
    _ui.priChatButton = transform:Find("Container/bg_franenew/bottom/button_chat"):GetComponent("UIButton")
    _ui.inviteButton = transform:Find("Container/bg_franenew/bottom/button_invite"):GetComponent("UIButton")
	

	_ui.midTransform = transform:Find("Container/bg_franenew/mid")
	local playerInstance = ResourceLibrary.GetUIInstance("PlayerInformation/Zhihuiguan")
	playerInstance.transform:SetParent(_ui.midTransform, false)
	local playerObject = transform:Find("Container/bg_franenew/mid/Zhihuiguan").gameObject
	local playerAnimation = transform:Find("Container/bg_franenew/mid/Zhihuiguan/Povit/Zhihuiguan_01"):GetComponent("Animation")
	local playerTransform = playerAnimation.transform
	SetClickCallback(playerObject, function()
	    playerAnimation:PlayQueued("idle0" .. math.random(3) + 1, UnityEngine.QueueMode.PlayNow)
	    playerAnimation:PlayQueued("idle01", UnityEngine.QueueMode.CompleteOthers)
    end)
	
	_ui.inBlackListButton = transform:Find("Container/bg_franenew/mid/btn_blacklist"):GetComponent("UIButton")
    _ui.outBlackListButton = transform:Find("Container/bg_franenew/mid/btn_blacklist_remove"):GetComponent("UIButton")
	
	
	SetClickCallback(_ui.inBlackListButton.gameObject, function()
	    
		ChatData.RequestOpBlackList(_ui.infoMsg.userInfo.charid,true,function()
			UpdateBlackListState()
			Chat.UpdateChatContentList()
		end,true)
		
    end)
	
	SetClickCallback(_ui.outBlackListButton.gameObject, function()
	    ChatData.RequestOpBlackList(_ui.infoMsg.userInfo.charid,false,function()
			UpdateBlackListState()
			Chat.UpdateChatContentList()
		end,true)
    end)
	
	
	UIUtil.SetDragCallback(playerObject, function(go, delta)
	    playerTransform:Rotate(0, -delta.x, 0)
    end)

    _ui.nationalFlag = transform:Find("Container/bg_franenew/mid/flag"):GetComponent("UITexture")

	_ui.mobaicon = transform:Find("Container/bg_franenew/info/moba/mobaicon"):GetComponent("UITexture")
	_ui.mobanone = transform:Find("Container/bg_franenew/info/moba/text").gameObject
    _ui.mobabtn = transform:Find("Container/bg_franenew/info/moba/mobaicon/btn").gameObject

    local heroGridTransform = transform:Find("Container/bg_franenew/info/bg_hero/Grid")
    local heroList = {}
    for i = 1, 5 do
        local hero = {}
        local heroTransform = heroGridTransform:GetChild(i - 1)
        HeroList.LoadHeroObject(hero, heroTransform)
        heroList[i] = hero
    end
    _ui.heroList = heroList
end
end

function UpdateBlackListState()
    if _ui == nil then 
		return 
	end 
	if ChatData.IsInBlackList(_ui.infoMsg.userInfo.charid) then 
		_ui.inBlackListButton.gameObject:SetActive(false)
		_ui.outBlackListButton.gameObject:SetActive(true)
	else
		_ui.inBlackListButton.gameObject:SetActive(false)
		_ui.outBlackListButton.gameObject:SetActive(false)
	end 
end

function Close()
    if GUIMgr:IsMenuOpen("MainInformation") then
        MainInformation.ShowFace3D()
    end
    _ui = nil
end

function Show(infoMsg)
    Global.OpenUI(_M)
    print("Show:" , _ui)
    _ui.infoMsg = infoMsg
    if GUIMgr:IsMenuOpen("MainInformation") then
	    MainInformation.HideFace3D()
    end
    LoadUI()
end

function RequestShow(charId , checkCallback)
	local req = ClientMsg_pb.MsgGetPlayerPublicInfoRequest()
	req.charId = charId
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGetPlayerPublicInfoRequest, req, ClientMsg_pb.MsgGetPlayerPublicInfoResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
			if checkCallback ~= nil then
				if checkCallback(msg) then
					Show(msg)
				end
			else
				Show(msg)
			end
        else
            Global.ShowError(msg.code)
        end
    end)
end

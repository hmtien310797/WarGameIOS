module("ChooseZone", package.seeall)

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
    login.gameObject:SetActive(true)
end

local function LoadZoneObject(zone, zoneTransform)
    zone.transform = zoneTransform
    zone.gameObject = zoneTransform.gameObject
    zone.languageIcon = zoneTransform:Find("bg_list/background/icon_country"):GetComponent("UITexture")
    zone.zoneLabel = zoneTransform:Find("bg_list/background/text_zoneID"):GetComponent("UILabel")
    zone.unionLabel = zoneTransform:Find("bg_list/background/text_union/text_name"):GetComponent("UILabel")
    zone.leaderLabel = zoneTransform:Find("bg_list/background/text_consul/text_name"):GetComponent("UILabel")
    zone.protectLabel = zoneTransform:Find("bg_list/background/text_protect/text_name"):GetComponent("UILabel")
    zone.recommendObject = zoneTransform:Find("bg_list/background/icon_new").gameObject
    zone.statusLabel = zoneTransform:Find("bg_list/background/text_zhuangtai"):GetComponent("UILabel")
    zone.selfObject = zoneTransform:Find("bg_list/background/icon_person").gameObject
end

local function LoadZone(zone, countryMsg, zoneGameMsg, zoneMsg)
    zone.gameObject:SetActive(true)
    zone.zoneLabel.text = String.Format(TextMgr:GetText(Text.ui_zone14), TextMgr:GetText(countryMsg.name), zoneMsg.zoneName)
    
	--Global.DumpMessage(zoneMsg , "d:/ffff.lua")
	
	local zoneInfo =  ServerListData.GetMyZoneData(zoneMsg.zoneId)
	
	if zoneGameMsg.guildid == 0 then
        zone.languageIcon.mainTexture = ResourceLibrary:GetIcon("Icon/Union/", "999")
        zone.unionLabel.text = TextMgr:GetText(Text.ui_zone12)
        zone.leaderLabel.text = TextMgr:GetText(Text.ui_zone12)
    else
        zone.languageIcon.mainTexture = ResourceLibrary:GetIcon("Icon/Union/", zoneGameMsg.guildlang)
        zone.unionLabel.text = string.format("[%s]%s", zoneGameMsg.guildbanner, zoneGameMsg.guildname)
        zone.leaderLabel.text = zoneGameMsg.officer
    end
	
	local charName = ''
	if zoneInfo ~=nil then
		charName = zoneInfo.charinfo.charname
	end 
	local pkvalue = 0
	if zoneInfo ~=nil then
		pkvalue = zoneInfo.charinfo.pkvalue
	end 
	zone.unionLabel.text = charName 
	zone.leaderLabel.text = pkvalue 
	
	
    if zoneGameMsg.time > 0 then
    else
        zone.protectLabel.text = TextMgr:GetText(Text.ui_zone13)
    end
    zone.recommendObject:SetActive(zoneMsg.isNew)
	zone.statusLabel.text, zone.statusLabel.color = login.GetStatusTextColor(zoneMsg.status)

    SetClickCallback(zone.gameObject, function()
        CloseAll()
        login.SetZoneInfo(countryMsg.name, zoneMsg.isNew, zoneMsg.status, zoneMsg.zoneId, zoneMsg.zoneName)
    end)
end

function LoadUI()
    for i = 2, #_ui.areaList do
        _ui.areaList[i].transform.gameObject:SetActive(ServerListData.HasCountryData(i - 1))
    end
    LoadMyArea()
end



function LoadMyArea()
    _ui.myZoneIdList = {}
    local myAreaMsg = ServerListData.GetMyAreaData()
    local zoneIndex = 1
    for i, v in ipairs(myAreaMsg) do
        for ii, vv in ipairs(v.zonelist) do
            local zoneTransform
            if _ui.listGrid.transform.childCount < zoneIndex then
                zoneTransform = NGUITools.AddChild(_ui.listGrid.gameObject, _ui.zonePrefab).transform
                zoneTransform.name = _ui.zonePrefab.name .. zoneIndex
            else
                zoneTransform = _ui.listGrid:GetChild(zoneIndex - 1)
            end
            local zone = {}
            LoadZoneObject(zone, zoneTransform)
            local countryMsg, _, zoneGameMsg = ServerListData.GetCountryZoneData(vv.zoneId)
            LoadZone(zone, countryMsg, zoneGameMsg, vv)
            _ui.myZoneIdList[vv.zoneId] = true
            zone.selfObject:SetActive(true)
            zoneIndex = zoneIndex + 1
        end
    end

    local allAreaMsg = ServerListData.GetAllAreaData()
    for i, v in ipairs(allAreaMsg) do
        for ii, vv in ipairs(v.zonelist) do
            if vv.isNew and _ui.myZoneIdList[vv.zoneId] == nil then
                local zoneTransform
                if _ui.listGrid.transform.childCount < zoneIndex then
                    zoneTransform = NGUITools.AddChild(_ui.listGrid.gameObject, _ui.zonePrefab).transform
                    zoneTransform.name = _ui.zonePrefab.name .. zoneIndex
                else
                    zoneTransform = _ui.listGrid:GetChild(zoneIndex - 1)
                end
                local zone = {}
                LoadZoneObject(zone, zoneTransform)
                local countryMsg, _, zoneGameMsg = ServerListData.GetCountryZoneData(vv.zoneId)
                LoadZone(zone, countryMsg, zoneGameMsg, vv)
                zone.selfObject:SetActive(false)
                zoneIndex = zoneIndex + 1
            end
        end
    end

    for i = zoneIndex, _ui.listGrid.transform.childCount do
        _ui.listGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end

    _ui.listGrid.repositionNow = true
    
    _ui.listScrollView:ResetPosition()
end


function sortZone(a, b)
	local a1=string.match(a.zoneMsg.zoneName,"S(%d+)")
	local b1=string.match(b.zoneMsg.zoneName,"S(%d+)") 
	if a1==nil then
		a1 = 99000
	end 
	
	if b1==nil then 
		b1 = 99000
	end 
	
	-- print(a.zoneMsg.zoneName,b.zoneMsg.zoneName,a1,b1,tonumber(a1) , tonumber(b1))
    return tonumber(a1) < tonumber(b1)
end

local function LoadArea(areaIndex)
    local zoneIndex = 1
    local countryMsg = ServerListData.GetAreaCountryData(areaIndex)
	
	local zoneList = {}
	
	if countryMsg ~= nil then
        for _, v in ipairs(countryMsg.data) do
            for i = #v.data, 1, -1 do
                local vv = v.data[i]
                local zoneMsg = ServerListData.GetAllZoneData(vv.zone)
                if zoneMsg ~= nil then
					local item ={}
					item.vv = vv
					item.zoneMsg = zoneMsg
                    table.insert(zoneList,item)
                end
            end
        end
    end
	
	table.sort(zoneList,sortZone)
	
	
	if countryMsg ~= nil then
        for _, v in ipairs(zoneList) do
            local zoneTransform
			if _ui.listGrid.transform.childCount < zoneIndex then
				zoneTransform = NGUITools.AddChild(_ui.listGrid.gameObject, _ui.zonePrefab).transform
				zoneTransform.name = _ui.zonePrefab.name .. zoneIndex
			else
				zoneTransform = _ui.listGrid:GetChild(zoneIndex - 1)
			end
			local zone = {}
			LoadZoneObject(zone, zoneTransform)
			LoadZone(zone, countryMsg, v.vv, v.zoneMsg)
			zone.selfObject:SetActive(_ui.myZoneIdList[v.zoneMsg.zoneId] ~= nil)
			zoneIndex = zoneIndex + 1
        end
    end
	
    for i = zoneIndex, _ui.listGrid.transform.childCount do
        _ui.listGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
    end

    _ui.listGrid.repositionNow = true
    _ui.listScrollView:ResetPosition()
end

function Awake()
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, CloseAll)
    _ui = {}
    _ui.zonePrefab = ResourceLibrary.GetUIPrefab("Login/ZoneInfo")
    _ui.listScrollView = transform:Find("Container/bg_frane/Scroll View"):GetComponent("UIScrollView")
    _ui.listGrid = transform:Find("Container/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
    
    local areaList = {}
    for i = 1, 7 do
        local areaTransform = transform:Find("Container/bg_frane/btn_region_" .. i)
        local area = {}
        area.transform = areaTransform
        area.toggle = areaTransform:GetComponent("UIToggle")
        EventDelegate.Add(area.toggle.onChange, EventDelegate.Callback(function()
            if area.toggle.value then
                if i == 1 then
                    LoadMyArea()
                else
                    LoadArea(i - 1)
                end
            end
        end))
        areaList[i] = area
    end
    _ui.areaList = areaList
end

function Close()
    _ui = nil
end

function Show()
    Global.OpenTopUI(_M)
    LoadUI()
end

module("FortHistory", package.seeall)

local GUIMgr = Global.GGUIMgr
local TextMgr = Global.GTextMgr

local subType = 0
local history

local ui

local isInViewport = false

local function LoadUI()
	if ui == nil then
		ui = {}

		UIUtil.SetClickCallback(transform:Find("mask").gameObject, function()
			Global.CloseUI(_M)
		end)

		UIUtil.SetClickCallback(transform:Find("bg_frane/bg_top/btn_close").gameObject, function()
			Global.CloseUI(_M)
		end)

		ui.newEntry = {}
		ui.newEntry.gameObject = transform:Find("bg_list").gameObject
		ui.newEntry.term = transform:Find("bg_list/top/number"):GetComponent("UILabel")
		ui.newEntry.fortName = transform:Find("bg_list/top/fort_name"):GetComponent("UILabel")
		ui.newEntry.leaderName = transform:Find("bg_list/name"):GetComponent("UILabel")
		ui.newEntry.date = transform:Find("bg_list/date"):GetComponent("UILabel")
		ui.newEntry.guildName = transform:Find("bg_list/union/union_name"):GetComponent("UILabel")
		ui.newEntry.damage = transform:Find("bg_list/damage/damage_number"):GetComponent("UILabel")
		ui.newEntry.damagePercentage = transform:Find("bg_list/damage01/damage_per"):GetComponent("UILabel")
		ui.newEntry.icon = transform:Find("bg_list/player/Texture"):GetComponent("UITexture")
		ui.newEntry.vipLevel = transform:Find("bg_list/player/vip_level"):GetComponent("UILabel")
		
		ui.entryList = transform:Find("bg_frane/bg/Scroll View/Grid").gameObject

		ui.tips = transform:Find("bg_frane/bg/none").gameObject
	end
end

local function SetUI()
	local guildNum = 0
	table.foreach(history, function(i, ownerGuild)
		if ownerGuild.guildId ~= nil and ownerGuild.guildId ~= 0 then
			ui.newEntry.term.text = System.String.Format(TextMgr:GetText("Duke_74"), #history - i + 1)
			ui.newEntry.fortName.text = TextMgr:GetText(string.format("Duke_%d", 14 + subType))
			ui.newEntry.leaderName.text = ownerGuild.leaderName
			ui.newEntry.date.text = System.String.Format(TextMgr:GetText("Duke_76"), Global.SecondToStringFormat(ownerGuild.ownTime , "yyyy-MM-dd HH:mm:ss"))
			ui.newEntry.guildName.text = string.format("[%s]%s", ownerGuild.guildBanner, ownerGuild.guildName)
			ui.newEntry.damage.text = Global.ExchangeValue(ownerGuild.hurt)
			ui.newEntry.damagePercentage.text = string.format("%.2f%%", ownerGuild.percent)
			ui.newEntry.icon.mainTexture = Global.GResourceLibrary:GetIcon("Icon/head/", ownerGuild.leaderFace)
			ui.newEntry.vipLevel.text = tostring(ownerGuild.leaderVipLevel)
			
			NGUITools.AddChild(ui.entryList, ui.newEntry.gameObject)

			guildNum = guildNum + 1
		end
	end)

	if guildNum ~= 0 then
		ui.tips:SetActive(false)
		ui.entryList.transform:GetComponent("UIGrid"):Reposition()
	else
		ui.tips:SetActive(true)
	end
end

local function Draw()
	LoadUI()
	SetUI()
end

function Show(_subType)
	if not isInViewport then
		subType = _subType

		FortsData.RequestFortHistoryData(subType, function(_history)
			history = _history

			Global.OpenUI(_M)
		end)

		return true
	end

	print(System.String.Format("[FortHistory.Show] The window is already in viewport"))
	return false
end

function Hide()
	if isInViewport then
		Global.CloseUI(_M)
	end
end

function Refresh()
	if isInViewport then
		FortsData.RequestFortHistoryData(subType, function(_history)
			history = _history

			Draw()
		end)
	end
end

function Start()
	isInViewport = true

	Draw()
end

function Close()
	isInViewport = false

	subType = 0
	history = nil

	ui = nil
end

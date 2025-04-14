module("UnionGuide",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local unionLeader
local mShowPage

local _ui

ShowPage = {
	UnionPage = 1,
	LeaderPage = 2,
	VipPage = 3,
}

local function GoMap()
	if mShowPage == ShowPage.UnionPage then
		local leader = unionLeader
		Hide()
		
		--[[if GUIMgr:FindMenu("UnionInfo") ~= nil then
			UnionInfo.Hide()
		end]]
		if not GUIMgr:IsMainCityUIOpen() then
			GUIMgr:ActiveMainCityUI()
		end
		
		MainCityUI.ShowWorldMap(leader.entryBaseData.pos.x, leader.entryBaseData.pos.y, true , function()
			Show(leader , ShowPage.LeaderPage)
		end)
	elseif mShowPage == ShowPage.VipPage then		
		Hide()
		store.Show()
	end
end

function LoadUI(showPage)
	if showPage == ShowPage.LeaderPage then
		_ui.lookBtn.gameObject:SetActive(false)
		_ui.text.text = System.String.Format(TextMgr:GetText("UnionGuide_ui2") ,unionLeader.name)
		_ui.knowBtn.transform.position = _ui.lookBtn.transform.position
	elseif showPage == ShowPage.UnionPage then
		_ui.text.text = System.String.Format(TextMgr:GetText("UnionGuide_ui1") ,UnionInfoData.GetData().guildInfo.banner ,UnionInfoData.GetData().guildInfo.name , unionLeader.name)
		_ui.lookBtn.gameObject:SetActive(true)	
	elseif showPage == ShowPage.VipPage then
		_ui.text.text = TextMgr:GetText("Vip_Experience_card_end")
	end
end



function LateUpdate()
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function Awake()
	_ui = {}
	_ui.closeBtn = transform:Find("Container/bg/bg_btn/btn_close"):GetComponent("UIButton")
	_ui.bg = transform:Find("Container")
	SetClickCallback(_ui.closeBtn.gameObject, Hide)
	SetClickCallback(_ui.bg.gameObject , Hide)
	
	_ui.lookBtn = transform:Find("Container/bg/bg_btn/btn_look"):GetComponent("UIButton")
	_ui.knowBtn = transform:Find("Container/bg/bg_btn/btn_know"):GetComponent("UIButton")
	SetClickCallback(_ui.lookBtn.gameObject , GoMap)
	SetClickCallback(_ui.knowBtn.gameObject , Hide)
	
	_ui.text = transform:Find("Container/bg/text_guide"):GetComponent("UILabel")
end


function Start()

end

function Close()
	_ui = nil
	unionLeader = nil
end

function Show(leaderInfo , showPage)
	unionLeader = leaderInfo
	mShowPage = showPage
	Global.OpenUI(_M)
	LoadUI(showPage)
end
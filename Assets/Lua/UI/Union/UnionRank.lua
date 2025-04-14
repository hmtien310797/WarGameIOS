module("UnionRank", package.seeall)
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
local String = System.String

local _ui
local _title
local _data

local function CloseSelf()
	Global.CloseUI(_M)
end

local function MakeScoreString(value)
	local s = tostring(value)
	local n = math.floor((#s - 1) / 3)
	for i = n, 1, -1 do
		s = string.sub(s, 0, -3 * i - 1) .. "," .. string.sub(s, -3 * i)
	end
	return s
end

local function UpdateRank(data)
	_ui.title.text = _title
	local myindex = 0
	local mycharid = MainData.GetCharId()
	for i, v in ipairs(data.rankList) do
		if v.charId == mycharid then
			myindex = v.rank
		end
	end
	endlesslist = EndlessList(_ui.scroll)
	endlesslist:SetItem(_ui.item, #data.rankList, function(prefab, index)
		local rankdata = data.rankList[index]
		prefab.transform:Find("no.1").gameObject:SetActive(index == 1)
		prefab.transform:Find("no.2").gameObject:SetActive(index == 2)
		prefab.transform:Find("no.3").gameObject:SetActive(index == 3)
		prefab.transform:Find("no.4").gameObject:SetActive(index >= 4)
		prefab.transform:Find("no.4"):GetComponent("UILabel").text = index
		prefab.transform:Find("name"):GetComponent("UILabel").text = rankdata.name
		prefab.transform:Find("number"):GetComponent("UILabel").text = MakeScoreString(rankdata.energy)
		local back = prefab.transform:Find("Sprite")
		back:GetComponent("UISprite").spriteName = "bg_list"
		if rankdata.charId == mycharid then
			back.gameObject:SetActive(true)
			back:GetComponent("UISprite").spriteName = "bg_list_select"
		elseif index % 2 == 0 then
			back.gameObject:SetActive(true)
		else
			back.gameObject:SetActive(false)
		end
	end)
	coroutine.start(function()
		coroutine.step()
		endlesslist:MoveTo(myindex)
	end)
end

function Awake()
	_ui = {}
	_ui.container = transform:Find("mask").gameObject
	_ui.btn_close = transform:Find("Container/base/top/close btn").gameObject
	_ui.title = transform:Find("Container/base/top/Label"):GetComponent("UILabel")
	_ui.scroll = transform:Find("Container/base/mid/Scroll View"):GetComponent("UIScrollView")
	_ui.item = transform:Find("Container/base/mid/Container")
end

function Start()
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	UpdateRank(_data)
end

function Close()
	_ui = nil
	_data = nil
end

function Show(data, title)
	_title = title == 1 and TextMgr:GetText("union_tec34") or (title == 2 and TextMgr:GetText("union_tec35") or "")
	_data = data
	Global.OpenUI(_M)
end

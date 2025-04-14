module("instructions", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback

local _container

local data

local function CloseSelf()
	Global.CloseUI(_M)
	_container = nil
end

function Awake()
	_container = {}
	_container.container = gameObject
	_container.btn_close = transform:Find("bg_top/btn_close").gameObject
	_container.title = transform:Find("bg_top/Label"):GetComponent("UILabel")
	_container.texture = transform:Find("bg_frane/Texture"):GetComponent("UITexture")
	_container.texture_bg = transform:Find("bg_frane/Texture01"):GetComponent("UITexture")
	_container.info_label = transform:Find("bg_frane/mid/Label"):GetComponent("UILabel")
	_container.grid = transform:Find("bg_frane/bg/Scroll View/Grid"):GetComponent("UIGrid")
	_container.table = transform:Find("bg_frane/bg/Scroll View/Table"):GetComponent("UITable")
	_container.text_item = transform:Find("text").gameObject
end

function Start()
	SetClickCallback(_container.container, CloseSelf)
	SetClickCallback(_container.btn_close, CloseSelf)
	_container.title.text = TextMgr:GetText(data.title)
	_container.texture.mainTexture = ResourceLibrary:GetIcon(data.icon, "")
	_container.texture_bg.mainTexture = ResourceLibrary:GetIcon(data.iconbg, "")
	_container.info_label.text = TextMgr:GetText(data.text)
	for i, v in ipairs(data.infos) do
		local item = NGUITools.AddChild(_container.table.gameObject, _container.text_item).transform
		item:Find("number"):GetComponent("UILabel").text = "" .. i .. "."
		item:Find("Label1 (1)"):GetComponent("UILabel").text = TextMgr:GetText(v)
		if i % 2 == 0 then
			item:Find("base").gameObject:SetActive(false)
		end
	end
	_container.table:Reposition()
end

function Show(_data)
	data = _data
	Global.OpenUI(_M)
end
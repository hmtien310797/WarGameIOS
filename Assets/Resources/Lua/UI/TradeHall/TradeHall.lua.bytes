module("TradeHall", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback

local _container
local _btn_close
local _bg_noitem
local _scrollview
local _grid
local _infoitem
local selfdata
local _ui

OnCloseCB = nil

function GetSelfData()
	return selfdata
end

local function CloseSelf()
	Global.CloseUI(_M)
end

local function MakeItem(index, data)
	local item = NGUITools.AddChild(_grid.gameObject, _infoitem.gameObject)
	local icon = item.transform:Find("bg_touxiang/icon_touxiang"):GetComponent("UITexture")
	local name = item.transform:Find("name"):GetComponent("UILabel")
	local zhanli = item.transform:Find("text/num"):GetComponent("UILabel")
	local btn = item.transform:Find("btn_trade").gameObject
	local iconlevel = item.transform:Find("icon_level"):GetComponent("UISprite")
	local line = item.transform:Find("bg").gameObject
	--if index%2 ~= 0 then
	--	line:SetActive(false)
	--else
		line:SetActive(true)
    --end		
	icon.mainTexture = ResourceLibrary:GetIcon("Icon/head/", data.face)
	name.text = data.name
	zhanli.text = Global.FormatNumber(data.pkValue)
	iconlevel.spriteName = "level_" .. data.position
	if data.charId == MainData.GetCharId() then
		selfdata = data
		btn:SetActive(false)
	end
	SetClickCallback(btn, function()
		local req = ClientMsg_pb.MsgCheckPlayerSomeRequest()
		req.charid = data.charId
		req.checktype = 1
		Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCheckPlayerSomeRequest, req, ClientMsg_pb.MsgCheckPlayerSomeResponse, function(msg)
			if msg.code == ReturnCode_pb.Code_OK then
				if msg.value > 0 then
					Trade.Show(data.entryBaseData.uid, data.entryBaseData.pos.x, data.entryBaseData.pos.y, selfdata.entryBaseData.pos.x, selfdata.entryBaseData.pos.y)
				else
					MessageBox.Show(TextMgr:GetText("TradeHall_ui12"))
				end
			else
				Global.ShowError(msg.code)
			end
		end, false)
	end)
	
	local memHead = item.transform:Find("bg_touxiang")
	SetClickCallback(memHead.gameObject , function()
		if data.charId ~= MainData.GetCharId() then
			OtherInfo.RequestShow(data.charId)
		end
	end)
end

function Awake()
	_ui = {}
	_container = transform:Find("Container").gameObject
	_btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	SetClickCallback(_container, CloseSelf)
	SetClickCallback(_btn_close, CloseSelf)
	_scrollview = transform:Find("Container/bg_frane/bg_mid/Scroll View"):GetComponent("UIScrollView")
	_grid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	_bg_noitem = transform:Find("Container/bg_frane/bg_mid/bg_noitem").gameObject
	SetClickCallback(_bg_noitem.transform:Find("btn").gameObject, function() JoinUnion.Show() CloseSelf() end)
	_infoitem = transform:Find("TradeHallinfo")
	_bg_noitem:SetActive(false)
end

function Start()
	local req = GuildMsg_pb.MsgSeeMyGuildRequest()
	Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgSeeMyGuildRequest, req, GuildMsg_pb.MsgSeeMyGuildResponse, function(msg)
		if _ui == nil then
			return
		end
        if msg.code == ReturnCode_pb.Code_OK then
            local req = GuildMsg_pb.MsgGuildMemberListRequest()
		    req.guildId = msg.guildInfo.guildId
			Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildMemberListRequest, req, GuildMsg_pb.MsgGuildMemberListResponse, function(msg)
				if _ui == nil then
					return
				end
		        if msg.code == ReturnCode_pb.Code_OK then
		            memberMsg = msg.members
		            table.sort(memberMsg, function(a, b) return a.name < b.name end)
		            for i, v in ipairs(memberMsg) do
		            	MakeItem(i, v)
		            end
		            _grid:Reposition()
		            _scrollview:ResetPosition()
		        else
		        	_bg_noitem:SetActive(true)
		        end
		    end, true)
		else
			_bg_noitem:SetActive(true)
        end
    end, true)
end

function Close()
	if OnCloseCB ~= nil then
    	OnCloseCB()
    	OnCloseCB = nil
    end
    _container = nil
	_btn_close = nil
	_bg_noitem = nil
	_scrollview = nil
	_grid = nil
	_infoitem = nil
	selfdata = nil
	_ui = nil
end

function Show()
	Global.OpenUI(_M)
end

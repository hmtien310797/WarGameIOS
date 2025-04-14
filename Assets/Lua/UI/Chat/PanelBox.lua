module("PanelBox", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback
local GameObject = UnityEngine.GameObject
local Screen = UnityEngine.Screen
local _container

function Show(chatinfo)
	Global.OpenUI(_M)
	LoadUI(chatinfo)
	
	-- transform.localPosition = Vector3(UICamera.lastEventPosition.x-460,UICamera.lastEventPosition.y -430,0);
	Reposition()
end

function ClampWidgetPosition( position)
	local gameObject = transform.gameObject

	local size = Vector2(100,300)
	local uiCamera = NGUITools.FindCameraForLayer(gameObject.layer)

	if uiCamera ~= nil then
		position.x = Mathf.Clamp01(position.x / Screen.width)
		position.y = Mathf.Clamp01(position.y / Screen.height)
		
		local activeSize = uiCamera.orthographicSize / transform.parent.lossyScale.y
		local ratio = (Screen.height * 0.5) / activeSize

		local max = Vector2(ratio * size.x / Screen.width, ratio * size.y / Screen.height)

		position.x = Mathf.Min(position.x, 1 - max.x)
		position.y = Mathf.Max(position.y, max.y)

		transform.position = uiCamera:ViewportToWorldPoint(position)
		position = transform.localPosition
		position.x = Mathf.Round(position.x) + 120
		position.y = Mathf.Round(position.y) - 190
		transform.localPosition = position
	else
		if position.x + size.x > Screen.width then
			position.x = Screen.width - size.x
		end
		if position.y - size.y < 0 then
			position.y = size.y
		end
		
		position.x = position.x - Screen.width * 0.5 + 120
		position.y = position.y - Screen.height * 0.5- 190
	end
	
	transform.localPosition = position
	transform.localSize = size
end

function Reposition()
	ClampWidgetPosition(UICamera.lastEventPosition)
end


function Hide()
	Global.CloseUI(_M)
end

function LoadUI(chatinfo)

	print("report "..chatinfo.id.." "..chatinfo.name.." text="..chatinfo.text);
	
	_ui = {}
	_ui.Mask = transform:Find("mask").gameObject
	SetClickCallback(_ui.Mask, function()
		Hide()
	end)
	
	_ui.DetailWidget = transform:Find("bg_box"):GetComponent("UIWidget")
	_ui.DetailLook = transform:Find("bg_box/btn_look").gameObject
	_ui.DetailMail = transform:Find("bg_box/btn_mail").gameObject
	_ui.DetailDisabled = transform:Find("bg_box/btn_pingbi").gameObject
	_ui.DetailCopy = transform:Find("bg_box/btn_copy").gameObject
	_ui.DetailBlackList = transform:Find("bg_box/btn_blacklist").gameObject
	_ui.DetailBlackListText = transform:Find("bg_box/btn_blacklist/text"):GetComponent("UILabel")
	local LabelCount = transform:Find("bg_box/btn_pingbi/text"):GetComponent("UILabel");
	transform:Find("bg_box/btn_pingbi/text"):GetComponent("LocalizeEx").enable = false;

	SetClickCallback(_ui.DetailLook, function()
		OtherInfo.RequestShow(chatinfo.id , nil , true)
		Hide()
	end)
	
	SetClickCallback(_ui.DetailBlackList, function()
		
		if ChatData.IsInBlackList(chatinfo.id) then 
			ChatData.RequestOpBlackList(chatinfo.id,false,function()
				Chat.UpdateChatContentList()
			end,true)
		else 
			ChatData.RequestOpBlackList(chatinfo.id,true,function()
				Chat.UpdateChatContentList()
			end,true)
		end 
		
		Hide()
	end)
	
	SetClickCallback(_ui.DetailMail, function()
		Mail.SimpleWriteTo(chatinfo.name)
		Hide()
	end)
	
	SetClickCallback(_ui.DetailCopy, function()
		FloatText.Show(chatinfo.name)
        NGUITools.clipboard = chatinfo.name
		Hide()
	end)

	SetClickCallback(_ui.DetailDisabled , function()
		RequestChatReport(chatinfo.id,chatinfo.kind,chatinfo.text);
		Hide()
	end)

	local reportCount = CountListData.GetReportCount();
	LabelCount.text = TextMgr:GetText("chat_report").."("..reportCount..")";

	if ChatData.IsInBlackList(chatinfo.id) then 
		_ui.DetailBlackListText.text = TextMgr:GetText("setting_blacklist_ui12")
	else 
	
		_ui.DetailBlackListText.text = TextMgr:GetText("setting_blacklist_ui11")
	end 
end


function RequestChatReport(charId , kind, text , callback)
    local reportCount = CountListData.GetReportCount()
	if text ==nil then 
		text ="";
	end
    print("report "..charId.." ".." text="..text);
	
   
	local req = ChatMsg_pb.MsgChatTipoffRequest()
	req.to_charid = charId;
	req.kind = kind;
	req.text = text;

	Global.Request(Category_pb.Chat, ChatMsg_pb.ChatTypeId.MsgChatTipoffRequest, req, ChatMsg_pb.MsgChatTipoffResponse, function(msg)		

		-- Global.DumpMessage(msg , "d:/chatreport.lua")
        if tonumber(msg.code) == 5525 then
			-- 日举报次数已用完
		    FloatText.Show(TextMgr:GetText("chat_report_ui2") , Color.red)
		else
			CountListData.RequestData()
			-- 已接受您的举报，我们会对举报信息进行核实
			MessageBox.Show(TextMgr:GetText("chat_report_ui1") , function() return false end)
			if callback ~= nil then
				callback()
			end
		end
	end, true)
end

function Awake()
	
end
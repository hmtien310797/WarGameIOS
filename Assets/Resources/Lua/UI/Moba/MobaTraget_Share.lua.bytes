module("MobaTraget_Share", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local Traget_ShareUI = nil

local name

local x

local y

local icon

local chanel = {
    [1] = ChatMsg_pb.chanel_MobaWorld,
    [2] = ChatMsg_pb.chanel_MobaTeam,
    [3] = ChatMsg_pb.chanel_MobaPrivate,
    [4] = ChatMsg_pb.chanel_MobaPrivate,
}

local guildmoba_chanel = {
    [1] = ChatMsg_pb.chanel_GuildMobaWorld,
    [2] = ChatMsg_pb.chanel_GuildMobaTeam,
    [3] = ChatMsg_pb.chanel_GuildMobaWorld,
    [4] = ChatMsg_pb.chanel_GuildMobaWorld,
}


local interface={
    ["channel"] = chanel,
    ["Chat"] = MobaChat,
	["ChatClass"] = "MobaChat",
}

local interface_guild={
    ["channel"] = guildmoba_chanel,
    ["Chat"] = GuildMobaChat,
    ["ChatClass"] = "GuildMobaChat",
}

local function GetInterface(interface_name)
    if Global.GetMobaMode() == 1 then
        return interface[interface_name]
    elseif Global.GetMobaMode() == 2 then
        return interface_guild[interface_name]
    end
    
end

function TestSend()
	local hasUnion = nil
	local send = {}
	send.curChanel = chanel[1]
	send.content = "chat_coordinate"
	send.spectext = 100 .. "," .. 100 .. "," .. "" .. "," .. "这是一条做表测试信息"..",".."name:小婊扎"
	send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
	send.chatType = 2
	send.senderguildname =  ""

	MobaChat.SendContent(send)  
	FloatText.Show(TextMgr:GetText("ui_worldmap_83") , Color.green)
	Hide()
end

local function LoadUI()
    Traget_ShareUI = {}

    Traget_ShareUI.name = transform:Find("frame/bg_mid/name"):GetComponent("UILabel")
    Traget_ShareUI.name.text = name
    Traget_ShareUI.close = transform:Find("frame/bg_top/btn_close").gameObject
    SetClickCallback(Traget_ShareUI.close,function()
        Hide()
    end)
	Traget_ShareUI.close = transform:Find("mask").gameObject
    SetClickCallback(Traget_ShareUI.close,function()
        Hide()
    end)
	
    Traget_ShareUI.coord = transform:Find("frame/bg_mid/bg_coordinate/text_coord"):GetComponent("UILabel")
    Traget_ShareUI.coord.text = String.Format(TextMgr:GetText("ui_worldmap_77"),1,  x, y)
    Traget_ShareUI.des = transform:Find("frame/bg_mid/frame_input"):GetComponent("UIInput")
    Traget_ShareUI.btn ={}
    for i =1,4,1 do
        Traget_ShareUI.btn[i] =  transform:Find("frame/btn_4/btn_"..i).gameObject
        SetClickCallback(Traget_ShareUI.btn[i],function()
            local send = {}
            send.curChanel = GetInterface("channel")[i]
            send.content = "chat_coordinate"
            print(x , y , icon , Traget_ShareUI.des.value,name)
		    send.spectext = x .. "," .. y .. "," .. icon .. "," .. Traget_ShareUI.des.value..","..name
            send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
            send.chatType = 2
			send.senderguildname = hasUnion and UnionInfoData.GetData().guildInfo.banner or ""
            
			
			if i == 4 then
				GetInterface("Chat").SetPrivateShare(send)
				GUIMgr:CreateMenu(GetInterface("ChatClass"), false)
			else
				GetInterface("Chat").SendContent(send)  
				FloatText.Show(TextMgr:GetText("ui_worldmap_83") , Color.green)
			end
			
			Hide()
         end)
    end
    
	transform:Find("frame/btn_4/btn_4").gameObject:SetActive(false)
	transform:Find("frame/btn_4/btn_1/txt_3"):GetComponent("LocalizeEx").enabled = false
	transform:Find("frame/btn_4/btn_1/txt_3"):GetComponent("UILabel").text =  TextMgr:GetText("ui_moba_72")
   
    transform:Find("frame/btn_4/btn_2/txt_3"):GetComponent("LocalizeEx").enabled = false
	transform:Find("frame/btn_4/btn_2/txt_3"):GetComponent("UILabel").text =  TextMgr:GetText("ui_moba_71")
   
end

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end


function Awake()
    LoadUI()
end

function Close()
    name = nil
    x = nil
    y = nil
    icon = nil    
    Traget_ShareUI = nil
end


function Show(_name,_icon,_x,_y)
    name = _name
    x = _x
    y = _y
    icon = _icon
    if name == nil or x == nil or y == nil then
        return
    end

    Global.OpenUI(_M)    
end






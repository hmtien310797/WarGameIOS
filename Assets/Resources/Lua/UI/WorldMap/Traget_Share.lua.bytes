module("Traget_Share", package.seeall)

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
    [1] = ChatMsg_pb.chanel_world,
    [2] = ChatMsg_pb.chanel_guild,
    [3] = ChatMsg_pb.chanel_system,
    [4] = ChatMsg_pb.chanel_private,
}
 
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
			local hasUnion = UnionInfoData.HasUnion()
            if i == 2 and not hasUnion then
                MessageBox.Show(TextMgr:GetText("union_cant_speak"))
                return 
            end
			
            local send = {}
            send.curChanel = chanel[i]
            send.content = "chat_coordinate"
            print(x , y , icon , Traget_ShareUI.des.value,name)
		    send.spectext = x .. "," .. y .. "," .. icon .. "," .. Traget_ShareUI.des.value..","..name
            send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
            send.chatType = 2
			send.senderguildname = hasUnion and UnionInfoData.GetData().guildInfo.banner or ""
            
			
			if i == 4 then
				Chat.SetPrivateShare(send)
				GUIMgr:CreateMenu("Chat", false)
			else
				Chat.SendContent(send)  
				FloatText.Show(TextMgr:GetText("ui_worldmap_83") , Color.green)
			end
			
			Hide()
         end)
    end
	
	transform:Find("frame/btn_4/btn_4").gameObject:SetActive(true)

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






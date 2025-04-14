module("Traget_Set", package.seeall)

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

local Traget_SetUI
local Type
local mapx
local mapy
local DName
local enable_length = false
local first = false
local function LoadUI()
    first = false
    enable_length = false
    Traget_SetUI = {}
    SetClickCallback(transform:Find("mask").gameObject,function()
        Hide()
    end)

    Type = 3
    SetClickCallback(transform:Find("frame/bg_top/btn_close").gameObject,Hide)
    Traget_SetUI.uit = {}
    for i =1,4,1 do
        Traget_SetUI.uit[i] = transform:Find("frame/bg_mid/bg_icon/icon"..i):GetComponent("UIToggle")
        if i == 3 then
            Traget_SetUI.uit[i].value = true
        else
            Traget_SetUI.uit[i].value = false
        end
        SetClickCallback(transform:Find("frame/bg_mid/bg_icon/icon"..i).gameObject,function()
            if Type == i then
              Traget_SetUI.uit[i].value = true  
            end
            Type = i
        end)
    end
    Traget_SetUI.coord = transform:Find("frame/bg_mid/bg_coordinate/text_coord"):GetComponent("UILabel")

    Traget_SetUI.coord.text = String.Format(TextMgr:GetText("ui_worldmap_77"),1,  mapx, mapy)

    Traget_SetUI.inputText = transform:Find("frame/bg_mid/frame_input/title"):GetComponent("UILabel")

    Traget_SetUI.input = transform:Find("frame/bg_mid/frame_input"):GetComponent("UIInput")



    Traget_SetUI.inputText.text = DName

    EventDelegate.Add(Traget_SetUI.input.onChange, EventDelegate.Callback(function()
        enable_length = true
    end))    
  
    SetClickCallback(transform:Find("frame/btn ok").gameObject,function()
        local name = Traget_SetUI.inputText.text
        if enable_length then
            local name_len = Global.utfstrlen(name)
            if name_len == 0 then
                FloatText.Show(TextMgr:GetText("Target_ui10"),Color.white)
                return
            end
            if name_len > 12 then
                FloatText.Show(TextMgr:GetText("Target_ui10"),Color.white)
                return 
            end
        end

        if TragetViewData.HasTraget(mapx,mapy) then
            MessageBox.Show(TextMgr:GetText("Target_ui9"), function()
                TragetViewData.RequestAddTraget(Type,name,mapx,mapy,function(success)
                    if success then
                        Hide()
                    end
                end)
            end,
            function()
            end)
        else
            TragetViewData.RequestAddTraget(Type,name,mapx,mapy,function(success)
                if success then
                    FloatText.Show(TextMgr:GetText("Target_ui11"),Color.white)
                    Hide()
                end
            end)
        end

    end)
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
    Traget_SetUI = nil
end


function Show(name,x,y)
    mapx = x
    mapy = y
    DName = name
    Global.OpenUI(_M)    
end






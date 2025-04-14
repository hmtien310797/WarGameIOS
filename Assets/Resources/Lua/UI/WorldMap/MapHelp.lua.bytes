module("MapHelp", package.seeall)

local ui = {}
local Gid = 0
local PlayerPrefs = UnityEngine.PlayerPrefs
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local CallBack
local LeftClick = true
local RightClick = true

local function FindData()
	local data = nil
    for _ , v in pairs(tableData_tMapHelp.data) do
		if v.id == Gid then
			data = v
			break
		end
	end
    return data
end

local function LoadUI()
    ui.Data = FindData()
    if ui.Data.type == 2 then        
        ui.ButtonLeftText.text = TextMgr:GetText("WorldmapHelp_Title20")
        
        ui.ButtonMid.gameObject:SetActive(false)
        ui.ButtonRight.gameObject:SetActive(true)
        if ui.Data.first == 0 then
            LeftClick = false
            ui.ButtonLeft.gameObject:SetActive(false)
        else
            LeftClick = true
            ui.ButtonLeft.gameObject:SetActive(true)
        end
        if ui.Data.next == 0 then
            RightClick = false
            ui.ButtonRightText.text = TextMgr:GetText("WorldmapHelp_Title22")
        else
            RightClick = true
            ui.ButtonRightText.text = TextMgr:GetText("WorldmapHelp_Title21")
        end
    else
        ui.ButtonMidText.text = TextMgr:GetText("WorldmapHelp_Title22")
        ui.ButtonMid.gameObject:SetActive(true)
        ui.ButtonLeft.gameObject:SetActive(false)
        ui.ButtonRight.gameObject:SetActive(false)
    end

    ui.Content.text = TextMgr:GetText(ui.Data.content)
    ui.Title.text = TextMgr:GetText(ui.Data.title)
    ui.Image.mainTexture = ResourceLibrary:GetIcon("Help/", ui.Data.imageUrl)

    if ui.ImageLabel ~= nil then
        ui.ImageLabel.gameObject:SetActive(false)
    end
    ui.ImageLabel = transform:Find("Container/bg_frane/bg_help_"..Gid)
    if ui.ImageLabel ~= nil then
        ui.ImageLabel.gameObject:SetActive(true)
    end
end

local function MidClickCallback(go)
    Global.CloseUI(_M)
end 

local function LeftClickCallback(go)
    if LeftClick == false then
        return
    end
    Gid = ui.Data.first
    ui.Data = FindData()
    LoadUI()
end 

local function RightClickCallback(go)
    if RightClick == false then
        Global.CloseUI(_M)
        return
    end
    Gid = ui.Data.next
    ui.Data = FindData()
    LoadUI()
end 

local function CloseClickCallback(go)
    Global.CloseUI(_M)
end

function  Awake()
    ui.Transform = transform
    ui.Mask = transform:Find("Container")
    ui.Title = transform:Find("Container/bg_frane/bg_top/title/text (1)"):GetComponent("UILabel")
    ui.Image = transform:Find("Container/bg_frane/Texture"):GetComponent("UITexture")
    ui.Content = transform:Find("Container/bg_frane/bg_desc/Scroll View/text_desc"):GetComponent("UILabel")
    ui.ButtonMid = transform:Find("Container/bg_frane/bg_bottom/btn_mid")
    ui.ButtonMidText = transform:Find("Container/bg_frane/bg_bottom/btn_mid/text"):GetComponent("UILabel")
    ui.ButtonLeft = transform:Find("Container/bg_frane/bg_bottom/btn_left")
    ui.ButtonLeftText = transform:Find("Container/bg_frane/bg_bottom/btn_left/text"):GetComponent("UILabel")
    ui.ButtonLeftBg = ui.ButtonLeft:GetComponent("UISprite")
    ui.ButtonLeftBtn = ui.ButtonLeft:GetComponent("UIButton")
    ui.ButtonRight = transform:Find("Container/bg_frane/bg_bottom/btn_right")
    ui.ButtonRightText = transform:Find("Container/bg_frane/bg_bottom/btn_right/text"):GetComponent("UILabel")
    ui.ButtonRightBg = ui.ButtonRight:GetComponent("UISprite")
    ui.ButtonRightBtn = ui.ButtonRight:GetComponent("UIButton")
    ui.Close = transform:Find("Container/bg_frane/bg_top/btn_close")

    UIUtil.SetClickCallback(ui.ButtonMid.gameObject, MidClickCallback)
    UIUtil.SetClickCallback(ui.ButtonLeft.gameObject, LeftClickCallback)
    UIUtil.SetClickCallback(ui.ButtonRight.gameObject, RightClickCallback)
    UIUtil.SetClickCallback(ui.Close.gameObject, CloseClickCallback)
    UIUtil.SetClickCallback(ui.Mask.gameObject, CloseClickCallback)

    LoadUI()
end

function CheckHelp(gid)
    local isHelp = false
    local cGid = -1
    if gid == 0 then
        cGid = 410
    elseif gid == 100 then
        cGid = 600
    elseif gid == 102 or gid == 103 or gid == 104 or gid == 105 or gid == 106 then
        cGid = 500
    elseif gid == 700 or gid == 701 or gid == 702 or gid == 703 or gid == 704 or gid == 705 then
        cGid = 200
    elseif gid == 101 then
        cGid = 130
    elseif gid == 107 then
        cGid = 100
    elseif gid == 108 then
        cGid = 110
    elseif gid == 109 then
        cGid = 120    
    elseif gid == 203 then
        cGid = 300    
    elseif gid == 400 then
        cGid = 1800
    elseif gid == 302 then
        cGid = 1900
    elseif gid == 201 then
        cGid = 2000
    end		
    
    if cGid > -1 then
        isHelp = true
    end
    return isHelp
end

function Open(gid, isGid, callBack, isCallBack, force)
    CallBack = callBack
    if ActivityGrow.IsInGuide() == true then
        if CallBack ~= nil then
            CallBack() 
        end
        return
    end
    Gid = 0
    if isGid then
        if gid == 0 then
            Gid = 400
        elseif gid == 101 then
            Gid = 130
        elseif gid ==  702 or gid == 703 or gid == 704 or gid == 705 or gid == 700 or gid == 701 then
            Gid = 200
        elseif gid == 107 then
            Gid = 100
        elseif gid == 108 then
            Gid = 110
        elseif gid == 109 then
            Gid = 120
        elseif gid == 203 then
            Gid = 300
        elseif gid == 400 then
            Gid = 1800
        elseif gid == 302 then
            Gid = 1900
        elseif gid == 201 then
            Gid = 2000
        end
    else
        Gid = gid
    end
    if Gid == 0 then
        if CallBack ~= nil then
            CallBack() 
        end
        return
    end
    
    if PlayerPrefs.GetInt("Mission10020") == 1 and PlayerPrefs.GetInt("MapHelp"..Gid) ~= 1 or force then        
        ui.Data = FindData()
        Global.OpenUI(_M)
        if ui.Data.first == 0 then
            PlayerPrefs.SetInt("MapHelp"..Gid, 1)
        end
        if isCallBack == false then
            CallBack = nil
        end
    else        
        if CallBack ~= nil then
            CallBack() 
        end
    end
    
end

function OpenMulti(gid)
    Gid = gid
    CallBack = nil
    Global.OpenUI(_M)
end

function ResGid(gid)
    print ("id"..gid)
    local cGid = 0
    if gid == 101 then
        cGid = 130
    elseif gid == 107 then
        cGid = 100    
    elseif gid == 108 then
        cGid = 110    
    elseif gid == 109 then
        cGid = 120    
    end
    return cGid
end

function Close()    
    if ui.ImageLabel ~= nil then
        ui.ImageLabel.gameObject:SetActive(false)
    end
    ui = {}
    if CallBack ~= nil then
        CallBack() 
    end
end

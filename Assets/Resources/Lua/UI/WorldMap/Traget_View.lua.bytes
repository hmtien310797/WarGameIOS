module("Traget_View", package.seeall)

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

local Traget_ViewUI = nil

local icon_textbyid = {
    [1] = "icon_target_red",
    [2] = "icon_target_blue",
    [3] = "icon_target_green",
    [4] = "icon_target_yellow",
}

function GetTargetIcon(type)
    return icon_textbyid[type]
end

local RefrushPage = nil


local function GetTileInfo(tileMsg,mapX, mapY)
    local tileInfo = {}
    local tileData = WorldMap.GetTileData(tileMsg)
    if tileData == nil then
        local tileGid = WorldMap.GetTileGidByMapCoord(mapX, mapY)
        local ad = TableMgr:GetArtSettingData(tileGid)
        tileInfo.name = TextMgr:GetText( ad.name)
        tileInfo.icon = ad.icon
        return tileInfo
    else
        local gid = WorldMap.GetTileGidByMsgData(mapX, mapY, tileMsg, tileData)
        local artSettingData = TableMgr:GetArtSettingData(gid) 
        tileInfo.icon = artSettingData.icon
    end
    local entryType = tileMsg.data.entryType
    print(tileData,entryType)
    
    if entryType == Common_pb.SceneEntryType_None then
        tileInfo.name = TextMgr:GetText(artSettingData.name)
    elseif entryType == Common_pb.SceneEntryType_Home then
        local homeMsg = tileMsg.home
        local guildMsg = tileMsg.ownerguild
        local name = homeMsg.name
        if guildMsg.guildid ~= 0 then                 
            name = string.format("[%s]%s", guildMsg.guildbanner, homeMsg.name)
        end        
        tileInfo.name = name
    elseif entryType == Common_pb.SceneEntryType_Monster then
        tileInfo.name = TextMgr:GetText(tileData.name)
    elseif entryType == Common_pb.SceneEntryType_ActMonster then
        tileInfo.name = TextMgr:GetText(tileData.name)
    elseif entryType >= Common_pb.SceneEntryType_ResFood and entryType <= Common_pb.SceneEntryType_ResElec then
        tileInfo.name = TextMgr:GetText(tileData.name)
    elseif entryType == Common_pb.SceneEntryType_Barrack or entryType == Common_pb.SceneEntryType_Occupy then
        local entryType = tileMsg.data.entryType
        local barrackMsg = entryType == Common_pb.SceneEntryType_Barrack and tileMsg.barrack or tileMsg.occupy
        tileInfo.name = barrackMsg.name
    end
    return tileInfo
end

function RequestTileInfo(name , x,y)
    local req = MapMsg_pb.SceneEntryInfoFreshRequest()
    req.pos.x = x
    req.pos.y = y
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.SceneEntryInfoFreshRequest, req, MapMsg_pb.SceneEntryInfoFreshResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            local info = GetTileInfo(msg.entry,x,y)
            if info == nil then
                return
            end
            print(info.name,info.icon,x,y)
            Traget_Share.Show(name,info.icon,x,y) 
        else
            print(msg.code)
            Global.FloatError(msg.code, Color.white)
        end
    end, true) 
end


function AddItem(traget)
    local item = {}
    item.obj = NGUITools.AddChild(Traget_ViewUI.grid.gameObject,Traget_ViewUI.itemPrefab)
    item.obj.name = 2147483647 - traget.msg.time
    local trf = item.obj.transform
    item.ui = {}
    item.ui.name = trf:Find("bg_list/bg_title/text_name"):GetComponent("UILabel")
    item.ui.icon = trf:Find("bg_list/icon"):GetComponent("UISprite")
    item.ui.del = trf:Find("bg_list/icon/btn_box").gameObject
    item.ui.coord = trf:Find("bg_list/bg_desc/text_des"):GetComponent("UILabel")
    item.ui.go = trf:Find("bg_list/btn_go").gameObject
    item.ui.share = trf:Find("bg_list/btn_share").gameObject

    print(traget.msg.name, item.ui.name,trf:Find("bg_list/bg_title/text_name"))
    item.ui.name.text = traget.msg.name
    item.ui.icon.spriteName = icon_textbyid[traget.msg.type]
    item.ui.coord.text = String.Format(TextMgr:GetText("ui_worldmap_77"),1, traget.msg.pos.x, traget.msg.pos.y)

    SetClickCallback(item.ui.del,function()
        TragetViewData.RequestDelTraget(traget.msg.pos.x, traget.msg.pos.y,function(success)
            if success then
                RefrushPage(Traget_ViewUI.curIndex,true)
            end
        end)
    end)

    SetClickCallback(item.ui.go,function()
        MainCityUI.ShowWorldMap( traget.msg.pos.x, traget.msg.pos.y,true,function()
            --WorldMap.SelectTile(traget.msg.pos.x, traget.msg.pos.y)
        end)
        Hide()
    end)
    
    SetClickCallback(item.ui.share,function()
        RequestTileInfo(traget.msg.name , traget.msg.pos.x, traget.msg.pos.y)
    end)
    return item
end

function ClearCurPage()
    if Traget_ViewUI.curpage == nil then
        return
    end    
    if Traget_ViewUI.curpage.list ~= nil then
        table.foreach(Traget_ViewUI.curpage.list,function(_,v)
            v.obj:SetActive(false)
            GameObject.Destroy(v.obj)
            v = nil
        end)
    end

    Traget_ViewUI.curpage = nil
end

RefrushPage = function(index,force)
    print(index,Traget_ViewUI.curIndex)
    if Traget_ViewUI.curpage ~=nil and Traget_ViewUI.curIndex == index and force == nil then
        return
    end
    ClearCurPage()
    Traget_ViewUI.curpage = {}
    Traget_ViewUI.curpage.list = nil
    Traget_ViewUI.curIndex = index
    local typelist = nil 
    if (index -1) == 0 then
        typelist = TragetViewData.GetTragetMap()
    else
        typelist = TragetViewData.GetTragetTypeList()
        if typelist ~= nil then
            typelist = typelist[index - 1]
        end
    end
    if typelist == nil  then
        Traget_ViewUI.none:SetActive(true)
    else
        Traget_ViewUI.none:SetActive(false)
        Traget_ViewUI.curpage.list = {}
        Traget_ViewUI.curpage.count = 0
        table.foreach(typelist,function(_,traget)
            if traget ~= nil then
                Traget_ViewUI.curpage.list[traget.pos_tag] = AddItem(traget)
                Traget_ViewUI.curpage.count = Traget_ViewUI.curpage.count + 1
            end
        end)
        if Traget_ViewUI.curpage.count ~= 0 then
            Traget_ViewUI.grid:Reposition()
            Traget_ViewUI.scrollView:SetDragAmount(0, 0, false)
        else
            Traget_ViewUI.curpage.list = nil
            Traget_ViewUI.none:SetActive(true)
        end
    end

end


local function LoadUI()
    SetClickCallback(transform:Find("Container").gameObject,function()
        Hide()
    end)

    Traget_ViewUI = {}
    Traget_ViewUI.page = {}
    Traget_ViewUI.curIndex = 1
    Traget_ViewUI.curpage = nil
    for i =1,5,1 do
        Traget_ViewUI.page[i] = transform:Find("Container/bg_frane/bg_tab/btn_type_"..i):GetComponent("UIToggle")
        SetClickCallback(Traget_ViewUI.page[i].gameObject,function()
            RefrushPage(i)
        end)
        if i == Traget_ViewUI.curIndex then
            Traget_ViewUI.page[i].value = true
        else
            Traget_ViewUI.page[i].value = false
        end        
    end
    SetClickCallback(transform:Find("Container/bg_frane/bg_top/btn_close").gameObject,Hide)

    Traget_ViewUI.none = transform:Find("Container/bg_frane/bg_mid/bg_noitem").gameObject
    Traget_ViewUI.scrollView = transform:Find("Container/bg_frane/Scroll View"):GetComponent("UIScrollView")
    Traget_ViewUI.grid = transform:Find("Container/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
    Traget_ViewUI.itemPrefab = transform:Find("Target_listinfo").gameObject

    RefrushPage(Traget_ViewUI.curIndex)
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
    Traget_ViewUI = nil
end

function Show()
    Global.OpenUI(_M)    
end






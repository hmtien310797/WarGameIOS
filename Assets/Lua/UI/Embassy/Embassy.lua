module("Embassy", package.seeall)
local HeroMsg_pb = require("HeroMsg_pb")
local MapMsg_pb = require("MapMsg_pb") 
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback
local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local EmbassyUI

local EmbassyMsg

local UserBaseInfoMap

local EmbassyMap

local EmbassyMapCount

local GOVMode = false

local GOVSubType = nil

local GOVUID 

local GOVMAPX

local GOVMAPY

local StrongholdMode = 0

OnCloseCB = nil
ShowGOVMode = nil
ShowStrongholdMode = nil

local ExtraHomeUid

local ApplyEmbassyItemBtn = true

function SetExtra(uid,apply)
    ExtraHomeUid = uid
    ApplyEmbassyItemBtn = apply
end

function Hide()
    Global.CloseUI(_M)
end
function CanEmbassy(uid,mapx,mapy,charid,callback)

    if not BattleMove.CheckActionList() then
        return
    end

    --是否有保护盾
    --是否有大使馆
    local building = maincity.GetBuildingByID(42)  
    if building == nil or building.data == nil then
		MessageBox.Show(TextMgr:GetText("garrison_ui2")) 
        return
    end
    --是否第二次驻防这个人
    --是否有空闲队列

     if ActionListData.IsFull() then
         MessageBox.Show(TextMgr:GetText("garrison_ui4"))
        return
    end
    --是否容量已满
    local req = MapMsg_pb.MsgGetUserSetoutCapacityRequest()
    req.charid = charid
    req.movetype = Common_pb.TeamMoveType_Garrison
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.MsgGetUserSetoutCapacityRequest, req, MapMsg_pb.MsgGetUserSetoutCapacityResponse, function(msg)
        if msg.code == 0 then
            if msg.capacity == 0 then
                MessageBox.Show(TextMgr:GetText("Embassy_full")) 
                if callback ~= nil then
                    callback()
                end
                return 
            end
            BattleMove.SetFixedMaxSoilder(msg.capacity)
            BattleMove.Show(Common_pb.TeamMoveType_Garrison, uid, "", mapx, mapy, function()
                TileInfo.Hide()
                if callback ~= nil then
                    callback()
                end
            end)
        else
            Global.FloatError(msg.code, Color.white)
        end
    end)   
end

function CanGOVEmbassy(uid,mapx,mapy,callback)
    if not BattleMove.CheckActionList() then
        return
    end

    --是否有保护盾
    --是否有大使馆
    local building = maincity.GetBuildingByID(42)  
    if building == nil or building.data == nil then
		MessageBox.Show(TextMgr:GetText("garrison_ui2")) 
        return false
    end
    --是否第二次驻防这个人
    --是否有空闲队列

     if ActionListData.IsFull() then
         MessageBox.Show(TextMgr:GetText("garrison_ui4"))
         return false
    end
    --是否容量已满

    local gov_msg = GovernmentData.GetGovernmentData()
    if gov_msg ~= nil then
        
        if gov_msg.garrisonCapacity ==0 then
            BattleMove.SetFixedMaxSoilder(Barrack.GetArmyNum())
            BattleMove.Show(Common_pb.TeamMoveType_GarrisonCenterBuild, uid, "", mapx, mapy, function()
                TileInfo.Hide()
                if callback ~= nil then
                    callback()
                end
            end)  
            return true  
        else
            local capacity =  gov_msg.garrisonCapacity - gov_msg.garrisonNum
            if capacity > 0 then
                print(gov_msg.garrisonCapacity ,gov_msg.garrisonNum,capacity)
                BattleMove.SetFixedMaxSoilder(capacity)
                BattleMove.Show(Common_pb.TeamMoveType_GarrisonCenterBuild, uid, "", mapx, mapy, function()
                    TileInfo.Hide()
                    if callback ~= nil then
                        callback()
                    end
                end)   
                return true           
            else
                MessageBox.Show(TextMgr:GetText("city_tips1"))
                return false
            end               
        end
    end
    return false
end

function CanTurretEmbassy(uid,mapx,mapy,subType,callback)
    if not BattleMove.CheckActionList() then
        return
    end    
    --是否有保护盾
    --是否有大使馆
    local building = maincity.GetBuildingByID(42)  
    if building == nil or building.data == nil then
		MessageBox.Show(TextMgr:GetText("garrison_ui2")) 
        return false
    end
    --是否第二次驻防这个人
    --是否有空闲队列

     if ActionListData.IsFull() then
         MessageBox.Show(TextMgr:GetText("garrison_ui4"))
         return false
    end
    --是否容量已满
    local turret_msg = GovernmentData.GetTurretData(subType)
    if turret_msg ~= nil then
        if turret_msg.garrisonCapacity ==0 then
            BattleMove.SetFixedMaxSoilder(Barrack.GetArmyNum())
            BattleMove.Show(Common_pb.TeamMoveType_GarrisonCenterBuild, uid, "", mapx, mapy, function()
                TileInfo.Hide()
                if callback ~= nil then
                    callback()
                end
            end)  
            return true  
        else
            local capacity =  turret_msg.garrisonCapacity - turret_msg.garrisonNum
            if capacity > 0 then
                BattleMove.SetFixedMaxSoilder(capacity)
                BattleMove.Show(Common_pb.TeamMoveType_GarrisonCenterBuild, uid, "", mapx, mapy, function()
                    TileInfo.Hide()
                    if callback ~= nil then
                        callback()
                    end
                end)       
                return true       
            else
                MessageBox.Show(TextMgr:GetText("city_tips1"))
                return false
            end                 
        end
    end
    return false
end

function CanStrongholdEmbassy(entryType,subtype,uid,mapx,mapy,callback)
    if not BattleMove.CheckActionList() then
        return
    end

    --是否有保护盾
    --是否有大使馆
    local building = maincity.GetBuildingByID(42)  
    if building == nil or building.data == nil then
		MessageBox.Show(TextMgr:GetText("garrison_ui2")) 
        return false
    end
    --是否第二次驻防这个人
    --是否有空闲队列

     if ActionListData.IsFull() then
         MessageBox.Show(TextMgr:GetText("garrison_ui4"))
         return false
    end
    --是否容量已满

    local garrisonCapacity
    local garrisonNum

    if entryType == Common_pb.SceneEntryType_Stronghold then
        local stronghold_msg = StrongholdData.GetStrongholdData(subtype)
        if stronghold_msg == nil then
            return false
        end
        garrisonCapacity = stronghold_msg.garrisonCapacity
        garrisonNum = stronghold_msg.garrisonNum
        
    elseif entryType == Common_pb.SceneEntryType_Fortress then
		local fortress_msg = FortressData.GetFortressData(subtype)
        if fortress_msg == nil then
            return false
        end
		garrisonCapacity = fortress_msg.garrisonCapacity
        garrisonNum = fortress_msg.garrisonNum

    end
    if garrisonCapacity ==0 then
        BattleMove.SetFixedMaxSoilder(Barrack.GetArmyNum())
        BattleMove.Show(Common_pb.TeamMoveType_GarrisonCenterBuild, uid, "", mapx, mapy, function()
            TileInfo.Hide()
            if callback ~= nil then
                callback()
            end
        end)  
        return true  
    else
        local capacity =  garrisonCapacity - garrisonNum
        if capacity > 0 then
            print(garrisonCapacity ,garrisonNum,capacity)
            BattleMove.SetFixedMaxSoilder(capacity)
            BattleMove.Show(Common_pb.TeamMoveType_GarrisonCenterBuild, uid, "", mapx, mapy, function()
                TileInfo.Hide()
                if callback ~= nil then
                    callback()
                end
            end)   
            return true           
        else
            MessageBox.Show(TextMgr:GetText("city_tips1"))
            return false
        end                  
    end
    return false
end

local function CloseSelf()
	Global.CloseUI(_M)
end

function RefrushToNone()
    if EmbassyMapCount <= 0 then
        EmbassyUI.None:SetActive(true);
    else
        EmbassyUI.None:SetActive(false)
    end
end

function RefrushTotalNum()
    if GOVMode then
        local gis = 0
        if GOVSubType == nil then
            gis = GovernmentData.GetGovGarrisonInfo()
        else
            gis = GovernmentData.GetTurretGarrisonInfo(GOVSubType)
        end
        EmbassyUI.num.text = gis.garrisonNum.."/"
    elseif StrongholdMode ~= 0 then
        local garrisonCapacity = 0
        if StrongholdMode == Common_pb.SceneEntryType_Stronghold then
            garrisonCapacity = StrongholdData.GetGarrisonInfo(GOVSubType).garrisonNum                
        else
            garrisonCapacity = FortressData.GetGarrisonInfo(GOVSubType).garrisonNum
        end   
        EmbassyUI.num.text = garrisonCapacity.."/"
    else
        local num = 0;
        local count = 0;
        table.foreach(EmbassyMap,function(_,v) 
            if v ~= nil then
                num = num + v.num
                count = count +1
            end
        end)
        EmbassyUI.num.text = num.."/"
        EmbassyUI.player_num.text = count.."/"
    end
end

function DestroyEmbassyMap()
    table.foreach(EmbassyMap,function(_,v) 
        if v ~= nil then
            CountDown.Instance:Remove("AddEmbassyItem"..v.id)
            v.destroyfunc()
        end
    end)
end

function DynamicRemoveEmbassyItem(item)
    EmbassyMap[item.id] = nil
    EmbassyMapCount = EmbassyMapCount -1 
    item.obj:SetActive(false)
    GameObject.Destroy(item.obj)
    item = nil
    EmbassyUI.Table:Reposition()
    RefrushTotalNum()  
    RefrushToNone()
end

function DynamicAddEmbassyItem(item)
    EmbassyMap[item.id] = item   
    EmbassyMapCount = EmbassyMapCount +1
    EmbassyUI.Table:Reposition() 
    RefrushTotalNum()  
    RefrushToNone()
end   

function CancelEmbassyItemEx(homeUid,charid,callback)
    local req = MapMsg_pb.CancelPathRequest()
    req.taruid = homeUid
    req.garrisonUser = charid
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.CancelPathRequest, req, MapMsg_pb.CancelPathResponse, function(msg)
        if msg.code == 0 then
            if callback ~= nil then
                callback();
            end
        else
            Global.FloatError(msg.code, Color.white)
        end
    end)
end  


function CancelEmbassyAllItemEx(homeUid,count,callback)
    if count == 0 then    
        return 
    end
    local req = MapMsg_pb.CancelPathRequest()
    req.taruid = homeUid
    req.garrisonAllUser = true
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.CancelPathRequest, req, MapMsg_pb.CancelPathResponse, function(msg)
        if msg.code == 0 then
            if callback ~= nil then
                callback();
            end        
        else
            Global.FloatError(msg.code, Color.white)
        end
    end)
end


function CancelEmbassyItem(item,callback)
    local req = MapMsg_pb.CancelPathRequest()
    local homeUid = ExtraHomeUid
    if homeUid == nil then
        if GOVMode then

            local gis = 0
            if GOVSubType == nil then
                gis = GovernmentData.GetGovGarrisonInfo()
            else
                gis = GovernmentData.GetTurretGarrisonInfo(GOVSubType)
            end
            
            homeUid = gis.seUid
        elseif StrongholdMode ~= 0 then 

            local gis = 0
            if StrongholdMode == Common_pb.SceneEntryType_Stronghold then
                gis = StrongholdData.GetGarrisonInfo(GOVSubType)
            else
				gis = FortressData.GetGarrisonInfo(GOVSubType)
            end
            
            homeUid = gis.seUid             
        else
            homeUid =  EmbassyMsg.homeUid
        end
    end
    req.taruid = homeUid
    
    if GOVMode then
        req.tarpathid = item.pathid
        req.garrisonCenterUser = item.charid 
    elseif StrongholdMode ~= 0 then  
        req.tarpathid = item.pathid
        req.garrisonCenterUser = item.charid         
    else
        req.garrisonUser = item.charid 
    end
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.CancelPathRequest, req, MapMsg_pb.CancelPathResponse, function(msg)
        if msg.code == 0 then
            if ExtraHomeUid == nil then
                DynamicRemoveEmbassyItem(item)
            else
                if item.cancel_cb ~= nil then
                    item.cancel_cb(item)
                end
            end
            if callback ~= nil then
                callback();
            end
        else
            Global.FloatError(msg.code, Color.white)
        end
    end)   
end  


function CancelEmbassyAllItem()
    if EmbassyMapCount == 0 then    
        return 
    end
    local req = MapMsg_pb.CancelPathRequest()
    if GOVMode then
        local gis = 0
        if GOVSubType == nil then
            gis = GovernmentData.GetGovGarrisonInfo()
        else
            gis = GovernmentData.GetTurretGarrisonInfo(GOVSubType)
        end
        req.taruid = gis.seUid
    elseif StrongholdMode ~= 0 then   
        local gis = 0
        if StrongholdMode == Common_pb.SceneEntryType_Stronghold then
            gis = StrongholdData.GetGarrisonInfo(GOVSubType)
        else
			gis = FortressData.GetGarrisonInfo(GOVSubType)
        end
        req.taruid = gis.seUid         
    else
        req.taruid = EmbassyMsg.homeUid
    end

    
    req.garrisonAllUser = true
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.CancelPathRequest, req, MapMsg_pb.CancelPathResponse, function(msg)
        if msg.code == 0 then
            table.foreach(EmbassyMap,function(_,v) 
                if v ~= nil and v.isArrired() then
                    v.obj:SetActive(false)
                    GameObject.Destroy(v.obj)   
                    v = nil
                    EmbassyMapCount = EmbassyMapCount -1
                end
            end)   
            EmbassyUI.Table:Reposition()
            RefrushTotalNum()
            RefrushToNone()
        else
            Global.FloatError(msg.code, Color.white)
        end
    end)
end

function AddArmyItem(armydata,armyPrefab,RootObj,shadowEffect)
    local army = {}
    army.obj = NGUITools.AddChild(RootObj,armyPrefab)

    print(armydata.id)
    army.obj.name = armydata.id
    army.ui = {}
    local trf = army.obj.transform
    army.ui.sprite = trf:Find("Sprite")
    if army.ui.sprite ~= nil then
        if shadowEffect then
            army.ui.sprite.gameObject:SetActive(true)
        else
            army.ui.sprite.gameObject:SetActive(false)
        end
    end
    army.ui.name = trf:Find("Label_01"):GetComponent("UILabel")
    army.ui.grid = trf:Find("Grid01"):GetComponent("UIGrid")
    army.ui.level = {}
    army.ui.level[1] = trf:Find("Grid01/show_1/Sprite1/number"):GetComponent("UILabel")
    army.ui.level[2] = trf:Find("Grid01/show_2/Sprite2/number"):GetComponent("UILabel")
    army.ui.level[3] = trf:Find("Grid01/show_3/Sprite3/number"):GetComponent("UILabel")
    army.ui.level[4] = trf:Find("Grid01/show_4/Sprite4/number"):GetComponent("UILabel")
    --添加为0的数据不显示
    army.ui.show = {}
    army.ui.show[1] = trf:Find("Grid01/show_1")
    army.ui.show[2] = trf:Find("Grid01/show_2")
    army.ui.show[3] = trf:Find("Grid01/show_3")
    army.ui.show[4] = trf:Find("Grid01/show_4")
    local s = Barrack.GetAramInfo(armydata.id,1)
    army.ui.name.text = TextMgr:GetText(s.TabName)
    for i=1,4,1 do
        if armydata[i] ~= nil then
            army.ui.level[i].text = armydata[i]
            army.ui.show[i].gameObject:SetActive(true)
        else
            army.ui.level[i].text = 0
            army.ui.show[i].gameObject:SetActive(false)
        end
    end
    army.ui.grid.repositionNow = true
    army.ui.grid:Reposition()
end

function LoadHeroObject(hero, heroTransform)
    hero.transform = heroTransform
    hero.icon = heroTransform:Find("head icon"):GetComponent("UITexture")
    hero.btn = heroTransform:Find("head icon"):GetComponent("UIButton")
    hero.qualityList = {}
    for i = 1, 5 do
        hero.qualityList[i] = heroTransform:Find("head icon/outline"..i)
    end
    hero.levelLabel = heroTransform:Find("head icon/level text"):GetComponent("UILabel")
    hero.starList = {}
    for i = 1, 6 do
        hero.starList[i] = heroTransform:Find("head icon/star/star"..i)
    end
end

function LoadHero(hero, msg, data)
    hero.msg = msg
    hero.data = data
    if hero.icon ~= nil then
        hero.icon.mainTexture = ResourceLibrary:GetIcon("Icon/herohead/", data.icon)
    end
    Global.SetNumber(hero.qualityList, data.quality)
    if hero.levelLabel ~= nil then
        hero.levelLabel.text = msg.level
    end
    Global.SetNumber(hero.starList, msg.star)
end

function AddEmbassyItem(GarrisonData,itemPrefab,armyPrefab,RootObj,use_charid)
    local item = {}
    item.id =  GarrisonData.pathid..","..GarrisonData.charid
    if use_charid ~= nil and use_charid then
        item.id = GarrisonData.charid
    end
    item.pathid = GarrisonData.pathid
    item.charid = GarrisonData.charid
    
    local endtime = GarrisonData.starttime + GarrisonData.movetime
    print("TTTTTTTTTTTTTTTTTTTTT",endtime,GarrisonData.starttime,GarrisonData.movetime)
    --print(RootObj,itemPrefab)
    item.obj = NGUITools.AddChild(RootObj,itemPrefab)
    item.obj.name = GarrisonData.pathid

    item.ui = {}
    local trf = item.obj.transform
    item.ui.name = trf:Find("bg_list/bg_icon/bg_text/text_name"):GetComponent("UILabel")
    item.ui.icon = trf:Find("bg_list/bg_icon/Texture"):GetComponent("UITexture")
    item.ui.totalcount = trf:Find("bg_list/total force/Label"):GetComponent("UILabel")
    item.ui.timetext = trf:Find("bg_list/bg_exp/bg/text"):GetComponent("UILabel")
    item.ui.timeroot = trf:Find("bg_list/bg_exp")
    item.ui.timebar = trf:Find("bg_list/bg_exp/bg/bar"):GetComponent("UISlider")
    item.ui.state = trf:Find("bg_list/march_text")
    item.ui.applybtn = trf:Find("bg_list/commander")
    item.ui.applybtn_btn = item.ui.applybtn.gameObject:GetComponent("UIButton")
    item.ui.applybtn_text = trf:Find("bg_list/commander/text"):GetComponent("UILabel")
    item.ui.armyroot = trf:Find("Item_open01/bg_soldier/Sprite#AutoHeight/Grid"):GetComponent("UIGrid")
    item.ui.disband = trf:Find("bg_list/btn_del")
    item.cancel_cb = nil
	item.ui.headbtn = trf:Find("bg_list/bg_icon"):GetComponent("UIButton")
	SetClickCallback(item.ui.headbtn.gameObject , function()
		OtherInfo.RequestShow(GarrisonData.charid)
    end)
    
    
    if GOVMode then
        if MainData.GetCharId() == item.charid then
            item.ui.applybtn_text.text =TextMgr:GetText("ui_worldmap_38")
            item.ui.applybtn_btn.normalSprite = EmbassyUI~=nil and "btn_5" or "union_button5"
        else
            item.ui.applybtn_text.text =TextMgr:GetText("Embassy_ui3")
            item.ui.applybtn_btn.normalSprite = EmbassyUI~=nil and "btn_5" or "union_button5"
        end
        SetClickCallback(item.ui.applybtn.gameObject, function()
            CancelEmbassyItem(item,function()
                if GOVSubType == nil then
                    GovernmentData.ReqGoveInfoData()
                else
                    GovernmentData.ReqTurretInfoData(GOVSubType)        
                end 
            
            end)
        end) 
    elseif StrongholdMode ~= 0 then
        if MainData.GetCharId() == item.charid then
            item.ui.applybtn_text.text =TextMgr:GetText("ui_worldmap_38")
            item.ui.applybtn_btn.normalSprite = EmbassyUI~=nil and "btn_5" or "union_button5"
        else
            item.ui.applybtn_text.text =TextMgr:GetText("Embassy_ui3")
            item.ui.applybtn_btn.normalSprite = EmbassyUI~=nil and "btn_5" or "union_button5"
        end
        SetClickCallback(item.ui.applybtn.gameObject, function()
            CancelEmbassyItem(item,function()
                if StrongholdMode == Common_pb.SceneEntryType_Stronghold then
                    StrongholdData.ReqStrongholdInfoData(GOVSubType)
                else
                    FortressData.ReqFortressData(GOVSubType)
                end
            end)
        end)    
    else
        item.ui.applybtn_text.text =TextMgr:GetText("Embassy_ui3")
        item.ui.applybtn_btn.normalSprite = EmbassyUI~=nil and "btn_5" or "union_button5"
        SetClickCallback(item.ui.applybtn.gameObject, function()
            CancelEmbassyItem(item)
        end) 
    end    



    item.destroyfunc = function()
        CountDown.Instance:Remove("AddEmbassyItem"..item.id)
    end

    item.isArrired = function()
        if endtime+1 - Serclimax.GameTime.GetSecTime() <= 0 then
            return true
        else
            return false
        end
    end

    local armymapdata = {}
    local tnum = 0
    
    for i=1,#GarrisonData.army.army.army,1 do
        local aid = GarrisonData.army.army.army[i].armyId
        local alevel = GarrisonData.army.army.army[i].armyLevel
        if armymapdata[aid] == nil then
            armymapdata[aid] = {}
            armymapdata[aid].id = aid
        end
        if armymapdata[aid][alevel] == nil then
            armymapdata[aid][alevel] = {}
        end
        armymapdata[aid][alevel] = GarrisonData.army.army.army[i].num - GarrisonData.army.army.army[i].deadNum - GarrisonData.army.army.army[i].injuredNum
        tnum = tnum + GarrisonData.army.army.army[i].num- GarrisonData.army.army.army[i].deadNum - GarrisonData.army.army.army[i].injuredNum
    end
    item.num = tnum
    local user = nil
    if GOVMode then
        local gis = 0
        if GOVSubType == nil then
            gis = GovernmentData.GetGovGarrisonInfo()
        else
            gis = GovernmentData.GetTurretGarrisonInfo(GOVSubType)
        end
        user = gis.garrisonMap[item.id].baseInfo
    elseif StrongholdMode ~= 0 then
        local gis = nil
        if StrongholdMode == Common_pb.SceneEntryType_Stronghold then
            gis = StrongholdData.GetGarrisonInfo(GOVSubType)
        else
			gis = FortressData.GetGarrisonInfo(GOVSubType)
        end
        user = gis.garrisonMap[item.id].baseInfo      
    else
        user = UserBaseInfoMap[GarrisonData.charid]
    end
    
    if user ~= nil then
        item.ui.name.text = user.name
        item.ui.icon.mainTexture = ResourceLibrary:GetIcon("Icon/head/",user.face)
        item.ui.userMsg = user
    end

    item.ui.totalcount.text = tnum
    local arrive = false
    if endtime - Serclimax.GameTime.GetSecTime() < 0 then
        arrive = true
        item.ui.timeroot.gameObject:SetActive(false)
        item.ui.state.gameObject:SetActive(false)
        if ApplyEmbassyItemBtn then
            if GOVMode then
                item.ui.applybtn.gameObject:SetActive(GovernmentData.IsCancelGarrison(item.charid,GOVSubType))
            elseif StrongholdMode ~= 0 then
                if StrongholdMode == Common_pb.SceneEntryType_Stronghold then
                    item.ui.applybtn.gameObject:SetActive(StrongholdData.IsCancelGarrison(item.charid,GOVSubType))
                else
					item.ui.applybtn.gameObject:SetActive(FortressData.IsCancelGarrison(item.charid,GOVSubType))
                end
            else
                item.ui.applybtn.gameObject:SetActive(true)
            end           
        else
            item.ui.applybtn.gameObject:SetActive(false)
        end
    else
        item.ui.timeroot.gameObject:SetActive(true)
        item.ui.state.gameObject:SetActive(true)
        item.ui.applybtn.gameObject:SetActive(false)
        --print(GarrisonData.endtime)
		CountDown.Instance:Add("AddEmbassyItem"..item.id,endtime,CountDown.CountDownCallBack(function(t)
			item.ui.timetext.text  = t
			--print(Serclimax.GameTime.GetSecTime(),GarrisonData.endtime,Serclimax.GameTime.GetSecTime()/GarrisonData.endtime)
			item.ui.timebar.value = math.min(1,(Serclimax.GameTime.GetSecTime() - GarrisonData.starttime)/GarrisonData.movetime)
			if endtime+1 - Serclimax.GameTime.GetSecTime() <= 0 then
                item.ui.timeroot.gameObject:SetActive(false)
                item.ui.state.gameObject:SetActive(false)
                if ApplyEmbassyItemBtn then
                    if GOVMode then
                        item.ui.applybtn.gameObject:SetActive(GovernmentData.IsCancelGarrison(item.charid,GOVSubType))
                    elseif StrongholdMode ~= 0 then
                        if StrongholdMode == Common_pb.SceneEntryType_Stronghold then
                            item.ui.applybtn.gameObject:SetActive(StrongholdData.IsCancelGarrison(item.charid,GOVSubType))
                        else
							item.ui.applybtn.gameObject:SetActive(FortressData.IsCancelGarrison(item.charid,GOVSubType))
                        end
                    else
                        item.ui.applybtn.gameObject:SetActive(true)
                    end   
                else
                    item.ui.applybtn.gameObject:SetActive(false)
                end
				CountDown.Instance:Remove("AddEmbassyItem"..item.id)
			end			
		end))        
    end
    item.ui.heros ={}
	item.ui.heroPrefab = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
    local thero = #GarrisonData.army.hero.heros
    for i =1,5,1 do
        item.ui.heros[i] = {}
        item.ui.heros[i].trf = trf:Find("bg_list/Grid/hero"..i) 
        item.ui.heros[i].herotrf = trf:Find("bg_list/Grid/hero"..i.."/listitem_herocard(Clone)") 
		item.ui.heros[i].bgtrf = trf:Find("bg_list/Grid/hero"..i.."/bg") 
        if i > thero then
			if item.ui.heros[i].herotrf ~= nil then
				item.ui.heros[i].herotrf.gameObject:SetActive(false)
			end
			item.ui.heros[i].bgtrf.gameObject:SetActive(true)
            --item.ui.heros[i].trf:Find("head icon").gameObject:SetActive(false)
        else
            local msg = GarrisonData.army.hero.heros[i]
            local heroData = Global.GTableMgr:GetHeroData(msg.baseid) 
            local hero = {}
			if item.ui.heros[i].herotrf == nil then
				item.ui.heros[i].herotrf = NGUITools.AddChild(item.ui.heros[i].trf.gameObject , item.ui.heroPrefab.gameObject).transform
				item.ui.heros[i].herotrf:SetParent(item.ui.heros[i].trf)
				item.ui.heros[i].herotrf.localScale = Vector3(0.8 ,0.8 , 1)
			end
			item.ui.heros[i].herotrf.gameObject:SetActive(true)
			item.ui.heros[i].bgtrf.gameObject:SetActive(false)
			
			HeroList.LoadHeroObject(hero , item.ui.heros[i].herotrf)
			UIUtil.LoadHeroInfo(hero , msg , false)
					
            --LoadHeroObject(hero,item.ui.heros[i].trf)
            --LoadHero(hero,msg,heroData)
            item.ui.heros[i].hero = hero
        end
    end
    local c = 0
    table.foreach(armymapdata,function(_,v)
        c = c+1
        AddArmyItem(v,armyPrefab,item.ui.armyroot.gameObject,c == 1 or c == 5)
    end)
    item.ui.armyroot:Reposition()

    local paradeTableItem = item.obj:GetComponent("ParadeTableItemController")
    paradeTableItem:CalAutoHight()
    return item
end

function RequestEmbassyData(charid,callback)
    local req = HeroMsg_pb.MsgGetGarrisonInfoRequest()
    req.charid = charid
    Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgGetGarrisonInfoRequest, req, HeroMsg_pb.MsgGetGarrisonInfoResponse, function(msg)
        if msg.code == 0 then
            if callback ~= nil then
                callback(msg);
            end
        else            
            Global.FloatError(msg.code, Color.white)
        end
    end)
end



function LoadUI()
    EmbassyUI = {}
    EmbassyUI.ScrollView = transform:Find("Marchlist/Container/bg_frane/Scroll View"):GetComponent("UIScrollView")
    EmbassyUI.Table = transform:Find("Marchlist/Container/bg_frane/Scroll View/Table"):GetComponent("UITable")
    EmbassyUI.itemPrefab = transform:Find("Marchlist/ItemInfo").gameObject
    EmbassyUI.ArmyPrefab = transform:Find("Marchlist/soilder_list").gameObject
    EmbassyUI.None = transform:Find("Marchlist/Container/bg_frane/none").gameObject
    EmbassyUI.title = transform:Find("Marchlist/Container/bg_frane/bg_top/bg_title_left/title"):GetComponent("UILabel")
    EmbassyUI.btn_text = transform:Find("Marchlist/Container/bg_frane/button/text"):GetComponent("UILabel")
    EmbassyMap = {}
    EmbassyMapCount = 0
    if GOVMode then
        EmbassyUI.btn_text.text = TextMgr:GetText("union_anagement6")
        EmbassyUI.title.text = TextMgr:GetText("GOV_ui9")
        local gis = 0
        if GOVSubType == nil then
            gis = GovernmentData.GetGovGarrisonInfo()
        else
            gis = GovernmentData.GetTurretGarrisonInfo(GOVSubType)
        end
        if gis ~= nil and gis.garrisonInfos ~= nil  then
            for i = 1,#gis.garrisonInfos,1 do
                local item = AddEmbassyItem(gis.garrisonInfos[i].garrisonData,EmbassyUI.itemPrefab,EmbassyUI.ArmyPrefab,EmbassyUI.Table.gameObject)
                EmbassyMap[item.id] = item
                EmbassyMapCount = EmbassyMapCount +1
            end 
        end
    elseif StrongholdMode ~= 0 then
        EmbassyUI.btn_text.text = TextMgr:GetText("union_anagement6")
        EmbassyUI.title.text = TextMgr:GetText("GOV_ui9")
        local gis = nil
        if StrongholdMode == Common_pb.SceneEntryType_Stronghold then
            gis = StrongholdData.GetGarrisonInfo(GOVSubType)
        else
			gis = FortressData.GetGarrisonInfo(GOVSubType)
        end
        if gis ~= nil and gis.garrisonInfos ~= nil  then
            for i = 1,#gis.garrisonInfos,1 do
                local item = AddEmbassyItem(gis.garrisonInfos[i].garrisonData,EmbassyUI.itemPrefab,EmbassyUI.ArmyPrefab,EmbassyUI.Table.gameObject)
                EmbassyMap[item.id] = item
                EmbassyMapCount = EmbassyMapCount +1
            end 
        end
    else
        EmbassyUI.btn_text.text = TextMgr:GetText("Embassy_ui4")
        EmbassyUI.title.text = TextMgr:GetText("Embassy_ui7")
        for i = 1,#EmbassyMsg.garrison.garrison,1 do
            local item = AddEmbassyItem(EmbassyMsg.garrison.garrison[i],EmbassyUI.itemPrefab,EmbassyUI.ArmyPrefab,EmbassyUI.Table.gameObject)
            EmbassyMap[item.id] = item
            EmbassyMapCount = EmbassyMapCount +1
        end 
    end
     EmbassyUI.Table:Reposition()
     EmbassyUI.ScrollView:MoveRelative(Vector3(0, 10, 0))
     EmbassyUI.ScrollView:ResetPosition()
    SetClickCallback(transform:Find("Marchlist/Container/bg_frane/bg_top/btn_close").gameObject, function()
        CloseSelf()
    end)
	SetClickCallback(transform:Find("Marchlist/Container").gameObject, function()
        CloseSelf()
    end)
    if GOVMode then
        SetClickCallback(transform:Find("Marchlist/Container/bg_frane/button").gameObject, function()
            if GOVSubType == nil then
                if Embassy.CanGOVEmbassy(GOVUID,GOVMAPX,GOVMAPY,function() 
                    ShowGOVMode(GOVUID,GOVMAPX,GOVMAPY,nil)
                end) then
                    Hide()
                end
            else
                if Embassy.CanTurretEmbassy(GOVUID,GOVMAPX,GOVMAPY,GOVSubType,function() 
                    ShowGOVMode(GOVUID,GOVMAPX,GOVMAPY,GOVSubType)
                end) then
                    Hide()
                end  
            end
            
        end)   
    elseif StrongholdMode ~= 0 then
        SetClickCallback(transform:Find("Marchlist/Container/bg_frane/button").gameObject, function()
            if Embassy.CanStrongholdEmbassy(StrongholdMode,GOVSubType,GOVUID,GOVMAPX,GOVMAPY,function() 
                ShowStrongholdMode(GOVUID,GOVMAPX,GOVMAPY,GOVSubType,StrongholdMode)
            end) then
                Hide()
            end
        end)      
    else
        SetClickCallback(transform:Find("Marchlist/Container/bg_frane/button").gameObject, function()
            CancelEmbassyAllItem()
        end)        
    end
    EmbassyUI.total_root =transform:Find("Marchlist/Container/bg_frane/Total")
    EmbassyUI.total_root.gameObject:SetActive(true)
    EmbassyUI.total = transform:Find("Marchlist/Container/bg_frane/Total/number (1)"):GetComponent("UILabel")
    EmbassyUI.num = transform:Find("Marchlist/Container/bg_frane/Total/number"):GetComponent("UILabel")

    EmbassyUI.player_total_root =transform:Find("Marchlist/Container/bg_frane/CommandNum")
    EmbassyUI.player_total_root.gameObject:SetActive(false)
    EmbassyUI.player_total = transform:Find("Marchlist/Container/bg_frane/CommandNum/number (1)"):GetComponent("UILabel")
    EmbassyUI.player_num = transform:Find("Marchlist/Container/bg_frane/CommandNum/number"):GetComponent("UILabel")

    local show_number = false

    
    --if GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_muzhi or
    --GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_muzhi or 
    --GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_opgame then
        show_number = false
    --else
    --    show_number = true
    --end

    if GOVMode then
        local gis = 0
        if GOVSubType == nil then
            gis = GovernmentData.GetGovGarrisonInfo()
            EmbassyUI.player_total.text = tonumber(TableMgr:GetGlobalData(100164).value)
            EmbassyUI.player_total_root.gameObject:SetActive(show_number)
        else
            gis = GovernmentData.GetTurretGarrisonInfo(GOVSubType)
            EmbassyUI.player_total.text = tonumber(TableMgr:GetGlobalData(100165).value)
            EmbassyUI.player_total_root.gameObject:SetActive(show_number)
        end
        EmbassyUI.total.text = gis.garrisonCapacity
        EmbassyUI.total_root.gameObject:SetActive(gis.garrisonCapacity~=0)
    elseif StrongholdMode ~= 0 then
        local garrisonCapacity = 0
        if StrongholdMode == Common_pb.SceneEntryType_Stronghold then
            garrisonCapacity = StrongholdData.GetGarrisonInfo(GOVSubType).garrisonCapacity
            EmbassyUI.player_total.text = tonumber(TableMgr:GetGlobalData(100162).value)
            EmbassyUI.player_total_root.gameObject:SetActive(show_number)
            --if GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_muzhi or
            --GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_muzhi or 
            --GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_opgame then
                EmbassyUI.total_root.gameObject:SetActive(true)
            --else
            --    EmbassyUI.total_root.gameObject:SetActive(false)
            --end
            
        else
            garrisonCapacity = FortressData.GetGarrisonInfo(GOVSubType).garrisonCapacity
            EmbassyUI.player_total.text = tonumber(TableMgr:GetGlobalData(100163).value)
            EmbassyUI.player_total_root.gameObject:SetActive(show_number)
            --if GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_muzhi or
            --GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_muzhi or 
            --GUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_opgame then
                EmbassyUI.total_root.gameObject:SetActive(true)
            --else
            --    EmbassyUI.total_root.gameObject:SetActive(false)
            --end
        end   
        EmbassyUI.total.text = garrisonCapacity
        EmbassyUI.total_root.gameObject:SetActive(garrisonCapacity~=0)
        
    else
        local building = maincity.GetBuildingByID(42)
        local curEmbassyData = TableMgr:GetEmbassyData(building.data.level)
        EmbassyUI.total.text =  curEmbassyData.armynum * (1 + 0.01 * (AttributeBonus.CollectBonusInfo()[1097] ~= nil and AttributeBonus.CollectBonusInfo()[1097] or 0)) + (AttributeBonus.CollectBonusInfo()[1093] ~= nil and AttributeBonus.CollectBonusInfo()[1093] or 0)            
    end

    RefrushTotalNum()
    RefrushToNone()
end

function Awake()
    if GOVMode or StrongholdMode ~= 0 then
        return
    end
    ApplyEmbassyItemBtn = true
    ExtraHomeUid = nil
    UserBaseInfoMap = nil
    EmbassyMsg = nil    
end

function FillUserBaseInfo(msg_user)
    UserBaseInfoMap = {}
    for i =1,#msg_user,1 do
        UserBaseInfoMap[msg_user[i].charid] = msg_user[i]
    end   
end

function Start()
    if GOVMode or StrongholdMode ~= 0 then
        return
    end    
    RequestEmbassyData(0,function(msg)
        EmbassyMsg = msg
        FillUserBaseInfo(EmbassyMsg.user)
        LoadUI();
    end)
end

ShowGOVMode = function (uid, mapx, mapy,subType)

    if subType == nil then
        GovernmentData.ReqGovGarrisonInfo(function()
            Global.OpenUI(_M)
            GOVMode = true
            StrongholdMode = 0;
            GOVSubType = subType
            GOVUID = uid
            GOVMAPX = mapx
            GOVMAPY = mapy           
            LoadUI();
        end)
    else
        GovernmentData.ReqTurretGarrisonInfo(subType,function()
            Global.OpenUI(_M)
            GOVMode = true
            StrongholdMode = 0;
            GOVSubType = subType
            GOVUID = uid
            GOVMAPX = mapx
            GOVMAPY = mapy              
           LoadUI();
        end)        
    end
end

ShowStrongholdMode = function (uid, mapx, mapy,subType,entryType)
    if entryType == Common_pb.SceneEntryType_Stronghold then
        StrongholdData.ReqGarrisonInfo(subType,function()
            Global.OpenUI(_M)
            GOVMode = false
            StrongholdMode = entryType
            GOVSubType = subType
            GOVUID = uid
            GOVMAPX = mapx
            GOVMAPY = mapy           
            LoadUI();
        end)
    elseif entryType == Common_pb.SceneEntryType_Fortress then
		FortressData.ReqGarrisonInfo(subType,function()
            Global.OpenUI(_M)
            GOVMode = false
            StrongholdMode = entryType
            GOVSubType = subType
            GOVUID = uid
            GOVMAPX = mapx
            GOVMAPY = mapy           
            LoadUI();
        end)
    end
end


function Close()
    GOVMode = false
    StrongholdMode = 0;
    --GOVSubType = nil
    DestroyEmbassyMap()
    EmbassyMapCount = 0
    EmbassyMap = nil
    UserBaseInfoMap = nil
    EmbassyMsg = nil
    EmbassyUI = nil
	if OnCloseCB ~= nil then
    	OnCloseCB()
    	OnCloseCB = nil
    end
end


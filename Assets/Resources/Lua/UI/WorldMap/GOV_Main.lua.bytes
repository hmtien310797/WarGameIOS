module("GOV_Main", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameObject = UnityEngine.GameObject

local _ui
local AdminMode
local AppointCharId
local setfinishColseCallback
local OfficialTableNames ={
    "Container/bg_frane/bg_mid/Scroll View/Table/bg_official/Grid",
    "Container/bg_frane/bg_mid/Scroll View/Table/bg_official (1)/Grid",
    "Container/bg_frane/bg_mid/Scroll View/Table/bg_official (2)/Grid",
    "Container/bg_frane/bg_mid/Scroll View/Table/bg_official (3)/Grid",
}

local OfficialTableNoAdminNames ={
    "Container/bg_frane/bg_mid/Scroll View (1)/Table/bg_official/Grid",
    "Container/bg_frane/bg_mid/Scroll View (1)/Table/bg_official (1)/Grid",
    "Container/bg_frane/bg_mid/Scroll View (1)/Table/bg_official (2)/Grid",
    "Container/bg_frane/bg_mid/Scroll View (1)/Table/bg_official (3)/Grid",
}

local BtnTableNames ={
    "Container/bg_frane/bg_bottom/button",
    "Container/bg_frane/bg_bottom/button (1)",
    "Container/bg_frane/bg_bottom/button (2)",
    "Container/bg_frane/bg_bottom/button (3)",
}

local OfficialGrades = {
    1,
    2,
    3,
    100,
}



local LoadUI = nil

function Hide()
    Global.CloseUI(_M)
end

local function DisposeGovRulingPush()
    FloatText.Show(TextMgr:GetText("GOV_ui70")  , Color.red)
    Hide()
end

local officialOperationMode ={
    DeposeOrEditPrivilege = function(item,callback)
        GOV_Officialinfo.Show(true,item.data.id,item.msg,callback)
    end,
    Appoint = function(item)
        if AppointCharId < 0 then
            return
        end
        GovernmentData.ReqGoveAppointOfficial(AppointCharId,item.data.id,function()
            LoadUI()
            if setfinishColseCallback~=nil then
                setfinishColseCallback(item.data.id)
            end
        end)      
    end,
} 



function InitOfficialItem(item,buff_prefab)
    item.official_icon = item.obj.transform:Find("official_icon"):GetComponent("UITexture")
    item.official_name=item.obj.transform:Find("official_icon/official_name"):GetComponent("UILabel")
    item.player_name=item.obj.transform:Find("official_icon/player_name"):GetComponent("UILabel")
    item.player_name.gameObject:AddComponent(typeof(UIEventListener))
    item.buff_root=item.obj.transform:Find("bg_buff/Grid"):GetComponent("UIGrid")
    local buff_values = TableMgr:GetSlgBuffDataToBuffValues(item.data.buffid)
    local count = item.buff_root.transform.childCount
    local cur = 0
    local buff_str
    if buff_values ~= nil then
        for i =1,#buff_values do
            cur = cur + 1
            if i>count then
                buff_str = NGUITools.AddChild(item.buff_root.gameObject, buff_prefab)
            else
                buff_str = item.buff_root.transform:GetChild(i-1)
            end
            local str = TextMgr:GetText(buff_values[i].buff_str) 
            if buff_values[i].value >= 0 then
                str = str .. " +"..buff_values[i].value.."%"
            else
                str = str ..buff_values[i].value.."%"
            end
            local cf = item.data.grade >= 100 and GovernmentData.ColorStr.RebelAtt or GovernmentData.ColorStr.OfficialAtt
            buff_str:GetComponent("UILabel").text = cf.. str..GovernmentData.ColorStr.End
            buff_str.gameObject:SetActive(true)
        end
    end

    if cur < count then

        for i=cur,count do
            buff_str = item.buff_root.transform:GetChild(i-1)
            buff_str.gameObject:SetActive(false)
        end
    end
    item.buff_root:Reposition()
    item.official_icon.mainTexture =  ResourceLibrary:GetIcon(GovernmentData.Official_icon_path, item.data.icon)
    local cf = item.data.grade >= 100 and GovernmentData.ColorStr.RebelName or GovernmentData.ColorStr.OfficialName
    item.official_name.text =cf.. TextMgr:GetText(item.data.name)..GovernmentData.ColorStr.End
    item.player_name.text = TextMgr:GetText("union_nounion")     
end


LoadUI = function()
    if AdminMode then
        _ui.titleLable.text = TextMgr:GetText("GOV_ui7") 
        _ui.adminBtnRoot.gameObject:SetActive(true)
        _ui.table.gameObject:SetActive(true)
        _ui.table_NoAdminMode.gameObject:SetActive(false)        
    else
        _ui.titleLable.text = TextMgr:GetText("GOV_ui10") 
        _ui.adminBtnRoot.gameObject:SetActive(false)

        _ui.table.gameObject:SetActive(false)
        _ui.table_NoAdminMode.gameObject:SetActive(true)        
    end
    local grid = _ui.officialGrids 
    if not AdminMode then
        grid = _ui.officialGridsNoAdmin
    end
    local officialData = TableMgr:GetGoveOfficialData()
    _ui.officials = {}
    for i =1,#officialData do
        local data = officialData[i]

        local item = {}
        item.msg = nil
        item.data = data    
        item.index = i
        
        local index = data.grade>=100 and #grid or data.grade
        local trf = grid[index].transform:Find(i)
        if trf == nil then
            item.obj = NGUITools.AddChild(grid[index].gameObject, _ui.itemPrefab)
            item.obj.name = i
        else
            item.obj = trf.gameObject
        end
        
        
        InitOfficialItem(item,_ui.buffPrefab)
        item.btn = item.obj.transform:Find("button"):GetComponent("UIButton")
        item.btn.normalSprite = AdminMode and "btn_1" or "btn_2"
        item.btn_label = item.obj.transform:Find("button/text"):GetComponent("UILabel")
        item.btn_label.text = AdminMode and TextMgr:GetText("GOV_ui10") or TextMgr:GetText("GOV_ui44")
        if data.grade >= 100 then
            item.btn_label.text = AdminMode and TextMgr:GetText("GOV_ui10") or TextMgr:GetText("GOV_ui61")
            item.btn.normalSprite = "btn_3"
        else
            item.btn_label.text = AdminMode and TextMgr:GetText("GOV_ui10") or TextMgr:GetText("GOV_ui44")
        end

        item.btn.gameObject:SetActive(false)
        item.cur_operation = nil
        item.operationCallBack = nil
        if AdminMode then
            item.cur_operation = officialOperationMode.DeposeOrEditPrivilege
        else
            item.cur_operation = officialOperationMode.Appoint
        end

        SetClickCallback(item.btn.gameObject,function()
            if item.cur_operation ~= nil then
                item.cur_operation(item,item.operationCallBack)
            end
        end)
        _ui.officials[data.id] = item
    end
    for i=1,#grid do
        grid[i]:Reposition ()
    end
    _ui.table.repositionNow = true
    _ui.table_NoAdminMode.repositionNow = true

    local flist = GovernmentData.GetOfficialList()
    for i=1,#flist.infos do
        local official = flist.infos[i]
        if _ui.officials[official.officialId] ~= nil then
            if official.charId ~= 0  then
                _ui.officials[official.officialId].msg = official
                _ui.officials[official.officialId].player_name.text = official.guildBanner ~="" and "["..official.guildBanner.."] "..official.charName or official.charName
                SetClickCallback(_ui.officials[official.officialId].player_name.gameObject,function()
                    OtherInfo.RequestShow(_ui.officials[official.officialId].msg.charId)
                end)
                if not AdminMode then
                    _ui.officials[official.officialId].btn.normalSprite =  "btn_1"
                    _ui.officials[official.officialId].btn_label.text = TextMgr:GetText("GOV_ui10")
                    _ui.officials[official.officialId].operationCallBack = function(xx)
                        LoadUI()
                        if setfinishColseCallback~=nil then
                            setfinishColseCallback(0)
                        end
                    end                    
                    _ui.officials[official.officialId].cur_operation = officialOperationMode.DeposeOrEditPrivilege

                --    _ui.officials[official.officialId].btn_label.text = TextMgr:GetText("GOV_ui43")
                else
                    _ui.officials[official.officialId].operationCallBack = function(xx)
                        LoadUI()
                        if setfinishColseCallback~=nil then
                            setfinishColseCallback(0)
                        end
                    end    
                end
            end
            if AdminMode then
                if official.charId ~= 0 and GovernmentData.EnableEditOfficial(official.charId,official.officialId)then                
                    _ui.officials[official.officialId].btn.gameObject:SetActive(true)
                end   
            else
                if GovernmentData.EnableEditOfficial(official.charId,official.officialId)then                
                    _ui.officials[official.officialId].btn.gameObject:SetActive(true)
                end  
            end          
        end
    end

    SetClickCallback(_ui.mask.gameObject,function()
        Hide()
    end)
    SetClickCallback(_ui.close.gameObject,function()
        Hide()
    end)    
    SetClickCallback(_ui.help.gameObject,function()
        GOV_Help.Show(GOV_Help.HelpModeType.OFFICEMODE)
    end)   
    
    SetClickCallback(_ui.btnList[1].gameObject,function()
        FloatText.ShowOn(_ui.btnList[1].gameObject,TextMgr:GetText("common_ui1"),Color.red)
    end)    
    SetClickCallback(_ui.btnList[2].gameObject,function()
        FloatText.ShowOn(_ui.btnList[2].gameObject,TextMgr:GetText("common_ui1"),Color.red)
    end)   
    SetClickCallback(_ui.btnList[3].gameObject,function()
        GOV_Tax.Show()
        --FloatText.ShowOn(_ui.btnList[3].gameObject,TextMgr:GetText("common_ui1"),Color.red)
    end)  

    if GovernmentData.IsPrivilegeValid(MapData_pb.GovernmentPrivilege_SendZoneMail,MainData.GetGOVPrivilege()) then
        SetClickCallback(_ui.btnList[4].gameObject,function()
            Mail.SimpleWriteTo(TextMgr:GetText("GOV_ui60"),function(type,param)
                if type == "SetGovInputName" then
                    if param == nil then
                        return
                    end
                    local collider = param.gameObject:GetComponent("BoxCollider")
                    if collider ~= nil then
                        collider.enabled = false
                    end
                end
                if type == "SetSendBtn" then
                    if param == nil then
                        return
                    end
                    SetClickCallback(param.gameObject , function(go)
                        if not MailNew.CheckMailVaild() then
                            return 
                        end
                        MailNew.SendGovMail()
                    end)
                end
            end)
        end)    
    else
        SetClickCallback(_ui.btnList[4].gameObject,function()
            FloatText.ShowOn(_ui.btnList[4].gameObject,TextMgr:GetText("GOV_ui63"),Color.red)
        end)   
    end      
end



function  Awake()
    _ui = {}
    _ui.itemPrefab = transform:Find("Container/bg_mid").gameObject
    _ui.buffPrefab = transform:Find("Container/buff (1)").gameObject
    _ui.mask = transform:Find("mask")
    _ui.close = transform:Find("Container/bg_frane/bg_top/btn_close")
    _ui.table = transform:Find("Container/bg_frane/bg_mid/Scroll View/Table"):GetComponent("UITable")
    _ui.table_NoAdminMode = transform:Find("Container/bg_frane/bg_mid/Scroll View (1)/Table"):GetComponent("UITable")
    _ui.help = transform:Find("Container/bg_frane/bg_top/btn_help")
    _ui.table.gameObject:SetActive(false)
    _ui.table_NoAdminMode.gameObject:SetActive(false)
    _ui.officialGrids = {}
    for i=1,4 do
        _ui.officialGrids[i] = transform:Find(OfficialTableNames[i]):GetComponent("UIGrid")
    end
    _ui.officialGridsNoAdmin = {}
    for i=1,4 do
        _ui.officialGridsNoAdmin[i] = transform:Find(OfficialTableNoAdminNames[i]):GetComponent("UIGrid")
    end
    _ui.adminBtnRoot = transform:Find("Container/bg_frane/bg_bottom")
    _ui.btnList = {}
    for i=1,4 do
        _ui.btnList[i] = transform:Find(BtnTableNames[i])
    end
    _ui.titleLable = transform:Find("Container/bg_frane/bg_top/title_left/Label"):GetComponent("UILabel")
    GovernmentData.AddGovRulingListener(DisposeGovRulingPush)
    LoadUI()
end

function Show(adminMode,appointCharId,_setfinishColseCallback)    
    GovernmentData.ReqGoveOfficialListData(function()
        setfinishColseCallback = _setfinishColseCallback
        AdminMode = adminMode
        AppointCharId = appointCharId
        Global.OpenUI(_M)
    end)
end

function Close()   
    setfinishColseCallback = nil
    GovernmentData.RemoveGovRulingListener(DisposeGovRulingPush)
    AdminMode = false 
    AppointCharId = -1
    _ui = nil
end
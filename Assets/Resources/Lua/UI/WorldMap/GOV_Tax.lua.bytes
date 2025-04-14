module("GOV_Tax", package.seeall)

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
    "Container/bg_frane/bg_bottom/button"
}

local OfficialGrades = {
    1,
    2,
    3,
    100,
}


local MainRate
local LoadUI = nil
local enableOnChange = false
function Hide()
    Global.CloseUI(_M)
end

function UpdateMainRate(item)
    if MainRate == nil then
        return false
    end
    local r = 0
    table.foreach(_ui.officials,function(i,offical)
        if offical.index ~= 1 then
            r  = r+math.floor( offical.texSlider.value*100+0.5)
        end
    end)
    
    local adjust = false
    if r < 0 then
        r = 0;
        adjust = true
    end

    if r > 100 then
        r = 100;
        adjust = true
    end

    MainRate.needUpdateChange = false
    local main = 100 - r
    MainRate.texSlider.value = (main)*0.01
    MainRate.needUpdateChange = true
    if adjust then
        r = 0
        table.foreach(_ui.officials,function(i,offical)
            if offical.index ~= item.index then
                r  = r+math.floor( offical.texSlider.value*100+0.5)
            end
        end)
        item.needUpdateChange = false
        item.texSlider.value = (100 - r)*0.01
        item.needUpdateChange = true
        return false
    end
    return true
end

function Sign(f)
    if f > 0 then
        return 1
    end
    if f < 0 then
        return -1
    end
    return 0
end

function UpdateOtherRate()
    if MainRate == nil then
        return false
    end 
    local remain = 100 - math.floor( MainRate.texSlider.value*100+0.5)
    --local r = 0
    local count = 0
    --local hcount = 0
    table.foreach(_ui.officials,function(i,offical)
        if offical.data.grade < 100 and offical.data.grade ~= 1 then
            count = count +1
            --local v =math.floor( offical.texSlider.value*100+0.5) 
            --if v ~= 0 then
            --    hcount = hcount +1
            --end
            --r  = r+v
        end
    end)

    local add = math.ceil(remain/count)
    local addTotal = 0
    local fillend = false
    --print("adddddddd  ",add,remain,count)
    table.foreach(_ui.officials,function(i,offical)
        if offical.data.grade < 100 and offical.data.grade ~= 1 then
            if not fillend then
                addTotal = addTotal + add
            else
                offical.needUpdateChange = false
                offical.texSlider.value = 0
                offical.needUpdateChange = true   
                return          
            end
            
            if addTotal >= remain then
                local _add = addTotal - remain 
                offical.needUpdateChange = false
                --print("RRRRRRRRRRRR   ",add -_add)
                offical.texSlider.value = (add -_add)*0.01
                offical.needUpdateChange = true 
                fillend = true          
            else
                offical.needUpdateChange = false
                --print("NNNNNNNNNN   ",add)
                offical.texSlider.value = (add)*0.01
                offical.needUpdateChange = true
            end
        end
    end)
    return true


    --[[
    local offset = (remain - r)
    
    if offset == 0 then
        return false
    end
    local f = Sign(offset)
    local inc = math.ceil(offset/(f>0 and count or hcount))
    if inc == 0 then
        inc = 1*f;
    end
    local fend = true
    --print("offset   ",offset,inc,f,count)
    table.foreach(_ui.officials,function(i,offical)
        if not fend then
            return
        end
        if offical.data.grade < 100 and offical.data.grade ~= 1 then
            if Sign(offset - inc)==0 or Sign(offset - inc) == f then
                offical.needUpdateChange = false
                --print("RRRRRRRRRRRR   ",math.floor( offical.texSlider.value*100+0.5)+inc,Sign(offset - inc),f)
                offical.texSlider.value = (math.floor( offical.texSlider.value*100+0.5)+inc)*0.01
                offical.needUpdateChange = true
                offset = offset - inc
            else
                --offical.needUpdateChange = false
                --offical.texSlider.value = (math.floor( offical.texSlider.value*100+0.5)+offset*-1)*0.01
                --print("bbbbbbbbbbbbbbbbbb   ",math.floor( offical.texSlider.value*100+0.5)+offset*-1,Sign(offset - inc),f)
                --offical.needUpdateChange = true
                fend = false
            end
        end
    end)
    return true
    ]]
end

function InitOfficialItem(item)
    item.official_icon = item.obj.transform:Find("official_icon"):GetComponent("UITexture")
    item.official_name=item.obj.transform:Find("official_icon/official_name"):GetComponent("UILabel")
    item.player_name=item.obj.transform:Find("official_icon/player_name"):GetComponent("UILabel")
    item.player_name.gameObject:AddComponent(typeof(UIEventListener))

    item.texPercentRoot= item.obj.transform:Find("bg_train_time")
    item.texSlider = item.obj.transform:Find("bg_train_time/bg_schedule/bg_slider"):GetComponent("UISlider")
    item.texPrecentText = item.obj.transform:Find("bg_train_time/bg_schedule/text_num"):GetComponent("UILabel")
    item.texPrecentAddBtn = item.obj.transform:Find("bg_train_time/btn_add")
    item.texPrecentSubBtn = item.obj.transform:Find("bg_train_time/btn_minus")
    item.texSliderBtn = item.obj.transform:Find("bg_train_time/bg_schedule/bg_btn_slider")

    item.official_icon.mainTexture =  ResourceLibrary:GetIcon(GovernmentData.Official_icon_path, item.data.icon)
    local cf = item.data.grade >= 100 and GovernmentData.ColorStr.RebelName or GovernmentData.ColorStr.OfficialName
    item.official_name.text =cf.. TextMgr:GetText(item.data.name)..GovernmentData.ColorStr.End
    item.player_name.text = TextMgr:GetText("union_nounion")    
    item.needUpdateChange = true
    item.OnSliderChange = function()
        local f = math.floor(item.texSlider.value*100+0.5)
        if not enableOnChange then
            item.rate = f
            item.texPrecentText.text = math.floor(item.texSlider.value*100+0.5).."%"
            return
        end
        if item.rate >= 0 then
            if item.index ~= 1 then
                if item.needUpdateChange then
                    if UpdateMainRate(item) then
                        item.rate = f
                    else
                        item.texPrecentText.text = math.floor(item.texSlider.value*100+0.5).."%"
                        return 
                    end
                end
            else
                if item.needUpdateChange then
                    UpdateOtherRate()
                end
                item.rate = f
            end
        else
            item.rate = f
        end
        if f ~= item.texSlider.value*100 then
            item.needUpdateChange = false
            item.texSlider.value = f*0.01
            item.needUpdateChange = true
            item.texPrecentText.text = math.floor(item.texSlider.value*100+0.5).."%"
            return
        end
        item.texPrecentText.text = math.floor(item.texSlider.value*100+0.5).."%"
    end

    item.OnClickAddBtn = function()
        local silder =  math.floor(item.texSlider.value*100+0.5)
        local v = silder+1
        if v >= 100 then
            v = 100
        end
        item.texSlider.value = v*0.01;
    end

    item.OnClickSubBtn = function()
        local silder =  math.floor(item.texSlider.value*100+0.5)
        local v = silder -1
        if v < 0 then
            v = 0
        end
        item.texSlider.value = v*0.01;
    end
    EventDelegate.Set(item.texSlider.onChange,EventDelegate.Callback(item.OnSliderChange))
    SetClickCallback(item.texPrecentAddBtn.gameObject,item.OnClickAddBtn)
    SetClickCallback(item.texPrecentSubBtn.gameObject,item.OnClickSubBtn)
end


local function ToRateList()
    local ratelist = {}

    local r = 0
    table.foreach(_ui.officials,function(i,v)
        if v ~= nil then
            if v.texSlider.value ~= 0 then
                local rl = {}
                rl.officialId = i
                rl.rate = math.floor(v.texSlider.value*100+0.5)
                r  = r+rl.rate 
                table.insert(ratelist,rl)
            end
        end
    end)
    print("SSSSSSSet total rate ",r);
    return r,ratelist
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
    local officialLocalData = {}
    for i =1,#officialData do
        officialLocalData[officialData[i].id] = officialData[i]
    end

    _ui.officials = {}
    local olist = GovernmentData.GetOfficialList()

    for i =1,#olist.infos do
        local official = olist.infos[i]
        local data = officialLocalData[official.officialId]
        if data ~= nil and official.officialId < 100 and official.charId ~= 0 then
            local item = {}
            item.msg = nil
            item.data = data   
            item.index = official.officialId 
            item.rate = -1
            local index = data.grade>=100 and #grid or data.grade
            local trf = grid[index].transform:Find(i)
            if trf == nil then
                item.obj = NGUITools.AddChild(grid[index].gameObject, _ui.itemPrefab)
                item.obj.name = i
            else
                item.obj = trf.gameObject
            end

            InitOfficialItem(item)
            if AdminMode then
                item.texSlider:GetComponent("BoxCollider").enabled = true
                item.texSliderBtn.gameObject:SetActive(true)
                item.texPrecentAddBtn.gameObject:SetActive(true)
                item.texPrecentSubBtn.gameObject:SetActive(true)
            else
                item.texSlider:GetComponent("BoxCollider").enabled = false
                item.texSliderBtn.gameObject:SetActive(false)
                item.texPrecentAddBtn.gameObject:SetActive(false)
                item.texPrecentSubBtn.gameObject:SetActive(false)            
            end
    
            _ui.officials[data.id] = item
            _ui.officials[official.officialId].msg = official
            _ui.officials[official.officialId].player_name.text = official.guildBanner ~="" and "["..official.guildBanner.."] "..official.charName or official.charName
            SetClickCallback(_ui.officials[official.officialId].player_name.gameObject,function()
                OtherInfo.RequestShow(_ui.officials[official.officialId].msg.charId)
            end)     
            if official.officialId == 1 then
                MainRate = _ui.officials[official.officialId]
            end       
        end
    end


    for i=1,#grid do
        grid[i]:Reposition ()
    end
    _ui.table.repositionNow = true
    _ui.table_NoAdminMode.repositionNow = true

    
    local flist = GovernmentData.GetTexRateInfo()
    for i=1,#flist.data do
        local data = flist.data[i]
        print(i,data.user.officialId,data.rate)

        if _ui.officials[data.user.officialId] ~= nil then
            _ui.officials[data.user.officialId].needUpdateChange = false
            _ui.officials[data.user.officialId].texSlider.value = data.rate/100   
            _ui.officials[data.user.officialId].needUpdateChange = true
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
        local r,ratelist = ToRateList()
        if r == 100 then
            GovernmentData.ReqSetGovTaxRate(ratelist,function() Hide() end)
        else
            MessageBox.Show(TextMgr:GetText("GOV_ui85"))
        end
        
    end)        
end



function  Awake()
    enableOnChange = false
    _ui = {}
    _ui.itemPrefab = transform:Find("Container/bg_mid").gameObject
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
    for i=1,#BtnTableNames do
        _ui.btnList[i] = transform:Find(BtnTableNames[i])
    end
    _ui.titleLable = transform:Find("Container/bg_frane/bg_top/title_left/Label"):GetComponent("UILabel")

    LoadUI()
end

function Update()
    enableOnChange = true
end


function Show(_setfinishColseCallback)    
    GovernmentData.ReqGovTaxRate(function()
        setfinishColseCallback = _setfinishColseCallback
        AdminMode = GovernmentData.IsPrivilegeValid(MapData_pb.GovernmentPrivilege_ManageRevenue,MainData.GetGOVPrivilege())
        Global.OpenUI(_M)
    end)
end

function Close()   
    setfinishColseCallback = nil
    AdminMode = false 
    MainRate = nil
    _ui = nil
end
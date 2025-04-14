module("SoliderUpgrade", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime
local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String

local _ui
local _ResList
local _Factor1 = 0
local _Factor2 = 0
local _CurSelectSoliderId
local _CurSelectSoliderLevel
local _CurSelectNum =0;
local _SoliderGroup
local _ArmyInfoMsg
local _SeUid
local _CurSelectIndex
local _CName
local RefrushCur
--Barrack.GetAramInfo(baseid,level)
--Barrack.RequestArmNum(callback)
local ResBarNames={[1]="food",[2]="iron",[3]="oil",[4]="electric",[5]="solider"}
local ResBarTypes={[1] = Common_pb.MoneyType_Food,[2] = Common_pb.MoneyType_Iron,[3] = Common_pb.MoneyType_Oil,[4] = Common_pb.MoneyType_Elec,[5] = -1}

function GetSoliderNum4LevelUp(solider_id,level)
    return Barrack.GetAramInfo(solider_id,level).Num 
end

function GetSoliderLevelupMaxCount(solider_id,level)
    local soldierData = TableMgr:GetBarrackData(solider_id, level)
    if soldierData == nil then
        return 0
    end
    local buildData = maincity.GetBuildingByID(soldierData.BarrackId)
    local maxNum = 0;
    if buildData ~= nil then
        local buildLevel = buildData.data.level
		local barrack_build_table = TableMgr:GetBarrackBuildDataTable()
        for _ , v in pairs(barrack_build_table) do
            if v.BuildID == soldierData.BarrackId and v.BuildLevel == buildLevel then
                maxNum = v.MaxNum 
                break;
            end
        end
    end
    return math.floor(maxNum*_Factor1)+_Factor2
end

function GetSoliderLevelUpData(solider_id,level)
    local levelupData = TableMgr:GetSoliderLevelupData(solider_id,level)
    if levelupData == nil then
        return nil
    end
    local resList = {}
    for v in string.gsplit(levelupData.LevelupConsume, ";") do
        local args = string.split(v, ":")
        local res ={}
        res.id = tonumber( args[1])
        res.count = tonumber(args[2])
        
        table.insert(resList,res)
    end 
    return resList
end

function GetMoneyTotal(type)
    return MoneyListData.GetMoneyByType(type);
end


local function CloseSelf()
    MoneyListData.RemoveListener(RefrushCur)
	Global.CloseUI(_M)
end

function Close()
    _ui = nil
end

function RequestCityArmyInfo(seUid,callback)
    local req = GuildMsg_pb.MsgGuildCityArmyInfoRequest()
    req.seUid = seUid
    LuaNetwork.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildCityArmyInfoRequest, req:SerializeToString(), function(typeId, data)
        local msg = GuildMsg_pb.MsgGuildCityArmyInfoResponse()
        msg:ParseFromString(data)
        Global.DumpMessage(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code) 
                       
        else
            _ArmyInfoMsg = msg
            if callback~=nil then
                callback()
            end
        end
    end, true)
end

function GetCurArmyRemain(solider_id,level)
    if _ArmyInfoMsg == nil then
        return 0
    end
    for i=1,#_ArmyInfoMsg.infos do
        if _ArmyInfoMsg.infos[i].armyId == solider_id and _ArmyInfoMsg.infos[i].armyLevel == level then
            return math.max(0,GetSoliderLevelupMaxCount(solider_id,level) - _ArmyInfoMsg.infos[i].curNum) 
        end
    end
    return 0
end

function UpdateCurArmyInfoNum(solider_id,level,addNum)
    if _ArmyInfoMsg == nil then
        return 
    end
    for i=1,#_ArmyInfoMsg.infos do
        if _ArmyInfoMsg.infos[i].armyId == solider_id and _ArmyInfoMsg.infos[i].armyLevel == level then
            _ArmyInfoMsg.infos[i].curNum = _ArmyInfoMsg.infos[i].curNum + addNum
            return 
        end
    end
    return 
end

function Show(name,seUid,soliderLevelUpCfg,soliderNumCfg)
    RequestCityArmyInfo(seUid,function()
        _SeUid = seUid
        _SoliderGroup = {}
        _CName = name
        for v in string.gsplit(soliderLevelUpCfg, ";") do
            local args = string.split(v, ":")
            local soliderTab ={}
            soliderTab.id = tonumber(args[1])
            soliderTab.level = tonumber(args[2])
            table.insert(_SoliderGroup,soliderTab)
        end 
        
        local args = string.split(soliderNumCfg, ";")
        _Factor1 = tonumber(args[1])
        _Factor2 = tonumber(args[2])
    
        Global.OpenUI(_M)
    end)
end

function UpdateLevelRes4Count(solider_id,level,num,remain)
    local totalLevelupCount = math.min(GetSoliderNum4LevelUp(_CurSelectSoliderId,_CurSelectSoliderLevel),
    math.min(GetSoliderLevelupMaxCount(_CurSelectSoliderId,_CurSelectSoliderLevel),remain))
    _ResList = GetSoliderLevelUpData(solider_id,level)
    for i =1,5 do
        if _ui.resourceBar[i].type<0 then
            local cur = num
            local target= totalLevelupCount
            _ui.resourceBar[i].state = cur <= target
            if not _ui.resourceBar[i].state then
                _ui.resourceBar[i].txt.text = "[ff0000]"..cur.."[ffffff]".."/"..target    
            else
                _ui.resourceBar[i].txt.text = cur.."/"..target    
            end  
        else
            if _ResList ~= nil then
                for j =1,#_ResList do
                    
                    if _ui.resourceBar[i].type ==  _ResList[j].id then
                        local cur = _ResList[j].count*num
                        local target= GetMoneyTotal(_ResList[j].id)
                        _ui.resourceBar[i].state = cur <= target
                        if not _ui.resourceBar[i].state then
                            _ui.resourceBar[i].txt.text = "[ff0000]"..cur.."[ffffff]".."/"..target    
                        else
                            _ui.resourceBar[i].txt.text = cur.."/"..target    
                        end  
                        break;
                    end
                end
            end
        end
    end
    _ui.input.text.text = num
    _ui.input.denom.text = "/"..totalLevelupCount
end

function UpdateLevelRes4Active(solider_id,level)
    _ResList = GetSoliderLevelUpData(solider_id,level)
    for i =1,5 do
        if _ui.resourceBar[i].type<0 then
            _ui.resourceBar[i].rootTrf.gameObject:SetActive(true)
        else
            if _ResList ~= nil then
                local vaild = false
                for j =1,#_ResList do
                    
                    if _ui.resourceBar[i].type ==  _ResList[j].id then
                        vaild = true
                        break;
                    end
                end
                _ui.resourceBar[i].rootTrf.gameObject:SetActive(vaild)
            else
                _ui.resourceBar[i].rootTrf.gameObject:SetActive(false)
            end
        end
    end
    _ui.resourceGrid:Reposition()
end


local function GetResource(id)
	AudioMgr:PlayUISfx("SFX_ui01", 1, false)
	local noitem = Global.BagIsNoItem(maincity.GetItemResList(id))
	if noitem then
		AudioMgr:PlayUISfx("SFX_ui02", 1, false)
		FloatText.Show(TextMgr:GetText("player_ui18"), Color.white)
		return
	end
	CommonItemBag.SetTittle(TextMgr:GetText("get_resource" .. (tonumber(id) - 2)))
	CommonItemBag.NotUseAutoClose()
	CommonItemBag.SetResType(id)
	CommonItemBag.SetItemList(maincity.GetItemResList(id), 0)
	CommonItemBag.SetUseFunc(maincity.UseResItemFunc)
	GUIMgr:CreateMenu("CommonItemBag" , false)
end

local function InputTextClickCallback(go)
    local remain = GetCurArmyRemain(_CurSelectSoliderId,_CurSelectSoliderLevel)
    local totalLevelupCount = math.min(GetSoliderNum4LevelUp(_CurSelectSoliderId,_CurSelectSoliderLevel),
    math.min(GetSoliderLevelupMaxCount(_CurSelectSoliderId,_CurSelectSoliderLevel),remain))
    if totalLevelupCount == 0 then
        return
    end    
	NumberInput.Show(_CurSelectNum, 0, totalLevelupCount, function(number)
        _CurSelectNum = number
        UpdateLevelRes4Count(_CurSelectSoliderId,_CurSelectSoliderLevel,_CurSelectNum,remain)
    end)
end

local function OnClickAddBtn()
	if _ui == nil then
		return
    end	
    local remain = GetCurArmyRemain(_CurSelectSoliderId,_CurSelectSoliderLevel)
    local totalLevelupCount = math.min(GetSoliderNum4LevelUp(_CurSelectSoliderId,_CurSelectSoliderLevel),
    math.min(GetSoliderLevelupMaxCount(_CurSelectSoliderId,_CurSelectSoliderLevel),remain))
    if totalLevelupCount == 0 then
        return
    end
	_ui.input.inputSilder.value = math.min( _CurSelectNum + 1,totalLevelupCount)/totalLevelupCount
end

local function OnClickDelBtn()
	if _ui == nil then
		return
    end	
    local remain = GetCurArmyRemain(_CurSelectSoliderId,_CurSelectSoliderLevel)
    local totalLevelupCount = math.min(GetSoliderNum4LevelUp(_CurSelectSoliderId,_CurSelectSoliderLevel),
    math.min(GetSoliderLevelupMaxCount(_CurSelectSoliderId,_CurSelectSoliderLevel),remain))
    if totalLevelupCount == 0 then
        return
    end    
	_ui.input.inputSilder.value = math.max( _CurSelectNum - 1,0)/totalLevelupCount 
end

local function OnHoldClickAddBtn(go)
	OnClickAddBtn()
end

local function OnHoldClickDelBtn(go)
	OnClickDelBtn()
end

function roundOff(num, n)
    if n > 0 then
    	local scale = math.pow(10, n-1)
        return math.floor(num / scale + 0.5) * scale
    elseif n < 0 then
    	local scale = math.pow(10, n)
    	return math.floor(num / scale + 0.5) * scale
    elseif n == 0 then
        return num
    end
end

local function OnSliderChange()
	if _ui == nil then
		return
    end	
    local remain = GetCurArmyRemain(_CurSelectSoliderId,_CurSelectSoliderLevel)
    local totalLevelupCount = math.min(GetSoliderNum4LevelUp(_CurSelectSoliderId,_CurSelectSoliderLevel),
    math.min(GetSoliderLevelupMaxCount(_CurSelectSoliderId,_CurSelectSoliderLevel),remain))

    _CurSelectNum = roundOff( totalLevelupCount * _ui.input.inputSilder.value,1)
	UpdateLevelRes4Count(_CurSelectSoliderId,_CurSelectSoliderLevel,_CurSelectNum,remain)
end

function InitGroup()
    if _SoliderGroup == nil then
        return;
    end
    for i =1,4 do
        if i <= #_SoliderGroup then
            local soliderData = Barrack.GetAramInfo(_SoliderGroup[i].id,_SoliderGroup[i].level)
            _ui.group[i].icon.mainTexture = ResourceLibrary:GetIcon ("Icon/Unit/", soliderData.SoldierIcon)
            _ui.group[i].rootTrf.gameObject:SetActive(true)
        else
            _ui.group[i].rootTrf.gameObject:SetActive(false)
        end
        _ui.group[i].select.gameObject:SetActive(false)
        SetClickCallback(_ui.group[i].rootTrf.gameObject,function()
            UpdateSelect(i)
        end)
    end
    _ui.groupGrid:Reposition()
end

function UpdateSelect(selectIndex)
    if _SoliderGroup == nil then
        return;
    end
    if(selectIndex > #_SoliderGroup) then
        return;
    end
    _CurSelectIndex = selectIndex
    for i =1,4 do
        _ui.group[i].select.gameObject:SetActive(false)
    end
    _ui.group[selectIndex].select.gameObject:SetActive(true)
    _CurSelectSoliderId = _SoliderGroup[selectIndex].id
    _CurSelectSoliderLevel = _SoliderGroup[selectIndex].level
    _CurSelectNum =0;
    _ui.input.inputSilder.value = 0
    local remain = GetCurArmyRemain(_CurSelectSoliderId,_CurSelectSoliderLevel)
    UpdateLevelRes4Active(_CurSelectSoliderId,_CurSelectSoliderLevel)
    UpdateLevelRes4Count(_CurSelectSoliderId,_CurSelectSoliderLevel,_CurSelectNum,remain)
    local soliderData = Barrack.GetAramInfo(_SoliderGroup[selectIndex].id,_SoliderGroup[selectIndex].level+1)
    _ui.display_text.text = TextMgr:GetText(soliderData.SoldierName)
    _ui.display.mainTexture = ResourceLibrary:GetIcon ("Icon/Unit/", soliderData.SoldierIcon)
    _ui.remain.text = System.String.Format(TextMgr:GetText("SoliderUpgrade_ui3"), remain) 
    _ui.des.text = System.String.Format(TextMgr:GetText("SoliderUpgrade_ui2"), _SoliderGroup[selectIndex].level,_SoliderGroup[selectIndex].level+1) 
end

local function OnLevelUp()

    if _CurSelectNum == 0 then
        return
    end
    if GameTime.GetSecTime() <= _ArmyInfoMsg.nextExchangeTime then
        FloatText.Show(TextMgr:GetText("SoliderUpgrade_ui5"))
        return
    end

    local req = GuildMsg_pb.MsgGuildCityExchangeArmyRequest()

    req.seUid = _SeUid
    req.armyId = _CurSelectSoliderId
    req.level = _CurSelectSoliderLevel
    req.num = _CurSelectNum

    LuaNetwork.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildCityExchangeArmyRequest, req:SerializeToString(), function(typeId, data)
        local msg = GuildMsg_pb.MsgGuildCityExchangeArmyResponse()
        msg:ParseFromString(data)

        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)    
        else
            UpdateCurArmyInfoNum(_CurSelectSoliderId,_CurSelectSoliderLevel,_CurSelectNum)
            _CurSelectNum = 0

            Barrack.RefreshArmNum(msg)

            UpdateSelect(_CurSelectIndex)
        end
    end, true)
end

RefrushCur = function()
    UpdateSelect(_CurSelectIndex)
end

function Awake()
    MoneyListData.AddListener(RefrushCur)	
    _ui = {}
    _ui.title = transform:Find("Container/bg_frane/bg_top/bg_title_left/title"):GetComponent("UILabel")
    _ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject


    _ui.resourceGrid =transform:Find("Container/bg_frane/right/bg_resource/Grid"):GetComponent("UIGrid")
    --
    _ui.resourceBar = {}
    for i =1,5 do
        local resAsset = {}
        resAsset.type = ResBarTypes[i]
        resAsset.rootTrf = transform:Find(System.String.Format("Container/bg_frane/right/bg_resource/Grid/bg_{0}", ResBarNames[i]))
        resAsset.txt = resAsset.rootTrf:Find(System.String.Format("txt_{0}", ResBarNames[i])):GetComponent("UILabel")
        resAsset.btn = resAsset.rootTrf:Find("get btn")
        resAsset.state = false
        _ui.resourceBar[i] = resAsset
    end

    _ui.input = {}

	_ui.input.inputSilder = transform:Find("Container/bg_frane/right/bg_train_time/bg_schedule/bg_slider"):GetComponent("UISlider")
	
    local inputText = transform:Find("Container/bg_frane/right/bg_train_time/frame_input")
    inputText.gameObject:SetActive(true)
    SetClickCallback(inputText.gameObject , InputTextClickCallback)
    _ui.input.text = transform:Find("Container/bg_frane/right/bg_train_time/frame_input/title"):GetComponent("UILabel")
	_ui.input.denom = transform:Find("Container/bg_frane/right/bg_train_time/frame_input/text_num"):GetComponent("UILabel")
	_ui.input.addBtn = transform:Find("Container/bg_frane/right/bg_train_time/btn_add"):GetComponent("UIButton")
    _ui.input.delBtn = transform:Find("Container/bg_frane/right/bg_train_time/btn_minus"):GetComponent("UIButton")

    _ui.group ={}
    _ui.groupGrid = transform:Find("Container/bg_frane/left/bg_select/Grid"):GetComponent("UIGrid")
    for i =1,4 do
        local groupAsset = {}
        groupAsset.rootTrf = transform:Find(System.String.Format("Container/bg_frane/left/bg_select/Grid/icon_solder ({0})", i))
        groupAsset.icon = groupAsset.rootTrf:Find("Texture"):GetComponent("UITexture")
        groupAsset.select = groupAsset.rootTrf:Find("select")
        
        _ui.group[i] = groupAsset
    end

    _ui.display = transform:Find("Container/bg_frane/back_full/solider"):GetComponent("UITexture")
    _ui.display_text = transform:Find("Container/bg_frane/left/bg_right_title/bg_right_text"):GetComponent("UILabel")
    _ui.remain = transform:Find("Container/bg_frane/right/text"):GetComponent("UILabel")
    _ui.des = transform:Find("Container/bg_frane/left/bg_des/text"):GetComponent("UILabel")
    _ui.levelupBtn = transform:Find("Container/bg_frane/right/button1")
end

function Start()
    SetClickCallback(_ui.btn_close, CloseSelf)
    for i =1,5 do
        if _ui.resourceBar[i].type>0 then
            SetClickCallback(_ui.resourceBar[i].btn.gameObject, function()
                GetResource(_ui.resourceBar[i].type)
            end)
        end
    end 
    SetClickCallback(_ui.levelupBtn.gameObject,OnLevelUp)
    SetClickCallback(_ui.input.addBtn.gameObject,OnClickAddBtn)
	_ui.input.addBtn.gameObject:GetComponent("UIHoldClick").OnHoldClick = OnHoldClickAddBtn
	SetClickCallback(_ui.input.delBtn.gameObject,OnClickDelBtn)
    _ui.input.delBtn.gameObject:GetComponent("UIHoldClick").OnHoldClick = OnHoldClickDelBtn
    EventDelegate.Set(_ui.input.inputSilder.onChange,EventDelegate.Callback(OnSliderChange))
    _ui.title.text = System.String.Format(TextMgr:GetText(SoliderUpgrade_ui4), _CName) 
    InitGroup()
    UpdateSelect(1)
end


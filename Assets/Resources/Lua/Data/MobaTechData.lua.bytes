module("MobaTechData", package.seeall)
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback

local eventListener = EventListener()

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

local mobaTech

local function MakeBonus(bonus, str)
    local temp = string.split(str, ",")
    local b = {}
    b.BonusType = tonumber(temp[1])
	b.Attype = tonumber(temp[2])
    b.Value = tonumber(temp[3])
    b.sign = true
	table.insert(bonus,b)
end

local function MakeBaseTable()
    --if mobaTech == nil then
        mobaTech = {}
        local data = TableMgr:GetMobaTech()
        for i, v in pairs(data) do
            if mobaTech[v.TechId] == nil then
                mobaTech[v.TechId] = {}
                mobaTech[v.TechId].step = {}
            end
            if mobaTech[v.TechId].step[v.PaceNeed] == nil or v.Level > mobaTech[v.TechId].step[v.PaceNeed] then
                mobaTech[v.TechId].step[v.PaceNeed] = v.Level
            end
            mobaTech[v.TechId][v.Level] = v
            v.bonus = {}
            v.bonus_text = {}
            if string.find(v.TechAttribute, ";") ~= nil then
                for ii, vv in ipairs(string.split(v.TechAttribute, ";")) do
                    MakeBonus(v.bonus, vv)
                end
            else
                MakeBonus(v.bonus, v.TechAttribute)
            end
            if string.find(v.Text, ";") ~= nil then
                for ii, vv in ipairs(string.split(v.Text, ";")) do
                    table.insert(v.bonus_text, vv)
                end
            else
                table.insert(v.bonus_text, v.Text)
            end
        end
        AttributeBonus.RegisterAttBonusModule(_M)
    --end
end

function CalAttributeBonus()
    if mobaTech == nil then
        return
    end
    local bonus = {}
    for i, v in pairs(mobaTech) do
        if v.data ~= nil and v.data.level > 0 then
            for ii, vv in ipairs(v[v.data.level].bonus) do
                table.insert(bonus, vv)
            end
        end
    end
    return bonus
end

function GetMobaTech()
    return mobaTech
end

function GetTechById(id)
    for i, v in pairs(mobaTech) do
        if v.data ~= nil and v.data.techid == id then
            return v
        end
    end
end

function GetTechLevelById(id)
    local tech = GetTechById(id)
    if tech ~= nil and tech.data ~= nil then
        return tech.data.level
    end
    return 0
end

local function SetData(data)
    MakeBaseTable()
    for i, v in pairs(data) do
        for ii, vv in pairs(mobaTech) do
            if ii == v.techid then
                vv.data = v
            end
        end
    end
end

local function UpdateTech(tech)
    for i, v in pairs(mobaTech) do
        if i == tech.techid then
            v.data = tech
        end
    end
end

function RequestMobaTechList()
    local req = MobaMsg_pb.MsgMobaTechListRequest()
    Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaTechListRequest, req, MobaMsg_pb.MsgMobaTechListResponse, function(msg)
        SetData(msg.tech)
        NotifyListener()
        UpdateUI()
    end, true)
end

function RequestMobaUpgradeTech(techId, buy)
    local req = MobaMsg_pb.MsgMobaUpgradeTechRequest()
    req.techId = techId
    req.useGold = buy
    Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaUpgradeTechRequest, req, MobaMsg_pb.MsgMobaUpgradeTechResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            UpdateTech(msg.tech)
            MainCityUI.UpdateRewardData(msg.fresh)
            NotifyListener()
            UpdateUI(techId)
            local techdata = mobaTech[techId]
			FloatText.Show(TextMgr:GetText(techdata[techdata.data.level].Name).."  LV."..msg.tech.level.."   "..TextMgr:GetText("build_ui39"), Color.green)
			if techId == 1 then 
				MobaActionListData.RequestData()
			end 
        else
        	Global.ShowError(msg.code)
        end
    end, true)
end

local target
function SetTarget(_target)
    target = _target
end

local _ui
function InitUI(transform)
    _ui = {}
    _ui.scrollview = transform:Find("Scroll View"):GetComponent("UIScrollView")
    _ui.grid = transform:Find("Scroll View/Grid"):GetComponent("UIGrid")
    _ui.list_item = transform:Find("list_1")
    UnityEngine.GameObject.DestroyImmediate(_ui.list_item:Find("item"):GetComponent("UISprite"))
    _ui.mask = MobaStore.transform:Find("mask"):GetComponent("UITexture")
    _ui.stepname = transform:Find("name"):GetComponent("UILabel")
    _ui.stepjindu = transform:Find("jindu"):GetComponent("UISlider")
    _ui.stepjindu_label = transform:Find("jindu/Label"):GetComponent("UILabel")
    _ui.setupStep = function()
        _ui.curstep = MobaData.GetMobaState()
        _ui.stepname.text = System.String.Format(TextMgr:GetText("ui_moba_112"), _ui.curstep)
        local begintime, endtime = MobaData.GetMobaStateStartEndTime()
        if Serclimax.GameTime.GetSecTime() < endtime then
            CountDown.Instance:Add("MobaTech", endtime, function(t)
                local now = Serclimax.GameTime.GetSecTime()
                if endtime <= now then
                    _ui.setupStep()
                    UpdateUI()
                end
                _ui.stepjindu.value = (now - begintime) / (endtime - begintime)
                _ui.stepjindu_label.text = System.String.Format(TextMgr:GetText("ui_moba_113"), t)
            end)
        end
    end
    _ui.setupStep()
    _ui.list_item.gameObject:SetActive(false)
    _ui.tech_list = {}
    for i, v in kpairs(mobaTech) do
        local item = {}
        item.transform = NGUITools.AddChild(_ui.grid.gameObject, _ui.list_item.gameObject).transform
        item.transform.gameObject:SetActive(true)
        item.name = item.transform:Find("name"):GetComponent("UILabel")
        item.texture = item.transform:Find("item/Texture"):GetComponent("UITexture")
        item.button = item.transform:Find("button").gameObject
        item.button_label = item.transform:Find("button/Label"):GetComponent("UILabel")
        item.hint = item.transform:Find("button_1"):GetComponent("UILabel")
        item.level_label = item.transform:Find("mid_sp/Label"):GetComponent("UILabel")
        item.level_current = item.transform:Find("mid_sp/number1 (1)"):GetComponent("UILabel")
        item.level_arrow = item.transform:Find("mid_sp/Sprite (1)").gameObject
        item.level_next = item.transform:Find("mid_sp/number2 (1)"):GetComponent("UILabel")
        item.level_max = item.transform:Find("mid_sp/max").gameObject
        item.grid = item.transform:Find("Scroll View/Grid"):GetComponent("UIGrid")
        item.grid_item = item.grid.transform:Find("Label")
        _ui.tech_list[i] = item

        SetClickCallback(item.texture.transform.parent.gameObject, function()
            _ui.desc_list:SetActive(true)
            _ui.desc_base.localPosition = _ui.desc_list.transform:InverseTransformPoint(item.texture.transform.position) + _ui.desc_base_offset
            _ui.desc_list_right = _ui.mask.localSize.x /2
            if _ui.desc_base.localPosition.x + _ui.desc_base_offset.x > _ui.desc_list_right then
                _ui.desc_base.localPosition = Vector3(_ui.desc_list_right - _ui.desc_base_offset.x, _ui.desc_base.localPosition.y, _ui.desc_base.localPosition.z)
            end
            local techdata = mobaTech[i]
            _ui.desc_name.text = TextMgr:GetText(techdata[techdata.data.level == 0 and 1 or techdata.data.level].Name)
            _ui.desc_desc.text = TextMgr:GetText(techdata[techdata.data.level == 0 and 1 or techdata.data.level].Desc)
            _ui.desc_tishi.text = TextMgr:GetText(techdata[techdata.data.level == 0 and 1 or techdata.data.level].Detail)
            local childCount = _ui.desc_grid.transform.childCount
            local index = 0
            for ii, vv in kpairs(techdata.step) do
                local gitem 
                if index < childCount then
                    gitem = _ui.desc_grid.transform:GetChild(index)
                else
                    gitem = NGUITools.AddChild(_ui.desc_grid.gameObject, _ui.desc_item.gameObject).transform
                end
                gitem.gameObject:SetActive(true)
                index = index + 1
                gitem:GetComponent("UILabel").text = System.String.Format(TextMgr:GetText("ui_moba_114"), ii, vv)
            end
            for ii = index, childCount - 1 do
                _ui.desc_grid.transform:GetChild(ii).gameObject:SetActive(false)
            end
            _ui.desc_grid:Reposition()
        end)
    end
    _ui.desc_list = transform:Find("desc_list").gameObject
    _ui.desc_base = transform:Find("desc_list/base")
    _ui.desc_base_offset = Vector3(_ui.desc_base:GetComponent("UISprite").localSize.x / 2, - _ui.desc_base:GetComponent("UISprite").localSize.y / 2, 0)
    _ui.desc_name = transform:Find("desc_list/base/name"):GetComponent("UILabel")
    _ui.desc_desc = transform:Find("desc_list/base/desc"):GetComponent("UILabel")
    _ui.desc_tishi = transform:Find("desc_list/base/tishi"):GetComponent("UILabel")
    _ui.desc_grid = transform:Find("desc_list/base/Grid"):GetComponent("UIGrid")
    _ui.desc_item = transform:Find("desc_list/base/Grid/Label")
    transform:Find("desc_list/base/Grid/Label/number1").gameObject:SetActive(false)
    SetClickCallback(_ui.desc_list, function()
        _ui.desc_list:SetActive(false)
    end)
    SetClickCallback(_ui.desc_base.gameObject, function()
        _ui.desc_list:SetActive(false)
    end)
end

function ReleaseUI()
    CountDown.Instance:Remove("MobaTech")
    _ui = nil
end

function UpdateUI(index)
    if _ui == nil then
        return
    end
    if index == nil then
        for i, v in kpairs(_ui.tech_list) do
            UpdateUI(i)
        end
        if target ~= nil then
            _ui.scrollview:MoveRelative(Vector3(-target * _ui.grid.cellWidth,0,0))
            target = nil
        end
    else
        local item = _ui.tech_list[index]
        local techdata = mobaTech[index]
        if techdata.data == nil or techdata.data.level == 0 then
            techdata.data = {}
            techdata.data.techid = index
            techdata.data.level = 0
            techdata.data.endtime = 0
            techdata.data.beginTime = 0
            techdata.data.originaltime = 0
            item.name.text = TextMgr:GetText(techdata[1].Name)
            item.texture.mainTexture = ResourceLibrary:GetIcon("Icon/Laboratory/", techdata[1].Icon)
        else
            item.name.text = TextMgr:GetText(techdata[techdata.data.level].Name)
            item.texture.mainTexture = ResourceLibrary:GetIcon("Icon/Laboratory/", techdata[techdata.data.level].Icon)
        end
        item.level_label.text = System.String.Format(TextMgr:GetText("ui_moba_50"), "")
        item.level_current.text = techdata.data.level
        item.level_next.text = techdata.data.level + 1
        item.level_arrow:SetActive(techdata.data.level == 0 or techdata.data.level < techdata[techdata.data.level].MaxLevel)
        item.level_next.gameObject:SetActive(techdata.data.level == 0 or techdata.data.level < techdata[techdata.data.level].MaxLevel)
        item.level_max:SetActive(techdata.data.level > 0 and techdata.data.level == techdata[techdata.data.level].MaxLevel)
        item.button:SetActive(techdata.data.level == 0 or (techdata.data.level < techdata[techdata.data.level].MaxLevel and techdata[techdata.data.level].PaceNeed < _ui.curstep))
        item.hint.gameObject:SetActive(techdata.data.level > 0 and techdata[techdata.data.level].PaceNeed >= _ui.curstep and techdata.data.level < techdata[techdata.data.level].MaxLevel)
        if techdata.data.level < techdata[techdata.data.level == 0 and 1 or techdata.data.level].MaxLevel then
            item.button_label.text = techdata[techdata.data.level + 1].NeedScore
            SetClickCallback(item.button, function()
                local isbuy = techdata[techdata.data.level + 1].NeedScore > MobaMainData.GetData().data.mobaScore
                if not isbuy then
                    RequestMobaUpgradeTech(index, false)
                else
                    MessageBox.Show(System.String.Format(TextMgr:GetText(Text.ui_moba_45), techdata[techdata.data.level + 1].NeedGold), function() 
                        RequestMobaUpgradeTech(index, true)
                    end, function() end)
                end
            end)
        else
            SetClickCallback(item.button, nil)
        end
        local updateAttr = function(data1, data2)
            local attrNum = data1 ~= nil and #data1.bonus or #data2.bonus
            for x = 1, attrNum do
                local gItem
                if x == 1 then
                    gItem = item.grid_item
                else
                    if x - 1 < item.grid.transform.childCount then
                        gItem = item.grid.transform:GetChild(x - 1)
                    else
                        gItem = NGUITools.AddChild(item.grid.gameObject, item.grid_item.gameObject).transform
                    end
                end
                gItem:GetComponent("UILabel").text = data1 ~= nil and TextMgr:GetText(data1.bonus_text[x]) or TextMgr:GetText(data2.bonus_text[x])
                local label1 = gItem:Find("number1"):GetComponent("UILabel")
                label1.text = data1 ~= nil and (data1.bonus[x].Value .. (Global.IsHeroPercentAttrAddition(data1.bonus[x].Attype) and "%" or "")) or 0
                local arrow = gItem:Find("Sprite").gameObject
                arrow:SetActive(data2 ~= nil)
                local label2 = gItem:Find("number2"):GetComponent("UILabel")
                label2.gameObject:SetActive(data2 ~= nil)
                label2.text = data2 ~= nil and (data2.bonus[x].Value .. (Global.IsHeroPercentAttrAddition(data2.bonus[x].Attype) and "%" or "")) or ""
                if (data2 ~= nil and data2.bonus[x].Value == 0) or (data1 ~= nil and data1.bonus[x].Value == 0) then
                    if index == 9 then
                        gItem:GetComponent("UILabel").text = data1 ~= nil and TextMgr:GetText(data1.bonus_text[x]) or TextMgr:GetText("Moba_Tech9_4")
                    else
                        gItem:GetComponent("UILabel").text = data2 ~= nil and TextMgr:GetText(data2.bonus_text[x]) or TextMgr:GetText(data1.bonus_text[x])
                    end
                    label1.gameObject:SetActive(false)
                    arrow:SetActive(false)
                    label2.gameObject:SetActive(false)
                end
            end
        end
        updateAttr(techdata[techdata.data.level], techdata[techdata.data.level + 1])
    end
end
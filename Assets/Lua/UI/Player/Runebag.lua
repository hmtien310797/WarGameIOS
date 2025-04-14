module("Runebag", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String
local _ui, _tab, _select, _selectedId
local UpdateTab, GetTabData, InitItemList, UpdateItem, UpdateRightContent, UpdateMoney, UpdateSelectLevel

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

function Awake()
    _ui = {}
    _ui.Container = transform:Find("Container").gameObject
    _ui.btn_close = transform:Find("Container/bg_frane/close btn").gameObject
    _ui.page1 = transform:Find("Container/left/page1").gameObject
    _ui.page2 = transform:Find("Container/left/page2").gameObject
    _ui.page3 = transform:Find("Container/left/page3").gameObject
    _ui.page4 = transform:Find("Container/left/page4").gameObject
    _ui.scroll1 = transform:Find("Container/left/content1/Scroll View"):GetComponent("UIScrollView")
    _ui.grid1 = transform:Find("Container/left/content1/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.label1 = transform:Find("Container/left/page1/selected effect/Label"):GetComponent("UILabel")
    _ui.lable2 = transform:Find("Container/left/page2/selected effect/Label"):GetComponent("UILabel")
    _ui.lable3 = transform:Find("Container/left/page3/selected effect/Label"):GetComponent("UILabel")
    _ui.lable4 = transform:Find("Container/left/page4/selected effect/Label"):GetComponent("UILabel")
    _ui.item = ResourceLibrary.GetUIPrefab("Rune/myrunes")
    _ui.button1 = transform:Find("Container/left/button1").gameObject
    --_ui.attrinfo = transform:Find("Container/right/content1/info/text2").gameObject
    --_ui.button_decompoms = transform:Find("Container/right/content2/info/button1").gameObject
    _ui.debrisLabel = transform:Find("Container/left/fragment_icon/Label"):GetComponent("UILabel")
    _ui.debris_icon = transform:Find("Container/left/fragment_icon/Sprite").gameObject
    
    --[[_ui.right_content1_texture = transform:Find("Container/right/content1/Texture"):GetComponent("UITexture")
    _ui.right_content1 = transform:Find("Container/right/content1")
    _ui.right_content1_grid = transform:Find("Container/right/content1/info/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.right_content2 = transform:Find("Container/right/content2")
    _ui.right_content1_name = transform:Find("Container/right/content1/Texture/name"):GetComponent("UILabel")
    _ui.right_content1_button1 = transform:Find("Container/right/content1/button1").gameObject
    _ui.right_content1_button1_label = transform:Find("Container/right/content1/button1/gold/Label (1)"):GetComponent("UILabel")
    _ui.right_content1_button2 = transform:Find("Container/right/content1/button2").gameObject
    _ui.right_content1_button2_label = transform:Find("Container/right/content1/button2/gold/Label (1)"):GetComponent("UILabel")

    _ui.right_content2_grid = transform:Find("Container/right/content2/info/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.right_content2_textitem = transform:Find("Container/right/content2/info/rune_text")
    _ui.right_content2_search = transform:Find("Container/right/content2/info/search").gameObject]]

    _ui.selectlist = {}
    for i = 1, 5 do
        local selectlv = {}
        selectlv.go = transform:Find(string.format("Container/left/selectlevel/%d", i)).gameObject
        selectlv.select = selectlv.go.transform:Find("select").gameObject
        SetClickCallback(selectlv.go, function()
            if _ui.selectedLevel == i then
                _ui.selectedLevel = 0
            else
                _ui.selectedLevel = i
            end
            UpdateSelectLevel()
        end)
        _ui.selectlist[i] = selectlv
    end
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

local function ResetSelectLevel()
    for i, v in ipairs(_ui.selectlist) do
        v.select:SetActive(false)
    end
    _ui.selectedLevel = 0
end

local function CloseSelf()
    Global.CloseUI(_M)
end

function Start()
    _select = 0
    _selectedId = 0
    SetClickCallback(_ui.Container,CloseSelf)
    SetClickCallback(_ui.btn_close,CloseSelf)
    SetClickCallback(_ui.button1, function()
        Sellmultiplerunes.Show(_ui.tabRunes)
    end)
    --[[SetClickCallback(_ui.button_decompoms,function()
        Sellmultiplerunes.Show(_ui.tabRunes)
    end)
    SetClickCallback(_ui.right_content1_button1,function()
        Sellitem.Show(_selectedId)
    end)
    SetClickCallback(_ui.right_content2_search,function()
        Selectrunes.Show(function(list)
            _ui.selectlist = list
            UpdateSelectLevel()
        end)
    end)]]
    _ui.tableData = RuneData.GetRuneTableData()  --获取全部数据

    SetClickCallback(_ui.page1, function()  --点击页签1，获得type1刷新列表
        UpdateTab(1)
    end)
    SetClickCallback(_ui.page2, function()  --点击页签2，获得type2刷新列表
        UpdateTab(2)
    end)
    SetClickCallback(_ui.page3, function()  --点击页签3，获得type3刷新列表
        UpdateTab(3)
    end)
    SetClickCallback(_ui.page4, function()  --点击页签4，获得type4刷新列表
        UpdateTab(4)
    end)

    UIUtil.SetClickCallback(_ui.debris_icon, function(go)
        if go == _ui.tipObject then
            _ui.tipObject = nil
        else
            _ui.tipObject = go
            local itemData = TableMgr:GetItemData(20)
            Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
        end
    end)
    --[[SetClickCallback(_ui.right_content1_button2, function()
        if _ui.leftItemList[_selectedId].num > 0 then
            if _ui.leftItemList[_selectedId].tableData.Level <= 3 then
                RuneData.RequestDecomposeRune(table.remove(_ui.tabRunes.uidlist[_selectedId]))
            else
                MessageBox.Show(TextMgr:GetText("ui_rune_33"), function()
                    RuneData.RequestDecomposeRune(table.remove(_ui.tabRunes.uidlist[_selectedId]))
                end, function() end)
            end
        else
            MessageBox.Show(TextMgr:GetText("ui_rune_34"))
        end
    end)]]
    UpdateTab(1)
    RuneData.AddListener(UpdateItem)
    MoneyListData.AddListener(UpdateMoney)
end

GetTabData = function(tab)
    local data = {}
    for i, v in kpairs(_ui.tableData) do     --在全部数据中循环
        if tab == 1 or v.RuneType == tab - 1 then   --如果数据为全部则都显示，否则就分层显示
            table.insert(data, v)   --在表中插入数据v
        end
    end
    return data 
end

local function UpdateSelect(index, id)
    --if _select == index then
    --    _select = 0
    --    _selectedId = 0
    --else
        _select = index
        _selectedId = id
    --end
    for i, v in pairs(_ui.leftItemList) do
        v.select:SetActive(_select == v.index)
    end
    --UpdateRightContent()
end

UpdateSelectLevel = function()
    --[[if _ui.selectlist == nil then
        return
    end]]
    for i, v in ipairs(_ui.selectlist) do
        v.select:SetActive(_ui.selectedLevel == i)
    end
    for i, v in pairs(_ui.leftItemList) do
        v.gameObject:SetActive(_ui.selectedLevel == 0 or _ui.selectedLevel == v.tableData.Level)
    end
    _ui.grid1.repositionNow = true
    coroutine.start(function()
        coroutine.step()
        _ui.scroll1:ResetPosition()
    end)
end

UpdateMoney = function()
    _ui.debrisLabel.text = MoneyListData.GetRuneChip()
end

UpdateItem = function()
    _ui.tabRunes = {}
    _ui.tabRunes.total = {}
    _ui.tabRunes.items = {}
    _ui.tabRunes.totalSelect = {}
    _ui.tabRunes.totalDebris = {}
    for i = 1, 5 do
        _ui.tabRunes.total[i] = 0
        _ui.tabRunes.items[i] = {}
        _ui.tabRunes.totalDebris[i] = 0
    end
    local runes, runenums, uidlist = RuneData.GetUnwearedRunes(_tab - 1)
    _ui.tabRunes.uidlist = uidlist
    for i, v in pairs(_ui.leftItemList) do
        v.num = 0
        v.number.text = String.Format(TextMgr:GetText("ui_worldmap_70"), 0)
        v.mask:SetActive(true)
    end
    for i, v in pairs(runenums) do
        _ui.leftItemList[i].num = v
        _ui.leftItemList[i].number.text = String.Format(TextMgr:GetText("ui_worldmap_70"), v)
        _ui.leftItemList[i].mask:SetActive(false)
        local item = {}
        item.tableData = _ui.leftItemList[i].tableData
        item.itemData = _ui.leftItemList[i].itemData
        item.num = v
        _ui.tabRunes.totalDebris[item.tableData.Level] = _ui.tabRunes.totalDebris[item.tableData.Level] + (item.tableData.Recycling.num * v)
        _ui.tabRunes.total[item.tableData.Level] = _ui.tabRunes.total[item.tableData.Level] + v
        _ui.tabRunes.totalSelect[item.tableData.Level] = _ui.tabRunes.total[item.tableData.Level]
        table.insert(_ui.tabRunes.items[item.tableData.Level], item)
    end
    Sellmultiplerunes.SetData(_ui.tabRunes)
    Buyrunes.SetData(_ui.tabRunes)

    --[[local childCount = _ui.right_content2_grid.transform.childCount
    for i = 1, 5 do
        local itemTransform 
        if i - 1 < childCount then
            itemTransform = _ui.right_content2_grid.transform:GetChild(i - 1)
        else
            itemTransform = NGUITools.AddChild(_ui.right_content2_grid.gameObject, _ui.right_content2_textitem.gameObject).transform
        end
        itemTransform.gameObject:SetActive(true)
        itemTransform:GetComponent("UILabel").text = TextMgr:GetText("ui_rune_" .. (35 + i))
	    itemTransform:GetChild(0):GetComponent("UILabel").text = _ui.tabRunes.total[i]
    end
    _ui.right_content2_grid:Reposition()]]
end

UpdateRightContent = function()
    if _select == 0 then

    else
        RuneData.SetAttributeList(_selectedId, _ui.right_content1_grid, _ui.attrinfo)
        _ui.right_content1_texture.mainTexture = ResourceLibrary:GetIcon("item/", _ui.leftItemList[_selectedId].itemData.icon)
        _ui.right_content1_name.text =TextMgr:GetText(_ui.leftItemList[_selectedId].itemData.name)
        local rdata = RuneData.GetRuneTableData(_selectedId)
        _ui.right_content1_button1_label.text = rdata.NeedMaterial.num
        _ui.right_content1_button2_label.text = rdata.Recycling.num
        UIUtil.SetBtnEnable(_ui.right_content1_button2:GetComponent("UIButton"), "btn_3", "btn_4", _ui.leftItemList[_selectedId].num > 0)
    end
    _ui.right_content1.gameObject:SetActive(_select > 0)
    _ui.right_content2.gameObject:SetActive(_select == 0)
end

InitItemList = function(_transform, data, index)
    local _temp = {}
    _temp.gameObject = _transform.gameObject
    _temp.texture = _transform:Find("Texture"):GetComponent("UITexture")
    _temp.name = _transform:Find("Texture/name"):GetComponent("UILabel")
    _temp.attrinfos = {}
    for i = 1, 3 do
        _temp.attrinfos[i] = _transform:Find(string.format("Texture/text%d", i))
        _temp.attrinfos[i].gameObject:SetActive(false)
    end
    _temp.select = _transform:Find("select").gameObject
    _temp.number = _transform:Find("number"):GetComponent("UILabel")
    _temp.number.text = 0
    _temp.num = 0
    _temp.index = index
    _temp.tableData = data
    _temp.itemData = TableMgr:GetItemData(data.id)
    _temp.texture.mainTexture = ResourceLibrary:GetIcon("item/" , _temp.itemData.icon)
    _temp.mask = _transform:Find("none").gameObject
    _temp.name.text = TextMgr:GetText(_temp.itemData.name)
    for i = 1, 3 do
        if _temp.tableData.RuneAttribute[i] ~= nil then
            _temp.attrinfos[i].gameObject:SetActive(true)
            RuneData.SetContentItemData(_temp.attrinfos[i], _temp.tableData.RuneAttribute[i])
        end
    end
    SetClickCallback(_temp.gameObject, function()
        UpdateSelect(index, data.id)
        Buyrunes.Show(data.id, _ui.tabRunes)
    end)
    _ui.leftItemList[data.id] = _temp
end

UpdateTab = function(tab)
    _tab = tab
    _ui.leftItemList = {}
    local tabdata = GetTabData(tab)
    local childCount = _ui.grid1.transform.childCount   --grid下的子集类
    for i, v in ipairs(tabdata) do
        local itemTransform 
        if i - 1 < childCount then  --池中存放item的数据
            itemTransform = _ui.grid1.transform:GetChild(i - 1)
        else
            itemTransform = NGUITools.AddChild(_ui.grid1.gameObject, _ui.item).transform
        end
        itemTransform.gameObject:SetActive(true)
        InitItemList(itemTransform, v, i)
    end
    for i = #tabdata, childCount - 1 do     --超出长度后进行销毁
        GameObject.Destroy(_ui.grid1.transform:GetChild(i).gameObject)
        --_ui.grid1.transform:GetChild(i).gameObject:SetActive(false)
    end
    _ui.grid1:Reposition()
    _ui.scroll1:ResetPosition()
    ResetSelectLevel()
    --UpdateSelect(0)
    UpdateItem()
    UpdateMoney()
end

function Show()
    Global.OpenUI(_M)
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    _ui = nil
    RuneData.RemoveListener(UpdateItem)
    MoneyListData.RemoveListener(UpdateMoney)
end

function Hide()
	 _ui = nil
	Global.CloseUI(_M)
end
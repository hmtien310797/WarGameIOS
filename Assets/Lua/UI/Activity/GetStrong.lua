module("GetStrong",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local PlayerPrefs = UnityEngine.PlayerPrefs
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local _ui, baseTable

function Hide()
	Global.CloseUI(_M)
end

local function CloseSelf()
	Global.CloseUI(_M)
end

function Close()
	_ui = nil
end

function Show()
    FunctionListData.RequestListData(function()
        Global.OpenUI(_M)
        GUIMgr:CloseMenu("MainInformation")
        GUIMgr:CloseMenu("setting")
    end)
end

local function UpdateList(index)
    if _ui.curtab == index then
        return
    end
    while _ui.grid.transform.childCount > 0 do
        GameObject.DestroyImmediate(_ui.grid.transform:GetChild(0).gameObject)
    end
    for i, v in pairs(baseTable[index].data) do
        local item
        if v.progressfunction ~= "" then
            item = NGUITools.AddChild(_ui.grid.gameObject, _ui.item1.gameObject).transform
            local func = "return " .. v.progressfunction
            local progress = math.min(Global.GetTableFunction(func)(), 1)
            item:Find("bg_list/exp bar"):GetComponent("UISlider").value = progress
            local rate = ""
            for ii, vv in ipairs(string.msplit(v.rate, ";", ":")) do
                if progress >= tonumber(vv[1]) then
                    rate = vv[2]
                end
            end
            item:Find("bg_list/exp bar/num"):GetComponent("UILabel").text = math.floor(progress * 100 + 0.5) .. "%"
            item:Find("bg_list/exp bar/rate"):GetComponent("UILabel").text = TextMgr:GetText(rate)
        else
            item = NGUITools.AddChild(_ui.grid.gameObject, _ui.item2.gameObject).transform
            item:Find("bg_list/text_des"):GetComponent("UILabel").text = TextMgr:GetText(v.description)
        end
        item:Find("bg_list/text_name"):GetComponent("UILabel").text = TextMgr:GetText(v.name)
        item:Find("bg_list/bg_icon/Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/GetStrong/", v.icon)
        local btn = item:Find("bg_list/btn_go").gameObject
        if v.checklockfunction ~= "" then
            local func = "return " .. v.checklockfunction
            local isunlocked = Global.GetTableFunction(func)()
            UIUtil.SetBtnEnable(btn:GetComponent("UIButton") ,"btn_1", "btn_4", isunlocked)
            if isunlocked then
                SetClickCallback(btn, function()
                    CloseSelf()
                    ActivityGrow.ExtraGuide(v.jumpfunction)
                    Starwars.RequestGameLog(66, v.jumpfunction)
                end)
            else
                local expbar = item:Find("bg_list/exp bar")
                if expbar ~= nil then
                    expbar.gameObject:SetActive(false)
                end
                SetClickCallback(btn, function()
                    local func = "return " .. v.lockshowfunction
                    local text = Global.GetTableFunction(func)()
                    FloatText.ShowAt(btn.transform.position, text, Color.white)
                end)
            end
        else
            SetClickCallback(btn, function()
                CloseSelf()
                ActivityGrow.ExtraGuide(v.jumpfunction)
                Starwars.RequestGameLog(66, v.jumpfunction)
            end)
        end
    end
    _ui.grid:Reposition()
    _ui.scrollView:ResetPosition()
    _ui.curtab = index
end

local function UpdateSelect(index)
    for i, v in pairs(_ui.leftBtns) do
        v.xuanzhong:SetActive(index == i)
        if index == i then
            UpdateList(v.parentId)
        end
    end
end

function Awake()
    _ui = {}
    _ui.btn_close = transform:Find("Container/background/close btn").gameObject
    _ui.mask = transform:Find("mask").gameObject

    _ui.bg_rate = transform:Find("Container/content/bg_top/rate/bg_rate"):GetComponent("UISprite")
    _ui.rate = transform:Find("Container/content/bg_top/rate/bg_rate/rate"):GetComponent("UITexture")
    _ui.combat = transform:Find("Container/content/bg_top/rate/combat"):GetComponent("UILabel")
    _ui.recommand = transform:Find("Container/content/bg_top/rate/recommand"):GetComponent("UILabel")

    _ui.left_grid = transform:Find("Container/content/bg_left/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.left_tab = transform:Find("Container/content/bg_left/Scroll View/Grid/tab1")

    _ui.scrollView = transform:Find("Container/content/Scroll View"):GetComponent("UIScrollView")
    _ui.grid = transform:Find("Container/content/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.item1 = transform:Find("Container/list_todo")
    _ui.item2 = transform:Find("Container/list_todo_s")

    _ui.checkbox = transform:Find("Container/content/bg_hint/checkbox"):GetComponent("UIToggle")

    if baseTable == nil then
        baseTable = {}
        for i, v in kpairs(tableData_tGetStrong.data) do
            if baseTable[v.parentId] == nil then
                baseTable[v.parentId] = {}
                baseTable[v.parentId].data = {}
            end
            if v.parentBtn == 1 then
                baseTable[v.parentId].btn = v.name
            else
                table.insert(baseTable[v.parentId].data, v)
            end
        end
    end
end

function Start()
    SetClickCallback(_ui.btn_close, CloseSelf)
    SetClickCallback(_ui.mask, CloseSelf)
    Starwars.RequestGameLog(66, 1)
    SetClickCallback(_ui.checkbox.gameObject, function()
        PlayerPrefs.SetInt("GetStrong" .. MainData.GetCharId(), _ui.checkbox.value and 1 or 0)
        PlayerPrefs.Save()
        Starwars.RequestGameLog(66, 2)
        MainCityUI.UpdateGetStrong()
    end)

    local combat = MainData.GetFight()
    _ui.combat.text = System.String.Format(TextMgr:GetText("ui_Bestrong_2"), combat)
    local mLevel = maincity.GetBuildingLevelByID(1)
    local combatdata = tableData_tForceEvaluation.data[mLevel]
    _ui.recommand.text = System.String.Format(TextMgr:GetText("ui_Bestrong_3"), mLevel, combatdata.recommend)
    local rate = "4"
    for i, v in ipairs(string.msplit(combatdata.evaluation, ";", ":")) do
        if combat >= tonumber(v[1]) then
            rate = v[2]
        end
    end
    _ui.rate.mainTexture = ResourceLibrary:GetIcon("Icon/Activity/", "rate_" .. rate)
    _ui.bg_rate.spriteName = "bg_rate" .. (tonumber(rate) == 0 and 3 or (tonumber(rate) == 1 and 2 or 1))

    local index = 0
    _ui.leftBtns = {}
    for i, v in kpairs(baseTable) do
        local btn = {}
        if index < _ui.left_grid.transform.childCount then
            btn.transform = _ui.left_grid.transform:GetChild(index)
        else
            btn.transform = NGUITools.AddChild(_ui.left_grid.gameObject, _ui.left_tab.gameObject).transform
        end
        index = index + 1
        btn.transform:Find("txt_get"):GetComponent("UILabel").text = TextMgr:GetText(v.btn)
        btn.transform:Find("btn_xuanzhong/txt_get (1)"):GetComponent("UILabel").text = TextMgr:GetText(v.btn)
        btn.redpoint = btn.transform:Find("redpoint").gameObject
        btn.xuanzhong = btn.transform:Find("btn_xuanzhong").gameObject
        btn.parentId = i
        SetClickCallback(btn.transform.gameObject, function()
            UpdateSelect(i)
        end)
        _ui.leftBtns[i] = btn
    end
    _ui.left_grid:Reposition()
    UpdateSelect(1)
    _ui.checkbox.value = UnityEngine.PlayerPrefs.GetInt("GetStrong" .. MainData.GetCharId()) == 1
end
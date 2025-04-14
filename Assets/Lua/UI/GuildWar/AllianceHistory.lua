module("AllianceHistory", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local SetTooltipCallback = UIUtil.SetTooltipCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime
local GameObject = UnityEngine.GameObject

local _ui

function Hide()
	Global.CloseUI(_M)
end

local function CloseSelf()
	Global.CloseUI(_M)
end

function Close()
	_ui = nil
end

local function UpdateList(index)
    if _ui.curtab == index then
        return
    end
    while _ui.grid.transform.childCount > 0 do
        GameObject.DestroyImmediate(_ui.grid.transform:GetChild(0).gameObject)
    end
    if _ui.infolist == nil then
        return
    end
    local curlist
    for i, v in pairs(_ui.infolist) do
        if v.session == index then
            curlist = v.data
        end
    end
    if curlist == nil then
        return
    end
    for i, v in pairs(curlist) do
        local item = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject).transform
        item:Find("bg_list/bg_name/name"):GetComponent("UILabel").text = string.format("[%s]%s", v.guildbanner, v.guildname)
        item:Find("bg_list/text_name"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("ui_unionwar_19"), v.groupindex)
        item:Find("bg_list/sever_name"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("ui_unionwar_20"), v.zonename)
        local badge = {}
        UnionBadge.LoadBadgeObject(badge, item:Find("bg_list/champion_icon/union_icon"))
        UnionBadge.LoadBadgeById(badge, v.guildbadge)
    end
    _ui.grid:Reposition()
    _ui.scrollView:ResetPosition()
    _ui.curtab = index
    _ui.scrollView:MoveRelative(Vector3(0,-5,0))
end

local function UpdateSelect(index)
    for i, v in pairs(_ui.leftBtns) do
        v.xuanzhong:SetActive(index == i)
        if index == i then
            UpdateList(v.parentId)
        end
    end
end

local function SetupLeft()
    _ui.left_tab.gameObject:SetActive(true)
    local index = 0
    _ui.leftBtns = {}
    for i, v in pairs(_ui.infolist) do
        local btn = {}
        if index < _ui.left_grid.transform.childCount then
            btn.transform = _ui.left_grid.transform:GetChild(index)
        else
            btn.transform = NGUITools.AddChild(_ui.left_grid.gameObject, _ui.left_tab.gameObject).transform
        end
        index = index + 1
        btn.transform:Find("txt_get"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("ui_unionwar_18"), v.session)
        btn.transform:Find("btn_xuanzhong/txt_get (1)"):GetComponent("UILabel").text = String.Format(TextMgr:GetText("ui_unionwar_18"), v.session)
        btn.redpoint = btn.transform:Find("redpoint").gameObject
        btn.xuanzhong = btn.transform:Find("btn_xuanzhong").gameObject
        btn.parentId = v.session
        SetClickCallback(btn.transform.gameObject, function()
            UpdateSelect(v.session)
        end)
        _ui.leftBtns[v.session] = btn
    end
    _ui.left_grid:Reposition()
    UpdateSelect(_ui.last)
end

function Awake()
    _ui = {}
    _ui.btn_close = transform:Find("Container/background/btn_close").gameObject
    _ui.mask = transform:Find("mask").gameObject

    _ui.left_grid = transform:Find("Container/content/bg_left/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.left_tab = transform:Find("Container/content/bg_left/Scroll View/Grid/tab1")

    _ui.scrollView = transform:Find("Container/content/Scroll View"):GetComponent("UIScrollView")
    _ui.grid = transform:Find("Container/content/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.item = transform:Find("Container/list_todo")
end

function Start()
    _ui.left_tab.gameObject:SetActive(false)
    SetClickCallback(_ui.btn_close, CloseSelf)
    SetClickCallback(_ui.mask, CloseSelf)
end

function Show()
    if Global.ACTIVE_GUILD_MOBA then
        UnionMobaActivityData.RequestMobaGlobalChampion(function(msg)
            if _ui ~= nil then
                _ui.infolist = {}
                local templist = {}
                _ui.last = 1
                table.sort(msg.infos, function(a, b)
                    return a.session > b.session
                end)
                for i, v in ipairs(msg.infos) do
                    if templist[v.session] == nil then
                        templist[v.session] = {}
                        templist[v.session].session = v.session
                        templist[v.session].data = {}
                    end
                    table.insert(templist[v.session].data, v)
                    if v.session > _ui.last then
                        _ui.last = v.session
                    end
                end
                for i, v in pairs(templist) do
                    table.insert(_ui.infolist, v)
                end
                table.sort(_ui.infolist, function(a, b)
                    return a.session > b.session
                end)
                SetupLeft()
            end
        end, Hide)
    end
    Global.OpenUI(_M)
end
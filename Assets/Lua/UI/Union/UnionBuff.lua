module("UnionBuff", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local Format = System.String.Format
local SetClickCallback = UIUtil.SetClickCallback

local _ui
local timer = 0
local ranklist = {5, 11, 12, 13, 14}

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function LoadUI()
    for i, v in ipairs(ranklist) do
        local unionprivilege = TableMgr:GetUnionPrivilege(v)
        local uniontec = UnionTechData.GetUnionTechById(unionprivilege.TechId)
        _ui.rankbufflist[v].unlocklabel.gameObject:SetActive(uniontec.level < unionprivilege.TechLevel)
        local unionTecData = UnionTec.GetUnionTechByID(unionprivilege.TechId)
        _ui.rankbufflist[v].unlocklabel.text = Format(TextMgr:GetText(Text.Union_tech_official), TextMgr:GetText(unionTecData.BaseData.Name), unionprivilege.TechLevel)
        _ui.rankbufflist[v].activation:SetActive(uniontec.level >= unionprivilege.TechLevel)
        local buffBaseData = TableMgr:GetSlgBuffData(unionprivilege.BuffId)
        _ui.rankbufflist[v].bufflabel.text = TextUtil.GetSlgBuffTitle(buffBaseData)
    end
    local unionteclist = UnionTec.GetHasedTech()
    for i, v in ipairs(unionteclist) do
        local label = NGUITools.AddChild(_ui.grid.gameObject, _ui.attrlabel.gameObject):GetComponent("UILabel")
        label.gameObject:SetActive(true)
        label.text = TextMgr:GetText(v.Dese) .. v.NumberShow
    end
    _ui.emptyObject:SetActive(#unionteclist == 0)

    _ui.grid.repositionNow = true
end

function Awake()
    _ui = {}
    _ui.prisonerPrefab = ResourceLibrary.GetUIPrefab("Jail/list_prisoner")
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/close btn")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)
end

function Start()
    _ui.rankbufflist = {}
    for i, v in ipairs(ranklist) do
        _ui.rankbufflist[v] = {}
        _ui.rankbufflist[v].namelabel = transform:Find(string.format("Container/content 1/r%d/Label", v)):GetComponent("UILabel")
        _ui.rankbufflist[v].rank = transform:Find(string.format("Container/content 1/r%d/rank", v)):GetComponent("UISprite")
        _ui.rankbufflist[v].bufflabel = transform:Find(string.format("Container/content 1/r%d/buff text", v)):GetComponent("UILabel")
        _ui.rankbufflist[v].unlocklabel = transform:Find(string.format("Container/content 1/r%d/unlock", v)):GetComponent("UILabel")
        _ui.rankbufflist[v].activation = transform:Find(string.format("Container/content 1/r%d/activation", v)).gameObject
    end
    _ui.grid = transform:Find("Container/content 2/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.attrlabel = transform:Find("Container/content 2/Scroll View/Grid/Label")
    _ui.attrlabel.gameObject:SetActive(false)
    _ui.btn_go = transform:Find("Container/tech_btn").gameObject
    _ui.emptyObject = transform:Find("Container/content 2/Sprite").gameObject
    UIUtil.SetClickCallback(_ui.btn_go, UnionTec.Show)
    LoadUI()
end

function Close()
    _ui = nil
end

function Show()
    Global.OpenUI(_M)
end

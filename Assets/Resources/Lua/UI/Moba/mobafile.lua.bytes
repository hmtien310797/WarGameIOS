module("mobafile", package.seeall)

local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr.Instance
local TextMgr = Global.GTextMgr
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local GuideMgr = Global.GGuideManager
local ResourceLibrary = Global.GResourceLibrary
local NGUITools = NGUITools
local AudioMgr = Global.GAudioMgr
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local _ui, _data, _charid

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

local function CloseSelf()
    Global.CloseUI(_M)
end

function Hide()
	Global.CloseUI(_M)
end

function Close()
    _ui = nil
    _data = nil
end

function Awake()
    _ui = {}
    _ui.mask = transform:Find("mask").gameObject
    _ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject

    _ui.stars = {}
    for i = 1, 6 do
        local staritem = {}
        staritem.bg = transform:Find(string.format("Container/bg_frane/mid/right/stars/bg (%d)", i)).gameObject
        staritem.star = transform:Find(string.format("Container/bg_frane/mid/right/stars/bg (%d)/star", i)).gameObject
        if i == 6 then
            staritem.num = transform:Find(string.format("Container/bg_frane/mid/right/stars/bg (%d)/NUMBER", i)):GetComponent("UILabel")
        end
        _ui.stars[i] = staritem
    end

    _ui.rank_icon = transform:Find("Container/bg_frane/mid/right/now"):GetComponent("UITexture")
    _ui.rank_name = transform:Find("Container/bg_frane/mid/right/rankname"):GetComponent("UILabel")

    _ui.hide = transform:Find("Container/bg_frane/mid/hide").gameObject
    _ui.btn = transform:Find("Container/bg_frane/mid/history").gameObject
    _ui.hint = transform:Find("Container/bg_frane/mid/bg_hint").gameObject
    _ui.check = transform:Find("Container/bg_frane/mid/bg_hint/checkbox"):GetComponent("UIToggle")

    _ui.rate = transform:Find("Container/bg_frane/mid/myrate"):GetComponent("UILabel")

    _ui.battlecount = transform:Find("Container/bg_frane/mid/bg/info/1/1"):GetComponent("UILabel")
    _ui.firstcount = transform:Find("Container/bg_frane/mid/bg/info/1/2"):GetComponent("UILabel")
    _ui.maxscore = transform:Find("Container/bg_frane/mid/bg/info/1/3"):GetComponent("UILabel")

    _ui.totalkill = transform:Find("Container/bg_frane/mid/bg/info/1 (1)/1"):GetComponent("UILabel")
    _ui.totaldead = transform:Find("Container/bg_frane/mid/bg/info/1 (1)/2"):GetComponent("UILabel")
    _ui.reputation = transform:Find("Container/bg_frane/mid/bg/info/1 (1)/3"):GetComponent("UILabel")
end

function Start()
    SetClickCallback(_ui.mask, CloseSelf)
    SetClickCallback(_ui.btn_close, CloseSelf)
    SetClickCallback(_ui.btn, function()
        Mobahistory.Show(_charid)
    end)
    SetClickCallback(_ui.check.gameObject, function()
        MobaData.RequestMobaHideRecord(_ui.check.value, function()
            _ui.check.value = not _ui.check.value
        end)
    end)
    local data = _data
    if data.info.level == 0 then
        data.info.level = 1
    end
    local rankData = TableMgr:GetMobaRankDataByID(data.info.level)
    _ui.rank_icon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "Moba/", rankData.RankIcon)
    _ui.rank_name.text = TextMgr:GetText(rankData.RankName)
    if rankData.RankStar <= 5 then
        for i = 1, rankData.RankStar do
            _ui.stars[i].bg:SetActive(true)
            _ui.stars[i].star:SetActive(i <= data.info.star)
            UIUtil.SetStarPos(_ui.rank_icon, _ui.stars[i].bg, rankData.RankStar, i, 103, 33)
        end
        for i = rankData.RankStar + 1, 5 do
            _ui.stars[i].bg:SetActive(false)
        end
        _ui.stars[6].bg:SetActive(false)
    else
        for i = 1, 5 do
            _ui.stars[i].bg:SetActive(false)
        end
        _ui.stars[6].bg:SetActive(true)
        _ui.stars[6].num.text = data.info.star
    end

    if _charid == MainData.GetCharId() then
        _ui.hide:SetActive(false)
        _ui.btn:SetActive(true)
        _ui.hint:SetActive(true)
        _ui.check.value = data.info.hiderecord
    else
        _ui.hide:SetActive(data.info.hiderecord)
        _ui.btn:SetActive(not data.info.hiderecord)
        _ui.hint:SetActive(false)
    end

    local total = data.info.wincount + data.info.losecount + data.info.tiecount
    _ui.rate.text = System.String.Format(TextMgr:GetText("ui_moba_19"), total == 0 and 0 or math.floor(data.info.wincount / total * 100 + 0.5) .. "%")

    _ui.battlecount.text = System.String.Format(TextMgr:GetText("ui_moba_22"), data.info.battlecount)
    _ui.firstcount.text = System.String.Format(TextMgr:GetText("ui_moba_23"), data.info.firstcount)
    _ui.maxscore.text = System.String.Format(TextMgr:GetText("ui_moba_24"), data.info.maxscore)

    _ui.totalkill.text = System.String.Format(TextMgr:GetText("ui_moba_25"), data.info.totalkill)
    _ui.totaldead.text = System.String.Format(TextMgr:GetText("ui_moba_26"), data.info.totaldead)
    _ui.reputation.text = System.String.Format(TextMgr:GetText("ui_moba_27"), 0, 0)
end

function Show(charid, data)
    Global.DumpMessage(data, "d:/dddd.lua")
    _data = data
    _charid = charid
    Global.OpenUI(_M)
end
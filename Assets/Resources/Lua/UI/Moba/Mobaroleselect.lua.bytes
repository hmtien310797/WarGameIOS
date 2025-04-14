module("Mobaroleselect", package.seeall)

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
local PlayerPrefs = UnityEngine.PlayerPrefs

local _ui

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

local function ShowGuide()
    if PlayerPrefs.GetInt("MobaMapGuide"..MainData.GetCharId()) ~= 1 then
        ActivityGrow.ExtraGuide(9008)
    end
end

local function ShowCountdown()
    coroutine.start(function()
        if GUIMgr:IsMenuOpen("MobaMain") then
            MobaMain.transform:Find("time").gameObject:SetActive(true)
            coroutine.wait(3.5)
            MobaMain.transform:Find("time").gameObject:SetActive(false)
            MobaData.SetMobaState(-2)
			ShowGuide()
        end
    end)
end

function Close()
    ActivityGrow.BrakeGuide()
    CountDown.Instance:Remove("Mobaroleselect")
    _ui = nil
    ShowCountdown()
end

function Awake()
    _ui.mask = transform:Find("mask").gameObject
    _ui.btn_close = transform:Find("Container/bg/close btn").gameObject
    _ui.btn_close:SetActive(false)
    _ui.btn = transform:Find("Container/bg/button"):GetComponent("UIButton")
    _ui.grid = transform:Find("Container/bg/mid/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.item = transform:Find("Container/bg/mid/list")
    _ui.time = transform:Find("Container/bg/time"):GetComponent("UILabel")
end

local function UpdateSelect(index)
    if _ui.RoleInfos == nil then 
        return
    end
    for i, v in ipairs(_ui.RoleInfos) do
        v.select:SetActive(index == i)
        v.select_kuang:SetActive(index == i)
        v.number.text = System.String.Format(TextMgr:GetText("ui_moba_130"), _ui.numbers[i] .. "/" .. v.maxnum)
    end
end

function Start()
    UIUtil.SetBtnEnable(_ui.btn ,"btn_2", "btn_4", false)
    SetClickCallback(_ui.btn.gameObject, function()
        UIUtil.SetBtnEnable(_ui.btn ,"btn_2", "btn_4", false)
    end)
    _ui.RoleInfos = {}
    for i, v in ipairs(tableData_tMobaRole.data) do
        local info = {}
        info.transform = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject).transform
        info.tabledata = v
        info.icon = info.transform:Find("icon"):GetComponent("UISprite")
        info.icon.spriteName = "Mobaroleselect_" .. i
        info.select = info.transform:Find("icon/select").gameObject
        info.select_kuang = info.transform:Find("select_kuang").gameObject
        info.number = info.transform:Find("icon/number"):GetComponent("UILabel")
        info.grid = info.transform:Find("title/Grid"):GetComponent("UIGrid")
        info.item = info.transform:Find("title/text_list")
        info.name = info.transform:Find("name"):GetComponent("UILabel")
        info.name.text = TextMgr:GetText(v.Name)
        info.maxnum = v.MaxNum
        info.select:SetActive(false)
        info.select_kuang:SetActive(false)
        info.number.text = ""

        local adds = v.description
        if string.find(adds, ";") ~= nil then
            adds = string.split(adds, ";")
            for ii, vv in ipairs(adds) do
                NGUITools.AddChild(info.grid.gameObject, info.item.gameObject).transform:GetComponent("UILabel").text = TextMgr:GetText(vv)
            end
        else
            NGUITools.AddChild(info.grid.gameObject, info.item.gameObject).transform:GetComponent("UILabel").text = TextMgr:GetText(adds)
        end
        info.grid:Reposition()
        info.item.gameObject:SetActive(false)

        SetClickCallback(info.transform.gameObject, function()
            if _ui.msg.endTime - 5 >= Serclimax.GameTime.GetSecTime() then
                MobaData.RequestMobaPickRole(i, function()
                    if _ui == nil then
                        return
                    end
                    if _ui.selfRoleId == nil or _ui.selfRoleId ~= i then
                        UIUtil.SetBtnEnable(_ui.btn ,"btn_2", "btn_4", true)
                        _ui.selfRoleId = i
                    end
                    --UpdateSelect(i)
                end)
            end
        end)
        table.insert(_ui.RoleInfos, info)
    end

    _ui.grid:Reposition()
    _ui.time.text = ""
    UpdateInfo(_ui.msg)
    if PlayerPrefs.GetInt("MobaRole"..MainData.GetCharId()) ~= 1 then
        ActivityGrow.ExtraGuide(9007)
    end
end

function UpdateInfo(msg)
    if _ui == nil then
        return
    end
    _ui.numbers = {}
    for i = 1, 4 do
        _ui.numbers[i] = 0
    end
    local charid = MainData.GetCharId()
    for i, v in ipairs(msg.info.users) do
        if v.roleid ~= nil and v.roleid > 0 then
            _ui.numbers[v.roleid] = _ui.numbers[v.roleid] + 1
            if v.charId == charid then
                UpdateSelect(v.roleid)
            end
        end
    end
    if _ui.RoleInfos ~= nil then
        for i, v in ipairs(_ui.RoleInfos) do
            v.number.text = System.String.Format(TextMgr:GetText("ui_moba_130"), _ui.numbers[i] .. "/" .. v.maxnum)
        end
    end

    CountDown.Instance:Add("Mobaroleselect", msg.endTime, function(t)
        local now = Serclimax.GameTime.GetSecTime()
        if msg.endTime >= now then
            if _ui.time ~= nil then
                _ui.time.text = t
            end
        else
            CloseSelf()
        end
    end)
end

function Show()
    MobaData.RequestMobaRoleInfo(function(msg)
        if msg.endTime >= Serclimax.GameTime.GetSecTime() then
            _ui = {}
            _ui.msg = msg
            Global.OpenUI(_M)
        else
            ShowGuide()
        end
    end)
end
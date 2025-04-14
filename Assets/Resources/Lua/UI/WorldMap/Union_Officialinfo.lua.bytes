module("Union_Officialinfo", package.seeall)
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
function Hide()
    Global.CloseUI(_M)
end

local function LoadUI()
    local officialData = _ui.officialData
    _ui.officialIcon.mainTexture = ResourceLibrary:GetIcon("Icon/Government/", officialData.icon)
    _ui.nameLabel.text = TextMgr:GetText(officialData.name)
    _ui.playerLabel.text = string.format("[%s]%s", _ui.guildBanner, _ui.charName) 
    City_lord.LoadOfficialBuff(officialData.buffid, _ui.buffGrid, _ui.buffPrefab)
end

function Awake()
    _ui = {}
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    local confirmButton = transform:Find("Container/bg_frane/bg_bottom/button")
    local mask = transform:Find("mask")
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)
    UIUtil.SetClickCallback(confirmButton.gameObject, Hide)
    UIUtil.SetClickCallback(mask.gameObject, Hide)

    _ui.buffPrefab = transform:Find("Container/buff (1)").gameObject
    _ui.officialIcon = transform:Find("Container/bg_frane/bg_mid/official_icon"):GetComponent("UITexture")
    _ui.nameLabel = transform:Find("Container/bg_frane/bg_mid/official_icon/official_name"):GetComponent("UILabel")
    _ui.playerLabel = transform:Find("Container/bg_frane/bg_mid/official_icon/player_name"):GetComponent("UILabel")
    _ui.buffGrid = transform:Find("Container/bg_frane/bg_mid/bg_buff/Grid"):GetComponent("UIGrid")
end

function Close()
    _ui = nil
end

function Show(officialData, guildBanner, charName)
    Global.OpenUI(_M)
    _ui.officialData = officialData
    _ui.guildBanner = guildBanner
    _ui.charName = charName
    LoadUI()
end

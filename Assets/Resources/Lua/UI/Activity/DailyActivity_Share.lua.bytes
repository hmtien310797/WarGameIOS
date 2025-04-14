module("DailyActivity_Share", package.seeall)
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

function CloseSelf()
	Global.CloseUI(_M)
end

function CloseAll()
	CloseSelf()
	DailyActivity.CloseSelf()
end

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    Tooltip.HideItemTip()
end

function LoadUI()
    _ui.shareTexture.mainTexture = ResourceLibrary:GetIcon("Background/", ShareCommon.GetShareTextureName())
    local rewardId = 100145
    local dropId = tonumber(tableData_tGlobal.data[rewardId].value)
    ShareCommon.LoadRewardList(_ui, _ui.gridTransform, dropId)
    local shareText = TextMgr:GetText(Text.share_2)
    local serverTime = GameTime.GetSecTime()
    local day = math.floor((serverTime - MainData.GetCreationTime()) / (24 * 3600))
    local fight = MainData.GetFight()
    
    _ui.shareLabel.text = Format(shareText, day, fight, _ui.myRank)
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local container = transform:Find("Container")
    UIUtil.SetClickCallback(mask.gameObject, CloseAll)
    --UIUtil.SetClickCallback(container.gameObject, CloseAll)
    _ui.shareTexture = transform:Find("Container/content/bg_frane/Texture"):GetComponent("UITexture")
    _ui.gridTransform = transform:Find("Container/content/reward/base/Scroll View/Grid")
    _ui.shareLabel = transform:Find("Container/content/Label"):GetComponent("UILabel")
    _ui.shareButton = transform:Find("Container/content/reward/base/button2"):GetComponent("UIButton")
    SetClickCallback(_ui.shareButton.gameObject, function(go)
        ShareCommon.Share(2)
    end)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    _ui = nil
end

function Show(myRank)
    Global.OpenUI(_M)
    _ui.myRank = myRank
    LoadUI()
end

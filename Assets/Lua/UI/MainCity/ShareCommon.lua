module("ShareCommon", package.seeall)
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
local shareTextureName

function GetShareTextureName()
    if shareTextureName == nil then
        shareTextureName = "share_" .. math.random(4)
    end
    return shareTextureName
end

function Hide()
    Global.CloseUI(_M)
    MainCityUI.LoginAwardGo()
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

function LoadRewardList(ui, gridTransform, dropId, itemScale)
    NGUITools.DestroyChildren(gridTransform)
	local itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    local heroPrefab = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")

    local dropShowList = TableMgr:GetDropShowData(dropId)
    for i, v in ipairs(dropShowList) do
        local contentType = v.contentType
        local contentId = v.contentId
        if contentType == 1 then
            local item = {}
            local itemTransform = NGUITools.AddChild(gridTransform.gameObject, itemPrefab).transform
            if itemScale ~= nil then
                itemTransform.localScale = itemScale
            end
            UIUtil.LoadItemObject(item, itemTransform)
            local itemData = TableMgr:GetItemData(contentId)
            local itemCount = v.contentNumber
            UIUtil.LoadItem(item, itemData, itemCount)
            UIUtil.SetClickCallback(item.transform.gameObject, function(go)
                if go == ui.tipObject then
                    ui.tipObject = nil
                else
                    ui.tipObject = go
                    Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)})
                end
            end)
        elseif contentType == 3 then
            local heroTransform = NGUITools.AddChild(gridTransform.gameObject, heroPrefab).transform
            heroTransform.localScale = Vector3(0.6,0.6,1)
            local hero = {}

            HeroList.LoadHeroObject(hero, heroTransform)
            local heroData = TableMgr:GetHeroData(contentId)
            local heroMsg = Common_pb.HeroInfo() 
            heroMsg.star = v.star
            heroMsg.level = v.level
            heroMsg.num = 1
            HeroList.LoadHero(hero, heroMsg, heroData)
            hero.nameLabel.gameObject:SetActive(false)

            SetClickCallback(hero.btn.gameObject, function(go)
                if go == ui.tipObject then
                    ui.tipObject = nil
                else
                    ui.tipObject = go
                    Tooltip.ShowItemTip({name = TextMgr:GetText(heroData.nameLabel), text = TextMgr:GetText(heroData.description)})
                end
            end)
        end
    end
end

function Share(shareType)
    local shareUrl = ""
	platformType = GUIMgr:GetPlatformType()
	if UnityEngine.Application.isEditor then
		platformType = LoginMsg_pb.AccType_adr_efun
	end

	if platformType == LoginMsg_pb.AccType_adr_efun then
	    shareUrl = "https://play.google.com/store/apps/details?id=com.weywell.wgame.efunkoudai.se"
	elseif platformType == LoginMsg_pb.AccType_ios_efun or platformType == LoginMsg_pb.AccType_ios_india then
	    shareUrl = "https://itunes.apple.com/app/id1358222570"
	end
	print("shareUrl#############", shareUrl)
    GUIMgr:SendMessageToSocial(2, 1, "标题", "说明", "图片url", shareUrl)

    local function ShareCallback(param)
        print("##############################ShareCallback", param)
        local req = ClientMsg_pb.MsgShareFacebookRequest()
        req.shareType = shareType
        Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgShareFacebookRequest, req, ClientMsg_pb.MsgShareFacebookResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                MainCityUI.UpdateRewardData(msg.fresh)
                Global.ShowReward(msg.reward)
                MainData.RequestData()
                DailyActivity.RemoveWeeklyShare()
            else
                Global.ShowError(msg.code)
            end
        end, true)
    end
	RemoveDelegate(GUIMgr, "onSocialCallback", ShareCallback)
    AddDelegate(GUIMgr, "onSocialCallback", ShareCallback)
    ShareCallback()
end

function LoadUI()
    _ui.shareTexture.mainTexture = ResourceLibrary:GetIcon("Background/", GetShareTextureName())
    local shareType = _ui.shareType
    local rewardId = shareType == 3 and 100144 or 100145
    local dropId = tonumber(tableData_tGlobal.data[rewardId].value)
    LoadRewardList(_ui, _ui.gridTransform, dropId)
    SetClickCallback(_ui.shareButton.gameObject, function(go)
        Share(shareType)
    end)
end

local function CancelShare()
    Hide()
end

function Awake()
    _ui = {}
    local mask = transform:Find("mask")
    local cancelButton = transform:Find("Container/bg_frane/button1")
    UIUtil.SetClickCallback(mask.gameObject, CancelShare)
    UIUtil.SetClickCallback(cancelButton.gameObject, CancelShare)
    _ui.shareTexture = transform:Find("Container/bg_frane/Texture"):GetComponent("UITexture")
    _ui.gridTransform = transform:Find("Container/bg_frane/reward/Scroll View/Grid")
    _ui.shareButton = transform:Find("Container/bg_frane/button2"):GetComponent("UIButton")
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Close()
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Tooltip.HideItemTip()
    if _ui.shareType == 2 then
        MainCityUI.CheckWeelyShareNotice()
    end
    _ui = nil
end

function Show(shareType)
    Global.OpenUI(_M)
    _ui.shareType = shareType
    LoadUI()
end

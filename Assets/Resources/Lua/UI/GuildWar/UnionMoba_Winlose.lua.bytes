module("UnionMoba_Winlose", package.seeall)

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
local GameObject = UnityEngine.GameObject

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
    GameObject.Destroy(transform.gameObject)
    Close()
end

function Hide()
    CloseSelf()
end

function Close()
    _ui = nil
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Awake()
    _ui = {}
    _ui.win = {}
    _ui.win.gameObject = transform:Find("guild_win").gameObject
    _ui.win.mask = transform:Find("guild_win/bg/mask").gameObject
    _ui.win.grid = transform:Find("guild_win/rewards/Scroll View/Grid"):GetComponent("UIGrid")

    _ui.fail = {}
    _ui.fail.gameObject = transform:Find("guild_fail").gameObject
    _ui.fail.mask = transform:Find("guild_fail/mask").gameObject
    _ui.fail.grid = transform:Find("guild_fail/rewards/Scroll View/Grid"):GetComponent("UIGrid")

    transform:Find("reward").gameObject:SetActive(false)

    _ui.item = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    _ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
    
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    Start()
end

function Start()
    SetClickCallback(_ui.win.mask, function()
        CloseSelf()
        Mobaconclusion.Show(UnionMobaActivityData.GetMobaUserResult())
    end)
    SetClickCallback(_ui.fail.mask, function()
        CloseSelf()
        Mobaconclusion.Show(UnionMobaActivityData.GetMobaUserResult())
    end)

    _ui.data = UnionMobaActivityData.GetMobaUserResult()
    if _ui.data == nil then
        print("结果数据木有！！！")
        return
    end
    
    for i, v in ipairs(_ui.data.userlist.users) do
        if v.charid == MainData.GetCharId() then
            _ui.selfResult = v
        end
    end
    if _ui.selfResult == nil then
        print("自己的结果木有！！！")
        return
    end
    _ui.win.gameObject:SetActive(_ui.selfResult.win == 1)
    _ui.fail.gameObject:SetActive(_ui.selfResult.win == -1)
    _ui.grid = _ui.selfResult.win == 1 and _ui.win.grid or _ui.fail.grid

    if _ui.data.reward.hero.hero then
        for i, v in ipairs(_ui.data.reward.hero.hero) do
            local heroData = TableMgr:GetHeroData(v.baseid)
            local hero = NGUITools.AddChild(_ui.grid.gameObject, _ui.hero.gameObject).transform
            hero.localScale = Vector3(0.6, 0.6, 1) * 0.9
            hero:Find("level text").gameObject:SetActive(false)
            hero:Find("name text").gameObject:SetActive(false)
            hero:Find("bg_skill").gameObject:SetActive(false)
            hero:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
            hero:Find("head icon/outline"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
            local star = hero:Find("star"):GetComponent("UISprite")
            if star ~= nil then
                star.width = v.star * star.height
            end
            SetClickCallback(hero:Find("head icon").gameObject,function(go)
                if go == _ui.tipObject then
                    _ui.tipObject = nil
                else
                    _ui.tipObject = go
                    Tooltip.ShowItemTip({name = TextMgr:GetText(heroData.nameLabel), text = TextMgr:GetText(heroData.description)}) 
                end
            end)
        end
    end
    if _ui.data.reward.item.item then
        for _, item in ipairs(_ui.data.reward.item.item) do
            local obj = UIUtil.AddItemToGrid(_ui.grid.gameObject, item)
            SetClickCallback(obj.gameObject,function(go)
                if go == _ui.tipObject then
                    _ui.tipObject = nil
                else
                    _ui.tipObject = go
                    local itemData = TableMgr:GetItemData(item.baseid)
                    Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)}) 
                end
            end)
        end
    end
    if _ui.data.reward.army.army then
        for ii, vv in ipairs(_ui.data.reward.army.army) do
            local reward = vv
            local soldierData = TableMgr:GetBarrackData(reward.baseid, reward.level)
            local itemprefab = NGUITools.AddChild(_ui.grid.gameObject, _ui.item.gameObject).transform
            itemprefab.gameObject:SetActive(true)
            itemprefab:GetComponent("UISprite").spriteName = "bg_item" .. (1 + reward.level)
            itemprefab:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", soldierData.SoldierIcon)
            itemprefab:Find("have"):GetComponent("UILabel").text = reward.num
            itemprefab:Find("num").gameObject:SetActive(false)
            SetClickCallback(itemprefab.gameObject,function(go)
                if go == _ui.tipObject then
                    _ui.tipObject = nil
                else
                    _ui.tipObject = go
                    Tooltip.ShowItemTip({name = TextMgr:GetText(soldierData.SoldierName), text = TextMgr:GetText(soldierData.SoldierDes)}) 
                end
            end)
        end
    end
    _ui.grid:Reposition()
end

function Show()
    transform = NGUITools.AddChild(GUIMgr.UIRoot.gameObject, ResourceLibrary.GetUIPrefab("Moba/Moba_winlose")).transform
    NGUITools.BringForward(transform.gameObject)
    Awake()
end
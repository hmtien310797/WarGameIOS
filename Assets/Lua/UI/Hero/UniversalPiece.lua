module("UniversalPiece", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local GetHeroAttrValueString = Global.GetHeroAttrValueString
local LoadHero = HeroList.LoadHero
local LoadHeroObject = HeroList.LoadHeroObject

local _ui

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local function CloseClickCallback(go)
    Hide()
end

local function RequestExchangePiece(uid, number, baseId)
    local req = HeroMsg_pb.MsgHeroPieceExchangeRequest()
    req.uid = uid
    req.num = number
    req.pieceId = baseId
    Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgHeroPieceExchangeRequest, req, HeroMsg_pb.MsgHeroPieceExchangeResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            _ui.effectObject.gameObject:SetActive(false)
            _ui.effectObject.gameObject:SetActive(true)
            MainCityUI.UpdateRewardData(msg.fresh)
        end
    end)
end

local function LoadUI()
    local heroMsg = _ui.heroMsg
    local heroData = TableMgr:GetHeroData(heroMsg.baseid)

    local requiredShardCount = 0
    if heroMsg.uid == 0 then
        requiredShardCount = heroData.chipnum
    else
        local rulesData = TableMgr:GetRulesDataByStarGrade(heroMsg.star, heroMsg.grade)
        requiredShardCount = rulesData.num
    end
    local shardCount = ItemListData.GetItemCountByBaseId(heroData.chipID)
    _ui.starSlider.value = shardCount / requiredShardCount
    _ui.starLabel.text = string.format("%d/%d", shardCount, requiredShardCount)

    local item1 = _ui.itemList[1]
    local item2 = _ui.itemList[2]
    local itemListData = ItemListData.GetData()
    local shardData2 = TableMgr:GetItemData(heroData.chipID)
    UIUtil.LoadHeroItem(item2, shardData2, shardCount)
    SetClickCallback(item2.iconObject, function(go)
        print("item id", shardData2.id)
    end)
    local shardData1 = TableMgr:GetItemDataListByTypeQuality(56, shardData2.quality)[1]
    local shardCount1 = 0
    
    local pieceUid = 0
    for _, v in ipairs(itemListData) do
        if v.baseid == shardData1.id then
            shardCount1 = v.number
            pieceUid = v.uniqueid
            break
        end
    end
    UIUtil.LoadHeroItem(item1, shardData1, shardCount1)
    item1.countLabel.color = shardCount1 >= 1 and Color.white or Color.red
    SetClickCallback(item1.iconObject, function(go)
        print("item id", shardData1.id)
    end)
    UIUtil.SetBtnEnable(_ui.oneButton, "btn_2", "btn_4", shardCount1 >= 1)
    UIUtil.SetBtnEnable(_ui.tenButton, "btn_2", "btn_4", shardCount1 >= 10)
    SetClickCallback(_ui.oneButton.gameObject, function()
        if shardCount1 >= 1 then
            RequestExchangePiece(pieceUid, 1, heroData.chipID)
        else
            FloatText.Show(TextMgr:GetText(Text.noMorePiece))
        end
    end)
    SetClickCallback(_ui.tenButton.gameObject, function()
        if shardCount1 >= 10 then
            RequestExchangePiece(pieceUid, 10, heroData.chipID)
        else
            FloatText.Show(TextMgr:GetText(Text.noMorePiece))
        end
    end)
end

function Awake()
    _ui = {}
    local closeButton = transform:Find("Container/close btn")
    local maskbg = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(maskbg.gameObject, CloseAll)
    _ui.stateLabel = transform:Find("Container/exp bar/Label"):GetComponent("UILabel")
    _ui.starSlider = transform:Find("Container/exp bar"):GetComponent("UISlider")
    _ui.starLabel = transform:Find("Container/exp bar/num"):GetComponent("UILabel")
    local itemList = {}
    for i = 1, 2 do
        local item = {}
        local itemTransform = transform:Find("Container/item widget/listitem_hero_item" .. i)
        UIUtil.LoadHeroItemObject(item, itemTransform)
        item.nameLabel = transform:Find(string.format("Container/item widget/item%d name", i)):GetComponent("UILabel")
        itemList[i] = item
    end
    _ui.itemList = itemList
    _ui.oneButton = transform:Find("Container/btn"):GetComponent("UIButton"):GetComponent("UIButton")
    _ui.tenButton = transform:Find("Container/btn ten"):GetComponent("UIButton"):GetComponent("UIButton")
    _ui.effectObject = transform:Find("Container/item widget/wannengsuipianzhuanhua").gameObject

    ItemListData.AddListener(LoadUI)
end

function Close()
    ItemListData.RemoveListener(LoadUI)
    _ui = nil
end

function Show(heroMsg)
    Global.OpenUI(_M)
    _ui.heroMsg = heroMsg
    LoadUI()
end

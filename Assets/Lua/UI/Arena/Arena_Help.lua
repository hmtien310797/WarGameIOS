module("Arena_Help", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameObject = UnityEngine.GameObject

local _ui
function Hide()
    Global.CloseUI(_M)
end

local function LoadUI()
    _ui.titleLabel.text = TextMgr:GetText(Text.Arena_Help_Title)
    _ui.descriptionLabel.text = TextMgr:GetText(Text.Arena_Help_Desc)

    for i, v in ipairs(tableData_tDailyRankReward.data) do
        local rewardTransform
        if i > _ui.rewardGrid.transform.childCount then
            rewardTransform = NGUITools.AddChild(_ui.rewardGrid.gameObject, _ui.rewardPrefab).transform
        else
            rewardTransform = _ui.rewardGrid.transform:GetChild(i - 1)
        end
        local rankLabel = rewardTransform:GetComponent("UILabel")
        if v.MinRanking == v.MaxRanking then
            rankLabel.text = String.Format(TextMgr:GetText(Text.Arena_Help_reward1), v.MinRanking)
        else
            rankLabel.text = String.Format(TextMgr:GetText(Text.Arena_Help_reward), v.MinRanking, v.MaxRanking)
        end
        local itemGrid = rewardTransform:Find("Grid"):GetComponent("UIGrid")
        local itemPrefab = rewardTransform:Find("Grid/icon").gameObject
        local itemIndex = 1
        for vv in string.gsplit(v.Reward, ";") do
            local itemTransform
            if itemIndex > itemGrid.transform.childCount then
                itemTransform = NGUITools.AddChild(itemGrid.gameObject, itemPrefab).transform
            else
                itemTransform = itemGrid.transform:GetChild(itemIndex - 1)
            end
            local iconTexture = itemTransform:GetComponent("UITexture")
            local countLabel = itemTransform:Find("num"):GetComponent("UILabel")
            local idList = string.split(vv, ":")
            local itemId = tonumber(idList[2])
            local itemCount = tonumber(idList[3])
            local itemData = tableData_tItem.data[itemId]
            iconTexture.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
            countLabel.text = itemCount
            itemIndex = itemIndex + 1
        end
        itemGrid.repositionNow = true
    end

    _ui.rewardGrid.repositionNow = true
end

function  Awake()
    _ui = {}
    _ui.mask = transform:Find("Container")
    _ui.close = transform:Find("Container/bg_frane/bg_top/btn_close")
    SetClickCallback(_ui.close.gameObject,function()
        Hide()
    end)    
    SetClickCallback(_ui.mask.gameObject,function()
        Hide()
    end)    
    _ui.titleLabel =transform:Find("Container/bg_frane/bg_top/title/text (1)"):GetComponent("UILabel")
    _ui.descriptionLabel =transform:Find("Container/bg_frane/Scroll View/text"):GetComponent("UILabel")
    _ui.rewardGrid = transform:Find("Container/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.rewardPrefab = transform:Find("Container/bg_frane/Scroll View/Grid/reward_text").gameObject
end

function Start()
    LoadUI()
end

function Show()
    Global.OpenUI(_M)
end

function Close()   
    _ui = nil
end

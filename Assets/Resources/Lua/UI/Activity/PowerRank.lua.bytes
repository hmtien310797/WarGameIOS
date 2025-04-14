module("PowerRank", package.seeall)

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

local ui

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    CountDown.Instance:Remove("PowerRankRewardListTime")
    Hide()
end


function LoadUI()

end


local ShowRewards = function(hero, item, army, grid)
    while grid.transform.childCount > 0 do
        UnityEngine.GameObject.DestroyImmediate(grid.transform:GetChild(0).gameObject)
    end
    if hero then
        print("Hero",#hero)
        for i, v in ipairs(hero) do
            local heroData = TableMgr:GetHeroData(v.id)
            local hero = NGUITools.AddChild(grid.gameObject, ui.hero.gameObject).transform
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
            UIUtil.SetClickCallback(hero:Find("head icon").gameObject,function(go)
                HeroInfoNew.ShowSpecialHero(v)
            end)
        end
    end
    if item then
        print("item",#item)
        for _, item in ipairs(item) do
            local obj = UIUtil.AddItemToGrid(grid.gameObject, item)
            UIUtil.SetClickCallback(obj.gameObject,function(go)
                if go ~= ui.tooltip then
                    local itemData = TableMgr:GetItemData(item.id)
                    Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)}) 
                    ui.tooltip = go
                else
                    Tooltip.HideItemTip()
                    ui.tooltip = nil
                end
            end)
        end
    end
    if army then
        print("army",#army)
        for i, v in ipairs(army) do
            print(v.id, v.level)
            local soldierData = TableMgr:GetBarrackData(v.id, v.level)
            local itemprefab = NGUITools.AddChild(grid.gameObject, ui.item.gameObject).transform
            itemprefab.gameObject:SetActive(true)
            itemprefab:GetComponent("UISprite").spriteName = "bg_item" .. (1 + v.level)
            itemprefab:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", soldierData.SoldierIcon)
            itemprefab:Find("have"):GetComponent("UILabel").text = v.num
            itemprefab:Find("num").gameObject:SetActive(false)
            UIUtil.SetClickCallback(itemprefab.gameObject,function(go)
                if go ~= ui.tooltip then
                    Tooltip.ShowItemTip({name = TextMgr:GetText(soldierData.SoldierName), text = TextMgr:GetText(soldierData.SoldierDes)}) 
                    ui.tooltip = go
                else
                    Tooltip.HideItemTip()
                    ui.tooltip = nil
                end
            end)
        end
    end
    grid.repositionNow = true
end


local function MakeRewardList(rl_transform,rewards_msg)
    local grid = rl_transform:Find("mid/Grid"):GetComponent("UIGrid")
    local title = rl_transform:Find("title/title"):GetComponent("UILabel")
    if rewards_msg.min == rewards_msg.max then
        title.text = System.String.Format(TextMgr:GetText("activity_content_107"), rewards_msg.min)
    else
        title.text = System.String.Format(TextMgr:GetText("activity_content_108"), rewards_msg.min , rewards_msg.max)
    end
    
    ShowRewards(rewards_msg.rewardInfo.heros,rewards_msg.rewardInfo.items,rewards_msg.rewardInfo.armys,grid)
end

local function LoadRewardList()
    local msg = PowerRankData.GetData()
    ui.text_time.text = System.String.Format(TextMgr:GetText("activity_content_106"),Serclimax.GameTime.SecondToString3(msg.endtime - Serclimax.GameTime.GetSecTime()))
    ui.text_time2.text = ui.text_time.text
    ui.text_palyerpower.text = System.String.Format(TextMgr:GetText("ui_Bestrong_2"), msg.mypkval)


    print("###########",msg.myrank,msg.mypkval)

    if  msg.myrank == 1 then
        ui.text_rank.text = TextMgr:GetText("activity_content_111")
    elseif msg.myrank == 0 then
        local l = #msg.rankUsers.userlist
        ui.text_rank.text = System.String.Format(TextMgr:GetText("activity_content_114"), msg.rankUsers.userlist[l].minpkval,l)
    else
        ui.text_rank.text = System.String.Format(TextMgr:GetText("activity_content_109"), msg.myrank,msg.rankUsers.userlist[msg.myrank-1].minpkval,msg.myrank-1)
    end

    while ui.rewardListGrid.transform.childCount > 0 do
        UnityEngine.GameObject.DestroyImmediate(ui.rewardListGrid.transform:GetChild(0).gameObject)
    end
    CountDown.Instance:Add("PowerRankRewardListTime", msg.endtime, function(t)
        ui.text_time.text = System.String.Format(TextMgr:GetText("activity_content_106"),t)
        ui.text_time2.text = ui.text_time.text
        if msg.endtime <= Serclimax.GameTime.GetSecTime() then
            ui.text_time.text = TextMgr:GetText("activity_content_115");
            ui.text_time2.text = ui.text_time.text
            CountDown.Instance:Remove("PowerRankRewardListTime")           
        end
    end)
	for i, v in ipairs(msg.ranklist) do
        local item = NGUITools.AddChild(ui.rewardListGrid.gameObject, ui.rewardListItem.gameObject).transform
        item.localScale = ui.rewardListItem.localScale
        item.gameObject:SetActive(true)
        MakeRewardList(item, v)
    end
    ui.rewardListGrid:Reposition()
end

local function SetRankInfo(trf,ServerOpenRankUser)
    local power = trf:Find("combat/number"):GetComponent("UILabel")
    local name = trf:Find("name"):GetComponent("UILabel")
    local flag= trf:Find("flag"):GetComponent("UITexture")
    local Military= trf:Find("Military")
    if Military ~= nil then
        Military = Military:GetComponent("UITexture")
    end
    if ServerOpenRankUser.charId == 0 then
        power.text = ServerOpenRankUser.minpkval
        name.text = TextMgr:GetText("GovernmentWar_10")
        flag.gameObject:SetActive(false)
        if Military ~= nil then
            Military.gameObject:SetActive(false)
        end
    else
        power.text = ServerOpenRankUser.minpkval
        name.text = ServerOpenRankUser.name
        flag.gameObject:SetActive(true)
        flag.mainTexture = UIUtil.GetNationalFlagTexture(ServerOpenRankUser.nation)
        if Military ~= nil then
            Military.gameObject:SetActive(true)
            local militaryRankData = tableData_tMilitaryRank.data[ServerOpenRankUser.militaryrankid] 
            Military.mainTexture = ResourceLibrary:GetIcon("Icon/MilitaryRank/", militaryRankData.Icon)
        end
    end
    local rank = trf:GetComponent("UILabel")
    if rank ~= nil then
        rank.text = ServerOpenRankUser.rank
    end
    
end

local function SetRankHead(trf,ServerOpenRankUser)
    local avatar = trf:Find("avatar"):GetComponent("UITexture")
    local Military = trf:Find("Military"):GetComponent("UITexture")

    if ServerOpenRankUser.charId == 0 then
        avatar.mainTexture = ResourceLibrary:GetIcon("Icon/head/", "666")
        if Military ~= nil then
            Military.gameObject:SetActive(false)
        end 
    else
        avatar.mainTexture = ResourceLibrary:GetIcon("Icon/head/", ServerOpenRankUser.face)
        if Military ~= nil then
            local militaryRankData = tableData_tMilitaryRank.data[ServerOpenRankUser.militaryrankid] 
            Military.mainTexture = ResourceLibrary:GetIcon("Icon/MilitaryRank/", militaryRankData.Icon)
        end 
    end

end


local function LoadPower()
    local msg = PowerRankData.GetData()
    for i=1,3 do
        SetRankInfo(ui.top[i].rank_info,msg.rankUsers.userlist[i])
        SetRankHead(ui.top[i].head,msg.rankUsers.userlist[i])
        SetClickCallback(ui.top[i].trf.gameObject, function()
            if msg.rankUsers.userlist[i].charId ~= 0 then
                OtherInfo.RequestShow(msg.rankUsers.userlist[i].charId)
            end
        end)     
    end

    while ui.powerTable.transform.childCount > 0 do
        UnityEngine.GameObject.DestroyImmediate(ui.powerTable.transform:GetChild(0).gameObject)
    end

    for i=4,#msg.rankUsers.userlist do
        local item = NGUITools.AddChild(ui.powerTable.gameObject, ui.powerItem.gameObject).transform
        local rf = item:Find("rank_info") 
        SetRankInfo(rf,msg.rankUsers.userlist[i])
        local self_tag = item:Find("bg_self")
        if msg.rankUsers.userlist[i].charId == MainData.GetCharId() then
            self_tag.gameObject:SetActive(true)
        else
            self_tag.gameObject:SetActive(false)
        end
        SetClickCallback(item.gameObject, function()
            if msg.rankUsers.userlist[i].charId ~= 0 then
                OtherInfo.RequestShow(msg.rankUsers.userlist[i].charId)
            end
        end)    
    end
    local l = #msg.rankUsers.userlist
    ui.text_power.text = System.String.Format(TextMgr:GetText("activity_content_112"),msg.rankUsers.userlist[l].minpkval)
end

function Awake()
    local closeButton = transform:Find("background/close btn")
    closeButton.gameObject:SetActive(true)
    local mask = transform:Find("mask")
    SetClickCallback(closeButton.gameObject, CloseAll)
    SetClickCallback(mask.gameObject, function()
        CloseAll()
    end)
    ui = {}
    ui.item = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
    ui.text_time =transform:Find("widget/Container01/base/title/time"):GetComponent("UILabel")
    ui.text_palyerpower = transform:Find("widget/Container01/base/bg_down/text_palyerpower"):GetComponent("UILabel")
    ui.text_rank = transform:Find("widget/Container01/base/bg_down/text_rank"):GetComponent("UILabel")
    ui.rewardListGrid = transform:Find("widget/Container01/base/Scroll View/Grid"):GetComponent("UIGrid")
    ui.rewardListItem = transform:Find("widget/Container01/base/term01")
	ui.rewardListBtn = transform:Find("widget/page1"):GetComponent("UIButton")
    ui.PowerBtn = transform:Find("widget/page2"):GetComponent("UIButton")
    ui.powerTable = transform:Find("widget/Container02/base/Scroll View/Table"):GetComponent("UITable")
    ui.powerItem = transform:Find("widget/Container02/base/list_playerinfo")
    ui.text_power = transform:Find("widget/Container02/base/bg_down/text_power"):GetComponent("UILabel")
    ui.text_time2 = transform:Find("widget/Container02/base/bg_down/text_time"):GetComponent("UILabel")
    ui.top={}
    for i=1,3 do
        ui.top[i] = {}
        ui.top[i].trf = transform:Find(System.String.Format("widget/Container02/base/bg_top/bg_top{0}",i))
        ui.top[i].rank_info = transform:Find(System.String.Format("widget/Container02/base/bg_top/bg_top{0}/rank_info",i))
        ui.top[i].head= transform:Find(System.String.Format("widget/Container02/base/bg_top/bg_top{0}/head",i))
    end

	--SetClickCallback(ui.rewardListBtn.gameObject , LoadRewardList)
    --SetClickCallback(ui.PowerBtn.gameObject , LoadPower)
    LoadRewardList()
    LoadPower()
end



function Start()

end

function Close()

    ui = nil
end

function Show()
    PowerRankData.RequestData(function(success)
        if success then
            Global.DumpMessage(PowerRankData.GetData(), "d:/PowerRank.lua")
            Global.OpenUI(_M)
            LoadUI()
        end
    end)
end

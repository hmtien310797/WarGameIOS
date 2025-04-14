module("AllianceLogin", package.seeall)
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
local GameObject = UnityEngine.GameObject

local _ui
local timer = 0

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
    ActivityAll.Hide()
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

local function SetTime(data)
    local showtime = 0
    if data.status == 0 then
        showtime = data.starttime
    elseif data.status == 1 then
        showtime = data.matchtime
    elseif data.status == 2 then
        showtime = data.battletime
    elseif data.status == 3 then
        showtime = data.battletime + tonumber(tableData_tGuildMobaGlobal.data[5].Value)
    elseif data.status == 4 then
        showtime = data.overtime
    end
    CountDown.Instance:Add("AllianceLogin", showtime, function(t)
        if showtime >= Serclimax.GameTime.GetSecTime() then
            _ui.time.text = t
        end
    end)
end

local function CheckReward(data)
    if data == nil then
        return false
    end
    return #data.roundreward.items > 0 or #data.roundreward.heros > 0 or #data.roundreward.armys > 0
end

local function SetBtn(data)
    if data.status == 0 then
        UIUtil.SetBtnEnable(_ui.login_record:GetComponent("UIButton"), "btn_2", "btn_4", false)
        SetClickCallback(_ui.login_record, function()
        
        end)
    elseif data.status == 1 then
        if data.guildapply or not UnionInfoData.HasUnion() or not UnionInfoData.IsUnionLeader() then
            UIUtil.SetBtnEnable(_ui.login_record:GetComponent("UIButton"), "btn_2", "btn_4", false)
            SetClickCallback(_ui.login_record, function()
                
            end)
        else
            UIUtil.SetBtnEnable(_ui.login_record:GetComponent("UIButton"), "btn_2", "btn_4", true)
            SetClickCallback(_ui.login_record, function()
                BattleTime.Show(function(timeflag)
                    UnionMobaActivityData.RequestGuildApply(timeflag)
                end)
            end)
        end
    elseif data.status == 2 then
        local canReward = data.round > 1 and not data.isRoundReward and data.roundself > 1 and CheckReward(data)
        UIUtil.SetBtnEnable(_ui.enter_btn:GetComponent("UIButton"), "union_button2", "union_button1_un", canReward)
        if canReward then
            _ui.enter_btn_text.text = TextMgr:GetText("RebelArmy_btn_reward")
            SetClickCallback(_ui.enter_btn, function()
                UnionMobaActivityData.RequestMobaGetReward(data.roundself < data.round and data.roundself or (data.pair.winner > 0 and data.roundself or data.roundself - 1), function(msg)
            
                end)
            end)
        else
            _ui.enter_btn_text.text = TextMgr:GetText("ui_moba_10")
            SetClickCallback(_ui.enter_btn, function() end)
        end
    elseif data.status == 3 then
        UIUtil.SetBtnEnable(_ui.enter_btn:GetComponent("UIButton"), "union_button2", "union_button1_un", data.guildapply and UnionMobaActivityData.GetData().pair.starttime > 0)
        _ui.enter_btn_text.text = TextMgr:GetText("ui_moba_10")
        SetClickCallback(_ui.enter_btn, function()
            UnionMobaActivityData.RequestMobaEnter(function()
                CloseAll()
                MainCityUI.CheckWorldMap(false, function()
                    Global.SetSlgMobaMode(2)
                    MainCityUI.ShowWorldMap(nil, nil, true, nil--[[Mobaroleselect.Show]])
                end)
            end)
        end)
    elseif data.status == 4 then
        UIUtil.SetBtnEnable(_ui.enter_btn:GetComponent("UIButton"), "union_button2", "union_button1_un", data.round > 1 and not data.isRoundReward and CheckReward(data))
        _ui.enter_btn_text.text = TextMgr:GetText("RebelArmy_btn_reward")
        SetClickCallback(_ui.enter_btn, function()
            UnionMobaActivityData.RequestMobaGetReward(data.roundself, function(msg)
            
            end)
        end)
    elseif data.status == 5 then
    end
end

function LoadUI()
    local data = UnionMobaActivityData.GetData()
    if data == nil then
        print("活动数据空!!!")
        return
    end

    local showReward = {}
    if data.isRoundReward or data.round == 1 or not CheckReward(data) then
        showReward = data.winreward
        _ui.enter_reward_text.text = TextMgr:GetText("ui_unionwar_12")
    else
        showReward = data.roundreward
        _ui.enter_reward_text.text = TextMgr:GetText("rebel_28")
    end

    if _ui.curRound ~= data.round or _ui.curRewarded ~= data.isRoundReward then
        while _ui.enter_reward_grid.transform.childCount > 0 do
			GameObject.DestroyImmediate(_ui.enter_reward_grid.transform:GetChild(0).gameObject)
        end
        _ui.curRewarded = nil
        _ui.curRound = nil
    end
    if _ui.curRewarded == nil or _ui.curRound == nil then
        for i, v in ipairs(showReward.heros) do
            local heroData = TableMgr:GetHeroData(v.id)
            local hero = NGUITools.AddChild(_ui.enter_reward_grid.gameObject, _ui.heroPrefab).transform
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
            UIUtil.SetClickCallback(reward.transform.gameObject, function(go)
                if go == _ui.tipObject then
                    _ui.tipObject = nil
                else
                    _ui.tipObject = go
                    Tooltip.ShowItemTip({name = TextMgr:GetText(heroData.nameLabel), text = TextMgr:GetText(heroData.description)})
                end
            end)
        end
        for i, v in ipairs(showReward.items) do
            local itemdata = TableMgr:GetItemData(v.id)
            local item = NGUITools.AddChild(_ui.enter_reward_grid.gameObject, _ui.itemPrefab).transform
            local reward = {}
            UIUtil.LoadItemObject(reward, item)
            UIUtil.LoadItem(reward, itemdata, v.num)
            UIUtil.SetClickCallback(reward.transform.gameObject, function(go)
                if go == _ui.tipObject then
                    _ui.tipObject = nil
                else
                    _ui.tipObject = go
                    Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
                end
            end)
        end
        for i, v in ipairs(showReward.armys) do
            local reward = v
            local soldierData = TableMgr:GetBarrackData(reward.id, reward.level)
            local itemprefab = NGUITools.AddChild(_ui.enter_reward_grid.gameObject, _ui.itemPrefab).transform
            itemprefab.gameObject:SetActive(true)
            itemprefab:GetComponent("UISprite").spriteName = "bg_item" .. (1 + reward.level)
            itemprefab:Find("Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", soldierData.SoldierIcon)
            itemprefab:Find("have"):GetComponent("UILabel").text = reward.num
            itemprefab:Find("num").gameObject:SetActive(false)
            UIUtil.SetClickCallback(itemprefab.gameObject, function(go)
                if go == _ui.tipObject then
                    _ui.tipObject = nil
                else
                    _ui.tipObject = go
                    Tooltip.ShowItemTip({name = TextMgr:GetText(soldierData.SoldierName), text = TextMgr:GetText(soldierData.SoldierDes)})
                end
            end)
        end
    end
    
    _ui.enter_reward_grid.repositionNow = true

    SetClickCallback(_ui.btn_select, function()
        AllianceUnionSelect.Show(data.status == 3 or not UnionInfoData.IsUnionLeader() , nil, function(idlist)
            UnionMobaActivityData.RequestConfirmTeam(idlist)
        end)
    end)

    SetClickCallback(_ui.contribution_reward, function()
        AllianceUnionSelect.Show(nil, data.assignreward, function(idlist)
            UnionMobaActivityData.RequestAssignReward(idlist)
        end)
    end)

    local index = 0
    if data.status <= 1 then
        _ui.login:SetActive(true)
        _ui.enter:SetActive(false)
        for i, v in ipairs(data.ranktop.guilds) do
            if i <= 3 and v.guildid > 0 then
                _ui.alliance_rank[i].iconroot:SetActive(true)
                local badge = {}
                UnionBadge.LoadBadgeObject(badge, _ui.alliance_rank[i].iconroot.transform)
                UnionBadge.LoadBadgeById(badge, v.guildbadge)
                local name = string.format("[%s]%s", v.guildbanner, v.guildname)
                _ui.alliance_rank[i].name.text = name
                index = i
            end
        end

        for i = index + 1, 3 do
            _ui.alliance_rank[i].iconroot:SetActive(false)
            _ui.alliance_rank[i].name.text = ""
        end
    else
        _ui.login:SetActive(false)
        _ui.enter:SetActive(true)
    end

    _ui.login_record:SetActive(false)
    _ui.enter_btn:SetActive(false)
    _ui.note_text.gameObject:SetActive(true)
    if not UnionInfoData.HasUnion() then
        _ui.note_text.text = TextMgr:GetText("ui_unionwar_31")
    elseif UnionInfoData.HasUnion() and not UnionInfoData.IsUnionLeader() and data.status == 1 then
        _ui.note_text.text = TextMgr:GetText("ui_unionwar_32")
    elseif data.status > 1 and not data.guildapply then
        _ui.note_text.text = TextMgr:GetText("ui_unionwar_35")
    elseif data.status > 1 and data.guildapply and data.roundself < data.round and data.isRoundReward then
        _ui.note_text.text = TextMgr:GetText("ui_unionwar_33")
    elseif data.status > 1 and data.guildapply and UnionMobaActivityData.GetData().pair.starttime == 0 and data.isRoundReward then
        _ui.note_text.text = TextMgr:GetText("ui_unionwar_46")
    elseif data.status == 3 and data.guildapply and not UnionMobaActivityData.CheckSelect(MainData.GetCharId()) and data.isRoundReward then
        _ui.note_text.text = TextMgr:GetText("ui_unionwar_34")
    else
        _ui.login_record:SetActive(true)
        _ui.enter_btn:SetActive(true)
        _ui.note_text.gameObject:SetActive(false)
        SetBtn(data)
    end
    SetTime(data)

    --_ui.rankreward:SetActive(data.status == 4)
    _ui.contribution_reward:SetActive(data.status == 4 and (#data.assignreward.items > 0 or #data.assignreward.heros > 0 or #data.assignreward.armys > 0))
    _ui.btn_select:SetActive((data.status == 2 or data.status == 3) and data.guildapply and UnionMobaActivityData.GetData().pair.starttime > 0 and (data.pair.winner == 0))
    _ui.desc.gameObject:SetActive((data.status == 2) and data.guildapply and UnionMobaActivityData.GetData().pair.starttime > 0)

    if data.round == 1 then
        _ui.enter_title.text = String.Format(TextMgr:GetText("ui_unionwar_13"), 16, 8)
    elseif data.round == 2 then
        _ui.enter_title.text = String.Format(TextMgr:GetText("ui_unionwar_13"), 8, 4)
    elseif data.round == 3 then
        _ui.enter_title.text = TextMgr:GetText("ui_unionwar_15")
    elseif data.round == 4 then
        _ui.enter_title.text = TextMgr:GetText("ui_unionwar_14")
    end
    _ui.curRound = data.round
    _ui.curRewarded = data.isRoundReward
end

function Awake()
    local mask = transform:Find("mask")
    SetClickCallback(mask.gameObject, function()
        CloseAll()
    end)
    _ui = {}
    _ui.rankreward = transform:Find("Container/bg_frane/mid/rank_reward").gameObject
    _ui.time = transform:Find("Container/bg_frane/mid/Sprite_time/time"):GetComponent("UILabel")
    _ui.help = transform:Find("Container/bg_frane/mid/Sprite_time/help_btn").gameObject

    _ui.login = transform:Find("Container/bg_frane/mid/login").gameObject
    _ui.login_record = transform:Find("Container/bg_frane/mid/login/record").gameObject
    _ui.login_desc = transform:Find("Container/bg_frane/mid/login/desc"):GetComponent("UILabel")
    _ui.alliance_rank = {}
    for i = 1, 3 do
        _ui.alliance_rank[i] = {}
        _ui.alliance_rank[i].name = transform:Find(string.format("Container/bg_frane/mid/login/alliance_rank/top%d/name", i)):GetComponent("UILabel")
        _ui.alliance_rank[i].iconroot = transform:Find(string.format("Container/bg_frane/mid/login/alliance_rank/top%d/union_icon", i)).gameObject
    end

    _ui.enter = transform:Find("Container/bg_frane/mid/enter").gameObject
    _ui.enter_title = transform:Find("Container/bg_frane/mid/enter/icon_tittle/text"):GetComponent("UILabel")
    _ui.enter_reward_text = transform:Find("Container/bg_frane/mid/enter/reward/text"):GetComponent("UILabel")
    _ui.enter_reward_grid = transform:Find("Container/bg_frane/mid/enter/reward/Grid"):GetComponent("UIGrid")
    _ui.enter_btn = transform:Find("Container/bg_frane/mid/enter/btn_enter").gameObject
    _ui.enter_btn_text = transform:Find("Container/bg_frane/mid/enter/btn_enter/text"):GetComponent("UILabel")

    _ui.btn_select = transform:Find("Container/bg_frane/mid/btn_select").gameObject
    _ui.desc = transform:Find("Container/bg_frane/mid/desc"):GetComponent("UILabel")
    _ui.btn_battle = transform:Find("Container/bg_frane/mid/btn_battle").gameObject
    _ui.contribution_reward = transform:Find("Container/bg_frane/mid/contribution_reward").gameObject
    _ui.btn_history = transform:Find("Container/bg_frane/Texture/btn_history").gameObject
    _ui.btn_history:SetActive(false)
    _ui.itemPrefab = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    _ui.heroPrefab = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")

    _ui.note_text = transform:Find("Container/bg_frane/mid/note_text"):GetComponent("UILabel")

    UnionMobaActivityData.AddListener(LoadUI)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()
    UnionMobaActivityData.NotifyUIOpened()
    SetClickCallback(_ui.btn_battle, AllianceMatch.Show)
    SetClickCallback(_ui.btn_history, AllianceHistory.Show)
    SetClickCallback(_ui.rankreward, AllianceRank.Show)
    SetClickCallback(_ui.help, function()
        MapHelp.Open(2700, false, function() end, false, true)
    end)
end

function Close()
    CountDown.Instance:Remove("AllianceLogin")
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    UnionMobaActivityData.RemoveListener(LoadUI)
    Tooltip.HideItemTip()
    _ui = nil
end

function Show()
    if Global.ACTIVE_GUILD_MOBA then
        UnionMobaActivityData.RequestData(false)
        UnionMobaActivityData.RequestMobaGlobalChampion(function(msg)
            _ui.btn_history:SetActive(#msg.infos > 0)
        end)
    end
    Global.OpenUI(_M)
    LoadUI()
end
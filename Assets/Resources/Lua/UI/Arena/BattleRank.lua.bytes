module("BattleRank", package.seeall)
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

local chestTextList = 
{
    "s",
    "m",
    "b",
}

local _ui
local lastMyMsg
local lastEnemyMsg
local rankListMsg

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

local function SecondUpdate()
    local arenaInfoMsg = ArenaInfoData.GetData().arenaInfo
    local leftText, leftTime  = Global.GetLeftCooldownTextLong(arenaInfoMsg.challengeCDTime)
    _ui.nextLabel.gameObject:SetActive(leftTime > 0)
    if leftTime > 0 then
        _ui.nextLabel.text = Format(TextMgr:GetText(Text.ui_Arena_5), leftText)
    end
    local cooldownText, cooldownTime = Global.GetLeftCooldownTextLong(arenaInfoMsg.refreshCDTime)
    _ui.changeLabel.gameObject:SetActive(cooldownTime == 0)
    _ui.cooldownLabel.gameObject:SetActive(cooldownTime > 0)
    if cooldownTime > 0 then
        _ui.cooldownLabel.text = cooldownText
    end
    UIUtil.SetBtnEnable(_ui.changeButton, "btn_1", "btn_4", cooldownTime == 0)
end

local function RequestBuy()
    local req = BattleMsg_pb.MsgArenaBuyChallengeTimesRequest()
    Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgArenaBuyChallengeTimesRequest, req, BattleMsg_pb.MsgArenaBuyChallengeTimesResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            MainCityUI.UpdateRewardData(msg.fresh)
            ArenaInfoData.RequestData()
        else
            Global.ShowError(msg.code)
        end
    end, false)
end

local function LoadEnemyObject(enemy, enemyTransform)
    enemy.transform = enemyTransform
    enemy.rankLabel = enemyTransform:Find("bg/bg_rank/text_rank"):GetComponent("UILabel")
    local vipTransform = enemyTransform:Find("bg/head")
    if vipTransform ~= nil then
        enemy.vipSprite = vipTransform:GetComponent("UISprite")
    end
    enemy.vipLabel = enemyTransform:Find("bg/head/vipicon/num"):GetComponent("UILabel")
    enemy.nationTexture = enemyTransform:Find("bg/head/flag"):GetComponent("UITexture")
    enemy.rankTexture = enemyTransform:Find("bg/head/Military"):GetComponent("UITexture")
    enemy.faceObject = enemyTransform:Find("bg/head").gameObject
    enemy.faceTexture = enemyTransform:Find("bg/head/avatar"):GetComponent("UITexture")
    enemy.levelLabel = enemyTransform:Find("bg/bg_info/level"):GetComponent("UILabel")
    enemy.nameLabel = enemyTransform:Find("bg/bg_info/level/name"):GetComponent("UILabel")
    enemy.powerLabel = enemyTransform:Find("bg/bg_info/combat/number"):GetComponent("UILabel")
end

local function LoadEnemy(enemy, enemyMsg)
    if enemyMsg.rank == 0 then
        enemy.rankLabel.text = TextMgr:GetText(Text.ui_Arena_11)
    else
        enemy.rankLabel.text = Format(TextMgr:GetText(Text.ui_Arena_6), enemyMsg.rank)
    end
    enemy.vipSprite.spriteName = tableData_tVip.data[enemyMsg.viplevel].headBox
    enemy.vipLabel.text = enemyMsg.viplevel
    enemy.nationTexture.mainTexture = UIUtil.GetNationalFlagTexture(enemyMsg.nation)
    local militaryRankData = tableData_tMilitaryRank.data[enemyMsg.militaryrankid] 
    enemy.rankTexture.mainTexture = ResourceLibrary:GetIcon("Icon/MilitaryRank/", militaryRankData.Icon)
    enemy.levelLabel.text = "Lv." .. enemyMsg.level
    if enemyMsg.charid == 0 then
        enemy.nameLabel.text = TextMgr:GetText(enemyMsg.charname)
        enemy.faceTexture.mainTexture = ResourceLibrary:GetIcon("Icon/head/", "666")
    else
        enemy.nameLabel.text = enemyMsg.charname
        enemy.faceTexture.mainTexture = ResourceLibrary:GetIcon("Icon/head/", enemyMsg.face)
    end
    enemy.powerLabel.text = enemyMsg.pkval
end

function LoadUI()
    local arenaInfoMsg = ArenaInfoData.GetData().arenaInfo
    _ui.arenaInfoMsg = arenaInfoMsg
    _ui.faceTexture.mainTexture = ResourceLibrary:GetIcon("Icon/head/", MainData.GetFace())
    if arenaInfoMsg.arenarank == 0 then
        _ui.rankLabel.text = TextMgr:GetText(Text.ui_Arena_11)
    else
        _ui.rankLabel.text = Format(TextMgr:GetText(Text.ui_Arena_6), arenaInfoMsg.arenarank)
    end
    _ui.powerLabel.text = arenaInfoMsg.pkval
    _ui.selectedIdList = {}
    _ui.heroListMsg = GeneralData.GetSortedGenerals(_ui.suggestionRule.sortingConfig)
    for _, v in ipairs(arenaInfoMsg.army.hero) do
        _ui.selectedIdList[v] = true
    end
    local heroIndex = 1
    for i, v in ipairs(_ui.heroListMsg) do
        if _ui.selectedIdList[v.uid] then
            local hero = _ui.heroList[heroIndex]
            local heroData = TableMgr:GetHeroData(v.baseid) 
            HeroList.LoadHero(hero, v, heroData)
            hero.gameObject:SetActive(true)
            heroIndex = heroIndex + 1
        end
    end

    for i = heroIndex, 5 do
        local hero = _ui.heroList[i]
        hero.gameObject:SetActive(false)
    end

    _ui.dailyObject:SetActive(not arenaInfoMsg.dayreward.got and arenaInfoMsg.dayreward.rewardTime ~= 0)

    local myRank = rankListMsg.myrank
    for i = 1, 3 do
        RankList.LoadRank(_ui.topRankList[i], rankListMsg.rankuser[i], myRank)
    end

    for i = 1, 4 do
        local enemy = _ui.enemyList[i]
        local enemyMsg = arenaInfoMsg.enemylist[i]
        LoadEnemy(enemy, enemyMsg)
        if enemyMsg.rank <= 3 then
            enemy.rankSprite1.spriteName = "bg_arena_" .. enemyMsg.rank
            enemy.rankSprite2.spriteName = "bg_arena_" .. enemyMsg.rank
        else
            enemy.rankSprite1.spriteName = "bg_arena_other"
            enemy.rankSprite2.spriteName = "bg_arena_other"
        end
        SetClickCallback(enemy.faceObject.gameObject, function(go)
            if enemyMsg.charid == 0 then
                Npcinfo.Show(enemyMsg.rank)
            else
                OtherInfo.RequestShow(enemyMsg.charid)
            end
        end)
        SetClickCallback(enemy.challengeButton.gameObject, function(go)
            if arenaInfoMsg.canBattleCnt == 0 then
                local showText = Format(TextMgr:GetText(Text.Arena_buy_desc2), arenaInfoMsg.buyBattleCntCost, tableData_tPvpInfo.data[1].Value, arenaInfoMsg.maxBuyBattleCnt - arenaInfoMsg.buyBattleCnt, arenaInfoMsg.maxBuyBattleCnt)
                MessageBox.Show(showText, function()
                    RequestBuy()
                end,
                function()
                end)
                return
            end

            Global.CheckSupportPlayBack(function()
                local req = BattleMsg_pb.MsgFightArenaBattleRequest()
                req.charid = enemyMsg.charid
                req.rank = enemyMsg.rank
                Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgFightArenaBattleRequest, req, BattleMsg_pb.MsgFightArenaBattleResponse, function(msg)
                    ArenaInfoData.RequestData()
                    if msg.code == ReturnCode_pb.Code_OK then
                        lastMyMsg = BattleMsg_pb.ArenaEnemyInfo()
                        lastMyMsg.rank = arenaInfoMsg.arenarank 
                        lastMyMsg.viplevel = MainData.GetVipLevel() 
                        lastMyMsg.charid = MainData.GetCharId()
                        lastMyMsg.charname = MainData.GetCharName()
                        lastMyMsg.face = MainData.GetFace()
                        lastMyMsg.level = MainData.GetLevel()
                        lastMyMsg.nation = MainData.GetNationality()
                        lastMyMsg.pkval = arenaInfoMsg.pkval
                        lastMyMsg.militaryrankid = MainData.GetMilitaryRankID()
                        lastEnemyMsg = enemyMsg
                    else
                        Global.ShowError(msg.code)
                    end
                end, false) 
            end)
        end)
    end

    SetClickCallback(_ui.addButton.gameObject, function(go)
        local showText = Format(TextMgr:GetText(Text.Arena_buy_desc2), arenaInfoMsg.buyBattleCntCost, tableData_tPvpInfo.data[1].Value, arenaInfoMsg.maxBuyBattleCnt - arenaInfoMsg.buyBattleCnt, arenaInfoMsg.maxBuyBattleCnt)
        MessageBox.Show(showText, function()
            RequestBuy()
        end,
        function()
        end)
    end)
    _ui.leftLabel.text = Format(TextMgr:GetText(Text.ui_Arena_4), arenaInfoMsg.canBattleCnt, tableData_tPvpInfo.data[1].Value)
    local rewardIndex = 3
    for i, v in ipairs(arenaInfoMsg.Reward) do
        if not v.got then
            rewardIndex = i
            break
        end
    end
    local rewardMsg = arenaInfoMsg.Reward[rewardIndex]
    _ui.rewardLabel.text = Format(TextMgr:GetText(Text.ui_Arena_12), tableData_tDailyReward.data[rewardIndex].NeedTimes)
    local completed = arenaInfoMsg.battleCnt >= rewardMsg.challengeCnt
    local chestText
    local chestStatus
    if rewardMsg.got then
        chestText = "open"
        chestStatus = 3
    elseif completed then
        chestText = "done"
        chestStatus = 2
    elseif completed then
    else
        chestText = "null"
        chestStatus = 1
    end
    _ui.rewardButton.normalSprite = string.format("icon_starbox_%s_%s_dm", chestTextList[rewardIndex], chestText)
    _ui.rewardEffectObject:SetActive(chestStatus == 2)
    SetClickCallback(_ui.rewardButton.gameObject, function(go)
        ArenaRewards.Show(rewardMsg.droplist.items, function()
            local req = BattleMsg_pb.MsgArenaGetChallangeRewardRequest()
            req.id = rewardMsg.id
            Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgArenaGetChallangeRewardRequest, req, BattleMsg_pb.MsgArenaGetChallangeRewardResponse, function(msg)
                if msg.code == ReturnCode_pb.Code_OK then
                    MainCityUI.UpdateRewardData(msg.freshInfo)
                    Global.ShowReward(msg.rewardInfo)
                    ArenaInfoData.RequestData(false)
                else
                    Global.ShowError(msg.code)
                end
            end, false)
        end,
        chestStatus)
    end)

    SetClickCallback(_ui.changeButton.gameObject, function(go)
        local req = BattleMsg_pb.MsgArenaFreshEnemyRequest()
        Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgArenaFreshEnemyRequest, req, BattleMsg_pb.MsgArenaFreshEnemyResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                ArenaInfoData.RequestData(false)
            else
                Global.ShowError(msg.code)
            end
        end, false)
    end)
    SecondUpdate()
end

function Awake()
    _ui = {}
    _ui.suggestionRule = TableMgr:GetHeroSuggestionRule(0)
    local mask = transform:Find("mask")
    local closeButton = transform:Find("Container/bg_frane/bg_title/btn_close")
    UIUtil.SetClickCallback(mask.gameObject, Hide)
    UIUtil.SetClickCallback(closeButton.gameObject, Hide)

    _ui.faceTexture = transform:Find("Container/bg_frane/bg_top/bg_my/head/avatar"):GetComponent("UITexture")
    _ui.rankLabel = transform:Find("Container/bg_frane/bg_top/bg_my/text_rank"):GetComponent("UILabel")
    _ui.powerLabel = transform:Find("Container/bg_frane/bg_top/bg_my/combat/number"):GetComponent("UILabel")

    local gridTransform = transform:Find("Container/bg_frane/bg_top/bg_my/bg_hero/Grid")
    local heroList = {}
    for i = 1, 5 do
        local hero = {}
        local heroTransform = gridTransform:GetChild(i - 1)
        HeroList.LoadHeroObject(hero, heroTransform)
        heroList[i] = hero
    end
    _ui.heroList = heroList

    _ui.dailyObject = transform:Find("Container/bg_frane/bg_top/bg_my/icon_pack").gameObject
    _ui.formationButton = transform:Find("Container/bg_frane/bg_top/bg_my/btn_change"):GetComponent("UIButton")
    _ui.shopButton = transform:Find("Container/bg_frane/bg_top/btn_shop") 
    _ui.rankObject = transform:Find("Container/bg_frane/bg_top/btn_rank").gameObject
    _ui.historyObject = transform:Find("Container/bg_frane/bg_top/btn_history").gameObject
    _ui.historyObjectRed = transform:Find("Container/bg_frane/bg_top/btn_history/new").gameObject

    local topRankList = {}
    for i = 1, 3 do
        local rank = {}
        local rankTransform = transform:Find("Container/bg_frane/bg_top/bg_top" .. i)
        RankList.LoadRankObject(rank, rankTransform)
        topRankList[i] = rank
    end
    _ui.topRankList = topRankList

    local enemyList = {}
    for i = 1, 4 do
        local enemy = {}
        local enemyTransform = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid/list_playerinfo" .. i)
        LoadEnemyObject(enemy, enemyTransform)
        enemy.rankSprite1 = enemyTransform:Find("bg/bg_rank"):GetComponent("UISprite")
        enemy.rankSprite2 = enemyTransform:Find("bg/bg_rank/bg_rank1"):GetComponent("UISprite")
        enemy.challengeButton = enemyTransform:Find("bg/btn_battle"):GetComponent("UIButton")
        enemyList[i] = enemy
    end
    _ui.enemyList = enemyList

    _ui.leftLabel = transform:Find("Container/bg_frane/bg_bottom/text"):GetComponent("UILabel")
    _ui.addButton = transform:Find("Container/bg_frane/bg_bottom/btn_add")
    _ui.nextLabel = transform:Find("Container/bg_frane/bg_bottom/text (1)"):GetComponent("UILabel")
    _ui.changeButton = transform:Find("Container/bg_frane/bg_bottom/btn_change"):GetComponent("UIButton")
    _ui.changeLabel = transform:Find("Container/bg_frane/bg_bottom/btn_change/text"):GetComponent("UILabel")
    _ui.cooldownLabel = transform:Find("Container/bg_frane/bg_bottom/btn_change/text_time"):GetComponent("UILabel")
    _ui.rewardButton = transform:Find("Container/bg_frane/bg_top/btn_reward"):GetComponent("UIButton")
    _ui.rewardLabel = transform:Find("Container/bg_frane/bg_top/btn_reward/text"):GetComponent("UILabel")
    _ui.rewardEffectObject = transform:Find("Container/bg_frane/bg_top/btn_reward/vfx").gameObject
    _ui.btn_help = transform:Find("Container/bg_frane/bg_top/bg_my/help").gameObject

    _ui.resultObject = transform:Find("Container/rankup").gameObject
    _ui.winPlayer = {}
    local winTransform = transform:Find("Container/rankup/Container/playerinfo2")
    LoadEnemyObject(_ui.winPlayer, winTransform)
    _ui.losePlayer = {}
    local loseTransform = transform:Find("Container/rankup/Container/playerinfo1")
    LoadEnemyObject(_ui.losePlayer, loseTransform)

    SetClickCallback(_ui.dailyObject, function(go)
        local req = BattleMsg_pb.MsgArenaGetRankRewardRequest()
        Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgArenaGetRankRewardRequest, req, BattleMsg_pb.MsgArenaGetRankRewardResponse, function(msg)
            if msg.code == ReturnCode_pb.Code_OK then
                MainCityUI.UpdateRewardData(msg.freshInfo)
                Global.ShowReward(msg.rewardInfo)
                ArenaInfoData.RequestData(false)
            else
                Global.ShowError(msg.code)
            end
        end, false)
    end)

    SetClickCallback(_ui.btn_help,function()
        Arena_Help.Show(GOV_Help.HelpModeType.ArenaHelpDesc)
    end)

    SetClickCallback(_ui.formationButton.gameObject, function(go)
        BattleFormation.Show()
    end)
    SetClickCallback(_ui.rankObject.gameObject, function(go)
        RankList.Show()
    end)
    SetClickCallback(_ui.historyObject, function(go)
        _ui.historyObjectRed:SetActive(false)
        BattleHistory.Show()
    end)

    SetClickCallback(_ui.shopButton.gameObject, function(go)
        SlgBag.Show(4)
    end)

    _ui.timer = Timer.New(SecondUpdate, 1, -1)
    _ui.timer:Start()
    ArenaInfoData.AddListener(LoadUI)
    _ui.historyObjectRed:SetActive(false)
    CheckHistoryListRed()
end

function ShowHistoryListRed(show)
    if _ui ~= nil then
        _ui.historyObjectRed:SetActive(show)
    end
end 

function CheckHistoryListRed()
    BattleHistory.ReqBattleList(function()
        if _ui ~= nil then
            _ui.historyObjectRed:SetActive(BattleHistory.CheckRedPot())
        end
    end)
end 

function Start()
    LoadUI()
    _ui.resultObject:SetActive(false)
    _ui.resultObject:GetComponent("UIPanel").alpha = 1
    local TweenAlpha = _ui.resultObject:GetComponent("TweenAlpha")
    TweenAlpha.enabled = true;
    TweenAlpha:ResetToBeginning()
    if _ui.win and lastMyMsg.rank > lastEnemyMsg.rank then
        _ui.resultObject:SetActive(true)
        LoadEnemy(_ui.winPlayer, lastMyMsg)
        LoadEnemy(_ui.losePlayer, lastEnemyMsg)
        _ui.winCoroutine = coroutine.start(function()
            coroutine.wait(0.833)
            lastMyMsg.rank, lastEnemyMsg.rank = lastEnemyMsg.rank, lastMyMsg.rank
            LoadEnemy(_ui.winPlayer, lastMyMsg)
            LoadEnemy(_ui.losePlayer, lastEnemyMsg)
            coroutine.wait(1)
            MessageBox.Show(Format(TextMgr:GetText(Text.ui_Arena_message), lastMyMsg.rank, lastEnemyMsg.rank - lastMyMsg.rank))
        end)
    else
        _ui.resultObject:SetActive(false)
    end
end

function Close()
    Global.ClearSupportPlayBack()
    _ui.timer:Stop()
    coroutine.stop(_ui.winCoroutine)
    ArenaInfoData.RemoveListener(LoadUI)
    if _ui.closeCallback ~= nil then
        _ui.closeCallback()
    end
    _ui = nil
end

function ForceSetWin(win)
    if _ui == nil then
        return
    end
    _ui.win = win or false
end

function Show(win, closeCallback)
    local req = BattleMsg_pb.MsgArenaRankListRequest()
    req.srank = 1
    req.count = 3
    Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgArenaRankListRequest, req, BattleMsg_pb.MsgArenaRankListResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            rankListMsg = msg
        else
            Global.ShowError(msg.code)
        end
    end, false)
    ArenaInfoData.RequestData(false, function()
        Global.OpenUI(_M)
        _ui.win = win or false
        _ui.closeCallback = closeCallback
    end)
end

module("ExistTest", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local SetClickCallback = UIUtil.SetClickCallback
local String = System.String
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter
local PlayerPrefs = UnityEngine.PlayerPrefs

local _ui, UpdateUI, UpdateRank, UpdatePage1, UpdatePage2, SearchPlayer, SharePlayer, SendFlower, StartBattle
local needshow = false
local searchCharId

function SetSearchCharId(id)
    if _ui ~= nil then
        SearchPlayer(1, nil, id)
    else
        searchCharId = id
    end
end

function IsNeedShow()
    if needshow then
        Show()
    end
end

local function CloseSelf()
    Global.CloseUI(_M)
    needshow = false
end

function Close()
    coroutine.stop(_ui.endlesslist1move)
    coroutine.stop(_ui.endlesslist2move)
    CountDown.Instance:Remove("ExistTest")
    CountDown.Instance:Remove("ExistTest_Share")
    CountDown.Instance:Remove("ExistTest_flower")
    ExistTestData.RemoveListener(UpdateRank)
    _ui = nil
end

function Awake()
    _ui = {}
    _ui.curpage = 1
    _ui.mask = transform:Find("mask").gameObject
    _ui.btn_close = transform:Find("Container/background/close btn").gameObject
    _ui.btn_help = transform:Find("Container/background/goal/wenhao").gameObject
    _ui.btn_fight = transform:Find("Container/background/fight").gameObject

    _ui.btn_page1 = transform:Find("Container/bg_top/page1 (1)").gameObject
    _ui.btn_page2 = transform:Find("Container/bg_top/page2 (1)").gameObject

    _ui.content1 = transform:Find("Container/content_rank1").gameObject
    _ui.scrollview1 = transform:Find("Container/content_rank1/Scroll View"):GetComponent("UIScrollView")
    _ui.scrollview1pos = _ui.scrollview1.transform.localPosition
    _ui.itemprefab1 = transform:Find("Container/content_rank1/listitem_supplyrank").gameObject
    _ui.none1 = transform:Find("Container/content_rank1/none").gameObject
    _ui.content2 = transform:Find("Container/content_rank2").gameObject
    _ui.scrollview2 = transform:Find("Container/content_rank2/Scroll View"):GetComponent("UIScrollView")
    _ui.scrollview2pos = _ui.scrollview2.transform.localPosition
    _ui.itemprefab2 = transform:Find("Container/content_rank2/listitem_supplyrank").gameObject
    _ui.none2 = transform:Find("Container/content_rank2/none").gameObject

    _ui.searchinput = transform:Find("Container/bg_top/search"):GetComponent("UIInput")
    _ui.btn_search = transform:Find("Container/bg_top/search/Sprite").gameObject
    _ui.searchresult = transform:Find("box")
    _ui.searchresult_mask = transform:Find("box/mask").gameObject
    _ui.searchresult_name = transform:Find("box/background/mid/name/label"):GetComponent("UILabel")
    _ui.searchresult_score = transform:Find("box/background/mid/flower/label"):GetComponent("UILabel")
    _ui.searchresult_rank = transform:Find("box/background/mid/rank/label"):GetComponent("UILabel")
    _ui.searchresult_sendflower = transform:Find("box/background/mid/button1").gameObject
    _ui.searchresult_share = transform:Find("box/background/mid/button2").gameObject
    _ui.searchresult_flowerlabel = transform:Find("box/background/mid/flower"):GetComponent("UILabel")

    _ui.share = transform:Find("share")
    _ui.share_mask = transform:Find("share/mask").gameObject
    _ui.share_label = transform:Find("share/background/mid/label"):GetComponent("UILabel")
    _ui.share_all = transform:Find("share/background/mid/button1").gameObject
    _ui.share_union = transform:Find("share/background/mid/button2").gameObject

    _ui.lefttime = transform:Find("Container/background/time"):GetComponent("UILabel")
    _ui.lefttime_text = TextMgr:GetText("ui_worldmap_42")

    _ui.reward = {}
    _ui.reward[2] = transform:Find("Container/background/reward/gold"):GetComponent("UILabel")
    _ui.reward[3] = transform:Find("Container/background/reward/res1"):GetComponent("UILabel")
    _ui.reward[4] = transform:Find("Container/background/reward/res2"):GetComponent("UILabel")
    _ui.reward[5] = transform:Find("Container/background/reward/res3"):GetComponent("UILabel")

    _ui.flower_label = transform:Find("Container/flower/time"):GetComponent("UILabel")

    ExistTestData.AddListener(UpdateRank)
end

function Start()
    SetClickCallback(_ui.mask, CloseSelf)
    SetClickCallback(_ui.btn_close, CloseSelf)
    SetClickCallback(_ui.btn_search, function() SearchPlayer(_ui.curpage, _ui.searchinput.value) end)
    SetClickCallback(_ui.searchresult_mask, function() _ui.searchresult.gameObject:SetActive(false) end)
    SetClickCallback(_ui.share_mask, function() _ui.share.gameObject:SetActive(false) end)
    SetClickCallback(_ui.btn_page1, function() _ui.curpage = 1 UpdateRank() end)
    SetClickCallback(_ui.btn_page2, function() _ui.curpage = 2 UpdateRank() end)
    SetClickCallback(_ui.btn_fight, StartBattle)
    SetClickCallback(_ui.btn_help, function()
        ExistTestHelp.Show()
    end)

    _ui.index1 = 0
    _ui.index2 = 0
    _ui.nextpage1 = 0
    _ui.nextpage2 = 0
    _ui.up1 = false
    _ui.up2 = false
    _ui.first1 = true
    _ui.first2 = true
    UpdateUI()
    --ExistTestData.RequestSurvivalUserRankList()
    _ui.data = ActivityData.GetExistTestActivity()
    if _ui.data ~= nil then
        CountDown.Instance:Add("ExistTest", _ui.data.endTime, function(t)
            if _ui.data.endTime <= Serclimax.GameTime.GetSecTime() then
                CloseSelf()
            else
                _ui.lefttime.text = _ui.lefttime_text .. t
            end
        end)
    end

    local changelist = ExistTestData.GetChangeList()
    local str = ""
    for i, v in kpairs(changelist) do
        if v == true then
            str = str .. TextMgr:GetText("ExistTest_3" .. i) .. "\n"
        end
    end
    if str ~= "" then
        MessageBox.Show(str)
    end
    ExistTestData.ResetChangeList()
    if searchCharId ~= nil then
        SearchPlayer(1, nil, searchCharId)
        searchCharId = nil
    else
        ExistTestData.RequestSurvivalUserRankList()
    end
    if ExistTestData.IsFirstGuide() then
        GrowGuide.Show(_ui.btn_fight.transform, function() ExistTestData.SetFirstGuide(false) end)
    end
end

UpdateUI = function()
    local data = ExistTestData.GetSurvivalUserRankList(1)
    if data ~= nil then
        for i, v in ipairs(data.rewardShow.items) do
            _ui.reward[v.id].text = v.num
        end
    end
    local data = ExistTestData.GetSurvivalUserRankList(2)
    if data ~= nil then
        for i, v in ipairs(data.rewardShow.items) do
            if _ui.reward[v.id] ~= nil then
                _ui.reward[v.id].text = Global.ExchangeValue(v.num)
            end
        end
    end
    
    UpdateRank()
end

UpdateRank = function(type)
    if _ui == nil then
        return
    end
    if type == nil or _ui.curpage == type then
        _ui.flowercount, _ui.flowercountmax = ExistTestData.GetSendFlowerCount()
        if _ui.flowercount ~= nil and _ui.flowercountmax ~= nil then
            if _ui.flowercount > 0 then
                CountDown.Instance:Remove("ExistTest_flower")
                _ui.flower_label.text = _ui.flowercount .. "/" .. _ui.flowercountmax
            else
                CountDown.Instance:Add("ExistTest_flower", Global.GetFiveOclockCooldown(), CountDown.CountDownCallBack(function(t)
                    if t == "00:00:00" then
                        CountDown.Instance:Remove("ExistTest_flower")
                    else
                        _ui.flower_label.text = "[ff0000]" .. t
                    end
                end))
            end
            _ui.content1:SetActive(_ui.curpage == 1)
            _ui.content2:SetActive(_ui.curpage == 2)
            if _ui.curpage == 1 then
                UpdatePage1()
            else
                UpdatePage2()
            end
        end
    end
end

UpdatePage1 = function(inputdata)
    local data = ExistTestData.GetSurvivalUserRankList(1)
    if inputdata ~= nil then
        data = inputdata
    end
    if data ~= nil then
        local setBtnState = function(btn, type, enabled)
            local bs = btn.transform:GetComponent("UISprite")
            local bb = btn.transform:GetComponent("BoxCollider")
            bs.spriteName = enabled and ("btn_" .. type) or "btn_4"
            bb.enabled = enabled
        end
        local updateitem = function(prefab, index, rankdata)
            prefab.transform:Find("Rank/rank1").gameObject:SetActive(index == 1)
            prefab.transform:Find("Rank/crown").gameObject:SetActive(index == 1)
            prefab.transform:Find("Rank/rank2").gameObject:SetActive(index == 2)
            prefab.transform:Find("Rank/rank3").gameObject:SetActive(index == 3)
            prefab.transform:Find("Rank/rankother").gameObject:SetActive(index >= 4)
            prefab.transform:Find("Rank/rankother"):GetComponent("UILabel").text = index
            prefab.transform:Find("name"):GetComponent("UILabel").text = "[EFCD61]" .. (String.IsNullOrEmpty(rankdata.guildBanner) and "[---]" or ("[" .. rankdata.guildBanner .. "]")) .. "[-]" .. rankdata.name
            prefab.transform:Find("flag"):GetComponent("UITexture").mainTexture = UIUtil.GetNationalFlagTexture(rankdata.nationality)
            prefab.transform:Find("bg").gameObject:SetActive(index % 2 == 1)
            local scoreobj = prefab.transform:Find("reward/number")
            if scoreobj == nil then
                scoreobj = prefab.transform:Find("reward/box/number")
            end
            scoreobj:GetComponent("UILabel").text = rankdata.score
            local btn_send = prefab.transform:Find("button1").gameObject
            SetClickCallback(btn_send, function()
                SendFlower(rankdata.charId)
            end)
            setBtnState(btn_send, "2small", _ui.flowercount > 0)
            local btn_share = prefab.transform:Find("button2").gameObject
            SetClickCallback(btn_share, function()
                SharePlayer(rankdata)
            end)
            local selected = prefab.transform:Find("bg (1)")
            if selected ~= nil then
                selected.gameObject:SetActive(index == _ui.searchindex1)
            end
            --btn_share:SetActive(index == data.myRank.rank)
            local sharetime = prefab.transform:Find("button2/time")
            if sharetime ~= nil then
                sharetime = sharetime:GetComponent("UILabel")
                if ExistTestData.GetShareTime() > Serclimax.GameTime.GetSecTime() then
                    setBtnState(btn_share, 5, false)
                    CountDown.Instance:Add("ExistTest_Share", ExistTestData.GetShareTime(), function(t)
                        if ExistTestData.GetShareTime() < Serclimax.GameTime.GetSecTime() then
                            setBtnState(btn_share, 5, true)
                            sharetime.text = ""
                            CountDown.Instance:Remove("ExistTest_Share")
                        else
                            sharetime.text = string.sub(t, -5)
                        end
                    end)
                else
                    setBtnState(btn_share, 5, true)
                    sharetime.text = ""
                end
            end
        end
        local updateListItem = function(prefab, index)
            local rankdata = data.rankList[index]
            if rankdata ~= nil then
                updateitem(prefab, rankdata.rank, rankdata)
            end
            local mindex = _ui.endlesslist1:GetMiddleIndex()
            if mindex ~= _ui.index1 then
                if _ui.index1 > mindex then
                    local nextpage = math.floor((_ui.index1 + ExistTestData.GetStartRank(1) - 1) / 10)
                    if _ui.nextpage1 ~= nextpage then
                        ExistTestData.SurvivalUserRankListRequest(1, nextpage)
                        _ui.nextpage1 = nextpage
                    end
                else
                    local nextpage = math.floor((_ui.index1 + ExistTestData.GetStartRank(1) - 1) / 10) + 2
                    if _ui.nextpage1 ~= nextpage then
                        ExistTestData.SurvivalUserRankListRequest(1, nextpage)
                        _ui.nextpage1 = nextpage
                    end
                end
                if _ui.index1 == 0 then
                    if ExistTestData.GetStartRank(1) > 1 then
                        ExistTestData.SurvivalUserRankListRequest(1, math.floor((_ui.index1 + ExistTestData.GetStartRank(1) - 1) / 10))
                    end
                end
                _ui.index1 = mindex
            end
        end
        if _ui.endlesslist1 == nil then
            _ui.endlesslist1 = EndlessList(_ui.scrollview1, _ui.scrollview1pos.x, _ui.scrollview1pos.y)
        end
        _ui.endlesslist1:SetItem(_ui.itemprefab1, #data.rankList, updateListItem, true)
        _ui.endlesslist1:SetClickCallback(function(index)
            local rankdata = data.rankList[index]
            OtherInfo.RequestShow(rankdata.charId)
        end)
        local myprefab = transform:Find("Container/content_rank1/Myrank/myranklist").gameObject
        if data.myRank == nil or data.myRank.rank == 0 then
            myprefab:SetActive(false)
        else
            myprefab:SetActive(true)
            updateitem(myprefab, data.myRank.rank, data.myRank)
        end
        _ui.none1:SetActive(#data.rankList == 0)
        if _ui.first1 then
            _ui.scrollview1:ResetPosition()
            _ui.first1 = false
        end
        _ui.endlesslist1:Refresh()
        if inputdata == nil then
            if _ui.laststart1 ~= nil and _ui.laststart1 > ExistTestData.GetStartRank(1) then
                _ui.up1 = true
            end
            if _ui.up1 then
                _ui.endlesslist1:MoveTo(_ui.index1 + 1 + _ui.laststart1 - ExistTestData.GetStartRank(1))
                _ui.up1 = false
            end
            _ui.laststart1 = ExistTestData.GetStartRank(1)
        end
        if _ui.searchindex1 ~= nil then
            _ui.endlesslist1:MoveTo(_ui.searchindex1)
            coroutine.stop(_ui.endlesslist1move)
            _ui.endlesslist1move = coroutine.start(function()
                coroutine.wait(1)
                _ui.searchindex1 = nil
            end)
        end
    else
        transform:Find("Container/content_rank1/Myrank/myranklist").gameObject:SetActive(false)
    end
end

UpdatePage2 = function(inputdata)
    local data = ExistTestData.GetSurvivalUserRankList(2)
    if inputdata ~= nil then
        data = inputdata
    end
    if data ~= nil then
        local updateitem = function(prefab, index, rankdata)
            prefab.transform:Find("Rank/rank1").gameObject:SetActive(index == 1)
            prefab.transform:Find("Rank/crown").gameObject:SetActive(index == 1)
            prefab.transform:Find("Rank/rank2").gameObject:SetActive(index == 2)
            prefab.transform:Find("Rank/rank3").gameObject:SetActive(index == 3)
            prefab.transform:Find("Rank/rankother").gameObject:SetActive(index >= 4)
            prefab.transform:Find("Rank/rankother"):GetComponent("UILabel").text = index
            prefab.transform:Find("name"):GetComponent("UILabel").text = "[EFCD61]" .. (String.IsNullOrEmpty(rankdata.guildBanner) and "[---]" or ("[" .. rankdata.guildBanner .. "]")) .. "[-]" .. rankdata.name
            prefab.transform:Find("flag"):GetComponent("UITexture").mainTexture = UIUtil.GetNationalFlagTexture(rankdata.nationality)

            prefab.transform:Find("reward/box/number"):GetComponent("UILabel").text = string.format("%02d", math.floor(rankdata.score / 60)) .. ":" .. string.format("%02d", rankdata.score % 60)
            prefab.transform:Find("bg").gameObject:SetActive(index % 2 == 1)
            local selected = prefab.transform:Find("bg (1)")
            if selected ~= nil then
                selected.gameObject:SetActive(index == _ui.searchindex2)
            end
        end
        local updateListItem = function(prefab, index)
            local rankdata = data.rankList[index]
            if rankdata ~= nil then
                updateitem(prefab, rankdata.rank, rankdata)
            end
            local mindex = _ui.endlesslist2:GetMiddleIndex()
            if mindex ~= _ui.index2 then
                if _ui.index2 > mindex then
                    local nextpage = math.floor((_ui.index2 + ExistTestData.GetStartRank(2) - 1) / 10)
                    if _ui.nextpage2 ~= nextpage then
                        ExistTestData.SurvivalUserRankListRequest(2, nextpage)
                        _ui.nextpage2 = nextpage
                    end
                else
                    local nextpage = math.floor((_ui.index2 + ExistTestData.GetStartRank(2) - 1) / 10) + 2
                    if _ui.nextpage2 ~= nextpage then
                        ExistTestData.SurvivalUserRankListRequest(2, nextpage)
                        _ui.nextpage2 = nextpage
                    end
                end
                if _ui.index2 == 0 then
                    if ExistTestData.GetStartRank(2) > 1 then
                        ExistTestData.SurvivalUserRankListRequest(2, math.floor((_ui.index2 + ExistTestData.GetStartRank(2) - 1) / 10))
                    end
                end
                _ui.index2 = mindex
            end
        end
        if _ui.endlesslist2 == nil then
            _ui.endlesslist2 = EndlessList(_ui.scrollview2, _ui.scrollview2pos.x, _ui.scrollview2pos.y)
        end
        _ui.endlesslist2:SetItem(_ui.itemprefab2, #data.rankList, updateListItem, true)
        _ui.endlesslist2:SetClickCallback(function(index)
            local rankdata = data.rankList[index]
            OtherInfo.RequestShow(rankdata.charId)
        end)
        local myprefab = transform:Find("Container/content_rank2/Myrank/myranklist").gameObject
        if data.myRank == nil or data.myRank.rank == 0 then
            myprefab:SetActive(false)
        else
            myprefab:SetActive(true)
            updateitem(myprefab, data.myRank.rank, data.myRank)
        end
        _ui.none2:SetActive(#data.rankList == 0)
        if _ui.first2 then
            _ui.scrollview2:ResetPosition()
            _ui.first2 = false
        end
        _ui.endlesslist2:Refresh()
        if inputdata == nil then
            if _ui.laststart2 ~= nil and _ui.laststart2 > ExistTestData.GetStartRank(2) then
                _ui.up2 = true
            end
            if _ui.up2 then
                _ui.endlesslist2:MoveTo(_ui.index2 + 1 + _ui.laststart2 - ExistTestData.GetStartRank(2))
                _ui.up2 = false
            end
            _ui.laststart2 = ExistTestData.GetStartRank(2)
        end
        if _ui.searchindex2 ~= nil then
            _ui.endlesslist2:MoveTo(_ui.searchindex2)
            coroutine.stop(_ui.endlesslist2move)
            _ui.endlesslist2move = coroutine.start(function()
                coroutine.wait(1)
                _ui.searchindex2 = nil
            end)
        end
    else
        transform:Find("Container/content_rank2/Myrank/myranklist").gameObject:SetActive(false)
    end
end

SearchPlayer = function(rankType, charName, charId)
    ExistTestData.SurvivalSearchUserRankRequest(rankType, charName, charId, function(rankdata)
        if #rankdata.rankList > 0 then
            _ui.index1 = 1
            _ui.index2 = 1
            _ui.nextpage1 = 0
            _ui.nextpage2 = 0
            _ui.up1 = false
            _ui.up2 = false
            _ui.first1 = true
            _ui.first2 = true
            _ui.searchindex1 = 0
            _ui.searchindex2 = 0
            local searchindex = 0
            for i, v in ipairs(rankdata.rankList) do
                if v.charId == charId or v.name == charName then
                    searchindex = v.rank
                end
            end
            if rankType == 1 then
                _ui.searchindex1 = searchindex
                if searchindex % 10 < 6 then
                    ExistTestData.SurvivalUserRankListRequest(1, rankdata.pageIndex - 1)
                end
                UpdatePage1()
            else
                _ui.searchindex2 = searchindex
                if searchindex % 10 < 6 then
                    ExistTestData.SurvivalUserRankListRequest(2, rankdata.pageIndex - 1)
                end
                UpdatePage2()
            end
        else
            FloatText.Show(TextMgr:GetText("ExistTest_22"), Color.white)
        end
    end)
end

SharePlayer = function(rankdata)
    _ui.share.gameObject:SetActive(true)
    local playerName = "[EFCD61]" .. (String.IsNullOrEmpty(rankdata.guildBanner) and "" or ("[" .. rankdata.guildBanner .. "]")) .. "[-]" .. rankdata.name
    _ui.share_label.text = String.Format(TextMgr:GetText("ExistTest_7"), playerName)
    local sendshare = function(chanel)
        local send = {}
        send.curChanel = chanel
        send.spectext = playerName .. "," .. rankdata.charId
        send.content = "ExistTest_1"
        send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
        send.chatType = 7
        send.senderguildname = ""
        
        if UnionInfoData.HasUnion() then
            send.senderguildname = UnionInfoData.GetData().guildInfo.banner
        end
        ExistTestData.SetShareTime()
        Chat.SendContent(send)
        FloatText.Show(TextMgr:GetText("ui_worldmap_83"), Color.green)
        _ui.share.gameObject:SetActive(false)
        UpdateRank()
    end
    SetClickCallback(_ui.share_all, function()
        sendshare(ChatMsg_pb.chanel_world)
    end)
    SetClickCallback(_ui.share_union, function()
        sendshare(ChatMsg_pb.chanel_guild)
    end)
end

SendFlower = function(charId)
    ExistTestData.SurvivalSendFlowerRequest(charId, function(reward)
        UpdateRank()
    end)
end

StartBattle = function()
    FunctionListData.IsFunctionUnlocked(301, function(isActive)
        if isActive then
            local actdata = ActivityData.GetActivityData(5)
            SelectArmy.SetAttackCallback(function(battleId, _teamType)
                        
                if TeamData.GetSelectedArmyCount(_teamType) == 0 then
                    local noSelectText = TextMgr:GetText(Text.selectunit_hint112)
                    Global.GAudioMgr:PlayUISfx("SFX_ui02", 1, false)
                    FloatText.Show(noSelectText, Color.red)
                    return
                end    
                

                local req = BattleMsg_pb.MsgBattleRandomPVEStartRequest()
                req.activityId = 5 -- ActivityID
                req.missionId = actdata.battle.battle[1].missionId 
                Global.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgBattleRandomPVEStartRequest, req, BattleMsg_pb.MsgBattleRandomPVEStartResponse, function(msg)
                    if msg.code ~= ReturnCode_pb.Code_OK then
                        Global.ShowError(msg.code)
                    else
                        local battleState = GameStateBattle.Instance
                        ActivityData.UpdateListData(msg.actInfo)
                        battleState:SetRandomBattleStartResponse(5,msg.chapterlevel,msg:SerializeToString())
                        local _battleId = msg.chapterlevel
                        local battleData = TableMgr:GetBattleData(_battleId)
                        local unlockArmyId
                        local unlockHeroId
                        if not ChapterListData.HasLevelExplored(_battleId) and battleData.unlock ~= "NA" then
                            local unlockList = string.split(battleData.unlock, ",")
                            if unlockList[1] == "1" then
                                unlockArmyId = tonumber(unlockList[2])
                            elseif unlockList[1] == "2" then
                                unlockHeroId = tonumber(unlockList[2])
                            end
                        end
                        battleState.IsPvpBattle = false
                        GUIMgr:CloseAllMenu()

                        battleState.BattleId =  _battleId

                        local teamData = TeamData.GetDataByTeamType(_teamType)
                        local selectedArmyList = {}
                        for _, v in ipairs(teamData.memArmy) do
                            table.insert(selectedArmyList, v.uid)
                        end

                        local heroInfoDataList = battleState.heroInfoDataList
                        heroInfoDataList:Clear()
                        for _, v in ipairs(teamData.memHero) do
                            local heroMsg = GeneralData.GetGeneralByUID(v.uid) -- HeroListData.GetHeroDataByUid(v.uid)
                            heroInfoDataList:Add(heroMsg:SerializeToString())
                        end

                        if unlockHeroId ~= nil and heroInfoDataList.Count < 5 then
                            local heroMsg = Common_pb.HeroInfo()
                            heroMsg.uid = 0
                            heroMsg.baseid = unlockHeroId
                            heroMsg.star = 1
                            heroMsg.exp = 0
                            heroMsg.grade = 1
                            heroMsg.skill.godSkill.id = tonumber(TableMgr:GetHeroData(unlockHeroId).skillId)
                            heroMsg.skill.godSkill.level = 1
                            heroInfoDataList:Add(heroMsg:SerializeToString())
                        end

                        AttributeBonus.CollectBonusInfo()
                        local battleBonus = AttributeBonus.CalBattleBonus(_battleId)
                        local battleArgs = 
                        {
                            loadScreen = "1",
                            selectedArmyList = selectedArmyList,
                            battleBonus = 
                            {
                                bulletAddition = battleBonus.SummonEnergy,
                                energyAddition = battleBonus.SkillEnergy,
                                bulletRecover = battleBonus.SummonEnergyRecovery
                            }
                        }
                        Main.Instance:ChangeGameState(battleState, cjson.encode(battleArgs),nil)
                        needshow = true
                    end
                end)
            end)
            SelectHero.Show(Common_pb.BattleTeamType_Main,true,nil,true)
        else
            MessageBox.Show(TextMgr:GetText("ExistTest_16"), function() 
                CloseSelf()
                MainCityUI.CheckWorldMap(false, function()
                    maincity.SetTargetBuild(1, false, nil, false, false, true, function()
                        GUIMgr:CreateMenu("BuildingUpgrade", false)
                        MainCityUI.HideCityMenu()
                        BuildingUpgrade.OnCloseCB = function()
                            MainCityUI.RemoveMenuTarget()
                            BuildingShowInfoUI.Refresh()
                        end
                    end)
                end)
            end, function() end, TextMgr:GetText("mission_go"), TextMgr:GetText("common_hint2"), "btn_3", "btn_1", true)
        end
    end)
end

function Show()
    local data = ActivityData.GetActivityData(5)
    if data == nil then
        ActivityData.RequestActivityData(5)
    end
    local data = ExistTestData.GetSurvivalUserRankList(1)
    if data ~= nil then
        Global.OpenUI(_M)
    else
        ExistTestData.CheckSurvivalUserRankList(Global.OpenUI(_M))
    end
end

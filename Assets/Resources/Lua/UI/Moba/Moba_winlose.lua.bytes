module("Moba_winlose", package.seeall)

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

local _ui, showReward, UpdateRank, InitScore, UpdateScore

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
    Global.CloseUI(_M)
end

function Hide()
	Global.CloseUI(_M)
end

function Close()
    _ui = nil
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Awake()
    _ui = {}
    _ui.win = {}
    _ui.win.gameObject = transform:Find("bg_win").gameObject
    _ui.win.mask = transform:Find("bg_win/bg/mask").gameObject

    _ui.fail = {}
    _ui.fail.gameObject = transform:Find("bg_fail").gameObject
    _ui.fail.mask = transform:Find("bg_fail/mask").gameObject

    _ui.reward = {}
    _ui.reward.gameObject = transform:Find("reward").gameObject
    _ui.reward.animator = _ui.reward.gameObject:GetComponent("Animator")
    _ui.reward.rank_icon = transform:Find("reward/bg/now"):GetComponent("UITexture")
    _ui.rank_name = transform:Find("reward/bg/rankname"):GetComponent("UILabel")
    _ui.reward.stars = {}
    for i = 1, 6 do
        local staritem = {}
        staritem.bg = transform:Find(string.format("reward/bg/stars/bg (%d)", i)).gameObject
        staritem.star = transform:Find(string.format("reward/bg/stars/bg (%d)/star", i)).gameObject
        if i == 6 then
            staritem.num = transform:Find(string.format("reward/bg/stars/bg (%d)/NUMBER", i)):GetComponent("UILabel")
        else
            staritem.effect = transform:Find(string.format("reward/bg/stars/bg (%d)/Starlizi", i)).gameObject
            staritem.ta = staritem.star:GetComponent("TweenAlpha")
            staritem.ts = staritem.star:GetComponent("TweenScale")
            staritem.tp = staritem.star:GetComponent("TweenPosition")
        end
        _ui.reward.stars[i] = staritem
    end
    _ui.reward.btn_continue = transform:Find("reward/btn_continue").gameObject
    _ui.draw = transform:Find("reward/bg/draw").gameObject
    _ui.pointCenter = transform:Find("reward/bg/rewards/pointbg/pointCenter").gameObject
    _ui.point = transform:Find("reward/bg/rewards/pointbg/pointCenter/point").gameObject
    _ui.point:SetActive(false)
    _ui.proceed = transform:Find("reward/bg/rewards/pointbg/proceed"):GetComponent("UISprite")
    _ui.guangquan = transform:Find("reward/bg/rewards/pointbg/proceed/guangquan"):GetComponent("UITexture")
    _ui.proceed_num = transform:Find("reward/bg/rewards/pointbg/number"):GetComponent("UILabel")
    _ui.proceed_hint = transform:Find("reward/bg/rewards/pointbg/hint").gameObject

    _ui.bravepoint = transform:Find("reward/bg/rewards/pointbg/Label/number"):GetComponent("UILabel")
    _ui.rankpoint = transform:Find("reward/bg/rewards/pointbg/Label (1)/number"):GetComponent("UILabel")
    _ui.ranktitle = transform:Find("reward/bg/rewards/pointbg/Label (1)"):GetComponent("UILabel")
    _ui.otherpoint = transform:Find("reward/bg/rewards/pointbg/Label (2)/number"):GetComponent("UILabel")

    _ui.grid = transform:Find("reward/bg/rewards/pointbg/gain/Grid"):GetComponent("UIGrid")
    _ui.item = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
    _ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
    
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()
    SetClickCallback(_ui.win.mask, function()
        _ui.win.gameObject:SetActive(false)
        showReward()
    end)
    SetClickCallback(_ui.fail.mask, function()
        _ui.fail.gameObject:SetActive(false)
        showReward()
    end)
    SetClickCallback(_ui.reward.btn_continue, function()
        CloseSelf()
        Mobaconclusion.Show(MobaData.GetMobaUserResult())
    end)
    _ui.reward.btn_continue:SetActive(false)

    _ui.showData = {}
    _ui.showData.data = MobaData.GetMobaMatchInfo()
    _ui.showData.rankData = TableMgr:GetMobaRankDataByID(_ui.showData.data.info.level)
    UpdateRank()
    
    InitScore()

    _ui.data = MobaData.GetMobaUserResult()
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
    _ui.reward.gameObject:SetActive(_ui.selfResult.win == 0)
    _ui.draw:SetActive(_ui.selfResult.win == 0)
    if _ui.selfResult.win == 0 then
        showReward()
    end
    _ui.bravepoint.text = "+" .. (_ui.selfResult.bravepoint + _ui.selfResult.goldpoint)
    _ui.rankpoint.text = "+" .. _ui.selfResult.bravepoint
    _ui.otherpoint.text = "+" .. _ui.selfResult.goldpoint

    _ui.ranktitle.text = System.String.Format(TextMgr:GetText("ui_moba_110"), _ui.selfResult.rank)

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

local function AddStar(needEff)
    if needEff then
        _ui.reward.animator:SetTrigger("save")
        coroutine.wait(1.2)
    end
    if _ui.showData.curmax <= 5 then
        if _ui.showData.data.info.star < _ui.showData.curmax then
            _ui.showData.data.info.star = _ui.showData.data.info.star + 1
            local i = _ui.showData.data.info.star
            _ui.reward.stars[i].star:SetActive(true)
            if _ui.reward.stars[i].ta then
                _ui.reward.stars[i].ta:PlayForward(true)
                _ui.reward.stars[i].ts:PlayForward(true)
                _ui.reward.stars[i].tp:PlayForward(true)
                _ui.reward.stars[i].effect:SetActive(false)
            end
            coroutine.wait(0.25)
            _ui.reward.stars[i].effect:SetActive(true)
        else
            _ui.reward.animator:SetTrigger("rank")
            coroutine.wait(1.03)
            _ui.showData.data.info.level = _ui.showData.data.info.level + 1
            _ui.showData.data.info.star = 1
            _ui.showData.rankData = TableMgr:GetMobaRankDataByID(_ui.showData.data.info.level)
            _ui.showData.StarupNeed = _ui.showData.rankData.StarupNeed
            _ui.showData.ProtectNeed = _ui.showData.rankData.ProtectNeed
            UpdateRank()
            coroutine.wait(1.12)
        end
    else
        _ui.showData.data.info.star = _ui.showData.data.info.star + 1
        _ui.reward.stars[6].num.text = _ui.showData.data.info.star
    end
end

local function SubStar()
    if _ui.showData.curmax <= 5 then
        if _ui.showData.data.info.bravepoint >= _ui.showData.ProtectNeed then
            _ui.showData.data.info.bravepoint = _ui.showData.data.info.bravepoint - _ui.showData.ProtectNeed
            _ui.reward.animator:SetTrigger("save")
            coroutine.wait(1.2)
        else
            if _ui.showData.data.info.star > 0 then
                local i = _ui.showData.data.info.star
                _ui.showData.data.info.star = _ui.showData.data.info.star - 1
                _ui.reward.stars[i].star:SetActive(false)
                coroutine.wait(0.25)
            else
                if _ui.showData.data.info.level > 1 then
                    _ui.reward.animator:SetTrigger("brake")
                    coroutine.wait(1.03)
                    _ui.showData.data.info.level = math.max(_ui.showData.data.info.level - 1, 1)
                    _ui.showData.data.info.star = _ui.showData.rankData.RankStar
                    _ui.showData.rankData = TableMgr:GetMobaRankDataByID(_ui.showData.data.info.level)
                    _ui.showData.StarupNeed = _ui.showData.rankData.StarupNeed
                    _ui.showData.ProtectNeed = _ui.showData.rankData.ProtectNeed
                    UpdateRank()
                    coroutine.wait(1.12)
                end
            end
        end
    else
        if _ui.showData.data.info.bravepoint >= _ui.showData.ProtectNeed then
            _ui.showData.data.info.bravepoint = _ui.showData.data.info.bravepoint - _ui.showData.ProtectNeed
            _ui.reward.animator:SetTrigger("save")
            coroutine.wait(1.2)
        else
            _ui.showData.data.info.star = _ui.showData.data.info.star - 1
            _ui.reward.stars[6].num.text = _ui.showData.data.info.star
        end
    end
end

local function Merge(data1,data2)
    data1.reputation = data2.reputation
    data1.hiderecord = data2.hiderecord
    data1.wincount = data2.wincount
    data1.level = data2.level
    data1.star = data2.star
    data1.bravepoint = data2.bravepoint
    data1.tiecount = data2.tiecount
    data1.evalue = data2.evalue
    data1.totalscore = data2.totalscore
    data1.totalkill = data2.totalkill
    data1.totaldead = data2.totaldead
    data1.losecount = data2.losecount
    data1.maxscore = data2.maxscore
    data1.battlecount = data2.battlecount
    data1.firstcount = data2.firstcount
end

local function ProcessScore()
    while _ui.showData.data.info.level < _ui.data.mobaUser.level or _ui.showData.data.info.star < _ui.data.mobaUser.star do
        print(_ui.showData.data.info.level, _ui.data.mobaUser.level, _ui.showData.data.info.star, _ui.data.mobaUser.star)
        for i = _ui.showData.data.info.bravepoint, _ui.showData.rankData.StarupNeed, _ui.addstep do
            _ui.showData.bravepoint = i
            _ui.showData.data.info.bravepoint = i
            coroutine.step()
        end
        _ui.showData.bravepoint = 0
        _ui.showData.data.info.bravepoint = 0
        AddStar(true)
    end
    for i = _ui.showData.data.info.bravepoint, _ui.data.mobaUser.bravepoint, _ui.addstep do
        _ui.showData.bravepoint = i
        _ui.showData.data.info.bravepoint = i
        coroutine.step()
    end
    _ui.showData.bravepoint = _ui.data.mobaUser.bravepoint
    _ui.showData.data.info.bravepoint = _ui.data.mobaUser.bravepoint
end

showReward = function()
    _ui.reward.gameObject:SetActive(true)
    coroutine.start(function()
        coroutine.wait(1)
        _ui.canupdate = true
        print()
        if _ui.selfResult.win == 1 then
            AddStar()
            ProcessScore()
        elseif _ui.selfResult.win == -1 then
            SubStar()
            ProcessScore()
        elseif _ui.selfResult.win == 0 then
            ProcessScore()
        end
        Merge(_ui.showData.data.info,_ui.data.mobaUser)
        _ui.reward.btn_continue:SetActive(true)
    end)
end

UpdateRank = function()
    _ui.showData.curmax = _ui.showData.rankData.RankStar
    if _ui.showData.curmax <= 5 then
        for i = 1, _ui.showData.rankData.RankStar do
            _ui.reward.stars[i].bg:SetActive(true)
            _ui.reward.stars[i].star:SetActive(i <= _ui.showData.data.info.star)
            UIUtil.SetStarPos(_ui.reward.rank_icon, _ui.reward.stars[i].bg, _ui.showData.rankData.RankStar, i, 103, 33)
            _ui.reward.stars[i].ta.enabled = false
            _ui.reward.stars[i].ts.enabled = false
            _ui.reward.stars[i].tp.enabled = false
        end
        for i = _ui.showData.rankData.RankStar + 1, 5 do
            _ui.reward.stars[i].bg:SetActive(false)
        end
        _ui.reward.stars[6].bg:SetActive(false)
    else
        for i = 1, 5 do
            _ui.reward.stars[i].bg:SetActive(false)
        end
        _ui.reward.stars[6].bg:SetActive(true)
        _ui.reward.stars[6].num.text = _ui.showData.data.info.star
    end
    _ui.addstep = math.floor(_ui.showData.rankData.StarupNeed / 30 + 0.5)
    _ui.reward.rank_icon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "Moba/", _ui.showData.rankData.RankIcon)
    _ui.rank_name.text = TextMgr:GetText(_ui.showData.rankData.RankName)

    local pointnum = math.floor(_ui.showData.rankData.StarupNeed / _ui.showData.rankData.ProtectNeed)
    local pointAngle = 360 * (_ui.showData.rankData.ProtectNeed / _ui.showData.rankData.StarupNeed)
    local pointActNum = _ui.showData.data.info.bravepoint / _ui.showData.rankData.ProtectNeed
    
    _ui.proceed_hint:SetActive(pointActNum >= 1)
    _ui.guangquan.gameObject:SetActive(pointActNum >= 1)
    if _ui.pointList == nil then
        _ui.pointList = {}
    end
    for i = 1, pointnum do
        if _ui.pointList[i] == nil then
            _ui.pointList[i] = {}
            _ui.pointList[i].transform = NGUITools.AddChild(_ui.pointCenter, _ui.point).transform
            _ui.pointList[i].activeP = _ui.pointList[i].transform:Find("active").gameObject
        end
        _ui.pointList[i].transform.gameObject:SetActive(true)
        
        _ui.pointList[i].transform.localEulerAngles = Vector3(0, 0, - pointAngle * (i - 1) - 180)
        _ui.pointList[i].activeP:SetActive(pointActNum > (i-1) and i ~= 1)
    end
    for i = pointnum + 1, #_ui.pointList do
        _ui.pointList[i].transform.gameObject:SetActive(false)
    end
end

InitScore = function()
    _ui.showData.bravepoint = _ui.showData.data.info.bravepoint
    _ui.proceed_num.text = _ui.showData.data.info.bravepoint
    _ui.proceed.fillAmount = _ui.showData.data.info.bravepoint / _ui.showData.rankData.StarupNeed
    _ui.guangquan.fillAmount = _ui.proceed.fillAmount
    _ui.showData.StarupNeed = _ui.showData.rankData.StarupNeed
    _ui.showData.ProtectNeed = _ui.showData.rankData.ProtectNeed
    
end

function Update()
    if not _ui.canupdate then
        return
    end
    _ui.proceed_num.text = _ui.showData.bravepoint
    _ui.proceed.fillAmount = _ui.showData.bravepoint / _ui.showData.StarupNeed
    _ui.guangquan.fillAmount = _ui.proceed.fillAmount
    _ui.guangquan.gameObject:SetActive(_ui.showData.bravepoint >= _ui.showData.ProtectNeed)

    for i, v in ipairs(_ui.pointList) do
        v.activeP:SetActive(_ui.showData.bravepoint >= _ui.showData.ProtectNeed * (i - 1) and i ~= 1)
    end
end

function Show()
    Global.OpenUI(_M)
end
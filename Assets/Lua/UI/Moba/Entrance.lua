module("Entrance", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local PlayerPrefs = UnityEngine.PlayerPrefs
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String
local _ui, LoadUI
OnCloseCB = nil

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
    CountDown.Instance:Remove("Entrance")
    MobaData.RemoveListener(LoadUI)
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    _ui = nil
    if OnCloseCB ~= nil then
        OnCloseCB()
        OnCloseCB = nil
    end
end

function Awake()
    _ui = {}
    _ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
    _ui.mask = transform:Find("mask").gameObject
    _ui.time_root = transform:Find("Container/bg_frane/mid/countdown").gameObject
    _ui.time_des = transform:Find("Container/bg_frane/mid/countdown/time_des"):GetComponent("UILabel")
    _ui.time = transform:Find("Container/bg_frane/mid/countdown/time"):GetComponent("UILabel")

    _ui.stars = {}
    for i = 1, 6 do
        local staritem = {}
        staritem.bg = transform:Find(string.format("Container/bg_frane/mid/right/stars/bg (%d)", i)).gameObject
        staritem.star = transform:Find(string.format("Container/bg_frane/mid/right/stars/bg (%d)/star", i)).gameObject
        if i == 6 then
            staritem.num = transform:Find(string.format("Container/bg_frane/mid/right/stars/bg (%d)/NUMBER", i)):GetComponent("UILabel")
        end
        _ui.stars[i] = staritem
    end

    _ui.rank_icon = transform:Find("Container/bg_frane/mid/right/now"):GetComponent("UITexture")
    _ui.rank_name = transform:Find("Container/bg_frane/mid/right/rankname"):GetComponent("UILabel")

    _ui.btn_rank = transform:Find("Container/bg_frane/mid/right/buttom/btn_rank").gameObject
    _ui.btn_attend = transform:Find("Container/bg_frane/mid/right/buttom/btn_attend").gameObject
    _ui.btn_attend_label = transform:Find("Container/bg_frane/mid/right/buttom/btn_attend/Label"):GetComponent("UILabel")
    _ui.checkbox = transform:Find("Container/bg_frane/mid/right/buttom/bg_hint/checkbox"):GetComponent("UIToggle")

    _ui.pointCenter = transform:Find("Container/bg_frane/button/pointbg/pointCenter").gameObject
    _ui.point = transform:Find("Container/bg_frane/button/pointbg/pointCenter/point").gameObject
    _ui.point:SetActive(false)
    _ui.proceed = transform:Find("Container/bg_frane/button/pointbg/proceed"):GetComponent("UISprite")
    _ui.guangquan = transform:Find("Container/bg_frane/button/pointbg/proceed/guangquan"):GetComponent("UITexture")
    _ui.proceed_num = transform:Find("Container/bg_frane/button/pointbg/number"):GetComponent("UILabel")
    _ui.proceed_hint = transform:Find("Container/bg_frane/button/pointbg/hint").gameObject
    _ui.point_help = transform:Find("Container/bg_frane/button/mypoint/Sprite").gameObject

    _ui.btn_history = transform:Find("Container/bg_frane/button/history").gameObject

    _ui.grid = transform:Find("Container/bg_frane/button/reward/Scroll View/Grid"):GetComponent("UIGrid")
    _ui.item = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	_ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
	_ui.btn_help = transform:Find("Container/bg_frane/mid/desc/help"):GetComponent("UIButton")
	SetClickCallback(_ui.btn_help.gameObject, function()
        MapHelp.Open(2400, false, nil, nil, true)
    end)

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    MobaData.AddListener(LoadUI)
end

function Start()
    NGUITools.AddWidgetCollider(_ui.rank_icon.gameObject)
    SetClickCallback(_ui.rank_icon.gameObject, MobaRankreward.Show)
    SetClickCallback(_ui.btn_close, CloseSelf)
    SetClickCallback(_ui.mask, CloseSelf)
    SetClickCallback(_ui.checkbox.gameObject, function()
        PlayerPrefs.SetInt("Moba" .. MainData.GetCharId(), _ui.checkbox.value and 1 or 0)
        PlayerPrefs.Save()
        MainCityUI.UpdateMobaUI()
    end)
    SetClickCallback(_ui.point_help, function()
        GOV_Help.Show(GOV_Help.HelpModeType.MobaPoint)
    end)
    SetClickCallback(_ui.btn_rank, MobaRank.Show)
    SetClickCallback(_ui.btn_history, function()
        Mobahistory.Show(MainData.GetCharId())
    end)
    LoadUI()
    MapHelp.Open(2400, false, function()
        if PlayerPrefs.GetInt("MobaEntrance"..MainData.GetCharId()) ~= 1 then
            ActivityGrow.ExtraGuide(9006)
            PlayerPrefs.SetInt("MobaEntrance"..MainData.GetCharId(), 1)
        end
    end, nil, false)
end

LoadUI = function()
    _ui.checkbox.value = UnityEngine.PlayerPrefs.GetInt("Moba" .. MainData.GetCharId()) == 1
    local data = MobaData.GetMobaMatchInfo()
    if data.info.level == 0 then
        data.info.level = 1
    end
    local rankData = TableMgr:GetMobaRankDataByID(data.info.level)
    if data.status > 0 and data.time > 0 then
        _ui.time_root:SetActive(true)
        if data.status == 1 then
            _ui.time_des.text = TextMgr:GetText("ui_moba_6")
            _ui.btn_attend_label.text = TextMgr:GetText("ui_moba_8")
            if data.userstatus == 0 then
                UIUtil.SetBtnEnable(_ui.btn_attend:GetComponent("UIButton"), "btn_2", "btn_4", true)
                SetClickCallback(_ui.btn_attend, function() 
                    MobaData.RequestMobaBook()
                end)
            else
                SetClickCallback(_ui.btn_attend, function()
                    FloatText.Show(TextMgr:GetText("ui_moba_161"), Color.white)
                end)
                _ui.btn_attend_label.text = TextMgr:GetText("ui_moba_11")
                UIUtil.SetBtnEnable(_ui.btn_attend:GetComponent("UIButton"), "btn_2", "btn_4", false)
            end
        elseif data.status == 2 then
            _ui.time_des.text = TextMgr:GetText("ui_moba_7")
            _ui.btn_attend_label.text = TextMgr:GetText("ui_moba_9")
            if data.userstatus == 1 then
                UIUtil.SetBtnEnable(_ui.btn_attend:GetComponent("UIButton"), "btn_2", "btn_4", true)
                SetClickCallback(_ui.btn_attend, function() 
                    MobaData.RequestMobaApply()
                end)
            elseif data.userstatus == 0 then
                SetClickCallback(_ui.btn_attend, function() FloatText.Show(TextMgr:GetText("Code_Moba_MatchNotBook"), Color.white) end)
                UIUtil.SetBtnEnable(_ui.btn_attend:GetComponent("UIButton"), "btn_2", "btn_4", false)
            else
                SetClickCallback(_ui.btn_attend, function() FloatText.Show(TextMgr:GetText("ui_moba_162"), Color.white) end)
                _ui.btn_attend_label.text = TextMgr:GetText("ui_moba_12")
                UIUtil.SetBtnEnable(_ui.btn_attend:GetComponent("UIButton"), "btn_2", "btn_4", false)
            end
        elseif data.status == 3 then
            _ui.time_des.text = TextMgr:GetText("ui_moba_5")
            _ui.btn_attend_label.text = TextMgr:GetText("ui_moba_10")
            print(data.userstatus)
            if data.userstatus == 2 or data.userstatus == 3 then
                UIUtil.SetBtnEnable(_ui.btn_attend:GetComponent("UIButton"), "btn_2", "btn_4", true)
                SetClickCallback(_ui.btn_attend, function() 
                    MobaData.RequestMobaEnter(function()
                        CloseSelf()
                        Global.SetSlgMobaMode(1)
                        MainCityUI.ShowWorldMap(nil, nil, true, Mobaroleselect.Show)
                    end)
                end)
            elseif data.userstatus < 2 then
                SetClickCallback(_ui.btn_attend, function() FloatText.Show(TextMgr:GetText("ui_moba_151"), Color.white) end)
                UIUtil.SetBtnEnable(_ui.btn_attend:GetComponent("UIButton"), "btn_2", "btn_4", false)
            else
                SetClickCallback(_ui.btn_attend, function() FloatText.Show(TextMgr:GetText("Code_Moba_BattleOver"), Color.white) end)
                UIUtil.SetBtnEnable(_ui.btn_attend:GetComponent("UIButton"), "btn_2", "btn_4", false)
            end
        end
    else
        _ui.time_root:SetActive(false)
        _ui.btn_attend_label.text = TextMgr:GetText("ui_moba_8")
        SetClickCallback(_ui.btn_attend, function() FloatText.Show(TextMgr:GetText("ui_moba_147"), Color.white) end)
        UIUtil.SetBtnEnable(_ui.btn_attend:GetComponent("UIButton"), "btn_2", "btn_4", false)
    end
    if data.time > 0 then
        CountDown.Instance:Add("Entrance", data.time, function(t)
            local now = Serclimax.GameTime.GetSecTime()
            if data.time >= now then
                _ui.time.text = t
            else
                CountDown.Instance:Remove("Entrance")
                MobaData.RequestMobaMatchInfo()
            end
        end)
    end

    if rankData.RankStar <= 5 then
        for i = 1, rankData.RankStar do
            _ui.stars[i].bg:SetActive(true)
            _ui.stars[i].star:SetActive(i <= data.info.star)
            UIUtil.SetStarPos(_ui.rank_icon, _ui.stars[i].bg, rankData.RankStar, i, 103, 33)
        end
        for i = rankData.RankStar + 1, 5 do
            _ui.stars[i].bg:SetActive(false)
        end
        _ui.stars[6].bg:SetActive(false)
    else
        for i = 1, 5 do
            _ui.stars[i].bg:SetActive(false)
        end
        _ui.stars[6].bg:SetActive(true)
        _ui.stars[6].num.text = data.info.star
    end

    if _ui.inited == nil then
        for i, v in ipairs(data.reward.heros) do
            local heroData = TableMgr:GetHeroData(v.id)
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
        for _, item in ipairs(data.reward.items) do
            local obj = UIUtil.AddItemToGrid(_ui.grid.gameObject, item)
            SetClickCallback(obj.gameObject,function(go)
                if go == _ui.tipObject then
                    _ui.tipObject = nil
                else
                    _ui.tipObject = go
                    local itemData = TableMgr:GetItemData(item.id)
                    Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemData), text = TextUtil.GetItemDescription(itemData)}) 
                end
            end)
        end
        for ii, vv in ipairs(data.reward.armys) do
            local reward = vv
            local soldierData = TableMgr:GetBarrackData(reward.id, reward.level)
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
        _ui.grid:Reposition()
        _ui.inited = true
    end

    _ui.proceed_num.text = data.info.bravepoint
    _ui.proceed.fillAmount = data.info.bravepoint / rankData.StarupNeed
    _ui.guangquan.fillAmount = _ui.proceed.fillAmount
    _ui.rank_icon.mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "Moba/", rankData.RankIcon)
    _ui.rank_name.text = TextMgr:GetText(rankData.RankName)
    local pointnum = math.floor(rankData.StarupNeed / rankData.ProtectNeed)
    local pointAngle = 360 * (rankData.ProtectNeed / rankData.StarupNeed)
    local pointActNum = data.info.bravepoint / rankData.ProtectNeed
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
    _ui.proceed_hint:SetActive(pointActNum >= 1)
    _ui.guangquan.gameObject:SetActive(pointActNum >= 1)
end

function Show()
    Global.OpenUI(_M)
    MobaData.RequestMobaMatchInfo()
end

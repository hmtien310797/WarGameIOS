module("NewRace", package.seeall)

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

function LoadUI()
    local data = NewRaceData.GetData()
    local step = #data.dayRace
    for i, v in ipairs(data.dayRace) do
        _ui.steps[i].num.text = i
        _ui.steps[i].name.text = TextMgr:GetText(v.actname)
        _ui.steps[i].flag.color = data.actId == i and Color.white or Color.gray
    end
    for i = step + 1, 5 do
        _ui.steps[i].flag.gameObject:SetActive(false)
        transform:Find(string.format("Container/background/mid/right/form/rank_%d", i)).gameObject:SetActive(false)
        transform:Find(string.format("Container/background/mid/right/form/1/%d", i)).gameObject:SetActive(false)
    end
    _ui.stepGrid.cellWidth = math.floor(760 / (step - 1))
    _ui.stepGrid:Reposition()
    for i, v in ipairs(NewRaceData.GetRank().actrank) do
        if v.actId == 0 then
            _ui.ranknum.text = String.Format(TextMgr:GetText("NewRace_10"), v.rank == 0 and "- -" or (v.rank > 500 and "500+" or v.rank))
        else
            _ui.form[v.actId].text = v.rank == 0 and "- -" or (v.rank > 500 and "500+" or v.rank)
        end
    end
    if data.actId > 0 and data.actId <= #data.dayRace then
        _data = data.dayRace[data.actId]
        _ui.stepSlider.value = (data.actId - 1) / (step - 1)
        _ui.stepScore.text = String.Format(TextMgr:GetText("NewRace_5"), _data.score)
        _ui.stepTexture.mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", _data.background)
        _ui.stepName.text = TextMgr:GetText(_data.actname)
        CountDown.Instance:Add("NewRace", _data.endTime, function(t)
            if _data.endTime >= Serclimax.GameTime.GetSecTime() then
                _ui.stepTime.text = t
            end
        end)
        local maxScore = 0
        local childCount = _ui.scoreGrid.transform.childCount
        local itemTransforms = {}
        for i, v in ipairs(_data.reward) do
            local itemTransform 
            if i - 1 < childCount then
                itemTransform = _ui.scoreGrid.transform:GetChild(i - 1)
            else
                itemTransform = NGUITools.AddChild(_ui.scoreGrid.gameObject, _ui.scoreItem.gameObject).transform
            end
            if v.needScore > maxScore then
                maxScore = v.needScore
            end
            itemTransform:GetComponent("UISprite").spriteName = "icon_starbox_m_" .. (_data.score >= v.needScore and (v.isReward and "open" or "done") or "null")
            itemTransform:Find("ShineItem").gameObject:SetActive(_data.score >= v.needScore and not v.isReward)
            itemTransform:Find("number"):GetComponent("UILabel").text = v.needScore
            itemTransforms[i] = {}
            itemTransforms[i].transform = itemTransform
            itemTransforms[i].score = v.needScore
            SetClickCallback(itemTransform.gameObject, function()
                NewRaceReward.Show(v.droplist, function()
                    NewRaceData.RequestGetMilitaryRaceReward(data.actId, v.index)
                end, (_data.score >= v.needScore and (v.isReward and 3 or 2) or 1), v.needScore)
            end)
        end
        for i = #_data.reward, childCount - 1 do
            GameObject.Destroy(_ui.scoreGrid.transform:GetChild(i).gameObject)
        end
        for i, v in ipairs(itemTransforms) do
            v.transform.localPosition = Vector3(487 * v.score / maxScore, 0, 0)
        end

        _ui.scoreSlider.value = _data.score / maxScore
        _ui.sourceData = string.split(_data.rule, ";")
    end
end

function Awake()
    local mask = transform:Find("mask")
    SetClickCallback(mask.gameObject, function()
        CloseAll()
    end)
    _ui = {}
    _ui.stepSlider = transform:Find("Container/background/top/jindu"):GetComponent("UISlider")
    _ui.stepGrid = transform:Find("Container/background/top/Grid"):GetComponent("UIGrid")
    _ui.steps = {}
    for i = 1, 5 do
        _ui.steps[i] = {}
        _ui.steps[i].flag = transform:Find(string.format("Container/background/top/Grid/flag%d", i)):GetComponent("UISprite")
        _ui.steps[i].num = transform:Find(string.format("Container/background/top/Grid/flag%d/number", i)):GetComponent("UILabel")
        _ui.steps[i].name = transform:Find(string.format("Container/background/top/Grid/flag%d/name", i)):GetComponent("UILabel")
    end
    _ui.stepTexture = transform:Find("Container/background/mid/left/Texture"):GetComponent("UITexture")
    _ui.stepTime = transform:Find("Container/background/mid/left/time"):GetComponent("UILabel")
    _ui.stepName = transform:Find("Container/background/mid/left/name"):GetComponent("UILabel")
    _ui.stepScore = transform:Find("Container/background/mid/right/Label_1"):GetComponent("UILabel")
    _ui.scoreSourceBtn = transform:Find("Container/background/mid/right/button_1").gameObject
    _ui.scoreSlider = transform:Find("Container/background/mid/right/jindu"):GetComponent("UISlider")
    _ui.scoreGrid = transform:Find("Container/background/mid/right/Grid"):GetComponent("UIGrid")
    _ui.scoreItem = transform:Find("Container/background/mid/right/Grid/box1")

    _ui.form = {}
    for i = 1, 5 do
        _ui.form[i] = transform:Find(string.format("Container/background/mid/right/form/rank_%d", i)):GetComponent("UILabel")
    end

    _ui.rankBtn = transform:Find("Container/background/mid/right/form/rank_icon").gameObject
    _ui.ranknum = transform:Find("Container/background/mid/right/form/ranknumber"):GetComponent("UILabel")

    NewRaceData.AddListener(LoadUI)
    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()
    NewRaceData.NotifyUIOpened()
    SetClickCallback(_ui.scoreSourceBtn, function()
        NewRaceSource.Show(_ui.sourceData)
    end)
    SetClickCallback(_ui.rankBtn, NewRaceRank.Show)
end

function Close()
    CountDown.Instance:Remove("NewRace")
    RemoveDelegate(UICamera, "onClick", OnUICameraClick)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    NewRaceData.RemoveListener(LoadUI)
    Tooltip.HideItemTip()
    _ui = nil
end

function Show()
    NewRaceData.RequestData(false)
    Global.OpenUI(_M)
    LoadUI()
end

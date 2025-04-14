module("SandSelect", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local sandDataList

local _ui
local completedChapter
local completedChapterType

function LoadSandDataList()
    if sandDataList == nil then
        sandDataList = {{}, {}}
        for k, v in pairs(tableData_tSandWar.data) do
            table.insert(sandDataList[v.type], v)
        end
        for i, v in ipairs(sandDataList) do
            table.sort(v, function(v1, v2)
                return v1.Number < v2.Number
            end)
        end
    end
end

function GetSandIndexById(sandId)
    LoadSandDataList()
    for i, v in ipairs(sandDataList) do
        for ii, vv in ipairs(v) do
            if vv.id == sandId then
                return ii
            end
        end
    end
end

function GetExploringSandIndex()
    local chapterId = ChapterListData.GetExploringChapterId(_ui.chapterType == 1 and 1 or 5)
    local chapterData = tableData_tChapters.data[chapterId]
    return GetSandIndexById(chapterData.Sandid)
end

function Hide()
    Global.CloseUI(_M)
end

function SetCompletedChapter(chapter , chapterType)
    completedChapter = chapter
	completedChapterType = chapterType
end

function GetCompletedChapter()
    return completedChapter
end

function GetCompletedChapterType()
	return completedChapterType
end

function HaveBattleReward()
    return false
end

function LoadUI()
    if transform == nil
    then return end 
    local chapterType = _ui.chapterType
    local unlocked, message = ChapterListData.IsChapterUnlocked(1001)
    _ui.normalButton.gameObject:SetActive(chapterType == 2)
    _ui.eliteButton.gameObject:SetActive(chapterType == 1 and unlocked and GameFunctionSwitchData.Switch(GameFunctionSwitchData.GFSwitch.GFSwitch_EliteChapter))
    SetClickCallback(_ui.normalButton.gameObject, function(go)
        _ui.chapterType = 1
        LoadUI()
    end)
    SetClickCallback(_ui.eliteButton.gameObject, function(go)
        _ui.chapterType = 2
        LoadUI()
    end)
    _ui.exploringSandIndex = GetExploringSandIndex()
    if _ui.sandIndexList[chapterType] == nil then
        _ui.sandIndexList[chapterType] = _ui.exploringSandIndex
    end

    local sandIndex = _ui.sandIndexList[chapterType]
    _ui.bgTexture.mainTexture = ResourceLibrary:GetIcon("chapter/", sandIndex)
    local sandData = sandDataList[chapterType][sandIndex]
    local sandPrefab = ResourceLibrary.GetUIPrefab("ChapterSelect/Sand" .. sandIndex)
    GameObject.Destroy(_ui.sandObject)
    _ui.sandObject = NGUITools.AddChild(_ui.containerObject, sandPrefab)
    _ui.sandObject:SetActive(true)
    local bgDepth = transform:GetComponent("UIPanel").depth
    _ui.leftButton.gameObject:SetActive(sandIndex > 1)
    _ui.rightButton.gameObject:SetActive(sandIndex < _ui.exploringSandIndex)

    SetClickCallback(_ui.leftButton.gameObject, function(go)
        _ui.sandIndexList[chapterType] = sandIndex - 1
        LoadUI()
    end)

    SetClickCallback(_ui.rightButton.gameObject, function(go)
        _ui.sandIndexList[chapterType] = sandIndex + 1
        LoadUI()
    end)

    local sandStarCount = 0
    local totalSandStarCount = 0
    local sandTransform = _ui.sandObject.transform
    local chapterIndex = 1
    for v in string.gsplit(sandData.HaveChapterId, ",") do
        local chapterId = tonumber(v)
        local chapterData = tableData_tChapters.data[chapterId]

        local chapterTransform = sandTransform:Find("icon_Send" .. chapterIndex)
        local finishObject = chapterTransform:Find("bg_frane/finish").gameObject
        local iconSprite = chapterTransform:Find("bg_frane/icon"):GetComponent("UISprite")
        local iconAnimator = chapterTransform:Find("bg_frane/icon"):GetComponent("Animator")
        local bgObject = chapterTransform:Find("bg_frane/bg").gameObject
        local bgSprite = bgObject:GetComponent("UISprite")
        local nameLabel = chapterTransform:Find("bg_frane/bg/name"):GetComponent("UILabel")
        local starObject = chapterTransform:Find("bg_frane/bg/icon_star").gameObject
        local starLabel = chapterTransform:Find("bg_frane/bg/icon_star/num"):GetComponent("UILabel")

        local chapterMsg = ChapterListData.GetChapterData(chapterId)
        local locked = false
        for _, openLevelId in ipairs(table.map(string.split(chapterData.openLevelId, ","), tonumber)) do
            if openLevelId ~= 0 and not ChapterListData.HasLevelExplored(openLevelId) then
                locked = true
                break
            end
        end

        nameLabel.text = TextMgr:GetText(chapterData.nameLabel)
        local hasCompleted = ChapterListData.HasChapterCompleted(chapterData)
        finishObject:SetActive(hasCompleted)
        if hasCompleted then
            local arrowTransform = finishObject.transform:Find("jiantou")
            if arrowTransform ~= nil then
                arrowTransform.gameObject:SetActive(true)
                arrowTransform:Find("jiantou").gameObject:SetActive(completedChapter == chapterId)
                if completedChapter ~= chapterId then
                    arrowTransform:Find("jiantoucunzai"):GetComponent("ParticleSystem").startDelay = 0
                end
            end
        end
        local completing = completedChapter == chapterId
        local unlocking = false
        if completedChapter ~= nil then
            local completedData = tableData_tChapters.data[completedChapter]
            if completedData ~= nil then
                unlocking = completedData.number + 1 == chapterData.number
            end
        end
        iconAnimator.enabled = completing or unlocking
        if completing or unlocking then
            iconAnimator:SetTrigger(completing and "icon" or "jiesuo")
        end

        local starCount, totalStarCount = ChapterListData.GetChapterStarCount(chapterData)
        sandStarCount = sandStarCount + starCount
        totalSandStarCount = totalSandStarCount + totalStarCount
        starLabel.text = string.format("%d/%d", starCount, totalStarCount)
        SetClickCallback(chapterTransform.gameObject, function(go)
            if not locked then
                ChapterSelectUI.Show(chapterId)
            else
                FloatText.Show(TextMgr:GetText(Text.PVPChapter_Hero_ui4))
            end
        end)
        if chapterType == 1 then
            iconSprite.spriteName = locked and "icon_sand_hui" or "icon_sand"
        else
            iconSprite.spriteName = locked and "icon_sand_hui_elitech" or "icon_sand_elitech"
        end
        bgObject:SetActive(not locked)
        if not locked then
            bgSprite.spriteName = chapterType == 1 and "bg_sand" or "bg_sand_elitech"
        end
        chapterIndex = chapterIndex + 1
    end

    for i, v in ipairs(_ui.toggleList) do
        v.gameObject:SetActive(i <= _ui.exploringSandIndex)
        v.toggle.value = i == sandIndex 
        v.nameLabel.text = TextMgr:GetText(sandDataList[chapterType][i].SandName)
		if tonumber(_ui.chapterType) == 1 then 
			v.bgSprite.spriteName = "select_normal" 
			v.gameObject:GetComponent("UIButton").normalSprite = "select_normal"
			v.iconSprite.spriteName = "icon_selectsand" 
		else
			v.bgSprite.spriteName = "select_elite" 
			v.gameObject:GetComponent("UIButton").normalSprite = "select_elite"
			v.iconSprite.spriteName = "icon_selectsand_elite"
		end
    end

    local sandId = sandData.id
    local sandRewardMsg = MainData.GetSandReward(sandId)
    _ui.starLabel.text = string.format("%d/%d", sandStarCount, totalSandStarCount)
    _ui.starSlider.value = sandStarCount / totalSandStarCount
    local rewardParamList = string.split(sandData.reward, ";")
	local typeList = {"s" , "m" , "b"}
    for i, v in ipairs(_ui.rewardList) do
        local paramList = string.split(rewardParamList[i], ":")
        local starCount = tonumber(paramList[1])
        local dropId = tonumber(paramList[2])
        
        local status = "_null"
        if sandStarCount >= starCount then
            status = "_done"
            if sandRewardMsg ~= nil then
                for ii, vv in ipairs(sandRewardMsg.index) do
                    if vv == i then
                        status = "_open"
                        break
                    end
                end
            end
        end

        v.shineObject:SetActive(status == "_done")
        v.numberLabel.text = starCount
        v.iconSprite.spriteName = string.format("icon_starbox_%s%s", typeList[i], status)
        SetClickCallback(v.gameObject, function(go)
            SectionRewards.Show(sandId, i, dropId, starCount, status)
        end)
    end

    completedChapter = nil
	completedChapterType = nil
end

function Start()
    LoadUI()
    _ui.toggleGrid.repositionNow = true
end

function Awake()
    _ui = {}
    _ui.sandIndexList = {}
    local btnBack = transform:Find("Container/btn_back"):GetComponent("UIButton")
    SetClickCallback(btnBack.gameObject, function(go)
        FunctionListData.IsFunctionUnlocked(100, function(isactive)
            if isactive then
                Hide()
            else
                FloatText.Show(TextMgr:GetText(TableMgr:GetFunctionUnlockText(100)), Color.white)
            end
        end)
    end)
    FunctionListData.IsFunctionUnlocked(100, function(isactive)
        btnBack.gameObject:SetActive(isactive)
    end)
    _ui.containerObject = transform:Find("Container").gameObject
    _ui.bgTexture = transform:Find("Container/bg_sand"):GetComponent("UITexture")
    _ui.leftButton =  transform:Find("Container/bg_arrow/btn_left"):GetComponent("UIButton")
    _ui.rightButton = transform:Find("Container/bg_arrow/btn_right"):GetComponent("UIButton")
    _ui.eliteButton = transform:Find("Container/btn_normal2elite"):GetComponent("UIButton")
    _ui.normalButton = transform:Find("Container/btn_elite2normal"):GetComponent("UIButton")
    _ui.starSlider = transform:Find("Container/bg_star/bg_schedule/bg_slider"):GetComponent("UISlider")
    _ui.starLabel = transform:Find("Container/bg_star/icon_star/num"):GetComponent("UILabel")

    local rewardList = {}
    for i = 1, 3 do
        local reward = {}
        local rewardTransform = transform:Find("Container/bg_star/icon_item" .. i)
        reward.transform = rewardTransform
        reward.gameObject = rewardTransform.gameObject
        reward.iconSprite = rewardTransform:GetComponent("UISprite")
        reward.numberLabel = rewardTransform:Find("num"):GetComponent("UILabel")
        reward.shineObject = rewardTransform:Find("ShineItem").gameObject
        rewardList[i] = reward
    end

    _ui.rewardList = rewardList

    _ui.toggleGrid = transform:Find("Container/bg_sandname/Scroll View/Grid"):GetComponent("UIGrid")
    local toggleList = {}
    for i = 1, _ui.toggleGrid.transform.childCount do
        local toggle = {}
        local toggleTransform = _ui.toggleGrid.transform:GetChild(i - 1)
        toggle.transform = toggleTransform
        toggle.gameObject = toggleTransform.gameObject
        toggle.toggle = toggleTransform:GetComponent("UIToggle")
        toggle.nameLabel = toggleTransform:Find("name"):GetComponent("UILabel")
        toggle.iconSprite = toggleTransform:Find("icon"):GetComponent("UISprite")
		toggle.bgSprite = toggleTransform:GetComponent("UISprite")
        toggleList[i] = toggle
        EventDelegate.Add(toggle.toggle.onChange, EventDelegate.Callback(function()
            if toggle.toggle.value then
                if _ui ~= nil then
                    _ui.sandIndexList[_ui.chapterType] = i
                    LoadUI()
                end
            end
        end))
    end
    _ui.toggleList = toggleList
end

function Close()
    _ui = nil
end

function Show(chapterType, sandIndex)
    Global.OpenUI(_M)
    _ui.chapterType = chapterType == 5 and 2 or 1
    _ui.sandIndexList[_ui.chapterType] = sandIndex
end

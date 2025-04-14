module("ChapterSelectUI", package.seeall)
local GUIMgr = Global.GGUIMgr.Instance
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local SetClickCallback = UIUtil.SetClickCallback
local GPlayerPrefs = UnityEngine.PlayerPrefs
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject

local levelList
local STATE_EXPLORED = 1
local STATE_EXPLORING = 2
local STATE_UNEXPLORED = 3
local selectedChapter
local selectedLevel
local selectedLevelfirst
local bColor = Color(0.2745,0.2745,0.2745,1)
local chapterMsg
local exploringlevel
local _ui
function Hide()
    Global.CloseUI(_M)
end

class "Level" {}

function Level:SetStar(battleData, star, isPlay)
    local battleType = battleData.Type
    for i, v in ipairs(self.starList) do
        v.transform:GetComponent("Animator").enabled = (battleType ~= 2 and i == star and isPlay)
        v.gameObject:SetActive(i == star and battleType ~= 2)
    end
end

function Level:SetExploredState(state, battleData)
    local battleType = battleData.Type
    self.btn.gameObject:SetActive(false)
    if battleType == 1 then
        self.btn.normalSprite = battleData.icon
        self.btn.disabledSprite = battleData.icon
        self.sprite.spriteName = battleData.icon
    else
        self.btn.normalSprite = state == STATE_EXPLORING and "icon_chapter_pvp_open" or "icon_chapter_pvp_done"
        self.btn.disabledSprite = "icon_chapter_pvp_open"
        self.sprite.spriteName = self.btn.normalSprite
    end

    self.state = state
    if state == STATE_EXPLORED then
        self.btn.isEnabled = true
        self.arrow.gameObject:SetActive(false)
        self.arrow2.gameObject:SetActive(false)
        if self.pointList ~= nil then
            for _, v in ipairs(self.pointList) do
                v.spriteName = "icon_point"
            end
        end
    elseif state == STATE_EXPLORING then
        if GPlayerPrefs.GetInt("battleid") ~= self.battleId then
            self.arrow.gameObject:SetActive(false)
            self.arrow2.gameObject:SetActive(false)
            self.btn.isEnabled = false
            if self.pointList ~= nil then
                local tweenList = {}
                local i = 1
                for _, v in ipairs(self.pointList) do
                    v.color = bColor
                    v.spriteName = "icon_point"
                    local tc = v.gameObject:AddComponent(typeof(TweenColor))
                    tc.enabled = false
                    tc.from = bColor
                    tc.duration = 0.15
                    tweenList[i] = tc
                    i = i + 1
                end
                local length = i - 1
                for i = 1, length do
                    if i < length then
                        if tweenList[i+1].gameObject.activeInHierarchy == false then
                            tweenList[i]:SetOnFinished(EventDelegate.Callback(function ()
                                self.btn.transform:GetComponent("Animator").enabled = true
                                self.btn.isEnabled = true
                                self.arrow.gameObject:SetActive(true)
                                coroutine.start(function()
                                    coroutine.wait(0.7)
                                    if _ui == nil then
                                        return
                                    end
                                    self.arrow2.gameObject:SetActive(true)
                                end)
                            end))
                        else
                            tweenList[i]:SetOnFinished(EventDelegate.Callback(function()
                                tweenList[i + 1].enabled = true
                            end))
                        end
                    else
                        tweenList[i]:SetOnFinished(EventDelegate.Callback(function ()
                            self.btn.transform:GetComponent("Animator").enabled = true
                            self.btn.isEnabled = true
                            self.arrow.gameObject:SetActive(true)
                            coroutine.start(function()
                                coroutine.wait(0.7)
                                if _ui == nil then
                                    return
                                end
                                self.arrow2.gameObject:SetActive(true)
                            end)
                        end))
                    end
                end
                if tweenList[1] ~= nil then
                    tweenList[1].enabled = true
                end
            else
                self.btn.isEnabled = true
                self.arrow.gameObject:SetActive(true)
                self.arrow2.gameObject:SetActive(true)
            end
            GPlayerPrefs.SetInt("battleid",self.battleId)
            GPlayerPrefs.Save()
        else
            self.btn.isEnabled = true
            self.arrow.gameObject:SetActive(true)
            self.arrow2.gameObject:SetActive(true)
        end
    elseif state == STATE_UNEXPLORED then
        self.btn.isEnabled = false
        self.arrow.gameObject:SetActive(false)
        self.arrow2.gameObject:SetActive(false)
        if self.pointList ~= nil then
            for _, v in ipairs(self.pointList) do
                v.spriteName = "icon_point_hui"
            end
        end
    end
    if battleType == 2 and state == STATE_EXPLORED then
        self.btn:GetComponent("BoxCollider").enabled = false
        self.btn.normalSprite = "icon_chapter_pvp_done"
        self.btn.disabledSprite = "icon_chapter_pvp_done"
    end
    self.btn.gameObject:SetActive(true)
end

function GetFirstValidLevel()
    for i, v in ipairs(levelList) do
        if v.state == STATE_EXPLORING then
            return v
        end
    end

    return levelList[1]
end

local function GetLevelMsg(levelId)
    chapterMsg = ChapterListData.GetChapterData(selectedChapter)
    playerLevel = MainData.GetLevel()
    if chapterMsg == nil then
        chapterMsg = {chapter = selectedChapter, level = {}}
    end
    for _, v in ipairs(chapterMsg.level) do
        if v.chapterlevel == levelId then
            return v
        end
    end
end

function GetSelectedLevel()
	return selectedLevel
end

function IsLevelFirst(battleId)
	if battleId == selectedLevel then
		if selectedLevelfirst and IsLevelUnLock(battleId) then
			return true
		end
	end
	return false
end

function IsLevelUnLock(battleId)
	local chapterData = TableMgr:GetChapterData(chapterMsg.chapter)
    local battleIdList = chapterData.content:split(";")
    local levelMsg = GetLevelMsg(battleId)
    if levelMsg ~= nil then
    	return true
    else
    	return false
    end
end

function ShowControledMenu(flag)
	local btnSection = transform:Find("Container/btn_backsection")
	btnSection.gameObject:SetActive(flag)
	
	local btnBack = transform:Find("Container/btn_back")
	btnBack.gameObject:SetActive(flag)
end

local function CheckPVP4PVE_BattleMove()
	local curP4pve = Global.GetCurrentP4PVEMsg()
	local needBattleMove = curP4pve ~= nil and curP4pve.id ~= nil and curP4pve.battleFail ~= nil and curP4pve.battleFail
	if needBattleMove then
		BattleMove.Show4PVE(curP4pve.id)
	end
end

function LoadChapter()
    local playerLevel = 100
    chapterMsg = ChapterListData.GetChapterData(selectedChapter)
    playerLevel = MainData.GetLevel()
    if chapterMsg == nil then
        chapterMsg = {chapter = selectedChapter, level = {}}
    end
    local starLevelSave = GPlayerPrefs.GetInt("starPlayedLevel")
	
    local chapterData = TableMgr:GetChapterData(chapterMsg.chapter)
    local battleIdList = chapterData.content:split(";")
    for i, v in ipairs(levelList) do
        local battleId = tonumber(battleIdList[i])
        v.battleId = battleId
        local levelMsg = GetLevelMsg(battleId)
        local battleData = TableMgr:GetBattleData(battleId)
        local explortedState = STATE_UNEXPLORED
        v.lock.gameObject:SetActive(false)
        if levelMsg ~= nil then
            explortedState = STATE_EXPLORED
            local star = 0
            for _, vv in ipairs(levelMsg.star) do
                if vv then
                    star = star + 1
                end
            end
            local canPlay = false
            if i > starLevelSave then
                canPlay = true
                GPlayerPrefs.SetInt("starPlayedLevel", i)
                GPlayerPrefs.Save()
            end
            v:SetStar(battleData, star, canPlay)
            if star == 0 then
            	explortedState = STATE_EXPLORING
            end
        else
            local frontIdList = string.split(battleData.frontId, ",")

            if tonumber(frontIdList[1]) == 0 or ChapterListData.HasLevelExplored(battleData.frontId) or i == 1 then
                local baseLevel = maincity.GetBuildingByID(1).data.level
                if tonumber(frontIdList[1]) ~= 0 and playerLevel >= battleData.requiredLevel and baseLevel >= battleData.requiredBaseLevel then
                    explortedState = STATE_EXPLORING
                else
                    v.lock.gameObject:SetActive(true)
                    SetClickCallback(v.lock.gameObject, function(go)
                        if tonumber(frontIdList[1]) == 0 then -- 暂未开启
                            FloatText.ShowOn(v.btn.gameObject, TextMgr:GetText("common_ui1"))
                        elseif baseLevel < battleData.requiredBaseLevel then
                            local lockText = TextMgr:GetText(Text.chat_hint2)
                            FloatText.ShowOn(v.btn.gameObject, System.String.Format(lockText, battleData.requiredBaseLevel))
                        else 
                            local lockText = TextMgr:GetText(Text.battle_ui1)
                            FloatText.ShowOn(v.btn.gameObject, System.String.Format(lockText, battleData.requiredLevel))
                        end
                    end)
                end
            end
            v:SetStar(battleData, 0)
        end
        SetClickCallback(v.btn.gameObject, function(go)
            print("battleId:", battleId)
        	selectedLevel = battleId
        	selectedLevelfirst = explortedState == STATE_EXPLORING
            if battleData.Type == 1 then
                ChapterInfoUI.Show(battleId)
            else
                if explortedState == STATE_EXPLORED then
                    --FloatText.Show(TextMgr:GetText(Text.PVPChapter_Hero_ui3))
                else
                    ChapterPVPInfo.Show(battleId)
                end
            end
        end)
        v:SetExploredState(explortedState, battleData)

        local unlockArmyId
        local unlockHeroId
        if not ChapterListData.HasLevelExplored(battleId) and battleData.unlock ~= "NA" then
            local unlockList = string.split(battleData.unlock, ",")
            if unlockList[1] == "1" then
                unlockArmyId = tonumber(unlockList[2])
            elseif unlockList[1] == "2" then
                unlockHeroId = tonumber(unlockList[2])
            end
        end

        if unlockArmyId == nil and battleData.EliteDropHint == 0 then
            local unlockTransform = v.btn.transform:Find("unlockHint")
            if unlockTransform ~= nil then
                GameObject.Destroy(unlockTransform.gameObject)
            end
        else
            local unlockTransform = v.btn.transform:Find("unlockHint")
            if unlockTransform == nil then
                local unlockObject = UnityEngine.GameObject.Instantiate(_ui.unlockPrefab)
                unlockObject.transform:SetParent(v.btn.transform, false)
                unlockObject.name = "unlockHint"
				if unlockArmyId ~= nil then
					local unitData = TableMgr:GetUnitData(unlockArmyId)
					local armyIcon = unlockObject.transform:Find("base/kuang/Texture"):GetComponent("UITexture")
					local nameLabel = unlockObject.transform:Find("name"):GetComponent("UILabel")
					armyIcon.mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", unitData._unitSoldierIcon)
					nameLabel.text = TextUtil.GetUnitName(unitData)
					local lockLabel = unlockObject.transform:Find("lock")
					lockLabel.gameObject:SetActive(true)
					local suipian = unlockObject.transform:Find("base/kuang/icon_suipian")
					suipian.gameObject:SetActive(false)
				elseif battleData.EliteDropHint ~= 0 then
					local itemData = TableMgr:GetItemData(battleData.EliteDropHint)
					local itemIcon = unlockObject.transform:Find("base/kuang/Texture"):GetComponent("UITexture")
					local nameLabel = unlockObject.transform:Find("name"):GetComponent("UILabel")
					local lockLabel = unlockObject.transform:Find("lock")
					lockLabel.gameObject:SetActive(false)
					itemIcon.mainTexture = ResourceLibrary:GetIcon("Item/", itemData.icon)
					nameLabel.text = TextUtil.GetItemName(itemData)
					local suipian = unlockObject.transform:Find("base/kuang/icon_suipian")
					suipian.gameObject:SetActive(true)
					
					SetClickCallback(unlockObject.gameObject , function() 
						local heroData = TableMgr:GetHeroData(tonumber(itemData.param1))
						local heroInfo = GeneralData.GetDefaultHeroData(heroData, GeneralData.MAX_LEVEL, GeneralData.MAX_STAR, 1, GeneralData.MAX_GRADE)
						HeroInfoNew.Show(heroInfo,nil , true)
					end)
				end
            end
        end
	end
end

function Awake()
    local btnSection = transform:Find("Container/btn_backsection")
    SetClickCallback(btnSection.gameObject, function(go)
        Hide()
    end)
    if not FunctionListData.IsFunctionUnlocked(102, function(isactive)
    	btnSection.gameObject:SetActive(isactive)
    end) then
    	btnSection.gameObject:SetActive(false)
    end
    local btnBack = transform:Find("Container/btn_back")
    SetClickCallback(btnBack.gameObject, function()
    	FunctionListData.IsFunctionUnlocked(100, function(isactive)
    		if isactive then
		        MainCityUI.HideWorldMap(false, nil, true)
		        SandSelect.Hide()
		        Hide()
		        selectedChapter = nil
		    else
		    	FloatText.Show(TextMgr:GetText(TableMgr:GetFunctionUnlockText(100)), Color.white)
		    end
	    end)
    end)
    if not FunctionListData.IsFunctionUnlocked(100, function(isactive)
    	btnBack.gameObject:SetActive(isactive)
    end) then
    	btnBack.gameObject:SetActive(false)
    end
    if Global.EnableFakeData() then
        btnBack.gameObject:SetActive(false)
    end

    local chapterData = TableMgr:GetChapterData(selectedChapter)
    local bgTexture = transform:Find("Container/bg_chapter"):GetComponent("UITexture")
    bgTexture.mainTexture = ResourceLibrary:GetIcon("chapter/", chapterData.bg)

    local chapterBg = transform:Find("Container")
    local chapterInstance = ResourceLibrary.GetUIInstance("ChapterSelect/"..chapterData.uiPrefab)
    chapterInstance:SetActive(true)
    local chapterTransform = chapterInstance.transform
    chapterTransform:SetParent(chapterBg, false)

    levelList = {}
    for i = 1, 10 do
        local level = Level()
        level.btn = chapterTransform:Find(string.format("icon_chapter%d", i)):GetComponent("UIButton")
        level.btn.duration = 0.001
        level.btn.isEnable = false
        level.anim = level.btn.transform:GetComponent("Animator")
        local sp = level.btn.transform:GetComponent("UISprite")
        sp.enabled = true
        sp.width = 2
        sp.height = 2
        level.sprite = chapterTransform:Find(string.format("icon_chapter%d/icon_chapter_done", i)):GetComponent("UISprite")
        --level.cloud = chapterTransform:Find(string.format("icon_chapter%d/cloud", i))
        --level.cloud.gameObject:SetActive(false)
        level.starList = {}
        for j = 1, 3 do
            level.starList[j] = chapterTransform:Find(string.format("icon_chapter%d/%dstar", i, j))
        end
        level.arrow = chapterTransform:Find(string.format("icon_chapter%d/jiantou", i))
        level.arrow2 = chapterTransform:Find(string.format("icon_chapter%d/arrow", i))
        level.done = chapterTransform:Find(string.format("icon_chapter%d/icon_chapter_done", i))
        level.lock = chapterTransform:Find(string.format("icon_chapter%d/icon_locked", i))
        level.btn.tweenTarget = level.done.gameObject
        if i > 1 then
            level.pointList = {}
            local point = chapterTransform:Find(string.format("point%d", i - 1))
            local childCount = point.childCount
            for i = 1, childCount do
                level.pointList[i] = point:GetChild(i - 1):GetComponent("UISprite")
            end
        end

        levelList[i] = level
    end
	
	_ui = {}
    _ui.unlockPrefab = ResourceLibrary.GetUIPrefab("ChapterSelect/hint")
    LoadChapter()
	CheckPVP4PVE_BattleMove()

    for i = 1, 10 do
        levelList[i].btn.duration = 0.2
    end
end

function GetSelectedChapter()
    return selectedChapter
end

function Show(chapter)
    selectedChapter = chapter
    print("select chapter, id:", chapter)
    Global.OpenUI(_M)
    if FunctionListData.IsFunctionUnlocked(100, function(isactive)
    	if isactive then
    	end
    end) then
    end
end

function ShowExploringChapter()
    local exploringChapterId = ChapterListData.GetExploringChapterId(1)
    Show(exploringChapterId)
end

function Close()
	_ui = nil
end

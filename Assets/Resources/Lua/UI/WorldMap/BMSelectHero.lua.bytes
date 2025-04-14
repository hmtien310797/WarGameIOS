class "BMSelectHero"
{
}

function BMSelectHero:__init__(trf,moveType, sortingConfig,fill,EnableignoreHeroAtts,climb_hero)
    self.transform = trf
    self.GUIMgr = Global.GGUIMgr
    self.TableMgr = Global.GTableMgr
    self.TextMgr = Global.GTextMgr
    self.AudioMgr = Global.GAudioMgr
    self.ResourceLibrary = Global.GResourceLibrary
    self.GameStateMain = Global.GGameStateMain
    self.GameTime = Serclimax.GameTime
    self.String = System.String

    self.SetPressCallback = UIUtil.SetPressCallback
    self.SetClickCallback = UIUtil.SetClickCallback
    self.AddDelegate = UIUtil.AddDelegate
    self.RemoveDelegate = UIUtil.RemoveDelegate

    self.NGUITools = NGUITools
    self.GameObject = UnityEngine.GameObject
    self.FloatText = FloatText

    self.LoadHero = HeroList.LoadHero
    self.LoadHeroObject = HeroList.LoadHeroObject

    self.moveType = moveType
    self.selectedList = nil 

    self.heroListGrid = nil
    self.heroPrefab = nil
    self.myList = nil  
    self.ClimbHeroData = climb_hero
    self.heroData = SelectHero_PVP.GetSelectHeroData((EnableignoreHeroAtts~=nil and EnableignoreHeroAtts)and true or false)    
    self.sortingConfig = sortingConfig
    self.switchBtn = nil
    self.switchScale = nil
    self.switchCallBack = nil
    self.editorHero = false
    self.editorCallBack = nil
    self.ignoreHeros = nil
    self.fill = fill
    self.EnableignoreHeroAtts = EnableignoreHeroAtts
    self.heroListWrapContent = nil
    self.heroRow = 0
    self.heroCol = 0    
    self.IgnoreHeroAtts = {1000,1004,1005,1008,1009,1010,1011,1012,100000021}
end


function BMSelectHero:LoadSelectList(recommend)
    local heroIndex = 1
    local tmpherolist = {}
    local sheroData = SelectHero_PVP.GetSelectHeroData((self.EnableignoreHeroAtts~=nil and self.EnableignoreHeroAtts)and true or false).memHero
    if self.ClimbHeroData ~= nil then
        sheroData = self.ClimbHeroData
    end
    
    for _, v in ipairs(sheroData) do
        
        local heroMsg = GeneralData.GetGeneralByUID(v) -- HeroListData.GetHeroDataByUid(v)
        
        local heroData = self.TableMgr:GetHeroData(heroMsg.baseid)
        table.insert(tmpherolist, heroMsg.uid)
        local hero = self.selectedList[heroIndex].hero
        self.LoadHero(hero, heroMsg, heroData)
        hero.icon.gameObject:SetActive(true)
        local skillMsg = heroMsg.skill.godSkill
        local skillData = self.TableMgr:GetGodSkillDataByIdLevel(skillMsg.id, skillMsg.level)
        local skill = self.selectedList[heroIndex].skill
        skill.icon.mainTexture = self.ResourceLibrary:GetIcon("Icon/Skill/", skillData.iconId)
        skill.bg.gameObject:SetActive(false)
        heroIndex = heroIndex + 1

    end
    --[[
    for i, v in ipairs(self. ) do
        if self.heroData:IsHeroSelectedByUid(v.msg.uid) then
            table.insert(tmpherolist, v.msg.uid)
            local hero = self.selectedList[heroIndex].hero
            self.LoadHero(hero, v.msg, v.data)
            hero.icon.gameObject:SetActive(true)
            local skillMsg = v.msg.skill.godSkill
            local skillData = self.TableMgr:GetGodSkillDataByIdLevel(skillMsg.id, skillMsg.level)
            local skill = self.selectedList[heroIndex].skill
            skill.icon.mainTexture = self.ResourceLibrary:GetIcon("Icon/Skill/", skillData.iconId)
            skill.bg.gameObject:SetActive(false)
            heroIndex = heroIndex + 1
        end
    end
--]]
    --self.heroData:UnselectAllHero()
    --local s= "hero"
    --table.foreach(tmpherolist,function(i,v)
    --    self.heroData:SelectHero(v)
       -- s=s..","..v..","
    --end)
    --print(s)
    local heroSlot = 5
    for i = heroIndex, 5 do
        local hero = self.selectedList[i].hero
        hero.msg = nil
        hero.icon.gameObject:SetActive(false)
        local locked = i > heroSlot
        hero.lock.gameObject:SetActive(locked)
        hero.plus.gameObject:SetActive(not locked)
        local skill = self.selectedList[i].skill
        skill.bg.gameObject:SetActive(false)
    end
end
--[[
function BMSelectHero:GetVaildHeroUid(uid)
    if self.ignoreHeros[uid] == nil then
        return uid
    end

    local baseHerodata = HeroListData.GetHeroDataByUid(uid)
    if baseHerodata == nil then
        return nil
    end
    local baseid = baseHerodata.baseid
    --print(baseid)
    local heroListData = HeroListData.GetData()
    for _, v in ipairs(heroListData) do
         -- print(v.baseid,baseid,uid,v.uid,v.baseid == baseid,uid ~= v.uid,v.baseid == baseid and uid ~= v.uid)
        if v.baseid == baseid and uid == v.uid and self.ignoreHeros[v.uid] == nil then
            --print("success   ",v.uid)
            return v.uid
        end
    end
    return nil
end

function  BMSelectHero:LoadHeroList()
    local heroListData = self.myList
    local rowCount = math.floor(#heroListData / self.heroCol)
    self.heroListWrapContent.minIndex = -rowCount
    self.heroListScrollView.disableDragIfFits = rowCount < self.heroRow
    self.heroListScrollView:ResetPosition()
    self.heroListWrapContent:ResetToStart()
end
--]]
function  BMSelectHero:LoadUI(dontrefrushfight,needAuto)
    print("needAuto", needAuto,self.fill)
    if needAuto then
        if self.fill then
            SelectHero_PVP.GetSelectHeroData((self.EnableignoreHeroAtts~=nil and self.EnableignoreHeroAtts)and true or false):UnselectAllHero()
            SelectHero_PVP.AutoSelect(self.moveType,MapData_pb.SEntryData(),nil,(self.EnableignoreHeroAtts~=nil and self.EnableignoreHeroAtts)and true or false)
        else
            SelectHero_PVP.GetSelectHeroData((self.EnableignoreHeroAtts~=nil and self.EnableignoreHeroAtts)and true or false):UnselectAllHero()
            SelectHero_PVP.AutoSelect(self.moveType,TileInfo.GetTileMsg(),nil,(self.EnableignoreHeroAtts~=nil and self.EnableignoreHeroAtts)and true or false)
        end
    end
    --self.heroData:NormalizeData()
    BattleMove.RecordTime("BMSelectHero  self.heroData:NormalizeData()==============================")

    --self:LoadMyList()
    BattleMove.RecordTime("BMSelectHero self:LoadMyList()==============================")
    --[[
    if dontrefrushfight then
        if self.sortingConfig == nil then
            local heros = BattleMoveData.GetPreHeroList()
            if heros ~= nil then
                for i = 1, #(heros), 1 do
                    local uid = self:GetVaildHeroUid(heros[i])
                    if uid ~= nil then self.heroData:SelectHero(uid) end
                end
            end
        else
            local selectedHeroes = {}
            for _, hero in pairs(self.myList) do -- 推荐出征将军
                if selectedHeroes[hero.msg.baseid] == nil and not HeroListData.IsHeroDefenseByState(HeroListData.GetHeroState(hero.msg.uid)) then
                    self.heroData:SelectHero(hero.msg.uid)
                    selectedHeroes[hero.msg.baseid] = hero.msg.uid
                    
                    if self.heroData:GetSelectedHeroCount() == 5 then break end
                end
            end
        end
    end
    if self.fill ~= nil and self.fill then
        if self.heroData:GetSelectedHeroCount() == 0 then
            local selectedHeroes = {}
            for _, hero in pairs(self.myList) do
                if selectedHeroes[hero.msg.baseid] == nil then
                    self.heroData:SelectHero(hero.msg.uid)
                    selectedHeroes[hero.msg.baseid] = hero.msg.uid
                    
                    if self.heroData:GetSelectedHeroCount() == 5 then break end
                end
            end 
        end
    end
    ]]
    self:LoadSelectList(dontrefrushfight)
    --self:LoadHeroList()

    BattleMove.RecordTime("BMSelectHero self:LoadSelectList()==============================")
    --AttributeBonus.CollectBonusInfo("SelectArmy")
    BattleMove.RecordTime("BMSelectHero AttributeBonus.CollectBonusInfo(SelectArmy)==============================")
    if dontrefrushfight ==  nil then
        print("[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[     BMSelectHero:LoadUI")
        BattleMove.RefrushTotalSoliderNum()
        BattleMove.RecordTime("BMSelectHero  BattleMove.RefrushFight==============================")
    end
end
--[[
function UpdateHeroList(go, wrapIndex, realIndex)
    local self = BattleMove.GetSelectHero()
    for i = 1, self.heroCol do
        local heroIndex = -realIndex * self.heroCol + i    
        local heroTransform = go.transform:GetChild(i - 1)
        local hero = self.myList[heroIndex]
        if hero ~= nil then
            heroTransform.gameObject:SetActive(true) 
            self.LoadHeroObject(hero, heroTransform)
            if self.sortingConfig ~= nil then
                heroTransform:Find("recommend").gameObject:SetActive(heroIndex < 6) -- 推荐图标
            end
            hero.skillIcon = heroTransform:Find("bg_skill/icon_skill"):GetComponent("UITexture")
            local heroMsg = hero.msg
        
            local heroData = hero.data
            self.LoadHero(hero, heroMsg, heroData)
            local heroState = HeroListData.GetHeroState(heroMsg.uid)
            hero.stateBg.gameObject:SetActive(heroState ~= 0)
            for _, v in pairs(hero.stateList) do
                v.gameObject:SetActive(false)
            end
            if HeroListData.IsHeroDefenseByState(heroState) then
                hero.stateList.defense.gameObject:SetActive(true)
            end
            local skillMsg = heroMsg.skill.godSkill
            local skillData = self.TableMgr:GetGodSkillDataByIdLevel(skillMsg.id, skillMsg.level)
            hero.skillIcon.mainTexture = self.ResourceLibrary:GetIcon("Icon/Skill/", skillData.iconId)
            local skillBg = heroTransform:Find("bg_skill")
            skillBg.gameObject:SetActive(false)
            self.SetClickCallback(hero.btn.gameObject, function(go)
                local heroUid = heroMsg.uid
                local heroBaseId = heroMsg.baseid
                local full = self.heroData:GetSelectedHeroCount() >=5
                if self.heroData:IsHeroSelectedByUid(heroUid) then
                    self.heroData:UnselectHero(heroUid)
                    self:LoadUI()
                else
                    if full then
                        local text = self.TextMgr:GetText(Text.selectunit_hint114)
                        self.AudioMgr:PlayUISfx("SFX_ui02", 1, false)
                        self.FloatText.Show(text, Color.white)
                    else
                        if self.heroData:IsHeroSelectedByBaseId(heroBaseId) then
                            local text = self.TextMgr:GetText(Text.team_error_hero_repeat)
                            self.AudioMgr:PlayUISfx("SFX_ui02", 1, false)
                            self.FloatText.Show(text, Color.white)
                        else
                            if HeroListData.IsHeroDefenseByState(heroState) then
                                MessageBox.Show(self.TextMgr:GetText(Text.BattleMove_wall), function()
                                    self.heroData:SelectHero(heroUid)
                                    self:LoadUI()
                                end,
                                function()
                                end)
                            else
                                self.heroData:SelectHero(heroUid)
                                self:LoadUI()
                            end
                        end
                    end
                end
            end)
            hero.mask.gameObject:SetActive(self.heroData:IsHeroSelectedByUid(heroMsg.uid))
        else
            heroTransform.gameObject:SetActive(false)
        end
    end
end

function  BMSelectHero:LoadMyList()
    local heroListData = HeroListData.GetSortedHeroes(self.sortingConfig)

    local newHeroListData = {}
    for _, v in ipairs(heroListData) do
        --print(v.uid)
        if self.ignoreHeros[v.uid] == nil then
            if self.sortingConfig == nil then
                table.insert(newHeroListData, v)
            else
                table.insert(newHeroListData, v.msg)
            end
            --print("Goood",v.uid)
        else
            --print("Nooo",v.uid)
        end
    end
    BattleMove.RecordTime("fill new newHeroListData==============================") 

    local heroIndex = 1
    for _, v in ipairs(newHeroListData) do
        --print("sssssssssssssssssssssss  ",v.uid)
        local heroData = self.TableMgr:GetHeroData(v.baseid) 
        if not heroData.expCard then
            --InitHero(heroData,v)
            local hero = {}
            hero.msg = v
            hero.data = heroData
            self.myList[heroIndex] = hero
            heroIndex = heroIndex + 1
        end
    end
end

function BMSelectHero:SetIgnoreHero(ignoreHeros)
    self.ignoreHeros = {}
    --print("SetIgnoreHero   ",ignoreHeros)
    if ignoreHeros == nil then
        return
    end
    table.foreach(ignoreHeros,function(i,_)
        self.ignoreHeros[i] = 1
        --print(i,self.ignoreHeros[i])
    end)
end
--]]

function BMSelectHero:Awake(un_auto_hero)
    
    self.selectedList = {}
    self.myList = {}
    self.editorHero = false
    self.switchBtn =  self.transform:Find("btn_down"):GetComponent("UIButton")
    self.switchBtn.gameObject:SetActive(true)
    self.switchBtn.transform.localEulerAngles = Vector3(0,0,270)
    self.switchCollider = self.transform:Find("btn_down"):GetComponent("BoxCollider")
    self.switchCollider.enabled = true;
    self.switchTween = self.transform:Find("btn_down"):GetComponent("TweenRotation")
    self.switchTween:ResetToBeginning(true)
    self.switchScale =self.transform:Find("bg_skills"):GetComponent("TweenScale")
    self.switchScale:ResetToBeginning(true)
    local ta = self.transform:Find("bg_skills"):GetComponent("TweenAlpha")
    local w = self.transform:Find("bg_skills"):GetComponent("UIWidget")
    if w ~= nil then
        w.alpha = 1
        w.gameObject:SetActive(false)
        w.transform.localScale = Vector3(1,0.01,1)
    end
    if ta ~= nil then
        self.GameObject.Destroy(ta)
    end
    self.switchCallBack = EventDelegate.Callback(function()
        self.switchCollider.enabled = true;
    end)
    EventDelegate.Add(self.switchTween.onFinished,self.switchCallBack)
    
    self.SetClickCallback(self.switchBtn.gameObject, function(go)
        self.switchCollider.enabled = false;
        self.editorHero = not self.editorHero
        if self.editorCallBack ~= nil then
            self.editorCallBack(self.editorHero)
        end
    end)
    BattleMove.RecordTime("BMSelectHero UI 1==============================")
    for i = 1, 5 do
        self.selectedList[i] = {}
        local hero = {}
        hero.bg = self.transform:Find(string.format("bg_battle skills/bg_selected/hero%d", i))
        hero.btn = self.transform:Find(string.format("bg_battle skills/bg_selected/hero%d/bg", i)):GetComponent("UIButton")
        hero.icon = self.transform:Find(string.format("bg_battle skills/bg_selected/hero%d/head icon", i)):GetComponent("UITexture")
        hero.levelLabel = self.transform:Find(string.format("bg_battle skills/bg_selected/hero%d/head icon/level text", i)):GetComponent("UILabel")
        hero.qualityList = {}
        for j = 1, 5 do
            hero.qualityList[j] = self.transform:Find(string.format("bg_battle skills/bg_selected/hero%d/head icon/outline%d", i, j))
        end
        hero.starList = {}
        for j = 1, 6 do
            hero.starList[j] = self.transform:Find(string.format("bg_battle skills/bg_selected/hero%d/head icon/star/star%d", i, j))
        end
        hero.plus = self.transform:Find(string.format("bg_battle skills/bg_selected/hero%d/bg/plus", i))
        hero.lock = self.transform:Find(string.format("bg_battle skills/bg_selected/hero%d/bg/lock", i))
        self.selectedList[i].hero = hero
        --[[
        self.SetClickCallback(hero.btn.gameObject, function(go)
            SelectHero_PVP.Show(self.moveType)            

            if  not self.editorHero and self.switchCollider.enabled then
                UICamera.Notify(self.switchBtn.gameObject, "OnClick", nil)
                return
            end
            if hero.msg == nil then
                return
            end
            for _, v in ipairs(self.myList) do
                if v.msg.uid == hero.msg.uid then
                    self.heroData:UnselectHero(v.msg.uid)
                end
            end
            self:LoadUI()

        end)
        --]]
        local skill = {}
        skill.bg = self.transform:Find(string.format("bg_battle skills/bg_selected/hero%d/bg_skill", i))
        skill.bg.gameObject:SetActive(false)
        skill.icon = self.transform:Find(string.format("bg_battle skills/bg_selected/hero%d/bg_skill/icon_skill", i)):GetComponent("UITexture")
        skill.icon.gameObject:SetActive(false)
        self.selectedList[i].skill = skill
    end

    --self.heroListGrid = self.transform:Find("bg_skills/bg_skills/bg2/Scroll View/Grid"):GetComponent("UIGrid")
    self.heroListScrollView = self.transform:Find("bg_skills/bg_skills/bg2/Scroll View"):GetComponent("UIScrollView")
    self.heroListWrapContent = self.transform:Find("bg_skills/bg_skills/bg2/Scroll View/Grid"):GetComponent("UIWrapContent")
    self.heroRow = self.heroListWrapContent.transform.childCount
    self.heroCol = self.heroListWrapContent.transform:GetChild(0).childCount
    self.SetClickCallback(self.transform:Find("bg_title").gameObject,function() 
        if self.fill ~= nil and self.fill then
            SelectHero_PVP.Show(self.moveType,MapData_pb.SEntryData(),
            (self.EnableignoreHeroAtts ~= nil and self.EnableignoreHeroAtts) and self.IgnoreHeroAtts or nil,function()
                local sh = BattleMove.GetSelectHero()
                if sh ~= nil then
                    sh:LoadUI()
                end

                BattleMove.CheckNeedSaveArchive()
             end)
        else
            SelectHero_PVP.Show(self.moveType,TileInfo.GetTileMsg() or MapData_pb.SEntryData(),
            (self.EnableignoreHeroAtts ~= nil and self.EnableignoreHeroAtts) and self.IgnoreHeroAtts or nil,function()
                local sh = BattleMove.GetSelectHero()
                if sh ~= nil then
                    sh:LoadUI()
                end

                BattleMove.CheckNeedSaveArchive()
             end)            
        end
    end)

    BattleMove.RecordTime("init SelectedList ==============================")
    --self.heroPrefab = self.ResourceLibrary.GetUIPrefab("WorldMap/listitem_herocard_small0.6")
    BattleMove.RecordTime("Load UI Prefab WorldMap/listitem_herocard_small0.6 ==============================")
    
    self:LoadUI(true,not un_auto_hero)
    BattleMove.RecordTime("BMSelectHero LoadUI==============================")
end
--[[
function BMSelectHero:Start()
    self.heroListWrapContent.onInitializeItem = UpdateHeroList
    self.heroListWrapContent:ResetToStart()
end

function BMSelectHero:Close()
    self.heroListWrapContent.onInitializeItem = nil

    if self.switchCallBack ~= nil then
        EventDelegate.Remove(self.switchTween.onFinished,self.switchCallBack)
    end
    self.switchCallBack = nil
 end
--]]

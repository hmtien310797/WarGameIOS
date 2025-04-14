module("SelectArmy", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local SetTooltipCallback = UIUtil.SetTooltipCallback

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText

local _ui

local teamType
local battleId
local curBattleId = 0
local curInfoId = 0
local IsRandomBattle
local IsPveMonsterBattle
local attackCallBack
local pveMonsterBattle
local pveMonsterBattleHeroBounus
local topHeroBonus = false

function SetPveMonsterBattle(topBonus , heroBonusCount)
	topHeroBonus = topBonus
	pveMonsterBattleHeroBounus = heroBonusCount
end

function SetCurBattleId(id)
	curBattleId = id
end

function Hide()
    Global.CloseUI(_M)
end

local function BackClickCallback(go)
    Hide()
    if GeneralData.HasBattleHero() then -- HeroListData.HasBattleHero() then
    	SelectHero.Show(teamType,IsRandomBattle , pveMonsterBattle)
    end
end

local function ConfirmPVP1ClickCallback(go)
    local req = HeroMsg_pb.MsgSetArmyTeamRequest()
    req.data.team:add()
    req.data.team[1] = TeamData.GetDataByTeamType(teamType)
    Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgSetArmyTeamRequest, req, HeroMsg_pb.MsgSetArmyTeamResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
            TeamData.SetData(msg.data)
        else
            PVPUI.RequestSetingBattleConfirm()
        end
    end)
end

local function StartBattle(battleData, _teamType)
    local _battleId = battleData.id
    local battleState = GameStateBattle.Instance
    battleState.IsPvpBattle = false
    GUIMgr:CloseAllMenu()
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
    local teamData = TeamData.GetDataByTeamType(_teamType)
    local selectedArmyList = {}
    for _, v in ipairs(teamData.memArmy) do
        table.insert(selectedArmyList, v.uid)
    end
    
    if unlockArmyId ~= nil and #selectedArmyList < 4 then
        table.insert(selectedArmyList, unlockArmyId)
    end

    battleState.BattleId = _battleId
    local heroInfoDataList = battleState.heroInfoDataList
    heroInfoDataList:Clear()
	
	--[[chapter表中unlock字段只要配置为2，则只带入配置中的将军，而不带入将军界面选中的将军。by借你蛋2018.1.5
    for _, v in ipairs(teamData.memHero) do
        local heroMsg = HeroListData.GetHeroDataByUid(v.uid)
        heroInfoDataList:Add(heroMsg:SerializeToString())
    end

    if unlockHeroId ~= nil and heroInfoDataList.Count < 5 then
        local heroMsg = HeroListData.GetDefaultHeroData(TableMgr:GetHeroData(unlockHeroId))
        heroInfoDataList:Add(heroMsg:SerializeToString())
    end]]
	if unlockHeroId ~= nil and unlockHeroId == 2 then
		local heroMsg = GeneralData.GetDefaultHeroData(TableMgr:GetHeroData(unlockHeroId)) -- HeroListData.GetDefaultHeroData(TableMgr:GetHeroData(unlockHeroId))
        heroInfoDataList:Add(heroMsg:SerializeToString())
	else
		for _, v in ipairs(teamData.memHero) do
			local heroMsg = GeneralData.GetGeneralByUID(v.uid) -- HeroListData.GetHeroDataByUid(v.uid)
			heroInfoDataList:Add(heroMsg:SerializeToString())
		end
	end

	--pve敌军战力调整
	local hpcoef = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PveMonsterHpCoef).value)
	local attackcoef = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PveMonsterAttackCoef).value)
	local levelFight = battleData.actFight == 0 and 1 or SelectHero.GetPveMonsterLevelFight(battleData.actFight)
	local levelAttackCoef = ((levelFight-1)*attackcoef + 1)
	local levelHpCoef = ((levelFight-1)*hpcoef + 1)
	
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
            bulletRecover = battleBonus.SummonEnergyRecovery,
			
			attackCoefAddjust = levelAttackCoef,
			defenceAddjust = 0,
			hpAddjust = levelHpCoef,
			eliteCoefAddjust = battleData.EliteParam,
        } 
    }
	
	print("开始战斗，关卡Id:", _battleId , "levelAttackCoef=" .. battleArgs.battleBonus.attackCoefAddjust , "lvelHpCoef:" .. battleArgs.battleBonus.hpAddjust , " 精英关卡属性：" .. battleData.EliteParam)

    Main.Instance:ChangeGameState(battleState, cjson.encode(battleArgs),nil)
   
end

function StartPVEBattle(_battleId, _teamType)
    local battleData = TableMgr:GetBattleData(_battleId)
    if MainData.GetEnergy() < battleData.energyCost then
        MainCityUI.CheckAndBuyEnergy(true)
        return
    end
    if TeamData.GetSelectedArmyCount(_teamType) == 0 then
        local noSelectText = TextMgr:GetText(Text.selectunit_hint112)
        AudioMgr:PlayUISfx("SFX_ui02", 1, false)
        FloatText.Show(noSelectText, Color.red)
        return
    end
    loading.Show()
    local req = HeroMsg_pb.MsgSetArmyTeamRequest()
    req.data.team:add()
    req.data.team[1] = TeamData.GetDataByTeamType(_teamType)
    Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgSetArmyTeamRequest, req, HeroMsg_pb.MsgSetArmyTeamResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
            TeamData.SetData(msg.data)
            loading.Hide()
        else
            StartBattle(battleData, _teamType)
        end
    end)
end

local function LoadArmyObject(army, armyTransform)
    army.btn = armyTransform:GetComponent("UIButton")
    army.icon = armyTransform:Find("bg_weapon/icon_weapon"):GetComponent("UITexture")
    army.bulletIcon = armyTransform:Find("bg_weapon/Label/icon_danyao")
    army.bulletCost = armyTransform:Find("bg_weapon/Label"):GetComponent("UILabel")
    army.mask = armyTransform:Find("mask_selected")
	army.btnTip = armyTransform:Find("btn"):GetComponent("UIButton")
	army.rank = armyTransform:Find("icon_rank"):GetComponent("UISprite")
	army.power = armyTransform:Find("bg_power/num"):GetComponent("UILabel")
	army.addObject = armyTransform:Find("add effect").gameObject
    armyTransform:Find("bg_skill").gameObject:SetActive(false)
end

local function LoadArmy(army, armyData)
	local armyFight = 0
    army.data = armyData
    local groupData = TableMgr:GetGroupData(armyData._unitArmyType)
    army.icon.mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", armyData._unitSoldierIcon)
    army.bulletCost.text = groupData._UnitGroupNum * armyData._unitNeedBullet
	
	local maxLevelarmy = UnlockArmyData.GetMaxLevelArmyByUid(armyData.id)
	local unitData = TableMgr:GetUnitData(maxLevelarmy)
	army.rank.gameObject:SetActive(true)
	army.rank.spriteName = "level_" .. unitData._unitArmyLevel
	
	AttributeBonus.CollectBonusInfo({ "EquipData", "TalentInfo", "BattleMove" })
	local barrackInfo = Barrack.GetAramInfo(unitData._unitArmyType , unitData._unitArmyLevel)
	local afterPower = AttributeBonus.CalBattlePointNew(barrackInfo)
	armyFight = math.floor(afterPower * _ui.PveArmyPowerFactor + 0.5)
	
	if army.power ~= nil then
		army.power.text = math.floor(armyFight)
	end
	return armyFight
end


local function LoadSelectList()
    local armyIndex = 1
    for i, v in ipairs(_ui.myList) do
        if TeamData.IsArmySelected(teamType, v.data.id) then
            local army = _ui.selectedList[armyIndex].army
            LoadArmy(army, v.data)
            army.icon.gameObject:SetActive(true)
            army.bulletCost.gameObject:SetActive(false)
            army.lock.gameObject:SetActive(false)
            army.addObject:SetActive(false)

            armyIndex = armyIndex + 1
        end
    end
	
	local battleData = TableMgr:GetBattleData(curBattleId)
	local mypower = math.floor(TeamData.GetTeamPower(teamType))
	local targetpower = 0
	if battleData ~= nil then
		targetpower = battleData.fight
	end
	
	if IsPveMonsterBattle then
		targetpower = math.floor(pveMonsterBattle.pveMonsterLevelFight)
	end
	
	if mypower >= targetpower then
		_ui.powerLabel.text = "[00ff00]"..mypower.."[-]"
	else
		_ui.powerLabel.text = "[ff0000]"..mypower.."[-]"
	end
	
	_ui.targetPower.text = math.min(targetpower)
	
    local armySlot = ChapterListData.GetArmySlot()
    local unselectCount = 0
    for i = armyIndex, 4 do
        local army = _ui.selectedList[i].army
        army.data = nil
        local locked = i > armySlot
        army.icon.gameObject:SetActive(false)
        army.bulletCost.gameObject:SetActive(false)
        army.lock.gameObject:SetActive(locked)
        army.rank.gameObject:SetActive(locked)
        army.addObject:SetActive(unselectCount < _ui.unselectCount)
        unselectCount = unselectCount + 1
    end
end

local LoadList
function LoadUI()
	if pveMonsterBattle ~= nil and pveMonsterBattle.isPveMonsterBattle then
		if pveMonsterBattle.pveMonsterLevelFight == nil then
			--local levelFight = SelectHero.GetPveMonsterLevelFight(pveMonsterBattle.pveMonsterLevelBaseFight)
			--pveMonsterBattle.pveMonsterLevelFight = levelFight
			pveMonsterBattle.pveMonsterLevelFight = pveMonsterBattle.pveMonsterLevelBaseFight
		end
		IsPveMonsterBattle = pveMonsterBattle.isPveMonsterBattle
	end
	
    LoadList()
    LoadSelectList()
end

local function ShowSoldierIfo(armyUnitId , groupId)
	if armyUnitId == curInfoId then
		curInfoId = 0
		_ui.soldierInfo.tween:PlayReverse(false)
		return
	end
	curInfoId = armyUnitId
	local groupData = TableMgr:GetGroupData(groupId)
    local unitData = TableMgr:GetUnitData(groupData._UnitGroupUnitId)
	local armyData = TableMgr:GetUnitData(armyUnitId) 
	
    local name = TextUtil.GetUnitName(unitData)
    local bulletCost = groupData._UnitGroupNum * unitData._unitNeedBullet
    local populationCost = groupData._UnitGroupNum * unitData._unitPopulation
    local armyNum = groupData._UnitGroupNum
    local cooldown = groupData._UnitGroupCD
	--tittleinfo
	_ui.soldierInfo.title:Find("icon_weapons"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/Unit/", armyData._unitSoldierIcon)
	_ui.soldierInfo.name.text = TextUtil.GetUnitName(armyData)
	
	local maxLevelarmy = UnlockArmyData.GetMaxLevelArmyByUid(armyUnitId)
	local unitData = TableMgr:GetUnitData(maxLevelarmy)
	_ui.soldierInfo.unLockLevel.spriteName = "level_"..unitData._unitArmyLevel
	--tipinfo
   -- armyTipTransform:Find("bg/title"):GetComponent("UILabel").text = name
    _ui.soldierInfo.detailmid:Find("icon_danyao/num"):GetComponent("UILabel").text = bulletCost
    _ui.soldierInfo.detailmid:Find("icon_renkou/num"):GetComponent("UILabel").text = populationCost
    _ui.soldierInfo.detailmid:Find("icon_toufangliang/num"):GetComponent("UILabel").text = armyNum
    _ui.soldierInfo.detailmid:Find("icon_cd/num"):GetComponent("UILabel").text = cooldown
	
	--attrinfo
	local barrackInfo = Barrack.GetAramInfo(groupId , unitData._unitArmyLevel)
	local barrack_bonus = nil
	barrack_bonus = AttributeBonus.CalBarrackBonus(barrackInfo)
	
	local unit_bonus = nil 
	unit_bonus = AttributeBonus.CalUnitBonus(groupData._UnitGroupUnitId)
	local attrGrid = _ui.soldierInfo.detailbottom:Find("Grid"):GetComponent("UIGrid")
	local attrAttack = attrGrid:GetChild(0):Find("num"):GetComponent("UILabel")
	attrAttack.text = math.floor(barrack_bonus.Attack)
	local attrArmo = attrGrid:GetChild(1):Find("num"):GetComponent("UILabel")
	attrArmo.text =  math.floor(barrack_bonus.Defend) + barrackInfo.fakeArmo
	local attrHp = attrGrid:GetChild(2):Find("num"):GetComponent("UILabel")
	attrHp.text = math.floor(barrack_bonus.Hp)
	local attrAttRange = attrGrid:GetChild(3):Find("num"):GetComponent("UILabel")
	attrAttRange.text = math.floor(unit_bonus.WeaponRangeBonus)
	local attrAttSpeed = attrGrid:GetChild(4):Find("num"):GetComponent("UILabel")
	attrAttSpeed.text =math.floor( barrack_bonus.AttackSpeed)
	local attrUnitSpeed = attrGrid:GetChild(5):Find("num"):GetComponent("UILabel")
	attrUnitSpeed.text = math.floor(unit_bonus.UnitSpeedBonus)

	--tween start
	_ui.soldierInfo.tween:PlayForward(false)
end

function LoadList()
    local armyList = UnlockArmyData.GetArmyList()
    local armyIndex = 1
    local beforPowerList = {}
    SelectHero.LoadBeforeAttr()
    for i, v in ipairs(armyList) do
    	local armyData = TableMgr:GetUnitData(v)
    	if armyData ~= nil and armyData._unitArmyType ~= 101 and armyData._unitArmyType ~= 102 then
    		beforPowerList[v] = SelectHero.LoadBeforePower(armyData)
    	end
    end
    SelectHero.LoadCurAttr()
    local attritem = _ui.soldierInfo.rightInfo:Find("bg/bg_addition/Scroll View/Grid/bg_soldier (1)")
    local grid = _ui.soldierInfo.rightInfo:Find("bg/bg_addition/Scroll View/Grid"):GetComponent("UIGrid")
    if _ui.attrList == nil then
		_ui.attrList = {}
	end
	_ui.unselectCount = 0
    local full = TeamData.GetSelectedArmyCount(teamType) >= ChapterListData.GetArmySlot()
    for i, v in ipairs(armyList) do
        local armyData = TableMgr:GetUnitData(v)
        local groupData = TableMgr:GetGroupData(armyData._unitArmyType)
        if groupData ~= nil and armyData ~= nil and armyData._unitArmyType ~= 101 and armyData._unitArmyType ~= 102 then
            local armyTransform
            local army = _ui.myList[armyIndex]
            if army == nil then
                army = {}
                armyTransform = NGUITools.AddChild(_ui.armyListGrid.gameObject, _ui.armyPrefab).transform
                armyTransform.gameObject.name = _ui.armyPrefab.name..armyIndex
            else
                armyTransform = _ui.armyListGrid:GetChild(armyIndex - 1)
            end

            LoadArmyObject(army, armyTransform)
            local armyData = TableMgr:GetUnitData(v) 
            LoadArmy(army, armyData)


            local attr
            if _ui.attrList[i] == nil then
                attr = NGUITools.AddChild(grid.gameObject, attritem.gameObject).transform
                _ui.attrList[i] = attr
            else
                attr = _ui.attrList[i]
            end
            --attr:Find("bg_list").gameObject:SetActive(armyIndex % 2 == 0)
            local isArmySelect = TeamData.IsArmySelected(teamType, v)
            SelectHero.LoadAttrValue(attr ,armyData , isArmySelect, beforPowerList[v])

            SetClickCallback(army.btn.gameObject, function(go)
                local armyUid = v
                local full = TeamData.GetSelectedArmyCount(teamType) >= ChapterListData.GetArmySlot()
                if TeamData.IsArmySelected(teamType, armyUid) then
                    TeamData.UnselectArmy(teamType, armyUid)
                    LoadUI()
                else
                    if full then
                        local text = TextMgr:GetText(Text.selectunit_hint113)
                        AudioMgr:PlayUISfx("SFX_ui02", 1, false)
                        FloatText.Show(text, Color.white)
                    else
                        TeamData.SelectArmy(teamType, armyUid)
                        LoadUI()
                    end
                end
            end)

            SetClickCallback(army.btnTip.gameObject, function(go)
                local armyUid = v
                local full = TeamData.GetSelectedArmyCount(teamType) >= ChapterListData.GetArmySlot()
                ShowSoldierIfo(v , army.data._unitArmyType)
            end)

            --[[SetTooltipCallback(army.btn.gameObject, function(go, show)
            if show then
            Tooltip.ShowArmyTip(army.data._unitArmyType)
            else
            Tooltip.HideArmyTip()
            end

            end)]]
            if TeamData.IsArmySelected(teamType, v) then
                army.mask.gameObject:SetActive(true)
                army.addObject.gameObject:SetActive(false)
            else
                army.mask.gameObject:SetActive(false)
                army.addObject.gameObject:SetActive(not full)
                _ui.unselectCount = _ui.unselectCount + 1
            end
            army.mask.gameObject:SetActive(TeamData.IsArmySelected(teamType, v))
            _ui.myList[armyIndex] = army

            armyIndex = armyIndex + 1
        end
    end
    grid:Reposition()
    for i = armyIndex, math.huge do
        local armyTransform = _ui.armyListGrid:GetChild(i - 1)
        if armyTransform == nil then
            break
        end
        armyTransform.gameObject:SetActive(false)
        _ui.myList[i] = nil
    end
    _ui.armyListGrid:Reposition()
end

local function LoadUnlockTextList()
	if _ui.unlockArmyTextList == nil then
		_ui.unlockArmyTextList = {}
		for i = 1, 4 do
		    local battleId = ChapterListData.GetUnlockArmySlotBattleId(i)
            if battleId ~= nil then
                local battleData = TableMgr:GetBattleData(battleId)
                if battleData ~= nil then
                    local battleName = TextMgr:GetText(battleData.nameLabel)
                    local msgText = TextMgr:GetText(Text.uint_locked_hint)
                    _ui.unlockArmyTextList[i] = System.String.Format(msgText, battleName)
                end
            end
		end
	end
end

function SetTeamType(type)
	teamType = type
end

function RegistAttributeModel()
	AttributeBonus.RegisterAttBonusModule(_M)
end

local function PVEAttack()
    local battleData = TableMgr:GetBattleData(battleId)
    if battleData == nil then
        StartPVEBattle(battleId, teamType)
        return
    end
    if TeamData.GetTeamPower(teamType) <  battleData.fight then
		MessageBox.Show(TextMgr:GetText("ui_pve_fight_warning"),
			function()
                StartPVEBattle(battleId, teamType)
			end,
			function()

			end,
		    TextMgr:GetText("common_hint1"),
			TextMgr:GetText("common_hint2"))
    else
        StartPVEBattle(battleId, teamType)
    end
end

local function AutoSelectArmy()
    local armyList = UnlockArmyData.GetArmyList()
    for i, v in ipairs(armyList) do
        local armyData = TableMgr:GetUnitData(v)
        local groupData = TableMgr:GetGroupData(armyData._unitArmyType)
        if groupData ~= nil and armyData ~= nil and armyData._unitArmyType ~= 101 and armyData._unitArmyType ~= 102 then
            if not TeamData.IsArmySelected(teamType, armyData.id) then
                TeamData.SelectArmy(teamType, armyData.id)
                break
            end
        end
    end
end

function Awake()
    _ui = {}
    LoadUnlockTextList()
    _ui.powerLabel = transform:Find("Container/bg_right/bg/bg_power/bg/icon_mypower/num"):GetComponent("UILabel")
	_ui.targetPower = transform:Find("Container/bg_right/bg/bg_power/bg/icon_targetpower/num"):GetComponent("UILabel")
    local targetPower_root=  transform:Find("Container/bg_right/bg/bg_power/bg/icon_targetpower").gameObject
    if IsRandomBattle ~= nil and IsRandomBattle then
        targetPower_root:SetActive(false)
    end	
    _ui.selectedList = {}
    _ui.myList = {}
	_ui.soldierInfo = {}

    _ui.btnBack = transform:Find("Container/btn_back"):GetComponent("UIButton")
    SetClickCallback(_ui.btnBack.gameObject, BackClickCallback)

    for i = 1, 4 do
        _ui.selectedList[i] = {}
        local army = {}
        army.bg = transform:Find(string.format("Container/bg_battle weapons/bg_selected/bg_weapons (%d)", i))
        army.btn = transform:Find(string.format("Container/bg_battle weapons/bg_selected/bg_weapons (%d)", i)):GetComponent("UIButton")
        army.icon = transform:Find(string.format("Container/bg_battle weapons/bg_selected/bg_weapons (%d)/icon_weapons", i)):GetComponent("UITexture")
        army.lock = transform:Find(string.format("Container/bg_battle weapons/bg_selected/bg_weapons (%d)/locked", i))
        army.bulletIcon = transform:Find(string.format("Container/bg_battle weapons/bg_selected/bg_weapons (%d)/Label/icon_danyao", i))
        army.bulletCost = transform:Find(string.format("Container/bg_battle weapons/bg_selected/bg_weapons (%d)/Label", i)):GetComponent("UILabel")
		army.rank = transform:Find(string.format("Container/bg_battle weapons/bg_selected/bg_weapons (%d)/icon_rank", i)):GetComponent("UISprite")
		army.addObject = transform:Find(string.format("Container/bg_battle weapons/bg_selected/bg_weapons (%d)/add effect", i)).gameObject
		
        _ui.selectedList[i].army = army
        SetClickCallback(army.btn.gameObject, function(go)
            local armySlot = ChapterListData.GetArmySlot()
            if i > armySlot then
                FloatText.ShowOn(go, _ui.unlockArmyTextList[i], Color.white)
            end
            if army.data == nil then
                AutoSelectArmy()
            else
                for _, v in ipairs(_ui.myList) do
                    if v.data.id == army.data.id then
                        TeamData.UnselectArmy(teamType, v.data.id)
                    end
                end
            end
            LoadUI()
        end)
        --[[SetTooltipCallback(army.btn.gameObject, function(go, show)
            if army.data == nil then
                return
            end
            if show then
                Tooltip.ShowArmyTip(army.data._unitArmyType)
            else
                Tooltip.HideArmyTip()
            end
        end)]]
    end

    _ui.armyListGrid = transform:Find("Container/bg_weapons/bg_weapons/bg2/Scroll View/Grid"):GetComponent("UIGrid")

    _ui.btnConfirm = transform:Find("Container/btn_attack"):GetComponent("UIButton")
    if teamType == Common_pb.BattleTeamType_pvp_1 then 
        SetClickCallback(_ui.btnConfirm.gameObject, ConfirmPVP1ClickCallback)
    else
        SetClickCallback(_ui.btnConfirm.gameObject,function()
            if attackCallBack ~= nil then
				print(battleId,teamType)
				
				local req = HeroMsg_pb.MsgSetArmyTeamRequest()
				req.data.team:add()
				req.data.team[1] = TeamData.GetDataByTeamType(teamType)
				Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgSetArmyTeamRequest, req, HeroMsg_pb.MsgSetArmyTeamResponse, function(msg)
					if msg.code ~= ReturnCode_pb.Code_OK then
						Global.ShowError(msg.code)
					else
						if IsPveMonsterBattle then
							--local myTopPower = (UnlockArmyData.GetArmyTopPower(4) + HeroListData.GetHeroTopPower(5))
							attackCallBack(battleId, teamType , pveMonsterBattle.pveMonsterLevelFight)
						else
							attackCallBack(battleId, teamType)
						end
					end
				end)
            else
                PVEAttack()
            end
        end)
    end

    _ui.armyPrefab = ResourceLibrary.GetUIPrefab("Army/weaponsinfo_new")
    AttributeBonus.RegisterAttBonusModule(_M)
	
	
	--soldier info
	_ui.soldierInfo.go = transform:Find("Container/bg_msg")
	_ui.soldierInfo.tween = transform:Find("Container/bg_msg"):GetComponent("TweenPosition")
	_ui.soldierInfo.closeBtn = transform:Find("Container/bg_msg/bg/btn_close"):GetComponent("UIButton")
	_ui.soldierInfo.title = transform:Find("Container/bg_msg/bg/bg_weapons")
	_ui.soldierInfo.detailmid = transform:Find("Container/bg_msg/bg/bg_skill")
	_ui.soldierInfo.detailbottom = transform:Find("Container/bg_msg/bg/bg_soldier")
	_ui.soldierInfo.name = transform:Find("Container/bg_msg/bg/name"):GetComponent("UILabel")
	_ui.soldierInfo.unLockLevel = transform:Find("Container/bg_msg/bg/bg_weapons/icon_rank"):GetComponent("UISprite")
	_ui.soldierInfo.rightInfo = transform:Find("Container/bg_right/")
	
	SetClickCallback(_ui.soldierInfo.closeBtn.gameObject , function(go)
		_ui.soldierInfo.tween:PlayReverse(false)
	end)
	
	_ui.PveArmyPowerFactor = tonumber(TableMgr:GetGlobalData(DataEnum.ScGlobalDataId.PveArmyPowerFactor).value)
    LoadUI()
end

function SetAttackCallback(callback)
    attackCallBack = callback
end

function Show(type,isRandomBattle , pveMonsterParam)
	print(teamType)
	pveMonsterBattleHeroBounus = 0
	topHeroBonus = false
	IsPveMonsterBattle = false
    IsRandomBattle = isRandomBattle
    battleId = ChapterInfoUI.GetBattleId()
	pveMonsterBattle = pveMonsterParam
    teamType = type
    Global.OpenUI(_M)
end

function Close()
    _ui = nil
end

function CalAttributeBonus()
	--print("collect hero bonus in SelectArmy. ispvemonster:" .. IsPveMonsterBattle .. "HeroBounus:" .. pveMonsterBattleHeroBounus)
	local bonusList = {}
	if topHeroBonus then
		local HeroTopPower = GeneralData.GetPowerRankingList() -- HeroListData.GetHeroTopPower() 
		for i=1 , #HeroTopPower , 1 do
			if i <= pveMonsterBattleHeroBounus then
				local heroData = HeroTopPower[i].data
				local heroMsg = HeroTopPower[i].heroMsg
				-- local attrList = HeroListData.GetAttrList(heroMsg, heroData)
				local attributes = GeneralData.GetAttributes(heroMsg)[2]
                for attributeID, value in pairs(attributes) do
                    local attributeData = TableMgr:GetNeedTextData(attributeID)
                    if attributeData then
                        local bonus = {}
                        bonus.BonusType = attributeData.additionArmy
                        bonus.Attype = attributeData.additionAttr
                        bonus.Value = value
                        table.insert(bonusList, bonus)
                    end
                end
			end
		end
		topHeroBonus = false
	else
		local teamData = TeamData.GetDataByTeamType(teamType)
		for _, v in ipairs(teamData.memHero) do
			local heroMsg = GeneralData.GetGeneralByUID(v.uid) -- HeroListData.GetHeroDataByUid(v.uid)
			local heroData = TableMgr:GetHeroData(heroMsg.baseid)
			--print(v.uid , heroMsg.baseid)
			-- local attrList = HeroListData.GetAttrList(heroMsg, heroData)

            local attributes = GeneralData.GetAttributes(heroMsg)[2]
			for attributeID, value in pairs(attributes) do
                local attributeData = TableMgr:GetNeedTextData(attributeID)
                if attributeData then
    				local bonus = {}
    				bonus.BonusType = attributeData.additionArmy
    				bonus.Attype = attributeData.additionAttr
    				bonus.Value = value
    				table.insert(bonusList, bonus)
                end
			end
		end
	end
    return bonusList
end

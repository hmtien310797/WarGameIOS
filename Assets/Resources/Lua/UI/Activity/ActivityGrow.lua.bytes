module("ActivityGrow", package.seeall)
local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local SetClickCallback = UIUtil.SetClickCallback
local Format = System.String.Format
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter
local PlayerPrefs = UnityEngine.PlayerPrefs

local _ui, chapterid, jumplist, guideJumpFunc, nowjumplist, ShowMissionReward

local growmask,chaterchange

local function SetGrowMask(x,y,w,h)
	if growmask == nil then
		growmask = NGUITools.AddChild(GUIMgr.UIRoot.gameObject, ResourceLibrary.GetUIPrefab("Tutorial/GrowMask")).transform
	end
	NGUITools.BringForward(growmask.gameObject)
	local area = growmask:Find("ShowArea"):GetComponent("UISprite")
	area.transform.localPosition = Vector3(x, y, 0)
	area.width = w
	area.height = h
	guideJumpFunc()
end

local function CloseGrowMask()
	GameObject.Destroy(growmask.gameObject)
	growmask = nil
	guideJumpFunc()
end

local function IsNil(obj)
	return obj == nil or obj:Equals(nil)
end

local _temp = 1
local function SaveTemp(temp)
	print(temp)
	_temp = temp
end

local function GetTemp()
	return _temp
end

local function CheckWorldMap(isworldmap)
	if not isworldmap then
	    if GUIMgr:IsMenuOpen("WorldMap") then
	        MainCityUI.HideWorldMap(true, guideJumpFunc, true)
	    else
	        guideJumpFunc()
	    end
	elseif isworldmap then
	    if not GUIMgr:IsMenuOpen("WorldMap") then
	        MainCityUI.ShowWorldMap(nil, nil, true, guideJumpFunc)
	    else
	        guideJumpFunc()
	    end
	end
end

local function JumpToBuildOpenMenu(buildingId)
	maincity.SetTargetBuild(buildingId, true, nil, true)
	guideJumpFunc()
end

local function JumpToBuildNoMenu(buildingId, needopen)
	maincity.SetTargetBuild(buildingId, true, nil, false, true, true, function()
		if needopen then
			GUIMgr:CreateMenu("BuildingUpgrade", false)
			MainCityUI.HideCityMenu()
			BuildingUpgrade.OnCloseCB = function()
				MainCityUI.RemoveMenuTarget()
				BuildingShowInfoUI.Refresh()
			end
		end
	end)
	guideJumpFunc()
end

local function JumpToEmptyZiyuantian()
	maincity.SetEmptyZiyuantianTarget(true)
	guideJumpFunc()
end

local function JumpToZiyuantianNoMenu(level, needopen)
	maincity.SetTargetZiyuantian(level, false, true, true, function()
		if needopen then
			GUIMgr:CreateMenu("BuildingUpgrade", false)
			MainCityUI.HideCityMenu()
			BuildingUpgrade.OnCloseCB = function()
				MainCityUI.RemoveMenuTarget()
				BuildingShowInfoUI.Refresh()
			end
		end
	end)
	guideJumpFunc()
end

local function JumpToZiyuantian(level)
	maincity.SetTargetZiyuantian(level)
	guideJumpFunc()
end

local function JumpToBuild(buildingId, isStrong, findmin)
	local _building = maincity.SetTargetBuild(buildingId, true, nil, false, true, nil, nil, findmin)
	if _building.unlock_collider ~= nil then
		coroutine.start(function()
			coroutine.wait(0.5)
			GrowGuide.Show(_building.unlock_collider.transform, guideJumpFunc, isStrong)
		end)
	elseif _building.unlockLand_collider ~= nil then
		coroutine.start(function()
			coroutine.wait(0.5)
			GrowGuide.Show(_building.unlockLand_collider.transform, guideJumpFunc, isStrong)
		end)
	else
		GrowGuide.Show(_building.land.transform, guideJumpFunc, isStrong)
	end
end

local function JumpToBarrack()
	GrowGuide.Show(maincity.SetTargetBuild(maincity.GetEmptyBarrack().data.type, true, nil, false).land.transform, guideJumpFunc)
end

local function JumpToCityMenu(menuid, isStrong)
	local waitTimer = 0
	coroutine.start(function()
		coroutine.wait(0.3)
		while waitTimer < 3 and MainCityUI.GetCityMenuBtnByType(menuid) == nil do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
		end
		local menu = MainCityUI.GetCityMenuBtnByType(menuid)
        if menu ~= nil and not menu:Equals(nil) then
			GrowGuide.Show(menu.transform, guideJumpFunc, isStrong)
		end
	end)
end

local function GoPve(middle)
	ChapterSelectUI.ShowExploringChapter()
	if middle ~= nil then
		middle(function() GrowGuide.Show(ChapterSelectUI.GetFirstValidLevel().btn.transform, guideJumpFunc) end)
	else
		GrowGuide.Show(ChapterSelectUI.GetFirstValidLevel().btn.transform, guideJumpFunc)
	end
end

local function JumpToZhankai()
	MainCityUI.Shousuo()
	GrowGuide.Show(MainCityUI.GetZhankai().transform, guideJumpFunc)
end

local function JumpToHero()
	GrowGuide.Show(MainCityUI.GetBottomMenuList().general.transform, guideJumpFunc)
end

local function JumpToMission()
	GrowGuide.Show(MainCityUI.GetBottomMenuList().mission.transform, guideJumpFunc)
	--GrowGuide.Show(MainCityUI.transform:Find("Container/bg_activity/Grid/bg_mission01/btn_mission"), guideJumpFunc)
end

local function JumpToUnion()
	GrowGuide.Show(MainCityUI.GetBottomMenuList().union.transform, guideJumpFunc)
end

local function JumpToFirstHero()
	GrowGuide.Show(HeroList.transform:Find("background widget/bg2/content 1/Scroll View/Grid/listitem_hero301/head icon"), guideJumpFunc)
end

local function JumpToHeroLevelUp()
	GrowGuide.Show(HeroInfo.transform:Find("Container/head widget/level widget/levelUP btn"), guideJumpFunc)
end

local function MoveScrollView(Module, scrollviewpath, move)
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (Module.gameObject == nil or Module.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
		end
		if Module.transform then
			local menu = Module.transform:Find(scrollviewpath)
			if menu ~= nil and not menu:Equals(nil) then
				local scrollview = menu:GetComponent("UIScrollView")
				scrollview:MoveRelative(move)
				guideJumpFunc()
			end
		end
	end)
end

local function WaitStep()
	coroutine.start(function()
		coroutine.step()
		guideJumpFunc()
	end)
end

local function JumpToMissionTab(tab)
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (MissionUI.gameObject == nil or MissionUI.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
		end
		local menu = MissionUI.transform:Find("Container/bg/mission list/page" .. tab)
        if menu ~= nil and not menu:Equals(nil) then
			GrowGuide.Show(menu.transform, guideJumpFunc)
		end
	end)
end

local function JumoToAppoint()
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (HeroAppointUI.gameObject == nil or HeroAppointUI.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
		end
		local menu
		if HeroAppointUI.transform:Find("Container/bg/mission list/content 1/Scroll View/Table"):GetChild(2):Find("hero widget/listitem_hero1").gameObject.activeInHierarchy then
			menu = HeroAppointUI.transform:Find("Container/bg/mission list/content 1/Scroll View/Table"):GetChild(2):Find("hero widget/listitem_hero1/head icon")
		else
			menu = HeroAppointUI.transform:Find("Container/bg/mission list/content 1/Scroll View/Table"):GetChild(2):Find("hero widget/hero1")
		end
        if menu ~= nil and not menu:Equals(nil) then
			GrowGuide.Show(menu.transform, guideJumpFunc)
		end
	end)
end

local function JumoToAppointHero()
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (HeroAppoint.gameObject == nil or HeroAppoint.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
        end
        local menu = HeroAppoint.transform:Find("Container/down widget/Scroll View/wrap/Grid"):GetChild(0):Find("head icon")
        if menu ~= nil and not menu:Equals(nil) then
			GrowGuide.Show(menu.transform, function()
				local menu = HeroAppoint.transform:Find("Container/bg/btn")
				if menu ~= nil and not menu:Equals(nil) then
					GrowGuide.Show(menu.transform, guideJumpFunc)
				end
			end)
		end
	end)
end

local function JumpToLaboratory(btn)
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (Laboratory.gameObject == nil or Laboratory.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
        end
        local menu = Laboratory.transform:Find(Format("Container/bg_frane/LaboratoryList/Grid/{0}", btn))
        if menu ~= nil and not menu:Equals(nil) then
			GrowGuide.Show(menu.transform, guideJumpFunc)
		end
	end)
end

local function JumpToLaboratoryMenu(row, index)
	local waitTimer = 0
	local techRoot = Laboratory.transform:Find("Container/bg_frane/TechTree/Grid")
	coroutine.start(function()
		waitTimer = 0
		for waitTimer = 0 , 3 , GameTime.deltaTime do
			if not IsNil(techRoot) and techRoot.childCount == 0 then
				coroutine.step()
			end
		end
		if IsNil(techRoot) then
			return
		end
		if techRoot.childCount < row then
			return
		end
		local menu = techRoot:GetChild(row - 1):Find(index):Find(row .. "_" .. index)
		techRoot.parent:GetComponent("UIScrollView"):MoveRelative(Vector3(0, 236*(row - 1), 0))
        if menu ~= nil and not menu:Equals(nil) then
			GrowGuide.Show(menu.transform, guideJumpFunc)
		end
	end)
end

local function JumpToMainInfomation(isStrong)
	local menu = MainCityUI.transform:Find("Container/TopBar/bg_touxiang")
    if menu ~= nil and not menu:Equals(nil) then
		GrowGuide.Show(menu.transform, guideJumpFunc, isStrong)
	end
end

local function JumpToDailyMission()
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (MissionUI.gameObject == nil or MissionUI.gameObject:Equals(nil)) do
			coroutine.step()
			waitTimer = waitTimer + GameTime.deltaTime
		end
		local menu = MissionUI.transform:Find("Container/bg/mission list/page2")
		if menu ~= nil and not menu:Equals(nil) then
			GrowGuide.Show(menu.transform, guideJumpFunc)
		end
	end)
end

local function WaitMainInfomation()
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (MainInformation.gameObject == nil or MainInformation.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
        end
        guideJumpFunc()
	end)
end

local function JumpToActivityArmy()
	local menu = MainCityUI.transform:Find("Container/bg_activity/Grid/bth_activity")
	if menu ~= nil and not menu:Equals(nil) then
		GrowGuide.Show(menu.transform, guideJumpFunc)
	end
end

local function JumpToRebelSurround()
	local menu = MainCityUI.transform:Find("Container/bg_activityleft/Grid/btn_rebelsurround")
    if menu ~= nil and not menu:Equals(nil) then
		GrowGuide.Show(menu.transform, guideJumpFunc)
	end
end

local function JumpToTalent()
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (MainInformation.gameObject == nil or MainInformation.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
        end
        local menu = MainInformation.transform:Find("Container/bg_franenew/bottom/button_right")
        if menu ~= nil and not menu:Equals(nil) then
			GrowGuide.Show(menu.transform, guideJumpFunc)
		end
	end)
end

local function JumpToLingtu()
	if not WorldMap.IsShowBorder() then
        local closeButton = WorldMap.transform:Find("Container/btn_lingtu_close")
        GrowGuide.Show(closeButton, guideJumpFunc)
    end
end

local function JumpToWarZone()
	local waitTimer = 0
	coroutine.start(function()
		coroutine.wait(1)
		for waitTimer = 0 , 3 , GameTime.deltaTime do
			if not IsNil(WorldMap.transform) and GUIMgr:IsMenuOpen("LoadingMap") then
				coroutine.step()
			end
		end
		if IsNil(WorldMap.transform) then
			return
		end
		local btn_bigmap = WorldMap.transform:Find("Container/btn_bigmap")
		GrowGuide.Show(btn_bigmap, guideJumpFunc)
	end)
end

local function JumpToWarZoneCenter()
	WarZoneMap.transform:Find("Container/map_bg/map").localPosition = Vector3(0, -876, 0)
	guideJumpFunc()
end

local function JumpToSearchBtn()
	local waitTimer = 0
	coroutine.start(function()
		coroutine.wait(1)
		for waitTimer = 0 , 3 , GameTime.deltaTime do
			if not IsNil(WorldMap.transform) and GUIMgr:IsMenuOpen("LoadingMap") then
				coroutine.step()
			end
		end
		if IsNil(WorldMap.transform) then
			return
		end
		local btn_bigmap = WorldMap.transform:Find("Container/bg_coordinate/search btn")
		GrowGuide.Show(btn_bigmap, guideJumpFunc)
	end)
end

function JumpToUnionContent()
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (UnionInfo.gameObject == nil or UnionInfo.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
        end
        --[[
        local menu = UnionInfo.transform:Find("Container/bg2/page3")
        if menu ~= nil and not menu:Equals(nil) then
			GrowGuide.Show(menu.transform, guideJumpFunc)
		end
		--]]
	end)
end

local function JumpToUnionBuilding(id)
    --[[
	local menu = UnionInfo.transform:Find(Format("Container/bg2/content 3/bg_mid/BuildingList/Grid/union_buildcommon{0}", id))
	if menu ~= nil and not menu:Equals(nil) then
		GrowGuide.Show(menu.transform, guideJumpFunc)
	end
	--]]
end

local function JumpToActivityEntrance(id)
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (ActivityEntrance.gameObject == nil or ActivityEntrance.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
        end
        local menu = ActivityEntrance.transform:Find(Format("Container/bg_frane/Scroll View/Grid/{0}", id))
        if menu ~= nil and not menu:Equals(nil) then
			GrowGuide.Show(menu.transform, guideJumpFunc)
		end
	end)
end

local function JumpToActivityRebel()
	local menu = MainCityUI.transform:Find("Container/bg_activity/Grid/RebelArmyWanted")
    if menu ~= nil and not menu:Equals(nil) then
		GrowGuide.Show(menu.transform, guideJumpFunc)
	end
end

local function JumpToActivityRebelTab(tab)
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (ActivityAll.gameObject == nil or ActivityAll.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
		end
		local firstid = ActivityAll.GetTabActivityID(1)
		if firstid ~= tab then
			local menu = ActivityAll.GetActivityTabByID(tab)
			if menu ~= nil and not menu:Equals(nil) then
				GrowGuide.Show(menu.transform, guideJumpFunc)
			end
		else
			guideJumpFunc()
		end
	end)
end

local function JumpToRebelArmyWanted(index)
	RebelArmyWanted.SetTargetLevel(index)
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (RebelArmyWanted.gameObject == nil or RebelArmyWanted.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
        end
        if RebelArmyWanted.gameObject ~= nil and not RebelArmyWanted.gameObject:Equals(nil) then
			waitTimer = 0
			for waitTimer = 0 , 3 , GameTime.deltaTime do
				if not IsNil(RebelArmyWanted.transform) then
					if RebelArmyWanted.transform:Find(Format("Container/bg/Scroll View/Grid/{0}/btn_search", index)) == nil or RebelArmyWanted.transform:Find(Format("Container/bg/Scroll View/Grid/{0}/btn_search", index)):Equals(nil) then
						coroutine.step()
					end
				end
			end
			if not IsNil(RebelArmyWanted.transform) then
				local menu = RebelArmyWanted.transform:Find(Format("Container/bg/Scroll View/Grid/{0}/btn_search", index))
				if menu ~= nil and not menu:Equals(nil) then
					GrowGuide.Show(menu.transform, guideJumpFunc)
				end
			end
		end
	end)
end

local function JumpToRebelSearch()
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (rebel.gameObject == nil or rebel.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
        end
        if rebel.gameObject ~= nil then
	        local menu = rebel.transform:Find("Container/bg_left/mid/button_search")
	        if menu ~= nil and not menu:Equals(nil) then
				GrowGuide.Show(menu.transform, guideJumpFunc)
			end
		end
	end)
end

local function JumpToActivityRace(index)
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (ActivityRace.gameObject == nil or ActivityRace.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
        end
        if ActivityRace.gameObject ~= nil then
			waitTimer = 0
	        while waitTimer < 3 and (ActivityRace.transform:Find(Format("Container/Scroll View/Grid/card_list ({0})/base", index)) == nil or ActivityRace.transform:Find(Format("Container/Scroll View/Grid/card_list ({0})/base", index)):Equals(nil)) do
	        	coroutine.step()
	        	waitTimer = waitTimer + GameTime.deltaTime
	        end
	        local menu = ActivityRace.transform:Find(Format("Container/Scroll View/Grid/card_list ({0})/base", index))
	        if menu ~= nil and not menu:Equals(nil) then
				GrowGuide.Show(menu.transform, guideJumpFunc)
			end
		end
	end)
end

local function JumpToRes(restype)
	local resType = tonumber(restype)
	local basePos = MapInfoData.GetData().mypos
	local posIndex = WorldMap.MapCoordToPosIndex(basePos.x, basePos.y)
	WorldMapData.RequestAndSearchData(posIndex, function(data)
		local nearest = nil
		for i, v in ipairs(data) do
			for __, vv in ipairs(v.entrys) do
				if vv.data.entryType == resType and vv.res.owner == 0 then
					if nearest == nil then
						nearest = vv
					else
						local ax = vv.data.pos.x - basePos.x
						local ay = vv.data.pos.y - basePos.y
						local bx = nearest.data.pos.x - basePos.x
						local by = nearest.data.pos.y - basePos.y
						if (ax * ax + ay * ay) < (bx * bx + by * by) then
							nearest = vv
						end
					end
				end
			end
		end
		if nearest ~= nil then
			local pos = nearest.data.pos
			MainCityUI.ShowWorldMap(pos.x, pos.y, true, function()
				GrowGuide.Show()
			end)
		else
			FloatText.Show(TextMgr:GetText(Text.mission_ui2))
			MainCityUI.ShowWorldMap(basePos.x, basePos.y, true)
		end
	end)
end

local function JumpToBarrackGrade(grade)
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (Barrack.gameObject == nil or Barrack.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
		end
		if Barrack.transform then
			local menu = Barrack.transform:Find(Format("Container/bg_frane/Container/bg_right_{0}/chassis", grade))
			if menu ~= nil and not menu:Equals(nil) then
				GrowGuide.Show(menu.transform, guideJumpFunc)
			end
		end
	end)
end

local function JumpToBarrackTrain()
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (Barrack.gameObject == nil or Barrack.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
		end
		if Barrack.transform then
			if Barrack.transform:Find("Container/bg_frane/bg_bottom/bg_train").gameObject.activeInHierarchy then
				local menu = Barrack.transform:Find("Container/bg_frane/bg_bottom/bg_train/btn_upgrade")
				if menu ~= nil and not menu:Equals(nil) then
					GrowGuide.Show(menu.transform, guideJumpFunc)
				end
			end
		end
	end)
end

local function Speak(person, speak, callback)
	Story.ShowSigle(person, speak, callback == nil and guideJumpFunc or callback)
end

local function CheckUI(uiobject)
	local waitTimer = 0
	coroutine.start(function()
		coroutine.step()
		while waitTimer < 3 and (uiobject.gameObject == nil or uiobject.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
        end
        if uiobject.gameObject ~= nil then
			guideJumpFunc()
		end
	end)
end

local function GetGameObject(Module, path)
	if Module.transform then
		local menu = Module.transform:Find(path)
		if menu ~= nil and not menu:Equals(nil) then
			return menu.gameObject
		end
	end
	return nil
end

local function CheckGOActive(Module, path)
	if Module.transform then
		local menu = Module.transform:Find(path)
		if menu ~= nil and not menu:Equals(nil) then
			return menu.gameObject.activeInHierarchy
		end
	end
	return false
end

local function AddJump(target, func, param, param1, param2, param3, param4, param5)
	table.insert(target, function()
		func(param, param1, param2, param3, param4, param5)
	end)
end

local function JumpToUnionHelp()
	if UnionInfoData.HasUnion() then
		local waitTimer = 0
		coroutine.start(function()
			UnionHelp.Show()
			while waitTimer < 3 and (UnionHelp.gameObject == nil or UnionHelp.gameObject:Equals(nil)) do
	        	coroutine.step()
	        	waitTimer = waitTimer + GameTime.deltaTime
	        end
	        Speak("icon_guide", "Chapterstory_32", function()
	        	local menu = UnionHelp.transform:Find("ok btn")
		        local unionHelpCount = UnionHelpData.GetHelpCount()
		        if menu ~= nil and not menu:Equals(nil) and unionHelpCount > 0 then
					GrowGuide.Show(menu.transform, guideJumpFunc)
				end
	        end)
		end)
	else
		JoinUnion.Show()
		Speak("icon_guide", "Chapterstory_31")
	end
end

local function JumpToSoldierEquipBanner(isStrong)
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (SoldierEquipBanner.gameObject == nil or SoldierEquipBanner.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
		end
		if SoldierEquipBanner.transform then
			local menu = SoldierEquipBanner.transform:Find("Container/bg_frane/button")
			if menu ~= nil and not menu:Equals(nil) then
				GrowGuide.Show(menu.transform, guideJumpFunc, isStrong)
			end
		end
	end)
end

local function JumpToSoldierEquipUpGrade(isStrong)
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (Barrack_SoldierEquip.gameObject == nil or Barrack_SoldierEquip.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
		end
		if Barrack_SoldierEquip.transform then
			local menu = Barrack_SoldierEquip.transform:Find("Container/bg_frane/right/upgrade/button")
			if menu ~= nil and not menu:Equals(nil) then
				GrowGuide.Show(menu.transform, guideJumpFunc, isStrong)
			end
		end
	end)
end

local function JumpToMainInfomationEquip(id, isStrong)
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (MainInformation.gameObject == nil or MainInformation.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
		end
		if MainInformation.transform then
			local menu = MainInformation.transform:Find(string.format("Container/bg_franenew/mid/equip0%d", id))
			if menu ~= nil and not menu:Equals(nil) then
				GrowGuide.Show(menu.transform, guideJumpFunc, isStrong)
			end
		end
	end)
end

local function JumpToEquipMaterial(id, isStrong)
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (EquipSelectNew.gameObject == nil or EquipSelectNew.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
		end
		if EquipSelectNew.transform then
			local menu = EquipSelectNew.transform:Find("Container/bg_frane/right/mid/Scroll View/bg_cailiao/Grid")
			waitTimer = 0
			while waitTimer < 3 and menu.childCount == 0 do
				coroutine.step()
				waitTimer = waitTimer + GameTime.deltaTime
			end
			menu = menu:GetChild(id - 1)
			if menu ~= nil and not menu:Equals(nil) then
				GrowGuide.Show(menu.transform, guideJumpFunc, isStrong)
			end
		end
	end)
end

local function JumpToEquipBuild(isStrong)
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (EquipSelectNew.gameObject == nil or EquipSelectNew.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
		end
		if EquipSelectNew.transform then
			local menu = EquipSelectNew.transform:Find("Container/bg_frane/right/button2")
			if menu ~= nil and not menu:Equals(nil) then
				GrowGuide.Show(menu.transform, guideJumpFunc, isStrong)
			end
		end
	end)
end

local function JumpToEquipMake(isStrong)
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (EquipBuildNew.gameObject == nil or EquipBuildNew.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
		end
		if EquipBuildNew.transform then
			local menu = EquipBuildNew.transform:Find("Container/bg_frane/bg2/Container/left/button01")
			if menu ~= nil and not menu:Equals(nil) then
				GrowGuide.Show(menu.transform, guideJumpFunc, isStrong)
			end
		end
	end)
end

local function JumptoBtn(Module, path, isStrong)
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (Module.gameObject == nil or Module.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
		end
		if Module.transform then
			local menu = Module.transform:Find(path)
			if menu ~= nil and not menu:Equals(nil) then
				GrowGuide.Show(menu.transform, guideJumpFunc, isStrong)
			end
		end
	end)
end

local function JumpToChild(Module, path, child, btnpath, isStrong)
	local waitTimer = 0
	coroutine.start(function()
		while waitTimer < 3 and (Module.gameObject == nil or Module.gameObject:Equals(nil)) do
        	coroutine.step()
        	waitTimer = waitTimer + GameTime.deltaTime
		end
		if Module.transform then
			local menu = Module.transform:Find(path)
			waitTimer = 0
			while waitTimer < 3 and menu.childCount == 0 do
				coroutine.step()
			end
			menu = menu.childCount > 0 and menu:GetChild(child - 1) or nil
			if menu ~= nil and not menu:Equals(nil) then
				print(btnpath, menu.name, menu:Find(btnpath).name)
				GrowGuide.Show(btnpath == "" and menu or menu:Find(btnpath), guideJumpFunc, isStrong)
			end
		end
	end)
end

local function InitJumpList()
	if jumplist == nil then
		jumplist = {}

		jumplist[119] = {}
		AddJump(jumplist[119], CheckWorldMap, false)
		AddJump(jumplist[119], JumpToBuild, 1)
		AddJump(jumplist[119], JumpToCityMenu, 2)

		jumplist[120] = {}
		AddJump(jumplist[120], JumpToMainInfomation)
		AddJump(jumplist[120], WaitMainInfomation)
		AddJump(jumplist[120], Speak, "icon_guide", "tutorial_126")

		jumplist[121] = {}
		AddJump(jumplist[121], CheckWorldMap, false)
		AddJump(jumplist[121], JumpToBuild, 1)
		AddJump(jumplist[121], JumpToCityMenu, 2)

		jumplist[1802] = {}
		--AddJump(jumplist[1802], CheckWorldMap, false)
		AddJump(jumplist[1802], JumpToBuildNoMenu, 1, true)
		AddJump(jumplist[1802], function() Event.Resume(10) guideJumpFunc() end)
		--AddJump(jumplist[1802], JumpToCityMenu, 2)
		
		jumplist[1803] = {}
		--AddJump(jumplist[1803], CheckWorldMap, false)
		AddJump(jumplist[1803], JumpToBuildNoMenu, 22)
		AddJump(jumplist[1803], function()  Event.Check(12, true) guideJumpFunc() end)
		--AddJump(jumplist[1803], JumpToCityMenu, 7)
		
		jumplist[1804] = {}
		--AddJump(jumplist[1804], CheckWorldMap, false)
		--AddJump(jumplist[1804], JumpToActivityRebel)
		--AddJump(jumplist[1804], CheckUI, ActivityAll)
		--AddJump(jumplist[1804], JumpToActivityRebelTab, 2001)
		--AddJump(jumplist[1804], JumpToRebelArmyWanted, 2)
		AddJump(jumplist[1804], function() Event.Check(14, true) guideJumpFunc() end)
		
		jumplist[1805] = {}
		AddJump(jumplist[1805], CheckWorldMap, false)
		--AddJump(jumplist[1805], JumpToZhankai)
		AddJump(jumplist[1805], JumpToHero)
		
		jumplist[1806] = {}
		AddJump(jumplist[1806], CheckWorldMap, false)
		--AddJump(jumplist[1806], JumpToZhankai)
		AddJump(jumplist[1806], JumpToHero)
		
		jumplist[1808] = {}
		AddJump(jumplist[1808], CheckWorldMap, false)
		AddJump(jumplist[1808], GoPve)
		
		jumplist[1809] = {}
		AddJump(jumplist[1809], CheckWorldMap, false)
		AddJump(jumplist[1809], JumpToBuild, 22)
		
		jumplist[1810] = {}
		AddJump(jumplist[1810], CheckWorldMap, false)
		AddJump(jumplist[1810], JumpToBuild, 22)
		AddJump(jumplist[1810], JumpToCityMenu, 6)
		
		jumplist[1811] = {}
		AddJump(jumplist[1811], CheckWorldMap, false)
		AddJump(jumplist[1811], JumpToBuild, 4)
		
		jumplist[1812] = {}
		AddJump(jumplist[1812], CheckWorldMap, false)
		AddJump(jumplist[1812], JumpToActivityRebel)
		AddJump(jumplist[1812], CheckUI, ActivityAll)
		AddJump(jumplist[1812], JumpToActivityRebelTab, 2001)
		AddJump(jumplist[1812], JumpToRebelArmyWanted, 3)
		
		jumplist[1814] = {}
		AddJump(jumplist[1814], CheckWorldMap, false)
		AddJump(jumplist[1814], JumpToBuild, 6)
		AddJump(jumplist[1814], JumpToCityMenu, 2)
		
		jumplist[1815] = {}
		AddJump(jumplist[1815], CheckWorldMap, false)
		AddJump(jumplist[1815], JumpToBuild, 25)
		AddJump(jumplist[1815], JumpToCityMenu, 23)
		AddJump(jumplist[1815], CheckUI, HeroAppointUI)
		AddJump(jumplist[1815], Speak, "305", "Chapterstory_29")
		AddJump(jumplist[1815], JumoToAppoint)
		AddJump(jumplist[1815], CheckUI, HeroAppoint)
		AddJump(jumplist[1815], JumoToAppointHero)
		
		jumplist[1816] = {}
		AddJump(jumplist[1816], CheckWorldMap, false)
		AddJump(jumplist[1816], JumpToBuild, 1)
		AddJump(jumplist[1816], JumpToCityMenu, 2)
		
		jumplist[1817] = {}
		AddJump(jumplist[1817], CheckWorldMap, false)
		AddJump(jumplist[1817], JumpToBuild, 11)
		AddJump(jumplist[1817], JumpToCityMenu, 2)
		
		jumplist[1818] = {}
		AddJump(jumplist[1818], CheckWorldMap, false)
		AddJump(jumplist[1818], JumpToBuild, 12)
		AddJump(jumplist[1818], JumpToCityMenu, 2)
		
		jumplist[1820] = {}
		AddJump(jumplist[1820], CheckWorldMap, false)
		AddJump(jumplist[1820], JumpToBuild, 4)
		AddJump(jumplist[1820], JumpToCityMenu, 2)
		
		jumplist[1821] = {}
		--[[ AddJump(jumplist[1821], CheckWorldMap, false)
		AddJump(jumplist[1821], JumpToBuild, 6)
		AddJump(jumplist[1821], JumpToCityMenu, 7)
		AddJump(jumplist[1821], CheckUI, Laboratory)
		AddJump(jumplist[1821], JumpToLaboratory, 1)
		AddJump(jumplist[1821], JumpToLaboratoryMenu, 2, 5) ]]
		AddJump(jumplist[1821], function()
			local building = maincity.GetBuildingByID(26)
			if building ~= nil and building.data ~= nil then
				if maincity.IsUpgrading(1, 3) then
					AddJump(nowjumplist, JumpToBuildNoMenu, 1)
					AddJump(nowjumplist, function() Event.Check(110, true) end)
					guideJumpFunc()
				else
					if building.data.level < 2 then
						if maincity.IsUpgrading(26, 2) then
							AddJump(nowjumplist, JumpToBuildNoMenu, 1, true)
							AddJump(nowjumplist, function() Event.Check(111, true) end)
							guideJumpFunc()
						else
							AddJump(nowjumplist, JumpToBuildNoMenu, 1, true)
							AddJump(nowjumplist, function() Event.Check(15, true) end)
							guideJumpFunc()
						end
					else
						AddJump(nowjumplist, JumpToBuildNoMenu, 1, true)
						AddJump(nowjumplist, function() Event.Check(16, true) end)
						guideJumpFunc()
					end
				end
			end
		end)
		
		jumplist[1822] = {}
		--[[ AddJump(jumplist[1822], CheckWorldMap, false)
		AddJump(jumplist[1822], JumpToBuild, 21)
		AddJump(jumplist[1822], JumpToCityMenu, 2) ]]
		AddJump(jumplist[1822], function()
			if maincity.GetBuildingLevelByID(1) >=3 then
				AddJump(nowjumplist, JumpToBuildNoMenu, 23)
				AddJump(nowjumplist, function() Event.Check(17, true) end)
				guideJumpFunc()
			else
				AddJump(nowjumplist, JumpToBuildNoMenu, 23)
				AddJump(nowjumplist, function() Event.Check(101, true) end)
				guideJumpFunc()
			end
		end)
		
		jumplist[1823] = {}
		AddJump(jumplist[1823], function()
			if maincity.GetBuildingLevelByID(1) >=3 then
				--[[if maincity.GetBuildingLevelByID(5) > 0 then
					AddJump(nowjumplist, JumpToBuildNoMenu, 23)
					AddJump(nowjumplist, function() Event.Check(19, true) end)
					guideJumpFunc()
				else]]
					AddJump(nowjumplist, JumpToBuildNoMenu, 23)
					AddJump(nowjumplist, function() Event.Check(18, true) end)
					guideJumpFunc()
				--end
			else
				AddJump(nowjumplist, JumpToBuildNoMenu, 23)
				AddJump(nowjumplist, function() Event.Check(101, true) end)
				guideJumpFunc()
			end
		end)
		
		jumplist[1824] = {}
		--[[ AddJump(jumplist[1824], CheckWorldMap, false)
		AddJump(jumplist[1824], JumpToBuild, 2) ]]
		--AddJump(jumplist[1824], function() ActivityAll.Show("RebelArmyWanted") end)
		AddJump(jumplist[1824], function() Event.Check(20, true) end)
		
		jumplist[1826] = {}
		AddJump(jumplist[1826], JumpToMainInfomation)
		AddJump(jumplist[1826], JumpToTalent)
		AddJump(jumplist[1826], CheckUI, TalentInfo)
		AddJump(jumplist[1826], Speak, "icon_guide", "tutorial_69")
		
		jumplist[1827] = {}
		AddJump(jumplist[1827], CheckWorldMap, false)
		--AddJump(jumplist[1827], JumpToZhankai)
		AddJump(jumplist[1827], JumpToHero)
		AddJump(jumplist[1827], CheckUI, HeroList)
		AddJump(jumplist[1827], Speak, "icon_guide", "tutorial_139")
		
		jumplist[1828] = {}
		AddJump(jumplist[1828], CheckWorldMap, false)
		AddJump(jumplist[1828], JumpToActivityRebel)
		AddJump(jumplist[1828], CheckUI, ActivityAll)
		AddJump(jumplist[1828], JumpToActivityRebelTab, 2001)
		AddJump(jumplist[1828], JumpToRebelArmyWanted, 5)
		
		jumplist[1829] = {}
		AddJump(jumplist[1829], CheckWorldMap, false)
		--AddJump(jumplist[1829], JumpToZhankai)
		AddJump(jumplist[1829], JumpToHero)
		
		jumplist[1830] = {}
		AddJump(jumplist[1830], CheckWorldMap, false)
		AddJump(jumplist[1830], JumpToBuild, 1)
		AddJump(jumplist[1830], JumpToCityMenu, 2)
		
		jumplist[1832] = {}
		AddJump(jumplist[1832], CheckWorldMap, false)
		--AddJump(jumplist[1832], JumpToZhankai)
		AddJump(jumplist[1832], JumpToUnion)
		
		jumplist[1833] = {}
		AddJump(jumplist[1833], CheckWorldMap, true)
		AddJump(jumplist[1833], Speak, "icon_guide", "Activity_Grow_ui5")
		AddJump(jumplist[1833], JumpToLingtu)
		
		jumplist[1834] = {}
		AddJump(jumplist[1834], CheckWorldMap, false)
		AddJump(jumplist[1834], JumpToBuild, 43)
		
		jumplist[1835] = {}
		AddJump(jumplist[1835], CheckWorldMap, false)
		AddJump(jumplist[1835], JumpToBuild, 21)
		AddJump(jumplist[1835], JumpToCityMenu, 6)
		
		jumplist[1836] = {}
		AddJump(jumplist[1836], CheckWorldMap, false)
		AddJump(jumplist[1836], JumpToUnionHelp)
		
		jumplist[1838] = {}
		AddJump(jumplist[1838], CheckWorldMap, false)
		AddJump(jumplist[1838], JumpToBuild, 6)
		AddJump(jumplist[1838], JumpToCityMenu, 2)
		
		jumplist[1839] = {}
		AddJump(jumplist[1839], CheckWorldMap, false)
		AddJump(jumplist[1839], JumpToActivityRebel)
		AddJump(jumplist[1839], CheckUI, ActivityAll)
		AddJump(jumplist[1839], JumpToActivityRebelTab, 2001)
		AddJump(jumplist[1839], JumpToRebelArmyWanted, 7)
		
		jumplist[1840] = {}
		AddJump(jumplist[1840], CheckWorldMap, false)
		AddJump(jumplist[1840], JumpToActivityRebel)
		AddJump(jumplist[1840], CheckUI, ActivityAll)
		AddJump(jumplist[1840], JumpToActivityRebelTab, 103)
		AddJump(jumplist[1840], JumpToActivityRace, 1)
		
		jumplist[1841] = {}
		--[[ AddJump(jumplist[1841], CheckWorldMap, false)
		AddJump(jumplist[1841], JumpToBuild, 6)
		AddJump(jumplist[1841], JumpToCityMenu, 7)
		AddJump(jumplist[1841], CheckUI, Laboratory)
		AddJump(jumplist[1841], JumpToLaboratory, 2)
		AddJump(jumplist[1841], JumpToLaboratoryMenu, 2, 5) ]]
		AddJump(jumplist[1841], function() Event.Check(21, true) end)
		
		jumplist[1842] = {}
		--[[ AddJump(jumplist[1842], CheckWorldMap, false)
		AddJump(jumplist[1842], JumpToBuild, 4)
		AddJump(jumplist[1842], JumpToCityMenu, 2) ]]
		AddJump(jumplist[1842], function()
			local chengqiang = maincity.GetBuildingByID(26)
			local liantiechang = maincity.GetBuildingByID(12)
			if chengqiang == nil or chengqiang.data == nil or (chengqiang ~= nil and chengqiang.data ~= nil and chengqiang.data.level < 3 and not maincity.IsUpgrading(26, 3)) then
				AddJump(nowjumplist, JumpToBuildNoMenu, 1, true)
				AddJump(nowjumplist, function() Event.Check(22, true) end)
				guideJumpFunc()
			elseif liantiechang == nil or liantiechang.data == nil or (liantiechang ~= nil and liantiechang.data ~= nil and liantiechang.data.level < 3 and not maincity.IsUpgrading(26, 3)) then
				AddJump(nowjumplist, JumpToBuildNoMenu, 1, true)
				AddJump(nowjumplist, function() Event.Check(23, true) end)
				guideJumpFunc()
			else
				if maincity.IsUpgrading(1, 4) then
					AddJump(nowjumplist, JumpToBuildNoMenu, 1)
					AddJump(nowjumplist, function() Event.Check(107, true) end)
					guideJumpFunc()
				else
					AddJump(nowjumplist, JumpToBuildNoMenu, 1, true)
					AddJump(nowjumplist, function() Event.Check(24, true) end)
					guideJumpFunc()
				end
			end
		end)

		jumplist[1843] = {}
		AddJump(jumplist[1843], JumpToBuildNoMenu, 6)
		AddJump(jumplist[1843], function()
			if maincity.GetBuildingLevelByID(1) >= 4 then
				if maincity.GetBuildingLevelByID(6) > 0 then
					Event.Check(26, true)
				else
					Event.Check(25, true)
				end
			else
				Event.Check(102, true)
			end
			guideJumpFunc()
		end)
		
		jumplist[1844] = {}
		--[[ AddJump(jumplist[1844], CheckWorldMap, false)
		AddJump(jumplist[1844], JumpToBarrack)
		AddJump(jumplist[1844], JumpToCityMenu, 6) ]]
		AddJump(jumplist[1844], JumpToEmptyZiyuantian)
		AddJump(jumplist[1844], function()
			Event.Check(27, true)
		end)
		
		jumplist[1845] = {}
		--[[ AddJump(jumplist[1845], CheckWorldMap, false)
		AddJump(jumplist[1845], Speak, "icon_guide", "tutorial_101")
		AddJump(jumplist[1845], JumpToBarrack)
		AddJump(jumplist[1845], JumpToCityMenu, 6) ]]
		AddJump(jumplist[1845], function() Event.Check(28, true) end)
		
		jumplist[1846] = {}
		AddJump(jumplist[1846], CheckWorldMap, false)
		--AddJump(jumplist[1846], JumpToZhankai)
		AddJump(jumplist[1846], JumpToUnion)
		AddJump(jumplist[1846], CheckUI, UnionInfo)
		AddJump(jumplist[1846], JumpToUnionContent)
		AddJump(jumplist[1846], JumpToUnionBuilding, 5)
		
		jumplist[1847] = {}
		AddJump(jumplist[1847], CheckWorldMap, false)
		AddJump(jumplist[1847], JumpToActivityRebel)
		AddJump(jumplist[1847], CheckUI, ActivityAll)
		AddJump(jumplist[1847], JumpToActivityRebelTab, 107)
		
		jumplist[1848] = {}
		AddJump(jumplist[1848], CheckWorldMap, false)
		AddJump(jumplist[1848], JumpToBuild, 6)
		AddJump(jumplist[1848], JumpToCityMenu, 7)
		AddJump(jumplist[1848], CheckUI, Laboratory)
		AddJump(jumplist[1848], Speak, "icon_guide", "tutorial_96;tutorial_97")
		AddJump(jumplist[1848], JumpToLaboratory, 5)

		jumplist[1861] = {}
		AddJump(jumplist[1861], function() Event.Check(29, true) end)

		jumplist[1862] = {}
		AddJump(jumplist[1862], function()
			local chengqiang = maincity.GetBuildingByID(26)
			local liantiechang = maincity.GetBuildingByID(11)
			if chengqiang == nil or chengqiang.data == nil or (chengqiang ~= nil and chengqiang.data ~= nil and chengqiang.data.level < 4 and not maincity.IsUpgrading(26, 4)) then
				AddJump(nowjumplist, JumpToBuildNoMenu, 1, true)
				AddJump(nowjumplist, function() Event.Check(30, true) end)
				guideJumpFunc()
			elseif liantiechang == nil or liantiechang.data == nil or (liantiechang ~= nil and liantiechang.data ~= nil and liantiechang.data.level < 4 and not maincity.IsUpgrading(11, 4)) then
				AddJump(nowjumplist, JumpToBuildNoMenu, 1, true)
				AddJump(nowjumplist, function() Event.Check(31, true) end)
				guideJumpFunc()
			else
				if maincity.IsUpgrading(1,5) then
					AddJump(nowjumplist, JumpToBuildNoMenu, 1)
					AddJump(nowjumplist, function() Event.Check(106, true) end)
					guideJumpFunc()
				else
					if (chengqiang ~= nil and chengqiang.data ~= nil and chengqiang.data.level < 4) or (liantiechang ~= nil and liantiechang.data ~= nil and liantiechang.data.level < 4) then
						AddJump(nowjumplist, JumpToBuildNoMenu, 1, true)
						AddJump(nowjumplist, function() Event.Check(109, true) end)
						guideJumpFunc()
					else
						AddJump(nowjumplist, JumpToBuildNoMenu, 1, true)
						AddJump(nowjumplist, function() Event.Check(32, true) end)
						guideJumpFunc()
					end
				end
			end
		end)

		jumplist[1863] = {}
		AddJump(jumplist[1863], function() 
			if maincity.GetBuildingLevelByID(1) >= 5 then
				if maincity.GetBuildingLevelByID(4) > 0 then
					AddJump(nowjumplist, JumpToBuildNoMenu, 4, true)
					AddJump(nowjumplist, function() Event.Check(35, true) end)
					guideJumpFunc()
				else
					AddJump(nowjumplist, JumpToBuildNoMenu, 4)
					AddJump(nowjumplist, function() Event.Check(34, true) end)
					guideJumpFunc()
				end
			else
				AddJump(nowjumplist, JumpToBuildNoMenu, 4)
				AddJump(nowjumplist, function() Event.Check(103, true) end)
				guideJumpFunc()
			end
		end)

		jumplist[1864] = {}
		AddJump(jumplist[1864], JumpToBuildNoMenu, 21)
		AddJump(jumplist[1864], function()
			if maincity.IsBarrackEmpty(21) then
				Event.Check(36, true)
			else
				Event.Check(37, true) 
			end
			guideJumpFunc()
		end)
		--[[AddJump(jumplist[1864], function()
			if maincity.GetBuildingLevelByID(1) >= 5 then
				if maincity.GetBuildingLevelByID(2) > 0 then
					Event.Check(37, true)
				else
					Event.Check(36, true) 
				end
			else
				Event.Check(104, true)
			end
		end)]]

		jumplist[1865] = {}
		AddJump(jumplist[1865], function() 
			Event.Check(38, true) 
			guideJumpFunc()
		end)

		jumplist[1881] = {}
		AddJump(jumplist[1881], function()
			if BuildingData.HasAppointedHero(1) then
				if maincity.IsUpgrading(1,6) then
					AddJump(nowjumplist, JumpToBuildNoMenu, 1)
					AddJump(nowjumplist, function() Event.Check(105, true) end)
					guideJumpFunc()
				else
					AddJump(nowjumplist, JumpToBuildNoMenu, 1, true)
					AddJump(nowjumplist, function() Event.Check(40, true) end)
					guideJumpFunc()
				end
			else
				AddJump(nowjumplist, JumpToBuildNoMenu, 1)
				AddJump(nowjumplist, function() Event.Check(39, true) end)
				guideJumpFunc()
			end
		end)

		jumplist[1882] = {}
		AddJump(jumplist[1882], function() Event.Check(41, true) end)

		jumplist[1883] = {}
		AddJump(jumplist[1883], JumpToBuildNoMenu, 22, true)
		AddJump(jumplist[1883], function() Event.Check(42, true) end)

		jumplist[1884] = {}
		AddJump(jumplist[1884], JumpToBuildNoMenu, 22)
		AddJump(jumplist[1884], function() Event.Check(43, true) end)

		jumplist[1886] = {}
		AddJump(jumplist[1886], JumpToBuildNoMenu, 21, true)

		jumplist[1885] = {}
		AddJump(jumplist[1885], function() Event.Check(44, true) end)
		
		jumplist[1901] = {}
		AddJump(jumplist[1901], function()
			if maincity.IsUpgrading(1) then
				AddJump(nowjumplist, JumpToBuild, 1)
				AddJump(nowjumplist, JumpToCityMenu, 10)
				guideJumpFunc()
			else
				AddJump(nowjumplist, JumpToBuildNoMenu, 1, true)
				guideJumpFunc()
			end
		end)

		jumplist[1902] = {}
		--AddJump(jumplist[1902], JumpToZhankai)
		AddJump(jumplist[1902], JumpToHero)
		AddJump(jumplist[1902], CheckUI, HeroList)
		AddJump(jumplist[1902], JumpToFirstHero)
		AddJump(jumplist[1902], CheckUI, HeroInfo)
		AddJump(jumplist[1902], JumpToHeroLevelUp)

		jumplist[1903] = {}
		AddJump(jumplist[1903], JumpToMission)
		AddJump(jumplist[1903], JumpToMissionTab, 2)

		jumplist[1904] = {}
		AddJump(jumplist[1904], CheckWorldMap, true)
		AddJump(jumplist[1904], JumpToSearchBtn)
		AddJump(jumplist[1904], JumptoBtn, MapSearch, "Container/item widget/item bg3")

		jumplist[1905] = {}
		AddJump(jumplist[1905], CheckWorldMap, true)
		AddJump(jumplist[1905], JumpToSearchBtn)

		jumplist[1921] = {}
		AddJump(jumplist[1921], JumpToBuild, 27)
		AddJump(jumplist[1921], JumpToCityMenu, 14)

		jumplist[1922] = {}
		AddJump(jumplist[1922], CheckWorldMap, true)
		AddJump(jumplist[1922], JumpToSearchBtn)

		jumplist[1923] = {}
		AddJump(jumplist[1923], GoPve)

		jumplist[1924] = {}
		AddJump(jumplist[1924], CheckWorldMap, false)
		AddJump(jumplist[1924], JumpToBuild, 1)
		AddJump(jumplist[1924], JumpToCityMenu, 2)
		AddJump(jumplist[1924], CheckUI, BuildingUpgrade)
		AddJump(jumplist[1924], JumptoBtn, BuildingUpgrade, "Container/bg_frane/btn_upgrade")
		--[[AddJump(jumplist[1924], JumpToBuild, 6)
		AddJump(jumplist[1924], JumpToCityMenu, 7)
		AddJump(jumplist[1924], CheckUI, Laboratory)
		AddJump(jumplist[1924], JumpToLaboratory, 5)
		AddJump(jumplist[1924], JumpToLaboratoryMenu, 3, 6)]]

		jumplist[1925] = {}
		--AddJump(jumplist[1925], JumpToRebelSurround)
		AddJump(jumplist[1925], JumpToBuild, 22)
		AddJump(jumplist[1925], JumpToCityMenu, 6)
		AddJump(jumplist[1925], JumpToBarrackTrain)

		jumplist[1941] = {}
		AddJump(jumplist[1941], CheckWorldMap, false)
		AddJump(jumplist[1941], JumpToBuild, 1)
		AddJump(jumplist[1941], JumpToCityMenu, 2)
		AddJump(jumplist[1941], CheckUI, BuildingUpgrade)
		AddJump(jumplist[1941], JumptoBtn, BuildingUpgrade, "Container/bg_frane/btn_upgrade")
		--[[AddJump(jumplist[1941], JumpToBuild, 6)
		AddJump(jumplist[1941], JumpToCityMenu, 7)
		AddJump(jumplist[1941], CheckUI, Laboratory)
		AddJump(jumplist[1941], JumpToLaboratory, 5)
		AddJump(jumplist[1941], JumpToLaboratoryMenu, 4, 6)]]

		--[[jumplist[1942] = {}
		AddJump(jumplist[1942], JumpToBuild, 21)
		AddJump(jumplist[1942], JumpToCityMenu, 6)
		AddJump(jumplist[1942], JumpToBarrackGrade, 2)]]

		jumplist[1943] = {}
		AddJump(jumplist[1943], GoPve)

		jumplist[1944] = {}
		AddJump(jumplist[1944], JumpToZiyuantianNoMenu, 10, true)
		--AddJump(jumplist[1944], JumpToCityMenu, 2)

		--[[jumplist[1945] = {}
		AddJump(jumplist[1945], CheckWorldMap, true)
		AddJump(jumplist[1945], JumpToWarZone)
		--[[AddJump(jumplist[1945], function()
			if ActivityData.isBattleFieldActivityAvailable(2002) then
				AddJump(nowjumplist, JumpToActivityRebel)
				AddJump(nowjumplist, CheckUI, ActivityAll)
				AddJump(nowjumplist, JumpToActivityRebelTab, 2002)
				AddJump(nowjumplist, JumpToRebelSearch)
				guideJumpFunc()
			else
				MessageBox.Show(TextMgr:GetText("gun carrier_tips"))
			end
		end)--]]

		jumplist[1931] = {}
		AddJump(jumplist[1931], CheckWorldMap, false)
		AddJump(jumplist[1931], JumpToBuild, 1)
		AddJump(jumplist[1931], JumpToCityMenu, 2)
		AddJump(jumplist[1931], CheckUI, BuildingUpgrade)
		AddJump(jumplist[1931], JumptoBtn, BuildingUpgrade, "Container/bg_frane/btn_upgrade")

		jumplist[1951] = {}
		AddJump(jumplist[1951], CheckWorldMap, false)
		AddJump(jumplist[1951], JumpToBuild, 1)
		AddJump(jumplist[1951], JumpToCityMenu, 2)
		AddJump(jumplist[1951], CheckUI, BuildingUpgrade)
		AddJump(jumplist[1951], JumptoBtn, BuildingUpgrade, "Container/bg_frane/btn_upgrade")

		jumplist[1971] = {}
		AddJump(jumplist[1971], CheckWorldMap, false)
		AddJump(jumplist[1971], JumpToBuild, 1)
		AddJump(jumplist[1971], JumpToCityMenu, 2)
		AddJump(jumplist[1971], CheckUI, BuildingUpgrade)
		AddJump(jumplist[1971], JumptoBtn, BuildingUpgrade, "Container/bg_frane/btn_upgrade")

		jumplist[1991] = {}
		AddJump(jumplist[1991], CheckWorldMap, false)
		AddJump(jumplist[1991], JumpToBuild, 1)
		AddJump(jumplist[1991], JumpToCityMenu, 2)
		AddJump(jumplist[1991], CheckUI, BuildingUpgrade)
		AddJump(jumplist[1991], JumptoBtn, BuildingUpgrade, "Container/bg_frane/btn_upgrade")

		jumplist[1961] = {}
		AddJump(jumplist[1961], CheckWorldMap, false)
		AddJump(jumplist[1961], JumpToBuild, 1)
		AddJump(jumplist[1961], JumpToCityMenu, 2)
		AddJump(jumplist[1961], CheckUI, BuildingUpgrade)
		AddJump(jumplist[1961], JumptoBtn, BuildingUpgrade, "Container/bg_frane/btn_upgrade")
		--[[AddJump(jumplist[1961], JumpToBuild, 6)
		AddJump(jumplist[1961], JumpToCityMenu, 7)
		AddJump(jumplist[1961], CheckUI, Laboratory)
		AddJump(jumplist[1961], JumpToLaboratory, 5)
		AddJump(jumplist[1961], JumpToLaboratoryMenu, 7, 6)]]

		jumplist[1952] = {}
		AddJump(jumplist[1952], CheckWorldMap, false)
		AddJump(jumplist[1952], JumpToBuild, 6)
		AddJump(jumplist[1952], JumpToCityMenu, 2)
		AddJump(jumplist[1952], CheckUI, BuildingUpgrade)
		AddJump(jumplist[1952], JumptoBtn, BuildingUpgrade, "Container/bg_frane/btn_upgrade")

		jumplist[1992] = {}
		AddJump(jumplist[1992], CheckWorldMap, false)
		AddJump(jumplist[1992], JumpToBuild, 6)
		AddJump(jumplist[1992], JumpToCityMenu, 2)
		AddJump(jumplist[1992], CheckUI, BuildingUpgrade)
		AddJump(jumplist[1992], JumptoBtn, BuildingUpgrade, "Container/bg_frane/btn_upgrade")

		--[[jumplist[1962] = {}
		AddJump(jumplist[1962], function()
			MessageBox.Show(TextMgr:GetText("maincity_ui13"))
			guideJumpFunc()
		end)]]

		--[[jumplist[1963] = {}
		AddJump(jumplist[1963], GoPve)]]

		--[[jumplist[1964] = {}
		AddJump(jumplist[1964], CheckWorldMap, false)
		AddJump(jumplist[1964], JumpToBuild, 6)
		AddJump(jumplist[1964], JumpToCityMenu, 2)]]
		--AddJump(jumplist[1964], JumpToZhankai)
		--AddJump(jumplist[1964], JumpToUnion)
		--AddJump(jumplist[1964], CheckUI, UnionInfo)
		--AddJump(jumplist[1964], JumpToUnionContent)
		--AddJump(jumplist[1964], JumpToUnionBuilding, 5)

		--[[jumplist[1965] = {}
		AddJump(jumplist[1965], JumpToActivityRebel)
		AddJump(jumplist[1965], CheckUI, ActivityAll)
		AddJump(jumplist[1965], JumpToActivityRebelTab, 107)]]

		jumplist[9001] = {}
		AddJump(jumplist[9001], JumpToSoldierEquipBanner, true)
		AddJump(jumplist[9001], CheckWorldMap, false)
		AddJump(jumplist[9001], JumpToMainInfomation, true)
		AddJump(jumplist[9001], JumpToMainInfomationEquip, 1, true)
		AddJump(jumplist[9001], JumpToEquipMaterial, 1, true)
		AddJump(jumplist[9001], Speak, "icon_guide_male", "tutorial_equip_2")
		AddJump(jumplist[9001], JumpToEquipBuild, true)
		AddJump(jumplist[9001], Speak, "icon_guide_male", "tutorial_equip_1")
		AddJump(jumplist[9001], JumpToEquipMake, true)
		AddJump(jumplist[9001], JumptoBtn, EquipBuildNew, "Container/bg_frane/bg_top/btn_close", true)
		AddJump(jumplist[9001], JumpToEquipBuild, true)
		--AddJump(jumplist[9001], JumptoBtn, EquipSelectNew, "Container/bg_frane/bg_top/btn_close", true)
		--AddJump(jumplist[9001], JumptoBtn, MainInformation, "Container/bg_franenew/btn_close", true)

		jumplist[9002] = {}
		AddJump(jumplist[9002], JumpToSoldierEquipBanner, true)
		AddJump(jumplist[9002], CheckWorldMap, false)
		AddJump(jumplist[9002], JumpToMainInfomation, true)
		AddJump(jumplist[9002], JumptoBtn, MainInformation, "Container/page/info2", true)
		AddJump(jumplist[9002], Speak, "icon_guide_male", "tutorial_rank_1")
		AddJump(jumplist[9002], JumptoBtn, MilitaryRank, "Container/MilitaryRank/rankinfo/button", true)

		jumplist[9003] = {}
		AddJump(jumplist[9003], JumpToSoldierEquipBanner, true)
		AddJump(jumplist[9003], CheckWorldMap, false)
		AddJump(jumplist[9003], JumpToMainInfomation, true)
		AddJump(jumplist[9003], JumptoBtn, MainInformation, "Container/page/info3", true)
		AddJump(jumplist[9003], Speak, "icon_guide_male", "tutorial_SoldierLevel_1")
		AddJump(jumplist[9003], JumptoBtn, SoldierLevel, "Container/back/right/button2", true)

		jumplist[9004] = {}
		AddJump(jumplist[9004], JumpToSoldierEquipBanner, true)
		AddJump(jumplist[9004], Speak, "icon_guide", "tutorial_Rune1")
		AddJump(jumplist[9004], CheckWorldMap, false)
		AddJump(jumplist[9004], JumptoBtn, MainCityUI, "Container/bg_zhankai/Panel_left/bg_left/bg_rune/btn_union", true)
		AddJump(jumplist[9004], Speak, "icon_guide", "tutorial_Rune2")
		AddJump(jumplist[9004], JumptoBtn, Rune, "Container/bg_frane/left/equip/blue/1", true)
		AddJump(jumplist[9004], JumptoBtn, Rune, "Container/bg_frane/right/content2/info/Scroll View/Grid/own(Clone)", true)
		AddJump(jumplist[9004], Speak, "icon_guide", "tutorial_Rune3")

		jumplist[9005] = {}
		AddJump(jumplist[9005], JumpToSoldierEquipBanner, true)
		AddJump(jumplist[9005], function()
			maincity.ResetUICameraPress()
			guideJumpFunc()
		end)
		AddJump(jumplist[9005], JumpToBuild, 8, true)
		AddJump(jumplist[9005], JumptoBtn, BuildingLocked, "Container/bg_frane/btn_confirm", true)
		AddJump(jumplist[9005], Speak, "icon_guide", "tutorial_Moba1")
		AddJump(jumplist[9005], JumpToBuild, 8, true)

		jumplist[9006] = {}
		AddJump(jumplist[9006], Speak, "icon_guide", "tutorial_Moba2;tutorial_Moba3")
		AddJump(jumplist[9006], JumptoBtn, Entrance, "Container/bg_frane/mid/right/now", true)
		AddJump(jumplist[9006], Speak, "icon_guide", "tutorial_Moba4")

		jumplist[9007] = {}
		AddJump(jumplist[9007], Speak, "icon_guide", "tutorial_Moba5")
		AddJump(jumplist[9007], function()
			PlayerPrefs.SetInt("MobaRole"..MainData.GetCharId(), 1)
			guideJumpFunc()
		end)

		jumplist[9008] = {}
		AddJump(jumplist[9008], Speak, "icon_guide", "tutorial_Moba6")
		AddJump(jumplist[9008], JumptoBtn, MobaMain, "Container/btn_bigmap", true)
		AddJump(jumplist[9008], CheckUI, MobaWarZoneMap)
		AddJump(jumplist[9008], function()
			local map = MobaWarZoneMap.transform:Find("Container/map_bg/map")
			if map.localPosition.x > 0 then
				map.localPosition = Vector3(-104, map.localPosition.y, map.localPosition.z)
				Speak("icon_guide", "tutorial_Moba7;tutorial_Moba8;tutorial_Moba9", function()
					local menu = MobaWarZoneMap.transform:Find("Container/map_bg/map/info_bg/building_bg/4/Container/icon_gov")
					NGUITools.AddWidgetCollider(menu.gameObject)
					SetClickCallback(menu.gameObject, nil)
					GrowGuide.Show(menu, function()
						MobaWarZoneMap.SelectTile(29, 2)
						guideJumpFunc()
					end, true)
				end)
			else
				map.localPosition = Vector3(104, map.localPosition.y, map.localPosition.z)
				Speak("icon_guide", "tutorial_Moba7;tutorial_Moba8;tutorial_Moba9", function()
					local menu = MobaWarZoneMap.transform:Find("Container/map_bg/map/info_bg/building_bg/1/Container/icon_gov")
					NGUITools.AddWidgetCollider(menu.gameObject)
					SetClickCallback(menu.gameObject, nil)
					GrowGuide.Show(menu, function()
						MobaWarZoneMap.SelectTile(2, 29)
						guideJumpFunc()
					end, true)
				end)
			end
		end)
		AddJump(jumplist[9008], Speak, "icon_guide", "tutorial_Moba10")
		AddJump(jumplist[9008], JumptoBtn, MobaMain, "Container/bg_coordinate/btn_coord", true)
		AddJump(jumplist[9008], JumptoBtn, MobaMain, "Container/bg_zhankai/Panel_left/bg_left/bg_shop/btn_bag", true)
		AddJump(jumplist[9008], Speak, "icon_guide", "tutorial_Moba11;tutorial_Moba12")
		AddJump(jumplist[9008], function()
			PlayerPrefs.SetInt("MobaMapGuide"..MainData.GetCharId(), 1)
			guideJumpFunc()
		end)

		jumplist[9009] = {}
		AddJump(jumplist[9009], CheckWorldMap, false)
		AddJump(jumplist[9009], Speak, "icon_guide", "Arena_Guide_desc1")
		AddJump(jumplist[9009], JumpToBuild, 9, true)
		AddJump(jumplist[9009], CheckUI, BattleRank)
		AddJump(jumplist[9009], SetGrowMask, 139, -54, 546, 364)
		AddJump(jumplist[9009], Speak, "icon_guide", "Arena_Guide_desc2;Arena_Guide_desc3")
		AddJump(jumplist[9009], CloseGrowMask)
		AddJump(jumplist[9009], JumptoBtn, BattleRank, "Container/bg_frane/bg_top/bg_my/btn_change", true)
		AddJump(jumplist[9009], CheckUI, BattleFormation)
		AddJump(jumplist[9009], function()
			BattleFormation.FirstSelect()
			guideJumpFunc()
		end)
		AddJump(jumplist[9009], SetGrowMask, -215, -53, 433, 454)
		AddJump(jumplist[9009], Speak, "icon_guide", "Arena_Guide_desc4")
		AddJump(jumplist[9009], WaitStep)
		AddJump(jumplist[9009], WaitStep)
		AddJump(jumplist[9009], SetGrowMask, 215, -34, 448, 417)
		AddJump(jumplist[9009], Speak, "icon_guide", "Arena_Guide_desc5;Arena_Guide_desc6")
		AddJump(jumplist[9009], CloseGrowMask)
		AddJump(jumplist[9009], JumptoBtn, BattleFormation, "Container/bg_frane/btn_upgrade", true)
		AddJump(jumplist[9009], JumptoBtn, BattleFormation, "Container/bg_frane/bg_top/btn_close", true)
		AddJump(jumplist[9009], Speak, "icon_guide", "Arena_Guide_desc7")
		AddJump(jumplist[9009], JumptoBtn, BattleRank, "Container/bg_frane/bg_mid/Scroll View/Grid/list_playerinfo3/bg/btn_battle")

		jumplist[9010] = {}
		AddJump(jumplist[9010], function()
			MapHelp.Open(2800, false, function() end, false, true)
			guideJumpFunc()
		end)
		
		jumplist[9999] = {}
		AddJump(jumplist[9999], JumpToSoldierEquipBanner, true)
		AddJump(jumplist[9999], CheckWorldMap, false)
		AddJump(jumplist[9999], JumpToBuild, 21, true)
		AddJump(jumplist[9999], JumpToCityMenu, 27, true)
		AddJump(jumplist[9999], CheckUI, Barrack_SoldierEquip)
		AddJump(jumplist[9999], JumpToSoldierEquipUpGrade, true)

		jumplist[10001] = {}
		AddJump(jumplist[10001], CheckWorldMap, false)
		AddJump(jumplist[10001], JumpToBuild, 1)
		AddJump(jumplist[10001], JumpToCityMenu, 2)
		AddJump(jumplist[10001], CheckUI, BuildingUpgrade)
		AddJump(jumplist[10001], JumptoBtn, BuildingUpgrade, "Container/bg_frane/btn_upgrade")

		jumplist[10002] = {}
		AddJump(jumplist[10002], CheckWorldMap, false)
		AddJump(jumplist[10002], JumpToBarrack)
		AddJump(jumplist[10002], JumpToCityMenu, 6)
		AddJump(jumplist[10002], JumpToBarrackTrain)

		jumplist[10003] = {}
		AddJump(jumplist[10003], CheckWorldMap, false)
		AddJump(jumplist[10003], JumpToBuild, 6)
		AddJump(jumplist[10003], JumpToCityMenu, 7)

		jumplist[10004] = {}
		AddJump(jumplist[10004], JumptoBtn, MainCityUI, "Container/TopBar/bg_touxiang")
		AddJump(jumplist[10004], CheckUI, MainInformation)
		AddJump(jumplist[10004], function()
			for i = 1, 9 do
				if CheckGOActive(MainInformation, string.format("Container/bg_franenew/mid/equip0%d/redpoint", i)) or
				   CheckGOActive(MainInformation, string.format("Container/bg_franenew/mid/equip0%d/effect", i)) then
					SaveTemp(i)
					guideJumpFunc()
					return
				end
			end
			SaveTemp(0)
			guideJumpFunc()
		end)
		AddJump(jumplist[10004], function()
			local index = GetTemp()
			JumptoBtn(MainInformation, string.format("Container/bg_franenew/mid/equip0%d", index == 0 and 1 or index))
		end)
		AddJump(jumplist[10004], CheckUI, EquipSelectNew)
		AddJump(jumplist[10004], Speak, "icon_guide_male", "tutorial_equip_1;tutorial_equip_2")
		AddJump(jumplist[10004], function()
			if CheckGOActive(EquipSelectNew, "Container/bg_frane/right/button2/red") then
				JumptoBtn(EquipSelectNew, "Container/bg_frane/right/button2")
			elseif CheckGOActive(EquipSelectNew, "Container/bg_frane/right/button1/red") then
				JumptoBtn(EquipSelectNew, "Container/bg_frane/right/button1")
			else
				nowjumplist = {}
				guideJumpFunc()
			end
		end)
		

		jumplist[10005] = {}
		AddJump(jumplist[10005], JumptoBtn, MainCityUI, "Container/TopBar/bg_touxiang")
		AddJump(jumplist[10005], CheckUI, MainInformation)
		AddJump(jumplist[10005], JumptoBtn, MainInformation, "Container/page/info2")
		AddJump(jumplist[10005], CheckUI, MilitaryRank)
		AddJump(jumplist[10005], JumptoBtn, MilitaryRank, "Container/MilitaryRank/rankinfo/button")

		jumplist[10006] = {}
		AddJump(jumplist[10006], CheckWorldMap, false)
		AddJump(jumplist[10006], JumptoBtn, MainCityUI, "Container/bg_zhankai/Panel_left/bg_left/bg_rune/btn_union")
		AddJump(jumplist[10006], CheckUI, Rune)
		AddJump(jumplist[10006], JumptoBtn, Rune, "Container/bg_frane/right/content3/info/button1")
		AddJump(jumplist[10006], CheckUI, Runedraw)
		AddJump(jumplist[10006], function()
			if CheckGOActive(Runedraw, "Container/bg_frane/bg/button/button1/red") then
				JumptoBtn(Runedraw, "Container/bg_frane/bg/button/button1")
			end
			if CheckGOActive(Runedraw, "Container/bg_frane/bg/button/button3/red") then
				JumptoBtn(Runedraw, "Container/bg_frane/bg/button/button3")
			end
		end)

		jumplist[10007] = {}
		AddJump(jumplist[10007], CheckWorldMap, false)
		AddJump(jumplist[10007], JumpToBarrack)
		AddJump(jumplist[10007], JumpToCityMenu, 27)
		AddJump(jumplist[10007], CheckUI, Barrack_SoldierEquip)
		AddJump(jumplist[10007], Speak, "icon_guide_male", "SoldierEquip_7")

		jumplist[10008] = {}
		AddJump(jumplist[10008], JumptoBtn, MainCityUI, "Container/TopBar/bg_touxiang")
		AddJump(jumplist[10008], CheckUI, MainInformation)
		AddJump(jumplist[10008], JumptoBtn, MainInformation, "Container/bg_franenew/bottom/button_right")

		jumplist[10101] = {}
		AddJump(jumplist[10101], JumpToMission)
		AddJump(jumplist[10101], CheckUI, MissionUI)
		AddJump(jumplist[10101], Speak, "icon_guide_male", "tutorial_59")
		AddJump(jumplist[10101], JumpToMissionTab, 2)

		jumplist[10102] = {}
		AddJump(jumplist[10102], JumpToMission)
		AddJump(jumplist[10102], CheckUI, MissionUI)
		AddJump(jumplist[10102], JumptoBtn, MissionUI, "Container/bg/mission list/page1")

		jumplist[10103] = {}
		AddJump(jumplist[10103], JumpToMission)
		AddJump(jumplist[10103], JumpToMissionTab, 3)

		jumplist[10104] = {}
		AddJump(jumplist[10104], CheckWorldMap, false)
		AddJump(jumplist[10104], JumptoBtn, MainCityUI, "Container/btn_battle")
		AddJump(jumplist[10104], CheckUI, SandSelect)
		AddJump(jumplist[10104], Speak, "icon_guide_male", "tutorial_135")

		jumplist[10105] = {}
		AddJump(jumplist[10105], JumptoBtn, MainCityUI, "Container/TopBar/bg_vip/bg_msg/num")
		--[[AddJump(jumplist[10105], CheckUI, VIP)
		AddJump(jumplist[10105], function()
			local btn = GetGameObject(VIP, "Container/bg_frane/bg_mid/Scroll View/OptGrid/VIPinfo (2)/bg_libao_bottom/btn_get")
			print(btn)
			if not IsNil(btn) then
				if btn:GetComponent("UISprite").spriteName == "btn_2" then
					JumptoBtn(VIP, "Container/bg_frane/bg_mid/Scroll View/OptGrid/VIPinfo (2)/bg_libao_bottom/btn_get")
				else
					nowjumplist = {}
					guideJumpFunc()
				end
			else
				nowjumplist = {}
				guideJumpFunc()
			end
		end)]]

		jumplist[10201] = {}
		AddJump(jumplist[10201], CheckWorldMap, false)
		AddJump(jumplist[10201], JumpToBuild, 7)
		AddJump(jumplist[10201], CheckUI, MilitarySchool)
		AddJump(jumplist[10201], function()
			if CheckGOActive(MilitarySchool, "Container/normal recruit/free/icon_red") then
				JumptoBtn(MilitarySchool, "Container/normal recruit/one btn")
			end
			if CheckGOActive(MilitarySchool, "Container/high-grade recruit/free/icon_red") then
				JumptoBtn(MilitarySchool, "Container/high-grade recruit/one btn")
			end
		end)

		jumplist[10202] = {}
		AddJump(jumplist[10202], JumpToHero)
		AddJump(jumplist[10202], CheckUI, HeroListNew)
		AddJump(jumplist[10202], JumpToChild, HeroListNew, "background widget/bg2/content 1/Scroll View/Grid", 1, "Icon")
		AddJump(jumplist[10202], CheckUI, HeroInfoNew)
		AddJump(jumplist[10202], Speak, "icon_guide_male", "tutorial_strong1")
		AddJump(jumplist[10202], JumptoBtn, HeroInfoNew, "Container/Right/Content 1/Level Up/Level Up Button")

		jumplist[10203] = {}
		AddJump(jumplist[10203], JumpToHero)
		AddJump(jumplist[10203], CheckUI, HeroListNew)
		AddJump(jumplist[10203], JumpToChild, HeroListNew, "background widget/bg2/content 1/Scroll View/Grid", 1, "Icon")
		AddJump(jumplist[10203], CheckUI, HeroInfoNew)
		AddJump(jumplist[10203], JumptoBtn, HeroInfoNew, "Container/Right/Content 1/Grade Up/1/Icon")
		AddJump(jumplist[10203], CheckUI, BadgeInfoNew_1)
		AddJump(jumplist[10203], Speak, "icon_guide_male", "tutorial_strong2")

		jumplist[10204] = {}
		AddJump(jumplist[10204], JumpToHero)
		AddJump(jumplist[10204], CheckUI, HeroListNew)
		AddJump(jumplist[10204], JumpToChild, HeroListNew, "background widget/bg2/content 1/Scroll View/Grid", 1, "Icon")
		AddJump(jumplist[10204], CheckUI, HeroInfoNew)
		AddJump(jumplist[10204], JumptoBtn, HeroInfoNew, "Container/Left/Passive Skills/Grid/1/Frame")
		AddJump(jumplist[10204], CheckUI, HeroSkillLevelup)
		AddJump(jumplist[10204], JumptoBtn, HeroSkillLevelup, "Container/bg/btn_levelup")

		jumplist[10205] = {}
		AddJump(jumplist[10205], JumpToHero)
		AddJump(jumplist[10205], CheckUI, HeroListNew)
		AddJump(jumplist[10205], JumpToChild, HeroListNew, "background widget/bg2/content 1/Scroll View/Grid", 1, "Icon")
		AddJump(jumplist[10205], JumptoBtn, HeroListNew, "background widget/bg2/page2")
		AddJump(jumplist[10205], Speak, "icon_guide_male", "tutorial_139")
		AddJump(jumplist[10205], CheckUI, HeroInfoNew)
		AddJump(jumplist[10205], JumptoBtn, HeroInfoNew, "Container/Right/Content 2/Top/Star Up Button")

		jumplist[10301] = {}
		AddJump(jumplist[10301], CheckWorldMap, false)
		AddJump(jumplist[10301], JumpToBarrack)
		AddJump(jumplist[10301], JumpToCityMenu, 6)
		AddJump(jumplist[10301], JumpToBarrackTrain)

		jumplist[10302] = {}
		AddJump(jumplist[10302], CheckWorldMap, false)
		AddJump(jumplist[10302], JumpToBuild, 6)
		AddJump(jumplist[10302], JumpToCityMenu, 7)
		AddJump(jumplist[10302], CheckUI, Laboratory)
		AddJump(jumplist[10302], function()
			local tabs = {[1] = {i = 4005, t = 5, c = 4},
						 [2] = {i = 5006, t = 6, c = 4},
						 [3] = {i = 6006, t = 7, c = 4},
						 [4] = {i = 7006, t = 8, c = 4},
						 [5] = {i = 4011, t = 5, c = 7},
						 [6] = {i = 5012, t = 6, c = 7},
						 [7] = {i = 6012, t = 7, c = 7},
						 [8] = {i = 7012, t = 8, c = 7},
						 [9] = {i = 4015, t = 5, c = 10},
						 [10] = {i = 5016, t = 6, c = 10},
						 [11] = {i = 6016, t = 7, c = 10},
						 [12] = {i = 7016, t = 8, c = 10}}
			for i, v in ipairs(tabs) do
				if Laboratory.GetTech(v.i).Info.level == 0 then
					SaveTemp(v)
					guideJumpFunc()
					return
				end
			end
		end)
		AddJump(jumplist[10302], function()
			JumpToLaboratory(GetTemp().t)
		end)
		AddJump(jumplist[10302], function()
			JumpToLaboratoryMenu(GetTemp().c, 6)
		end)

		jumplist[10303] = {}
		AddJump(jumplist[10303], CheckWorldMap, false)
		AddJump(jumplist[10303], JumpToBarrack)
		AddJump(jumplist[10303], JumpToCityMenu, 27)
		AddJump(jumplist[10303], CheckUI, Barrack_SoldierEquip)
		AddJump(jumplist[10303], JumptoBtn, Barrack_SoldierEquip, "Container/bg_frane/right/upgrade/button")

		jumplist[10304] = {}
		AddJump(jumplist[10304], CheckWorldMap, false)
		AddJump(jumplist[10304], JumpToBuild, 4)
		AddJump(jumplist[10304], JumpToCityMenu, 2)

		jumplist[10305] = {}
		AddJump(jumplist[10305], JumptoBtn, MainCityUI, "Container/TopBar/bg_touxiang")
		AddJump(jumplist[10305], CheckUI, MainInformation)
		AddJump(jumplist[10305], JumptoBtn, MainInformation, "Container/page/info3")
		AddJump(jumplist[10305], CheckUI, SoldierLevel)
		AddJump(jumplist[10305], JumptoBtn, SoldierLevel, "Container/back/right/button2")

		jumplist[10306] = {}
		AddJump(jumplist[10306], CheckWorldMap, false)
		AddJump(jumplist[10306], function()
			if not maincity.HasBuildingByID(4) then
				UnitCounters.Show()
				nowjumplist = {}
			end
			guideJumpFunc()
		end)
		AddJump(jumplist[10306], JumpToBuild, 4)
		AddJump(jumplist[10306], JumpToCityMenu, 16)
		AddJump(jumplist[10306], JumptoBtn, Embattle, "Container/bg_frane/Embattle/btn_help")

		jumplist[10401] = {}
		AddJump(jumplist[10401], CheckWorldMap, true)
		AddJump(jumplist[10401], JumpToSearchBtn)
		AddJump(jumplist[10401], JumptoBtn, MapSearch, "Container/item widget/item bg3")
		AddJump(jumplist[10401], JumptoBtn, MapSearch, "Container/search btn")

		jumplist[10402] = {}
		AddJump(jumplist[10402], CheckWorldMap, false)
		AddJump(jumplist[10402], JumpToBuild, 11, nil, true)
		AddJump(jumplist[10402], JumpToCityMenu, 2)
		AddJump(jumplist[10402], CheckUI, BuildingUpgrade)
		AddJump(jumplist[10402], Speak, "icon_guide_male", "tutorial_strong3")
		AddJump(jumplist[10402], JumptoBtn, BuildingUpgrade, "Container/bg_frane/btn_upgrade")

		jumplist[10403] = {}
		AddJump(jumplist[10403], JumptoBtn, MainCityUI, "Container/bg_zhankai/Panel_left/bg_left/bg_bag/btn_bag")
		AddJump(jumplist[10403], CheckUI, SlgBag)
		AddJump(jumplist[10403], JumptoBtn, SlgBag, "Container/bg_frane/Container1/bg_left/btn_itemtype_4")

		jumplist[10404] = {}
		AddJump(jumplist[10404], JumpToMission)
		AddJump(jumplist[10404], CheckUI, MissionUI)
		AddJump(jumplist[10404], Speak, "icon_guide_male", "tutorial_59")
		AddJump(jumplist[10404], JumpToMissionTab, 2)

		jumplist[10405] = {}
		AddJump(jumplist[10405], JumptoBtn, MainCityUI, "Container/bg_activity/Grid/DailyActivity")

		jumplist[10406] = {}
		AddJump(jumplist[10406], JumpToUnion)
		AddJump(jumplist[10406], CheckUI, UnionInfo)
		AddJump(jumplist[10406], JumptoBtn, UnionInfo, "Container/bg2/content 1/function widget/building_btn")
		AddJump(jumplist[10406], CheckUI, UnionBuilding)
		AddJump(jumplist[10406], JumptoBtn, UnionBuilding, "Container/bg2/content 3/bg_mid/BuildingList/Grid/union_buildcommon3")
		AddJump(jumplist[10406], function()
			MapHelp.Open(1300, false, function() end, false, true)
			guideJumpFunc()
		end)

		jumplist[10407] = {}
		AddJump(jumplist[10407], JumptoBtn, MainCityUI, "Container/resourebar/bg_resoure (1)/icon")
		AddJump(jumplist[10407], CheckUI, CommonItemBag)
		AddJump(jumplist[10407], Speak, "icon_guide_male", "tutorial_strong4")

		jumplist[10408] = {}
		AddJump(jumplist[10408], JumptoBtn, MainCityUI, "Container/btn_buff")
		AddJump(jumplist[10408], CheckUI, BuffView)
		AddJump(jumplist[10408], MoveScrollView, BuffView, "BUFF/Container/bg_frane/Scroll View", Vector3(0, 1021, 0))
		AddJump(jumplist[10408], Speak, "icon_guide_male", "tutorial_strong5")
		AddJump(jumplist[10408], JumptoBtn, BuffView, "BUFF/Container/bg_frane/Scroll View/Grid/9110/bg_list/button")

		jumplist[10501] = {}
		AddJump(jumplist[10501], JumpToMission)
		AddJump(jumplist[10501], CheckUI, MissionUI)
		AddJump(jumplist[10501], Speak, "icon_guide_male", "tutorial_59")
		AddJump(jumplist[10501], JumpToMissionTab, 2)

		jumplist[10502] = {}
		AddJump(jumplist[10502], JumptoBtn, MainCityUI, "Container/bg_activity/Grid/DailyActivity")

		jumplist[10503] = {}
		AddJump(jumplist[10503], CheckWorldMap, false)
		AddJump(jumplist[10503], JumptoBtn, MainCityUI, "Container/btn_battle")
		AddJump(jumplist[10503], CheckUI, SandSelect)
		AddJump(jumplist[10503], Speak, "icon_guide_male", "tutorial_135")

		jumplist[10504] = {}
		AddJump(jumplist[10504], JumptoBtn, MainCityUI, "Container/btn_shop")
		AddJump(jumplist[10504], CheckUI, Goldstore)
		AddJump(jumplist[10504], JumptoBtn, Goldstore, "Container/Background/Sidebar/Container/Scroll View/Grid/11500")
		AddJump(jumplist[10504], CheckUI, Goldstore_template2)
		AddJump(jumplist[10504], WaitStep)
		AddJump(jumplist[10504], JumptoBtn, Goldstore_template2, "Container/Top Bar/3/text3")

		jumplist[10601] = {}
		AddJump(jumplist[10601], CheckWorldMap, true)
		AddJump(jumplist[10601], JumpToSearchBtn)
		AddJump(jumplist[10601], JumptoBtn, MapSearch, "Container/item widget/item bg1")
		AddJump(jumplist[10601], JumptoBtn, MapSearch, "Container/search btn")

		jumplist[10602] = {}
		AddJump(jumplist[10602], CheckWorldMap, true)
		AddJump(jumplist[10602], Speak, "icon_guide_male", "tutorial_strong6")
		AddJump(jumplist[10602], function()
			MapHelp.Open(500, false, function() end, false, true)
			guideJumpFunc()
		end)

		jumplist[10603] = {}
		AddJump(jumplist[10603], JumptoBtn, MainCityUI, "Container/bg_activity/Grid/RebelArmyWanted")

		jumplist[10604] = {}
		AddJump(jumplist[10604], CheckWorldMap, false)
		AddJump(jumplist[10604], JumptoBtn, MainCityUI, "Container/btn_battle")
		AddJump(jumplist[10604], CheckUI, SandSelect)
		AddJump(jumplist[10604], Speak, "icon_guide_male", "tutorial_135")

		jumplist[10605] = {}
		AddJump(jumplist[10605], CheckWorldMap, false)
		AddJump(jumplist[10605], JumpToBuild, 8)
		AddJump(jumplist[10605], CheckUI, Entrance)
		AddJump(jumplist[10605], Speak, "icon_guide_male", "bestrong_mobaguide")
		AddJump(jumplist[10605], function()
			MapHelp.Open(2400, false, function() end, false, true)
			guideJumpFunc()
		end)

		jumplist[10606] = {}
		AddJump(jumplist[10606], CheckWorldMap, false)
		AddJump(jumplist[10606], JumpToBuild, 9)
		AddJump(jumplist[10606], CheckUI, BattleRank)
		AddJump(jumplist[10606], Speak, "icon_guide_male", "bestrong_battlerankguide")
		AddJump(jumplist[10606], function()
			Arena_Help.Show(GOV_Help.HelpModeType.ArenaHelpDesc)
			guideJumpFunc()
		end)

		jumplist[10607] = {}
		AddJump(jumplist[10607], CheckWorldMap, false)
		AddJump(jumplist[10607], JumpToBuild, 15)
		AddJump(jumplist[10607], JumpToCityMenu, 26)
		AddJump(jumplist[10607], CheckUI, Climb)
		AddJump(jumplist[10607], function()
			GOV_Help.Show(GOV_Help.HelpModeType.CLIMB)
			guideJumpFunc()
		end)

		jumplist[10608] = {}
		AddJump(jumplist[10608], CheckWorldMap, false)
		AddJump(jumplist[10608], JumptoBtn, MainCityUI, "Container/bg_activityleft/Grid/btn_citywar")
		AddJump(jumplist[10608], CheckUI, CityMap)
		AddJump(jumplist[10608], Speak, "icon_guide_male", "bestrong_citywarguide")
		AddJump(jumplist[10608], function()
			MapHelp.Open(2600, false, function() end, false, true)
			guideJumpFunc()
		end)

		jumplist[10701] = {}
		AddJump(jumplist[10701], CheckWorldMap, true)
		AddJump(jumplist[10701], function()
			MapHelp.Open(403, false, function() end, false, true)
			guideJumpFunc()
		end)
		
		jumplist[10702] = {}
		AddJump(jumplist[10702], CheckWorldMap, true)
		AddJump(jumplist[10702], JumpToWarZone)
		AddJump(jumplist[10702], CheckUI, WarZoneMap)
		AddJump(jumplist[10702], JumpToWarZoneCenter)
		AddJump(jumplist[10702], function()
			GOV_Help.Show(GOV_Help.HelpModeType.STRONGHOLDMODE)
			guideJumpFunc()
		end)

		jumplist[10703] = {}
		AddJump(jumplist[10703], CheckWorldMap, true)
		AddJump(jumplist[10703], JumpToWarZone)
		AddJump(jumplist[10703], CheckUI, WarZoneMap)
		AddJump(jumplist[10703], JumpToWarZoneCenter)
		AddJump(jumplist[10703], function()
			GOV_Help.Show(GOV_Help.HelpModeType.GOVMODE)
			guideJumpFunc()
		end)

		jumplist[10704] = {}
		AddJump(jumplist[10704], CheckWorldMap, true)
		AddJump(jumplist[10704], JumpToWarZone)
		AddJump(jumplist[10704], CheckUI, WarZoneMap)
		AddJump(jumplist[10704], JumpToWarZoneCenter)
		AddJump(jumplist[10704], function()
			GOV_Help.Show(GOV_Help.HelpModeType.FORTRESS)
			guideJumpFunc()
		end)

		jumplist[11000] = {}
		AddJump(jumplist[11000], Speak, "icon_guide", "guide_citywar_1;guide_citywar_2")
		AddJump(jumplist[11000], JumptoBtn, MainCityUI, "Container/bg_activityleft/Grid/btn_citywar", true)
		AddJump(jumplist[11000], CheckUI, CityMap)
		AddJump(jumplist[11000], function()
			UnityEngine.PlayerPrefs.SetInt("city" .. MainData.GetCharId(), 1)
			UnityEngine.PlayerPrefs.Save()
			guideJumpFunc()
		end)
		AddJump(jumplist[11000], Speak, "icon_guide", "guide_citywar_3;guide_citywar_4;guide_citywar_5")
		AddJump(jumplist[11000], JumptoBtn, CityMap, "Container/background/mid/level_list/city (1)/icon")
		AddJump(jumplist[11000], JumptoBtn, CityMap, "Container/CityTips/bg/btn_battle")
		AddJump(jumplist[11000], CheckUI, WorldMap)
		AddJump(jumplist[11000], WaitStep)
		AddJump(jumplist[11000], WaitStep)
		AddJump(jumplist[11000], WaitStep)
		AddJump(jumplist[11000], WaitStep)
		AddJump(jumplist[11000], Speak, "icon_guide", "guide_citywar_6")
		AddJump(jumplist[11000], function()
			GrowGuide.SetShowPos(0, 0)
			local menu = WorldMap.transform:Find("Container/map_bg")
			GrowGuide.Show(menu, function()
				WorldMap.ShowTileInfo(59, 323)
				guideJumpFunc()
			end, true)
		end)
		AddJump(jumplist[11000], CheckUI, TileInfo)
		AddJump(jumplist[11000], SetGrowMask, 135, -34, 474, 145)
		AddJump(jumplist[11000], Speak, "icon_guide", "guide_citywar_7;guide_citywar_8")
		AddJump(jumplist[11000], CloseGrowMask)
		AddJump(jumplist[11000], JumptoBtn, TileInfo, "CityBuilding/bg_info/btn_2/btn_1", true)

		jumplist[99999] = {}
		AddJump(jumplist[99999], function()
			account.Show()
			guideJumpFunc()
		end)
		AddJump(jumplist[99999], CheckUI, account)
		AddJump(jumplist[99999], Speak, "icon_guide_male", "tutorial_account1;tutorial_account2;tutorial_account3")
		AddJump(jumplist[99999], JumptoBtn, account, "account/bg_frane/btn_relate", true)
		AddJump(jumplist[99999], JumptoBtn, account, "relateaccount/account/bg_frane/Scroll View/Grid/5", true)
	end
end

local function AddDepth(go, add)
	local widgets = go:GetComponentsInChildren(typeof(UIWidget))
	for i = 0, widgets.Length - 1 do
		widgets[i].depth = widgets[i].depth + add
	end
end

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	local param = GetParameter(go)
	if param ~= nil then
		local param = param:split("_")
		if param[1] == "item" then
			local itemdata = TableMgr:GetItemData(tonumber(param[2]))
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
			else
			    if itemTipTarget == go then
			        Tooltip.HideItemTip()
			    else
			        itemTipTarget = go
			        Tooltip.ShowItemTip({name = TextUtil.GetItemName(itemdata), text = TextUtil.GetItemDescription(itemdata)})
			    end
			end
		else
			local itemdata = TableMgr:GetHeroData(tonumber(param[2]))
			if not Tooltip.IsItemTipActive() then
			    itemTipTarget = go
				Tooltip.ShowItemTip({name = TextMgr:GetText(itemdata.nameLabel), text = TextMgr:GetText(itemdata.description)})
		    else
		        if itemTipTarget == go then
		            Tooltip.HideItemTip()
		        else
		            itemTipTarget = go
		            Tooltip.ShowItemTip({name = TextMgr:GetText(itemdata.nameLabel), text = TextMgr:GetText(itemdata.description)})
		        end
		    end
		end
	else
		Tooltip.HideItemTip()
	end
end

function Hide()
    Global.CloseUI(_M)
end

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
end

function OnUICameraDragStart(go, delta)
    --Tooltip.HideItemTip()
end

function GetRewardDataCount(data)
    local itemTable = string.split(data, ":")
    local itemId, itemCount = tonumber(itemTable[1]), tonumber(itemTable[2])
    local itemData = TableMgr:GetItemData(itemId)

    return itemData, itemCount
end

local isInGuide = false

function IsInGuide()
	isInGuide = nowjumplist ~= nil and (#nowjumplist > 0) or false
	return isInGuide
end

guideJumpFunc = function(isbrake)
	isInGuide = true
	if isbrake then
		isInGuide = false
		nowjumplist = {}
	end
	if nowjumplist ~= nil and #nowjumplist > 0 and (isbrake == nil or isbrake == false) then
		table.remove(nowjumplist,1)()
	else
		isInGuide = false
	end
end

function BrakeGuide()
	isInGuide = false
	nowjumplist = {}
	GrowGuide.Hide()
	Story.Hide()
end

function LoadUI()
	local catchedMission = {}
    MissionListData.Sort2()
    local missionMsgList = MissionListData.GetData()
    local missionIndex = 1
    local storylist = {}
    for _, v in ipairs(missionMsgList) do
    	local missionData = TableMgr:GetMissionData(v.id)
        if missionData.type == ClientMsg_pb.UserMissionType_Chapter then
        	local story = {}
        	story.mission = v
        	story.data = missionData
        	table.insert(storylist, story)
        	table.insert(catchedMission, v.id)
        end
    end
    table.sort(storylist, function(a,b)
    	if a.data.ChapOrder ~= nil and b.data.ChapOrder ~= nil then
    		return a.data.ChapOrder < b.data.ChapOrder
    	end
    	return a.mission.id < b.mission.id
	end)
    for _, v in ipairs(storylist) do
        local missionData = v.data
        if missionData.type == ClientMsg_pb.UserMissionType_Chapter then
			local completed = v.mission.status > 1
			if completed then
				v.mission.value = missionData.number
			end
            if not missionData.chest then
                local mission = _ui.missionList[missionIndex]
				if mission ~= nil then
					mission.transform.gameObject:SetActive(true)
	                mission.star.gameObject:SetActive(completed)
					mission.titleLabel.text = Format(TextUtil.GetMissionTitle(missionData), v.mission.value, missionData.number)
					mission.titleLabel.color = v.mission.rewarded and (Color.white * 0.7) or Color.white
	                if missionData.contra == 1 then
	                	mission.expbar.value = (v.mission.value >= missionData.number and 1 or 0) / 1
						mission.expnum.text = "" .. (v.mission.value >= missionData.number and 1 or 0) .. "/" .. 1
					elseif missionData.contra == 3 then
						mission.expbar.value = (completed and 1 or 0) / 1
						mission.expnum.text = "" .. (completed and 1 or 0) .. "/" .. 1
	                else
	                	mission.expbar.value = v.mission.value / missionData.number
	                	mission.expnum.text = "" .. v.mission.value .. "/" .. missionData.number
	                end

	                local reward = mission.reward
	                --[[ local itemData, itemCount = GetRewardDataCount(missionData.item)
					if itemData.id == 11 then
	                	mission.rewardnum.text = itemCount
	                	SetParameter(mission.Texture.gameObject, "item_" .. 11)
	                else
	                	mission.rewardnum.text = 0
					end ]]
					SetClickCallback(mission.Texture.gameObject, function()
						ShowMissionReward(missionData.item, TextMgr:GetText("mission_reward_title"))
					end)
					
					mission.getButton.gameObject:SetActive(completed and not v.mission.rewarded)
					mission.complete:SetActive(completed and v.mission.rewarded)
	                --[[ if completed then
	                    UIUtil.SetBtnEnable(mission.getButton ,"btn_2", "btn_4", not v.mission.rewarded)
	                    if v.mission.rewarded then
	                        mission.getLabel.text = TextMgr:GetText(Text.SectionRewards_ui5)
	                    else
	                        mission.getLabel.text = TextMgr:GetText(Text.mail_ui12)
	                    end
	                end ]]
	                mission.goButton.gameObject:SetActive(not completed)
	                SetClickCallback(mission.getButton.gameObject, function()
	                    if completed and not v.mission.rewarded then
	                        local req = ClientMsg_pb.MsgUserMissionRewardRequest()
	                        req.taskid = v.mission.id
	                        Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserMissionRewardRequest, req, ClientMsg_pb.MsgUserMissionRewardResponse, function(msg)
	                            if msg.code ~= ReturnCode_pb.Code_OK then
	                                Global.FloatError(msg.code)
	                            else
	                                AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
									if tonumber(msg.taskid) == 1815 then
										GUIMgr:SendDataReport("efun", "build_general")
									end
									if tonumber(msg.taskid) == 1803 then
										Event.Resume(12)
										--Event.Check(13)
									end
									if tonumber(msg.taskid) == 1804 then
										Event.Resume(14)
									end
									if tonumber(msg.taskid) == 1821 then
										Event.Resume(15)
										Event.Resume(16)
									end
									if tonumber(msg.taskid) == 1822 then
										Event.Resume(17)
									end
									if tonumber(msg.taskid) == 1823 then
										--Event.Resume(18)
										Event.Resume(19)
									end
									if tonumber(msg.taskid) == 1824 then
										Event.Resume(20)
									end
									if tonumber(msg.taskid) == 1841 then
										Event.Resume(21)
									end
									if tonumber(msg.taskid) == 1842 then
										Event.Resume(22)
										Event.Resume(23)
									end
									if tonumber(msg.taskid) == 1843 then
										--Event.Resume(25)
										Event.Resume(26)
									end
									if tonumber(msg.taskid) == 1844 then
										Event.Resume(27)
									end
									if tonumber(msg.taskid) == 1845 then
										Event.Resume(28)
									end
									if tonumber(msg.taskid) == 1861 then
										Event.Resume(29)
									end
									if tonumber(msg.taskid) == 1862 then
										Event.Resume(31)
										Event.Check(33)
									end
									if tonumber(msg.taskid) == 1863 then
										Event.Resume(34)
										Event.Resume(35)
									end
									if tonumber(msg.taskid) == 1864 then
										Event.Resume(36)
										Event.Resume(37)
									end
									if tonumber(msg.taskid) == 1865 then
										Event.Resume(38)
									end
									if tonumber(msg.taskid) == 1881 then
										Event.Resume(39)
									end
									if tonumber(msg.taskid) == 1882 then
										Event.Resume(41)
									end
									if tonumber(msg.taskid) == 1883 then
										Event.Resume(42)
									end
									if tonumber(msg.taskid) == 1884 then
										Event.Resume(43)
									end
									if tonumber(msg.taskid) == 1885 then
										Event.Resume(44)
									end
	                                GUIMgr:SendDataReport("reward", "UserMissionReward:" .. msg.taskid, "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))
	                                MainCityUI.UpdateRewardData(msg.fresh)
	                                Global.ShowReward(msg.reward)
	                                MissionListData.SetRewarded(msg.taskid)
	                                MissionListData.UpdateList(msg.quest)
	                                -- send data report-----------
	                                GUIMgr:SendDataReport("umission", "" .. msg.taskid, "completed", "0")
	                                ------------------------------
	                            end
	                        end, true)
	                    end
	                end)
					if not completed then
						if v.mission.id >= 1993 and v.mission.id <= 1995 then
							mission.goButton.gameObject:SetActive(false)
						end
	                    SetClickCallback(mission.goButton.gameObject, function()
	                        Hide()
	                        nowjumplist = {}
	                        if jumplist[v.mission.id] ~= nil then
		                        for iii, vvv in ipairs(jumplist[v.mission.id]) do
		                        	table.insert(nowjumplist, vvv)
		                        end
								guideJumpFunc()
							else
								local missionJumpFunc = MissionUI.GetMissionJumpFunction(v.mission, missionData)
								if missionJumpFunc ~= nil then
									local conditionType = missionData.conditionType
									print(string.format("任务跳转,表格Id:%d, 条件类型:%d", missionData.id, conditionType))
									missionJumpFunc()
								end
		                    end
	                    end)
	                end
	                missionIndex = missionIndex + 1
	            end
            else
                if completed then
	                _ui.chestSprite.spriteName = "btn_2"
	                SetClickCallback(_ui.chestButton.gameObject, function()
	                	if completed and not v.mission.rewarded then
	                		MissionListData.RemoveListener(LoadUI)
		                    local req = ClientMsg_pb.MsgUserMissionRewardRequest();
		                    req.taskid = v.mission.id
		                    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgUserMissionRewardRequest, req, ClientMsg_pb.MsgUserMissionRewardResponse, function(msg)
		                        if msg.code ~= ReturnCode_pb.Code_OK then
		                            Global.FloatError(msg.code)
								else
									
		                            AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
		                            GUIMgr:SendDataReport("reward", "UserMissionReward:" .. msg.taskid, "" .. MoneyListData.ComputeDiamond(msg.fresh.money.money))
		                            MainCityUI.UpdateRewardData(msg.fresh)
		                            --[[ ItemListShowNew.SetTittle(TextMgr:GetText("ui_chapmiss_complete"))
									ItemListShowNew.SetItemShow(msg)
									GUIMgr:CreateMenu("ItemListShowNew" , false) ]]
		                            MissionListData.SetRewarded(msg.taskid)
		                            MissionListData.UpdateList(msg.quest)
		                            -- send data report-----------
									GUIMgr:SendDataReport("umission", "" .. msg.taskid, "completed", "0")
									if chapterid <= 5 then
										GUIMgr:SendDataReport("efun", "chapter" .. chapterid)
									end
		                            ------------------------------
		                            for _, x in ipairs(catchedMission) do
		                            	MissionListData.RemoveMission(x)
									end
									MainCityUI.CheckRecommendedMission()
									Hide()
									if chapterid == 6 then
										Tutorial.FinishModule(99999)
									end
									if chapterid == 1 then
										StoryPicture.Show(4, function()
											Story.Show(100 + chapterid, function()
												ChapComplete.Show(missionData, chapterid, function()
													local cid = MainCityUI.GetCurStoryChap()
													if cid > chapterid then
														ChapterPicture.Show(chapterid + 1, function()
															Show(cid)
														end)
													end
												end)
											end)
										end)
									elseif chapterid == 4 then
										chaterchange = true
										Story.Show(100 + chapterid, function()
											ChapComplete.Show(missionData, chapterid, function()
												local cid = MainCityUI.GetCurStoryChap()
												if cid > chapterid then
													ChapterPicture.Show(chapterid + 1, function()
														Show(cid)
													end)
												end
											end)
										end)
									elseif chapterid == 5 then
										StoryPicture.Show(5, function()
											Story.Show(100 + chapterid, function()
												ChapComplete.Show(missionData, chapterid, function()
													local cid = MainCityUI.GetCurStoryChap()
													if cid > chapterid then
														ChapterPicture.Show(chapterid + 1, function()
															Show(cid)
														end)
													end
												end)
											end)
										end)
									else
										Story.Show(100 + chapterid, function()
											ChapComplete.Show(missionData, chapterid, function()
												local cid = MainCityUI.GetCurStoryChap()
												if cid > chapterid then
													ChapterPicture.Show(chapterid + 1, function()
														Show(cid)
													end)
												end
											end)
										end)
									end
		                        end
		                    end, true)
		                end
	                end)
	            else
	            	_ui.chestSprite.spriteName = "btn_4"
	            	SetClickCallback(_ui.chestButton.gameObject, nil)
	            end
                _ui.titleLabel.text = TextUtil.GetMissionTitle(missionData)
                
                while _ui.chapterRewardRoot.transform.childCount > 0 do
					GameObject.DestroyImmediate(_ui.chapterRewardRoot.transform:GetChild(0).gameObject)
				end
                for vv in string.gsplit(missionData.item, ";") do
                	local itemTable = string.split(vv, ":")
			        local itemId, itemCount = tonumber(itemTable[1]), tonumber(itemTable[2])
			        local itemdata = TableMgr:GetItemData(itemId)
			        local item = NGUITools.AddChild(_ui.chapterRewardRoot.gameObject, _ui.item.gameObject).transform
					item.localScale = Vector3(1.2,1.2,1)
					local reward = {}
					UIUtil.LoadItemObject(reward, item)
					UIUtil.LoadItem(reward, itemdata, itemCount)
					SetParameter(item.gameObject, "item_" .. itemId)
                end
                for vv in string.gsplit(missionData.hero, ";") do
                	local heroTable = string.split(vv, ":")
                	local heroId, heroCount = tonumber(heroTable[1]), tonumber(heroTable[2])
                	if heroId ~= nil then
	                	local heroData = TableMgr:GetHeroData(heroId)
						local hero = NGUITools.AddChild(_ui.chapterRewardRoot.gameObject, _ui.hero.gameObject).transform
						hero.localScale = Vector3(0.72, 0.72, 1)
						hero:Find("level text").gameObject:SetActive(false)
						hero:Find("name text").gameObject:SetActive(false)
						hero:Find("bg_skill").gameObject:SetActive(false)
						hero:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
						hero:Find("head icon/outline"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
						local star = hero:Find("star"):GetComponent("UISprite")
						if star ~= nil then
					        star.width = 1 * star.height
					    end
						SetParameter(hero:Find("head icon").gameObject, "hero_" .. heroId)
					end
                end
                _ui.chapterRewardRoot:Reposition()
				_ui.chapterinfo.text = Format(TextMgr:GetText("ui_chapmiss_proceed"), chapterid, 13)
				SetClickCallback(_ui.chapterinfo.gameObject, function()
					ChapComplete.Show(missionData, chapterid)
				end)
            end
        end
	end
	for i = missionIndex, 5 do
		_ui.missionList[i].transform.gameObject:SetActive(false)
	end
    _ui.missionGrid.repositionNow = true
    
	local story = TableMgr:GetStoryById(chapterid)
	if story ~= nil then
		_ui.leftTexture.mainTexture = ResourceLibrary:GetIcon("ActivityBanner/", story.Id1)
		_ui.leftTextLabel.text = TextMgr:GetText(story.Id2)
	end
end

function Awake()
    _ui = {}
    local closeButton = transform:Find("Container/bg_frane/bg_top/btn_close")
    SetClickCallback(closeButton.gameObject, Hide)
    SetClickCallback(transform:Find("mask").gameObject, Hide)
    SetClickCallback(transform:Find("Container").gameObject, Hide)
    
    _ui.missionPrefab = ResourceLibrary.GetUIPrefab("ActivityStage/ActivityGrowInfo")
    _ui.missionScrollView = transform:Find("Container/bg_frane/bg_right/Scroll View"):GetComponent("UIScrollView")
    _ui.missionGrid = transform:Find("Container/bg_frane/bg_right/Scroll View/Grid"):GetComponent("UIGrid")
    --_ui.titleLabel = transform:Find("Container/bg_frane/bg_right/title/title_text"):GetComponent("UILabel")
    --_ui.descriptionLabel = transform:Find("Container/bg_frane/bg_right/title/title_bg/text_desc"):GetComponent("UILabel")
    _ui.titleLabel = transform:Find("Container/bg_frane/bg_top/title_left/Label"):GetComponent("UILabel")
    
    _ui.item = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	_ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
	_ui.rewardshow = ResourceLibrary.GetUIPrefab("ActivityStage/GrowRewards")
	
	local num_item = _ui.item.transform:Find("have"):GetComponent("UILabel")
	local num_hero = _ui.hero.transform:Find("num"):GetComponent("UILabel")
	num_hero.trueTypeFont = num_item.trueTypeFont
	num_hero.fontSize = num_item.fontSize
	num_hero.applyGradient = num_item.applyGradient
	num_hero.gradientTop = num_item.gradientTop
	num_hero.gradientBottom = num_item.gradientBottom
	num_hero.spacingX = num_item.spacingX
	num_hero.transform.localScale = Vector3(1.6, 1.6, 1)
	num_hero.transform.localPosition = Vector3(50, -46, 0)
	
	_ui.chapterRewardRoot = transform:Find("Container/bg_frane/bg_right/list_reward"):GetComponent("UIGrid")

    local missionList = {}
    for i = 1, 5 do
        local mission = {}
        local missionTransform = _ui.missionGrid:GetChild(i - 1)
        mission.transform = missionTransform
        mission.star = missionTransform:Find("bg_list/bg_star/icon_star")
        local reward = {}
        mission.rewardnum = missionTransform:Find("bg_list/list_reward/Texture/Label"):GetComponent("UILabel")
        mission.titleLabel = missionTransform:Find("bg_list/txt_mission"):GetComponent("UILabel")
        mission.getButton = missionTransform:Find("bg_list/btn_get"):GetComponent("UIButton")
        mission.getLabel = missionTransform:Find("bg_list/btn_get/text"):GetComponent("UILabel")
        mission.goButton = missionTransform:Find("bg_list/btn_go"):GetComponent("UIButton")
        mission.expbar = missionTransform:Find("exp bar"):GetComponent("UISlider")
        mission.expnum = missionTransform:Find("exp bar/num"):GetComponent("UILabel")
		mission.Texture = missionTransform:Find("bg_list/list_reward/Texture").gameObject
		mission.complete = missionTransform:Find("bg_list/complete").gameObject
        missionList[i] = mission
    end
    _ui.missionList = missionList

    local starList = {}
    for i = 1, 5 do
        starList[i] = transform:Find(string.format("Container/bg_frane/bg_right/bottom_bg/bg_star/bg_star1 (%d)/icon_star", i))
    end
    _ui.starList = starList

    _ui.chestSprite = transform:Find("Container/bg_frane/bg_right/icon_chest"):GetComponent("UISprite")
    _ui.chestButton = transform:Find("Container/bg_frane/bg_right/icon_chest"):GetComponent("UIButton")
    _ui.chestButton.enabled = false
    
    _ui.leftTexture = transform:Find("Container/bg_frane/bg_right/title/Texture"):GetComponent("UITexture")
    _ui.leftTexture.gameObject:SetActive(true)
    _ui.leftTextLabel = transform:Find("Container/bg_frane/bg_right/title/text_desc"):GetComponent("UILabel")
    _ui.chapterinfo = transform:Find("Container/bg_frane/bg_right/bottom_bg (1)/Label"):GetComponent("UILabel")
    MissionListData.AddListener(LoadUI)
    AddDelegate(UICamera, "onPress", OnUICameraPress)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
    
    LoadUI()
end

function Close()
    MissionListData.RemoveListener(LoadUI)
    RemoveDelegate(UICamera, "onPress", OnUICameraPress)
    RemoveDelegate(UICamera, "onDragStart", OnUICameraDragStart)
	Tooltip.HideItemTip()
	if chapterid == 5 and chaterchange then
		FunctionListData.IsFunctionUnlocked(122, function(isactive)
			if isactive then
				NewActivityBanner.Show()
			end
		end)
		chaterchange = false
	end
	_ui = nil
end

function Show(chapter)
	chapterid = chapter
	if CheckStory(chapter) then
		Story.Show(chapter, function()
			Show(chapter)
		end)
	else
		MainCityUI.Shousuo()
		Global.OpenUI(_M)
		MissionListData.RequestDataByType(200)
	end
end

function CheckStory(chapter)
	if chapter > 9 then
		ConfigData.SetStoryConfig(chapter)
		MainCityUI.HasReadStory()
	end
	return chapter > ConfigData.GetStoryConfig()
end

function ExtraGuide(openCondition)
	openCondition = tonumber(openCondition)
	nowjumplist = {}
	if jumplist[openCondition] ~= nil then
		for i, v in ipairs(jumplist[openCondition]) do
			table.insert(nowjumplist, v)
		end
		guideJumpFunc()
	end
end

ShowMissionReward = function(reward, title)
	local showgo = NGUITools.AddChild(GUIMgr.UIRoot.gameObject, _ui.rewardshow)
	local showtrans = showgo.transform
	local _show = {}
	_show.bg = showtrans:Find("Container")
	_show.title = showtrans:Find("Container/bg_frane/bg_top/title"):GetComponent("UILabel")
	_show.listGrid = showtrans:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	_show.getButton = showtrans:Find("Container/bg_frane/button"):GetComponent("UIButton")
	_show.getLabel = showtrans:Find("Container/bg_frane/button/Label"):GetComponent("UILabel")
	_show.growHint = showtrans:Find("Container/bg_frane/bg_hint").gameObject
	_show.dailyHint = showtrans:Find("Container/bg_frane/bg_dailymission").gameObject
	_show.dailyHintLabel = showtrans:Find("Container/bg_frane/bg_dailymission/text"):GetComponent("UILabel")
	_show.dailyHintLabel.text = ""
	_show.title.transform:GetComponent("LocalizeEx").enabled = false
	_show.title.text = title
	local rewards = reward:split(";")
	for i, v in ipairs(rewards) do
		local item = v:split(":")
		local itemId = tonumber(item[1])
		local itemCount = tonumber(item[2])
		local itemData = TableMgr:GetItemData(itemId)

		local itemTransform = NGUITools.AddChild(_show.listGrid.gameObject, _ui.item).transform
		local reward = {}
        UIUtil.LoadItemObject(reward, itemTransform)
		UIUtil.LoadItem(reward, itemData, itemCount)
		SetParameter(itemTransform.gameObject, "item_" .. itemId)
	end
	_show.listGrid:Reposition()
	SetClickCallback(_show.bg.gameObject, function()
		GameObject.Destroy(showgo)
		_show = nil
	end)
	SetClickCallback(_show.getButton.gameObject, function()
		GameObject.Destroy(showgo)
		_show = nil
	end)
	showgo:SetActive(true)
	GUIMgr:BringForward(showgo)
end

InitJumpList()

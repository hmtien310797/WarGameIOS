class "BuildTransition"
{	
}

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local SetParameter = UIUtil.SetParameter
local GetParameter = UIUtil.GetParameter
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local Format = System.String.Format

TIMETYPE_BUILD = 1
TIMETYPE_TECH = 2
TIMETYPE_BARRACK = 3
TIMETYPE_BUFF = 4
TIMETYPE_HOSPITAL = 5

local MakeUpgradeMark, MakeHeroAppoint

function BuildTransition:CheckShowTime()
    if self.transition.timerList == nil then
        return nil, false
    end
    self.buildtime = nil
    self.techtime = nil
    for i, v in ipairs(self.transition.timerList) do
        if v.type == 1 then
            self.buildtime = v
            if v.time - self.curtime <= maincity.freetime() then
                return v, true
            end
        elseif v.type == 2 then
            self.techtime = v
            if v.time - self.curtime <= maincity.techFreeTime() then
                return v, true
            end
        end
    end
    return (#self.transition.timerList > 0 and self.transition.timerList[1] or nil), false
end

function BuildTransition:__init__(_building, showroottransform, colliderroottransform, buildinginforootsize)
    local transition = _building.transition
	if transition == nil then
		transition = {}
		transition.timerList = {}
	else
		return self
    end
    transition.building = _building
    transition.colliderroottransform = colliderroottransform:Find(_building.land.name)
    if transition.colliderroottransform == nil then
        local tgo = GameObject()
        tgo.name = _building.land.name
        transition.colliderroottransform = tgo.transform
        transition.colliderroottransform.transform:SetParent(colliderroottransform, false)
    end
    transition.buildinginforootsize = buildinginforootsize
	if _building.land == nil or	_building.land:Equals(nil) then
		return
	end
	transition.go =	_building.land.gameObject
	transition.h = _building.buildingData.offsetTop
	transition.w = _building.buildingData.offsetLevel
	transition.b = _building.buildingData.offsetbottom
	if transition.head == nil then
        transition.head	= ResourceLibrary.GetUIInstance("BuildingCommon/BuildingName"):GetComponent("UIWidget")
        transition.name	= transition.head.transform:Find("bg_title/text"):GetComponent("UILabel")
		transition.arrow = transition.head.transform:Find("arrow")
		transition.head.transform:Find("time").gameObject:SetActive(false)
	end
	if transition.level	== nil then
        transition.level = ResourceLibrary.GetUIInstance("BuildingCommon/BuildLevel"):GetComponent("UIWidget")
        transition.level_text = transition.level.transform:Find("text"):GetComponent("UILabel")
        transition.level_upgrade = transition.level.transform:Find("Sprite"):GetComponent("UISprite")
	end
	if transition.foot == nil then
        transition.foot	= ResourceLibrary.GetUIInstance("BuildingCommon/Buildingtime"):GetComponent("UIWidget")
        transition.foot_time = transition.foot.transform:Find("time/num"):GetComponent("UILabel")
        transition.foot_icon = transition.foot.transform:Find("time/icon"):GetComponent("UISprite")
	end
	if transition.free == nil then
        transition.free	= ResourceLibrary.GetUIInstance("BuildingCommon/freetexiao")
        transition.free_icon = transition.free.transform:Find("freetexiao/kejiquan")
        transition.free_collider = ResourceLibrary.GetUIInstance("BuildingCommon/BuildingBubbleCollider"):GetComponent("BoxCollider")
        transition.free_collider.enabled = false
        transition.free_collider.gameObject.name = "free"
        transition.free.name = "free"
    end
    if transition.help == nil then
        transition.help	= ResourceLibrary.GetUIInstance("BuildingCommon/lianmengyuanjian")
        transition.help_collider = ResourceLibrary.GetUIInstance("BuildingCommon/BuildingBubbleCollider"):GetComponent("BoxCollider")
        transition.help_collider.enabled = false
        transition.help_collider.gameObject.name = "help"
        transition.help_icon = transition.help.transform:Find("lianmengyuanjian/kapaidi")
        transition.help.name = "help"
    end
    if transition.hero == nil then
        transition.hero	= ResourceLibrary.GetUIInstance("BuildingCommon/jiangjunweiren")
        transition.hero_collider = ResourceLibrary.GetUIInstance("BuildingCommon/BuildingBubbleCollider"):GetComponent("BoxCollider")
        transition.hero_collider.enabled = false
        transition.hero_collider.gameObject.name = "hero"
        transition.hero_icon = transition.hero.transform:Find("jiangjunweiren/diadd")
        transition.hero.gameObject.name = "hero"
    end
    if transition.sfx_collider == nil then
        transition.sfx_collider = ResourceLibrary.GetUIInstance("BuildingCommon/BuildingBubbleCollider"):GetComponent("BoxCollider")
        transition.sfx_collider.enabled = false
        transition.sfx_collider.gameObject.name = "sfx"
    end
    transition.name.text = TextMgr:GetText(_building.buildingData.name)
    transition.free:SetActive(false)
    transition.help:SetActive(false)
    transition.foot.gameObject:SetActive(false)
    transition.head.gameObject:SetActive(false)
    transition.hero:SetActive(false)
    transition.showroottransform = showroottransform:Find(_building.land.name)
    if transition.showroottransform == nil then
        local tgo = GameObject()
        tgo.name = _building.land.name
        transition.showroottransform = tgo.transform
        transition.showroottransform.transform:SetParent(showroottransform, false)
    end
    transition.head.transform:SetParent(transition.showroottransform)
    transition.head.transform.localScale = Vector3.one * 0.7
    transition.free.transform:SetParent(transition.showroottransform, false)
    transition.help.transform:SetParent(transition.showroottransform, false)
	transition.level.transform:SetParent(transition.showroottransform, false)
    transition.foot.transform:SetParent(transition.showroottransform, false)
    transition.hero.transform:SetParent(transition.showroottransform, false)
    transition.free_collider.transform:SetParent(transition.colliderroottransform, false)
    transition.help_collider.transform:SetParent(transition.colliderroottransform, false)
    transition.hero_collider.transform:SetParent(transition.colliderroottransform, false)
    transition.sfx_collider.transform:SetParent(transition.colliderroottransform, false)
    transition.showroottransform.position = _building.land.transform.position
    transition.head.transform.localPosition	= Vector3(0, transition.h, 0)
    transition.head.transform.localEulerAngles = Vector3(30, 0, 0)
    transition.free.transform.localPosition	= Vector3(0, transition.h, 0)
    transition.free.transform.localEulerAngles = Vector3(45, 0, 0)
    transition.help.transform.localPosition = Vector3(0, transition.h, 0)
    transition.help.transform.localEulerAngles = Vector3(45, 0, 0)
    transition.hero.transform.localPosition	= Vector3(0, transition.h, 0)
    transition.hero.transform.localEulerAngles = Vector3(45, 0, 0)
    transition.level.transform.localPosition = Vector3(transition.w, 0, 0)
    transition.level.transform.localEulerAngles = Vector3(45, 0, 0)
    transition.foot.transform.localPosition	= Vector3(0, 0, transition.w / 2)
    transition.foot.transform.localEulerAngles = Vector3(45, 0, 0)
	
    _building.transition = transition
    self.transition = transition
    transition.transitionStruct = self
    _building.transitionStruct = self
    
    NGUITools.SetLayer(showroottransform.gameObject, 27)
end

function BuildTransition:SetSfx(path, colliderpath, clickcallback)
    local transition = self.transition
    if transition.buildsfx == nil or transition.buildsfx:Equals(nil) then
        transition.buildsfx = ResourceLibrary:GetEffectInstance(path)
        transition.buildsfx_icon = transition.buildsfx.transform:Find(colliderpath)
        transition.buildsfx.transform:SetParent(transition.building.land.transform, false)
        SetClickCallback(transition.sfx_collider.gameObject, clickcallback)
        transition.sfx_collider.enabled = true
    end
end

function BuildTransition:RemoveSfx()
    local transition = self.transition
    if transition.buildsfx ~= nil and not transition.buildsfx:Equals(nil) then
        GameObject.Destroy(transition.buildsfx)
        transition.buildsfx = nil
        transition.buildsfx_icon = nil
        transition.sfx_collider.enabled = false
    end
end

function BuildTransition:SetTime(timer)
    if self.transition.timerList == nil then
        self.transition.timerList = {}
    end
    local isnew = true
    for i, v in ipairs(self.transition.timerList) do
        if v.type == timer.type then
            isnew = false
            v.time = timer.time
        end
    end
    if isnew then
        table.insert( self.transition.timerList, timer )
    end
    table.sort( self.transition.timerList, function(a, b)
        return a. time < b.time
    end)
end

function BuildTransition:RemoveTime(type)
    if self.transition.timerList ~= nil then
        for i, v in ipairs(self.transition.timerList) do
            if v.type == type then
                table.remove( self.transition.timerList, i )
            end
        end
    end
end

function BuildTransition:UpdateTime()
    self.curtime = Serclimax.GameTime.GetSecTime()
    local showtime, isfree = self:CheckShowTime()

    local checkhospitalandhero = function()
        if self.transition.needshowhospital then
            if isfree or self.transition.help.activeInHierarchy == true then
                self.transition.building.hospitalUI:SetActive(false)
                self.transition.building.hospital_collider.gameObject:SetActive(false)
            else
                self.transition.building.hospitalUI:SetActive(true)
                self.transition.building.hospital_collider.gameObject:SetActive(true)
            end
        end
        if self.transition.needshowhero then
            if isfree or self.transition.help.activeInHierarchy == true or self.transition.needshowhospital or self.transition.seNeedShow or self.transition.IsNeedRepair then
                self.transition.hero:SetActive(false)
                self.transition.hero_collider.enabled = false
            else
                self.transition.hero:SetActive(true)
                self.transition.hero_collider.enabled = true
            end
        end
    end
    local checkOther = function()
        if self.transition.building.data.type == 10 then
            if not self.transition.help.activeInHierarchy and not self.transition.free.activeInHierarchy and JailInfoData.HasPrisoner() then
                if not self.transition.HasPrisoner then
                    self.transition.HasPrisoner = true
                    self.transition.jianyu = ResourceLibrary.GetUIInstance("BuildingCommon/jianyu")
                    self.transition.jianyu.transform:SetParent(self.transition.building.land)
                    self.transition.jianyu.transform.localPosition = Vector3(0,0,12)
                    self.transition.jianyu_collider = ResourceLibrary.GetUIInstance("BuildingCommon/BuildingBubbleCollider"):GetComponent("BoxCollider")
                    self.transition.jianyu_touxiang = self.transition.jianyu.transform:Find("jianyu/jianyutouxiang")
                    self.transition.jianyu_collider.transform:SetParent(self.transition.colliderroottransform, false)
                    SetClickCallback(self.transition.jianyu_collider.gameObject, function(go)
                        JailInfo.Show()
                    end)
                    BuildingShowInfoUI.SetReposition()
                end
            elseif self.transition.HasPrisoner then
                self.transition.HasPrisoner = false
                if self.transition.jianyu ~= nil and not self.transition.jianyu:Equals(nil) then
                    GameObject.Destroy(self.transition.jianyu)
                    GameObject.Destroy(self.transition.jianyu_collider)
                    self.transition.jianyu = nil
                    self.transition.jianyu_collider = nil
                end
            end
        end
    
        if self.transition.building.data.type >= 21 and self.transition.building.data.type <= 24 then
            if not self.transition.help.activeInHierarchy and not self.transition.free.activeInHierarchy and Barrack_SoldierEquipData.IsNeedShow(980 + self.transition.building.data.type) then
                if not self.transition.seNeedShow then
                    self.transition.seNeedShow = true
                    self.transition.sequip = ResourceLibrary.GetUIInstance("BuildingCommon/bingying")
                    self.transition.sequip.transform:SetParent(self.transition.building.land)
                    self.transition.sequip.transform.localPosition = Vector3(0,0,12)
                    self.transition.sequip_collider = ResourceLibrary.GetUIInstance("BuildingCommon/BuildingBubbleCollider"):GetComponent("BoxCollider")
                    self.transition.sequip_touxiang = self.transition.sequip.transform:Find("bingying")
                    self.transition.sequip_collider.transform:SetParent(self.transition.colliderroottransform, false)
                    SetClickCallback(self.transition.sequip_collider.gameObject, function(go)
                        Barrack_SoldierEquip.Show(980 + self.transition.building.data.type)
                    end)
                    BuildingShowInfoUI.SetReposition()
                end
            elseif self.transition.seNeedShow then
                self.transition.seNeedShow = false
                if self.transition.sequip ~= nil and not self.transition.sequip:Equals(nil) then
                    GameObject.Destroy(self.transition.sequip)
                    GameObject.Destroy(self.transition.sequip_collider)
                    self.transition.sequip = nil
                    self.transition.sequip_collider = nil
                end
            end
        end

        if self.transition.building.data.type == 26 then
            if not self.transition.help.activeInHierarchy and not self.transition.free.activeInHierarchy and DefenseData.IsNeedRepair() then
                if not self.transition.IsNeedRepair then
                    self.transition.IsNeedRepair = true
                    self.transition.jianyu = ResourceLibrary.GetUIInstance("BuildingCommon/chengqiang")
                    self.transition.jianyu.transform:SetParent(self.transition.building.land)
                    self.transition.jianyu.transform.localPosition = Vector3(0,0,6)
                    self.transition.jianyu_collider = ResourceLibrary.GetUIInstance("BuildingCommon/BuildingBubbleCollider"):GetComponent("BoxCollider")
                    self.transition.jianyu_touxiang = self.transition.jianyu.transform:Find("chengqiang/kejiquan")
                    self.transition.jianyu_collider.transform:SetParent(self.transition.colliderroottransform, false)
                    SetClickCallback(self.transition.jianyu_collider.gameObject, function(go)
                        DefenceNumber.Show()
                    end)
                    BuildingShowInfoUI.SetReposition()
                end
            elseif self.transition.IsNeedRepair then
                self.transition.IsNeedRepair = false
                if self.transition.jianyu ~= nil and not self.transition.jianyu:Equals(nil) then
                    GameObject.Destroy(self.transition.jianyu)
                    GameObject.Destroy(self.transition.jianyu_collider)
                    self.transition.jianyu = nil
                    self.transition.jianyu_collider = nil
                end
            end
        end

        if self.transition.building.data.type == 8 then
            if not self.transition.IsMobaShow then
                local path = {"yuyue", "baoming", "kaiqi"}
                self.transition.IsMobaShow = true
                self.transition.moba = {}
                for i, v in ipairs(path) do
                    self.transition.moba[i] = ResourceLibrary.GetUIInstance("BuildingCommon/" .. v)
                    self.transition.moba[i].transform:SetParent(self.transition.building.land)
                    self.transition.moba[i].transform.localPosition = Vector3(0,0,15)
                    self.transition.moba[i].gameObject:SetActive(i == status)
                end
                self.transition.moba_collider = ResourceLibrary.GetUIInstance("BuildingCommon/BuildingBubbleCollider"):GetComponent("BoxCollider")
                self.transition.moba_touxiang = self.transition.moba[1].transform
                self.transition.moba_collider.transform:SetParent(self.transition.colliderroottransform, false)
                SetClickCallback(self.transition.moba_collider.gameObject, function(go)
                    Entrance.Show()
                end)
                BuildingShowInfoUI.SetReposition()
            end
            local data = MobaData.GetMobaMatchInfo()
            if data ~= nil and data.status > 0 then
                local status = 0
                if data.status == 1 then
                    if data.userstatus ~= 0 then
                        status = 0
                    else
                        status = 1
                    end
                elseif data.status == 2 then
                    if data.userstatus ~= 1 then
                        status = 0
                    else
                        status = 2
                    end
                elseif data.status == 3 and (data.userstatus == 2 or data.userstatus == 3) then
                    status = 3
                else
                    status = 0
                end
                for i, v in ipairs(self.transition.moba) do
                    if v ~= nil then
                        v.gameObject:SetActive(i == status)
                    end
                end
                self.transition.moba_collider.gameObject:SetActive(status ~= 0)
            elseif self.transition.IsMobaShow then
                if self.transition.moba ~= nil then
                    for i, v in ipairs(self.transition.moba) do
                        if v ~= nil then
                            v.gameObject:SetActive(false)
                        end
                    end
                    self.transition.moba_collider.gameObject:SetActive(false)
                end
            end
        end

        if self.transition.building.data.type == 9 then
            if self.transition.sfx == nil or self.transition.sfx:Equals(nil) then
                self.transition.sfx = self.transition.building.land:Find("paihangbang_01/paihangbangdiaoxiang/kong")
            end
            self.transition.sfx.gameObject:SetActive(ArenaInfoData.HasNotice())
        end
    end
    
    if showtime == nil then
        checkOther()
        checkhospitalandhero()
        self.transition.foot.gameObject:SetActive(false)
        return
    else
        self.transition.foot.gameObject:SetActive(true)
    end
    
    if not isfree and self.buildtime ~= nil and UnionHelpData.HasBuildHelp(self.transition.building.data.uid) and self.buildtime.beginTime >= UnionInfoData.GetJoinTime() then
        if self.transition.help.activeInHierarchy == false then
            self.transition.help:SetActive(true)
            self.transition.help_collider.enabled = true
            SetClickCallback(self.transition.help_collider.gameObject, function(go)
                UnionHelpData.RequestBuildHelp(self.transition.building.data.uid)
                self.transition.help:SetActive(false)
                self.transition.help_collider.enabled = false
            end)
        end
    elseif not isfree and self.techtime ~= nil and UnionHelpData.HasTechHelp() and self.techtime.beginTime >= UnionInfoData.GetJoinTime() then
        if self.transition.help.activeInHierarchy == false then
            self.transition.help:SetActive(true)
            self.transition.help_collider.enabled = true
            SetClickCallback(self.transition.help_collider.gameObject, function(go)
                UnionHelpData.RequestTechHelp()
                self.transition.help:SetActive(false)
                self.transition.help_collider.enabled = false
            end)
        end
    else
        self.transition.help:SetActive(false)
        self.transition.help_collider.enabled = false
    end
    if showtime.type == 1 then
        if isfree then
            if self.transition.free.activeInHierarchy == false then
                self.transition.free:SetActive(true)
                self.transition.help:SetActive(false)
                self.transition.free_collider.enabled = true
                self.transition.help_collider.enabled = false
                SetClickCallback(self.transition.free_collider.gameObject, function(go)
                    self.transition.building.buildingfree = false
                    maincity.FinishBuild(self.transition.building)
                    --[[ self:RemoveTime(showtime.type)
                    self.transition.free:SetActive(false)
                    self.transition.help:SetActive(false)
                    self.transition.free_collider.enabled = false
                    self.transition.help_collider.enabled = false ]]
                end)
            end
        else
            self.transition.free:SetActive(false)
            self.transition.free_collider.enabled = false
        end
    elseif showtime.type == 2 then
        if isfree then
            if self.transition.free.activeInHierarchy == false then
                self.transition.free:SetActive(true)
                self.transition.help:SetActive(false)
                self.transition.free_collider.enabled = true
                self.transition.help_collider.enabled = false
                SetClickCallback(self.transition.free_collider.gameObject, function(go)
                    self.transition.building.techfree = false
                    LaboratoryUpgrade.RequestFree(function()
                        MainCityQueue.UpdateSimpleQueue();
                    end)
                    --[[ self:RemoveTime(showtime.type)
                    self.transition.free:SetActive(false)
                    self.transition.help:SetActive(false)
                    self.transition.free_collider.enabled = false
                    self.transition.help_collider.enabled = false ]]
                end)
            end
        else
            self.transition.free:SetActive(false)
            self.transition.free_collider.enabled = false
        end
    end
    self.transition.foot_icon.spriteName = showtime.icon
    self.transition.foot_time.text = Serclimax.GameTime.SecondToString3(showtime.time - self.curtime)
    if showtime.time < self.curtime then
        self:RemoveTime(showtime.type)
        self.transition.foot.gameObject:SetActive(false)
        self.transition.free:SetActive(false)
        self.transition.help:SetActive(false)
        self.transition.free_collider.enabled = false
        self.transition.help_collider.enabled = false
		MainCityQueue.UpdateSimpleQueue();
    end
    checkOther()
    checkhospitalandhero()
end

function BuildTransition:UpdateCollider(pos, scale)
    self.transition.free_collider.transform.localPosition = pos
    self.transition.free_collider.transform.localScale = scale
    self.transition.help_collider.transform.localPosition = pos
    self.transition.help_collider.transform.localScale = scale
    self.transition.hero_collider.transform.localPosition = pos
    self.transition.hero_collider.transform.localScale = scale
end

function BuildTransition:MakeUpgradeMark()
    local transition = self.transition
    local _building = transition.building
	transition.level_text.text = _building.data.level
	local canshow =	true
	local str =	_building.upgradeData.unlockCondition
	if str == "NA" then
		canshow	= true
	end
	
	str	= str:split(";")
	for	i, w in	ipairs(str)	do
		local s	= w:split(":")
		if #s >	1 then
			if tonumber(s[1]) == 1 then
				local isenough,	lv = maincity.CheckLevelByID(s[2], s[3])
				if isenough	then
					canshow	= canshow and true
				else
					canshow	= canshow and false
				end
			else
				if tonumber(s[3]) <= GetBuildingCount(s[2])	then
					canshow	= canshow and true
				else
					canshow	= canshow and false
				end
			end
		end
	end
	
	str	= _building.upgradeData.needItem
	if str == "NA" then
		canshow	= canshow and true
	end
	str	= str:split(";")
	for	i, v in	ipairs(str)	do
		local s	= v:split(":")
        if #s >	1 then
            local needid = tonumber(s[1])
            if needid >= 15001 and needid <= 15004 then
				local itembagdata = ItemListData.GetItemDataByBaseId(needid)
				if itembagdata ~= nil and itembagdata.number >= tonumber(s[2]) then
					canshow	= canshow and true
                else
                    canshow	= canshow and false
                end
			else
                if MoneyListData.GetMoneyByType(needid)	>= tonumber(s[2]) then
                    canshow	= canshow and true
                else
                    canshow	= canshow and false
                end
            end
		end
	end
	
	if _building.buildingData.levelMax == 1	then
        canshow	= false
        transition.level.gameObject:SetActive(false)
    end
    
    if _building.data.donetime > Serclimax.GameTime.GetSecTime() then
        canshow = false
    end
	
	if _building.data.level	== _building.buildingData.levelMax then
		canshow	= false
	end
	
	if not maincity.HasFreeQueue() then
		canshow	= false
    end
    
	if canshow then
        transition.level_upgrade.gameObject:SetActive(true)
    else
        transition.level_upgrade.gameObject:SetActive(false)
    end
end
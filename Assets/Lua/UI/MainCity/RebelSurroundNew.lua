module("RebelSurroundNew", package.seeall)
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

local _ui, UpdateUI, UpdateBtn
local islose

local function CloseSelf()
	Global.CloseUI(_M)
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

local function CheckWorldMap(isworldmap, callback)
	if not isworldmap then
	    if GUIMgr:IsMenuOpen("WorldMap") then
	        MainCityUI.HideWorldMap(true, callback, true)
		else
			if callback ~= nil then
				callback()
			end
	    end
	elseif isworldmap then
	    if not GUIMgr:IsMenuOpen("WorldMap") then
	        MainCityUI.ShowWorldMap(nil, nil, true, callback)
	    else
	        if callback ~= nil then
				callback()
			end
	    end
	end
end

local function TrainSoldier()
    local _building = maincity.GetEmptyBarrack()
    if _building ~= nil then
        CheckWorldMap(false, function()
            Barrack.Show(_building.data.type)
        end)
    end
end

function Awake()
    if _ui == nil then
        _ui = {}
    end
    _ui.container = transform:Find("Container").gameObject
    _ui.mask = transform:Find("mask").gameObject
    _ui.btn_close = transform:Find("Container/background/close btn").gameObject

    _ui.label_time = transform:Find("Container/background/top/Sprite_time/Label"):GetComponent("UILabel")
    _ui.btn_add = transform:Find("Container/background/top/button_add").gameObject
    _ui.label_soldier = transform:Find("Container/background/top/text_soldier/Label"):GetComponent("UILabel")
    _ui.label_wave = transform:Find("Container/background/top/text_number/Label"):GetComponent("UILabel")

    _ui.enemys = {}
    for i = 1, 4 do
        local enemy = {}
        enemy.texture = transform:Find(string.format("Container/background/mid/Grid01/btn_enemy (%d)/enemy", i)):GetComponent("UITexture")
        enemy.label_num = transform:Find(string.format("Container/background/mid/Grid01/btn_enemy (%d)/Label", i)):GetComponent("UILabel")
        table.insert(_ui.enemys, enemy)
    end

    _ui.grid = transform:Find("Container/background/mid/Grid02"):GetComponent("UIGrid")

    _ui.btn_bottom = transform:Find("Container/background/bottom/button"):GetComponent("UIButton")
    _ui.btn_sprite = _ui.btn_bottom:GetComponent("UISprite")
    _ui.btn_text = transform:Find("Container/background/bottom/button/Label"):GetComponent("UILabel")

    AddDelegate(UICamera, "onPress", OnUICameraPress)
    RebelSurroundNewData.AddListener(UpdateUI)
    RebelSurroundNewData.AddSoldierChangeListener(UpdateUI)
end

function Start()
    SetClickCallback(_ui.mask, CloseSelf)
    SetClickCallback(_ui.container, CloseSelf)
    SetClickCallback(_ui.btn_close, CloseSelf)
    UpdateUI()
end

UpdateUI = function()
    _ui.data = RebelSurroundNewData.GetNemesisInfo()
    local data = _ui.data
    if data == nil then
        CloseSelf()
        return
    end
    if data.pathArriveTime > Serclimax.GameTime.GetSecTime() then
        _ui.label_time.transform.parent.gameObject:SetActive(true)
        CountDown.Instance:Add("RebelSurroundNew", data.pathArriveTime, CountDown.CountDownCallBack(function(t)
            if t == "00:00:00" then
                CountDown.Instance:Remove("RebelSurroundNew")
            end
            _ui.label_time.text = Format(TextMgr:GetText("RebelSurround_new_4"), t)
        end))                
        UpdateBtn(3)
    else
        _ui.label_time.text = TextMgr:GetText("RebelSurround_new_5")
        if data.win then
            UpdateBtn(2)
            _ui.label_time.transform.parent.gameObject:SetActive(false)
        else
            UpdateBtn(1)
            _ui.label_time.transform.parent.gameObject:SetActive(true)
        end
    end
    _ui.curArmyCount = Barrack.GetRealArmyNum() + Barrack.GetDefTotalNum()
    _ui.label_soldier.text = (_ui.curArmyCount >= data.recommendSoldier and "[ffffff]" or "[ff0000]") .. _ui.curArmyCount .. "[-]/" .. data.recommendSoldier
    _ui.label_wave.text = (data.MaxWave - data.wave) .. "/" .. data.MaxWave
    _ui.btn_add:SetActive(_ui.curArmyCount < data.recommendSoldier)
    SetClickCallback(_ui.btn_add, function()
        TrainSoldier()
    end)
    for i, v in ipairs(data.army.army.army) do
        local soldier = TableMgr:GetBarrackData(v.armyId , v.armyLevel)
        if i <= 4 then
            _ui.enemys[i].texture.mainTexture = ResourceLibrary:GetIcon ("Icon/Unit/", soldier.SoldierIcon)
            _ui.enemys[i].label_num.text = v.num
        end
    end
    while _ui.grid.transform.childCount > 0 do
        GameObject.DestroyImmediate(_ui.grid.transform:GetChild(0).gameObject)
    end
    for i, v in ipairs(data.rewardInfo.items) do
        local item = UIUtil.AddItemToGrid(_ui.grid.gameObject, v, nil)
        SetParameter(item.gameObject, "item_" .. v.id)
    end
    _ui.grid:Reposition()
end

UpdateBtn = function(state)
    if state == 1 then
        _ui.btn_bottom.normalSprite = "btn_3"
        _ui.btn_sprite.spriteName = "btn_3"
        _ui.btn_text.text = TextMgr:GetText("RebelSurround_12")
        _ui.btn_text.color = Color.white
        SetClickCallback(_ui.btn_bottom.gameObject, function()
            if _ui.curArmyCount == 0 then
                MessageBox.Show(TextMgr:GetText("paradeground_ui2"), TrainSoldier, function() end, TextMgr:GetText("activity_content_15"))
            elseif _ui.curArmyCount < _ui.data.recommendSoldier then
                MessageBox.Show(TextMgr:GetText("RebelSurround_23"), RebelSurroundNewData.RequestMsgNemesisStartBattle, TrainSoldier, TextMgr:GetText("RebelSurround_24"), TextMgr:GetText("activity_content_15"), "btn_3", "btn_1", true)
            else
                RebelSurroundNewData.RequestMsgNemesisStartBattle()
            end
        end)
        if _ui.data.wave == 1 and not GUIMgr:IsMenuOpen("Barrack") and not islose then
            GrowGuide.Show(_ui.btn_bottom.transform, nil)
        end
    elseif state == 2 then
        _ui.btn_bottom.normalSprite = "btn_2"
        _ui.btn_sprite.spriteName = "btn_2"
        _ui.btn_text.text = TextMgr:GetText("mail_ui12")
        _ui.btn_text.color = Color.white
        SetClickCallback(_ui.btn_bottom.gameObject, function()
            RebelSurroundNewData.RequestNemesisTakeReward(_ui.data.wave, function(msg)
                if msg.code == 0 then
                    RebelSurroundNewData.RequestNemesisInfo()
                    MainCityUI.UpdateRewardData(msg.freshInfo)
                    if _ui.data.wave == 1 then
                        local story = {}
                        local s = {}
                        s.person = "bg_Baruch"
                        s.speak = "tutorial_147"
                        table.insert(story, s)
                        s = {}
                        s.person = "icon_guide_male"
                        s.speak = "tutorial_148"
                        table.insert(story, s)
                        s = {}
                        s.person = "icon_guide_male"
                        s.speak = "tutorial_149"
                        table.insert(story, s)
                        Story.ShowMultiple(story, function()
                            ItemListShowNew.Show(msg, nil, "RebelSurround_new_12")
                        end)
                    else
                        ItemListShowNew.Show(msg, nil, "RebelSurround_new_12")
                    end
                    CloseSelf()
                else
                    Global.ShowError(msg.code)
                end
            end)
        end)
        if _ui.data.wave == 1 then
            GrowGuide.Show(_ui.btn_bottom.transform, nil, true)
        end
    else
        _ui.btn_bottom.normalSprite = "btn_4"
        _ui.btn_sprite.spriteName = "btn_4"
        _ui.btn_text.text = TextMgr:GetText("RebelSurround_12")
        _ui.btn_text.color = Color(0.5,0.5,0.5,1)
        SetClickCallback(_ui.btn_bottom.gameObject, function()
            FloatText.ShowAt(_ui.btn_bottom.transform.position, TextMgr:GetText("RebelSurround_new_16"), Color.white)
        end)
    end
end

function Close()
    CountDown.Instance:Remove("RebelSurroundNew")
    RemoveDelegate(UICamera, "onPress", OnUICameraPress)
    RebelSurroundNewData.RemoveListener(UpdateUI)
    RebelSurroundNewData.RemoveSoldierChangeListener(UpdateUI)
    _ui = nil
    islose = nil
end

function Show()
	Global.OpenUI(_M)
end

function ShowBattle(result)
    msg ={
        content = "Mail_attack_actmonster_win_Desc",
        misc =
        {
            recon ={},
            robres ={},
            traderes ={},
            heros ={},
            train ={},
            attachShow ={},
            siegeShow ={},
            reportid = 8602,
            source ={},
            target ={},
            fortOccupy ={},
            result ={},
        }        
    }
    msg.misc.result = result.battleResult 
    msg.misc.result.input.user.team1[1].user.name = TextMgr:GetText(result.nemesisName)
    msg.misc.result.input.user.team1[1].user.face = 666
    msg.misc.result.ACampPlayers[1].icon = 666
    msg.misc.source = msg.misc.result.input.user.team1[1].user
    msg.misc.target = msg.misc.result.input.user.team2[1].user
    if msg.misc.result.input.user.team1[1].hero == nil then
        msg.misc.result.input.user.team1[1].hero = {heros={}}
    end
    if msg.misc.result.input.user.team2[1].hero == nil then
        msg.misc.result.input.user.team2[1].hero = {heros={}}
    end    

    local mainui = "MainCityUI"
	local posx = 0
	local posy = 0
	if GUIMgr:FindMenu("WorldMap") ~= nil then
		mainui = "WorldMap"
		local curpos = WorldMap.GetCenterMapCoord()
		posx , posy = WorldMap.GetCenterMapCoord()
	end
    Global.SetBattleReportBack(mainui , "RebelSurroundNew" , posx , posy)
    RebelSurroundNewData.RequestNemesisInfo()
    Global.CheckBattleReportEx(msg ,Mail.MailReportType.MailReport_player , function()
		print("report end function")
        local backfunction = function()
            RebelSurroundNew.Show()
            if result.battleResult.winteam == 1 then
                islose = true
                MessageBox.Show(TextMgr:GetText("RebelSurround_new_7"), TrainSoldier, function() end, TextMgr:GetText("activity_content_15"), nil, "btn_2")
            else
                if result.wave == 10 then
                    local story = {}
                    local s = {}
                    s.person = "bg_Baruch"
                    s.speak = "tutorial_112"
                    table.insert(story, s)
                    s = {}
                    s.person = "icon_guide"
                    s.speak = "tutorial_113"
                    table.insert(story, s)
                    s = {}
                    s.person = "icon_guide_male"
                    s.speak = "tutorial_114"
                    table.insert(story, s)
                    Story.ShowMultiple(story)
                end
            end 
        end
		local battleBack = Global.GetBattleReportBack()
		if battleBack.MainUI == "WorldMap" then
            MainCityUI.ShowWorldMap(battleBack.PosX , battleBack.PosY, false, backfunction)
        else
            backfunction()
		end
	end)
end

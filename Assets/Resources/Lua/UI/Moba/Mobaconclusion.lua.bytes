module("Mobaconclusion", package.seeall)

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
local GameObject = UnityEngine.GameObject

local _ui

local TextIds = {"ui_moba_87", "ui_moba_89", "ui_moba_88"}

local scoreData, winner

function OnUICameraClick(go)
    Tooltip.HideItemTip()
    if go ~= _ui.tipObject then
        _ui.tipObject = nil
    end
    if go ~= _ui.btn_choose then
        _ui.choose_tween:PlayReverse(false)
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
    MainCityUI.HideWorldMap(true , MainCityUI.WorldMapCloseCallback, true)
end

function Show(data, _winner)
    Global.DumpMessage(data, "d:/ddddd.lua")
    scoreData = data
    winner = _winner
    Global.OpenUI(_M)
end

local function ChangeChoose(index)
    for i, v in ipairs(_ui.contents) do
        v:SetActive(i == index)
    end
    for i, v in ipairs(_ui.choose) do
        v.select:SetActive(i == index)
        if i == index then
            _ui.choose_label.text = TextMgr:GetText(TextIds[index])
        end
    end
    _ui.content1_table_b:Reposition()
    _ui.content1_table_r:Reposition()
    _ui.content2_grid_b:Reposition()
    _ui.content2_grid_r:Reposition()
    _ui.content3_grid_b:Reposition()
    _ui.content3_grid_r:Reposition()
end

function Awake()
    _ui = {}
    _ui.btn_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
    _ui.btn_close2 = transform:Find("Container/bg_frane/bg_top_finish/btn_close").gameObject
    _ui.btn_cancel = transform:Find("Container/bg_frane/bg/buttom/btn_cancel").gameObject

    _ui.top1 = transform:Find("Container/bg_frane/bg_top").gameObject
    _ui.top2 = transform:Find("Container/bg_frane/bg_top_finish").gameObject

    _ui.winlose_root = transform:Find("Container/bg_frane/bg_top/bg_title_left").gameObject
    _ui.winlose_texture = transform:Find("Container/bg_frane/bg_top/bg_title_left/title"):GetComponent("UITexture")
    _ui.winlose_bg1 = transform:Find("Container/bg_frane/bg_top/bg_title_left"):GetComponent("UITexture")
    _ui.winlose_bg2 = transform:Find("Container/bg_frane/bg_top/bg_title_left/bg_title_right"):GetComponent("UITexture")
    _ui.draw = transform:Find("Container/bg_frane/bg_top/draw").gameObject
    _ui.time = transform:Find("Container/bg_frane/bg_top/time"):GetComponent("UILabel")
    _ui.duration = transform:Find("Container/bg_frane/bg_top/duration"):GetComponent("UILabel")

    _ui.time2 = transform:Find("Container/bg_frane/bg_top_finish/time"):GetComponent("UILabel")
    _ui.duration2 = transform:Find("Container/bg_frane/bg_top_finish/duration"):GetComponent("UILabel")
    _ui.finish_left_win = transform:Find("Container/bg_frane/bg_top_finish/left/win").gameObject
    _ui.finish_left_fail = transform:Find("Container/bg_frane/bg_top_finish/left/fail").gameObject
    _ui.finish_left_score = transform:Find("Container/bg_frane/bg_top_finish/left/score"):GetComponent("UILabel")
    _ui.finish_right_win = transform:Find("Container/bg_frane/bg_top_finish/right/win").gameObject
    _ui.finish_right_fail = transform:Find("Container/bg_frane/bg_top_finish/right/fail").gameObject
    _ui.finish_right_score = transform:Find("Container/bg_frane/bg_top_finish/right/score"):GetComponent("UILabel")

    _ui.btn_choose = transform:Find("Container/bg_frane/bg/choose/btn_choose").gameObject
    _ui.choose_label = transform:Find("Container/bg_frane/bg/choose/btn_choose/text_cancel"):GetComponent("UILabel")
    _ui.choose_root = transform:Find("Container/bg_frane/bg/choose/Panel").gameObject
    _ui.choose_tween = transform:Find("Container/bg_frane/bg/choose/Panel/open"):GetComponent("TweenPosition")
    _ui.choose = {}
    _ui.choose[1] = {}
    _ui.choose[1].gameObject = transform:Find("Container/bg_frane/bg/choose/Panel/open/Label").gameObject
    _ui.choose[1].label = transform:Find("Container/bg_frane/bg/choose/Panel/open/Label"):GetComponent("UILabel")
    _ui.choose[1].select = transform:Find("Container/bg_frane/bg/choose/Panel/open/Label/Select").gameObject
    _ui.choose[2] = {}
    _ui.choose[2].gameObject = transform:Find("Container/bg_frane/bg/choose/Panel/open/Label (1)").gameObject
    _ui.choose[2].label = transform:Find("Container/bg_frane/bg/choose/Panel/open/Label (1)"):GetComponent("UILabel")
    _ui.choose[2].select = transform:Find("Container/bg_frane/bg/choose/Panel/open/Label (1)/Select").gameObject
    _ui.choose[3] = {}
    _ui.choose[3].gameObject = transform:Find("Container/bg_frane/bg/choose/Panel/open/Label (2)").gameObject
    _ui.choose[3].label = transform:Find("Container/bg_frane/bg/choose/Panel/open/Label (2)"):GetComponent("UILabel")
    _ui.choose[3].select = transform:Find("Container/bg_frane/bg/choose/Panel/open/Label (2)/Select").gameObject

    _ui.contents = {}
    _ui.contents[1] = transform:Find("Container/bg_frane/content1").gameObject
    _ui.contents[2] = transform:Find("Container/bg_frane/content2").gameObject
    _ui.contents[3] = transform:Find("Container/bg_frane/content3").gameObject

    _ui.content1_table_r = transform:Find("Container/bg_frane/content1/Scroll View/Table_r"):GetComponent("UITable")
    _ui.content1_table_b = transform:Find("Container/bg_frane/content1/Scroll View/Table_b"):GetComponent("UITable")
    _ui.content1_info = transform:Find("Container/bg_frane/content1/TroopsInfo")
    _ui.hero = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")

    _ui.content2_grid_b = transform:Find("Container/bg_frane/content2/Scroll View/Grid_b"):GetComponent("UIGrid")
    _ui.content2_grid_r = transform:Find("Container/bg_frane/content2/Scroll View/Grid_r"):GetComponent("UIGrid")
    _ui.content2_info = transform:Find("Container/bg_frane/content2/playerInfo")

    _ui.content3_grid_b = transform:Find("Container/bg_frane/content3/Scroll View/Grid_b"):GetComponent("UIGrid")
    _ui.content3_grid_r = transform:Find("Container/bg_frane/content3/Scroll View/Grid_r"):GetComponent("UIGrid")
    _ui.content3_info = transform:Find("Container/bg_frane/content3/playerInfo2")

    AddDelegate(UICamera, "onClick", OnUICameraClick)
    AddDelegate(UICamera, "onDragStart", OnUICameraDragStart)
end

function Start()
    SetClickCallback(_ui.btn_close, CloseSelf)
    SetClickCallback(_ui.btn_close2, CloseSelf)
    SetClickCallback(_ui.btn_cancel, CloseSelf)

    _ui.top1:SetActive(winner == nil)
    _ui.top2:SetActive(winner ~= nil)

    SetClickCallback(_ui.btn_choose, function()
        _ui.choose_root:SetActive(true)
        _ui.choose_tween:PlayForward(false)
    end)

    for i, v in ipairs(_ui.choose) do
        SetClickCallback(v.gameObject, function()
            ChangeChoose(i)
        end)
    end
    
    _ui.data = scoreData
    if _ui.data == nil then
        print("结果数据木有！！！")
        return
    end
    _ui.time.text = Global.SecondToStringFormat(_ui.data.info.starttime , "yyyy-MM-dd HH:mm:ss")
    _ui.duration.text = Serclimax.GameTime.SecondToString(_ui.data.info.overtime - _ui.data.info.starttime)
    _ui.time2.text = _ui.time.text
    _ui.duration2.text = _ui.duration.text
    if winner ~= nil then
        _ui.finish_left_win:SetActive(winner == 1)
        _ui.finish_left_fail:SetActive(winner ~= 1)
        _ui.finish_right_win:SetActive(winner ~= 1)
        _ui.finish_right_fail:SetActive(winner == 1)
    end
    _ui.totalkill = {}
    _ui.totalkill[1] = 0
    _ui.totalkill[2] = 0
    table.sort(_ui.data.userlist.users, function(a, b)
        return a.rank < b.rank
    end)
    for i, v in ipairs(_ui.data.userlist.users) do
        _ui.totalkill[v.team] = _ui.totalkill[v.team] + v.totalkill
        if v.charid == MainData.GetCharId() then
            _ui.winlose_root:SetActive(v.win ~= 0)
            _ui.draw:SetActive(v.win == 0)
            _ui.winlose_texture.mainTexture = ResourceLibrary:GetIcon("Background/", v.win == 1 and "Moba_victory" or "Moba_defeat")
            _ui.winlose_bg1.mainTexture = ResourceLibrary:GetIcon("Background/", v.win == 1 and "Moba_bg_victory" or "Moba_bg_defeat")
            _ui.winlose_bg2.mainTexture = ResourceLibrary:GetIcon("Background/", v.win == 1 and "Moba_bg_victory" or "Moba_bg_defeat")
        end
    end

    if winner ~= nil then
        _ui.finish_left_score.text = System.String.Format(TextMgr:GetText("LuckyRotary_3"), _ui.data.info.teama.score)
        _ui.finish_right_score.text = System.String.Format(TextMgr:GetText("LuckyRotary_3"), _ui.data.info.teamb.score)
    end

    for i, v in ipairs(_ui.data.userlist.users) do
        local info
        if v.team == 1 then
            info = NGUITools.AddChild(_ui.content1_table_b.gameObject, _ui.content1_info.gameObject).transform
            info:Find("bg_list"):GetComponent("UISprite").spriteName = "bg_resultbase"
        else
            info = NGUITools.AddChild(_ui.content1_table_r.gameObject, _ui.content1_info.gameObject).transform
            info:Find("bg_list"):GetComponent("UISprite").spriteName = "bg_resultbase1"
        end
        SetClickCallback(info:Find("bg_list/name").gameObject, function()
            --MobaPersonalInfo.Show(v.charid)
        end)
        info:Find("bg_list/name"):GetComponent("UILabel").text = v.charname
        info:Find("bg_list/mine").gameObject:SetActive(v.charid == MainData.GetCharId())
        local herogrid = info:Find("TroopsInfo_open/bg_general/Grid"):GetComponent("UIGrid")
        local nohero = info:Find("TroopsInfo_open/bg_general/txt_noitem").gameObject
        nohero:SetActive(#v.hero == 0)
        for ii, vv in ipairs(v.hero) do
            local heroData = TableMgr:GetHeroData(vv.baseid)
            local hero = NGUITools.AddChild(herogrid.gameObject, _ui.hero.gameObject).transform
            hero.localScale = Vector3.one * 0.6
            hero:Find("level text"):GetComponent("UILabel").text = vv.level
            hero:Find("name text").gameObject:SetActive(false)
            hero:Find("bg_skill").gameObject:SetActive(false)
            hero:Find("head icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon(ResourceLibrary.PATH_ICON .. "herohead/", heroData.icon)
            hero:Find("head icon/outline"):GetComponent("UISprite").spriteName = "head" .. heroData.quality
            local star = hero:Find("star"):GetComponent("UISprite")
            if star ~= nil then
                star.width = vv.star * star.height
            end
            local number = hero:Find("num"):GetComponent("UILabel")
            number.text = vv.num
            number.transform.localScale = Vector3.one / 0.6
            if vv.num > 1 then
                number.gameObject:SetActive(true)
            else
                number.gameObject:SetActive(false)
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
        local armymax = 0
        if false then
            for ii = 1, 4 do
                if v.army[ii] ~= nil then
                    local soldierData = TableMgr:GetBarrackData(v.army[ii].id, v.army[ii].lv)
                    info:Find(string.format("TroopsInfo_open/bg_soldier/frame/soldier/%d/text", ii)):GetComponent("UILabel").text = TextMgr:GetText(soldierData.SoldierName)
                    info:Find(string.format("TroopsInfo_open/bg_soldier/frame/soldier/%d/text (2)", ii)):GetComponent("UILabel").text = Global.ExchangeValue(v.army[ii].num)
                    info:Find(string.format("TroopsInfo_open/bg_soldier/frame/soldier/%d/text (3)", ii)):GetComponent("UILabel").text = math.floor(v.army[ii].atk + 0.5) .. " [00ff00](+" .. math.floor(v.army[ii].atk - soldierData.Attack + 0.5) .. ")[-]"
                    info:Find(string.format("TroopsInfo_open/bg_soldier/frame/soldier/%d/text (4)", ii)):GetComponent("UILabel").text = math.floor(v.army[ii].def + 0.5) .. " [00ff00](+" .. math.floor(v.army[ii].def - soldierData.fakeArmo + 0.5) .. ")[-]"
                    info:Find(string.format("TroopsInfo_open/bg_soldier/frame/soldier/%d/text (5)", ii)):GetComponent("UILabel").text = math.floor(v.army[ii].hp + 0.5) .. " [00ff00](+" .. math.floor(v.army[ii].hp - soldierData.Hp + 0.5) .. ")[-]"
                    armymax = armymax + v.army[ii].num
                end
            end
        else
            table.sort(v.army, function(a,b)
                if a.id == b.id then
                    return a.lv < b.lv
                else
                    return a.id < b.id
                end
            end)
            local nosoldier = info:Find("TroopsInfo_open/bg_soldier/frame/txt_noitem").gameObject
            local soldier_root = info:Find("TroopsInfo_open/bg_soldier/frame/soldier")
            local prefab = soldier_root:Find("1")
            local soldier_bg = info:Find("TroopsInfo_open/bg_soldier/frame"):GetComponent("UISprite")
            local base_height = soldier_bg.height
            local collider = info:Find("TroopsInfo_open"):GetComponent("BoxCollider") 
            local index = 0
            for ii, vv in ipairs(v.army) do
                index = index + 1
                local army_item
                if index <= soldier_root.childCount then
                    army_item = soldier_root:GetChild(index - 1)
                else
                    army_item = NGUITools.AddChild(soldier_root.gameObject, prefab.gameObject).transform
                end
                army_item.localPosition = Vector3(0, -20 * (index - 1), 0)
                local soldierData = TableMgr:GetBarrackData(vv.id, vv.lv)
                army_item:Find("text"):GetComponent("UILabel").text = TextMgr:GetText(soldierData.SoldierName)
                army_item:Find("text (2)"):GetComponent("UILabel").text = Global.ExchangeValue(vv.num)
                army_item:Find("text (3)"):GetComponent("UILabel").text = math.floor(vv.atk + 0.5) .. " [00ff00](+" .. math.floor(vv.atk - soldierData.Attack + 0.5) .. ")[-]"
                army_item:Find("text (4)"):GetComponent("UILabel").text = math.floor(vv.def + 0.5) .. " [00ff00](+" .. math.floor(vv.def - soldierData.fakeArmo + 0.5) .. ")[-]"
                army_item:Find("text (5)"):GetComponent("UILabel").text = math.floor(vv.hp + 0.5) .. " [00ff00](+" .. math.floor(vv.hp - soldierData.Hp + 0.5) .. ")[-]"
                armymax = armymax + vv.num
            end
            for ii = soldier_root.childCount, index + 1, -1 do
                GameObject.Destroy(soldier_root:GetChild(ii - 1).gameObject)
            end
            if index > 4 then
                soldier_bg.height = base_height + 20 * (index - 4)
                collider.size = Vector3(collider.size.x, collider.size.y + 20 * (index - 4), 0)
                collider.center = Vector3(collider.center.x, collider.center.y - 10 * (index - 4), 0)
            end
            nosoldier:SetActive(index == 0)
        end
        info:Find("bg_list/troops"):GetComponent("UILabel").text = armymax
    end
    
    for i, v in ipairs(_ui.data.userlist.users) do
        local info
        if v.team == 1 then
            info = NGUITools.AddChild(_ui.content2_grid_b.gameObject, _ui.content2_info.gameObject).transform
        else
            info = NGUITools.AddChild(_ui.content2_grid_r.gameObject, _ui.content2_info.gameObject).transform
        end
        SetClickCallback(info:Find("name").gameObject, function()
            --MobaPersonalInfo.Show(v.charid)
        end)
        info:Find("head/Texture"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/head/", v.face)
        info:Find("name"):GetComponent("UILabel").text = v.charname
        info:Find("rank"):GetComponent("UILabel").text = v.rank
        info:Find("point"):GetComponent("UILabel").text = v.totalscore
        info:Find("killed"):GetComponent("UILabel").text = v.totalkill
        info:Find("death"):GetComponent("UILabel").text = v.totaldead
        info:Find("mine").gameObject:SetActive(v.charid == MainData.GetCharId())
    end

    for i, v in ipairs(_ui.data.userlist.users) do
        local info
        if v.team == 1 then
            info = NGUITools.AddChild(_ui.content3_grid_b.gameObject, _ui.content3_info.gameObject).transform
        else
            info = NGUITools.AddChild(_ui.content3_grid_r.gameObject, _ui.content3_info.gameObject).transform
        end
        SetClickCallback(info:Find("Label").gameObject, function()
            --MobaPersonalInfo.Show(v.charid)
        end)
        info:Find("Label"):GetComponent("UILabel").text = v.charname
        info:Find("Label (1)"):GetComponent("UILabel").text = v.armymax
        info:Find("Label (2)"):GetComponent("UILabel").text = v.citynum
        info:Find("Label (3)"):GetComponent("UILabel").text = v.killmonsternum
        info:Find("Label (4)"):GetComponent("UILabel").text = v.pathnum
        local p = v.totalkill / (_ui.totalkill[v.team] == 0 and 1 or _ui.totalkill[v.team])
        info:Find("addexp"):GetComponent("UISlider").value = p
        info:Find("addexp/Label (5)"):GetComponent("UILabel").text = math.floor(p * 100 + 0.5) .. "%"
        info:Find("mine").gameObject:SetActive(v.charid == MainData.GetCharId())
    end

    ChangeChoose(2)
end
module("StrongholdInfoall", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameObject = UnityEngine.GameObject

local _ui
local mode
local actId
local curInfo
local endTime

local isInViewport = false

local infos = 
{
	[Common_pb.SceneEntryType_Fortress] =
	{
		[2013] = {desc = "FortressLord_Help_text1" , title = "ActivityAll_23" , Abtns={} , Dbtns = {} },
		[110] = {desc = "FortressLord_Help_text2" , title = "FortressLord_13" , Abtns={} , Dbtns = {}},
		
		[110003] = {desc = "FortressLord_Help_text1" , title = "ActivityAll_23" , Abtns={} , Dbtns = {} },
		[100003] = {desc = "FortressLord_Help_text2" , title = "FortressLord_13" , Abtns={} , Dbtns = {}},
		
		[110004] = {desc = "FortressLord_Help_text1" , title = "ActivityAll_23" , Abtns={} , Dbtns = {} },
		[100004] = {desc = "FortressLord_Help_text2" , title = "FortressLord_13" , Abtns={} , Dbtns = {}},
	},
	[Common_pb.SceneEntryType_Stronghold] =
	{
		[2012] = {desc = "Stronghold_Help_text1" , title = "FortressLord_14" , Abtns={} , Dbtns = {}},
		[109] = {desc = "Stronghold_Help_text2" , title = "FortressLord_15" , Abtns={} , Dbtns = {}},
		
		[2016] = {desc = "Stronghold_Help_text1" , title = "FortressLord_14" , Abtns={} , Dbtns = {}},
		[2017] = {desc = "Stronghold_Help_text2" , title = "FortressLord_15" , Abtns={} , Dbtns = {}},
		
		[110002] = {desc = "Stronghold_Help_text1" , title = "FortressLord_14" , Abtns={} , Dbtns = {}},
		[110001] = {desc = "Stronghold_Help_text1" , title = "FortressLord_14" , Abtns={} , Dbtns = {}},
		[100001] = {desc = "Stronghold_Help_text2" , title = "FortressLord_15" , Abtns={} , Dbtns = {}},
		[100002] = {desc = "Stronghold_Help_text2" , title = "FortressLord_15" , Abtns={} , Dbtns = {}},
	},
}


local hasVisited = {}
function HasVisited(id)
	return hasVisited[id] or false
end

function NotifyAvailable(id)
	hasVisited[id] = false
	MainCityUI.UpdateActivityAllNotice(id)
end


function Hide()
    Global.CloseUI(_M)
end

function ShowBtns(fortressCfg) 
	for _ , v in pairs(fortressCfg.Abtns) do
		if v == _ui.war then
			_ui.war_sprite.spriteName = "btn_1"
			_ui.war.normalSprite = "btn_1"			
		else
			v.gameObject:SetActive(true)
		end
	end
	
	for _ , v in pairs(fortressCfg.Dbtns) do
		v.gameObject:SetActive(false)
	end
end

LoadUI = function()
	local activ = nil
	local activId = 0
	_ui.help.gameObject:SetActive(false)
	_ui.go.gameObject:SetActive(false)
	_ui.war_sprite.spriteName = "btn_4"
	_ui.war.normalSprite = "btn_4"
    --_ui.war.gameObject:SetActive(false)
	
	if mode == Common_pb.SceneEntryType_Fortress then
		activ = ActivityData.GetBattleFieldActivityConfigs(actId)
		if activ ~= nil then
			if not activ.isAvailable then
				activ = ActivityData.GetBattleFieldActivityConfigs(110)
			end
		else
			activ = ActivityData.GetBattleFieldActivityConfigs(110)
		end
		_ui.title.text = TextMgr:GetText("Duke_7")
	elseif mode == Common_pb.SceneEntryType_Stronghold then
		activ = ActivityData.GetBattleFieldActivityConfigs(actId)
		if activ ~= nil then
			if not activ.isAvailable then
				activ = ActivityData.GetBattleFieldActivityConfigs(109)
			end
		else
			activ = ActivityData.GetBattleFieldActivityConfigs(109)
		end	
		_ui.title.text = TextMgr:GetText("stronghold_1")
	end
	
	if activ ~= nil then
		local cfgData = infos[mode][activ.id]
		if cfgData ~= nil then
			_ui.des.text = TextMgr:GetText(cfgData.desc)
			print(mode , cfgData.desc)
			_ui.govStateTitle.text = TextMgr:GetText(cfgData.title)
			ShowBtns(cfgData)
			endTime = activ.endTime
		end
	end
	
end

function LateUpdate()
	if endTime ~= nil then
		local leftTimeSec = endTime - Serclimax.GameTime.GetSecTime()
		if leftTimeSec > 0 then
			_ui.govStateTime.text = Global.GetLeftCooldownTextLong(endTime)
		else
			
		end
	end
end

function  Awake()
    _ui = {}
	_ui.mask = transform:Find("mask")
	_ui.title = transform:Find("Container/bg_frane/Texture/Label"):GetComponent("UILabel")
    _ui.govStateTitle = transform:Find("Container/bg_frane/mid/Sprite_time/text"):GetComponent("UILabel")
    _ui.govStateTime = transform:Find("Container/bg_frane/mid/Sprite_time/time"):GetComponent("UILabel")
    _ui.help = transform:Find("Container/bg_frane/mid/occuRule")
    _ui.go = transform:Find("Container/bg_frane/mid/rule")
	_ui.war =  transform:Find("Container/bg_frane/mid/btn_war"):GetComponent("UIButton")
	_ui.war_sprite = _ui.war.gameObject:GetComponent("UISprite")
    _ui.des =  transform:Find("Container/bg_frane/mid/text"):GetComponent("UILabel")
	
    --_ui.war_des =  transform:Find("Container/bg_frane/mid/bg_waring")
    --_ui.war_des_guild =  transform:Find("Container/bg_frane/mid/bg_waring/text (2)"):GetComponent("UILabel")

	infos[Common_pb.SceneEntryType_Fortress][2013].Abtns = {_ui.help , _ui.go}
	infos[Common_pb.SceneEntryType_Fortress][110].Abtns = {_ui.help , _ui.go , _ui.war}

	infos[Common_pb.SceneEntryType_Fortress][110003].Abtns = {_ui.help , _ui.go}
	infos[Common_pb.SceneEntryType_Fortress][100003].Abtns = {_ui.help , _ui.go , _ui.war}
	infos[Common_pb.SceneEntryType_Fortress][110004].Abtns = {_ui.help , _ui.go}
	infos[Common_pb.SceneEntryType_Fortress][100004].Abtns = {_ui.help , _ui.go , _ui.war}
	
	infos[Common_pb.SceneEntryType_Stronghold][2012].Abtns = {_ui.help , _ui.go}
	infos[Common_pb.SceneEntryType_Stronghold][109].Abtns = {_ui.help , _ui.go , _ui.war}
	infos[Common_pb.SceneEntryType_Stronghold][2016].Abtns = {_ui.help , _ui.go}
	infos[Common_pb.SceneEntryType_Stronghold][2017].Abtns = {_ui.help , _ui.go , _ui.war}
	
	
	infos[Common_pb.SceneEntryType_Stronghold][110002].Abtns = {_ui.help , _ui.go}
	infos[Common_pb.SceneEntryType_Stronghold][110001].Abtns = {_ui.help , _ui.go}
	infos[Common_pb.SceneEntryType_Stronghold][100001].Abtns = {_ui.help , _ui.go , _ui.war}
	infos[Common_pb.SceneEntryType_Stronghold][100002].Abtns = {_ui.help , _ui.go , _ui.war}
	
    if _ui.close ~= nil then
        SetClickCallback(_ui.close.gameObject,function()
            ActivityAll.Hide()
            Hide()
        end) 
    end
   
    SetClickCallback(_ui.mask.gameObject,function()
        ActivityAll.Hide()
        Hide()
        
    end)      

    SetClickCallback(_ui.help.gameObject,function()
		if mode == Common_pb.SceneEntryType_Fortress then
			GOV_Help.Show(GOV_Help.HelpModeType.FORTRESS)
		elseif  mode == Common_pb.SceneEntryType_Stronghold then
			GOV_Help.Show(GOV_Help.HelpModeType.STRONGHOLDMODE)
		end
    end)   

    SetClickCallback(_ui.go.gameObject,function()
       StrongholdRule.Show(mode)
    end)   
    
	SetClickCallback(_ui.war.gameObject,function()
		if mode == Common_pb.SceneEntryType_Fortress then
			activ = ActivityData.GetBattleFieldActivityConfigs(actId)
			if activ == nil then
				activ = ActivityData.GetBattleFieldActivityConfigs(110)
			end
		elseif mode == Common_pb.SceneEntryType_Stronghold then
			activ = ActivityData.GetBattleFieldActivityConfigs(actId)
			if activ == nil then
				activ = ActivityData.GetBattleFieldActivityConfigs(109)
			end
		end
		
	
		if activ ~= nil then
			local cfgData = infos[mode][activ.id]
			if cfgData ~= nil then
				for _ , v in pairs(cfgData.Abtns) do
					if v == _ui.war then	
						if mode == Common_pb.SceneEntryType_Fortress then
							FortressWarinfo.Show()
						elseif  mode == Common_pb.SceneEntryType_Stronghold then
							StrongholdWarinfo.Show()
						end		
						return
					end
				end
				FloatText.ShowOn(_ui.war.gameObject, TextMgr:GetText("activity_wait"))
			end
		end		
    end)       

    LoadUI()
end

function Start()
    isInViewport = true
end

function Show(_mode, id)
	mode = _mode
	actId = id
	
	hasVisited[id] = true
	MainCityUI.UpdateActivityAllNotice(id)

    if isInViewport then
        LoadUI()
    else
	    Global.OpenUI(_M)
    end
end

function Close()
    isInViewport = false

    _ui = nil
end
module("PlayerLevelup", package.seeall)

local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr.Instance
local TextMgr = Global.GTextMgr
local SetClickCallback = UIUtil.SetClickCallback
local GuideMgr = Global.GGuideManager
local ResourceLibrary = Global.GResourceLibrary
local AudioMgr = Global.GAudioMgr

local uiCoroutine

local eventListener = EventListener()

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end


local btnQuit
local lastLv
local curLv

local ShowContent
local animators
local _ui = {}

function SetLevelContent(cLevel ,lLevel)
	lastLv = lLevel
	curLv = tonumber(cLevel)
	if curLv == 3 or curLv == 5 or curLv == 8 or curLv == 10 or curLv == 15 or curLv == 20 then
		GUIMgr:SendDataReport("efun", "lv"..curLv)
	end
	GUIMgr:SendDataReport("muzhi","0")
	GUIMgr:SendDataReport("mango", "2")
end	

function GetCurrentLevel()
    return curLv
end

--退出战斗按钮
local function OnCloseCallback(go)
	GUIMgr:CloseMenu("PlayerLevelup")	
end

--local function AddContent(strName , )

function Start()
	local left_level = transform:Find("unlock/bg_frane/bg_level/num_left"):GetComponent("UILabel")
	left_level.text = lastLv
	local right_level = transform:Find("unlock/bg_frane/bg_level/num_right"):GetComponent("UILabel")
	right_level.text = curLv

	MainData.SaveMainData()
	AudioMgr:PlayUISfx("SFX_UI_character_levelup", 1, false)
	ActivityData.RequestListData()
	
	GUIMgr:SubmitRoleInfo(MainData.GetCharName(), curLv, false)
	NotifyListener()
end

function SetContent()
	--local grid = transform:Find("unlock/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
	--local content = transform:Find("listinfo")
	local index = 0
	
	local startpos = 40
	local offset = _ui.grid.cellHeight
	if uiCoroutine ~= nil then
		coroutine.stop(uiCoroutine)
	end
	uiCoroutine = coroutine.start(function()
		for i, v in pairs(ShowContent) do
		    if _ui == nil then
		        return
            end
			local item = NGUITools.AddChild(_ui.grid.gameObject , _ui.content.gameObject)
			item.gameObject:SetActive(true)
			item.transform:SetParent(_ui.grid.transform , false)
			
			local name = item.transform:Find("text"):GetComponent("UILabel")
			name.text = v.name
			local leftV = item.transform:Find("num_left"):GetComponent("UILabel")
			leftV.text = v.leftValue
			local rightV = item.transform:Find("num_right"):GetComponent("UILabel")
			rightV.text = v.rightValue
			
			--ShowContent[i].itemanim = item.transform:Find("SFX/animate"):GetComponent("Animator")
			--ShowContent[i].itemanim.transform.parent.gameObject:SetActive(true)
			item.transform:Find("SFX").gameObject:SetActive(true)
			item.transform.localPosition = Vector3(0 , startpos - index*offset , 0 , 0)
			index = index + 1
			
			coroutine.wait(0.5)
		end
		--[[
		grid:Reposition()
		coroutine.wait(0.5)
		for i=1 , 3 do
			ShowContent[i].itemanim.transform.parent.gameObject:SetActive(true)
			coroutine.wait(0.5)
		end
		]]
		
	end)
end

function Awake()
	_ui = {}
	_ui.grid = transform:Find("unlock/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.content = transform:Find("listinfo")

	local btnClose = transform:Find("unlock/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(btnClose.gameObject , OnCloseCallback)
	
	local container = transform:Find("unlock")
	SetClickCallback(container.gameObject, function(go)
		GUIMgr:CloseMenu("PlayerLevelup")
	end)
	
	local lastExpData = TableMgr:GetPlayerExpData(lastLv)
	local curExpData = TableMgr:GetPlayerExpData(curLv)
	
	local curEnergy = 0
	local sceneEnergy = 0
	local lv = lastLv
	while lv < curLv do
		local ExpData = TableMgr:GetPlayerExpData(lv)
		curEnergy = curEnergy + ExpData.energy
		sceneEnergy = sceneEnergy + ExpData.mpoint
		lv = lv + 1
		
	end
	
	ShowContent = {}
	local index = 1
	--"增加体力"
	if MainData.GetSavedEnergy() + curEnergy > MainData.GetSavedEnergy() then
		ShowContent[index] = {}
		ShowContent[index].name = TextMgr:GetText("player_ui23")--"当前体力"
		ShowContent[index].leftValue = MainData.GetSavedEnergy()
		ShowContent[index].rightValue = MainData.GetSavedEnergy() + curEnergy
		index = index + 1
	end
	
	--"增加体力上限"
	if curExpData.energyMax > lastExpData.energyMax then
		ShowContent[index] = {}
		ShowContent[index].name = TextMgr:GetText("player_ui24")
		ShowContent[index].leftValue = lastExpData.energyMax
		ShowContent[index].rightValue = curExpData.energyMax
		index = index + 1
	end
	--[[
	--"将军等级上限"
	if curExpData.heroMaxLevel > lastExpData.heroMaxLevel then
		ShowContent[index] = {}
		ShowContent[index].name = TextMgr:GetText("player_ui25")
		ShowContent[index].leftValue = lastExpData.heroMaxLevel
		ShowContent[index].rightValue = curExpData.heroMaxLevel
		index = index + 1
	end
	--]]
	--"天赋总数上限"
	--[[if curExpData.totalTalentPoint > lastExpData.totalTalentPoint then
		ShowContent[index] = {}
		ShowContent[index].name = TextMgr:GetText("player_ui29")
		ShowContent[index].leftValue = lastExpData.totalTalentPoint
		ShowContent[index].rightValue = curExpData.totalTalentPoint
		index = index + 1
	end]]
	
	--"行动力总数上限"
	if MainData.GetSavedScenEnergy() + sceneEnergy > MainData.GetSavedScenEnergy() then
		ShowContent[index] = {}
		ShowContent[index].name = TextMgr:GetText("Mpoint_Levelup")--"当前行动力"
		ShowContent[index].leftValue = MainData.GetSavedScenEnergy()
		ShowContent[index].rightValue = MainData.GetSavedScenEnergy() + sceneEnergy
		index = index + 1
	end
	
	animators = {}
	animators.anim_title = transform:Find("unlock/bg_frane/bg_top/title"):GetComponent("Animator")
	animators.top_sfx = transform:Find("unlock/bg_frane/bg_top/SFX/Animate"):GetComponent("Animator")
	animators.top_sfxTrf = transform:Find("unlock/bg_frane/bg_top/SFX")
	
	local tweenScale = transform:Find("unlock"):GetComponent("TweenScale")
	tweenScale:SetOnFinished(EventDelegate.Callback(function()
		animators.anim_title.enabled = true
		animators.top_sfx.enabled = true
		SetContent()
	end))
end

function Close()
	if uiCoroutine ~= nil then
		coroutine.stop(uiCoroutine)
		uiCoroutine = nil
	end
	
	_ui = nil
	FunctionListData.RequestListData()
	TalentInfoData.RequestData()
end

function Show()
	if curLv < 5 then
		return
	end
    Global.OpenUI(_M)
end

module("pause", package.seeall)

local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local SetClickCallback = UIUtil.SetClickCallback

local GameTime = Serclimax.GameTime
local gamestateBattle

local btnRestart
local btnQuit
local btnContinue
local btnBg
local GuideMgr = Global.GGuideManager
local oldTimeScale
local battleData


function SetBattleData(bData)
	battleData = bData
end
--再玩一次按钮
local function RestartClickCallback(isPressed)
	local msg = TextMgr:GetText(Text.ingame_hint1)
	local okCallback = function()
        local battleState = GameStateBattle.Instance
        if battleState.IsCommonBattle then
            InGameUI.RequestEscapeBattle()
        end
		SceneManager.instance.gScRoots.GamePaused = false
		gamestateBattle:Restart()
	end
	local cancelCallback = function()
		
		SceneManager.instance.gScRoots.GamePaused = true
		MessageBox.Clear()
	end
	MessageBox.Show(msg, okCallback, cancelCallback)
end

--继续游戏
local function ContinueClickCallback(go)
	SceneManager.instance.gScRoots.GamePaused = false
	GUIMgr:CloseMenu("pause")
	GuideMgr:Resume()
	InGameUI.Show()
	AudioMgr:ResumeSfx()
end


local function QuitPveMonsterBattle()
	local battleState = GameStateBattle.Instance
	local req = BattleMsg_pb.MsgBattleMapDigTreasureEndRequest()
	print(battleState.activeId , battleState.missionId)
	req.monsterSeUid = battleState.pveMonsterUid
	
	req.data.chapterlevel = battleData.id
	req.data.escape = true
	req.data.win = false
	--req.data.battleTime = battleData.time - leftSecond
	LuaNetwork.Request(Category_pb.Battle, BattleMsg_pb.BattleTypeId.MsgBattleMapDigTreasureEndRequest, req:SerializeToString(), function(typeId, data)
		local msg = BattleMsg_pb.MsgBattleMapDigTreasureEndResponse()
		msg:ParseFromString(data)
		if msg.code == ReturnCode_pb.Code_OK then
			GUIMgr:SendDataReport("reward", "battle end:" ..battleData.id, "".. MoneyListData.ComputeDiamond(msg.data.fresh.money.money))
			--battleInfo.complete = msg.battleComplete
			WinLose.SetBattleId(battleData.id)
			WinLose.SetBattleRewards(msg.data)
			PveMonsterData.UpdatePveMonsterData(msg.winMonster)
			WinLose.OpenPveMonsterPVE()
			WinLose.Show()
			
			--send win/lose data report-------------
			GUIMgr:SendDataReport("level", "" .. battleData.id, "escape", "0")
			-----------------------------------------
			SceneManager.instance.gScRoots.GamePaused = false
			local mainState = GameStateMain.Instance
			GUIMgr:CloseAllMenu()
			Main.Instance:ChangeGameState(mainState, "",nil)
			--send win/lose data report-------------
			if gameWin then 
				GUIMgr:SendDataReport("level", "" .. battleData.id, "completed", "" .. starCount)
			else
				GUIMgr:SendDataReport("level", "" .. battleData.id, "failed", "0")
			end
			-----------------------------------------
		else
			Global.ShowError(msg.code)
		end
	
	end, true)
end
--退出战斗按钮
local function QuitClickCallback(isPressed)
	local battleState = GameStateBattle.Instance
	
	if battleState.IsPveMonsterBattle then
		QuitPveMonsterBattle()
		return
	end
	
	
	local msg = battleState.IsGuildMonsterBattle and TextMgr:GetText("Union_Radar_ui40") or TextMgr:GetText(Text.ingame_hint2)
	local okCallback = function()
	
        if battleState.IsCommonBattle then
            InGameUI.RequestEscapeBattle()
        end
		--send win/lose data report-------------
		GUIMgr:SendDataReport("level", "" .. battleData.id, "escape", "0")
		-----------------------------------------
		SceneManager.instance.gScRoots.GamePaused = false
		local mainState = GameStateMain.Instance
		GUIMgr:CloseAllMenu()
		Main.Instance:ChangeGameState(mainState, "",nil)
	end
	local cancelCallback = function()
		--GameTime.timeScale = 0
	end

	MessageBox.Show(msg, okCallback, cancelCallback)
end



function Awake()
	AudioMgr:PauseSfx()
	SceneManager.instance.gScRoots.GamePaused = true

	gamestateBattle = Global.GGameStateBattle
	TableMgr = SceneManager.instance.gScTableData

	btnQuit = transform:Find("bg_pause/bg/btn_retreat"):GetComponent("UIButton")
	SetClickCallback(btnQuit.gameObject, QuitClickCallback)
	if battleData.id == 90001 then
		btnQuit.gameObject:SetActive(false)
	end
	

	btnRestart = transform:Find("bg_pause/bg/btn_retry"):GetComponent("UIButton")
	SetClickCallback(btnRestart.gameObject, RestartClickCallback)

    local battleState = GameStateBattle.Instance
    if battleState.IsRandomBattle then
        btnRestart.gameObject:SetActive(false)
    end
	if battleState.IsGuildMonsterBattle then
        btnRestart.gameObject:SetActive(false)
    end
	if battleState.IsPveMonsterBattle then
		btnRestart.gameObject:SetActive(false)
	end

	btnContinue = transform:Find("bg_pause/bg/btn_continue"):GetComponent("UIButton")
	SetClickCallback(btnContinue.gameObject, ContinueClickCallback)

	btnBg = transform:Find("bg_pause").gameObject
	SetClickCallback(btnBg, ContinueClickCallback)
end


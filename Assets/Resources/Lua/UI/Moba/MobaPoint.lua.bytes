module("MobaPoint", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local SetDragCallback = UIUtil.SetDragCallback



local _ui

local function QuitPressCallback(go, isPressed)
	if not isPressed then
		GUIMgr:CloseMenu("MobaPoint")
	end
end


function Start()
	_ui = {}
	local btnQuit = transform:Find("Container/bg_frane/btn_close")
	SetPressCallback(btnQuit.gameObject, QuitPressCallback)
	local bg = transform:Find("Container")
	SetPressCallback(bg.gameObject, QuitPressCallback)

	_ui.refreshtime = transform:Find("Container/bg_frane/mid/countdown/time"):GetComponent("UILabel")
	_ui.states = {}
	_ui.name = transform:Find("Container/bg_frane/mid/bg_stage/name"):GetComponent("UILabel")
	
	for i=1,4 do 
	  _ui.states[i] = {}
	  _ui.states[i].btn = transform:Find("Container/bg_frane/mid/bg_stage/stage"..i):GetComponent("UISprite")
	end 

		coroutine.stop(_ui.countdowncoroutine)
		_ui.countdowncoroutine = coroutine.start(function()

			local timer = MobaData.GetMobaLeftTime()
			while true do
				timer = MobaData.GetMobaLeftTime()
				_ui.refreshtime.text = Global.SecondToTimeLong(timer)
				if timer <= 0 then
					break
				end
				local state = MobaData.GetMobaState()
				for i=1,4 do 
					
				  if state >= i then 
					_ui.states[i].btn.spriteName = "icon_stage_done"
				  else
					_ui.states[i].btn.spriteName = "icon_stage_null"
				  end 
				end 
				coroutine.wait(1)
			end
		end)
	
	
	
	
	_ui.redSp= transform:Find("Container/bg_frane/mid/bg/red/Sprite/proceed"):GetComponent("UISprite")
	_ui.redLabel= transform:Find("Container/bg_frane/mid/bg/red/Label"):GetComponent("UILabel")
	
	_ui.blueSp= transform:Find("Container/bg_frane/mid/bg/blue/Sprite/proceed"):GetComponent("UISprite")
	_ui.blueLabel= transform:Find("Container/bg_frane/mid/bg/blue/Label"):GetComponent("UILabel")
	_ui.name.text = System.String.Format(TextMgr:GetText(Text.ui_moba_115), MobaData.GetMobaState())
	
	
	coroutine.stop(_ui.scorecoroutine)
	_ui.scorecoroutine = coroutine.start(function()

		local timer = MobaData.GetMobaLeftTime()
		while true do

			timer = MobaData.GetMobaLeftTime()
			MobaData.GetMobaScoreInfo(function(msg)
				local redScore = msg.team1.score
				local blueScore = msg.team2.score
				if msg.team1.teamId == 1 then 
					redScore = msg.team1.score
					blueScore = msg.team2.score
				else
					redScore = msg.team2.score
					blueScore = msg.team1.score
				end 
				
				if _ui ~= nil then 
					_ui.redSp.fillAmount = redScore /(redScore+blueScore)
					_ui.redLabel.text = redScore
					
					_ui.blueSp.fillAmount = blueScore /(redScore+blueScore)
					_ui.blueLabel.text = blueScore
				end 
			end)
			
			if timer <= 0 then
				 break
			end
			coroutine.wait(1)
		end
	end)	
end


function Close()
	coroutine.stop(_ui.countdowncoroutine)
	coroutine.stop(_ui.scorecoroutine)
    _ui = nil
end

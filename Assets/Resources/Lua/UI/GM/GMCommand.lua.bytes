module("GMCommand", package.seeall)
local String = System.String
function SetTimeScale(timeScale)
    Serclimax.GameTime.timeScale = timeScale
end

function ToggleLuaConsole()
    Global.GGUIMgr:ToggleLuaConsole()
end

function ShowReporter()
    Global.GGUIMgr:ShowReporter()
end

function SetTutorialDebugId(debugId)
    Tutorial.SetDebugId(debugId)
end

function SetTutorialDebug(flag)
    Tutorial.SetDebug(flag)
end

function SetTutorialAuto(auto)
    Tutorial.SetAuto(auto)
end

function SetBullet(bullet)
    SceneManager.instance.gScRoots:GetBattle():SetBullet(bullet)
end

function SetEnergy(energy)
    SceneManager.instance.gScRoots:GetBattle():SetEnergy(energy)
end

function SetMaxPopulation(population)
    SceneManager.instance.gScRoots:GetBattle():SetMaxPopulation(population)
end

function SetInvincible(teamIndex, invisible)
    SceneManager.instance.gScRoots:GetBattle():SetInvincible(teamIndex, invisible)
end

function Win(star)
    InGameUI.Win(star)
end

function SetNoCooldown()
    SceneManager.instance.gScRoots:GetBattle():SetNoCooldown()
end

function OpenPVP()
    PVPUI.Show()
end

function OpenAccount()
    account.Show()
end

function OpenOptions()
    options.Show()
end

function SetLanguage(tag,language_name , language_code)
    if Global.GTextMgr.currentLanguage == tag then
        return
    end
	MessageBox.Show(String.Format(Global.GTextMgr:GetText("setting_change_language"),Global.GTextMgr:GetText(language_name)),
		function()
			--[[
            local option = Global.GGameSetting.instance.option
            option.mLanguage = tostring(tag)
            Global.GGameSetting.instance.option = option
            Global.GGameSetting.instance:SaveOption()
            Global.GTextMgr:LoadLanguage(tag)
            --]]
			NotifySettingData.RequestNoticeLanguage(language_code , GameStateLogin.Instance:SettingAccountLogout(tostring(tag)))
            
        end,
		function()
		end,
		Global.GTextMgr:GetText("common_hint1"),
		Global.GTextMgr:GetText("common_hint2"))
end

function TagCurLanguage(tagmap)    
    local m ={"CN","EN","FR","SP","PT","IT","GM","RU","JP","KR","TCN"};
    local index = -1
    local str = tostring(Global.GTextMgr.currentLanguage)
    for i=1,#(m) do
        if str == m[i] then 
            index = i
            break
        end
    end
    if index>=1 then
        setting.EnableIndex = tagmap[index]
    end
end

function ShowFeedBack()
    feedback.Show()
end

function FinishAllTutorial()
    Tutorial.FinishAll()
end

function MakeTokenBroken()
	Global.GGUIMgr:MakeTokenBroken()
end

function ShowRank()
	setting.Hide()
	rank.Show()
end

function StartPVEBattle(teamType, battleId)
    SelectArmy.StartPVEBattle(battleId, teamType)
end

function ExportWorldMapBlock()
    local GOVERNMENT_START_X = 251
    local GOVERNMENT_START_Y = 251
    local GOVERNMENT_WIDTH = 9
    local GOVERNMENT_HEIGHT = 9
    local mapMgr = UnityEngine.GameObject.Find("3DTerrain(Clone)"):GetComponent("WorldMapMgr")
    local bigMapData = MapMsg_pb.BigMapData()
    for x = 0, 511 do
        for y = 0, 511 do
            if (x >= GOVERNMENT_START_X and x < GOVERNMENT_START_X + GOVERNMENT_WIDTH and y >= GOVERNMENT_START_Y and y < GOVERNMENT_START_Y + GOVERNMENT_HEIGHT)
                or x == 0 or y == 0 or x == 511 or y == 511
                or mapMgr:GetSprite(x, y) ~= 0 then
                local block = bigMapData.blocks:add()
                block.x = x
                block.y = y
            end
        end
    end
    local file = io.open("..\\..\\..\\project\\map\\blocks.data", "wb")
    file:write(bigMapData:SerializeToString())
    file:close()
end

function SaveMailBattleReport(path, index)
    Global.SaveMailBattleReport(index, path ..".bytes")
end

function PlayBattleReport(path)
    Global.PlayBattleReport(path .. ".bytes")
end

function ToggleEnableNetworkLog()
    Main.Instance:ToggleEnableNetworkLog()
end

function ResetNetworkLog()
    Main.Instance:ResetNetworkLog()
end

function ToggleShowNetworkLog()
    Main.Instance:ToggleShowNetworkLog()
end

function SetNetworkDelay(delay)
    Main.Instance:SetNetworkDelay(delay)
end

function TestText()
    TextUtil.Test()
end

function PlayPVP4PVE(battleid)
    BattleMove.Show4PVE(battleid)
end

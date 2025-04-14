module("SceneStory", package.seeall)
local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local SetClickCallback = UIUtil.SetClickCallback
local SetPressCallback = UIUtil.SetPressCallback
local GameTime = Serclimax.GameTime
local DebugPrint = Global.DebugPrint

currentStoryId = nil
currentStorySubId = 1
currentStory = nil
currentStoryCoroutine = nil
sceneStoryList = nil

local function WaitCommand(command, param)
    repeat
        local retCommand, retParam = coroutine.yield()
        print("检测剧情脚本:", retCommand, retParam)
    until retCommand == command and retParam == param
end

function ActivateStory(storyId)
    ConfigData.SetSceneStoryConfig(storyId)
end

function StartStory(storyId, storySubId)
    currentStoryId = storyId
    currentStorySubId = storySubId or 1
    currentStoryCoroutine = coroutine.start(function()
        for i = currentStorySubId, #sceneStoryList[currentStoryId] do
            currentStory = sceneStoryList[currentStoryId][i]
            local command = currentStory.command
            local param = currentStory.param
            print("执行剧情脚本:", currentStoryId, i, command, param)
            if command == "WaitLevel" then
                if not ChapterListData.HasLevelExplored(tonumber(param)) then
                    WaitCommand(command, tonumber(param))
                end
            elseif command == "WaitMainCity" then
                local topMenu = GUIMgr:GetTopMenuOnRoot()
                if topMenu == nil or topMenu.name ~= "MainCityUI" then
                    WaitCommand(command, param)
                end
            elseif command == "ShowTutorial" then
                Tutorial.TriggerModule(tonumber(param))
            elseif command == "WaitFinishTutorial" then
                WaitCommand(command, tonumber(param))
            elseif command == "DisableUI" then
                Global.ShowTopMask(tonumber(param))
            elseif command == "MoveToLand" then
                maincity.SetTargetBuild(tonumber(param), true, 1, false, true)
            elseif command == "WaitCamera" then
                WaitCommand(command, param)
            elseif command == "WaitBuilding" then
                WaitCommand(command, tonumber(param))
            elseif command == "ActivateStory" then
                ActivateStory(tonumber(param))
            elseif command == "StartStory" then
                StartStory(tonumber(param))
            elseif command == "Wait" then
                coroutine.wait(tonumber(param))
            else
                error("未定义的剧情脚本命令:" .. command)
            end
        end
    end)
end

function ResumeStory(command, ...)
    if currentStoryCoroutine ~= nil then
        if not coroutine.resume(currentStoryCoroutine, command, ...) then
            currentStoryCoroutine = nil
        end
    end
end

function Init()
    sceneStoryList = {}
    for _, v in pairs(tableData_tSceneStory.data) do
        local storyId = math.floor(v.id / 100)
        local storySubId = v.id % 100
        if sceneStoryList[storyId] == nil then
            sceneStoryList[storyId] = {}
        end
        sceneStoryList[storyId][storySubId] = v
    end
    if true then
        return
    end
    local sceneStoryConfig = ConfigData.GetSceneStoryConfig()
    if sceneStoryConfig == nil or sceneStoryConfig == 0 then
        StartStory(2)
    else
        StartStory(sceneStoryConfig)
    end
end

module("GrowGuide", package.seeall)
local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local SetClickCallback = UIUtil.SetClickCallback
local Format = System.String.Format
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameTime = Serclimax.GameTime

local _ui

local tutorialCoroutine
local waitCommand
local tutorialDataList
local waitTimer
local targetTransform
local closecallback
local isbrake
local strong
local px, py

function SetShowPos(x, y)
    px = x
    py = y
end

function LoadData()
    if tutorialDataList == nil then
        tutorialDataList = {}
        local list = TableMgr:GetMissionTutorialList()
		if #list > 0 then
			for i , v in pairs(list) do
				local data = list[i]
				tutorialDataList[data.id] = data
			end
		end
        --[[for i = 1, list.Length do
            local data = list[i - 1]
            tutorialDataList[data.id] = data
        end]]
    end
end

function Hide()
    Global.CloseUI(_M)
    print("close GrowGuide")
    strong = nil
    px = nil
    py = nil
    if closecallback ~= nil then
	    closecallback(isbrake)
    end
end

function WaitPress(menuName, buttonPath)
end

function WaitClose(menuName)
end

local function TutorialLoop(startId)
    local dataId = startId
    local data = tutorialDataList[tonumber(v)]

    local callResult
    local callFunc
    local compareResult
    while true do
        local data = tutorialDataList[dataId]
        if data == nil then
            break
        end

        local command = data.command
        local param = data.param

        print(string.format("execute command id: %d command: %s param: %s", data.id, command, param))
        if command == "JE" then
            if compareResult == 0 then
                dataId = tonumber(param)
            else
                dataId = dataId + 1
            end
        elseif command == "JE" then
            if compareResult == 0 then
                dataId = tonumber(param)
            else
                dataId = dataId + 1
            end
        elseif command == "JNE" then
            if compareResult ~= 0 then
                dataId = tonumber(param)
            else
                dataId = dataId + 1
            end
        elseif command == "JMP" then
            dataId = tonumber(param)
        else
            if command == "CALL" then
                callFunc = loadstring("return " .. param)
                callResult = callFunc()
            elseif command == "EXIT" then
                break
            elseif command == "WAIT_PRESS" then
                if callResult == nil or not callResult.activeSelf then
                    waitTimer = 5
                    repeat
                        local deltaTime = coroutine.yield(command)
                        waitTimer = waitTimer - deltaTime
                        callResult = callFunc()
                        if waitTimer <= 0 then
                            print("can not find press target", data.id, param)
                            break
                        end
                    until callResult ~= nil and not callResult.activeSelf
                end
                print("wait press:", callResult.name)

                _ui.pointerTransform.gameObject:SetActive(true)
                
                targetTransform = callResult.transform
                if coroutine.yield(command) ~= callResult then
                    break
                end
                _ui.pointerTransform.gameObject:SetActive(false)
                print('wait pressed return##########')
            elseif command == "WAIT_CLOSE" then
                while coroutine.yield(command) ~= param do
                end
                print('wait close return##########')
            elseif command == "WAIT_TIME" then
                waitTimer = tonumber(param)
                while waitTimer > 0 do
                    waitTimer = waitTimer - coroutine.yield(command)
                end
                print('wait time return##########')
            elseif command == "WAIT_OPEN" then
                while coroutine.yield(command) ~= param do
                end
            elseif command == "WAIT_LAND" then
                if coroutine.yield(command) ~= param then
                    break
                end
            elseif command == "WAIT_CITY_MENU" then
                if coroutine.yield(command) ~= param then
                    break
                end
            elseif command == "CMP" then
                if tostring(callResult) == param then
                    compareResult = 0
                else
                    local n1 = tonumber(callResult)
                    local n2 = tonumber(param)
                    if n1 ~= nil and n2 ~= nil then
                        if n1 > n2 then
                            compareResult = 1
                        else
                            compareResult = -1
                        end
                    else
                        compareResult = 1
                    end
                end
            end
            dataId = dataId + 1
        end
    end

    print("no more command")
    Hide()
end

local function OnMenuOpen(menuName)
    if waitCommand == "WAIT_OPEN" then
        _, waitCommand = coroutine.resume(tutorialCoroutine, menuName)
    end
end

local function OnMenuClose(menuName)
    if waitCommand == "WAIT_CLOSE" then
        _, waitCommand = coroutine.resume(tutorialCoroutine, menuName)
    end
end

local function OnUICameraPress(go, pressed)
    if not pressed then
        --[[
        if waitCommand == "WAIT_PRESS" then
            _, waitCommand = coroutine.resume(tutorialCoroutine, go)
        end
        --]]
        if strong then
            if _ui.pointerTransform == go.transform then
                if targetTransform ~= nil and not targetTransform:Equals(nil) then
                    targetTransform.gameObject:SendMessage("OnClick")
                end
                isbrake = false
                Hide()
            else
                _ui.effecttime = 2
                _ui.effect.gameObject:SetActive(false)
            end
        else
            isbrake = targetTransform ~= go.transform
            Hide()
        end
    end
end

local function OnLocateLand(landName)
    print("OnLocateLand", landName)
    if waitCommand == "WAIT_LAND" then
        _, waitCommand = coroutine.resume(tutorialCoroutine, landName)
    end
end

local function OnCityMenu(landName)
    print("OnCityMenu:", landName)
    if waitCommand == "WAIT_CITY_MENU" then
        _, waitCommand = coroutine.resume(tutorialCoroutine, landName)
    end
end

function Update()
    if waitTimer ~= nil and waitTimer > 0 then
        _, waitCommand = coroutine.resume(tutorialCoroutine, GameTime.deltaTime)
    end
    if targetTransform ~= nil and not targetTransform:Equals(nil) then
        if px == nil and py == nil then
            NGUIMath.OverlayPosition(_ui.pointerTransform, targetTransform)
        else
            _ui.pointerTransform.localPosition = Vector3(0, 0, 0)
        end
        local localPosition = _ui.pointerTransform.localPosition
        _ui.pointerTransform.localPosition = Vector3(localPosition.x, localPosition.y, 0)
        if strong then
            _ui.transtime = _ui.transtime + GameTime.deltaTime
            _ui.hand.localPosition = Vector3(Mathf.Lerp(-localPosition.x + _ui.handlocal.x, _ui.handlocal.x, _ui.transtime), Mathf.Lerp(-localPosition.y + _ui.handlocal.y, _ui.handlocal.y, _ui.transtime), 0)
            if _ui.effecttime ~= nil then
                _ui.effecttime = _ui.effecttime - GameTime.deltaTime
                _ui.effect.gameObject:SetActive(_ui.effecttime > 0)
            end
        end
    end
end

function Awake()
    _ui = {}
    _ui.pointerTransform = transform:Find("Container/hand widget")
    _ui.quan = transform:Find("Container/hand widget/zhiyinquan/quan")
    _ui.effect = transform:Find("Container/hand widget/zhiyinquan/zhiyinjiantou")
    _ui.hand = transform:Find("Container/hand widget/zhiyinquan/hand")
    _ui.handlocal = _ui.hand.localPosition
    --_ui.pointerTransform.gameObject:SetActive(false)
    AddDelegate(UICamera, "onPress", OnUICameraPress)
    --[[
    AddDelegate(GUIMgr, "onMenuOpen", OnMenuOpen)
    AddDelegate(GUIMgr, "onMenuClose", OnMenuClose)
    maincity.AddLocateLandListener(OnLocateLand)
    MainCityUI.AddCityMenuListener(OnCityMenu)
    --]]
    if strong then
        transform:Find("Container/mask"):GetComponent("BoxCollider").enabled = true
        NGUITools.AddWidgetCollider(_ui.pointerTransform.gameObject)
        _ui.quan.gameObject:SetActive(true)
        _ui.effect.gameObject:SetActive(false)
        _ui.hand.position = Vector3.zero
        _ui.hand.gameObject:SetActive(true)
    end
    _ui.transtime = 0
end

function Close()
    _ui = nil
    RemoveDelegate(UICamera, "onPress", OnUICameraPress)
    --[[
    RemoveDelegate(GUIMgr, "onMenuOpen", OnMenuOpen)
    RemoveDelegate(GUIMgr, "onMenuClose", OnMenuClose)
    maincity.RemoveLocateLandListener(OnLocateLand)
    MainCityUI.RemoveCityMenuListener(OnCityMenu)
    --]]
end

function Show(_targetTransform, callback, isstrong)
    strong = isstrong
	closecallback = callback
    LoadData()
    Global.OpenTopUI(_M)
    targetTransform = _targetTransform
    --[[
    tutorialCoroutine = coroutine.create(TutorialLoop)
    _, waitCommand = coroutine.resume(tutorialCoroutine, startId)
    --]]
end

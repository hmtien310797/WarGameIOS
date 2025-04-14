local FOCUS_SPEED = 2.5 --聚焦速度(时间的倒数)
local MIN_HEIGHT = 40 --聚焦最低高度
local FOCUS_DISTANCE = 80 --聚焦距离
local FOCUS_OFFSET = 15 -- 聚焦偏移

local FOLLOW_TIME = 0.5 --平移时间
local RECOVER_SPEED = 3 --恢复速度(时间的倒数)
local RECOVER_DISTANCE = 90 --恢复后的距离 

SMOOTH_TIME = 0.3

local Mathf = Mathf
local math = math
local GameTime = Serclimax.GameTime

local STATE_NORMAL = 0
local STATE_FOCUS = 1
local STATE_IDLE = 2
local STATE_FOLLOW = 3
local STATE_RECOVER = 4
local STATE_MOVE_TO = 5
local STATE_DAMP_MOVE = 6

class "CityCamera"
{

}

function CityCamera:__init__(camera, minX, maxX, minY, maxY, minZ, maxZ)
    local transform = camera.transform
    self.camera = camera
    self.transform = transform
    self.gameObject = transform.gameObject

    self.minX = minX
    self.maxX = maxX
    self.minY = minY
    self.maxY = maxY
    self.minZ = minZ
    self.maxZ = maxZ
    self.state = STATE_NORMAL
    self.defaultForward = self.transform.forward
    self.forwardProject = self.defaultForward:ProjectOnPlane(Vector3.up)
    self.followSpeed = 0
    self.autoMode = false
    self.dampSpeed = Vector3.zero
end

function CityCamera:Move(deltaRight, deltaForward)
    if self.autoMode then
        return
    end

    if self.state == STATE_NORMAL then
        local position = self.transform.position
        local x = Mathf.Clamp(position.x + deltaRight, self.minX, self.maxX)
        local z = Mathf.Clamp(position.z + deltaForward, self.minZ, self.maxZ)
        self.transform.position = Vector3(x, position.y, z)
    elseif self.state == STATE_MOVE_TO then
        self.state = STATE_NORMAL
    elseif self.state == STATE_DAMP_MOVE then
        self.state = STATE_NORMAL
    elseif self.state ~= STATE_RECOVER then
        self:Recover()
    end
end

function CityCamera:Zoom(delta)
    if self.autoMode then
        return
    end

    if self.state == STATE_NORMAL then
        local y = self.transform.localPosition.y
        if (delta > 0 and y > self.minY) or (delta < 0 and y < self.maxY) then
            self.transform:Translate(0, 0, delta)
            local position = self.transform.position
            local x = Mathf.Clamp(position.x, self.minX, self.maxX)
            local z = Mathf.Clamp(position.z, self.minZ, self.maxZ)
            self.transform.position = Vector3(x, position.y, z)
        end
    elseif self.state == STATE_MOVE_TO then
        self.state = STATE_NORMAL
    elseif self.state == STATE_DAMP_MOVE then
        self.state = STATE_NORMAL
    elseif self.state ~= STATE_RECOVER then
        self:Recover()
    end
end

function CityCamera:FocusTarget(targetPosition)
    self.state = STATE_FOCUS
    self.targetPosition = targetPosition
    self.focusStartPosition = self.transform.position
    self.lastFocusPosition = self.transform.position + self.transform.forward * self.transform.position.y / Vector3.Dot(self.transform.forward, Vector3.down)
    self.focusStartTime = GameTime.time
end

function CityCamera:FollowTarget(targetPosition)
    self.state = STATE_FOLLOW
    self.targetPosition = targetPosition
    local followStartPosition = self.transform.position
    local followEndPosition = self.targetPosition - self.transform.forward * FOCUS_DISTANCE
    self.followSpeed = (followEndPosition - followStartPosition).magnitude / FOLLOW_TIME 
end

function CityCamera:Recover()
    if self.state ~= STATE_RECOVER and self.state ~= STATE_NORMAL then
        self.state = STATE_RECOVER
        self.recoverStartPosition = self.transform.position
        self.lastFocusPosition = self.transform.position + self.transform.forward * self.transform.position.y / Vector3.Dot(self.transform.forward, Vector3.down)
        self.recoverStartTime = GameTime.time
    end
end

function CityCamera:MoveTo(targetPosition)
    self.state = STATE_MOVE_TO
    self.targetPosition = targetPosition
    self.targetDistance = (self.transform.position.y - targetPosition.y) / Vector3.Dot(self.transform.forward, Vector3.down)
    local moveStartPosition = self.transform.position
    local moveEndPosition = self.targetPosition - self.transform.forward * self.targetDistance
    self.moveSpeed = (moveEndPosition - moveStartPosition).magnitude / FOLLOW_TIME 
end

function CityCamera:SetTargetPosition(targetPosition, moveTo, autoMode)
    assert(targetPosition ~= nil, "targetPosition is nil")
    targetPosition = targetPosition + self.forwardProject * FOCUS_OFFSET
    targetPosition.y = 0
    if self.state == STATE_NORMAL or self.state == STATE_DAMP_MOVE then
        if moveTo then
            self:MoveTo(targetPosition)
        else
            self:FocusTarget(targetPosition)
        end
    elseif self.state == STATE_FOLLOW or self.state == STATE_IDLE then
        self:FollowTarget(targetPosition)
    end
    self.autoMode = autoMode
end

function CityCamera:DampMove(moveSpeedRight, moveSpeedForward)
    if self.state == STATE_NORMAL then
        self.dampStartTime = GameTime.time
        self.dampSpeed = Vector3(moveSpeedRight, moveSpeedForward)
        self.state = STATE_DAMP_MOVE
        local position = self.transform.position
        self.targetPosition = Vector3(position.x + moveSpeedRight * SMOOTH_TIME, position.y, position.z + moveSpeedForward * SMOOTH_TIME)
    end
end

function CityCamera:SetArriveTargetCallback(callback)
    self.arriveTargetCallback = callback
end

function CityCamera:Update()
    if self.state ~= STATE_NORMAL then
        if self.state == STATE_FOCUS then
            local focusTime = (GameTime.time - self.focusStartTime) * FOCUS_SPEED

            local focusEndPosition = self.targetPosition - self.transform.forward * FOCUS_DISTANCE
            focusEndPosition.y = MIN_HEIGHT
            self.transform.position = Vector3.Lerp(self.focusStartPosition, focusEndPosition, focusTime)
            self.transform:LookAt(Vector3.Lerp(self.lastFocusPosition, self.targetPosition, focusTime))
            if focusTime >= 1 then
                self.state = STATE_IDLE
                self.autoMode = false
                if self.arriveTargetCallback ~= nil then
                    self.arriveTargetCallback()
                end
            end
        elseif self.state == STATE_FOLLOW then
            local followEndPosition = self.targetPosition - self.transform.forward * FOCUS_DISTANCE
            self.transform.position = Vector3.MoveTowards(self.transform.position, followEndPosition, self.followSpeed * GameTime.deltaTime)
            if (self.transform.position - followEndPosition).sqrMagnitude < 0.01 then
                self.state = STATE_IDLE
                self.autoMode = false
                if self.arriveTargetCallback ~= nil then
                    self.arriveTargetCallback()
                end
            end
        elseif self.state == STATE_MOVE_TO then
            local moveEndPosition = self.targetPosition - self.transform.forward * self.targetDistance
            self.transform.position = Vector3.MoveTowards(self.transform.position, moveEndPosition, self.moveSpeed * GameTime.deltaTime)
            if (self.transform.position - moveEndPosition).sqrMagnitude < 0.01 then
                self.state = STATE_IDLE
                self.autoMode = false
                if self.arriveTargetCallback ~= nil then
                    self.arriveTargetCallback()
                end
            end
        elseif self.state == STATE_RECOVER then
            local recoverTime = (GameTime.time - self.recoverStartTime) * RECOVER_SPEED
            local recoverEndPosition = self.lastFocusPosition - self.defaultForward * RECOVER_DISTANCE
            self.transform.position = Vector3.Lerp(self.recoverStartPosition, recoverEndPosition, recoverTime)
            self.transform:LookAt(self.lastFocusPosition)
            if recoverTime >= 1 then
                self.state = STATE_NORMAL
                self.autoMode = false
            end
        elseif self.state == STATE_DAMP_MOVE then
            local position, dampSpeed = Vector3.SmoothDamp(self.transform.position, self.targetPosition, self.dampSpeed, SMOOTH_TIME)
            self.transform.position = Vector3(Mathf.Clamp(position.x, self.minX, self.maxX), self.transform.position.y, Mathf.Clamp(position.z, self.minZ, self.maxZ))
            self.dampSpeed = dampSpeed
            if GameTime.time - self.dampStartTime > SMOOTH_TIME then
                self.state = STATE_NORMAL
            end
        end
    end
end

function CityCamera:IsMoving()
    local state = self.state
    return state == STATE_MOVE_TO or state == STATE_FOCUS or state == STATE_FOLLOW or state == STATE_RECOVER
end

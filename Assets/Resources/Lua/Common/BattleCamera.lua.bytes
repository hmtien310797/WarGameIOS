local Mathf = Mathf
local math = math
local GameTime = Serclimax.GameTime
class "BattleCamera"
{
}

function BattleCamera:__init__(camera, minX, maxX, minY, maxY, minZ, maxZ)
    self.sceneManager = SceneManager.instance
    
    local transform = camera.transform
    local defaultPosition = transform.position
    local right = Vector3.ProjectOnPlane(transform.right, Vector3.up).normalized
    local forward = Vector3.ProjectOnPlane(transform.up, Vector3.up).normalized
    local localPosition = transform.localPosition

    self.camera = camera
    self.transform = transform
    self.defaultPosition = defaultPosition
    self.right = right
    self.forward = forward
    self.secForward = 1 / Vector3.Dot(transform.up, forward)

    self.minRightOffset = Vector3.Dot(Vector3(defaultPosition.x - minX, 0, 0), right)
    self.maxRightOffset = Vector3.Dot(Vector3(defaultPosition.x - maxX, 0, 0), right)
    self.minForwardOffset = Vector3.Dot(Vector3(0, 0, defaultPosition.z - minZ), forward)
    self.maxForwardOffset = Vector3.Dot(Vector3(0, 0, defaultPosition.z - maxZ), forward)

    local cosForwardDown = Vector3.Dot(transform.forward, Vector3.down)
    self.minZoom = (localPosition.y - maxY) / cosForwardDown
    self.maxZoom = (localPosition.y - minY) / cosForwardDown

    self.rightOffset = 0
    self.forwardOffset = 0
    self.zoom = 0

    self.halfFovTan = math.tan(camera.fieldOfView * 0.5 * Mathf.Deg2Rad)
    self.aspect = camera.aspect

    self.groundPlane = Plane.New(Vector3.up, 0)
    self.zoomChanged = true
    self.followTimer = 0
    self.followTime = 0.5
    self.enabled = true
    self.followCallback = nil
	self.isRightMax = false
	self.isRightMin = true
	
end

function BattleCamera:UpdatePos()
    local attackDir = {}
    attackDir.x = 1
    if self.scUnitMgr == nil and self.sceneManager.gScRoots ~= nil then
        self.scUnitMgr = self.sceneManager.gScRoots:GetUnitMgr()
    end    
    if self.scUnitMgr ~= nil then
        attackDir = self.scUnitMgr:GetAttackDirection(0)
    end

    local upDelta = self.halfFovTan * self.zoom
    local rightDelta = upDelta * self.aspect
    local minRightOffset = self.minRightOffset - rightDelta
    local maxRightOffset = self.maxRightOffset + rightDelta
    if self.zoomChanged then
        local forwardRay = Ray(self.forward, self.transform.position)
        local _, groundDistance = self.groundPlane:Raycast(forwardRay)
        self.groundDistance = groundDistance
        local rightCenter
        if attackDir.x>0 then
            rightCenter = self.camera:ViewportToWorldPoint(Vector3(0, 0.5, groundDistance))
        else
            rightCenter = self.camera:ViewportToWorldPoint(Vector3(1, 0.5, groundDistance))
        end
        local halfGroundLength = Vector3.Dot((rightCenter - self.transform.position), self.right)
        self.halfGroundLength = halfGroundLength
    end
    if self.fireLineLimit ~= nil then
        local fireLineLimitOffset = Vector3.Dot(Vector3(self.defaultPosition.x - self.fireLineLimit.x, 0, 0), self.right*-1*attackDir.x) 
        fireLineLimitOffset = fireLineLimitOffset + self.halfGroundLength
        if attackDir.x>0 then
            if minRightOffset > maxRightOffset then
                local temp = minRightOffset
                minRightOffset = maxRightOffset
                maxRightOffset = temp
            end

            maxRightOffset = math.max(fireLineLimitOffset, maxRightOffset)
        else
            minRightOffset = math.max(fireLineLimitOffset, minRightOffset)
        end
        
    end
	
    if minRightOffset > maxRightOffset then
        minRightOffset = maxRightOffset
    end
	
    self.rightOffset = Mathf.Clamp(self.rightOffset, minRightOffset, maxRightOffset)
    local minForwardOffset = self.minForwardOffset - upDelta * self.secForward
    local maxForwardOffset = self.maxForwardOffset + upDelta * self.secForward
    if minForwardOffset > maxForwardOffset then
        minForwardOffset = maxForwardOffset
    end

	self.isRightMax = self.rightOffset == maxRightOffset
	self.isRightMin = self.rightOffset == minRightOffset
	
    self.forwardOffset = Mathf.Clamp(self.forwardOffset, minForwardOffset, maxForwardOffset)
    self.transform.position = self.defaultPosition - self.forward * self.forwardOffset -  self.right * self.rightOffset + self.transform.forward * self.zoom
    self.zoomChanged = false
end

function BattleCamera:IsMaxRight()
	return self.isRightMax
end

function BattleCamera:IsMinRight()
	return self.isRightMin
end

function BattleCamera:Move(deltaRight, deltaForward)
    if SceneManager.instance.isScreenLock == false then
        self.rightOffset = self.rightOffset + deltaRight
        self.forwardOffset = self.forwardOffset + deltaForward
        self.followPosition = nil
    end
end

function BattleCamera:Zoom(delta)
    self.zoom = Mathf.Clamp(self.zoom + delta, self.minZoom, self.maxZoom)
    self.zoomChanged = true
    self.followPosition = nil
end

function BattleCamera:SetFollowPosition(followPosition)
    if followPosition ~= nil and self.followPosition == nil then
        self.currentVelocity = Vector3.zero
    end
    self.followPosition = followPosition
    if self.followPosition ~= nil then
        self.followTimer = self.followTime
        self.followPosition.y = 0
        local forwardRay = Ray(self.transform.forward, self.transform.position)
        local _, forwardDistance = self.groundPlane:Raycast(forwardRay)
        local forwardPos = forwardRay:GetPoint(forwardDistance)
        self.targetPosition = self.followPosition - forwardRay.direction * forwardDistance
        --self.followSpeed = (self.targetPosition - self.transform.position).magnitude / self.followTime
    end
end

function BattleCamera:SetFireLineLimit(fireLineLimit)
    self.fireLineLimit = fireLineLimit
end

function BattleCamera:SetFollowTime(followTime)
    self.followTime = followTime
end

function BattleCamera:SetFollowCallback(callback)
    self.followCallback = callback
end

function BattleCamera:UpdateFollow()
    if self.followPosition  ~= nil then
        local cameraPos, currentVelocity = Vector3.SmoothDamp(self.transform.position, self.targetPosition, self.currentVelocity, self.followTime)
        --local cameraPos = Vector3.MoveTowards(self.transform.position, self.targetPosition, self.followSpeed)
        local defaultPosition = self.defaultPosition
        self.currentVelocity = currentVelocity
       self.rightOffset = Vector3.Dot(defaultPosition + self.transform.forward * self.zoom - cameraPos, self.right)
       self.forwardOffset = Vector3.Dot(defaultPosition + self.transform.forward * self.zoom - cameraPos, self.forward)
    end
end

function BattleCamera:Update()
    if self.enabled then
        self:UpdateFollow()
        self:UpdatePos()
        if self.followTimer > 0 then
            self.followTimer = self.followTimer - GameTime.deltaTime
            if self.followTimer <= 0 then
                if self.followCallback ~= nil then
                    self.followCallback()
                end
            end
        end
    end
end

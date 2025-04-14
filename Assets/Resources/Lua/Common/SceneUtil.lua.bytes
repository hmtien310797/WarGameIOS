module("SceneUtil", package.seeall)
local UnityEngine = UnityEngine
local Raycast = UnityEngine.Physics.Raycast
local mainCamera = UnityEngine.Camera.main

function SceneUtil.GetPick(touchPos, layerMask)
	if touchPos == nil then
		return nil
	end
	local ray = camera:ScreenPointToRay(touchPos)
	local distance = mainCamera.farClipPlane - mainCamera.nearClipPlane
	local ret, hit = Raycast(ray, nil, distance, layerMask)
	if ret then
		return hit
	end
end

function SceneUtil.GetUIPick(layerMask)
	return SceneUtil.GetPick(UICamera.currentTouch.pos, layerMask)
end

function SceneUtil.IsPointVisibile(point)
	local viewportPoint = mainCamera:WorldToViewportPoint(point)
	return viewportPoint.x >= 0 and viewportPoint.x <= 1 and viewportPoint.y >= 0 and viewportPoint.y <= 1
end


local UIAnim = {}

function UIAnim:New(anim, clipName)
	local animCtrl = {anim = anim, animState = clipName and anim:get_Item(clipName) or anim:get_Item(anim.clip.name)}
	setmetatable(animCtrl, self)
	self.__index = self
	return animCtrl
end

function UIAnim:Play()
	self.animState.time = 0
	self.animState.speed = 1
	self.anim:Play(self.animState.name)
end

function UIAnim:Reset()
	self.animState.time = 0
	self.anim:Sample()
end

function UIAnim:Playback()
	self.animState.time = self.animState.length
	self.animState.speed = -1
	self.anim:Play(self.animState.name)
end

function UIAnim:Finish()
	if self.anim:IsPlaying(self.animState.name) then
		self.animState.time = self.animState.length
		self.anim:Sample()
	end
end
return UIAnim


module("MessageBox", package.seeall)
local GUIMgr = Global.GGUIMgr
local SetPressCallback = UIUtil.SetPressCallback
local TextMgr = Global.GTextMgr
local NGUITools = NGUITools

local defaultOkText
local defaultCancelText

local bg
local messageBoxOk = {}
local messageBoxCancel = {}
local messageBoxOkCancel = {}
local messageBoxGold = {}
local showing
local remberFunction
local okNow


local MessageRequest = {}

function MessageRequest:New()
	local req = {}
	setmetatable(req, self)
	self.__idnex = self
	return req
end

local msgReqList = {}

function GetMessageBox()
	return showing
end

function DoNothing()
	return
end

function SetRemberFunction(func)
	remberFunction = func
end

function SetOkNow()
	okNow = true
end



local function ShowFirst()
	CountDown.Instance:Remove("MBCountDown")
	if #msgReqList > 0 then
		local req = table.remove(msgReqList, 1)
		local messageBox = nil
		if req.okCallback ~= nil and req.cancelCallback ~= nil then
			messageBox = messageBoxOkCancel
			messageBox.okCallback = req.okCallback
			messageBox.cancelCallback = req.cancelCallback
			transform:Find("bg_okcancel/bg/bg_hint").gameObject:SetActive(remberFunction ~= nil)
			
		elseif req.okCallback ~= nil then
			messageBox = messageBoxOk
			messageBox.okCallback = req.okCallback
		elseif req.cancelCallback ~= nil then
			messageBox = messageBoxCancel
			messageBox.cancelCallback = req.cancelCallback
		else
			messageBox = messageBoxOk
			messageBox.okCallback = nil
		end
		
		if req.msg2 ~= nil then 
			messageBox = messageBoxGold
			messageBox.msg1.text = req.msg
			messageBox.msg2.text = req.msg2
			if req.msg3 ~= nil then
				if req.time ~= nil then
					CountDown.Instance:Add("MBCountDown",req.time, function(t)
						messageBox.msg3.text = System.String.Format(req.msg3, t)
						if t == "00:00:00" then
							CountDown.Instance:Remove("MBCountDown")
						end
					end)
				else
					messageBox.msg3.text = req.msg3
				end
			else
				messageBox.msg3.text = ""
			end
			messageBox.goldnum.text = req.goldnum
			messageBox.okCallback = req.okCallback
			messageBox.cancelCallback = req.cancelCallback
		else
			messageBox.msg.text = req.msg
			if req.time ~= nil then
				CountDown.Instance:Add("MBCountDown",req.time, function(t)
					messageBox.msg.text = System.String.Format(req.msg, t)
					if t == "00:00:00" then
						CountDown.Instance:Remove("MBCountDown")
					end
				end)
			end
		end
		
		
		bg:SetActive(true)
		messageBox.goBg:SetActive(true)
		messageBox.playTween = messageBox.goBg:GetComponent("UIPlayTween")
		messageBox.playTween:Play(true)
		if messageBox.okLabel ~= nil then
			messageBox.okLabel.text = req.okText or defaultOkText
        end
        if messageBox.cancelLabel ~= nil then
			messageBox.cancelLabel.text = req.cancelText or defaultCancelText
		end
		if messageBox.okSprite ~= nil and messageBox.okButton ~= nil then
			if req.okSpriteName ~= nil then
				messageBox.okSprite.spriteName = req.okSpriteName
				messageBox.okButton.normalSprite = req.okSpriteName
			else
				messageBox.okSprite.spriteName = messageBox.okDefaultSprite
				messageBox.okButton.normalSprite = messageBox.okDefaultSprite
			end
		end
		if messageBox.cancelSprite ~= nil and messageBox.cancelButton ~= nil then
			if req.cancelSpriteName ~= nil then
				messageBox.cancelSprite.spriteName = req.cancelSpriteName
				messageBox.cancelButton.normalSprite = req.cancelSpriteName
			else
				messageBox.cancelSprite.spriteName = messageBox.cancelDefaultSprite
				messageBox.cancelButton.normalSprite = messageBox.cancelDefaultSprite
			end
		end
		if req.canCloseOnBg then
			SetPressCallback(messageBox.goBg, function(go, isPressed)
				if not isPressed then
					bg:SetActive(false)
					messageBoxOkCancel.goBg:SetActive(false)
					ShowFirst()
				end
			end)
		else
			SetPressCallback(messageBox.goBg, nil)
		end
		showing = messageBox
		NGUITools.BringForward(bg)
	else
		showing = nil
	end
end


function SetCancelNow()
	if bg == nil then
		return
	end
	bg:SetActive(false)
	messageBoxCancel.goBg:SetActive(false)
	if messageBoxCancel.cancelCallback ~= nil then
		messageBoxCancel.cancelCallback()
	end
	ShowFirst()
end
-- 用于弹框确认某些信息
-- 流程：??? ---> 弹出条件(condition) ---True--> 需要确认，弹出MessageBox ---NOT OK--> cancelCallback
--                                    |                                   |            
--                                    |                                  OK
--                                    |                                  |        
--                                    *--False--> 不需要确认 ------------*--> Do Something (okCallback)
--                                                                               
function ShowConfirmation(condition, msg, okCallback, cancelCallback, okText, cancelText, okSpriteName, cancelSpriteName, canCloseOnBg)
	if condition then
		Show(msg, okCallback, cancelCallback or DoNothing, okText, cancelText, okSpriteName, cancelSpriteName, canCloseOnBg)
	elseif okCallback then
		okCallback()
	end
end

function ShowCountDownMsg(msg, time)
	Show(msg, nil, nil, nil, nil, nil, nil, nil, nil, nil, time)
end

function Show(msg, okCallback, cancelCallback, okText, cancelText, okSpriteName, cancelSpriteName, canCloseOnBg, msgGoldTip, numGold, time, msgGoldBottomTip)
	if defaultOkText == nil then
	    defaultOkText = TextMgr:GetText(Text.common_hint1)
	    defaultCancelText = TextMgr:GetText(Text.common_hint2)
    end

	if GUIMgr:FindMenu("MessageBox") == nil then
		GUIMgr:CreateMenu("MessageBox", true)
	end
	local req = MessageRequest:New()
	req.msg = msg
	if type(okCallback) == "userdata" then
		req.okCallback = function()
			okCallback:DynamicInvoke()
		end
	else
		req.okCallback = okCallback
	end
	if okNow then
		if req.okCallback then
			req.okCallback()
		end
		okNow = nil
		return
	end
	if type(cancelCallback) == "userdata" then
		req.cancelCallback = function()
			cancelCallback:DynamicInvoke()
		end
	else
		req.cancelCallback = cancelCallback
	end
	req.okText = okText
	req.cancelText = cancelText
	req.okSpriteName = okSpriteName
	req.cancelSpriteName = cancelSpriteName
	req.canCloseOnBg = canCloseOnBg
	req.msg2 = msgGoldTip
	req.msg3 = msgGoldBottomTip
	req.goldnum =numGold
	req.time = time
	table.insert(msgReqList, req)
	
	if showing == nil then
		ShowFirst()
	else 
		
	end
	return req
end

function Clear()
	if showing ~= nil then
		bg:SetActive(false)
		showing.goBg:SetActive(false)
	end
	msgReqList = {}
end

function Awake()
	bg = gameObject

	--有确定和取消的
	messageBoxOkCancel.goBg = transform:Find("bg_okcancel").gameObject
	messageBoxOkCancel.msg = transform:Find("bg_okcancel/bg/text"):GetComponent("UILabel")
	messageBoxOkCancel.okGameObject = transform:Find("bg_okcancel/bg/btn_confirm").gameObject
	messageBoxOkCancel.cancelGameObject = transform:Find("bg_okcancel/bg/btn_cancel").gameObject
	messageBoxOkCancel.okSprite = messageBoxOkCancel.okGameObject:GetComponent("UISprite")
	messageBoxOkCancel.okButton = messageBoxOkCancel.okGameObject:GetComponent("UIButton")
	messageBoxOkCancel.okDefaultSprite = messageBoxOkCancel.okSprite.spriteName
	messageBoxOkCancel.cancelSprite = messageBoxOkCancel.cancelGameObject:GetComponent("UISprite")
	messageBoxOkCancel.cancelButton = messageBoxOkCancel.cancelGameObject:GetComponent("UIButton")
	messageBoxOkCancel.cancelDefaultSprite = messageBoxOkCancel.cancelSprite.spriteName
	messageBoxOkCancel.okLabel = transform:Find(string.format("bg_okcancel/bg/btn_confirm/text_confirm")):GetComponent("UILabel")
	messageBoxOkCancel.cancelLabel = transform:Find(string.format("bg_okcancel/bg/btn_cancel/text_cancel")):GetComponent("UILabel")
	SetPressCallback(messageBoxOkCancel.okGameObject, function(go, isPressed)
		if not isPressed then
			bg:SetActive(false)
			messageBoxOkCancel.goBg:SetActive(false)
			if remberFunction ~= nil then
				remberFunction(transform:Find("bg_okcancel/bg/bg_hint/checkbox"):GetComponent("UIToggle").value)
				remberFunction = nil
			end
			if messageBoxOkCancel.okCallback ~= nil then
				messageBoxOkCancel.okCallback()
			end
			ShowFirst()
		end
	end)

	SetPressCallback(messageBoxOkCancel.cancelGameObject, function(go, isPressed)
		if not isPressed then
			bg:SetActive(false)
			messageBoxOkCancel.goBg:SetActive(false)
			if messageBoxOkCancel.cancelCallback ~= nil then
				messageBoxOkCancel.cancelCallback()
			end
			if remberFunction ~= nil then
				remberFunction = nil
			end
			ShowFirst()
		end
	end)

	--只有确定的
	messageBoxOk.goBg = transform:Find("bg_ok").gameObject
	messageBoxOk.msg = transform:Find("bg_ok/bg/text"):GetComponent("UILabel")
	messageBoxOk.okGameObject = transform:Find("bg_ok/bg/btn_confirm").gameObject
	messageBoxOk.okLabel = transform:Find(string.format("bg_ok/bg/btn_confirm/text_confirm")):GetComponent("UILabel")
	SetPressCallback(messageBoxOk.okGameObject, function(go, isPressed)
		if not isPressed then
			bg:SetActive(false)
			messageBoxOk.goBg:SetActive(false)
			if messageBoxOk.okCallback ~= nil then
				messageBoxOk.okCallback()
			end
			ShowFirst()
		end
	end)

	--只有取消的
	messageBoxCancel.goBg = transform:Find("bg_cancel").gameObject
	messageBoxCancel.msg = transform:Find("bg_cancel/bg/text"):GetComponent("UILabel")
	messageBoxCancel.cancelGameObject = transform:Find("bg_cancel/bg/btn_cancel").gameObject
	messageBoxCancel.cancelLabel = transform:Find(string.format("bg_cancel/bg/btn_cancel/text_cancel")):GetComponent("UILabel")
	SetPressCallback(messageBoxCancel.cancelGameObject, function(go, isPressed)
		if not isPressed then
			bg:SetActive(false)
			messageBoxCancel.goBg:SetActive(false)
			if messageBoxCancel.cancelCallback ~= nil then
				messageBoxCancel.cancelCallback()
			end
			ShowFirst()
		end
	end)
	
	--带图片的
	messageBoxGold.goBg = transform:Find("bg_gold").gameObject
	messageBoxGold.msg1 = transform:Find("bg_gold/bg/text1"):GetComponent("UILabel")
	messageBoxGold.msg2 = transform:Find("bg_gold/bg/text2"):GetComponent("UILabel")
	messageBoxGold.msg3 = transform:Find("bg_gold/bg/text3"):GetComponent("UILabel")
	messageBoxGold.goldnum = transform:Find("bg_gold/bg/gold/number"):GetComponent("UILabel")
	messageBoxGold.okGameObject = transform:Find("bg_gold/bg/btn_confirm").gameObject
	messageBoxGold.cancelGameObject = transform:Find("bg_gold/bg/btn_cancel").gameObject
	messageBoxGold.okSprite = messageBoxGold.okGameObject:GetComponent("UISprite")
	messageBoxGold.okButton = messageBoxGold.okGameObject:GetComponent("UIButton")
	messageBoxGold.okDefaultSprite = messageBoxGold.okSprite.spriteName
	messageBoxGold.cancelSprite = messageBoxGold.cancelGameObject:GetComponent("UISprite")
	messageBoxGold.cancelButton = messageBoxGold.cancelGameObject:GetComponent("UIButton")
	messageBoxGold.cancelDefaultSprite = messageBoxGold.cancelSprite.spriteName
	messageBoxGold.okLabel = transform:Find(string.format("bg_gold/bg/btn_confirm/text_confirm")):GetComponent("UILabel")
	messageBoxGold.cancelLabel = transform:Find(string.format("bg_gold/bg/btn_cancel/text_cancel")):GetComponent("UILabel")
	SetPressCallback(messageBoxGold.okGameObject, function(go, isPressed)
		if not isPressed then
			bg:SetActive(false)
			messageBoxGold.goBg:SetActive(false)
			if remberFunction ~= nil then
				remberFunction(transform:Find("bg_gold/bg/bg_hint/checkbox"):GetComponent("UIToggle").value)
				remberFunction = nil
			end
			if messageBoxGold.okCallback ~= nil then
				messageBoxGold.okCallback()
			end
			ShowFirst()
		end
	end)

	SetPressCallback(messageBoxGold.cancelGameObject, function(go, isPressed)
		if not isPressed then
			bg:SetActive(false)
			messageBoxGold.goBg:SetActive(false)
			if messageBoxGold.cancelCallback ~= nil then
				messageBoxGold.cancelCallback()
			end
			if remberFunction ~= nil then
				remberFunction = nil
			end
			ShowFirst()
		end
	end)

	messageBoxOkCancel.goBg:SetActive(false)
	messageBoxOk.goBg:SetActive(false)
	messageBoxCancel.goBg:SetActive(false)
	messageBoxGold.goBg:SetActive(false)
	bg:SetActive(false)
end

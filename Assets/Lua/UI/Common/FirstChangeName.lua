module("FirstChangeName", package.seeall)

local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr.Instance
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local SetClickCallback = UIUtil.SetClickCallback

local btnQuit
local ChangeNameUi
local nameInput
local texthint
local charLimit
local useCallBack
local randombtn
local closeCallback

function SetCallBack(ItemUseCount)
	useCallBack = ItemUseCount
end

--退出战斗按钮
local function ClosePressCallback(go, isPressed)
	if not isPressed then
		GUIMgr:CloseMenu("FirstChangeName")
	end
end

local function UpdateHint()
	local nameLen = Global.utfstrlen(nameInput.value)
	texthint.text = System.String.Format("剩余{0}个字符" , charLimit - nameLen)
end

local function ChangeNameFunc()

	local req = ClientMsg_pb.MsgCharacterRenameRequest()
	req.name = System.String(nameInput.value):Trim()
	--print("reqName:" .. req.name .. "--")
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCharacterRenameRequest, req, ClientMsg_pb.MsgCharacterRenameResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
			Global.ShowError(msg.code)
		else
			--AudioMgr:PlayUISfx("SFX_ui01", 1, false)
			FloatText.Show(TextMgr:GetText("player_ui11") , Color.green)
			MainCityUI.UpdateRewardData(msg.fresh)
			MainData.SetCharName(msg.charname)
			CountListData.SetCount(msg.count)
			
			GUIMgr:CloseMenu("FirstChangeName")
		end
	end)
end


local function SureChangeNameCallBack(go)
	
	--检查名字长度是否合法
	local nameLen = Global.utfstrlen(nameInput.value)
	if nameLen < 3 then
		if nameLen == 0 then
			FloatText.Show(TextMgr:GetText("player_ui15"), Color.white)
		else
			FloatText.Show(TextMgr:GetText("player_ui27"), Color.white)
		end 
		return
	end
	
	if nameLen  > 12 then
		FloatText.Show(TextMgr:GetText("player_ui12"), Color.white)
		return
	end

	--检查名字是否合法
	local nameLegalReq = ClientMsg_pb.MsgCheckNameExitRequest()
	nameLegalReq.name = nameInput.value
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCheckNameExitRequest, nameLegalReq, ClientMsg_pb.MsgCheckNameExitResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
			return
		else
			ChangeNameFunc()
		end
	end)
	
	
end



function Start()
	
end

function Awake()
	ChangeNameUi = transform:Find("first")
	
	
	
	local nameSure_btn = transform:Find("first/bg_frane/btn_confirm"):GetComponent("UIButton")
	SetClickCallback(nameSure_btn.gameObject, SureChangeNameCallBack)

	nameInput = transform:Find("first/bg_frane/frame_input"):GetComponent("UIInput")
	nameInput.value = MainData.GetCharName()
	EventDelegate.Set(nameInput.onChange , EventDelegate.Callback(function(go , value)
		--UpdateHint()
	end))
	
	local eff = transform:Find("first/bg_frane/shaizi"):GetComponent("Animator")
	local randombtn = transform:Find("first/bg_frane/random btn").gameObject
	SetClickCallback(randombtn, function()
		nameInput.value = TableMgr:GetRandomName()
		eff:SetTrigger("shaizi")
	end)
	nameInput.value = TableMgr:GetRandomName()
	charLimit = nameInput.characterLimit
end

function Close()
    useCallBack = nil

    if closeCallback then
    	closeCallback()
    end
    closeCallback = nil
end

function Show(_closeCallback)
	closeCallback = _closeCallback
    Global.OpenUI(_M)
end

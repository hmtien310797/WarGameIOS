module("ChangeName", package.seeall)

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

local initFunc
local cancelFunc
local sureFunc

local checkBoxTable = {}

local ChangeNameFunc
local function ChangeNameSureBox()
	local newPreview = TextMgr:GetText("player_ui13") .. nameInput.value
	local okCallback = function()
		local needItem = TableMgr:GetItemData(11101)--改名卡道具
		local myItem = ItemListData.GetItemDataByBaseId(needItem.id)
		local resText = TextMgr:GetText("player_ui11") .. ", " ..  TextMgr:GetText(needItem.name) .. "-1"
		ChangeNameFunc(nameInput.value , resText)
		MessageBox.Clear()
	end
	local cancelCallback = function()
		MessageBox.Clear()
	end
	MessageBox.Show(newPreview, okCallback, cancelCallback)
end

function SetCallBack(ItemUseCount)
	useCallBack = ItemUseCount
end

function Use()
	GUIMgr:CreateMenu("ChangeName" , false)
end
--退出战斗按钮
local function ClosePressCallback(go, isPressed)
	if not isPressed then
		GUIMgr:CloseMenu("MainInformation")
	end
end

local function UpdateHint()
	local nameLen = Global.utfstrlen(nameInput.value)
	texthint.text = System.String.Format("剩余{0}个字符" , charLimit - nameLen)
end

ChangeNameFunc = function(newName , resText)
	local req = ClientMsg_pb.MsgCharacterRenameRequest()
	req.name = System.String(newName):Trim()
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCharacterRenameRequest, req, ClientMsg_pb.MsgCharacterRenameResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
		else
		print("1231231")
			--local showText = TextMgr:GetText("player_ui11") .. ", " ..  TextMgr:GetText(needItem.name) .. "-1"
			AudioMgr:PlayUISfx("SFX_UI_props_use", 1, false)
			FloatText.Show(resText , Color.green)
			if useCallBack ~= nil then
				useCallBack(msg)
			end
			GUIMgr:CloseMenu("ChangeName")
			--MInfoUpdate()
		end
	end)
end


local function SureChangeNameCallBack(go)
	
	local needItem = TableMgr:GetItemData(11101)--改名卡道具
	local needItemEx = TableMgr:GetItemExchangeData(1)--改名卡兑换
	
	--检查名字长度是否合法
	local nameLen = Global.utfstrlen(nameInput.value)
	print("nameLen:" .. nameLen)
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

	--本地检查名字是否相同
	local nowName = MainData.GetCharName()
	if nowName == nameInput.value then
		FloatText.Show(TextMgr:GetText("player_ui17"), Color.white)
		return
	end
	--检查是否使用免费改名次数
	--[[local renameCount = CountListData.GetRenameCount()
	if renameCount.count > 0 then
		local resText = TextMgr:GetText("player_ui11", Color.white)
		ChangeName(nameInput.value , resText)
		return
	end]]
	
	--检查名字是否合法
	
	local nameLegalReq = ClientMsg_pb.MsgCheckNameExitRequest()
	nameLegalReq.name = nameInput.value
	Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgCheckNameExitRequest, nameLegalReq, ClientMsg_pb.MsgCheckNameExitResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
			return
		else
			--检查是否有改名卡，没有就提示使用金币改名
			local myItem = ItemListData.GetItemDataByBaseId(needItem.id)
			if myItem == nil then
				local newPreview = System.String.Format(TextMgr:GetText("player_ui14") , needItemEx.price)
				local okCallback = function()
					ChangeNameSureBox()
					--MessageBox.Clear()
				end
				local cancelCallback = function()
					MessageBox.Clear()
				end
				MessageBox.Show(newPreview, okCallback, cancelCallback)
			else
				ChangeNameSureBox()
			end
		end
	end)
end



function Start()
	
	if initFunc ~= nil then
		initFunc(transform)
	end
end

function Awake()
	ChangeNameUi = transform:Find("Container")
	
	local close_btn = transform:Find("Container/bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(close_btn.gameObject, function(go)
		GUIMgr:CloseMenu("ChangeName")
	end)
	
	SetClickCallback(ChangeNameUi.gameObject, function(go)
		GUIMgr:CloseMenu("ChangeName")
	end)
	
	local nameSure_btn = transform:Find("Container/bg_frane/btn_confirm"):GetComponent("UIButton")
	SetClickCallback(nameSure_btn.gameObject, function()
		if sureFunc ~= nil then
			sureFunc(nameInput.value)
		else
			SureChangeNameCallBack()
		end
	end)

	local nameCancel_btn = transform:Find("Container/bg_frane/btn_cancel"):GetComponent("UIButton")
	SetClickCallback(nameCancel_btn.gameObject, function(go)
		if cancelFunc ~= nil then
			cancelFunc()
		end
		GUIMgr:CloseMenu("ChangeName")
	end)
	
	nameInput = transform:Find("Container/bg_frane/frame_input"):GetComponent("UIInput")
	EventDelegate.Set(nameInput.onChange , EventDelegate.Callback(function(go , value)
		--UpdateHint()
	end))
	
	local randombtn = transform:Find("Container/bg_frane/random btn").gameObject
	local eff = transform:Find("Container/bg_frane/shaizi"):GetComponent("Animator")
	SetClickCallback(randombtn, function()
		nameInput.value = TableMgr:GetRandomName()
		eff:SetTrigger("shaizi")
	end)
	nameInput.value = TableMgr:GetRandomName()
	charLimit = nameInput.characterLimit
end

function SetFunc(init_func , cancel_func , sure_func)
	--data = _data
	initFunc = init_func
	cancelFunc = cancel_func
	sureFunc = sure_func
end

function Close()
    useCallBack = nil	
end
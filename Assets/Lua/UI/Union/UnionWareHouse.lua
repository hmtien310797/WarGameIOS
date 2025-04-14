module("UnionWareHouse", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback
local SetDragCallback = UIUtil.SetDragCallback
local GameObject = UnityEngine.GameObject

local UnionWareHouseUI
local UnionWareMsg
local UnionWareRequestItem
local reqResType
local reqResCount

function Hide()
    Global.CloseUI(_M)
end

local function CancelMyResRequest()
	local req = GuildMsg_pb.MsgCancelApplyGuildResRequest()
	Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgCancelApplyGuildResRequest, req, GuildMsg_pb.MsgCancelApplyGuildResResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			UnionResourceRequestData.RequestData()
			FloatText.Show(TextMgr:GetText("UnionWareHouse_ui21"))
			
        end
    end)
end

local function ApplyResRequest(charid , reqType)
	local req = GuildMsg_pb.MsgDealGuildResApplicationRequest()
	req.charId = charid
	req.type = reqType
	Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgDealGuildResApplicationRequest, req, GuildMsg_pb.MsgDealGuildResApplicationResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			--UnionWareHouseUI.SelectRes.gameObject:SetActive(false)
			--if MainData.GetCharId() == charid then
			UnionResourceRequestData.RequestData()
			--end
			
			FloatText.Show(TextMgr:GetText("UnionWareHouse_ui22") , Color.green)
        end
    end)
end

local function onClickInput()
	local indexType = reqResType - GuildMsg_pb.GuildResType_Food + 1
	local maxNum = math.min(1000000 , UnionWareMsg.resInfos[indexType].resNum)
	NumberInput.Show(reqResCount , 0 , maxNum , function(number)
		reqResCount = number
		UnionWareHouseUI.SelResInputLabel.text = reqResCount
		UnionWareHouseUI.SelResSlider.value = reqResCount / maxNum
	end)
end

local function OnClickAddBtn()
	local indexType = reqResType - GuildMsg_pb.GuildResType_Food + 1
	reqResCount = math.min(reqResCount + 1 , UnionWareMsg.resInfos[indexType].resNum)
	UnionWareHouseUI.SelResSlider.value = reqResCount / UnionWareMsg.resInfos[indexType].resNum
	
end

local function OnClickDelBtn()
	local indexType = reqResType - GuildMsg_pb.GuildResType_Food + 1
	reqResCount = math.max(reqResCount - 1 , 0)
	UnionWareHouseUI.SelResSlider.value = reqResCount / UnionWareMsg.resInfos[indexType].resNum
end

local function OnClickSure()
	print("req:" .. reqResType .. "  " .. reqResCount)
	if reqResCount <= 0 then
		FloatText.Show(TextMgr:GetText("UnionWareHouse_ui20") , Color.green)
		return
	end
	local req = GuildMsg_pb.MsgApplyGuildResRequest()
	req.resType = reqResType
	req.applyNum = reqResCount
	Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgApplyGuildResRequest, req, GuildMsg_pb.MsgApplyGuildResResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			UnionWareHouseUI.SelectRes.gameObject:SetActive(false)
			UnionResourceRequestData.RequestData()
			FloatText.Show(TextMgr:GetText("UnionWareHouse_ui23") , Color.green)
        end
    end)
end

local function OnSelResIconClick(resSelect)
	print("resSelect" .. resSelect)
	reqResType = resSelect
	reqResCount = 0
	UnionWareHouseUI.SelResSlider.value = 0
	UnionWareHouseUI.SelResInputLabel.text = reqResCount
	if UnionWareMsg.resInfos[reqResType - GuildMsg_pb.GuildResType_Food + 1].resNum > 0 then
		UnionWareHouseUI.SelResSliderBtn:GetComponent("BoxCollider").enabled = true
	else
		UnionWareHouseUI.SelResSliderBtn:GetComponent("BoxCollider").enabled = false
	end
end

local function HaveMyUnApplyRequest()
	for i=1 , #UnionWareMsg.resApplyInfos do
		if UnionWareMsg.resApplyInfos[i].charId == MainData.GetCharId() then
			return true
		end
	end
	
	return false
end

local function LoadRequestResUI()
	
	if HaveMyUnApplyRequest() then
		FloatText.Show(TextMgr:GetText("UnionWareHouse_ui24") , Color.red)
		return 
	end


	UnionWareHouseUI.SelectRes.gameObject:SetActive(true)
	UnionWareHouseUI.SelResIcon[GuildMsg_pb.GuildResType_Food]:GetComponent("UIToggle"):Set(true)
	
	reqResType = GuildMsg_pb.GuildResType_Food--默认粮食
	reqResCount = 0
	UnionWareHouseUI.SelResSlider.value = 0
	UnionWareHouseUI.SelResInputLabel.text = reqResCount
	if UnionWareMsg.resInfos[reqResType - GuildMsg_pb.GuildResType_Food + 1].resNum > 0 then
		UnionWareHouseUI.SelResSliderBtn:GetComponent("BoxCollider").enabled = true
	else
		UnionWareHouseUI.SelResSliderBtn:GetComponent("BoxCollider").enabled = false
	end
	
	--set number
	for i=GuildMsg_pb.GuildResType_Food , GuildMsg_pb.GuildResType_Elec do
		UnionWareHouseUI.SelResIcon[i]:Find("num"):GetComponent("UILabel").text = Global.ExchangeValue2(UnionWareMsg.resInfos[i - GuildMsg_pb.GuildResType_Food + 1].resNum)
	end
end

local function LoadTopResources()
	for i=1 , #UnionWareMsg.resInfos do 
		local res = UnionWareMsg.resInfos[i]
		if UnionWareHouseUI.topRes[res.resType] ~= nil then
			UnionWareHouseUI.topRes[res.resType].text = Global.ExchangeValue2(UnionWareMsg.resInfos[i].resNum)
		end
	end
end


local function LoadRequstList()
	local unionInfoMsg = UnionInfoData.GetData()
    local unionMsg = unionInfoMsg.guildInfo
    local memberMsg = unionInfoMsg.memberInfo
	local privilege = memberMsg.privilege 
	
	while UnionWareHouseUI.midGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(UnionWareHouseUI.midGrid.transform:GetChild(0).gameObject)
	end
	
	print(#UnionWareMsg.resApplyInfos)
	UnionWareHouseUI.Noitem.gameObject:SetActive(#UnionWareMsg.resApplyInfos <= 0)
	for i=1 , #UnionWareMsg.resApplyInfos do
		local info = nil
		local v = UnionWareMsg.resApplyInfos[i]
		info = NGUITools.AddChild(UnionWareHouseUI.midGrid.gameObject , UnionWareHouseUI.listItem.gameObject)
		info.transform:SetParent(UnionWareHouseUI.midGrid.transform , false)
		info.gameObject:SetActive(true)
		
		local itemTBData = TableMgr:GetItemData(v.resType)
		--icon
		info.transform:Find("bg_res/icon"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/" , v.resType)
		
		--res name
		info.transform:Find("txt_resnum"):GetComponent("UILabel").text = System.String.Format("{0}:{1}" , TextUtil.GetItemName(itemTBData) , v.applyNum)
		
		--request name
		info.transform:Find("bg_name/rank"):GetComponent("UISprite").spriteName = "level_" .. v.position
		info.transform:Find("bg_name/name"):GetComponent("UILabel").text = v.name
		
		local myReq = (MainData.GetCharId() == v.charId)
		local myPri = bit.band(privilege,  GuildMsg_pb.PrivilegeType_ManageRes) ~= 0
		info.transform:Find("bg_select").gameObject:SetActive(myReq)
		
		if myReq then
			info.name = i
			info.transform:Find("btn_cencel/Label"):GetComponent("UILabel").text = TextMgr:GetText("UnionWareHouse_ui21")
		else
			info.name = 1000 + i --sort children
			info.transform:Find("btn_cencel/Label"):GetComponent("UILabel").text = TextMgr:GetText("UnionWareHouse_ui7")--"拒绝申请"
		end
		
		info.transform:Find("btn_ok").gameObject:SetActive(myPri)
		info.transform:Find("btn_cencel").gameObject:SetActive(myReq or myPri)

	--[[info.transform:Find("btn_ok").gameObject:SetActive(myReq)
		info.transform:Find("btn_ok").gameObject:SetActive(bit.band(privilege,  GuildMsg_pb.PrivilegeType_ManageRes) ~= 0)
		info.transform:Find("btn_cencel").gameObject:SetActive(bit.band(privilege,  GuildMsg_pb.PrivilegeType_ManageRes) ~= 0)
		info.transform:Find("btn_cencel").gameObject:SetActive(myReq)]]

		
		SetClickCallback(info.transform:Find("btn_ok").gameObject , function(go)
			print("apply request")
			ApplyResRequest(v.charId , GuildMsg_pb.DealApplicationType_Pass)
		end)
		SetClickCallback(info.transform:Find("btn_cencel").gameObject , function(go)
			print("cancel or reject request")
			if myReq then
				CancelMyResRequest(v.charId , GuildMsg_pb.DealApplicationType_Reject)
			else
				ApplyResRequest(v.charId , GuildMsg_pb.DealApplicationType_Reject)
			end
		end)
		
	end
	UnionWareHouseUI.midGrid:Reposition()
	UnionWareHouseUI.midScrollView:ResetPosition()
end

local function OnNotify()

end

local function LoadUI()
   UnionWareMsg = UnionResourceRequestData.GetData()
   if UnionWareMsg == nil then
		print("UnionWareMsg is nil")
		return
   end
   LoadTopResources()
   LoadRequstList()
end

function Awake()
	UnionWareHouseUI = {}
	UnionWareMsg = nil
	
	UnionWareHouseUI.mask = transform:Find("Container")
    UnionWareHouseUI.closeButton = transform:Find("Container/bg_frane/bg_title/btn_close"):GetComponent("UIButton")
    SetClickCallback(UnionWareHouseUI.mask.gameObject, Hide)
    SetClickCallback(UnionWareHouseUI.closeButton.gameObject, Hide)

	UnionWareHouseUI.topRes = {}
	UnionWareHouseUI.topRes[GuildMsg_pb.GuildResType_Food] = transform:Find("Container/bg_frane/bg_top/bg_res (1)/Texture/num"):GetComponent("UILabel")
	UnionWareHouseUI.topRes[GuildMsg_pb.GuildResType_Iron] = transform:Find("Container/bg_frane/bg_top/bg_res (2)/Texture/num"):GetComponent("UILabel")
	UnionWareHouseUI.topRes[GuildMsg_pb.GuildResType_Oil] = transform:Find("Container/bg_frane/bg_top/bg_res (3)/Texture/num"):GetComponent("UILabel")
	UnionWareHouseUI.topRes[GuildMsg_pb.GuildResType_Elec] = transform:Find("Container/bg_frane/bg_top/bg_res (4)/Texture/num"):GetComponent("UILabel")
	
	UnionWareHouseUI.midScrollView = transform:Find("Container/bg_frane/bg_mid/Scroll View"):GetComponent("UIScrollView")
	--UnionWareHouseUI.midGrid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	UnionWareHouseUI.midGrid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("CustomSortUIGrid")
	
	UnionWareHouseUI.listItem = transform:Find("listitem")
	
	UnionWareHouseUI.BottomHisBtn = transform:Find("Container/bg_frane/bg_bottom/btn_history"):GetComponent("UIButton")
	UnionWareHouseUI.BottomReqBtn = transform:Find("Container/bg_frane/bg_bottom/btn_apply"):GetComponent("UIButton")
	SetClickCallback(UnionWareHouseUI.BottomHisBtn.gameObject , function(go)
		print("history")
		UnionWareHouseHis.Show()
	end)
	SetClickCallback(UnionWareHouseUI.BottomReqBtn.gameObject , function(go)
		print("request")
		LoadRequestResUI()
	end)
	
	UnionWareHouseUI.Noitem = transform:Find("Container/bg_frane/bg_mid/bg_noitem")
	--选择资源
	UnionWareHouseUI.SelectRes = transform:Find("UnionResApply")
	UnionWareHouseUI.SelResCloseBtn = transform:Find("UnionResApply/Container/bg_frane/bg_title/btn_close"):GetComponent("UIButton")
	UnionWareHouseUI.SelResIcon = {}
	UnionWareHouseUI.SelResIcon[GuildMsg_pb.GuildResType_Food] = transform:Find("UnionResApply/Container/bg_frane/bg_icon/icon1")
	UnionWareHouseUI.SelResIcon[GuildMsg_pb.GuildResType_Iron] = transform:Find("UnionResApply/Container/bg_frane/bg_icon/icon2")
	UnionWareHouseUI.SelResIcon[GuildMsg_pb.GuildResType_Oil] = transform:Find("UnionResApply/Container/bg_frane/bg_icon/icon3")
	UnionWareHouseUI.SelResIcon[GuildMsg_pb.GuildResType_Elec] = transform:Find("UnionResApply/Container/bg_frane/bg_icon/icon4")
	
	for i=GuildMsg_pb.GuildResType_Food , GuildMsg_pb.GuildResType_Elec do
		SetClickCallback(UnionWareHouseUI.SelResIcon[i].gameObject, function()
            OnSelResIconClick(i)--按键索引对应到资源类型
        end)
	end
	
	SetClickCallback(UnionWareHouseUI.SelResCloseBtn.gameObject , function(go)
		UnionWareHouseUI.SelectRes.gameObject:SetActive(false)
	end)
	SetClickCallback(UnionWareHouseUI.SelectRes:Find("Container").gameObject , function(go)
		UnionWareHouseUI.SelectRes.gameObject:SetActive(false)
	end)
	
	UnionWareHouseUI.SelResSlider = transform:Find("UnionResApply/Container/bg_frane/bg_train_time/bg_schedule/bg_slider"):GetComponent("UISlider")
	UnionWareHouseUI.SelResSliderBtn = transform:Find("UnionResApply/Container/bg_frane/bg_train_time/bg_schedule/bg_btn_slider"):GetComponent("UIButton")
	UnionWareHouseUI.SelResBtnAdd = transform:Find("UnionResApply/Container/bg_frane/bg_train_time/btn_add"):GetComponent("UIButton")
	UnionWareHouseUI.SelResBtnMin = transform:Find("UnionResApply/Container/bg_frane/bg_train_time/btn_minus"):GetComponent("UIButton")
	UnionWareHouseUI.SelResBtnSure = transform:Find("UnionResApply/Container/bg_frane/btn_cencel"):GetComponent("UIButton")
	
	SetClickCallback(UnionWareHouseUI.SelResBtnAdd.gameObject , function(go)
		--UnionWareHouseUI.SelectRes.gameObject:SetActive(false)
		--OnClickAddBtn()
		local indexType = reqResType - GuildMsg_pb.GuildResType_Food + 1
		local numMax = math.min(1000000 , UnionWareMsg.resInfos[indexType].resNum)
		
		reqResCount = math.min(reqResCount + 1 , numMax)
		UnionWareHouseUI.SelResSlider.value = numMax > 0 and reqResCount / numMax or 0
		UnionWareHouseUI.SelResInputLabel.text = reqResCount
	end)
	SetClickCallback(UnionWareHouseUI.SelResBtnMin.gameObject , function(go)
		--OnClickDelBtn()
		local indexType = reqResType - GuildMsg_pb.GuildResType_Food + 1
		local numMax = math.min(1000000 , UnionWareMsg.resInfos[indexType].resNum)
		
		reqResCount = math.max(reqResCount - 1 , 0)
		UnionWareHouseUI.SelResSlider.value = numMax > 0 and reqResCount / numMax or 0
		UnionWareHouseUI.SelResInputLabel.text = reqResCount
	end)
	
	SetClickCallback(UnionWareHouseUI.SelResBtnSure.gameObject , function(go)
		OnClickSure()
	end)
--[[
	SetDragCallback(UnionWareHouseUI.SelResSliderBtn.gameObject , function(go,delta)
		--print(UnionWareHouseUI.SelResSlider.value)
		local numMax = math.min(1000000 , UnionWareMsg.resInfos[reqResType - GuildMsg_pb.GuildResType_Food + 1].resNum)
		reqResCount = math.floor(UnionWareHouseUI.SelResSlider.value * numMax)
		UnionWareHouseUI.SelResInputLabel.text = reqResCount
	end)
--]]	
	--[[EventDelegate.Set(UnionWareHouseUI.SelResSlider.onChange,EventDelegate.Callback(function(obj,delta)
		local numMax = math.min(1000000 , UnionWareMsg.resInfos[reqResType - GuildMsg_pb.GuildResType_Food + 1].resNum)
		reqResCount = math.floor(UnionWareHouseUI.SelResSlider.value * numMax)
		if numMax == 0 then
			UnionWareHouseUI.SelResSlider.value = 0
		end
		UnionWareHouseUI.SelResInputLabel.text = reqResCount
	end))]]
	UIUtil.SetPressCallback(UnionWareHouseUI.SelResSlider.gameObject, function(go, isPressed)
		if isPressed then
			EventDelegate.Set(UnionWareHouseUI.SelResSlider.onChange,EventDelegate.Callback(function(obj,delta)
				local numMax = math.min(1000000 , UnionWareMsg.resInfos[reqResType - GuildMsg_pb.GuildResType_Food + 1].resNum)
				reqResCount = math.floor(UnionWareHouseUI.SelResSlider.value * numMax)
				if numMax == 0 then
					UnionWareHouseUI.SelResSlider.value = 0
				end
				UnionWareHouseUI.SelResInputLabel.text = reqResCount
			end))
		else
			EventDelegate.Set(UnionWareHouseUI.SelResSlider.onChange,EventDelegate.Callback(function(obj,delta) end))
		end
	end)
	UIUtil.SetPressCallback(UnionWareHouseUI.SelResSliderBtn.gameObject, function(go, isPressed)
		if isPressed then
			EventDelegate.Set(UnionWareHouseUI.SelResSlider.onChange,EventDelegate.Callback(function(obj,delta)
				local numMax = math.min(1000000 , UnionWareMsg.resInfos[reqResType - GuildMsg_pb.GuildResType_Food + 1].resNum)
				reqResCount = math.floor(UnionWareHouseUI.SelResSlider.value * numMax)
				if numMax == 0 then
					UnionWareHouseUI.SelResSlider.value = 0
				end
				UnionWareHouseUI.SelResInputLabel.text = reqResCount
			end))
		else
			EventDelegate.Set(UnionWareHouseUI.SelResSlider.onChange,EventDelegate.Callback(function(obj,delta) end))
		end
	end)
	
	UnionWareHouseUI.SelResInput = transform:Find("UnionResApply/Container/bg_frane/bg_train_time/frame_input")
	UnionWareHouseUI.SelResInputLabel = transform:Find("UnionResApply/Container/bg_frane/bg_train_time/frame_input/title"):GetComponent("UILabel")
	SetClickCallback(UnionWareHouseUI.SelResInput.gameObject , onClickInput)
	
	UnionResourceRequestData.AddListener(LoadUI)
end

function Show(msg)
    Global.OpenUI(_M)

	local req = GuildMsg_pb.MsgGuildWareHouseInfoRequest()
	Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildWareHouseInfoRequest, req, GuildMsg_pb.MsgGuildWareHouseInfoResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			UnionResourceRequestData.SetData(msg)
			--UnionWareMsg = UnionResourceRequestData.GetData()
			LoadUI()
        end
    end)
end

function Close()
	UnionResourceRequestData.RemoveListener(LoadUI)
	
	UnionWareHouseUI = nil
	UnionWareRequestItem = nil
	if not GUIMgr.Instance:IsMenuOpen("UnionInfo") then
	end
end

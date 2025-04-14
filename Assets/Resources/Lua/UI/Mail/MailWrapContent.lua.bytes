module("MailWarpContent", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String
local GameObject = UnityEngine.GameObject
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback

local mailInfoItem
local mailListGrid
local mailContent
local mailListScrollView
local testList
local curTabDataList
local curOptGrid

local curTabSelect = 1
local mailUI = {}
local mailNew = {}
local MainMailNotify
local newTab = false
local flagCount = 0

local jumpMailMenu = nil 
local operateMailList = {}

local markList = {}

function NotifyMail()
	--print("MailNotify")
	for _ , v in pairs(mailUI) do
		if v.NotifyPush ~= nil then
			v.NotifyPush()
		end
	end

end

function SetJumMenu(mailmenu)
	jumpMailMenu = mailmenu
end

function JumpNewTab(sel)
	newTab = sel
end

function GetTabSelect()
	return curTabSelect
end

function SetTabSelect(tab)
	curTabSelect = tab
end

local function OnUICameraPress(go, pressed)
	--print(go.name)
	if not pressed then
		return
	end
	
	Tooltip.HideItemTip()
end

function CancalSaveMail(mailid)
	local req = MailMsg_pb.MsgUserMailSetSaveRequest()
	req.maillist:append(mailid)
	
	Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailSetSaveRequest, req, MailMsg_pb.MsgUserMailSetSaveResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
		else
			AudioMgr:PlayUISfx("SFX_ui02", 1, false)
			FloatText.Show(TextMgr:GetText("mail_ui35") , Color.white)
			MailListData.CancelSaveMails(msg.maillist)
		end
	end)
end

function SaveMail(mailid)
	local mailData = MailListData.GetMailDataById(mailid)
	if mailData.saved then
		AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
		FloatText.Show(TextMgr:GetText("mail_ui34")  , Color.green)
		return
	end
	
	local req = MailMsg_pb.MsgUserMailSetSaveRequest()
	--for _, v in pairs(mailid) do
	--	print("---------" .. v)
	req.maillist:append(mailid)
	--end
	
	Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailSetSaveRequest, req, MailMsg_pb.MsgUserMailSetSaveResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
		else
			AudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed", 1, false)
			FloatText.Show(TextMgr:GetText("mail_ui40") , Color.green)
			MailListData.SaveMails(msg.maillist)
		end
	end)
end

function GetAllAttachItem()
	local maillist 
	if curTabSelect == 4 then
		maillist = MailListData.GetAllSavedAttachItems()
	else
		maillist = MailListData.GetAllAttachItems(curTabSelect)
	end
	
	local req = MailMsg_pb.MsgUserMailTakeAttachmentRequest()
	for _, v in pairs(maillist) do
		req.mailid:append(v.id)
	end

	Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailTakeAttachmentRequest, req, MailMsg_pb.MsgUserMailTakeAttachmentResponse, function(msg)
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
		else
			--MoneyListData.UpdateData(msg.fresh.money.money)
			--MainData.UpdateData(msg.fresh.maindata)
			--ItemListData.UpdateData(msg.fresh.item)
			MainCityUI.UpdateRewardData(msg.fresh)
			MailListData.GetMailAttachItem(msg.mailid)
			
			local getItemList = {}
			for _ , v in ipairs(msg.reward.item.item) do
				local getItem = {baseid = v.baseid , num = v.num , itype = 0}
				table.insert(getItemList , getItem)
			end
			ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
			ItemListShowNew.SetItemShow(msg)
			GUIMgr:CreateMenu("ItemListShowNew" , false)
			
		end
	end)
	--MainMailNotify()
end

function RequestReadMail(maildata)
	local req = MailMsg_pb.MsgUserMailReadRequest()
	req.mailid = maildata.id
	req.isRead = true
	Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailReadRequest, req, MailMsg_pb.MsgUserMailReadResponse, function(msg)
		if msg.code == 0 then
			MailListData.UpdateMailStatus(maildata.id , MailMsg_pb.MailStatus_Readed)
			if maildata.type == MailMsg_pb.MailType_Report and 
			(maildata.subtype == MailMsg_pb.MailReport_player or 
			maildata.subtype == MailMsg_pb.MailReport_defence or 
			maildata.subtype == MailMsg_pb.MailReport_robres or 
			maildata.subtype == MailMsg_pb.MailReport_robclamp or 
			maildata.subtype == MailMsg_pb.MailReport_robresdefence or 
			maildata.subtype == MailMsg_pb.MailReport_robcampdefence) then
				MailReportDoc.ReadMail(maildata.id , msg)
			elseif maildata.type == MailMsg_pb.MailType_Report and maildata.subtype == MailMsg_pb.MailReport_recon  then --侦查
				MailReportSpyonDoc.ReadMail(maildata.id , msg)
			else 
				MailDoc.ReadMail(maildata.id , msg)
			end
		else
			print(msg.code)
		end
	end)
	
	

	--[[if curTabSelect == MailMsg_pb.MailType_Report and v.subtype == MailMsg_pb.MailReport_player then
		MailReportDoc.ReadMail(tonumber(str[2]))
	else 
		MailDoc.ReadMail(tonumber(str[2]))
	end]]
end

local function ShowFBIWarning()

end

function DeleteMail(dlist)
	local showFBIWarning_unget = false
	local showFBIWarning_unread = false
	local req = MailMsg_pb.MsgUserMailDelRequest()
	local dellist = dlist or nil
	
	if dellist == nil then--删除所有勾选的邮件
		dellist = operateMailList
		print(#operateMailList)
	end
	
	for _ , v in pairs(dellist) do
		req.maillist:append(v.id)
		local mail = MailListData.GetMailDataById(v.id)
		if not mail.taked and mail.attachList ~= nil and (#mail.attachList) > 0 then
			showFBIWarning_unget = true
		end
		if mail.status == 1--[[MailStatus_New]] then
			showFBIWarning_unread = true
		end
	end
	
	
	
	
	if showFBIWarning_unget or showFBIWarning_unread then
		local okCallback = function()
			Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailDelRequest, req, MailMsg_pb.MsgUserMailDelResponse, function(msg)
				MailListData.DeleteMailList(msg.maillist)
			end)
			AudioMgr:PlayUISfx("SFX_ui02", 1, false)
			FloatText.Show(TextMgr:GetText("mail_ui37") , Color.white)
			MessageBox.Clear()
		end
		
		local cancelCallback = function()
			MessageBox.Clear()
		end
		MessageBox.Show(TextMgr:GetText("mail_ui41"), okCallback, cancelCallback)
	else
		Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailDelRequest, req, MailMsg_pb.MsgUserMailDelResponse, function(msg)
			MailListData.DeleteMailList(msg.maillist)
			AudioMgr:PlayUISfx("SFX_ui02", 1, false)
			FloatText.Show(TextMgr:GetText("mail_ui37") , Color.white)
		end)
	end
	
	
end

function MarkMail()
	local req = MailMsg_pb.MsgUserMailSetReadRequest()
	--[[local childCount = mailListGrid.childCount
	for i = 0, childCount - 1 do
		if mailListGrid:GetChild(i).gameObject.activeSelf then
			local gouxuan = mailListGrid:GetChild(i):Find("bg_list/checkbox"):GetComponent("UIToggle")
			if gouxuan.value == true then
				local str = mailListGrid:GetChild(i).name:split("_")
				local markid = tonumber(str[2])
				req.maillist:append(markid)
			end
		end
	end]]
	
	for _ ,v in pairs(operateMailList) do
		if v ~= nil then
			req.maillist:append(v.id)
		end
	end
	
	Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailSetReadRequest, req, MailMsg_pb.MsgUserMailSetReadResponse, function(msg)
		MailListData.MarkMailList(msg.maillist)
    end)
end

local function IsOperatMail(mailid)
	for _ ,  v in pairs(operateMailList) do
		if v ~= nil and v.id == mailid then
			return true
		end
	end

	return false
end

local function OperatMailListLength()
	local count = 0
	for _ ,  v in pairs(operateMailList) do
		if v ~= nil then
			count = count + 1
		end
	end
	return count
end



--check box
local function MailOperatorBox()
	local mainMailUI = GetMailUI("Container")
	--[[local opbox = mainMailUI.go:Find("bg_frane/Panel_box")

	if flagCount == 0 then
		opbox.gameObject:SetActive(false)
	elseif flagCount == 1 then
		if not opbox.gameObject.activeSelf then
			opbox.gameObject:SetActive(true)
			mainMailUI.panelBox.tweenScale:Play(true,true)
			mainMailUI.panelBox.tweenPos:Play(true,true)
			mainMailUI.panelBox.tweenAlpha:Play(true,true)
		end
	else	
	end]]
	local opCount = OperatMailListLength()
	local delReadBtnGO = mainMailUI.go:Find("bg_frane/bg_bottom/btn_delread")
	if opCount == 0 then
		mainMailUI.btnGroup.go.gameObject:SetActive(false)
	elseif opCount == 1 then
		if not mainMailUI.btnGroup.go.gameObject.activeSelf then
			mainMailUI.btnGroup.go.gameObject:SetActive(true)
		end
	end
end

local function UpdateOperatorMailBox()
	--[[flagCount = 0
	local childCount = mailListGrid.childCount
	for i = 0, childCount - 1 do
		if mailListGrid:GetChild(i).gameObject.activeSelf then
			local gouxuan = mailListGrid:GetChild(i):Find("bg_list/checkbox"):GetComponent("UIToggle")
			if gouxuan.value == true then
				flagCount = flagCount + 1
			end
		end
	end
	
	]]
	MailOperatorBox()
end

local function SelectAllBtnCallback(go)
	print("SelectAllBtn")
	local allCheck = false
	local dataLength = #curTabDataList
	if OperatMailListLength() >= 0 and OperatMailListLength() < dataLength then
		allCheck = true
	end
	
	local childCount = mailListGrid.childCount
	for i = 0, childCount - 1 do
		--GameObject.Destroy(mailListGrid.transform:GetChild(i).gameObject)
		local gouxuan = mailListGrid:GetChild(i):Find("bg_list/checkbox"):GetComponent("UIToggle")
		gouxuan.value = allCheck
	end
	
	
	if allCheck == true then
		operateMailList = {}
		for _ , v in pairs(curTabDataList) do
			operateMailList[v.id] = v
		end
	else
		operateMailList = {}
	end
	MailOperatorBox()
end

function UpdateMailListItem(item , index , realInde)
	if curTabDataList == nil then
		return
	end

	--print("inde:" .. index .. "   realindex:" .. realInde .. "   dataindex:" .. math.abs(realInde) + 1 .. "   datasize:" .. #curTabDataList)
	--item.name = index .. "_" .. realInde .. "_" .. item.transform.localPosition.y
	local dataIndex = math.abs(realInde) + 1
	
	if dataIndex > #curTabDataList then
		--print("dataindex is out of range of data : dataindex:" .. dataIndex .. "datasize:" .. #testList)
		return
	end

	local mailmainUI = GetMailUI("Container")
	local v = curTabDataList[dataIndex]
	item.gameObject.name = "mail_" .. v.id
	
	if not v.saved or curTabSelect == 4 then
		--mid info
		local midShow = "bg_common"
		local midUnShow = "bg_war"
		if v.type == 3 then--MailMsg_pb.MailTypeId.MailType_Report
			midShow = "bg_war"
			midUnShow = "bg_common"
			--report icon
			if v.report ~= nil and v.report.icon ~= nil then
				local mailIcon = item.transform:Find("bg_list/bg_war/bg_icon/Texture"):GetComponent("UITexture")
				mailIcon.mainTexture = ResourceLibrary:GetIcon("Icon/Mail/" , v.report.icon)
			end
		end
		local itemMidInfoShow = item.transform:Find(System.String.Format("bg_list/{0}" , midShow))
		itemMidInfoShow.gameObject:SetActive(true)
		local itemMidInfoUnShow = item.transform:Find(System.String.Format("bg_list/{0}" , midUnShow))
		itemMidInfoUnShow.gameObject:SetActive(false)
		
		local des = itemMidInfoShow:Find("text_des"):GetComponent("UILabel")
		--print(v.report.param[1] , v.report.param[2])
		local contentText = ""
		
		if v.type == 3 then
			if tonumber(v.report.param[3]) == 0 then --player name
				contentText = System.String.Format(TextMgr:GetText(v.content) ,v.report.param[1], v.report.param[2])
			else
				contentText = System.String.Format(TextMgr:GetText(v.content) ,TextMgr:GetText(v.report.param[1]), v.report.param[2])
			end
		else
			contentText = v.content
		end
		
		if v.status == 2 then
			des.text = System.String.Format("[b2b2b2ff]{0}[-]" , contentText)
		else
			des.text = contentText
		end
		
		
		local backG = item.transform:Find("bg_list/background")
		local readed = item.transform:Find("bg_list/bg_text/icon_unread")
		local tittle = itemMidInfoShow:Find("text_name"):GetComponent("UILabel")
		if v.status == 2 then 
			tittle.gradientTop = Color(1,1,1,1)
			tittle.gradientBottom = Color(0.3608 , 0.3843 , 0.3960 , 1)
			readed.gameObject:SetActive(false)
			backG.gameObject:SetActive(true)
		else
			readed.gameObject:SetActive(true)
			backG.gameObject:SetActive(false)
		end
		
		if v.type == MailMsg_pb.MailType_System then
			tittle.text = TextMgr:GetText("mail_ui43")
		elseif v.type == MailMsg_pb.MailType_User then
			tittle.text = v.fromname

			local gov = itemMidInfoShow:Find("bg_gov")
			if gov ~= nil then
				GOV_Util.SetGovNameUI(gov,v.fromOfficialId,v.fromGuildOfficialId,true)
			end			
		else
			tittle.text = TextMgr:GetText(v.fromname)
		end
		
		local mtime = itemMidInfoShow:Find("text_time"):GetComponent("UILabel")
		if v.status == 2 then 
			mtime.text = System.String.Format("[b2b2b2ff]{0}[-]" , Global.SecondToStringFormat(v.createtime , "yyyy-MM-dd HH:mm:ss"))
		else
			mtime.text = Global.SecondToStringFormat(v.createtime , "yyyy-MM-dd HH:mm:ss")
		end
		
		
		local attchItem = item.transform:Find("bg_list/icon_attachment")
		if not v.taked and (#v.attachList) > 0 then
			attchItem.gameObject:SetActive(true)
		else
			attchItem.gameObject:SetActive(false)
		end
		
		SetClickCallback(item.gameObject , function(go)
			local str = go.name:split("_")
			RequestReadMail(v)
			
			--[[if curTabSelect == MailMsg_pb.MailType_Report and v.subtype == MailMsg_pb.MailReport_player then
				MailReportDoc.ReadMail(tonumber(str[2]))
			else 
				MailDoc.ReadMail(tonumber(str[2]))
			end]]
		end)
		
		
		local checkbox = item.transform:Find("bg_list/checkbox"):GetComponent("UIToggle")
		EventDelegate.Set(checkbox.onChange , EventDelegate.Callback(function(go , value)
			if checkbox.value then
				operateMailList[v.id] = v
			else
				if operateMailList[v.id] ~= nil then
					operateMailList[v.id] = nil
				end
			end
			MailOperatorBox()
		end))
		
		
		if IsOperatMail(v.id) then
			checkbox.value = true
		else
			checkbox.value = false
		end
		
		--save 
		local saveFlag = item.transform:Find("bg_list/bg_star"):GetComponent("UIButton")
		local flag = item.transform:Find("bg_list/bg_star/star")
		if v.saved then
			flag.gameObject:SetActive(true)
			SetClickCallback(saveFlag.gameObject , function(go)
				CancalSaveMail(v.id)
				flag.gameObject:SetActive(false)
			end)
		else
			flag.gameObject:SetActive(false)
			SetClickCallback(saveFlag.gameObject , function(go)
				SaveMail(v.id)
				flag.gameObject:SetActive(true)
			end)
		end
	end
	
	local getAllItemBtn = mailmainUI.go:Find("bg_frane/bg_bottom/btn_get"):GetComponent("UIButton")
	local items = MailListData.GetAllAttachItems(curTabSelect)
	if curTabSelect == 4 then
		items = MailListData.GetAllSavedAttachItems()
	else
		items = MailListData.GetAllAttachItems(curTabSelect)
	end
	
	if items ~= nil and (#items) > 0 then
		getAllItemBtn.gameObject:SetActive(true)
	else
		getAllItemBtn.gameObject:SetActive(false)
	end
	
	UpdateOperatorMailBox()
	
	local delReadBtn = mailmainUI.go:Find("bg_frane/bg_bottom/btn_delread"):GetComponent("UIButton")
	local readedMails
	if curTabSelect == 4 then
		readedMails = MailListData.GetMailSavedList(2)
	else
		readedMails = MailListData.GetMailListByStatus(2 , curTabSelect)
	end
	
	
	if readedMails ~= nil and (#readedMails) > 0 then
		delReadBtn.gameObject:SetActive(true)
	else
		delReadBtn.gameObject:SetActive(false)
	end
	
	local SelectAllBtn = mailmainUI.go:Find("bg_frane/bg_bottom/btn_selectall"):GetComponent("UIButton")
	if mailListGrid ~= nil and mailListGrid.childCount > 0 then 
		SelectAllBtn.gameObject:SetActive(true)
	else
		SelectAllBtn.gameObject:SetActive(false)
	end
end

function GetTabContent(selTab)
	local mainMailUI = GetMailUI("Container")
	for i, v in pairs(mainMailUI.mailContent) do
		if v ~= nil and i == selTab then
			return v
		end
	end
	
	return nil
end

function ClearTabOptGrid(content)
	local optChild = {}
	for i=0 , content.scrollview.transform.childCount-1 do
		local child = content.scrollview.transform:GetChild(i)
		if child:GetComponent("UIWrapContent") ~= nil then
			--GameObject.DestroyImmediate(child.gameObject)
			table.insert(optChild , child)
		end
	end
	
	for _ , v in pairs(optChild) do
		local wrapContent = v:GetComponent("UIWrapContent")
		wrapContent.onInitializeItem = nil
		wrapContent.enabled = false
		GameObject.DestroyImmediate(v.gameObject)
	end
	
	--清除wrapContent组件需要清理scrollview中的委托函数onClipMove
	local scrollPanel = content.scrollview.transform:GetComponent("UIScrollView").panel
	if scrollPanel ~= nil then
		if scrollPanel.onClipMove ~= nil then
			print("clear scroll panel")
			scrollPanel.onClipMove = nil 
		end
	end
	
end

function SetTabOptGrid(content , InitOptGrid)
	local maildata = nil
	local datalength = 0
	if curTabSelect == 4 then --save tab
		maildata = MailListData.GetSavedMail()
	else
		maildata = MailListData.GetMailDataByType(curTabSelect)
	end
	
	if maildata ~= nil then
		datalength = #maildata
	end
	print(datalength)
	
	curTabDataList = maildata
	
	local wrapParam = {}
	wrapParam.OnInitFunc = UpdateMailListItem
	wrapParam.itemSize = 115
	wrapParam.minIndex = -(datalength-1)
	wrapParam.maxIndex = 0
	wrapParam.itemCount = 4 -- 预设项数量。 -1为实际显示项数量
	wrapParam.cellPrefab = mailInfoItem
	wrapParam.localPos = Vector3(0 , 0 , 0)
	wrapParam.cullContent = false
	wrapParam.moveDir = 1--vertical
	UIUtil.CreateWrapContent(content.scrollview , wrapParam , InitOptGrid)
		
	
	--[[if heroListDataLength >= 20 then
		heroScrollView:GetComponent("UIScrollView").disableDragIfFits = false
	else
		heroScrollView:GetComponent("UIScrollView").disableDragIfFits = true
	end]]
	content.scrollview:GetComponent("UIScrollView"):ResetPosition()
end

function SetTabContent(content)
	local maildata 
	if curTabSelect == 4 then --save tab
		maildata = MailListData.GetSavedMail()
	else
		maildata = MailListData.GetMailDataByType(curTabSelect)
	end
	
	operateMailList = {}
	local noitem = transform:Find("Container/bg_frane/bg_mid/bg_noitem")
	if maildata == nil then
		noitem.gameObject:SetActive(true)
		content.scrollview.gameObject:SetActive(false)
	else
		noitem.gameObject:SetActive(false)
		ClearTabOptGrid(content)
		content.scrollview.gameObject:SetActive(true)
		mailListScrollView = content.scrollview
		print(content.scrollview.name)
		
		if #maildata < 4 then
			content.Grid.gameObject:SetActive(true)
			mailListGrid = content.Grid
			UpdateTabContent(false , curTabSelect)
		else
			content.Grid.gameObject:SetActive(false)
			SetTabOptGrid(content , function(optGrid)
				print(optGrid.name)
				mailListGrid = optGrid
			end)
		end
	end
	
end

function ShowTabContent(selTab)
	print("111")
	local mainMailUI = GetMailUI("Container")
	for i, v in pairs(mainMailUI.mailContent) do
		if v ~= nil and i == selTab then
			curTabSelect = selTab
			v.content.gameObject:SetActive(true)
			print(selTab)
			SetTabContent(v)
		else
			v.content.gameObject:SetActive(false)
		end
	end
end

--刷新当前页内容
function UpdateTabContent(forceFresh , selTab)
	--[[if not forceFresh and selTab == curTabSelect then
		return
	end
	]]
	local mailmainUI = GetMailUI("Container")
	curTabSelect = selTab
	
	local tabContent = GetTabContent(curTabSelect)
	if tabContent == nil then
		return
	end
	
	--print("select mail tyope : " .. curTabSelect)
	while mailListGrid.childCount > 0 do
		GameObject.DestroyImmediate(mailListGrid:GetChild(0).gameObject)
	end

	--MailOperatorBox()
	local maildata 
	if curTabSelect == 4 then --save tab
		maildata = MailListData.GetSavedMail()
	else
		maildata = MailListData.GetMailDataByType(curTabSelect)
	end
	
	curTabDataList = maildata
	print(#curTabDataList)
	
	
	for _ ,v in pairs(curTabDataList) do
		if not v.saved or curTabSelect == 4 then
			--print(v.id , v.type , v.subtype)
			local item = NGUITools.AddChild(mailListGrid.gameObject , mailInfoItem.gameObject)
			item.gameObject:SetActive(true)
			item.gameObject.name = "mail_" .. v.id
			item.transform:SetParent(mailListGrid , false)
			
			
			--mid info
			local midShow = "bg_common"
			local midUnShow = "bg_war"
			if v.type == 3 then--MailMsg_pb.MailTypeId.MailType_Report
				midShow = "bg_war"
				midUnShow = "bg_common"
				--report icon
				if v.report ~= nil and v.report.icon ~= nil then
					local mailIcon = item.transform:Find("bg_list/bg_war/bg_icon/Texture"):GetComponent("UITexture")
					mailIcon.mainTexture = ResourceLibrary:GetIcon("Icon/Mail/" , v.report.icon)
				end
			end
			local itemMidInfoShow = item.transform:Find(System.String.Format("bg_list/{0}" , midShow))
			itemMidInfoShow.gameObject:SetActive(true)
			local itemMidInfoUnShow = item.transform:Find(System.String.Format("bg_list/{0}" , midUnShow))
			itemMidInfoUnShow.gameObject:SetActive(false)
			
			local des = itemMidInfoShow:Find("text_des"):GetComponent("UILabel")
			--print(v.report.param[1] , v.report.param[2])
			local contentText = ""
			
			if v.type == 3 then
				if tonumber(v.report.param[3]) == 0 then --player name
					contentText = System.String.Format(TextMgr:GetText(v.content) ,v.report.param[1], v.report.param[2])
				else
					contentText = System.String.Format(TextMgr:GetText(v.content) ,TextMgr:GetText(v.report.param[1]), v.report.param[2])
				end
			else
				contentText = v.content
			end
			
			if v.status == 2 then
				des.text = System.String.Format("[b2b2b2ff]{0}[-]" , contentText)
			else
				des.text = contentText
			end
			
			
			
			local backG = item.transform:Find("bg_list/background")
			local readed = item.transform:Find("bg_list/bg_text/icon_unread")
			local tittle = itemMidInfoShow:Find("text_name"):GetComponent("UILabel")
			if v.status == 2 then 
				tittle.gradientTop = Color(1,1,1,1)
				tittle.gradientBottom = Color(0.3608 , 0.3843 , 0.3960 , 1)
				readed.gameObject:SetActive(false)
				backG.gameObject:SetActive(true)
			else
				readed.gameObject:SetActive(true)
				backG.gameObject:SetActive(false)
			end
			
			if v.type == MailMsg_pb.MailType_System then
				tittle.text = TextMgr:GetText("mail_ui43")
			elseif v.type == MailMsg_pb.MailType_User then
				tittle.text = v.fromname
				local gov = itemMidInfoShow:Find("bg_gov")
				if gov ~= nil then
					GOV_Util.SetGovNameUI(gov,v.fromOfficialId,v.fromGuildOfficialId,true)
				end		

			else
				tittle.text = TextMgr:GetText(v.fromname)
			end
			
			local mtime = itemMidInfoShow:Find("text_time"):GetComponent("UILabel")
			if v.status == 2 then 
				mtime.text = System.String.Format("[b2b2b2ff]{0}[-]" , Global.SecondToStringFormat(v.createtime , "yyyy-MM-dd HH:mm:ss"))
			else
				mtime.text = Global.SecondToStringFormat(v.createtime , "yyyy-MM-dd HH:mm:ss")--v.createtime)
			end
			
			
			local attchItem = item.transform:Find("bg_list/icon_attachment")
			if not v.taked and (#v.attachList) > 0 then
				attchItem.gameObject:SetActive(true)
			else
				attchItem.gameObject:SetActive(false)
			end
			
			SetClickCallback(item.gameObject , function(go)
				local str = go.name:split("_")
				RequestReadMail(v)
				
				--[[if curTabSelect == MailMsg_pb.MailType_Report and v.subtype == MailMsg_pb.MailReport_player then
					MailReportDoc.ReadMail(tonumber(str[2]))
				else 
					MailDoc.ReadMail(tonumber(str[2]))
				end]]
			end)
			
			
			local checkbox = item.transform:Find("bg_list/checkbox"):GetComponent("UIToggle")
			EventDelegate.Set(checkbox.onChange , EventDelegate.Callback(function(go , value)
				if checkbox.value then
					--flagCount = flagCount + 1
					operateMailList[v.id] = v
				else
					--flagCount = math.max( 0, flagCount - 1)
					if operateMailList[v.id] ~= nil then
						operateMailList[v.id] = nil
					end
				end
				MailOperatorBox()
			end))
			
			if IsOperatMail(v.id) then
				checkbox.value = true
			else
				checkbox.value = false
			end
			
			--save 
			local saveFlag = item.transform:Find("bg_list/bg_star"):GetComponent("UIButton")
			local flag = item.transform:Find("bg_list/bg_star/star")
			if v.saved then
				flag.gameObject:SetActive(true)
				SetClickCallback(saveFlag.gameObject , function(go)
					CancalSaveMail(v.id)
					flag.gameObject:SetActive(false)
				end)
			else
				flag.gameObject:SetActive(false)
				SetClickCallback(saveFlag.gameObject , function(go)
					SaveMail(v.id)
					flag.gameObject:SetActive(true)
				end)
			end
			
		end
	end
	mailListGrid:GetComponent("UIGrid"):Reposition()
	if mailListScrollView ~= nil then
		mailListScrollView:GetComponent("UIScrollView"):ResetPosition()
	end
	
	--update bottom button
	local getAllItemBtn = mailmainUI.go:Find("bg_frane/bg_bottom/btn_get"):GetComponent("UIButton")
	local items = MailListData.GetAllAttachItems(curTabSelect)
	if curTabSelect == 4 then
		items = MailListData.GetAllSavedAttachItems()
	else
		items = MailListData.GetAllAttachItems(curTabSelect)
	end
	
	if items ~= nil and (#items) > 0 then
		getAllItemBtn.gameObject:SetActive(true)
	else
		getAllItemBtn.gameObject:SetActive(false)
	end
	
	UpdateOperatorMailBox()
	
	local delReadBtn = mailmainUI.go:Find("bg_frane/bg_bottom/btn_delread"):GetComponent("UIButton")
	local readedMails
	if curTabSelect == 4 then
		readedMails = MailListData.GetMailSavedList(2)
	else
		readedMails = MailListData.GetMailListByStatus(2 , curTabSelect)
	end
	
	
	if readedMails ~= nil and (#readedMails) > 0 then
		delReadBtn.gameObject:SetActive(true)
	else
		delReadBtn.gameObject:SetActive(false)
	end
	
	local SelectAllBtn = mailmainUI.go:Find("bg_frane/bg_bottom/btn_selectall"):GetComponent("UIButton")
	if mailListGrid.childCount > 0 then 
		SelectAllBtn.gameObject:SetActive(true)
	else
		SelectAllBtn.gameObject:SetActive(false)
	end
end

--刷新邮件主界面各页签状态和当前页内容
MainMailNotify =  function()
	--print("main mail noti push")
	local mailmainUI = GetMailUI("Container")
	local systemNewNum = MailListData.GetNewMailCount(1)
	local reportNewNum = MailListData.GetNewMailCount(3)
	local playerNewNum = MailListData.GetNewMailCount(2)
	local favNewNum = MailListData.GetNewSavedMailCount()
	--[[
	local maildata = MailListData.GetData()
	for _,v in ipairs(maildata) do
		if v.status == 1 then --MailMsg_pb.MailStatus.MailStatus_New
			if v.type == 1 then--MailMsg_pb.MailTypeId.MailType_System
				sysNewNum = sysNewNum + 1
			elseif v.type == 2 then--MailMsg_pb.MailTypeId.MailType_Report
				reportNewNum = reportNewNum + 1
			elseif v.type == 3 then--MailMsg_pb.MailTypeId.MailType_User
				playerNewNum = playerNewNum + 1
			elseif v.type == 4 then--MailMsg_pb.MailTypeId.MailType_Save
				favNewNum = favNewNum + 1
			end
		end
	end
	]]
	if systemNewNum > 0 then
		mailmainUI.Notify.sysNew.gameObject:SetActive(true)
		mailmainUI.Notify.sysNew:Find("num"):GetComponent("UILabel").text = systemNewNum
	else
		mailmainUI.Notify.sysNew.gameObject:SetActive(false)
	end
	
	if reportNewNum > 0 then
		mailmainUI.Notify.reportNew.gameObject:SetActive(true)
		mailmainUI.Notify.reportNew:Find("num"):GetComponent("UILabel").text = reportNewNum
	else
		mailmainUI.Notify.reportNew.gameObject:SetActive(false)
	end
	
	if playerNewNum > 0 then
		mailmainUI.Notify.userNew.gameObject:SetActive(true)
		mailmainUI.Notify.userNew:Find("num"):GetComponent("UILabel").text = playerNewNum
	else
		mailmainUI.Notify.userNew.gameObject:SetActive(false)
	end
	
	if favNewNum > 0 then
		mailmainUI.Notify.favNew.gameObject:SetActive(true)
		mailmainUI.Notify.favNew:Find("num"):GetComponent("UILabel").text = favNewNum
	else
		mailmainUI.Notify.favNew.gameObject:SetActive(false)
	end
	
	mailmainUI.Tab[curTabSelect]:Set(true)
	if mailmainUI.Notify.updateContent ~= nil then
		print(curTabSelect)
		mailmainUI.Notify.updateContent(curTabSelect)
	end
end

local function InitUI()
	--邮件主界面
	local uiContainer = {}
	uiContainer.go = transform:Find("Container")
	uiContainer.name = "Container"
	uiContainer.NotifyPush = MainMailNotify
	uiContainer.Notify = {}
	uiContainer.Notify.sysNew = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_5/Animation/bg_num")--mailmainUI:Find("bg_frane/bg_tab/btn_tabtype_5/bg_num/num"):GetComponent("UILabel")
	uiContainer.Notify.reportNew = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_4/Animation/bg_num")
	uiContainer.Notify.userNew = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_6/Animation/bg_num")
	uiContainer.Notify.favNew = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_7/Animation/bg_num")
	uiContainer.Notify.updateContent = ShowTabContent--UpdateTabContent
	uiContainer.script = Mail
	uiContainer.Tab = {}
	uiContainer.Tab[1] = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_5"):GetComponent("UIToggle")
	uiContainer.Tab[3] = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_4"):GetComponent("UIToggle")
	uiContainer.Tab[2] = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_6"):GetComponent("UIToggle")
	uiContainer.Tab[4] = transform:Find("Container/bg_frane/bg_tab/btn_tabtype_7"):GetComponent("UIToggle")
	uiContainer.panelBox = {}
	uiContainer.panelBox.tweenScale = transform:Find("Container/bg_frane/Panel_box/bg_box"):GetComponent("TweenScale")
	uiContainer.panelBox.tweenPos = transform:Find("Container/bg_frane/Panel_box/bg_box"):GetComponent("TweenPosition")
	uiContainer.panelBox.tweenAlpha = transform:Find("Container/bg_frane/Panel_box/bg_box"):GetComponent("TweenAlpha")
	uiContainer.btnGroup = {}
	uiContainer.btnGroup.go = transform:Find("Container/bg_frane/bg_bottom/operatorBtn")
	uiContainer.btnGroup.delBtn = transform:Find("Container/bg_frane/bg_bottom/operatorBtn/btn_del"):GetComponent("UIButton")
	uiContainer.btnGroup.markBtn = transform:Find("Container/bg_frane/bg_bottom/operatorBtn/btn_mark"):GetComponent("UIButton")
	
	uiContainer.mailContent = {}
	uiContainer.mailContent[1] = {}
	uiContainer.mailContent[1].content = transform:Find("Container/bg_frane/bg_mid/content_system")
	uiContainer.mailContent[1].scrollview = transform:Find("Container/bg_frane/bg_mid/content_system/Scroll View")
	uiContainer.mailContent[1].Grid = transform:Find("Container/bg_frane/bg_mid/content_system/Scroll View/Grid")
	uiContainer.mailContent[2] = {}
	uiContainer.mailContent[2].content = transform:Find("Container/bg_frane/bg_mid/content_user")
	uiContainer.mailContent[2].scrollview = transform:Find("Container/bg_frane/bg_mid/content_user/Scroll View")
	uiContainer.mailContent[2].Grid = transform:Find("Container/bg_frane/bg_mid/content_user/Scroll View/Grid")
	uiContainer.mailContent[3] = {}
	uiContainer.mailContent[3].content = transform:Find("Container/bg_frane/bg_mid/content_report")
	uiContainer.mailContent[3].scrollview = transform:Find("Container/bg_frane/bg_mid/content_report/Scroll View")
	uiContainer.mailContent[3].Grid = transform:Find("Container/bg_frane/bg_mid/content_report/Scroll View/Grid")
	uiContainer.mailContent[4] = {}
	uiContainer.mailContent[4].content = transform:Find("Container/bg_frane/bg_mid/content_save")
	uiContainer.mailContent[4].scrollview = transform:Find("Container/bg_frane/bg_mid/content_save/Scroll View")
	uiContainer.mailContent[4].Grid = transform:Find("Container/bg_frane/bg_mid/content_save/Scroll View/Grid")
	
	table.insert(mailUI , uiContainer)
	
	--邮件阅读界面
	local uiMailDoc = {}
	uiMailDoc.go = transform:Find("MailDoc")
	uiMailDoc.name = "MailDoc"
	uiMailDoc.NotifyPush = nil
	uiMailDoc.Notify = nil
	uiMailDoc.script = MailDoc
	table.insert(mailUI , uiMailDoc)
	
	--写邮件界面
	local uiMailNew = {}
	uiMailNew.go = transform:Find("MailNew")
	uiMailNew.name = "MailNew"
	uiMailNew.NotifyPush = nil
	uiMailNew.Notify = nil
	uiMailNew.script = MailNew
	table.insert(mailUI , uiMailNew)
	
	--PVP报告阅读界面
	local uiMailReportDoc = {}
	uiMailReportDoc.go = transform:Find("MailReport")
	uiMailReportDoc.name = "MailReportDoc"
	uiMailReportDoc.NotifyPush = nil
	uiMailReportDoc.Notify = nil
	uiMailReportDoc.script = MailReportDoc
	table.insert(mailUI , uiMailReportDoc)
	
	--侦查报告界面
	local uiMailReportSpyonDoc = {}
	uiMailReportSpyonDoc.go = transform:Find("Mail-spyon")
	uiMailReportSpyonDoc.name = "MailReportSpyonDoc"
	uiMailReportSpyonDoc.NotifyPush = nil
	uiMailReportSpyonDoc.Notify = nil
	uiMailReportSpyonDoc.script = MailReportSpyonDoc
	table.insert(mailUI , uiMailReportSpyonDoc)
end


function OpenMailUI(uiName)
	for _ , v in pairs(mailUI) do
		if v.name == uiName then
			v.go.gameObject:SetActive(true)
			v.script.OpenUI()
			--if v.name == "Container" then
			--	v.Notify.updateContent(true , curTabSelect)
			--end
		else
			v.script.CloseUI()
			v.go.gameObject:SetActive(false)
		end
	end
end

function GetMailUI(uiName)
	for _ , v in pairs(mailUI) do
		if v.name == uiName then
			return v
		end
	end
	return nil
end



function Init(mailTransform)
	flagCount = 0
	local mainMailUI = GetMailUI("Container")
	--mailListGrid = mainMailUI.go:Find("bg_frane/Scroll View/Grid")
	--mailListScrollView = mainMailUI.go:Find("bg_frane/Scroll View")
	
	local closeBtn = mainMailUI.go:Find("bg_frane/bg_top/btn_close"):GetComponent("UIButton")
	SetClickCallback(closeBtn.gameObject , function(go)
		GUIMgr:CloseMenu("Mail")
	end)
	SetClickCallback(mainMailUI.go.gameObject , function(go)
		GUIMgr:CloseMenu("Mail")
	end)
	
	--tab btn
	local tabBtnSys = mainMailUI.go:Find("bg_frane/bg_tab/btn_tabtype_5"):GetComponent("UIButton")
	SetClickCallback(tabBtnSys.gameObject , function(go)
		ShowTabContent(1)--UpdateTabContent(false , 1)--MailMsg_pb.MailTypeId.MailType_System)
	end)
	local tabBtnReport = mainMailUI.go:Find("bg_frane/bg_tab/btn_tabtype_4"):GetComponent("UIButton")
	SetClickCallback(tabBtnReport.gameObject , function(go)
		ShowTabContent(3)--UpdateTabContent(false , 3)--MailMsg_pb.MailTypeId.MailType_Report
	end)
	local tabBtnPlayer = mainMailUI.go:Find("bg_frane/bg_tab/btn_tabtype_6"):GetComponent("UIButton")
	SetClickCallback(tabBtnPlayer.gameObject , function(go)
		ShowTabContent(2)--UpdateTabContent(false , 2)--MailMsg_pb.MailTypeId.MailType_User
	end)
	local tabBtnfavorate = mainMailUI.go:Find("bg_frane/bg_tab/btn_tabtype_7"):GetComponent("UIButton")
	SetClickCallback(tabBtnfavorate.gameObject , function(go)
		ShowTabContent(4)--UpdateTabContent(false , 4)--MailMsg_pb.MailTypeId.MailType_Save)
	end)
	
	--selecet all btn
	local SelectAllBtn = mainMailUI.go:Find("bg_frane/bg_bottom/btn_selectall"):GetComponent("UIButton")
	SetClickCallback(SelectAllBtn.gameObject , SelectAllBtnCallback)
		--[[print("SelectAllBtn")
		local allCheck = false
		local childCount = mailListGrid.childCount
		for i = 0, childCount - 1 do
			if mailListGrid:GetChild(i).gameObject.activeSelf then
				--GameObject.Destroy(mailListGrid.transform:GetChild(i).gameObject)
				local gouxuan = mailListGrid:GetChild(i):Find("bg_list/checkbox"):GetComponent("UIToggle")
				if gouxuan.value == false then
					allCheck = true
					break
				end
			end
		end
		for i = 0, childCount - 1 do
			--GameObject.Destroy(mailListGrid.transform:GetChild(i).gameObject)
			local gouxuan = mailListGrid:GetChild(i):Find("bg_list/checkbox"):GetComponent("UIToggle")
			gouxuan.value = allCheck
		end
		
		
		
		
		
		if allCheck == true then
			flagCount = childCount
		else
			flagCount = 0
		end
		MailOperatorBox()
		
		local allCheck = false
		for _ , v in pairs(operateMailList) do
			if v ~= nil then
				allCheck = true
			end
		end
		
		
		if allCheck == true then
			flagCount = childCount
		else
			flagCount = 0
		end
		MailOperatorBox()
	end)]]
	--write mail btn
	local newMailBtn = mainMailUI.go:Find("bg_frane/bg_bottom/btn_newmail"):GetComponent("UIButton")
	SetClickCallback(newMailBtn.gameObject , function(go)
		OpenMailUI("MailNew")
	end)
	--del btn
	local delReadBtn = mainMailUI.go:Find("bg_frane/bg_bottom/btn_delread"):GetComponent("UIButton")
	SetClickCallback(delReadBtn.gameObject , function(go)
		print("btn_delread : " .. curTabSelect)
		local readedMails
		if curTabSelect == 4 then
			readedMails = MailListData.GetMailSavedList(2)
		else
			readedMails = MailListData.GetMailListByStatus(2 , curTabSelect)
		end
		DeleteMail(readedMails)
	end)
	--getall btn
	local getAllItemBtn = mainMailUI.go:Find("bg_frane/bg_bottom/btn_get"):GetComponent("UIButton")
	SetClickCallback(getAllItemBtn.gameObject , function(go)
		print("btn_getall")
		GetAllAttachItem()
	end)
	
	--operatorbox
	local opbox = mainMailUI.go:Find("bg_frane/Panel_box")
	local opBox_del = opbox:Find("bg_box/btn_del"):GetComponent("UIButton")
	SetClickCallback(opBox_del.gameObject , function(go)
		DeleteMail()
	end)
	
	local opBox_mark = opbox:Find("bg_box/btn_mark"):GetComponent("UIButton")
	SetClickCallback(opBox_mark.gameObject , function(go)
		MarkMail()
	end)
	
	--operatorbox1 邮件UI优化  ID：1000237
	SetClickCallback(mainMailUI.btnGroup.delBtn.gameObject , function(go)
		DeleteMail()
	end)
	SetClickCallback(mainMailUI.btnGroup.markBtn.gameObject , function(go)
		MarkMail()
	end)
	
end


local function InitMailUI()
	for _ , v in pairs(mailUI) do
		if v.script ~= nil then
			--print(v.name)
			v.script.Init(transform)
		end
	end 
end

function OpenUI()
	--ShowTabContent(curTabSelect)
	
end
function CloseUI()
	
end

function Awake()
	mailUI = {}
	InitUI()
	mailInfoItem = transform:Find("MailInfo")
	MailListData.AddListener(NotifyMail)
	AddDelegate(UICamera, "onPress", OnUICameraPress)
	
end

function OpenMenu()
	if jumpMailMenu ~= nil and jumpMailMenu ~= "" then
		OpenMailUI(jumpMailMenu)
	else
		OpenMailUI("Container")
	end
end

function Start()
	InitMailUI()
	if newTab then
		curTabSelect = MailListData.GetFirstNewMail()
		if curTabSelect == 0 then
			curTabSelect = 1
		end
	end
	
	
	MainCityUI.UpdateMailIcon(false)
	if MailListData.IsNeedUpdate() then
		local req = MailMsg_pb.MsgUserMailListRequest()
		Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailListRequest, req, MailMsg_pb.MsgUserMailListResponse, function(msg)
			MailListData.UpdateData(msg.maillist)
			--OpenMailUI("Container")
			OpenMenu()
			MainMailNotify()
			MailListData.NeedUpdate(false)
		end)
	else
		--OpenMailUI("Container")
		OpenMenu()
		MainMailNotify()
	end
end

function OnDestroy()
	print("a111")
	operateMailList = {}
	MainCityUI.UpdateMailIcon(false)
	curTabSelect = 1--MailMsg_pb.MailTypeId.MailType_System
	newTab = false
	curTabDataList = nil
	jumpMailMenu = nil
	flagCount = 0
	MailListData.RemoveListener(NotifyMail)
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
end

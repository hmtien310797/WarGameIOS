module("UnionWareHouseHis", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetClickCallback = UIUtil.SetClickCallback

local UnionWareHouseHisUI
local UnionWareHouseHisMsg
local curReqPage

function Hide()
    Global.CloseUI(_M)
end

local function LoadHistoryItem(info,index)
	local v = UnionWareHouseHisMsg.resApproveInfos[index]
	local itemTBData = TableMgr:GetItemData(v.resType)
	info.transform:Find("name"):GetComponent("UILabel").text = v.name
	--num
	info.transform:Find("num"):GetComponent("UILabel").text = System.String.Format("{0}:{1}" , TextUtil.GetItemName(itemTBData) , Global.ExchangeValue2(v.applyNum))--TextUtil.GetItemName(itemTBData) .. v.applyNum

	--time
	info.transform:Find("time"):GetComponent("UILabel").text = Global.SecondToStringFormat(v.approveTime , "yyyy-MM-dd HH:mm:ss") 
	
	info.transform:Find("bg").gameObject:SetActive(index % 2 == 1)
	
	info.transform:Find("bg_select").gameObject:SetActive(v.charId == MainData.GetCharId())
end

local function UpdateHistoryMsgRecord(recordmsg)
	--
	UnionWareHouseHisMsg.more = recordmsg.more
	UnionWareHouseHisMsg.pageIndex = recordmsg.pageIndex
	curReqPage = recordmsg.pageIndex
	
	for i=1 , #recordmsg.resApproveInfos do
		UnionWareHouseHisMsg.resApproveInfos:add()
		local addIndex = #UnionWareHouseHisMsg.resApproveInfos
		UnionWareHouseHisMsg.resApproveInfos[addIndex] = recordmsg.resApproveInfos[i]
		
		local info = nil
		local v = UnionWareHouseHisMsg.resApproveInfos[addIndex]
		info = NGUITools.AddChild(UnionWareHouseHisUI.hisGrid.gameObject , UnionWareHouseHisUI.hisItem.gameObject)
		info.transform:SetParent(UnionWareHouseHisUI.hisGrid.transform , false)
		info.gameObject:SetActive(true)
		
		LoadHistoryItem(info , addIndex)
	end
	UnionWareHouseHisUI.hisGrid:Reposition()
end

local function LoadHistorList()
	while UnionWareHouseHisUI.hisGrid.transform.childCount > 0 do
		GameObject.DestroyImmediate(UnionWareHouseHisUI.hisGrid.transform:GetChild(0).gameObject)
	end
	
	for i=1 , #UnionWareHouseHisMsg.resApproveInfos do
		local info = nil
		local v = UnionWareHouseHisMsg.resApproveInfos[i]
		info = NGUITools.AddChild(UnionWareHouseHisUI.hisGrid.gameObject , UnionWareHouseHisUI.hisItem.gameObject)
		info.transform:SetParent(UnionWareHouseHisUI.hisGrid.transform , false)
		info.gameObject:SetActive(true)
		
		LoadHistoryItem(info , i)
	end
	UnionWareHouseHisUI.hisGrid:Reposition()
end

local function LoadUI()
	if UnionWareHouseHisMsg == nil then
		print("get unionWareHouse his failed")
		return
	end
	LoadHistorList()
end

local function RequestHistoryList(page , size , resFunc)
	local req = GuildMsg_pb.MsgGuildResApplyHistoryRequest()
	req.pageIndex = page
	req.pageSize = size
	Global.Request(Category_pb.Guild, GuildMsg_pb.GuildTypeId.MsgGuildResApplyHistoryRequest, req, GuildMsg_pb.MsgGuildResApplyHistoryResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
			if resFunc ~= nil then
				resFunc(msg)
			end
        end
    end)
end

function OnDrag()
	
end

function OnDragStart()
	
end

function OnDragFinish()
	--print("finish:" .. chatContentList.scrollView.transform.localPosition.y .. "fref:" .. -100 - addOldChatItemPos)
	local contentHeight = UnionWareHouseHisUI.hisGrid.transform.childCount * 40
	local constHeight = 9 * 40
	local checkHeight = math.max(0,contentHeight - constHeight) + 60
	--print(checkHeight)
	if UnionWareHouseHisUI.hisScrollView.transform.localPosition.y > checkHeight then
		--print("get record" .. curReqPage)
		
		if not UnionWareHouseHisMsg.more then
			--FloatText.Show(TextMgr:GetText("UnionWareHouse_ui25"))
			return
		end
		
		RequestHistoryList(curReqPage + 1 , 10 , function(msg)
			UpdateHistoryMsgRecord(msg)
		end)
	end
end

function Awake()
	curReqPage = 1
	UnionWareHouseHisUI = {}
	UnionWareHouseHisMsg = nil
    UnionWareHouseHisUI.mask = transform:Find("mask")
    UnionWareHouseHisUI.closeButton = transform:Find("Container/bg_frane/bg_title/btn_close"):GetComponent("UIButton")
    SetClickCallback(UnionWareHouseHisUI.mask.gameObject, Hide)
    SetClickCallback(UnionWareHouseHisUI.closeButton.gameObject, Hide)

	UnionWareHouseHisUI.hisScrollView = transform:Find("Container/bg_frane/bg_mid/Scroll View"):GetComponent("UIScrollView")
	UnionWareHouseHisUI.hisGrid = transform:Find("Container/bg_frane/bg_mid/Scroll View/Grid"):GetComponent("UIGrid")
	UnionWareHouseHisUI.hisItem = transform:Find("listitem")
	
	UnionWareHouseHisUI.hisScrollView.onDragMove =  OnDrag
	UnionWareHouseHisUI.hisScrollView.onDragStarted = OnDragStart
	UnionWareHouseHisUI.hisScrollView.onDragFinished = OnDragFinish
end

function Close()
	UnionWareHouseHisUI = nil
end


function Show(msg)
    Global.OpenUI(_M)
	RequestHistoryList(1 , 10 , function(msg)
		UnionWareHouseHisMsg = msg
		curReqPage = msg.pageIndex
		LoadUI()
	end)
   
end

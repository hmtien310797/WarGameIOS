module("ItemListShowNew", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr

local SetClickCallback = UIUtil.SetClickCallback
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local bgScrollViewGrid
local bgScrollView
local AudioMgr = Global.GAudioMgr
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local title
local itemShow
local rewardList

local itemTipTarget

local content
local showFinish
local closeMenuCallback
local showCoroutine = {}

function IsInViewport()
	return content ~= nil
end

function BringForward()
	GUIMgr:BringForward(gameObject)
end

local uiMask
local function OnCloseCallback()
	GUIMgr:CloseMenu("ItemListShowNew")
end

function SetTittle(strTittle)
	title = strTittle
end

function SetItemShow(rewardmsg)
	itemShow = rewardmsg
	ActiveHeroData.SetOldData()
end

function SetCloseMenuCallback(callback)
	closeMenuCallback = callback
end

local function OnUICameraPress(go)
	if not showFinish then
		UIUtil.UIListItemShowJumpFinish()
		return
	end
	
	if uiMask.gameObject == go then
		if Tooltip.IsItemTipActive() then
			Tooltip.HideItemTip()
			return
		else
			OnCloseCallback()
		end
	end
	if rewardList ~= nil and rewardList.data ~= nil then
		for _, v in pairs(rewardList.data) do
			if go == v.btnGo then
				local rewardName , rewardDescription
				if v.dtype == 0 then
					rewardName = TextUtil.GetItemName(v.tbData)
					rewardDescription = TextUtil.GetItemDescription(v.tbData)
				else
					rewardName = TextUtil.GetItemName(v.tbData)
					rewardDescription = TextUtil.GetItemDescription(v.tbData)
					
				end
			
				if not Tooltip.IsItemTipActive() then
					itemTipTarget = go
					Tooltip.ShowItemTip({name = rewardName, text = rewardDescription})
				else
					 if itemTipTarget == go then
						Tooltip.HideItemTip()
					else
						itemTipTarget = go
						Tooltip.ShowItemTip({name = rewardName, text = rewardDescription})
					end
				end
				return
			end
		end
	end
	Tooltip.HideItemTip()
end


local function CloseShowCoroutine()
	for i=1 , #showCoroutine , 1 do
		if showCoroutine[i] ~= nil then
			coroutine.stop(showCoroutine[i])
		end
	end
	showCoroutine = nil
end


local function AddNewShowCoroutine(showCo)
	if showCoroutine ~= nil then
		table.insert(showCoroutine , showCo)
	end
end

function Awake()
	showFinish = false
	content = {}
	showCoroutine = {}
	content.btnClose = transform:Find("bg_get props/btn_ok"):GetComponent("UIButton")
	SetClickCallback(content.btnClose.gameObject , OnCloseCallback)
	
	uiMask = transform:Find("mask")
	--SetClickCallback(uiMask.gameObject , OnCloseCallback)
	
	content.ItemInfo = ResourceLibrary.GetUIPrefab("Bag/Item_CommonNew")
	content.ItemHeroInfo = ResourceLibrary.GetUIPrefab("Hero/listitem_hero")
	
	content.ItemGrid = transform:Find("bg_get props/bg_selected/Scroll View/Grid"):GetComponent("UIGrid")
	content.ItemScrollView = transform:Find("bg_get props/bg_selected/Scroll View"):GetComponent("UIScrollView")
	AddDelegate(UICamera, "onClick", OnUICameraPress)
end

function ShowFinishCallBack()
	showFinish = true
end

function Start()
	itemTipTarget = nil
	local Title = transform:Find("bg_get props/Title/text"):GetComponent("UILabel")
	Title.text = title--TextMgr:GetText(strTittle)

	
	
	
	local showInfo = {}
	showInfo.msg = itemShow
	showInfo.ItemInfo = content.ItemInfo
	showInfo.HeroIndo = content.ItemHeroInfo
	
	rewardList = {}
	rewardList.data = {}
	rewardList.grid = content.ItemGrid
	rewardList.scrollview = content.ItemScrollView
	rewardList.data = UIUtil.FormatItemList(showInfo)
	AddNewShowCoroutine(UIUtil.UIListItemShow(rewardList , 7 , ShowFinishCallBack))
	--AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
end

function Close()
	CloseShowCoroutine()
	if closeMenuCallback ~= nil then
		closeMenuCallback()
		closeMenuCallback = nil
	end
	rewardList = {}
	content = nil
	RemoveDelegate(UICamera, "onClick", OnUICameraPress)
	local touse = ItemListData.GetItemDataByBaseId(9102)
	if touse ~= nil and touse.number > 0 then
		local req = ItemMsg_pb.MsgUseItemRequest()
		req.uid = touse.uniqueid
		req.num = 1
		Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemRequest, req, ItemMsg_pb.MsgUseItemResponse, function(msg)
			if msg.code ~= ReturnCode_pb.Code_OK then
				Global.ShowError(msg.code)
			else
				ItemListShowNew.SetTittle(TextMgr:GetText("getitem_hint"))
				ItemListShowNew.SetItemShow(msg)
				GUIMgr:CreateMenu("ItemListShowNew" , false)
				MainCityUI.UpdateRewardData(msg.fresh)
				if GUIMgr.Instance:IsMenuOpen("MainCityUI") and not GUIMgr.Instance:IsMenuOpen("WorldMap") then							
					maincity.GetBuildingListData(maincity.GetBuildingByID(1).data.uid)
				end
			end
		end)
	end
end

function Show(rewardMsg, callback, titleText)
    SetCloseMenuCallback(callback)
    ItemListShowNew.SetTittle(TextMgr:GetText(tileText or Text.getitem_hint))
    ItemListShowNew.SetItemShow(rewardMsg)
    Global.OpenUI(_M)
end

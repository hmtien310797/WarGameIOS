module("Speedup",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local BuildMsg_pb = require("BuildMsg_pb")

local btnQuit
local buildid
local buildlevel

local build
local buildingData

local bScrollViewCom

local function QuitPressCallback(go, isPressed)
	if not isPressed then
		GUIMgr:CloseMenu("Speedup")
	end
end

local function BuyPressCallback(go, isPressed)
	if not isPressed then
		print("buybuybuy")
	end
end

local function UsePressCallback(go, isPressed)
	if not isPressed then
		local useItemId = tonumber(go.transform.parent.gameObject.name)
		--print("Useuseuse" .. useItemId)
		local itemTBData = TableMgr:GetItemData(useItemId)
		local itemdata = ItemListData.GetItemDataByBaseId(useItemId)
		local usegold = false
		if itemdata == nil or itemdata.number == 0 then
			usegold = true
		end
		--print("buffid :" .. buffid .. "build : " .. build.data.uid)
		local buffdata = BuffData.HaveSameBuff(build.data.uid , itemTBData.param1)
		
		if buffdata ~= nil then
			local buffTableData = TableMgr:GetSlgBuffData(buffdata.buffId)
			print("========== buff data :" .. buffdata.uid .. " time :".. buffdata.time .. "build :" .. buffdata.buffMasterId)
			
			local okCallback = function()
				UseItem(useItemId , usegold)
				CountDown.Instance:Remove("BuffCountDown")
				MessageBox.Clear()
			end
			local cancelCallback = function()
				CountDown.Instance:Remove("BuffCountDown")
				MessageBox.Clear()
			end
			MessageBox.Show(msg, okCallback, cancelCallback)
			local mbox = MessageBox.GetMessageBox()
			if mbox ~= nil then
				CountDown.Instance:Add("BuffCountDown",buffdata.time, function(t)
					mbox.msg.text = System.String.Format(TextMgr:GetText("speedup_ui5") , TextUtil.GetSlgBuffDescription(buffTableData) , t)
					if t == "00:00:00" then
						CountDown.Instance:Remove("BuffCountDown")
					end
				end)
			end
		else
			UseItem(useItemId , usegold)
		end
	end
end

function UseItem(useItemId , usegold)
	local itemTBData = TableMgr:GetItemData(uItemid)
	local req = BuildMsg_pb.MsgAccelResouceProductionRequest()
	req.uid = maincity.GetCurrentBuildingData().data.uid
	req.itemid = useItemId
	req.buy = usegold
	Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgAccelResouceProductionRequest, req, BuildMsg_pb.MsgAccelResouceProductionResponse, function(msg)
		print("msg code " .. msg.code)
		if msg.code == 0 then
			--不播放get音效 bug ID： 1001337
			--AudioMgr:PlayUISfx("SFX_UI_props_get", 1, false)
			--FloatText.Show("道具使用成功", Color.green)
			local nameColor = Global.GetLabelColorNew(itemTBData.quality)
			local showText = System.String.Format(TextMgr:GetText("item_ui2") ,nameColor[0]..TextUtil.GetItemName(itemTBData)..nameColor[1])
			FloatText.Show(showText , Color.white)
			
			for _ , v in ipairs(msg.fresh.buff.data) do
				--print("====== " .. v.data.uid .. "=====" .. v.data.buffId .. "=====" .. v.data.buffMasterId .. "======" .. v.optype)
			end
			maincity.UpdateBuildInMsg(msg.build)
			MainCityUI.UpdateRewardData(msg.fresh)
			--end
			GUIMgr:CloseMenu("Speedup")
			
		end
	end, true)
end

function UpdateItem()
	local itemGrid = transform:Find("Container/bg_frane/Scroll View/Grid")
	local itemContent = transform:Find("ResViewinfo")
	local childCount = itemGrid.childCount
	while itemGrid.childCount > 0 do
		GameObject.DestroyImmediate(itemGrid:GetChild(0).gameObject);
	end
	
	--print(buildingData.resource_BAccelItem)
	local str = {}
	str = buildingData.resource_BAccelItem:split(";")
	print("---------- " .. buildingData.resource_BAccelItem)
	for i,v in ipairs(str) do
		local itemPar = {}
		itemPar = v:split(":")
		local itemid = tonumber(itemPar[1])
		local itemExId = tonumber(itemPar[2])
		
		print("itemid : " .. itemid .. "exitemid : " .. itemExId)
		local itemData = TableMgr:GetItemData(itemid)
		local itemExchangeData = TableMgr:GetItemExchangeData(itemExId)
		
		
		if itemExId > 0 then
			local item = NGUITools.AddChild(itemGrid.gameObject , itemContent.gameObject)
			item.gameObject:SetActive(true)
			item.gameObject.name = itemData.id
			item.transform:SetParent(itemGrid , false)
			--bg_list
			local bgList = item.transform:Find("bg_list")
			if i%2 ~= 0 then
				bgList.gameObject:SetActive(true)
			else
				bgList.gameObject:SetActive(false)
			end
			
			--icon
			local icon = item.transform:Find("bg_icon/Texture"):GetComponent("UITexture")
			icon.texture = "Icon/head/101"
			--name
			local name = item.transform:Find("bg_title/text"):GetComponent("UILabel")
			name.text = TextUtil.GetItemName(itemData)
			--des
			local des = item.transform:Find("text"):GetComponent("UILabel")
			des.text = TextUtil.GetItemDescription(itemData)
			--use button
			local useBtn = item.transform:Find("btn_use")
			SetPressCallback(useBtn.gameObject, UsePressCallback)
			--buy button
			local buyBtn  = item.transform:Find("btn_use_gold")
			SetPressCallback(buyBtn.gameObject, UsePressCallback)
			--num
			--local myItemInfo = ItemListData.GetItemDataByBaseId(itemData.id)
			local myItemInfo = ItemListData.GetItemDataByBaseId(itemid)
			local num = item.transform:Find("bg_icon/num"):GetComponent("UILabel")
			if myItemInfo ~= nil then
				useBtn.gameObject:SetActive(true)
				buyBtn.gameObject:SetActive(false)
				
				num.text = myItemInfo.number
			else
				useBtn.gameObject:SetActive(false)
				buyBtn.gameObject:SetActive(true)
				
				num.text = "[ff0000]0[-]"
				local money = item.transform:Find("btn_use_gold/num"):GetComponent("UILabel")
				money.text = itemExchangeData.price
			end
		end
	end
	local gridCom = itemGrid:GetComponent("UIGrid")
	gridCom:Reposition()
	bScrollViewCom:ResetPosition()
end

function Awake()
	BuffData.AddListener(UpdateItem)
end

function Close()
    BuffData.RemoveListener(UpdateItem)
end

function Start()
	build = maincity.GetCurrentBuildingData()
	buildingData = TableMgr:GetBuildingResourceData(build.buildingData.id , build.data.level)
	
	btnQuit = transform:Find("Container/bg_frane/bg_top/btn_close")
	SetPressCallback(btnQuit.gameObject, QuitPressCallback)
	SetClickCallback(transform:Find("Container").gameObject, function() GUIMgr:CloseMenu("Speedup") end)
	local title = transform:Find("Container/bg_frane/bg_top/title"):GetComponent("UILabel")
	title.text = TextMgr:GetText("speedup_ui1")
	
	bScrollViewCom = transform:Find("Container/bg_frane/Scroll View"):GetComponent("UIScrollView")
	UpdateItem()
end



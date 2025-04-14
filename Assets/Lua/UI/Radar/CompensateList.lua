module("CompensateList", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String
OnCloseCB = nil

local _ui = nil

local function CloseSelf()
	Global.CloseUI(_M)
end

local function RefreshList(_data)
	
end

function Awake()
	_ui = {}
	_ui.countDown = {}
	_ui.container = transform:Find("Marchlist/Container").gameObject
	_ui.btn_close = transform:Find("Marchlist/Container/bg_frane/bg_top/btn_close").gameObject
	_ui.scroll_view = transform:Find("Marchlist/Container/bg_frane/Scroll View"):GetComponent("UIScrollView")
	_ui.scroll_grid = transform:Find("Marchlist/Container/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.iteminfo_prefab = transform:Find("Marchlist/ItemInfo").gameObject
	_ui.noitem = transform:Find("Marchlist/Container/bg_frane/bg_mid/bg_noitem").gameObject
	
	SetClickCallback(_ui.container, CloseSelf)
	SetClickCallback(_ui.btn_close, CloseSelf)
	
	UnionHelpData.AddListener(RefreshUnionHelpInfo)
end

local function CheckIsContain(item, datas)
	for i, v in ipairs(datas) do
		if item.se.pathId == v.se.pathId then
			return true
		end
	end
	return false
end

function RefreshUnionHelpInfo()
	while _ui.scroll_grid.transform.childCount > 0 do
		 UnityEngine.GameObject.DestroyImmediate(_ui.scroll_grid.transform:GetChild(0).gameObject)
	end
	
	local unionMemHelpMsg = UnionHelpData.GetMemberHelpData()
	--local unionMemHelpMsg = data.compensateInfos
	
	print(#unionMemHelpMsg.compensateInfos)
	if unionMemHelpMsg.compensateInfos ~= nil then
		for i=1 , #unionMemHelpMsg.compensateInfos do
			local msgInfo = unionMemHelpMsg.compensateInfos[i]
			if msgInfo.charId == MainData.GetCharId() and msgInfo.endTime > Serclimax.GameTime.GetSecTime() then
				local info = {}
				info.go = GameObject.Instantiate(_ui.iteminfo_prefab)
				info.go.transform:SetParent(_ui.scroll_grid.transform, false)
				
				info.go.transform:Find("bg_list/foodstuff").gameObject:SetActive(false)
				info.go.transform:Find("bg_list/from").gameObject:SetActive(false)
				info.go.transform:Find("bg_list/btn_open").gameObject:SetActive(false)
				info.go.transform:Find("bg_list/Label").gameObject:SetActive(true)
				
				info.bg_icon = info.go.transform:Find("bg_list/bg_icon/Sprite"):GetComponent("UITexture")
				info.bg_icon.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/" ,"icon_plane_support" )--typeicon
				info.text_name = info.go.transform:Find("bg_list/bg_icon/bg_text/text_type/text_name"):GetComponent("UILabel")
				info.text_name.text = TextMgr:GetText("Union_Support_ui7")
				info.timeslider = info.go.transform:Find("bg_list/bg_exp/bg/bar"):GetComponent("UISlider")
				info.timetext = info.go.transform:Find("bg_list/bg_exp/bg/text"):GetComponent("UILabel")

				local _time = msgInfo.endTime -- pathInfo.starttime + pathInfo.time
				local _totalTime = msgInfo.endTime - msgInfo.triggerTime --pathInfo.time
				local cdid = string.format("compensateInfos_%d_%d_%d", msgInfo.charId , msgInfo.triggerTime ,msgInfo.endTime)
				table.insert(_ui.countDown , cdid)
				CountDown.Instance:Add(cdid , _time , CountDown.CountDownCallBack(function(t)
					leftTime = _time - Serclimax.GameTime.GetSecTime()
					if leftTime > 0 then
						local totalTime = tonumber(_totalTime)
						print(leftTime , totalTime)
						if _ui then
							info.timetext.text = t
							info.timeslider.value = 1 - (leftTime / totalTime)
						end
					else
						--RefreshUnionHelpInfo()
						CountDown.Instance:Remove(cdid)
						UnionHelpData.RequestGuildMemHelp()
					end
				end))
			end
		end
		_ui.scroll_grid:Reposition()
	end
end

function RefreshRadar()
	
end

function Start()
	
	--RefreshRadar()
end

function Update()
	
end

function LateUpdate()
	
end

function Show()
	Global.OpenUI(_M)
	
    RefreshUnionHelpInfo()
		
end
function Close()
    if OnCloseCB ~= nil then
    	OnCloseCB()
    	OnCloseCB = nil
    end
	for _, v in pairs(_ui.countDown) do
		CountDown.Instance:Remove(v)
	end
	
	UnionHelpData.RemoveListener(RefreshUnionHelpInfo)
	_ui = nil
end

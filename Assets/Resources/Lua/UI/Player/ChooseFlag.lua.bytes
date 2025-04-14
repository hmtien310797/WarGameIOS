module("ChooseFlag", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary

local currentNationality

local ui
local isInViewport = false

function IsInViewport()
	return isInViewport
end

local function SelectListItem(i)
	ui.list.items[math.max(1, i)].isSelected:SetActive(true)
end

local function UnselectListItem(i)
	ui.list.items[math.max(1, i)].isSelected:SetActive(false)
end

local function LoadUI()
	ui = {}

	ui.list = {}
	ui.list.transform = transform:Find("menu/background/scrollView/grid")
	ui.list.gameObject = ui.list.transform.gameObject
	ui.list.grid = transform:Find("menu/background/scrollView/grid"):GetComponent("UIGrid")
	-- ui.list.scrollView = transform:Find("menu/background/scrollView"):GetComponent("UIScrollView")
	
	ui.list.newItem = {}
	ui.list.newItem.transform = transform:Find("menu/newListItem")
	ui.list.newItem.gameObject = ui.list.newItem.transform.gameObject
	ui.list.newItem.flag = transform:Find("menu/newListItem/flag"):GetComponent("UITexture")
	ui.list.newItem.nationality = transform:Find("menu/newListItem/name"):GetComponent("UILabel")
	
	ui.list.items = {}
	for k, nationality in kpairs(TableMgr:GetNationalityData()) do
        if k ~= 0 then
            ui.list.newItem.flag.mainTexture = ResourceLibrary:GetIcon("Icon/Union/", nationality.texture)
            ui.list.newItem.nationality.text = TextMgr:GetText(nationality.text)

            local newItem = {}
            newItem.gameObject = NGUITools.AddChild(ui.list.gameObject, ui.list.newItem.gameObject)
            newItem.transform = newItem.gameObject.transform
            newItem.isSelected = newItem.transform:Find("flag/isSelected").gameObject

            newItem.gameObject.name = 10000 + nationality.id

            UIUtil.SetClickCallback(newItem.gameObject, function()
                if nationality.id ~= currentNationality then
                    MainData.RequestChangeNationality(nationality.id)
                elseif not ConfigData.HasSetNationality() then
                    ConfigData.SetHasSetNationality(true)
                    MainInformation.MInfoUpdate()
                end
            end)

            ui.list.items[nationality.id] = newItem
        end
	end

	ui.list.grid:Reposition()

	UIUtil.SetClickCallback(transform:Find("mask").gameObject, Hide)
	UIUtil.SetClickCallback(transform:Find("menu/background/btn_close").gameObject, Hide)
end

local function RefreshUI(previousNationality)
	if previousNationality then
		UnselectListItem(previousNationality)
	end

	SelectListItem(currentNationality)
end

local function SetCurrentNationality(_currentNationality)
	local previousNationality = currentNationality
	currentNationality = _currentNationality

	if previousNationality and previousNationality ~= currentNationality then
		RefreshUI(previousNationality)
	end
end

local function UpdateCurrentNationality()
	SetCurrentNationality(MainData.GetNationality())
end

function Show()
	Global.OpenUI(_M)
end

function Hide()
	Global.CloseUI(_M)
end

function Awake()
	LoadUI()
end

function Start()
	isInViewport = true

	UpdateCurrentNationality()
	RefreshUI()

	MainData.AddListener(UpdateCurrentNationality)
end

function Close()
	isInViewport = false

	currentNationality = nil
	ui = nil

	MainData.RemoveListener(UpdateCurrentNationality)
end

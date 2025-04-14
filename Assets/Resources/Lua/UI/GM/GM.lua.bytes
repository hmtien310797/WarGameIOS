module("GM", package.seeall)
local Controller = Global.GController
local TableMgr = Global.GTableMgr
local ResourceLibrary = Global.GResourceLibrary
local GUIMgr = Global.GGUIMgr
local TextMgr = Global.GTextMgr
local SetClickCallback = UIUtil.SetClickCallback
local SetSubmit = UIUtil.SetSubmit
local NGUITools = NGUITools

local btnBack
local btnOk
local scrollView
local grid
local itemTransform
local gmList
local currentParentId
local currentGm
local inputText
local idLabel

local function ShowCommand(parentId)
    currentParentId = parentId
    btnBack.gameObject:SetActive(currentParentId ~= 0)
    local index = 1
    for _, v in kpairs(gmList) do
        if v.parentId == parentId then
            local child = grid:GetChild(index - 1)
            if child == nil then
                child = NGUITools.AddChild(grid.gameObject, itemTransform.gameObject).transform
            end
            child.gameObject:SetActive(true)
            local childBtn = child:Find("btn"):GetComponent("UIButton")
            local childLabel = child:Find("btn/text"):GetComponent("UILabel")
            childLabel.text = v.name
            local command = v.command
            SetClickCallback(childBtn.gameObject, function()
                if command == "" then
                    ShowCommand(v.id)
                else
                    inputText.value = command
                    currentGm = v
                    inputText.isSelected = true
                end
            end)
            index = index + 1
        end
    end

    for i = index, math.huge do
        local child = grid:GetChild(i - 1)
        if child == nil then
            break
        end
        child.gameObject:SetActive(false)
    end
    grid:Reposition()
    scrollView:SetDragAmount(0, 0, false)
end

function ExecuteRemoteCommand(command, showResult)
    local req = ClientMsg_pb.MsgGMCommandRequest()
    req.command = command
    print("GM Command:", req.command)
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGMCommandRequest, req, ClientMsg_pb.MsgGMCommandResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            if showResult then
                GMLog.Show(msg.result)
            else
                print(msg.result)
            end
        end
    end, true)
end

local function OkClickCallback(go)
    if currentGm == nil then
        return
    end
    local command = inputText.value
    if currentGm.localExecute then
        local commandTable = string.split(command, " +")
        local funcName
        local argsTable = {}
        for v in string.gsplit(command, " +") do
            if funcName == nil then
                funcName = v
            elseif v ~= "" then
                table.insert(argsTable, v)
            end
        end

        loadstring(string.format("GMCommand.%s(%s)", funcName, table.concat(argsTable, ",")))()
    else
        ExecuteRemoteCommand(string.gsub(command, "=%s+", "="), true)
    end
end

local function LoadUI()
    if gmList == nil then
        gmList = {}
        local gmTable = TableMgr:GetGmTable()
		for _ , v in pairs(gmTable) do
			local value = v
            gmList[v.id] = value
		end
    end
    ShowCommand(0)
    idLabel.text = MainData.GetCharId()
end

function Awake()
    local bg = transform:Find("Container")
    SetClickCallback(bg.gameObject, function(go)
        GUIMgr:CloseMenu("GM")
    end)
    scrollView = transform:Find("Container/list_GM/Scroll View"):GetComponent("UIScrollView")
    grid = transform:Find("Container/list_GM/Scroll View/Grid"):GetComponent("UIGrid")
    itemTransform = transform:Find("GMinfo")
    btnBack = transform:Find("Container/btn_back"):GetComponent("UIButton")
    btnOk = transform:Find("Container/btn_ok"):GetComponent("UIButton")
    idLabel =  transform:Find("Container/UID"):GetComponent("UILabel")
    SetClickCallback(btnOk.gameObject, OkClickCallback)

    inputText = transform:Find("Container/frame_input"):GetComponent("UIInput")
    if UnityEngine.Application.isEditor then
        EventDelegate.Set(inputText.onSubmit, EventDelegate.Callback(OkClickCallback))
    end

    SetClickCallback(btnBack.gameObject, function()
        local parentId = gmList[currentParentId].parentId
        ShowCommand(parentId)
    end)

    LoadUI()
end

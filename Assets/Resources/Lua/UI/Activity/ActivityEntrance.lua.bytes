module("ActivityEntrance", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameStateMain = Global.GGameStateMain
local GameTime = Serclimax.GameTime
local String = System.String

local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
CurShowID = -1
OnCloseCB = nil

local functionlistdata

local function CloseClickCallback(go)
    Hide()
end

local function ShowActivity(id,l,m,func)
    --Hide()
    local f = Global.GetTableFunction("return function(id,l,m) "..func.." end")()
    f(id,l,m)
    --ActivityStage.Show(id,l,m)
end

local function AddActivity(grid,prefab,data)
    local obj = NGUITools.AddChild(grid.gameObject, prefab)
    obj.name = data.activityId
    obj:SetActive(true)
    local childLabel = obj.transform:Find("bg_list/text_name"):GetComponent("UILabel")
    local childIcon = obj.transform:Find("bg_list/background/Texture"):GetComponent("UITexture")
    local child_red_icon = obj.transform:Find("bg_list/icon_red").gameObject
    local isopen = false
    for i, v in ipairs(functionlistdata) do
    	if tonumber(v) == tonumber(data.activityId) - 1 then
    		isopen = true
    	end
    end
    if isopen then
    	childIcon.color = Color.white
    else
    	childIcon.color = Color(0.5,0.5,0.5,1)
    end
    childLabel.text = TextMgr:GetText(data.name)
    childIcon.mainTexture = ResourceLibrary:GetIcon ("Icon/Activity/", data.icon)
    
    if ActivityData.GetRedList() ~= null then
    local redlist =  ActivityData.GetRedList().count
    
    if data.countid ~= 0 and redlist ~= nil  then
        for i = 1,#(redlist) do
            --print(redlist[i].id.id,data.countid,redlist[i].count, FunctionListData.IsFunctionUnlocked(id, function() ShowActivity(tonumber( obj.name),data.leftCount,data.countMax, data.actskip) end) == nil)
            if redlist[i].id.id == data.countid and redlist[i].count > 0 and FunctionListData.IsFunctionUnlocked(id, nil) == nil then 
                obj.transform:Find("bg_list/icon_red").gameObject:SetActive(true)
            end
        end
    end
    end
    SetClickCallback(obj, function(obj)
    	--if data.activityId == 2 or data.activityId == 3 then
    		local id = data.activityId - 1
    		FunctionListData.IsFunctionUnlocked(id, function(isactive)
    			if isactive then
    				ShowActivity(tonumber( obj.name),data.leftCount,data.countMax, data.actskip)
                else
                    if obj == nil or obj:Equals(nil) then
                        return
                    end
    				FloatText.ShowAt(obj.transform.position,TextMgr:GetText(TableMgr:GetFunctionUnlockText(id)), Color.white)
    			end
    		end)
    	--end
        --ShowActivity(tonumber( obj.name),data.leftCount,data.countMax, data.actskip)
    end)
end

local function LoadUI()
	functionlistdata = FunctionListData.GetListData()
    CurShowID = -1
    local prefab = transform:Find("ActivityInfo").gameObject
    prefab:SetActive(false)
    
    local scorllView = transform:Find("Container/bg_frane/Scroll View"):GetComponent("UIScrollView")
    local grid = transform:Find("Container/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")

    local data_list = ActivityData.GetListData()
    for i= 1,#(data_list) do
        if data_list[i].templet == 0 then
            AddActivity(grid, prefab,data_list[i])
        end
    end

    grid:Reposition()
    scorllView:SetDragAmount(0, 0, false) 
    SetClickCallback(transform:Find("Container/bg_frane/bg_top/btn_close").gameObject,CloseClickCallback)
    SetClickCallback(transform:Find("Container").gameObject,CloseClickCallback)
end

function Hide()
    Global.CloseUI(_M)
    functionlistdata = nil
end

function CloseAll()
    Hide()
end


function Awake()

end

function Close()
	if OnCloseCB ~= nil then
    	OnCloseCB()
    	OnCloseCB = nil
    end
end


function Show()
    Global.OpenUI(_M)
    FunctionListData.RequestListData(function()
    	if ActivityData.GetListData() == nil then
	        ActivityData.RequestListData(LoadUI)
	    else
	        LoadUI()
	    end
    end)
    
end

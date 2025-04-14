module("MainCityQueue", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
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
local armyPathQueueSubType = 0
local goMenu = {}
local RegisterShowQueue
local OnQueueUIChange


local QueueTableType = {
	QueueTableType_Build = 1,
	QueueTableType_Camp = 2,
	QueueTableType_Plane =3,
	QueueTableType_Hospital = 4,
	QueueTableType_Equip = 5,
	QueueTableType_Union = 6,
	QueueTableType_Hero = 7,
	QueueTableType_Rune = 8,
}

local QueueType = {
    BuildQueue = 1,
    BuildQueue_1 = 2,
    BuildQueue_2 = 3,
    TechQueue = 4,
    ArmyQueue = 5,
    ArmyBarrack1Queue =6,
    ArmyBarrack2Queue =7,
    ArmyBarrack3Queue =8,
    ArmyBarrack4Queue =9,
	
	ArmyBarrack5Queue = 10,

	ArmyPathQueue = 11,
	HospitalQueue = 12,
	EquipQueue = 13,
	UnionQueue = 14,
	MilitaryQueue = 15,
	RuneQueue = 17,
	
    MaxType = 19,
}

local QueueTypeIcon ={
    "queue_building",
    "queue_building",
    "queue_building",
    "queque_tech",
    "queue_barrack",
    "icon_barrack1",
    "icon_barrack2",
    "icon_barrack3",
    "icon_barrack4",
    "array_s_camp5",
}

local QueueState = {
    QS_Free = 1,
    QS_Busy = 2,
    QS_Free_Done = 3,
    QS_Some_Busy = 4,
	QS_Go = 5,
	QS_Some_FreeDone = 6,
}

QueueStateColor = {
	"bg_bqueue_null",
    "bg_bqueue_green",
    "bg_bqueue_yellow",
    "bg_bqueue_green",
    "bg_bqueue_green",
    "bg_bqueue_yellow",
}

local MainCityQueueUI={
    Root = nil,
    QueueGrid = nil,
    IconGrid = nil,
    QueueBtn = nil,
    IconBtn = nil,
    QueuePrefab = nil,
    IconPrefab = nil,
}

local isSimple = nil

function IsSimple()
    return isSimple
end

local Queue = nil

local QueueInfo = nil
local QueueTab = nil
local QueueTableInfo = nil
local inited = false

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    Hide()
end

function AddAction2UIChange(func)
	
end


local function RemoveAllCountDown()
	for _ , v in pairs(QueueType) do
		CountDown.Instance:Remove("Queue"..v)
	end
	CountDown.Instance:Remove("Queue_rent")
end


function OnMenuClose(menuname)
	if goMenu[menuname] ~= nil then
		goMenu[menuname] = nil
		ShowQueue(false,true)
	end
end

RegisterShowQueue = function(menuname)
    if menuname ~= "Waiting" and menuname ~= "Tutorial" then
        ShowQueue(true,false)
    end
end


function LoadUI(maincity_prefab_trf)
	goMenu = {}
    inited = true
    MainCityQueueUI.Root = maincity_prefab_trf:Find("Container/arraybar")
    MainCityQueueUI.QueueGrid = maincity_prefab_trf:Find("Container/arraybar/Grid_queue"):GetComponent("UIGrid")
    MainCityQueueUI.QueueTweenPos = maincity_prefab_trf:Find("Container/arraybar/bg_array"):GetComponent("TweenPosition")
    MainCityQueueUI.QueueTweenAlpha = maincity_prefab_trf:Find("Container/arraybar/bg_array"):GetComponent("TweenAlpha")

    MainCityQueueUI.IconGrid = maincity_prefab_trf:Find("Container/arraybar/bg_queueicon/Grid_icon"):GetComponent("UIGrid")
    MainCityQueueUI.bgQueue = maincity_prefab_trf:Find("Container/arraybar/bg_queueicon")
    MainCityQueueUI.IconTweenPos = maincity_prefab_trf:Find("Container/arraybar/bg_queueicon"):GetComponent("TweenPosition")
    MainCityQueueUI.IconTweenAlpha = maincity_prefab_trf:Find("Container/arraybar/bg_queueicon"):GetComponent("TweenAlpha")
    
    MainCityQueueUI.QueueBtn = maincity_prefab_trf:Find("Container/arraybar/btn_jiantou")
    MainCityQueueUI.IconBtn = maincity_prefab_trf:Find("Container/arraybar/btn_jiantou (1)")
    MainCityQueueUI.QueuePrefab = maincity_prefab_trf:Find("Container/arraybar/bg_queue").gameObject
    MainCityQueueUI.IconPrefab = maincity_prefab_trf:Find("Container/arraybar/bg_icon").gameObject
	
	MainCityQueueUI.bgArray = {}
	MainCityQueueUI.bgArray.Root = maincity_prefab_trf:Find("Container/arraybar/bg_array")
	MainCityQueueUI.bgArray.Bg = maincity_prefab_trf:Find("Container/arraybar/bg_array/Container")
	MainCityQueueUI.bgArray.ScrollView = maincity_prefab_trf:Find("Container/arraybar/bg_array/Scroll View"):GetComponent("UIScrollView")
	MainCityQueueUI.bgArray.Table = maincity_prefab_trf:Find("Container/arraybar/bg_array/Scroll View/Table"):GetComponent("UITable")
	MainCityQueueUI.bgArray.SingleHeight = 97
	MainCityQueueUI.bgArray.TableContent = {}
	MainCityQueueUI.bgArray.TableContent[QueueTableType.QueueTableType_Build] =  maincity_prefab_trf:Find("Container/arraybar/bg_array/Scroll View/Table/bg_building") 
	MainCityQueueUI.bgArray.TableContent[QueueTableType.QueueTableType_Camp] =  maincity_prefab_trf:Find("Container/arraybar/bg_array/Scroll View/Table/bg_camp") 
	MainCityQueueUI.bgArray.TableContent[QueueTableType.QueueTableType_Plane] =  maincity_prefab_trf:Find("Container/arraybar/bg_array/Scroll View/Table/bg_plane") 
	MainCityQueueUI.bgArray.TableContent[QueueTableType.QueueTableType_Hospital] =  maincity_prefab_trf:Find("Container/arraybar/bg_array/Scroll View/Table/bg_hospital") 
	MainCityQueueUI.bgArray.TableContent[QueueTableType.QueueTableType_Equip] =  maincity_prefab_trf:Find("Container/arraybar/bg_array/Scroll View/Table/bg_equip") 
	MainCityQueueUI.bgArray.TableContent[QueueTableType.QueueTableType_Union] =  maincity_prefab_trf:Find("Container/arraybar/bg_array/Scroll View/Table/bg_union") 
	MainCityQueueUI.bgArray.TableContent[QueueTableType.QueueTableType_Hero] =  maincity_prefab_trf:Find("Container/arraybar/bg_array/Scroll View/Table/bg_hero") 
	MainCityQueueUI.bgArray.TableContent[QueueTableType.QueueTableType_Rune] =  maincity_prefab_trf:Find("Container/arraybar/bg_array/Scroll View/Table/bg_Rune") 
	
	MainCityQueueUI.bgQueue.gameObject:SetActive(false)
	ActionListData.AddListener(UpdateQueue)
	AddDelegate(GUIMgr, "onMenuClose", OnMenuClose)
	--AddDelegate(GUIMgr,"onMenuClose",OnMenuClose)
	--AddDelegate(GUIMgr,"onMenuOpen",RegisterShowQueue)
end

local function ClearQueue(tween)
	RemoveAllCountDown()
    --if tween ~= nil and tween then
    for i =1,QueueType.MaxType do
       CountDown.Instance:RemoveCallBack("Queue"..i)
	    for j=1 , armyPathQueueSubType , 1 do
			CountDown.Instance:RemoveCallBack("Queue" .. i .. j)
		end
   end
   
   
	
	
	
	
	armyPathQueueSubType = 0
   -- end
    if Queue ~= nil then
    for i =1,#(Queue) do
        if Queue[i] ~= nil and Queue[i].obj ~= nil and Queue[i].obj.gameObject ~= nil then
            Queue[i].func = nil
        Queue[i].obj.gameObject:SetActive(false)
        Queue[i].obj.transform.parent = nil
        GameObject.Destroy( Queue[i].obj.gameObject );
        Queue[i] = nil
        end
    end
    end
    Queue = nil
	QueueTableInfo = nil
end

local function SetIcon(queueType,sprite)
    sprite.spriteName = QueueTypeIcon[queueType]
end

local function SetBarColor(queueState,sprite)
	sprite.spriteName = QueueStateColor[queueState]
end

local function FreeDoneBarrack(barrackinfo , callback)
		Barrack.RequestAccelArmyTrainEx(function(msg)
		if msg.code == 0 then
		    FloatText.Show(TextMgr:GetText(barrackinfo.SoldierName).."   "..TextMgr:GetText("ui_barrack_warning9"), Color.green)
		    barrackinfo.TmpTrainNum = 0
		    barrackinfo.TimeSec = 0
		    UpdateQueue()
			if callback ~= nil then
				callback()
			end
		 else
			Global.FloatError(msg.code, Color.white)
        end
		end)    
    end

local function ShowBarrackAccUI(barrackinfo)
    CommonItemBag.OnOpenCB = function()
    end
    CommonItemBag.OnCloseCB = function() 
    end	

    local CurBuild = maincity.GetBuildingByID(barrackinfo.BarrackId)
    CommonItemBag.SetTittle(TextMgr:GetText("build_ui21"))
    CommonItemBag.NotUseAutoClose()
    CommonItemBag.NotUseFreeFinish()
    CommonItemBag.NeedItemMaxValue()
    CommonItemBag.SetEntryFlag(2)
	CommonItemBag.SetItemList(maincity.GetItemExchangeList(47), 4)
	CommonItemBag.SetMsgText("purchase_confirmation3", "s_today")
    local finish = function()
		Barrack.RequestAccelArmyTrainEx(barrackinfo,CurBuild,function(msg)
			if msg.code == 0 then
				FloatText.Show(TextMgr:GetText(barrackinfo.SoldierName).."   "..TextMgr:GetText("ui_barrack_warning9"), Color.green)
				barrackinfo.TmpTrainNum = 0
				barrackinfo.TimeSec = 0
				UpdateQueue()
				BuildingShowInfoUI.MakeTransition(CurBuild)
				MainCityUI.UpdateRewardData(msg.fresh)
			 else
				Global.FloatError(msg.code, Color.white)
			end
		end)
		CommonItemBag.SetInitFunc(nil)
		GUIMgr:CloseMenu("CommonItemBag")                        
    end

    local cancel = function()
		MessageBox.Show(TextMgr:GetText("ui_barrack_warning3"),
	    function()
			Barrack.RequestCancelArmyTrainEx(CurBuild,function(msg)
				if msg.code == 0 then
		            barrackinfo.TmpTrainNum = 0
		            barrackinfo.TimeSec = 0
		            barrackinfo.TimeSec = 0
		            UpdateQueue()
		            BuildingShowInfoUI.MakeTransition(CurBuild)
                end
			end)
			CommonItemBag.SetInitFunc(nil)
			GUIMgr:CloseMenu("CommonItemBag")
        end,
		function()
		end,
		TextMgr:GetText("common_hint1"),
		TextMgr:GetText("common_hint2"))
    end

    CommonItemBag.SetInitFunc(function()
        local _text = TextMgr:GetText(barrackinfo.SoldierName)
        local _time = barrackinfo.TimeSec
        local _totalTime = math.floor(barrackinfo.TmpTrainNum * barrackinfo.TrainTime * barrackinfo.TeamCount)
        _totalTime = Barrack.GetTrainTime(_totalTime,barrackinfo.SoldierId)
        return _text, _time, _totalTime, finish, cancel, finish, 2
    end)

	--使用加速道具 減時間
	CommonItemBag.SetUseFunc(function(useItemId , exItemid , count)
	    print("Useid : " .. useItemId .. "exid : " .. exItemid .. "count :" .. count)
	    local itemTBData = TableMgr:GetItemData(useItemId)
	    local itemdata = ItemListData.GetItemDataByBaseId(useItemId)

	    local req = ItemMsg_pb.MsgUseItemSubTimeRequest()
	    if itemdata ~= nil then
            req.uid = itemdata.uniqueid
        else
            req.exchangeId = exItemid
        end
        req.num = count
        req.buildId = CurBuild.data.uid
        req.subTimeType = 3

        Global.Request(Category_pb.Item, ItemMsg_pb.ItemTypeId.MsgUseItemSubTimeRequest, req, ItemMsg_pb.MsgUseItemSubTimeResponse, function(msg)
            print("use item code:" .. msg.code)
            if msg.code == 0 then
				local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
				if price == 0 then
					GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
				else
					GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
				end
	            useItemReward = msg.reward
	            AudioMgr:PlayUISfx("SFX_UI_building_speed", 1, false)
	            FloatText.Show(TextMgr:GetText("common_ui17") , Color.green)
	            --執行減時間
                if msg.armyTrain ~= nil  and msg.armyTrain.buildUid ~= 0 then
                    Barrack.GetAramInfo(msg.armyTrain.army.baseid,msg.armyTrain.army.level).TimeSec = msg.armyTrain.endtime
                    Barrack.GetAramInfo(msg.armyTrain.army.baseid,msg.armyTrain.army.level).Num = msg.armyTrain.army.num
                    UpdateQueue()
                else
                    FloatText.Show(TextMgr:GetText(barrackinfo.SoldierName).."   "..TextMgr:GetText("ui_barrack_warning9"), Color.green)
                    for i = 1, #(msg.fresh.arms) do
                        Barrack.UpdateArmNumEx(msg.fresh)
                    end
	                    barrackinfo.TmpTrainNum = 0
                    barrackinfo.TimeSec = 0                           
                    UpdateQueue()
                    maincity.RemoveBuildCountDown(CurBuild)

  			        CommonItemBag.SetInitFunc(nil)
                	GUIMgr:CloseMenu("CommonItemBag")              
                end
                BuildingShowInfoUI.MakeTransition(CurBuild)
	            --MoneyListData.UpdateData(msg.fresh.money.money)
	            --MainData.UpdateData(msg.fresh.maindata)
	            --ItemListData.UpdateData(msg.fresh.item)
				MainCityUI.UpdateRewardData(msg.fresh)
	            CommonItemBag.UpdateTopProgress()
            else
                print(msg.code)
                Global.FloatError(msg.code, Color.white)
            end
        end, true)
	end)
	local obj = GUIMgr:CreateMenu("CommonItemBag" , false)
	goMenu["CommonItemBag"] = "CommonItemBag"
end

local function FreeDoneTech(tech , callback)
    Laboratory.RequestTechUpAccl(function(msg)
        if tech.Info.endtime <= Serclimax.GameTime.GetSecTime() then
            FloatText.Show(TextMgr:GetText(tech.BaseData.Name).."  LV."..tech.Info.level.."   "..TextMgr:GetText("build_ui39"), Color.green)
            Global.GAudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed",1,false)
            Laboratory.ClearCurTechState()
            UpdateQueue()
				MainData.RequestData()
			MainCityUI.FlyExp(maincity.GetBuildingByID(6))
			maincity.GetBuildingByID(6).techfree = false
			if callback ~= nil then
				callback()
			end
        end
    end)
end

local function ShowTechAccUI(tech)
    CommonItemBag.OnOpenCB = function()
    end
    
    CommonItemBag.OnCloseCB = function()
        maincity.RefreshBuildingTransition(maincity.GetBuildingByID(6))
        UpdateQueue();
    end	    
		    
    CommonItemBag.SetTittle(TextMgr:GetText("build_ui21"))
    CommonItemBag.NotUseAutoClose()
    CommonItemBag.NeedItemMaxValue()
    CommonItemBag.SetEntryFlag(1)
    CommonItemBag.SetItemList(maincity.GetItemExchangeList(2), 1)
    CommonItemBag.SetMsgText("purchase_confirmation2", "t_today")
    local finish = function(go)
        Laboratory.RequestTechUpAccl(function(msg) 
            if tech.Info.endtime <= Serclimax.GameTime.GetSecTime() then
                FloatText.Show(TextMgr:GetText(tech.BaseData.Name).."  LV."..tech.Info.level.."   "..TextMgr:GetText("build_ui39"), Color.green)
                Global.GAudioMgr:PlayUISfx("SFX_UI_sciencetechnology_research_succeed",1,false)                
                Laboratory.ClearCurTechState(true)
                UpdateQueue()
 				--MoneyListData.UpdateData(msg.fresh.money.money)
				MainCityUI.UpdateRewardData(msg.fresh)
				CommonItemBag.SetInitFunc(nil)
				GUIMgr:CloseMenu("CommonItemBag")
            end
        end)
    end
    
    local cancel = function(go)
		MessageBox.Show(TextMgr:GetText("speedup_ui10"), function()
        	Laboratory.RequestTechUpCancel(function(msg) 
            	if tech.Info.endtime <= Serclimax.GameTime.GetSecTime() then
                	Laboratory.ClearCurTechState(false)
                	UpdateQueue()
 					--MoneyListData.UpdateData(msg.fresh.money.money)
					MainCityUI.UpdateRewardData(msg.fresh)
					CommonItemBag.SetInitFunc(nil)
					GUIMgr:CloseMenu("CommonItemBag")
            	end
        	end)
		end, function()
		end,
		TextMgr:GetText("common_hint1"),
		TextMgr:GetText("common_hint2"))
    end
    
    CommonItemBag.SetInitFunc(function()
        
        local level = tech.Info.level == 0 and 1 or math.min( tech.Info.level+1,tech.BaseData.MaxLevel)
    	local _text = TextMgr:GetText(tech.BaseData.Name).."  LV. "..level
    	local _time = tech.Info.endtime
    	local _totalTime =  Laboratory.GetTechCostTime(tech[level].CostTime)
    	return _text, _time, _totalTime, finish, cancel, finish, 3, UnionHelpData.RequestTechHelp, tech.Info.beginTime
    end)
	
	--使用加速道具 減時間
	CommonItemBag.SetUseFunc(function(useItemId , exItemid , count)
	     Laboratory.RequestItemSubTime(tech,useItemId,exItemid,count, function(msg) 
		    local price = MoneyListData.ComputeDiamond(msg.fresh.money.money)
			if price == 0 then
				GUIMgr:SendDataReport("purchase", "useitem", "" ..useItemId, "" ..count)
			else
				GUIMgr:SendDataReport("purchase", "costgold", "" ..useItemId, "" ..count, "" .. price)
			end
			useItemReward = msg.reward
		    AudioMgr:PlayUISfx("SFX_UI_building_speed", 1, false)
		    FloatText.Show(TextMgr:GetText("common_ui17"), Color.green)
            local ttech = Laboratory.GetTech(msg.tech.techid)
            if ttech ~= nil and msg.tech.techid ~= 0 then
               
            else
                if tech ~= nil then
                    tech.Info.endtime = 0
                    tech.Info.level = math.min(tech.Info.level + 1, tech.BaseData.MaxLevel)
                end     
                Laboratory.ClearCurTechState(true)
                UpdateQueue();
	  		    CommonItemBag.SetInitFunc(nil)
	            GUIMgr:CloseMenu("CommonItemBag") 
            end
  
			MainCityUI.UpdateRewardData(msg.fresh)
		    CommonItemBag.UpdateTopProgress()     
	    end)
	end)
    
	GUIMgr:CreateMenu("CommonItemBag" , false)
	goMenu["CommonItemBag"] = "CommonItemBag"
end

local function FreeDoneBuild(_build , callback)
	local req = BuildMsg_pb.MsgAccelBuildUpdateRequest()
	req.uid = _build.data.uid
	Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgAccelBuildUpdateRequest, req, BuildMsg_pb.MsgAccelBuildUpdateResponse, function(msg)
	    if msg.code == 0 then
	         FloatText.Show(TextMgr:GetText(_build.buildingData.name).."  LV."..(_build.data.level + 1).."   "..TextMgr:GetText("build_ui39"), Color.green)
	        AudioMgr:PlayUISfx("SFX_UI_building_speed", 1, false)
			maincity.UpdateBuildInMsg(msg.build, msg.build.donetime)
			MainCityUI.UpdateRewardData(msg.fresh)
			MainCityUI.FlyExp(maincity.GetBuildingByUID(msg.build.uid))
			if maincity.GetBuildingByUID(msg.build.uid) ~= nil then
				maincity.GetBuildingByUID(msg.build.uid).buildingfree = false
			end
			UpdateQueue()
			if callback ~= nil then
				callback()
			end
		else
            Global.FloatError(msg.code, Color.white)
	    end
    end, true)
end

local  function ShowBuildAccUI(_build)
    local noitem = Global.BagIsNoItem(maincity.GetItemExchangeList(1))
    if noitem then
        AudioMgr:PlayUISfx("SFX_ui02", 1, false)
        FloatText.Show(TextMgr:GetText("speedup_ui13"), Color.white)
        return
    end
    CommonItemBag.SetTittle(TextMgr:GetText("build_ui21"))
	CommonItemBag.NotUseAutoClose()
	CommonItemBag.NeedItemMaxValue()
	CommonItemBag.SetEntryFlag(0)
	CommonItemBag.SetItemList(maincity.GetItemExchangeList(1), 1)
	CommonItemBag.SetMsgText("purchase_confirmation2", "b_today")
	local finish = function(go)
	local req = BuildMsg_pb.MsgAccelBuildUpdateRequest()
	req.uid = _build.data.uid
	Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgAccelBuildUpdateRequest, req, BuildMsg_pb.MsgAccelBuildUpdateResponse, function(msg)
	    if msg.code == 0 then
	         FloatText.Show(TextMgr:GetText(_build.buildingData.name).."  LV."..(_build.data.level + 1).."   "..TextMgr:GetText("build_ui39"), Color.green)
	        AudioMgr:PlayUISfx("SFX_UI_building_speed", 1, false)
			maincity.UpdateBuildInMsg(msg.build, msg.build.donetime)
			--MoneyListData.UpdateData(msg.fresh.money.money)
			MainCityUI.UpdateRewardData(msg.fresh)
			UpdateQueue()
			CommonItemBag.SetInitFunc(nil)
			GUIMgr:CloseMenu("CommonItemBag")
		else
            Global.FloatError(msg.code, Color.white)
        end
    end, true)
	end
    local cancelreq = function()
	local req = BuildMsg_pb.MsgCancelBuildUpdateRequest()
	    req.uid = _build.data.uid
	    Global.Request(Category_pb.Build, BuildMsg_pb.BuildTypeId.MsgCancelBuildUpdateRequest, req, BuildMsg_pb.MsgCancelBuildUpdateResponse, function(msg)
	        if msg.code == 0 then
	        	AudioMgr:PlayUISfx("SFX_UI_building_levelupcancel", 1, false)
	        	maincity.UpdateBuildInMsg(msg.build, msg.build.donetime)
				--MoneyListData.UpdateData(msg.fresh.money.money)
				MainCityUI.UpdateRewardData(msg.fresh)
				CommonItemBag.SetInitFunc(nil)
				UpdateQueue()
				GUIMgr:CloseMenu("CommonItemBag")
				MainCityUI.NotifyCancelUpgradeListener()
				else
                    Global.FloatError(msg.code, Color.white)
	        	end
	    end)
	end
	local cancel = function(go)
	    MessageBox.Show(TextMgr:GetText("speedup_ui10"), cancelreq, function() end)
	end
    --table.foreach(_build,function(i,v) print(i,v) end)
	CommonItemBag.SetInitFunc(function()
	    local _text = String.Format("{0}  LV. {1}", TextMgr:GetText(_build.buildingData.name), _build.data.level + 1)
	    local _time = _build.data.donetime
	    local _totalTime = _build.data.originaltime
	    return _text, _time, _totalTime, finish, cancel, finish, 1, function() UnionHelpData.RequestBuildHelp(_build.data.uid) end , _build.data.createtime , _build.data.uid
	end)
	CommonItemBag.SetUseFunc(function(useItemId , exItemid , count)
	MainCityUI.UseExItemFuncEx(_build,useItemId,exItemid,count)
    end)
	GUIMgr:CreateMenu("CommonItemBag" , false)
	goMenu["CommonItemBag"] = "CommonItemBag"
	CommonItemBag.OnOpenCB = function()
	end
    CommonItemBag.OnCloseCB = function() 
    end	
end

local  function ShowHospitalAccUI(_build)
	Hospital.testShow()
end

local  function ShowEquipAccUI(_build)
	EuipBuil.Show()
end

local function SetOpenUI(queueType)
    if queueType > QueueType.BuildQueue and queueType < QueueType.TechQueue then 
		AudioMgr:PlayUISfx("SFX_ui02", 1, false)
        FloatText.Show(TextMgr:GetText("queue_ui1") , Color.white)
    elseif queueType == QueueType.TechQueue then 
        Laboratory.Show()
    elseif  queueType > QueueType.ArmyQueue and queueType <= QueueType.ArmyBarrack4Queue then 
        Barrack.Show(20+queueType-5)
    end
end

local function SetQueueSpeedUp(queueType,obj)	
	RemoveAllCountDown()
    if queueType > QueueType.BuildQueue and queueType < QueueType.TechQueue then 
        ShowBuildAccUI(obj)
    elseif queueType == QueueType.TechQueue then 
        ShowTechAccUI(obj)
    elseif  queueType > QueueType.ArmyQueue and queueType <= QueueType.ArmyBarrack4Queue then 
        ShowBarrackAccUI(obj)
	elseif queueType == QueueType.ArmyBarrack5Queue then
		ShowBarrackAccUI(obj)
	elseif queueType >= QueueType.ArmyPathQueue and queueType < QueueType.HospitalQueue then
		local targetPos = MapInfoData.GetData().mypos
		ShowQueue(true,false)
		goMenu["WorldMap"] = "WorldMap"
		MainCityUI.ShowWorldMap(targetPos.x , targetPos.y , true , function()
			ActionList.Show()
		end , nil)
	elseif queueType == QueueType.HospitalQueue then
		local hosBuilding =maincity.GetBuildingByID(3)
		Hospital.SetBuild(hosBuilding)
		GUIMgr:CreateMenu("Hospital",false)
		goMenu["Hospital"] = "Hospital"
    end
end

local function SetClickGo2(queueType , queueState , go2Param)
	RemoveAllCountDown()
	if queueType == QueueType.HospitalQueue then
		local hosBuilding =maincity.GetBuildingByID(3)
		if hosBuilding ~= nil then
			Hospital.SetBuild(hosBuilding)
			GUIMgr:CreateMenu("Hospital",false)
			goMenu["Hospital"] = "Hospital"
		else
			ShowQueue(true,false)
			maincity.SetEmptyZiyuantianTarget()
		end
	elseif queueType == QueueType.EquipQueue then
		local equipBuil = maincity.GetBuildingByID(44)
		if equipBuil ~= nil then
			EquipMainNew.Show()
			goMenu["EquipMainNew"] = "EquipMainNew"
		else
			ShowQueue(true,false)
			GrowGuide.Show(maincity.SetTargetBuild(44, true, nil, false).land.transform, nil)
		end
	elseif queueType >= QueueType.MilitaryQueue and queueType < QueueType.MilitaryQueue + 2 then
		MilitarySchool.Show()
		goMenu["MilitarySchool"] = "MilitarySchool"
	elseif queueType >= QueueType.RuneQueue and  queueType < QueueType.RuneQueue + 2 then
		FunctionListData.IsFunctionUnlocked(305, function(isactive)
			if isactive then
				Rune.Show(3)
				goMenu["Rune"] = "Rune"
			else
				FloatText.Show(TextMgr:GetText("ui_rune_44"), Color.white)
			end
		end)
	elseif queueType == QueueType.UnionQueue then
		if UnionInfoData.HasUnion() then
			--[[UnionTec.Show()
			goMenu["UnionTec"] = "UnionTec"]]
			Union_donate.Show()
			goMenu["Union_donate"] = "Union_donate"
		else
			JoinUnion.Show()
			goMenu["JoinUnion"] = "JoinUnion"
		end
	elseif queueType >= QueueType.ArmyPathQueue and queueType < QueueType.HospitalQueue then
		local targetPos = go2Param.tarpos --== nil and go2Param or MapInfoData.GetData().mypos
		goMenu["WorldMap"] = "WorldMap"
		ShowQueue(true,false)
		MainCityQueueUI.bgQueue.gameObject:SetActive(false)
		MainCityQueueUI.Root.gameObject:SetActive(false)
		
		if go2Param.isGuildMoba then
			UnionMobaActivityData.RequestMobaEnter(function()
                Global.SetSlgMobaMode(2)
                MainCityUI.ShowWorldMap(nil, nil, true, nil)
            end)
		else
			MainCityUI.ShowWorldMap(targetPos.x , targetPos.y , true)
		end
		
	elseif queueType == QueueType.TechQueue then 
		Laboratory.Show()
		goMenu["Laboratory"] = "Laboratory"
	elseif  queueType > QueueType.ArmyQueue and queueType <= QueueType.ArmyBarrack4Queue then 
        Barrack.Show(20+queueType-5)
		goMenu["Barrack"] = "Barrack"
		--goMenu["Barrack"] = "Barrack"		
	elseif queueType == QueueType.ArmyBarrack5Queue then 
		Barrack.Show(27) 
		goMenu["Barrack"] = "Barrack"
	elseif queueType > QueueType.BuildQueue and queueType < QueueType.TechQueue then

		--local builIndex = nil
		
		--if go2Param ~= nil and go2Param.queueIndex ~= nil then
		--	builIndex = go2Param.queueIndex
		--end
		--VIP.Show(Global.CheckBuildQueue(builIndex))
		--goMenu["VIP"] = "VIP"

		QueueLease.Show()
		goMenu["QueueLease"] = "QueueLease"		
    end
end

local function SetQueueFreeDone(queueType,obj , callback)
    if queueType > QueueType.BuildQueue and queueType < QueueType.TechQueue then 
		--ShowQueue(true,false)
        FreeDoneBuild(obj , callback)
    elseif queueType == QueueType.TechQueue then 
		--ShowQueue(true,false)
        FreeDoneTech(obj , callback)
    elseif  queueType > QueueType.ArmyQueue and queueType <= QueueType.ArmyBarrack4Queue then 
		--ShowQueue(true,false)
        FreeDoneBarrack(obj , callback)
    end
end

local function SetQueueCountDownFinish(queueType,obj)
    if queueType > QueueType.BuildQueue and queueType < QueueType.TechQueue then 
       FloatText.Show(TextMgr:GetText(obj.buildingData.name).."  LV."..obj.data.level.."   "..TextMgr:GetText("build_ui39"), Color.green)
    elseif queueType == QueueType.TechQueue then 
       FloatText.Show(TextMgr:GetText(obj.BaseData.Name).."  LV."..math.min( obj.Info.level+1,obj.BaseData.MaxLevel).."   "..TextMgr:GetText("build_ui39"), Color.green)
       Laboratory.ClearCurTechState(true)
    elseif  queueType > QueueType.ArmyQueue and queueType <= QueueType.ArmyBarrack4Queue then 
       FloatText.Show(TextMgr:GetText(obj.SoldierName).."   "..TextMgr:GetText("ui_barrack_warning9"), Color.green)
    end
end
local function AddQueue(queueType,queueState,des,endtime,totalTime,target_obj , queueGridTrf , btngo2 , queueIcon ,go2Param , freeEff,showLine,rent_time)
    local qobj = {}
	local obj=nil
	
	if Queue[queueType] == nil or Queue[queueType].obj == nil then
		if queueGridTrf ~= nil then
			obj = NGUITools.AddChild(queueGridTrf.gameObject, MainCityQueueUI.QueuePrefab)
		else
			obj = NGUITools.AddChild(MainCityQueueUI.QueueGrid.gameObject, MainCityQueueUI.QueuePrefab)
		end
	else
		obj = Queue[queueType].obj
	end
	
    obj.name = queueType
    obj:SetActive(true)
    local bg = obj:GetComponent("UISprite")
    local icon = obj.transform:Find("icon"):GetComponent("UISprite")
    local bar =  obj.transform:Find("bar"):GetComponent("UISprite")
    local text =  obj.transform:Find("text"):GetComponent("UILabel")
    local time =  obj.transform:Find("time"):GetComponent("UILabel")
    local speedup =  obj.transform:Find("btn_speedup").gameObject
    local free =  obj.transform:Find("btn_free").gameObject
    local help = obj.transform:Find("btn_help").gameObject
	local go2 = obj.transform:Find("btn_go").gameObject
	local eff = obj.transform:Find("Sprite").gameObject
    obj.transform:Find("line").gameObject:SetActive(showLine == true)
    if queueState == QueueState.QS_Free then
        bg.enabled = false
    else
        bg.enabled = true
    end
    
    if queueIcon ~= nil then
		icon.spriteName = queueIcon
	else
		SetIcon(queueType,icon)
	end
	
	
	SetBarColor(queueState,bar)
	
	
    text.text = des
    qobj.func = nil
	local countDownKey = "Queue" .. queueType
    if endtime ~= nil and (endtime+1 -  Serclimax.GameTime.GetSecTime()) > 0 then
		
		if go2Param ~= nil and go2Param.queueSub ~= nil then
			countDownKey = "Queue" .. queueType .. go2Param.queueSub
		end
		--CountDown.Instance:Remove("Queue"..queueType)
		obj.func = function(t)
			if time ~= nil and goMenu ~= nil and bar ~= nil and MainCityUI.transform~=nil   then
				time.text  = t
				--print((endtime+1 - Serclimax.GameTime.GetSecTime()) , totalTime , ((endtime+1 - Serclimax.GameTime.GetSecTime())/totalTime) , (1-  math.min(1 , ((endtime+1 - Serclimax.GameTime.GetSecTime())/totalTime))   ))
				if go2Param ~= nil and go2Param.timeModeDown then
					bar.width =	 math.min(1 , ((endtime+1 - Serclimax.GameTime.GetSecTime())/totalTime))*280
				else
					bar.width =	 (1-  math.min(1 , ((endtime+1 - Serclimax.GameTime.GetSecTime())/totalTime))   )*280
				end
				
				if endtime+1 -  Serclimax.GameTime.GetSecTime() <= 0 then	
					CountDown.Instance:Remove(countDownKey)  
					SetQueueCountDownFinish(queueType,target_obj)
					ShowQueue(isSimple,false)
				end		
			end			
		end
		
		
        CountDown.Instance:Add(countDownKey,endtime,CountDown.CountDownCallBack(function(t) 
			if obj ~=nil then
				if obj.func~=nil then
					obj.func(t) 
				end
			end
        end))   
    else
		if go2Param ~= nil and go2Param.timeLabel ~= nil then
			time.text = go2Param.timeLabel
		else
			time.gameObject:SetActive(false)
		end
    end
	
	if rent_time ~= nil then
		text.text = System.String.Format(TextMgr:GetText("ui_QueueLease6"),Serclimax.GameTime.SecondToString3((rent_time - Serclimax.GameTime.GetSecTime()))) 
		CountDown.Instance:Add("Queue_rent",rent_time,CountDown.CountDownCallBack(function(t) 
			local sec = rent_time - Serclimax.GameTime.GetSecTime()
			text.text = System.String.Format(TextMgr:GetText("ui_QueueLease6"),Serclimax.GameTime.SecondToString3((sec))) 
			if sec == 0 then
				CountDown.Instance:Remove("Queue_rent")
				UpdateQueue()
			end
        end)) 
	end

    speedup:SetActive(false)
    free:SetActive(false)
	help:SetActive(false)
	go2:SetActive(false)

	if queueState == QueueState.QS_Free_Done then
	    free:SetActive(true)
	    SetClickCallback(free,function() 
            SetQueueFreeDone(queueType,target_obj , function()
				--SetBarColor(QueueState.QS_Free,bar)
				--bar.width = 280
				CountDown.Instance:Remove(countDownKey)  
				--SetQueueCountDownFinish(queueType,target_obj)
				bar.width = 280
			end)
        end)
	      
	elseif queueState == QueueState.QS_Busy then
        --print(queueType == QueueType.TechQueue,UnionHelpData.HasTechHelp(),endtime - totalTime,UnionInfoData.GetJoinTime())
		
        if queueType > QueueType.BuildQueue and queueType < QueueType.TechQueue and UnionHelpData.HasBuildHelp(target_obj.data.uid) then
			if endtime - totalTime >= UnionInfoData.GetJoinTime() then
				help:SetActive(true)
				SetClickCallback(help,function()
					--info.obj
					UnionHelpData.RequestBuildHelp(target_obj.data.uid)
					help:SetActive(false)
					speedup:SetActive(true)
					SetClickCallback(speedup,function() 
						SetQueueSpeedUp(queueType,target_obj)
					end)                   
				end)  
			else
				speedup:SetActive(true)
				SetClickCallback(speedup,function() 
					SetQueueSpeedUp(queueType,target_obj)
				end)
			end
        elseif UnionHelpData.HasTechHelp() and queueType == QueueType.TechQueue then
            if endtime - totalTime >= UnionInfoData.GetJoinTime() then
                help:SetActive(true)
                SetClickCallback(help,function() 
                    UnionHelpData.RequestTechHelp()
                    help:SetActive(false)
                    speedup:SetActive(true)
                    SetClickCallback(speedup,function() 
                        SetQueueSpeedUp(queueType,target_obj)
                    end)                   
                end)  
            else
            	speedup:SetActive(true)
	            SetClickCallback(speedup,function() 
	                SetQueueSpeedUp(queueType,target_obj)
	            end)
            end
        else
            speedup:SetActive(true)
            SetClickCallback(speedup,function() 
                SetQueueSpeedUp(queueType,target_obj)
            end)
        end
    end
    if queueState == QueueState.QS_Free then
		eff:SetActive(freeEff ~= nil and freeEff)
		SetClickCallback(bar.gameObject, function(obj)
			SetOpenUI(queueType)
		end) 
    end
	
	if btngo2 then
		go2:SetActive(true)
		speedup:SetActive(false)
		help:SetActive(false)
		free:SetActive(false)
		SetClickCallback(go2 , function()
			SetClickGo2(queueType ,queueState , go2Param)
		end)
	end

    qobj.obj = obj
    --table.insert(Queue,qobj)
	Queue[queueType] = qobj
end
local function AddQueueNew(queueType,queueState,des,endtime,totalTime,target_obj , btngo2 , go2Param, icon ,queueGrid ,freeEff,showLine,rent_time)
	AddQueue(queueType,queueState,des,endtime,totalTime,target_obj,queueGrid , btngo2 , icon , go2Param , freeEff,showLine,rent_time)
end

local function AddSimpleQueue(queueType,queueState,num)
    local qobj = {}
    local obj = NGUITools.AddChild(MainCityQueueUI.IconGrid.gameObject, MainCityQueueUI.IconPrefab)
    obj.name = queueType
    obj:SetActive(true)
    local bg = obj:GetComponent("UISprite")    
    local icon = obj.transform:Find("icon"):GetComponent("UISprite")
    local bar =  obj.transform:Find("bar"):GetComponent("UISprite")
    local time =  obj.transform:Find("time"):GetComponent("UILabel")
    local reddot = obj.transform:Find("red dot").gameObject
	if queueState == QueueState.QS_Free or queueState == QueueState.QS_Some_Busy or queueState == QueueState.QS_Some_FreeDone then
		reddot:SetActive(true)
	else
		reddot:SetActive(false)
	end
    if queueState == QueueState.QS_Free then
        bg.enabled = false
    else
        bg.enabled = true
    end
	

    SetIcon(queueType,icon)
    
	SetBarColor(queueState,bar)
	
    if num > 0 then
        time.text = num
    else
        time.gameObject:SetActive(false)
    end
    SetClickCallback(bar.gameObject, function(obj)
        ShowQueue(false,true)
    end)    
    qobj.obj = obj
    table.insert(Queue,qobj)
end

local function UpdateQueueInfo1()
	QueueTableInfo = {}
    QueueInfo = {}
	QueueTab = {}
    local info = {}
    --build
    local buildQueue = 2 --建筑队列容量，应读表
	local upgrading = maincity.GetUpgradingBuildList()
	for i=1 , buildQueue , 1 do
		info = {}
		info.queueType = QueueType.BuildQueue + i
		local unlock = Global.CheckBuildQueue(i) <= MainData.GetVipLevel()
		if unlock then
			local upbuild = #(upgrading)>=i and upgrading[i] or nil
			if upbuild ~= nil then
				info.obj = upgrading[i]
				info.queueState = QueueState.QS_Busy
				info.name = TextMgr:GetText(upgrading[i].buildingData.name).." LV."..(upgrading[i].data.level + 1)
				info.lv =  upgrading[i].data.level
				info.endtime = upgrading[i].data.donetime
				info.totalTime = upgrading[i].data.originaltime
				if upgrading[i].data.donetime-1  -  Serclimax.GameTime.GetSecTime() <= maincity.freetime() then
					info.queueState = QueueState.QS_Free_Done
				end
				if upgrading[i].data.donetime-1 <=  Serclimax.GameTime.GetSecTime() then
					info.totalTime = nil 
					info.endtime = nil
					info.name = TextMgr:GetText("queue_ui1")
					info.queueState = QueueState.QS_Free
					info.freeEff = true
				end
			else
				info.name = TextMgr:GetText("queue_ui1")
				info.queueState = QueueState.QS_Free
				info.freeEff = true
			end
		else
			info.name = TextMgr:GetText("maincity_ui17")
			info.queueState = QueueState.QS_Free
			info.freeEff = true
			info.go2 = true
			info.go2Param = {}
			info.go2Param.queueIndex = i
		end
		table.insert(QueueInfo,info)
		table.insert(QueueTab , info)
	end
	QueueTableInfo[QueueTableType.QueueTableType_Build] = QueueTab
end

local function UpdateQueueInfo()
	QueueTableInfo = {}
    QueueInfo = {}
	QueueTab = {}
    local info = {}
    --build
    local buildQueue = 2 --建筑队列容量，应读表
	local upgrading = maincity.GetUpgradingBuildList()
	local buildQueueNum = 0
	local unlockQueueNum = 0
	local freeDoneNum = 0
	local freeNum = 0
	for i=1 , buildQueue , 1 do
		info = {}
		info.queueType = QueueType.BuildQueue + i
		local unlock = Global.CheckBuildQueue(i) <= MainData.GetVipLevel()
		if unlock then
			unlockQueueNum = unlockQueueNum + 1
			local upbuild = #(upgrading)>=i and upgrading[i] or nil
			if upbuild ~= nil then
				info.obj = upgrading[i]
				info.queueState = QueueState.QS_Busy
				info.name = TextMgr:GetText(upgrading[i].buildingData.name).." LV."..(upgrading[i].data.level + 1)
				info.lv =  upgrading[i].data.level
				info.endtime = upgrading[i].data.donetime
				info.totalTime = upgrading[i].data.originaltime
				if upgrading[i].data.donetime-1  -  Serclimax.GameTime.GetSecTime() <= maincity.freetime() then
					info.queueState = QueueState.QS_Free_Done
					freeDoneNum = freeDoneNum + 1
					
				end
				if upgrading[i].data.donetime-1 <=  Serclimax.GameTime.GetSecTime() then
					info.totalTime = nil 
					info.endtime = nil
					info.name = TextMgr:GetText("queue_ui1")
					info.queueState = QueueState.QS_Free
					info.freeEff = true
					freeNum = freeNum + 1
				end
				buildQueueNum = buildQueueNum + 1
			else
				info.name = TextMgr:GetText("queue_ui1")
				info.queueState = QueueState.QS_Free
				info.freeEff = true
			end
		else
			if(Serclimax.GameTime.GetSecTime() >= MainData.GetRentBuildQueueExpire()) then
				info.name = TextMgr:GetText("maincity_ui17")
				info.queueState = QueueState.QS_Free
				info.freeEff = true
				info.go2 = true
				info.go2Param = {}
				info.go2Param.queueIndex = i
			else
				unlockQueueNum = unlockQueueNum + 1
				local upbuild = #(upgrading)>=i and upgrading[i] or nil
				if upbuild ~= nil then
					info.obj = upgrading[i]
					info.queueState = QueueState.QS_Busy
					info.name = TextMgr:GetText(upgrading[i].buildingData.name).." LV."..(upgrading[i].data.level + 1)
					info.lv =  upgrading[i].data.level
					info.endtime = upgrading[i].data.donetime
					info.totalTime = upgrading[i].data.originaltime
					if upgrading[i].data.donetime-1  -  Serclimax.GameTime.GetSecTime() <= maincity.freetime() then
						info.queueState = QueueState.QS_Free_Done
						freeDoneNum = freeDoneNum + 1
					end
					if upgrading[i].data.donetime-1 <=  Serclimax.GameTime.GetSecTime() then
						info.totalTime = nil 
						info.endtime = nil
						info.name = TextMgr:GetText("queue_ui1")
						info.queueState = QueueState.QS_Free
						info.freeEff = true
						freeNum = freeNum + 1
					end
					buildQueueNum = buildQueueNum + 1
				else
					
					info.rent_time = MainData.GetRentBuildQueueExpire()
					info.name = TextMgr:GetText("queue_ui1")
					info.queueState = QueueState.QS_Free
					info.freeEff = true
				end
			end
		end
		
		info.freeEff = not maincity.IsAllBuildingMaxLevel()
		
		table.insert(QueueTab , info)
	end
	
	if unlockQueueNum >= 0 then
		info = {}
        info.queueType = QueueType.BuildQueue
		
		if buildQueueNum == 0 then
			info.queueState = QueueState.QS_Free
			info.freeEff = true
		else
			if buildQueueNum < unlockQueueNum then
				info.queueState = QueueState.QS_Some_Busy
				if freeDoneNum > 0 then
					info.queueState = QueueState.QS_Some_FreeDone
				end
			else
				info.queueState = QueueState.QS_Busy
				if freeDoneNum > 0 then	
					info.queueState = QueueState.QS_Free_Done
				end
			end
			
			
			if freeNum == buildQueueNum then
				info.queueState = QueueState.QS_Free
			end
		end
		
		info.name = ""
        info.lv = unlockQueueNum - buildQueueNum
        --print(info.queueType,info.lv,info.queueState)
        info.endtime = 0 
		
		table.insert(QueueInfo,info)
	end
	
    --laboratory
    local build = maincity.GetBuildingByID(6)
    if build ~= nil then
        info = {}
        info.queueType = QueueType.TechQueue
        --print("QueueType.TechQueue : " , QueueType.TechQueue)
        upgrading = Laboratory.GetCurUpgradeTech()
        if upgrading ~= nil and upgrading.Info.endtime > Serclimax.GameTime.GetSecTime() then
            info.obj = upgrading
            info.queueState = QueueState.QS_Busy
            local level = math.min( upgrading.Info.level+1,upgrading.BaseData.MaxLevel)
            info.name = TextMgr:GetText(upgrading.BaseData.Name).." LV."..level
            
            info.lv = level
            info.beginTime = upgrading.Info.beginTime
            info.endtime = upgrading.Info.endtime
            info.totalTime = upgrading.Info.originaltime--Laboratory.GetTechCostTime(upgrading[level].CostTime)
            if upgrading.Info.endtime  -  Serclimax.GameTime.GetSecTime() <= maincity.techFreeTime() then
                info.queueState = QueueState.QS_Free_Done
            end            
        else
            info.name = TextMgr:GetText("queue_ui2")
            info.queueState = QueueState.QS_Free
			info.go2 = true
			info.freeEff = true
			if upgrading ~= nil then
                upgrading.Info.level = math.min(upgrading.Info.level + 1,upgrading.BaseData.MaxLevel)
                Laboratory.ClearCurTechState(true)
            end
        end
        table.insert(QueueInfo,info)
		table.insert(QueueTab , info)
    end
	QueueTableInfo[QueueTableType.QueueTableType_Build] = QueueTab

    --barrack
	QueueTab = {}
    local ub = -1
    local barrack_count = 0
    for i = 1,4,1 do
        local barrack =maincity.GetBuildingByID(20+i)
        if barrack ~= nil then
            barrack_count = barrack_count +1
            info = {}
            info.queueType = QueueType.ArmyQueue + i
       
            upgrading = Barrack.GetTrainInfo(20+i)
            if upgrading ~= nil then
                if ub < 0 then
                    ub = 0
                end
                info.obj = upgrading
                info.queueState = QueueState.QS_Busy
                info.name = TextMgr:GetText(upgrading.SoldierName)
                info.lv =  upgrading.Grade
                info.endtime = upgrading.TimeSec 
		        local time = math.floor(upgrading.TmpTrainNum*upgrading.TrainTime*upgrading.TeamCount)
		        info.totalTime = upgrading.TotalTime--Barrack.GetTrainTime(time,upgrading.SoldierId)
		        ub = ub + 1
            else
                info.name =  System.String.Format(TextMgr:GetText("queue_ui3"), TextMgr:GetText(barrack.buildingData.name))
                info.queueState = QueueState.QS_Free
				info.go2 = true
				info.freeEff = true
            end
            if ub < 0 then
                ub = 0
            end
            table.insert(QueueInfo,info)
			table.insert(QueueTab , info)
        end
    end
	--战争堡垒
	
	local barrackDef =maincity.GetBuildingByID(27)
	if barrackDef ~= nil then
		barrack_count = barrack_count + 1
		info = {}
		info.queueType = QueueType.ArmyBarrack5Queue
		upgrading = Barrack.GetTrainInfo(27)
		if upgrading ~= nil then
			info.obj = upgrading
			info.queueState = QueueState.QS_Busy
			info.name = TextMgr:GetText(upgrading.SoldierName)
			info.lv =  upgrading.Grade
			info.endtime = upgrading.TimeSec 
			local time = math.floor(upgrading.TmpTrainNum*upgrading.TrainTime*upgrading.TeamCount)
			info.totalTime = upgrading.TotalTime--Barrack.GetTrainTime(time,upgrading.SoldierId)
			ub = ub + 1
		else
			info.name =  System.String.Format(TextMgr:GetText("queue_ui3"), TextMgr:GetText(barrackDef.buildingData.name))
            info.queueState = QueueState.QS_Free
			info.go2 = true
			info.freeEff = true
		end
		table.insert(QueueInfo,info)
		table.insert(QueueTab , info)
	end
	QueueTableInfo[QueueTableType.QueueTableType_Camp] = QueueTab
	
    if ub >= 0 then
        info = {}
        info.queueType = QueueType.ArmyQueue
        if ub == 0 then
            info.queueState = QueueState.QS_Free
			info.freeEff = true
        elseif ub < barrack_count then
            info.queueState = QueueState.QS_Some_Busy
        else
            info.queueState = QueueState.QS_Busy
        end
        
        info.name = ""
        info.lv = barrack_count - ub
        --print(info.queueType,info.lv,info.queueState)
        info.endtime = 0 
        table.insert(QueueInfo,info)
    end
	
	--armyPath
	QueueTab = {}
	local baseLevel = BuildingData.GetCommandCenterData().level
    local coreData = TableMgr:GetBuildCoreDataByLevel(baseLevel)
    AttributeBonus.CollectBonusInfo()
	local Bonus = AttributeBonus.GetBonusInfos()
	local pathCount = coreData.armyNumber + (Bonus[1088] ~= nil and Bonus[1088] or 0)
	pathCount = pathCount + #ActionListData.GetGuildMobaActionData()
	armyPathQueueSubType = pathCount
	
	ActionListData.Sort1()
	local actionListMsg = ActionListData.GetData()
	--print("QueueType.ArmyPathQueue : " , QueueType.ArmyPathQueue)
	for i=1 , pathCount , 1 do
		info = {}
		info.queueType = QueueType.ArmyPathQueue + (i - 1)
		if actionListMsg ~= nil and i <= #(actionListMsg) then
			local statusIcon, statusText, targetName = ActionList.GetActionTargetInfoByMsg(actionListMsg[i])
			info.icon = statusIcon
			info.name = targetName
			info.queueState = QueueState.QS_Free
			info.go2 = true
			info.go2Param = {tarpos = actionListMsg[i].tarpos}
			
			local showTime = false
			local status = actionListMsg[i].status
			
			--路径显示时间
			if status == Common_pb.PathMoveStatus_Back or status == Common_pb.PathMoveStatus_Go then
				showTime = true
				info.queueState = QueueState.QS_Busy
				info.go2 = false
				info.name = targetName
				info.icon = "array_s_plane1"
				local entype = actionListMsg[i].tarentrytype 
				if entype == Common_pb.SceneEntryType_None then
					info.name = string.format("#1 X:%s Y:%s" , actionListMsg[i].tarpos.x , actionListMsg[i].tarpos.y)
				end
			end

			--采集显示时间
			if status == Common_pb.PathEntryStatus_takeres
				--占领显示时间
				or status == Common_pb.PathEntryStatus_Occupy
				---联盟矿建造显示时间
				or status == Common_pb.PathEntryStatus_GuileMineCreate
				--联盟矿采集显示时间
				or status == Common_pb.PathEntryStatus_GuileMineTake
				--联盟训练场显示时间
				or status == Common_pb.PathEntryStatus_Train then
				showTime = true
				
				info.name = targetName
			end
			
			if status == Common_pb.PathEntryStatus_takeres then
				local entype = actionListMsg[i].tarentrytype 
				if entype == Common_pb.SceneEntryType_ResFood then
					info.icon = "array_s_res1"
				elseif entype == Common_pb.SceneEntryType_ResIron then
					info.icon = "array_s_res2"
				elseif entype == Common_pb.SceneEntryType_ResOil then
					info.icon = "array_s_res3"
				elseif entype == Common_pb.SceneEntryType_ResElec then
					info.icon = "array_s_res4"
				end
			end

			if status == Common_pb.PathEntryStatus_GuileMineTake then
				info.icon = "array_s_res5"
			end
			
			if status == Common_pb.PathEntryStatus_GuileMineCreate then
				info.icon = "array_s_unbuild"
			end
			
			if status == Common_pb.PathEntryStatus_camp then--扎营
				info.icon = "array_s_plane4"
				info.name = string.format("#1 X:%s Y:%s" , actionListMsg[i].tarpos.x , actionListMsg[i].tarpos.y)
				showTime = true
			end
			
			if status == Common_pb.PathEntryStatus_Occupy then--占领
				info.icon = "array_s_plane2"
				info.name = string.format("#1 X:%s Y:%s" , actionListMsg[i].tarpos.x , actionListMsg[i].tarpos.y)
				showTime = true
			end
			
			--驻防
			if status == Common_pb.PathEntryStatus_Garrison then
				info.name = targetName
				info.icon = "array_s_plane3"
				info.queueState = QueueState.QS_Busy
			end
			
			if status == Common_pb.PathEntryStatus_GuildMoba then
				info.name = targetName
				info.icon = "array_s_plane1"
				info.queueState = QueueState.QS_Busy
				info.go2 = true
				info.go2Param.isGuildMoba = true
			end
			
			if status == Common_pb.PathEntryStatus_Gather or status == Common_pb.PathMoveStatus_GoWait then
				showTime = false
				info.queueState = QueueState.QS_Busy
				local state,startTime,endTime = MassTroops.UpdateTimeMsg(nil, actionListMsg[i].gather)
				startTime = math.max(startTime, 0)
				endTime = math.max(endTime, 0)
				
				info.name = targetName
				info.icon = "array_s_plane5"
				info.endtime = endTime
				info.totalTime = endTime - startTime
				--info.go2Param = {}
				info.go2Param.queueSub = i
			end
			
			if showTime then
				info.queueState = QueueState.QS_Busy
				info.endtime = actionListMsg[i].starttime + actionListMsg[i].time
				info.totalTime = actionListMsg[i].time
				--info.go2Param = {}
				info.go2Param.queueSub = i
			end
		else--空闲中
			info.name = TextMgr:GetText("UnionDomain_ui7")--"空闲中"
			info.queueState = QueueState.QS_Free
			info.freeEff = true
			info.icon = "array_s_free"
			info.go2 = true
			info.go2Param = {tarpos = MapInfoData.GetData().mypos}
		end
		table.insert(QueueTab,info)
	end

	QueueTableInfo[QueueTableType.QueueTableType_Plane] = QueueTab
	--hospital
	QueueTab = {}
	info = {}
	QueueType.HospitalQueue = QueueType.ArmyPathQueue + #(QueueTableInfo[QueueTableType.QueueTableType_Plane])
	--print("QueueType.HospitalQueue : " , QueueType.HospitalQueue)
	info.queueType = QueueType.HospitalQueue
	info.icon = "array_s_hos"
	local hosBuilding =maincity.GetBuildingByID(3)
	if hosBuilding ~= nil and ArmyListData.GetTreatmentData() ~= nil then
		--print(TextMgr:GetText(hosBuilding.buildingData.name).." LV."..(hosBuilding.data.level + 1))
		info.obj = hosBuilding
		info.name = TextMgr:GetText(hosBuilding.buildingData.name).." LV."..(hosBuilding.data.level + 1)
		info.lv = hosBuilding.data.level
		
		local cureEndTime = ArmyListData.GetTreatmentData().endtime
		if cureEndTime > GameTime.GetSecTime() then
			info.queueState = QueueState.QS_Busy
			info.endtime = ArmyListData.GetTreatmentData().endtime
			info.totalTime = ArmyListData.GetTreatmentData().originaltime
			info.name = TextMgr:GetText("hospital_ui7")--"医疗中"
			info.go2 = false
			
		elseif ArmyListData.GetInjuredNum() > 0 then
			info.queueState = QueueState.QS_Free
			info.name = TextMgr:GetText("queue_ui7")--"可医疗"
			info.icon = "array_s_leb"
			info.go2 = true
			info.freeEff = true
		else
			info.queueState = QueueState.QS_Free
			info.name = TextMgr:GetText("hospital_ui5")--"无伤兵"
			info.icon = "array_s_free"
			info.go2 = false
		end
	else
		info.queueState = QueueState.QS_Free
		info.name = TextMgr:GetText("queue_ui6")--"医疗所为建造"
		info.go2 = true
	end
	table.insert(QueueTab , info)
	QueueTableInfo[QueueTableType.QueueTableType_Hospital] = QueueTab
	--equip
	QueueTab = {}
	info = {}
	QueueType.EquipQueue = QueueType.HospitalQueue + #(QueueTableInfo[QueueTableType.QueueTableType_Hospital])
	--print("QueueType.EquipQueue : " , QueueType.EquipQueue)
	info.queueType = QueueType.EquipQueue
	info.icon = "array_s_equip"
	local equip = EquipData.GetUpgradingEquip()
	local equipBuil = maincity.GetBuildingByID(44)
	if equipBuil ~= nil then
		if equip ~= nil then
			local upgradingEquipData = EquipData.GetEquipDataByID(equip.BaseData.id)
			info.queueState = QueueState.QS_Busy
			info.endtime = equip.data.completeTime
			info.totalTime = EquipData.GetUpgradeNeedTime()
			info.name = TextMgr:GetText(upgradingEquipData.BaseData.name)--"锻造中"
			info.go2 = true
		else
			info.queueState = QueueState.QS_Free
			info.freeEff = true
			info.name = TextMgr:GetText("UnionDomain_ui7")--"空闲中"
			info.go2 = true
		end
	else
		info.name = TextMgr:GetText("queue_ui8")--"军备库未建造"
		info.queueState = QueueState.QS_Free
		info.go2 = true
	end
	table.insert(QueueTab , info)
	QueueTableInfo[QueueTableType.QueueTableType_Equip] = QueueTab
	--union
	QueueTab = {}
	info = {}
	QueueType.UnionQueue = QueueType.EquipQueue + #(QueueTableInfo[QueueTableType.QueueTableType_Equip])
	--print("QueueType.UnionQueue : " , QueueType.UnionQueue)
	info.queueType = QueueType.UnionQueue
	info.icon = "array_s_unionleb"
	if UnionInfoData.HasUnion() then
		
		--local unionTecBuilding = UnionBuildingData.HasBuilding(2)
		--if UnionBuildingData.HasBuildingBuilt(2) then
			local techStats = UnionTechData.IsNormalInCD()
			if techStats == 1 then--"冷却中"
				info.name = TextMgr:GetText("queue_ui10")--"冷却中"
				info.queueState = QueueState.QS_Busy
				info.go2 = true
			elseif techStats == 2 then --"可捐献(有倒计时)"
				info.name = TextMgr:GetText("queue_ui11")--"可捐献"
				info.go2 = true
				info.queueState = QueueState.QS_Busy
			elseif techStats == 0 then --"可捐献(无倒计时)"
				info.name = TextMgr:GetText("queue_ui11")--"可捐献"
				info.go2 = true
				info.queueState = QueueState.QS_Free
				info.freeEff = true
			end
			local donData = UnionTechData.GetNormalDonate()
			info.endtime = donData == nil and 0 or donData.cdEndTime
			info.totalTime = donData == nil and 0 or donData.cdLimit
			info.go2Param = {}
			info.go2Param.timeModeDown = true
			
		--else
		--	info.name = TextMgr:GetText("queue_ui9")--"建造联盟科技馆后解锁"
		--	info.queueState = QueueState.QS_Free
		--	info.go2 = false
		--end
	else
		info.name = TextMgr:GetText("rank_ui24")--"您还未加入联盟"
		info.queueState = QueueState.QS_Free
		info.go2 = true
	end
	
	table.insert(QueueTab , info)
	QueueTableInfo[QueueTableType.QueueTableType_Union] = QueueTab

	--hero
	QueueTab = {}
	local building = maincity.GetBuildingByID(7)
	QueueType.MilitaryQueue = QueueType.UnionQueue + #(QueueTableInfo[QueueTableType.QueueTableType_Union])
	--print("QueueType.MilitaryQueue : " , QueueType.MilitaryQueue)
    if building ~= nil then
		--普通抽
		info = {}
		info.go2 = true
		info.queueType = QueueType.MilitaryQueue
		info.icon = "array_s_hero2"
		local haveFree , item , normalItemId = MilitarySchool.HaveFreeCount("normal")
		local itemData = TableMgr:GetItemData(normalItemId)
		if haveFree then
			info.queueState = QueueState.QS_Free
			info.freeEff = true
			info.name = TextUtil.GetItemName(itemData)
			info.go2Param = {}
			info.go2Param.timeLabel = TextMgr:GetText("text_free")--"免费"
		else
			info.queueState = QueueState.QS_Free
			info.itemCount = item
			info.name = TextUtil.GetItemName(itemData)
			info.go2Param = {}
			info.go2Param.timeLabel = item
		end
		
		table.insert(QueueTab , info)
		--高级抽
		info = {}
		info.go2 = true
		info.queueType = QueueType.MilitaryQueue + 1
		info.icon = "array_s_hero1"
		haveFree , item , senItemId = MilitarySchool.HaveFreeCount("senior")
		local itemDataSen = TableMgr:GetItemData(senItemId)
		if haveFree then
			info.queueState = QueueState.QS_Free
			info.freeEff = true
			info.name = TextUtil.GetItemName(itemDataSen)
			info.go2Param = {}
			info.go2Param.timeLabel = TextMgr:GetText("text_free")--"免费"
		else
			info.queueState = QueueState.QS_Free
			info.itemCount = item
			info.name = TextUtil.GetItemName(itemDataSen)
			info.go2Param = {}
			info.go2Param.timeLabel = item
		end 
		table.insert(QueueTab , info)
	end
	QueueTableInfo[QueueTableType.QueueTableType_Hero] = QueueTab
	
	--rune
	QueueTab = {}
	QueueType.RuneQueue = QueueType.MilitaryQueue + #(QueueTableInfo[QueueTableType.QueueTableType_Hero])
 
	--普通抽
	info = {}
	info.go2 = true
	info.queueType = QueueType.RuneQueue
	info.icon = "rune_normal"
	local haveFree = RuneData.IsFreeDraw()
	local itemData = TableMgr:GetItemData(310001)
	print(haveFree)
	if haveFree == 1 or haveFree == 3 then
		info.queueState = QueueState.QS_Free
		info.freeEff = true
		info.name = TextUtil.GetItemName(itemData)
		info.go2Param = {}
		info.go2Param.timeLabel = TextMgr:GetText("text_free")--"免费"
	else
		info.queueState = QueueState.QS_Free
		print(ItemListData.GetItemCountByBaseId(310001))
		info.itemCount = ItemListData.GetItemCountByBaseId(310001)
		info.name = TextUtil.GetItemName(itemData)
		info.go2Param = {}
		info.go2Param.timeLabel = ItemListData.GetItemCountByBaseId(310001)
	end
	
	table.insert(QueueTab , info)
	--高级抽
	info = {}
	info.go2 = true
	info.queueType = QueueType.RuneQueue + 1
	info.icon = "rune_advance"
	local itemDataSen = TableMgr:GetItemData(310002)
	if haveFree == 2 or haveFree == 3 then
		info.queueState = QueueState.QS_Free
		info.freeEff = true
		info.name = TextUtil.GetItemName(itemDataSen)
		info.go2Param = {}
		info.go2Param.timeLabel = TextMgr:GetText("text_free")--"免费"
	else
		info.queueState = QueueState.QS_Free
		info.itemCount = ItemListData.GetItemCountByBaseId(310002)
		info.name = TextUtil.GetItemName(itemDataSen)
		info.go2Param = {}
		info.go2Param.timeLabel = ItemListData.GetItemCountByBaseId(310002)
	end 
	table.insert(QueueTab , info)
		
	QueueTableInfo[QueueTableType.QueueTableType_Rune] = QueueTab
end

local function DisplayQueue(tween)
    MainCityQueueUI.QueueGrid.gameObject:SetActive(true)
    if tween then
        MainCityQueueUI.QueueTweenPos:Play(true,true)
        MainCityQueueUI.QueueTweenAlpha:Play(true,true)
    end
    --MainCityQueueUI.IconGrid.gameObject:SetActive(false)
	MainCityQueueUI.bgQueue.gameObject:SetActive(false)
    MainCityQueueUI.QueueBtn.gameObject:SetActive(true)
    MainCityQueueUI.IconBtn.gameObject:SetActive(false)
    for i = 1,#(QueueInfo) do
        --print(QueueInfo[i].queueType,QueueInfo[i].queueState,QueueInfo[i].name ,QueueInfo[i].endtime)
        if QueueInfo[i].queueType ~= 3 then
            AddQueue(QueueInfo[i].queueType,QueueInfo[i].queueState, QueueInfo[i].name ,QueueInfo[i].endtime,QueueInfo[i].totalTime,QueueInfo[i].obj , nil)
        end
    end
    MainCityQueueUI.QueueGrid.hideInactive = false;
    MainCityQueueUI.QueueGrid:Reposition()
    SetClickCallback(MainCityQueueUI.QueueBtn.gameObject, function(obj)
        ShowQueue(true,true)
    end)      
end

local function DisplayQueueNew(tween)
	MainCityQueueUI.bgArray.Root.gameObject:SetActive(true)
	MainCityQueueUI.bgQueue.gameObject:SetActive(false)
	if tween then
        MainCityQueueUI.QueueTweenPos:Play(true,true)
        MainCityQueueUI.QueueTweenAlpha:Play(true,true)
    end
	for i ,v in pairs(QueueTableInfo) do
		
		if v ~= nil then
			local tab = MainCityQueueUI.bgArray.TableContent[i]
			local tabGrid = tab:Find("Grid"):GetComponent("UIGrid")
			
			local count =0;
			for k=1 , #(v) do
				count= count +1
			end
			
			
			for k=1 , #(v) do
				local showLine = true;
				if k == count then 
					showLine = false
				end
				AddQueueNew(v[k].queueType,v[k].queueState, v[k].name ,v[k].endtime,v[k].totalTime,v[k].obj ,
				 v[k].go2 , v[k].go2Param , v[k].icon ,tabGrid , v[k].freeEff,showLine,v[k].rent_time)
			end
			tabGrid.repositionNow = true
			
			if i == 1 or i == 2 or i == 3 then
				local bg = tab:Find("bg"):GetComponent("UISprite")
				local bgH = 95--bg.height
				bg.height = bgH + (#(v)-1)*45
			end
		end
	end
	coroutine.start(function()
		coroutine.step()
		MainCityQueueUI.bgArray.Table.repositionNow = true
	end)
	
	SetClickCallback(MainCityQueueUI.bgArray.Bg.gameObject, function(obj)
        ShowQueue(true,true)
    end) 
	
end

local function DisplaySimpleQueue(tween)
    MainCityQueueUI.QueueGrid.gameObject:SetActive(false)
	MainCityQueueUI.bgArray.Root.gameObject:SetActive(false)
    --MainCityQueueUI.IconGrid.gameObject:SetActive(true)
	MainCityQueueUI.bgQueue.gameObject:SetActive(true)
    if tween then
        MainCityQueueUI.IconTweenPos:Play(true,true)
        MainCityQueueUI.IconTweenAlpha:Play(true,true)
    end
    MainCityQueueUI.QueueBtn.gameObject:SetActive(false)
    MainCityQueueUI.IconBtn.gameObject:SetActive(false)
	local count = 0;
    for i = 1,#(QueueInfo) do
        --print(QueueInfo[i].queueType,QueueInfo[i].queueState,QueueInfo[i].lv)
		if QueueInfo[i].queueType == QueueType.BuildQueue then
			AddSimpleQueue(QueueInfo[i].queueType,QueueInfo[i].queueState,QueueInfo[i].lv)
			count = count +1;
		end
		if QueueInfo[i].queueType == QueueType.TechQueue then
			AddSimpleQueue(QueueInfo[i].queueType,QueueInfo[i].queueState,0)
			count = count +1;
		end
		if QueueInfo[i].queueType == QueueType.ArmyQueue then
			AddSimpleQueue(QueueInfo[i].queueType,QueueInfo[i].queueState,QueueInfo[i].lv)
			count = count +1;
		end
     end
	if count ==1 then 
		MainCityQueueUI.bgQueue:GetComponent("UISprite").height = 60
	elseif count ==2 then 
		MainCityQueueUI.bgQueue:GetComponent("UISprite").height = 104
	elseif count ==3 then
	    MainCityQueueUI.bgQueue:GetComponent("UISprite").height = 148
	else  
		MainCityQueueUI.bgQueue:GetComponent("UISprite").height = count * 50+4;
	end 
	
    MainCityQueueUI.IconGrid.hideInactive = false;
    MainCityQueueUI.IconGrid:Reposition()
    SetClickCallback(MainCityQueueUI.IconBtn.gameObject, function(obj)
        ShowQueue(false,true)
    end)       
end

function ShowQueue(is_simple,tween)
    if MainCityQueueUI == nil then
        return
    end
	
    isSimple = is_simple
    ClearQueue(tween)
    UpdateQueueInfo()
    Queue= {}
    if isSimple then
    	MainCityUI.QueueOpened(false)
        RemoveDelegate(GUIMgr,"onMenuOpen",RegisterShowQueue)		
        DisplaySimpleQueue(tween)
	else
		if Event.HasEvent(33) then
			Event.Check(33)--触发引导
		else
			Event.Check(108)
		end
    	MainCityUI.QueueOpened(true)
        AddDelegate(GUIMgr,"onMenuOpen",RegisterShowQueue)
		DisplayQueueNew(tween)
		
		NGUITools.BringForward(MainCityQueueUI.bgArray.ScrollView.gameObject)
    end
	MainCityUI.OnMainCityQueueSimple(is_simple)
    MainCityUI.UpdateQueueTips()
end

function UpdateQueue()
    if  not inited then
        return
    end
	
	if not isSimple then
		UpdateQueueDetail(false)
	else
		ShowQueue(isSimple,false)
	end
end

function UpdateQueueDetail(tween)
	if MainCityQueueUI == nil then
        return
    end
	
	QueueTableInfo = nil
    QueueInfo = nil
	QueueTab = nil
	UpdateQueueInfo()
	
	MainCityUI.QueueOpened(true)
    AddDelegate(GUIMgr,"onMenuOpen",RegisterShowQueue)
	DisplayQueueNew(tween)
	
	MainCityUI.OnMainCityQueueSimple(is_simple)
    MainCityUI.UpdateQueueTips()
end

function UpdateSimpleQueue()
	if  not inited then
        return
    end
	
	if isSimple then
		ShowQueue(isSimple,false)
	end
end



function Show()
    heroUid = uid
    Global.OpenUI(_M)
    LoadUI()
end

function Destroy()
	
    RemoveDelegate(GUIMgr,"onMenuOpen",RegisterShowQueue)
	RemoveDelegate(GUIMgr, "onMenuClose", OnMenuClose)
    ClearQueue(true)
    inited = false
	goMenu = nil
	ActionListData.RemoveListener(UpdateQueue)
end


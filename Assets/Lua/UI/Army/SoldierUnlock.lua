module("SoldierUnlock", package.seeall)
local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local SetClickCallback = UIUtil.SetClickCallback
local UIAnimMgr = Global.GUIAnimMgr

local ui
local unlockedList = {}
local soldierData
local unlockUnitType
local unlockedUnitId
local unlockUnitScale
local attrSliderCoroutine = {}


local function DestroyAreaView()
    if ui.areaView.transform ~= nil then
        GameObject.Destroy(ui.areaView.transform.gameObject)
    end
end

local function PlayShow()
    local anim = ui.areaView.anim
    if anim:get_Item("show") ~= nil then
        if not anim:IsPlaying("show") then
            anim:PlayQueued("show", UnityEngine.QueueMode.PlayNow)
            anim:PlayQueued("idle", UnityEngine.QueueMode.CompleteOthers)
        end
    else
        if not anim:IsPlaying("idle") then
            anim:Play("idle")
        end
    end
end


local function LoadUnitData()
	local unitData = {}
	if unlockUnitType == "unitDefense" then
		unitData.data = TableMgr:GetUnitDefenseData(unlockedUnitId)
		unitData.barrackData = TableMgr:GetBarrackDataByUnitId(unitData.data.id)

		unitData.parent = unitData.data.id
		unitData.nameLabel = TextMgr:GetText(unitData.barrackData.SoldierName)
		unitData.desLabel = TextMgr:GetText(unitData.barrackData.SoldierDes)
		unitData.unitTransform = ResourceLibrary:GetDefenceInstance4UI(unitData.data._unitDefensePrefab).transform
	elseif unlockUnitType == "unitSoldier" then
		unitData.data = TableMgr:GetUnitData(unlockedUnitId)
		unitData.barrackData = TableMgr:GetBarrackDataByUnitId(unitData.data.id)
		unitData.parent = unitData.data._unitArmyType
		unitData.nameLabel = TextUtil.GetUnitName(unitData.data)
		unitData.desLabel = TextUtil.GetUnitDescription(unitData.data)
		unitData.unitTransform = ResourceLibrary:GetUnitInstance4UI(unitData.data._unitPrefab).transform
	end
	return unitData
end

local function LoadUI()
	local unitData = LoadUnitData()
	--print(unitData.unitPrefab)
    local areaView = ui.areaView
    local viewTransform = areaView.transform
	local unitTransform = unitData.unitTransform
	unitTransform:SetParent(viewTransform:Find(unitData.parent), false)
	unitTransform.localScale = unitTransform.localScale * unlockUnitScale
	NGUITools.SetChildLayer(unitTransform.transform, viewTransform.gameObject.layer)
	areaView.anim = unitTransform:GetComponent("Animation")
	PlayShow()
    ui.nameLabel.text = unitData.nameLabel
    ui.descriptionLabel.text = unitData.desLabel
	ui.title.text = TextMgr:GetText("Military_congratulations")
	
	soldierData = unitData.barrackData
end

function Show(unitId)
	soldierData = nil
    unlockedUnitId = unitId
	unlockUnitType = "unitSoldier"
	unlockUnitScale = 1
	attrSliderCoroutine = {}
    Global.OpenUI(_M)
	if GUIMgr:IsMenuOpen("FirstChangeName") then
		FirstChangeName.gameObject:SetActive(false)
	end
	LoadUI()
end

--有坑，不要用！！！
function SetUnlockId(paramStr)
	local params = paramStr:split(",")

	unlockedUnitId = params[2]
	unlockUnitType = params[3]
	unlockUnitScale = 1
	if #params >= 4 then
		unlockUnitScale = tonumber(params[4])
	end
	print(unlockedUnitId , unlockUnitType , unlockUnitScale)
	
	soldierData = nil
	
	LoadUI()
	ui.title.text = TextMgr:GetText("guild_newsoldier")
end

function UnlockArmy(list)
    for _, v in ipairs(list) do
        table.insert(unlockedList, v)
    end
end

function CheckShow()
    while #unlockedList > 0 do
        local unitId = table.remove(unlockedList, 1)
		local barrackData = TableMgr:GetBarrackDataByUnitId(unitId)
        if barrackData.Popup then
            Show(unitId)
            break
        end
    end
end
function Hide()
    Global.CloseUI(_M)
    CheckShow()
end

local function ShowContent(AttrTransform)
	if AttrTransform == nil then
		return
	end
	
	local sliderto = 0
	local addTotal = 0
	
	if AttrTransform.name == "bg_attribute01" then
		sliderto = soldierData.Attack
		addTotal = 300
	elseif AttrTransform.name == "bg_attribute02" then
		sliderto = soldierData.fakeArmo
		addTotal = 120 + 1
	elseif AttrTransform.name == "bg_attribute03" then
		sliderto = soldierData.Hp
		addTotal = 2500 + 1
	end
	
	AttrTransform:Find("text").gameObject:SetActive(true)
	--slider anim
	local slider = AttrTransform:Find("bg_exp/exp"):GetComponent("UISlider")
	local cor = UIUtil.UIAnimSlider(0 , sliderto/addTotal, 10 , slider , nil)
	if attrSliderCoroutine == nil then
		attrSliderCoroutine = {}
	end
	table.insert(attrSliderCoroutine , cor)
	--text anim
	local floatTextLabel = AttrTransform:Find("text"):GetComponent("UILabel")
	local labelAnim = AttrTransform:Find("text"):GetComponent("UILabelAnimController")
	floatTextLabel.text = 0
    --floatTextLabel.color = color or Color.red
	UIAnimMgr:IncreaseUILabelTextAnim(floatTextLabel , 0 , sliderto)

	if ui ~= nil then
		SetClickCallback(ui.btnClose.gameObject, Hide)
	end
end
function Awake()
    ui = {}
    ui.area3D = transform:Find("bg_soldier/bg/bg_mid/3Darea")
    ui.topLeft = transform:Find("bg_soldier/bg/bg_mid/3Darea/topleft")
    ui.bottomRight = transform:Find("bg_soldier/bg/bg_mid/3Darea/bottomright")
    ui.nameLabel = transform:Find("bg_soldier/bg/bg_mid/txt_name"):GetComponent("UILabel")
    ui.descriptionLabel = transform:Find("bg_soldier/bg/txt_des"):GetComponent("UILabel")
	ui.title = transform:Find("bg_soldier/bg/Title"):GetComponent("UILabel")
	ui.btnClose = transform:Find("bg_soldier/bg/text_sure")
	
	ui.attrAnim = {}
	ui.attrAnim[1] = transform:Find("bg_soldier/bg/bg/bg_attribute01"):GetComponent("AnimColltroller")
	ui.attrAnim[1].finishCallback = ShowContent
	ui.attrAnim[2] = transform:Find("bg_soldier/bg/bg/bg_attribute02"):GetComponent("AnimColltroller")
	ui.attrAnim[2].finishCallback = ShowContent
	ui.attrAnim[3] = transform:Find("bg_soldier/bg/bg/bg_attribute03"):GetComponent("AnimColltroller")
	ui.attrAnim[3].finishCallback = ShowContent
	attrSliderCoroutine = {}
	
    SetClickCallback(ui.area3D.gameObject, PlayShow)
    local areaView = {}
    local viewTransform = ResourceLibrary.GetUIInstance("Barrack/Barrack3DAreaCam").transform
    areaView.transform = viewTransform
    local viewPort = viewTransform:GetComponent("UIViewport")
    viewPort.topLeft =  ui.topLeft
    viewPort.bottomRight = ui.bottomRight
    viewPort.sourceCamera = GUIMgr.UIRoot:Find("Camera"):GetComponent("Camera")
    ui.areaView = areaView
    --LoadUI()
end

function Start()
    GUIMgr:BringForward(gameObject)
end

function Close()
	if attrSliderCoroutine ~= nil then
		for i=1 , #attrSliderCoroutine , 1 do
			if attrSliderCoroutine[i] ~= nil then
				coroutine.stop(attrSliderCoroutine[i])
			end
		end
		attrSliderCoroutine = nil
	end
	
	--UIUtil.UIAnimSliderStop()
    DestroyAreaView()
    if GUIMgr.Instance:IsMenuOpen("FirstChangeName") then
    	transform.parent:Find("FirstChangeName").gameObject:SetActive(true)
    end
	
	
	ui = nil
end

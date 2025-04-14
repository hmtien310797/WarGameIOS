module("MobaArmyListData", package.seeall)
local armyListData ={}
local armyInjuredData
local armyTreatmentData
local eventListener = EventListener()
local GameTime = Serclimax.GameTime

local TableMgr = Global.GTableMgr

function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function GetData()
    return armyListData
end

function SetData(data)
    armyListData = data
end

function UpdateData(data)
    
	for _, v in ipairs(data.data) do
        if v.optype == Common_pb.FreshDataType_Add then

           armyListData:add()
           armyListData[#armyListData] = v.data
		   print("ArmyItem add ",v.data.baseid,v.data.num)
            for ii, vv in ipairs(armyListData) do
                if vv.baseid == v.data.baseid then
                    armyListData[ii].num = v.data.num
					armyListData[ii].level = v.data.level
                end
            end

            --BroadcastEventOnDataChange(v.data, 1)
        elseif v.optype == Common_pb.FreshDataType_Fresh then
            local is_new = false
			-- print("MobaItem fresh ",v.data.baseid,v.data.number)
            for ii, vv in ipairs(armyListData) do
                if vv.baseid == v.data.baseid then
                    armyListData[ii].num = v.data.num
					armyListData[ii].level = v.data.level
                end
            end

           -- BroadcastEventOnDataChange(v.data, 0)
        elseif v.optype == Common_pb.FreshDataType_Delete then
             RemoveArmyByBaseId(v.data.baseid)
           -- BroadcastEventOnDataChange(v.data, -1)
        elseif v.optype == Common_pb.FreshDataType_FlagAdd then
        end
    end
	
	if #data.data > 0 then
	--	RuneData.RefreshList()
        NotifyListener()
    end
	
end

function RemoveArmyByBaseId(uid)
    for i, v in ipairs(itemListData) do
        if v.baseid == uid then
            armyListData:remove(i)
            return
        end
    end
end

function GetInjuredData()
	return armyInjuredData
end

function GetTreatmentData()
	return armyTreatmentData
end

function SetInjuredData(injuredata)
	armyInjuredData = injuredata
	
end

function GetInjuredNum()
	local num = 0
	if armyInjuredData ~= nil then
		for _ , v in ipairs(armyInjuredData) do
			if v.count > 0 then
				num = num + v.count
			end
		end
	end
	return num
end

function SetTreatmentData(treatmentdata)
	armyTreatmentData = treatmentdata
	if armyTreatmentData ~= nil then
		--for _, v in ipairs(armyTreatmentData.armys) do
			
		--	print(v.baseid .. " " .. v.level .. " " .. v.count)
		--end
	end	
end

function SetInjuredArmyData(msg)
	SetInjuredData(msg.injuredarmys)
	SetTreatmentData(msg.treatarmy)
	
	NotifyListener()
end

function UpdateInjuredArmyData(msg)
	SetInjuredData(msg.fresharmy)
	SetTreatmentData(msg.treatarmy)
	NotifyListener()
end

function UpdateInjuredData(msg)
	SetInjuredData(msg.fresharmy)
	NotifyListener()
end

function CanCureArmy()
	--是否有伤兵
	local cancure = 0
	
	--是否有伤兵
	if armyInjuredData ~= nil then
		for _, v in ipairs(armyInjuredData) do
			if v.count > 0 then
				cancure = 1
			end
		end
	end
	
	--是否有正在治疗的队列
	if armyTreatmentData ~= nil and armyTreatmentData.endtime + 5 >  GameTime.GetSecTime() then
		
		cancure = 2
	end
	
	return cancure
end

function IsCuring()
	local isCuring = false
	if armyTreatmentData ~= nil and armyTreatmentData.endtime >  GameTime.GetSecTime() then
		isCuring = true
	end
	
	return isCuring
end


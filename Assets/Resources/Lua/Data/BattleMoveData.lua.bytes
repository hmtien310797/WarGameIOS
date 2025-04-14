module("BattleMoveData", package.seeall)
local TableMgr = Global.GTableMgr

local ArchiveData

local UserAttackFormation

local UserSeverAFormation

local UserSeverDFormation

local UserDefendFormation

local SoliderVaildNums

local SaveArchiveData 

local IgnoreHeros

local DefaultFormation = {21,22,0,23,24,0}

function GetData()
    return ArchiveData
end

local function UpdateSoliderVaildNum(army)
    for i = 1,#(army),1 do 
        local info = army[i]
        local data = Barrack.GetAramInfo(info.baseid,info.level)
        SoliderVaildNums[data.UnitID] = info.num
    end
end

function SetData(data)
    ArchiveData = data
    SoliderVaildNums = {}
    if ArchiveData.freshArmyNum ~= nil then
        --[[local s = "sss "
        for i = 1,#(ArchiveData.freshArmyNum.hero),1 do
            s = s..ArchiveData.freshArmyNum.hero[i].."  "
        end
        print(s)
        --]]
        IgnoreHeros = ArchiveData.freshArmyNum.hero
        UpdateSoliderVaildNum(ArchiveData.freshArmyNum.army)
    end
end

function IsHeroSetout(heroUid)
    if IgnoreHeros == nil then
        return false
    end

    for _, v in ipairs(IgnoreHeros) do
        if v.uid == heroUid then
            return true
        end
    end

    return false
end

function DataToArchive()
    local archive = nil 
    if ArchiveData == nil then
        return nil
    end
    archive = BMLayoutArchive(0)
    for i = 1,#(ArchiveData.armyScheme.army),1 do 
        local info = ArchiveData.armyScheme.army[i]
        local data = Barrack.GetAramInfo(info.armyId,info.armyLevel)
        archive:AddArmyRecord(data.UnitID,info.num)
    end
    table.foreach(ArchiveData.heroScheme.hero,function(i,v)
        --print(v)
        if type(v) == "number" then
            archive:AddHeroRecord(v)
        end
    end)
    return archive
end

function GetIgnoreHeros()
    return IgnoreHeros
end

function GetPreHeroList()
    if ArchiveData == nil or ArchiveData.heroScheme == nil then
        return nil
    end
    return ArchiveData.heroScheme.hero
end

function GetSoliderVaildNum(unit_id)
    return SoliderVaildNums[unit_id]
end

function RequestSaveArchiveDataFirst()
    if SaveArchiveData == nil then
        RequestSaveArchiveData()
    end      
end

function RequestSaveArchiveData(callback)
	local req = HeroMsg_pb.MsgGetArmySetoutNumRequest()
	req.index = 1
	--LuaNetwork.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgGetArmySetoutNumRequest, req:SerializeToString(), function(typeId, data)
	--	local msg = HeroMsg_pb.MsgGetArmySetoutNumResponse()
	--	msg:ParseFromString(data)
    Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgGetArmySetoutNumRequest, req,HeroMsg_pb.MsgGetArmySetoutNumResponse,function(msg)		
		BattleMove.RecordTime("RequestSaveArchiveData SetData Req Start =================================")
		
        SaveArchiveData = nil
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)          
        else
            SaveArchiveData = {}
            for i = 1, #(msg.scheme), 1 do
                if msg.scheme[i].army ~= nil and #(msg.scheme[i].army)~=0 then
                    SaveArchiveData[i] = BMLayoutArchive(i)
                    SaveArchiveData[i]:AddGenerals(msg.scheme[i].hero)
                    for j = 1,#(msg.scheme[i].army),1 do 
                        local info = msg.scheme[i].army[j]
                        local data = Barrack.GetAramInfo(info.armyId,info.armyLevel)
                        SaveArchiveData[i]:AddArmyRecord(data.UnitID,info.num)
                        --print(i,data,UnitID,info.num)
                    end
                end
            end
        end
        if callback ~= nil then
            callback()
        end
	end, true)
end

function RequestSetArchiveData(index, infos, generals, callback)
	local req = HeroMsg_pb.MsgSetArmySetoutNumRequest()
	req.index = index
	
    table.foreach(infos,function(i,v)
        if v.num > 0 then
           local army = req.armyScheme.army:add()
           army.armyId = v.type_id
           army.armyLevel = v.level
           army.num = v.num
       end
	end)

    table.foreach(generals, function(i, uid)
       req.armyScheme.hero:append(uid)
    end)
	
    --LuaNetwork.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgSetArmySetoutNumRequest, req:SerializeToString(), function(typeId, data)
	--	local msg = HeroMsg_pb.MsgSetArmySetoutNumResponse()
	--	msg:ParseFromString(data)
    Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgSetArmySetoutNumRequest, req,HeroMsg_pb.MsgSetArmySetoutNumResponse,function(msg)	
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)          
        else
            if SaveArchiveData == nil then
                SaveArchiveData = {}
            end

            SaveArchiveData[index] = BMLayoutArchive(index)
            SaveArchiveData[index]:AddGenerals(generals)
            
            table.foreach(infos, function(_, v)
                if v.num > 0 then
                    SaveArchiveData[index]:AddArmyRecord(v.unitId, v.num)
                end                
            end)

            if callback ~= nil then
                callback()
            end
        end
	end, true)
end

function SetArchiveData(msg, callback)
    SetData(msg)
    --print("SetArchiveData",SaveArchiveData)
    BattleMove.RecordTime("SetArchiveData SetData =================================")        
    if SaveArchiveData == nil then
        RequestSaveArchiveData(function() 
            BattleMove.RecordTime("RequestSaveArchiveData SetData End=================================")
		    if callback ~= nil then
                callback(true)
            end               
        end)
    else
		if callback ~= nil then
            callback(true)
        end
    end    
end

function RequestArchiveData4PVE(callback)
	local req = HeroMsg_pb.MsgGetArmySetoutUIRequest()
    req.pathType = Common_pb.TeamMoveType_ChapterPvP
	--LuaNetwork.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgGetArmySetoutUIRequest, req:SerializeToString(), function(typeId, data)
	--	local msg = HeroMsg_pb.MsgGetArmySetoutUIResponse()
	--	msg:ParseFromString(data)
    Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgGetArmySetoutUIRequest, req,HeroMsg_pb.MsgGetArmySetoutUIResponse,function(msg)			
        Global.DumpMessage(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
		    if callback ~= nil then
                callback(false)
		    end              
        else
            SetData(msg)

		    if callback ~= nil then
                callback(true)
            end
        end
	end, true)
end


function RequestArchiveData(uid, px, py, callback)
	local req = HeroMsg_pb.MsgGetArmySetoutUIRequest()
	req.seUid = uid
	req.pos.x = px
	req.pos.y = py
	--LuaNetwork.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgGetArmySetoutUIRequest, req:SerializeToString(), function(typeId, data)
	--	local msg = HeroMsg_pb.MsgGetArmySetoutUIResponse()
	--	msg:ParseFromString(data)
    Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgGetArmySetoutUIRequest, req,HeroMsg_pb.MsgGetArmySetoutUIResponse,function(msg)			
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
		    if callback ~= nil then
                callback(false)
		    end              
        else
            SetData(msg)
            if SaveArchiveData == nil then
                RequestSaveArchiveData(function() 
		            if callback ~= nil then
                        callback(true)
                    end               
                end)
            else
		        if callback ~= nil then
                    callback(true)
                end
            end
        end
	end, true)
end

function RequestUserFormation(ftype,callback)
	local req = HeroMsg_pb.MsgGetArmyFormationRequest()
	req.formType = ftype
	--LuaNetwork.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgGetArmyFormationRequest, req:SerializeToString(), function(typeId, data)
	--	local msg = HeroMsg_pb.MsgGetArmyFormationResponse()
	--	msg:ParseFromString(data)
	Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgGetArmyFormationRequest, req,HeroMsg_pb.MsgGetArmyFormationResponse,function(msg)	
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
		    if callback ~= nil then
                callback(false)
		    end              
        else
		    if callback ~= nil then
                callback(true,msg)
		    end            
        end
	end, false)
end


function isVaildFormation(form)
    if form == nil then 
        return false
    end
    local v = {}
    v[21] =1
    v[22] =1
    v[23] =1
    v[24] =1
    for i =1,8,1 do
        if v[form[i]] ~= nil then
            v[form[i]] = 0
        end
    end
    return (v[21]+v[22]+v[23]+v[24]) == 0
end

function CloneFormation(s,t)
    if s == nil or t == nil then
        return
    end
    for i =1,8,1 do
        s[i] = t[i]
    end
end

function isFormationSame(s,t)
    if s == nil or t == nil then
        return false
    end
    for i =1,8,1 do
        if s[i] ~= t[i] then
            return false
        end
    end
    return true
end 

function Update2DefaultFormation(formation)
    CloneFormation(formation,DefaultFormation)
end

function SetUserAttackFormaion(atkArmyForm)
    UserSeverAFormation = atkArmyForm.form
    UserAttackFormation = UserSeverAFormation;	
    if not isVaildFormation(UserAttackFormation) then
        UserAttackFormation = {}
        CloneFormation(UserAttackFormation,DefaultFormation)
    end    
    return UserAttackFormation
end

function GetOrReqUserAttackFormaion(result_callback)
    if result_callback == nil then
        return
    end
    if UserAttackFormation ~= nil then
        --result_callback(UserAttackFormation)
        --return 
    end
    RequestUserFormation(1,function(success,data) 
        if success then
            UserSeverAFormation = data.armyForm.form
            UserAttackFormation = UserSeverAFormation;
		    --print( data.armyForm[1], data.armyForm[2], data.armyForm[3], data.armyForm[4], data.armyForm[5], data.armyForm[6])	
            if not isVaildFormation(UserAttackFormation) then
                UserAttackFormation = {}
                CloneFormation(UserAttackFormation,DefaultFormation)
            end
            --print( UserAttackFormation[1], UserAttackFormation[2], UserAttackFormation[3], UserAttackFormation[4], UserAttackFormation[5],UserAttackFormation[6])	
            result_callback(UserAttackFormation)
        else
            result_callback(nil)
        end        
    end)
end

function GetOrReqUserAttackFormaionFirst()
    if UserAttackFormation == nil then
        GetOrReqUserAttackFormaion()
    end      
end


function GetUserAttackFormation()
    return UserAttackFormation
end

function GetServerAttackFormation()
    return UserSeverAFormation
end

function GetOrReqUserDefendFormaion(result_callback)
    if result_callback == nil then
        return
    end
    if UserDefendFormation ~= nil then
		--result_callback(UserDefendFormation)
        --return 
    end
    RequestUserFormation(2,function(success,data) 
        if success then
            UserSeverDFormation = data.armyForm.form
            UserDefendFormation = UserSeverDFormation;
			for _,v in ipairs(data.armyForm) do
				--print(v)
			end
			
            if not isVaildFormation(UserDefendFormation) then
                UserDefendFormation = {}
                CloneFormation(UserDefendFormation,DefaultFormation)
            end            
            result_callback(UserDefendFormation)
        else
            result_callback(nil)
        end        
    end)
end

function GetOrReqUserDefendFormaionFirst()
    if UserDefendFormation == nil then
        GetOrReqUserDefendFormaion()
    end      
end

function GetUserDefendFormaion()
    return UserDefendFormation
end

function GetServerDefendFormation()
    return UserSeverDFormation
end

function GetDefaultFormation()
    return DefaultFormation
end

function SaveFormation(ftype, form, callback)
	local req = HeroMsg_pb.MsgSetArmyFormationRequest()
	req.formType = ftype
	local count = 0
	table.foreach(form , function(_,v)	
		count = count + 1
		if count <=6 then
		    --print(v)
		    req.armyForm.form:append(v)
		end
		
	end)
	--LuaNetwork.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgSetArmyFormationRequest, req:SerializeToString(), function(typeId, data)
	--	local msg = HeroMsg_pb.MsgSetArmyFormationResponse()
	--	msg:ParseFromString(data)
	Global.Request(Category_pb.Hero, HeroMsg_pb.HeroTypeId.MsgSetArmyFormationRequest, req,HeroMsg_pb.MsgSetArmyFormationResponse,function(msg)	
		if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
		    if callback ~= nil then
                callback(false)
		    end              
        else
		    if callback ~= nil then
                callback(true,msg)
		    end            
        end
	end, true)
	
end

function GetSaveArchiveData(index)
    if SaveArchiveData == nil then
        return nil
    end

    return SaveArchiveData[index]
end

function SetSaveArchiveData(index, left_infos, selectHeroData, callback)
    if SaveArchiveData == nil then
        return
    end

    RequestSetArchiveData(index, left_infos, selectHeroData.memHero, callback)
end

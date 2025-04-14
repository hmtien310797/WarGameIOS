class "MassTroopsCondition"
{
}
function MassTroopsCondition:__init__()
    self.target_shield = false 
    self.self_shield = BuffData.HasShield()
    self.self_union = UnionInfoData.HasUnion()
    self.target_enable_mass = true
    self.is_union_mass = false
    self.self_had_mass = ActionListData.IsGatherCalling()
    self.isActMonster = false


    self.msgTextids={
        create_target_shield = "assemble_warning_1",
        create_self_shield = "assemble_warning_2",
        create_not_self_union = "assemble_warning_3",
        create_not_self_build = "assemble_warning_4",
        create_not_target_enable_mass = "assemble_warning_5",
        create_is_union_mass = "assemble_warning_6",
        create_queue_free = "assemble_warning_7",
        create_self_had_mass = "assemble_warning_8",

        join_self_shield = "shield_warning_1",
        join_not_self_build = "assemble_warning_4",
        join_queue_free = "assemble_warning_7",
    }
end

function MassTroopsCondition:__CreateMass4BattleConditionSub(callback)
    --是否自己有联盟 否 
    if not self.self_union then 
        MessageBox.Show(Global.GTextMgr:GetText(self.msgTextids.create_not_self_union),function() 
		    callback(false)
		end)   
        return 
    end
    --是否自己有战争大厅
    local building = maincity.GetBuildingByID(43)  
    if building == nil or building.data == nil then
		MessageBox.Show(Global.GTextMgr:GetText(self.msgTextids.create_not_self_build),function() 
		    callback(false)
		end) 
        return
    end
    --目标是否可以集结
    if not self.target_enable_mass then
		MessageBox.Show(System.String.Format(Global.GTextMgr:GetText(self.msgTextids.create_not_target_enable_mass),
		tonumber(Global.GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.MassMinLevel).value)),function() 
		    callback(false)
		end)        
        return 
    end
    --是否有同盟已经集结
    if self.is_union_mass then
		MessageBox.Show(Global.GTextMgr:GetText(self.msgTextids.create_is_union_mass),function() 
		    callback(false)
		end)        
        return   
    end
    --是否有空队列
    if ActionListData.IsFull() then
        MessageBox.Show(Global.GTextMgr:GetText(self.msgTextids.create_queue_free),function() 
		    callback(false)
		end) 
        return
    end

    --是否自己已经有其他集结
    if self.self_had_mass then
        MessageBox.Show(Global.GTextMgr:GetText(self.msgTextids.create_self_had_mass),function() 
		    callback(false)
		end) 
        return
    end

    callback(true)
end

-- 发起集结判定
function MassTroopsCondition:CreateMass4BattleCondition(callback,igrone_target)

    if callback == nil then
        return
    end

    if not BattleMove.CheckActionList() then
        return
    end


    if TileInfo.GetTileMsg() == nil then
        self.target_shield = false
    else
        self.target_shield = TileInfo.GetTileMsg().home.hasShield
    end
    --目标是否有保护盾 是
    if igrone_target == nil then 
        if self.target_shield then
            MessageBox.Show(Global.GTextMgr:GetText(self.msgTextids.create_target_shield),function() 
		        callback(false)
		    end)
            return
        end
    end
    
    --自己是否有保护盾 是
    --[[
    if self.self_shield and not self.isActMonster then
        MessageBox.Show(Global.GTextMgr:GetText(self.msgTextids.create_self_shield),function() 
		    self:__CreateMass4BattleConditionSub(callback)
        end,function()
            callback(false)
        end)
    else
        self:__CreateMass4BattleConditionSub(callback)
    end
    --]]
    self:__CreateMass4BattleConditionSub(callback)
end

function MassTroopsCondition:__JoinMass4BattleConditionEx(callback)
    --是否自己有战争大厅
    local building = maincity.GetBuildingByID(43)  
    if building == nil or building.data == nil then
		MessageBox.Show(Global.GTextMgr:GetText(self.msgTextids.join_not_self_build),function() 
		    callback(false)
		end) 
        return
    end
    --是否有空队列
    if ActionListData.IsFull() then
        MessageBox.Show(Global.GTextMgr:GetText(self.msgTextids.join_queue_free),function() 
		    callback(false)
		end) 
        return
    end
    callback(true)
end

--参与集结判定
function MassTroopsCondition:JoinMass4BattleCondition(callback)
    if not BattleMove.CheckActionList() then
        return
    end    
    --自己是否有保护盾 是
    --[[
    if self.self_shield then
        MessageBox.Show(Global.GTextMgr:GetText(self.msgTextids.join_self_shield),function() 
		    self:__JoinMass4BattleConditionEx(callback)
        end,function()
            callback(false)
        end)
    else
        self:__JoinMass4BattleConditionEx(callback)
    end
    --]]
    self:__JoinMass4BattleConditionEx(callback)
end

function MassTroopsCondition:ShowCreateMassBattleMove(uid, charname, mapx,mapy,maxnum,time ,enType , sweep)
    BattleMove.SetMassTime(time*60)
    BattleMove.SetFixedMaxSoilder(maxnum)
    BattleMove.Show(Common_pb.TeamMoveType_GatherCall,uid,charname,mapx,mapy,TileInfo.Hide , nil , nil,nil,enType , sweep)
end


function MassTroopsCondition:ShowJionMassBattleMove(uid,mapx,mapy,maxnum,callback, mapx2,mapy2)
    BattleMove.SetFixedMaxSoilder(maxnum)
    BattleMove.Show(Common_pb.TeamMoveType_GatherRespond,uid,"", mapx,mapy,function()
        TileInfo.Hide()
        if callback ~= nil then
            callback()
        end
    end, mapx2,mapy2)
end

----------------------------------Moba----------------------------------------

function MassTroopsCondition:__MobaCreateMass4BattleConditionSub(callback)

    --目标是否可以集结
    if not self.target_enable_mass then
		MessageBox.Show(System.String.Format(Global.GTextMgr:GetText(self.msgTextids.create_not_target_enable_mass),
		tonumber(Global.GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.MassMinLevel).value)),function() 
		    callback(false)
		end)        
        return 
    end
    --是否有空队列
    if MobaActionListData.IsFull() then
        MessageBox.Show(Global.GTextMgr:GetText("ui_moba_152"),function() 
		    callback(false)
		end) 
        return
    end

    --是否自己已经有其他集结
    if self.self_had_mass then
        MessageBox.Show(Global.GTextMgr:GetText(self.msgTextids.create_self_had_mass),function() 
		    callback(false)
		end) 
        return
    end

    callback(true)
end

-- 发起集结判定
function MassTroopsCondition:MobaCreateMass4BattleCondition(build_id,callback,igrone_target)

    if callback == nil then
        return
    end

    if not MobaBattleMove.CheckActionList() then
        return
    end
    local build_msg = nil
    if build_id ~= nil then
        build_msg = MobaZoneBuildingData.GetData(build_id)
    end
    if build_msg == nil then
        self.target_shield = false
    else
        self.target_shield = build_msg.hasShield
    end
    --目标是否有保护盾 是
    if igrone_target == nil then 
        if self.target_shield then
            MessageBox.Show(Global.GTextMgr:GetText(self.msgTextids.create_target_shield),function() 
		        callback(false)
		    end)
            return
        end
    end
    self.self_had_mass = MobaActionListData.IsGatherCalling()
    --自己是否有保护盾 是
    --[[
    if self.self_shield and not self.isActMonster then
        MessageBox.Show(Global.GTextMgr:GetText(self.msgTextids.create_self_shield),function() 
		    self:__CreateMass4BattleConditionSub(callback)
        end,function()
            callback(false)
        end)
    else
        self:__CreateMass4BattleConditionSub(callback)
    end
    --]]
    self:__MobaCreateMass4BattleConditionSub(callback)
end




function MassTroopsCondition:MobaShowCreateMassBattleMove(uid, charname, mapx,mapy,maxnum,time)
	print(uid, charname, mapx,mapy,maxnum,time)
    MobaBattleMove.SetMassTime(time)
    MobaBattleMove.SetFixedMaxSoilder(maxnum)
    MobaBattleMove.Show(Common_pb.TeamMoveType_GatherCall,uid,charname,mapx,mapy,MobaTileInfo.Hide)
end

function MassTroopsCondition:MobaShowJionMassBattleMove(uid,mapx,mapy,maxnum,callback, mapx2,mapy2)
    MobaBattleMove.SetFixedMaxSoilder(maxnum)
    MobaBattleMove.Show(Common_pb.TeamMoveType_GatherRespond,uid,"", mapx,mapy,function()
        TileInfo.Hide()
        if callback ~= nil then
            callback()
        end
    end, mapx2,mapy2)
end


function MassTroopsCondition:__MobaJoinMass4BattleConditionEx(callback)
    --是否自己有战争大厅
   --[[] local building = maincity.GetBuildingByID(43)  
    if building == nil or building.data == nil then
		MessageBox.Show(Global.GTextMgr:GetText(self.msgTextids.join_not_self_build),function() 
		    callback(false)
		end) 
        return
    end]]
    --是否有空队列
    if MobaActionListData.IsFull() then
        MessageBox.Show(Global.GTextMgr:GetText("ui_moba_152"),function() 
		    callback(false)
		end) 
        return
    end
    callback(true)
end

--参与集结判定
function MassTroopsCondition:MobaJoinMass4BattleCondition(callback)
    if not MobaBattleMove.CheckActionList() then
        return
    end    
  
    self:__MobaJoinMass4BattleConditionEx(callback)
end

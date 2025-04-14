class "MobaMassTroops"
{
}

function MobaMassTroops:__init__(RootTrf)

    self.interface={
        ["Category_pb_RequestInfoEx"] = Category_pb.Moba,
        ["GetPathSituationRequest"]=MobaMsg_pb.MsgMobaGetPathSituationRequest,
        ["GetPathSituationRequestTypeID"] = MobaMsg_pb.MobaTypeId.MsgMobaGetPathSituationRequest,
        ["GetPathSituationResponse"] = MobaMsg_pb.MsgMobaGetPathSituationResponse,
    
    
        ["Category_pb_RequestInfoDetail"] = Category_pb.Moba,
        ["GetGatheInfoRequest"]=MobaMsg_pb.MsgMobaGetGatheInfoRequest,
        ["GetGatheInfoRequestTypeID"] = MobaMsg_pb.MobaTypeId.MsgMobaGetGatheInfoRequest,
        ["GetGatheInfoResponse"] = MobaMsg_pb.MsgMobaGetGatheInfoResponse, 

        ["Category_pb_CancelMass"] = Category_pb.Moba,
        ["CancelPathRequest"]=MobaMsg_pb.MsgMobaCancelPathRequest,
        ["CancelPathRequestTypeID"] = MobaMsg_pb.MobaTypeId.MsgMobaCancelPathRequest,
        ["CancelPathResponse"] = MobaMsg_pb.MsgMobaCancelPathResponse, 


        ["Category_pb_RequestBuildInfo"] = Category_pb.Moba,
        ["GetBuildSituationRequest"]=MobaMsg_pb.MsgMobaGetBuildSituationRequest,
        ["GetBuildSituationRequestTypeID"] = MobaMsg_pb.MobaTypeId.MsgMobaGetBuildSituationRequest,
        ["GetBuildSituationResponse"] = MobaMsg_pb.MsgMobaGetBuildSituationResponse,  
		
		["ChatChannel"] = ChatMsg_pb.chanel_MobaTeam,
		["ChatConditionSendType"] = ChatMsg_pb.ChatInfoConditionType_MobaGather,
		["Chat"] = MobaChat,

    }
    
    self.interface_guild={
        ["Category_pb_RequestInfoEx"] = Category_pb.GuildMoba,
        ["GetPathSituationRequest"]=GuildMobaMsg_pb.GuildMobaGetPathSituationRequest,
        ["GetPathSituationRequestTypeID"] = GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaGetPathSituationRequest,
        ["GetPathSituationResponse"] = GuildMobaMsg_pb.GuildMobaGetPathSituationResponse,
    
    
        ["Category_pb_RequestInfoDetail"] = Category_pb.GuildMoba,
        ["GetGatheInfoRequest"]=GuildMobaMsg_pb.GuildMobaGetGatheInfoRequest,
        ["GetGatheInfoRequestTypeID"] = GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaGetGatheInfoRequest,
        ["GetGatheInfoResponse"] = GuildMobaMsg_pb.GuildMobaGetGatheInfoResponse, 

        ["Category_pb_CancelMass"] = Category_pb.GuildMoba,
        ["CancelPathRequest"]=GuildMobaMsg_pb.GuildMobaCancelPathRequest,
        ["CancelPathRequestTypeID"] = GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaCancelPathRequest,
        ["CancelPathResponse"] = GuildMobaMsg_pb.GuildMobaCancelPathResponse, 


        ["Category_pb_RequestBuildInfo"] = Category_pb.GuildMoba,
        ["GetBuildSituationRequest"]=GuildMobaMsg_pb.GuildMobaGetBuildSituationRequest,
        ["GetBuildSituationRequestTypeID"] = GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaGetBuildSituationRequest,
        ["GetBuildSituationResponse"] = GuildMobaMsg_pb.GuildMobaGetBuildSituationResponse,  
		
		["ChatChannel"] = ChatMsg_pb.chanel_GuildMobaTeam,
		["ChatConditionSendType"] = ChatMsg_pb.ChatInfoConditionType_GuildMobaGather,
		["Chat"] = GuildMobaChat,
    }
    
    self.GetInterface=function(interface_name)
        if Global.GetMobaMode() == 1 then
            return self.interface[interface_name]
        else
            return self.interface_guild[interface_name]
        end
    end

    self.moba_center_build_ids={[1] = true,[4] = true}
    self.moba_main_build_ids={[1] = true,[2] = true,[3] = true,[4]= true,[5]=true,[6]=true}
    if RootTrf == nil then
        return
    end
    self.transform = RootTrf
    self.assembled_prefab = RootTrf:Find("assembled").gameObject
    self.build_info_prefab = RootTrf:Find("bg2/build_list").gameObject

    self.list_ui = {}
    self.list_ui.root = RootTrf:Find("bg2").gameObject
    self.list_ui.root:SetActive(false)

    self.build_info_index = 3
    self.moba_ruling_strs =  { "moba_mapzone0", "moba_mapzone1", "moba_mapzone2" };
    self.countDownRemoveIDs = {}
    
    for i = 1,3,1 do
        self.list_ui[i] = {}
        self.list_ui[i].count = 0
        self.list_ui[i].msg = nil
        self.list_ui[i].list = {}
        self.list_ui[i].grid = RootTrf:Find("bg2/content "..i.."/Scroll View/Grid"):GetComponent("UIGrid")
        self.list_ui[i].scroll_view = RootTrf:Find("bg2/content "..i.."/Scroll View"):GetComponent("UIScrollView")
        self.list_ui[i].no_one = RootTrf:Find("bg2/content "..i.."/no one").gameObject
        self.list_ui[i].root = RootTrf:Find("bg2/content "..i).gameObject
        self.list_ui[i].page = RootTrf:Find("bg2/page"..i):GetComponent("UIToggle")
        self.list_ui[i].page:Set(i==1 and true or false)
        self.list_ui[i].notice = RootTrf:Find("bg2/page"..i.."/red")
        self.list_ui[i].notice.gameObject:SetActive(MobaMain.MassTotlaNum[i] ~= MobaMain.GetPreMassTotalNum()[i])
        self.list_ui[i].no_one:SetActive(false)
        UIUtil.SetClickCallback(self.list_ui[i].page.gameObject,function()
            if i == 3 then
                self:OpenBuildList()
                return
            end            
            MobaMain.PreMassTotalNum[1] = MobaMain.MassTotlaNum[1]
            MobaMain.PreMassTotalNum[2] = MobaMain.MassTotlaNum[2]
            self:OpenList(i)
        end)
    end
    self.list_items = {}

    self.cur_select_index = 1
    self.per_select_index =0
    

    self.detail_ui = {}
    self.detail_ui.itemlist = nil
    self.detail_ui.item = nil
    self.detail_ui.item_trf = RootTrf:Find("bg3/assembled")
    self.detail_ui.root = RootTrf:Find("bg3").gameObject
    self.detail_ui.root:SetActive(false)
    self.detail_ui.ScrollView = RootTrf:Find("bg3/base/Scroll View"):GetComponent("UIScrollView")
    self.detail_ui.Table = RootTrf:Find("bg3/base/Scroll View/Table"):GetComponent("UITable")
    self.detail_ui.itemPrefab = RootTrf:Find("bg3/ItemInfo").gameObject
    self.detail_ui.ArmyPrefab = RootTrf:Find("bg3/soilder_list").gameObject
    self.detail_ui.None = RootTrf:Find("bg3/base/none").gameObject
    self.detail_ui.join_sprite = RootTrf:Find("bg3/join"):GetComponent("UIButton")
    self.detail_ui.join_text = RootTrf:Find("bg3/join/Label"):GetComponent("UILabel")
    self.detail_ui.join_collision =self.detail_ui.join_sprite:GetComponent("BoxCollider")
    UIUtil.SetClickCallback(self.detail_ui.join_sprite.gameObject,function()
            self:OnJoinBtn()
    end)
    self.stateTextIds = {
        [1] = "ui_worldmap_74", -- 等待集结时间
        [2] = "ui_worldmap_75", -- 等待玩家到来
        [3] = "ui_worldmap_51", -- 行军中
    }
    self.join_state = {
        cancel = 1, -- 取消
        join = 2, -- 加入
        full = 3,-- 满员
        joined = 4,--已经加入
        close = 5,--关闭
    }
    self.join_state_textid = {
        [1] = "union_assembled_7",
        [2] = "union_assembled_11",
        [3] = "union_assembled_9",
        [4] = "union_assembled_10",
        [5] = "union_assembled_8",
        [21] = "union_assembled_13",
        [22] = "ui_moba_171",
        [31] = "ui_worldmap_38",
    }
    self.inited = false
end

function MobaMassTroops:RequsetMassTotalNum(callback)
    if callback == nil then
        return
    end
    local count1 = 0
    local count2 = 0
    self:RequestInfoEx(0,1,function(msg1)
        if msg1 ~= nil then
            count1 = #msg1.gather 
            self:RequestInfoEx(0,2,function(msg2)
                if msg2 ~= nil then
                    count2 = #msg2.gather 
                    if callback ~= nil then
                        callback(count1,count2)
                    end
                else
                    if callback ~= nil then
                        callback(count1,count2)
                    end
                end
            end)
        else
            if callback ~= nil then
                callback(count1,count2)
            end
        end
    end)
end

function MobaMassTroops:RequestInfoEx(charid,index,callback)
    if callback == nil then
        return
    end
    local req = self.GetInterface("GetPathSituationRequest")()
    req.infoType = index
    req.charid = charid
    Global.Request(self.GetInterface("Category_pb_RequestInfoEx"),self.GetInterface("GetPathSituationRequestTypeID"),req,self.GetInterface("GetPathSituationResponse"),function(msg)
         if msg.code == 0 then
            if callback ~= nil  then -- and self.inited
                callback(msg)
            end
        else
            if callback ~= nil  then -- and self.inited
                callback(nil)
            end
            Global.FloatError(msg.code, Color.white)
        end
    end, true)   
end

function MobaMassTroops:RequestInfo(charid,callback)
    if callback == nil then
        return
    end
    local index = self.cur_select_index
    if index == 10 then
        index = 1
    end
    --local info = debug.getinfo(2,"S")
    --print("RequestInfoRequestInfoRequestInfoRequestInfo",info.source,info.linedefined) 

    self:RequestInfoEx(charid,index,function(msg1)
        if msg1 ~= nil then
            if callback ~= nil and self.inited then
                callback(msg1)
            end
        else
            if callback ~= nil and self.inited then
                callback(nil)
            end
        end
    end)    
end

function MobaMassTroops:RequestInfoDetail(charid,callback)
    if callback == nil then
        return
    end
    local req = self.GetInterface("GetGatheInfoRequest")()
    req.charid = charid
	Global.Request(self.GetInterface("Category_pb_RequestInfoDetail"),self.GetInterface("GetGatheInfoRequestTypeID"),req,self.GetInterface("GetGatheInfoResponse"),function(msg)
        if msg.code == 0 then
            if callback ~= nil and self.inited then
                callback(msg)
            end
        else
            if callback ~= nil and self.inited then
                callback(nil)
            end
            Global.FloatError(msg.code, Color.white)
        end
    end)    
end

function MobaMassTroops:UpdateTimeMsg(msg)
    local state = 0
    local startTime = 0
    local endTime = 0
    
    local mass_wait_time = msg.starttime + msg.waittime
    local path_time = -1
    if msg.pathstarttime ~= 0 then
        path_time = msg.pathstarttime + msg.pathtime
    end

    local cur_time = Serclimax.GameTime.GetSecTime()

    if mass_wait_time > cur_time then
        state = 1
        startTime = msg.starttime
        endTime = mass_wait_time
        return state,startTime,endTime
    end

    if path_time > 0 and path_time > cur_time then
        state = 3
        startTime = msg.pathstarttime
        endTime = path_time
        return state,startTime,endTime  
    end

    local index = -1
    for i =1,#msg.user,1 do
        if index < 0 then
            index = i
        elseif msg.user[index].endtime > cur_time then
            if msg.user[index].endtime > msg.user[i].endtime then
                index = i
            end
        end
    end
    
    if index < 0 then
        state = 4
        startTime = -1
        endTime = -1
        return state,startTime,endTime
    end
    state = 2
    startTime = msg.user[index].starttime
    endTime = msg.user[index].endtime
    return state,startTime,endTime
end

function MobaMassTroops:UpdateTime(item)
    return self:UpdateTimeMsg(item.msg)
end

--更新一个Item  当item自己的时间完成时 去请求 并判断出最新的状态和相应的时间 以及容量数量 参与人数
function MobaMassTroops:UpdateItem(item,HeroMsg_GatheSummaryInfo,force_update)
    if not self.inited then
        return
    end
    item.msg = HeroMsg_GatheSummaryInfo
    local friend = nil
    local enemy = nil 
    if item.index == 1 then
        friend = item.msg.atk
        enemy = item.msg.def
        item.ui.bg1:SetActive(true)
        item.ui.bg2:SetActive(false)
    else
       
        friend = item.msg.def
        enemy = item.msg.atk  

        item.ui.bg1:SetActive(false)
        item.ui.bg2:SetActive(true)        
    end
    item.ui.player1_face.mainTexture = Global.GResourceLibrary:GetIcon("Icon/head/",friend.face)
    item.ui.player1_name.text = friend.guildBanner == "" and friend.name or "["..friend.guildBanner.."]"..friend.name
    item.ui.player1_lv.text = friend.level
    if enemy.level == nil or enemy.level == 0 then
        item.ui.player2_lv_root.gameObject:SetActive(false)
    else
        item.ui.player2_lv_root.gameObject:SetActive(true)
        item.ui.player2_lv.text = enemy.level
    end
    
    if item.msg.actMonster ~= nil and item.msg.actMonster > 0 then
    	local monster = Global.GTableMgr:GetActMonsterRuleData(item.msg.actMonster)
    	item.ui.player2_face.mainTexture = Global.GResourceLibrary:GetIcon("Icon/head/",RebelData.GetActivityInfo().headIcon)
	    item.ui.player2_name.text = Global.GTextMgr:GetText(monster.name)
    elseif item.msg.guildMonster ~= nil and item.msg.guildMonster > 0 then
		local monster = Global.GTableMgr:GetUnionMonsterData(item.msg.guildMonster)
    	item.ui.player2_face.mainTexture = Global.GResourceLibrary:GetIcon("Icon/head/",monster.icon)
	    item.ui.player2_name.text = Global.GTextMgr:GetText(monster.name)
    elseif item.msg.fortSubType ~= nil and item.msg.fortSubType > 0 then
    	item.ui.player2_face.mainTexture = Global.GResourceLibrary:GetIcon("Icon/head/","666")
        item.ui.player2_name.text = Global.GTextMgr:GetText("FortArmyName_"..item.msg.fortSubType)
    elseif item.msg.govt ~= nil and item.msg.govt > 0 then
    	item.ui.player2_face.mainTexture = Global.GResourceLibrary:GetIcon("Icon/head/","777")
        item.ui.player2_name.text = Global.GTextMgr:GetText("GOV_ui7")     
    elseif item.msg.turretSubType ~= nil and item.msg.turretSubType > 0 then
    	item.ui.player2_face.mainTexture = Global.GResourceLibrary:GetIcon("Icon/head/","777")
        item.ui.player2_name.text = Global.GTextMgr:GetText(Global.GTableMgr:GetTurretDataByid(item.msg.turretSubType).name)     
    elseif item.msg.strongholdSubType ~= nil and item.msg.strongholdSubType > 0 then    
    	item.ui.player2_face.mainTexture = Global.GResourceLibrary:GetIcon("Icon/head/","777")
        item.ui.player2_name.text = Global.GTextMgr:GetText(Global.GTableMgr:GetStrongholdRuleByID(item.msg.strongholdSubType).name)  
    elseif item.msg.fortressSubType ~= nil and item.msg.fortressSubType > 0 then   
    	item.ui.player2_face.mainTexture = Global.GResourceLibrary:GetIcon("Icon/head/","777")
        item.ui.player2_name.text = Global.GTextMgr:GetText(Global.GTableMgr:GetFortressRuleByID(item.msg.fortressSubType).name)      		
    elseif item.msg.eliteMonsterId ~= nil and item.msg.eliteMonsterId > 0 then
		local elitedata = Global.GTableMgr:GetEliteRebelDataById(item.msg.eliteMonsterId)
    	item.ui.player2_face.mainTexture = Global.GResourceLibrary:GetIcon("Icon/head/",elitedata.icon)
        item.ui.player2_name.text = Global.GTextMgr:GetText(elitedata.name) 
		item.ui.player2_lv_root.gameObject:SetActive(true)
        item.ui.player2_lv.text = elitedata.level	
    elseif item.msg.mobabuildingid ~= nil and item.msg.mobabuildingid > 0 then
        if  item.index == 2 then
            item.ui.player1_face.mainTexture = Global.GResourceLibrary:GetIcon("Icon/head/","666")
            local build_data =  Global.GTableMgr:GetMobaMapBuildingDataByID(item.msg.mobabuildingid)
            item.ui.player1_name.text =  Global.GTextMgr:GetText(build_data.Name) 
            item.ui.player2_face.mainTexture = Global.GResourceLibrary:GetIcon("Icon/head/",enemy.face)
            item.ui.player2_name.text = enemy.guildBanner == "" and enemy.name or "["..enemy.guildBanner.."]"..enemy.name     
        else
            item.ui.player2_face.mainTexture = Global.GResourceLibrary:GetIcon("Icon/head/","666")
            local build_data =  Global.GTableMgr:GetMobaMapBuildingDataByID(item.msg.mobabuildingid)
            item.ui.player2_name.text =  Global.GTextMgr:GetText(build_data.Name) 
        end
    else
	    item.ui.player2_face.mainTexture = Global.GResourceLibrary:GetIcon("Icon/head/",enemy.face)
	    item.ui.player2_name.text = enemy.guildBanner == "" and enemy.name or "["..enemy.guildBanner.."]"..enemy.name
    end
    

    if HeroMsg_GatheSummaryInfo.pathType == Common_pb.TeamMoveType_GatherCall then
        item.ui.forcenum1.text = item.msg.num
        local addnum = item.msg.addNum 
        if  addnum == 0 then 
            item.ui.forcenum2.text = "/"..item.msg.numMax
        else
            item.ui.forcenum2.text = "/"..(item.msg.numMax - addnum).."[20F545FF] +"..addnum.."[-]"
        end
    else
        item.ui.forcenum1.text = item.msg.num
        item.ui.forcenum2.text = ""
    end


    ---[[
    if item.msg.playerNumMax > 0 then

        
       -- if Global.GGUIMgr:GetPlatformType() == LoginMsg_pb.AccType_ios_muzhi or
       -- Global.GGUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_muzhi or 
       -- Global.GGUIMgr:GetPlatformType() == LoginMsg_pb.AccType_adr_opgame then
            item.ui.member.gameObject:SetActive(false)
        --else
        --    item.ui.member.gameObject:SetActive(true)
        --    item.ui.membernum1.text = item.msg.playerNum
        --   item.ui.membernum2.text = "/"..item.msg.playerNumMax
        --end

    else
        item.ui.member.gameObject:SetActive(false)
    end
    ---]]
    
    local state,startime,endtime = self:UpdateTime(item)
    item.ui.state.text = Global.GTextMgr:GetText(self.stateTextIds[state])
    item.ui.state_index = state
    if state == 1 then
        if item.index == 1 then
            if item.trf:Find("button_invite") ~= nil then
                item.ui.share = item.trf:Find("button_invite").gameObject
                if HeroMsg_GatheSummaryInfo.atk.charid == MainData.GetCharId() then
                    item.ui.share:SetActive(true)
                end
            end
        end
    else
        if item.trf:Find("button_invite") ~= nil then
            item.ui.share = item.trf:Find("button_invite").gameObject
            item.ui.share:SetActive(false)
        end
    end
   -- print(state,startime,endtime,Serclimax.GameTime.GetSecTime())

    item.ui.countdownid = nil
    if state == 4 then
        if self.cur_select_index /10 >= 1 then
            self:CloseDetail()
        else
            self:RemoveItem(item)
        end
        return
    end
    if self.cur_select_index == item.index or force_update then
        local ex = force_update and "MassTroops" or "MassTroopsForce"
        item.ui.countdownid = ex..item.charid..":"..item.index..":"..item.msg.pathType
        --print("  CountDown.Instance:Add",item.ui.countdownid)
	        CountDown.Instance:Add(item.ui.countdownid,endtime,CountDown.CountDownCallBack(function(t)
	            if item.isdestroy then
	              --  print(item.isdestroy,"DDDDDDDDDDDDDDDDDDDDDestroy")
	                return
                end
		    item.ui.arrivedtime.text  = t
            item.ui.arrivedBar.value = math.min(1,(Serclimax.GameTime.GetSecTime() - startime)/(endtime - startime))

                if endtime - Serclimax.GameTime.GetSecTime() <= 5 then
                    item.Enable_Click = false
                else
                    item.Enable_Click = true
                end
            

	    	if endtime+1 - Serclimax.GameTime.GetSecTime() <= 0 then				
                CountDown.Instance:Remove(item.ui.countdownid)
			    --print("add CountDown.Instance:Remove",item.ui.countdownid)
                item.ui.countdownid = nil
                --print("statestatestatestatestatestatestatestatestatestatestatestate",state)
                if state <= 3 then
                    if HeroMsg_GatheSummaryInfo.pathType == Common_pb.TeamMoveType_GatherCall and HeroMsg_GatheSummaryInfo.pathstarttime == 0 then
                        --print("StartStartStartStartStartStartRequestInfoRequestInfoRequestInfoRequestInfo")
                        self:RequestInfo(item.req_charid,function(msg)
                            --print("RequestInfoRequestInfoRequestInfoRequestInfo",item.req_charid)
                            if msg == nil then         
                                self:UpdateItem(item,item.msg,force_update)
                            else
                                if msg.gather[1] ~= nil then
                                    if self.cur_select_index >= 10 and self.detail_ui.source_item ~= nil then
                                        self.detail_ui.source_item.msg = msg.gather[1]
                                    end                            
                                    self:UpdateItem(item,msg.gather[1],force_update)
                                end
                            end
                        end)
                        if state == 3 and self.detail_ui.itemlist ~= nil then
                            for _, v in pairs(self.detail_ui.itemlist) do
                                if v.ui.disband ~= nil then
                                    v.ui.disband.gameObject:SetActive(false)
                                end
                            end
                        end   
                    else
                        if self.cur_select_index /10 >= 1 then
                            self:CloseDetail()
                        else
                            self:RemoveItem(item)
                        end
                    end
                else
                    
                    if self.cur_select_index /10 >= 1 then
                        self:CloseDetail()
                    else
                        self:RemoveItem(item)
                    end
                end 
		    end			
	    end)) 
    end
end



function MobaMassTroops:RemoveItem(item)
    if item == nil then
        return 
    end
    item.isdestroy = true
    if item.ui.countdownid ~= nil then
        CountDown.Instance:Remove(item.ui.countdownid)
        -- print("RemoveItem CountDown.Instance:Remove",item.ui.countdownid)
        item.ui.countdownid = nil
    end
    
    item.obj:SetActive(false)
    UnityEngine.GameObject.Destroy(item.obj)
    item.obj = nil
    if self.list_ui[item.index].list[item.charid] ~= nil then
        self.list_ui[item.index].count = self.list_ui[item.index].count - 1      
    end
    
    if self.cur_select_index == item.index then
        self.list_ui[self.cur_select_index].grid:Reposition()
    end  
    if self.list_ui[item.index].count == 0 then
        self.list_ui[item.index].no_one:SetActive(true)
    else
        self.list_ui[item.index].no_one:SetActive(false)
    end  
    self.list_items[item.charid] = nil
    self.list_ui[item.index].list[item.charid] = nil
    item = nil
end

function MobaMassTroops:RemoveItem4Push(guild,charid)
    local index = guild == MobaMainData.GetTeamID() and 1 or 2
    --print("RemoveItem4Push   ",index,self.list_ui[index].list[charid])
    if self.list_ui[index].list[charid] ~= null then
       -- print(index,guild,UnionInfoData.GetData().guildInfo.guildId,self.list_ui[index].list[charid])
        self:RemoveItem(self.list_ui[index].list[charid])
    end  
    --[[
    if self.cur_select_index >= 10 then
        self:CloseDetail()
        end
    --]]
end

function MobaMassTroops:SetItem(item,trf,index,HeroMsg_GatheSummaryInfo,force_update)
    item.index = index
    item.obj = trf.gameObject
    item.Enable_Click = true
    item.obj_collider = item.obj:GetComponent("BoxCollider")
    if index == 1 then
        item.charid = HeroMsg_GatheSummaryInfo.atk.charid
    else
        item.charid = HeroMsg_GatheSummaryInfo.def.charid
    end
    item.req_charid = HeroMsg_GatheSummaryInfo.atk.charid
    if HeroMsg_GatheSummaryInfo.pathType ~= Common_pb.TeamMoveType_GatherCall then
        item.charid = item.charid..":"..HeroMsg_GatheSummaryInfo.pathType
    end
    item.trf = trf
    item.ui = {}
    item.ui.player1_face = item.trf:Find("head_bg01/icon"):GetComponent("UITexture")
    item.ui.player1_name = item.trf:Find("head_bg01/name_01"):GetComponent("UILabel")
    item.ui.player1_pos = item.trf:Find("head_bg01/btn_coord").gameObject
    item.ui.player1_lv = item.trf:Find("head_bg01/level/Label"):GetComponent("UILabel")
    item.ui.player1_lv.gameObject:SetActive(false)
    item.ui.player2_face = item.trf:Find("head_bg02/icon"):GetComponent("UITexture")
    item.ui.player2_name = item.trf:Find("head_bg02/name_02"):GetComponent("UILabel")
    item.ui.player2_pos = item.trf:Find("head_bg02/btn_coord").gameObject
    item.ui.player2_lv = item.trf:Find("head_bg02/level/Label"):GetComponent("UILabel")
    item.ui.player2_lv_root = item.trf:Find("head_bg02/level")

    item.ui.forcenum1 = item.trf:Find("mid_text/number01"):GetComponent("UILabel")
    item.ui.forcenum2 = item.trf:Find("mid_text/number02"):GetComponent("UILabel")

    item.ui.membernum1 = item.trf:Find("CommandNum/number"):GetComponent("UILabel")
    item.ui.membernum2 = item.trf:Find("CommandNum/number (1)"):GetComponent("UILabel")
    item.ui.member = item.trf:Find("CommandNum")

    item.ui.arrivednode = item.trf:Find("bg_exp")
    item.ui.arrivedBar = item.trf:Find("bg_exp/bg/bar"):GetComponent("UISlider")
    item.ui.arrivedtime = item.trf:Find("bg_exp/bg/text"):GetComponent("UILabel")
    item.ui.state = item.trf:Find("bg_exp/Label"):GetComponent("UILabel")

    item.ui.bg1 = item.trf:Find("base_01").gameObject
    item.ui.bg2 = item.trf:Find("base_02").gameObject
    item.isdestroy = false
    if item.trf:Find("button_invite") ~= nil then
        item.ui.share = item.trf:Find("button_invite").gameObject
    end
	--Global.DumpMessage(HeroMsg_GatheSummaryInfo , "d:/HeroMsg_GatheSummaryInfo.lua")
    if item.index == 1 then
        if item.trf:Find("button_invite") ~= nil then
            item.ui.share = item.trf:Find("button_invite").gameObject
            UIUtil.SetClickCallback(item.ui.share,function()
                if HeroMsg_GatheSummaryInfo.atk.charid == MainData.GetCharId() then
                    if UnionInfoData.GetRallyTime() ~= 0 then
                        if UnionInfoData.GetRallyTime() + tonumber(Global.GTableMgr:GetGlobalData(DataEnum.ScGlobalDataId.RallyShareTime).value) > Serclimax.GameTime.GetSecTime() then
                            FloatText.Show(Global.GTextMgr:GetText("ui_rally_cd"))
                            return
                        end
                    end
                    UnionInfoData.SetRallyTime(Serclimax.GameTime.GetSecTime())
                    local deficon
                    local defunionname = ""
                    local defname
                    --local playerunionname = HeroMsg_GatheSummaryInfo.atk.guildBanner
                    --local playername = HeroMsg_GatheSummaryInfo.atk.name
					local teamData = Global.GTableMgr:GetMobaTeamData(HeroMsg_GatheSummaryInfo.atk.guildid)
					local roleData = Global.GTableMgr:GetMobaRoleTablebyID(HeroMsg_GatheSummaryInfo.atk.officialId)
					local atkU = "【".. Global.GTextMgr:GetText(teamData.Name) .. "】"
					local atkR = roleData and Global.GTextMgr:GetText(roleData.Name) or ""
					local playerunionname = atkR .. atkU
					local playername = HeroMsg_GatheSummaryInfo.atk.name
					
                    if HeroMsg_GatheSummaryInfo.actMonster ~= nil and HeroMsg_GatheSummaryInfo.actMonster > 0 then
                        local monster = Global.GTableMgr:GetActMonsterRuleData(HeroMsg_GatheSummaryInfo.actMonster)
                        deficon = RebelData.GetActivityInfo().headIcon
                        defname = Global.GTextMgr:GetText(monster.name)
                    elseif HeroMsg_GatheSummaryInfo.guildMonster ~= nil and HeroMsg_GatheSummaryInfo.guildMonster > 0 then
                        local monster = Global.GTableMgr:GetUnionMonsterData(HeroMsg_GatheSummaryInfo.guildMonster)
                        deficon = monster.icon
                        defname = Global.GTextMgr:GetText(monster.name)
                    elseif HeroMsg_GatheSummaryInfo.fortSubType ~= nil and HeroMsg_GatheSummaryInfo.fortSubType > 0 then
                        deficon = "666"
                        defname = Global.GTextMgr:GetText("FortArmyName_"..HeroMsg_GatheSummaryInfo.fortSubType)
					elseif HeroMsg_GatheSummaryInfo.eliteMonsterId ~= nil and HeroMsg_GatheSummaryInfo.eliteMonsterId > 0 then
						local elitedata = Global.GTableMgr:GetEliteRebelDataById(HeroMsg_GatheSummaryInfo.eliteMonsterId)
						deficon = elitedata.icon
                        defname = Global.GTextMgr:GetText(elitedata.name)
					elseif HeroMsg_GatheSummaryInfo.strongholdSubType ~= nil and HeroMsg_GatheSummaryInfo.strongholdSubType > 0 then
						local strongholdData = Global.GTableMgr:GetStrongholdRuleByID(HeroMsg_GatheSummaryInfo.strongholdSubType)
						deficon = "666"
                        defname = Global.GTextMgr:GetText(strongholdData.name)
					elseif HeroMsg_GatheSummaryInfo.fortressSubType ~= nil and HeroMsg_GatheSummaryInfo.fortressSubType > 0 then
						local fortressData = Global.GTableMgr:GetFortressRuleByID(HeroMsg_GatheSummaryInfo.fortressSubType)
						deficon = "666"
                        defname = Global.GTextMgr:GetText(fortressData.name)
                    elseif HeroMsg_GatheSummaryInfo.turretSubType ~= nil and HeroMsg_GatheSummaryInfo.turretSubType > 0 then
                        local turretData = Global.GTableMgr:GetTurretDataByid(HeroMsg_GatheSummaryInfo.turretSubType)
                        deficon = "777"
                        defname = Global.GTextMgr:GetText(turretData.name)
                    elseif HeroMsg_GatheSummaryInfo.govt ~= nil and HeroMsg_GatheSummaryInfo.govt > 0 then
                        deficon = "777"
                        defname = Global.GTextMgr:GetText("GOV_ui7")
					elseif HeroMsg_GatheSummaryInfo.mobabuildingid ~= nil and HeroMsg_GatheSummaryInfo.mobabuildingid > 0 then
						local mobaBuild = Global.GTableMgr:GetMobaMapBuildingDataByID(HeroMsg_GatheSummaryInfo.mobabuildingid)
						deficon = "666"
						defname = Global.GTextMgr:GetText(mobaBuild.Name)
                    else
                        deficon = HeroMsg_GatheSummaryInfo.def.face
                        --defunionname = HeroMsg_GatheSummaryInfo.def.guildBanner == "" and "" or "["..HeroMsg_GatheSummaryInfo.def.guildBanner.."]"
                        defname = HeroMsg_GatheSummaryInfo.def.name
						local teamData = Global.GTableMgr:GetMobaTeamData(HeroMsg_GatheSummaryInfo.def.guildid)
						local roleData = Global.GTableMgr:GetMobaRoleTablebyID(HeroMsg_GatheSummaryInfo.def.officialId)
						local defU = "【".. Global.GTextMgr:GetText(teamData.Name) .. "】"
						local defR = roleData and Global.GTextMgr:GetText(roleData.Name) or ""
						defunionname = defR .. defU
						
                    end
                    local state,startime,endtime = self:UpdateTime(item)
                    local number1, number2
                    number1 = HeroMsg_GatheSummaryInfo.num
                    local addnum = HeroMsg_GatheSummaryInfo.addNum 
                    if  addnum == 0 then 
                        number2 = HeroMsg_GatheSummaryInfo.numMax
                    else
                        number2 = (HeroMsg_GatheSummaryInfo.numMax - addnum).."[20F545FF] +"..addnum.."[-]"
                    end
                    local send = {}
                    send.curChanel = self.GetInterface("ChatChannel")--ChatMsg_pb.chanel_MobaTeam
                    send.content = Global.GTextMgr:GetText("ui_rally_msg")   
                    send.spectext = deficon..","..defunionname..","..defname..","..endtime..","..startime..","..HeroMsg_GatheSummaryInfo.defpos.x..","..HeroMsg_GatheSummaryInfo.defpos.y..","..HeroMsg_GatheSummaryInfo.atk.charid..","..playerunionname..","..playername
                    send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
                    send.type = self.GetInterface("ChatConditionSendType")--ChatMsg_pb.ChatInfoConditionType_MobaGather
                    send.chatType = 6
                    send.tarUid = HeroMsg_GatheSummaryInfo.defHomeuid
                    send.senderguildname = hasUnion and UnionInfoData.GetData().guildInfo.banner or ""
                    self.GetInterface("Chat").SendConditionContent(send, function()
                        FloatText.Show(Global.GTextMgr:GetText("union_invite_text7"), Color.green)
                    end)      
                end
            end)
        end
    end
		
    self:UpdateItem(item,HeroMsg_GatheSummaryInfo,force_update)

    UIUtil.SetClickCallback(item.ui.player1_pos,function()
        if self.cur_select_index /10 >= 1 then
            self:CloseDetail()
        end
        MobaUnionWar.CloseAll()
        if(Global.GetMobaMode == 1) then
            if item.index == 1 then 
                --MainCityUI.ShowWorldMap(item.msg.atkpos.x,item.msg.atkpos.y,true,nil)
                MobaMain.LookAt(item.msg.atkpos.x,item.msg.atkpos.y,true)
                local offsetx,offsety = MobaMain.MobaMinPos()
                MobaMain.SelectTile(item.msg.atkpos.x+ offsetx,item.msg.atkpos.y+ offsety)
            else
                MobaMain.LookAt(item.msg.defpos.x,item.msg.defpos.y,true)
                local offsetx,offsety = MobaMain.MobaMinPos()
                MobaMain.SelectTile(item.msg.defpos.x+ offsetx,item.msg.defpos.y+ offsety)
    
                --MainCityUI.ShowWorldMap(item.msg.defpos.x,item.msg.defpos.y,true,nil)  
            end 
        else
            
            if item.index == 1 then 
                --MainCityUI.ShowWorldMap(item.msg.atkpos.x,item.msg.atkpos.y,true,nil)
                GuildWarMain.LookAt(item.msg.atkpos.x,item.msg.atkpos.y,true)
                local offsetx,offsety = GuildWarMain.MobaMinPos()
                GuildWarMain.SelectTile(item.msg.atkpos.x+ offsetx,item.msg.atkpos.y+ offsety)
            else
                GuildWarMain.LookAt(item.msg.defpos.x,item.msg.defpos.y,true)
                local offsetx,offsety = GuildWarMain.MobaMinPos()
                GuildWarMain.SelectTile(item.msg.defpos.x+ offsetx,item.msg.defpos.y+ offsety)
    
                --MainCityUI.ShowWorldMap(item.msg.defpos.x,item.msg.defpos.y,true,nil)  
            end 
        end

    end)

    UIUtil.SetClickCallback(item.ui.player2_pos,function()
        if self.cur_select_index /10 >= 1 then
            self:CloseDetail()
        end        
        MobaUnionWar.CloseAll()
        if(Global.GetMobaMode == 1) then
            if item.index == 1 then
                --MainCityUI.ShowWorldMap(item.msg.defpos.x,item.msg.defpos.y,true,nil)  
                MobaMain.LookAt(item.msg.defpos.x,item.msg.defpos.y,true)
                local offsetx,offsety = MobaMain.MobaMinPos()
                MobaMain.SelectTile(item.msg.defpos.x+ offsetx,item.msg.defpos.y+ offsety)         
            else
                --MainCityUI.ShowWorldMap(item.msg.atkpos.x,item.msg.atkpos.y,true,nil)
                MobaMain.LookAt(item.msg.atkpos.x,item.msg.atkpos.y,true)
                local offsetx,offsety = MobaMain.MobaMinPos()
                MobaMain.SelectTile(item.msg.atkpos.x+ offsetx,item.msg.atkpos.y+ offsety)        
            end    
        else
            if item.index == 1 then
                --MainCityUI.ShowWorldMap(item.msg.defpos.x,item.msg.defpos.y,true,nil)  
                GuildWarMain.LookAt(item.msg.defpos.x,item.msg.defpos.y,true)
                local offsetx,offsety = GuildWarMain.MobaMinPos()
                GuildWarMain.SelectTile(item.msg.defpos.x+ offsetx,item.msg.defpos.y+ offsety)         
            else
                --MainCityUI.ShowWorldMap(item.msg.atkpos.x,item.msg.atkpos.y,true,nil)
                GuildWarMain.LookAt(item.msg.atkpos.x,item.msg.atkpos.y,true)
                local offsetx,offsety = GuildWarMain.MobaMinPos()
                GuildWarMain.SelectTile(item.msg.atkpos.x+ offsetx,item.msg.atkpos.y+ offsety)        
            end    
        end
    
    end)

    
end

function MobaMassTroops:AddItem(index,HeroMsg_GatheSummaryInfo)
    local item = {}
    local obj = NGUITools.AddChild(self.list_ui[index].grid.gameObject,self.assembled_prefab)
    if index == 1 then
        obj.name = HeroMsg_GatheSummaryInfo.atk.charid
    else
        obj.name = HeroMsg_GatheSummaryInfo.def.charid
    end    
    obj.name = HeroMsg_GatheSummaryInfo.atk.charid
    obj:SetActive(true)
    self:SetItem(item,obj.transform,index,HeroMsg_GatheSummaryInfo,false)
    if HeroMsg_GatheSummaryInfo.pathType == Common_pb.TeamMoveType_GatherCall then
        if item ~= nil and item.obj ~= nil  then
            UIUtil.SetClickCallback(item.obj,function()
                if not item.Enable_Click then
                    return
                end
                self:OpenDetail(item)
            end)
            self.list_ui[item.index].list[item.charid] = item
            self.list_ui[item.index].count = self.list_ui[item.index].count + 1 
            self.list_items[item.charid] = item
    
            if self.join ~= nil then
                if self.join.charid == item.charid then
                    MobaMassTroops.join = nil 
                    self:OpenDetail(item)                
                end
            end
        end
    else
        if index == 2 then
            if HeroMsg_GatheSummaryInfo.pathType == Common_pb.TeamMoveType_AttackPlayer then
                if item ~= nil and item.obj ~= nil  then
                    UIUtil.SetClickCallback(item.obj,function()
                        local offset_x,offset_y = MobaMain.MobaMinPos()  
                        local x = HeroMsg_GatheSummaryInfo.defpos.x + offset_x
                        local y = HeroMsg_GatheSummaryInfo.defpos.y + offset_y   
                        if Global.GetMobaMode() ==2 then
                            GuildWarMain.ShowTileInfo(x,y)
                            MobaUnionWar.CloseAll()  
                        else
                            MobaMain.ShowTileInfo(x,y)
                            --print("MobaEmbassy.Show(HeroMsg_GatheSummaryInfo.def.charid)",HeroMsg_GatheSummaryInfo.def.charid)
                            --MobaEmbassy.Show(HeroMsg_GatheSummaryInfo.def.charid)
                            --local offset_x,offset_y = MobaMain.MobaMinPos()  
                            --local x = HeroMsg_GatheSummaryInfo.defpos.x + offset_x
                            --local y = HeroMsg_GatheSummaryInfo.defpos.y + offset_y
                            --MobaEmbassy.CanEmbassy(HeroMsg_GatheSummaryInfo.defHomeuid,x,y,HeroMsg_GatheSummaryInfo.def.charid)   
                            MobaUnionWar.CloseAll()  
                        end
 
                    end)
                end
            elseif HeroMsg_GatheSummaryInfo.pathType == Common_pb.TeamMoveType_MobaAtkBuild then
                if item ~= nil and item.obj ~= nil  then
                    UIUtil.SetClickCallback(item.obj,function()
                        local offset_x,offset_y = MobaMain.MobaMinPos()  
                        local x = HeroMsg_GatheSummaryInfo.defpos.x + offset_x
                        local y = HeroMsg_GatheSummaryInfo.defpos.y + offset_y  
                        MobaEmbassy.ShowMobaBaseMode(HeroMsg_GatheSummaryInfo.defHomeuid,x,y,HeroMsg_GatheSummaryInfo.mobabuildingid)
                        MobaUnionWar.CloseAll()                       
                    end)
                end 
            end
        end
        if item ~= nil and item.obj ~= nil  then
            self.list_ui[item.index].list[item.charid] = item
            self.list_ui[item.index].count = self.list_ui[item.index].count + 1 
            self.list_items[item.charid] = item
        end    
    end

    --if item == nil then
    --    print("################ add item nil",index)
    --end
    
    return item
end

function MobaMassTroops:AddItem4Push(guild,HeroMsg_GatheSummaryInfo)
    local index = guild == MobaMainData.GetTeamID() and 1 or 2
    local item = self:AddItem(index,HeroMsg_GatheSummaryInfo)
    --print("AddItem4Push   ",index,item,guild,UnionInfoData.GetData().guildInfo.guildId)
    if item == nil then
        return
    end
    if self.cur_select_index == item.index then
        self.list_ui[self.cur_select_index].grid:Reposition()
    end    
    if self.list_ui[item.index].count == 0 then
        self.list_ui[item.index].no_one:SetActive(true)
    else
        self.list_ui[item.index].no_one:SetActive(false)
    end      
end

function MobaMassTroops:StopListCountDown(index)
   -- print("StopListCountDown",index)
    if self.list_ui[index] == nil then
        return
    end
    table.foreach(self.list_ui[index].list,function(_,v)
        if v ~= nil then
            if v.ui.countdownid ~= nil then
                CountDown.Instance:Remove(v.ui.countdownid)
                 --print("StopListCountDown CountDown.Instance:Remove",v.ui.countdownid) 
            end
            v.ui.countdownid = nil
        end
    end)
end

function MobaMassTroops:StartListCountDown(index)
    table.foreach(self.list_ui[index].list,function(_,v)
        if v ~= nil then
            if v.ui.countdownid == nil then
                self:UpdateItem(v,v.msg)
            end
        end
    end)  
end

function MobaMassTroops:Clearlist()
    for i = 1,3,1 do
        table.foreach(self.list_ui[i].list,function(_,v)
            if v ~= nil then
                v.isdestroy = true
                if v.ui.countdownid ~= nil then
                    CountDown.Instance:Remove(v.ui.countdownid)
                    -- print("Clearlist CountDown.Instance:Remove",v.ui.countdownid)
                end
                v.ui.countdownid = nil
                
                v.obj:SetActive(false)
                UnityEngine.GameObject.Destroy(v.obj)                
            end
        end)  
    end
end

function MobaMassTroops:SortItem(gather)
    local list = {}
    for i= 1,#gather,1 do
        list[i] = gather[i]
    end
    table.sort(list,function(a,b)
        local aindex = a.pathType == Common_pb.TeamMoveType_GatherCall and 1 or 0
        local bindex = b.pathType == Common_pb.TeamMoveType_GatherCall and 1 or 0
        return aindex > bindex
    end)
    return list
end

function MobaMassTroops:OpenList(index) 
    if Global.GetMobaMode() == 2 then
        GuildWarMain.GetPreMassTotalNum()[index] = GuildWarMain.MassTotlaNum[index]
    else
        MobaMain.GetPreMassTotalNum()[index] = MobaMain.MassTotlaNum[index]
    end

    if self.cur_select_index ~= index then
        self:CloseCurList()
        self.cur_select_index = index
    end
    self.list_ui.root:SetActive(true)
    self.list_ui[self.cur_select_index].notice.gameObject:SetActive(false)
    self.list_ui[self.cur_select_index].root:SetActive(true)
	
    if self.list_ui[self.cur_select_index].msg == nil then
        self:RequestInfo(0,function(msg) 
			Global.DumpMessage(msg , "d:/moba.lua")
            self.list_ui[self.cur_select_index].msg = msg
            local count = #msg.gather
            local gather = self:SortItem(msg.gather)
            if count == 0 then
                self.list_ui[self.cur_select_index].no_one:SetActive(true)
                if self.join ~= nil then
                    MobaMassTroops.join = nil
                    FloatText.Show(Global.GTextMgr:GetText("ui_rally_cancelled"))
                end
            else
                --self.list_ui[self.cur_select_index].no_one:SetActive(false)
                local rallycancel = true
                for i= 1,count,1 do
                    if self.join ~= nil then
                        if self.join.charid == gather[i].atk.charid then 
                            rallycancel = false
                        end
                    end
                    self:AddItem(self.cur_select_index,gather[i])
                end

                if self.join ~= nil then
                    MobaMassTroops.join = nil
                    if rallycancel then
                        FloatText.Show(Global.GTextMgr:GetText("ui_rally_cancelled"))
                    end
                end
                --self.list_ui[self.cur_select_index].grid:Reposition()
                --self.list_ui[self.cur_select_index].scroll_view:SetDragAmount(0, 0, false) 
                --print(count,self.list_ui[self.cur_select_index].count) 
                if self.list_ui[self.cur_select_index].count == 0 then
                    self.list_ui[self.cur_select_index].no_one:SetActive(true)
                else
                    self.list_ui[self.cur_select_index].no_one:SetActive(false)
                    self.list_ui[self.cur_select_index].grid:Reposition()
                    self.list_ui[self.cur_select_index].scroll_view:SetDragAmount(0, 0, false) 
                end 
            end
        end)
    else
        if self.list_ui[self.cur_select_index].count == 0 then
            self.list_ui[self.cur_select_index].no_one:SetActive(true)
        else
            self.list_ui[self.cur_select_index].no_one:SetActive(false)
            self:StartListCountDown(self.cur_select_index)
            self.list_ui[self.cur_select_index].grid:Reposition()
            self.list_ui[self.cur_select_index].scroll_view:SetDragAmount(0, 0, false)
        end     
    end
end


function MobaMassTroops:CloseCurList()
    if self.cur_select_index >= 1  and self.list_ui[self.cur_select_index] ~= nil then
        self:StopListCountDown(self.cur_select_index)   
        self.list_ui[self.cur_select_index].root:SetActive(false)
    end
end

function MobaMassTroops:ClearEmbassyItem()
    if self.detail_ui.itemlist ~= nil then
        table.foreach(self.detail_ui.itemlist,function(_,v)
            if v.obj ~= nil then
                v.obj:SetActive(false)
                v.destroyfunc()
                UnityEngine.GameObject.Destroy(v.obj)
                v.obj = nil
            end
        end)
    end
    self.detail_ui.itemlist = nil
end

function MobaMassTroops:_RefrushEmbassyNum()
    self.detail_ui.num = 0;
    table.foreach(self.detail_ui.itemlist,function(_,v) 
        if v ~= nil then
            self.detail_ui.num = self.detail_ui.num + v.num
        end
    end)
end

function MobaMassTroops:_RemoveEmbassyItem(eitem)
    local id = eitem.id
    if eitem.build_charid ~= nil then
        id = eitem.build_charid
    end
    print("EEEEEEEEEEE",id)
    self.detail_ui.count = self.detail_ui.count -1 
    eitem.obj:SetActive(false)
    UnityEngine.GameObject.Destroy(eitem.obj)
    self.detail_ui.itemlist[id].obj = nil
    eitem = nil
    self.detail_ui.itemlist[id] = nil
    self.detail_ui.Table:Reposition()
    self:_RefrushEmbassyNum()  
end

function MobaMassTroops:_FillEmbassyItem(item,homeuid,msgitemlist)
    self:ClearEmbassyItem()

    MobaEmbassy.SetExtra(homeuid,self.cur_select_index == 20 and item.charid == MainData.GetCharId())
    self.detail_ui.count = 0
    self.detail_ui.itemlist = {}
    local build_id = item.msg.mobabuildingid ~= nil and item.msg.mobabuildingid or nil
    if build_id == 0 or item.index == 1 then
        build_id = nil
    end


    for i = 1,#msgitemlist,1 do

        local eitem = MobaEmbassy.AddEmbassyItem(msgitemlist[i],self.detail_ui.itemPrefab,self.detail_ui.ArmyPrefab,self.detail_ui.Table.gameObject,true,build_id)
        if build_id ~= nil then
            eitem.build_charid = msgitemlist[i].charid
        end
        if item.index == 2 then
            local enable_disband = item.ui.state_index ~= self.join_state.full and item.charid == MainData.GetCharId() and eitem.ui.userMsg.charid ~= MainData.GetCharId()
            print("IIIIIitem.index",item.index,enable_disband,self.roleid,MobaData.GetRoleID())
            if item.index == 2 then
                enable_disband = enable_disband or (self.roleid == MobaData.GetRoleID())
            end
            eitem.ui.disband.gameObject:SetActive(enable_disband)
        else
            local enable_disband = item.ui.state_index ~= self.join_state.full and item.charid == MainData.GetCharId() and eitem.ui.userMsg.charid ~= MainData.GetCharId()
            eitem.ui.disband.gameObject:SetActive(enable_disband) 
        end
        --[[
        if (item.ui.state_index == self.join_state.cancel) then
            if item.index == 2 then
                eitem.ui.disband.gameObject:SetActive(false)
            else
                local enable_disband = item.ui.state_index ~= self.join_state.full and item.charid == MainData.GetCharId() and eitem.ui.userMsg.charid ~= MainData.GetCharId()
                eitem.ui.disband.gameObject:SetActive(enable_disband)
            end
        else
            local enable_disband = item.ui.state_index ~= self.join_state.full and item.charid == MainData.GetCharId() and eitem.ui.userMsg.charid ~= MainData.GetCharId()
            if item.index == 2 then
                enable_disband = enable_disband or (self.roleid == MobaData.GetRoleID())
            end
            eitem.ui.disband.gameObject:SetActive(enable_disband)
        end
        --]]
        UIUtil.SetClickCallback(eitem.ui.disband.gameObject, function()
            MessageBox.Show(System.String.Format(Global.GTextMgr:GetText(Text.union_disband_hint), eitem.ui.userMsg.name), function()
                local charId = eitem.ui.userMsg.charid


                if item.index == 2 then
       

                    if self.detail_ui.item.msg.mobabuildingid ~= nil and self.detail_ui.item.msg.mobabuildingid > 0 then
                        local pathid = 0
                        local msg = MobaMainData.GetGarrisonInfo(item.msg.mobabuildingid)
                        local garrisondata = nil 
                        for i=1,#msg.garrisonInfos do
                            if msg.garrisonInfos[i].garrisonData.charid == charId then
                                garrisondata = msg.garrisonInfos[i].garrisonData
                            end 
                        end
                        
                        if garrisondata ~= nil then
                            pathid = garrisondata.pathid
                        end             
                         
                        MobaEmbassy.CancelEmbassyItemEx(nil,charId,self.msg,function()
                            CountDown.Instance:Remove("AddEmbassyItem"..charId)
                        self:_RemoveEmbassyItem(eitem)                        
                        self:RequestInfo(item.req_charid,function(msg)
                        if msg == nil then
                            self:UpdateItem(item,item.msg,true)
                             self:UpdateItem(self.detail_ui.item,item.msg,true)
                        else
                            if self.cur_select_index >= 10 and self.detail_ui.source_item ~= nil then
                                self.detail_ui.source_item.msg = msg.gather[1]
                            end                            
                            self:UpdateItem(item,msg.gather[1],true)
                            self:UpdateItem(self.detail_ui.item,msg.gather[1],true)
                        end
                        end)
                        end,self.detail_ui.item.msg.mobabuildingid,pathid)  
                    else
                        MobaEmbassy.CancelEmbassyItemEx(self.detail_ui.homeuid,charId,self.msg,function()
                            CountDown.Instance:Remove("AddEmbassyItem"..charId)
                            self:_RemoveEmbassyItem(eitem)                        
                            self:RequestInfo(item.req_charid,function(msg)
                            if msg == nil then
                                self:UpdateItem(item,item.msg,true)
                                 self:UpdateItem(self.detail_ui.item,item.msg,true)
                            else
                                if self.cur_select_index >= 10 and self.detail_ui.source_item ~= nil then
                                    self.detail_ui.source_item.msg = msg.gather[1]
                                end                            
                                self:UpdateItem(item,msg.gather[1],true)
                                self:UpdateItem(self.detail_ui.item,msg.gather[1],true)
                            end
                            end)
                        end)   
                    end
                    return
                end


                local req = MobaMsg_pb.MsgMobaCancelGatherPathRequest()
                if Global.GetMobaMode() == 2 then
                    req = GuildMobaMsg_pb.GuildMobaCancelGatherPathRequest()
                end
                local msg = self.detail_ui.msg
                for _, v in ipairs(self.detail_ui.msg) do
                    if v.charid == charId then
                        req.tarpathid = v.pathid
                    end
                end
                req.cancelUserId = charId
                if Global.GetMobaMode() ==1 then
                    Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaCancelGatherPathRequest, req, MobaMsg_pb.MsgMobaCancelGatherPathResponse, function(msg)
                        if msg.code == 0 then
                           
                            CountDown.Instance:Remove("AddEmbassyItem"..charId)
                            self:_RemoveEmbassyItem(eitem)
                            self:RequestInfo(item.req_charid,function(msg)
                            if msg == nil then
                                self:UpdateItem(item,item.msg,true)
                                 self:UpdateItem(self.detail_ui.item,item.msg,true)
                            else
                                if self.cur_select_index >= 10 and self.detail_ui.source_item ~= nil then
                                    self.detail_ui.source_item.msg = msg.gather[1]
                                end                            
                                self:UpdateItem(item,msg.gather[1],true)
                                self:UpdateItem(self.detail_ui.item,msg.gather[1],true)
                            end
                        end)
                        else
                            Global.FloatError(msg.code)
                        end
                    end)  
                else

                    Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaCancelGatherPathRequest, req, GuildMobaMsg_pb.GuildMobaCancelGatherPathResponse, function(msg)   
                        if msg.code == 0 then
                           
                            CountDown.Instance:Remove("AddEmbassyItem"..charId)
                            self:_RemoveEmbassyItem(eitem)
                            self:RequestInfo(item.req_charid,function(msg)
                            if msg == nil then
                                self:UpdateItem(item,item.msg,true)
                                 self:UpdateItem(self.detail_ui.item,item.msg,true)
                            else
                                if self.cur_select_index >= 10 and self.detail_ui.source_item ~= nil then
                                    self.detail_ui.source_item.msg = msg.gather[1]
                                end                            
                                self:UpdateItem(item,msg.gather[1],true)
                                self:UpdateItem(self.detail_ui.item,msg.gather[1],true)
                            end
                        end)
                        else
                            Global.FloatError(msg.code)
                        end
                    end) 
                end
  
            end,
            function()
            end)
        end)
        eitem.cancel_cb = function() 
            self:_RemoveEmbassyItem(eitem)
        end
        self.detail_ui.count = self.detail_ui.count +1
        if build_id ~= nil then
            self.detail_ui.itemlist[msgitemlist[i].charid] = eitem
        else
            self.detail_ui.itemlist[eitem.id] = eitem
        end
        
        --循环隐藏人物名称
        for i = 1,5,1 do        
            local item = eitem.obj.transform:Find(string.format("bg_list/Grid/hero%d/listitem_hero(Clone)/name text",i))
            if item ~= nil then
                item.gameObject:SetActive(false)
            end
        end
    end 
    self.detail_ui.Table:Reposition()
    self.detail_ui.ScrollView:SetDragAmount(0, 0, false)
end

function MobaMassTroops:CancelMass(pathId,callback)

    local req = self.GetInterface("CancelPathRequest")()
    req.tarpathid = pathId
    
    Global.Request(self.GetInterface("Category_pb_CancelMass"), self.GetInterface("CancelPathRequestTypeID"), req,self.GetInterface("CancelPathResponse"), function(msg) 
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            if callback ~= nil then
                callback()
            end
        end
    end, true)
end

function MobaMassTroops:OnJoinBtn()
    if not self.detail_ui.item.Enable_Click then
        return
    end
    if self.cur_select_index == 10 and self.detail_ui.join_state == self.join_state.join then --集结加入

        local x = self.detail_ui.item.msg.atkpos.x 
        local y = self.detail_ui.item.msg.atkpos.y 

        local mtc = MassTroopsCondition()
        mtc:MobaJoinMass4BattleCondition(function(success)
            if success then
                local offset_x,offset_y = MobaMain.MobaMinPos()
                x = x + offset_x
                y = y + offset_y
                mtc:MobaShowJionMassBattleMove(self.detail_ui.homeuid, x, y,self.detail_ui.numMax - self.detail_ui.item.msg.num,function() 
                    --self:OpenDetail(self.detail_ui.item)
                end,self.detail_ui.item.msg.defpos.x,self.detail_ui.item.msg.defpos.y)
            end               
        end)
    end
    if self.cur_select_index == 20 and self.detail_ui.join_state == self.join_state.join then --驻防加入
        local offset_x,offset_y = MobaMain.MobaMinPos()
        local x = self.detail_ui.item.msg.defpos.x+ offset_x
        local y = self.detail_ui.item.msg.defpos.y+ offset_y

        if self.detail_ui.item.msg.mobabuildingid ~= nil and self.detail_ui.item.msg.mobabuildingid > 0 then
            MobaEmbassy.CanMobaBaseEmbassy(self.detail_ui.item.msg.mobabuildingid,self.detail_ui.homeuid,x,y,function()
                if self.detail_ui.item ~= nil then
                    self:OpenDetail(self.detail_ui.item)
                end
            end)
        else
            MobaEmbassy.CanEmbassy(self.detail_ui.homeuid,x,y,self.detail_ui.item.charid,function()
                if self.detail_ui.item ~= nil then
                    self:OpenDetail(self.detail_ui.item)
                end
            end)      
        end
    end   
    if self.cur_select_index == 10 and self.detail_ui.join_state == self.join_state.cancel then --集结取消
        self:CancelMass(self.detail_ui.pathId,function()
            self:CloseDetail()
        end)
    end
    if self.cur_select_index == 20 and self.detail_ui.join_state == self.join_state.cancel then --驻防取消
        if self.detail_ui.item.charid == MainData.GetCharId() then --取消全部
            MobaEmbassy.CancelEmbassyAllItemEx(self.detail_ui.homeuid,self.detail_ui.count,function()
                if self.detail_ui.item ~= nil then
                    self:OpenDetail(self.detail_ui.item)
                end
            end)    
        else--取消自己
            if self.detail_ui.item.msg.mobabuildingid ~= nil and self.detail_ui.item.msg.mobabuildingid > 0 then
                MobaEmbassy.CancelEmbassyItemEx(nil,MainData.GetCharId(),self.msg,function()
                    if self.detail_ui.item ~= nil then
                        self:OpenDetail(self.detail_ui.item)
                    end
                end,self.detail_ui.item.msg.mobabuildingid,self.detail_ui.pathId)  
            else
                MobaEmbassy.CancelEmbassyItemEx(self.detail_ui.homeuid,MainData.GetCharId(),self.msg,function()
                    if self.detail_ui.item ~= nil then
                        self:OpenDetail(self.detail_ui.item)
                    end
                end)   
            end

  
        end
    end   
end

function MobaMassTroops:_UpdateDetailJoinBtn(item)
    local state = -1
    if self.cur_select_index == 10 then
        if item.charid == MainData.GetCharId() then --判断是否是发起者
            state = self.join_state.cancel
        else
            if item.ui.state_index == 1 then--正在等待集结时
                if item.msg.num < self.detail_ui.numMax then -- 判读是否满员
                    if self.detail_ui.itemlist[MainData.GetCharId()] ~= nil then 
                        state = self.join_state.joined
                    else
                        state = self.join_state.join
                    end  
                else
                    state = self.join_state.full
                end
            else
                state = self.join_state.close
            end
        end
    else
        if item.charid == MainData.GetCharId() then --判断是否是发起者
            state = self.join_state.cancel
        else
            if self.detail_ui.num < self.detail_ui.numMax then -- 判读是否满员
                if self.detail_ui.itemlist[MainData.GetCharId()] ~= nil then 
                    state = self.join_state.cancel
                else
                    state = self.join_state.join
                end  
            else
                if self.detail_ui.itemlist[MainData.GetCharId()] ~= nil then
                    state = self.join_state.cancel
                else
                    state = self.join_state.full
                end   
            end
        end        
    end   
    self.detail_ui.join_state = state
    self:_UpdateJoinBtn()
    return state
end

function MobaMassTroops:_UpdateJoinBtn()
    if self.detail_ui.item == nil then
        return 
    end
    self.detail_ui.join_text.text = Global.GTextMgr:GetText(self.join_state_textid[self.detail_ui.join_state])
    if self.detail_ui.join_state >=  self.join_state.full then
        self.detail_ui.join_sprite.normalSprite = "union_button1_un"
        self.detail_ui.join_collision.enabled = false
    else
        if self.cur_select_index == 20 then
            if self.detail_ui.item.charid ~= MainData.GetCharId() and self.detail_ui.join_state == self.join_state.cancel then 
                --print(self.detail_ui.item.charid,MainData.GetCharId(),self.detail_ui.join_state)
                self.detail_ui.join_text.text = Global.GTextMgr:GetText(self.join_state_textid[30+self.detail_ui.join_state])
            else
                -- print(self.detail_ui.item.charid,MainData.GetCharId(),self.detail_ui.join_state,self.cur_select_index+self.detail_ui.join_state)
                self.detail_ui.join_text.text = Global.GTextMgr:GetText(self.join_state_textid[self.cur_select_index+self.detail_ui.join_state])
            end
            self.detail_ui.join_sprite.normalSprite = "union_button1"
        else
            if self.detail_ui.item.charid == MainData.GetCharId() and self.detail_ui.join_state == self.join_state.cancel then 
                self.detail_ui.join_sprite.normalSprite = "union_button5"
            else
                self.detail_ui.join_sprite.normalSprite = "union_button1"
            end
        end
        self.detail_ui.join_collision.enabled = true
    end         
end

function MobaMassTroops:_OpenDetail(item,homeuid,msgitemlist,maxNum,pathId, msg)
    self.detail_ui.msg = msgitemlist
    self.detail_ui.homeuid = homeuid
    self.detail_ui.num = 0
    self.detail_ui.numMax = maxNum
    self.detail_ui.pathId =pathId
    self.detail_ui.source_item = item
    self.msg = msg
    self:CloseCurList()
    if self.cur_select_index >= 10 then
        self.cur_select_index = self.cur_select_index / 10
    end 
    self.per_select_index = self.cur_select_index
    self.cur_select_index = self.cur_select_index*10
    self.list_ui.root:SetActive(false)
    
    self.detail_ui.root:SetActive(true) 
    self.detail_ui.item = {}
    if self.msg ~= nil and item.index == 1 then
        item.msg.starttime = self.msg.starttime
        item.msg.waittime = self.msg.waittime
        item.msg.pathstarttime = self.msg.pathstarttime
        item.msg.pathtime = self.msg.pathtime
    end
    self:SetItem(self.detail_ui.item,self.detail_ui.item_trf,item.index,item.msg,true)
    if self.detail_ui.item.ui.share ~= nil then
        self.detail_ui.item.ui.share:SetActive(false)
    end    
    self:_FillEmbassyItem(item,homeuid,msgitemlist)
    self:_RefrushEmbassyNum()
    --self.detail_ui.root:SetActive(true)
    if self.detail_ui.item ~= nil then
        self:_UpdateDetailJoinBtn(item)
    end
end

function MobaMassTroops:UpdateDetail(charId)
    if self.list_items[charId] == nil then
        return 
    end

    if not self.detail_ui.root.activeSelf then
        return
    end

    if self.detail_ui.item ~= nil and self.detail_ui.item.charid ~= charId then
        return
    end
    --self:CloseDetailItem()
    local item = self.list_items[charId]
    self:RequestInfo(item.charid,function(msg)    
        if msg == nil then    
            self:UpdateItem(item,item.msg,true)                     
        else
            if self.cur_select_index >= 10 and self.detail_ui.source_item ~= nil then                                
                self.detail_ui.source_item.msg = msg.gather[1]                            
            end             

            item.msg = msg.gather[1]                          
            self:OpenDetail(item)                        
        end                    
    end)
end

function MobaMassTroops:OpenDetail(item)
    if self.cur_select_index >= 10 then
        self.cur_select_index = self.per_select_index
    end    
     --print(self.cur_select_index)
    if self.cur_select_index == 1 then

            self:RequestInfoDetail(item.charid,function(msg) 
                if msg == nil then
                    return
                else
                    MobaEmbassy.FillUserBaseInfo(msg.user)
                    --print(item,item.msg.atkHomeuid,msg.gather.gather,item.msg.numMax,msg.gather.gather[1].pathid)
                    if msg.gather.gather == nil or #msg.gather.gather == 0 then
                        return
                    end
                    Global.DumpMessage(msg)
                    self:_OpenDetail(item,item.msg.atkHomeuid,msg.gather.gather,item.msg.numMax,msg.gather.gather[1].pathid, msg) 
                end
            end) 
    else
        if item.msg.mobabuildingid ~= nil and item.msg.mobabuildingid > 0 then
            MobaMainData.ReqGarrisonInfo(item.msg.mobabuildingid,function()
                local msg = MobaMainData.GetGarrisonInfo(item.msg.mobabuildingid)
                local users = {}
                local garrisondata = nil 
                local garrison_list = {}
                for i=1,#msg.garrisonInfos do
                    users[i] = msg.garrisonInfos[i].baseInfo
                    garrison_list[i]= msg.garrisonInfos[i].garrisonData
                    if msg.garrisonInfos[i].garrisonData.charid == MainData.GetCharId() then
                        garrisondata = msg.garrisonInfos[i].garrisonData
                    end 
                end
                local build_msg = MobaZoneBuildingData.GetData(item.msg.mobabuildingid)
                self.roleid = msg.roleid
                local tnum = msg.garrisonCapacity
                if tnum <= 0 then
                    tnum = 9999999999
                end
                local pathid = 0
                
                if garrisondata ~= nil then
                    pathid = garrisondata.pathid
                end
                self:_OpenDetail(item,build_msg.data.uid,garrison_list,tnum,pathid,garrisondata) 
            end)
        else
            MobaEmbassy.RequestEmbassyData(item.charid,function(msg)
                MobaEmbassy.FillUserBaseInfo(msg.user)
                local garrisondata = nil 
                for i=1,#msg.garrison.garrison do
                    if msg.garrison.garrison[i].charid ==MainData.GetCharId() then
                        garrisondata = msg.garrison.garrison[i]
                    end
                end   
                self:_OpenDetail(item,msg.homeUid,msg.garrison.garrison,msg.garrisonCapacity,msg.garrison.garrison.pathid,garrisondata) 
            end)
        end

    end
end

function MobaMassTroops:CloseDetailItem()
    if self.detail_ui.item ~= nil then
        self.detail_ui.item.isdestroy = true
        if self.detail_ui.item.ui.countdownid ~= nil then
            CountDown.Instance:Remove(self.detail_ui.item.ui.countdownid)
            --print("CloseDetailItem CountDown.Instance:Remove",self.detail_ui.item.ui.countdownid)
            self.detail_ui.item.ui.countdownid = nil
        end
    end
    self.detail_ui.source_item  =nil
    self.detail_ui.item = nil
    self.roleid = nil
end

function MobaMassTroops:CloseDetail()
    self.detail_ui.root:SetActive(false)
    self.list_ui.root:SetActive(true)
    self:ClearEmbassyItem()
    self:CloseDetailItem()
    print( self.cur_select_index)
    self.cur_select_index = self.per_select_index
    self:OpenList(self.cur_select_index)
end

function MobaMassTroops:Open(index)
    self.inited = true
    if index ~= nil and (index>=1 and index <=3) then
        self.list_ui[1].page:Set(false)
        self.list_ui[2].page:Set(false)
        self.list_ui[3].page:Set(false)
        self.list_ui[index].page:Set(true)
        if index == 3 then
            self:OpenBuildList()
        else
            self:OpenList(index)
        end       
        return
    end
    if Global.GetMobaMode() ==2 then
        if GuildWarMain.MassTotlaNum[1] == 0 and GuildWarMain.MassTotlaNum[2] ~= 0 then
            self.list_ui[1].page:Set(false)
            self.list_ui[2].page:Set(true)
            self:OpenList(2)
        else
            self.list_ui[1].page:Set(true)
            self.list_ui[2].page:Set(false)        
            self:OpenList(1)
        end        
    else
        if MobaMain.MassTotlaNum[1] == 0 and MobaMain.MassTotlaNum[2] ~= 0 then
            self.list_ui[1].page:Set(false)
            self.list_ui[2].page:Set(true)
            self:OpenList(2)
        else
            self.list_ui[1].page:Set(true)
            self.list_ui[2].page:Set(false)        
            self:OpenList(1)
        end
    end

end

function MobaMassTroops:Close() 
    self.inited = false
    MainCityUI.UpdateNotice()
    self:ClearEmbassyItem()
    self:CloseDetailItem()
    self:Clearlist()
end

function MobaMassTroops:RequestBuildInfo(callback,isopened)
    if callback == nil then
        return
    end
    local req = self.GetInterface("GetBuildSituationRequest")()
    Global.Request(self.GetInterface("Category_pb_RequestBuildInfo"),self.GetInterface("GetBuildSituationRequestTypeID"),req,self.GetInterface("GetBuildSituationResponse"),function(msg)     
        Global.DumpMessage(msg)
        local check = true
        if isopened then
            check = self.inited
        end
         if msg.code == 0 then
            if callback ~= nil  and check then --
                callback(msg)
            end
        else
            if callback ~= nil  and check then --
                callback(nil)
            end
            Global.FloatError(msg.code, Color.white)
        end
    end, true) 
end

function MobaMassTroops:SetBuildItemBuff(item,buff_str)
    item.ui.buff_root.gameObject:SetActive(true)
    item.ui.buff_1.gameObject:SetActive(false)
    item.ui.buff_2.gameObject:SetActive(false)
    item.ui.buff_3.gameObject:SetActive(false)
    local index = 1
    for v in string.gsplit(buff_str, ";") do    
        local itemTBData = Global.GTableMgr:GetSlgBuffData(tonumber(v)) 
        if itemTBData ~= nil then
            if index == 1 then
                item.ui.buff_1.gameObject:SetActive(true)
                item.ui.buff_1.mainTexture = Global.GResourceLibrary:GetIcon("Item/", itemTBData.icon)
            elseif index == 2 then
                item.ui.buff_2.gameObject:SetActive(true)
                item.ui.buff_2.mainTexture = Global.GResourceLibrary:GetIcon("Item/", itemTBData.icon)
            elseif index == 3 then
                item.ui.buff_3.gameObject:SetActive(true)
                item.ui.buff_3.mainTexture = Global.GResourceLibrary:GetIcon("Item/", itemTBData.icon)    
            else
                return 
            end
            index = index +1
        else
            print("itemTBData is nil=>",buff_str,v);
        end

    end
end

function MobaMassTroops:SetBuildItemDefence(item,cityguard,maxcityguard,cityguardspeed)
    item.ui.defense_root.gameObject:SetActive(true)
    item.ui.defense_state.gameObject:SetActive(true)
    item.ui.defense_progress.width = math.floor(145*(cityguard/maxcityguard))
    local full = false
    if cityguard == maxcityguard then
        full = true
    end
    if cityguardspeed == 0 or full then
        item.ui.defense_state.gameObject:SetActive(false)
    elseif cityguardspeed > 0 then
        item.ui.defense_state.spriteName = "icon_add"
        item.ui.defense_up.gameObject:SetActive(true)
        item.ui.defense_down.gameObject:SetActive(false)        
    else
        item.ui.defense_state.spriteName = "icon_addun"
        item.ui.defense_up.gameObject:SetActive(false)
        item.ui.defense_down.gameObject:SetActive(true)        
    end
	
	if cityguard == maxcityguard then 
		item.ui.defense_up.gameObject:SetActive(false)
        item.ui.defense_down.gameObject:SetActive(false)   
	end 
    
end

function MobaMassTroops:UpdateBuildItem(item,MobaBuildSituation,force_update)
    if not self.inited then
        return
    end
    
    item.msg = MobaBuildSituation
    local teamid = MobaMainData.GetTeamID()
    local build_data = Global.GTableMgr:GetMobaMapBuildingDataByID(item.msg.buildingid)
    item.ui.build_icon.mainTexture = Global.GResourceLibrary:GetIcon("Icon/WorldMap/", build_data.Icon)
    item.ui.build_name.text = Global.GTextMgr:GetText(build_data.Name)
    if item.msg.rulingTeam == 0 then
        item.ui.build_name.color = NGUIMath.HexToColor(0xFFE167FF)
        item.ui.type_sprite.spriteName = "MobaUnionWar_3"
    elseif teamid ~= item.msg.rulingTeam then
        item.ui.build_name.color = NGUIMath.HexToColor(0xFF0000FF)
        item.ui.type_sprite.spriteName = "MobaUnionWar_1"
    else
        item.ui.build_name.color = NGUIMath.HexToColor(0x00FF56FF)
        item.ui.type_sprite.spriteName = "MobaUnionWar_2"
    end
    item.ui.label_1.gameObject:SetActive(false)
    item.ui.label_2.gameObject:SetActive(false)
    item.ui.label_3.gameObject:SetActive(false)
    item.ui.label_4.gameObject:SetActive(false)
    item.ui.label_1_up.gameObject:SetActive(false)
    item.ui.label_2_up.gameObject:SetActive(false)
    item.ui.label_3_up.gameObject:SetActive(false)
    item.ui.label_4_up.gameObject:SetActive(false)    
    item.ui.build_state.gameObject:SetActive(false)
    item.ui.build_bg.gameObject:SetActive(false)
    item.ui.buff_root.gameObject:SetActive(false)
    item.ui.defense_root.gameObject:SetActive(false)
    item.ui.tips.gameObject:SetActive(false)
    item.ui.warning.gameObject:SetActive(false);

    if item.msg.broken then
        item.ui.build_icon.mainTexture = Global.GResourceLibrary:GetIcon("Icon/WorldMap/", "MobaUnionWar_walldie")
        item.ui.is_destroy.gameObject:SetActive(true)
        item.ui.build_name.color = NGUIMath.HexToColor(0xCCCCCCFF)
        return
    end



    if self.moba_main_build_ids[item.msg.buildingid] then
        item.ui.label_1.gameObject:SetActive(true)
        if teamid ~= item.msg.rulingTeam then
            item.ui.label_1.text = System.String.Format(Global.GTextMgr:GetText("ui_moba_58"),  ("?????".."/".."?????"))
        else
            item.ui.label_1.text = System.String.Format(Global.GTextMgr:GetText("ui_moba_58"), item.msg.garrisonCapacity > 0 and (item.msg.garrisonNum.."/"..item.msg.garrisonCapacity) or "0")
        end
        self:SetBuildItemDefence(item,item.msg.cityguard,item.msg.maxcityguard,item.msg.cityguardspeed)

        if item.msg.rulingTeam ~= item.msg.ownerTeam then
            item.ui.build_state.gameObject:SetActive(true)
            item.ui.build_bg.gameObject:SetActive(true)
            if item.msg.rulingTeam == teamid then
                item.ui.build_state.text = Global.GTextMgr:GetText("ui_moba_64")
            else
                item.ui.build_state.text = Global.GTextMgr:GetText("ui_moba_63")
            end            
        end

        item.ui.tips.gameObject:SetActive(true)
        if teamid ~= item.msg.ownerTeam then
            
            if self.moba_center_build_ids[item.msg.buildingid] then
                item.ui.tips.text = Global.GTextMgr:GetText("ui_moba_67")
            else
                if item.msg.rulingTeam ~= teamid then
                    item.ui.tips.text = Global.GTextMgr:GetText("ui_moba_60")
                else
                    item.ui.tips.gameObject:SetActive(false)
                end
            end
            if item.msg.rulingTeam == teamid then
                item.ui.label_2.gameObject:SetActive(true)
                item.ui.label_2_up.gameObject:SetActive(true)
                item.ui.label_2.text = System.String.Format(Global.GTextMgr:GetText("ui_moba_59"), item.msg.scoreInc)
            else
                item.ui.label_2.gameObject:SetActive(true)
                item.ui.label_2.text = System.String.Format(Global.GTextMgr:GetText("ui_moba_138"), item.msg.fistScore)
                item.ui.label_4.gameObject:SetActive(true)
                item.ui.label_4.text = System.String.Format(Global.GTextMgr:GetText("ui_moba_59"), item.msg.scoreInc)
            end
        else
            if self.moba_center_build_ids[item.msg.buildingid] then
                item.ui.tips.text = Global.GTextMgr:GetText("ui_moba_66")
            else
                if item.msg.rulingTeam ~= teamid then
                    item.ui.tips.text = Global.GTextMgr:GetText("ui_moba_61")
                else
                    item.ui.tips.gameObject:SetActive(false)
                end
            end
        end

        if teamid == item.msg.ownerTeam then
            item.ui.warning.gameObject:SetActive(item.msg.fighting or item.msg.rulingTeam ~= item.msg.ownerTeam);
        end

    else
        if teamid == item.msg.rulingTeam then
            item.ui.warning.gameObject:SetActive(item.msg.fighting);
        end 

        item.ui.build_state.gameObject:SetActive(true)
        item.ui.build_bg.gameObject:SetActive(true)
        if item.msg.rulingTeam == 0 then
            item.ui.build_state.text = Global.GTextMgr:GetText("ui_moba_65")
            item.ui.label_1.gameObject:SetActive(true)
            item.ui.label_1.text = System.String.Format(Global.GTextMgr:GetText("wall_army_num"), item.msg.garrisonNum)
            item.ui.label_2.gameObject:SetActive(true)
            item.ui.label_2.text = System.String.Format(Global.GTextMgr:GetText("ui_moba_138"), item.msg.fistScore)
            item.ui.label_3.gameObject:SetActive(true)
            item.ui.label_3.text = System.String.Format(Global.GTextMgr:GetText("ui_moba_59"), item.msg.scoreInc)
            self:SetBuildItemBuff(item,item.msg.buff)        
        elseif item.msg.rulingTeam == teamid then
            item.ui.build_state.text = Global.GTextMgr:GetText("ui_moba_64")
            item.ui.label_1.gameObject:SetActive(true)
            item.ui.label_1.text = System.String.Format(Global.GTextMgr:GetText("ui_moba_58"),item.msg.garrisonCapacity > 0 and(item.msg.garrisonNum.."/"..item.msg.garrisonCapacity)or"0")  
            item.ui.label_2.gameObject:SetActive(true)
            item.ui.label_2_up.gameObject:SetActive(true)
            item.ui.label_2.text = System.String.Format(Global.GTextMgr:GetText("ui_moba_59"), item.msg.scoreInc)                      
            self:SetBuildItemBuff(item,item.msg.buff) 
        else
            item.ui.build_state.text = Global.GTextMgr:GetText("ui_moba_63")
            item.ui.label_1.gameObject:SetActive(true)
            item.ui.label_1.text = System.String.Format(Global.GTextMgr:GetText("ui_moba_134"), "??")  
            item.ui.label_2.gameObject:SetActive(true)
            item.ui.label_2.text = System.String.Format(Global.GTextMgr:GetText("ui_moba_59"), item.msg.scoreInc)              
            self:SetBuildItemBuff(item,item.msg.buff) 
        end 
    end
end

function MobaMassTroops:SetBuildItem(item,trf,MobaBuildSituation,force_update)
    item.index = self.build_info_index
    item.obj = trf.gameObject
    item.buildingid = MobaBuildSituation.buildingid
    item.trf = trf
    item.ui = {}

    item.ui.type_sprite = item.trf:Find("base/type_icon"):GetComponent("UISprite")
    item.ui.build_icon = item.trf:Find("build_icon"):GetComponent("UITexture")
    item.ui.build_state = item.trf:Find("build_icon/text1"):GetComponent("UILabel")
    item.ui.build_bg = item.trf:Find("build_icon/Sprite")

    item.ui.build_name = item.trf:Find("name"):GetComponent("UILabel")
    item.ui.tips = item.trf:Find("tishi"):GetComponent("UILabel")

    item.ui.warning= item.trf:Find("warn")

    item.ui.defense_root = item.trf:Find("jindu_3")
    item.ui.defense_progress = item.trf:Find("jindu_3/kuang/yellow"):GetComponent("UISprite")
    item.ui.defense_state = item.trf:Find("jindu_3/jiantou"):GetComponent("UISprite")
    item.ui.defense_up = item.trf:Find("jindu_3/jiantou/lvse")
    item.ui.defense_down = item.trf:Find("jindu_3/jiantou/hongse")

    item.ui.is_destroy = item.trf:Find("Label_5")

    item.ui.buff_root = item.trf:Find("get_buff")
    item.ui.buff_1 = item.trf:Find("get_buff/1"):GetComponent("UITexture")
    item.ui.buff_2 = item.trf:Find("get_buff/2"):GetComponent("UITexture")
    item.ui.buff_3 = item.trf:Find("get_buff/3"):GetComponent("UITexture")

    item.ui.label_1 = item.trf:Find("Label_1"):GetComponent("UILabel")
    item.ui.label_2 = item.trf:Find("Label_2"):GetComponent("UILabel")
    item.ui.label_3 = item.trf:Find("Label_3"):GetComponent("UILabel")
    item.ui.label_4 = item.trf:Find("Label_4"):GetComponent("UILabel")
    item.ui.label_1_up = item.trf:Find("Label_1/up")
    item.ui.label_2_up = item.trf:Find("Label_2/up")
    item.ui.label_3_up = item.trf:Find("Label_3/up")
    item.ui.label_4_up = item.trf:Find("Label_4/up")


    item.isdestroy = false

    self:UpdateBuildItem(item,MobaBuildSituation,force_update)

    UIUtil.SetClickCallback(item.ui.build_icon.gameObject,function()
        MobaUnionWar.CloseAll()
        MainCityUI.ShowWorldMap(item.msg.pos.x,item.msg.pos.y,true,nil)
    end)
end

function MobaMassTroops:AddBuildItem(MobaBuildSituation)
    local index = self.build_info_index
    local item = {}
    local obj = NGUITools.AddChild(self.list_ui[index].grid.gameObject,self.build_info_prefab)
    obj.name = MobaBuildSituation.buildingid
    obj:SetActive(true)
    self:SetBuildItem(item,obj.transform,MobaBuildSituation,false)
    if item ~= nil and item.obj ~= nil  then
        self.list_ui[item.index].list[item.buildingid] = item
        self.list_ui[item.index].count = self.list_ui[item.index].count + 1 
        self.list_items[item.buildingid] = item
    end
    return item
end

--local mt = MobaMassTroops()
--mt:RequestBuildInfo(function(msg)
--    local state =  mt:GetCenterWarningState(msg,true)
--end)

function MobaMassTroops:GetCenterWarningState(msg,is_center)
	if msg == nil then
		return false
	end
    local count = #msg.situation
    local teamid = MobaMainData.GetTeamID()
    local state = false
    for i= 1,count,1 do
        local l_msg = msg.situation[i]
        if teamid == l_msg.ownerTeam then
            if self.moba_main_build_ids[l_msg.buildingid] and (not l_msg.broken) then
                if self.moba_center_build_ids[l_msg.buildingid] then
                    --大本营
                    if is_center then
                        state = teamid ~= l_msg.rulingTeam or l_msg.fighting
                    end
                else
                    -- 城门
                    if not is_center then
                        state = teamid ~= l_msg.rulingTeam or l_msg.fighting
                    end
                end
            end
            if state then
                return state
            end
        end
    end
    return state
end

function MobaMassTroops:OpenBuildList()
    
    if self.cur_select_index ~= self.build_info_index  then
        self:CloseCurList()
        self.cur_select_index = self.build_info_index
    end
    self.list_ui.root:SetActive(true)
    self.list_ui[self.cur_select_index].notice.gameObject:SetActive(false)
    self.list_ui[self.cur_select_index].root:SetActive(true)
	
    if self.list_ui[self.cur_select_index].msg == nil then
        self:RequestBuildInfo(function(msg) 
            self.list_ui[self.cur_select_index].msg = msg
            local count = #msg.situation
            if count == 0 then
                self.list_ui[self.cur_select_index].no_one:SetActive(true)
            else
                for i= 1,count,1 do
                    self:AddBuildItem(msg.situation[i])
                end         
                if self.list_ui[self.cur_select_index].count == 0 then
                    self.list_ui[self.cur_select_index].no_one:SetActive(true)
                else
                    self.list_ui[self.cur_select_index].no_one:SetActive(false)
                    self.list_ui[self.cur_select_index].grid:Reposition()
                    self.list_ui[self.cur_select_index].scroll_view:SetDragAmount(0, 0, false) 
                end 
            end
        end,true)
    else
        if self.list_ui[self.cur_select_index].count == 0 then
            self.list_ui[self.cur_select_index].no_one:SetActive(true)
        else
            self.list_ui[self.cur_select_index].no_one:SetActive(false)
            self.list_ui[self.cur_select_index].grid:Reposition()
            self.list_ui[self.cur_select_index].scroll_view:SetDragAmount(0, 0, false)
        end     
    end
end



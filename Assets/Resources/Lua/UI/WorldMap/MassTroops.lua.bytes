class "MassTroops"
{
}

function MassTroops:__init__(RootTrf)
    if RootTrf == nil then
        return
    end
    self.transform = RootTrf
    self.assembled_prefab = RootTrf:Find("assembled").gameObject

    self.list_ui = {}
    self.list_ui.root = RootTrf:Find("bg2").gameObject
    self.list_ui.root:SetActive(false)
    for i = 1,2,1 do
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
        self.list_ui[i].notice.gameObject:SetActive(MainCityUI.MassTotlaNum[i] ~= MainCityUI.GetPreMassTotalNum()[i])
        self.list_ui[i].no_one:SetActive(false)
        UIUtil.SetClickCallback(self.list_ui[i].page.gameObject,function()
            MainCityUI.PreMassTotalNum[1] = MainCityUI.MassTotlaNum[1]
            MainCityUI.PreMassTotalNum[2] = MainCityUI.MassTotlaNum[2]
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

    self.show_cabcel_msg_box = false;
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
        [22] = "union_assembled_14",
        [31] = "Embassy_ui3",
    }
    self.inited = false
end

function MassTroops:RequsetMassTotalNum(callback)
    if callback == nil then
        return
    end
    local count1 = 0
    local count2 = 0
    self:RequestInfoEx(0,1,function(msg1)
        if msg1 ~= nil then
            count1 = #msg1.gather 
            print("1111111111111111111",count1)
            self:RequestInfoEx(0,2,function(msg2)
                if msg2 ~= nil then
                    count2 = #msg2.gather 
                    print("222222222222222222",count2)
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

function MassTroops:RequestInfoEx(charid,index,callback)
    if callback == nil then
        return
    end
    local req = HeroMsg_pb.MsgGetGuildGatheInfoRequest()
    req.infoType = index
    req.charid = charid
    Global.Request(Category_pb.Hero,HeroMsg_pb.HeroTypeId.MsgGetGuildGatheInfoRequest,req,HeroMsg_pb.MsgGetGuildGatheInfoResponse,function(msg)
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

function MassTroops:RequestInfo(charid,callback)
    if callback == nil then
        return
    end
    self:RequestInfoEx(charid,self.cur_select_index,function(msg1)
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

function MassTroops:RequestInfoDetail(charid,callback)
    if callback == nil then
        return
    end
    local req = HeroMsg_pb.MsgGetGatheInfoRequest()
    req.charid = charid
    Global.Request(Category_pb.Hero,HeroMsg_pb.HeroTypeId.MsgGetGatheInfoRequest,req,HeroMsg_pb.MsgGetGatheInfoResponse,function(msg)
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

function MassTroops:UpdateTimeMsg(msg)
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

function MassTroops:UpdateTime(item)
    return self:UpdateTimeMsg(item.msg)
end

--更新一个Item  当item自己的时间完成时 去请求 并判断出最新的状态和相应的时间 以及容量数量 参与人数
function MassTroops:UpdateItem(item,HeroMsg_GatheSummaryInfo,force_update)
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
    else
	    item.ui.player2_face.mainTexture = Global.GResourceLibrary:GetIcon("Icon/head/",enemy.face)
	    item.ui.player2_name.text = enemy.guildBanner == "" and enemy.name or "["..enemy.guildBanner.."]"..enemy.name
    end

    item.ui.forcenum1.text = item.msg.num
    local addnum = item.msg.addNum 
    if  addnum == 0 then 
        item.ui.forcenum2.text = "/"..item.msg.numMax
    else
        item.ui.forcenum2.text = "/"..(item.msg.numMax - addnum).."[20F545FF] +"..addnum.."[-]"
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
    print("time run ",self.cur_select_index == item.index,force_update)
    if self.cur_select_index == item.index or force_update then
        local ex = force_update and "MassTroops" or "MassTroopsForce"
        item.ui.countdownid = ex..item.charid
       -- print("  CountDown.Instance:Add",item.ui.countdownid)
	        CountDown.Instance:Add(item.ui.countdownid,endtime,CountDown.CountDownCallBack(function(t)
	            if item.isdestroy then
	              --  print(item.isdestroy,"DDDDDDDDDDDDDDDDDDDDDestroy")
	                return
                end
		    item.ui.arrivedtime.text  = t
		    item.ui.arrivedBar.value = math.min(1,(Serclimax.GameTime.GetSecTime() - startime)/(endtime - startime))
	    	if endtime+1 - Serclimax.GameTime.GetSecTime() <= 0 then				
			    CountDown.Instance:Remove(item.ui.countdownid)
			   -- print(" CountDown.Instance:Remove",item.ui.countdownid)
			    item.ui.countdownid = nil
			    if state <= 3 then
                    self:RequestInfo(item.req_char_id,function(msg)
                        if msg == nil then
     
                            self:UpdateItem(item,item.msg,force_update)
                        else
                            if self.cur_select_index >= 10 and self.detail_ui.source_item ~= nil then
                                self.detail_ui.source_item.msg = msg.gather[1]
                            end                            
                            self:UpdateItem(item,msg.gather[1],force_update)
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
		    end			
	    end)) 
    end
end



function MassTroops:RemoveItem(item)
    if item == nil then
        return 
    end
    if item.ui.countdownid ~= nil then
        CountDown.Instance:Remove(item.ui.countdownid)
        -- print(" CountDown.Instance:Remove",item.ui.countdownid)
        item.ui.countdownid = nil
    end
    item.isdestroy = true
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


function MassTroops:RemoveItem4Push(guild,charid)
    local index = guild == UnionInfoData.GetData().guildInfo.guildId and 1 or 2
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

function MassTroops:SetItem(item,trf,index,HeroMsg_GatheSummaryInfo,force_update)
    item.index = index
    item.obj = trf.gameObject
    if index == 1 then
        item.charid = HeroMsg_GatheSummaryInfo.atk.charid
    else
        item.charid = HeroMsg_GatheSummaryInfo.def.charid
    end

    item.req_char_id = HeroMsg_GatheSummaryInfo.atk.charid
    item.trf = trf
    item.ui = {}
    item.ui.player1_face = item.trf:Find("head_bg01/icon"):GetComponent("UITexture")
    item.ui.player1_name = item.trf:Find("head_bg01/name_01"):GetComponent("UILabel")
    item.ui.player1_pos = item.trf:Find("head_bg01/btn_coord").gameObject
    item.ui.player1_lv = item.trf:Find("head_bg01/level/Label"):GetComponent("UILabel")
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
                    local playerunionname = HeroMsg_GatheSummaryInfo.atk.guildBanner
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
						print(HeroMsg_GatheSummaryInfo.eliteMonsterId)
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
                    else
                        deficon = HeroMsg_GatheSummaryInfo.def.face
                        defunionname = HeroMsg_GatheSummaryInfo.def.guildBanner == "" and "" or "["..HeroMsg_GatheSummaryInfo.def.guildBanner.."]"
                        defname = HeroMsg_GatheSummaryInfo.def.name
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
                    send.curChanel = ChatMsg_pb.chanel_guild
                    send.content = Global.GTextMgr:GetText("ui_rally_msg")   
                    send.spectext = deficon..","..defunionname..","..defname..","..endtime..","..startime..","..HeroMsg_GatheSummaryInfo.defpos.x..","..HeroMsg_GatheSummaryInfo.defpos.y..","..HeroMsg_GatheSummaryInfo.atk.charid..","..playerunionname..","..playername
                    send.languageCode = Global.GTextMgr:GetCurrentLanguageID()
                    send.type = ChatMsg_pb.ChatInfoConditionType_GuildGather
                    send.chatType = 6
                    send.tarUid = HeroMsg_GatheSummaryInfo.defHomeuid
                    send.senderguildname = hasUnion and UnionInfoData.GetData().guildInfo.banner or ""
                    Chat.SendConditionContent(send, function()
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
        UnionInfo.CloseAll()
        if item.index == 1 then
            MainCityUI.ShowWorldMap(item.msg.atkpos.x,item.msg.atkpos.y,true,nil)
        else
            MainCityUI.ShowWorldMap(item.msg.defpos.x,item.msg.defpos.y,true,nil)   
        end
    end)

    UIUtil.SetClickCallback(item.ui.player2_pos,function()
        if self.cur_select_index /10 >= 1 then
            self:CloseDetail()
        end        
        UnionInfo.CloseAll()
        if item.index == 1 then
            MainCityUI.ShowWorldMap(item.msg.defpos.x,item.msg.defpos.y,true,nil)  
        else
            MainCityUI.ShowWorldMap(item.msg.atkpos.x,item.msg.atkpos.y,true,nil)
        end        
    end)

    
end

function MassTroops:AddItem(index,HeroMsg_GatheSummaryInfo)
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
       
    if item ~= nil and item.obj ~= nil  then
        UIUtil.SetClickCallback(item.obj,function()
            self:OpenDetail(item)
        end)
        self.list_ui[item.index].list[item.charid] = item
        self.list_ui[item.index].count = self.list_ui[item.index].count + 1 
        self.list_items[item.charid] = item

        if self.join ~= nil then
            if self.join.charid == item.charid then
                MassTroops.join = nil 
                self:OpenDetail(item)                
            end
        end
    end
    --if item == nil then
    --    print("################ add item nil",index)
    --end
    
    return item
end

function MassTroops:AddItem4Push(guild,HeroMsg_GatheSummaryInfo)
    local index = guild == UnionInfoData.GetData().guildInfo.guildId and 1 or 2
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

function MassTroops:StopListCountDown(index)
   -- print("StopListCountDown",index)
    if self.list_ui[index] == nil then
        return
    end
    table.foreach(self.list_ui[index].list,function(_,v)
        if v ~= nil then
            if v.ui.countdownid ~= nil then
                CountDown.Instance:Remove(v.ui.countdownid)
               -- print(" CountDown.Instance:Remove",v.ui.countdownid) 
            end
            v.ui.countdownid = nil
        end
    end)
end

function MassTroops:StartListCountDown(index)
    table.foreach(self.list_ui[index].list,function(_,v)
        if v ~= nil then
            if v.ui.countdownid == nil then
                self:UpdateItem(v,v.msg)
            end
        end
    end)  
end

function MassTroops:Clearlist()
    for i = 1,2,1 do
        table.foreach(self.list_ui[i].list,function(_,v)
            if v ~= nil then
                if v.ui.countdownid ~= nil then
                    CountDown.Instance:Remove(v.ui.countdownid)
                    -- print(" CountDown.Instance:Remove",v.ui.countdownid)
                end
                v.ui.countdownid = nil
                v.isdestroy = true
                v.obj:SetActive(false)
                UnityEngine.GameObject.Destroy(v.obj)                
            end
        end)  
    end
end

function MassTroops:OpenList(index) 
    MainCityUI.GetPreMassTotalNum()[index] = MainCityUI.MassTotlaNum[index]

    if self.cur_select_index ~= index then
        self:CloseCurList()
        self.cur_select_index = index
    end
    self.list_ui.root:SetActive(true)
    self.list_ui[self.cur_select_index].notice.gameObject:SetActive(false)
    self.list_ui[self.cur_select_index].root:SetActive(true)
    if self.list_ui[self.cur_select_index].msg == nil then
        self:RequestInfo(0,function(msg) 
            self.list_ui[self.cur_select_index].msg = msg
            local count = #msg.gather
            
            if count == 0 then
                self.list_ui[self.cur_select_index].no_one:SetActive(true)
                if self.join ~= nil then
                    MassTroops.join = nil
                    FloatText.Show(Global.GTextMgr:GetText("ui_rally_cancelled"))
                end
            else
                --self.list_ui[self.cur_select_index].no_one:SetActive(false)
                local rallycancel = true
                for i= 1,count,1 do
                    if self.join ~= nil then
                        if self.join.charid == msg.gather[i].atk.charid then 
                            rallycancel = false
                        end
                    end
                    self:AddItem(self.cur_select_index,msg.gather[i])
                end

                if self.join ~= nil then
                    MassTroops.join = nil
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


function MassTroops:CloseCurList()
    if self.cur_select_index >= 1  and self.list_ui[self.cur_select_index] ~= nil then
        self:StopListCountDown(self.cur_select_index)   
        self.list_ui[self.cur_select_index].root:SetActive(false)
    end
end

function MassTroops:ClearEmbassyItem()
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

function MassTroops:_RefrushEmbassyNum()
    self.detail_ui.num = 0;
    table.foreach(self.detail_ui.itemlist,function(_,v) 
        if v ~= nil then
            self.detail_ui.num = self.detail_ui.num + v.num
        end
    end)
end

function MassTroops:_RemoveEmbassyItem(eitem)
    self.detail_ui.itemlist[eitem.id] = nil
    self.detail_ui.count = self.detail_ui.count -1 
    eitem.obj:SetActive(false)
    UnityEngine.GameObject.Destroy(eitem.obj)
    eitem = nil
    self.detail_ui.Table:Reposition()
    self:_RefrushEmbassyNum()  
end

function MassTroops:_FillEmbassyItem(item,homeuid,msgitemlist)
    self:ClearEmbassyItem()

    Embassy.SetExtra(homeuid,self.cur_select_index == 20 and item.charid == MainData.GetCharId())
    self.detail_ui.count = 0
    self.detail_ui.itemlist = {}
    for i = 1,#msgitemlist,1 do
        local eitem = Embassy.AddEmbassyItem(msgitemlist[i],self.detail_ui.itemPrefab,self.detail_ui.ArmyPrefab,self.detail_ui.Table.gameObject,true)

        --eitem.ui.disband.gameObject:SetActive(item.ui.state_index ~= self.join_state.full and item.charid == MainData.GetCharId() and eitem.ui.userMsg.charid ~= MainData.GetCharId())

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

        UIUtil.SetClickCallback(eitem.ui.disband.gameObject, function()
            self.show_cabcel_msg_box = true;
            MessageBox.Show(System.String.Format(Global.GTextMgr:GetText(Text.union_disband_hint), eitem.ui.userMsg.name), function()
                self.show_cabcel_msg_box = false;
                local charId = eitem.ui.userMsg.charid
                if item.index == 2 then

                    Embassy.CancelEmbassyItemEx(self.detail_ui.homeuid,charId,function()
                        CountDown.Instance:Remove("AddEmbassyItem"..charId)
                        self:_RemoveEmbassyItem(eitem)                        
                        self:RequestInfo(item.req_char_id,function(msg)
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
                    return
                end

                local req = MapMsg_pb.CancelGatherPathRequest()
                local msg = self.detail_ui.msg
                for _, v in ipairs(self.detail_ui.msg) do
                    if v.charid == charId then
                        req.tarpathid = v.pathid
                    end
                end
                req.cancelUserId = charId
                Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.CancelGatherPathRequest, req, MapMsg_pb.CancelGatherPathResponse, function(msg)
                    if msg.code == 0 then
                        
                        CountDown.Instance:Remove("AddEmbassyItem"..charId)
                        self:_RemoveEmbassyItem(eitem)                        
                        self:RequestInfo(item.req_char_id,function(msg)
                        if msg == nil then
                            self:UpdateItem(item,item.msg,true)
                             self:UpdateItem(self.detail_ui.item,item.msg,true)
                        else
                            Global.DumpMessage(msg)
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
            end,
            function()
                self.show_cabcel_msg_box = false;
            end)
        end)
        eitem.cancel_cb = function() 
            self:_RemoveEmbassyItem(eitem)
        end
        self.detail_ui.count = self.detail_ui.count +1
        self.detail_ui.itemlist[eitem.id] = eitem
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

function MassTroops:CancelMass(pathId,callback)
    local req = MapMsg_pb.CancelPathRequest()
    req.tarpathid = pathId
    Global.Request(Category_pb.Map, MapMsg_pb.MapTypeId.CancelPathRequest, req, MapMsg_pb.CancelPathResponse, function(msg)
        if msg.code ~= ReturnCode_pb.Code_OK then
            Global.ShowError(msg.code)
        else
            if callback ~= nil then
                callback()
            end
        end
    end, true)
end

function MassTroops:OnJoinBtn()
    if self.cur_select_index == 10 and self.detail_ui.join_state == self.join_state.join then --集结加入
        local x = self.detail_ui.item.msg.atkpos.x
        local y = self.detail_ui.item.msg.atkpos.y   
        if  (self.detail_ui.item.msg.eliteMonsterId ~= nil and self.detail_ui.item.msg.eliteMonsterId > 0) then  
            local massSta = Global.GetMinMassSceneEnergyValue()
            if massSta == 0 then
                massSta = RebelData.GetActivityInfo().massSta
            end
             if MainData.GetSceneEnergy() < massSta then
                Global.ShowNoEnoughSceneEnergy(massSta - MainData.GetSceneEnergy() +1)
                return
            end
        end
        local mtc = MassTroopsCondition()
        mtc:JoinMass4BattleCondition(function(success)
            if success then
                mtc:ShowJionMassBattleMove(self.detail_ui.homeuid, x, y,self.detail_ui.numMax - self.detail_ui.item.msg.num,function() 
                    --self:OpenDetail(self.detail_ui.item)
                end,self.detail_ui.item.msg.defpos.x,self.detail_ui.item.msg.defpos.y)
            end               
        end)
    end
    if self.cur_select_index == 20 and self.detail_ui.join_state == self.join_state.join then --驻防加入
        local x = self.detail_ui.item.msg.defpos.x
        local y = self.detail_ui.item.msg.defpos.y
        Embassy.CanEmbassy(self.detail_ui.homeuid,x,y,self.detail_ui.item.charid,function()
            self:OpenDetail(self.detail_ui.item)
        end)
    end   
    if self.cur_select_index == 10 and self.detail_ui.join_state == self.join_state.cancel then --集结取消
        self:CancelMass(self.detail_ui.pathId,function()
            self:CloseDetail()
        end)
    end
    if self.cur_select_index == 20 and self.detail_ui.join_state == self.join_state.cancel then --驻防取消
        if self.detail_ui.item.charid == MainData.GetCharId() then --取消全部
            Embassy.CancelEmbassyAllItemEx(self.detail_ui.homeuid,self.detail_ui.count,function()
                self:OpenDetail(self.detail_ui.item)
            end)    
        else--取消自己
            Embassy.CancelEmbassyItemEx(self.detail_ui.homeuid,MainData.GetCharId(),function()
                self:OpenDetail(self.detail_ui.item)
            end)    
        end
    end   
end

function MassTroops:_UpdateDetailJoinBtn(item)
    local state = -1
    if self.cur_select_index == 10 then
        if item.charid == MainData.GetCharId() then --判断是否是发起者
            state = self.join_state.cancel
        else
            if item.ui.state_index == 1 then--正在等待集结时
                --print(item.msg,self.detail_ui,item.msg.num,self.detail_ui.numMax)
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
            -- print(self.detail_ui.num,self.detail_ui.numMax)
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

function MassTroops:_UpdateJoinBtn()
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

function MassTroops:_OpenDetail(item,homeuid,msgitemlist,maxNum,pathId, msg)
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
    self:SetItem(self.detail_ui.item,self.detail_ui.item_trf,item.index,item.msg,true)
    self:_FillEmbassyItem(item,homeuid,msgitemlist)
    self:_RefrushEmbassyNum()
    --self.detail_ui.root:SetActive(true)
    if self.detail_ui.item ~= nil then
        self:_UpdateDetailJoinBtn(item)
    end
end

function MassTroops:UpdateDetail(charId)
    if self.list_items[charId] == nil then
        return 
    end

    if not self.detail_ui.root.activeSelf then
        return
    end

    if self.detail_ui.item ~= nil and self.detail_ui.item.charid ~= charId then
        return
    end
    if self.show_cabcel_msg_box then
        self.show_cabcel_msg_box = false
        MessageBox.SetCancelNow()
    end 
    --self:CloseDetailItem()
    local item = self.list_items[charId]
    self:RequestInfo(item.req_char_id,function(msg)        
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

function MassTroops:OpenDetail(item)
   
    if self.cur_select_index >= 10 then
        self.cur_select_index = self.per_select_index
    end    
     --print(self.cur_select_index)
    if self.cur_select_index == 1 then
        self:RequestInfoDetail(item.charid,function(msg) 
            if msg == nil then
                return
            else
                Embassy.FillUserBaseInfo(msg.user)
                --print(item,item.msg.atkHomeuid,msg.gather.gather,item.msg.numMax,msg.gather.gather[1].pathid)
                if msg.gather.gather == nil or #msg.gather.gather == 0 then
                    return
                end
                self:_OpenDetail(item,item.msg.atkHomeuid,msg.gather.gather,item.msg.numMax,msg.gather.gather[1].pathid, msg) 
            end
        end)
    else
        Embassy.RequestEmbassyData(item.charid,function(msg)
            Embassy.FillUserBaseInfo(msg.user)
            --print(msg.garrisonCapacity)
            self:_OpenDetail(item,msg.homeUid,msg.garrison.garrison,msg.garrisonCapacity,0) 
        end)
    end
end

function MassTroops:CloseDetailItem()
    if self.detail_ui.item ~= nil then
        self.detail_ui.item.isdestroy = true
        if self.detail_ui.item.ui.countdownid ~= nil then
            CountDown.Instance:Remove(self.detail_ui.item.ui.countdownid)
            --print(" CountDown.Instance:Remove",self.detail_ui.item.ui.countdownid)
            self.detail_ui.item.ui.countdownid = nil
        end
    end
    self.detail_ui.source_item  =nil
    self.detail_ui.item = nil
end

function MassTroops:CloseDetail()
    self.detail_ui.root:SetActive(false)
    self.list_ui.root:SetActive(true)
    self:ClearEmbassyItem()
    self:CloseDetailItem()
    print( self.cur_select_index)
    self.cur_select_index = self.per_select_index
    self:OpenList(self.cur_select_index)
end

function MassTroops:Open()
    self.inited = true
    
    if MainCityUI.MassTotlaNum[1] == 0 and MainCityUI.MassTotlaNum[2] ~= 0 then
        self.list_ui[1].page:Set(false)
        self.list_ui[2].page:Set(true)
        self:OpenList(2)
    else
        self.list_ui[1].page:Set(true)
        self.list_ui[2].page:Set(false)        
        self:OpenList(1)
    end
end

function MassTroops:Close() 
    self.show_cabcel_msg_box = false
    self.inited = false
    MainCityUI.UpdateNotice()
    self:ClearEmbassyItem()
    self:CloseDetailItem()
    self:Clearlist()
end



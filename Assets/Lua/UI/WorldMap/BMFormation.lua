class "BMFormation"
{
}

function BMFormation:__init__(trf)
    self.transform = trf
    self.leftFormation = nil
    self.rightFormation = nil

    self.leftUI = nil
    self.rightUI = nil
    self.selectUI = nil
    self.selectFormation = nil
    self.leftDefense_obj = nil
    self.rightDefense_obj = nil
    self.leftArrow_obj = nil
    self.rightArrow_obj = nil
    self.leftPressSelected = nil
    self.click_count = 2
    self.formationIdMap = {}
    self.formationIdMap[21] = "icon_rifle"
    self.formationIdMap[22] = "icon_sniper"
    self.formationIdMap[23] = "icon_RPG"
    self.formationIdMap[24] = "icon_tank"
    
    self.formationIdMap[27] = "icon_machinegun"
    self.formationIdMap[28] = "icon_cannon"

    self.formationIdMap[99] = "wenhao01"
    self.formationIdMap[100] = "wenhao_fan"

    self.formationNameMap = {}
    self.formationNameMap[21] = Global.GTextMgr:GetText("TabName_1001")
    self.formationNameMap[22] = Global.GTextMgr:GetText("TabName_1002")
    self.formationNameMap[23] = Global.GTextMgr:GetText("TabName_1003")
    self.formationNameMap[24] = Global.GTextMgr:GetText("TabName_1004")
    self.formationNameMap[27] = Global.GTextMgr:GetText("TabName_101")
    self.formationNameMap[28] = Global.GTextMgr:GetText("TabName_102")

    self.selectShow_spriet = nil
    self.CurPressSelectIndex = 0
    self.CurClickSelectIndex = 0
    self.onSelectEndCallBack = nil
end

function BMFormation:SetCallBack(callback)
    self.onSelectEndCallBack = callback
end

function BMFormation:GetSelfFormation()
	return self.selectFormation
end

function BMFormation:PvPData2Formation(data) -- data:BattleUserAttrInfo
	if data == nil or data.army == nil then
		return nil
	end
	
	local formation = {}
	for i =1,#(data.army),1 do
	    if data.army[i].army.baseid == 101 then
	        formation[data.army[i].pos] = 27
	    elseif data.army[i].army.baseid == 102 then
	        formation[data.army[i].pos] = 28
	    else
		    local solider = Barrack.GetAramInfo(data.army[i].army.baseid , data.army[i].army.level)
            formation[data.army[i].pos] = solider.BarrackId
        end
    end
	return formation
end

function BMFormation:Data2Formation(data)
    if data == nil or data.army == nil then
        return nil
    end
    local formation = {}
    for i =1,#(data.army),1 do
	    if data.army[i].army.baseid == 101 then
	        formation[data.army[i].pos] = 27
	    elseif data.army[i].army.baseid == 102 then
	        formation[data.army[i].pos] = 28
	    else        
            local solider = Barrack.GetAramInfo(data.army[i].armyId,data.army[i].armyLevel)
            formation[data.army[i].pos] = solider.BarrackId
        end
    end
    return formation
end

function BMFormation:CheckArmyRestrict()	
    if self.leftFormation ~= nil then
	for i=1 , 6 , 1 do
		---self.leftUI[i].unit_restricSpr
		local restrainInfo = ""
		if self.leftFormation[i] ~= nil then
			local tIndex = self:GetTargetIndexInFormation(i , self.rightFormation)
			if tIndex > 0 then
				--print("left :" ,i , self.leftFormation[i] , " targetIndex:" , tIndex , self.rightFormation[tIndex])
				local barrackData = Global.GTableMgr:GetBarrackRestrainInfo(self.leftFormation[i])
                local barrackTargetData = Global.GTableMgr:GetBarrackRestrainInfo(self.rightFormation[tIndex])
                if barrackData ~= nil and barrackTargetData ~= nil then
                
				local restrainId = tonumber(string.split(barrackData.Restrain , '_')[2])
				local restrainedId = tonumber(string.split(barrackData.Restrained , '_')[2])
				if restrainId == barrackTargetData.SoldierId then
					--print("barrack:" , barrackData.SoldierId , " 克制 :" , restrainId)
					restrainInfo = "icon_star"
					self.leftUI[i].unit_restricSpr.color = Color.New(0,1,0,self.rightUI[i].unit_restricSpr.color.a)
					if self.leftUI[i].unit_restricGreen and self.leftUI[i].unit_restricRed then
						self.leftUI[i].unit_restricGreen.gameObject:SetActive(true)
						self.leftUI[i].unit_restricRed.gameObject:SetActive(false)
					end
				elseif restrainedId == barrackTargetData.SoldierId then
					restrainInfo = "icon_unprotect"
					self.leftUI[i].unit_restricSpr.color = Color.New(1,0,0,self.rightUI[i].unit_restricSpr.color.a)
					if self.leftUI[i].unit_restricGreen and self.leftUI[i].unit_restricRed then
						self.leftUI[i].unit_restricRed.gameObject:SetActive(true)
						self.leftUI[i].unit_restricGreen.gameObject:SetActive(false)
					end
					--print("barrack:" , barrackData.SoldierId , " 被克制 :" , restrainedId)
				else
					--print("barrack:" , barrackData.SoldierId , " 互不克制 :" , barrackTargetData.SoldierId)
					restrainInfo = "icon_translate"
					self.leftUI[i].unit_restricSpr.color = Color.New(1, 0.9215686, 0.01568628, self.rightUI[i].unit_restricSpr.color.a)
					if self.leftUI[i].unit_restricGreen and self.leftUI[i].unit_restricRed then
						self.leftUI[i].unit_restricRed.gameObject:SetActive(false)
						self.leftUI[i].unit_restricGreen.gameObject:SetActive(false)
					end
				end
                end
			else
				--print("left :" ,i , self.leftFormation[i] , "== no target ==")
			end
		end
		--print(self.rightUI)
		if self.leftUI[i].unit_restricSpr ~= nil and restrainInfo ~= "" then 
			self.leftUI[i].unit_restricSpr.gameObject:SetActive(true)
			--self.leftUI[i].unit_restricSpr.spriteName = restrainInfo
			--self.leftUI[i].unit_restricSpr.color = statsColor
		else
			self.leftUI[i].unit_restricSpr.gameObject:SetActive(false)
		end
    end
    end
	
	if self.rightFormation ~= nil then
	for i=1 , 6 , 1 do
		---self.leftUI[i].unit_restricSpr
		local restrainInfo = ""
		if self.rightFormation[i] ~= nil then
			local tIndex = self:GetTargetIndexInFormation(i , self.leftFormation)
			if tIndex > 0 then
				--print("right :" ,i , self.rightFormation[i] , " targetIndex:" , tIndex , self.leftFormation[tIndex])
				local barrackData = Global.GTableMgr:GetBarrackRestrainInfo(self.rightFormation[i])
                local barrackTargetData = Global.GTableMgr:GetBarrackRestrainInfo(self.leftFormation[tIndex])
                if barrackData ~= nil and barrackTargetData ~= nil then
				local restrainId = tonumber(string.split(barrackData.Restrain , '_')[2])
				local restrainedId = tonumber(string.split(barrackData.Restrained , '_')[2])
				if restrainId == barrackTargetData.SoldierId then
					--print("barrack:" , barrackData.SoldierId , " 克制 :" , restrainId)
					restrainInfo = "icon_star"
					self.rightUI[i].unit_restricSpr.color = Color.New(0,1,0,self.rightUI[i].unit_restricSpr.color.a)
					if self.rightUI[i].unit_restricGreen and self.rightUI[i].unit_restricRed then
						self.rightUI[i].unit_restricGreen.gameObject:SetActive(true)
						self.rightUI[i].unit_restricRed.gameObject:SetActive(false)
					end
				elseif restrainedId == barrackTargetData.SoldierId then
					restrainInfo = "icon_unprotect"
					self.rightUI[i].unit_restricSpr.color = Color.New(1,0,0,self.rightUI[i].unit_restricSpr.color.a)
					if self.rightUI[i].unit_restricGreen and self.rightUI[i].unit_restricRed then
						self.rightUI[i].unit_restricGreen.gameObject:SetActive(false)
						self.rightUI[i].unit_restricRed.gameObject:SetActive(true)
					end
					--print("barrack:" , barrackData.SoldierId , " 被克制 :" , restrainedId)
				else
					--print("barrack:" , barrackData.SoldierId , " 互不克制 :" , barrackTargetData.SoldierId)
					restrainInfo = "icon_translate"
					self.rightUI[i].unit_restricSpr.color = Color.New(1, 0.9215686, 0.01568628, self.rightUI[i].unit_restricSpr.color.a)
					if self.rightUI[i].unit_restricGreen and self.rightUI[i].unit_restricRed then
						self.rightUI[i].unit_restricGreen.gameObject:SetActive(false)
						self.rightUI[i].unit_restricRed.gameObject:SetActive(false)
					end
				end
                end
			else
				--print("right :" ,i , self.rightFormation[i] , "== no target ==")
			end
		end
		--print(self.rightUI)
		if self.rightUI[i].unit_restricSpr ~= nil and restrainInfo ~= "" then 
			self.rightUI[i].unit_restricSpr.gameObject:SetActive(true)
			--self.rightUI[i].unit_restricSpr.spriteName = restrainInfo
		else
			self.rightUI[i].unit_restricSpr.gameObject:SetActive(false)
		end
    end
    end
	--local tIndex = self:GetTargetIndexInFormation(3 , self.leftFormation)
end

function BMFormation:GetTargetIndexInFormation(formPos , tagetFormation)
	local add = true
	local row = 0
	--[[for i=1 , 6 , 1 do
		if add then
			local tIndex = row * 3 + formPos % 3
			tIndex = tIndex == 0 and 3 or tIndex
			if tagetFormation[tIndex] ~= nil and tagetFormation[tIndex] > 0 then
				return tIndex
			end
			add = false
		end
		
		if tagetFormation[i] ~= nil and tagetFormation[i] > 0 then
			return i
		end
		
		if i % 3 == 0 then
			add = true
			row = row + 1
		end
	end
	return 0 
	]]
    
    if tagetFormation == nil then
        return 0
    end
	local tIndex = formPos % 3
	tIndex = tIndex == 0 and 3 or tIndex
	
	if tagetFormation[tIndex] ~= nil and tagetFormation[tIndex] > 0 then
		return tIndex
	elseif tagetFormation[tIndex + 3] ~= nil and tagetFormation[tIndex + 3] > 0 then
		return tIndex + 3
	else
		return 0
	end

end

function BMFormation:FillFormation(formation,ui,isright)
    if formation == nil or ui == nil then
        return
    end
    for i=1,6,1 do 
        if ui[i] ~= nil then
            ui[i].unit_sprite.gameObject:SetActive(false)
            if formation[i] ~= nil and formation[i] ~= 0 then
				--print("fill formation[" .. i .. "] :" ,formation[i])
                ui[i].unit_sprite.spriteName =self.formationIdMap[formation[i]] 
                ui[i].unit_sprite.gameObject:SetActive(true)
                if ui[i].unit_name then
                    if formation[i] == 99 or formation[i] == 100 then
                        ui[i].unit_name.transform.parent.gameObject:SetActive(false)
                    else
                        ui[i].unit_name.transform.parent.gameObject:SetActive(true)
                        ui[i].unit_name.text = self.formationNameMap[formation[i]]
                    end
                end
                if isright then
                	if formation[i] == 99 then
                		ui[i].unit_sprite.spriteName =self.formationIdMap[100] 
                	end
                end
            end       
        end
    end
    if isright then
        for i=7,8,1 do
            self.rightDefense_obj[i-6].unit_sprite.gameObject:SetActive(false)
            if formation[i] ~= nil and formation[i] ~= 0  then
                self.rightDefense_obj[i-6].unit_sprite.spriteName =self.formationIdMap[formation[i]] 
                self.rightDefense_obj[i-6].unit_sprite.gameObject:SetActive(true)   
                if formation[i] == 99 then
                    self.rightDefense_obj[i-6].unit_sprite.spriteName =self.formationIdMap[100] 
                    if self.rightDefense_obj[i-6].unit_name then
                        self.rightDefense_obj[i-6].unit_name.transform.parent.gameObject:SetActive(false)
                    end
                else
                    if self.rightDefense_obj[i-6].unit_name then
                        self.rightDefense_obj[i-6].unit_name.transform.parent.gameObject:SetActive(true)
                        self.rightDefense_obj[i-6].unit_name.text = self.formationNameMap[formation[i]] 
                    end
                end             
            end
        end
    end
end

--pvp 邮件阵形
function BMFormation:SetPVPMailLeftFormationData(PvpMailArmyDetectionInfo)
    self.leftFormation = self:PvPData2Formation(PvpMailArmyDetectionInfo)
end

function BMFormation:SetPVPMailRightFormationData(PvpMailArmyDetectionInfo)
    self.rightFormation = self:PvPData2Formation(PvpMailArmyDetectionInfo)
end

function BMFormation:SetLeftFormationData(ArmyDetectionInfo)
    self.leftFormation = self:Data2Formation(ArmyDetectionInfo)
end

function BMFormation:SetRightFormationData(ArmyDetectionInfo)
    self.rightFormation = self:Data2Formation(ArmyDetectionInfo)
end

function BMFormation:SetLeftFormation(form)
    self.leftFormation = form
end

function BMFormation:SetRightFormation(form)
    self.rightFormation = form
end

function BMFormation:OnPressSelect(isPress,obj)
    if self.selectUI == nil then 
        return
    end
    if not isPress then --or not UnityEngine.Input.GetMouseButton(0) then
        return    
    end

    local selected = 0
    for i = 1,6,1 do 

        if self.selectUI[i].pos_sprite.gameObject == obj then
            selected = i
            break
        end
    end
    if selected > 0 and self.selectFormation[selected] > 0 then
        self.CurPressSelectIndex = selected
        self.selectShow_spriet.spriteName = self.formationIdMap[self.selectFormation[self.CurPressSelectIndex]]
        self.PressSelected.Enable=true
        self.selectUI[self.CurPressSelectIndex].unit_sprite.gameObject:SetActive(false)
        self.selectUI[self.CurPressSelectIndex].pos_sprite_selected.PressActiveObj:SetActive(true)
    end
    print("Begin -----------------   ",self.CurPressSelectIndex)
    self.click_count = self.click_count -1
end

function BMFormation:OnPressSelectEnd(obj)
    if self.selectUI == nil then 
        return
    end

    local selected = 0
    for i = 1,6,1 do
        if self.selectUI[i].pos_sprite.gameObject == obj then
            selected = i
            break
        end
    end
    print("End -----------------   ",self.CurPressSelectIndex)
    if selected > 0 and self.CurPressSelectIndex > 0 then
        local old_fid = self.selectFormation[self.CurPressSelectIndex]
        local new_fid = self.selectFormation[selected]
        self.selectFormation[self.CurPressSelectIndex] = new_fid
        self.selectFormation[selected] = old_fid      

        self.selectUI[self.CurPressSelectIndex].unit_sprite.gameObject:SetActive(false)
        if self.selectFormation[self.CurPressSelectIndex] ~= 0 then
            self.selectUI[self.CurPressSelectIndex].unit_sprite.spriteName =self.formationIdMap[self.selectFormation[self.CurPressSelectIndex]] 
            self.selectUI[self.CurPressSelectIndex].unit_sprite.gameObject:SetActive(true)
            if self.selectUI[self.CurPressSelectIndex].unit_name then
                self.selectUI[self.CurPressSelectIndex].unit_name.text = self.formationNameMap[self.selectFormation[self.CurPressSelectIndex]]
            end
        end  
        self.selectUI[selected].unit_sprite.gameObject:SetActive(false)
        if self.selectFormation[selected] ~= 0 then
            self.selectUI[selected].unit_sprite.spriteName =self.formationIdMap[self.selectFormation[selected]] 
            self.selectUI[selected].unit_sprite.gameObject:SetActive(true)
            if self.selectUI[selected].unit_name then
                self.selectUI[selected].unit_name.text = self.formationNameMap[self.selectFormation[selected]]
            end
        end 
    else
        if self.CurPressSelectIndex > 0 then
            self.selectUI[self.CurPressSelectIndex].unit_sprite.gameObject:SetActive(true)
        end
    end
    self.PressSelected.Enable=false

    print("CCCCCCCCCC",self.click_count)
    if self.click_count  <= 1 then
        if self.CurPressSelectIndex > 0 then
            self.selectUI[self.CurPressSelectIndex].pos_sprite_selected.PressActiveObj:SetActive(false)
        end
        if self.CurClickSelectIndex > 0 then
            self.selectUI[self.CurClickSelectIndex].pos_sprite_selected.PressActiveObj:SetActive(false)
        end        
        if selected > 0 then
            self.selectUI[selected].pos_sprite_selected.PressActiveObj:SetActive(false)
        end             
    end

    self.CurPressSelectIndex = 0
    
    --self.CurClickSelectIndex = 0
    if self.onSelectEndCallBack ~= nil then
        self.onSelectEndCallBack(self.selectFormation)
    end
    self:CheckArmyRestrict()
end

function BMFormation:OnClickSelect(obj)
    if self.selectUI == nil then 
        return
    end
    local selected = 0
    for i = 1,6,1 do
        if self.selectUI[i].pos_sprite.gameObject == obj then
            selected = i
            break
        end
    end    
    if self.click_count  < 1 then
        self.CurClickSelectIndex = 0
    end
    if self.CurClickSelectIndex == 0 then
        if selected > 0 and self.selectFormation[selected] > 0 then
            self.CurClickSelectIndex = selected
            --self.selectShow_spriet.spriteName = self.formationIdMap[self.selectFormation[self.CurClickSelectIndex]]
            self.PressSelected.Enable=true
            --self.selectUI[self.CurClickSelectIndex].unit_sprite.gameObject:SetActive(false)
            self.click_count = 2
            self.selectUI[self.CurClickSelectIndex].pos_sprite_selected.PressActiveObj:SetActive(true)
        end
        print("Click1 -----------------   ",self.CurClickSelectIndex)
    else
        print("Click2 -----------------   ",self.CurClickSelectIndex)
        if selected > 0 and self.CurClickSelectIndex > 0 then
            local old_fid = self.selectFormation[self.CurClickSelectIndex]
            local new_fid = self.selectFormation[selected]
            self.selectFormation[self.CurClickSelectIndex] = new_fid
            self.selectFormation[selected] = old_fid      
    
            self.selectUI[self.CurClickSelectIndex].unit_sprite.gameObject:SetActive(false)
            if self.selectFormation[self.CurClickSelectIndex] ~= 0 then
                self.selectUI[self.CurClickSelectIndex].unit_sprite.spriteName =self.formationIdMap[self.selectFormation[self.CurClickSelectIndex]] 
                self.selectUI[self.CurClickSelectIndex].unit_sprite.gameObject:SetActive(true)
                if self.selectUI[self.CurClickSelectIndex].unit_name then
                    self.selectUI[self.CurClickSelectIndex].unit_name.text = self.formationNameMap[self.selectFormation[self.CurClickSelectIndex]]
                end
            end  
            self.selectUI[selected].unit_sprite.gameObject:SetActive(false)
            if self.selectFormation[selected] ~= 0 then
                self.selectUI[selected].unit_sprite.spriteName =self.formationIdMap[self.selectFormation[selected]] 
                self.selectUI[selected].unit_sprite.gameObject:SetActive(true)
                if self.selectUI[selected].unit_name then
                    self.selectUI[selected].unit_name.text = self.formationNameMap[self.selectFormation[selected]]
                end
            end 
        else
            print("Click3 -----------------   ",self.CurClickSelectIndex)
            if self.CurClickSelectIndex > 0 then
                self.selectUI[self.CurClickSelectIndex].unit_sprite.gameObject:SetActive(true)
            end
        end
        self.PressSelected.Enable=false
        self.CurClickSelectIndex = 0
        self.CurPressSelectIndex = 0
        if self.onSelectEndCallBack ~= nil then
            self.onSelectEndCallBack(self.selectFormation)
        end
        self:CheckArmyRestrict()
    end
end


function BMFormation:Awake(enable_editor)
    BattleMove.RecordTime("BMFormation:Awake==============================")
    self.leftUI = {}
    for i = 1,6,1 do 
        self.leftUI[i] = {}
        self.leftUI[i].unit_sprite = self.transform:Find("bg_left/soldier ("..i..")"):GetComponent("UISprite")
        self.leftUI[i].unit_name = self.transform:Find("bg_left/soldier ("..i..")/bg_name/text")
        if self.leftUI[i].unit_name then
            self.leftUI[i].unit_name = self.leftUI[i].unit_name:GetComponent("UILabel")
        end
		if self.transform:Find("bg_left/soldier ("..i..")/Sprite") ~= nil then
			self.leftUI[i].unit_restricSpr = self.transform:Find("bg_left/soldier ("..i..")/Sprite"):GetComponent("UISprite")
			self.leftUI[i].unit_restricRed = self.transform:Find("bg_left/soldier ("..i..")/hongse")
			self.leftUI[i].unit_restricGreen = self.transform:Find("bg_left/soldier ("..i..")/lvse")
		end
        self.leftUI[i].pos_sprite = self.transform:Find("bg_left/"..i):GetComponent("UISprite")
        self.leftUI[i].pos_sprite_selected = self.leftUI[i].pos_sprite:GetComponent("UIPressSelected");
        self.leftUI[i].unit_sprite.gameObject:SetActive(false)
        if enable_editor ~= nil and enable_editor == 1 then
            self.leftUI[i].pos_sprite:GetComponent("BoxCollider").enabled = true
            UIUtil.SetPressCallback(self.leftUI[i].pos_sprite.gameObject,function(go,ispress)
                self:OnPressSelect(ispress,go)
            end)
            UIUtil.SetClickCallback(self.leftUI[i].pos_sprite.gameObject,function(go)
                self:OnClickSelect(go)
            end)
        else
            local bc = self.leftUI[i].pos_sprite:GetComponent("BoxCollider")
            if bc ~= nil then
                bc.enabled = false     
            end
        end
    end
    BattleMove.RecordTime("BMFormation:Awake  leftUI==============================")
    self.rightUI = {}
    for i = 1,6,1 do 
        self.rightUI[i] = {}
        self.rightUI[i].unit_sprite = self.transform:Find("bg_right/soldier ("..i..")"):GetComponent("UISprite")
        self.rightUI[i].unit_name = self.transform:Find("bg_right/soldier ("..i..")/bg_name/text")
        if self.rightUI[i].unit_name then
            self.rightUI[i].unit_name = self.rightUI[i].unit_name:GetComponent("UILabel")
        end
		if self.transform:Find("bg_right/soldier ("..i..")/Sprite") ~= nil then
			self.rightUI[i].unit_restricSpr = self.transform:Find("bg_right/soldier ("..i..")/Sprite"):GetComponent("UISprite")
			self.rightUI[i].unit_restricRed = self.transform:Find("bg_right/soldier ("..i..")/hongse")
			self.rightUI[i].unit_restricGreen = self.transform:Find("bg_right/soldier ("..i..")/lvse")
		end
        self.rightUI[i].pos_sprite = self.transform:Find("bg_right/"..i):GetComponent("UISprite")
        self.rightUI[i].pos_sprite_selected = self.rightUI[i].pos_sprite:GetComponent("UIPressSelected");
        self.rightUI[i].unit_sprite.gameObject:SetActive(false)   
        if enable_editor ~= nil and enable_editor == 2 then
            self.rightUI[i].pos_sprite:GetComponent("BoxCollider").enabled = true
            UIUtil.SetPressCallback(self.rightUI[i].pos_sprite.gameObject,function(go,ispress)
                self:OnPressSelect(ispress,go)
            end)
            UIUtil.SetClickCallback(self.rightUI[i].pos_sprite.gameObject,function(go)
                self:OnClickSelect(go)
            end)            
        else
            local bc = self.rightUI[i].pos_sprite:GetComponent("BoxCollider")
            if bc ~= nil then
                bc.enabled = false     
            end
        end
    end
    BattleMove.RecordTime("BMFormation:Awake  rightUI==============================")

    self.rightDefense_obj = {}
    for i =1,2,1 do
        self.rightDefense_obj[i] = {}  
        self.rightDefense_obj[i].unit_sprite = self.transform:Find("bg_right/bg_defense/soldier ("..i..")"):GetComponent("UISprite")
        self.rightDefense_obj[i].unit_sprite.gameObject:SetActive(false)
        self.rightDefense_obj[i].unit_name = self.transform:Find("bg_right/bg_defense/soldier ("..i..")/bg_name/text")
        if self.rightDefense_obj[i].unit_name then
            self.rightDefense_obj[i].unit_name = self.rightDefense_obj[i].unit_name:GetComponent("UILabel")
        end
    end
    BattleMove.RecordTime("BMFormation:Awake  rightDefense_obj==============================")

    if  self.PressSelected ~= nil then
        self.PressSelected.OnPSelectedEndCallBack = nil
        self.PressSelected.enabled=false
        self.PressSelected = nil
    end

    if self.selectShow_spriet ~= nil then
        self.selectShow_spriet.gameObject:SetActive(false) 
        self.selectShow_spriet = nil
    end

    if enable_editor ~= nil then
        if enable_editor == 1 then
            self.selectUI = self.leftUI
            self.selectFormation = self.leftFormation
            self.PressSelected = self.transform:Find("bg_left"):GetComponent("UIPressSelected")
            self.PressSelected.OnPSelectedEndCallBack = function( go)
                self:OnPressSelectEnd( go)
            end
            self.PressSelected.enabled=false
            self.PressSelected:Reset()
            local rightPressSelected = self.transform:Find("bg_right"):GetComponent("UIPressSelected")
            rightPressSelected.enabled=false  
            rightPressSelected:Reset()

            self.selectShow_spriet = self.transform:Find("left soldier Select"):GetComponent("UISprite")
            self.selectShow_spriet.gameObject:SetActive(false)
        elseif enable_editor == 2 then
            self.selectUI = self.rightUI
            self.selectFormation = self.rightFormation
            self.PressSelected = self.transform:Find("bg_right"):GetComponent("UIPressSelected")
            self.PressSelected.OnPSelectedEndCallBack = function( go)
                self:OnPressSelectEnd( go)
            end
            self.PressSelected.enabled=false  
            self.PressSelected:Reset()
            local leftPressSelected = self.transform:Find("bg_left"):GetComponent("UIPressSelected")
            leftPressSelected.enabled=false  
            leftPressSelected:Reset()

            self.selectShow_spriet = self.transform:Find("right soldier Select"):GetComponent("UISprite")
            self.selectShow_spriet.gameObject:SetActive(false)            
        else
            local leftPressSelected = self.transform:Find("bg_left"):GetComponent("UIPressSelected")
            if leftPressSelected ~= nil then
                leftPressSelected.enabled=false  
                leftPressSelected:Reset()
            end
            local rightPressSelected = self.transform:Find("bg_right"):GetComponent("UIPressSelected")
            if rightPressSelected ~= nil then
                rightPressSelected.enabled=false  
                rightPressSelected:Reset()            
            end
            self.selectUI = nil
            self.selectFormation = nil
        end
    else
        local leftPressSelected = self.transform:Find("bg_left"):GetComponent("UIPressSelected")
        if leftPressSelected ~= nil then
            leftPressSelected.enabled=false  
            leftPressSelected:Reset()
        end
        local rightPressSelected = self.transform:Find("bg_right"):GetComponent("UIPressSelected")
        if rightPressSelected ~= nil then
            rightPressSelected.enabled=false  
            rightPressSelected:Reset()            
        end

        self.selectUI = nil
        self.selectFormation = nil
    end
    BattleMove.RecordTime("BMFormation:Awake  enable_editor==============================")

    self.leftDefense_obj = self.transform:Find("bg_left/bg_defense").gameObject
    self.leftDefense_obj:SetActive(false)
    
    --self.rightDefense_obj = self.transform:Find("bg_right/bg_defense").gameObject
    --self.rightDefense_obj:SetActive(false)

    self.leftArrow_obj = self.transform:Find("left_arrow").gameObject
    self.leftArrow_obj:SetActive(true)

    self.rightArrow_obj = self.transform:Find("right_arrow").gameObject
    self.rightArrow_obj:SetActive(false)
    BattleMove.RecordTime("BMFormation:Awake  rightArrow==============================")


    self:FillFormation(self.leftFormation,self.leftUI)
    BattleMove.RecordTime("BMFormation:Awake  FillFormation leftUI ==============================")
    self:FillFormation(self.rightFormation,self.rightUI,true)
    BattleMove.RecordTime("BMFormation:Awake  FillFormation rightUI ==============================")

    local rootuips = self.transform:GetComponent("UIPressSelected");
    if rootuips ~= nil then
        rootuips.enabled = false
    end
end

function BMFormation:Equals(form1 , form2)
	 if form1 == nil or form2 == nil then
        return false
    end
	
    for i=1,6,1 do 
		if form1[i] ~= form2[i] then
			return false
		end
	end
	return true
end
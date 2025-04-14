local TextMgr = Global.GTextMgr
class "TileInfoMore"
{
}

function TileInfoMore:__init__(RootTrf , isMobaMode)
    self.trf = RootTrf
    self.Sprite = self.trf:Find("bg"):GetComponent("UISprite")
    self.Sprite.gameObject:SetActive(false)
    self.state = false
    self.tragetbtn = self.trf:Find("bg/btn_ traget").gameObject
    UIUtil.SetClickCallback(self.tragetbtn,function()
        self:onClickTraget()
    end)
    self.sharebtn = self.trf:Find("bg/btn_share").gameObject
    UIUtil.SetClickCallback(self.sharebtn,function()
        self:onClickShare()
    end)    
    local buildTransform = self.trf:Find("bg/btn_build")
    if buildTransform ~= nil then
        self.buildbtn = buildTransform.gameObject
        UIUtil.SetClickCallback(self.buildbtn,function()
            self:onClickBuild()
        end)    
    end
    self.name = nil
    self.x = nil
    self.y = nil 
    self.icon = nil
	self.mobaMode = isMobaMode
end

function TileInfoMore:onClickTraget()
    if self.name == nil or self.x == nil or self.y == nil then
        return
    end
    Traget_Set.Show(self.name,self.x,self.y)
end

function TileInfoMore:onClickShare()
	if self.mobaMode then
		MobaTraget_Share.Show(self.name,self.icon,self.x,self.y) 
	else
		Traget_Share.Show(self.name,self.icon,self.x,self.y) 
	end
end

function TileInfoMore:onClickBuild()
    if not UnionInfoData.HasPrivilege(GuildMsg_pb.PrivilegeType_DeclareWar) then
        MessageBox.Show(TextMgr:GetText(Text.union_build1))
        return
    end
    if not WorldBorderData.IsSelfBorder(self.x, self.y) then
        MessageBox.Show(TextMgr:GetText(Text.union_build2))
        return
    end
    TileInfo.Hide()
    UnionBuilding.Show(self.x, self.y)
end

function TileInfoMore:Open(Traget,name,x,y,icon) 
    if self.state then
        self:Close()
    else
		self.trf.gameObject:SetActive(true)
        self.Sprite.gameObject:SetActive(true)
        self.Sprite.transform.localPosition = Vector3.zero
        local pos = self.trf:InverseTransformPoint(Traget.transform.position)
        self.Sprite.transform.localPosition = pos + Vector3(48,60,0) 
        self.name = name
		self.x = x
		self.y = y
        if self.mobaMode then
			local offset_x,offset_y = MobaMain.MobaMinPos()  
			self.x = x - offset_x
			self.y = y - offset_y
		end
        self.icon = icon
    end

    self.state = not self.state
	
	if Global.IsSlgMobaMode() then
		self:onClickShare()
		self:Close()
	end 
end

function TileInfoMore:Close()
    self.name = nil
    self.x = nil
    self.y = nil     
    self.Sprite.gameObject:SetActive(false)
end



module("GOV_Util", package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local String = System.String
local SetPressCallback = UIUtil.SetPressCallback
local SetClickCallback = UIUtil.SetClickCallback
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local GameObject = UnityEngine.GameObject


local GovMenus = {
	"GOV_Help","GOV_Main","GOV_Officialinfo","GOV_Authority",
}

function ToGovOfficialInfo4UserBaseInfo(userBaseInfo)
    if userBaseInfo == nil then
        return
    end

    local msg = {}
	msg.officialId = userBaseInfo.officialId
	msg.charId = userBaseInfo.charid
	if msg.charId == nil then
		msg.charId = userBaseInfo.charId
	end
	msg.charName = userBaseInfo.name
	msg.privilege = userBaseInfo.privilege
	msg.guildId = userBaseInfo.guildid
    msg.guildBanner = userBaseInfo.guildBanner
    return msg
end

function ToGovOfficialInfo4MainData()
    local msg = {}
	msg.officialId = MainData.GetOfficialId()
	msg.charId = MainData.GetCharId()
	msg.charName = MainData.GetCharName()
    msg.privilege = MainData.GetGOVPrivilege()
    local union = UnionInfoData.GetData()
	msg.guildId = union.guildInfo.guildId
    msg.guildBanner = union.guildInfo.banner
    return msg

end

function SetFaceUI(bg_face_trf,militaryRankId)
	
	if bg_face_trf == nil then
		return
	end
	bg_face_trf.gameObject:SetActive(false)
	local militaryRankData = nil
	if militaryRankId ~= nil then
		militaryRankData = tableData_tMilitaryRank.data[militaryRankId] 
	end
	if militaryRankData == nil then
		return
	end
	bg_face_trf.gameObject:SetActive(true)
	local icon = bg_face_trf:Find("Texture")
	if icon ~= nil then
        icon.gameObject:SetActive(true)
		if militaryRankData ~= nil then
			icon:GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/MilitaryRank/", militaryRankData.Icon)
		else
			icon.gameObject:SetActive(false)
        end		
	end
end


function SetGovNameUIEx(bg_gov_trf,officialId,guildOfficialId,militaryRankId,WhenInvaildHide)
	if bg_gov_trf == nil then
		return
	end
	
	local officialData = TableMgr:GetGoveOfficialData()
	local guildOfficialData = tableData_tUnionOfficial.data[guildOfficialId] 
	local militaryRankData = nil
	if militaryRankId ~= nil then
		militaryRankData = tableData_tMilitaryRank.data[militaryRankId] 
	end
	--print("YYYYYYYYYYYYYYYYYYY",officialData[officialId], guildOfficialData, militaryRankData,militaryRankId)
	if officialData[officialId] == nil and guildOfficialData == nil and militaryRankData == nil then
		if WhenInvaildHide then
			bg_gov_trf.localScale = Vector3(0,1,1)
			bg_gov_trf.gameObject:SetActive(false)
		else
			bg_gov_trf.localScale = Vector3(1,1,1)
			bg_gov_trf.gameObject:SetActive(true)	
			local text = bg_gov_trf:Find("text")
			if text ~= nil then
				text:GetComponent("UILabel").text = TextMgr:GetText("GOV_ui62")
			end
			local icon = bg_gov_trf:Find("gov_icon")
			if icon ~= nil then
				icon.gameObject:SetActive(false)
			end
		end
		return
	end
	bg_gov_trf.localScale = Vector3(1,1,1)
	bg_gov_trf.gameObject:SetActive(true)	
	local data = officialData[officialId]
	local text = bg_gov_trf:Find("text")
	if text ~= nil then
		--text.gameObject:SetActive(true)
        if officialData[officialId] ~= nil then
            local cf = data.grade >= 100 and GovernmentData.ColorStr.RebelName or GovernmentData.ColorStr.OfficialName
            text:GetComponent("UILabel").text = cf.. TextMgr:GetText(data.name)..GovernmentData.ColorStr.End
		elseif guildOfficialData ~= nil then
			text:GetComponent("UILabel").text = TextMgr:GetText(guildOfficialData.name)
		else
			text:GetComponent("UILabel").text = ""
			--text.gameObject:SetActive(false)
        end
	end
	local icon = bg_gov_trf:Find("gov_icon")
	if icon ~= nil then
        icon.gameObject:SetActive(true)
        if officialData[officialId] ~= nil then
            icon:GetComponent("UITexture").mainTexture =  ResourceLibrary:GetIcon(GovernmentData.Official_icon_path, data.icon)
		elseif guildOfficialData ~= nil then
			icon:GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/Government/", guildOfficialData.icon)
		elseif militaryRankData ~= nil then
			icon:GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Icon/MilitaryRank/", militaryRankData.Icon)
		else
			icon.gameObject:SetActive(false)
        end
	end
end

function SetGovNameUI(bg_gov_trf,officialId,guildOfficialId,WhenInvaildHide,militaryRankId)
	--local info = debug.getinfo(2,"S")
    --print("RRRRRRRRRRRRRRRRRRRR",info.source,info.linedefined)
    
	SetGovNameUIEx(bg_gov_trf,officialId,guildOfficialId,militaryRankId,WhenInvaildHide)
end

function SetGovInfoUI(bg_gov_trf,govOfficialInfo,setfinishColseCallback)
	if bg_gov_trf == nil  or govOfficialInfo == nil then
		return
    end
	local isedit = GovernmentData.EnableEditOfficial(govOfficialInfo.charId,govOfficialInfo.officialId)
	
	local officialData = TableMgr:GetGoveOfficialData()
    if officialData[govOfficialInfo.officialId] == nil then
        if not isedit then
            bg_gov_trf.gameObject:SetActive(false)
            return
        end
	end
	bg_gov_trf.gameObject:SetActive(true)

	local edit_btn = bg_gov_trf:Find("btn")
	local check_btn = bg_gov_trf:Find("btn (1)")
	
	if isedit then
		if edit_btn ~= nil then
            edit_btn.gameObject:SetActive(true)
            SetClickCallback(edit_btn.gameObject,function()
                GOV_Main.Show(false,govOfficialInfo.charId,setfinishColseCallback)
            end)
		end
		if check_btn ~= nil then
			check_btn.gameObject:SetActive(false)
		end		
	else
		if edit_btn ~= nil then
			edit_btn.gameObject:SetActive(false)
		end
		if check_btn ~= nil then
            check_btn.gameObject:SetActive(true)
            SetClickCallback(check_btn.gameObject,function()
                GOV_Officialinfo.Show(false,govOfficialInfo.officialId,govOfficialInfo,setfinishColseCallback)
            end)            
		end			
	end
	SetGovNameUI(bg_gov_trf,govOfficialInfo.officialId,govOfficialInfo.guildOfficialId,false)
end

function SetGovInfoUI4OtherInfo(bg_gov_trf,userBaseInfo,setfinishColseCallback)
    SetGovInfoUI(bg_gov_trf,ToGovOfficialInfo4UserBaseInfo(userBaseInfo),setfinishColseCallback)
end

function SetGovInfoUI4MainInfo(bg_gov_trf)
    SetGovInfoUI(bg_gov_trf,ToGovOfficialInfo4MainData())
end


--[[ function CloseGOVUIWhenGovChange(subType)
	local need_close = false
	for i=1,#GovMenus do 
		if Global.GGUIMgr:FindMenu(GovMenus[i]) ~= nil then
			need_close = true;
			break;
		end
	end
	if need_close then
		GUIMgr:CloseAllMenu()
	end
end ]]

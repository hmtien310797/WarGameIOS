module("MailListData", package.seeall)

local eventListener = EventListener()
local TableMgr = Global.GTableMgr
local GUIMgr = Global.GGUIMgr
local needUpdate = false
--MailData repeat
local mailListData = {}
local mailListMsg
local newNotyfyCount = 0


function GetMailPushCount()
	return newNotyfyCount
end

function AddNotifyCount()
	newNotyfyCount = newNotyfyCount + 1
	return GetMailPushCount()
end

function SubNotifyCount()
	newNotyfyCount = math.max(0,newNotyfyCount - 1) 
	return GetMailPushCount()
end

function ClearMailPush()
	newNotyfyCount = 0
	return GetMailPushCount()
end


function NeedUpdate(need)
	needUpdate = need
end

function IsNeedUpdate()
	return needUpdate
end

function GetData()
    return mailListData
end

function SetData(data)
	mailListMsg = data
    --mailListData = data
end

local function NotifyListener()
    eventListener:NotifyListener()
end

function AddListener(listener)
    eventListener:AddListener(listener)
end

function RemoveListener(listener)
    eventListener:RemoveListener(listener)
end

function UpdateData(data , mtype)
	mailListMsg = data
	--[[for i , v in pairs(mailListData) do
		if v.type == mtype then
			print("=delete mail:id"..v.id .. " type:" .. v.type .. " save :".. tostring(v.saved) .. " ctime:" .. v.createtime)
			table.remove(mailListData , i)
		end
	end
	
	for _ , v in ipairs(mailListMsg) do
		table.insert(mailListData , v)
	end ]]
	
	for _, v in ipairs(mailListMsg) do
		local dataIndex = -1
		for i , vv in pairs(mailListData) do
			if v.category == vv.category and v.id == vv.id then
				mailListData[i] = v
				dataIndex = i
			end
		end
		
		if dataIndex < 0 then
			table.insert(mailListData , v)
		end
	end
	SortMailListData(mailListData)
	for _ , v in pairs(mailListData) do
		--print("=====mail:id"..v.id .. " type:" .. v.type .. " save :".. tostring(v.saved) .. " ctime:" .. v.createtime)
	end
	
    NotifyListener()
end

function RequestData(mtype)
	local req = MailMsg_pb.MsgUserMailListRequest()
	req.type = mtype
	--Global.DumpMessage(req , "d:/mailmoba.lua")
	Global.Request(Category_pb.Mail, MailMsg_pb.MailTypeId.MsgUserMailListRequest, req, MailMsg_pb.MsgUserMailListResponse, function(msg)
		--Global.DumpMessage(msg , "d:/mailmoba.lua")
		UpdateData(msg.maillist , mtype)
		NeedUpdate(false)
    end, true)
end

function RequestGuildMobaData() 
	local req = GuildMobaMsg_pb.GuildMobaMailListRequest()
	req.type = MailMsg_pb.MailType_GuildMoba
	--Global.DumpMessage(req , "d:/mailmoba.lua")
	Global.Request(Category_pb.GuildMoba, GuildMobaMsg_pb.GuildMobaTypeId.GuildMobaMailListRequest, req, GuildMobaMsg_pb.GuildMobaMailListResponse, function(msg)
		--Global.DumpMessage(msg , "d:/mailmoba.lua")
		UpdateData(msg.maillist , MailMsg_pb.MailType_GuildMoba)
		NeedUpdate(false)
    end, true)
end

function RequestAllData()
	mailListData = {}
	for i=1 , 4 do
		RequestData(i)
	end
end

function ClearMobaMail()
	if mailListData ~= nil then
		for i=#mailListData , 1 , -1 do
			if mailListData[i].category == MailMsg_pb.MailType_Moba then
				table.remove(mailListData , i)
			end
		end
	end
end

function ClearGuildMobaMail()
	if mailListData ~= nil then
		for i=#mailListData , 1 , -1 do
			if mailListData[i].category == MailMsg_pb.MailType_GuildMoba then
				table.remove(mailListData , i)
			end
		end
	end
end

function GetMailDataByType(mailtype)
	local mailData = nil
	for i , v in pairs(mailListData) do
		if v.category == mailtype and not v.saved then
			if mailData == nil then
				mailData = {}
			end
			table.insert(mailData , v)
		end
	end
	--SortMailListData(mailData)
	return mailData
end

function GetMailDataByTypeWithFlag(mailtype, submailtype)
	local mailData = {}
	for i , v in pairs(mailListData) do
		if submailtype == 0 then
			if v.category == mailtype and not v.saved then
				local maillinfo = {}
				maillinfo.data = v
				maillinfo.flag = false
				table.insert(mailData , maillinfo)
			end
		else
			if v.category == mailtype and not v.saved and v.subcategory == submailtype then
				local maillinfo = {}
				maillinfo.data = v
				maillinfo.flag = false
				table.insert(mailData , maillinfo)
			end
		end
	end
	--SortMailListData(mailData)
	return mailData
end

function GetMailDataById(mailid)
	for _ , v in pairs(mailListData) do
		if v.id == mailid then
			return v
		end
	end
	return nil
end

function UpdateMailStatus(mailid , status)
	for _ , v in pairs(mailListData) do
		if v.id == mailid then
			v.status = status
		end
	end
	--NotifyListener()
end

function DeleteMailList(dellist)
	for _, v in ipairs(dellist) do
		for i , vv in pairs(mailListData) do
			if vv.id == v then
				--mailListData:remove(i)
				table.remove(mailListData , i)
			end
		end
	end
	NotifyListener()
end

function MarkMailList(marklist)
	for _, v in ipairs(marklist) do
		for i , vv in pairs(mailListData) do
			if vv.id == v then
				vv.status = 2 -- enum MailStatus.MailStatus_Readed
			end
		end
	end
	NotifyListener()
end

function GetMailSavedList(mailStatus)
	local mailData = {}
	for i , v in pairs(mailListData) do
		if v.status == mailStatus and v.saved then
			local mdata = {}
			mdata.id = v.id
			table.insert(mailData , mdata)
		end
	end
	return mailData
end

function GetMailListByStatus(mailStatus, mtype, submtype, isSaved)
	local mailData = {}
	for i , v in pairs(mailListData) do
		if submtype == 0 then
			if v.status == mailStatus and v.category == mtype and not v.saved then
				local mdata = {}
				mdata.id = v.id
				table.insert(mailData , mdata)
			end
		else
			if v.status == mailStatus and v.category == mtype and not v.saved and v.subcategory == submtype then
				local mdata = {}
				mdata.id = v.id
				table.insert(mailData , mdata)
			end
		end
	end
	return mailData
end

function GetMailAttachItem(mailid)
	for _, v in ipairs(mailid) do
		for i , vv in pairs(mailListData) do
			if vv.id == v then
				vv.taked = true
				vv.status = 2--MailStatus_Readed
			end
		end
	end
	NotifyListener()
end

function GetSavedNextMail(mailid)
	for i , v in pairs(mailListData) do
		if v.id == mailid then
			local index = i
			while index < (#mailListData) do
				index = index + 1
				local nextm = mailListData[index]
				if nextm.saved then 
					return mailListData[index]
				end
			end
		end
	end
	return nil
end 

function GetSavedPreMail(mailid)
	for i , v in pairs(mailListData) do
		if v.id == mailid then
			local index = i
			while index > 1 do
				index = index - 1
				local prem = mailListData[index]
				if prem.saved then
					return mailListData[index]
				end
			end
		end
	end
	return nil
end

function GetNextMail(mailid)
	for i , v in pairs(mailListData) do
		if v.id == mailid then
			local index = i
			if v.category == MailMsg_pb.MailType_Moba or v.category == MailMsg_pb.MailType_GuildMoba then
				while index < (#mailListData) do
					index = index + 1
					local nextm = mailListData[index]
					if nextm.category == v.category and not nextm.saved then 
						return mailListData[index]
					end
				end
			else
				while index < (#mailListData) do
					index = index + 1
					local nextm = mailListData[index]
					if nextm.category == v.category and not nextm.saved and nextm.subcategory == v.subcategory then 
						return mailListData[index]
					end
				end
			end
		end
	end
	return nil
end

function GetPreMail(mailid)
	for i , v in pairs(mailListData) do
		if v.id == mailid then
			local index = i
			if v.category == MailMsg_pb.MailType_Moba or v.category == MailMsg_pb.MailType_GuildMoba then
				while index > 1 do
					index = index - 1
					local prem = mailListData[index]
					if prem.category == v.category and not prem.saved then
						return mailListData[index]
					end
				end
			else
				while index > 1 do
					index = index - 1
					local prem = mailListData[index]
					if prem.category == v.category and not prem.saved and prem.subcategory == v.subcategory then
						return mailListData[index]
					end
				end
			end
		end
	end
	return nil
end

function GetAllAttachItems(mtype, submtype)
	local allItems = {}
	for i , v in pairs(mailListData) do
		--print("mtype" .. mtype .. "id:" .. v.id .. " type:" .. v.type .. " taked :" .. tostring(v.taked))
		if submtype == 0 then
			if v.category == mtype and not v.taked  and v.hasattach and not v.saved then
				local items = {}
				items.id = v.id
				items.data = v.attachList
				table.insert(allItems , items)
				--print("id:" .. v.id .. " type:" .. v.type .. " taked :" .. tostring(v.taked))
			end
		else
			if v.category == mtype and not v.taked  and v.hasattach and not v.saved and v.subcategory == submtype then
				local items = {}
				items.id = v.id
				items.data = v.attachList
				table.insert(allItems , items)
				--print("id:" .. v.id .. " type:" .. v.type .. " taked :" .. tostring(v.taked))
			end
		end
	end
	return allItems
end

function GetAllSavedAttachItems()
	local allItems = {}
	for i , v in pairs(mailListData) do
		if not v.taked  and v.hasattach and v.saved then
			local items = {}
			items.id = v.id
			items.data = v.attachList
			table.insert(allItems , items)
		end
	end
	return allItems
end

function GetSavedMail()
	local allItems = nil
	for i , v in pairs(mailListData) do
		if v.saved == true then
			if allItems == nil then
				allItems = {}
			end
			table.insert(allItems  ,v)
		end
	end
	--SortMailListData(allItems)
	return allItems
end

function GetSavedMailByDefaultFlag()
	local allItems = nil
	for i , v in pairs(mailListData) do
		if v.saved == true then
			if allItems == nil then
				allItems = {}
			end
			local mailinfo = {}
			mailinfo.data = v
			mailinfo.flag = false
			table.insert(allItems  ,mailinfo)
		end
	end
	--SortMailListData(allItems)
	return allItems
end

function CancelSaveMails(maillist)
	for _, v in ipairs(maillist) do
		for _ , vv in pairs(mailListData) do
			if vv.id == v then
				vv.saved = false
			end
		end
	end
	NotifyListener()
end

function SaveMails(maillist)
	for _, v in ipairs(maillist) do
		for _ , vv in pairs(mailListData) do
			if vv.id == v then
				vv.saved = true
			end
		end
	end
	NotifyListener()
end

function GetNewMailCount(mtype)
	local count = 0
	for _ , v in pairs(mailListData) do
		if v.status == 1--[[MailStatus_New]] and v.category == mtype and not v.saved then
			count = count + 1
		end
	end
	return count
end

function GetNewMailTypeCount(mtype, submtype)
	local count = false
	for _ , v in pairs(mailListData) do
		if v.status == 1--[[MailStatus_New]] and v.category == mtype and not v.saved and v.subcategory == submtype then
			count = true
			break
		end
	end
	return count
end

function GetNewSavedMailCount()
	local count = 0
	for _ , v in pairs(mailListData) do
		if v.status == 1--[[MailStatus_New]] and v.saved == true then
			count = count + 1
		end
	end
	return count
end

function GetFirstNewMail()
	for _ , v in pairs(mailListData) do
		if v.status == 1 then
			if v.saved then
				return 4
			else
				return v.category
			end
		end
	end
	return 0
end

function HaveNewMail()
	for _ , v in pairs(mailListData) do
		if v.status == 1 then
			return true
		end
	end
	return false
end

function SortMailListData(mailtable)
	if mailtable ~= nil then
		table.sort(mailtable, function(t1, t2)
			if t1.createtime == t2.createtime then
				return t1.id > t2.id
			else
				return t1.createtime > t2.createtime
			end
		end)
	end
end

function HasNewNum()
	return (GetNewMailCount(MailMsg_pb.MailType_System) + 
			GetNewMailCount(MailMsg_pb.MailType_User) + 
			GetNewMailCount(MailMsg_pb.MailType_Report) + 
			GetNewSavedMailCount())
			--GetNewMailCount(MailMsg_pb.MailType_Moba))
end

function HasNotice()
	return HasNewNum() > 0 
end

function HasMobaNotice()
	return GetNewMailCount(MailMsg_pb.MailType_Moba) > 0 
end

function HasGuildMobaNotice()
	return GetNewMailCount(MailMsg_pb.MailType_GuildMoba) > 0 
end

function GetAttachList(id)
	local readMailData = MailListData.GetMailDataById(id)
	local itemList = {}
	for _ , v in ipairs(readMailData.misc.attachList) do
		
		local key = "0" .. v.type .. v.id
		--print(key)
		if itemList[key] == nil then
			itemList[key] = {}
			itemList[key].data = v
			itemList[key].count = 1
		else
			itemList[key].count = itemList[key].count + 1
		end
	end
	return itemList
end

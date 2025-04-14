module("MobaRank",package.seeall)

local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local ResourceLibrary = Global.GResourceLibrary
local SetClickCallback = UIUtil.SetClickCallback
local NGUITools = NGUITools
local GameObject = UnityEngine.GameObject
local FloatText = FloatText
local String = System.String

local endlesslist
local _ui
local showtype
local ranktype

local closeCallback

local UserTitle = {"ui_moba_121","ui_moba_122","ui_moba_123"}
local GuildTitle = {"rank_ui8","rank_ui13","rank_ui9","rank_ui17"}

function SetCloseCallback(_closeCallback)
	closeCallback = _closeCallback
end

local function CloseSelf()
	if closeCallback ~= nil then
		closeCallback()
	end

	Global.CloseUI(_M)
end

local function RemoveChildren()
	local childCount = _ui.container2.mid02_grid.transform.childCount
	for i = 0, childCount - 1 do
        GameObject.Destroy(_ui.container2.mid02_grid.transform:GetChild(i).gameObject)
    end
    childCount = _ui.container2.mid02_mygrid.transform.childCount
	for i = 0, childCount - 1 do
        GameObject.Destroy(_ui.container2.mid02_mygrid.transform:GetChild(i).gameObject)
    end
    childCount = _ui.container2.mid03_grid.transform.childCount
	for i = 0, childCount - 1 do
        GameObject.Destroy(_ui.container2.mid03_grid.transform:GetChild(i).gameObject)
    end
end

local function ShowMainPage()
	_ui.container1.container:SetActive(true)
	_ui.container2.container:SetActive(false)
	_ui.container2.mid02_none:SetActive(false)
	_ui.container2.mid02_notinrank:SetActive(false)
	_ui.container2.mid02_notinunion:SetActive(false)
	RemoveChildren()
end

local function Show100Page()
	_ui.container1.container:SetActive(false)
	_ui.container2.container:SetActive(true)
end

local function ShowHelp()
	_ui.instruction.container:SetActive(true)
end

local function HideHelp()
	_ui.instruction.container:SetActive(false)
end

local function MakeScoreString(value)
	local s = tostring(value)
	local n = math.floor((#s - 1) / 3)
	for i = n, 1, -1 do
		s = string.sub(s, 0, -3 * i - 1) .. "," .. string.sub(s, -3 * i)
	end
	return s
end

local function UserRankOverviewRequest(callback)
	local childCount = _ui.container1.content1_grid.transform.childCount
	for i = 0, childCount - 1 do
        GameObject.Destroy(_ui.container1.content1_grid.transform:GetChild(i).gameObject)
    end
	local req = MobaMsg_pb.MsgMobaRankOverviewRequest()
    Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaRankOverviewRequest, req, MobaMsg_pb.MsgMobaRankOverviewResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
            	callback(msg.allList)
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

local function GuildRankOverviewRequest(callback)
	local childCount = _ui.container1.content2_grid.transform.childCount
	for i = 0, childCount - 1 do
        GameObject.Destroy(_ui.container1.content2_grid.transform:GetChild(i).gameObject)
    end
	local req = ClientMsg_pb.MsgGuildRankOverviewRequest()
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGuildRankOverviewRequest, req, ClientMsg_pb.MsgGuildRankOverviewResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
            	callback(msg.allList)
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

local function UserRankListRequest(rankType, callback)
	local req = MobaMsg_pb.MsgMobaRankListRequest()
	req.rankType = rankType
    Global.Request(Category_pb.Moba, MobaMsg_pb.MobaTypeId.MsgMobaRankListRequest, req, MobaMsg_pb.MsgMobaRankListResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
            	callback(msg)
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

function GuildRankListRequest(rankType, callback)
	local req = ClientMsg_pb.MsgGuildRankListRequest()
	req.rankType = rankType
    Global.Request(Category_pb.Client, ClientMsg_pb.ClientTypeId.MsgGuildRankListRequest, req, ClientMsg_pb.MsgGuildRankListResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            if callback ~= nil then
            	callback(msg)
            end
        else
        	Global.ShowError(msg.code)
        end
    end, false)
end

local function SetSearch(data, isGuild, noneText)
    _ui.searchInput.value = ""
    _ui.nextButton.gameObject:SetActive(false)
    SetClickCallback(_ui.searchButton.gameObject, function()
        local searchList = {}
        local inputValue = _ui.searchInput.value
        if #inputValue > 0 then
            for i, v in ipairs(data.rankList) do
                local searchText
                if isGuild then
                    searchText = v.guildBanner .. v.guildName
                else
                    searchText = v.name
                end
                if string.find(searchText, inputValue) ~= nil then
                    table.insert(searchList, i)
                end
            end
            local searchCount = #searchList
            _ui.nextButton.gameObject:SetActive(searchCount > 1)
            if searchCount == 0 then
                FloatText.Show(TextMgr:GetText(noneText))
            else
                local searchFunc = coroutine.wrap(function()
                    for _, v in ipairs(searchList) do
                        coroutine.yield(v)
                    end
                end)
                _ui.searchRank = searchFunc()
                endlesslist:MoveTo(_ui.searchRank)
                if searchCount > 1 then
                    SetClickCallback(_ui.nextButton.gameObject, function()
                        _ui.searchRank = searchFunc()
                        if _ui.searchRank ~= nil then
                            endlesslist:MoveTo(_ui.searchRank)
                        else
                            _ui.nextButton.gameObject:SetActive(false)
                        end
                    end)
                end
            end
        else
            _ui.nextButton.gameObject:SetActive(false)
            local myRank = data.myRank.rank
            if myRank ~= nil and myRank > 0 and myRank <= 100 then
                _ui.searchRank = data.myRank.rank
                endlesslist:MoveTo(_ui.searchRank)
            else
                endlesslist:MoveTo(1)
            end
        end
    end)
end

local function MakeUserEndlessList(scroll, data, pos, rankType)
    _ui.searchRank = data.myRank.rank
	endlesslist = EndlessList(scroll, pos.x, pos.y)
	endlesslist:SetItem(_ui.bg2, #data.rankList, function(prefab, index)
		local rankdata = data.rankList[index]
		prefab.transform:Find("no.1").gameObject:SetActive(index == 1)
		prefab.transform:Find("no.2").gameObject:SetActive(index == 2)
		prefab.transform:Find("no.3").gameObject:SetActive(index == 3)
		prefab.transform:Find("no.4").gameObject:SetActive(index >= 4)
		prefab.transform:Find("no.4"):GetComponent("UILabel").text = index
		prefab.transform:Find("name"):GetComponent("UILabel").text = "[EFCD61]" .. (String.IsNullOrEmpty(rankdata.guildBanner) and "[---]" or ("[" .. rankdata.guildBanner .. "]")) .. "[-]" .. rankdata.name
		prefab.transform:Find("Texture"):GetComponent("UITexture").mainTexture = UIUtil.GetNationalFlagTexture(rankdata.nationality)
		local gov =prefab.transform:Find("bg_gov")
		if gov ~= nil then
			GOV_Util.SetGovNameUI(gov,rankdata.officialId,rankdata.guildOfficialId,true,rankdata.militaryRankId)
		end
		prefab.transform:Find("number"):GetComponent("UILabel").text = rankType == 3 and TextMgr:GetText(TableMgr:GetMobaRankDataByID(rankdata.score).RankName) or MakeScoreString(rankdata.score)
		local back = prefab.transform:Find("back")
		back:GetComponent("UISprite").spriteName = "bg_light"
		if index == _ui.searchRank then
			back.gameObject:SetActive(true)
			back:GetComponent("UISprite").spriteName = "ranking_my"
		elseif index % 2 ~= 0 then
			back.gameObject:SetActive(false)
		else
			back.gameObject:SetActive(true)
		end
	end)
	endlesslist:SetClickCallback(function(index)
		local rankdata = data.rankList[index]
		OtherInfo.RequestShow(rankdata.charId)
	end)
	coroutine.start(function()
		coroutine.step()
		endlesslist:MoveTo(data.myRank.rank <= 100 and data.myRank.rank or 1)
	end)

    SetSearch(data, false, Text.rank_29)
end

local function MakeUserRank(data, ismy, rankType)
	local item = NGUITools.AddChild(_ui.container2.mid02_mygrid.gameObject, _ui.bg3)
	item.transform:Find("name"):GetComponent("UILabel").text = "[EFCD61]" .. (String.IsNullOrEmpty(data.guildBanner) and "[---]" or ("[" .. data.guildBanner .. "]")) .. "[-]" .. data.name
	local gov =item.transform:Find("bg_gov")
	if gov ~= nil then
		GOV_Util.SetGovNameUI(gov,data.officialId,data.guildOfficialId,true,data.militaryRankId)
	end
	item.transform:Find("number"):GetComponent("UILabel").text = rankType == 3 and TextMgr:GetText(TableMgr:GetMobaRankDataByID(data.score).RankName) or MakeScoreString(data.score)
	item.transform:Find("no"):GetComponent("UILabel").text = data.rank
	item.transform:Find("back").gameObject:SetActive(ismy)
	item.transform:Find("Texture"):GetComponent("UITexture").mainTexture = UIUtil.GetNationalFlagTexture(data.nationality)
	SetClickCallback(item, function()
		OtherInfo.RequestShow(data.charId)
	end)
end

local function MakeGuildEndlessList(scroll, data, pos)
    _ui.searchRank = data.myRank.rank
	endlesslist = EndlessList(scroll, pos.x, pos.y)
	endlesslist:SetItem(_ui.bg2, #data.rankList, function(prefab, index)
		local rankdata = data.rankList[index]
		prefab.transform:Find("no.1").gameObject:SetActive(index == 1)
		prefab.transform:Find("no.2").gameObject:SetActive(index == 2)
		prefab.transform:Find("no.3").gameObject:SetActive(index == 3)
		prefab.transform:Find("no.4").gameObject:SetActive(index >= 4)
		prefab.transform:Find("no.4"):GetComponent("UILabel").text = index
		prefab.transform:Find("name"):GetComponent("UILabel").text = "[EFCD61]" .. (String.IsNullOrEmpty(rankdata.guildBanner) and "[---]" or ("[" .. rankdata.guildBanner .. "]")) .. "[-]" .. rankdata.guildName
		prefab.transform:Find("Texture"):GetComponent("UITexture").mainTexture = UIUtil.GetNationalFlagTexture(rankdata.guildLeaderNationality)
		local ucard = prefab.transform:Find("icon_unioncard")
		ucard.gameObject:SetActive(rankdata.guildMonthCardBuyed)
		SetClickCallback(ucard.gameObject , function()
			FloatText.Show(TextMgr:GetText("Union_Mcard_ui8") , Color.green)
		end)
		
		local gov =prefab.transform:Find("bg_gov")
		if gov ~= nil then
			GOV_Util.SetGovNameUI(gov,rankdata.officialId,rankdata.fromGuildOfficialId,true,rankdata.militaryRankId)
		end		
		prefab.transform:Find("number"):GetComponent("UILabel").text = MakeScoreString(rankdata.score)
		local back = prefab.transform:Find("back")
		back:GetComponent("UISprite").spriteName = "bg_light"
		if index == _ui.searchRank then
			back.gameObject:SetActive(true)
			back:GetComponent("UISprite").spriteName = "ranking_my"
		elseif index % 2 ~= 0 then
			back.gameObject:SetActive(false)
		else
			back.gameObject:SetActive(true)
		end
		endlesslist:SetClickCallback(function(index)
			local rankdata = data.rankList[index]
			UnionPubinfo.RequestShow(rankdata.guildId)
		end)
	end)
	coroutine.start(function()
		coroutine.step()
		endlesslist:MoveTo(data.myRank.rank)
	end)

    SetSearch(data, true, Text.rank_28)
end

local function MakeGuildRank(data, ismy)
	local item = NGUITools.AddChild(_ui.container2.mid02_mygrid.gameObject, _ui.bg3)
	item.transform:Find("name"):GetComponent("UILabel").text = "[EFCD61]" .. (String.IsNullOrEmpty(data.guildBanner) and "[---]" or ("[" .. data.guildBanner .. "]")) .. "[-]" .. data.guildName
	item.transform:Find("number"):GetComponent("UILabel").text = MakeScoreString(data.score)
	item.transform:Find("no"):GetComponent("UILabel").text = data.rank
	item.transform:Find("back").gameObject:SetActive(ismy)
	item.transform:Find("Texture"):GetComponent("UITexture").mainTexture = UIUtil.GetNationalFlagTexture(data.guildLeaderNationality)
end

local function UpdateUserRankList(data)
	Show100Page()
	_ui.container2.title.text = TextMgr:GetText("rank_ui2")
	_ui.container2.combat1.text = TextMgr:GetText(UserTitle[data.rankType])
	_ui.container2.combat2.text = TextMgr:GetText(UserTitle[data.rankType])
	_ui.container2.name1.text = TextMgr:GetText("rank_ui20")
	_ui.container2.name2.text = TextMgr:GetText("rank_ui20")
	_ui.container2.title_bottom.text = TextMgr:GetText("rank_ui25")
	if data.myRank == nil or data.myRank.rank == 0 or data.myRank.rank > 100 then
		_ui.container2.mid02:SetActive(true)
		_ui.container2.mid03:SetActive(false)
		if data.myRank == nil or data.myRank.rank == 0 then
			_ui.container2.mid02_none:SetActive(true)
			_ui.container2.mid02_notinrank:SetActive(true)
		else
			if data.beforeRank ~= nil and data.beforeRank.rank ~= 0 then
				MakeUserRank(data.beforeRank, false, data.rankType)
			end
			MakeUserRank(data.myRank, true, data.rankType)
			if data.afterRank ~= nil and data.afterRank.rank ~= 0 then
				MakeUserRank(data.afterRank, false, data.rankType)
			end
			_ui.container2.mid02_mygrid:Reposition()
		end
		MakeUserEndlessList(_ui.container2.mid02_scroll, data, _ui.container2.mid02_scroll_pos, data.rankType)
	else
		_ui.container2.mid02:SetActive(false)
		_ui.container2.mid03:SetActive(true)
		MakeUserEndlessList(_ui.container2.mid03_scroll, data, _ui.container2.mid03_scroll_pos, data.rankType)
	end
end

local function UpdateGuildRankList(data)
	Show100Page()
	_ui.container2.title.text = TextMgr:GetText("rank_ui3")
	_ui.container2.combat1.text = TextMgr:GetText(GuildTitle[data.rankType])
	_ui.container2.combat2.text = TextMgr:GetText(GuildTitle[data.rankType])
	_ui.container2.name1.text = TextMgr:GetText("rank_ui26")
	_ui.container2.name2.text = TextMgr:GetText("rank_ui26")
	_ui.container2.title_bottom.text = TextMgr:GetText("rank_ui27")
	if data.myRank == nil or data.myRank.rank == 0 or data.myRank.rank > 100 then
		_ui.container2.mid02:SetActive(true)
		_ui.container2.mid03:SetActive(false)
		if data.myRank == nil or data.myRank.rank == 0 then
			_ui.container2.mid02_none:SetActive(true)
			if not UnionInfoData.HasUnion() then
				_ui.container2.mid02_notinunion:SetActive(true)
			else
				_ui.container2.mid02_notinrank:SetActive(true)
			end
		else
			if data.beforeRank ~= nil and data.beforeRank.rank ~= 0 then
				MakeGuildRank(data.beforeRank, false)
			end
			MakeGuildRank(data.myRank, true)
			if data.afterRank ~= nil and data.afterRank.rank ~= 0 then
				MakeGuildRank(data.afterRank, false)
			end
		end
		MakeGuildEndlessList(_ui.container2.mid02_scroll, data, _ui.container2.mid02_scroll_pos)
	else
		_ui.container2.mid02:SetActive(false)
		_ui.container2.mid03:SetActive(true)
		MakeGuildEndlessList(_ui.container2.mid03_scroll, data, _ui.container2.mid03_scroll_pos)
	end
end

local function UpdateUserRankOverview(data)
	for i, v in ipairs(data) do
		local item = NGUITools.AddChild(_ui.container1.content1_grid.gameObject, _ui.bg1).transform
		item:Find("title"):GetComponent("UILabel").text = TextMgr:GetText(UserTitle[v.rankType])
		SetClickCallback(item:Find("more").gameObject, function()
			UserRankListRequest(v.rankType, function(msg)
				UpdateUserRankList(msg)
			end)
		end)
		table.sort(v.rankList, function(a, b) return a.rank < b.rank end)
		for j, vv in ipairs(v.rankList) do
			item:Find(String.Format("Container_{0}/name", j)):GetComponent("UILabel").text = "[EFCD61]" .. (String.IsNullOrEmpty(vv.guildBanner) and "[---]" or ("[" .. vv.guildBanner .. "]")) .. "[-]" .. vv.name
			local gov =item:Find(String.Format("Container_{0}/bg_gov", j))
			if gov ~= nil then
				GOV_Util.SetGovNameUI(gov,vv.officialId,vv.guildOfficialId,true,vv.militaryRankId)
			end
			item:Find(String.Format("Container_{0}/number", j)):GetComponent("UILabel").text = v.rankType == 3 and TextMgr:GetText(TableMgr:GetMobaRankDataByID(vv.score).RankName) or MakeScoreString(vv.score)
			item:Find(String.Format("Container_{0}/Texture", j)):GetComponent("UITexture").mainTexture = UIUtil.GetNationalFlagTexture(vv.nationality)
			item:Find(String.Format("Container_{0}/Texture", j)).gameObject:SetActive(true)
			SetClickCallback(item:Find(String.Format("Container_{0}", j)).gameObject, function()
				OtherInfo.RequestShow(vv.charId)
			end)
		end
	end
	_ui.container1.content1_grid:Reposition()
	_ui.container1.content1_scroll:ResetPosition()
end

local function UpdateGuildRankOverview(data)
	for i, v in ipairs(data) do
		local item = NGUITools.AddChild(_ui.container1.content2_grid.gameObject, _ui.bg1).transform
		item:Find("title"):GetComponent("UILabel").text = TextMgr:GetText(GuildTitle[v.rankType])
		SetClickCallback(item:Find("more").gameObject, function()
			GuildRankListRequest(v.rankType, function(msg)
				Global.DumpMessage(msg , "d:/union_rank.lua")
				UpdateGuildRankList(msg)
			end)
		end)
		table.sort(v.rankList, function(a, b) return a.rank < b.rank end)
		for j, vv in ipairs(v.rankList) do
			item:Find(String.Format("Container_{0}/name", j)):GetComponent("UILabel").text = "[EFCD61]" .. (String.IsNullOrEmpty(vv.guildBanner) and "[---]" or ("[" .. vv.guildBanner .. "]")) .. "[-]" .. vv.guildName
			item:Find(String.Format("Container_{0}/number", j)):GetComponent("UILabel").text = MakeScoreString(vv.score)
			item:Find(String.Format("Container_{0}/Texture", j)):GetComponent("UITexture").mainTexture = UIUtil.GetNationalFlagTexture(vv.guildLeaderNationality)
			item:Find(String.Format("Container_{0}/Texture", j)).gameObject:SetActive(true)
			local ucard = item:Find(String.Format("Container_{0}/icon_unioncard", j)).gameObject
			ucard:SetActive(vv.guildMonthCardBuyed)
			SetClickCallback(item:Find(String.Format("Container_{0}", j)).gameObject, function()
				UnionPubinfo.RequestShow(vv.guildId)
			end)
			SetClickCallback(ucard , function()
				FloatText.Show(TextMgr:GetText("Union_Mcard_ui8") , Color.green)
			end)
		end
	end
	_ui.container1.content2_grid:Reposition()
	_ui.container1.content2_scroll:ResetPosition()
end

function Awake()
	_ui = {}
	_ui.container1 = {}
	_ui.container1.container = transform:Find("Container_1").gameObject
	_ui.container1.btn_close = transform:Find("Container_1/bg_top/btn_close").gameObject
	_ui.container1.btn_rankinfo = transform:Find("Container_1/mid01/rank_infor").gameObject
	_ui.container1.content1_scroll = transform:Find("Container_1/mid01/content 1/Scroll View"):GetComponent("UIScrollView")
	_ui.container1.content1_grid = transform:Find("Container_1/mid01/content 1/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.container1.content2_scroll = transform:Find("Container_1/mid01/content 2/Scroll View"):GetComponent("UIScrollView")
	_ui.container1.content2_grid = transform:Find("Container_1/mid01/content 2/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.container1.btn_page1 = transform:Find("Container_1/mid01/page1").gameObject
	_ui.container1.btn_page2 = transform:Find("Container_1/mid01/page2").gameObject
	_ui.container2 = {}
	_ui.container2.container = transform:Find("Container_2").gameObject
	_ui.container2.btn_close = transform:Find("Container_2/bg_top/btn_close").gameObject
	_ui.container2.title = transform:Find("Container_2/bg_top/bg_title_left/title"):GetComponent("UILabel")
	_ui.container2.combat1 = transform:Find("Container_2/mid02/title/combat"):GetComponent("UILabel")
	_ui.container2.combat2 = transform:Find("Container_2/mid03/title/combat"):GetComponent("UILabel")
	_ui.container2.name1 = transform:Find("Container_2/mid02/title/name"):GetComponent("UILabel")
	_ui.container2.name2 = transform:Find("Container_2/mid03/title/name"):GetComponent("UILabel")
	_ui.container2.title_bottom = transform:Find("Container_2/mid02/myrank/title"):GetComponent("UILabel")
	_ui.container2.mid02 = transform:Find("Container_2/mid02").gameObject
	_ui.container2.mid02_scroll = transform:Find("Container_2/mid02/Scroll View"):GetComponent("UIScrollView")
	_ui.container2.mid02_scroll_pos = _ui.container2.mid02_scroll.transform.localPosition
	_ui.container2.mid02_grid = transform:Find("Container_2/mid02/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.container2.mid02_mygrid = transform:Find("Container_2/mid02/myrank/Grid"):GetComponent("UIGrid")
	_ui.container2.mid02_none = transform:Find("Container_2/mid02/myrank/none").gameObject
	_ui.container2.mid02_notinrank = transform:Find("Container_2/mid02/myrank/none/Label01").gameObject
	_ui.container2.mid02_notinunion = transform:Find("Container_2/mid02/myrank/none/Label02").gameObject
	_ui.container2.mid03 = transform:Find("Container_2/mid03").gameObject
	_ui.container2.mid03_scroll = transform:Find("Container_2/mid03/Scroll View"):GetComponent("UIScrollView")
	_ui.container2.mid03_scroll_pos = _ui.container2.mid03_scroll.transform.localPosition
	_ui.container2.mid03_grid = transform:Find("Container_2/mid03/Scroll View/Grid"):GetComponent("UIGrid")
	_ui.instruction = {}
	_ui.instruction.container = transform:Find("instruction").gameObject
	_ui.instruction.btn_close = transform:Find("instruction/back/close_button").gameObject
	_ui.instruction.mask = transform:Find("instruction/mask").gameObject
	_ui.bg1 = transform:Find("bg1").gameObject
	_ui.bg2 = transform:Find("bg2").gameObject
	_ui.bg3 = transform:Find("bg3").gameObject
	_ui.searchInput = transform:Find("Container_2/search"):GetComponent("UIInput")
	_ui.searchButton = transform:Find("Container_2/search/Sprite"):GetComponent("UIButton")
	_ui.nextButton = transform:Find("Container_2/search/button"):GetComponent("UIButton")
	transform:Find("Container_1/mid01/page1/selected effect/text (1)"):GetComponent("UILabel").text = TextMgr:GetText("ui_moba_119")
	transform:Find("Container_1/mid01/page1/selected effect/text (1)"):GetComponent("LocalizeEx").enabled = false
	transform:Find("Container_1/mid01/page2/selected effect/text (1)"):GetComponent("UILabel").text = TextMgr:GetText("ui_moba_120")
	transform:Find("Container_1/mid01/page2/selected effect/text (1)"):GetComponent("LocalizeEx").enabled = false
	transform:Find("Container_1/mid01/page2").gameObject:SetActive(false)
	transform:Find("instruction/mid/Label"):GetComponent("UILabel").text = TextMgr:GetText("ui_moba_124")
	transform:Find("instruction/mid/Label (1)"):GetComponent("UILabel").text = "" --TextMgr:GetText("ui_moba_125")
	transform:Find("instruction/mid/Label"):GetComponent("LocalizeEx").enabled = false
	transform:Find("instruction/mid/Label (1)"):GetComponent("LocalizeEx").enabled = false
end

function Start()
	SetClickCallback(_ui.container1.container, CloseSelf)
	SetClickCallback(_ui.container1.btn_close, CloseSelf)
	SetClickCallback(_ui.container2.container, ShowMainPage)
	SetClickCallback(_ui.container2.btn_close, ShowMainPage)
	SetClickCallback(_ui.container1.btn_rankinfo, ShowHelp)
	SetClickCallback(_ui.instruction.container, HideHelp)
	SetClickCallback(_ui.instruction.btn_close, HideHelp)
	SetClickCallback(_ui.instruction.mask, HideHelp)
	SetClickCallback(_ui.container1.btn_page1, function() UserRankOverviewRequest(UpdateUserRankOverview) end)
	SetClickCallback(_ui.container1.btn_page2, function() GuildRankOverviewRequest(UpdateGuildRankOverview) end)
	
	if showtype ~= nil and ranktype ~= nil then
		Show100Page()
		SetClickCallback(_ui.container2.container, CloseSelf)
		SetClickCallback(_ui.container2.btn_close, CloseSelf)
		if showtype == 1 then
			UserRankListRequest(ranktype, function(msg)
				UpdateUserRankList(msg)
			end)
		else
			GuildRankListRequest(ranktype, function(msg)
				Global.DumpMessage(msg , "d:/union_rank.lua")
				UpdateGuildRankList(msg)
			end)
		end
	else
		ShowMainPage()
		UserRankOverviewRequest(UpdateUserRankOverview)
	end
end

function Close()
	_ui = nil
	endlesslist = nil
	showtype = nil
	ranktype = nil
	closeCallback = nil
end

function Show(_showtype, _ranktype)
	showtype = _showtype
	ranktype = _ranktype
	Global.OpenUI(_M)
end

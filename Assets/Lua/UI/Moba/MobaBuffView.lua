module("MobaBuffView", package.seeall)
local GUIMgr = Global.GGUIMgr
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local AudioMgr = Global.GAudioMgr
local ResourceLibrary = Global.GResourceLibrary
local GameObject = UnityEngine.GameObject
local GameTime = Serclimax.GameTime
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate
local Format = System.String.Format
local SetClickCallback = UIUtil.SetClickCallback

local _ui
local timer = 0

function Hide()
    Global.CloseUI(_M)
end

function CloseAll()
    if _ui ~= nil then
      Hide()
    end
end


function Awake()
   _ui = {}
   _ui.closeBtn = transform:Find("BUFF/Container/bg_frane/bg_top/btn_close")
   SetClickCallback(_ui.closeBtn.gameObject , Hide)
   _ui.bg = transform:Find("mask")
   SetClickCallback(_ui.bg.gameObject , Hide)
   
   _ui.buffitemPrefab = transform:Find("BUFF/buffInfo")
   _ui.buffGrid = transform:Find("BUFF/Container/bg_frane/Scroll View/Grid"):GetComponent("UIGrid")
end

function Close()
   
    _ui = nil
end

function Show()
    Global.OpenUI(_M)
	LoadUI()
end

function LoadUI()
	local bufflist = MobaBuffData.GetData()
	local activeCount = bufflist and #bufflist or 0
	local childCound = _ui.buffGrid.transform.childCount
	if _ui ~= nil then	
		for i = 1 , activeCount do
			local v = bufflist[i]
			local baseData = TableMgr:GetSlgBuffData(v.buffId)
			local item = nil
			if i <= childCound then
				item = _ui.buffGrid.transform:GetChild(i - 1).transform
				item.gameObject:SetActive(true)
				item:Find("bg_list/bg_icon/Sprite"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", baseData.icon)
			else
				item = NGUITools.AddChild(_ui.buffGrid.gameObject ,_ui.buffitemPrefab.gameObject ).transform
				item:Find("bg_list/bg_icon/Sprite"):GetComponent("UITexture").mainTexture = ResourceLibrary:GetIcon("Item/", baseData.icon)
			end
			item:Find("bg_list/active").gameObject:SetActive(false)
			item:Find("bg_list/button").gameObject:SetActive(false)
			item:Find("bg_list/bg_top/text_type"):GetComponent("UILabel").text = TextMgr:GetText(baseData.title)
			
			--[[
			local buffdes = ""
			local buff_values = MilitaryRank.Moba_GetEffectDataToBuffValues(baseData.Effect)
			if buff_values ~= nil then
				for i =1,#buff_values do
					local str = buff_values[i].value
					buffdes = buffdes .. TextMgr:GetText(buff_values[i].buff_str)  .. " : " .. str
				end
			end
			item:Find("bg_list/text_mid"):GetComponent("UILabel").text = buffdes
			]]
			item:Find("bg_list/text_mid"):GetComponent("UILabel").text = TextMgr:GetText(baseData.description)
		end
		
        local skinInfoMsg = MainData.GetData().skin
        local skinList = {}
        local skinsMsg = skinInfoMsg.skins
        for _, v in ipairs(skinsMsg) do
            if not Skin.IsDefaultSkin(v.id) then
                table.insert(skinList, {data = tableData_tSkin.data[v.id], msg = v, itemDataList = Skin.GetItemDataList(v.id)})
            end
        end

        local skinGrid = _ui.buffGrid
        local skinPrefab = _ui.buffitemPrefab.gameObject
        local skinIndex = activeCount + 1
        for i, v in ipairs(skinList) do
            local skinTransform
            if skinIndex > skinGrid.transform.childCount then
                skinTransform = NGUITools.AddChild(skinGrid.gameObject, skinPrefab).transform
            else
                skinTransform = skinGrid.transform:GetChild(skinIndex - 1)
            end
            local skin = v
            local itemData = skin.itemDataList[1]
            print("skin id:", skin.data.id)
            local nameLabel = skinTransform:Find("bg_list/bg_top/text_type"):GetComponent("UILabel")
            local iconTexture = skinTransform:Find("bg_list/bg_icon/Sprite"):GetComponent("UITexture")
            local attrLabel = skinTransform:Find("bg_list/text_mid"):GetComponent("UILabel")
            nameLabel.text = TextMgr:GetText(itemData.name)
            iconTexture.mainTexture = ResourceLibrary:GetIcon("Icon/WorldMap/", itemData.icon)
            skinTransform:Find("bg_list/active").gameObject:SetActive(false)
            skinTransform:Find("bg_list/button").gameObject:SetActive(false)
            --[[
            skinTransform:Find("bg_list/btn_use").gameObject:SetActive(false)
            skinTransform:Find("bg_list/bg_top/num").gameObject:SetActive(false)
            skinTransform:Find("bg_list/active").gameObject:SetActive(false)
            --]]
            skinTransform.gameObject:SetActive(true)

            local attrText = ""
            if skin.data.SkinAttribute ~= "" then
                for vv in string.gsplit(skin.data.SkinAttribute, ";") do
                    local attrList = string.split(vv, ",")
                    local needData = TableMgr:GetNeedTextDataByAddition(tonumber(attrList[1]), tonumber(attrList[2]))
                    attrText = attrText .. TextMgr:GetText(needData.unlockedText) .. Global.GetHeroAttrValueString(needData.additionAttr, tonumber(attrList[3]))
                end
            end
            attrLabel.text = attrText
            skinIndex = skinIndex + 1
        end
		for i = activeCount + #skinList + 1 , childCound do
			_ui.buffGrid.transform:GetChild(i - 1).gameObject:SetActive(false)
		end
		_ui.buffGrid:Reposition()
	end
end

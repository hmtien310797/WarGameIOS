module("Notice", package.seeall)
local GUIMgr = Global.GGUIMgr.Instance
local TableMgr = Global.GTableMgr
local TextMgr = Global.GTextMgr
local SetClickCallback = UIUtil.SetClickCallback
local AddDelegate = UIUtil.AddDelegate
local RemoveDelegate = UIUtil.RemoveDelegate

local _container
local _close
local _waiting
local _scrollview
local _table
local _itemprefab

local _version
local _url
local _urlCoroutines

local baselength = 63

local function CloseCallback()
	if _urlCoroutines ~= nil then
		for i, v in ipairs(_urlCoroutines) do
			if v ~= nil then
				coroutine.stop(v)
			end
		end
	end
	Global.CloseUI(_M)
end

local function OnUICameraPress(go, pressed)
	if not pressed then
		return
	end
	local lab = go:GetComponent("UILabel")
	if lab ~= nil then
		local laburl = lab:GetUrlAtPosition(UICamera.lastWorldPosition)
		if not System.String.IsNullOrEmpty(laburl) then
			UnityEngine.Application.OpenURL(laburl)
		end
	end
end

function Awake()
	_container = transform:Find("Container").gameObject
	_close = transform:Find("Container/bg_frane/bg_top/btn_close").gameObject
	_waiting = transform:Find("Waiting").gameObject
	_scrollview = transform:Find("Container/bg_frane/Scroll View"):GetComponent("UIScrollView")
	_table = transform:Find("Container/bg_frane/Scroll View/Table"):GetComponent("UITable")
	_itemprefab = transform:Find("ItemInfo").gameObject
	AddDelegate(UICamera, "onPress", OnUICameraPress)
end

function Start()
	_urlCoroutines = {}
	_waiting:SetActive(true)
	SetClickCallback(_container, function() 
		CloseCallback()
	end)
	SetClickCallback(_close, function() 
		CloseCallback()
	end)
	
	local cor = coroutine.start(function()
		local loadwww = UnityEngine.WWW(_url .. tostring(TextMgr.currentLanguage) .. ".txt?t=" .. os.time())
		Yield(loadwww)
		if loadwww.isDone then
			_waiting:SetActive(false)
			local str = string.sub(loadwww.text, 4)
			local _data = cjsonSafe.decode(str)
			table.sort(_data, function(a,b)
				return a.index < b.index
			end)
			for i, v in ipairs(_data) do
				if v.switch == "on" then
					local versions = v.version:split(",")
					if tonumber(versions[1]) <= tonumber(_version) and tonumber(_version) <= tonumber(versions[2]) then
						local item = NGUITools.AddChild(_table.gameObject, _itemprefab)
						local tolength = baselength
						if v.texture ~= nil then
							tolength = tolength + 143
							local _cor = coroutine.start(function()
								local textureurl = string.find(v.texture, "http") ~= nil and v.texture or _url .. v.texture
								local loadwww = UnityEngine.WWW(textureurl)
								Yield(loadwww)
								if loadwww.isDone then
									local texture = UnityEngine.Texture2D(512, 128)
									loadwww:LoadImageIntoTexture(texture)
									item.transform:Find("ItemInfo_open/bg_pic/pic"):GetComponent("UITexture").mainTexture = texture
									if not System.String.IsNullOrEmpty(v.url) then
										SetClickCallback(item.transform:Find("ItemInfo_open/bg_pic").gameObject, function()
											UnityEngine.Application.OpenURL(v.url)
										end)
									end
								end
							end)
							table.insert(_urlCoroutines, _cor)
						else
							item.transform:Find("ItemInfo_open/bg_pic").localScale = Vector3(1,0,1)
						end
						item.transform:Find("bg_list/bg_text/text"):GetComponent("UILabel").text = v.title
						local context = item.transform:Find("ItemInfo_open/txt_noitem"):GetComponent("UILabel")
						context.text = v.text
						tolength = tolength + context.height
						item.transform:Find("bg_list"):GetComponent("TweenHeight").to = tolength
						if i == 1 then
							item.transform:Find("bg_list/btn_open").gameObject:SendMessage("OnClick")
						end
						coroutine.start(function()
							coroutine.step()
							context:ResizeCollider()
						end)
					end
				end
			end
			_table:Reposition()
		end
	end)
	table.insert(_urlCoroutines, cor)
end

function Show(url, version, isfirst)
	if url ~= nil then
		_url = url
	end
	if version ~= nil then
		_version = version
	end
	print(_url)
	if _url == nil then
		return
	end
	if isfirst == nil or isfirst then
		Global.OpenTopUI(_M)
		if UnityEngine.GameObject.Find("login") ~= nil then
			login.HideLoginBtn()
		end
	end
end

function Close()
	RemoveDelegate(UICamera, "onPress", OnUICameraPress)
	if UnityEngine.GameObject.Find("login") ~= nil then
		login.ShowLoginBtn()
	end
	_container = nil
	_close = nil
	_waiting = nil
	_scrollview = nil
	_table = nil
	_itemprefab = nil
	_urlCoroutines = nil
end

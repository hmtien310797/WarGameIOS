module("FaceDrawData", package.seeall)
local GameTime = Serclimax.GameTime
local faceDrawData
local textureList
local TextMgr = Global.GTextMgr
local eventListener = EventListener()

local TableMgr = Global.GTableMgr

function GetData()
    return faceDrawData
end

function SetData(data)
    faceDrawData = data
    local serverTime = GameTime.GetSecTime()
    local fdlist = faceDrawData.fdlist
    --Global.DumpMessage(data)
    --Global.DumpMessage(fdlist)

    local need_remove={}
    for i, v in ipairs(fdlist) do
        --print(i,v.actid,"noticetime",v.noticetime,"endtime",v.endtime,"serverTime",serverTime)
        --if(v.actid == 1020) then
        --    print("ssss",serverTime < v.noticetime or serverTime > v.endtime)
        --end
        if serverTime < v.noticetime or serverTime > v.endtime then
            --print("success remove",v.actid)
            --fdlist:remove(i)
            table.insert(need_remove,i)
        end
    end

    for i=1,#need_remove do
        --print("EEEEEEEEEEE",need_remove[i],need_remove[i]-i+1)
        fdlist:remove(need_remove[i]-i+1)
    end

    --for i, v in ipairs(fdlist) do
    --    print("_____________________________",i,v.actid,"noticetime",v.noticetime,"endtime",v.endtime,"serverTime",serverTime)
    --end


    table.sort(fdlist, function(v1, v2)
        return v1.priority > v2.priority
    end)

    local priorityList = {}
    for i, v in ipairs(fdlist) do
        local priority = v.priority
        if priorityList[priority] == nil then
            priorityList[priority] = {}
        end
        table.insert(priorityList[priority], i)
    end

    local keepList = {}
    for _, v in pairs(priorityList) do
        keepList[v[math.random(#v)]] = true
    end

    for i = #fdlist, 1, -1 do
        if keepList[i] == nil then
            print("RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR")
            table.remove(fdlist, i)
        end
    end
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

function RequestData(callback, lockScreen)
    textureList = {}
	local req = ActivityMsg_pb.MsgGetFaceDrawListRequest()
    Global.Request(Category_pb.Activity, ActivityMsg_pb.ActivityTypeId.MsgGetFaceDrawListRequest, req, ActivityMsg_pb.MsgGetFaceDrawListResponse, function(msg)
        if msg.code == ReturnCode_pb.Code_OK then
            SetData(msg)
            Global.DumpMessage(msg)
        	if callback ~= nil then
        		callback()
        	end
        end
    end, not lockScreen)
end

function GetTexture(url, callback)
    if textureList[url] == nil then
        textureList[url] = {}
        textureList[url].callback = callback
        textureList[url].co = coroutine.start(function()
            local www = UnityEngine.WWW(url)
            coroutine.www(www)
            local texture = UnityEngine.Texture2D(512, 256)
            www:LoadImageIntoTexture(texture)
            textureList[url].texture = texture
            textureList[url].callback(texture)
        end)
    else
        textureList[url].callback = callback
        if textureList[url].texture ~= nil then
            textureList[url].callback(textureList[url].texture)
        end
    end
end

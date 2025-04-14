
class "WorldMapNet"
{
}

function WorldMapNet:__init__(world_map_mgr)
    self.world_map_mgr = world_map_mgr
    self.map_data = {}
    for i =1,9 do
        self.map_data[i] = nil
    end
    self.path_data = {}
    for i =1,9 do
        self.path_data[i] = nil
    end    
end

function WorldMapNet:GetCenterServerPos()
    local centerMapX, centerMapY = WorldMap.GetCenterMapCoord()

    local center_server_x = math.floor(centerMapX % 
    WorldMap.GetServerMapSize() / 
    WorldMap.GetServerBlockSize())
    local center_server_y = math.floor(centerMapY % 
    WorldMap.GetServerMapSize() / 
    WorldMap.GetServerBlockSize())   
    return center_server_x,center_server_y
end    

function WorldMapNet:ServerPosIndex2LocalPosIndex(server_pos_index)
    local server_pos_x = math.floor(server_pos_index%WorldMap.GetServerBlockTotalCount())
    local server_pos_y = math.floor(server_pos_index/WorldMap.GetServerBlockTotalCount())
    local center_server_x,center_server_y = self:GetCenterServerPos()
    local local_x = server_pos_x - center_server_x +1
    local local_y = server_pos_y - center_server_y +1
    if local_x < 0 or local_x> 2 or local_y < 0 or local_y > 2 then
        return -1
    end
    return local_y*3+local_x+1
end

function WorldMapNet:OnMapDataUpdate(map_data_btyes)
    local msg = nil
    if map_data_btyes == nil then
        return
    end
    if #map_data_btyes > 0 then
        msg = MapMsg_pb.PosISceneEntrysInfoResponse()
        msg:ParseFromString(map_data_btyes)
    end


    if msg ~= nil then
        local centerMapX, centerMapY = WorldMap.GetCenterMapCoord()
        local center_server_x,center_server_y = self:GetCenterServerPos()
       
        local posIndexs = {}
        local i=1
        for _y = -1,3,1 do
            for _x = -1,3,1 do
                local y = (center_server_y+_y)%WorldMap.GetServerBlockTotalCount()
                local x = (center_server_x+_x)%WorldMap.GetServerBlockTotalCount()
                posIndexs[i] = y*WorldMap.GetServerBlockTotalCount() +x
                i = i+1
            end
        end

        for p=1,9 do
            if self.map_data[i] ~= nil then
                if self.map_data[i].posI ~= posIndexs[i] then
                    self.map_data[i] = nil
                end
            end
        end
        --local log = ""
        for cur_entry_index = 1,#msg.entry do
            local entrysInfo = msg.entry[cur_entry_index]
            local local_pos_index = self:ServerPosIndex2LocalPosIndex(entrysInfo.posI)

            if local_pos_index > 0 then
                self.map_data[local_pos_index] = {}
                self.map_data[local_pos_index].posI = entrysInfo.posI
                self.map_data[local_pos_index].datas = {}
                for entry_index = 1,#entrysInfo.entrys do
                    local entry = entrysInfo.entrys[entry_index]
                    self.map_data[local_pos_index].datas[entry.data.uid] = entry
                    --log = log ..local_pos_index..":"..entry.data.uid..'\n'
                end
            end
        end
        --print("RRRRRRRRRRR",log)
    end
end

function WorldMapNet:OnPathDataUpdate(path_data_btyes)
    local msg = nil
    if path_data_btyes == nil then
        return
    end    
    if #path_data_btyes > 0 then
        msg = MapMsg_pb.SceneMapPathInfoV2Response()
        msg:ParseFromString(path_data_btyes)
    end


    if msg ~= nil then
        local centerMapX, centerMapY = WorldMap.GetCenterMapCoord()
        local center_server_x,center_server_y = self:GetCenterServerPos()
       
        local posIndexs = {}
        local i=1
        for _y = -1,3,1 do
            for _x = -1,3,1 do
                local y = (center_server_y+_y)%WorldMap.GetServerBlockTotalCount()
                local x = (center_server_x+_x)%WorldMap.GetServerBlockTotalCount()
                posIndexs[i] = y*WorldMap.GetServerBlockTotalCount() +x
                i = i+1
            end
        end

        for p=1,9 do
            if self.path_data[i] ~= nil then
                if self.path_data[i].posI ~= posIndexs[i] then
                    self.path_data[i] = nil
                end
            end
        end
        
        local path_map = {}
        for cur_path_index = 1,#msg.path do
            path_map[msg.path[cur_path_index].pathId] = msg.path[cur_path_index]
        end

        for cur_data_index = 1,#msg.data do
            local data = msg.data[cur_data_index]
            for data_p_index = 1,#data.posi do
                local local_pos_index = self:ServerPosIndex2LocalPosIndex(data.posi[data_p_index])
                if local_pos_index > 0 then
                    if self.path_data[local_pos_index] == nil or self.path_data[local_pos_index].old_version then
                        self.path_data[local_pos_index] = {}
                        self.path_data[local_pos_index].old_version = false
                        self.path_data[local_pos_index].posI = data.posi[data_p_index]  
                        self.map_data[local_pos_index].datas={}
                    end
                    self.map_data[local_pos_index].datas[data.pathid] = path_map[data.pathid]         
                end      
            end
        end

        for p=1,9 do
            if self.path_data[i] ~= nil then
                self.path_data[i].old_version = true
            end
        end        
    end
end

function WorldMapNet:GetMapData(id)
    local data =nil
    for p=1,9 do
        if self.map_data[i] ~= nil and self.map_data[i].datas ~= nil then
            data = self.map_data[i][id]
            if data ~= nil then
                return data;
            end
        end
    end
    return data
end

function WorldMapNet:GetPathData(id)
    local data =nil
    for p=1,9 do
        if self.path_data[i] ~= nil and self.path_data[i].datas ~= nil then
            data = self.path_data[i][id]
            if data ~= nil then
                return data;
            end
        end
    end
    return data
end

function WorldMapNet:Destroy()
    self.world_map_mgr = nil
    self.map_data = nil
    self.path_data = nil
end


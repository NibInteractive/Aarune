local SpatialHash = {}
SpatialHash.__index = SpatialHash

function SpatialHash.New(CellSize)
    return setmetatable({CellSize = CellSize or 128, Grid = {}}, SpatialHash)
end

function SpatialHash:Clear()
    self.Grid = {}
end

function SpatialHash:Hash(x, y)
    local cx = math.floor(x / self.CellSize)
    local cy = math.floor(y / self.CellSize)

    return cx .. "," .. cy
end

function SpatialHash:Insert(Object)
    local Key = self:Hash(Object.x, Object.y)

    self.Grid[Key] = self.Grid[Key] or {}

    table.insert(self.Grid[Key], Object)
end

function SpatialHash:GetNearby(Object)
    local cx = math.floor(Object.x / self.CellSize)
    local cy = math.floor(Object.y / self.CellSize)

    local Neighbors = {}

    for dx = -1, 1 do
        for dy = -1, 1 do
            local Key = (cx + dx) .. "," .. (cy + dy)

            if self.Grid[Key] then
                for _, o in ipairs(self.Grid[Key]) do
                    table.insert(Neighbors, o)
                end
            end
        end
    end

    return Neighbors
end

return SpatialHash
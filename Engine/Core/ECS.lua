local ECS = {}
ECS.__index = ECS
ECS.Systems = {}
ECS.Components = {}
ECS.Entities = {}
ECS.EntityCount = 0
ECS.SystemCount = 0
ECS.ComponentCount = 0
ECS.EntityComponents = {}
ECS.ComponentEntities = {}

function ECS:New()
    local MetaECS = setmetatable({}, ECS)

    return MetaECS
end

function ECS:CreateEntity()
    self.EntityCount = self.EntityCount + 1
    local EntityID = "Entity_" .. tostring(self.EntityCount)
    self.Entities[EntityID] = {}
    self.EntityComponents[EntityID] = {}

    return EntityID
end
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

local function DeepCopy(Original)
    local Copy = {}

    for k, v in pairs(Original) do
        Copy[k] = type(v) == "table" and DeepCopy(v) or v
    end

    return Copy
end

function ECS:New()
    local MetaECS = setmetatable({
        Systems = {},
        Components = {},
        Entities = {},
        EntityCount = 0,
        SystemCount = 0,
        ComponentCount = 0,
        EntityComponents = {},
        ComponentEntities = {},
    }, ECS)

    return MetaECS
end

function ECS:CreateEntity()
    self.EntityCount = self.EntityCount + 1
    local EntityID = "Entity_" .. tostring(self.EntityCount)
    self.Entities[EntityID] = {}
    self.EntityComponents[EntityID] = {}

    return EntityID
end

function ECS:RemoveEntity(EntityID)
    if not EntityID or not self.Entities[EntityID] then return end

    for ComponentName, _ in pairs(self.EntityComponents[EntityID]) do
        self:RemoveComponentFromEntity(EntityID, ComponentName)
    end

    self.Entities[EntityID] = nil
    self.EntityComponents[EntityID] = nil
end

function ECS:CreateComponent(Name, Data)
    if not Name or self.Components[Name] then return end

    self.ComponentCount = self.ComponentCount + 1
    self.Components[Name] = true
    self.ComponentEntities[Name] = {}

    return Name
end

function ECS:RemoveComponent(Name)
    if not Name or not self.Components[Name] then return end

    for EntityID, _ in pairs(self.ComponentEntities[Name]) do
        self:RemoveComponentFromEntity(EntityID, Name)
    end

    self.Components[Name] = nil
    self.ComponentEntities[Name] = nil
    self.ComponentCount = self.ComponentCount - 1
end

function ECS:GetComponent(EntityID, ComponentName)
    local Components = self.EntityComponents[EntityID]

    return Components and Components[ComponentName]
end

function ECS:HasComponent(EntityID, ComponentName)
    return self.EntityComponents[EntityID]
       and self.EntityComponents[EntityID][ComponentName] ~= nil
end


function ECS:AddComponentToEntity(EntityID, ComponentName, Data)
    if not EntityID or not ComponentName then return end
    if not self.Entities[EntityID] or not self.Components[ComponentName] then return end

    self.EntityComponents[EntityID][ComponentName] = DeepCopy(Data or {})
    self.ComponentEntities[ComponentName][EntityID] = true
end

function ECS:RemoveComponentFromEntity(EntityID, ComponentName)
    if not EntityID or not ComponentName then return end
    if not self.Entities[EntityID] or not self.Components[ComponentName] then return end
    if not self.EntityComponents[EntityID][ComponentName] then return end

    self.EntityComponents[EntityID][ComponentName] = nil
    self.ComponentEntities[ComponentName][EntityID] = nil
end

function ECS:GetEntityComponents(EntityID)
    if not EntityID or not self.Entities[EntityID] then return nil end

    return self.EntityComponents[EntityID]
end

function ECS:GetEntitiesWithComponent(ComponentName)
    if not ComponentName or not self.Components[ComponentName] then return nil end

    local Entities = {}
    for EntityID, _ in pairs(self.ComponentEntities[ComponentName]) do
        table.insert(Entities, EntityID)
    end

    return Entities
end

function ECS:CreateSystem(Name, UpdateFunction)
    if not Name or self.Systems[Name] then return end
    if not UpdateFunction or type(UpdateFunction) ~= "function" then return end

    self.SystemCount = self.SystemCount + 1
    self.Systems[Name] = UpdateFunction

    return Name
end

function ECS:RemoveSystem(Name)
    if not Name or not self.Systems[Name] then return end

    self.Systems[Name] = nil
    self.SystemCount = self.SystemCount - 1
end

function ECS:Update(dt)
    for _, System in pairs(self.Systems) do
        System(self, dt)
    end
end

return ECS
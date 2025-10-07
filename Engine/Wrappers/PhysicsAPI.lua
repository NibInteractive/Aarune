local Physics = require("Engine.Physics.Physics") -- your OOP physics module
local ECS = require("Engine.Core.ECS")            -- ECS module, optional if using ECS

local PhysicsAPI = {}
PhysicsAPI.__index = PhysicsAPI

local function RawContains(Table, Object)
    for _, v in ipairs(Table) do
        if v == Object then return true end
    end

    return false
end

function PhysicsAPI:New(ECSInstance)
    local Meta = setmetatable({
        Physics = Physics:New(),
        ECS = ECSInstance or nil,
        RawObjects = {},
        DefaultFriction = .9,
        DefaultTerminalVelocity = .9
    }, PhysicsAPI)

    return Meta
end

function PhysicsAPI:AddDynamic(ObjectOrEntity)
    if not ObjectOrEntity then return end

    if self.ECS and self.ECS.Entities and self.ECS:GetComponent(ObjectOrEntity, "Transform") then
        local Transform = self.ECS:GetComponent(ObjectOrEntity, "Transform")
        Transform.PhysicsType = "Dynamic"
        Transform.vy = 0

        return
    end

    ObjectOrEntity.PhysicsType = "Dynamic"
    ObjectOrEntity.vy = 0
    
    if not RawContains(self.RawObjects, ObjectOrEntity) then
        table.insert(self.RawObjects, ObjectOrEntity)
    end
end

function PhysicsAPI:AddStatic(ObjectOrEntity)
    if not ObjectOrEntity then return end
    
    if self.ECS and self.ECS.Entities and self.ECS:GetComponent(ObjectOrEntity, "Transform") then
        local Transform = self.ECS:GetComponent(ObjectOrEntity, "Transform")
        Transform.PhysicsType = "Static"
        Transform.vy = nil

        return
    end

    ObjectOrEntity.PhysicsType = "Static"
    ObjectOrEntity.vy = nil

    if not RawContains(self.RawObjects, ObjectOrEntity) then
        table.insert(self.RawObjects, ObjectOrEntity)
    end
end

function PhysicsAPI:SystemUpdate(dt)
    -- ECS Entities
    if self.ECS then
        local Entities = self.ECS:GetEntitiesWithComponent("Transform")

        for _, id in ipairs(Entities) do
            local Object = self.ECS:GetComponent(id, "Transform")

            if Object.PhysicsType == "Dynamic" then
                self.Physics:Update(Object, dt)
                self.Physics:ApplyTerminalVelocity(Object, self.DefaultTerminalVelocity)
                self.Physics:ApplyFriction(Object, self.DefaultFriction)

                for _, OtherID in ipairs(Entities) do
                    if id ~= OtherID then
                        local Other = self.ECS:GetComponent(OtherID, "Transform")

                        if Other.PhysicsType == "Static" then
                            self.Physics:ResolveCollision(Object, Other)
                        end
                    end
                end
            end
        end
    end

    -- Raw objects
    for _, Object in ipairs(self.RawObjects) do
        if Object.PhysicsType == "Dynamic" then
            self.Physics:Update(Object, dt)
            self.Physics:ApplyTerminalVelocity(Object, self.DefaultTerminalVelocity)
            self.Physics:ApplyFriction(Object, self.DefaultFriction)

            for _, other in ipairs(self.RawObjects) do
                if other.PhysicsType == "Static" then
                    self.Physics:ResolveCollision(Object, other)
                end
            end
        end
    end
end

return PhysicsAPI
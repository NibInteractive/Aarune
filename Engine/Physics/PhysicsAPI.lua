local Physics = require("Engine.Physics.Physics") -- your OOP physics module
local ECS = require("Engine.Core.ECS")            -- ECS module, optional if using ECS

local PhysicsAPI = {}
PhysicsAPI.__index = PhysicsAPI

function PhysicsAPI:New(ECSInstance)
    local Meta = setmetatable({
        Physics = Physics:New(),
        ECS = ECSInstance,
    }, PhysicsAPI)

    return Meta
end

function PhysicsAPI:_GetObject(Object)
    if type(Object) == "string" and self.ECS then
        -- ECS entity ID provided
        local Transform = self.ECS:GetComponent(Object, "Transform")
        if not Transform then
            -- Auto-add Transform if it doesn't exist
            self.ECS:AddComponentToEntity(Object, "Transform", { x = 0, y = 0, vx = 0, vy = 0, PhysicsType = "Dynamic", OnGround = false })
            Transform = self.ECS:GetComponent(Object, "Transform")
        end
        return Transform
    elseif type(Object) == "table" then
        return Object
    else
        return nil
    end
end

-- Dynamic Body
function PhysicsAPI:DynamicBody(Object)
    local Obj = self:_GetObject(Object)
    if not Obj then return end
    self.Physics:DynamicBody(Obj)
end

function PhysicsAPI:DynamicBodies(Objects)
    for _, Obj in ipairs(Objects) do
        self:DynamicBody(Obj)
    end
end

-- Static Body
function PhysicsAPI:StaticBody(Object)
    local Obj = self:_GetObject(Object)
    if not Obj then return end
    self.Physics:StaticBody(Obj)
end

function PhysicsAPI:StaticBodies(Objects)
    for _, Obj in ipairs(Objects) do
        self:StaticBody(Obj)
    end
end

-- Apply Gravity
function PhysicsAPI:ApplyGravity(Object, dt)
    local Obj = self:_GetObject(Object)
    if not Obj then return end
    self.Physics:ApplyGravity(Obj, dt)
end

-- Friction
function PhysicsAPI:ApplyFriction(Object, Friction)
    local Obj = self:_GetObject(Object)
    if not Obj then return end
    self.Physics:ApplyFriction(Obj, Friction)
end

-- Collision
function PhysicsAPI:CheckCollision(A, B)
    local ObjA = self:_GetObject(A)
    local ObjB = self:_GetObject(B)
    if not ObjA or not ObjB then return false end
    return self.Physics:CheckCollision(ObjA, ObjB)
end

function PhysicsAPI:ResolveCollision(A, B)
    local ObjA = self:_GetObject(A)
    local ObjB = self:_GetObject(B)
    if not ObjA or not ObjB then return end
    self.Physics:ResolveCollision(ObjA, ObjB)
end

-- Update
function PhysicsAPI:Update(Object, dt)
    local Obj = self:_GetObject(Object)
    if not Obj then return end
    self.Physics:Update(Obj, dt)
end

return PhysicsAPI

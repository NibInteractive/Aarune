local Physics = require("Engine.Physics.Physics") -- your OOP physics module
local ECS = require("Engine.Core.ECS")            -- ECS module, optional if using ECS

local SpatialHash = require("Engine.Physics.Utilities.SpatialHash")
local Hash = SpatialHash.New(128)

local PhysicsAPI = {}
PhysicsAPI.__index = PhysicsAPI

local function RawContains(Table, Object)
    for _, v in ipairs(Table) do
        if v == Object then return true end
    end

    return false
end

function PhysicsAPI:RetrieveAPI()
    return self
end

function PhysicsAPI:New(ECSInstance)
    local Meta = setmetatable({
        Physics = Physics:New(),
        ECS = ECSInstance or nil,

        RawObjects = {},
        Collisions = {},

        DefaultFriction = .8,
        DefaultTerminalVelocity = 2500
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

function PhysicsAPI:AddDynamics(ObjectsOrEntities)
    for i, v in ipairs(ObjectsOrEntities) do
        self:AddDynamic(v)
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

function PhysicsAPI:AddStatics(ObjectsOrEntities)
    for i, v in ipairs(ObjectsOrEntities) do
        self:AddStatic(v)
    end
end

function PhysicsAPI:TriggerCollisionEvent(A, B, Event)
	if A[Event] then A[Event](A, B) end
	if B[Event] then B[Event](B, A) end

	if self.ECS then
		if type(A) == "string" then self.ECS:Dispatch("Physics_" .. Event, A, B) end
		if type(B) == "string" then self.ECS:Dispatch("Physics_" .. Event, B, A) end
	end
end

function PhysicsAPI:CheckCollisionEvents(A, B, Collided)
	self.Collisions[A] = self.Collisions[A] or {}

	local wasColliding = self.Collisions[A][B]
	if Collided and not wasColliding then
		self:TriggerCollisionEvent(A, B, "OnCollisionEnter")
		self.Collisions[A][B] = true
	elseif Collided and wasColliding then
		self:TriggerCollisionEvent(A, B, "OnCollisionStay")
	elseif not Collided and wasColliding then
		self:TriggerCollisionEvent(A, B, "OnCollisionExit")
		self.Collisions[A][B] = nil
	end
end

function PhysicsAPI:SystemUpdate(dt)
    dt = dt or (1 / (love.timer.getFPS() or 60))

    self.RawObjects = self.RawObjects or {}
    self.DefaultTerminalVelocity = self.DefaultTerminalVelocity or 1500
    
    for _, Object in ipairs(self.RawObjects) do
        Hash:Insert(Object)
    end

    local function ResolveWithStatics(DynamicObject)
        for _, Other in ipairs(self.RawObjects) do
            if Other.PhysicsType == "Static" then
                self.Physics:ResolveCollision(DynamicObject, Other)
            end
        end

        if self.ECS then
            local Entities = self.ECS:GetEntitiesWithComponent("Transform")

            for _, id in ipairs(Entities) do
                local Other = self.ECS:GetComponent(id, "Transform")

                if Other.PhysicsType == "Static" then
                    self.Physics:ResolveCollision(DynamicObject, Other)
                end
            end
        end
    end

    if self.ECS then
        local Entities = self.ECS:GetEntitiesWithComponent("Transform")

        for _, id in ipairs(Entities) do
            local Object = self.ECS:GetComponent(id, "Transform")

            if Object.PhysicsType == "Dynamic" then
                self.Physics:Update(Object, dt)
                self.Physics:ApplyTerminalVelocity(Object, self.DefaultTerminalVelocity)
                
                ResolveWithStatics(Object)

                if Object.OnGround then
                    self.Physics:ApplyFriction(Object, self.DefaultFriction)
                end
            end
        end
    end
    
    for _, Object in ipairs(self.RawObjects) do
        if Object.PhysicsType == "Dynamic" then
            self.Physics:Update(Object, dt)
            self.Physics:ApplyTerminalVelocity(Object, self.DefaultTerminalVelocity)

            ResolveWithStatics(Object)

            if Object.OnGround then
                self.Physics:ApplyFriction(Object, self.DefaultFriction)
            end
        end
    end
end

function PhysicsAPI:ApplyFriction(ObjectOrEntity, Amount)
	Amount = Amount or self.DefaultFriction

	if self.ECS and type(ObjectOrEntity) == "string" then
		local Object = self.ECS:GetComponent(ObjectOrEntity, "Transform")

		if Object then self.Physics:ApplyFriction(Object, Amount) end
	else
		self.Physics:ApplyFriction(ObjectOrEntity, Amount)
	end
end

function PhysicsAPI:ApplyForce(ObjectOrEntity, fx, fy)
	if not ObjectOrEntity then return end

	if self.ECS and type(ObjectOrEntity) == "string" then
		local Object = self.ECS:GetComponent(ObjectOrEntity, "Transform")
        if not Object then return end
        
		Object.vx = (Object.vx or 0) + (fx or 0)
		Object.vy = (Object.vy or 0) + (fy or 0)
	else
		ObjectOrEntity.vx = (ObjectOrEntity.vx or 0) + (fx or 0)
		ObjectOrEntity.vy = (ObjectOrEntity.vy or 0) + (fy or 0)
	end
end

function PhysicsAPI:SetVelocity(ObjectOrEntity, vx, vy)
	if not ObjectOrEntity then return end

	if self.ECS and type(ObjectOrEntity) == "string" then
		local Object = self.ECS:GetComponent(ObjectOrEntity, "Transform")
        if not Object then return end
        
		Object.vx = vx or Object.vx or 0
		Object.vy = vy or Object.vy or 0
	else
		ObjectOrEntity.vx = vx or ObjectOrEntity.vx or 0
		ObjectOrEntity.vy = vy or ObjectOrEntity.vy or 0
	end
end

function PhysicsAPI:GetVelocity(ObjectOrEntity)
	if not ObjectOrEntity then return 0, 0 end

	if self.ECS and type(ObjectOrEntity) == "string" then
		local Object = self.ECS:GetComponent(ObjectOrEntity, "Transform")

		if Object then return Object.vx or 0, Object.vy or 0 end
	else
		return ObjectOrEntity.vx or 0, ObjectOrEntity.vy or 0
	end
end

function PhysicsAPI:ApplyGravity(ObjectOrEntity, dt)
	dt = dt or (1 / 60)

	if self.ECS and type(ObjectOrEntity) == "string" then
		local Object = self.ECS:GetComponent(ObjectOrEntity, "Transform")

		if Object then self.Physics:ApplyGravity(Object, dt) end
	else
		self.Physics:ApplyGravity(ObjectOrEntity, dt)
	end
end

function PhysicsAPI:Clear()
	self.RawObjects = {}
    self.Collisions = {}
end

return PhysicsAPI
local Physics = {}
Physics.__index = Physics
Physics.Integrators = {}

-- If you like pure OOP based frameworks/engines, you can always redirect the requires --
-- PhysicsAPI wrapper, should be automated ECS or OOP, as of V0.6.2-Prototype [Version 0.7.2] --
function Physics:New()
    local MetaPhysics = setmetatable({}, Physics)

    return MetaPhysics
end

function Physics:GetCollisionNormal(A, B)
    local dx = (A.x + A.width/2) - (B.x + B.width/2)
    local dy = (A.y + A.height/2) - (B.y + B.height/2)

    local OverlapX = (A.width + B.width)/2 - math.abs(dx)
    local OverlapY = (A.height + B.height)/2 - math.abs(dy)

    if OverlapX <= 0 or OverlapY <= 0 then
        return 0, 0, 0
    end

    if OverlapX < OverlapY then
        return (dx < 0 and -1 or 1), 0, OverlapX
    else
        return 0, (dy < 0 and -1 or 1), OverlapY
    end
end

function Physics:ApplyGravity(Object, dt)
    if not Object or not Object.y or not Object.vy then return end
    if not Object.PhysicsType or Object.PhysicsType ~= "Dynamic" then
         Object.PhysicsType = "Dynamic"
    end

    local Gravity = 1325 -- 980 | Works better via direct physics module, not the GamePhysics wrapper.
    Object.vy = Object.vy + Gravity * dt
end

function Physics:DynamicBody(Object)
    if not Object then return end

    Object.PhysicsType = "Dynamic"
    Object.vy = 0
    Object.vx = Object.vx or 0
    Object.Mass = Object.Mass or 1
end

function Physics:DynamicBodies(Objects)
    if not Objects or type(Objects) ~= "table" then return end

    for _, Object in ipairs(Objects) do
        self:DynamicBody(Object)
    end
end

function Physics:StaticBody(Object)
    if not Object then return end

    Object.PhysicsType = "Static"
    Object.vy = nil
    Object.vx = nil
end

function Physics:StaticBodies(Objects)
    if not Objects or type(Objects) ~= "table" then return end

    for _, Object in ipairs(Objects) do
        self:StaticBody(Object)
    end
end

-- Testing purposes so I don't constantlly change function names between Physics & GamePhysics --
function Physics:AddStatics(Objects)
    Physics:StaticBodies(Objects)
end

function Physics:ApplyTerminalVelocity(Object, TerminalVelocity)
    if not Object or not Object.vy then return end

    TerminalVelocity = TerminalVelocity or 500
    if Object.vy > TerminalVelocity then
        Object.vy = TerminalVelocity
    end    
end

function Physics:ApplyFriction(Object, Friction)
    if not Object then return end

    Friction = Friction or 0.9
    
    if Object.vx then
        Object.vx = Object.vx * Friction
        if math.abs(Object.vx) < 0.1 then Object.vx = 0 end
    end
end

function Physics:CheckCollision(A, B)
    return A.x < B.x + B.width and
           A.x + A.width > B.x and
           A.y < B.y + B.height and
           A.y + A.height > B.y
end

function Physics:ResolveCollision(A, B)
    if not self:CheckCollision(A, B) then return end

    local nx, ny, Penetration = self:GetCollisionNormal(A, B)
    if not nx and not ny or Penetration <= 0 then return end

    if A.PhysicsType == "Dynamic" then
        A.x = A.x + nx * Penetration
        A.y = A.y + ny * Penetration

        if ny < 0 then A.OnGround = true end
        if ny ~= 0 then A.vy = 0 end
        if nx ~= 0 then A.vx = 0 end
    end
end

function Physics:ResolveDynamicCollision(A, B, Elasticity)
    if not self:CheckCollision(A, B) then return end

    Elasticity = Elasticity or 0.5
    local nx, ny, Penetration = self:GetCollisionNormal(A, B)
    if Penetration <= 0 then return end

    local Half = Penetration * 0.5

    A.x = A.x + nx * Half
    A.y = A.y + ny * Half
    B.x = B.x - nx * Half
    B.y = B.y - ny * Half
    
    local rvx = (A.vx or 0) - (B.vx or 0)
    local rvy = (A.vy or 0) - (B.vy or 0)
    local relVelAlongNormal = rvx * nx + rvy * ny

    if relVelAlongNormal > 0 then
        return
    end

    local InvMassA = 1 / (A.mass or 1)
    local InvMassB = 1 / (B.mass or 1)

    local j = -(1 + Elasticity) * relVelAlongNormal
    j = j / (InvMassA + InvMassB)

    local ImpulseX = j * nx
    local ImpulseY = j * ny

    A.vx = (A.vx or 0) + ImpulseX * InvMassA
    A.vy = (A.vy or 0) + ImpulseY * InvMassA
    B.vx = (B.vx or 0) - ImpulseX * InvMassB
    B.vy = (B.vy or 0) - ImpulseY * InvMassB
end

function Physics:Update(Object, dt)
    if Object.PhysicsType == "Dynamic" then
        Object.OnGround = false
        
        if Object.vy then
            self:ApplyGravity(Object, dt)
        end

        self:Integrate(Object, dt)
    end
end

-- Modular Integrators --

Physics.Integrators["Euler"] = function(Object, dt)
    Object.x = Object.x + (Object.vx or 0) * dt
    Object.y = Object.y + (Object.vy or 0) * dt
end

Physics.Integrators["SemiImplicitEuler"] = function(Object, dt)
    Object.vx = Object.vx + (Object.ax or 0) * dt
    Object.vy = Object.vy + (Object.ay or 0) * dt
    Object.x = Object.x + Object.vx * dt
    Object.y = Object.y + Object.vy * dt
end

Physics.ActiveIntegrator = "SemiImplicitEuler"

function Physics:Integrate(Object, dt)
    local method = self.Integrators[self.ActiveIntegrator]
    if method then method(Object, dt) end
end

return Physics
local Physics = {}
Physics.__index = Physics

-- If you like pure OOP based frameworks/engines, you can always redirect the requires --
-- PhysicsAPI wrapper, should be automated ECS or OOP, as of V0.6.2-Prototype --
function Physics:New()
    local MetaPhysics = setmetatable({}, Physics)

    return MetaPhysics
end

function Physics:ApplyGravity(Object, dt)
    if not Object or not Object.y or not Object.vy then return end
    if not Object.PhysicsType or Object.PhysicsType ~= "Dynamic" then
         Object.PhysicsType = "Dynamic"
    end

    local Gravity = 980
    Object.vy = Object.vy + Gravity * dt
    Object.y = Object.y + Object.vy * dt
end

function Physics:DynamicBody(Object)
    if not Object then return end

    Object.PhysicsType = "Dynamic"
    Object.vy = 0
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
    Object.vy = Object.vy * Friction    
end

function Physics:CheckCollision(A, B)
    return A.x < B.x + B.width and
           A.x + A.width > B.x and
           A.y < B.y + B.height and
           A.y + A.height > B.y
end

function Physics:ResolveCollision(A, B)
    if not self:CheckCollision(A, B) then return end

    if A.PhysicsType == "Dynamic" and B.PhysicsType == "Static" then
        -- Vertical collision
        if A.y + A.height > B.y and A.y < B.y then
            A.y = B.y - A.height
            A.vy = 0
            A.OnGround = true
        end

        -- Horizontal collision
        if A.x + A.width > B.x and A.x < B.x then
            if A.x < B.x then
                A.x = B.x - A.width
            else
                A.x = B.x + B.width
            end
        end
    end
end

function Physics:Update(Object, dt)
    if Object.PhysicsType == "Dynamic" then
        Object.OnGround = false
    end

    if Object.vy then
        self:ApplyGravity(Object, dt)
    end
end

return Physics
local Graphics = {}
Graphics.__index = Graphics

function Graphics:New()
    local self = setmetatable({}, Graphics)

    local ECS = require("Engine.Core.ECS")
    local SpriteRenderer = require("Engine.Rendering.SpriteRenderer")

    self.ECS = ECS:New()
    self.Renderer = SpriteRenderer:New()
    
    self.ECS:CreateComponent("Transform")
    self.ECS:CreateComponent("Sprite")

    return self
end

function Graphics:AddSpriteEntity(ImagePath, Layer, x, y, sx, sy)
    local Entity = self.ECS:CreateEntity()
    local SpriteName = "Entity_" .. tostring(Entity)

    self.Renderer:RegisterEntity(SpriteName, ImagePath, Layer or 1)
    self.Renderer:UpdateEntityTransform(Entity, x, y)

    self.ECS:AddComponentToEntity(Entity, "Transform", { x = x or 0, y = y or 0, r = 0, sx = sx or 1, sy = sy or 1 })
    self.ECS:AddComponentToEntity(Entity, "Sprite", { Name = SpriteName })

    return {
        Entity = Entity,
        ECS = self.ECS,
        x = x or 0,
        y = y or 0,
        width = 32,
        height = 32,
        vx = 0,
        vy = 0,
        PhysicsType = "Dynamic"
    }
end

function Graphics:AttachSprite(Object, ImagePath)
    if not Object then return end

    Object.Sprite = {
        Image = love.graphics.newImage(ImagePath),
        Path = ImagePath,
    }
end

function Graphics:Move(Entity, x, y)
    local Transform = self.ECS:GetEntityComponents(Entity)["Transform"]

    if Transform then
        Transform.x = x or 0
        Transform.y = y or 0
    end
end

function Graphics:Scale(Entity, sx, sy)
    local Transform = self.ECS:GetEntityComponents(Entity)["Transform"]

    if Transform then
        Transform.sx = sx or 1
        Transform.sy = sy or 1
    end
end

function Graphics:Update()
    local Entities = self.ECS:GetEntitiesWithComponent("Sprite")

    for _, Entity in ipairs(Entities) do
        local Transform = self.ECS:GetEntityComponents(Entity)["Transform"]
        local SpriteComponent = self.ECS:GetEntityComponents(Entity)["Sprite"]

        if Transform and SpriteComponent then
            local Sprite = self.Renderer.Entities[SpriteComponent.Name]

            if Sprite then
                Sprite.x = Transform.x
                Sprite.y = Transform.y
                Sprite.r = Transform.r or 0
                Sprite.sx = Transform.sx or 1
                Sprite.sy = Transform.sy or 1
            end
        end
    end
end

function Graphics:Draw()
    for _, Object in ipairs(self.Objects or {}) do
        self:DrawObject(Object)
    end

    self.Renderer:DrawAll()
end

function Graphics:DrawObject(Object)
    if Object.Sprite and Object.Sprite.Image then
        love.graphics.draw(
            Object.Sprite.Image,
            Object.x,
            Object.y,
            0,
            Object.width / Object.Sprite.Image:getWidth(),
            Object.height / Object.Sprite.Image:getHeight()
        )
    else
        love.graphics.setColor(1, 1, 0)
        love.graphics.rectangle("fill", Object.x, Object.y, Object.width, Object.height)
        love.graphics.setColor(1, 1, 1)
    end
end

function Graphics:GetECS()
    return self.ECS
end

return Graphics
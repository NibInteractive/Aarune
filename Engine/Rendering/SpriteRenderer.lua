local SpriteRenderer = {}
SpriteRenderer.__index = SpriteRenderer

function SpriteRenderer:New(Name)
    local MetaSpriteRenderer = setmetatable({}, SpriteRenderer)
    MetaSpriteRenderer.Name = Name or "Unnamed"
    MetaSpriteRenderer.Entities = {}

    return MetaSpriteRenderer
end

function SpriteRenderer:RegisterEntity(EntityID, ImagePath, Layer)
    if not EntityID or not ImagePath then return end
    local Image = love.graphics.newImage(ImagePath)

    self.Entities[EntityID] = {
        Image = Image,
        Layer = Layer or 1,
        x = 0, y = 0,
        r = 0, sx = 1, sy = 1,
        Width = Image:getWidth(),
        Height = Image:getHeight()
    }

    self:SortLayers()
end

function SpriteRenderer:UpdateEntityTransform(EntityID, x, y, r, sx, sy)
    local Sprite = self.Entities[EntityID]
    if not Sprite then return end

    Sprite.x, Sprite.y = x or Sprite.x, y or Sprite.y
    Sprite.r = r or Sprite.r
    Sprite.sx, Sprite.sy = sx or Sprite.sx, sy or Sprite.sy
end

function SpriteRenderer:SortLayers()
    self.Sorted = {}

    for _, Sprite in pairs(self.Entities) do
        table.insert(self.Sorted, Sprite)
    end
    
    table.sort(self.Entities, function(a, b)
        return a.Layer < b.Layer
    end)
end

function SpriteRenderer:Draw(Name, x, y, r, sx, sy)
    local Sprite = self.Entities[Name]
    if not Sprite then return end

    love.graphics.draw(
        Sprite.Image,
        x or 0,
        y or 0,
        r or 0,
        sx or 1,
        sy or 1
    )
end 

function SpriteRenderer:DrawAll()
    for _, Sprite in ipairs(self.Sorted or {}) do
        love.graphics.draw(
            Sprite.Image,
            Sprite.x,
            Sprite.y,
            Sprite.r,
            Sprite.sx,
            Sprite.sy
        )
    end
end

return SpriteRenderer
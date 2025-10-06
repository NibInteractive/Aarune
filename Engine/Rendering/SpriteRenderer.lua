local SpriteRenderer = {}
SpriteRenderer.__index = SpriteRenderer

function SpriteRenderer:New(Name)
    local MetaSpriteRenderer = setmetatable({}, SpriteRenderer)
    MetaSpriteRenderer.Name = Name or "Unnamed"
    MetaSpriteRenderer.Images = {}

    return MetaSpriteRenderer
end

function SpriteRenderer:NewSprite(Name, ImagePath, Layer, Width, Height)
    if not Name and ImagePath then return end
    local Image = love.graphics.newImage(ImagePath)

    self.Images[Name] = {
        Image = Image or nil,
        Width = Width or Image:getWidth(),
        Height = Height or Image:getHeight(),
        Layer = Layer or 1,
        x = 0,
        y = 0,
        r = 0,
        sx = 1,
        sy = 1
    }

    self:SortLayers()
    return self.Images[Name]
end

function SpriteRenderer:SetPosition(Name, x, y)
    local Sprite = self.Images[Name]
    if not Sprite then return end

    Sprite.x, Sprite.y = x, y
end

function SpriteRenderer:SetScale(Name, sx, sy)
    local Sprite = self.Images[Name]
    if not Sprite then return end

    Sprite.sx, Sprite.sy = sx or 1, sy or 1
end

function SpriteRenderer:SetRotation(Name, r)
    local Sprite = self.Images[Name]
    if not Sprite then return end
    
    Sprite.r = r or 0
end

function SpriteRenderer:SortLayers()
    self.Sorted = {}

    for _, Sprite in pairs(self.Images) do
        table.insert(self.Sorted, Sprite)
    end
    
    table.sort(self.Sorted, function(a, b)
        return a.Layer < b.Layer
    end)
end

function SpriteRenderer:Draw(Name, x, y, r, sx, sy)
    local Sprite = self.Images[Name]
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
    for _, sprite in ipairs(self.Sorted or {}) do
        love.graphics.draw(
            sprite.Image,
            sprite.x,
            sprite.y,
            sprite.r,
            sprite.sx,
            sprite.sy
        )
    end
end

return SpriteRenderer
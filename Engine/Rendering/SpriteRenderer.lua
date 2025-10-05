local SpriteRenderer = {}
SpriteRenderer.__index = SpriteRenderer

function SpriteRenderer:New(ImagePath, Layer, Width, Height)
    local MetaSpriteRenderer = setmetatable({}, SpriteRenderer)
    MetaSpriteRenderer.Image = love.graphics.newImage(ImagePath)
    MetaSpriteRenderer.Width = Width or MetaSpriteRenderer.Image:getWidth()
    MetaSpriteRenderer.Height = Height or MetaSpriteRenderer.Image:getHeight()

    return MetaSpriteRenderer
end
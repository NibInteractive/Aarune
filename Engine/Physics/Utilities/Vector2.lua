local Vector2 = {}
Vector2.__index = Vector2

function Vector2.New(x, y)
    return setmetatable({x = x or 0, y = y or 0}, Vector2)
end

function Vector2:Add(v)
    return Vector2.new(self.x + v.x, self.y + v.y)
end

function Vector2:Sub(v)
    return Vector2.new(self.x - v.x, self.y - v.y)
end

function Vector2:Mul(s)
    return Vector2.new(self.x * s, self.y * s)
end

function Vector2:Multiply(s)
    return self:Mul(s)
end

function Vector2:Div(s)
    return Vector2.new(self.x / s, self.y / s)
end

function Vector2:Division(s)
    return self:Div(s)
end

function Vector2:Dot(v)
    return self.x * v.x + self.y * v.y
end

function Vector2:Magnitude()
    return math.sqrt(self.x^2 + self.y^2)
end

function Vector2:Normalize()
    local Magnitude = self:Magnitude()
    if Magnitude == 0 then return Vector2.new(0, 0) end

    return self:Div(Magnitude)
end

return Vector2
local Camera = {}
Camera.__index = Camera

function Camera:Lerp(a, b, t)
    return a + (b - a) * t
end

function Camera:New()
    local MetaCamera = setmetatable({}, Camera)
    MetaCamera.x = 0
    MetaCamera.y = 0
    MetaCamera.ScaleX = 1
    MetaCamera.ScaleY = 1
    MetaCamera.Rotation = 0

    MetaCamera.DeadZoneWidth = 35
    MetaCamera.DeadZoneHeight = 20

    MetaCamera.CameraType = "Follow" -- Future use

    return MetaCamera
end

function Camera:Set()
    love.graphics.push()
    love.graphics.translate(-self.x, -self.y)
    love.graphics.scale(self.ScaleX, self.ScaleY)
    love.graphics.rotate(self.Rotation)
end

function Camera:Reset()
    love.graphics.pop()
end

function Camera:SetPosition(x, y)
    self.x = x
    self.y = y
end

--[[
Parameters:
    dt: Delta time
    Target: The object the camera should follow (should have x, y, width, height properties)
    CameraType: The type of camera movement ("Static", "Follow", "DeadFollow", "Custom")
    CustomData: A table containing custom data for the "Custom" camera type (e.g., a custom function)
if CameraType is "Custom", CustomData should include a 'Function' key with a function value.
IE:
    CustomData = {
        Function = function(self, dt, Target, CustomData)
            -- Custom camera logic here
        end
    }
]]
function Camera:Update(dt, Target, CameraType, CustomData)
    if not Target then return end
    CameraType = CameraType or self.CameraType or "Static"
    CustomData = CustomData or {}

    local ScreenWidth, ScreenHeigth = love.graphics.getWidth(), love.graphics.getHeight()
    local DeadZoneWidth, DeadZoneHeight = self.DeadZoneWidth / 2, self.DeadZoneHeight / 2

    local CamCenterX = self.x + ScreenWidth / 2
    local CamCenterY = self.y + ScreenHeigth / 2

    local PlayerX = Target.x + Target.width / 2
    local PlayerY = Target.y + Target.height / 2

    local Speed = 5

    local DeltaX, DeltaY = 0, 0

    -- Aren't I so nice for giving premade camera types?
    if CameraType == "Static" then 
        self.x = Target.x - love.graphics.getWidth() / 2
        self.y = Target.y - love.graphics.getHeight() / 2
    elseif CameraType == "Follow" then
        -- Dont mess with this, unless you know what you're doing
        local TargetX = Target.x - love.graphics.getWidth() / 2 + Target.width / 2
        local TargetY = Target.y - love.graphics.getHeight() / 2 + Target.height / 2

        self.x = self:Lerp(self.x, TargetX, Speed * dt)
        self.y = self:Lerp(self.y, TargetY, Speed * dt)
    elseif CameraType == "DeadFollow" then
        -- This one either, it's a bit complex
        if PlayerX < CamCenterX - DeadZoneWidth then
            DeltaX = PlayerX - (CamCenterX - DeadZoneWidth)
        elseif PlayerX > CamCenterX + DeadZoneWidth then
            DeltaX = PlayerX - (CamCenterX + DeadZoneWidth)
        end

        if PlayerY < CamCenterY - DeadZoneHeight then
            DeltaY = PlayerY - (CamCenterY - DeadZoneHeight)
        elseif PlayerY > CamCenterY + DeadZoneHeight then
            DeltaY = PlayerY - (CamCenterY + DeadZoneHeight)
        end

        self.x = self:Lerp(self.x, self.x + DeltaX, Speed * dt)
        self.y = self:Lerp(self.y, self.y + DeltaY, Speed * dt)
    elseif CameraType == "Custom" then
        if type(CustomData.Function) ~= "function" then
            return error("Custom camera requires a 'Function' in CustomData")
        end

        CustomData.Function(self, dt, Target, CustomData)
    else
        return error("Camera Type '" .. tostring(CameraType) .. "' not recognized.")
    end
end

return Camera
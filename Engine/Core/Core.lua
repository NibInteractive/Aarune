local Scene = require("Engine.Core.Scene")
local Camera = require("Engine.Core.Camera")
local Physics = require("Engine.Physics.Physics")

local Graphics = require("Engine.Rendering.Graphics")

local Settings = require("ProjectSettings")

local Engine = {}
Engine.Scenes = {}
Engine.CurrentScene = Scene.CurrentScene

Engine.Cameras = {}
Engine.CurrentCamera = nil

Engine.Objects = {}

Scene:SetEngine(Engine)

local function CreateSessionID()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

local SessionID = CreateSessionID()

function Engine:SetWindow(Title, Width, Height, Fullscreen, Resizable)
    love.window.setTitle(Title or "Aarune Engine Window")
    love.window.setMode(Width or 800, Height or 600, {
        fullscreen = Fullscreen or false,
        resizable = Resizable or false,
    })
end

function Engine:SetAdvancedWindow(Title, Width, Height, MinimumWidth, MinimumHeight, Fullscreen, Borderless, Resizable, VSync)
    if Borderless then Fullscreen = false end
    
    love.window.setTitle(Title or "Aarune Engine Window")
    love.window.setMode(Width or 800, Height or 600, {
        fullscreen = Fullscreen or false,
        borderless = Borderless or false,
        resizable = Resizable or false,
        vsync = VSync or false,
        minwidth = MinimumWidth or 400,
        minheight = MinimumHeight or 200,
    })
end

-- If you try and set borderless to true and fullscreen to true then it will cause an error.
function Engine:SetCustomWindow(Title, Width, Height, Settings)
    love.window.setTitle(Title or "Aarune Engine Window")
    love.window.setMode(Width or 800, Height or 600, Settings or {})
end

function Engine:INIT(SceneName, AdditionalObjects)
    self.CurrentScene = Scene:New(SceneName or "Main")
    self.CurrentCamera = Camera:New()
    self.CurrentScene:SetCamera(self.CurrentCamera)

    if AdditionalObjects and type(AdditionalObjects) == "table" then
        for _, Object in ipairs(AdditionalObjects) do
            self.CurrentScene:Add(Object)
        end
    end
end

function Engine:CreateScene(SceneName)
    local NewScene = Scene:New(SceneName or ("Scene" .. tostring(#self.Scenes + 1)))
    self.Scenes[SceneName] = NewScene

    return NewScene
end

function Engine:ChangeScene(SceneName)
    if not SceneName or type(SceneName) ~= "string" then return end
    local SceneToChange = self.Scenes[SceneName]
    if not SceneToChange then return end

    self.CurrentScene = SceneToChange
    self.CurrentCamera = SceneToChange.Camera or Camera:New()
    self.CurrentScene:SetCamera(self.CurrentCamera)
end

function Engine:LoadScene(Name)
    if not self.Scenes[Name] then
        self:CreateScene(Name)
    end

    self:ChangeScene(Name)
end

function Engine:AddObject(Object)
    if not self.CurrentScene or not Object then return end

    self.CurrentScene:Add(Object)
end

function Engine:AddObjects(Objects)
    if not self.CurrentScene or not Objects or type(Objects) ~= "table" then return end

    self.CurrentScene:AddObjects(Objects)    
end

function Engine:RemoveObject(Object)
    if not self.CurrentScene or not Object then return end

    self.CurrentScene:Remove(Object)    
end

function Engine:RemoveObjects(Objects)
    if not self.CurrentScene or not Objects or type(Objects) ~= "table" then return end

    for _, Object in ipairs(Objects) do
        self.CurrentScene:Remove(Object)
    end    
end

function Engine:ClearScene()
    if not self.CurrentScene then return end

    self.CurrentScene:Clear()        
end

function Engine:CreateCamera()
    local NewCamera = Camera:New()

    return NewCamera    
end

function Engine:Update(dt)
    if self.CurrentScene and self.CurrentScene.Update then
        self.CurrentScene:Update(dt)
    end

    for _, Object in ipairs(self.CurrentScene.Objects) do
        if Object.PhysicsType == "Dynamic" then
            Physics:Update(Object, dt)
            
            for _, Other in ipairs(self.CurrentScene.Objects) do
                if Other.PhysicsType == "Static" then
                    Physics:ResolveCollision(Object, Other)
                end
            end
        end
    end
end

function Engine:Draw()
    if self.CurrentScene then
        if Settings.General.VerboseLogging then
            love.graphics.print("Engine Session ID: " .. SessionID, 10, 30)
            love.graphics.print(
                "Camera Position: " .. math.floor(self.CurrentCamera.x) .. ", " .. math.floor(self.CurrentCamera.y), 10, 10
            )
            love.graphics.print("Current Scene: " .. self.CurrentScene.Name, 1920, 0)
        end

        self.CurrentScene:Draw()
    end
end

return Engine
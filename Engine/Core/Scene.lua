local Scene = {}
Scene.__index = Scene
Scene.CurrentScene = nil

local Engine

function Scene:SetEngine(EnginePath)
    Engine = EnginePath
end

function Scene:New(Name)
    local MetaScene = setmetatable({}, Scene)
    MetaScene.Name = Name or "Unnamed"
    MetaScene.Objects = {}
    MetaScene.Camera = nil

    return MetaScene
end

function Scene:Add(Object)
    table.insert(self.Objects, Object)
end

function Scene:AddObjects(Objects)
    for _, Object in ipairs(Objects) do
        table.insert(self.Objects, Object)
    end
end

function Scene:HasObject(Object)
    for i, v in pairs(self.Objects) do
        if v == Object then
            return true
        end
    end

    return false
end

function Scene:SetCamera(Camera)
    self.Camera = Camera
end

function Scene:Update(dt)
    if self.Camera and self.Camera.Update and self.Objects[1] then
        self.Camera:Update(dt, self.Objects[1])
    end

    for _, Object in ipairs(self.Objects) do
        if Object.Update then
            Object:Update(dt)
        end
    end
end

function Scene:Draw()
    if self.Camera and self.Camera.Set then
        self.Camera:Set()
    end

    for _, Object in ipairs(self.Objects) do
        if Object.Draw then
            Object:Draw()
        end
    end

    if self.Camera and self.Camera.Reset then
        self.Camera:Reset()
    end
end

function Scene:Clear()
    self.Objects = {}    
end

function Scene:ChangeScene(Name)
    if not Engine then return end
    Engine:ChangeScene(Name)
end

function Scene:Remove(Object)
    if not Object then return end

    for i, Obj in ipairs(self.Objects) do
        if Obj == Object then
            table.remove(self.Objects, i)
            break
        end
    end
end

function Scene:RemoveScene(_Scene)
    if not _Scene or getmetatable(_Scene) ~= _Scene then return end

    self.Objects = {}
    self.Camera = nil
    Scene[_Scene] = nil
end

return Scene
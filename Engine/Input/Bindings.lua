local Bindings = {}
Bindings.__index = Bindings

function Bindings:New()
    local MetaBindings = setmetatable({}, Bindings)
    MetaBindings.Keys = {}

    return MetaBindings
end

function Bindings:Callback(Action, Callback)
    if not Action or not Callback then return end

    if love.keyboard.isDown(Action) then
        Callback()
    end    
end

function Bindings:BindKey(Action, Key)
    self.Keys[Action] = Key
end

function Bindings:BindKeys(KeyTable)
    for Action, Key in pairs(KeyTable) do
        self.Keys[Action] = Key
    end
end

function Bindings:RebindKey(Action, NewKey)
    self.Keys[Action] = NewKey    
end

function Bindings:GetKey(Action)
    return self.Keys[Action]    
end

function Bindings:IsKeyPressed(Action)
    local Key = self.Keys[Action]
    if not Key then return false end

    return love.keyboard.isDown(Key)
end

function Bindings:IsKeyReleased(Action)
    local Key = self.Keys[Action]
    if not Key then return false end

    return not love.keyboard.isDown(Key)
end

function Bindings:GetAllBindings()
    return self.Keys
end

function Bindings:PrintBindings()
    local Output = ""
    local Intervals = 0

    for Action, Key in pairs(self.Keys) do
        Output = Output .. Action .. ": " .. Key .. "\n"
        Intervals = Intervals + 1
    end
    return Output:sub(1, -2), Intervals
end

function Bindings:UnbindKey(Action)
    self.Keys[Action] = nil    
end

function Bindings:ClearBindings()
    self.Keys = {}    
end

return Bindings
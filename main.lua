local Engine = require("Engine.Core.Core")
local Bindings = require("Engine.Input.Bindings")
local Physics = require("Engine.Physics.Physics")

local GamePhysics = Physics:New()

local PlayerBindings = Bindings:New()

function love.load()
    PlayerBindings:BindKeys({
        MoveRight = "d",
        MoveLeft = "a",
        MoveUp = "w",
    })

    local Player = {
        x = 100,
        y = 100,
        width = 32,
        height = 32,
        speed = 200,

        -- Physics properties --
        vx = 0, -- vx : horizontal velocity
        vy = 0, -- vy : vertical velocity
        PhysicsType = "Dynamic",
        OnGround = false,

        Update = function(self, dt)
            if PlayerBindings:IsKeyPressed("MoveRight") then self.x = self.x + self.speed * dt end
            if PlayerBindings:IsKeyPressed("MoveLeft") then self.x = self.x - self.speed*dt end

            if PlayerBindings:IsKeyPressed("MoveUp") and self.OnGround then
                self.vy = -400 -- Jump Strength
                self.OnGround = false
            end

            GamePhysics:Update(self, dt)
        end,

        Draw = function(self)
            love.graphics.setColor(1, 1, 0)
            love.graphics.circle("fill", self.x, self.y, self.width)
            love.graphics.setColor(1, 1, 1)
        end,
    }

    local Platform = {
        x = 0,
        y = 550,
        width = 800,
        height = 50,

        Draw = function(self)
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            love.graphics.setColor(1, 1, 1)
        end,
    }

    local Box = {
        x = 300,
        y = 300,
        width = 50,
        height = 50,

        Draw = function(self)
            love.graphics.setColor(0, 1, 0)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            love.graphics.setColor(1, 1, 1)
        end,
    }

    local Box2 = {
        x = 750,
        y = 450,
        width = 75,
        height = 50,

        Draw = function(self)
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            love.graphics.setColor(1, 1, 1)
        end,
    }

    GamePhysics:StaticBodies({ Platform, Box, Box2 })
    GamePhysics:ApplyFriction(Player, 0.8)
    
    Engine:SetWindow("Aarune Engine Example", 800, 600, true, true)
    Engine:INIT("Main", {Player, Platform, Box, Box2})
end

function love.update(dt)
    Engine:Update(dt)
end

function love.draw()
    Engine:Draw()

    local BindingsList, Count = PlayerBindings:PrintBindings()
    
    love.graphics.print("Objects in Scene: " .. #Engine.CurrentScene.Objects, 10, 50)
    love.graphics.print(BindingsList, 10, 70)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 90 + (Count * 9))
end
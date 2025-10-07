local Engine = require("Engine.Core.Core")
local Bindings = require("Engine.Input.Bindings")
local Physics = require("Engine.Physics.Physics")

local Graphics = require("Engine.Rendering.Graphics")

local GamePhysics = Physics:New()
local PlayerBindings = Bindings:New()

function love.load()
    GFX = Graphics:New()

    PlayerImage = love.graphics.newImage("Assets/Robin.jpg")

    Chopper = GFX:AddSpriteEntity("Assets/Chopper.jpg", 3, 1600, 50, 0.45, 0.45)
    Nami = GFX:AddSpriteEntity("Assets/Nami.jfif", 4, 300, 500, 1.25, 1.25)

    PlayerBindings:BindKeys({
        MoveRight = "d",
        MoveLeft = "a",
        MoveUp = "w",
    })

    local Player = {
        x = 100,
        y = 100,
        width = 45,
        height = 45,
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
            love.graphics.draw(PlayerImage, self.x, self.y, 0, self.width / PlayerImage:getWidth(), self.height / PlayerImage:getHeight())

            --[[love.graphics.setColor(1, 1, 0)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            love.graphics.setColor(1, 1, 1)]]
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
        x = 350,
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
        x = 700,
        y = 450,
        width = 95,
        height = 50,

        Draw = function(self)
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            love.graphics.setColor(1, 1, 1)
        end,
    }

    local Box3 = {
        x = 575,
        y = 400,
        width = 75,
        height = 50,

        Draw = function(self)
            love.graphics.setColor(1, 0, 1)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            love.graphics.setColor(1, 0, 1)
        end,
    }

    local Box4 = {
        x = 450,
        y = 350,
        width = 75,
        height = 50,

        Draw = function(self)
            love.graphics.setColor(1, 0.5, .75)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            love.graphics.setColor(1, 0.5, .75)
        end,
    }

    local Circle = {
        x = 500,
        y = 500,
        width = 25,
        height = 25,

        Draw = function(self)
            love.graphics.setColor(1, .5, 0)
            love.graphics.circle("fill", self.x, self.y, self.width, self.height)
            love.graphics.setColor(1, 1, 1)
        end,
    }

    local Circle2 = {
        x = 500,
        y = 500,
        width = 25,
        height = 25,

        Draw = function(self)
            love.graphics.setColor(1, .5, 0)
            love.graphics.circle("fill", self.x, self.y, self.width, self.height)
            love.graphics.setColor(1, 1, 1)
        end,
    }

    GamePhysics:StaticBodies({ Platform, Box, Box2, Box3, Box4, Circle })
    GamePhysics:ApplyFriction(Player, 0.8)
    
    Engine:SetWindow("Aarune Engine Example", 800, 600, true, true)
    Engine:INIT("Main", {Player, Platform, Box, Box2, Box3, Box4, Circle})

    --[[Engine:CreateScene("Secondary")
    Engine:ChangeScene("Secondary")]]
end

function love.update(dt)
    Engine:Update(dt)
    GFX:Update()
end

function love.draw()
    Engine:Draw()

    local BindingsList, Count = PlayerBindings:PrintBindings()
    
    love.graphics.print("Objects in Scene: " .. #Engine.CurrentScene.Objects, 10, 50)
    love.graphics.print(BindingsList, 10, 70)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 90 + (Count * 9))

    GFX:Draw()
end
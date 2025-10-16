local Engine = require("Engine.Core.Core")

local ProjectManager = require("Engine.Project.ProjectManager")

local Editor = {}
Editor.__index = Editor

function Editor.new()
    local self = setmetatable({}, Editor)
    self.currentProject = nil
    self.scroll = 0

    return self
end

function Editor:loadProject(project)
    ProjectManager:LoadProject(project)

    self.currentProject = CURRENT_PROJECT

    love.window.setTitle(self.currentProject.name or "Aarune Project")
    love.window.setMode(1920, 1080, {
        fullscreen = true,
        resizable = false,
    })
    love.window.setVSync(false) -- You literally have a BUILT IN window function, 3 infact, why manual? Besides, look at line 1, REAL QUICK
end

function Editor:update(dt)
    local up = love.keyboard.isDown("up")
    local down = love.keyboard.isDown("down")

    if up then self.scroll = self.scroll + 100 * dt end
    if down then self.scroll = self.scroll - 100 * dt end
end

function Editor:draw()
    love.graphics.clear(0.12, 0.12, 0.15)
    love.graphics.setColor(1,1,1)

    if self.currentProject then
        love.graphics.print("Editing Project: " .. self.currentProject.name, 50, 50)
        love.graphics.print("Path: " .. self.currentProject.path, 50, 70)
        love.graphics.print("Config keys:", 50, 90)
        local y = 110 - self.scroll
        for k,v in pairs(self.currentProject.config) do
            love.graphics.print(k .. ": " .. tostring(v), 60, y)
            y = y + 20
        end
    else
        love.graphics.print("No project loaded", 50, 50)
    end

    local bx, by, bw, bh = 400, 600, 150, 40
    love.graphics.setColor(0.2, 0.7, 0.3)
    love.graphics.rectangle("fill", bx, by, bw, bh, 6)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Play Project", bx + 20, by + 10)
end

function Editor:mousepressed(x, y, button)
    if button == 1 then
        local bx, by, bw, bh = 400, 600, 150, 40
        if x > bx and x < bx + bw and y > by and y < by + bh then
            local ProjectManager = require("Engine.Project.ProjectManager")

            if CURRENT_PROJECT then
                ProjectManager:PlayProject()
                GAMESTATE = "game"
            else
                print("⚠ No project loaded.")
            end
        end
    end
end

return Editor

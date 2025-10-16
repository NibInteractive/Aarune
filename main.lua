local ProjectSelector = require("Engine.Project.ProjectSelector")
local EditorModule = require("Engine.Project.Editor")

local Engine = require("Engine.Core.Core")

local selector
local Editor
local GAMESTATE

function love.load()
    Editor = EditorModule.new()
	GAMESTATE = "selector"
	selector = ProjectSelector.new()
    
    WIDTH = love.graphics.getWidth()
    HEIGHT = love.graphics.getHeight()

    Engine:SetWindow("Aarune", WIDTH, HEIGHT, true, false)
end

function love.update(dt)
    if GAMESTATE == "editor" then
	    Editor:update(dt)
    elseif GAMESTATE == "selector" then
        selector:update(dt)
    end
end

function love.draw() -- who the actual FUCK codes like this?
    if GAMESTATE == "editor" then
		Editor:draw()
	else
		selector:draw()
	end
end

function love.mousepressed(x, y, b)
	 if GAMESTATE == "editor" then
        Editor:mousepressed(x, y, b)
    else
        selector:mousepressed(x, y, b)
        
        if selector.selected then
            Editor:loadProject(selector.selected)
            GAMESTATE = "editor"
        end
    end
end
-- OMG OMG, AI IS THAT AI????

local ProjectManager = require("Engine.Project.ProjectManager")

local ProjectSelector = {}
ProjectSelector.__index = ProjectSelector

function ProjectSelector.new()
	local self = setmetatable({}, ProjectSelector)
	self.projects = ProjectManager:GetProjects()
	self.selected = nil
	self.scroll = 0

	-- Load most recent project
	local recentPath = ProjectManager:LoadRecent()
	if recentPath then
		for _, proj in ipairs(self.projects) do
			if proj.path == recentPath then
				self.selected = proj
			end
		end
	end

	return self
end

function ProjectSelector:update(dt)
	-- Simple scroll control (mouse wheel)
	local up = love.mouse.isDown(3)
	local down = love.mouse.isDown(4)

	if up then
		self.scroll = self.scroll + dt * 50
	elseif down then
		self.scroll = self.scroll - dt * 50
	end
end

function ProjectSelector:draw()
	love.graphics.clear(0.1, 0.1, 0.12)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Select a Project", 50, 40)

	local y = 100 - self.scroll
	for _, proj in ipairs(self.projects) do
		local isSelected = (self.selected == proj)
		local bx, by, bw, bh = 50, y, 300, 50

		-- Highlight selected project
		if isSelected then
			love.graphics.setColor(0.2, 0.6, 1)
		else
			love.graphics.setColor(0.2, 0.2, 0.25)
		end
		love.graphics.rectangle("fill", bx, by, bw, bh, 8)

		love.graphics.setColor(1, 1, 1)
		love.graphics.print(proj.name, bx + 10, by + 15)

		y = y + 60
	end

	-- Open button
	if self.selected then
		love.graphics.setColor(0.2, 0.7, 0.3)
	else
		love.graphics.setColor(0.3, 0.3, 0.3)
	end
    
	love.graphics.rectangle("fill", 400, 500, 150, 40, 6)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Open Project", 420, 510)
end

function ProjectSelector:mousepressed(x, y, button)
	if button ~= 1 then return end

	-- Detect project clicks
	local listY = 100 - self.scroll
	for _, proj in ipairs(self.projects) do
		if x > 50 and x < 350 and y > listY and y < listY + 50 then
			self.selected = proj
			return
		end
		listY = listY + 60
	end

	-- Detect "Open Project" click
	if self.selected and x > 400 and x < 550 and y > 500 and y < 540 then
		ProjectManager:LoadProject(self.selected)
		ProjectManager:SaveRecent(self.selected)
		GAMESTATE = "editor"
	end
end

return ProjectSelector


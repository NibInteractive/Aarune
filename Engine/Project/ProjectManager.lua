-- This is fucking dogshit code, lucky the module even returns shit

local ProjectManager = {}
ProjectManager.__index = ProjectManager
ProjectManager.Projects = {}
ProjectManager.Project = nil
ProjectManager.ProjectPath = nil

local lfs = love.filesystem
local json = require("Engine.libs.dkjson")

-- Load Engine fresh or use existing one
local Engine = require("Engine.Core.Core")  -- or clone if you want isolation
Engine:INIT("Main") -- create a new scene/camera

local function ReadJSON(Path)
    local Content, size = love.filesystem.read(Path)
    if not Content then
        error("Failed to read file: " .. tostring(Path))
    end

    local Data, idk, Error = json.decode(Content, 1, nil)
    if Error then
        error("JSON decode error in " .. Path .. ": " .. Error)
    end

    return Data
end

local function writeJSON(Path, Data)
	local Content, Error = json.encode(Data, { indent = true })
	if not Content then
		error("JSON encode error: " .. tostring(Error))
	end

	local Success, Error = love.filesystem.write(Path, Content)
	if not Success then
		error("Failed to write file: " .. tostring(Error))
	end
end

-- Huh?
function ProjectManager:ProjectInformation(Project)
    
end

function ProjectManager:GetProjects()
    local Directories = lfs.getDirectoryItems("Projects")
    local ValidProjects = {}

    for _, Directory in ipairs(Directories) do
        local ConfigPath = "Projects/" .. Directory .. "/Config/project.json"

        if lfs.getInfo(ConfigPath) then
            table.insert(ValidProjects, {
                name = Directory,
                Path = "Projects/" .. Directory,
                configPath = ConfigPath
            })
        end
    end

    return ValidProjects
end

-- God, imagine going so insane you write comments about code when you're only one guy making it, haha, couldn't be me though right?
function ProjectManager:LoadProject(Project)
	local Data = ReadJSON(Project.configPath)
	if not Data or not Data.name then
		error("Invalid or missing project.json in " .. Project.name)
	end

	-- Optional version checking
	if Data.engineVersion and Data.engineVersion ~= "v0.8.2-Prototype" then -- Who manually changes the damn version?
		print(("⚠ Version mismatch: Project %s was made for engine version %s"):format(Project.name, tostring(Data.engineVersion)))
	end

	CURRENT_PROJECT = {
		name = Data.name,
		Path = Project.Path,
		config = Data
	}

	print("✅ Loaded project: " .. Data.name)
end

function ProjectManager:PlayProject()
	if not CURRENT_PROJECT then
		error("No project loaded to play.")
	end

	local Entry = CURRENT_PROJECT.config.entry or "main.lua"
	local EntryPath = CURRENT_PROJECT.Path .. "/Scripts/" .. Entry

	local Chunk, Error = love.filesystem.load(EntryPath)

	if not Chunk then
		error("Failed to load entry script: " .. tostring(Error))
	end

	-- Sandbox environment: inject Engine, Scene, etc
	local env = setmetatable({
		Engine = Engine,
		Scene = Engine.CurrentScene,
		Camera = Engine.CurrentCamera,
		Vector2 = Engine.Vector2,
		print = print,
		CURRENT_PROJECT = CURRENT_PROJECT
	}, { __index = _G })
	setfenv(Chunk, env)

	-- Run the project code
	local ok, runErr = pcall(Chunk)
	if not ok then
		error("Error running entry script: " .. tostring(runErr))
	end

	GAMESTATE = "game"
	print("🎮 Project running: " .. CURRENT_PROJECT.name)
end

function ProjectManager:SaveRecent(Project)
	local Path = "recent.json"
	local Recent = {}

	if love.filesystem.getInfo(Path) then
		-- recent = ReadJSON(Path) or {}
	end

	Recent.lastOpened = Project.Path
	writeJSON(Path, Recent)
end

function ProjectManager:LoadRecent()
	local Path = "recent.json"

	if love.filesystem.getInfo(Path) then
		local Recent = ReadJSON(Path)

		if Recent and Recent.lastOpened then
			return Recent.lastOpened
		end
	end

	return nil
end

return ProjectManager
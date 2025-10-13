local EngineRoot = "Engine"
local RequireList = {}

local function ToRequirePath(Path)
    Path = Path:gsub("%.lua$", "")
    Path = Path:gsub("\\", ".")
    Path = Path:gsub("/", ".")
    return Path
end

local function ScanFolder(Folder)
    local p = io.popen('dir "' .. Folder .. '" /b /a')

    for Item in p:lines() do
        local FullPath = Folder .. "\\" .. Item
        local Attr = io.popen('if exist "' .. FullPath .. '\\*" (echo dir) else (echo file)'):read("*l")
        
        if Attr == "dir" then
            ScanFolder(FullPath)
        elseif Item:match("%.lua$") then
            local RequirePath = ToRequirePath(FullPath)
            local VariableName = Item:gsub("%.lua$", "")

            table.insert(RequireList, ("%s = require(\"%s\")"):format(VariableName, RequirePath))
        end
    end
end

ScanFolder(EngineRoot)

for _, line in ipairs(RequireList) do
    print(line)
end

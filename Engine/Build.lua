local Exporter = {}

-- Fuck me

-- Utility function for running shell commands
local function exec(cmd)
	local handle = io.popen(cmd)
	local result = handle:read("*a")
	handle:close()
    
	return result
end

local function createShortcut(exePath, shortcutPath, iconPath)
    -- forward slashes to avoid double-backslash issues
    exePath = exePath:gsub("\\", "/")
    shortcutPath = shortcutPath:gsub("\\", "/")
    if iconPath then
        iconPath = iconPath:gsub("\\", "/")
    end

    local iconLine = ""
    if iconPath then
        iconLine = "$s.IconLocation = '" .. iconPath .. "';"
    end

    -- Use single quotes for paths in PowerShell
    local psCmd = "$W = New-Object -ComObject WScript.Shell; $s = $W.CreateShortcut('" .. shortcutPath .. "'); $s.TargetPath = '" .. exePath .. "'; " .. iconLine .. " $s.Save()"

    -- wrap the whole command in double quotes for Lua os.execute
    os.execute('powershell -NoProfile -ExecutionPolicy Bypass -Command "' .. psCmd .. '"')
end

-- Export project to a standalone EXE
function Exporter.Export(gameName, srcDir, engineDir)
	gameName = gameName or "MyGame"
	srcDir = srcDir or "Projects"
	engineDir = engineDir or "Engine" -- default engine folder

	local lovePath = "LoveRuntime"
	local buildPath = "TempBuild"
	local exportPath = "Exports"

	-- create folders if missing
	os.execute(("mkdir %s"):format(buildPath))
	os.execute(("mkdir %s"):format(exportPath))

	-- copy project into temp build
    local tempProject = buildPath .. "\\Project"
	os.execute(("xcopy /E /I /Y \"%s\" \"%s\" > nul"):format(srcDir, tempProject))

	local loveFile = ("%s\\%s.love"):format(buildPath, gameName)
	local finalExe = ("%s\\%s.exe"):format(exportPath, gameName)

    print("[Exporter] Copying engine into project folder for export...")
	os.execute(("xcopy /E /I /Y \"%s\" \"%s\\Engine\" > nul"):format(engineDir, tempProject))

	print("[Exporter] Building .love file...")

	-- zip source folder into .love
	local zipCmd = ([[powershell -command "Compress-Archive -Path '%s/*' -DestinationPath '%s'" ]]):format(srcDir, loveFile .. ".zip")
	exec(zipCmd)
	os.rename(loveFile .. ".zip", loveFile)

	print("[Exporter] Fusing with Love2D runtime...")

	-- fuse .love with love.exe
	local fuseCmd = ([[copy /b "%s\love.exe"+"%s" "%s" > nul]]):format(lovePath, loveFile, finalExe)
	os.execute(fuseCmd)

	-- copy required DLLs
	print("[Exporter] Copying DLLs...")
	os.execute(([[xcopy "%s\*.dll" "%s\" /Y > nul]]):format(lovePath, exportPath))
    
    print("[Exporter] Cleaning up temp files...")
    --os.execute(("rmdir /S /Q %s"):format(buildPath))

    local desktopPathHandle = io.popen([[powershell -command "[Environment]::GetFolderPath('Desktop')"]])
	local desktopPath = desktopPathHandle:read("*a"):gsub("%s+$", "")
	desktopPathHandle:close()

    local currentDirHandle = io.popen("cd")
    local currentDir = currentDirHandle:read("*a"):gsub("%s+$", "")
    currentDirHandle:close()

    finalExe = currentDir .. "\\" .. exportPath .. "\\" .. gameName .. ".exe"

    local shortcutPath = ("%s\\%s.lnk"):format(desktopPath, gameName)
    
	print("[Exporter] Creating shortcut on desktop...")
	createShortcut(finalExe, shortcutPath)

	print(("[Exporter] Done! ✅ %s created successfully."):format(finalExe))
end

return Exporter
local FileManagement = {}
FileManagement.__index = FileManagement

function FileManagement:SetDirectory(Directory)
    
end

function FileManagement:CreateFile(FileName, FileType, FilePath)
    love.filesystem.newFile()
end

return FileManagement
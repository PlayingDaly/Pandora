require "libs.fileActions"
require "libs.utils"


--Folder Actions
Folder = {}

function Folder:GetDirs(path)
    local dirs = {}
    local dirPath = ''
    for path in path:gmatch("[^/]+") do
        dirPath = dirPath.."/"..path

        if filesystem.isDir(dirPath) then
            table.insert(dirs,dirPath)
        end
    end
    return dirs
end
function Folder:CreateDir(path)
    return filesystem.createDir(path)
end
function Folder:GetChildren(path)
	if filesystem.isDir(path) then
		return filesystem.childs(path)
	end
end
function Folder:CopyFolderToBuffer(src, excludepaths, recursive)
    local fileList = {}
    local folderChildren = self:GetChildren(src)

    if folderChildren then
        for k,v in pairs(folderChildren) do 
            local path = src.."/"..v

            --Check if path is excluded
            local exPath = false

            if excludepaths then
                for ek,ev in ipairs(excludepaths) do
                    if string.find(path,ev) then
                        exPath = true
                        break
                    end
                end
            end

            if filesystem.isDir(path) and recursive and not exPath then
                local childFiles = self:CopyFolderToBuffer(path, excludepaths, recursive)

                if childFiles then
                    for ck,cv in ipairs(childFiles) do
                        --fileList[k+1] = cv
                        table.insert(fileList,cv)
                    end
                end
            elseif filesystem.isFile(path) then
                table.insert(fileList,File:CreateCopyItem(path))
            end
        end
    end

    return fileList
end
function Folder:WriteFolderBuffer(rootpath,buff)
    local rootpath = rootpath or ''
    Log.Information("Copying Files in Buffer")
    for k,v in ipairs(buff) do
        v:Copy(rootpath)
    end
end

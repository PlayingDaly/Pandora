require "libs.utils"
--File Actions
File = {}

function File:Exists(path)
    return filesystem.exists(path)
end
function File:OpenFile(path)
    if filesystem.isFile(path) then
        local fileData = filesystem.open(path,"r")
        return fileData
    end
end
function File:Read(path)
    if filesystem.isFile(path) then
        local fileData = filesystem.open(path,"r")

        if fileData then
            local data = fileData:read("*all")
            return data
        end
    end
end

function File:Write(path, data)
    local fileData = filesystem.open(path,"w")
    fileData:write(data)
end
function File:Copy(src, dest)
    local srcfile = File:Read(src)

    if srcFile then
        File:Write(dest,srcfile)
    end
end
function File:Move(src,dest)
    filesystem.move(src,dest)
end
function File:Delete(path)
    return filesystem.remove(path)
end


--Protected File Copy Item
function FileCopyItem(path)
    local this = {
        path = path,
        data = File:Read(path)
    }
    function this:Details()
        local l = string.len(self.data) or 0
        return string.format("File Copy Item. \tPath:%s\t\tCharSz:%s",self.path, l)
    end
    function this:CreateParentDir(path)
        return filesystem.createDir(path)       --Note: As of 080121 this will always return false
    end
    function this:GetParentDirs(path)
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
    function this:VerifyParentDir(path, createIfMissing)
        local dirPath = ''
        local sPath = string.sub(self.path,1,Utils.strings.lastIndexOfChar(self.path,"/"))

        --Assuming if the path ends with a / then its a dir
        if Utils.strings.ends_with(path,'/') then
            local r = self:CreateParentDir(path)            

            if Utils.strings.starts_with(sPath, "/") then
                sPath = string.sub(sPath,2)
            end
            dirPath = path..sPath
        else
            dirPath = sPath
        end

        --Iterates through 
        local bpath = ''
        for p in dirPath:gmatch("[^/]+") do
            bpath = bpath.."/"..p
            
            if not filesystem.exists(bpath) and createIfMissing then
                self:CreateParentDir(bpath)
            end
        end
    end
    function this:Copy(rootDir)
        local rootDir = rootDir or ''
        local sPath = self.path

        --Split the path and verify the dirs exist, if not create them
        self:VerifyParentDir(rootDir, true)

        --Write the data to the file
        if Utils.strings.starts_with(sPath, "/") then
            sPath = string.sub(sPath,2)
        end
        
        rootDir = rootDir..sPath
        --rootDir = string.gsub(rootDir..sPath,"//","/")
        Log.Debug("Writing:\t"..rootDir)
        File:Write(rootDir,self.data)
    end
    return this
end

function File:CreateCopyItem(path, data)
    --Remove the Leading / -- this is causing improper directory creation --  How to resolve
    if Utils.strings.starts_with(path, "//") then
        path = string.sub(path,2)
    end

      return FileCopyItem(path,data)
end

--Original Implementation provided by safisynai 
--https://gist.github.com/safisynai/8a9e3aab93833cfe3ec4c5dc4e167dec

---------------------------------------------------------------------
--  Implementation by playingdaly for FIN a Satisfactory modified  --
---------------------------------------------------------------------

local fs = filesystem


local USER_INIT = "/src/os/PAN.lua"

local function loadFile(filename)
  local file = fs.open(filename, "r")

  if file then
    local code = file:read("*all")

    file:close()

    if code then
      return load(code, filename)
    else
      return nil, "Error reading " .. filename
    end
  else
    return nil, "Error opening " .. filename
  end
end

local function loadModuleFile(modName, filename)
  local modFn, err = loadFile(filename)

  if err then
    print(err)
    error("Error loading module `" .. modName .. "`")
  end

  return modFn()
end

local package = {
  --path = "/src/?.lua;/src/libs/?.lua;/src/os/?.lua;/src/listeners/?.lua",
  path = "/src/?.lua;",
  loaded = {},
  searchers = {}
}

local function fsSearcher(modName)
  local modFile, err = package.searchpath(modName, package.path)

  if modFile then return loadModuleFile, modFile end

  return err
end

table.insert(package.searchers, (fsSearcher))

function package.searchpath(name, path, sep, rep)
  sep = sep or "%."
  rep = rep or "/"

  name = name:gsub(sep, rep)

  local pathsTried = setmetatable({}, { __index = table })

  for path in path:gmatch("[^;]+") do
    path = path:gsub("?", name)

    if fs.exists(path) then
      local file = fs.open(path, "r")

      if file then
        -- File was opened okay, return its path, after we close it
        file:close()

        return path
      end
    end

    pathsTried:insert(path)
  end

  return nil, "searchpath could not find/open any of:\n" .. pathsTried:concat("\n")
end

-- Minimal (i.e. incomplete) implementation of Lua module API
function require(modName)
  local mod = package.loaded[modName]

  -- We already have the module in cache, return it from there
  if mod then return mod end

  local loader, loaderArg
  local errs = setmetatable({}, { __index = table })

  for _, searcher in ipairs(package.searchers) do
    local loaderOrErr, arg = searcher(modName)

    if type(loaderOrErr) == "function" then
      loader = loaderOrErr
      loaderArg = arg

      break
    else
      errs:insert(loaderOrErr)
    end
  end

  if loader then
    mod = loader(modName, loaderArg)

    if mod then
      package.loaded[modName] = mod
    elseif package.loaded[modName] ~= nil then
      package.loaded[modName] = true
    end

    return package.loaded[modName]
  else
    if #errs > 0 then
      for _, err in ipairs(errs) do
        print(err)
      end

      error("Could not find loader for module `" .. modName .. "`, errors above")
    else
      error("Could not find loader for module `" .. modName .. "`")
    end
  end

  error("Failed to load module `" .. modName .. "`")
end

-- We scan all storage for src/init.lua as our main code might not necessarily be on the boot drive

local function mountRootFS()
  for _, f in ipairs(fs.childs("/dev")) do
    if f ~= "serial" then
      if fs.mount("/dev/" .. f, "/") then
        if fs.exists(USER_INIT) then
          -- We found our rootfs, nothing more to do here
          return
        else
          if fs.unmount("/") ~= true then
            error "Failed to unmount rootfs"
          end
        end
      end
    end
  end

  return nil, "Unable to find root FS"
end

-- TODO: rename userInit to main
local function init()
  local err = mountRootFS()

  if err then error(err) end

  local userInit, err = loadFile(USER_INIT)

  if err then error(err) end

  --Launch the File
  userInit()
end

init()
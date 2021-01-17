local fs = filesystem

local INIT_FILE = "/boot/boot.lua"

local function tryLoadInit(devNode)
  if fs.mount("/dev/" .. devNode, "/boot") ~= true then
    return nil, "Unable to mount FS `" .. devNode .. "`"
  end

  if fs.exists(INIT_FILE) then
    local initFile = fs.open(INIT_FILE, "r")

    if initFile then
      local code = initFile:read("*all")

      initFile:close()

      if code then
        return load(code, INIT_FILE)
      else
        return nil, "Error reading init.lua on `" .. devNode .. "`"
      end
    else
      return nil, "Unable to open init.lua on `" .. devNode .. "`"
    end
  else
    return nil, "Unable to find init.lua on `" .. devNode .. "`"
  end
end

-- Scans all available filesystems for "init.lua" at FS root and executes
-- the first match found
local function boot()
  if fs.initFileSystem("/dev") ~= true then error("Failed to mount /dev") end

  local initFn
  local errs = setmetatable({}, { __index = table })

  for _, entry in ipairs(fs.childs("/dev")) do
    if entry ~= "serial" then
      initFn, err = tryLoadInit(entry)

      if initFn then
        -- Break out of the loop rather than executing here, just to ensure
        -- our iterator goes out of scope and can be GC'd
        break
      else
        errs:insert(err)
      end
    end
  end

  if initFn then
    -- All good, drop any errors from other drives we tried to save mem
    errs = nil

    return initFn()
  else
    for _, err in ipairs(errs) do
      print(err)
    end

    error "Failed to boot, please review the above messages for the cause"
  end
end

boot() 
--Handles the copying of files
--Creates print notifications for the copying/startup
--Print notifications needs to write to screen if one is detected


local fs = filesystem
local mainDriveID = nil
local nic = component.proxy(component.findComponent("networkCard"))[1]
local rcp = 9997
local finalEEprom = ''
local allFilesSent = false

local function networkSetup()
    print("Setting up Network Connection")
    networkCard = component.proxy(component.findComponent("networkCard"))
    
    if not networkCard[1] then 
        computer.panic("Please Install a network card and name it networkCard before continuing")
    else 
        nic = networkCard[1]
    end

    if nic then 
        event.listen(nic)
        nic:open(rcp) 
        print("Network Configured and listening on port ", rcp)
    end
end
local function RewriteEEProm(prom)
	computer.setEEPROM(prom)	
	computer.reset()
	computer.beep()
end
local function boot()
    print("Attempting to Boot Primary Drive")
    if fs.initFileSystem("/dev") ~= true then error("Failed to mount /dev") end
    for _, entry in ipairs(fs.childs("/dev")) do
        if entry ~= "serial" then
            mainDriveID = entry
            print("Primary Drive Found")
            print("Boot Successful for Intermediate EEprom")
        end
    end  
    networkSetup()
end

function Write(path, data)
    local fileData = filesystem.open(path,"w")
    fileData:write(data)
end
function Copy(path, data)
    local rootDir = '/'
    local sPath = path

    --Split the path and verify the dirs exist, if not create them
    self:VerifyParentDir(rootDir, true)

    --Write the data to the file
    if Utils.strings.starts_with(sPath, "/") then
        sPath = string.sub(sPath,2)
    end

    rootDir = rootDir..sPath
    print("Writing:\t"..rootDir)
    Write(rootDir,data)
end

--Startup
boot()


if not mainDriveID then
    --computer.beep()
    computer.panic("Please Insert a hard drive and restart the computer") 
end


while true do

    if allFilesSent and allFilesSent ~= false and finalEEprom ~= '' then
        RewriteEEProm(finalEEprom)
    end
    
    e = table.pack(event.pull(0.1))
	
	if e[1] == "NetworkMessage" and e[4]== rcp then
		local msg = e[1]
		local s = e[2]
		local sender = e[3] --Central core
		local port = e[4]
		local message = e[5] -- CODE
		local path = e[6]	-- File path
		local data = e[7]	-- File Data

        if code == "0x0014" and path and data then
            --Write the Data to the drive
            Copy(path,data)
            --nic:send(sender,port,"0x0002")
        elseif code == "0x0016" then
            --Code is file transmit complete
            allFilesSent = true
            nic:send(sender,port,"0x0015")
        elseif code == "0x0013" then
            --Receive last EEprom
            --this will be the reset eeprom
			finalEEprom = e[6]
        end
	 end 
end
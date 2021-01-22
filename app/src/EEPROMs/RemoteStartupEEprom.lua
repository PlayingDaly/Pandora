local fs = filesystem
local mainDriveID = nil
local nic = nil
local bcp = 9998
local rcp = 9997
local finalEEprom = ''
local allFilesSent = false
local t = computer.millis()

starts_with = function(str, start) return str:sub(1, #start) == start end
ends_with = function(str, ending)  return ending == "" or str:sub(-#ending) == ending end
lastIndexOfChar =   function(str,char) return string.find(str, char.."[^"..char.."]*$") end

--Wait for X seconds before starting 
function StartupPause(s)
    local wait = true
    local time = s * 1000

    print(string.format("Waiting for %s seconds before contacting the central server.\nPLEASE CLOSE THIS INTERFACE BEFORE THAT TIME OR THE GAME IS LIKELY TO CRASH", s))

    while wait do
	    local ct = computer.millis()
        local tl = (time - ct)
        
        --If 10s on less left then beep the computer every second
        if tl <= 10000 and tl % 1000 == 0 then
            computer.beep()
        end

        if tl % 1000 == 0 then print(tl/1000) end

        if ct > t + time then
		    t = ct
            wait = false
	    end
    end
end

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
local function mountDrive()
    if fs.mount("/dev/" .. mainDriveID, "/") ~= true then
        return "Unable to mount FS `" .. mainDriveID .. "`"
    else
        return "Drive mounted"
    end
end
local function boot()
    --Set Wait timer to 60s
    --StartupPause(60)              --Currently Breaks ENTIRE GAME
    print("Attempting to Boot Primary Drive")
    if fs.initFileSystem("/dev") ~= true then error("Failed to mount /dev") end
    for _, entry in ipairs(fs.childs("/dev")) do
        if entry ~= "serial" then
            mainDriveID = entry
            print("Primary Drive Found")
            print(mountDrive())
            print("Boot Successful for Startup EEprom")
        end
    end  
    networkSetup()
end
function Write(path, data)
    local fileData = fs.open(path,"w")

    if not fileData then panic("File system didn't open'") end

    fileData:write(data)
end
function CreateParentDir(path)
    print("Creating directory:", path)
    return fs.createDir(path)       --Note: As of 080121 this will always return false
end
function VerifyParentDir(rootDir, path, createIfMissing)
    local dirPath = ''
    local sPath = string.sub(path,1,lastIndexOfChar(path,"/"))              --File Path without the filename

    print(string.format("R:%s\tP:%s\tS:%s",rootDir,path, sPath))

    --Assuming if the path ends with a / then its a dir
    if ends_with(rootDir,'/') then
         CreateParentDir(rootDir)

        --Remove the Leading /
        if starts_with(sPath, "/") then
            sPath = sPath:sub(2)
        end

        --Concat the current root dir to the sPath
        dirPath = rootDir..sPath
    else
        dirPath = sPath
    end

    --Iterates through 
    local bpath = ''
    for p in dirPath:gmatch("[^/]+") do
        bpath = bpath.."/"..p
            
        if not fs.exists(bpath) and createIfMissing then
            CreateParentDir(bpath)
        end
    end
end
function Copy(path, data)
    local rootDir = '/'
    local sPath = path

    --Split the path and verify the dirs exist, if not create them
    VerifyParentDir(rootDir, path, true)

    --Write the data to the file
    if starts_with(sPath, "/") then
        sPath = string.sub(sPath,2)
    end

    rootDir = rootDir..sPath
    print("Writing:\t"..rootDir)
    Write(rootDir,data)
end
local function RewriteEEProm(prom)
	computer.setEEPROM(prom)	
	computer.reset()
	computer.beep()
end
local function broadcast(mainDriveID)
 print("Broadcasting Request for deployment on port", bcp)
 nic:broadcast(bcp, "0x0011", mainDriveID)
end

--Startup
boot()


if not mainDriveID then
 computer.panic("Please Insert a hard drive and restart the computer") 
end
if nic then
 broadcast(mainDriveID)
end

local continuousBroadcast = true
while true do
	local ct = computer.millis()

    --60s rebroadcast if no ack received
	if ct > t + 60000 and continuousBroadcast then
		t = ct
       broadcast(mainDriveID)
	end
    if allFilesSent and allFilesSent ~= false and finalEEprom ~= '' then
        RewriteEEProm(finalEEprom)
        print("Write new EE")
    end

    e = table.pack(event.pull(0.1))
	
	if e[1] == "NetworkMessage" and e[3] ~= nic.id and e[4]== rcp then
		local msg = e[1]
		local s = e[2]
		local sender = e[3] --Central core
		local port = e[4]
		local code = e[5]   -- CODE
		local path = e[6]	-- File path
		local data = e[7]	-- File Data
		
		if code then
            if code == "0x0012" then
			    --print(s,sender,port,message)
			    continuousBroadcast = false
			    print("Setup Msg Received. Waiting for instructions")
		    elseif code == "0x0014" and path and data then
                --Write the Data to the drive
                Copy(path,data)
            elseif code == "0x0016" then
                --Code is file transmit complete
                allFilesSent = true
                nic:send(sender,port,"0x0015")
                print("Send All Files Received Response")
            elseif code == "0x0013" then
                --Receive last EEprom
                finalEEprom = fs.open(path,"r"):read("*all")
                print("Boot EEprom Read")
            end
        end
	 end 
end
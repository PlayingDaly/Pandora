local fs = filesystem
--local computerID = nil
local mainDriveID = nil
local nic = nil
local bcp = 9998
local rcp = 9997
local t = computer.millis()

local function networkSetup()
 print("Setting up Network Connection")
 networkCard = component.proxy(component.findComponent("networkCard"))
 if not networkCard[1] then computer.panic("Please Install a network card and name it networkCard before continuing")
 else nic = networkCard[1]
 end
 if nic then 
  event.listen(nic)
  nic:open(bcp) 
  nic:open(rcp)
  print("Network Configured")
 end

end
local function boot()
  print("Attempting to Boot Primary Drive")
  if fs.initFileSystem("/dev") ~= true then error("Failed to mount /dev") end
  for _, entry in ipairs(fs.childs("/dev")) do
    if entry ~= "serial" then
     mainDriveID = entry
     print("Primary Drive Found")
     print("Boot Successful")
    end
  end  
  networkSetup()
end
local function RewriteEEProm(prom)
	computer.setEEPROM(prom)	
	computer.reset()
	computer.beep()
end

local function broadcast(mainDriveID)
 --print("Broadcasting Request for deployment on port", bcp)
 nic:broadcast(bcp, "0x0011", mainDriveID,"Test 1", "Test 2", 25)
end

--Startup
boot()


if not mainDriveID then
 computer.panic("Please Insert a hard drive and restart the computer") 
end


if nic then
 broadcast(mainDriveID)
end


--When starting the cpu pause for 60 seconds.				--Move to Manual button press?????
--This is necessary due to the eeprom re-write crashing the game if the cpu interface is open
--Enabling the time hold once the machine is turned on should prevent this from happening 


local continuousBroadcast = true
while true do
	local ct = computer.millis()

	if ct > t + 60000 then			--60s rebroadcast if no ack received
		t = ct
       if continuousBroadcast then
		 broadcast(mainDriveID)
       end
	end

    e = table.pack(event.pull(0.1))
	
	if e[1] == "NetworkMessage" and e[3] ~= nic.id then --and e[4]== rcp then
		print(select(1,table.unpack(e)))
		local msg = e[1]
		local s = e[2]
		local sender = e[3]
		local port = e[4]
		local message = e[5] -- CODE
		
		if message and message == "0x0012" then
			print(s,sender,port,message)
			continuousBroadcast = false
			print("Setup Msg Received. Waiting for instructions")
		elseif message and message == "0x0013" then
			--this will be the reset eeprom
			local newProm = e[6]
			RewriteEEProm(newProm)
       end
	 end 
end
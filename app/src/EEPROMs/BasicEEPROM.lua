local fs = filesystem
local computerID = nil
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
  print("Network Configured")
  print("Broadcasting Request for deployment on port 9998")
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

--Startup
boot()


if not mainDriveID then
-- computer.beep()
 computer.panic("Please Insert a hard drive and restart the computer") 
end


if nic then
 nic:broadcast(bcp, "0x0001", computerID, mainDriveID)
end

while true do
	local ct = computer.millis()

	if ct > t + 10000 then
		t = ct
		nic:broadcast(broadcastPort, "0x0001", computerID, mainDriveID)
	end

	e, s, sender, port, message, cid, mdid = event.pull()
	
	if e == "NetworkMessage" and port == rcp then
		print(s,sender,port,message)
	 end 

end
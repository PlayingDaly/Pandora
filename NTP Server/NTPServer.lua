--NTP Display and Server Code
local tgpu
netCard = component.proxy(component.findComponent("networkCard"))
nic = netCard[1]
local broadcastPort = 9999

function SetGPU()
	tgpu = computer.getGPUs()[1]
	disp = computer.getScreens()
	tgpu:bindScreen(disp[1])
	tgpu:setSize(11,1)
	tgpu:fill(0,0,11,1," ")
end

function SetRouter()
	local conRtrs = component.proxy(component.findComponent("Router"))[1]

	if conRtrs then
		conRtrs:setPortWhitelist(true)
		conRtrs:addPortList(broadcastPort)
	end
end

--System Time Table
SysTime = {
			ms = 0,
			seconds = 0,
			minutes = 0,
			hours = 0,
			last_Sync = 0
		}	

SysTime.Reset = function()
       SysTime.seconds = 0
       SysTime.minutes = 0
       SysTime.hours = 0
end
			 
SysTime.Set = function(millis)

	SysTime.ms = millis
	SysTime.seconds = math.floor((SysTime.ms/1000) - (SysTime.minutes * 60) - (SysTime.hours * 3600))

	if SysTime.ms > 1 and SysTime.ms < 1000 then
		SysTime.Reset()
	end

	if SysTime.seconds > 59 then
		SysTime.minutes = SysTime.minutes + 1
		SysTime.seconds = 0
	end

	if SysTime.minutes > 59 then
		SysTime.hours = SysTime.hours + 1
		SysTime.minutes = 0
	end
end

function SysTime:DisplayTime(showMilliseconds)
	if showMilliseconds then
		return string.format("%02d:%02d:%02d.%03d", self.hours, self.minutes, self.seconds, self.ms)
	else
		return string.format("%02d:%02d:%02d", self.hours, self.minutes, self.seconds)
	end
end
function SysTime:GetTick()
	return self.ms
end

function SysTime:InitServer()
    SetGPU()
	nic:open(broadcastPort)
	event.listen(nic)
	self.Set(computer.millis())

	--Set the Connected Router to whitelist and only open port 9999
	SetRouter()
end

SysTime.Start = function()
	print("NTP Server Started")
	
	while true do
		SysTime.Set(computer.millis())       
   		
       pcall(function() 
                  tgpu:setText(1,0,SysTime:DisplayTime())
                  tgpu:flush()
                end)    

		e = table.pack(event.pull(0.1))
		if e and e[1] == "NetworkMessage" and e[4] == broadcastPort then
			print(string.format("Time request received from %s. Sending Sync Data!", e[3]))
			pcall(function() nic:send(e[3], broadcastPort, "0xFFFE", SysTime.ms) end) 
		end
	end
end

SysTime:InitServer()
SysTime.Start()

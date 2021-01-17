--NTP Display and Server Code
local tgpu
netCard = component.proxy(component.findComponent("netcard"))
nic = netCard[1]

function SetGPU()
tgpu = computer.getGPUs()[2]
disp = component.proxy(component.findComponent("Time"))
tgpu:bindScreen(disp[1])
tgpu:setSize(11,1)
tgpu:fill(0,0,11,1," ")
end

--Local VARS
local broadcastPort = 9999
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

local timeRunning = false

function SysTime:InitServer()
    SetGPU()
	nic:open(broadcastPort)
	self.Set(computer.millis())
end

SysTime.Start = function()
	print("SysTime Start")
	timeRunning = true;
    lasttime = 0
	while timeRunning do
		SysTime:Sync(computer.millis())
       if tgpu then
        tgpu:setText(1,0,SysTime:DisplayTime())
		 tgpu:flush()
       else
        SetGPU()
       end

   		if nic then
         if SysTime.ms > lasttime + 300 then
           lasttime = SysTime.ms
		 	  nic:broadcast(broadcastPort, SysTime.ms)
         end
		end
	end
	print("SysTime Done")
end
function SysTime:Sync(tick)
	tick = tick or 0
	self.Set(tick)
end

SysTime:InitServer()
SysTime.Start()





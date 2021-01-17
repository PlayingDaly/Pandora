--System Time Module

--Local VARS
local displayScreen = nil
local nic = nil
local broadcastPort = 9999
local location = "SERVER"			--SERVER or CLIENT
local CLIENT_TRANSMISSION_OFFSET = 0	--Estimated transmission time from Svr to Client  testing shows 525 unless timer in task then 0

--System Time Table
SysTime = {
			ms = 0,
			seconds = 0,
			minutes = 0,
			hours = 0,
			last_Sync = 0,

			--Set = setTime,
			--Reset = resetTime
		}	

SysTime.Reset = function()
       SysTime.seconds = 0
       SysTime.minutes = 0
       SysTime.hours = 0
end
			 
SysTime.Set = function(millis)

	SysTime.ms = millis + CLIENT_TRANSMISSION_OFFSET
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
	if self.ms == 0 and location:upper() == "CLIENT" then
		return "No Sync"
	elseif showMilliseconds then
		return string.format("%02d:%02d:%02d.%03d", self.hours, self.minutes, self.seconds, self.ms)
	else
		return string.format("%02d:%02d:%02d", self.hours, self.minutes, self.seconds)
	end
end
function SysTime:GetTick()
	return self.ms
end
SysTime.Display = function()
	return string.format("System Time: %s",SysTime:DisplayTime(false))
end

local timeRunning = false

function SysTime:InitServer(screen,n)
	location = "SERVER"
	if screen then 
		displayScreen = screen
		displayScreen.gpu:Fill(0,0,displayScreen.width,displayScreen.height," ")
	end

	if n then
		nic = n
		nic:open(broadcastPort)
	end

	self.Set(computer.millis())
end
function SysTime:InitClient(screen, nic)
	location = "CLIENT"
	if screen then 
		displayScreen = screen
		displayScreen.gpu:Fill(0,0,displayScreen.width,displayScreen.height," ")
	end

	if n then
		nic = n
		nic:open(broadcastPort)
		event.listen(nic)
	end
end


SysTime.Start = function()
	if location == "CLIENT" then error("SysTime can ONLY be run on the NTP Server") end

	SysTime:Sync(computer.millis())

	if displayScreen and displayScreen.gpu then
		--Local vars handle rare case on factory load throwing an exception due to data not loaded yet
		local x = displayScreen.lastWritePoint.x+1 or 1
		local y = displayScreen.height/2 or 1

		displayScreen.gpu:setText(x,y,SysTime:DisplayTime())
		displayScreen.gpu:flush()
	end
		
	if nic then
		nic:broadcast(broadcastPort, SysTime.ms)
	end
end
function SysTime:Stop()
	timeRunning = false
end
function SysTime:Sync(tick)
	tick = tick or 0
	self.Set(tick)
end



--System Time Module

--Local VARS
local displayScreen = nil
local nic = nil
local broadcastPort = 9999
local location = "SERVER"			--SERVER or CLIENT
local ntpsvr_address = ''
local CLIENT_TRANSMISSION_OFFSET = 0	--Estimated transmission time from Svr to Client  testing shows 525 unless timer in task then 0

--System Time Table
SysTime = {
			ms = 0,
			seconds = 0,
			minutes = 0,
			hours = 0,
			last_sync = 0,				--Last tick from the NTP Svr
			last_sync_local = 0,		--Local millis at last NTP Svr tick
			ServerAddress = ''
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
	elseif SysTime.seconds < 0 then
		SysTime.seconds = 0
	end

	if SysTime.minutes > 59 then
		SysTime.hours = SysTime.hours + 1
		SysTime.minutes = 0
	elseif SysTime.minutes < 0 then
		SysTime.minutes  = 0
	end

	if SysTime.ms < 1000*60*60 then
		SysTime.hours = 0
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
function SysTime:InitClient()
	location = "CLIENT"	
end
function SysTime:SetNTPAddress(address)
	--print("Setting NTP address to: ",address)
	self.ServerAddress = address
end

SysTime.Start = function()
	local ct = computer.millis()
	if location == "CLIENT" then
		--If its first execution or more then 30s has passed call for a NTP server Sync
		if SysTime.last_sync_local == 0 or ct > SysTime.last_sync_local + 30000 then
			SysTime.RequestTime()
			SysTime.last_sync_local = 1
		end

		if SysTime.last_sync_local > 1 then
			local t = ct + SysTime.last_sync - SysTime.last_sync_local
			--print(string.format("Time:%s :: %s + %s - %s = %s", SysTime:DisplayTime(), ct,SysTime.last_sync, SysTime.last_sync_local, t))		--THIS DOESN"T RETURN CORRECT TIME......"
			SysTime.Set(t)
		end


		
	else
		SysTime.Set(ct)

		pcall(function() 
                  displayScreen.gpu:setText(1,0,SysTime:DisplayTime())
                  displayScreen.gpu:flush()
                end)
	end
end
function SysTime:Stop()
	timeRunning = false
end
function SysTime:Sync(tick)
	tick = tick or 0
	self.last_sync_local = computer.millis()
	self.last_sync = tick
	print("Last Sync Set:", self.last_sync)
	self.Set(tick)
end
SysTime.RequestTime = function()
	pcall(function() 
			--print("Requesting Time from", SysTime.ServerAddress)
			if not SysTime.ServerAddress or SysTime.ServerAddress == '' then
				SysConfig.Network_Manager.execute.nic:broadcast(9999,"0xFFFD")
			else
				SysConfig.Network_Manager.execute.nic:send(SysTime.ServerAddress,9999,"0xFFFD")
			end
		end
		)
end


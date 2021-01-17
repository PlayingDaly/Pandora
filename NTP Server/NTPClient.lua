netcard = component.proxy(component.findComponent("netcard"))
nic = netcard[1]

gpu = computer.getGPUs()[1]
screen = component.proxy(component.findComponent("screen"))
s = screen[1]
gpu:bindScreen(s)
gpu:setSize(11,1)
gpu:fill(0,0,11,1, " ")


TRANSMISSION_OFFSET = 525    --Estimate transmission offset in ms (Adjust as needed)

SysTime = {
			ms = 0,
			seconds = 0,
			minutes = 0,
			hours = 0,
			last_Sync = 0
				}

function WriteTime()
    SysTime.seconds = math.floor((SysTime.ms/1000) - (SysTime.minutes * 60) - (SysTime.hours * 3600))

    --Handle Sync Resets
    if SysTime.ms > 1 and SysTime.ms < 1000 then
       SysTime.seconds = 0
       SysTime.minutes = 0
       SysTime.hours = 0
    end 
	if SysTime.seconds > 59 then
		SysTime.minutes = SysTime.minutes + 1
		SysTime.seconds = 0
	end

	if SysTime.minutes > 59 then
		SysTime.hours = SysTime.hours + 1
		SysTime.minutes = 0
	end
	return string.format("%02d:%02d:%02d", SysTime.hours, SysTime.minutes, SysTime.seconds)
end

print("Listening for NTP SYNC")
nic:open(9999)
event.listen(nic)
timeSync = false
while true do

 --Listen for all msgs
 e,s,sender,port,message = event.pull(1)

 if e == "NetworkMessage" then
  if port == 9999 then
   --this is the ntp time sync msg
   SysTime.ms = tonumber(message) + TRANSMISSION_OFFSET
   SysTime.last_Sync = computer.millis()
  end
 end

 --If its been more then 5 seconds since last sync show issue and reset time to 1ms while waiting for 
 --sync to reestablish
 if SysTime.last_Sync + 5000 <= computer.millis() then
  gpu:setText(1,0,"Sync Lost")
  SysTime.ms = 1
 elseif SysTime.ms == 0 then
  gpu:setText(1,0,"No Time Sync")
 else
  if timeSync then gpu:fill(0,0,11,1, " ") end   --Fixed h/w for testing
  gpu:setText(1,0,WriteTime())
  timeSync = true
 end


 gpu:flush()
end


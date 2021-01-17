

--Port Actions File
--Defines the functions(Send/Receive) for each port
PortActions = {}

















--Port 9998 - New Computer Setup Request
PortActions.ReceiveCPUSetup = function(...)
	local srcID = select(1,...)
	local netcode = select(3,...)
	local driveID = select(4,...)

	if netcode == "0x0010" then
		--Register the new computer as a status reporter
		print("Reg new computer")
	elseif netcode == "0x0011" then
		--Register the computer if not registered.
		

		--Process the Deployment actions to send
		print("Process Deployment")
	end
end
PortActions.SendCPUSetup = function()
	--Do Nothing
end

--Port 9999 - Restricted NTP Broadcast Port
PortActions.ReceiveNTP = function(...)
	local netcode = select(1,...)
	local syncData = select(2,...)

	if netcode == "0x0001" then
		SysConfig.Time.Set(syndData)
	end
end
PortActions.SendNTP = function()
	--Broadcast the SysTime
	if nic then
		nic:broadcast(9999, SysTime.ms)
	end
end

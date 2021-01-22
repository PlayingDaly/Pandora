require "actions.Deploy"
require "libs.networkcode"

--Port Actions File
--Defines the functions(Send/Receive) for each port
PortActions = {}


--Port 9998 - New Computer Setup Request
PortActions.ReceiveCPUSetup = function(portData, ...)
	local address = select(1,...)
	local netcode = select(3,...)
	local driveID = select(4,...)

	if netcode == "0x0010" then
		--Register the new computer as a status reporter
		print("Reg new computer")
	elseif netcode == "0x0011" then
		--Register the computer if not registered.
		
		--Process the Deployment actions to send
		print("Process Deployment")		
		Deploy:RemoteFactorySetup(address,portData.responsePort.port)
		print("RMT Drive: ", driveID)
		print("Deployment Complete")
	end
end
PortActions.SendCPUSetup = function()
	--Do Nothing
end

--Port 9999 - Restricted NTP Broadcast Port
PortActions.ReceiveNTP = function(...)
	local address = select(2,...)
	local netcode = select(4,...)
	local syncData = select(5,...)

	--print(select(1,...))

	if netcode == "0xFFFE" then
		SysConfig.Time:SetNTPAddress(address)
		SysConfig.Time:Sync(syncData)
		print("Time Sync R")
	end
end
PortActions.SendNTP = function(address)
	--Broadcast the SysTime
	if nic then
		nic:send(address, 9999, "0xFFFD", SysTime.ms)
	end
end

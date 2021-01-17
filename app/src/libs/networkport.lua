require "actions.portActions"

function PortData(p,options)
	local this = {
			port = p,
			description = '',
			canSend = false,		--Can Data be sent on this port
			canReceive = false,		--Can the port be used to catch data(decided at the sending location) ie. should data be returned using this port
			responsePort = nil,
			isRestricted = false,
			sendFunc = nil,
			receiveFunc = nil
	}
		
		function this:ValidateAndProcess(...)
			print("processing port", self.port)
			--print("args:", select(1,...))

			--Check if Receive Func is set. if so process the func
			if self.receiveFunc then
				print("Calling Receive Func")
				self.receiveFunc(...)
			end
		end

	--Options 
	if options then
		if options.description then this.description = options.description end
		if options.canSend then this.canSend = options.canSend end
		if options.canReceive then this.canReceive = options.canReceive end
		if options.isRestricted then this.isRestricted = options.isRestricted end
		if options.sendFunc then this.sendFunc = options.sendFunc end
		if options.receiveFunc then this.receiveFunc = options.receiveFunc end
	end

	return this
	
end
function CreatePort(p,options)
	return PortData(p,options)
end


PortMap = {}

--Reserved ports

--	9998				--This is the new computer setup port
--	9999				--This is the SysTime Broadcast Port


function PortMap:UpdatePort(port)

end

function PortMap:RegisterPort(port)
	--Verify the Port isn't in the map
	local p = PortMap[port.port]

	if not p then
		--new port
		PortMap[port.port] = port
	else
		--update port
		self:UpdatePort(port)
	end
end
function PortMap:FindPort(portNum)
	return self[portNum]
end

function PortMap:OpenPorts(nic)
	if not nic then error("Unable to open ports. No NIC provided") end
	for k,v in ipairs(PortMap) do
		if v.canSend then
			nic:open(k)
		end
	end
end

function PortMap:SetRestrictedPorts()

PortMap[9997] = CreatePort(9997, {canSend = true, canReceive = false, isRestricted = true, description = "New CPU setup response port"})
PortMap[9998] = CreatePort(9998, {	canSend = true, canReceive = false, isRestricted = true, responsePort = PortMap[9997], description = "New CPU setup request port",
									sendFunc = PortActions.SendCPUSetup, receiveFunc = PortActions.ReceiveCPUSetup})
PortMap[9999] = CreatePort(9999, {canSend = true, canReceive = false, isRestricted = true, description = "NTP Systime broadcast port",
									sendFunc = PortActions.SendNTP, receiveFunc = PortActions.ReceiveNTP})


end

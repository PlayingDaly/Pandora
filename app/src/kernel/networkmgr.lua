
require "libs.networkport"
require "libs.networkcode"
require "libs.networkrouter"

NetworkManager = {
	nic = nil,						--Primary Network Card(FUTURE: Allow for multiple nics)
	connectedRouters = nil,
	factoryRequests = {},

}
function NetworkManager:Initialize()
	print("Starting Network Manager.....")

	--Find the nic -- 17_01_21 only supports 1 nic -- Future add multi-nic support
	print("Initialize the network card")
	self.nic = component.proxy(component.findComponent("networkCard"))[1]
	if not self.nic then computer.panic("Please Install a network card and name it networkCard before continuing") end

	--Find the Parent Router
	print("Finding connected Routers")
	local conRtrs = component.proxy(component.findComponent("Router"))
	
	if not conRtrs or #conRtrs < 1 then
		print("No Routers found in the network. Skipping Router Setup")
	else
		print(string.format("%s routers found. Setting router configurations", #conRtrs))
		self.connectedRouters = {}

		for k,v in pairs(conRtrs) do 
			self.connectedRouters[k] = NetworkRouter(v)
			--print(self.connectedRouters[k]:Details())
		end
	end
	
	
	--Opening the nic to listen for events
	--self.nic:Open(9999)
	self.nic:Open(9998)
	event.listen(self.nic)

	PortMap:SetRestrictedPorts()

	--Register the listen event
	SysConfig.Event_Manager.execute:RegisterListener(NetworkManager.nic,NetworkManager.HandleMessage,ListenerTypes.NetworkMessage)

end

function NetworkManager:AddActionRequest()
	--Requests that require actions to be taken(New Factory Deployment. Settings)

end

--When 
NetworkManager.HandleMessage = function(src, args)
	--If port is black listed ignore it
	if NetworkManager.blacklist and #NetworkManager.blacklist > 0 then
		return
	else
		local sender = args[2]
		local port = args[3]
		local code = args[4]

		--Remove the mapped args
		table.remove(args,1)		--Remove the first argument of the local component
		--table.remove(args,1)
		--table.remove(args,1)
		--table.remove(args,1)

		
		--local remainingArgs = args
		--print(string.format("Network Message Received from %s on port %s, code %s with %s args", sender, port, code, #remainingArgs))

		--Find the Port from the PortMap
		local pdata = PortMap:FindPort(port)

		if pdata then
			--Remaining args will contain sender,port,code and add'l args
			pdata:ValidateAndProcess(table.unpack(args))
		end

	end
end
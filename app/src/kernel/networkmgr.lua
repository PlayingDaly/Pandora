
require "network"









NetworkManager = {
	nic = nil,						--Primary Network Card(FUTURE: Allow for multiple nics)
	listenPorts = {-1}				--Set to -1 means listen for everything
	whitelist = {},
	blacklist = nil
}
function NetworkManager:Initialize()
	print("Starting Network Manager.....")

	--Find the nic
	print("Initialize the network card")
	self.nic = component.proxy(component.findComponent("networkCard"))[1]
	if not self.nic then computer.panic("Please Install a network card and name it networkCard before continuing") end

	--Register the listen event
	EventManager:RegisterListener(NetworkManager.nic,NetworkManager.HandleMessage,ListenerTypes.NetworkMessage)

end


--When 
NetworkManager.HandleMessage = function(s,sender,port,...)
	print(string.format("Network Message Received from % on port %s with %s args", sender, port, select("#",...))
end
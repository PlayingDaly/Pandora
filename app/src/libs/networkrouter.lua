
RouterModes = {
	Blacklist = "Blacklist",
	NotConfigured = "Blacklist",				--Per the FICST DOCS  @ https://docs.ficsit.app/ficsit-networks/0.0.1/buildings/NetworkRouter.html
	Whitelist = "Whitelist"
}

NetworkRouter = function(com, allowInbound)
	local this = {
		name = com.nick,
		component = com,
		portFilterMode = RouterModes.NotConfigured,
		portFilter = {},
		addressFilterMode = RouterModes.NotConfigured,
		addressFilter = {}
	}
	function this:Details()
		return string.format("%s:\n\tport mode: %s with %s ports.\n\taddress mode: %s with %s addresses.", self.name, self.portFilterMode, #self.portFilter, self.addressFilterMode, #self.addressFilter)
	end
	function this:BlacklistAll()
		self:BlacklistAllPorts()
		self.BlackListAllAddresses()
	end
	function this:SetPortFilterMode(m)
		if m == RouterModes.Whitelist then
			component:setPortWhitelist(true)
			self.portFilterMode = m
		else
			component:setPortWhitelist(false)
			self.portFilterMode = m or RouterModes.NotConfigured
		end
	end
	function this:AddPort(port)
		if self.component then
			--Only handles network port class as of 17_01_21
			if type(port) == "table" then
				if not self.portFilter[port.port] then
					self.portFilter[port.port] = port
					self.component:addPortList(port.port)
				end
			end
		end
	end
	function this:RemovePort(port)
		if self.component then
			if self.portFilter[port.port] then
				self.component:removePortList(port.port)
				self.portFilter[port.port] = nil
			end
		end
	end
	function this:BlacklistAllPorts()
		self:SetPortFilterMode(RouterModes.Whitelist)
		self.portFilter = {}
	end

	function this:SetAddressFilterMode(m)
		if m == RouterModes.Whitelist then
			component:setAddressWhitelist(true)
			self.portFiltermode = m
		else
			component:setAddressWhitelist(false)
			self.portFiltermode = m or RouterModes.NotConfigured
		end
	end
	function this:AddAddress(address)
		if self.component then
			local i = Utils.table.getKeyForValue(self.addressFilter, address)
			if not self.addressFilter[i] then
				self.component:addAddrList(address)
				self.addressFilter[#self.addressFilter + 1] = address
			end
		end
	end
	function this:RemoveAddress(address)
		if self.component then
			local i = Utils.table.getKeyForValue(self.addressFilter, address)
			if self.addressFilter[i] then
				self.component:removeAddrList(address)
				self.addressFilter[i] = nil
			end
		end
	end
	function this:BlacklistAllAddresses()
		self:SetAddressFilterMode(RouterModes.Whitelist)
		self.addressFilter = {}
	end

	if allowInbound and allowInbound == false then
		this:BlacklistAll()
	end

	--Initialize the Router


	return this
end
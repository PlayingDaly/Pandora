
SystemStatus = {
					Not_Connected = "0x0001",
					Connected = "0x0002",
					Transmitting_Request = "0x0003",
					Receiving_Request = "0x0004",

}

function NetworkComputer(nic,n)
	local this = {
					nic = nic,
					name = n,
					status = SystemStatus.Not_Connected
				}

	this:SetStatus = function(s)
		self.status = s
	end
	this:GetStatus = function()
		return self.status
	end

	return this
end
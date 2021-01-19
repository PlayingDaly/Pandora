


local function NetworkCode(c,d)
	local this = {
		code = c,
		description = d
	}

	function this:Details()
		return string.format("%s - %s", self.code, self.descriptions)
	end
	return this
end

--TODO: FIX DESIGN.
--NEED A BETTER WAY TO LOOKUP AND MANAGE NETWORK CODES
NetworkCodes = {
				NetworkCode("0x0001", "NTP Server Time"),
				NetworkCode("0x0002", "Acknowledge"),





				NetworkCode("0x0010", "Register new computer"),
				NetworkCode("0x0011", "New Computer waiting for setup"),
				NetworkCode("0x0012", "New Computer setup received"),
				NetworkCode("0x0013", "New EEprom sent"),
				NetworkCode("0x0014", "Transmit new file"),
				NetworkCode("0x0015", "All files received"),
				NetworkCode("0x0016", "All files sent"),


				NetworkCode("0x0020", "Remote factory status request"),
				NetworkCode("0x0021", "Remote factory status response"),
}

NetworkCodeLookup = function(code)
	return Utils.table.getKeyForValue(NetworkCodes, code, "code")
end
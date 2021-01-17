


local function NetworkCode(c,d)
	local this = {
		code = c,
		description = d
	}

	return this
end


NetworkCodes = {
				NetworkCode("0x0001", "NTP Server Time"),





				NetworkCode("0x0010", "Register new computer"),
				NetworkCode("0x0011", "New Computer waiting for setup"),
				NetworkCode("0x0012", "New Computer setup received"),
				NetworkCode("0x0013", "Transmit new files"),
				NetworkCode("0x0014", "All files received"),


				NetworkCode("0x0020", "Remote factory status request"),
				NetworkCode("0x0021", "Remote factory status response"),
}